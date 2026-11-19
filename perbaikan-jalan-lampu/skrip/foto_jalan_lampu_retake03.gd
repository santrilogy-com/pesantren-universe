extends Node
## Retake foto 03 saja: pintu + lampu baru, dari sudut yang tidak menabrak lampu (2.2,-2).
## Foto 03 lama gagal framing: kamera (2.5,2,-1.5) hanya 0,6 m dari lampu (2.2,-2).
## Pola disamakan dengan foto_jalan_lampu.gd (extends Node, _ready, main.tscn, _on_login).

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
	# Pemain di spawn (0,0,14); kamera dari tenggara pintu, 3,2 m dari lampu (2.2,-2).
	_main._player.global_position = Vector3(0, 0, 14)
	_main._player.velocity = Vector3.ZERO
	_cam.global_position = Vector3(1.0, 2.2, 1.0)
	_cam.look_at(Vector3(-4.0, 1.2, -7.0), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "03-pintu-lampu.png")
	print("RETAKE 03-pintu-lampu.png -> %s (err=%s)" % [OUT_DIR + "03-pintu-lampu.png", str(err)])
	get_tree().quit(0)
