extends Node
## Foto repro "sarung mekar seperti sila saat jalan" (Kirana, 19 Nov 2026).
## Hipotesis: Kyai habis duduk baca (PAKAIAN_DUDUK: sarung scale 1.70x
## lebar, 0.45x tinggi, hem y=0.50) lalu jalan ke sholat lewat
## _proses_sholat -> _langkah_ke, yang TIDAK pernah memanggil
## _terapkan_pakaian(PAKAIAN_DEFAULT) — sarung TETAP terhampar 1,7x
## lebar selama seluruh jalan ke sajadah. (Jalur patroli memanggilnya
## di 4 fase, jadi di sana sarung kembali normal dalam ~0,5 dtk.)
## Foto 1: jalan normal (timpa jalan-v2.png yang basi dari run
## ambang-salah). Foto 2+3: jalan + pakaian DUDUK (repro bug).
## Jalankan: Xvfb :96 -screen 0 1280x720x24 & DISPLAY=:96 godot --path . skrip/foto_sarung_mekar.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-karakter/"

var _cam: Camera3D


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
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
	var built := SantriPlayer.build_visual("Ust. Aqsal Murad", MissionData.OUTFIT_KYAI)
	var rig := AnimasiMixamo.rig_dari_built(built)
	var wadah := Node3D.new()
	wadah.position = Vector3(0, 0, 0)
	wadah.add_child(built["root"])
	add_child(wadah)
	for k in 5:
		await get_tree().process_frame
	# 1. Jalan NORMAL (motif sudah diperbaiki) — timpa jalan-v2 basi.
	AnimasiMixamo.terapkan_jalan(rig, 0.25, 1.0)
	await _foto("sarung-kyai-jalan-v2.png", Vector3(-0.7, 1.0, 2.6), Vector3(0, 0.9, 0))
	# 2. Jalan + PAKAIAN_DUDUK (repro bug): sarung terhampar 1,7x.
	_pakaian_duduk(built)
	AnimasiMixamo.terapkan_jalan(rig, 0.25, 1.0)
	await _foto("sarung-kyai-jalan-mekar-v1.png", Vector3(-0.7, 1.0, 2.6), Vector3(0, 0.9, 0))
	# 3. Sama, dari samping — kelihatan sarung gepeng melebar.
	await _foto("sarung-kyai-jalan-mekar-samping-v1.png", Vector3(2.6, 1.0, 0), Vector3(0, 0.9, 0))
	print("FOTO SARUNG MEKAR SELESAI")
	get_tree().quit(0)


func _pakaian_duduk(built: Dictionary) -> void:
	# Cermin PAKAIAN_DUDUK (player.gd:82): sarung 1,70x lebar,
	# 0,45x tinggi, hem naik ke y=0,50.
	var sarung := built["sarung"] as Node3D
	sarung.scale = Vector3(1.70, 0.45, 1.70)
	sarung.position.y = 0.65
	var hem := built["sarung_hem"] as Node3D
	hem.scale = Vector3(1.70, 0.20, 1.70)
	hem.position.y = 0.50
	var trim := built["sarung_trim"] as Node3D
	trim.position.y = 0.50


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
