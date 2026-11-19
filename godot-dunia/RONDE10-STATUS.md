# RONDE 10 — Jendela cangkruk + kopyah/rambut + 3 koreksi Mas (16 Nov ~05:52–06:30 WIB, Raka)

**Pemicu:** Mas 05:52 WIB *"Tambah jendela"* (interior cangkruk siang
hari tetap gelap) + Mas 05:54 WIB (kopyah/rambut) *"Kopyah dan rambut
keliatan aneh.. harusnya rambut itu dibawah kopyah.. ini bagian
belakang malah ga ada kopyah cuma rambut aja."* + tiga koreksi Mas
05:57 WIB: (1) *"Salaman harusnya pakai tangan kanan bukan kiri."*
(2) *"Tulisan di smartboard dihapus."* (3) *"Arah kiblat tidak sesuai
dg arah matahari."*

**Aturan:** tidak ada perubahan logika misi/poin/save — hanya
`scripts/interior_cangkruk.gd` (jendela + cahaya), `scripts/player.gd`
(pivot lengan + kopyah/rambut), `scripts/interior_surau.gd` (mihrab +
sajadah + smartboard bersih), `scripts/main.gd` (1 fungsi jadi no-op),
`scripts/langit_dinamis.gd` TIDAK diubah (matahari terbenam sudah
benar — lihat §4). **TIDAK deploy** — deploy urusan Damar.

## 1. Jendela cangkruk — dari gelap jadi terang karena cahaya jendela

**Yang diubah (`interior_cangkruk.gd` `_jendela`, sudah dikerjakan
sebelum koreksi 05:57):** 3 jendela kayu gaya pos ronda (bingkai
KAYU_GELAP + kaca biru terang emissive + jeruji silang + ambang):
**JendelaBarat** (-66.875, 1.7, -301.8) dan **JendelaTimur** (-53.125,
1.7, -301.8) di celah antara 2 kasur tiap sisi, **JendelaSelatan**
(-63.9, 1.7, -294.875) di samping pintu. Dinding TIDAK dilubangi
(collision utuh); kaca menempel di muka dalam dinding. Tiap jendela
punya OmniLight hangat (#ffeecf) 0.7 m di dalam ruangan, grup
"CahayaJendela" — `langit_dinamis.gd` meredupkannya di malam hari
(x0.05), kebalikan dari lampu (x2.0 di malam hari).

**Koreksi pengukuran (Raka):** energi awal 0.55 + range 6.0 TERLALU
REDUP — foto interior siang mean luminance **47.1** (sama gelapnya
dengan ronde 9: 50.9) — jendela jadi hiasan, bukan sumber cahaya.
Dinaikkan ke **energi 1.6 + range 9.0** (lebih kuat dari lampu
gantung 0.7/range 10). Hasil: mean luminance **60.9 (+29%)**,
dinding + kasur + karpet terbaca jelas, kaca jendela bercahaya.
Plafon + lantai tetap KAYU_GELAP (gaya pos ronda kayu) — lihat
§ "Belum sempurna".

**Bukti:** `foto-ronde10/01-cangkruk-luar.png` (cangkang kayu + atap
segitiga, jendela hijau di dinding selatan + timur, label KAMAR
CANGKRUK) dan `02-cangkruk-dalam.png` (jendela barat + 3 kasur +
karpet, ruangan terang hangat).

## 2. Kopyah/rambut — kopyah menutupi ubun-ubun 360°

**Yang aneh (foto ronde 9/03):** dari belakang seluruh kepala HITAM
(bola rambut menutupi semuanya); dari samping kepala dua warna
(hitam belakang, putih depan-atas).

**Yang diubah (`player.gd`, sudah dikerjakan sebelum koreksi 05:57):**
peci diperbesar r=0.265 (skala y 0.62, pusat y=1.77, puncak 1.934)
— lebih besar dari kepala (0.24) sehingga menutupi ubun-ubun dari
semua arah; rambut dikecilkan r=0.21 skala (1.2, 0.55, 1.0) pusat
(0, 1.69, -0.05) — punggung rambut (-0.26) hanya 0.022 di luar
kepala, puncak rambut 1.805 di bawah puncak peci, depan rambut
(+0.16) di dalam kepala.

**Bukti:** `03-peci-depan.png` (kubah putih rendah, wajah jelas),
`04-peci-samping.png` (putih di atas, hitam di belakang bawah),
`05-peci-belakang.png` (**atas kepala PUTIH**, rambut hitam hanya di
bawah tepi kopyah).

## 3. Salaman tangan KANAN — akar: pivot lengan tertukar anatomi

**Diagnosis (terukur, bukan tebakan):** wajah karakter di +Z (mata
z=+0.222). Saat menghadap +Z (selatan), tangan KANAN anatomis ada di
**-X (barat)**. Dulu `arm_r` di +X = tangan KIRI anatomis — jadi
salaman (rotation.x -1.45 di `_arm_r`) mengulurkan tangan kiri.
Nama node "TanganKanan" pun menempel di pivot yang salah.

**Yang diubah (`player.gd`):** posisi pivot DITUKAR — `arm_r` kini
di (-0.235, 1.30, 0), `arm_l` di (+0.235, 1.30, 0) — dan SEMUA
`rotation.z` lengan dibalik tandanya (konstruksi, reset berdiri,
duduk, menulis, salaman, melambai, tidur) supaya "ke dalam / ke
luar" tetap sama. `rotation.x` tidak berubah (ayunan simetris).
Efek samping yang BENAR: menulis kini pakai tangan kanan, melambai
tangan kanan, kitab dibawa tangan kanan (anak `arm_r`).

**Bukti:** `06-salaman-depan.png` (retake — foto pertama GAGAL:
pemain tidak kelihatan karena SantriPlayer tanpa CollisionShape3D
jatuh ke bawah tanah di skrip foto minimal; diperbaiki dengan reset
posisi tiap frame, lihat § "Jujur"). Karakter menghadap kamera,
tangan kanan terulur ke depan — di foto ada di sisi KIRI gambar
(karena karakter menghadap kamera, kanan karakter = kiri foto).
Tes: `arm_r` di x=-0.235 + pose rot.x -1.45, `arm_l` diam.

## 4. Tulisan smartboard DIHAPUS — papan bersih

**Yang diubah:** `interior_surau.gd` `_smartboard()` — Label3D
"SmartboardScreen" dipertahankan (interface `build()` tetap
mengembalikannya) tapi teksnya KOSONG; `main.gd` `_on_slide_changed`
jadi no-op (tidak lagi menulis judul/ringkas ke papan 3D).
**Konten pelajaran TIDAK dihapus** — slide Isim/Fi'il/Huruf tetap
tampil di popup UI saat smartboard dibuka (`ui.gd`).

**Bukti:** `07-smartboard.png` — papan putih bersih, bingkai kayu +
4 bola emas di sudut, tanpa tulisan sama sekali.

## 5. Kiblat 295° — mihrab + sajadah diputar searah matahari terbenam

**Fakta:** dari Indonesia kiblat ≈ **295° (barat-barat laut)**.
Matahari terbenam di game: **290°** (`K_MATAHARI` jam 18.0, elev
-6°) — selisih 5°, keduanya searah barat saat maghrib. Mihrab lama
menghadap utara (0°) — salah 65°.

**Yang diubah (`interior_surau.gd`, konstanta baru `KIBLAT_AZIMUT
:= 295.0`):** mihrab dipindah dari dinding utara ke **dinding
barat (-8.4, 0, -306.0)** — sinar 295° dari tengah ruangan
menabrak dinding barat di situ — diputar `rotation.y = -295°`
supaya muka relung menghadap jamaah (115°, tenggara). Sajadah
3×5 dipindah ke tengah ruangan (0, 0, -301.8), diputar sama
(`rotation.y = -295°`) — baris depan (lokal z=-2.0) menghadap
kiblat. Semua 15 sajadah tetap di dalam ruangan (margin ≥0.2 m
dari dinding utara); meja sampar, rak kitab, smartboard, lampu,
pintu, dan spawn tidak terganggu (jarak terdekat 1.1 m ke marker
M2). Pintu tetap selatan — TIDAK ada perubahan bangunan luar,
jalan, atau peta (koordinasi dengan Gilang tidak diperlukan).

**Matahari TIDAK diubah:** azimut terbenam 290° sudah benar dan
searah kiblat. Catatan jujur: azimut jam 15.00 = 325° (barat laut)
adalah pilihan DELIBERATE ronde 4 supaya matahari masuk tampilan
default (menghadap utara) — secara astronomi jam 15.00 seharusnya
~250° (barat-barat daya), tapi mengubahnya akan menghilangkan
matahari senja dari tampilan default yang sudah di-ACC Mas.
Keputusan ini milik Mas kalau mau diubah.

**Bukti:** `08-mihrab-sajadah.png` (retake — sudut lebih dekat:
sajadah diagonal menghadap barat-barat laut, mihrab panel hijau
tua + lis emas di dinding barat) dan `09-matahari-sore.png`
(jam 17:10, matahari rendah di barat, langit oranye, bayangan
panjang ke timur — matahari dan kiblat searah barat).

## Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: `player.gd`, `interior_surau.gd`, `interior_cangkruk.gd`,
  `main.gd`, `test_ronde10.gd`, `foto_ronde10.gd`,
  `foto_ronde10_retake.gd` — semua lolos.
- **Tes headless `test_ronde10.gd`: 99/99 LOLOS, exit 0** (76 lama:
  jendela siang/malam + kopyah/rambut; 23 baru: salaman 7 — pivot
  kanan -0.235/kiri +0.235, TanganKanan anak arm_r, kitab di tangan
  kanan, pose rot.x -1.45; smartboard 4 — teks kosong, papan + 6
  mesh utuh; kiblat 12 — mihrab/sajadah rot.y -295°, mihrab di
  (-8.4, -306.0), muka mihrab 115°, 15 sajadah di dalam ruangan,
  mihrab di arah ~295° dari sajadah, matahari terbenam 290°,
  selisih ≤10°). 1 gagal di run pertama adalah BUG TES (hitung
  mesh smartboard 7 padahal 6: bingkai+layar+4 bola) — diperbaiki,
  bukan bug game.
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR**
  (dijalankan 2x: setelah koreksi + setelah kenaikan cahaya).
- **9 foto bukti** di `~/workspace/pesantren-verse/foto-ronde10/`
  (960×540, xvfb-run + opengl3, siang via `LangitDinamis.debug_jam`
  — hanya di skrip foto, game tidak diubah): 01–05, 07, 09 sekali
  jalan; 06/08 retake sekali (06: pemain jatuh; 08: sudut kurang
  dekat). Semua ditinjau satu per satu.
- **Luminance interior cangkruk siang:** 47.1 (energi 0.55) → **60.9
  (energi 1.6)** vs ronde 9: 50.9. Diukur mean piksel grayscale
  dengan PIL pada framing yang sama.
- **Export `export/web/`:** pck BARU **985.328 byte** sha256
  `a892b3cf924ffd9a256d620b84c2664fb522b43722842945db8f635595be494b`
  (tumbuh 1.920 byte dari ronde 9); wasm TIDAK berubah sha256
  `fc74679e…`; index.js tidak berubah sha256 `33c94cb3…`; worklet
  ada (2.973 byte). File tes/foto dihapus sebelum export (pck
  bersih). **TIDAK deploy** — deploy urusan Damar.

## Belum sempurna / jujur

- Interior cangkruk kini terang (+29% luminance) tapi plafon +
  lantai tetap KAYU_GELAP — ruangan terbaca "hangat diterangi
  jendela", bukan "putih terang". Kalau Mas masih merasa gelap,
  langkah berikut adalah menerangkan material plafon/lantai (keputusan
  desain) atau menaikkan energi cahaya lagi — bukan tambah jendela.
- Peci dari belakang: atas kepala PUTIH sesuai permintaan, tapi
  pita rambut hitam di bawahnya masih cukup terlihat (bukan garis
  sehelai) — rambut menutupi belakang kepala seperti rambut asli di
  bawah peci. Kalau Mas mau lebih tipis lagi, rambut harus dikecilkan
  sekali lagi.
- Salaman: lengan terulur ke depan 83° (rotation.x -1.45) — dari
  depan terbaca sebagai jabat tangan; tangan tidak membuka (bola
  pipih, bukan jari) — itu keterbatasan primitif.
- `SantriPlayer` TIDAK punya CollisionShape3D — di game nyata tidak
  masalah (main.gd menaruhnya di spawn + lantai menahan), tapi
  skrip foto/tes yang menginstansiasi pemain langsung HARUS
  menahan posisinya tiap frame (pelajaran untuk foto ronde berikut).
- Baris `ERROR: Condition "status < 0"... ERR_CANT_OPEN` di awal
  render foto adalah peringatan startup (kemungkinan audio driver
  headless), bukan script error — 9 foto ter-render semua.
- Retest browser ronde 9 masih jalan saat ronde 10 dibuat — temuannya
  (khususnya sarung biru) perlu dicocokkan dengan build ronde 10;
  retest browser ronde 10 (salaman kanan, smartboard bersih, kiblat)
  menunggu deploy Damar + penilaian Mas di HP (juri akhir).
