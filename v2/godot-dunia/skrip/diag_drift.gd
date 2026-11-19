extends Node
## Diagnosis drift drive (Bagas, 18 Nov 2026, fix3->fix4).
## Apakah pemain yang didorong lurus di TANAH TERBUKA (tanpa objek)
## berjalan lurus, atau melenceng lateral? Menjawab apakah slip
## tiang/pohon/pilar (fix2+fix3, drift ~0,4-0,5 m) berasal dari
## harness (drive miring) atau dari kontak fisik (geser di tiang).
## Jalankan: godot --headless --path . skrip/diag_drift.tscn

var _main: Node
var _t_fwd := Vector3(0, 0, -1)
var _t_right := Vector3(1, 0, 0)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["role"] = "keamanan"
	_main._masuk_pesantren("Diag drift")
	for i in 3:
		await get_tree().process_frame
	await _kalibrasi()
	# (a) Selatan di tanah terbuka (taman, x=0, 2,5 m timur lampu).
	await _uji("selatan taman (0,27)->S", Vector3(0, 0, 27), Vector3(0, 0, 1))
	# (b) Utara di tanah terbuka (x=-20).
	await _uji("utara (-20,20)->N", Vector3(-20, 0, 20), Vector3(0, 0, -1))
	# (c) Timur di detour z=-25 (terbuka).
	await _uji("timur detour (-20,-25)->E", Vector3(-20, 0, -25), Vector3(1, 0, 0))
	# (d) Barat di detour z=-25.
	await _uji("barat detour (10,-25)->W", Vector3(10, 0, -25), Vector3(-1, 0, 0))
	# (e) Selatan di jalan utama (x=0, z=20->0) — jalur lampu.
	await _uji("selatan jalan (0,20)->S", Vector3(0, 0, 20), Vector3(0, 0, 1))
	print("DIAG DRIFT SELESAI")
	get_tree().quit(0)


func _kalibrasi() -> void:
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	for i in 3:
		await get_tree().process_frame
	var s: Vector3 = _main._player.global_position
	_main._player.set_aksi("berdiri")
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 20:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var d: Vector3 = _main._player.global_position - s
	d.y = 0
	if d.length() > 0.05:
		_t_fwd = d.normalized()
		# right = fwd berputar -90° (searah jarum jam dari atas):
		# untuk fwd=(0,0,-1) -> right=(1,0,0).
		_t_right = Vector3(-_t_fwd.z, 0, _t_fwd.x)
	print("KALIB fwd=%s right=%s" % [str(_t_fwd), str(_t_right)])


func _uji(nama: String, start: Vector3, arah: Vector3) -> void:
	_main._teleport_player(start, PI)
	for i in 3:
		await get_tree().process_frame
	var s: Vector3 = _main._player.global_position
	var ja := arah.dot(_t_right)
	var jb := arah.dot(_t_fwd)
	_main._ui._joystick.output = Vector2(ja, -jb)
	for i in 90:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var e: Vector3 = _main._player.global_position
	var disp := e - s
	var maju: float = disp.dot(arah)
	# Lateral = komponen tegak lurus arah (di bidang XZ).
	var lat_vec := disp - arah * maju
	print("DRIFT %s maju=%.2f lateral=%s (%.2f m) akhir=%s" % [nama, maju, str(lat_vec), lat_vec.length(), str(e)])
