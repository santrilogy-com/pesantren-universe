extends Node
## Probe "kantor madrasah gelap" (Cahya, 20 Nov 2026) — SESUDAH perbaikan.
## Ukur luminansi rata-rata viewport + simpan foto, siang (12:00) & malam (21:00):
##   M1/M2 interior Madrasah | K1/K2 interior Kantor Ustadzah (pembanding,
##   pola builder sama) | U1/U2 interior Musholla (pembanding, Mas ACC terang)
##   P1/P2/P3 eksterior Kantor Putra + venue tes (tanpa interior) | D1 fasad
##   Madrasah putri malam (lampu pintu Fase 2).
## Jalankan TANPA --headless (save_png null di headless):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . skrip/foto_kantor_madrasah_gelap.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Bersihkan frame: pop-up "PETUNJUK TOMBOL" pemain baru menutupi
	# tengah layar (flag save) + pin kualitas "sedang" supaya
	# pengali_lampu = 1,0 (pola test_pencahayaan — tanpa pin, probe
	# FPS Xvfb 7,5 menurunkan tingkat ke Ringan 0,6x dan semua energi
	# lampu terukur 0,6x).
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._masuk_pesantren("Probe kantor madrasah gelap")
	for i in 3:
		await get_tree().process_frame
	if _main._kualitas != null:
		_main._kualitas.atur_mode("sedang")
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Energi lampu kunci (bukti kode -> angka nyata), siang & malam.
	_energi_lampu("SIANG")
	LangitDinamis.debug_jam = 12.0
	for i in 10:
		await get_tree().process_frame
	_energi_lampu("SIANG-12")
	# --- SIANG 12:00 ---
	await _foto("km-madrasah-interior-siang-sesudah.png", Vector3(-183.5, 1.7, -297.5), Vector3(-179.0, 1.2, -302.5), 12.0, "madrasah")
	await _foto("km-kantor-interior-siang-sesudah.png", Vector3(-122.5, 1.7, -297.5), Vector3(-117.5, 1.2, -301.5), 12.0, "kantor")
	await _foto("km-musholla-interior-siang-sesudah.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 12.0, "musholla")
	await _foto("km-kantor-putra-luar-siang-sesudah.png", Vector3(-18, 2.5, 12), Vector3(-18, 2.0, 22.5), 12.0, "")
	# --- MALAM 21:00 ---
	LangitDinamis.debug_jam = 21.0
	for i in 10:
		await get_tree().process_frame
	_energi_lampu("MALAM-21")
	await _foto("km-madrasah-interior-malam-sesudah.png", Vector3(-183.5, 1.7, -297.5), Vector3(-179.0, 1.2, -302.5), 21.0, "madrasah")
	await _foto("km-kantor-interior-malam-sesudah.png", Vector3(-122.5, 1.7, -297.5), Vector3(-117.5, 1.2, -301.5), 21.0, "kantor")
	await _foto("km-musholla-interior-malam-sesudah.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 21.0, "musholla")
	await _foto("km-kantor-putra-luar-malam-sesudah.png", Vector3(-18, 2.5, 12), Vector3(-18, 2.0, 22.5), 21.0, "")
	await _foto("km-kantor-putra-venue-malam-sesudah.png", Vector3(-18, 1.7, 15.5), Vector3(-18, 1.5, 20.0), 21.0, "")
	await _foto("km-madrasah-luar-malam-sesudah.png", Vector3(140, 2.5, -2), Vector3(152, 2.0, -12), 21.0, "")
	LangitDinamis.debug_jam = -1.0
	print("PROBE KANTOR MADRASAH SESUDAH SELESAI")
	get_tree().quit(0)


func _energi_lampu(tag: String) -> void:
	for nama in ["LampuMadrasah", "LampuKantor", "LampuOmni_1", "LampuV2_PintuMadrasah", "LampuV2_PintuKantorUstadzah"]:
		var n := _main.find_child(nama, true, false)
		if n == null:
			print("ENERGI %s %s: TIDAK KETEMU" % [tag, nama])
			continue
		var omni := n as OmniLight3D
		if omni == null:
			var c := (n as Node).find_child("Cahaya", true, false) as OmniLight3D
			if c != null:
				print("ENERGI %s %s/Cahaya: %.2f (range %.1f)" % [tag, nama, c.light_energy, c.omni_range])
			else:
				print("ENERGI %s %s: bukan omni" % [tag, nama])
		else:
			print("ENERGI %s %s: %.2f (range %.1f)" % [tag, nama, omni.light_energy, omni.omni_range])


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float, interior: String) -> void:
	LangitDinamis.debug_jam = jam
	match interior:
		"madrasah":
			_main._set_interior_terlihat(false, false, false, false, false, false, true)
		"kantor":
			_main._set_interior_terlihat(false, false, false, false, false, true)
		"musholla":
			_main._set_interior_terlihat(false, false, true)
		_:
			_main._set_interior_terlihat(false, false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	var mean := _mean_luminansi(img)
	print("UKUR %s jam=%.0f mean=%.1f (err=%s)" % [nama, jam, mean, str(err)])


func _mean_luminansi(img: Image) -> float:
	var w := img.get_width()
	var h := img.get_height()
	var total := 0.0
	var n := 0
	for y in range(0, h, 8):
		for x in range(0, w, 8):
			var c := img.get_pixel(x, y)
			total += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			n += 1
	return total / float(maxi(n, 1)) * 255.0
