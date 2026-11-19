extends Node
## Foto verifikasi seragam utama v2 (Kirana, 19 Nov 2026) — KONSEP
## SERAGAM UTAMA v1 sudah DIBANGUN ke game (ACC Mas 15:41).
## Verifikasi: (1) putra baju putih + sarung hijau garis kuning tipis
## vertikal; (2) putri tunik biru langit + sarung batik coklat + jilbab
## putih (BUKAN abaya); (3) Ustadzah Mariyah TETAP abaya.
## Karakter dibangun dengan outfit ASLI (mission_data.gd / room_config
## / npc_fatimah.gd) — tanpa patch runtime.
## Jalankan (pola foto_songkok_v2.gd, Xvfb display privat):
##   DISPLAY=:9X <godot-4.7> --audio-driver Dummy --path . skrip/foto_seragam_utama.tscn

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
	var putra := _karakter("Santri", Vector3(-1.3, 0, 0), MissionData.OUTFIT_DEFAULT)
	var putri := _karakter("Santriwati", Vector3(1.3, 0, 0), RoomConfig.outfit_untuk("putri"))
	var mariyah := _karakter("Ustadzah Mariyah", Vector3(3.9, 0, 0), MissionData.OUTFIT_USTADZAH)
	for k in 5:
		await get_tree().process_frame
	# Ukur: putra/putri punya Sarung (bukan Abaya); Mariyah Abaya.
	_ukur("Santri (putra)", putra["built"])
	_ukur("Santriwati (putri)", putri["built"])
	_ukur("Ustadzah Mariyah", mariyah["built"])
	# 1-2. Putra: depan + samping (badan penuh).
	_cam.fov = 50.0
	await _foto("seragam-utama-putra-depan.png", Vector3(-1.3, 1.1, 3.4), Vector3(-1.3, 1.0, 0))
	# Samping: foto SATU karakter saja — tetangga di sumbu-x menutupi
	# subjek bila kamera di sumbu-x (foto pertama: yang tampak malah
	# tunik putri / abaya Mariyah). Sembunyikan yang lain dulu.
	(putri["wadah"] as Node3D).visible = false
	(mariyah["wadah"] as Node3D).visible = false
	await _foto("seragam-utama-putra-samping.png", Vector3(-4.5, 1.1, 0), Vector3(-1.3, 1.0, 0))
	(putri["wadah"] as Node3D).visible = true
	(mariyah["wadah"] as Node3D).visible = true
	# 3-4. Putri: depan + samping (badan penuh).
	await _foto("seragam-utama-putri-depan.png", Vector3(1.3, 1.1, 3.4), Vector3(1.3, 1.0, 0))
	(putra["wadah"] as Node3D).visible = false
	(mariyah["wadah"] as Node3D).visible = false
	await _foto("seragam-utama-putri-samping.png", Vector3(4.5, 1.1, 0), Vector3(1.3, 1.0, 0))
	(putra["wadah"] as Node3D).visible = true
	(mariyah["wadah"] as Node3D).visible = true
	# 5. Banding ketiganya (putri di tengah: tunik vs abaya Mariyah).
	await _foto("seragam-utama-banding.png", Vector3(1.3, 1.3, 8.0), Vector3(1.3, 1.0, 0))
	print("FOTO SERAGAM UTAMA SELESAI")
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
	var ada_sarung := root.find_child("Sarung", true, false) != null
	var ada_abaya := root.find_child("Abaya", true, false) != null
	var tunik: bool = bool(built.get("tunik", false))
	print("UKUR %s: Sarung=%s Abaya=%s tunik=%s" % [nama, str(ada_sarung), str(ada_abaya), str(tunik)])


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
