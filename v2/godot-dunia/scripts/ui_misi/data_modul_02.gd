class_name DataModul02
extends RefCounted
## Data Modul 02 — Nahwu Dasar, Bagian 2: Isim Lebih Dalam.
## (Sinta, 22 Nov 23:05, pola data_modul_01.gd; sumber
## ruang-belajar-nahwu-dasar-02-isim-lebih-dalam.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai".)
## Bank ini dipakai Tes Kenaikan N2.T dan chat Ruang Belajar
## (DataChatModul02.opsi_soal()/benar_soal()).
## Latihan A (5 soal) dikonversi dari isian ke pilihan ganda
## (opsi dari jawaban + distractor jalan makrifat); Kuis (10 soal)
## verbatim dari modul. Item DITAHAN (daftar lengkap muannats
## samai) tetap tidak diajarkan — hanya 4 contoh paling sering.

const JUDUL := "Nahwu Dasar — Modul 02"
const SUBJUDUL := "Isim Lebih Dalam • Bagian 2"
const MATERI_JUDUL := "Makrifat dan Nakiroh"
const MATERI_TEKS := "Makrifat menunjuk yang sudah tertentu dan dikenal; nakiroh masih umum."
const MATERI_ARAB := "جَاءَتِ الطَّالِبَةُ إِلَى الْمَدْرَسَةِ"
const MATERI_TRANSLITERASI := "Jaa-at ath-thaalibatu ila al-madrasati — \"Siswi itu datang ke sekolah.\""
const MATERI_CATATAN := "Ath-thaalibatu makrifat (diawali al-), muannats (ta marbuthah), musytaq (isim fa'il dari thalaba)."
const KARTU_KATA := [
	{"nama": "MAKRIFAT", "ciri": "dhamir • alam • isyarah", "arti": "sudah dikenal"},
	{"nama": "NAKIROH", "ciri": "bertanwin", "arti": "masih umum"},
	{"nama": "MUSYTAQ", "ciri": "fa'il • maf'ul • makan", "arti": "dibentuk dari fi'il"},
]
const RUMUS := [
	"Sudah dikenal? Makrifat. Masih umum? Nakiroh.",
	"Ada ta marbuthah atau alif? Itu muannats.",
	"Ada fi'il asalnya? Itu musytaq.",
]
const BAIT := "\"Isim itu ada yang makrifat — dikenal jelas — dan ada yang nakiroh — masih umum sifatnya.\""

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_HAFALAN := 10


## Latihan A Modul 02 (5 soal) — dikonversi dari isian ke
## pilihan ganda: tiap soal 4 opsi (jawaban + 3 distractor dari
## daftar jawaban Latihan A: Nakiroh, 5 jalan makrifat).
static func latihan_soal() -> Array:
	return [
		{
			"pertanyaan": "Kata سَيَّارَةٌ (sayyaaratun — sebuah mobil) makrifat atau nakiroh?",
			"opsi": ["Nakiroh", "Makrifat — diawali al-", "Makrifat — nama diri", "Makrifat — kata penunjuk"],
			"jawaban": 0,
			"petunjuk": "masih umum (sebuah mobil, siapa saja)",
		},
		{
			"pertanyaan": "Kata السَّيَّارَةُ (as-sayyaaratu — mobil itu) makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?",
			"opsi": ["Nakiroh", "Makrifat — diawali al-", "Makrifat — nama diri", "Makrifat — disandarkan ke makrifat"],
			"jawaban": 1,
			"petunjuk": "diawali al- (as-sayyaaratu)",
		},
		{
			"pertanyaan": "Kata فَاطِمَةُ (Faathimatu — Fatimah) makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?",
			"opsi": ["Nakiroh", "Makrifat — diawali al-", "Makrifat — nama diri", "Makrifat — kata ganti"],
			"jawaban": 2,
			"petunjuk": "nama diri (Faathimatu)",
		},
		{
			"pertanyaan": "Kata هَذَا (haadzaa — ini) makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?",
			"opsi": ["Nakiroh", "Makrifat — diawali al-", "Makrifat — nama diri", "Makrifat — kata penunjuk"],
			"jawaban": 3,
			"petunjuk": "kata penunjuk / isyarah (haadzaa)",
		},
		{
			"pertanyaan": "Kata بَيْتُ الْمُعَلِّمِ (baitu al-mu'allimi — rumah guru itu) makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?",
			"opsi": ["Nakiroh", "Makrifat — diawali al-", "Makrifat — disandarkan ke makrifat", "Makrifat — kata penunjuk"],
			"jawaban": 2,
			"petunjuk": "disandarkan ke makrifat (al-mu'allimi makrifat karena al-)",
		},
	]


## Kuis Modul 02 (10 soal) — verbatim dari modul; jawaban
## SEMUA A (indeks 0), sesuai Kunci Kuis modul.
static func kuis_soal() -> Array:
	return [
		{
			"pertanyaan": "Apa beda makrifat dan nakiroh?",
			"opsi": ["Makrifat menunjuk yang sudah tertentu dan dikenal; nakiroh masih umum, belum menunjuk yang tertentu", "Makrifat masih umum; nakiroh sudah tertentu dan dikenal", "Makrifat hanya untuk nama orang; nakiroh hanya untuk benda", "Tidak ada bedanya"],
			"jawaban": 0,
			"petunjuk": "Makrifat menunjuk yang sudah tertentu dan dikenal; nakiroh masih umum.",
		},
		{
			"pertanyaan": "Kenapa nama diri tetap makrifat walau bertanwin?",
			"opsi": ["Karena nama diri menunjuk orang tertentu, walau bertanwin", "Karena tanwin membuat kata menjadi makrifat", "Karena nama diri tidak pernah bertanwin", "Karena semua kata bertanwin adalah makrifat"],
			"jawaban": 0,
			"petunjuk": "Nama diri menunjuk orang tertentu, walau bertanwin (Muhammadun tetap makrifat).",
		},
		{
			"pertanyaan": "Manakah tiga tanda muannats?",
			"opsi": ["Ta marbuthah, alif maqshurah, alif mamdudah", "Tanwin, al-, huruf jer", "Qad, sin, saufa", "Dhammah, fathah, kasrah"],
			"jawaban": 0,
			"petunjuk": "Tiga tanda muannats: ta marbuthah, alif maqshurah, alif mamdudah.",
		},
		{
			"pertanyaan": "Manakah contoh muannats tanpa tanda?",
			"opsi": ["syamsun (matahari)", "qamarun (bulan)", "kitaabun (kitab)", "rajulun (laki-laki)"],
			"jawaban": 0,
			"petunjuk": "syamsun (matahari) — muannats tanpa tanda, contoh paling sering.",
		},
		{
			"pertanyaan": "Apa beda jamid dan musytaq?",
			"opsi": ["Jamid kata dasar yang tidak diambil dari kata lain; musytaq dibentuk dari fi'il", "Jamid dibentuk dari fi'il; musytaq kata dasar yang berdiri sendiri", "Jamid hanya untuk benda; musytaq hanya untuk orang", "Tidak ada bedanya"],
			"jawaban": 0,
			"petunjuk": "Jamid kata dasar yang berdiri sendiri; musytaq dibentuk dari fi'il.",
		},
		{
			"pertanyaan": "Kata كَاتِبٌ — kaatibun (penulis) jamid atau musytaq? Dari fi'il apa?",
			"opsi": ["Musytaq, dari kataba (menulis)", "Jamid, tidak punya fi'il asal", "Musytaq, dari darasa (belajar)", "Jamid, dari kataba (menulis)"],
			"jawaban": 0,
			"petunjuk": "kaatibun musytaq (isim fa'il) dari kataba.",
		},
		{
			"pertanyaan": "Kata مَكْتُوبٌ — maktuubun artinya apa dan bentukan apa?",
			"opsi": ["Yang ditulis; isim maf'ul", "Penulis; isim fa'il", "Tempat menulis; isim makan", "Kunci; isim alat"],
			"jawaban": 0,
			"petunjuk": "maktuubun = yang ditulis; isim maf'ul.",
		},
		{
			"pertanyaan": "Golongkan kata الْمَدْرَسَةُ — al-madrasatu (sekolah itu):",
			"opsi": ["Makrifat (al-) dan muannats (ta marbuthah)", "Nakiroh dan mudzakar", "Makrifat (al-) dan mudzakar", "Nakiroh dan muannats (ta marbuthah)"],
			"jawaban": 0,
			"petunjuk": "al-madrasatu: makrifat (al-) dan muannats (ta marbuthah).",
		},
		{
			"pertanyaan": "Kata بَيْتُ الْمُعَلِّمِ — baitu al-mu'allimi (rumah guru itu) menjadi makrifat lewat jalan apa?",
			"opsi": ["Disandarkan ke makrifat (al-mu'allimi)", "Diawali al- secara langsung", "Kata ganti (dhamir)", "Kata penunjuk (isyarah)"],
			"jawaban": 0,
			"petunjuk": "baitu al-mu'allimi makrifat karena disandarkan ke makrifat (al-mu'allimi).",
		},
		{
			"pertanyaan": "Kata مَنْصُورٌ — manshuurun (yang ditolong) jamid atau musytaq?",
			"opsi": ["Musytaq, dari nashara (menolong) — isim maf'ul", "Jamid, tidak punya fi'il asal", "Musytaq, dari kataba (menulis)", "Jamid, dari nashara (menolong)"],
			"jawaban": 0,
			"petunjuk": "manshuurun musytaq (isim maf'ul) dari nashara.",
		},
	]
