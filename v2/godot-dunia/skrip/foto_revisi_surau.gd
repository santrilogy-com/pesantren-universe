extends Node
## Foto v2 REVISI SURAU LURUS (Mas 17 Nov 22:51 WIB) — jalankan
## TANPA --headless (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_revisi_surau.tscn
## R1 spawn -> Surau lurus | R2 atas (seluruh dunia) |
## R3 matahari jam 17:00 dari depan pintu Surau (arah barat).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-revisi-surau-lurus/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto revisi Surau lurus")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# R1: dari spawn menghadap Surau lurus (pusat -14).
	await _foto("R1-spawn-surau-lurus.png", Vector3(-4, 2.5, 10), Vector3(0, 4, -14))
	# R2: dari atas (seluruh dunia).
	await _foto("R2-atas.png", Vector3(70, 130, 13), Vector3(70, 0, 12))
	# R3: matahari jam 17:00 (azim 252° = barat-barat daya) dari
	# depan pintu Surau, menghadap barat-barat daya.
	LangitDinamis.debug_jam = 17.0
	await _foto("R3-matahari-1700-barat.png", Vector3(0, 2.5, -4.5), Vector3(-38, 4, 8))
	print("FOTO REVISI SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
