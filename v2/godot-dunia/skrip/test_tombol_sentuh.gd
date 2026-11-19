extends Node
## TES SENTUHAN — Tara (UI). Mas: tombol bermasalah HANYA di HP, di PC
## aman. Tes ini mengirim SENTUHAN NYATA (InputEventScreenTouch,
## BUKAN klik mouse) ke tiap tombol gamepad + strip atas + joystick,
## lalu mengulang ✕ dengan emulate_mouse_from_touch=false untuk
## membuktikan tombol menangani sentuhan mentah (bukan cuma lewat
## emulasi mouse). JALANKAN DI Xvfb (headless TIDAK mengantar input).
## Pola spy mengikuti test_tombol_x.gd: flag MEMBER + lepas handler
## main dulu (lambda TIDAK boleh menangkap var lokal).
##
## Yang dicek: pop-up Mengerti, ✕ dekat Kyai (langkah 2, putra),
## △/□/○, kamera/suara/peta/kartu/Main Bersama/layar penuh,
## joystick drag sentuh, ✕ tanpa emulasi mouse (+ kelas event yg
## diterima tombol, untuk membuktikan toggle setting berlaku),
## strip atas 64x64 (perbesar 18 Nov 2026) + bar 414 + tak tumpang.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_interact := false
var _f_reset := false
var _f_kamera := false
var _f_suara := false
var _f_peta := false
var _f_kartu := false
var _f_mp := false
var _f_full := false
var _ev_kelas: Array = []


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("SENTUH LULUS: ", nama)
	else:
		_gagal += 1
		print("SENTUH GAGAL: ", nama)


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


## Tap jari: tekan + lepas di satu posisi (index 0).
## KOREKSI KOORDINAT (Tara, 19 Nov 2026 — temuan diagnostik
## test_diagnostik_koordinat_mini2): push_input menerima koordinat
## VIEWPORT (piksel), sedangkan get_global_rect() memberi koordinat
## KANVAS. Dengan stretch canvas_items + aspect expand, skala =
## window / visible_rect (0,32 di 412x892) — tanpa konversi, tap
## mendarat ~3x terlalu jauh (di luar layar) dan SEMUA tombol
## "gagal" padahal game-nya benar. Di jendela 1280x720 skala=1,
## jadi tes lama 47/47 tidak pernah menangkap ini.
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


func _atur_onboarding(langkah: int) -> void:
	var ob := {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


## Cari tombol strip atas dari meta ikon (pola test_tombol_x.gd).
func _cari_tombol_ikon(jenis: String) -> Button:
	var ui = _main._ui
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			for t in (c as HBoxContainer).get_children():
				if t is Button and (t as Button).has_meta("ikon"):
					var ik = ui._ikon_dari(t as Button)
					if ik != null and ik.jenis == jenis:
						return t as Button
	return null


## Cari tombol berdasarkan teks, rekursif (untuk tombol di dalam overlay).
func _cari_tombol_teks(n: Node, teks: String) -> Button:
	if n is Button and (n as Button).text == teks:
		return n as Button
	for c in n.get_children():
		var r := _cari_tombol_teks(c, teks)
		if r != null:
			return r
	return null


func _ready() -> void:
	print("SENTUH: emulate_mouse_from_touch default = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	print("SENTUH: emulate_touch_from_mouse default = ", ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"))
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	await _run()
	print("TES SENTUH: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	# Isolasi MP + pop-up muncul (flag false).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_atur_onboarding(2)
	_main._masuk_pesantren("Tes sentuh")
	await _tunggu(3)
	var ui = _main._ui

	# --- 0. Pop-up petunjuk: tap Mengerti (sentuh) ---
	_cek("pop-up petunjuk tampil saat pertama main", ui.is_petunjuk_visible())
	_cek("tombol Mengerti ada", ui._petunjuk_mengerti_btn != null)
	if ui._petunjuk_mengerti_btn != null:
		await _tap_tombol(ui._petunjuk_mengerti_btn)
		_cek("TAP Mengerti -> pop-up tertutup", not ui.is_petunjuk_visible())
		_cek("TAP Mengerti -> flag save true", bool(_main._save.get("petunjuk_tombol_ditutup", false)))

	# --- 1. ✕ dekat Kyai (putra, langkah 2): sinyal saja ---
	_main._kyai.position = Vector3(-3.5, 0, -2.0)
	ui._interact_btn.text = "XXXX"
	ui.set_interact_visible(false)
	_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
	await _tunggu(3)
	_cek("dekat Kyai langkah 2: tombol ✕ TAMPIL", ui._interact_btn.visible)
	_cek("dekat Kyai langkah 2: teks 'MULAI MISI'", ui._interact_btn.text == "MULAI MISI")
	ui.interact_pressed.disconnect(_main._on_interact)
	ui.interact_pressed.connect(func() -> void: _f_interact = true)
	var x_btn := ui._tombol_gamepad.get("x") as Button
	_cek("tombol ✕ ada di diamond", x_btn != null)
	if x_btn != null:
		_f_interact = false
		await _tap_tombol(x_btn)
		_cek("TAP ✕ tengah -> sinyal interact_pressed", _f_interact)
	ui.interact_pressed.connect(_main._on_interact)

	# --- 2. Gamepad lain + strip atas (tap sentuh) ---
	var aksi_btn := ui._tombol_gamepad.get("segitiga") as Button
	if aksi_btn != null:
		await _tap_tombol(aksi_btn)
		_cek("TAP △ -> panel aksi terbuka", ui.is_aksi_visible())
		ui.close_aksi()
	var chat_btn := ui._tombol_gamepad.get("kotak") as Button
	if chat_btn != null:
		await _tap_tombol(chat_btn)
		_cek("TAP □ -> panel chat terbuka", ui.is_chat_visible())
		ui.close_chat()
	ui.reset_requested.connect(func() -> void: _f_reset = true)
	ui.reset_requested.disconnect(_main._respawn_ke_spawn)
	var reset_btn := ui._tombol_gamepad.get("lingkaran") as Button
	if reset_btn != null:
		_f_reset = false
		await _tap_tombol(reset_btn)
		_cek("TAP ○ -> sinyal reset_requested", _f_reset)
	ui.reset_requested.connect(_main._respawn_ke_spawn)
	ui.kamera_mode_pressed.connect(func() -> void: _f_kamera = true)
	ui.kamera_mode_pressed.disconnect(_main._ganti_mode_kamera)
	_f_kamera = false
	await _tap_tombol(ui._kamera_ikon_btn)
	_cek("TAP kamera strip atas -> sinyal kamera_mode_pressed", _f_kamera)
	ui.kamera_mode_pressed.connect(_main._ganti_mode_kamera)
	ui.suara_toggled.connect(func() -> void: _f_suara = true)
	ui.suara_toggled.disconnect(_main._on_suara_toggled)
	_f_suara = false
	await _tap_tombol(ui._suara_btn)
	_cek("TAP suara strip atas -> sinyal suara_toggled", _f_suara)
	ui.suara_toggled.connect(_main._on_suara_toggled)
	ui.open_peta_requested.connect(func() -> void: _f_peta = true)
	ui.open_peta_requested.disconnect(_main._on_open_peta)
	_f_peta = false
	var peta_btn := _cari_tombol_ikon("peta")
	_cek("tombol peta strip atas ada", peta_btn != null)
	if peta_btn != null:
		await _tap_tombol(peta_btn)
		_cek("TAP peta strip atas -> sinyal open_peta_requested", _f_peta)
	ui.open_peta_requested.connect(_main._on_open_peta)
	ui.open_dashboard_requested.connect(func() -> void: _f_kartu = true)
	ui.open_dashboard_requested.disconnect(_main._on_open_dashboard)
	_f_kartu = false
	var kartu_btn := _cari_tombol_ikon("kartu")
	_cek("tombol kartu strip atas ada", kartu_btn != null)
	if kartu_btn != null:
		await _tap_tombol(kartu_btn)
		_cek("TAP kartu strip atas -> sinyal open_dashboard_requested", _f_kartu)
	ui.open_dashboard_requested.connect(_main._on_open_dashboard)
	ui.mp_gabung_ditekan.connect(func() -> void: _f_mp = true)
	ui.mp_gabung_ditekan.disconnect(_main._on_mp_gabung_ditekan)
	_f_mp = false
	await _tap_tombol(ui._mp_gabung_btn)
	_cek("TAP Main Bersama -> sinyal mp_gabung_ditekan", _f_mp)
	ui.mp_gabung_ditekan.connect(_main._on_mp_gabung_ditekan)
	ui._layar_penuh_btn.pressed.connect(func() -> void: _f_full = true)
	_f_full = false
	await _tap_tombol(ui._layar_penuh_btn)
	_cek("TAP layar penuh strip atas -> sinyal pressed", _f_full)

	# --- 2b. Strip atas 64x64 (DI-ACC Mas 21:18 WIB, 18 Nov 2026:
	# perbesar dari 48x48). Ukuran kanvas + lebar bar + tidak
	# tumpang tindih + gamepad/joystick TAK berubah. ---
	var strip_64 := true
	for jenis in ["kartu", "peta", "kamera", "speaker", "expand", "kualitas"]:
		var tb := _cari_tombol_ikon(jenis)
		if tb == null or tb.custom_minimum_size != Vector2(64, 64):
			strip_64 = false
	_cek("strip atas: 6 tombol ikon 64x64 kanvas", strip_64)
	var bar: HBoxContainer = null
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			var anak := (c as HBoxContainer).get_children()
			if not anak.is_empty() and anak[0] is Button and (anak[0] as Button).has_meta("ikon"):
				bar = c as HBoxContainer
	_cek("strip atas: bar ada", bar != null)
	if bar != null:
		_cek("strip atas: lebar bar 414 (6x64 + 5x6)", int(bar.size.x) == 414)
		_cek("strip atas: bar tidak tumpang minimap", not bar.get_global_rect().intersects(ui._minimap.get_global_rect()))
		_cek("strip atas: bar tidak tumpang pill Main Bersama", not bar.get_global_rect().intersects(ui._mp_gabung_btn.get_global_rect()))
	_cek("strip atas: pill Main Bersama 200x56", ui._mp_gabung_btn.custom_minimum_size == Vector2(200, 56))
	_cek("strip atas: gamepad ✕ tetap 100x100 (tak diubah)", ui._interact_btn.custom_minimum_size == Vector2(100, 100))
	_cek("strip atas: joystick tetap 220x220 (tak diubah)", ui._joystick.size == Vector2(220, 220))
	var kartu_ik := _cari_tombol_ikon("kartu")
	if kartu_ik != null:
		var ik = ui._ikon_dari(kartu_ik)
		_cek("strip atas: ikon kartu 46x46 (proporsional 64)", ik != null and (ik as Control).size == Vector2(46, 46))

	# --- 1b. ✕ (handler main tersambung) -> dialog misi TERBUKA ---
	_main._kyai.position = Vector3(-3.5, 0, -2.0)
	_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
	await _tunggu(3)
	_cek("sebelum tap: tidak ada panel misi terbuka", _main._manajer_misi == null or not _main._manajer_misi.ada_panel_terbuka())
	await _tap_tombol(x_btn)
	_cek("TAP ✕ dekat Kyai -> dialog misi terbuka", _main._manajer_misi != null and _main._manajer_misi.ada_panel_terbuka())
	if _main._manajer_misi != null:
		_main._manajer_misi.tutup_semua()
		await _tunggu(2)
		_cek("tutup_semua menutup panel misi", not _main._manajer_misi.ada_panel_terbuka())

	# --- 5. Joystick: drag sentuh -> output != 0, lepas -> 0 ---
	var joy = ui._joystick
	var pusat: Vector2 = _ke_piksel(joy.get_global_rect().get_center())
	var t_joy := InputEventScreenTouch.new()
	t_joy.index = 1
	t_joy.pressed = true
	t_joy.position = pusat
	get_viewport().push_input(t_joy)
	await get_tree().process_frame
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = _ke_piksel(joy.get_global_rect().get_center() + Vector2(80, 0))
	get_viewport().push_input(drag)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("DRAG sentuh joystick -> output kanan > 0.5 (output=%s)" % str(joy.output), joy.output.x > 0.5)
	var r_joy := InputEventScreenTouch.new()
	r_joy.index = 1
	r_joy.pressed = false
	r_joy.position = _ke_piksel(joy.get_global_rect().get_center() + Vector2(80, 0))
	get_viewport().push_input(r_joy)
	await get_tree().process_frame
	_cek("LEPAS sentuh joystick -> output 0", joy.output == Vector2.ZERO)

	# --- 6. ✕ TANPA emulasi mouse (sentuhan mentah) ---
	# Rekam kelas event yang diterima tombol: bila toggle berlaku,
	# yang masuk HANYA InputEventScreenTouch (tanpa mouse).
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	print("SENTUH: emulate_mouse_from_touch kini = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	_ev_kelas.clear()
	x_btn.gui_input.connect(func(ev: InputEvent) -> void: _ev_kelas.append(ev.get_class()))
	_main._kyai.position = Vector3(-3.5, 0, -2.0)
	_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
	await _tunggu(3)
	_cek("tanpa emulasi: tombol ✕ masih TAMPIL dekat Kyai", ui._interact_btn.visible)
	ui.interact_pressed.disconnect(_main._on_interact)
	ui.interact_pressed.connect(func() -> void: _f_interact = true)
	_f_interact = false
	await _tap_tombol(x_btn)
	_cek("TAP ✕ TANPA emulasi mouse -> sinyal interact_pressed", _f_interact)
	print("SENTUH: kelas event diterima ✕ tanpa emulasi = ", str(_ev_kelas))
	_cek("tanpa emulasi: ✕ hanya terima sentuh (tanpa mouse)", not ("InputEventMouseButton" in _ev_kelas) and ("InputEventScreenTouch" in _ev_kelas))
	# Opsi A 19 Nov 2026: emulate_mouse_from_touch=false kini DEFAULT
	# proyek (project.godot) — TIDAK dikembalikan ke true di sini.

	# --- 7. Overlay "PUTAR HP-MU" TIDAK memblokir sentuhan (TARA 18 Nov
	# 2026 — laporan Mas "tombol di HP belum stabil"): latar overlay
	# IGNORE, hanya tombol "Tetap main portrait" yang STOP. Overlay
	# dipaksa tampil (Xvfb bukan layar sentuh, jadi butuh_putar_hp
	# false) lalu TAP ✕ + kamera strip atas harus tetap sampai. ---
	var ov: Control = ui._rotate_overlay
	_cek("overlay putar HP ada", ov != null)
	if ov != null:
		_cek("overlay putar HP: root IGNORE", ov.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		var ov_bg: Control = null
		var ov_center: Control = null
		for c in ov.get_children():
			if c is ColorRect:
				ov_bg = c as Control
			if c is CenterContainer:
				ov_center = c as Control
		_cek("overlay putar HP: latar IGNORE", ov_bg != null and ov_bg.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		_cek("overlay putar HP: center IGNORE", ov_center != null and ov_center.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		ov.visible = true
		await _tunggu(1)
		_cek("overlay putar HP: tampil saat dipaksa", ov.visible)
		# TAP ✕ dekat Kyai selagi overlay tampil.
		_main._kyai.position = Vector3(-3.5, 0, -2.0)
		_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
		await _tunggu(3)
		_cek("overlay tampil: tombol ✕ masih TAMPIL", ui._interact_btn.visible)
		ui.interact_pressed.disconnect(_main._on_interact)
		ui.interact_pressed.connect(func() -> void: _f_interact = true)
		_f_interact = false
		await _tap_tombol(x_btn)
		_cek("overlay tampil: TAP ✕ -> sinyal interact_pressed", _f_interact)
		ui.interact_pressed.connect(_main._on_interact)
		# TAP kamera strip atas selagi overlay tampil.
		ui.kamera_mode_pressed.connect(func() -> void: _f_kamera = true)
		ui.kamera_mode_pressed.disconnect(_main._ganti_mode_kamera)
		_f_kamera = false
		await _tap_tombol(ui._kamera_ikon_btn)
		_cek("overlay tampil: TAP kamera -> sinyal kamera_mode_pressed", _f_kamera)
		ui.kamera_mode_pressed.connect(_main._ganti_mode_kamera)
		# Tombol overlay sendiri tetap bisa ditekan -> menutup overlay.
		var portrait_btn := _cari_tombol_teks(ov, "Tetap main portrait")
		_cek("overlay putar HP: tombol 'Tetap main portrait' ada", portrait_btn != null)
		if portrait_btn != null:
			_cek("overlay putar HP: tombol portrait STOP (bisa ditekan)", portrait_btn.mouse_filter == Control.MOUSE_FILTER_STOP)
			await _tap_tombol(portrait_btn)
			_cek("TAP 'Tetap main portrait' -> overlay tertutup", not ov.visible)
