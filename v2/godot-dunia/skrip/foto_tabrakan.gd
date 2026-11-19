extends Node
## Foto tabrakan (Bagas, 18 Nov 2026) — jalankan TANPA --headless:
##   xvfb-run godot --path . skrip/foto_tabrakan.tscn [-- N]
## N = nomor foto pertama (1-5, default 1) — untuk retake sebagian.
## Pemain didorong ke objek dan TERTAHAN — posisi berhenti memakai
## nilai "akhir" probe fix3 (head-on, bukan tebakan). F1 lampu jalan |
## F2 pohon rindang | F3 pagar bata | F4 bangku taman 2 | F5 pilar
## barat Musholla. Memakai kamera GAME sendiri (seperti
## foto_gubuk.gd). Lanskap 1280x720 (game memaksa lanskap).
## Siang paksa (LangitDinamis.debug_jam = 10, cerah) — foto malam
## pertama F2/F5 terlalu gelap, F3/F4 tertutup pohon/kepala.
## Yaw: 0 = menghadap +Z (selatan), PI = -Z (utara), PI/2 = +X (timur).

const OUT_BASE := "/home/hatch/workspace/pesantren-verse/v2/foto-tabrakan/"

var _main: Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var mulai: int = int(args[0]) if args.size() > 0 else 1
	DirAccess.make_dir_recursive_absolute(OUT_BASE)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Siang paksa untuk foto (hook resmi tes/foto di LangitDinamis).
	LangitDinamis.debug_jam = 10.0
	LangitDinamis.debug_kondisi = "cerah"
	_main._save["role"] = "keamanan"
	_main._masuk_pesantren("Foto tabrakan")
	for i in 3:
		await get_tree().process_frame
	# Pintu taman ditahan terbuka (F4 di dalam taman).
	var pintu: Node = _main._pesantren["root"].find_child("PintuTaman", true, false)
	if pintu != null and pintu.has_method("set_tahan_terbuka"):
		pintu.set_tahan_terbuka(true)
	if mulai <= 1:
		# F1: lampu jalan (-2.5,10) — pemain di selatan lampu,
		# menghadap utara (akhir fix3: (-2.5, 10.42)).
		_main._teleport_player(Vector3(-2.5, 0, 10.42), PI)
		for i in 90:
			await get_tree().process_frame
		await _foto(OUT_BASE + "F1-lampu-jalan.png")
	if mulai <= 2:
		# F2: pohon rindang (35,5) — pemain di barat pohon, menghadap
		# timur (akhir fix3: (34.42, 5.0)).
		_main._teleport_player(Vector3(34.42, 0, 5.0), PI * 0.5)
		for i in 90:
			await get_tree().process_frame
		await _foto(OUT_BASE + "F2-pohon-rindang.png")
	# CATATAN KAMERA: panjang spring DINAMIS (kamera.gd: default 7 m,
	# memendek bila raycast kena penghalang; set manual ditimpa tiap
	# frame). Jadi posisi foto dipilih supaya sumbu kamera 7 m
	# tidak menabrak pohon: F3 di ujung timur pagar (x=-16, bukan
	# -30 — pohon (-30,34) tepat di sumbu kamera), F4 bangku 1
	# (kamera dari selatan, bukan dari barat — pohon taman (-2,2,27,4)
	# tepat di sumbu kamera barat bangku 2).
	if mulai <= 3:
		# F3: pagar bata (-16,39) ujung timur — pemain di utara
		# pagar, menghadap selatan (akhir fix3: (-16, 38.44)).
		_main._teleport_player(Vector3(-16, 0, 38.44), 0.0)
		for i in 90:
			await get_tree().process_frame
		await _foto(OUT_BASE + "F3-pagar-bata.png")
	if mulai <= 4:
		# F4: bangku taman 2 (3.45,28.2), muka SELATAN — pemain di
		# selatan bangku, menghadap utara (muka selatan 29,1+0,35).
		# Pitch curam (-0,7) supaya bangku (rendah, 0,5 m) terlihat
		# melewati kaki pemain — bidikan head-on biasa menyembunyikan
		# bangku tepat di belakang badan pemain. (Bangku 1 gagal:
		# kanopi pohon taman (-2,2,27,4) tepat di sumbu kamera.)
		_main._teleport_player(Vector3(3.45, 0, 29.45), PI)
		_main._cam_pitch = -0.7
		for i in 90:
			await get_tree().process_frame
		await _foto(OUT_BASE + "F4-bangku-taman.png")
	if mulai <= 5:
		# F5: pilar barat Musholla (128.3,-28.7) — pemain di barat
		# pilar, menghadap timur, digeser 0,5 m ke utara (-28,2)
		# supaya pilar terlihat di kanan pemain (offset 0,3 m
		# masih menyembunyikan pilar di belakang bahu pemain).
		_main._teleport_player(Vector3(127.79, 0, -28.2), PI * 0.5)
		for i in 90:
			await get_tree().process_frame
		await _foto(OUT_BASE + "F5-pilar-musholla.png")
	print("FOTO TABRAKAN SELESAI (mulai=%d)" % mulai)
	get_tree().quit(0)


func _foto(path: String) -> void:
	for i in 5:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(path)
	print("FOTO %s (err=%s)" % [path, str(err)])
