extends Node
## Foto ulang audit lighting 20 Nov 2026 (Cahya) — 3 shot yang gagal/ragu:
## R1 kantor-posjaga: kamera pertama menempel dinding — ambil dari tinggi/jauh.
## R2 kamar001-dalam: dari dalam pintu ke arah kasur (lampu di atas lorong).
## R3 kamar001-kasur: dari kasur bawah ke arah pintu (cek garis pandang bangun tidur).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto audit lighting ulang")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	await _foto("audit-20nov-kantor-posjaga-r2.png", Vector3(128, 8, -14), Vector3(155, 2, -34), 21.0, 0)
	await _foto("audit-20nov-kamar001-dalam.png", Vector3(-244.5, 1.7, -301.5), Vector3(-244.5, 1.4, -305), 19.0, 4)
	await _foto("audit-20nov-kamar001-kasur.png", Vector3(-247.8, 1.2, -304.7), Vector3(-244.5, 1.5, -301.0), 19.0, 4)
	LangitDinamis.debug_jam = -1.0
	print("FOTO AUDIT ULANG SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float, mode: int) -> void:
	LangitDinamis.debug_jam = jam
	match mode:
		4:
			_main._set_interior_terlihat(false, false, false, true)
		_:
			_main._set_interior_terlihat(false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
