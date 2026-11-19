extends Node
## Profil performa (Rangga, 19 Nov 2026) — headless:
##   godot --headless --path . skrip/test_profil.tscn
## Hitung node/lampu/mesh runtime dunia v2 + perkiraan draw call &
## segitiga. TIDAK mengubah game, hanya mengukur.

var _main: Node
var c_total := 0
var c_mesh := 0
var c_surfaces := 0
var c_verts := 0
var c_tris := 0
var c_omni := 0
var c_omni_shadow := 0
var c_spot := 0
var c_dir := 0
var c_label3d := 0
var c_anim := 0
var c_colshape := 0
var c_cast_off := 0
var c_cast_on := 0
var c_glb := 0
var c_visible_off := 0
var c_npc := 0


func _hitung(n: Node) -> void:
	c_total += 1
	if n is MeshInstance3D:
		c_mesh += 1
		var mi := n as MeshInstance3D
		if mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			c_cast_off += 1
		else:
			c_cast_on += 1
		var m := mi.mesh
		if m != null:
			var sc := m.get_surface_count()
			c_surfaces += sc
			for s in sc:
				var arr := m.surface_get_arrays(s)
				if arr.is_empty():
					continue
				var v = arr[Mesh.ARRAY_VERTEX]
				if v != null:
					c_verts += (v as PackedVector3Array).size()
				var idx = arr[Mesh.ARRAY_INDEX]
				if idx != null:
					c_tris += (idx as PackedInt32Array).size() / 3
				elif v != null:
					c_tris += (v as PackedVector3Array).size() / 3
	if n is OmniLight3D:
		c_omni += 1
		if (n as OmniLight3D).shadow_enabled:
			c_omni_shadow += 1
	if n is SpotLight3D:
		c_spot += 1
	if n is DirectionalLight3D:
		c_dir += 1
	if n is Label3D:
		c_label3d += 1
	if n is AnimationPlayer:
		c_anim += 1
	if n is CollisionShape3D:
		c_colshape += 1
	if String(n.name).begins_with("GLB_"):
		c_glb += 1
	if n is Node3D and not (n as Node3D).visible:
		c_visible_off += 1
	if n.get_script() != null and String(n.get_script().resource_path).ends_with("npc.gd"):
		c_npc += 1
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
	_main._masuk_pesantren("Profil")
	for i in 5:
		await get_tree().process_frame
	_hitung(_main)
	print("PROFIL: total_node=%d" % c_total)
	print("PROFIL: mesh_instance=%d surfaces=%d verts=%d tris~%d" % [c_mesh, c_surfaces, c_verts, c_tris])
	print("PROFIL: omni=%d omni_shadow=%d spot=%d dir=%d" % [c_omni, c_omni_shadow, c_spot, c_dir])
	print("PROFIL: cast_shadow_ON=%d cast_shadow_OFF=%d" % [c_cast_on, c_cast_off])
	print("PROFIL: label3d=%d animplayer=%d colshape=%d glb_nodes=%d npc=%d visible_off=%d" % [c_label3d, c_anim, c_colshape, c_glb, c_npc, c_visible_off])
	# Kamera aktif + far + viewport.
	var cam := get_viewport().get_camera_3d()
	if cam != null:
		print("PROFIL: camera far=%.1f fov=%.1f" % [cam.far, cam.fov])
	print("PROFIL: viewport=%s" % str(get_viewport().get_visible_rect().size))
	# Ukuran dunia (AABB semua MeshInstance3D).
	var mn := Vector3(INF, INF, INF)
	var mx := Vector3(-INF, -INF, -INF)
	var stack: Array[Node] = [_main]
	while not stack.is_empty():
		var nd: Node = stack.pop_back()
		if nd is MeshInstance3D:
			var aabb: AABB = (nd as MeshInstance3D).get_aabb()
			var ga: AABB = AABB((nd as Node3D).to_global(aabb.position), aabb.size)
			mn = mn.min(ga.position)
			mx = mx.max(ga.position + ga.size)
		for ch in nd.get_children():
			stack.append(ch)
	print("PROFIL: world_aabb_min=%s max=%s size=%s" % [str(mn), str(mx), str(mx - mn)])
	get_tree().quit()
