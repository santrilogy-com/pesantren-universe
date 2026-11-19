extends Node
## Foto revisi -90° (KOREKSI 23:15 WIB — muka depan GLB ke selatan):
##   xvfb-run godot --path . skrip/foto_revisi_90.tscn
## R1: spawn -> muka DEPAN Surau (portal + plakat + pintu terbuka
##     + serambi + menara). R2: dari atas (jejak baru 16x20 m).
## R3 (matahari 17:00) TIDAK diulang — kamera + arahnya sama,
## matahari tidak berubah.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-revisi-surau-lurus/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto revisi -90")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# R1 — spawn -> depan Surau.
	_cam.global_position = Vector3(-4, 2.5, 10)
	_cam.look_at(Vector3(0, 4, -14), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "R1-spawn-surau-depan.png")
	print("FOTO R1-depan -> %s (err=%s)" % [OUT_DIR + "R1-spawn-surau-depan.png", str(err)])
	# R2 — dari atas.
	_cam.global_position = Vector3(0, 55, -14)
	_cam.look_at(Vector3(0, 0, -14), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	img = get_viewport().get_texture().get_image()
	err = img.save_png(OUT_DIR + "R2-atas-lurus-90.png")
	print("FOTO R2-atas90 -> %s (err=%s)" % [OUT_DIR + "R2-atas-lurus-90.png", str(err)])
	print("FOTO REVISI -90 SELESAI")
	get_tree().quit(0)
