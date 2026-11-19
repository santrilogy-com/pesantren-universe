extends Node
## DIAG TOGGLE — Tara (UI, 19 Nov 2026; Opsi A 19 Nov 2026).
## Gejala T1 Mas: yang HIDUP = kamera, reset, ✕/misi, joystick;
## yang MATI = △/□/strip lain. Semua yang mati itu TOGGLE
## (aksi/chat/kartu/peta/suara/layar-penuh).
## Penyebab (TERBUKTI): di HP asli (web export,
## emulate_mouse_from_touch=true) satu ketukan menghasilkan DUA event
## — touch + mouse emulasi — sehingga tombol toggle ditekan 2x dalam
## satu ketukan (buka lalu tutup lagi) dan tampak "mati".
## Perbaikan (Opsi A): emulate_mouse_from_touch=false di project.godot
## — ketukan HP asli kini hanya menghasilkan InputEventScreenTouch.
## CATATAN HARNESS: push_input TIDAK memicu emulasi engine, jadi
## dorongan manual sentuh+mouse tetap menghasilkan pressed=2 (T11
## mengunci perilaku harness ini — BUKAN bug produk). Simulasi
## ketukan HP pasca-perbaikan di tes ini = sentuh saja (_ketuk_sentuh);
## jalur klik mouse desktop dicek terpisah (T10, _ketuk_mouse).
## Xvfb 412x892. Output: print "TES TOGGLE: LULUS= GAGAL=".

const MAIN_SCENE := "res://main.tscn"

var _main: Node
var _lulus := 0
var _gagal := 0
var _hitung: Dictionary = {}


func _cek(nama: String, ok: bool, info: String = "") -> void:
	if ok:
		_lulus += 1
		print("  OK: ", nama, " ", info)
	else:
		_gagal += 1
		print("  GAGAL: ", nama, " ", info)


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _dorong_sentuh_tekan(pos: Vector2) -> void:
	var tekan := InputEventScreenTouch.new()
	tekan.index = 0
	tekan.pressed = true
	tekan.position = _ke_piksel(pos)
	get_viewport().push_input(tekan)
	await get_tree().process_frame


func _dorong_sentuh_lepas(pos: Vector2) -> void:
	var lepas := InputEventScreenTouch.new()
	lepas.index = 0
	lepas.pressed = false
	lepas.position = _ke_piksel(pos)
	get_viewport().push_input(lepas)
	await get_tree().process_frame


func _dorong_mouse_tekan(pos: Vector2) -> void:
	var tekan := InputEventMouseButton.new()
	tekan.button_index = MOUSE_BUTTON_LEFT
	tekan.pressed = true
	tekan.position = _ke_piksel(pos)
	get_viewport().push_input(tekan)
	await get_tree().process_frame


func _dorong_mouse_lepas(pos: Vector2) -> void:
	var lepas := InputEventMouseButton.new()
	lepas.button_index = MOUSE_BUTTON_LEFT
	lepas.pressed = false
	lepas.position = _ke_piksel(pos)
	get_viewport().push_input(lepas)
	await get_tree().process_frame


## Ketuk sentuh saja (seperti tes lama).
func _ketuk_sentuh(pos: Vector2) -> void:
	await _dorong_sentuh_tekan(pos)
	await _dorong_sentuh_lepas(pos)


## Ketuk mouse saja.
func _ketuk_mouse(pos: Vector2) -> void:
	await _dorong_mouse_tekan(pos)
	await _dorong_mouse_lepas(pos)


## Dorong manual sentuh+mouse (touch-press, mouse-press,
## touch-release, mouse-release) — urutan yang DULU dihasilkan engine
## saat emulate_mouse_from_touch=true menerima satu sentuhan jari.
## Pasca-Opsi A engine TIDAK lagi mensintesis mouse dari sentuhan,
## jadi ini BUKAN simulasi ketukan HP — hanya kunci perilaku harness
## (T11): push_input melewati emulasi, pressed tetap fire 2x.
func _ketuk_ganda_manual(pos: Vector2) -> void:
	await _dorong_sentuh_tekan(pos)
	await _dorong_mouse_tekan(pos)
	await _dorong_sentuh_lepas(pos)
	await _dorong_mouse_lepas(pos)


func _pusat(b: Control) -> Vector2:
	return b.get_global_rect().get_center()


func _siap_hitungan(nama: String) -> void:
	_hitung[nama] = 0


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_main._save["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Diag toggle")
	await _tunggu(3)
	var ui = _main._ui
	if ui.is_petunjuk_visible() and ui._petunjuk_mengerti_btn != null:
		await _ketuk_sentuh(_pusat(ui._petunjuk_mengerti_btn))
	# Spy: hitung tiap `pressed` tombol yang diselidiki.
	var aksi_btn: Button = ui._tombol_gamepad["segitiga"]
	var chat_btn: Button = ui._tombol_gamepad["kotak"]
	var kartu_btn := _cari_tombol_ikon("kartu")
	var peta_btn := _cari_tombol_ikon("peta")
	var kamera_btn := _cari_tombol_ikon("kamera")
	for pas in [
		["aksi", aksi_btn], ["chat", chat_btn], ["kartu", kartu_btn],
		["peta", peta_btn], ["kamera", kamera_btn],
		["suara", ui._suara_btn], ["layar", ui._layar_penuh_btn],
		["interact", ui._interact_btn], ["reset", ui._reset_btn],
	]:
		_siap_hitungan(String(pas[0]))
		(pas[1] as Button).pressed.connect(_hitung_pressed.bind(String(pas[0])))

	# T1 kontrol: sentuh saja pada △ -> panel aksi TERBUKA, pressed 1x.
	await _ketuk_sentuh(_pusat(aksi_btn))
	_cek("T1 sentuh saja △ -> aksi terbuka", ui.is_aksi_visible(), "pressed=" + str(_hitung["aksi"]))
	_cek("T1 sentuh saja △ -> pressed tepat 1x", int(_hitung["aksi"]) == 1)
	# T2: ketuk HP pasca-Opsi A pada △ (sentuh saja; tutup dulu via
	# sentuh bila masih terbuka dari T1) -> pressed 1x, aksi TERBUKA.
	if ui.is_aksi_visible():
		await _ketuk_sentuh(_pusat(aksi_btn))
	_siap_hitungan("aksi")
	await _ketuk_sentuh(_pusat(aksi_btn))
	_cek("T2 ketuk HP △ -> pressed tepat 1x", int(_hitung["aksi"]) == 1, "pressed=" + str(_hitung["aksi"]))
	_cek("T2 ketuk HP △ -> aksi TERBUKA", ui.is_aksi_visible())
	if ui.is_aksi_visible():
		await _ketuk_sentuh(_pusat(aksi_btn))

	# T3: ketuk HP pasca-Opsi A pada □ chat (sentuh saja).
	_siap_hitungan("chat")
	await _ketuk_sentuh(_pusat(chat_btn))
	_cek("T3 ketuk HP □ -> pressed tepat 1x", int(_hitung["chat"]) == 1, "pressed=" + str(_hitung["chat"]))
	_cek("T3 ketuk HP □ -> chat TERBUKA", ui.is_chat_visible())
	if ui.is_chat_visible():
		await _ketuk_sentuh(_pusat(chat_btn))

	# T4: ketuk HP pasca-Opsi A pada strip suara (sentuh saja) -> mute
	# harus BERUBAH tepat 1 toggle.
	var mati_awal := bool(_main._save.get("suara_mati", false))
	_siap_hitungan("suara")
	await _ketuk_sentuh(_pusat(ui._suara_btn))
	_cek("T4 ketuk HP suara -> pressed tepat 1x", int(_hitung["suara"]) == 1, "pressed=" + str(_hitung["suara"]))
	_cek("T4 ketuk HP suara -> mute BERUBAH dari awal", bool(_main._save.get("suara_mati", false)) != mati_awal)

	# T5: ketuk HP pasca-Opsi A pada strip peta (sentuh saja).
	_siap_hitungan("peta")
	await _ketuk_sentuh(_pusat(peta_btn))
	_cek("T5 ketuk HP peta -> pressed tepat 1x", int(_hitung["peta"]) == 1, "pressed=" + str(_hitung["peta"]))
	_cek("T5 ketuk HP peta -> peta TERBUKA", ui.is_peta_visible())
	if ui.is_peta_visible():
		await _ketuk_sentuh(_pusat(peta_btn))

	# T6: ketuk HP pasca-Opsi A pada strip kartu / dashboard (sentuh saja).
	_siap_hitungan("kartu")
	await _ketuk_sentuh(_pusat(kartu_btn))
	_cek("T6 ketuk HP kartu -> pressed tepat 1x", int(_hitung["kartu"]) == 1, "pressed=" + str(_hitung["kartu"]))
	_cek("T6 ketuk HP kartu -> dashboard TERBUKA", ui.is_dashboard_visible())
	if ui.is_dashboard_visible():
		await _ketuk_sentuh(_pusat(kartu_btn))

	# T7: ketuk HP pasca-Opsi A pada strip kamera (sentuh saja) ->
	# mode maju tepat 1 langkah (bukan 2 seperti saat double-fire).
	var mode_awal: String = _main._kamera.nama_mode()
	_siap_hitungan("kamera")
	await _ketuk_sentuh(_pusat(kamera_btn))
	_cek("T7 ketuk HP kamera -> pressed tepat 1x", int(_hitung["kamera"]) == 1, "pressed=" + str(_hitung["kamera"]))
	_cek("T7 ketuk HP kamera -> mode BERUBAH dari awal", _main._kamera.nama_mode() != mode_awal, "mode=" + _main._kamera.nama_mode())

	# T8: ketuk HP pasca-Opsi A pada ✕ jauh dari NPC (sentuh saja) ->
	# Panel Misi terbuka, pressed 1x.
	_siap_hitungan("interact")
	if ui._interact_btn.visible:
		await _ketuk_sentuh(_pusat(ui._interact_btn))
		_cek("T8 ketuk HP ✕ -> pressed tepat 1x", int(_hitung["interact"]) == 1, "pressed=" + str(_hitung["interact"]))
		_cek("T8 ketuk HP ✕ -> ada panel misi terbuka", _main._manajer_misi.ada_panel_terbuka() or ui.is_mission_visible())
	else:
		print("  SKIP T8: tombol ✕ tidak terlihat (bukan langkah misi)")
	# T9: jalur _unhandled_input (perbaikan cacat #2): tutup dulu panel
	# misi sisa T8 LANGSUNG via API (tombol ✕ disembunyikan main.gd
	# saat panel misi terbuka, jadi tidak bisa diketuk untuk menutup),
	# baru buka aksi via sentuh saja, lalu mouse-press DI DALAM panel
	# (kanvas (640,280)) harus TIDAK menutup; mouse-press DI LUAR
	# (kanvas (640,2600)) HARUS menutup.
	if _main._manajer_misi != null and _main._manajer_misi.ada_panel_terbuka():
		_main._manajer_misi.tutup_semua()
	if ui.is_mission_visible():
		ui.close_mission()
	await _tunggu(2)
	_cek("T9 setup panel misi tertutup", not _main._manajer_misi.ada_panel_terbuka() and not ui.is_mission_visible())
	await _ketuk_sentuh(_pusat(aksi_btn))
	_cek("T9 setup aksi terbuka", ui.is_aksi_visible())
	await _dorong_mouse_tekan(Vector2(640, 280))
	await _dorong_mouse_lepas(Vector2(640, 280))
	_cek("T9 mouse DI DALAM panel aksi -> tetap terbuka", ui.is_aksi_visible())
	await _dorong_mouse_tekan(Vector2(640, 2600))
	await _dorong_mouse_lepas(Vector2(640, 2600))
	_cek("T9 mouse DI LUAR panel aksi -> tertutup", not ui.is_aksi_visible())

	# T10: jalur klik mouse desktop (regresi Opsi A): klik mouse saja
	# pada △ -> pressed 1x, aksi TERBUKA (emulate_touch_from_mouse
	# tetap true; mouse tidak boleh ikut mati).
	_siap_hitungan("aksi")
	await _ketuk_mouse(_pusat(aksi_btn))
	_cek("T10 klik mouse △ -> pressed tepat 1x", int(_hitung["aksi"]) == 1, "pressed=" + str(_hitung["aksi"]))
	_cek("T10 klik mouse △ -> aksi TERBUKA", ui.is_aksi_visible())
	if ui.is_aksi_visible():
		await _ketuk_mouse(_pusat(aksi_btn))

	# T11: kunci perilaku harness — dorong manual sentuh+mouse tetap
	# fire 2x karena push_input melewati emulasi engine. Ini BUKAN
	# bug produk (engine asli pasca-Opsi A tidak mensintesis mouse
	# dari sentuhan); jangan "perbaiki" tes ini jadi 1x.
	_siap_hitungan("aksi")
	await _ketuk_ganda_manual(_pusat(aksi_btn))
	_cek("T11 harness sentuh+mouse manual -> pressed tetap 2x", int(_hitung["aksi"]) == 2, "pressed=" + str(_hitung["aksi"]))
	if ui.is_aksi_visible():
		await _ketuk_sentuh(_pusat(aksi_btn))

	print("TES TOGGLE: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _hitung_pressed(nama: String) -> void:
	_hitung[nama] = int(_hitung.get(nama, 0)) + 1


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
