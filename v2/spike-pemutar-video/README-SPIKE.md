# SPIKE — Pemutar Video di Dalam Game (cara A, konsep RB v3)

**Status: BERHASIL — cara A TERBUKTI JALAN.** Diuji di browser sungguhan
(chrome-headless-shell 157 + export web Godot 4.7.2), video contoh
30 dtk 540×960 H.264+AAC. **Ringkasan uji akhir: SEMUA UJI LOLOS**
(12 langkah, `hasil-uji/hasil-uji.json`).

## Yang terbukti (run 4, server Range, port 8932)

| Uji | Hasil |
|---|---|
| Game boot di browser, `JavaScriptBridge` ada (`di_web=true`) | ✓ |
| Elemen `<video>` dibuat Godot via `jsb.eval`, metadata durasi 30 dtk | ✓ |
| Putar dari tombol Godot → posisi maju (4,4 dtk / 6 dtk dinding — headless ~0,7x, di HP nyata 1x) | ✓ |
| Jeda → posisi DIAM persis (4,808583 = 4,808583) | ✓ |
| Seek ke 25 dtk → posisi 25, **ditonton kumulatif TIDAK nambah (selisih 0)** | ✓ (gate anti-farming jalan) |
| Putar dari 25 → 29,4 dtk (hampir habis) | ✓ |
| Gate 80% tercapai: ditonton 24,85 dtk ≥ 24 dtk → tombol "Lanjut ke Latihan" terbuka | ✓ |
| Sembunyikan / tampilkan elemen video | ✓ |
| Layar penuh (`requestFullscreen`) → `fullscreenElement=true`, bahkan di headless | ✓ |
| `timeupdate` → Godot via `create_callback` + polling eval 0,5 dtk (cadangan) | ✓ |

Bukti visual: `hasil-uji/03-sedang-memutar.png` (timer video 00:00:04.633,
status MEMUTAR, gate 18%) dan `hasil-uji/04-gate-tercapai.png`
(timer 00:00:20.967, gate 104% TERCAPAI).

## File spike (tree game TIDAK disentuh)

- `pemutar_video.gd` — modul siap pakai ulang di game (`class_name
  PemutarVideoSpike`): muat/putar/jeda/seek/sembunyikan/tampilkan/
  layar-penuh/hapus + sinyal `waktu_berubah` + `persen_gate()` /
  `gate_tercapai()`. Hitungan kumulatif di JS (`timeupdate`, delta
  maju ≤1,0 dtk saja; lompat seek tidak dihitung).
- `main.gd` + `main.tscn` — UI uji (9 tombol, label status, log).
- `episode-contoh.mp4` — video contoh 30 dtk, 540×960, 3,3 MB
  (dibuat `buat_video_contoh.sh`, timer dibakar ke gambar).
- `web/` — hasil export web (pck hanya 15 KB — video TIDAK di pck).
- `uji_spike.mjs` — uji browser otomatis (puppeteer + chrome-headless-shell).
- `probe_seek.mjs` — probe diagnostik seek (dipakai saat debug run 3).
- `server_range.mjs` — server statis Node DENGAN Range (pengganti
  `python http.server` — lihat pelajaran 2).

## Cara menjalankan ulang

```bash
cd ~/workspace/pesantren-verse/v2/spike-pemutar-video
# (1) export ulang bila .gd berubah:
~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --export-release Web web/index.html
# (2) server Range (JANGAN python http.server — lihat pelajaran 2):
node server_range.mjs   # port 8932, biarkan jalan
# (3) uji:
node uji_spike.mjs      # exit 0 = semua lolos; hasil di hasil-uji/
# (4) matikan server: kill <PID node server_range.mjs>
```

## Pelajaran (3 temuan penting — semuanya sudah diperbaiki/diverifikasi)

1. **Overlay HARUS `pointer-events:none`.** Backdrop `inset:0` + video
   di atas canvas MENELAN semua klik/sentuhan → tombol Godot di bawahnya
   mati total (run 1: klik Putar/Seek tidak sampai ke Godot). Overlay
   hanya lapisan VISUAL; semua input tetap milik Godot. Ketuk area video
   = klik canvas → Godot yang menjeda/melanjutkan (sesuai mockup §3.1).
2. **Server video WAJIB dukung HTTP Range.** `python http.server` tidak
   mendukung Range → Chrome melaporkan `video.seekable = [0,0]` sehingga
   SEMUA seek dijepit ke 0 (run 2–3, sempat dikira bug mekanisme).
   Dengan server Range: `seekable=[0,30]`, seek 25/15/5 semua tepat
   (`probe_seek.mjs`). **Implikasi panel v3: hosting episode HARUS
   mendukung Range — Cloudflare Pages mendukung Range (perilaku standar
   CDN), tapi WAJIB diverifikasi ulang saat episode 1 di-deploy ke Pages
   (cek `Accept-Ranges: bytes` + seek di HP Mas).**
3. **Jangan ada probe autoplay yang menyentuh playback.** Probe
   `play()` + `pause()` + `currentTime=0` di `loadedmetadata` sempat
   dicurigai mereset posisi (ternyata bukan itu — pelajaran 2), tapi
   tetap DIBUANG: alur nyata SELALU mulai dari ketukan "Tonton Episode"
   (gestur), jadi autoplay tanpa gestur tidak relevan. Headless: video
   berjalan ~0,7x kecepatan nyata (SwiftShader) — ambang uji
   disesuaikan (posisi >2 dtk per 6 dtk dinding); di HP nyata 1x.

## Keterbatasan yang TIDAK teruji di spike ini

- **Suara di HP nyata** — headless tidak punya output audio; video
  berputar (`!paused`, `currentTime` maju) tapi bunyi VO belum
  terdengar telinga. Perlu T1 Mas di HP (Galaxy A35) saat panel v3 jadi.
- **Perilaku saat aplikasi diminimalkan / layar mati** — jeda otomatis
  + simpan posisi (§6.2 konsep butir 3) belum diuji; panel v3 harus
  menjeda saat panel ditutup (sudah ada `jeda()` + `hapus()`).
- **Jaringan lambat / video besar** — contoh 3,3 MB lokal; episode
  90 dtk ±8–15 MB via Pages belum diukur waktu muat streaming-nya.
- **Autoplay tanpa gestur** — sengaja tidak diuji (tidak relevan).

## Yang masih harus dibangun untuk panel v3 (sesudah spike ini)

1. Port `pemutar_video.gd` ke game (`scripts/ui_misi/pemutar_video_ui.gd`)
   + panel sesuai mockup §3.1 (area video 9:16, daftar 6 adegan, kotak
   gate, tombol "Lanjut ke Latihan" + "Baca Ulang Modul" + "× Tutup").
2. `data_modul_01.gd`: pemetaan video episode `{url, durasi, adegan[]}`.
3. `data_chat_modul_01.gd`: 14 node → 6 node pemandu (P1–P6).
4. `save_data.gd`: kunci baru `rb_tonton_detik` + `rb_fase` di
   `default_data()`; poin materi 10 saat gate 80% tercapai.
5. `manajer_ui_misi.gd` + `main.gd`: orkestrasi pemandu → tonton →
   latihan; papan tulis = judul episode + adegan aktif; jeda suara
   game/adzan selama video diputar.
6. `skrip/test_ruang_belajar_v3.gd`: gate 80%, seek tidak membuka gate,
   resume `rb_fase` + posisi tonton, tonton ulang tanpa poin.
7. Hosting episode 1 di Pages (file statis di luar pck) + verifikasi
   Range + seek di HP Mas. **Urutan tetap: naskah final → VO + build
   video ep01 → bangun panel.**
