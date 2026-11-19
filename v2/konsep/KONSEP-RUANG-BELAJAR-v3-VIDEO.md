# KONSEP — Ruang Belajar v3: "Tonton videonya, chat jadi pemandu"

**Keputusan Mas (20 Nov 2026, 01:16 WIB):** "Ruang belajar kan diganti
video.." — pelajaran di Ruang Belajar diganti **video episode Nahwu**
(1 episode = 1 misi/modul, Sanusi + Fatimah yang ngajari, suara
cowo/cewe). **Konsep v2 ("Baca di reader, chat jadi pemandu",
`KONSEP-RUANG-BELAJAR-v2-BACA-READER.md`) SUDAH TIDAK BERLAKU sebagai
alur utama.** Dokumen v2 disimpan sebagai arsip — pola chat pemandu
dan latihan/kuis-nya dipakai ulang di sini.

**Status:** KONSEP — menunggu ACC Mas. Kode game TIDAK diubah.
**Gambar:** `konsep-ruang-belajar-v3-pemandu.png` (chat pemandu),
`konsep-ruang-belajar-v3-video.png` (panel pemutar video — BARU),
`konsep-ruang-belajar-v3-kuis.png` (chat latihan/kuis + tugas).
**Sumber:** konsep v2 + mockup-nya, naskah episode 1
`video-nahwu-ep01-naskah.md` (6 adegan, ~90 dtk, duet Sanusi+Fatimah),
Modul 01 Tim Kurikulum (`ruang-belajar-nahwu-dasar-01-mengenal-kata.md`),
`DRAF-ALUR-MISI.md` v5.4.1 (§1A langkah 5, §2.1, §2.9).

**Catatan status naskah (Mas, 01:04):** naskah episode 1 **BELUM final** —
Mas mau menyesuaikannya dengan hasil transkrip video referensi episode
#1 (sedang dikerjakan Nara). Konsep v3 ini tidak mengubah naskah; yang
diatur di sini hanya *bagaimana video ditonton di dalam game*. Produksi
video (VO penuh + build Remotion, fase 2) tetap menunggu naskah final.

---

## 0. Masalah yang diperbaiki (kata Mas, 19 Nov 23:36)

Chat v1 (14 pesan dialog ala Genshin, live di build 20261119-4) dinilai
dangkal untuk belajar beneran: materi terpotong jadi gelembung, susah
diulang, strukturnya tidak kelihatan. Penilaian yang sama yang membuat
v2 memilih reader — tapi Mas memilih jalan yang satu lagi dari kalimat
beliau sendiri: "enak baca **atau liat video** aja". Video menjawab
ketiga kelemahan itu dengan cara yang berbeda dari reader:

1. **Materi tidak terpotong** — satu episode menjelaskan satu topik
   utuh (contoh episode 1: apa itu Nahwu → contoh u/a/i → kalam →
   tiga jenis kata → mabni/mu'rob → bait hafalan), dengan bagan yang
   *bergerak* (akhir kata berubah warna, kartu kata bergabung,
   kalimat dipilah per warna) — hal yang tidak bisa dilakukan teks
   diam.
2. **Gampang diulang** — santri tinggal putar ulang episodenya, atau
   lompat ke adegan yang diinginkan (§3.2).
3. **Strukturnya kelihatan** — daftar adegan episode tampil di panel
   (§3.1), santri tahu sudah sampai mana.

**Prinsip v3:** video adalah pelajarannya (ustadz yang mengajar,
di layar); chat hanya memandu (menyapa, mengarahkan, menguji,
memberi tugas). Reader tidak dibuang — ia turun pangkat jadi
**pendamping opsional** untuk mengulang lewat teks (§4). Bukan "chat
diganti video", melainkan "ustadz mengajar lewat video, lalu menguji".

---

## 1. Alur baru end-to-end (Modul 01 / Episode 1 sebagai contoh)

Pola baku "Cari Ustadz → Belajar → Tugas dari Ustadz" (draf v5.4.1 §2.1)
**TETAP** — yang berubah hanya isi langkah "Belajar" (dulu chat v1,
lalu reader v2, kini video v3).

```
1. Cari Ustadz (TETAP)
   Santri menemukan Ust. Sanusi (lokasi random, tanpa marker) /
   Ustzh. Fatimah (putri). Ketuk → adegan belajar terbuka:
   ustadz DUDUK di atas tikar + meja + papan tulis kecil di sampingnya,
   kamera membingkai beliau (seperti v1 §8 — TIDAK berubah).

2. Chat pemandu — SINGKAT (sama seperti v2, ganti kata "baca" → "tonton")
   P1  "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar —
        Modul 01: Mengenal Kata."
   P2  "Episodenya 90 detik — saya dan Ustazah Fatimah yang mengajar.
        Tonton dulu sampai selesai, santai saja. Kalau sudah,
        kembali ke saya."
   P3  [tombol emas] "Tonton Episode ›"  → membuka panel video (§3).
       [tombol outline] "Nanti dulu" → tutup, bisa kembali kapan saja.
   Efek bicara TETAP (huruf satu-satu ±40 ms, tap = tampil penuh).
   TIDAK ADA cabang "Belum, jelaskan lagi" — penjelasan ada di video,
   bukan di chat. TIDAK ADA status mengetik (sudah dihapus §8 v1).

3. Tonton video episode (BARU — §3)
   Panel pemutar video terbuka (layar penuh). Episode 1 diputar:
   judul, 6 adegan, kontrol putar/jeda + progress + waktu.
   Santri menonton; progres tonton kumulatif dicatat (kunci save
   `rb_tonton_detik`, §5). Tombol "Lanjut ke Latihan ›" di panel
   AKTIF setelah ≥80% episode ditonton (opsi A, §5) — sebelum itu
   redup dengan keterangan "Tonton dulu (X%)".
   Poin materi 10 diberikan saat gate 80% tercapai.

4. Kembali ke chat — latihan + kuis (TETAP di chat, sama seperti v2)
   Tap "Lanjut ke Latihan" → panel video tertutup → chat pemandu
   muncul lagi:
   P4  "Sudah ditonton? Bagus. Sekarang kita latihan — 5 soal."
   L1–L5  Soal latihan (5 soal, format v1: ustadz bertanya, 4 opsi;
           salah → ustadz menjelaskan dari "petunjuk" + soal diulang,
           opsi salah dimatikan). → +15 poin latihan.
   K1  Kuis (1 soal dari bank N1.T). → +10 poin kuis.
   P5  Penutup: "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin."
       + kartu "Selesai — 35 poin".

5. Tugas dari Ustadz (TETAP)
   P6  "Tugasmu: hafalkan baitnya, lalu baca 1 bab di rak kitab."
       → +5 poin saat selesai (sesuai tashih Modul 01).
       → maju langkah 5→6 (tes kenaikan), toast seperti sekarang.
```

**Total pesan chat v3: 6** (P1–P3 pemandu, P4–P6 sesudah tonton) — sama
seperti v2. Yang hilang dari chat: 7 pesan materi + 2 cabang "Belum".
Yang pindah ke video: seluruh isi materi (§1–§7 Modul 01, bait,
rangkuman — dalam bentuk adegan 1–6 naskah episode 1).

**Buka ulang setelah selesai → mode tonton ulang:** episode bisa
diputar kapan saja dari Ruang Belajar (tombol "Tonton Lagi"), chat
pemandu hanya menampilkan P1 singkat + tombol "Tonton Episode" —
TANPA poin lagi (guard `rb_selesai` yang sudah ada). Tutup di tengah
nonton → lanjut dari posisi terakhir (resume `rb_fase` +
`rb_tonton_detik`, §5).

---

## 2. Nasib chat v1 dan konsep v2 — apa yang dipensiunkan, apa yang tetap

| Elemen | Nasib di v3 | Alasan |
|---|---|---|
| 14 pesan dialog materi (v1) | **DIPENSIUNKAN** (tetap seperti v2) | Materi pindah ke video. Data `NOD` di `data_chat_modul_01.gd` diganti 6 node pemandu (§1). |
| Cabang "Belum" maks 2× (v1) | **DIPENSIUNKAN** (tetap seperti v2) | Penjelasan ulang ada di video (putar ulang adegan). |
| Reader modul sebagai langkah wajib (v2) | **TURUN JADI OPSIONAL** (§4) | Pelajaran utama kini video; reader hanya pendamping teks. Panel reader v2 tetap dibangun, tapi hanya dibuka lewat tombol "Baca Ulang Modul" — bukan langkah wajib. |
| Gate baca 7/7 + `rb_baca_bagian` (v2) | **DIGANTI gate tonton (§5)** | Yang diukur kini "sudah menonton", bukan "sudah membuka bagian". |
| Efek bicara (±40 ms/huruf) | **TETAP** | Pesan pemandu tetap ucapan ustadz. Tap = tampil penuh. |
| Papan tulis kecil | **TETAP, isi berubah** | Adegan duduk + papan (§8 v1) tetap — papan kini menampilkan **judul episode + adegan yang sedang diputar** ("EPISODE 1 — Adegan 5: Tiga Jenis Kata"), bukan ringkasan materi. Papan = penanda posisi, bukan pengganti video. |
| Ustadz duduk + meja | **TETAP** | Adegan belajar di dunia tidak berubah (meja Sinta, lantai Surau y=0,5). |
| Latihan 5 soal + kuis 1 soal di chat | **TETAP** | Format tanya-jawab memang cocok dengan dialog — soal + opsi + penjelasan saat salah. Isi soal TIDAK berubah. |
| Tombol Auto + Riwayat | **TETAP** | Auto = alur pemandu otomatis; Riwayat = log 6 pesan pemandu. |
| Bilah progres emas | **TETAP, makna berubah** | Kini progres FASE (pemandu → tonton → latihan → selesai). |
| Poin 35 (10+15+10) + tugas 5 | **TETAP** | Poin materi 10 diberikan saat gate tonton 80% (§5); latihan 15 + kuis 10 seperti v1; tugas 5 seperti tashih Modul 01. |
| Resume `rb_chat_pos` | **DIGANTI** | Node chat lama tidak ada lagi. Diganti `rb_fase` + `rb_tonton_detik` (§5). `rb_chat_modul` TETAP (modul yang sedang berjalan). |

---

## 3. Panel pemutar video — bagaimana episode tampil di game

### 3.1 Anatomi layar (mockup `konsep-ruang-belajar-v3-video.png`)

Video episode 1 dibuat **vertikal 1080×1920** (sesuai naskah — format
video pendek, sama seperti trial motion). Panel di game (HP Mas,
landscape maupun portrait) menampilkannya sebagai berikut:

- **Area video (kiri di landscape, atas di portrait):** bingkai
  vertikal 9:16 berisi video yang sedang diputar. Di dalamnya:
  judul adegan kecil di atas ("Adegan 5 — Tiga Jenis Kata"), dan
  kontrol di bawah video: tombol putar/jeda besar (ramah jempol),
  bilah progres emas (posisi saat ini), waktu "0:56 / 1:30".
  Ketuk area video = jeda/lanjut. Tombol layar penuh di pojok
  (memutar video memenuhi layar HP, tetap vertikal).
- **Panel info (kanan di landscape, bawah di portrait):**
  - Header: "EPISODE 1" kecil emas + judul "Mengenal Ilmu Nahwu"
    (30, hijau) + "Diajari Ust. Sanusi & Ustzh. Fatimah" dengan dua
    avatar lingkaran (S / F).
  - "Yang dibahas di episode ini" — daftar 6 adegan (1 Pembuka ·
    2 Apa itu Nahwu · 3 Contoh u/a/i · 4 Kalam · 5 Tiga Jenis Kata ·
    6 Mabni vs mu'rob + penutup). Adegan yang sudah ditonton =
    centang emas; adegan aktif = isi emas. Tap adegan = lompat ke
    waktu adegan itu (seek — diizinkan, tapi tidak menambah hitungan
    gate, §5).
  - **Kotak gate:** "Sudah ditonton 82%" + bilah progres emas tipis.
  - Tombol emas "Lanjut ke Latihan ›" (aktif hanya bila ≥80% — §5)
    atau, bila belum, teks redup "Tonton dulu (42%) — latihan
    terbuka setelah 80%".
  - Tombol outline "Baca Ulang Modul" (membuka reader teks, §4) +
    "× Tutup" kanan atas.
- **Perilaku putar:** video dijeda otomatis saat panel ditutup atau
  saat santri pindah ke chat latihan; posisi terakhir disimpan
  (`rb_tonton_detik`) sehingga "Tonton Lagi" lanjut dari posisi itu.
  Suara video = suara Sanusi/Fatimah (VO episode); tidak ada suara
  lain yang bertabrakan (adzan / suara game dijeda selama video
  diputar — diputuskan saat bangun).

### 3.2 Adegan → § modul (episode 1)

| Adegan (naskah) | Waktu | § Modul 01 yang dibahas |
|---|---|---|
| 1 Pembuka | 0–12 dtk | Pengantar modul |
| 2 Apa itu Nahwu | 12–30 dtk | Pengantar + singgung Sharaf (Modul 05) |
| 3 Contoh u / a / i | 30–38 dtk | Perubahan akhir kata (i'rob) |
| 4 Kalam | 38–49 dtk | §1 Kalam |
| 5 Tiga jenis kata | 49–70 dtk | §2 Isim · §3 Fi'il · §4 Huruf |
| 6 Mabni vs mu'rob + penutup | 70–90 dtk | §6 Mabni · §7 Akhir kata · Bait hafalan |

Daftar adegan ini BUKAN daftar isi reader — ia adalah penanda posisi
di dalam video. Tap adegan = lompat (seek) ke waktunya.

### 3.3 Episode 02 & 03 — pola sama, video belum ada

Satu episode = satu misi/modul: Episode 2 = Modul 02, Episode 3 =
Modul 03, dan seterusnya mengikuti playlist (28 episode). **Catatan:**
saat v3 dibangun, yang ada hanya Episode 1 (Modul 01) — itu pun
menunggu naskah final. Episode 02/03 dibuat satu per satu sesudahnya
(produksi 1 video butuh berhari-hari). Sampai episode-nya ada, Modul
02/03 **belum bisa dipelajari lewat video** — lihat keputusan 5 (§8):
apakah Modul 02/03 pakai reader dulu sementara, atau dikunci sampai
videonya jadi.

---

## 4. Reader jadi pendamping OPSIONAL (bukan langkah wajib)

Reader modul dari konsep v2 (panel baca krem, daftar isi chip,
kartu contoh Arab, kotak Rumus — mockup v2 `konsep-ruang-belajar-v2-reader.png`)
**tetap dibangun, tapi bukan langkah wajib.** Fungsinya:

- Tombol **"Baca Ulang Modul"** di panel video (§3.1) dan di Ruang
  Belajar setelah selesai — untuk santri yang mau mengulang materi
  lewat teks (mis. menghafal bait, mengecek rumus, membaca contoh
  tanpa memutar video).
- Isi reader = Modul 01 lengkap (§1–§7 + bait + rangkuman), pola
  v2 §3 — tidak ada gate baca, tidak ada poin dari membaca (poin
  materi 10 sudah diberikan lewat gate tonton, §5).
- Keputusan 3 (§8) menunggu Mas: reader tetap sebagai opsi ini,
  atau dihapus total (video saja, tanpa teks sama sekali).

---

## 5. Penanda selesai tonton + anti-farming

### Opsi yang dipertimbangkan

| Opsi | Cara kerja | Kelebihan | Kelemahan |
|---|---|---|---|
| **A. ≥80% waktu tonton KUMULATIF (REKOMENDASI)** | Setiap detik video yang *benar-benar diputar* dijumlahkan (dari event `timeupdate` pemutar, per ~0,25 detik). Seek maju TIDAK menambah hitungan; seek mundur tidak mengurangi. Tombol "Lanjut ke Latihan" aktif saat total ≥80% durasi episode (≈72 detik untuk episode 90 detik). Poin materi 10 diberikan saat itu. Disimpan di `rb_tonton_detik` (per modul). | Tidak bisa diakali dengan sekali klik atau sekali lompat ke akhir — harus benar-benar memutar ~72 detik; santri bebas jeda, putar ulang, lompat ke adegan; tidak memaksa tonton 100% (toleransi untuk yang sudah paham / gangguan). | Santri bisa memutar sambil tidak melihat — tapi itu sama dengan membuka buku tanpa membaca; latihan + kuis tetap menguji paham. |
| B. Video harus selesai (event `ended`) | Tombol aktif hanya setelah video diputar sampai akhir. | Paling ketat — membuktikan tonton penuh. | Menghukum santri yang sudah paham lalu menutup di 85%; bila video terputus di detik akhir (jaringan), gate tidak tercapai — frustrasi. |
| C. Tanpa gate (tombol "Sudah Nonton") | "Lanjut ke Latihan" langsung aktif; poin materi 10 saat latihan dimulai. | Paling sederhana, nol friksi. | Satu klik tanpa nonton = poin materi; tujuan "tonton" gagal. |
| D. Tonton penuh tanpa boleh seek | Seek dimatikan; harus menonton berurutan sampai akhir. | Tidak bisa lompat ke akhir. | Pengalaman buruk di HP (tidak bisa mengulang adegan yang terlewat); bertentangan dengan "santai saja". |

### Rekomendasi Sinta: Opsi A

Gate-nya ringan dan jujur: yang diukur adalah "sudah memutar 80%
episode", bukan "sudah menonton tiap detik" — karena yang benar-benar
menguji paham adalah latihan + kuis (15+10 poin), bukan gate tonton.
Poin materi 10 adalah hadiah menyelesaikan tontonan, bukan hadiah
menghafal. Kunci save baru:

- `rb_tonton_detik` — detik kumulatif yang benar-benar diputar, per
  modul (angka, bukan bitmask). WAJIB tambah di `save_data.gd
  default_data()` (pelajaran lama: kunci baru yang tidak ada di sana
  tidak tersalin saat load).
- `rb_fase` — "pemandu" | "tonton" | "latihan" | "selesai" (ganti
  `rb_chat_pos`; `rb_chat_modul` tetap).
- `rb_selesai` — TETAP (anti-farming per langkah: materi/latihan/
  kuis/tugas; `langkah_selesai` + `selesai` tidak berubah).
- `rb_baca_bagian` (v2) — hanya dipakai bila keputusan 3 (§8)
  mempertahankan reader; itupun tanpa gate (baca ulang bebas).

---

## 6. Pertanyaan teknis — video diputar DI DALAM game atau tautan keluar?

### Rekomendasi Sinta: DI DALAM game (panel pemutar)

Santri menonton tanpa keluar aplikasi — ketuk "Tonton Episode",
video diputar di panel (§3.1), kembali ke chat sesudahnya. Ini yang
paling mulus buat HP Mas: tidak ada pindah aplikasi, tidak ada iklan
YouTube, progres tonton tercatat untuk gate (§5), dan suasananya
tetap "di dalam pesantren".

### Tiga cara teknis (asumsi + yang perlu diuji — JANGAN dianggap pasti)

| Cara | Cara kerja | Kelebihan | Kelemahan / yang perlu diuji |
|---|---|---|---|
| **A. Elemen video HTML di atas canvas (REKOMENDASI)** | Export web Godot 4.7 memakai `<video>` HTML (MP4/H.264) yang diposisikan di atas canvas lewat JavaScriptBridge — panel Godot mengatur tampil/sembunyi + menerima `timeupdate` untuk gate. | Dekode video oleh browser (hardware, mulus di HP); format MP4 standar (hasil render Remotion langsung dipakai); kontrol + progress akurat. | **BELUM TERBUKTI** di export ini — butuh spike: elemen video di atas canvas Godot web, bridge `timeupdate` → Godot, jeda saat panel ditutup, perilaku layar penuh, kebijakan autoplay browser (butuh gestur tap — ketuk "Tonton Episode" sudah cukup sebagai gestur, perlu dibuktikan). |
| B. VideoStreamPlayer Godot (Theora .ogv) | Video di-encode ke .ogv, diputar sebagai texture di dalam scene Godot (murni Godot, tanpa bridge). | Tanpa bridge; video jadi bagian scene. | Butuh re-encode ke Theora (kualitas/ukuran lebih boros dari H.264); **belum dibuktikan** mulus di export web + HP Mas; file video masuk pck (membesarkan export — lihat §6.1). |
| C. Tautan keluar ke YouTube | Tombol membuka video YouTube di browser/ aplikasi YouTube. | Nol pekerjaan teknis. | Santri keluar dari game; progres tonton TIDAK tercatat (gate §5 tidak bisa jalan — harus pakai tombol "Sudah Nonton" yang mudah diakali, opsi C §5); ada iklan + rekomendasi video lain; suasana pesantren putus. **Ditolak sebagai jalur utama** — paling banter jadi tautan cadangan "Tonton di YouTube" bila panel gagal. |

### 6.1 Ukuran + hosting video (risiko nyata)

- Satu episode ±90 detik, 1080×1920, MP4 H.264 — perkiraan
  **8–15 MB** (tergantung bitrate render). 28 episode ≈ 250–400 MB
  bila semuanya jadi.
- **JANGAN dibundel ke dalam pck game.** Pck sekarang ±9 MB dan
  deploy chunked mentok ±48 MB — 28 video tidak akan muat, dan
  tiap deploy ikut mengunggah ulang semua video. Video harus
  di-host terpisah dari bundle game (file statis di proyek Pages
  yang sama ATAU layanan video) dan di-stream lewat URL.
- Yang diputuskan saat bangun (bukan di konsep ini): lokasi hosting
  + apakah video di-cache di HP santri. Keputusan hosting masuk
  spike yang sama dengan cara A.

### 6.2 Yang harus diuji SEBELUM bangun (spike, bukan janji)

1. Elemen `<video>` MP4 di atas canvas export web — tampil, suara
   keluar, `timeupdate` sampai ke Godot.
2. Panel video di HP Mas (Galaxy A35): putar/jeda responsif,
   layar penuh vertikal, kembali ke game tanpa reload.
3. Jeda otomatis + simpan posisi saat panel ditutup / aplikasi
   diminimalkan.
4. Ukuran file episode 1 hasil render + waktu muat streaming.

Bila spike A gagal, jatuh ke cara B (Theora) — dan bila itu pun
gagal, baru bicara soal tautan YouTube (cara C) dengan Mas.

---

## 7. Yang TETAP (tidak berubah dari v1 / v2 / draf)

- **Tes kenaikan** — ambang 8/10, +20 poin, venue Kantor Putra
  (−18,18.5) / Kantor Ustadzah (148,−33); N2–N4 "belum tersedia".
  (Tes kini DI DALAM kantor — konsep tes sudah ACC Mas 00:37.)
- **Poin** — materi 10 / latihan 15 / kuis 10 / tugas 5; bank soal
  Modul 01–03 (N1/N2/N3 final setelah tashih); kuis modul = N.T.
- **Pola baku** — "Cari Ustadz → Belajar → Tugas dari Ustadz"
  (draf v5.4.1 §9 TERKUNCI); alur santri baru §1A langkah 5.
- **Adegan belajar** — ustadz duduk + meja + papan tulis, kamera
  dialog, avatar Sanusi (peci hitam nasional) / Fatimah (jilbab krem).
- **Syarat tampilan §2.9** — enak dibaca, tidak primitif, nuansa 3D
  style game; gradien zamrud + rim emas + Baloo 2 + Amiri (pola
  GayaMisi / Panel Misi v2).

---

## 8. Yang BERUBAH saat implementasi nanti (daftar file — JANGAN diubah sekarang)

| File | Perubahan (nanti, setelah ACC konsep + spike §6.2 lolos) |
|---|---|
| `scripts/ui_misi/data_chat_modul_01.gd` | 14 node → 6 node pemandu (P1–P6, §1); tombol "Tonton Episode ›" (bukan "Buka Modul"); cabang "Belum" + papan-per-node dihapus; papan kini diisi judul episode + adegan aktif. |
| `scripts/ui_misi/data_modul_01.gd` | Tambah pemetaan video episode: `{file/url video, durasi, adegan[]: {judul, mulai_dtk}}` — dipakai panel pemutar + papan tulis. |
| `scripts/ui_misi/data_modul_02.gd` + `data_modul_03.gd` | BARU — port Modul 02/03 (.md → data) + pemetaan video begitu episode-nya ada. Ini pekerjaan A2. |
| `scripts/ui_misi/ruang_belajar_ui.gd` | Chat dipersingkat (6 node) + memanggil panel video saat "Tonton Episode" + menerima kembali saat gate 80% / "Lanjut ke Latihan". Class + sinyal + `tampilkan(pengajar)` TETAP supaya manajer/main tidak berubah. Simpan v1 sebagai `.bak` sampai tes hijau. |
| `scripts/ui_misi/pemutar_video_ui.gd` | **BARU** — panel pemutar video (§3): area video + kontrol putar/jeda + progress + waktu + daftar adegan + gate 80% + sinyal selesai-tonton. Bridge ke elemen `<video>` HTML (cara A §6) atau VideoStreamPlayer (cara B) — diputuskan dari hasil spike. |
| `scripts/ui_misi/reader_modul_ui.gd` | **BARU (opsional, keputusan 3)** — panel reader modul (pola v2 §3): hanya dibuka lewat "Baca Ulang Modul"; tanpa gate, tanpa poin. Bila Mas memilih hapus reader, file ini TIDAK dibuat. |
| `scripts/ui_misi/manajer_ui_misi.gd` | Orkestrasi fase pemandu → tonton → latihan (panggil panel video, terima sinyal selesai-tonton). |
| `scripts/save_data.gd` | Kunci baru `rb_tonton_detik` + `rb_fase` di `default_data()` (+ `rb_baca_bagian` hanya bila reader dipertahankan). |
| `scripts/main.gd` | Adegan belajar: isi papan tulis = judul episode + adegan aktif (diperbarui saat adegan berganti); sinyal selesai-tonton → lanjut chat latihan; jeda suara game/adzan selama video diputar. Perubahan kecil, di satu tempat. |
| `skrip/test_ruang_belajar_v3.gd` | **BARU**: 6 node pemandu, panel video tampil + gate 80% (putar <80% tombol tetap redup; seek ke akhir tidak membuka gate; putar ulang kumulatif membuka gate), latihan/kuis tetap, resume `rb_fase` + posisi tonton, tonton ulang tanpa poin, tanpa SCRIPT ERROR. |
| `v2/export/` (spike, bukan game) | Prototipe panel video HTML (cara A) + uji di HP Mas sebelum bangun — hasil spike menentukan cara A/B (§6.2). |

**Tidak disentuh:** `dialog_misi.gd` (percakapan aturan pesantren),
`tes_kenaikan_ui.gd`, `panel_misi_ui.gd`, `data_misi_bagian.gd`,
`data_dialog_misi.gd`, `avatar_misi.gd`, `gaya_misi.gd` (helper
dipakai ulang, bukan diubah), `ui.gd` reader rak kitab (tetap untuk
kitab umum).

---

## 9. Pertanyaan untuk Mas (jawab saat ACC)

1. **Gate tonton opsi A (≥80% waktu tonton kumulatif, seek maju
   tidak dihitung) — setuju?** Atau video harus selesai (opsi B),
   atau tanpa gate (opsi C)?
2. **Video diputar DI DALAM game (panel pemutar, MP4 via elemen
   video HTML) — setuju?** Atau cukup tautan keluar ke YouTube?
   (Usulan: di dalam game — paling mulus, gate bisa jalan.)
3. **Reader tetap sebagai opsi "Baca Ulang Modul", atau dihapus
   total?** (Usulan: tetap sebagai opsi — buat yang mau mengulang
   lewat teks; tidak wajib, tanpa poin.)
4. **Papan tulis isi judul episode + adegan aktif — setuju?** Atau
   papan dihapus saja karena materi sudah di video?
5. **Modul 02/03 ikut pola video saat episode-nya jadi — dan
   sementara itu pakai reader dulu atau dikunci?** (Usulan: ikut
   pola video; sementara episode-nya belum ada, Modul 02/03 pakai
   reader dulu supaya santri tidak macet — video menggantikan
   begitu episode-nya ACC.)

---

## 10. Rekomendasi Sinta

**Bangun v3 dengan pola di atas, Modul 01 dulu — tapi spike
pemutar dulu sebelum bangun.** Urutannya: (1) Mas ACC konsep v3 ini;
(2) naskah episode 1 difinalkan (menunggu transkrip referensi);
(3) spike panel video di HP Mas (§6.2) — bila cara A terbukti jalan,
(4) VO penuh + build video episode 1, lalu (5) bangun panel +
pemandu + gate di game. Sekitar 70% sistem sudah ada (GayaMisi,
MesinKuis, DataModul01, banking poin di main), jadi yang baru hanya
panel pemutar + data video + 6 node pemandu + 2 kunci save (+ reader
opsional).

Risiko utama: **produksi video itu beban besar** — 1 episode butuh
berhari-hari (naskah → VO → motion → render → verdict Mas), dan
28 episode adalah antrean panjang. Pilot episode 1 dulu, dinilai
Mas, baru lanjut satu-satu. Risiko kedua: **cara putar video di
dalam game belum terbukti** — jangan bangun panel sebelum spike
lolos. Risiko ketiga: **Modul 02/03 menunggu episode-nya** — v3
untuk Modul 01 bisa jalan, tapi Bagian 2–3 menunggu produksi video
(atau reader sementara, keputusan 5).
