# FITUR BACA BUKU — Status AKHIR (Tara, 18 Nov 2026, ~01:35 WIB)
— REVISI LAYAR PENUH (18 Nov 2026, ~07:30 WIB, permintaan Mas 07:11 WIB)

Pembaca kitab di dalam game: dekati rak → tombol **BACA KITAB** → daftar buku →
daftar bab/halaman → halaman baca. Patokan desain: artifact
pratinjau-pembaca-kitab (zamrud #065F46 / pasir #F2EAD6 / emas #C9A227,
teks Arab besar Amiri, baris atribusi). **SELESAI + TERUJI sebelum Subuh.**

## REVISI: Reader LAYAR PENUH (Mas 07:11 WIB: "bisa ngga dimodel full?
## Bukan pop up gitu.. biar bisa dibaca jelas")
- Panel reader kini mengisi SELURUH viewport (anchor full rect, offset 0)
  lewat `_layout_baca_panel()` di `scripts/ui.gd` — bukan lagi popup
  720x640. Dipanggil dari `_build_baca_buku_panel()` + `_layout_semua_panel()`
  (resize/open). Sudut siku + tanpa border (sudut membulat menyisakan
  celah game di 4 sudut layar penuh); isi diberi jarak aman dari tepi
  layar via MarginContainer (kiri/kanan 40, atas/bawah 16).
- Klik-di-luar tidak lagi menutup (tidak ada "luar" — panel menutupi
  semuanya); tutup tetap via X / TUTUP / Escape; kunci gerak pemain
  tetap lewat visibilitas panel (`main.gd` tidak diubah).
- Font baca dibesarkan: Arab 30→34, Latin 22→26 (dasar `font_dasar`,
  tetap diskala `_terapkan_skala_panel` di HP).
- PERBAIKAN F4 (tertunda dari semalam — dikerjakan sekarang): label teks
  dibungkus MarginContainer (kanan 32, kiri 16) — teks Arab tidak lagi
  mepet scrollbar. Terukur di tes: celah kanan 40 px.
- Navigasi jadi DUA baris (temuan saat pengerjaan): satu baris berisi
  Sebelumnya + zoom −/100%/+ + Berikutnya MELUBER keluar panel di HP
  portrait (lebar minimum gabungan > lebar isi saat font diperbesar
  skala layar). Baris 1: Sebelumnya/Berikutnya (lebar penuh). Baris 2:
  zoom −/100%/+ (tengah, hanya halaman gambar, `_baca_zoom_row`).
- Tes: **66/66 lolos** (57 lama tetap lolos + 9 cek fullscreen baru:
  anchor full rect, panel = viewport, panel > popup lama, area teks/
  gambar dapat ruang, celah Arab ≥20, judul+nomor terlihat, tombol nav
  ≥36, portrait ikut viewport). Foto: F1–F5 landscape + F1–F5-portrait
  di `v2/foto-baca-buku/` — dibaca sendiri semua (daftar 7 buku muat
  sekaligus, teks Arab/Latin besar dan jelas, atlas tampil penuh, baris
  zoom terpisah rapi di tengah).
- Catatan jujur: (1) Di portrait, game menampilkan overlay "PUTAR HP-MU"
  di ATAS reader (fitur game yang sudah ada — "Tetap main portrait"
  untuk lanjut); panel reader sendiri sudah layar penuh di baliknya.
  (2) Teks bab 1 Jurumiyah diawali "..." — itu ISI dari server
  (OpenITI), bukan artefak render; isi buku tidak diubah.
  (3) `test_v2` sempat 59/60 ("Spawn putra") saat run ini — BUKAN
  regresi reader: save di disk `santri.json` tertinggal
  `jenis_kelamin:"putri"` (dari run gender/hijab), jadi pemain spawn
  di putri. Terbukti: tanpa save, test_v2 60/60. Perbaikan: cek spawn
  di `test_v2.gd` kini sadar gender (spawn harapan = `_spawn_putri`
  bila save putri, else SPAWN putra) — test_v2 kini 60/60 DENGAN save
  putri tetap di tempat. (4) Total titik rak kini 6 (2 Surau + 2
  Musholla + 2 Kelas Putri dari wiring Raka) — cek tes diperbarui
  dari 4 ke 6.
- BELUM DEPLOY — Xam yang export + deploy.

## Aturan flag (Mas, 23:49 WIB — KOREKSI dari larangan awal)
Hanya buku `dicek_ustadz:true` yang tampil (filter client-side di
`BukuData`, jangan hardcode kitab masuk, jangan ubah flag dari game).
Jurumiyah + 4 kitab antrean **SUDAH OK** (Saka, 23:58 WIB) — tanpa lencana
"Belum dicek ustadz". Draf `data/buku-draft-nahwu.json` (Nahwu Dasar v2,
`dicek_ustadz:false` + field PERINGATAN) **TIDAK PERNAH dimuat** reader.

## Yang berubah / file
- `scripts/buku_data.gd` (BARU): logika data murni — muat lokal, filter
  ketat (hanya bool `true` lolos; string `"true"`/1/null tidak), parse
  daftar/kitab/bab server, gabung (server dulu, dedupe id), **deteksi
  bahasa dari judul** (kitab server tidak mengirim field bahasa — judul
  Arab → "ar", sisanya "id"; perbaikan label "Indonesia" di foto F2).
  API: `GET https://43-173-39-166.sslip.io/api/kitab` (publik, TANPA
  token — `X-PV-Token` tidak dipakai di file game mana pun) + isi kitab
  via `GET /api/kitab/<id>` (semua bab) / `?bab=N` (satu bab).
- `scripts/ui.gd`: panel reader `_build_baca_buku_panel()` + `open/close/
  is_baca_buku_visible()` + fetch server + navigasi + zoom gambar.
  Tiga tampilan: DAFTAR (judul + bahasa + atribusi) → BAB (nomor + judul
  + "›") → BACA (teks Arab Amiri 30 rata kanan / Latin 22 rata kiri,
  tombol Sebelum/Berikut + zona tap kiri-kanan 64 px, nomor bab/halaman,
  tombol TUTUP besar 56 px + X + Escape + klik-di-luar; gambar
  fit-to-width + zoom 100–250% + pan via ScrollContainer + keterangan).
  **Panel reader 720×640** (lebih tinggi dari panel lain 700×560 —
  halaman gambar butuh ruang; via `_pusatkan_panel(panel, w, h)`).
  **BACA_HTTP_TIMEOUT = 30 dtk** (dinaikkan dari 10 — HTTPRequest Godot
  di render software lambat; fetch gagal 2× di run foto sebelum ini).
  **Baris status disembunyikan saat kosong** (`_baca_set_status()`).
- `scripts/main.gd`: titik rak (`_rak_spots`), `_dekat_rak()` (radius
  3,0 m, hanya di dalam ruangan), tombol "BACA KITAB", buka via
  `_on_interact`, **gerak pemain dinolkan selagi reader terbuka**
  (joystick + keyboard) — tutup mengembalikan kontrol.
- `scripts/interior_surau.gd`: `rak_spots` (2, Barat + Timur) di dict
  `build()`; `scripts/interior_musholla.gd`: dipakai kunci `rak_spot` /
  `rak_spots` dari dict `build()` (2 rak Dewi — lihat catatan tabrakan).
- `data/buku.json` (Laras, TIDAK diubah): array polos 2 buku —
  "Puisi Pilihan Chairil Anwar" (teks, id, 6 bab, domain publik) +
  "Atlas Pesantren Universe" (gambar, id, 6 halaman, `res://data/atlas/*.png`).
  Loader menerima array polos maupun `{"buku": [...]}`.
- `skrip/test_baca_buku.gd` + `.tscn`, `skrip/foto_baca_buku.gd` + `.tscn`.

## Isi daftar (saat ini — diverifikasi LIVE)
Server (5 kitab, semua `dicek_ustadz:true`): Jurumiyah 25 bab,
Safinatun Naja 66, Imrithi 34, Matn Abi Shuja 17, Arba'in Nawawi 42.
Lokal (2 buku): Puisi Chairil Anwar, Atlas Pesantren Universe.
**Total daftar reader: 7 buku.** Kitab antrean baru muncul otomatis
begitu ada di server (fetch dinamis + filter).

## Tes headless — 57/57 LULUS, EXIT 0 (run terakhir 01:26 WIB)
`godot --headless --path . skrip/test_baca_buku.tscn`
(lihat `/tmp/test_baca_buku.log`): data lokal (2 buku, 6 bab/6 hal.,
draf Nahwu tidak dimuat), filter (hanya bool true lolos 1/4), parse
server (stub false→0, true→1, rusak→[], ok:false→[]), **bahasa server
terdeteksi Arab**, parse kitab (2 bab, judul bab 2, `?bab=N`), gabung
(server dulu), rak (4 titik: 2 Surau + 2 Musholla), tombol BACA KITAB,
buka/tutup, kunci gerak (`move_dir` nol saat membaca, jalan lagi setelah
tutup), LIVE 5 kitab + daftar 7, Jurumiyah e2e (25 bab, bab 1 berisi
"الكلام", bab 2 "الإعراب"), puisi bab 2 "Aku" (binatang jalang) +
navigasi, zona tap ada, atlas hal. 1 termuat + keterangan + zoom 150%
+ hal. 2, **area gambar >100 px (cek regresi F5)**, fetch gagal →
status gagal + lokal tetap ada.
Satu cek berupa placeholder jujur: "Tombol TUTUP besar (min 56)" —
tinggi minimum 56 px diset di kode; verifikasi visualnya di foto F2–F5.

## Foto bukti — `v2/foto-baca-buku/` (run ke-4, 01:28–01:29 WIB, EXIT 0)
- `F1-rak-tombol.png` — rak barat Surau + tombol BACA KITAB.
- `F2-daftar-buku.png` — daftar 7 buku; label bahasa kini **"Arab"**
  untuk kelima kitab (sebelumnya salah "Indonesia").
- `F3-halaman-teks-latin.png` — puisi "Aku" (bab 2/6).
- `F4-halaman-teks-arab.png` — Jurumiyah bab 1 (Arab besar, "BAB 1 • 1/25").
- `F5-halaman-gambar.png` — atlas masterplan v2 hal. 1, **peta tampil
  penuh** (AREA PUTRA, MASJID BESAR, KAMPUS PUTRI, SURAU, dll.) +
  zoom "− 100% +" + nav + TUTUP.
Jalankan: `xvfb-run -a <godot> --path . skrip/foto_baca_buku.tscn`
(bukan headless — butuh X; timeout 900 dtk karena render software
lambat di bawah beban VM).

## Masalah F5 — SELESAI (akar masalah + perbaikan, 01:20–01:30 WIB)
Peta atlas tidak terlihat di foto run ke-3 padahal tekstur termuat
(`texture != null`, tes lulus): penyebabnya **layout, bukan gambar**.
Keterangan + baris zoom berdiri sendiri di VBox sebagai baris tetap —
baris-baris tetap itu menghabiskan tinggi panel (560 px) sehingga
ScrollContainer gambar kebagian **0 px** (terbukti via probe headless:
`gambar_scroll.size = (1395, 0)`, gambar sendiri 1129×734 tapi
terpotong viewport 0 px). Perbaikan di `ui.gd`:
1. Keterangan dipindah **ke dalam** ScrollContainer gambar (di bawah
   TextureRect, ikut scroll) — tidak lagi makan baris tetap.
2. Zoom dipindah **ke dalam baris nav** (`◀ Sebelumnya | − 100% + |
   Berikutnya ▶`) — satu baris, bukan tiga.
3. Kicker disembunyikan di halaman gambar (judul "Halaman N" + nomor
   sudah cukup); baris status disembunyikan saat kosong.
4. Panel reader diperbesar 720×640; area gambar/teks diberi
   `custom_minimum_size` 200 px (jaminan tidak 0 lagi).
5. Cek regresi di tes headless: "area gambar >100px".
Verifikasi: tes 57/57 + foto F5 peta tampil penuh. Catatan: keterangan
halaman gambar kini dibaca dengan scroll ke bawah (ikut gambar).

## Catatan tabrakan paralel (Dewi, 18 Nov ~00:31 WIB)
Dewi membangun modul `scripts/rak_buku_putri.gd` (RakBukuPutri) +
menulis ulang rak Musholla (1 rak kotak → 2 rak jati: Timur + Utara,
tiap 10 kitab) + `interior_kelas_putri.gd` / `interior_gedung_putri.gd`.
Dampak ke fitur ini:
- Run tes 23:56 + 00:32 WIB GAGAL compile (`RakBukuPutri not declared`)
  karena file Dewi belum selesai ditulis saat Godot memindai class —
  BUKAN bug reader. Setelah file lengkap, tes 55/55 lulus.
- Musholla kini 2 rak (bukan 1 seperti brief awal) — wiring main.gd
  membaca `rak_spots` (jamak) bila ada, fallback `rak_spot` (tunggal,
  dipertahankan Dewi untuk main.gd). Total titik rak: 4.
- Perbaikan ikut: `BukuData` sempat error runtime `String == bool`
  pada flag string `"true"` (Godot 4 strict) — diperbaiki ke cek
  `is bool` di `buku_lolos()` + `normalisasi_buku()`.

## Yang belum / batasan
- Deploy TIDAK dilakukan (urusan Damar; export juga sedang ditahan
  sampai Raka lapor posisi — file proyek diedit paralel).
- Reader tidak mengubah flag `dicek_ustadz` apa pun; kitab baru tinggal
  ditambah Saka di server / Laras di `data/buku.json` mengikuti kontrak.
- Kosmetik F4 (teks Arab mepet scrollbar) SUDAH diperbaiki di revisi
  layar penuh 07:30 WIB (MarginContainer kanan 32 — celah terukur 40 px).
  Sisa catatan: teks bab 1 Jurumiyah diawali "..." dari server (isi
  OpenITI, bukan artefak — isi buku tidak diubah).
