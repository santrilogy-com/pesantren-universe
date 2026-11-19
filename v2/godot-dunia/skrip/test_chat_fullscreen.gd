extends Node
## Tes chat saat fullscreen (Tara, 18 Nov 2026 — bug Mas: "ketika full
## screen kenapa ga bisa chatingan?").
##   DISPLAY=:99 <godot-4.7.2> --path . skrip/test_chat_fullscreen.tscn
##   (Xvfb, TANPA --headless — butuh jendela nyata yang ter-map:
##   headless memberi window (0,0) sehingga window_set_mode tidak
##   mengubah mode + posisi mouse emulasi sentuhan jadi 20x lipat,
##   dan 4 cek gagal padahal bukan bug game. Di Xvfb: 25/25.)
## AKAR MASALAH (dari sumber engine Godot 4.7-stable): fullscreen
## diminta engine HANYA pada kanvas, sedangkan input tersembunyi
## keyboard virtual ditempel sebagai SAUDARA kanvas (anak <body>) —
## saat kanvas fullscreen, browser tidak memunculkan keyboard untuk
## input di luar subtree kanvas. Perbaikan di scripts/ui.gd: fullscreen
## diminta pada documentElement (<html>) lewat JavaScriptBridge, jadi
## kanvas + input keyboard sama-sama di dalam elemen fullscreen.
## Yang dibuktikan headless (bukan web — JS tidak jalan di sini):
##  (1) jalur fallback non-web: _minta_layar_penuh_web() false ->
##      window_set_mode FULLSCREEN + flag _layar_penuh_diminta;
##      _keluar_layar_penuh() kembali WINDOWED + flag false;
##  (2) alur chat LENGKAP saat mode FULLSCREEN: panel terbuka, input
##      dapat fokus, panel di dalam viewport, tidak ada overlay yang
##      menutupi input, ketik + kirim sampai jadi baris chat;
##  (3) ketuk DI DALAM panel tidak menutup chat, ketuk DI LUAR panel
##      menutupnya (handler _unhandled_input tetap benar saat FS);
##  (4) chat tetap jalan setelah keluar fullscreen.
## Pembuktian browser (keyboard sungguhan muncul saat chat dibuka
## dalam fullscreen) hanya bisa di HP Mas — tes ini TIDAK
## mengklaimnya.

var _main: Node
var _lulus := 0
var _gagal := 0
var _chat_diterima := 0
var _chat_teks_terakhir := ""


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _on_chat_sent_test(teks: String) -> void:
	_chat_diterima += 1
	_chat_teks_terakhir = teks


func _ketuk(pos: Vector2) -> void:
	var t := InputEventScreenTouch.new()
	t.pressed = true
	t.position = pos
	Input.parse_input_event(t)
	for i in 3:
		await get_tree().process_frame
	var r := InputEventScreenTouch.new()
	r.pressed = false
	r.position = pos
	Input.parse_input_event(r)
	for i in 3:
		await get_tree().process_frame


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Isolasi offline (pola test_v2): kosongkan ig supaya tidak
	# auto-join multiplayer dari save yang tertinggal.
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes chat FS")
	# HUD v3 (Tara, 18 Nov): pop-up "PETUNJUK TOMBOL" muncul saat
	# pertama main dan dim full-screen-nya (MOUSE_FILTER_STOP)
	# menelan ketuk layar — ketuk-di-luar panel chat di _unhandled_
	# input tidak sampai selama pop-up terbuka. Pemain sungguhan
	# menutupnya dulu ("Mengerti"); tes ini menutupnya lewat tombol
	# yang sama sebelum menguji ketuk-di-luar.
	if _main._ui.is_petunjuk_visible():
		_main._ui._petunjuk_mengerti_btn.pressed.emit()
	for i in 3:
		await get_tree().process_frame
	var ui = _main._ui
	ui.chat_sent.connect(_on_chat_sent_test)

	# --- (1) Jalur fallback non-web ---
	_cek("Headless bukan web: _minta_layar_penuh_web() false", ui._minta_layar_penuh_web() == false)
	_cek("Headless bukan web: _keluar_layar_penuh_web() false", ui._keluar_layar_penuh_web() == false)
	ui._minta_layar_penuh()
	for i in 3:
		await get_tree().process_frame
	_cek("Minta fullscreen: mode FULLSCREEN", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	_cek("Minta fullscreen: flag _layar_penuh_diminta true", ui._layar_penuh_diminta == true)
	_cek("Minta fullscreen: _apakah_layar_penuh() true", ui._apakah_layar_penuh() == true)

	# --- (2) Alur chat lengkap saat FULLSCREEN ---
	_cek("Chat tertutup sebelum dibuka", not ui.is_chat_visible())
	ui._toggle_chat()
	for i in 3:
		await get_tree().process_frame
	_cek("FS: panel chat terbuka", ui.is_chat_visible())
	_cek("FS: input chat dapat fokus", ui._chat_input.has_focus())
	var vp: Rect2 = get_viewport().get_visible_rect()
	var rect: Rect2 = ui._chat_panel.get_global_rect()
	_cek("FS: panel chat di dalam viewport (dapat %s, vp %s)" % [str(rect), str(vp.size)], vp.has_point(rect.position) and vp.has_point(rect.end - Vector2(1, 1)))
	_cek("FS: overlay putar-HP tidak menutupi", ui._rotate_overlay == null or not ui._rotate_overlay.visible)
	_cek("FS: blackout tidak menutupi", not ui.is_blackout_visible())
	# Ketik + kirim.
	var sebelum: int = ui._chat_list.get_child_count()
	ui._chat_input.text = "Assalamu'alaikum FS"
	ui._on_chat_submit("")
	for i in 3:
		await get_tree().process_frame
	_cek("FS: sinyal chat_sent diterima (dapat %d)" % _chat_diterima, _chat_diterima == 1)
	_cek("FS: teks terkirim utuh (dapat '%s')" % _chat_teks_terakhir, _chat_teks_terakhir == "Assalamu'alaikum FS")
	_cek("FS: baris chat bertambah (dapat %d)" % ui._chat_list.get_child_count(), ui._chat_list.get_child_count() == sebelum + 1)
	_cek("FS: input dikosongkan setelah kirim", ui._chat_input.text == "")
	# main.gd menutup panel setelah kirim (by design) — buka lagi
	# untuk cek handler ketuk-di-luar.
	_cek("FS: panel tertutup setelah kirim (by design main.gd)", not ui.is_chat_visible())

	# --- (3) Ketuk di dalam vs di luar panel saat FS ---
	ui._toggle_chat()
	for i in 3:
		await get_tree().process_frame
	_cek("FS: panel dibuka lagi", ui.is_chat_visible())
	var tengah: Vector2 = ui._chat_panel.get_global_rect().get_center()
	await _ketuk(tengah)
	_cek("FS: ketuk DI DALAM panel tidak menutup chat", ui.is_chat_visible())
	await _ketuk(Vector2(20, vp.size.y - 20))
	_cek("FS: ketuk DI LUAR panel menutup chat", not ui.is_chat_visible())

	# --- (4) Keluar fullscreen, chat tetap jalan ---
	ui._keluar_layar_penuh()
	for i in 3:
		await get_tree().process_frame
	_cek("Keluar fullscreen: mode WINDOWED", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	_cek("Keluar fullscreen: flag _layar_penuh_diminta false", ui._layar_penuh_diminta == false)
	_cek("Keluar fullscreen: _apakah_layar_penuh() false", ui._apakah_layar_penuh() == false)
	ui._toggle_chat()
	for i in 3:
		await get_tree().process_frame
	_cek("Setelah keluar FS: panel chat terbuka", ui.is_chat_visible())
	ui._chat_input.text = "Balik jendela"
	ui._on_chat_submit("")
	for i in 3:
		await get_tree().process_frame
	_cek("Setelah keluar FS: kirim kedua diterima (dapat %d)" % _chat_diterima, _chat_diterima == 2)
	_cek("Setelah keluar FS: teks kedua utuh", _chat_teks_terakhir == "Balik jendela")

	print("TES CHAT FULLSCREEN: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
