extends Node
## Foto BUKTI implementasi HUD v3 gamepad — VARIAN B rev1 (Tara,
## 18 Nov 2026 — DI-ACC Mas 18:43 WIB, mockup
## hud-v3-perbaikan-b-rev1.png): disc + pill kaca buram bertinta
## zamrud muda alpha 150 (tanpa bayangan), icon/chevron/teks pill
## ZAMRUD GELAP; □ = Chat, kamera di strip atas (icon kamera slot
## ke-3); pop-up panel alpha 225 + dim 80.
## F1: pop-up "PETUNJUK TOMBOL" saat pertama main (flag false) —
## judul + 4 baris hitam + "Mengerti" + ×, scene di-dim, klaster
## diamond + analog tetap kelihatan.
## F2: idle HUD B rev1 portrait 720x1560 (aspek HP Mas) — analog
## kaca bertinta + klaster diamond △□○✕ zamrud gelap tanpa teks +
## bar ikon (kamera di strip atas) + pill "Main Bersama" zamrud
## gelap + minimap + Interact ✕ tampil ("MULAI MISI").
## Nama file BARU (hud-v3-brev1-*.png) — foto v3 lama
## (hud-v3-idle.png / hud-v3-popup.png) adalah bukti "sebelum"
## kontras buruk, JANGAN ditimpa.
## Jalankan di Xvfb :98 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:98 godot --path . skrip/foto_hud_v3.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-hud/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false


func _foto(nama: String) -> void:
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	# Portrait HP Mas (Galaxy A35 1080x2340 = 9:19,5; 720x1560 sama).
	get_window().size = Vector2i(720, 1560)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# SIMPAN save asli (pola foto_kamera_mode.gd — jangan kontaminasi
	# santri.json dengan nama/gender foto; dipulihkan sebelum quit).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	# ISOLASI MP (pola test_v2.gd): kosongkan ig supaya offline,
	# tombol "Main Bersama" tampil. Flag petunjuk false supaya
	# pop-up muncul (F1).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Tara"
	_main._save["petunjuk_tombol_ditutup"] = false
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Tara")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# Portrait di Xvfb :98 MELAPORKAN layar sentuh tersedia, jadi
	# overlay "PUTAR HP-MU" muncul (butuh_putar_hp: sentuh + portrait)
	# — tutup seperti Mas mengetuk "Tetap main portrait", supaya
	# HUD + dunia terlihat di foto (di HP Mas overlay ini memang
	# muncul di portrait sampai diketuk).
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame
	# Dekat penanda M1 (3,0,-6.5) supaya Interact "MULAI MISI" tampil.
	# Pelajaran foto sebelumnya: JANGAN teleport ke z<=-4 (garis
	# dinding selatan Surau) — pemain tertanam di dinding dan kamera
	# hanya melihat tembok/kubah dari dalam. Posisi (4,0,-3.5) masih
	# dalam radius interaksi 3,5 m (jarak 3,16 m) tapi 0,5 m DI LUAR
	# dinding — pemain terlihat berdiri di depan serambi.
	_main._teleport_player(Vector3(4, 0, -3.5), PI)
	for i in 10:
		await get_tree().process_frame
	var ui = _main._ui
	print("FOTO-CEK viewport=%s interact visible=%s teks='%s' petunjuk=%s" % [
		str(get_viewport().get_visible_rect().size),
		str(ui._interact_btn.visible), ui._interact_btn.text, str(ui.is_petunjuk_visible())])
	print("FOTO-CEK diamond: segitiga=%s kotak=%s lingkaran=%s x=%s" % [
		str(ui._tombol_gamepad["segitiga"].get_global_rect()),
		str(ui._tombol_gamepad["kotak"].get_global_rect()),
		str(ui._tombol_gamepad["lingkaran"].get_global_rect()),
		str(ui._tombol_gamepad["x"].get_global_rect())])
	# F1: pop-up petunjuk (awal main).
	await _foto("hud-v3-brev1-popup.png")
	# F2: tutup pop-up via tombol "Mengerti" ASLI, lalu foto idle.
	ui._petunjuk_mengerti_btn.pressed.emit()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK setelah tutup pop-up: petunjuk=%s flag=%s" % [
		str(ui.is_petunjuk_visible()), str(_main._save.get("petunjuk_tombol_ditutup", false))])
	await _foto("hud-v3-brev1-idle.png")
	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	SantriSave.save_data(_main._save)
	print("FOTO HUD V3 SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
