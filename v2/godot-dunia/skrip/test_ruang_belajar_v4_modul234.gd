extends Node
## Tes Ruang Belajar TEKS v4 — Modul 02/03/04 (Sinta, 22 Nov 2026
## — port naskah Laras data_chat_modul_02/03/04_v4.gd, DI-ACC Mas
## 22:52 "Acc semua sampai selesai"; TASHIH LOLOS).
## Cakupan per modul (pola test_ruang_belajar_v4.gd Modul 01):
## data (SPINE/NARASI/NOD, poin 40, indeks_progres, jalur_log,
## jawaban soal dari DataModul0X), alur penuh p1 -> narasi -> cek
## -> latihan -> kuis -> penutup -> tugas (10+15+10+5), lanjut
## MANUAL, cek "Belum" maks 1x per cek, salah -> teguran -> soal
## diulang (opsi salah HILANG), resume, baca ulang tanpa poin.
## Plus: dispatch UI per modul (_chat dari _modul; modul 5+ jatuh
## ke Modul 01), bank Tes Kenaikan N2/N3/N4 (DataModul02/03/04),
## dan cek sumber wiring.
## Headless (isolasi HOME — JANGAN pakai argumen posisional +
## --user-dir: kombinasi itu malah memuat main.tscn, bukan tes ini):
##   HOME=/tmp/iso-rb-v4 godot --headless --path . --scene res://skrip/test_ruang_belajar_v4_modul234.tscn
## Pola test_ui_misi.gd: _cek + hitung lulus/gagal, EXIT 0 bila
## semua lulus.

var _lulus := 0
var _gagal := 0

## Konfigurasi per modul (angka diverifikasi dari naskah v4 +
## DataModul0X; BUKAN dari kode yang dites — kecuali jalur_log
## l3/c3 yang mengikuti definisi jalur_log: elemen SPINE SEBELUM
## id itu).
const MODUL := [
	{
		"n": 2, "judul": "Modul 02 — Isim Lebih Dalam", "spine": 24, "narasi": 20,
		"jawaban": [0, 1, 2, 3, 2], "k1": 0,
		"u": [3, 6, 8, 11], "jalur_u4": 12,
		"c1_ke": "n3", "c2_ke": "n5",
		"u1_teks": "sayyaaratun", "u2_teks": "al-madrasatu",
		"resume_l3": 18, "resume_u2": 7, "resume_c3": 8,
		"idx": {"p_latihan": 15, "l1": 16, "k1": 21, "penutup": 22, "tugas": 23},
		"kuis_jawaban": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		"tes_soal1": "Makrifat menunjuk yang sudah tertentu",
	},
	{
		"n": 3, "judul": "Modul 03 — Fi'il dan I'robnya", "spine": 28, "narasi": 24,
		"jawaban": [0, 1, 2, 0, 1], "k1": 0,
		"u": [5, 8, 11, 15], "jalur_u4": 16,
		"c1_ke": "n5", "c2_ke": "n7",
		"u1_teks": "kataba", "u2_teks": "Syariba al-maa-a",
		"resume_l3": 22, "resume_u2": 9, "resume_c3": 11,
		"idx": {"p_latihan": 19, "l1": 20, "k1": 25, "penutup": 26, "tugas": 27},
		"kuis_jawaban": [0, 0, 0, 0, 0, 0, 3, 0, 0, 0],
		"tes_soal1": "Madhi, mudhori', amar",
	},
	{
		"n": 4, "judul": "Modul 04 — Keadaan Isim", "spine": 28, "narasi": 24,
		"jawaban": [0, 1, 2, 1, 0], "k1": 0,
		"u": [5, 9, 13, 15], "jalur_u4": 16,
		"c1_ke": "n5", "c2_ke": "n8",
		"u1_teks": "Kataba ath-thaalibu", "u2_teks": "Qara'tu al-kitaaba",
		"resume_l3": 22, "resume_u2": 10, "resume_c3": 13,
		"idx": {"p_latihan": 19, "l1": 20, "k1": 25, "penutup": 26, "tugas": 27},
		"kuis_jawaban": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		"tes_soal1": "Fa'il, naib fa'il, mubtada, khabar, isim kaana",
	},
]


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


## Jumlah tombol pilihan yang HIDUP (bukan queue_free).
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


## Kelas data chat per nomor modul (dispatch yang sama dipakai UI).
func _chat_modul(n: int):
	match n:
		2:
			return DataChatModul02
		3:
			return DataChatModul03
		4:
			return DataChatModul04
	return DataChatModul01


## Kelas bank soal per nomor modul.
func _bank_modul(n: int):
	match n:
		2:
			return DataModul02
		3:
			return DataModul03
		4:
			return DataModul04
	return DataModul01


## Save baru dengan modul onboarding = n.
func _save_modul(n: int) -> Dictionary:
	var save := SantriSave.default_data()
	save["onboarding"] = {"modul": n}
	return save


## Buka sesi baru modul n (sinyal disambung pemanggil SEBELUM tampilkan).
func _buka_modul(n: int) -> RuangBelajarUI:
	var rb := RuangBelajarUI.new()
	add_child(rb)
	rb.tampilkan("Ust. Sanusi", _save_modul(n))
	return rb


## Tekan opsi cek ke-idx (0 = "Paham", 1 = "Belum").
func _tekan_cek(rb: RuangBelajarUI, chat, idx: int) -> void:
	var opsi: Array = chat.cari(rb.node_saat_ini()).get("opsi", [])
	rb._on_cek_ditekan(opsi[idx])


## Jalan dari node saat ini sampai target (cek dijawab Paham).
## Pengaman 40 langkah supaya tidak macet bila node baru.
func _jalan_sampai(rb: RuangBelajarUI, chat, target: String) -> void:
	var pengaman := 0
	while rb.node_saat_ini() != target and pengaman < 40:
		pengaman += 1
		rb._selesaikan_bicara()
		var nod: Dictionary = chat.cari(rb.node_saat_ini())
		if String(nod.get("tipe", "")) == "cek":
			_tekan_cek(rb, chat, 0)
		else:
			rb._lanjut_pesan()
	# Selesaikan bicara di node target (tanpa ini, opsi cek di
	# node target belum tampil karena masih mengetik).
	rb._selesaikan_bicara()


## Jalan dari node saat ini sampai l1. cek_belum = id cek yang
## dijawab "Belum" (1x) — cek lain dijawab "Paham".
func _ke_l1(rb: RuangBelajarUI, chat, cek_belum: Array = []) -> void:
	var pengaman := 0
	while rb.node_saat_ini() != "l1" and pengaman < 40:
		pengaman += 1
		rb._selesaikan_bicara()
		var nod: Dictionary = chat.cari(rb.node_saat_ini())
		if String(nod.get("tipe", "")) == "cek":
			var idx := 1 if cek_belum.has(String(nod.get("id", ""))) else 0
			_tekan_cek(rb, chat, idx)
		else:
			rb._lanjut_pesan()
	rb._selesaikan_bicara()


## Jawab l1..l5 + k1 semua benar (pertama coba), sampai penutup.
func _jawab_semua_benar(rb: RuangBelajarUI, chat) -> void:
	for i in range(5):
		var id := "l%d" % (i + 1)
		rb._selesaikan_bicara()
		rb._on_soal_ditekan(chat.benar_soal(chat.cari(id)))
		rb._selesaikan_bicara()
		rb._lanjut_pesan()
	rb._selesaikan_bicara()
	rb._on_soal_ditekan(chat.benar_soal(chat.cari("k1")))
	rb._selesaikan_bicara()
	rb._lanjut_pesan()
	rb._selesaikan_bicara()


func _ready() -> void:
	for cfg in MODUL:
		var n: int = cfg["n"]
		var chat = _chat_modul(n)
		var bank = _bank_modul(n)
		var tag := "M0%d" % n

		# ---------- A. Data (naskah v4 Laras + DataModul0X) ----------
		_cek(tag + " Data: SPINE %d + jumlah_pesan %d" % [cfg["spine"], cfg["spine"]], chat.SPINE.size() == cfg["spine"] and chat.jumlah_pesan() == cfg["spine"])
		_cek(tag + " Data: NARASI %d + NOD 8" % cfg["narasi"], chat.NARASI.size() == cfg["narasi"] and chat.NOD.size() == 8)
		_cek(tag + " Data: node pertama p1 (sapaan)", chat.id_pertama() == "p1" and String(chat.cari("p1").get("teks", "")).contains("Assalamu'alaikum"))
		_cek(tag + " Data: 4 cek (c1-c4) + 4 ulang (u1-u4, TIDAK di SPINE)", chat.cari("c1").get("tipe", "") == "cek" and chat.cari("c4").get("tipe", "") == "cek" and not chat.SPINE.has("u1") and not chat.SPINE.has("u4"))
		_cek(tag + " Data: poin 10+15+10+5 = 40", chat.POIN_MATERI == 10 and chat.POIN_LATIHAN == 15 and chat.POIN_KUIS == 10 and chat.POIN_TUGAS == 5 and chat.POIN_TOTAL == 40)
		_cek(tag + " Data: fase_node narasi/latihan/kuis/penutup/tugas/selesai", chat.fase_node("p1") == "narasi" and chat.fase_node("n1") == "narasi" and chat.fase_node("c1") == "narasi" and chat.fase_node("u1") == "narasi" and chat.fase_node("p_latihan") == "narasi" and chat.fase_node("l1") == "latihan" and chat.fase_node("k1") == "kuis" and chat.fase_node("penutup") == "penutup" and chat.fase_node("tugas") == "tugas" and chat.fase_node("") == "selesai")
		var u: Array = cfg["u"]
		_cek(tag + " Data: indeks_progres u1-u4 (slot cek)", chat.indeks_progres("u1") == u[0] and chat.indeks_progres("u2") == u[1] and chat.indeks_progres("u3") == u[2] and chat.indeks_progres("u4") == u[3])
		var idx: Dictionary = cfg["idx"]
		_cek(tag + " Data: indeks_progres p1/p_latihan/l1/k1/penutup/tugas", chat.indeks_progres("p1") == 0 and chat.indeks_progres("p_latihan") == idx["p_latihan"] and chat.indeks_progres("l1") == idx["l1"] and chat.indeks_progres("k1") == idx["k1"] and chat.indeks_progres("penutup") == idx["penutup"] and chat.indeks_progres("tugas") == idx["tugas"])
		_cek(tag + " Data: jalur_log u1/u4/l3", chat.jalur_log("u1").size() == (u[0] + 1) and chat.jalur_log("u4").size() == cfg["jalur_u4"] and chat.jalur_log("l3").size() == cfg["resume_l3"])
		_cek(tag + " Data: soal l1-l5 bank latihan 0-4, k1 bank kuis 0", chat.cari("l1").get("soal", -1) == 0 and chat.cari("l5").get("soal", -1) == 4 and chat.cari("k1").get("bank", "") == "kuis")
		var jwb: Array = cfg["jawaban"]
		var jwb_ok := true
		for i in range(5):
			if chat.benar_soal(chat.cari("l%d" % (i + 1))) != jwb[i]:
				jwb_ok = false
		_cek(tag + " Data: jawaban latihan %s + k1 %d (dari DataModul0%d)" % [str(jwb), cfg["k1"], n], jwb_ok and chat.benar_soal(chat.cari("k1")) == cfg["k1"])
		var kj: Array = cfg["kuis_jawaban"]
		var kj_ok := true
		for i in range(10):
			if int((bank.kuis_soal()[i] as Dictionary).get("jawaban", -1)) != kj[i]:
				kj_ok = false
		_cek(tag + " Data: bank kuis 10 soal, jawaban %s" % str(kj), bank.kuis_soal().size() == 10 and bank.latihan_soal().size() == 5 and kj_ok)
		_cek(tag + " Data: poin DataModul 10+15+10 = 35", bank.POIN_MATERI + bank.POIN_LATIHAN + bank.POIN_HAFALAN == 35)
		var ada_sekali_lagi := false
		var ada_mengetik := false
		for nd in chat.NARASI:
			var t := String(nd.get("teks", ""))
			if t.contains("Sekali lagi"):
				ada_sekali_lagi = true
			if t.contains("mengetik"):
				ada_mengetik = true
		for nd in chat.NOD:
			var t2 := String(nd.get("teks", ""))
			if t2.contains("Sekali lagi"):
				ada_sekali_lagi = true
			if t2.contains("mengetik"):
				ada_mengetik = true
		_cek(tag + " Data: TIDAK ADA 'Sekali lagi' / 'mengetik' di naskah", not ada_sekali_lagi and not ada_mengetik)
		var target_hilang := false
		for nd in chat.NARASI:
			for o in (nd.get("opsi", []) as Array):
				if chat.cari(String((o as Dictionary).get("ke", ""))).is_empty():
					target_hilang = true
			if String(nd.get("berikut", "")) != "" and chat.cari(String(nd.get("berikut", ""))).is_empty():
				target_hilang = true
		_cek(tag + " Data: semua target opsi 'ke' + 'berikut' ada", not target_hilang)
		_cek(tag + " Data: cek c1 Paham->%s, Belum->u1; u1 berikut->%s" % [cfg["c1_ke"], cfg["c1_ke"]], String((chat.cari("c1").get("opsi", []) as Array)[0].get("ke", "")) == cfg["c1_ke"] and String((chat.cari("c1").get("opsi", []) as Array)[1].get("ke", "")) == "u1" and String(chat.cari("u1").get("berikut", "")) == cfg["c1_ke"])
		_cek(tag + " Data: cek c2 Paham->%s, Belum->u2; u2 berikut->%s" % [cfg["c2_ke"], cfg["c2_ke"]], String((chat.cari("c2").get("opsi", []) as Array)[0].get("ke", "")) == cfg["c2_ke"] and String((chat.cari("c2").get("opsi", []) as Array)[1].get("ke", "")) == "u2" and String(chat.cari("u2").get("berikut", "")) == cfg["c2_ke"])
		_cek(tag + " Data: penutup tipe 'pesan' + tugas ada", String(chat.cari("penutup").get("tipe", "")) == "pesan" and String(chat.cari("tugas").get("tipe", "")) == "tugas")

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
		rb.tampilkan("Ust. Sanusi", _save_modul(n))
		_cek(tag + " B: buka -> node p1, sedang bicara, pilihan kosong", rb.visible and rb.node_saat_ini() == "p1" and rb.sedang_bicara() and _jumlah_pilihan(rb) == 0)
		_cek(tag + " B: papan pertama NAHWU DASAR + kemajuan p1/narasi/p1 (modul %d)" % n, rb_papan == [["NAHWU DASAR", PackedStringArray([cfg["judul"]])]] and rb_kemajuan == [["p1", n, "narasi", "p1"]])
		_cek(tag + " B: TIDAK ADA 'mengetik' / 'dari %d' di panel" % cfg["spine"], not _ada_teks(rb, "mengetik") and not _ada_teks(rb, "dari %d" % cfg["spine"]))
		_ketuk(rb)
		_cek(tag + " B: ketuk gelembung saat bicara -> tampil penuh + tombol Lanjut (node tetap p1)", not rb.sedang_bicara() and rb.node_saat_ini() == "p1" and _jumlah_pilihan(rb) == 1 and _teks_pilihan(rb)[0] == "Lanjut ›")
		_ketuk(rb)
		_cek(tag + " B: ketuk gelembung setelah selesai -> lanjut ke n1", rb.node_saat_ini() == "n1")
		rb._selesaikan_bicara()
		await get_tree().create_timer(1.5).timeout
		_cek(tag + " B: TANPA ketuk, 1,5 dtk berlalu -> node TETAP n1 (tidak ada auto-advance)", rb.node_saat_ini() == "n1")
		_jalan_sampai(rb, chat, "c1")
		_cek(tag + " B: sampai c1 + 2 opsi (Paham/Belum) aktif penuh, tidak terkunci", rb.node_saat_ini() == "c1" and _jumlah_pilihan(rb) == 2 and _teks_pilihan(rb) == ["Paham, lanjut ›", "Belum, jelaskan lagi"] and not rb.ada_tombol_terkunci())
		_tekan_cek(rb, chat, 0)
		_cek(tag + " B: Paham di c1 -> %s + gelembung player tampil" % cfg["c1_ke"], rb.node_saat_ini() == cfg["c1_ke"] and rb._gelembung_box.visible and String(rb._gelembung_label.text) == "Paham, lanjut ›")
		_ke_l1(rb, chat)
		_cek(tag + " B: sampai l1 + materi 10 emit SEKALI (di p_latihan)", rb.node_saat_ini() == "l1" and rb_langkah == [["materi", 10]])
		_cek(tag + " B: kemajuan di l1 = latihan + node_terakhir p_latihan", (rb_kemajuan[-1] as Array) == ["l1", n, "latihan", "p_latihan"])
		_jawab_semua_benar(rb, chat)
		_cek(tag + " B: latihan 15 + kuis 10 setelah semua benar", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10]])
		_cek(tag + " B: sampai penutup + papan TUNTAS", rb.node_saat_ini() == "penutup" and (rb_papan[-1] as Array)[0] == "TUNTAS")
		_cek(tag + " B: papan %d judul s.d. penutup, pertama NAHWU DASAR, terakhir TUNTAS" % (cfg["spine"] - 1), rb_papan.size() == cfg["spine"] - 1 and (rb_papan[0] as Array)[0] == "NAHWU DASAR" and (rb_papan[-1] as Array)[0] == "TUNTAS")
		_cek(tag + " B: kemajuan %d node s.d. penutup + fase penutup di penutup" % (cfg["spine"] - 1), rb_kemajuan.size() == cfg["spine"] - 1 and (rb_kemajuan[-1] as Array) == ["penutup", n, "penutup", "p_latihan"])
		_cek(tag + " B: TIDAK ADA tombol terkunci sepanjang alur", not rb.ada_tombol_terkunci())
		rb._lanjut_pesan()
		rb._selesaikan_bicara()
		_cek(tag + " B: penutup lanjut -> tugas + papan TUGAS + tombol Terima Tugas", rb.node_saat_ini() == "tugas" and (rb_papan[-1] as Array)[0] == "TUGAS" and _teks_pilihan(rb) == ["Terima Tugas ✓"])
		rb._on_terima_tugas()
		_cek(tag + " B: Terima Tugas -> tugas 5 + tombol jadi Tutup", rb_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10], ["tugas", 5]] and _teks_pilihan(rb) == ["Tutup"])
		rb._on_tutup_penutup()
		_cek(tag + " B: Tutup tugas -> selesai(40) + ditutup + kemajuan dibersihkan (fase selesai)", rb_selesai_ev == [40] and rb_ditutup_ev.size() == 1 and (rb_kemajuan[-1] as Array) == ["", n, "selesai", "p_latihan"])
		rb.queue_free()

		# ---------- C. "Belum" maks 1x per cek ----------
		var rb2 := _buka_modul(n)
		var rb2_langkah: Array = []
		rb2.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb2_langkah.append([jenis, poin]))
		_jalan_sampai(rb2, chat, "c1")
		_cek(tag + " C: sampai c1", rb2.node_saat_ini() == "c1")
		_tekan_cek(rb2, chat, 1)
		_cek(tag + " C: Belum di c1 -> u1 (ulang, contoh lain)", rb2.node_saat_ini() == "u1" and rb2._teks_penuh.contains(String(cfg["u1_teks"])))
		rb2._selesaikan_bicara()
		rb2._lanjut_pesan()
		_cek(tag + " C: Lanjut dari u1 -> %s (tidak ada Belum ke-2)" % cfg["c1_ke"], rb2.node_saat_ini() == cfg["c1_ke"])
		_jalan_sampai(rb2, chat, "c2")
		_tekan_cek(rb2, chat, 1)
		_cek(tag + " C: Belum di c2 -> u2", rb2.node_saat_ini() == "u2" and rb2._teks_penuh.contains(String(cfg["u2_teks"])))
		rb2._selesaikan_bicara()
		rb2._lanjut_pesan()
		_cek(tag + " C: Lanjut dari u2 -> %s" % cfg["c2_ke"], rb2.node_saat_ini() == cfg["c2_ke"])
		_ke_l1(rb2, chat)
		_cek(tag + " C: setelah 2x Belum (cek berbeda) sampai l1 + materi 10 SEKALI", rb2.node_saat_ini() == "l1" and rb2_langkah == [["materi", 10]])
		_jawab_semua_benar(rb2, chat)
		rb2._lanjut_pesan()
		rb2._selesaikan_bicara()
		rb2._on_terima_tugas()
		rb2._on_tutup_penutup()
		_cek(tag + " C: alur selesai setelah Belum (40 poin)", rb2_langkah == [["materi", 10], ["latihan", 15], ["kuis", 10], ["tugas", 5]])
		rb2.queue_free()

		# ---------- D. Salah -> teguran -> soal diulang, opsi salah HILANG ----------
		var rb3 := _buka_modul(n)
		_ke_l1(rb3, chat)
		rb3._selesaikan_bicara()
		_cek(tag + " D: di l1, tampil 4 opsi", rb3.node_saat_ini() == "l1" and _jumlah_pilihan(rb3) == 4)
		var benar_l1 := chat.benar_soal(chat.cari("l1"))
		var salah_l1 := (benar_l1 + 1) % 4
		var teks_salah: String = String((chat.opsi_soal(chat.cari("l1")) as Array)[salah_l1])
		rb3._on_soal_ditekan(salah_l1)
		_cek(tag + " D: jawaban salah -> teguran 'Belum tepat'", rb3._teks_penuh.contains("Belum tepat"))
		rb3._selesaikan_bicara()
		rb3._lanjut_pesan()
		rb3._selesaikan_bicara()
		_cek(tag + " D: soal diulang, opsi salah HILANG (3 opsi) + tidak ada tombol terkunci", rb3.node_saat_ini() == "l1" and _jumlah_pilihan(rb3) == 3 and not _teks_pilihan(rb3).has(teks_salah) and not rb3.ada_tombol_terkunci())
		rb3._on_soal_ditekan(benar_l1)
		_cek(tag + " D: jawaban benar -> pujian 'Benar!'", rb3._teks_penuh.contains("Benar!"))
		rb3.queue_free()

		# ---------- E. Resume ----------
		var save_resume := _save_modul(n)
		save_resume["rb_chat_pos"] = "l3"
		save_resume["rb_chat_modul"] = n
		save_resume["rb_fase"] = "latihan"
		save_resume["rb_node_terakhir"] = "p_latihan"
		var rb4x := RuangBelajarUI.new()
		add_child(rb4x)
		rb4x.tampilkan("Ust. Sanusi", save_resume)
		_cek(tag + " E: resume l3 -> node l3 + riwayat %d pesan guru" % cfg["resume_l3"], rb4x.node_saat_ini() == "l3" and rb4x.jumlah_riwayat() == cfg["resume_l3"])
		_cek(tag + " E: resume l3 -> sedang bicara (bukan baca ulang)", rb4x.sedang_bicara())
		rb4x.queue_free()
		var save_u2 := _save_modul(n)
		save_u2["rb_chat_pos"] = "u2"
		save_u2["rb_fase"] = "narasi"
		save_u2["rb_node_terakhir"] = "c2"
		var rb4b := RuangBelajarUI.new()
		add_child(rb4b)
		rb4b.tampilkan("Ust. Sanusi", save_u2)
		_cek(tag + " E: resume u2 -> node u2 + riwayat %d (p1..c2)" % cfg["resume_u2"], rb4b.node_saat_ini() == "u2" and rb4b.jumlah_riwayat() == cfg["resume_u2"])
		rb4b.queue_free()
		var save_c3 := _save_modul(n)
		save_c3["rb_chat_pos"] = "c3"
		var rb4c := RuangBelajarUI.new()
		add_child(rb4c)
		rb4c.tampilkan("Ust. Sanusi", save_c3)
		_cek(tag + " E: resume c3 -> node c3 + riwayat %d" % cfg["resume_c3"], rb4c.node_saat_ini() == "c3" and rb4c.jumlah_riwayat() == cfg["resume_c3"])
		rb4c.queue_free()
		var save_parsial := _save_modul(n)
		save_parsial["rb_chat_pos"] = "l1"
		save_parsial["rb_selesai"] = ["%d:materi" % n]
		var rb4d := RuangBelajarUI.new()
		add_child(rb4d)
		rb4d.tampilkan("Ust. Sanusi", save_parsial)
		_cek(tag + " E: selesai SEBAGIAN (baru materi) BUKAN baca ulang", rb4d.node_saat_ini() == "l1" and rb4d.sedang_bicara())
		rb4d.queue_free()

		# ---------- F. Baca ulang (tuntas) tanpa poin ----------
		var save_tuntas := _save_modul(n)
		save_tuntas["rb_selesai"] = ["%d:materi" % n, "%d:latihan" % n, "%d:kuis" % n]
		var rb5 := RuangBelajarUI.new()
		add_child(rb5)
		var rb5_langkah: Array = []
		var rb5_selesai_ev: Array = []
		var rb5_ditutup_ev: Array = []
		rb5.langkah_selesai.connect(func(jenis: String, poin: int) -> void: rb5_langkah.append([jenis, poin]))
		rb5.selesai.connect(func(total: int) -> void: rb5_selesai_ev.append(total))
		rb5.ditutup.connect(func() -> void: rb5_ditutup_ev.append(true))
		rb5.tampilkan("Ust. Sanusi", save_tuntas)
		_cek(tag + " F: baca ulang -> p1 tampil penuh tanpa bicara + riwayat %d" % cfg["spine"], rb5.node_saat_ini() == "p1" and not rb5.sedang_bicara() and rb5.jumlah_riwayat() == cfg["spine"])
		for i in range(int(cfg["spine"]) - 1):
			rb5._lanjut_pesan()
		_cek(tag + " F: baca ulang jalan sampai tugas (cek dilewati via Lanjut)", rb5.node_saat_ini() == "tugas")
		_cek(tag + " F: baca ulang tugas -> langsung Tutup (tanpa Terima Tugas)", _teks_pilihan(rb5) == ["Tutup"])
		rb5._on_tutup_penutup()
		_cek(tag + " F: baca ulang Tutup -> TANPA poin + hanya ditutup", rb5_langkah.is_empty() and rb5_selesai_ev.is_empty() and rb5_ditutup_ev.size() == 1)
		rb5.queue_free()

	# ---------- G. Dispatch UI per modul + fallback ----------
	for n in [1, 2, 3, 4]:
		var rb := _buka_modul(n)
		_cek("G: modul %d -> _chat = DataChatModul0%d" % [n, n], rb._chat == _chat_modul(n))
		rb.queue_free()
	var rb5x := _buka_modul(5)
	_cek("G: modul 5 (Jurumiyah, belum ada) -> fallback DataChatModul01 + papan Modul 01", rb5x._chat == DataChatModul01 and rb5x.node_saat_ini() == "p1" and String(_chat_modul(1).cari("p1").get("teks", "")).contains("Modul 01"))
	rb5x.queue_free()

	# ---------- H. Bank Tes Kenaikan N2/N3/N4 + N5 belum ada ----------
	for cfg2 in MODUL:
		var tes := TesKenaikanUI.new()
		add_child(tes)
		var bagian := "N%d" % cfg2["n"]
		tes.tampilkan(bagian)
		# Pertanyaan dirender buat_label_campur (satu label PER
		# KATA) — jadi yang dicek teks utuh opsi A soal 1 (Button),
		# bukan kalimat pertanyaan penuh.
		_cek("H: %s bank ADA + opsi A soal 1 tampil ('%s')" % [bagian, cfg2["tes_soal1"]], tes.visible and tes._bank_tersedia and tes._mesin.dimulai() and _ada_teks(tes, String(cfg2["tes_soal1"])) and not _ada_teks(tes, "belum tersedia"))
		tes.tutup()
		tes.queue_free()
	var tes5 := TesKenaikanUI.new()
	add_child(tes5)
	tes5.tampilkan("N5")
	_cek("H: N5 bank belum ada -> 'belum tersedia' tanpa crash", tes5.visible and not tes5._bank_tersedia and _ada_teks(tes5, "belum tersedia"))
	tes5.tutup()
	tes5.queue_free()

	# ---------- I. Cek sumber wiring ----------
	var src_rb := _isi_file("res://scripts/ui_misi/ruang_belajar_ui.gd")
	_cek("I: UI punya dispatch _chat (match _modul + _chat = DataChatModul02/03/04)", src_rb.contains("match _modul:") and src_rb.contains("_chat = DataChatModul02") and src_rb.contains("_chat = DataChatModul03") and src_rb.contains("_chat = DataChatModul04"))
	_cek("I: UI TIDAK ADA lagi DataChatModul01. di kode (kecuali default + fallback)", not src_rb.contains("DataChatModul01.cari") and not src_rb.contains("DataChatModul01.SPINE") and not src_rb.contains("DataChatModul01.POIN"))
	var src_ob := _isi_file("res://scripts/onboarding.gd")
	_cek("I: Onboarding ambang hatam = MODUL_TERAKHIR_NAHWU (4), JUMLAH_MODUL tetap 30", src_ob.contains("const MODUL_TERAKHIR_NAHWU := 4") and src_ob.contains(">= MODUL_TERAKHIR_NAHWU") and src_ob.contains("const JUMLAH_MODUL := 30"))
	var src_tes := _isi_file("res://scripts/ui_misi/tes_kenaikan_ui.gd")
	_cek("I: TesKenaikanUI pakai DataModul02/03/04.kuis_soal()", src_tes.contains("DataModul02.kuis_soal()") and src_tes.contains("DataModul03.kuis_soal()") and src_tes.contains("DataModul04.kuis_soal()"))

	print("TES RUANG BELAJAR V4 MODUL 02-04: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
