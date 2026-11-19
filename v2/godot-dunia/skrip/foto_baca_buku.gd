extends Node
## Foto bukti fitur BACA BUKU (Tara, 17 Nov 2026) — jalankan TANPA --headless:
##   xvfb-run -a ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_baca_buku.tscn
## Lanskap 1280x720 (game memaksa lanskap). Hasil di v2/foto-baca-buku/:
##   F1-rak-tombol.png (rak + tombol BACA KITAB), F2-daftar-buku.png
##   (7 buku: 5 kitab server + 2 lokal), F3-halaman-teks-latin.png
##   (puisi "Aku"), F4-halaman-teks-arab.png (Jurumiyah bab 1),
##   F5-halaman-gambar.png (atlas masterplan v2).
## Portrait (bukti responsif layar penuh): BACA_FOTO_UKURAN=720x1280
##   BACA_FOTO_SUFIKS=-portrait — hasil F1..F5-portrait.png.
## Fetch server DITUNGGU sampai ok (retry 1x bila gagal — fetch
## pertama bisa timeout saat beban VM tinggi); F4 baru dibuka setelah
## "Jurumiyah" ada di daftar (jangan asal buka bab 0).

const OUT_BASE := "/home/hatch/workspace/pesantren-verse/v2/foto-baca-buku/"

var _main: Node
var _sufiks := ""


func _foto(nama: String) -> void:
	for i in 5:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_BASE + nama + _sufiks + ".png")
	print("FOTO %s (err=%s)" % [nama + _sufiks + ".png", str(err)])


func _tunggu_status_server() -> String:
	for i in 30:
		var s: String = _main._ui.baca_status_server()
		if s == "ok" or s == "gagal":
			return s
		await get_tree().create_timer(0.5).timeout
	return _main._ui.baca_status_server()


## Buka daftar + tunggu fetch server (retry 1x bila gagal).
func _buka_daftar_tunggu_server() -> String:
	_main._ui.open_baca_buku()
	var s := await _tunggu_status_server()
	if s == "gagal":
		print("FOTO: fetch gagal, coba lagi sekali")
		_main._ui.open_baca_buku()
		s = await _tunggu_status_server()
	return s


func _tunggu_kitab(jumlah_min: int) -> bool:
	for i in 30:
		var bab: Array = _main._ui._baca_buku.get("bab", [])
		if bab.size() >= jumlah_min:
			return true
		await get_tree().create_timer(0.5).timeout
	return (_main._ui._baca_buku.get("bab", []) as Array).size() >= jumlah_min


func _tunggu_judul(judul: String) -> bool:
	for i in 40:
		if _main._ui.baca_daftar_judul().has(judul):
			return true
		if _main._ui.baca_status_server() == "gagal":
			_main._ui.open_baca_buku()
		await get_tree().create_timer(0.5).timeout
	return _main._ui.baca_daftar_judul().has(judul)


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_BASE)
	var ukuran := Vector2i(1280, 720)
	var env_ukuran := OS.get_environment("BACA_FOTO_UKURAN")
	if env_ukuran != "":
		var bagian := env_ukuran.split("x")
		if bagian.size() == 2:
			ukuran = Vector2i(int(bagian[0]), int(bagian[1]))
			_sufiks = OS.get_environment("BACA_FOTO_SUFIKS")
	get_window().size = ukuran
	print("FOTO: ukuran jendela = " + str(ukuran) + ", sufiks = '" + _sufiks + "'")
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Foto baca buku")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# Masuk Surau, berdiri 1,5 m di timur rak barat, menghadap rak.
	_main._masuk_surau()
	for i in 3:
		await get_tree().process_frame
	var rak_barat: Vector3 = _main._rak_spots[0]
	_main._teleport_player(rak_barat + Vector3(1.5, 0, 0), -PI / 2.0)
	for i in 40:
		await get_tree().process_frame
	# F1: rak + tombol BACA KITAB (panel belum dibuka).
	await _foto("F1-rak-tombol")
	# F2: daftar buku (5 kitab server + 2 lokal).
	var status := await _buka_daftar_tunggu_server()
	print("FOTO: status server = " + status + ", daftar = " + str(_main._ui.baca_jumlah_daftar()))
	for i in 6:
		await get_tree().process_frame
	await _foto("F2-daftar-buku")
	# F3: halaman teks Latin — puisi "Aku" (bab 2).
	_main._ui.baca_buka_buku_id("puisi-chairil-anwar-pilihan")
	for i in 5:
		await get_tree().process_frame
	_main._ui.baca_buka_bagian(1)
	await _foto("F3-halaman-teks-latin")
	# F4: halaman teks Arab — Jurumiyah bab 1 (tunggu ada di daftar).
	_main._ui.open_baca_buku()
	for i in 3:
		await get_tree().process_frame
	var ada := await _tunggu_judul("Jurumiyah")
	print("FOTO: Jurumiyah di daftar = " + str(ada))
	_main._ui.baca_buka_buku_id("jurumiyah")
	var ok := await _tunggu_kitab(25)
	print("FOTO: Jurumiyah termuat = " + str(ok))
	_main._ui.baca_buka_bagian(0)
	await _foto("F4-halaman-teks-arab")
	# F5: halaman gambar — atlas masterplan v2 hal. 1.
	_main._ui.open_baca_buku()
	for i in 3:
		await get_tree().process_frame
	_main._ui.baca_buka_buku_id("atlas-pesantren-verse")
	for i in 5:
		await get_tree().process_frame
	_main._ui.baca_buka_bagian(0)
	await _foto("F5-halaman-gambar")
	_main._ui.close_baca_buku()
	print("FOTO BACA BUKU SELESAI")
	get_tree().quit(0)
