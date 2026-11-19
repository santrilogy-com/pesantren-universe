extends Node
## Foto KOMPRES taman saja (susulan — run pertama kena timeout 300 dtk
## sebelum shot ke-3). Taman Putri dari selatan.
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_kompres_taman.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-kompres/"

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto kompres taman")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	await _foto("kompres-taman", Vector3(122, 0, 33), PI, -0.12)
	print("FOTO KOMPRES TAMAN SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos: Vector3, yaw: float, pitch: float) -> void:
	get_window().size = Vector2i(1024, 576)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(pos, yaw)
	_main._cam_pitch = pitch
	_main._spring.rotation.x = pitch
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama + ".png")
	print("FOTO %s -> %s (err=%s) cam=%s pemain=%s" % [
		nama, OUT_DIR + nama + ".png", str(err),
		str(_main._cam.global_position), str(_main._player.global_position)])
