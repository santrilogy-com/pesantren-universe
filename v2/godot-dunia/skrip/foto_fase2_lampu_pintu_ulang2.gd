extends Node
## Foto ulang Fase 2 ronde 2 (20 Nov 2026, Cahya) — 2 close-up pintu.
## Alasan: shot R2 kantor-posjaga (sudut audit) terlalu jauh — Kantor
## dan Pos Jaga hanya sebesar jempol, lampunya tidak bisa dinilai.
## Shot ini dari dekat, dari sisi pintu (barat).
## Jalankan TANPA --headless: xvfb-run -a -s "-screen 0 1280x720x24"
##   godot --path . skrip/foto_fase2_lampu_pintu_ulang2.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto fase2 ulang2 close-up")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Malam 21:00, close-up dari barat (pintu menghadap barat).
	await _foto("fase2-kantor-pintu.png", Vector3(132, 3, -33), Vector3(144, 2, -33), 21.0)
	await _foto("fase2-posjaga-pintu.png", Vector3(163, 3, -20), Vector3(174.5, 2, -20), 21.0)
	LangitDinamis.debug_jam = -1.0
	print("FOTO FASE2 ULANG2 SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float) -> void:
	LangitDinamis.debug_jam = jam
	_main._set_interior_terlihat(false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
