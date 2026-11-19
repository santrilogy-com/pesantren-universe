# FITUR FULLSCREEN VIA KETUK MASUK — Status (Cakra)

**Tugas:** ACC Mas 17 Nov 2026 ~20:52 WIB. Fullscreen diminta saat pemain
mengetuk tombol masuk di layar login (browser melarang fullscreen otomatis
tanpa ketukan). **TIDAK deploy** — menunggu verifikasi Raka + Mas.

## File diubah (HANYA `scripts/ui.gd`)

Tidak ada file lain yang disentuh — bukan `main.gd`, bukan audio/langit,
bukan file agen lain. Tidak ada file sisa di root proyek (semua skrip tes /
foto dihapus dari root setelah jalan; arsip di `fitur-baru/`).

### 1. Permintaan fullscreen saat masuk (login)

- `_on_masuk_pressed()` — setelah validasi username lolos (tidak kosong,
  tidak berspasi), memanggil `_minta_layar_penuh()` **sebelum**
  `login_submitted.emit(...)`. Handler berjalan sinkron di dalam gesture
  ketuk tombol, jadi browser menerima permintaan. Ketukan yang gagal
  validasi TIDAK minta fullscreen (diuji).
- `_on_continue_pressed()` — **baru** (sebelumnya lambda anonim di
  `_build_login`). "Lanjutkan sesi sebelumnya" kini memanggil
  `_minta_layar_penuh()` lalu `continue_pressed.emit()` — perilaku sama
  seperti MASUK, sesuai tugas.
- `_on_daftar_pressed()` — **perluasan di luar brief harfiah, dicatat di
  sini supaya Raka/Mas bisa membatalkan:** tombol "DAFTAR & MASUK
  PESANTREN" juga masuk ke game dari layar login, jadi perlakuannya
  disamakan (minta fullscreen setelah nama valid). Alasan: santri baru
  adalah jalur masuk pertama yang paling umum — kalau tombol ini tidak
  fullscreen, justru pemain baru yang tidak dapat fitur ini. Kalau Mas
  mau DAFTAR tetap berjendela, hapus satu baris `_minta_layar_penuh()`
  di `_on_daftar_pressed()`.

### 2. Fungsi fullscreen baru (di `ui.gd`, setelah `set_login_loading`)

- `_minta_layar_penuh()` — `DisplayServer.window_set_mode(FULLSCREEN)`
  kalau belum fullscreen; mencatat jejak `_layar_penuh_diminta = true`.
- `_keluar_layar_penuh()` — kembali ke `WINDOW_MODE_WINDOWED`;
  jejak dibersihkan.
- `_apakah_layar_penuh()` — keadaan nyata sekarang. Di web membaca DOM
  (`document.fullscreenElement != null` via JavaScriptBridge, pola sama
  seperti `_buka_video()`) — ini yang benar saat browser keluar sendiri
  via tombol kembali/ESC. Di luar web pakai `window_get_mode()`.
- `_dukung_layar_penuh()` — di web membaca `document.fullscreenEnabled`
  (false di iPhone/Safari). Kalau JS tidak terbaca, anggap didukung.
- `_on_layar_penuh_pressed()` — toggle tombol HUD: kalau sedang
  fullscreen → keluar; kalau tidak didukung browser → toast
  "Layar penuh tidak didukung di browser ini (mis. Safari iPhone)."
  dan tidak memaksa; kalau didukung → minta fullscreen.
- `_sinkron_tombol_layar_penuh()` + `_atur_teks_tombol_layar_penuh(penuh)` —
  teks tombol "Layar Penuh" / "Keluar Layar" mengikuti keadaan nyata.
  Dipanggil saat `size_changed` (connect di `_ready`, di samping
  `_layout_semua_panel`) dan berkala tiap 0,5 dtk di `_process`.

### 3. Tombol HUD "Layar Penuh" / "Keluar Layar"

- Di `_build_hud()`, baris kanan atas setelah tombol Suara:
  `_layar_penuh_btn`, 160×44, warna `HIJAU_TERANG` (sama seperti tombol
  HUD lain). Baris kini 6 tombol; offset baris dihitung ulang
  `-544 → -712` (lebar total 676 + 36 px dari tepi kanan, sama seperti
  sebelumnya). Foto F1/F2 membuktikan tombol muat dan terbaca.

## Hasil uji headless (xvfb-run, TANPA --headless, jam 10.00)

Skrip: `fitur-baru/skrip/test_fullscreen.gd` (+ `.tscn`).
Foto: `fitur-baru/skrip/foto_fullscreen.gd` (+ `.tscn`).

**Tes: 41 LOLOS / 0 GAGAL** (`/tmp/test_fullscreen.log`).

- Wiring (8): tombol ada, teks awal "Layar Penuh", 6 tombol di baris
  kanan atas, MASUK/DAFTAR/Lanjutkan/Layar Penuh terhubung ke handler
  masing-masing, `size_changed` terhubung ke sinkron label.
- MASUK (7): kosong/berspasi → tidak minta fullscreen + mode tetap
  WINDOWED + galat tampil + sinyal tidak terkirim; valid → minta
  fullscreen + **mode jadi FULLSCREEN (0 → 3)** + sinyal terkirim.
- DAFTAR (5): pendek → tidak minta fullscreen; valid → minta fullscreen
  + mode FULLSCREEN + sinyal terkirim.
- Lanjutkan (4): tampil saat ada save; diketuk → minta fullscreen +
  mode FULLSCREEN + sinyal terkirim.
- Toggle + label (10): toggle dari berjendela → FULLSCREEN + label
  "Keluar Layar" (sinkron dari keadaan nyata); toggle dari fullscreen →
  WINDOWED + label "Layar Penuh"; `_apakah_layar_penuh()` benar di
  kedua keadaan; `_dukung_layar_penuh()` true di non-web.
- Masuk dunia (3): HUD tampil, tombol tampil, `is_world_visible()`.
- Smoke 300 frame: **tidak ditunggu sampai habis.** Asersi 41/0 selesai
  ~4,5 menit; smoke merangkak karena VM padat (10 proses Godot agen lain
  bersamaan, share CPU ~23%) — proses dimatikan setelah ~11 menit smoke
  tanpa satu pun error di log. Bukan kegagalan tes; smoke penuh bisa
  diulang Raka saat VM lengang.

**Koreksi dari jalan tes (jujur):** jalan pertama 29/3 — 3 gagal di
DAFTAR/Lanjutkan/toggle. Penyebabnya BUG TES, bukan bug kode: mode
jendela bertahan antar-bagian (setelah MASUK valid, mode sudah
FULLSCREEN, jadi `_minta_layar_penuh()` benar-benar early-return).
Tes diperbaiki (reset mode ke WINDOWED sebelum tiap bagian) → 41/0.
Probe awal yang mengklaim "window_set_mode tidak mengubah mode di xvfb"
SALAH: probe itu memanggil dari `_ready` saat jendela belum ter-map.
Probe ulang (`probe_fullscreen2.gd`, disimpan): setelah 30 frame,
mode 0 → 3 langsung setelah set FULLSCREEN, 3 → 0 setelah set
WINDOWED. **Pelajaran untuk semua: jangan panggil `window_set_mode`
dari `_ready`** — jendela belum ter-map, permintaan hilang diam-diam.

## Foto bukti (`fitur-baru/foto/`)

- `F0-layar-login.png` (1280×720) — layar login: MASUK PESANTREN +
  "Lanjutkan sebagai Tes (PV-0001)" + "Belum terdaftar? Daftar baru".
  (Tombol Lanjutkan ditampilkan via `show_login` save tes — sama
  seperti di HP Mas yang save-nya sudah ada.)
- `F1-hud-layar-penuh.png` — dalam game, baris kanan atas:
  Kartu Santri | Peta | Chat | Aksi | Suara | **Layar Penuh**.
- `F2-hud-keluar-layar.png` — setelah ketuk toggle: mode FULLSCREEN
  betulan di xvfb (log: `mode setelah toggle: 3`), tombol berubah
  jadi **Keluar Layar**. (Ukuran foto tetap 1280×720 karena layar
  virtual Xvfb memang segitu — bukan bukti ukuran browser.)

Tombol "Layar Penuh" juga sudah terlihat di foto S1/S3 Raka (21:23 WIB)
— konfirmasi independen dari agen lain bahwa tombol tampil di HUD.

## Batasan yang jujur — BELUM terverifikasi

1. **Fullscreen asli di browser HP Mas BELUM terbukti.** Yang terbukti
   headless: transisi mode jendela + jejak permintaan + label. Yang
   masih butuh HP Mas (Chrome Android): ketuk MASUK → layar benar-benar
   penuh (tanpa bilah alamat); ketuk "Layar Penuh" → penuh; ketuk
   "Keluar Layar" → kembali; tombol kembali HP → keluar fullscreen dan
   label kembali "Layar Penuh" (sinkron via DOM + `size_changed` +
   polling 0,5 dtk). **Verifikasi ini butuh deploy + cek di HP Mas —
   Raka yang pegang deploy.**
2. **iPhone/Safari: fullscreen TIDAK jalan — batas Apple, bukan bug.**
   Safari iPhone tidak menyediakan Fullscreen API
   (`document.fullscreenEnabled == false`). Kode tidak mengakali:
   ketuk MASUK di iPhone tetap masuk game berjendela seperti biasa
   (tanpa galat), ketuk tombol HUD menampilkan toast penjelasan.
   iPad Safari kabarnya mendukung, tapi belum diuji — jangan klaim.
3. **Keluar fullscreen via gesture browser (tombol kembali / ESC)**
   disinkronkan lewat DOM `document.fullscreenElement` + resize +
   polling — logikanya ada, tapi butuh uji browser nyata (poin 1).
   Kalau di HP ternyata label telat berubah, yang perlu dicek pertama
   adalah apakah `size_changed` fire saat keluar fullscreen di Chrome
   Android (polling 0,5 dtk adalah jaring pengamannya).
4. **Tidak ada perubahan di luar `ui.gd`.** Kalau Raka butuh sesuatu
   dari `main.gd` (mis. menyimpan preferensi fullscreen ke save) itu
   belum ada — tulis di sini sebagai spesifikasi bila diperlukan:
   saat ini tidak ada persistensi; tiap buka game mulai berjendela,
   fullscreen diminta lagi tiap ketuk MASUK. Itu sesuai brief
   (fullscreen via ketuk MASUK), bukan kekurangan.

## Yang TIDAK dilakukan

- Tidak deploy. Folder v2 tidak disentuh. Tidak ada trik untuk
  Safari/iPhone. Tidak ada perubahan main.gd / audio / langit.
