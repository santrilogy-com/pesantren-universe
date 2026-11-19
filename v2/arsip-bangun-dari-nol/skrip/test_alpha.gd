extends Node
## Tes headless v2 ALPHA — jalankan: godot --headless --path . skrip/test_alpha.tscn
## Cek: spawn pemain, jumlah GLB, jumlah gedung, tanah, joystick, gerak maju.

var _main: Node
var _pass: int = 0
var _fail: int = 0


func _cek(nama: String, ok: bool, info: String = "") -> void:
	if ok:
		_pass += 1
		print("PASS ", nama, " ", info)
	else:
		_fail += 1
		print("FAIL ", nama, " ", info)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 10:
		await get_tree().process_frame

	var player: Node = _main.player
	_cek("player-ada", player != null)
	if player != null:
		var p: Vector3 = player.global_position
		_cek("spawn-putra", absf(p.x - (-4.0)) < 0.5 and absf(p.z - 14.0) < 0.5,
			"pos=(%.1f, %.1f)" % [p.x, p.z])
	_cek("glb-count", _main._glb_count >= 40, "glb=%d" % _main._glb_count)
	_cek("gedung-count", _main._gedung_count == 18, "gedung=%d" % _main._gedung_count)
	_cek("tanah-ada", _main.get_node_or_null("Tanah") != null)
	_cek("surau-ada", _main.get_node_or_null("Surau") != null)
	_cek("sawah-ada", _main.get_node_or_null("Sawah") != null)
	_cek("taman-ada", _main.get_node_or_null("Taman") != null)
	_cek("joystick-ada", _main._joystick != null)
	# Gerak maju: dorong joystick ke depan 30 frame -> pemain harus pindah > 0.5 m.
	# (Injeksi lewat joystick.output, karena main._process menimpa
	# player.move_input tiap frame dari joystick/keyboard.)
	if player != null:
		var awal: Vector3 = player.global_position
		_main._joystick.output = Vector2(0, -1)
		for i in 30:
			await get_tree().physics_frame
		var akhir: Vector3 = player.global_position
		var jarak: float = awal.distance_to(akhir)
		_cek("gerak-maju", jarak > 0.5, "pindah=%.2f m" % jarak)
		_main._joystick.output = Vector2.ZERO

	print("TEST SELESAI: %d PASS / %d FAIL" % [_pass, _fail])
	get_tree().quit(0 if _fail == 0 else 1)
