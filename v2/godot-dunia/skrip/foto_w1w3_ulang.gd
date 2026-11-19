extends Node
## Retake W1 + W3 BURST (Eka, 18 Nov 2026) — in-world saja.
## W1/W3 pertama pose jalan TIDAK TERBACA (kaki rapat — foto
## diambil 6 frame setelah joystick lepas / fase acak saat kaki
## berpapasan). Di sini 6 kandidat per foto diambil SELAGI karakter
## berjalan, kamera diposisikan ulang tiap frame; fase ayun maju
## ~2,8 rad/frame di bawah xvfb, jadi dari 6 frame pasti ada yang
## dekat ayunan maks. Eka pilih manual kandidat terbaik lalu
## cp ke W1-pemain-jalan.png / W3-npc-jalan.png.
##   xvfb-run godot --path . skrip/foto_w1w3_ulang.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-animasi-mixamo/"


func _jepret(cam: Camera3D, nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	cam.global_position = pos_kamera
	cam.look_at(target, Vector3.UP)
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("BURST %s err=%s" % [nama, str(err)])


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var main := packed.instantiate()
	add_child(main)
	for i in 3:
		await get_tree().process_frame
	main._masuk_pesantren("Foto ulang W1 W3")
	for i in 3:
		await get_tree().process_frame
	var cam := Camera3D.new()
	cam.fov = 60.0
	add_child(cam)
	cam.current = true
	# ---------- W1 burst: pemain jalan (joystick TETAP aktif) ----------
	var player = main._player
	player.global_position = Vector3(0, 0, 20)
	player.velocity = Vector3.ZERO
	main._ui._joystick.output = Vector2(0, -1)
	for i in 6:
		await get_tree().process_frame
		var p: Vector3 = player.global_position
		var yaw: float = player.get_facing_yaw()
		var depan := Vector3(sin(yaw), 0, cos(yaw))
		var kanan := Vector3(cos(yaw), 0, -sin(yaw))
		print("BURST W1 f=%d kaki_l=%.2f p=%s" % [i, player._leg_l.rotation.x, str(p)])
		await _jepret(cam, "W1-coba-%d.png" % i, p + depan * 3.2 + kanan * 1.4 + Vector3(0, 1.5, 0), p + Vector3(0, 1.0, 0))
	main._ui._joystick.output = Vector2.ZERO
	# ---------- W3 burst: NPC jalan ----------
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("TesFoto", Vector3(0, 0, 30), [Vector3(10, 0, 30), Vector3(-10, 0, 30)], MissionData.OUTFIT_DEFAULT)
	for i in 3:
		await get_tree().process_frame
	npc._pause_timer = 0.0
	npc._target = Vector3(10, 0, 30)
	for i in 6:
		await get_tree().process_frame
		var np: Vector3 = npc.position
		var nyaw: float = (npc._visual as Node3D).rotation.y
		var ndepan := Vector3(sin(nyaw), 0, cos(nyaw))
		var nkanan := Vector3(cos(nyaw), 0, -sin(nyaw))
		print("BURST W3 f=%d kaki_l=%.2f p=%s" % [i, npc._leg_l.rotation.x, str(np)])
		await _jepret(cam, "W3-coba-%d.png" % i, np + ndepan * 3.0 + nkanan * 1.2 + Vector3(0, 1.5, 0), np + Vector3(0, 1.0, 0))
	print("BURST SELESAI")
	get_tree().quit(0)
