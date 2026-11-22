extends Node
## Foto Ruang Belajar landscape SEBELUM/SESUDAH dilebarkan (Wulan,
## 19 Nov 2026 — permintaan Mas 12:48 WIB: Ruang Belajar full screen
## / lebih lebar biar enak dibaca).
## Membuka Ruang Belajar langsung via manajer (langkah Materi lalu
## Latihan), layar landscape 1280x720.
## Jalankan di Xvfb :96 (layar 1280x720):
##   DISPLAY=:96 godot --path . skrip/foto_ruang_belajar_lebar.tscn -- --prefix=ruang-belajar-sebelum
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}
var _prefix := "ruang-belajar"


func _foto(nama: String) -> void:
	for i in 15:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--prefix="):
			_prefix = arg.trim_prefix("--prefix=")
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
	# SIMPAN save asli (pola foto_ui_misi_v2.gd — jangan kontaminasi
	# santri.json; dipulihkan sebelum quit).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	# ISOLASI: putra, flag petunjuk true (pop-up tidak menutupi foto).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Misi"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Misi")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame

	# Materi (n1-n2 bicara) — adegan belajar dulu (ustadz duduk +
	# papan tulis + kamera dialog), lalu buka chat.
	_main._mulai_adegan_belajar()
	_main._manajer_misi.buka_ruang_belajar("Ust. Sanusi", _main._save)
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK materi: panel='%s' (harap ruang_belajar)" % _main._manajer_misi.panel_terbuka())
	await _foto(_prefix + "-materi.png")
	# Latihan (soal l1) — jalan manual ke l1 (lanjut n1->n5, lalu l1).
	var rb_lebar = _main._manajer_misi._ruang_belajar
	for i in range(5):
		rb_lebar._selesaikan_bicara()
		rb_lebar._lanjut_pesan()
	rb_lebar._selesaikan_bicara()
	for i in 10:
		await get_tree().process_frame
	await _foto(_prefix + "-latihan.png")
	_main._manajer_misi.tutup_semua()

	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	SantriSave.save_data(_main._save)
	print("FOTO RUANG BELAJAR SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
