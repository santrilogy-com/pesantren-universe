extends Node
## Foto SISAN panel ikon (Tara, 19 Nov 2026): run foto_panel_arab.gd
## mentok timeout 900 dtk di tengah jalan (VM lambat, fps ~7.5 di
## Xvfb) — 9 dari 11 foto sudah jadi. Skrip ini hanya mengambil 2
## yang kurang: 9 dashboard Kartu Santri + 10 reader buku.
## Pola/setup sama seperti foto_panel_arab.gd (save dibackup +
## dipulihkan, tag --tag=web untuk nama file).
##   DISPLAY=:95 godot --path . --resolution 1280x720 skrip/foto_panel_ikon_sisa.tscn -- --tag=web

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

	# 9 — Dashboard Kartu Santri: daftar khataman ("• SEDANG
	# BERLANGSUNG" hanya bila ada sesi aktif saat foto diambil —
	# glif • sendiri sudah terbukti render di foto tes "Benar 4 •
	# Salah 0"; foto ini bukti panel tidak rusak).
	_main._on_open_dashboard()
	await _tunggu(10)
	await _foto("panel-ikon-dashboard-%s.png" % _tag)
	_main._ui.close_dashboard()
	await _tunggu(3)

	# 10 — Reader buku: tombol "‹ Sebelumnya" / "Berikutnya ›" +
	# zona tap ‹ › (buku lokal "puisi-chairil-anwar-pilihan",
	# pola foto_baca_buku.gd; server boleh gagal — buku lokal
	# tetap ada di daftar).
	_main._ui.open_baca_buku()
	var status_baca := ""
	for i in 30:
		status_baca = _main._ui.baca_status_server()
		if status_baca == "ok" or status_baca == "gagal":
			break
		await get_tree().create_timer(0.5).timeout
	if status_baca == "gagal":
		_main._ui.open_baca_buku()
		for i in 30:
			status_baca = _main._ui.baca_status_server()
			if status_baca == "ok" or status_baca == "gagal":
				break
			await get_tree().create_timer(0.5).timeout
	print("FOTO-CEK baca status=%s judul=%s" % [status_baca, str(_main._ui.baca_daftar_judul())])
	if _main._ui.baca_buka_buku_id("puisi-chairil-anwar-pilihan"):
		await _tunggu(5)
		_main._ui.baca_buka_bagian(1)
		await _tunggu(8)
		await _foto("panel-ikon-baca-%s.png" % _tag)
	else:
		print("FOTO-CEK baca: buku lokal tidak ada di daftar — foto reader DILEWAT")
	_main._ui.close_baca_buku()
	await _tunggu(3)

	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_asli
	_main._save["onboarding"] = _onb_asli
	SantriSave.save_data(_main._save)
	print("FOTO PANEL IKON SISA SELESAI tag=%s — save dipulihkan" % _tag)
	get_tree().quit()
