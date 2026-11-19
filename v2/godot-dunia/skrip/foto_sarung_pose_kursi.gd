extends Node
## Foto reproduksi 4 bug sarung + pose duduk (Kirana, 20 Nov 2026 —
## laporan Mas 00:24 WIB, T1 live build 20261119-4).
## 1) sarung mekar saat berdiri setelah duduk; 2) bersila mekar
## kayak bunga; 3) duduk di kursi malah bersila; 4) berdiri dari
## kursi malah berdiri DI ATAS kursi.
## Memakai SantriNPC + SantriPlayer SUNGGUHAN di scene kosong
## (pola foto_sarung_mekar_v2.gd) — bukan build_visual langsung.
## Jalankan: Xvfb :NN -screen 0 1280x720x24 & DISPLAY=:NN
##   HOME=/tmp/iso-pose-kursi godot --path . --resolution 1280x720
##   --audio-driver Dummy --scene res://skrip/foto_sarung_pose_kursi.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-karakter/"

var _cam: Camera3D
var _npc: SantriNPC
var _pemain: SantriPlayer


func _siapkan_dunia() -> void:
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
	# Lantai visual + lantai FISIKA (pemain CharacterBody butuh pijak).
	var lantai := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(60, 60)
	lantai.mesh = pm
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color("#ddd6c4")
	lm.roughness = 0.95
	lantai.material_override = lm
	add_child(lantai)
	var lantai_fisik := StaticBody3D.new()
	var bentuk := CollisionShape3D.new()
	var bidang := WorldBoundaryShape3D.new()
	bentuk.shape = bidang
	lantai_fisik.add_child(bentuk)
	add_child(lantai_fisik)
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true


func _bangku(pos: Vector3, yaw: float) -> Node3D:
	# Bangku taman sederhana: dudukan 1,8 x 0,55 di y 0,45 + kaki.
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	var kayu := StandardMaterial3D.new()
	kayu.albedo_color = Color("#7b4b2a")
	kayu.roughness = 0.9
	var dudukan := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.8, 0.08, 0.55)
	dudukan.mesh = bm
	dudukan.material_override = kayu
	dudukan.position = Vector3(0, 0.41, 0)
	root.add_child(dudukan)
	for sx in [-0.8, 0.8]:
		var kaki := MeshInstance3D.new()
		var km := BoxMesh.new()
		km.size = Vector3(0.08, 0.38, 0.5)
		kaki.mesh = km
		kaki.material_override = kayu
		kaki.position = Vector3(sx, 0.19, 0)
		root.add_child(kaki)
	add_child(root)
	return root


func _foto(nama: String, target: Vector3, offset_kamera: Vector3) -> void:
	for i in 5:
		await get_tree().process_frame
	_cam.global_position = target + offset_kamera
	_cam.look_at(target + Vector3(0, 0.9, 0), Vector3.UP)
	for i in 3:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _angka(tag: String, node: Node3D, visual: Node3D, sarung: MeshInstance3D, leg_l: Node3D, knee_l: Node3D) -> void:
	print("ANGKA %s: node_y=%.2f visual_y=%.2f sarung_scale=%s leg_l.rot=%s knee_l.rot.x=%.2f" % [
		tag, node.position.y, visual.position.y, str(sarung.scale),
		str(leg_l.rotation), knee_l.rotation.x])


func _tunggu_frame(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	_siapatkan_dunia()
	# ---------- NPC putra: bersila di lantai ----------
	_npc = SantriNPC.new()
	_npc.setup("Hasan", Vector3(0, 0, 0), [], MissionData.OUTFIT_DEFAULT, false, {}, true, true)
	add_child(_npc)
	await _tunggu_frame(10)
	_npc._terapkan_duduk_baca(1.0)
	await _tunggu_frame(90)
	_angka("NPC-BERSILA", _npc, _npc._visual, _npc._sarung, _npc._leg_l, _npc._knee_l)
	await _foto("pose-bersila-depan-sebelum.png", Vector3(0, 0, 0), Vector3(0.0, 1.0, 3.2))
	await _foto("pose-bersila-samping-sebelum.png", Vector3(0, 0, 0), Vector3(3.2, 1.0, 0.0))
	# ---------- NPC putra: duduk di kursi (jalur KODE saat ini) ----------
	# Bangku taman putra 1a (posisi asli registry).
	var bangku_pos := Vector3(-3.4, 0.45, 25.45)
	_bangku(Vector3(-3.4, 0, 25.45), 0.0)
	# Jalur asli _proses_aktivitas "ke_kursi" -> sampai: position = sp.
	_npc.position = bangku_pos
	_npc._visual.rotation.y = 0.0
	_npc._terapkan_duduk_baca(1.0)
	await _tunggu_frame(90)
	_angka("NPC-KURSI-BERSILA", _npc, _npc._visual, _npc._sarung, _npc._leg_l, _npc._knee_l)
	await _foto("pose-kursi-bersila-sebelum.png", bangku_pos, Vector3(0.0, 1.0, 3.2))
	# ---------- NPC: berdiri dari kursi (jalur KODE saat ini) ----------
	# _akhiri_aktivitas() lalu idle — node y TETAP 0,45 (bug 4).
	_npc._akhiri_aktivitas()
	_npc._pause_timer = 5.0
	await _tunggu_frame(90)
	_angka("NPC-BERDIRI-DARI-KURSI", _npc, _npc._visual, _npc._sarung, _npc._leg_l, _npc._knee_l)
	await _foto("pose-berdiri-dari-kursi-sebelum.png", _npc.position, Vector3(0.0, 1.0, 3.2))
	# ---------- PEMAIN: bersila ----------
	_pemain = SantriPlayer.new()
	_pemain.position = Vector3(6, 0, 0)
	add_child(_pemain)
	await _tunggu_frame(10)
	_pemain.set_aksi("duduk")
	await _tunggu_frame(90)
	_angka("PEMAIN-BERSILA", _pemain, _pemain._visual, _pemain._sarung, _pemain._leg_l, _pemain._knee_l)
	await _foto("pose-pemain-bersila-depan-sebelum.png", Vector3(6, 0, 0), Vector3(0.0, 1.0, 3.2))
	await _foto("pose-pemain-bersila-samping-sebelum.png", Vector3(6, 0, 0), Vector3(3.2, 1.0, 0.0))
	# ---------- PEMAIN: berdiri setelah bersila (bug 1 — pemain) ----------
	_pemain.set_aksi("berdiri")
	await _tunggu_frame(90)
	_angka("PEMAIN-BERDIRI-SETELAH-BERSILA", _pemain, _pemain._visual, _pemain._sarung, _pemain._leg_l, _pemain._knee_l)
	await _foto("pose-pemain-berdiri-setelah-bersila-sebelum.png", Vector3(6, 0, 0), Vector3(0.0, 1.0, 3.2))
	print("FOTO POSE KURSI SELESAI")
	get_tree().quit(0)
