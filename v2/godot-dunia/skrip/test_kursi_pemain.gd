extends Node
## TES REGISTRY KURSI PEMAIN (Gilang, 20 Nov 2026 — permintaan Mas
## "bisa duduk di kursi taman dll").
## Membuktikan tanpa memuat dunia (fungsi statis + konstanta saja):
##   1. Struktur: 42 entri, id unik, kunci lengkap, jenis valid,
##      pos.y sesuai jenis, bangun.y == lantai_y, jarak bangun
##      wajar (bersila 0, kursi/kasur 0,5–2,0 m).
##   2. Silang vs registry NPC: 28 entri berbagi (npc_id != "")
##      pos.xz + yaw + gedung + jenis + putri + dalam SAMA PERSIS
##      dengan SantriNPC.KURSI_LUAR/DALAM (pos.y bersila boleh
##      beda <= 0,05 — teras Musholla dikoreksi 0 -> 0,05).
##   3. Silang vs builder: 12 kursi Kelas Putri baru turunan
##      InteriorKelasPutri.MEJA_POS_LIST (x = meja.x ± 0,3,
##      z = meja.z + 0,55, yaw PI); 2 kursi Studio sama dengan
##      InteriorGedungPutri.STUDIO_KURSI(_2) + rot.
##   4. Bangun aman: dalam -> di dalam bounds ruangan; luar ->
##      di luar semua TAPAK (SantriNPC.TAPAK); kelas -> di lorong
##      antar-kolom (x 118,65 / 121,35); taman putra -> 0,5 m di
##      luar kotak collision bangku; taman putri -> di celah
##      antar-bangku.
##   5. Pintu dalam: semua entri dalam punya pintu_luar /
##      pintu_dalam / spawn_dalam dengan y=0.
## Jalankan headless (tanpa Xvfb, tanpa dunia):
##   HOME=/tmp/iso-kursi-pemain godot --headless --path . --scene res://skrip/test_kursi_pemain.tscn

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("KURSI-PEMAIN LULUS %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("KURSI-PEMAIN GAGAL %s %s" % [nama, detail])


func _di_dalam_tapak(p: Vector2) -> String:
	for nama in SantriNPC.TAPAK.keys():
		var r: Array = SantriNPC.TAPAK[nama]
		var mn: Vector2 = r[0]
		var mx: Vector2 = r[1]
		if p.x >= mn.x and p.x <= mx.x and p.y >= mn.y and p.y <= mx.y:
			return String(nama)
	return ""


func _ready() -> void:
	var semua: Array = KursiPemain.KURSI_PEMAIN
	# --- 1) Jumlah + id unik ---
	_cek("jumlah 42 entri", semua.size() == 42, "(dapat %d)" % semua.size())
	var ids := {}
	var duplikat := 0
	for k in semua:
		var id := String(k["id"])
		if ids.has(id):
			duplikat += 1
		ids[id] = true
	_cek("id unik", duplikat == 0, "(%d id)" % ids.size())
	# --- 1b) Struktur per entri ---
	var kunci_luar := ["id", "pos", "yaw", "gedung", "jenis", "putri", "dalam", "bangun", "lantai_y", "npc_id"]
	var kunci_dalam := ["pintu_luar", "pintu_dalam", "spawn_dalam"]
	for k in semua:
		var id := String(k["id"])
		var masalah := ""
		for kunci in kunci_luar:
			if not k.has(kunci):
				masalah += "tanpa " + kunci + "; "
		var dalam := bool(k["dalam"])
		if dalam:
			for kunci in kunci_dalam:
				if not k.has(kunci):
					masalah += "tanpa " + kunci + "; "
		var jenis := String(k["jenis"])
		if not jenis in ["kursi", "bersila", "kasur"]:
			masalah += "jenis aneh; "
		var pos: Vector3 = k["pos"]
		var lantai_y := float(k["lantai_y"])
		var y_harap := 0.45 if jenis == "kursi" else (0.51 if jenis == "kasur" else lantai_y)
		if absf(pos.y - y_harap) > 0.01:
			masalah += "pos.y=%.2f harap %.2f; " % [pos.y, y_harap]
		var bangun: Vector3 = k["bangun"]
		if absf(bangun.y - lantai_y) > 0.01:
			masalah += "bangun.y=%.2f lantai %.2f; " % [bangun.y, lantai_y]
		var jarak := Vector2(bangun.x - pos.x, bangun.z - pos.z).length()
		if jenis == "bersila" and jarak > 0.01:
			masalah += "bersila bangun menjauh %.2f; " % jarak
		if jenis != "bersila" and (jarak < 0.5 or jarak > 2.0):
			masalah += "jarak bangun %.2f; " % jarak
		_cek("struktur " + id, masalah == "", masalah)
	# --- 2) Silang vs registry NPC (28 berbagi) ---
	var npc_semua: Array = []
	npc_semua.append_array(SantriNPC.KURSI_LUAR)
	npc_semua.append_array(SantriNPC.KURSI_DALAM)
	var npc_dari_id := {}
	for n in npc_semua:
		npc_dari_id[String(n["id"])] = n
	var n_berbagi := 0
	for k in semua:
		var npc_id := String(k["npc_id"])
		if npc_id == "":
			continue
		n_berbagi += 1
		var n: Dictionary = npc_dari_id.get(npc_id, {})
		var ok := not n.is_empty()
		var detail := ""
		if ok:
			var pk: Vector3 = k["pos"]
			var pn: Vector3 = n["pos"]
			ok = absf(pk.x - pn.x) < 0.01 and absf(pk.z - pn.z) < 0.01
			ok = ok and absf(float(k["yaw"]) - float(n["yaw"])) < 0.01
			ok = ok and String(k["gedung"]) == String(n["gedung"])
			ok = ok and String(k["jenis"]) == String(n["jenis"])
			ok = ok and bool(k["putri"]) == bool(n["putri"])
			ok = ok and bool(k["dalam"]) == bool(n["dalam"])
			# pos.y bersila: registry NPC pakai 0, pemain pakai
			# lantai_y (teras Musholla 0,05) — selisih <= 0,05 OK.
			# Ambang 0,06 (bukan 0,05 persis): float32 0,05 =
			# 0,0500000007, jadi <= 0,05 gagal karena pembulatan.
			if String(k["jenis"]) == "bersila":
				ok = ok and absf(pk.y - pn.y) <= 0.06
			else:
				ok = ok and absf(pk.y - pn.y) < 0.01
			detail = "npc %s" % npc_id
		_cek("cocok NPC " + npc_id, ok, detail)
	_cek("28 entri berbagi NPC", n_berbagi == 28, "(dapat %d)" % n_berbagi)
	# --- 3a) 12 kursi Kelas Putri baru vs MEJA_POS_LIST ---
	var n_kelas_baru := 0
	for k in semua:
		var id := String(k["id"])
		if not (id.begins_with("kelas_putri_kursi_") and (id.ends_with("u") or id.ends_with("t"))):
			continue
		n_kelas_baru += 1
		var pos: Vector3 = k["pos"]
		var cocok := false
		for m in InteriorKelasPutri.MEJA_POS_LIST:
			var meja: Vector3 = m
			if (absf(pos.x - (meja.x - 0.3)) < 0.01 or absf(pos.x - (meja.x + 0.3)) < 0.01) and absf(pos.z - (meja.z + 0.55)) < 0.01:
				cocok = true
		_cek("kelas baru turunan meja " + id, cocok and absf(float(k["yaw"]) - PI) < 0.01, str(pos))
	_cek("12 kursi kelas baru", n_kelas_baru == 12, "(dapat %d)" % n_kelas_baru)
	# --- 3b) 2 kursi Studio vs konstanta builder ---
	var s1 := KursiPemain.dari_id("studio_kursi_1")
	var s2 := KursiPemain.dari_id("studio_kursi_2")
	_cek("studio 1 = STUDIO_KURSI + rot PI/2",
		absf((s1["pos"] as Vector3).x - InteriorGedungPutri.STUDIO_KURSI.x) < 0.01
		and absf((s1["pos"] as Vector3).z - InteriorGedungPutri.STUDIO_KURSI.z) < 0.01
		and absf(float(s1["yaw"]) - PI / 2.0) < 0.01, str(s1["pos"]))
	_cek("studio 2 = STUDIO_KURSI2 + rot -PI/2",
		absf((s2["pos"] as Vector3).x - InteriorGedungPutri.STUDIO_KURSI2.x) < 0.01
		and absf((s2["pos"] as Vector3).z - InteriorGedungPutri.STUDIO_KURSI2.z) < 0.01
		and absf(float(s2["yaw"]) + PI / 2.0) < 0.01, str(s2["pos"]))
	# --- 4) Bangun aman ---
	var bounds := {
		"kelas_putri": [Vector2(115, -305), Vector2(125, -297)],
		"madrasah": [Vector2(-185, -304), Vector2(-175, -296)],
		"studio": [Vector2(235, -304), Vector2(245, -296)],
		"cangkruk": [Vector2(-67, -305), Vector2(-53, -295)],
	}
	for k in semua:
		var id := String(k["id"])
		var bangun: Vector3 = k["bangun"]
		if bool(k["dalam"]):
			var b: Array = bounds[String(k["gedung"])]
			var mn: Vector2 = b[0]
			var mx: Vector2 = b[1]
			_cek("bangun dalam bounds " + id,
				bangun.x >= mn.x and bangun.x <= mx.x and bangun.z >= mn.y and bangun.z <= mx.y,
				str(bangun))
		else:
			var tapak := _di_dalam_tapak(Vector2(bangun.x, bangun.z))
			_cek("bangun luar tapak " + id, tapak == "", "di " + tapak if tapak != "" else str(bangun))
	# Kelas: bangun HARUS di lorong antar-kolom (bukan di dalam meja).
	for k in semua:
		if String(k["gedung"]) != "kelas_putri":
			continue
		var bangun: Vector3 = k["bangun"]
		_cek("bangun kelas di lorong " + String(k["id"]),
			absf(bangun.x - 118.65) < 0.01 or absf(bangun.x - 121.35) < 0.01, str(bangun))
	# Taman putra: bangun 0,5 m di luar kotak collision bangku.
	# Bangku 1: kotak x -3,9..-2,1, z 25,175..25,725. Bangku 2:
	# kotak x 3,175..3,725, z 27,3..29,1.
	for k in semua:
		var id := String(k["id"])
		if not id.begins_with("bangku_taman_putra_"):
			continue
		var bangun: Vector3 = k["bangun"]
		var ok := false
		if id.ends_with("1a") or id.ends_with("1b"):
			ok = bangun.z >= 25.725 + 0.5
		else:
			ok = bangun.x <= 3.175 - 0.5
		_cek("bangun taman putra clear bangku " + id, ok, str(bangun))
	# Taman putri: bangun di celah antar-bangku (z 30,675..33,325).
	for k in semua:
		var id := String(k["id"])
		if not id.begins_with("bangku_taman_putri_"):
			continue
		var bangun: Vector3 = k["bangun"]
		_cek("bangun taman putri di celah " + id,
			bangun.z > 30.675 and bangun.z < 33.325, str(bangun))
	# --- 5) Pintu dalam: y=0 semua ---
	var pintu_ok := true
	var n_dalam := 0
	for k in semua:
		if not bool(k["dalam"]):
			continue
		n_dalam += 1
		for kunci in ["pintu_luar", "pintu_dalam", "spawn_dalam"]:
			if absf((k[kunci] as Vector3).y) > 0.01:
				pintu_ok = false
	_cek("pintu dalam y=0 (%d entri)" % n_dalam, pintu_ok and n_dalam == 27, "")
	print("KURSI-PEMAIN SELESAI lulus=%d gagal=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
