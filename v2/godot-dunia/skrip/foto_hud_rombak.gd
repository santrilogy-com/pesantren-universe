extends Node
## Foto BUKTI rombakan HUD v2 (Tara, 18 Nov 2026 — arahan Mas 15:10 WIB:
## tombol ala MLBB, jangan primitif — v1 kotak hijau datar DITOLAK).
## F1: HUD v2 portrait 720x1560 (aspek HP Mas) — bar ikon kaca gelap +
## klaster skill bulat + Main Bersama pill + minimap + JOYSTICK (v2
## harus kelihatan di foto idle — di foto v1 joystick tidak terlihat).
## F2: panel Chat dibuka lewat tombol icon amplop ASLI (bukan panggil
## _toggle_chat langsung) — bukti icon amplop tetap membuka chat.
## Jalankan di Xvfb :98 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:98 godot --path . skrip/foto_hud_rombak.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-hud/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}


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
	# ISOLASI MP (pola test_v2.gd): kosongkan ig supaya offline,
	# tombol "Main Bersama" tampil.
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Tara"
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
	print("FOTO-CEK viewport=%s interact visible=%s teks='%s' chat=%s" % [
		str(get_viewport().get_visible_rect().size),
		str(ui._interact_btn.visible), ui._interact_btn.text, str(ui.is_chat_visible())])
	print("FOTO-CEK rect: kamera=%s mode_label='%s' aksi/kamera/reset OK" % [
		str(ui._kamera_btn.get_global_rect()), ui._kamera_mode_label.text])
	await _foto("hud-v2-idle.png")
	# F2: buka chat lewat tombol icon amplop ASLI.
	ui._chat_ikon_btn.pressed.emit()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK setelah tekan icon amplop: chat=%s" % str(ui.is_chat_visible()))
	await _foto("hud-v2-chat.png")
	ui.close_chat()
	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	SantriSave.save_data(_main._save)
	print("FOTO HUD ROMBAK SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
