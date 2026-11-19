extends Node
## Profil v2 (Rangga, 19 Nov 2026): mesh terberat + label + lampu arah.
##   godot --headless --path . skrip/test_profil2.tscn

var _main: Node
var _top: Array = [] # [tris, path]
var _label_nama := {}
var _dir_nama: Array = []


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


func _hitung(n: Node, path: String) -> void:
	var p := path + "/" + String(n.name)
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var t := _tris_mesh((n as MeshInstance3D).mesh)
		_top.append([t, p])
	if n is Label3D:
		var k := String((n as Label3D).text).substr(0, 24)
		_label_nama[k] = int(_label_nama.get(k, 0)) + 1
	if n is DirectionalLight3D:
		_dir_nama.append(p)
	for ch in n.get_children():
		_hitung(ch, p)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Profil2")
	for i in 5:
		await get_tree().process_frame
	_hitung(_main, "")
	_top.sort_custom(func(a, b): return a[0] > b[0])
	print("PROFIL2: top 25 mesh by tris:")
	for i in mini(25, _top.size()):
		print("PROFIL2: %7d tris  %s" % [_top[i][0], _top[i][1]])
	print("PROFIL2: dir_lights=%s" % str(_dir_nama))
	print("PROFIL2: label3d distinct=%d" % _label_nama.size())
	var items: Array = []
	for k in _label_nama:
		items.append([int(_label_nama[k]), k])
	items.sort_custom(func(a, b): return a[0] > b[0])
	for i in mini(15, items.size()):
		print("PROFIL2: label x%d %s" % [items[i][0], items[i][1]])
	get_tree().quit()
