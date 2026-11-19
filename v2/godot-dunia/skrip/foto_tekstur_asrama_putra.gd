extends Node
## Foto RONDE TEKSTUR P2+P6 ASRAMA PUTRA (Arsa, 18 Nov 2026) —
## bukti visual sebelum/sesudah perbaikan fasad barat Asrama Putra:
## P2 jendela lengkung fasad barat + lis emas vertikal sudut,
## P6 plakat "ASRAMA PUTRA" diperbesar.
## 2 shot dari barat (pintu utama), pemain asli, kamera luar:
##   jauh  : pemain (-44,0,10) hadap timur — seluruh fasad 3 lantai
##   dekat : pemain (-41,0,10) hadap timur — plakat + jendela Lt 1
## Jalankan TANPA --headless (headless = save_png null):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_tekstur_asrama_putra.tscn -- --nama=sebelum
##   ... -- --nama=sesudah
## Hanya menyentuh skrip foto ini; TIDAK menyentuh main.gd/ui.gd.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-tekstur-p2p6/"

var _main: Node


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var nama := "sesudah"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nama="):
			nama = a.trim_prefix("--nama=")
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto tekstur asrama putra " + nama)
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	await _foto("asrama-putra-barat-jauh-" + nama, Vector3(-44, 0, 10), PI / 2.0, -0.05)
	await _foto("asrama-putra-barat-dekat-" + nama, Vector3(-41, 0, 10), PI / 2.0, -0.02)
	print("FOTO TEKSTUR ASRAMA PUTRA %s SELESAI" % nama.to_upper())
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
