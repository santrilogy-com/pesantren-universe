extends Node
## TES FIELD DAFTAR + CHAT — Dita (UI), 19 Nov 2026. Pelengkap
## test_login_field.gd (12/12 pasca-perbaikan): membuktikan handler
## gui_input -> grab_focus() juga bekerja di _reg_nama_input,
## _reg_ig_input (kotak Daftar) dan _chat_input (panel chat).
## JALANKAN DI Xvfb. JANGAN ubah kode game.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("REG LULUS: ", nama)
	else:
		_gagal += 1
		print("REG GAGAL: ", nama)


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


func _fokus() -> String:
	var f := get_viewport().gui_get_focus_owner()
	return "null" if f == null else f.name


func _ready() -> void:
	print("REG: emulate_mouse_from_touch = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES FIELD DAFTAR+CHAT: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	_cek("panel login tampil saat start", ui._login_panel.visible)
	# --- Kotak Daftar ---
	ui._tampil_daftar()
	await _tunggu(3)
	_cek("kotak daftar tampil", ui._register_box.visible)
	_cek("kotak login sembunyi", not ui._login_box.visible)
	# _tampil_daftar() sudah grab_focus ke nama — lepas dulu supaya
	# yang diuji adalah jalur ketuk, bukan fokus bawaan tombol.
	ui._reg_nama_input.release_focus()
	await _tunggu(2)
	await _tap_sentuh(ui._reg_nama_input.get_global_rect().get_center())
	print("REG: setelah SENTUH NAMA: focus_owner=", _fokus())
	_cek("SENTUH kolom NAMA daftar -> fokus masuk", _fokus() == ui._reg_nama_input.name)
	ui._reg_nama_input.text = ""
	await _ketik("Dita")
	print("REG: teks NAMA setelah ketik = '", ui._reg_nama_input.text, "'")
	_cek("Ketik 'Dita' di NAMA -> teks terisi", ui._reg_nama_input.text == "Dita")
	await _tap_sentuh(ui._reg_ig_input.get_global_rect().get_center())
	print("REG: setelah SENTUH IG daftar: focus_owner=", _fokus())
	_cek("SENTUH kolom IG daftar -> fokus masuk", _fokus() == ui._reg_ig_input.name)
	ui._reg_ig_input.text = ""
	await _ketik("dita.test")
	print("REG: teks IG daftar setelah ketik = '", ui._reg_ig_input.text, "'")
	_cek("Ketik 'dita.test' di IG daftar -> teks terisi", ui._reg_ig_input.text == "dita.test")
	# --- Panel chat (dipaksa tampil; normalnya butuh login dulu) ---
	_cek("panel chat ada", ui._chat_panel != null)
	if ui._chat_panel != null:
		ui._chat_panel.visible = true
		await _tunggu(3)
		ui._chat_input.release_focus()
		await _tunggu(2)
		await _tap_sentuh(ui._chat_input.get_global_rect().get_center())
		print("REG: setelah SENTUH CHAT: focus_owner=", _fokus())
		_cek("SENTUH kolom CHAT -> fokus masuk", _fokus() == ui._chat_input.name)
		ui._chat_input.text = ""
		await _ketik("halo")
		print("REG: teks CHAT setelah ketik = '", ui._chat_input.text, "'")
		_cek("Ketik 'halo' di CHAT -> teks terisi", ui._chat_input.text == "halo")
