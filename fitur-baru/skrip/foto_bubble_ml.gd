extends Node
## Foto BUBBLE-ML (Gita, 17 Nov 2026). Dijalankan sebagai SCENE:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --resolution 1280x720 \
##     --path . foto_bubble_ml.tscn
## (TANPA --headless — headless membuat save_png null.)
## Jam dibekukan 10.00 (pagi). Kamera dari depan pemain supaya karakter
## + feed di sebelah analog sama-sama terlihat.
## B1: 1 baris — pesan pemain di feed. B2: 3 baris menumpuk — pesan
## pemain + 2 NPC (paling MLBB: terbaru di bawah, yang lama naik).
## SYARAT: patch ui_feed_ml.patch SUDAH dipasang di scripts/ui.gd
## (GO Cakra) — kalau belum, skrip berhenti dengan pesan jelas (exit 2).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/fitur-baru/foto/"

var _main: Node
var _ui: Node
var _cam: Camera3D


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_ui = _main._ui
	if not _ui.has_method("tampilkan_pesan_melayang"):
		print("FOTO BUBBLE-ML DIBATALKAN: feed belum ada — pasang dulu patch ui_feed_ml.patch (menunggu GO Cakra).")
		get_tree().quit(2)
		return
	# Masuk langsung TANPA login server (pola foto_cuaca.gd).
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes foto bubble ML")
	await get_tree().process_frame
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Kamera dari depan pemain (pemain menghadap kamera) — karakter
	# terlihat di tengah frame, feed HUD di kiri bawah di atas joystick.
	var p: Vector3 = _main._player.global_position
	_cam.global_position = p + Vector3(2.5, 2.0, 5.5)
	_cam.look_at(p + Vector3(0, 1.3, 0), Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	# B1: pesan pemain saja. Pesan dikirim SETELAH kamera settle, lalu
	# foto diambil hanya 3 frame kemudian — baris feed hidup 4 dtk,
	# dan di xvfb (render software, ~1-2 fps) 40 frame = puluhan detik
	# waktu game, jadi pesan akan kedaluwarsa sebelum difoto kalau
	# menunggu lama (pelajaran dari run tes pertama).
	_ui.tampilkan_pesan_melayang("Tes", "Assalamu'alaikum! Ayo selesaikan misinya.")
	await _foto("B1-pesan-pemain.png")
	# B2: + 2 pesan NPC (total 3 baris menumpuk; semua masih dalam 4 dtk).
	_ui.tampilkan_pesan_melayang("Bilal", "Wa'alaikumsalam! Aku baru buka Peti Kayu.")
	_ui.tampilkan_pesan_melayang("Ust. Aqsal Murad", "Ayo sholat berjamaah — saya jadi imam.")
	await _foto("B2-pesan-npc.png")
	print("FOTO BUBBLE-ML SELESAI")
	get_tree().quit(0)


func _foto(nama: String) -> void:
	# Hanya 3 frame: cukup untuk layout + 1 render, tapi jauh di bawah
	# umur baris 4 dtk walau fps xvfb rendah (lihat _ready).
	for i in 3:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
