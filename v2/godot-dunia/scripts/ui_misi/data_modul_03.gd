class_name DataModul03
extends RefCounted
## Data Modul 03 — Nahwu Dasar, Bagian 3: Fi'il dan I'robnya.
## (Sinta, 22 Nov 23:05, pola data_modul_01.gd; sumber
## ruang-belajar-nahwu-dasar-03-fiil-dan-irobnya.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai".)
## Bank ini dipakai Tes Kenaikan N3.T dan chat Ruang Belajar
## (DataChatModul03.opsi_soal()/benar_soal()).
## Latihan A (5 soal) dikonversi dari isian ke pilihan ganda
## (opsi seragam: Madhi / Mudhori' / Amar / Nahi — Nahi distractor,
## muncul di naskah n4); Kuis (10 soal) verbatim dari modul.
## Item DITAHAN (i'lal — perubahan bentuk mu'tal) tetap tidak
## diajarkan — hanya kenali golongan shahih/mu'tal.

const JUDUL := "Nahwu Dasar — Modul 03"
const SUBJUDUL := "Fi'il dan I'robnya • Bagian 3"
const MATERI_JUDUL := "Tiga waktu fi'il"
const MATERI_TEKS := "Fi'il madhi sudah terjadi, mudhori' sedang atau akan terjadi, amar perintah."
const MATERI_ARAB := "لَنْ يَذْهَبَ الطَّالِبُ"
const MATERI_TRANSLITERASI := "Lan yadz-haba ath-thaalibu — \"Siswa itu tidak akan pergi.\""
const MATERI_CATATAN := "Yadz-haba mudhori' manshub karena penashob lan; ath-thaalibu fa'il."
const KARTU_KATA := [
	{"nama": "MADHI", "ciri": "sudah terjadi", "arti": "kataba • nashara"},
	{"nama": "MUDHORI'", "ciri": "anaytu • sedang/akan", "arti": "yaktubu • yanshuru"},
	{"nama": "AMAR", "ciri": "perintah \"kamu\"", "arti": "uktub • unshur"},
]
const RUMUS := [
	"Tanpa penanda di depan mudhori'? Dibaca U — rafa'.",
	"Setelah penashob (an, lan, kai)? Dibaca A — nashob.",
	"Setelah penjazim (lam, lamma, la)? Dibaca sukun — jazm.",
]
const BAIT := "\"Fi'il itu madhi, lalu mudhori', dan amar untuk orang yang kau ajak bicara.\""

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_HAFALAN := 10


## Latihan A Modul 03 (5 soal) — dikonversi dari isian ke
## pilihan ganda; opsi seragam [Madhi, Mudhori', Amar, Nahi].
static func latihan_soal() -> Array:
	return [
		{
			"pertanyaan": "Kata نَصَرَ (nashara — dia telah menolong) madhi, mudhori', atau amar?",
			"opsi": ["Madhi", "Mudhori'", "Amar", "Nahi"],
			"jawaban": 0,
			"petunjuk": "perbuatan yang sudah terjadi",
		},
		{
			"pertanyaan": "Kata يَنْصُرُ (yanshuru — dia sedang/akan menolong) madhi, mudhori', atau amar?",
			"opsi": ["Madhi", "Mudhori'", "Amar", "Nahi"],
			"jawaban": 1,
			"petunjuk": "diawali ya (huruf mudhori'), perbuatan sedang/akan terjadi",
		},
		{
			"pertanyaan": "Kata اُنْصُرْ (unshur — tolonglah!) madhi, mudhori', atau amar?",
			"opsi": ["Madhi", "Mudhori'", "Amar", "Nahi"],
			"jawaban": 2,
			"petunjuk": "perintah kepada orang yang diajak bicara",
		},
		{
			"pertanyaan": "Kata تَعَلَّمَ (ta'allama — dia telah belajar) madhi, mudhori', atau amar?",
			"opsi": ["Madhi", "Mudhori'", "Amar", "Nahi"],
			"jawaban": 0,
			"petunjuk": "perbuatan yang sudah terjadi (walau mazid, tetap madhi menurut waktu)",
		},
		{
			"pertanyaan": "Kata سَيَكْتُبُ (sa-yaktubu — dia akan menulis) madhi, mudhori', atau amar?",
			"opsi": ["Madhi", "Mudhori'", "Amar", "Nahi"],
			"jawaban": 1,
			"petunjuk": "diawali sin + ya mudhori'; sa- menandai akan terjadi",
		},
	]


## Kuis Modul 03 (10 soal) — verbatim dari modul; jawaban
## 1–6 A (0), 7 D (3), 8–10 A (0), sesuai Kunci Kuis modul.
static func kuis_soal() -> Array:
	return [
		{
			"pertanyaan": "Manakah tiga fi'il menurut waktu?",
			"opsi": ["Madhi, mudhori', amar", "Madhi, mudhori', nahi", "Isim, fi'il, huruf", "Mujarrod, mazid, mu'tal"],
			"jawaban": 0,
			"petunjuk": "Tiga fi'il menurut waktu: madhi, mudhori', amar.",
		},
		{
			"pertanyaan": "Apa ciri fi'il mudhori'?",
			"opsi": ["Diawali salah satu huruf mudhori' yang terkumpul dalam kata anaytu: alif, nun, ya, ta", "Bisa diakhiri ta ta'nits sukun untuk pelaku perempuan", "Mabni dan dibentuk dari fi'il mudhori' untuk \"kamu\"", "Huruf aslinya mengandung huruf illat"],
			"jawaban": 0,
			"petunjuk": "Ciri mudhori': diawali salah satu huruf anaytu (alif, nun, ya, ta).",
		},
		{
			"pertanyaan": "Dari kata apa fi'il amar dibentuk?",
			"opsi": ["Dari fi'il mudhori' untuk \"kamu\"", "Dari fi'il madhi untuk \"dia\"", "Dari isim fa'il", "Dari masdar"],
			"jawaban": 0,
			"petunjuk": "Amar dibentuk dari fi'il mudhori' untuk \"kamu\".",
		},
		{
			"pertanyaan": "Apa beda mujarrod dan mazid?",
			"opsi": ["Mujarrod semua hurufnya asli tanpa tambahan; mazid ada huruf tambahan di akar katanya", "Mujarrod ada huruf tambahan di akar katanya; mazid semua hurufnya asli", "Mujarrod butuh objek; mazid cukup pada pelaku saja", "Mujarrod pelakunya disebut; mazid pelakunya disembunyikan"],
			"jawaban": 0,
			"petunjuk": "Mujarrod semua hurufnya asli; mazid ada huruf tambahan di akar katanya.",
		},
		{
			"pertanyaan": "Apa beda muta'addi dan lazim? Manakah pasangan contoh yang benar?",
			"opsi": ["Muta'addi perbuatannya sampai ke objek; lazim cukup pada pelaku saja — contoh: syariba al-maa-a (muta'addi) dan jalasa ath-thaalibu (lazim)", "Muta'addi cukup pada pelaku saja; lazim perbuatannya sampai ke objek — contoh: syariba al-maa-a (lazim) dan jalasa ath-thaalibu (muta'addi)", "Muta'addi dan lazim sama saja, bedanya hanya pada huruf awalnya", "Muta'addi perbuatannya sampai ke objek; lazim cukup pada pelaku saja — contoh: jalasa ath-thaalibu (muta'addi) dan syariba al-maa-a (lazim)"],
			"jawaban": 0,
			"petunjuk": "Muta'addi sampai ke objek (syariba al-maa-a); lazim cukup pada pelaku (jalasa ath-thaalibu).",
		},
		{
			"pertanyaan": "Bagaimana pola fi'il majhul pada madhi?",
			"opsi": ["Awalnya didhammah dan huruf sebelum akhir dikasrah — contoh: kataba menjadi kutiba", "Awalnya didhammah dan huruf sebelum akhir difathah — contoh: kataba menjadi kutiba", "Awalnya difathah dan huruf sebelum akhir dikasrah — contoh: kataba menjadi katiba", "Awalnya disukun dan huruf sebelum akhir didhammah — contoh: kataba menjadi kutuba"],
			"jawaban": 0,
			"petunjuk": "Majhul madhi: awal didhammah, huruf sebelum akhir dikasrah — kataba menjadi kutiba.",
		},
		{
			"pertanyaan": "Manakah jawaban yang memuat KETIGA huruf illat?",
			"opsi": ["Alif", "Waw", "Ya", "Semua benar — alif, waw, dan ya"],
			"jawaban": 3,
			"petunjuk": "Tiga huruf illat: alif, waw, dan ya — ketiganya benar.",
		},
		{
			"pertanyaan": "Kata قَالَ — qaala (dia berkata) shahih atau mu'tal? Jenis apa?",
			"opsi": ["Mu'tal ajwaf (tengah kata alif)", "Shahih (semua huruf asli sehat)", "Mu'tal mitsal (awal kata waw)", "Mu'tal naqish (akhir kata illat)"],
			"jawaban": 0,
			"petunjuk": "qaala mu'tal ajwaf — huruf illat alif di tengah kata.",
		},
		{
			"pertanyaan": "Manakah tiga penashob dan dua penjazim?",
			"opsi": ["Penashob: an, lan, kai — penjazim: lam, lamma", "Penashob: lam, lamma, la — penjazim: an, lan, kai", "Penashob: qad, sin, saufa — penjazim: lam, lan", "Penashob: an, lan, lam — penjazim: kai, hatta"],
			"jawaban": 0,
			"petunjuk": "Penashob: an, lan, kai; penjazim: lam, lamma.",
		},
		{
			"pertanyaan": "Beri i'rob: لَمْ يَنْجَحْ — lam yanjah (dia tidak berhasil). Kenapa akhir katanya sukun?",
			"opsi": ["Majzum, karena didahului penjazim lam; tanda jazm-nya sukun", "Manshub, karena didahului penashob lam; tanda nashob-nya sukun", "Marfu', karena tidak didahului penashob dan penjazim; tanda rafa'-nya sukun", "Mabni, karena lam membuat fi'il menjadi mabni sukun"],
			"jawaban": 0,
			"petunjuk": "lam yanjah majzum karena penjazim lam; tanda jazm fi'il tunggal biasa adalah sukun.",
		},
	]
