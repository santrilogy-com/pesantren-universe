class_name DataChatModul01
extends RefCounted
## Data percakapan Ruang Belajar Modul 01 — NASKAH §2 konsep
## (v2/konsep/KONSEP-RUANG-BELAJAR-CHAT-v1.md). Data murni, tanpa UI.
## Alur 14 pesan + cabang "Belum" maks 2x + poin 35 (10 materi /
## 15 latihan / 10 kuis). Isi diambil PERSIS dari DataModul01 —
## hanya diubah bentuknya dari kartu/soal menjadi kalimat ustadz.
##
## Node:
##   {"id", "tipe": "pesan"|"cek"|"soal"|"penutup",
##    "teks": kalimat ustadz (untuk soal = pertanyaan ustadz §2),
##    "opsi": [{"teks", "ke": id node berikut}] (cek + pesan b2),
##    "bank": "latihan"|"kuis", "soal": indeks ke DataModul01 (soal),
##    "benar"/"salah": kalimat ustadz saat jawaban benar/salah (soal),
##    "papan": {"judul", "baris": [String]} (opsional — bila tidak ada,
##    papan menampilkan isi node terakhir, lihat §8)}
## Target "ulang" (opsi Belum di m7) = pseudo-target yang ditangani
## UI: ulang materi dari m2, maks 1x penuh, lalu lanjut ke latihan
## apa pun jawabannya.

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TOTAL := 35

## Tulang punggung linear (14 pesan §2) — dipakai bilah progres
## (tanpa teks "Pesan X dari 14" — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
const SPINE: Array[String] = ["m1", "m2", "m3", "m4", "m5", "m6", "m7", "l1", "l2", "l3", "l4", "l5", "k1", "penutup"]

const NOD: Array = [
	{"id": "m1", "tipe": "pesan", "teks": "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar — Modul 01: Mengenal Kata.", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 01 — Mengenal Kata"]}},
	{"id": "m2", "tipe": "cek", "teks": "kalam itu artinya adalah susunan kalimat. Kalimat disini maksudnya adalah kata dalam bahasa indonesia. Paham?", "papan": {"judul": "KALAM", "baris": ["kalam = susunan kalimat", "kata = isim • fi'il • huruf"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "m3"}, {"teks": "Belum, jelaskan lagi", "ke": "b1"}]},
	{"id": "b1", "tipe": "cek", "teks": "Baik, coba contoh ini: Qaama Muhammadun — 'Muhammad telah berdiri.' Itu kalam, karena pendengar sudah paham dan tidak bertanya lagi. Kalau saya hanya bilang 'Muhammad' saja, kamu pasti bertanya: Muhammad kenapa? Itu belum kalam. Paham sekarang?", "papan": {"judul": "CONTOH", "baris": ["Qaama Muhammadun", "Muhammad telah berdiri.", "Itu kalam."]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "m3"}, {"teks": "Belum, jelaskan lagi", "ke": "b2"}]},
	{"id": "b2", "tipe": "pesan", "teks": "Tidak apa-apa, pelan-pelan. Ingat saja ini: kalam = susunan kata yang memberi arti sempurna. Kita lanjut dulu, nanti ketemu lagi di latihan. Siap?", "papan": {"judul": "KALAM", "baris": ["kalam = susunan kata", "yang memberi arti sempurna"]}, "opsi": [{"teks": "Siap, lanjut", "ke": "m3"}]},
	{"id": "m3", "tipe": "pesan", "teks": "Kata itu ada tiga macam. Pertama, isim — kata benda dan nama. Cirinya: tanwin, al-, dan jer. Contohnya madrasatun — sekolah.", "papan": {"judul": "ISIM", "baris": ["tanwin • al- • jer", "madrasatun — sekolah"]}},
	{"id": "m4", "tipe": "pesan", "teks": "Kedua, fi'il — kata kerja yang terikat waktu. Cirinya: qad, sin, dan saufa. Contohnya yaqra'u — dia sedang membaca.", "papan": {"judul": "FI'IL", "baris": ["qad • sin • saufa", "yaqra'u — dia membaca"]}},
	{"id": "m5", "tipe": "pesan", "teks": "Ketiga, huruf — kata penghubung yang kecil. Dia baru bermakna bila digabung dengan kata lain. Contohnya 'alaa — di atas.", "papan": {"judul": "HURUF", "baris": ["kata penghubung kecil", "'alaa — di atas"]}},
	{"id": "m6", "tipe": "pesan", "teks": "Ada rumus cepatnya — hafalkan ini: ada tanwin atau al-? Itu isim. Ada qad, sin, atau saufa? Itu fi'il. Kata pendek penghubung? Itu huruf.", "papan": {"judul": "RUMUS 10 DETIK", "baris": ["tanwin/al- → isim", "qad/sin/saufa → fi'il", "penghubung → huruf"]}},
	{"id": "m7", "tipe": "cek", "teks": "Terakhir, hafalkan bait ini: 'Kata itu tiga, hafalkanlah: isim, fi'il, dan huruf yang datang untuk suatu makna — maka ketahuilah ia.' Sudah paham semua? Kalau sudah, kita latihan.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Kata itu tiga,", "isim, fi'il, dan huruf"]}, "opsi": [{"teks": "Paham, mulai latihan", "ke": "l1"}, {"teks": "Belum, ulangi dari awal", "ke": "ulang"}]},
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — madrasatun (sekolah) itu jenis kata apa?", "papan": {"judul": "LATIHAN 1", "baris": ["madrasatun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Madrasatun bertanwin — jadi isim. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "yaqra'u (dia sedang membaca) itu jenis kata apa?", "papan": {"judul": "LATIHAN 2", "baris": ["yaqra'u = ?", "terikat waktu → fi'il"]}, "benar": "Benar! Kata kerja mudhori', terikat waktu.", "salah": "Belum tepat. Yaqra'u itu kata kerja mudhori' — terikat waktu. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "'alaa (di atas) itu jenis kata apa?", "papan": {"judul": "LATIHAN 3", "baris": ["'alaa = ?", "penghubung → huruf"]}, "benar": "Benar! Kata penghubung, tidak berciri isim maupun fi'il.", "salah": "Belum tepat. 'Alaa itu kata penghubung. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "qalamun (pena) itu jenis kata apa?", "papan": {"judul": "LATIHAN 4", "baris": ["qalamun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Qalamun bertanwin. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "jalasa (dia telah duduk) itu jenis kata apa?", "papan": {"judul": "LATIHAN 5", "baris": ["jalasa = ?", "lampau → fi'il"]}, "benar": "Benar! Kata kerja madhi, perbuatan lampau.", "salah": "Belum tepat. Jalasa itu kata kerja madhi. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: Apa yang dipelajari ilmu Nahwu?", "papan": {"judul": "KUIS", "baris": ["Nahwu = ?", "perubahan akhir kata"]}, "benar": "Benar! Nahwu itu ilmu tentang perubahan akhir kata (i'rab).", "salah": "Belum tepat. Nahwu itu ilmu tentang perubahan akhir kata (i'rab). Coba lagi."},
	{"id": "penutup", "tipe": "penutup", "teks": "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin. Besok kita lanjut Modul 02 — atau langsung tes kenaikan di Surau.", "papan": {"judul": "TUNTAS", "baris": ["Modul 01 — 35 poin"]}},
]


## Cari node berdasarkan id ({} bila tidak ada).
static func cari(id: String) -> Dictionary:
	for n in NOD:
		if String(n.get("id", "")) == id:
			return n
	return {}


## Id node pertama ("m1").
static func id_pertama() -> String:
	return SPINE[0]


## Jumlah pesan tulang punggung (14) — penyebut bilah progres.
static func jumlah_pesan() -> int:
	return SPINE.size()


## Posisi node di tulang punggung (0..13) untuk bilah progres.
## Cabang b1/b2 menempati slot m2 (indeks 1).
static func indeks_progres(id: String) -> int:
	if id == "b1" or id == "b2":
		return 1
	if SPINE.has(id):
		return SPINE.find(id)
	return 0


## Node guru yang pesannya tampil di Riwayat saat resume di
## resume_id (jalur terpendek; cabang b1/b2 hanya bila resume
## memang di dalamnya — jawaban player saat resume tidak
## tersimpan, jadi Riwayat resume berisi pesan ustadz saja).
static func jalur_log(resume_id: String) -> Array[String]:
	if resume_id == "b1":
		return ["m1", "m2"]
	if resume_id == "b2":
		return ["m1", "m2", "b1"]
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
