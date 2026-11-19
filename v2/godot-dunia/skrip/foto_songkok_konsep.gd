extends Node
## Foto konsep songkok (Kirana, 19 Nov 2026) — masukan Mas 14:00 WIB:
## (1) songkok putra menutupi sebagian mata; (2) songkok jangan bulat
## semua — perlu SONGKOK HITAM NASIONAL (peci hitam, atas rata).
## KONSEP SAJA — tidak ada kode game yang diubah. Semua varian dibuat
## di skrip ini dengan menggeser/menyembunyikan node Peci hasil
## build_visual (runtime, hanya di scene foto ini).
##
## Geometri terukur (player.gd): kepala bola r=0.24 di (0,1.66,0);
## mata r=0.025 (skala y 1.25) di (±0.085, 1.69, 0.222) → mata
## membentang y 1.659–1.721. Peci bulat SEKARANG: bola r=0.265 di
## (0,1.77,0), skala y 0.70 → tepi bawah di posisi mata
## (d=0.2377) y = 1.77 − 0.70·√(0.265²−0.2377²) = 1.688 → menutupi
## SETENGAH ATAS mata (1.688–1.721). Itu yang Mas lihat.
## SESUDAH (bulat diperbaiki): pusat y 1.82, skala y 0.68 →
## tepi bawah di mata y = 1.740 (1,9 cm di atas puncak mata);
## puncak kubah 2.00 (< 2.10 audit); band y 1.80, r 0.255/0.265.
## PECI NASIONAL: kerucut terpancung atas RATA — silinder atas
## r=0.205, bawah r=0.235, tinggi 0.18, pusat y=1.825 (tepi 1.735,
## puncak 1.915 > puncak kepala 1.90); lis bawah r 0.235/0.24
## h=0.03 di y=1.75; warna hitam #151515, lis #0d0d0d.
## Jalankan (pola Sinta, Xvfb :95 sudah jalan):
##   DISPLAY=:95 <godot-4.7> --audio-driver Dummy --path . skrip/foto_songkok_konsep.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/konsep/"

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
	# A = SEBELUM (apa adanya), B = SESUDAH bulat diperbaiki,
	# C = PECI HITAM NASIONAL.
	var a := _santri("Sebelum", Vector3(-1.7, 0, 0))
	var b := _santri("Bulat Baru", Vector3(0, 0, 0))
	_perbaiki_bulat(b)
	var c := _santri("Peci Hitam", Vector3(1.7, 0, 0))
	_pasang_peci_nasional(c)
	for k in 5:
		await get_tree().process_frame
	# Ukur tepi bawah peci di posisi mata (d = 0.2377 dari sumbu).
	var d_mata := sqrt(0.085 * 0.085 + 0.222 * 0.222)
	var tepi_sebelum := 1.77 - 0.70 * sqrt(0.265 * 0.265 - d_mata * d_mata)
	var tepi_sesudah := 1.82 - 0.68 * sqrt(0.265 * 0.265 - d_mata * d_mata)
	print("UKUR: mata y 1.659-1.721 | tepi SEBELUM %.3f (tutup atas mata) | tepi SESUDAH %.3f | tepi PECI 1.735" % [tepi_sebelum, tepi_sesudah])
	# 1-2. SEBELUM: depan + samping.
	await _foto("konsep-songkok-sebelum-depan.png", Vector3(-1.7, 1.72, 1.5), Vector3(-1.7, 1.68, 0))
	await _foto("konsep-songkok-sebelum-samping.png", Vector3(-0.2, 1.72, 0), Vector3(-1.7, 1.68, 0))
	# 3-4. SESUDAH bulat: depan + samping.
	await _foto("konsep-songkok-sesudah-depan.png", Vector3(0, 1.72, 1.5), Vector3(0, 1.68, 0))
	await _foto("konsep-songkok-sesudah-samping.png", Vector3(1.5, 1.72, 0), Vector3(0, 1.68, 0))
	# 5-6. PECI NASIONAL: depan + samping.
	await _foto("konsep-peci-nasional-depan.png", Vector3(1.7, 1.72, 1.5), Vector3(1.7, 1.68, 0))
	await _foto("konsep-peci-nasional-samping.png", Vector3(3.2, 1.72, 0), Vector3(1.7, 1.68, 0))
	# 7. Banding ketiganya, badan penuh.
	_cam.fov = 50.0
	await _foto("konsep-songkok-banding.png", Vector3(0, 1.35, 4.6), Vector3(0, 1.15, 0))
	print("FOTO KONSEP SONGKOK SELESAI")
	get_tree().quit(0)


func _santri(nama: String, pos: Vector3) -> Dictionary:
	var built := SantriPlayer.build_visual(nama, MissionData.OUTFIT_DEFAULT)
	var wadah := Node3D.new()
	wadah.position = pos
	wadah.add_child(built["root"])
	add_child(wadah)
	return built


func _perbaiki_bulat(built: Dictionary) -> void:
	# Peci + band tinggal di bawah KepalaPivot (posisi relatif pivot
	# di (0,1.66,0)). Naikkan: pusat 1.77 -> 1.82, skala y 0.70 -> 0.68.
	var root: Node = built["root"]
	var peci := root.find_child("Peci", true, false) as MeshInstance3D
	if peci != null:
		peci.position = Vector3(0, 0.16, 0)
		peci.scale = Vector3(1.0, 0.68, 1.0)
	var band := root.find_child("PeciBand", true, false) as MeshInstance3D
	if band != null:
		band.position = Vector3(0, 0.14, 0)
		band.scale = Vector3(0.98, 1.0, 0.98)


func _pasang_peci_nasional(built: Dictionary) -> void:
	# Sembunyikan songkok bulat, ganti peci hitam nasional (atas rata,
	# sedikit mengerucut). Dibangun di bawah KepalaPivot.
	var root: Node = built["root"]
	var peci := root.find_child("Peci", true, false) as MeshInstance3D
	if peci != null:
		peci.visible = false
	var band := root.find_child("PeciBand", true, false) as MeshInstance3D
	if band != null:
		band.visible = false
	var pivot := root.find_child("KepalaPivot", true, false) as Node3D
	if pivot == null:
		return
	var nasional := Node3D.new()
	nasional.name = "PeciNasional"
	# Badan: kerucut terpancung, atas rata. Pusat y dunia 1.825.
	var badan := Palette.cylinder(0.205, 0.235, 0.18, Vector3(0, 0.165, 0), Color("#151515"))
	badan.name = "PeciNasionalBadan"
	nasional.add_child(badan)
	# Lis bawah (jahitan tepi). Pusat y dunia 1.75.
	var lis := Palette.cylinder(0.235, 0.24, 0.03, Vector3(0, 0.09, 0), Color("#0d0d0d"))
	lis.name = "PeciNasionalLis"
	nasional.add_child(lis)
	pivot.add_child(nasional)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 30:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
