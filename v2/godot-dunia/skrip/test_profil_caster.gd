extends Node
## Profil caster bayangan (Rangga, 19 Nov 2026) — headless:
##   godot --headless --path . skrip/test_profil_caster.tscn
## Rincian cast_shadow=ON per area + per kelas mesh, untuk mengejar
## target caster < 500. TIDAK mengubah game, hanya mengukur.

var _main: Node
var _per_area: Dictionary = {}
var _per_kelas_on: Dictionary = {}
var _per_kelas_off: Dictionary = {}
var _besar_luar_on := 0
var _kecil_luar_on := 0


func _hitung(n: Node, area: String) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var kelas := "?"
		if mi.mesh != null:
			kelas = mi.mesh.get_class()
		var on := mi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var d := _per_kelas_on if on else _per_kelas_off
		d[kelas] = int(d.get(kelas, 0)) + 1
		if on:
			_per_area[area] = int(_per_area.get(area, 0)) + 1
			if area == "Pesantren":
				var s: Vector3 = mi.get_aabb().size * mi.scale
				if maxf(maxf(s.x, s.y), s.z) >= 2.0:
					_besar_luar_on += 1
				else:
					_kecil_luar_on += 1
	for ch in n.get_children():
		_hitung(ch, area)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("ProfilCaster")
	for i in 5:
		await get_tree().process_frame
	for ch in _main.get_children():
		_hitung(ch, String(ch.name))
	print("CASTER: ON per area:")
	for k in _per_area.keys():
		print("CASTER:   %-28s %d" % [k, int(_per_area[k])])
	print("CASTER: ON per kelas mesh:")
	for k in _per_kelas_on.keys():
		print("CASTER:   %-16s %d" % [k, int(_per_kelas_on[k])])
	print("CASTER: OFF per kelas mesh:")
	for k in _per_kelas_off.keys():
		print("CASTER:   %-16s %d" % [k, int(_per_kelas_off[k])])
	print("CASTER: Pesantren ON besar(>=2m)=%d kecil(<2m)=%d" % [_besar_luar_on, _kecil_luar_on])
	get_tree().quit()
