extends Node
## Foto WIRING INTERIOR PUTRI (Lestari, 18 Nov 2026) — lewat main.tscn
## (bukti wiring, BUKAN build langsung seperti foto_interior_*):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_wiring_putri.tscn
## JANGAN --headless (save_png null). 6 foto, satu per gedung putri,
## diambil dari kamera pemain setelah _masuk_*() (teleport interior).
## Catatan framing: kamera pemain (spring 4 m di dalam ruangan)
## dijepit SpringArm di dinding ruangan kecil — foto Pos Jaga
## jadi close-up; itu wajar, bukan cacat wiring.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto wiring putri")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# Kelas: dari tengah ruangan menghadap utara (papan tulis + meja).
	await _foto("wiring-kelas-putri.png", "_masuk_kelas_putri", "_keluar_kelas_putri", Vector3(120, 0, -302.5), 0.0)
	# Asrama: dari koridor lantai 1 menghadap timur (kamar + tangga).
	await _foto("wiring-asrama-putri.png", "_masuk_asrama_putri", "_keluar_asrama_putri", Vector3(-238, 0, -300), -PI / 2.0)
	# Kantor: menghadap timur-laut (meja kerja + papan utara).
	await _foto("wiring-kantor-ustadzah.png", "_masuk_kantor", "_keluar_kantor", Vector3(-119.5, 0, -301.5), -PI / 4.0)
	# Madrasah: menghadap timur-laut (papan tulis + meja guru).
	await _foto("wiring-madrasah.png", "_masuk_madrasah", "_keluar_madrasah", Vector3(-180, 0, -301.5), -PI / 4.0)
	# Studio: menghadap selatan (papan + meja kerja).
	await _foto("wiring-studio.png", "_masuk_studio", "_keluar_studio", Vector3(240, 0, -300.5), PI)
	# Pos Jaga: menghadap timur (meja jaga + lemari) — close-up.
	await _foto("wiring-pos-jaga.png", "_masuk_pos_jaga", "_keluar_pos_jaga", Vector3(179.8, 0, -300), -PI / 2.0)
	print("FOTO WIRING PUTRI SELESAI")
	get_tree().quit(0)


func _foto(nama: String, masuk_fn: String, keluar_fn: String, pos_pemain: Vector3, yaw: float) -> void:
	_main.call(masuk_fn)
	for i in 5:
		await get_tree().process_frame
	_main._teleport_player(pos_pemain, yaw)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
	_main.call(keluar_fn)
	for i in 5:
		await get_tree().process_frame
