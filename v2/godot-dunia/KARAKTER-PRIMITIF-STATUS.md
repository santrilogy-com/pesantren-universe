# KARAKTER PRIMITIF — STATUS RONDE EXPORT BERIKUTNYA

**Oleh:** Kirana, Tim Karakter — **Selesai:** Rabu, 18 November 2026, ~00:54 WIB
**Lingkup:** proyek v2 SAJA (`~/workspace/pesantren-verse/v2/godot-dunia/`).
v1 tidak disentuh. File Blender karakter tidak disentuh (dihentikan Mas).
Tidak export, tidak deploy — ini bahan untuk ronde export berikutnya (Raka).

## Ringkasan

- **Audit karakter SESUDAH: 112 lulus, 0 gagal** (baseline terukur 106 lulus / 5 gagal).
- **Tes `skrip/test_v2.tscn`: 59 lulus, 1 gagal** — gagalnya `Kolong tertutup`,
  di luar konstruksi karakter (lihat § Tes). Sebelum restart VM sempat 60/0.
- **Foto SESUDAH: 29 PNG** (7 karakter × depan + tiga-perempat + belakang +
  close-up wajah + 1 grup), semua `err=0`, di `v2/foto-karakter-primitif/`.
- **Foto SEBELUM: 29 PNG** — lengkap, sudah ada sebelum edit (tidak diambil ulang).
- Konstruksi badan SAJA yang diubah. Fungsi animasi jalan/duduk (Eka),
  logika spawn/gender, dan semua sistem lain tidak disentuh.

## Baseline — koreksi angka awal

Info awal tugas menyebut baseline "99 lulus / 12 gagal". Yang terukur di disk
sebelum edit (headless, 17 Nov ~23:5x WIB): **106 lulus / 5 gagal** — dan
kelima gagal itu persis yang "nyata" di tugas: jilbab BoxMesh ×4 + lencana
satpam ×1. Tidak ada 7 gagal lain yang terukur. Total cek baseline 111,
sesudah 112: cek kedua lencana ("di dada kiri") baru jalan setelah node
`Lencana` ada — sebelumnya dilewati karena `lencana == null`.

## Perubahan (semua di `scripts/player.gd`, kecuali palet)

| # | Edit | Cara | Bukti |
|---|---|---|---|
| 1 | Jilbab tanpa kotak | `HijabDrape`: BoxMesh 0.50×0.75×0.06 → elipsoid pipih (bola r=0.28, skala 0.95/1.35/0.25, y 0.97..1.73, z −0.33..−0.19). `HijabSisiKiri/Kanan`: BoxMesh → kapsul vertikal r=0.045 tinggi 0.40 (bukaan wajah tetap 0.38) | Audit 4 cek jilbab lulus; foto `putri_belakang_sesudah.png`: drape membulat, tanpa sudut kotak |
| 2 | Lencana satpam | Node baru `Lencana` (cakram luar emas #e2b955 r=0.032 di (0.09, 1.22, 0.19) + cakram dalam #c9a227 + titik biru), aktif bila `outfit["lencana"]`; `OUTFIT_SATPAM` di `mission_data.gd` + `"lencana": true`; masuk dict `build_visual` | Audit 2 cek lencana lulus; foto `satpam_depan_sesudah.png`: lencana emas terbaca di dada kiri |
| 3 | Kacamata bundar | Bingkai kotak (4 batang BoxMesh) + lensa kotak → cincin `TorusMesh` (luar r=0.06, dalam r=0.048) + lensa cakram silinder r=0.05 bening alpha 0.35 + jembatan + gagang kapsul. Helper `_batang()` yang tak terpakai dihapus | Audit kacamata lulus (depan z 0.246, gagang s.d. z 0.14); foto `putra_wajah_sesudah.png`: cincin bundar, mata terlihat lewat lensa |
| 4 | Peci berkubah | Skala y peci 0.62 → 0.70 (puncak 1.934 → 1.956, total tetap < 2.10); band tetap mengikuti radius kubah | Foto `putra_tigaperempat_sesudah.png`: kubah membulat dari samping, bukan helm datar |
| 5 | Sandal + sol | Sandal #5a3a22 → #4a3226 (konsep). Sol gelap #2e1d12 (silinder r=0.105, tebal 0.012) sebagai anak node sandal — ikut skala sandal + ikut sembunyi saat sandal dilepas. Bawah sol dunia 0.009 | Audit sandal lulus; sol terbaca sebagai garis gelap di bawah sandal di foto tiga-perempat |
| 6 | Tangan kapsul | Tangan bola pipih (r=0.072, skala 1/0.7/1.3) → kapsul vertikal r=0.055 tinggi 0.12, skala z 0.8 (rentang −0.23..−0.35, menyatu lengan bawah; \|x\| pusat = lengan_x) | Audit 4 cek tangan lulus; foto depan: telapak menggantung natural di sisi badan |
| 7 | Jenggot Kyai | Jenggot dipanjangkan (skala y 0.85 → 0.95, pusat 1.51 → 1.50; bawah 1.35 → 1.32, melewati kerah) + uban ujung r=0.11 → 0.12. Mulut tetap di depan jenggot (z 0.197 vs mulut 0.210) | Foto `kyai_wajah_sesudah.png`: jenggot gelap + ujung beruban abu + kumis tipis, mulut tidak tertutup |
| 8 | Bahan kain | Helper baru `_bahan_kain(warna)`: tekstur cotton jersey Poly Haven CC0 (`models/cotton_jersey_diff_1k.jpg`, 581 KB — sudah diunduh sebelumnya), diwarnai per baju, roughness 0.85, uv1_scale 3. Dipakai torso + kerah + bahu + lengan + siku + abaya + seluruh jilbab. `_lembutkan()` diubah: bahan bertekstur dibiarkan (batik 0.45, kain 0.85), hanya bahan polos dilembutkan ke 0.45. `terapkan_outfit()` memakai `_bahan_kain` yang sama supaya ganti baju tidak mengembalikan kain jadi polos | Foto: koko/abaya/jilbab tidak lagi plastik polos (tenun halus; paling terbaca di close-up wajah putra — tekstur koko di bahu/dada) |

## Palet konsep (`scripts/mission_data.gd`)

Mengikuti `KONSEP-KARAKTER.md`: `OUTFIT_DEFAULT` koko #faf7f0 → **#e8e8e8**,
sarung #0b6b4f → **#008062**, kulit #c68e5e → **#ffc09f**; `OUTFIT_KYAI`
kulit #c68e5e → **#d59e78** (lebih gelap dari santri). Bilal/Faris di
`main.gd` menimpa kulit sendiri — tidak kena dampak. `OUTFIT_USTADZAH`
dan `OUTFIT_SATPAM` tidak diubah warnanya (tidak ada instruksi konsep).
`Palette.EMAS` global TIDAK diubah (dipakai seluruh game); emas konsep
#e2b955 hanya dipakai di lencana baru.

## File yang diubah

- `scripts/player.gd` — 8 edit di atas (konstruksi `build_visual` +
  `_kacamata()` + `_bahan_kain()` + `_lembutkan()` + `terapkan_outfit()`).
  Fungsi animasi jalan/duduk (`_physics_process`, `_terapkan_pose`,
  `AnimasiMixamo`) dan logika spawn/gender TIDAK disentuh.
- `scripts/mission_data.gd` — 3 konstanta outfit (di atas).
- Tidak ada file baru yang menetap: probe kolong sementara sudah dihapus
  (`skrip/probe_kolong.*`).

## Tes

- **Audit karakter** (`skrip/audit_karakter_primitif.tscn`, headless):
  baseline 106/5 → **sesudah 112/0**. Dijalankan ulang setelah VM restart
  00:28 WIB: tetap 112/0.
- **Tes v2** (`skrip/test_v2.tscn`, headless): sebelum restart 60/0;
  setelah restart **59/1** — `GAGAL: Kolong tertutup (dapat (24.41094,
  -0.312738, 30.0))`. BUKAN dari edit karakter (tidak ada collision shape
  yang disentuh; `build_visual` hanya MeshInstance3D visual).
  - Probe fokus (`skrip/probe_kolong.*`, sudah dihapus): teleport +
    dorong +X 60 frame persis seperti tes, **3× TERTUTUP**
    (start (23.58906, −0.00779, 30.0) → akhir (23.58906, ~0, 30.0)).
    Teleport mendarat menempel dinding lalu didepenetrasi ke barat
    (23.589) sebelum dorongan — dinding kolong bekerja.
  - Kesimpulan: 1 gagal itu **flaky di bawah beban VM ekstrem** (saat itu
    load ~7, RAM ~97% penuh, 8 proses Godot jalan bersamaan; rerun penuh
    sempat melambat sampai 0:35 CPU dalam 16 menit wall sehingga
    dihentikan dan diganti probe). Bukan regresi karakter.
  - Diserahkan ke Raka / Alur B (tabrakan): kalau mau dikejar, arahnya
    teleport yang mendarat menabrak dinding tipis (depenetrasi bisa
    terlempar ke sisi yang salah) — bukan konstruksi karakter.
- `nice -n -10` dipakai untuk run tes/foto; setelah restart VM perintah
  itu jalan (sebelum restart sempat `Permission denied` sekali).

## Foto — verifikasi visual (aturan anti-tembus: 360° + close-up)

Diperiksa langsung: putra depan/wajah/tiga-perempat, putri depan/belakang,
kyai depan/wajah, ustadzah depan, satpam depan, grup depan. Tidak ada
intersection yang terlihat pada bagian yang diubah: kacamata di depan
wajah (tidak menembus kepala), peci menempel 360°, drape jilbab di
belakang wajah, lencana menempel di dada (belakang cakram 0.002 di dalam
torso), tangan menyatu lengan bawah, sandal menyentuh tanah.

Catatan jujur (bukan regresi — semuanya sudah begitu di foto SEBELUM,
geometrinya tidak disentuh ronde ini):

- **Cape jilbab** (putri/ustadzah) terbaca seperti piring/nampan datar di
  sekeliling bahu, terutama dari depan/belakang. Geometri lama
  (bola r=0.40 skala y 0.28) — kalau mau diperbaiki, itu ronde sendiri.
- **Serban Kyai**: sambungan antar lilitan terbaca sebagai garis putus
  tipis di close-up wajah. Geometri lama.
- **Motif batik sarung gelap** (Kyai, satpam): kontras hitam-putih sangat
  kuat, terbaca seperti zebra. Motif prosedural lama (pita terang =
  lerp ke krem) — bukan dari edit ini.
- **Foto grup** (`semua_depan_*`): putra (kiri) dan satpam (kanan)
  terpotong di tepi frame — framing skrip foto lama (kamera terlalu
  dekat untuk rentang x −9..+9). Sama persis di SEBELUM; per karakter
  tetap lengkap, jadi tidak diambil ulang.

## Untuk Raka (ronde export berikutnya)

- Kode karakter di atas siap masuk export — audit 112/0, test_v2 hanya
  menyisakan 1 gagal flaky kolong di luar karakter.
- Kalau export ulang: tidak ada yang perlu ditahan dari sisi karakter.
  Perhatian: `main.gd` dan file area putri sedang diedit paralel tim lain
  (mtime 00:31–00:47 WIB saat ronde ini jalan) — pastikan export memakai
  snapshot yang sudah dikunci, bukan file yang sedang ditulis.
- Sisa yang masih menunggu (bukan bagian ronde ini): verdict Mas atas
  foto sesudah; perbaikan cape jilbab + garis serban + batik gelap kalau
  Mas minta; animasi jalan/duduk tetap ranah Eka.
