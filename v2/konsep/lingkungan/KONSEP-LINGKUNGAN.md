# KONSEP LINGKUNGAN v2 — 5 Elemen

**Dibuat:** 17 Nov 2026 (Bima, Blender Pesantren Verse), setelah Revisi 1 Surau di-ACC Mas
**Metode:** vektor datar berskala (PIL, `gambar_lingkungan.py`), palet HEX persis PV —
krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A, batu #B8B2A4.
Sama standarnya dengan lembar konsep Surau: rapi, bersih, sesuai konsep.
**Status: HANYA GAMBAR 2D — belum ada 3D yang dibangun.** Menunggu penilaian Mas;
kalau ACC baru lanjut 3D (satu elemen demi satu, atau sekaligus — Mas yang tentukan).

## File

| No | Elemen | File | Isi |
|----|--------|------|-----|
| 01 | Pohon | `lingkungan-01-pohon.png` (1080×1560) | 2 varian, tampak depan + figur skala 1,7 m |
| 02 | Taman | `lingkungan-02-taman.png` (1080×1560) | Denah atas 8×6 m + tampak depan bangku |
| 03 | Sawah | `lingkungan-03-sawah.png` (1080×1560) | Denah atas 20×12 m (4 petak) + potongan |
| 04 | Pagar | `lingkungan-04-pagar.png` (1080×1560) | 2 varian, segmen 4 m, tampak depan |
| 05 | Gubuk santri | `lingkungan-05-gubuk.png` (1080×1560) | Tampak depan + samping + denah 4×3 m |

Generator: `gambar_lingkungan.py` (dapat diulang — ubah angka, jalankan lagi).

## 01 — Pohon

- **Varian A — Pohon rindang:** tinggi ±8,5 m, tajuk ±5,5 m, batang jati 6 m
  (meruncing Ø 0,6 m → 0,4 m) + 2–3 cabang. Tajuk **3 gumpalan tumpang tindih**
  (zamrud + daun #2E7D5B + daun muda #7FB069) — bukan 1 bola lollipop seperti v1.
- **Varian B — Pohon hias kecil:** tinggi ±3,5 m, tajuk bundar Ø 2,4 m, batang 1,8 m.
- **Pakai:** A untuk halaman, tepi jalan, dekat Surau (peneduh utama); B untuk
  taman, dekat bangunan, pot besar.

## 02 — Taman

- **Denah 8 × 6 m:** rumput hijau muda; jalan batu lebar 0,8 m dari pintu selatan
  melengkung ke bangku utara; 4 bedeng bunga (2,4 × 1,2 m, tanah coklat) di 4 sudut
  dengan bunga 4 warna (merah, kuning, ungu, oranye); 1 pohon hias kecil + 3 semak.
- **Bangku jati (2×):** 1,8 m × 0,45 m tinggi duduk, sandaran 2 bilah, menghadap jalan.
- **Letak (usulan):** zona bersama selatan, dekat Surau — atau di zona penyangga
  antara putra–putri (lihat Keputusan 2).

## 03 — Sawah

- **Denah 20 × 12 m, 4 petak** @ ±9,4 × 5,4 m; pematang tanah 60 cm (bisa jalan)
  keliling + antar petak; saluran air di sisi utara.
- **Potongan:** air 15 cm di atas lumpur; padi hijau muda 50 cm, berbaris rapat
  (±0,5 m antar rumpun).
- **Letak:** barat kampus putra (sesuai peta tata letak v2 — sawah/kebun sudah di sana).

## 04 — Pagar

- **Varian A — Pagar bambu:** tinggi 1,5 m (menghalangi pandang); bilah bambu kuning
  9 cm, jarak 18 cm; 2 rel jati; tiang jati tua tiap 2 m (ujung runcing).
- **Varian B — Pagar bata rendah + lis emas:** tinggi 0,9 m (rendah, terbuka);
  bata krem + lis emas di atas; pilar krem tiap 2 m + tutup emas.
- **Pakai (usulan):** A untuk batas kebun / sawah / belakang pesantren; B untuk batas
  halaman — serasi dengan tembok putri (krem + lis emas).

## 05 — Gubuk santri (rumah panggung)

- **Ukuran:** 4 × 3 m; kolong 1,2 m; dinding 2,2 m; atap pelana → total ±4,5 m.
- **Konstruksi:** 6 tiang jati + silang kolong; lantai + dinding papan jati;
  atap pelana zamrud tua #044230 + lis emas bubungan; pintu jati 0,9 × 1,8 m;
  jendela berkisi 0,8 × 0,8 m; tangga kayu 5 anak tangga di depan;
  beranda 1 m di depan pintu.
- **Isi (denah):** 2 tikar tidur + rak kecil. Muat 2–3 santri tidur / 4–5 mengaji lesehan.
- **Kolong:** simpan kayu bakar / perkakas.
- **Letak (usulan):** dekat kebun/sawah (gubuk penjaga kebun) atau zona penyangga —
  lihat Keputusan 5.

## Keputusan untuk Mas

1. **Pohon:** pakai kedua varian (A + B), atau satu saja?
2. **Taman:** letaknya di mana — zona bersama selatan dekat Surau, atau zona penyangga?
3. **Sawah:** ukuran 20 × 12 m dan letak barat kampus putra sudah cocok?
4. **Pagar:** varian A untuk kebun/sawah + varian B untuk halaman (sesuai usulan),
   atau pilih satu varian untuk semua batas?
5. **Gubuk:** berapa unit dan di mana — dekat kebun/sawah, zona penyangga,
   atau jadi rumah santri di area asrama?
6. **Atap gubuk zamrud tua** — setuju, atau ganti warna (misal jati/seng abu-abu)?
7. **Lanjut 3D:** kalau ACC — bangun kelima elemen sekaligus, atau satu dulu
   (usul urutan: pohon → pagar → gubuk → taman → sawah)?

## Perbaikan saat menggambar (verifikasi visual)

- Judul semua lembar sempat terpotong tepi (font 42 terlalu besar) → judul
  auto-fit sampai muat 960 px.
- Lembar sawah: judul potongan sempat menimpa petak bawah → potongan digeser
  ke bawah (alas lumpur y=890).
- Lembar gubuk: label "TAMPAK DEPAN" sempat menimpa garis dimensi "4 m", dan
  label "±4,5 m" sempat menimpa tampak samping → garis dimensi lebar dipindah
  ke bawah tanah; tinggi total ditulis di judul tampak depan; garis dimensi
  kedalaman denah dihapus (sudah tertulis di judul "DENAH 4 × 3 m").
