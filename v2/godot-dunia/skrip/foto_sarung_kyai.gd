extends Node
## Foto sarung Kyai (Kirana, 19 Nov 2026) — investigasi laporan Mas:
## "sarung Ustadz Aqsal juga aneh" (dari HP, setelah deploy d38581eb).
## Kyai = SantriPlayer.build_visual("Ust. Aqsal Murad",
## MissionData.OUTFIT_KYAI) — sarung hitam #23282e motif batik parang.
## Santri default (OUTFIT_DEFAULT, sarung zamrud) di samping sebagai
## pembanding: konstruksi sarungnya SAMA, warnanya beda.
## Jalankan TANPA --headless (pola skrip/foto_menoleh.gd):
##   Xvfb :97 -screen 0 1280x720x24 & sleep 3; DISPLAY=:97 godot --path . skrip/foto_sarung_kyai.tscn
## Pose berdiri = pose default build_visual (tanpa idle, supaya bentuk
## sarung terbaca murni). Foto jalan = terapkan_jalan fase 0.25
## (ayunan kaki maksimal) untuk cek kaki menembus sarung atau tidak.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-karakter/"

var _cam: Camera3D
var _rig_kyai: Dictionary


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
	# Kyai (kiri) + santri default (kanan, pembanding).
	var built_kyai := SantriPlayer.build_visual("Ust. Aqsal Murad", MissionData.OUTFIT_KYAI)
	_rig_kyai = AnimasiMixamo.rig_dari_built(built_kyai)
	var wadah_kyai := Node3D.new()
	wadah_kyai.position = Vector3(-1.6, 0, 0)
	wadah_kyai.add_child(built_kyai["root"])
	add_child(wadah_kyai)
	var built_santri := SantriPlayer.build_visual("SantriBiasa", MissionData.OUTFIT_DEFAULT)
	var wadah_santri := Node3D.new()
	wadah_santri.position = Vector3(1.6, 0, 0)
	wadah_santri.add_child(built_santri["root"])
	add_child(wadah_santri)
	for k in 5:
		await get_tree().process_frame
	# 1. Kyai depan, badan penuh.
	await _foto("sarung-kyai-depan.png", Vector3(-1.6, 1.15, 3.0), Vector3(-1.6, 1.0, 0))
	# 2. Kyai samping (+X).
	await _foto("sarung-kyai-samping.png", Vector3(1.0, 1.0, 0), Vector3(-1.6, 0.95, 0))
	# 3. Close-up sarung Kyai.
	await _foto("sarung-kyai-dekat.png", Vector3(-1.6, 0.55, 1.7), Vector3(-1.6, 0.45, 0))
	# 4. Duo pembanding Kyai vs santri zamrud.
	await _foto("sarung-kyai-vs-santri.png", Vector3(0, 1.2, 4.8), Vector3(0, 1.0, 0))
	# 5. Kyai melangkah (fase 0.25 = ayunan maksimal) — cek kaki
	# menembus sarung saat patroli.
	AnimasiMixamo.terapkan_jalan(_rig_kyai, 0.25, 1.0)
	await _foto("sarung-kyai-jalan.png", Vector3(-0.7, 1.0, 2.6), Vector3(-1.6, 0.9, 0))
	print("FOTO SARUNG KYAI SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
