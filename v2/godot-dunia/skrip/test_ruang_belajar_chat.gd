extends Node
## Tes Ruang Belajar CHAT Genshin (Sinta, 19 Nov 2026 — konsep
## KONSEP-RUANG-BELAJAR-CHAT-v1.md §7+§8, ACC Mas 15:18).
## Cakupan: DataChatModul01 (14 pesan + cabang Belum + poin 35),
## alur penuh chat (Paham / Belum 2x / salah->benar), resume
## (rb_chat_pos), baca ulang tanpa poin, ustadz DUDUK (npc.gd),
## papan tulis mengikuti pesan, TIDAK ADA "mengetik", TIDAK ADA
## penghitung "Pesan X dari 14", tombol tidak pernah terkunci,
## AvatarMisi Sanusi peci hitam nasional, manajer (panel bawah +
## dim transparan + chip Auto).
## Headless (user-dir TERISOLASI — jangan pakai save VM):
##   godot --headless --path . --user-dir /tmp/test-rb-chat/ skrip/test_ruang_belajar_chat.tscn
## Pola test_ui_misi.gd: _cek + hitung lulus/gagal, EXIT 0 bila
## semua lulus. Alur digerakkan sinkron (auto OFF + _selesaikan_
## bicara() manual — timer bicara tidak ditunggu).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Cari teks di semua Label/Button/RichTextLabel di bawah node.
func _ada_teks(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	if node is Button and String((node as Button).text).contains(cari):
		return true
	if node is RichTextLabel and String((node as RichTextLabel).text).contains(cari):
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


## Jumlah tombol pilihan yang HIDUP (bukan queue_free — pilihan
## lama di-queue_free tiap node baru; tes sinkron harus melewatinya).
func _jumlah_pilihan(rb: RuangBelajarUI) -> int:
	var n := 0
	for c in rb._pilihan_box.get_children():
		if c.is_queued_for_deletion():
			continue
		if c is Button:
			n += 1
		elif c is GridContainer:
			for g in c.get_children():
				if g is Button and not g.is_queued_for_deletion():
					n += 1
	return n


func _teks_pilihan(rb: RuangBelajarUI) -> Array:
	var out: Array = []
	for c in rb._pilihan_box.get_children():
		if c.is_queued_for_deletion():
			continue
		if c is Button:
			out.append((c as Button).text)
		elif c is GridContainer:
			for g in c.get_children():
				if g is Button and not g.is_queued_for_deletion():
					out.append((g as Button).text)
	return out


## Buka chat baru (auto OFF supaya alur digerakkan manual).
func _buka_baru(save: Dictionary = {}) -> RuangBelajarUI:
	var rb := RuangBelajarUI.new()
	add_child(rb)
	rb.set_auto(false)
	rb.tampilkan("Ust. Sanusi", save)
	return rb


## Jalan m1 -> m7. m2_belum = lewat cabang b1/b2 (Belum 2x).
func _ke_m7(rb: RuangBelajarUI, m2_belum: bool) -> void:
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	var opsi: Array = DataChatModul01.cari("m2").get("opsi", [])
	rb._on_opsi_ditekan(opsi[1] if m2_belum else opsi[0])
	if m2_belum:
		rb._selesaikan_bicara()
		var opsi_b1: Array = DataChatModul01.cari("b1").get("opsi", [])
		rb._on_opsi_ditekan(opsi_b1[1])
		rb._selesaikan_bicara()
		rb._lanjut_pesan()
	for i in range(4):
		rb._selesaikan_bicara()
		rb._lanjut_pesan()


## Jawab l1..l5 + k1 semua benar (pertama coba), sampai penutup.
func _jawab_semua_benar(rb: RuangBelajarUI) -> void:
	for i in range(5):
		var id := "l%d" % (i + 1)
		rb._selesaikan_bicara()
		rb._on_soal_ditekan(DataChatModul01.benar_soal(DataChatModul01.cari(id)))
		rb._selesaikan_bicara()
		rb._lanjut_pesan()
	rb._selesaikan_bicara()
	rb._on_soal_ditekan(DataChatModul01.benar_soal(DataChatModul01.cari("k1")))
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	rb._selesaikan_bicara()


func _ready() -> void:
	# ---------- A. DataChatModul01 ----------
	_cek("Data: tulang punggung 14 pesan", DataChatModul01.SPINE.size() == 14 and DataChatModul01.jumlah_pesan() == 14)
	_cek("Data: total node 16 (14 + b1 + b2)", DataChatModul01.NOD.size() == 16)
	_cek("Data: poin 10+15+10 = 35", DataChatModul01.POIN_MATERI == 10 and DataChatModul01.POIN_LATIHAN == 15 and DataChatModul01.POIN_KUIS == 10 and DataChatModul01.POIN_TOTAL == 35)
	_cek("Data: m2 contoh PERSIS Mas (kalam = susunan kalimat)", String(DataChatModul01.cari("m2").get("teks", "")).contains("kalam itu artinya adalah susunan kalimat"))
	var opsi_m2: Array = DataChatModul01.cari("m2").get("opsi", [])
	_cek("Data: m2 Paham->m3, Belum->b1", opsi_m2.size() == 2 and String(opsi_m2[0].get("ke", "")) == "m3" and String(opsi_m2[1].get("ke", "")) == "b1")
	var opsi_b1: Array = DataChatModul01.cari("b1").get("opsi", [])
	_cek("Data: b1 Paham->m3, Belum->b2; b2 Siap->m3", opsi_b1.size() == 2 and String(opsi_b1[0].get("ke", "")) == "m3" and String(opsi_b1[1].get("ke", "")) == "b2" and String((DataChatModul01.cari("b2").get("opsi", []) as Array)[0].get("ke", "")) == "m3")
	_cek("Data: m7 Belum->ulang (maks 1x, ditangani UI)", String((DataChatModul01.cari("m7").get("opsi", []) as Array)[1].get("ke", "")) == "ulang")
	_cek("Data: soal l1-l5 bank latihan 0-4, k1 bank kuis 0", DataChatModul01.cari("l1").get("soal", -1) == 0 and DataChatModul01.cari("l5").get("soal", -1) == 4 and DataChatModul01.cari("k1").get("bank", "") == "kuis")
	_cek("Data: jawaban soal [0,1,2,0,1] + kuis 0 (dari DataModul01)", DataChatModul01.benar_soal(DataChatModul01.cari("l1")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l2")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("l3")) == 2 and DataChatModul01.benar_soal(DataChatModul01.cari("l4")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l5")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("k1")) == 0)
	_cek("Data: papan m2 KALAM + b1 CONTOH (transliterasi saja)", String((DataChatModul01.cari("m2").get("papan", {}) as Dictionary).get("judul", "")) == "KALAM" and String((DataChatModul01.cari("b1").get("papan", {}) as Dictionary).get("judul", "")) == "CONTOH")
	var ada_mengetik := false
	var ada_penghitung := false
	for n in DataChatModul01.NOD:
		var t := String(n.get("teks", ""))
		if t.contains("mengetik"):
			ada_mengetik = true
		if t.contains("dari 14"):
			ada_penghitung = true
	_cek("Data: TIDAK ADA 'mengetik' / penghitung di naskah", not ada_mengetik and not ada_penghitung)
	_cek("Data: jalur_log l3 = 9 pesan guru (m1-m7+l1+l2)", DataChatModul01.jalur_log("l3").size() == 9)
	_cek("Data: indeks_progres b1/b2 = slot m2 (1)", DataChatModul01.indeks_progres("b1") == 1 and DataChatModul01.indeks_progres("b2") == 1 and DataChatModul01.indeks_progres("penutup") == 13)

	# ---------- B. Alur penuh (Paham + semua benar) ----------
	var rb := _buka_baru(SantriSave.default_data())
	var rb_langkah: Array = []
	var rb_selesai_ev: Array = []
	var rb_ditutup_ev: Array = []
	var rb_papan: Array = []
	var rb_kemajuan: Array = []
	rb.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb_langkah.append([jenis, poin]))
	rb.selesai.connect(func(total: int) -> void: rb_selesai_ev.append(total))
	rb.ditutup.connect(func() -> void: rb_ditutup_ev.append(true))
	rb.papan_berubah.connect(func(judul: String, baris: PackedStringArray) -> void: rb_papan.append([judul, baris]))
	rb.kemajuan_disimpan.connect(func(pos_id: String, modul: int) -> void: rb_kemajuan.append([pos_id, modul]))
	_cek("B: buka -> node m1, sedang bicara, pilihan kosong", rb.visible and rb.node_saat_ini() == "m1" and rb.sedang_bicara() and _jumlah_pilihan(rb) == 0)
	_cek("B: papan pertama NAHWU DASAR + kemajuan m1", rb_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata"])]] and rb_kemajuan == [["m1", 1]])
	_cek("B: TIDAK ADA 'mengetik' / 'dari 14' di panel", not _ada_teks(rb, "mengetik") and not _ada_teks(rb, "dari 14"))
	_ke_m7(rb, false)
	_cek("B: sampai m7 (Paham di m2)", rb.node_saat_ini() == "m7")
	rb._selesaikan_bicara()
	rb._on_opsi_ditekan((DataChatModul01.cari("m7").get("opsi", []) as Array)[0])
	_cek("B: Paham di m7 -> materi 10 + node l1", rb_langkah == [["materi", 10]] and rb.node_saat_ini() == "l1")
	_jawab_semua_benar(rb)
	_cek("B: latihan 15 + kuis 10 setelah semua benar", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10]])
	_cek("B: sampai penutup + papan TUNTAS", rb.node_saat_ini() == "penutup" and (rb_papan[-1] as Array)[0] == "TUNTAS")
	_cek("B: papan mengikuti pesan (14 judul, pertama NAHWU DASAR)", rb_papan.size() == 14 and (rb_papan[0] as Array)[0] == "NAHWU DASAR")
	_cek("B: kemajuan mencatat 14 node + '' saat tuntas (belum)", rb_kemajuan.size() == 14 and (rb_kemajuan[-1] as Array)[0] == "penutup")
	_cek("B: TIDAK ADA tombol terkunci sepanjang alur", not rb.ada_tombol_terkunci())
	rb._on_tutup_penutup()
	_cek("B: Tutup penutup -> selesai(35) + ditutup + kemajuan dibersihkan", rb_selesai_ev == [35] and rb_ditutup_ev.size() == 1 and (rb_kemajuan[-1] as Array)[0] == "")
	rb.queue_free()

	# ---------- C. Cabang Belum 2x + ulang m7 maks 1x ----------
	var rb2 := _buka_baru(SantriSave.default_data())
	var rb2_langkah: Array = []
	rb2.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb2_langkah.append([jenis, poin]))
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()
	rb2._selesaikan_bicara()
	rb2._on_opsi_ditekan((DataChatModul01.cari("m2").get("opsi", []) as Array)[1])
	_cek("C: Belum ke-1 di m2 -> b1 (contoh Qaama)", rb2.node_saat_ini() == "b1" and rb2._teks_penuh.contains("Qaama Muhammadun"))
	rb2._selesaikan_bicara()
	rb2._on_opsi_ditekan((DataChatModul01.cari("b1").get("opsi", []) as Array)[1])
	_cek("C: Belum ke-2 di b1 -> b2 (ringkasan)", rb2.node_saat_ini() == "b2")
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()
	_cek("C: Siap, lanjut di b2 -> m3 (tidak ada Belum ke-3)", rb2.node_saat_ini() == "m3")
	for i in range(4):
		rb2._selesaikan_bicara()
		rb2._lanjut_pesan()
	rb2._selesaikan_bicara()
	rb2._on_opsi_ditekan((DataChatModul01.cari("m7").get("opsi", []) as Array)[1])
	_cek("C: Belum di m7 (ke-1) -> ulang dari m2, materi BELUM emit", rb2.node_saat_ini() == "m2" and rb2_langkah.is_empty())
	_ke_m7(rb2, false)
	rb2._selesaikan_bicara()
	rb2._on_opsi_ditekan((DataChatModul01.cari("m7").get("opsi", []) as Array)[1])
	_cek("C: Belum di m7 (ke-2) -> langsung l1 + materi emit SEKALI", rb2.node_saat_ini() == "l1" and rb2_langkah == [["materi", 10]])
	_jawab_semua_benar(rb2)
	rb2._on_tutup_penutup()
	_cek("C: alur selesai setelah ulang (35 poin)", rb2_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10]])
	rb2.queue_free()

	# ---------- D. Salah -> teguran -> soal diulang, opsi salah HILANG ----------
	var rb3 := _buka_baru(SantriSave.default_data())
	_ke_m7(rb3, false)
	rb3._selesaikan_bicara()
	rb3._on_opsi_ditekan((DataChatModul01.cari("m7").get("opsi", []) as Array)[0])
	_cek("D: di l1", rb3.node_saat_ini() == "l1")
	rb3._selesaikan_bicara()
	_cek("D: l1 tampil 4 opsi", _jumlah_pilihan(rb3) == 4)
	var benar_l1 := DataChatModul01.benar_soal(DataChatModul01.cari("l1"))
	var salah_l1 := (benar_l1 + 1) % 4
	var teks_salah: String = String((DataChatModul01.opsi_soal(DataChatModul01.cari("l1")) as Array)[salah_l1])
	rb3._on_soal_ditekan(salah_l1)
	_cek("D: jawaban salah -> teguran 'Belum tepat'", rb3._teks_penuh.contains("Belum tepat"))
	rb3._selesaikan_bicara()
	rb3._lanjut_pesan()
	rb3._selesaikan_bicara()
	_cek("D: soal diulang, opsi salah HILANG (3 opsi) + tidak ada tombol terkunci", rb3.node_saat_ini() == "l1" and _jumlah_pilihan(rb3) == 3 and not _teks_pilihan(rb3).has(teks_salah) and not rb3.ada_tombol_terkunci())
	rb3._on_soal_ditekan(benar_l1)
	_cek("D: jawaban benar -> pujian 'Benar!'", rb3._teks_penuh.contains("Benar!"))
	rb3.queue_free()

	# ---------- E. Resume ----------
	var save_resume := SantriSave.default_data()
	save_resume["rb_chat_pos"] = "l3"
	save_resume["rb_chat_modul"] = 1
	var rb4 := _buka_baru(save_resume)
	_cek("E: resume l3 -> node l3 + riwayat 9 pesan guru", rb4.node_saat_ini() == "l3" and rb4.jumlah_riwayat() == 9)
	_cek("E: resume l3 -> sedang bicara (bukan baca ulang)", rb4.sedang_bicara())
	rb4.queue_free()
	var save_b1 := SantriSave.default_data()
	save_b1["rb_chat_pos"] = "b1"
	var rb4b := _buka_baru(save_b1)
	_cek("E: resume b1 -> node b1 + riwayat 2 (m1+m2)", rb4b.node_saat_ini() == "b1" and rb4b.jumlah_riwayat() == 2)
	rb4b.queue_free()
	var save_parsial := SantriSave.default_data()
	save_parsial["rb_chat_pos"] = "l1"
	save_parsial["rb_selesai"] = ["1:materi"]
	var rb4c := _buka_baru(save_parsial)
	_cek("E: selesai SEBAGIAN (baru materi) BUKAN baca ulang", rb4c.node_saat_ini() == "l1" and rb4c.sedang_bicara())
	rb4c.queue_free()

	# ---------- F. Baca ulang (tuntas) tanpa poin ----------
	var save_tuntas := SantriSave.default_data()
	save_tuntas["rb_selesai"] = ["1:materi", "1:latihan", "1:kuis"]
	var rb5 := _buka_baru(save_tuntas)
	var rb5_langkah: Array = []
	var rb5_selesai_ev: Array = []
	var rb5_ditutup_ev: Array = []
	rb5.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb5_langkah.append([jenis, poin]))
	rb5.selesai.connect(func(total: int) -> void: rb5_selesai_ev.append(total))
	rb5.ditutup.connect(func() -> void: rb5_ditutup_ev.append(true))
	_cek("F: baca ulang -> m1 tampil penuh tanpa bicara + riwayat 14", rb5.node_saat_ini() == "m1" and not rb5.sedang_bicara() and rb5.jumlah_riwayat() == 14)
	for i in range(13):
		rb5._lanjut_pesan()
	_cek("F: baca ulang jalan sampai penutup", rb5.node_saat_ini() == "penutup")
	rb5._on_tutup_penutup()
	_cek("F: baca ulang Tutup -> TANPA poin + hanya ditutup", rb5_langkah.is_empty() and rb5_selesai_ev.is_empty() and rb5_ditutup_ev.size() == 1)
	rb5.queue_free()

	# ---------- G. NPC duduk belajar ----------
	var npc := SantriNPC.new()
	add_child(npc)
	var wps: Array[Vector3] = [Vector3(0, 0, -14)]
	npc.setup("Ust. Sanusi", Vector3(0, 0, -14), wps, Onboarding.OUTFIT_SANUSI.duplicate(), true)
	_cek("G: NPC Sanusi dibuat (mode diam)", npc.berdiri_tetap())
	npc.duduk_belajar(0.5)
	for i in range(5):
		npc._process(0.1)
	_cek("G: duduk_belajar -> pose duduk aktif (visual turun)", npc.sedang_duduk_belajar() and npc._visual.position.y < -0.3)
	npc.berdiri_belajar()
	for i in range(5):
		npc._process(0.1)
	_cek("G: berdiri_belajar -> kembali berdiri + sarung default", not npc.sedang_duduk_belajar() and npc._visual.position.y > -0.1 and npc._sarung.scale.is_equal_approx(SantriPlayer.PAKAIAN_DEFAULT["sarung_scale"]))
	npc.queue_free()

	# ---------- H. AvatarMisi Sanusi peci hitam nasional ----------
	var av := AvatarMisi.new()
	av.atur_tipe("sanusi")
	_cek("H: avatar tipe sanusi", av.tipe == "sanusi")
	var av_src := _isi_file("res://scripts/ui_misi/avatar_misi.gd")
	_cek("H: avatar Sanusi gambar peci hitam nasional (bukan songkok putih)", av_src.contains("PECI_HITAM") and av_src.contains("nasional") and av_src.contains("tipe == \"sanusi\""))
	av.queue_free()

	# ---------- I. Manajer: panel bawah + dim transparan + chip Auto ----------
	var mj := ManajerUIMisi.new()
	add_child(mj)
	var mj_papan: Array = []
	var mj_kemajuan: Array = []
	var mj_ditutup_ev: Array = []
	mj.ruang_belajar_papan.connect(func(judul: String, baris: PackedStringArray) -> void: mj_papan.append([judul, baris]))
	mj.ruang_belajar_kemajuan.connect(func(pos_id: String, modul: int) -> void: mj_kemajuan.append([pos_id, modul]))
	mj.ruang_belajar_ditutup.connect(func() -> void: mj_ditutup_ev.append(true))
	mj.buka_ruang_belajar("Ust. Sanusi", SantriSave.default_data())
	var tinggi_rb := mj._ruang_belajar.offset_bottom - mj._ruang_belajar.offset_top
	_cek("I: manajer buka_ruang_belajar -> panel ruang_belajar", mj.panel_terbuka() == "ruang_belajar")
	_cek("I: panel menempel BAWAH (anchor_top 1.0) + tinggi 475 di 720p", is_equal_approx(mj._ruang_belajar.anchor_top, 1.0) and is_equal_approx(tinggi_rb, 475.0))
	_cek("I: dim TRANSPARAN (alpha 0) tapi tampil (tahan input dunia)", mj._dim.visible and mj._dim.color.a < 0.01)
	_cek("I: chip Auto tampil 'Auto: ON' di kiri atas", mj._rb_auto_chip.visible and mj._rb_auto_chip.text == "Auto: ON" and mj._rb_auto_chip.position == Vector2(16, 16))
	_cek("I: sinyal papan + kemajuan diteruskan manajer", mj_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata"])]] and mj_kemajuan == [["m1", 1]])
	mj._on_rb_auto_chip_ditekan()
	_cek("I: tap chip Auto -> OFF + panel auto OFF", mj._rb_auto_chip.text == "Auto: OFF" and not mj._ruang_belajar.auto_aktif())
	mj._on_rb_auto_chip_ditekan()
	_cek("I: tap chip Auto lagi -> ON", mj._rb_auto_chip.text == "Auto: ON" and mj._ruang_belajar.auto_aktif())
	mj._ruang_belajar._tutup()
	_cek("I: tutup eksplisit -> ditutup diteruskan + chip sembunyi", mj_ditutup_ev.size() == 1 and not mj._rb_auto_chip.visible)
	mj.tutup_semua()
	_cek("I: tutup_semua -> tidak ada panel + dim mati + chip mati", not mj.ada_panel_terbuka() and not mj._dim.visible and not mj._rb_auto_chip.visible)
	mj.queue_free()

	print("TES RUANG BELAJAR CHAT: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
