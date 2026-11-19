extends Node
## DIAGNOSTIK 2 — Tara, 19 Nov 2026. Isolasi: tap MASUK dengan IG kosong
## di layar login SEGAR (tanpa pindah kotak dulu), lalu tap kedua.
## Pertanyaan: apakah kegagalan tap MASUK (test_login_tombol step 4)
## butuh riwayat pindah kotak, atau terjadi juga di layar segar?
## Juga: tap MASUK dua kali berturut-turut — apakah tap pertama
## "dimakan" sesuatu dan tap kedua baru sampai?

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_masuk := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("DIAG2 LULUS: ", nama)
	else:
		_gagal += 1
		print("DIAG2 GAGAL: ", nama)


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
	print("DIAG2: sesudah press -> hovered=", get_viewport().gui_get_hovered_control(), " masuk.button_pressed=", _main._ui._masuk_btn.button_pressed)
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
	await _tunggu(4)
	await _run()
	print("TES DIAG2: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	ui._masuk_btn.pressed.connect(func() -> void: _f_masuk += 1)
	print("DIAG2: rect MASUK segar = ", ui._masuk_btn.get_global_rect(), " visible_rect=", get_viewport().get_visible_rect(), " window=", DisplayServer.window_get_size())
	print("DIAG2: ig awal = '", ui._ig_input.text, "'")
	# Tap 1: layar segar, IG kosong.
	ui._ig_input.text = ""
	_f_masuk = 0
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG2: tap1 -> pressed count=", _f_masuk, " error='", ui._login_error.text, "'")
	_cek("tap1 segar IG kosong -> pressed sampai", _f_masuk == 1)
	_cek("tap1 segar IG kosong -> pesan validasi", ui._login_error.text == "Isi username Instagram dulu.")
	# Tap 2: ulangi persis sama.
	_f_masuk = 0
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG2: tap2 -> pressed count=", _f_masuk, " error='", ui._login_error.text, "'")
	_cek("tap2 ulangan -> pressed sampai", _f_masuk == 1)
