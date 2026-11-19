extends Node
## Tes UI misi Fase A gelombang 3 (Raka, 18 Nov 2026 — mockup UI misi
## DI-ACC Mas 18:58 WIB: dialog-aqsal-v2, ruang-belajar-v1,
## tes-kenaikan-v1, panel-misi-v1).
## Headless:
##   godot --headless --path . skrip/test_ui_misi.tscn
## Pola test_mesin_kuis.gd: _cek + hitung lulus/gagal, print per butir.
## Mencakup: 3 file data (Wulan), kit gaya+avatar (Dita), 4 panel
## (Sinta/Nusa), manajer + kunci save rb_selesai + wiring main.gd
## (cek sumber — guard regresi).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Cari teks di semua Label di bawah node (rekursif).
func _ada_teks(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	for anak in node.get_children():
		if _ada_teks(anak, cari):
			return true
	return false


func _isi_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _ready() -> void:
	# ---------- A. DataDialogMisi ----------
	var b1 := DataDialogMisi.babak(1, "putra")
	_cek("Dialog: babak 1 putra ada teks", String(b1.get("teks", "")).contains("Ahlan wa sahlan"))
	_cek("Dialog: babak 1 putra 2 pilihan (ke 2 dan 3)", (b1.get("pilihan", []) as Array).size() == 2 and int((b1["pilihan"][0] as Dictionary).get("ke", 0)) == 2 and int((b1["pilihan"][1] as Dictionary).get("ke", 0)) == 3)
	var b1p := DataDialogMisi.babak(1, "putri")
	_cek("Dialog: babak 1 putri menyebut Ustzh. Mariyah", String(b1p.get("teks", "")).contains("Ustzh. Mariyah"))
	_cek("Dialog: babak 1 putri pilihan 1 menyapa Ustadzah", String(((b1p.get("pilihan", []) as Array)[0] as Dictionary).get("teks", "")).contains("Ustadzah"))
	var b5 := DataDialogMisi.babak(5, "putra")
	# TEKA-TEKI (Raka, 18 Nov 2026 — babak 5 baru Laras, DI-ACC Mas
	# 23:03 WIB): dulu 1 pilihan ("Baik, Ustadz. Saya siap belajar."
	# — ulangan babak 1), kini 2 pilihan pamit, keduanya ke -1.
	_cek("Dialog: babak 5 baru 2 pilihan pamit (keduanya ke -1)", (b5.get("pilihan", []) as Array).size() == 2 and int((b5["pilihan"][0] as Dictionary).get("ke", 0)) == -1 and int((b5["pilihan"][1] as Dictionary).get("ke", 0)) == -1)
	_cek("Dialog: babak 5 putra ucapan penutup Kyai (bukan catatan panggung)", String(b5.get("teks", "")).contains("Selamat datang di Pesantren Universe") and not String(b5.get("teks", "")).contains("Penutup —"))
	_cek("Dialog: babak 5 putra pilihan pamit berangkat", String(((b5.get("pilihan", []) as Array)[0] as Dictionary).get("teks", "")).contains("berangkat mencari beliau"))
	_cek("Dialog: babak 5 putri pilihan pamit (Ustadzah)", String(((DataDialogMisi.babak(5, "putri").get("pilihan", []) as Array)[1] as Dictionary).get("teks", "")).contains("Ustadzah"))
	_cek("Dialog: babak 5 putri menyebut Ustzh. Fatimah", String(DataDialogMisi.babak(5, "putri").get("teks", "")).contains("Ustzh. Fatimah"))
	_cek("Dialog: babak 3 aturan pokok (verbatim topik)", String(DataDialogMisi.babak(3).get("teks", "")).contains("Aturan pokok"))
	_cek("Dialog: nomor di luar 1-5 -> {}", DataDialogMisi.babak(0).is_empty() and DataDialogMisi.babak(6).is_empty())
	_cek("Dialog: JUMLAH_BABAK 5", DataDialogMisi.JUMLAH_BABAK == 5)
	_cek("Dialog: pembicara putri = Mariyah / Pengasuh Pesantren Universe", String((DataDialogMisi.PEMBICARA["putri"] as Dictionary).get("nama", "")) == "Ustzh. Mariyah" and String((DataDialogMisi.PEMBICARA["putri"] as Dictionary).get("subjudul", "")).contains("Pesantren Universe"))

	# ---------- B. DataModul01 ----------
	var lat := DataModul01.latihan_soal()
	_cek("Modul01: latihan 5 soal", lat.size() == 5)
	var lat_jawaban := [0, 1, 2, 0, 1]
	var lat_ok := true
	for i in lat.size():
		var s: Dictionary = lat[i]
		if not MesinKuis.soal_valid(s) or int(s.get("jawaban", -1)) != lat_jawaban[i]:
			lat_ok = false
	_cek("Modul01: latihan jawaban [0,1,2,0,1] + valid mesin", lat_ok)
	var kuis := DataModul01.kuis_soal()
	_cek("Modul01: kuis 10 soal", kuis.size() == 10)
	var kuis_jawaban := [0, 0, 0, 1, 2, 0, 1, 1, 2, 0]
	var kuis_ok := true
	for i in kuis.size():
		var s2: Dictionary = kuis[i]
		if not MesinKuis.soal_valid(s2) or int(s2.get("jawaban", -1)) != kuis_jawaban[i]:
			kuis_ok = false
	_cek("Modul01: kuis jawaban persis Modul 01 + valid mesin", kuis_ok)
	_cek("Modul01: Arab qama Muhammadun + 3 kartu kata", DataModul01.MATERI_ARAB == "قَامَ مُحَمَّدٌ" and DataModul01.KARTU_KATA.size() == 3)
	_cek("Modul01: poin 10+15+10 = 35", DataModul01.POIN_MATERI + DataModul01.POIN_LATIHAN + DataModul01.POIN_HAFALAN == 35)

	# ---------- C. DataMisiBagian ----------
	_cek("Bagian: total poin 110, 8 baris", DataMisiBagian.total_poin() == 110 and DataMisiBagian.BARIS.size() == 8)
	var st0 := DataMisiBagian.status_baris({})
	_cek("Bagian: save kosong -> baris 1 aktif, sisanya terkunci", String(st0[0].get("status", "")) == "aktif" and String(st0[1].get("status", "")) == "terkunci" and String(st0[7].get("status", "")) == "terkunci")
	var st1 := DataMisiBagian.status_baris({"misi_selesai": ["M1"]})
	_cek("Bagian: M1 selesai -> N1.1 selesai, N1.2 aktif", String(st1[0].get("status", "")) == "selesai" and String(st1[1].get("status", "")) == "aktif")
	var save_penuh := {"misi_selesai": ["M1", "M2", "M3"], "tes_lulus": ["N1.T"], "tugas_selesai": []}
	var st2 := DataMisiBagian.status_baris(save_penuh)
	_cek("Bagian: M1-M3 + N1.T -> N1.7 dan N1.T selesai", String(st2[6].get("status", "")) == "selesai" and String(st2[7].get("status", "")) == "selesai")
	_cek("Bagian: poin_bagian M1+M2+M3+N1.T = 65", DataMisiBagian.poin_bagian(save_penuh) == 65)
	_cek("Bagian: poin_bagian kosong = 0", DataMisiBagian.poin_bagian({}) == 0)
	_cek("Bagian: tugas belum/sudah selesai", not DataMisiBagian.tugas_selesai({}) and DataMisiBagian.tugas_selesai({"tugas_selesai": ["N1-tugas-1"]}))
	_cek("Bagian: tugas 5 poin (DRAF, menunggu verdict Mas)", int(DataMisiBagian.TUGAS.get("poin", 0)) == 5)

	# ---------- D. GayaMisi + AvatarMisi ----------
	var panel_sb := GayaMisi.gaya_panel()
	_cek("Gaya: panel rim emas 3 + radius 18", panel_sb.border_width_left == 3 and panel_sb.corner_radius_top_left == 18)
	_cek("Gaya: tombol emas Button", GayaMisi.buat_tombol_emas("X") is Button)
	_cek("Gaya: bilah progres max 1, tanpa persen", GayaMisi.buat_bilah_progres() is ProgressBar and GayaMisi.buat_bilah_progres().max_value == 1.0 and not GayaMisi.buat_bilah_progres().show_percentage)
	_cek("Gaya: label Arab Amiri + tab judul emas", GayaMisi.buat_label_arab("قَامَ", 40) is Label and GayaMisi.buat_tab_judul("Tes") is PanelContainer)
	# REGRESI cacat foto ui-misi v1 (Raka, 18 Nov 2026): autowrap di
	# semua label membuat lebar minimum kolaps ke ~0 — tab/pill/
	# footer terjepit 1 px dan teks vertikal huruf-per-huruf.
	_cek("Gaya REGRESI: label tanpa bungkus lebar minimum = lebar teks (96 vs 1)", GayaMisi.buat_label("Ust. Aqsal M", 24, GayaMisi.KREM).get_minimum_size().x > 50 and GayaMisi.buat_label("Ust. Aqsal M", 24, GayaMisi.KREM, true).get_minimum_size().x < 5)
	_cek("Gaya REGRESI: tab judul lebar minimum > 80 (bukan 1 px)", GayaMisi.buat_tab_judul("Ust. Aqsal M").get_minimum_size().x > 80)
	# (Cek pill DRAF dihapus bersama chipnya — keputusan Mas 13:05.)
	_cek("Gaya REGRESI: bungkus=true mengaktifkan autowrap", GayaMisi.buat_label("teks panjang", 16, GayaMisi.KREM, true).autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
	var av := AvatarMisi.new()
	av.atur_tipe("ustadzah")
	_cek("Avatar: tipe ustadzah", av.tipe == "ustadzah")
	av.atur_tipe("ngawur")
	_cek("Avatar: tipe tak dikenal -> kyai", av.tipe == "kyai")
	_cek("Avatar: ukuran minimum 96x96", av.custom_minimum_size == Vector2(96, 96))
	av.queue_free()

	# ---------- E. DialogMisi ----------
	var dlg := DialogMisi.new()
	add_child(dlg)
	_cek("Dialog UI: hidden saat dibuat", not dlg.visible)
	dlg.tampilkan("putra")
	_cek("Dialog UI: tampil + teks babak 1 + footer Babak 1 dari 5", dlg.visible and _ada_teks(dlg, "Ahlan wa sahlan") and _ada_teks(dlg, "Babak 1 dari 5"))
	_cek("Dialog UI: tab nama Ust. Aqsal M + tanpa TEKS DRAF (dihapus Mas 13:05)", _ada_teks(dlg, "Ust. Aqsal M") and not _ada_teks(dlg, "TEKS DRAF"))
	_cek("Dialog UI REGRESI: tab judul tidak kolaps (min width > 80)", (dlg._tab_wadah.get_child(0) as Control).get_minimum_size().x > 80)
	var dlg_selesai_ev: Array = []
	dlg.selesai.connect(func() -> void: dlg_selesai_ev.append(true))
	dlg._on_pilihan_ditekan(2)
	_cek("Dialog UI: pilihan ke 2 -> babak 2", String(dlg._footer_kiri.text) == "Babak 2 dari 5")
	dlg._on_pilihan_ditekan(-1)
	_cek("Dialog UI: ke -1 -> sembunyi + sinyal selesai", not dlg.visible and not dlg_selesai_ev.is_empty())
	var dlg2 := DialogMisi.new()
	add_child(dlg2)
	dlg2.tampilkan("ngawur")
	_cek("Dialog UI: pembicara tak dikenal -> putra", _ada_teks(dlg2, "Ust. Aqsal M"))
	var dlg_ditutup_ev: Array = []
	var dlg2_selesai_ev: Array = []
	dlg2.selesai.connect(func() -> void: dlg2_selesai_ev.append(true))
	dlg2.ditutup.connect(func() -> void: dlg_ditutup_ev.append(true))
	dlg2._on_tutup_ditekan()
	_cek("Dialog UI: tutup -> sembunyi + sinyal ditutup (tanpa selesai)", not dlg2.visible and not dlg_ditutup_ev.is_empty() and dlg2_selesai_ev.is_empty())
	dlg.queue_free()
	dlg2.queue_free()

	# ---------- F. RuangBelajarUI — chat Genshin (Sinta, 19 Nov 2026) ----------
	# UI lama (3 langkah kartu+soal) DIGANTI chat 14 pesan (§7+§8,
	# ACC Mas 15:18); alur penuh (cabang Belum, salah->benar,
	# resume, baca ulang) diuji di test_ruang_belajar_chat.gd —
	# di sini hanya kontrak dasar: tampil, bicara, pilihan, sinyal.
	var rb := RuangBelajarUI.new()
	add_child(rb)
	var save_rb := SantriSave.default_data()
	var rb_langkah: Array = []
	var rb_selesai_ev: Array = []
	var rb_papan: Array = []
	rb.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb_langkah.append([jenis, poin]))
	rb.selesai.connect(func(total: int) -> void: rb_selesai_ev.append(total))
	rb.papan_berubah.connect(func(judul: String, baris: PackedStringArray) -> void: rb_papan.append([judul, baris]))
	rb.set_auto(false)
	rb.tampilkan("Ust. Sanusi", save_rb)
	_cek("RB chat: tampil + node m1 + pengajar + papan NAHWU DASAR", rb.visible and rb.node_saat_ini() == "m1" and _ada_teks(rb, "Ust. Sanusi") and rb_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata"])]])
	_cek("RB chat: TIDAK ADA teks mengetik / penghitung pesan", not _ada_teks(rb, "mengetik") and not _ada_teks(rb, "dari 14"))
	_cek("RB chat: sedang bicara + pilihan BELUM tampil + tombol tidak terkunci", rb.sedang_bicara() and rb._pilihan_box.get_child_count() == 0 and not rb.ada_tombol_terkunci())
	rb._selesaikan_bicara()
	var jml_lanjut := 0
	for c in rb._pilihan_box.get_children():
		if not c.is_queued_for_deletion() and c is Button:
			jml_lanjut += 1
	_cek("RB chat: m1 selesai -> tombol Lanjut tampil, tombol tidak terkunci", not rb.sedang_bicara() and jml_lanjut == 1 and not rb.ada_tombol_terkunci())
	rb._lanjut_pesan()
	_cek("RB chat: lanjut -> node m2 (kalam) + papan KALAM", rb.node_saat_ini() == "m2" and (rb_papan[-1] as Array)[0] == "KALAM")
	rb._selesaikan_bicara()
	var jml_pilihan := 0
	for c in rb._pilihan_box.get_children():
		if not c.is_queued_for_deletion() and c is Button:
			jml_pilihan += 1
	_cek("RB chat: m2 selesai -> 2 pilihan (Paham/Belum) aktif penuh", jml_pilihan == 2 and not rb.ada_tombol_terkunci())
	var opsi_m2: Array = DataChatModul01.cari("m2").get("opsi", [])
	rb._on_opsi_ditekan(opsi_m2[0])
	_cek("RB chat: Paham di m2 -> node m3 + gelembung player tampil", rb.node_saat_ini() == "m3" and rb._gelembung_box.visible)
	rb.tutup()
	_cek("RB chat: tutup() sembunyi tanpa sinyal tambahan", not rb.visible and rb_selesai_ev.is_empty())
	rb.queue_free()

	# ---------- G. TesKenaikanUI ----------
	var tes := TesKenaikanUI.new()
	add_child(tes)
	tes.tampilkan("N1")
	_cek("Tes: tampil N1 + 10 soal + ambang 8, tanpa TEKS DRAF", tes.visible and _ada_teks(tes, "Tes Naik Bagian 2 (N1.T)") and _ada_teks(tes, "8") and not _ada_teks(tes, "TEKS DRAF"))
	var tes_hasil_ev: Array = []
	tes.tes_selesai.connect(func(lulus: bool, skor: int, bagian: String, mesin: MesinKuis) -> void: tes_hasil_ev.append({"lulus": lulus, "skor": skor, "bagian": bagian, "mesin": mesin}))
	for i in 10:
		var s3: Dictionary = DataModul01.kuis_soal()[i]
		tes._on_opsi_ditekan(int(s3.get("jawaban", 0)))
		tes._on_kunci_ditekan()
		tes._on_kunci_ditekan()
	var tes_hasil: Dictionary = tes_hasil_ev[0] if not tes_hasil_ev.is_empty() else {}
	_cek("Tes: 10 benar -> lulus + skor 10 + bagian N1 + mesin diteruskan", bool(tes_hasil.get("lulus", false)) and int(tes_hasil.get("skor", 0)) == 10 and String(tes_hasil.get("bagian", "")) == "N1" and tes_hasil.get("mesin", null) is MesinKuis)
	_cek("Tes: kartu HASIL TES + LULUS tampil", _ada_teks(tes, "HASIL TES") and _ada_teks(tes, "LULUS"))
	# Integrasi Gerbang: catat hasil tes lulus ke save.
	var save_tes := SantriSave.default_data()
	var mesin_lulus: MesinKuis = tes_hasil.get("mesin", null)
	_cek("Tes+Gerbang: catat_tes N1 true + N1/N1.T tercatat", Gerbang.catat_tes(save_tes, "N1", mesin_lulus) and "N1" in (save_tes.get("bagian_lulus", []) as Array) and "N1.T" in (save_tes.get("tes_lulus", []) as Array))
	_cek("Tes+Gerbang: catat ulang tidak duplikat", Gerbang.catat_tes(save_tes, "N1", mesin_lulus) and (save_tes.get("tes_lulus", []) as Array).count("N1.T") == 1)
	tes.tutup()
	# Jalur gagal: semua salah.
	var tes2 := TesKenaikanUI.new()
	add_child(tes2)
	var tes2_hasil_ev: Array = []
	tes2.tes_selesai.connect(func(lulus: bool, skor: int, bagian: String, mesin: MesinKuis) -> void: tes2_hasil_ev.append({"lulus": lulus, "skor": skor}))
	tes2.tampilkan("N1")
	for i in 10:
		var s4: Dictionary = DataModul01.kuis_soal()[i]
		tes2._on_opsi_ditekan((int(s4.get("jawaban", 0)) + 1) % 4)
		tes2._on_kunci_ditekan()
		tes2._on_kunci_ditekan()
	var tes2_hasil: Dictionary = tes2_hasil_ev[0] if not tes2_hasil_ev.is_empty() else {"lulus": true, "skor": -1}
	_cek("Tes: 10 salah -> gagal + skor 0", tes2_hasil.get("lulus", true) == false and int(tes2_hasil.get("skor", -1)) == 0)
	_cek("Tes: kartu BELUM LULUS tampil", _ada_teks(tes2, "BELUM LULUS"))
	tes2.tutup()
	# Bank belum tersedia (N2-N4).
	var tes3 := TesKenaikanUI.new()
	add_child(tes3)
	tes3.tampilkan("N2")
	_cek("Tes: N2 bank belum ada -> 'belum tersedia' tanpa crash", tes3.visible and _ada_teks(tes3, "belum tersedia"))
	tes3.tutup()
	tes.queue_free()
	tes2.queue_free()
	tes3.queue_free()

	# ---------- H. PanelMisiUI ----------
	var pm := PanelMisiUI.new()
	add_child(pm)
	pm.tampilkan({})
	_cek("Panel: tampil + gelar Thalib al-'Ilm + 0 poin", pm.visible and _ada_teks(pm, "Thalib al-'Ilm") and _ada_teks(pm, "0 poin"))
	_cek("Panel: progres 0 dari 7 misi + Bagian 2 terkunci", _ada_teks(pm, "0 dari 7 misi") and _ada_teks(pm, "Bagian 2 (Biru)"))
	var pm_save := {"misi_selesai": ["M1", "M2", "M3"], "tes_lulus": ["N1.T"], "tugas_selesai": [], "poin": 65}
	pm.tampilkan(pm_save)
	_cek("Panel: M1-M3+N1.T -> 65 poin + 3 dari 7 misi (N1.T = baris tes)", _ada_teks(pm, "65 poin") and _ada_teks(pm, "3 dari 7 misi"))
	_cek("Panel: strip tugas Ustadz tampil", _ada_teks(pm, "Tugas dari Ustadz"))
	pm.tutup()
	_cek("Panel: tutup() sembunyi", not pm.visible)
	pm.queue_free()

	# ---------- I. ManajerUIMisi ----------
	var mj := ManajerUIMisi.new()
	add_child(mj)
	_cek("Manajer: awal tidak ada panel terbuka", not mj.ada_panel_terbuka())
	_cek("Manajer: skala layar valid (> 0)", mj._skala_layar() > 0.0)
	mj.buka_dialog("putra")
	var tinggi_dialog := mj._dialog.offset_bottom - mj._dialog.offset_top
	mj.buka_tes("N1")
	var tinggi_tes := mj._tes.offset_bottom - mj._tes.offset_top
	var vp_tes := mj.get_viewport().get_visible_rect().size
	var s_tes := mj._skala_layar()
	var harap_dialog := minf(vp_tes.y * 0.92, maxf(560.0, 560.0 / s_tes))
	var harap_tes := minf(vp_tes.y * 0.92, maxf(1120.0, 1120.0 / s_tes))
	_cek("Manajer: dialog kompak target 560, tes target 1120", is_equal_approx(tinggi_dialog, harap_dialog) and is_equal_approx(tinggi_tes, harap_tes) and tinggi_dialog <= tinggi_tes)
	mj.tutup_semua()
	mj.buka_dialog("putra")
	_cek("Manajer: buka_dialog -> dialog terbuka + dim tampil", mj.ada_panel_terbuka() and mj.panel_terbuka() == "dialog" and mj._dim.visible)
	mj.buka_tes("N1")
	_cek("Manajer: buka_tes ganti panel (dialog tertutup)", mj.panel_terbuka() == "tes" and not mj._dialog.visible)
	var mj_dialog_selesai_ev: Array = []
	mj.dialog_selesai.connect(func() -> void: mj_dialog_selesai_ev.append(true))
	mj.buka_dialog("putri")
	mj._dialog._on_pilihan_ditekan(-1)
	_cek("Manajer: dialog selesai diteruskan + dim ikut mati", not mj_dialog_selesai_ev.is_empty() and not mj._dim.visible and not mj.ada_panel_terbuka())
	mj.buka_ruang_belajar("Ust. Sanusi")
	_cek("Manajer: buka_ruang_belajar -> panel ruang_belajar", mj.panel_terbuka() == "ruang_belajar")
	mj.buka_panel_misi({})
	_cek("Manajer: buka_panel_misi -> panel panel_misi", mj.panel_terbuka() == "panel_misi")
	mj.tutup_semua()
	_cek("Manajer: tutup_semua -> tidak ada panel + dim mati", not mj.ada_panel_terbuka() and not mj._dim.visible)
	mj.queue_free()

	# ---------- J. Kunci save + wiring main.gd (guard regresi) ----------
	_cek("Save: default_data punya rb_selesai (Array)", SantriSave.default_data().has("rb_selesai") and SantriSave.default_data()["rb_selesai"] is Array)
	_cek("Save: default_data punya rb_chat_pos + rb_chat_modul (resume chat)", SantriSave.default_data().has("rb_chat_pos") and SantriSave.default_data().has("rb_chat_modul"))
	var main_src := _isi_file("res://scripts/main.gd")
	_cek("Wiring: main.gd membuat ManajerUIMisi + 4 handler", main_src.contains("ManajerUIMisi.new()") and main_src.contains("_on_manajer_dialog_selesai") and main_src.contains("_on_manajer_rb_langkah") and main_src.contains("_on_manajer_tes_selesai"))
	_cek("Wiring: main.gd routing _buka_ui_misi_terdekat + Panel Misi saat ✕ kosong", main_src.contains("_buka_ui_misi_terdekat()") and main_src.contains("buka_panel_misi(_save)"))
	_cek("Wiring: main.gd langkah 1->2 saat masuk pesantren", main_src.contains("Onboarding.langkah_saat_ini(_save) == 1"))
	_cek("Wiring: adegan belajar chat (§8) — mulai/akhir + papan + resume", main_src.contains("_mulai_adegan_belajar()") and main_src.contains("_akhiri_adegan_belajar()") and main_src.contains("_on_manajer_rb_ditutup") and main_src.contains("_on_manajer_rb_kemajuan") and main_src.contains("_perbarui_papan_belajar"))

	print("TES UI MISI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
