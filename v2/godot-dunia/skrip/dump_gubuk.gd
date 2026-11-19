extends Node
## Dump isi GLB gubuk-santri yang DIMUAT Godot (Dewa, 17 Nov 2026):
##   godot --headless --path . skrip/dump_gubuk.tscn
## Cetak nama node + posisi + rotasi tiap Node3D + material kaca.

func _dump(n: Node, indent: String) -> void:
	var extra := ""
	if n is Node3D:
		var t := n as Node3D
		extra = " pos=(%.2f, %.2f, %.2f) rotY=%.1f" % [t.position.x, t.position.y, t.position.z, rad_to_deg(t.rotation.y)]
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var mesh := mi.mesh
		if mesh != null:
			for si in mesh.get_surface_count():
				var mat := mesh.surface_get_material(si)
				if mat is StandardMaterial3D:
					var sm := mat as StandardMaterial3D
					extra += " [mat albedo=%s alpha=%.2f transp=%d]" % [str(sm.albedo_color), sm.albedo_color.a, sm.transparency]
	print(indent + String(n.name) + " [" + n.get_class() + "]" + extra)
	for ch in n.get_children():
		_dump(ch, indent + "  ")


func _ready() -> void:
	var packed := load("res://models/gubuk-santri.glb") as PackedScene
	if packed == null:
		print("DUMP GAGAL: GLB tidak termuat")
		get_tree().quit(1)
		return
	var inst := packed.instantiate() as Node3D
	add_child(inst)
	_dump(inst, "")
	print("DUMP SELESAI")
	get_tree().quit(0)
