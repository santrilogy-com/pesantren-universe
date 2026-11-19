extends Node
## Foto KOMPRES TEKSTUR (Gilang, 18 Nov 2026) — bukti visual tekstur
## ETC1S-linear di dalam game untuk Mas: lapangan rumput + tanah
## jalan, dinding bangunan bertekstur, taman/pohon.
## Jalankan TANPA --headless (headless = save_png null):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_kompres.tscn
## Yaw: menghadap = (sin yaw, 0, cos yaw): 0 = selatan, PI/2 = timur,
## PI = utara, -PI/2 = barat.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-kompres/"

const SHOTS := [
	# lapangan rumput + jalan tanah, menghadap Surau (utara)
	["kompres-lapangan", Vector3(0, 0, 28), PI, -0.08],
	# dinding Asrama Putra dari barat (bata/plester/kayu)
	["kompres-bangunan", Vector3(-44, 0, 10), PI / 2.0, -0.05],
	# Taman Putri dari selatan (pohon, paving, bunga)
	["kompres-taman", Vector3(122, 0, 42), PI, -0.08],
]

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto kompres tekstur")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	for s in SHOTS:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO KOMPRES SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos: Vector3, yaw: float, pitch: float) -> void:
	get_window().size = Vector2i(1024, 576)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(pos, yaw)
	_main._cam_pitch = pitch
	_main._spring.rotation.x = pitch
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama + ".png")
	print("FOTO %s -> %s (err=%s) cam=%s pemain=%s" % [
		nama, OUT_DIR + nama + ".png", str(err),
		str(_main._cam.global_position), str(_main._player.global_position)])
