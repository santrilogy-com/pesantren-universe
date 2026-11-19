extends Node
## Foto HALAMAN/TAMAN BEKAS CANGKRUK PUTRI — RONDE 2 (Dewi, 18 Nov 2026
## — perintah Mas 13:47 WIB "Tidak usah kotak putih gitu.. langsung
## bunga.. terus kasih paving.."): box bedeng dihapus, bunga langsung
## di tanah, paving dalam taman (jalur tengah + bingkai).
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run -a godot --path . skrip/foto_halaman_putri_r2.tscn
## F1 overview dari tenggara atas | F2 dari jalan internal lewat
## paving (pemain di halaman, hadap kamera) | F3 dari selatan
## (pemain + rumpun bunga + papan TAMAN PUTRI) | F4 portrait diagonal.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s) pemain=%s" % [nama, OUT_DIR + nama, str(err),
		str(_main._player.global_position)])


func _ready() -> void:
	# Siang hari (debug_jam LangitDinamis — memang untuk tes/foto):
	# rumput + bunga harus terbaca warnanya, bukan gelap.
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto halaman putri ronde 2")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Pemain santriwati di tengah halaman.
	_main._teleport_player(Vector3(128, 0, -12), PI / 2.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r2-overview.png", Vector3(140, 16, 2), Vector3(128, 0, -12))
	await _foto("halaman-r2-dari-jalan.png", Vector3(141.5, 2.2, -12), Vector3(128, 0.8, -12))
	# F3: pemain hadap selatan (ke kamera).
	_main._teleport_player(Vector3(128, 0, -12), 0.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r2-pemain.png", Vector3(128, 2.0, -2.5), Vector3(128, 0.9, -12))
	# F4: portrait — pemain hadap tenggara (ke kamera diagonal).
	get_window().size = Vector2i(390, 844)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(Vector3(128, 0, -12), PI / 4.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r2-portrait.png", Vector3(133.5, 2.6, -5.5), Vector3(128, 0.9, -12))
	print("FOTO HALAMAN PUTRI RONDE 2 SELESAI")
	get_tree().quit(0)
