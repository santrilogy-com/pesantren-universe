extends Node
## Tes fullscreen (Cakra, 17 Nov 2026) — pola test_ronde20.gd.
##
## Yang dibuktikan headless (xvfb): wiring tombol, handler MASUK /
## DAFTAR / Lanjutkan meminta fullscreen (jejak _layar_penuh_diminta
## + transisi window_get_mode 0 -> 3), validasi gagal = TIDAK minta
## fullscreen, logika teks tombol, toggle masuk + keluar fullscreen,
## sinkron label dari keadaan nyata, masuk dunia + smoke 300 frame.
## Transisi mode TERBUKTI berubah di xvfb (probe_fullscreen2.gd:
## 0 -> 3 -> 0 langsung setelah window_set_mode, asal jendela sudah
## ter-map). Yang TIDAK bisa dibuktikan headless: fullscreen asli di
## browser (Chrome Android menerima gesture ketuk MASUK + kanvas
## benar-benar fullscreen + perilaku iPhone/Safari) — itu butuh
## browser HP Mas (lihat status doc).
##
## Handler login di main.gd diputus sementara (disconnect) supaya tes
## tidak mengirim request HTTP login sungguhan ke server.

var _main: Node
var _ui: Node
var _lolos := 0
var _gagal := 0
var _login_terkirim := false
var _daftar_terkirim := false
var _continue_terkirim := false


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_ui = _main._ui
	_tes_wiring()
	_tes_masuk()
	await _tes_daftar()
	await _tes_continue()
	await _tes_toggle()
	await _tes_masuk_dunia()
	print("HASIL TES FULLSCREEN: %d LOLOS / %d GAGAL" % [_lolos, _gagal])
	for i in 300:
		await get_tree().process_frame
	print("SMOKE 300 FRAME SELESAI")
	get_tree().quit(0 if _gagal == 0 else 1)


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


## Kembalikan mode jendela ke WINDOWED sebelum tiap bagian yang
## mengharapkan permintaan fullscreen baru — mode bertahan antar
## bagian (setelah MASUK valid, mode sudah FULLSCREEN dan
## _minta_layar_penuh() benar-benar early-return).
func _reset_mode_jendela() -> void:
	_ui._keluar_layar_penuh()
	await get_tree().process_frame
	await get_tree().process_frame


func _catat_login(_ig: String, _sandi: String) -> void:
	_login_terkirim = true


func _catat_daftar(_nama: String) -> void:
	_daftar_terkirim = true


func _catat_continue() -> void:
	_continue_terkirim = true


# ---------- A. Wiring ----------
func _tes_wiring() -> void:
	print("== A. Wiring tombol ==")
	_cek("tombol Layar Penuh ada di HUD", _ui._layar_penuh_btn != null)
	_cek("teks awal 'Layar Penuh'", _ui._layar_penuh_btn.text == "Layar Penuh",
		"teks='%s'" % _ui._layar_penuh_btn.text)
	_cek("tombol di baris kanan atas (6 tombol)",
		_ui._layar_penuh_btn.get_parent().get_child_count() == 6,
		"jumlah=%d" % _ui._layar_penuh_btn.get_parent().get_child_count())
	_cek("MASUK terhubung ke _on_masuk_pressed",
		_ui._masuk_btn.pressed.is_connected(_ui._on_masuk_pressed))
	_cek("DAFTAR terhubung ke _on_daftar_pressed",
		_ui._reg_daftar_btn.pressed.is_connected(_ui._on_daftar_pressed))
	_cek("Lanjutkan terhubung ke _on_continue_pressed",
		_ui._continue_btn.pressed.is_connected(_ui._on_continue_pressed))
	_cek("Layar Penuh terhubung ke _on_layar_penuh_pressed",
		_ui._layar_penuh_btn.pressed.is_connected(_ui._on_layar_penuh_pressed))
	_cek("size_changed terhubung ke sinkron label",
		get_viewport().size_changed.is_connected(_ui._sinkron_tombol_layar_penuh))


# ---------- B. Tombol MASUK ----------
func _tes_masuk() -> void:
	print("== B. Tombol MASUK PESANTREN ==")
	# Putus handler main supaya tidak ada request HTTP ke server.
	_ui.login_submitted.disconnect(_main._on_login)
	_ui.login_submitted.connect(_catat_login)
	# B1. Username kosong -> tidak minta fullscreen, ada pesan galat.
	_ui._layar_penuh_diminta = false
	_ui._ig_input.text = ""
	_ui._on_masuk_pressed()
	_cek("MASUK kosong: tidak minta fullscreen", _ui._layar_penuh_diminta == false)
	_cek("MASUK kosong: mode tetap WINDOWED",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	_cek("MASUK kosong: galat tampil", _ui._login_error.text != "")
	_cek("MASUK kosong: sinyal tidak terkirim", _login_terkirim == false)
	# B2. Username berspasi -> tidak minta fullscreen.
	_ui._layar_penuh_diminta = false
	_ui._ig_input.text = "a b"
	_ui._on_masuk_pressed()
	_cek("MASUK berspasi: tidak minta fullscreen", _ui._layar_penuh_diminta == false)
	_cek("MASUK berspasi: mode tetap WINDOWED",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	# B3. Username valid -> minta fullscreen + sinyal terkirim.
	_ui._layar_penuh_diminta = false
	_login_terkirim = false
	_ui._ig_input.text = "tes_santri"
	_ui._sandi_input.text = ""
	_ui._on_masuk_pressed()
	_cek("MASUK valid: minta fullscreen", _ui._layar_penuh_diminta == true)
	_cek("MASUK valid: mode jadi FULLSCREEN",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN,
		"mode=%d" % DisplayServer.window_get_mode())
	_cek("MASUK valid: login_submitted terkirim", _login_terkirim == true)
	_cek("MASUK valid: galat kosong", _ui._login_error.text == "")


# ---------- C. Tombol DAFTAR ----------
func _tes_daftar() -> void:
	print("== C. Tombol DAFTAR & MASUK ==")
	_ui.register_submitted.disconnect(_main._on_register)
	_ui.register_submitted.connect(_catat_daftar)
	# C1. Nama terlalu pendek -> tidak minta fullscreen.
	_ui._layar_penuh_diminta = false
	_ui._reg_nama_input.text = "A"
	_ui._on_daftar_pressed()
	_cek("DAFTAR pendek: tidak minta fullscreen", _ui._layar_penuh_diminta == false)
	_cek("DAFTAR pendek: sinyal tidak terkirim", _daftar_terkirim == false)
	# C2. Nama valid -> minta fullscreen + sinyal terkirim.
	await _reset_mode_jendela()
	_ui._layar_penuh_diminta = false
	_daftar_terkirim = false
	_ui._reg_nama_input.text = "Tes Santri"
	_ui._on_daftar_pressed()
	_cek("DAFTAR valid: minta fullscreen", _ui._layar_penuh_diminta == true)
	_cek("DAFTAR valid: mode jadi FULLSCREEN",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	_cek("DAFTAR valid: register_submitted terkirim", _daftar_terkirim == true)


# ---------- D. Tombol Lanjutkan ----------
func _tes_continue() -> void:
	print("== D. Tombol Lanjutkan sesi ==")
	_ui.continue_pressed.disconnect(_main._on_continue)
	_ui.continue_pressed.connect(_catat_continue)
	_ui.show_login({"id_santri": "PV-0001", "nama": "Tes", "ig_username": "tes_santri"})
	_cek("tombol Lanjutkan tampil saat ada save", _ui._continue_btn.visible == true)
	await _reset_mode_jendela()
	_ui._layar_penuh_diminta = false
	_continue_terkirim = false
	_ui._on_continue_pressed()
	_cek("Lanjutkan: minta fullscreen", _ui._layar_penuh_diminta == true)
	_cek("Lanjutkan: mode jadi FULLSCREEN",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	_cek("Lanjutkan: continue_pressed terkirim", _continue_terkirim == true)


# ---------- E. Toggle + label ----------
func _tes_toggle() -> void:
	print("== E. Toggle + label tombol ==")
	# E1. Dari berjendela: toggle -> masuk fullscreen.
	await _reset_mode_jendela()
	_ui._layar_penuh_diminta = false
	_ui._on_layar_penuh_pressed()
	_cek("toggle dari berjendela: minta fullscreen", _ui._layar_penuh_diminta == true)
	_cek("toggle dari berjendela: mode jadi FULLSCREEN",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	_cek("_apakah_layar_penuh() true saat fullscreen", _ui._apakah_layar_penuh() == true)
	_ui._sinkron_tombol_layar_penuh()
	_cek("sinkron saat fullscreen: label 'Keluar Layar'",
		_ui._layar_penuh_btn.text == "Keluar Layar",
		"teks='%s'" % _ui._layar_penuh_btn.text)
	# E2. Dari fullscreen: toggle -> keluar ke berjendela.
	_ui._on_layar_penuh_pressed()
	_cek("toggle dari fullscreen: jejak bersih", _ui._layar_penuh_diminta == false)
	_cek("toggle dari fullscreen: mode jadi WINDOWED",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	_cek("_apakah_layar_penuh() false saat berjendela", _ui._apakah_layar_penuh() == false)
	_ui._sinkron_tombol_layar_penuh()
	_cek("sinkron saat berjendela: label 'Layar Penuh'",
		_ui._layar_penuh_btn.text == "Layar Penuh")
	# E3. Logika label langsung + dukungan platform.
	_ui._atur_teks_tombol_layar_penuh(true)
	_cek("label saat fullscreen = 'Keluar Layar'",
		_ui._layar_penuh_btn.text == "Keluar Layar")
	_ui._atur_teks_tombol_layar_penuh(false)
	_cek("label saat berjendela = 'Layar Penuh'",
		_ui._layar_penuh_btn.text == "Layar Penuh")
	_cek("_dukung_layar_penuh() true di non-web",
		_ui._dukung_layar_penuh() == true)


# ---------- F. Masuk dunia + smoke ----------
func _tes_masuk_dunia() -> void:
	print("== F. Masuk dunia (bypass login) ==")
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes fullscreen.")
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("HUD tampil setelah masuk", _ui._hud.visible == true)
	_cek("tombol Layar Penuh tampil di HUD", _ui._layar_penuh_btn.visible == true)
	_cek("dunia tampil (is_world_visible)", _ui.is_world_visible() == true)
