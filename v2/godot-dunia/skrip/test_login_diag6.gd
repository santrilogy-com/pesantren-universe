extends Node
## DIAGNOSTIK 6 — Tara, 19 Nov 2026. Tap 1 pada MASUK tidak sampai ke
## MASUK maupun leluhurnya (diag5). Ke mana ia pergi? Pasang spy
## gui_input di SEMUA Control di bawah PesantrenUI, lalu tap MASUK
## sekali. Bila ada kontrol lain yang berbunyi -> itulah yang memakan
## tap 1. Bila tetap sunyi -> event gugur sebelum dispatch GUI.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _jejak: Array = []


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("DIAG6 LULUS: ", nama)
	else:
		_gagal += 1
		print("DIAG6 GAGAL: ", nama)


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


func _catat_gui_input(ev: InputEvent, nama: String) -> void:
	_jejak.append("%s:%s" % [nama, ev.get_class()])


func _pasang_semua(akar: Node, prefix: String) -> void:
	if akar is Control:
		var c := akar as Control
		# Hanya yang bisa menerima input (STOP/PASS) — IGNORE takkan bunyi.
		if c.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			c.gui_input.connect(_catat_gui_input.bind(prefix + String(c.name)))
	for ch in akar.get_children():
		_pasang_semua(ch, prefix + String(akar.name) + "/")


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES DIAG6: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	_pasang_semua(ui, "UI/")
	# Daftar kontrol STOP yang VISIBLE saat login (calon pemakan tap).
	var calon: Array = []
	var tumpuk: Array = [ui]
	while not tumpuk.is_empty():
		var n: Node = tumpuk.pop_back()
		if n is Control:
			var c := n as Control
			if c.is_visible_in_tree() and c.mouse_filter == Control.MOUSE_FILTER_STOP:
				calon.append("%s rect=%s" % [c.get_path(), c.get_global_rect()])
		for ch in n.get_children():
			tumpuk.append(ch)
	print("DIAG6: kontrol STOP visible saat login = ", calon)
	print("DIAG6: rect MASUK = ", ui._masuk_btn.get_global_rect())
	_jejak.clear()
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG6: tap1 MASUK jejak = ", _jejak)
	_cek("tap1 MASUK -> ada kontrol yang menerima gui_input", not _jejak.is_empty())
	_jejak.clear()
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG6: tap2 MASUK jejak = ", _jejak)
	_cek("tap2 MASUK -> MASUK menerima gui_input", _jejak.any(func(s: String) -> bool: return "@Button@" in s))
