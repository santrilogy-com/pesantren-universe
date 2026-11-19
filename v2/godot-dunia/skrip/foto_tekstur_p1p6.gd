extends Node
## Foto BUKTI SESUDAH ronde perbaikan tekstur P1-P6 putri (Nadia, 18 Nov 2026).
## Sudut diambil SAMA dengan foto audit (v2/foto-audit-tekstur/) supaya
## sebelum/sesudah sebanding langsung. Yaw: menghadap = (sin yaw, 0, cos yaw).
## Jalankan TANPA --headless (headless = save_png null), Xvfb :99 sudah jalan:
##   DISPLAY=:99 ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_tekstur_p1p6.tscn
## Argumen opsional: -- --hanya=p1 | p4 | p2 (default: semua).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-tekstur-p1p6/"

const SHOT_P1 := [
	["asrama-putri-p1", Vector3(140, 0, 17), 2.16, -0.05],
	["asrama-putri-p1-barat", Vector3(136, 0, 9), PI / 2.0, -0.05],
	["asrama-putri-p1-timur", Vector3(172, 0, 20), -2.31, -0.05],
	# Serambi + plakat dari barat-daya jalan (kamera bebas dinding Kelas).
	["asrama-putri-p1-serambi", Vector3(141, 0, 19), 2.44, -0.05],
]
const SHOT_P4 := [
	["musholla-p4", Vector3(134, 0, -8), PI, 0.0],
	["musholla-p4-dekat", Vector3(134, 0, -10), PI, 0.15],
]
const SHOT_P2 := [
	["kelas-putri-p2", Vector3(130, 0, 22), PI, -0.05],
	["kantor-p2", Vector3(134, 0, -33), PI / 2.0, -0.05],
	["madrasah-p2", Vector3(137, 0, -12), PI / 2.0, -0.05],
	# KOREKSI: yaw audit (PI) membelakangi Studio — pintu di fasad
	# UTARA (z=-16), pemain di utara gedung harus menghadap SELATAN (yaw 0).
	["studio-p2", Vector3(166, 0, -22), 0.0, -0.05],
	["studio-p6-jauh", Vector3(166, 0, -28), 0.0, -0.05],
	["asrama-putri-p6", Vector3(140, 0, 17), 2.16, -0.05],
]

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var hanya := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hanya="):
			hanya = a.trim_prefix("--hanya=")
	var shots: Array = []
	if hanya == "" or hanya == "p1":
		shots.append_array(SHOT_P1)
	if hanya == "" or hanya == "p4":
		shots.append_array(SHOT_P4)
	if hanya == "" or hanya == "p2":
		shots.append_array(SHOT_P2)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto tekstur P1-P6 putri")
	for i in 3:
		await get_tree().process_frame
	_main._player.set_nama("Nadia")
	_main._audio.mulai()
	for s in shots:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO TEKSTUR P1P6 SELESAI (%d shot)" % shots.size())
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
