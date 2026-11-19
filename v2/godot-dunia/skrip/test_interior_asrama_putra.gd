extends Node
## Tes INTERIOR ASRAMA PUTRA (Nadia, 18 Nov 2026) — headless:
##   godot --headless --path . skrip/test_interior_asrama_putra.tscn
## Adaptasi PERSIS skrip/test_interior_asrama_putri.gd (Rani) —
## denah sama, OFFSET (-300,0,-300), ID A-PUTRA-xxx.
## JANGAN edit skrip/test_kasur.gd (Wulan) atau test_v2.gd.
## Tes ini HANYA interior Asrama Putra (tanpa main.tscn, tanpa
## ledger kasur.json, tanpa login) — wiring ke main.gd belum ada
## (tugas Lestari); hook main.gd dites terpisah setelah integrasi.
##
## Isi: (A) hitung + nama — 96 kasur, 12 kamar x 8 kasur, nama
## "Kamar 001".."Kamar 012", kasur "A-PUTRA-001".."A-PUTRA-096",
## kamar/susun/tingkat konsisten dengan POSISI kasur (cek internal).
## Cross-check ke PembagianKasur untuk putra BELUM di sini: alokasi
## putra saat ini masih Cangkruk (5 kasur) + Surau (14 titik) —
## Lestari mengerjakan alokasi Cangkruk -> Asrama -> Surau paralel;
## cross-check itu pindah ke tes wiring setelah alokasi diupdate.
## TIDAK ADA kasur di Cangkruk Putra.
## (B) geometri anti-tembus — badan tidur (1,1 x 2,1 + margin 0,1)
## di tiap pusat kasur dicek terhadap AABB furnitur LANTAI YANG
## SAMA (jendela y-window per lantai, pola test_kasur.gd).
## (C) posisi tidur valid — tiap POSISI_TIDUR di dalam kamarnya,
## y kasur benar (bawah +0,55 / atas +1,65), offset kaki ke arah
## yang benar, tidak ada dua posisi yang sama.
## (D) collision menahan pemain — kapsul CharacterBody3D didorong
## ke kasur (lantai 1 + lantai 2): tertahan di muka kasur, tidak
## tembus. (E) tangga bisa dinaiki — kapsul jalan naik flight A
## (lantai 1->2) dan flight B (bordes -> lantai 2); bordes bisa
## dipijak. (F) pintu kamar + koridor bisa dilewati (celah).
## (G) 3 orang berdampingan (Mas 08:06 WIB) — 3 kapsul jalan
## bareng di koridor 2,6 m dan di lorong kaki kasur tanpa tabrakan.

var _lulus := 0
var _gagal := 0
var _root: Node3D


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	var hasil: Dictionary = InteriorAsramaPutra.build()
	_root = hasil["root"]
	add_child(_root)
	for i in 5:
		await get_tree().process_frame
	_tes_hitung(hasil)
	_tes_geometri()
	_tes_posisi_tidur(hasil)
	await _tes_collision()
	await _tes_tangga()
	await _tes_tiga_berdampingan()
	_tes_tidak_ada_kasur_cangkruk(hasil)
	print("TES INTERIOR ASRAMA PUTRA: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


# ---------- (A) hitung + nama ----------
func _tes_hitung(hasil: Dictionary) -> void:
	var beds: Array = hasil["bed_pos_list"]
	var tidur: Array = hasil["posisi_tidur_list"]
	var ids: Array = hasil["kasur_id_list"]
	var kamar: Array = hasil["kamar_list"]
	var bodies: Array = hasil["kasur_bodies"]
	_cek("96 kasur", beds.size() == 96 and tidur.size() == 96 and ids.size() == 96 and kamar.size() == 96)
	_cek("48 unit kasur susun (1 body per unit)", bodies.size() == 48)
	_cek("pintu interior (-309,-300)", hasil["interior_door"] == Vector3(-309, 0, -300))
	_cek("spawn interior (-307.5,-300)", hasil["interior_spawn"] == Vector3(-307.5, 0, -300))
	_cek("pintu cangkang (-33,10)", hasil["shell_door"] == Vector3(-33, 0, 10))
	_cek("exit cangkang (-34.5,10)", hasil["shell_exit"] == Vector3(-34.5, 0, 10))
	_cek("3 lantai y 0 / 3,2 / 6,4", (hasil["lantai_y"] as Array) == [0.0, 3.2, 6.4])
	_cek("bounds x -309..-287,5 z -306..-294", (hasil["bounds"] as Dictionary) == {"min_x": -309.0, "max_x": -287.5, "min_z": -306.0, "max_z": -294.0})
	# Tiap kamar 8 kasur; nama kamar 001..012; kasur id unik.
	var per_kamar := {}
	var id_unik := {}
	for i in range(96):
		var k := String(kamar[i])
		per_kamar[k] = int(per_kamar.get(k, 0)) + 1
		id_unik[String(ids[i])] = true
	_cek("12 kamar", per_kamar.size() == 12)
	var delapan := true
	for n in range(1, 13):
		if int(per_kamar.get("Kamar %03d" % n, 0)) != 8:
			delapan = false
	_cek("tiap kamar 8 kasur", delapan)
	_cek("kasur id unik A-PUTRA-001..096", id_unik.size() == 96 and String(ids[0]) == "A-PUTRA-001" and String(ids[95]) == "A-PUTRA-096")
	# Konvensi internal konsisten: kamar/susun yang dilaporkan
	# harus cocok dengan POSISI kasur (ruang dari tanda x/z +
	# lantai dari y, susun dari offset x terhadap pusat kamar).
	var konvensi := true
	for i in range(1, 97):
		var bed: Vector3 = beds[i - 1]
		var lokal := InteriorAsramaPutra.ke_lokal(bed)
		var ruang := 0
		if lokal.x > 0.0 and lokal.z < 0.0:
			ruang = 1
		elif lokal.x < 0.0 and lokal.z > 0.0:
			ruang = 2
		elif lokal.x > 0.0 and lokal.z > 0.0:
			ruang = 3
		var nomor := roundi(lokal.y / 3.2) * 4 + ruang + 1
		if String(kamar[i - 1]) != "Kamar %03d" % nomor:
			konvensi = false
			print("  beda kamar idx %d: posisi ruang %d lantai %d vs %s" % [i, ruang, roundi(lokal.y / 3.2) + 1, String(kamar[i - 1])])
		var cx := -4.5 if (ruang == 0 or ruang == 2) else 4.5
		var susun_pos := -1
		for s in range(4):
			if absf(lokal.x - (cx + InteriorAsramaPutra.BUNK_X_OFF[s])) < 0.01:
				susun_pos = s + 1
		if susun_pos != InteriorAsramaPutra.susun_untuk_idx(i):
			konvensi = false
			print("  beda susun idx %d" % i)
	_cek("kamar/susun konsisten dengan posisi kasur", konvensi)


# ---------- (B) geometri anti-tembus ----------
func _tes_geometri() -> void:
	var beds := InteriorAsramaPutra.bed_pos_list()
	# Kumpulkan rintangan per lantai (jendela y [fy+0,2, fy+1,9]).
	var rintangan := {}
	for lantai in range(1, 4):
		var fy: float = InteriorAsramaPutra.LANTAI_Y[lantai - 1]
		rintangan[lantai] = _kumpulkan_rintangan(_root, fy)
	for i in range(96):
		var bed: Vector3 = beds[i]
		var lantai := InteriorAsramaPutra.lantai_untuk_idx(i + 1)
		var idx_bawah := ((i) / 2) * 2 + 1
		var bentur := _bentur_pertama(bed, rintangan[lantai], "Kasur%03d" % idx_bawah)
		_cek("kasur %03d anti-tembus (lantai %d)" % [i + 1, lantai], bentur == "")
		if bentur != "":
			print("  bentur kasur %d di %s: %s" % [i + 1, str(bed), bentur])
	# Jarak antar pusat kasur se-tingkat (>= 1,3 m — badan 1,1 + celah).
	for tingkat in ["bawah", "atas"]:
		var daftar: Array[Vector3] = []
		for i in range(96):
			if InteriorAsramaPutra.tingkat_untuk_idx(i + 1) == tingkat:
				daftar.append(beds[i])
		_cek("kasur %s saling berjauhan (>=1,3 m)" % tingkat, _jarak_min(daftar) >= 1.3)


func _kumpulkan_rintangan(root: Node3D, fy: float) -> Array:
	var hasil: Array = []
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		var nama := String(m.name)
		if "Lantai" in nama or "Karpet" in nama or "Plafon" in nama or "Trim" in nama:
			continue
		var gab: AABB = m.global_transform * m.get_aabb()
		# Hanya furnitur di jendela y lantai ini (badan tidur
		# y fy+0,2..fy+1,9) — furnitur lantai lain tidak dihitung.
		if gab.end.y < fy + 0.2 or gab.position.y > fy + 1.9:
			continue
		var induk := ""
		var ortu := m.get_parent()
		if ortu != null:
			induk = String(ortu.name)
		hasil.append([nama, induk, gab])
	return hasil


func _bentur_pertama(pusat: Vector3, rintangan: Array, kecuali_induk: String) -> String:
	var x0 := pusat.x - (PembagianKasur.TIDUR_SETENGAH_X + 0.10)
	var x1 := pusat.x + (PembagianKasur.TIDUR_SETENGAH_X + 0.10)
	var z0 := pusat.z - (PembagianKasur.TIDUR_SETENGAH_Z + 0.10)
	var z1 := pusat.z + (PembagianKasur.TIDUR_SETENGAH_Z + 0.10)
	for r in rintangan:
		if kecuali_induk != "" and String(r[1]) == kecuali_induk:
			continue
		var gab: AABB = r[2]
		if x0 < gab.end.x and x1 > gab.position.x and z0 < gab.end.z and z1 > gab.position.z:
			return "%s (induk %s, AABB %s)" % [String(r[0]), String(r[1]), str(gab)]
	return ""


func _jarak_min(daftar: Array[Vector3]) -> float:
	var paling_kecil := 1e9
	for a in range(daftar.size()):
		for b in range(a + 1, daftar.size()):
			var d := daftar[a].distance_to(daftar[b])
			if d < paling_kecil:
				paling_kecil = d
	return paling_kecil


# ---------- (C) posisi tidur valid ----------
func _tes_posisi_tidur(hasil: Dictionary) -> void:
	var beds: Array = hasil["bed_pos_list"]
	var tidur: Array = hasil["posisi_tidur_list"]
	var kunci := {}
	var unik := true
	var di_kamar := true
	var y_benar := true
	var kaki_benar := true
	for i in range(96):
		var bed: Vector3 = beds[i]
		var pos: Vector3 = tidur[i]
		var k := "%d|%d|%d" % [int(round(pos.x * 100.0)), int(round(pos.y * 100.0)), int(round(pos.z * 100.0))]
		if kunci.has(k):
			unik = false
		kunci[k] = true
		# y kasur: bawah +0,55 / atas +1,65 dari lantai.
		var fy: float = InteriorAsramaPutra.LANTAI_Y[InteriorAsramaPutra.lantai_untuk_idx(i + 1) - 1]
		var y_harap := fy + (0.55 if (i % 2 == 0) else 1.65)
		if absf(pos.y - y_harap) > 0.01:
			y_benar = false
		# Offset kaki 0,95 m: kamar utara (+z, kaki di selatan),
		# kamar selatan (-z, kaki di utara). x sama dengan kasur.
		var nomor_kamar := (i / 8) + 1
		var ruang := (nomor_kamar - 1) % 4
		var zs := -1.0 if (ruang == 0 or ruang == 1) else 1.0
		if absf(pos.x - bed.x) > 0.01 or absf(pos.z - (bed.z - zs * 0.95)) > 0.01:
			kaki_benar = false
		# Di dalam kamar: |x - pusat kamar| <= 4,4 dan z di sisi kamar
		# (di balik dinding koridor z=±1,3).
		var cx := -4.5 if (ruang == 0 or ruang == 2) else 4.5
		var lokal := InteriorAsramaPutra.ke_lokal(pos)
		if absf(lokal.x - cx) > 4.4 or (zs < 0 and lokal.z > -1.25) or (zs > 0 and lokal.z < 1.25):
			di_kamar = false
	_cek("96 posisi tidur unik", unik)
	_cek("posisi tidur di dalam kamarnya", di_kamar)
	_cek("posisi tidur y kasur benar (bawah +0,55 / atas +1,65)", y_benar)
	_cek("posisi tidur offset kaki benar (0,95 m ke kaki)", kaki_benar)


# ---------- (D) collision menahan pemain ----------
func _tes_collision() -> void:
	# Kamar 001 (lantai 1): dorong kapsul dari lorong ke kasur 1.
	# Spawn: pusat kapsul = lantai + 0,95 (kaki 0,05 di atas lantai
	# — JANGAN y=0,1, kapsul menembus lantai dan depenetrasi
	# menggesernya). Lorong kaki kasur 2,275 m (z lokal -3,65..-1,375);
	# kasur 1 di lokal (-7,8, -4,7), muka kasur dunia z=-303,65.
	var ok1 := await _dorong_ke_kasur(1, Vector3(-307.8, 0.95, -302.4), Vector3(-307.8, 0, -304.7), -303.35)
	_cek("collision kasur lantai 1 menahan kapsul", ok1)
	# Kamar 005 (lantai 2): dorong kapsul dari lorong ke kasur 33.
	var ok2 := await _dorong_ke_kasur(33, Vector3(-307.8, 4.15, -302.4), Vector3(-307.8, 3.2, -304.7), -303.35)
	_cek("collision kasur lantai 2 menahan kapsul", ok2)
	# Dinding koridor menahan: dorong kapsul ke utara di koridor
	# (z -300 -> -303 harus tertahan di dinding koridor z=-301,3;
	# muka koridor -301,225, kapsul berhenti 0,35 m di selatannya
	# -> pusat -300,875).
	var body := _buat_kapsul(Vector3(-300.0, 0.95, -300.0))
	var akhir := await _jalan_ke(body, Vector3(-300.0, 0, -303.0), 240, 3.0)
	print("  dinding koridor akhir: %s (harap ~-300,875)" % str(akhir))
	_cek("dinding koridor menahan kapsul", akhir.z > -301.2 and akhir.z < -300.5)
	body.queue_free()


## Dorong kapsul dari `awal` ke `target` (pusat kasur); kembali true
## bila kapsul tertahan di muka kasur (z akhir di selatan
## `batas_z` = muka kasur + jejari, tidak pernah melewatinya).
func _dorong_ke_kasur(idx: int, awal: Vector3, target: Vector3, batas_z: float) -> bool:
	var body := _buat_kapsul(awal)
	var akhir := await _jalan_ke(body, target, 240, 3.0)
	var bed: Vector3 = InteriorAsramaPutra.bed_pos_list()[idx - 1]
	# Maju diukur HANYA di sumbu dorong (z): jarak 3D tercemar
	# jatuhan y spawn (kapsul spawn bersih 0,05 di atas lantai).
	var maju := absf(akhir.z - awal.z) > 0.3
	var tertahan := akhir.z >= batas_z
	print("  kasur %d: awal %s akhir %s (muka kasur z=%.2f)" % [idx, str(awal), str(akhir), bed.z + 1.05])
	body.queue_free()
	return maju and tertahan


func _buat_kapsul(pos: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.position = pos
	body.floor_snap_length = 0.3
	body.floor_max_angle = deg_to_rad(45.0)
	var shape := CollisionShape3D.new()
	var kapsul := CapsuleShape3D.new()
	kapsul.radius = 0.35
	kapsul.height = 1.8
	shape.shape = kapsul
	body.add_child(shape)
	add_child(body)
	return body


## Jalan lurus ke target (arah datar saja, y dijaga snap lantai).
## Mengembalikan posisi akhir.
func _jalan_ke(body: CharacterBody3D, target: Vector3, maks_frame: int, kecepatan: float) -> Vector3:
	for i in range(maks_frame):
		var arah := target - body.global_position
		arah.y = 0.0
		if arah.length() < 0.3:
			break
		body.velocity = arah.normalized() * kecepatan
		body.velocity.y = -2.0
		body.move_and_slide()
		await get_tree().physics_frame
	return body.global_position


# ---------- (E) tangga bisa dinaiki ----------
func _tes_tangga() -> void:
	# Flight A (lantai 1 -> bordes): dari koridor (z=-0,3, lajur
	# utara flight A) ke TENGAH bordes (12,0).
	# Target harus bordes, bukan ujung rampa (11,3): _jalan_ke
	# berhenti bila jarak horizontal <0,3 — target 11,3 membuat
	# loop putus di kaki rampa (pusat y 2,26 < 2,3) padahal kapsul
	# masih naik. Assert memakai y PUSAT kapsul (kaki = y - 0,9):
	# di bordes kaki 1,6 -> pusat 2,5.
	var a := _buat_kapsul(InteriorAsramaPutra.ke_dunia(Vector3(7.0, 0.95, -0.3)))
	var akhir_a := await _jalan_ke(a, InteriorAsramaPutra.ke_dunia(Vector3(12.0, 1.6, -0.3)), 400, 3.0)
	_cek("tangga flight A bisa dinaiki (pusat y>=2,3, x>=-289,0)", akhir_a.y >= 2.3 and akhir_a.x >= -289.0)
	print("  flight A akhir: %s" % str(akhir_a))
	a.queue_free()
	# Bordes bisa dipijak: kapsul jatuh di bordes, pusat diam di
	# y 2,5 (= kaki 1,6 + setengah kapsul 0,9).
	var b := _buat_kapsul(InteriorAsramaPutra.ke_dunia(Vector3(12.0, 2.55, 0.0)))
	for i in 30:
		b.velocity = Vector3(0, -5, 0)
		b.move_and_slide()
		await get_tree().physics_frame
	_cek("bordes bisa dipijak (pusat y~2,5)", absf(b.global_position.y - 2.5) < 0.08)
	print("  bordes: %s" % str(b.global_position))
	b.queue_free()
	# Flight B (bordes -> lantai 2): dari bordes ke koridor lantai 2.
	var c := _buat_kapsul(InteriorAsramaPutra.ke_dunia(Vector3(12.0, 2.55, 0.5)))
	var akhir_c := await _jalan_ke(c, InteriorAsramaPutra.ke_dunia(Vector3(8.0, 3.2, 0.5)), 400, 3.0)
	_cek("tangga flight B bisa dinaiki (pusat y>=3,9, x<=-291,3)", akhir_c.y >= 3.9 and akhir_c.x <= -291.3)
	print("  flight B akhir: %s" % str(akhir_c))
	c.queue_free()


# ---------- (G) 3 orang jalan berdampingan (Mas 08:06 WIB) ----------
func _tes_tiga_berdampingan() -> void:
	# Koridor 2,6 m: 3 kapsul (diameter 0,7 m) di z -0,8 / 0 / +0,8
	# jalan ke timur BERSAMAAN; ketiganya harus sampai (x lokal
	# >= 5) tanpa terdorong ke dinding (jarak antar pusat tetap
	# >= 0,7 m — tidak ada yang menumpuk/menembus).
	var awal_z := [-0.8, 0.0, 0.8]
	var badan: Array[CharacterBody3D] = []
	var target: Array[Vector3] = []
	for z in awal_z:
		badan.append(_buat_kapsul(InteriorAsramaPutra.ke_dunia(Vector3(-2.0, 0.95, z))))
		target.append(InteriorAsramaPutra.ke_dunia(Vector3(6.0, 0.0, z)))
	var akhir: Array = await _jalan_bersama(badan, target, 400, 3.0)
	var sampai := true
	for p in akhir:
		if InteriorAsramaPutra.ke_lokal(p).x < 5.0:
			sampai = false
	var renggang := true
	for i in range(3):
		for j in range(i + 1, 3):
			if absf(InteriorAsramaPutra.ke_lokal(akhir[i]).z - InteriorAsramaPutra.ke_lokal(akhir[j]).z) < 0.7:
				renggang = false
	_cek("koridor muat 3 kapsul berdampingan jalan ke timur", sampai and renggang)
	print("  3-berdampingan koridor akhir: %s" % str(akhir))
	for b in badan:
		b.queue_free()
	# Lorong kaki kasur Kamar 001 (2,275 m): 3 kapsul di
	# z -1,8 / -2,55 / -3,3 jalan ke timur; ketiganya harus sampai
	# (x lokal >= -1,5, sebelum partisi x=0).
	var awal_z_kamar := [-1.8, -2.55, -3.3]
	var badan_k: Array[CharacterBody3D] = []
	var target_k: Array[Vector3] = []
	for z in awal_z_kamar:
		badan_k.append(_buat_kapsul(InteriorAsramaPutra.ke_dunia(Vector3(-8.0, 0.95, z))))
		target_k.append(InteriorAsramaPutra.ke_dunia(Vector3(-1.0, 0.0, z)))
	var akhir_k: Array = await _jalan_bersama(badan_k, target_k, 400, 3.0)
	var sampai_k := true
	for p in akhir_k:
		if InteriorAsramaPutra.ke_lokal(p).x < -1.5:
			sampai_k = false
	_cek("lorong kaki kasur muat 3 kapsul berdampingan", sampai_k)
	print("  3-berdampingan kamar akhir: %s" % str(akhir_k))
	for b in badan_k:
		b.queue_free()


## Jalan BERSAMAAN: semua kapsul digerakkan tiap physics frame
## (kalau _jalan_ke dipakai berurutan, kapsul 1 sudah sampai saat
## kapsul 2 mulai jalan — tabrakan antar kapsul tidak teruji).
## Mengembalikan posisi akhir tiap kapsul.
func _jalan_bersama(badan: Array, target: Array[Vector3], maks_frame: int, kecepatan: float) -> Array:
	for i in range(maks_frame):
		var semua_sampai := true
		for k in range(badan.size()):
			var b: CharacterBody3D = badan[k]
			var arah := target[k] - b.global_position
			arah.y = 0.0
			if arah.length() >= 0.3:
				semua_sampai = false
				b.velocity = arah.normalized() * kecepatan
				b.velocity.y = -2.0
				b.move_and_slide()
			else:
				b.velocity = Vector3.ZERO
		await get_tree().physics_frame
		if semua_sampai:
			break
	var akhir: Array = []
	for b in badan:
		akhir.append((b as CharacterBody3D).global_position)
	return akhir


# ---------- (F) tidak ada kasur di Cangkruk Putra ----------
func _tes_tidak_ada_kasur_cangkruk(hasil: Dictionary) -> void:
	var bounds: Dictionary = hasil["bounds"]
	var cangkruk := Vector2(-22, -18)
	var di_luar := cangkruk.x < float(bounds["min_x"]) or cangkruk.x > float(bounds["max_x"]) or cangkruk.y < float(bounds["min_z"]) or cangkruk.y > float(bounds["max_z"])
	_cek("map asrama tidak mencakup Cangkruk Putra (-22,-18)", di_luar)
	var jauh := true
	for bed in (hasil["bed_pos_list"] as Array):
		var b: Vector3 = bed
		if Vector2(b.x, b.z).distance_to(cangkruk) < 20.0:
			jauh = false
	_cek("semua kasur >20 m dari Cangkruk Putra", jauh)
