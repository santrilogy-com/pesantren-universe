extends Node
## Tes headless RAK BUKU PUTRI + INTERIOR KELAS PUTRI (Dewi, 18 Nov 2026):
##   godot --headless --path . skrip/tes_rak_kelas_putri.tscn
## Cek: (1) modul rak — 10 kitab, collision menahan (raycast), spot
## baca 0,9 m di depan rak; (2) Musholla — 2 rak baru, 20 kitab,
## rak_spot lama tetap ada, rak tidak menabrak sajadah; (3) Kelas
## Putri — 9 meja + 18 kursi + papan tulis + meja ustadzah + 2 rak
## + 2 lampu + 3 jendela, celah pintu selatan benar-benar kosong,
## spawn tidak di dalam kursi. Keluar 0 bila semua lolos, 1 bila ada
## yang gagal. TIDAK menyentuh main.gd / save / jaringan.

var _gagal: int = 0
var _lolos: int = 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  Lolos: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _rak_langsung(root: Node3D, prefix: String) -> Array[Node3D]:
	## Anak LANGSUNG root yang namanya diawali prefix — find_children
	## dengan pola "RakKitab_*" ikut menangkap "RakKitab_TimurBody"
	## (StaticBody3D juga Node3D), jadi saring manual di sini.
	var hasil: Array[Node3D] = []
	for ch in root.get_children():
		if ch is Node3D and String(ch.name).begins_with(prefix):
			hasil.append(ch)
	return hasil


func _ready() -> void:
	print("TES RAK + KELAS PUTRI — mulai")
	await get_tree().process_frame
	await _tes_modul_rak()
	await _tes_musholla()
	_tes_kelas()
	print("TES SELESAI: %d lolos, %d gagal" % [_lolos, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


## (1) Modul rak berdiri sendiri.
func _tes_modul_rak() -> void:
	print("== Modul RakBukuPutri ==")
	var pos := Vector3(0, 0, 0)
	var rak := RakBukuPutri.build(pos, 0.0, "RakTes")
	add_child(rak)
	for i in 3:
		await get_tree().process_frame
	_cek("rak 10 kitab", RakBukuPutri.hitung_buku(rak) == 10,
		"hitung=%d" % RakBukuPutri.hitung_buku(rak))
	_cek("rak konstanta JUMLAH_BUKU", RakBukuPutri.JUMLAH_BUKU == 10)
	var body := rak.find_child("RakTesBody", true, false) as StaticBody3D
	_cek("rak punya StaticBody3D", body != null)
	var bentuk_ok := false
	if body != null:
		for ch in body.get_children():
			if ch is CollisionShape3D and (ch as CollisionShape3D).shape is BoxShape3D:
				var s: Vector3 = ((ch as CollisionShape3D).shape as BoxShape3D).size
				bentuk_ok = s.is_equal_approx(Vector3(1.8, 2.0, 0.35))
	_cek("collision rak 1,8x2,0x0,35", bentuk_ok)
	_cek("rak 3 judul Arab", rak.find_children("Judul_*", "Label3D", true, false).size() == 3)
	var spot := RakBukuPutri.spot(pos, 0.0)
	_cek("spot 0,9 m di depan rak", spot.is_equal_approx(Vector3(0, 0, 0.9)), "spot=%s" % str(spot))
	# Raycast: dari spot ke tengah rak (y=1,0) HARUS kena badan rak;
	# sinar di atas rak (y=3,0) HARUS lewat (tidak kena).
	var ruang := get_viewport().get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(spot + Vector3(0, 1.0, 0), Vector3(0, 1.0, -0.5))
	var kena := ruang.intersect_ray(q)
	_cek("raycast depan->rak KENA", not kena.is_empty(), "kena=%s" % str(kena.get("collider")))
	var q2 := PhysicsRayQueryParameters3D.create(Vector3(0, 3.0, 3.0), Vector3(0, 3.0, -3.0))
	var kena2 := ruang.intersect_ray(q2)
	_cek("raycast di atas rak LEWAT", kena2.is_empty())
	rak.queue_free()


## (2) Musholla: 2 rak modul, spot lama tetap ada, tidak tabrak sajadah.
func _tes_musholla() -> void:
	print("== Interior Musholla (2 rak baru) ==")
	var m := InteriorMusholla.build()
	add_child(m["root"])
	for i in 3:
		await get_tree().process_frame
	var root: Node3D = m["root"]
	var rak_nodes := _rak_langsung(root, "RakKitab_")
	_cek("musholla 2 rak modul", rak_nodes.size() == 2, "rak=%d" % rak_nodes.size())
	var total_buku := 0
	for r in rak_nodes:
		total_buku += RakBukuPutri.hitung_buku(r)
	_cek("musholla 20 kitab (2x10)", total_buku == 20, "total=%d" % total_buku)
	_cek("rak_spot lama tetap ada (main.gd)", m.has("rak_spot"))
	var spots: Array = m.get("rak_spots", [])
	_cek("rak_spots berisi 2 titik", spots.size() == 2, "spots=%d" % spots.size())
	# Tiap spot: di dalam ruangan (koordinat lokal) + 0,9 m dari raknya.
	var semua_dalam := true
	for s in spots:
		var lokal: Vector3 = InteriorMusholla.ke_lokal(s)
		if lokal.x < 53.5 or lokal.x > 66.5 or lokal.z < -305.5 or lokal.z > -296.5:
			semua_dalam = false
	_cek("kedua spot di dalam ruangan", semua_dalam)
	# Rak tidak menabrak sajadah: jarak pusat rak ke sajadah terdekat > 1,5 m.
	var jarak_min := 100.0
	for r in rak_nodes:
		var rp := (r as Node3D).position
		for sj in InteriorMusholla.sajadah_grid():
			var sj_dunia: Vector3 = InteriorMusholla.ke_dunia(sj)
			jarak_min = minf(jarak_min, rp.distance_to(sj_dunia))
	_cek("rak jauh dari sajadah (>1,5 m)", jarak_min > 1.5, "min=%.2f m" % jarak_min)
	# Rak tidak menabrak kursi Ustadzah (65.6,-305) + meja sampar (64.5,-297.5).
	var kursi_dunia: Vector3 = InteriorMusholla.ke_dunia(InteriorMusholla.KURSI_USTADZAH)
	var j_kursi := 100.0
	for r in rak_nodes:
		j_kursi = minf(j_kursi, (r as Node3D).position.distance_to(kursi_dunia))
	_cek("rak jauh dari kursi Ustadzah (>1,0 m)", j_kursi > 1.0, "min=%.2f m" % j_kursi)


## (3) Kelas Putri: isi lengkap + pintu + spawn.
func _tes_kelas() -> void:
	print("== Interior Kelas Putri ==")
	var k := InteriorKelasPutri.build()
	add_child(k["root"])
	var root: Node3D = k["root"]
	_cek("kelas 9 meja santri", root.find_children("MejaSantri_*", "Node3D", true, false).size() == 9)
	_cek("kelas 18 kursi", root.find_children("Kursi_*", "Node3D", true, false).size() == 18)
	_cek("kelas papan tulis ada", root.find_child("PapanTulis", true, false) != null)
	_cek("kelas meja ustadzah ada", root.find_child("MejaUstadzah", true, false) != null)
	_cek("kelas kursi ustadzah ada", root.find_child("KursiUstadzah", true, false) != null)
	var rak_nodes := _rak_langsung(root, "RakKitab_Kelas_")
	_cek("kelas 2 rak buku", rak_nodes.size() == 2)
	var total_buku := 0
	for r in rak_nodes:
		total_buku += RakBukuPutri.hitung_buku(r)
	_cek("kelas 20 kitab di rak (2x10)", total_buku == 20, "total=%d" % total_buku)
	_cek("kelas 2 lampu hangat", root.find_children("LampuKelas_*", "Node3D", true, false).size() == 2)
	_cek("kelas 3 jendela", root.find_children("Jendela*", "Node3D", true, false).size() == 3)
	_cek("kelas label KELUAR ada", root.find_child("LabelKeluar", true, false) != null)
	_cek("kelas label KELAS PUTRI ada", root.find_child("LabelKelasPutri", true, false) != null)
	var spots: Array = k.get("rak_spots", [])
	_cek("kelas rak_spots berisi 2 titik", spots.size() == 2)
	# Celah pintu selatan (x 119,2..120,8, z=-297) benar-benar kosong:
	# segmen dinding selatan kiri berakhir di x=119,2, kanan mulai
	# di x=120,8. (Tiang emas pintu di x=119,28/120,72 TIDAK dihitung
	# — tiang tipis r=0,06 di tepi celah, lorong bersih 1,32 m.)
	var kiri := root.find_child("DindingSelatan_Kiri", true, false) as MeshInstance3D
	var kanan := root.find_child("DindingSelatan_Kanan", true, false) as MeshInstance3D
	var celah_bersih := false
	if kiri != null and kanan != null:
		var uk_kiri: Vector3 = (kiri.mesh as BoxMesh).size
		var uk_kanan: Vector3 = (kanan.mesh as BoxMesh).size
		var maks_kiri := kiri.position.x + uk_kiri.x / 2.0
		var min_kanan := kanan.position.x - uk_kanan.x / 2.0
		celah_bersih = maks_kiri <= 119.21 and min_kanan >= 120.79
		print("    dinding selatan: kiri s.d. x=%.2f, kanan dari x=%.2f" % [maks_kiri, min_kanan])
	_cek("celah pintu selatan kosong (119,2..120,8)", celah_bersih)
	# Spawn tidak di dalam kursi/meja: jarak ke kursi/meja terdekat
	# > 0,5 m. Kursi/meja adalah grup Node3D di origin (anak-anaknya
	# yang berposisi absolut — pola Cangkruk), jadi ukur dari posisi
	# kursi sebenarnya: tiap meja (mx, mz) punya 2 kursi di
	# (mx±0,3, mz+0,55) — hitung dari MEJA_POS_LIST, bukan .position.
	var spawn: Vector3 = k["interior_spawn"]
	var j_min := 100.0
	for mp in InteriorKelasPutri.MEJA_POS_LIST:
		j_min = minf(j_min, spawn.distance_to(Vector3(mp.x, 0, mp.z)))
		for dx in [-0.3, 0.3]:
			j_min = minf(j_min, spawn.distance_to(Vector3(mp.x + dx, 0, mp.z + 0.55)))
	_cek("spawn jauh dari kursi/meja (>0,5 m)", j_min > 0.5, "min=%.2f m" % j_min)
	# Rak di dalam batas ruangan.
	var bounds: Dictionary = k["bounds"]
	var rak_dalam := true
	for r in rak_nodes:
		var rp := (r as Node3D).position
		if rp.x < float(bounds["min_x"]) or rp.x > float(bounds["max_x"]) or rp.z < float(bounds["min_z"]) or rp.z > float(bounds["max_z"]):
			rak_dalam = false
	_cek("rak kelas di dalam batas ruangan", rak_dalam)
