extends Node
## DIAGNOSTIK KOORDINAT MINI v2 — Tara (UI). Sama seperti mini v1, tapi
## output ditulis ke FILE (bukan print — print bisa hilang bila proses
## dimatikan timeout sebelum flush). File:
## ~/workspace/.logs-gate-18nov/diag-koordinat-mini.txt
## JALANKAN: Xvfb --resolution 412x892 (atau tanpa --resolution).

const OUT := "/home/hatch/workspace/.logs-gate-18nov/diag-koordinat-mini.txt"


var _f: FileAccess


func _tulis(s: String) -> void:
	if _f == null:
		_f = FileAccess.open(OUT, FileAccess.WRITE)
	if _f == null:
		return
	_f.store_line(s)
	_f.flush()


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
	_tulis("MINI2 _ready mulai " + str(Time.get_ticks_msec()))
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var b := Button.new()
	b.text = "X"
	b.custom_minimum_size = Vector2(100, 100)
	b.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	b.position = Vector2(-195, -130)
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	var ditekan := {"v": false}
	b.pressed.connect(func() -> void: ditekan["v"] = true)
	layer.add_child(b)
	_tulis("MINI2 tombol dibuat, tunggu 2 frame")
	await get_tree().process_frame
	await get_tree().process_frame
	var vp := get_viewport()
	_tulis("MINI2 viewport visible_rect=" + str(vp.get_visible_rect()))
	_tulis("MINI2 window size=" + str(DisplayServer.window_get_size()))
	_tulis("MINI2 canvas_transform=" + str(vp.get_canvas_transform()))
	var pusat_kanvas: Vector2 = b.get_global_rect().get_center()
	_tulis("MINI2 tombol global_rect=" + str(b.get_global_rect()) + " pusat_kanvas=" + str(pusat_kanvas))
	var pusat_vp: Vector2 = vp.get_canvas_transform() * pusat_kanvas
	_tulis("MINI2 pusat_viewport(transform)=" + str(pusat_vp))
	# (c) tap di koordinat PIKSEL jendela: kanvas * skala stretch
	# (skala = window / visible_rect; aspect expand -> skala x).
	var skala := Vector2(vp.get_visible_rect().size.x, vp.get_visible_rect().size.y)
	var win := DisplayServer.window_get_size()
	var faktor := Vector2(float(win.x) / skala.x, float(win.y) / skala.y)
	_tulis("MINI2 faktor piksel/kanvas=" + str(faktor))
	var pusat_piksel: Vector2 = pusat_kanvas * faktor
	_tulis("MINI2 pusat_piksel=" + str(pusat_piksel))
	ditekan["v"] = false
	await _tap(pusat_piksel)
	_tulis("MINI2 (c) tap pusat_piksel (sentuh) -> pressed=" + str(ditekan["v"]))
	# (d) klik MOUSE di posisi piksel yang sama (jalur emulasi).
	ditekan["v"] = false
	var klik := InputEventMouseButton.new()
	klik.button_index = MOUSE_BUTTON_LEFT
	klik.pressed = true
	klik.position = pusat_piksel
	vp.push_input(klik)
	await get_tree().process_frame
	klik = InputEventMouseButton.new()
	klik.button_index = MOUSE_BUTTON_LEFT
	klik.pressed = false
	klik.position = pusat_piksel
	vp.push_input(klik)
	await get_tree().process_frame
	_tulis("MINI2 (d) klik mouse pusat_piksel -> pressed=" + str(ditekan["v"]))
	_tulis("MINI2 SELESAI")
	get_tree().quit(0)
