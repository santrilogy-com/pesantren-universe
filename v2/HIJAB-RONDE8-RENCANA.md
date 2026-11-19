# HIJAB PUTRI RONDE 8 — RENCANA + HASIL

Koreksi Mas atas 3D ronde 7 (18 Nov 11:54 WIB): "Kurang.. apa ga bisa
jilbabnya itu menyatu dari atas sampai dada.. jangan dipisah gitu"

## Diagnosis — ronde 7 menutupi pipi, tapi dengan potongan terpisah

Ronde 7 memenuhi spesifikasi "pipi tertutup" — TAPI dengan 2 bola
pipih (HijabPipi) yang terbaca sebagai DUA GUMPALAN BULAT terpisah
di sisi wajah. Ditambah kubah, dagu, dan drape 3 tier, jilbab
terbaca sebagai potongan-potongan yang disambung, bukan satu kain.
Mas mau SATU KAIN UTUH dari atas sampai dada, seperti gambar konsep
(konsep-jilbab-v1.png): satu aliran kain, tanpa kesan dipisah.

## Desain (satu aliran — yang diganti hanya panel pipi)

1. **HijabPipi DIHAPUS, diganti HijabPanelSamping (1 kapsul vertikal
   per sisi)** — mengalir dari kubah (ujung atas masuk ke dalam
   kubah, y 1,75), turun menutupi pipi, lanjut ke dagu, lalu
   menembus ke dalam drape dada (ujung bawah y 1,21). Kapsul
   (bukan bola): penampang memanjang vertikal, jadi terbaca kain
   yang jatuh, bukan gumpalan bulat.
2. **Geometri (grid Python, kandidat R8-H)** — kapsul r=0,12,
   tinggi total 0,54 (silinder 0,30 + 2 tutup), pusat (±0,17,
   1,48, 0,085), skala x 0,65 (pipih ke samping), rotasi z ±0,10
   (ujung atas merapat ke dalam, bawah melebar ke bahu seperti
   gambar). Depan maks z 0,205. Grid: 0 titik kulit di zona pipi
   (ronde 7: 2 titik di (±0,14, 1,66)), 0 kain di tengah wajah,
   0 kulit di pelipis dari samping, siluet panel di dalam siluet
   kubah.
3. **Strip sisi DIPERTAHANKAN** — strip r 0,04 di z -0,05 menutupi
   sisi pelipis (z -0,09..-0,01) yang tidak dijangkau panel
   (belakang panel z -0,035). Setengah terkubur di dalam panel;
   dari samping terbaca sebagai lipatan tepi kain, bukan potongan
   terpisah.
4. **Drape dada 3 tier DIPERTAHANKAN (bukan satu frustum)** — satu
   frustum = panel kotak seperti ronde 4 yang ditolak Mas
   ("Jelek"); tier + lidah U memberi lekuk bawah melengkung +
   garis lipat seperti gambar. Sambungannya sudah menembus dalam
   (ronde 6), bukan garis pisah.

## Dipertahankan (jangan dirusak)

- Pipi TERTUTUP kain (bukaan wajah oval sempit, hanya tengah wajah
  terlihat: mata, hidung, mulut), dagu tertutup, dada tertutup
  sampai dada tengah tepi U, tanpa celah hijau di leher, belakang
  satu kerudung menyatu, kacamata tetap terlihat (lensa z 0,238
  di depan panel maks 0,205; gagang masuk di bawah kain).
- Recolor: HijabPanelKiri + HijabPanelKanan masuk daftar
  warna-sama di `_warnai_ulang` (ganti HijabPipi).

## Verifikasi numerik (grid Python, SEBELUM menyentuh kode)

Skrip: `godot-dunia/skrip/grid_hijab_ronde8.py` — permukaan terdepan
di tiap titik grid depan (x -0,24..0,24, y 1,45..1,78) + grid samping
(z -0,12..-0,02, y 1,50..1,70, sampling numerik).

- Ronde 7 (baseline): 2 titik kulit di zona pipi (±0,14, 1,66).
- R8-H (dipilih): pipi 0, tengah wajah 0, mulut 0, pelipis samping
  0, siluet +0,000. Standoff maks kain-vs-kulit 0,144 di (±0,21,
  1,55) — seorde ronde 7 (0,137); pipi melengkung ke belakang,
  kain pasti berdiri di depan kulit di tepi luar.
- Kandidat lain yang diuji (semua pipi 0 / tengah 0 / pelipis 0):
  R8-D (r 0,11, standoff 0,147), R8-E (r 0,12, 0,150), R8-G
  (r 0,13, 0,157). R8-H dipilih: standoff terkecil, silinder
  terpanjang (kain vertikal), bawah paling dalam (y 1,21).
- Dua metrik awal yang SALAH dan diperbaiki: (1) "tonjolan panel
  vs kubah" — kubah melengkung ke belakang di sisi kepala, bukan
  patokan; yang benar standoff vs kulit + siluet luar vs kubah.
  (2) zona samping awal mencakup tepi wajah depan (z 0..0,05)
  yang MEMANG harus terlihat dari samping (profil wajah di gambar
  konsep); zona benar z -0,12..-0,02.

## Verifikasi

- Audit karakter: **186/0** (ronde 7: 178/0 − 8 cek pipi lama +
  16 cek panel baru × 2 karakter — putri + ustadzah: panel ada;
  bukan kotak; pad gumpalan dihapus; menutupi pipi; tidak
  menutupi tengah wajah; satu aliran ke kubah; satu aliran ke
  drape dada; bukan gumpalan).
- test_v2: **60/0**.
- Foto 22/22 (foto_hijab.gd, -- sesudah). Foto ronde 7 diarsipkan
  ke `foto-hijab/ronde7-sesudah/` (22 file).
- Backup keadaan ronde 7 SEBELUM edit: `v2/backup-ronde7/`
  (player.gd.ronde7 + audit_karakter_primitif.gd.ronde7, sha
  cocok) — dibuat karena deploy bundle 11:57 WIB jalan TANPA
  hijab (Rangga export dari SALINAN dengan hijab dikembalikan
  ke ronde 2+3; ronde 8 tidak boleh hilang).
- Hanya player.gd + skrip audit + foto + dokumen ini (+ grid
  Python + backup) yang disentuh. main.gd, kampus_putri.gd,
  interior, kamera.gd TIDAK disentuh. TIDAK deploy — export +
  deploy urusan Xam.

## Catatan jujur (penilaian Mas)

1. **Pipi TERTUTUP, kain SATU ALIRAN** — panel vertikal dari kubah
   ke dada; grid membuktikan 0 kulit di zona pipi; foto depan +
   close-up (putri + ustadzah) mengonfirmasi. Gumpalan bulat
   ronde 7 HILANG.
2. **Panel terbaca seperti dua kolom kain yang lurus** — tepi dalam
   panel hampir garis lurus vertikal, jadi bukaan wajah lebih
   seperti celah oval sempit daripada oval lembut melengkung
   seperti di gambar konsep. Permukaan panel juga polos tanpa
   lipatan (lipatan hanya ada di drape dada). Ini batas primitif:
   kapsul tidak bisa melengkung mengikuti oval wajah. Tapi arahnya
   sudah benar — satu kain, bukan potongan — dan kacamata/mata/
   hidung/mulut tetap terlihat penuh.
3. Dari SAMPING, profil wajah (kacamata + hidung) tetap terbaca;
   panel turun satu garis lurus ke dagu lalu drape dada — tidak
   ada tonjolan aneh. Kapsul lipatan di drape dada terlihat
   sedikit menonjol dari samping (tab kecil di tepi depan dada).
4. Belakang tetap satu kerudung menyatu, 0 kulit (ujung bawah
   belakang masih agak kotak — catatan ronde 2, di luar brief).
