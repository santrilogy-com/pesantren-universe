# TANGGA SURAU — STATUS (Rangga, builder v2)

**Terakhir diperbarui: 18 Nov 2026 ~00:18 WIB — PERBAIKAN GEOMETRI SELESAI, 3/3 CEK TANGGA LULUS.**
Siap untuk ronde export berikutnya (bukan deploy yang sedang jalan — Damar deploy build 00:03).

## Ringkasan

Tangga Surau v2 sudah bisa dinaiki pemain dari jalan E-W sampai serambi lalu
masuk pintu — tanpa macet, tanpa kaki tenggelam. Akar macet sebelumnya sudah
diperbaiki di `scripts/tangga_surau.gd` (rampa B/C + datar dipendekkan, lihat
§ Akar masalah). Semua tes headless + foto sudah diverifikasi Rangga.

## Hasil tes (18 Nov ~00:12 WIB)

`nice -n -10 godot --headless --path . skrip/test_v2.tscn` — **59 lulus, 1 gagal.**

Ketiga cek tangga LULUS:

| Cek | Hasil |
|---|---|
| Naik tangga tanpa macet | LULUS (macet=0; sebelumnya macet=46) |
| Kaki tak tenggelam | LULUS (clear min +0,001 di z=−0,29; ambang −0,03) |
| Sampai serambi + masuk pintu (di_dalam) | LULUS |

Cek pendukung tangga juga lulus: `TanggaSurau ada (7 badan: 3 rampa + 4 datar)`,
`Lantai serambi y=0.5`, `outdoor_exit di atas serambi (0,0.5,−2.3)`.

**1 gagal di luar scope tangga** (milik Gilang, pintu taman — sudah gagal sama
di tes export 00:03): `Masuk lewat pintu, berhenti di depan peti (dapat
(0.0, −0.007583, 25.27406))` — pemain berhenti di z=25,27, di luar rentang
25,7–26,5. Tidak disentuh Rangga; diteruskan ke Raka/Gilang.

## Probe ulang (18 Nov ~00:10 WIB)

`nice -n -10 godot --headless --path . skrip/probe_tangga.tscn` —
pemain jalan mulus dari (0,0,3) ke utara, masuk Surau di frame 174:

| frame | z | y | pijakan | clear |
|---|---|---|---|---|
| 0 | 2,90 | 0,001 | 0,000 | +0,001 |
| 15 | 2,30 | 0,001 | 0,000 | +0,001 |
| 30 | 1,70 | −0,007 | 0,000 | −0,007 |
| 45 | 1,20 | 0,167 | 0,000 | +0,167 |
| 60 | 0,70 | 0,317 | 0,166 | +0,151 |
| 75 | 0,17 | 0,444 | 0,333 | +0,111 |
| 90 | −0,39 | 0,501 | 0,500 | +0,001 |
| 105 | −1,09 | 0,501 | 0,500 | +0,001 |
| 135 | −2,29 | 0,501 | 0,500 | +0,001 |
| 165 | −3,49 | 0,501 | 0,500 | +0,001 |

`PROBE AKHIR z=−295,36 y=0,000 min_clear=+0,001 di z=−0,69 di_dalam=true`
— tidak ada frame macet (macet=0), kaki tidak pernah di bawah pijakan
(clear min +0,001 sepanjang lintasan).

Catatan: y≈0,31–0,32 di atas rampa (bukan 0,27 permukaan rampa) adalah
geometri kapsul yang benar di bidang miring 27,6° (titik singgung
hemisfer bawah bergeser — origin naik ±0,04 di atas permukaan), bukan
melayang; di permukaan datar y=0,501 (tepat +0,001 di atas 0,5).

## Akar masalah + obat (diterapkan 18 Nov ~00:09 WIB)

**Akar (probe v2):** pemain naik rampa A sampai datar T3 (y=0,167,
clearance +0,001) lalu MACET di z=0,95. Datar-0,333 lama (z 0,05..0,65)
mukanya jadi tembok 0,167 m: hemisfer bawah kapsul (r=0,35) menyentuh
muka itu di tinggi 0,333 saat pusat kapsul di 0,65+0,298=0,95 — sebelum
pusat mencapai awal rampa B (0,84), sehingga rampa tak pernah mengangkatnya.

**Obat** (di `scripts/tangga_surau.gd`, rampa A + datar T3 + serambi tidak berubah):

| Bagian | Lama | Baru |
|---|---|---|
| Rampa B | z 0,84 → 0,56 (30,8°) | **z 0,90 → 0,58 (27,6°)** — mulai di atas datar T3, pusat kapsul sudah naik sebelum hemisfer mencapai muka datar |
| Datar 0,333 | z 0,05..0,65 (panjang 0,60) | **z 0,30..0,58 (panjang 0,28)** |
| Rampa C | z 0,24 → −0,04 (30,8°) | **z 0,30 → −0,02 (27,6°)** — pola sama |
| Datar T1 (0,5) | z −0,85..0,00 (panjang 0,85) | **z −0,85..−0,02 (panjang 0,83)** |

Semua sudut rampa < 45° (floor_max_angle). Ujung rampa tetap tertanam di
dalam kotak datar/tanah — tidak ada muka ujung yang menyangkut kapsul.
Fungsi `pijakan(z)` tidak berubah (cermin ukuran visual GLB).

## Geometri akhir (collision, tanpa visual — GLB yang tampil)

- Rampa A: (z=1,6, y=0) → (z=1,16, y=0,166), lebar 7,2
- Datar T3: atas 0,166, z 0,72..1,25, lebar 7,2
- Rampa B: (z=0,90, y=0,166) → (z=0,58, y=0,333), lebar 6,6
- Datar T2: atas 0,333, z 0,30..0,58, lebar 6,6
- Rampa C: (z=0,30, y=0,333) → (z=−0,02, y=0,5), lebar 6,0
- Datar T1: atas 0,5, z −0,85..−0,02, lebar 6,0
- Lantai serambi: atas 0,5, z −4,1..−0,7, lebar 6,4
- `LANTAI_SERAMBI_Y = 0.5`; sandal luar di (−0,8, 0,5, −2,3);
  `outdoor_exit` (0, 0,5, −2,3). 7 badan: 3 rampa + 4 datar.

## Foto SESUDAH (18 Nov ~00:09–00:18 WIB, `v2/foto-tangga-surau/`)

SEBELUM (2 foto, 17 Nov, sudah diverifikasi Raka): `sebelum-samping-tangga.png`,
`sebelum-samping-serambi.png` — kaki tenggelam di visual (y=0 di atas T3/serambi).

SESUDAH (6 foto, pemain DIJALANKAN dari jalan E-W, bukan teleport):

| File | Isi / verifikasi |
|---|---|
| `sesudah-samping-tangga.png` | Samping timur, pemain di atas anak tangga — kaki menapak di permukaan anak tangga, tidak tenggelam, tidak melayang |
| `sesudah-tiga-perempat-tangga.png` | 3/4 tenggara — pemain di atas anak tangga teratas, kaki menapak; cek sudut kedua (360°) |
| `sesudah-samping-t1.png` | Samping timur di T1 — pemain berdiri setinggi lantai serambi (kaki terhalang pot tanaman, lihat barat) |
| `sesudah-samping-serambi.png` | Samping timur di serambi — kaki jelas menapak lantai 0,5 di depan pintu; tombol MASUK SURAU (masih di luar) |
| `sesudah-samping-barat-tangga.png` | Samping barat di rampa B — pemain mendarat di y=0,312 (z=0,7), kaki menapak permukaan rampa; cek sudut ketiga |
| `sesudah-samping-barat-t1.png` | Barat di T1, kamera tinggi dari barat-laut (diulang — foto lurus terhalang pot tanaman dari kedua sisi) — kaki jelas menapak lantai T1/serambi di tepi anak tangga teratas, sandal di sampingnya; cek sudut keempat |

**Perbaikan skrip foto (18 Nov):** run SESUDAH pertama hanya menghasilkan
2 foto yang SALAH — keduanya terambil sesudah teleport (pemain sudah di
dalam, toast "Kamu masuk ke dalam Surau"). Penyebab: di xvfb FPS rendah,
tiap frame proses = banyak langkah fisika; selama 6 frame tunggu `_foto`,
pemain jalan sampai masuk pintu. `skrip/foto_tangga_surau.gd` (mode
sesudah) diperbaiki: joystick DIHENTIKAN sebelum tiap foto, jalan lagi
sesudahnya — run kedua menghasilkan keempat foto dengan pemain masih di
luar, di titik ukur. Foto barat diambil skrip sementara
`skrip/foto_tangga_barat.gd` (pemain dijatuhkan dari sedikit di atas
permukaan lalu difoto setelah mendarat) — sudah dihapus setelah pakai.

## Yang TIDAK disentuh

- **v1** — tidak disentuh sama sekali.
- **npc.gd** — tidak disentuh. NPC sholat masih akan tembus tangga karena
  `_langkah_ke` memaksa to.y=0 — itu scope Eka.
- **Pintu taman** (1 gagal di atas) — scope Gilang.
- **Tidak ada export / deploy** dari ronde ini — file siap untuk ronde
  export berikutnya oleh Raka.

## File yang diubah

- `scripts/tangga_surau.gd` — geometri rampa B/C + datar T2/T1 (lihat tabel di atas) + komentar akar masalah.
- `skrip/foto_tangga_surau.gd` — mode sesudah: hentikan joystick sebelum tiap foto (perbaikan bug foto, lihat § Foto).
- `skrip/probe_tangga.gd` + `skrip/probe_tangga.tscn` — probe sementara, **sudah dihapus** setelah pakai.
- `skrip/foto_tangga_barat.gd` + `skrip/foto_tangga_barat.tscn` — foto barat sementara, **sudah dihapus** setelah pakai.
- Foto baru: `v2/foto-tangga-surau/sesudah-*.png` (6 file).
- File ini: `TANGGA-SURAU-STATUS.md`.

## Langkah berikut (untuk Raka)

1. Masukkan `scripts/tangga_surau.gd` (dan `skrip/foto_tangga_surau.gd`)
   ke ronde export berikutnya — tidak ada perubahan lain dari Rangga.
2. 1 gagal pintu taman (z=25,27) tetap menunggu Gilang — bukan blocker tangga.
3. NPC tembus tangga menunggu Eka (`npc.gd` `_langkah_ke`).
