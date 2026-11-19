extends Node
## TES KAMERA PINCH v2 — Raka (lead game), 19 Nov 2026.
## v2 (koreksi setelah run v1): S2/S3/S6 v1 TIDAK VALID — pemain macet
## menabrak rintangan (S2: z=11,5; S6: x=-3,55, tepi serambi) sehingga
## 'jalan menyusuri tembok' tidak pernah terjadi (jalan pemain 0,7 m).
## v2: S2b/S3b mulai (12,0,14) strafe ke UTARA (lewati ujung tembok
## z=16); S6b strafe ke BARAT (lewati ujung tembok x=-8); S5b paksa
## flag _di_dalam_asrama_putra=true (keadaan nyata saat masuk lewat
## pintu — teleport melewati pemicu pintu, lihat _masuk_asrama_putra);
## S7b pakai _ke_piksel (v1 salah: rect kanvas dipakai mentah sebagai
## koordinat viewport sehingga sentuh joystick meleset). S0/S1/S4/S7a
## dipertahankan sebagai kontrol (valid di v1).
## Penyelidikan kamera tidak stabil saat pinch-zoom (laporan Mas 19 Nov 14:17):
## "saat jalan.. kadang camera tidak stabil terutama ketika jalan sempit
## atau dekat ke objek. Misal tembok.. bukan fitur kameranya.. tapi
## ketika di arahkan (dicubit) itu kadang tidak stabil."
## HANYA TES — tidak mengubah kode game. Mengukur, per skenario, deret
## waktu posisi kamera + panjang spring + keluaran penjaga
## (_jarak_kamera_aman) + zoom + yaw/pitch, lalu membandingkan:
## S1 terbuka+jalan+pinch (kontrol) | S2 tembok+jalan TANPA pinch |
## S3 tembok+jalan+pinch (skenario Mas) | S4 tembok+DIAM+pinch |
## S5 koridor Asrama+jalan+pinch | S6 ujung tembok Surau+jalan+pinch |
## S7 bocor input (joystick ditahan + pinch; lepas satu jari; drag asing).
## Hipotesis yang diuji: (a) SpringArm/penjaga vs zoom = osilasi saat
## sinar raycast melewati tepi tembok; (b) kamera menempel tembok saat
## jarak berubah; (c) cubit bocor ke input lain; (d) smoothing/spring
## melawan perubahan jarak cepat.
## JALANKAN DI Xvfb --resolution 892x412 (lanskap HP Mas).
## CSV per skenario di ~/workspace/.logs-gate-18nov/kamera-pinch-19nov/.

const MAIN_SCENE := "res://main.tscn"
const CSV_DIR := "/home/hatch/workspace/.logs-gate-18nov/kamera-pinch-19nov/"

var _lulus := 0
var _gagal := 0
var _main: Node
var _hasil := {} ## nama skenario -> Dictionary metrik (untuk cek banding).


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("KAMERA-PINCH LULUS: ", nama)
	else:
		_gagal += 1
		print("KAMERA-PINCH GAGAL: ", nama)


## Baca metrik dengan aman: bila _rekam mengembalikan null / kunci
## hilang (skenario gagal total), kembalikan default — _cek jadi
## GAGAL, bukan error runtime yang membunuh korutin _ready (itu
## yang membuat run pertama menggantung 900 dtk tanpa progres).
func _met(m, kunci: String, default: float) -> float:
	if m == null:
		return default
	return float((m as Dictionary).get(kunci, default))


## Pop-up PETUNJUK TOMBOL menelan sentuhan (dim full-screen
## MOUSE_FILTER_STOP) — tutup bila muncul, sebelum skenario apa pun
## yang memakai input sentuh. Idempotent.
func _tutup_petunjuk_jika_ada() -> void:
	if _main._ui.is_petunjuk_visible():
		_main._ui._petunjuk_mengerti_btn.pressed.emit()


## Kanvas -> viewport (pola test_sentuh_vs_mouse.gd): rect kontrol
## (get_global_rect) berkoordinat kanvas (1280x720 + expand);
## posisi injeksi InputEvent berkoordinat viewport/jendela.
func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _tunggu_waktu(detik: float) -> void:
	var t := 0.0
	while t < detik:
		await get_tree().process_frame
		t += get_process_delta_time()


## Settle setelah teleport / antar skenario: rig sudah di-snap oleh
## _teleport_player, tapi _spring_halus (reset_halus TIDAK pernah
## dipanggil dari mana pun) merangkak dari nilai lama — memanjang
## 4/dtk butuh ~1,6 dtk dari 2 m ke 8 m. Zoom juga dikembalikan
## ke 1,0 dulu supaya target spring tiap skenario mulai dari angka sama.
func _settle() -> void:
	_main._ui._joystick.output = Vector2.ZERO
	var k = _main._kamera
	if absf(k.zoom_target() - 1.0) > 0.001:
		k.geser_zoom(1.0 / k.zoom_target())
	var t := 0.0
	while t < 3.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		if t > 1.0 and absf(k.zoom_halus() - 1.0) < 0.01 and absf(_main._spring.spring_length - float(k.parameter_target(_main._di_dalam_asrama_putri or _main._di_dalam_asrama_putra, false, _main._cam_pitch, false)["spring"])) < 0.3:
			break


## Target spring frame ini — meniru hitungan _process main.gd
## (parameter_target murni: tidak mengubah apa pun).
func _target_spring() -> float:
	var tidur: bool = _main._player.aksi_saat_ini() == "tidur"
	var di_asrama: bool = _main._di_dalam_asrama_putri or _main._di_dalam_asrama_putra
	var di_ruangan: bool = _main._di_dalam or _main._di_dalam_cangkruk or _main._di_dalam_musholla or _main._di_dalam_kelas_putri or _main._di_dalam_asrama_putri or _main._di_dalam_asrama_putra or _main._di_dalam_kantor or _main._di_dalam_madrasah or _main._di_dalam_studio or _main._di_dalam_pos_jaga
	var t: Dictionary = _main._kamera.parameter_target(di_asrama, tidur, _main._cam_pitch, di_ruangan)
	return float(t["spring"])


func _npc_min_ke_kamera() -> float:
	var p: Vector3 = _main._cam.global_position
	var m := 999.0
	for npc in _main._npcs:
		m = minf(m, p.distance_to(npc.global_position + Vector3(0, 1.2, 0)))
	return m


# --- Injeksi sentuh (pola test_kamera.gd 6f) ---
func _sentuh_turun(idx: int, pos: Vector2) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = pos
	e.pressed = true
	Input.parse_input_event(e)


func _sentuh_naik(idx: int, pos: Vector2) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = pos
	e.pressed = false
	Input.parse_input_event(e)


func _seret(idx: int, pos: Vector2, rel: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = idx
	e.position = pos
	e.relative = rel
	Input.parse_input_event(e)


## Rekam satu skenario selama `detik` detik (waktu nyata) sambil
## joystick `joy` ditahan. `pinch` = {} (tanpa pinch) atau
## {"t0":float, "durasi":float, "p0a":Vector2, "p1a":Vector2,
##  "p0b":Vector2, "p1b":Vector2, "langkah":int} — jari merapat
## (p0a->p0b, p1a->p1b) = zoom out; merenggang = zoom in.
## Mengembalikan Dictionary metrik + menulis CSV.
func _rekam(nama: String, detik: float, joy: Vector2, pinch: Dictionary) -> Dictionary:
	_tutup_petunjuk_jika_ada()
	_main._ui._joystick.output = joy
	var t := 0.0
	var s_t: Array[float] = []
	var s_spring: Array[float] = []
	var s_guard: Array[float] = []
	var s_target: Array[float] = []
	var s_zh: Array[float] = []
	var s_cam: Array[Vector3] = []
	var s_play: Array[Vector3] = []
	var s_yaw: Array[float] = []
	var s_pitch: Array[float] = []
	var s_npc: Array[float] = []
	var pinch_jalan := false
	var pinch_selesai := false
	var langkah_berikut := 0
	var p0_lalu := Vector2.ZERO
	var p1_lalu := Vector2.ZERO
	if not pinch.is_empty():
		p0_lalu = pinch["p0a"]
		p1_lalu = pinch["p1a"]
	while t < detik:
		await get_tree().process_frame
		var d := get_process_delta_time()
		t += d
		if not pinch.is_empty() and not pinch_jalan and t >= float(pinch["t0"]):
			_sentuh_turun(0, pinch["p0a"])
			_sentuh_turun(1, pinch["p1a"])
			pinch_jalan = true
		if pinch_jalan and not pinch_selesai:
			var langkah: int = pinch["langkah"]
			var waktunya := float(pinch["t0"]) + float(pinch["durasi"]) * float(langkah_berikut + 1) / float(langkah)
			if t >= waktunya:
				var f := float(langkah_berikut + 1) / float(langkah)
				var p0: Vector2 = (pinch["p0a"] as Vector2).lerp(pinch["p0b"], f)
				var p1: Vector2 = (pinch["p1a"] as Vector2).lerp(pinch["p1b"], f)
				_seret(0, p0, p0 - p0_lalu)
				_seret(1, p1, p1 - p1_lalu)
				p0_lalu = p0
				p1_lalu = p1
				langkah_berikut += 1
				if langkah_berikut >= langkah:
					_sentuh_naik(0, p0)
					_sentuh_naik(1, p1)
					pinch_selesai = true
		var tgt := _target_spring()
		s_t.append(t)
		s_spring.append(_main._spring.spring_length)
		s_guard.append(_main._jarak_kamera_aman(tgt, 0.0))
		s_target.append(tgt)
		s_zh.append(_main._kamera.zoom_halus())
		s_cam.append(_main._cam.global_position)
		s_play.append(_main._player.global_position)
		s_yaw.append(_main._cam_yaw)
		s_pitch.append(_main._cam_pitch)
		s_npc.append(_npc_min_ke_kamera())
	_main._ui._joystick.output = Vector2.ZERO
	if pinch_jalan and not pinch_selesai:
		_sentuh_naik(0, p0_lalu)
		_sentuh_naik(1, p1_lalu)
	# --- Metrik ---
	var n := s_t.size()
	var m := {"nama": nama, "n": n, "T": t}
	var lompat_spring := 0.0
	var laju_spring := 0.0
	var balik := 0
	var arah_lalu := 0.0
	var spring_min := 999.0
	var spring_maks := -999.0
	var lompat_kam := 0.0
	var laju_kam := 0.0
	var frame_lompat := 0
	var jalan_kam := 0.0
	var jalan_play := 0.0
	var guard_min := 999.0
	var guard_aktif := 0
	var guard_transisi := 0
	var guard_aktif_lalu := false
	var npc_min := 999.0
	for i in n:
		var g_raw = s_guard[i]
		var g: float = float(g_raw) if g_raw != null else s_target[i]
		spring_min = minf(spring_min, s_spring[i])
		spring_maks = maxf(spring_maks, s_spring[i])
		guard_min = minf(guard_min, g)
		npc_min = minf(npc_min, s_npc[i])
		var aktif := g < s_target[i] - 0.5
		if aktif:
			guard_aktif += 1
		if i > 0 and aktif != guard_aktif_lalu:
			guard_transisi += 1
		guard_aktif_lalu = aktif
		if i == 0:
			continue
		var dt: float = s_t[i] - s_t[i - 1]
		if dt <= 0.0001:
			continue
		var ds: float = s_spring[i] - s_spring[i - 1]
		lompat_spring = maxf(lompat_spring, absf(ds))
		laju_spring = maxf(laju_spring, absf(ds) / dt)
		if absf(ds) > 0.05:
			var arah := signf(ds)
			if arah_lalu != 0.0 and arah != arah_lalu:
				balik += 1
			arah_lalu = arah
		var dk: float = s_cam[i].distance_to(s_cam[i - 1])
		lompat_kam = maxf(lompat_kam, dk)
		laju_kam = maxf(laju_kam, dk / dt)
		if dk / dt > 10.0:
			frame_lompat += 1
		jalan_kam += dk
		jalan_play += s_play[i].distance_to(s_play[i - 1])
	m["lompat_spring"] = lompat_spring
	m["laju_spring"] = laju_spring
	m["balik_spring"] = balik
	m["amplitudo_spring"] = spring_maks - spring_min
	m["spring_min"] = spring_min
	m["spring_maks"] = spring_maks
	m["lompat_kamera"] = lompat_kam
	m["laju_kamera"] = laju_kam
	m["frame_lompat"] = frame_lompat
	m["jalan_kamera"] = jalan_kam
	m["jalan_pemain"] = jalan_play
	m["rasio_gerak"] = jalan_kam / maxf(jalan_play, 0.01)
	m["guard_min"] = guard_min
	m["guard_aktif_pct"] = 100.0 * float(guard_aktif) / float(maxi(n, 1))
	m["guard_transisi"] = guard_transisi
	m["npc_min"] = npc_min
	m["yaw_awal"] = s_yaw[0]
	m["yaw_akhir"] = s_yaw[n - 1]
	m["pitch_awal"] = s_pitch[0]
	m["pitch_akhir"] = s_pitch[n - 1]
	m["zoom_target_akhir"] = _main._kamera.zoom_target()
	m["zoom_halus_akhir"] = _main._kamera.zoom_halus()
	m["play_awal"] = s_play[0]
	m["play_akhir"] = s_play[n - 1]
	_hasil[nama] = m
	# CSV bukti deret waktu.
	DirAccess.make_dir_recursive_absolute(CSV_DIR)
	var f := FileAccess.open(CSV_DIR + nama + ".csv", FileAccess.WRITE)
	if f != null:
		f.store_line("t,spring,guard,target,zoom_halus,cam_x,cam_y,cam_z,play_x,play_y,play_z,yaw,pitch,npc_min")
		for i in n:
			f.store_line("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.4f,%.4f,%.2f" % [s_t[i], s_spring[i], s_guard[i], s_target[i], s_zh[i], s_cam[i].x, s_cam[i].y, s_cam[i].z, s_play[i].x, s_play[i].y, s_play[i].z, s_yaw[i], s_pitch[i], s_npc[i]])
		f.close()
	print("KAMERA-PINCH %s: n=%d T=%.1f dtk | spring lompat maks %.2f m (%.1f m/dtk) balik=%d amplitudo %.2f m (%.2f..%.2f) | kamera lompat maks %.2f m (%.1f m/dtk) frame_lompat=%d jalan %.1f m vs pemain %.1f m (rasio %.2f) | guard min %.2f aktif %.0f%% transisi=%d | npc_min %.2f m | yaw %.3f->%.3f pitch %.3f->%.3f | zoom %.2f/%.2f | pemain %s -> %s" % [nama, n, t, lompat_spring, laju_spring, balik, spring_maks - spring_min, spring_min, spring_maks, lompat_kam, laju_kam, frame_lompat, jalan_kam, jalan_play, jalan_kam / maxf(jalan_play, 0.01), guard_min, 100.0 * float(guard_aktif) / float(maxi(n, 1)), guard_transisi, npc_min, s_yaw[0], s_yaw[n - 1], s_pitch[0], s_pitch[n - 1], _main._kamera.zoom_target(), _main._kamera.zoom_halus(), str(s_play[0]), str(s_play[n - 1])])
	return m


## Pilih arah strafe yang menggerakkan pemain sepanjang `sumbu`
## ("x" atau "z") ke arah `arah` (+1/-1): coba (1,0) 0,6 dtk,
## ukur; bila tidak cocok, pakai (-1,0).
func _pilih_strafe(sumbu: String, arah: float) -> Vector2:
	_main._ui._joystick.output = Vector2(1, 0)
	var p0: Vector3 = _main._player.global_position
	await _tunggu_waktu(0.6)
	var p1: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2.ZERO
	var d := (p1.z - p0.z) if sumbu == "z" else (p1.x - p0.x)
	print("KAMERA-PINCH kalibrasi strafe (1,0): d%s=%.2f (mau %+.0f)" % [sumbu, d, arah])
	if signf(d) == arah and absf(d) > 0.2:
		return Vector2(1, 0)
	return Vector2(-1, 0)


func _ready() -> void:
	var packed := load(MAIN_SCENE) as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Isolasi MP + paksa putra (pola test_kamera.gd).
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Tes kamera pinch")
	if _main._ui.is_petunjuk_visible():
		_main._ui._petunjuk_mengerti_btn.pressed.emit()
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	var k = _main._kamera
	# --- S0. Fakta runtime + pinch murni bekerja ---
	var emu = ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch")
	print("KAMERA-PINCH S0: emulate_mouse_from_touch (runtime) = %s | mode = %s" % [str(emu), k.nama_mode()])
	_cek("S0: emulate_mouse_from_touch=false di runtime (tanpa ini sentuh juga jadi mouse -> orbit bocor saat cubit)", emu == false)
	_cek("S0: mode awal NORMAL", k.mode() == 0)
	await _tunggu_waktu(2.0)
	# Pinch merapat 200 -> 60 px = zoom out, target harus dijepit 1,30.
	var m0 := await _rekam("S0-pinch-diam-terbuka", 3.0, Vector2.ZERO, {"t0": 0.5, "durasi": 1.5, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 12})
	_cek("S0: pinch merapat mengubah zoom target ke jepit 1,30 (dapat %.2f)" % k.zoom_target(), absf(k.zoom_target() - 1.30) < 0.02)
	_cek("S0: pinch diam di lapangan terbuka tidak membalik spring (balik=%d)" % int(_met(m0, "balik_spring", -1.0)), int(_met(m0, "balik_spring", -1.0)) <= 2)
	await _settle()
	# --- S1. KONTROL: lapangan terbuka + jalan + pinch-out ---
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	await _settle()
	var m1 := await _rekam("S1-terbuka-jalan-pinch", 4.0, Vector2(0, -1), {"t0": 0.5, "durasi": 2.0, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 14})
	await _settle()
	# --- S2/S3. Tembok x=14: pemain (12,0,10) menghadap barat
	# (kamera di timur, DI BALIK tembok), strafe menyusuri tembok
	# ke utara (+z, lewati ujung tembok z=16). S2 tanpa pinch, S3 + pinch.
	_main._teleport_player(Vector3(12, 0, 14), -PI * 0.5)
	await _settle()
	var strafe_z := await _pilih_strafe("z", 1.0)
	_main._teleport_player(Vector3(12, 0, 14), -PI * 0.5)
	await _settle()
	var m2 := await _rekam("S2b-tembok-jalan-tanpa-pinch", 5.0, strafe_z, {})
	await _settle()
	_main._teleport_player(Vector3(12, 0, 14), -PI * 0.5)
	await _settle()
	var m3 := await _rekam("S3b-tembok-jalan-pinch", 5.0, strafe_z, {"t0": 0.5, "durasi": 2.0, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 14})
	await _settle()
	# --- S4. Tembok x=14, DIAM + pinch-out (pinch saja, tanpa jalan) ---
	_main._teleport_player(Vector3(12, 0, 14), -PI * 0.5)
	await _settle()
	var m4 := await _rekam("S4-tembok-diam-pinch", 3.5, Vector2.ZERO, {"t0": 0.5, "durasi": 2.0, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 14})
	await _settle()
	# --- S5. Koridor Asrama Putra (2,6 m — jalan tersempit): jalan + pinch ---
	_main._teleport_player(_main._asrama_putra_interior_spawn, PI * 0.5)
	await _settle()
	# FLAG ASRAMA (v2): teleport melewati pemicu pintu sehingga
	# _di_dalam_asrama_putra=false (v1 mengukur aturan LUAR di dalam
	# ruangan). Di game nyata flag ini diset _masuk_asrama_putra()
	# saat masuk lewat pintu — paksa ke keadaan nyata itu di sini
	# (hanya state tes; _process tidak pernah membersihkannya
	# kecuali lewat pintu keluar, dan pemain jauh dari pintu).
	_main._di_dalam_asrama_putra = true
	print("KAMERA-PINCH S5b: di_asrama_putra dipaksa=%s (keadaan nyata di dalam Asrama; target spring harus 5,5 m, bukan 8,0)" % str(_main._di_dalam_asrama_putra))
	var m5 := await _rekam("S5b-koridor-asrama-jalan-pinch", 4.5, Vector2(0, -1), {"t0": 0.5, "durasi": 2.0, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 14})
	print("KAMERA-PINCH S5b: flag sesudah rekam di_asrama_putra=%s" % str(_main._di_dalam_asrama_putra))
	_main._di_dalam_asrama_putra = false
	await _settle()
	# --- S6. Ujung tembok selatan Surau (z=-4, x -8..+8): pemain
	# (-6,0,-2) menghadap selatan (kamera di utara, DI BALIK tembok),
	# strafe ke timur (+x) melewati ujung tembok x=8 + pinch-out.
	_main._teleport_player(Vector3(-6, 0, -2), 0.0)
	await _settle()
	var strafe_x := await _pilih_strafe("x", -1.0)
	_main._teleport_player(Vector3(-6, 0, -2), 0.0)
	await _settle()
	var m6 := await _rekam("S6b-ujung-tembok-surau-jalan-pinch", 4.5, strafe_x, {"t0": 0.5, "durasi": 2.0, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 14})
	# --- S7. Bocor input (hipotesis c) ---
	# S7a: joystick ditahan (output langsung) + pinch — zoom harus
	# berubah, yaw/pitch TIDAK boleh bergerak (cubit bukan orbit).
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	await _settle()
	var yaw0: float = _main._cam_yaw
	var pitch0: float = _main._cam_pitch
	var m7 := await _rekam("S7a-joystick-ditahan-pinch", 3.0, Vector2(0, -1), {"t0": 0.5, "durasi": 1.5, "p0a": Vector2(350, 200), "p1a": Vector2(550, 200), "p0b": Vector2(420, 200), "p1b": Vector2(480, 200), "langkah": 12})
	_cek("S7a: pinch tetap mengubah zoom saat joystick ditahan (target %.2f)" % k.zoom_target(), absf(k.zoom_target() - 1.30) < 0.02)
	_cek("S7a: yaw/pitch TIDAK bergerak selama pinch+joystick (dyaw %.4f dpitch %.4f)" % [absf(_met(m7, "yaw_akhir", 0.0) - yaw0), absf(_met(m7, "pitch_akhir", 0.0) - pitch0)], absf(_met(m7, "yaw_akhir", 0.0) - yaw0) < 0.01 and absf(_met(m7, "pitch_akhir", 0.0) - pitch0) < 0.01)
	await _settle()
	# S7b: TIGA jari sungguhan — jari 0 di atas joystick (harus
	# ditelan kontrol joystick, TIDAK masuk _sentuh), jari 1+2
	# pinch di area 3D (harus masuk _sentuh + mengubah zoom).
	var joy_rect: Rect2 = _main._ui._joystick.get_global_rect()
	# v2: rect kanvas (1280x720 + expand) HARUS dikonversi ke viewport
	# (pola _ke_piksel test_sentuh_vs_mouse) — v1 memakai rect mentah
	# sehingga sentuh joystick mendarat di luar viewport (y=586 > 412).
	var joy_tengah := _ke_piksel(joy_rect.get_center())
	var joy_atas := _ke_piksel(joy_rect.get_center() + Vector2(0, -60))
	print("KAMERA-PINCH S7b: joystick rect %s tengah kanvas %s -> viewport %s (atas %s)" % [str(joy_rect), str(joy_rect.get_center()), str(joy_tengah), str(joy_atas)])
	_sentuh_turun(0, joy_tengah)
	_sentuh_turun(1, Vector2(380, 200))
	_sentuh_turun(2, Vector2(520, 200))
	for i in 3:
		await get_tree().process_frame
	var sentuh_saat_pinch: int = _main._sentuh.size()
	_seret(0, joy_atas, joy_atas - joy_tengah)
	_seret(1, Vector2(430, 200), Vector2(50, 0))
	_seret(2, Vector2(470, 200), Vector2(-50, 0))
	for i in 5:
		await get_tree().process_frame
	var joy_out_akhir: Vector2 = _main._ui._joystick.output
	print("KAMERA-PINCH S7b: _sentuh.size()=%d (harap 2: jari joystick ditelan kontrol) | joystick output=%s (harap ~(0,-0,67): joystick menerima seretan) | zoom target=%.2f" % [sentuh_saat_pinch, str(joy_out_akhir), k.zoom_target()])
	_cek("S7b: jari joystick TIDAK masuk _sentuh (size=%d, harap 2)" % sentuh_saat_pinch, sentuh_saat_pinch == 2)
	_cek("S7b: joystick menerima sentuhan (output %s, harap y < -0,3)" % str(joy_out_akhir), joy_out_akhir.y < -0.3)
	_cek("S7b: pinch 2 jari tetap jalan saat jari ke-3 di joystick (zoom %.2f, harap 1,30)" % k.zoom_target(), absf(k.zoom_target() - 1.30) < 0.05)
	_sentuh_naik(0, joy_atas)
	_sentuh_naik(1, Vector2(430, 200))
	_sentuh_naik(2, Vector2(470, 200))
	await _settle()
	# S7c: lepas satu jari di tengah cubit, lalu seret jari sisa —
	# ukur lompatan yaw/pitch pada seretan pertama (bocor orbit?).
	_sentuh_turun(0, Vector2(350, 200))
	_sentuh_turun(1, Vector2(550, 200))
	_seret(0, Vector2(380, 200), Vector2(30, 0))
	_seret(1, Vector2(520, 200), Vector2(-30, 0))
	for i in 3:
		await get_tree().process_frame
	_sentuh_naik(1, Vector2(520, 200))
	for i in 2:
		await get_tree().process_frame
	var yaw_sebelum_lepas: float = _main._cam_yaw
	var pitch_sebelum_lepas: float = _main._cam_pitch
	_seret(0, Vector2(410, 200), Vector2(30, 0))
	for i in 3:
		await get_tree().process_frame
	var dyaw_lepas: float = _main._cam_yaw - yaw_sebelum_lepas
	var dpitch_lepas: float = _main._cam_pitch - pitch_sebelum_lepas
	print("KAMERA-PINCH S7c: seret 30px jari sisa setelah lepas satu jari -> dyaw %.4f rad dpitch %.4f rad (orbit 1 jari = 30*0,006 = 0,18 rad bila bocor penuh)" % [dyaw_lepas, dpitch_lepas])
	_sentuh_naik(0, Vector2(410, 200))
	await _settle()
	# S7d: drag jari ASING (index tak pernah disentuh) — apakah orbit?
	var yaw_sebelum_asing: float = _main._cam_yaw
	_seret(5, Vector2(400, 200), Vector2(40, 0))
	for i in 3:
		await get_tree().process_frame
	var dyaw_asing: float = _main._cam_yaw - yaw_sebelum_asing
	print("KAMERA-PINCH S7d: drag index asing 40px -> dyaw %.4f rad (0,24 bila orbit penuh)" % dyaw_asing)
	# --- Cek banding (bukti mekanisme) ---
	_cek("BANDING: S3b (tembok+jalan+pinch) balik spring > S1 (terbuka+jalan+pinch): %d vs %d" % [int(_met(m3, "balik_spring", -1.0)), int(_met(m1, "balik_spring", -1.0))], int(_met(m3, "balik_spring", -1.0)) > int(_met(m1, "balik_spring", -1.0)))
	_cek("BANDING: S3 lompat spring maks > S1: %.2f vs %.2f m" % [float(_met(m3, "lompat_spring", -1.0)), float(_met(m1, "lompat_spring", -1.0))], float(_met(m3, "lompat_spring", -1.0)) > float(_met(m1, "lompat_spring", -1.0)))
	_cek("BANDING: S3 guard bertransisi (hidup/mati) lebih sering dari S1: %d vs %d" % [int(_met(m3, "guard_transisi", -1.0)), int(_met(m1, "guard_transisi", -1.0))], int(_met(m3, "guard_transisi", -1.0)) > int(_met(m1, "guard_transisi", -1.0)))
	_cek("BANDING: S2b (tembok+jalan TANPA pinch) lebih tenang dari S3 (dengan pinch): balik %d vs %d" % [int(_met(m2, "balik_spring", -1.0)), int(_met(m3, "balik_spring", -1.0))], int(_met(m2, "balik_spring", -1.0)) < int(_met(m3, "balik_spring", -1.0)))
	_cek("BANDING: S4 (tembok+DIAM+pinch) tenang — balik=%d (jalan diperlukan sebagai pemicu)" % int(_met(m4, "balik_spring", -1.0)), int(_met(m4, "balik_spring", -1.0)) <= 2)
	_cek("BANDING: S6b lewati ujung tembok -> spring melonjak (min %.2f ke maks %.2f, harap selisih > 2 m)" % [float(_met(m6, "spring_min", -1.0)), float(_met(m6, "spring_maks", -1.0))], float(_met(m6, "spring_maks", -1.0)) - float(_met(m6, "spring_min", -1.0)) > 2.0)
	_cek("BANDING: S5b (koridor Asrama, flag benar) lompat kamera > S1 (terbuka): %.2f vs %.2f m" % [float(_met(m5, "lompat_kamera", -1.0)), float(_met(m1, "lompat_kamera", -1.0))], float(_met(m5, "lompat_kamera", -1.0)) > float(_met(m1, "lompat_kamera", -1.0)) * 2.0)
	_cek("BANDING: S5b frame_lompat (laju kamera > 10 m/dtk) >= 1 (ada frame kamera melonjak)" , int(_met(m5, "frame_lompat", -1.0)) >= 1)
	print("KAMERA-PINCH RINGKASAN: S1 balik=%d lompat=%.2f | S2b balik=%d lompat=%.2f | S3b balik=%d lompat=%.2f | S4 balik=%d lompat=%.2f | S5b balik=%d lompat=%.2f | S6b balik=%d lompat=%.2f (spring %.2f..%.2f)" % [int(_met(m1, "balik_spring", -1.0)), float(_met(m1, "lompat_spring", -1.0)), int(_met(m2, "balik_spring", -1.0)), float(_met(m2, "lompat_spring", -1.0)), int(_met(m3, "balik_spring", -1.0)), float(_met(m3, "lompat_spring", -1.0)), int(_met(m4, "balik_spring", -1.0)), float(_met(m4, "lompat_spring", -1.0)), int(_met(m5, "balik_spring", -1.0)), float(_met(m5, "lompat_spring", -1.0)), int(_met(m6, "balik_spring", -1.0)), float(_met(m6, "lompat_spring", -1.0)), float(_met(m6, "spring_min", -1.0)), float(_met(m6, "spring_maks", -1.0))])
	print("TES KAMERA PINCH: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0)
