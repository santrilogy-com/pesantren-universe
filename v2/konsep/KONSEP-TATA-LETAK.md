# KONSEP TATA LETAK v2 — Pesantren Universe

**Tim Maps (Gilang) — 17 Nov 2026. Sketsa 2D saja, belum dibangun 3D.**

- Gambar: [peta-tata-letak-v2.png](sandbox://workspace/pesantren-verse/v2/konsep/peta-tata-letak-v2.png) (2743×1819, top-down, warna datar palet PV: krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A`)
- Skrip gambar (bisa digambar ulang bila ada revisi): `buat_peta.py`
- Dasar: tata letak v1 **Opsi A** (live Ronde 23) — `maps/ROADMAP-MAPS.md` + `organisasi/STRUKTUR-ORGANISASI.md`
- Sistem koordinat game: **x+ = timur, z+ = selatan, utara = −z** (atas peta). Kiblat = utara.

---

## Revisi — Surau LURUS (Mas, 17 Nov ~22:51 WIB — keputusan final)

- **Surau sekarang LURUS (sejajar sumbu peta)** — tidak miring lagi. Sebelumnya diputar −25° (kiblat 295°). Di game rotasi GLB-nya −90° (bukan 0° — muka depan GLB ada di sisi lokal +X; temuan Rangga 23:19, tes 23/23).
- **Matahari yang menyesuaikan ke arah barat** — bukan bangunan yang diputar. Kalibrasi azimut matahari dilakukan di game (tugas tim game/Rangga, bukan bagian peta ini).
- **Alasan Mas:** "Surau lurus aja. Jangan miring. Biar matahari yg menyesuaikan dg arah barat. Surau lurus seperti masjid."
- **Pusat Surau diselaraskan ke (0,−14)** (pusat live v1; sebelumnya di peta ini jangkar lokal (0,−12)).
- **Interior Surau TIDAK berubah** — mihrab/kiblat di dalam tetap seperti semula; yang berubah hanya penempatan di peta + arah matahari.
- **Dampak ke U2:** Surau lurus menjorok sampai z=−24 — jejak terverifikasi Rangga 23:19: 16 m (timur–barat) × 20 m (utara–selatan), depan z=−4, belakang z=−24 (sebelumnya diperkirakan z=−22); plot Masjid Besar lama (0,−26) tumpang tindih ±6 m, jadi usulan geser ke (0,−38) tetap diperlukan — celah plaza Surau–Masjid jadi 6 m (sebelumnya diperkirakan 8 m; sebelum revisi 6,5 m).
- Peta digambar ulang dari `buat_peta.py` (nama file sama: `peta-tata-letak-v2.png`); semua bangunan lain TIDAK digeser.
- **Koreksi ukuran 23:19 (Gilang):** jejak Surau diperbaiki jadi 16×20 di kedua peta (v2 + masterplan) + tabel koordinat + U2; file lama dibackup (`*_sebelum-koreksi-surau-16x20.png`).

---

## Masterplan — Pesantren Percontohan (Mas, 17 Nov ~22:56 WIB)

**Visi Mas:** "Tata letak yg rapi.. saya ingin membangun pesantren yg indah dan bisa jadi percontohan. Rencanakan gedung asrama 3 lantai, kelas 5 lantai pakai lift dan eskalator, klinik, balai tamu dll. Harus rapi.. jalan, gedung semuanya rapi."

- Gambar BARU: [peta-tata-letak-v2-masterplan.png](sandbox://workspace/pesantren-verse/v2/konsep/peta-tata-letak-v2-masterplan.png) (2743×1819, gaya sama dengan peta v2). Skrip gambar: `buat_masterplan.py`. Peta lama `peta-tata-letak-v2.png` TIDAK ditimpa — Mas bisa membandingkan.
- Ini KONSEP dulu — belum 3D. Semua bangunan baru di bawah ini adalah rencana; posisi dan ukuran boleh direvisi Mas.

### Prinsip kerapian masterplan
1. **Jalan lurus sejajar grid** — semua jalan sejajar sumbu N–S atau E–W; tidak ada jalan miring/diagonal.
2. **Bangunan sejajar sumbu** — semua gedung tegak lurus sumbu peta (tidak ada yang miring, termasuk Surau — revisi 22:51).
3. **Zona jelas** — 5 zona: Ibadah (utara + tengah), Pendidikan (barat laut putra + dalam kampus putri), Asrama (selatan sumbu E–W, kedua area), Layanan (sepanjang jalan N–S selatan, kawasan bersama), Hijau & Olahraga (sawah/kebun/kolam/lapangan + zona penyangga).
4. **Plaza di depan gedung besar** — plaza Surau–Masjid (sudah ada), plaza Klinik/Dapur/Koperasi/Balai Tamu (baru).
5. **Batasan yang dipertahankan** — tembok x=14 + gerbang + pos satpam; tembok keliling putri; spawn putra (−4,14); Surau lurus (0,−14); geser Masjid Besar lama ke (0,−38) DIGANTI oleh Masjid Besar baru di tengah (lihat bawah).

### Gedung baru — tabel koordinat masterplan

| Bangunan | Ukuran (m) | Koordinat | Keterangan |
|---|---|---|---|
| Masjid Besar (pusat) | 54×44 | **(64,−24)** | BARU — pusat pesantren, ±2.000 jama'ah (lihat alasan penempatan di bawah) |
| Wudhu Putra (Masjid Besar) | 8×6 | (30,−6) | BARU — di luar masjid, sisi barat |
| Wudhu Putri (Masjid Besar) | 8×6 | (98,−6) | BARU — di luar masjid, sisi timur |
| Asrama Putra — 3 lantai | 20×12 | **(−24,10)** | GANTI plot lama 14×10 — kapasitas ±96 santri |
| Asrama Putri — 3 lantai | 20×12 | **(156,10)** | TAPAK CADANGAN (garis putus-putus di peta) — DITUNDA, keputusan Xam 18 Nov 13:19: dibangun bila Asrama 1 (±96) penuh; gedung saat ini tetap 12×8, 1 lantai di (152,9) |
| Kelas Putra — 5 lantai | 20×12 | **(−44,−14)** | GANTI plot lama 12×9 — lift + eskalator di pintu masuk selatan |
| Kelas Putri — 5 lantai | 20×12 | **(128,10)** | TAPAK CADANGAN (garis putus-putus di peta) — DITUNDA, keputusan Xam 18 Nov 13:19: dibangun bila santri putri ≥ 25 (ambang Kelas); gedung saat ini tetap 10×8, 1 lantai di (130,10) |
| Klinik | 12×8 | (16,44) | BARU — kawasan bersama, timur jalan N–S |
| Balai Tamu | 14×10 | (12,74) | BARU — tepat di dalam Gerbang Utama (0,80) |
| Koperasi / Toko Santri | 10×8 | (−10,32) | BARU — barat jalan N–S, antara Perpustakaan & Kantin |
| Dapur Umum | 12×8 | (16,36) | BARU — timur jalan N–S, dekat Kantin |
| Gudang | 10×8 | (−51,62) | BARU — barat daya, tepi jalan barat x=−58 |
| Tempat Wudhu (Surau) | 8×6 | (−16,−8) | BARU — barat Surau, dekat plaza |
| Tempat Wudhu Putri (kampus putri) | 8×6 | (122,−24) | BARU — barat Musholla Ar-Raudhah, diputuskan Mas 18 Nov 18:27 WIB (usulan utama Tim Maps; alternatif (134,−35) tidak dipakai). Di peta label digeser ke utara kotak karena label Musholla menjorok ke x=123 |
| Taman Surau | 20×16 | (0,−38) | GANTI plot Masjid Besar lama — taman hijau di utara Surau; celah 6 m dari belakang Surau (z=−24) |

### Kapasitas asrama
- Per gedung: **3 lantai × 4 kamar/lantai × 4 kasur tingkat (8 kasur/kamar) = ±96 santri** (1 santri = 1 kasur, aturan yang sudah ada).
- Total kedua gedung: **±192 santri**. Bila santri sudah melebihi itu, gedung asrama ke-2 dibangun di sampingnya (cadangan: putra di barat Asrama 1, putri di **halaman selatan kampus putri (170,31)** — keputusan Xam 18 Nov 13:19, tapak cadangan 20×12 sudah digambar garis putus-putus di peta; rencana lama "putri di timur Asrama 1" BATAL karena tapak itu kini Lapangan Putri).

### Kelas 5 lantai — lift + eskalator
- **Posisi di peta:** penanda emas "L" (lift) dan "E" (eskalator) di pintu masuk tiap gedung Kelas — putra di sisi selatan (hadap jalan penghubung x=−44), putri di sisi timur (hadap jalan internal x=142).
- **Rencana awal ruang:** 4 ruang kelas/lantai (20 ruang/gedung), ±30 santri/ruang → ±600 santri/gedung (asumsi perencanaan, bisa disesuaikan saat desain bangunan).
- **Catatan implementasi (bukan urusan peta):** di game nanti lift butuh mekanisme naik (pilih lantai / teleport antar lantai) dan eskalator butuh mekanisme jalan bergerak atau tanjakan — diputuskan saat bangunan ini dibangun 3D, bukan sekarang.

### Masjid Besar — alasan penempatan (keputusan penting)
**Perintah Mas (22:59 WIB):** kapasitas RIBUAN jama'ah; Masjid Besar adalah PUSAT pesantren — gabung putra + putri; tapi DIPISAH supaya tetap tidak campur (sekat/pembatas + pintu masuk terpisah, seperti masjid pada umumnya: satu bangunan, dua area sholat yang terpisah).

**Pilihan yang diambil: di tengah Zona Penyangga, (64,−24), 54×44 m, menghadap jalan E–W.**
- **Kenapa bukan di plot lama (0,−38) Area Putra:** plot itu di dalam Area Putra — santriwati tidak boleh masuk Area Putra, jadi masjid pusat tidak bisa di sana. Putri harus jalan jauh memutar lewat zona penyangga dan masuk area putra (melanggar pemisahan).
- **Kenapa bukan menempel tembok pemisah x=14:** menempel tembok berarti masjid menabrak Surau (Surau di (0,−14) hanya 14 m dari tembok) dan pintu masuk putri jatuh di zona penyangga tanpa jalan lurus dari kampus putri — aksesnya berbelok lewat kebun, tidak rapi. Selain itu tembok harus dibongkar sebagian.
- **Kenapa di tengah zona penyangga:** (a) benar-benar di tengah pesantren — titik tengah geografis antara Area Putra dan Kampus Putri; (b) menghadap langsung jalan E–W (tulang punggung bersama) — putra jalan dari gerbang (14,0) ke timur, putri jalan dari gerbang putri (115,0) ke barat, keduanya lurus di satu jalan, tanpa masuk area lawan; (c) tidak membongkar tembok dan tidak menggeser bangunan yang sudah ada; (d) dikelilingi kebun & taman — masjid di tengah taman, sesuai citra pesantren yang indah.
- **Pemisahan di dalam:** sekat tengah membujur (garis emas di peta, sejajar sumbu N–S) — putra di sayap barat (x 37..64), putri di sayap timur (x 64..91). Pintu masuk terpisah di sisi selatan, keduanya menghadap jalan E–W: pintu putra di barat (x≈48), pintu putri di timur (x≈80). Wudhu terpisah di luar bangunan, masing-masing di sisi masuknya (Wudhu Putra (30,−6), Wudhu Putri (98,−6)).
- **Kapasitas:** ruang sholat ±48×38 m ≈ 1.800 m² → **±2.000 jama'ah (±1.000 putra + ±1.000 putri)** dengan asumsi ±0,9 m²/jama'ah. Serambi keliling + 2 menara di sudut utara (titik di peta).
- **Yang diganti:** plot Masjid Besar lama (0,−38) tidak lagi dipakai sebagai masjid — jadi **Taman Surau** (taman hijau di utara Surau, sejajar plaza). Usulan U2 butir (a) (geser Masjid Besar ke (0,−38)) dengan ini DIGANTI oleh penempatan baru ini.
- **Catatan:** Musholla Ar-Raudhah (putri) dan Surau (putra) tetap dipakai harian; Masjid Besar dipakai untuk sholat Jumat, tarawih, dan acara besar bersama.

### Klinik — alasan penempatan
- **Satu klinik untuk seluruh pesantren**, di Kawasan Bersama (16,44), timur jalan N–S, di antara Dapur dan Aula.
- Alasan: (a) terjangkau putra maupun putri tanpa masuk area lawan — keduanya lewat jalan N–S yang sama; (b) dekat Gerbang Utama (0,80) via jalan N–S lurus — ambulans/tamu bisa langsung masuk tanpa belok; (c) berdekatan dengan Kantin/Dapur (logistik makanan & obat) dan Aula (bila butuh ruang darurat).

### Balai Tamu — alasan penempatan
- **Tepat di dalam Gerbang Utama** (12,74), timur jalan N–S — tamu masuk gerbang → langsung sampai balai tamu tanpa melewati area santri. Plaza kecil di depannya (x 2..5, z 70..78).

### Jalan baru masterplan
- **Jalan penghubung Kelas Putra** x=−44 (z −8..2): dari jalan E–W lurus ke pintu masuk selatan gedung Kelas Putra.
- **Jalan barat (servis)** x=−58 (z −32..66): dari jalan E–W ke Gudang dan sisi barat Lapangan Putra — melengkapi grid barat.
- **Plaza kecil** di depan Klinik (x 2..10, z 43..49), Dapur (x 2..10, z 33..39), Koperasi (x −5..−2, z 29..35), Balai Tamu (x 2..5, z 70..78).

### Status usulan U1–U5 dalam masterplan
- **U1** (sumbu lurus putri): tetap berlaku — Kelas Putri 5 lantai di (128,10) menggantikan plot U1 (130,10) dengan sedikit penyesuaian; spawn putri tetap (140,16) seperti peta v2.
- **U2:** butir (a) DIGANTI (Masjid Besar pindah ke tengah, plot lama jadi Taman Surau); butir (b) DIGANTI (Kelas Putra jadi gedung 5 lantai di (−44,−14), bukan (−35,−8)).
- **U3** (sudut timur laut putri): tetap berlaku, tidak berubah.
- **U4** (Lapangan Putri (198,12)): tetap berlaku posisinya — TAPI sejak perluasan 18 Nov lapangan kini **di dalam tembok** (bukan lagi di timur tembok); statusnya tapak saja, belum dibangun (dibangun NANTI bareng Asrama ke-2).
- **U5** (asrama ke selatan sumbu): tetap berlaku semangatnya — kedua Asrama 3 lantai di z≈10, selatan sumbu E–W.

### Status keputusan masterplan (update 18 Nov 2026)
- **Masterplan DI-ACC Mas 18 Nov ~11:57 WIB** (butir 1 di bawah terjawab).
- **Butir 5 (Asrama ke-2):** diputuskan Xam 18 Nov 13:19 (Mas: "Terserah kamu — Yg putri") — Asrama ke-2 putri di **halaman selatan (170,31)**, tapak cadangan 20×12 digambar garis putus-putus.
- **Butir 6 (Kelas 5 lantai):** tapak Kelas Putri 5 lantai (128,10) + Asrama Putri 3 lantai (156,10) **DITUNDA** (keputusan Xam 18 Nov 13:19) — dibangun bila santri putri ≥ 25 (Kelas) atau Asrama 1 penuh (Asrama); di peta keduanya tampil sebagai tapak cadangan garis putus-putus, bukan bangunan.
- **Butir 4 (spawn putri):** tetap (140,16) — sesuai peta v2 + kode (Mira 18 Nov).

### Catatan penggambaran
- **Spawn putri:** di peta ini tetap (140,16) seperti peta v2 (U1). Di brief tertulis (130,14) — itu koordinat live v1 sebelum U1. Kalau Mas mau kembali ke (130,14), Kelas Putri 5 lantai harus digeser karena tapaknya menabrak titik spawn — tolong putuskan.
- **Caption "Papan selamat datang" dihapus** di peta masterplan karena bertabrakan dengan label Koperasi; penanda peti M3 di (0,26) tetap ada.
- **Zona penyangga berubah peran:** dari "kebun & taman — tanpa bangunan" menjadi "kebun & taman mengelilingi Masjid Besar" — masjid adalah satu-satunya bangunan di zona ini.

### Yang perlu Mas putuskan (masterplan)
1. ACC masterplan ini secara umum? (Atau ada gedung yang Mas mau geser/tambah/kurangi.)
2. Penempatan Masjid Besar di tengah (64,−24) — setuju? (Atau Mas lebih suka opsi lain: menempel tembok / kawasan bersama selatan?)
3. Kapasitas Masjid Besar ±2.000 — cukup? (Atau perlu lebih besar?)
4. Spawn putri: tetap (140,16) seperti peta v2, atau kembali ke (130,14)?
5. Asrama: bila santri melebihi ±96 per area, bangun gedung asrama ke-2 di sampingnya — setuju dengan cadangan itu?
6. Kelas 5 lantai: 4 ruang/lantai (±600 santri/gedung) — cukup? Lift + eskalator di pintu masuk — setuju?

---

## Perluasan area putri + penyelarasan peta (18 Nov 2026, Mira + Nadia + Gilang)

**Perintah Mas 18 Nov ~00:28 WIB:** "Langsung aja ya.. intinya diperluas.." — diterapkan langsung di kode (Mira, 00:35–01:00 WIB) + peta diselaraskan (Gilang, 13:20–13:40 WIB). Detail perluasan: `area-putri-perluasan.md` (+ `area-putri-perluasan.png`, skrip `buat_perluasan_putri.py`).

- **Tembok keliling putri BARU: x 115..216, z −70..+40** (lama: x 115..180, z −52..+22). Luas **11.110 m² (×2,31)**. Tembok barat x=115 + gerbang (115,0) TETAP — zona penyangga tidak dimakan.
- **Cangkruk Putri (128,−12) DIHAPUS total** (Mas 00:26 WIB) — tapaknya kini **halaman/taman** (dibangun Dewi; di peta: petak hijau "HALAMAN TAMAN").
- **Posisi baru (kode + peta):** Kelas Putri (130,10), Asrama Putri (152,9), Kantor Ustadzah (148,−33), Pos Jaga TL (176,−20), spawn putri (140,16); jalan internal x=142 diperpanjang ke z=+22. Musholla (134,−24), Madrasah (152,−12), Studio (166,−12), reserve Masjid Putri (166,−40) 20×16 tetap.
- **Lapangan Putri (198,12) kini DI DALAM tembok** (dulu 3 m di luar tembok timur) — status: **tapak saja, belum dibangun** (keputusan Xam 18 Nov 13:19: dibangun NANTI, bareng Asrama ke-2). Di peta: garis putus-putus + "(tapak — dibangun nanti)".
- **Tapak cadangan (garis putus-putus, bukan bangunan):** Kelas 5 lantai 20×12 di (128,10) + Asrama 3 lantai 20×12 di (156,10) — DITUNDA sampai santri putri ≥ 25 / Asrama 1 penuh (keputusan Xam 18 Nov 13:19). Asrama ke-2 20×12 di **(170,31), halaman selatan**.
- **Kanvas peta diperluas** (x −70..235, z −84..95; dulu x −70..220, z −70..95) supaya tembok baru + gunung latar utara (geser ke z=−76) muat. Ukuran PNG kini 2743×1819.
- **Atlas reader ikut diperbarui** (skrip `buat_atlas.py`): 6 halaman `data/atlas/` digambar ulang dari masterplan baru — masterplan-v2.png + konsep-v2.png utuh, 3 crop zona lain kotak meternya sama seperti 17 Nov, crop kampus-putri baru (x 100..222, z −76..44). Keterangan hal. 1 + 4 di `data/buku.json` diselaraskan.
- File lama dibackup: `peta-tata-letak-v2-masterplan_sebelum-perluasan-putri-18nov.png`, `peta-tata-letak-v2_sebelum-perluasan-putri-18nov.png`.
- **Wudhu Putri (122,−24) — BARU, diputuskan Mas 18 Nov 18:27 WIB** (usulan utama Tim Maps, barat Musholla Ar-Raudhah, tapak 8×6 m x 118..126, z −27..−21; alternatif (134,−35) tidak dipakai). Masuk masterplan resmi 18 Nov 18:28 WIB (Gilang): peta masterplan + peta konsep digambar ulang, footer masterplan mencatat tanggal keputusan; backup PNG lama `*_sebelum-wudhu-putri-18nov.png`. Pembangunan di game BELUM — menunggu arahan.

---

## 1. Prinsip yang dipertahankan dari v1

1. **Satu dunia, dua area terpisah.** Barat (x<14) = Area Putra; timur (x≥124) = Area Putri; di antaranya zona penyangga kebun/taman tanpa bangunan.
2. **Tembok pemisah solid x=14** (z −60..+16, tinggi 3 m) + **gerbang (14,0)** (pintu tertutup) + **pos satpam (17,5)**. Aturan zona keras tetap: santri tidak boleh masuk area lawan; Pengasuh + musyrif/musyrifah + Keamanan boleh lintas.
3. **Tembok keliling kampus putri** persegi x 115..216, z −70..+40 (BARU 18 Nov; lama x 115..180, z −52..+22) + **gerbang barat (115,0)**.
4. **Surau (0,−14) LURUS (sejajar sumbu; rotasi GLB −90° di game)** — revisi Mas 17 Nov ~22:51: "Surau lurus aja. Jangan miring. Biar matahari yg menyesuaikan dg arah barat. Surau lurus seperti masjid." Jejak 16×20 m (depan z=−4, belakang z=−24; terverifikasi Rangga 23:19). Matahari dikalibrasi ulang ke arah barat di game; interior Surau (mihrab/kiblat di dalam) tidak berubah. Detail bangunan ikut lembar konsep Arsa.
5. **Ibadah di utara, bersama di selatan.** Surau + Musholla + Masjid di sisi utara; Perpustakaan & Taman, Kantin, Aula, Gerbang Utama di sumbu selatan (kawasan bersama, terbuka untuk putra + putri).
6. **Jalan utama tidak pernah ditutup.** Sumbu N–S (x=0) + E–W (z=0) tetap tulang punggung; jalan internal putri x=142 tetap.
7. **Ambang 25 / 100 / 200 tetap.** Kelas 25 per gender, Masjid Besar 100 total, Perpustakaan & Taman 200 total. Asrama tetap dipicu cangkruk penuh (10 kasur), bukan ambang.
8. **Spawn putra (−4,14) tetap.** Sawah (60,30), Kebun (100,30), Kolam (100,60), 4 pos jaga, Peti Kayu M3 (0,26), papan selamat datang (0,18) tetap di tempatnya.

---

## 2. Tabel koordinat v2 (pusat bangunan)

| Bangunan | Ukuran (m) | Koordinat v2 | Keterangan |
|---|---|---|---|
| Surau | 16×20, lurus | (0,−14) | REVISI Mas 22:51 — lurus seperti masjid; pusat diselaraskan ke live (0,−14); jejak terverifikasi Rangga 23:19: 16 (T-B) × 20 (U-S), depan z=−4, belakang z=−24 |
| Masjid Besar | 20×16 | **(0,−38)** | U2 — geser ke utara |
| Kelas Putra | 12×9 | **(−35,−8)** | U2 — geser |
| Asrama Putra | 14×10 | **(−16,9)** | U5 — geser ke selatan sumbu |
| Cangkruk Putra | 10×8 | (−22,−18) | tetap (posisi live Ronde 21) |
| Kantor Pengasuh | 10×8 | (−36,−28) | tetap |
| Spawn Putra | — | (−4,14) | tetap |
| Musholla Ar-Raudhah | 12×10 | (134,−24) | tetap |
| Cangkruk Putri | 10×8 | (128,−12) | **DIHAPUS 18 Nov (Mas 00:26 WIB)** — tapak kini halaman/taman |
| Kelas Putri | 10×8 | **(130,10)** | U1 — geser ke selatan sumbu |
| Asrama Putri | 12×8 | **(152,9)** | U5 — geser ke selatan sumbu |
| Tapak cadangan Kelas 5 lantai | 20×12 | (128,10) | DITUNDA (Xam 18 Nov 13:19) — bangun bila santri putri ≥ 25; garis putus-putus di peta |
| Tapak cadangan Asrama 3 lantai | 20×12 | (156,10) | DITUNDA (Xam 18 Nov 13:19) — bangun bila Asrama 1 penuh; garis putus-putus di peta |
| Tapak cadangan Asrama ke-2 | 20×12 | (170,31) | Halaman selatan (Xam 18 Nov 13:19); garis putus-putus di peta |
| Madrasah | 10×8 | (152,−12) | tetap |
| Studio | 10×8 | (166,−12) | tetap |
| Kantor Ustadzah | 8×6 | **(148,−33)** | U3 — geser |
| Masjid Putri (rencana) | 20×16 | **(166,−40)** | U3 — geser |
| Spawn Putri | — | **(140,16)** | U1 — geser |
| Pos Jaga TL | 3×3 | **(176,−20)** | U3 — geser |
| Perpustakaan & Taman | 12×9 | (0,20) | tetap |
| Kantin | 12×8 | (0,40) | tetap |
| Aula | 16×12 | (0,52) | tetap |
| Gerbang Utama | — | (0,80) | tetap |
| Lapangan Putra | 30×20 | (−30,50) | tetap |
| Lapangan Putri | 30×20 | **(198,12)** | U4 — pindah ke timur kampus; **kini DI DALAM tembok (perluasan 18 Nov) — tapak saja, belum dibangun (NANTI bareng Asrama ke-2)** |
| Sawah / Kebun / Kolam | 60×40 / 30×20 / 12×8 | (60,30) / (100,30) / (100,60) | tetap |
| Pos Jaga BL / BD / TG | 3×3 | (−40,−35) / (−40,80) / (40,80) | tetap |
| Pos Satpam | 3×3 | (17,5) | tetap |

Jalan: N–S x=0 (stub utara z −62..−46, plaza Surau–Masjid, ruas selatan z 0..90); E–W z=0 (x −62..+198, **diperpanjang ke Lapangan Putri**); jalan internal putri x=142 (z −35..+22, diperpanjang 18 Nov); jalan ke sawah z=30.

---

## 3. Yang diubah dari v1 — usulan (U1–U5, butuh ACC Mas)

### U1 — Sumbu lurus ke kampus putri (hapus belokan dogleg v1)
**Masalah v1:** jalan masuk putri berbelok (115,0)→(115,8)→(142,8) karena Kelas Putri (130,0) tepat memotong sumbu z=0.
**Usulan:** Kelas Putri geser ke selatan sumbu → **(130,10)**; jalan masuk jadi **lurus z=0** dari gerbang barat (115,0) sampai jalan internal x=142. Spawn putri ikut geser → **(140,16)** (tetap di dekat persimpangan, 5 m timur Kelas).
**Alternatif:** pertahankan dogleg v1 (tidak ada yang rusak, hanya kurang rapi).

### U2 — Perbaiki dua tabrakan di klaster putra
**Masalah v1 (terukur dari denah):**
- (a) Plot **Masjid Besar (0,−26)** bertabrakan dengan Surau lurus di (0,−14) (Surau menjorok sampai z=−24; tumpang tindih ±6 m). Plot ini belum pernah dibangun, jadi tidak ada yang sadar.
- (b) Plot **Kelas Putra (−24,−20)** bertabrakan dengan **Cangkruk Putra live (−22,−18)** (tumpang tindih besar). Catatan: denah lama menulis Cangkruk di (−12,−12), tapi posisi live Ronde 21 adalah (−22,−18) — peta v2 memakai posisi live.
**Usulan:** Masjid Besar → **(0,−38)** (plaza 6 m antara Surau dan Masjid); Kelas Putra → **(−35,−8)** (barat Asrama, 2 m dari Cangkruk, 6 m dari Asrama).

### U3 — Penataan ulang sudut timur laut kampus putri
**Masalah v1:** reserve **Masjid Putri (134,−40)** hanya **3 m** dari dinding utara Musholla (134,−24) — dua rumah ibadah berdempetan. Pos Jaga TL (160,−35) juga berdiri di dalam tapak reserve baru bila masjid digeser.
**Usulan (satu paket):** Masjid Putri → **(166,−40)** (timur laut kampus, 16 m dari Studio, 4 m dari Kantor); Kantor Ustadzah → **(148,−33)** (gang 4 m ke Musholla dan ke Masjid); Pos Jaga TL → **(176,−20)** (dekat tembok timur, tetap di dalam keliling).

### U4 — Lapangan Putri pindah ke timur kampus
**Masalah v1:** Lapangan Putri (48,62) masuk akal saat kampus putri masih di x≈51 (rencana 19:42), tapi setelah Opsi A kampus pindah ke x≈130 — lapangan tertinggal **95 m (±16 detik jalan)** dari spawn putri, di kawasan bersama.
**Usulan:** Lapangan Putri → **(198,12)**, di timur tembok keliling (3 m dari tembok), dilayani perpanjangan jalan E–W. Seimbang dengan Lapangan Putra di barat (−30,50).
**Update 18 Nov 2026 (perluasan):** tembok timur geser ke x=216 — lapangan kini **di dalam tembok**; statusnya tapak saja, belum dibangun (dibangun NANTI bareng Asrama ke-2, keputusan Xam 13:19).
**Alternatif:** tetap di (48,62) (tetap bisa dipakai bersama, hanya jauh dari kampus putri).

### U5 — Kedua Asrama geser ke selatan sumbu jalan E–W
**Masalah v1:** plot Asrama Putra (−16,0) dan Asrama Putri (152,0) **tepat di atas sumbu jalan E–W (z=0)** — jalan menembus tapak bangunan. Belum pernah dibangun (masih plot), jadi tidak ada yang sadar.
**Usulan:** Asrama Putra → **(−16,9)**, Asrama Putri → **(152,9)** (keduanya di selatan sumbu, simetris; jalan E–W jadi bersih dari gerbang sampai Lapangan Putri).

---

## 4. Catatan lain

- **Zona penyangga (x 14..115)** digambar sebagai kebun & taman dengan pohon tersebar + jalan akses E–W. Isi detailnya (kebun sayur produktif? taman bunga? kolam kecil? bangku/lampu istirahat?) belum ditetapkan — lihat keputusan no. 7.
- **Pohon (130,−40)** di dalam keliling putri tetap dicatat: pindah saat Masjid Putri dibangun (sesuai rencana lama).
- **Gunung** digambar sebagai latar utara (±350 m), 2 gunung — sesuai usulan Tim Maps di roadmap §7 butir 1.
- **Yang tidak digambar di sketsa ini** (di luar lingkup peta): interior bangunan (pola GTA, terpisah), desain tiap bangunan (ikut lembar konsep Arsa dkk.), sistem misi/poin, NPC.
- **Ketidakcocokan dokumen v1 yang ditemukan saat menggambar** (dicatat supaya tidak terulang di v2): denah §3 menulis Cangkruk Putra (−12,−12) padahal live Ronde 21 di (−22,−18); plot Masjid Besar dan Kelas Putra di denah bertabrakan dengan bangunan yang sudah/akan dibangun.

---

## 5. Yang perlu Mas putuskan

1. **ACC peta konsep ini secara umum?** (Atau ada bangunan yang Mas mau geser.)
2. **U1** — sumbu lurus kampus putri (Kelas Putri → (130,10), spawn → (140,16)), atau pertahankan dogleg v1?
3. **U2** — Masjid Besar → (0,−38) dan Kelas Putra → (−35,−8) (perbaiki tabrakan)?
4. **U3** — penataan ulang sudut timur laut putri (Masjid Putri → (166,−40), Kantor Ustadzah → (148,−33), Pos Jaga TL → (176,−20))?
5. **U4** — Lapangan Putri → (198,12) di timur kampus, atau tetap (48,62)?
6. **U5** — kedua Asrama geser ke selatan sumbu E–W (Putra (−16,9), Putri (152,9))?
7. **Isi zona penyangga** — kebun sayur produktif + taman bunga + jalur setapak (usulan Gilang), atau biarkan hijau kosong saja?
8. **Kawasan selatan** tetap bersama untuk putra + putri, atau ikut dipisah? (Pertanyaan lama roadmap §7 butir 8, belum terjawab.)
9. **Area putri di v2 dibuka sejak awal** (dunia langsung lengkap), atau dibangun bertahap seperti v1 (buka saat santriwati pertama)? (Roadmap §7 butir 10.)
10. **Masjid Besar** tetap satu masjid utuh putra + Masjid Putri terpisah (arah v1), atau ada perubahan?

---

## 6. Langkah berikut (setelah Mas menilai)

1. Mas ACC / revisi peta ini (dan U1–U5).
2. Bila ACC: Gilang perbarui sketsa bila ada revisi → Raka membangun dunia v2 di Godot (folder v2, terpisah dari v1) mengikuti peta ini + lembar konsep bangunan (Arsa) + lembar konsep karakter (Kirana).
3. Bila revisi: Gilang gambar ulang sketsa (skrip `buat_peta.py` siap dipakai ulang) dan setor lagi ke Mas.
