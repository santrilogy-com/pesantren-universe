extends Node
## Foto spot-check massal: ASLI vs ETC1S+linear, per kelompok tekstur.
## Jalankan TANPA --headless, sesudah render adu-tanah selesai (display :96 dipakai bergantian):
##   Xvfb :96 -screen 0 1280x1280x24 & DISPLAY=:96 godot --path . massal.tscn
## 1 shot per kelompok (2 quad berdampingan: kiri ASLI, kanan ETC1S+linear).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/"

var _cam: Camera3D

const PASANG := [
	["massal-kayu.png", "res://m_kayu_asli.jpg", "res://m_kayu_etc1s_linear.ktx2", Vector2(2, 2), 1.05, 3.4],
	["massal-bata.png", "res://m_bata_asli.jpg", "res://m_bata_etc1s_linear.ktx2", Vector2(2, 2), 1.05, 3.4],
	["massal-kain.png", "res://m_kain_asli.jpg", "res://m_kain_etc1s_linear.ktx2", Vector2(2, 2), 1.05, 3.4],
	["massal-batu.png", "res://m_batu_asli.jpg", "res://m_batu_etc1s_linear.ktx2", Vector2(2, 2), 1.05, 3.4],
	["massal-atlas.png", "res://m_atlas_asli.png", "res://m_atlas_etc1s_linear.ktx2", Vector2(2.6, 1.73), 1.35, 6.0],
]


func _ready() -> void:
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
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	# 2 quad berdampingan per pasangan (kiri asli, kanan ktx2).
	var quads: Array = []
	for p in PASANG:
		var q := QuadMesh.new()
		q.size = p[3]
		for j in 2:
			var mat := StandardMaterial3D.new()
			mat.albedo_texture = load(p[1 + j]) as Texture2D
			mat.roughness = 1.0
			var mi := MeshInstance3D.new()
			mi.mesh = q
			mi.set_surface_override_material(0, mat)
			mi.position = Vector3(-p[4] if j == 0 else p[4], 0, 0)
			mi.visible = false
			add_child(mi)
			quads.append(mi)
	_cam = $Camera3D
	_cam.current = true
	for i in PASANG.size():
		quads[i * 2].visible = true
		quads[i * 2 + 1].visible = true
		await _foto(PASANG[i][0], PASANG[i][5])
		quads[i * 2].visible = false
		quads[i * 2 + 1].visible = false
	print("FOTO MASSAL SELESAI")
	get_tree().quit(0)


func _foto(nama: String, jarak: float) -> void:
	_cam.global_position = Vector3(0, 0, jarak)
	_cam.look_at(Vector3(0, 0, 0), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO ", nama, " -> err=", err)
