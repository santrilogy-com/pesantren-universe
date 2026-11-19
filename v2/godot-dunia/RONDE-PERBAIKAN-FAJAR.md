# RONDE PERBAIKAN — Fajar (item 3, 4, 6, 7) — 17 Nov 2026

Koordinator: Raka. Game v1 (`godot-dunia/`), TIDAK deploy — hasil dulu untuk ACC Mas.
File milik Fajar: `pesantren_builder.gd`, `kampus_putri.gd`, `interior_musholla.gd`,
`interior_surau.gd` (bila perlu), `tembok_putri.gd`, + `jalan_ronde22.gd`
(file builder dunia yang relevan untuk item 6 — Sinta pembuat awal, diubah
hanya bagian jalan N-S ke Surau; dicatat di sini supaya Raka tahu).
`main.gd` (Raka) TIDAK disentuh — item 7(f) butuh main.gd, jadi hanya
diagnosis + spesifikasi patch untuk Raka (lihat bawah).

## Diagnosis (tes headless `test_perbaikan.gd`, Godot 4.7.2 — baseline)

Baseline: **49 LULUS / 10 GAGAL** (sebelum perbaikan).
Skrip tes + foto diarsipkan di `~/workspace/pesantren-verse/ronde-perbaikan/skrip/`
(salinan sementara di root proyek dihapus setelah selesai).

### Item 3 — Papan nama terbalik dari satu sisi
- Akar masalah: **semua Label3D papan nama `double_sided=true`** (default
  Godot) — teks terlihat dari belakang sebagai cermin. Arah hadap depan
  semua label SUDAH benar (terverifikasi: GERBANG barat -X / timur +X,
  MADRASAH -X, CANGKRUK PUTRI +Z, KELUAR Surau/Musholla/Cangkruk ke dalam
  ruangan). Jadi yang rusak hanya sisi belakangnya, bukan hadap depannya.
- Bukti: `label-hadap-*` semua PASS; `label-depan-saja-*` FAIL (4 label
  dicek: GerbangBarat, Madrasah, CangkrukPutri, Cangkruk).
- Foto baseline: A1/A2 (Gerbang barat/timur), A3/A4 (Madrasah depan/belakang),
  A5/A6 (Cangkruk Putri depan/belakang), A10/A11 (KELUAR Surau dalam/luar),
  M6/M7 (KELUAR Musholla dalam/luar), A12/A13 (Gerbang Putri barat/timur).

### Item 4 — Celah di bubungan atap Cangkruk
- Akar masalah: **BUKAN ridge-nya** — dua bidang atap BERTEMU di bubungan
  (tumpang tindih 0,18 m: ujung kiri x=-21,91 / kanan x=-22,09 pada cx=-22;
  putri 128,09/127,91 pada cx=128 — PASS). Yang bolong: **segitiga pelana
  (gable) di kedua ujung atap (z=cz±4) TIDAK ADA penutup sama sekali**
  (0 kandidat — FAIL). Dinding hanya 3,4 m, bubungan 4,85 m: lubang
  segitiga ~10 m × 1,25 m di tiap ujung, langit terlihat menembus atap.
- Berlaku sama untuk Cangkruk putra (-22,-18) dan Cangkruk Putri (128,-12)
  (konstruksi identik).
- Foto baseline: A7 (atap Cangkruk), A8 (atap Cangkruk Putri).

### Item 6 — Jalan aspal Surau meleset dari pintu
- Akar masalah: jalan N-S di x=0 (x -1,5..+1,5), sedangkan garis lurus
  spawn (-4,14) -> pintu (-3,38,-6,75) di x≈-4..-3,38. Hanya **5/41 titik**
  garis itu di atas aspal; pintu **5,50 m** dari aspal terdekat (jalan E-W).
  Segmen utara berakhir z=-24 (1,17 m di utara dinding utara Surau pada x=0)
  — tapi di x=-3,38 dinding utara Surau ada di z≈-24,40 (pintu putar -25°),
  jadi segmen utara harus DIPENDEKKAN bila digeser.
- Pintu luar terverifikasi: (-3,38,-6,75), sumbu 115°, keluar 205°.
- Foto baseline: A9 (dari atas: spawn -> pintu).

### Item 7 — Interior Musholla
- **(a)(b)(c)(e) SUDAH BENAR di kode saat ini** (terverifikasi headless):
  16 sajadah (15 grid + Sajadah_Ustadzah), mihrab di dinding barat
  (lokal x=53,15; dunia (55,90,1,3,-303,43)), RakKitab tegak 0,35×2,0×1,6
  + 3 kitab, TIDAK ADA bola placeholder (0 bola non-lampu), lantai +
  plafon ada, Rehal_Ustadzah ada, Ustadzah duduk di dalam
  (68,88,0,-301,79; fase=duduk; di_dalam()=true).
- Maka deskripsi retest ("lantai biru muda polos tanpa sajadah, tidak ada
  mihrab, rak hanya 2 platform + bola") **TIDAK cocok dengan kode saat ini**.
  Penjelasan paling masuk akal: retest melihat **SHELL luar Musholla
  (134,-24) yang bisa dimasuki jalan kaki** — lantainya PUTIH polos
  (render pucat kebiruan di bayangan), kosong tanpa sajadah/mihrab/rak
  (perabotnya memang di map interior terpisah, bukan di shell) — dan/atau
  pck live yang di-retest lebih tua dari kode ini. Foto M1/M3 membuktikan
  tampilan shell; foto M4 membuktikan isi map interior.
- **(d) Kubah: BENAR-BENAR RUSAK di kode.** Drum r=1,6 (y 4,15..4,45),
  kubah bola r=2,0 (pusat y=4,45, skala y 0,72) — bawah kubah y=**3,01**,
  yaitu ~1 m DI BAWAH plafon/atap (bawah 3,995): dari dalam shell, kubah
  menjuntai seperti bola hijau melayang; dari luar, kubah (r~1,98 di garis
  atap) menjorok 0,38 m melewati drum (r=1,6) — terlihat mengambang dengan
  celah bayangan di bawah perutnya. FAIL `kubah-tidak-menjuntai`.
- **(e) Ustadzah:** patroli benar (mulai duduk di kursi, timer 45–90 dtk,
  lalu keluar patroli, lalu masuk lagi — `npc.gd` `_proses_patroli`).
  "Tidak di dalam" dari sudut pandang pemain terjadi karena interior
  TIDAK PERNAH ditampilkan di live play — lihat (f).
- **(f) Pemain tidak bisa keluar — AKAR MASALAH: TIDAK ADA logika pintu
  Musholla untuk pemain di `main.gd`.** Terverifikasi:
  `has_method(_cek_pintu_musholla)=false`, `_masuk_musholla=false`,
  `_keluar_musholla=false`; tidak ada prompt "MASUK/KELUAR MUSHOLLA"
  (hanya Surau + Cangkruk, `main.gd:897-906`); tidak ada flag
  `_di_dalam_musholla`. Komentar `main.gd:235` malah menulis "Pemain
  putra TIDAK PERNAH masuk — yang memakai: Ustadzah Mariyah". Pemain
  putri yang di-teleport ke interior (mis. retest) TERJEBAK: tidak ada
  koridor keluar, dan `_cek_batas` tidak menolongnya (x=60 > tembok 14
  = zona "legal" untuk putri). **Perbaikan ini file Raka — Fajar TIDAK
  edit `main.gd`. Spesifikasi patch ada di bawah.**

## Bukti foto baseline (dilihat 17 Nov ~12:30–13:00 WIB, 20 foto)

- **M3 (di dalam SHELL Musholla) = bukti kunci item 7:** lantai biru
  muda polos (lantai PUTIH shell render kebiruan di bayangan), kosong
  tanpa sajadah/mihrab, dan di sudut timur ada **2 platform rendah +
  bola warna** — itu **bedeng bunga TamanMusholla** yang jatuh DI DALAM
  ruang sholat (x=138,5 di dalam footprint bangunan 128..140) — persis
  "rak kitab placeholder" yang dilaporkan retest. Kubah hijau gelap
  melayang di langit-langit (M2: bola hijau gelap memenuhi pandangan
  dari dalam). Jadi retest memang masuk SHELL, bukan map interior.
- **M4 (map interior):** sajadah hijau tersusun rapi, mihrab emas
  berlabel محراب di dinding jauh, smartboard + rak kitab cokelat di
  bawahnya, lantai kayu gelap — interior SUDAH lengkap. Di kiri atas
  terlihat label KELUAR terbalik (cermin) — konfirmasi visual item 3.
- **M5:** Ustadzah Mariyah duduk di dalam map interior, di samping
  rak kitab (3 kitab warna-warni) — (e) benar di kode.
- **M7 (KELUAR Musholla dari luar):** label terbaca "ЯAULƎK" (cermin)
  lewat pintu — konfirmasi visual item 3.
- **A7/A8 (atap Cangkruk putra + putri):** segitiga pelana ujung atap
  gelap = bayangan interior menembus lubang (bukan dinding) —
  konfirmasi visual item 4. Bubungan sendiri rapat.
- **A9 (dari atas):** jalan N-S putih di x=0, jauh di timur pintu
  Surau; garis spawn→pintu melewati rumput hijau — konfirmasi item 6.
- **A1/A2/A3:** GERBANG + MADRASAH terbaca benar dari sisi depan.
  A4 (dari timur) hanya dinding kosong — label belakang tidak terlihat
  dari luar (di dalam gedung, di atas pintu) — foto sesudah-perbaikan
  A4/A6 diambil dari DALAM.
- **Catatan proses:** foto a2 baseline sempat GAGAL sekali (12:44) —
  `main.gd` gagal parse ("`_jarak_kamera_aman()` not found") karena
  agen lain (Eka) sedang mengedit `main.gd` saat itu; diulang 12:58
  setelah fungsi itu ada — berhasil. Foto E*/G* di folder yang sama
  milik agen lain, bukan Fajar. Semua 20 foto baseline disimpan di
  `ronde-perbaikan/foto/baseline/`.

## Perbaikan yang dilakukan

### Item 3 — papan nama dua sisi (semua `double_sided=false` + label belakang)
Pola: label depan tetap di tempatnya (hadap + posisi tidak berubah),
`double_sided=false`; label belakang (nama sama + "Belakang", teks sama,
putar 180° dari depan, menempel sisi dalam dinding/pintu, juga
`double_sided=false`) sehingga terbaca benar dari dua sisi.
- `pesantren_builder.gd` `_tembok`: GERBANG barat/timur (14,0) — dua
  label sudah ada per sisi, tinggal `double_sided=false` (2 baris).
  `_cangkruk`: LabelCangkruk + LabelCangkrukBelakang
  (cx,2.9,cz+3.85, rot PI). `_gubuk_pos`: LabelPos + LabelPosBelakang
  (lokal (1,35,2,6,0), rot -PI/2) — berlaku PosJaga_1..4 + PosSatpam.
- `tembok_putri.gd` `_tembok_putri`: GERBANG PUTRI barat/timur (115,0)
  — `double_sided=false` di keduanya.
- `kampus_putri.gd` `_cangkruk_putri`: LabelCangkrukPutri +
  LabelCangkrukPutriBelakang (cx,2.9,cz+3.85, rot PI). `_gedung`:
  semua gedung (Madrasah, KelasPutri, AsramaPutri, KantorUstadzah,
  Studio) — label belakang di `pintu_pos - keluar*0,18`,
  rot `putar_label+PI`. `_pos_jaga_tl`: LabelPos + LabelPosBelakang
  (lokal (-1,35,2,6,0), rot PI/2).
- `interior_surau.gd`: LabelKeluar + LabelKeluarBelakang (0,3.0,-293,7).
- `interior_musholla.gd`: LabelKeluar + LabelKeluarBelakang
  (`ke_dunia((60,2,6,-295,7))`, rot ROTASI_DEG).
- `interior_cangkruk.gd`: LabelKeluar + LabelKeluarBelakang
  (-60,2.7,-294,7).

### Item 4 — segitiga pelana atap Cangkruk
- `pesantren_builder.gd` `_cangkruk` + `kampus_putri.gd`
  `_cangkruk_putri`: 2 prisma segitiga (PrismMesh 10×1,4×0,25,
  left_to_right=0,5, material KAYU) di (cx,4,1,cz±4) —
  "PelanaAtap_Utara"/"PelanaAtap_Selatan". Alas di puncak dinding
  (y=3,4), puncak (cx,4,8) tersembunyi di dalam panel atap + bubungan;
  sisi miring sejajar lereng atap sehingga tidak menembus panel.
  Visual saja, tanpa collision.

### Item 6 — jalan aspal ke pintu Surau
- `jalan_ronde22.gd` `bangun()`: jalan N-S geser dari x=0 ke x=-3,38
  (Selatan + Tengah geser posisi; Utara geser + DIPENDEKKAN jadi
  z -200..-25,5 — ujung lama z=-24 akan menusuk cangkang Surau di
  x=-3,38 karena dinding utara miring -25° mencapai z=-25,10 di tepi
  barat jalan). BARU: taji `JalanNS_Surau` (3,0.06,2.19) di
  (-3,38,0.03,-2,345), z -3,44..-1,25 — dari tepi utara jalan E-W
  sampai tepi selatan serambi, tepat di garis tengah pintu. Header
  file diperbarui dengan geometri baru + alasan pemendekan. Catatan:
  satu tiang serambi (-2,30,-3,15) berdiri di atas taji (alas 6 cm di
  bawah permukaan jalan — tidak terlihat); segitiga kecil tumpang
  tindih (≤0,7 m) di pertemuan taji-serambi sisi timur diterima
  (lip aspal 4 cm di tepi serambi yang miring).

### Item 7 — interior Musholla
- **(d) Kubah** — `kampus_putri.gd` `_musholla`: drum lama r=1,6/h=0,3
  diganti drum r=2,0/h=1,44, pusat y=4,72 (y 4,0..5,44, kaki di dalam
  pelat atap); kubah naik ke pusat y=5,44 (bawah y=4,0 = rata pelat
  atap, tidak menjuntai; ekuator r=2,0 = rata drum, tidak menjorok);
  tangkai y=7,05, sabit y=7,45 (puncak ~7,6 m). Pola yang sama dengan
  kubah Surau.
- **(c) Bedeng bunga** — `kampus_putri.gd` `_musholla` TamanMusholla:
  dipindah dari DALAM ruang sholat (138,5,-27,8) + (138,5,-20,2) ke
  LUAR bangunan: (138,5,-30,0) strip utara timur-laut dan (129,5,-18,0)
  strip selatan barat serambi. Sudut tenggara tidak dipakai — di sana
  jalan konektor ke pintu. Inilah "platform + bola" yang dibaca retest
  sebagai rak kitab placeholder.
- **(a)(b)(e): tidak ada perubahan kode** — sudah benar (sajadah,
  mihrab, rak kitab, Ustadzah di dalam map interior; dibuktikan foto
  M4/M5). Yang membuat retest "tidak melihatnya": pemain tidak pernah
  sampai ke map interior karena tidak ada logika pintu (f).
- **(f): tidak ada perubahan kode oleh Fajar** — butuh `main.gd`
  (Raka). Spesifikasi patch di bawah (tidak berubah).

## Hasil uji headless (setelah perbaikan)

Tes `test_perbaikan.gd` di-update: cek label belakang (10 label) +
`double_sided=false` semua label (24 label), cek drum kubah (r≥1,95),
cek bedeng di luar bangunan, cek jalan memakai aspal ATAU serambi
(ujung garis spawn→pintu di atas lantai serambi batu).
Hasil: **103 LULUS / 1 GAGAL** (sebelumnya 49/10).
- Item 3: semua `label-hadap-*` PASS; 10 `label-*-Belakang` PASS
  (hadap berlawanan dari depan); 24 `label-satu-sisi-*` PASS.
- Item 4: pelana 2 kandidat di tiap Cangkruk (PelanaAtap_Utara +
  PelanaAtap_Selatan, pos (cx,4,1,cz±4)) — PASS.
- Item 6: garis spawn→pintu 34/41 titik di atas aspal, **41/41 di
  atas aspal+serambi**; taji bertemu serambi PASS; jarak pintu ke
  aspal terdekat 3,31 m (lewat serambi) — PASS.
- Item 7: kubah bawah_y=4,00 (plafon/atap bawah 3,995) PASS;
  drum r=2,00 PASS; bedeng (138,5,-30,0) + (129,5,-18,0) di luar
  bangunan PASS; sajadah/mihrab/rak/Ustadzah tetap PASS.
- **SATU-SATUNYA GAGAL: `pintu-musholla-logika-ada` — SESUAI RENCANA**
  (bukan regresi): logika pintu Musholla ada di `main.gd` milik Raka,
  Fajar tidak edit. Spesifikasi patch di bawah.

## Foto bukti

Semua foto di `~/workspace/pesantren-verse/ronde-perbaikan/foto/`
(20 foto sesudah-perbaikan; 20 foto baseline di `foto/baseline/`).
Skrip foto di `ronde-perbaikan/skrip/` (A4/A6 diubah: bidikan dari DALAM
gedung supaya label belakang terlihat).
- Item 3: A1/A2 (GERBANG dua sisi, tetap benar), A3 (MADRASAH depan),
  **A4 (MADRASAH dari dalam — "MADRASAH" terbaca benar di atas pintu)**,
  A5 (CANGKRUK PUTRI depan), **A6 (dari dalam — "CANGKRUK PUTRI"
  terbaca benar)**, **A11 (KELUAR Surau dari luar — "KELUAR" benar,
  dulu "ЯAULƎK")**, **M7 (KELUAR Musholla dari luar — "KELUAR" benar,
  dulu cermin)**, A12/A13 (GERBANG PUTRI dua sisi), A10/M6 (KELUAR
  dari dalam — depan, tidak berubah).
- Item 4: **A7 (Cangkruk putra — segitiga pelana kini cokelat dinding
  yang sama, diterangi matahari; dulu gelap = bayangan interior)**,
  A8 (Cangkruk Putri — sama).
- Item 6: **A9 (dari atas — jalan putih kini di x=-3,38, melewati
  spawn, menempel serambi Surau; dulu di x=0 dengan rumput di
  antaranya)**.
- Item 7: **M1 (kubah dari luar — kini duduk di drum silinder yang
  terlihat, tidak lagi jongkok mengambang di atap)**, **M2 (dari
  dalam melihat ke atas — tidak ada lagi bola hijau gelap; langit-
  langit datar hangat)**, **M3 (di dalam shell — bedeng bunga + bola
  warna SUDAH HILANG dari ruang sholat; lantai biru muda polos
  tetap — itu shell kosong, perabot di map interior)**, M4/M5
  (interior: sajadah, mihrab, rak kitab, Ustadzah — tidak berubah,
  sudah benar).

## Untuk Raka — spesifikasi patch `main.gd` item 7(f) (Fajar TIDAK edit)

Cermin `_cek_pintu_surau` (`main.gd:932`), dengan frame pintu Musholla
dari `InteriorMusholla` (sudah ada, tinggal dipakai):

- Konstanta yang sudah tersedia: `_musholla_door` = (60,0,-296) (pintu
  DALAM, = `ke_dunia(PINTU)`), `_musholla_spawn` = (60,0,-297,5),
  `_musholla_exit` = (134,0,-17,5) (dari dict build), dan
  `InteriorMusholla.SUMBU` = (0,906,0,0,423),
  `InteriorMusholla.KE_DALAM` = (0,423,0,-0,906),
  `InteriorMusholla.KELUAR` = (-0,423,0,0,906).
- Baru: flag `_di_dalam_musholla: bool = false`.
- Baru: `func _cek_pintu_musholla()` — di luar: `d = p - _musholla_exit`,
  `u = d·SUMBU`, `v = d·KE_DALAM`... (perhatian: pintu LUAR (134,-17,5)
  TIDAK diputar — shell Musholla tidak diputar (rotasi 0°) — jadi koridor
  luar cukup sumbu dunia: |x-134|<1,0 dan z di (-19,-17,5) (celah pintu
  2,0 m di dinding selatan shell, z=-19); di dalam: `d2 = p -
  _musholla_door`, `u2 = d2·SUMBU`, `v2 = d2·KELUAR`, picu
  `|u2|<1,2 dan 0<v2<1,5` (pola Surau, pakai SUMBU/KELUAR interior).
- Baru: `_masuk_musholla()` (set flag, `_set_interior_terlihat(false,
  false, true)`, teleport ke `_musholla_spawn`, toast) dan
  `_keluar_musholla()` (clear flag, `_set_interior_terlihat(false,
  false)`, teleport ke `_musholla_exit`, toast).
- Panggil `_cek_pintu_musholla()` di `_process` (di samping
  `_cek_pintu_surau()` / `_cek_pintu_cangkruk()`).
- `_cek_batas`: tambahkan `_di_dalam_musholla` ke pengecualian
  (`if ... _di_dalam or _di_dalam_cangkruk or _di_dalam_musholla:
  return`) supaya pemain di dalam interior tidak didorong balik.
- Prompt interaksi (opsional, pola Surau): "MASUK MUSHOLLA" saat dekat
  pintu luar, "KELUAR MUSHOLLA" saat di dalam (lihat `_perbarui_interaksi`
  sekitar `main.gd:897-906`).
- Catatan: `_on_ikut_sholat` saat ini selalu mengantar pemain ke SURAU
  (putra). Untuk pemain putri, seharusnya ke Musholla
  (`_posisi_imam_musholla()` + `_set_interior_terlihat(false, false,
  true)` + flag) — di luar item ini, tapi satu paket dengan pintu
  Musholla; Raka yang putuskan.
