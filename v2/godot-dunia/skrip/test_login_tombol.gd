extends Node
## TES TOMBOL LOGIN — Tara (UI), 19 Nov 2026. Mas (T1 12:25 WIB, stempel
## "Build 20261119-1" ADA): tombol TETAP bermasalah saat login di HP
## sungguhan, walau Opsi A (emulate_mouse_from_touch=false) sudah live.
## Tes-tes sebelumnya TIDAK PERNAH mengetuk layar login: test_tombol_sentuh
## langsung _masuk_pesantren() melewati login. Tes ini memuat main.tscn
## APA ADANYA (panel login tampil saat start) lalu mengetuk tombol-tombol
## login/daftar dengan SENTUHAN (InputEventScreenTouch) di Xvfb 412x892.
## Bila MASUK tidak memicu login_submitted, bug TERREPRODUKSI di sini
## dan penyebabnya dicari dari diagnostik (rect, disabled, kontrol yang
## menutupi titik ketuk). JALANKAN DI Xvfb (headless tidak mengantar input).

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_login := false
var _f_register := false
var _f_continue := false
var _f_daftar_link := false
var _f_masuk_pressed := false


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LOGIN LULUS: ", nama)
	else:
		_gagal += 1
		print("LOGIN GAGAL: ", nama)


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


func _tap_tombol(b: Control) -> void:
	await _tap(b.get_global_rect().get_center())


## Kontrol paling atas yang menerima input di satu titik kanvas:
## jalan seluruh pohon UI, kumpulkan yang visible + rect memuat titik +
## mouse_filter STOP, lalu ambil yang paling dalam (anak paling bawah).
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


func _diag_tombol(nama: String, b: Button) -> void:
	print("LOGIN DIAG ", nama, ": visible=", b.visible, " disabled=", b.disabled, " rect=", b.get_global_rect(), " mouse_filter=", b.mouse_filter, " action_mode=", b.action_mode, " focus_mode=", b.focus_mode)
	var atas := _kontrol_di_atas_titik(_main._ui, b.get_global_rect().get_center())
	if atas != null:
		print("LOGIN DIAG ", nama, ": kontrol teratas di titik ketuk = ", atas.get_class(), " '", atas.name, "' rect=", atas.get_global_rect())
	else:
		print("LOGIN DIAG ", nama, ": tidak ada kontrol STOP di titik ketuk")


func _ready() -> void:
	print("LOGIN: emulate_mouse_from_touch = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(4)
	await _run()
	print("TES LOGIN: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	var ui = _main._ui
	# --- 0. Keadaan awal: panel login tampil, HUD sembunyi. ---
	_cek("panel login tampil saat start", ui._login_panel.visible)
	_cek("HUD sembunyi saat login", not ui._hud.visible)
	_cek("kotak MASUK tampil", ui._login_box.visible)
	_cek("kotak DAFTAR sembunyi", not ui._register_box.visible)
	_cek("tombol MASUK ada", ui._masuk_btn != null)
	if ui._masuk_btn != null:
		_diag_tombol("MASUK", ui._masuk_btn)
		_cek("tombol MASUK enabled", not ui._masuk_btn.disabled)

	# --- 1. Tautan "Belum terdaftar? Daftar baru" -> kotak DAFTAR. ---
	_cek("tautan daftar ada", ui._daftar_link != null)
	if ui._daftar_link != null:
		await _tap_tombol(ui._daftar_link)
		_cek("TAP 'Daftar baru' -> kotak DAFTAR tampil", ui._register_box.visible)
		_cek("TAP 'Daftar baru' -> kotak MASUK sembunyi", not ui._login_box.visible)

	# --- 2. Pemilih gender: tap "Santri (Putra)". ---
	_cek("tombol gender putra ada", ui._reg_putra_btn != null)
	if ui._reg_putra_btn != null:
		_diag_tombol("GENDER-PUTRA", ui._reg_putra_btn)
		await _tap_tombol(ui._reg_putra_btn)
		_cek("TAP gender Putra -> _reg_gender == putra", ui.gender_daftar_terpilih() == "putra")

	# --- 3. Kembali ke MASUK. ---
	_cek("tombol kembali ada", ui._kembali_btn != null)
	if ui._kembali_btn != null:
		await _tap_tombol(ui._kembali_btn)
		_cek("TAP 'Sudah punya ID' -> kotak MASUK tampil", ui._login_box.visible)

	# --- 4. MASUK dengan IG kosong -> pesan validasi (bukan diam). ---
	# Spy langsung di sinyal pressed tombol (bukan hanya sinyal ui):
	# membedakan "tap tidak sampai" vs "handler jalan tapi validasi aneh".
	ui._masuk_btn.pressed.connect(func() -> void: _f_masuk_pressed = true)
	ui._ig_input.text = ""
	ui._sandi_input.text = ""
	print("LOGIN DIAG step4: ig sebelum tap = '", ui._ig_input.text, "' error sebelum = '", ui._login_error.text, "'")
	_f_masuk_pressed = false
	await _tap_tombol(ui._masuk_btn)
	print("LOGIN DIAG step4: masuk.pressed sampai = ", _f_masuk_pressed, " | error sesudah tap = '", ui._login_error.text, "' masuk.disabled=", ui._masuk_btn.disabled)
	_cek("TAP MASUK IG kosong -> sinyal pressed tombol sampai", _f_masuk_pressed)
	_cek("TAP MASUK IG kosong -> pesan 'Isi username Instagram dulu.'", ui._login_error.text == "Isi username Instagram dulu.")

	# --- 5. MASUK dengan IG terisi -> sinyal login_submitted. ---
	ui.login_submitted.disconnect(_main._on_login)
	ui.login_submitted.connect(func(_ig: String, _pw: String) -> void: _f_login = true)
	ui._ig_input.text = "tes.tara"
	ui._sandi_input.text = ""
	_f_login = false
	await _tap_tombol(ui._masuk_btn)
	_cek("TAP MASUK IG terisi -> sinyal login_submitted", _f_login)
	# (Pemeriksaan loading DIHAPUS: spy menggantikan _on_login, jadi
	# set_login_loading(true) memang tidak pernah dipanggil di tes ini.
	# Yang dibuktikan adalah sinyalnya sampai.)
	ui.login_submitted.connect(_main._on_login)

	# --- 6. DAFTAR: isi nama + IG + gender -> sinyal register_submitted. ---
	ui.register_submitted.disconnect(_main._on_register)
	ui.register_submitted.connect(func(_ig: String, _nm: String, _jk: String) -> void: _f_register = true)
	await _tap_tombol(ui._daftar_link)
	ui._reg_nama_input.text = "Tes Tara"
	ui._reg_ig_input.text = "tes.tara"
	await _tap_tombol(ui._reg_putra_btn)
	_f_register = false
	await _tap_tombol(ui._reg_daftar_btn)
	_cek("TAP DAFTAR data lengkap -> sinyal register_submitted", _f_register)
	ui.register_submitted.connect(_main._on_register)

	# --- 7. "Lanjutkan sesi sebelumnya" bila tampil (save lama).
	# (visible saja tidak cukup: tombol di dalam kotak MASUK yang
	# sedang sembunyi tetap visible=true — pakai is_visible_in_tree.)
	print("LOGIN DIAG lanjutkan: visible=", ui._continue_btn.visible, " in_tree=", ui._continue_btn.is_visible_in_tree(), " rect=", ui._continue_btn.get_global_rect(), " kotak MASUK visible=", ui._login_box.visible)
	if ui._continue_btn.is_visible_in_tree():
		ui.continue_pressed.disconnect(_main._on_continue)
		ui.continue_pressed.connect(func() -> void: _f_continue = true)
		_f_continue = false
		await _tap_tombol(ui._continue_btn)
		_cek("TAP Lanjutkan -> sinyal continue_pressed", _f_continue)
		ui.continue_pressed.connect(_main._on_continue)
	else:
		_cek("tombol Lanjutkan tidak tampil di pohon (kotak DAFTAR sedang tampil) — dilewati", true)
