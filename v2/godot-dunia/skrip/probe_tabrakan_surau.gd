extends Node

## Probe baca-saja: daftar semua StaticBody3D di sekitar pintu Surau
## (pusat (0,-1), radius 4 m) beserta nama, induk, posisi, dan ukuran kotak.
## Untuk mengidentifikasi collider anonim @53/@57/@59 yang paling sering
## ditabrak tes tembusan. TIDAK mengubah kode game.

var _t := 0.0
var _selesai := false


func _ready() -> void:
	var dunia: PackedScene = load("res://main.tscn")
	var inst: Node = dunia.instantiate()
	add_child(inst)


func _process(delta: float) -> void:
	if _selesai:
		return
	_t += delta
	if _t < 4.0:
		return
	_selesai = true
	var pusat := Vector3(0, 0, -1)
	var daftar: Array = []
	for n in get_tree().root.find_children("*", "StaticBody3D", true, false):
		var b := n as StaticBody3D
		var p: Vector3 = b.global_position
		var d: float = Vector2(p.x - pusat.x, p.z - pusat.z).length()
		if d <= 4.0:
			var ukuran := ""
			for c in b.get_children():
				var cs := c as CollisionShape3D
				if cs and cs.shape is BoxShape3D:
					var s: Vector3 = (cs.shape as BoxShape3D).size
					ukuran += " kotak(%s,%s,%s)" % [str(s.x), str(s.y), str(s.z)]
				elif cs and cs.shape:
					ukuran += " " + cs.shape.get_class()
			daftar.append("%s | induk=%s | pos=(%.2f,%.2f,%.2f) | jarah=%.2f%s" % [b.name, b.get_parent().name if b.get_parent() else "?", p.x, p.y, p.z, d, ukuran])
	daftar.sort()
	print("PROBE-SURAU: %d StaticBody3D dalam 4 m dari (0,-1)" % daftar.size())
	for s in daftar:
		print("PROBE-SURAU: " + s)
	get_tree().quit()
