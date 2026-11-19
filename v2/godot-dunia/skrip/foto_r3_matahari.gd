extends Node
## Foto R3 SAJA (ulangan — run sebelumnya kena timeout 180 dtk):
##   xvfb-run godot --path . skrip/foto_r3_matahari.tscn
## Matahari jam 17:00 (azim 252° = barat-barat daya) dari depan
## pintu Surau lurus, menghadap barat-barat daya.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-revisi-surau-lurus/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto R3 matahari")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	LangitDinamis.debug_jam = 17.0
	_cam.global_position = Vector3(0, 2.5, -4.5)
	_cam.look_at(Vector3(-38, 4, 8), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "R3-matahari-1700-barat.png")
	print("FOTO R3 -> %s (err=%s)" % [OUT_DIR + "R3-matahari-1700-barat.png", str(err)])
	print("FOTO R3 SELESAI")
	get_tree().quit(0)
