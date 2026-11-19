extends Node
## Tes PERLUASAN AREA PUTRI (Mira, 18 Nov 2026 ~00:40 WIB — perintah Mas 00:28 WIB).
##   godot --headless --path . skrip/test_perluasan_putri.tscn
## Cek: Cangkruk Putri hilang total; tembok keliling baru x 115..216,
## z -70..+40 (konstanta + collision nyata via raycast); gerbang barat
## (115,0) TERTUTUP (barrier); tembok LAMA (x=180, z=-52, z=22) sudah
## tidak ada collision-nya; posisi v2 ACC (Kelas (130,10), Asrama
## (155,9 — P1 Nadia: pusat geser 152 -> 155 karena badan melebar ke timur), Kantor (148,-33), Pos Jaga (176,-20), Spawn (140,16));
## jalan internal diperpanjang z -35..+22; spawn putri di dalam tembok;
## pemain bisa jalan di area baru. Keluar: exit 0 bila semua lulus.

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


func _ray(dari: Vector3, ke: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(dari, ke)
	return get_tree().root.get_world_3d().direct_space_state.intersect_ray(q)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Uji sebagai santriwati: spawn otomatis (140,16) + jalan di dalam
	# kampus legal (putra di z<16 akan didorong balik _cek_batas — benar).
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes perluasan putri")
	print("DEBUG putri? ", _main._pemain_adalah_putri(),
		" pos awal: ", _main._player.global_position)
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()

	# --- 1. Konstanta tembok baru ---
	_cek("Tembok X_MIN 115", TembokPutri.KELILING_X_MIN == 115.0)
	_cek("Tembok X_MAX 216", TembokPutri.KELILING_X_MAX == 216.0)
	_cek("Tembok Z_MIN -70", TembokPutri.KELILING_Z_MIN == -70.0)
	_cek("Tembok Z_MAX 40", TembokPutri.KELILING_Z_MAX == 40.0)
	_cek("Gerbang putri tetap (115,0)",
		TembokPutri.GERBANG_PUTRI_POS.distance_to(Vector3(115, 0, 0)) < 0.01)
	var garis: Array = TembokPutri.KELILING_GARIS
	_cek("KELILING_GARIS 5 titik", garis.size() == 5)
	_cek("KELILING_GARIS sudut baru",
		garis[0] == Vector2(115, -70) and garis[1] == Vector2(216, -70)
		and garis[2] == Vector2(216, 40) and garis[3] == Vector2(115, 40))

	# --- 2. Cangkruk Putri hilang total ---
	var root: Node = _main._pesantren["root"]
	var kampus: Node = root.find_child("KampusPutri", true, false)
	_cek("KampusPutri ada", kampus != null)
	_cek("Node CangkrukPutri TIDAK ada",
		root.find_child("CangkrukPutri", true, false) == null)
	_cek("Dict tanpa kunci cangkruk_putri_pos",
		not _main._pesantren.has("cangkruk_putri_pos"))
	_cek("KonekCangkruk TIDAK ada",
		root.find_child("KonekCangkruk", true, false) == null)

	# --- 3. Posisi v2 ACC (dari dict builder) ---
	var d: Dictionary = _main._pesantren
	_cek("Kelas Putri (130,10)",
		(d["kelas_putri_pos"] as Vector3).distance_to(Vector3(130, 0, 10)) < 0.01)
	_cek("Asrama Putri (155,9) — P1: pusat 152 -> 155",
		(d["asrama_putri_pos"] as Vector3).distance_to(Vector3(155, 0, 9)) < 0.01)
	_cek("Kantor Ustadzah (148,-33)",
		(d["kantor_ustadzah_pos"] as Vector3).distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("Madrasah tetap (152,-12)",
		(d["madrasah_pos"] as Vector3).distance_to(Vector3(152, 0, -12)) < 0.01)
	_cek("Studio tetap (166,-12)",
		(d["studio_pos"] as Vector3).distance_to(Vector3(166, 0, -12)) < 0.01)
	_cek("Pos Jaga TL (176,-20)",
		(d["pos_jaga_tl"] as Vector3).distance_to(Vector3(176, 0, -20)) < 0.01)
	_cek("Spawn putri (140,16)",
		(d["spawn_putri"] as Vector3).distance_to(Vector3(140, 0, 16)) < 0.01)
	_cek("_spawn_putri main (140,16)",
		_main._spawn_putri.distance_to(Vector3(140, 0, 16)) < 0.01)
	_cek("Jalan internal x=142", d["jalan_internal_x"] == 142.0)

	# --- 4. Gedung di posisi baru — via mesh lantai (atap visual saja,
	# tanpa collision, jadi raycast fisik tidak bisa melihatnya) ---
	_cek("Lantai KelasPutri di (130,10)", _ada_mesh_di(kampus, Vector3(130, -0.05, 10)))
	_cek("Lantai AsramaPutri di (155,9)", _ada_mesh_di(kampus, Vector3(155, -0.05, 9)))
	_cek("Lantai KantorUstadzah di (148,-33)", _ada_mesh_di(kampus, Vector3(148, -0.05, -33)))
	_cek("Lantai Madrasah di (152,-12)", _ada_mesh_di(kampus, Vector3(152, -0.05, -12)))
	_cek("Lantai Studio di (166,-12)", _ada_mesh_di(kampus, Vector3(166, -0.05, -12)))
	_cek("Lantai Musholla di (134,-24)", _ada_mesh_di(kampus, Vector3(134, -0.05, -24)))
	_cek("Bekas Kelas lama (130,0) kosong", not _ada_mesh_di(kampus, Vector3(130, -0.05, 0)))
	_cek("Bekas Asrama lama (152,0) kosong", not _ada_mesh_di(kampus, Vector3(152, -0.05, 0)))
	_cek("Bekas Pos Jaga lama (160,-35) kosong", not _ada_mesh_di(kampus, Vector3(160, -0.05, -35)))
	_cek("Bekas lantai Cangkruk (128,-12) kosong — halaman di atasnya (Dewi, 18 Nov)",
		not _ada_mesh_di(kampus, Vector3(128, -0.05, -12)))
	_cek("Halaman pengganti ada: rumput di (122,0.03,32) — pindah ke pojok barat-daya (ronde 4, Dewi, 18 Nov)",
		_ada_mesh_di(kampus, Vector3(122, 0.03, 32)))
	_cek("Node PosJagaTL di (176,-20)",
		_get_pos(root, "PosJagaTL").distance_to(Vector3(176, 0, -20)) < 0.5)
	_cek("JalanUtama diperpanjang (pusat z -6.5)",
		abs(_get_pos(root, "JalanUtama").z - (-6.5)) < 0.5)
	_cek("KonekPosJaga ada (panjang 31 m)",
		root.find_child("KonekPosJaga", true, false) != null)
	_cek("KonekSpawn ada", root.find_child("KonekSpawn", true, false) != null)
	_cek("BarrierGerbangPutri ada",
		root.find_child("BarrierGerbangPutri", true, false) != null)
	# --- 5. Raycast collision tembok baru (dari dalam, y=1.5) ---
	var h: Dictionary = _ray(Vector3(150, 1.5, -40), Vector3(230, 1.5, -40))
	_cek("Tembok timur BARU menahan (hit x 210..216, bukan 180)",
		not h.is_empty() and (h["position"] as Vector3).x > 210.0
		and (h["position"] as Vector3).x < 216.0)
	h = _ray(Vector3(150, 1.5, -40), Vector3(100, 1.5, -40))
	_cek("Tembok barat menahan (hit x 115..116)",
		not h.is_empty() and (h["position"] as Vector3).x > 115.0
		and (h["position"] as Vector3).x < 116.0)
	h = _ray(Vector3(165, 1.5, -40), Vector3(165, 1.5, -80))
	_cek("Tembok utara BARU menahan (hit z -70..-69, bukan -52)",
		not h.is_empty() and (h["position"] as Vector3).z < -60.0
		and (h["position"] as Vector3).z > -70.0)
	h = _ray(Vector3(200, 1.5, 30), Vector3(200, 1.5, 50))
	_cek("Tembok selatan BARU menahan (hit z 39..40, bukan 22)",
		not h.is_empty() and (h["position"] as Vector3).z > 35.0
		and (h["position"] as Vector3).z < 40.0)
	h = _ray(Vector3(130, 1.5, 0), Vector3(100, 1.5, 0))
	_cek("Gerbang barat TERTUTUP (barrier hit x 115..116)",
		not h.is_empty() and (h["position"] as Vector3).x > 115.0
		and (h["position"] as Vector3).x < 116.0)

	# --- 6. Spawn di dalam tembok + pemain bisa jalan ---
	var sp: Vector3 = d["spawn_putri"]
	_cek("Spawn di dalam tembok baru",
		sp.x > 115.0 and sp.x < 216.0 and sp.z > -70.0 and sp.z < 40.0)
	# Pemain sudah di spawn putri (140,16) via _masuk_pesantren.
	_cek("Pemain spawn di (140,16)",
		_main._player.global_position.distance_to(Vector3(140, 0, 16)) < 1.0)
	_main._player.set_aksi("berdiri")
	for i in 3:
		await get_tree().process_frame
	print("DEBUG pos setelah teleport: ", _main._player.global_position)
	var a: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 10:
		await get_tree().process_frame
	print("DEBUG pos +10 frame: ", _main._player.global_position,
		" vel: ", _main._player.velocity)
	for i in 20:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	var b: Vector3 = _main._player.global_position
	print("DEBUG pos akhir: ", b)
	_cek("Pemain bisa jalan dari spawn putri (>0,5 m / 30 frame)",
		a.distance_to(b) > 0.5)
	_cek("Pemain tetap di dalam tembok setelah jalan",
		b.x > 115.0 and b.x < 216.0 and b.z > -70.0 and b.z < 40.0)

	print("HASIL PERLUASAN PUTRI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


func _get_pos(root: Node, nama: String) -> Vector3:
	var n := root.find_child(nama, true, false)
	if n == null:
		return Vector3(9999, 0, 9999)
	return (n as Node3D).global_position


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
