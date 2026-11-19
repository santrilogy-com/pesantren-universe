# Uji Coba Kompres Tekstur — CATATAN (Rangga, 18 Nov 2026 ~21:30 WIB)

Trial saja, di folder ini. Game TIDAK diubah, TIDAK deploy, optimasi loading penuh TIDAK dikerjakan (Mas: "Nanti dulu").

## Verdict singkat

**Kompresi Basis/KTX2 BERHASIL — dengan satu syarat yang menentukan: encode HARUS pakai `--assign_oetf linear`.**

- Dengan flag default toktx (sRGB), tekstur di-render Godot **jauh lebih gelap** (rumput 73 vs 150, tanah 30 vs 81) — ini BUKAN cacat kompresi, melainkan perangkap ruang warna (lihat §3). Kalau langsung dipakai begitu, game jadi gelap — kekhawatiran Mas ("nanti jelek dong?") akan terbukti benar.
- Dengan `--assign_oetf linear`, hasil render **tidak bisa dibedakan dari aslinya** — mata maupun angka (selisih piksel rata-rata 2,1/255 untuk UASTC, 7,2/255 untuk ETC1S). Tidak ada blok, blur, atau perubahan warna.
- Rekomendasi bila Mas ACC optimasi loading nanti: **ETC1S + `--assign_oetf linear`** — paling kecil (rumput 0,20 MB vs 2,50 MB sekarang, −92%) dengan kualitas yang sama di mata. UASTC + linear adalah cadangan yang lebih aman secara teori (kualitas lebih tinggi, tapi 7× lebih besar).

## 1. Ukuran (per tekstur, 1024×1024, tanpa downscale)

| Tekstur | JPG asli | .ctex di .pck game (saat ini) | UASTC | ETC1S |
|---|---|---|---|---|
| `taman_leafy_grass_1k.jpg` (rumput) | 1.195.394 B | 2.502.542 B | 1.398.640 B (−44%) | 196.080 B (−92%) |
| `sawah_farm_soil_1k.jpg` (tanah) | 735.837 B | 1.538.654 B | 1.398.640 B (−9%) | 157.081 B (−90%) |

- Varian `linear` ukurannya sama persis dengan varian sRGB (rumput UASTC-linear 1.398.640 B; rumput ETC1S-linear 195.542 B) — flag OETF hanya metadata, tidak mengubah ukuran.
- UASTC ukurannya fixed-rate (~1,33 MB per tekstur 1K RGB + mipmaps), jadi menangnya tergantung sumber: rumput berisik menang besar (−44%), tanah halus menang kecil (−9%). ETC1S variable-rate, jauh lebih kecil di keduanya.
- Baseline aneh (dicatat, penyebab tidak diketahui): rebuild trial di proyek uji menghasilkan .ctex LEBIH KECIL dari .ctex game (rumput 1.795.730 vs 2.502.542 B). Angka .ctex game-lah yang berlaku untuk ukuran .pck.

## 2. Foto perbandingan (sudut sama, render Godot langsung, 1280×1280)

Proyek trial: `proyek/` (GL Compatibility, 8 quad 2×2 m, cahaya netral sama untuk semua shot, kamera pindah per shot, tunggu 40 frame, `save_png`; TANPA `--headless` — headless membuat `save_png` null; pakai Xvfb :96).

Shot mentah (satu per varian):
- `adu-rumput-asli.png`, `adu-rumput-uastc.png`, `adu-rumput-etc1s.png`, `adu-rumput-linear.png` (UASTC + linear), `adu-rumput-etc1s-linear.png` (ETC1S + linear)
- `adu-tanah-asli.png`, `adu-tanah-uastc.png`, `adu-tanah-etc1s.png`

Komposit (full-frame + crop tengah 1:1):
- `banding-rumput.png` — ASLI vs UASTC (gelap) vs ETC1S (gelap)
- `banding-tanah.png` — ASLI vs UASTC (sangat gelap) vs ETC1S (sangat gelap)
- `banding-rumput-linear.png` — ASLI vs UASTC + linear (tidak bisa dibedakan)
- `banding-rumput-etc1s-linear.png` — UASTC + linear vs ETC1S + linear (tidak bisa dibedakan)

## 3. Temuan kunci — perangkap sRGB (penyebab "gelap")

1. **Import Godot 4.7.2 compress/mode=3 (Basis Universal) TIDAK mengompres.** File `.ctex` berisi RGB8 mentah tak terkompres (terbukti hitungan byte eksak: 3.145.780 B = 1024×1024×3 + 52 header; dengan mipmaps 4.194.355 B = mentah × 4/3; tanpa magic KTX2). Diuji uastc_level 4/2/0 dan rdo_quality_loss 0.0/2.0, mipmaps on/off — semua mentah. File `.import` tetap mode=3. Jadi Basis-lewat-import-Godot adalah jalan buntu di setup ini — hasilnya LEBIH BESAR dari sekarang.
2. **toktx (KTX-Software 4.4.2) bekerja.** UASTC quality 2 ~10 dtk; quality 4 terlalu lambat (>4 menit, dimatikan). Godot memuat `.ktx2` langsung sebagai ImageTexture (format RGBA8 hasil dekompresi, mipmaps=true); editor import TIDAK membuat `.import`/`.ctex` untuk `.ktx2`, jadi kontribusi ukuran di .pck = ukuran file `.ktx2` itu sendiri.
3. **Perangkap: toktx default menulis flag transfer sRGB, dan loader KTX2 Godot 4.7.2 men-decode sRGB→linear saat load.** Terbukti dari decode balik (`get_image()` → save PNG): JPG asli mean 123,8; UASTC (sRGB) mean 55,6; tanah 63,5 → 14,0 — persis nilai linear dari sumber (0,486^2,2 ≈ 0,204). Akibatnya render jadi ~50% lebih gelap. **Obatnya: `--assign_oetf linear`** — decode balik mean 124,0 (≈ sumber 123,8), render mean 149,8 vs asli 149,6.
4. **Bukan flip/rotasi, bukan blur.** Pola daun/gumpalan tanah di posisi yang sama persis di semua varian; UASTC vs ETC1S (sama-sama sRGB) hampir identik satu sama lain (selisih 6,7) — jadi gelapnya berasal dari jalur loading, bukan dari kualitas encoding.

## 4. Angka perbedaan piksel (mean-abs-diff /255, RGB, vs ASLI)

| Perbandingan | Mean | Max | Keterangan |
|---|---|---|---|
| ASLI vs UASTC (sRGB) | 76,79 | 115 | jauh lebih gelap |
| ASLI vs ETC1S (sRGB) | 77,25 | 169 | jauh lebih gelap |
| ASLI vs UASTC + linear | 2,13 | 30 | tidak kelihatan beda |
| ASLI vs ETC1S + linear | 7,18 | 71 | tidak kelihatan beda |
| UASTC+linear vs ETC1S+linear | 6,83 | 70 | tidak kelihatan beda |

Kecerahan rata-rata render (mean RGB): ASLI 149,6; UASTC sRGB 72,8; ETC1S sRGB 72,3; UASTC+linear 149,8; ETC1S+linear 149,5. Tanah: ASLI 81,2; UASTC sRGB 29,9.

## 5. Cara encode yang benar (bila dipakai nanti)

```bash
K=~/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/ktx
export LD_LIBRARY_PATH="$K/KTX-Software-4.4.2-Linux-x86_64/lib"
TOK="$K/KTX-Software-4.4.2-Linux-x86_64/bin/toktx"
# ETC1S (rekomendasi — paling kecil):
$TOK --encode etc1s --qlevel 128 --assign_oetf linear --genmipmap out.ktx2 in.jpg
# UASTC (cadangan kualitas lebih tinggi):
$TOK --encode uastc --uastc_quality 2 --assign_oetf linear --genmipmap out.ktx2 in.jpg
```

Peringatan: **JANGAN encode tanpa `--assign_oetf linear`** — hasilnya gelap di game. Dan jangan pakai import Godot mode=3 (lihat §3.1).

## 6. Catatan teknis / pelajaran

- `/tmp` dihapus antar perintah di VM ini — alat harus tinggal di `~/workspace`. toktx ada di `ktx/KTX-Software-4.4.2-Linux-x86_64/bin/toktx` (butuh `LD_LIBRARY_PATH` ke `lib/`-nya). Tarball sumber: `ktx/ktx-linux.tar.bz2` (7 MB, KTX-Software 4.4.2, GitHub releases).
- ETC1S + linear baru dites render di rumput (tanah ETC1S-linear belum di-render; efek OETF adalah level format, bukan level tekstur, jadi diharapkan sama — tapi sebelum dipakai massal, render 1 shot tanah ETC1S-linear dulu untuk kepastian).
- Render 8 shot butuh >170 dtk (timeout run ke-3 memotong shot ke-8 `adu-tanah-etc1s.png` — file itu dari run ke-2, isinya sama). Untuk render ulang: naikkan timeout atau kurangi jumlah shot.
- `decode-*.png` = hasil `get_image()` tiap varian (bukti §3.3).

## 7. Tugas tambahan (steer 21:13 WIB) — meta viewport ganda: SELESAI

- Masalah: `index.html` hasil export punya 2 meta viewport — baris 5 `user-scalable=no` (template Godot) vs baris 95 `user-scalable=yes` (dari `export_presets.cfg:27` `html/head_include`).
- Perbaikan: **hapus baris `html/head_include` di `export_presets.cfg`** (isinya HANYA meta viewport itu, tidak ada yang lain). Verifikasi: `grep viewport|head_include export_presets.cfg` → 0 (bersih).
- `stage_v2.py` TIDAK menyuntikkan viewport/meta sendiri (dicek grep).
- Catatan: `index.html` staging saat ini masih hasil export lama (tetap 2 viewport) — perbaikan berlaku di export/staging BERIKUTNYA. Saat export berikutnya, verifikasi `index.html` hanya punya SATU meta viewport (`user-scalable=no`, baris template).
- TIDAK ada perubahan lain di game.

## 8. Penerapan massal (Mas ACC 21:33 WIB "kompres semua sekarang") — SELESAI 18 Nov 2026

**Encode: ETC1S + `--assign_oetf linear` untuk SEMUA 23 tekstur** (qlevel 128, `--genmipmap`). UASTC tidak dipakai — tidak ada tekstur yang ETC1S-nya terbukti jelek; semua spot-check lolos. Total `.ktx2` = **2.902.158 B** (dari `.ctex` 23.082.860 B, **−87%**). Satu-satunya pengecualian ukuran: `surau-v2_kisi.ktx2` (21.826 B) lebih besar dari `.ctex` lamanya (10.420 B, +11 KB — bisa diabaikan); 4 atlas PNG kecil juga sedikit membesar (lihat tabel) tapi total atlas tetap mengecil.

### 8.1 Per tekstur (.ctex lama → .ktx2 baru)

| Tekstur | .ctex lama | .ktx2 baru | Hemat |
|---|---|---|---|
| taman_leafy_grass_1k (rumput) | 2.502.542 | 195.542 | −92% |
| pohon-hias_bark_brown_01_1k | 2.066.080 | 184.335 | −91% |
| pohon-rindang_bark_brown_01_1k | 2.066.080 | 184.335 | −91% |
| pagar-bata_brick_wall_001_1k | 1.920.710 | 180.235 | −91% |
| taman_cobblestone_01_1k | 1.669.284 | 167.335 | −90% |
| sawah_brown_mud_03_1k | 1.644.656 | 172.484 | −90% |
| sawah_farm_soil_1k | 1.538.654 | 154.533 | −90% |
| taman_farm_soil_1k | 1.538.654 | 154.533 | −90% |
| gubuk-santri_brown_planks_04_1k | 1.262.706 | 148.832 | −88% |
| pagar-bambu_brown_planks_04_1k | 1.262.706 | 148.832 | −88% |
| taman_brown_planks_04_1k | 1.262.706 | 148.832 | −88% |
| lantai_stone_floor_1k | 1.067.942 | 162.094 | −85% |
| dinding_white_plaster_02_1k | 1.035.244 | 150.251 | −85% |
| cotton_jersey_diff_1k | 986.200 | 130.658 | −87% |
| pondasi_stone_block_wall_1k | 766.038 | 135.793 | −82% |
| masterplan-v2 (atlas) | 168.528 | 153.629 | −9% |
| konsep-v2 (atlas) | 148.510 | 135.747 | −9% |
| atlas-kampus-putri | 47.722 | 47.916 | +194 B |
| atlas-kawasan-bersama | 43.270 | 46.566 | +3.296 B |
| atlas-area-putra | 33.788 | 37.680 | +3.892 B |
| atlas-zona-penyangga | 27.362 | 33.374 | +6.012 B |
| surau-v2_plakat | 13.058 | 6.796 | −48% |
| surau-v2_kisi | 10.420 | 21.826 | +11.406 B |

### 8.2 Referensi yang diubah (atomik per tekstur)

- `scripts/material_tekstur.gd` — 3 konstanta (dinding, pondasi, lantai) → `.ktx2`
- `scripts/kampus_putri.gd:886-888` — rumput, cobblestone, farm_soil → `.ktx2`
- `scripts/player.gd:454` — cotton_jersey → `.ktx2`
- `data/buku.json` — `"gambar"` ×6 (atlas) → `.ktx2`
- `skrip/test_baca_buku.gd:69` — asersi path masterplan → `.ktx2`
- **Bug `ganti-tekstur.sh`:** sed pengganti tanpa prefix `res://` → referensi relatif; diperbaiki manual di 7 jalur kode + 6 jalur buku.json; diverifikasi 0 referensi relatif tersisa (sisa hit "lama" hanya komentar di `player.gd:441` + backup `player.gd.bak-ronde8-20261118`, keduanya historis). Skrip sudah diperbaiki DAN dikunci (exit 1 bila dijalankan ulang — kerja sudah selesai 18 Nov).

### 8.3 Verifikasi visual (render + baca sendiri)

- **Gate tanah ETC1S-linear (caveat trial §6 — tertutup):** `adu-tanah-etc1s-linear.png` terbaca tanah normal (bukan gelap); diff vs asli 2,57/255, max 40, mean RGB 81,2 vs 81,0. Komposit `banding-tanah-linear.png`.
- **Spot-check massal** (diff region-yang-sama, dibaca Rangga): kayu 2,86; bata 4,56; kain 2,38; batu 0,19; atlas 8,17; tanah 2,57; rumput 7,18 (trial). **Semua lolos — tidak ada yang kelihatan beda.** Foto `massal-kayu/bata/kain/batu/atlas.png`.
- **Pelajaran spot-check:** run massal pertama INVALID (file asli tanpa `.import` → quad kiri putih kosong; diperbaiki editor import); diff naif kiri/kanan mengembang karena membandingkan region berbeda (kamera hanya melihat 75% dalam tiap quad; diperbaiki overlap mapping; atlas butuh kamera z=6,0). Diff naif bata 17,58 ternyata mismatch region, bukan masalah kualitas (crop 1:1 dicek visual — bata sama, retak halus sedikit lebih lembut, bisa diterima).

### 8.4 Perangkap GLB (ditemukan ~15:00 WIB) + solusi URI .ktx2

- **Perangkap:** 10 tekstur yang dikira "tak terpakai" ternyata **embedded di GLB** (JSON `images` hanya `bufferView` + nama, mis. `bark_brown_01_1k`) dan importer (`gltf/embedded_image_handling=1`) mengekstraknya jadi file eksternal `<stem>_<nama>.<ext>` yang dirujuk `.scn`. Menghapusnya merusak SEMUA load GLB: **test_v2 42/60 (18 GAGAL)**, 93 "Can't load dependency".
- **Pemulihan:** 13 file GLB-extracted direstorasi **byte-identik dari byte embedded GLB** (ukuran cocok persis dengan aslinya); editor import ulang → test_v2 60/60.
- **Solusi permanen (dipakai, bukan fallback):** ubah JSON tiap GLB — image `{"bufferView":N,"mimeType":"image/jpeg","name":X}` → `{"uri":"<stem>_<X>.ktx2","name":X}`; hapus `.jpg/.png` + `.import` + `.scn/.md5` lama; re-import editor. 8 GLB: pohon-rindang, pohon-hias, pagar-bambu, pagar-bata, gubuk-santri, sawah (2 image), taman (4 image), surau-v2 (2 image PNG). `.scn` baru kecil (pohon-rindang 39 KB; referensi via UID, bukan path). Setelah semua 8: **test_v2 60/60, 0 "Can't load dependency"**.
- **Catatan:** byte JPEG lama tetap ada di chunk BIN tiap GLB (tak terujuk, ~3,9 MB total di file sumber — TIDAK masuk `.pck` karena importer mengabaikan bufferView tak terujuk). BIN bisa dibersihkan nanti bila mau (bukan prioritas).
- **Fallback yang TIDAK jadi dipakai:** Option F (kembalikan `.jpg` GLB, `.ktx2` hanya 13 tekstur kode) → pck ~19,6 MB. Tidak perlu — solusi URI berhasil penuh.

### 8.5 Hasil export + staging Deploy B

- **Export Web dari snapshot** (Godot 4.7.2, `--export-release "Web"`, skrip `v2/export/deployB-pipeline.sh`): **`index.pck` 28.043.740 B → 7.967.296 B (−71,6%, −20.076.444 B)**. Entri 598 → 653. `.ctex`: 24 file 23.084.356 B → **1 file 1.496 B** (hanya `icon.svg` — ikon aplikasi, bukan tekstur game). `.ktx2`: 0 → **23 file 2.902.158 B**. Parser PCK: `parse-pck.py` (format Godot 4.7.2: header 112 B, direktori di akhir file, string dipad nol ke kelipatan 4 — divalidasi dengan mereproduksi angka pck lama persis).
- **wasm tidak berubah:** 39.514.754 B (5 chunk).
- **Staging:** `v2/export/web-pages-ktx2/` (BUKAN `web-pages` — itu staging Deploy A / d08dfb5e, jangan ditimpa). pck 2 chunk × 3.983.648 B. Boot harness `test_chunked_boot.mjs`: **SEMUA LULUS** (14 cek, sha pck + wasm cocok). `index.html` 1 viewport (`user-scalable=no` — perbaikan §7 terkonfirmasi di export baru), `fileSizes` pck 7.967.296, index.html sha `d33e612e925b0082`.
- **Regresi** (tree tekstur-lengkap, sebelum edit menoleh Kirana): test_v2 **60/60**, test_pencahayaan **27/27**, test_baca_buku **66/66** (retry; run pertama 55/64 karena fetch live Jurumiyah kehabisan waktu tunggu 15 dtk di bawah beban VM — flake waktu, bukan regresi; server kitab merespons HTTP 200).
- **PERINGATAN — staging ini BUKAN untuk deploy langsung:** snapshot export menangkap `player.gd` Kirana yang sedang diedit — duplikat key `"hijab"` (`player.gd:1356` `hijab_node` + `:1369` `hijab`) → parse error, `network_manager.gd` gagal compile. **Deploy B WAJIB re-export dari tree segar setelah Kirana lapor hijau + gate hijau.** Gate siap: `v2/export/gate-deploy-ktx2.sh` (adaptasi gate-deploy-20261118-1952; test_kamera TANPA `--fixed-fps 60`).
