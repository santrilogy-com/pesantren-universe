extends Node
## DIAGNOSTIK 3 — Tara, 19 Nov 2026. Mekanisme "tap pertama dimakan":
## (a) apakah tap pertama ke AREA KOSONG (bukan tombol) ikut dimakan,
## (b) apakah tap MASUK sesudah tap kosong itu langsung bekerja,
## (c) apakah jendela Xvfb belum fokus saat tap pertama (window_has_focus),
## (d) alur Mas: tap field IG dulu, lalu tap MASUK.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_masuk := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("DIAG3 LULUS: ", nama)
	else:
		_gagal += 1
		print("DIAG3 GAGAL: ", nama)


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
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES DIAG3: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	ui._masuk_btn.pressed.connect(func() -> void: _f_masuk += 1)
	print("DIAG3: window_has_focus awal = ", get_viewport().gui_get_focus_owner())
	# (a) Tap kosong: pojok kiri atas panel login (jauh dari tombol).
	_f_masuk = 0
	await _tap(Vector2(60, 60))
	print("DIAG3: sesudah tap kosong -> window_has_focus=", get_viewport().gui_get_focus_owner(), " pressed count=", _f_masuk)
	# (b) Tap MASUK langsung sesudah tap kosong.
	ui._ig_input.text = ""
	_f_masuk = 0
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG3: tap MASUK sesudah tap kosong -> pressed count=", _f_masuk, " error='", ui._login_error.text, "'")
	_cek("tap MASUK sesudah 1 tap kosong -> pressed sampai", _f_masuk == 1)
	_cek("tap MASUK sesudah 1 tap kosong -> pesan validasi", ui._login_error.text == "Isi username Instagram dulu.")
	# (d) Alur Mas: tap field IG, lalu tap MASUK (IG terisi).
	ui._ig_input.text = "tes.tara"
	await _tap(ui._ig_input.get_global_rect().get_center())
	print("DIAG3: sesudah tap field IG -> ig fokus=", ui._ig_input.has_focus(), " window_has_focus=", get_viewport().gui_get_focus_owner())
	_f_masuk = 0
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG3: tap MASUK sesudah tap field -> pressed count=", _f_masuk)
	_cek("tap MASUK sesudah tap field IG -> pressed sampai", _f_masuk == 1)
