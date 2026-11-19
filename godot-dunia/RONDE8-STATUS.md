# RONDE 8 — STATUS (16 Nov 2026 ~04:35 WIB)

Perbaikan 8 temuan retest browser build ronde 7 (deployment ef4315d4).
Yang lolos di retest tidak diutak-atik.

## Verifikasi

- **Tes headless `test_ronde8.gd`: 51 lolos, 0 gagal** (EXIT 0, log akhir
  /tmp/test8e.log). `--import` 0; `--check-only` semua script OK.
- **Smoke headless 600 frame: 0 script error.**
- **Foto bukti: 8 foto** di `~/workspace/pesantren-verse/foto-ronde8/`
  (01–08 + 3 crop close-up), diambil di bawah xvfb-run + opengl3 960×540.
- **Export: `export/web/`** — pck 981.264 byte sha256
  `dca77670d5552dfd7db8ff743cad7d172a9e9f5ef281152e16c3242da96e1e16`
  (ronde 7: 978.512 byte `9cf7c26a…`); wasm TIDAK berubah
  `fc74679e…fa57d0` (39.514.754 byte); index.js TIDAK berubah `33c94cb3…`;
  worklet `index.audio.position.worklet.js` 2.973 byte ✓;
  index.html export mentah 2 `<script>` / 2 `</script>` seimbang (template
  Godot standar — guard 3/3 berlaku di STAGING `export/web-pages/`,
  tempat Damar menambah patch fetch wasm; bukan di export mentah).
- **TIDAK deploy (Damar).** Skrip tes + foto sudah dihapus dari proyek
  sebelum export (hanya `.uid` yatim ronde 4/6 yang tersisa dari ronde
  lalu, tidak mengganggu).

## Per item

### 1. Ganti Baju TIDAK mengubah karakter (KRITIS) — perbaikan defensif + bukti, retest browser MASIH DIBUTUHKAN
- **Akar masalah: TIDAK ditemukan bug di jalur sinyal (headless).**
  Rantai lengkap dites dengan klik sungguhan: dashboard terbuka (1a),
  panel outfit terbuka (1b), dict outfit sarung = #1d4e6b setelah klik
  Biru (1c), material sarung = material batik biru dari cache (1d),
  piksel tekstur BIRU rata-rata rgb=(0.30, 0.44, 0.51) (1e), ganti ke
  Coklat + tutup panel tetap coklat (1f). Sinyal tersambung,
  `terapkan_outfit` mewarnai node yang benar, hex benar.
- Hipotesis terbuka (belum terbukti): di pencahayaan malam (Subuh),
  biru gelap #1d4e6b terbaca sebagai zamrud di crop kecil — retest
  WAJIB cek di siang hari.
- **Perbaikan defensif (main.gd `_on_outfit_dipilih`):** visual
  `terapkan_outfit` dipanggil DULU, save sesudahnya (sebelumnya save
  dulu); + print diagnostik `[RONDE8] outfit_dipilih: %s=%s -> sarung=%s`
  supaya console retest browser membuktikan sinyal sampai ke main.gd.
- **Bukti:** foto 01 (karakter depan, sarung biru) + crop-03 (close-up:
  BIRU jelas, motif batik parang + titik emas, bukan hijau) + foto 08
  (sarung biru terlihat dari samping). Catatan: foto diambil ~04:17–
  04:30 WIB (Subuh, gelap) — bukti piksel + close-up sudah kuat, tapi
  screenshot siang hari di retest browser tetap bukti terbersih.

### 2. Panel chat memotong label nama (TINGGI) — LOLOS
- Akar: label nama adalah Label3D terpisah dari bubble; ronde 7 hanya
  menyembunyikan bubble.
- Fix: flag `_nama_ditahan` + `set_nama_ditahan()` di player.gd dan
  npc.gd (`_process` menyembunyikan label saat ditahan, digabung aturan
  jarak 28 m); main.gd `_process` menerapkan tiap frame dari
  `_ui.is_chat_visible()` (pemain + semua NPC).
- Bukti: tes 2a–2d (disembunyikan saat chat terbuka — pemain + NPC —
  muncul lagi setelah ditutup); foto 02 (panel chat terbuka, tombol X
  besar, TIDAK ADA label "Tes" di atas kepala; karakter utuh di bawah
  panel).

### 3. Bangun tidur: kamera terjepit bola hitam (TINGGI) — LOLOS
- Akar TERKONFIRMASI PERSIS: lampu gantung di tengah ruangan cangkruk
  (-60, 3.05, -300); kamera bangun dari kasur utara-tengah (-60,-303.7)
  dengan yaw 0 + spring 4 m jatuh di (-60, ~2.97, -299.8) = 0,22 m dari
  bola lampu; bola tanpa collision → SpringArm tidak mengerut. Saat
  tidur (spring 3 m) jarak 1,32 m — makanya tidur tampak normal.
- Fix: lampu cangkruk pindah ke sudut NW (-65.5,-303.5, di atas kasur
  barat-utara, jauh dari semua garis kamera bangun), dinaikkan (bola
  3.28), + StaticBody3D collision sphere r=0.28 di bola. 4 lampu Surau
  juga diberi collision r=0.28 (interior_surau.gd). Saat bangun, kamera
  di-snap (pitch reset -0.35, rig snap ke pemain+1,6 m, rotasi spring
  diset) supaya tidak menyapu lewat lampu.
- Sekalian: bangun bisa lewat tekan TIDUR lagi (toggle di `_on_aksi`)
  dan lewat gerak joystick/tombol W (input mentah ditangkap SEBELUM
  pose-tidur menolkan gerakan di `_process`, ambang 0.3).
- Bukti: tes 3a–3h (jarak kamera-lampu min 4,05 m dari SEMUA kasur;
  toggle + gerak membangunkan); foto 03 (bangun → tampilan normal,
  karakter utuh, tidak ada bola hitam; tombol TIDUR terlihat).

### 4. Salaman (SEDANG) — LOLOS
- Akar: pose hanya 5 detik (auto-reset `_aksi_timer`), penguji mengecek
  ~20 detik kemudian → lengan sudah turun.
- Fix: salaman/melambai `_aksi_timer = 0.0` — pose TAHAN sampai pemain
  bergerak atau tekan Berdiri (player.gd).
- Bukti: tes 4a–4c (arm_r.x=-1.43, bertahan setelah 10 detik, W
  mengakhiri → berdiri); foto 08 (profil samping: lengan kanan terulur
  horizontal ke depan, jelas; foto 04 dari depan kurang jelas karena
  lengan mengarah ke kamera — foreshortening).

### 5. Peta (SEDANG) — LOLOS
- (a) GERBANG: akar — saat zoom, peta berpusat pada pemain; GERBANG
  (384 m jauhnya) jatuh di luar layar sehingga HILANG; jepit pertama
  salah hitung (rect meleset 3 px di bawah tepi). Fix: `_teks` param
  `jepit_tepi` — clamp dihitung dari RECT label (p.y-9 s.d. p.y+7),
  bukan titik tengah; `_rect_gerbang` direkam untuk tes.
- (b) Zoom: `PETA_ZOOM = [1.0, 2.0, 4.0]` (2.0x dikembalikan — dulu
  dihapus ronde 5 karena label menumpuk; de-collision ronde 7 kini
  menanganinya) + tombol dinonaktifkan di ujung + label tingkat
  ("1.0x"/"2.0x"/"4.0x") via `_perbarui_tombol_zoom()`.
- (c) Marker menutupi label: rect marker pemain (24×24) + tujuan misi
  (26×26) dicadangkan di `_label_hindari` SEBELUM label digambar
  (dipisah dari `_label_rects` supaya tes tumpang-tindih tidak salah
  menuduh saat pemain berdiri tepat di atas tujuan). `_teks` kini
  mengembalikan Rect2.
- Bukti: tes 5a–5h lolos di zoom 1.0x/2.0x/4.0x (0 tumpang-tindih,
  GERBANG dalam batas, tidak ada label menabrak marker pemain);
  foto 05 (2.0x: GERBANG utuh di tepi bawah, label "2.0x") + foto 06
  (4.0x: GERBANG utuh, tombol + abu-abu/nonaktif, "RUANG KELAS (25)"
  utuh tidak tertutup titik hijau pemain).

### 6. Kartu Santri scroll (SEDANG) — LOLOS
- Akar TERUKUR (tes fokus /tmp/tes_seret.gd): drag mulai di atas
  **CheckButton** → scroll tetap 0; dari **Label** → menggulir ke 199.
  CheckButton (mouse_filter STOP) memakan press sehingga
  ScrollContainer tidak pernah melihat awal seretan. Baris checklist
  Ma'hadiyah (660×35) menutupi hampir semua area scroll — persis
  keluhan retester "hanya roda mouse, bukan seret".
- Fix: tiap CheckButton Ma'hadiyah `gui_input` → `_on_dash_item_seret`
  (teruskan MouseMotion kiri-ditekan + ScreenDrag ke
  `_dash_scroll.scroll_vertical -= relative.y`); klik biasa tanpa gerak
  tetap menandai checklist. `_dash_scroll` disimpan di
  `_build_dashboard_panel`.
- Bukti: tes 6a–6g (6g: seret dari baris checklist 0→240; 6f: mencapai
  bawah — ekspektasi diperbaiki: batas capai = max_value - page, bukan
  max_value); foto 07 (dashboard digulir ke bawah: "18:30 Ba'da
  Maghrib — Safinatun Naja" + tombol "Hadir Khataman" + footer
  "Ganti Baju"/"Tutup" terlihat utuh).

### 7. Tombol X panel chat (RENDAH) — LOLOS (robustness)
- TIDAK terreproduksi headless: X menutup panel walau toast tampil
  (7b/7c lolos) — teori toast-menutupi-X salah.
- Perbaikan robustness: X diperbesar 40×36 → 56×48 (pelajaran tombol
  X dashboard 15:05 WIB); toast `mouse_filter = IGNORE` (Label 800×40
  di y=70 menutupi header panel — tidak boleh memakan klik); klik di
  luar panel chat juga menutupnya (konsisten dengan semua panel lain).
- Bukti: tes 7a–7c; foto 02 (X besar terlihat di header panel chat).

### 8. Kecepatan jalan (CEK) — EXONERATED, tanpa perubahan kode
- W 3 detik = 18,0 m / 6,00 m/detik tepat; diagonal W+D = 18,0 m
  (ternormalisasi); yaw kamera 0.000 → 0.000 (tidak berputar);
  joystick penuh 18,3 m / 6,10 m/detik; joystick 1/6 (15 px) =
  1,00 m/detik tepat — ~1 m/detik penguji = artefak defleksi
  joystick sebagian, bukan bug.
- Bukti: tes 8a–8e.

## File yang diubah

- `scripts/main.gd` — `_on_outfit_dipilih` (visual dulu + print
  `[RONDE8]`); `_on_aksi` (TIDUR toggle + snap kamera saat bangun);
  `_process` (input mentah sebelum zeroing pose; tahan label nama tiap
  frame dari `is_chat_visible()`).
- `scripts/player.gd` — `_nama_ditahan` + `set_nama_ditahan()`;
  salaman/melambai `_aksi_timer = 0.0`.
- `scripts/npc.gd` — `_nama_ditahan` + `set_nama_ditahan()`.
- `scripts/interior_cangkruk.gd` — lampu pindah sudut NW + naik +
  collision sphere r=0.28.
- `scripts/interior_surau.gd` — 4 lampu + collision sphere r=0.28.
- `scripts/ui.gd` — toast IGNORE; chat X 56×48; klik-di-luar chat;
  `PETA_ZOOM` 3 tingkat + `_perbarui_tombol_zoom()`; `_teks` jepit_tepi
  + return Rect2 + `_rect_gerbang` + `_label_hindari`; dashboard
  `_dash_scroll` + `_on_dash_item_seret`.

## Insiden selama ronde 8 (pelajaran)

1. **Bug skrip foto (bukan game):** `open_dashboard(main._data_dashboard())`
   — fungsi itu TIDAK ADA di main.gd dan open_dashboard butuh 4
   argumen. Error runtime menghentikan `_initialize` sebelum `quit(0)`
   sehingga mesin terus jalan (CPU 143%, tanpa progres) — tampak
   seperti "macet". Terjadi 2× (run foto pertama terhenti di shot 07,
   lalu run susulan terhenti di langkah yang sama). Perbaikan:
   `open_dashboard(main._save, [], false, 0)` — persis seperti tes.
   Pelajaran: skrip foto/tes harus memakai signature yang sama dengan
   tes headless; run xvfb yang "macet" + CPU tinggi + tanpa output =
   cek dulu signature pemanggilan, bukan gamenya.
2. **Runtime restart** di tengah render foto pertama (9 mnt 31 dtk) —
   6/7 foto terselamatkan, log hilang. Foto susulan (foto_ronde8b.gd)
   menyelesaikan sisanya.
3. **pkill hati-hati:** `pkill -f` dengan pola yang juga muncul di
   command line sesi exec sendiri ikut membunuh sesinya (SIGTERM).
   Bunuh lewat PID, atau pola yang tidak cocok dengan command sendiri.

## Yang masih butuh parent agent

1. **Damar deploy** export ini (staging `export/web-pages/` dibangun
   ulang dari export baru seperti biasa: wasm 5 chunk + patch fetch;
   guard 3/3 di staging; pck baru `dca77670…` 981.264 byte).
2. **Retest browser sungguhan setelah deploy — WAJIB untuk item 1–3:**
   - Item 1: apakah print `[RONDE8] outfit_dipilih: sarung=#1d4e6b`
     muncul di console? Apakah sarung BIRU di **siang hari**?
   - Item 3: bangun dari kasur utara-tengah → tampilan normal?
   - Item 2: panel chat terbuka → label nama hilang (bukan terpotong)?
   - Item 7: X chat menutup dengan andal di browser sungguhan?
3. Setelah ronde 8 lolos retest: (a) hapus pilihan jalur dari form
   Daftar app + endpoint register server (sistem tunggal — tertunda
   sejak 15 Nov 22:17 WIB); (b) integrasi game-server; (c) set alamat
   game di app (Panel Ustadz → Gerbang Game).
