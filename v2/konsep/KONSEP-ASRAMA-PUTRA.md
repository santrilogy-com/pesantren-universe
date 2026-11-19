# KONSEP — ASRAMA PUTRA

Lembar konsep 2D (tampak + denah) — **belum dibangun 3D, menunggu penilaian Mas.**

- Gambar: [`asrama-putra-konsep.png`](asrama-putra-konsep.png) (+ `.svg` — sama)
- Skrip gambar: `bangunan/gambar_asrama_putra.py` (matplotlib, bisa di-render ulang)
- Lokasi (masterplan v2): **(−24, 10)**, selatan jalan E–W, Zona Asrama
- Status: konsep 01 · 18 Nov 2026

## Ringkasan

| Item | Ukuran / isi |
|---|---|
| Lantai | 3 lantai × 3,2 m = **9,6 m** + parapet 0,6 m = **10,2 m** total |
| Tapak | Badan utama **18 × 12 m** + annex tangga timur **3,5 × 2,6 m** = total **21,5 × 12 m** |
| Kamar | **12 kamar** (4/lantai) × **9 × 4,7 m** = 42,3 m² per kamar |
| Kasur | **96 kasur susun** — 4 susun per kamar × 2 tingkat = 8 santri/kamar |
| Kapasitas | **±96 santri** (1 santri = 1 kasur, sesuai aturan Mas) |
| Koridor | **2,6 m** bersih, timur–barat — muat 3 orang jalan berdampingan |
| Lorong kaki kasur | **2,275 m** (kepala kasur 0,125 m dari dinding luar) |
| Tangga | Switchback 2 flight + bordes di annex timur, rampa **32,6°** — **tanpa lift** |
| Pintu utama | Dinding **barat**, lebar 1,6 m (hanya lantai 1; dinding barat lantai 2–3 utuh) |

## Keputusan desain

1. **Menyalin persis layout Asrama Putri yang sudah diperbesar & teruji** (interior
   `scripts/interior_asrama_putri.gd`, verdict Mas 08:04 + 08:06 WIB) — pintu barat +
   annex tangga timur, koridor 2,6 m, kamar 9 × 4,7 m, lorong 2,275 m. Tujuannya
   supaya tim game bisa **reuse modul Putri dengan perubahan minimal** (ID
   `A-PUTRA-xxx`, label kamar, arah hadap).
2. **Standar lapang, bukan kamar sempit Putri yang lama** (7,75 × 3,25 m, lorong
   0,9 m, koridor 1,5 m) — itu yang Mas protes ("terlalu sempit, ga enak buat
   user, apalagi kalau portrait").
3. **Atap datar + parapet zamrud 0,6 m** (bukan pelana) — selaras fasad bangunan
   putri; lis emas antar lantai; plakat "ASRAMA PUTRA" di atas pintu utama.
4. **Tangga antar lantai saja** — lift + eskalator hanya untuk Kelas 5 lantai,
   bukan Asrama (sesuai masterplan).
5. **Fasad & palet selaras bangunan putri:** krem #F2EAD6 (dinding), zamrud
   #065F46 (parapet, selimut, karpet), emas #C9A227 (lis, plakat, gagang),
   jati #7B4B2A (pintu, jendela, kasur), batu #B8B2A4 (alas & anak tangga),
   krem muda #FAF4E6 (lantai interior).
6. **1 jendela per kamar** di dinding luar (utara/selatan); jendela kecil di annex
   tangga tiap lantai; rak buku 1 per lantai di dinding koridor utara.

## Denah per lantai

Lantai 1 = Kamar **001–004**; lantai 2 = **005–008**; lantai 3 = **009–012**.
Denah lantai 2 & 3 sama dengan lantai 1, kecuali dinding barat utuh
(tanpa pintu utama).

- Utara: Kamar 001 (barat-laut), 002 (timur-laut)
- Selatan: Kamar 003 (barat-daya), 004 (timur-daya)
- Koridor di tengah (z −1,3..1,3), pintu kamar menghadap koridor
- Annex tangga di timur (x 9..12,5): flight A naik ke timur, bordes,
  flight B balik ke barat

## Isi tiap kamar (9 × 4,7 m)

- 4 kasur susun **1,1 × 2,1 m** di dinding luar (kepala di dinding, bantal +
  selimut zamrud), jarak antar kasur 2,2 m
- Lemari **1,6 × 0,55 m** di dinding koridor
- Meja bundar r 0,3 m dekat dinding luar
- Karpet **5,0 × 1,6 m** di tengah kamar
- Lampu hangat gantung di atas lorong kaki kasur
- Jendela di dinding luar + label nama kamar di atas pintu (sisi koridor)

## Penomoran kasur

`A-PUTRA-001` s.d. `A-PUTRA-096` — urut per kamar (001–008 kamar 001, dst.),
mengikuti pola `A-...` Asrama Putri.

## Pertanyaan terbuka (untuk Mas / tim game)

1. **Tapak masterplan 20 × 12 m vs total 21,5 × 12 m** — annex menjorok
   1,5 m ke timur dari tapak 20 m. Apakah tapak digeser/diperlebar, atau annex
   diterima menjorok? (Asrama Putri punya soal yang sama.)
2. **Posisi pintu cangkang luar** (pintu gedung di peta dunia, bukan denah
   interior) ditentukan saat cangkang dibangun oleh tim game — denah ini
   hanya interior (pola map terpisah + teleport, seperti Putri).
3. **Asrama ke-2 cadangan di barat** (masterplan) — dibangun nanti bila
   santri putra mendekati 96.

## Catatan

- Cangkang luar Putri saat ini hanya 12 × 8 m (placeholder) — interior
  21,5 × 12 m adalah ruang sebenarnya. Asrama Putra mengikuti pola yang sama
  sampai cangkang luar dibangun.
- Batas darurat putra saat ini 19 (5 kasur Cangkruk + 14 titik Surau);
  gedung ini menaikkan batas menjadi 96 + overflow Surau.
