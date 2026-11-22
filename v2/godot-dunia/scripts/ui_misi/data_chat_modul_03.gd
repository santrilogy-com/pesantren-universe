class_name DataChatModul03
extends RefCounted
## Data percakapan Ruang Belajar Modul 03 — NARASI TEKS v4
## (v2/konsep/KONSEP-RUANG-BELAJAR-v4-TEKS.md, pola Modul 01 v4).
## Guru menjelaskan seperti guru beneran — detail dan lengkap — lewat
## dialog chat. TIDAK ada video, TIDAK ada gate tonton, TIDAK ada
## lanjut otomatis: pemain yang menentukan lanjut/tidaknya (tombol
## "Lanjut ›" / tap gelembung); KONSEP + NASKAH v4 DI-ACC Mas
## 22:52 — "Acc semua sampai selesai").
##
## PORT (Sinta, 22 Nov 23:03): NARASI + NOD + SPINE + helper disalin
## dari data_chat_modul_03_v4.gd (naskah Laras — file sumber, TIDAK
## dihapus); class_name tetap DataChatModul03.
##
##
## Sumber SATU-SATUNYA: Modul 03 tashih-lolos
## (ruang-belajar-nahwu-dasar-03-fiil-dan-irobnya.md, TASHIH LOLOS
## 22 Nov 2026 — Mas ACC "Acc semua sampai selesai").
## Tidak ada materi di luar modul. Item DITAHAN tetap TIDAK
## diajarkan: perubahan bentuk mu'tal (i'lal) — santri hanya
## mengenali golongan shahih/mu'tal (mitsal/ajwaf/naqish).
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
## Soal (l1-l5, k1) merujuk DataModul03 — file data dibuat Sinta
## saat port (pola data_modul_01.gd: latihan_soal() 5 soal dari
## Latihan A Modul 03, kuis_soal() 10 soal dari Kuis Modul 03;
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
## Panjang node (terverifikasi skrip): narasi n1-n14 total 1.227 kata
## (rata-rata ~88 kata/node, rentang 67-100); cek 38-49 kata
## (total 167); ulang 51-63 kata (total 228); p1 48 kata.
## Bait hafalan + rangkuman + tugas diambil PERSIS dari Modul 03.

const POIN_MATERI := 10
const POIN_LATIHAN := 15
const POIN_KUIS := 10
const POIN_TUGAS := 5
const POIN_TOTAL := 40

## Tulang punggung linear (28 node) — dipakai bilah progres
## (tanpa teks penghitung — koreksi Mas 19 Nov 15:09) dan
## rekonstruksi Riwayat saat resume.
## Node ulang (u1-u4) TIDAK masuk SPINE — mereka menempati slot cek-nya.
const SPINE: Array[String] = ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "c2", "n7", "n8", "c3", "n9", "n10", "n11", "c4", "n12", "n13", "n14", "p_latihan", "l1", "l2", "l3", "l4", "l5", "k1", "penutup", "tugas"]

## Narasi guru — naskah Modul 03 ASLI (Laras, 22 Nov 2026).
## p1 sapaan; n1-n14 narasi (tujuan, madhi, mudhori', amar,
## mujarrod/mazid, muta'addi/lazim, ma'lum/majhul, shahih/mu'tal,
## rafa', nashob, jazm, bait hafalan, rangkuman 1-2); c1-c4 cek
## "Paham? Fahimtum?"; u1-u4 ulang (1x per cek); p_latihan
## transisi ke latihan.
const NARASI: Array = [
	{"id": "p1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Assalamu'alaikum, Nak. Hari ini kita lanjut Nahwu Dasar — Modul 03: Fi'il dan I'robnya. Kemarin kamu sudah bisa menggolongkan isim. Hari ini giliran fi'il — mesin kalimat. Fi'il itu bergerak menurut waktu, bertambah huruf, butuh objek atau tidak, dan akhir katanya berubah karena rafa', nashob, dan jazm. Siap?", "papan": {"judul": "NAHWU DASAR", "baris": ["Modul 03 — Fi'il dan I'robnya"]}},
	{"id": "n1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Tujuan hari ini: kamu bisa menggolongkan fi'il dan memberi i'rob pada fi'il mudhori'. Lima pertanyaan untuk setiap fi'il — hafalkan. Kapan? Sudah terjadi, sedang, atau diperintahkan? Bertambah? Asli tiga atau empat huruf, atau ada tambahan? Butuh objek? Pelaku disebut? Hurufnya sehat? Lima pertanyaan itu peta Bagian 3 ini. Ingat ya: fi'il itu mesin kalimat — ia bergerak menurut waktu, bertambah huruf, butuh objek atau tidak, dan akhir katanya berubah. Kita mulai dari pertanyaan pertama: kapan?", "papan": {"judul": "LIMA PERTANYAAN", "baris": ["kapan? • bertambah?", "objek? • pelaku? • sehat?"]}},
	{"id": "n2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Fi'il madhi menunjukkan perbuatan yang sudah terjadi sebelum waktu bicara. Ia mabni — bentuk dasarnya tetap, akhirannya mengikuti pelaku. Contohnya: kataba ath-thaalibu ad-darsa — 'Siswa itu telah menulis pelajaran.' Perhatikan akhirannya: kataba — dia laki-laki telah menulis. Katabat — dia perempuan telah menulis. Katabuu — mereka telah menulis. Katabtu — saya telah menulis. Katabnaa — kami telah menulis. Ciri mudahnya: madhi bisa diakhiri ta ta'nits sukun untuk pelaku perempuan, dan bisa menerima kata ganti pelaku di akhir kata.", "papan": {"judul": "FI'IL MADHI", "baris": ["sudah terjadi", "mabni • kataba"]}},
	{"id": "n3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Fi'il mudhori' menunjukkan perbuatan yang sedang atau akan terjadi. Ia diawali salah satu huruf mudhori' yang terkumpul dalam kata anaytu: alif, nun, ya, ta. Contohnya: yaktubu ath-thaalibu ad-darsa — 'Siswa itu sedang atau akan menulis pelajaran.' Perhatikan awalnya: ya untuk dia laki-laki atau mereka, ta untuk dia perempuan atau kamu, alif untuk saya, nun untuk kami. Dan ingat satu hal penting: fi'il mudhori' adalah satu-satunya fi'il yang mu'rob — akhirnya bisa rafa', nashob, atau jazm. Tiga bagian terakhir modul ini khusus membahasnya. Mudhori' mirip isim dalam hal berubah akhir — karena itu namanya mudhori', artinya 'yang menyerupai'.", "papan": {"judul": "FI'IL MUDHORI'", "baris": ["sedang / akan", "anaytu • mu'rob"]}},
	{"id": "n4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Fi'il amar adalah perintah kepada orang yang diajak bicara. Ia mabni, dibentuk dari fi'il mudhori' untuk 'kamu'. Contohnya: iqra' kitaabaka — 'Bacalah kitabmu!' Perhatikan pasangannya: taktubu — kamu menulis — menjadi uktub — tulislah! Taqra'u menjadi iqra' — bacalah! Tadzhabu menjadi idzhab — pergilah! Pasangan amar adalah nahi — larangan — yang memakai la nahiyah ditambah mudhori' majzum: laa taktub — 'Jangan menulis!' Larangan ini dibahas di halaman jazm nanti. Ingat ya: tiga waktu fi'il — madhi sudah terjadi, mudhori' sedang atau akan terjadi, amar perintah sekarang. Hanya mudhori' yang mu'rob; madhi dan amar mabni.", "papan": {"judul": "FI'IL AMAR", "baris": ["perintah 'kamu'", "uktub • iqra' • idzhab"]}},
	{"id": "c1", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — tiga waktu fi'il: madhi itu sudah terjadi dan mabni, seperti kataba. Mudhori' itu sedang atau akan terjadi, diawali huruf anaytu, dan satu-satunya yang mu'rob, seperti yaktubu. Amar itu perintah dari mudhori' 'kamu', seperti uktub. Paham? Fahimtum?", "papan": {"judul": "CEK — TIGA WAKTU", "baris": ["madhi • mudhori' • amar", "kataba • yaktubu • uktub"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n5"}, {"teks": "Belum, jelaskan lagi", "ke": "u1"}]},
	{"id": "u1", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu akar: kataba — dia telah menulis — itu madhi, sudah terjadi. Yaktubu — dia sedang atau akan menulis — itu mudhori', diawali ya. Uktub — tulislah! — itu amar, perintah untuk kamu. Satu akar, tiga waktu. Coba perhatikan: madhi dan amar itu mabni — bentuknya tetap. Mudhori' itu mu'rob — akhirnya bisa berubah. Paham sekarang?", "papan": {"judul": "TIGA WAKTU — ULANG", "baris": ["kataba → madhi", "yaktubu → mudhori'", "uktub → amar"]}, "berikut": "n5"},
	{"id": "n5", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan kedua: bertambah atau tidak? Mujarrod itu murni — semua hurufnya asli, tanpa tambahan. Tsulatsi tiga huruf: kataba — menulis. Ruba'i empat huruf: dahraja — menggelindingkan. Mazid itu bertambah — ada huruf tambahan di akar katanya, dan tambahan itu mengubah arti dengan pola yang teratur. Contohnya: 'alima — tahu — menjadi 'allama — mengajar, membuat tahu. Kharaja — keluar — menjadi akhraja — mengeluarkan. Kataba menjadi kaataba — saling menulis, berkirim surat. 'Alima menjadi ta'allama — belajar, berusaha tahu. Rincian wazannya materi tashrif; di sini cukup tahu satu hal: huruf tambahan bukan hiasan — ia membawa arti baru.", "papan": {"judul": "MUJARROD • MAZID", "baris": ["mujarrod = asli", "mazid = bertambah"]}},
	{"id": "n6", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan ketiga: butuh objek atau sudah cukup? Muta'addi itu perbuatannya sampai ke objek — maf'ul bih. Kalimat belum lengkap tanpa objek. Contohnya: syariba al-maa-a — 'Dia minum air itu.' Lazim itu perbuatannya cukup pada pelaku saja — kalimat sudah lengkap dengan fa'il. Contohnya: jalasa ath-thaalibu — 'Siswa itu duduk.' Uji cepatnya: tanyakan 'apa atau siapa yang di-...?' Bila ada jawabannya di kalimat, fi'il itu muta'addi. Bahasan maf'ul bih ada di Bagian 4 — untuk sekarang, cukup bisa membedakan keduanya.", "papan": {"judul": "MUTA'ADDI • LAZIM", "baris": ["butuh objek?", "syariba • jalasa"]}},
	{"id": "c2", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — mujarrod itu semua hurufnya asli, seperti kataba; mazid itu ada huruf tambahan yang membawa arti baru, seperti 'allama dari 'alima. Dan muta'addi itu butuh objek, seperti syariba al-maa-a; lazim itu cukup pada pelaku, seperti jalasa ath-thaalibu. Paham? Fahimtum?", "papan": {"judul": "CEK — GOLONGAN", "baris": ["mujarrod • mazid", "muta'addi • lazim"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n7"}, {"teks": "Belum, jelaskan lagi", "ke": "u2"}]},
	{"id": "u2", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan uji cepatnya. Syariba al-maa-a — dia minum air itu. Tanyakan: minum apa? Ada jawabannya — air. Jadi muta'addi, butuh objek. Jalasa ath-thaalibu — siswa itu duduk. Tanyakan: duduk apa? Tidak ada jawabannya — jadi lazim, cukup pada pelaku. Satu pertanyaan, dua jawaban. Pegang uji ini — 'apa atau siapa yang di-...?' — ia dipakai lagi di Bagian 4. Paham sekarang?", "papan": {"judul": "GOLONGAN — ULANG", "baris": ["minum apa? → muta'addi", "duduk apa? → lazim"]}, "berikut": "n7"},
	{"id": "n7", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan keempat: pelaku disebut atau disembunyikan? Ma'lum itu pelakunya disebut sebagai fa'il. Contohnya: kataba ath-thaalibu — 'Siswa itu menulis.' Majhul itu pelaku tidak disebut — objek naik menjadi naib fa'il, pengganti pelaku. Contohnya: kutiba ad-darsu — 'Pelajaran itu ditulis.' Polanya mudah dikenali. Madhi majhul: awalnya didhammah dan huruf sebelum akhir dikasrah — kataba menjadi kutiba. Mudhori' majhul: awalnya didhammah dan huruf sebelum akhir difathah — yaktubu menjadi yuktabu. Jadi gini: kalau pelakunya disebut, itu ma'lum; kalau disembunyikan, objeknya naik jadi naib fa'il.", "papan": {"judul": "MA'LUM • MAJHUL", "baris": ["kataba → kutiba", "yaktubu → yuktabu"]}},
	{"id": "n8", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Pertanyaan kelima: hurufnya sehat? Huruf sakit — illat — ada tiga: alif, waw, ya. Fi'il yang huruf aslinya mengandung huruf illat disebut mu'tal; selain itu shahih. Golongannya ada empat. Shahih: kataba, jalasa — semua huruf asli sehat. Mu'tal awal, mitsal: wa'ada — awal kata waw, dia berjanji. Mu'tal tengah, ajwaf: qaala — tengah kata alif, dia berkata. Mu'tal akhir, naqish: da'aa, ramaa — akhir kata illat, dia berdoa, dia melempar. Satu catatan penting: perubahan bentuk mu'tal saat bertemu pelaku yang berbeda — i'lal — sengaja tidak saya ajarkan di sini. Di tingkat dasar, kenali dulu golongannya.", "papan": {"judul": "SHAHIH • MU'TAL", "baris": ["alif • waw • ya", "mitsal • ajwaf • naqish"]}},
	{"id": "c3", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat — ma'lum itu pelakunya disebut, seperti kataba ath-thaalibu; majhul itu pelaku disembunyikan dan objek naik jadi naib fa'il, seperti kutiba ad-darsu. Dan shahih itu semua hurufnya sehat, mu'tal itu mengandung alif, waw, atau ya. Paham? Fahimtum?", "papan": {"judul": "CEK — MA'LUM", "baris": ["ma'lum • majhul", "shahih • mu'tal"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n9"}, {"teks": "Belum, jelaskan lagi", "ke": "u3"}]},
	{"id": "u3", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan dua kata. Qaala — dia berkata — itu mu'tal ajwaf, huruf illat alif di tengah kata. Kataba — dia menulis — itu shahih, semua huruf aslinya sehat. Jadi tanyanya begini: ada alif, waw, atau ya di huruf aslinya? Kalau ada, itu mu'tal; kalau tidak, itu shahih. Paham sekarang?", "papan": {"judul": "MA'LUM — ULANG", "baris": ["qaala → ajwaf", "kataba → shahih"]}, "berikut": "n9"},
	{"id": "n9", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sekarang i'rob fi'il mudhori' — hanya mudhori' yang mu'rob, dan i'robnya ditentukan kata di depannya. Pertama, rafa' — keadaan asal fi'il mudhori'. Fi'il mudhori' itu marfu' bila tidak didahului penashob dan penjazim. Tanda rafa' yang paling umum adalah dhammah di akhir kata: yaktubu, yadzhabu, naqra-u. Tapi ada yang di-rafa' dengan tetapnya nun — untuk dua orang dan mereka laki-laki: yaktubaani, yaktubuuna. Kelompok 'lima fi'il' ini di-rafa' dengan tetapnya nun, di-nashob dan di-jazm dengan hilangnya nun. Ingat pola ini — ia muncul di dua bagian berikutnya.", "papan": {"judul": "RAFA' MUDHORI'", "baris": ["dhammah • tsubut nun", "lima fi'il"]}},
	{"id": "n10", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Kedua, nashob — fi'il mudhori' menjadi manshub bila didahului huruf nashob, dan tanda utamanya fathah. Lima penashob yang wajib dikenal: an — uriidu an aqra'a, saya ingin membaca. Lan — lan yakdziba, dia tidak akan berdusta. Kai — ji'tu kai ta'allama, saya datang agar belajar. Hatta — lan nabraha hatta yarji'a, kami tidak pergi sampai ia kembali. Idzan — idzan tanjaha, kalau begitu kamu akan berhasil. Contohnya: lan yadz-haba ath-thaalibu — 'Siswa itu tidak akan pergi.' Perhatikan baik-baik: ada an, lan, kai, hatta, atau idzan di depan mudhori' — akhir kata dibaca A, nashob.", "papan": {"judul": "NASHOB", "baris": ["an • lan • kai", "hatta • idzan"]}},
	{"id": "n11", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Ketiga, jazm — fi'il mudhori' menjadi majzum bila didahului penjazim, dan tanda utamanya sukun. Empat penjazim yang wajib dikenal: lam — lam yaktub, dia tidak menulis. Lamma — lamma yashil, dia belum sampai. La nahiyah — laa takdzib, jangan berdusta! Lam amar — li-yaqra', hendaklah dia membaca. Contohnya: lam yadz-hab ath-thaalibu — 'Siswa itu tidak pergi.' Perhatikan bedanya: yadzhabu itu rafa', lan yadzhaba itu nashob, lam yadzhab — sukun — itu jazm. Satu fi'il, tiga akhir, tiga penanda di depannya. Ingat rumusnya: mudhori' tanpa penanda dibaca U, setelah penashob dibaca A, setelah penjazim dibaca sukun.", "papan": {"judul": "JAZM", "baris": ["lam • lamma • la", "lam amar • sukun"]}},
	{"id": "c4", "tipe": "cek", "pembicara": "Ust. Sanusi", "teks": "Coba ingat semuanya. Mudhori' tanpa penanda itu rafa' — dibaca U, seperti yaktubu. Setelah penashob seperti lan, itu nashob — dibaca A, seperti lan yadzhaba. Setelah penjazim seperti lam, itu jazm — dibaca sukun, seperti lam yadzhab. Rumusnya: tanpa penanda U, setelah penashob A, setelah penjazim sukun. Paham? Fahimtum?", "papan": {"judul": "CEK — I'ROB", "baris": ["tanpa penanda = U", "penashob = A", "penjazim = sukun"]}, "opsi": [{"teks": "Paham, lanjut ›", "ke": "n12"}, {"teks": "Belum, jelaskan lagi", "ke": "u4"}]},
	{"id": "u4", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Saya ulangi dengan satu fi'il: yaqra-u. Sendiri, tanpa penanda di depannya — itu rafa', dibaca U. Setelah lan — lan yaqra-a — itu nashob, dibaca A. Setelah lam — lam yaqra' — itu jazm, dibaca sukun. Satu fi'il, tiga akhir, tiga penanda. Pegang rumusnya: tanpa penanda U, setelah penashob A, setelah penjazim sukun. Paham sekarang?", "papan": {"judul": "I'ROB — ULANG", "baris": ["yaqra-u → rafa'", "lan yaqra-a → nashob", "lam yaqra' → jazm"]}, "berikut": "n12"},
	{"id": "n12", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Sebelum latihan, hafalkan bait ini. Baitnya orisinal dari Pesantren Universe:\nالْفِعْلُ مَاضٍ ثُمَّ مُضَارِعٌ * وَأَمْرٌ لِمَنْ تُخَاطِبُ حَاضِرًا\nArtinya: fi'il itu madhi, lalu mudhori', dan amar untuk orang yang kau ajak bicara. Dan ingat tambahannya: mudhori' di-rafa' dengan u, di-nashob dengan a, di-jazm dengan sukun. Ucapkan tiga kali pelan-pelan, lalu tutup mata dan ucapkan sekali tanpa melihat. Bait ini nanti kamu setorkan ke saya sebagai tugas.", "papan": {"judul": "BAIT HAFALAN", "baris": ["Fi'il itu madhi,", "lalu mudhori', dan amar"]}},
	{"id": "n13", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Terakhir, rangkumannya — tujuh hal yang harus kamu bawa pulang hari ini. Satu: waktu — madhi itu sudah terjadi dan mabni, mudhori' itu sedang atau akan terjadi dan satu-satunya yang mu'rob, amar itu perintah dari mudhori' 'kamu' dan mabni; pasangan amar adalah nahi, la ditambah mudhori' majzum. Dua: tambahan — mujarrod itu asli tiga atau empat huruf, mazid itu ada huruf tambahan yang membawa arti baru: 'allama, akhraja, kaataba, ta'allama. Tiga: objek — muta'addi butuh maf'ul bih, lazim cukup dengan fa'il. Empat: pelaku — ma'lum itu pelaku disebut sebagai fa'il, majhul itu pelaku disembunyikan dan objek naik jadi naib fa'il.", "papan": {"judul": "RANGKUMAN 1", "baris": ["waktu • tambahan", "objek • pelaku"]}},
	{"id": "n14", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Lima: huruf — shahih itu semua hurufnya sehat, mu'tal itu mengandung alif, waw, atau ya: mitsal di awal, ajwaf di tengah, naqish di akhir. I'lal ditahan — menunggu tashih. Enam: i'rob mudhori' — rafa' dengan dhammah atau tetapnya nun, nashob dengan fathah setelah an, lan, kai, hatta, idzan, jazm dengan sukun setelah lam, lamma, la nahiyah, dan lam amar. Tujuh: lima pertanyaan untuk setiap fi'il — kapan? Bertambah? Butuh objek? Pelaku disebut? Hurufnya sehat? Tujuh hal ini — hafalkan, karena semuanya dipakai di Modul 04 nanti.", "papan": {"judul": "RANGKUMAN 2", "baris": ["huruf • i'rob", "lima pertanyaan"]}},
	{"id": "p_latihan", "tipe": "narasi", "pembicara": "Ust. Sanusi", "teks": "Alhamdulillah, materinya selesai. Sekarang kita latihan — 5 soal. Jawab dengan tenang. Kalau salah, nanti saya jelaskan, lalu soalnya diulang. Siap?", "papan": {"judul": "LATIHAN", "baris": ["5 soal", "salah → dijelaskan"]}},
]

const NOD: Array = [
	{"id": "l1", "tipe": "soal", "bank": "latihan", "soal": 0, "teks": "Coba tebak — nashara (dia telah menolong) itu madhi, mudhori', atau amar?", "papan": {"judul": "LATIHAN 1", "baris": ["nashara = ?", "sudah → madhi"]}, "benar": "Benar! Perbuatan yang sudah terjadi — madhi.", "salah": "Belum tepat. Nashara itu perbuatan yang sudah terjadi — madhi. Coba lagi."},
	{"id": "l2", "tipe": "soal", "bank": "latihan", "soal": 1, "teks": "yanshuru (dia sedang atau akan menolong) itu madhi, mudhori', atau amar?", "papan": {"judul": "LATIHAN 2", "baris": ["yanshuru = ?", "ya → mudhori'"]}, "benar": "Benar! Diawali ya, huruf mudhori' — perbuatan sedang atau akan terjadi.", "salah": "Belum tepat. Yanshuru diawali ya, huruf mudhori' — perbuatan sedang atau akan terjadi. Coba lagi."},
	{"id": "l3", "tipe": "soal", "bank": "latihan", "soal": 2, "teks": "unshur (tolonglah!) itu madhi, mudhori', atau amar?", "papan": {"judul": "LATIHAN 3", "baris": ["unshur = ?", "perintah → amar"]}, "benar": "Benar! Perintah kepada orang yang diajak bicara — amar.", "salah": "Belum tepat. Unshur itu perintah — amar. Coba lagi."},
	{"id": "l4", "tipe": "soal", "bank": "latihan", "soal": 3, "teks": "ta'allama (dia telah belajar) itu madhi, mudhori', atau amar?", "papan": {"judul": "LATIHAN 4", "baris": ["ta'allama = ?", "sudah → madhi"]}, "benar": "Benar! Perbuatan yang sudah terjadi — madhi, walau mazid.", "salah": "Belum tepat. Ta'allama itu perbuatan yang sudah terjadi — madhi. Coba lagi."},
	{"id": "l5", "tipe": "soal", "bank": "latihan", "soal": 4, "teks": "sa-yaktubu (dia akan menulis) itu madhi, mudhori', atau amar?", "papan": {"judul": "LATIHAN 5", "baris": ["sa-yaktubu = ?", "sin + ya → mudhori'"]}, "benar": "Benar! Diawali sin dan ya mudhori' — akan terjadi.", "salah": "Belum tepat. Sa-yaktubu diawali sin dan ya mudhori' — akan terjadi. Coba lagi."},
	{"id": "k1", "tipe": "soal", "bank": "kuis", "soal": 0, "teks": "Terakhir, satu soal kuis: manakah tiga fi'il menurut waktu?", "papan": {"judul": "KUIS", "baris": ["tiga fi'il", "menurut waktu"]}, "benar": "Benar! Madhi, mudhori', dan amar.", "salah": "Belum tepat. Tiga fi'il menurut waktu: madhi, mudhori', dan amar. Coba lagi."},
	{"id": "penutup", "tipe": "pesan", "teks": "Alhamdulillah, Modul 03 tuntas. Kamu dapat 35 poin — 10 materi, 15 latihan, 10 kuis. Besok kita lanjut Modul 04 — keadaan isim dalam kalimat, atau langsung tes kenaikan di kantor, duduk berhadapan dengan saya.", "papan": {"judul": "TUNTAS", "baris": ["Modul 03 — 35 poin", "materi 10 • latihan 15", "kuis 10"]}},
	{"id": "tugas", "tipe": "tugas", "teks": "Tugasmu ada dua. Pertama, hafalkan baitnya — 'Fi'il itu madhi, lalu mudhori'…' — lalu setorkan hafalanmu ke saya. Kedua, baca 1 bab di rak kitab — pilih bab yang ringan. Kalau baitnya sudah hafal, kamu dapat 5 poin.", "papan": {"judul": "TUGAS", "baris": ["hafal bait + setorkan", "baca 1 bab di rak kitab", "+5 poin"]}},
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
		return 8
	if id == "u3":
		return 11
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
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "c2"]
	if resume_id == "u3":
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "c2", "n7", "n8", "c3"]
	if resume_id == "u4":
		return ["p1", "n1", "n2", "n3", "n4", "c1", "n5", "n6", "c2", "n7", "n8", "c3", "n9", "n10", "n11", "c4"]
	var out: Array[String] = []
	for id in SPINE:
		if id == resume_id:
			break
		out.append(id)
	return out


## Opsi jawaban sebuah node soal dari DataModul03 (satu sumber
## kebenaran untuk opsi + indeks benar). Latihan: 5 soal, opsi
## sama; kuis: soal pertama bank N3.T.
## (DataModul03 dibuat Sinta saat port — pola data_modul_01.gd.)
static func opsi_soal(nod: Dictionary) -> Array:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul03.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return bank[idx].get("opsi", [])
		return []
	var lat: Array = DataModul03.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return lat[idx2].get("opsi", [])
	return []


## Indeks jawaban benar sebuah node soal dari DataModul03
## (kunci "jawaban" — lihat DataModul03.latihan_soal()).
static func benar_soal(nod: Dictionary) -> int:
	if String(nod.get("bank", "")) == "kuis":
		var bank: Array = DataModul03.kuis_soal()
		var idx := int(nod.get("soal", 0))
		if idx >= 0 and idx < bank.size():
			return int(bank[idx].get("jawaban", 0))
		return 0
	var lat: Array = DataModul03.latihan_soal()
	var idx2 := int(nod.get("soal", 0))
	if idx2 >= 0 and idx2 < lat.size():
		return int(lat[idx2].get("jawaban", 0))
	return 0
