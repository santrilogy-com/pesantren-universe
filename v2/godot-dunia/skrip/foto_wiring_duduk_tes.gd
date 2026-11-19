extends Node
## Foto verifikasi wiring duduk + adegan tes (Gilang, 20 Nov 2026).
## 3 tangkapan, pola foto_kantor_putra_interior.gd (main.tscn asli +
## kamera lepas, HUD tampil saat penyeberangan pintu):
##   1 pemain duduk di bangku taman 1a lewat jalur asli (✕ DUDUK) —
##      pose duduk_kursi dari depan (paha horizontal, betis vertikal).
##   2a adegan tes: pemain duduk di kursi tes (panel tes terbuka
##      OTOMATIS — bukti panel muncul tanpa tombol MULAI MISI).
##   2b adegan tes, panel ditutup (✕ pertama) — pemain + penguji
##      (Sanusi) duduk berhadapan di seberang meja, dari sisi barat.
## Dijalankan di Xvfb display SEGAR:
##   Xvfb :94 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-wiring-duduk-tes DISPLAY=:94 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_wiring_duduk_tes.tscn
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.
## JANGAN ubah kode game — skrip foto saja.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String) -> void:
	# HUD disembunyikan HANYA saat jepret, langsung ditampilkan
	# lagi — cek pintu butuh HUD tampil. Panel tes (manajer) bukan
	# bagian _hud, jadi tetap tampil di foto 2a.
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
	_main._save["nama"] = "Foto Wiring Duduk"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 6, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "musholla", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Wiring Duduk")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 5:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	_cam.current = true

	# ---------- 1 — duduk bangku taman lewat jalur asli ----------
	_main._teleport_player(Vector3(-3.4, 0, 26.5), 0.0)
	await _tunggu(0.5)
	_main._update_interact_button()
	print("FOTO-CEK ✕ di bangku = %s (harap DUDUK)" % str(_main._ui._interact_btn.text))
	_main._on_interact()
	await _tunggu(1.5)
	print("FOTO-CEK aksi = %s (harap duduk_kursi), kursi = %s" % [str(_main._player.aksi_saat_ini()), str(_main._player.kursi_duduk().get("id", ""))])
	# Bangku 1a yaw 0 = hadap selatan (+z); kamera dari selatan,
	# menatap utara ke pemain yang duduk menghadap kamera.
	await _bidik(Vector3(-3.4, 1.4, 28.6), Vector3(-3.4, 0.8, 25.45))
	await _foto("wiring-duduk-bangku-taman.png")

	# ---------- 2 — masuk kantor putra lewat jalur asli ----------
	_main._on_aksi("berdiri")
	await _tunggu(0.5)
	_main._teleport_player(Vector3(-18, 0, 19.2), PI)
	await _tunggu(1.0)
	print("FOTO-CEK masuk kantor _di_dalam_kantor_putra = %s (harap true)" % str(_main._di_dalam_kantor_putra))
	print("FOTO-CEK penguji duduk_tes = %s (harap true)" % str(_main._sanusi.sedang_duduk_tes()))
	# Berjalan dari spawn ke kursi tes (0,55 m di depannya).
	_main._teleport_player(Vector3(-90, 0, -301.2), 0.0)
	await _tunggu(0.5)
	_main._update_interact_button()
	print("FOTO-CEK ✕ di kursi tes = %s (harap DUDUK)" % str(_main._ui._interact_btn.text))
	_main._on_interact()
	await _tunggu(1.5)
	print("FOTO-CEK aksi = %s (harap duduk_kursi), panel = %s (harap tes)" % [str(_main._player.aksi_saat_ini()), str(_main._manajer_misi.panel_terbuka())])
	# 2a — panel tes terbuka otomatis (dari sisi barat, kedua
	# sosok duduk berhadapan di balik panel).
	await _bidik(Vector3(-92.8, 1.7, -299.8), Vector3(-89.0, 0.9, -299.8))
	await _foto("wiring-tes-panel-otomatis.png")
	# 2b — tutup panel (✕ pertama, tetap duduk), foto adegan bersih.
	_main._on_interact()
	await _tunggu(0.8)
	print("FOTO-CEK sesudah ✕ pertama: panel = '%s' (harap ''), aksi = %s (harap duduk_kursi)" % [str(_main._manajer_misi.panel_terbuka()), str(_main._player.aksi_saat_ini())])
	await _foto("wiring-tes-adegan-duduk.png")
	print("FOTO-SELESAI")
	get_tree().quit()
