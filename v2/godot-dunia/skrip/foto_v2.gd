extends Node
## Foto v2 ALPHA — jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_v2.tscn
## F1 spawn -> Surau | F2 pemain close-up | F3 atas (seluruh dunia).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-alpha/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto v2")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# F1: dari spawn menghadap Surau (pusat -14, bukan -12).
	await _foto("F1-spawn-surau.png", Vector3(-4, 2.5, 10), Vector3(0, 4, -14))
	# F2: pemain close-up dari barat laut.
	await _foto("F2-pemain-spawn.png", Vector3(-8, 2.0, 10), Vector3(-4, 1.2, 14))
	# F3: dari atas (seluruh dunia).
	await _foto("F3-atas.png", Vector3(70, 130, 13), Vector3(70, 0, 12))
	print("FOTO SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
