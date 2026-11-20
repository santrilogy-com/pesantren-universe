extends Node
## Diagnosa juntai via jalur NPC (sama seperti test_pose_kursi).

func _ready() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#efe9dc")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff6e6")
	env.ambient_light_energy = 0.75
	env_node.environment = env
	add_child(env_node)
	var lantai_fisik := StaticBody3D.new()
	var bentuk := CollisionShape3D.new()
	var kotak := BoxShape3D.new()
	kotak.size = Vector3(60, 1, 60)
	bentuk.shape = kotak
	bentuk.position = Vector3(0, -0.5, 0)
	lantai_fisik.add_child(bentuk)
	add_child(lantai_fisik)
	var bangku: Dictionary = {}
	for k in SantriNPC.KURSI_LUAR:
		if String(k["jenis"]) == "kursi":
			bangku = k
			break
	print("BANGKU %s" % str(bangku))
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("Hasan", Vector3.ZERO, [], MissionData.OUTFIT_DEFAULT, false)
	npc.set_process(false)
	npc.position = Vector3(bangku["pos"].x, 0.0, bangku["pos"].z)
	npc._aktivitas = "duduk"
	npc._aktivitas_kursi = bangku
	npc._aktivitas_yaw = float(bangku["yaw"])
	npc._aktivitas_timer = 60.0
	for i in 3:
		npc._proses_aktivitas(1.0)
	print("JUNTAI npc._juntai=%s scale=%s visible=%s" % [str(npc._juntai), str(npc._juntai.scale), str(npc._juntai.visible)])
	print("JUNTAI get_aabb=%s" % str(npc._juntai.get_aabb()))
	print("JUNTAI mesh=%s class=%s" % [str(npc._juntai.mesh), npc._juntai.mesh.get_class() if npc._juntai.mesh != null else "null"])
	print("JUNTAI mesh_aabb=%s" % str(npc._juntai.mesh.get_aabb()))
	print("KNEE global_y=%.3f SANDAL global=%s" % [npc._knee_l.global_position.y, str((npc._visual.find_child("SandalKiri", true, false) as Node3D).global_position)])
	print("CEK1 hem<=lutut-0.28: %.3f <= %.3f = %s" % [npc._juntai.get_aabb().position.y, npc._knee_l.global_position.y - 0.28 + 0.01, str(npc._juntai.get_aabb().position.y <= npc._knee_l.global_position.y - 0.28 + 0.01)])
	print("CEK2 hem>sandal-0.02: %.3f > %.3f = %s" % [npc._juntai.get_aabb().position.y, (npc._visual.find_child("SandalKiri", true, false) as Node3D).global_position.y - 0.02, str(npc._juntai.get_aabb().position.y > (npc._visual.find_child("SandalKiri", true, false) as Node3D).global_position.y - 0.02)])
	print("UKUR SELESAI")
	get_tree().quit(0)
