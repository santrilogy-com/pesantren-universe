# RENCANA IMPLEMENTASI 20 NPC v1 — Raka, 19 Nov 2026

Desain: `v2/konsep/DESAIN-SISTEM-NPC-v1.md` (Laras, ACC Mas 14:10).
Tugas: 10 putra + 10 putri. Satu pass Raka setelah kamera F1+F3.
Status: RENCANA — belum ada baris kode game yang diubah.

## 0. Fakta yang sudah diverifikasi dari kode (bukan dari desain)

- `npc.gd`: `_process` prioritas `_mode_sholat` > `_duduk_belajar` >
  `_patroli` > `_diam` > jalan bebas. `_segmen_bersih` + `_pick_target`
  + `_waypoint_terdekat` sudah ada (Ronde 25). `_terapkan_duduk_baca`
  mematikan kitab pangku (`visible=false`) — NPC santri BACA_* butuh
  kitab TERLIHAT (tidak ada rehal), jadi perlu varian/override.
- `main.gd _spawn_npcs` (:820-1130): Bilal (-4,4), Faris (-5,8), Kyai
  patroli, Mariyah patroli, Satpam (17,8) diam, Penjaga (173,-20) diam.
  Sanusi + Fatimah SENGAJA tidak masuk `_npcs`.
- `main.gd _mulai_sholat` (:3980): daftar sajadah jamaah HANYA
  `["Sajadah_02", "Sajadah_04"]`, `j % sajadah.size()` — Bilal tetap
  02, Faris tetap 04. Kyai/Mariyah imam, Satpam/Penjaga ikut_sholat=false.
- Sajadah FISIK: Surau 15 (grid 3x5, Sajadah_01..15, `interior_surau.gd`)
  + Sajadah_Kyai (di bawah kursi Kyai, luar grid); Musholla 15
  (`interior_musholla.gd sajadah_grid()`). Imam berdiri DI DEPAN
  Sajadah_03 (tengah baris depan) + kiblat x 1,5 m — bukan DI ATAS sajadah.
- PEMAIN saat ikut sholat diteleport ke Sajadah_03 (`main.gd` ~:4470)
  — jadi Sajadah_03 DICADANGKAN untuk pemain, jangan dipakai NPC.
- Sisa sajadah per interior: 14. Jamaah putra baru: Bilal + Faris +
  10 NPC = 12 <= 14 ✓. Jamaah putri baru: 10 NPC <= 14 ✓.
- Kursi Kyai (Surau, (5.6,-305)) + Kursi Ustadzah (Musholla, (65.6,-305))
  + Kursi Guru Madrasah (-177.4,-302.6) TERLARANG — tidak masuk inventaris.
- Pintu luar/dalam (sudah ada, dipakai ulang):
  - Cangkruk: luar (-22,-14), exit (-22,-12.5), dalam (-60,-295),
    spawn (-60,-296.5). 5 kasur: (-66,-303.3), (-66,-300.3),
    (-54,-303.3), (-54,-300.3), (-60,-303.7), kepala utara.
  - Kelas Putri: luar (130,14), exit (130,15.5), dalam (120,-297),
    spawn (118.6,-298.5). 9 meja (117.3/120/122.7 x -301.8/-300.4/-299.0);
    2 kursi per meja di (meja.x ± 0.3, meja.z + 0.55), menghadap utara
    (yaw PI). Baris belakang (z=-299.0) = 6 kursi untuk NPC.
  - Madrasah: luar (147,-12), exit (145.5,-12), dalam (-185,-300),
    spawn (-183.5,-300). 2 kursi murid: (-182.0,-297.4), (-178.8,-297.4),
    yaw PI.
  - Asrama Putra: luar (-33,10), exit (-34.5,10), dalam (-309,-300),
    spawn (-307.5,-300). 96 kasur (`bed_pos_list`).
  - Asrama Putri: luar (146,9), exit (144.5,9), dalam (-249,-300),
    spawn (-247.5,-300). 96 kasur.
- Bangku Taman Putra (GLB, tanpa collision): Bangku 1 (-3, 25.45)
  sumbu X (tabrakan 1.8 x 0.55) — kursi (-3±0.4, 25.45); Bangku 2
  (3.45, 28.2) sumbu Z (0.55 x 1.8) — kursi (3.45, 28.2±0.4).
  PERHATIAN: taman putra BERPAGAR — (0,30) dihapus Ronde 25 karena di
  dalam taman. Akses bangku = lewat pintu taman (cek `pintu_taman.gd`:
  apakah buka otomatis / perlu teleport GTA).
- Bangku Taman Putri (kode, `kampus_putri.gd`): BangkuUtara (122, 30.4)
  yaw 0 (sandaran utara, hadap selatan); BangkuSelatan (122, 33.6)
  yaw PI (hadap utara). Kursi (122±0.4, 30.4) yaw 0 / (122±0.4, 33.6)
  yaw PI. Pohon (124, 29.8) — 2 spot bersila di bawah pohon.
- Teras Musholla (134,-18) ± 2 m — bersila di lantai, 3 spot.

## 1. Nama (pool 30/gender, tanpa nama kembar, tanpa nama yang sudah dipakai)

Tidak dipakai: Bilal, Faris, Sanusi, Aqsal, Satpam, Mariyah, Fatimah,
Penjaga; santri nyata PV-0002 Atul, PV-0003 Mamad, PV-0006 Yusuf,
PV-0008 rehan, PV-0009 Salsa; nama agen (Raka, Sinta, Dita, Kirana,
Laras, Tara, Nadia, Rania, Zahra, Gilang, Dimas, Rangga, Damar, Eka,
Cahya, Arsa, Saka, Wulan, Nusa, Umar).

PUTRA (30): Ahmad, Rizki, Fajar, Ilham, Hasan, Umar, Ali, Abdullah,
Abdul, Huda, Syamsul, Mahmud, Ridwan, Fauzi, Anwar, Lutfi, Wahyu,
Zainal, Fikri, Hafidz, Iqbal, Maulana, Rafli, Rendra, Panji, Bimo,
Arif, Dedi, Thoriq, Fauzan.
PUTRI (30): Aisyah, Khadijah, Maryam, Siti, Nurul, Salma, Hana, Laila,
Dewi, Putri, Sari, Wulan, Ratna, Intan, Melati, Kartika, Ayu, Rina,
Nisa, Amira, Yasmin, Farah, Dina, Lina, Maya, Salsabila, Humaira,
Syifa, Nabila, Zahira.
Pilih 10/gender acak berseed (seed tetap di kode supaya build
deterministik — nama sama tiap run).

## 2. Wajah (1.728 kombinasi/gender)

Kulit x mata x alis x hidung x senyum x rambut x model peci x tinggi.
Implementasi: hash nama (seperti `peci_model_untuk`) -> pilih varian
tiap dimensi dari daftar kecil yang SUDAH ADA di `player.gd` /
`npc.gd` (jangan bikin mesh baru). Peci: `peci_model` Kirana
(bulat/nasional, hash nama, 50/50). Putri: hijab putih (seragam v2) +
tunik biru + sarung batik coklat; putra: baju putih + sarung hijau
garis emas (seragam v2). Alis miring Putra D DIPERTAHANKAN sebagai
varian "tegas".

## 3. Zona spawn/patroli (waypoint HANYA di dalam sub-zona)

PUTRA (5 NPC per sub-zona, 2 sub-zona per NPC? — tiap NPC 1 zona):
- P1 Plaza Surau: x -8..8, z -2..18. Waypoint: (-4,6), (-6,-2),
  (-8,8), (0,2), (-2,12).
- P2 Halaman Asrama–Cangkruk: x -36..-12, z 16..28 + koridor barat
  x -36..-28, z -14..16. Waypoint: (-20,18), (-32,24), (-28,10),
  (-16,22), (-30,-2).
- P3 Taman Selatan: x -8..8, z 22..34 — HANYA untuk DUDUK (bangku),
  bukan patroli bebas (pagar). Patroli di jalur luar taman.
- P4 Jalur Barat/Sawah: x -60..-36, z -10..30. Waypoint: (-58,-38),
  (-44,10), (-52,24), (-40,-4), (-58,8).
PUTRI:
- W1 Halaman Musholla: x 128..140, z -18..-8. Waypoint: (134,-14),
  (136,-10), (130,-16), (138,-18).
- W2 Halaman Kelas–Madrasah: x 128..160, z -8..16. Waypoint: (140,16),
  (144,4), (152,8), (136,0).
- W3 Halaman Asrama Putri: x 146..166, z 0..20. Waypoint: (152,10),
  (160,16), (148,6), (162,4).
- W4 Taman Putri: x 117..127, z 28..36 — bangku + pohon (duduk),
  patroli di jalur (122, 26)? Waypoint luar: (120,26), (126,26).
Segmen antar waypoint divalidasi `_segmen_bersih` (sudah ada).
NPC TIDAK PERNAH menyeberang tembok x=14 (zona putra x<14,
zona putri x>115).

## 4. Kursi — inventaris + registry

### 4.1 Inventaris (const di npc.gd, posisi + yaw + gedung)
LUAR (DUDUK_KURSI / BERSILA_BACA):
- bangku_taman_putra_1a/b: (-3.4,25.45) / (-2.6,25.45), yaw ? (foto)
- bangku_taman_putra_2a/b: (3.45,27.8) / (3.45,28.6), yaw ? (foto)
- bangku_taman_putri_utara_a/b: (121.6,30.4) / (122.4,30.4), yaw 0
- bangku_taman_putri_selatan_a/b: (121.6,33.6) / (122.4,33.6), yaw PI
- teras_musholla_1/2/3: (132,-18), (134,-18), (136,-18), bersila, yaw PI
  (menghadap Musholla/utara? — Musholla di z=-24, jadi hadap utara = PI)
- pohon_taman_putri_1/2: (123.2,29.8), (124.8,29.8), bersila, yaw 0
DALAM (BACA_KAMAR, teleport):
- kelas_putri belakang 6 kursi: (117.0,-298.45), (117.6,-298.45),
  (119.7,-298.45), (120.3,-298.45), (122.4,-298.45), (123.0,-298.45),
  yaw PI. Pintu luar (130,14).
- madrasah 2 kursi: (-182.0,-297.4), (-178.8,-297.4), yaw PI.
  Pintu luar (147,-12).
- cangkruk 5 kasur: (-66,-303.3), (-66,-300.3), (-54,-303.3),
  (-54,-300.3), (-60,-303.7) — duduk DI ATAS kasur (y = atas kasur,
  cek tinggi kasur di `interior_cangkruk.gd`), bersila, hadap selatan
  (yaw 0). Pintu luar (-22,-14).
- asrama putra/putri: kasur lantai dasar dekat spawn (baca
  `bed_pos_list` saat implementasi; pilih 4 per asrama). Pintu luar
  (-33,10) / (146,9).
### 4.2 Registry
`static var _kursi_registry: Dictionary = {}` di npc.gd
(seat_id -> npc). `ambil_kursi(npc, filter)` / `lepas_kursi(npc)`.
Aturan: 1 NPC 1 kursi; kursi Kyai/Ustadzah/Guru TIDAK ada di
inventaris (tidak bisa diambil); maks 4 NPC per gedung (hitung
pemegang kursi gedung itu); lepas kursi saat: selesai aktivitas,
sholat mulai, misi panel dibuka, NPC di-free.

## 5. Mesin state aktivitas (di npc.gd _process)

Prioritas baru: `_mode_sholat` > `_duduk_belajar` > `_aktivitas` >
`_patroli` > `_diam` > jalan bebas.
- Saat idle (selesai patroli / diam), lempar dadu: 35% DUDUK_KURSI,
  20% BACA_MUSHOLLA, 15% BACA_KAMAR, 15% JALAN_KITAB, 15% tetap
  patroli/jalan bebas.
- DUDUK_KURSI: ambil kursi luar (gender sesuai) -> jalan ke kursi
  (rute `_pick_target` biasa) -> duduk (`_terapkan_duduk_baca` +
  PAKAIAN_DUDUK, kitab pangku TERLIHAT) 60-180 dtk -> berdiri, lepas
  kursi, kembali patroli.
- BACA_MUSHOLLA: putri -> teras Musholla bersila + kitab; putra ->
  serambi Surau? (desain: BACA_MUSHOLLA 20% — putra baca di Surau
  luar? Cek desain: "BACA_MUSHOLLA" untuk putri di Musholla; putra
  padanannya baca di serambi Surau — implementasi: putra duduk
  bersila di plaza Surau (0,2) area? Tentukan saat implementasi
  dengan foto.)
- BACA_KAMAR: ambil kursi dalam -> jalan ke pintu luar gedung ->
  TELEPORT ke kursi (pola GTA, seperti masuk interior) -> duduk +
  kitab 60-180 dtk -> teleport kembali ke pintu luar -> lepas kursi.
- JALAN_KITAB: jalan pelan (50% kecepatan?) sambil pegang kitab
  (`_kitab()` terlihat di tangan) 30-90 dtk -> kembali patroli.
- Kitab: pakai ulang `SantriPlayer._kitab()` (prop di tangan/pangku).
- `_terapkan_duduk_baca` perlu varian `kitab_terlihat=true` untuk
  NPC santri (Kyai punya rehal, santri tidak).

## 6. Hormat

- Guru yang dihormati: Kyai, Ustadzah Mariyah, Ust. Sanusi,
  Ustzh. Fatimah — group `"guru_hormat"` (main.gd tambahkan saat
  spawn; Sanusi/Fatimah ikut karena mereka Node3D juga).
- NPC _process: bila di luar ruangan + tidak sholat + panel misi
  tidak terbuka: cek jarak ke tiap guru dalam group; bila < 4 m
  dan cooldown pasangan > 60 dtk dan cooldown NPC > 20 dtk:
  - NPC JALAN -> varian A: minggir 1 m (tegak lurus arah guru) +
    nunduk (KepalaPivot rotasi.x +) + tangan menyilang, ±3 dtk,
    lalu lanjut.
  - NPC DIAM/DUDUK -> varian B: berdiri (lepas kursi sementara?) +
    hampiri 1 m dari guru + salaman 2 dtk + cium tangan 1,5 dtk +
    kembali ke tempat; guru `jeda_patroli(4.0)` (API baru di npc.gd:
    `_jeda_sampai`, dicek di _process sebelum patroli).
  - Antrean maks 3 (hitung NPC lain yang sedang hormat ke guru itu).
- Pose: cermin pose salaman `player.gd:2083` untuk NPC (node lengan
  di visual NPC — baca konstruksi visual npc.gd saat implementasi).
  Varian A "tangan menyilang": rotasi lengan ke dalam (nilai dari foto).
- BUKAN guru: Bilal/Faris, Satpam/Penjaga, pemain — tidak dihormati.

## 7. Sholat — perluasan alokasi sajadah (main.gd _mulai_sholat)

- Daftar sajadah putra (urutan PENTING: Bilal tetap 02, Faris tetap 04):
  `["Sajadah_02", "Sajadah_04", "Sajadah_01", "Sajadah_05",
  "Sajadah_06", "Sajadah_07", "Sajadah_08", "Sajadah_09",
  "Sajadah_10", "Sajadah_11", "Sajadah_12", "Sajadah_13"]` (12 slot).
  Sajadah_03 dicadangkan untuk pemain. Sajadah_14/15 cadangan.
- Daftar sajadah putri (Musholla, `_posisi_sajadah_musholla`):
  `["Sajadah_01", "Sajadah_02", "Sajadah_04", "Sajadah_05",
  "Sajadah_06", "Sajadah_07", "Sajadah_08", "Sajadah_09",
  "Sajadah_10", "Sajadah_11"]` (10 slot).
- Cabang generik di `_mulai_sholat`: bila NPC putri
  (`npc.adalah_putri()` — accessor baru, baca `_muslimah`) ->
  rute `_rute_ke_pintu_musholla` + sajadah Musholla; bila putra ->
  rute Surau + sajadah Surau (seperti sekarang).
- Counter `j` per gender (j_putra, j_putri) supaya urutan Bilal/Faris
  tetap dan tidak tercampur.
- Timeout kumpul 25 dtk TETAP (NPC dari zona jauh mungkin telat —
  mekanisme yang sudah ada; takbir jalan dengan yang ada).

## 8. Tes

- `skrip/test_npc_20.gd` (baru): 20 NPC spawn; nama unik; gender
  benar (10/10); zona benar (putra x<14, putri x>115); peci 50/50
  campuran; wajah bervariasi; aktivitas: tiap NPC pernah duduk /
  jalan kitab dalam window tes; registry: tidak ada 2 NPC 1 kursi;
  hormat: varian A/B terpicu dalam radius; sholat: 12 sajadah putra
  + 10 putri terisi tanpa berbagi; tembusan Fase D live 0.
- Regresi: `test_npc_tembus` (Fase D 0), `test_npc_fatimah`,
  `test_fatimah`, `test_idle_diam`, `test_kamera_pinch2` (S5b).
- Performa: catat tris/draw call sebelum/sesudah (20 NPC) —
  review Rangga menyusul via Xam.
- Foto: tiap zona + duduk + baca + hormat + sholat (12+10 sajadah).

## 10. Keputusan implementasi (temuan dari kode — jujur)

- **Wajah 1.728 kombinasi TIDAK tercapai apa adanya.** `build_visual`
  (player.gd) TIDAK punya kunci outfit mata/alis/hidung/senyum/
  rambut/tinggi — geometri wajah TETAP (mata 2 titik, hidung bola,
  senyum garis lurus, rambut bola hitam). Variasi yang DIDUKUNG kode:
  kulit, kacamata, songkok, sarung, peci_model, muslimah/tunik,
  hijab_warna. Variasi v1: kulit (6 tone) x kacamata (2) x peci_model
  (2, putra) x tinggi (4 langkah via `_visual.scale` 0.96/0.99/1.02/
  1.05) = 96 kombinasi putra; putri 6 x 2 x 4 = 48 (tanpa peci,
  jilbab putih tetap). Untuk 10 NPC/gender, semua tetap beda.
  Membangun varian geometri wajah (mata/alis/hidung/senyum) adalah
  tugas TERPISAH untuk build_visual, bukan pass ini.
- **Alis miring "tegas" TIDAK dibangun.** Alis di kode HANYA untuk
  muslimah (putri), dan revisi Kirana 21:52 sudah MEMBUATNYA DATAR
  karena alis miring (PI/2 ± 0.10) terbaca "marah/jutek" di foto.
  Membangun alis miring untuk putra = menghidupkan kembali tampilan
  yang sudah ditolak. Sebagai gantinya, v1 menambah kunci outfit
  `"alis"` (bool, default false — pemain + NPC lama tidak berubah):
  sebagian NPC putra mendapat alis DATAR (sama seperti putri) sebagai
  varian wajah. Varian "tegas" = alis + kacamata + peci nasional +
  kulit gelap.
- **Pintu Taman Putra TERBUKA OTOMATIS saat NPC mendekat (<= 4 m)**
  (`pintu_taman.gd`). Akses bangku = rute 2 kaki: jalan ke titik
  gerbang (0, 24) dulu (pintu terbuka oleh proksimitas), lalu ke
  bangku. `_segmen_bersih` menolak segmen ke bangku selagi pintu
  tertutup — karena itu rute harus 2 kaki, bukan langsung.
- **BACA_KAMAR v1: Cangkruk (putra) + Kelas Putri + Madrasah
  (putri).** Kasur Asrama (96, `bed_pos_list` + `posisi_tidur_list`)
  BISA dipakai (arah kaki = tidur - pusat kasur, y duduk 0.55
  kasur bawah) — verifikasi posisi dengan probe dulu; bila ada
  yang aneh, Asrama ditunda ke v1.1 tanpa mengurangi fungsi
  (Cangkruk 5 + Kelas 6 + Madrasah 2 = 13 kursi dalam sudah cukup
  untuk probabilitas 15%).
- **BACA_MUSHOLLA putra** = bersila baca di serambi Surau
  (area (0,2) plaza selatan, hadap kiblat) — padanan putra dari
  teras Musholla putri.

1. Spawn 20 NPC (nama/wajah/zona/patroli) + tes.
2. Kursi + registry + DUDUK_KURSI/BERSILA + JALAN_KITAB + tes.
3. BACA_KAMAR (teleport interior) + BACA_MUSHOLLA + tes.
4. Hormat A/B + tes.
5. Sholat sajadah + tes.
6. Foto + laporan ke Xam.
