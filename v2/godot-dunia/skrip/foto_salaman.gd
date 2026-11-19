extends Node
## Foto salaman pemain + NPC (Raka, 20 Nov 2026 — verifikasi visual
## fitur salaman: pemain jabat tangan Bilal, tangan kanan terulur).
## Layar 1280x720. Jalankan di Xvfb display SEGAR (pola foto_npc_20.gd):
##   Xvfb :96 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-salaman-foto DISPLAY=:96 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_salaman.tscn
## Nama file BARU di v2/foto-npc/ — jangan timpa yang lama.
## JANGAN ubah kode game — skrip foto saja.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-npc/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String) -> void:
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik).timeout


func _bidik(pos: Vector3, target: Vector3) -> void:
	_cam.global_position = pos
	_cam.look_at(target, Vector3.UP)
	await _tunggu(0.5)


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Salaman")
	for i in 5:
		await get_tree().process_frame
	_main._ui.set_hud_visible(false)
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	# Bilal diam di (-4,4), pemain di (-4,6) — berhadapan sumbu z.
	var bilal: Node = _main._bilal
	bilal.global_position = Vector3(-4, 0, 4)
	bilal.set("_target", Vector3(-4, 0, 4))
	bilal.set("_pause_timer", 30.0)
	_main._player.global_position = Vector3(-4, 0, 6)
	await _tunggu(0.5)
	_main._on_aksi("salaman")
	print("FOTO-SALAMAN pemain=%s bilal=%s" % [String(_main._player.aksi_saat_ini()), String(bilal.get("_salaman"))])
	await _tunggu(1.5)
	print("FOTO-SALAMAN saat foto bilal=%s arm_r=%.2f" % [String(bilal.get("_salaman")), float(bilal.get("_arm_r").rotation.x)])
	# Foto 1: samping (profil berhadapan) — kamera dari timur.
	await _bidik(Vector3(0, 1.8, 5), Vector3(-4, 1.0, 5))
	await _foto("salaman-pemain-bilal.png")
	# Foto 2: lebar dari tenggara — konteks plaza Surau.
	await _bidik(Vector3(2, 3.0, 10), Vector3(-4, 1.0, 5))
	await _foto("salaman-pemain-bilal-lebar.png")
	print("FOTO-SALAMAN selesai")
	get_tree().quit(0)
