extends Node
## Foto perbaikan figur Ustadzah — KIRANA 16 Nov ~21:45 WIB
## (Mas: figur Ustadzah "kok aneh" — kerucut tanpa lengan,
## jilbab celemek, wajah topeng, kubah boneka).
## Dijalankan sebagai SCENE (.tscn), pola foto_ustadzah_abaya.gd.
## Sudut PERSIS foto 05b/05c/05d supaya sebelum/sesudah bisa
## dibandingkan langsung. Jam dibekukan 10.00 (pagi).
## 05e = duduk baca kitab (sudut 05b), 05f = close-up depan
## (sudut 05c), 05g = berdiri (sudut 05d).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/foto-ronde-20/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._on_login("PV-0001", "Tes")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Bekukan patroli: Ustadzah tetap duduk baca kitab.
	_main._ustadzah._patroli_timer = 9999.0
	# 05e. Ustadzah duduk baca kitab — SUDUT PERSIS foto 05b.
	_main._player.global_position = _main._musholla_spawn
	_main._player.velocity = Vector3.ZERO
	_main._set_interior_terlihat(false, false, true)
	await _foto("05e-ustadzah-baru-duduk.png", Vector3(63.5, 2.0, -297.8), Vector3(68.88, 1.0, -301.79), "musholla")
	# 05f. Close-up DEPAN (sudut 05c): wajah + alis + drape baru.
	await _foto("05f-ustadzah-baru-dekat.png", Vector3(66.71, 1.35, -302.81), Vector3(68.88, 1.30, -301.79), "musholla")
	# 05g. Ustadzah BERDIRI (sudut 05d): lengan + siluet abaya.
	var ustadzah: Node = _main._ustadzah
	ustadzah._patroli = {}
	ustadzah._diam = true
	ustadzah.global_position = _main._musholla_spawn
	# Hadap kamera: visual menghadap +Z lokal saat rotation.y = 0
	# (selatan) — kamera di utara spawn, jadi hadap utara (PI).
	ustadzah._visual.rotation.y = PI
	ustadzah._visual.position.y = 0.0
	ustadzah._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_ABAYA_DEFAULT)
	if ustadzah._kitab_pangku != null:
		ustadzah._kitab_pangku.visible = false
	_main._player.global_position = _main._musholla_spawn + Vector3(4, 0, 0)
	_main._player.velocity = Vector3.ZERO
	var spawn: Vector3 = _main._musholla_spawn
	await _foto("05g-ustadzah-baru-berdiri.png", spawn + Vector3(0, 1.6, -3.2), spawn + Vector3(0, 1.1, 0), "musholla")
	print("FOTO SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, _mode: String) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
