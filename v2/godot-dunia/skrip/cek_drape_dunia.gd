extends Node
## Diagnostik sementara (Kirana, v6): di mana alas drape bersila
## berada di DUNIA saat NPC bersila — apakah cincin bawahnya
## terkubur di bawah lantai (visual y = -0.42)?

func _ready() -> void:
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("Tes", Vector3(0, 0, 0), [], MissionData.OUTFIT_DEFAULT, false, {}, true, true)
	npc.set_process(false)
	for i in 10:
		await get_tree().process_frame
	npc._terapkan_duduk_baca(1.0)
	for i in 25:
		await get_tree().process_frame
	var vis: Node3D = npc._visual
	print("DUNIA visual_y=%.3f rot_x=%.3f node_y=%.3f" % [vis.position.y, vis.rotation.x, npc.position.y])
	var drape: MeshInstance3D = npc._drape
	print("DUNIA drape_scale=%s visible=%s" % [str(drape.scale), str(drape.visible)])
	var mesh: ArrayMesh = drape.mesh as ArrayMesh
	print("DUNIA drape AABB lokal=%s" % str(mesh.get_aabb()))
	print("DUNIA drape AABB global=%s" % str(drape.get_aabb()))
	var arr: Array = mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ymin := 999.0
	var ymax := -999.0
	for v in verts:
		var g: Vector3 = drape.to_global(v)
		ymin = minf(ymin, g.y)
		ymax = maxf(ymax, g.y)
	print("DUNIA drape verteks global y: min=%.3f max=%.3f (lantai y=0)" % [ymin, ymax])
	# Verteks dengan |x| terbesar (lutut) — posisi globalnya.
	var xl := 0.0
	var xl_v := Vector3.ZERO
	for v in verts:
		var g: Vector3 = drape.to_global(v)
		if absf(g.x) > xl:
			xl = absf(g.x)
			xl_v = g
	print("DUNIA verteks |x| terbesar: x=%.3f global=%s" % [xl, str(xl_v)])
	# Verteks paling depan (z terbesar).
	var zf := -999.0
	var zf_v := Vector3.ZERO
	for v in verts:
		var g: Vector3 = drape.to_global(v)
		if g.z > zf:
			zf = g.z
			zf_v = g
	print("DUNIA verteks z terbesar: z=%.3f global=%s" % [zf, str(zf_v)])
	get_tree().quit(0)
