extends Node
## Foto IDLE DIAM vs BERSIWAK — RONDE 10 (Kirana, 18 Nov 2026 —
## keluhan Mas 14:03 WIB "kamera saat diam kek aneh, gerakannya
## melayang"): badan diam total, hanya tangan yang bergerak.
## RONDE 21: garuk kepala diganti bersiwak — F2 kini merender
## tangan kanan naik ke mulut + siwak (lihat juga
## skrip/foto_siwak.gd untuk foto close-up siwak).
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run -a godot --path . skrip/foto_idle_garuk.tscn
## (kalau xvfb-run gagal start: Xvfb manual di :99 + DISPLAY=:99)
## F1 idle-diam: _idle_t=2,0 (di luar jendela siwak) — lengan di sisi
## badan. F2 idle-siwak: _idle_t=7,8 (tengah jendela siwak) — tangan
## kanan terangkat ke mulut. Badan harus DIAM di kedua foto.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-idle/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String, jam_idle: float) -> void:
	# PIN jam idle tiap frame fisika: di bawah beban VM, satu frame
	# proses bisa mengejar sampai 8 tick fisika, jadi _idle_t yang
	# di-set sekali akan hanyut beberapa detik sebelum jepretan dan
	# jendela siwak terlewat. Dengan pin, nilai yang dipakai modul
	# selalu tepat di target; 45 frame cukup untuk lerp settle.
	for i in 45:
		_main._player._idle_t = jam_idle
		await get_tree().physics_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto idle siwak")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true
	# Pemain di jalan terbuka, hadap kamera (selatan, yaw 0).
	_main._teleport_player(Vector3(0, 0, 20), 0.0)
	for i in 10:
		await get_tree().process_frame
	_cam.global_position = Vector3(0, 1.6, 24.0)
	_cam.look_at(Vector3(0, 1.0, 20), Vector3.UP)
	# F1: diam — jam idle di luar jendela siwak, lengan di sisi badan.
	await _foto("idle-diam.png", 2.0)
	# F2: siwak — jam idle di tengah jendela (7,0–9,5), tangan kanan
	# terangkat ke mulut.
	await _foto("idle-siwak.png", 7.8)
	print("FOTO IDLE SELESAI")
	get_tree().quit(0)
