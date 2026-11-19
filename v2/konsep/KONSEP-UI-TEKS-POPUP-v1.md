# Konsep v2 — Tampilan Teks & Pop-up (Sinta, 19 Nov 2026)

Masukan Mas (19 Nov 12:32 WIB): "tampilan teks, pop up dll kurang keren..
masih kaku". Ini KONSEP saja — belum ada kode game yang diubah. Mockup
dibuat dengan font asli game (Baloo 2 + Amiri) di atas foto game, jadi
yang Mas lihat di mockup = yang akan terlihat di game.

## File

| Isi | File (`v2/konsep/`) |
|---|---|
| Dialog misi — SESUDAH | `konsep-ui-dialog-v2.png` |
| Pop-up petunjuk — SESUDAH | `konsep-ui-popup-v2.png` |
| Banner misi — SESUDAH | `konsep-ui-banner-v2.png` |
| Banding dialog (sebelum/sesudah) | `konsep-ui-banding-dialog-v1.png` |
| Banding pop-up (sebelum/sesudah) | `konsep-ui-banding-popup-v1.png` |
| Banding banner (sebelum/sesudah) | `konsep-ui-banding-banner-v1.png` |
| Skrip pembuat mockup (bisa diulang) | `desain-ui-teks-popup-v1.py` |
| Catatan ini | `KONSEP-UI-TEKS-POPUP-v1.md` |

Foto SEBELUM diambil dari game yang sudah live:
`foto-misi/dialog-aqsal-v2.png`, `foto-hud/hud-v3-perbaikan-popup-rev1.png`,
`foto-misi/petunjuk-santri-baru-putra.png`.

## Kenapa tampilan sekarang terasa "kaku"

1. **Warna datar** — panel diisi satu warna solid. Mata tidak merasakan
   kedalaman; panel terlihat seperti formulir, bukan elemen game.
2. **Teks seragam** — satu ukuran, satu bobot, satu warna. Tidak ada
   hierarki: judul, keterangan, dan isi sama pentingnya di mata.
3. **Semua rata tengah** (pop-up) — baris demi baris simetris seperti
   dialog sistem HP, bukan seperti papan game.
4. **Jarak sempit & seragam** — padding kecil, semua sudut sama, semua
   tombol pill yang sama. Tidak ada irama.
5. **Tidak ada gerak** — panel muncul langsung (pop), tanpa animasi masuk.

## Yang diusulkan — per elemen

### 1. Dialog misi (`scripts/ui_misi/dialog_misi.gd` + `gaya_misi.gd`)

- Panel: **gradien vertikal** zamrud gelap → zamrud (bukan solid),
  radius 18 → **26**, rim emas 3 → **2** + garis dalam tipis (hairline)
  krem alpha rendah — kesan berlapis. Bayangan lebih besar & lembut.
- Tab nama: tetap pill emas, tapi bergradien emas terang → emas +
  bayangan kecil.
- Kepala: subjudul jadi **kapital berjarak** ("PENGASUH PESANTREN
  UNIVERSE", emas terang, 14) + salam Arab **"أهلا وسهلا"** (Amiri, emas,
  tanpa harakat supaya render bersih) di bawahnya.
- Isi: ukuran 21, jarak baris lebih lega (leading ~1,45) + **aksen emas
  vertikal** di kiri teks — seperti kutipan.
- Pemisah: garis emas tipis antara isi dan tombol (sebelumnya tidak ada).
- Tombol utama: **bergradien** emas terang → emas + bayangan + panah **›**
  di kanan (mengajak menekan). Tombol kedua: outline, isi agak transparan.
- Footer: "Babak 1 dari 5" jadi **5 titik progres** (titik aktif emas
  terisi, sisanya outline) + teks tetap; "✕ Lanjut" dan "□ Chat" jadi
  **chip keycap** (kotak gelap berbingkai, seperti tombol keyboard).

### 2. Pop-up PETUNJUK TOMBOL (`scripts/ui.gd` `_build_petunjuk_popup`)

- Latar dim lebih gelap (alpha 80 → **96**) supaya pop-up menonjol.
- Panel: putih hangat bergradien + **pita emas di atas** + radius 26.
- Kepala **rata kiri** (bukan rata tengah): judul "Petunjuk Tombol" 26
  tebal hitam + subjudul abu "Ketuk tombol sesuai kebutuhanmu" 15.
- Tombol tutup ✕: masuk **lingkaran zamrud gelap** (sebelumnya ✕ kecil
  telanjang di sudut).
- Baris: ikon bentuk (△ □ ○ ✕) masuk **lingkaran lembut zamrud** +
  label tebal 20 + **keterangan kecil 14 abu** di bawahnya
  ("Berinteraksi dengan NPC & objek", dst.) — tiap baris sekarang
  menjelaskan, bukan sekadar menamai.
- Catatan kaki: masuk **strip krem** dengan ikon "i" emas (sebelumnya teks
  kecil abu melayang).
- Tombol "Mengerti": **penuh lebar, bergradien emas, 21 tebal**
  (sebelumnya pill outline kecil di tengah).

### 3. Banner petunjuk misi (`scripts/ui.gd` `_build_petunjuk_misi_banner`)

- Dari bilah hitam polos → **toast bergradien zamrud** + rim emas 2 +
  bayangan.
- **Ikon bintang emas** dalam lingkaran di kiri (penanda "ini misi").
- Teks jadi **dua baris**: ajakan tebal krem 24 ("ayo mulai misi santri
  barumu!") + arah emas 18 ("Sowan ke Ustadz sekarang") — sebelumnya satu
  baris emas yang sama rata.
- Panah **›** emas di kanan (isyarat "ikuti arah ini").

## Animasi masuk (usul — belum digambar, via Tween Godot, tanpa aset baru)

- Panel dialog / pop-up: **scale 0.96 → 1.0 + fade, 180 ms, ease-out**
  (muncul "mengembang" lembut, bukan pop).
- Banner: **geser turun dari atas, 220 ms, ease-out**.
- Tombol ditekan: **scale 0.97** sesaat (umpan balik sentuhan).
- Dim latar pop-up: fade masuk 150 ms.

## Yang TIDAK diubah

- **Palet tetap**: krem #F2EAD6, zamrud #065F46, zamrud gelap #043B2C,
  emas #C9A227, jati #7B4B2A. Tidak ada warna baru.
- **Font tetap**: Baloo 2 (Latin) + Amiri Bold (Arab). Tidak ganti font.
- **Isi teks tetap**: kalimat dialog, label tombol, dan teks banner sama
  persis dengan yang sudah ada (isi dialog masih draf sampai
  tashih Mas).
- **Ukuran & posisi kasar tetap**: dialog tetap di bawah layar, pop-up
  tetap di tengah, banner tetap di tengah-atas (y=200). Hanya gaya
  dalamnya yang berubah — jadi tidak mengganggu pemetaan tombol / tes
  sentuh yang sudah ada.
- **Chip "TEKS DRAF" DIHAPUS** atas keputusan Mas 19 Nov 2026 13:05 WIB
  ("Tidak usah teks draf.. hapus aja kata itu") — chip tidak tampil di
  mana pun: `buat_pill_draf()` dihapus dari `gaya_misi.gd` beserta semua
  pemakaiannya (dialog, Ruang Belajar, Tes, Panel Misi) dan cek tesnya.

## Kalau Mas ACC — langkah bangun (perkiraan)

1. `scripts/ui_misi/gaya_misi.gd`: tambah `gaya_panel_gradien()`,
   `gaya_tombol_emas_gradien()`, `buat_label_subjudul()`,
   `buat_dot_progres()`, `buat_chip_kunci()` — StyleBoxFlat tidak bisa
   gradien, jadi gradien dibuat sebagai TextureRect latar / GradientTexture2D
   (satu-satunya bagian yang butuh cara baru; sisanya hanya angka).
2. `scripts/ui_misi/dialog_misi.gd`: susun ulang kepala (subjudul +
   Arab), aksen emas isi, pemisah, footer titik + chip kunci.
3. `scripts/ui.gd`: `_build_petunjuk_popup` (kepala rata kiri, baris
   berikon + keterangan, strip catatan, tombol penuh) +
   `_build_petunjuk_misi_banner` (toast berikon 2 baris) + Tween animasi
   masuk di ketiganya.
4. Foto ulang ketiganya (pola `skrip/foto_*.gd`) → Mas nilai dari HP.
