extends Node
## Foto Interior Kantor Putra BARU + Kantor Ustadzah penataan ulang
## (Gilang, 20 Nov 2026 — konsep tes-di-dalam-kantor Laras, ACC Mas
## 00:37 WIB). 4 tangkapan, pola foto_kantor_putra.gd (main.tscn asli
## + kamera lepas):
##   1 interior putra dari spawn (pintu utara) menghadap selatan —
##      kursi pemain (depan) + meja + kursi penguji + papan selatan.
##   2 interior putra dari tenggara — lemari + rak + jendela timur.
##   3 keluar kantor putra lewat jalur asli (jalan menembus celah
##      pintu dalam -> teleport ke titik keluar (-18,18.5)), lalu
##      masuk lagi lewat jalur asli (siklus penuh).
##   4 interior ustadzah — meja TENGAH + 2 kursi berhadapan.
## Foto 1 + 3 memakai JALUR ASLI masuk/keluar (pemain diteleport ke
## zona pintu luar (-18,19.2) -> _cek_pintu_kantor_putra men-teleport
## masuk; keluar: teleport ke utara celah pintu dalam (-90,-303.2)
## -> _cek_pintu_kantor_putra men-teleport keluar). Foto 4 memakai
## _masuk_kantor() langsung (pintu putri tidak berubah — yang difoto
## hanya penataan ulang perabotnya; pemain putra memang tidak bisa
## jalan ke pintu putri karena _cek_batas).
## PELAJARAN (run pertama, 20 Nov ~01:00): _cek_pintu_* di-gate
## _ui.is_world_visible() == _hud.visible — MENYEMBUNYIKAN HUD
## (set_hud_visible(false)) MEMATIKAN semua cek pintu. Run pertama
## menyembunyikan HUD sebelum foto 1, jadi "masuk lagi" hanya flag
## basi (tidak pernah false sejak foto 1) dan keluar tidak pernah
## jalan. Karena itu HUD HANYA disembunyikan sesaat di dalam _foto()
## (saat jepret), langsung ditampilkan lagi — penyeberangan pintu
## selalu saat HUD tampil.
## Dijalankan di Xvfb display SEGAR:
##   Xvfb :93 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-kantor-putra-interior DISPLAY=:93 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_kantor_putra_interior.tscn
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.
## JANGAN ubah kode game — skrip foto saja.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String) -> void:
	# HUD disembunyikan HANYA saat jepret (foto bersih), langsung
	# ditampilkan lagi — cek pintu butuh HUD tampil (lihat atas).
	_main._ui.set_hud_visible(false)
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
	_main._ui.set_hud_visible(true)


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
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Kantor"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 6, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Kantor")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 5:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	_cam.current = true

	# ---------- 1 — masuk kantor putra lewat jalur asli ----------
	# Zona pintu luar: |x+18| < 1,0 dan 18,5 < z < 20. HUD TAMPIL
	# selama penyeberangan (cek pintu butuh HUD tampil).
	_main._teleport_player(Vector3(-18, 0, 19.2), PI)
	await _tunggu(1.0)
	print("FOTO-CEK masuk kantor putra _di_dalam_kantor_putra = %s (harap true)" % str(_main._di_dalam_kantor_putra))
	print("FOTO-CEK posisi pemain = %s (harap dekat (-90, 0, -301.9))" % str(_main._player.global_position))
	# Dari spawn menghadap selatan: kursi pemain + meja + kursi
	# penguji + papan di dinding selatan.
	await _bidik(Vector3(-90, 2.3, -302.1), Vector3(-90, 0.9, -298.3))
	await _foto("kantor-putra-interior-dalam.png")

	# ---------- 2 — interior putra dari tenggara ----------
	# Lemari barat-daya + rak timur + jendela timur + lampu.
	await _bidik(Vector3(-87.9, 2.1, -298.3), Vector3(-91.8, 1.0, -301.2))
	await _foto("kantor-putra-interior-sudut.png")

	# ---------- 3 — keluar kantor putra lewat jalur asli ----------
	# Masih di dalam dari foto 1: jalan menembus celah pintu dalam
	# ke utara (z -304..-302.5, |x+90| < 1,2) -> teleport keluar.
	_main._teleport_player(Vector3(-90, 0, -303.2), 0.0)
	await _tunggu(1.0)
	print("FOTO-CEK keluar _di_dalam_kantor_putra = %s (harap false)" % str(_main._di_dalam_kantor_putra))
	print("FOTO-CEK posisi pemain = %s (harap dekat (-18, 0, 18.5))" % str(_main._player.global_position))
	await _bidik(Vector3(-13, 3, 17), Vector3(-18, 2, 22))
	await _foto("kantor-putra-interior-keluar.png")

	# ---------- 3b — masuk lagi lewat jalur asli (siklus penuh) ----
	_main._teleport_player(Vector3(-18, 0, 19.2), PI)
	await _tunggu(1.0)
	print("FOTO-CEK masuk lagi _di_dalam_kantor_putra = %s (harap true)" % str(_main._di_dalam_kantor_putra))
	print("FOTO-CEK posisi pemain masuk lagi = %s (harap dekat (-90, 0, -301.9))" % str(_main._player.global_position))
	# Bersihkan flag putra sebelum foto ustadzah (panggilan langsung
	# _masuk_kantor() di bawah tidak membersihkan flag lain — di
	# permainan nyata flag-flag ini eksklusif lewat cek pintu).
	_main._keluar_kantor_putra()
	await _tunggu(0.5)

	# ---------- 4 — interior ustadzah (meja tengah + 2 kursi) ----------
	_main._masuk_kantor()
	await _tunggu(1.0)
	print("FOTO-CEK masuk kantor ustadzah _di_dalam_kantor = %s (harap true)" % str(_main._di_dalam_kantor))
	# Dari spawn (barat) menghadap timur: kursi pemain + meja +
	# kursi penguji berhadapan.
	await _bidik(Vector3(-123.3, 2.3, -300), Vector3(-118.0, 0.9, -300))
	await _foto("kantor-ustadzah-interior-baru.png")
	_main._keluar_kantor()
	await _tunggu(1.0)
	print("FOTO-CEK keluar kantor ustadzah _di_dalam_kantor = %s (harap false)" % str(_main._di_dalam_kantor))
	print("FOTO-SELESAI")
	get_tree().quit()
