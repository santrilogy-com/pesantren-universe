# Tekstur Bangunan P5 — Poly Haven CC0

**P5 Fase 1 (Bima, 18 Nov 2026 — ACC Mas 14:01 WIB).** Texture map
sungguhan untuk dinding gedung prosedural (audit
`v2/konsep/AUDIT-TEKSTUR-BANGUNAN.md` §4 P5). Semua file di sini
**CC0 (domain publik, gratis, tanpa atribusi wajib)** dari
[Poly Haven](https://polyhaven.com/textures), resolusi **1K**
(1024×1024, wajar untuk web). Helper: `scripts/material_tekstur.gd`.

## Daftar file

| File lokal | Aset Poly Haven | Sumber | Pakai untuk |
|---|---|---|---|
| `dinding_white_plaster_02_1k.jpg` (397 KB) | White Plaster 02 | https://polyhaven.com/a/white_plaster_02 | Dinding krem (plester halus) |
| `pondasi_stone_block_wall_1k.jpg` (214 KB) | Stone Block Wall | https://polyhaven.com/a/stone_block_wall | Fondasi / anak tangga batu |
| `lantai_stone_floor_1k.jpg` (369 KB) | Stone Floor | https://polyhaven.com/a/stone_floor | Lantai / teras batu |

Unduhan langsung (diffuse 1K JPG):
- https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/white_plaster_02/white_plaster_02_diff_1k.jpg
- https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/stone_block_wall/stone_block_wall_diff_1k.jpg
- https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/stone_floor/stone_floor_diff_1k.jpg

MD5 file **asli** (terverifikasi sama dengan yang diumumkan Poly Haven
di `api.polyhaven.com/files/<slug>`):
- white_plaster_02: `7b10c2686bcfd76d1f309a20fd06b57e`
- stone_block_wall: `1b4f10545a59fa8f8436093d72293c45`
- stone_floor: `6dff94d7c1da0fd034ba714c249ec72f`

## Normalisasi warna (PENTING — kenapa file ini bukan file mentah)

Texture mentah Poly Haven gelap dan ber-cast warna:

| Tekstur mentah | Rata-rata RGB |
|---|---|
| White Plaster 02 | 0.556 / 0.531 / 0.480 |
| Stone Block Wall | 0.244 / 0.180 / 0.116 |
| Stone Floor | 0.467 / 0.399 / 0.285 |

Godot mengalikan `albedo_texture × albedo_color`. Tekstur mentah ×
tinta krem `#F2EAD6` = cokelat gelap — palet rusak (pelajaran yang
sama dari jilbab rebuild Kirana 18 Nov: tekstur jersey × krem =
cokelat). Karena itu file di repo ini **sudah dinormalisasi** dengan
`v2/skrip/normalisasi_tekstur_p5.py`: remap affine per channel,
rata-rata tiap channel = **0.90**, tanpa cast warna, kontras lokal
dipertahankan (gain ≤ 1.0, p1/p99 tidak terpotong). Hasilnya:

- rata-rata RGB tiap file setelah normalisasi: **0.90 / 0.90 / 0.90**
- tekstur × tinta palet ≈ **0.90 × tinta** — warna palet tetap
  terbaca (selisih ~0.09 per channel, dalam toleransi tes),
  permukaan dapat detail plester/batu.

## Konvensi nama

Sama seperti tekstur lingkungan yang sudah ada di folder ini
(`taman_cobblestone_01_1k.jpg`, `pagar-bata_brick_wall_001_1k.jpg`,
`cotton_jersey_diff_1k.jpg`): `<konteks>_<slug-poly-haven>_1k.jpg`.

## Lisensi

CC0 1.0 Universal — bebas dipakai, diubah, dan didistribusikan
termasuk untuk keperluan komersial, tanpa perlu izin atau atribusi.
Lihat https://polyhaven.com/license.
