extends Node
## AUDIT jalan + lampu (susulan Ronde 20 — Mas 21:12 WIB:
## "Jalan dan lampu dibangun ulang. Yg rapi. Masa ada tiang di
## tengah jalan."). Dijalankan sebagai SCENE (.tscn), pola
## test_pohon_pindah.gd: bangun dunia lewat main.tscn + login,
## lalu ukur jarak SEMUA tiang ke SEMUA jalan.
##
## Jalan dikumpulkan DARI dunia yang dibangun: semua BoxMesh
## tebal 0.06 (hanya jalan pasir yang setebal itu — alas plot
## 0.08, tanah 0.2, air sawah 0.1). Tiang dikumpulkan dari
## dunia yang dibangun: lampu (grup LampuJalan), pilar gerbang
## (BoxShape 0.5x3.2x0.5), tiang pagar (silinder r=0.09 h=1.7
## di bawah PagarBatas), tiang papan plot (r=0.06 h=1.6),
## pohon (CylinderShape r=0.25 h=1.6), menara/pilar tinggi
## (silinder h>=4.0 r<=0.4), footprint pos jaga/satpam (3x3).
## Aturan: tiang TIDAK BOLEH berdiri di atas permukaan jalan
## (jarak <= 0) — lolos bila semua tiang >= 1.0 m dari tepi
## jalan (batas rapi); 0..1.0 m = mepet (dicatat).

var _lolos := 0
var _gagal := 0
var _jalan: Array = []  # tiap item: {"pusat": Vector2, "hx": float, "hz": float, "rot": float, "nama": String}


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _jarak_ke_rect_putar(p: Vector2, rect: Dictionary) -> float:
	# Jarak titik ke rect berputar: pindah ke frame lokal rect.
	# Godot rotation.y = rot memetakan lokal (lx,lz) ke dunia
	# (lx*cos+lz*sin, -lx*sin+lz*cos); inversnya di bawah.
	# (Dicek: pintu Surau (-2.11,-7.47) thd JalanSurau harus
	# jatuh di lokal (0,-4.25) — ujung sumbu jalan.)
	var c: Vector2 = rect["pusat"]
	var rot: float = rect["rot"]
	var d := p - c
	var cs := cos(rot)
	var sn := sin(rot)
	var lx := d.x * cs - d.y * sn
	var lz := d.x * sn + d.y * cs
	# Jarak ke rect sumbu-sejajar di frame lokal:
	var ox := maxf(absf(lx) - rect["hx"], 0.0)
	var oz := maxf(absf(lz) - rect["hz"], 0.0)
	return sqrt(ox * ox + oz * oz)


func _jarak_ke_semua_jalan(p: Vector2) -> Dictionary:
	var md := 9999.0
	var mana := ""
	for r in _jalan:
		var d := _jarak_ke_rect_putar(p, r)
		if d < md:
			md = d
			mana = r["nama"]
	return {"d": md, "jalan": mana}


func _nama_jalan(nama: String, pusat: Vector2, sx: float, sz: float) -> String:
	# Jalan bernama (JalanSurau/JalanMusholla) dipertahankan.
	# Kotak _ground tanpa nama diberi nama dari pusat/ukuran:
	# N-S x=0 -> JalanNS-z<pusat>, E-W 320x2.5 -> JalanEW,
	# sawah (16,30) -> JalanSawah.
	if nama.begins_with("Jalan"):
		return nama
	if absf(pusat.x) < 0.1 and absf(sx - 3.0) < 0.1:
		return "JalanNS-z%.0f" % pusat.y
	if absf(pusat.x) < 0.1 and absf(sx - 2.5) < 0.1:
		return "JalanNS-tambal-z%.0f" % pusat.y
	if absf(sx - 320.0) < 0.1:
		return "JalanEW"
	if absf(pusat.x - 16.0) < 0.1 and absf(pusat.y - 30.0) < 0.1:
		return "JalanSawah"
	return "Jalan?(%s)" % str(pusat)


func _kumpul_jalan(n: Node) -> void:
	for c in n.get_children():
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			if mi.mesh is BoxMesh:
				var bm := mi.mesh as BoxMesh
				if absf(bm.size.y - 0.06) < 0.001:
					var gp := mi.global_position
					# BUANG false positive: lantai interior (z~-300,
					# mis. 17.4x13.4 di z=-300) dan kotak kecil
					# (alas peti 1.14x0.8, perabot interior 0.34x0.24
					# — luas < 5 m2, bukan jalan). Batas z=-250 aman:
					# jalan luar terjauh z=-200 (ruas N-S utara),
					# interior di z~-300.
					if gp.z < -250.0 or bm.size.x * bm.size.z < 5.0:
						_kumpul_jalan(c)
						continue
					var rot := mi.global_rotation.y
					var nama := _nama_jalan(mi.name, Vector2(gp.x, gp.z), bm.size.x, bm.size.z)
					_jalan.append({"pusat": Vector2(gp.x, gp.z), "hx": bm.size.x * 0.5, "hz": bm.size.z * 0.5, "rot": rot, "nama": nama})
		_kumpul_jalan(c)


func _di_bawah(n: Node, nama_leluhur: String) -> bool:
	var p := n.get_parent()
	while p != null:
		if p.name == nama_leluhur:
			return true
		p = p.get_parent()
	return false


func _audit_tiang(nama_kelompok: String, daftar: Array) -> void:
	# daftar: Array[Vector2] posisi tiang.
	# Pengecualian yang didokumentasikan: pilar gerbang + tiang
	# pagar ujung celah gerbang di (2.5,+-2) — posisinya DI SUDUT
	# persimpangan N-S/E-W (gerbang memang di persimpangan), 0,75 m
	# dari tepi jalan E-W dan 1,0 m dari tepi jalan N-S; tidak
	# berdiri di atas jalan dan tidak menghalangi jalan. Bar untuk
	# keempat tiang itu 0,5 m, bukan 1,0 m.
	for pos in daftar:
		var r := _jarak_ke_semua_jalan(pos)
		var d: float = r["d"]
		var di_sudut_gerbang := absf(pos.x - 2.5) < 0.05 and (absf(pos.y - 2.0) < 0.05 or absf(pos.y + 2.0) < 0.05)
		var batas := 0.5 if di_sudut_gerbang else 1.0
		var status := "DI ATAS JALAN" if d <= 0.0 else ("MEPET (%.2f m)" % d if d < batas else ("DI TEPI GERBANG (disengaja, %.2f m)" % d if di_sudut_gerbang else "bersih (%.2f m)" % d))
		print("  TIANG %s di %s -> %s [%s]" % [nama_kelompok, str(pos), status, r["jalan"]])
		_cek("%s di %s >= %.1f m dari jalan" % [nama_kelompok, str(pos), batas], d >= batas, "(%.2f m ke %s)" % [d, r["jalan"]])


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	var main: Node = packed.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	main._on_login("PV-0001", "Tes")
	await get_tree().process_frame
	main._kyai._patroli_timer = 9999.0
	main._ustadzah._patroli_timer = 9999.0

	# 1. Kumpulkan jalan dari dunia yang dibangun.
	_kumpul_jalan(main)
	print("JALAN DITEMUKAN: %d" % _jalan.size())
	for r in _jalan:
		print("  jalan '%s' pusat=%s hx=%.2f hz=%.2f rot=%.2f" % [r["nama"], str(r["pusat"]), r["hx"], r["hz"], r["rot"]])

	# 2. Kumpulkan tiang.
	var lampu: Array = []
	for bulb in get_tree().get_nodes_in_group("LampuJalan"):
		var induk := (bulb as Node).get_parent() as Node3D
		if induk != null:
			lampu.append(Vector2(induk.global_position.x, induk.global_position.z))
	var pilar_gerbang: Array = []
	var tiang_pagar: Array = []
	var tiang_papan: Array = []
	var pohon: Array = []
	var tiang_tinggi: Array = []
	_kumpul_tiang(main, pilar_gerbang, tiang_pagar, tiang_papan, pohon, tiang_tinggi)

	print("LAMPU: %d | PILAR GERBANG: %d | TIANG PAGAR: %d | TIANG PAPAN PLOT: %d | POHON: %d | TIANG TINGGI: %d" % [lampu.size(), pilar_gerbang.size(), tiang_pagar.size(), tiang_papan.size(), pohon.size(), tiang_tinggi.size()])

	# 3. Audit tiap kelompok.
	print("--- AUDIT LAMPU JALAN ---")
	_audit_tiang("lampu", lampu)
	print("--- AUDIT PILAR GERBANG ---")
	_audit_tiang("pilar-gerbang", pilar_gerbang)
	print("--- AUDIT TIANG PAGAR ---")
	_audit_tiang("tiang-pagar", tiang_pagar)
	print("--- AUDIT TIANG PAPAN PLOT ---")
	_audit_tiang("tiang-papan", tiang_papan)
	print("--- AUDIT POHON ---")
	_audit_tiang("pohon", pohon)
	print("--- AUDIT TIANG TINGGI (menara/pilar) ---")
	_audit_tiang("tiang-tinggi", tiang_tinggi)

	# 4. Footprint pos jaga/satpam (3x3) vs jalan: jarak rect-ke-rect
	# (diukur dari 4 sudut + pusat; bila sudut di dalam jalan -> 0).
	print("--- AUDIT FOOTPRINT POS JAGA/SATPAM ---")
	for nama_pos in ["PosJaga_1", "PosJaga_2", "PosJaga_3", "PosJaga_4", "PosSatpam"]:
		var node := main.find_child(nama_pos, true, false) as Node3D
		if node == null:
			_cek("pos %s ditemukan" % nama_pos, false)
			continue
		var c := Vector2(node.global_position.x, node.global_position.z)
		var md := 9999.0
		var mana := ""
		for sx in [-1.5, 1.5]:
			for sz in [-1.5, 1.5]:
				var r := _jarak_ke_semua_jalan(c + Vector2(sx, sz))
				if r["d"] < md:
					md = r["d"]
					mana = r["jalan"]
		print("  POS %s di %s -> sudut terdekat %.2f m [%s]" % [nama_pos, str(c), md, mana])
		_cek("pos %s sudutnya >= 0.5 m dari jalan" % nama_pos, md >= 0.5, "(%.2f m ke %s)" % [md, mana])

	print("HASIL AUDIT JALAN+LAMPU: %d LOLOS / %d GAGAL" % [_lolos, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


func _kumpul_tiang(n: Node, pilar_gerbang: Array, tiang_pagar: Array, tiang_papan: Array, pohon: Array, tiang_tinggi: Array) -> void:
	# Tiang interior (z<-250, mis. tiang mihrab di z=-300) DIBUANG —
	# audit ini hanya untuk tiang luar ruangan vs jalan luar.
	for c in n.get_children():
		if c is StaticBody3D:
			for s in c.get_children():
				if s is CollisionShape3D:
					var sh := (s as CollisionShape3D).shape
					var gp := (c as Node3D).global_position
					if gp.z < -250.0:
						continue
					if sh is BoxShape3D:
						var b := sh as BoxShape3D
						if absf(b.size.x - 0.5) < 0.01 and absf(b.size.y - 3.2) < 0.01 and absf(b.size.z - 0.5) < 0.01:
							pilar_gerbang.append(Vector2(gp.x, gp.z))
					if sh is CylinderShape3D:
						var cy := sh as CylinderShape3D
						if absf(cy.radius - 0.25) < 0.01 and absf(cy.height - 1.6) < 0.01:
							pohon.append(Vector2(gp.x, gp.z))
		if c is MeshInstance3D:
			var mi := c as MeshInstance3D
			var gp2 := mi.global_position
			if gp2.z < -250.0:
				_kumpul_tiang(c, pilar_gerbang, tiang_pagar, tiang_papan, pohon, tiang_tinggi)
				continue
			if mi.mesh is CylinderMesh:
				var cm := mi.mesh as CylinderMesh
				if absf(cm.top_radius - 0.09) < 0.01 and absf(cm.height - 1.7) < 0.01 and _di_bawah(mi, "PagarBatas"):
					tiang_pagar.append(Vector2(gp2.x, gp2.z))
				elif absf(cm.top_radius - 0.06) < 0.01 and absf(cm.height - 1.6) < 0.01:
					tiang_papan.append(Vector2(gp2.x, gp2.z))
				elif cm.height >= 4.0 and cm.top_radius <= 0.4 and cm.bottom_radius <= 0.4:
					tiang_tinggi.append(Vector2(gp2.x, gp2.z))
		_kumpul_tiang(c, pilar_gerbang, tiang_pagar, tiang_papan, pohon, tiang_tinggi)
