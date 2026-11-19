extends Node
## Foto perbaikan jalan + lampu (susulan Ronde 20 — Mas 21:12 WIB:
## "Jalan dan lampu dibangun ulang. Yg rapi. Masa ada tiang di
## tengah jalan."). Dijalankan sebagai SCENE (.tscn), pola
## foto_ronde20.gd. Jam dibekukan 10.00 (pagi, langit biru).
## Kamera bebas. Timer patroli dibekukan. Tiap foto membuktikan
## TIDAK ADA tiang di tengah jalan mana pun.

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
	# Bekukan patroli: Kyai + Ustadzah tetap duduk baca kitab.
	_main._kyai._patroli_timer = 9999.0
	_main._ustadzah._patroli_timer = 9999.0
	_main._player.global_position = Vector3(-4, 0, 14)
	_main._player.velocity = Vector3.ZERO
	# 1. Jalan N-S dari selatan ke utara: lampu di sisi barat
	# (x=-2.5), pagar di timur (x=2.5), jalan bersih.
	await _foto("09-jalan-ns-utara.png", Vector3(-8, 8, 40), Vector3(0, 0, -10), "luar")
	# 2. Jalan E-W dari barat ke timur: persimpangan + gerbang.
	await _foto("10-jalan-ew-timur.png", Vector3(-30, 5, 6), Vector3(10, 0, 0), "luar")
	# 3. Persimpangan + gerbang dari dekat: pilar di tepi bukaan,
	# bukan di tengah jalan.
	await _foto("11-persimpangan-gerbang.png", Vector3(-6, 3, 8), Vector3(2.5, 1.5, 0), "luar")
	# 4. JalanSurau + lampu: jalan lurus ke pintu, lampu di tepi
	# barat jalan.
	await _foto("12-jalansurau-lampu.png", Vector3(-10, 3, 4), Vector3(-4, 1, -5), "luar")
	# 5. Jalan ke musholla: jalan 12 m + lampu di tepi timur,
	# belokan pagar x=9 bersih dari jalan, pohon (14,-6) di luar jalan.
	await _foto("13-jalan-musholla.png", Vector3(22, 4, -4), Vector3(14, 1, -15), "luar")
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
