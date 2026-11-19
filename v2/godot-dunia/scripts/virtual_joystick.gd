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

# ROMBAKAN HUD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB,
# mockup hud-v3-desain-gamepad-v3.png): kembali ke joystick LAMA —
# PUTIH polos transparan, tanpa gelap/zamrud/glow. Piringan putih
# alpha 0.25 + rim putih tipis, knob putih alpha 0.5, 4 chevron
# PUTIH (atas/bawah/kiri/kanan). Menggantikan gaya v2 (piringan
# gelap + ring glow zamrud + knob zamrud padat).
# VARIAN B rev1 (Tara, 18 Nov 2026 — DI-ACC Mas 18:43 WIB, mockup
# hud-v3-perbaikan-b-rev1.png): putih polos TERBUKTI hilang di
# lantai marmer putih — piringan + knob kini KACA BURAM BERTINTA
# zamrud muda (alpha 150 / 170), 4 chevron ZAMRUD GELAP #043B2C.
# Rim putih tipis dipertahankan (samar di atas kaca, tidak merusak
# kontras). TANPA bayangan (varian B).
const GAYA_V3 := true
const GAYA_B_REV1 := true

var _knob_offset: Vector2 = Vector2.ZERO
var _active: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(220, 220)
	mouse_filter = Control.MOUSE_FILTER_STOP


func get_vector() -> Vector2:
	return output


func _draw() -> void:
	var c := size * 0.5
	# Piringan kaca buram bertinta + rim putih tipis + ring dalam samar.
	# (Varian B rev1: tint zamrud muda alpha 150, bukan putih 0.25.)
	draw_circle(c, 100.0, Color(GayaTombol.TINT_KACA, GayaTombol.ALPHA_KACA))
	draw_arc(c, 100.0, 0.0, TAU, 64, Color(1, 1, 1, 0.35), 2.0)
	draw_arc(c, 58.0, 0.0, TAU, 48, Color(1, 1, 1, 0.12), 2.0)
	var k := c + _knob_offset
	# Knob kaca buram bertinta sedikit lebih pekat + rim putih tipis.
	# (Varian B rev1: tint knob alpha 170, bukan putih 0.5.)
	draw_circle(k, KNOB_RADIUS, Color(GayaTombol.TINT_KNOB, GayaTombol.ALPHA_KNOB))
	draw_arc(k, KNOB_RADIUS, 0.0, TAU, 40, Color(1, 1, 1, 0.4), 2.0)
	# 4 chevron ZAMRUD GELAP di piringan (arah gerak) — ala joystick
	# lama. (Varian B rev1: zamrud gelap, bukan putih.)
	var r_ch := 76.0
	_chevron(c + Vector2(0, -r_ch), Vector2.UP)
	_chevron(c + Vector2(0, r_ch), Vector2.DOWN)
	_chevron(c + Vector2(-r_ch, 0), Vector2.LEFT)
	_chevron(c + Vector2(r_ch, 0), Vector2.RIGHT)


# Segitiga ZAMRUD GELAP kecil menunjuk ke `arah` (chevron joystick).
func _chevron(pusat: Vector2, arah: Vector2) -> void:
	var tegak := Vector2(-arah.y, arah.x)
	var ujung := pusat + arah * 10.0
	var kiri := pusat - arah * 6.0 + tegak * 9.0
	var kanan := pusat - arah * 6.0 - tegak * 9.0
	draw_colored_polygon(PackedVector2Array([ujung, kiri, kanan]), Color(GayaTombol.ZAMRUD_GELAP, 0.92))


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
