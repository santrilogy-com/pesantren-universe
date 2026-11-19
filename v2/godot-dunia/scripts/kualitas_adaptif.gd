class_name KualitasAdaptif
extends Node
## Kualitas adaptif (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB:
## "kualitas game tergantung device user").
##
## 3 tingkat (Ringan / Sedang / Tinggi) + mode Otomatis (default).
## Otomatis: tingkat awal dari info perangkat (web saja, guard
## OS.has_feature("web")) LALU dikoreksi probe FPS ~3 detik setelah
## masuk dunia. Sesudahnya FPS dipantau terus; bila rendah sustained,
## turun satu tingkat otomatis (hysteresis + cooldown). NAIK otomatis
## TIDAK PERNAH dilakukan — naik hanya lewat pengaturan manual.
## Alasan: naik-turun otomatis berosilasi (naik -> fps jatuh -> turun
## -> fps naik -> naik lagi...); tingkat hasil deteksi sudah yang
## "benar" untuk perangkat itu, dan pemain yang merasa mampu selalu
## bisa menaikkan sendiri dari Pengaturan.
##
## TUAS YANG JALAN (diukur, bukan asumsi):
## - Engine.max_fps, bayangan matahari (shadow_enabled + jarak),
##   camera far, pengali energi lampu omni, jarak cull Label3D, MSAA.
## - scaling_3d TIDAK dipakai: TERBUKTI inert di renderer GL
##   Compatibility (wajib web export) — setter menolak BILINEAR,
##   baca-balik 0 (tes 19 Nov, test_cek_perf_setting.gd).
## - MSAA DIPAKAI di tingkat Tinggi: TERBUKTI diterima Compatibility
##   — setter MSAA_4X dibaca-balik 2 (tes 19 Nov, test_msaa.gd).
##   Baca-balik BUKAN bukti driver HP benar-benar menerapkan — itu
##   perlu T1 Mas — tapi penolakan di sini sudah cukup untuk menolak.
##
## TIDAK DIGANGGU: perbaikan statis 1-6 (segmen primitif rendah,
## caster default OFF, dst.) adalah BASELINE — tingkat kualitas hanya
## mengatur tuas DINAMIS. Modulasi siang/malam lampu di pencahayaan.gd
## + langit_dinamis.gd tetap jalan: tingkat kualitas hanya MENGALIKAN
## energi (pengali_energi / pengali_lampu), bukan mengganti faktor
## siang/malam (lerpf(0.0, 2.0, f) tetap).
##
## Save: "kualitas_mode" ("otomatis"/"ringan"/"sedang"/"tinggi") dan
## "kualitas_tingkat" (tingkat yang sedang diterapkan; "" = belum
## pernah ditentukan -> deteksi saat setup). Keduanya WAJIB ada di
## SantriSave.default_data() (load_data membuang kunci yang tidak
## ada di sana).

const MODE_OTOMATIS := "otomatis"
const MODE_RINGAN := "ringan"
const MODE_SEDANG := "sedang"
const MODE_TINGGI := "tinggi"
const SEMUA_MODE := [MODE_OTOMATIS, MODE_RINGAN, MODE_SEDANG, MODE_TINGGI]
const URUTAN_TINGKAT := [MODE_RINGAN, MODE_SEDANG, MODE_TINGGI]

## Nilai per tingkat. far Ringan 350: gunung 331-338 m dari spawn
## masih terlihat (puncak bisa terpotong di tepi jauh seperti far300
## — trade-off tingkat rendah yang diterima); Sedang 450 terverifikasi
## foto A/B; Tinggi 600.
const TINGKAT := {
	MODE_RINGAN: {
		"max_fps": 30, "bayangan": false, "shadow_jarak": 100.0,
		"far": 350.0, "omni": 0.6, "label_cull": 25.0,
		"msaa": 0, # Viewport.MSAA_DISABLED
	},
	MODE_SEDANG: {
		"max_fps": 60, "bayangan": true, "shadow_jarak": 100.0,
		"far": 450.0, "omni": 1.0, "label_cull": 40.0,
		"msaa": 0,
	},
	MODE_TINGGI: {
		"max_fps": 0, "bayangan": true, "shadow_jarak": 200.0,
		"far": 600.0, "omni": 1.0, "label_cull": 60.0,
		"msaa": 2, # Viewport.MSAA_4X (terverifikasi diterima, test_msaa.gd)
	},
}

## Ambang FPS: probe < 30 -> turun; pantau < 28 selama 5 jendela
## 1 detik berturut-turut -> turun; jeda 10 detik antar penurunan.
const PROBE_DETIK := 3.0
const PROBE_FPS_MIN := 30.0
const PANTAU_FPS_MIN := 28.0
const PANTAU_JENDELA := 5
const COOLDOWN_DETIK := 10.0

var _mode: String = MODE_OTOMATIS
var _tingkat: String = MODE_SEDANG
var _kamera: Camera3D = null
var _matahari: DirectionalLight3D = null
var _save: Dictionary = {}
var _fase: String = "idle" # "idle" | "probe" | "pantau"
var _probe_waktu := 0.0
var _probe_frame := 0
var _jendela_waktu := 0.0
var _jendela_frame := 0
var _jendela_rendah := 0
var _cooldown := 0.0
var _fps_terakhir := 0.0
var _cull_label := 40.0


## Pasang dari main._ready (SETELAH kamera dibuat; matahari sudah ada
## karena PesantrenBuilder.build() jalan duluan). Menerapkan tingkat
## awal: mode manual -> tingkat = mode; otomatis + tingkat tersimpan
## -> pakai simpanan; otomatis + tingkat kosong -> deteksi perangkat.
func setup(main: Node, kamera: Camera3D, save: Dictionary) -> void:
	_kamera = kamera
	_save = save
	_matahari = main.find_child("CahayaMatahariBulan", true, false) as DirectionalLight3D
	if _matahari == null:
		push_warning("KualitasAdaptif: matahari tidak ketemu — tuas bayangan dilewati.")
	_mode = String(_save.get("kualitas_mode", MODE_OTOMATIS))
	if _mode not in SEMUA_MODE:
		_mode = MODE_OTOMATIS
	if _mode == MODE_OTOMATIS:
		var tersimpan := String(_save.get("kualitas_tingkat", ""))
		if tersimpan in URUTAN_TINGKAT:
			_tingkat = tersimpan
		else:
			_tingkat = deteksi_tingkat_awal()
			print("KualitasAdaptif: deteksi perangkat -> %s" % _tingkat)
	else:
		_tingkat = _mode
	_terapkan_tingkat(_tingkat)


## Deteksi tingkat awal dari perangkat (web saja). Aturan konservatif:
## ambil yang TERENDAH dari sinyal yang diketahui; sinyal tak dikenal
## (0 / tidak ada) diabaikan, bukan dipaksa rendah. Bukan web -> sedang.
static func deteksi_tingkat_awal() -> String:
	if not OS.has_feature("web"):
		return MODE_SEDANG
	var hasil = JavaScriptBridge.eval("[navigator.hardwareConcurrency || 0, navigator.deviceMemory || 0, (window.innerWidth || 0) * (window.innerHeight || 0)]")
	if typeof(hasil) != TYPE_ARRAY or (hasil as Array).size() < 2:
		return MODE_SEDANG
	var core := int((hasil as Array)[0])
	var mem := float((hasil as Array)[1])
	var piksel := 0
	if (hasil as Array).size() > 2:
		piksel = int((hasil as Array)[2])
	# Piksel hanya dicatat (korelasi dengan GPU lemah) — bukan sinyal.
	print("KualitasAdaptif: perangkat core=%d mem=%.1f GB piksel=%d" % [core, mem, piksel])
	var skor := 2 # mulai dari Tinggi, turunkan oleh sinyal terendah
	if core > 0:
		if core <= 4:
			skor = mini(skor, 0)
		elif core <= 8:
			skor = mini(skor, 1)
	if mem > 0.0:
		if mem <= 4.0:
			skor = mini(skor, 0)
		elif mem <= 8.0:
			skor = mini(skor, 1)
	return URUTAN_TINGKAT[skor]


## Mulai probe FPS (dipanggil main._masuk_pesantren — SETELAH masuk
## dunia, bukan di layar login yang fps-nya tidak mewakili dunia).
## Hanya mode Otomatis; mode manual tidak pernah diutak-atik.
func mulai_probe() -> void:
	if _mode != MODE_OTOMATIS:
		return
	_fase = "probe"
	_probe_waktu = 0.0
	_probe_frame = 0
	print("KualitasAdaptif: probe FPS %.0f detik dimulai (tingkat %s)" % [PROBE_DETIK, _tingkat])


func _process(delta: float) -> void:
	if _fase == "probe":
		_probe_waktu += delta
		_probe_frame += 1
		if _probe_waktu >= PROBE_DETIK:
			var rata := float(_probe_frame) / maxf(_probe_waktu, 0.001)
			_fps_terakhir = rata
			_koreksi_probe(rata)
			_fase = "pantau"
			_jendela_waktu = 0.0
			_jendela_frame = 0
			_jendela_rendah = 0
			_cooldown = 0.0
	elif _fase == "pantau":
		if _cooldown > 0.0:
			_cooldown -= delta
		_jendela_waktu += delta
		_jendela_frame += 1
		if _jendela_waktu >= 1.0:
			var rata := float(_jendela_frame) / maxf(_jendela_waktu, 0.001)
			_fps_terakhir = rata
			_catat_jendela(rata)
			_jendela_waktu = 0.0
			_jendela_frame = 0
			# Label baru (NPC/bubble) lahir dengan cull default 40 —
			# terapkan ulang cull tingkat saat ini tiap jendela.
			_terapkan_cull_label(_cull_label)


## Probe hanya mengoreksi ke BAWAH. fps >= ambang -> tingkat tetap
## (tidak naik otomatis — lihat alasan di header file).
func _koreksi_probe(fps_rata: float) -> void:
	if fps_rata < PROBE_FPS_MIN:
		print("KualitasAdaptif: probe fps=%.1f < %.0f — turun satu tingkat" % [fps_rata, PROBE_FPS_MIN])
		_turun_satu_tingkat("probe")
	else:
		print("KualitasAdaptif: probe fps=%.1f — tingkat %s dipertahankan" % [fps_rata, _tingkat])


func _catat_jendela(fps_rata: float) -> void:
	if _cooldown > 0.0:
		_jendela_rendah = 0
		return
	if fps_rata < PANTAU_FPS_MIN:
		_jendela_rendah += 1
		if _jendela_rendah >= PANTAU_JENDELA:
			print("KualitasAdaptif: fps=%.1f rendah %d jendela berturut-turut — turun satu tingkat" % [fps_rata, PANTAU_JENDELA])
			_turun_satu_tingkat("pantau")
			_jendela_rendah = 0
			_cooldown = COOLDOWN_DETIK
	else:
		_jendela_rendah = 0


func _turun_satu_tingkat(_alasan: String) -> void:
	var idx := URUTAN_TINGKAT.find(_tingkat)
	if idx > 0:
		_terapkan_tingkat(URUTAN_TINGKAT[idx - 1])
		print("KualitasAdaptif: tingkat kini %s" % _tingkat)


## Pilihan manual dari UI Pengaturan. "otomatis" -> deteksi ulang
## perangkat + probe ulang (probe hanya bisa menurunkan). Manual
## langsung menerapkan tingkatnya dan mematikan probe/pantau.
func atur_mode(mode: String) -> void:
	if mode not in SEMUA_MODE:
		return
	_mode = mode
	if mode == MODE_OTOMATIS:
		_tingkat = deteksi_tingkat_awal()
		_terapkan_tingkat(_tingkat)
		mulai_probe()
	else:
		_fase = "idle"
		_terapkan_tingkat(mode)
	print("KualitasAdaptif: mode=%s tingkat=%s" % [_mode, _tingkat])


func _terapkan_tingkat(nama: String) -> void:
	var t: Dictionary = TINGKAT[nama]
	_tingkat = nama
	Engine.max_fps = int(t["max_fps"])
	if _matahari != null:
		_matahari.shadow_enabled = bool(t["bayangan"])
		_matahari.directional_shadow_max_distance = float(t["shadow_jarak"])
	if _kamera != null:
		_kamera.far = float(t["far"])
	# Pengali energi — modulasi siang/malam (lerpf 0..2) TETAP di
	# pencahayaan.gd / langit_dinamis.gd; ini hanya mengalikannya.
	PencahayaanV2.pengali_energi = float(t["omni"])
	LangitDinamis.pengali_lampu = float(t["omni"])
	get_viewport().msaa_3d = int(t["msaa"])
	_cull_label = float(t["label_cull"])
	_terapkan_cull_label(_cull_label)
	_simpan()


func _terapkan_cull_label(jarak: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	for n in tree.get_nodes_in_group("label_kualitas"):
		var l := n as Label3D
		if l != null:
			l.visibility_range_end = jarak


func _simpan() -> void:
	_save["kualitas_mode"] = _mode
	_save["kualitas_tingkat"] = _tingkat
	SantriSave.save_data(_save)


func mode_saat_ini() -> String:
	return _mode


func tingkat_saat_ini() -> String:
	return _tingkat


func fps_rata_terakhir() -> float:
	return _fps_terakhir
