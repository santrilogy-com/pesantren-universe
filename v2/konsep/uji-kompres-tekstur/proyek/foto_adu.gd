extends Node
## Foto adu tekstur: ASLI (JPG lossless) vs UASTC vs ETC1S, sudut SAMA.
## Jalankan TANPA --headless (headless membuat save_png null):
##   Xvfb :96 -screen 0 1280x1280x24 & DISPLAY=:96 godot --path . adu.tscn
## 6 shot full-frame (tekstur 1024 px memenuhi layar 1280 px).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/"

var _cam: Camera3D

const VARIAN := [
	["adu-rumput-asli.png", "res://rumput_asli.jpg", -7.5],
	["adu-rumput-uastc.png", "res://rumput_uastc.ktx2", -4.5],
	["adu-rumput-etc1s.png", "res://rumput_etc1s.ktx2", -1.5],
	["adu-rumput-linear.png", "res://rumput_linear.ktx2", 10.5],
	["adu-rumput-etc1s-linear.png", "res://rumput_etc1s_linear.ktx2", 13.5],
	["adu-tanah-asli.png", "res://tanah_asli.jpg", 1.5],
	["adu-tanah-uastc.png", "res://tanah_uastc.ktx2", 4.5],
	["adu-tanah-etc1s.png", "res://tanah_etc1s.ktx2", 7.5],
	["adu-tanah-etc1s-linear.png", "res://tanah_etc1s_linear.ktx2", 16.5],
]


func _ready() -> void:
	# Lingkungan: cahaya netral, sama untuk semua shot.
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.12, 0.12, 0.12)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1, 1, 1)
	e.ambient_light_energy = 0.9
	env.environment = e
	add_child(env)
	var matahari := DirectionalLight3D.new()
	matahari.rotation_degrees = Vector3(-25, -15, 0)
	matahari.light_energy = 0.8
	add_child(matahari)
	# 6 quad 2x2 m, masing-masing 1 varian tekstur.
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	for v in VARIAN:
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = load(v[1]) as Texture2D
		mat.roughness = 1.0
		var mi := MeshInstance3D.new()
		mi.mesh = quad
		mi.set_surface_override_material(0, mat)
		mi.position = Vector3(v[2], 0, 0)
		add_child(mi)
	_cam = $Camera3D
	_cam.current = true
	for v in VARIAN:
		await _foto(v[0], v[2])
	print("FOTO ADU SELESAI")
	get_tree().quit(0)


func _foto(nama: String, x: float) -> void:
	_cam.global_position = Vector3(x, 0, 2.2)
	_cam.look_at(Vector3(x, 0, 0), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO ", nama, " -> err=", err)
