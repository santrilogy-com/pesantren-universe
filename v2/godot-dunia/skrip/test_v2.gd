extends Node
## Tes v2 REVISI SURAU LURUS (Mas 17 Nov 22:51 WIB) — headless:
##   godot --headless --path . skrip/test_v2.tscn
## Cek alpha (GLB, spawn, NPC, jalan) + revisi: Surau lurus,
## pintu (0,-3.8) menghadap selatan, frame luar selatan, interior
## TETAP miring -25° (mihrab kiblat 295°), jalan N-S kembali x=0,
## matahari terbenam di barat (252°), teleport masuk + keluar
## lewat koridor pintu.
## KOREKSI 23:15 WIB: lurus = -90° (bukan 0°) — muka depan GLB di
## lokal +X (dump node). Pintu (0,-3.8), jejak 16x20 m, taji
## dihapus (tangga serambi mendarat di jalan E-W), daun pintu
## GLB baru Bima (terbuka ±110°) dicek posisinya di muka selatan.

var _main: Node
var _lulus := 0
var _gagal := 0
# Arah joystick -> dunia (diukur _probe_arah_taman, kamera-relatif).
var _t_fwd := Vector3(0, 0, -1)
var _t_right := Vector3(1, 0, 0)


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _hitung_glb(n: Node) -> int:
	var c := 0
	for ch in n.get_children():
		if String(ch.name).begins_with("GLB_"):
			c += 1
		c += _hitung_glb(ch)
	return c


func _ada_mesh(n: Node) -> bool:
	if n is MeshInstance3D:
		return true
	for ch in n.get_children():
		if _ada_mesh(ch):
			return true
	return false


## --- Helper PINTU TAMAN (Gilang) ---
func _probe_arah_taman() -> void:
	# Petakan joystick -> arah dunia (kamera-relatif): (0,-1) dan
	# (1,0) masing-masing 10 frame, ukur perpindahan pemain.
	_main._player.set_aksi("berdiri")
	var a: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 10:
		await get_tree().process_frame
	var b: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	var d := b - a
	d.y = 0.0
	if d.length() > 0.05:
		_t_fwd = d.normalized()
	a = _main._player.global_position
	_main._ui._joystick.output = Vector2(1, 0)
	for i in 10:
		await get_tree().process_frame
	b = _main._player.global_position
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	d = b - a
	d.y = 0.0
	if d.length() > 0.05:
		_t_right = d.normalized()


func _dorong_taman(arah: Vector3, frame: int) -> Vector3:
	var ja := arah.dot(_t_right)
	var jb := arah.dot(_t_fwd)
	_main._ui._joystick.output = Vector2(ja, -jb)
	for i in frame:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	return _main._player.global_position


func _taruh_taman(pos: Vector3) -> void:
	# Teleport langsung (posisi saja — TIDAK _teleport_player, supaya
	# yaw kamera hasil probe tidak berubah).
	_main._player.global_position = pos
	_main._player.velocity = Vector3.ZERO
	_main._player.set_aksi("berdiri")
	for i in 3:
		await get_tree().process_frame


func _di_dalam_taman(p: Vector3) -> bool:
	return p.x > -6.5 and p.x < 6.5 and p.z > 25.5 and p.z < 31.5


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (Dimas, 18 Nov 2026): _masuk_pesantren memanggil _mp_mulai
	# yang auto-join bila save punya ig_username — save di disk bisa
	# tertinggal akun tes MP (test_mp_putra/putri) sehingga tes ini ikut
	# terhubung ke server live dan pemain lokal diadopsi avatar server
	# (gerakan tes jadi macet, 13 gagal). Tes dunia/fisika ini harus
	# jalan OFFLINE: kosongkan ig di save sebelum masuk.
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes v2")
	for i in 3:
		await get_tree().process_frame
	# SFX (Sinta): simulasi gestur pertama — headless tidak ada
	# input, jadi audio dimulai manual supaya langkah/pintu bisa
	# diuji end-to-end (tanpa ini mainkan_* diam karena _dimulai
	# false — itu perilaku benar di web sebelum gestur).
	_main._audio.mulai()
	var root: Node = _main._pesantren["root"]
	var surau: Node = root.find_child("Surau", true, false)
	var sawah: Node = root.find_child("Sawah", true, false)
	_cek("Surau GLB ada", surau != null)
	_cek("Surau GLB bermesh", surau != null and _ada_mesh(surau))
	_cek("Sawah GLB ada", sawah != null)
	_cek("Sawah GLB bermesh", sawah != null and _ada_mesh(sawah))
	var glb := _hitung_glb(root)
	_cek("GLB_* >= 90 (dapat %d)" % glb, glb >= 90)
	_cek("SandalLuarSurau ada", root.find_child("SandalLuarSurau", true, false) != null)
	# Spawn mengikuti gender di save (putri -> spawn putri, putra ->
	# -4,14): save di disk bisa tertinggal "putri" dari run gender/
	# hijab — cek harus sadar gender, bukan mengasumsikan putra.
	var spawn_harap: Vector3 = _main._spawn_putri if String(_main._save.get("jenis_kelamin", "putra")) == "putri" else PesantrenBuilder.SPAWN
	_cek("Spawn sesuai gender save", _main._player.global_position.distance_to(spawn_harap) < 0.5)
	# --- REVISI Surau lurus (-90°: muka depan GLB di lokal +X) ---
	_cek("Pintu Surau lurus (0,-3.8)", _main._outdoor_door.distance_to(Vector3(0, 0, -3.8)) < 0.3)
	_cek("Rotasi Surau -90 (dapat %.1f)" % PesantrenBuilder.SURAU_ROTASI_DEG, absf(PesantrenBuilder.SURAU_ROTASI_DEG - (-90.0)) < 0.01)
	_cek("Frame luar keluar = selatan", _main._surau_keluar.distance_to(Vector3(0, 0, 1)) < 0.01)
	_cek("Frame luar masuk = utara", _main._surau_masuk.distance_to(Vector3(0, 0, -1)) < 0.01)
	# Daun pintu GLB baru (Bima): harus di muka SELATAN + terbuka.
	var daun_kiri: Node = surau.find_child("SR_Pintu_Kiri", true, false) if surau != null else null
	var daun_kanan: Node = surau.find_child("SR_Pintu_Kanan", true, false) if surau != null else null
	_cek("Daun pintu kiri di muka selatan", daun_kiri != null and (daun_kiri as Node3D).global_position.distance_to(Vector3(-1.97, 1.8, -3.8)) < 0.3)
	_cek("Daun pintu kanan di muka selatan", daun_kanan != null and (daun_kanan as Node3D).global_position.distance_to(Vector3(1.97, 1.8, -3.8)) < 0.3)
	_cek("Daun pintu terbuka -110/+110", daun_kiri != null and daun_kanan != null and absf(rad_to_deg((daun_kiri as Node3D).rotation.y) - (-110.0)) < 1.0 and absf(rad_to_deg((daun_kanan as Node3D).rotation.y) - 110.0) < 1.0)
	var sandal: Node = root.find_child("SandalLuarSurau", true, false)
	# TANGGA (Rangga, 17 Nov 23:xx WIB): sandal kini di ATAS lantai
	# serambi (y=0.5) — dulu y=0, terkubur di dalam lantai GLB.
	_cek("Sandal di depan pintu (-0.8,0.5,-2.3)", sandal != null and (sandal as Node3D).global_position.distance_to(Vector3(-0.8, 0.5, -2.3)) < 0.3)
	var rot_ruang := rad_to_deg(_main._interior_root.rotation.y)
	_cek("Interior tetap miring -25 (dapat %.1f)" % rot_ruang, absf(rot_ruang - (-25.0)) < 0.5)
	_cek("Frame dalam keluar 205", _main._surau_keluar_dalam.distance_to(Vector3(-0.4226, 0, 0.9063)) < 0.01)
	var jln_s: Node = root.find_child("JalanNS_Selatan", true, false)
	var jln_u: Node = root.find_child("JalanNS_Utara", true, false)
	var jln_t: Node = root.find_child("JalanNS_Surau", true, false)
	# Utara: pusat z=-112.5 (segmen 175 m: z -200..-25, ujung 1 m di
	# utara dinding belakang z=-24); taji DIHAPUS (tangga serambi
	# mendarat langsung di jalan E-W).
	_cek("Jalan N-S di x=0, utara berakhir -25, tanpa taji", jln_s != null and jln_u != null and jln_t == null and absf((jln_s as Node3D).position.x) < 0.01 and absf((jln_u as Node3D).position.x) < 0.01 and absf((jln_u as Node3D).position.z - (-112.5)) < 0.01)
	# --- Matahari terbenam di barat (252° = barat-barat daya) ---
	var mk: Array = LangitDinamis._antara(LangitDinamis.K_MATAHARI, 17.0)
	var ma: Dictionary = mk[0]
	var mb: Dictionary = mk[1]
	var fm: float = mk[2]
	var azim17: float = lerpf(float(ma["azim"]), float(mb["azim"]), fm)
	var dir17: Vector3 = LangitDinamis.arah(azim17, 3.0)
	_cek("Matahari 17:00 di barat (azim %.0f, x %.2f)" % [azim17, dir17.x], azim17 >= 225.0 and azim17 <= 270.0 and dir17.x < -0.5)
	_cek("NPC >= 5", _main._npcs.size() >= 5)
	# Jalan maju 120 frame lewat joystick (pola v1: _ui.get_joystick_vector).
	# 120 frame (bukan 30) supaya fase jalan (_walk_time += delta*9)
	# PASTI melewati nol sin sekali: kontak kaki = sin melewati nol.
	var awal: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 120:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var jalan: float = _main._player.global_position.distance_to(awal)
	_cek("Jalan maju > 1 m (dapat %.2f m)" % jalan, jalan > 1.0)
	# --- SFX LANGKAH: bunyi saat jalan, varian tanah (di luar) ---
	_cek("SFX langkah bunyi saat jalan (dapat %d)" % _main._audio.langkah_jumlah(), _main._audio.langkah_jumlah() >= 1)
	_cek("SFX langkah luar = tanah", not _main._audio.langkah_lantai_terakhir())
	# --- Teleport MASUK lewat koridor pintu lurus ---
	_main._player.global_position = _main._outdoor_door + _main._surau_masuk * 0.75
	_main._player.velocity = Vector3.ZERO
	_main._cek_pintu_surau()
	for i in 2:
		await get_tree().process_frame
	_cek("Teleport MASUK Surau (koridor lurus)", _main._di_dalam)
	# --- SFX PINTU: buka saat masuk, tutup saat keluar ---
	_cek("SFX pintu buka saat masuk Surau (dapat %d)" % _main._audio.pintu_jumlah(), _main._audio.pintu_jumlah() >= 1)
	# --- Teleport KELUAR lewat koridor pintu dalam (miring) ---
	_main._player.global_position = _main._interior_door + _main._surau_keluar_dalam * 0.75
	_main._player.velocity = Vector3.ZERO
	_main._cek_pintu_surau()
	for i in 2:
		await get_tree().process_frame
	_cek("Teleport KELUAR Surau (koridor dalam)", not _main._di_dalam and _main._player.global_position.distance_to(_main._outdoor_exit) < 0.5)
	_cek("SFX pintu tutup saat keluar Surau (dapat %d)" % _main._audio.pintu_jumlah(), _main._audio.pintu_jumlah() >= 2)
	# --- SFX API langsung: varian lantai + klik (pemicu klik di ui.gd
	# belum dipasang ronde ini — fungsinya sudah diuji di sini) ---
	var l0: int = _main._audio.langkah_jumlah()
	_main._audio.mainkan_langkah(true)
	_cek("SFX langkah lantai (API langsung)", _main._audio.langkah_jumlah() == l0 + 1 and _main._audio.langkah_lantai_terakhir())
	_main._audio.mainkan_klik()
	_cek("SFX klik (API langsung)", _main._audio.klik_jumlah() == 1)
	# --- GUBUK SANTRI BISA DIMASUKI (Dewa, 17 Nov 2026) ---
	# Pintu dibuka modul (pivot -110°), collision lantai/dinding/ramp
	# + lampu interior — lihat scripts/gubuk_masuk.gd. GubukSawah di
	# (26,0,30) rot 0°: muka + tangga menghadap -Z (utara), pintu di
	# X 26,45..27,35, ramp X 26,3..27,5. Jalur masuk: x=26,9, z 24->31.
	var gubuk: Node = root.find_child("GLB_GubukSawah", true, false)
	_cek("GubukSawah GLB ada", gubuk != null)
	_cek("GubukMasuk terpasang (Sawah)", gubuk != null and gubuk.find_child("GubukMasuk", false, false) != null)
	var gubuk_pivot: Node = gubuk.find_child("GubukMasuk_PintuPivot", true, false) if gubuk != null else null
	_cek("Pintu gubuk terbuka -110", gubuk_pivot != null and absf(rad_to_deg((gubuk_pivot as Node3D).rotation.y) - (-110.0)) < 1.0)
	var gubuk2: Node = root.find_child("GLB_GubukKebun", true, false)
	_cek("GubukKebun GLB ada + modul", gubuk2 != null and gubuk2.find_child("GubukMasuk", false, false) != null)
	# Jalan dari luar (26.9, 24) menghadap +Z (yaw 0): naik ramp 38°,
	# lewat pintu, berhenti di dinding belakang, berdiri di lantai.
	_main._teleport_player(Vector3(26.9, 0, 24), 0.0)
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 180:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var pg: Vector3 = _main._player.global_position
	_cek("Masuk gubuk: di dalam di lantai (dapat %s)" % str(pg), pg.y > 1.2 and pg.y < 1.45 and pg.z > 29.5 and pg.z < 31.3 and pg.x > 26.2 and pg.x < 27.6)
	# Anti-tembus: dorong terus ke dinding belakang — tetap di dalam.
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 60:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	pg = _main._player.global_position
	_cek("Dinding belakang menahan (dapat %s)" % str(pg), pg.z < 31.3 and pg.y > 1.2 and pg.y < 1.45)
	# Anti-tembus dinding kanan/rak: dari dalam dorong ke +X.
	_main._teleport_player(Vector3(26.9, 1.32, 30), PI * 0.5)
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 60:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	pg = _main._player.global_position
	_cek("Dinding kanan/rak menahan (dapat %s)" % str(pg), pg.x < 27.6 and pg.x > 26.9 and pg.y > 1.2 and pg.y < 1.45)
	# Anti-tembus kolong: dari barat (23.5, 30) dorong ke +X — mentok di
	# dinding kolong kiri, tidak bisa masuk bawah gubuk. Spawn 23.5
	# (bukan 24.0): 24.0 TEPAT di bidang tengah dinding kolong barat
	# (x 23.94..24.06) — kapsul overlap 0,29 m di kedua sisi, arah
	# depenetrasi flip antar run (flaky, 18 Nov 2026). 23.5 bersih
	# 0,09 m dari muka barat dinding (kapsul 23.15..23.85).
	_main._teleport_player(Vector3(23.5, 0, 30), PI * 0.5)
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 60:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	pg = _main._player.global_position
	_cek("Kolong tertutup (dapat %s)" % str(pg), pg.x > 23.0 and pg.x < 24.0 and pg.y > -0.1 and pg.y < 0.2)
	# Jalan keluar: dari dalam (26.9, 1.32, 30) mundur (-Z) sampai
	# tanah luar — turun ramp, kaki kembali di y=0.
	_main._teleport_player(Vector3(26.9, 1.32, 30), 0.0)
	_main._ui._joystick.output = Vector2(0, 1)
	for i in 240:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	pg = _main._player.global_position
	_cek("Keluar gubuk ke tanah (dapat %s)" % str(pg), pg.z < 25.5 and pg.y > -0.1 and pg.y < 0.2)
	# --- TANGGA SURAU (Rangga, 17 Nov 23:xx WIB) ---
	# GLB tidak punya collision: ramps + datar di TanggaSurau
	# (ukuran dari dump GLB); pemain jalan dari jalan E-W naik ke
	# serambi tanpa kaki tenggelam di bawah pijakan, lalu masuk
	# lewat pintu (teleport koridor lurus).
	var tangga: Node = root.find_child("TanggaSurau", true, false)
	_cek("TanggaSurau ada (7 badan: 3 rampa + 4 datar)", tangga != null and tangga.get_child_count() == 7)
	_cek("Lantai serambi y=0.5", absf(TanggaSurau.LANTAI_SERAMBI_Y - 0.5) < 0.001)
	_cek("outdoor_exit di atas serambi (0,0.5,-2.3)", _main._outdoor_exit.distance_to(Vector3(0, 0.5, -2.3)) < 0.01)
	_main._teleport_player(Vector3(0, 0, 3), PI)
	for i in 3:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2(0, -1)
	var min_clear := 999.0
	var min_clear_z := 0.0
	var z_terakhir := 3.0
	var macet := 0
	for i in 300:
		await get_tree().process_frame
		var pp: Vector3 = _main._player.global_position
		if pp.z < 1.6 and pp.z > -4.1:
			var clear := pp.y - TanggaSurau.pijakan(pp.z)
			if clear < min_clear:
				min_clear = clear
				min_clear_z = pp.z
		if absf(pp.z - z_terakhir) < 0.001 and not _main._di_dalam:
			macet += 1
		else:
			macet = 0
		z_terakhir = pp.z
		if _main._di_dalam or macet > 45:
			break
	_main._ui._joystick.output = Vector2.ZERO
	_cek("Naik tangga tanpa macet (macet=%d)" % macet, macet <= 45)
	_cek("Kaki tak tenggelam (clear min %.3f di z=%.2f)" % [min_clear, min_clear_z], min_clear >= -0.03)
	_cek("Sampai serambi + masuk pintu (di_dalam)", _main._di_dalam)
	# --- PINTU PAGAR TAMAN (Gilang, 17 Nov 2026) ---
	# Baseline probe (sebelum perbaikan): 0 StaticBody3D di bawah 10
	# GLB pagar + 14/14 titik dorong TEMBUS (yang "tertahan" di utara
	# tengah pun sebenarnya mentok peti, bukan pagar). Kini: segmen
	# tengah utara dilepas (9 segmen) diganti pintu geser bambu +
	# collision keliling — lihat scripts/pintu_taman.gd.
	# Keluar Surau dulu (tes tangga meninggalkan pemain di dalam).
	_main._keluar_surau()
	for i in 3:
		await get_tree().process_frame
	_taruh_taman(Vector3(0, 0, 20))
	await _probe_arah_taman()
	var pagar: Node = root.find_child("PagarTaman", true, false)
	_cek("PagarTaman ada", pagar != null)
	var pintu_taman: Node = root.find_child("PintuTaman", true, false)
	_cek("PintuTaman ada", pintu_taman != null)
	var n_bambu := 0
	var ada_tengah_utara := false
	for i in 10:
		var g: Node = root.find_child("GLB_PagarBambu_%d" % i, true, false)
		if g != null:
			n_bambu += 1
			if (g as Node3D).position.distance_to(Vector3(0, 0, 25.5)) < 0.1:
				ada_tengah_utara = true
	_cek("Segmen pagar bambu 9 (dapat %d)" % n_bambu, n_bambu == 9)
	_cek("Segmen tengah utara dilepas", not ada_tengah_utara)
	_cek("Pintu tertutup saat start", pintu_taman != null and pintu_taman.apakah_tertutup())
	# Pintu DIKUNCI tertutup selama tes dorong (supaya NPC yang lewat
	# tidak membuka pintu di tengah tes).
	if pintu_taman != null:
		pintu_taman.set_tahan_tertutup(true)
	# Dorong dari 4 sisi luar + sudut + dari dalam (pintu tertutup).
	_taruh_taman(Vector3(0, 0, 23.5))
	var p1: Vector3 = await _dorong_taman(Vector3(0, 0, 1), 45)
	_cek("Pintu tertutup menahan dari utara (dapat %s)" % str(p1), p1.z > 24.0 and p1.z < 25.25 and not _di_dalam_taman(p1))
	_taruh_taman(Vector3(-4, 0, 23.5))
	var p2: Vector3 = await _dorong_taman(Vector3(0, 0, 1), 45)
	_cek("Pagar utara-barat menahan (dapat %s)" % str(p2), p2.z > 24.0 and p2.z < 25.25 and not _di_dalam_taman(p2))
	_taruh_taman(Vector3(0, 0, 33.5))
	var p3: Vector3 = await _dorong_taman(Vector3(0, 0, -1), 45)
	_cek("Pagar selatan menahan (dapat %s)" % str(p3), p3.z > 31.8 and p3.z < 33.0 and not _di_dalam_taman(p3))
	_taruh_taman(Vector3(-8.5, 0, 28))
	var p4: Vector3 = await _dorong_taman(Vector3(1, 0, 0), 45)
	_cek("Pagar barat menahan (dapat %s)" % str(p4), p4.x > -8.0 and p4.x < -6.8 and not _di_dalam_taman(p4))
	_taruh_taman(Vector3(8.5, 0, 28))
	var p5: Vector3 = await _dorong_taman(Vector3(-1, 0, 0), 45)
	_cek("Pagar timur menahan (dapat %s)" % str(p5), p5.x > 6.8 and p5.x < 8.0 and not _di_dalam_taman(p5))
	_taruh_taman(Vector3(-8.5, 0, 23.5))
	var p6: Vector3 = await _dorong_taman(Vector3(1, 0, 1).normalized(), 45)
	_cek("Sudut barat-laut menahan (dapat %s)" % str(p6), not _di_dalam_taman(p6) and (p6.x > -7.5 or p6.z > 24.5))
	_taruh_taman(Vector3(0, 0, 27))
	var p7: Vector3 = await _dorong_taman(Vector3(0, 0, -1), 45)
	_cek("Pintu tertutup menahan dari dalam (dapat %s)" % str(p7), p7.z > 25.7 and p7.z < 27.0)
	# Buka kunci — pintu harus membuka OTOMATIS saat pemain mendekat.
	# NPC diabaikan selama sisa tes pintu (set_abaikan_npc) supaya
	# buka/tutup-otomatis deterministik — hanya pemain yang memicu
	# (18 Nov 2026: NPC lewat waypoint (0,30) menahan pintu terbuka).
	if pintu_taman != null:
		pintu_taman.set_tahan_tertutup(false)
		pintu_taman.set_abaikan_npc(true)
	_taruh_taman(Vector3(0, 0, 23.2))
	var terbuka := false
	for i in 240:
		await get_tree().process_frame
		if pintu_taman != null and pintu_taman.apakah_terbuka():
			terbuka = true
			break
	_cek("Pintu buka otomatis saat pemain mendekat", terbuka)
	var daun: Node = root.find_child("PintuTaman_Daun", true, false)
	_cek("Daun geser ke timur (dapat %s)" % str((daun as Node3D).global_position if daun != null else Vector3.ZERO), daun != null and (daun as Node3D).global_position.distance_to(Vector3(2.1, 0, 25.72)) < 0.2)
	# Jalan masuk lewat pintu yang terbuka — berhenti di depan peti
	# (0,28) (18 Nov 2026: peti pindah (0,26)->(0,28) — muka utara
	# z 27,625, kapsul r=0,35 berhenti z ~27,28; 120 frame karena
	# pemain sempat menunggu daun geser terbuka dulu).
	var p8: Vector3 = await _dorong_taman(Vector3(0, 0, 1), 120)
	_cek("Masuk lewat pintu, berhenti di depan peti (dapat %s)" % str(p8), p8.z > 26.5 and p8.z < 27.6 and absf(p8.x) < 0.5)
	# Pintu menutup otomatis setelah pemain menjauh (NPC sudah
	# diabaikan — lihat atas; poll 600 frame = ~10 dtk).
	_taruh_taman(Vector3(0, 0, 14))
	var tertutup := false
	for i in 600:
		await get_tree().process_frame
		if pintu_taman != null and pintu_taman.apakah_tertutup():
			tertutup = true
			break
	_cek("Pintu menutup otomatis saat pemain menjauh", tertutup)
	print("TES V2: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
