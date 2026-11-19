extends Node
## Dump isi GLB Surau yang DIMUAT Godot (bukan file .blend):
##   godot --headless --path . skrip/dump_surau.tscn
## Cetak nama node + posisi + rotasi Y tiap MeshInstance3D.

func _dump(n: Node, indent: String) -> void:
	var extra := ""
	if n is Node3D:
		var t := n as Node3D
		extra = " pos=(%.2f, %.2f, %.2f) rotY=%.1f" % [t.position.x, t.position.y, t.position.z, rad_to_deg(t.rotation.y)]
	print(indent + String(n.name) + " [" + n.get_class() + "]" + extra)
	for ch in n.get_children():
		_dump(ch, indent + "  ")


func _ready() -> void:
	var packed := load("res://models/surau-v2.glb") as PackedScene
	if packed == null:
		print("DUMP GAGAL: GLB tidak termuat")
		get_tree().quit(1)
		return
	var inst := packed.instantiate() as Node3D
	_dump(inst, "")
	print("DUMP SELESAI")
	get_tree().quit(0)
