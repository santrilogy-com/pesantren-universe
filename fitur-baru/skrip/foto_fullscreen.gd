extends Node
## Foto fullscreen (Cakra, 17 Nov 2026) — pola foto_ronde20.gd.
## Jam dibekukan 10.00. Kamera bebas di plaza depan Surau.
## F0: layar login (MASUK + Lanjutkan — titik masuk fullscreen).
## F1: HUD dalam game, tombol "Layar Penuh" (berjendela).
## F2: setelah ketuk toggle — mode FULLSCREEN betulan di xvfb
## (window_get_mode 0 -> 3), label tombol jadi "Keluar Layar".
## Catatan: F0 memakai show_login dengan save tes supaya tombol
## Lanjutkan tampil seperti di HP Mas (save-nya sudah ada).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/fitur-baru/foto/"

var _main: Node
var _ui: Node
var _cam: Camera3D


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_ui = _main._ui
	# F0: layar login.
	_ui.show_login({"id_santri": "PV-0001", "nama": "Tes", "ig_username": "tes_santri"})
	await _foto("F0-layar-login.png")
	# Masuk dunia (bypass login, pola tugas).
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Foto fullscreen.")
	await get_tree().process_frame
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	_cam.global_position = Vector3(-4, 2.5, 18)
	_cam.look_at(Vector3(-4, 1.5, 0), Vector3.UP)
	# F1: HUD berjendela, tombol "Layar Penuh".
	_ui._atur_teks_tombol_layar_penuh(false)
	await _foto("F1-hud-layar-penuh.png")
	# F2: ketuk toggle -> fullscreen betulan + label "Keluar Layar".
	_ui._on_layar_penuh_pressed()
	for i in 10:
		await get_tree().process_frame
	_ui._sinkron_tombol_layar_penuh()
	print("FOTO mode setelah toggle: ", DisplayServer.window_get_mode(),
		" label='", _ui._layar_penuh_btn.text, "'")
	await _foto("F2-hud-keluar-layar.png")
	# Kembalikan berjendela supaya tidak mengganggu sesi berikut.
	_ui._keluar_layar_penuh()
	print("FOTO SELESAI")
	get_tree().quit(0)


func _foto(nama: String) -> void:
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s, ukuran=%s)" % [nama, OUT_DIR + nama, str(err), str(img.get_size())])
