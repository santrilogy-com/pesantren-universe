extends Node
## DIAGNOSTIK 4 (MINIMAL) — Tara, 19 Nov 2026. Apakah "tap pertama
## pada sebuah Button dimakan" adalah perilaku ENGINE/harness
## (push_input + Button segar), atau spesifik layar login game?
## Scene kosong: dua Button polos (A dan B). Ketuk A sekali, B sekali,
## A lagi, B lagi. Bila A1 gagal tapi A2/B2 lolos -> artefak engine
## pada tap pertama PER BUTTON. Bila semua lolos -> spesifik game.

var _lulus := 0
var _gagal := 0
var _btn_a: Button
var _btn_b: Button
var _c_a := 0
var _c_b := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("DIAG4 LULUS: ", nama)
	else:
		_gagal += 1
		print("DIAG4 GAGAL: ", nama)


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _tap(pos: Vector2) -> void:
	pos = _ke_piksel(pos)
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
	_btn_a = Button.new()
	_btn_a.text = "A"
	_btn_a.position = Vector2(100, 300)
	_btn_a.size = Vector2(300, 120)
	_btn_a.pressed.connect(func() -> void: _c_a += 1)
	add_child(_btn_a)
	_btn_b = Button.new()
	_btn_b.text = "B"
	_btn_b.position = Vector2(100, 500)
	_btn_b.size = Vector2(300, 120)
	_btn_b.pressed.connect(func() -> void: _c_b += 1)
	add_child(_btn_b)
	await _tunggu(4)
	await _run()
	print("TES DIAG4: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	print("DIAG4: rect A=", _btn_a.get_global_rect(), " rect B=", _btn_b.get_global_rect(), " visible_rect=", get_viewport().get_visible_rect())
	_c_a = 0
	await _tap(_btn_a.get_global_rect().get_center())
	print("DIAG4: A1 -> count=", _c_a)
	_cek("tap A pertama -> pressed", _c_a == 1)
	_c_b = 0
	await _tap(_btn_b.get_global_rect().get_center())
	print("DIAG4: B1 -> count=", _c_b)
	_cek("tap B pertama -> pressed", _c_b == 1)
	_c_a = 0
	await _tap(_btn_a.get_global_rect().get_center())
	print("DIAG4: A2 -> count=", _c_a)
	_cek("tap A kedua -> pressed", _c_a == 1)
	_c_b = 0
	await _tap(_btn_b.get_global_rect().get_center())
	print("DIAG4: B2 -> count=", _c_b)
	_cek("tap B kedua -> pressed", _c_b == 1)
