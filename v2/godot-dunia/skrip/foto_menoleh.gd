extends Node
## Foto gerakan menoleh (Kirana, 18 Nov 2026) — bukti visual RONDE 21b:
## kepala melirik pelan ke kiri/kanan saat diam, lalu kembali tegak.
## Jalankan TANPA --headless (headless membuat save_png null), pola
## skrip/foto_siwak.gd:
##   Xvfb :96 -screen 0 1280x720x24 & sleep 3; DISPLAY=:96 godot --path . skrip/foto_menoleh.tscn
## Pose dipaksa ke tengah jendela menoleh (waktu 4,0 — RONDE 21b:
## siklus 18 dtk, jendela 2,0-6,0 dtk, siklus 0 arah +1) lalu
## di-settle dengan terapkan_idle berulang supaya lerp sampai target.
## Kamera putri dari sisi +X (wajah menoleh ke +X — dari sisi itu
## lirikannya terbaca; dari sisi -X hanya tampak belakang kepala).

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
	# Putra (kiri) + putri (kanan, outfit Fatimah). PENTING: root
	# visual TIDAK boleh dipindah langsung — terapkan_idle me-lerp
	# visual.position ke NOL (itu offset lokal bob/goyang), jadi
	# posisi dunia harus dipegang wadah induk.
	var built_putra := SantriPlayer.build_visual("MenolehPutra", MissionData.OUTFIT_DEFAULT)
	var rig_putra := AnimasiMixamo.rig_dari_built(built_putra)
	var wadah_putra := Node3D.new()
	wadah_putra.position = Vector3(-1.6, 0, 0)
	wadah_putra.add_child(built_putra["root"])
	add_child(wadah_putra)
	var built_putri := SantriPlayer.build_visual("MenolehPutri", NPCFatimah.OUTFIT_FATIMAH)
	var rig_putri := AnimasiMixamo.rig_dari_built(built_putri)
	var wadah_putri := Node3D.new()
	wadah_putri.position = Vector3(1.6, 0, 0)
	wadah_putri.add_child(built_putri["root"])
	add_child(wadah_putri)
	for k in 5:
		await get_tree().process_frame
	# Settle pose menoleh tengah jendela (t=4,0) untuk keduanya.
	for i in range(60):
		AnimasiMixamo.terapkan_idle(rig_putra, 1.0 / 60.0, 4.0, 0.0)
		AnimasiMixamo.terapkan_idle(rig_putri, 1.0 / 60.0, 4.0, 0.0)
	await _foto("menoleh-putra-depan.png", Vector3(-1.25, 1.62, 1.15), Vector3(-1.6, 1.52, 0))
	await _foto("menoleh-putri-depan.png", Vector3(1.95, 1.62, 1.15), Vector3(1.6, 1.52, 0))
	await _foto("menoleh-duo.png", Vector3(0, 1.2, 4.2), Vector3(0, 1.0, 0))
	print("FOTO MENOLEH SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
