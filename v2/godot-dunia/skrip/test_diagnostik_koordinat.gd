extends Node
## DIAGNOSTIK KOORDINAT — Tara (UI). Menjawab: kenapa SEMUA tap gagal di
## --resolution 412x892 padahal 47/47 di jendela 1280x720?
## Dugaan: push_input menerima koordinat VIEWPORT (piksel), sedangkan
## get_global_rect() mengembalikan koordinat KANVAS (dengan stretch
## canvas_items + aspect expand, skala != 1 di portrait). Tes ini
## mencetak viewport, canvas transform, rect tombol, lalu mengetuk ✕
## di (a) koordinat kanvas mentah, (b) koordinat hasil transform
## kanvas->viewport. JALANKAN: Xvfb 412x892 --resolution 412x892.

const MAIN_SCENE := "res://main.tscn"

var _main: Node
var _f_interact := false


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _tap(pos: Vector2) -> void:
	var tekan := InputEventScreenTouch.new()
	tekan.index = 0
	tekan.pressed = true
	tekan.position = pos
	get_viewport().push_input(tekan)
	await get_tree().process_frame
	var lepas := InputEventScreenTouch.new()
	lepas.index = 0
	lepas.pressed = false
	lepas.position = pos
	get_viewport().push_input(lepas)
	await get_tree().process_frame


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	await _run()
	get_tree().quit(0)


func _run() -> void:
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes koordinat")
	await _tunggu(3)
	var ui = _main._ui
	var vp := get_viewport()
	print("DIAG viewport visible_rect=", vp.get_visible_rect())
	print("DIAG window size=", DisplayServer.window_get_size())
	print("DIAG canvas_transform=", vp.get_canvas_transform())
	print("DIAG stretch scale=", vp.get_canvas_transform().get_scale())
	var x_btn := ui._tombol_gamepad.get("x") as Button
	# Paksa ✕ tampil di dekat Bilal supaya bisa diketuk.
	_main._bilal.position = Vector3(-4, 0, 4)
	_main._teleport_player(Vector3(-4, 0, 6.5), PI)
	await _tunggu(3)
	print("DIAG interact visible=", ui._interact_btn.visible, " teks=", ui._interact_btn.text)
	var pusat_kanvas: Vector2 = ui._interact_btn.get_global_rect().get_center()
	print("DIAG ✕ global_rect=", ui._interact_btn.get_global_rect(), " pusat_kanvas=", pusat_kanvas)
	var pusat_vp: Vector2 = vp.get_canvas_transform() * pusat_kanvas
	print("DIAG ✕ pusat_viewport(transform)=", pusat_vp)
	ui.interact_pressed.connect(func() -> void: _f_interact = true)
	# (a) tap koordinat kanvas mentah
	_f_interact = false
	await _tap(pusat_kanvas)
	print("DIAG (a) tap pusat_kanvas mentah -> interact=", _f_interact)
	# (b) tap koordinat hasil transform
	_f_interact = false
	await _tap(pusat_vp)
	print("DIAG (b) tap pusat_viewport(transform) -> interact=", _f_interact)
	# (c) tap tengah layar viewport (kontrol: harus TIDAK kena ✕)
	_f_interact = false
	await _tap(vp.get_visible_rect().size * 0.5)
	print("DIAG (c) tap tengah layar -> interact=", _f_interact)
	print("DIAG SELESAI")
