extends SceneTree
## Dump material tiap MeshInstance3D di surau-v2.glb:
## nama node, nama material, ada/tidaknya albedo texture, warna albedo.
## Jalankan: godot --headless --path . --script skrip/dump_material_surau.gd
## (SceneTree script: pakai --script, bukan .tscn.)

func _init() -> void:
	var packed := load("res://models/surau-v2.glb") as PackedScene
	if packed == null:
		print("DUMP MATERIAL GAGAL: GLB tidak termuat")
		quit(1)
		return
	var inst := packed.instantiate() as Node3D
	_dump(inst, "")
	print("DUMP MATERIAL SELESAI")
	quit(0)


func _dump(n: Node, indent: String) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var mat: Material = mi.material_override
		if mat == null and mi.mesh != null:
			mat = mi.mesh.surface_get_material(0)
		var info := "TANPA MATERIAL"
		if mat is StandardMaterial3D:
			var sm := mat as StandardMaterial3D
			var tex := "tanpa-tekstur"
			if sm.albedo_texture != null:
				tex = "TEKSTUR:" + str(sm.albedo_texture.resource_path)
			info = "mat=%s albedo=%s rough=%.2f metal=%.2f %s" % [
				"GLB:" + str(sm.resource_name) if sm.resource_name != "" else "(tanpa-nama)",
				str(sm.albedo_color.to_html()), sm.roughness, sm.metallic, tex]
		elif mat != null:
			info = "mat-klas=" + mat.get_class()
		print(indent + String(n.name) + " [" + n.get_class() + "] " + info)
	for ch in n.get_children():
		_dump(ch, indent + "  ")
