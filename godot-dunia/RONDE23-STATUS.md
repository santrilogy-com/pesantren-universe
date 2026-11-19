# RONDE 23 — Perbaikan dinding selatan tembok putri (Cakra)

Perintah Mas 17 Nov ~08:21 WIB: perbaiki dinding selatan tembok putri
yang terlihat gelap (foto 28 Ronde 22). Raka koordinasi; Cakra perbaiki.

## Penyebab (TERVERIFIKASI, bukan sekadar hipotesis)

Bukan material — semua sisi tembok pakai `Palette.KREM` (#f2ead6) yang
sama via `PesantrenBuilder._static_box`, roughness 0.9. Ini pencahayaan.

**Koreksi arah dari hipotesis awal.** Muka luar z=-52 menghadap
**UTARA** (-Z, azimut 0°), bukan selatan. Konvensi dunia ini +Z =
selatan — bukti: minimap `ui.gd` ("y = selatan/+z"), sawah "tenggara"
di (60,+30), gunung "di selatan" di z≈+330, kiblat 295° konsisten
dengan azimut 0 = utara = -Z. Nama node "Selatan"/"Utara" di
`tembok_putri.gd` TETAP (tes Ronde 22 mengacu ke nama itu) meski
arah mata anginnya tertukar — jangan rename tanpa ubah tes.

**Bukti render ulang sudut foto 28 (kamera (147,5,-68) → (147,1.5,-52)):**

| Foto | Jam | Matahari (azimut) | Dinding (RGB rata-rata) |
|------|-----|-------------------|-------------------------|
| 28 (Ronde 22) | 10:00 | 118° | (111,139,130) abu-abu kehijauan |
| 40 baseline | 10:00 | 118° | (111,139,130) — identik dgn 28, render deterministik |
| 41 baseline dekat | 10:00 | 118° | (103,145,123) |
| 42 baseline | 12:00 | 200° | (111,136,125) |
| 43 baseline | 15:00 | 252° | (114,130,113) |

Dot normal -Z dengan arah matahari: -0,27 (10:00), -0,44 (12:00),
-0,31 (15:00) — selalu negatif. **Prediksi "siang lebih terang"
SALAH dan terbukti salah di foto 42/43**: muka ini TIDAK PERNAH kena
matahari langsung sepanjang hari (matahari selalu di belahan langit
selatan), hanya ambient langit (`AMBIENT_SOURCE_SKY`, energi 0,85)
yang kehijauan karena pantulan rumput di ground sky — krem me-render
abu-abu kehijauan di bawah tonemapping AGX. Foto 27 (timur) dan 26
(z=+22) terang karena mukanya kena matahari langsung.

## Perbaikan (`scripts/tembok_putri.gd` saja)

**Cahaya isi utara** — satu `DirectionalLight3D` tanpa bayangan dari
langit utara (azimut 0°, elevasi 20°), nama node `CahayaIsiUtara`,
kelas dalam `CahayaIsiUtara extends DirectionalLight3D`:

- Energi 1,2, warna hangat #ffd9a0 (menetralkan sisa hijau ambient).
- Energi mengikuti jam lewat `_faktor_siang()` (penuh 05:30–17:30,
  padam 18:00–05:00, transisi halus subuh/senja) — baca
  `LangitDinamis.jam_saat_ini()` tiap frame, jadi ikut `debug_jam`
  saat foto/tes.
- **Isolasi lapis:** semua 25 mesh tembok (5 badan + 5 lis emas +
  5 fondasi batu + 2 pilar + 2 tutup emas + balok/lis/atap gapura +
  2 daun pintu + palang emas) dipindah ke visual layer 2
  (`_lapis()`, `LAPIS_TEMBOK := 2`) dan `light_cull_mask` isi HANYA
  layer 2. Gunung, rumput, dan bangunan lain (layer 1) tidak kena
  isi sama sekali. Matahari utama (mask semua lapis) + lampu tetap
  menyinari tembok seperti biasa; kamera utama (mask semua lapis)
  tetap melihat tembok. Proyek sebelumnya tidak memakai visual
  layer, jadi layer 2 kosong.
- Geometri + collision tembok TIDAK berubah. Jalur matahari
  (`langit_dinamis.gd`), `Palette.KREM`, `pesantren_builder.gd`,
  `main.gd` TIDAK disentuh.

**Kalibrasi (foto tuning dekat jam 10:00, /tmp):** energi 0,35 →
(149,173,145); 0,75 → (174,192,162); 1,2 global → (208,197,174)
tapi lereng utara gunung ikut jadi kuning-hijau pucat; 1,0 global →
(202,192,169); **1,2 + isolasi lapis → (208,197,174) jauh /
(210,199,176) dekat, gunung kembali hijau** — versi final.

## Tes

- `test_ronde22.gd` (baseline, sebelum perbaikan): **259 LOLOS /
  0 GAGAL**, exit 0, 0 SCRIPT ERROR, 0 NaN. Log:
  `/tmp/cakra_test_r22_baseline.log`.
- `test_ronde22.gd` (sesudah perbaikan, 2× jalan): run 1 =
  **258/1** — "celah utara tertutup (x<14 di z=-70)" gagal tipis
  (x=14,60); run 2 = **259 LOLOS / 0 GAGAL**, exit 0, 0 SCRIPT
  ERROR. Kegagalan run 1 flaky (timing fisika headless — tes itu
  jalan pemain 180 physics frame di `main.gd`, tidak ada kaitannya
  dengan perubahan ini: hanya visual layer + satu cahaya tanpa
  bayangan; tidak ada sentuhan fisika/batas/pemain). Log:
  `/tmp/cakra_test_r22_perbaikan.log`,
  `/tmp/cakra_test_r22_perbaikan2.log`.
- `--check-only` `tembok_putri.gd`: OK.

## Foto (semua di `foto-ronde-20/`, foto lama TIDAK ditimpa)

Baseline (verifikasi penyebab): 40 (jauh 10:00), 41 (dekat 10:00),
42 (jauh 12:00), 43 (jauh 15:00).
Perbaikan: **44 (jauh 10:00), 45 (dekat 10:00), 46 (jauh 12:00),
47 (jauh 15:00), 48 (jauh 21:00 malam)** — semua DILIHAT Cakra.

| Foto | Jam | Dinding (RGB) | Keterangan |
|------|-----|---------------|------------|
| 44 | 10:00 | (208,197,174) | Krem terang, lis emas jelas; gunung tetap hijau, bangunan di balik tembok tidak berubah |
| 45 | 10:00 | (210,199,176) | Dekat: krem merata, lis emas garis tegas, fondasi batu terlihat |
| 46 | 12:00 | (208,196,173) | Krem sama seperti 10:00 (banner Dzuhur muncul seperti di baseline 42) |
| 47 | 15:00 | (208,195,169) | Krem, sedikit lebih hangat (golden hour); banner Ashar |
| 48 | 21:00 | (0,0,14) | Malam: dinding gelap seperti seluruh scene (bintang + lampu jauh menyala) — **TIDAK menyala sendiri** |

Pembanding: dinding kena matahari foto 26/27 merender (253,253,249)
— hampir putih clip. Dinding perbaikan (208,197,174) lebih gelap
dari itu tapi jelas krem hangat, bukan abu-abu kehijauan
(111,139,130). Jarak RGB ke krem target #F2EAD6: 182,3 (baseline)
→ 64,2 (perbaikan).

## Catatan jujur / yang perlu dicek saat verifikasi

- **Isi HANYA menyentuh mesh tembok** (layer 2). Yang perlu dicek
  Raka: (1) foto 44 vs 28 berdampingan di HP Mas; (2) gerbang
  putri dari barat (foto 25) — pilar + gapura + label tetap normal
  (mesh gerbang ikut layer 2, kena isi dari utara; dari barat
  seharusnya tak berubah banyak); (3) sisi DALAM tembok (dari
  kampus putri) — muka dalam menghadap selatan/timur/barat, dot
  dengan isi ≤ 0, seharusnya identik dengan Ronde 22; (4) malam
  hari di dalam game (foto 48 hanya dari luar).
- **Satu-satunya efek samping yang sempat muncul sudah diatasi:**
  versi global (tanpa isolasi lapis) membuat lereng utara gunung
  kuning-hijau pucat — versi final dengan isolasi lapis tidak
  menyentuh gunung (foto 44: gunung hijau sama seperti foto 28).
- **Nama "Selatan"/"Utara" tertukar arah mata angin** (lihat
  Penyebab). Bukan blocker — geometri dan tes tidak berubah — tapi
  kalau suatu saat ada yang memperbaiki penamaan, tes Ronde 22 yang
  mengacu `TembokKelilingSelatan`/`Utara` harus ikut diubah.
- **Tidak di-export.** `export/web/` dan `export/web-pages/` tidak
  disentuh (Damar deploy paralel). Pck baru urusan Raka setelah
  verifikasi.
- Skrip: `ronde-23/skrip/` (`foto_ronde23_baseline.gd`,
  `foto_ronde23_perbaikan.gd`, `foto_ronde23_tuning.gd`,
  `ukur_dinding.py` + `.tscn`). Salinan sementara di root
  `godot-dunia/` sudah dihapus; root bersih (hanya `main.tscn`).

## Verifikasi Raka + Export (17 Nov ~09:20 WIB)

- **Foto DILIHAT Raka:** 44 (jauh 10:00) — dinding krem terang, lis
  emas jelas, gunung tetap hijau, bangunan di balik tembok tidak
  berubah; 45 (dekat 10:00) — krem merata, lis emas garis tegas,
  fondasi batu terlihat; 48 (malam 21:00) — dinding gelap seperti
  seluruh scene, **tidak menyala sendiri**. Banding foto 28 vs 44:
  perbaikan nyata (abu-abu kehijauan → krem hangat).
- **Koreksi hipotesis dicatat + disetujui Raka:** muka luar z=-52
  menghadap UTARA (-Z), bukan selatan — prediksi awal Raka ("siang
  lebih terang") terbukti salah di render 12:00/15:00; muka ini
  memang tidak pernah kena matahari langsung. Nama node
  "Selatan"/"Utara" tertukar arah mata angin tapi geometri + tes
  benar — tidak di-rename.
- **Kode dibaca Raka:** hanya `scripts/tembok_putri.gd` yang berubah
  (`CahayaIsiUtara`, `_faktor_siang`, `_lapis`, 25 mesh ke layer 2,
  `light_cull_mask` layer 2 saja, tanpa bayangan).
  `--check-only` OK.
- **Tes diulang Raka (independen): 259 LOLOS / 0 GAGAL**, 0 SCRIPT
  ERROR, smoke 600 frame selesai. Log: `/tmp/raka_test_r23.log`.
  Root proyek bersih kembali (hanya `main.tscn`).
- **Export pck BARU (Raka): `export/web-tembok-selatan/index.pck`,
  1.623.472 byte, sha256
  `ffdf8d2d49a4e8055dee9bf97b465b1d42cf40fad7dba9f81469ada96e840a20`**
  (GDPC, 78 file, berisi `scripts/tembok_putri.gdc`); wasm TIDAK
  berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…`); worklet `index.audio.position.worklet.js` ada
  (2.973 byte); `index.html` segar GODOT_CONFIG `fileSizes` pck
  1623472, 2 `<script>` (normal — patch wasm jadi 3/3 dikerjakan
  Damar saat sinkron staging). **TIDAK deploy** — menunggu verdict
  Mas atas foto 44/45.
- **Insiden export (pelajaran):** percobaan pertama memberi path
  `.../index.pck` langsung → HTML shell menimpa `index.pck`
  (5.534 byte, magic `<!DO`) karena preset Web memakai path
  **HTML** (`export_path` berakhir `index.html`); diperbaiki dengan
  path `.../index.html`, pck benar 1.623.472 byte.
- **`export/web/index.pck` TIDAK tersentuh** (1.602.820 byte, md5
  `eec75465…` — pck live Damar, deployment 241e7608).
