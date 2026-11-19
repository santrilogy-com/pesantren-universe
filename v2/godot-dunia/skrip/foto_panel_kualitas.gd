extends Node
## Foto panel Pengaturan kualitas (Rangga, 19 Nov 2026):
##   (Xvfb :98) godot --path . --resolution 1280x720 skrip/foto_panel_kualitas.tscn
## Buka panel kualitas dari strip atas lalu tangkap layar — bukti
## visual panel tidak rusak (tombol tidak meluap, teks terbaca).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node


func _foto(nama: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO panel kualitas: %s err=%d" % [nama, err])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._masuk_pesantren("Foto Kualitas")
	for i in 10:
		await get_tree().process_frame
	# Buka panel kualitas + tandai mode saat ini, lalu foto.
	_main._ui._toggle_panel_kualitas()
	_main._ui.set_kualitas_mode(_main._kualitas.mode_saat_ini())
	await _foto("panel-kualitas-v1.png")
	get_tree().quit(0)
