extends Node
## Foto Kantor Putra SEMENTARA (Gilang, 19 Nov 2026 — perintah Mas
## 18:09 WIB "Bikin kantor putra sementara").
## 4 tangkapan, pola foto_npc_20.gd (main.tscn asli + kamera lepas):
##   1 kantor dari plaza (plakat KANTOR + Surau di samping),
##   2 kantor dekat (plakat + pintu jati),
##   3 panel Tes Kenaikan TERBUKA lewat jalur asli langkah 6
##      (pemain di venue (-11,0) -> _buka_ui_misi_terdekat()),
##   4 panel misi (baris N1.T "Tes Naik Bagian 2 — Kantor").
## Dijalankan di Xvfb display SEGAR:
##   Xvfb :93 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-kantor-putra DISPLAY=:93 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_kantor_putra.tscn
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.
## JANGAN ubah kode game — skrip foto saja.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

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

	# ---------- 1+2 — kantor dari luar (HUD sembunyi) ----------
	_main._ui.set_hud_visible(false)
	await _bidik(Vector3(-2, 5, 14), Vector3(-11, 1.5, -4))
	await _foto("kantor-putra-plaza.png")
	await _bidik(Vector3(-8, 2.5, 6), Vector3(-11, 2.2, -2))
	await _foto("kantor-putra-dekat.png")

	# ---------- 3 — tes terbuka lewat jalur asli langkah 6 ----------
	# Pemain diteleport ke venue baru (-11,0) lalu tombol aksi
	# ditekan lewat _buka_ui_misi_terdekat() — persis jalur game.
	var venue: Vector3 = Onboarding.venue_tes("putra")
	print("FOTO-CEK venue_tes putra = %s (harap (-11, 0, 0))" % str(venue))
	_main._teleport_player(venue, 0.0)
	await _tunggu(1.0)
	var jarak: float = _main._player.global_position.distance_to(venue)
	print("FOTO-CEK jarak pemain->venue = %.2f (batas 3,5)" % jarak)
	_main._ui.set_hud_visible(true)
	await _bidik(Vector3(-11, 2.5, 8), Vector3(-11, 1.5, -4))
	var dibuka: bool = _main._buka_ui_misi_terdekat()
	await _tunggu(1.0)
	print("FOTO-CEK _buka_ui_misi_terdekat() = %s, panel='%s' (harap true/tes)" % [str(dibuka), _main._manajer_misi.panel_terbuka()])
	await _foto("kantor-putra-tes.png")
	_main._manajer_misi.tutup_semua()
	await _tunggu(0.5)

	# ---------- 4 — panel misi (baris N1.T) ----------
	# N1.T ada di bawah lipatan (baris ke-8): gulung panel ke bawah
	# dulu supaya baris tes kelihatan di foto.
	_main._manajer_misi.buka_panel_misi(_main._save)
	await _tunggu(1.0)
	print("FOTO-CEK panel misi terbuka='%s' (harap panel_misi)" % _main._manajer_misi.panel_terbuka())
	_main._manajer_misi._panel_misi._gulung.scroll_vertical = 10000
	await _tunggu(0.5)
	await _foto("kantor-putra-panelmisi.png")
	print("FOTO-SELESAI")
	get_tree().quit()
