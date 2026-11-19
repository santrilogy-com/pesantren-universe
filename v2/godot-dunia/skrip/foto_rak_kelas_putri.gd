extends Node
## Foto RAK BUKU PUTRI + INTERIOR KELAS PUTRI (Dewi, 18 Nov 2026) —
## jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_rak_kelas_putri.tscn
## Empat foto (standalone, tanpa main.tscn — interior dibangun
## langsung): (1) rak timur Musholla; (2) rak utara Musholla;
## (3) Kelas Putri luas dari pintu; (4) rak buku Kelas close-up.
## WorldEnvironment ambient ditambah supaya stills tidak gelap
## (di game, cahaya datang dari lampu interior + matahari).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _cam: Camera3D


func _ready() -> void:
	# Ambient hangat supaya stills terbaca (bukan bagian interior).
	var wenv := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#2a2f38")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff2dd")
	env.ambient_light_energy = 0.9
	wenv.environment = env
	add_child(wenv)
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	await _foto_musholla_rak_timur()
	await _foto_musholla_rak_utara()
	await _foto_kelas_luas() # foto rak kelas ikut di dalamnya
	print("FOTO RAK + KELAS PUTRI SELESAI")
	get_tree().quit(0)


func _foto_musholla_rak_timur() -> void:
	var m := InteriorMusholla.build()
	add_child(m["root"])
	for i in 3:
		await get_tree().process_frame
	var rak_pos: Vector3 = InteriorMusholla.ke_dunia(Vector3(66.7, 0, -298.0))
	var cam_pos := InteriorMusholla.ke_dunia(Vector3(62.5, 2.0, -297.0))
	await _foto("musholla-rak-timur.png", cam_pos, rak_pos + Vector3(0, 1.0, 0))
	print("FOTO musholla rak timur: rak=%s spot=%s" % [str(rak_pos), str((m["rak_spots"] as Array)[0])])
	m["root"].queue_free()


func _foto_musholla_rak_utara() -> void:
	var m := InteriorMusholla.build()
	add_child(m["root"])
	for i in 3:
		await get_tree().process_frame
	var rak_pos: Vector3 = InteriorMusholla.ke_dunia(Vector3(57.5, 0, -305.7))
	var cam_pos := InteriorMusholla.ke_dunia(Vector3(60.5, 1.8, -302.5))
	await _foto("musholla-rak-utara.png", cam_pos, rak_pos + Vector3(0, 1.0, 0))
	print("FOTO musholla rak utara: rak=%s spot=%s" % [str(rak_pos), str((m["rak_spots"] as Array)[1])])
	m["root"].queue_free()


func _foto_kelas_luas() -> void:
	var k := InteriorKelasPutri.build()
	add_child(k["root"])
	for i in 3:
		await get_tree().process_frame
	await _foto("kelas-putri-luas.png", Vector3(120, 2.6, -297.8), Vector3(120, 0.8, -303.5))
	print("FOTO kelas luas: door=%s spawn=%s" % [str(k["interior_door"]), str(k["interior_spawn"])])
	# Root kelas dipakai lagi untuk foto rak (jangan di-free dulu).
	# HARUS await — tanpa await, quit() di _ready mendahului 40
	# frame foto rak dan PNG ke-4 tidak pernah tersimpan.
	await _foto_kelas_rak(k["root"], k["rak_spots"])


func _foto_kelas_rak(kelas_root: Node3D, rak_spots: Array) -> void:
	await _foto("kelas-putri-rak.png", Vector3(118.0, 1.6, -301.8), Vector3(115.35, 1.0, -303.5))
	print("FOTO kelas rak: rak_spots=%s" % str(rak_spots))
	kelas_root.queue_free()


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
