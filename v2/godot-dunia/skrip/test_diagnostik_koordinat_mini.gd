extends Node
## DIAGNOSTIK KOORDINAT MINI — Tara (UI). Versi ringan dari
## test_diagnostik_koordinat: TANPA main scene (load 3D lambat di
## llvmpipe) — hanya CanvasLayer + Button, tapi tetap memakai
## project.godot yang sama (stretch canvas_items + aspect expand).
## Menjawab: apakah push_input butuh koordinat VIEWPORT (piksel),
## sementara get_global_rect() memberi koordinat KANVAS?
## JALANKAN: Xvfb 412x892 --resolution 412x892.

var _f_a := false
var _f_b := false


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
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var b := Button.new()
	b.text = "X"
	b.custom_minimum_size = Vector2(100, 100)
	b.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	b.position = Vector2(-195, -130)
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.pressed.connect(func() -> void: _f_a = true)
	layer.add_child(b)
	await get_tree().process_frame
	await get_tree().process_frame
	var vp := get_viewport()
	print("MINI viewport visible_rect=", vp.get_visible_rect())
	print("MINI window size=", DisplayServer.window_get_size())
	print("MINI canvas_transform=", vp.get_canvas_transform())
	var pusat_kanvas: Vector2 = b.get_global_rect().get_center()
	print("MINI tombol global_rect=", b.get_global_rect(), " pusat_kanvas=", pusat_kanvas)
	var pusat_vp: Vector2 = vp.get_canvas_transform() * pusat_kanvas
	print("MINI pusat_viewport(transform)=", pusat_vp)
	_f_a = false
	await _tap(pusat_kanvas)
	print("MINI (a) tap pusat_kanvas mentah -> pressed=", _f_a)
	_f_a = false
	_f_b = false
	b.pressed.disconnect(b.pressed.get_connections()[0].callable)
	b.pressed.connect(func() -> void: _f_b = true)
	await _tap(pusat_vp)
	print("MINI (b) tap pusat_viewport(transform) -> pressed=", _f_b)
	print("MINI SELESAI")
	get_tree().quit(0)
