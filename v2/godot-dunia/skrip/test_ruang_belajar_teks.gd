extends Node
## Tes Ruang Belajar TEKS, LANJUT MANUAL (Sinta, 22 Nov 2026 —
## keputusan Mas 16:03: misi pindah dari VIDEO ke TEKS, narasi
## guru detail + lanjut manual, TIDAK ada auto-advance, TIDAK
## ada timer; video v3 DITUNDA, spike pemutar TIDAK di-port).
## Cakupan: DataChatModul01 (narasi n1–n5 CONTOH {pembicara,
## teks} + latihan l1–l5 + kuis k1 + penutup + tugas, poin 40),
## alur penuh narasi -> latihan -> kuis -> tugas (10+15+10+5),
## lanjut MANUAL (tombol Lanjut + ketuk gelembung, tanpa timer),
## salah -> teguran -> soal diulang (opsi salah HILANG), resume
## (rb_chat_pos + rb_fase + rb_node_terakhir), baca ulang tanpa
## poin, pembicara di-resolve ke pengajar sesi ini, kunci save
## baru di default_data, manajer (panel bawah + dim transparan,
## TANPA chip Auto).
## Headless (isolasi HOME — JANGAN pakai argumen posisional +
## --user-dir: kombinasi itu malah memuat main.tscn, bukan tes ini):
##   HOME=/tmp/iso-rb-teks godot --headless --path . --scene res://skrip/test_ruang_belajar_teks.tscn
## Pola test_ui_misi.gd: _cek + hitung lulus/gagal, EXIT 0 bila
## semua lulus. Alur digerakkan sinkron (_selesaikan_bicara()
## manual — timer bicara tidak ditunggu; TIDAK ADA timer otomatis
## lagi, jadi tidak ada yang perlu dimatikan).

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


## Ketuk mouse kiri (sintetis — langsung ke handler gui_input).
func _ketuk(rb: RuangBelajarUI) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	rb._on_kotak_gui_input(ev)


## Sentuhan layar (sintetis — langsung ke handler gui_input).
func _sentuh(rb: RuangBelajarUI) -> void:
	var ev := InputEventScreenTouch.new()
	ev.pressed = true
	rb._on_kotak_gui_input(ev)


## Buka sesi baru (sinyal disambung pemanggil SEBELUM tampilkan).
func _buka_baru(save: Dictionary = {}, pengajar: String = "Ust. Sanusi") -> RuangBelajarUI:
	var rb := RuangBelajarUI.new()
	add_child(rb)
	rb.tampilkan(pengajar, save)
	return rb


## Jalan n1 -> l1 (5x Lanjut; materi +10 emit di n5 -> l1).
func _ke_l1(rb: RuangBelajarUI) -> void:
	for i in range(5):
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
	_cek("Data: tulang punggung 13 node (5 narasi + 5 latihan + kuis + penutup + tugas)", DataChatModul01.SPINE.size() == 13 and DataChatModul01.jumlah_pesan() == 13)
	_cek("Data: 5 node narasi CONTOH {pembicara, teks}", DataChatModul01.NARASI.size() == 5 and String(DataChatModul01.NARASI[0].get("pembicara", "")) == "Ust. Sanusi" and String(DataChatModul01.NARASI[0].get("teks", "")).contains("Mengenal Kata"))
	_cek("Data: narasi n2 kalam + n5 bait (fakta sama dengan DataModul01)", String(DataChatModul01.cari("n2").get("teks", "")).contains("kalam") and String(DataChatModul01.cari("n5").get("teks", "")).contains("Kata itu tiga"))
	_cek("Data: node lama m1-m7/b1/b2 SUDAH TIDAK ADA", DataChatModul01.cari("m1").is_empty() and DataChatModul01.cari("m7").is_empty() and DataChatModul01.cari("b1").is_empty() and DataChatModul01.cari("b2").is_empty())
	_cek("Data: poin 10+15+10+5 = 40", DataChatModul01.POIN_MATERI == 10 and DataChatModul01.POIN_LATIHAN == 15 and DataChatModul01.POIN_KUIS == 10 and DataChatModul01.POIN_TUGAS == 5 and DataChatModul01.POIN_TOTAL == 40)
	_cek("Data: fase_node n1=narasi, l1=latihan, k1=kuis, penutup, tugas, ''=selesai", DataChatModul01.fase_node("n1") == "narasi" and DataChatModul01.fase_node("l1") == "latihan" and DataChatModul01.fase_node("k1") == "kuis" and DataChatModul01.fase_node("penutup") == "penutup" and DataChatModul01.fase_node("tugas") == "tugas" and DataChatModul01.fase_node("") == "selesai")
	_cek("Data: soal l1-l5 bank latihan 0-4, k1 bank kuis 0", DataChatModul01.cari("l1").get("soal", -1) == 0 and DataChatModul01.cari("l5").get("soal", -1) == 4 and DataChatModul01.cari("k1").get("bank", "") == "kuis")
	_cek("Data: jawaban soal [0,1,2,0,1] + kuis 0 (dari DataModul01)", DataChatModul01.benar_soal(DataChatModul01.cari("l1")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l2")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("l3")) == 2 and DataChatModul01.benar_soal(DataChatModul01.cari("l4")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l5")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("k1")) == 0)
	var ada_mengetik := false
	var ada_penghitung := false
	for n in DataChatModul01.NARASI:
		var t := String(n.get("teks", ""))
		if t.contains("mengetik"):
			ada_mengetik = true
		if t.contains("dari 13"):
			ada_penghitung = true
	for n in DataChatModul01.NOD:
		var t2 := String(n.get("teks", ""))
		if t2.contains("mengetik"):
			ada_mengetik = true
		if t2.contains("dari 13"):
			ada_penghitung = true
	_cek("Data: TIDAK ADA 'mengetik' / penghitung di naskah", not ada_mengetik and not ada_penghitung)
	_cek("Data: jalur_log l3 = 7 pesan guru (n1-n5+l1+l2)", DataChatModul01.jalur_log("l3").size() == 7)
	_cek("Data: indeks_progres n1=0, n5=4, l1=5, k1=10, penutup=11, tugas=12", DataChatModul01.indeks_progres("n1") == 0 and DataChatModul01.indeks_progres("n5") == 4 and DataChatModul01.indeks_progres("l1") == 5 and DataChatModul01.indeks_progres("k1") == 10 and DataChatModul01.indeks_progres("penutup") == 11 and DataChatModul01.indeks_progres("tugas") == 12)

	# ---------- B. Alur penuh (narasi -> latihan -> kuis -> tugas) ----------
	var rb := RuangBelajarUI.new()
	add_child(rb)
	var rb_langkah: Array = []
	var rb_selesai_ev: Array = []
	var rb_ditutup_ev: Array = []
	var rb_papan: Array = []
	var rb_kemajuan: Array = []
	rb.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb_langkah.append([jenis, poin]))
	rb.selesai.connect(func(total: int) -> void: rb_selesai_ev.append(total))
	rb.ditutup.connect(func() -> void: rb_ditutup_ev.append(true))
	rb.papan_berubah.connect(func(judul: String, baris: PackedStringArray) -> void: rb_papan.append([judul, baris]))
	rb.kemajuan_disimpan.connect(func(pos_id: String, modul: int, fase: String, node_terakhir: String) -> void: rb_kemajuan.append([pos_id, modul, fase, node_terakhir]))
	rb.tampilkan("Ust. Sanusi", SantriSave.default_data())
	_cek("B: buka -> node n1, sedang bicara, pilihan kosong", rb.visible and rb.node_saat_ini() == "n1" and rb.sedang_bicara() and _jumlah_pilihan(rb) == 0)
	_cek("B: papan pertama NAHWU DASAR + kemajuan n1/narasi/n1", rb_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata", "akhir kata berubah = i'rab"])]] and rb_kemajuan == [["n1", 1, "narasi", "n1"]])
	_cek("B: TIDAK ADA 'mengetik' / 'dari 13' di panel", not _ada_teks(rb, "mengetik") and not _ada_teks(rb, "dari 13"))
	# Ketuk gelembung saat bicara -> tampil penuh, node tetap n1.
	_ketuk(rb)
	_cek("B: ketuk gelembung saat bicara -> tampil penuh + tombol Lanjut (node tetap n1)", not rb.sedang_bicara() and rb.node_saat_ini() == "n1" and _jumlah_pilihan(rb) == 1 and _teks_pilihan(rb)[0] == "Lanjut ›")
	# Ketuk lagi (ucapan selesai) -> lanjut ke n2.
	_ketuk(rb)
	_cek("B: ketuk gelembung setelah selesai -> lanjut ke n2", rb.node_saat_ini() == "n2")
	# TIDAK ADA auto-advance: tunggu 1,5 dtk nyata, node tetap n2.
	rb._selesaikan_bicara()
	await get_tree().create_timer(1.5).timeout
	_cek("B: TANPA ketuk, 1,5 dtk berlalu -> node TETAP n2 (tidak ada auto-advance)", rb.node_saat_ini() == "n2")
	# Sentuhan layar juga lanjut (bukan cuma mouse).
	_sentuh(rb)
	_cek("B: sentuh gelembung setelah selesai -> lanjut ke n3", rb.node_saat_ini() == "n3")
	# Jalan ke l1 (n4, n5, lalu l1) — materi +10 emit di n5 -> l1.
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	_cek("B: sampai l1 + materi 10 emit SEKALI", rb.node_saat_ini() == "l1" and rb_langkah == [["materi", 10]])
	_cek("B: kemajuan di l1 = latihan + node_terakhir n5", (rb_kemajuan[-1] as Array) == ["l1", 1, "latihan", "n5"])
	_jawab_semua_benar(rb)
	_cek("B: latihan 15 + kuis 10 setelah semua benar", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10]])
	_cek("B: sampai penutup + papan TUNTAS", rb.node_saat_ini() == "penutup" and (rb_papan[-1] as Array)[0] == "TUNTAS")
	_cek("B: papan mengikuti pesan (12 judul sebelum tugas)", rb_papan.size() == 12 and (rb_papan[0] as Array)[0] == "NAHWU DASAR")
	_cek("B: kemajuan di penutup = fase penutup", (rb_kemajuan[-1] as Array) == ["penutup", 1, "penutup", "n5"])
	_cek("B: TIDAK ADA tombol terkunci sepanjang alur", not rb.ada_tombol_terkunci())
	# Penutup -> Lanjut -> tugas.
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	_cek("B: penutup lanjut -> tugas + papan TUGAS + tombol Terima Tugas", rb.node_saat_ini() == "tugas" and (rb_papan[-1] as Array)[0] == "TUGAS" and _teks_pilihan(rb) == ["Terima Tugas ✓"])
	rb._on_terima_tugas()
	_cek("B: Terima Tugas -> tugas 5 + tombol jadi Tutup", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10], ["tugas", 5]] and _teks_pilihan(rb) == ["Tutup"])
	rb._on_tutup_penutup()
	_cek("B: Tutup tugas -> selesai(40) + ditutup + kemajuan dibersihkan (fase selesai)", rb_selesai_ev == [40] and rb_ditutup_ev.size() == 1 and (rb_kemajuan[-1] as Array) == ["", 1, "selesai", "n5"])
	rb.queue_free()

	# ---------- C. Salah -> teguran -> soal diulang, opsi salah HILANG ----------
	var rb2 := _buka_baru(SantriSave.default_data())
	_ke_l1(rb2)
	rb2._selesaikan_bicara()
	_cek("C: di l1, tampil 4 opsi", rb2.node_saat_ini() == "l1" and _jumlah_pilihan(rb2) == 4)
	var benar_l1 := DataChatModul01.benar_soal(DataChatModul01.cari("l1"))
	var salah_l1 := (benar_l1 + 1) % 4
	var teks_salah: String = String((DataChatModul01.opsi_soal(DataChatModul01.cari("l1")) as Array)[salah_l1])
	rb2._on_soal_ditekan(salah_l1)
	_cek("C: jawaban salah -> teguran 'Belum tepat'", rb2._teks_penuh.contains("Belum tepat"))
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()
	rb2._selesaikan_bicara()
	_cek("C: soal diulang, opsi salah HILANG (3 opsi) + tidak ada tombol terkunci", rb2.node_saat_ini() == "l1" and _jumlah_pilihan(rb2) == 3 and not _teks_pilihan(rb2).has(teks_salah) and not rb2.ada_tombol_terkunci())
	rb2._on_soal_ditekan(benar_l1)
	_cek("C: jawaban benar -> pujian 'Benar!'", rb2._teks_penuh.contains("Benar!"))
	rb2.queue_free()

	# ---------- D. Resume ----------
	var save_resume := SantriSave.default_data()
	save_resume["rb_chat_pos"] = "l3"
	save_resume["rb_chat_modul"] = 1
	save_resume["rb_fase"] = "latihan"
	save_resume["rb_node_terakhir"] = "n5"
	var rb3 := _buka_baru(save_resume)
	_cek("D: resume l3 -> node l3 + riwayat 7 pesan guru", rb3.node_saat_ini() == "l3" and rb3.jumlah_riwayat() == 7)
	_cek("D: resume l3 -> sedang bicara (bukan baca ulang)", rb3.sedang_bicara())
	rb3.queue_free()
	var save_n3 := SantriSave.default_data()
	save_n3["rb_chat_pos"] = "n3"
	save_n3["rb_fase"] = "narasi"
	save_n3["rb_node_terakhir"] = "n2"
	var rb3b := _buka_baru(save_n3)
	_cek("D: resume n3 -> node n3 + riwayat 2 (n1+n2)", rb3b.node_saat_ini() == "n3" and rb3b.jumlah_riwayat() == 2)
	rb3b.queue_free()
	var save_parsial := SantriSave.default_data()
	save_parsial["rb_chat_pos"] = "l1"
	save_parsial["rb_selesai"] = ["1:materi"]
	var rb3c := _buka_baru(save_parsial)
	_cek("D: selesai SEBAGIAN (baru materi) BUKAN baca ulang", rb3c.node_saat_ini() == "l1" and rb3c.sedang_bicara())
	rb3c.queue_free()

	# ---------- E. Baca ulang (tuntas) tanpa poin ----------
	var save_tuntas := SantriSave.default_data()
	save_tuntas["rb_selesai"] = ["1:materi", "1:latihan", "1:kuis"]
	var rb4 := _buka_baru(save_tuntas)
	var rb4_langkah: Array = []
	var rb4_selesai_ev: Array = []
	var rb4_ditutup_ev: Array = []
	rb4.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb4_langkah.append([jenis, poin]))
	rb4.selesai.connect(func(total: int) -> void: rb4_selesai_ev.append(total))
	rb4.ditutup.connect(func() -> void: rb4_ditutup_ev.append(true))
	_cek("E: baca ulang -> n1 tampil penuh tanpa bicara + riwayat 13", rb4.node_saat_ini() == "n1" and not rb4.sedang_bicara() and rb4.jumlah_riwayat() == 13)
	for i in range(12):
		rb4._lanjut_pesan()
	_cek("E: baca ulang jalan sampai tugas", rb4.node_saat_ini() == "tugas")
	_cek("E: baca ulang tugas -> langsung Tutup (tanpa Terima Tugas)", _teks_pilihan(rb4) == ["Tutup"])
	rb4._on_tutup_penutup()
	_cek("E: baca ulang Tutup -> TANPA poin + hanya ditutup", rb4_langkah.is_empty() and rb4_selesai_ev.is_empty() and rb4_ditutup_ev.size() == 1)
	rb4.queue_free()

	# ---------- F. Pembicara di-resolve ke pengajar sesi ini ----------
	var rb5 := _buka_baru(SantriSave.default_data(), "Ustzh. Fatimah")
	_cek("F: pengajar Fatimah -> nama label 'Ustzh. Fatimah' walau node tulis Sanusi", String(rb5._nama_label.text) == "Ustzh. Fatimah")
	_cek("F: avatar ikut pengajar (ustadzah)", rb5._avatar.tipe == "ustadzah")
	rb5.queue_free()
	var rb5b := _buka_baru(SantriSave.default_data(), "Ust. Sanusi")
	_cek("F: pengajar Sanusi -> nama label 'Ust. Sanusi' + avatar sanusi", String(rb5b._nama_label.text) == "Ust. Sanusi" and rb5b._avatar.tipe == "sanusi")
	rb5b.queue_free()

	# ---------- G. Kunci save baru di default_data + round-trip ----------
	var d := SantriSave.default_data()
	_cek("G: default_data punya rb_fase + rb_node_terakhir (\"\" )", d.has("rb_fase") and d.has("rb_node_terakhir") and String(d.get("rb_fase", "x")) == "" and String(d.get("rb_node_terakhir", "x")) == "")
	var d2 := SantriSave.default_data()
	d2["rb_fase"] = "latihan"
	d2["rb_node_terakhir"] = "n5"
	d2["rb_chat_pos"] = "l1"
	SantriSave.save_data(d2)
	var d3 := SantriSave.load_data()
	_cek("G: round-trip save/load mempertahankan rb_fase + rb_node_terakhir", String(d3.get("rb_fase", "")) == "latihan" and String(d3.get("rb_node_terakhir", "")) == "n5" and String(d3.get("rb_chat_pos", "")) == "l1")

	# ---------- H. TIDAK ADA Auto / timer otomatis di sumber ----------
	var src_rb := _isi_file("res://scripts/ui_misi/ruang_belajar_ui.gd")
	_cek("H: ruang_belajar_ui.gd TIDAK ADA _timer_otomatis / set_auto / auto_berubah", not src_rb.contains("_timer_otomatis") and not src_rb.contains("set_auto") and not src_rb.contains("auto_berubah"))
	var src_mj := _isi_file("res://scripts/ui_misi/manajer_ui_misi.gd")
	_cek("H: manajer TIDAK ADA chip Auto (_rb_auto_chip)", not src_mj.contains("_rb_auto_chip"))
	_cek("H: manajer meneruskan kemajuan 4 argumen (pos, modul, fase, node)", src_mj.contains("ruang_belajar_kemajuan(pos_id: String, modul: int, fase: String, node_terakhir: String)"))

	# ---------- I. Manajer: panel bawah + dim transparan + kemajuan 4 argumen ----------
	var mj := ManajerUIMisi.new()
	add_child(mj)
	var mj_papan: Array = []
	var mj_kemajuan: Array = []
	var mj_ditutup_ev: Array = []
	mj.ruang_belajar_papan.connect(func(judul: String, baris: PackedStringArray) -> void: mj_papan.append([judul, baris]))
	mj.ruang_belajar_kemajuan.connect(func(pos_id: String, modul: int, fase: String, node_terakhir: String) -> void: mj_kemajuan.append([pos_id, modul, fase, node_terakhir]))
	mj.ruang_belajar_ditutup.connect(func() -> void: mj_ditutup_ev.append(true))
	mj.buka_ruang_belajar("Ust. Sanusi", SantriSave.default_data())
	var tinggi_rb := mj._ruang_belajar.offset_bottom - mj._ruang_belajar.offset_top
	var vp_rb := mj.get_viewport().get_visible_rect().size
	var s_rb := mj._skala_layar()
	var harap_rb := minf(vp_rb.y * 0.66, maxf(560.0, 560.0 / s_rb))
	_cek("I: manajer buka_ruang_belajar -> panel ruang_belajar", mj.panel_terbuka() == "ruang_belajar")
	_cek("I: panel menempel BAWAH (anchor_top 1.0) + tinggi = min(vp*0.66, 560/s)", is_equal_approx(mj._ruang_belajar.anchor_top, 1.0) and is_equal_approx(tinggi_rb, harap_rb))
	await get_tree().process_frame
	var kotak_rb := mj._ruang_belajar._kotak_dialog.get_global_rect()
	_cek("I: kotak dialog menempel BAWAH (dasar kotak = dasar layar)", absf(kotak_rb.end.y - vp_rb.y) < 4.0)
	_cek("I: dim TRANSPARAN (alpha 0) tapi tampil (tahan input dunia)", mj._dim.visible and mj._dim.color.a < 0.01)
	_cek("I: sinyal papan + kemajuan 4 argumen diteruskan manajer", mj_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata", "akhir kata berubah = i'rab"])]] and mj_kemajuan == [["n1", 1, "narasi", "n1"]])
	mj._ruang_belajar._tutup()
	_cek("I: tutup eksplisit -> ditutup diteruskan", mj_ditutup_ev.size() == 1)
	mj.tutup_semua()
	_cek("I: tutup_semua -> tidak ada panel + dim mati", not mj.ada_panel_terbuka() and not mj._dim.visible)
	mj.queue_free()

	print("TES RUANG BELAJAR TEKS: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
