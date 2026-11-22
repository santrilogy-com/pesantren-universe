class_name DataChatModul01
extends RefCounted
## Data percakapan Ruang Belajar Modul 01 — NARASI TEKS v4
## (v2/konsep/KONSEP-RUANG-BELAJAR-v4-TEKS.md, keputusan Mas 22 Nov 16:03:
## karakter BERHENTI dulu, project Godot lanjut; misi Ruang Belajar
## pindah dari VIDEO ke TEKS; KONSEP + NASKAH v4 DI-ACC Mas 16:12).
## Guru menjelaskan seperti guru beneran — detail dan lengkap — lewat
## dialog chat. TIDAK ada video, TIDAK ada gate tonton, TIDAK ada
## lanjut otomatis: pemain yang menentukan lanjut/tidaknya (tombol
## "Lanjut ›" / tap gelembung).
##
## PORT (Sinta, 22 Nov 16:13): NARASI + NOD + SPINE + helper disalin
## dari data_chat_modul_01_v4.gd (naskah Laras — file sumber, TIDAK
## dihapus); class_name tetap DataChatModul01. File Sinta sebelumnya
## (5 node CONTOH) disimpan sebagai data_chat_modul_01.gd.bak.
##
## Sumber SATU-SATUNYA: Modul 01 tashih-lolos
## (ruang-belajar-nahwu-dasar-01-mengenal-kata.md, TASHIH LOLOS 18 Nov).
## Tidak ada materi di luar modul. Metode Mas "jelaskan, tanyakan,
## jelaskan, tanyakan" (20 Nov): jelaskan pelan-pelan, ulang 2-3x
## dengan penekanan kata kunci, lalu tanyakan ("Paham? Fahimtum?").
## Pengulangan pakai variasi natural ("Ingat ya", "Coba perhatikan",
## "Jadi gini", "Perhatikan baik-baik") — TANPA "Sekali lagi"
## (ditolak Mas di naskah v7, monoton).
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
##    ("berikut" eksplisit — _lanjut_pesan UI menghormatinya;
##    node ulang TIDAK masuk SPINE, jadi resume kembali ke node cek.)
##   Soal/penutup/tugas: kunci sama seperti dulu ("id", "tipe",
##    "teks", "bank", "soal", "benar", "salah", "papan") — TANPA
##    "pembicara" (UI memakai _pengajar sebagai fallback).
##    Penutup tipe "pesan" (UI tidak punya arm "penutup").
##
## Aturan lanjut manual (v4 §5):
## - TIDAK ADA lanjut otomatis — tidak ada timer, tidak ada auto-scroll
##   ke node berikut. Tiap node maju HANYA bila pemain mengetuk tombol
##   "Lanjut ›" atau mengetuk gelembung.
## - Efek bicara TETAP (±40 ms/huruf): ketuk saat mengetik = tampil
##   penuh; ketuk lagi = node berikut.
## - Node "cek" maju HANYA lewat tombol opsi. "Belum, jelaskan lagi"
##   membuka SATU node ulang (contoh lain, bukan pengulangan kata yang
##   sama), maks 1x per cek — sesudah node ulang, hanya opsi
##   "Paham, lanjut ›" yang tampil (tidak bisa mengulang tanpa henti).
##   Yang belum paham bisa membaca ulang lewat Riwayat atau tombol
##   "Baca Ulang Modul" (reader, tanpa gate, tanpa poin).
## - Poin materi 10 diberikan saat pemain meninggalkan node narasi
##   terakhir (p_latihan) ke l1.
## - Penyelesaian = sampai node terakhir (tugas diberikan).
##   Poin 35 (10 materi + 15 latihan + 10 kuis) terkunci saat penutup;
##   tugas +5 poin diberikan saat tugas DITERIMA (tombol
##   "Terima Tugas ✓").
##
## Panjang node (terverifikasi skrip): narasi n1-n14 total 1.201 kata
## (rata-rata ~86 kata/node, rentang 64-115); cek 36-60 kata
## (total 177); ulang 50-59 kata (total 217); p1 40 kata.
## Bait hafalan + rangkuman + tugas diambil PERSIS dari Modul 01.

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TUGAS := 5
const POIN_TOTAL := 40

## Tulang punggung linear (28 node) — dipakai bilah progres
## (tanpa teks penghitung — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
## Node ulang (u1-u4) TIDAK masuk SPINE — mereka menempati slot cek-nya.
const SPINE: Array[String] = ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "n6", "n7", "c3", "n8", "n9", "n10", "n11", "c4", "n12", "n13", "n14", "p_latihan", "l1", "l2", "l3", "l4", "l5", "k1", "penutup", "tugas"]

## Narasi guru — naskah Modul 01 ASLI (Laras, 22 Nov 2026).
## p1 sapaan; n1-n14 narasi (tujuan, kalam, isim, ciri isim, fi'il,
## ciri fi'il, huruf, rumus 10 detik, mabni/mu'rob, kelompok mabni,
## u/a/i, bait hafalan, rangkuman 1-2); c1-c4 cek "Paham? Fahimtum?";
## u1-u4 ulang (1x per cek); p_latihan transisi ke latihan.
const NARASI: Array = [
	{"id": "p1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Assalamu'alaikum, Nak. Hari ini kita mulai belajar Nahwu Dasar — Modul 01: Mengenal Kata. Nahwu itu ilmu tentang perubahan akhir kata. Dengan nahwu, kamu bisa membaca kitab kuning tanpa menebak-nebak harakat akhir kata. Kita belajar pelan-pelan, satu-satu, sampai paham. Siap?", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 01 — Mengenal Kata"]}},
	{"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sebelum mulai, ingat dulu tujuannya. Satu kata Arab yang sama bisa dibaca u, a, atau i di akhir — dan itu bukan kebetulan. Dhammah, fathah, dan kasrah itu petunjuk kedudukan kata di kalimat. Nahwu inilah ilmu yang mempelajari perubahan itu. Jadi, kalau kamu sudah bisa memilah kata dan membaca akhir katanya, kamu sudah memegang kunci pertama membaca kitab. Itu yang kita pelajari hari ini.", "papan": {"judul": "NAHWU", "baris": ["u • a • i = petunjuk", "kedudukan kata"]}},
	{"id": "n2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kita mulai dari kalam. Kalam adalah susunan kata yang memberi arti sempurna, sehingga pendengar tidak bertanya lagi. Contohnya: Qaama Muhammadun — 'Muhammad telah berdiri.' Kalimat itu sudah sempurna: ada yang berdiri, yaitu Muhammad, dan ada perbuatannya, yaitu berdiri. Bayangkan kalimat seperti rumah. Isim adalah benda dan orang di dalamnya. Fi'il adalah kegiatan yang terjadi. Huruf adalah penghubung kecil — seperti engsel dan paku — yang membuat semuanya menyatu dan bermakna. Ingat ya: jangan hafalkan definisi dulu. Kenali ciri-cirinya. Di nahwu, ciri jauh lebih berguna daripada hafalan definisi.", "papan": {"judul": "KALAM", "baris": ["kalam = susunan kata", "arti sempurna", "Qaama Muhammadun"]}},
	{"id": "c1", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Jadi, kalam itu apa? Susunan kata yang memberi arti sempurna — pendengar tidak bertanya lagi. Contohnya Qaama Muhammadun: 'Muhammad telah berdiri.' Coba ingat analoginya: kalimat itu seperti rumah — isim bendanya, fi'il kegiatannya, huruf penghubungnya. Paham? Fahimtum?", "papan": {"judul": "CEK — KALAM", "baris": ["kalam = arti sempurna", "Qaama Muhammadun"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n3"}, {"teks": "Belum, jelaskan lagi", "ke": "u1"}]},
	{"id": "u1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Baik, saya ulangi dengan contoh lain. Kalau saya bilang 'Muhammad' saja, kamu pasti bertanya: Muhammad kenapa? Itu belum kalam, karena artinya belum sempurna. Tapi kalau saya bilang 'Muhammad telah berdiri', kamu sudah paham dan tidak bertanya lagi. Nah, itu kalam. Kalam itu susunan kata yang artinya sudah sempurna. Paham sekarang?", "papan": {"judul": "KALAM — ULANG", "baris": ["'Muhammad' saja", "belum kalam"]}, "berikut": "n3"},
	{"id": "n3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Jenis kata pertama: isim. Isim adalah kata yang menunjukkan arti pada dirinya sendiri dan tidak terikat waktu. Orang, benda, tempat, sifat, dan nama kegiatan bisa menjadi isim. Contohnya: Muhammadun — Muhammad, nama orang. Masjidun — masjid, tempat. Qalamun — pena, benda. 'Ilmun — ilmu, nama kegiatan. Kabiirun — besar, sifat. Perhatikan baik-baik: isim itu tidak terikat waktu. Kata 'masjid' tidak bilang kapan — kemarin, sekarang, atau besok. Itu bedanya dengan fi'il, yang sebentar lagi kita bahas.", "papan": {"judul": "ISIM", "baris": ["tanpa waktu", "Muhammadun • masjidun", "qalamun • 'ilmun • kabiirun"]}},
	{"id": "n4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang kuncinya: ciri-ciri isim. Ada empat. Pertama, isim bisa diberi tanwin: kitaabun — kitab, masjidan — masjid. Kedua, isim bisa diawali al-: al-kitaabu — kitab itu. Ketiga, isim bisa di-jer dengan huruf jer di depannya: fi al-masjidi — di masjid. Keempat, isim bisa disandarkan: kitaabu Muhammadin — kitabnya Muhammad. Hafalkan rumusnya: ada tanwin, al-, huruf jer, atau disandarkan — pasti isim. Coba perhatikan polanya: tanwin, al-, huruf jer, idhafah — empat ciri itu yang membedakan isim dari kata lain.", "papan": {"judul": "CIRI ISIM", "baris": ["tanwin • al- • jer", "idhafah", "tanwin/al- → isim"]}},
	{"id": "c2", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — ciri isim ada empat: tanwin, al-, huruf jer, dan idhafah. Rumusnya: ada tanwin, al-, huruf jer, atau disandarkan — pasti isim. Contohnya madrasatun: bertanwin, jadi isim. Al-masjidu: diawali al-, jadi isim. Paham? Fahimtum?", "papan": {"judul": "CEK — ISIM", "baris": ["4 ciri isim", "madrasatun • al-masjidu"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n5"}, {"teks": "Belum, jelaskan lagi", "ke": "u2"}]},
	{"id": "u2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu kata saja: al-masjidu. Kata itu diawali al- — jadi pasti isim. Dan qalamun — bertanwin — jadi isim juga. Dua ciri, satu kesimpulan: kalau ada tanwin atau al-, itu isim. Tidak usah dihafal semua sekaligus; pegang dulu dua ciri ini, dua ciri lainnya menyusul di latihan. Paham sekarang?", "papan": {"judul": "ISIM — ULANG", "baris": ["al-masjidu → isim", "qalamun → isim"]}, "berikut": "n5"},
	{"id": "n5", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Jenis kata kedua: fi'il. Fi'il adalah kata yang menunjukkan perbuatan dan terikat waktu: sudah terjadi, sedang atau akan terjadi, atau diperintahkan. Contohnya: kataba — dia telah menulis, itu lampau. Yaktubu — dia sedang atau akan menulis, itu sekarang dan akan datang. Uktub — tulislah! Itu perintah. Perhatikan baik-baik: fi'il itu selalu terikat waktu. Kata 'menulis' saja belum fi'il — harus jelas kapan: sudah menulis, sedang menulis, atau disuruh menulis. Itu bedanya dengan isim, yang tidak terikat waktu.", "papan": {"judul": "FI'IL", "baris": ["terikat waktu", "kataba • yaktubu • uktub"]}},
	{"id": "n6", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Seperti isim, fi'il juga punya ciri. Ada empat. Pertama, fi'il bisa dimasuki qad: qad kataba — sungguh dia telah menulis. Kedua, fi'il bisa dimasuki sin atau saufa untuk masa depan: sa-yaktubu — dia akan menulis. Ketiga, fi'il madhi bisa diakhiri ta ta'nits untuk perempuan: katabat — dia, perempuan, telah menulis. Keempat, fi'il amar dan mudhori' bisa dimasuki ya mukhathabah untuk perempuan yang diajak bicara. Dan ini larangannya, hafalkan: fi'il tidak pernah diberi tanwin dan tidak pernah diawali al-. Kalau sebuah kata bertanwin, ia bukan fi'il.", "papan": {"judul": "CIRI FI'IL", "baris": ["qad • sin • saufa", "ta ta'nits • ya mukhathabah", "tanwin/al- = bukan fi'il"]}},
	{"id": "n7", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Jenis kata ketiga: huruf. Huruf adalah kata yang artinya baru jelas bila digabung dengan kata lain. Huruf tidak bisa diberi tanwin, tidak bisa diawali al-, dan tidak menerima ciri isim maupun fi'il. Contohnya: fi — di atau di dalam, seperti fi al-masjidi, di masjid. Ila — ke atau kepada, seperti ila as-suuqi, ke pasar. 'An — dari atau tentang, seperti 'an ad-darsi, tentang pelajaran. 'Ala — di atas, seperti 'ala al-maktabi, di atas meja. Lam — tidak untuk lampau, seperti lam yaktub, dia tidak menulis. Huruf jumlahnya terbatas dan akan sering kamu temui. Rumusnya: tidak berciri isim, tidak berciri fi'il, dan bermakna bila bergabung — itu huruf.", "papan": {"judul": "HURUF", "baris": ["fi • ila • 'an", "'ala • lam", "bermakna bila bergabung"]}},
	{"id": "c3", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Sekarang coba bedakan ketiganya. Isim itu kata benda tanpa waktu — cirinya tanwin, al-, huruf jer, idhafah. Fi'il itu kata kerja yang terikat waktu — cirinya qad, sin, saufa, ta ta'nits. Huruf itu kata penghubung — baru bermakna bila bergabung. Dan ingat larangannya: fi'il tidak pernah bertanwin dan tidak pernah ber-al-. Kalau sebuah kata bertanwin, ia bukan fi'il. Paham? Fahimtum?", "papan": {"judul": "CEK — TIGA KATA", "baris": ["isim • fi'il • huruf", "tanwin = bukan fi'il"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n8"}, {"teks": "Belum, jelaskan lagi", "ke": "u3"}]},
	{"id": "u3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dari bedanya. Kata 'kataba' — dia telah menulis — itu perbuatan lampau, terikat waktu, jadi fi'il. Kata 'kitaabun' — kitab — itu benda, tidak terikat waktu, bertanwin, jadi isim. Dan 'fi' — di dalam — itu huruf, baru bermakna bila digabung: fi al-masjidi, di masjid. Tiga jenis kata, tiga ciri yang berbeda. Paham sekarang?", "papan": {"judul": "TIGA KATA — ULANG", "baris": ["kataba → fi'il", "kitaabun → isim", "fi → huruf"]}, "berikut": "n8"},
	{"id": "n8", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang rumus cepatnya — rumus memilah kata dalam 10 detik. Langkah satu: lihat akhir dan awal kata. Ada tanwin atau al-? Itu isim. Langkah dua: ada qad, sin, saufa, atau tanda fi'il lain? Itu fi'il. Langkah tiga: kata pendek penghubung dan tidak menerima tanda di atas? Itu huruf. Coba lima kata ini: ath-thaalibu — diawali al-, jadi isim. Dzahaba — perbuatan lampau tanpa tanwin, jadi fi'il. Min — kata penghubung 'dari', jadi huruf. Madrasatun — bertanwin, jadi isim. Sa-yadzhabu — dimasuki sin masa depan, jadi fi'il. Dan satu kalimat utuh: dzahaba ath-thaalibu ila al-madrasati — 'Siswa itu pergi ke sekolah.' Dzahaba itu fi'il, ath-thaalibu itu isim, ila itu huruf, al-madrasati itu isim.", "papan": {"judul": "RUMUS 10 DETIK", "baris": ["tanwin/al- → isim", "qad/sin/saufa → fi'il", "penghubung → huruf"]}},
	{"id": "n9", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Selanjutnya, akhir kata isim itu bisa tetap, bisa berubah mengikuti kedudukannya. Dari sini lahir dua istilah penting. Mabni — akhir katanya tidak berubah walau kedudukannya berubah. Contoh kata ganti: huwa — dia — tetap huwa di mana pun posisinya. Mu'rob — akhir katanya berubah: rafa' dengan dhammah, nashob dengan fathah, jer dengan kasrah. Contohnya: kitaabun, kitaaban, kitaabin. Perhatikan kalimat ini: haadzaa kitaabu Muhammadin — 'Ini kitab Muhammad.' Haadzaa — ini — adalah isim isyarah yang mabni. Kitaabu dan Muhammadin itu mu'rob — akhir katanya berubah sesuai kedudukan.", "papan": {"judul": "MABNI • MU'ROB", "baris": ["mabni = tetap", "mu'rob = berubah", "huwa • kitaabun"]}},
	{"id": "n10", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kelompok mabni yang sering muncul ada lima. Pertama, kata ganti: huwa, hiya, anaa — dia, dia, saya. Kedua, isim isyarah: haadzaa, dzaalika — ini, itu. Ketiga, isim maushul: alladzii — yang. Keempat, isim istifham: man, maa, ayna — siapa, apa, di mana. Kelima, sebagian isim syarat: man, maa. Mabni bukan berarti tidak penting. Kata ganti dan kata penunjuk muncul di hampir setiap halaman kitab. Kabar baiknya: karena tetap, sekali hafal bentuknya, kamu tidak perlu memikirkan perubahan akhirnya. Satu lagi yang perlu diingat: semua fi'il madhi dan amar itu mabni. Fi'il mudhori' umumnya mu'rob — bahasan lengkap fi'il ada di Bagian 3.", "papan": {"judul": "KELOMPOK MABNI", "baris": ["dhamir • isyarah", "maushul • istifham", "madhi + amar = mabni"]}},
	{"id": "n11", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Terakhir untuk hari ini: perubahan akhir kata. Kata yang sama bisa dibaca u, a, atau i di akhir — dan itu bukan kebetulan. Dhammah, fathah, dan kasrah adalah petunjuk kedudukan kata di kalimat. Perhatikan tiga kalimat ini. Jaa-a ath-thaalibu — 'Siswa itu datang.' Ath-thaalib dibaca u — itu tanda rafa'. Ra-aitu ath-thaaliba — 'Aku melihat siswa itu.' Dibaca a — itu tanda nashob. Marartu bi ath-thaalibi — 'Aku berpapasan dengan siswa itu.' Dibaca i — itu tanda jer. Jadi, u itu rafa', a itu nashob, i itu jer. Bagian 4 nanti akan menjawab pertanyaan besarnya: kedudukan apa saja yang membuat isim di-rafa', di-nashob, dan di-jer. Untuk sekarang, cukup kenali bahwa perubahan itu ada dan bermakna.", "papan": {"judul": "U • A • I", "baris": ["u = rafa'", "a = nashob", "i = jer"]}},
	{"id": "c4", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat semuanya. Mabni itu akhir katanya tetap — seperti huwa, haadzaa, dan man. Mu'rob itu akhir katanya berubah — seperti kitaabun, kitaaban, kitaabin. Dan u, a, i di akhir kata adalah petunjuk: dhammah itu rafa', fathah itu nashob, kasrah itu jer. Paham? Fahimtum?", "papan": {"judul": "CEK — MABNI", "baris": ["mabni = tetap", "u/a/i = rafa'/nashob/jer"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n12"}, {"teks": "Belum, jelaskan lagi", "ke": "u4"}]},
	{"id": "u4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu kata: ath-thaalib. Waktu dia datang — jaa-a ath-thaalibu — dibaca u, itu rafa'. Waktu aku melihatnya — ra-aitu ath-thaaliba — dibaca a, itu nashob. Waktu aku berpapasan dengannya — marartu bi ath-thaalibi — dibaca i, itu jer. Satu kata, tiga bacaan, tiga kedudukan. Dan huwa? Tetap huwa di mana pun — itu mabni. Paham sekarang?", "papan": {"judul": "U • A • I — ULANG", "baris": ["ath-thaalibu / -a / -i", "huwa tetap"]}, "berikut": "n12"},
	{"id": "n12", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sebelum latihan, hafalkan bait ini. Baitnya orisinal dari Pesantren Universe:\nاَلْكَلِمَةُ ثَلَاثَةٌ فَاحْفَظْهَا\nاِسْمٌ وَفِعْلٌ وَحَرْفٌ جَاءَ لِمَعْنًى فَاعْرِفْهَا\nArtinya: kata itu tiga, hafalkanlah — isim, fi'il, dan huruf yang datang untuk suatu makna. Isim bertanwin dan ber-al-, fi'il terikat waktu, huruf bermakna bila bergabung. Ucapkan tiga kali pelan-pelan, lalu tutup mata dan ucapkan sekali tanpa melihat. Bait ini nanti kamu setorkan ke saya sebagai tugas.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Kata itu tiga,", "isim, fi'il, dan huruf"]}},
	{"id": "n13", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Terakhir, rangkumannya — tujuh hal yang harus kamu bawa pulang hari ini. Satu: kalam adalah susunan kata yang memberi arti sempurna; setiap kata Arab hanya masuk satu dari tiga jenis. Dua: isim menunjukkan benda tanpa waktu — cirinya tanwin, al-, huruf jer, dan idhafah. Tiga: fi'il menunjukkan perbuatan yang terikat waktu — cirinya qad, sin atau saufa, ta ta'nits, dan ya mukhathabah; fi'il tidak pernah bertanwin dan tidak pernah ber-al-. Empat: huruf adalah kata penghubung yang baru bermakna bila bergabung.", "papan": {"judul": "RANGKUMAN 1", "baris": ["kalam • isim", "fi'il • huruf"]}},
	{"id": "n14", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Lima: rumus 10 detik — ada tanwin atau al-, itu isim; ada qad, sin, atau saufa, itu fi'il; kata pendek penghubung, itu huruf. Enam: mabni itu akhir katanya tetap, mu'rob itu akhir katanya berubah. Tujuh: u, a, i di akhir kata adalah petunjuk — dhammah itu rafa', fathah itu nashob, kasrah itu jer. Tujuh hal ini — hafalkan, karena semuanya dipakai di Modul 02 nanti.", "papan": {"judul": "RANGKUMAN 2", "baris": ["rumus 10 detik", "mabni • mu'rob • u/a/i"]}},
	{"id": "p_latihan", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Alhamdulillah, materinya selesai. Sekarang kita latihan — 5 soal. Jawab dengan tenang. Kalau salah, nanti saya jelaskan, lalu soalnya diulang. Siap?", "papan": {"judul": "LATIHAN", "baris": ["5 soal", "salah → dijelaskan"]}},
]

const NOD: Array = [
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — madrasatun (sekolah) itu jenis kata apa?", "papan": {"judul": "LATIHAN 1", "baris": ["madrasatun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Madrasatun bertanwin — jadi isim. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "yaqra'u (dia sedang membaca) itu jenis kata apa?", "papan": {"judul": "LATIHAN 2", "baris": ["yaqra'u = ?", "terikat waktu → fi'il"]}, "benar": "Benar! Kata kerja mudhori', terikat waktu.", "salah": "Belum tepat. Yaqra'u itu kata kerja mudhori' — terikat waktu. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "'alaa (di atas) itu jenis kata apa?", "papan": {"judul": "LATIHAN 3", "baris": ["'alaa = ?", "penghubung → huruf"]}, "benar": "Benar! Kata penghubung, tidak berciri isim maupun fi'il.", "salah": "Belum tepat. 'Alaa itu kata penghubung. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "qalamun (pena) itu jenis kata apa?", "papan": {"judul": "LATIHAN 4", "baris": ["qalamun = ?", "tanwin → isim"]}, "benar": "Benar! Bertanwin, jadi isim.", "salah": "Belum tepat. Qalamun bertanwin. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "jalasa (dia telah duduk) itu jenis kata apa?", "papan": {"judul": "LATIHAN 5", "baris": ["jalasa = ?", "lampau → fi'il"]}, "benar": "Benar! Kata kerja madhi, perbuatan lampau.", "salah": "Belum tepat. Jalasa itu kata kerja madhi. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: Apa yang dipelajari ilmu Nahwu?", "papan": {"judul": "KUIS", "baris": ["Nahwu = ?", "perubahan akhir kata"]}, "benar": "Benar! Nahwu itu ilmu tentang perubahan akhir kata (i'rab).", "salah": "Belum tepat. Nahwu itu ilmu tentang perubahan akhir kata (i'rab). Coba lagi."},
	{"id": "penutup", "tipe": "pesan", "teks": "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin — 10 materi, 15 latihan, 10 kuis. Besok kita lanjut Modul 02 — atau langsung tes kenaikan di kantor, duduk berhadapan dengan saya.", "papan": {"judul": "TUNTAS", "baris": ["Modul 01 — 35 poin", "materi 10 • latihan 15", "kuis 10"]}},
	{"id": "tugas", "tipe": "tugas", "teks": "Tugasmu ada dua. Pertama, hafalkan baitnya — 'Kata itu tiga, hafalkanlah…' — lalu setorkan hafalanmu ke saya. Kedua, baca 1 bab di rak kitab — pilih bab yang ringan. Kalau baitnya sudah hafal, kamu dapat 5 poin.", "papan": {"judul": "TUGAS", "baris": ["hafal bait + setorkan", "baca 1 bab di rak kitab", "+5 poin"]}},
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


## Jumlah node tulang punggung (28) — penyebut bilah progres.
static func jumlah_pesan() -> int:
	return SPINE.size()


## Posisi node di tulang punggung (0..27) untuk bilah progres.
## Node ulang (u1-u4) menempati slot cek-nya.
static func indeks_progres(id: String) -> int:
	if id == "u1":
		return 3
	if id == "u2":
		return 6
	if id == "u3":
		return 10
	if id == "u4":
		return 15
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
		return ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "n6", "n7", "c3"]
	if resume_id == "u4":
		return ["p1", "n1", "n2", "c1", "n3", "n4", "c2", "n5", "n6", "n7", "c3", "n8", "n9", "n10", "n11", "c4"]
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
