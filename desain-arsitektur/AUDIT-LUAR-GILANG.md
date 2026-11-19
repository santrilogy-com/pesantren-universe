# AUDIT DUNIA LUAR — Semua Elemen Masih Balok/Primitif Godot

**Auditor:** Gilang (Tim Maps) · **Tanggal:** 17 November 2026
**Sumber:** `godot-dunia/scripts/pesantren_builder.gd`, `kampus_putri.gd`, `tembok_putri.gd`, `jalan_ronde22.gd`, `palette.gd`, `langit_dinamis.gd`, `mission_data.gd`, `main.tscn`
**Ruang lingkup:** LUAR ruangan saja. Interior (Surau/Cangkruk/Musholla, map terpisah z=-300) TIDAK diaudit. Karakter pemain/NPC TIDAK diaudit (Tim Karakter/Bima).

## Temuan global

- **NOL model 3D halus di seluruh dunia luar.** Tidak ada satu pun `load()` GLB/gltf di codebase — satu-satunya `preload` adalah font (Baloo 2, Amiri). Semua geometri dibuat runtime dari primitif Godot lewat helper `Palette.box/cylinder/sphere/capsule` (`BoxMesh`, `CylinderMesh`, `SphereMesh`, `CapsuleMesh`, `TorusMesh`).
- **~726 mesh primitif individual** di luar ruangan (estimasi dari hitung kode; pohon mendominasi: 183 mesh = 25%).
- **39 kelompok elemen logis** masih primitif (dirinci di bawah).
- Palet sudah benar (krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A`) — yang balok adalah **bentuknya**, bukan warnanya.
- Gaya target: 3D halus seperti Asian Boy (chibi 3,66 kepala, permukaan bulat lembut, mesh buatan manusia 62.434 tris, CC-BY giyasudeen31) — lihat `blender-santri/riset-model-dasar/ASIANBOY-STUDY.md`.

---

## 1. Bangunan

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 1 | **Surau** (bangunan utama) | (0,-14), diputar -25° | ~88 mesh: dinding BoxMesh, atap pelat box, kubah utama = SphereMesh digepeng (skala Y 0,9) + drum CylinderMesh, 4 kubah kecil = bola gepeng, menara = tumpukan silinder, portal = 7 keping box (voussoir), jendela = box + cakram silinder diputar 90°, sabit = 2 bola | 20×16 m, dinding 5 m, kubah puncak ~10 m, menara ~14,6 m | Bangunan paling besar & paling sering dilihat (tepat di depan spawn putra). Kubah "bola gepeng" adalah ciri balok yang paling kentara dari jauh. |
| 2 | **Serambi Surau** | Depan pintu Surau, dunia ±(-3,4,-6,8) | Lantai box batu, 4 tiang silinder krem, balok box, atap box miring 20°, 3 anak tangga box | 6×3 m, tinggi ~4,2 m | Atap = pelat box miring, bukan genteng melengkung. |
| 3 | **Tempat Wudu** | (-9,22,-23,81), barat-laut Surau | Bak box krem + air box biru + 2 keran silinder emas, alas box batu | 2×1,2 m | Air = kotak biru datar. |
| 4 | **Musholla Ar-Raudhah** | (134,-24) | ~97 mesh: dinding box krem, atap datar box zamrud + lis emas, kubah = drum silinder + SphereMesh digepeng (skala Y 0,72) + tangkai silinder + sabit = **TorusMesh** miring, 2 pilar silinder, jendela = box emas + box zamrud, plakat = 2 box + Label3D Arab | 12×10 m, dinding 4 m, kubah puncak ~6,6 m | Bangunan terbesar kampus putri. Sabit torus adalah satu-satunya TorusMesh di game — tetap primitif. |
| 5 | **Serambi Musholla** | (134,-17,6) depan pintu selatan | Lantai box batu, 2 tiang silinder jati, atap box jati, lis emas box, 1 anak tangga box | 4,5×2,8 m | Sama polanya dengan serambi Surau. |
| 6 | **Taman Musholla** | (138,5,-27,8) & (138,5,-20,2) | 2 bedeng box + 12 bunga = SphereMesh kecil warna-warni | Bedeng 2×1,2 m | Bunga = bola-bola kecil di atas kotak tanah. |
| 7 | **Cangkruk Putra** | (-22,-18), pintu selatan (-22,-14) | ~21 mesh: cangkang box kayu, atap segitiga = 2 box miring ±0,27 rad + bubungan box, jendela 6× box zamrud, lis emas box | 10×8 m, tinggi 3,4 m, atap puncak 4,85 m | "Pos ronda kayu" — atap segitiga dari 2 pelat box. |
| 8 | **Cangkruk Putri** | (128,-12) | Sama persis dengan Cangkruk Putra (~20 mesh) | 10×8 m, tinggi 3,4 m | Duplikat pola putra. |
| 9 | **Kelas Putri** | (130,0), pintu selatan | Gedung generik: 6 box dinding krem + atap datar box zamrud + lis emas + 8 box jendela + ambang/lis box + Label3D | 10×8 m, tinggi 3,6 m | 1 dari 5 gedung generik — semuanya klon pola yang sama. |
| 10 | **Asrama Putri** | (152,0), pintu barat | Sama, gedung generik | 12×8 m, tinggi 4,0 m | Gedung terbesar kampus putri setelah Musholla. |
| 11 | **Kantor Ustadzah** | (150,-28), pintu barat | Sama, gedung generik | 8×6 m, tinggi 3,4 m | — |
| 12 | **Madrasah** | (152,-12), pintu barat | Sama, gedung generik | 10×8 m, tinggi 3,8 m | — |
| 13 | **Studio** | (166,-12), pintu utara | Sama, gedung generik | 10×8 m, tinggi 3,6 m | — |
| 14 | **Pos Jaga ×4** | (±40,-35), (±40,80) | Gubuk kayu: 6 box dinding + lantai box + atap piramida = CylinderMesh 4-segmen (top_radius 0) + Label3D | 3×3 m, tinggi ~3,6 m | Atap piramida = kerucut segi-4, bukan limasan halus. |
| 15 | **Pos Satpam** | (17,5), timur gerbang (14,0) | Sama dengan Pos Jaga (gubuk 3×3 m + atap piramida 4-segmen) | 3×3 m | Pintu menghadap barat ke gerbang. |
| 16 | **Pos Jaga TL** | (160,-35) | Sama dengan Pos Jaga (gubuk 3×3 m + atap piramida 4-segmen) | 3×3 m | Tanpa lampu jalan (sesuai brief). |

## 2. Tembok, pagar & gerbang

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 17 | **Tembok pemisah putra/putri** | x=14, z -60..+16 | 2 box krem (58 m + 14 m) + 2 lis emas box + 2 fondasi batu box | 76 m panjang, 3 m tinggi, 0,4 m tebal | Garis lurus 76 m — sangat dominan di pandangan dari spawn. |
| 18 | **Gerbang (14,0)** | (14,0), bukaan z -2..+2 | 2 pilar box krem 0,6×3,4×0,6 + tutup emas box + gapura box krem + lis emas + atap box zamrud + 2 daun pintu box jati + Label3D "GERBANG" 2 sisi | Bukaan 4 m, gapura puncak ~4 m | Pintu = 2 pelat box jati rapat. |
| 19 | **Tembok keliling pondok putri** | Persegi x 115..180, z -52..+22 | 5 box krem (50+20+74+65+65 m) + 5 lis emas box + 5 fondasi batu box | Keliling ~274 m, 3 m tinggi, 0,4 m tebal | Tembok terpanjang di game; seluruh muka luarnya kotak polos. |
| 20 | **Gerbang Putri (115,0)** | (115,0), bukaan z -2..+2 | Sama polanya dengan Gerbang (14,0): 2 pilar box + gapura box + 2 daun pintu box jati + Label3D "GERBANG PUTRI" 2 sisi | Bukaan 4 m, gapura puncak ~4 m | Satu-satunya bukaan tembok keliling. |
| 21 | **Pagar kayu Musholla** | Petak x 126..140, z -31..-17 | ~46 mesh: tiang box jati tiap ~2 m + 2 rel box per segmen (6 segmen, total ~51,5 m) | Tinggi 1 m | Pagar kayu "piket" dari kotak-kotak. |

## 3. Terrain, gunung & sawah

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 22 | **Tanah** | Seluruh peta, pusat (0,0) | 1 BoxMesh raksasa | 800×800 m, tebal 0,2 m | Datar sempurna — tanpa bukit/relief sama sekali. |
| 23 | **Gunung ×2** | Selatan jauh, jarak ~350–360 m (sudut 160° & 200°) | CylinderMesh kerucut 8-segmen (top_radius 0,5) + collision silinder | Tinggi 70 & 85 m, jejari 60 & 70 m | Kerucut segi-8 raksasa — latar seluruh peta selatan; faceting 8 sisi terlihat dari jauh. |
| 24 | **Sawah** | (60,30), tenggara | 12 petak air BoxMesh mengkilap + 9 pematang box + 24 rumpun padi = kerucut CylinderMesh 6-segmen + Gubuk Sawah (box kayu + atap piramida 4-segmen merah) | 60×40 m | Air = kotak-kotak biru-hijau; padi = kerucut hijau kecil. |
| 25 | **Gubuk Sawah** | (26,30), tepi barat sawah | Box kayu 2,4×1,8×2 m + atap piramida CylinderMesh 4-segmen | ~2,4×2 m, tinggi ~2,8 m | Atap merah segi-4. |

## 4. Jalan

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 26 | **Jalan E-W** | z=0, x -160..+160 | 1 BoxMesh pasir tipis | 320×2,5 m, tebal 0,06 m | Termasuk ruas (14,0)→(115,0) ke kampus putri. |
| 27 | **Jalan N-S** | x=0, 3 segmen | 3 BoxMesh pasir (12,75 m + 186 m + 176 m) | Lebar 3 m, total ~375 m | Jalan utama ke Surau; segmen putus di sekitar Surau. |
| 28 | **Jalan ke sawah** | (16,30) | 1 BoxMesh pasir | 32×2,5 m | Cabang dari jalan E-W ke tepi sawah. |
| 29 | **Jalan masuk kampus putri** | (115,0)→(115,8)→(142,8) | 2 BoxMesh pasir (kaki utara + kaki timur) | 2,5 m lebar, total ~28 m | Membelok karena Kelas Putri menghalangi z=0. |
| 30 | **Jalan internal putri + 8 konektor** | x=142, z -35..+14 | 1 BoxMesh utama 3×49 m + 8 konektor BoxMesh pasir | Utama 49 m; konektor 2,5–22,5 m | Semua jalan = pelat kotak tipis warna pasir, tanpa trotoar/batas. |

## 5. Pohon & vegetasi

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 31 | **Pohon ×61** | Tersebar radius s.d. ~210 m; terdekat (-10,-8), (18,-6), (-12,10), (12,12), (-26,-8), (22,6) | Tiap pohon 3 mesh: batang CylinderMesh + tajuk SphereMesh + tajuk kedua SphereMesh lebih kecil | Tinggi ~3,8 m, tajuk r~1,15 m | **Pola "lollipop"**: bola hijau di atas silinder cokelat — pohon paling berulang di game (183 mesh). TIDAK ADA pohon di dalam kampus putri. |
| 32 | **Semak ×6** | (-8,26), (8,26), (-20,-28), (20,-28), (-30,-2), (30,-2) | SphereMesh digepeng (skala Y 0,6) | r~0,7 m | Bola hijau gepeng di tepi jalan. |
| 33 | **Batu hias ×4** | (-40,-2), (40,2), (-16,44), (16,-44) | SphereMesh digepeng abu-abu (skala Y 0,55) | r~0,5 m | Bola abu-abu gepeng. |

## 6. Props luar

| # | Nama | Lokasi | Bentuk primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|---|
| 34 | **Lampu jalan ×13** | 8 di sisi barat jalan N-S x=-2,5 (z -70..70) + 1 di tiap Pos Jaga/Satpam (5) | Tiap lampu: tiang CylinderMesh hitam + bohlam SphereMesh emissive | Tinggi 3 m, bohlam r 0,22 m | Tiang lurus + bola lampu — tanpa lengan/cabang. |
| 35 | **Plot terkunci ×4** | Ruang Kelas (16,0), Asrama (-16,0), Masjid Besar (0,-32), Perpustakaan & Taman (0,20) | Alas BoxMesh pasir 10×8 m + 2 tiang silinder kayu + papan BoxMesh putih + Label3D 2 sisi | Papan 4,2×1 m | Lahan kosong bertanda — placeholder, wajar tetap primitif sampai dibangun. |
| 36 | **Peti Kayu (Misi 3)** | (0,26), kawasan bersama | ~9 BoxMesh: badan + tutup + 2 pita emas + kunci emas | 1,1×0,75 m | Peti = kotak kayu + tutup kotak. |
| 37 | **Penanda misi ×3** | M1 (3,-6,5), M2 di interior (bukan luar), M3 di peti (0,26) | Hanya Label3D "!" + "TERKUNCI/SELESAI" (tanpa mesh) | — | Bukan mesh, tapi elemen visual luar yang masih teks datar. |
| 38 | **Sandal ×4 set** | Depan Surau, Cangkruk Putra, Cangkruk Putri, Musholla | Tiap set: 2 CylinderMesh digepeng (skala 0,9×1,0×1,5) | ~0,35 m | Sandal = 2 silinder pipih cokelat. |
| 39 | **Langit (matahari/bulan/bintang)** | Kubah langit r~360–380 m | Matahari + halo = 2 SphereMesh, bulan + halo = 2 SphereMesh, bintang = MultiMesh 140 bola kecil | Bola matahari r 18 m, bulan r 12 m | Benda langit = bola emissive — wajar & disengaja (bukan target upgrade). |

---

## Hitungan

| Kategori | Kelompok elemen | Mesh primitif (estimasi) |
|---|---|---|
| Bangunan (Surau, Musholla, 2 Cangkruk, 5 gedung, 6 pos) | 16 | ~330 |
| Tembok, pagar & gerbang | 5 | ~103 |
| Terrain, gunung & sawah | 4 | ~52 |
| Jalan (semua ruas) | 5 | 19 |
| Pohon & vegetasi | 3 | ~193 |
| Props luar (lampu, plot, peti, sandal) | 5 | ~24 |
| Langit | 1 | 5 |
| **TOTAL LUAR** | **39 kelompok** | **~726 mesh primitif** |

- **Total elemen balok di luar: 39 kelompok elemen logis, ~726 mesh primitif individual.**
- **0 (nol) model 3D halus** di dunia luar — 100% primitif.
- Penyumbang mesh terbanyak: pohon 183, Musholla ~97, Surau ~88, gedung generik 95 (5×19), pagar Musholla ~46, tembok keliling 25.

## 5 yang paling mencolok secara visual

1. **Surau (0,-14)** — bangunan utama, tepat di depan spawn putra; kubah bola-gepeng + menara tumpukan-silinder + portal 7 keping box terlihat dari detik pertama. Ini wajah pesantren — upgrade di sini paling terasa.
2. **Tembok pemisah x=14 + tembok keliling putri (115..180)** — ~350 m garis kotak krem lurus; mendominasi pandangan horizontal dari mana saja di kampus inti.
3. **Pohon ×61 ("lollipop")** — pola bola-di-atas-silinder yang sama diulang 61 kali sampai radius 210 m; sekali mata menangkap polanya, seluruh vegetasi terbaca balok.
4. **Gunung ×2** — kerucut 8-segmen setinggi 70–85 m; faceting segi-8 terlihat jelas sebagai latar seluruh peta selatan.
5. **Musholla Ar-Raudhah (134,-24)** — kubah bola-gepeng + sabit torus + atap datar box; bangunan kedua yang paling sering dilihat (spawn putri (130,14) menghadap ke arahnya) dan satu-satunya kubah kedua di game.

Catatan tambahan: tanah 800×800 yang datar sempurna dan jalan-jalan pelat-kotak tipis juga mencolok dari ketinggian, tapi kalah prioritas dari 5 di atas karena pemain lebih sering memandang horizontal. Plot terkunci (4) sengaja tidak masuk 5 besar — itu placeholder resmi, bukan bangunan jadi.
