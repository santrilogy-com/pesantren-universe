extends Node
## Profil v3 (Rangga, 19 Nov 2026): agregasi tris per kelas mesh.
##   godot --headless --path . skrip/test_profil3.tscn

var _main: Node
var _agg := {} # class -> [instances, tris]
var _sphere_seg := {} # "radial x rings" -> count


func _tris_mesh(m: Mesh) -> int:
	var t := 0
	for s in m.get_surface_count():
		var arr := m.surface_get_arrays(s)
		if arr.is_empty():
			continue
		var idx = arr[Mesh.ARRAY_INDEX]
		if idx != null:
			t += (idx as PackedInt32Array).size() / 3
		else:
			var v = arr[Mesh.ARRAY_VERTEX]
			if v != null:
				t += (v as PackedVector3Array).size() / 3
	return t


func _hitung(n: Node) -> void:
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var m := (n as MeshInstance3D).mesh
		var cls := m.get_class()
		var t := _tris_mesh(m)
		var e: Array = _agg.get(cls, [0, 0])
		e[0] += 1
		e[1] += t
		_agg[cls] = e
		if m is SphereMesh:
			var sm := m as SphereMesh
			var k := "%dx%d" % [sm.radial_segments, sm.rings]
			_sphere_seg[k] = int(_sphere_seg.get(k, 0)) + 1
		if m is CylinderMesh:
			var cm := m as CylinderMesh
			var k := "cyl_r%d" % cm.radial_segments
			_sphere_seg[k] = int(_sphere_seg.get(k, 0)) + 1
	for ch in n.get_children():
		_hitung(ch)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Profil3")
	for i in 5:
		await get_tree().process_frame
	_hitung(_main)
	print("PROFIL3: tris per kelas mesh:")
	var items: Array = []
	for k in _agg:
		items.append([int(_agg[k][1]), k, int(_agg[k][0])])
	items.sort_custom(func(a, b): return a[0] > b[0])
	for it in items:
		print("PROFIL3: %8d tris  %5d inst  %s" % [it[0], it[2], it[1]])
	print("PROFIL3: segmen sphere/cylinder:")
	var sitems: Array = []
	for k in _sphere_seg:
		sitems.append([int(_sphere_seg[k]), k])
	sitems.sort_custom(func(a, b): return a[0] > b[0])
	for it in sitems:
		print("PROFIL3: %5d inst  %s" % [it[0], it[1]])
	get_tree().quit()
