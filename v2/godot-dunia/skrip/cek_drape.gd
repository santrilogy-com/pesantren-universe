extends Node
## Diagnosa drape: cetak mesh + AABB + permukaan.

func _ready() -> void:
	var built: Dictionary = SantriPlayer.build_visual("Tes", MissionData.OUTFIT_DEFAULT)
	var drape: MeshInstance3D = built["drape"]
	print("DRAPE node=%s visible=%s scale=%s pos=%s" % [str(drape), str(drape.visible), str(drape.scale), str(drape.position)])
	var mesh: ArrayMesh = drape.mesh as ArrayMesh
	print("DRAPE mesh=%s surfaces=%d" % [str(mesh), mesh.get_surface_count()])
	if mesh != null and mesh.get_surface_count() > 0:
		var arr: Array = mesh.surface_get_arrays(0)
		var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var norms: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV]
		var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
		print("DRAPE verts=%d norms=%d uvs=%d idx=%d" % [verts.size(), norms.size(), uvs.size(), idx.size()])
		print("DRAPE aabb=%s" % str(mesh.get_aabb()))
		print("DRAPE v0=%s v100=%s v174=%s" % [str(verts[0]), str(verts[100]), str(verts[174])])
		print("DRAPE idx0-5=%s" % str(idx.slice(0, 6)))
		print("DRAPE material=%s" % str(drape.material_override))
		print("DRAPE cast_shadow=%d" % drape.cast_shadow)
	var sarung: MeshInstance3D = built["sarung"]
	print("SARUNG mesh aabb=%s" % str((sarung.mesh as ArrayMesh).get_aabb() if sarung.mesh is ArrayMesh else sarung.mesh))
	get_tree().quit(0)
