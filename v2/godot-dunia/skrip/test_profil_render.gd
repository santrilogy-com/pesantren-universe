extends Node
## Profil render (Eka, gate 20261119-4): ukur mesh/tris/surface yang
## BENAR-BENAR ter-render dari kamera pemain (frustum + visible),
## bukan total scene — test_profil menghitung semua mesh termasuk
## interior tersembunyi z=-300. Headless, tanpa input.
##   godot --headless --path . skrip/test_profil_render.tscn

var _main: Node


func _tris_mesh(m: Mesh) -> Array:
	var v := 0
	var t := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		if arr.is_empty():
			continue
		var vv = arr[Mesh.ARRAY_VERTEX]
		if vv != null:
			v += (vv as PackedVector3Array).size()
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx != null:
			t += (idx as PackedInt32Array).size() / 3
		elif vv != null:
			t += (vv as PackedVector3Array).size() / 3
	return [v, t, m.get_surface_count()]


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("ProfilRender")
	for i in 5:
		await get_tree().process_frame
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		print("PROFIL-RENDER: KAMERA TIDAK ADA")
		get_tree().quit(1)
		return
	print("PROFIL-RENDER: kamera pos=%s far=%.1f fov=%.1f" % [str(cam.global_position), cam.far, cam.fov])
	var t_mesh := 0
	var t_tris := 0
	var t_surf := 0
	var t_verts := 0
	var v_mesh := 0
	var v_tris := 0
	var v_surf := 0
	var v_verts := 0
	var npc_total := 0
	var npc_vis := 0
	var stack: Array[Node] = [_main]
	while not stack.is_empty():
		var nd: Node = stack.pop_back()
		if nd is MeshInstance3D:
			var mi := nd as MeshInstance3D
			var m := mi.mesh
			if m != null:
				var r := _tris_mesh(m)
				t_mesh += 1
				t_verts += r[0]
				t_tris += r[1]
				t_surf += r[2]
				# Ter-render = visible + (pusat ATAU salah satu sudut AABB
				# di dalam frustum). get_frustum() + Plane.distance_to
				# SALAH tanda di percobaan pertama (TER-RENDER=1) —
				# is_position_in_frustum() yang dipakai di sini.
				if mi.is_visible_in_tree():
					var ga: AABB = mi.get_aabb()
					var sudut := [
						ga.position,
						ga.position + Vector3(ga.size.x, 0, 0),
						ga.position + Vector3(0, ga.size.y, 0),
						ga.position + Vector3(0, 0, ga.size.z),
						ga.position + Vector3(ga.size.x, ga.size.y, 0),
						ga.position + Vector3(ga.size.x, 0, ga.size.z),
						ga.position + Vector3(0, ga.size.y, ga.size.z),
						ga.position + ga.size,
					]
					var terlihat := false
					for s in sudut:
						if cam.is_position_in_frustum(mi.to_global(s)):
							terlihat = true
							break
					if not terlihat and cam.is_position_in_frustum(mi.to_global(ga.get_center())):
						terlihat = true
					if terlihat:
						v_mesh += 1
						v_verts += r[0]
						v_tris += r[1]
						v_surf += r[2]
		if nd.get_script() != null and String(nd.get_script().resource_path).ends_with("npc.gd"):
			npc_total += 1
			if nd is Node3D and (nd as Node3D).is_visible_in_tree():
				if cam.is_position_in_frustum((nd as Node3D).global_position):
					npc_vis += 1
		for ch in nd.get_children():
			stack.append(ch)
	print("PROFIL-RENDER: total mesh=%d tris~%d surfaces=%d verts=%d" % [t_mesh, t_tris, t_surf, t_verts])
	print("PROFIL-RENDER: TER-RENDER mesh=%d tris~%d surfaces~drawcall=%d verts=%d" % [v_mesh, v_tris, v_surf, v_verts])
	print("PROFIL-RENDER: npc total=%d npc_dalam_frustum=%d" % [npc_total, npc_vis])
	get_tree().quit()
