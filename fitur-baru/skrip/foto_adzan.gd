extends Node
## Foto FITUR ADZAN (Sinta, 17 Nov 2026). Dijalankan sebagai SCENE:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --resolution 1280x720 \
##     --path . foto_adzan.tscn
## (TANPA --headless — headless membuat save_png null.)
## Bukti VISUAL: banner sholat muncul tepat di jam sholat, tidak
## muncul di luar jam. Audio TIDAK terlihat di foto — bukti bunyi
## ada di tes headless (test_adzan.gd: counter + playing).
## A1 Subuh 04:30 (banner) | A2 Maghrib 18:00 (banner) |
## A3 jam 10:00 (tanpa banner, pembanding).
## Kamera sama persis untuk ketiganya: depan Surau (-4, 2, 22).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/fitur-baru/foto/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes foto adzan")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	var pos_kamera := Vector3(-4, 2.0, 22.0)
	var target := Vector3(-4, 3.0, -20.0)

	# A1 — Subuh: sesi mulai lewat _process (debug_jam beku).
	LangitDinamis.debug_jam = 4.5
	await _foto("A1-subuh-banner.png", pos_kamera, target)
	# A2 — Maghrib: sesi Subuh berakhir dulu (jam lewat batas),
	# lalu sesi Maghrib mulai di frame berikutnya.
	LangitDinamis.debug_jam = 18.0
	await _foto("A2-maghrib-banner.png", pos_kamera, target)
	# A3 — jam 10:00: di luar jendela, tanpa banner.
	LangitDinamis.debug_jam = 10.0
	await _foto("A3-bukan-jam-sholat.png", pos_kamera, target)
	print("FOTO ADZAN SELESAI")
	get_tree().quit(0)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 60:
		await get_tree().process_frame
	var banner := _main._ui._sholat_banner.visible
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s, banner=%s, sholat_aktif=%s)" % [
		nama, OUT_DIR + nama, str(err), str(banner), str(_main._sholat_aktif)])
