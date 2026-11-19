extends Node
## Foto penyelidikan teks Arab + ikon di PANEL (Tara, 19 Nov 2026 —
## temuan Mas 15:00: Arab + sebagian ikon di panel tidak terbaca).
## 6 tangkapan, pola foto_ruang_belajar_lebar.gd (main.tscn asli):
##   1 dialog (salam Arab), 2 latihan soal 1 (مَدْرَسَةٌ),
##   3 tes Q4 (يَذْهَبُ), 4 tes umpan "Benar ✓",
##   5 panel misi (★☆ + 🔒 + ✓), 6 panel kualitas (✓ terpilih).
## Dijalankan 2x: normal + FONTCONFIG_FILE=/tmp/empty-fonts.conf
## (tanpa font sistem — meniru web, yang tidak punya fallback).
##   DISPLAY=:97 godot --audio-driver Dummy --path . --resolution 1280x720 skrip/foto_panel_arab.tscn -- --tag=nofallback
## Nama file BARU di v2/foto-ui/ — jangan timpa yang lama.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _tag := "normal"


func _foto(nama: String) -> void:
	for i in 15:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tag="):
			_tag = arg.trim_prefix("--tag=")
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	await _tunggu(5)
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await _tunggu(3)
	var _nama_asli := String(_main._save.get("nama", ""))
	var _jk_asli := String(_main._save.get("jenis_kelamin", "putra"))
	var _outfit_asli := (_main._save.get("outfit", {}) as Dictionary).duplicate()
	var _flag_asli := bool(_main._save.get("petunjuk_tombol_ditutup", false))
	var _onb_asli := (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Panel"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Panel")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	await _tunggu(3)
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	await _tunggu(3)

	# 1 — Dialog misi babak 1 (salam Arab أهلا وسهلا).
	_main._manajer_misi.buka_dialog("putra")
	await _tunggu(30)
	print("FOTO-CEK dialog panel='%s'" % _main._manajer_misi.panel_terbuka())
	await _foto("panel-arab-dialog-%s.png" % _tag)
	_main._manajer_misi.tutup_semua()
	await _tunggu(5)

	# 2 — Ruang Belajar latihan soal 1 (مَدْرَسَةٌ).
	_main._manajer_misi.buka_ruang_belajar("Ust. Sanusi")
	await _tunggu(10)
	_main._manajer_misi._ruang_belajar._ke_langkah(2)
	await _tunggu(10)
	await _foto("panel-arab-latihan-%s.png" % _tag)
	_main._manajer_misi.tutup_semua()
	await _tunggu(5)

	# 3 — Tes kenaikan Q4 (يَذْهَبُ): jawab Q1-Q3 benar (0,0,0).
	_main._manajer_misi.buka_tes("N1")
	await _tunggu(10)
	var tes: TesKenaikanUI = _main._manajer_misi._tes
	var kunci_jawaban := [0, 0, 0, 1]
	for q in 3:
		tes._on_opsi_ditekan(kunci_jawaban[q])
		await _tunggu(3)
		tes._on_kunci_ditekan()
		await _tunggu(3)
		tes._on_kunci_ditekan()
		await _tunggu(5)
	print("FOTO-CEK tes nomor tampil=%d (harap 4)" % tes._nomor_tampil)
	await _foto("panel-arab-tes-q4-%s.png" % _tag)

	# 4 — Umpan "Benar ✓" setelah jawab Q4 benar (jawaban 1).
	tes._on_opsi_ditekan(1)
	await _tunggu(3)
	tes._on_kunci_ditekan()
	await _tunggu(10)
	await _foto("panel-arab-tes-umpan-%s.png" % _tag)
	_main._manajer_misi.tutup_semua()
	await _tunggu(5)

	# 5 — Panel misi: M1 selesai (✓), baris 2 aktif (▶), sisanya
	# terkunci (🔒), deret bintang ★☆.
	_main._manajer_misi.buka_panel_misi({"misi_selesai": ["M1"], "tes_lulus": [], "tugas_selesai": []})
	await _tunggu(10)
	await _foto("panel-arab-panelmisi-%s.png" % _tag)
	_main._manajer_misi.tutup_semua()
	await _tunggu(5)

	# 6 — Panel kualitas: tanda ✓ di mode terpilih.
	_main._ui._toggle_panel_kualitas()
	_main._ui.set_kualitas_mode(_main._kualitas.mode_saat_ini())
	await _tunggu(10)
	await _foto("panel-arab-kualitas-%s.png" % _tag)

	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_asli
	_main._save["onboarding"] = _onb_asli
	SantriSave.save_data(_main._save)
	print("FOTO PANEL ARAB SELESAI tag=%s — save dipulihkan" % _tag)
	get_tree().quit()
