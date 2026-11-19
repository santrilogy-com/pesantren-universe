extends Node
## Foto pintu DEKAT — verifikasi GLB baru benar-benar terpakai:
##   xvfb-run godot --path . skrip/foto_pintu_dekat.tscn
## Kamera 4,5 m di depan pintu lurus, lurus ke arah pintu (0,-6).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-revisi-surau-lurus/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto pintu dekat")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true
	_cam.global_position = Vector3(0, 2.0, -1.5)
	_cam.look_at(Vector3(0, 1.6, -6), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "R1-pintu-dekat.png")
	print("FOTO pintu-dekat -> %s (err=%s)" % [OUT_DIR + "R1-pintu-dekat.png", str(err)])
	print("FOTO PINTU DEKAT SELESAI")
	get_tree().quit(0)
