extends Node
## Foto PINTU LUAR PUTRI — Dewi, 18 Nov 2026 (perintah Mas 07:09 WIB).
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run -a godot --path . skrip/foto_pintu_luar_putri.tscn
## F1 Musholla (dari selatan, lewat celah pagar) | F2 KelasPutri |
## F3 AsramaPutri | F4 KantorUstadzah | F5 Madrasah | F6 Studio |
## F7 PosJagaTL | F8 overview kampus putri dari tenggara.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-pintu-luar-putri/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	# Siang hari (debug_jam LangitDinamis — memang untuk tes/foto):
	# foto malam (~00:30 WIB) terlalu gelap, daun jati tidak terbaca.
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["role"] = "keamanan"
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto pintu luar putri")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	await _foto("F1-musholla-luar.png", Vector3(134, 2.6, -13.0), Vector3(134, 1.4, -19))
	await _foto("F2-kelas-luar.png", Vector3(130, 2.4, 20.5), Vector3(130, 1.4, 14))
	await _foto("F3-asrama-luar.png", Vector3(140, 2.4, 9), Vector3(146, 1.3, 9))
	await _foto("F4-kantor-luar.png", Vector3(138, 2.4, -33), Vector3(144, 1.3, -33))
	await _foto("F5-madrasah-luar.png", Vector3(141, 2.4, -12), Vector3(147, 1.3, -12))
	await _foto("F6-studio-luar.png", Vector3(166, 2.4, -22.5), Vector3(166, 1.3, -16))
	await _foto("F7-posjaga-luar.png", Vector3(168, 2.2, -20), Vector3(174.5, 1.0, -20))
	await _foto("F8-overview.png", Vector3(150, 25, 32), Vector3(152, 0, -14))
	print("FOTO SELESAI")
	get_tree().quit(0)
