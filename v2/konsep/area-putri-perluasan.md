# AREA PUTRI — PERLUASAN (18 Nov 2026, Mira, Tim Area Putri)

**Perintah Mas 00:28 WIB:** "Langsung aja ya.. intinya diperluas.." — **SUDAH DITERAPKAN
langsung di kode** (bukan sekadar konsep). Peta: [area-putri-perluasan.png](sandbox://workspace/pesantren-verse/v2/konsep/area-putri-perluasan.png)
(skrip gambar: `buat_perluasan_putri.py` — palet + skala SAMA dengan `buat_peta.py` Gilang,
supaya bisa diselaraskan ke `peta-tata-letak-v2.png`).

## 1. Batas baru

| | Lama (kode) | Baru (kode) |
|---|---|---|
| Tembok barat (x) | 115 — **TETAP** (gerbang (115,0) tetap, zona penyangga tidak dimakan) | 115 |
| Tembok timur (x) | 180 | **216** (+36 m — menelan tapak Lapangan Putri ke dalam kampus) |
| Tembok utara (z) | −52 | **−70** (+18 m — reserve Masjid Putri kini 22 m dari tembok) |
| Tembok selatan (z) | +22 | **+40** (+18 m — halaman selatan 27 m) |
| Luas | 65 × 74 m = **4.810 m²** | 101 × 110 m = **11.110 m² (×2,31)** |
| Tapak gedung | 593 m² (8 gedung, termasuk Cangkruk) | **513 m²** (7 gedung, tanpa Cangkruk) |
| Ruang terbuka | 4.217 m² | **10.597 m²** (10.277 m² bila Masjid Putri 20×16 dibangun) |

## 2. Jawaban: benarkah terlalu sempit? — YA, terbukti angka

| Titik sempit (kode lama) | Angka |
|---|---|
| Musholla – Cangkruk Putri | celah **3 m** |
| Cangkruk Putri – Kelas Putri | celah **4 m** |
| Asrama Putri – Madrasah | celah **4 m** |
| Madrasah – Studio | celah **4 m** |
| Pagar Musholla (x=140) – jalan internal (x=140,5) | celah **0,5 m** |
| Kelas Putri (130,0) & Asrama Putri (152,0) | **menutup sumbu jalan E–W (z=0)** — jalan menembus tapak |
| Reserve Masjid Putri (166,−40) – tembok utara (−52) | **4 m** |
| Pos Jaga TL (160,−35) | **berdiri DI DALAM tapak reserve Masjid Putri** |
| Lapangan Putri (198,12) – tembok timur (180) | **3 m** (di luar tembok) |
| Tapak Asrama 3 lantai / Kelas 5 lantai 20×12 | **tidak muat rapi** (Kelas 20×12 cuma 3 m dari tembok barat; Asrama 20×12 cuma 0,5 m dari jalan) |

**Sesudah perluasan** — celah terkecil antar gedung kini **4 m** (Madrasah–Studio, tetap;
Musholla–Kantor 4 m diagonal). Koridor barat yang dulu 3–4 m kini **25 m**
(Musholla–Kelas, bekas tapak Cangkruk jadi halaman). Kelas & Asrama tidak lagi
menutup sumbu E–W (celah 4 m ke jalan). Pos Jaga keluar dari tapak Masjid
(celah 10,5 m).

## 3. Tapak tiap gedung (baru)

| Gedung | Ukuran | Pusat baru | Pintu | Keterangan |
|---|---|---|---|---|
| Musholla Ar-Raudhah | 12×10 (+pagar 14×14) | (134,−24) | Selatan | tetap |
| Kelas Putri | 10×8 | **(130,10)** | Selatan | geser +10 m (U1) |
| Asrama Putri | 12×8 | **(152,9)** | Barat | geser +9 m (U5) |
| Kantor Ustadzah | 8×6 | **(148,−33)** | Barat | geser (U3) |
| Madrasah | 10×8 | (152,−12) | Barat | tetap |
| Studio | 10×8 | (166,−12) | Utara | tetap |
| Pos Jaga TL | 3×3 | **(176,−20)** | Barat | geser (U3), keluar dari tapak Masjid |
| Cangkruk Putri | 10×8 | (128,−12) | — | **DIHAPUS total** (Mas 00:26 WIB) |
| Masjid Putri (rencana) | 20×16 | (166,−40) | — | reserve peta v2, belum dibangun |
| Lapangan Putri (rencana) | 30×20 | (198,12) | — | tapak peta v2, kini DI DALAM tembok; **belum dibangun di kode** |
| Spawn Putri | — | **(140,16)** | — | geser (U1); 5 m timur Kelas, 0,5 m barat jalan |

## 4. Jalan

| Jalan | Lebar | Ukuran |
|---|---|---|
| Jalan internal x=142 | 3 m | z −35..+14 (49 m) → **z −35..+22 (57 m)**, diperpanjang 8 m ke selatan |
| Jalan E–W (z=0) | 2,5 m | satu box x −160..+160 (kode `_ground`); **berhenti di x=160 — belum sampai Lapangan Putri (183)** |
| Konektor ke tiap pintu | 2,5 m | digeser semua mengikuti gedung; KonekPosJaga jadi **31 m** (z=−21, bukan −20, supaya tidak z-fighting dengan KonekStudio z=−18) |

## 5. Selisih kode-vs-peta v2 ACC (diverifikasi dari `KONSEP-TATA-LETAK.md` + PNG)

| Gedung | Kode lama | Peta v2 ACC | Selisih | Kini di kode |
|---|---|---|---|---|
| Musholla | (134,−24) | (134,−24) | — | sama |
| Cangkruk Putri | (128,−12) | (128,−12) | — | **dihapus** |
| Kelas Putri | (130,0) | **(130,10)** | Δz +10 | ✓ diterapkan |
| Asrama Putri | (152,0) | **(152,9)** | Δz +9 | ✓ diterapkan |
| Kantor Ustadzah | (150,−28) | **(148,−33)** | Δx −2, Δz −5 | ✓ diterapkan |
| Madrasah | (152,−12) | (152,−12) | — | sama |
| Studio | (166,−12) | (166,−12) | — | sama |
| Pos Jaga TL | (160,−35) | **(176,−20)** | Δx +16, Δz +15 | ✓ diterapkan |
| Spawn Putri | (130,14) | **(140,16)** | Δx +10, Δz +2 | ✓ diterapkan |
| Masjid Putri (rencana) | — (header tembok lama tulis (134,−40)) | (166,−40) 20×16 | — | reserve (166,−40); komentar header dikoreksi |
| Lapangan Putri | — (tidak ada di kode) | (198,12) 30×20 | — | tapak saja, belum dibangun |

Catatan: masterplan (**BELUM ACC**) menaruh Kelas 5 lantai di (128,10) dan Asrama 3 lantai
di (154,10) — berbeda dari peta v2. Cadangan di PNG ini: Kelas 5L 20×12 di (128,10),
Asrama 3L 20×12 di **(156,10)** (geser +2 m dari masterplan, supaya pintu barat dapat
koridor 2,5 m ke jalan; di (154,10) koridornya cuma 0,5 m).

## 6. Yang berubah di kode (18 Nov ~00:35–01:00 WIB, Mira)

- `v2/godot-dunia/scripts/kampus_putri.gd` — backup Ayu sudah ada dan identik
  (`kampus_putri.gd.bak-sebelum-hapus-cangkruk-putri`, md5 sama — Ayu sempat backup
  tapi belum menghapus; saya yang menghapus). Dihapus: fungsi `_cangkruk_putri`
  + konstanta + pemanggilan + entri dict + `KonekCangkruk` (±4.336 karakter).
  Posisi baru (lihat §3); daun pintu Kelas pindah z 4→14 (mengikuti dinding selatan
  baru); jalan internal 49→57 m; semua konektor digeser.
- `v2/godot-dunia/scripts/tembok_putri.gd` — `KELILING_X_MAX` 180→216,
  `KELILING_Z_MIN` −52→−70, `KELILING_Z_MAX` 22→40; kelima segmen tembok + lis emas
  + fondasi dihitung ulang; gerbang (115,0) + pilar + gapura + barrier + cahaya isi
  **tidak berubah**.
- `v2/godot-dunia/scripts/pesantren_builder.gd` — **1 baris**: hapus passthrough
  `"cangkruk_putri_pos"` (kalau tidak, builder crash karena key-nya hilang dari dict
  `KampusPutri.build()`). Bukan file tim Raka/Tara.
- **Baru:** `v2/godot-dunia/skrip/test_perluasan_putri.gd` + `.tscn` (44 cek headless).
- **TIDAK disentuh:** v1 (`pesantren-verse/godot-dunia/`), `main.gd`, `player.gd`,
  `kamera.gd`, `pembagian_kasur.gd`, `buku_data.gd`, tembok x=14, zona penyangga.
  **Tidak deploy.**

## 7. Hasil tes headless (Godot 4.7.2, `--headless`)

`skrip/test_perluasan_putri.tscn` — **44 lulus, 0 gagal, exit 0.**
Dicek: konstanta tembok baru + `KELILING_GARIS`; Cangkruk Putri hilang (node, dict,
konektor); posisi v2 semua gedung (dict + mesh lantai); bekas posisi lama kosong;
raycast collision — tembok timur hit x≈215,8 (bukan 180), utara hit z≈−69,8
(bukan −52), selatan hit z≈39,8 (bukan 22), barat + gerbang barrier hit x≈115,2
(**gerbang TERTUTUP**); spawn (140,16) di dalam tembok; santriwati spawn otomatis
di (140,16) dan bisa jalan (tes jalan sebagai putra GAGAL dengan benar — `_cek_batas`
mendorong balik putra yang masuk area putri; itu perilaku benar, bukan bug).

**Regresi `skrip/test_v2.tscn`:** flaky di headless — run 1: 2 gagal; run 2 (ulang):
6 gagal, itemnya BERBEDA (spawn putra, teleport Surau, kolong, pintu taman).
Semuanya di luar file yang saya ubah (Surau / spawn putra / pintu taman).
Tidak ada git di repo ini, jadi baseline pra-perubahan tidak bisa dibandingkan
langsung — mohon Raka jalankan ulang `test_v2` 2–3× untuk konfirmasi flaky.

## 8. Keputusan — DIPUTUSKAN (Mas 13:19 WIB: "Terserah kamu — yg putri"; diputuskan Xam)

1. **Tapak Asrama 3 lantai & Kelas 5 lantai 20×12** (masterplan) — **DITUNDA.**
   Alasan: baru 1 santri putri, fasilitas sekarang cukup. **Pemicu bangun:** santri
   putri ≥25 (ambang Kelas) atau Asrama Putri 96 kasur penuh. Cadangan tapak tetap
   di PNG (emas putus-putus): Kelas 5L (128,10), Asrama 3L (156,10).
2. **Asrama ke-2** — **HALAMAN SELATAN** (z 22..40), sesuai usul. Tapak timur
   Asrama 1 tetap untuk Lapangan Putri.
3. **Lapangan Putri** — **NANTI, bareng Asrama ke-2**, saat santri putri bertambah.
   Jalan E–W kode diperpanjang ke lapangan (x=183) saat itu juga (kini berhenti
   di x=160).
4. **Bekas tapak Cangkruk (128,−12) 10×8** — **HALAMAN/TAMAN DULU** (bukan gazebo /
   taman baca). Dikerjakan Dewi 13:19 WIB.
5. **Lampu Cangkruk Putri** — **SUDAH SELESAI** sebelum keputusan ini: dihapus di
   ronde Raka (`pencahayaan.gd:97` — "Cangkruk Putri dihapus 18 Nov (dulu 15)").
6. **Peta v2 Gilang** — **YA, DISELARASKAN** ke batas + posisi baru. Dikerjakan
   Gilang 13:19 WIB (masterplan + atlas reader bila terkait).

Pertanyaan asli §8 (sebelum diputuskan) disimpan di bawah untuk arsip:

1. ~~Tapak Asrama 3 lantai & Kelas 5 lantai 20×12 (masterplan, belum ACC) —
   sudah dicadangkan di PNG (emas putus-putus). Kapan dibangun + ACC ukurannya?
   Catatan: Kelas 5L di (128,10) hanya 3 m dari tembok barat; Asrama 3L di (156,10)
   2,5 m dari jalan — itu yang paling rapi yang muat; kalau Mas mau lebih lega,
   tembok barat harus geser (makan zona penyangga — tidak disarankan).~~
2. ~~Asrama ke-2 (cadangan masterplan: timur Asrama 1) — tapak itu kini ditempati
   Lapangan Putri. Pilih: Asrama ke-2 di halaman selatan (z 22..40, luas)?
   Atau lapangan pindah? Perlu diputuskan sebelum santri putri >96.~~
3. ~~Lapangan Putri belum dibangun di kode (hanya tapak di peta v2). Bangun sekarang
   di dalam tembok, atau nanti? Jalan E–W kode juga berhenti di x=160 — perlu
   diperpanjang ke lapangan (183) bila lapangan dibangun.~~
4. ~~Bekas tapak Cangkruk (128,−12) 10×8 — jadi halaman/taman dulu (usulan di PNG),
   atau langsung gazebo / taman baca?~~
5. ~~Lampu Cangkruk Putri (`pencahayaan.gd:58`, posisi (128,−7)) kini mengambang
   di tanah kosong — hapus / pindah? (Butuh Raka; saya tidak menyentuh file itu.)~~
6. ~~Peta v2 Gilang perlu diselaraskan ke batas + posisi baru — koordinat & skala
   PNG ini sama dengan `peta-tata-letak-v2.png`, tinggal tempel.~~

## 9. Catatan untuk tim Raka (referensi yang TIDAK saya ubah)

- `pencahayaan.gd:58` — lampu `LampuV2_PintuCangkrukPutri` (128, 3.0, −7.0) mengambang
  (lihat butir 5 di atas). Lampu gerbang putri (113.5, 3.0, 0) tetap benar.
- `main.gd:207,318` — fallback default `_spawn_putri` masih `Vector3(130, 0, 14)` +
  komentar (130,14); runtime memakai dict builder (140,16) jadi aman, tapi komentar
  & fallback sebaiknya diselaraskan.
- `main.gd:2287`, `ui.gd:2119,2356` — komentar masih tulis tembok lama
  "x 115..180, z −52..+22"; kodenya baca `TembokPutri.KELILING_GARIS` dinamis (aman).
- `pembagian_kasur.gd` — sudah benar pasca-koreksi Mas 00:25 WIB (PUTRI: Asrama →
  Musholla overflow; Cangkruk Putri tidak ditugaskan). Komentar baris 33 masih tulis
  "Asrama PUTRI (152,0)" — posisi lama, hanya komentar.
- `_cek_batas` (`main.gd:1360`) — batas selatan zona larangan z=16: santriwati
  spawn (140,16) tepat di garis batas; jalan ke utara (z<16) legal untuk putri,
  putra didorong balik. Terverifikasi di tes headless.
