extends Node
## Foto sekali: fasad utara Studio (pintu "N") — pemain di utara gedung
## menghadap SELATAN (yaw 0), kamera 8 m di utara pemain.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-audit-tekstur/"
var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto studio utara")
	for i in 3:
		await get_tree().process_frame
	_main._player.set_nama("Gilang")
	_main._audio.mulai()
	get_window().size = Vector2i(1024, 576)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(Vector3(166, 0, -24), 0.0)
	_main._cam_pitch = -0.05
	_main._spring.rotation.x = -0.05
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "studio-utara.png")
	print("FOTO studio-utara -> err=%s cam=%s pemain=%s" % [
		str(err), str(_main._cam.global_position), str(_main._player.global_position)])
	print("FOTO STUDIO UTARA SELESAI")
	get_tree().quit(0)
