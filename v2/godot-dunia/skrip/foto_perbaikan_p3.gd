extends Node
## Foto PERBAIKAN P3 (Fajar, 18 Nov 2026) — bukti sesudah Pos Jaga
## bahasa Surau (dinding KREM + lis emas, atap zamrud dipertahankan):
## 1 pos putra + Pos Satpam + 1 pos putri TL. Viewpoint SAMA seperti
## foto audit (foto-audit-tekstur/) supaya sebelum/sesudah sebanding.
## Jalankan TANPA --headless (headless = save_png null):
##   Xvfb :99 & DISPLAY=:99 ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_perbaikan_p3.tscn -- --gender putra
##   Xvfb :99 & DISPLAY=:99 ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_perbaikan_p3.tscn -- --gender putri
## Yaw: menghadap = (sin yaw, 0, cos yaw): 0 = selatan, PI/2 = timur,
## PI = utara, -PI/2 = barat.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-perbaikan-p3/"

const SHOT_PUTRA := [
	["pos-jaga-putra", Vector3(-40, 0, -25), PI, -0.05],
	["pos-satpam", Vector3(26, 0, 5), -PI / 2.0, -0.05],
]

const SHOT_PUTRI := [
	["pos-jaga-tl", Vector3(176, 0, -10), PI, -0.05],
]

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var gender := "putra"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gender="):
			gender = a.trim_prefix("--gender=")
		elif a == "putri" or a == "putra":
			gender = a
	var shots: Array = SHOT_PUTRI if gender == "putri" else SHOT_PUTRA
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = gender
	_main._masuk_pesantren("Foto perbaikan P3 " + gender)
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	for s in shots:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO PERBAIKAN P3 %s SELESAI" % gender.to_upper())
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
