extends Node
## Ukur lebar Label3D plakat (Nadia, 18 Nov 2026 — sizing P6, bukan tebak-tebakan).
## Jalankan headless: godot --headless --path . skrip/ukur_label_plakat.tscn
## get_aabb().size.x = lebar teks (palette.gd: AABB Label3D berkubus sisi=lebar).

func _ready() -> void:
	var teks: Array = ["ASRAMA PUTRI", "KELAS PUTRI", "KANTOR USTADZAH", "MADRASAH", "STUDIO"]
	for t in teks:
		for fs in [20, 28, 32, 36, 40]:
			var f: Font = Palette.FONT_GAME
			var w: float = f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.01
			var h: float = float(f.get_height(fs)) * 0.01
			print("UKUR label='%s' font=%d lebar=%.2f tinggi_font=%.2f" % [t, fs, w, h])
	for fs in [36, 44, 48]:
		var f: Font = Palette.FONT_ARAB
		var w: float = f.get_string_size("مصلى الروضة", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.01
		print("UKUR arab font=%d lebar=%.2f tinggi_font=%.2f" % [fs, w, float(f.get_height(fs)) * 0.01])
	print("UKUR SELESAI")
	get_tree().quit(0)
