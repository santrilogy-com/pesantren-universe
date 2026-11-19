# TABRAKAN DUNIA — Status Audit (Bagas, 18 Nov 2026)

Tugas Mas (00:18 WIB, 18 Nov 2026): sebagian benda masih bisa ditembus —
tiang dan pohon bisa dilewati pemain. Audit SEMUA objek dunia: tiap objek
padat WAJIB punya collision yang menahan pemain. Scope: proyek v2 saja,
pemain saja (NPC tembus = scope Eka). Jangan deploy.

## Ringkasan hasil

| Run | LULUS | GAGAL | Catatan |
|-----|-------|-------|---------|
| Baseline (17 Nov) | 13 | 28 | 41 probe; tiang + pohon + perabot tembus |
| fix1 | 9 | 49 | Harness rusak (kalibrasi tak di-await) — hasil palsu |
| fix2 | 44 | 14 | Harness diperbaiki; 14 gagal dianalisis |
| fix3 | 50 | 8 | Bak diperbaiki; tiang/pohon/pilar jadi kotak |
| **fix4 (akhir)** | **56** | **2** | Kriteria penetrasi untuk tiang; frame ditambah |
| **fix5 (Bagas-2, 18 Nov)** | **58** | **0** | **AUDIT BERSIH** — 2 gagal fix4 ternyata artefak ekspektasi, bukan geometri (lihat § fix5) |

**Sisa 2 GAGAL fix4 — keduanya BUKAN collision saya:**
1. **Kolong gubuk sawah (26,30)** — pemain menembus dinding kolong
   selatan ~1,03 m (tempuh 2,09 vs ideal 1,06). Bug nyata di
   `scripts/gubuk_masuk.gd` (Dewa/Raka) — cocok dengan temuan test_v2
   Rangga ("Kolong tertutup": selip 0,41 m + 0,09 m di bawah lantai).
   **Dilaporkan ke Raka, tidak saya perbaiki.**
2. **Jalan E-W tengah (tangga Surau menahan)** — pemain berhenti di
   x=-3,35 (tempuh 16,65 vs ideal lama 16,05). Ternyata BUKAN tembus:
   di z=0 yang menghadang adalah segmen 3 ramp (lebar 6,0, muka barat
   x=-3,0 — bukan segmen 1 lebar 7,2). Berhenti di -3,35 = -3,0+0,35
   — TEPAT di muka ramp. Ekspektasi probe salah (16,4 → 17,0),
   sudah diperbaiki di skrip. Tangga MENAHAN (jalan E-W memang
   tertutup tangga+serambi Surau — lihat § Jalan).

## fix5 (Bagas-2, 18 Nov 2026) — audit bersih 58/0

Kedua GAGAL fix4 terbukti **artefak ekspektasi probe, BUKAN cacat
geometri** — tidak ada perubahan di `scripts/gubuk_masuk.gd` maupun
logika probe lain. Satu baris diubah di
`skrip/test_tabrakan_dunia.gd` baris 114 (probe kolong selatan):

- `jarak_muka` 1,41 → **2,44**; komentar "muka selatan dinding
  32,59" → **31,56**.
- Bukti (Dewa-3, terverifikasi di scene hidup): dinding kolong
  selatan ADA — size (4,0, 1,2, 0,12), pos (26,0, 0,6, 31,5),
  muka luar z=31,56. Spawn (26,0,34) → muka = 2,44 m; ideal benar
  2,44 − 0,35 (radius kapsul) = **2,09** = persis tempuh yang diukur
  fix4. Posisi berhenti z=31,91 = 31,56 + 0,35, tepat di muka dinding.
  "Tembus 1,03 m" = galat jarak_muka probe sendiri.
- Jalan E-W tengah juga LOLOS tanpa perubahan (tempuh 16,65 =
  ideal 16,65; berhenti x=−3,35 di muka ramp segmen 3) — ekspektasinya
  sudah diperbaiki di fix4.

**Rerun headless 1×: HASIL TABRAKAN: 58 LULUS, 0 GAGAL**
(log `/tmp/test_tabrakan_bagas2.log`). Kolong: tempuh=2,09 ideal=2,09
akhir=(26,0, −0,000921, 31,91094). **Sisa gagal: 0 — audit tabrakan
BERSIH.** Temuan #4 di § "Temuan untuk orang lain" (kolong tembus
~1,03 m) dan butir kolong di § "Sisa untuk Raka" dinyatakan SELESAI
sebagai artefak — test_v2 Rangga "Kolong tertutup" (selip 0,41 m)
adalah temuan terpisah di harness lain, bukan temuan audit ini.

## Cara kerja probe

Skrip dedikasi `skrip/test_tabrakan_dunia.gd` + `.tscn` (JANGAN edit
`skrip/test_v2.gd`). Pemain di-teleport ke depan objek lalu didorong
lurus memakai joystick berkamera (kalibrasi arah dulu, pola test_v2).
Dua kriteria:

- **`_cek_tahan` (dinding/kotak/perabot):** tempuh maksimum sepanjang
  arah dorong harus berhenti di muka objek (ideal = jarak muka − 0,35,
  toleransi −0,6 / +0,1). Cocok untuk objek lebar — pemain tidak bisa
  mengelilinginya dalam 90 frame.
- **`_cek_tiang` (tiang/pohon/pilar, baru fix4):** jarak MINIMUM pusat
  pemain ke pusat objek (bidang XZ) harus ≥ `jaga` (setengah lebar muka
  + 0,35 kapsul − 0,05 toleransi). Tembus = pemain lewat sumbu objek
  (min_jarak ~0). Tergelincir mengelilingi = min_jarak ~jaga+0,05 —
  itu defleksi, bukan tembus (lihat § Slip).

`_cek_lewat` (jalan/celah): pemain harus menempuh jarak jauh tanpa
halangan. Role `keamanan` dipakai di tes supaya `_cek_batas` (putra
dilarang masuk area putri) tidak menarik pemain saat probe.

## Tabel per kelas objek

### Tiang & pohon (prioritas Mas)

| Objek | Baseline | Perbaikan | fix4 |
|-------|----------|-----------|------|
| Tiang lampu jalan Cahya (4: -2,5,±10/±30, -6,89,-2,67) | TEMBUS (visual saja) | Kotak terinskripsi 0,141×3,0 (sisi = r·√2, r=0,10) di `pesantren_builder.gd::_lamp` | LULUS — min_jarak 0,42–0,43 ≥ jaga 0,37 |
| Pohon hias `_tree` (batang r≈0,16) | LULUS (silinder lama r=0,25) | Kotak terinskripsi 0,283×1,6 | LULUS — min 0,50–0,59 ≥ jaga 0,44 |
| Pohon rindang `_tree` + 10 penyangga (batang r≈0,30) | TEMBUS (10 penyangga tanpa collision; `_tree` jauh terkonfound `_cek_batas`) | Kotak terinskripsi 0,453×1,6 | LULUS — min 0,58 ≥ jaga 0,53 |
| Pohon taman GLB (batang r≈0,16) | TEMBUS | Kotak terinskripsi 0,283×1,8 | LULUS — min 0,50 ≥ jaga 0,44 |
| Tiang papan plot (r=0,06) | TEMBUS | Kotak terinskripsi 0,127×1,6 | LULUS — min 0,41 ≥ jaga 0,36 |
| Pilar barat Musholla (r=0,22) | TEMBUS | Kotak terinskripsi 0,311×4,0 | LULUS — min 0,53 ≥ jaga 0,46 |
| Tiang serambi Musholla (r=0,12–0,14) | TEMBUS | Kotak terinskripsi 0,212×3,0 | LULUS — min 0,47 ≥ jaga 0,41 |
| Pilar sudut interior Surau (r=0,22) | TEMBUS | Kotak terinskripsi 0,311×4,6 | LULUS — min 0,57 ≥ jaga 0,46 (diagonal, lihat § Slip) |
| Tiang serambi Surau (0,4×0,4) | TEMBUS | Kotak 0,4×2,5×0,4 | LULUS — tempuh 0,75 / 0,65 = ideal |

### Pagar & tembok

| Objek | Baseline | Perbaikan | fix4 |
|-------|----------|-----------|------|
| Pagar bata GLB (z=39, 8 panel + pilar) | TEMBUS | Kotak panjang (32, 0,96, 0,2) + 17 kotak pilar 0,42 | LULUS — tempuh 3,44 (ideal 3,55) |
| Pagar kayu Musholla | TEMBUS ("visual saja") | Kotak per segmen (y 0,5); celah selatan x 133..135 + celah timur z −20,25..−17,75 TETAP TERBUKA | LULUS — tempuh 2,57 = ideal; kedua celah LULUS (lewat) |
| Tembok x=14 + barrier gerbang | LULUS (regresi) | — (sudah benar) | LULUS — tempuh 3,45 |
| Tembok keliling putri (x 115..216, z −70..+40, diperluas Mira) + barrier gerbang putri | LULUS (regresi) | — (sudah benar) | LULUS — tembok timur 2,45; barrier 2,45 |

### Bangunan — Surau GLB & taman

| Objek | Baseline | Perbaikan | fix4 |
|-------|----------|-----------|------|
| Menara Surau (alas 2,4 + badan 1,7) | TEMBUS | 2 kotak lokal (diputar seperti dinding) | LULUS — tempuh 2,60 = ideal |
| Bak wudu (0,8×3,0) | "LULUS" PALSU (pemain berhenti di dinding barat) | Kotak — **sempat TERBALIK** (0,8, 0,95, 3,0) → diperbaiki fix3 jadi (3,0, 0,95, 0,8) lokal | LULUS — tempuh 1,65 = ideal |
| Pot serambi (0,5×0,4) | TEMBUS | Kotak 0,5×0,45×0,5 | LULUS — tempuh 1,20 = ideal |
| Peti taman (0,28) | LULUS (regresi) | — | LULUS — tempuh 3,27 = ideal |
| Bangku taman 1 (−3, 25,45) | TEMBUS — dan menutupi sumbu pintu taman | Gilang geser 3 m ke barat (opsi a Raka); saya tambah kotak 1,8×0,5×0,55 | LULUS — tempuh 2,42 (ideal 2,43) |
| Bangku taman 2 (3,45, 28,2) | TEMBUS | Kotak 0,55×0,5×1,8 | LULUS — tempuh 1,82 = ideal |
| Dinding Surau GLB (5 segmen), dinding Cangkruk, pos jaga | LULUS (regresi) | — | LULUS |
| Kolong gubuk sawah (Dewa) | LULUS (dari dalam) | — (bukan ranah saya) | **GAGAL — tembus 1,03 m dari luar (lihat § Sisa)** |

### Perabot interior

| Objek | Baseline | Perbaikan | fix4 |
|-------|----------|-----------|------|
| Rak Surau barat/timur | TEMBUS | Kotak 0,4×1,9×1,85 | LULUS — 1,25 = ideal |
| Meja sampar Surau (oval 2,2×1,21) | TEMBUS (Mas pernah komplain "Ini kok tembus meja?") | Kotak 1,5×0,5×0,8 | LULUS — 1,40 / 1,75 = ideal |
| Rehal Kyai | TEMBUS | Kotak 0,45×0,4×0,35 | LULUS — 0,92 (ideal 0,97) |
| Smartboard Surau | "LULUS" PALSU (muka papan 0,085 dari dinding) | Kotak 0,14×2,4×4,6 | LULUS — 1,43 = ideal (head-on dari timur) |
| Mihrab Surau | TEMBUS | Kotak 1,6×2,4×0,2 | LULUS — 1,45 (ideal 1,46) |
| Lemari Cangkruk | TEMBUS | Kotak 0,55×2,2×1,6 (LEMARI_SPOT tetap terjangkau, jeda 0,375 m) | LULUS — 1,77 = ideal |
| Meja kecil Cangkruk | TEMBUS | Silinder r=0,45 h=0,6 (meja bundar) | LULUS — 1,40 = ideal |
| Rak Musholla | — (sudah ada collision via RakBukuPutri Dewi) | TIDAK disentuh | LULUS — 1,46 / 1,47 (ideal 1,48) |
| Meja Musholla | TEMBUS | Kotak 1,2×0,5×0,7 | LULUS — 0,80 = ideal (dari utara) |
| Rehal Ustadzah | TEMBUS | Kotak 0,45×0,4×0,35 | LULUS — 1,42 = ideal |
| Smartboard Musholla | TEMBUS | Kotak gabungan 0,12×2,65×3,0 | LULUS — 1,39 = ideal |
| Mihrab Musholla | TEMBUS | Kotak 0,2×2,6×1,4 | LULUS — 1,40 = ideal |
| Papan plot (4,2×1,0) | TEMBUS | Kotak 4,2×1,0×0,12 | LULUS — 3,19 = ideal |

### Jalan & pintu (harus LEWAT, bukan tertahan)

| Objek | Hasil fix4 |
|-------|------------|
| Jalan N-S bebas (0,20)→pintu Surau | LULUS — tempuh 316,96 (teleport masuk Surau) |
| Jalan E-W detour utara Surau z=−25 | LULUS — tempuh 33,45 (sampai tembok x=14) |
| Jalan internal putri (142,14)→(142,−28) | LULUS — tempuh 47,40 |
| Pintu taman — otomatis (NPC abaikan / NPC nyata) | LULUS — masuk z=27,26–27,27, kemajuan 1,00 |
| Pintu taman — ditahan terbuka / tertutup | LULUS — terbuka sampai peti; tertutup tertahan z=25,09 |

## Fenomena slip silinder/kotak tipis (temuan utama fix2–fix4)

Pemain yang didorong lurus 1,5–2,5 detik ke tiang tipis BISA
tergelincir mengelilinginya — lampu (−2,5,30), pohon hias (−10,−8),
pilar interior, pilar Musholla — semuanya lolos dari muka kotak dan
berhenti di objek berikutnya. Ini BUKAN drive miring: diagnosis
`skrip/diag_drift.gd` membuktikan drive lurus sempurna di tanah
terbuka (drift lateral 0,00–0,01 m ke segala arah). Ini fisika kontak:
kapsul (r=0,35) yang menekan muka sempit (0,14–0,31 m) selama
1,5 detik akan meluncur ke sisi — makin tipis mukanya, makin mudah.

**Perbaikan yang diterapkan:**
- Silinder tipis → **kotak terinskripsi** (sisi = r·√2, tidak pernah
  melebihi visual) untuk semua tiang/pohon/pilar. Muka datar menahan
  lebih andal daripada silinder, tapi tetap tidak bisa menahan
  dorongan 1,5 detik penuh pada muka 0,14 m.
- Kriteria probe diubah: untuk tiang/pohon/pilar yang diukur adalah
  **penetrasi** (`_cek_tiang`), bukan proyeksi. Pemain yang
  tergelincir mengelilingi TIDAK PERNAH menembus objek (kapsul tidak
  tumpang tindih) — itu defleksi yang benar untuk tiang tipis
  (pemain di permainan nyata akan memutar, bukan menembus). Tembus
  (tanpa collision) = pemain lewat sumbu objek (min_jarak ~0).
  Nilai fix4: lampu 0,42–0,43; hias 0,50–0,59; rindang 0,58; pilar
  0,53–0,57 — semuanya di atas jaga (0,36–0,53) dengan margin
  0,05–0,15, persis jarak muka/sudut kotak + kapsul.

**Catatan jujur untuk Mas/Raka:** tiang tipis TIDAK BISA menahan
pemain yang mendorong joystick lurus 1,5 detik penuh — pemain akan
meluncur mengelilinginya (seperti memutar tiang di dunia nyata).
Yang sudah diperbaiki: pemain TIDAK BISA lagi jalan TEMBUS
(lurus menembus tiang/pohon). Kalau Mas mau tiang benar-benar
"mengunci" pemain, perlu halo collision lebih lebar dari visual —
itu keputusan desain, bukan bug.

## Bug perbaikan saya sendiri (bak wudu terbalik)

Kotak bak wudu di `_surau_glb` sempat saya tulis terbalik: dimensi
lokal (0,8, 0,95, 3,0) dirotasi −90° menjadi dunia (3,0 X, 0,8 Z),
padahal bak memanjang 3,0 m arah Z dunia. Probe fix2 menangkapnya
(tempuh 2,75 vs ideal 1,65 — pemain berhenti di muka yang salah).
Diperbaiki fix3 jadi (3,0, 0,95, 0,8) lokal → dunia (0,8 X, 3,0 Z).
Pelajaran: kotak GLB yang diputar harus dicek sumbunya satu per satu;
yang berbentuk persegi (menara, tiang, pot) tidak terpengaruh.

## Pengecualian yang didokumentasikan (sengaja tanpa collision)

- **Kasur (Cangkruk + Asrama):** TANPA collision — tidur = teleport
  ke atas kasur (`main.gd`); collision penuh akan menendang pemain
  saat tidur/bangun.
- **Sawah / pematang / bedeng bunga / semak / batu dekor:** dilewati,
  sengaja (lahan garapan & dekor rendah; pematang 0,4 m tak bisa
  dilangkahi kapsul bila diberi collision).
- **Daun pintu + BlokPortal Surau:** tanpa collision — pintu harus
  tetap bisa dilewati; rak/dampar di DALAM GLB Surau tak terjangkau
  pemain (cangkang luar saja).
- **Gunung:** sudah ada collision silinder (jejari 70%) — verifikasi
  kode saja (jarak ±350 m, tidak diprobe).

## Temuan untuk orang lain (LAPOR ke Raka, jangan diperbaiki diam-diam)

1. **Pintu taman (Gilang):** mekanisme pintu BEKERJA (4/4 sub-probe
   lolos). Bug "taman tidak bisa dimasuki" kemungkinan besar
   TIMING/UX: pintu butuh ~1,3 detik membuka (geser 1,6 m/dtk × 2,1 m),
   pemain jalan 6 m/dtk tiba dalam ~0,43 detik dan harus menunggu
   ~1 detik di gerbang — di HP terasa "kehalang benda". Ditambah
   intermittent: NPC di jalur geser membekukan pintu
   (`jalur_terhalang`). Saran: naikkan KECEPATAN_GESER atau mulai buka
   lebih awal (JARAK_BUKA 2,6 → lebih besar). Keputusan Gilang.
2. **Tangga Surau menutup sumbu jalan E-W (Rangga/Sinta):** jalan E-W
   z=0..1,1 DITUTUP tangga+serambi Surau (tangga 3 segmen, lebar
   7,2/6,6/6,0). Pemain harus memutar lewat utara (z=−25, di luar
   dinding utara Surau z=−24) atau naik tangga → serambi → turun sisi
   timur. Bukan bug collision — Surau duduk di jalur jalan.
   Lantai serambi: pemain JATUH di baseline (y=0,305) tapi tetap di
   fix2/fix3/fix4 (y=0,5) — flaky, area Rangga.
3. **Papan plot Ruang Kelas menembus PosSatpam (Raka/Bima):** papan di
   (16,4,6) ada DI DALAM footprint pos satpam (17,5); tiang barat
   (14,4,6) DI DALAM tembok x=14. Collision tetap ditambahkan
   (membuat fakta visual menjadi fisik), tapi papan/pos perlu digeser
   — keputusan Raka/Bima. Papan ini TIDAK BISA diprobe (terhalang
   dinding pos/tembok dari keempat arah); probe memakai plot Asrama.
4. **Kolong gubuk sawah (Dewa/Raka):** pemain menembus dinding kolong
   selatan ~1,03 m dari luar (fix4) — cocok dengan test_v2 Rangga
   ("Kolong tertutup": selip 0,41 m + 0,09 m di bawah lantai).
   Pemain 1,7 m juga tidak muat di kolong 1,32 m (teleport ke dalam
   malah menjepit pemain di lantai gubuk). File `gubuk_masuk.gd`.
5. **Bangku 1 taman** sudah digeser Gilang 3 m ke barat (opsi a Raka)
   — kini di luar sumbu pintu, collision aman ditambahkan. Catatan:
   bangku sebagian menutupi bedeng bunga (kaki di atas bedeng);
   kalau dinilai janggal, perlu edit GLB (Bima).
6. **Cangkruk Putri dihapus; tembok keliling putri diperluas** ke
   x 115..216, z −70..+40 (Mira/Nadia) — probe dinding timur (216,0)
   adalah baseline dinding yang diperluas. Jangan tambah
   collision/probe ke Cangkruk Putri.

## Foto bukti

Folder `~/workspace/pesantren-verse/v2/foto-tabrakan/` — kamera game
sendiri, lanskap 1280×720, siang paksa jam 10:00
(`LangitDinamis.debug_jam`, hook resmi tes/foto), posisi berhenti
memakai nilai `akhir` probe fix3/fix4. Skrip:
`skrip/foto_tabrakan.gd` + `.tscn` (arg `-- N` = foto pertama).

| Foto | Isi | Verifikasi saya |
|------|-----|-----------------|
| F1-lampu-jalan.png | Pemain (Faris) tertahan di tiang lampu (−2,5,10), Surau di belakang | BAGUS — tiang + pemain jelas (malam, lampu menyala) |
| F2-pohon-rindang.png | Pemain tertahan di batang pohon rindang (35,5) | BAGUS — siang, pemain + batang + tajuk jelas |
| F3-pagar-bata.png | Pemain tertahan di pagar bata (−16,39) | BAGUS — siang, pemain + pagar bata + pilar jelas |
| F4-bangku-taman.png | Pemain di taman, di muka selatan bangku 2 (3,45,29,45), bidikan curam dari atas | CUKUP — pemain + taman jelas; bangku (rendah 0,5 m) tidak tajam terlihat dari sudut ini — bukti utama bangku adalah angka probe (1,82 = ideal) |
| F5-pilar-musholla.png | Pemain tertahan di pilar barat Musholla (128,3,−28,7) | CUKUP — pemain + dinding Musholla + pagar kayu jelas; pilar krem tipis menyatu dengan dinding terang — bukti utama pilar adalah angka probe (min_jarak 0,53 ≥ 0,46) |

Catatan foto: 3x retake (malam terlalu gelap; kanopi pohon
(−30,34) dan pohon taman (−2,2,27,4) tepat di sumbu kamera 7 m
— spring kamera DINAMIS, set manual ditimpa `kamera.gd` tiap frame,
jadi posisi foto dipilih menghindari pohon di sumbu kamera).

## File yang diubah (hanya collision, sisi kode builder)

- `scripts/pesantren_builder.gd` — helper `_tabrakan_kotak` /
  `_tabrakan_silinder` (sudah ada); `_lamp`, `_tree`, `_lingkungan_glb`
  (pagar bata, 10 rindang, taman), `_surau_glb` (isi_surau + bak),
  `_plot` (papan + tiang).
- `scripts/kampus_putri.gd` — pilar barat + tiang serambi Musholla,
  `_pagar_kayu` (kotak per segmen).
- `scripts/interior_surau.gd` — 4 pilar, mihrab, smartboard, rak,
  meja sampar, rehal.
- `scripts/interior_cangkruk.gd` — lemari, meja kecil (kasur sengaja
  tanpa collision).
- `scripts/interior_musholla.gd` — smartboard, meja, rehal, mihrab
  (rak TIDAK disentuh — RakBukuPutri Dewi sudah punya collision).
- Semua file lolos `--check-only`. TIDAK ADA file orang lain disentuh
  (`tangga_surau.gd`, `pintu_taman.gd`, `gubuk_masuk.gd`, `npc.gd`,
  `test_v2.gd`, v1). TIDAK ADA deploy.

## File tes & log

- Tes: `skrip/test_tabrakan_dunia.gd` + `.tscn` (58 probe, mode
  gabungan putra+putri, role `keamanan`).
- Diagnosis: `skrip/diag_drift.gd` + `.tscn` (drive lurus 0,00 m),
  `skrip/diag_gerak.gd` + `.tscn`, `skrip/dump_glb_tabrakan.gd` +
  `.tscn`, `skrip/ukur_frame_rate.gd` + `.tscn` (sementara — boleh
  dihapus setelah audit selesai).
- Foto: `skrip/foto_tabrakan.gd` + `.tscn`.
- Log: `/tmp/tabrakan_putra.log` (baseline 13/28),
  `/tmp/tabrakan_fix1.log` (9/49, harness rusak),
  `/tmp/tabrakan_fix2.log` (44/14), `/tmp/tabrakan_fix3.log` (50/8),
  `/tmp/tabrakan_fix4.log` (**56/2**), `/tmp/diag_drift.log`,
  `/tmp/test_tabrakan_bagas2.log` (**58/0**, fix5).

## Sisa untuk Raka

- Kolong gubuk (Dewa): ~~dinding kolong selatan tembus ~1 m — perlu
  perbaikan di `gubuk_masuk.gd` (ronde Raka)~~ — **SELESAI fix5:
  artefak ekspektasi probe** (dinding ADA di z=31,56; tempuh 2,09 =
  ideal; audit 58/0). Tidak ada perbaikan geometri.
- Papan plot Ruang Kelas vs PosSatpam: geser papan atau geser pos
  (keputusan Raka/Bima).
- Pintu taman: pertimbangkan buka lebih cepat/awal (Gilang).
- Tiang tipis: kalau Mas mau tiang "mengunci" pemain (tidak bisa
  meluncur mengelilingi), perlu halo collision lebih lebar dari
  visual — keputusan desain.
