extends Node
## Tes tombol ✕ + audit SEMUA tombol — KLIK SUNGGUHAN (Tara).
## Latar: laporan Mas 20:30 WIB "ga bisa tekan X pas deket" — misi
## pertama tidak bisa dimulai. Tes lama (test_hud_rombak) hanya
## memanggil `button.pressed.emit()` — itu menguji wiring sinyal,
## BUKAN apakah ketukan nyata sampai ke tombol (icon anak / overlay
## yang menutupi / tombol yang tidak pernah tampil). Tes ini
## mengirim InputEventMouseButton sungguhan lewat viewport dan
## memeriksa sinyal/panel benar-benar merespon.
##
## Yang diuji (klik nyata di tengah tombol + di sudut 5,5):
##  0. Pop-up PETUNJUK: klik "Mengerti" -> tertutup + flag save.
##  1. ✕ dekat Kyai (putra, langkah 2) -> tombol TAMPIL "MULAI MISI"
##     + klik -> sinyal interact_pressed + klik lagi (handler main
##     tersambung) -> dialog misi TERBUKA.
##  2. △/□/○ + strip atas (kamera/suara/peta/kartu/Main Bersama/
##     layar penuh) -> sinyal/panel merespon.
##  3. Login: link daftar, gender PUTRI, MASUK/DAFTAR kosong -> error
##     (tanpa jaringan), kembali.
##  4. Struktural: icon anak tombol mouse_filter IGNORE; tidak ada
##     kontrol STOP yang terlihat menutupi rect ✕; _hud IGNORE.
##  5. [BUG TERKENAL — main.gd, patch Raka] Putri dekat Mariyah di
##     rumahnya (134,-17): pintu Musholla (exit 134,-17,5, radius
##     2,5 m) MENUTUPI misi — tombol tampil "MASUK MUSHOLLA" bukan
##     "MULAI MISI". Cek ini GAGAL sampai cabang misi didahulukan
##     atas pintu di _update_interact_button() + _on_interact().
##  6. [CELAH TERKENAL — main.gd, patch Raka] Langkah 4 (cari
##     Sanusi): dekat Sanusi tombol ✕ TIDAK TAMPIL (tidak ada cabang
##     langkah 4 di _dekat_npc_misi()). Cek ini GAGAL sampai cabang
##     langkah 4 ditambahkan (tampil + tekan -> maju ke 5 + buka
##     Ruang Belajar).
##
## Jalankan headless (tanpa Xvfb — tidak ada resize):
##   godot --headless --path . skrip/test_tombol_x.tscn
## Save dipulihkan di akhir (pola test_hud_rombak).

var _main: Node
var _lulus := 0
var _gagal := 0
var _save_asli := {}
var _f_interact := false
var _f_reset := false
var _f_kamera := false
var _f_suara := false
var _f_peta := false
var _f_kartu := false
var _f_mp := false
var _f_full := false


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _klik_pos(pos: Vector2) -> void:
	var tekan := InputEventMouseButton.new()
	tekan.button_index = MOUSE_BUTTON_LEFT
	tekan.pressed = true
	tekan.position = pos
	get_viewport().push_input(tekan)
	var lepas := InputEventMouseButton.new()
	lepas.button_index = MOUSE_BUTTON_LEFT
	lepas.pressed = false
	lepas.position = pos
	get_viewport().push_input(lepas)
	for i in 2:
		await get_tree().process_frame


func _klik_tombol(b: Button) -> void:
	await _klik_pos(b.get_global_rect().get_center())


func _klik_sudut(b: Button) -> void:
	await _klik_pos(b.get_global_rect().position + Vector2(5, 5))


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _atur_onboarding(langkah: int) -> void:
	var ob := {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


func _atur_gender(jk: String) -> void:
	_main._save["jenis_kelamin"] = jk
	SantriSave.save_data(_main._save)


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await _tunggu(2)
	_save_asli = (_main._save as Dictionary).duplicate(true)
	var ui = _main._ui
	# Isolasi MP + pop-up muncul (flag false).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_atur_onboarding(2)
	_main._masuk_pesantren("Tes tombol X")
	await _tunggu(3)

	# --- 0. Pop-up PETUNJUK: klik "Mengerti" (nyata) ---
	_cek("pop-up petunjuk tampil saat pertama main", ui.is_petunjuk_visible())
	var mengerti: Button = ui._petunjuk_mengerti_btn
	_cek("tombol Mengerti ada", mengerti != null)
	if mengerti != null:
		await _klik_tombol(mengerti)
		_cek("klik Mengerti -> pop-up tertutup", not ui.is_petunjuk_visible())
		_cek("klik Mengerti -> flag save true", bool(_main._save.get("petunjuk_tombol_ditutup", false)))

	# --- 1. ✕ dekat Kyai (putra, langkah 2) ---
	# Kyai DIPAKSA ke (-3.5,-2) — dia patroli, jadi tanpa ini
	# posisinya acak saat tes jalan. Pemain di (-3.5,0.5): jarak
	# ke Kyai 2,5 m (<= 3,5), jarak ke pintu Surau (0,-3.8) ~5,5 m
	# (> 2,5). Teks dipalsukan dulu supaya cek 'MULAI MISI' tidak
	# vakum (teks awal memang 'MULAI MISI').
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
		await _klik_tombol(x_btn)
		_cek("KLIK NYATA tengah ✕ -> sinyal interact_pressed", _f_interact)
		_f_interact = false
		await _klik_sudut(x_btn)
		_cek("KLIK NYATA sudut ✕ -> sinyal interact_pressed", _f_interact)
	ui.interact_pressed.connect(_main._on_interact)

	# --- 2. Gamepad lain + strip atas (klik nyata) ---
	var aksi_btn := ui._tombol_gamepad.get("segitiga") as Button
	if aksi_btn != null:
		await _klik_tombol(aksi_btn)
		_cek("KLIK NYATA △ -> panel aksi terbuka", ui.is_aksi_visible())
		ui.close_aksi()
	var chat_btn := ui._tombol_gamepad.get("kotak") as Button
	if chat_btn != null:
		await _klik_tombol(chat_btn)
		_cek("KLIK NYATA □ -> panel chat terbuka", ui.is_chat_visible())
		ui.close_chat()
	ui.reset_requested.connect(func() -> void: _f_reset = true)
	ui.reset_requested.disconnect(_main._respawn_ke_spawn)
	var reset_btn := ui._tombol_gamepad.get("lingkaran") as Button
	if reset_btn != null:
		_f_reset = false
		await _klik_tombol(reset_btn)
		_cek("KLIK NYATA ○ -> sinyal reset_requested", _f_reset)
	ui.reset_requested.connect(_main._respawn_ke_spawn)
	ui.kamera_mode_pressed.connect(func() -> void: _f_kamera = true)
	ui.kamera_mode_pressed.disconnect(_main._ganti_mode_kamera)
	_f_kamera = false
	await _klik_tombol(ui._kamera_ikon_btn)
	_cek("KLIK NYATA kamera strip atas -> sinyal kamera_mode_pressed", _f_kamera)
	ui.kamera_mode_pressed.connect(_main._ganti_mode_kamera)
	ui.suara_toggled.connect(func() -> void: _f_suara = true)
	ui.suara_toggled.disconnect(_main._on_suara_toggled)
	_f_suara = false
	# Tombol suara ada di bar_ikon (anak ke-4); cari via _suara_btn.
	await _klik_tombol(ui._suara_btn)
	_cek("KLIK NYATA suara strip atas -> sinyal suara_toggled", _f_suara)
	ui.suara_toggled.connect(_main._on_suara_toggled)
	# Peta + kartu: lepas handler main (buka panel), cek sinyal saja.
	ui.open_peta_requested.connect(func() -> void: _f_peta = true)
	ui.open_peta_requested.disconnect(_main._on_open_peta)
	_f_peta = false
	var peta_btn: Button = null
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			for t in (c as HBoxContainer).get_children():
				if t is Button and (t as Button).has_meta("ikon"):
					var ik = ui._ikon_dari(t as Button)
					if ik != null and ik.jenis == "peta":
						peta_btn = t as Button
	_cek("tombol peta strip atas ada", peta_btn != null)
	if peta_btn != null:
		await _klik_tombol(peta_btn)
		_cek("KLIK NYATA peta strip atas -> sinyal open_peta_requested", _f_peta)
	ui.open_peta_requested.connect(_main._on_open_peta)
	ui.open_dashboard_requested.connect(func() -> void: _f_kartu = true)
	ui.open_dashboard_requested.disconnect(_main._on_open_dashboard)
	_f_kartu = false
	var kartu_btn: Button = null
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			for t in (c as HBoxContainer).get_children():
				if t is Button and (t as Button).has_meta("ikon"):
					var ik2 = ui._ikon_dari(t as Button)
					if ik2 != null and ik2.jenis == "kartu":
						kartu_btn = t as Button
	_cek("tombol kartu strip atas ada", kartu_btn != null)
	if kartu_btn != null:
		await _klik_tombol(kartu_btn)
		_cek("KLIK NYATA kartu strip atas -> sinyal open_dashboard_requested", _f_kartu)
	ui.open_dashboard_requested.connect(_main._on_open_dashboard)
	ui.mp_gabung_ditekan.connect(func() -> void: _f_mp = true)
	ui.mp_gabung_ditekan.disconnect(_main._on_mp_gabung_ditekan)
	_f_mp = false
	await _klik_tombol(ui._mp_gabung_btn)
	_cek("KLIK NYATA Main Bersama -> sinyal mp_gabung_ditekan", _f_mp)
	ui.mp_gabung_ditekan.connect(_main._on_mp_gabung_ditekan)
	ui._layar_penuh_btn.pressed.connect(func() -> void: _f_full = true)
	_f_full = false
	await _klik_tombol(ui._layar_penuh_btn)
	_cek("KLIK NYATA layar penuh strip atas -> sinyal pressed", _f_full)

	# --- 1b. ✕ (handler main tersambung) -> dialog misi TERBUKA ---
	# Pemain masih dekat Kyai, langkah 2. Kyai dipaksa lagi ke
	# (-3.5,-2) karena dia patroli selama fase 2.
	_main._kyai.position = Vector3(-3.5, 0, -2.0)
	_main._teleport_player(Vector3(-3.5, 0, 0.5), PI)
	await _tunggu(3)
	_cek("sebelum klik: tidak ada panel misi terbuka", _main._manajer_misi == null or not _main._manajer_misi.ada_panel_terbuka())
	await _klik_tombol(x_btn)
	_cek("KLIK NYATA ✕ dekat Kyai -> dialog misi terbuka", _main._manajer_misi != null and _main._manajer_misi.ada_panel_terbuka())
	if _main._manajer_misi != null:
		_main._manajer_misi.tutup_semua()
		await _tunggu(2)
		_cek("tutup_semua menutup panel misi", not _main._manajer_misi.ada_panel_terbuka())

	# --- 3. Login: tombol-tombol layar login (klik nyata, tanpa jaringan) ---
	ui.show_login(_main._save)
	await _tunggu(3)
	_cek("show_login menampilkan panel login", ui._login_panel.visible)
	# Link daftar -> kotak daftar tampil.
	await _klik_tombol(ui._daftar_link)
	_cek("klik link daftar -> kotak daftar tampil", ui._register_box.visible)
	# Gender PUTRI -> nilai berubah.
	await _klik_tombol(ui._reg_putri_btn)
	_cek("klik PUTRI -> gender terpilih putri", ui.gender_daftar_terpilih() == "putri")
	await _klik_tombol(ui._reg_putra_btn)
	_cek("klik PUTRA -> gender terpilih putra", ui.gender_daftar_terpilih() == "putra")
	# MASUK kosong -> error (tanpa jaringan).
	ui._tampil_masuk()
	await _tunggu(2)
	ui._ig_input.text = ""
	await _klik_tombol(ui._masuk_btn)
	_cek("klik MASUK kosong -> error tampil", String(ui._login_error.text) != "")
	# DAFTAR kosong -> error (tanpa jaringan).
	ui._tampil_daftar()
	await _tunggu(2)
	ui._reg_nama_input.text = ""
	await _klik_tombol(ui._reg_daftar_btn)
	_cek("klik DAFTAR kosong -> error tampil", String(ui._reg_error.text) != "")
	# Kembali -> kotak masuk.
	await _klik_tombol(ui._kembali_btn)
	_cek("klik kembali -> kotak masuk tampil", ui._login_box.visible)
	_main._ui.show_world()

	# --- 4. Struktural: icon IGNORE + tidak ada yang menutupi ✕ ---
	var ikon_ok := true
	for k in ui._tombol_gamepad.keys():
		var b := ui._tombol_gamepad[k] as Button
		for ch in b.get_children():
			if ch is IkonHUD and (ch as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
				ikon_ok = false
	_cek("icon anak 4 tombol gamepad mouse_filter IGNORE", ikon_ok)
	var ikon_bar_ok := true
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			for t in (c as HBoxContainer).get_children():
				if t is Button:
					for ch in (t as Button).get_children():
						if ch is IkonHUD and (ch as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
							ikon_bar_ok = false
	_cek("icon anak tombol strip atas mouse_filter IGNORE", ikon_bar_ok)
	_cek("_hud mouse_filter IGNORE", ui._hud.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_cek("minimap mouse_filter IGNORE", ui._minimap.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	# Pemindai penutup: kontrol STOP yang terlihat + rect beririsan
	# dengan rect ✕, selain ✕ sendiri + anak-anaknya + sesama
	# tombol gamepad (sudut disc 100x100 BOLEH bersentuhan 15 px —
	# lihat _build_hud; hanya laporkan irisan > 10x10 px).
	var r_x: Rect2 = x_btn.get_global_rect()
	var penutup := []
	var gamepad_btns: Array = []
	for k in ui._tombol_gamepad.keys():
		gamepad_btns.append(ui._tombol_gamepad[k])
	var tumpuk: Array = [ui._hud]
	while not tumpuk.is_empty():
		var n = tumpuk.pop_back()
		if n is Control and n != x_btn and not x_btn.is_ancestor_of(n) and not (n in gamepad_btns):
			var cc := n as Control
			if cc.visible and cc.mouse_filter == Control.MOUSE_FILTER_STOP:
				var irisan := cc.get_global_rect().intersection(r_x)
				if irisan.get_area() > 100.0:
					penutup.append(String(n.name) + " " + str(cc.get_global_rect()) + " irisan=" + str(irisan.get_area()))
		for ch2 in n.get_children():
			tumpuk.append(ch2)
	_cek("tidak ada kontrol STOP terlihat menutupi ✕ (penutup: %s)" % str(penutup), penutup.is_empty())

	# --- 5. [BUG TERKENAL] Putri dekat Mariyah di rumahnya ---
	_atur_gender("putri")
	_atur_onboarding(2)
	_main._masuk_pesantren("Tes tombol X putri")
	await _tunggu(3)
	# Mariyah dipaksa ke rumahnya (134,-17); pemain di (134,-16):
	# jarak ke Mariyah 1 m, ke pintu Musholla (134,-17.5) 1,5 m.
	_main._ustadzah.position = Vector3(134, 0, -17)
	_main._teleport_player(Vector3(134, 0, -16), PI)
	await _tunggu(3)
	var jarak_m: float = _main._player.global_position.distance_to(_main._ustadzah.global_position)
	var jarak_pintu: float = _main._player.global_position.distance_to(Vector3(134, 0, -17.5))
	print("PUTRI: jarak ke Mariyah=%.2f, ke pintu Musholla=%.2f, teks tombol='%s', terlihat=%s" % [jarak_m, jarak_pintu, ui._interact_btn.text, str(ui._interact_btn.visible)])
	_cek("[BUG] putri dekat Mariyah di rumah: teks 'MULAI MISI'", ui._interact_btn.text == "MULAI MISI")

	# --- 6. [CELAH TERKENAL] Langkah 4 dekat Sanusi ---
	_atur_gender("putra")
	_atur_onboarding(4)
	_main._masuk_pesantren("Tes tombol X langkah 4")
	await _tunggu(3)
	var spos: Vector3 = _main._sanusi.global_position
	_main._teleport_player(spos + Vector3(2, 0, 0), PI)
	await _tunggu(3)
	var jarak_s: float = _main._player.global_position.distance_to(_main._sanusi.global_position)
	print("LANGKAH4: jarak ke Sanusi=%.2f, teks tombol='%s', terlihat=%s" % [jarak_s, ui._interact_btn.text, str(ui._interact_btn.visible)])
	_cek("[CELAH] langkah 4 dekat Sanusi: tombol ✕ TAMPIL", ui._interact_btn.visible)

	# --- pulihkan save + keluar ---
	_main._save = _save_asli
	SantriSave.save_data(_main._save)
	print("TES TOMBOL X: LULUS=%d GAGAL=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


func _ready() -> void:
	_run()
