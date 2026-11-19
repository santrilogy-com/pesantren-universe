extends Node
## Lembar verifikasi ikon panel (Tara, 19 Nov 2026): gambar SEMUA jenis
## IkonHUD baru dalam satu tangkapan — bukti visual langsung bahwa
## "bintang_kosong" benar-benar kosong (garis tipis) dan "silang"
## terender (tidak pernah muncul di foto panel karena semua jawaban
## tes di skrip foto benar). Ikon digambar kode — tampilannya sama
## dengan/tanpa font sistem, tapi tetap dijalankan mode web supaya
## buktinya setara foto panel lain.
##   DISPLAY=:95 godot --path . --resolution 1280x720 skrip/foto_ikon_sheet.tscn -- --tag=web

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _tag := "normal"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tag="):
			_tag = arg.trim_prefix("--tag=")
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	var latar := ColorRect.new()
	latar.color = Color("043b2c")
	latar.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(latar)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.position = Vector2(40, 30)
	add_child(v)
	var judul := Label.new()
	judul.text = "LEMBAR IKON PANEL (kiri 20px = ukuran panel, kanan 40px)"
	judul.add_theme_font_size_override("font_size", 24)
	judul.add_theme_color_override("font_color", Color("f2ead6"))
	v.add_child(judul)
	var jenis := ["centang", "silang", "gembok", "segitiga_isi", "bintang", "bintang_kosong", "x", "kotak"]
	for j in jenis:
		var baris := HBoxContainer.new()
		baris.add_theme_constant_override("separation", 16)
		v.add_child(baris)
		for ukuran in [20, 40]:
			var ikon := IkonHUD.new()
			ikon.jenis = j
			ikon.warna = Color("f2c14e")
			ikon.bayangan = false
			ikon.custom_minimum_size = Vector2(ukuran, ukuran)
			baris.add_child(ikon)
		var nama := Label.new()
		nama.text = j
		nama.add_theme_font_size_override("font_size", 22)
		nama.add_theme_color_override("font_color", Color("f2ead6"))
		nama.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		baris.add_child(nama)
	for i in 10:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "ikon-sheet-%s.png" % _tag)
	print("FOTO ikon-sheet-%s.png (err=%s)" % [_tag, str(err)])
	get_tree().quit()
