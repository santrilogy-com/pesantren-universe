extends Node
## Re-shoot lampu pintu Kantor Putra (Cahya, 20 Nov 2026) — KOREKSI KAMERA.
## Probe pertama salah posisi: kamera (-18,12) & (-18,15.5) ternyata DI
## DALAM tapak Asrama Putra (x -33..-15, z 4..16) — kesalahan yang sama
## seperti foto pertama Gilang. Posisi benar: luar dari ujung timur celah,
## venue tepat di titik venue (-18,18.5) menghadap pintu.
## Sebelum/sesudah dalam SATU run: lampu baru disembunyikan (visible=false)
## untuk shot "sebelum", dinyalakan lagi untuk "sesudah".
## Jalankan TANPA --headless:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . skrip/foto_kantor_putra_lampu.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._masuk_pesantren("Re-shoot lampu Kantor Putra")
	for i in 3:
		await get_tree().process_frame
	if _main._kualitas != null:
		_main._kualitas.atur_mode("sedang")
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	LangitDinamis.debug_jam = 21.0
	for i in 10:
		await get_tree().process_frame
	var lampu := _main.find_child("LampuV2_PintuKantorPutra", true, false) as OmniLight3D
	if lampu == null:
		print("LAMPU KANTOR PUTRA: TIDAK KETEMU")
		get_tree().quit(1)
		return
	print("LAMPU KANTOR PUTRA: energi %.2f (range %.1f) di %s" % [lampu.light_energy, lampu.omni_range, str(lampu.global_position)])
	# --- SEBELUM: lampu disembunyikan ---
	lampu.visible = false
	for i in 10:
		await get_tree().process_frame
	await _foto("km-kantor-putra-luar-malam-sebelum.png", Vector3(-11, 2.5, 18), Vector3(-18, 2.0, 20.5))
	await _foto("km-kantor-putra-venue-malam-sebelum.png", Vector3(-18, 1.7, 18.5), Vector3(-18, 1.8, 20.0))
	# --- SESUDAH: lampu dinyalakan ---
	lampu.visible = true
	for i in 10:
		await get_tree().process_frame
	print("LAMPU KANTOR PUTRA SESUDAH: energi %.2f visible=%s" % [lampu.light_energy, str(lampu.visible)])
	await _foto("km-kantor-putra-luar-malam-sesudah.png", Vector3(-11, 2.5, 18), Vector3(-18, 2.0, 20.5))
	await _foto("km-kantor-putra-venue-malam-sesudah.png", Vector3(-18, 1.7, 18.5), Vector3(-18, 1.8, 20.0))
	LangitDinamis.debug_jam = -1.0
	print("RE-SHOOT LAMPU KANTOR PUTRA SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_main._set_interior_terlihat(false, false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	var mean := _mean_luminansi(img)
	print("UKUR %s jam=21 mean=%.1f (err=%s)" % [nama, mean, str(err)])


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
