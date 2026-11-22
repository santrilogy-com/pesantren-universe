class_name DataModul04
extends RefCounted
## Data Modul 04 — Nahwu Dasar, Bagian 4: Keadaan Isim.
## (Sinta, 22 Nov 23:05, pola data_modul_01.gd; sumber
## ruang-belajar-nahwu-dasar-04-keadaan-isim.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai".)
## Bank ini dipakai Tes Kenaikan N4.T dan chat Ruang Belajar
## (DataChatModul04.opsi_soal()/benar_soal()).
## Latihan A (8 soal) — dipakai 5 soal pertama (l1–l5 = indeks
## 0–4), dikonversi dari isian ke pilihan ganda (opsi dari daftar
## kedudukan marfu'/manshub/makhfudh); Kuis (10 soal) verbatim
## dari modul. Item DITAHAN (syarat isim laa nafi jins, rincian
## bentuk munada) tetap tidak diajarkan.
## Modul ini MENUTUP Nahwu Dasar — penutup mengarah ke Jurumiyah.

const JUDUL := "Nahwu Dasar — Modul 04"
const SUBJUDUL := "Keadaan Isim • Bagian 4"
const MATERI_JUDUL := "Tiga keadaan isim"
const MATERI_TEKS := "Marfu' dibaca u, manshub dibaca a, makhfudh dibaca i — mengikuti kedudukan kata dalam kalimat."
const MATERI_ARAB := "كَتَبَ الطَّالِبُ الدَّرْسَ فِي الْفَصْلِ بِالْقَلَمِ"
const MATERI_TRANSLITERASI := "Kataba ath-thaalibu ad-darsa fi al-fashli bi al-qalami — \"Siswa itu menulis pelajaran di kelas dengan pena.\""
const MATERI_CATATAN := "Tanya dulu kedudukannya apa, baru tahu bacaannya."
const KARTU_KATA := [
	{"nama": "MARFU'", "ciri": "u • dhammah", "arti": "fa'il • mubtada • khabar"},
	{"nama": "MANSHUB", "ciri": "a • fathah", "arti": "maf'ul bih • hal • zharaf"},
	{"nama": "MAKHFUDH", "ciri": "i • kasrah", "arti": "setelah huruf jer • idhafah"},
]
const RUMUS := [
	"Pelaku atau pokok kalimat? Marfu' — dibaca u.",
	"Objek atau keterangan? Manshub — dibaca a.",
	"Setelah huruf jer atau disandarkan? Makhfudh — dibaca i.",
]
const BAIT := "\"Rafa'-kan fa'il, nashob-kan maf'ul, dan jer-kan dengan huruf jer atau idhafah — niscaya kamu sampai.\""

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_HAFALAN := 10


## Latihan A Modul 04 (5 soal pertama dari 8) — dikonversi
## dari isian ke pilihan ganda: tiap soal 4 opsi kedudukan
## (jawaban + 3 distractor dari daftar kedudukan modul).
static func latihan_soal() -> Array:
	return [
		{
			"pertanyaan": "Kata الْمُعَلِّمُ dalam حَضَرَ الْمُعَلِّمُ (guru itu hadir) kedudukannya apa?",
			"opsi": ["Fa'il — marfu' — dhammah", "Maf'ul bih — manshub — fathah", "Mubtada — marfu' — dhammah", "Naib fa'il — marfu' — dhammah"],
			"jawaban": 0,
			"petunjuk": "pelaku perbuatan hadhara (hadir)",
		},
		{
			"pertanyaan": "Kata الْمَاءَ dalam شَرِبْتُ الْمَاءَ (saya minum air itu) kedudukannya apa?",
			"opsi": ["Fa'il — marfu' — dhammah", "Maf'ul bih — manshub — fathah", "Isim setelah huruf jer — makhfudh — kasrah", "Mudhaf ilaih — makhfudh — kasrah"],
			"jawaban": 1,
			"petunjuk": "objek yang diminum; menjawab \"minum apa?\"",
		},
		{
			"pertanyaan": "Kata السُّوقِ dalam ذَهَبْتُ إِلَى السُّوقِ (saya pergi ke pasar) kedudukannya apa?",
			"opsi": ["Fa'il — marfu' — dhammah", "Maf'ul bih — manshub — fathah", "Isim setelah huruf jer — makhfudh — kasrah", "Mubtada — marfu' — dhammah"],
			"jawaban": 2,
			"petunjuk": "di-jer oleh huruf jer ila",
		},
		{
			"pertanyaan": "Kata الْمَسْجِدُ dalam الْمَسْجِدُ كَبِيرٌ (masjid itu besar) kedudukannya apa?",
			"opsi": ["Fa'il — marfu' — dhammah", "Mubtada — marfu' — dhammah", "Naib fa'il — marfu' — dhammah", "Maf'ul bih — manshub — fathah"],
			"jawaban": 1,
			"petunjuk": "pokok kalimat isim; pasangannya kabiirun (khabar)",
		},
		{
			"pertanyaan": "Kata الطَّالِبِ dalam هَذَا كِتَابُ الطَّالِبِ (ini kitab siswa itu) kedudukannya apa?",
			"opsi": ["Mudhaf ilaih — makhfudh — kasrah", "Isim setelah huruf jer — makhfudh — kasrah", "Mubtada — marfu' — dhammah", "Fa'il — marfu' — dhammah"],
			"jawaban": 0,
			"petunjuk": "kata kedua dalam sandaran kitaabu ath-thaalibi",
		},
	]


## Kuis Modul 04 (10 soal) — verbatim dari modul; jawaban
## SEMUA A (indeks 0), sesuai Kunci Kuis modul.
static func kuis_soal() -> Array:
	return [
		{
			"pertanyaan": "Sebutkan semua kedudukan marfu' yang dipelajari di Bagian 4.",
			"opsi": ["Fa'il, naib fa'il, mubtada, khabar, isim kaana, khabar inna, isim laa nafi jins", "Fa'il, naib fa'il, mubtada, khabar, maf'ul bih, maf'ul muthlaq, zharaf", "Fa'il, mubtada, khabar, maf'ul bih, hal, tamyiz, mudhaf ilaih", "Mubtada, khabar, isim kaana, khabar inna, maf'ul fih, mustatsna, munada"],
			"jawaban": 0,
			"petunjuk": "Tujuh kedudukan marfu': fa'il, naib fa'il, mubtada, khabar, isim kaana, khabar inna, isim laa nafi jins.",
		},
		{
			"pertanyaan": "Sebutkan lima kedudukan manshub yang dipelajari di tabel hal. 64.",
			"opsi": ["Zharaf (maf'ul fih), hal, tamyiz, mustatsna, munada", "Maf'ul bih, maf'ul muthlaq, fa'il, mubtada, khabar", "Zharaf, hal, tamyiz, mudhaf ilaih, isim setelah huruf jer", "Munada, mustatsna, naib fa'il, khabar inna, isim kaana"],
			"jawaban": 0,
			"petunjuk": "Lima kedudukan manshub di tabel hal. 64: zharaf (maf'ul fih), hal, tamyiz, mustatsna, munada.",
		},
		{
			"pertanyaan": "Sebutkan dua sebab isim di-jer (makhfudh).",
			"opsi": ["Setelah huruf jer, dan sebagai mudhaf ilaih (disandarkan dalam idhafah)", "Setelah kaana, dan setelah inna", "Sebagai fa'il, dan sebagai mubtada", "Setelah fi'il madhi, dan setelah fi'il mudhori'"],
			"jawaban": 0,
			"petunjuk": "Dua sebab isim di-jer: setelah huruf jer, dan sebagai mudhaf ilaih dalam idhafah.",
		},
		{
			"pertanyaan": "Beri i'rob: نَجَحَ الْمُجْتَهِدُ — najaha al-mujtahidu (orang yang bersungguh-sungguh itu berhasil).",
			"opsi": ["Najaha fi'il madhi mabni; al-mujtahidu fa'il, marfu' dengan dhammah", "Najaha fi'il mudhori' marfu'; al-mujtahidu maf'ul bih, manshub dengan fathah", "Najaha fi'il madhi mabni; al-mujtahidu mubtada, marfu' dengan dhammah", "Najaha fi'il amar mabni; al-mujtahidu naib fa'il, marfu' dengan dhammah"],
			"jawaban": 0,
			"petunjuk": "Najaha fi'il madhi mabni; al-mujtahidu pelakunya — fa'il, marfu' dengan dhammah.",
		},
		{
			"pertanyaan": "Beri i'rob: أُكْرِمَ الضَّيْفُ — ukrima adh-dhaifu (tamu itu dimuliakan).",
			"opsi": ["Ukrima fi'il madhi majhul mabni; adh-dhaifu naib fa'il, marfu' dengan dhammah", "Ukrima fi'il madhi ma'lum mabni; adh-dhaifu fa'il, marfu' dengan dhammah", "Ukrima fi'il madhi majhul mabni; adh-dhaifu maf'ul bih, manshub dengan fathah", "Ukrima fi'il mudhori' majhul marfu'; adh-dhaifu mubtada, marfu' dengan dhammah"],
			"jawaban": 0,
			"petunjuk": "Ukrima fi'il madhi majhul (pelaku tidak disebut); adh-dhaifu naik menjadi naib fa'il, marfu' dengan dhammah.",
		},
		{
			"pertanyaan": "Beri i'rob: مَرَرْتُ بِالْمُعَلِّمِ — marartu bi al-mu'allimi (saya berpapasan dengan guru itu).",
			"opsi": ["Marartu fi'il madhi mabni; bi huruf jer; al-mu'allimi isim setelah huruf jer, makhfudh dengan kasrah", "Marartu fi'il madhi mabni; bi huruf jer; al-mu'allimi maf'ul bih, manshub dengan fathah", "Marartu fi'il mudhori' marfu'; bi huruf jer; al-mu'allimi fa'il, marfu' dengan dhammah", "Marartu fi'il madhi mabni; bi huruf jer; al-mu'allimi mudhaf ilaih, makhfudh dengan kasrah"],
			"jawaban": 0,
			"petunjuk": "Marartu fi'il madhi mabni; bi huruf jer; al-mu'allimi isim setelah huruf jer, makhfudh dengan kasrah.",
		},
		{
			"pertanyaan": "Apa beda fa'il dan naib fa'il?",
			"opsi": ["Fa'il adalah pelaku dalam kalimat ma'lum dan disebut terang-terangan; naib fa'il adalah pengganti pelaku dalam kalimat majhul — pelakunya dibuang, objek naik menggantikannya, dan kedudukannya tetap marfu'", "Fa'il adalah pelaku dalam kalimat majhul; naib fa'il adalah pelaku dalam kalimat ma'lum", "Fa'il selalu manshub; naib fa'il selalu marfu'", "Fa'il dan naib fa'il sama saja, bedanya hanya pada harakat akhir fi'ilnya"],
			"jawaban": 0,
			"petunjuk": "Fa'il = pelaku kalimat ma'lum yang disebut; naib fa'il = pengganti pelaku dalam kalimat majhul, pelaku dibuang, objek naik, tetap marfu'.",
		},
		{
			"pertanyaan": "Apa beda mubtada dan fa'il?",
			"opsi": ["Mubtada adalah pokok kalimat isim — di awal kalimat, pasangannya khabar; fa'il adalah pelaku setelah fi'il dalam kalimat fi'liyah. Keduanya marfu'", "Mubtada adalah pelaku setelah fi'il; fa'il adalah pokok kalimat isim di awal kalimat", "Mubtada selalu manshub; fa'il selalu marfu'", "Mubtada pasangannya maf'ul bih; fa'il pasangannya khabar"],
			"jawaban": 0,
			"petunjuk": "Mubtada = pokok kalimat isim di awal, pasangannya khabar; fa'il = pelaku setelah fi'il. Keduanya marfu'.",
		},
		{
			"pertanyaan": "Baca dan i'rob kalimat ini: يَقْرَأُ الطَّالِبُ الْقُرْآنَ فِي الْمَسْجِدِ — yaqra-u ath-thaalibu al-qur-aana fi al-masjidi (siswa itu membaca Al-Qur'an di masjid).",
			"opsi": ["Yaqra-u fi'il mudhori' marfu' dengan dhammah (tanpa penashob dan penjazim); ath-thaalibu fa'il, marfu' dengan dhammah; al-qur-aana maf'ul bih, manshub dengan fathah; fi huruf jer; al-masjidi isim setelah huruf jer, makhfudh dengan kasrah", "Yaqra-u fi'il mudhori' manshub dengan fathah; ath-thaalibu fa'il, marfu' dengan dhammah; al-qur-aana maf'ul bih, manshub dengan fathah; fi huruf jer; al-masjidi isim setelah huruf jer, makhfudh dengan kasrah", "Yaqra-u fi'il mudhori' marfu' dengan dhammah; ath-thaalibu mubtada, marfu' dengan dhammah; al-qur-aana maf'ul bih, manshub dengan fathah; fi huruf jer; al-masjidi isim setelah huruf jer, makhfudh dengan kasrah", "Yaqra-u fi'il mudhori' marfu' dengan dhammah; ath-thaalibu fa'il, marfu' dengan dhammah; al-qur-aana hal, manshub dengan fathah; fi huruf jer; al-masjidi mudhaf ilaih, makhfudh dengan kasrah"],
			"jawaban": 0,
			"petunjuk": "Yaqra-u mudhori' marfu' (tanpa penashob/penjazim); ath-thaalibu fa'il; al-qur-aana maf'ul bih; al-masjidi setelah huruf jer fi, makhfudh.",
		},
		{
			"pertanyaan": "Kenapa akhir kata berubah dalam bahasa Arab?",
			"opsi": ["Karena kedudukan kata dalam kalimat berubah — i'rob mengikuti kedudukan: marfu' bila jadi pelaku/pokok, manshub bila jadi objek/keterangan, makhfudh bila setelah huruf jer atau disandarkan", "Karena jumlah huruf kata itu berubah-ubah", "Karena akhir kata mengikuti jenis kelamin pembicaranya", "Karena setiap kata Arab memang dibaca dengan harakat yang acak"],
			"jawaban": 0,
			"petunjuk": "Akhir kata berubah karena kedudukan (i'rob) berubah — rafa'/nashob/jer mengikuti kedudukan dalam kalimat.",
		},
	]
