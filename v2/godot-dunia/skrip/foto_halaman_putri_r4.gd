extends Node
## Foto TAMAN PUTRI — RONDE 4 (Dewi, 18 Nov 2026 — perintah Mas
## 14:17 WIB "Taman taruh di pojok aja.. jangan di depan musholla"):
## SELURUH isi r3 PINDAH ke pojok barat-daya (122,32); paving ke
## jalan DIPANJANGKAN + strip ke ujung selatan Jalan Internal.
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run -a godot --path . skrip/foto_halaman_putri_r4.tscn
## F1 overview dari tenggara atas | F2 dari ujung selatan Jalan
## Internal menghadap selatan ke taman (lewat strip + paving) |
## F3 dari utara (pemain + rumpun bunga + papan TAMAN PUTRI) |
## F4 portrait diagonal.

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
	_main._masuk_pesantren("Foto taman putri ronde 4")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Pemain santriwati di tengah taman pojok barat-daya.
	_main._teleport_player(Vector3(122, 0, 32), PI / 2.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r4-overview.png", Vector3(136, 16, 46), Vector3(122, 0, 32))
	await _foto("halaman-r4-dari-jalan.png", Vector3(142, 2.2, 16), Vector3(124, 0.8, 32))
	# F3: pemain hadap selatan (ke kamera).
	_main._teleport_player(Vector3(122, 0, 32), 0.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r4-pemain.png", Vector3(122, 2.0, 22.5), Vector3(122, 0.9, 32))
	# F4: portrait — pemain hadap tenggara (ke kamera diagonal).
	# Kamera digeser ke timur (x 129, bukan 127,5) supaya pohon
	# taman (124,29,8) tidak menutupi pemain dari sudut ini.
	get_window().size = Vector2i(390, 844)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(Vector3(122, 0, 32), PI / 4.0)
	for i in 10:
		await get_tree().process_frame
	await _foto("halaman-r4-portrait.png", Vector3(129, 2.6, 25.5), Vector3(122, 0.9, 32))
	print("FOTO TAMAN PUTRI RONDE 4 SELESAI")
	get_tree().quit(0)
