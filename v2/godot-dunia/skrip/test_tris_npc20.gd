extends Node
## Hitung tris + draw call (proxy MeshInstance3D) 20 NPC baru vs total
## scene — sekali jalan headless untuk laporan performa Raka.
##   HOME=/tmp/iso-tris godot --headless --path . --audio-driver Dummy --scene res://skrip/test_tris_npc20.tscn

func _tris_mesh(m: Mesh) -> int:
	if m == null:
		return 0
	var total := 0
	for s in range(m.get_surface_count()):
		var arr := m.surface_get_arrays(s)
		if arr.is_empty():
			continue
		var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
		if idx != null and idx.size() > 0:
			total += idx.size() / 3
		else:
			var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			if v != null:
				total += v.size() / 3
	return total


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var main: Node = packed.instantiate()
	add_child(main)
	for i in 3:
		await get_tree().process_frame
	main._save["ig_username"] = ""
	SantriSave.save_data(main._save)
	main._masuk_pesantren("Hitung Tris NPC20")
	for i in 5:
		await get_tree().process_frame
	var tris_baru := 0
	var mesh_baru := 0
	var npc_baru := 0
	for npc in main._npcs:
		if not bool(npc.get("_aktivitas_aktif")):
			continue
		npc_baru += 1
		var stack: Array[Node] = [npc._visual]
		while not stack.is_empty():
			var n: Node = stack.pop_back()
			if n is MeshInstance3D:
				mesh_baru += 1
				tris_baru += _tris_mesh((n as MeshInstance3D).mesh)
			for c in n.get_children():
				stack.append(c)
	# Total scene: semua MeshInstance3D di bawah main.
	var tris_total := 0
	var mesh_total := 0
	var stack2: Array[Node] = [main]
	while not stack2.is_empty():
		var n2: Node = stack2.pop_back()
		if n2 is MeshInstance3D:
			mesh_total += 1
			tris_total += _tris_mesh((n2 as MeshInstance3D).mesh)
		for c in n2.get_children():
			stack2.append(c)
	print("TRIS-NPC20: npc_baru=%d mesh_baru=%d tris_baru=%d (rata-rata %.0f tris/NPC)" % [npc_baru, mesh_baru, tris_baru, float(tris_baru) / float(maxi(npc_baru, 1))])
	print("TRIS-NPC20: scene mesh_total=%d tris_total=%d" % [mesh_total, tris_total])
	get_tree().quit(0)
