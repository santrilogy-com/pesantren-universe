extends Node
## Foto ANIMASI-MIXAMO (Eka, 17 Nov 2026) — jalankan TANPA --headless
## (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_animasi_mixamo.tscn
## Studio (fase jalan BEKU via modul + pemain duduk/idle asli) +
## in-world (pemain jalan + duduk, NPC jalan).
## M1 jalan depan (ayun maks) | M2 jalan samping | M3 jalan kontak
## M4 duduk depan | M5 duduk samping | M6 idle depan |
## W1 pemain jalan | W2 pemain duduk | W3 NPC jalan.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-animasi-mixamo/"

var _cam: Camera3D


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, tunggu: int = 40) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in tunggu:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _studio() -> Node3D:
	var st := Node3D.new()
	st.name = "Studio"
	add_child(st)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#a8c4d4")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#fff4e0")
	e.ambient_light_energy = 0.7
	env.environment = e
	st.add_child(env)
	var matahari := DirectionalLight3D.new()
	matahari.rotation = Vector3(-0.9, -0.5, 0.0)
	matahari.shadow_enabled = true
	matahari.light_energy = 1.1
	st.add_child(matahari)
	# Lantai visual + lantai fisika (pemain studio harus berdiri).
	var lantai := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	lantai.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#7a9a5a")
	lantai.material_override = mat
	lantai.position = Vector3(0, 0.001, 0)
	st.add_child(lantai)
	var body := StaticBody3D.new()
	var bentuk := CollisionShape3D.new()
	var kotak := BoxShape3D.new()
	kotak.size = Vector3(20, 1, 20)
	bentuk.shape = kotak
	bentuk.position = Vector3(0, -0.5, 0)
	body.add_child(bentuk)
	st.add_child(body)
	_cam = Camera3D.new()
	_cam.fov = 50.0
	st.add_child(_cam)
	_cam.current = true
	return st


func _ready() -> void:
	# ---------- STUDIO: pose jalan beku (fase eksak via modul) ----------
	var st := _studio()
	# M1+M2: fase 4,5 = lutut kiri terlipat MAKSIMAL (tengah ayunan).
	var built := SantriPlayer.build_visual("Santri", MissionData.OUTFIT_DEFAULT)
	var rig := AnimasiMixamo.rig_dari_built(built)
	st.add_child(built["root"])
	AnimasiMixamo.terapkan_jalan(rig, 4.5, 1.0)
	await _foto("M1-jalan-depan.png", Vector3(0, 1.3, 3.6), Vector3(0, 0.9, 0))
	await _foto("M2-jalan-samping.png", Vector3(3.6, 1.3, 0), Vector3(0, 0.9, 0))
	# M3: fase 0 = kontak kiri (tumit mendarat, lutut hampir lurus).
	AnimasiMixamo.terapkan_jalan(rig, 0.0, 1.0)
	await _foto("M3-jalan-kontak.png", Vector3(2.5, 1.5, 2.5), Vector3(0, 0.9, 0))
	st.remove_child(built["root"])
	built["root"].queue_free()
	# ---------- STUDIO: duduk + idle pakai pemain ASLI ----------
	# EKA (18 Nov 2026, perbaikan M4-M6 kosong): SantriPlayer HARUS
	# punya kapsul collision seperti di main.gd (r=0,35, h=1,7 di
	# y=0,85) — tanpanya _physics_process (gravitasi + move_and_slide)
	# menjatuhkan pemain menembus lantai studio dan keluar frame
	# selama 90 frame tunggu pose. Itu penyebab M4-M6 kosong, bukan
	# framing kamera (pose duduk hanya turun -0,42).
	var pemain := SantriPlayer.new()
	var bentuk := CollisionShape3D.new()
	var kapsul := CapsuleShape3D.new()
	kapsul.radius = 0.35
	kapsul.height = 1.7
	bentuk.shape = kapsul
	bentuk.position = Vector3(0, 0.85, 0)
	pemain.add_child(bentuk)
	pemain.floor_snap_length = 0.3
	st.add_child(pemain)
	for i in 5:
		await get_tree().process_frame
	pemain.set_aksi("duduk")
	for i in 90:
		await get_tree().process_frame
	print("STUDIO duduk pos pemain: ", pemain.global_position)
	await _foto("M4-duduk-depan.png", Vector3(0, 1.4, 3.2), Vector3(0, 0.7, 0))
	print("STUDIO duduk pos pemain: ", pemain.global_position)
	await _foto("M5-duduk-samping.png", Vector3(3.2, 1.4, 0), Vector3(0, 0.7, 0))
	pemain.set_aksi("berdiri")
	for i in 90:
		await get_tree().process_frame
	print("STUDIO idle pos pemain: ", pemain.global_position)
	await _foto("M6-idle-depan.png", Vector3(1.8, 1.5, 2.8), Vector3(0, 1.0, 0))
	st.queue_free()
	for i in 3:
		await get_tree().process_frame
	# ---------- IN-WORLD ----------
	var packed := load("res://main.tscn") as PackedScene
	var main := packed.instantiate()
	add_child(main)
	for i in 3:
		await get_tree().process_frame
	main._masuk_pesantren("Foto animasi")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	var player = main._player
	# W1: pemain jalan di jalan N-S (kamera di depan jalur).
	player.global_position = Vector3(0, 0, 20)
	player.velocity = Vector3.ZERO
	main._ui._joystick.output = Vector2(0, -1)
	for i in 18:
		await get_tree().process_frame
	var p: Vector3 = player.global_position
	var yaw: float = player.get_facing_yaw()
	var depan := Vector3(sin(yaw), 0, cos(yaw))
	var kanan := Vector3(cos(yaw), 0, -sin(yaw))
	main._ui._joystick.output = Vector2.ZERO
	await _foto("W1-pemain-jalan.png", p + depan * 3.2 + kanan * 1.4 + Vector3(0, 1.5, 0), p + Vector3(0, 1.0, 0), 6)
	# W2: pemain duduk di tempat (kamera depan).
	player.set_aksi("duduk")
	for i in 90:
		await get_tree().process_frame
	p = player.global_position
	yaw = player.get_facing_yaw()
	depan = Vector3(sin(yaw), 0, cos(yaw))
	await _foto("W2-pemain-duduk.png", p + depan * 3.0 + Vector3(0, 1.4, 0), p + Vector3(0, 0.8, 0))
	# W3: NPC keliling buatan tes (kamera depan 3/4).
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("TesFoto", Vector3(0, 0, 30), [Vector3(10, 0, 30), Vector3(-10, 0, 30)], MissionData.OUTFIT_DEFAULT)
	for i in 3:
		await get_tree().process_frame
	npc._pause_timer = 0.0
	npc._target = Vector3(10, 0, 30)
	for i in 30:
		await get_tree().process_frame
	var np: Vector3 = npc.position
	var nyaw: float = (npc._visual as Node3D).rotation.y
	var ndepan := Vector3(sin(nyaw), 0, cos(nyaw))
	var nkanan := Vector3(cos(nyaw), 0, -sin(nyaw))
	await _foto("W3-npc-jalan.png", np + ndepan * 3.0 + nkanan * 1.2 + Vector3(0, 1.5, 0), np + Vector3(0, 1.0, 0), 6)
	print("FOTO SELESAI")
	get_tree().quit(0)
