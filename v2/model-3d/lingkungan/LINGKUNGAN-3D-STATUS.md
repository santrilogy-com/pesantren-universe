# LINGKUNGAN v2 — STATUS 3D

**Konsep:** `v2/konsep/lingkungan/` — 5 PNG + `KONSEP-LINGKUNGAN.md`
(DI-ACC Mas 17 Nov ~20:31 WIB, "ACC, lanjut 3D"; urutan kerja pohon →
pagar → gubuk → taman → sawah; kedua varian pohon + pagar)
**Dibangun:** 17 Nov 2026, Blender 4.5.16 LTS headless, Cycles CPU
**Folder:** `v2/model-3d/lingkungan/` — per elemen satu subfolder
(`.blend` + `.glb` engine-agnostic + skrip build + `render/`)
**Skrip bersama:** `common.py` (util + palet HEX persis PV),
`render_lingkungan.py` (Cycles 768px, 64 sampel, HDRI),
`apply_tekstur.py` (pasang tekstur Poly Haven), `swap_tekstur_1k.py`
(turunkan tekstur 2k → 1k untuk GLB), `cek_tembus.py` (cek BVH)

## Status ringkas (22:40 WIB, 17 Nov 2026) — SELESAI + TERVERIFIKASI

| Elemen | Model (.blend + .glb) | Render baru (HDRI+tekstur) | Verdict Mas |
|---|---|---|---|
| Pohon rindang | ✅ SELESAI | ✅ 2/2 (depan, tiga-perempat) | ✅ **DI-ACC 21:41 WIB** |
| Pohon hias | ✅ SELESAI | ✅ 2/2 (depan, tiga-perempat) | ✅ **DI-ACC 21:41 WIB** |
| Pagar bambu | ✅ SELESAI | ✅ 2/2 (depan, tiga-perempat) | ✅ **DI-ACC 21:41 WIB** |
| Pagar bata | ✅ SELESAI | ✅ 2/2 (depan, tiga-perempat) | ⏳ menunggu verdict |
| Gubuk santri | ✅ SELESAI | ✅ 3/3 (depan, samping, tiga-perempat) | ⏳ menunggu verdict |
| Taman | ✅ SELESAI | ✅ 2/2 (depan, tiga-perempat) | ⏳ menunggu verdict |
| Sawah | ✅ SELESAI | ✅ 2/2 (tiga-perempat, atas) | ⏳ menunggu verdict |

**Model 7/7 SELESAI. Render baru 14/14 SELESAI, semua sudah diverifikasi
visual oleh Bima.** Yang DI-ACC jangan diutak-atik lagi — pertahankan
standar yang sama. Pagar bata, gubuk, taman, sawah siap dinilai Mas.

## Ukuran tiap elemen

| Elemen | Ukuran | Objek | Verts | Tris | .blend | .glb |
|---|---|---|---|---|---|---|
| Pohon rindang | ±8,5 m, tajuk ±5,7 m | 6 | 726 | **1.408** | 587 KB | 777 KB |
| Pohon hias | ±3,5 m, tajuk Ø 2,4 m | 3 | 290 | **552** | 505 KB | 750 KB |
| Pagar bambu | segmen 4 m, tinggi 1,5 m | 2 | 167 | **246** | 461 KB | 210 KB |
| Pagar bata | segmen 4 m, tinggi 0,9 m | 9 | 63 | **90** | 508 KB | 587 KB |
| Gubuk santri | 4 × 3 m, total ±4,5 m | 60 | 587 | **934** | 970 KB | 292 KB |
| Taman | 8 × 6 m | 108 | 1.620 | **2.792** | 1,36 MB | 2,82 MB |
| Sawah | 20 × 12 m, 4 petak | 15 | 6.584 | **2.316** | 879 KB | 1,51 MB |

Semua jauh di bawah target (pohon ≤2.000, gubuk ≤40.000 hero). GLB taman
paling besar (2,82 MB) karena menanam 4 tekstur 1k; sisanya ≤1,5 MB.

## Isi tiap model (sesuai konsep)

- **Pohon rindang:** batang jati meruncing 0→6 m + tajuk 3 gumpalan
  tumpang tindih (zamrud + daun + daun muda) — bukan 1 bola lollipop v1.
- **Pohon hias:** batang 1,8 m + tajuk bundar + sorot daun muda.
- **Pagar bambu:** 15 bilah bambu 9 cm + 2 rel jati + 3 tiang jati
  ujung runcing (tiap 2 m). Modul segmen 4 m, bisa diulang.
- **Pagar bata:** dinding krem + plinth batu + lis emas + 3 pilar krem
  tutup emas. Modul segmen 4 m.
- **Gubuk santri:** 6 tiang jati, kolong 1,2 m + silang kolong, lantai +
  dinding papan jati, atap pelana zamrud tua + lis emas bubungan +
  finial emas, pintu jati tua + gagang emas, jendela kaca + kisi,
  beranda 1 m + tangga 5 anak tangga, 2 tikar + rak kitab, kayu bakar
  di kolong.
- **Taman:** rumput 8×6, jalan batu melengkung 7 lempeng, 4 bedeng bunga
  (merah/kuning/ungu/oranye, 8 bunga per bedeng) + pagar jati rendah,
  2 bangku jati, 1 pohon hias + 3 semak.
- **Sawah:** lumpur 20×12, pematang 0,6 m (puncak 0,4 m, bisa jalan),
  saluran air utara, air 15 cm per petak, 720 rumpun padi (3 bilah
  segitiga per rumpun, 2 warna hijau).

## Tekstur + HDRI Poly Haven (CC0, gratis) — diterapkan TANPA bangun ulang

Aset di `tekstur/` (2k + 1k; yang tertanam di GLB = 1k, supaya GLB
tidak membengkak — taman sempat 10,6 MB di 2k → 2,8 MB di 1k):

| Aset | Dipakai di |
|---|---|
| HDRI `kloppenheim_06_puresky_2k.hdr` (langit siang cerah) | Dunia render semua elemen (bukan di GLB) |
| `bark_brown_01` (kulit batang) | Batang kedua pohon |
| `brown_planks_04` (papan kayu coklat) | Jati pagar bambu, dinding/lantai gubuk, bangku + pagar bedeng taman |
| `brick_wall_001` (bata) | Dinding krem pagar bata |
| `leafy_grass` (rumput) | Rumput taman |
| `farm_soil` (tanah ladang) | Bedeng taman, pematang sawah |
| `brown_mud_03` (lumpur) | Lumpur sawah |
| `cobblestone_01` (batu bulat) | Jalan batu taman |

Cara pasang: UV cube-project (1 ubin/meter) per mesh + material flat
diubah jadi MixRGB Multiply (warna palet × tekstur, fac 0,35–0,5) +
Bump halus 0,15. Palet HEX tetap terjaga karena warna dasar palet
yang dikalikan tekstur. Tajuk daun, air, dan atap zamrud tetap warna
datar (sengaja — gaya stilasi). Bilah bambu tetap datar (terlalu tipis
untuk tekstur).

## Cek TEMBUS (pelajaran @jipraks) — `cek_tembus.py` + `cek/*.txt`

Metode: BVH overlap dalam koordinat dunia untuk tiap pasangan objek.
Hasil per model: pohon-rindang 9, pohon-hias 2, pagar-bambu 1,
pagar-bata 13, gubuk 103, taman 133, sawah 35 pasangan ter-flag.

- **1 CACAT NYATA — SUDAH DIPERBAIKI:** cabang pohon rindang menembus
  keluar tajuk dan menjuntai di udara sebagai tongkat coklat (terlihat
  di render depan + tiga-perempat pertama). Perbaikan: cabang dihapus
  total (batang sudah masuk ke tajuk; cabang di dalam tajuk tidak
  terlihat). Rebuild: 1.528 → **1.408 tris**. Render ulang dengan
  HDRI+tekstur sedang jalan.
- **Sisanya = sambungan yang disengaja atau noise:** tiang menempel
  dinding/lantai, silang kolong bersilangan di tiang, pematang bersilang
  di sudut, rel menempel bilah, pilar menempel dinding, tikar/rak
  menempel dinding, padi menjuntai alami ke pematang selatan, bunga
  menempel tanah bedeng. Tidak ada bagian yang menjuntai keluar seperti
  cabang tadi. Catatan alat: BVH `overlap()` memberi positif palsu
  kecil untuk segitiga koplanar yang berdekatan tapi tidak bersentuhan
  (air 4 petak sawah berjarak 0,6 m ikut ter-flag; AABB membuktikan
  tidak bersentuhan) — jadi daftar di atas dibaca + dinilai manusia,
  bukan angka mentah.

## Render

- Skrip: `render_lingkungan.py` — Cycles CPU, 768px, 64 sampel,
  denoising, HDRI + 2 lampu matahari (utama 3.0, isi 0.8).
- View per elemen: pohon 2 (depan, tiga-perempat), pagar 2 (depan,
  tiga-perempat), gubuk 3 (depan, samping, tiga-perempat), taman 2
  (depan, tiga-perempat tinggi), sawah 2 (tiga-perempat tinggi, atas).
- Render lama (pra-tekstur, latar datar) masih ada di folder pagar
  (13:51–13:55) — akan tertimpa render baru.

## File

- `pohon/build_pohon.py` → `pohon-rindang.blend/.glb`, `pohon-hias.blend/.glb`
- `pagar/build_pagar.py` → `pagar-bambu.blend/.glb`, `pagar-bata.blend/.glb`
- `gubuk/build_gubuk.py` → `gubuk-santri.blend/.glb`
- `taman/build_taman.py` → `taman.blend/.glb`
- `sawah/build_sawah.py` → `sawah.blend/.glb`
- `common.py`, `render_lingkungan.py`, `apply_tekstur.py`,
  `swap_tekstur_1k.py`, `cek_tembus.py`, `cek/*.txt`, `tekstur/`
- **Catatan:** kalau `build_*.py` dijalankan ulang, tekstur hilang
  (build membuat material flat dari nol) — pasang ulang dengan
  `apply_tekstur.py` + `swap_tekstur_1k.py` sesudahnya.

## Perbaikan setelah render pertama (semua sudah terverifikasi)

1. **Cabang pohon rindang menembus tajuk** → cabang dihapus total,
   rebuild 1.528 → 1.408 tris. Render baru: tidak ada lagi tongkat
   menjuntai. (Pohon sudah DI-ACC Mas atas render baru ini.)
2. **Kamera gubuk salah sisi** → "depan" dan "tiga-perempat" pertama
   memotret dinding BELAKANG (pintu menghadap +Y, kamera di −Y).
   Diperbaiki di `render_lingkungan.py` (kamera pindah ke +Y) +
   render ulang 3 view. Sekarang pintu + jendela 4 panel + tangga 5
   anak tangga + beranda terbaca jelas, tidak ada yang tembus.
3. **Kotak hitam di persilangan pematang sawah (z-fighting)** →
   pematang vertikal diturunkan 5 mm (puncak 0,395 vs horizontal 0,4),
   GLB diekspor ulang, `build_sawah.py` diperbaiki supaya rebuild
   nanti tidak mengulang cacat. Render ulang 2 view: kotak hitam
   HILANG total di kedua view.

## Penilaian jujur per elemen (setelah verifikasi visual semua render)

- **Pohon rindang/hias:** bagus — tajuk 3 gumpalan terbaca sebagai massa
  bertumpang (bukan lollipop), batang meruncing, tidak ada yang tembus.
  Tekstur kulit batang nyaris tidak terlihat dari jarak render (batang
  terbaca coklat datar) — bisa diterima, pohon dibaca dari siluetnya.
  ✅ DI-ACC Mas.
- **Pagar bambu:** bagus — 15 bilah krem + 2 rel jati + 3 tiang runcing
  rapi, bayangan bersih. ✅ DI-ACC Mas.
- **Pagar bata:** bersih — dinding krem + lis emas + tutup piramida emas
  rapi. Kelemahan jujur: tekstur bata HAMPIR TIDAK TERLIHAT (fac 0,45
  di atas krem nyaris putih) — dinding terbaca krem polos, bukan bata.
  Kalau Mas mau bata lebih terbaca, fac bisa dinaikkan (perlu render
  ulang 2 view, ~11 menit). Menunggu verdict.
- **Gubuk santri:** bagus — dinding papan bertekstur terbaca, atap
  zamrud + lis emas + finial rapi, pintu jati tua + jendela 4 panel +
  tangga 5 anak tangga + beranda + silang kolong + kayu bakar, tidak ada
  yang tembus. Menunggu verdict.
- **Taman:** bagus — 4 bedeng 4 warna terbaca jelas, jalan batu
  melengkung rapi, 2 bangku jati, pohon hias + 3 semak. Rumput bertekstur
  halus (hampir datar) — bisa diterima. Menunggu verdict.
- **Sawah:** bagus setelah perbaikan — 4 petak, padi 2 warna hijau
  berbaris rapi, air pucat, pematang bersih tanpa kotak hitam. Menunggu
  verdict.

## Status

**MODEL SELESAI 7/7 + TEKSTUR/HDRI SELESAI + RENDER 14/14 SELESAI +
VERIFIKASI VISUAL SELESAI. POHON (2 varian) + PAGAR BAMBU DI-ACC MAS
(21:41 WIB, 👍) — jangan diutak-atik lagi. PAGAR BATA, GUBUK, TAMAN,
SAWAH MENUNGGU VERDICT MAS.** Tidak ada penempatan di peta (model
mandiri dulu, integrasi dunia v2 nanti). Folder v1/Godot/Three.js/
karakter/bangunan lain tidak disentuh.
