extends Node
## Foto pencahayaan v2 — jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_pencahayaan.tscn
## Tiap shot diambil 2x (SEBELUM tanpa modul, SESUDAH dengan modul) di jam yang sama.
## L1 interior Surau | L2 interior Musholla | L3 jalan malam | L4 gerbang malam |
## L5 Surau senja (seperti F1) | L6 taman malam | L7/L8 dinding samping Surau
## malam (barat/timur, 23:45 — laporan Mas: sisi Surau masih gelap).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto cahaya")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# --- SEBELUM (tanpa modul) ---
	await _foto("L1-surau-interior-sebelum.png", Vector3(0, 2.0, -295.8), Vector3(0, 1.5, -304.0), 19.0, "surau")
	await _foto("L2-musholla-interior-sebelum.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 19.0, "musholla")
	await _foto("L3-jalan-malam-sebelum.png", Vector3(-4, 2.5, 10), Vector3(0, 2, -30), 21.0, "")
	await _foto("L4-gerbang-malam-sebelum.png", Vector3(8, 2.5, 6), Vector3(15, 2, 0), 21.0, "")
	await _foto("L5-surau-senja-sebelum.png", Vector3(-4, 2.5, 10), Vector3(0, 4, -14), 17.5, "")
	await _foto("L6-taman-malam-sebelum.png", Vector3(-6, 3.0, 20), Vector3(0, 2, 28), 21.0, "")
	await _foto("L7-surau-barat-malam-sebelum.png", Vector3(-16, 3.5, -2), Vector3(-8, 2, -14), 21.0, "")
	await _foto("L8-surau-timur-malam-sebelum.png", Vector3(12, 3.5, -2), Vector3(8, 2, -14), 21.0, "")
	# --- SESUDAH (pasang modul) ---
	PencahayaanV2.pasang(_main, _main._outdoor_door)
	for i in 10:
		await get_tree().process_frame
	await _foto("L1-surau-interior-sesudah.png", Vector3(0, 2.0, -295.8), Vector3(0, 1.5, -304.0), 19.0, "surau")
	await _foto("L2-musholla-interior-sesudah.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 19.0, "musholla")
	await _foto("L3-jalan-malam-sesudah.png", Vector3(-4, 2.5, 10), Vector3(0, 2, -30), 21.0, "")
	await _foto("L4-gerbang-malam-sesudah.png", Vector3(8, 2.5, 6), Vector3(15, 2, 0), 21.0, "")
	await _foto("L5-surau-senja-sesudah.png", Vector3(-4, 2.5, 10), Vector3(0, 4, -14), 17.5, "")
	await _foto("L6-taman-malam-sesudah.png", Vector3(-6, 3.0, 20), Vector3(0, 2, 28), 21.0, "")
	await _foto("L7-surau-barat-malam-sesudah.png", Vector3(-16, 3.5, -2), Vector3(-8, 2, -14), 21.0, "")
	await _foto("L8-surau-timur-malam-sesudah.png", Vector3(12, 3.5, -2), Vector3(8, 2, -14), 21.0, "")
	LangitDinamis.debug_jam = -1.0
	print("FOTO CAHAYA SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float, interior: String) -> void:
	LangitDinamis.debug_jam = jam
	match interior:
		"surau":
			_main._set_interior_terlihat(true, false, false)
		"musholla":
			_main._set_interior_terlihat(false, false, true)
		_:
			_main._set_interior_terlihat(false, false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
