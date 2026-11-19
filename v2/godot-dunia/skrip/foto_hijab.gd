extends Node
## Foto diagnosis hijab putri (Kirana, 18 Nov 2026) — bug HP Mas 07:08 WIB:
## "jilbabnya kek bukan jilbab, kek lagi gendong benda aneh" (live alpha
## 2f90447b). Jalankan TANPA --headless (headless membuat save_png null),
## pola skrip/foto_karakter_primitif.gd:
##   xvfb-run godot --path . skrip/foto_hijab.tscn -- sebelum
##   xvfb-run godot --path . skrip/foto_hijab.tscn -- sesudah
## Argumen "sesudah" memilih sufiks file; tanpa argumen = "sebelum".
## 2 karakter berhijab (Santriwati + Ustadzah Mariyah) x sudut gameplay
## (depan, samping/profil, belakang, tiga-perempat, close-up wajah,
## jalan depan + jalan samping) x siang + malam (malam: depan, samping,
## belakang, jalan). Label nama disembunyikan supaya foto bersih.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-hijab/"

var _cam: Camera3D
var _sufiks := "sebelum"
var _env: Environment
var _matahari: DirectionalLight3D
var _isi: DirectionalLight3D
var _lampu_malam: OmniLight3D


func _karakter() -> Array:
	var putri := MissionData.OUTFIT_USTADZAH.duplicate()
	putri["abaya"] = "#007a61"
	putri["hijab_warna"] = "#f5e4cc"
	putri["kacamata"] = true
	putri["kulit"] = "#ffc09f"
	return [
		["putri", "Santriwati", putri],
		["ustadzah", "Ustadzah Mariyah", MissionData.OUTFIT_USTADZAH],
	]


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "sesudah":
			_sufiks = "sesudah"
	var env_node := WorldEnvironment.new()
	_env = Environment.new()
	env_node.environment = _env
	add_child(env_node)
	_matahari = DirectionalLight3D.new()
	_matahari.shadow_enabled = true
	add_child(_matahari)
	_isi = DirectionalLight3D.new()
	add_child(_isi)
	_lampu_malam = OmniLight3D.new()
	_lampu_malam.light_color = Color("#ffb46b")
	_lampu_malam.light_energy = 0.0
	_lampu_malam.omni_range = 6.0
	add_child(_lampu_malam)
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
	var dibangun: Array = []
	var i := 0
	for item in daftar:
		var slug: String = item[0]
		var nama: String = item[1]
		var outfit: Dictionary = item[2]
		var built: Dictionary = SantriPlayer.build_visual(nama, outfit)
		var root: Node3D = built["root"]
		root.position = Vector3((i - 0.5) * 4.0, 0, 0)
		(built["name_label"] as Label3D).visible = false
		add_child(root)
		dibangun.append(built)
		i += 1
	for k in 5:
		await get_tree().process_frame
	for j in range(daftar.size()):
		var slug: String = daftar[j][0]
		var x: float = (j - 0.5) * 4.0
		var built: Dictionary = dibangun[j]
		# Siang.
		_atur_cahaya(true, x)
		await _foto("%s_depan_siang_%s.png" % [slug, _sufiks], Vector3(x, 1.05, 2.4), Vector3(x, 1.0, 0))
		await _foto("%s_samping_siang_%s.png" % [slug, _sufiks], Vector3(x + 2.4, 1.05, 0), Vector3(x, 1.0, 0))
		await _foto("%s_belakang_siang_%s.png" % [slug, _sufiks], Vector3(x, 1.35, -2.4), Vector3(x, 1.0, 0))
		await _foto("%s_tigaperempat_siang_%s.png" % [slug, _sufiks], Vector3(x + 1.7, 1.35, 1.7), Vector3(x, 1.0, 0))
		await _foto("%s_wajah_siang_%s.png" % [slug, _sufiks], Vector3(x + 0.3, 1.72, 0.95), Vector3(x, 1.62, 0))
		_pose_jalan(built, true)
		await _foto("%s_jalan_depan_siang_%s.png" % [slug, _sufiks], Vector3(x, 1.05, 2.4), Vector3(x, 1.0, 0))
		await _foto("%s_jalan_samping_siang_%s.png" % [slug, _sufiks], Vector3(x + 2.4, 1.05, 0), Vector3(x, 1.0, 0))
		_pose_jalan(built, false)
		# Malam.
		_atur_cahaya(false, x)
		await _foto("%s_depan_malam_%s.png" % [slug, _sufiks], Vector3(x, 1.05, 2.4), Vector3(x, 1.0, 0))
		await _foto("%s_samping_malam_%s.png" % [slug, _sufiks], Vector3(x + 2.4, 1.05, 0), Vector3(x, 1.0, 0))
		await _foto("%s_belakang_malam_%s.png" % [slug, _sufiks], Vector3(x, 1.35, -2.4), Vector3(x, 1.0, 0))
		_pose_jalan(built, true)
		await _foto("%s_jalan_samping_malam_%s.png" % [slug, _sufiks], Vector3(x + 2.4, 1.05, 0), Vector3(x, 1.0, 0))
		_pose_jalan(built, false)
		_atur_cahaya(true, x)
	print("FOTO HIJAB SELESAI (%s)" % _sufiks)
	get_tree().quit(0)


func _atur_cahaya(siang: bool, x: float) -> void:
	if siang:
		_env.background_mode = Environment.BG_COLOR
		_env.background_color = Color("#efe9dc")
		_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		_env.ambient_light_color = Color("#fff6e6")
		_env.ambient_light_energy = 0.75
		_matahari.rotation_degrees = Vector3(-50, 30, 0)
		_matahari.light_color = Color("#fff2dd")
		_matahari.light_energy = 1.1
		_isi.rotation_degrees = Vector3(-20, -140, 0)
		_isi.light_color = Color("#dfe8ff")
		_isi.light_energy = 0.35
		_lampu_malam.light_energy = 0.0
	else:
		_env.background_mode = Environment.BG_COLOR
		_env.background_color = Color("#0b1226")
		_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		_env.ambient_light_color = Color("#33406b")
		_env.ambient_light_energy = 0.55
		_matahari.rotation_degrees = Vector3(-60, -40, 0)
		_matahari.light_color = Color("#8fa8ff")
		_matahari.light_energy = 0.45
		_isi.rotation_degrees = Vector3(-20, 140, 0)
		_isi.light_color = Color("#5a6ea8")
		_isi.light_energy = 0.15
		_lampu_malam.position = Vector3(x + 1.2, 2.2, 1.2)
		_lampu_malam.light_energy = 1.6


## Pose jalan tengah langkah (bukan idle): kaki berlawanan + lengan
## mengayun, supaya siluet hijab terlihat saat bergerak seperti di game.
func _pose_jalan(built: Dictionary, aktif: bool) -> void:
	var s := 1.0 if aktif else 0.0
	(built["leg_l"] as Node3D).rotation.x = 0.45 * s
	(built["leg_r"] as Node3D).rotation.x = -0.45 * s
	(built["knee_l"] as Node3D).rotation.x = -0.35 * s
	(built["knee_r"] as Node3D).rotation.x = -0.15 * s
	(built["arm_l"] as Node3D).rotation.x = -0.35 * s
	(built["arm_r"] as Node3D).rotation.x = 0.35 * s


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
