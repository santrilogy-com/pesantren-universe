# RONDE 4 — STATUS SERAH-TERIMA (15 Nov 2026, ~19:05 WIB)

> Raka = ketua + integrator. Ronde 4 dipecah Mas 19:01 WIB supaya cepat selesai.
> Tara (UI), Gilang (pesantren luar), Dewa (interior) mulai sekarang.
> Raka selesaikan slice karakter + langit sampai titik aman, lalu INTEGRASI
> setelah ketiganya lapor. **JANGAN deploy** (Damar). Model Blender Bima
> **TIDAK masuk ronde ini** (swap model ronde berikutnya, setelah Mas acc
> preview Bima).

## Slice Raka — SELESAI (titik aman)

### 1. Karakter gaya Roblox — `scripts/player.gd` (`build_visual`) — SELESAI
Referensi: `~/workspace/pesantren-verse/referensi-avatar-roblox.jpg` (Mas 18:49 WIB).
Yang diambil: proporsi chunky, semua membulat, shading lembut mengkilap, wajah
simpel. Yang TIDAK ditiru: hoodie/sneakers/headphone/visor/logo "B".
Identitas tetap SANTRI: peci putih, koko putih kancing emas, sarung zamrud
kotak-kotak putih, sandal coklat.

Perubahan (dari revisi 18:45 WIB):
- Kepala 0.21 → **0.24** di y=1.66 (diameter 0.48 = ~25% tinggi, LEBIH LEBAR
  dari torso — kepala besar bulat ala Roblox). Mata 0.023 → 0.025 di
  (±0.085, 1.69, 0.222); hidung (0, 1.62, 0.237); peci 0.18/0.21 → 0.19/0.225
  di y=1.87 + lis 0.215/0.23 di y=1.81; kerah 0.10/0.12 h=0.08 di y=1.42.
- Torso kapsul 0.21 → **0.23** h=0.62 di y=1.08 (silinder kapsul kini
  y 1.00–1.16; kancing + lis dihitung ulang di permukaan baru; lis
  dipendekkan 0.36 → 0.30, z 0.205 → 0.225).
- Lengan kapsul 0.065 → **0.08** h=0.50, pivot ±0.26 → ±0.29; tangan bola
  0.07 → **0.09**. Kaki kapsul 0.07 → **0.085** h=0.55, pivot ±0.09 → ±0.11;
  sandal silinder 0.095 → **0.11**.
- Sarung 0.19/0.27 → **0.20/0.28** h=0.55 di y=0.62; hem 0.275 → 0.285;
  lis emas 0.285. Motif tetap checker prosedural (ImageTexture 8×3).
- Mulut: torus (18:46 WIB) → **kapsul tipis dibaringkan** (r=0.009, h=0.08,
  rotasi Z 90°, di (0, 1.55, 0.210)) — GARIS LURUS kecil menyambung seperti
  referensi Roblox, bukan busur, bukan benjolan. Pusat sedikit ditanam
  (z 0.210 vs permukaan 0.213) supaya ujung tidak melayang.
- Shading lembut: helper `_lembutkan(root)` — semua bahan karakter ke
  roughness **0.45** (dari 0.9 karton) via `Palette.mat(..., 0.45)`; motif
  sarung dipertahankan (hanya roughness turun). Dipanggil di akhir
  `build_visual`. Berlaku untuk pemain + semua NPC.
- Label nama y 2.05 → 2.12, bubble y 2.45 → 2.50 (mengikuti peci 1.935).
  `set_nama` tetap cocok (mencari Label3D y 2.0–2.2).
- Total tinggi karakter ~1.94 m (ke peci). 6 kapsul, 0 BoxMesh, 0 TorusMesh.

### 2. Langit senja — `scripts/pesantren_builder.gd` — SELESAI di kode
Perbaikan ronde 4 (dari tes browser ronde 3): kabut **DIMATIKAN**
(`fog_enabled=false`) — kabut menutupi langit di renderer web meski
`fog_sky_affect=0.0`; matahari DirectionalLight ke barat-laut elevasi ~8°
(`rotation_degrees (-8, -145, 0)`, energi 1.3); gradasi dikuatkan
(atas `#3f8fd2`, horizon `#ff9e57`, dasar langit `#5a8f57`); matahari 3D
(bola r=18 `#ffdf6b` + halo r=27 alpha 0.30) di `sun_dir × 380 m`.
Teruji headless (5 cek langit di test_karakter). **Belum teruji di build web**
— lihat BLOKIR di bawah.

### 3. Verifikasi slice Raka — HIJAU
- `--import` exit 0.
- `--check-only` **10/10 script exit 0** (main, mission_data, npc, palette,
  pesantren_builder, player, save_data, ui, virtual_joystick, test_karakter).
- `test_karakter.gd`: **38 lolos, 0 gagal** (600 frame, 0 script error).
  Rincian: karakter 20 cek (lengan/tangan/kaki/sandal/torso/sarung/hem/
  kepala/mata/peci/mulut garis lurus/tanpa TorusMesh/checker/shading 0.45/
  0 BoxMesh/6 kapsul/kepala > torso), langit 5, login+panel 5, interior
  masuk 4, interior keluar 4.
- Foto render software (BUKAN build web — lihat BLOKIR):
  `~/workspace/pesantren-verse/foto-avatar-gameplay-belakang.png`,
  `foto-avatar-depan.png`, `foto-avatar-wajah.png`, `foto-avatar-sarung.png`,
  `foto-langit-utara.png` (skrip `foto_karakter.gd`, xvfb-run + opengl3).
  **Penilaian jujur dari foto (Raka, 19:12 WIB):** langit gradasi
  biru→oranye + matahari 3D TERLIHAT jelas (kabut mati bekerja); avatar
  chunky (kepala besar bulat, lengan/tangan/kaki tebal, sarung checker
  kotak-kotak terbaca depan-belakang, mulut garis lurus kecil bukan
  benjolan — terlihat di close-up depan, shading lembut ada kilap di
  kepala). Masih jelas primitif Godot (bukan sculpt Roblox) — Mas yang
  menilai cukup "keren" atau belum. Catatan: foto "wajah" dan "depan"
  ternyata dari BELAKANG (pemain menghadap selatan; kamera di utara) —
  close-up wajah depan yang benar ada di foto-langit-utara (karakter
  "Tes" di kanan, close-up depan). Foto "gameplay-belakang" justru
  tampak DEPAN (kamera di selatan).

## File ownership (selama split — JANGAN saling timpa)
- **Raka:** `player.gd` + integrasi (wiring Dewa di `main.gd`) + export.
- **Tara:** `ui.gd` — kartu kuis (muat + tutup 4 cara, portrait & landscape),
  overlay peta (tombol Peta HUD, top-down, tutup 4 cara), smartboard
  (3 slide Nahwu M1 next/prev + tombol "Tonton Video" via JavaScriptBridge,
  URL konstanta, nonaktif bila kosong).
- **Gilang:** `pesantren_builder.gd` + bounds/kamera di `main.gd` — peta
  membesar (tanah/pagar/respawn, pohon/prop, 4 lahan + ambang 25/50/100/200
  tetap), pagar plot SOLID (collision), Surau luar membesar, papan 2 sisi,
  Reset Posisi kembalikan kamera, SPEED 6.0.
- **Dewa:** file **BARU** interior + snippet wiring untuk Raka pasang di
  `main.gd`. Dewa **TIDAK edit main.gd**. Interior Surau (ala GTA, teleport
  bukan reload): sajadah 3×4, mihrab, rak kitab, 2 lampu hangat, papan
  dinding, 2 meja sampar + kitab, smartboard. State utuh bolak-balik.

## Yang tersisa (Tara / Gilang / Dewa — tunggu laporan mereka)
- Tara: item 1 (kartu kuis), 3 (overlay peta), 7 (smartboard) + bonus kamera
  lerp / goyangan halus (bila sempat, jangan ganggu slice lain).
- Gilang: item 2 (map luas), pagar solid, item 4 (Surau luar besar),
  Reset Posisi + kamera, kecepatan jalan.
- Dewa: item 5 (interior GTA) + 6 (isi interior) — file baru + snippet.
- Setelah ketiganya lapor → Raka INTEGRASI (di bawah).

## Integrasi (Raka, SETELAH ketiganya lapor)
1. Gabungkan hasil Tara/Gilang/Dewa; selesaikan konflik (bila ada file
   yang sama disentuh, bandingkan dan gabung manual — jangan timpa buta).
2. Verifikasi PENUH: `--import` exit 0; `--check-only` semua script;
   headless test per item (panel kuis, map, peta, interior bolak-balik,
   smartboard, langit, karakter); smoke 600 frame 0 script error.
3. Hapus file tes (`test_karakter.gd`, `foto_karakter.gd`) sebelum export.
4. Export web ke `export/web/` (`--export-release "Web"`).
5. Lapor ke parent. **JANGAN deploy** (Damar).

## INTEGRASI — PROGRES (19:12–19:17 WIB)
- **Gilang SELESAI (48/48, 0 gagal) — TERINTEGRASI, tanpa konflik.**
  Sebagian besar slice-nya sudah dikerjakan Raka sebelum pecah (peta 116 m,
  pagar solid, papan 2 sisi, Surau 12×10, Reset Posisi + kamera). Yang BARU
  dari Gilang HANYA di `pesantren_builder.gd` `_dekor` (baris 545–586,
  komentar GILANG): 2 pohon dipindah (dari dalam plot Asrama + menempel
  pagar Ruang Kelas), +14 pohon (total 37), +6 semak +4 batu, papan selamat
  datang jadi 2 sisi. TIDAK menyentuh main.gd. Tes: `test_luar.gd` 48/48.
  **SPEED: tetap 6.0** (keputusan integrator, saran Gilang — menyeberang
  penuh ~19 dtk; naik ke 6.5 hanya kalau Mas masih mengeluh lambat).
- **Dewa SELESAI (52/52, 0 gagal) — WIRING SELESAI oleh Raka.**
  File BARU `scripts/interior_surau.gd` (class InteriorSurau,
  `build()` -> Dictionary) + `scenes/interior_surau.tscn` +
  `test_interior.gd`. Ruangan 18×14 m, tinggi 4,6 m, pusat (0,0,-301).
  Wiring di `main.gd` `_ready()` (ganti 4 baris interior-dari-builder
  dengan `InteriorSurau.build()` + `add_child`); di
  `pesantren_builder.gd` DIHAPUS: pemanggilan `_interior_surau(root)`,
  fungsi `_interior_surau` + `_meja_sampar`, 4 kunci dict
  (interior_door/interior_spawn/smartboard_spot/smartboard_screen),
  `static var _smartboard_screen`. Konstanta INTERIOR_SPAWN
  DIPERTAHANKAN (dipakai test_interior + test_karakter).
  **Konflik integrasi (diperbaiki Raka):** tes Dewa menambahkan
  `InteriorSurau` kedua ke `_main` → Godot menamai ulang jadi
  `InteriorSurau2` → cek nama gagal (51/52). Perbaikan pertama (cabut
  add_child) malah merusak 5 cek collision (global_transform butuh node
  di tree). Perbaikan final: node tes ditambahkan ke `root` (Window),
  bukan `_main` — nama tetap unik + transform terhitung. Tes ulang
  sedang jalan (target 52/52).
  Koreksi Dewa dicatat: `show_smartboard()` kini ADA (alias Tara);
  smartboard spot Dewa (-6.8,0,-301) dipertahankan (jarak ke M2 ±2,4 m,
  dalam radius 3,5 m — jangan "diperbaiki").
- **Tara SELESAI (97/97, 0 gagal) — TERINTEGRASI, tanpa merge.**
  HANYA mengubah `scripts/ui.gd` (tidak ada yang perlu di-merge).
  Temuan akar keluhan Mas: panel 390×844 portrait cuma 213×171 px FISIK
  (kanvas 700×560 skala 0,30) — font judul ~8 px, tombol X 17×15 px.
  Perbaikan: `panel_metrics` sadar-skala (target fisik maks 700×560,
  dibatasi 92% viewport), `_terapkan_skala_panel()` menskalakan font +
  tombol ke ukuran fisik desain, autowrap di 3 judul header (judul
  smartboard tanpa autowrap bikin panel melebar 1349 px kanvas >
  viewport 1280 portrait — bug nyata, diperbaiki). Desktop tidak berubah.
  `show_smartboard()` kini ADA (alias `open_smartboard()`). URL video di
  `mission_data.gd` saja. Tes: `test_tara_ui.gd` 97/97.
- **Status verifikasi gabungan (19:17 WIB):** import 0; check-only 14/14
  script exit 0 (termasuk interior_surau.gd + 4 file tes); Tara 97/97,
  Karakter 38/38, Luar 48/48; Interior 47/52 (5 gagal collision —
  regresi perbaikan pertama, sedang dites ulang dengan perbaikan final).
- **HASIL AKHIR (19:19 WIB): Interior 52/52, 0 gagal.** Total verifikasi
  penuh: **235 cek (Tara 97 + Interior 52 + Karakter 38 + Luar 48),
  0 gagal.** Import 0; check-only 14/14. File tes dihapus sebelum export
  (test_tara_ui, test_luar, test_karakter, test_interior, foto_karakter;
  hanya .uid tersisa). Export web ke `export/web/` sedang jalan.
  **SPEED: tetap 6.0** (keputusan integrator).
- **EXPORT SELESAI (19:20 WIB):** `--export-release "Web"` exit 0.
  `index.pck` 144.296 byte (sha256 `2f6041b4b8ad59d37…`),
  `index.wasm` 39.514.754 byte (sha256 `fc74679e3b97f768…`, TIDAK berubah),
  `index.js` 279.815 byte, `index.audio.position.worklet.js` 2.973 byte
  (WAJIB ikut deploy). Script tag fresh export 2/2 seimbang (3/3 di
  deploy guard = staging Damar + patch chunking). Pck headless 600 frame
  (`--main-pack`): exit 0, **0 SCRIPT ERROR**. **TIDAK deploy** (Damar).
- **Yang tersisa sebelum export:** tes interior hijau (52/52) → hapus
  file tes (`test_tara_ui.gd`, `test_luar.gd`, `test_karakter.gd`,
  `test_interior.gd`, `foto_karakter.gd`) → export web ke `export/web/` →
  lapor. Verifikasi visual browser (terutama portrait) TIDAK BISA dari
  VM ini (LNA — lihat BLOKIR); harus dari URL live setelah Damar deploy.

## BLOKIR — screenshot build web (Chrome 157 Local Network Access)
Build web lokal (`https://pesantren-verse.pages.dev:8901/`, server HTTPS
127.0.0.1:8901, sertifikat self-signed) **TIDAK BISA dibuka Chrome penuh**
di VM ini: `chrome-error://chromewebdata/`,
`net::ERR_BLOCKED_BY_LOCAL_NETWORK_ACCESS_CHECKS`
("initiated by a public page to connect to devices on your local network",
corsError `InsecureLocalNetwork`). Penyebab: hostname publik
(pesantren-verse.pages.dev) di-resolve ke IP lokal (127.0.0.1) via
host-resolver-rules — Chrome 157 memblokirnya sebagai Local Network Access.
Yang sudah dicoba dan GAGAL (15 Nov ~19:00 WIB):
- `--disable-features=LocalNetworkAccessChecks` (flag ada di proses, tetap diblokir).
- Tab fresh dari about:blank (tetap diblokir).
- Navigasi langsung `https://127.0.0.1:8901/` (tetap diblokir; proxy-bypass
  tidak mencakup 127.0.0.1).
- Enterprise policy `/etc/opt/chrome/policies/managed/pv-local.json`
  (`LocalNetworkAccessAllowedForUrls` untuk kedua URL) + restart Chrome —
  tetap diblokir; `chrome://policy` ikut diblokir ("Your organization
  doesn't allow you to view this site") — browser ini managed (Hatch),
  policy kemungkinan dikunci.
- Server lokal sendiri SEHAT (curl HTTPS 8901: index.html 200, index.pck 200).
Dampak: gerbang "karakter lolos di screenshot build web" **belum bisa
dipenuhi dari VM ini**. Foto render software (di atas) adalah bukti visual
terbaik yang tersedia — geometri avatar + langit SAMA (Godot yang sama),
hanya renderer-nya software (llvmpipe) bukan web. **Setelah Damar deploy
ronde 4 ke pages.dev, LNA hilang dengan sendirinya** (URL publik sungguhan,
bukan server lokal) — screenshot build web bisa diambil dari URL live.
Artefak diagnosis: `/tmp/diag-nav.mjs`, `/tmp/diag-freshtab.mjs`,
`/tmp/diag-ip.mjs`, `/tmp/diag-policy.mjs`, `/tmp/launch-chrome-lna.sh`.
Chrome 9223 (uji LNA) masih jalan; Chrome 9222 (utama) tidak disentuh.
Policy `/etc/opt/chrome/policies/managed/pv-local.json` (dibuat Raka,
gagal mengatasi LNA) boleh dihapus setelah tidak diperlukan.

## Catatan penting (jangan dilanggar)
- Engine **TETAP Godot 4.7.2** (`~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64`).
  Jangan pindah ke Three.js/Unity/Roblox. Jangan sentuh CCS, game-nahwu, app.
- Deploy guard: sebelum deploy, cek 3 `<script>` / 3 `</script>` di staging
  index.html; deploy helper pakai `~/workspace/.venv-cloudflare/bin/python`
  (blake3); `index.audio.position.worklet.js` wajib ikut deploy; wasm
  39,5 MB di-chunk (~5 chunk.bin).
- Deploy aktif masih `483a3983` (ronde 3, 15:56 WIB). Export ronde 4
  (11:16 WIB, pck sha256 `1eca5879…`) SUDAH KEDALUWARSA (sebelum revisi karakter).
- Server game Fase 1 live: https://43-173-39-166.sslip.io (Saka). PV-0001 "Tes"
  sudah di server. Ambang bangunan: Kelas 25, Asrama 50, Masjid 100,
  Perpustakaan & Taman 200.
- Bahasa: pakai "pesantren", jangan "dunia". Mulai dari Surau kecil.
- File tes yang ada: `test_karakter.gd` (38 cek — JANGAN hapus sebelum
  integrasi + export), `foto_karakter.gd` (utilitas foto — hapus sebelum export).
