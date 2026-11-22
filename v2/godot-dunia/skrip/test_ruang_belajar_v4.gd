extends Node
## Tes Ruang Belajar TEKS v4 (Sinta, 22 Nov 2026 — konsep v4 +
## naskah Modul 01 Laras, DI-ACC Mas 16:12; port dari
## data_chat_modul_01_v4.gd).
## Cakupan: DataChatModul01 (28 node tulang punggung + 4 node
## ulang kondisional, total 32 node, 1.201 kata narasi, poin 40),
## alur penuh p1 -> narasi -> cek -> latihan -> kuis -> penutup
## -> tugas (10+15+10+5), lanjut MANUAL (tanpa ketuk, node TIDAK
## maju; tanpa timer), cek "Belum" maks 1x per cek (ulang sekali,
## lalu lanjut — tidak bisa mengulang tanpa henti), salah ->
## teguran -> soal diulang (opsi salah HILANG), resume
## (rb_chat_pos + rb_fase + rb_node_terakhir), baca ulang tanpa
## poin, pembicara di-resolve ke pengajar sesi ini, kunci save
## baru di default_data, manajer (panel bawah + dim transparan,
## TANPA chip Auto).
## Headless (isolasi HOME — JANGAN pakai argumen posisional +
## --user-dir: kombinasi itu malah memuat main.tscn, bukan tes ini):
##   HOME=/tmp/iso-rb-v4 godot --headless --path . --scene res://skrip/test_ruang_belajar_v4.tscn
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


## Buka sesi baru (sinyal disambung pemanggil SEBELUM tampilkan).
func _buka_baru(save: Dictionary = {}, pengajar: String = "Ust. Sanusi") -> RuangBelajarUI:
	var rb := RuangBelajarUI.new()
	add_child(rb)
	rb.tampilkan(pengajar, save)
	return rb


## Tekan opsi cek ke-idx (0 = "Paham", 1 = "Belum").
func _tekan_cek(rb: RuangBelajarUI, idx: int) -> void:
	var opsi: Array = DataChatModul01.cari(rb.node_saat_ini()).get("opsi", [])
	rb._on_cek_ditekan(opsi[idx])


## Jalan dari node saat ini sampai l1. cek_belum = id cek yang
## dijawab "Belum" (1x) — cek lain dijawab "Paham".
## Pengaman 40 langkah supaya tidak macet bila node baru.
func _ke_l1(rb: RuangBelajarUI, cek_belum: Array = []) -> void:
	var pengaman := 0
	while rb.node_saat_ini() != "l1" and pengaman < 40:
		pengaman += 1
		rb._selesaikan_bicara()
		var nod := DataChatModul01.cari(rb.node_saat_ini())
		if String(nod.get("tipe", "")) == "cek":
			var idx := 1 if cek_belum.has(String(nod.get("id", ""))) else 0
			_tekan_cek(rb, idx)
		else:
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
	# ---------- A. DataChatModul01 (naskah v4 Laras) ----------
	_cek("Data: tulang punggung 28 node", DataChatModul01.SPINE.size() == 28 and DataChatModul01.jumlah_pesan() == 28)
	_cek("Data: NARASI 24 + NOD 8 = 32 node", DataChatModul01.NARASI.size() == 24 and DataChatModul01.NOD.size() == 8)
	_cek("Data: node pertama p1 (sapaan)", DataChatModul01.id_pertama() == "p1" and String(DataChatModul01.cari("p1").get("teks", "")).contains("Assalamu'alaikum"))
	_cek("Data: 4 cek (c1-c4) + 4 ulang (u1-u4, TIDAK di SPINE)", DataChatModul01.cari("c1").get("tipe", "") == "cek" and DataChatModul01.cari("c4").get("tipe", "") == "cek" and not DataChatModul01.SPINE.has("u1") and not DataChatModul01.SPINE.has("u4"))
	_cek("Data: poin 10+15+10+5 = 40", DataChatModul01.POIN_MATERI == 10 and DataChatModul01.POIN_LATIHAN == 15 and DataChatModul01.POIN_KUIS == 10 and DataChatModul01.POIN_TUGAS == 5 and DataChatModul01.POIN_TOTAL == 40)
	_cek("Data: fase_node p1/n1/c1/u1/p_latihan=narasi, l1=latihan, k1=kuis", DataChatModul01.fase_node("p1") == "narasi" and DataChatModul01.fase_node("n1") == "narasi" and DataChatModul01.fase_node("c1") == "narasi" and DataChatModul01.fase_node("u1") == "narasi" and DataChatModul01.fase_node("p_latihan") == "narasi" and DataChatModul01.fase_node("l1") == "latihan" and DataChatModul01.fase_node("k1") == "kuis" and DataChatModul01.fase_node("penutup") == "penutup" and DataChatModul01.fase_node("tugas") == "tugas" and DataChatModul01.fase_node("") == "selesai")
	_cek("Data: indeks_progres u1=3, u2=6, u3=10, u4=15 (slot cek)", DataChatModul01.indeks_progres("u1") == 3 and DataChatModul01.indeks_progres("u2") == 6 and DataChatModul01.indeks_progres("u3") == 10 and DataChatModul01.indeks_progres("u4") == 15)
	_cek("Data: indeks_progres p1=0, p_latihan=19, l1=20, k1=25, penutup=26, tugas=27", DataChatModul01.indeks_progres("p1") == 0 and DataChatModul01.indeks_progres("p_latihan") == 19 and DataChatModul01.indeks_progres("l1") == 20 and DataChatModul01.indeks_progres("k1") == 25 and DataChatModul01.indeks_progres("penutup") == 26 and DataChatModul01.indeks_progres("tugas") == 27)
	_cek("Data: jalur_log u1=4, u4=16, l3=22", DataChatModul01.jalur_log("u1").size() == 4 and DataChatModul01.jalur_log("u4").size() == 16 and DataChatModul01.jalur_log("l3").size() == 22)
	_cek("Data: soal l1-l5 bank latihan 0-4, k1 bank kuis 0", DataChatModul01.cari("l1").get("soal", -1) == 0 and DataChatModul01.cari("l5").get("soal", -1) == 4 and DataChatModul01.cari("k1").get("bank", "") == "kuis")
	_cek("Data: jawaban soal [0,1,2,0,1] + kuis 0 (dari DataModul01)", DataChatModul01.benar_soal(DataChatModul01.cari("l1")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l2")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("l3")) == 2 and DataChatModul01.benar_soal(DataChatModul01.cari("l4")) == 0 and DataChatModul01.benar_soal(DataChatModul01.cari("l5")) == 1 and DataChatModul01.benar_soal(DataChatModul01.cari("k1")) == 0)
	var ada_sekali_lagi := false
	var ada_mengetik := false
	for n in DataChatModul01.NARASI:
		var t := String(n.get("teks", ""))
		if t.contains("Sekali lagi"):
			ada_sekali_lagi = true
		if t.contains("mengetik"):
			ada_mengetik = true
	for n in DataChatModul01.NOD:
		var t2 := String(n.get("teks", ""))
		if t2.contains("Sekali lagi"):
			ada_sekali_lagi = true
		if t2.contains("mengetik"):
			ada_mengetik = true
	_cek("Data: TIDAK ADA 'Sekali lagi' (ditolak Mas) / 'mengetik' di naskah", not ada_sekali_lagi and not ada_mengetik)
	var target_hilang := false
	for n in DataChatModul01.NARASI:
		for o in (n.get("opsi", []) as Array):
			if DataChatModul01.cari(String((o as Dictionary).get("ke", ""))).is_empty():
				target_hilang = true
		if String(n.get("berikut", "")) != "" and DataChatModul01.cari(String(n.get("berikut", ""))).is_empty():
			target_hilang = true
	_cek("Data: semua target opsi 'ke' + 'berikut' ada", not target_hilang)
	_cek("Data: cek c1 Paham->n3, Belum->u1; u1 berikut->n3", String((DataChatModul01.cari("c1").get("opsi", []) as Array)[0].get("ke", "")) == "n3" and String((DataChatModul01.cari("c1").get("opsi", []) as Array)[1].get("ke", "")) == "u1" and String(DataChatModul01.cari("u1").get("berikut", "")) == "n3")
	_cek("Data: penutup tipe 'pesan' (bukan 'penutup') + tugas ada", String(DataChatModul01.cari("penutup").get("tipe", "")) == "pesan" and String(DataChatModul01.cari("tugas").get("tipe", "")) == "tugas")

	# ---------- B. Alur penuh (semua cek "Paham") ----------
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
	_cek("B: buka -> node p1, sedang bicara, pilihan kosong", rb.visible and rb.node_saat_ini() == "p1" and rb.sedang_bicara() and _jumlah_pilihan(rb) == 0)
	_cek("B: papan pertama NAHWU DASAR + kemajuan p1/narasi/p1", rb_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata"])]] and rb_kemajuan == [["p1", 1, "narasi", "p1"]])
	_cek("B: TIDAK ADA 'mengetik' / 'dari 28' di panel", not _ada_teks(rb, "mengetik") and not _ada_teks(rb, "dari 28"))
	# Ketuk gelembung saat bicara -> tampil penuh, node tetap p1.
	_ketuk(rb)
	_cek("B: ketuk gelembung saat bicara -> tampil penuh + tombol Lanjut (node tetap p1)", not rb.sedang_bicara() and rb.node_saat_ini() == "p1" and _jumlah_pilihan(rb) == 1 and _teks_pilihan(rb)[0] == "Lanjut ›")
	# Ketuk lagi (ucapan selesai) -> lanjut ke n1.
	_ketuk(rb)
	_cek("B: ketuk gelembung setelah selesai -> lanjut ke n1", rb.node_saat_ini() == "n1")
	# TIDAK ADA auto-advance: tunggu 1,5 dtk nyata, node tetap n1.
	rb._selesaikan_bicara()
	await get_tree().create_timer(1.5).timeout
	_cek("B: TANPA ketuk, 1,5 dtk berlalu -> node TETAP n1 (tidak ada auto-advance)", rb.node_saat_ini() == "n1")
	# Jalan ke c1 (n1 -> n2 -> c1): cek tampil 2 opsi outline.
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	_cek("B: sampai c1 + 2 opsi (Paham/Belum) aktif penuh, tidak terkunci", rb.node_saat_ini() == "c1" and _jumlah_pilihan(rb) == 2 and _teks_pilihan(rb) == ["Paham, lanjut ›", "Belum, jelaskan lagi"] and not rb.ada_tombol_terkunci())
	# Paham di c1 -> n3 + gelembung player tampil.
	_tekan_cek(rb, 0)
	_cek("B: Paham di c1 -> n3 + gelembung player tampil", rb.node_saat_ini() == "n3" and rb._gelembung_box.visible and String(rb._gelembung_label.text) == "Paham, lanjut ›")
	# Jalan ke l1 (semua cek Paham) — materi +10 emit di p_latihan -> l1.
	_ke_l1(rb)
	_cek("B: sampai l1 + materi 10 emit SEKALI (di p_latihan)", rb.node_saat_ini() == "l1" and rb_langkah == [["materi", 10]])
	_cek("B: kemajuan di l1 = latihan + node_terakhir p_latihan", (rb_kemajuan[-1] as Array) == ["l1", 1, "latihan", "p_latihan"])
	_jawab_semua_benar(rb)
	_cek("B: latihan 15 + kuis 10 setelah semua benar", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10]])
	_cek("B: sampai penutup + papan TUNTAS", rb.node_saat_ini() == "penutup" and (rb_papan[-1] as Array)[0] == "TUNTAS")
	_cek("B: papan mengikuti pesan (27 judul s.d. penutup, pertama NAHWU DASAR, terakhir TUNTAS)", rb_papan.size() == 27 and (rb_papan[0] as Array)[0] == "NAHWU DASAR" and (rb_papan[-1] as Array)[0] == "TUNTAS")
	_cek("B: kemajuan 27 node s.d. penutup + fase penutup di penutup", rb_kemajuan.size() == 27 and (rb_kemajuan[-1] as Array) == ["penutup", 1, "penutup", "p_latihan"])
	_cek("B: TIDAK ADA tombol terkunci sepanjang alur", not rb.ada_tombol_terkunci())
	# Penutup -> Lanjut -> tugas.
	rb._lanjut_pesan()
	rb._selesaikan_bicara()
	_cek("B: penutup lanjut -> tugas + papan TUGAS + tombol Terima Tugas", rb.node_saat_ini() == "tugas" and (rb_papan[-1] as Array)[0] == "TUGAS" and _teks_pilihan(rb) == ["Terima Tugas ✓"])
	rb._on_terima_tugas()
	_cek("B: Terima Tugas -> tugas 5 + tombol jadi Tutup", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10], ["tugas", 5]] and _teks_pilihan(rb) == ["Tutup"])
	rb._on_tutup_penutup()
	_cek("B: Tutup tugas -> selesai(40) + ditutup + kemajuan dibersihkan (fase selesai)", rb_selesai_ev == [40] and rb_ditutup_ev.size() == 1 and (rb_kemajuan[-1] as Array) == ["", 1, "selesai", "p_latihan"])
	rb.queue_free()

	# ---------- C. "Belum" maks 1x per cek ----------
	var rb2 := _buka_baru(SantriSave.default_data())
	var rb2_langkah: Array = []
	rb2.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb2_langkah.append([jenis, poin]))
	# Jalan ke c1 (p1 -> n1 -> n2 -> c1).
	for i in range(3):
		rb2._selesaikan_bicara()
		rb2._lanjut_pesan()
	rb2._selesaikan_bicara()
	_cek("C: sampai c1", rb2.node_saat_ini() == "c1")
	# Belum ke-1 di c1 -> u1 (contoh lain, papan KALAM — ULANG).
	_tekan_cek(rb2, 1)
	_cek("C: Belum di c1 -> u1 (ulang, contoh lain)", rb2.node_saat_ini() == "u1" and rb2._teks_penuh.contains("Muhammad telah berdiri"))
	# Lanjut dari u1 -> n3 (berikut) — TIDAK kembali ke c1.
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()
	_cek("C: Lanjut dari u1 -> n3 (tidak ada Belum ke-2, cek tidak muncul lagi)", rb2.node_saat_ini() == "n3")
	# Belum juga di c2 (cek lain, independen) -> u2 -> n5.
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()   # n3 -> n4
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()   # n4 -> c2
	rb2._selesaikan_bicara()
	_tekan_cek(rb2, 1)
	_cek("C: Belum di c2 -> u2", rb2.node_saat_ini() == "u2")
	rb2._selesaikan_bicara()
	rb2._lanjut_pesan()
	_cek("C: Lanjut dari u2 -> n5", rb2.node_saat_ini() == "n5")
	# Lanjut sampai l1 + selesaikan alur — materi tetap SEKALI.
	_ke_l1(rb2)
	_cek("C: setelah 2x Belum (cek berbeda) sampai l1 + materi 10 SEKALI", rb2.node_saat_ini() == "l1" and rb2_langkah == [["materi", 10]])
	_jawab_semua_benar(rb2)
	rb2._lanjut_pesan()
	rb2._selesaikan_bicara()
	rb2._on_terima_tugas()
	rb2._on_tutup_penutup()
	_cek("C: alur selesai setelah Belum (40 poin)", rb2_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10], ["tugas", 5]])
	rb2.queue_free()

	# ---------- D. Salah -> teguran -> soal diulang, opsi salah HILANG ----------
	var rb3 := _buka_baru(SantriSave.default_data())
	_ke_l1(rb3)
	rb3._selesaikan_bicara()
	_cek("D: di l1, tampil 4 opsi", rb3.node_saat_ini() == "l1" and _jumlah_pilihan(rb3) == 4)
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
	save_resume["rb_fase"] = "latihan"
	save_resume["rb_node_terakhir"] = "p_latihan"
	var rb4 := _buka_baru(save_resume)
	_cek("E: resume l3 -> node l3 + riwayat 22 pesan guru", rb4.node_saat_ini() == "l3" and rb4.jumlah_riwayat() == 22)
	_cek("E: resume l3 -> sedang bicara (bukan baca ulang)", rb4.sedang_bicara())
	rb4.queue_free()
	var save_u2 := SantriSave.default_data()
	save_u2["rb_chat_pos"] = "u2"
	save_u2["rb_fase"] = "narasi"
	save_u2["rb_node_terakhir"] = "c2"
	var rb4b := _buka_baru(save_u2)
	_cek("E: resume u2 -> node u2 + riwayat 7 (p1..c2)", rb4b.node_saat_ini() == "u2" and rb4b.jumlah_riwayat() == 7)
	rb4b.queue_free()
	var save_c3 := SantriSave.default_data()
	save_c3["rb_chat_pos"] = "c3"
	var rb4c := _buka_baru(save_c3)
	_cek("E: resume c3 -> node c3 + riwayat 10", rb4c.node_saat_ini() == "c3" and rb4c.jumlah_riwayat() == 10)
	rb4c.queue_free()
	var save_parsial := SantriSave.default_data()
	save_parsial["rb_chat_pos"] = "l1"
	save_parsial["rb_selesai"] = ["1:materi"]
	var rb4d := _buka_baru(save_parsial)
	_cek("E: selesai SEBAGIAN (baru materi) BUKAN baca ulang", rb4d.node_saat_ini() == "l1" and rb4d.sedang_bicara())
	rb4d.queue_free()

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
	_cek("F: baca ulang -> p1 tampil penuh tanpa bicara + riwayat 28", rb5.node_saat_ini() == "p1" and not rb5.sedang_bicara() and rb5.jumlah_riwayat() == 28)
	for i in range(27):
		rb5._lanjut_pesan()
	_cek("F: baca ulang jalan sampai tugas (cek dilewati via Lanjut)", rb5.node_saat_ini() == "tugas")
	_cek("F: baca ulang tugas -> langsung Tutup (tanpa Terima Tugas)", _teks_pilihan(rb5) == ["Tutup"])
	rb5._on_tutup_penutup()
	_cek("F: baca ulang Tutup -> TANPA poin + hanya ditutup", rb5_langkah.is_empty() and rb5_selesai_ev.is_empty() and rb5_ditutup_ev.size() == 1)
	rb5.queue_free()

	# ---------- G. Pembicara di-resolve ke pengajar sesi ini ----------
	var rb6 := _buka_baru(SantriSave.default_data(), "Ustzh. Fatimah")
	_cek("G: pengajar Fatimah -> nama label 'Ustzh. Fatimah' walau node tulis Sanusi", String(rb6._nama_label.text) == "Ustzh. Fatimah")
	_cek("G: avatar ikut pengajar (ustadzah)", rb6._avatar.tipe == "ustadzah")
	rb6.queue_free()
	var rb6b := _buka_baru(SantriSave.default_data(), "Ust. Sanusi")
	_cek("G: pengajar Sanusi -> nama label 'Ust. Sanusi' + avatar sanusi", String(rb6b._nama_label.text) == "Ust. Sanusi" and rb6b._avatar.tipe == "sanusi")
	rb6b.queue_free()

	# ---------- H. Kunci save baru di default_data + round-trip ----------
	var d := SantriSave.default_data()
	_cek("H: default_data punya rb_fase + rb_node_terakhir (\"\" )", d.has("rb_fase") and d.has("rb_node_terakhir") and String(d.get("rb_fase", "x")) == "" and String(d.get("rb_node_terakhir", "x")) == "")
	var d2 := SantriSave.default_data()
	d2["rb_fase"] = "latihan"
	d2["rb_node_terakhir"] = "p_latihan"
	d2["rb_chat_pos"] = "l1"
	SantriSave.save_data(d2)
	var d3 := SantriSave.load_data()
	_cek("H: round-trip save/load mempertahankan rb_fase + rb_node_terakhir", String(d3.get("rb_fase", "")) == "latihan" and String(d3.get("rb_node_terakhir", "")) == "p_latihan" and String(d3.get("rb_chat_pos", "")) == "l1")

	# ---------- I. TIDAK ADA Auto / timer otomatis di sumber ----------
	var src_rb := _isi_file("res://scripts/ui_misi/ruang_belajar_ui.gd")
	_cek("I: ruang_belajar_ui.gd TIDAK ADA _timer_otomatis / set_auto / auto_berubah", not src_rb.contains("_timer_otomatis") and not src_rb.contains("set_auto") and not src_rb.contains("auto_berubah"))
	_cek("I: ruang_belajar_ui.gd PUNYA arm cek + handler _on_cek_ditekan", src_rb.contains("\"cek\"") and src_rb.contains("_on_cek_ditekan"))
	_cek("I: pemicu materi di p_latihan (bukan n5 contoh)", src_rb.contains("== \"p_latihan\"") and not src_rb.contains("== \"n5\""))
	var src_mj := _isi_file("res://scripts/ui_misi/manajer_ui_misi.gd")
	_cek("I: manajer TIDAK ADA chip Auto (_rb_auto_chip)", not src_mj.contains("_rb_auto_chip"))
	_cek("I: manajer meneruskan kemajuan 4 argumen (pos, modul, fase, node)", src_mj.contains("ruang_belajar_kemajuan(pos_id: String, modul: int, fase: String, node_terakhir: String)"))

	# ---------- J. Manajer: panel bawah + dim transparan + kemajuan 4 argumen ----------
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
	_cek("J: manajer buka_ruang_belajar -> panel ruang_belajar", mj.panel_terbuka() == "ruang_belajar")
	_cek("J: panel menempel BAWAH (anchor_top 1.0) + tinggi = min(vp*0.66, 560/s)", is_equal_approx(mj._ruang_belajar.anchor_top, 1.0) and is_equal_approx(tinggi_rb, harap_rb))
	await get_tree().process_frame
	var kotak_rb := mj._ruang_belajar._kotak_dialog.get_global_rect()
	_cek("J: kotak dialog menempel BAWAH (dasar kotak = dasar layar)", absf(kotak_rb.end.y - vp_rb.y) < 4.0)
	_cek("J: dim TRANSPARAN (alpha 0) tapi tampil (tahan input dunia)", mj._dim.visible and mj._dim.color.a < 0.01)
	_cek("J: sinyal papan + kemajuan 4 argumen diteruskan manajer", mj_papan == [["NAHWU DASAR", PackedStringArray(["Modul 01 — Mengenal Kata"])]] and mj_kemajuan == [["p1", 1, "narasi", "p1"]])
	mj._ruang_belajar._tutup()
	_cek("J: tutup eksplisit -> ditutup diteruskan", mj_ditutup_ev.size() == 1)
	mj.tutup_semua()
	_cek("J: tutup_semua -> tidak ada panel + dim mati", not mj.ada_panel_terbuka() and not mj._dim.visible)
	mj.queue_free()

	print("TES RUANG BELAJAR V4: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
