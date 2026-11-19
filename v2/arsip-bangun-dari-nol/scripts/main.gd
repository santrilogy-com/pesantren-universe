extends Node
## Main v2 ALPHA (Rangga, 17 Nov 2026) — dunia baru Godot, folder v2.
## ALPHA = dunia bisa dijelajahi: Surau + 7 elemen lingkungan GLB,
## bangunan placeholder sesuai peta Gilang, pemain primitif, joystick.
## BELUM ADA: login, misi, sholat, NPC, interior, karakter final.
## Tata letak ikut KONSEP-TATA-LETAK.md (DI-ACC Mas 17 Nov 18:23).

const ZAMRUD := Color(0.02, 0.37, 0.27)
const KREM := Color(0.95, 0.91, 0.84)
const EMAS := Color(0.79, 0.64, 0.15)
const JATI := Color(0.48, 0.29, 0.16)
const RUMPUT := Color(0.42, 0.72, 0.32)
const JALAN := Color(0.85, 0.85, 0.83)

const SPAWN_PUTRA := Vector3(-4, 0, 14)

var player: V2Player
var _joystick: V2Joystick
var _label_pos: Label
var _glb_count: int = 0
var _gedung_count: int = 0


func _ready() -> void:
	_langit()
	_tanah()
	_jalan()
	_surau()
	_gedung_placeholder()
	_tembok()
	_lingkungan()
	_peti_dan_papan()
	player = V2Player.new()
	player.position = SPAWN_PUTRA
	player.cam_yaw = 0.0
	add_child(player)
	_ui()


func _langit() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = Color(0.35, 0.60, 0.90)
	mat.sky_horizon_color = Color(0.85, 0.90, 0.95)
	mat.ground_bottom_color = Color(0.40, 0.50, 0.35)
	mat.ground_horizon_color = Color(0.80, 0.85, 0.80)
	sky.sky_material = mat
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.7
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)


func _tanah() -> void:
	var body := StaticBody3D.new()
	body.name = "Tanah"
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(280, 1, 165)
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = RUMPUT
	mi.material_override = mat
	mi.position = Vector3(70, -0.5, 12.5)
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(280, 1, 165)
	col.shape = shape
	col.position = Vector3(70, -0.5, 12.5)
	body.add_child(col)
	add_child(body)


func _datar(ukuran: Vector3, pos: Vector3, warna: Color, nama: String) -> void:
	var mi := MeshInstance3D.new()
	mi.name = nama
	var box := BoxMesh.new()
	box.size = ukuran
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = warna
	mi.material_override = mat
	mi.position = pos
	add_child(mi)


func _jalan() -> void:
	# N-S x=0 (z -62..90), E-W z=0 (x -62..198), internal putri x=142, ke sawah z=30.
	_datar(Vector3(6, 0.04, 152), Vector3(0, 0.02, 14), JALAN, "JalanNS")
	_datar(Vector3(260, 0.04, 6), Vector3(68, 0.02, 0), JALAN, "JalanEW")
	_datar(Vector3(6, 0.04, 51), Vector3(142, 0.02, -9.5), JALAN, "JalanInternalPutri")
	_datar(Vector3(60, 0.04, 6), Vector3(30, 0.02, 30), JALAN, "JalanSawah")


func _glb(path: String, pos: Vector3, rot_y_deg: float, nama: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("V2 GLB gagal dimuat: " + path)
		return null
	var inst := packed.instantiate() as Node3D
	inst.name = nama
	inst.position = pos
	inst.rotation.y = deg_to_rad(rot_y_deg)
	add_child(inst)
	_glb_count += 1
	return inst


func _surau() -> void:
	_glb("res://models/surau-v2.glb", Vector3(0, 0, -12), -25.0, "Surau")
	# Collision kasar tapak Surau 20x16, ikut putaran -25 derajat.
	var body := StaticBody3D.new()
	body.name = "SurauCollision"
	body.position = Vector3(0, 2, -12)
	body.rotation.y = deg_to_rad(-25.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(20, 4, 16)
	col.shape = shape
	body.add_child(col)
	add_child(body)
	_label("SURAU", Vector3(0, 12.5, -12))


func _gedung(nama: String, ukuran: Vector2, pos: Vector2, tinggi: float = 4.0) -> void:
	var body := StaticBody3D.new()
	body.name = "Gedung_" + nama
	body.position = Vector3(pos.x, 0, pos.y)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(ukuran.x, tinggi, ukuran.y)
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = ZAMRUD
	mi.material_override = mat
	mi.position = Vector3(0, tinggi * 0.5, 0)
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(ukuran.x, tinggi, ukuran.y)
	col.shape = shape
	col.position = Vector3(0, tinggi * 0.5, 0)
	body.add_child(col)
	# Atap krem (slab, menjorok 0.4 m).
	var atap := MeshInstance3D.new()
	var abox := BoxMesh.new()
	abox.size = Vector3(ukuran.x + 0.8, 0.4, ukuran.y + 0.8)
	atap.mesh = abox
	var amat := StandardMaterial3D.new()
	amat.albedo_color = KREM
	atap.material_override = amat
	atap.position = Vector3(0, tinggi + 0.2, 0)
	body.add_child(atap)
	add_child(body)
	_label(nama, Vector3(pos.x, tinggi + 1.6, pos.y))
	_gedung_count += 1


func _label(teks: String, pos: Vector3) -> void:
	var l := Label3D.new()
	l.text = teks
	l.font_size = 64
	l.pixel_size = 0.02
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.outline_size = 12
	l.outline_modulate = Color(0.02, 0.23, 0.18)
	l.position = pos
	add_child(l)


func _gedung_placeholder() -> void:
	# (nama, ukuran x/z, posisi x/z) — ikut tabel KONSEP-TATA-LETAK.md.
	_gedung("MASJID BESAR", Vector2(20, 16), Vector2(0, -38), 5.0)
	_gedung("KELAS PUTRA", Vector2(12, 9), Vector2(-35, -8))
	_gedung("ASRAMA PUTRA", Vector2(14, 10), Vector2(-16, 9))
	_gedung("CANGKRUK PUTRA", Vector2(10, 8), Vector2(-22, -18), 3.0)
	_gedung("KANTOR PENGASUH", Vector2(10, 8), Vector2(-36, -28))
	_gedung("MUSHOLLA", Vector2(12, 10), Vector2(134, -24))
	_gedung("CANGKRUK PUTRI", Vector2(10, 8), Vector2(128, -12), 3.0)
	_gedung("KELAS PUTRI", Vector2(10, 8), Vector2(130, 10))
	_gedung("ASRAMA PUTRI", Vector2(12, 8), Vector2(152, 9))
	_gedung("MADRASAH", Vector2(10, 8), Vector2(152, -12))
	_gedung("STUDIO", Vector2(10, 8), Vector2(166, -12))
	_gedung("KANTOR USTADZAH", Vector2(8, 6), Vector2(148, -33), 3.5)
	_gedung("MASJID PUTRI", Vector2(20, 16), Vector2(166, -40), 5.0)
	_gedung("PERPUSTAKAAN", Vector2(8, 6), Vector2(0, 19))
	_gedung("KANTIN", Vector2(12, 8), Vector2(0, 40))
	_gedung("AULA", Vector2(16, 12), Vector2(0, 52), 5.0)
	# Lapangan: datar saja (bukan gedung).
	_datar(Vector3(30, 0.05, 20), Vector3(-30, 0.025, 50), Color(0.35, 0.65, 0.30), "LapanganPutra")
	_label("LAPANGAN PUTRA", Vector3(-30, 1.2, 50))
	_datar(Vector3(30, 0.05, 20), Vector3(198, 0.025, 12), Color(0.35, 0.65, 0.30), "LapanganPutri")
	_label("LAPANGAN PUTRI", Vector3(198, 1.2, 12))
	# Pos Satpam + Pos Jaga.
	_gedung("POS SATPAM", Vector2(3, 3), Vector2(17, 5), 3.0)
	_gedung("POS JAGA", Vector2(3, 3), Vector2(176, -20), 3.0)


func _tembok_segitiga(nama: String, ukuran: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = nama
	body.position = pos
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = ukuran
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = KREM
	mi.material_override = mat
	mi.position = Vector3(0, ukuran.y * 0.5, 0)
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = ukuran
	col.shape = shape
	col.position = Vector3(0, ukuran.y * 0.5, 0)
	body.add_child(col)
	add_child(body)


func _tembok() -> void:
	# Tembok pemisah x=14 (z -60..16), celah gerbang di z -2..2.
	_tembok_segitiga("Tembok14_Utara", Vector3(1, 3, 58), Vector3(14, 0, -31))
	_tembok_segitiga("Tembok14_Selatan", Vector3(1, 3, 14), Vector3(14, 0, 9))
	# Gerbang (14,0): dua pilar + ambang + label.
	_tembok_segitiga("Gerbang_PilarUtara", Vector3(1.2, 4, 1.2), Vector3(14, 0, -2))
	_tembok_segitiga("Gerbang_PilarSelatan", Vector3(1.2, 4, 1.2), Vector3(14, 0, 2))
	_tembok_segitiga("Gerbang_Ambang", Vector3(1.2, 1, 5.2), Vector3(14, 4.5, 0))
	_label("GERBANG", Vector3(14, 6.0, 0))
	# Tembok keliling kampus putri x 115..180, z -52..22 (celah gerbang barat di z -2..2).
	_tembok_segitiga("TembokPutri_Utara", Vector3(65, 3, 1), Vector3(147.5, 0, -52))
	_tembok_segitiga("TembokPutri_Selatan", Vector3(65, 3, 1), Vector3(147.5, 0, 22))
	_tembok_segitiga("TembokPutri_BaratUtara", Vector3(1, 3, 50), Vector3(115, 0, -27))
	_tembok_segitiga("TembokPutri_BaratSelatan", Vector3(1, 3, 20), Vector3(115, 0, 12))
	_tembok_segitiga("TembokPutri_Timur", Vector3(1, 3, 74), Vector3(180, 0, -15))
	_label("GERBANG PUTRI", Vector3(115, 5.0, 0))


func _lingkungan() -> void:
	# Sawah (60,30) 20x12 + taman (0,25) 8x6 — taman di SELATAN
	# Perpustakaan (tapak 8x6 di (0,19)), bukan di dalam kotaknya.
	_glb("res://models/sawah.glb", Vector3(60, 0, 30), 0.0, "Sawah")
	_glb("res://models/taman.glb", Vector3(0, 0, 25), 0.0, "Taman")
	# Gubuk santri x2.
	_glb("res://models/gubuk-santri.glb", Vector3(48, 0, 30), 0.0, "GubukSawah")
	_glb("res://models/gubuk-santri.glb", Vector3(90, 0, 10), 90.0, "GubukKebun")
	# Pohon rindang — zona penyangga + sekitar Surau/lapangan.
	var rindang := [
		Vector3(25, 0, -20), Vector3(35, 0, 5), Vector3(45, 0, -35),
		Vector3(55, 0, 25), Vector3(70, 0, -15), Vector3(85, 0, 40),
		Vector3(100, 0, -30), Vector3(110, 0, 15), Vector3(30, 0, 45),
		Vector3(60, 0, -45), Vector3(-14, 0, -22), Vector3(12, 0, -28),
		Vector3(-42, 0, 42), Vector3(8, 0, 72),
	]
	for i in rindang.size():
		_glb("res://models/pohon-rindang.glb", rindang[i], float(i * 37 % 360), "PohonRindang_%d" % i)
	# Pohon hias — dekat pintu masuk bangunan.
	var hias := [
		Vector3(-6, 0, -2), Vector3(6, 0, -2), Vector3(0, 0, 76),
		Vector3(134, 0, -14), Vector3(140, 0, 8), Vector3(0, 0, 16),
	]
	for i in hias.size():
		_glb("res://models/pohon-hias.glb", hias[i], float(i * 53 % 360), "PohonHias_%d" % i)
	# Pagar bambu — keliling taman (8x6 di (0,25)).
	var bambu := [
		[Vector3(-4, 0, 22.5), 0.0], [Vector3(0, 0, 22.5), 0.0], [Vector3(4, 0, 22.5), 0.0],
		[Vector3(-4, 0, 28.5), 0.0], [Vector3(0, 0, 28.5), 0.0], [Vector3(4, 0, 28.5), 0.0],
		[Vector3(-6.5, 0, 24), 90.0], [Vector3(-6.5, 0, 27), 90.0],
		[Vector3(6.5, 0, 24), 90.0], [Vector3(6.5, 0, 27), 90.0],
	]
	for i in bambu.size():
		_glb("res://models/pagar-bambu.glb", bambu[i][0], float(bambu[i][1]), "PagarBambu_%d" % i)
	# Pagar bata — tepi utara Lapangan Putra (z=39, x -44..-16).
	for i in 8:
		_glb("res://models/pagar-bata.glb", Vector3(-44 + i * 4, 0, 39), 0.0, "PagarBata_%d" % i)


func _peti_dan_papan() -> void:
	# Peti Kayu M3 (0,26).
	var peti := StaticBody3D.new()
	peti.name = "PetiM3"
	peti.position = Vector3(0, 0.4, 26)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1, 0.8, 1)
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = JATI
	mi.material_override = mat
	peti.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1, 0.8, 1)
	col.shape = shape
	peti.add_child(col)
	add_child(peti)
	_label("PETI M3", Vector3(0, 1.6, 26))
	# Papan selamat datang (0,18).
	_datar(Vector3(4, 2, 0.2), Vector3(0, 1.6, 18), KREM, "PapanSelamatDatang")
	_label("SELAMAT DATANG", Vector3(0, 3.2, 18))
	# Gerbang Utama (0,80): dua pilar + label.
	_tembok_segitiga("GerbangUtama_Barat", Vector3(1.2, 4, 1.2), Vector3(-3, 0, 80))
	_tembok_segitiga("GerbangUtama_Timur", Vector3(1.2, 4, 1.2), Vector3(3, 0, 80))
	_label("GERBANG UTAMA", Vector3(0, 5.5, 80))


func _ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var judul := Label.new()
	judul.text = "PESANTREN VERSE v2 — ALPHA"
	judul.position = Vector2(16, 12)
	judul.add_theme_font_size_override("font_size", 28)
	judul.add_theme_color_override("font_color", Color(1, 1, 1))
	judul.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	judul.add_theme_constant_override("shadow_offset_x", 2)
	judul.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(judul)
	_label_pos = Label.new()
	_label_pos.text = ""
	_label_pos.position = Vector2(16, 48)
	_label_pos.add_theme_font_size_override("font_size", 20)
	_label_pos.add_theme_color_override("font_color", Color(1, 1, 1))
	_label_pos.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_label_pos.add_theme_constant_override("shadow_offset_x", 2)
	_label_pos.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(_label_pos)
	_joystick = V2Joystick.new()
	_joystick.position = Vector2(30, 470)
	_joystick.size = Vector2(220, 220)
	layer.add_child(_joystick)
	var hint := Label.new()
	hint.text = "Seret kanan: putar kamera • WASD: jalan"
	hint.position = Vector2(700, 680)
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	hint.add_theme_constant_override("shadow_offset_x", 2)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(hint)


func _process(_delta: float) -> void:
	if player == null:
		return
	var joy := _joystick.get_vector() if _joystick != null else Vector2.ZERO
	var key := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var mv := joy if joy.length() > 0.1 else key
	player.move_input = mv
	_label_pos.text = "Pos: (%.0f, %.0f)  •  GLB: %d  •  Gedung: %d" % [
		player.global_position.x, player.global_position.z, _glb_count, _gedung_count]


func _unhandled_input(event: InputEvent) -> void:
	if player == null:
		return
	var vw := get_viewport().get_visible_rect().size.x
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.position.x > vw * 0.4:
			player.add_yaw(-drag.relative.x * 0.005)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mm.position.x > vw * 0.4:
			player.add_yaw(-mm.relative.x * 0.005)
