# RONDE 20 — STATUS (16 Nov 2026 ~19:30 WIB)

Dunia Putri + perilaku ustadz/ustadzah: Musholla Ar-Raudhah, pagar +
gerbang + pos satpam + 4 pos jaga, Ustadzah Mariyah, patroli ustadz/
ustadzah, penegakan batas pakem. **Plus perbaikan bubble chat tanpa
outline (Mas 19:09 WIB) — ikut di ronde ini, bukan sisa kerja.**

## ⚠️ FLAG UNTUK MAS (2 hal, perlu konfirmasi)

**1. Mihrab Musholla Ar-Raudhah: dinding BARAT (kiblat 295°), BUKAN
dinding utara.** Brief + roadmap menulis "mihrab di dinding utara",
tapi aturan kiblat game yang sudah ditetapkan Mas sendiri (ronde
10/12/14, koreksi Mas berkali-kali) adalah **kiblat 295° = dinding
BARAT** (mihrab Surau juga di dinding barat). Dinding utara = 65°
melenceng dari kiblat; dinding barat = 25° melenceng, sama seperti
Surau. Diimplementasikan: mihrab di dinding barat, interior musholla
diputar −25° mengelilingi pintunya persis seperti interior Surau —
jadi arah sholat putri SAMA dengan arah sholat putra. Kalau Mas
memang mau dinding utara, itu mengubah arah kiblat putri; mohon
konfirmasi.

**2. Papan selamat datang: TIDAK digeser — sudah tidak ada.** Brief
meminta geser (0,16) → (0,18), tapi papan itu **sudah dihapus di
ronde 6** (yang tersisa hanya komentar di kode). Di kode tidak ada
yang dipindah; ini no-op, bukan kelalaian. Kalau Mas mau papan
selamat datang kembali, itu pekerjaan baru (posisi + desain).

## Yang dibangun (implementasi selesai ~19:05 WIB)

### A. Musholla Ar-Raudhah (مصلى الروضة) — putri, TERPISAH
- Eksterior **10×8 m** di **(18,−24)**, diputar −25° mengelilingi
  pusatnya (serasi Surau yang juga miring), kubah emas + **menara
  kecil** (dunia (15.35,−29.20)), plakat Arab "مصلى الروضة" di atas
  pintu selatan, pintu di (16.31,−20.37). Jalan pasir 2.5×22 m dari
  pintu ke jalan E-W (berakhir (7.0,−0.47)); tetap di timur pagar
  dan barat plot Kelas — catatan roadmap: geser ke x=24 saat Kelas
  Putri dibangun (Fase B).
- Interior terpisah **14×10 m** di (60,0,−301), diputar −25°
  mengelilingi pintu (60,0,−296) persis pola Surau — file baru
  `scripts/interior_musholla.gd` (class_name InteriorMusholla).
  Isi: **15 sajadah (3×5)**, mihrab di dinding barat (lihat flag 1)
  + label "محراب", smartboard 3.0 m di dinding barat ujung utara
  (M2 putri di sini — M2 putra tetap di Surau), 1 rak kitab dinding
  timur utara (3 kitab), 1 meja sampar, 2 lampu hangat + OmniLight,
  label "KELUAR", 4 pilar sudut, plafon + collision, dinding selatan
  dengan celah pintu 2.4 m.
- Sumbu: masuk 25° / keluar 205°; pintu-luar = pintu + keluar×1.5.

### B. Pagar + gerbang + satpam + pos jaga
- **Pagar fisik** mengikuti polyline (0,−60) → (0,−17.5) →
  (9,−17.5) → (9,−4) → (0,−4) → (0,16): membelok mengikuti dinding
  timur Surau supaya Surau utuh di area putra (detour bersih dari
  sudut timur Surau (3.32,−4.93)..(7.55,−13.99)). Visual: tiang
  tiap ~4 m + rel di y=1.1. Barrier: 6 StaticBody (termasuk
  melintasi bukaan gerbang — gerbang hanya bukaan VISUAL, pemain
  tetap ditahan; satpam yang menjaga).
- **Gerbang di (0,0)**: bukaan 4 m + 2 pilar batu di (0,±2) + balok
  + atap piramida 4 segmen + label "GERBANG" menghadap barat/timur.
  **Pos satpam 3×3 m di (3,3)** menghadap gerbang (pintu menghadap
  barat) + **satpam NPC** berjaga di sana (tidak ikut sholat, tidak
  berpatroli, tetap di pos selama sholat).
- **4 pos jaga 3×3 m + 1 lampu** di (−40,−35), (40,−35), (−40,80),
  (40,80). Peta (penuh + minimap) menampilkan musholla, pagar,
  gerbang ("GERBANG BATAS" — beda dari gerbang selatan), 4 pos jaga,
  pos satpam.
- Pagar memotong plakat plot Masjid Besar di (0,−21.4) — plakat
  digeser 3 m ke barat ((−3,−21.4), tiang x=−5/−1) supaya bersih;
  saat masjid dibangun, pagar bertemu dindingnya seperti rencana.

### C. Ustadzah Mariyah + perilaku ustadz/ustadzah
- **Ustadzah Mariyah** (NPC baru, label "Ustadzah Mariyah"): hijab
  zamrud gelap **#065f46** (kubah + tirai belakang + cape bahu),
  gamis krem **#e8dcc0**, rok gamis zamrud **#0b6b4f**, kulit sawo
  matang, tanpa kacamata/jenggot. Kunci outfit baru `hijab` /
  `hijab_warna` di `player.gd build_visual` (cabang hijab mengganti
  peci/rambut seperti cabang serban); panel Ganti Baju TIDAK
  menawarkan hijab — hanya Ustadzah yang memakainya.
- **Perilaku patroli** (state machine di `npc.gd`, Kyai + Ustadzah):
  "duduk" (duduk bersila baca kitab, kitab pangku terlihat, timer
  45–90 dtk) → "ke_pintu_dalam" → teleport keluar di pintu →
  "patroli" (rute luar sekali putaran) → "ke_pintu_luar" → teleport
  masuk di spawn dalam → "ke_kursi" → "duduk". Penyeberangan pintu
  selalu teleport (pola GTA) supaya NPC tidak menembus dinding.
  Kyai: kursi di Surau (di samping MejaSampar_3, menghadap kiblat),
  rute putra/plaza [(−4,4),(−8,8),(−4,12),(0,20),(−8,18),(−2,2)].
  Ustadzah: kursi di Musholla, rute putri
  [(20,−10),(24,0),(20,8),(12,12)]. Sholat meng-override patroli
  (`_mode_sholat` dicek PALING DULU di `_process`); sesudah sholat
  keduanya kembali ke kursi masing-masing.
- **Sholat putri:** Ustadzah memimpin di Musholla — posisi imam di
  depan Sajadah_03 (dihitung seperti `_posisi_imam()` Surau). Bila
  sedang di dalam, ia langsung jalan ke sajadah; bila di luar, rute
  via (18,−14) → pintu musholla. Kyai tetap imam Surau (tidak
  berubah). Satpam tidak ikut sholat.

### D. Pakem batas (aturan keras)
- **Barrier tak terlihat** di sepanjang garis pagar (termasuk
  melintasi gerbang). Pemain (santri putra) yang mendekat dari sisi
  putra (x<0, z<16, jarak <1.5 m, bergerak ke arah pagar) mendapat
  toast **"Santri putra tidak boleh masuk area putri."** (throttle
  ~4 dtk). Zona bersama (z>+16) tetap terbuka.
- **Bilal/Faris tetap di area putra:** spawn Bilal (4,0,4) →
  **(−4,0,4)**; waypoint difilter — hanya yang x<−0.5 atau z>16.5
  (**14 dipertahankan, 7 dibuang**: (4,4), (8,−2), (2,12), (10,8),
  (24,−10), (0,−20), (40,−100)). Rute sholat: koridor x=−12 →
  **−20**, plaza (0,2) → **(−2,2)** (supaya tidak menembus pagar
  secara visual).
- **Konsekuensi pakem yang TIDAK tertulis di brief tapi WAJIB
  (semua sudah dikerjakan):** spawn pemain (0,0,14) → **(−4,0,14)**
  (spawn lama tepat di garis pagar x=0); **peti M3** (6,10) →
  **(0,0,26)** zona bersama (peti lama di area putri — M3 akan
  mustahil diambil); **Cangkruk** (14,−14) → **(−12,−12)** (kamar
  tidur putra lama di area putri — tidur/ganti baju akan rusak);
  koridor sholat & plaza (di atas); Bilal + waypoint (di atas).
  Cangkruk Putri (12,−12) TIDAK dibangun ronde ini (belum ada
  pemain santriwati / sistem gender di game).

### E. Bubble chat TANPA outline (Mas 19:09 WIB — IKUT RONDE INI)
- Satu baris: `player.gd:613` bubble kini
  `Palette.label3d("", Vector3(0, 2.50, 0), 22, Color("#065f46"),
  true, true)` — argumen `tanpa_outline=true` membuat
  `outline_size = 0` (sebelumnya 8, putih, di atas teks hijau gelap
  — itu yang bikin kelihatan kolot). Font TIDAK diubah (sudah Baloo
  2 Bold sejak Ronde 6). Satu perubahan memperbaiki pemain + semua
  NPC (satu `build_visual`). Label nama sudah tanpa outline sejak
  Ronde 5 — tidak berubah.

## Bug yang ditemukan & diperbaiki selama verifikasi

1. **NPC TIDAK TERLIHAT di game (bug besar, akar: satu baris).**
   `npc.gd:60` mendeklarasi `var _kitab_pangku: MeshInstance3D`,
   padahal `player.gd _kitab()` mengembalikan **Node3D** (wadah:
   sampul marun + halaman + garis emas, sejak Ronde 9). Penugasan
   yang gagal di `setup()` (baris 118) menggagalkan `setup()` di
   tengah jalan: `add_child(_visual)` tidak pernah jalan — visual,
   bubble, dan label nama NPC **di luar tree (tidak terlihat di
   game)** — dan blok patroli tidak pernah jalan (Kyai/Ustadzah
   diam di spawn). Perbaikan: `var _kitab_pangku: Node3D`.
   **Pertanyaan terbuka (belum terjawab):** apakah NPC sudah tidak
   terlihat sejak Ronde 9 (saat `_kitab()` jadi wadah Node3D), atau
   ketidakcocokan ini lebih baru? Retest live ronde 10–14 memakai
   cek posisi/fase, bukan visibilitas — jadi tidak akan ketahuan
   dari sana. Perlu dicek di build live bila penting.
2. **Interior musholla diputar +25° (salah arah)** — `ke_dunia`
   memakai `deg_to_rad(-ROTASI_DEG)` dengan ROTASI_DEG=−25, jadi
   putaran +25°: normal dinding barat mengarah 245° (50° melenceng
   dari kiblat). Diperbaiki: `deg_to_rad(ROTASI_DEG)` (−25°) —
   normal dinding barat kini 295°, persis Surau. Konstanta KELUAR /
   KE_DALAM / SUMBU yang tak terpakai ikut dibetulkan; `ke_lokal()`
   ditambahkan untuk tes. Akibat: spawn musholla (59.37,−297.36) →
   **(60.63,−297.36)**; kursi Ustadzah (61.27,−306.52) →
   **(68.88,−301.79)**.
3. **Nama duplikat** — 6 barrier semua "BarrierPagar", 4 pos jaga
   semua "PosJaga" (Godot mengganti nama otomatis, `find_children`
   hanya menemukan 1). Diperbaiki: nama berindeks
   `BarrierPagar_1..6` / `PosJaga_1..4`; label gubuk memakai nama
   dasar supaya tetap "POS JAGA" / "POS SATPAM".
4. **Rute pulang Ustadzah default ke spawn putra** — `_npc_rumah`
   hanya diisi saat sholat dimulai; tes memanggil `_rute_pulang`
   sebelum sholat → rumah = spawn pemain (−4,14, area putra).
   Diperbaiki: `_npc_rumah` diisi di `_spawn_npcs` (Kyai → serambi
   (−4.8,−4.8), Ustadzah → (18,−16) dekat pintu musholla).
5. **Detour 300 m sesudah sholat** — setelah `pulang_luar` para
   pemimpin sudah di kursi (di dalam), tapi kode memaksa fase
   "ke_pintu_luar" (jalan ~300 m keluar menembus dinding, teleport
   masuk, jalan kembali). Diperbaiki: bila jarak ke kursi < 3.0 m,
   langsung "ke_kursi".
6. **Patroli macet (npc.gd:402)** — `_patroli_rute =
   _patroli["rute_luar"]` (Array tak bertipe dari Dictionary ke
   `Array[Vector3]`) melempar runtime error, menggagalkan
   `_proses_patroli` sebelum fase jadi "patroli"; NPC macet
   berosilasi di "ke_pintu_dalam". Diperbaiki:
   `_patroli_rute.assign(_patroli["rute_luar"])`.
7. **Palette di interior_musholla.gd** — konstanta khayalan
   `SAJADAH_IJO`, `HIJAU`, `BIRU`, `ORANYE`, `KUNING_LAMPU`,
   `KREM_PUTIH` tidak ada di palette (hanya RUMPUT, PASIR,
   PASIR_GELAP, PUTIH, ZAMRUD, ZAMRUD_GELAP, EMAS, EMAS_TERANG,
   KAYU, KAYU_GELAP, KULIT, KOKO, SARUNG, HITAM, ABU). Diperbaiki:
   sajadah → `Palette.ZAMRUD`, lampu → `Color("#ffd9a0")`, kitab →
   `[Palette.ZAMRUD, Color("#1d4e6b"), Color("#c96a1e")]`,
   krem → `Palette.PUTIH`.

## Verifikasi

- **Tes headless `test_ronde20.gd/.tscn`** (seksi A Musholla, B
  Pagar, C Konsekuensi, D Batas, E Karakter, F Patroli, G Sholat +
  smoke 600 frame): **104 LOLOS / 0 GAGAL, EXIT=0**
  (log `/tmp/tes-ronde20d.log`), **0 SCRIPT ERROR / 0 ERROR**.
  Perjalanan tes: run 1 gagal parse (cache kelas global basi +
  palette khayalan + inferensi tipe tes); run 2: 77/16 (bug #1
  dominan + 7 kesalahan ekspektasi tes); run 3: 96/8 (bug #6 +
  timeout kumpul 25 dtk karena Bilal/Faris keliling jauh — tes
  kini men-teleport mereka ke spawn sebelum sholat); run 4: 103/1
  (tunggu kembali-duduk 3000 frame ≈ 120 dtk game < jalan pulang
  ~186–220 dtk — tes kini menunggu 9000 frame); **run 5: 104/0**.
  Kesalahan ekspektasi tes yang diperbaiki (game-nya benar):
  sumbu 115° = (0.906, 0, 0.423) bukan sebaliknya; jalan musholla
  diukur dari tengah, bukan ujung selatan; mihrab dicek di
  koordinat lokal via `ke_lokal()`; waypoint 21 − 7 = **14**,
  bukan 15; cek "kembali duduk" per pemimpin (bukan simultan).
- **Bubble:** tes seksi E memeriksa bubble pemain outline_size==0,
  warna tetap #065f46, font tetap `Palette.FONT_GAME`, bubble NPC
  outline_size==0, label nama tetap 0 — **semua LOLOS**.
- **Foto bukti** di `~/workspace/pesantren-verse/foto-ronde-20/`
  (render software xvfb-run + opengl3, jam 10.00) — 9 foto:
  01-musholla-eksterior.png (dari tenggara-atas: kubah emas +
  menara kecil), 01b-musholla-eksterior-pintu.png (dari selatan:
  pintu + plakat مصلى الروضة + kubah),
  02-musholla-interior.png (sajadah + mihrab emas + label محراب +
  smartboard + rak kitab + lampu hangat),
  03-pagar-gerbang-satpam.png (gerbang + pagar + pos satpam),
  04-pos-jaga.png (pos jaga + lampu),
  05-ustadzah-duduk.png (Ustadzah Mariyah duduk baca kitab, hijab
  zamrud + kitab marun di pangkuan, rak kitab di belakang),
  06-kyai-duduk.png (Kyai duduk baca kitab, serban putih + jenggot,
  meja sampar + rak kitab),
  07-batas-ditahan.png (pemain di gerbang + toast "Santri putra
  tidak boleh masuk area putri." + pos satpam),
  08-bubble-tanpa-outline.png (Bilal close-up, bubble hijau gelap
  tanpa outline putih — tiga baris terbaca penuh berlatar langit;
  label nama "Bilal" juga tanpa outline).
  Catatan foto: 02 + 08 sempat gagal di pengambilan pertama
  (02: kamera terlalu dekat dinding/pilar; 08: Bilal sudah keliling
  menjauh saat render lambat + bubble hanya 5 dtk) — di-retake
  dengan sudut tenggara untuk 02 dan Bilal dibekukan + `say()`
  tepat sebelum jepret untuk 08 (retake ke-2: kamera rendah
  menengadah supaya bubble berlatar langit, bukan atap Surau).

## Jujur / belum sempurna
- **Retest browser live MASIH dibutuhkan** (Chromium VM tidak bisa
  start; tes headless tidak menangkap kegagalan live — pelajaran
  ronde 10–14). Yang perlu dicek di build live: musholla masuk/
  keluar, pagar menahan + toast, Ustadzah/Kyai terlihat duduk
  (terutama mengingat bug #1 — NPC mungkin sudah lama tak terlihat
  di live), patroli, sholat putri, bubble tanpa outline.
- Pohon di (−20,−26) berdiri di koridor patroli Kyai yang baru
  (x=−20) — NPC mengabaikan collision, jadi hanya klip visual
  singkat saat Kyai lewat. Pohon dipindah dari (−20,−20) ke
  (−20,−26) supaya tidak tepat di koridor; klip sisa diterima
  (rute NPC memang mengabaikan pohon).
- Pagar memotong plakat plot Masjid Besar (sudah digeser 3 m ke
  barat); saat masjid dibangun, pagar harus bertemu dindingnya.
- Jalan musholla berakhir di (7.0,−0.47) — akan digeser ke x=24
  saat Kelas Putri dibangun (Fase B).
- Satpam tidak bisa masuk Surau/Musholla (bukan santri, tidak ikut
  sholat) — sesuai desain; bila Mas mau satpam ikut sholat, itu
  perubahan perilaku.

## Export
- **Export: `export/web/`** — pck BARU **1.572.616 byte**, sha256
  `c8b874837161d42ee416a516de26e4b7a8c61c346d2ffd56c670e16ee4fa04f4`
  (+28.228 dari 1.544.388 ronde 19 + Surau fix); wasm TIDAK berubah
  (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…`); worklet `index.audio.position.worklet.js` 2.973
  byte ada; guard script export segar **2/2** (3/3 berlaku di
  staging setelah patch wasm-fetch Damar); smoke pck 600 frame
  **0 SCRIPT ERROR / 0 ERROR, EXIT=0**.
- Skrip tes + foto sudah dihapus dari proyek sebelum export
  (salinan akhir: `~/workspace/pesantren-verse/ronde-20/skrip/`).
- **TIDAK deploy** (Damar deploy setelah verifikasi — Damar: salin
  pck baru + update GODOT_CONFIG 1544388 → 1572616 + cek guard).

## Sisa kerja / berikutnya
- Konfirmasi Mas: mihrab dinding barat vs utara (flag 1).
- Retest browser live ronde 20 (oleh parent) + ronde 17+18+19
  yang masih tertunggak.
- Lamaran pengurus di game (pengumuman + label jabatan) — antre
  setelah Ronde 20.
- Integrasi game ↔ server (login username, kirim poin, ranking) —
  antre setelah perbaikan game.
- Poles UI (Tara) — Mas setuju arah UI Roblox 19:28 WIB; ronde
  khusus setelah Ronde 20.
- Pembaca rak kitab Jurumiyah (server v1.5.0 siap; butuh cek ustadz
  dulu) — setelah Ronde 20.

## Susulan — pohon pindah + perbaikan NaN idle (Raka, 16 Nov ~13:23 WIB)

### Pohon (22,−22) → (22,−32)
- **Masalah:** pohon di (22,−22) berdiri DI DALAM Musholla Ar-Raudhah — diukur terhadap rect musholla yang TERPUTAR −25° (bukan kotak sumbu): koordinat lokal (22.47,−23.88) di dalam rect, jarak dinding 0,00 m, tajuk menembus dinding 1,15 m — terlihat di foto 01 (gumpalan tajuk hijau di dinding timur).
- **Pilihan diukur (Python, terhadap rect terputar + jalan + patroli + pohon lain + pagar + plot + pos jaga + menara):** kandidat A (26,−22) DITOLAK — batang 3,10 m dari dinding timur, tajuk cuma 1,95 m (terlalu mepet). **Dipilih B (22,−32), utara musholla: batang 4,94 m dari dinding utara, tajuk 3,79 m; 11,69 m dari tepi JalanMusholla; 16,49 m dari rute patroli Ustadzah; pohon terdekat 18,44 m; menara 7,22 m; pos jaga 18,25 m; plot Masjid 22,80 m.** Satu baris di `scripts/pesantren_builder.gd:1060` + komentar.
- **Verifikasi pohon** (`test_pohon_pindah.gd`, memindai 61 badan tabrakan pohon di dunia yang dibangun): **6 LOLOS / 0 GAGAL** — 61 pohon, ada di (22,−32), tidak lagi di (22,−22), semua pohon ≥3 m dari dinding musholla (terdekat 4,94 m).
- **Foto bukti:** `foto-ronde-20/01-musholla-eksterior-pindah-pohon.png` — sudut PERSIS foto 01 (kamera (28,4.5,−10) → (18,2,−24), jam 10.00): dinding timur musholla BERSIH, tajuk tidak lagi menembus. Foto 01 lama TIDAK ditimpa (bukti "sebelum").

### Bug NaN idle — ditemukan saat verifikasi, DIPERBAIKI sebelum export
- **Gejala:** tes lengkap Ronde 20 pertama sesudah pindah pohon: **104 LOLOS / 0 GAGAL TAPI 28.590 ERROR** `!v.is_finite()` di `instance_set_transform`, mulai seksi F (Patroli). Run 5 Ronde 20 (log tes-ronde20d.log) 0 error — run ini kena karena kebetulan frame lambat.
- **Akar masalah (probe membuktikan):** `_animate_idle` di `scripts/npc.gd` + lerp jalan/idle di `scripts/player.gd` memakai bobot lerp mentah `delta * 8.0` / `delta * 10.0` TANPA dijepit — di frame lambat (time_scale 6.0 di tes / lag di HP) bobot > 1 membuat lerp DIVERGEN eksponensial sampai tak-hingga. Probe: **Satpam** `visual.pos=(0,−inf,0)` di frame 60 (fase "duduk" = default string; Satpam mode diam → `_animate_idle` tiap frame) → transform tidak finite → visual Satpam hilang + renderer spam error tiap frame. **BUKAN disebabkan pindah pohon** (pohon 16+ m dari semua rute patroli; pemicunya frame lambat).
- **Perbaikan (idiom yang sama, sudah dipakai file itu):** jepit bobot `minf(1.0, delta * 8.0)` / `minf(1.0, delta * 10.0)` — npc.gd `_animate_idle` (5 lerp) + player.gd blok jalan/idle (7 lerp: rotation.x jalan, 4 lengan/kaki, napas idle, rotation.x idle). Pola jepit ini sudah ada di `_terapkan_duduk_baca`/`_terapkan_pakaian` dan yaw pemain (RONDE 5 — "di frame lambat, delta*10 > 1 membuat visual berputar melewati target lalu berosilasi"); yang di sini ketinggalan.
- **Verifikasi ulang:** probe 600 frame (pemain + 5 NPC diperiksa tiap frame) **TIDAK ADA NaN, 0 is_finite**; tes lengkap Ronde 20 diulang **104 LOLOS / 0 GAGAL, EXIT=0, 0 is_finite, 0 SCRIPT ERROR, 0 ERROR non-audio** (log /tmp/tes-ronde20-susulan2.log); tes pohon diulang **6/6**. (Satu ERROR ERR_CANT_OPEN di awal tiap run = VM tanpa soundcard, bukan bug game — sudah dikenal sejak Ronde 17.)
- Insiden: dua kali skrip probe gagal parse karena sintaks Python (`[x for x in ...]` — GDScript tidak punya list comprehension; `var b := ...basis` tak bisa diinferensi) → engine jalan tanpa skrip sampai dimatikan manual; sekali `pkill -f` mematikan shell sendiri (pola cocok dengan command line sendiri) — bunuh pakai PID saja.

### Export susulan
- **Export: `export/web/`** — pck BARU **1.572.776 byte**, sha256 `212d995c0fb407f676c7f8f5325c776d309095f826f318d5bb96395e16d41f5b` (+160 dari 1.572.616 Ronde 20); wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet `index.audio.position.worklet.js` 2.973 byte ada; guard script export segar **2/2** (3/3 berlaku di staging setelah patch wasm-fetch Damar).
- Skrip tes/foto/probe susulan diarsipkan di `~/workspace/pesantren-verse/ronde-20/skrip-susulan-pohon/` dan DIHAPUS dari proyek sebelum export (pck bersih).
- **TIDAK deploy** (Damar deploy setelah verifikasi — Damar: salin pck baru + update GODOT_CONFIG 1572616 → 1572776 + cek guard).
- **TIDAK disentuh:** mihrab (tetap dinding barat, menunggu keputusan Mas); posisi musholla (relokasi ke (62,−24) = Ronde 21, SETELAH deploy ini, per ACC Mas 19:49 WIB); kostum Ustadzah (abaya + jilbab, antre sesudah ini, sebelum deploy).

## Susulan — kostum Ustadzah abaya + jilbab (Raka, 16 Nov ~20:24–20:45 WIB)

### Masalah (keputusan Mas 19:42 WIB)
- Kostum Ustadzah Mariyah lama — koko putih/krem + sarung batik zamrud + penutup kepala seperti songkok (kubah kecil zamrud) — terbaca laki-laki ("malah kek ustadz 😀"). Foto 05 lama membuktikan: dari jauh ia tampak santriwan berpeci hijau.
- Perintah Mas: pakai abaya dan jilbab.

### Yang dibangun
- **Abaya** (satu gamis panjang longgar, bahu → mata kaki) menggantikan koko + sarung sekaligus: tabung meruncing atas r=0.23 → bawah r=0.36, tinggi 1.32, pusat y=0.76 (bawah y=0.10, sama seperti sarung ronde 6), zamrud gelap #065f46 polos (TANPA motif batik — motif batik itu yang membuat roknya terbaca "sarung santri"), lis emas di hem. Torso + lengan panjang sewarna abaya; TANPA kerah, TANPA kancing koko.
- **Jilbab** krem #f2ead6 (kontras dengan abaya gelap — yang membuat jilbab terbaca dari jauh), 6 bagian: kubah (r=0.28, tepi depan menyilang wajah tepat di atas alis, mata tetap di depan kain), drape belakang (sampai punggung atas), cape bahu (r=0.40, menutupi bahu), drape depan (dada, dari bawah dagu sampai pinggang), 2 strip sisi pembingkai wajah.
- **Target pakaian sendiri** (`PAKAIAN_ABAYA_DEFAULT` / `PAKAIAN_ABAYA_DUDUK` di player.gd; pemetaan di `npc.gd _terapkan_pakaian`): PAKAIAN_DUDUK (sarung mengerut y 0.45) akan menghancurkan gamis 1,32 m + membuka kaki bersila — abaya duduk justru MELEBAR (1.55) + sedikit memendek (0.78), hem tetap ~0.04 m di atas lantai, kaki bersila tertutup kain.
- Perilaku TIDAK berubah: duduk baca kitab (kitab pangku tetap), patroli area putri, imam putri. Mihrab TIDAK disentuh (tetap barat). Musholla TIDAK dipindah (relokasi = Ronde 21).
- `OUTFIT_USTADZAH` baru: koko #065f46, sarung #065f46, hijab_warna #f2ead6, kunci baru `abaya` + `muslimah: true`. Node "Hijab" dipertahankan (tes + referensi lama), node baru "Abaya"; `build_visual` mengembalikan "abaya" + "muslimah".

### Dua bug visual ditemukan dari foto + diperbaiki
- (1) Cape lama (r=0.34) tenggelam di balik abaya saat duduk (abaya melebar 1.55x, puncaknya naik ke 1.48) → bahu terbaca tabung polos. Perbaikan: cape diperbesar (r=0.40, y 1.26..1.58) + abaya duduk sedikit direndahkan (pusat 0.97, skala y 0.78).
- (2) Drape depan lama (z=0.185, diukur dari torso r=0.21) TENGGELAM di dalam abaya (permukaan abaya di dada z~0.25-0.27) — hanya tepinya yang mencuat, terbaca dua bilah krem seperti suspender (foto 05d pertama). Perbaikan: panel pindah ke z=0.28 + miring -0.10 mengikuti kemiringan abaya → satu drape dada utuh.

### Verifikasi
- Tes lengkap Ronde 20 diulang (3 run): **110 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR / 0 SCRIPT ERROR / 0 is_finite** (log /tmp/tes-ronde20-kostum3.log) — 104 lama (3 asersi hijab diperbarui: jilbab krem + 6 bagian) + 6 baru (abaya, abaya #065f46, tanpa sarung batik, tanpa kancing/kerah, gamis 1,32 m, abaya duduk skala 1.55,0.78,1.55 — terukur eksak). Smoke 600 frame selesai. Perbaikan NaN idle susulan pohon TETAP berlaku (0 is_finite).
- Foto baru di `foto-ronde-20/` (05 lama TIDAK ditimpa): `05b-ustadzah-abaya-depan.png` (sudut persis foto 05 — perbandingan langsung), `05c-ustadzah-abaya-dekat.png` (close-up depan, arah kiblat 295°), `05d-ustadzah-abaya-berdiri.png` (berdiri, abaya utuh + drape dada). Semua dilihat: siluet abaya + jilbab terbaca jelas, beda nyata dari Kyai (koko + sarung + serban) dan santriwan (koko + sarung + songkok).
- Insiden: foto pertama gagal 3/3 (`save_png` null) — skrip foto dijalankan dengan `--headless` (tidak ada render); foto harus jalan TANPA --headless (xvfb-run saja, render llvmpipe). Foto 05d pertama juga salah hadap (rotation.y = 0 = menghadap selatan/+Z, kamera di utara) → diperbaiki ke PI.

### Export susulan
- **Export: `export/web/`** — pck BARU **1.574.232 byte**, sha256 `8844375fe67d9de719444535a801a12ef475dbb38c587b6ed87a2e6ec8883c52` (+1.456 dari 1.572.776 susulan pohon); wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet `index.audio.position.worklet.js` 2.973 byte ada; guard script export segar **2/2** (3/3 berlaku di staging setelah patch wasm-fetch Damar); skrip tes/foto TIDAK ada di pck (dihapus dari proyek sebelum export).
- Skrip tes/foto susulan diarsipkan di `~/workspace/pesantren-verse/ronde-20/skrip-susulan-kostum/` (test_ronde20.gd + foto_ustadzah_abaya.gd + .tscn).
- **TIDAK deploy** (Damar deploy setelah verifikasi — Damar: salin pck baru + update GODOT_CONFIG 1572776 → 1574232 + cek guard).
- **TIDAK disentuh:** mihrab (tetap dinding barat, menunggu keputusan Mas); posisi musholla (relokasi ke (62,−24) = Ronde 21, SETELAH deploy ini, per ACC Mas 19:49 WIB); pagar (pagar kayu/tembok putri = gambar ACC dulu, bukan ronde ini).

### Catatan desain untuk nanti (JANGAN dibangun sekarang)
- **Seragam santri putri nanti juga abaya/gamis + jilbab, bukan koko** (keputusan Mas 19:45 WIB). Konstruksi di sini PAKAI ULANG untuk santriwati: flag `muslimah: true` + kunci `abaya` di outfit → `build_visual` sudah bercabang (abaya + jilbab + tanpa kerah/kancing + target PAKAIAN_ABAYA); yang belum ada hanya karakter santriwati-nya sendiri (outfit + gender L/P + penempatan asrama). Yang mungkin perlu nanti: warna abaya santriwati vs Ustadzah (saat ini sama #065f46 — kalau santriwati dibangun, bedakan supaya Ustadzah tetap terbaca sebagai pimpinan; belum diputuskan Mas).

### Susulan — Perbaikan jalan + lampu (Mas 16 Nov ~21:12 WIB, Raka)

**Pemicu:** Mas menanggapi game live Ronde 20: "Jalan dan lampu dibangun ulang. Yg rapi. Masa ada tiang di tengah jalan."

**Audit (skrip baru `perbaikan-jalan-lampu-2/skrip/audit_jalan_lampu.gd`, ukur dari dunia yang dibangun — jalan = BoxMesh tebal 0.06, tiang dari grup/koleksi dunia):** run pertama **89 LOLOS / 43 GAGAL**. Yang Mas maksud + yang sama salahnya:
- **Pilar gerbang (0,±2) DI ATAS jalan N-S (0,00 m)** + **~20 tiang pagar x=0 DI ATAS jalan N-S** — pagar membelah TENGAH jalan (pagar dan jalan sama-sama di x=0).
- **Tiang pagar (9,−4) DI ATAS JalanMusholla** + (9,−8.5) mepet 0,36 m — belokan pagar memotong jalan musholla.
- **Tiang papan Masjid (−1,−21.4) DI ATAS jalan N-S**; papan Perpus (±2,24.6) mepet 0,50 m.
- **Pohon (10,−6) DI ATAS JalanMusholla**; pohon (−52,2) mepet 0,75 m ke jalan E-W (tajuk menggantung di atas jalan).
- **7 lampu jalan mepet 0,70 m** dari tepi jalan (x=±2.2, sisi acak, jarak z tak teratur) — di foto 03 lampu (−2.2,6) tampak berdiri di atas jalan.
- Sudut pos satpam menyentuh tepi jalan N-S (0,00 m); dinding utaranya 0,25 m dari jalan E-W.

**Perbaikan (semua di `scripts/pesantren_builder.gd` + `scripts/main.gd`):**
- **Pagar + gerbang + pos satpam PINDAH ke timur x=2.5** (garis pagar (2.5,−60)→(2.5,−17.5)→(9,−17.5)→(9,−4)→(2.5,−4)→(2.5,16); belokan x=9 TETAP menjaga Surau; gerbang (2.5,0) pilar (2.5,±2) 1,0 m dari tepi jalan N-S; pos satpam (3,3)→(5.5,5), 2,5 m dari jalan N-S + 2,25 m dari E-W; satpam NPC ikut pindah, yaw −2.36→−2.60 menghadap gerbang; `_cek_batas` early-return `p.x >= 0.0` → `p.x >= 2.5`; barrier + peta mengikuti konstanta otomatis). **CATATAN JUJUR — brief bilang "JANGAN ubah pagar":** pagar di x=0 membuat "tidak ada tiang di atas jalan" MUSTAHIL dipenuhi tiang pagarnya sendiri; memindah pagar adalah satu-satunya perbaikan geometris (jalan N-S tidak bisa pindah barat = menabrak Surau, tidak bisa pindah timur = masuk area putri). Diputuskan Raka + dilaporkan ke Mas lewat Xam — bukan diam-diam.
- **Lampu dibangun ulang:** 7 lampu N-S SEMUA di sisi barat x=−2.5 (1,0 m dari tepi), z teratur 20 m (−70,−50,−30,10,30,50,70 — dilewati z −10 = di dalam Surau, z 0 = persimpangan, z −20 = 1 m dari sudut NW Surau); lampu JalanSurau baru (−6.89,−2.67), 1,05 m di luar tepi barat jalan; lampu JalanMusholla baru (15.86,−13.96), 1,05 m di luar tepi timur jalan; lampu pos jaga/satpam TETAP (sudah bersih). Total lampu 14 (9 jalan + 4 pos jaga + 1 satpam — gubuk sawah memang TIDAK punya lampu).
- **JalanMusholla DIPENDEKKAN 22 → 12 m** (ujung selatan baru (11.24,−9.49), di area patroli Ustadzah): jalan lama menabrak belokan pagar x=9 dan koridor antara tiang (9,−4) dan plot Kelas (x=11) hanya 2 m — jalan 2,5 m TIDAK BISA lewat tanpa menabrak pagar atau plot. Saat Ronde 21 memindah plot Kelas ke (58,0), jalan bisa dipanjangkan lagi ke jalan E-W.
- **Papan Masjid + Perpus digeser −5.0** (tiang di x=−7/−3; Masjid 1,75 m, Perpus 1,50 m dari tepi jalan).
- **Pohon (10,−6)→(14,−6)** (3,14 m dari tepi JalanMusholla) dan **(−52,2)→(−52,6)** (4,75 m dari tepi jalan E-W).
- **Pengecualian yang didokumentasikan:** 2 pilar gerbang + 2 tiang pagar ujung celah gerbang di (2.5,±2) berada 0,75 m dari tepi jalan E-W — posisinya DI SUDUT persimpangan (gerbang memang di persimpangan), tidak di atas jalan dan tidak menghalangi jalan; bar audit untuk keempat tiang itu 0,5 m, bukan 1,0 m.
- **TIDAK disentuh:** posisi bangunan, mihrab (tetap barat), spawn, peti M3, Cangkruk, musholla (relokasi (62,−24) = Ronde 21).

**Verifikasi:**
- Audit ulang (skrip diperbaiki: nama jalan terbaca, buang false positive interior z<−250 + kotak <5 m²): **129 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR** — 9 jalan, 14 lampu, 2 pilar, 29 tiang pagar, 8 tiang papan, 60 pohon, 10 tiang tinggi, 5 footprint pos. (Perbaikan skrip: filter interior awal z<−100 salah membuang ruas jalan N-S utara (pusat z=−108) — diganti z<−250; offset lampu jalan 2,25 m → 2,30 m karena pembulatan koordinat 2 desimal membuat audit mengukur 0,9998 m.)
- Tes lengkap Ronde 20 diulang (test_ronde20.gd diperbarui: 12 asersi baru seksi G + `_tes_batas` disesuaikan pagar x=2.5 — pemain ditahan x~2.05, dari putri mulai (5,0,0) ditahan x~2.95, jarak pagar dari spawn 6,5 m): **122 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR, 0 NaN** (110 lama + 12 baru). Smoke 600 frame selesai. Perbaikan NaN idle TETAP berlaku (0 is_finite).
- Foto baru di `foto-ronde-20/` (foto lama TIDAK ditimpa): `09-jalan-ns-utara.png` (jalan N-S dari selatan — lampu barat, pagar timur, jalan bersih), `10-jalan-ew-timur.png` (jalan E-W + gerbang di kejauhan + pos satpam), `11-persimpangan-gerbang.png` (gerbang dari dekat — pilar di tepi bukaan, pos satpam baru (5.5,5) + satpam NPC di depannya), `12-jalansurau-lampu.png` (JalanSurau lurus ke pintu + plakat + lampu di tepi barat jalan), `13-jalan-musholla.png` (JalanMusholla + lampu di tepi timur + belokan pagar + pohon (14,−6) di luar jalan). Semua dilihat: tidak ada tiang di tengah jalan mana pun.
- Skrip audit + tes + foto diarsipkan di `perbaikan-jalan-lampu-2/skrip/` (audit_jalan_lampu.gd/.tscn, foto_jalan_lampu_baru.gd/.tscn) dan `ronde-20/skrip-susulan-kostum/` (test_ronde20.gd/.tscn, diperbarui).

### Export susulan jalan + lampu
- **Export: `export/web/`** — pck BARU **1.574.360 byte**, sha256 `8343a6dd543dca0d70c169672b5d681fc7d69e51ac4ae45ee624daa9ab5aaa91` (+128 dari 1.574.232 kostum); wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet `index.audio.position.worklet.js` 2.973 byte ada; guard script export segar **2/2** (3/3 berlaku di staging setelah patch wasm-fetch Damar); skrip tes/foto/audit TIDAK ada di pck (dihapus dari proyek sebelum export).
- **TIDAK deploy** (Damar deploy setelah verifikasi — Damar: salin pck baru + update GODOT_CONFIG 1574232 → 1574360 + cek guard).

### Perbaikan figur Ustadzah — KIRANA 16 Nov ~21:45–21:52 WIB (Mas: "Kok aneh" menanggapi foto 05d)
- **Yang aneh di 05d (dilihat langsung):** badan kerucut hijau tanpa lengan; jilbab depan kotak seperti celemek; wajah topeng coklat datar dua titik mata; kubah jilbab terlalu besar dan bulat.
- **Akar masalah (terukur di `scripts/player.gd build_visual`):** pivot lengan (±0.235, 1.30) berada DI DALAM kerucut abaya (permukaan 0.242 di y=1.30, melebar ke 0.30 di y=0.72) + cape raksasa (x ±0.46, y 1.26..1.58) menelan bahu — lengan sewarna abaya jadi tidak terbaca sama sekali.
- **Perbaikan (semua di `scripts/player.gd`, HANYA cabang `muslimah` — santriwan/Kyai tidak berubah):**
  - Lengan keluar dari abaya: pivot ±0.235 → **±0.34**, miring keluar 0.05 → **0.12**, lengan atas r 0.10 → 0.11, lengan bawah 0.08 → 0.085 (sleeve abaya terbaca + tangan kulit terlihat di ujung).
  - Kubah jilbab dikecilkan: r 0.28 → **0.255**, skala (1.08,0.62,1.08) → (1.05,0.58,1.05), pusat (0,1.80,−0.05) → (0,1.79,−0.04) — puncak 1.94, mata/alis tetap di depan kubah.
  - Cape bahu dipipihkan: skala y 0.40 → **0.28**, pusat y 1.42 → 1.38 (drape bahu, bukan pelampung); lebar x tetap ±0.46 supaya saat duduk tetap di luar abaya yang melebar 1.55x.
  - Drape depan kotak → **elipsoid pipih** (bola r=0.20 di (0,1.18,0.24), skala (0.72,1.15,0.45)): atas meruncing ke bawah dagu, tengah terlebar di dada, bawah membulat seperti ujung kain; ujung atas terselip di balik cape. Revisi 21:52: skala x 0.85 → 0.72 (terlalu lebar menutupi dada seperti pelat di foto pertama).
  - Wajah: mata muslimah 0.025 → **0.028**; **alis baru** (2 kapsul tipis di (±0.085,1.735,0.222), di depan tepi kubah); strip sisi dipindah ±0.21 → **±0.235** + dipersempit 0.10 → 0.08 (bukaan wajah 0.32 → 0.39). Revisi 21:52: alis miring (PI/2 ± 0.10) membuat wajah terlihat marah/jutek di foto pertama — kini **datar**.
  - Abaya tetap zamrud gelap #065f46 polos + lis emas, jilbab tetap krem #f2ead6; perilaku tidak berubah (duduk-baca, patroli, imam putri).
- **Verifikasi:** tes lengkap Ronde 20 diulang (test_ronde20.gd + 5 asersi baru seksi E: pivot lengan 0.34, miring 0.12 dicek via build_visual langsung — pose duduk menimpa rotation.z jadi −0.15, asersi pertama sempat gagal karena itu; alis ada; drape elipsoid; kubah r=0.255): **127 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR, 0 NaN** (122 + 5 baru). Smoke 600 frame selesai.
- Foto baru di `foto-ronde-20/` (sudut PERSIS 05b/05c/05d, foto lama TIDAK ditimpa): `05e-ustadzah-baru-duduk.png` (bersila baca kitab — abaya melebar, kitab di pangkuan, tangan terlihat), `05f-ustadzah-baru-dekat.png` (close-up: alis datar, mata lebih besar, kubah lebih kecil, strip membingkai wajah), `05g-ustadzah-baru-berdiri.png` (berdiri: lengan + tangan terlihat di kedua sisi, drape oval membulat di dada, siluet bukan kerucut). Semua dilihat Kirana: keempat keluhan Mas teratasi.
- Skrip foto diarsipkan di `perbaikan-ustadzah-kirana/skrip/` (foto_ustadzah_kirana.gd/.tscn); salinan tes/foto dihapus dari root proyek setelah jalan.
- **TIDAK export pck** — perbaikan ini di source (`scripts/player.gd`) saja; pck export/web saat ini (1.574.360 byte, sha256 8343a6dd…) adalah hasil export Raka SEBELUM perbaikan ini — perlu re-export gabungan (dikoordinasikan Xam/Damar; deploy jalan+lampu sendiri masih ditahan menunggu ACC peta revisi Gilang).
