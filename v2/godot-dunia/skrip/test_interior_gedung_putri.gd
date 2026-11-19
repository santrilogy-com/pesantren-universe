extends Node
## Tes INTERIOR GEDUNG PUTRI (Lestari, Tim Area Putri, 18 Nov 2026) — headless:
##   godot --headless --path . skrip/test_interior_gedung_putri.tscn
## JANGAN edit skrip/test_v2.gd (Rangga + Gilang mengeditnya paralel).
##
## Isi: (A) struktur — keempat gedung terbangun, node perabot yang
## diminta ada, tiap perabot punya StaticBody3D + shape valid.
## (B) geometri anti-tembus — titik spawn bersih dari AABB perabot,
## koridor pintu->spawn bersih, semua perabot di dalam bounds ruangan,
## keempat bounds tidak saling tumpang tindih. (C) FISIKA — probe
## CharacterBody3D (kapsul r=0,35): test_move ke arah meja/lemari
## HARUS tertahan (true), test_move keluar lewat pintu HARUS bebas
## (false). Pola AABB mengikuti test_kasur.gd; probe mengikuti
## test_tabrakan_dunia.gd (test_move, bukan gerak sungguhan).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	var kantor: Dictionary = InteriorGedungPutri.build_kantor()
	var madrasah: Dictionary = InteriorGedungPutri.build_madrasah()
	var studio: Dictionary = InteriorGedungPutri.build_studio()
	var pos: Dictionary = InteriorGedungPutri.build_pos_jaga()
	add_child(kantor["root"])
	add_child(madrasah["root"])
	add_child(studio["root"])
	add_child(pos["root"])
	for i in 5:
		await get_tree().process_frame
		await get_tree().physics_frame
	_tes_struktur(kantor, madrasah, studio, pos)
	_tes_geometri(kantor, madrasah, studio, pos)
	await _tes_fisika(kantor, madrasah, studio, pos)
	print("TES INTERIOR GEDUNG PUTRI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


# ---------- (A) struktur ----------
func _tes_struktur(kantor: Dictionary, madrasah: Dictionary, studio: Dictionary, pos: Dictionary) -> void:
	var harap: Dictionary = {
		"kantor": [["MejaKerja", "KursiKerja", "LemariArsip", "RakBuku", "PapanPengumuman", "LampuKantor", "JendelaUtara", "JendelaSelatan", "LabelKeluar", "Lantai", "Plafon"], kantor],
		"madrasah": [["PapanTulis", "MejaGuru", "KursiGuru", "MejaMurid1", "MejaMurid2", "KursiMurid1", "KursiMurid2", "LemariMadrasah", "RakBuku", "LampuMadrasah", "JendelaUtara", "JendelaSelatan", "LabelKeluar", "Lantai", "Plafon"], madrasah],
		"studio": [["MejaKerja", "KursiKerja", "MejaKerja2", "KursiKerja2", "RakPeralatan", "PapanStudio", "LampuStudio", "JendelaTimur", "JendelaBarat", "LabelKeluar", "Lantai", "Plafon"], studio],
		"pos": [["MejaJaga", "KursiJaga", "LemariKecil", "PapanJadwalJaga", "LampuPosJaga", "LabelKeluar", "Lantai", "Plafon"], pos],
	}
	for kunci in harap.keys():
		var nama_list: Array = harap[kunci][0]
		var d: Dictionary = harap[kunci][1]
		var root: Node3D = d["root"]
		_cek("%s: root bernama benar" % kunci, root.name.begins_with("Interior"))
		_cek("%s: dict punya door+spawn+bounds" % kunci, d.has("interior_door") and d.has("interior_spawn") and d.has("bounds"))
		for nama in nama_list:
			_cek("%s: node %s ada" % [kunci, nama], root.find_child(nama, true, false) != null)
	# Tiap perabot (Meja/Kursi/Lemari/Rak/Papan) punya StaticBody3D +
	# shape valid (kotak > 0) — tanpa ini perabot bisa ditembus.
	var perabot_nama: Array = ["Meja", "Kursi", "Lemari", "Rak", "Papan"]
	for kunci in harap.keys():
		var d: Dictionary = harap[kunci][1]
		var root: Node3D = d["root"]
		for anak in root.get_children():
			var nm := String(anak.name)
			var perlu := false
			for aw in perabot_nama:
				if nm.begins_with(aw):
					perlu = true
			if not perlu:
				continue
			var badan := (anak as Node).find_children("*", "StaticBody3D", true, false)
			var ok := false
			for b in badan:
				for cs in (b as Node).find_children("*", "CollisionShape3D", true, false):
					var shp := (cs as CollisionShape3D).shape
					if shp is BoxShape3D and (shp as BoxShape3D).size.x > 0.0 and (shp as BoxShape3D).size.y > 0.0 and (shp as BoxShape3D).size.z > 0.0:
						ok = true
			_cek("%s: %s punya collision kotak valid" % [kunci, nm], ok)


# ---------- (B) geometri anti-tembus ----------
func _tes_geometri(kantor: Dictionary, madrasah: Dictionary, studio: Dictionary, pos: Dictionary) -> void:
	var semua: Array = [kantor, madrasah, studio, pos]
	var nama_ruang: Array = ["kantor", "madrasah", "studio", "pos"]
	# Bounds keempat ruangan tidak saling tumpang tindih (map terpisah).
	for a in range(4):
		for b in range(a + 1, 4):
			var ba: Dictionary = semua[a]["bounds"]
			var bb: Dictionary = semua[b]["bounds"]
			var tumpang := float(ba["min_x"]) < float(bb["max_x"]) and float(ba["max_x"]) > float(bb["min_x"]) and float(ba["min_z"]) < float(bb["max_z"]) and float(ba["max_z"]) > float(bb["min_z"])
			_cek("bounds %s vs %s tidak tumpang tindih" % [nama_ruang[a], nama_ruang[b]], not tumpang)
	for i in range(4):
		var d: Dictionary = semua[i]
		var kunci: String = nama_ruang[i]
		var root: Node3D = d["root"]
		var rint := _kumpulkan_rintangan(root)
		# Dinding + ambang pintu dikeluarkan dari cek furnitur: dinding
		# memang menumpang 0,125 m di luar garis bounds (tebal 0,25,
		# pusat di garis bounds — sama seperti InteriorCangkruk) dan
		# koridor pintu tentu saja menyentuh segmen dinding di tepinya.
		var rint_furnitur: Array = []
		for r in rint:
			var nm := String(r[0])
			if nm.begins_with("Dinding") or nm.begins_with("AmbangPintu"):
				continue
			rint_furnitur.append(r)
		var spawn: Vector3 = d["interior_spawn"]
		var door: Vector3 = d["interior_door"]
		var bounds: Dictionary = d["bounds"]
		# Spawn bersih (badan 0,7 m + margin 0,1) dari semua perabot.
		var bentur_spawn := _bentur_pertama(spawn, rint_furnitur, "")
		_cek("%s: spawn bersih dari perabot" % kunci, bentur_spawn == "")
		if bentur_spawn != "":
			print("  bentur spawn %s: %s" % [kunci, bentur_spawn])
		# Koridor pintu -> spawn bersih (lebar koridor = lebar pintu).
		var bentur_koridor := _bentur_koridor(door, spawn, rint_furnitur)
		_cek("%s: koridor pintu->spawn bersih" % kunci, bentur_koridor == "")
		if bentur_koridor != "":
			print("  bentur koridor %s: %s" % [kunci, bentur_koridor])
		# Semua perabot di dalam bounds ruangan — inset 0,09 m dari
		# garis bounds (garis bounds = TENGAH dinding; muka dalam
		# dinding 0,125 m di dalamnya; bingkai jendela yang menempel
		# di muka dinding masuk 0,03 m ke dinding jadi lolos inset
		# 0,09 — tapi perabot yang TENGGELAM di dinding, seperti
		# papan Studio di -295,95 (18 Nov), ketangkap di sini).
		var keluar_bounds := ""
		for r in rint_furnitur:
			var gab: AABB = r[2]
			if gab.position.x < float(bounds["min_x"]) + 0.09 or gab.end.x > float(bounds["max_x"]) - 0.09 or gab.position.z < float(bounds["min_z"]) + 0.09 or gab.end.z > float(bounds["max_z"]) - 0.09:
				keluar_bounds = "%s AABB %s" % [String(r[0]), str(gab)]
				break
		_cek("%s: semua perabot di dalam bounds" % kunci, keluar_bounds == "")
		if keluar_bounds != "":
			print("  keluar bounds %s: %s" % [kunci, keluar_bounds])


## Kumpulkan AABB dunia perabot yang bisa ditabrak badan (pola
## test_kasur.gd): lewati lantai/karpet/plafon, yang alasnya di bawah
## badan (top < 0,25) dan yang melayang di atas badan (alas > 1,2).
func _kumpulkan_rintangan(root: Node3D) -> Array:
	var hasil: Array = []
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		var nama := String(m.name)
		if "Lantai" in nama or "Karpet" in nama or "Plafon" in nama or "Trim" in nama:
			continue
		var gab: AABB = m.global_transform * m.get_aabb()
		if gab.end.y < 0.25 or gab.position.y > 1.2:
			continue
		var induk := ""
		var ortu := m.get_parent()
		if ortu != null:
			induk = String(ortu.name)
		hasil.append([nama, induk, gab])
	return hasil


## Nama rintangan pertama yang bersentuhan dengan badan di `pusat`
## (badan 0,7 x 0,7 m + margin 0,1) — "" bila bersih.
func _bentur_pertama(pusat: Vector3, rintangan: Array, kecuali_induk: String) -> String:
	var x0 := pusat.x - 0.45
	var x1 := pusat.x + 0.45
	var z0 := pusat.z - 0.45
	var z1 := pusat.z + 0.45
	for r in rintangan:
		if kecuali_induk != "" and String(r[1]) == kecuali_induk:
			continue
		var gab: AABB = r[2]
		if x0 < gab.end.x and x1 > gab.position.x and z0 < gab.end.z and z1 > gab.position.z:
			return "%s (induk %s, AABB %s)" % [String(r[0]), String(r[1]), str(gab)]
	return ""


## Koridor lurus pintu -> spawn (lebar 1,6 m, 1,2 m untuk pos):
## tidak boleh ada perabot yang memotong jalur masuk.
func _bentur_koridor(door: Vector3, spawn: Vector3, rintangan: Array) -> String:
	var setengah := 0.8
	if absf(door.x - 178.5) < 0.01:
		setengah = 0.6 # Pos Jaga: pintu 1,2 m (bukan 1,6 m)
	var x0 := minf(door.x, spawn.x) - setengah
	var x1 := maxf(door.x, spawn.x) + setengah
	var z0 := minf(door.z, spawn.z) - setengah
	var z1 := maxf(door.z, spawn.z) + setengah
	# Koridor hanya sepanjang sumbu gerak (sisi lainnya = lebar pintu).
	if absf(spawn.x - door.x) > absf(spawn.z - door.z):
		z0 = door.z - setengah
		z1 = door.z + setengah
	else:
		x0 = door.x - setengah
		x1 = door.x + setengah
	for r in rintangan:
		var gab: AABB = r[2]
		if x0 < gab.end.x and x1 > gab.position.x and z0 < gab.end.z and z1 > gab.position.z:
			return "%s (induk %s, AABB %s)" % [String(r[0]), String(r[1]), str(gab)]
	return ""


# ---------- (C) fisika: test_move kapsul ----------
func _buat_probe() -> CharacterBody3D:
	var b := CharacterBody3D.new()
	b.name = "ProbeBadan"
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.7
	col.shape = cap
	# Dasar kapsul y=0,03 — 0,01 m DI ATAS lantai (puncak lantai
	# y=0,02). Kalau dasar kapsul di y=0, test_move selalu tertahan
	# karena kapsul terbenam 0,02 m di lantai (jebakan ronde ini).
	col.position = Vector3(0, 0.88, 0)
	b.add_child(col)
	add_child(b)
	return b


func _tes_fisika(kantor: Dictionary, madrasah: Dictionary, studio: Dictionary, pos: Dictionary) -> void:
	var probe := _buat_probe()
	for i in 5:
		await get_tree().physics_frame
	# [nama, posisi probe, arah gerak, jarak, harap_tertahan]
	var kasus: Array = [
		["kantor meja", Vector3(-118.25, 0, -300), Vector3(1, 0, 0), 1.0, true],
		["kantor pintu", Vector3(-123.0, 0, -300), Vector3(-1, 0, 0), 1.2, false],
		["madrasah meja guru", Vector3(-175.55, 0, -300.9), Vector3(0, 0, -1), 1.0, true],
		["madrasah pintu", Vector3(-184.0, 0, -300), Vector3(-1, 0, 0), 1.2, false],
		["studio meja", Vector3(242.75, 0, -301.0), Vector3(1, 0, 0), 1.0, true],
		["studio pintu", Vector3(240, 0, -303.0), Vector3(0, 0, -1), 1.2, false],
		["pos lemari", Vector3(180.0, 0, -299.3), Vector3(1, 0, 0), 1.0, true],
		["pos pintu", Vector3(179.6, 0, -300), Vector3(-1, 0, 0), 1.2, false],
	]
	for k in kasus:
		var nama: String = k[0]
		probe.global_position = k[1]
		for i in 2:
			await get_tree().physics_frame
		var tertahan := probe.test_move(probe.global_transform, (k[2] as Vector3) * float(k[3]))
		_cek("fisika %s: %s" % [nama, "tertahan" if bool(k[4]) else "bebas"], tertahan == bool(k[4]))
	probe.queue_free()
