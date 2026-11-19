extends Node
## Foto audit lighting 20 Nov 2026 (Cahya) — JANGAN timpa foto L1-L8 lama.
## Jalankan TANPA --headless (headless membuat save_png null):
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . skrip/foto_audit_lighting_20nov.tscn
## 12 shot, modul PencahayaanV2 SUDAH terpasang via main.gd (keadaan live
## saat ini, bukan sebelum/sesudah). Jam paksa via LangitDinamis.debug_jam.
## A1-A8 eksterior malam 21:00 | B1-B4 interior 19:00.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto audit lighting")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# --- A. EKSTERIOR MALAM (21:00), semua interior disembunyikan ---
	await _foto("audit-20nov-jalan-malam.png", Vector3(-4, 2.5, 10), Vector3(0, 2, -30), 21.0, 0)
	await _foto("audit-20nov-musholla-luar.png", Vector3(134, 2.5, -6), Vector3(134, 2.5, -24), 21.0, 0)
	await _foto("audit-20nov-asrama-putri-luar.png", Vector3(138, 3.5, 14), Vector3(155, 3, 0), 21.0, 0)
	await _foto("audit-20nov-kelas-putri-luar.png", Vector3(118, 3, 10), Vector3(130, 2, 0), 21.0, 0)
	await _foto("audit-20nov-madrasah-studio-luar.png", Vector3(140, 3, -2), Vector3(160, 2, -12), 21.0, 0)
	await _foto("audit-20nov-kantor-posjaga-luar.png", Vector3(136, 4, -20), Vector3(154, 2, -34), 21.0, 0)
	await _foto("audit-20nov-asrama-putra-luar.png", Vector3(-10, 3, 20), Vector3(-24, 3, 10), 21.0, 0)
	await _foto("audit-20nov-cangkruk-putra-luar.png", Vector3(-22, 3, -4), Vector3(-22, 2, -18), 21.0, 0)
	# --- B. INTERIOR (19:00) ---
	await _foto("audit-20nov-musholla-interior.png", InteriorMusholla.ke_dunia(Vector3(60, 1.8, -297.0)), InteriorMusholla.ke_dunia(Vector3(60, 1.2, -304.0)), 19.0, 3)
	await _foto("audit-20nov-surau-interior.png", Vector3(0, 2.0, -295.8), Vector3(0, 1.5, -304.0), 19.0, 1)
	await _foto("audit-20nov-kamar001-putri.png", Vector3(-245.5, 1.7, -300.5), Vector3(-244.5, 1.3, -304.7), 19.0, 4)
	await _foto("audit-20nov-koridor-putri.png", Vector3(-242, 1.7, -300), Vector3(-230, 1.5, -300), 19.0, 4)
	LangitDinamis.debug_jam = -1.0
	print("FOTO AUDIT LIGHTING SELESAI")
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
