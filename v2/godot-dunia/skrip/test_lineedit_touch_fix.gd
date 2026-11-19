extends Node
## TES PERBAIKAN LINEEDIT SENTUH — Dita (UI), 19 Nov 2026. BUKTI untuk
## usulan perbaikan (TANPA ubah kode game): sebuah LineEdit polos +
## handler gui_input yang memanggil grab_focus() saat InputEventScreenTouch
## ditekan — apakah ketuk sentuh lalu memberi fokus + ketik jalan?
## Scene minimal (tanpa main.tscn) supaya tidak kena parse error
## ruang_belajar_ui.gd yang sedang dikerjakan Sinta.

var _lulus := 0
var _gagal := 0
var _field: LineEdit


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("FIX LULUS: ", nama)
	else:
		_gagal += 1
		print("FIX GAGAL: ", nama)


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _tap_sentuh(pos: Vector2) -> void:
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


func _ketik(teks: String) -> void:
	for ch in teks:
		var k := InputEventKey.new()
		k.unicode = ch.unicode_at(0)
		k.pressed = true
		get_viewport().push_input(k)
		await get_tree().process_frame
		var kr := InputEventKey.new()
		kr.unicode = ch.unicode_at(0)
		kr.pressed = false
		get_viewport().push_input(kr)
		await get_tree().process_frame


func _ready() -> void:
	# --- Kontrol A: LineEdit polos (tanpa perbaikan) = perilaku game sekarang. ---
	var a := LineEdit.new()
	a.placeholder_text = "A polos"
	a.custom_minimum_size = Vector2(360, 44)
	a.position = Vector2(20, 20)
	a.size = Vector2(360, 44)
	add_child(a)
	# --- Kontrol B: LineEdit + handler gui_input (usulan perbaikan). ---
	var b := LineEdit.new()
	b.placeholder_text = "B diperbaiki"
	b.custom_minimum_size = Vector2(360, 44)
	b.position = Vector2(20, 100)
	b.size = Vector2(360, 44)
	b.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventScreenTouch and (ev as InputEventScreenTouch).pressed:
			b.grab_focus())
	add_child(b)
	await _tunggu(4)
	# A: sentuh -> fokus?
	await _tap_sentuh(a.get_global_rect().get_center())
	_cek("A polos: SENTUH -> fokus masuk", get_viewport().gui_get_focus_owner() == a)
	# B: sentuh -> fokus?
	b.release_focus()
	await _tunggu(2)
	await _tap_sentuh(b.get_global_rect().get_center())
	_cek("B diperbaiki: SENTUH -> fokus masuk", get_viewport().gui_get_focus_owner() == b)
	# B: ketik -> teks?
	b.text = ""
	await _ketik("oke")
	_cek("B diperbaiki: ketik 'oke' -> teks terisi", b.text == "oke")
	print("TES FIX LINEEDIT: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)
