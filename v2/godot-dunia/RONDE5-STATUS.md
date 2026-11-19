# RONDE 5 — STATUS (15 Nov 2026, selesai ~21:50 WIB)

Ronde 5 (4 item Mas 20:36 WIB + koreksi 20:41 WIB + chat MLBB 20:49 WIB).
**SELESAI, sudah di-export ke `export/web/` — TIDAK deploy (Damar yang deploy).**
Retest browser ronde 4 (build 6eaa34d9) TIDAK pernah sampai selama ronde 5 —
tidak ada temuan tambahan yang bisa dilipat ke ronde ini.

## 1. Langit dinamis sesuai jam nyata — SELESAI
- Baru: `scripts/langit_dinamis.gd` (class `LangitDinamis`, controller Node3D).
- Baca jam lokal perangkat (`Time.get_datetime_dict_from_system`); 5 fase
  dengan keyframe + smoothstep (bukan lompat): Subuh 04:00–05:30, Pagi
  05:30–10:00, Siang 10:00–15:00, Sore 15:00–18:00, Malam 18:00–04:00.
- Matahari 3D (bola + halo, posisi dari jam: azimut timur→barat, elevasi
  −6°→62°→3°), bulan 3D (tampil malam saja, posisi dari jam), 140 bintang
  (MultiMesh, alpha mengikuti gelap), 1 DirectionalLight3D (matahari siang /
  cahaya bulan malam), kabut TETAP MATI.
- Lampu jalan + lampu Surau menyala di malam hari (emisi bohlam 0,1→4,0,
  OmniLight 0→1,2) — suasana malam tetap jelas, bisa main.
- `debug_jam` statis (≥0 = paksa jam untuk tes, −1 = jam sistem). Di-render
  ulang lewat `_environment()` (pesantren_builder) — `fog_enabled=false`
  dipertahankan.
- Bukti: 5 foto langit (subuh/pagi/siang/sore/malam) + 10 cek logika
  (fase, warna langit, elevasi matahari, bintang, bulan, lampu).

## 2. Semua tulisan diperbaiki — SELESAI (dengan koreksi Mas)
- **Koreksi Mas 20:41 WIB: label nama TANPA outline, ala game bola.**
  `palette.gd`: `label3d()` kini ambil `tanpa_outline` (bukan lagi outline
  putih untuk semua) + outline GELAP untuk teks terang / TERANG untuk teks
  gelap (penyebab gumpalan putih dulu: outline putih di atas teks putih) +
  `outline_size = clampi(font_size/3, 8, 20)` + helper baru `label_nama()`
  (font 26, putih, tanpa outline). Player + NPC pakai `label_nama()`.
- Label nama hilang bila kamera > 28 m (player.gd + npc.gd).
- Papan lahan & penanda misi tetap dirapikan (outline kontras) — ikon "!"
  emas kini outline GELAP, label papan hijau gelap outline TERANG.
- M2: "Papan Tulis Surau" → "Smartboard Surau" (materi ikut diubah).
- Bukti: foto close-up nama siang + malam + NPC (label kecil, bersih,
  terbaca di langit terang maupun gelap).

## 3. Papan tulis Surau dihapus — SELESAI
- `_papan_dinding()` + pemanggilannya dihapus dari
  `scripts/interior_surau.gd` (tidak ada papan tulis lain di dalam Surau).
- Smartboard TETAP (3 slide + tombol video). Meja sampar, rak kitab, lampu
  hangat, mihrab, sajadah tetap.
- Bukti: foto interior timur (dinding timur kosong) + interior barat
  (smartboard), cek logika "PapanDinding TIDAK ADA".

## 4. Map tanpa pagar, luas, gunung + sawah — SELESAI
- `MAP_HALF` 56 → **400.0** (tanah 800×800 m), `RESPAWN_LIMIT` DIHAPUS,
  pagar luar + cek batas di `main.gd` DIHAPUS (hanya jatuh y < −5 yang
  respawn). Pemain dites jalan ke (100,100) dan (300,0) tanpa diteleport.
- 10 gunung low-poly di kejauhan (radius 330–370 m, tinggi 60–95 m,
  salju di 4 tertinggi) + area SAWAH di (60,30) ukuran 60×40 m (4×3 petak
  berair + pematang + 24 rumpun padi + gubuk kayu) + jalan ke sawah +
  jalan N-S/E-W diperpanjang + 61 pohon total (+24 ronde 5) + 6 semak +
  4 batu (visual, tanpa collision) + waypoint NPC jauh (sawah, kaki gunung).
- Pagar 4 lahan terkunci TETAP (penanda lahan, bukan batas dunia).
- Performa: mesh sederhana (prisma/kerucut/box), pohon 61, bintang
  MultiMesh 1 draw call — pck cuma naik 144.296 → 158.132 byte.
- Bukti: foto sawah + gunung + cek logika (tidak ada dinding 112 m,
  10 gunung, sawah 46 bagian, pohon baru di (-60,-40)).

## 5. Peta ala GTA — SELESAI
- **Minimap live di HUD** (`MinimapControl`, ui.gd): lingkaran heading-up
  ala GTA V (panah pemain selalu ke atas, dunia berputar), kiri atas di
  bawah label poin/misi (16,96, 190×190 — kiri bawah sudah dipakai
  joystick; bawah-tengah tidak muat di landscape 390 px). Jangkauan ~45 m:
  jalan, Surau, lahan terkunci, peti, NPC, sawah, utara (huruf "U"),
  tujuan misi aktif (dijepit ke tepi + berdenyut bila jauh).
- **Peta penuh**: marker tujuan misi (wajik emas), sawah, gunung,
  zoom **1.0x / 4.0x** (tombol − / ＋ di header; saat zoom berpusat pada
  pemain). Label teks hanya tampil saat zoom > 1.0; label 4 lahan SATU
  baris "NAMA (ambang)" + geser diagonal (Masjid atas, Perpus bawah,
  Kelas kanan-bawah, Asrama kiri-atas). Teks SURAU/Kamu/TUJUAN dihapus
  dari peta (menumpuk di tengah; marker + legenda cukup).
  - Pelajaran dari foto: 1.6x/2.0x DIHAPUS — cluster lahan (~30×43 px)
    jauh lebih kecil dari labelnya, label tetap menumpuk. 1.0x =
    keseluruhan tanpa label, 4.0x = detail dengan label terbaca.
- `main.gd::_data_peta()` kini kirim "yaw", "target" (penanda misi aktif;
  bila di interior → Surau), "sawah_pos", "sawah_size", "gunung";
  `_process()` panggil `_ui.update_minimap()` tiap frame saat dunia tampil.
- Bukti: foto minimap, peta 1.0x (bersih), peta 4.0x (label terpisah).

## 6. Chat elegan ala Mobile Legends — SELESAI
- Tombol "Chat" kecil (64×44) di pojok kanan atas. Ketuk → panel chat
  MLBB: semi-transparan gelap (alpha 0,82), sudut membulat 12, header
  "CHAT PESANTREN" + X, daftar pesan singkat (font 15, maks 5 baris),
  baris input ringkas (LineEdit + tombol Kirim 76×44).
- Panel di **tengah-atas (offset 70)** — BUKAN di bawah layar, teks yang
  diketik tetap terbaca saat keyboard virtual HP terbuka. Lebar maks 520,
  dibatasi 92% viewport (portrait 390 → 359 px).
- Riwayat chat lama di kiri bawah DIHAPUS (pindah ke dalam panel).
  Bubble di atas karakter TETAP seperti sebelumnya. Tutup via X / tombol
  Chat / Escape (klik-di-luar TIDAK menutup — supaya tidak tertutup
  saat mengetik).
- Bukti: foto chat (landscape) + foto chat portrait 390×844 (panel muat,
  overlay "Putar HP" ditutup dulu via `_tutup_rotate_overlay()`).

## 7. Bug kamera di frame lambat — DIPERBAIKI (temuan dari foto)
- `_rig.global_position.lerp(target, delta * 8.0)` di main.gd TIDAK
  dijepit: di frame lambat (delta > 0,125 dtk) bobot > 1 → rig OVERSHOOT
  lalu berosilasi, kamera terbang menjauh dari pemain. Terbukti di foto
  NPC ronde 5 (kamera mendarat di papan selamat datang). Perbaikan:
  `minf(1.0, delta * 8.0)`. Hadap visual pemain (player.gd:342) ikut
  dijepit (`minf(1.0, delta * 10.0)`). Limb/bob dibiarkan (osilasi sudut
  kecil, tidak terlihat).

## Verifikasi
- `--import` exit 0.
- `--check-only` 11/11 script OK.
- Tes logika `test_ronde5.gd`: **70 LOLOS, 0 GAGAL, 1 SKIP** (portrait —
  viewport headless tidak bisa diubah; diverifikasi lewat foto xvfb).
- Smoke headless 600 frame: **0 error** (dijalankan 2×, terakhir pada
  kode final yang sama dengan export).
- Foto bukti (17 file, 960×540, di `~/workspace/pesantren-verse/`):
  subuh, pagi, siang, sore, malam, nama-siang, nama-malam, nama-npc,
  interior-timur, interior-smartboard, minimap, peta, peta-zoom (4.0x),
  chat, chat-portrait, sawah, gunung. (File peta-zoom4.png dari iterasi
  tengah sudah dihapus saat zoom disederhanakan jadi 1.0x/4.0x.)
- File tes dihapus sebelum export (0 tersisa).
- Export: `export/web/index.html` — **pck BARU 158.132 byte sha256
  `97f0359b…eefffe4e`** (ronde 4: 144.296 byte `2f6041b4…`); wasm TIDAK
  berubah (`fc74679e…fa57d0`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…5bb6ba`); worklet 2.973 byte TIDAK berubah
  (`be33985b…c84327bc8`).

## Yang belum sempurna (jujur)
- Langit subuh (05:00) di foto terlihat cukup terang (biru baja) — fase
  subuh di 05:00 sudah 74% menuju pagi; jingga tipis di timur sangat
  halus. Matahari subuh + siang tidak masuk frame foto (di luar FOV
  vertikal kamera) — keberadaannya terverifikasi logika, bukan foto.
- Foto gunung: kamera terlalu dekat ke pemain (spring memendek karena
  menabrak tanah saat pitch ke atas) — gunung tetap terlihat di latar
  (juga jelas di foto sawah/subuh/pagi/siang).
- Foto sawah: komposisi terhalang gubuk di tengah (sawah tetap jelas di
  kiri-kanan). Tidak diulang — bukti cukup.
- Di foto interior-smartboard, label "TERKUNCI" (penanda misi M2) melayang
  di atas smartboard — itu penanda misi, bukan cacat; hilang setelah M1
  selesai.
- Verifikasi visual dari URL live BELUM dilakukan — Damar deploy dulu,
  lalu retest browser + tes HP Mas (seperti biasa).
- Karakter game masih primitif ronde 4 (sarung checker). Model Blender
  Bima: v5 DITOLAK Mas 21:42 WIB ("Jelek anjir"), v6 (sculpt) sedang
  dibangun — swap model tetap ronde terpisah setelah Mas acc.

## File yang diubah (ronde 5)
- Baru: `scripts/langit_dinamis.gd`, `RONDE5-STATUS.md` (ini).
- Diubah: `scripts/pesantren_builder.gd` (MAP_HALF 400, gunung, sawah,
  pohon, langit), `scripts/main.gd` (batas luar hapus, data peta, minimap,
  clamp rig), `scripts/ui.gd` (MinimapControl, PetaControl zoom/target/
  sawah/gunung/label, panel chat MLBB, Escape tutup chat),
  `scripts/palette.gd` (label tanpa outline + label_nama),
  `scripts/player.gd` + `scripts/npc.gd` (label nama + culling 28 m +
  clamp hadap), `scripts/mission_data.gd` (M2 → Smartboard),
  `scripts/interior_surau.gd` (papan dinding hapus, lampu grup).
- Dihapus sebelum export: `test_ronde5.gd`, `foto_ronde5.gd`,
  `foto_perbaikan.gd`, `smoke_ronde5.gd`.
