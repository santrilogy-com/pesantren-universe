# RONDE 7 — STATUS (16 Nov 2026, Raka)

Perintah: perbaikan 8 temuan retest browser build ronde 6 (deployment `8c7f05de`, live).
Retest 01:30 WIB: 5 LOLOS (jangan diutak-atik), 3 GAGAL, 1 tidak teruji.
**TIDAK deploy (Damar).** Export siap di `export/web/`.

## Ringkas per item

| # | Temuan retest | Akar masalah | Perbaikan | Bukti |
|---|---|---|---|---|
| 1 | Panel Aksi tidak berfungsi (KRITIS) | **Artefak tes, bukan bug game** (lihat §1) + pose kurang kentara | Toast tiap pose; duduk lebih dalam; salaman/melambai 5 dtk | Klik nyata headless + foto 01/02 |
| 2 | Kamera tidur masuk dinding (KRITIS) | Spring 7 m + pitch −0,35 → kamera y≈4,0 DI ATAS plafon 3,6 m; plafon tanpa collision | Spring 4 m luar → 3 m tidur; plafon jadi collision; kepala di bantal | Tes 31/31 + foto 03 |
| 3 | Panel Ganti Baju tidak ditemukan (TINGGI) | Jalur lemari bekerja, tapi tidak ada yang menemukannya | Tombol "Ganti Baju" di footer dashboard | Foto 04/05/05b + tes |
| 4 | Kasur ke-5 tidak terlihat | Ada (5 kasur), penguji melewatkannya | Tanpa perubahan kode — bukti foto | Foto 06 (5 kasur terhitung) |
| 5 | Label "TERKUNCI" menempel di dinding cangkruk | Label y=2,9 di peti (6,0,10) sejajar dinding cangkruk dari spawn | Label status turun ke y=1,6 | Foto 07 |
| 6 | Peta: legenda ▯, "GERBANG" terpotong, label menumpuk saat zoom | Glif tidak ada di Baloo 2; label di tepi bawah; tanpa de-collision | Legenda swatch warna; GERBANG ke dalam; de-collision label | Foto 08/09 + tes |
| 7 | Kartu Santri: Khataman 18:30 terpotong; "Subuh berjamaah" putih saat hover | Tanpa spacer bawah; CheckButton hover putih bawaan | Spacer 20 px; warna hover = GELAP | Foto 10 + tes |
| 8 | Bubble sendiri tertutup panel chat | Bubble di y=2,45 tepat di area panel | Bubble sendiri disembunyikan saat panel chat terbuka | Foto 11 + tes |

## §1 — Panel Aksi: reproduksi pertama adalah ARTEFAK TES, bukan bug game

- Dugaan awal (sinyal tidak tersambung / `_process` me-reset pose) **tidak terbukti**:
  sinyal `aksi_dipilih` tersambung di `main.gd` baris 142; `_process` tidak
  menyentuh pose; `_terapkan_pose` hanya dipanggil dari `set_aksi`.
- Yang ditemukan: viewport headless 64×64, visible rect 1280×1280 — viewport
  mengalikan posisi event yang di-dispatch dengan 20 (1280/64). Klik yang
  dikirim di koordinat canvas (640,152) tiba di `_unhandled_input` sebagai
  (12800,3040), di luar panel → handler klik-di-luar menutup panel dan tombol
  tidak pernah mendapat press. Terbukti dengan trace print sementara di `ui.gd`
  (sudah dihapus; `ui.gd` dikembalikan dari backup).
- **Perbaikan untuk tes**: kirim klik dalam koordinat WINDOW (canvas ×
  window/visible). Dengan koordinat yang benar, jalur klik penuh bekerja
  headless (aksi jadi "duduk", panel menutup, toast tampil, pose bertahan
  90 frame, visual y=−0,50, rotasi kaki −1,34).
- **Penyebab asli di browser sungguhan tetap tidak terbukti dari pembacaan
  kode** (jalur tombol/sinyal/pose identik strukturnya dengan tombol login/chat
  yang terbukti bekerja). Dugaan paling masuk akal: salaman/melambai auto-reset
  3 dtk terlalu singkat untuk diamati, dan pose duduk dari belakang kurang
  kentara (badan hanya turun, kaki melipat di dalam sarung).
- Mitigasi yang diterapkan: (a) **toast konfirmasi untuk SETIAP pose** di
  `main.gd _on_aksi` ("Duduk bersila.", "Salaman.", dst.); (b) pose duduk
  diperjelas di `player.gd _terapkan_pose` (turun −0,45→−0,50, condong
  0,05→0,12, lengan merentang z ±0,25 ke lutut); (c) auto-reset
  salaman/melambai 3,0→**5,0 dtk** di `set_aksi`; (d) helper baru
  `ui.gd is_toast_visible()`.
- **Pembuktian di browser sungguhan untuk item 1–3 tetap menunggu retest
  parent setelah deploy** — Chromium VM tidak bisa start sama sekali
  ("Hatch WebGL domain policy is required for browser startup", exit 2/13;
  terverifikasi 02:00 WIB). Jangan klaim item 1 terbukti di browser sebelum
  retest itu ada.

## §2 — Kamera tidur: akar masalah terukur

- Sebelum perbaikan (headless): kamera y=4,02, spring=7,0 saat tidur.
  Pitch −0,35 dari rig y=1,6 → kamera y = 1,6 + 7·sin(0,35) ≈ 4,0 — di ATAS
  plafon cangkruk (3,6 m). Plafon hanya visual (`Palette.box`, tanpa
  collision) sehingga SpringArm tidak pernah mengerut — kamera keluar ruangan
  dan melihat plafon dari atas (layar cokelat).
- Perbaikan: (a) di `main.gd _process`, spring **4,0 m di dalam ruangan**
  (7,0 m di luar), **3,0 m saat tidur** (revisi akhir ronde — kasur mengisi
  frame, plafon tidak mendominasi); target rig turun ke 0,9 m saat tidur
  (dari 1,6); (b) **collision plafon ditambahkan** di
  `interior_cangkruk.gd` dan `interior_surau.gd` (plafon kini `_static_box`,
  bukan visual saja) sebagai pengaman pitch curam.
- Hasil ukur: kamera tidur y=1,95 (spring 3,0); pitch curam −1,0 → y=3,44
  (di bawah plafon 3,595 — margin tipis 0,15 m, dicatat jujur).
- **Koreksi dari foto**: foto tidur pertama menunjukkan kepala di SELATAN
  (dekat kamera) dan kaki di bantal — terbalik. Penyebab: pose tidur memutar
  visual −1,5 rad; dengan hadap utara (yaw PI, arah masuk cangkruk) kepala
  jatuh ke selatan. Perbaikan: `_on_aksi("tidur")` kini memanggil
  `_player.set_facing(0.0)` (hadap selatan) sebelum snap, supaya kepala jatuh
  ke UTARA, di atas bantal. Tes baru: `basis.y.z < −0,9` (hasil −1,0).
- Foto 03 (retake): karakter berbaring di kasur, kepala di bantal utara,
  sarung batik + selimut hijau terlihat, toast "Selamat tidur, santri.".
- Catatan: saat pemain berdiri tepat di celah pintu, sinar spring menembus
  celah (tanpa collision) dan kamera bisa jatuh ke luar ruangan — perilaku
  transien saat melintas pintu, bukan bug tidur; tidak diperbaiki ronde ini.

## §3 — Ganti Baju: dua jalur

- Jalur lemari **terverifikasi bekerja** (headless: `_dekat_lemari()` true +
  `_on_interact()` membuka panel) — kegagalan retest murni discoverability.
- Jalur baru: sinyal `ui.gd ganti_baju_requested` + handler
  `main.gd _on_ganti_baju_requested()` (tutup dashboard, buka panel outfit
  dengan outfit saat ini). Tombol di **footer dashboard** (HBox "Ganti Baju"
  + "Tutup", di luar ScrollContainer, selalu terlihat). Percobaan pertama
  menaruhnya di dalam konten scroll — tidak terjangkau tanpa scroll, klik
  mendarat di handler klik-di-luar (tertangkap tes); dipindah ke footer.
- Foto 04 (tombol "Ganti Baju" di footer dashboard), foto 05 (panel terbuka,
  sarung "✓ Biru" terpilih), foto 05b (karakter dari depan, sarung biru batik
  terlihat jelas). Tes: warna material sarung berubah ke `#1d4e6b`.

## §4 — Kasur ke-5: tidak ada perubahan kode

- `BED_POS_LIST`: barat (−66,−303,3)/(−66,−300,3), timur (−54,−303,3)/
  (−54,−300,3), utara-tengah (−60,−303,7) — 5 kasur memang ada; penguji
  kemungkinan melewatkan yang utara-tengah (posisinya di tengah, sering
  tertutup karakter).
- Foto 06 (retake dari tengah ruangan, FOV 95): kelima kasur terhitung —
  barat 2, timur 2, utara-tengah 1 (sebagian di belakang karakter).
- Pelajaran foto: jangan posisikan pemain di pintu saat memotret interior —
  kamera jatuh keluar (lihat §2 catatan).

## §5 — Label "TERKUNCI": turun ke y=1,6

- Akar: label status misi M3 di peti (6,0,10) pada y=2,9; dari spawn, proyeksinya
  jatuh tepat di rentang dinding depan cangkruk (azimuth ~24–29°) — terbaca
  seolah cangkruk terkunci.
- Perbaikan: di `pesantren_builder.gd _markers`, label status misi turun
  y 2,9→**1,6** (ikon "!" tetap di 2,9).
- Foto 07: "TERKUNCI" kini rendah, tepat di atas peti kayu, jelas lepas dari
  dinding cangkruk.

## §6 — Peta: tiga perbaikan

- (a) Legenda dibangun ulang sebagai GridContainer 3 kolom berisi swatch
  warna (ColorRect 16×16) + teks polos — **tanpa glif khusus** (● ■ ▢ ◆ ▨ ▲
  dihapus; tidak ada di Baloo 2, tampil sebagai tofu ▯).
- (b) Label "GERBANG" dipindah ke `half − 16` (dari `half − 2`) — muat di
  dalam rect peta.
- (c) De-collision label di `PetaControl._teks`: setiap rect label dicatat di
  `_label_rects` (dibersihkan tiap `_draw`); label yang bertabrakan digeser
  ke bawah (size+4) sampai 6 kali.
- Foto 08 (legenda swatch + teks, GERBANG utuh), foto 09 (zoom 4x: 9 label,
  0 tumpang tindih antar-label menurut tes). Jujur: di zoom 4x klaster sekitar
  pemain tetap padat (5 POI dalam 20 m) dan label duduk di atas rect lahan —
  tapi masing-masing terbaca di barisnya sendiri, tidak lagi menumpuk.

## §7 — Kartu Santri: spacer + hover

- (a) Spacer 20 px di akhir `_dash_content` di `open_dashboard` — baris
  Khataman 18:30 kini tampil utuh saat scroll ke bawah (foto 10).
- (b) CheckButtons Ma'hadiyah kini override `font_hover_color` /
  `font_pressed_color` / `font_focus_color` = GELAP (sebelumnya putih bawaan
  di atas krem saat hover).
- Catatan foto 10: tombol "Hadir hari ini" tampak abu-abu — itu BENAR, bukan
  bug: kehadiran hari ini sudah tercatat di save persisten VM (sekali per
  hari); tombol disabled saat `khataman_hadir` sudah berisi tanggal hari ini.

## §8 — Chat: bubble ditahan

- `player.gd set_bubble_ditahan(bool)` + flag `_bubble_ditahan` — bubble
  sendiri disembunyikan saat panel chat terbuka (pesan sudah ada di log chat);
  bubble NPC tidak terpengaruh; timer bubble tetap berjalan saat ditahan;
  `main.gd _process` memanggilnya tiap frame dari `_ui.is_chat_visible()`;
  `show_chat` menghormati flag.
- Foto 11: panel chat terbuka dengan pesan di log; tidak ada bubble di atas
  karakter.

## Perubahan kode (file)

- `scripts/main.gd` — toast tiap pose; spring 4,0 dalam ruangan / 3,0 tidur;
  rig tidur 0,9; `_on_ganti_baju_requested`; `set_facing(0.0)` saat tidur;
  `set_bubble_ditahan` tiap frame.
- `scripts/ui.gd` — sinyal `ganti_baju_requested`; tombol "Ganti Baju" di
  footer dashboard; spacer 20 px; warna hover CheckButton; helper
  `is_toast_visible()`.
- `scripts/player.gd` — duduk lebih dalam + lengan merentang; salaman/
  melambai 5,0 dtk; `set_bubble_ditahan`.
- `scripts/pesantren_builder.gd` — label status misi y 2,9→1,6.
- `scripts/interior_cangkruk.gd`, `scripts/interior_surau.gd` — collision
  plafon (`_static_box`).
- `scripts/peta.gd` — legenda swatch; GERBANG `half − 16`; de-collision label
  (`_label_rects`).

## Verifikasi

- `--import` exit 0; `--check-only` **12/12 script** OK.
- **test_ronde7.gd: 31/31 LOLOS, 0 gagal** (bertambah 1 cek: kepala tidur ke
  utara, up.z=−1,0) — termasuk klik mouse NYATA via `Input.parse_input_event`
  dalam koordinat window (aksi jadi "duduk", panel menutup, toast tampil,
  pose bertahan 90 frame, visual y=−0,50, rotasi kaki −1,34); kamera tidur
  y=1,95 (spring 3,0), y=3,44 di pitch −1,0; lemari + tombol footer dashboard
  membuka panel outfit; label M3 y=1,6; legenda tanpa glif tofu; spacer 20 px
  + hover tidak putih; bubble ditahan saat chat terbuka, kembali saat ditutup;
  zoom peta 4x: 9 label, 0 tumpang tindih.
- Smoke headless **600 frame, 0 script error**.
- **12 foto bukti** di `~/workspace/pesantren-verse/foto-ronde7/` (960×540,
  xvfb-run + opengl3, fase malam — jam VM UTC ~19:00 = Malam): 01-aksi-duduk,
  02-aksi-salaman, 03-tidur-kasur (retake: kepala di bantal), 04-dashboard-
  ganti-baju, 05-ganti-baju-sarung-biru, 05b-sarung-biru-karakter, 06-kasur-lima
  (retake dari tengah ruangan), 07-label-terkunci, 08-peta-legenda,
  09-peta-zoom-4x, 10-dashboard-khataman, 11-chat-bubble-ditahan. Semua
  ditinjau satu per satu.
- **Pelajaran skrip foto**: versi pertama `foto_ronde7.gd` async (await 2
  frame sebelum save) — capture terjadi 2 frame SETELAH state berubah, foto
  01 malah menampilkan "Berdiri.". Ditulis ulang sinkron (capture di frame
  yang sama) + refresh aksi/toast sebelum tiap foto. Skrip foto khusus:
  `foto_chat7.gd`, `foto_tidur7.gd`, `foto_kasur7.gd`, `foto_sarung7.gd`.
- Semua skrip tes/foto **dihapus sebelum export** (`ls *.gd` di root proyek =
  0; file `.uid` ronde 7 ikut dibersihkan).
- Export `export/web/`: pck BARU **978.512 byte** sha256
  `9cf7c26ad23cf2d88dbf9b90fc4f6dd820f48d1468eb3d3a7c80572659fa873b`
  (tumbuh 2.272 byte dari ronde 6); wasm TIDAK berubah sha256
  `fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0`;
  index.js TIDAK berubah sha256 `33c94cb3…`; worklet ada (2.973 byte).
  Guard tag script berlaku di staging deploy (Damar), bukan di export mentah
  (export mentah 2/2 — patch fetch wasm ditambahkan di staging).

## Belum sempurna / jujur

- **Bukti browser sungguhan untuk item 1–3 belum ada** — Chromium VM tidak
  bisa start; perlu retest parent setelah deploy. Yang ada: klik nyata
  headless (koordinat window) + foto xvfb + pembacaan kode. Jangan klaim
  item 1 terbukti di browser sebelum retest.
- Margin kamera tidur di pitch curam tipis: y=3,44 vs plafon 3,595 (0,15 m).
- Label dunia (bukan peta) masih bisa bertumpuk sesaat saat NPC berdiri
  dekat penanda misi (foto 02: "Faris" menimpa "TERKUNCI") — NPC bergerak,
  transien; bukan item retest.
- Portrait 390×844 masih belum teruji di browser — perlu HP Mas.
- Foto interior memakai FOV 95 (bukan FOV game 60) supaya 5 kasur masuk
  frame; foto 06 kasur timur-selatan terpotong sebagian di tepi frame.
- Pertanyaan ronde 6 untuk Mas masih terbuka: label nama putih tanpa outline
  sulit dibaca di latar terang — tetap, atau tambah bayangan halus ala FIFA?
