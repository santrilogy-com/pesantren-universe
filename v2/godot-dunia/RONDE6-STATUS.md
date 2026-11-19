# RONDE 6 — STATUS (15 Nov 2026, ~23:50 WIB)

Perintah Mas 21:58 WIB (6 item) + 22:04 WIB (9 item: rambut, sarung
panjang, sandal lepas, double Surau, bubble kecil, tidur, kamar
cangkruk, ganti baju, font prioritas) + 22:08 WIB (perbaikan lengan/
tangan) + 22:17 WIB (sistem SATU jalur — tanpa pilihan Misi/Ngaji
Aja — + jadwal khataman) + 22:55 WIB (plakat PAKAI HAMZAH — tanpa
perubahan; sarung motif BATIK, bisa diganti warna) + 23:01 WIB
(lengan/bahu DIULANG serius — satu bentuk halus; cangkruk DIUBAH
jadi pos ronda tertutup & luas isi 5 kasur). Build ronde 5 tetap
LIVE (deployment 13177323) sampai ronde 6 ini di-deploy Damar.

## Ringkas

Semua 15 item + perbaikan lengan (2x) + sistem satu jalur + motif
batik + cangkruk pos ronda 5 kasur SELESAI di kode dan lolos tes
logika **130/130, 0 gagal** (test_ronde6.gd, exit 0), smoke
headless 0 script error, `--import` exit 0, `--check-only` 12/12
script OK. **Export SELESAI ke `export/web/` (exit 0): pck baru
976.240 byte, sha256 `c85116fbd8582596cc7af1ae6d4f5749316b5e7a02c9e
1feb9ce9289591ba35f`; wasm TIDAK berubah
(`fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0`,
39.514.754 byte); index.js tidak berubah; worklet ada (2.973
byte).** TIDAK deploy (Damar).

## Yang berubah (per file)

### `project.godot`
- `[gui] theme/default_font="res://fonts/Baloo2-SemiBold.tres"` — font
  default SEMUA UI = Baloo 2 SemiBold.
- **TEMUAN PENTING (tes ronde 6):** setting ini TIDAK PERNAH aktif
  sejak ronde 6 — komentar multi-baris dengan `#` di project.godot
  merusak parsing ConfigFile Godot (parser hanya mengenal `;`
  sebagai komentar; baris `#` digabung ke setting berikutnya
  sehingga `theme/default_font` tidak terdaftar). Buktinya:
  `ProjectSettings.has_setting("gui/theme/default_font")` = false
  sebelum perbaikan, true sesudahnya. Komentar ditulis ulang
  dengan `;` + catatan larangan `#` di project.godot. Ini sebagian
  menjelaskan keluhan Mas "font ngasal banget ga pro banget" — UI
  selama ini memakai font fallback, bukan Baloo 2.

### `fonts/` (baru)
- `Baloo2-Variable.ttf` (683 KB, OFL) + `Baloo2-SemiBold.tres`
  (FontVariation wght 600) + `Baloo2-Bold.tres` (wght 700).
  FontVariation memakai properti `variation_opentype` (Dictionary)
  — properti `variation_coordinates` TIDAK ADA di Godot 4.7.
- `Amiri-Regular.ttf` (431 KB) + `Amiri-Bold.ttf` (413 KB, OFL)
  untuk teks Arab (plakat).

### `scripts/palette.gd`
- Konstanta `FONT_GAME` (Baloo2-Bold), `FONT_UI` (Baloo2-SemiBold),
  `FONT_ARAB` (Amiri-Bold).
- `label3d()` kini memakai `FONT_GAME`.
- Baru: `label_arab(teks, pos, font_size, color)` (Amiri Bold,
  billboard=false) dan `rapikan_bubble(teks, maks=100)` (potong +
  "…").

### `scripts/ui.gd`
- PetaControl + MinimapControl memakai `Palette.FONT_GAME` (dulu
  `ThemeDB.fallback_font`).
- **Panel Aksi (baru):** tombol HUD "Aksi" (kanan atas, setelah
  Chat); panel gelap ala MLBB, 7 tombol: Duduk Bersila / Berdiri /
  Salaman / Menulis / Bawa Kitab / Melambai / Tidur. Sinyal baru
  `aksi_dipilih(nama)`. Escape + klik-di-luar menutup; buka Chat
  menutup panel Aksi dan sebaliknya.
- **Panel Ganti Baju (baru):** panel krem, 3 baris Koko/Songkok/
  Sarung dengan tombol swatch warna + tanda "✓" pada pilihan aktif.
  Sinyal baru `outfit_dipilih(jenis, warna_hex)`; `open_outfit()`,
  `close_outfit()`, `is_outfit_visible()`, `set_outfit_terpilih()`.
  **BUG ✓ DIPERBAIKI (~23:05 WIB):** kunci tombol memakai
  `warna.to_html()` = 8 digit hex TANPA `#` (misal `faf7f0ff`)
  sementara `set_outfit_terpilih` membandingkan `"#rrggbb"` —
  tanda "✓" tidak pernah muncul. Sekarang kunci + hex yang
  di-emit memakai `"#" + warna.to_html(false)` (6 digit).
- **Login/daftar TANPA jalur (22:17 WIB):** OptionButton
  Misi/Ngaji Aja DIHAPUS dari kedua form; login hanya ID + nama,
  daftar hanya nama. Sinyal berubah: `login_submitted(id, nama)`,
  `register_submitted(nama)`. Estimasi tinggi form di
  `login_metrics()` disesuaikan (3 field -> 2 field).
- **Dashboard:** baris "Jalur:" DIHAPUS. Seksi "Ngaji Aja — jadwal"
  diganti **"Khataman — pengajian kitab (tiap hari, di surau)"**:
  3 sesi (05:00 Ba'da Subuh — Jurumiyah; 13:00 Siang — Amtsilah
  Tashrifiyyah; 18:30 Ba'da Maghrib — Safinatun Naja) + penanda
  "● SEDANG BERLANGSUNG" bila jam perangkat masuk jam sesi.
  Tombol "Hadir Khataman Hari Ini" (sinyal `khataman_joined`,
  dulu `ngaji_joined`); `set_khataman_hadir()`.
- Peta penuh + minimap: kamar cangkruk digambar (kotak coklat
  10×8 m + label "CANGKRUK" + legenda; minimap kotak 10×10 px).

### `scripts/player.gd` (ditulis ulang + revisi lengan/batik/tidur)
- `build_visual(nama, outfit)` — outfit = `{"koko", "songkok",
  "sarung"}` (tanda lama `build_visual(nama, sarung_color)` HILANG).
- **Rambut hitam:** bola r=0.245 skala (1, 0.8, 1) di (0, 1.74,
  -0.06) — di bawah songkok, tepi terlihat di sisi kepala.
- **Sarung sampai mata kaki:** tabung tinggi 0.80 pusat y=0.50
  (bawah y=0.10 = pergelangan kaki) + hem bulat y=0.12 + lis emas.
- **MOTIF BATIK (22:55 WIB, Mas):** `_motif_sarung` diganti dari
  checker (kotak-kotak) menjadi **batik parang prosedural**
  (ImageTexture 256×128): pita diagonal mengalir (x+y + tepi
  sinus bergelombang) + garis tepi tipis (isen-isen) + titik emas
  (mlinion) di pita terang; pola periodik 32 px di kedua sumbu
  supaya menyambung mulus melingkari tabung. Keempat warna sarung
  (Zamrud/Biru/Coklat/Hitam) tetap — masing-masing dirender batik
  dalam warnanya (cache per warna).
- **LENGAN SATU BENTUK HALUS (revisi 23:01 WIB — Mas: "tangan
  dan bahu MASIH JELEK, terkesan balok"; perbaikan 22:08 WIB
  bola r=0.10 + kapsul dua segmen BELUM CUKUP):** (a) **BahuYoke**
  — massa bahu koko (elipsoid pipih r=0.23, skala 1.35/0.45/0.95
  di y=1.30) menutupi pangkal bahu sepenuhnya, torso+yoke+bola
  bahu menyatu jadi satu massa bahu lebar; (b) lengan atas +
  bawah **TABUNG MERUNCING** (CylinderMesh, bukan kapsul):
  0.105 -> 0.085 -> 0.062 dari bahu ke pergelangan, siku LURUS
  (0.0) saat berdiri (bukan -0.18 — patahan sudut itulah yang
  terbaca balok); sendi siku ditutup bola r=0.085 (tak terlihat
  saat lurus, menutupi sambungan saat pose menekuk); ujung atas
  tabung tersembunyi di dalam bola bahu (r=0.115 > 0.105) dan
  bola siku; (c) **tangan membulat** — bola kulit r=0.075 yang
  dipipihkan (skala 1.0/0.7/1.3, memanjang ke arah jari), bukan
  kotak/kapsul. Lengan menggantung sedikit menjauh dari badan
  (rotasi z ±0.07); shading tetap lembut (roughness 0.45).
  Pose "berdiri" mengembalikan rotasi z ±0.07 + siku 0.0.
- **Kitab:** `_kitab()` (sampul zamrud + halaman krem + punggung
  emas); `kitab_tangan` (di lengan kanan, tersembunyi) +
  `kitab_pangku` (di pangkuan, tersembunyi).
- **Bubble kecil:** font 22 (dulu 28), lebar 240 (dulu 300);
  `show_chat` memotong via `Palette.rapikan_bubble` (maks 100
  karakter + "…"); cap ukuran tampak 0.09 (dulu 0.11).
- **Pose prosedural:** `set_aksi(nama)` — duduk (badan y -0.45,
  kaki -1.35 rad + silang ±0.35, lengan -0.7), menulis (duduk +
  lengan kanan -1.0 + goyang sinus + kitab pangkuan terlihat),
  salaman (lengan kanan -1.45), melambai (lengan kanan -2.6 +
  goyang z), tidur (visual rot.x -1.5, **y 0.58 — DI ATAS kasur**,
  lihat bawah), berdiri (reset rotasi kaki/lengan); bawa_kitab =
  toggle (kitab tangan terlihat + lengan kanan -0.55).
  Salaman/melambai kembali berdiri sendiri setelah 3.0 detik.
  `sedang_aksi_diam()` menahan gerak.
- **PERBAIKAN TIDUR (temuan foto 10, ~23:00 WIB):** target y
  pose tidur lama 0.22 membuat badan berbaring TENGGELAM ke dalam
  kasur (atas matras 0.51) sehingga di foto kasur tampak kosong.
  Diubah ke **y=0.58** — badan berbaring di atas kasur (kepala di
  bantal, kaki tidak menjuntai: snap tidur digeser dari +0.6
  menjadi +0.15 ke selatan dari pusat kasur, lihat main.gd).
- **Outfit:** `terapkan_outfit(outfit)` mewarnai ulang di tempat
  (Torso/BahuYoke/Bahu/Siku/Lengan -> koko; Peci -> songkok;
  Sarung/SarungHem -> sarung batik); `outfit_saat_ini()`.
- **Sandal:** `set_sandal(pakai)`, `sandal_dipakai()`.

### `scripts/npc.gd`
- Menyesuaikan tanda baru `build_visual` (outfit dict dari
  `MissionData.OUTFIT_DEFAULT` + warna sarung NPC); `say()`
  memotong via `rapikan_bubble(teks, 100)`; cap bubble 0.09.
  Siku NPC LURUS (0.0, sama seperti pemain — revisi 23:01 WIB).

### `scripts/mission_data.gd`
- `OUTFIT_KOKO` (Putih/Krem/Hijau Muda/Biru Muda), `OUTFIT_SONGKOK`
  (Putih/Hitam), `OUTFIT_SARUNG` (Zamrud/Biru/Coklat/Hitam),
  `OUTFIT_DEFAULT` (koko/songkok putih, sarung zamrud).
- `NGAJI_JADWAL` DIHAPUS, diganti `KHATAMAN_JADWAL` (3 sesi/hari,
  jam + durasi 60 menit + nama + kitab) + `khataman_saat_ini()`
  (sesi yang sedang berlangsung menurut jam perangkat, atau {}).

### `scripts/save_data.gd`
- `default_data()` tanpa kunci `"jalur"` (sistem satu jalur) +
  `"outfit"` default + `"khataman_hadir"` (dulu `"ngaji_hadir"`).
  Save lama yang masih punya "jalur"/"ngaji_hadir" tidak masalah
  (kunci itu tidak lagi dibaca).

### `scripts/pesantren_builder.gd`
- `GUNUNG`: 10 -> **2**, keduanya di SELATAN (sudut 160°/jarak 350/
  tinggi 70; sudut 200°/jarak 360/tinggi 85) supaya zona interior
  utara (z=-300) bersih. Sawah + 61 pohon tetap.
- `_plot()`: pagar lahan DIHAPUS (4 tiang sudut + tali + 4 dinding
  tak terlihat `_dinding` dihapus); yang tersisa alas pasir +
  papan ambang (tanda ambang 25/50/100/200 tetap).
- `_surau()`: `TandaKelasNahwu` DIHAPUS; **PlakatSurau** baru —
  bingkai emas (2.9×0.7×0.06) + papan hijau gelap (2.8×0.6×0.08)
  di (0, 3.85, -6.84/-6.81) + `label_arab("مصلى الإخلاص",
  (0,3.85,-6.74), 36, emas #f2c14e)`. Ejaan memakai hamzah
  (الإخلاص) — **DIKONFIRMASI Mas 22:55 WIB: "PAKAI HAMZAH",
  sudah benar, tanpa perubahan.** `SandalLuarSurau` (pasangan
  sandal tersembunyi di (0.8,0,-6.2)).
- `_dekor()`: `PapanSelamatDatang` DIHAPUS seluruhnya.
- `_markers()`: papan penanda misi (M1 di depan Surau + M2 di
  dalam interior) DIHAPUS — marker kini hanya ikon "!" + label
  status (TERKUNCI/SELESAI).
- `_cangkruk(root)` — **DESAIN ULANG 23:01 WIB (Mas: "ala POS
  RONDA tapi tertutup dan luas, ada kamar di dalam, isi 5 kasur
  dulu buat santri"):** cangkang luar kayu **10×8 m** tinggi 3.4 m
  (dulu 6×5 m / 3.0 m) pusat (14,0,-14); dinding penuh (tertutup);
  celah pintu 1.6 m selatan (x 13.2–14.8, **z=-10.0**); lis emas
  di atas pintu; **atap segitiga curam ala pos ronda** (2 lereng
  6.0 m sudut 0.27 rad, puncak y=4.8, bubungan) + overhang 0.8 m;
  **6 jendela** (2 timur + 2 barat + 2 mengapit pintu selatan);
  lampu hangat; label **"KAMAR CANGKRUK" SATU BARIS** di ambang
  pintu (font 20, y=2.9, z=-9.85 — lebar ~1.4 m, pas di ambang
  1.6 m); `SandalLuarCangkruk` (tersembunyi di (15.4,0,-9.3)).
  Konstanta: `CANGKRUK_POS (14,-14)`,
  `CANGKRUK_DOOR (14,0,-10.0)`, `CANGKRUK_EXIT (14,0,-8.5)`.
  `build()` mengembalikan `cangkruk_door/cangkruk_exit/cangkruk_pos`.

### `scripts/interior_surau.gd`
- `_papan_jadwal()` + pemanggilannya DIHAPUS (jadwal Ngaji Aja
  pindah ke dashboard sebagai jadwal khataman). Interior kini
  TANPA papan sama sekali — tersisa smartboard, mihrab, sajadah,
  rak kitab, meja sampar, lampu hangat. Label "KELUAR" di atas
  pintu dipertahankan (teks penunjuk, bukan papan).

### `scripts/interior_cangkruk.gd` (BARU, desain ulang 23:01 WIB)
- `InteriorCangkruk.build() -> Dictionary` (interface sama seperti
  `InteriorSurau.build()`): kamar kayu **14×10 m tinggi 3.6 m**
  (dulu 8×6 m / 3.2 m) pusat (-60,0,-300); dinding selatan
  **z=-295** dengan celah pintu 1.6 m (|x+60|<0.8, ambang 2.2 m);
  `interior_door (-60,0,-295)`, `interior_spawn (-60,0,-296.5)`,
  **`bed_pos_list` (5 posisi)** — `bed_pos` tunggal DIHAPUS,
  `lemari_spot (-54.6,0,-296.8)`, `cangkruk_bounds`
  (min_x -67, max_x -53, min_z -305, max_z -295).
- **5 kasur** (nama unik `TempatTidur1..5`, kepala di utara):
  barat-utara (-66,-303.3), barat-selatan (-66,-300.3),
  timur-utara (-54,-303.3), timur-selatan (-54,-300.3),
  utara-tengah (-60,-303.7) — berjajar rapi, **jalan 3 m di
  tengah** dari pintu ke kasur utara.
- Isi: lemari pakaian dinding timur dekat pintu (2 pintu + kenop
  emas + cermin kecil), meja kecil + lampu meja + kitab (dinding
  barat dekat pintu), karpet merah di jalan tengah, 1 lampu hangat
  gantung (grup LampuCahaya, jangkauan 10 m), label "KELUAR" di
  atas pintu. TIDAK ADA papan.

### `scripts/main.gd`
- **Sistem satu jalur (22:17 WIB):** `_on_login(id, nama)` /
  `_on_register(nama)` tanpa argumen jalur; semua cabang
  "jalur Ngaji Aja" dihapus (`_refresh_markers`,
  `_misi_terdekat`, `_on_interact`, `_update_hud`); sinyal
  `khataman_joined` + `_on_khataman_joined()` + dashboard memakai
  `khataman_hadir`.
- **Double Surau (perbaikan):** `_interior_root` +
  `_cangkruk_root` disimpan; keduanya `visible=false` di `_ready`
  dan hanya ditampilkan saat pemain masuk ruangan
  (`_set_interior_terlihat(surau, cangkruk)`) — penyebab duplikat:
  ruangan interior 18×14 m di z=-300 berdiri di lapangan luar dan
  terlihat dari spawn sebagai bangunan putih kedua. Reset
  (`_respawn_ke_spawn`) juga menyembunyikan kedua interior.
- **Pintu cangkruk (diperbarui 23:01 WIB):** `_cek_pintu_cangkruk()`
  (koridor luar |x-14|<0.8, **z (-11.5,-10.0)**; koridor dalam
  |x+60|<0.8, **z (-295,-293.5)**) + `_masuk_cangkruk()`/
  `_keluar_cangkruk()` (teleport + toast).
- **Sandal otomatis:** `_set_sandal_ruangan(masuk)` — masuk
  ruangan: `set_sandal(false)` + tampilkan pasangan
  `SandalLuar*` di depan pintu yang dimasuki; keluar:
  `set_sandal(true)` + sembunyikan keduanya.
- **Aksi:** `_on_aksi(nama)` — salaman menghadap NPC terdekat
  (<=6 m); **tidur di kasur MANA SAJA (23:01 WIB):**
  `_dekat_tempat_tidur()` memeriksa jarak ke 5 kasur,
  `_kasur_terdekat()` memilih yang paling dekat, snap ke kasur
  itu + (0,0,0.15); kalau bukan di cangkruk/dekat kasur -> toast;
  bawa_kitab -> toast nyala/mati. `_npc_terdekat(jarak)`.
- **Outfit:** `_on_outfit_dipilih(jenis, hex)` — update
  `_save["outfit"]` + `SantriSave.save_data` +
  `_player.terapkan_outfit` + `_ui.set_outfit_terpilih`.
- **Lainnya:** `_teleport_player` mengembalikan pose berdiri
  setiap teleport; `_process` menolkan input gerak saat
  `sedang_aksi_diam()`; `_masuk_pesantren` menerapkan outfit
  tersimpan + sandal dipakai; `_update_interact_button`
  (prioritas: pintu Surau -> pintu cangkruk -> lemari GANTI BAJU
  -> tempat tidur TIDUR -> misi -> smartboard); `_data_peta()`
  menambahkan `"cangkruk"`.

## Verifikasi

- `--import` exit 0.
- `--check-only`: 12/12 script OK (interior_cangkruk, interior_surau,
  langit_dinamis, main, mission_data, npc, palette,
  pesantren_builder, player, save_data, ui, virtual_joystick).
- `test_ronde6.gd` (SceneTree, headless): **130 lulus, 0 gagal,
  exit 0** — font (variation_opentype wght 600/700, Amiri,
  default_font terdaftar), gunung 2 selatan, MAP_HALF 400,
  4 lahan tanpa pagar + 4 papan ambang, interior tanpa papan,
  plakat Arab (Amiri, lebar <= 2.8 m), 1 node Surau + interior
  tersembunyi di luar, karakter (rambut hitam, sarung bawah
  y=0.10, **yoke bahu skala x 1.35, bola bahu r=0.115, lengan
  meruncing 0.105>0.085=0.085>0.062, bola siku, siku LURUS 0.0,
  tangan bola pipih**, sandal on/off), **motif batik (tekstur
  256×128, >=4 warna unik, ada titik emas, sarung biru juga
  batik)**, 7 pose (duduk/menulis/salaman/melambai/**tidur y 0.58
  di atas kasur**/bawa_kitab/berdiri), bubble (font 22, lebar 240,
  potong <=103 + "…", pendek utuh, NPC juga), **cangkruk pos ronda
  (interior 14×10, 5 kasur, label 1 baris, pintu (14,0,-10.0) /
  (-60,0,-295), masuk/keluar lewat pintu fisik + sandal, tidur
  snap ke kasur TERDEKAT — barat-selatan DAN timur-utara)**,
  outfit (recolor langsung + save/load + **tanda ✓ muncul**),
  sistem satu jalur (form tanpa OptionButton, sinyal 2/1 argumen,
  KHATAMAN_JADWAL 3 sesi, NGAJI_JADWAL hilang, save tanpa
  "jalur", dashboard Khataman tanpa "Ngaji Aja"/"Jalur:", hadir
  khataman tercatat).
  - Dua kegagalan tes yang ditemukan dan diperbaiki SELAMA tes:
    (1) `get_script_constant_map()` tidak bisa dipanggil di kelas
    — pakai `load(...).get_script_constant_map()`; (2) path scene
    utama `res://main.tscn` (bukan `scenes/main.tscn`).
  - Tes sempat menemukan bug project.godot `#` di atas (sudah
    diperbaiki — bukan kegagalan tes, tapi temuan tes).
- Smoke: test headless + 3 run foto xvfb (~10 menit rendering,
  ratusan frame) — 0 script error.
- **Export: exit 0. pck 976.240 byte
  (sha256 c85116fbd8582596cc7af1ae6d4f5749316b5e7a02c9e1feb9ce92
  89591ba35f) — membesar dari 158.132 byte ronde 5 karena font
  ter-bundle (Baloo 2 + Amiri, terverifikasi ada di dalam pck
  via `strings`); wasm + index.js TIDAK berubah; worklet ada
  (2.973 byte).**

## Foto bukti

`~/workspace/pesantren-verse/foto-ronde6/` (29 foto, 960×540,
xvfb-run + opengl3, software render). Catatan umum: jam VM adalah
UTC (bukan WIB), jadi langit dinamis di foto menunjukkan fase SORE
(golden hour, ~15:40 UTC) — di HP Mas jam 22:40 WIB fasenya MALAM.
Toast ("Selamat datang…", "Kamu masuk ke dalam Surau…") terlihat
di beberapa foto — itu fitur game yang bekerja, bukan cacat; toast
tampil 2,5 detik saat masuk ruangan/login. Perbaikan arah kamera
skrip foto: `set_facing(PI)` = menghadap utara; kamera ada di
rig + forward×spring — `_cam_yaw=PI` = kamera di utara (tampak
depan), `_cam_yaw=0` = kamera di selatan (tampak belakang/punggung).

Daftar (semua sudah dilihat dan diverifikasi satu per satu):
- `01-login-tanpa-jalur.png` — form login 2 field (ID + nama),
  tanpa pilihan jalur, font Baloo.
- `02-gunung-dua.png` — 2 gunung di selatan (kerucut hijau +
  abu bersalju), sawah + pohon tetap.
- `03-plot-tanpa-pagar.png` — lahan Ruang Kelas: alas pasir +
  papan ambang 25 santri, TANPA pagar.
- `04-interior-tanpa-papan.png` — interior Surau tanpa papan:
  sajadah + rak kitab + meja sampar + smartboard.
- `05-aksi-duduk.png` — duduk bersila dari depan, terbaca.
- `06-aksi-salaman.png` — (retake) lengan kanan terulur ke
  depan, pose salaman terbaca.
- `07-aksi-menulis.png` — duduk + tangan kanan ke depan di atas
  kitab pangkuan (kitab kurang jelas di foto — warnanya mirip
  sarung; lihat "Penilaian jujur").
- `08-aksi-bawa-kitab.png` — kitab hijau kecil di tangan kanan
  saat berdiri.
- `09-aksi-melambai.png` — (retake) lengan kanan terangkat
  tinggi, melambai terbaca.
- `10-aksi-tidur.png` — (retake) pemain berbaring DI ATAS kasur
  B2 (kepala di bantal, badan di atas matras — perbaikan y=0.58
  terbukti); kasur B4 kosong terlihat di sebelah.
- `11-aksi-berdiri.png` — berdiri normal.
- `12-plakat-arab.png` — (retake) plakat مصلى الإخلاص emas di
  atas pintu Surau, terbaca jelas, pemain di samping pintu.
- `13-rambut-closeup.png` — rambut hitam terlihat di sisi kepala
  di bawah songkok putih.
- `14-lengan-depan.png` — (baru, desain ulang) bahu lebar
  menyatu (yoke), lengan meruncing lurus tanpa sendi terlihat,
  tangan membulat; dari depan terbaca sebagai bagian badan.
- `15-lengan-samping.png` — (baru) profil: lengan kanan satu
  bentuk meruncing mulus bahu->tangan, tanpa patahan sudut;
  NPC Faris di latar (sarung batik coklat).
- `16-lengan-belakang.png` — (baru) punggung: massa bahu lebar
  + lengan lurus meruncing; rambut belakang + sarung batik
  terlihat.
- `17-bubble-pendek.png` — bubble kecil "Assalamu'alaikum!" di
  atas kepala, tidak menutupi layar.
- `18-bubble-panjang.png` — bubble chat panjang (3 kalimat)
  compact, multi-baris kecil di atas kepala, terpotong rapi.
- `19-cangkruk-luar.png` — (baru, pos ronda) bangunan kayu
  10×8 m atap segitiga curam, 2 jendela mengapit pintu, label
  "KAMAR CANGKRUK" SATU BARIS bersih di atas pintu (tidak ada
  lagi teks bertumpuk — bubble sudah disembunyikan skrip foto).
- `20-cangkruk-dalam.png` — (retake v3, FOV 95) interior 14×10 m:
  **ke-5 kasur terlihat dalam satu frame** (2 barat + 1 tengah
  utara + 2 timur), karpet merah di jalan tengah, lampu gantung
  hangat menyala, pemain berdiri di tengah (sarung batik).
- `21-outfit-panel.png` — (retake) panel GANTI BAJU: tanda "✓"
  kini muncul di Putih / Putih / Zamrud (bug hex diperbaiki).
- `22-outfit-var1-hitam-biru.png` — variasi: songkok hitam +
  sarung biru batik, langsung terlihat di karakter.
- `23-outfit-var2-krem-coklat.png` — variasi: koko krem +
  sarung coklat batik.
- `24-hud-font-baru.png` — HUD dari belakang pemain: tombol
  Kartu Santri/Peta/Chat/Aksi + minimap + joystick, semua font
  Baloo; Surau + cangkruk + peti + marker TERKUNCI terlihat.
- `25-surau-tunggal-depan.png` — SATU Surau dari depan (kubah
  emas + plakat), cangkruk di kanan, NPC Bilal di kiri.
- `26-surau-tunggal-timur.png` — SATU Surau dari timur (putih di
  belakang cangkruk coklat).
- `27-dashboard-khataman.png` — Kartu Santri: ID PV-0001, Tier,
  Poin, Misi 0/3, Ma'hadiyah checklist (bagian Khataman ada di
  bawah scroll — dibuktikan tes logika, bukan foto ini).
- `31-batik-zamrud.png` — (baru) close-up sarung: motif batik
  parang JELAS (pita diagonal zamrud + titik emas), bukan
  kotak-kotak lagi; lis emas di hem.
- `32-batik-biru.png` — (baru) variasi warna: motif batik yang
  sama dalam warna biru (pita biru + titik emas).

## Penilaian jujur / yang belum sempurna

- **Font default baru aktif sekarang.** Sejak ronde 6 (font
  ditambahkan) sampai tes ini, UI memakai font fallback karena
  bug `#` di project.godot. Setelah perbaikan, Baloo 2 SemiBold
  baru benar-benar tampil — tampilannya di HP Mas belum terlihat;
  foto software render di bawah hanya bukti kasar.
- **Verifikasi visual terbatas pada software render.** Seperti
  ronde 4/5, tampilan di browser sungguhan + HP Mas (terutama
  plakat Arab, font Baloo di HUD, pose dari kamera third-person,
  panel ganti baju, dan lengan baru) belum teruji — butuh retest
  browser build ronde 6 + tes HP Mas. **Penilaian Mas atas lengan
  baru dari foto software render adalah penentunya** — di kode
  bentuknya sudah satu alur meruncing tanpa sendi, tapi kalau di
  mata Mas masih balok, yang tersisa hanya model impor / sculpt.
- **Label nama putih tanpa outline sulit dibaca saat latarnya
  terang** (foto 06: "Tes" hampir hilang saat menimpa papan
  putih / langit cerah). Itu keputusan ronde 5 Mas ("tanpa
  outline, kaya game bola") — TIDAK diubah sepihak. Kalau Mas
  mau, tambahkan bayangan gelap halus di bawah teks (seperti
  FIFA) tanpa mengembalikan outline tebal.
- **Diagnosis label bertumpuk di foto 19/20 lama:** BUKAN label
  "KAMAR CANGKRUK" yang ganda (label itu satu baris bersih) —
  melainkan **bubble chat panjang dari shot sebelumnya** (tahap
  18) yang masih tampil 5 detik dan menimpa label di atas kepala
  pemain. Skrip foto baru menyembunyikan bubble di reset; foto
  19 baru membuktikan labelnya bersih. Di game sungguhan, bubble
  yang tampil saat pemain berdiri di depan pintu memang akan
  menutupi label sebentar (normal — bubble lebih dekat ke kamera),
  lalu hilang setelah 5 detik.
- **Kitab pangkuan (menulis) kurang jelas di foto 07** — sampul
  zamrudnya mirip warna sarung sehingga menyatu. Logika benar
  (kitab terlihat + tangan ke depan, lolos tes); secara visual
  bedanya dengan pose duduk tipis di foto diam.
- **Foto interior 5 kasur memakai FOV 95** (dari 60) supaya
  kelimanya masuk frame dari dalam ruangan 14×10 m — sudutnya
  agak wide-angle, bukan tampilan game normal (FOV 60). Isi
  ruangan dan posisi kasur tetap apa adanya.
- **Dashboard foto 27 tidak menampilkan seksi Khataman** (ada di
  bawah scroll) — keberadaannya dibuktikan tes logika, bukan foto.
- **Keyboard + form di HP beneran belum teruji** untuk form login
  baru (2 field) — sama seperti catatan ronde sebelumnya.
- **Joystick/tombol HUD di HP portrait** masih koordinat tetap —
  perbaikan terpisah yang sudah dicatat sebelumnya.
- **Tidur hanya bisa di kamar cangkruk** (sengaja — sesuai
  perintah); tidur di luar cangkruk menampilkan toast penolakan.
- **Salaman** menghadap NPC terdekat hanya bila NPC dalam 6 m;
  kalau tidak ada NPC, pose tetap dilakukan menghadap arah kini.
- **NPC (Bilal, Faris) belum memakai pose aksi** — prioritas
  pemain dulu sesuai perintah; NPC hanya memakai karakter baru
  (rambut/sarung batik/lengan) + bubble kecil.
- **Khataman "sedang berlangsung"** memakai jam perangkat
  (Time.get_datetime_dict_from_system) — sama seperti langit
  dinamis; kalau jam perangkat salah, penandanya ikut salah.

## File tes (HAPUS sebelum export)

- `test_ronde6.gd` (tes logika, 130 cek) — **DIHAPUS sebelum
  export** (bersama `test_font_load.gd`, `test_font_api.gd`,
  `foto_ronde6.gd`, `foto_retake.gd`, `foto_baru.gd`,
  `foto_retake2.gd`, `foto_retake3.gd`). `probe_font.gd`,
  `probe_font2.gd` sudah dihapus sebelumnya. Tidak ada file tes
  tersisa di proyek (dicek `ls *.gd` — kosong).
