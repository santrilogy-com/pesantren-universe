extends Node
## Tes JALAN MUNDUR (Raka, 18 Nov 2026) — reproduksi laporan Mas 16:11 WIB.
##   godot --headless --path . skrip/test_jalan_mundur.tscn
## Laporan Mas (T1 HP, bundle live 37d51aa2): "Kenapa player jalannya mundur?"
## Di atas kertas rantai input -> gerak -> hadap -> kamera SEMUA benar:
## joystick atas = output.y negatif -> move_dir = forward kamera ->
## velocity searah -> target_yaw = atan2(v.x, v.z) menghadapkan wajah
## (+Z) searah gerak -> kamera di atas-belakang. Tes ini MENGUKUR
## ujung-ke-ujung di scene asli (bukan membaca kode):
## (a) arah perpindahan vs forward kamera (searah?)
## (b) arah hadap wajah vs arah kecepatan (searah atau berlawanan?)
## (c) posisi kamera vs pemain (di belakang arah hadap atau di depan?)
## (d) fase kaki: lutut menekuk saat kaki mengayun ke DEPAN (jalan
##     maju) atau saat kaki bergerak ke BELAKANG (moonwalk)?
## (e) kaki tidak pernah bergerak mundur relatif terhadap tanah.
## (f) ulangi tiap mode kamera + tiap yaw spawn.

var _main: Node
var _lulus := 0
var _gagal := 0


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


func _datar(v: Vector3) -> Vector3:
	var d := v
	d.y = 0.0
	if d.length() < 0.0001:
		return Vector3.ZERO
	return d.normalized()


## Arah hadap wajah: sumbu +Z visual (mata/hidung di +Z).
func _wajah() -> Vector3:
	return _datar((_main._player._visual as Node3D).global_transform.basis.z)


## Forward kamera menurut main.gd: -Z rig.
func _forward() -> Vector3:
	return _datar(-(_main._rig as Node3D).global_transform.basis.z)


## Arah pandang kamera sebenarnya: -Z kamera.
func _pandang() -> Vector3:
	return _datar(-(_main._cam as Camera3D).global_transform.basis.z)


func _dump(tag: String) -> void:
	var p = _main._player
	print("DUMP %s: pos=%s vel=%s move_dir=%s wajah=%s yaw_vis=%.3f forward=%s pandang=%s cam=%s rig_yaw=%.3f cam_yaw=%.3f aksi=%s" % [
		tag, str(p.global_position), str(p.velocity), str(p.move_dir),
		str(_wajah()), float(p._visual.rotation.y), str(_forward()), str(_pandang()),
		str((_main._cam as Camera3D).global_position), float((_main._rig as Node3D).rotation.y),
		float(_main._cam_yaw), str(p.aksi_saat_ini())])


## Dorong joystick penuh ke atas selama `durasi` detik, sampling tiap
## frame. Mengembalikan Dictionary metrik (angka mentah ikut dicetak).
func _jalan_atas(durasi: float) -> Dictionary:
	var p = _main._player
	var pos0: Vector3 = p.global_position
	var fw0: Vector3 = _forward()
	var fw_jumlah := Vector3.ZERO
	var fw_n := 0
	var dot_wajah_vel := 0.0
	var dot_wajah_n := 0
	var dot_movedir_fw := 0.0
	var dot_movedir_n := 0
	var hitung_maju := 0
	var lutut_maju := 0
	var hitung_mundur := 0
	var lutut_mundur := 0
	var leg_sebelum := 0.0
	var punya_sebelum := false
	var kaki_min := 999.0
	var contoh_kaki: Array = [] # [waktu, posisi kaki kiri sepanjang arah jalan]
	_main._ui._joystick.output = Vector2(0, -1)
	var t := 0.0
	while t < durasi:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var fw := _forward()
		fw_jumlah += fw
		fw_n += 1
		var vel := _datar(p.velocity)
		if vel.length() > 0.5:
			dot_wajah_vel += _wajah().dot(vel)
			dot_wajah_n += 1
		var md := _datar(p.move_dir)
		if md.length() > 0.5:
			dot_movedir_fw += md.dot(fw)
			dot_movedir_n += 1
		# Fase kaki — baru diukur setelah 0,3 dtk (blend jalan 0->1).
		# Ayun MAJU = rotation.x kaki kiri MENURUN (kaki ke depan);
		# ayun MUNDUR = rotation.x NAIK (kaki ke belakang, fase
		# tumpuan). Jalan maju yang benar: lutut menekuk BESAR saat
		# ayun maju (angkat kaki), hampir lurus saat tumpuan.
		if t > 0.3:
			var leg := float(p._leg_l.rotation.x)
			if punya_sebelum:
				var lutut := float(p._knee_l.rotation.x) > 0.3
				if leg < leg_sebelum - 0.0005:
					hitung_maju += 1
					if lutut:
						lutut_maju += 1
				elif leg > leg_sebelum + 0.0005:
					hitung_mundur += 1
					if lutut:
						lutut_mundur += 1
			leg_sebelum = leg
			punya_sebelum = true
			# Kecepatan kaki kiri sepanjang arah jalan (jendela 0,1 dtk).
			# HANYA saat hadap sudah searah gerak (dot > 0,99): saat
			# pemain berputar (mis. Bagian D — kamera yaw warisan
			# Bagian C), kaki berputar bersama badan dan proyeksi
			# ke arah jalan tetap bisa negatif sesaat — itu putaran,
			# bukan moonwalk. Metrik ini mengukur gait tunak.
			var s := float(p._sandal_l.global_position.dot(fw0))
			if _wajah().dot(fw) > 0.99:
				contoh_kaki.append([t, s])
			else:
				contoh_kaki.clear()
			while contoh_kaki.size() > 0 and float(contoh_kaki[0][0]) < t - 0.1:
				contoh_kaki.remove_at(0)
			if contoh_kaki.size() >= 2:
				var dt_w: float = t - float(contoh_kaki[0][0])
				if dt_w > 0.02:
					var v_kaki: float = (s - float(contoh_kaki[0][1])) / dt_w
					kaki_min = minf(kaki_min, v_kaki)
	_main._ui._joystick.output = Vector2.ZERO
	var pos1: Vector3 = p.global_position
	var disp := pos1 - pos0
	var disp_datar := _datar(disp)
	var fw_rata := _datar(fw_jumlah / maxf(1.0, float(fw_n)))
	var m := {
		"disp": disp,
		"jarak": disp.length(),
		"dot_disp_forward": disp_datar.dot(fw_rata),
		"dot_wajah_vel": dot_wajah_vel / maxf(1.0, float(dot_wajah_n)),
		"dot_wajah_disp": _wajah().dot(disp_datar),
		"dot_movedir_forward": dot_movedir_fw / maxf(1.0, float(dot_movedir_n)),
		"dot_pandang_forward": _pandang().dot(_forward()),
		"kamera_belakang": (_datar((_main._cam as Camera3D).global_position - p.global_position)).dot(_wajah()),
		"frac_lutut_maju": float(lutut_maju) / maxf(1.0, float(hitung_maju)),
		"frac_lutut_mundur": float(lutut_mundur) / maxf(1.0, float(hitung_mundur)),
		"kaki_min": kaki_min,
		"wajah_akhir": _wajah(),
		"forward_akhir": _forward(),
	}
	print("UKUR: disp=%s jarak=%.2f dot_disp_fw=%.3f dot_wajah_vel=%.3f dot_wajah_disp=%.3f dot_movedir_fw=%.3f dot_pandang_fw=%.3f kam_belakang=%.2f lutut_maju=%.2f lutut_mundur=%.2f kaki_min=%.2f wajah=%s fw=%s" % [
		str(disp), float(m["jarak"]), float(m["dot_disp_forward"]), float(m["dot_wajah_vel"]),
		float(m["dot_wajah_disp"]), float(m["dot_movedir_forward"]), float(m["dot_pandang_forward"]),
		float(m["kamera_belakang"]), float(m["frac_lutut_maju"]), float(m["frac_lutut_mundur"]),
		float(m["kaki_min"]), str(m["wajah_akhir"]), str(m["forward_akhir"])])
	return m


func _cek_gerak(m: Dictionary, tag: String) -> void:
	_cek(tag + ": gerak searah forward kamera (dot %.3f, jarak %.2f m)" % [float(m["dot_disp_forward"]), float(m["jarak"])], float(m["dot_disp_forward"]) > 0.9 and float(m["jarak"]) > 1.0)
	_cek(tag + ": wajah searah kecepatan (dot %.3f)" % [float(m["dot_wajah_vel"])], float(m["dot_wajah_vel"]) > 0.9)
	_cek(tag + ": wajah searah perpindahan (dot %.3f)" % [float(m["dot_wajah_disp"])], float(m["dot_wajah_disp"]) > 0.9)
	_cek(tag + ": move_dir searah forward (dot %.3f)" % [float(m["dot_movedir_forward"])], float(m["dot_movedir_forward"]) > 0.99)
	_cek(tag + ": arah pandang kamera = forward (dot %.3f)" % [float(m["dot_pandang_forward"])], float(m["dot_pandang_forward"]) > 0.99)
	_cek(tag + ": kamera di belakang arah hadap (dot %.2f)" % [float(m["kamera_belakang"])], float(m["kamera_belakang"]) < 0.0)
	_cek(tag + ": lutut menekuk saat ayun maju, bukan saat mundur (%.2f vs %.2f)" % [float(m["frac_lutut_maju"]), float(m["frac_lutut_mundur"])], float(m["frac_lutut_maju"]) > float(m["frac_lutut_mundur"]) + 0.15)
	_cek(tag + ": kaki tidak pernah bergerak mundur di tanah (min %.2f m/dtk)" % [float(m["kaki_min"])], float(m["kaki_min"]) > 0.0 and float(m["kaki_min"]) < 900.0)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (pola test_kamera.gd): kosongkan ig di save supaya
	# tes jalan OFFLINE (tidak ikut terhubung ke server live).
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Tes jalan mundur")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	await _tunggu_waktu(2.5)
	# --- Keadaan awal (sebelum input) ---
	_dump("AWAL")
	_cek("AWAL: pemain menghadap menjauhi kamera (dot wajah·(kam-pemain) < 0)", _datar((_main._cam as Camera3D).global_position - _main._player.global_position).dot(_wajah()) < 0.0)
	# --- A. NORMAL, spawn (yaw PI, menghadap -Z / Surau) ---
	var m_a := await _jalan_atas(2.0)
	_cek_gerak(m_a, "A NORMAL spawn")
	# --- B. Tiap mode kamera (teleport ulang + tunggu transisi) ---
	var k = _main._kamera
	var nama_mode := ["Normal", "Drone", "Low Angle", "High Angle", "Sinematik"]
	for mode in [1, 2, 3, 4]:
		_main._teleport_player(Vector3(-4, 0, 14), PI)
		k.atur_mode(mode)
		await _tunggu_waktu(3.0)
		_dump("B mode " + nama_mode[mode])
		var m_b := await _jalan_atas(1.5)
		_cek_gerak(m_b, "B " + nama_mode[mode])
	k.atur_mode(0)
	# --- C. Yaw spawn lain (mode NORMAL) ---
	for yaw in [0.0, PI * 0.5, -PI * 0.5]:
		_main._teleport_player(Vector3(-4, 0, 14), yaw)
		await _tunggu_waktu(0.7)
		_dump("C yaw %.2f" % yaw)
		var m_c := await _jalan_atas(1.2)
		_cek_gerak(m_c, "C yaw %.2f" % yaw)
	# --- D. AVATAR MP (reproduksi laporan Mas — mode online) ---
	# Alur asli saat klien bergabung: NetworkManager.spawn_player
	# membuat avatar lokal (SantriPlayer, node rotation.y = PI) lalu
	# _mp_adopsi_avatar_sendiri menjadikannya _player. Di mode MP,
	# hadap dunia = node PI + _visual PI (set_facing / lerp hadap) =
	# 2PI = 0: wajah menghadap kamera (selatan) sementara badan
	# bergerak ke utara — "jalannya mundur". Mode offline tidak kena
	# (node avatar offline rotation.y-nya 0). Bagian ini memakai
	# spawn_player ASLI (bukan set rotation.y manual) supaya yang
	# diuji adalah jalur produksi.
	var nm := get_node_or_null("/root/NetworkManager")
	_cek("D MP: NetworkManager autoload ada", nm != null)
	if nm != null:
		var peer_id := multiplayer.get_unique_id()
		print("D MP: peer_id lokal = %d" % peer_id)
		var data_mp := {"peer_id": peer_id, "nama": "Tes MP", "jenis_kelamin": "putra", "outfit": MissionData.OUTFIT_DEFAULT}
		var avatar_mp = nm.spawn_player(data_mp)
		_cek("D MP: spawn_player mengembalikan SantriPlayer", avatar_mp is SantriPlayer)
		_main._players.add_child(avatar_mp)
		for i in 5:
			await get_tree().process_frame
		# Adopsi seperti _mp_adopsi_avatar_sendiri (tanpa status MP).
		var lama = _main._player
		lama.visible = false
		lama.process_mode = Node.PROCESS_MODE_DISABLED
		_main._player = avatar_mp
		_main._pos_legal_terakhir = avatar_mp.global_position
		_main._punya_pos_legal = true
		await _tunggu_waktu(0.5)
		# Samakan kamera dengan hadap (seperti Bagian B/C): teleport
		# mengatur _cam_yaw = yaw + PI + set_facing pada avatar
		# adopsi — tanpa ini drive dimulai dengan putaran 90° (yaw
		# kamera warisan Bagian C) dan metrik kaki (proyeksi ke arah
		# jalan yang tetap) menangkap artefak putaran, bukan gait.
		_main._teleport_player(Vector3(-4, 0, 14), PI)
		await _tunggu_waktu(0.7)
		_dump("D MP spawn (belum jalan)")
		_cek("D MP: avatar spawn menghadap utara (wajah -Z)", _wajah().dot(Vector3(0, 0, -1)) > 0.9)
		var m_d := await _jalan_atas(2.0)
		_cek_gerak(m_d, "D MP jalan")
	print("TES JALAN MUNDUR: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
