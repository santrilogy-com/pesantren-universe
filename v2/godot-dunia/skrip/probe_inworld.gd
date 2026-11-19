extends Node
## Probe in-world SAJA (Eka, 18 Nov 2026) — diagnosis run foto yang
## macet di fase in-world (banjir SCRIPT ERROR global_position Nil
## + tidak pernah sampai W1-W3). TIDAK menyentuh foto studio.
##   xvfb-run godot --path . skrip/probe_inworld.tscn

func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	var packed := load("res://main.tscn") as PackedScene
	var main := packed.instantiate()
	add_child(main)
	print("PROBE main added t=%d ms" % (Time.get_ticks_msec() - t0))
	for i in 3:
		await get_tree().process_frame
	print("PROBE 3f t=%d player=%s rig=%s cam=%s" % [Time.get_ticks_msec() - t0, str(main._player), str(main._rig), str(main._cam)])
	main._masuk_pesantren("Probe in-world")
	for i in 3:
		await get_tree().process_frame
	print("PROBE masuk t=%d ms" % (Time.get_ticks_msec() - t0))
	var cam := Camera3D.new()
	cam.fov = 60.0
	add_child(cam)
	cam.current = true
	var player = main._player
	player.global_position = Vector3(0, 0, 20)
	player.velocity = Vector3.ZERO
	main._ui._joystick.output = Vector2(0, -1)
	for i in 18:
		await get_tree().process_frame
		if i % 6 == 0:
			print("PROBE jalan f=%d t=%d ppos=%s" % [i, Time.get_ticks_msec() - t0, str(player.global_position)])
	main._ui._joystick.output = Vector2.ZERO
	var p: Vector3 = player.global_position
	var yaw: float = player.get_facing_yaw()
	var depan := Vector3(sin(yaw), 0, cos(yaw))
	var kanan := Vector3(cos(yaw), 0, -sin(yaw))
	cam.global_position = p + depan * 3.2 + kanan * 1.4 + Vector3(0, 1.5, 0)
	cam.look_at(p + Vector3(0, 1.0, 0), Vector3.UP)
	for i in 6:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("/home/hatch/workspace/pesantren-verse/v2/foto-animasi-mixamo/W1-pemain-jalan.png")
	print("PROBE W1 save err=%s t=%d ms" % [str(err), Time.get_ticks_msec() - t0])
	print("PROBE SELESAI")
	get_tree().quit(0)
