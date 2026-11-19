extends Node
## Tes PINTU LUAR PUTRI (Dewi, 18 Nov 2026 — perintah Mas 07:09 WIB).
##   godot --headless --path . skrip/test_pintu_luar_putri.tscn
## Cek: tiap gedung putri punya daun pintu TERTUTUP dua daun jati di
## celah pintu (Musholla, Kelas, Asrama, Kantor, Madrasah, Studio,
## Pos Jaga TL); posisi daun = posisi pintu kanonik; celah tertutup
## collision (raycast mentok di bidang pintu, termasuk dekat puncak
## daun + ambang di atasnya); pemain yang jalan dari exit ke pintu
## men-teleport ke interior (koridor pemicu _cek_pintu_* di main.gd
## 1,5 m DI LUAR daun, jadi pemain tidak pernah menyentuh daun —
## daun = pengaman + visual, bukan jalan tembus) dan TIDAK pernah
## berakhir di dalam cangkang kosong. Daun rata dengan dinding dan
## gagang tanpa collision, jadi tidak ada yang menjebak pemain di
## depan pintu.
## Pola dorong (_kalibrasi/_taruh/_dorong) disalin dari
## skrip/test_tabrakan_dunia.gd (Bagas). Keluar: exit 0 bila lulus.

var _main: Node
var _t_fwd: Vector3
var _t_right: Vector3
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ray(dari: Vector3, ke: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(dari, ke)
	return get_tree().root.get_world_3d().direct_space_state.intersect_ray(q)


## True bila ada MeshInstance3D di subtree `di` yang AABB dunianya memuat titik.
func _ada_mesh_di(di: Node, titik: Vector3) -> bool:
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			if (mi.global_transform * mi.get_aabb()).has_point(titik):
				return true
		if _ada_mesh_di(ch, titik):
			return true
	return false


func _kalibrasi() -> void:
	_main._player.global_position = Vector3(-4, 0, 14)
	_main._player.velocity = Vector3.ZERO
	for i in 3:
		await get_tree().process_frame
	var start: Vector3 = _main._player.global_position
	_main._player.set_aksi("berdiri")
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 20:
		await get_tree().process_frame
	var d: Vector3 = _main._player.global_position - start
	d.y = 0
	if d.length() > 0.05:
		_t_fwd = d.normalized()
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	start = _main._player.global_position
	_main._ui._joystick.output = Vector2(1, 0)
	for i in 20:
		await get_tree().process_frame
	d = _main._player.global_position - start
	d.y = 0
	if d.length() > 0.05:
		_t_right = d.normalized()
	_main._ui._joystick.output = Vector2.ZERO


func _set_joystick_arah(arah: Vector3) -> void:
	var ja := arah.dot(_t_right)
	var jb := arah.dot(_t_fwd)
	_main._ui._joystick.output = Vector2(ja, -jb)


func _taruh(pos: Vector3) -> void:
	_main._teleport_player(pos, PI)
	for i in 3:
		await get_tree().process_frame


## Jalan dari exit ke pintu: harus men-teleport ke interior (pola
## _cek_pintu_* di main.gd: koridor pemicu 1,5 m DI LUAR daun, jadi
## pemain tidak pernah menyentuh daun — daun = pengaman + visual,
## dibuktikan raycast di §3). Pemain TIDAK boleh berakhir di dalam
## cangkang kosong. Bendera _di_dalam_* direset setelah cek (pola
## test_tabrakan_dunia) supaya tes berikutnya mulai dari luar.
func _cek_pintu_teleport(nama: String, start: Vector3, arah: Vector3, bendera: String, spawn_dalam: String, cangkang: Array) -> void:
	await _taruh(start)
	_set_joystick_arah(arah.normalized())
	var masuk := false
	for i in 120:
		await get_tree().process_frame
		if _main.get(bendera):
			masuk = true
			break
	_main._ui._joystick.output = Vector2.ZERO
	var pos_akhir: Vector3 = _main._player.global_position
	var spawn: Vector3 = _main.get(spawn_dalam)
	var di_interior := masuk and pos_akhir.distance_to(spawn) < 6.0
	var di_cangkang: bool = (pos_akhir.x > cangkang[0] and pos_akhir.x < cangkang[1]
		and pos_akhir.z > cangkang[2] and pos_akhir.z < cangkang[3])
	_cek(nama + " jalan ke pintu men-teleport ke interior (akhir=%s)" % str(pos_akhir),
		di_interior and not di_cangkang)
	_main.set(bendera, false)


## Raycast dari luar ke pintu: harus mentok di bidang pintu
## (muka daun 0,125 dari bidang; toleransi 0,25).
func _cek_ray_mentok(nama: String, dari: Vector3, ke: Vector3, bidang: float, sumbu: String) -> void:
	var h: Dictionary = _ray(dari, ke)
	var ok := false
	if not h.is_empty():
		var p: Vector3 = h["position"]
		var v := p.z if sumbu == "z" else p.x
		ok = absf(v - bidang) < 0.25
	_cek(nama + (" (hit=%s)" % [str(h.get("position", Vector3.ZERO))]), ok)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["role"] = "keamanan"
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes pintu luar putri")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	await _kalibrasi()

	var root: Node = _main._pesantren["root"]
	var kampus: Node = root.find_child("KampusPutri", true, false)
	_cek("KampusPutri ada", kampus != null)

	# --- 1. Konstanta pintu kanonik (sumber kanonik = KampusPutri;
	# PesantrenBuilder.build() hanya meneruskan sebagian kunci ke
	# _main._pesantren — forward 12 kunci door/exit baru di sana
	# adalah tugas wiring Raka, BUKAN tugas ini) ---
	_cek("KELAS_DOOR (130,14)", KampusPutri.KELAS_DOOR.distance_to(Vector3(130, 0, 14)) < 0.01)
	_cek("ASRAMA_DOOR (146,9)", KampusPutri.ASRAMA_DOOR.distance_to(Vector3(146, 0, 9)) < 0.01)
	_cek("KANTOR_DOOR (144,-33)", KampusPutri.KANTOR_DOOR.distance_to(Vector3(144, 0, -33)) < 0.01)
	_cek("MADRASAH_DOOR (147,-12)", KampusPutri.MADRASAH_DOOR.distance_to(Vector3(147, 0, -12)) < 0.01)
	_cek("STUDIO_DOOR (166,-16)", KampusPutri.STUDIO_DOOR.distance_to(Vector3(166, 0, -16)) < 0.01)
	_cek("POS_JAGA_DOOR (174.5,-20)", KampusPutri.POS_JAGA_DOOR.distance_to(Vector3(174.5, 0, -20)) < 0.01)
	_cek("MUSHOLLA_DOOR (134,-19)", KampusPutri.MUSHOLLA_DOOR.distance_to(Vector3(134, 0, -19)) < 0.01)
	_cek("KELAS_EXIT (130,15.5)", KampusPutri.KELAS_EXIT.distance_to(Vector3(130, 0, 15.5)) < 0.01)
	_cek("ASRAMA_EXIT (144.5,9)", KampusPutri.ASRAMA_EXIT.distance_to(Vector3(144.5, 0, 9)) < 0.01)
	_cek("KANTOR_EXIT (142.5,-33)", KampusPutri.KANTOR_EXIT.distance_to(Vector3(142.5, 0, -33)) < 0.01)
	_cek("MADRASAH_EXIT (145.5,-12)", KampusPutri.MADRASAH_EXIT.distance_to(Vector3(145.5, 0, -12)) < 0.01)
	_cek("STUDIO_EXIT (166,-17.5)", KampusPutri.STUDIO_EXIT.distance_to(Vector3(166, 0, -17.5)) < 0.01)
	_cek("POS_JAGA_EXIT (173,-20)", KampusPutri.POS_JAGA_EXIT.distance_to(Vector3(173, 0, -20)) < 0.01)
	_cek("MUSHOLLA_EXIT (134,-17.5)", KampusPutri.MUSHOLLA_EXIT.distance_to(Vector3(134, 0, -17.5)) < 0.01)

	# --- 2. Node daun + posisi mesh daun = posisi kanonik ---
	# (nama node, pusat daun 1, pusat daun 2)
	var daun: Array = [
		["DaunPintuMusholla", Vector3(133.5, 1.5, -19), Vector3(134.5, 1.5, -19)],
		["PintuKelasPutri", Vector3(129.6, 1.3, 14), Vector3(130.4, 1.3, 14)],
		["PintuAsramaPutri", Vector3(146, 1.3, 8.6), Vector3(146, 1.3, 9.4)],
		["PintuKantorUstadzah", Vector3(144, 1.3, -33.4), Vector3(144, 1.3, -32.6)],
		["PintuMadrasah", Vector3(147, 1.3, -12.4), Vector3(147, 1.3, -11.6)],
		["PintuStudio", Vector3(165.6, 1.3, -16), Vector3(166.4, 1.3, -16)],
		["PintuPosJagaTL", Vector3(174.5, 0.9, -20.3), Vector3(174.5, 0.9, -19.7)],
	]
	for item in daun:
		var n: Node = root.find_child(item[0], true, false)
		_cek("Node " + item[0] + " ada", n != null)
		if n != null:
			_cek(item[0] + " daun 1 di " + str(item[1]), _ada_mesh_di(n, item[1]))
			_cek(item[0] + " daun 2 di " + str(item[2]), _ada_mesh_di(n, item[2]))

	# --- 3. Raycast: celah tertutup di tengah daun, dekat puncak daun, + ambang ---
	# (nama, dari, ke, bidang, sumbu, y-ray sudah di `dari`/`ke`)
	var sinar: Array = [
		# Musholla (bidang z=-19): daun 2,0x3,0; lintel 3,0..4,0.
		["ray Musholla tengah", Vector3(133.5, 1.5, -14), Vector3(133.5, 1.5, -22), -19.0, "z"],
		["ray Musholla tengah 2", Vector3(134.5, 1.5, -14), Vector3(134.5, 1.5, -22), -19.0, "z"],
		["ray Musholla dekat puncak (y2.8)", Vector3(133.5, 2.8, -14), Vector3(133.5, 2.8, -22), -19.0, "z"],
		["ray Musholla ambang (y3.4)", Vector3(134, 3.4, -14), Vector3(134, 3.4, -22), -19.0, "z"],
		# Kelas (bidang z=14): daun 1,6x2,6; lintel 2,6..3,6.
		["ray Kelas tengah", Vector3(129.6, 1.3, 18), Vector3(129.6, 1.3, 10), 14.0, "z"],
		["ray Kelas tengah 2", Vector3(130.4, 1.3, 18), Vector3(130.4, 1.3, 10), 14.0, "z"],
		["ray Kelas dekat puncak (y2.4)", Vector3(129.6, 2.4, 18), Vector3(129.6, 2.4, 10), 14.0, "z"],
		["ray Kelas ambang (y3.0)", Vector3(130, 3.0, 18), Vector3(130, 3.0, 10), 14.0, "z"],
		# Asrama (bidang x=146).
		["ray Asrama tengah", Vector3(142, 1.3, 8.6), Vector3(148, 1.3, 8.6), 146.0, "x"],
		["ray Asrama tengah 2", Vector3(142, 1.3, 9.4), Vector3(148, 1.3, 9.4), 146.0, "x"],
		["ray Asrama dekat puncak (y2.4)", Vector3(142, 2.4, 8.6), Vector3(148, 2.4, 8.6), 146.0, "x"],
		["ray Asrama ambang (y3.0)", Vector3(142, 3.0, 9), Vector3(148, 3.0, 9), 146.0, "x"],
		# Kantor (bidang x=144).
		["ray Kantor tengah", Vector3(140, 1.3, -33.4), Vector3(148, 1.3, -33.4), 144.0, "x"],
		["ray Kantor tengah 2", Vector3(140, 1.3, -32.6), Vector3(148, 1.3, -32.6), 144.0, "x"],
		["ray Kantor dekat puncak (y2.4)", Vector3(140, 2.4, -33.4), Vector3(148, 2.4, -33.4), 144.0, "x"],
		["ray Kantor ambang (y3.0)", Vector3(140, 3.0, -33), Vector3(148, 3.0, -33), 144.0, "x"],
		# Madrasah (bidang x=147).
		["ray Madrasah tengah", Vector3(143, 1.3, -12.4), Vector3(150, 1.3, -12.4), 147.0, "x"],
		["ray Madrasah tengah 2", Vector3(143, 1.3, -11.6), Vector3(150, 1.3, -11.6), 147.0, "x"],
		["ray Madrasah dekat puncak (y2.4)", Vector3(143, 2.4, -12.4), Vector3(150, 2.4, -12.4), 147.0, "x"],
		["ray Madrasah ambang (y3.0)", Vector3(143, 3.0, -12), Vector3(150, 3.0, -12), 147.0, "x"],
		# Studio (bidang z=-16, pintu menghadap utara).
		["ray Studio tengah", Vector3(165.6, 1.3, -20), Vector3(165.6, 1.3, -12), -16.0, "z"],
		["ray Studio tengah 2", Vector3(166.4, 1.3, -20), Vector3(166.4, 1.3, -12), -16.0, "z"],
		["ray Studio dekat puncak (y2.4)", Vector3(165.6, 2.4, -20), Vector3(165.6, 2.4, -12), -16.0, "z"],
		["ray Studio ambang (y3.0)", Vector3(166, 3.0, -20), Vector3(166, 3.0, -12), -16.0, "z"],
		# Pos Jaga (bidang x=174.5): daun 1,2x1,8; lintel 1,8..2,6.
		["ray PosJaga tengah", Vector3(171, 0.9, -20.3), Vector3(177, 0.9, -20.3), 174.5, "x"],
		["ray PosJaga tengah 2", Vector3(171, 0.9, -19.7), Vector3(177, 0.9, -19.7), 174.5, "x"],
		["ray PosJaga dekat puncak (y1.6)", Vector3(171, 1.6, -20.3), Vector3(177, 1.6, -20.3), 174.5, "x"],
		["ray PosJaga ambang (y2.2)", Vector3(171, 2.2, -20), Vector3(177, 2.2, -20), 174.5, "x"],
	]
	for s in sinar:
		_cek_ray_mentok(s[0], s[1], s[2], s[3], s[4])

	# --- 4. Jalan dari exit ke pintu: teleport ke interior, bukan tembus cangkang ---
	# (nama, start=exit, arah, bendera _di_dalam_*, spawn interior, batas cangkang [x_min, x_max, z_min, z_max])
	await _cek_pintu_teleport("KelasPutri", Vector3(130, 0, 15.5), Vector3(0, 0, -1),
		"_di_dalam_kelas_putri", "_kelas_putri_interior_spawn", [125.0, 135.0, 6.0, 14.0])
	await _cek_pintu_teleport("AsramaPutri", Vector3(144.5, 0, 9), Vector3(1, 0, 0),
		"_di_dalam_asrama_putri", "_asrama_putri_interior_spawn", [146.0, 158.0, 5.0, 13.0])
	await _cek_pintu_teleport("KantorUstadzah", Vector3(142.5, 0, -33), Vector3(1, 0, 0),
		"_di_dalam_kantor", "_kantor_interior_spawn", [144.0, 152.0, -36.0, -30.0])
	await _cek_pintu_teleport("Madrasah", Vector3(145.5, 0, -12), Vector3(1, 0, 0),
		"_di_dalam_madrasah", "_madrasah_interior_spawn", [147.0, 157.0, -16.0, -8.0])
	await _cek_pintu_teleport("Studio", Vector3(166, 0, -17.5), Vector3(0, 0, 1),
		"_di_dalam_studio", "_studio_interior_spawn", [161.0, 171.0, -16.0, -8.0])
	await _cek_pintu_teleport("PosJagaTL", Vector3(173, 0, -20), Vector3(1, 0, 0),
		"_di_dalam_pos_jaga", "_pos_jaga_interior_spawn", [174.5, 177.5, -21.5, -18.5])

	# --- 5. Musholla: jalan ke pintu = teleport interior, bukan tembus cangkang ---
	await _taruh(Vector3(134, 0, -14))
	_set_joystick_arah(Vector3(0, 0, -1))
	var masuk := false
	for i in 120:
		await get_tree().process_frame
		if _main._di_dalam_musholla:
			masuk = true
			break
	_main._ui._joystick.output = Vector2.ZERO
	var pos_akhir: Vector3 = _main._player.global_position
	_cek("Musholla: jalan ke pintu men-teleport ke interior (bukan tembus cangkang)",
		masuk and pos_akhir.z < -50.0)
	_cek("Musholla: pemain TIDAK di dalam cangkang kosong (134,-24)",
		not (not _main._di_dalam_musholla and pos_akhir.x > 128.0 and pos_akhir.x < 140.0
			and pos_akhir.z > -29.0 and pos_akhir.z < -19.0))

	print("HASIL PINTU LUAR PUTRI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
