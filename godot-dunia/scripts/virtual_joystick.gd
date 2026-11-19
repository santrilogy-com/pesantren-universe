extends Control
class_name SantriJoystick
## Joystick virtual kiri (ala Mobile Legends).
## UPGRADE Godot 4.7: class_name lama "VirtualJoystick" MENABRAK class
## native baru di 4.7 (parse error "hides a native class") — diganti
## jadi SantriJoystick (mengikuti SantriNPC/SantriPlayer).
## Drag jari (touch) atau drag mouse (desktop, emulate_touch_from_mouse=true).
## output: Vector2 ternormalisasi, panjang 0..1. Gambar digambar via _draw()
## (lingkaran dasar + knob) — tanpa aset gambar.

var output: Vector2 = Vector2.ZERO

const RADIUS := 90.0
const KNOB_RADIUS := 42.0

var _knob_offset: Vector2 = Vector2.ZERO
var _active: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(220, 220)
	mouse_filter = Control.MOUSE_FILTER_STOP


func get_vector() -> Vector2:
	return output


func _draw() -> void:
	var c := size * 0.5
	draw_circle(c, 100.0, Color(1, 1, 1, 0.10))
	draw_arc(c, 100.0, 0.0, TAU, 48, Color(1, 1, 1, 0.35), 4.0)
	draw_circle(c + _knob_offset, KNOB_RADIUS, Color(1, 1, 1, 0.35))
	draw_arc(c + _knob_offset, KNOB_RADIUS, 0.0, TAU, 32, Color(1, 1, 1, 0.6), 3.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_active = true
			_update_knob(touch.position)
		else:
			_reset()
	elif event is InputEventScreenDrag and _active:
		_update_knob((event as InputEventScreenDrag).position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_active = true
				_update_knob(mb.position)
			else:
				_reset()
	elif event is InputEventMouseMotion and _active:
		_update_knob((event as InputEventMouseMotion).position)


func _update_knob(pos: Vector2) -> void:
	var d := pos - size * 0.5
	if d.length() > RADIUS:
		d = d.normalized() * RADIUS
	_knob_offset = d
	output = d / RADIUS
	queue_redraw()


func _reset() -> void:
	_active = false
	_knob_offset = Vector2.ZERO
	output = Vector2.ZERO
	queue_redraw()
