# Audio Pesantren Universe (Ronde 17)

## Ambience (SUDAH ADA — dipakai game)

Loop suasana, Ogg Vorbis mono 22050 Hz, q0, dinormalisasi ke −24 LUFS,
loop mulus (4 dtk terakhir di-crossfade dengan 4 dtk pertama). Semua
**CC0** (domain publik, bebas dipakai tanpa atribusi) — dicari lewat
Openverse, file dari Freesound:

| File | Isi | Sumber | Durasi |
|---|---|---|---|
| `burung.ogg` | Kicau burung pagi di lapangan + sedikit angin | Freesound 456766 — "Birds Ambience Atmosphere early morning field slight breeze" (CC0) | 40 dtk |
| `angin.ogg` | Angin/daun (breeze) | Freesound 181801 — "breeze.wav" (CC0) | 40 dtk |
| `jangkrik.ogg` | Jangkrik malam di hutan | Freesound 453862 — "crickets night forest" (CC0) | 35,4 dtk |

Pemakaian di game (`scripts/audio_pesantren.gd`): 04:00–10:00 burung,
10:00–15:00 angin, 15:00–18:00 burung, 18:00–04:00 jangkrik.

## Adzan saat jam sholat (FITUR ADZAN — Sinta, 17 Nov 2026)

Satu file, `adzan.ogg`, diputar SEKALI (tidak di-loop) bersamaan
dengan banner sholat (Subuh 04:30, Dzuhur 12:00, Ashar 15:00,
Maghrib 18:00, Isya 19:00) — lihat `FITUR-ADZAN-STATUS.md`.
Selama adzan bunyi, ambience di-duck (-30 dB). Ikut tombol
Suara/Senyap (bus Master).

**STATUS 17 Nov 2026: FILE BELUM ADA.** Kodenya sudah jadi dan
sudah diuji (tes headless 28/28 dengan nada tes sementara, lalu
10/10 tanpa file — banner + sesi tetap jalan, game tidak error).
Yang belum: rekaman adzan berlisensi bersih yang TERVERIFIKASI.

Pencarian 17 Nov 2026 (Sinta): rekaman adzan CC0 ADA di Freesound
— halaman pencarian Freesound dengan filter lisensi "Creative
Commons 0" untuk kata kunci `adhan` (dibaca 17 Nov ~20:57 WIB)
menampilkan ±14 rekaman CC0 (contoh: adzan subuh Balakong Kuala
Lumpur; adzan di luar Masjid Jumeirah Dubai, Jan 2012; adzan yang
diperagakan sendiri perekamnya di Kakusenkei, Jepang; rekaman
lapangan Fes, Marrakesh, Al-Azhar Park Kairo). TAPI: halaman hasil
pencarian itu tidak menampilkan judul/ID/tautan tiap rekaman, dan
halaman tiap suara di Freesound + Wikimedia Commons tidak bisa
dibuka dari VM ini saat itu (HTTP 403 dari fetcher), jadi TIDAK ADA
satu file pun yang lisensinya berhasil DIVERIFIKASI per-file — maka
TIDAK ADA file yang diunduh/dipakai. Lebih baik fitur tertunda
daripada rekaman bermasalah.

Yang DITOLAK (jangan dipakai):
- Rekaman Cambridge "Voices and Faces of the Adhan" (CC BY-NC-ND
  3.0) — non-komersial + tanpa turunan (format pun tak boleh diubah).
- Koleksi archive.org "ADZAN around the world" / "Kumpulan Adzan"
  — tanpa pernyataan lisensi.
- Apa pun dari YouTube (termasuk yang "diekstrak dari YouTube" di
  Freesound) — jangan comot.
- TTS / suara sintetis / rekaman buatan — dilarang.

Cara mengisi (kalau sudah ada file terverifikasi): letakkan file
`.ogg` (mono, 22050 Hz, seperti ambience — lihat bawah) di folder
ini dengan nama PERSIS `adzan.ogg` — **tanpa ubah kode**.
`mainkan_adzan()` di `scripts/audio_pesantren.gd` langsung
memakainya. Catat sumber + URL + lisensi di `FITUR-ADZAN-STATUS.md`
dan di bawah ini. Jangka panjang paling aman tetap **rekam sendiri**
(masjid / muadzin Sidogiri) — seperti rekomendasi untuk wirid &
nadzom.

| File | Dipakai saat | Sumber | Durasi |
|---|---|---|---|
| `adzan.ogg` | Banner sholat muncul (5 waktu) | BELUM ADA — menunggu rekaman CC0 terverifikasi / rekaman Mas | — |

## Bacaan kegiatan (SENGAJA KOSONG — jangan diisi suara palsu)

Slot ini disiapkan kodenya, tapi **filenya belum ada**. Bacaan
(wirid / Quran / nadzom) TIDAK BOLEH digenerate TTS atau disintesis —
menunggu **rekaman Mas** atau file rekaman berlisensi.

| File | Dipakai saat |
|---|---|
| `wirid.ogg` | Sesi sholat berjamaah berjalan |
| `quran_khataman.ogg` | Sesi khataman berjalan (kitab Jurumiyah / Safinatun Naja) |
| `nadzom.ogg` | Sesi khataman kitab Amtsilah Tashrifiyyah berjalan |

Cara mengisi: letakkan file `.ogg` (mono, 22050 Hz, nama PERSIS seperti
di atas) di folder ini — **tanpa ubah kode**. Selama file belum ada,
game tetap jalan normal: ambience biasa terus berbunyi, tanpa error.

## Sampel referensi (sudah dikirim ke Mas — Zahra, 16 Nov ~08:57 WIB)

Folder `~/workspace/pesantren-verse/audio-referensi/` (±1,9 MB).
JANGAN salin mentah ke sini sebelum Mas memutuskan — baca dulu:

1. **`quran-alfatihah-alafasy.ogg` (47 dtk, qari Mishary Rashid
   Alafasy) — lisensi BERSIH untuk non-komersial** (AlQuran Cloud:
   personal & edukasi; HARUS diganti kalau game jadi komersial).
   Kandidat pengisi `quran_khataman.ogg` — TAPI: durasinya 47 dtk
   dan player kegiatan me-loop, jadi Al-Fatihah akan berulang selama
   sesi khataman 60 menit; rekaman lebih panjang lebih baik. Surah
   pendek lain bisa diambil dengan cara sama. Kalau Mas ACC, file ini
   perlu di-downmix ke mono 22050 Hz dulu (saat ini 293 KB stereo).
2. **`wirid-ratib-al-haddad-cupli.ogg` (2 mnt dari ±21,8 mnt) —
   lisensi TIDAK JELAS** (archive.org tanpa lisensi/pembuat) — hanya
   untuk didengar, BUKAN untuk dipakai di game.
3. **`nadzomu-ajurumiyyah-cupli.ogg` (2 mnt dari ±25 mnt) — lisensi
   TIDAK JELAS** (situs dakwah tanpa pernyataan lisensi), kualitas
   asli rendah (16 kbps) — hanya untuk didengar.
4. Nadzom Aqidatul Awam / Imrithi berlisensi bebas TIDAK ketemu
   (hanya teks/PDF atau audio di dalam aplikasi Android). Tidak ada
   rip YouTube. Rekomendasi Zahra: jangka panjang paling aman tetap
   **rekam sendiri** untuk wirid & nadzom.
