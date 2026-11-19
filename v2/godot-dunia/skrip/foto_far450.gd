extends Node
## Foto verifikasi far=450 (Rangga, 19 Nov 2026) — hanya jepretan siang:
##   xvfb-run -a ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_far450.tscn
## Dari spawn menghadap gunung 1: puncak harus RUNCING lagi (far=300
## memotongnya jadi datar — bandingkan gunung-siang-far300.png).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-performa/"

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto far450")
	for i in 3:
		await get_tree().process_frame
	var yaw_gunung := atan2(119.7 - (-4.0), 328.9 - 14.0)
	LangitDinamis.debug_jam = 12.0
	for i in 5:
		await get_tree().process_frame
	_main._teleport_player(Vector3(-4, 0, 14), yaw_gunung)
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "gunung-siang-far450.png")
	print("FOTO gunung-siang-far450.png err=%s cam_far=%.0f" % [str(err), _main._cam.far])
	LangitDinamis.debug_jam = -1.0
	print("FOTO FAR450 SELESAI")
	get_tree().quit(0)
