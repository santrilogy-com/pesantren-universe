extends Node
## Foto samping Surau saja — jalankan TANPA --headless:
##   xvfb-run godot --path . skrip/foto_samping_surau.tscn
## Alasan skrip terpisah: foto_pencahayaan.gd penuh (16 shot) kena timeout 300 dtk.
## main.gd _ready() SUDAH memasang modul otomatis (sejak 23:21), jadi untuk
## shot SEBELUM yang benar modul harus dicopot dulu, lalu dipasang lagi.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto samping surau")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# --- SEBELUM: copot modul yang dipasang otomatis main.gd ---
	var modul := _main.find_child("PencahayaanV2", true, false)
	if modul != null:
		modul.queue_free()
		for i in 5:
			await get_tree().process_frame
	await _foto("L7-surau-barat-malam-sebelum.png", Vector3(-16, 3.5, -2), Vector3(-8, 2, -14), 21.0)
	await _foto("L8-surau-timur-malam-sebelum.png", Vector3(12, 3.5, -2), Vector3(8, 2, -14), 21.0)
	# --- SESUDAH: pasang modul lagi ---
	PencahayaanV2.pasang(_main, _main._outdoor_door)
	for i in 10:
		await get_tree().process_frame
	await _foto("L7-surau-barat-malam-sesudah.png", Vector3(-16, 3.5, -2), Vector3(-8, 2, -14), 21.0)
	await _foto("L8-surau-timur-malam-sesudah.png", Vector3(12, 3.5, -2), Vector3(8, 2, -14), 21.0)
	LangitDinamis.debug_jam = -1.0
	print("FOTO SAMPING SURAU SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float) -> void:
	LangitDinamis.debug_jam = jam
	_main._set_interior_terlihat(false, false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
