class_name DataModul01
## Data Modul 01 Nahwu Dasar "Mengenal Kata" — Fase A, A9 (Wulan).
## LOGIKA/DATA MURNI, tanpa UI: tampilan Ruang Belajar dikerjakan
## Sinta, mesin kuisnya A1 (MesinKuis), wiring gelombang 2 oleh Raka.
##
## TEKS DRAF — isi menunggu tashih Mas (§9 butir 17 / Modul 01).
## Semua isi dari Modul 01 (ruang-belajar-nahwu-dasar-01-
## mengenal-kata.md, Tim Kurikulum — MENUNGGU TASHIH MAS) dan
## mockup ruang-belajar-v1.png / tes-kenaikan-v1.png (DI-ACC Mas).
## Branding: "Pesantren Universe" (rebrand total DIKUNCI Mas 18:55
## — JANGAN tulis "Verse").
##
## Format soal = format MesinKuis:
##   {"pertanyaan": String, "opsi": Array[String] (tepat 4),
##    "jawaban": int (0..3, indeks opsi benar)}
## Soal latihan memakai kunci ekstra "petunjuk" (string alasan
## dari kunci jawaban Modul 01) — MesinKuis.soal_valid() mengabaikan
## kunci ekstra, jadi soal tetap valid untuk mesin kuis.

## Judul modul (mockup Ruang Belajar).
const JUDUL := "Nahwu Dasar — Modul 01"
const SUBJUDUL := "Mengenal Kata • Bagian 1 (Hijau)"

## Materi §1 Modul 01 (mockup Ruang Belajar — "Apa itu kalam?").
const MATERI_JUDUL := "Apa itu kalam?"
const MATERI_TEKS := "Kalam adalah susunan kata yang memberi arti sempurna, sehingga pendengar tidak bertanya lagi."
const MATERI_ARAB := "قَامَ مُحَمَّدٌ"
const MATERI_TRANSLITERASI := "Qaama Muhammadun — \"Muhammad telah berdiri.\""
const MATERI_CATATAN := "Kenali cirinya, bukan hafalan definisinya."

## Tiga kartu kata (mockup Ruang Belajar — Modul 01 §2-4).
const KARTU_KATA: Array[Dictionary] = [
	{"nama": "ISIM", "ciri": "tanwin • al- • jer", "arti": "kata benda & nama"},
	{"nama": "FI'IL", "ciri": "qad • sin • saufa", "arti": "kata kerja & waktu"},
	{"nama": "HURUF", "ciri": "penghubung kecil", "arti": "bermakna bila digabung"},
]

## Rumus 10 detik (mockup Ruang Belajar — Modul 01 §5).
const RUMUS: Array[String] = [
	"Ada tanwin atau al-? Itu isim.",
	"Ada qad, sin, atau saufa? Itu fi'il.",
	"Kata pendek penghubung? Itu huruf.",
]

## Bait hafalan Bagian 1 (Modul 01 — bait orisinal Pesantren Universe,
## bukan kutipan kitab; pilihan bait vs kutipan Jurumiyah menunggu
## tashih Mas — pertanyaan tashih no. 1).
const BAIT := "\"Kata itu tiga, hafalkanlah: isim, fi'il, dan huruf yang datang untuk suatu makna — maka ketahuilah ia.\""

## Poin jenis misi (draf §2.1).
const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_HAFALAN := 10


## Latihan Ruang Belajar: 5 soal pilihan ganda (format MesinKuis).
## Konversi MEKANIS Latihan A Modul 01 soal 1-5 (isian: tentukan
## jenis kata + alasan) -> pilihan ganda; opsi selalu
## ["Isim", "Fi'il", "Huruf", "Kalam"], jawaban dari kunci
## Latihan A, "petunjuk" = alasan dari kunci jawaban Modul 01.
## Soal 6-8 Latihan A TIDAK dipakai (latihan UI = 5 soal sesuai
## mockup Ruang Belajar: "latihan 5 soal").
static func latihan_soal() -> Array:
	return [
		{
			"pertanyaan": "Kata مَدْرَسَةٌ (madrasatun — sekolah) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 0,
			"petunjuk": "bertanwin",
		},
		{
			"pertanyaan": "Kata يَقْرَأُ (yaqra'u — dia sedang membaca) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 1,
			"petunjuk": "kata kerja mudhori', terikat waktu",
		},
		{
			"pertanyaan": "Kata عَلَى ('alaa — di atas) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 2,
			"petunjuk": "kata penghubung, tidak berciri isim maupun fi'il",
		},
		{
			"pertanyaan": "Kata قَلَمٌ (qalamun — pena) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 0,
			"petunjuk": "bertanwin",
		},
		{
			"pertanyaan": "Kata جَلَسَ (jalasa — dia telah duduk) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 1,
			"petunjuk": "kata kerja madhi, perbuatan lampau",
		},
	]


## Kuis / Tes Kenaikan N1.T: 10 soal PERSIS Kuis Modul 01 soal 1-10
## + kunci (soal 1-2 sama persis dengan kuis M1/M3 di game).
## Bank ini dipakai Tes Kenaikan N1.T (ambang lulus 8/10 — draf
## §2.1 / Onboarding.TES_LULUS_MINIMAL) dan soal ke-1 dipakai kuis
## langkah Ruang Belajar. Modul 01 masih menunggu tashih Mas.
static func kuis_soal() -> Array:
	return [
		{
			"pertanyaan": "Apa yang dipelajari ilmu Nahwu?",
			"opsi": ["Perubahan akhir kata (i'rab)", "Cara menghafal Al-Quran", "Sejarah Islam", "Cara berwudhu"],
			"jawaban": 0,
		},
		{
			"pertanyaan": "Manakah yang termasuk isim?",
			"opsi": ["kitabun (kitab)", "kataba (dia menulis)", "fi (di dalam)", "min (dari)"],
			"jawaban": 0,
		},
		{
			"pertanyaan": "Kata yang menunjukkan benda tanpa terikat waktu disebut ...",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 0,
		},
		{
			"pertanyaan": "Kata يَذْهَبُ (yadzhabu — dia sedang / akan pergi) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 1,
		},
		{
			"pertanyaan": "Kata إِلَى (ilaa — ke / kepada) termasuk jenis kata apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 2,
		},
		{
			"pertanyaan": "Apa beda isim mabni dan isim mu'rob?",
			"opsi": ["Mabni akhir katanya tetap, mu'rob akhir katanya berubah mengikuti kedudukan", "Mabni akhir katanya berubah, mu'rob akhir katanya tetap", "Mabni hanya untuk fi'il, mu'rob hanya untuk isim", "Tidak ada bedanya"],
			"jawaban": 0,
		},
		{
			"pertanyaan": "Manakah yang termasuk isim mabni?",
			"opsi": ["kitabun (sebuah kitab)", "huwa (dia, laki-laki)", "ath-thaalibu (siswa itu)", "qalamun (pena)"],
			"jawaban": 1,
		},
		{
			"pertanyaan": "Manakah contoh isim mu'rob dalam tiga keadaan (u, a, i)?",
			"opsi": ["huwa – huwa – huwa", "kitabun – kitaban – kitabin", "haadzaa – haadzaa – haadzaa", "man – man – man"],
			"jawaban": 1,
		},
		{
			"pertanyaan": "Dalam kalimat خَرَجَ الْمُعَلِّمُ مِنَ الْفَصْلِ (Kharaja al-mu'allimu min al-fashli — \"Guru itu keluar dari kelas\"), kata مِنَ (min) termasuk jenis apa?",
			"opsi": ["Isim", "Fi'il", "Huruf", "Kalam"],
			"jawaban": 2,
		},
		{
			"pertanyaan": "Apa arti kalam?",
			"opsi": ["Susunan kata yang memberi arti sempurna, sehingga pendengar tidak bertanya lagi", "Kata benda yang tidak terikat waktu", "Kata kerja yang terikat waktu", "Kata penghubung yang kecil"],
			"jawaban": 0,
		},
	]
