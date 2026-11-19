# KONSEP — Tes di dalam kantor (v1)

**Permintaan Mas (20 Nov 2026, 00:24 WIB):** "harusnya tes itu masuk
kantor bukan di luar. Masuk terus duduk di kursi dan berhadapan dg
juri/ustadz yg nguji."

**Status:** KONSEP — menunggu ACC Mas. Kode game TIDAK diubah.
**Gambar:** `konsep-tes-dalam-kantor-denah.png` (denah tampak-atas
Kantor Putra baru + Kantor Ustadzah penataan ulang).
**Sumber:** `DRAF-ALUR-MISI.md` v5.4.1 (§1A langkah 6, §9 butir 19),
`KONSEP-RUANG-BELAJAR-v2-BACA-READER.md` (Sinta — belajar = baca di
reader, konsep ini TIDAK bentrok: yang berubah hanya TEMPAT tes),
`scripts/onboarding.gd` (LANGKAH, VENUE_TES), `scripts/main.gd`
(langkah 6, `_cek_pintu_kantor`, adegan belajar),
`scripts/pesantren_builder.gd` (`_kantor_putra`),
`scripts/interior_gedung_putri.gd` (`build_kantor`),
`scripts/ui_misi/tes_kenaikan_ui.gd`.

---

## 0. Masalah yang diperbaiki

### 0.1 Tes putra dibuka dari LUAR — kantor hanya fasad
Hari ini venue tes putra = `VENUE_TES_PUTRA (-18, 0, 18.5)` — titik
di DEPAN pintu utara Kantor Putra (`onboarding.gd:191`). Kantor Putra
sendiri (pusat (-18,22.5), 6×5 m, pintu utara (-18,20)) **TIDAK punya
interior** — komentar kode di `pesantren_builder.gd:1221` berkata
terus terang: *"di sini TIDAK ADA interior; tes dibuka dari luar,
venue = titik keluar."* Pemain tidak pernah masuk kantor; tes terasa
seperti kuis pop-up di lapangan.

### 0.2 Tes putri JUGA dibuka dari luar — dan TIDAK PERNAH dari dalam
Ini temuan saat menyusun konsep (terbukti dari kode):
- Venue putri = `VENUE_TES_PUTRI (148, 0, -33)` — titik TENGAH
  cangkang Kantor Ustadzah (`onboarding.gd:189-192`). Cangkang 8×6 m
  (x 144..152, z -36..-30): dari luar dinding utara/selatan jarak ke
  venue = 3,0 m ≤ `CHAT_JARAK_INTERAKSI` 3,5 m → **tes terbuka sambil
  berdiri di luar gedung**.
- Dari DALAM interior, pemain berada di (-122.5, 0, -300) — venue
  (148,-33) tidak terjangkau sama sekali. **Tes putri hari ini tidak
  pernah dibuka dari dalam**, padahal interior Kantor Ustadzah SUDAH
  ADA (`interior_gedung_putri.gd:31`, pusat (-120,-300), pintu barat,
  meja + 1 kursi + lemari + rak + papan + lampu hangat + 2 jendela)
  dan pemain SUDAH BISA masuk (`main.gd:2318` `_cek_pintu_kantor` →
  teleport ke interior, toast "Kamu masuk ke dalam Kantor Ustadzah.").
- Jadi putri pun perlu konsep ini — bukan hanya putra.

### 0.3 Tidak ada adegan ujian
Tidak ada yang menguji, tidak ada duduk berhadapan. Tes = 10 soal di
atas layar, tanpa konteks siapa yang menguji. Padahal Mas meminta
adegan: masuk → duduk → berhadapan dengan juri/ustadz.

### 0.4 Terkait: "kantor madrasah gelap"
Laporan yang sama dari Mas. Interior tes HARUS terang — lihat §5.
Penyelidikan Cahya (Madrasah vs Kantor Putra vs Kantor Ustadzah,
ukur + perbaiki) masih berjalan; konsep ini tidak memutuskan gedung
mana yang gelap.

---

## 1. Alur baru end-to-end (putra, Modul 01 sebagai contoh)

```
1. Langkah 6 aktif — "Tes kenaikan di Kantor" (teks baru, §6)
   "Masuk ke Kantor Putra, duduk di kursi, dan hadapi Ust. Sanusi
   untuk tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus
   bila benar minimal 8."
   Target peta TETAP di pintu kantor (luar) — peta tidak
   menampilkan interior.

2. Masuk kantor
   Pemain jalan ke pintu utara Kantor Putra. Pintu TERTUTUP seperti
   sekarang; jalan ke zona pintu → TELEPORT masuk (pola putri
   `_cek_pintu_kantor` — tanpa tombol, tanpa ketuk, tanpa animasi
   buka pintu v1; konsisten dengan semua interior GTA-style).
   SFX pintu + toast "Kamu masuk ke dalam Kantor Putra."

3. Penguji sudah duduk (BARU)
   Saat pemain masuk DI LANGKAH 6, Ust. Sanusi SUDAH duduk di kursi
   penguji di balik meja (di-teleport ke kursi penguji; posisi dan
   aktivitas lamanya disimpan, dikembalikan saat pemain keluar —
   pola `_mulai_adegan_belajar` / `_akhiri_adegan_belajar`).
   Kamera dialog membingkai adegan (pola adegan belajar).
   Di luar langkah 6, kantor KOSONG — penguji tidak ada.

4. Duduk berhadapan
   Pemain jalan ke kursi kosong di seberang meja → tombol △ Aksi
   "DUDUK" → duduk (pose duduk_kursi Kirana: kaki menjuntai,
   menghadap penguji) → **panel tes TERBUKA otomatis**:
   "Kantor • Tes Naik Bagian 1 (N1.T)" + subjudul baru
   "di hadapan Ust. Sanusi" — 10 soal, lulus ≥8, +20 poin.

5a. LULUS → panel hasil → +20 poin → langkah 6→7 → toast
    "kembali belajar ke Ust. Sanusi" → pemain BERDIRI (tombol
    Berdiri / gerak — pola sistem kursi Gilang; berdiri DI SAMPING
    kursi, bukan di atasnya) → jalan ke pintu → teleport keluar ke
    utara kantor (exit (-18,18.5) yang sekarang jadi titik KELUAR,
    bukan venue). Penguji kembali ke patroli / lokasi acak.
5b. GAGAL → panel hasil "belum lulus" → langkah TETAP 6 → berdiri
    → keluar → belajar lagi → kembali. Tes diulang dari soal 1
    saat duduk lagi (tidak ada resume soal).
5c. Tutup di tengah tes (tombol Keluar) → pemain tetap duduk;
    bisa berdiri dan keluar; tes diulang dari awal saat duduk lagi.

6. Masuk di luar langkah 6 (jalan-jalan)
   Boleh masuk; kantor kosong; kursi bisa diduduki tapi tes TIDAK
   terbuka. Keluar seperti biasa.
```

**Putri: alur yang sama persis**, dengan Kantor Ustadzah
(pintu barat), penguji Ustzh. Fatimah, dan interior yang sudah ada
(§4).

---

## 2. Siapa pengujinya (REKOMENDASI)

| Opsi | Penilaian |
|---|---|
| **Ust. Sanusi (putra) / Ustzh. Fatimah (putri) — REKOMENDASI** | Yang mengajar, yang menguji — nyambung dengan alur "belajar ke Sanusi/Fatimah → tes". TIDAK perlu NPC baru. Pola adegan belajar sudah ada (teleport guru ke adegan + kembalikan posisi). |
| Kyai (Ust. Aqsal M) sebagai penguji | DITOLAK untuk v1 — Kyai = pimpinan/imam; tes per modul oleh guru lebih wajar. Kyai bisa jadi penguji ujian HATAM/akhir nanti bila Mas mau (pertanyaan §10). |
| Penguji khusus (NPC baru "Ust. Penguji") | DITOLAK untuk v1 — NPC baru = model + dialog + jadwal; tidak ada nilai tambah dibanding guru yang sudah ada. |

Penguji muncul HANYA saat pemain masuk di langkah 6. Di luar itu
kantor kosong (tidak ada NPC yang "menunggu" di kantor).

---

## 3. Interior Kantor Putra (BARU) — denah

**Pola:** `InteriorGedungPutri` (GTA-style, garis z=-300, map
terpisah) — cangkang 6×5 m, tinggi 3,4, sama dengan cangkang di dunia
luar. **Slot bebas yang diusulkan: pusat x=-90** (antara Kantor
Ustadzah x -124..-116 dan Cangkruk x -67..-53 — 20 m lebih ke
tetangga terdekat). Slot final ditentukan builder (syarat: tidak
menumpuk interior lain, terdaftar di `_set_interior_terlihat`).

Denah (lokal 0..6 × 0..5, utara = atas; lihat
`konsep-tes-dalam-kantor-denah.png`):

- **Pintu UTARA tengah** (lebar 1,6 m, menghadap Asrama — sama sisi
  dengan pintu cangkang). Spawn di dalam 0,5 m dari pintu,
  menghadap selatan (ke arah meja).
- **Meja kerja di tengah ruangan** (sumbu timur-barat), **kursi
  penguji di SELATAN meja menghadap utara**, **kursi pemain di UTARA
  meja menghadap selatan** — berhadapan di seberang meja, jarak
  meja–kursi ±0,8 m tiap sisi.
- **Lemari arsip** sudut barat-daya, **rak buku** dinding timur,
  **papan pengumuman** dinding selatan (di belakang penguji),
  karpet zamrud tengah, **2 jendela** (timur + barat),
  **lampu hangat gantung** di tengah (§5).
- Semua perabot punya collision (pola interior putri).

Koordinat interior (slot pusat (-90, 0, -300); x -93..-87,
z -302.5..-297.5):

| Titik | Koordinat | Keterangan |
|---|---|---|
| Pusat ruangan | (-90, 0, -300) | 6×5 m, tinggi 3,4 |
| Pintu dalam | (-90, 0, -302.5) | utara, lebar 1,6 |
| Spawn dalam | (-90, 0, -301.9) | menghadap selatan |
| Meja | (-90, 0, -299.8) | tengah |
| Kursi pemain | (-90, 0, -300.65) | menghadap selatan |
| Kursi penguji | (-90, 0, -298.95) | menghadap utara |
| Lemari | (-92.25, 0, -298.05) | barat-daya |
| Rak | (-87.35, 0, -300.1) | dinding timur |
| Papan | (-90, 0, -297.68) | dinding selatan |

Kamera saat duduk: kamera dialog membingkai pemain + penguji + meja
(pola `_mulai_adegan_belajar`).

---

## 4. Interior Kantor Ustadzah (putri) — penataan ulang, bukan bangun baru

Interior SUDAH ADA — yang berubah hanya **posisi meja**:

- **Meja PINDAH dari menempel dinding timur (-116.55,-300) ke
  TENGAH ruangan (-120,-300)** — supaya bisa berhadapan. Hari ini
  meja menempel dinding + hanya 1 kursi: penguji duduk menghadap
  dinding, pemain tidak bisa duduk di seberangnya (di balik meja
  adalah tembok).
- **Kursi penguji di TIMUR meja (-118.85,-300), menghadap barat;
  kursi pemain (BARU, 1 buah) di BARAT meja (-121.15,-300),
  menghadap timur** — dekat pintu masuk: pemain masuk, langsung
  duduk.
- **TETAP di tempatnya:** lemari (-122.3,-302.6), rak
  (-118.3,-297.325), papan (-118.5,1.6,-302.82), lampu hangat
  (-117.2,-302.0), 2 jendela, karpet.
- Pintu masuk putri TETAP pola sekarang (jalan ke zona pintu barat
  (144,-33) → teleport ke spawn (-122.5,-300)).
- Venue putri pindah dari (148,-33) ke kursi pemain di dalam
  interior; `VENUE_TES_PUTRI` menjadi posisi kursi pemain.

---

## 5. Pencahayaan — syarat keras

- Interior tes HARUS terang di siang hari (tes bisa dibuka kapan
  saja, termasuk siang). Kantor Ustadzah sudah punya 1 lampu hangat
  + 2 jendela; **Kantor Putra baru WAJIB punya lampu hangat gantung
  + 2 jendela** (pola interior putri, §3).
- Laporan Mas "kantor madrasah gelap" masih diselidiki Cahya —
  implementasi WAJIB mengukur terang interior baru (foto + baca
  nilai cahaya) sebelum gate. Bila hasil ukur Cahya menunjukkan
  interior putri gelap, perbaiki lampunya di ronde yang sama.
- Jendela: kaca terang (bukan gelap pekat) supaya cahaya siang
  masuk — pelajaran kanopi Asrama Putri hitam pekat.

---

## 6. Perubahan alur/misi (teks + logika)

### 6.1 Teks langkah 6 (onboarding.gd LANGKAH)

| | Lama | Baru (usulan) |
|---|---|---|
| Putra, judul | "Tes kenaikan di Kantor" | TETAP |
| Putra, deskripsi | "Setelah selesai belajar, pergi ke Kantor untuk ikut tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8." | "Masuk ke Kantor Putra, duduk di kursi, dan hadapi Ust. Sanusi untuk tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8." |
| Putri, deskripsi | "Setelah selesai belajar, pergi ke Kantor Ustadzah untuk ikut tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8." | "Masuk ke Kantor Ustadzah, duduk di kursi, dan hadapi Ustzh. Fatimah untuk tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8." |
| Langkah 7 | "Lulus tes? Kembali belajar ke Ust. Sanusi (modul/bagian berikut), tes lagi di Kantor, ..." | TETAP (menyebut "Kantor" — tetap benar). |

### 6.2 Logika pemicu tes (main.gd langkah 6)

- **Lama:** jarak pemain ke venue dunia ≤ 3,5 m → `buka_tes`.
- **Baru:** pemain **DUDUK di kursi tes di dalam kantor** pada
  langkah 6 → `buka_tes`. Tombol △ "DUDUK" muncul di dekat kursi
  tes saat langkah 6 (dan kapan saja untuk duduk biasa tanpa tes).
- `VENUE_TES_PUTRA` (-18,18.5) → kursi pemain interior putra;
  `VENUE_TES_PUTRI` (148,-33) → kursi pemain interior putri.
  `venue_tes_id` tetap "kantor_putra" / "kantor_ustadzah".
- `tes_kenaikan_ui.gd`: struktur TIDAK berubah (10 soal, ambang 8,
  +20, sekali per bagian); judul tetap "Kantor • Tes Naik Bagian N
  (N.T)"; tambah subjudul "di hadapan Ust. Sanusi / Ustzh. Fatimah".
- `panel_misi_ui.gd`: label "Kantor • Tes Naik Bagian 2 (N1.T)"
  tetap; target peta = pintu kantor (luar).

### 6.3 Usulan teks kunci baru — §9 butir 19 (DRAF-ALUR-MISI)

> **19. Tes kenaikan diadakan DI DALAM kantor, duduk berhadapan
> dengan penguji (putra: Ust. Sanusi; putri: Ustzh. Fatimah).**
> Putra: Kantor Putra (-18,22.5), interior baru 6×5 di garis
> z=-300. Putri: Kantor Ustadzah (148,-33), interior sudah ada
> (meja dipindah ke tengah). **Tes TIDAK bisa dibuka dari luar
> gedung.** (Menggantikan kunci lama 21:24 — "tes putra TETAP di
> Surau sampai kantor putra dibangun"; kantor putra kini SUDAH
> dibangun.)

§1A langkah 6 + §6.2 draf diperbarui sejalan (dari "di Surau /
Kantor (luar)" menjadi "di dalam Kantor") — oleh Laras setelah ACC.

---

## 7. Ketergantungan (HARUS selesai dulu / barengan)

1. **Pose duduk_kursi Kirana — WAJIB sebelum implementasi.**
   Tanpa itu adegan ini justru memamerkan bug yang Mas laporkan:
   duduk di kursi malah bersila, berdiri dari kursi malah berdiri
   DI ATAS kursi, sarung mekar setelah duduk. Tiga-tiganya
   menyangkut persis adegan tes (penguji + pemain duduk lama).
2. **Kursi Gilang (survei + registry kursi)** — 2 kursi kantor
   (penguji + pemain) masuk registry; kursi tes DICADANGKAN — NPC
   `DUDUK_KURSI` tidak boleh mengklaimnya (pola sajadah Surau:
   Sajadah_03 dicadangkan pemain; 28 kursi + registry sudah ada
   di `npc.gd`).
3. **Cahya (pencahayaan)** — ukur interior; lampu interior baru
   (§5).
4. **Sinta v2 reader — TIDAK bentrok.** Belajar = baca di reader
   (Sinta), tes = di kantor (ini). Satu-satunya irisan: fungsi
   adegan di `main.gd` — koordinasi saat bangun.

---

## 8. Yang TIDAK berubah

- Soal / ambang / poin tes (10 soal, ≥8, +20, sekali per bagian);
  bank soal N1–N3; N2–N4 "belum tersedia" (sampai A2).
- Pola masuk interior (teleport lewat zona pintu, GTA-style) —
  tidak ada pintu yang dibuka/diketuk, tidak ada animasi buka
  pintu v1.
- Cangkang Kantor Putra di dunia luar (posisi, plakat, pintu
  utara) — tidak berubah; tapak NPC + tembusan tidak berubah
  (interior di z=-300, tidak menambah tembusan dunia).
- Sholat / khataman / lokasi lain — tidak disentuh.
- Multiplayer: v1 adegan tes = pemain + penguji saja; pemain lain
  tidak bisa ikut masuk adegan (Fase 2 nanti).

---

## 9. Rencana tes saat implementasi (rencana — bukan hasil)

- `test_tes_dalam_kantor.gd` (BARU): masuk kantor (langkah 6) →
  penguji duduk di kursi penguji → pemain duduk → panel tes
  terbuka → jawab 8 benar → lulus +20 → berdiri (DI SAMPING
  kursi, bukan di atasnya) → keluar → penguji kembali ke patroli.
  Varian gagal (7 benar) → langkah tetap 6. Varian masuk di luar
  langkah 6 → penguji tidak ada, tes tidak terbuka. Varian putri
  (Kantor Ustadzah, Fatimah).
- `test_onboarding.gd`: ekspektasi venue baru (interior) +
  deskripsi langkah 6 baru.
- `test_npc_tembus.gd`: tidak berubah (cangkang sama).
- Foto: denah (§3–§4) + foto adegan (pemain duduk berhadapan
  penguji + panel tes terbuka) — web-faithful bila panel terlibat.

---

## 10. Pertanyaan untuk Mas (jawab saat ACC)

1. **Penguji = Ust. Sanusi / Ustzh. Fatimah (yang mengajar) —
   setuju?** Atau Kyai?
2. **Masuk kantor = jalan ke pintu langsung teleport** (pola semua
   interior sekarang) — setuju? Atau mau diketuk/dibuka dulu?
3. **Denah §3–§4 (meja tengah, berhadapan)** — setuju?
4. **Putri ikut pola yang sama** (meja Kantor Ustadzah pindah ke
   tengah) — setuju?
5. **Bila gagal tes:** penguji tetap di kantor sampai pemain
   keluar, atau langsung kembali patroli? (Usulan: tetap sampai
   pemain keluar — biar adegan tidak "hilang" mendadak.)

---

## 11. Rekomendasi Laras

**Bangun dengan pola di atas.** Ini menjawab langsung permintaan
Mas: tes menjadi adegan ujian yang terasa — masuk kantor, duduk,
berhadapan dengan ustadz — bukan kuis pop-up di lapangan. Putri
ikut pola yang sama karena interiornya sudah ada (hanya pindah
meja), jadi satu ronde bisa menyelesaikan keduanya.

**Syarat mutlak:** pose duduk-kursi + sarung Kirana dan registry
kursi Gilang selesai dulu — tanpa itu adegannya justru memamerkan
bug yang Mas laporkan. Dan interior baru wajib diukur terangnya
sebelum gate (pelajaran "kantor madrasah gelap").
