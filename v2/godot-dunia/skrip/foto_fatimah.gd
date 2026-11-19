extends Node
## Foto NPC Ustzh. Fatimah vs Ustzh. Mariyah (Kirana, 18 Nov 2026) —
## bukti visual pembeda: abaya Fatimah zamrud gelap #043B2C vs
## Mariyah #065F46, jilbab sama-sama krem. Jalankan TANPA --headless
## (headless membuat save_png null), pola skrip/foto_hijab.gd:
##   Xvfb :93 -screen 0 1280x720x24 & sleep 3; DISPLAY=:93 godot --path . skrip/foto_fatimah.tscn
## Label nama DIBIARKAN tampil (bukti identitas tiap NPC).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-npc-fatimah/"

var _cam: Camera3D


func _ready() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#efe9dc")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff6e6")
	env.ambient_light_energy = 0.75
	env_node.environment = env
	add_child(env_node)
	var matahari := DirectionalLight3D.new()
	matahari.rotation_degrees = Vector3(-50, 30, 0)
	matahari.light_color = Color("#fff2dd")
	matahari.light_energy = 1.1
	matahari.shadow_enabled = true
	add_child(matahari)
	var isi := DirectionalLight3D.new()
	isi.rotation_degrees = Vector3(-20, -140, 0)
	isi.light_color = Color("#dfe8ff")
	isi.light_energy = 0.35
	add_child(isi)
	var lantai := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(60, 60)
	lantai.mesh = pm
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color("#ddd6c4")
	lm.roughness = 0.95
	lantai.material_override = lm
	add_child(lantai)
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true
	# Fatimah (kiri) + Mariyah (kanan), berdiri berdampingan.
	var fatimah := NPCFatimah.buat(self)
	fatimah.position = Vector3(-1.6, 0, 0)
	var mariyah := SantriNPC.new()
	mariyah.setup("Ustadzah Mariyah", Vector3(1.6, 0, 0), [Vector3(1.6, 0, 0)], MissionData.OUTFIT_USTADZAH, true)
	add_child(mariyah)
	for k in 5:
		await get_tree().process_frame
	await _foto("duo_depan.png", Vector3(0, 1.15, 3.6), Vector3(0, 1.0, 0))
	await _foto("duo_tigaperempat.png", Vector3(2.4, 1.5, 2.4), Vector3(0, 1.0, 0))
	await _foto("fatimah_depan.png", Vector3(-1.6, 1.05, 2.4), Vector3(-1.6, 1.0, 0))
	await _foto("fatimah_wajah.png", Vector3(-1.3, 1.72, 0.95), Vector3(-1.6, 1.62, 0))
	await _foto("mariyah_depan.png", Vector3(1.6, 1.05, 2.4), Vector3(1.6, 1.0, 0))
	print("FOTO FATIMAH SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
