extends Node
## DIAGNOSTIK 5 — Tara, 19 Nov 2026. Lacak ke mana perginya tap pertama
## pada MASUK: pasang spy gui_input di MASUK + SELURUH rantai leluhurnya
## (VBox, PanelContainer, CenterContainer, panel login) + tombol daftar
## sebagai pembanding. Bila gui_input MASUK tidak berbunyi pada tap 1
## tapi leluhur berbunyi -> event dimakan leluhur / salah rute.
## Bila gui_input MASUK berbunyi tapi pressed tidak -> logika Button
## yang menolak (disabled sesaat / pasangan tekan-lepas).

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _jejak: Array = []


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("DIAG5 LULUS: ", nama)
	else:
		_gagal += 1
		print("DIAG5 GAGAL: ", nama)


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


func _pasang_spy(c: Control) -> void:
	# bind nama lewat Callable (lambda dilarang menangkap var lokal).
	c.gui_input.connect(_catat_gui_input.bind(String(c.name)))


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES DIAG5: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	# Rantai leluhur MASUK.
	var rantai: Array = []
	var n: Node = ui._masuk_btn
	while n != null:
		rantai.append(n)
		n = n.get_parent()
	print("DIAG5: rantai MASUK = ", rantai)
	for x in rantai:
		if x is Control:
			_pasang_spy(x as Control)
	# Pembanding: tombol daftar link + rantainya (tanpa duplikat spy).
	_pasang_spy(ui._daftar_link)
	ui._masuk_btn.pressed.connect(func() -> void: _jejak.append("MASUK:pressed"))
	ui._daftar_link.pressed.connect(func() -> void: _jejak.append("LINK:pressed"))
	print("DIAG5: rect MASUK = ", ui._masuk_btn.get_global_rect(), " disabled=", ui._masuk_btn.disabled, " mouse_filter=", ui._masuk_btn.mouse_filter)
	# Tap 1 pada MASUK.
	_jejak.clear()
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG5: tap1 MASUK jejak = ", _jejak)
	_cek("tap1 MASUK -> gui_input MASUK berbunyi", _jejak.any(func(s: String) -> bool: return s.begins_with("@Button@") or s.contains("MASUK")))
	_cek("tap1 MASUK -> pressed berbunyi", "MASUK:pressed" in _jejak)
	# Tap 2 pada MASUK.
	_jejak.clear()
	await _tap(ui._masuk_btn.get_global_rect().get_center())
	print("DIAG5: tap2 MASUK jejak = ", _jejak)
	_cek("tap2 MASUK -> pressed berbunyi", "MASUK:pressed" in _jejak)
