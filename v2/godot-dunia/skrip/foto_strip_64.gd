extends Node
## Foto BUKTI strip atas 64x64 — Tara (UI), 18 Nov 2026.
## Mas ACC 21:18 WIB: perbesar tombol strip atas 48x48 -> 64x64.
## Satu foto portrait 720x1560 (aspek HP Mas) + cetak rect bar +
## tiap tombol strip + minimap + pill Main Bersama (bukti ukuran
## dan tidak tumpang tindih). Nama file BARU, jangan timpa foto B rev1.
## Jalankan di Xvfb :97 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:97 godot --path . skrip/foto_strip_64.tscn

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
	get_window().size = Vector2i(720, 1560)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Tara"
	_main._save["petunjuk_tombol_ditutup"] = true
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Tara")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame
	_main._teleport_player(Vector3(4, 0, -3.5), PI)
	for i in 10:
		await get_tree().process_frame
	var ui = _main._ui
	print("FOTO-CEK viewport=%s" % str(get_viewport().get_visible_rect().size))
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			var anak := (c as HBoxContainer).get_children()
			if not anak.is_empty() and anak[0] is Button and (anak[0] as Button).has_meta("ikon"):
				print("FOTO-CEK bar_ikon rect=%s size=%s" % [str(c.get_global_rect()), str(c.size)])
				for t in anak:
					print("FOTO-CEK strip %s rect=%s min=%s" % [str(ui._ikon_dari(t as Button).jenis), str((t as Button).get_global_rect()), str((t as Button).custom_minimum_size)])
	print("FOTO-CEK minimap rect=%s" % str(ui._minimap.get_global_rect()))
	print("FOTO-CEK mp_pill rect=%s min=%s" % [str(ui._mp_gabung_btn.get_global_rect()), str(ui._mp_gabung_btn.custom_minimum_size)])
	await _foto("strip-64-portrait.png")
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	SantriSave.save_data(_main._save)
	print("FOTO STRIP 64 SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
