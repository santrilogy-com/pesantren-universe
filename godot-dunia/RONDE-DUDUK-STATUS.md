# RONDE DUDUK — Revisi Cara Duduk Semua Karakter (17 Nov 2026)

Mas (17 Nov ~18:45 WIB): "cara duduk semua karakter juga perlu revisi biar bagus."
Game v1 keseluruhan dinilai Mas tetap lebih bagus — jadi yang diperbaiki adalah v1.
**BELUM DEPLOY** — screenshot dulu untuk ACC Mas.

## Diagnosis pose lama (dari kode + foto 05 / 05e / 06)

Akar masalah: **kaki adalah SATU kapsul kaku tanpa sendi lutut**
(`player.gd` `build_visual`: kapsul 0,55 m, pivot di pinggul).
Duduk hanya memutar batang itu ke depan (rotation.x −1,35) — sandal
menusuk ke depan/atas, "bersila" tidak terbaca. Tangan melayang
~0,45 m di atas lutut (lengan −0,85, siku −0,5).

- **Pemain duduk/menulis:** batang kaku + tangan melayang di dada.
- **Kyai (foto 06):** duduk di lantai di belakang meja rendah, kaku,
  kaki tersembunyi di balik sarung yang mengerut.
- **Ustadzah (foto 05e):** duduk di lantai tapi terbaca lonceng hijau
  (abaya mengembang, tanpa pangkuan, tanpa kitab terlihat, lengan
  tersembunyi). Foto 05 lama: ia melayang di udara, kaki menjuntai.
- **Kursi tidak ada:** kursi Kyai (5.6,−305) dan Ustadzah (65.6,−305)
  di luar grid 15 sajadah — **tidak ada sajadah di bawah keduanya,
  tidak ada rehal**; Kyai memegang kitab di tangan, Ustadzah hanya
  punya `kitab_pangku`. MejaSampar_3 (6.5,−305) di samping Kyai,
  bukan di depan; meja Musholla (64.5,−297.5) 7,5 m dari kursi Ustadzah.

## Pose baru

1. **Sendi lutut** (`build_visual`): kaki dibelah paha 0,30 m (pivot
   pinggul y=0,62) + lutut `LututKiri/Kanan` (y=0,32) + betis 0,28 m +
   sandal. Total 0,58 m ≈ kaki lama; mata kaki tetap ~0,02 m.
   Nama `KakiKiri/KakiKanan` dipertahankan di betis supaya loop warna
   kulit RONDE 11 tetap jalan; paha memakai warna sarung/abaya.
2. **Bersila pemain** (`_terapkan_pose` "duduk"): paha −0,85 (dulu
   −1,35), yaw ±0,50, z ±0,10; **lutut +2,30** (betis terlipat ke bawah
   paha), yaw lutut ±0,20 searah paha (kaki menyilang); turun −0,42;
   **tangan di pangkuan** (lengan −0,35, siku −0,20).
3. **Menulis:** kaki sama; badan membungkuk 0,20; tangan ke kitab
   (lengan −0,50, siku −0,50/−0,45); kitab pangku tetap (0, 0.86, 0.38).
4. **Kyai/Ustadzah** (`npc.gd` `_terapkan_duduk_baca`): kaki sama;
   **tangan terulur ke rehal** (lengan −0,70, siku −0,35); kitab
   pangku DISEMBUNYIKAN — kitabnya kini di atas rehal.
5. **Rehal + sajadah:** `_rehal()` baru di `interior_surau.gd` dan
   `interior_musholla.gd` — dua papan jati bersilangan (±28°) + kitab
   TERBUKA (sampul marun + 2 halaman krem ±18°), 0,55 m di depan kursi
   ke arah kiblat, menghadap pembaca. `Sajadah_Kyai` (5.6,−305) dan
   `Sajadah_Ustadzah` (65.6,−305) di bawah kursi masing-masing.
6. **Lutut ikut jalan/idle:** ayunan jalan menekuk lutut
   (`clampf(s,0,1)*0,5`); idle/sholat/salaman/melambai/tidur +
   reset `set_aksi("berdiri")` mengembalikan lutut ke 0.
7. **Pakaian duduk:** sarung 1,15→1,20 (lutut terlipat tidak menonjol);
   abaya 1,55→1,65, y 0,97→0,95 (hem menumpuk di lantai).
8. **Sandal:** offset z +0,04→−0,02 di frame lutut — saat terlipat,
   sumbu +Z lutut menunjuk ke bawah, jadi offset depan membuat sandal
   tenggelam 7 cm di bawah lantai (ditemukan tes, sudah diperbaiki).

## File diubah (hanya v1 `godot-dunia/`, v2 tidak disentuh)

- `scripts/player.gd` — PAKAIAN_DUDUK/ABAYA_DUDUK, `_knee_l/_knee_r`,
  belah kaki, pose duduk/menulis, reset lutut, ayunan jalan.
- `scripts/npc.gd` — `_knee_l/_knee_r`, `_terapkan_duduk_baca`,
  ayunan/idle/sholat.
- `scripts/interior_surau.gd` — `Sajadah_Kyai`, `Rehal_Kyai`, `_rehal()`.
- `scripts/interior_musholla.gd` — `Sajadah_Ustadzah`, `Rehal_Ustadzah`,
  `_rehal()`.

## Hasil uji

- Headless `test_duduk.gd` (Godot 4.7.2): **33/33 LULUS** —
  lutut ada, duduk paha −0,85 / lutut +2,30 / turun −0,42 / tangan
  −0,35; sandal + lutut di atas lantai; menulis kitab terlihat;
  berdiri lutut kembali 0; Kyai + Ustadzah duduk baca, lutut 2,30,
  tangan −0,70, kitab pangku sembunyi; sajadah + rehal ada (isi 5 anak).
  Satu FAIL awal (sandal −0,073) diperbaiki → lulus semua.
- Foto (xvfb-run, jam 10.00, `ronde-duduk/foto/`): D1 putra duduk
  depan, D2 putra duduk samping, D3 putri duduk depan, D4 Kyai +
  rehal, D5 Ustadzah + rehal, D6 putra menulis — **keenamnya DILIHAT
  langsung dan bagus**: sarung/abaya mengembang di lantai, tangan di
  pangkuan/kitab, Kyai + Ustadzah membaca kitab terbuka di rehal.
- Kendala foto (bukan pose): `_on_login` gagal "Server tidak
  terjangkau" karena HTTPRequest Godot di VM tidak menembus proxy
  (curl shell bisa) — skrip foto memakai `_masuk_pesantren` langsung
  (jalur tombol "Lanjutkan"). D3 pertama kosong karena save masih
  "putra" sehingga `_cek_batas` men-teleport pemain dari (130,14)
  kembali ke spawn putra — diperbaiki dengan save "putri" + jangkar
  legal. D4 pertama salah sudut (kamera di belakang Kyai) — diambil
  ulang dari sisi kiblat.

## Penilaian Xam dari foto (untuk Mas)

- D1/D2: duduk terbaca jelas dari depan + samping; tidak ada lagi
  kaki kaku menusuk ke depan. Lutut tertutup sarung — bersila terbaca
  dari siluet + tangan di pangkuan, bukan dari lipatan kaki yang
  kelihatan (sarung menutupi kaki).
- D6: paling kuat — kitab di pangkuan, kedua tangan di kitab.
- D4: Kyai membaca di rehal — rehal + kitab terbuka jelas.
- D3/D5: santriwati/Ustadzah duduk; abaya tetap bentuk lonceng
  (itu desain abaya, bukan pose) tapi tangan + kitab menjual
  pose "membaca".

## Yang belum / catatan

- Bilal/Faris/Satpam tidak punya perilaku duduk — tidak diubah
  (hanya lutut jalan/idle yang ikut).
- Skrip tes + foto diarsipkan di `~/workspace/pesantren-verse/ronde-duduk/skrip/`
  (sudah dihapus dari proyek supaya tidak ikut deploy).
