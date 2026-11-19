extends Node
## TES RANTAI — Tara (UI). Pendamping headless test_tombol_telepon:
## Xvfb lambat (scene load software-rendering), tes ini TIDAK memakai
## input sama sekali — ia memanggil handler langsung untuk menutup
## celah test_tombol_sentuh: handler main.gd untuk kartu/peta/suara
## + toggle △/□ + rantai TANYA langkah 4 + stempel build. Jalur
## tombol->sinyal sendiri SUDAH terbukti 47/47 di test_tombol_sentuh;
## tes ini membuktikan sinyal->efek. Headless, --fixed-fps 60.

const MAIN_SCENE := "res://main.tscn"

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("RANTAI LULUS: ", nama)
	else:
		_gagal += 1
		print("RANTAI GAGAL: ", nama)


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _atur_onboarding(langkah: int) -> void:
	var ob := {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	await _run()
	print("TES RANTAI: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)


func _run() -> void:
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = true
	_atur_onboarding(4)
	_main._masuk_pesantren("Tes rantai")
	await _tunggu(3)
	var ui = _main._ui
	_cek("setup: pop-up petunjuk tidak tampil", not ui.is_petunjuk_visible())

	# --- A. Handler main.gd: kartu/peta/suara/kamera/reset ---
	_main._on_open_dashboard()
	_cek("A1 _on_open_dashboard -> dashboard terbuka", ui.is_dashboard_visible())
	_main._on_open_dashboard()
	_cek("A1 _on_open_dashboard lagi -> dashboard tertutup", not ui.is_dashboard_visible())
	_main._on_open_peta()
	_cek("A2 _on_open_peta -> peta terbuka", ui.is_peta_visible())
	_main._on_open_peta()
	_cek("A2 _on_open_peta lagi -> peta tertutup", not ui.is_peta_visible())
	var mati_sebelum := bool(_main._save.get("suara_mati", false))
	_main._on_suara_toggled()
	_cek("A3 _on_suara_toggled -> save suara_mati berbalik", bool(_main._save.get("suara_mati", false)) != mati_sebelum)
	_main._on_suara_toggled()
	_cek("A3 _on_suara_toggled lagi -> save kembali", bool(_main._save.get("suara_mati", false)) == mati_sebelum)
	var mode_sebelum: String = ui._kamera_ikon_btn.text
	_main._ganti_mode_kamera()
	_cek("A4 _ganti_mode_kamera -> label mode berubah (%s -> %s)" % [mode_sebelum, ui._kamera_ikon_btn.text], ui._kamera_ikon_btn.text != mode_sebelum)
	_main._teleport_player(Vector3(50, 0, 50), 0.0)
	await _tunggu(2)
	_main._respawn_ke_spawn()
	await _tunggu(2)
	_cek("A5 _respawn_ke_spawn -> pemain kembali ke spawn (pos=%s)" % str(_main._player.global_position), _main._player.global_position.distance_to(Vector3(-4, 0, 14)) < 2.0)

	# --- B. Toggle △/□ langsung ---
	ui._toggle_aksi()
	_cek("B1 _toggle_aksi -> panel aksi terbuka", ui.is_aksi_visible())
	ui._toggle_aksi()
	_cek("B1 _toggle_aksi lagi -> panel aksi tertutup", not ui.is_aksi_visible())
	ui._toggle_chat()
	_cek("B2 _toggle_chat -> panel chat terbuka", ui.is_chat_visible())
	ui.close_chat()
	_cek("B2 close_chat -> panel chat tertutup", not ui.is_chat_visible())

	# --- C. Joystick: output berubah saat drag (simulasi logika) ---
	var joy = ui._joystick
	joy._update_knob(joy.size * 0.5 + Vector2(80, 0))
	_cek("C1 _update_knob kanan -> output.x > 0.5 (output=%s)" % str(joy.output), joy.output.x > 0.5)
	joy._reset()
	_cek("C2 _reset -> output 0", joy.output == Vector2.ZERO)

	# --- D. TANYA end-to-end, langkah 4 (keadaan Mas) ---
	_main._bilal.position = Vector3(-4, 0, 4)
	_main._teleport_player(Vector3(-4, 0, 6.5), PI)
	await _tunggu(3)
	_main._update_interact_button()
	_cek("D1 dekat Bilal langkah 4: tombol ✕ TAMPIL", ui._interact_btn.visible)
	_cek("D1 dekat Bilal langkah 4: teks ✕ = 'TANYA' (teks=%s)" % ui._interact_btn.text, ui._interact_btn.text == "TANYA")
	var dibuka: bool = _main._buka_ui_misi_terdekat()
	_cek("D2 _buka_ui_misi_terdekat -> true", dibuka)
	_cek("D2 layar tanya terbuka (panel=%s)" % _main._manajer_misi.panel_terbuka(), _main._manajer_misi.panel_terbuka() == "dialog")
	_main._manajer_misi.tutup_semua()
	await _tunggu(2)
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	await _tunggu(3)
	_main._update_interact_button()
	_cek("D3 jauh dari NPC: ✕ tidak berbunyi 'TANYA' (teks=%s, tampil=%s)" % [ui._interact_btn.text, str(ui._interact_btn.visible)], ui._interact_btn.text != "TANYA")

	# --- E. Stempel build ---
	_cek("E1 stempel build ada", ui._stempel_label != null)
	if ui._stempel_label != null:
		_cek("E2 stempel build teks 'Build 716a5831' (teks=%s)" % ui._stempel_label.text, ui._stempel_label.text == "Build 716a5831")
		_cek("E3 stempel build IGNORE (tak blokir sentuhan)", ui._stempel_label.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		_cek("E4 stempel build terlihat", ui._stempel_label.visible)
		var vp := get_viewport().get_visible_rect()
		_cek("E5 stempel build rect di dalam layar", vp.encloses(ui._stempel_label.get_global_rect()))
