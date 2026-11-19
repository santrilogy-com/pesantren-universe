extends Node
## Foto ulang Fase 2 (20 Nov 2026, Cahya) — 4 shot dari SISI PINTU.
## Alasan: 4 dari 6 shot fase2 pertama diambil dari sudut audit yang
## memperlihatkan sisi gedung yang BUKAN sisi pintu (Asrama Putra dari
## tenggara — pintu di barat; Kelas dari barat — pintu di selatan;
## Studio dari barat — pintu di selatan; kantor-posjaga mengulang
## sudut R1 audit yang menempel dinding). Shot ini dari sisi pintu,
## supaya lampu pintunya terlihat langsung. Sudut kantor memakai
## sudut R2 audit (128,8,-14 -> 155,2,-34).
## Jalankan TANPA --headless: xvfb-run -a -s "-screen 0 1280x720x24"
##   godot --path . skrip/foto_fase2_lampu_pintu_ulang.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-lighting/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto fase2 ulang sisi pintu")
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Malam 21:00, semua dari sisi pintu (lampu 1,5 m di luar pintu).
	await _foto("fase2-asrama-putra-pintu.png", Vector3(-44, 3, 10), Vector3(-33, 2.5, 10), 21.0, 0)
	await _foto("fase2-kelas-putri-pintu.png", Vector3(130, 3, 26), Vector3(130, 2, 14), 21.0, 0)
	await _foto("fase2-studio-pintu.png", Vector3(166, 3, -28), Vector3(166, 2, -16), 21.0, 0)
	await _foto("fase2-kantor-posjaga-r2.png", Vector3(128, 8, -14), Vector3(155, 2, -34), 21.0, 0)
	LangitDinamis.debug_jam = -1.0
	print("FOTO FASE2 ULANG SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, jam: float, mode: int) -> void:
	LangitDinamis.debug_jam = jam
	_main._set_interior_terlihat(false, false)
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
