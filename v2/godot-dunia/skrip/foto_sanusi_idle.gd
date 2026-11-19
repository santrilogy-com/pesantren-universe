extends Node
## Foto Sanusi IDLE di Surau + Fatimah di Musholla (Sinta, 19 Nov 2026
## — tindak lanjut temuan lantai Surau y=0,5).
## Sanusi ditempatkan lewat JALUR ASLI (LokasiAcak.pos_dari_id +
## tempatkan_sanusi) supaya foto SEBELUM perbaikan (y=0, tenggelam)
## vs SESUDAH (y=0,5, berdiri di lantai) benar-benar membuktikan
## perbaikannya. Fatimah lewat jalur asli putri (NPCFatimah.tempatkan
## + pos_dari_id_putri("musholla_putri")) — lantai Musholla atas
## y=0,02, jadi ia harus berdiri wajar tanpa perbaikan.
## Jalankan di Xvfb segar (layar 1280x720) — pola --scene + HOME
## terisolasi (JANGAN argumen posisional + --user-dir: malah
## memuat main.tscn):
##   HOME=/tmp/iso-sanusi-idle DISPLAY=:93 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_sanusi_idle.tscn
## Foto: foto-sanusi-idle-{sebelum,sesudah}.png + foto-fatimah-musholla.png.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}
var _mode := "sesudah"


func _foto(nama: String) -> void:
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik).timeout


func _siapkan_main() -> void:
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
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Idle"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Idle")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame


## Arahkan kamera gameplay ke target: pemain disembunyikan (bukan
## subjek foto), kamera di belakang pemain menghadap target.
func _bidik(pos_pemain: Vector3, pos_target: Vector3, yaw: float) -> void:
	_main._player.global_position = pos_pemain
	_main._player.visible = false
	_main._cam_yaw = yaw
	_main._cam_pitch = -0.08
	_main._pos_legal_terakhir = pos_pemain
	for i in 10:
		await get_tree().process_frame
	await _tunggu(1.5)
	print("FOTO-CEK bidik pemain=%s target=%s yaw=%.2f" % [str(pos_pemain), str(pos_target), yaw])


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--sebelum":
			_mode = "sebelum"
	await _siapkan_main()
	# --- 1) Sanusi IDLE di Surau (jalur asli) ---
	var pos_surau: Vector3 = LokasiAcak.pos_dari_id("surau")
	Onboarding.tempatkan_sanusi(_main._sanusi, pos_surau)
	print("FOTO-CEK sanusi pos=%s (lantai visual Surau 0,5)" % str(_main._sanusi.global_position))
	# Pemain di dalam cangkang, 3 m selatan Sanusi, kamera hadap utara.
	# (6 m terlalu jauh: tenggelam 0,5 m tidak terbaca di foto.)
	await _bidik(Vector3(0, 0.5, -11), pos_surau, 0.0)
	await _foto("foto-sanusi-idle-%s.png" % _mode)
	# --- 2) Fatimah di Musholla (jalur asli putri) ---
	var pos_musholla: Vector3 = LokasiAcak.pos_dari_id_putri("musholla_putri")
	NPCFatimah.tempatkan(_main._fatimah, pos_musholla)
	# Gender pemain tetap putra di save — Fatimah sudah ditempatkan
	# langsung (tempatkan() tidak peduli gender pemain); kamera
	# dibidik dari dalam cangkang, 2 m selatan Fatimah.
	_main._save["jenis_kelamin"] = "putra"
	print("FOTO-CEK fatimah pos=%s (lantai Musholla atas 0,02)" % str(_main._fatimah.global_position))
	await _bidik(Vector3(134, 0, -22), pos_musholla, 0.0)
	await _foto("foto-fatimah-musholla-%s.png" % _mode)
	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	print("FOTO-CEK selesai mode=%s" % _mode)
	get_tree().quit(0)
