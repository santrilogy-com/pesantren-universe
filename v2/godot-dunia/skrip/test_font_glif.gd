extends Node
## PROBE GLIF FONT (Tara, 19 Nov 2026) — penyelidikan teks Arab + ikon
## di panel. Dijalankan sebagai scene (pola test_ui_misi.tscn):
##   godot --headless --path . skrip/test_font_glif.tscn
## Membuktikan di dalam engine: glif apa yang ADA/TIDAK di tiap font
## proyek + apakah ada font sistem (fallback) di lingkungan ini.
## Di web TIDAK ada font sistem — jadi glif yang tidak ada di Baloo 2
## maupun Amiri = kotak/tofu di HP Mas.


func _ready() -> void:
	# TextServer 4.7 TIDAK punya get_system_fonts() — jumlah font sistem
	# tidak bisa ditanya dari engine; ketiadaan fallback dibuktikan
	# lewat foto namespace (tofu muncul) bukan lewat probe ini.
	var fonts := {
		"Baloo2-SemiBold.tres": load("res://fonts/Baloo2-SemiBold.tres") as Font,
		"Baloo2-Bold.tres": load("res://fonts/Baloo2-Bold.tres") as Font,
		"Amiri-Bold.ttf": load("res://fonts/Amiri-Bold.ttf") as Font,
		"Amiri-Regular.ttf": load("res://fonts/Amiri-Regular.ttf") as Font,
	}
	var cek := {
		"CHECK_2713": 0x2713, "CROSS_2717": 0x2717, "STAR_2605": 0x2605,
		"STARO_2606": 0x2606, "PLAY_25B6": 0x25B6, "LOCK_1F512": 0x1F512,
		"MULTX_2715": 0x2715, "SQUARE_25A1": 0x25A1, "BULLET_25CF": 0x25CF,
		"FULLPLUS_FF0B": 0xFF0B, "ARROW_203A": 0x203A, "MULT_00D7": 0x00D7,
		"BULLET_2022": 0x2022, "ALEF_0627": 0x0627, "QAF_0642": 0x0642,
		"FATHA_064E": 0x064E, "SHADDA_0651": 0x0651, "ARABQ_061F": 0x061F,
	}
	for nama in fonts:
		var f: Font = fonts[nama]
		if f == null:
			print("PROBE %s GAGAL_DIMUAT" % nama)
			continue
		var ada: Array = []
		var tidak: Array = []
		for k in cek:
			if f.has_char(cek[k]):
				ada.append(k)
			else:
				tidak.append(k)
		print("PROBE %s ADA=%s TIDAK=%s" % [nama, ada, tidak])
	var amiri_rt := load("res://fonts/Amiri-Bold.ttf")
	print("PROBE load_runtime_Amiri_Bold=%s" % str(amiri_rt != null))
	print("PROBE SELESAI")
	get_tree().quit(0)
