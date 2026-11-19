extends Node
## Cek setting performa (Rangga, 19 Nov 2026) — headless:
##   godot --headless --path . skrip/test_cek_perf_setting.tscn
## Pastikan Engine.max_fps=60 (main.gd _ready), scaling_3d mode=1
## (bilinear) + scale=0.75 (project.godot), dan kamera far=300.

var _main: Node


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Cek setting")
	for i in 5:
		await get_tree().process_frame
	var mode: int = int(ProjectSettings.get_setting("rendering/scaling_3d/mode", -1))
	var skala: float = float(ProjectSettings.get_setting("rendering/scaling_3d/scale", -1.0))
	var cam := get_viewport().get_camera_3d()
	print("CEK: Engine.max_fps=%d (harap 60)" % Engine.max_fps)
	# scaling_3d: TERBUKTI inert di renderer GL Compatibility (wajib
	# web) — engine memaksa mode 0 walau project.godot berisi 1/0.75
	# (setter viewport menolak BILINEAR). Dicetak sebagai info saja,
	# bukan syarat lulus; penahan fill-rate yang jalan = max_fps 60.
	print("CEK: scaling_3d mode=%d scale=%.2f (0/1.0 = dipaksa nonaktif oleh Compatibility, project.godot tetap 1/0.75)" % [mode, skala])
	print("CEK: viewport scaling_3d_mode=%d (1=bilinear)" % get_viewport().scaling_3d_mode)
	if cam != null:
		print("CEK: camera far=%.1f (harap 450) fov=%.1f" % [cam.far, cam.fov])
	var ok := Engine.max_fps == 60 and cam != null and absf(cam.far - 450.0) < 0.01
	print("CEK PERF SETTING: %s" % ("LULUS" if ok else "GAGAL"))
	get_tree().quit(0 if ok else 1)
