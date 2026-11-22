class_name DataChatModul02
extends RefCounted
## Data percakapan Ruang Belajar Modul 02 — NARASI TEKS v4
## (v2/konsep/KONSEP-RUANG-BELAJAR-v4-TEKS.md, pola Modul 01 v4).
## Guru menjelaskan seperti guru beneran — detail dan lengkap — lewat
## dialog chat. TIDAK ada video, TIDAK ada gate tonton, TIDAK ada
## lanjut otomatis: pemain yang menentukan lanjut/tidaknya (tombol
## "Lanjut ›" / tap gelembung); KONSEP + NASKAH v4 DI-ACC Mas
## 22:52 — "Acc semua sampai selesai").
##
## PORT (Sinta, 22 Nov 23:02): NARASI + NOD + SPINE + helper disalin
## dari data_chat_modul_02_v4.gd (naskah Laras — file sumber, TIDAK
## dihapus); class_name tetap DataChatModul02.
##
##
## Sumber SATU-SATUNYA: Modul 02 tashih-lolos
## (ruang-belajar-nahwu-dasar-02-isim-lebih-dalam.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai").
## Tidak ada materi di luar modul. Item DITAHAN tetap TIDAK
## diajarkan: daftar lengkap muannats tanpa tanda (muannats samai)
## — hanya 4 contoh paling sering (syamsun, ardhun, naarun, Maryam).
## Metode Mas "jelaskan, tanyakan, jelaskan, tanyakan" (20 Nov):
## jelaskan pelan-pelan, ulang 2-3x dengan penekanan kata kunci,
## lalu tanyakan ("Paham? Fahimtum?"). Pengulangan pakai variasi
## natural ("Ingat ya", "Coba perhatikan", "Jadi gini",
## "Perhatikan baik-baik") — TANPA "Sekali lagi" (ditolak Mas di
## naskah v7, monoton).
##
## Format node:
##   Narasi: {"id", "tipe": "narasi", "pembicara": "Ust. Sanusi",
##    "teks", "papan": {"judul", "baris": [String]}}
##    ("pembicara" di-resolve UI ke pengajar sesi ini — Sanusi putra /
##    Fatimah putri — bila isinya nama ustadz.)
##   Cek: {"id", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks",
##    "papan", "opsi": [{"teks", "ke": id node berikut}]}
##    ("Belum, jelaskan lagi" membuka SATU node ulang, maks 1x per cek.)
##   Ulang: {"id", "tipe": "narasi", "pembicara": "Ust. Sanusi",
##    "teks", "papan", "berikut": id node berikut}
##    ("berikut" eksplisit — _lanjut_pesan UI sudah menghormatinya;
##    node ulang TIDAK masuk SPINE, jadi resume kembali ke node cek.)
##   Soal/penutup/tugas: kunci sama seperti dulu ("id", "tipe",
##    "teks", "bank", "soal", "benar", "salah", "papan") — TANPA
##    "pembicara" (UI memakai _pengajar sebagai fallback).
##    Penutup tipe "pesan" (UI tidak punya arm "penutup").
##
## Soal (l1-l5, k1) merujuk DataModul02 — file data dibuat Sinta
## saat port (pola data_modul_01.gd: latihan_soal() 5 soal dari
## Latihan A Modul 02, kuis_soal() 10 soal dari Kuis Modul 02;
## l1-l5 = latihan indeks 0-4, k1 = kuis indeks 0).
##
## Aturan lanjut manual (v4 §3): TIDAK ADA lanjut otomatis —
## tiap node maju HANYA bila pemain mengetuk tombol "Lanjut ›"
## atau mengetuk gelembung. Node "cek" maju HANYA lewat tombol
## opsi. "Belum, jelaskan lagi" membuka SATU node ulang (contoh
## lain, bukan pengulangan kata yang sama), maks 1x per cek.
## - Poin materi 10 diberikan saat pemain meninggalkan node narasi
##   terakhir (p_latihan) ke l1.
## - Penyelesaian = sampai node terakhir (tugas diberikan).
##   Poin 35 (10 materi + 15 latihan + 10 kuis) terkunci saat penutup;
##   tugas +5 poin diberikan saat tugas DITERIMA (tombol
##   "Terima Tugas ✓").
##
## Panjang node (terverifikasi skrip): narasi n1-n10 total 808 kata
## (rata-rata ~81 kata/node, rentang 64-101); cek 36-41 kata
## (total 152); ulang 48-52 kata (total 201); p1 51 kata.
## Bait hafalan + rangkuman + tugas diambil PERSIS dari Modul 02.

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TUGAS := 5
const POIN_TOTAL := 40

## Tulang punggung linear (24 node) — dipakai bilah progres
## (tanpa teks penghitung — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
## Node ulang (u1-u4) TIDAK masuk SPINE — mereka menempati slot cek-nya.
const SPINE: Array[String] = ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "c3", "n6", "n7", "c4", "n8", "n9", "n10", "p_latihan", "l1", "l2", "l3", "l4", "l5", "k1", "penutup", "tugas"]

## Narasi guru — naskah Modul 02 ASLI (Laras, 22 Nov 2026).
## p1 sapaan; n1-n10 narasi (tujuan, makrifat/nakiroh, enam jalan
## makrifat, mudzakar/muannats, tanda muannats, jamid/musytaq,
## enam bentukan musytaq, bait hafalan, rangkuman 1-2); c1-c4 cek
## "Paham? Fahimtum?"; u1-u4 ulang (1x per cek); p_latihan
## transisi ke latihan.
const NARASI: Array = [
	{"id": "p1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Assalamu'alaikum, Nak. Hari ini kita lanjut Nahwu Dasar — Modul 02: Isim Lebih Dalam. Kemarin kamu sudah bisa memilah tiga jenis kata. Hari ini kita masuk lebih dalam ke isim: sudah dikenal atau belum, laki-laki atau perempuan, asli atau bentukan. Tiga pertanyaan itu akan kamu pakai di semua bagian berikutnya. Siap?", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 02 — Isim Lebih Dalam"]}},
	{"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Tujuan hari ini sederhana: kamu bisa menggolongkan isim dengan tiga pertanyaan. Sudah dikenal atau belum — makrifat atau nakiroh. Laki-laki atau perempuan — mudzakar atau muannats. Asli atau bentukan — jamid atau musytaq. Tiga pasang ini membuka banyak rahasia kalimat. Contohnya: mubtada itu harus makrifat — rincinya ada di Bagian 4. Dan sifat mengikuti jenis kata yang disifatinya. Jadi, kalau kamu sudah bisa menjawab tiga pertanyaan ini untuk setiap isim, kamu sudah memegang peta isi kalimat. Kita mulai dari pertanyaan pertama.", "papan": {"judul": "TIGA PERTANYAAN", "baris": ["sudah dikenal?", "laki/perempuan?", "asli/bentukan?"]}},
	{"id": "n2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan pertama: sudah dikenal atau belum? Nakiroh adalah isim yang artinya masih umum, belum menunjuk yang tertentu — biasanya bertanwin. Makrifat adalah isim yang menunjuk sesuatu yang sudah tertentu dan dikenal. Perhatikan polanya di kitab: pertama kali disebut nakiroh, setelah dikenal disebut makrifat. Contohnya: jaa-a rajulun tsumma takallama ar-rajulu — 'Datanglah seorang laki-laki, kemudian laki-laki itu berbicara.' Rajulun pertama masih umum — siapa saja. Ar-rajulu kedua sudah dikenal — laki-laki yang tadi datang. Ingat ya: nakiroh itu umum, makrifat itu jelas.", "papan": {"judul": "MAKRIFAT • NAKIROH", "baris": ["nakiroh = umum", "makrifat = dikenal", "rajulun → ar-rajulu"]}},
	{"id": "c1", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — nakiroh itu masih umum dan biasanya bertanwin: rajulun, seorang laki-laki siapa saja. Makrifat itu sudah tertentu dan dikenal: ar-rajulu, laki-laki itu. Polanya di kitab: pertama disebut nakiroh, setelah dikenal disebut makrifat. Paham? Fahimtum?", "papan": {"judul": "CEK — MAKRIFAT", "baris": ["nakiroh = umum", "makrifat = dikenal"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n3"}, {"teks": "Belum, jelaskan lagi", "ke": "u1"}]},
	{"id": "u1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Baik, saya ulangi dengan contoh lain. Kalau saya bilang 'sayyaaratun' — sebuah mobil — kamu tidak tahu mobil yang mana. Itu nakiroh, masih umum. Tapi kalau saya bilang 'as-sayyaaratu' — mobil itu — kamu langsung tahu mobil yang sudah kita bicarakan. Itu makrifat. Satu kata, dua keadaan: umum atau dikenal. Paham sekarang?", "papan": {"judul": "MAKRIFAT — ULANG", "baris": ["sayyaaratun → nakiroh", "as-sayyaaratu → makrifat"]}, "berikut": "n3"},
	{"id": "n3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang, bagaimana sebuah isim menjadi makrifat? Ada enam jalan. Pertama, kata ganti: huwa, anta — dia, kamu. Kedua, nama diri: Muhammadun, Makkatu — Muhammad, Makkah. Ketiga, kata penunjuk: haadzaa, dzaalika — ini, itu. Keempat, kata penghubung: alladzii — yang. Kelima, diawali al-: al-kitaabu — kitab itu. Keenam, disandarkan ke makrifat: kitaabu Muhammadin — kitabnya Muhammad. Dan ingat satu hal penting: nama diri itu makrifat walau bertanwin. Muhammadun tetap menunjuk orang tertentu. Jadi, tanwin bukan satu-satunya tanda nakiroh — lihat dulu jenis katanya.", "papan": {"judul": "6 JALAN MAKRIFAT", "baris": ["dhamir • alam • isyarah", "maushul • al- • idhafah"]}},
	{"id": "n4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan kedua: laki-laki atau perempuan? Mudzakar menunjuk laki-laki, atau kata yang diperlakukan sebagai mudzakar. Muannats menunjuk perempuan, atau kata yang diperlakukan sebagai muannats. Pasangannya jelas: mu'allimun — mu'allimatun, guru laki-laki dan perempuan. Qaa'imun — qaa'imatun, yang berdiri. Jadiidun — jadiidatun, yang baru. Jenis ini menentukan pasangan katanya. Fi'il untuk pelaku perempuan berubah — qaama ath-thaalibu, siswa laki-laki berdiri; qaamat ath-thaalibatu, siswi berdiri. Fi'il kedua memakai ta ta'nits karena pelakunya perempuan. Perhatikan baik-baik: jenis kata ini ikut mengubah fi'ilnya.", "papan": {"judul": "MUDZAKAR • MUANNATS", "baris": ["mu'allimun • mu'allimatun", "qaama → qaamat"]}},
	{"id": "c2", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — enam jalan makrifat: kata ganti, nama diri, kata penunjuk, kata penghubung, diawali al-, dan disandarkan ke makrifat. Dan jenis kata: mudzakar itu laki-laki, muannats itu perempuan — fi'ilnya ikut berubah, qaama jadi qaamat kalau pelakunya perempuan. Paham? Fahimtum?", "papan": {"judul": "CEK — MAKRIFAT", "baris": ["6 jalan makrifat", "qaama → qaamat"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n5"}, {"teks": "Belum, jelaskan lagi", "ke": "u2"}]},
	{"id": "u2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu kata: al-madrasatu. Kata itu diawali al- — jadi makrifat. Dan berakhiran ta marbuthah — jadi muannats. Satu kata, dua jawaban: makrifat dan muannats. Begitu juga kitaabu Muhammadin — kitabnya Muhammad — makrifat karena disandarkan ke nama diri. Pegang dulu dua contoh ini, sisanya menyusul di latihan. Paham sekarang?", "papan": {"judul": "MAKRIFAT — ULANG", "baris": ["al-madrasatu → makrifat", "makrifat + muannats"]}, "berikut": "n5"},
	{"id": "n5", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang tanda-tanda muannats — tiga penanda yang bisa dilihat. Pertama, ta marbuthah: madrasatun — sekolah. Kedua, alif maqshurah: kubraa — paling besar, perempuan. Ketiga, alif mamdudah: hamraa'u — merah, perempuan. Tapi hati-hati: sebagian kata muannats tidak bertanda, dan diketahui dari pemakaian orang Arab. Hafalkan empat contoh yang paling sering ini: syamsun — matahari, ardhun — bumi, naarun — api, dan nama-nama perempuan seperti Maryamu. Daftar lengkapnya sengaja tidak saya ajarkan di sini — cukup hafalkan empat ini dulu, sisanya tanyakan saat membaca kitab.", "papan": {"judul": "TANDA MUANNATS", "baris": ["ta marbuthah • alif", "syamsun • ardhun • naarun"]}},
	{"id": "c3", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — tiga tanda muannats: ta marbuthah seperti madrasatun, alif maqshurah seperti kubraa, dan alif mamdudah seperti hamraa'u. Dan empat yang tanpa tanda: syamsun, ardhun, naarun, dan Maryam — matahari, bumi, api, dan nama perempuan. Paham? Fahimtum?", "papan": {"judul": "CEK — MUANNATS", "baris": ["3 tanda muannats", "4 tanpa tanda"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n6"}, {"teks": "Belum, jelaskan lagi", "ke": "u3"}]},
	{"id": "u3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan dua kata. Madrasatun — berakhiran ta marbuthah — jadi muannats. Syamsun — matahari — tidak bertanda, tapi orang Arab memperlakukannya sebagai muannats, jadi tetap muannats. Tanda itu membantu, tapi tidak semua muannats bertanda. Empat contoh tadi — syamsun, ardhun, naarun, Maryam — hafalkan. Paham sekarang?", "papan": {"judul": "MUANNATS — ULANG", "baris": ["madrasatun → ta marbuthah", "syamsun → tanpa tanda"]}, "berikut": "n6"},
	{"id": "n6", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan ketiga: asli atau bentukan? Jamid adalah kata dasar yang tidak diambil dari kata lain — ia berdiri sendiri sejak awal. Contohnya: rajulun — laki-laki, farasun — kuda, hajarun — batu. Musytaq adalah kata yang dibentuk dari fi'il, membawa arti perbuatan itu. Contohnya: dari kataba — menulis — lahir kaatibun — penulis — dan maktuubun — yang ditulis — dan maktabatun — perpustakaan, tempat menulis. Musytaq itu seperti keluarga kata. Sekali kamu tahu akar fi'il-nya, banyak kata baru langsung bisa ditebak artinya. Jadi gini: jamid tidak punya fi'il asal yang seakar; musytaq selalu bisa ditanya — dari fi'il apa ia dibentuk?", "papan": {"judul": "JAMID • MUSYTAQ", "baris": ["jamid = berdiri sendiri", "musytaq = dari fi'il"]}},
	{"id": "n7", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Keluarga musytaq yang paling sering ada enam — kenali dulu bentuknya, wazannya nanti di tashrif. Pertama, isim fa'il — pelaku: kaatibun — penulis. Kedua, isim maf'ul — objek: maktuubun — yang ditulis. Ketiga, sifat musyabbahah — sifat tetap: kariimun — mulia. Keempat, isim tafdhil — lebih atau paling: akbaru — lebih besar, terbesar. Kelima, isim zaman dan makan — waktu atau tempat: maktabun — tempat menulis. Keenam, isim alat: miftaahun — kunci, alat membuka. Enam bentukan ini akan kamu temui di hampir setiap halaman kitab. Ingat ya: sekali tahu akar fi'il-nya, artinya langsung bisa ditebak — itulah gunanya mengenal keluarga musytaq.", "papan": {"judul": "6 MUSYTAQ", "baris": ["fa'il • maf'ul • sifat", "tafdhil • zaman • alat"]}},
	{"id": "c4", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — jamid itu kata dasar yang berdiri sendiri, seperti hajarun. Musytaq itu dibentuk dari fi'il, seperti kaatibun dari kataba. Dan enam bentukan musytaq: fa'il, maf'ul, sifat musyabbahah, tafdhil, zaman dan makan, dan alat. Paham? Fahimtum?", "papan": {"judul": "CEK — MUSYTAQ", "baris": ["jamid vs musytaq", "6 bentukan"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n8"}, {"teks": "Belum, jelaskan lagi", "ke": "u4"}]},
	{"id": "u4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan dua kata. 'Aalimun — orang berilmu — itu musytaq, dari 'alima, dia tahu; bentuknya isim fa'il. Hajarun — batu — itu jamid, tidak punya fi'il asal yang seakar. Jadi tanyanya begini: ada fi'il asalnya atau tidak? Kalau ada, itu musytaq; kalau tidak, itu jamid. Paham sekarang?", "papan": {"judul": "MUSYTAQ — ULANG", "baris": ["'aalimun → musytaq", "hajarun → jamid"]}, "berikut": "n8"},
	{"id": "n8", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sebelum latihan, hafalkan bait ini. Baitnya orisinal dari Pesantren Universe:\nاَلاِسْمُ إِمَّا مُعْرِفَةٌ تُعْرَفُ * أَوْ نَكِرَةٌ بِالْوَصْفِ تُوْصَفُ\nArtinya: isim itu ada yang makrifat — dikenal jelas — dan ada yang nakiroh — masih umum sifatnya. Lalu tanya: mudzakar atau muannats? Jamid atau musytaq? Ucapkan tiga kali pelan-pelan, lalu tutup mata dan ucapkan sekali tanpa melihat. Bait ini nanti kamu setorkan ke saya sebagai tugas.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Isim itu makrifat", "atau nakiroh"]}},
	{"id": "n9", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Terakhir, rangkumannya — empat hal yang harus kamu bawa pulang hari ini. Satu: makrifat punya enam jalan — kata ganti, nama diri, kata penunjuk, kata penghubung, diawali al-, dan disandarkan ke makrifat; nakiroh masih umum. Nama diri tetap makrifat walau bertanwin. Dua: mudzakar itu laki-laki, muannats itu perempuan. Muannats bertanda ta marbuthah, alif maqshurah, atau alif mamdudah — dan ada yang tanpa tanda; hafalkan empat contohnya: syamsun, ardhun, naarun, dan Maryam.", "papan": {"judul": "RANGKUMAN 1", "baris": ["makrifat • nakiroh", "mudzakar • muannats"]}},
	{"id": "n10", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Tiga: musytaq dibentuk dari fi'il — fa'il, maf'ul, sifat musyabbahah, tafdhil, zaman dan makan, dan alat; jamid berdiri sendiri. Empat: tiga pertanyaan untuk setiap isim — sudah dikenal? Laki atau perempuan? Asli atau bentukan? Ingat ya: makrifat atau nakiroh, mudzakar atau muannats, jamid atau musytaq — tiga pasang, tiga pertanyaan. Kalau kamu bisa menjawab ketiganya untuk satu kata, kamu sudah bisa menggolongkan isim itu.", "papan": {"judul": "RANGKUMAN 2", "baris": ["jamid • musytaq", "tiga pertanyaan"]}},
	{"id": "p_latihan", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Alhamdulillah, materinya selesai. Sekarang kita latihan — 5 soal. Jawab dengan tenang. Kalau salah, nanti saya jelaskan, lalu soalnya diulang. Siap?", "papan": {"judul": "LATIHAN", "baris": ["5 soal", "salah → dijelaskan"]}},
]

const NOD: Array = [
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — sayyaaratun (sebuah mobil) itu makrifat atau nakiroh?", "papan": {"judul": "LATIHAN 1", "baris": ["sayyaaratun = ?", "umum → nakiroh"]}, "benar": "Benar! Masih umum, sebuah mobil siapa saja — nakiroh.", "salah": "Belum tepat. Sayyaaratun masih umum — sebuah mobil siapa saja — jadi nakiroh. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "as-sayyaaratu (mobil itu) itu makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?", "papan": {"judul": "LATIHAN 2", "baris": ["as-sayyaaratu = ?", "al- → makrifat"]}, "benar": "Benar! Makrifat — jalannya diawali al-.", "salah": "Belum tepat. As-sayyaaratu makrifat — jalannya diawali al-. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "Faathimatu (Fatimah) itu makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?", "papan": {"judul": "LATIHAN 3", "baris": ["Faathimatu = ?", "nama diri → makrifat"]}, "benar": "Benar! Makrifat — jalannya nama diri.", "salah": "Belum tepat. Faathimatu makrifat — jalannya nama diri. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "haadzaa (ini) itu makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?", "papan": {"judul": "LATIHAN 4", "baris": ["haadzaa = ?", "isyarah → makrifat"]}, "benar": "Benar! Makrifat — jalannya kata penunjuk, isyarah.", "salah": "Belum tepat. Haadzaa makrifat — jalannya kata penunjuk. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "baitu al-mu'allimi (rumah guru itu) itu makrifat atau nakiroh? Kalau makrifat, lewat jalan apa?", "papan": {"judul": "LATIHAN 5", "baris": ["baitu al-mu'allimi = ?", "idhafah → makrifat"]}, "benar": "Benar! Makrifat — disandarkan ke makrifat, al-mu'allimi.", "salah": "Belum tepat. Baitu al-mu'allimi makrifat — disandarkan ke makrifat. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: apa beda makrifat dan nakiroh?", "papan": {"judul": "KUIS", "baris": ["makrifat vs nakiroh", "apa bedanya?"]}, "benar": "Benar! Makrifat menunjuk yang sudah tertentu dan dikenal; nakiroh masih umum.", "salah": "Belum tepat. Makrifat menunjuk yang sudah tertentu dan dikenal; nakiroh masih umum. Coba lagi."},
	{"id": "penutup", "tipe": "pesan", "teks": "Alhamdulillah, Modul 02 tuntas. Kamu dapat 35 poin — 10 materi, 15 latihan, 10 kuis. Besok kita lanjut Modul 03 — fi'il dan i'robnya, atau langsung tes kenaikan di kantor, duduk berhadapan dengan saya.", "papan": {"judul": "TUNTAS", "baris": ["Modul 02 — 35 poin", "materi 10 • latihan 15", "kuis 10"]}},
	{"id": "tugas", "tipe": "tugas", "teks": "Tugasmu ada dua. Pertama, hafalkan baitnya — 'Isim itu ada yang makrifat…' — lalu setorkan hafalanmu ke saya. Kedua, baca 1 bab di rak kitab — pilih bab yang ringan. Kalau baitnya sudah hafal, kamu dapat 5 poin.", "papan": {"judul": "TUGAS", "baris": ["hafal bait + setorkan", "baca 1 bab di rak kitab", "+5 poin"]}},
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


## Id node pertama ("p1").
static func id_pertama() -> String:
	return SPINE[0]


## Jumlah node tulang punggung (24) — penyebut bilah progres.
static func jumlah_pesan() -> int:
	return SPINE.size()


## Posisi node di tulang punggung (0..23) untuk bilah progres.
## Node ulang (u1-u4) menempati slot cek-nya.
static func indeks_progres(id: String) -> int:
	if id == "u1":
		return 3
	if id == "u2":
		return 6
	if id == "u3":
		return 8
	if id == "u4":
		return 11
	if SPINE.has(id):
		return SPINE.find(id)
	return 0


## Fase sesi belajar untuk kunci save rb_fase (Sinta, 22 Nov 2026).
static func fase_node(id: String) -> String:
	if id == "":
		return "selesai"
	if id == "k1":
		return "kuis"
	if id == "penutup":
		return "penutup"
	if id == "tugas":
		return "tugas"
	if id.begins_with("l"):
		return "latihan"
	return "narasi"


## Node guru yang pesannya tampil di Riwayat saat resume di
## resume_id (jalur linear; node ulang hanya bila resume memang
## di dalamnya — jawaban player saat resume tidak tersimpan, jadi
## Riwayat resume berisi pesan ustadz saja).
static func jalur_log(resume_id: String) -> Array[String]:
	if resume_id == "u1":
		return ["p1", "n1", "n2", "c1"]
	if resume_id == "u2":
		return ["p1", "n1", "n2", "c1", "n3", "n4", "c2"]
	if resume_id == "u3":
		return ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "c3"]
	if resume_id == "u4":
		return ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "c3", "n6", "n7", "c4"]
	var out: Array[String] = []
	for id in SPINE:
		if id == resume_id:
			break
		out.append(id)
	return out


## Opsi jawaban sebuah node soal dari DataModul02 (satu sumber
## kebenaran untuk opsi + indeks benar). Latihan: 5 soal, opsi
## sama; kuis: soal pertama bank N2.T.
## (DataModul02 dibuat Sinta saat port — pola data_modul_01.gd.)
static func opsi_soal(nod: Dictionary) -> Array:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul02.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return bank[idx].get("opsi", [])
		return []
	var lat: Array = DataModul02.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return lat[idx2].get("opsi", [])
	return []


## Indeks jawaban benar sebuah node soal dari DataModul02
## (kunci "jawaban" — lihat DataModul02.latihan_soal()).
static func benar_soal(nod: Dictionary) -> int:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul02.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return int(bank[idx].get("jawaban", 0))
		return 0
	var lat: Array = DataModul02.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return int(lat[idx2].get("jawaban", 0))
	return 0
