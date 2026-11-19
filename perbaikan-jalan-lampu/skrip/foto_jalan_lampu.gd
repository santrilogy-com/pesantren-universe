extends Node
## Foto perbaikan jalan + lampu Surau. Dijalankan sebagai SCENE (.tscn).
## Jam dibekukan 10.00 (pagi, langit biru). Kamera bebas; pemain
## diteleport ke jalan baru untuk foto pendekatan.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/foto-jalan-lampu/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._on_login("PV-0001", "Tes")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	await _foto("01-jalan-lurus.png", Vector3(8, 3.5, 10), Vector3(-3.5, 1.0, -5.0), "pemain di spawn")
	await _foto("02-pendekatan.png", Vector3(-6.5, 2.0, 4.5), Vector3(-2.11, 1.0, -7.47), "pemain di jalan s=6")
	await _foto("03-pintu-lampu.png", Vector3(2.5, 2.0, -1.5), Vector3(-3.0, 1.2, -7.0), "pemain di spawn")
	await _foto("04-dari-pintu.png", Vector3(-2.11, 2.0, -7.47), Vector3(-5.6, 1.0, 0.0), "pemain di pintu")
	await _foto("05-kyai-jalan.png", Vector3(0.5, 2.2, 5.0), Vector3(-4.8, 1.2, -4.8), "pemain di spawn")
	print("FOTO SELESAI")
	get_tree().quit(0)


func _atur_pemain(mode: String) -> void:
	if mode == "pemain di jalan s=6":
		_main._player.global_position = Vector3(-4.65, 0, -2.03)
		_main._player.velocity = Vector3.ZERO
	elif mode == "pemain di pintu":
		_main._player.global_position = Vector3(-2.75, 0, -6.11)
		_main._player.velocity = Vector3.ZERO
	else:
		_main._player.global_position = Vector3(0, 0, 14)
		_main._player.velocity = Vector3.ZERO


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, mode_pemain: String) -> void:
	_atur_pemain(mode_pemain)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
