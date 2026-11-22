# KONSEP — Ruang Belajar v4: "Guru menjelaskan lewat dialog teks, santri yang menentukan lanjut"

**Keputusan Mas (22 Nov 2026, 16:03 WIB):** "Berhenti dulu.. kita lanjutkan
project godot. Untuk misinya pakai tulisan aja tapi dg narasi seperti
menjelaskan dan detail serta lengkap sebagaimana guru beneran. Pakai dialog
tetap, tapi tidak otomatis lanjut.. player yg menentukan lanjut tidaknya."
**Konsep v3 (video) DITUNDA — bukan dihapus.** Panel video tidak jadi
dibangun; spike pemutar video (`v2/spike-pemutar-video/`, SUDAH TERBUKTI
jalan) disimpan sebagai arsip. Produksi video episode Nahwu (VO + Remotion)
juga berhenti bersama karakter.

**Status:** KONSEP — naskah Modul 01 selesai (file data dialog v4, §8).
Kode game TIDAK diubah oleh dokumen ini.
**Sumber:** konsep v3 + mockup pemandu v3 (panel chat — TETAP berlaku),
`DRAF-ALUR-MISI.md` v5.4.1 (§1A langkah 5, §2.1, §2.9, §9 TERKUNCI),
Modul 01 Tim Kurikulum (`ruang-belajar-nahwu-dasar-01-mengenal-kata.md`,
TASHIH LOLOS 18 Nov), dan **keadaan kode nyata 22 Nov: Sinta SUDAH
membangun mekanik dialog teks + lanjut manual secara paralel**
(`ruang_belajar_ui.gd`, `manajer_ui_misi.gd`, kunci save `rb_fase` +
`rb_node_terakhir` di `save_data.gd`). Konsep ini ditulis mengikuti
mekanik yang SUDAH ADA itu — bukan asumsi baru.

---

## 0. Masalah yang diperbaiki

1. **Chat v1 dangkal (penilaian Mas, 19 Nov 23:36):** 14 pesan pendek,
   materi terpotong jadi gelembung, susah diulang, struktur tidak
   kelihatan. v4 menjawabnya dengan narasi guru yang detail dan
   lengkap — 14 node narasi, 1.201 kata, satu topik utuh per node —
   bukan dengan memanjangkan gelembung v1.
2. **Video v3 tidak jadi:** produksi 1 episode butuh berhari-hari
   (naskah → VO → motion → render → verdict), VO episode 1 ditolak
   Mas, dan karakter berhenti. v4 memindahkan beban itu ke teks —
   yang bisa ditulis, ditashih, dan diubah dalam hitungan jam, bukan
   hari. Modul 02/03 yang di v3 **menunggu episode-nya kini TIDAK
   menunggu apa pun** (§11).
3. **Lanjut otomatis:** di v1/v2 ada chip Auto yang memajukan dialog
   sendiri. Mas meminta sebaliknya: pemain yang menentukan lanjut
   tidaknya. Chip Auto SUDAH DIHAPUS Sinta dari manajer (22 Nov).

**Prinsip v4:** guru mengajar lewat dialog teks (ustadz yang
menjelaskan, di chat); santri membaca dengan kecepatannya sendiri
dan mengetuk Lanjut kalau sudah paham. Reader tetap ada sebagai
pendamping (§6) — bukan pengganti narasi, melainkan teks modul
utuhnya untuk diulang.

---

## 1. Alur baru end-to-end (Modul 01 sebagai contoh)

Pola baku "Cari Ustadz → Belajar → Tugas dari Ustadz" (draf v5.4.1 §2.1)
**TETAP** — yang berubah hanya isi langkah "Belajar" (dulu chat v1
pendek, lalu reader v2, lalu video v3 yang tidak jadi, kini narasi
teks v4).

```
1. Cari Ustadz (TETAP)
   Santri menemukan Ust. Sanusi (lokasi random, tanpa marker) /
   Ustzh. Fatimah (putri). Ketuk → adegan belajar terbuka:
   ustadz DUDUK di atas tikar + meja + papan tulis kecil di sampingnya,
   kamera membingkai beliau (seperti v1 §8 — TIDAK berubah).

2. Chat pemandu — SINGKAT (p1)
   p1  "Assalamu'alaikum, Nak. Hari ini kita mulai belajar Nahwu
        Dasar — Modul 01: Mengenal Kata. Nahwu itu ilmu tentang
        perubahan akhir kata..." (40 kata)
       → pemain mengetuk "Lanjut ›" (atau ketuk gelembung) untuk
       masuk ke narasi. TIDAK ADA tombol "Tonton Episode" lagi.

3. Narasi guru — DETAIL DAN LENGKAP (§2, 14 node + 4 cek + 4 ulang)
   n1  Tujuan: kenapa akhir kata berubah (u/a/i = petunjuk)
   n2  Kalam: definisi + contoh + analogi rumah
   c1  CEK 1: "Paham? Fahimtum?" → "Paham" lanjut / "Belum" → u1
   n3  Isim: definisi + 5 contoh
   n4  Ciri-ciri isim: 4 ciri + rumus
   c2  CEK 2 (ciri isim) → u2
   n5  Fi'il: definisi + 3 waktu
   n6  Ciri-ciri fi'il: 4 ciri + larangan tanwin/al-
   n7  Huruf: definisi + 5 contoh
   c3  CEK 3 (tiga jenis kata) → u3
   n8  Rumus 10 detik + 5 contoh + 1 kalimat utuh
   n9  Mabni vs mu'rob: definisi + contoh
   n10 Kelompok mabni: 5 kelompok + madhi/amar mabni
   n11 u/a/i: tiga kalimat + rafa'/nashob/jer
   c4  CEK 4 (mabni + u/a/i) → u4
   n12 Bait hafalan (Arab + arti + cara menghafal)
   n13 Rangkuman 1 (poin 1-4)
   n14 Rangkuman 2 (poin 5-7)
   p_latihan  Transisi: "Alhamdulillah, materinya selesai.
       Sekarang kita latihan — 5 soal." → poin materi 10 diberikan
       saat pemain meninggalkan node ini ke l1 (§4).
   Tiap node maju HANYA bila pemain mengetuk (§3). Papan tulis
   menampilkan poin kunci node aktif (§7).

4. Latihan + kuis — DI CHAT (TETAP, sama seperti v1/v3)
   l1–l5  Soal latihan (5 soal, dari DataModul01; salah → ustadz
           menjelaskan dari "salah" + soal diulang, opsi salah
           dihilangkan). → +15 poin latihan.
   k1  Kuis (1 soal dari bank N1.T). → +10 poin kuis.

5. Penutup + tugas (TETAP)
   penutup  "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin..."
       + kartu "Tuntas — 35 poin".
   tugas  "Tugasmu ada dua: hafalkan baitnya... baca 1 bab di rak
       kitab..." → +5 poin saat tugas DITERIMA (tombol
       "Terima Tugas ✓", sesuai implementasi UI Sinta saat ini —
       lihat catatan §4).
       → maju langkah 5→6 (tes kenaikan), toast seperti sekarang.
```

**Total node v4: 32** (28 di tulang punggung + 4 node ulang
kondisional) — bandingkan v1: 14 node, v3: 6 node pemandu + video.
Yang kembali dari v1: cabang "Belum" (maks 1x per cek, §2) — karena
di v4 tidak ada video yang bisa memutar ulang penjelasan.

**Buka ulang setelah selesai → mode baca ulang:** chat menampilkan
semua node tanpa poin lagi (guard `rb_selesai` — sudah di UI Sinta),
tombol "Baca Ulang Modul" membuka reader (§6).

---

## 2. Struktur node dialog — panjang, gaya bahasa, metode

### 2.1 Jenis node

| Tipe | Isi | Maju dengan | Jumlah (Modul 01) |
|---|---|---|---|
| `narasi` | Penjelasan guru (detail, lengkap) | Tombol "Lanjut ›" / ketuk gelembung | 20 (p1, n1–n14, u1–u4, p_latihan) |
| `cek` | Rangkuman singkat + "Paham? Fahimtum?" | HANYA tombol opsi (2 pilihan) | 4 (c1–c4) |
| `soal` | Latihan/kuis (opsi dari DataModul01) | Jawaban benar (salah → diulang) | 6 (l1–l5, k1) |
| `pesan` | Penutup | Tombol "Lanjut ›" | 1 (penutup) |
| `tugas` | Pemberian tugas | Tombol "Terima Tugas ✓" | 1 (tugas) |

Penutup WAJIB tipe `pesan` (bukan `penutup`) — UI Sinta tidak punya
arm `penutup`, jadi tipe itu tidak menampilkan tombol apa pun.

### 2.2 Panjang per node (terukur dari file data v4)

- **Narasi n1–n14: 64–115 kata, rata-rata ~86 kata, total 1.201 kata.**
  Satu node = satu topik utuh (satu § modul), 4–8 kalimat pendek,
  dibaca ±30–45 detik. Gelembung panjang tapi masih satu layar
  baca di HP (panel chat v3, font Baloo 2).
- **Cek: 36–60 kata (total 177).** Rangkuman 2–3 kalimat + pertanyaan.
- **Ulang: 50–59 kata (total 217).** Penjelasan ulang dengan contoh
  LAIN (bukan pengulangan kata yang sama).
- **Sapaan p1: 40 kata. Transisi p_latihan: 21 kata. Penutup: 31 kata.
  Tugas: 37 kata.**

Aturan panjang: **satu node = satu topik, maksimal ~120 kata.**
Bila satu § modul tidak muat (contoh: §6 Mabni vs Mu'rob = 164 kata),
PECAH jadi dua node (n9 + n10) — jangan memanjangkan gelembung.
Papan tulis memikul tabel/contoh supaya gelembung tidak membengkak
(§7).

### 2.3 Gaya bahasa guru (metode Mas)

Metode Mas (20 Nov 12:16–12:17): **"Jelaskan, tanyakan, jelaskan,
tanyakan"** — jelaskan konsep pelan-pelan, diulang 2–3 kali dengan
penekanan kata kunci, lalu tanyakan ("Paham? Fahimtum?"). Sebagai
TEKS dialog:

- **Sapaan:** "Nak" (Sanusi putra / Fatimah putri — satu naskah,
  `pembicara` di-resolve UI ke pengajar sesi ini).
- **Penjelasan pelan-pelan:** satu ide per kalimat; contoh langsung
  setelah definisi; analogi dari modul (kalimat seperti rumah).
- **Pengulangan 2–3x dengan penekanan kata kunci:** kata kunci
  diulang dalam kalimat yang berbeda ("Isim itu tidak terikat
  waktu... Itu bedanya dengan fi'il"; "tanwin, al-, huruf jer,
  idhafah — empat ciri itu..."), dan muncul lagi di papan tulis
  (§7) serta di node cek. Pengulangan pakai variasi natural:
  "Ingat ya", "Coba perhatikan", "Jadi gini", "Perhatikan
  baik-baik", "Saya ulangi dengan contoh lain" — **TANPA
  "Sekali lagi"** (ditolak Mas di naskah v7 karena monoton;
  naskah v4 terverifikasi 0 kemunculan).
- **Pertanyaan:** tiap cek ditutup "Paham? Fahimtum?" — persis
  frasa Mas. Jawaban "Belum" membuka penjelasan ulang dengan
  contoh lain (maks 1x per cek), lalu hanya "Paham, lanjut ›"
  yang tampil.
- **Arab + transliterasi + arti** di setiap contoh (seperti modul):
  "Qaama Muhammadun — 'Muhammad telah berdiri.'"
- **Tidak ada materi di luar modul.** Naskah v4 diambil dari Modul 01
  tashih-lolos saja. Bait hafalan, rangkuman, dan tugas dikutip
  PERSIS dari modul.

### 2.4 Pembagian kerja narasi vs reader

Narasi = guru menjelaskan (detail, lengkap, dengan contoh,
pengulangan, dan pertanyaan). Reader = teks modul utuh (§1–§7 +
bait + rangkuman) untuk diulang. Narasi TIDAK perlu memuat setiap
baris tabel modul — tabel dan contoh lengkap ada di reader; narasi
membawa contoh-contoh kuncinya + cara berpikirnya.

---

## 3. Aturan lanjut manual (inti keputusan Mas)

1. **TIDAK ADA lanjut otomatis.** Tidak ada timer, tidak ada
   auto-scroll ke node berikut, tidak ada chip Auto (sudah dihapus
   Sinta dari manajer, 22 Nov).
2. **Tiap node maju HANYA bila pemain mengetuk** tombol emas
   "Lanjut ›" ATAU mengetuk gelembung dialog.
3. **Efek bicara TETAP** (±40 ms/huruf, kursor blok emas): ketuk
   saat mengetik = tampil penuh; ketuk lagi = node berikut.
   (Sudah di UI Sinta — `_on_kotak_gui_input`.)
4. **Node cek maju HANYA lewat tombol opsi.** Tidak ada tombol
   "Lanjut ›" di node cek — pemain harus memilih "Paham, lanjut ›"
   atau "Belum, jelaskan lagi".
5. **"Belum" maks 1x per cek.** Node ulang menampilkan penjelasan
   ulang (contoh lain), lalu hanya opsi "Paham, lanjut ›".
   Pemain yang masih belum paham bisa membaca ulang lewat
   **Riwayat** (log percakapan) atau tombol **"Baca Ulang Modul"**
   (reader, §6) — tanpa mengulang node tanpa henti.
6. **Resume:** titik resume = id node tulang punggung berikutnya
   (`rb_chat_pos`) + fase (`rb_fase`) + node narasi terakhir
   (`rb_node_terakhir`) — sudah di save (§5). Node ulang bukan
   titik resume: tutup di tengah ulang → kembali ke node cek-nya.
7. **Tombol Auto + Riwayat:** Auto DIHAPUS; Riwayat TETAP
   (log pesan ustadz + jawaban pemain).

---

## 4. Poin + penyelesaian + buka ulang

- **Poin TETAP (draf §2.1, §9 terkunci):** materi 10 / latihan 15 /
  kuis 10 / tugas 5 — total 40.
- **Poin materi 10** diberikan saat pemain meninggalkan node
  narasi terakhir (`p_latihan`) ke l1 — yaitu setelah narasi
  selesai dibaca sampai node terakhir. (Catatan implementasi:
  UI Sinta saat ini masih memicu di id `"n5"` — node contoh lama;
  HARUS diganti ke `"p_latihan"` saat port, 1 baris, §8.)
- **Penyelesaian = sampai node terakhir** (`tugas`): dialog
  selesai saat tugas diberikan. Poin 35 (materi+latihan+kuis)
  terkunci saat penutup.
- **Tugas +5 poin** diberikan saat tugas DITERIMA (tombol
  "Terima Tugas ✓") — sesuai implementasi UI Sinta saat ini
  (`_on_terima_tugas` meng-emit `langkah_selesai("tugas", 5)`).
  Catatan jujur: modul menulis "Hadiah: 5 poin untuk hafal bait"
  — yang diimplementasi adalah hadiah saat menerima tugas, bukan
  saat hafalan disetor. Bila Mas mau hadiahnya pindah ke saat
  setoran hafalan, itu keputusan tersendiri (Fase C, butuh
  mekanik setoran) — JANGAN diubah diam-diam di sini.
- **Anti-farming TETAP:** `rb_selesai` ("modul:jenis") — buka ulang
  modul yang sudah selesai = mode baca ulang, tanpa poin lagi.
- **Bilah progres emas:** posisi node di tulang punggung (28 node)
  — tanpa teks penghitung (koreksi Mas 19 Nov 15:09).

---

## 5. Kunci save (keadaan nyata — bukan rencana)

| Kunci | Status | Isi (v4) |
|---|---|---|
| `rb_chat_pos` | SUDAH ADA (v1) | id node BERIKUTNYA yang akan tampil |
| `rb_chat_modul` | SUDAH ADA (v1) | modul yang sedang berjalan |
| `rb_fase` | SUDAH ADA (Sinta, 22 Nov) | "narasi" / "latihan" / "kuis" / "penutup" / "tugas" / "selesai" |
| `rb_node_terakhir` | SUDAH ADA (Sinta, 22 Nov) | id node narasi TERAKHIR yang ditampilkan |
| `rb_selesai` | SUDAH ADA (Fase A) | ["modul:jenis"] anti-farming |
| `rb_tonton_detik` | TIDAK PERNAH DITAMBAH | v3 tidak jadi dibangun — tidak ada yang perlu dihapus |
| `rb_baca_bagian` | TIDAK DIPAKAI | reader tanpa gate (§6) |

Fase ditentukan `DataChatModul01.fase_node(id)` — sudah ada di file
Sinta; file v4 membawanya juga (diadaptasi ke id v4: `p1`,
`p_latihan`, `c1–c4`, `u1–u4` → "narasi").

---

## 6. Reader "Baca Ulang Modul" — pendamping, bukan langkah wajib

Reader modul (panel baca krem, pola v2) **tetap dibangun, tapi
bukan langkah wajib** — sama seperti v3 §4. Fungsinya:

- Tombol **"Baca Ulang Modul"** di Ruang Belajar (setelah selesai,
  dan dari panel misi) — untuk santri yang mau mengulang materi
  lewat teks utuh (menghafal bait, mengecek rumus, membaca contoh
  tanpa mengulang dialog).
- Isi reader = Modul 01 lengkap (§1–§7 + bait + rangkuman).
- **Tanpa gate baca, tanpa poin dari membaca** (poin materi 10
  sudah diberikan lewat narasi, §4).
- Perbedaan dari v3: di v3 reader dibuka dari panel video (yang
  kini tidak ada) — di v4 reader dibuka dari chat/panel misi.

---

## 7. Papan tulis kecil — isi = poin kunci node aktif

Adegan belajar TETAP (ustadz duduk + meja + papan tulis kecil di
sampingnya). Papan kini menampilkan **poin kunci node yang sedang
dibaca** — judul + 2–3 baris singkat — bukan judul episode (v3)
dan bukan ringkasan tetap (v1). Setiap node di file data v4
membawa `papan` sendiri (contoh: node n4 → judul "CIRI ISIM",
baris ["tanwin • al- • jer", "idhafah", "tanwin/al- → isim"]).
Sinyal `papan_berubah` (sudah di UI Sinta) memperbarui papan di
dunia tiap ganti node.

---

## 8. Yang BERUBAH saat implementasi (daftar file — JANGAN diubah sekarang)

| File | Perubahan (nanti, setelah ACC konsep) |
|---|---|
| `scripts/ui_misi/data_chat_modul_01_v4.gd` | **BARU — deliverable Laras, SUDAH SELESAI.** Naskah Modul 01 v4 (32 node: NARASI 24 + NOD 8; SPINE 28). Sintaks GDScript terverifikasi (`--check-only` lolos), struktur terverifikasi skrip (id unik, semua target opsi/`berikut` ada, 0× "Sekali lagi" di teks dialog). |
| `scripts/ui_misi/data_chat_modul_01.gd` | **PORT (Sinta):** salin NARASI + NOD + SPINE + helper (`cari`, `fase_node`, `jalur_log`, `indeks_progres`, `opsi_soal`, `benar_soal`) dari file v4 ke file ini; `class_name` tetap `DataChatModul01`. Simpan file Sinta saat ini (n1–n5 CONTOH) sebagai `data_chat_modul_01.gd.bak` dulu. File v4 sendiri TIDAK dihapus — ia sumber naskah. |
| `scripts/ui_misi/ruang_belajar_ui.gd` | **2 perubahan kecil (Sinta):** (1) `_tampilkan_pilihan`: tambah arm `"cek"` — render `nod.opsi` sebagai tombol outline (pola tombol soal), tiap tombol mengikuti `"ke"`-nya; tambah handler `_on_cek_ditekan(ke)` (catat jawaban pemain ke Riwayat + `_tampilkan_node(DataChatModul01.cari(ke))`). Tanpa arm ini node cek tidak menampilkan tombol apa pun. (2) `_lanjut_pesan`: pemicu materi `id == "n5"` → `id == "p_latihan"` (1 baris). Selebihnya TIDAK BERUBAH — mekanik lanjut manual, efek bicara, papan, resume, dan baca ulang sudah jadi. |
| `scripts/ui_misi/manajer_ui_misi.gd` | TIDAK BERUBAH (chip Auto sudah dihapus Sinta; orkestrasi pemandu → narasi → latihan sudah mengikuti `rb_fase`). |
| `scripts/ui_misi/reader_modul_ui.gd` | **BARU (opsional, bila belum ada)** — panel reader modul (pola v2 §3): hanya dibuka lewat "Baca Ulang Modul"; tanpa gate, tanpa poin. |
| `scripts/save_data.gd` | TIDAK BERUBAH — kunci v4 (`rb_fase`, `rb_node_terakhir`) sudah ada (Sinta, 22 Nov). |
| `scripts/main.gd` | TIDAK BERUBAH (papan tulis sudah diisi sinyal `papan_berubah`; tidak ada sinyal video yang perlu dicabut — panel video tidak pernah di-port). |
| `skrip/test_ruang_belajar_v4.gd` | **BARU**: 28 node tulang punggung; lanjut manual (tanpa ketuk, node TIDAK maju); cek "Belum" maks 1x (ulang kedua tidak ada opsi "Belum"); latihan/kuis tetap; resume `rb_chat_pos` + `rb_fase` + `rb_node_terakhir`; buka ulang tanpa poin; tanpa SCRIPT ERROR. |
| `v2/spike-pemutar-video/` | **ARSIP — JANGAN DIHAPUS.** Spike cara A TERBUKTI jalan; panel tidak jadi di-port. Simpan sebagai bukti bila video dibutuhkan lagi nanti (mis. trailer). |
| `scripts/ui_misi/pemutar_video_ui.gd` | **TIDAK DIBUAT** (v3 §8 dibatalkan). |

**Tidak disentuh:** `dialog_misi.gd`, `tes_kenaikan_ui.gd`,
`panel_misi_ui.gd`, `data_misi_bagian.gd`, `data_dialog_misi.gd`,
`avatar_misi.gd`, `gaya_misi.gd`, `ui.gd` reader rak kitab,
`data_modul_01.gd` (sumber soal — dipakai ulang apa adanya).

---

## 9. Yang TETAP (tidak berubah dari v1 / v2 / v3 / draf)

- **Tes kenaikan** — ambang 8/10, +20 poin, DI DALAM Kantor Putra
  (−18,22.5) / Kantor Ustadzah (148,−33); N2–N4 "belum tersedia".
- **Poin** — materi 10 / latihan 15 / kuis 10 / tugas 5; bank soal
  Modul 01–03 (N1/N2/N3 final setelah tashih); kuis modul = N.T.
- **Pola baku** — "Cari Ustadz → Belajar → Tugas dari Ustadz"
  (draf v5.4.1 §9 TERKUNCI); alur santri baru §1A langkah 5.
- **Adegan belajar** — ustadz duduk + meja + papan tulis, kamera
  dialog, avatar Sanusi (peci hitam nasional) / Fatimah (jilbab krem).
- **Syarat tampilan §2.9** — enak dibaca, tidak primitif, nuansa 3D
  style game; gradien zamrud + rim emas + Baloo 2 + Amiri (pola
  GayaMisi / Panel Misi v2). Mockup pemandu v3 tetap berlaku
  (panel chat tidak berubah); mockup video v3 PENSIUN.
- **§9 DRAF-ALUR-MISI v5.4.1 TERKUNCI SEMUA** — dokumen ini tidak
  mengubah satu butir pun.

---

## 10. Pertanyaan v3 yang TERJAWAB oleh keputusan Mas (22 Nov 16:03)

| Pertanyaan v3 (§9) | Jawaban v4 |
|---|---|
| 1. Gate tonton opsi A (≥80%)? | **DIHAPUS.** Tidak ada video, tidak ada gate. Poin materi 10 diberikan saat narasi selesai dibaca (sampai `p_latihan`). |
| 2. Video di dalam game atau tautan YouTube? | **DIBATALKAN.** Tidak ada video di Ruang Belajar. |
| 3. Reader tetap atau dihapus? | **TETAP sebagai opsi "Baca Ulang Modul"** (§6) — tanpa gate, tanpa poin. |
| 4. Papan tulis isi judul episode? | **DIGANTI:** isi = poin kunci node aktif (§7). |
| 5. Modul 02/03 ikut pola video / reader dulu / dikunci? | **Ikut pola v4 (teks)** — tidak menunggu video (§11). |

---

## 11. Modul 02/03 — TIDAK MENUNGGU APA PUN LAGI

Di v3, Modul 02/03 macet menunggu episode videonya. Di v4 tidak ada
video — jadi Modul 02/03 mengikuti pola yang sama begitu modulnya
tashih-lolos: **naskah narasi dialog dari modul (.md) → file data
dialog (`data_chat_modul_02_v4.gd`, dst.) → port ke
`data_chat_modul_02.gd`**. Struktur node sama (pemandu → narasi →
cek → latihan → kuis → penutup → tugas); panjang node sama
(60–120 kata); metode sama ("jelaskan, tanyakan"). Tidak ada
pekerjaan video yang mengantre di depan mereka.

---

## 12. Catatan jujur + risiko

1. **Narasi 1.201 kata ≈ 8–10 menit membaca.** Itu memang maksud
   Mas ("detail dan lengkap sebagaimana guru beneran") — tapi
   panjang ini HARUS diuji di HP Mas: apakah 14 gelembung panjang
   terasa seperti belajar, atau seperti membaca dinding teks.
   Bila terasa berat, obatnya BUKAN memotong isi (isi sudah
   tashih-lolos) melainkan memecah node lebih kecil (satu § jadi
   3 node, bukan 2) — keputusan Mas setelah mencoba.
2. **Node cek bergantung pada arm UI baru** (§8, 1 arm + 1 handler).
   Bila arm itu belum ada saat port, node cek macet (tidak ada
   tombol). Tes v4 (§8) WAJIB mencakup jalur "Belum" sebelum
   deploy.
3. **Pemicu materi `"n5"` → `"p_latihan"`** (§8, 1 baris). Bila
   lupa diganti, poin materi 10 jatuh di tengah narasi (saat
   meninggalkan node fi'il) — tes v4 harus memeriksa poin materi
   baru muncul setelah `p_latihan`.
4. **Tugas +5 saat diterima** (§4) — dicatat apa adanya, bukan
   diubah diam-diam. Bila Mas mau hadiahnya saat setoran hafalan,
   itu pekerjaan Fase C (mekanik setoran), bukan revisi konsep ini.
