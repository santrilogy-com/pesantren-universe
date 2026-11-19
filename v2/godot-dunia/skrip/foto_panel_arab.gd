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

	# 2 — Ruang Belajar CHAT (v1 Sinta, 19 Nov 16:30): alur chat 14 node,
	# teks transliterasi Latin semua (0 karakter Arab di data chat) —
	# foto node soal l1 untuk membuktikan tidak ada Arab di chat.
	# PERBAIKAN HARNESS (Tara, 19 Nov 2026 — "kotak besar + lingkaran
	# samar" di header chat): skrip ini dulu memanggil
	# buka_ruang_belajar() LANGSUNG tanpa _mulai_adegan_belajar() —
	# HUD tidak disembunyikan, tombol gamepad □/○ menembus kotak
	# dialog 92%-opaque sebagai hantu kotak+lingkaran. Alur game
	# asli selalu memanggil _mulai_adegan_belajar() dulu (main.gd).
	_main._mulai_adegan_belajar()
	_main._manajer_misi.buka_ruang_belajar("Ust. Sanusi")
	await _tunggu(10)
	var rb: RuangBelajarUI = _main._manajer_misi._ruang_belajar
	for i in 16:
		if rb.node_saat_ini() == "l1":
			break
		var nod: Dictionary = rb._node_saat_ini
		rb._selesaikan_bicara()
		await _tunggu(2)
		if String(nod.get("tipe", "")) == "cek":
			var opsi: Array = nod.get("opsi", [])
			if opsi.size() > 0:
				rb._on_opsi_ditekan(opsi[0])
		else:
			rb._lanjut_pesan()
		await _tunggu(3)
	rb._selesaikan_bicara()
	await _tunggu(4)
	print("FOTO-CEK chat node=%s (harap l1)" % rb.node_saat_ini())
	await _foto("panel-arab-chat-l1-%s.png" % _tag)
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
	await _foto("panel-arab-tes-q4-%s.png" % _tag)

	# 4 — Umpan "Benar ✓" setelah jawab Q4 benar (jawaban 1).
	tes._on_opsi_ditekan(1)
	await _tunggu(3)
	tes._on_kunci_ditekan()
	await _tunggu(10)
	print("FOTO-CEK tes nomor tampil=%d (harap 4)" % tes._nomor_tampil)
	await _foto("panel-arab-tes-umpan-%s.png" % _tag)

	# 4b — Riwayat + tombol "Soal Berikutnya" PENUH (perbaikan Tara,
	# 19 Nov 2026): _render() menggulir ke bawah secara tertunda
	# saat umpan tampil — tunggu scroll jalan, lalu foto.
	await _tunggu(12)
	await _foto("panel-ikon-tes-riwayat-%s.png" % _tag)
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
	_main._ui._toggle_panel_kualitas()
	await _tunggu(3)

	# 7 — Panel outfit: centang ikon di swatch terpilih.
	_main._ui.open_outfit(_main._save.get("outfit", {}))
	await _tunggu(10)
	await _foto("panel-ikon-outfit-%s.png" % _tag)
	_main._ui.close_outfit()
	await _tunggu(3)

	# 8 — Panel peta: tombol zoom "+" ASCII.
	_main._on_open_peta()
	await _tunggu(10)
	await _foto("panel-ikon-peta-%s.png" % _tag)
	_main._ui.close_peta()
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
	# baca_daftar_judul() mengembalikan judul latin, BUKAN id —
	# pakai nilai balik baca_buka_buku_id() (bool) sebagai penanda.
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
	print("FOTO PANEL ARAB SELESAI tag=%s — save dipulihkan" % _tag)
	get_tree().quit()
