extends Node
## Foto tambahan P3 (Fajar, 18 Nov 2026) — verifikasi LABEL dari sisi
## pintu (label tidak terlihat dari viewpoint audit yang dari selatan):
## Pos Jaga putra (-40,-35) pintu timur + Pos Satpam (17,5) pintu barat.
## Jalankan: DISPLAY=:99 godot --path . skrip/foto_perbaikan_p3_label.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-perbaikan-p3/"

const SHOTS := [
	["label-pos-jaga-putra", Vector3(-33, 0, -35), -PI / 2.0, -0.05],
	["label-pos-satpam", Vector3(23, 0, 5), -PI / 2.0, -0.05],
]

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto label P3")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	for s in SHOTS:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO LABEL P3 SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos: Vector3, yaw: float, pitch: float) -> void:
	get_window().size = Vector2i(1024, 576)
	for i in 10:
		await get_tree().process_frame
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(pos, yaw)
	_main._cam_pitch = pitch
	_main._spring.rotation.x = pitch
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama + ".png")
	print("FOTO %s -> %s (err=%s) cam=%s pemain=%s" % [
		nama, OUT_DIR + nama + ".png", str(err),
		str(_main._cam.global_position), str(_main._player.global_position)])
