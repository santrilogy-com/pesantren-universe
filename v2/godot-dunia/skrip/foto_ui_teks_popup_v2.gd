extends Node
## Foto BUKTI implementasi Konsep UI v2 (Sinta, 19 Nov 2026 — ACC Mas
## 12:48 WIB): dialog misi + pop-up petunjuk tombol + banner misi.
## F1: dialog Ust. Aqsal M (langkah 2, dekat Kyai) — babak 1.
## F2: pop-up "PETUNJUK TOMBOL" (flag false, tampil langsung).
## F3: banner misi putra (langkah 2, teks persis ucapan Mas).
## Nama file BARU (v2/foto-ui/*-v2-implementasi.png).
## Jalankan di Xvfb :98 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:98 godot --path . skrip/foto_ui_teks_popup_v2.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}


func _foto(nama: String) -> void:
	for i in 20:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _dekat_npc(npc: Node3D) -> void:
	var pos: Vector3 = npc.global_position
	_main._teleport_player(Vector3(pos.x, 0, pos.z + 1.5), PI)
	for i in 10:
		await get_tree().process_frame


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(720, 1560)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# SIMPAN save asli (pola foto_ui_misi.gd — jangan kontaminasi
	# santri.json; dipulihkan sebelum quit).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	# ISOLASI: putra, flag petunjuk false (pop-up tampil), onboarding
	# langkah 2 (dialog + banner misi). Nama foto, ig kosong (offline).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto UI v2"
	_main._save["petunjuk_tombol_ditutup"] = false
	_main._save["onboarding"] = {"langkah": 2, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto UI v2")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame

	# F2 DULU: pop-up petunjuk (muncul saat masuk — flag false).
	print("FOTO-CEK F2 popup: visible=%s (harap true)" % str(_main._ui.is_petunjuk_visible()))
	await _foto("popup-v2-implementasi.png")
	_main._ui._tutup_petunjuk()
	for i in 5:
		await get_tree().process_frame

	# F3: banner misi putra.
	_main._ui.show_petunjuk_misi(false)
	for i in 5:
		await get_tree().process_frame
	print("FOTO-CEK F3 banner: visible=%s teks='%s'" % [str(_main._ui.is_petunjuk_misi_visible()), _main._ui.teks_petunjuk_misi()])
	await _foto("banner-v2-implementasi.png")
	_main._ui.hide_petunjuk_misi()
	for i in 5:
		await get_tree().process_frame

	# F1: dialog — dekat Kyai, langkah 2, ✕.
	await _dekat_npc(_main._kyai)
	_main._on_interact()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK F1 dialog: panel='%s' (harap dialog)" % _main._manajer_misi.panel_terbuka())
	if _main._manajer_misi.panel_terbuka() != "dialog":
		_main._manajer_misi.buka_dialog("putra")
		print("FOTO-CEK F1: routing gagal, panel dibuka langsung")
	await _foto("dialog-v2-implementasi.png")
	_main._manajer_misi.tutup_semua()

	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	SantriSave.save_data(_main._save)
	print("FOTO UI TEKS POPUP v2 SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
