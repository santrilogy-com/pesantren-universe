# FITUR ADZAN — Status (Sinta, 17 Nov 2026)

Perintah Mas 17 Nov ~20:52 WIB (DI-ACC): adzan bunyi saat jam
sholat, bersamaan dengan banner sholat. Dikerjakan Sinta (tim Raka).
**TANPA deploy.**

## Ringkasan jujur

- **Kode SELESAI dan TERUJI (28/28 dengan file, 10/10 tanpa file).**
  Hook pemicu + pemutaran + mute + anti-ganda sudah jalan.
- **Rekaman adzan SUDAH ADA di game (Cakra, 18 Nov 2026, §7).**
  Mas memilih "Beautiful adhan" (13:23 WIB); file
  `audio/adzan.ogg` sudah diletakkan, lisensi CC0 terverifikasi,
  tes headless dengan file asli 29/29 LULUS. **Belum deploy.**
  Kualitas suara + apakah ini versi Subuh atau biasa hanya bisa
  dinilai telinga Mas di HP.

## 1. Pencarian + verifikasi rekaman (17 Nov 2026, Sinta)

### Yang terverifikasi ADA (tapi tidak cukup untuk memakai)

Halaman pencarian Freesound dengan filter lisensi
"Creative Commons 0" untuk kata kunci `adhan` — dibaca langsung
17 Nov ~20:57 WIB (https://freesound.org/search/?q=adhan&f=license%3A%22Creative+Commons+0%22)
— menampilkan ±14 rekaman adzan berlisensi CC0, antara lain:

| Deskripsi (dari halaman hasil) | Catatan |
|---|---|
| Adzan subuh, kawasan perumahan Balakong, Kuala Lumpur ("Loud exterior aircon unit") | 22 Jul 2026 — ada suara AC luar |
| Adzan di luar Masjid Jumeirah, Dubai, Jan 2012 | 29 Jan 2012 — kandidat paling bersih dari deskripsi |
| Adzan diperagakan sendiri oleh perekam di Kakusenkei, Jepang (+ suara hutan/sungai/burung) | 11 Mar 2020 — karya sendiri, CC0 |
| Koleksi rekaman lapangan adzan di Fes, Maroko | 9 Sep 2026 — suara jauh, beberapa masjid |
| Marrakesh 5.1 surround, muadzin se-kota | 29 Mei 2020 — suasana kota, bukan satu suara |
| Al-Azhar Park, Kairo (+ air mengalir) | 8 Apr 2023 — adzan kemungkinan jauh |
| Quseir, Nov 2018; Port Fouad, Nov 2022; Jemaa El-Fna (Maghrib), 2021; Ramallah, Agu 2025; Alanya, Mar 2023 | Rekaman lapangan, kejelasan suara tak pasti |

### Kenapa tidak ada yang dipakai

1. Halaman hasil pencarian itu TIDAK menampilkan judul, nama
   perekam, durasi, ID, atau tautan tiap rekaman (ekstraksi halaman
   hanya berisi potongan deskripsi) — jadi tidak ada satu file pun
   yang bisa diidentifikasi untuk diverifikasi.
2. Upaya membuka halaman tiap suara di Freesound
   (`freesound.org/sounds/802681/` — "Adhan (call to prayer).
   Aroumd, Morocco", iainmccurdy, 2:13 — kandidat terkuat dari
   daftar umum) dan halaman file Wikimedia Commons
   ("Adhan in Shalqar mosque.webm") GAGAL dengan HTTP 403 dari
   fetcher VM ini. Mesin pencari juga tidak menampilkan lisensi
   tiap suara adzan di cuplikannya.
3. Aturan keras tugas ini: lisensi harus TERVERIFIKASI dari
   sumbernya per-file. "Kemungkinan CC0" bukan verifikasi.

### Yang DITOLAK (dicatat supaya tidak diulang orang lain)

- Cambridge "Voices and Faces of the Adhan: Cairo" (6 muadzin,
  mis. Sheikh Ahmed, Masjid Omar Makram) — lisensi
  **CC BY-NC-ND 3.0** (tertera di halaman item
  repository.cam.ac.uk): non-komersial + tanpa turunan — bahkan
  konversi format pun dilarang. TIDAK cocok.
- archive.org "ADZAN around the world" (JpnMuslim, 167 file OGG)
  dan "Kumpulan Adzan" (Keluarga ilma95, 34 file) — koleksi
  Community Audio TANPA pernyataan lisensi. TIDAK cocok.
- Satu hasil Freesound CC0 yang deskripsinya berbunyi "Extracted
  from https://www.youtube.com/watch?v=4dpqrKYI-n4 and processed"
  — rip YouTube, DITOLAK meski berlabel CC0.
- YouTube, TTS, suara sintetis, rekaman buatan — dilarang.

### Langkah lanjut untuk mendapatkan file (untuk Raka / Xam)

- **Paling cepat:** buka dari browser biasa (bukan fetcher VM)
  halaman pencarian Freesound di atas, buka satu suara (mis.
  Jumeirah Dubai atau Kakusenkei), baca lisensi di halaman
  suaranya ("Creative Commons 0"), unduh, konversi ke
  mono 22050 Hz Ogg (lihat §5), letakkan sebagai
  `audio/adzan.ogg`, catat URL + lisensi di doc ini.
- **Paling aman jangka panjang:** rekam sendiri (muadzin
  Sidogiri) — sama seperti rekomendasi untuk wirid & nadzom di
  `audio/README.md`.

## 2. Yang diubah

| File | Perubahan |
|---|---|
| `scripts/audio_pesantren.gd` | Tambah `PATH_ADZAN` (`res://audio/adzan.ogg`), player `_adz`, `mainkan_adzan()` + `adzan_tersedia()` / `adzan_dimainkan()` / `adzan_jumlah_main()`, penunda sampai gestur pertama (autoplay web), ambience di-duck (-30 dB) selagi adzan bunyi. TIDAK ada perubahan perilaku ambience/kegiatan lama. |
| `scripts/main.gd` | HANYA 1 hook di `_mulai_sholat`, tepat setelah `show_sholat_banner`: `_audio.mainkan_adzan()`. Tidak ada baris lain yang disentuh. |
| `audio/README.md` | Tambah bagian "Adzan saat jam sholat" (status + cara mengisi + daftar tolak). |
| `audio/adzan.ogg` | **ADA** — "Beautiful adhan" (Cakra, 18 Nov 2026, §7). |
| `audio/adzan.ogg.import` | Dibuat otomatis saat import headless (18 Nov 2026). |
| `test_adzan.gd/.tscn`, `foto_adzan.gd/.tscn`, `foto_adzan_ringan.gd/.tscn`, `probe_pause.gd/.tscn` | Arsip di `~/workspace/pesantren-verse/fitur-baru/skrip/`; copy di root proyek SUDAH DIHAPUS setelah tes (lihat §4). |

File lain (ui.gd, langit_dinamis.gd, dsb.) TIDAK disentuh.

## 3. Cara kerja

- `_cek_waktu_sholat` (main.gd) mendeteksi jendela sholat
  (Subuh 04:30, Dzuhur 12:00, Ashar 15:00, Maghrib 18:00,
  Isya 19:00, durasi 1 menit — `MissionData.WAKTU_SHOLAT`) →
  `_mulai_sholat` → banner + toast → `_audio.mainkan_adzan()`.
- Anti-ganda dua lapis: (1) kunci `_sholat_sudah`
  (nama_jam_tanggal) di `_cek_waktu_sholat` — sesi tidak mulai
  ulang di jendela yang sama; (2) `mainkan_adzan()` menolak
  mulai ulang selagi `_adz.playing`.
- Mute: bila bus Master dimatikan (`set_mute(true)`, tombol
  Suara/Senyap di HUD, tersimpan di save `suara_mati`),
  `mainkan_adzan()` langsung kembali tanpa memutar.
- File belum ada: `mainkan_adzan()` mencetak peringatan
  `[ADZAN] file adzan.ogg belum ada` dan kembali — banner + sesi
  tetap jalan normal, game tidak error (pola sama seperti slot
  wirid/quran/nadzom Ronde 17).
- Autoplay web: bila banner muncul sebelum gestur pertama,
  adzan ditunda (`_adzan_tertunda`) dan diputar oleh `mulai()`.
- Adzan TIDAK di-loop (sekali putar sampai habis). Adzan boleh
  berbunyi lebih lama dari sesi 1 menit (wajar — seperti adzan
  asli yang berlanjut saat jamaah berkumpul).
- Ambience di-duck ke -30 dB selama adzan bunyi, kembali ke
  -16 dB setelahnya (di `_process`, pola sama seperti duck saat
  kegiatan).

## 4. Hasil uji

### Tes headless — `test_adzan.gd` (arsip di `fitur-baru/skrip/`)

Dijalankan: `godot --headless --path . test_adzan.tscn`
(dua mode: dengan file nada tes sementara 30 dtk, dan tanpa file).

**Mode A — dengan file (nada tes SEMENTARA, lihat catatan): 28/28 LULUS**

| # | Cek | Hasil |
|---|---|---|
| 1 | Luar jendela (10:00): tidak ada sesi/adzan | PASS |
| 2–5 | Sesi + banner + adzan bunyi (counter 1→4) Subuh 04:30, Dzuhur 12:00, Ashar 15:00, Maghrib 18:00 | PASS (playing=true tiap kali) |
| 6–9 | Panggil `mainkan_adzan()` ulang selagi bunyi: counter tetap | PASS |
| 10–13 | Sesi mulai ulang di jendela sama: ditolak kunci `_sholat_sudah`, counter tetap | PASS |
| 14–15 | Ambience duck -30 dB selagi adzan bunyi, kembali -16 dB setelah berhenti | PASS |
| 16–18 | MUTE Isya 19:00: sesi + banner jalan, adzan DIAM (counter tetap, playing=false) | PASS |
| 19 | Unmute lalu panggil langsung: bunyi lagi (counter +1) | PASS |
| 20–21 | Tertunda sebelum gestur: belum bunyi (counter 0), bunyi di `mulai()` (counter 1) | PASS |

**Mode B — tanpa file (kondisi yang DIKIRIM): 10/10 LULUS.**
Banner + sesi jalan di Subuh & Dzuhur, adzan diam, tidak ada
error/crash; panggil langsung tanpa file = no-op; tertunda tanpa
file = tetap diam.

**Catatan nada tes:** Mode A memakai file nada sinus 440 Hz
30 dtk mono 22050 Hz (`/tmp/adzan_tes_nada.ogg`, 35 KB) yang
disalin SEMENTARA sebagai `audio/adzan.ogg` hanya selama tes —
BUKAN rekaman adzan, BUKAN untuk dikirim. File itu + file
`.import`-nya SUDAH DIHAPUS setelah tes (folder `audio/`
kembali berisi hanya burung/angin/jangkrik + README). Nada tes
hanya membuktikan jalur putar (player mulai, mute, anti-ganda,
duck) — BUKAN isi suara. Kualitas suara adzan asli hanya bisa
dinilai telinga Mas di HP setelah file asli dipasang.

### Foto (xvfb, TANPA --headless)

Audio TIDAK terlihat di foto — bukti bunyi ada di tes headless
di atas (counter + `playing=true`).

**STATUS FOTO: TERTUNDA — 0 foto dihasilkan (bukan gagal kode).**
Tiga kali percobaan foto xvfb, semuanya tidak menghasilkan satu
frame pun yang tampil ke layar. VM 1,5 core dipakai bersamaan
oleh banyak agen paralel (render Blender Bima ~55%, job Whisper,
2–3 instance Godot lain; load average 8–20). Proses foto hanya
mendapat ~16–19% CPU:

1. `foto_adzan.gd` (1280x720, 60 frame settle, 3 foto) — 19 menit
   tanpa satu foto pun; dimatikan.
2. `foto_adzan_ringan.gd` v1 (640x360, 25 frame settle, 2 foto)
   — 9,5 menit tanpa satu foto pun; dimatikan.
3. `foto_adzan_ringan.gd` v2 (640x360, 25 frame, 2 foto + trik
   PAUSE: tree di-pause begitu banner tampil, supaya adegan
   sholat sinematik — kumpul 25 dtk lalu takbir menyembunyikan
   banner — tidak mengalahkan frame yang lambat) — 20 menit,
   ~3:21 CPU, tetap 0 foto; DIMATIKAN 17 Nov ~22:02 WIB.

Bukti diagnosis (bukan dugaan): tangkapan layar X display :100
via `ffmpeg -f x11grab` setelah 20 menit menunjukkan layar abu
seragam TANPA HUD/game sama sekali — belum satu frame pun yang
dipresentasikan, padahal thread llvmpipe aktif meraster
(~22 dtk CPU per thread). Probe terpisah (`probe_pause.gd`,
headless, 5,5 dtk) MEMBUKTIKAN `process_frame` tetap terpancar
saat tree di-pause — jadi macetnya BUKAN trik pause. Dugaan
terkuat: frame pertama di jam Subuh (04:30, langit malam +
sesi sholat langsung mulai) butuh kompilasi shader malam yang
belum ada di cache, dan llvmpipe dengan jatah CPU ~16%
tidak kunjung selesai; bandingkan foto Wulan (C1–C4, jam
siang, tanpa sesi) selesai ~2 menit/foto, dan foto Cakra
(F0–F2) + tes bubble-ML (20/20) selesai di VM yang sama.

Cara mengulang (saat VM SEPI): jalankan
`foto_adzan_ringan.tscn` dari arsip
`fitur-baru/skrip/` (copy ke root proyek, xvfb-run
`-s "-screen 0 640x360x24" --resolution 640x360`), lalu isi
tabel di bawah dan hapus copy dari root. Foto BUKAN bukti
bunyi — bukti bunyi tetap tes headless di atas.

| Foto | Isi | Banner |
|---|---|---|
| `A1-subuh-banner.png` | Jam 04:30 | (belum ada — foto tertunda, lihat di atas) |
| `A2-maghrib-banner.png` | Jam 18:00 | (tidak difoto — cakupan Maghrib sudah dibuktikan tes headless Mode A) |
| `A3-bukan-jam-sholat.png` | Jam 10:00 | (belum ada — foto tertunda, lihat di atas) |

## 5. Cara memasang file adzan asli (untuk nanti)

1. Verifikasi lisensi di halaman sumber (CC0 / CC BY yang jelas),
   catat URL + lisensi di §1 doc ini.
2. Konversi ke format proyek (sama seperti ambience):
   `ffmpeg -i sumber.mp3 -ac 1 -ar 22050 -q:a 0 audio/adzan.ogg`
   (mono, 22050 Hz; durasi wajar adzan ±2–4 menit).
3. Letakkan sebagai `audio/adzan.ogg` — tanpa ubah kode.
4. Jalankan ulang `test_adzan.gd` (mode A harus 28/28),
   lalu hapus copy tes dari root proyek.
5. Minta Mas dengar di HP (kualitas + volume hanya bisa
   dinilai telinga).

## 6. Batasan jujur + catatan untuk Raka

- **Belum terverifikasi:** isi/kualitas suara adzan (belum ada
  file asli); volume adzan di HP Mas (DB_ADZAN = -10.0, sama
  seperti kegiatan — mungkin perlu disetel setelah didengar).
- **Interaksi dengan wirid:** bila suatu hari `wirid.ogg` ADA,
  wirid (kegiatan sesi sholat) akan mulai BERSAMAAN dengan adzan
  — keduanya berbunyi sekaligus selama ±1 menit. Perlu keputusan:
  tunda wirid sampai adzan selesai (patch `_perbarui_audio` di
  main.gd — BUKAN wewenang Sinta di tugas ini) atau biarkan.
  Saat ini tidak berdampak (wirid.ogg belum ada).
- **Adzan Subuh vs biasa:** file yang dipakai nanti sebaiknya
  adzan BIASA (tanpa "ash-shalatu khairun min an-naum") karena
  satu file dipakai untuk kelima waktu; kalau yang ketemu hanya
  versi Subuh, beri tahu Mas.
- **Import Godot:** file `.ogg` baru di `audio/` HARUS di-import
  dulu (sekali jalan `--editor --quit` atau buka proyek di editor)
  sebelum `ResourceLoader.exists` mengenalinya — tes pertama
  Mode A sempat membaca "TIDAK ADA" sebelum import (lihat §4).
- **Tidak deploy.** Tidak sentuh folder v2. Copy skrip tes/foto
  di root proyek sudah dihapus; arsip tetap di `fitur-baru/skrip/`.
## 7. File asli dipasang (Cakra, 18 Nov 2026) — PILIHAN MAS

Mas memilih (13:23 WIB) pilihan 3 dari shortlist Cakra
(`v2/ADZAN-SHORTLIST.md`): **"Beautiful adhan"**.

| | |
|---|---|
| File di proyek | `audio/adzan.ogg` (nama PERSIS seperti yang kode harapkan — **tanpa ubah kode**) |
| Sumber | Wikimedia Commons — https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg |
| URL file | https://upload.wikimedia.org/wikipedia/commons/b/b0/Beautiful_adhan.ogg |
| Pembuat | Adam-synagda (metadata Commons: Artist) |
| Lisensi | **CC0 1.0** — terverifikasi dari halaman file + metadata API Commons (LicenseShortName "CC0", http://creativecommons.org/publicdomain/zero/1.0/deed.en). Atribusi tidak wajib; pembuat tetap dicatat di `audio/README.md`. |
| Format | Ogg Vorbis stereo 44100 Hz, ~112 kbps, 1.229.032 byte (~1,2 MB) |
| Durasi | 154,0 dtk (2:34) — adzan lengkap |
| Konversi | TIDAK dikonversi (ukuran kecil, jauh di bawah batas 10 MB; konversi ke mono 22050 Hz akan memotong kualitas suara muadzin). Penyimpangan dari konvensi §5 dicatat di `audio/README.md`. |
| Unduhan | Unduhan pertama tanpa User-Agent ditolak Wikimedia (halaman error HTML); berhasil dengan header User-Agent. |

Tes headless ulang dengan file ASLI (`test_adzan.gd` dari arsip,
mode A): **29/29 LULUS, 0 FAIL, 0 SCRIPT ERROR** — file dikenali
(`ADZAN FILE: ADA`), adzan bunyi di kelima waktu (counter 1→6
termasuk unmute + tertunda), anti-ganda jalan, mute jalan,
ambience duck -30 dB → kembali -16 dB, tertunda-sampai-gestur
jalan. Copy tes di root proyek sudah dihapus lagi setelah tes.

**Belum terverifikasi (mohon telinga Mas di HP):**
- Apakah rekaman ini adzan BIASA atau versi SUBUH (mengandung
  "ash-shalatu khairun min an-naum")? Metadata Commons hanya
  berbunyi "Adhan." — tidak bisa dipastikan tanpa mendengar.
  Bila ternyata versi Subuh, beri tahu (satu file dipakai kelima
  waktu — lihat §6).
- Kualitas + volume di HP (DB_ADZAN = -10.0).

**TIDAK deploy** — menunggu perintah Xam.

