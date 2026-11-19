extends Node
## Retake close-up santriwati (KIRANA 17 Nov 2026): foto 35-37
## diambil dari 6,5 m — wajah tidak terbaca. Retake dari ~3 m
## supaya jilbab + wajah depan terlihat jelas. Sisi depan dihitung
## dari posisi mata di dunia (bukan asumsi yaw) supaya kamera
## pasti di depan wajah. Output 39; foto 01-38 JANGAN ditimpa.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/foto-ronde-20/"

var _main: Node
var _cam: Camera3D
var _save_backup := ""
var _save_ada := false


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	if FileAccess.file_exists(SantriSave.SAVE_PATH):
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.READ)
		if f != null:
			_save_backup = f.get_as_text()
			_save_ada = true
			f.close()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri", "jenis_kelamin": "putri", "session": "stub"})
	_main._masuk_pesantren("Tes Putri")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 55.0
	add_child(_cam)
	_cam.current = true
	_main._kyai._patroli_timer = 9999.0
	_main._ustadzah._patroli_timer = 9999.0
	_main._player.global_position = Vector3(130, 0, 14)
	_main._player.velocity = Vector3.ZERO
	_main._player.set_facing(PI)
	await get_tree().process_frame
	# Sisi depan = arah mata dari kepala (dunia).
	var v: Node3D = _main._player._visual
	var mata := v.find_child("MataKiri", true, false) as Node3D
	var kepala := v.find_child("Kepala", true, false) as Node3D
	var depan := Vector3(0, 0, 1)
	if mata != null and kepala != null:
		var d := mata.global_position - kepala.global_position
		d.y = 0.0
		if d.length() > 0.01:
			depan = d.normalized()
	print("ARAH DEPAN WAJAH: %s" % str(depan))
	var pos_pemain := Vector3(130, 0, 14)
	var pos_kam := pos_pemain + depan * 3.2 + Vector3(0, 1.9, 0)
	await _foto("39-santriwati-dekat.png", pos_kam, pos_pemain + Vector3(0, 1.35, 0), "luar")
	_pulihkan_save()
	print("FOTO SELESAI")
	get_tree().quit(0)


func _pulihkan_save() -> void:
	if _save_ada:
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.WRITE)
		if f != null:
			f.store_string(_save_backup)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, _mode: String) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
