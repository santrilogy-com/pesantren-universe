extends Node
## Foto sesudah Fase 2 lampu pintu (20 Nov 2026, Cahya) — JANGAN timpa
## foto audit-20nov-*. Sudut KAMERA SAMA PERSIS dengan audit, supaya
## sebelum/sesudah bisa dibandingkan. Jalankan TANPA --headless
## (headless membuat save_png null):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . skrip/foto_fase2_lampu_pintu.tscn
## 5 eksterior malam 21:00 (7 fasad: madrasah+studio 1 shot, kantor+posjaga
## 1 shot) | 1 interior Musholla 19:00 (sudah diterangkan: dasar 1,3,
## malam 2,6, jangkauan 8 m).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto fase2 lampu pintu")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# --- A. EKSTERIOR MALAM (21:00), sudut sama dengan audit ---
	await _foto("fase2-asrama-putri-luar.png", Vector3(138, 3.5, 14), Vector3(155, 3, 0), 21.0, 0)
	await _foto("fase2-kelas-putri-luar.png", Vector3(118, 3, 10), Vector3(130, 2, 0), 21.0, 0)
	await _foto("fase2-madrasah-studio-luar.png", Vector3(140, 3, -2), Vector3(160, 2, -12), 21.0, 0)
	await _foto("fase2-kantor-posjaga-luar.png", Vector3(136, 4, -20), Vector3(154, 2, -34), 21.0, 0)
	await _foto("fase2-asrama-putra-luar.png", Vector3(-10, 3, 20), Vector3(-24, 3, 10), 21.0, 0)
	# --- B. INTERIOR MUSHOLLA (19:00), sudut sama dengan audit ---
	await _foto("fase2-musholla-interior.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 19.0, 3)
	LangitDinamis.debug_jam = -1.0
	print("FOTO FASE2 LAMPU PINTU SELESAI")
	get_tree().quit(0)


## mode: 0 eksterior | 1 Surau | 3 Musholla | 4 Asrama Putri
func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float, mode: int) -> void:
	LangitDinamis.debug_jam = jam
	match mode:
		1:
			_main._set_interior_terlihat(true, false)
		3:
			_main._set_interior_terlihat(false, false, true)
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
