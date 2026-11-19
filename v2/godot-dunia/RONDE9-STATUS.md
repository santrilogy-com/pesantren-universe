# RONDE 9 — Perbaikan KARAKTER (16 Nov ~05:25–06:00 WIB, Raka)

**Pemicu:** verdict Mas 16 Nov ~05:25 WIB dari game live: *"Kopyah aneh..
Pose duduk aneh, Pose tidur aneh, Pose menulis aneh, Bahu dan dada aneh.
Banyak yg aneh² masih."* + tambahan Mas 05:33 WIB (soal tidur):
*"Kalau tidur kepalanya tembus ke luar 🤣"*.

**Aturan:** karakter TETAP primitif Godot (jalur Blender ditutup Mas).
Tidak ada perubahan logika misi/poin/save/deploy — hanya `scripts/player.gd`
(karakter + pose), `scripts/main.gd` (1 baris: offset snap tidur), dan
`scripts/interior_cangkruk.gd` TIDAK diubah (kasur tetap menempel dinding
utara — yang salah adalah offset snap, bukan posisi kasur).

## 1. Kopyah — dari "ember" jadi kubah

**Yang aneh (foto ronde 8/6):** peci silinder putih TINGGI dan LURUS
(0.19/0.225, tinggi 0.13 di y=1.87) seperti ember/timba di atas kepala;
rambut hitam menutupi separuh belakang kepala seperti helm.

**Yang diubah (`player.gd`):**
- Peci jadi KUBAH: bola r=0.23 skala (1.0, 0.62, 1.0) di y=1.79 —
  atas membulat, duduk RENDAH menutupi ubun-ubun, puncak 1.933 (hanya
  0.03 di atas puncak kepala 1.90). Lis lama (#d8d2c2 di y=1.81) dihapus,
  diganti "PeciBand" (silinder 0.225/0.235, tinggi 0.035, di y=1.78,
  warna songkok digelapkan 0.12).
- Rambut diperkecil + dinaikkan: bola r=0.235 skala (1.0, 0.68, 1.0) di
  (0, 1.76, -0.08) — kini hanya jambul yang mengintip di bawah tepi
  songkok (sisi + tengkuk), bukan helm.

**Bukti:** `foto-ronde9/01-berdiri-depan.png` (kubah putih rendah mengikuti
kepala, rambut hitam terlihat di bawah tepinya), `02-berdiri-samping.png`
(profil: kubah + rambut belakang), `03-berdiri-belakang.png` (rambut
sebagai jambul di bawah peci, bukan mangkuk hitam), `10-berdiri-jauh.png`
(siluet terbaca dari jauh). **Dinilai: BAGUS** — ember hilang.

## 2. Bahu + dada — dari "football + rompi" jadi torso menyatu

**Yang aneh:** BahuYoke elipsoid 0.62 m = bantalan bahu pemain football
dengan lipatan terlihat; dada kotak pipih dengan lis strip + 4 kancing
emas di tengah seperti rompi.

**Yang diubah (`player.gd`):**
- **BahuYoke DIHAPUS.** Lengan muncul DARI DALAM torso: pivot
  (±0.29, 1.33) → **(±0.235, 1.30)** — hanya 0.025 di luar permukaan
  torso (r=0.21); tabung lengan (r=0.10) menembus torso 0.08 m sehingga
  menyatu tanpa celah; bola bahu kecil (r=0.115 → **0.095**) hanya
  mengisi sudut ketiak. Lebar bahu total 0.77 → **0.66 m**. Rotasi
  z lengan ±0.07 → ±0.05.
- Torso: kapsul r 0.23 → **0.21**, tinggi 0.62 → **0.66**, pusat y=1.06
  (lebih ramping + panjang, tidak kotak-pipih); **lis dada DIHAPUS**;
  kancing 4 → **3** butir kecil (r=0.016, y=1.27/1.16/1.05, z mengikuti
  permukaan kapsul) langsung di kapsul; kerah cincin (0.11/0.13, 0.07)
  di y=1.40 warna koko (bukan krem pucat).
- Lengan tetap meruncing 0.10 → 0.08 → 0.058, tangan bola pipih
  (1.0, 0.7, 1.3) r=0.072.

**Bukti:** `01-berdiri-depan.png` (bahu melandai dari leher, dada kapsul
dengan 3 kancing kecil, tanpa strip rompi), `02-berdiri-samping.png`
(torso ramping dari samping, lengan menempel natural), `03-berdiri-belakang.png`
(punggung polos tanpa bantalan). **Dinilai: BAGUS** — football + rompi
hilang. Catatan jujur: lengan saat diam tetap tabung lurus sederhana
(tangan bola kecil) — wajar untuk primitif, tidak lagi terbaca "balok".

## 3. Duduk bersila — dari "gumpalan membungkuk" jadi orang duduk

**Yang aneh (foto ronde 7/01):** dari belakang karakter jadi gumpalan
kecil membungkuk; kaki bersila tidak terbaca — sarung tabung kaku
(y 0.10–0.90) menyembunyikan kaki yang terlipat dan tenggelam saat
visual turun -0.50.

**Yang diubah (`player.gd` `_terapkan_pose` "duduk" + `PAKAIAN_DUDUK`):**
- Badan TEGAK (rot.x 0.12 → **0.05**), turun secukupnya (visual.y
  -0.50 → **-0.42** — sarung tidak lagi tenggelam ke tanah).
- Kaki MENYILANG ke depan: rot.x -1.35 + **yaw ±0.45** + z ±0.15
  (dulu hanya terlipat di balik sarung).
- Sarung MENGERUT jadi lipatan di pangkuan: skala (1.15, **0.45**, 1.15),
  y **0.68** (dulu tabung tegak) + hem/trim ikut naik (y 0.52/0.54) —
  kaki bersila terlihat, bukan tabung.
- Tangan ke tengah pangkuan (rot.x -0.85, z ±0.15 ke dalam, siku -0.5).

**Bukti:** `04-duduk-depan.png` (badan tegak, tangan bertemu di pangkuan,
lutut + sandal terlihat di bawah lipatan sarung), `05-duduk-samping.png`
(profil duduk: torso tegak, lengan ke depan-bawah, kaki bersila +
telapak terlihat). **Dinilai: BAGUS** — terbaca sebagai orang duduk
bersila dari depan dan samping.

## 4. Tidur — dari "kepompong" jadi orang berbaring + KEPALA TIDAK TEMBUS

**Yang aneh (foto ronde 7/03):** badan berbaring jadi kepompong/kubah
besar warna sarung, kepala nyaris tidak terlihat, peci melayang ~0.2 m
melewati kepala, dua bola kecil (tangan) mencuat di samping.

**Yang aneh (Mas 05:33 WIB, ketawa):** *"Kalau tidur kepalanya tembus
ke luar"* — kepala menembus dinding/headboard utara cangkruk, kelihatan
dari luar bangunan.

**Akar masalah kepala tembus (TERUKUR, bukan tebakan):** origin pemain
ada di KAKI — rotasi tidur memutar visual di origin, jadi kepala jatuh
**1.66 m ke utara origin**. Offset snap lama +0.15 ke selatan menaruh
kepala di bed_z-1.51. Probe headless (sebelum perbaikan): kasur
utara-tengah kepala z=**-305.21**, ujung kepala **-305.45** — melewati
muka LUAR dinding utara (-305.125) sejauh 0.32 m; peci z=-305.34 juga
di luar. Kasur barat/timur-utara: kepala menembus 0.17 m KE DALAM
dinding (ujung -305.05 vs muka dalam -304.875).

**Yang diubah:**
- `player.gd` pose "tidur": sarung + torso DIPIPIHKAN (bukan kubah):
  sarung skala (1.15, 1.0, **0.55**), torso skala (1.0, 1.0, **0.6**)
  — badan terbaring DATAR seperti di bawah selimut; visual.y 0.58
  (badan di atas kasur, bukan tenggelam); lengan ke sisi badan
  (z ±0.30 ke luar, bukan mencuat); peci skala z **0.7** (ikut pipih,
  tidak melayang melewati kepala); bubble + label nama disembunyikan.
- `main.gd` `_on_aksi("tidur")`: offset snap **+0.15 → +0.95** ke
  selatan. Dengan +0.95: kepala di bed_z-0.71 (tepat di atas bantal,
  pusat -0.75), ujung kepala -0.95 masih di atas kasur (tepi -1.0),
  kaki di +0.88 (tepi +1.05) — badan 1.83 m pas di kasur 2.1 m.
  Kasur TIDAK digeser (tetap menempel dinding utara, sesuai desain).
- `player.gd` `_process`: label nama disembunyikan saat tidur
  (`_aksi != "tidur"`) — sebelumnya `_terapkan_pose` menyembunyikannya
  tapi `_process` menampilkannya lagi tiap frame (label melayang 2.1 m
  melewati kepala).

**Bukti:**
- `06-tidur-samping.png` (retake, FOV 60): badan DATAR di kasur, kepala
  utuh di atas bantal putih, peci menempel di kepala, jarak jelas ke
  headboard/dinding — bukan kepompong, bukan tembus.
- `07-tidur-kaki.png` (retake, pitch +0.10): dari arah kaki — gundukan
  sarung biru di depan, kubah peci di ujung jauh, tangan di sisi badan.
  Sudut ini memang foreshortening (gundukan), bukan cacat pose.
- `11-tidur-luar-utara.png` (2 versi: 6.5 m + 3.5 m): muka LUAR dinding
  utara bersih — TIDAK ADA kepala yang nongol.
- Angka (test_ronde9, 5 kasur): kepala terjauh (kasur utara-tengah)
  ujung z=**-304.646**, jarak **0.23 m** dari muka dalam dinding
  (-304.875); peci ujung -304.706, jarak 0.17 m; kepala di atas bantal
  (y 0.72, bantal atas 0.61) di SEMUA kasur.
- **Dinilai: BAGUS, kepala tembus SELESAI** (angka + 2 foto luar).

## 5. Menulis — dari "kitab hilang" jadi kitab terlihat

**Yang aneh (foto ronde 6/07):** kitab di pangkuan (0, 0.30, 0.30)
masuk BAWAH LANTAI saat visual turun -0.45 (y dunia -0.15) — tidak
terlihat di foto; sampul zamrud gelap menyatu dengan sarung zamrud;
lengan kanan nyaris tidak menekuk; kepala tidak menunduk.

**Yang diubah (`player.gd`):**
- Kitab pangku: skala 1.2 → **1.5**, posisi (0, 0.30, 0.30) →
  **(0, 0.86, 0.38)**, rot.x -0.25 → **-0.35** — di atas pangkuan
  (y dunia terukur 0.348, bukan di bawah lantai).
- Sampul: zamrud gelap → **MARUN #7a1f1f** — kontras dengan sarung
  zamrud + koko putih.
- Pose "menulis": kepala MENUNDUK (rot.x 0.20), lengan kanan ke
  depan-bawah (x -0.85 + goyangan menulis sin ±0.06), siku -0.45,
  lengan kiri menahan kitab (x -0.9); kaki bersila seperti duduk.

**Bukti:** `08-menulis-depan.png` (kitab TERLIHAT di pangkuan: halaman
putih + tepi sampul marun, tangan di atasnya, kepala menunduk),
`09-menulis-samping.png` (profil: kepala menunduk, lengan ke kitab,
kitab kontras dengan sarung). **Dinilai: BAGUS.**

## 6. Perbaikan pendukung (agar pose tidak "menempel")

- **Restore pakaian** (`player.gd` `_physics_process`): di luar pose
  diam, `_lerp_pakaian(delta, PAKAIAN_DEFAULT)` mengembalikan sarung/
  torso ke normal — tanpa ini sarung mengerut/pipih pose terakhir
  menempel saat berdiri/jalan. Teruji: setelah tidur → berdiri, sarung
  + torso kembali (1,1,1).
- **Kancing di `terapkan_outfit`**: "BahuYoke" dihapus dari daftar node
  koko, "Kerah" + "PeciBand" ikut diwarnai ulang saat ganti baju.

## Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: semua script game + `test_ronde9.gd` + `foto_ronde9.gd`
  + `foto_ronde9_retake.gd` lolos (1x parse error di tengah jalan:
  inferensi tipe `vis`/`rel` — diperbaiki dengan anotasi eksplisit).
- **Tes headless `test_ronde9.gd`: 66/66 LOLOS, exit 0** — bentuk
  (peci kubah SphereMesh scale.y 0.62 puncak 1.933, BahuYoke hilang,
  torso kapsul r 0.21 h 0.66, pivot lengan ±0.235, 3 kancing, sampul
  marun #7a1f1f, rambut scale.y 0.68); pose (duduk y -0.42 + sarung
  0.45 + yaw kaki ±0.45; menulis kitab y 0.348 + kepala 0.20; tidur
  kepala relatif (0, 0.70, -1.66) + sarung z 0.55 + torso z 0.6 +
  label tersembunyi; berdiri restore (1,1,1)); snap tidur 5 kasur
  (offset +0.95, kepala di atas bantal, ujung kepala > -304.80,
  peci tidak tembus, label tersembunyi). 4 gagal di run pertama
  adalah BUG TES (teleport 1.8 m memilih kasur tetangga) — diperbaiki
  (teleport 0.8 m), bukan bug game.
- **Probe pra-perbaikan** (`probe_tidur.gd`, sudah dihapus): kepala
  utara-tengah z=-305.21 / ujung -305.45 = TEMBUS 0.32 m melewati muka
  luar dinding — diagnosis Mas terkonfirmasi angka. Setelah perbaikan:
  ujung -304.646 = aman 0.23 m.
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR.**
- **Pck hasil export dijalankan headless 600 frame (`--main-pack`):
  0 SCRIPT ERROR.**
- **11 foto bukti** di `~/workspace/pesantren-verse/foto-ronde9/`
  (960×540, xvfb-run + opengl3, siang via `LangitDinamis.debug_jam=10.0`
  — hanya di skrip foto, game tidak diubah): 01–05, 08–10 sekali jalan;
  06/07/11 retake sekali (framing pertama gagal: FOV 40 terlalu sempit
  + pitch +0.25 terlalu menunduk + kamera luar 6.5 m terlalu jauh).
  Semua ditinjau satu per satu (lihat § "Dinilai" di atas).
- **Export `export/web/`:** pck BARU **983.408 byte** sha256
  `62c9552a550ddbd519bcee03a7790e1747325a67cff119d1faca9762578f68bb`
  (tumbuh 2.144 byte dari ronde 8); wasm TIDAK berubah sha256
  `fc74679e…fa57d0`; index.js tidak berubah; worklet ada (2.973 byte);
  `experimentalVK:true` tetap di index.html. File tes/foto dihapus
  sebelum export (pck bersih). **TIDAK deploy** — deploy urusan Damar.
  Catatan: percobaan export pertama gagal ("Could not write file")
  karena argumen path `export/web/` — preset "Web" sudah punya
  `export_path` sendiri; export benar tanpa argumen path.

## Belum sempurna / jujur

- Lengan saat diam tetap tabung lurus sederhana (tangan bola kecil) —
  tidak lagi "balok"/"football", tapi bukan lengan berotot/siku
  terlihat. Tekukan siku hanya terbaca saat duduk/menulis.
- Kepala besar (~25% tinggi, gaya chibi Roblox) — itu arah gaya yang
  sudah disetujui sebelumnya; kalau Mas masih merasa "aneh", yang
  perlu diputuskan adalah gaya (chibi vs proporsi natural), bukan
  tweak primitif lagi.
- Tidur dari arah kaki (07) secara alami jadi gundukan (foreshortening)
  — bukan cacat pose; bukti utama tidur adalah 06 + angka + 11.
- **Interior cangkruk siang hari tetap GELAP** (terlihat di 06/07/11:
  dinding coklat gelap, hanya 1 lampu gantung) — tidak ada jendela,
  matahari terhalang atap. Ini desain interior lama, bukan ronde 9;
  kalau Mas mau kamar lebih terang, perlu jendela/lampu tambah
  (ronde berikut).
- Peci dari depan kadang terbaca seperti "topi datar" karena kubahnya
  dangkal (skala y 0.62) — jauh lebih baik dari ember, tapi bukan
  songkok tinggi tradisional (sengaja: songkok memang pendek).
- **Belum teruji:** tampilan di HP beneran + browser tetap perlu
  dinilai Mas — foto render software bukan HP. Retest browser ronde 9
  + verdict Mas dari HP adalah penentu akhir.
