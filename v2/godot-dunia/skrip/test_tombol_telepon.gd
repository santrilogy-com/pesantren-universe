extends Node
## TES TELEPON — Tara (UI). Diagnostik T1 Mas 19 Nov 08:18 WIB: setelah
## deploy 716a5831, di HP Mas yang bisa HANYA kamera strip atas, reset
## (○), dan ✕ "Misi" — △/□/joystick/kartu/peta/suara/layar-penuh
## tetap mati "seperti sebelumnya". Private tab sudah dicoba Mas
## (cache GUGUR) + export segar byte-identik dengan live (pck basi
## GUGUR) — jadi bug ada di kode/build saat ini.
##
## Beda dari test_tombol_sentuh.gd: tes ini TIDAK memutus handler
## main.gd untuk kartu/peta/suara — panelnya harus BENAR-BENAR
## terbuka (celah tes lama: hanya sinyal yang dicek). Tambah:
## tap di luar tengah (presisi jari), rect panel harus di layar,
## TANYA end-to-end di langkah 4 (keadaan Mas), joystick dari
## titik awal di luar tengah, dan stempel build.
## JALANKAN DI Xvfb 412x892 (ukuran HP Mas).

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node
var _f_kartu := false
var _f_peta := false
var _f_kamera := false
var _f_suara := false
var _f_full := false
var _f_interact := false


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("TELEPON LULUS: ", nama)
	else:
		_gagal += 1
		print("TELEPON GAGAL: ", nama)


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


func _tap_di(b: Control, off: Vector2) -> void:
	await _tap(b.get_global_rect().get_center() + off)


func _atur_onboarding(langkah: int) -> void:
	var ob := {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


## Cari tombol strip atas dari meta ikon.
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


func _rect_di_layar(r: Rect2) -> bool:
	var vp := get_viewport().get_visible_rect()
	return vp.encloses(r)


func _bersih_spy() -> void:
	_f_kartu = false
	_f_peta = false
	_f_kamera = false
	_f_suara = false
	_f_full = false
	_f_interact = false


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	await _run()
	print("TES TELEPON: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_atur_onboarding(4)
	_main._masuk_pesantren("Tes telepon")
	await _tunggu(3)
	var ui = _main._ui
	# Spy sinyal strip + interact — TANPA memutus handler main.
	ui.open_dashboard_requested.connect(func() -> void: _f_kartu = true)
	ui.open_peta_requested.connect(func() -> void: _f_peta = true)
	ui.kamera_mode_pressed.connect(func() -> void: _f_kamera = true)
	ui.suara_toggled.connect(func() -> void: _f_suara = true)
	ui.interact_pressed.connect(func() -> void: _f_interact = true)
	ui._layar_penuh_btn.pressed.connect(func() -> void: _f_full = true)
	# Tutup pop-up petunjuk seperti pemain sungguhan.
	if ui.is_petunjuk_visible() and ui._petunjuk_mengerti_btn != null:
		await _tap_tombol(ui._petunjuk_mengerti_btn)
	_cek("setup: pop-up petunjuk tertutup", not ui.is_petunjuk_visible())

	# --- A. Rantai handler penuh: kartu/peta/suara/layar-penuh/△/□ ---
	var kartu_btn := _cari_tombol_ikon("kartu")
	var peta_btn := _cari_tombol_ikon("peta")
	var vp := get_viewport().get_visible_rect()
	_bersih_spy()
	if kartu_btn != null:
		await _tap_tombol(kartu_btn)
		_cek("A1 TAP kartu -> sinyal open_dashboard_requested", _f_kartu)
		_cek("A1 TAP kartu -> dashboard BENAR terbuka", ui.is_dashboard_visible())
		_cek("A1 dashboard rect di dalam layar", _rect_di_layar(ui._dashboard_panel.get_global_rect()))
		await _tap_tombol(kartu_btn)
		_cek("A1 TAP kartu lagi -> dashboard tertutup", not ui.is_dashboard_visible())
	_bersih_spy()
	if peta_btn != null:
		await _tap_tombol(peta_btn)
		_cek("A2 TAP peta -> sinyal open_peta_requested", _f_peta)
		_cek("A2 TAP peta -> peta BENAR terbuka", ui.is_peta_visible())
		_cek("A2 peta rect di dalam layar", _rect_di_layar(ui._peta_panel.get_global_rect()))
		await _tap_tombol(peta_btn)
		_cek("A2 TAP peta lagi -> peta tertutup", not ui.is_peta_visible())
	# --- B. Regresi cacat #2 (Tara, 19 Nov 2026): ketuk DI LUAR panel
	# (di bawah panel, kanvas (640,2600)) harus menutup panel. Dengan
	# bug lama (klik piksel vs rect kanvas), ketuk ini terbaca "di
	# dalam" dan panel tidak mau tertutup di HP portrait.
	_bersih_spy()
	await _tap_tombol(peta_btn)
	_cek("B1 peta terbuka lagi", ui.is_peta_visible())
	await _tap(Vector2(640, 2600))
	_cek("B2 TAP di luar (bawah panel) -> peta tertutup", not ui.is_peta_visible())
	var mati_sebelum := bool(_main._save.get("suara_mati", false))
	_bersih_spy()
	await _tap_tombol(ui._suara_btn)
	_cek("A3 TAP suara -> sinyal suara_toggled", _f_suara)
	_cek("A3 TAP suara -> save suara_mati berbalik", bool(_main._save.get("suara_mati", false)) != mati_sebelum)
	await _tap_tombol(ui._suara_btn)
	_cek("A3 TAP suara lagi -> save suara_mati kembali", bool(_main._save.get("suara_mati", false)) == mati_sebelum)
	_bersih_spy()
	await _tap_tombol(ui._layar_penuh_btn)
	_cek("A4 TAP layar penuh -> sinyal pressed", _f_full)
	var aksi_btn := ui._tombol_gamepad.get("segitiga") as Button
	if aksi_btn != null:
		await _tap_tombol(aksi_btn)
		_cek("A5 TAP △ -> panel aksi terbuka", ui.is_aksi_visible())
		_cek("A5 panel aksi rect di dalam layar", _rect_di_layar(ui._aksi_panel.get_global_rect()))
		ui.close_aksi()
	var chat_btn := ui._tombol_gamepad.get("kotak") as Button
	if chat_btn != null:
		await _tap_tombol(chat_btn)
		_cek("A6 TAP □ -> panel chat terbuka", ui.is_chat_visible())
		_cek("A6 panel chat rect di dalam layar", _rect_di_layar(ui._chat_panel.get_global_rect()))
		ui.close_chat()

	# --- B. Presisi jari: tap di luar tengah tombol ---
	# Strip 64u: setengah lebar 32u. Jari meleset ±10 px CSS = ±31u.
	# Tap ±26u HARUS tetap kena tombol yang sama.
	_bersih_spy()
	if peta_btn != null:
		await _tap_di(peta_btn, Vector2(26, 0))
		_cek("B1 TAP peta +26u -> sinyal peta (bukan tetangga)", _f_peta and not _f_kamera and not _f_kartu)
		ui.close_peta()
		_bersih_spy()
		await _tap_di(peta_btn, Vector2(-26, 0))
		_cek("B2 TAP peta -26u -> sinyal peta (bukan tetangga)", _f_peta and not _f_kamera and not _f_kartu)
		ui.close_peta()
		_bersih_spy()
		await _tap_di(peta_btn, Vector2(33, 0))
		_cek("B3 TAP peta +33u (di luar tombol) -> peta TIDAK kena", not _f_peta)
		print("TELEPON INFO: tap peta +33u -> kartu=", _f_kartu, " kamera=", _f_kamera, " suara=", _f_suara, " full=", _f_full)
	# Gamepad 100u: setengah lebar 50u. Tap ±40u HARUS tetap kena.
	if aksi_btn != null:
		await _tap_di(aksi_btn, Vector2(40, 0))
		_cek("B4 TAP △ +40u -> panel aksi terbuka", ui.is_aksi_visible())
		ui.close_aksi()
		await _tap_di(aksi_btn, Vector2(-40, 0))
		_cek("B5 TAP △ -40u -> panel aksi terbuka", ui.is_aksi_visible())
		ui.close_aksi()

	# --- C. Joystick dari titik awal di luar tengah ---
	var joy = ui._joystick
	var pusat: Vector2 = _ke_piksel(joy.get_global_rect().get_center() + Vector2(40, 30))
	var t_joy := InputEventScreenTouch.new()
	t_joy.index = 1
	t_joy.pressed = true
	t_joy.position = pusat
	get_viewport().push_input(t_joy)
	await get_tree().process_frame
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = _ke_piksel(joy.get_global_rect().get_center() + Vector2(120, 30))
	get_viewport().push_input(drag)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("C1 DRAG joystick dari luar tengah -> output kanan > 0.5 (output=%s)" % str(joy.output), joy.output.x > 0.5)
	var r_joy := InputEventScreenTouch.new()
	r_joy.index = 1
	r_joy.pressed = false
	r_joy.position = _ke_piksel(joy.get_global_rect().get_center() + Vector2(120, 30))
	get_viewport().push_input(r_joy)
	await get_tree().process_frame
	_cek("C2 LEPAS joystick -> output 0", joy.output == Vector2.ZERO)

	# --- D. TANYA end-to-end, langkah 4 (keadaan Mas) ---
	# Bilal di (-4,4); pemain di (-4,0,6.5) = jarak 2,5 m < 3,5 m.
	_main._bilal.position = Vector3(-4, 0, 4)
	_main._teleport_player(Vector3(-4, 0, 6.5), PI)
	await _tunggu(3)
	var x_btn := ui._tombol_gamepad.get("x") as Button
	_cek("D1 dekat Bilal langkah 4: tombol ✕ TAMPIL", ui._interact_btn.visible)
	_cek("D1 dekat Bilal langkah 4: teks ✕ = 'TANYA' (teks=%s)" % ui._interact_btn.text, ui._interact_btn.text == "TANYA")
	_bersih_spy()
	if x_btn != null:
		await _tap_tombol(x_btn)
		_cek("D2 TAP ✕ 'TANYA' -> sinyal interact_pressed", _f_interact)
		_cek("D2 TAP ✕ 'TANYA' -> layar tanya terbuka (panel=%s)" % _main._manajer_misi.panel_terbuka(), _main._manajer_misi.panel_terbuka() == "dialog")
		_main._manajer_misi.tutup_semua()
		await _tunggu(2)
		# Presisi ✕: ±45u dari tengah (setengah lebar 50u) harus kena.
		_bersih_spy()
		await _tap_di(x_btn, Vector2(45, 0))
		_cek("D3 TAP ✕ +45u -> layar tanya terbuka lagi", _main._manajer_misi.panel_terbuka() == "dialog")
		_main._manajer_misi.tutup_semua()
		await _tunggu(2)
		_bersih_spy()
		await _tap_di(x_btn, Vector2(-45, 0))
		_cek("D4 TAP ✕ -45u -> layar tanya terbuka lagi", _main._manajer_misi.panel_terbuka() == "dialog")
		_main._manajer_misi.tutup_semua()
		await _tunggu(2)
	# Jauh dari NPC (spawn, jarak ke Bilal 10 m): ✕ TIDAK boleh TANYA.
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	await _tunggu(3)
	_cek("D5 jauh dari NPC: ✕ tidak berbunyi 'TANYA' (teks=%s, tampil=%s)" % [ui._interact_btn.text, str(ui._interact_btn.visible)], ui._interact_btn.text != "TANYA")

	# --- E. Stempel build ---
	_cek("E1 stempel build ada", ui._stempel_label != null)
	if ui._stempel_label != null:
		# Stempel versi sumber (Tara, 19 Nov 2026): format YYYYMMDD-N,
		# bukan ID deployment — bandingkan dengan konstanta di ui.gd
		# supaya tes tidak basi saat Eka menaikkan stempel tiap staging.
		_cek("E2 stempel build teks 'Build 20261119-4' (teks=%s)" % ui._stempel_label.text, ui._stempel_label.text == "Build 20261119-4")
		_cek("E3 stempel build IGNORE (tak blokir sentuhan)", ui._stempel_label.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		_cek("E4 stempel build terlihat", ui._stempel_label.visible)
		_cek("E5 stempel build rect di dalam layar", _rect_di_layar(ui._stempel_label.get_global_rect()))
