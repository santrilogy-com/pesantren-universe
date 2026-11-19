extends Node
## Probe akar potong pill AKTIF (Tara, 19 Nov 2026 — lanjutan Panel Misi v2):
## chip buat_chip_isi() pakai StyleBoxTexture 9-slice radius 24 pada
## chip setinggi ~25 px (margin atas+bawah 48 > tinggi chip).
## Probe: (A) chip natural, (B) chip sama dipaksa tinggi 50 px,
## (C) replika baris aktif persis panel_misi_ui.gd. Cetak ukuran +
## simpan PNG + crop zoom tiap chip.
##   DISPLAY=:95 godot --path . skrip/probe_chip_aktif.tscn --resolution 1280x720

const OUT_DIR := "/home/hatch/workspace/.logs-gate-18nov/ikon-panel-19nov/"

var _crops := {}


func _crop(nama: String, rect: Rect2i) -> void:
	var img := get_viewport().get_texture().get_image()
	var c := img.get_region(rect)
	var err := c.save_png(OUT_DIR + nama)
	print("CROP %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# (A) chip natural, posisi tetap.
	var chip_a := GayaMisi.buat_chip_isi("AKTIF")
	chip_a.position = Vector2(100, 80)
	root.add_child(chip_a)
	_crops["probe-chip-a-natural.png"] = Rect2i(80, 60, 220, 90)

	# (B) chip sama, dipaksa tinggi 50 px (>= 2x radius 24).
	var chip_b := GayaMisi.buat_chip_isi("AKTIF")
	chip_b.position = Vector2(100, 200)
	chip_b.custom_minimum_size = Vector2(0, 50)
	root.add_child(chip_b)
	_crops["probe-chip-b-tinggi50.png"] = Rect2i(80, 180, 220, 110)

	# (C) replika baris aktif: Button kartu-aktif + HBox isi panel.
	var tombol := Button.new()
	tombol.add_theme_stylebox_override("normal", GayaMisi.gaya_kartu_aktif_gradien())
	tombol.position = Vector2(100, 360)
	tombol.size = Vector2(620, 42)
	tombol.clip_contents = false
	root.add_child(tombol)
	var isi := HBoxContainer.new()
	isi.add_theme_constant_override("separation", 10)
	isi.anchor_right = 1.0
	isi.anchor_bottom = 1.0
	isi.offset_left = 16
	isi.offset_top = 8
	isi.offset_right = -16
	isi.offset_bottom = -8
	tombol.add_child(isi)
	var ikon := Control.new()
	ikon.custom_minimum_size = Vector2(22, 22)
	ikon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	isi.add_child(ikon)
	var l_id := GayaMisi.buat_label("N1.2", 18, GayaMisi.EMAS_TERANG)
	l_id.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	isi.add_child(l_id)
	var judul := GayaMisi.buat_label("Isim", 18, GayaMisi.KREM)
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	judul.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	isi.add_child(judul)
	var chip_c := GayaMisi.buat_chip_isi("AKTIF")
	isi.add_child(chip_c)
	var poin := GayaMisi.buat_label("+10 poin", 16, GayaMisi.KREM)
	poin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	isi.add_child(poin)
	_crops["probe-chip-c-baris.png"] = Rect2i(80, 340, 680, 90)

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var label := chip_a.get_child(0) as Label
	print("PROBE chip min=%s label min=%s font_height=%s" % [str(chip_a.get_minimum_size()), str(label.get_minimum_size()), str(label.get_theme_font("font").get_height(12))])
	print("PROBE A size=%s B size=%s C chip size=%s isi size=%s tombol size=%s" % [str(chip_a.size), str(chip_b.size), str(chip_c.size), str(isi.size), str(tombol.size)])
	var img := get_viewport().get_texture().get_image()
	print("PROBE full err=%s" % str(img.save_png(OUT_DIR + "probe-chip-aktif.png")))
	for nama in _crops:
		_crop(nama, _crops[nama])
	print("PROBE selesai")
	get_tree().quit(0)
