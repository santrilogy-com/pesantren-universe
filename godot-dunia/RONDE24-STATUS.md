# RONDE 24 — STATUS (Raka, 17 Nov 2026)

**ACC Mas 22:16 WIB (widget "ACC semua")** — isi: ronde perbaikan 15 item +
revisi duduk/sarung terhampar S1–S4 + meja tembus Kyai S3b + bubble chat gaya
MLBB + fullscreen + cuaca + kode adzan (masih DIAM — belum ada rekaman,
sesuai perintah, jangan cari rekaman sendiri).

## 1. Clone v2 (penanda ditunggu dulu)

- Penanda `~/workspace/pesantren-verse/v2/CLONE-SELESAI.txt` muncul 22:26 WIB,
  isi: `clone selesai Tue Nov 17 15:24:34 UTC 2026` (22:24:34 WIB).
- Export dimulai SETELAH penanda ada. Folder v2 TIDAK disentuh Raka.

## 2. Export web (22:26:33–22:27:16 WIB, 43 detik, EXIT:0)

- Godot 4.7.2 headless, `--export-release "Web"`, target `export/web/index.html`.
- `index.pck` BARU: **1.670.160 byte**, sha256
  `0f8ca2b2bfb4f941211d3b450be700865c59081c3cc58b8b9bb66f2f0c6a670e`
  (naik dari 1.623.472 Ronde 23 — cuaca.gd baru + ui.gd/main.gd/langit_dinamis
  berubah).
- `index.wasm` TIDAK berubah: 39.514.754 byte, sha256
  `fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0`.
- `index.js` TIDAK berubah: 279.815 byte, sha256
  `33c94cb3175f3333b82e2a3be5e8e86f77986f0aa2042b1631f6367a4e5bb6ba`.

## 3. Snapshot staging `export/web-pages/` (22:27–22:28 WIB)

- Backup staging lama: `export/web-pages-backup-35f66eba/` (pck Ronde 23
  `ffdf8d2d…` terverifikasi di backup).
- `index.pck` baru disalin — sha256 staging `0f8ca2b2…` COCOK dengan export segar.
- 3 file `.import` segar disalin (index.png / index.icon.png /
  index.apple-touch-icon.png) — sha256 staging COCOK dengan fresh.
- GODOT_CONFIG staging: `"index.pck":1623472 → 1670160`,
  `"index.wasm":39514754` tetap.
- `index.audio.position.worklet.js` di staging: 2.973 byte, sha256
  `be33985bc7160d6bf9646f259cd86b259cd67b02ccb297ee5c44f8ac84327bc8`
  (sama dengan fresh).

## 4. Guard staging index.html — LOLOS

- 3 `<script>` / 3 `</script>`; `})();` baris 144 → `</script>` 145 →
  `<script src="index.js">` 146.
- Diff staging vs fresh export: HANYA blok patch wasm 34 baris
  (chunked wasm loader). Tidak ada perubahan struktur lain.
- Chunk wasm `wasm/part-00..04.bin` TIDAK disentuh — rakitan sha256
  `fc74679e…` COCOK.
- Staging `index.html` 7.024 byte (fresh 5.534 byte).

## 5. Uji headless

- `--check-only`: **MACET >5 menit tanpa output** — dihentikan (SIGTERM).
  Dicatat jujur: export `--export-release` EXIT:0 sudah membuktikan semua
  skrip ter-parse + ter-pack (error parse akan menggagalkan export).
- Boot headless `--quit-after 240`: **EXIT:0, 0 baris error**, 17 detik
  (22:33:40–22:33:57 WIB). Log hanya banner Godot, tanpa SCRIPT ERROR /
  parse error / failed to load.
- Tes fitur (tim, sebelum export — sudah dilaporkan ke Xam): bubble ML 22/0
  + reroute 11/11, fullscreen 41/0, cuaca C1–C4, adzan 28/28 + 10/10 (tanpa
  file), ronde perbaikan integrasi 35/35, duduk 33/33.
- Catatan: saat boot test ada 4 proses Godot bersamaan di VM (kemungkinan
  Rangga v2 + sisa check-only) — VM sibuk, tes tetap bersih.

## 6. Status deploy

**BELUM DEPLOY — export + staging SIAP, menunggu Damar** (perintah Xam).
Live saat ini tetap Ronde 23 (`35f66eba`, pck `ffdf8d2d…`).
