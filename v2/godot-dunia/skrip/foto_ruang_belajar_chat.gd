extends Node
## Foto Ruang Belajar TEKS (Sinta, 22 Nov 2026 — keputusan Mas
## 16:03: misi pindah dari VIDEO ke TEKS, lanjut MANUAL).
## Membuka dialog belajar via adegan (ustadz DUDUK + papan tulis
## kecil + kamera dialog + HUD sembunyi), layar 1280x720.
## Jalankan di Xvfb :96 (layar 1280x720) — pola jalan tes yang
## benar (--scene + HOME terisolasi; argumen posisional + --user-dir
## malah memuat main.tscn):
##   HOME=/tmp/iso-rb-foto DISPLAY=:96 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_ruang_belajar_chat.tscn
##   HOME=/tmp/iso-rb-foto DISPLAY=:96 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_ruang_belajar_chat.tscn -- --putri
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.
## Foto: n1 bicara, n2 bicara (papan KALAM), n2 tombol Lanjut, l1 soal.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}
var _putri := false


func _foto(nama: String) -> void:
	# Tunggu singkat berbasis WAKTU NYATA (bukan frame: FPS di
	# Xvfb rendah, 15 frame bisa jadi detik-detik) agar render
	# sempat settle tanpa efek bicara keburu jalan jauh.
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(detik: float) -> void:
	# Waktu nyata (create_timer), BUKAN jumlah frame.
	await get_tree().create_timer(detik).timeout


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--putri":
			_putri = true
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
	# SIMPAN save asli (pola foto_ruang_belajar_lebar.gd — jangan
	# kontaminasi santri.json; dipulihkan sebelum quit).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	# ISOLASI: flag petunjuk true (pop-up tidak menutupi foto).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putri" if _putri else "putra"
	_main._save["nama"] = "Foto Misi"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	# Foto SELALU dari n1 — hapus posisi resume (RB menyimpan
	# rb_chat_pos ke save selama jalan; tanpa reset, run berikut
	# me-resume di l1/l2, bukan n1).
	_main._save["rb_chat_pos"] = ""
	_main._save["rb_chat_modul"] = 0
	_main._save["rb_fase"] = ""
	_main._save["rb_node_terakhir"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Misi")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame
	# Tempatkan pengajar + pemain berhadapan (4 m) di area terbuka.
	var guru: Node = _main._fatimah if _putri else _main._sanusi
	var pos_guru := Vector3(140, 0, 16) if _putri else Vector3(0, 0, -14)
	guru.position = pos_guru
	_main._player.global_position = pos_guru + Vector3(0, 0, 4)
	_main._pos_legal_terakhir = pos_guru + Vector3(0, 0, 4)
	for i in 10:
		await get_tree().process_frame
	var awalan := "foto-rb-chat-fatimah" if _putri else "foto-rb-chat-sanusi"
	var pengajar := "Ustzh. Fatimah" if _putri else "Ust. Sanusi"
	# Buka adegan belajar + dialog. Lanjut MANUAL — tidak ada Auto
	# yang menekan Lanjut sendiri (dihapus 22 Nov), node tidak
	# akan lari sebelum foto.
	_main._mulai_adegan_belajar()
	_main._manajer_misi.buka_ruang_belajar(pengajar, _main._save)
	var rb = _main._manajer_misi._ruang_belajar
	print("FOTO-CEK buka: panel='%s' adegan=%s guru_duduk=%s" % [_main._manajer_misi.panel_terbuka(), str(_main._dialog_adegan_aktif), str(guru.sedang_duduk_belajar())])
	# n1 sedang bicara (teks progresif + kursor, tanpa pilihan).
	await _tunggu(1.5)
	print("FOTO-CEK n1: node='%s' bicara=%s" % [rb.node_saat_ini(), str(rb.sedang_bicara())])
	await _foto(awalan + "-n1-bicara-meja.png")
	# n2 sedang bicara (papan KALAM): selesaikan n1, tekan Lanjut.
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	await _tunggu(1.2)
	print("FOTO-CEK n2: node='%s' bicara=%s" % [rb.node_saat_ini(), str(rb.sedang_bicara())])
	await _foto(awalan + "-n2-bicara-meja.png")
	# n2 selesai -> tombol Lanjut tampil aktif penuh (tanpa cabang).
	rb._selesaikan_bicara()
	await _tunggu(0.5)
	print("FOTO-CEK n2 lanjut: node='%s' bicara=%s" % [rb.node_saat_ini(), str(rb.sedang_bicara())])
	await _foto(awalan + "-n2-lanjut-meja.png")
	# Jalan ke l1 (manual): Lanjut n3, n4, n5, lalu l1.
	for i in range(4):
		rb._selesaikan_bicara()
		rb._lanjut_pesan()
	await _tunggu(0.5)
	print("FOTO-CEK l1: node='%s' bicara=%s" % [rb.node_saat_ini(), str(rb.sedang_bicara())])
	rb._selesaikan_bicara()
	await _tunggu(0.5)
	await _foto(awalan + "-l1-soal-meja.png")
	_main._manajer_misi.tutup_semua()

	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	SantriSave.save_data(_main._save)
	print("FOTO RUANG BELAJAR CHAT SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
