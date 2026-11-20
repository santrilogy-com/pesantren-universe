extends Node
## Foto VERIFIKASI drape bersila v3 + sarung duduk kursi v2 (Kirana,
## 20 Nov 2026 — koreksi Mas 06:05 WIB "Yg jelas duduk bersila" +
## 06:06 "sama yg duduk kursi juga aneh"): gundukan + tonjolan lutut
## v2 DIPENSIUNKAN, diganti drape ArrayMesh yang mengikuti paha
## menyilang; tabung sarung di kursi DIROTASI mengikuti paha.
## Dari depan harus terbaca dua lutut + kain mengikuti paha
## menyilang (bukan gundukan), dan di bangku sarung menutupi paha
## (bukan tirai menggantung). Nama file BARU (-drape).
## Memakai SantriNPC + SantriPlayer SUNGGUHAN di scene kosong
## (pola foto_sarung_lutut.gd).
## Jalankan: Xvfb :NN -screen 0 1280x720x24 & DISPLAY=:NN
##   HOME=/tmp/iso-drape godot --path . --resolution 1280x720
##   --audio-driver Dummy --scene res://skrip/foto_sarung_drape.tscn

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


func _kursi_kantor(pos: Vector3, yaw: float) -> Node3D:
	# Kursi kantor sederhana: dudukan + sandaran + 4 kaki.
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	var kayu := StandardMaterial3D.new()
	kayu.albedo_color = Color("#7b4b2a")
	kayu.roughness = 0.9
	var dudukan := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.55, 0.07, 0.5)
	dudukan.mesh = bm
	dudukan.material_override = kayu
	dudukan.position = Vector3(0, 0.42, 0)
	root.add_child(dudukan)
	var sandaran := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.55, 0.6, 0.06)
	sandaran.mesh = sm
	sandaran.material_override = kayu
	sandaran.position = Vector3(0, 0.75, -0.24)
	root.add_child(sandaran)
	for sx in [-0.24, 0.24]:
		for sz in [-0.2, 0.2]:
			var kaki := MeshInstance3D.new()
			var km := BoxMesh.new()
			km.size = Vector3(0.06, 0.4, 0.06)
			kaki.mesh = km
			kaki.material_override = kayu
			kaki.position = Vector3(sx, 0.2, sz)
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


func _angka_drape(tag: String, node: Node3D, visual: Node3D, sarung: MeshInstance3D, drape: MeshInstance3D) -> void:
	print("ANGKA %s: node_y=%.2f visual_y=%.2f sarung_scale=%s rot_x=%.2f pos_z=%.2f | drape visible=%s scale=%s" % [
		tag, node.position.y, visual.position.y, str(sarung.scale), sarung.rotation.x, sarung.position.z,
		str(drape.visible), str(drape.scale)])


func _tunggu_frame(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	_siapkan_dunia()
# ---------- PEMAIN: bersila + menulis (cek kitab di atas drape) ----------
	_pemain = SantriPlayer.new()
	var bentuk := CollisionShape3D.new()
	var kapsul := CapsuleShape3D.new()
	kapsul.radius = 0.35
	kapsul.height = 1.7
	bentuk.shape = kapsul
	bentuk.position = Vector3(0, 0.85, 0)
	_pemain.add_child(bentuk)
	_pemain.position = Vector3(12, 0, 0)
	add_child(_pemain)
	await _tunggu_frame(10)
	_pemain.set_aksi("duduk")
	await _tunggu_frame(90)
	_angka_drape("PEMAIN-BERSILA-DRAPE", _pemain, _pemain._visual, _pemain._sarung, _pemain._drape)
	await _foto("pose-pemain-bersila-depan-v4.png", Vector3(12, 0, 0), Vector3(0.0, 1.0, 3.2))
	_pemain.set_aksi("menulis")
	await _tunggu_frame(90)
	await _foto("pose-pemain-menulis-v4.png", Vector3(12, 0, 0), Vector3(0.0, 1.0, 3.2))
	_pemain.visible = false
	# ---------- FATIMAH (abaya): bersila ----------
	var fatimah := SantriNPC.new()
	fatimah.setup("Fatimah", Vector3(18, 0, 0), [], MissionData.OUTFIT_USTADZAH, true)
	add_child(fatimah)
	fatimah.set_process(false)
	await _tunggu_frame(10)
	fatimah._terapkan_duduk_baca(1.0, true, 0.0)
	await _tunggu_frame(90)
	_angka_drape("FATIMAH-BERSILA-DRAPE", fatimah, fatimah._visual, fatimah._sarung, fatimah._drape)
	await _foto("pose-fatimah-bersila-depan-v4.png", Vector3(18, 0, 0), Vector3(0.0, 1.0, 3.2))
	await _foto("pose-fatimah-bersila-samping-v4.png", Vector3(18, 0, 0), Vector3(3.2, 1.0, 0.0))
	print("FOTO V4 SISA SELESAI")
	get_tree().quit(0)
