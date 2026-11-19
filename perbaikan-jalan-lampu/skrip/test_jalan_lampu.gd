extends Node
## Tes perbaikan jalan + lampu Surau (Mas 12:36-12:38 WIB: "Tetap miring
## — perbaiki jalan + pindah lampu"). Dijalankan sebagai SCENE (.tscn),
## bukan -s (pelajaran ronde 19: -s membuat jendela 100x100).
## Jam dibekukan 10.00 (debug_jam) supaya sesi sholat tidak mengganggu.

var _main: Node
var _lolos := 0
var _gagal := 0

const PINTU := Vector3(-2.11, 0, -7.47)
const KELUAR := Vector3(-2.75, 0, -6.11) # pintu + keluar*1.5
const LAMPU_BARU := Vector3(-6.5, 0, -7.5)
const LAMPU_LAMA := Vector3(-2.2, 0, -6.0)
const KYAI := Vector3(-4.8, 0, -4.8)


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._on_login("PV-0001", "Tes")
	await get_tree().process_frame
	_jalan()
	print("HASIL TES JALAN+LAMPU: %d LOLOS / %d GAGAL" % [_lolos, _gagal])
	for i in 600:
		await get_tree().process_frame
	print("SMOKE 600 FRAME SELESAI")
	get_tree().quit(0 if _gagal == 0 else 1)


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _dekat(a: Vector3, b: Vector3, tol: float) -> bool:
	return a.distance_to(b) <= tol


func _jarak_titik_ke_segmen(p: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _jalan() -> void:
	var frame: Dictionary = PesantrenBuilder.surau_pintu()
	var pintu: Vector3 = frame["pintu"]
	var masuk: Vector3 = frame["masuk"]
	var keluar: Vector3 = frame["keluar"]
	var sumbu: Vector3 = frame["sumbu"]
	# --- 1. Frame pintu TIDAK berubah (Surau tetap miring -25°) ---
	_cek("frame pintu tetap (-2.11,-7.47)", _dekat(pintu, PINTU, 0.05), str(pintu))
	_cek("rotasi Surau tetap -25", is_equal_approx(PesantrenBuilder.SURAU_ROTASI_DEG, -25.0), "")
	_cek("outdoor_door tidak berubah", _dekat(_main._outdoor_door, PINTU, 0.05), str(_main._outdoor_door))
	_cek("outdoor_exit tidak berubah", _dekat(_main._outdoor_exit, KELUAR, 0.05), str(_main._outdoor_exit))
	# --- 2. Jalan baru ---
	var root: Node = _main.get_node("Pesantren")
	var jalan: MeshInstance3D = root.find_child("JalanSurau", true, false) as MeshInstance3D
	_cek("node JalanSurau ada", jalan != null, "")
	if jalan == null:
		return
	var mesh := jalan.mesh as BoxMesh
	_cek("jalan ukuran 2.5 x 0.06 x 8.5", mesh != null and _dekat(mesh.size, Vector3(2.5, 0.06, 8.5), 0.01), str(mesh.size) if mesh else "?")
	_cek("jalan posisi (-3.91, 0.03, -3.62)", _dekat(jalan.position, Vector3(-3.91, 0.03, -3.62), 0.05), str(jalan.position))
	_cek("jalan rotasi.y -25 derajat", absf(rad_to_deg(jalan.rotation.y) + 25.0) < 0.5, "%.2f" % rad_to_deg(jalan.rotation.y))
	var sumbu_jalan: Vector3 = jalan.global_transform.basis.z.normalized()
	_cek("sumbu jalan sejajar normal pintu (|dot|=1)", absf(absf(sumbu_jalan.dot(keluar)) - 1.0) < 0.001, "dot=%.4f" % sumbu_jalan.dot(keluar))
	var ujung_pintu: Vector3 = jalan.position - sumbu_jalan * 4.25
	var ujung_jalan: Vector3 = jalan.position + sumbu_jalan * 4.25
	_cek("ujung jalan di pintu", _dekat(ujung_pintu, PINTU, 0.15), str(ujung_pintu))
	_cek("ujung jalan di lajur jalan E-W (z~0)", absf(ujung_jalan.z) < 1.25 and absf(ujung_jalan.x + 5.6) < 0.3, str(ujung_jalan))
	# --- 3. Segmen lama hilang ---
	var segmen_lama := false
	for n in root.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var bm := mi.mesh as BoxMesh
		if bm != null and _dekat(bm.size, Vector3(3.0, 0.06, 2.5), 0.01) and _dekat(mi.position, Vector3(-1.0, 0.03, -6.5), 0.05):
			segmen_lama = true
	_cek("segmen lama (-1.0,-6.5) sudah hilang", not segmen_lama, "")
	# --- 4. Lampu ---
	var lampu_pos: Array[Vector3] = []
	for bulb in get_tree().get_nodes_in_group("LampuJalan"):
		lampu_pos.append((bulb as Node3D).get_parent().position)
	_cek("jumlah lampu tetap 8", lampu_pos.size() == 8, str(lampu_pos.size()))
	var ada_lama := false
	var ada_baru := false
	for p in lampu_pos:
		if _dekat(p, LAMPU_LAMA, 0.3):
			ada_lama = true
		if _dekat(p, LAMPU_BARU, 0.15):
			ada_baru = true
	_cek("lampu lama (-2.2,-6) sudah tidak ada", not ada_lama, "")
	_cek("lampu baru (-6.5,-7.5) ada", ada_baru, "")
	var d_pintu := LAMPU_BARU.distance_to(PINTU)
	var rel := LAMPU_BARU - PINTU
	var d_sumbu := absf(rel.x * masuk.z - rel.z * masuk.x)
	_cek("lampu baru 4.39 m dari pintu (dulu 1.47)", absf(d_pintu - 4.39) < 0.1, "%.2f" % d_pintu)
	_cek("lampu baru 3.99 m dari sumbu jalan (dulu 0.54)", absf(d_sumbu - 3.99) < 0.1, "%.2f" % d_sumbu)
	_cek("lampu baru 4.00 m dari titik keluar NPC", absf(LAMPU_BARU.distance_to(KELUAR) - 4.0) < 0.1, "%.2f" % LAMPU_BARU.distance_to(KELUAR))
	_cek("lampu baru 3.19 m dari Kyai", absf(LAMPU_BARU.distance_to(KYAI) - 3.19) < 0.1, "%.2f" % LAMPU_BARU.distance_to(KYAI))
	# Lampu baru di luar tapak Surau: koordinat lokal (putar +25 mengelilingi pusat (0,-12)).
	var lr := LAMPU_BARU - Vector3(0, 0, -12)
	var lx := lr.x * cos(deg_to_rad(25.0)) + lr.z * sin(deg_to_rad(25.0))
	var lz := -lr.x * sin(deg_to_rad(25.0)) + lr.z * cos(deg_to_rad(25.0))
	_cek("lampu baru di luar tapak Surau (lokal z>5)", lz > 5.0, "lokal (%.2f, %.2f)" % [lx, lz])
	# Semua lampu >= 2.7 m dari sumbu jalan (tengah jalan).
	var min_lampu := 999.0
	for p in lampu_pos:
		var r2 := p - PINTU
		var d2 := absf(r2.x * masuk.z - r2.z * masuk.x)
		min_lampu = minf(min_lampu, d2)
	_cek("semua lampu >= 2.7 m dari sumbu jalan", min_lampu >= 2.7, "min=%.2f" % min_lampu)
	# --- 5. Kyai ---
	var kyai: Node3D = _main._npcs[2] as Node3D # Bilal, Faris, Kyai
	_cek("Kyai tetap di serambi (-4.8,-4.8)", kyai != null and _dekat(kyai.global_position, KYAI, 0.1), str(kyai.global_position) if kyai else "?")
	var relk := KYAI - PINTU
	var d_kyai := absf(relk.x * masuk.z - relk.z * masuk.x)
	_cek("Kyai 1.31 m dari sumbu jalan (di luar tepi 1.25)", absf(d_kyai - 1.31) < 0.05, "%.2f" % d_kyai)
	# --- 6. Pohon: jarak ke SEGMEN jalan (bukan garis tak hingga) ---
	var a_seg: Vector3 = ujung_pintu
	var b_seg: Vector3 = ujung_jalan
	var min_pohon := 999.0
	for body in root.find_children("*", "StaticBody3D", true, false):
		for ch in (body as StaticBody3D).get_children():
			var cs := ch as CollisionShape3D
			if cs != null and cs.shape is CylinderShape3D:
				var cyl := cs.shape as CylinderShape3D
				if cyl.radius < 1.0:
					var dp := _jarak_titik_ke_segmen((body as StaticBody3D).position, a_seg, b_seg)
					min_pohon = minf(min_pohon, dp)
	_cek("semua pohon >= 2 m dari segmen jalan", min_pohon >= 2.0, "min=%.2f" % min_pohon)
	# --- 7. Penanda M1 (3,-6.5) tidak di jalan ---
	var m1 := Vector3(3.0, 0, -6.5)
	_cek("penanda M1 jauh dari segmen jalan", _jarak_titik_ke_segmen(m1, a_seg, b_seg) >= 3.0, "%.2f" % _jarak_titik_ke_segmen(m1, a_seg, b_seg))
	# --- 8. Rute NPC ke pintu tetap jalan ---
	var mulai_list: Array[Vector3] = [Vector3(0, 0, 2), Vector3(0, 0, -30), Vector3(-20, 0, 0), Vector3(20, 0, 20), Vector3(-4.8, 0, -4.8)]
	for dari in mulai_list:
		var rute: Array = _main._rute_ke_pintu_surau(dari)
		var akhir: Vector3 = rute[rute.size() - 1]
		_cek("rute NPC dari %s berakhir di titik keluar" % str(dari), _dekat(akhir, KELUAR, 0.05), str(akhir))
	var rel_exit := KELUAR - PINTU
	var d_exit := absf(rel_exit.x * masuk.z - rel_exit.z * masuk.x)
	_cek("titik keluar NPC ada DI ATAS jalan baru", d_exit < 0.05, "%.3f" % d_exit)
	# --- 9. Masuk Surau lewat jalan baru: jalan dari titik keluar ke pintu ---
	_main._player.global_position = KELUAR
	_main._player.velocity = Vector3.ZERO
	await get_tree().process_frame
	var masuk_ok := false
	for i in range(7):
		var v := 0.25 * float(i + 1)
		_main._player.global_position = PINTU + masuk * v
		_main._cek_pintu_surau()
		if _main._di_dalam:
			masuk_ok = true
			break
		await get_tree().process_frame
	_cek("pemain masuk Surau dengan jalan lurus dari titik keluar", masuk_ok, "")
	if _main._di_dalam:
		_main._keluar_surau()
		_cek("pemain bisa keluar lagi ke titik keluar", _dekat(_main._player.global_position, KELUAR, 0.1) and not _main._di_dalam, str(_main._player.global_position))
