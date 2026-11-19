extends Node
## Foto kamera v2 (Cakra, 17 Nov 2026) — jalankan TANPA --headless:
##   xvfb-run godot --path . skrip/foto_kamera.tscn -- sebelum
##   xvfb-run godot --path . skrip/foto_kamera.tscn -- sesudah
## Memakai kamera GAME sendiri (bukan kamera foto terpisah) supaya
## framing sebelum/sesudah benar-benar sebanding. Lanskap 1280x720
## (game memaksa lanskap — potret memunculkan overlay "PUTAR HP-MU").
## Surau (pemain membelakangi dinding, kamera di sisi dinding —
## skenario rawan tembus).

const OUT_BASE := "/home/hatch/workspace/pesantren-verse/v2/foto-kamera/"

var _main: Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var sub: String = args[0] if args.size() > 0 else "sesudah"
	var out_dir := OUT_BASE + sub + "/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto kamera")
	# PAKSA putra (alasan sama seperti foto_kamera_k3.gd: santri.json
	# bersama bisa ditulis "putri" oleh tes agen paralel).
	_main._save["jenis_kelamin"] = "putra"
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	# Jeda WAKTU (bukan jumlah frame): di VM padat, 1 frame bisa
	# 1-2 dtk (render software) — hitungan frame saja membuat
	# foto tertangkap sebelum adegan siap / run kehabisan waktu.
	await get_tree().create_timer(2.0).timeout
	# K1: diam di spawn, kamera game sudah di belakang pemain.
	for i in 15:
		await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	await _foto(out_dir + "K1-diam-spawn.png")
	# K2: jalan maju (joystick penuh) — tangkap di tengah jalan.
	_main._ui._joystick.output = Vector2(0, -1)
	await get_tree().create_timer(2.0).timeout
	for i in 5:
		await get_tree().process_frame
	await _foto(out_dir + "K2-jalan.png")
	_main._ui._joystick.output = Vector2.ZERO
	for i in 5:
		await get_tree().process_frame
	# K3: pemain di (0,0,-2) menghadap selatan (yaw 0) — kamera di
	# sisi utara, menempel dinding depan Surau (z=-4). Kalau penjaga
	# anti-tembus bekerja, spring memendek dan kamera tetap di luar.
	_main._teleport_player(Vector3(0, 0, -2), 0.0)
	for i in 15:
		await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	await _foto(out_dir + "K3-dekat-dinding.png")
	print("FOTO KAMERA SELESAI (" + sub + ")")
	get_tree().quit(0)


func _foto(path: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(path)
	print("FOTO %s (err=%s)" % [path, str(err)])
