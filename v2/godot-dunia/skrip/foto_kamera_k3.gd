extends Node
## Foto K3 saja (Cakra, 18 Nov 2026) — run terpisah karena VM padat:
## satu foto penuh butuh ~10 menit (load adegan + frame lambat).
##   xvfb-run godot --path . skrip/foto_kamera_k3.tscn
## Pemain di (0,0,-2) menghadap selatan — kamera di sisi utara,
## menempel dinding depan Surau (z=-4).

const OUT := "/home/hatch/workspace/pesantren-verse/v2/foto-kamera/sesudah/K3-dekat-dinding.png"

var _main: Node


func _ready() -> void:
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto kamera K3")
	# PAKSA putra: santri.json bersama bisa ditulis "putri" oleh
	# tes agen paralel — kalau putri, _cek_batas mendorong pemain
	# dari (0,0,-2) kembali ke spawn putri sebelum foto diambil.
	_main._save["jenis_kelamin"] = "putra"
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	_main._teleport_player(Vector3(0, 0, -2), 0.0)
	for i in 5:
		await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	for i in 3:
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT)
	print("FOTO %s (err=%s)" % [OUT, str(err)])
	print("FOTO KAMERA K3 SELESAI")
	get_tree().quit(0)
