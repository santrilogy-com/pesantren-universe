extends Node
## Foto verifikasi abaya RAMPING (Kirana, 19 Nov 2026) — koreksi Mas
## 16:34: "badannya kayak tabung elpiji" — abaya lama (0.23 -> 0.36)
## silinder seragam, lengan tenggelam di kerucut. Baru: A-line lembut
## 0.19 -> 0.30, lengan di luar badan. Berlaku untuk SEMUA pemakai
## abaya: Fatimah (#043B2C), Mariyah (#065F46), Penjaga (#7b4b2a).
## Santriwati TIDAK kena (tunik+sarung). Warna/palet/jilbab TIDAK
## berubah. Jalankan (pola foto_seragam_utama.gd, Xvfb display privat):
##   DISPLAY=:9X <godot-4.7> --audio-driver Dummy --path . skrip/foto_abaya_ramping.tscn

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
	_cam.fov = 40.0
	add_child(_cam)
	_cam.current = true
	# Karakter dengan outfit ASLI (bukan patch runtime).
	var fatimah := _karakter("Ustzh. Fatimah", Vector3(-1.3, 0, 0), NPCFatimah.OUTFIT_FATIMAH)
	var mariyah := _karakter("Ustadzah Mariyah", Vector3(1.3, 0, 0), MissionData.OUTFIT_USTADZAH)
	var penjaga := _karakter("Penjaga Pos Jaga", Vector3(3.9, 0, 0), MissionData.OUTFIT_PENJAGA_PUTRI)
	for k in 5:
		await get_tree().process_frame
	_ukur("Ustzh. Fatimah", fatimah["built"])
	_ukur("Ustadzah Mariyah", mariyah["built"])
	_ukur("Penjaga Pos Jaga", penjaga["built"])
	# 1-2. Fatimah: depan + samping.
	_cam.fov = 50.0
	await _foto("abaya-ramping-fatimah-depan.png", Vector3(-1.3, 1.1, 3.4), Vector3(-1.3, 1.0, 0))
	(mariyah["wadah"] as Node3D).visible = false
	(penjaga["wadah"] as Node3D).visible = false
	await _foto("abaya-ramping-fatimah-samping.png", Vector3(-4.5, 1.1, 0), Vector3(-1.3, 1.0, 0))
	(mariyah["wadah"] as Node3D).visible = true
	(penjaga["wadah"] as Node3D).visible = true
	# 3-4. Mariyah (regresi): depan + samping.
	await _foto("abaya-ramping-mariyah-depan.png", Vector3(1.3, 1.1, 3.4), Vector3(1.3, 1.0, 0))
	(fatimah["wadah"] as Node3D).visible = false
	(penjaga["wadah"] as Node3D).visible = false
	await _foto("abaya-ramping-mariyah-samping.png", Vector3(4.5, 1.1, 0), Vector3(1.3, 1.0, 0))
	(fatimah["wadah"] as Node3D).visible = true
	(penjaga["wadah"] as Node3D).visible = true
	# 5. Penjaga: depan.
	await _foto("abaya-ramping-penjaga-depan.png", Vector3(3.9, 1.1, 3.4), Vector3(3.9, 1.0, 0))
	# 6. Banding ketiganya.
	await _foto("abaya-ramping-banding.png", Vector3(1.3, 1.3, 8.0), Vector3(1.3, 1.0, 0))
	# 7. Fatimah DUDUK (pose belajar, skala ABAYA_DUDUK) — NPC asli,
	# bukan build_visual: duduk_belajar() me-lerp pose + pakaian.
	(fatimah["wadah"] as Node3D).visible = false
	(mariyah["wadah"] as Node3D).visible = false
	(penjaga["wadah"] as Node3D).visible = false
	var npc_fatimah := NPCFatimah.buat(self)
	npc_fatimah.position = Vector3(-1.3, 0, 0)
	for k in 5:
		await get_tree().process_frame
	npc_fatimah.duduk_belajar(0.0)
	for k in 60:
		await get_tree().process_frame
	await _foto("abaya-ramping-fatimah-duduk.png", Vector3(-1.3, 1.0, 3.4), Vector3(-1.3, 0.7, 0))
	print("FOTO ABAYA RAMPING SELESAI")
	get_tree().quit(0)


func _karakter(nama: String, pos: Vector3, outfit: Dictionary) -> Dictionary:
	var built := SantriPlayer.build_visual(nama, outfit)
	var wadah := Node3D.new()
	wadah.position = pos
	wadah.add_child(built["root"])
	add_child(wadah)
	return {"wadah": wadah, "built": built}


func _ukur(nama: String, built: Dictionary) -> void:
	var root: Node = built["root"]
	var abaya := root.find_child("Abaya", true, false) as MeshInstance3D
	var sil := abaya.mesh as CylinderMesh if abaya != null else null
	var bahu := root.find_child("BahuKiri", true, false) as Node3D
	var pivot_x := absf((bahu.get_parent() as Node3D).position.x) if bahu != null else 0.0
	print("UKUR %s: abaya atas=%.2f bawah=%.2f pivot_lengan=%.2f" % [nama, sil.top_radius if sil != null else -1.0, sil.bottom_radius if sil != null else -1.0, pivot_x])


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
