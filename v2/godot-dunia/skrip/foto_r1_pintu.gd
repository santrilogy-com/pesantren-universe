extends Node
## Foto R1 ULANG — GLB pintu TERBUKA (Bima, 23:05 WIB):
##   xvfb-run godot --path . skrip/foto_r1_pintu.tscn
## Spawn -> Surau lurus + pintu terbuka (dua daun jati ±110°).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-revisi-surau-lurus/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto R1 pintu terbuka")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	_cam.global_position = Vector3(-4, 2.5, 10)
	_cam.look_at(Vector3(0, 4, -14), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "R1-spawn-surau-pintu-terbuka.png")
	print("FOTO R1-pintu -> %s (err=%s)" % [OUT_DIR + "R1-spawn-surau-pintu-terbuka.png", str(err)])
	print("FOTO R1 PINTU SELESAI")
	get_tree().quit(0)
