# RENCANA PENCAHAYAAN v2 — Cahya (lead lighting)

Dibuat: 17 Nov 2026 ~23:00 WIB, atas perintah Mas: "v2 gelap.. butuh tim bagian lighting. Lampu musholla dll. Biar lebih hidup."
Status: AUDIT + RENCANA + MODUL SELESAI, teruji headless + foto sebelum/sesudah. Integrasi final MENUNGGU export ulang Rangga (revisi Surau lurus) — modul dipasang setelah itu (lihat §7).

## 1. AUDIT — pencahayaan v2 sekarang

### 1.1 Yang sudah ada (semua di clone v1, terverifikasi dari kode)

**Langit + ambient (urusan Rangga — JANGAN DIUBAH):**
- `langit_dinamis.gd`: WorldEnvironment + ProceduralSky, `ambient_light_source = SKY`. Ambient: 0,30 (malam) → 0,60 (05:30) → 0,85 (10:00) → 0,75 (15:00) → 0,55 (17:30) → 0,32 (18:00).
- 1 DirectionalLight3D `CahayaMatahariBulan` (bayangan NYALA, matahari siang / bulan malam 0,35, warna `#a8bce8`). Azimut matahari sedang dikalibrasi ulang Rangga ke barat (revisi Surau lurus).
- Fill `CahayaIsiUtara` (`tembok_putri.gd`, Ronde 23): DirectionalLight TANPA bayangan, cull-mask layer 2 SAJA (hanya tembok putri), warna `#D0C5AE` (RGB 208,197,174), energi ikut faktor siang. Bekerja — bukan sumber gelap.

**Lampu nyata (OmniLight3D, semua hangat `#ffd9a0`, TANPA bayangan):**

| Lokasi | Jumlah | Energi | Jangkauan | Grup |
|---|---|---|---|---|
| Interior Surau | 4 gantung | 0,7 | 10 m | LampuCahaya ✓ |
| Interior Musholla | 2 gantung | 0,9 | 6 m | TIDAK ADA ✗ (lihat 1.3) |
| Interior Cangkruk (putra, z≈-300) | 1 gantung + lampu jendela | 0,7 / 1,6 | 10 / 9 m | LampuCahaya / CahayaJendela ✓ |
| Cangkang Musholla putri (134,-24) | 1 | 0,5 | 7 m | LampuCahaya ✓ |
| Cangkang Cangkruk putri (128,-12) | 1 | 0,5 | 9 m | LampuCahaya ✓ |
| Cangkang Cangkruk putra (-22,-18) | 1 | 0,5 | 9 m | LampuCahaya ✓ |
| **Total lampu nyata** | **±13** | | | |

- Lampu cangkang Surau lama `(0, 3.5, -12)` di `pesantren_builder.gd:689` SUDAH MATI: fungsinya `_surau()` (primitif) tidak lagi dipanggil di v2 — Surau primitif diganti GLB (`_surau_glb`, baris 512). Jadi GLB Surau TIDAK punya lampu di dalamnya/di serambinya.
- `LangitDinamis` menaikkan semua lampu grup `LampuCahaya` 2× di malam hari (`energi = dasar × lerp(1, 2, lampu_f)`); lampu jendela Cangkruk justru meredup di malam hari (siang 1,6 → malam 0,08) — by design, sebagai "cahaya siang".

**Tiang lampu jalan: 12 tiang, SEMUANYA visual saja.**
- `_lamp()` (`pesantren_builder.gd:1255`): tiang hitam 3 m + bola emas emisif (grup `LampuJalan`, emisi 1,5 → 4,0 di malam hari). TIDAK ADA OmniLight.
- Posisi: 8 di jalan N-S (x=-2,5; z=-70,-50,-30,10,30,50,70) + 1 JalanSurau (-6,89,-2,67) + 3 di sudut pos jaga/gubuk. (Ronde 20: "jalan dan lampu dibangun ulang, yang rapi" — tiang sudah rapi, cahayanya yang belum ada.)

### 1.2 Kenapa v2 gelap (temuan audit)

1. **Nol lampu nyata di luar ruangan.** Setelah 18:00 yang tersisa hanya bulan (0,35) + ambient (0,30). Jalan, gerbang, taman, sawah, kampus putri — gelap total, padahal 12 tiang lampu menyala secara visual (bola emisif) tapi tidak menerangi apa-apa.
2. **Foto alpha F1–F3 diambil saat senja** (langit jingga, matahari elevasi ±3°, energi → 0 di 18:00; ambient 0,55 → 0,32). Di jam itu dunia MEMANG redup — dan tidak ada lampu luar yang mengambil alih.
3. **Sisi pintu Surau GLB gelap.** Matahari sore di barat-barat daya (252°) berada di belakang bangunan; fasad selatan (pintu) membelakangi matahari. Tanpa lampu serambi, 3 lengkung pintu terbaca cokelat gelap (lihat F1).
4. **Kampus putri hampir tanpa lampu**: hanya 2× 0,5 (cangkang Musholla + Cangkruk). Kelas/Asrama/Kantor/Madrasah/Studio putri TIDAK punya lampu sama sekali.
5. **Interior Musholla tidak ikut terang di malam hari** (cacat kecil): 2 lampunya tidak masuk grup `LampuCahaya`, jadi energinya tetap 0,9 siang-malam, sementara lampu Surau naik sampai 1,4.

### 1.3 Yang TIDAK disentuh

- Matahari/key light + langit + ambient (Rangga, revisi Surau lurus).
- `v1` (`~/workspace/pesantren-verse/godot-dunia/`), deploy, `pesantren_builder.gd`, `main.gd` (selama revisi Rangga berjalan).

## 2. PRINSIP DESAIN (HP Mas — Galaxy A35)

- **Sedikit lampu, tanpa bayangan.** Semua OmniLight baru `shadow_enabled = false`, jangkauan 8–12 m (kolam cahaya lokal, bukan banjir).
- **Material emisif untuk bola lampu** (biaya nol): bola emas di tiap lampu baru + emisi dihidupkan pada 2 bola interior Musholla (hati-hati: `Palette.mat()` memakai CACHE — material harus di-`duplicate()` dulu sebelum diubah).
- **Ikut ritme langit**: semua lampu baru dimodulasi sendiri oleh modul (`energi = dasar × lerp(1, 2, f)`; f = faktor lampu dari jam, sama bentuknya dengan keyframe `K_LANGIT` di `langit_dinamis.gd`: 0 siang, 1 malam, transisi 17:30→18:00 dan 04:00→05:30). Tidak bergantung pada cache grup `LampuCahaya` (yang diisi sekali oleh `LangitDinamis`).
- **Posisi pintu Surau dibaca saat runtime** (dari `main._outdoor_door`), BUKAN hardcode — supaya tetap benar setelah Rangga meluruskan Surau (pintu pindah dari (-3,38,-6,75)).

## 3. DAFTAR LAMPU — FASE 1 (dibangun sekarang, 11 lampu baru)

Warna semua: hangat `#ffd9a0`. Semua tanpa bayangan.

| # | Nama | Posisi (dunia) | Energi siang → malam | Jangkauan | Visual |
|---|---|---|---|---|---|
| 1 | LampuPintuSurau | pintu Surau + (0, 3,0, 1,5) | 1,0 → 2,0 | 10 m | braket dinding + bola |
| 2–5 | LampuJalan (4 dari 8 tiang) | (-2,5, 3,1, -50), (-2,5, 3,1, 10), (-2,5, 3,1, 50), (-6,89, 3,1, -2,67) | 0,8 → 1,6 | 12 m | pakai bola tiang yang ada |
| 6 | LampuGerbang14 | (15,5, 3,0, 0) | 0,9 → 1,8 | 10 m | tiang + bola |
| 7 | LampuGerbangPutri | (113,5, 3,0, 0) | 0,9 → 1,8 | 10 m | tiang + bola |
| 8 | LampuPintuMusholla | (134, 3,0, -17,5) = MUSHOLLA_EXIT | 1,0 → 2,0 | 10 m | braket dinding + bola |
| 9 | LampuPintuCangkrukPutra | (-22, 3,0, -13,0) (1 m di selatan pintu (-22,-14)) | 0,8 → 1,6 | 8 m | braket dinding + bola |
| 10 | LampuPintuCangkrukPutri | (128, 3,0, -7,0) (asumsi: pintu 4 m di selatan pusat (128,-12), seperti putra) | 0,8 → 1,6 | 8 m | braket dinding + bola |
| 11 | LampuTaman | (0, 3,0, 28) (pusat taman GLB) | 0,8 → 1,6 | 10 m | tiang + bola |

**Perbaikan lampu lama (tanpa lampu baru):**
- Interior Musholla: 2 lampu `LampuOmni_1/2` dimasukkan ke grup `LampuCahaya` + meta `energi_siang = 0,9` + dimodulasi modul (0,9 → 1,8 malam); bola `Lampu_1/2` diberi emisi (material di-`duplicate()` dulu karena cache `Palette.mat`).

**Sengaja TIDAK ditambah:** interior Surau (4 lampu sudah cukup), interior Cangkruk (1 gantung + jendela sudah cukup), jalan E-W putra-putri (dilewati gerbang 14 + gerbang putri), sawah/kebun (area gelap alami, cukup bulan).

## 4. FASE 2 (SELESAI 20 Nov 2026 — Mas ACC 20:41 WIB)

Lampu pintu untuk 7 fasad yang gelap di audit 20:38 (interiornya terang).
Posisi pintu terverifikasi dari konstanta `kampus_putri.gd` (EXIT = 1,5 m di
luar pintu) + `asrama_putra.gd` ASRAMA_DOOR (-33, 0, 10). Lampu di EXIT,
pola LampuV2_PintuMusholla (braket + bola, hangat #ffd9a0, 0,9 → 1,8 malam,
jangkauan 10 m, tanpa bayangan). Koreksi dari usulan audit: Asrama Putri di
EXIT (144.5, 9) bukan di pintu (146, 9); Pos Jaga di EXIT (173, -20) bukan
(176, -20) — 176 itu di dalam gedung.

| Bangunan | Lampu | Posisi final |
|---|---|---|
| Asrama Putri | LampuV2_PintuAsramaPutri | (144.5, 3, 9), braket +X |
| Asrama Putra | LampuV2_PintuAsramaPutra | (-34.5, 3, 10), braket +X |
| Kelas Putri | LampuV2_PintuKelasPutri | (130, 3, 15.5) |
| Kantor Ustadzah | LampuV2_PintuKantorUstadzah | (142.5, 3, -33), braket +X |
| Madrasah | LampuV2_PintuMadrasah | (145.5, 3, -12), braket +X |
| Studio | LampuV2_PintuStudio | (166, 3, -17.5), braket +Z |
| Pos Jaga | LampuV2_PintuPosJaga | (173, 3, -20), braket +X |

TIDAK dikerjakan (Mas tidak menyetujui): 2 tiang jalan tambahan + naikkan
jangkauan lampu Musholla 6→8 m — DIBATALKAN sebagai bagian Fase 2.
**Koreksi terpisah (Mas 20:41, "Kurang terang"):** interior Musholla Putri
diterangkan — 2 lampu gantung dasar 0,9 → 1,3 (malam 2,6) + jangkauan
6 → 8 m; TANPA lampu baru di dalam Musholla.

## 5. ANGGARAN (Galaxy A35)

- Lampu nyata sekarang: ±13 OmniLight (0 berbayangan) + 1 DirectionalLight berbayangan (matahari/bulan) + 1 fill DirectionalLight tanpa bayangan.
- **Setelah Fase 1: ±24 OmniLight, tetap 0 berbayangan tambahan, jangkauan maks 12 m.**
- **Setelah lampu samping Surau (23:45): 30 OmniLight** = 13 lama + 2 interior gubuk (Raka, `gubuk_masuk.gd`, 0,5 / 6 m, tanpa bayangan) + 15 modul (11 Fase 1 + 4 samping). Tetap 0 berbayangan tambahan.
- Perkiraan beban: lampu omni tanpa bayangan di renderer GL Compatibility dievaluasi per klaster dalam jangkauannya saja — 24 lampu tersebar di dunia 200 m, kamera hanya melihat 3–5 sekaligus. Risiko FPS rendah; **tuas pemotong pertama: 4 lampu jalan → 2** (matikan LampuJalan di z=-50 dan z=50).
- Visual emisif (bola + tiang): biaya nol (tanpa cahaya).

## 6. MODUL

- File: `scripts/pencahayaan.gd` (`class_name PencahayaanV2`, extends Node3D) — SATU file sendiri.
- API: `PencahayaanV2.pasang(main: Node, pintu_surau: Vector3) -> PencahayaanV2`. Menempel sebagai anak dari world root (`main._pesantren["root"]`), posisi lampu dalam koordinat dunia.
- `_process`: modulasi energi semua lampu modul + 2 lampu interior Musholla dari `LangitDinamis.jam_saat_ini()`.
- Tes: `skrip/test_pencahayaan.gd` (+ `.tscn`) — headless. Foto: `skrip/foto_pencahayaan.gd` (+ `.tscn`) — xvfb-run, sebelum/sesudah per shot. Hasil: `~/workspace/pesantren-verse/v2/foto-lighting/`.

## 7. CARA PEMASANGAN (dilakukan SETELAH export ulang Rangga selesai)

Di `main.gd`, setelah dunia dibangun (di sekitar `_pesantren` selesai dibuat, sebelum/sesudah `_cuaca.mulai(...)`):

```gdscript
var cahaya := PencahayaanV2.pasang(self, _outdoor_door)
```

- `self` = Main (modul mencari `_pesantren["root"]` dan lampu interior Musholla lewat `find_child`).
- `_outdoor_door` = posisi pintu Surau dunia (sudah benar untuk Surau lurus).
- Tidak ada perubahan di `pesantren_builder.gd`. Tidak ada perubahan skrip lain. Kalau modul dihapus, dunia kembali seperti semula (lampu lama tetap jalan).

## 8. HASIL UJI (17 Nov 2026 ~23:05–23:10 WIB)

**Tes headless** (`skrip/test_pencahayaan.gd`): **17/17 LULUS, exit 0, ±3 detik.**
OmniLight di scene: 13 → 24. Modulasi malam terukur persis: PintuSurau 2,00 (dasar 1,0), Musholla 1,80 (dasar 0,9); siang kembali 1,00. Jalan maju tetap 1,20 m (tidak ada regresi gerak). Lampu pintu Surau terbukti mengikuti pintu runtime (bukan hardcode lama).

**Foto sebelum/sesudah** (`skrip/foto_pencahayaan.gd`, xvfb-run): **12/12 tersimpan, err=0**, di `foto-lighting/`. Hasil per shot (jam paksa via `LangitDinamis.debug_jam`):
- L1 interior Surau (19:00): hampir sama — kontrol, interior Surau memang tidak diubah; sesudah sedikit lebih hangat (kemungkinan frame pertama vs modulasi malam settle).
- L2 interior Musholla (19:00): lebih terang + hangat; bola lampu kini beremisi putih terang; sajadah terbaca jelas.
- L3 jalan malam (21:00): perubahan terbesar — fasad Surau krem hangat, jalan terang, rumput hijau (sebelumnya gelap total, hanya bola tiang yang menyala visual).
- L4 gerbang x=14 malam (21:00): jalan depan gerbang hangat, tiang krem, bola lampu terlihat lewat bukaan gerbang.
- L5 Surau senja (17:30): pintu Surau ada bola + kolam hangat di dinding (energi 1,4 di 17:30); matahari/bayangan tidak berubah.
- L6 taman malam (21:00): pagar bambu cokelat hangat, bedeng + bangku terbaca, jalan E-W ada kolam cahaya dari lampu gerbang.

**Catatan foto:** NPC berpindah antara shot sebelum/sesudah (patroli — Ust. Aqsal Murad + Bilal di L3, Ustadzah Mariyah di L2); bukan masalah lampu. Foto-foto ini diambil dengan revisi Surau lurus Rangga sudah di dalam proyek (fasad menghadap selatan langsung) — lampu pintu mengikuti pintu runtime.

**Dua kendala saat uji (sudah diatasi):** (1) tes pertama menggantung 6 menit tanpa output — penyebab: `global_script_class_cache.cfg` belum berisi `PencahayaanV2` (file baru), skrip tes gagal load diam-diam dan proses idle; diatasi dengan `--editor --quit` untuk refresh cache (pelajaran: file `class_name` baru wajib refresh cache dulu sebelum tes headless). (2) Parse error `Cannot infer type e_malam/e_siang` — `_modul` dideklarasi `Node` sehingga return type tidak terinferensi; diperbaiki jadi `var _modul: PencahayaanV2`.

**Belum dilakukan (sesuai perintah):** integrasi final ke `main.gd` — menunggu export ulang Rangga selesai. Cara pasang ada di §7 (satu baris).

## 9. LAMPU SAMPING SURAU (23:45 — laporan Mas: "lampu surau dari samping belum ada.. masih gelap")

Lampu pintu depan (Fase 1, #1) hanya menerangi fasad selatan + serambi. Dinding samping barat/timur (x=±8) tidak kena cahaya apa pun di malam hari. Tambahan: **4 lampu, 2 per sisi**, sistem sama (Omni hangat `#ffd9a0`, tanpa bayangan).

| # | Nama | Posisi (dunia) | Energi siang → malam | Jangkauan | Visual |
|---|---|---|---|---|---|
| 12 | LampuV2_SurauBarat_A | (-8,6, 3,0, -9) | 0,9 → 1,8 | 10 m | braket dinding ±X + bola |
| 13 | LampuV2_SurauBarat_B | (-8,6, 3,0, -19) | 0,9 → 1,8 | 10 m | braket dinding ±X + bola |
| 14 | LampuV2_SurauTimur_A | (8,6, 3,0, -9) | 0,9 → 1,8 | 10 m | braket dinding ±X + bola |
| 15 | LampuV2_SurauTimur_B | (8,6, 3,0, -19) | 0,9 → 1,8 | 10 m | braket dinding ±X + bola |

- Posisi: 0,6 m di luar dinding (x=±8,6), y=3,0; 2 lampu per sisi di tengah bentang (z=-9 dan z=-19, jarak 10 m = jangkauan, kolam cahaya saling bersentuhan, seluruh bentang 20 m tertutup).
- Braket: `_tambah_lampu` kini menerima `braket_offset` + `braket_ukuran` opsional — untuk dinding samping, braket diputar 90° (sumbu panjang = X, offset ±0,25 ke dinding). Default lama (dinding selatan) tidak berubah.
- `jumlah_lampu_baru()` 11 → 15. Tes diperbarui: `test_pencahayaan.gd` 17 → 19 cek (cek posisi 4 lampu samping + modulasi malam 1,8), `test_integrasi_pencahayaan.gd` 16 → 18 cek (cek posisi + modulasi; total omni 24 → 30 karena 2 lampu interior gubuk Raka masuk baseline — lihat §5).
- Foto: L7 (sisi barat) + L8 (sisi timur) di `foto-lighting/`, sebelum/sesudah, malam 21:00 — kamera diagonal dari tenggara/barat-daya supaya kedua lampu satu sisi terbaca dalam satu frame.

## 9.1 HASIL UJI LAMPU SAMPING (23:58 WIB)

**Tes headless: `test_pencahayaan.gd` 19/19 LULUS, `test_integrasi_pencahayaan.gd` 18/18 LULUS, exit 0.**
- 4 lampu samping di posisi benar (hangat `#ffd9a0`, jangkauan 10 m, tanpa bayangan); modulasi malam terukur 1,80 (dasar 0,9); total omni 30 = 15 lama (13 + 2 interior gubuk Raka) + 15 modul; jalan maju 1,40–2,40 m (tidak ada regresi gerak).
- Catatan: tes standalone pertama menggantung 1× (timeout 120 dtk, banjir error `main.gd:878` `_player` Nil) lalu lulus di ulang kedua ±10 dtk — kemungkinan tabrakan dengan tim Raka yang sedang mengedit file proyek paralel; bukan masalah kode lampu.

**Foto L7/L8 (skrip khusus `skrip/foto_samping_surau.gd`, 4/4 err=0) — diverifikasi Cahya:**
- L7 barat: sebelum — dinding barat hitam total (siluet kubah + lengkung saja); sesudah — dinding krem hangat sepanjang bentang, lengkung terbaca, braket + bola menyala terlihat, kolam hangat di dinding + rumput.
- L8 timur: sebelum — dinding abu-biru datar (hanya pantulan bulan), tembok x=14 hitam; sesudah — dinding krem hangat, KEDUA braket + bola terlihat jelas, tembok x=14 ikut kena limpahan hangat, jalur rumput antara Surau–tembok terang.
- Catatan foto: run penuh `foto_pencahayaan.gd` (16 shot) kena timeout 300 dtk dan hanya sampai L1-sesudah — file `L1–L6-sebelum` tertimpa versi modul-nyala (bukan sebelum murni lagi; perbandingan murni 23:05 untuk L1–L6 hilang), `L2–L6-sesudah` masih asli 23:05. L7/L8 tidak kena masalah ini (skrip khusus mencopot modul dulu untuk shot sebelum, lalu pasang lagi — sebelum/sesudah L7/L8 murni).

## 10. FASE 2 — HASIL (20 Nov 2026, ~21:00–22:05 WIB)

**Tes headless: `test_pencahayaan.gd` 27/27 LULUS, `test_integrasi_pencahayaan.gd` 18/18 LULUS, `test_v2.gd` 60/60 LULUS, exit 0.** 7 cek baru (1 per lampu pintu: posisi EXIT + hangat + 10 m + tanpa bayangan). Omni total 89 → **96** (75 lama + 21 modul). Musholla interior: jangkauan 8,0 m, malam 2,60 (dasar 1,3) terukur.

**Foto sesudah** (`skrip/foto_fase2_lampu_pintu.gd` + `_ulang.gd` + `_ulang2.gd`, xvfb-run, 12/12 err=0), dibaca sendiri oleh Cahya:
- Asrama Putri: fasad hangat, plang + pintu + kanopi terbaca (sebelum: hampir hitam).
- Asrama Putra: fasad barat hangat, plang + pintu + serambi terbaca.
- Kelas Putri: fasad selatan hangat, plang + pintu + jendela terbaca.
- Madrasah: fasad barat hangat, plang + pintu terbaca.
- Studio: fasad selatan hangat, plang + pintu terbaca.
- Kantor Ustadzah: fasad barat hangat, plang + pintu + jalan terang.
- Pos Jaga: fasad barat hangat, plang + pintu + jalan terang.
- Musholla interior: lantai + dinding belakang jelas lebih hangat dari foto audit (malam 2,6 vs 1,8); sudut barat-laut masih lebih redup dari tengah ruangan — Mas yang menilai cukup atau belum.
- Catatan jujur: 4 shot pertama dari sudut audit memperlihatkan sisi yang BUKAN sisi pintu (Asrama Putra dari tenggara, Kelas dari barat, Studio dari barat, kantor-posjaga menempel dinding seperti R1 audit) — diulang dari sisi pintu; yang dipakai bukti hanya foto ulang. Bola lampu (y=3,0) menutupi 1 huruf plang HANYA dari kamera setinggi lampu; dari mata pemain (±1,7 m) bola tampak di atas plang — bukan cacat.
- Beban HP: +7 Omni tanpa bayangan; kamera hanya melihat 3–5 sekaligus. FPS tidak bisa diukur headless — perlu T1 HP Mas. Tuas pemotong bila FPS turun: matikan 2 lampu jalan (seperti §5).
