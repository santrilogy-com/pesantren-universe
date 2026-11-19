extends Node
## Foto PINTU PAGAR TAMAN — Gilang, 17 Nov 2026. Jalankan TANPA
## --headless (headless membuat save_png null):
##   xvfb-run -a godot --path . skrip/foto_pintu_taman.tscn
## F1 pintu tertutup dari luar (utara) | F2 pintu terbuka dari luar
## (pemain di depan pintu) | F3 tertutup dari dalam | F4 terbuka
## dari dalam | F5 overview pagar keliling + taman.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-pintu-taman/"

var _main: Node
var _cam: Camera3D
var _pintu: Node


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu_buka() -> void:
	for i in 240:
		await get_tree().process_frame
		if _pintu != null and _pintu.apakah_terbuka():
			return


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto Pintu Taman")
	for i in 3:
		await get_tree().process_frame
	_pintu = _main._pesantren["root"].find_child("PintuTaman", true, false)
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# F1: pintu TERTUTUP dari luar (utara) — dikunci supaya NPC yang
	# lewat tidak membuka pintu di tengah foto.
	if _pintu != null:
		_pintu.set_tahan_tertutup(true)
	await _foto("F1-tertutup-luar.png", Vector3(0, 2.2, 20.5), Vector3(0, 1.0, 25.5))
	# F2: pintu TERBUKA dari luar — pemain di depan pintu (0,23),
	# pintu membuka otomatis; pemain terlihat menghadap pintu.
	if _pintu != null:
		_pintu.set_tahan_tertutup(false)
	_main._teleport_player(Vector3(0, 0, 23), 0.0)
	await _tunggu_buka()
	await _foto("F2-terbuka-luar.png", Vector3(0, 2.2, 20.5), Vector3(0, 1.0, 25.5))
	# F3: pintu TERTUTUP dari dalam (selatan) — pemain dijauhkan.
	if _pintu != null:
		_pintu.set_tahan_tertutup(true)
	_main._teleport_player(Vector3(0, 0, 14), PI)
	for i in 60:
		await get_tree().process_frame
	await _foto("F3-tertutup-dalam.png", Vector3(0, 2.2, 30.5), Vector3(0, 1.0, 25.5))
	# F4: pintu TERBUKA dari dalam — pemain di dalam taman (0,27.0).
	# (18 Nov 2026: dulu (0,27.5) — peti pindah ke (0,28), muka
	# utaranya z 27,625, jadi (0,27.5) menabrak collision peti.)
	if _pintu != null:
		_pintu.set_tahan_tertutup(false)
	_main._teleport_player(Vector3(0, 0, 27.0), PI)
	await _tunggu_buka()
	await _foto("F4-terbuka-dalam.png", Vector3(0, 2.2, 30.5), Vector3(0, 1.0, 25.5))
	# F5: overview — pagar keliling + taman + pintu (terbuka).
	await _foto("F5-overview.png", Vector3(10, 9, 16), Vector3(0, 0, 28.5))
	print("FOTO SELESAI")
	get_tree().quit(0)
