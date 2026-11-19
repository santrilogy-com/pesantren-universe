extends Node
## Foto ULANG audit tekstur (Gilang, 18 Nov 2026) — perbaiki shot yang
## lemah di ronde pertama: pemain menutupi pintu/plakat, kamera
## kejepit dinding (asrama-putri), sudut kurang bagus (gerbang,
## kantor, pos jaga). Posisi digeser dari sumbu pintu + nama pemain
## diganti "Gilang" (foto ronde 1 memakai nama sisa save tes MP).
## Jalankan TANPA --headless:
##   DISPLAY=:99 godot --path . skrip/foto_audit_tekstur_ulangi.tscn -- --gender putra
##   DISPLAY=:99 godot --path . skrip/foto_audit_tekstur_ulangi.tscn -- --gender putri

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-audit-tekstur/"

const SHOT_PUTRA := [
	["asrama-putra-2", Vector3(-44, 0, 12.5), PI / 2.0, -0.05],
	["cangkruk-putra-2", Vector3(-20, 0, -6), PI, -0.05],
	["gerbang-tembok-2", Vector3(8, 0, 0), PI / 2.0, -0.05],
	["pos-jaga-putra-2", Vector3(-40, 0, -31), PI, -0.05],
]

const SHOT_PUTRI := [
	["asrama-putri-2", Vector3(140, 0, 17), 2.16, -0.05],
	["kantor-2", Vector3(138, 0, -40), 0.71, -0.05],
	["pos-jaga-tl-2", Vector3(176, 0, -15), PI, -0.05],
	["studio-utara", Vector3(166, 0, -22), PI, -0.05],
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
	_main._masuk_pesantren("Foto audit tekstur ulangi " + gender)
	for i in 3:
		await get_tree().process_frame
	_main._player.set_nama("Gilang")
	_main._audio.mulai()
	for s in shots:
		await _foto(s[0], s[1], s[2], s[3])
	print("FOTO AUDIT TEKSTUR ULANGI %s SELESAI" % gender.to_upper())
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
