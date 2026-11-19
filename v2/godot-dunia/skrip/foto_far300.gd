extends Node
## Foto verifikasi far (Rangga, 19 Nov 2026) — bandingkan far=300
## (nilai baru di main.gd) vs far=4000 (nilai lama), pose + jam SAMA:
##   xvfb-run -a ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_far300.tscn
## 1. SIANG (jam 12) dari spawn menghadap gunung 1 (160°, 350 m).
## 2. MALAM menghadap bulan (jam dipilih: elevasi bulan ~12° supaya
##    nyaman di frame): bulan 380 m + bintang 360 m.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-performa/"

var _main: Node


func _foto(nama: String) -> void:
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s err=%s" % [nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto far300")
	for i in 3:
		await get_tree().process_frame
	var root_pesantren: Node = _main._pesantren["root"]
	var langit: Node = root_pesantren.find_child("LangitDinamis", true, false)
	var g0 := root_pesantren.find_child("Gunung_0", true, false) as Node3D
	var g1 := root_pesantren.find_child("Gunung_1", true, false) as Node3D
	print("FOTO cam=%s far=%.0f" % [str(_main._cam.global_position), _main._cam.far])
	if g0 != null:
		print("FOTO Gunung_0 pos=%s jarak_ke_cam=%.0f" % [str(g0.global_position), g0.global_position.distance_to(_main._cam.global_position)])
	if g1 != null:
		print("FOTO Gunung_1 pos=%s jarak_ke_cam=%.0f" % [str(g1.global_position), g1.global_position.distance_to(_main._cam.global_position)])
	# 1 — SIANG, gunung 1, far 300 lalu far 4000 (pose sama).
	var yaw_gunung := atan2(119.7 - (-4.0), 328.9 - 14.0)
	LangitDinamis.debug_jam = 12.0
	for i in 5:
		await get_tree().process_frame
	_main._teleport_player(Vector3(-4, 0, 14), yaw_gunung)
	await _foto("gunung-siang-far300.png")
	_main._cam.far = 4000.0
	await _foto("gunung-siang-far4000.png")
	_main._cam.far = 300.0
	# 2 — MALAM: cari jam dengan elevasi bulan ~12°.
	var bulan := langit.get_node_or_null("Bulan") as Node3D
	var jam_bulan := 21.0
	var skor_terbaik := 999.0
	for jam in [18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 0.0, 1.0, 2.0, 3.0]:
		LangitDinamis.debug_jam = jam
		for i in 5:
			await get_tree().process_frame
		if bulan == null:
			continue
		var elev := rad_to_deg(asin(clampf(bulan.global_position.y / 380.0, -1.0, 1.0)))
		var skor := absf(elev - 12.0)
		if elev > 5.0 and skor < skor_terbaik:
			skor_terbaik = skor
			jam_bulan = jam
	LangitDinamis.debug_jam = jam_bulan
	for i in 5:
		await get_tree().process_frame
	var arah_b: Vector3 = bulan.global_position - _main._cam.global_position
	var yaw_bulan := atan2(arah_b.x, arah_b.z)
	var elev_bulan := rad_to_deg(asin(clampf(bulan.global_position.y / 380.0, -1.0, 1.0)))
	print("FOTO malam jam=%.1f elev_bulan=%.1f jarak_bulan=%.0f" % [jam_bulan, elev_bulan, bulan.global_position.distance_to(_main._cam.global_position)])
	_main._teleport_player(Vector3(-4, 0, 14), yaw_bulan)
	await _foto("bulan-malam-far300.png")
	_main._cam.far = 4000.0
	await _foto("bulan-malam-far4000.png")
	_main._cam.far = 300.0
	LangitDinamis.debug_jam = -1.0
	print("FOTO FAR300 SELESAI")
	get_tree().quit(0)
