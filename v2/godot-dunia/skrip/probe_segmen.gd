extends Node
## PROBE SEMENTARA (Raka, 20 Nov 2026) — diagnosis 2 segmen gagal
## test_lokasi_acak: taman_putra (0,27) + musholla_putri (131,-17.5).
## Untuk tiap pasangan (kandidat, jangkar): laporkan tapak vs raycast,
## dan bila raycast gagal, nama collider + posisi tabrakan pertama.
## HAPUS setelah diagnosis (bukan tes permanen).
##   HOME=/tmp/iso-probe godot --headless --path . --scene res://skrip/probe_segmen.tscn

var _main: Node
var _ruang: PhysicsDirectSpaceState3D


func _nama_tabrakan(c: Node) -> String:
	if c == null:
		return "?"
	var induk := c.get_parent()
	var nama_induk := "" if induk == null else String(induk.name)
	var p := Vector3.ZERO
	if c is Node3D:
		p = (c as Node3D).global_position
	return "%s/%s@(%.1f,%.1f,%.1f)" % [nama_induk, String(c.name), p.x, p.y, p.z]


func _ray_dari_ke(dari: Vector3, ke: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(dari, ke)
	q.collision_mask = 0xFFFFFFFF
	q.collide_with_areas = false
	q.collide_with_bodies = true
	return _ruang.intersect_ray(q)


## Raycast marching 3 jalur (pola test_npc_tembus): collider pertama.
func _tabrakan_pertama(a: Vector3, b: Vector3) -> String:
	var d := Vector2(b.x - a.x, b.z - a.z)
	var panjang := d.length()
	if panjang < 0.05:
		return ""
	var arah := d / panjang
	var tegak := Vector2(-arah.y, arah.x)
	for jalur: float in [-0.3, 0.0, 0.3]:
		var off := tegak * jalur
		var hit := _ray_dari_ke(
			Vector3(a.x + off.x, 0.9, a.z + off.y),
			Vector3(b.x + off.x, 0.9, b.z + off.y))
		if hit.is_empty():
			continue
		var c := hit.get("collider") as Node
		if c == null or not (c is StaticBody3D):
			continue
		var hp := hit.get("position") as Vector3
		return "jalur %+.1f -> %s @ (%.1f,%.1f,%.1f)" % [jalur, _nama_tabrakan(c), hp.x, hp.y, hp.z]
	return ""


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Probe Segmen")
	for i in 5:
		await get_tree().process_frame
	_ruang = get_viewport().get_world_3d().direct_space_state
	var sanusi: SantriNPC = _main._sanusi
	var kasus := {
		"taman_putra (0,27)": [Vector3(0, 0, 27), [
			Vector3(4, 0, 4), Vector3(-4, 0, 6), Vector3(8, 0, -2),
			Vector3(-6, 0, -2), Vector3(2, 0, 12), Vector3(-8, 0, 8),
			Vector3(10, 0, 8), Vector3(-20, 0, 18), Vector3(-24, 0, -10),
			Vector3(-32, 0, 24), Vector3(-58, 0, -38),
		]],
		"musholla_putri (131,-17.5)": [Vector3(131, 0, -17.5), [
			Vector3(140, 0, 16), Vector3(122, 0, 32),
			Vector3(128, 0, -12), Vector3(142, 0, 0),
		]],
	}
	for nama in kasus:
		var data: Array = kasus[nama]
		var p: Vector3 = data[0]
		print("PROBE === %s ===" % nama)
		for j in (data[1] as Array):
			var jj: Vector3 = j
			var ray_ok: bool = sanusi._segmen_bersih(p, jj)
			var tabrak := "" if ray_ok else _tabrakan_pertama(p, jj)
			print("PROBE ke (%.1f,%.1f): _segmen_bersih=%s %s" % [jj.x, jj.z, str(ray_ok), tabrak])
	# Khusus taman_putra: cek pintu taman (0,25.5) sebagai portal.
	print("PROBE === taman_putra via pintu (0,25.5) ===")
	var p0 := Vector3(0, 0, 27)
	var pintu := Vector3(0, 0, 25.5)
	print("PROBE (0,27)->(0,25.5): %s %s" % [str(sanusi._segmen_bersih(p0, pintu)), _tabrakan_pertama(p0, pintu)])
	for jj in [Vector3(4, 0, 4), Vector3(-4, 0, 6), Vector3(2, 0, 12)]:
		print("PROBE (0,25.5)->(%.1f,%.1f): %s %s" % [jj.x, jj.z, str(sanusi._segmen_bersih(pintu, jj)), _tabrakan_pertama(pintu, jj)])
	print("PROBE SELESAI")
	get_tree().quit(0)
