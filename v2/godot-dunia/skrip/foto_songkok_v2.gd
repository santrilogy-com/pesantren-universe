extends Node
## Foto verifikasi songkok v2 (Kirana, 19 Nov 2026) — KONSEP SONGKOK v1
## sudah DIBANGUN ke game (player.gd + kunci peci_model, ACC Mas 14:07).
## Verifikasi: (1) songkok bulat posisi baru — mata terlihat PENUH;
## (2) peci hitam nasional — terbaca sebagai peci Indonesia, mata
## penuh; (3) pembagian pemakai sesuai ACC (Satpam nasional;
## Bilal/Faris/Sanusi hash 50/50; pemain default bulat putih).
## Karakter dibangun dengan outfit ASLI (main.gd / onboarding.gd /
## mission_data.gd) — tanpa patch runtime.
## Jalankan (pola Sinta, Xvfb display privat):
##   DISPLAY=:9X <godot-4.7> --audio-driver Dummy --path . skrip/foto_songkok_v2.tscn

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
	# 5 karakter dengan outfit ASLI (bukan patch runtime).
	var santri := _karakter("Santri", Vector3(-3.4, 0, 0), MissionData.OUTFIT_DEFAULT)
	var outfit_bilal := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_bilal["sarung"] = "#1d4e6b"
	outfit_bilal["kulit"] = "#8a5a33"
	outfit_bilal["kacamata"] = true
	outfit_bilal["songkok"] = "#1a1a1a"
	outfit_bilal["peci_model"] = SantriPlayer.peci_model_untuk("Bilal")
	var bilal := _karakter("Bilal", Vector3(-1.7, 0, 0), outfit_bilal)
	var outfit_faris := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_faris["sarung"] = "#6b3a1d"
	outfit_faris["kulit"] = "#e8b98a"
	outfit_faris["kacamata"] = false
	outfit_faris["songkok"] = "#faf7f0"
	outfit_faris["peci_model"] = SantriPlayer.peci_model_untuk("Faris")
	var faris := _karakter("Faris", Vector3(0, 0, 0), outfit_faris)
	var outfit_sanusi := Onboarding.OUTFIT_SANUSI.duplicate()
	outfit_sanusi["peci_model"] = SantriPlayer.peci_model_untuk("Ust. Sanusi")
	var sanusi := _karakter("Ust. Sanusi", Vector3(1.7, 0, 0), outfit_sanusi)
	var satpam := _karakter("Satpam", Vector3(3.4, 0, 0), MissionData.OUTFIT_SATPAM)
	for k in 5:
		await get_tree().process_frame
	# Ukur tepi bawah peci di posisi mata (d = 0.2377 dari sumbu).
	# Mata membentang y 1.659–1.721; tepi harus > 1.721 = mata penuh.
	_ukur("Santri", santri, "bulat")
	_ukur("Bilal", bilal, String(outfit_bilal["peci_model"]))
	_ukur("Faris", faris, String(outfit_faris["peci_model"]))
	_ukur("Ust. Sanusi", sanusi, String(outfit_sanusi["peci_model"]))
	_ukur("Satpam", satpam, "nasional")
	# 1-2. Bulat (Santri): depan + samping.
	await _foto("songkok-v2-santri-depan.png", Vector3(-3.4, 1.72, 1.5), Vector3(-3.4, 1.68, 0))
	await _foto("songkok-v2-santri-samping.png", Vector3(-1.9, 1.72, 0), Vector3(-3.4, 1.68, 0))
	# 3-4. Nasional (Satpam): depan + samping.
	await _foto("songkok-v2-satpam-depan.png", Vector3(3.4, 1.72, 1.5), Vector3(3.4, 1.68, 0))
	await _foto("songkok-v2-satpam-samping.png", Vector3(4.9, 1.72, 0), Vector3(3.4, 1.68, 0))
	# 5-7. Depan Bilal / Faris / Sanusi (bukti hash 50/50 ter-render).
	await _foto("songkok-v2-bilal-depan.png", Vector3(-1.7, 1.72, 1.5), Vector3(-1.7, 1.68, 0))
	await _foto("songkok-v2-faris-depan.png", Vector3(0, 1.72, 1.5), Vector3(0, 1.68, 0))
	await _foto("songkok-v2-sanusi-depan.png", Vector3(1.7, 1.72, 1.5), Vector3(1.7, 1.68, 0))
	# 8. Banding kelimanya, badan penuh.
	_cam.fov = 50.0
	await _foto("songkok-v2-banding.png", Vector3(0, 1.4, 8.0), Vector3(0, 1.1, 0))
	print("FOTO SONGKOK V2 SELESAI")
	get_tree().quit(0)


func _karakter(nama: String, pos: Vector3, outfit: Dictionary) -> Dictionary:
	var built := SantriPlayer.build_visual(nama, outfit)
	var wadah := Node3D.new()
	wadah.position = pos
	wadah.add_child(built["root"])
	add_child(wadah)
	return built


func _ukur(nama: String, built: Dictionary, model_harapan: String) -> void:
	var root: Node = built["root"]
	var peci := root.find_child("Peci", true, false) as MeshInstance3D
	if peci == null:
		print("UKUR %s: PECI TIDAK KETEMU (serban/jilbab?)" % nama)
		return
	var d_mata := sqrt(0.085 * 0.085 + 0.222 * 0.222)
	var tepi := 0.0
	var jenis := "?"
	var model_aktual := "?"
	if peci.mesh is SphereMesh:
		var r: float = (peci.mesh as SphereMesh).radius
		tepi = peci.global_position.y - peci.scale.y * sqrt(r * r - d_mata * d_mata)
		jenis = "sphere r=%.3f" % r
		model_aktual = "bulat"
	elif peci.mesh is CylinderMesh:
		var h: float = (peci.mesh as CylinderMesh).height
		tepi = peci.global_position.y - h / 2.0
		jenis = "cylinder h=%.2f" % h
		model_aktual = "nasional"
	var cocok := "COCOK" if model_aktual == model_harapan else "TIDAK COCOK"
	var status := "MATA PENUH" if tepi > 1.721 else "MATA TERTUTUP"
	print("UKUR %s: model=%s (harapan %s, %s) mesh=%s tepi-mata=%.3f vs puncak mata 1.721 -> %s" % [nama, model_aktual, model_harapan, cocok, jenis, tepi, status])


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
