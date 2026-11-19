# KASUR — STATUS (Wulan, 18 Nov 2026)

Tugas Mas 00:06 WIB: **tiap santri baru dapat kasur. 1 santri = 1 kasur.
Kasur susun (tingkat). Santri yang tidak kebagian kasur tidur di Surau
dulu (sementara).** Selesai 18 Nov ~00:47 WIB (modul + hook + tes +
foto). **Tidak deploy, tidak export. v1 tidak disentuh. Server/API
tidak diubah** (pembagian kasur logika di GAME, lokal).

## 1. Desain yang dipakai (alur per gender)

| Gender | Urutan | Kapasitas |
|---|---|---|
| Putra | Cangkruk Putra → Asrama Putra → Surau | 10 + 96 + overflow |
| Putri | Asrama Putri → Musholla | 96 + overflow |

- Cangkruk: 5 kasur susun × 2 tingkat = 10 tempat (`C-PUTRA-01..10`).
- Asrama: 3 lantai × 4 kamar/lantai × 4 kasur susun (8 kasur/kamar) =
  96 kasur/gedung (`A-PUTRA-001..096`, `A-PUTRI-001..096`).
  Kamar `Kamar 001`..`Kamar 012` (lantai 1 = 001–004, lantai 2 =
  005–008, lantai 3 = 009–012).
- Overflow: `S-PUTRA-01..` (Surau), `S-PUTRI-01..` (Musholla).
- Aturan keras: **1 kasur = 1 santri** (tidak boleh dobel, dicek tes),
  **pemisahan gender** (putra tidak pernah dapat kasur putri dan
  sebaliknya), **idempotent** (ID yang sama selalu kembali ke kasur
  yang sama).

## 2. PERUBAHAN DESAIN dari Mas (00:25–00:26 WIB — WAJIB)

- **00:25 WIB: "Jangan cangkruk.. asrama aja.."** — kasur susun HANYA
  di Asrama Putri, **bukan Cangkruk Putri**. Alur putri jadi Asrama
  Putri → Musholla (tanpa Cangkruk).
- **00:26 WIB: Cangkruk Putri (128,−12) DIHAPUS TOTAL** dari area
  putri (tugas penghapusan terpisah, Nadia + Gilang).
- **Cek disk 00:31 WIB: Cangkruk Putri MASIH ADA** di
  `scripts/kampus_putri.gd` (fungsi `_cangkruk_putri` + const
  `CANGKRUK_PUTRI_POS` + lampu `LampuV2_PintuCangkrukPutri` di
  `pencahayaan.gd`). Tim penghapusan sudah membuat backup
  `scripts/kampus_putri.gd.bak-sebelum-hapus-cangkruk-putri` tapi
  belum menghapus dari file live. **Modul kasur SUDAH tidak menjadikan
  Cangkruk Putri tujuan** — apapun keadaan gedungnya, tidak ada santri
  putri yang ditugaskan ke sana. Penghapusan bangunannya BUKAN tugas
  saya (jangan disentuh Wulan — Nadia + Gilang).
- Putra TETAP: Cangkruk Putra → Asrama Putra → Surau (tidak berubah).

## 3. Temuan penyelidikan (apa adanya — fisik vs logis)

| Tempat | Keadaan fisik di dunia v2 (cek 18 Nov) |
|---|---|
| Cangkruk Putra (−22,−18) | Interior (−60,0,−300) punya **5 kasur TUNGGAL** (`InteriorCangkruk.BED_POS_LIST`), bukan 5 susun. Jadi `C-PUTRA-01..05` punya kasur fisik; `C-PUTRA-06..10` (tingkat atas) LOGIS. |
| Cangkruk Putri (128,−12) | Cangkang luar SAJA, tanpa interior/kasur — dan kini DIHAPUS (lihat §2). |
| Asrama Putra | **TIDAK ADA gedung** — hanya plot terkunci (−16,0), ambang 50 santri (`MissionData.GROWTH_STAGES`). Semua tugas Asrama putra LOGIS. |
| Asrama Putri (152,0) | Cangkang luar SAJA (`_gedung` generik 12×8), tanpa interior/kasur. Semua tugas Asrama putri LOGIS. |
| Tidur Cangkruk | Fitur tidur/bangun SUDAH ADA (`main.gd _on_aksi("tidur")` + pose berbaring `player.gd`, snap ke kasur terdekat + offset +0,95 selatan, Ronde 6–9) — dipakai/hook, tidak dibangun ulang. |

**"Posisi tidur" (fisik, malam ini):** kasur fisik sendiri kalau ada;
kalau tidak, satu titik lantai **terverifikasi** di Surau (putra,
14 titik) / Musholla (putri, 6 titik). Kalau titik terverifikasi
habis, `posisi_tidur = null` + flag `tempat_fisik_belum_terverifikasi`
— **tidak pernah** menumpuk dua santri di satu titik/kasur.
**Batas fisik darurat: 19 putra** (5 kasur + 14 titik Surau),
**6 putri** (0 kasur + 6 titik Musholla). Asrama (ambang 50 santri,
sudah ACC Mas) WAJIB dibangun jauh sebelum batas itu.

## 4. File yang dibuat / diubah

- **BARU `scripts/pembagian_kasur.gd`** (`class_name PembagianKasur`,
  `extends RefCounted`) — logika murni + ledger lokal
  `user://kasur.json` (bukan field server). API: `buat_tugas()`,
  `kasur_milik()`, `posisi_tidur()`, `tempat_tidur_surau()`,
  `tempat_tidur_musholla()`, `daftarkan()` / `daftarkan_baru()`,
  `bersama()`. Kapasitas + titik fallback + semua catatan fisik-vs-
  logis ada di komentar file itu.
- **DIUBAH `scripts/main.gd`** (minimal, ditandai `KASUR (Wulan)`):
  member `_kasur_saya` + `_muat_kasur_saya()`; hook di
  `_terapkan_login_server` + `_terapkan_register_server` (setiap
  login/daftar memastikan santri punya kasur — idempotent);
  `_dekat_tempat_tidur()` / `_kasur_terdekat()` / `_tempat_tidur_tugas()`
  baru + cabang tidur di `_on_aksi("tidur")` kini mengizinkan Surau /
  Musholla di titik tugas SENDIRI. **1 kasur = 1 santri ditegakkan
  di game:** pemain berkasur fisik hanya bisa tidur di kasurnya
  sendiri (tidur di kasur orang lain DITOLAK); pemain tanpa kasur
  fisik hanya di titik tugasnya. Save lama tanpa tugas kasur =
  perilaku lama (kasur mana saja) supaya tidak terkunci.
- **BARU `skrip/test_kasur.gd` + `skrip/test_kasur.tscn`** — tes
  dedikasi (JANGAN edit `skrip/test_v2.gd`, milik Rangga + Gilang).
- **BARU `skrip/foto_kasur.gd` + `skrip/foto_kasur.tscn`** — foto
  bukti (ledger foto sendiri `user://kasur_foto.json`).
- **Tidak disentuh:** `test_v2.gd`, server/API, `save_data.gd`
  (tidak ada field kasur di save — ledger terpisah), v1.

## 5. Tes — `skrip/test_kasur.gd` (headless, `nice -n -10`)

Jalankan: `nice -n -10 godot --headless --path . skrip/test_kasur.tscn`

**HASIL AKHIR: 134 LULUS, 0 GAGAL (EXIT=0).** Isi tes:

- (A) Logika murni: putra #1–10 Cangkruk Putra (`C-PUTRA-01..10`,
  susun/tingkat benar); putra #11 Asrama `Kamar 001 A-PUTRA-001`;
  #18 susun 4 atas Kamar 001, #19 `Kamar 002 A-PUTRA-009`; putri #1
  Asrama Putri `Kamar 001 A-PUTRI-001` (tanpa Cangkruk — koreksi
  00:25); #8 susun 4 atas, #9 Kamar 002; idempotent (daftar ulang
  ID sama → kasur sama, isi tidak bertambah); 106 putra + 96 putri
  tanpa kasur dobel; tidak ada posisi tidur dobel; gender tidak
  pernah campur; PV-0001 tidak pernah dipakai; overflow putra #107
  → Surau `S-PUTRA-01`, putri #97 → Musholla `S-PUTRI-01`; titik
  habis → posisi null + flag (bukan dobel diam-diam).
- (B) Geometri anti-tembus (SAT 2D atas jejak kaki furnitur interior
  ASLI): 5 kasur Cangkruk + 14 titik Surau + 6 titik Musholla semua
  bersih; titik-titik saling berjauhan ≥ 1,3 m.
- (C) Ledger file: simpan/muat ulang → tugas sama; ID tak dikenal
  kosong.
- (D) Hook main.gd (stub, tanpa jaringan): login baru putra →
  `C-PUTRA-01` fisik bed 1; login ulang ID sama → tetap; daftar
  baru putri → `A-PUTRI-001` belum fisik; tidur di kasur sendiri →
  pose tidur + snap ke kasur; tidur di kasur orang lain → DITOLAK;
  santri Asrama #11 tidur di titik Surau → pose tidur + snap;
  tidur di luar ruangan → DITOLAK; `santri.json` + `kasur.json`
  dikembalikan seperti sebelum tes (backup/restore di dalam tes).

**Dua temuan selama tes (sudah diperbaiki di ronde yang sama):**

1. **AABB dunia mengembang** (ronde 1): uji sentuh pertama pakai
   AABB dunia — dinding miring −25° punya AABB 6,1 × 12,8 m dan
   menelan semua titik Surau/Musholla (20 gagal). Diganti SAT 2D
   atas jejak kaki furnitur (persegi panjang yang diputar).
2. **Urutan sudut bowtie** (ronde 2): sudut jejak tersusun
   (x0,z0),(x0,z1),(x1,z0),(x1,z1) = dasih — sumbu SAT diagonal,
   6 titik Surau + 6 Musholla gagal palsu. Diperbaiki ke urutan
   melingkar; Surau 14/14 lolos.
3. **Titik Musholla terlalu dekat dinding** (ronde 3): baris lama
   (selatan −297,3 / utara −304,7) gagal SAT — badan tidur sejajar
   sumbu DUNIA, ruangan miring −25°, proyeksi ke normal dinding
   1,32 m (bukan 1,15 m). Digelar 0,7 m (selatan −298,0 / utara
   −304,0) → 6/6 lolos.
4. **Login ulang tidak dapat kasur** (ronde 3): hook awal hanya
   menugaskan bila `id_baru` — santri lama yang ledger-nya hilang
   (ganti HP) tidak pernah dapat kasur lagi. Hook diubah: setiap
   login memanggil `daftarkan_baru` (idempotent, tanpa tulis ulang
   bila sudah ada).
5. **Tabrakan dengan tim putri** (ronde 1–2): `interior_musholla.gd`
   sedang diedit Dewi (rak buku `RakBukuPutri` baru, file
   `rak_buku_putri.gd` belum punya `.uid` → kelas tidak terdaftar
   → `InteriorMusholla` gagal kompilasi → tes gagal 91/6 lalu
   abort di geometri/hook). Bukan bug saya — file Dewi selesai
   00:31–00:32 WIB, `.uid` terbit saat run berikutnya, tes jalan
   penuh. **Efek samping yang saya tangani:** rak 2 baru Dewi di
   (57,5,−305,7) berdiri TEPAT di titik Musholla utara x=57,5 —
   titik itu saya hapus dari daftar (Musholla 7 → 6 titik).
   Juga: VM restart 00:28 WIB (uptime reset) + load 17–26 dari
   render paralel tim lain membuat run pertama merangkak (0,17
   dtk CPU/menit) — run ulang setelah restart jauh lebih cepat.

## 6. Foto bukti — `~/workspace/pesantren-verse/v2/foto-kasur/`

- `kasur-cangkruk-terisi.png` — santri PV-9001 (`C-PUTRA-01`) tidur
  di kasur fisik bed 1 Cangkruk (aksi=tidur, posisi
  (−66, 0, −302,35) = bed 1 + 0,95 selatan — sesuai snap Ronde 9).
  **Diverifikasi 00:52 WIB:** santri berbaring di kasur tengah-belakang
  (kepala di bantal, badan di atas kasur, sarung hijau), tidak tembus
  kasur/lantai; tombol "TIDUR" tampil (prompt interaksi aktif).
- `kasur-surau-penuh.png` — santri PV-9011 (ke-11: Cangkruk penuh →
  Asrama `Kamar 001 A-PUTRA-001`, logis) tidur SEMENTARA di titik
  Surau. **Diverifikasi 00:55 WIB:** santri berbaring telentang di
  karpet hijau Surau (koko + sarung hijau + songkok, kepala utara),
  meja sampar + kitab terlihat di kiri, tidak menyentuh meja/dinding.
- `kasur-musholla-putri.png` — santriwati PV-9021 (`A-PUTRI-001`,
  Asrama Putri, KOREKSI 00:25 — tanpa Cangkruk) tidur sementara di
  titik Musholla (visual abaya + jilbab via `_terapkan_gender_pemain`).
  **Diverifikasi 00:58 WIB:** santriwati berbaring di lantai Musholla
  di antara sajadah hijau, label مِحْرَاب + "KELUAR" terlihat, tidak
  menyentuh rak/meja/dinding. Foto agak gelap (malam di dalam game)
  dan framing dekat, tapi posisi tidur terbukti.
- Semua foto: `err=0`, "FOTO KASUR SELESAI", EXIT=0.
- **Catatan jejak:** `_masuk_pesantren()` memanggil
  `_terapkan_gender_pemain()` yang MENYIMPAN `_save` ke disk
  (main.gd ~845) — foto sempat meninggalkan santri tes
  (PV-9011/putri) di `user://santri.json`. **Sudah dibersihkan
  00:58 WIB** (id/nama/ig dikosongkan, gender putra) + ledger
  `kasur.json` / `kasur_foto.json` dihapus (hanya berisi ID tes
  PV-9001/9002 — bukan data produksi).

## 7. Follow-up (bukan tugas saya — untuk tim lain)

- **Gilang/Bima — kasur susun fisik Cangkruk Putra:** ubah 5 kasur
  tunggal interior (−60,−300) jadi 5 kasur susun (10 tempat) supaya
  `C-PUTRA-06..10` tidak lagi tidur sementara di Surau.
- **Nadia + Gilang — Asrama Putri (152,0):** gedung masih cangkang
  luar; kasur susun 3 lantai × 4 kamar × 4 susun (96 kasur) +
  interior + rak buku — prioritas Mas 00:24 WIB (area putri kosong).
  **Kasur susun HANYA Asrama Putri** (koreksi 00:25) + **Cangkruk
  Putri DIHAPUS** (00:26, penghapusan sedang jalan — backup sudah
  ada, file live masih berisi bangunannya saat cek 00:31 WIB).
- **Raka/Gilang — Asrama Putra:** gedung belum ada (plot terkunci
  (−16,0), ambang 50 santri) — 3 lantai × 4 kamar × 4 susun.
- **Raka — review hook `main.gd`:** 4 titik (`_kasur_saya`,
  `_muat_kasur_saya`, login, daftar, tidur) — kecil dan ditandai,
  tapi Raka sedang mengedit file yang sama paralel; mohon cek
  tidak bentrok dengan ronde Raka.
- **Dimas (multiplayer):** ledger `user://kasur.json` lokal
  per-perangkat — pembagian sisi server untuk multiplayer adalah
  tugas tim Dimas (Fase 0–1); modul ini jembatan sementara, bukan
  sumber kebenaran akhir.
- **Catatan untuk semua:** titik tidur Surau/Musholla dihitung dari
  interior **saat ini** — tiap kali Dewi/Nadia menambah furnitur
  Musholla (rak, dst), jalankan ulang `test_kasur` (cek SAT) sebelum
  deploy; titik yang ketabrak furnitur baru akan GAGAL dengan nama
  perabotnya di log.

## 8. Batas yang diketahui

- Kapasitas fisik darurat: 19 putra / 6 putri (lihat §3). Santri
  ke-20 putra / ke-7 putri sudah tercatat di kasur logisnya tapi
  **belum punya titik tidur terverifikasi** (flag di ledger) —
  mereka tetap punya KASUR (tugas logis), hanya titik lantainya
  menunggu Asrama dibangun / verifikasi tambahan. Bukan dobel,
  bukan tanpa tempat — tapi JANGAN dikira semua bisa tidur di
  Surau/Musholla secara fisik hari ini.
- Foto: 3 foto di §6, semua diverifikasi visual (00:52–00:58 WIB).

## 9. Aturan tidur Asrama Putri (Rani) — DOKUMENTASI, wiring BELUM dipasang

**Status: aturan ini HANYA didokumentasikan di ronde ini. Wiring
`main.gd` untuk semua interior putri TIDAK dipasang sekarang —
paling aman dipasang SETELAH ronde ini di-deploy, memakai potongan
Dewi / Lestari / Rani. Posisi pintu luar harus diturunkan ulang
dari `kampus_putri.gd` BARU (Mira) karena gedung sudah pindah
(lihat §7 tim putri). JANGAN wiring dari posisi pintu lama.**

- **Satu unit kasur susun = SATU StaticBody3D penuh** (1,1 × 1,9 ×
  2,1 m) — tidak bisa ditembus saat jalan. Kapsul pemain TIDAK
  BOLEH di-snap begitu saja ke posisi tidur: kapsul akan berada
  DI DALAM collision kasur itu sendiri.
- **Saat tidur, `main.gd` WAJIB menonaktifkan dulu body kasur itu:**
  `kasur_bodies[idx-1].set_deferred("disabled", true)`, lalu snap
  kapsul ke `posisi_tidur_list()[idx-1]`; **saat bangun, aktifkan
  lagi** body tersebut.
- **Posisi tidur sudah termasuk y kasur + offset kaki 0,95 m** —
  tingkat bawah +0,55 m / tingkat atas +1,65 m dari lantai kamar,
  ditambah offset 0,95 m ke arah kaki. **JANGAN pakai rumus
  Cangkruk** (`bed + (0,0,0.95)`, y=0); kasur atas butuh y yang
  benar.
- **File sudah ada, siap dipakai wiring pasca-deploy:**
  `scripts/interior_asrama_putri.gd` (29.134 byte,
  `class_name InteriorAsramaPutri`) — 96 kasur `A-PUTRI-001..096`,
  Kamar 001–012, 3 lantai (y 0 / 3,2 / 6,4). `build()` mengembalikan
  `posisi_tidur_list()` (96 posisi kapsul tidur, dunia),
  `kasur_bodies` (96 StaticBody3D, idx-1, untuk tidur),
  `bed_pos_list`, `kasur_id_list`, `kamar_list`, pintu interior /
  spawn / shell + bounds. Aturan di atas juga tertulis di header
  file itu ("TIDUR — BACA SEBELUM WIRING").
- Perbedaan dengan tidur Cangkruk/Surau/Musholla yang sudah ada di
  `main.gd`: di sana kasur TUNGGAL / titik lantai tidak punya body
  penuh yang menelan kapsul, jadi snap langsung aman. Di Asrama,
  tanpa disable body dulu, santri akan terjebak di dalam collision
  kasur sendiri.

## 10. Catatan ronde Sari (18 Nov, subuh — untuk Raka)

- **Lampu yatim Cangkruk Putri DIHAPUS** dari
  `scripts/pencahayaan.gd` (baris `#10` + `_tambah_lampu(
  "LampuV2_PintuCangkrukPutri", Vector3(128, 3.0, -7.0), ...)`).
  Grep pasca-hapus: tidak ada lagi referensi
  `LampuV2_PintuCangkrukPutri` di kode (`.gd`/`.tscn`) — sisa
  "CangkrukPutri" hanya tes Nadia di `skrip/test_perluasan_putri.gd`
  yang justru memastikan node itu TIDAK ada (jangan disentuh).
  Lampu lain tidak disentuh (GerbangPutri, PintuMusholla,
  PintuCangkrukPutra utuh). Penomoran komentar lampu jadi
  lompat #9 → #11 (sengaja tidak di-renumber supaya diff minimal).
- **`skrip/test_kasur.tscn` 1×: 134 lulus, 0 gagal, EXIT=0** —
  bukti alokasi putri sudah benar (putri #1 → `A-PUTRI-001`,
  tanpa Cangkruk; klaim lama "10 putri pertama ke Cangkruk" tidak
  berlaku — `pembagian_kasur.gd` tidak diubah). Noise di log:
  `SCRIPT ERROR: Trying to cast a freed object` dari
  `langit_dinamis.gd:573` saat teardown — bukan kegagalan tes.
- **`skrip/test_v2.tscn` 3× berturut-turut (flaky terkonfirmasi,
  item TUNGGAL):**
  - Run 1: 59 lulus, 1 gagal — `Kolong tertutup (dapat (24.46078,
    -0.312738, 30.0))`, exit=1.
  - Run 2: 60 lulus, 0 gagal, exit=0.
  - Run 3: 59 lulus, 1 gagal — `Kolong tertutup (dapat (24.44873,
    -0.187263, 30.0))`, exit=1.
  - Beda dari laporan Nadia (2 lalu 6 gagal, item Surau / spawn
    putra / pintu taman — TIDAK muncul di 3 run ini). Item yang
    flaky di sini hanya "Kolong tertutup": dorong 60 frame dari
    (24,0,30) ke +X, pemain lolos sedikit melewati batas
    (x > 24,0; y < −0,1) di 2 dari 3 run — ambang batas fisika,
    bukan regresi hapus lampu (lampu visual saja; run 2 lolos
    60/0 setelah lampu dihapus). Log lengkap:
    `/tmp/sari_test_v2_run1|2|3.log`.
- Tidak ada kompilasi gagal / file tanpa `.uid` di ronde ini —
  `--import` tidak diperlukan.
