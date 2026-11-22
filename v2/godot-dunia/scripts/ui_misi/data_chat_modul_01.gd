class_name DataChatModul01
extends RefCounted
## Data percakapan Ruang Belajar Modul 01 — NARASI TEKS, LANJUT
## MANUAL (keputusan Mas 22 Nov 2026, 16:03 WIB: karakter BERHENTI
## dulu, project Godot lanjut; misi Ruang Belajar pindah dari VIDEO
## ke TEKS — narasi guru ditulis detail dan lengkap, pakai dialog
## TETAP, tapi TIDAK otomatis lanjut, pemain yang menentukan).
## Konsep video v3 (KONSEP-RUANG-BELAJAR-v3-VIDEO.md) DITUNDA —
## spike pemutar video (v2/spike-pemutar-video/) TIDAK di-port.
## Data murni, tanpa UI.
##
## Alur 13 node: narasi n1–n5 (guru menjelaskan, SATU PER SATU)
## -> latihan l1–l5 (5 soal) -> kuis k1 (1 soal) -> penutup ->
## tugas (+5). Poin 40 (10 materi / 15 latihan / 10 kuis / 5 tugas).
## Isi soal diambil PERSIS dari DataModul01 (satu sumber kebenaran
## untuk opsi + indeks benar).
##
## Format node NARASI (dipakai Laras untuk naskah Modul 01 asli —
## naskah tinggal ditukar masuk, format sama):
##   {"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi",
##    "teks": narasi guru (detail, lengkap),
##    "papan": {"judul", "baris": [String]} (opsional)}
## "pembicara" di-resolve UI ke pengajar sesi ini (Sanusi putra /
## Fatimah putri) bila isinya nama ustadz — jadi satu naskah bisa
## dipakai dua versi tanpa digandakan.
## Node soal/penutup/tugas memakai kunci yang sama seperti dulu
## ("id", "tipe", "teks", "bank", "soal", "benar", "salah", "papan").

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TUGAS := 5
const POIN_TOTAL := 40

## Tulang punggung linear (13 node) — dipakai bilah progres
## (tanpa teks penghitung — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
const SPINE: Array[String] = ["n1", "n2", "n3", "n4", "n5", "l1", "l2", "l3", "l4", "l5", "k1", "penutup", "tugas"]

## Narasi guru — 5 NODE CONTOH (Sinta, 22 Nov 2026) supaya mekanik
## bisa dites. Isi CONTOH ini fakta-nya sama dengan DataModul01
## (kalam, isim, fi'il, huruf, rumus, bait) — hanya bentuknya
## narasi guru yang detail. Naskah Modul 01 ASLI sedang ditulis
## Laras secara paralel dengan format {pembicara, teks} yang sama;
## begitu naskahnya jadi, 5 node ini DIGANTI naskah Laras.
const NARASI: Array = [
	{"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar — Modul 01: Mengenal Kata. Nahwu itu ilmu tentang perubahan akhir kata. Kenapa akhir kata bisa berubah? Karena kedudukan kata di dalam kalimat berubah. Contohnya kata 'kitab' — kalau dia pelaku, akhirnya 'kitabun'; kalau dia objek, 'kitaban'; kalau dia setelah huruf jer, 'kitabin'. Tiga keadaan, tiga bunyi. Itulah yang dipelajari Nahwu. Kita pelan-pelan ya, satu demi satu.", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 01 — Mengenal Kata", "akhir kata berubah = i'rab"]}},
	{"id": "n2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertama, kita kenali dulu apa itu kalam. Kalam itu susunan kata yang memberi arti sempurna, sehingga pendengar tidak bertanya lagi. Contohnya: 'Qaama Muhammadun' — Muhammad telah berdiri. Pendengar langsung paham, tidak bertanya lagi. Tapi kalau saya hanya bilang 'Muhammad' saja — kamu pasti bertanya: Muhammad kenapa? Itu belum kalam, karena artinya belum sempurna. Jadi, kalam itu bukan sekadar kata-kata yang disusun — tapi susunan yang memberi arti sempurna. Ingat ya: kalam = susunan kata yang memberi arti sempurna.", "papan": {"judul": "KALAM", "baris": ["kalam = susunan kata", "arti sempurna, pendengar paham"]}},
	{"id": "n3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kata itu ada tiga macam. Pertama, isim — kata benda dan nama. Cirinya ada tiga: tanwin, al-, dan jer. Tanwin itu bunyi 'n' di akhir kata, seperti madrasatun — sekolah. Al- itu seperti al-kitabu — kitab itu. Dan jer itu kata setelah huruf jer, seperti 'fi al-madrasati' — di dalam sekolah. Kalau kamu lihat ada tanwin atau al-, itu pasti isim. Contohnya: qalamun — pena, kitabun — kitab, madrasatun — sekolah. Semuanya isim.", "papan": {"judul": "ISIM", "baris": ["tanwin • al- • jer", "madrasatun — sekolah"]}},
	{"id": "n4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedua, fi'il — kata kerja yang terikat waktu. Cirinya: qad, sin, dan saufa. Qad itu 'sungguh' atau 'telah', sin itu 'akan', saufa itu 'akan' juga tapi lebih jauh. Contohnya: yaqra'u — dia sedang membaca. Itu fi'il mudhori', waktunya sekarang. Jalasa — dia telah duduk. Itu fi'il madhi, waktunya lampau. Jadi kalau kata itu perbuatan dan terikat waktu — lampau, sekarang, atau akan datang — itu fi'il. Beda dengan isim yang tidak terikat waktu.", "papan": {"judul": "FI'IL", "baris": ["qad • sin • saufa", "yaqra'u — dia membaca"]}},
	{"id": "n5", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Ketiga, huruf — kata penghubung yang kecil. Dia baru bermakna bila digabung dengan kata lain. Contohnya 'alaa — di atas. Sendirian, 'alaa tidak memberi arti. Tapi 'al-kitabu 'alaa ath-thaawilati' — kitab itu di atas meja — baru bermakna. Nah, ada rumus cepatnya, hafalkan ini: ada tanwin atau al-? Itu isim. Ada qad, sin, atau saufa? Itu fi'il. Kata pendek penghubung? Itu huruf. Terakhir, hafalkan bait ini: 'Kata itu tiga, hafalkanlah: isim, fi'il, dan huruf yang datang untuk suatu makna — maka ketahuilah ia.' Sudah? Kalau sudah, kita latihan.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Kata itu tiga,", "isim, fi'il, dan huruf"]}},
]

const NOD: Array = [
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — madrasatun (sekolah) itu jenis kata apa?", "papan": {"judul": "LATIHAN 1", "baris": ["madrasatun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Madrasatun bertanwin — jadi isim. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "yaqra'u (dia sedang membaca) itu jenis kata apa?", "papan": {"judul": "LATIHAN 2", "baris": ["yaqra'u = ?", "terikat waktu → fi'il"]}, "benar": "Benar! Kata kerja mudhori', terikat waktu.", "salah": "Belum tepat. Yaqra'u itu kata kerja mudhori' — terikat waktu. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "'alaa (di atas) itu jenis kata apa?", "papan": {"judul": "LATIHAN 3", "baris": ["'alaa = ?", "penghubung → huruf"]}, "benar": "Benar! Kata penghubung, tidak berciri isim maupun fi'il.", "salah": "Belum tepat. 'Alaa itu kata penghubung. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "qalamun (pena) itu jenis kata apa?", "papan": {"judul": "LATIHAN 4", "baris": ["qalamun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Qalamun bertanwin. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "jalasa (dia telah duduk) itu jenis kata apa?", "papan": {"judul": "LATIHAN 5", "baris": ["jalasa = ?", "lampau → fi'il"]}, "benar": "Benar! Kata kerja madhi, perbuatan lampau.", "salah": "Belum tepat. Jalasa itu kata kerja madhi. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: Apa yang dipelajari ilmu Nahwu?", "papan": {"judul": "KUIS", "baris": ["Nahwu = ?", "perubahan akhir kata"]}, "benar": "Benar! Nahwu itu ilmu tentang perubahan akhir kata (i'rab).", "salah": "Belum tepat. Nahwu itu ilmu tentang perubahan akhir kata (i'rab). Coba lagi."},
	{"id": "penutup", "tipe": "pesan", "teks": "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin. Sekarang, satu tugas terakhir dariku.", "papan": {"judul": "TUNTAS", "baris": ["Modul 01 — 35 poin"]}},
	{"id": "tugas", "tipe": "tugas", "teks": "Tugasmu: hafalkan baitnya, lalu baca 1 bab di rak kitab. Kalau sudah, kembali ke saya — atau langsung lanjut tes kenaikan di Surau.", "papan": {"judul": "TUGAS", "baris": ["hafalkan baitnya", "baca 1 bab di rak kitab"]}},
]


## Cari node berdasarkan id ({} bila tidak ada) — narasi dulu,
## lalu latihan/kuis/penutup/tugas.
static func cari(id: String) -> Dictionary:
	for n in NARASI:
		if String(n.get("id", "")) == id:
			return n
	for n in NOD:
		if String(n.get("id", "")) == id:
			return n
	return {}


## Id node pertama ("n1").
static func id_pertama() -> String:
	return SPINE[0]


## Jumlah node tulang punggung (13) — penyebut bilah progres.
static func jumlah_pesan() -> int:
	return SPINE.size()


## Posisi node di tulang punggung (0..12) untuk bilah progres.
static func indeks_progres(id: String) -> int:
	if SPINE.has(id):
		return SPINE.find(id)
	return 0


## Fase sesi belajar untuk kunci save rb_fase (Sinta, 22 Nov 2026).
static func fase_node(id: String) -> String:
	if id == "":
		return "selesai"
	if id.begins_with("n"):
		return "narasi"
	if id.begins_with("l"):
		return "latihan"
	if id == "k1":
		return "kuis"
	if id == "penutup":
		return "penutup"
	if id == "tugas":
		return "tugas"
	return ""


## Node guru yang pesannya tampil di Riwayat saat resume di
## resume_id (jalur linear; jawaban player saat resume tidak
## tersimpan, jadi Riwayat resume berisi pesan ustadz saja).
static func jalur_log(resume_id: String) -> Array[String]:
	var out: Array[String] = []
	for id in SPINE:
		if id == resume_id:
			break
		out.append(id)
	return out


## Opsi jawaban sebuah node soal dari DataModul01 (satu sumber
## kebenaran untuk opsi + indeks benar). Latihan: 5 soal, opsi
## sama; kuis: soal pertama bank N1.T.
static func opsi_soal(nod: Dictionary) -> Array:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul01.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return bank[idx].get("opsi", [])
		return []
	var lat: Array = DataModul01.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return lat[idx2].get("opsi", [])
	return []


## Indeks jawaban benar sebuah node soal dari DataModul01
## (kunci "jawaban" — lihat DataModul01.latihan_soal()).
static func benar_soal(nod: Dictionary) -> int:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul01.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return int(bank[idx].get("jawaban", 0))
		return 0
	var lat: Array = DataModul01.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return int(lat[idx2].get("jawaban", 0))
	return 0
