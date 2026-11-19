extends Node
## PROBE SEMENTARA (Gilang, Pintu Taman): petakan celah pagar bambu.
##   godot --headless --path . skrip/probe_pagar.tscn
## Dorong pemain ke pagar dari luar di 10 titik + hitung StaticBody3D
## di bawah GLB_PagarBambu_*. HAPUS setelah dipakai (bukan tes tetap).

var _main: Node
var _fwd := Vector3(0, 0, 1)
var _right := Vector3(1, 0, 0)


func _probe_joystick() -> void:
	# (0,-1) = maju kamera; ukur arah dunia nyata (2x10 frame).
	var a: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 10:
		await get_tree().process_frame
	var b: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	var d := (b - a)
	d.y = 0.0
	if d.length() > 0.05:
		_fwd = d.normalized()
	a = _main._player.global_position
	_main._ui._joystick.output = Vector2(1, 0)
	for i in 10:
		await get_tree().process_frame
	b = _main._player.global_position
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	d = (b - a)
	d.y = 0.0
	if d.length() > 0.05:
		_right = d.normalized()
	print("PROBE arah joystick: maju=%s kanan=%s" % [str(_fwd), str(_right)])


func _dorong(arah: Vector3, frame: int) -> Vector3:
	# Joystick untuk arah dunia tertentu (kamera-relatif, dipecah ke
	# basis fwd/right hasil probe).
	var a := arah.dot(_right)
	var b := arah.dot(_fwd)
	_main._ui._joystick.output = Vector2(a, -b)
	for i in frame:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	return _main._player.global_position


func _hitung_static(n: Node) -> int:
	var c := 0
	for ch in n.get_children():
		if ch is StaticBody3D:
			c += 1
		c += _hitung_static(ch)
	return c


func _di_dalam_taman(p: Vector3) -> bool:
	return p.x > -6.5 and p.x < 6.5 and p.z > 25.5 and p.z < 31.5


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Probe Pagar")
	for i in 3:
		await get_tree().process_frame
	var root: Node = _main._pesantren["root"]
	var statik := 0
	for i in 10:
		var g: Node = root.find_child("GLB_PagarBambu_%d" % i, true, false)
		if g != null:
			statik += _hitung_static(g)
	print("PROBE StaticBody3D di bawah 10 GLB pagar bambu: %d" % statik)
	await _probe_joystick()
	# [nama, start, arah dorong]
	var titik: Array = [
		["utara-tengah (0,23.5)->S", Vector3(0, 0, 23.5), Vector3(0, 0, 1)],
		["utara-barat (-4,23.5)->S", Vector3(-4, 0, 23.5), Vector3(0, 0, 1)],
		["utara-timur (4,23.5)->S", Vector3(4, 0, 23.5), Vector3(0, 0, 1)],
		["selatan-tengah (0,33.5)->U", Vector3(0, 0, 33.5), Vector3(0, 0, -1)],
		["selatan-barat (-4,33.5)->U", Vector3(-4, 0, 33.5), Vector3(0, 0, -1)],
		["selatan-timur (4,33.5)->U", Vector3(4, 0, 33.5), Vector3(0, 0, -1)],
		["barat-tengah (-8.5,28)->T", Vector3(-8.5, 0, 28), Vector3(1, 0, 0)],
		["barat-utara (-8.5,26)->T", Vector3(-8.5, 0, 26), Vector3(1, 0, 0)],
		["barat-selatan (-8.5,30)->T", Vector3(-8.5, 0, 30), Vector3(1, 0, 0)],
		["timur-tengah (8.5,28)->B", Vector3(8.5, 0, 28), Vector3(-1, 0, 0)],
		["timur-utara (8.5,26)->B", Vector3(8.5, 0, 26), Vector3(-1, 0, 0)],
		["timur-selatan (8.5,30)->B", Vector3(8.5, 0, 30), Vector3(-1, 0, 0)],
		["sudut-BL (-8.5,23.5)->TG", Vector3(-8.5, 0, 23.5), Vector3(1, 0, 1).normalized()],
		["sudut-TS (8.5,33.5)->BL", Vector3(8.5, 0, 33.5), Vector3(-1, 0, -1).normalized()],
	]
	for t in titik:
		_main._player.global_position = t[1]
		_main._player.velocity = Vector3.ZERO
		for i in 3:
			await get_tree().process_frame
		var akhir: Vector3 = await _dorong(t[2], 45)
		var tembus := _di_dalam_taman(akhir)
		print("PROBE %-32s akhir=(%.2f, %.2f) %s" % [t[0], akhir.x, akhir.z, "TEMBUS" if tembus else "tertahan"])
	print("PROBE SELESAI")
	get_tree().quit(0)
