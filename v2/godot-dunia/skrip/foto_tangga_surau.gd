extends Node
## Foto tangga Surau — SEBELUM & SESUDAH (Rangga, 17 Nov 23:xx WIB):
##   xvfb-run godot --path . skrip/foto_tangga_surau.tscn -- sebelum
##   xvfb-run godot --path . skrip/foto_tangga_surau.tscn -- sesudah
## Kamera samping (timur, x=+7) setinggi kaki — yang dicek: kaki vs
## permukaan pijakan (tenggelam / menapak). SEBELUM: pemain di-teleport
## ke (0,0,0.7) [atas anak tangga T3, y=0] dan (0,0,-2.0) [serambi,
## y=0] — tanpa collision, kaki tenggelam ke dalam visual. SESUDAH:
## pemain DIJALANKAN dari jalan E-W (0,0,3) ke utara; foto diambil
## saat z melewati 0.7 (tangga), -0.5 (T1) dan -2.0 (serambi) + satu
## sudut 3/4 dari tenggara (cek 360°).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-tangga-surau/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String) -> void:
	for i in 6:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO TANGGA %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _pasang_kamera(pos: Vector3, target: Vector3) -> void:
	_cam.global_position = pos
	_cam.look_at(target, Vector3.UP)


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var mode := "sebelum"
	if args.size() > 0:
		mode = String(args[0])
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto tangga " + mode)
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true
	if mode == "sebelum":
		# Samping timur: kaki di atas T3 (y=0, pijakan visual 0.166).
		_main._teleport_player(Vector3(0, 0, 0.7), PI)
		_pasang_kamera(Vector3(7, 1.0, 0.7), Vector3(0, 0.25, 0.7))
		await _foto("sebelum-samping-tangga.png")
		# Samping timur: kaki di serambi (y=0, lantai visual 0.5).
		_main._teleport_player(Vector3(0, 0, -2.0), PI)
		_pasang_kamera(Vector3(7, 1.0, -2.0), Vector3(0, 0.3, -2.0))
		await _foto("sebelum-samping-serambi.png")
	else:
		# Dijalankan dari jalan E-W ke utara; foto di titik ukur.
		# PENTING (18 Nov 00:xx WIB): di xvfb FPS rendah, tiap frame
		# proses = banyak langkah fisika — pemain bisa jalan sampai
		# masuk Surau selama 6 frame tunggu _foto. Karena itu
		# joystick DIHENTIKAN dulu sebelum tiap foto, baru jalan
		# lagi sesudahnya; kalau tidak, foto "sesudah" malah
		# terambil sesudah teleport (pemain sudah di dalam).
		_main._teleport_player(Vector3(0, 0, 3), PI)
		for i in 3:
			await get_tree().process_frame
		_main._ui._joystick.output = Vector2(0, -1)
		var ambil := {"tangga": false, "t1": false, "serambi": false}
		for i in 400:
			await get_tree().process_frame
			var p: Vector3 = _main._player.global_position
			if not ambil["tangga"] and p.z <= 0.7:
				ambil["tangga"] = true
				_main._ui._joystick.output = Vector2.ZERO
				_pasang_kamera(Vector3(7, 1.0, 0.7), Vector3(0, 0.35, 0.7))
				await _foto("sesudah-samping-tangga.png")
				# Sudut 3/4 tenggara di momen yang sama (cek 360°).
				_pasang_kamera(Vector3(5, 3.0, 4.5), Vector3(0, 0.3, 0.0))
				await _foto("sesudah-tiga-perempat-tangga.png")
				_main._ui._joystick.output = Vector2(0, -1)
			if not ambil["t1"] and p.z <= -0.5:
				ambil["t1"] = true
				_main._ui._joystick.output = Vector2.ZERO
				_pasang_kamera(Vector3(7, 1.0, -0.5), Vector3(0, 0.6, -0.5))
				await _foto("sesudah-samping-t1.png")
				_main._ui._joystick.output = Vector2(0, -1)
			if not ambil["serambi"] and p.z <= -2.0:
				ambil["serambi"] = true
				_main._ui._joystick.output = Vector2.ZERO
				_pasang_kamera(Vector3(7, 1.0, -2.0), Vector3(0, 0.6, -2.0))
				await _foto("sesudah-samping-serambi.png")
				_main._ui._joystick.output = Vector2(0, -1)
			if _main._di_dalam:
				break
		_main._ui._joystick.output = Vector2.ZERO
		print("FOTO TANGGA sesudah: di_dalam=%s pemain=%s" % [str(_main._di_dalam), str(_main._player.global_position)])
	print("FOTO TANGGA " + mode + " SELESAI")
	get_tree().quit(0)
