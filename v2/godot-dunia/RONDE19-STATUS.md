# RONDE 19 — STATUS (16 Nov 2026 ~13:00 WIB)

Investigasi + perbaikan sarung biru yang gagal live untuk ke-3 kalinya
(retest browser ronde 10+11+12+13+14, build live ad5074ed).

## Fakta live (retest 16 Nov ~12:24 WIB)
- Panel Ganti Baju: klik sarung "Biru" 2× TIDAK mengubah apa-apa
  (centang tetap di "Zamrud", pratinjau tetap hijau); klik "Coklat" juga
  tidak mengubah. Baris Kulit ("Gelap") dan Kacamata ("Pakai") merespons
  NORMAL. Close-up karakter setelah panel ditutup: sarung HIJAU Zamrud.
- Console browser tidak bisa dibuka penguji, jadi print `[RONDE8]`
  tidak bisa dicatat.

## Yang diperiksa dan DISELESAIKAN (bukan penyebab)
- Kode panel seragam untuk semua baris (loop yang sama di
  `_build_outfit_panel`, ui.gd:876-909): tombol, sinyal
  `_on_outfit_swatch`, kunci hex — tidak ada perbedaan sarung vs
  kulit/kacamata.
- Rantai sinyal utuh: `outfit_dipilih` → `main._on_outfit_dipilih` →
  `terapkan_outfit` + save + `set_outfit_terpilih` (✓).
- Handler klik-di-luar ada di `_unhandled_input` (ui.gd) — TIDAK BISA
  memakan klik tombol (tombol menangani kliknya dulu).
- `main._input` hanya membuka audio (ronde 17), tidak memakan klik.
- Tidak ada overlay di atas baris sarung (toast + blackout IGNORE;
  HUD IGNORE; joystick kiri-bawah, jauh dari panel).
- Geometri terukur di ukuran browser live (1920×998, skala 1.386):
  panel 700×560 di (342.5, 80); SEMUA tombol di dalam rect panel,
  visible=true, disabled=false.

## Tes repro (test_repro_sarung.gd/.tscn — salinan akhir di /tmp)
- Jebakan harness (dicatat supaya tidak terulang): mode `-s` membuat
  jendela 100×100 dan `--resolution` diabaikan → jalankan sebagai
  SCENE (`.tscn`) supaya `--resolution 1920x998` diterapkan. Skala
  stretch "expand" = 1.386 (BUKAN 1.5 — expand memakai rasio TERKECIL,
  visible rect 1385×720). Posisi klik event = koordinat WINDOW
  (tengah rect kanvas × skala) — pelajaran ronde 7.
- **Klik bersih: SEMUA LOLOS** — sarung Biru (2×), Coklat, kulit Gelap,
  kacamata Pakai, koko Biru Muda, songkok Hitam: sinyal sampai, ✓
  pindah, save berubah, panel tetap terbuka (38/38 sebelum perbaikan).
  Jadi kegagalan live TIDAK bisa direproduksi dengan klik bersih di
  geometri live yang persis.
- **Kasus seret — MEKANISME TERBUKTI:** tekan di tengah tombol, geser
  mouse 120 px (dengan InputEventMouseMotion, supaya posisi mouse
  engine ikut pindah), lepas di luar tombol → tombol mode RELEASE
  TIDAK menyala (sinyal 7->7, centang tidak pindah) — PERSIS gejala
  live. Tanpa motion event, seret tetap menyala (posisi mouse engine
  tidak berpindah) — itu sebabnya percobaan seret pertama lolos.
  Bukti harness browser memang menggeser mouse saat menahan tombol:
  receipt retest menunjukkan drag 480 px dan tahan-klik 17 detik.

## Perbaikan (satu-satunya perubahan kode — scripts/ui.gd)
- Semua tombol swatch (koko/songkok/sarung/kulit) + tombol kacamata di
  `_build_outfit_panel` kini `action_mode =
  BaseButton.ACTION_MODE_BUTTON_PRESS` — pilihan menyala SAAT TEKAN,
  tidak tergantung posisi lepas. Cocok untuk pemilih warna (umpan
  balik langsung) dan kebal terhadap klik yang dikirim sebagai
  tekan→geser→lepas. Tombol X (tutup) TIDAK diubah (tetap RELEASE).
- Tidak ada perubahan lain: tidak sentuh skema sholat ronde 18,
  sistem regu CCS, atau bangunan.

## Verifikasi setelah perbaikan
- **Tes repro: 42 LOLOS / 0 GAGAL** (termasuk kasus seret yang kini
  DIASSERT dan lolos: sinyal sampai, ✓ pindah ke Coklat, save berubah).
- `--import` 0 error; `--check-only` ui.gd OK; smoke headless
  600 frame 0 SCRIPT ERROR / 0 ERROR.
- **Foto bukti** di `~/workspace/pesantren-verse/foto-ronde19/`:
  01-panel-sebelum.png (✓ Zamrud), 02-panel-biru.png (✓ pindah ke
  Biru), 03-sarung-biru-depan.png (karakter depan, sarung BIRU batik
  parang + titik emas — jelas biru, bukan hijau; siang hari).
- Save lokal dikembalikan ke default sesudah tes (sarung Zamrud).
- **Export: `export/web/`** — pck BARU **1.544.020 → 1.544.260 byte**,
  sha256 `3b117b5bdb8577141d5dbe63a1c1b583b974470af8a1b18e695c1c644ae4db48`
  (+240 byte, 2 baris kode); wasm TIDAK berubah (`fc74679e…`,
  39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet
  `index.audio.position.worklet.js` 2.973 byte ada.
- Skrip tes + foto sudah dihapus dari proyek sebelum export
  (salinan akhir: /tmp/test_repro_sarung_final.gd,
  /tmp/foto_ronde19_final.gd).
- **TIDAK deploy** (menunggu verifikasi + keputusan parent).

## Jujur / belum sempurna
- **Akar masalah di browser live TIDAK diamati langsung** (Chromium VM
  tidak bisa start; tidak ada retest browser lokal). Yang terbukti:
  (a) klik bersih di geometri live yang persis TIDAK gagal;
  (b) seret tekan→geser→lepas mereproduksi gejala live dengan tepat;
  (c) perbaikan PRESS membuat seret menyala. Mekanisme seret adalah
  penjelasan paling masuk akal, BUKAN kepastian — **retest browser
  live tetap dibutuhkan untuk mengonfirmasi** (klik Biru + Coklat di
  build baru, plus cek console `[RONDE8]` bila bisa dibuka).
- Observasi kosmetik (SUDAH ADA sebelum ronde 19, TIDAK diperbaiki —
  di luar tugas): tombol swatch yang sedang di-hover tampil ABU-ABU
  (stylebox hover/pressed tidak di-override, jatuh ke tema default) —
  terlihat di foto 02 pada tombol Biru yang baru diklik. Fungsinya
  benar; tampilannya bisa dilengkapi nanti bila Mas minta.
- Tugas BERIKUTNYA (jalan + lampu Surau, Mas 12:38 WIB) BELUM
  dikerjakan — sengaja tidak dicampur; mulai setelah laporan ini.
