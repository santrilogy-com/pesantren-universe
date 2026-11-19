extends Node
## TES FIELD LOGIN — Dita (UI), 19 Nov 2026. Laporan Mas 15:58 + 16:01 WIB
## (HP Galaxy A35, build live f288f998): keyboard TIDAK muncul saat kolom
## login diketuk. Tes ini mengetuk kolom username + sandi dengan SENTUHAN
## (InputEventScreenTouch) dan memeriksa: (a) apakah fokus masuk ke
## LineEdit, (b) apakah ketik (InputEventKey) mengisi teks, (c) kontrol
## STOP apa yang menutupi titik ketuk, (d) perbandingan dengan ketuk
## mouse, (e) overlay PUTAR HP-MU dipaksa tampil (simulasi portrait di
## HP — di Xvfb is_touchscreen_available() = false sehingga overlay
## tidak muncul sendiri). JALANKAN DI Xvfb (headless tidak mengantar
## input). JANGAN ubah kode game.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_focus_ig := false
var _f_focus_sandi := false
var _f_gui_input_ig := false


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("FIELD LULUS: ", nama)
	else:
		_gagal += 1
		print("FIELD GAGAL: ", nama)


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


func _tap_mouse(pos: Vector2) -> void:
	pos = _ke_piksel(pos)
	var tekan := InputEventMouseButton.new()
	tekan.button_index = MOUSE_BUTTON_LEFT
	tekan.pressed = true
	tekan.position = pos
	get_viewport().push_input(tekan)
	await get_tree().process_frame
	var lepas := InputEventMouseButton.new()
	lepas.button_index = MOUSE_BUTTON_LEFT
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


## Kontrol paling atas yang menerima input di satu titik kanvas.
func _kontrol_di_atas_titik(akar: Node, titik: Vector2) -> Control:
	var terbaik: Control = null
	var terbaik_kedalaman := -1
	var tumpuk: Array = [[akar, 0]]
	while not tumpuk.is_empty():
		var item: Array = tumpuk.pop_back()
		var n: Node = item[0]
		var ked: int = item[1]
		if n is Control:
			var c := n as Control
			if c.visible and c.mouse_filter != Control.MOUSE_FILTER_IGNORE and c.get_global_rect().has_point(titik) and ked >= terbaik_kedalaman:
				terbaik = c
				terbaik_kedalaman = ked
		for ch in n.get_children():
			tumpuk.append([ch, ked + 1])
	return terbaik


func _diag_field(nama: String, f: LineEdit) -> void:
	var r := f.get_global_rect()
	print("FIELD DIAG ", nama, ": visible=", f.visible, " in_tree=", f.is_visible_in_tree(), " editable=", f.editable, " focus_mode=", f.focus_mode, " mouse_filter=", f.mouse_filter, " rect=", r)
	var atas := _kontrol_di_atas_titik(_main._ui, r.get_center())
	if atas != null:
		print("FIELD DIAG ", nama, ": kontrol teratas di titik ketuk = ", atas.get_class(), " '", atas.name, "' rect=", atas.get_global_rect())
	else:
		print("FIELD DIAG ", nama, ": tidak ada kontrol STOP di titik ketuk")


func _cari_tombol_overlay(ui) -> Button:
	var tumpuk: Array = [ui._rotate_overlay]
	while not tumpuk.is_empty():
		var n: Node = tumpuk.pop_back()
		if n is Button:
			return n as Button
		for ch in n.get_children():
			tumpuk.append(ch)
	return null


func _fokus() -> String:
	var f := get_viewport().gui_get_focus_owner()
	return "null" if f == null else f.name


func _ready() -> void:
	print("FIELD: emulate_mouse_from_touch = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	print("FIELD: touchscreen_available = ", DisplayServer.is_touchscreen_available())
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES FIELD LOGIN: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	print("FIELD: viewport=", vp, " window=", win, " scale=", get_viewport().get_screen_transform().x.x)
	print("FIELD: overlay putar visible=", ui._rotate_overlay.visible, " dismissed=", ui._rotate_dismissed)
	_cek("panel login tampil saat start", ui._login_panel.visible)
	_cek("HUD sembunyi saat login", not ui._hud.visible)
	ui._ig_input.focus_entered.connect(func() -> void: _f_focus_ig = true)
	ui._sandi_input.focus_entered.connect(func() -> void: _f_focus_sandi = true)
	ui._ig_input.gui_input.connect(func(ev: InputEvent) -> void: if ev is InputEventScreenTouch and (ev as InputEventScreenTouch).pressed: _f_gui_input_ig = true)
	_diag_field("IG", ui._ig_input)
	_diag_field("SANDI", ui._sandi_input)

	# --- 1. SENTUH kolom IG -> fokus? ---
	_f_focus_ig = false
	_f_gui_input_ig = false
	await _tap_sentuh(ui._ig_input.get_global_rect().get_center())
	print("FIELD: setelah SENTUH IG: focus_owner=", _fokus(), " focus_entered=", _f_focus_ig, " gui_input_sentuh_diterima=", _f_gui_input_ig)
	_cek("SENTUH kolom IG -> fokus masuk ke IG", _fokus() == ui._ig_input.name)
	_cek("SENTUH kolom IG -> sinyal focus_entered", _f_focus_ig)

	# --- 2. Ketik di IG -> teks terisi? ---
	ui._ig_input.text = ""
	await _ketik("tesdita")
	print("FIELD: teks IG setelah ketik = '", ui._ig_input.text, "'")
	_cek("Ketik 'tesdita' di IG -> teks terisi", ui._ig_input.text == "tesdita")

	# --- 3. SENTUH kolom SANDI -> fokus + ketik? ---
	_f_focus_sandi = false
	await _tap_sentuh(ui._sandi_input.get_global_rect().get_center())
	print("FIELD: setelah SENTUH SANDI: focus_owner=", _fokus(), " focus_entered=", _f_focus_sandi)
	_cek("SENTUH kolom SANDI -> fokus masuk ke SANDI", _fokus() == ui._sandi_input.name)
	ui._sandi_input.text = ""
	await _ketik("rahasia")
	print("FIELD: teks SANDI setelah ketik = '", ui._sandi_input.text, "'")
	_cek("Ketik 'rahasia' di SANDI -> teks terisi", ui._sandi_input.text == "rahasia")

	# --- 4. Perbandingan: ketuk MOUSE di kolom IG -> fokus? ---
	ui._ig_input.release_focus()
	await _tunggu(2)
	_f_focus_ig = false
	await _tap_mouse(ui._ig_input.get_global_rect().get_center())
	print("FIELD: setelah MOUSE IG: focus_owner=", _fokus(), " focus_entered=", _f_focus_ig)
	_cek("MOUSE kolom IG -> fokus masuk ke IG", _fokus() == ui._ig_input.name)

	# --- 5. Overlay PUTAR HP-MU dipaksa tampil (simulasi portrait HP). ---
	ui._rotate_dismissed = false
	ui._rotate_overlay.visible = true
	await _tunggu(2)
	print("FIELD: overlay dipaksa tampil: visible=", ui._rotate_overlay.visible)
	var tombol_overlay := _cari_tombol_overlay(ui)
	if tombol_overlay != null:
		print("FIELD: tombol overlay '", tombol_overlay.text, "' rect=", tombol_overlay.get_global_rect(), " in_tree=", tombol_overlay.is_visible_in_tree())
	_diag_field("IG dgn overlay", ui._ig_input)
	_diag_field("SANDI dgn overlay", ui._sandi_input)
	ui._ig_input.release_focus()
	await _tunggu(2)
	_f_focus_ig = false
	await _tap_sentuh(ui._ig_input.get_global_rect().get_center())
	print("FIELD: SENTUH IG dgn overlay tampil: focus_owner=", _fokus(), " focus_entered=", _f_focus_ig)
	_cek("SENTUH kolom IG dgn overlay tampil -> fokus masuk ke IG", _fokus() == ui._ig_input.name)
	_f_focus_sandi = false
	await _tap_sentuh(ui._sandi_input.get_global_rect().get_center())
	print("FIELD: SENTUH SANDI dgn overlay tampil: focus_owner=", _fokus(), " focus_entered=", _f_focus_sandi)
	_cek("SENTUH kolom SANDI dgn overlay tampil -> fokus masuk ke SANDI", _fokus() == ui._sandi_input.name)

	# --- 6. Tutup overlay via tombolnya, lalu sentuh kolom lagi. ---
	if tombol_overlay != null:
		await _tap_sentuh(tombol_overlay.get_global_rect().get_center())
		print("FIELD: setelah tap tombol overlay: overlay visible=", ui._rotate_overlay.visible)
		_cek("Tap tombol overlay -> overlay tertutup", not ui._rotate_overlay.visible)
		ui._ig_input.release_focus()
		await _tunggu(2)
		_f_focus_ig = false
		await _tap_sentuh(ui._ig_input.get_global_rect().get_center())
		_cek("SENTUH kolom IG setelah overlay ditutup -> fokus masuk", _fokus() == ui._ig_input.name)
