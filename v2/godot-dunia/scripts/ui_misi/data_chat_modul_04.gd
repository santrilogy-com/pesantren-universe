class_name DataChatModul04
extends RefCounted
## Data percakapan Ruang Belajar Modul 04 — NARASI TEKS v4
## (v2/konsep/KONSEP-RUANG-BELAJAR-v4-TEKS.md, pola Modul 01 v4).
## Guru menjelaskan seperti guru beneran — detail dan lengkap — lewat
## dialog chat. TIDAK ada video, TIDAK ada gate tonton, TIDAK ada
## lanjut otomatis: pemain yang menentukan lanjut/tidaknya (tombol
## "Lanjut ›" / tap gelembung); KONSEP + NASKAH v4 DI-ACC Mas
## 22:52 — "Acc semua sampai selesai").
##
## PORT (Sinta, 22 Nov 23:04): NARASI + NOD + SPINE + helper disalin
## dari data_chat_modul_04_v4.gd (naskah Laras — file sumber, TIDAK
## dihapus); class_name tetap DataChatModul04.
##
##
## Sumber SATU-SATUNYA: Modul 04 tashih-lolos
## (ruang-belajar-nahwu-dasar-04-keadaan-isim.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai").
## Tidak ada materi di luar modul. Item DITAHAN tetap TIDAK
## diajarkan rinciannya: syarat isim laa nafi jins (hanya disebut
## sekilas) dan rincian bentuk munada (hanya dua pola paling
## sering: yaa thaalibu / yaa 'abda Allaahi). Maf'ul ma'ah dan
## maf'ul li-ajlih hanya dikenal namanya.
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
## Soal (l1-l5, k1) merujuk DataModul04 — file data dibuat Sinta
## saat port (pola data_modul_01.gd: latihan_soal() 5 soal dari
## Latihan A Modul 04, kuis_soal() 10 soal dari Kuis Modul 04;
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
## Panjang node (terverifikasi skrip): narasi n1-n14 total 1.146 kata
## (rata-rata ~82 kata/node, rentang 63-116); cek 42-51 kata
## (total 181); ulang 50-58 kata (total 214); p1 47 kata.
## Bait hafalan + rangkuman + tugas diambil PERSIS dari Modul 04.
## Modul 04 menutup Nahwu Dasar — jenjang berikutnya Al-Jurumiyah.

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TUGAS := 5
const POIN_TOTAL := 40

## Tulang punggung linear (28 node) — dipakai bilah progres
## (tanpa teks penghitung — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
## Node ulang (u1-u4) TIDAK masuk SPINE — mereka menempati slot cek-nya.
const SPINE: Array[String] = ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "n7", "c2", "n8", "n9", "n10", "c3", "n11", "c4", "n12", "n13", "n14", "p_latihan", "l1", "l2", "l3", "l4", "l5", "k1", "penutup", "tugas"]

## Narasi guru — naskah Modul 04 ASLI (Laras, 22 Nov 2026).
## p1 sapaan; n1-n14 narasi (peta tiga keadaan, fa'il, naib fa'il,
## mubtada/khabar, kaana/inna/laa, maf'ul bih, maf'ul muthlaq,
## lima manshub lain, huruf jer, idhafah, kalimat utuh, bait
## hafalan, rangkuman 1-2); c1-c4 cek "Paham? Fahimtum?"; u1-u4
## ulang (1x per cek); p_latihan transisi ke latihan.
const NARASI: Array = [
	{"id": "p1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Assalamu'alaikum, Nak. Hari ini kita lanjut Nahwu Dasar — Modul 04: Keadaan Isim dalam Kalimat. Ini jantung nahwu, Nak. Kenapa isim dibaca u, a, atau i? Jawabannya selalu sama — karena kedudukannya dalam kalimat. Satu pertanyaan untuk setiap isim: kedudukannya apa? Itulah peta Bagian 4 ini. Siap?", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 04 — Keadaan Isim"]}},
	{"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Tiga keadaan, satu pertanyaan: kedudukannya apa? Marfu' — dibaca u dengan dhammah — untuk pelaku dan pokok kalimat. Manshub — dibaca a dengan fathah — untuk objek dan keterangan. Makhfudh — dibaca i dengan kasrah — untuk yang setelah huruf jer atau disandarkan. Daftarnya terlihat panjang, tetapi polanya rapi: rafa' untuk pelaku dan pokok, nashob untuk objek dan keterangan, jer untuk yang ditempel huruf jer atau disandarkan. Ingat ya: jangan tanya 'kenapa u?' — tanya dulu 'kedudukannya apa?' Kalau kedudukannya sudah ketemu, bacaannya ikut ketemu.", "papan": {"judul": "PETA TIGA KEADAAN", "baris": ["u = marfu'", "a = manshub", "i = makhfudh"]}},
	{"id": "n2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedudukan marfu' pertama: fa'il — pelaku perbuatan. Ia selalu marfu'. Contohnya: kataba ath-thaalibu ad-darsa — 'Siswa itu menulis pelajaran.' Ath-thaalibu itu fa'il, marfu' dengan dhammah. Ingat ya: setiap fi'il pasti punya fa'il — disebut terang-terangan, atau tersembunyi sebagai kata ganti di dalam fi'il itu sendiri. Jadi, kalau ada fi'il, carilah pelakunya — itulah fa'il, dan ia selalu dibaca u. Fa'il itu jawaban dari pertanyaan 'siapa yang melakukan?'", "papan": {"judul": "FA'IL", "baris": ["pelaku • marfu'", "ath-thaalibu"]}},
	{"id": "n3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedudukan marfu' kedua: naib fa'il — pengganti pelaku. Pada kalimat majhul, pelaku dibuang dan objek naik menggantikannya — kedudukan baru ini tetap marfu'. Contohnya: kutiba ad-darsu — 'Pelajaran itu ditulis.' Ad-darsu itu naib fa'il, marfu'. Bedanya dengan fa'il: fa'il itu pelaku yang disebut; naib fa'il itu objek yang naik menggantikan pelaku yang dibuang. Perhatikan baik-baik: fi'ilnya majhul — kutiba, bukan kataba — dan isim setelahnya tetap dibaca u, karena kedudukannya marfu'.", "papan": {"judul": "NAIB FA'IL", "baris": ["pengganti pelaku", "kutiba ad-darsu"]}},
	{"id": "n4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedudukan marfu' ketiga dan keempat: mubtada dan khabar — pokok dan berita kalimat isim. Keduanya marfu'. Contohnya: al-'ilmu naafi'un — 'Ilmu itu bermanfaat.' Al-'ilmu itu mubtada, naafi'un itu khabar, keduanya marfu'. Coba perhatikan: kalimat ini tidak diawali fi'il — ia kalimat isim, pokoknya di awal, beritanya sesudahnya. Mubtada itu pokoknya, khabar itu beritanya. Dua-duanya dibaca u. Ingat ya: mubtada dan khabar itu pasangan — kalau ada mubtada, carilah khabarnya.", "papan": {"judul": "MUBTADA • KHABAR", "baris": ["pokok • berita", "al-'ilmu naafi'un"]}},
	{"id": "c1", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — empat kedudukan marfu' yang sudah kita bahas: fa'il itu pelaku, seperti ath-thaalibu. Naib fa'il itu pengganti pelaku dalam kalimat majhul, seperti ad-darsu. Mubtada itu pokok kalimat isim, khabar itu beritanya — seperti al-'ilmu naafi'un. Semuanya dibaca u. Paham? Fahimtum?", "papan": {"judul": "CEK — MARFU'", "baris": ["fa'il • naib fa'il", "mubtada • khabar"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n5"}, {"teks": "Belum, jelaskan lagi", "ke": "u1"}]},
	{"id": "u1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan tiga kalimat. Kataba ath-thaalibu — ath-thaalibu itu fa'il, pelaku yang disebut. Kutiba ad-darsu — ad-darsu itu naib fa'il, objek yang naik menggantikan pelaku. Al-'ilmu naafi'un — al-'ilmu itu mubtada, naafi'un itu khabar. Tiga kalimat, empat kedudukan — semuanya marfu', semuanya dibaca u. Pegang polanya: pelaku, pengganti pelaku, pokok, berita — empat marfu' pertama. Paham sekarang?", "papan": {"judul": "MARFU' — ULANG", "baris": ["fa'il • naib fa'il", "mubtada • khabar"]}, "berikut": "n5"},
	{"id": "n5", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Ada tiga kedudukan yang menyerupai mubtada dan khabar. Dua yang pertama diajarkan polanya yang paling dasar; yang ketiga hanya disebut sekilas. Pertama, isim kaana: kaana al-jawwu jamiilan — 'Cuaca itu indah.' Kaana menashob khabarnya, isimnya tetap marfu'. Kedua, khabar inna: inna al-'ilma naafi'un — 'Sesungguhnya ilmu itu bermanfaat.' Inna menashob mubtadanya, khabarnya tetap marfu'. Ketiga, isim laa nafi jins: laa thaaliba haadhirun — 'Tidak ada siswa yang hadir.' Yang ketiga ini hanya saya sebut sekilas — rincian syaratnya sengaja tidak diajarkan di sini. Hafalkan dulu pola dasarnya: isim kaana marfu', khabar inna marfu'. Kaana dan inna beserta saudara-saudaranya adalah jembatan menuju kitab Jurumiyah.", "papan": {"judul": "KAANA • INNA • LAA", "baris": ["isim kaana marfu'", "khabar inna marfu'"]}},
	{"id": "n6", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang kedudukan manshub. Pertama: maf'ul bih — objek yang dikenai perbuatan. Ia manshub. Contohnya: qara'tu al-kitaaba — 'Saya membaca kitab itu.' Al-kitaaba itu maf'ul bih, manshub dengan fathah. Ingat uji cepat dari Modul 03: kata yang menjawab 'apa atau siapa yang di-...?' setelah fi'il muta'addi. Membaca apa? Kitab. Jadi al-kitaaba itu maf'ul bih. Coba perhatikan: fi'ilnya muta'addi — qara'tu butuh objek — dan objeknya selalu dibaca a.", "papan": {"judul": "MAF'UL BIH", "baris": ["objek • manshub", "al-kitaaba"]}},
	{"id": "n7", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedudukan manshub kedua: maf'ul muthlaq — mashdar dari fi'il yang sama, disebut untuk menguatkan atau menjelaskan perbuatan. Contohnya: ijtahada ijtihaadan — 'Dia bersungguh-sungguh dengan sungguh-sungguh.' Perhatikan: ijtihaadan berasal dari fi'il yang sama — ijtahada. Itulah ciri maf'ul muthlaq — ia mengulang akar fi'ilnya. Jadi, kalau kamu melihat mashdar yang akarnya sama dengan fi'il di kalimat itu, dan ia berfungsi menguatkan — itulah maf'ul muthlaq, manshub dengan fathah.", "papan": {"judul": "MAF'UL MUTHLAQ", "baris": ["mashdar fi'il yang sama", "ijtihaadan"]}},
	{"id": "c2", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — kaana menashob khabarnya, jadi isim kaana tetap marfu'; inna menashob mubtadanya, jadi khabar inna tetap marfu'. Dan dua manshub pertama: maf'ul bih itu objek yang dikenai perbuatan, seperti al-kitaaba; maf'ul muthlaq itu mashdar dari fi'il yang sama, seperti ijtihaadan. Paham? Fahimtum?", "papan": {"judul": "CEK — KAANA", "baris": ["isim kaana • khabar inna", "maf'ul bih • muthlaq"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n8"}, {"teks": "Belum, jelaskan lagi", "ke": "u2"}]},
	{"id": "u2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan dua kalimat. Qara'tu al-kitaaba — al-kitaaba itu maf'ul bih, objek yang dibaca. Membaca apa? Kitab — jadi manshub. Ijtahada ijtihaadan — ijtihaadan itu maf'ul muthlaq, mashdar dari fi'il yang sama, menguatkan perbuatan. Dua-duanya manshub, dua-duanya dibaca a — tapi jalannya beda: satu objek, satu penguat. Paham sekarang?", "papan": {"judul": "MANSHUB — ULANG", "baris": ["al-kitaaba → maf'ul bih", "ijtihaadan → muthlaq"]}, "berikut": "n8"},
	{"id": "n8", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Selain maf'ul bih dan maf'ul muthlaq, ada lima kedudukan manshub di tingkat dasar. Pertama, maf'ul fih atau zharaf — keterangan waktu atau tempat: saafartu laylan — 'Saya bepergian malam hari.' Kedua, hal — keadaan pelaku atau objek saat perbuatan: jaa'a ath-thaalibu farihan — 'Siswa itu datang dalam keadaan gembira.' Ketiga, tamyiz — menghilangkan samar: isytaraytu kiilu urzan — 'Saya membeli satu kilo beras.' Keempat, mustatsna — yang dikecualikan: hadhara ath-thullaabu illaa 'aliyyan — 'Para siswa hadir kecuali Ali.' Kelima, munada — yang dipanggil: yaa thaalibu — 'Wahai siswa!' — dan yaa 'abda Allaahi — 'Wahai hamba Allah!' Dua pola munada itu dulu yang paling sering; rincian bentuknya tidak diajarkan di sini.", "papan": {"judul": "5 MANSHUB LAIN", "baris": ["zharaf • hal • tamyiz", "mustatsna • munada"]}},
	{"id": "n9", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang makhfudh — isim di-jer karena dua sebab saja: huruf jer atau idhafah. Pertama, huruf jer: isim yang jatuh setelah huruf jer selalu makhfudh. Tujuh huruf jer yang wajib dikenal: min — mina al-baiti, dari rumah. Ilaa — ila al-masjidi, ke masjid. Fii — fi al-fashli, di kelas. 'Alaa — 'ala al-maktabi, di atas meja. Bi — bi al-qalami, dengan pena. Li — li ath-thaalibi, untuk siswa. Ka — ka al-qamari, seperti bulan. Ingat rumusnya: setelah huruf jer, pasti JER.", "papan": {"judul": "HURUF JER", "baris": ["min • ilaa • fii", "'alaa • bi- • li- • ka-"]}},
	{"id": "n10", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedua, idhafah — disandarkan. Dalam sandaran dua isim, kata kedua — mudhaf ilaih — selalu makhfudh. Contohnya: kitaabu ath-thaalibi jadiidun — 'Kitab siswa itu baru.' Ath-thaalibi itu mudhaf ilaih, makhfudh dengan kasrah. Perhatikan baik-baik: kata pertama — kitaabu — itu mudhaf, kedudukannya mengikuti kalimat; kata kedua — ath-thaalibi — selalu JER, apa pun kedudukan kalimatnya. Ingat rumusnya: kata kedua dalam sandaran, mudhaf ilaih, selalu JER.", "papan": {"judul": "IDHAFAH", "baris": ["mudhaf ilaih = JER", "kitaabu ath-thaalibi"]}},
	{"id": "c3", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — lima manshub di tabel: zharaf, hal, tamyiz, mustatsna, dan munada — seperti laylan, farihan, urzan, 'aliyyan, dan yaa thaalibu. Dan dua sebab isim di-jer: setelah huruf jer, seperti ila al-masjidi; dan sebagai mudhaf ilaih, seperti ath-thaalibi dalam kitaabu ath-thaalibi. Paham? Fahimtum?", "papan": {"judul": "CEK — JER", "baris": ["5 manshub", "2 sebab jer"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n11"}, {"teks": "Belum, jelaskan lagi", "ke": "u3"}]},
	{"id": "u3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan dua kalimat. Ila al-masjidi — al-masjidi itu makhfudh karena setelah huruf jer ila. Kitaabu ath-thaalibi — ath-thaalibi itu makhfudh karena mudhaf ilaih, kata kedua dalam sandaran. Dua sebab, satu keadaan: makhfudh, dibaca i. Dan lima manshub tadi — zharaf, hal, tamyiz, mustatsna, munada — semuanya dibaca a. Paham sekarang?", "papan": {"judul": "JER — ULANG", "baris": ["ila al-masjidi", "kitaabu ath-thaalibi"]}, "berikut": "n11"},
	{"id": "n11", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang semua ilmu dipakai bersama. Baca pelan, kata demi kata: kataba ath-thaalibu ad-darsa fi al-fashli bi al-qalami — 'Siswa itu menulis pelajaran di kelas dengan pena.' Kataba — fi'il madhi, mabni. Ath-thaalibu — fa'il, marfu' dengan dhammah. Ad-darsa — maf'ul bih, manshub dengan fathah. Fi — huruf jer. Al-fashli — isim setelah huruf jer, makhfudh dengan kasrah. Bi — huruf jer. Al-qalami — isim setelah huruf jer, makhfudh dengan kasrah. Inilah yang dilakukan pembaca kitab setiap hari: memilah kata, menyebut kedudukannya, lalu membaca akhirnya dengan benar. Pelan, kata demi kata, sampai terbiasa.", "papan": {"judul": "KALIMAT UTUH", "baris": ["kataba ath-thaalibu", "ad-darsa fi al-fashli"]}},
	{"id": "c4", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat semuanya. Kataba ath-thaalibu ad-darsa fi al-fashli bi al-qalami — fa'il marfu', maf'ul bih manshub, dua isim setelah huruf jer makhfudh. Dan peta besarnya: marfu' itu u untuk pelaku dan pokok, manshub itu a untuk objek dan keterangan, makhfudh itu i untuk yang setelah huruf jer atau disandarkan. Paham? Fahimtum?", "papan": {"judul": "CEK — KALIMAT", "baris": ["fa'il • maf'ul bih", "jer • jer"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n12"}, {"teks": "Belum, jelaskan lagi", "ke": "u4"}]},
	{"id": "u4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu kalimat lain: yaqra-u ath-thaalibu al-qur-aana fi al-masjidi — 'Siswa itu membaca Al-Qur'an di masjid.' Yaqra-u — fi'il mudhori' marfu', tanpa penashob dan penjazim. Ath-thaalibu — fa'il, marfu'. Al-qur-aana — maf'ul bih, manshub. Fi — huruf jer. Al-masjidi — isim setelah huruf jer, makhfudh. Satu kalimat, semua keadaan ada. Paham sekarang?", "papan": {"judul": "KALIMAT — ULANG", "baris": ["yaqra-u ath-thaalibu", "al-qur-aana fi al-masjidi"]}, "berikut": "n12"},
	{"id": "n12", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sebelum latihan, hafalkan bait ini. Baitnya orisinal dari Pesantren Universe:\nاِرْفَعْ فَاعِلاً وَانْصِبْ مَفْعُولاً * وَاجْرُرْ بِحَرْفٍ أَوْ إِضَافَةٍ تَصِلُ\nArtinya: rafa'-kan fa'il, nashob-kan maf'ul, dan jer-kan dengan huruf jer atau idhafah — niscaya kamu sampai. Kedudukan dulu, baru bacaan akhir kata. Ucapkan tiga kali pelan-pelan, lalu tutup mata dan ucapkan sekali tanpa melihat. Bait ini nanti kamu setorkan ke saya sebagai tugas.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Rafa'-kan fa'il,", "nashob-kan maf'ul"]}},
	{"id": "n13", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Terakhir, rangkumannya — enam hal yang harus kamu bawa pulang hari ini. Satu: tiga keadaan — marfu' dengan dhammah untuk pelaku dan pokok, manshub dengan fathah untuk objek dan keterangan, makhfudh dengan kasrah untuk yang setelah huruf jer atau disandarkan. Pertanyaan kuncinya satu: kedudukannya apa? Dua: marfu' — fa'il seperti ath-thaalibu, naib fa'il seperti ad-darsu dalam kutiba ad-darsu, mubtada dan khabar seperti al-'ilmu naafi'un, isim kaana seperti al-jawwu, khabar inna seperti naafi'un, dan isim laa nafi jins — syaratnya ditahan, menunggu tashih. Tiga: manshub — maf'ul bih seperti al-kitaaba, maf'ul muthlaq seperti ijtihaadan, zharaf seperti laylan, hal seperti farihan, tamyiz seperti urzan, mustatsna seperti 'aliyyan, munada seperti yaa thaalibu — rincian bentuk munada ditahan, menunggu tashih.", "papan": {"judul": "RANGKUMAN 1", "baris": ["tiga keadaan", "marfu' • manshub"]}},
	{"id": "n14", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Empat: makhfudh — setelah huruf jer seperti min, ilaa, fii, 'alaa, bi-, li-, ka-, dan mudhaf ilaih dalam idhafah seperti ath-thaalibi dalam kitaabu ath-thaalibi. Lima: kalimat utuh — kataba ath-thaalibu ad-darsa fi al-fashli bi al-qalami — fa'il marfu', maf'ul bih manshub, dua isim setelah huruf jer makhfudh. Enam: bait hafalan — irfa' faa'ilan wanshib maf'uulan, wajrur bi-harfin aw idhaafatin tashilu — kedudukan dulu, baru bacaan akhir kata. Maf'ul ma'ah dan maf'ul li-ajlih hanya dikenal namanya — diajarkan di Jurumiyah. Setelah modul ini, jenjang berikutnya adalah membaca Al-Jurumiyah dengan bimbingan ustadz.", "papan": {"judul": "RANGKUMAN 2", "baris": ["makhfudh • kalimat utuh", "bait hafalan"]}},
	{"id": "p_latihan", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Alhamdulillah, materinya selesai. Sekarang kita latihan — 5 soal. Jawab dengan tenang. Kalau salah, nanti saya jelaskan, lalu soalnya diulang. Siap?", "papan": {"judul": "LATIHAN", "baris": ["5 soal", "salah → dijelaskan"]}},
]

const NOD: Array = [
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — kata al-mu'allimu dalam 'hadhara al-mu'allimu' itu kedudukannya apa?", "papan": {"judul": "LATIHAN 1", "baris": ["al-mu'allimu = ?", "fa'il • marfu'"]}, "benar": "Benar! Fa'il — pelaku perbuatan hadhara — marfu' dengan dhammah.", "salah": "Belum tepat. Al-mu'allimu itu pelakunya — fa'il, marfu' dengan dhammah. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "Kata al-maa-a dalam 'syaribtu al-maa-a' itu kedudukannya apa?", "papan": {"judul": "LATIHAN 2", "baris": ["al-maa-a = ?", "maf'ul bih • manshub"]}, "benar": "Benar! Maf'ul bih — objek yang diminum — manshub dengan fathah.", "salah": "Belum tepat. Al-maa-a itu objek yang diminum — maf'ul bih, manshub dengan fathah. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "Kata as-suuqi dalam 'dzahabtu ila as-suuqi' itu kedudukannya apa?", "papan": {"judul": "LATIHAN 3", "baris": ["as-suuqi = ?", "setelah jer • makhfudh"]}, "benar": "Benar! Isim setelah huruf jer ila — makhfudh dengan kasrah.", "salah": "Belum tepat. As-suuqi itu setelah huruf jer ila — makhfudh dengan kasrah. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "Kata al-masjidu dalam 'al-masjidu kabiirun' itu kedudukannya apa?", "papan": {"judul": "LATIHAN 4", "baris": ["al-masjidu = ?", "mubtada • marfu'"]}, "benar": "Benar! Mubtada — pokok kalimat isim — marfu' dengan dhammah.", "salah": "Belum tepat. Al-masjidu itu pokok kalimat isim — mubtada, marfu' dengan dhammah. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "Kata ath-thaalibi dalam 'haadzaa kitaabu ath-thaalibi' itu kedudukannya apa?", "papan": {"judul": "LATIHAN 5", "baris": ["ath-thaalibi = ?", "mudhaf ilaih • makhfudh"]}, "benar": "Benar! Mudhaf ilaih — kata kedua dalam sandaran — makhfudh dengan kasrah.", "salah": "Belum tepat. Ath-thaalibi itu kata kedua dalam sandaran — mudhaf ilaih, makhfudh dengan kasrah. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: sebutkan semua kedudukan marfu' yang dipelajari di Bagian 4.", "papan": {"judul": "KUIS", "baris": ["kedudukan marfu'", "ada tujuh"]}, "benar": "Benar! Fa'il, naib fa'il, mubtada, khabar, isim kaana, khabar inna, dan isim laa nafi jins.", "salah": "Belum tepat. Tujuh kedudukan marfu': fa'il, naib fa'il, mubtada, khabar, isim kaana, khabar inna, dan isim laa nafi jins. Coba lagi."},
	{"id": "penutup", "tipe": "pesan", "teks": "Alhamdulillah, Modul 04 tuntas — dan dengan ini Nahwu Dasar selesai. Kamu dapat 35 poin — 10 materi, 15 latihan, 10 kuis. Selanjutnya kita naik ke Jurumiyah dengan bimbingan ustadz, atau langsung tes kenaikan di kantor, duduk berhadapan dengan saya.", "papan": {"judul": "TUNTAS", "baris": ["Modul 04 — 35 poin", "Nahwu Dasar selesai"]}},
	{"id": "tugas", "tipe": "tugas", "teks": "Tugasmu ada dua. Pertama, hafalkan baitnya — 'Rafa'-kan fa'il, nashob-kan maf'ul…' — lalu setorkan hafalanmu ke saya. Kedua, baca 1 bab di rak kitab — pilih bab yang ringan. Kalau baitnya sudah hafal, kamu dapat 5 poin.", "papan": {"judul": "TUGAS", "baris": ["hafal bait + setorkan", "baca 1 bab di rak kitab", "+5 poin"]}},
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
		return 5
	if id == "u2":
		return 9
	if id == "u3":
		return 13
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
		return ["p1", "n1", "n2", "n3", "n4", "c1"]
	if resume_id == "u2":
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "n7", "c2"]
	if resume_id == "u3":
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "n7", "c2", "n8", "n9", "n10", "c3"]
	if resume_id == "u4":
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "n7", "c2", "n8", "n9", "n10", "c3", "n11", "c4"]
	var out: Array[String] = []
	for id in SPINE:
		if id == resume_id:
			break
		out.append(id)
	return out


## Opsi jawaban sebuah node soal dari DataModul04 (satu sumber
## kebenaran untuk opsi + indeks benar). Latihan: 5 soal, opsi
## sama; kuis: soal pertama bank N4.T.
## (DataModul04 dibuat Sinta saat port — pola data_modul_01.gd.)
static func opsi_soal(nod: Dictionary) -> Array:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul04.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return bank[idx].get("opsi", [])
		return []
	var lat: Array = DataModul04.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return lat[idx2].get("opsi", [])
	return []


## Indeks jawaban benar sebuah node soal dari DataModul04
## (kunci "jawaban" — lihat DataModul04.latihan_soal()).
static func benar_soal(nod: Dictionary) -> int:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul04.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return int(bank[idx].get("jawaban", 0))
		return 0
	var lat: Array = DataModul04.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return int(lat[idx2].get("jawaban", 0))
	return 0
