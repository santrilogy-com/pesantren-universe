extends Node
## Foto konsep splash portrait 9:16 — varian C (Gilang, 19 Nov 2026).
## Sama seperti foto_splash_konsep.gd bagian C, tapi jendela PORTRAIT
## 720x1280 dan kamera MUNDUR + RENDAH + menengadah sedikit, supaya
## ~25% atas frame adalah LANGIT (ruang untuk judul melengkung di post)
## dan kubah/plakat Surau tidak tertutup judul.
## KONSEP SAJA — tidak ada kode game yang diubah.
## Jalankan (Xvfb privat :98, 720x1280):
##   Xvfb :98 -screen 0 720x1280x24 &
##   DISPLAY=:98 <godot-4.7> --audio-driver Dummy --path . --resolution 720x1280 skrip/foto_splash_portrait.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/konsep/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.make_current()
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	print("SPLASH-PORTR %s: cam=%s | pemain=%s kyai=%s" % [
		nama, str(_cam.global_position),
		str(_main._player.global_position), str(_main._kyai.global_position),
	])
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _sembunyikan_label_nama(node: Node) -> void:
	for l in node.find_children("*", "Label3D", true, false):
		(l as Label3D).visible = false


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(720, 1280)
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto splash portrait")
	for i in 3:
		await get_tree().process_frame
	_main._ui.visible = false
	_main._ui._tutup_rotate_overlay()

	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true

	# --- C PORTRAIT: Kyai + santri di plaza selatan tangga serambi.
	# Posisi sama seperti varian C landscape; kamera mundur (z=12),
	# rendah (y=1.6), bidik sedikit ke ATAS (target y=2.6) supaya
	# langit mengisi ~25% atas frame dan kubah/plakat Surau turun
	# ke tengah frame (tidak tertutup judul melengkung di post).
	var kyai: Node = _main._kyai
	for npc in _main._npcs:
		if npc == kyai:
			continue
		_sembunyikan_label_nama(npc)
		npc.global_position = Vector3(30, 0, 30)
		npc.set_process(false)
	kyai.global_position = Vector3(-1.5, 0, 2.0)
	kyai._visual.rotation.y = 0.0
	kyai._visual.position.y = 0.0
	kyai._visual.rotation.x = 0.0
	for sendi in [kyai._leg_l, kyai._leg_r, kyai._knee_l, kyai._knee_r, kyai._arm_l, kyai._arm_r, kyai._elbow_l, kyai._elbow_r]:
		(sendi as Node3D).rotation = Vector3.ZERO
	var kepala := kyai._rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.y = 0.0
	kyai._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)
	_sembunyikan_label_nama(kyai)
	_main._teleport_player(Vector3(1.0, 0, 2.5), 0.0)
	kyai.set_process(false)
	_main._player.set_process(false)
	for i in 3:
		await get_tree().process_frame
	_sembunyikan_label_nama(_main._player)
	for i in 5:
		await get_tree().process_frame
	print("SPLASH-PORTR C: kyai=%s pemain=%s" % [str(kyai.global_position), str(_main._player.global_position)])
	await _foto("konsep-splash-c-karakter-portrait-mentah.png", Vector3(-0.2, 1.6, 12.0), Vector3(-0.3, 2.6, 1.0))

	LangitDinamis.debug_jam = -1.0
	print("FOTO SPLASH PORTRAIT SELESAI")
	get_tree().quit(0)
