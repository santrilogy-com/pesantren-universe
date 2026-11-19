extends Node
## Foto INTERIOR GEDUNG PUTRI (Lestari, Tim Area Putri, 18 Nov 2026).
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_interior_gedung_putri.tscn
## Empat foto, satu per interior: kantor, madrasah, studio, pos jaga.
## Interior dibangun langsung (tanpa main.tscn); WorldEnvironment
## ambient ditambahkan supaya render tidak hitam.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _cam: Camera3D


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var kantor: Dictionary = InteriorGedungPutri.build_kantor()
	var madrasah: Dictionary = InteriorGedungPutri.build_madrasah()
	var studio: Dictionary = InteriorGedungPutri.build_studio()
	var pos: Dictionary = InteriorGedungPutri.build_pos_jaga()
	add_child(kantor["root"])
	add_child(madrasah["root"])
	add_child(studio["root"])
	add_child(pos["root"])
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#1a1a22")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#fff2dd")
	e.ambient_light_energy = 0.5
	env.environment = e
	add_child(env)
	_cam = Camera3D.new()
	_cam.fov = 60.0
	_cam.near = 0.1
	add_child(_cam)
	_cam.current = true
	for i in 10:
		await get_tree().process_frame
	# Kantor: dari sudut barat-daya, lihat meja + lemari + papan utara.
	await _foto("kantor-ustadzah.png", Vector3(-123.2, 2.2, -297.9), Vector3(-117.5, 1.0, -301.8))
	# Madrasah: dari sudut barat-daya, lihat papan tulis + meja guru.
	await _foto("madrasah.png", Vector3(-184.0, 2.4, -297.0), Vector3(-177.5, 1.0, -302.5))
	# Studio: dari dekat pintu utara, lihat papan + meja barat
	# (pintu TIDAK diframing — celah pintu terbuka ke void hitam,
	# sama seperti interior Surau/Cangkruk; lihat pertanyaan terbuka).
	await _foto("studio.png", Vector3(241.0, 2.3, -303.0), Vector3(238.5, 1.0, -296.8))
	# Pos jaga: dari sudut barat-laut, lihat meja + lemari + papan jadwal.
	await _foto("pos-jaga.png", Vector3(178.8, 2.0, -300.6), Vector3(180.7, 0.8, -299.5))
	print("FOTO INTERIOR GEDUNG PUTRI SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
