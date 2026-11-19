extends Node
## Foto AUDIT TEKSTUR BANGUNAN (Gilang, 18 Nov 2026) — bukti visual
## audit tekstur/material tiap gedung terhadap standar Surau:
## foto eksterior tiap gedung dari depan pintunya, pemain asli,
## kamera luar (pitch ~datar supaya kubah/menara masuk frame).
## Jalankan TANPA --headless (headless = save_png null):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_audit_tekstur.tscn -- --gender putra
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_audit_tekstur.tscn -- --gender putri
## Yaw: menghadap = (sin yaw, 0, cos yaw): 0 = selatan, PI/2 = timur,
## PI = utara, -PI/2 = barat.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-audit-tekstur/"

const SHOT_PUTRA := [
	["surau", Vector3(0, 0, 20), PI, 0.0],
	["asrama-putra", Vector3(-44, 0, 10), PI / 2.0, -0.05],
	["cangkruk-putra", Vector3(-22, 0, -6), PI, -0.05],
	["gerbang-tembok", Vector3(4, 0, 0), PI / 2.0, -0.05],
	["pos-jaga-putra", Vector3(-40, 0, -25), PI, -0.05],
]

const SHOT_PUTRI := [
	["musholla", Vector3(134, 0, -8), PI, 0.0],
	["kelas-putri", Vector3(130, 0, 22), PI, -0.05],
	["asrama-putri", Vector3(136, 0, 9), PI / 2.0, -0.05],
	["kantor-ustadzah", Vector3(134, 0, -33), PI / 2.0, -0.05],
	["madrasah", Vector3(137, 0, -12), PI / 2.0, -0.05],
	["studio", Vector3(166, 0, -2), PI, -0.05],
	["pos-jaga-tl", Vector3(176, 0, -10), PI, -0.05],
	["gerbang-putri", Vector3(125, 0, 0), -PI / 2.0, -0.05],
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
	_main._masuk_pesantren("Foto audit tekstur " + gender)
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	for s in shots:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO AUDIT TEKSTUR %s SELESAI" % gender.to_upper())
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
