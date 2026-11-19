# AUDIT TEKSTUR / MATERIAL BANGUNAN — Standar Surau Putra

**Tanggal:** 18 November 2026 (13:39–14:05 WIB)
**Auditor:** Gilang (Tim Maps + konsep bangunan)
**Pertanyaan Mas (13:39 WIB):** "tekstur bangunan apakah sudah sesuai standar Surau Putra?"
**Status:** AUDIT SAJA — tidak ada bangunan yang diubah. Perbaikan menunggu keputusan Mas.
**Foto bukti:** `v2/foto-audit-tekstur/` (21 foto, semua sudah dibaca auditor)

---

## 0. Jawaban singkat

**Sebagian besar SUDAH sesuai bahasa Surau — tapi "tekstur" hampir tidak ada di mana-mana, termasuk di Surau sendiri.**

Surau v2 adalah satu-satunya bangunan dengan model 3D sungguhan (GLB) dan satu-satunya yang memakai texture map gambar — itupun hanya 2 gambar: plakat Arab dan kisi jendela. Semua gedung lain dibangun dari primitif Godot dengan **warna datar (flat color)** tanpa texture map. Jadi standar "tekstur" Surau sebenarnya adalah: **palet warna + bentuk** (kubah bawang, jendela lengkung, lis emas) — bukan texture map.

**Temuan terbesar: cangkang luar Asrama Putri TIDAK SESUAI** — masih 12×8 m, 1 lantai, padahal interiornya sudah 21,5×12 m, 3 lantai (96 kasur). Perbesaran 09:10 hanya membesarkan interior, cangkang tidak ikut.

**Ringkasan verdict:**

| Gedung | Verdict | Catatan utama |
|---|---|---|
| Surau Putra (standar) | — (referensi) | GLB, 2 texture gambar, kubah bawang |
| Asrama Putra | ✅ SESUAI | Fasad barat (pintu) polos, tanpa jendela lengkung |
| Asrama Putri | ❌ TIDAK SESUAI | Cangkang 12×8×4 m vs interior 21,5×12×9,6 m |
| Musholla Ar-Raudhah | ✅ SESUAI | Kubah bola gepeng, bukan bawang seperti Surau |
| Kelas Putri | ⚠️ SEBAGIAN | Fasad pintu polos; jendela lengkung hanya di sisi samping |
| Kantor Ustadzah | ⚠️ SEBAGIAN | Sama seperti Kelas Putri |
| Madrasah | ⚠️ SEBAGIAN | Sama seperti Kelas Putri |
| Studio | ⚠️ SEBAGIAN | Sama seperti Kelas Putri |
| Pos Jaga (putra ×4, satpam, putri TL) | ⚠️ SEBAGIAN | Dinding kayu penuh — paling jauh dari bahasa Surau |
| Cangkruk Putra | ⚠️ SEBAGIAN | Kayu penuh, sengaja beda (brief "ala pos ronda") |
| Gerbang + tembok (x=14) | ✅ SESUAI | Krem + lis emas + fondasi batu + pintu jati |
| Tembok keliling + Gerbang Putri | ✅ SESUAI | Sama seperti gerbang putra |
| Kelas Putra | — BELUM ADA | Hanya plot terkunci (ambang 25 santri) |

---

## 1. STANDAR SURAU PUTRA

Sumber: `v2/godot-dunia/models/surau-v2.glb` (GLB Bima, 191 MeshInstance3D) + dump material headless (`skrip/dump_material_surau.gd`) + `v2/konsep/desain-arsitektur/DESAIN-ARSITEKTUR.md` (Ronde 21, ACC Mas).

### 1.1 Palet (dari `scripts/palette.gd` — berlaku untuk semua gedung)

| Nama | Hex | Pakai di |
|---|---|---|
| KREM | `#F2EAD6` | Dinding utama semua gedung |
| ZAMRUD | `#065F46` | Kubah, atap, parapet |
| ZAMRUD_GELAP | `#043B2C` | Atap/parapet gelap |
| EMAS | `#C9A227` | Lis, sabit, gagang, detail |
| EMAS_DESAIN | `#D4A017` | Lis desain (sedikit lebih terang dari EMAS) |
| JATI | `#7B4B2A` | Pintu, tiang serambi |
| BATU | `#B8B2A4` | Anak tangga, fondasi, pembatas |
| KAYU | `#8A5A2B` | Bangunan kayu (Cangkruk, Pos Jaga) |
| KAYU_GELAP | `#5C3A1A` | Atap kayu gelap |
| HIJAU_TUA | `#1E4D2B` | Jendela gelap, detail hijau |

### 1.2 Material Surau (hasil dump GLB, 13:39)

6 material warna datar + 2 texture gambar:

- **Krem_Dinding** `#f2ead6` — dinding
- **Zamrud_Kubah** `#065f46` — kubah
- **Emas** `#c9a227` (roughness 0,35, metallic 0,55) — lis, sabit, detail
- **Batu** `#b8b2a4` — tangga, fondasi
- **Jati** `#7b4b2a` — pintu
- **Hijau_Tanaman** `#5f7055` — tanaman
- **Texture gambar (hanya 2):** `surau-v2_plakat.png` (plakat Arab di atas pintu) dan `surau-v2_kisi.png` (kisi ukir jendela)

**Tidak ada texture map Poly Haven di Surau.** Tekstur Poly Haven dipakai untuk props lingkungan (pohon, pagar, sawah, taman) — bukan untuk dinding bangunan.

### 1.3 Bentuk (bahasa Surau)

- Kubah **bawang** zamrud + bulan sabit emas (1 kubah besar + 4 kecil)
- 1 menara ramping (badan silinder krem + lis emas, tutup kubah zamrud)
- Portal pintu **lengkung lancip** (di game disederhanakan setengah lingkaran)
- Pintu jati dua daun + lis emas + kisi ukir
- 6 jendela **lengkung** berkisi kayu
- Serambi depan 3 m, 3 lengkung di atas tiang ramping
- 3 anak tangga batu
- Lis emas sekeliling tepi atap

**Kesimpulan standar:** Surau = **krem + zamrud + emas + jati + batu, warna datar, bentuk lengkung + kubah bawang + lis emas**. "Tekstur" dalam arti texture map hampir tidak ada — yang ada adalah bentuk dan detail.

---

## 2. AUDIT PER GEDUNG

Semua penilaian dari 2 sumber: (a) baca kode builder (`scripts/asrama_putra.gd`, `scripts/kampus_putri.gd`, `scripts/pesantren_builder.gd`), (b) foto render headless yang sudah dibaca auditor. Foto: `v2/foto-audit-tekstur/`.

### 2.1 Surau Putra — REFERENSI (bukan diaudit)

Foto: `surau.png`. Krem + kubah zamrud + menara + portal lengkung + lis emas, semua terbaca dari jalan. Plakat Arab hijau-emas di atas pintu. Satu-satunya bangunan berkubah bawang dan satu-satunya dengan texture gambar (plakat + kisi). **Ini patokannya.**

### 2.2 Asrama Putra — ✅ SESUAI (dengan 1 catatan)

**Kode:** `scripts/asrama_putra.gd` di (−24, 10). Cangkang 18×12 m + annex tangga timur 3,5×2,6 m = 21,5×12 m, 3 lantai × 3,2 m + parapet zamrud 0,6 m = 10,2 m.

**Material (kode):** dinding KREM; lis EMAS_DESAIN per lantai (y 3,2 / 6,4 / 9,6); parapet ZAMRUD_GELAP; pintu jati dua daun + gagang/tiang EMAS; plakat "ASRAMA PUTRA" (papan zamrud bingkai emas); jendela lengkung (kotak emas + kotak zamrud + cakram emas + cakram gelap) di fasad utara (z=3,87) dan selatan (z=16,13) tiap lantai + annex timur; serambi (tiang KREM + atap ZAMRUD_GELAP + lis EMAS).

**Foto:** `asrama-putra.png` + `asrama-putra-2.png`. Fasad barat terbaca: 3 lantai krem, garis emas antar lantai, kanopi hijau di atas pintu jati, plakat kecil di atas pintu, atap datar zamrud + lis emas. Di latar kiri terlihat kubah Surau + Cangkruk kayu.

**Catatan (bukan pelanggaran, tapi patut tahu Mas):** fasad barat — sisi pintu utama, sisi yang paling sering dilihat santri — **polos, tanpa satu pun jendela lengkung**. Semua jendela lengkung ada di fasad utara/selatan (samping). Dari depan, gedung ini kotak krem besar dengan garis emas tipis. Dindingnya warna datar, tanpa texture map.

### 2.3 Asrama Putri — ❌ TIDAK SESUAI (ukuran cangkang)

**Kode:** `scripts/kampus_putri.gd:79` — cangkang luar masih **12×8 m, tinggi 4,0 m, 1 lantai**. Interiornya (`scripts/interior_asrama_putri.gd`) sudah **21,5×12 m, 3 lantai**, 12 kamar, 96 kasur (A-PUTRI-001..096).

**Foto:** `asrama-putri-2.png` (foto ronde 1 gagal — kamera kejepit dinding Kelas, diulang dari diagonal). Yang terlihat: **kotak kecil 1 lantai**, krem + atap datar zamrud + lis emas + pintu jati + label kecil. Sepintas tidak bisa dibedakan dari Kelas Putri / Madrasah / Studio. Sementara Asrama Putra di seberang adalah gedung 3 lantai 21,5×12 m.

**Akar masalah:** perbesaran Asrama Putri 09:10 ("tapak 12×8 → 18×12 m") ternyata **hanya membesarkan interior**; cangkang luar tidak ikut membesar. Akibatnya cangkang tidak cocok dengan interiornya sendiri, dan tidak cocok dengan Asrama Putra.

**Bahasa paletnya sendiri sesuai** (krem/zamrud/emas/jati + plakat) — yang salah adalah **skala**.

### 2.4 Musholla Ar-Raudhah — ✅ SESUAI (dengan 1 catatan)

**Kode:** `scripts/kampus_putri.gd` (134,−24), 12×10 m. Dinding KREM; lis EMAS + atap ZAMRUD_GELAP; kubah zamrud (bola, scale y 0,75) + tiang/sabit EMAS; pintu jati + lis/tiang EMAS; plakat Arab (hijau-emas); serambi kayu (tiang JATI, atap JATI + lis EMAS); tangga BATU; jendela lengkung (emas+zamrud) di sisi timur/barat; pagar kayu sekeliling.

**Foto:** `musholla.png` + terlihat juga di `kantor-2.png`. Terbaca jelas: krem + atap zamrud + kubah hijau + sabit emas + serambi kayu + plakat Arab. Bedeng bunga warna-warni di depannya (taman putri).

**Catatan:** kubahnya **bola gepeng** (sphere scale y 0,75), bukan kubah **bawang** seperti Surau. Dari jauh tetap terbaca sebagai kubah masjid, tapi bentuknya beda dengan Surau. Atapnya datar (sesuai desain Musholla — bukan pelana).

### 2.5 Gedung generik putri (`_gedung`) — Kelas Putri, Kantor Ustadzah, Madrasah, Studio — ⚠️ SEBAGIAN

**Kode:** `scripts/kampus_putri.gd` — satu fungsi `_gedung` dipakai keempatnya. Dinding KREM; lis EMAS + atap ZAMRUD_GELAP; jendela lengkung (emas+zamrud) **hanya di sisi timur/barat**; pintu JATI + lis EMAS di satu sisi; plakat nama (papan zamrud bingkai emas, Label3D kecil).

- **Kelas Putri** (130,10), pintu S. Foto: `kelas-putri.png` — kotak krem + atap zamrud + pintu jati + label kecil. Fasad selatan (pintu) polos tanpa jendela.
- **Kantor Ustadzah** (148,−33), pintu W. Foto: `kantor-ustadzah.png` (lemah — dinding Musholla menutupi separuh frame) + `kantor-2.png` (diulang dari diagonal selatan — Kantor terlihat kecil di tengah, dinding barat Musholla + kubahnya di kanan). Sama: kotak krem + pintu jati + label kecil.
- **Madrasah** (152,−12), pintu W. Foto: `madrasah.png` — paling jelas dari keempatnya: jalan paving menuju pintu jati, label "MADRASAH", serambi Musholla di kiri, dinding Studio di kanan. Fasad barat polos selain pintu.
- **Studio** (166,−12), pintu N. Foto: `studio.png` (fasad selatan — dinding krem polos total, tanpa pintu/jendela/label) + `studio-utara.png` (fasad utara, diulang — pintu jati + label "STUDIO" kecil, tetap tanpa jendela di fasad ini).

**Penilaian:** palet dan bahan **sesuai** bahasa Surau (krem/zamrud/emas/jati). Yang kurang: (1) **fasad pintu polos** — jendela lengkung hanya di sisi samping, jadi dari arah pintu gedung terlihat seperti kotak krem kosong; (2) **dinding warna datar tanpa texture map**; (3) label plakat kecil, sulit dibaca dari jarak normal (di foto hanya terbaca dari dekat, sering tertutup pemain). Keempat gedung ini **tidak bisa dibedakan satu sama lain** kecuali dari label kecilnya — bentuknya identik.

### 2.6 Pos Jaga — ⚠️ SEBAGIAN (paling jauh dari standar)

**Kode:** `scripts/pesantren_builder.gd` — 4 pos jaga putra di sudut kampus + Pos Satpam di gerbang (17,5, 0) + 1 Pos Jaga TL putri (176,−20). Semua sama: dinding + lantai **KAYU penuh (#8a5a2b)**; atap **piramida ZAMRUD_GELAP** (CylinderMesh 4-segmen); label "POS JAGA".

**Foto:** `pos-jaga-putra.png` + `pos-jaga-putra-2.png` (gubuk kayu cokelat + atap piramida hijau, lampu jalan di samping) dan `pos-jaga-tl.png` + `pos-jaga-tl-2.png` (sama, di putri — dinding putih Studio mendominasi kiri frame).

**Penilaian:** atap piramida zamrud **sesuai** (warna atap Surau). Tapi dinding kayu polos penuh: **tidak krem, tidak ada lis emas, tidak ada jendela lengkung**. Dari semua gedung, Pos Jaga yang paling jauh dari bahasa Surau. (Perlu keputusan Mas: pos jaga memang gubuk kayu — apakah dibiarkan begitu, atau disamakan bahasanya dengan Surau?)

### 2.7 Cangkruk Putra — ⚠️ SEBAGIAN (sengaja beda)

**Kode:** `scripts/pesantren_builder.gd` (−22,−18). Bangunan **kayu penuh** (KAYU + KAYU_GELAP), atap segitiga 2 pelat + pelana prisma; lis EMAS di atas pintu; jendela **ZAMRUD_GELAP kotak** (bukan lengkung); label "KAMAR CANGKRUK".

**Foto:** `cangkruk-putra.png` + `cangkruk-putra-2.png` (paling bagus dari seri ini — Cangkruk kayu cokelat + atap segitiga + 2 jendela hijau kotak + lis emas di atas pintu, bersebelahan dengan dinding Surau berlengkung + kubah di kanan; kontras kedua bahasa terlihat jelas dalam satu frame).

**Penilaian:** beda bahan dengan Surau, **tapi sesuai briefnya sendiri** (Ronde 6: "ala POS RONDA tapi tertutup dan luas"). Ada lis emas + jendela zamrud + label — usaha menyambung ke bahasa Surau sudah ada. Bukan pelanggaran; hanya beda bahasa karena beda fungsi.

### 2.8 Gerbang + tembok — ✅ SESUAI

**Kode:** tembok pemisah x=14 (z −60..+16) + Gerbang (14,0) + tembok keliling putri (x 115..216, z −70..+40) + Gerbang Putri (115,0).

**Material:** krem + lis EMAS_DESAIN + fondasi BATU; pilar krem + tutup emas; gapura krem + lis emas + atap zamrud; pintu JATI dua daun + lis emas; label "GERBANG" / "GERBANG PUTRI" 2 sisi.

**Foto:** `gerbang-tembok.png` + `gerbang-tembok-2.png` (pilar krem + tutup emas + pintu jati + label GERBANG + tembok krem panjang + lis emas di atas; serambi Surau dengan lengkung emas + kisi di kiri frame) dan `gerbang-putri.png` (gapura + pintu jati + tembok krem dua arah + label GERBANG PUTRI, jalan paving menuju gerbang).

**Penilaian:** sesuai penuh. Temboknya memang dinding krem panjang yang polos — tapi itu wajar untuk tembok, dan lis emas di atasnya memberi bahasa Surau.

### 2.9 Kelas Putra — BELUM ADA

Tidak ada gedungnya. Hanya plot "Ruang Kelas" (16,0) status terkunci di `mission_data.gd` (ambang 25 santri). Bukan temuan audit — dicatat supaya tidak dikira terlewat.

---

## 3. TEMUAN UMUM (POLA)

1. **Tidak ada texture map di gedung prosedural.** Semua gedung (kecuali Surau GLB) = warna datar + bentuk primitif. Satu-satunya texture gambar di seluruh pesantren: plakat Arab + kisi jendela di GLB Surau. Jadi kalau Mas bertanya "teksturnya sudah sesuai standar Surau?" — jawaban jujurnya: **tekstur gambar tidak ada di mana-mana, termasuk di Surau**. Yang sesuai adalah palet + bentuk.
2. **Fasad pintu gedung generik polos.** Jendela lengkung hanya dipasang di sisi samping (timur/barat). Dari arah pintu — arah yang paling sering dilihat — gedung terlihat seperti kotak krem kosong. Berlaku untuk Kelas/Kantor/Madrasah/Studio dan juga fasad barat Asrama Putra.
3. **Keempat gedung generik putri identik.** Hanya label kecil yang membedakan Kelas, Kantor, Madrasah, Studio. Dari jauh tidak bisa dibedakan.
4. **Label plakat kecil.** Label3D nama gedung kecil dan sering tertutup pemain dari dekat; dari jarak normal (8–15 m) teksnya tidak terbaca di foto.
5. **Cangkang Asrama Putri salah skala** (lihat §2.3) — temuan terbesar audit ini.
6. **Pos Jaga paling jauh dari bahasa Surau** (kayu penuh, tanpa krem/emas/lengkung).
7. **Kubah Musholla gepeng**, bukan bawang seperti Surau.

---

## 4. YANG PERLU DIPERBAIKI (USULAN — MENUNGGU KEPUTUSAN MAS)

**JANGAN dikerjakan dulu.** Urutan prioritas menurut auditor:

| # | Perbaikan | Gedung | Perkiraan kerja |
|---|---|---|---|
| P1 | **Perbesar cangkang Asrama Putri** jadi 21,5×12 m, 3 lantai (9,6 m + parapet) — samakan dengan interior + Asrama Putra | Asrama Putri | Sedang (tiru `asrama_putra.gd`, sesuaikan pintu W) |
| P2 | **Tambah jendela lengkung di fasad pintu** + lis emas vertikal di sudut fasad | Asrama Putra (barat), Kelas/Kantor/Madrasah/Studio (fasad pintu) | Ringan–sedang |
| P3 | **Pos Jaga: putuskan bahasa** — (a) biarkan kayu (gubuk memang begitu), atau (b) dinding krem + lis emas + atap zamrud dipertahankan | Pos Jaga ×6 | Ringan bila (b) |
| P4 | **Kubah Musholla jadi bentuk bawang** seperti Surau (atau biarkan — Musholla memang lebih kecil) | Musholla | Ringan (ganti mesh kubah) |
| P5 | **Texture map sungguhan** (bila Mas mau): plester/bata/batu Poly Haven CC0 di dinding krem + lantai batu — ini pekerjaan besar, mengubah semua gedung | Semua gedung | Besar — perlu keputusan Mas dulu |
| P6 | **Perbesar label plakat** nama gedung (atau pakai texture plakat seperti Surau) supaya terbaca dari jarak normal | Semua gedung generik | Ringan |

---

## 5. CARA AUDIT DILAKUKAN

- **Standar:** dump material GLB Surau headless (`skrip/dump_material_surau.gd`, 13:39) + baca `scripts/palette.gd` + `v2/konsep/desain-arsitektur/DESAIN-ARSITEKTUR.md`.
- **Kode:** baca `scripts/asrama_putra.gd`, `scripts/kampus_putri.gd`, `scripts/pesantren_builder.gd`, `scripts/palette.gd` — material/tekstur/warna per gedung dicatat dari kode, bukan dari ingatan.
- **Foto:** render headless Godot 4.7.2 lewat Xvfb manual di :99 (xvfb-run gagal start di VM ini), skrip `skrip/foto_audit_tekstur.gd` + `skrip/foto_audit_tekstur_ulangi.gd` + `skrip/foto_studio_utara.gd` (`.tscn` masing-masing). 13 viewpoint ronde 1 + 8 ulangan (posisi digeser dari sumbu pintu, nama pemain diganti "Gilang"). Semua 21 foto sudah dibaca auditor sebelum laporan ini ditulis.
- **Catatan foto:** foto ronde 1 memakai label nama pemain "Tes MP Putri" — sisa save dari tes multiplayer Dimas (kontaminasi save, bukan bug game); diperbaiki di foto ulangan (label "Gilang"). Foto `asrama-putri.png` ronde 1 gagal (kamera kejepit dinding Kelas Putri — spring memendek jadi ~1 m, frame dipenuhi jilbab); foto `studio-utara.png` ronde 1 salah arah (kamera membelakangi gedung). Keduanya diulang dan yang dipakai di laporan ini adalah versi ulangannya.
- **Yang TIDAK diaudit:** interior gedung, tekstur tanah/rumput/pohon, dan bangunan yang belum ada (Kelas Putra, Masjid Besar, Perpustakaan — masih plot/masterplan).

---

## 6. DAFTAR FOTO

`v2/foto-audit-tekstur/` — 21 file:

- Ronde 1 (label "Tes MP Putri"): `surau.png`, `asrama-putra.png`, `cangkruk-putra.png`, `gerbang-tembok.png`, `pos-jaga-putra.png`, `musholla.png`, `kelas-putri.png`, `asrama-putri.png` (gagal — kamera kejepit), `kantor-ustadzah.png`, `madrasah.png`, `studio.png`, `pos-jaga-tl.png`, `gerbang-putri.png`
- Ulangan (label "Gilang", posisi digeser): `asrama-putra-2.png`, `cangkruk-putra-2.png`, `gerbang-tembok-2.png`, `pos-jaga-putra-2.png`, `asrama-putri-2.png`, `kantor-2.png`, `pos-jaga-tl-2.png`, `studio-utara.png` (2× ambil — yang pertama salah arah, sudah ditimpa dengan yang benar)
