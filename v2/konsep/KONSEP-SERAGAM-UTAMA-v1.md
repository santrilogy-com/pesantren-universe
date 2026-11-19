# KONSEP — Seragam Utama v1 (Kirana, 19 Nov 2026)

Spesifikasi dari Mas (19 Nov 15:32). **KONSEP SAJA — menunggu ACC Mas sebelum dibangun ke game.**
Gate 20261119-3 sedang jalan saat konsep ini dibuat; kode game TIDAK diubah.

## 1. Putra — baju putih + sarung hijau garis kuning tipis vertikal

| Bagian | Warna | Kode |
|---|---|---|
| Baju (koko) | Putih | `#FFFFFF` (saat ini `#e8e8e8` — diputihkan) |
| Sarung | Hijau zamrud | `#008062` (sama seperti sarung santri sekarang — tidak berubah) |
| Garis motif | Kuning emas | `#C9A227` (emas resmi game) |
| Peci | — | Tetap sistem `peci_model` (bulat putih default pemain baru; nasional hitam 50/50 NPC) |
| Kancing | Emas | `#C9A227` |
| Sandal | Coklat jati | `#7B4B2A` |

**Motif garis (ini inti pesanan Mas — "tipis sampai hampir tidak ketara dari jauh"):**
- Garis VERTIKAL, lebar **2 px** pada tekstur 256 px (≈ **1,2 cm** di dunia: 256 px melingkari sarung ~1,54 m → 1 px ≈ 6 mm).
- Jarak antar garis **32 px** (≈ **19 cm**), periodik 32 px supaya menyambung mulus melingkari tabung.
- Bukti di mockup detail (panel C): pada tampilan 25% (simulasi dilihat dari jauh) garis hampir tidak ketara, sedangkan dari dekat tetap terbaca.
- Bila Mas mau lebih samar lagi: turunkan ke 1 px atau jarak 48 px — tulis di ACC.

## 2. Putri — baju biru langit + sarung batik

| Bagian | Warna | Kode |
|---|---|---|
| Baju (tunik lengan panjang, sampai lutut) | Biru langit | `#87CEEB` |
| Sarung | Batik indigo | dasar `#1B2A4A` (lihat §3) |
| Jilbab | Biru langit (lebih dalam dari baju) | `#7FB8E0` |
| Sandal | Coklat jati | `#7B4B2A` |

**Pilihan jilbab:** biru langit `#7FB8E0` (sedikit lebih dalam dari baju supaya terpisah visual).
Alternatif bila Mas mau: krem `#F2EAD6` seperti jilbab sekarang.

**Catatan bentuk (penting untuk build):** putri saat ini memakai **abaya** (satu potong,
`PAKAIAN_ABAYA_*`). Seragam baru = **baju + sarung** → saat dibangun, putri memakai jalur
koko+sarung (`PAKAIAN_DEFAULT`) + hijab. Abaya tetap dipakai Ustadzah Mariyah / Penjaga
Pos Jaga (bukan seragam santri).

## 3. Tekstur batik putri — detail kelihatan, file kecil

File: `v2/konsep/tekstur-batik-putri-v1.png` — **512×256 px, 1.066 byte** (±1 KB).
Pembanding: versi RGB yang sama = 5.483 byte. (Skrip: `buat_batik_putri_v1.py`.)

**Motif:** parang (pita diagonal mengalir) + isen-isen (garis tepi tipis) + mlinion
(titik-titik emas) — mengikuti matematika `_motif_sarung()` di `player.gd`
(periode 32 px), tapi digambar sebagai file PNG, bukan prosedural.

**Teknik kompresi (jawaban "bisa kompres batik png ya"):**
1. **Palet sengaja terbatas — 5 warna saja:** indigo `#1B2A4A`, indigo sedang `#586E94`,
   krem `#F2EAD6`, indigo gelap `#0E1626`, emas `#C9A227`. Batik tradisional memang
   2–3 warna, jadi detail garis/titik tetap tajam tanpa butuh jutaan warna.
2. **PNG palet (mode P, 16 warna adaptif)** + `optimize=True, compress_level=9` →
   1.066 byte untuk 512×256. Tidak ada `oxipng`/`pngquant` di VM; hasil PIL ini
   sudah sekecil itu karena paletnya kecil.
3. **Periodik 64 px persis** (512/64=8, 256/64=4; frekuensi sinus `k = 2π/64`) →
   tekstur menyambung mulus tanpa jahitan saat melingkari tabung sarung
   (pratinjau 2×2 ubin: `tekstur-batik-putri-v1-ubin2x2.png`, tidak ada garis sambung).
   Catatan: `_motif_sarung()` lama memakai `sin((x-y)*0.08)` yang tidak membagi
   2π — ada jog kecil di garis sambung; bila motif ini nanti digambar prosedural
   di game, pakai `k = 2π/64`.

**Pakai di game (saat dibangun):** impor PNG sebagai `albedo_texture` sarung putri
(atau gambar ulang prosedural dengan matematika yang sama). Satu file 1 KB untuk
semua santriwati + NPC putri (material di-cache seperti `_motif_sarung_cache`).

## 4. Mockup

- `konsep-seragam-utama-v1.png` — tampak depan putra + putri + kode warna.
- `konsep-seragam-utama-detail-v1.png` — (A) zoom garis kuning, (B) zoom batik 2×,
  (C) tampilan dari jauh 25%, (D) chips warna resmi.
- `konsep-seragam-utama-samping-v1.png` — profil putra + putri.
- Skrip gambar: `gambar_seragam_utama_v1.py` (gaya gambar mengikuti `gambar_npc_v1.py`).

## 5. Catatan build (nanti, setelah ACC + setelah gate 20261119-3 + deploy)

1. **Putra:** varian baru tekstur sarung — dasar hijau `#008062` + garis vertikal emas
   2 px / jarak 32 px — **menggantikan parang** untuk sarung putra (parang tetap untuk
   Kyai/sarung lain yang memakainya). Paling rapi: `_motif_sarung()` tambah parameter
   `motif` (`"parang"` | `"garis"`) atau fungsi `_motif_garis_kuning()` baru.
2. **Putri:** outfit baru (baju `#87CEEB` + sarung batik impor + jilbab `#7FB8E0`),
   jalur koko+sarung + hijab; `OUTFIT_DEFAULT` putri diganti; abaya tidak lagi
   dipakai santriwati.
3. **Taper sarung:** mockup memakai taper sekarang. Pilihan taper Mas (widget
   "Motif saja" vs "Motif + rampingkan") belum diputuskan — apa pun pilihannya,
   warna/motif seragam ini TIDAK berubah, hanya bentuk tabung sarung.
4. **Tes:** `test_seragam_utama.gd` (baru) — warna baju/sarung putra & putri sesuai
   spesifikasi; garis 2 px jarak 32 px; tekstur batik terpasang + tileable;
   putri tidak lagi memakai abaya; NPC 20 tetap memakai seragam ini.
