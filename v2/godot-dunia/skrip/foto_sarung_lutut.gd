extends Node
## Foto VERIFIKASI tonjolan lutut bersila v2 (Kirana, 20 Nov 2026 —
## verdict Mas 01:28 WIB "Ketika duduk bersila masih mekar sarungnya"
## atas foto pose-bersila-depan-sesudah): gundukan v2 masih kerucut
## mulus dari depan — dua tonjolan lutut (mesh baru) harus terbaca
## sebagai dua gundukan kiri-kanan depan, bukan kerucut.
## Nama file BARU (-lutut) supaya cache HP Mas tidak menampilkan
## foto lama. Memakai SantriNPC + SantriPlayer SUNGGUHAN di scene
## kosong (pola foto_sarung_pose_kursi.gd).
## Jalankan: Xvfb :NN -screen 0 1280x720x24 & DISPLAY=:NN
##   HOME=/tmp/iso-lutut godot --path . --resolution 1280x720
##   --audio-driver Dummy --scene res://skrip/foto_sarung_lutut.tscn

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
	var kotak := BoxShape3D.new()
	kotak.size = Vector3(60, 1, 60)
	bentuk.shape = kotak
	bentuk.position = Vector3(0, -0.5, 0)
	lantai_fisik.add_child(bentuk)
	add_child(lantai_fisik)
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true


func _bangku(pos: Vector3, yaw: float) -> Node3D:
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


func _angka_lutut(tag: String, node: Node3D, visual: Node3D, sarung: MeshInstance3D, lutut_l: MeshInstance3D, lutut_r: MeshInstance3D) -> void:
	print("ANGKA %s: node_y=%.2f visual_y=%.2f sarung_scale=%s lutut_l visible=%s scale=%s pos=%s | lutut_r visible=%s scale=%s pos=%s" % [
		tag, node.position.y, visual.position.y, str(sarung.scale),
		str(lutut_l.visible), str(lutut_l.scale), str(lutut_l.position),
		str(lutut_r.visible), str(lutut_r.scale), str(lutut_r.position)])


func _tunggu_frame(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	_siapkan_dunia()
	# ---------- NPC putra: bersila di lantai (tonjolan lutut) ----------
	_npc = SantriNPC.new()
	_npc.setup("Hasan", Vector3(0, 0, 0), [], MissionData.OUTFIT_DEFAULT, false, {}, true, true)
	add_child(_npc)
	_npc.set_process(false)
	await _tunggu_frame(10)
	_npc._terapkan_duduk_baca(1.0)
	await _tunggu_frame(90)
	_angka_lutut("NPC-BERSILA-LUTUT", _npc, _npc._visual, _npc._sarung, _npc._lutut_l, _npc._lutut_r)
	await _foto("pose-bersila-depan-lutut-v2.png", Vector3(0, 0, 0), Vector3(0.0, 1.0, 3.2))
	await _foto("pose-bersila-samping-lutut-v2.png", Vector3(0, 0, 0), Vector3(3.2, 1.0, 0.0))
	# ---------- NPC putra: duduk di kursi (REGRESI — tonjolan HARUS sembunyi) ----------
	var bangku_pos := Vector3(-3.4, 0.45, 25.45)
	_bangku(Vector3(-3.4, 0, 25.45), 0.0)
	var bangku: Dictionary = SantriNPC.KURSI_LUAR[0]
	_npc.position = Vector3(bangku_pos.x, 0.0, bangku_pos.z)
	_npc._aktivitas = "duduk"
	_npc._aktivitas_kursi = bangku
	_npc._aktivitas_yaw = float(bangku["yaw"])
	_npc._aktivitas_timer = 60.0
	for i in 3:
		_npc._proses_aktivitas(1.0)
	await _tunggu_frame(90)
	_angka_lutut("NPC-KURSI-LUTUT", _npc, _npc._visual, _npc._sarung, _npc._lutut_l, _npc._lutut_r)
	await _foto("pose-kursi-depan-lutut-v2.png", bangku_pos, Vector3(0.0, 1.0, 3.2))
	_npc.visible = false
	# ---------- PEMAIN: bersila ----------
	_pemain = SantriPlayer.new()
	var bentuk := CollisionShape3D.new()
	var kapsul := CapsuleShape3D.new()
	kapsul.radius = 0.35
	kapsul.height = 1.7
	bentuk.shape = kapsul
	bentuk.position = Vector3(0, 0.85, 0)
	_pemain.add_child(bentuk)
	_pemain.position = Vector3(6, 0, 0)
	add_child(_pemain)
	await _tunggu_frame(10)
	_pemain.set_aksi("duduk")
	await _tunggu_frame(90)
	_angka_lutut("PEMAIN-BERSILA-LUTUT", _pemain, _pemain._visual, _pemain._sarung, _pemain._lutut_l, _pemain._lutut_r)
	await _foto("pose-pemain-bersila-depan-lutut-v2.png", Vector3(6, 0, 0), Vector3(0.0, 1.0, 3.2))
	_pemain.visible = false
	# ---------- FATIMAH (abaya): bersila ----------
	var fatimah := SantriNPC.new()
	fatimah.setup("Fatimah", Vector3(12, 0, 0), [], MissionData.OUTFIT_USTADZAH, true)
	add_child(fatimah)
	fatimah.set_process(false)
	await _tunggu_frame(10)
	fatimah._terapkan_duduk_baca(1.0, true, 0.0)
	await _tunggu_frame(90)
	_angka_lutut("FATIMAH-BERSILA-LUTUT", fatimah, fatimah._visual, fatimah._sarung, fatimah._lutut_l, fatimah._lutut_r)
	await _foto("pose-fatimah-bersila-depan-lutut-v2.png", Vector3(12, 0, 0), Vector3(0.0, 1.0, 3.2))
	await _foto("pose-fatimah-bersila-samping-lutut-v2.png", Vector3(12, 0, 0), Vector3(3.2, 1.0, 0.0))
	print("FOTO LUTUT SELESAI")
	get_tree().quit(0)
