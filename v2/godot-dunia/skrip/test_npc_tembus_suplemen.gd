extends Node
## Suplemen tes tembusan: rute sholat dari titik berangkat REALISTIS
## (bukan waypoint Bilal/Faris). Kyai dari tiap titik patrolinya ke
## Surau; Mariyah dari tiap titik patrolinya ke Musholla; Bilal dari
## SPAWN ke Surau. Memakai pendeteksi yang sama dengan test_npc_tembus.
## JANGAN ubah kode game — skrip tes saja.

var _main: Node
var _ruang: PhysicsDirectSpaceState3D
var _kyai: Node
var _ustadzah: Node
var _temuan: Array[String] = []
var _dilihat := {}
var _t := 0.0
var _jalan := false

const CANGKANG := {
	"Surau": [Vector2(-8, -24), Vector2(8, -4)],
	"Cangkruk": [Vector2(-27, -22), Vector2(-17, -14)],
	"AsramaPutra": [Vector2(-33.25, 4), Vector2(-14.75, 16)],
	"Musholla": [Vector2(128, -29), Vector2(140, -19)],
	"AsramaPutri": [Vector2(146, 3), Vector2(164, 15)],
}


func _nama_tabrakan(c: Node) -> String:
	if c == null:
		return "?"
	var induk := c.get_parent()
	var nama_induk := "" if induk == null else String(induk.name)
	var p := Vector3.ZERO
	if c is Node3D:
		p = (c as Node3D).global_position
	return "%s/%s@(%.1f,%.1f)" % [nama_induk, String(c.name), p.x, p.z]


func _ray_dari_ke(dari: Vector2, ke: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(Vector3(dari.x, 0.9, dari.y), Vector3(ke.x, 0.9, ke.y))
	q.collision_mask = 0xFFFFFFFF
	q.collide_with_areas = false
	q.collide_with_bodies = true
	return _ruang.intersect_ray(q)


func _catat(fase: String, label: String, apa: String, pos: Vector2) -> void:
	var kunci := "%s|%s|%s|%d,%d" % [fase, label, apa, int(round(pos.x)), int(round(pos.y))]
	if _dilihat.has(kunci):
		return
	_dilihat[kunci] = true
	var baris := "%s | %s | %s @ (%.1f, %.1f)" % [fase, label, apa, pos.x, pos.y]
	_temuan.append(baris)
	print("NPC-TEMBUS-SUP: " + baris)


func _cek_segmen(a: Vector3, b: Vector3, fase: String, label: String) -> void:
	var d := Vector2(b.x - a.x, b.z - a.z)
	var panjang := d.length()
	if panjang < 0.05:
		return
	var arah := d / panjang
	var tegak := Vector2(-arah.y, arah.x)
	for jalur: float in [-0.3, 0.0, 0.3]:
		var off: Vector2 = tegak * jalur
		var pos: Vector2 = Vector2(a.x, a.z) + off
		var sisa: float = panjang
		var guard := 0
		while sisa > 0.01 and guard < 128:
			guard += 1
			var target: Vector2 = pos + arah * sisa
			var hit := _ray_dari_ke(pos, target)
			if hit.is_empty():
				break
			var c := hit.get("collider") as Node
			if c == null or not (c is StaticBody3D):
				break
			var hp := hit.get("position") as Vector3
			var hp2 := Vector2(hp.x, hp.z)
			_catat(fase, label, "TABRAK " + _nama_tabrakan(c), hp2)
			var maju: float = hp2.distance_to(pos) + 0.5
			pos = pos + arah * maju
			sisa = sisa - maju
	var n := int(panjang / 1.0) + 1
	for i in range(n + 1):
		var t := float(i) / float(n)
		var p := Vector2(a.x, a.z) + d * t
		for nama in CANGKANG:
			var r: Array = CANGKANG[nama]
			var mn: Vector2 = r[0]
			var mx: Vector2 = r[1]
			if p.x >= mn.x and p.x <= mx.x and p.y >= mn.y and p.y <= mx.y:
				_catat(fase, label, "DI DALAM CANGKANG " + nama, p)
				break


func _cek_rute(titik: Array, fase: String, label: String) -> void:
	for i in range(titik.size() - 1):
		_cek_segmen(titik[i], titik[i + 1], fase, label)


func _ready() -> void:
	var dunia: PackedScene = load("res://main.tscn")
	var inst: Node = dunia.instantiate()
	add_child(inst)


func _process(delta: float) -> void:
	if _jalan:
		return
	_t += delta
	if _t < 4.0:
		return
	_jalan = true
	_main = get_tree().root.find_child("Main", true, false)
	_ruang = get_viewport().get_world_3d().direct_space_state
	_kyai = _main.get("_kyai")
	_ustadzah = _main.get("_ustadzah")

	var pk: Dictionary = _kyai._patroli
	var pm: Dictionary = _ustadzah._patroli
	# Kyai: dari tiap titik patroli luar + pintu luar -> Surau.
	var titik_kyai: Array = [pk["pintu_luar"]]
	for p in (pk["rute_luar"] as Array):
		titik_kyai.append(p)
	for p in titik_kyai:
		var r: Array = _main._rute_ke_pintu_surau(p)
		var t: Array = [p]
		for q in r:
			t.append(q)
		_cek_rute(t, "sholat-real", "Kyai->Surau dari (%.0f,%.0f)" % [p.x, p.z])
	# Mariyah: dari tiap titik patroli luar + pintu luar -> Musholla.
	var titik_mar: Array = [pm["pintu_luar"]]
	for p in (pm["rute_luar"] as Array):
		titik_mar.append(p)
	for p in titik_mar:
		var r2: Array = _main._rute_ke_pintu_musholla(p)
		var t2: Array = [p]
		for q in r2:
			t2.append(q)
		_cek_rute(t2, "sholat-real", "Mariyah->Musholla dari (%.0f,%.0f)" % [p.x, p.z])
	# Bilal dari SPAWN (-4,14) -> Surau.
	var spawn := Vector3(-4, 0, 14)
	var r3: Array = _main._rute_ke_pintu_surau(spawn)
	var t3: Array = [spawn]
	for q in r3:
		t3.append(q)
	_cek_rute(t3, "sholat-real", "Bilal->Surau dari SPAWN (-4,14)")
	print("NPC-TEMBUS-SUP: selesai, temuan=%d" % _temuan.size())
	get_tree().quit()
