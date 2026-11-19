extends Node
## TES SENTUH vs MOUSE — Tara (UI), 19 Nov 2026.
## Bukti baru Mas (13:40-13:42 WIB, HP Galaxy A35): tombol DI DALAM
## GAME mati di HP (sentuh) tapi SEMUA normal di PC (mouse); ketukan
## SAMPAI ke tombol (teks tombol muncul = visual pressed), hanya
## BEBERAPA tombol yang aksinya tak jalan; TIDAK ADA keyboard virtual
## (hipotesis keyboard GUGUR — ScrollContainer login TIDAK diterapkan).
## Hipotesis utama: DOUBLE-FIRE sentuh+mouse pada tombol TOGGLE
## (△ aksi, □ chat, peta, kartu, suara, layar penuh, kualitas):
## sekali ketuk = buka lalu tutup = tampak mati. Tombol momentary
## (✕, ○, kamera) selamat karena sinyal 2x tetap beraksi.
## PERBAIKAN 19 Nov 2026 (Xam ACC): debounce 200 ms di `ui.gd`
## (`_debounce_tekan`) — A3/A4/B3/B4 di bawah kini menegaskan
## perilaku SETELAH perbaikan (T5 pressed=1, panel TETAP TERBUKA).
## T6 diberi jeda 250 ms waktu nyata supaya benar-benar dua ketuk
## disengaja (> jendela debounce) — membuktikan debounce hanya
## menelan double-fire, bukan ketukan ganda sungguhan.
## Tes ini, per tombol, membandingkan 6 varian ketukan dan mencatat
## (a) jumlah emisi `pressed` tombol itu dan (b) keadaan akhir aksi.
## Varian: T1 sentuh murni | T2 mouse murni | T3 sentuh + geser 5px
## (drift jari) | T4 sentuh tahan 6 frame | T5 sentuh lalu mouse
## (urutan event kompatibilitas browser) | T6 dua ketuk sentuh.
## Spy memakai flag MEMBER (lambda TIDAK boleh menangkap var lokal).
## JALANKAN DI Xvfb --resolution 892x412 (landscape HP Mas).
## HANYA TES — tidak mengubah kode game.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _pressed_count := 0
var _f_reset := 0
var _f_interact := 0
var _f_kamera := 0
var _f_suara := 0
var _f_mp := 0
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


func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _sentuh_tekan(pos: Vector2, index: int = 0) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.pressed = true
	e.position = _ke_piksel(pos)
	get_viewport().push_input(e)


func _sentuh_lepas(pos: Vector2, index: int = 0) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.pressed = false
	e.position = _ke_piksel(pos)
	get_viewport().push_input(e)


func _sentuh_seret(dari: Vector2, ke: Vector2, index: int = 0) -> void:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = _ke_piksel(ke)
	e.relative = _ke_piksel(ke) - _ke_piksel(dari)
	get_viewport().push_input(e)


func _mouse_tekan(pos: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = _ke_piksel(pos)
	get_viewport().push_input(e)


func _mouse_lepas(pos: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = false
	e.position = _ke_piksel(pos)
	get_viewport().push_input(e)


# Spy pressed (member — lambda tidak boleh menangkap var lokal).
func _on_pressed_spy() -> void:
	_pressed_count += 1


func _on_reset_spy() -> void:
	_f_reset += 1


func _on_interact_spy() -> void:
	_f_interact += 1


func _on_kamera_spy() -> void:
	_f_kamera += 1


func _on_suara_spy() -> void:
	_f_suara += 1


func _on_mp_spy() -> void:
	_f_mp += 1


# Satu varian ketukan pada posisi kanvas `pos`; kembalikan jumlah
# emisi `pressed` tombol `b` selama varian (spy dipasang di sini).
func _varian(nama: String, b: Button, pos: Vector2) -> int:
	_pressed_count = 0
	b.pressed.connect(_on_pressed_spy)
	match nama:
		"T1":
			_sentuh_tekan(pos)
			await _tunggu(1)
			_sentuh_lepas(pos)
		"T2":
			_mouse_tekan(pos)
			await _tunggu(1)
			_mouse_lepas(pos)
		"T3":
			_sentuh_tekan(pos)
			await _tunggu(1)
			_sentuh_seret(pos, pos + Vector2(5, 0))
			await _tunggu(1)
			_sentuh_lepas(pos + Vector2(5, 0))
		"T4":
			_sentuh_tekan(pos)
			await _tunggu(6)
			_sentuh_lepas(pos)
		"T5":
			# Double-fire browser: event mouse kompatibilitas datang
			# SEGERA setelah touchend — frame yang SAMA (atau
			# sebelahnya), bukan 3 frame kemudian. Dorong ke-4 event
			# tanpa jeda frame: jeda frame di harness VM (frame
			# ~100-300 ms, render software) menggelembungkan jarak
			# wall-clock kedua `pressed` melewati jendela debounce
			# 200 ms — padahal di HP 60 fps jaraknya ~16-50 ms.
			_sentuh_tekan(pos)
			_sentuh_lepas(pos)
			_mouse_tekan(pos)
			_mouse_lepas(pos)
		"T6":
			_sentuh_tekan(pos)
			await _tunggu(1)
			_sentuh_lepas(pos)
			# Dua ketuk DELIBERATE: jeda 250 ms waktu nyata (> jendela
			# debounce 200 ms) supaya ketuk ke-2 TIDAK ditelan.
			await get_tree().create_timer(0.25).timeout
			_sentuh_tekan(pos)
			await _tunggu(1)
			_sentuh_lepas(pos)
	await _tunggu(2)
	b.pressed.disconnect(_on_pressed_spy)
	return _pressed_count


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


func _atur_onboarding(langkah: int) -> void:
	var ob := {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


func _ready() -> void:
	print("SENTUH: emulate_mouse_from_touch = ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	await _run()
	print("TES SENTUH-VS-MOUSE: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_atur_onboarding(2)
	_main._masuk_pesantren("Tes sentuh-vs-mouse")
	await _tunggu(3)
	var ui = _main._ui

	# Tutup pop-up petunjuk dulu (sentuh, seperti pemain).
	if ui.is_petunjuk_visible() and ui._petunjuk_mengerti_btn != null:
		var mp: Vector2 = ui._petunjuk_mengerti_btn.get_global_rect().get_center()
		_sentuh_tekan(mp)
		await _tunggu(1)
		_sentuh_lepas(mp)
		await _tunggu(2)
	_cek("setup: pop-up petunjuk tertutup", not ui.is_petunjuk_visible())

	# Siapkan ✕ dekat Kyai (langkah 2, putra).
	_main._kyai.position = Vector3(-3.5, 0, -2.0)
	_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
	await _tunggu(3)
	_cek("setup: tombol ✕ tampil dekat Kyai", ui._interact_btn.visible)

	var aksi_btn := ui._tombol_gamepad.get("segitiga") as Button
	var chat_btn := ui._tombol_gamepad.get("kotak") as Button
	var reset_btn := ui._tombol_gamepad.get("lingkaran") as Button
	var x_btn := ui._tombol_gamepad.get("x") as Button
	var peta_btn := _cari_tombol_ikon("peta")
	var kartu_btn := _cari_tombol_ikon("kartu")
	var kamera_btn := ui._kamera_ikon_btn as Button
	var suara_btn := ui._suara_btn as Button
	var full_btn := ui._layar_penuh_btn as Button
	var kualitas_btn := ui._kualitas_btn as Button
	var mp_btn := ui._mp_gabung_btn as Button
	_cek("setup: 11 tombol target ada", aksi_btn != null and chat_btn != null and reset_btn != null and x_btn != null and peta_btn != null and kartu_btn != null and kamera_btn != null and suara_btn != null and full_btn != null and kualitas_btn != null and mp_btn != null)
	if aksi_btn == null or chat_btn == null or peta_btn == null:
		return

	# Rekam kelas event yang diterima tombol △ (untuk T5).
	_ev_kelas.clear()
	aksi_btn.gui_input.connect(func(ev: InputEvent) -> void: _ev_kelas.append(ev.get_class()))

	# ===== A. TOMBOL TOGGLE △ AKSI — pressed + keadaan akhir panel =====
	var aksi_t1_pressed := -1
	var aksi_t1_buka := false
	var aksi_t5_pressed := -1
	var aksi_t5_buka := true
	for v in ["T1", "T2", "T3", "T4", "T5", "T6"]:
		ui.close_aksi()
		var n := await _varian(v, aksi_btn, aksi_btn.get_global_rect().get_center())
		var buka: bool = ui.is_aksi_visible()
		print("AKSI %s pressed=%d terbuka=%s" % [v, n, str(buka)])
		if v == "T1":
			aksi_t1_pressed = n
			aksi_t1_buka = buka
		if v == "T5":
			aksi_t5_pressed = n
			aksi_t5_buka = buka
	ui.close_aksi()
	_cek("A1: T1 sentuh murni △ pressed=1", aksi_t1_pressed == 1)
	_cek("A2: T1 sentuh murni △ panel TERBUKA", aksi_t1_buka)
	_cek("A3: T5 sentuh+mouse △ pressed TETAP 2 (emisi ganda di level sinyal — debounce bekerja di handler)", aksi_t5_pressed == 2)
	_cek("A4: T5 sentuh+mouse △ panel TETAP TERBUKA (debounce menelan aksi ke-2)", aksi_t5_buka)

	# ===== B. TOMBOL TOGGLE □ CHAT — pressed + keadaan akhir panel =====
	var chat_t1_pressed := -1
	var chat_t1_buka := false
	var chat_t5_pressed := -1
	var chat_t5_buka := true
	for v in ["T1", "T2", "T3", "T4", "T5", "T6"]:
		ui.close_chat()
		var n := await _varian(v, chat_btn, chat_btn.get_global_rect().get_center())
		var buka: bool = ui.is_chat_visible()
		print("CHAT %s pressed=%d terbuka=%s" % [v, n, str(buka)])
		if v == "T1":
			chat_t1_pressed = n
			chat_t1_buka = buka
		if v == "T5":
			chat_t5_pressed = n
			chat_t5_buka = buka
	ui.close_chat()
	_cek("B1: T1 sentuh murni □ pressed=1", chat_t1_pressed == 1)
	_cek("B2: T1 sentuh murni □ panel TERBUKA", chat_t1_buka)
	_cek("B3: T5 sentuh+mouse □ pressed TETAP 2 (emisi ganda di level sinyal — debounce bekerja di handler)", chat_t5_pressed == 2)
	_cek("B4: T5 sentuh+mouse □ panel TETAP TERBUKA (debounce menelan aksi ke-2)", chat_t5_buka)

	# ===== C. TOGGLE peta / kartu / kualitas — pressed + keadaan akhir =====
	for v in ["T1", "T2", "T5"]:
		if ui.is_peta_visible():
			ui.close_peta()
		var n := await _varian(v, peta_btn, peta_btn.get_global_rect().get_center())
		print("PETA %s pressed=%d terbuka=%s" % [v, n, str(ui.is_peta_visible())])
		if ui.is_peta_visible():
			ui.close_peta()
	for v in ["T1", "T2", "T5"]:
		if ui.is_dashboard_visible():
			ui.close_dashboard()
		var n := await _varian(v, kartu_btn, kartu_btn.get_global_rect().get_center())
		print("KARTU %s pressed=%d terbuka=%s" % [v, n, str(ui.is_dashboard_visible())])
		if ui.is_dashboard_visible():
			ui.close_dashboard()
	for v in ["T1", "T2", "T5"]:
		ui._kualitas_panel.visible = false
		var n := await _varian(v, kualitas_btn, kualitas_btn.get_global_rect().get_center())
		print("KUALITAS %s pressed=%d terbuka=%s" % [v, n, str(ui._kualitas_panel.visible)])
		ui._kualitas_panel.visible = false

	# ===== D. TOMBOL SINYAL (momentary) — jumlah sinyal per varian =====
	# Handler main dilepas, spy menghitung. Harapan SETELAH debounce:
	# T1/T2 = 1 sinyal; T5 = 1 sinyal untuk kamera/suara (handlernya
	# ikut di-debounce di ui.gd) dan 2 sinyal untuk reset/interact/mp
	# (momentary, SENGAJA tidak di-debounce — aksinya idempoten).
	# Kamera: sebelum debounce T5 = 2 sinyal = lompat 2 mode.
	ui.reset_requested.disconnect(_main._respawn_ke_spawn)
	ui.interact_pressed.disconnect(_main._on_interact)
	ui.kamera_mode_pressed.disconnect(_main._ganti_mode_kamera)
	ui.suara_toggled.disconnect(_main._on_suara_toggled)
	ui.mp_gabung_ditekan.disconnect(_main._on_mp_gabung_ditekan)
	for v in ["T1", "T2", "T5"]:
		_f_reset = 0
		ui.reset_requested.connect(_on_reset_spy)
		var n := await _varian(v, reset_btn, reset_btn.get_global_rect().get_center())
		ui.reset_requested.disconnect(_on_reset_spy)
		print("RESET %s pressed=%d sinyal=%d" % [v, n, _f_reset])
	for v in ["T1", "T2", "T5"]:
		_f_interact = 0
		ui.interact_pressed.connect(_on_interact_spy)
		var n := await _varian(v, x_btn, x_btn.get_global_rect().get_center())
		ui.interact_pressed.disconnect(_on_interact_spy)
		print("INTERACT %s pressed=%d sinyal=%d" % [v, n, _f_interact])
	for v in ["T1", "T2", "T5"]:
		_f_kamera = 0
		ui.kamera_mode_pressed.connect(_on_kamera_spy)
		var n := await _varian(v, kamera_btn, kamera_btn.get_global_rect().get_center())
		ui.kamera_mode_pressed.disconnect(_on_kamera_spy)
		print("KAMERA %s pressed=%d sinyal=%d" % [v, n, _f_kamera])
	for v in ["T1", "T2", "T5"]:
		_f_suara = 0
		ui.suara_toggled.connect(_on_suara_spy)
		var n := await _varian(v, suara_btn, suara_btn.get_global_rect().get_center())
		ui.suara_toggled.disconnect(_on_suara_spy)
		print("SUARA %s pressed=%d sinyal=%d" % [v, n, _f_suara])
	for v in ["T1", "T2", "T5"]:
		_f_mp = 0
		ui.mp_gabung_ditekan.connect(_on_mp_spy)
		var n := await _varian(v, mp_btn, mp_btn.get_global_rect().get_center())
		ui.mp_gabung_ditekan.disconnect(_on_mp_spy)
		print("MP %s pressed=%d sinyal=%d" % [v, n, _f_mp])
	# Layar penuh: hitung pressed saja (handler JS fullscreen dijaga
	# non-web; yang diukur di sini hanya apakah tombol double-fire).
	# Toggle juga: 2x tekan = fullscreen nyala lalu mati = tampak mati.
	for v in ["T1", "T2", "T5"]:
		var n := await _varian(v, full_btn, full_btn.get_global_rect().get_center())
		print("FULL %s pressed=%d" % [v, n])
	ui.reset_requested.connect(_main._respawn_ke_spawn)
	ui.interact_pressed.connect(_main._on_interact)
	ui.kamera_mode_pressed.connect(_main._ganti_mode_kamera)
	ui.suara_toggled.connect(_main._on_suara_toggled)
	ui.mp_gabung_ditekan.connect(_main._on_mp_gabung_ditekan)

	# ===== E. Kelas event di tombol △ selama semua varian =====
	print("EV-KELAS △ selama semua varian: ", str(_ev_kelas))
	_cek("E: △ menerima InputEventScreenTouch", "InputEventScreenTouch" in _ev_kelas)
	_cek("E: △ menerima InputEventMouseButton (dari T2/T5)", "InputEventMouseButton" in _ev_kelas)
