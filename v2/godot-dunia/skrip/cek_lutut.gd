extends Node
## Diagnosa posisi lutut/betis/sandal di pose duduk + duduk_kursi (Kirana).

func _tunggu(n: int) -> void:
	for i in n:
		await get_tree().process_frame

func _laporkan(tag: String, p: SantriPlayer) -> void:
	var vis: Node3D = p._visual
	var vl: Node3D = p._leg_l
	var vr: Node3D = p._leg_r
	var kl: Node3D = p._knee_l
	var kr: Node3D = p._knee_r
	var sand_l: Node3D = vis.find_child("SandalKiri", true, false)
	var sand_r: Node3D = vis.find_child("SandalKanan", true, false)
	# posisi lokal relatif visual (visual bisa condong): pakai to_local
	var to_loc := func(gp: Vector3) -> Vector3: return vis.to_local(gp)
	print("UKUR %s: visual_y=%.3f rot_x=%.2f" % [tag, vis.position.y, vis.rotation.x])
	print("UKUR %s: lutut_L lok=%s dunia=%s | lutut_R lok=%s dunia=%s" % [tag, str(to_loc.call(kl.global_position)), str(kl.global_position), str(to_loc.call(kr.global_position)), str(kr.global_position)])
	print("UKUR %s: sandal_L lok=%s dunia=%s | sandal_R lok=%s dunia=%s" % [tag, str(to_loc.call(sand_l.global_position)), str(sand_l.global_position), str(to_loc.call(sand_r.global_position)), str(sand_r.global_position)])
	var drape: MeshInstance3D = p._drape
	print("UKUR %s: drape scale=%s visible=%s aabb=%s" % [tag, str(drape.scale), str(drape.visible), str((drape.mesh as ArrayMesh).get_aabb())])
	var juntai: MeshInstance3D = p._juntai
	print("UKUR %s: juntai scale=%s visible=%s aabb_lokal=%s" % [tag, str(juntai.scale), str(juntai.visible), str(juntai.get_aabb())])

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
	var p := SantriPlayer.new()
	var cs := CollisionShape3D.new()
	var kap := CapsuleShape3D.new()
	kap.radius = 0.35
	kap.height = 1.7
	cs.shape = kap
	cs.position = Vector3(0, 0.85, 0)
	p.add_child(cs)
	p.position = Vector3(0, 0, 0)
	add_child(p)
	await _tunggu(10)
	p.set_aksi("duduk")
	await _tunggu(90)
	_laporkan("DUDUK", p)
	p.set_aksi("duduk_kursi")
	p._kursi_tinggi_duduk = 0.45
	await _tunggu(90)
	_laporkan("KURSI-0.45", p)
	print("UKUR SELESAI")
	get_tree().quit(0)
