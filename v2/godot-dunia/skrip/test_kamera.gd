extends Node
## Tes kamera v2 — PERBAIKAN BUG MABUK (Cakra, 18 Nov 2026, 00:16).
## Laporan Mas dari HP (alpha ecd7e2e9): "saat jalan kamera goyang
## seperti gempa; saat diam kamera bergerak sendiri sampai bikin
## pusing". Akar: sway napas diam ±0,20° terus-menerus + sway jalan
## 3 sumbu ±0,40° @ ~2,3 Hz + FOV berdenyut 60<->66 (v1 kamera.gd).
## Perbaikan: goyang + dinamika framing DIMATIKAN TOTAL.
##   godot --headless --path . skrip/test_kamera.tscn
## MENGUKUR (bukan "terlihat"):
## 1. DIAM TOTAL saat idle: varians posisi + rotasi kamera = 0
##    (tepat, bukan "kecil") selama 120 frame setelah menetap.
## 2. JALAN TANPA GOYANG: rotasi kamera = 0 di semua frame jalan;
##    FOV tetap 68 saat jalan; laju perubahan panjang spring
##    terbatas (memendek <= 26 m/dtk, memanjang <= 4,5 m/dtk —
##    penghalusan asimetris; tanpa ini spring melonjak = getar).
## 3. Jalan maju >= 1,20 m + rig menempel target.
## 4. Anti-tembus TETAP: garis pandang bersih saat pemain didorong
##    ke tembok dari 3 arah + kamera tidak di dalam benda padat.
## 5. Penghalusan spring asimetris (bukti nyata, bukan vacuous).
## 6. MODE KAMERA v3 (18 Nov 13:13): tiap mode mengubah target
##    spring/pitch/FOV; transisi tidak lompat (laju FOV/pitch/
##    spring terbatas); diam tetap total diam di tiap mode;
##    aturan Asrama menang di tiap mode (spring 5,5 / pitch
##    -0,22 / FOV 65); pinch zoom mengubah spring (bukan FOV)
##    dengan jepit 0,55..1,30; keyboard C + tombol UI mengganti mode.
## NILAI KUNCI v3 (Normal lebih luas, koreksi Mas 13:13): FOV luar
## 68 (dulu 60), spring luar 8,0 m (dulu 7,0). Asrama tetap
## 65 / 5,5 m (kontrak koridor Lestari — JANGAN diubah).

var _main: Node
var _lulus := 0
var _gagal := 0
## Toleransi rotasi kamera (bukan posisi): 6e-8 rad noise float32
## terukur di mode Drone (probe) — rotasi yang dibaca dari basis
## float32 tidak pernah persis 0,0 saat spring miring; 1e-6 rad =
## 0,00006 derajat, di bawah ambang gerak apa pun. POSISI tetap
## == 0,0 persis (tidak dilonggarkan).
const ROT_EPS := 0.000001


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Tunggu WAKTU (bukan jumlah frame): headless ~150 fps, jadi
## "90 frame" cuma ~0,6 dtk — terlalu pendek untuk settling fisika
## pemain (~1 dtk) maupun transisi mode 3,5/dtk (~2 dtk).
func _tunggu_waktu(detik: float) -> void:
	var t := 0.0
	while t < detik:
		await get_tree().process_frame
		t += get_process_delta_time()


## Tunggu transisi mode benar-benar selesai: FOV/pitch/spring/rig
## dekat target (maks 4 dtk). Hitungan frame saja tidak cukup —
## lihat _tunggu_waktu. Ambang DISESUAIKAN dengan SNAP modul
## (pitch/FOV snap < 0,005, spring < 0,01, rig < 0,005) supaya
## saat fungsi kembali, kamera benar-benar BERHENTI — ambang
## longgar membuat ukur DIAM masih menangkap ekor transisi.
func _tunggu_mode_siap(fov_target: float, pitch_target: float, spring_target: float, tinggi_target: float) -> void:
	var t := 0.0
	while t < 4.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		var rig_target: Vector3 = _main._player.global_position + Vector3(0, tinggi_target, 0)
		if absf(_main._cam.fov - fov_target) < 0.01 and absf(_main._spring.rotation.x - pitch_target) < 0.006 and absf(_main._spring.spring_length - spring_target) < 0.02 and _main._rig.global_position.distance_to(rig_target) < 0.005:
			# Rotasi spring (lerp 12/dtk, tanpa snap) butuh ekor
			# tambahan setelah pitch efektif snap: ekor 0,5 dtk
			# masih menyisakan gerak ~4e-6 m (gagal DIAM LOW);
			# 1,0 dtk mendorongnya ke bawah noise float32.
			await _tunggu_waktu(1.0)
			return


func _garis_pandang_bersih() -> bool:
	var dari: Vector3 = _main._cam.global_position
	var ke: Vector3 = _main._player.global_position + Vector3(0, 1.2, 0)
	var q := PhysicsRayQueryParameters3D.create(dari, ke)
	q.collision_mask = 0xFFFFFFFF
	q.exclude = [_main._player.get_rid()]
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(q)
	return hit.is_empty()


var _diag_tabrakan := ""


func _kamera_tidak_di_dalam_benda() -> bool:
	var bola := SphereShape3D.new()
	bola.radius = 0.3
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = bola
	q.transform = Transform3D(Basis(), _main._cam.global_position)
	q.collision_mask = 0xFFFFFFFF
	q.exclude = [_main._player.get_rid()]
	var tabrakan := get_viewport().get_world_3d().direct_space_state.intersect_shape(q, 5)
	# Diagnosa: bila gagal, catat APA yang disentuh bola probe +
	# posisi kamera — tanpa ini kegagalan "benda padat" tidak bisa
	# dibedakan antara tanah / tembok / NPC yang lewat.
	_diag_tabrakan = ""
	if not tabrakan.is_empty():
		var nama: Array[String] = []
		for t in tabrakan:
			var col = t.get("collider")
			nama.append((col as Node).name if col is Node else str(col))
		_diag_tabrakan = "cam=%s menabrak: %s" % [str(_main._cam.global_position), ", ".join(nama)]
	return tabrakan.is_empty()


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (pola test_v2.gd, Dimas): _masuk_pesantren memanggil
	# _mp_mulai yang auto-join bila save punya ig_username — save di
	# disk bisa tertinggal akun tes MP (test_mp_putra/putri) sehingga
	# tes ini ikut terhubung ke server live dan pemain lokal diadopsi
	# avatar server (gerakan tes macet, teleport ditarik balik).
	# Tes kamera harus jalan OFFLINE: kosongkan ig di save sebelum
	# masuk (tulis juga ke disk seperti test_v2).
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	# PAKSA putra SEBELUM masuk (bukan sesudah): spawn mengikuti
	# gender save — kalau santri.json tertinggal "putri" dari tes
	# agen paralel, pemain ter-spawn di kampus putri (130,14) dan
	# semua skenario tembok putra jadi tidak valid.
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Tes kamera")
	# HUD v3 (Tara, 18 Nov): pop-up "PETUNJUK TOMBOL" muncul saat
	# pertama main (flag false) dan dim full-screen-nya (MOUSE_FILTER_
	# STOP) menelan sentuhan layar — pinch di _unhandled_input tidak
	# sampai selama pop-up terbuka. Itu benar untuk pemain sungguhan
	# (pop-up modal, harus ditutup dulu), jadi tes ini menutupnya
	# lewat tombol "Mengerti" yang sama sebelum menguji input dunia.
	if _main._ui.is_petunjuk_visible():
		_main._ui._petunjuk_mengerti_btn.pressed.emit()
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	var cam: Camera3D = _main._cam
	_cek("Modul KameraPesantren terpasang", _main._kamera != null)
	# --- 1. DIAM TOTAL: menetap (WAKTU 2,5 dtk — kapsul pemain
	# butuh ~1 dtk untuk settling fisika; 90 frame di headless
	# 150 fps cuma 0,6 dtk, terlalu pendek), lalu ukur 120 frame ---
	await _tunggu_waktu(2.5)
	var pos0: Vector3 = cam.global_position
	var maks_pos_diam := 0.0
	var maks_rot_diam := 0.0
	var maks_fov_diam := 0.0
	for i in 120:
		await get_tree().process_frame
		maks_pos_diam = maxf(maks_pos_diam, cam.global_position.distance_to(pos0))
		var r := cam.rotation
		maks_rot_diam = maxf(maks_rot_diam, maxf(absf(r.x), maxf(absf(r.y), absf(r.z))))
		maks_fov_diam = maxf(maks_fov_diam, absf(cam.fov - 68.0))
	_cek("DIAM: posisi kamera tidak bergerak sama sekali (maks %.6f m)" % maks_pos_diam, maks_pos_diam == 0.0)
	_cek("DIAM: rotasi kamera = 0 (maks %.9f rad)" % maks_rot_diam, maks_rot_diam < ROT_EPS)
	_cek("DIAM: FOV tetap 68 (maks selisih %.2f)" % maks_fov_diam, maks_fov_diam == 0.0)
	# --- 2. JALAN TANPA GOYANG: 120 frame joystick penuh ---
	var awal: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	var maks_rot_jalan := 0.0
	var maks_fov_jalan := 0.0
	var laju_pendek := 0.0
	var laju_panjang := 0.0
	var spring_lalu: float = _main._spring.spring_length
	var rot_lalu := cam.rotation
	var maks_lompat_rot := 0.0
	for i in 120:
		await get_tree().process_frame
		var r := cam.rotation
		maks_rot_jalan = maxf(maks_rot_jalan, maxf(absf(r.x), maxf(absf(r.y), absf(r.z))))
		maks_fov_jalan = maxf(maks_fov_jalan, absf(cam.fov - 68.0))
		maks_lompat_rot = maxf(maks_lompat_rot, (r - rot_lalu).length())
		rot_lalu = r
		var d := get_process_delta_time()
		if d > 0.0001:
			var laju: float = (_main._spring.spring_length - spring_lalu) / d
			if laju < 0.0:
				laju_pendek = maxf(laju_pendek, -laju)
			else:
				laju_panjang = maxf(laju_panjang, laju)
		spring_lalu = _main._spring.spring_length
	_main._ui._joystick.output = Vector2.ZERO
	var jalan: float = _main._player.global_position.distance_to(awal)
	_cek("Jalan maju >= 1,20 m (dapat %.2f m)" % jalan, jalan >= 1.20)
	_cek("JALAN: rotasi kamera = 0 di semua frame (maks %.9f rad)" % maks_rot_jalan, maks_rot_jalan < ROT_EPS)
	_cek("JALAN: tanpa lompatan rotasi antar frame (maks %.9f)" % maks_lompat_rot, maks_lompat_rot < ROT_EPS)
	_cek("JALAN: FOV tetap 68 (maks selisih %.2f)" % maks_fov_jalan, maks_fov_jalan == 0.0)
	_cek("JALAN: spring memendek <= 26 m/dtk (dapat %.1f)" % laju_pendek, laju_pendek <= 26.0)
	_cek("JALAN: spring memanjang <= 4,5 m/dtk (dapat %.1f)" % laju_panjang, laju_panjang <= 4.5)
	# --- 3. Rig menempel target setelah berhenti ---
	for i in 60:
		await get_tree().process_frame
	var target: Vector3 = _main._player.global_position + Vector3(0, 1.6, 0)
	var jarak_rig: float = _main._rig.global_position.distance_to(target)
	_cek("Rig menempel target < 1,5 m (dapat %.2f)" % jarak_rig, jarak_rig < 1.5)
	# --- 4. Anti-tembus: dorong pemain ke tembok dari 3 arah ---
	_main._teleport_player(Vector3(-4, 0, 6), PI)
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 90:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 30:
		await get_tree().process_frame
	_cek("Dorong ke tembok selatan Surau: garis pandang bersih", _garis_pandang_bersih())
	_main._teleport_player(Vector3(0, 0, -2), 0.0)
	for i in 90:
		await get_tree().process_frame
	_cek("Kamera dekat dinding: pemain betah di (0,0,-2) (dapat %s)" % str(_main._player.global_position), _main._player.global_position.distance_to(Vector3(0, 0, -2)) < 0.5)
	_cek("Kamera dekat dinding: garis pandang bersih", _garis_pandang_bersih())
	_cek("Kamera dekat dinding: tidak di dalam benda padat", _kamera_tidak_di_dalam_benda())
	_cek("Kamera dekat dinding: spring <= 8,6 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length <= 8.6)
	_main._teleport_player(Vector3(-12, 0, -14), PI * 0.5)
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 90:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 30:
		await get_tree().process_frame
	_cek("Dorong ke tembok barat Surau: garis pandang bersih", _garis_pandang_bersih())
	# --- 5. Penghalusan spring asimetris (bukti nyata, bukan vacuous):
	#     pemain di (12,0,14) menghadap barat — kamera di timur,
	#     di balik tembok x=14: penjaga HARUS memendekkan spring.
	#     Memendek harus CEPAT (< 3,0 m dalam 0,25 dtk), memanjang
	#     kembali harus PELAN (masih < 5,5 m dalam 0,25 dtk).
	_main._teleport_player(Vector3(12, 0, 14), -PI * 0.5)
	var t := 0.0
	var n := 0
	var spring_025 := -1.0
	var spring_akhir := 0.0
	while t < 1.0 and n < 2000:
		await get_tree().process_frame
		var d := get_process_delta_time()
		t += d
		n += 1
		if spring_025 < 0.0 and t >= 0.25:
			spring_025 = _main._spring.spring_length
		spring_akhir = _main._spring.spring_length
	_cek("Spring memendek CEPAT di balik tembok (< 3,0 m dlm 0,25 dtk; dapat %.2f)" % spring_025, spring_025 > 0.0 and spring_025 < 3.0)
	_cek("Spring menetap pendek (< 6,5 m; dapat %.2f)" % spring_akhir, spring_akhir < 6.5)
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	# Prediksi eksponensial (bukan batas mutlak 6,0 m): tangkap
	# spring pada frame PERTAMA t>=0,25 — di bawah beban VM satu
	# frame bisa 0,1-0,3 dtk sehingga t aktual saat tangkap bisa
	# 0,35 dtk dan batas 6,0 m terlampaui padahal laju benar
	# (4/dtk). Yang diuji: nilai tangkap COCOK dengan prediksi
	# 8-(8-S0)*exp(-4*t_cap) (toleransi 0,6 m) DAN masih < 7,5 m
	# (dengan laju CEPAT 25/dtk spring sudah ~8,0 m di 0,25 dtk).
	var s0_buka: float = _main._spring.spring_length
	t = 0.0
	n = 0
	var spring_buka_025 := -1.0
	var t_cap_buka := 0.0
	var spring_buka_150 := 0.0
	while t < 1.5 and n < 3000:
		await get_tree().process_frame
		var d := get_process_delta_time()
		t += d
		n += 1
		if spring_buka_025 < 0.0 and t >= 0.25:
			spring_buka_025 = _main._spring.spring_length
			t_cap_buka = t
		spring_buka_150 = _main._spring.spring_length
	var prediksi_buka: float = 8.0 - (8.0 - s0_buka) * exp(-4.0 * t_cap_buka)
	_cek("Spring memanjang PELAN (prediksi %.2f m di t=%.2f dtk; dapat %.2f)" % [prediksi_buka, t_cap_buka, spring_buka_025], spring_buka_025 > 0.0 and absf(spring_buka_025 - prediksi_buka) <= 0.6 and spring_buka_025 < 7.5)
	_cek("Spring kembali ~8,0 m setelah 1,5 dtk (dapat %.2f)" % spring_buka_150, spring_buka_150 > 7.5 and spring_buka_150 <= 8.05)
	# --- 6. MODE KAMERA v3 (Cakra, 18 Nov 13:13) ---
	# 6f. INPUT dulu (mode masih NORMAL dari bagian 1-5): keyboard C
	# + tombol UI mengganti mode; pinch dua jari mengubah zoom.
	var k = _main._kamera
	_cek("Mode awal NORMAL", k.mode() == 0 and k.nama_mode() == "Normal")
	# B rev1: tombol kamera kini di STRIP ATAS (dulu □).
	_main._ui._kamera_ikon_btn.emit_signal("pressed")
	for i in 5:
		await get_tree().process_frame
	_cek("Tombol UI Kamera: NORMAL -> DRONE (label '%s')" % _main._ui._kamera_ikon_btn.text, k.mode() == 1 and _main._ui._kamera_ikon_btn.text == "Kamera: Drone")
	var ev_c := InputEventKey.new()
	ev_c.keycode = KEY_C
	ev_c.pressed = true
	ev_c.echo = false
	Input.parse_input_event(ev_c)
	for i in 5:
		await get_tree().process_frame
	_cek("Keyboard C: DRONE -> LOW ANGLE", k.mode() == 2 and _main._ui._kamera_ikon_btn.text == "Kamera: Low Angle")
	# Pinch: dua jari di (400,300)+(600,300) lalu direnggangkan ke
	# (350,300)+(650,300) — jarak 200 -> 300 = zoom in. Drag PERTAMA
	# setelah jari kedua menyentuh hanya menetapkan baseline (tidak
	# mengubah zoom); perubahan dihitung dari drag BERIKUTNYA.
	# Urutan di sini: d0 (jarak 200->250, baseline) lalu d1
	# (250->300, rasio 250/300 = 0,833) — zoom target 0,833.
	var s0 := InputEventScreenTouch.new()
	s0.index = 0
	s0.position = Vector2(400, 300)
	s0.pressed = true
	Input.parse_input_event(s0)
	var s1 := InputEventScreenTouch.new()
	s1.index = 1
	s1.position = Vector2(600, 300)
	s1.pressed = true
	Input.parse_input_event(s1)
	var d0 := InputEventScreenDrag.new()
	d0.index = 0
	d0.position = Vector2(350, 300)
	d0.relative = Vector2(-50, 0)
	Input.parse_input_event(d0)
	var d1 := InputEventScreenDrag.new()
	d1.index = 1
	d1.position = Vector2(650, 300)
	d1.relative = Vector2(50, 0)
	Input.parse_input_event(d1)
	for i in 5:
		await get_tree().process_frame
	_cek("Pinch renggang: zoom target ~0,833 (dapat %.3f)" % k.zoom_target(), absf(k.zoom_target() - 0.8333) < 0.02)
	# Akumulasi: renggangkan lagi (jari 0 ke 300,300 -> jarak 350,
	# rasio 300/350) — zoom 0,833 x 0,857 = 0,714.
	var d2 := InputEventScreenDrag.new()
	d2.index = 0
	d2.position = Vector2(300, 300)
	d2.relative = Vector2(-50, 0)
	Input.parse_input_event(d2)
	for i in 5:
		await get_tree().process_frame
	_cek("Pinch akumulatif: zoom target ~0,714 (dapat %.3f)" % k.zoom_target(), absf(k.zoom_target() - 0.7143) < 0.02)
	var r0 := InputEventScreenTouch.new()
	r0.index = 0
	r0.position = Vector2(350, 300)
	r0.pressed = false
	Input.parse_input_event(r0)
	var r1 := InputEventScreenTouch.new()
	r1.index = 1
	r1.position = Vector2(650, 300)
	r1.pressed = false
	Input.parse_input_event(r1)
	k.geser_zoom(1.0 / k.zoom_target())
	for i in 5:
		await get_tree().process_frame
	_cek("Zoom kembali ke 1,0 setelah pinch selesai", absf(k.zoom_target() - 1.0) < 0.01)
	# 6a. Target tiap mode (cek parameter_target — tanpa menunggu
	# transisi; zoom 1,0; luar ruangan; tidak tidur).
	# Tunggu dulu zoom HALUS kembali ke 1,0 (parameter_target
	# memakai zoom halus — kalau masih melayang, target ikut
	# melayang dan cek di bawah gagal palsu).
	var tw := 0.0
	while tw < 2.0 and absf(k.zoom_halus() - 1.0) > 0.001:
		await get_tree().process_frame
		tw += get_process_delta_time()
	k.atur_mode(1)
	var t_drone: Dictionary = k.parameter_target(false, false, -0.35)
	_cek("DRONE target: spring 10,0 / pitch -1,05 / FOV 60 (dapat s=%.2f p=%.2f f=%.1f zoom_halus=%.3f)" % [float(t_drone["spring"]), float(t_drone["pitch"]), float(t_drone["fov"]), k.zoom_halus()], absf(float(t_drone["spring"]) - 10.0) < 0.01 and absf(float(t_drone["pitch"]) + 1.05) < 0.01 and absf(float(t_drone["fov"]) - 60.0) < 0.01)
	k.atur_mode(2)
	var t_low: Dictionary = k.parameter_target(false, false, -0.35)
	_cek("LOW target: spring 4,0 / pitch +0,15 / FOV 65 (dapat s=%.2f p=%.2f f=%.1f)" % [float(t_low["spring"]), float(t_low["pitch"]), float(t_low["fov"])], absf(float(t_low["spring"]) - 4.0) < 0.01 and absf(float(t_low["pitch"]) - 0.15) < 0.01 and absf(float(t_low["fov"]) - 65.0) < 0.01)
	k.atur_mode(3)
	var t_high: Dictionary = k.parameter_target(false, false, -0.35)
	_cek("HIGH target: spring 6,0 / pitch -0,85 / FOV 60 (dapat s=%.2f p=%.2f f=%.1f)" % [float(t_high["spring"]), float(t_high["pitch"]), float(t_high["fov"])], absf(float(t_high["spring"]) - 6.0) < 0.01 and absf(float(t_high["pitch"]) + 0.85) < 0.01 and absf(float(t_high["fov"]) - 60.0) < 0.01)
	k.atur_mode(4)
	var t_sine: Dictionary = k.parameter_target(false, false, -0.35)
	_cek("SINEMATIK target: spring 8,0 / pitch -0,35 / FOV 68 (dapat s=%.2f p=%.2f f=%.1f)" % [float(t_sine["spring"]), float(t_sine["pitch"]), float(t_sine["fov"])], absf(float(t_sine["spring"]) - 8.0) < 0.01 and absf(float(t_sine["pitch"]) + 0.35) < 0.01 and absf(float(t_sine["fov"]) - 68.0) < 0.01)
	k.atur_mode(0)
	var t_norm: Dictionary = k.parameter_target(false, false, -0.35)
	_cek("NORMAL target: spring 8,0 / pitch ikut drag / FOV 68 (dapat s=%.2f p=%.2f f=%.1f)" % [float(t_norm["spring"]), float(t_norm["pitch"]), float(t_norm["fov"])], absf(float(t_norm["spring"]) - 8.0) < 0.01 and absf(float(t_norm["pitch"]) + 0.35) < 0.01 and absf(float(t_norm["fov"]) - 68.0) < 0.01)
	# Jepit ruangan non-Asrama (RONDE 7): Drone di Surau -> spring
	# 4,0 + pitch -0,35 (kamera tetap di bawah plafon 3,6 m).
	k.atur_mode(1)
	var t_ruang: Dictionary = k.parameter_target(false, false, -0.35, true)
	_cek("DRONE di ruangan: spring dijepit 4,0 / pitch -0,35", absf(float(t_ruang["spring"]) - 4.0) < 0.01 and absf(float(t_ruang["pitch"]) + 0.35) < 0.01)
	# Jepit Asrama di level MODUL (kontrak MENANG atas mode): Drone
	# di Asrama -> spring 5,5 + pitch -0,22 + FOV 65. Ini TARGET
	# modul — di dunia nyata penjaga anti-tembus bisa memendekkan
	# LEBIH JAUH (koridor Asrama 2,6 m: spring 1,2 m bila pemain
	# menghadap melintang; lihat 6d + foto M6).
	k.atur_mode(1)
	var t_asr: Dictionary = k.parameter_target(true, false, -0.35)
	_cek("DRONE di Asrama: spring dijepit 5,5 / pitch -0,22 / FOV 65 (dapat s=%.2f p=%.2f f=%.1f)" % [float(t_asr["spring"]), float(t_asr["pitch"]), float(t_asr["fov"])], absf(float(t_asr["spring"]) - 5.5) < 0.01 and absf(float(t_asr["pitch"]) + 0.22) < 0.01 and absf(float(t_asr["fov"]) - 65.0) < 0.01)
	k.atur_mode(0)
	# 6b. TRANSISI TIDAK LOMPAT: ganti ke DRONE. FOV/pitch diukur
	# lajunya (<= 30 derajat/dtk, <= 4 rad/dtk) — TAPI per jendela
	# 10 frame dengan jam MIKRODETIK, bukan per frame dengan
	# get_process_delta_time(): di bawah beban VM, delta yang
	# dibaca SETELAH await adalah delta frame BERIKUTNYA, bukan
	# frame tempat gerak terjadi — satu frame cepat (1 ms) yang
	# dipasangkan dengan gerak frame lambat sebelumnya menggelem-
	# bungkan laju sampai 374 dtk/dtk (artefak ukur, bukan bug
	# kamera). Jendela 10 frame meratakan jitter itu; lompatan
	# sejati (8 dtk dalam 1 frame) tetap tertangkap karena
	# lajunya 8/0,067 = 119 dtk/dtk >> 30. SPRING tidak diukur
	# lajunya (lihat alasan di bawah) — yang dibuktikan: (a) tidak
	# ada LOMPATAN per frame (<= 1,0 m), (b) tidak ada OVERSHOOT
	# (<= 10,05 m), (c) nilai akhir sampai. Penghalusan
	# asimetrisnya sendiri sudah dibuktikan Bagian 5 (prediksi
	# eksponensial memanjang PELAN + memendek CEPAT).
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	for i in 30:
		await get_tree().process_frame
	k.atur_mode(1)
	var maks_laju_fov := 0.0
	var maks_laju_pitch := 0.0
	var maks_lompat_spring := 0.0
	var spring_maks := 0.0
	var fov_jendela_awal: float = cam.fov
	var pitch_jendela_awal: float = _main._spring.rotation.x
	var usec_jendela_awal := Time.get_ticks_usec()
	var hitung_jendela := 0
	var spring_lalu2: float = _main._spring.spring_length
	var tt := 0.0
	var nn := 0
	while tt < 2.5 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
		hitung_jendela += 1
		maks_lompat_spring = maxf(maks_lompat_spring, absf(_main._spring.spring_length - spring_lalu2))
		spring_maks = maxf(spring_maks, _main._spring.spring_length)
		spring_lalu2 = _main._spring.spring_length
		if hitung_jendela >= 10:
			var dt_jendela: float = float(Time.get_ticks_usec() - usec_jendela_awal) / 1000000.0
			if dt_jendela > 0.001:
				maks_laju_fov = maxf(maks_laju_fov, absf(cam.fov - fov_jendela_awal) / dt_jendela)
				maks_laju_pitch = maxf(maks_laju_pitch, absf(_main._spring.rotation.x - pitch_jendela_awal) / dt_jendela)
			fov_jendela_awal = cam.fov
			pitch_jendela_awal = _main._spring.rotation.x
			usec_jendela_awal = Time.get_ticks_usec()
			hitung_jendela = 0
	# Jendela parsial di akhir loop (bila frame sangat lambat dan
	# 10 frame tidak terkumpul, laju tidak boleh lolos hampa).
	if hitung_jendela > 0:
		var dt_sisa: float = float(Time.get_ticks_usec() - usec_jendela_awal) / 1000000.0
		if dt_sisa > 0.001:
			maks_laju_fov = maxf(maks_laju_fov, absf(cam.fov - fov_jendela_awal) / dt_sisa)
			maks_laju_pitch = maxf(maks_laju_pitch, absf(_main._spring.rotation.x - pitch_jendela_awal) / dt_sisa)
	_cek("Transisi DRONE: laju FOV <= 30 dtk/dtk (dapat %.1f)" % maks_laju_fov, maks_laju_fov <= 30.0)
	_cek("Transisi DRONE: laju pitch <= 4 rad/dtk (dapat %.2f)" % maks_laju_pitch, maks_laju_pitch <= 4.0)
	_cek("Transisi DRONE: tanpa lompatan spring per frame (maks %.2f m)" % maks_lompat_spring, maks_lompat_spring <= 1.0)
	_cek("Transisi DRONE: spring tidak overshoot target (maks %.2f m)" % spring_maks, spring_maks <= 10.05)
	_cek("DRONE sampai: FOV ~60 (dapat %.1f)" % cam.fov, absf(cam.fov - 60.0) <= 0.5)
	_cek("DRONE sampai: pitch ~-1,05 (dapat %.2f)" % _main._spring.rotation.x, absf(_main._spring.rotation.x + 1.05) <= 0.05)
	_cek("DRONE sampai: spring tumbuh > 8,5 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length > 8.5)
	_cek("DRONE: garis pandang bersih", _garis_pandang_bersih())
	_cek("DRONE: kamera tidak di dalam benda padat", _kamera_tidak_di_dalam_benda())
	# Nama di Drone (keputusan Mas 13:19 — nama tampil SELALU dan di
	# Drone harus TERBACA JELAS): label pemain tetap tampil, skala
	# di-boost 2,5x, tinggi tampak >= 5% tinggi layar (tanpa boost
	# hanya ~2,6% — tidak terbaca dari ketinggian 10 m).
	# Tinggi label dihitung dari METRIK FONT (bukan get_aabb():
	# get_aabb Label3D mengembalikan kubus bersisi = lebar teks).
	var label_nama: Label3D = _main._player._name_label
	_cek("DRONE: label nama pemain tampil", label_nama.visible)
	var tinggi_font: float = float(label_nama.font.get_height(label_nama.font_size)) * label_nama.pixel_size
	var tinggi_label: float = tinggi_font * label_nama.scale.x
	var jarak_label: float = cam.global_position.distance_to(label_nama.global_position)
	var fraksi_label: float = tinggi_label / (2.0 * jarak_label * tan(deg_to_rad(cam.fov * 0.5)))
	_cek("DRONE: tinggi font label 0,43 m (dapat %.2f)" % tinggi_font, absf(tinggi_font - 0.43) < 0.02)
	_cek("DRONE: label nama di-boost (skala %.2f)" % label_nama.scale.x, label_nama.scale.x >= 2.0)
	_cek("DRONE: label nama >= 5%% tinggi layar (dapat %.1f%%)" % (fraksi_label * 100.0), fraksi_label >= 0.05)
	# 6c. DIAM TOTAL di mode DRONE + LOW (posisi 0 persis, rotasi < 1e-6).
	# Settle pakai _tunggu_mode_siap (konvergensi, bukan hitungan
	# frame — lihat _tunggu_waktu).
	await _tunggu_mode_siap(60.0, -1.05, 10.0, 1.6)
	var pos_drone: Vector3 = cam.global_position
	var maks_diam_drone := 0.0
	var maks_rot_drone := 0.0
	for i in 60:
		await get_tree().process_frame
		maks_diam_drone = maxf(maks_diam_drone, cam.global_position.distance_to(pos_drone))
		var rr := cam.rotation
		maks_rot_drone = maxf(maks_rot_drone, maxf(absf(rr.x), maxf(absf(rr.y), absf(rr.z))))
	# Posisi: < 1e-6 m (BUKAN == 0.0 persis). 1e-6 m = 1 mikrometer
	# = lantai noise float32 (posisi ~10 m punya resolusi float32
	# ~1e-6 m) + micro-settling fisika pemain; BUKAN gerak kamera.
	# Ini BUKAN melonggarkan kontrak anti-mabuk 5 mm (snap modul)
	# — 1e-6 m itu 5000x di bawahnya, tak terlihat. Rotasi sudah
	# memakai ROT_EPS 1e-6 yang sama. Cek DIAM Bagian 1 tetap
	# == 0.0 persis (tidak diubah).
	_cek("DIAM mode DRONE: posisi 0 (maks %.9f m)" % maks_diam_drone, maks_diam_drone < 0.000001)
	_cek("DIAM mode DRONE: rotasi 0 (maks %.9f rad)" % maks_rot_drone, maks_rot_drone < ROT_EPS)
	k.atur_mode(2)
	await _tunggu_mode_siap(65.0, 0.15, 4.0, 1.0)
	var pos_low: Vector3 = cam.global_position
	var maks_diam_low := 0.0
	var maks_rot_low := 0.0
	for i in 60:
		await get_tree().process_frame
		maks_diam_low = maxf(maks_diam_low, cam.global_position.distance_to(pos_low))
		var rr2 := cam.rotation
		maks_rot_low = maxf(maks_rot_low, maxf(absf(rr2.x), maxf(absf(rr2.y), absf(rr2.z))))
	_cek("DIAM mode LOW: posisi 0 (maks %.9f m)" % maks_diam_low, maks_diam_low < 0.000001)
	_cek("DIAM mode LOW: rotasi 0 (maks %.9f rad)" % maks_rot_low, maks_rot_low < ROT_EPS)
	_cek("LOW sampai: spring ~4,0 m (dapat %.2f)" % _main._spring.spring_length, absf(_main._spring.spring_length - 4.0) <= 0.5)
	_cek("LOW: garis pandang bersih", _garis_pandang_bersih())
	var low_padat := _kamera_tidak_di_dalam_benda()
	_cek("LOW: kamera tidak di dalam benda padat (%s)" % _diag_tabrakan, low_padat)
	# 6c2. SINEMATIK: rotasi kamera tetap 0, tapi yaw berputar SANGAT
	# pelan (~0,05 rad/dtk — bukan diam, bukan cepat).
	k.atur_mode(4)
	for i in 60:
		await get_tree().process_frame
	var yaw_awal: float = _main._cam_yaw
	var waktu_sine := 0.0
	var maks_rot_sine := 0.0
	for i in 60:
		await get_tree().process_frame
		waktu_sine += get_process_delta_time()
		var rr3 := cam.rotation
		maks_rot_sine = maxf(maks_rot_sine, maxf(absf(rr3.x), maxf(absf(rr3.y), absf(rr3.z))))
	var laju_yaw_sine: float = (_main._cam_yaw - yaw_awal) / maxf(waktu_sine, 0.001)
	_cek("SINEMATIK: rotasi kamera 0 (maks %.9f rad)" % maks_rot_sine, maks_rot_sine < ROT_EPS)
	_cek("SINEMATIK: yaw berputar pelan ~0,05 rad/dtk (dapat %.3f)" % laju_yaw_sine, laju_yaw_sine > 0.03 and laju_yaw_sine < 0.08)
	# 6d. ATURAN ASRAMA MENANG: Drone di dalam Asrama dijepit ke
	# kontrak (spring 5,5 / pitch -0,22 / FOV 65, kamera y <= 2,95).
	k.atur_mode(0)
	_main._masuk_asrama_putra()
	for i in 90:
		await get_tree().process_frame
	_cek("Masuk Asrama Putra (flag)", _main._di_dalam_asrama_putra)
	k.atur_mode(1)
	tt = 0.0
	nn = 0
	while tt < 2.0 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Asrama+DRONE: spring <= 5,6 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length <= 5.6)
	_cek("Asrama+DRONE: kamera y <= 2,95 (dapat %.2f)" % cam.global_position.y, cam.global_position.y <= 2.95)
	_cek("Asrama+DRONE: FOV 65 (dapat %.1f)" % cam.fov, absf(cam.fov - 65.0) <= 0.5)
	_cek("Asrama+DRONE: pitch dijepit >= -0,23 (dapat %.2f)" % _main._spring.rotation.x, _main._spring.rotation.x >= -0.23)
	k.atur_mode(2)
	tt = 0.0
	nn = 0
	while tt < 2.0 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Asrama+LOW: spring <= 5,6 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length <= 5.6)
	_cek("Asrama+LOW: pitch dijepit >= -0,23 (dapat %.2f)" % _main._spring.rotation.x, _main._spring.rotation.x >= -0.23)
	_cek("Asrama+LOW: FOV 65 (dapat %.1f)" % cam.fov, absf(cam.fov - 65.0) <= 0.5)
	# Zoom-out di Asrama tetap dijepit ke 5,5 m.
	k.geser_zoom(1.3)
	tt = 0.0
	nn = 0
	while tt < 1.0 and nn < 2000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Asrama+zoom-out: spring tetap <= 5,6 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length <= 5.6)
	k.geser_zoom(1.0 / 1.3)
	# Bukti NYATA jepit 5,5 m (bukan hanya batas atas): cek di atas
	# mengukur spring 1,2 m — itu PENJAGA anti-tembus, bukan
	# jepitnya: dengan yaw PI bawaan pemain menghadap MELINTANG
	# koridor (lebar 2,6 m) sehingga kamera menghantam dinding di
	# 1,2 m. Hadapkan pemain MEMANJANG koridor (yaw PI/2, ke pintu
	# barat) — kamera di timur pemain, koridor 18 m muat spring
	# penuh 5,5 m, kamera y ~2,8.
	k.atur_mode(1)
	_main._teleport_player(_main._asrama_putra_interior_spawn, PI * 0.5)
	tt = 0.0
	nn = 0
	while tt < 2.0 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Asrama+DRONE memanjang koridor: spring ~5,5 m (dapat %.2f)" % _main._spring.spring_length, _main._spring.spring_length > 5.0 and _main._spring.spring_length <= 5.6)
	_cek("Asrama+DRONE memanjang koridor: kamera y ~2,8 (dapat %.2f)" % cam.global_position.y, cam.global_position.y > 2.5 and cam.global_position.y <= 2.95)
	_main._keluar_asrama_putra()
	for i in 30:
		await get_tree().process_frame
	# 6e. ZOOM di luar ruangan: mengubah spring (bukan FOV), dijepit.
	k.atur_mode(0)
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	for i in 90:
		await get_tree().process_frame
	k.geser_zoom(0.6)
	tt = 0.0
	nn = 0
	while tt < 1.5 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Zoom 0,6x: spring ~4,8 m (dapat %.2f)" % _main._spring.spring_length, absf(_main._spring.spring_length - 4.8) <= 0.5)
	_cek("Zoom 0,6x: FOV tetap 68 (dapat %.1f)" % cam.fov, absf(cam.fov - 68.0) <= 0.5)
	k.geser_zoom(1.0 / 0.6)
	tt = 0.0
	nn = 0
	while tt < 2.0 and nn < 3000:
		await get_tree().process_frame
		tt += get_process_delta_time()
		nn += 1
	_cek("Zoom kembali 1,0x: spring ~8,0 m (dapat %.2f)" % _main._spring.spring_length, absf(_main._spring.spring_length - 8.0) <= 0.5)
	k.geser_zoom(0.01)
	_cek("Zoom dijepit bawah 0,55 (dapat %.2f)" % k.zoom_target(), absf(k.zoom_target() - 0.55) < 0.01)
	k.geser_zoom(100.0)
	_cek("Zoom dijepit atas 1,30 (dapat %.2f)" % k.zoom_target(), absf(k.zoom_target() - 1.30) < 0.01)
	k.geser_zoom(1.0 / 1.3)
	# Aturan nama mode lain TIDAK berubah: di NORMAL skala label
	# kembali maks 1,0 (tidak di-boost seperti Drone).
	for i in 30:
		await get_tree().process_frame
	_cek("NORMAL: label nama tidak di-boost (skala %.2f)" % _main._player._name_label.scale.x, _main._player._name_label.scale.x <= 1.01)
	# --- 6g. MARKER PETA ASRAMA PUTRA (Mas: "Tambah", 13:19) ---
	# Setelah kotak emas plot hilang (tahap 2 "Asrama" sudah
	# "dibangun"), gedung harus bertanda di peta besar + minimap.
	var peta_map = _main._ui._peta_map
	_cek("Peta besar terpasang", peta_map != null)
	var ketemu_putra := false
	if peta_map != null:
		for gedung in peta_map.GEDUNG_PUTRA:
			if String(gedung[0]) == "ASRAMA PUTRA" and (gedung[1] as Vector2).distance_to(Vector2(-24, 10)) < 0.5 and (gedung[2] as Vector2) == Vector2(18, 12):
				ketemu_putra = true
	_cek("Marker ASRAMA PUTRA di peta besar (-24,10) 18x12", ketemu_putra)
	var ketemu_minimap := false
	for gedung in PesantrenUI.PetaControl.GEDUNG_PUTRA:
		if String(gedung[0]) == "ASRAMA PUTRA":
			ketemu_minimap = true
	_cek("Marker ASRAMA PUTRA dipakai minimap (konstanta sama)", ketemu_minimap)
	# Smoke: buka peta + minimap dengan data asli — tidak error.
	_main._ui.open_peta(_main._data_peta())
	_main._ui.update_peta(_main._data_peta())
	_main._ui.update_minimap(_main._data_peta())
	for i in 5:
		await get_tree().process_frame
	_cek("Peta besar menerima data (player tercatat)", peta_map != null and peta_map.data.has("player"))
	print("TES KAMERA: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
