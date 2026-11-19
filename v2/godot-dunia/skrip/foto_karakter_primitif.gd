extends Node
## Foto karakter primitif v2 (Kirana, 17 Nov 2026) — jalankan TANPA
## --headless (headless membuat save_png null), pola skrip/foto_v2.gd:
##   xvfb-run godot --path . skrip/foto_karakter_primitif.tscn -- sebelum
##   xvfb-run godot --path . skrip/foto_karakter_primitif.tscn -- sesudah
## Argumen "sesudah" memilih sufiks file; tanpa argumen = "sebelum".
## 7 karakter (pemain putra/putri, Bilal, Faris, Kyai, Ustadzah,
## Satpam) x 4 sudut (depan, tiga-perempat, belakang, close-up wajah)
## + 1 foto grup. Label nama disembunyikan supaya foto bersih.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-karakter-primitif/"

var _cam: Camera3D
var _sufiks := "sebelum"


func _karakter() -> Array:
	var putri := MissionData.OUTFIT_USTADZAH.duplicate()
	putri["abaya"] = "#007a61"
	putri["hijab_warna"] = "#f5e4cc"
	putri["kacamata"] = true
	putri["kulit"] = "#ffc09f"
	var putra := MissionData.OUTFIT_DEFAULT.duplicate()
	putra["kacamata"] = true
	var bilal := MissionData.OUTFIT_DEFAULT.duplicate()
	bilal["sarung"] = "#1d4e6b"
	bilal["kulit"] = "#8a5a33"
	bilal["kacamata"] = true
	bilal["songkok"] = "#1a1a1a"
	var faris := MissionData.OUTFIT_DEFAULT.duplicate()
	faris["sarung"] = "#6b3a1d"
	faris["kulit"] = "#e8b98a"
	faris["kacamata"] = false
	faris["songkok"] = "#faf7f0"
	return [
		["putra", "Santri Putra", putra],
		["putri", "Santriwati", putri],
		["bilal", "Bilal", bilal],
		["faris", "Faris", faris],
		["kyai", "Ust. Aqsal Murad", MissionData.OUTFIT_KYAI],
		["ustadzah", "Ustadzah Mariyah", MissionData.OUTFIT_USTADZAH],
		["satpam", "Satpam", MissionData.OUTFIT_SATPAM],
	]


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "sesudah":
			_sufiks = "sesudah"
	# Langit + cahaya siang netral (rig foto saja, bukan lighting game).
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#efe9dc")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#fff6e6")
	e.ambient_light_energy = 0.75
	env.environment = e
	add_child(env)
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
	# Lantai netral.
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
	var daftar: Array = _karakter()
	var i := 0
	for item in daftar:
		var slug: String = item[0]
		var nama: String = item[1]
		var outfit: Dictionary = item[2]
		var built: Dictionary = SantriPlayer.build_visual(nama, outfit)
		var root: Node3D = built["root"]
		root.position = Vector3((i - 3) * 3.0, 0, 0)
		(built["name_label"] as Label3D).visible = false
		add_child(root)
		i += 1
	for i2 in 5:
		await get_tree().process_frame
	# Foto per karakter.
	for j in range(daftar.size()):
		var slug: String = daftar[j][0]
		var x := (j - 3) * 3.0
		await _foto("%s_depan_%s.png" % [slug, _sufiks], Vector3(x, 1.05, 2.4), Vector3(x, 1.0, 0))
		await _foto("%s_tigaperempat_%s.png" % [slug, _sufiks], Vector3(x + 1.7, 1.35, 1.7), Vector3(x, 1.0, 0))
		await _foto("%s_belakang_%s.png" % [slug, _sufiks], Vector3(x, 1.35, -2.4), Vector3(x, 1.0, 0))
		await _foto("%s_wajah_%s.png" % [slug, _sufiks], Vector3(x + 0.3, 1.72, 0.95), Vector3(x, 1.62, 0))
	# Foto grup.
	await _foto("semua_depan_%s.png" % _sufiks, Vector3(0, 1.6, 9.5), Vector3(0, 1.0, 0))
	print("FOTO KARAKTER SELESAI (%s)" % _sufiks)
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
