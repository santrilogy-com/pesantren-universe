extends Node
## Foto gubuk santri (Dewa, 17 Nov 2026) — jalankan TANPA --headless:
##   xvfb-run godot --path . skrip/foto_gubuk.tscn -- sebelum
##   xvfb-run godot --path . skrip/foto_gubuk.tscn -- sesudah
## Memakai kamera GAME sendiri (seperti foto_kamera.gd). Lanskap 1280x720
## (game memaksa lanskap — potret 720x1280 memunculkan overlay
## "PUTAR HP-MU" yang menutupi foto; run pertama 17 Nov 17:09-17:19
## WIB kena overlay itu, 4 PNG dihapus + diulang lanskap).
## "sebelum" = keadaan lama: daun pintu ditutup kembali (visual saja,
## collision modul tak kasatmata) — menunjukkan gubuk tak bisa dimasuki.
## "sesudah" = pintu terbuka -110°, pemain naik tangga + di dalam.
## G1 luar depan | G2 di tangga | G3 dalam menghadap pintu | G4 dalam
## menghadap rak. Spring kamera dipendekkan (2,5 m) untuk foto dalam
## supaya kamera tetap di dalam ruangan (tembok memendekkan spring).

const OUT_BASE := "/home/hatch/workspace/pesantren-verse/v2/foto-gubuk/"

var _main: Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var sub: String = args[0] if args.size() > 0 else "sesudah"
	var out_dir := OUT_BASE + sub + "/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto gubuk")
	for i in 3:
		await get_tree().process_frame
	if sub == "sebelum":
		var pivot: Node = _main._pesantren["root"].find_child("GubukMasuk_PintuPivot", true, false)
		if pivot != null:
			(pivot as Node3D).rotation.y = 0.0
	# G1: luar depan — pemain di utara gubuk menghadap +Z (pintu).
	_main._teleport_player(Vector3(26.9, 0, 22), 0.0)
	for i in 90:
		await get_tree().process_frame
	await _foto(out_dir + "G1-luar-depan.png")
	# G2: di tangga — pemain di tengah ramp (y permukaan ~0,46).
	_main._teleport_player(Vector3(26.9, 0.46, 26.5), 0.0)
	for i in 90:
		await get_tree().process_frame
	await _foto(out_dir + "G2-tangga.png")
	# G3+G4: dalam — spring pendek supaya kamera di dalam ruangan.
	_main._spring.spring_length = 2.5
	# G3: pemain di dalam menghadap pintu (-Z): terlihat pintu
	# terbuka + beranda + tangga dari dalam. Pemain digeser ke
	# z=29,2 (dekat pintu) supaya kamera di belakang punya ruang
	# sampai dinding belakang (z=31,5) — run pertama z=30,6 bikin
	# spring tertekan tembok jadi ~0,9 m dan kepala pemain menutup
	# seluruh frame.
	_main._teleport_player(Vector3(26.9, 1.32, 29.2), PI)
	for i in 90:
		await get_tree().process_frame
	await _foto(out_dir + "G3-dalam-pintu.png")
	# G4: pemain di dalam menghadap rak (+X): terlihat rak kitab +
	# tikar di lantai.
	_main._teleport_player(Vector3(26.2, 1.32, 29.5), PI * 0.5)
	for i in 90:
		await get_tree().process_frame
	await _foto(out_dir + "G4-dalam-rak.png")
	print("FOTO GUBUK SELESAI (" + sub + ")")
	get_tree().quit(0)


func _foto(path: String) -> void:
	for i in 5:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(path)
	print("FOTO %s (err=%s)" % [path, str(err)])
