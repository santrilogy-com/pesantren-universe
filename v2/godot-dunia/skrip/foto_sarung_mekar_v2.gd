extends Node
## Foto verifikasi perbaikan "sarung mekar seperti sila" v2 (Kirana, 19 Nov 2026).
## BEDA dengan v1: v1 memakai build_visual + AnimasiMixamo langsung
## (tidak lewat kode NPC) — v1 hanya bisa merepro BUG, tidak bisa
## membuktikan PERBAIKAN. v2 memakai SantriNPC SUNGGUHAN: Kyai patroli
## (setup() -> duduk baca, PAKAIAN_DUDUK) lalu teleport ke pintu luar +
## mulai_rute() (jalur sholat _proses_sholat -> _langkah_ke) + pose
## takbir (mulai_pose_sholat -> _animasi_sholat). Perbaikan npc.gd:
## _terapkan_pakaian(PAKAIAN_DEFAULT) di _langkah_ke + _animasi_sholat.
## Bukti angka: skala sarung dicetak di tiap tahap (duduk ~1.70 lebar,
## jalan/takbir harus ~1.00).
## Jalankan: Xvfb :96 -screen 0 1280x720x24 & DISPLAY=:96 godot --path . skrip/foto_sarung_mekar_v2.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-karakter/"

var _cam: Camera3D
var _npc: SantriNPC


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

	# Kyai patroli: setup() menaruhnya di kursi + _terapkan_duduk_baca.
	var patroli := {
		"kursi": Vector3(0, 0, 10),
		"kursi_yaw": 0.0,
		"pintu_dalam": Vector3(1, 0, 10),
		"spawn_dalam": Vector3(0, 0, 10),
		"pintu_luar": Vector3(2, 0, 10),
		"rute_luar": [],
	}
	_npc = SantriNPC.new()
	_npc.setup("Ust. Aqsal Murad", Vector3(0, 0, 10), [], MissionData.OUTFIT_KYAI, false, patroli, true)
	add_child(_npc)
	for i in 5:
		await get_tree().process_frame
	# Tahap 0 — habis duduk baca: sarung HARUS masih terhampar 1,70x.
	print("SKALA SARUNG SETELAH DUDUK: %s (harap ~(1.70, 0.45, 1.70))" % str(_npc._sarung.scale))
	print("HEM Y SETELAH DUDUK: %.2f (harap 0.50)" % _npc._sarung_hem.position.y)
	# Seperti main.gd saat sesi sholat mulai: keluarkan dari ruangan,
	# lalu beri rute sholat (z=10 = tanah datar, jauh dari anak tangga).
	_npc.teleport_ke_pintu_luar()
	_npc.mulai_rute([Vector3(6, 0, 10), Vector3(12, 0, 10)])
	# Jalan ~1,5 dtk (SPEED 1,6 m/dtk) — lerp pakaian (k = delta*8)
	# menyatu dalam ~0,5 dtk, jadi sarung harus sudah normal.
	for i in 90:
		await get_tree().process_frame
	print("SKALA SARUNG SAAT JALAN: %s (harap ~(1.00, 1.00, 1.00))" % str(_npc._sarung.scale))
	print("HEM Y SAAT JALAN: %.2f (harap 0.12)" % _npc._sarung_hem.position.y)
	print("POSISI NPC SAAT JALAN: %s (harap x ~4-5, sedang jalan)" % str(_npc.position))
	# Kamera di depan-samping arah jalan (+x) supaya tampak depan Kyai.
	await _foto_dekat("sarung-kyai-jalan-setelah-duduk-v2.png", Vector3(2.0, 1.0, 2.2))
	# Sampai di sajadah: pose takbir — sarung harus TETAP normal.
	_npc.mulai_pose_sholat(0.0)
	for i in 45:
		await get_tree().process_frame
	print("SKALA SARUNG SAAT TAKBIR: %s (harap ~(1.00, 1.00, 1.00))" % str(_npc._sarung.scale))
	print("HEM Y SAAT TAKBIR: %.2f (harap 0.12)" % _npc._sarung_hem.position.y)
	await _foto_dekat("sarung-kyai-takbir-v2.png")
	var ok_jalan := _npc._sarung.scale.distance_to(Vector3.ONE) < 0.08
	print("VERDIK MEKAR-V2: sarung kembali normal saat jalan+takbir = %s" % str(ok_jalan))
	print("FOTO SARUNG MEKAR V2 SELESAI")
	get_tree().quit(0 if ok_jalan else 1)


func _foto_dekat(nama: String, offset_kamera: Vector3 = Vector3(-0.7, 1.0, 2.6)) -> void:
	# Kamera mengikuti NPC: re-aim SETELAH settle — NPC terus jalan
	# selama settle, jadi aim di awal akan ketinggalan (foto jalan v2
	# pertama: NPC keluar frame kanan). Aim ulang dari posisi TERKINI,
	# lalu 3 frame saja sebelum jepret.
	for i in 10:
		await get_tree().process_frame
	var p: Vector3 = _npc.position
	_cam.global_position = p + offset_kamera
	_cam.look_at(p + Vector3(0, 0.9, 0), Vector3.UP)
	for i in 3:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
