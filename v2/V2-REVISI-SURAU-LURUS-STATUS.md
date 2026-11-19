# Revisi Surau Lurus — Status (Rangga, 17 Nov ~23:20 WIB)

Keputusan Mas (17 Nov ~22:51 WIB): **"Surau lurus aja. Jangan miring.
Biar matahari yg menyesuaikan dg arah barat. Surau lurus seperti masjid."**

## 1. Koreksi arah — lurus = −90°, BUKAN 0° (temuan 23:15 WIB)

Asumsi awal (salah): muka depan GLB ada di sisi +Z (seperti primitif
v1), jadi lurus = rotasi 0°, pintu (0,−6). Revisi 0° itu sempat
selesai (tes 19/19, foto R1/R2/R3, export pck `fb8b947e…`) — TAPI
foto R1 menunjukkan dinding samping (3 jendela + wudu), bukan muka
depan. Penyelidikan (dump node GLB, `skrip/dump_surau.gd`):

- Muka depan GLB Bima (portal + pintu + serambi + plakat
  مصلى الإخلاص) ada di sisi **LOKAL +X** — sesuai KONSEP-SURAU.md
  ("pintu menghadap timur/jalan", denah 20 T-B × 16 U-S m).
- Rotasi 0° membuat pintu menghadap **timur ke tembok x=14**
  (serambi menembus tembok 0,7 m) dan pemain selama ini "masuk"
  lewat jendela dinding selatan, bukan pintu.
- **−90°** memutar +X lokal ke +Z dunia (selatan): pintu di
  **(0,−3.8)** menghadap spawn/plaza. Bangunan tetap lurus
  (sejajar sumbu), jejak jadi **16 (T-B) × 20 (U-S) m**:
  dinding depan z=−4, belakang z=−24.

## 2. Yang diubah (hanya proyek v2 — v1 tidak disentuh)

| File | Perubahan |
|---|---|
| `scripts/pesantren_builder.gd` | `SURAU_ROTASI_DEG` 0.0 → **−90.0**; `surau_pintu()` ditulis ulang dari frame lokal GLB (pintu lokal (10.2,0,0); keluar = R·+X; sumbu = R·+Z; jangkar lama tidak dipakai); collision 5 segmen ditulis ulang dalam koordinat lokal GLB (celah 2,4 m di muka depan); `SandalLuarSurau` → lokal (11.7, 0, 0.8) = dunia (−0.8,−2.3) |
| `scripts/main.gd` | Default `_outdoor_door` (0,−3.8), `_outdoor_exit` (0,−2.3); rumah luar Kyai → (−3.5,−2.0) rumput barat serambi (sekaligus samakan `_npc_rumah` yang masih (−4.8,−4.8) dari Ronde 20); komentar rute + koridor diperbarui |
| `scripts/jalan_ronde22.gd` | Segmen utara dipendekkan: z −200..−25 (pusat −112.5) — ujung 1 m di utara dinding belakang z=−24; **taji `JalanNS_Surau` DIHAPUS** (tangga serambi z −0,5..+0,7 mendarat langsung di jalan E-W) |
| `scripts/langit_dinamis.gd` | TIDAK diubah (angka K_MATAHARI sudah benar: terbenam 252° = barat) |
| `scripts/interior_surau.gd` | TIDAK diubah (mihrab/kiblat dalam tetap −25° / 295°) |
| `scripts/ui.gd` (peta) | TIDAK diubah — poligon Surau sudah generik terhadap rotasi (kini tergambar 10×12 m) |
| `skrip/test_v2.gd` | 23 cek (tambah: daun pintu di muka selatan + terbuka ±110°, sandal, utara jalan berakhir −25, tanpa taji) |

## 3. GLB pintu terbuka (Bima, 23:05 WIB) — sudah masuk proyek

- `model-3d/surau/surau-v2.glb` baru (1.356.812 B, sha
  `626f4aec…`) disalin ke `godot-dunia/models/surau-v2.glb`
  (sha cocok); GLB lama (pintu tertutup) dibackup sebagai
  `model-3d/surau/surau-v2-pintu-tertutup.glb` (sha `ed35eea9…`).
- Cache import `.scn` dihapus lalu di-regenerate
  (`--headless --editor --quit`) — pelajaran: run headless biasa
  TIDAK reimport otomatis; hapus `.scn` tanpa reimport membuat
  GLB gagal dimuat (2 cek gagal sesaat, lalu 19/19 setelah reimport).
- Daun pintu `SR_Pintu_Kiri/Kanan` di dunia: (−1.97/1.97, 1.8,
  −3.8), rotasi −110°/+110° — **pintu TERBUKA di muka selatan**,
  dicek tes + foto.

## 4. Verifikasi

**Tes headless 23/23 LULUS** (`skrip/test_v2.gd`, exit 0):
GLB ada+bermesh, GLB_* 92, spawn (−4,14), pintu (0,−3.8),
rotasi −90, frame keluar selatan / masuk utara, daun pintu di
muka selatan + terbuka ±110°, sandal (−0.8,−2.3), interior
tetap −25°, frame dalam keluar 205, jalan N-S x=0 + utara
berakhir −25 + tanpa taji, matahari 17:00 di barat (azim 252),
NPC ≥ 5, jalan maju 1,20 m, teleport MASUK (koridor lurus) +
KELUAR (koridor dalam) jalan.

**Foto** (`v2/foto-revisi-surau-lurus/`):
- `R1-spawn-surau-depan.png` (BARU, 23:17) — dari spawn: portal
  lengkung + kisi emas, plakat مصلى الإخلاص, serambi + tiang,
  **pintu TERBUKA** (interior + saf terlihat), menara di kiri
  (barat-daya), jalan lurus ke tangga serambi. ✅
- `R2-atas-lurus-90.png` (BARU, 23:18) — dari atas: jejak
  16×20 m, lurus sejajar sumbu, kubah di tengah. (Catatan: kamera
  top-down `look_at` dari atas tegak membuat orientasi gambar
  terputar — bukan masalah game; tes + R1 yang membuktikan arah.)
- `R3-matahari-1700-barat.png` (23:03, tetap berlaku) — jam 17:00
  dari depan pintu: senja oranye di barat, bayangan panjang ke
  timur, bola lampu jalan menyala. Matahari TIDAK diubah.
- `R1-spawn-surau-lurus.png` + `R2-atas.png` (23:01) = arsip
  orientasi 0° yang SALAH (dinding samping) — jangan dipakai.
- `R1-pintu-dekat.png` (23:07) = arsip yang membuktikan kekeliruan
  0° (yang terlihat jendela berkisi, bukan pintu).

## 5. Export web ulang (23:18 WIB)

- Perintah: `--headless --path . --export-release "Web"` — EXIT 0 (~7 dtk).
- `v2/export/web/index.pck`: **21.473.392 B**,
  sha256 `708779bd2883d12bb09c05ddd9de0cfee3d030116115f11e3b2cc2ffd35eb77b`
  (alpha: 21.446.948 B `eb20e7a9…`; export 0° yang salah:
  21.461.560 B `fb8b947e…` — keduanya SUDAH tidak berlaku).
- `index.html` 5.538 B (mentah, belum patch); `index.wasm`
  39.514.754 B sha `fc74679e…` (SAMA seperti alpha — engine
  tidak berubah); `index.audio.position.worklet.js` ada.
- Staging `v2/export/web-pages/` masih berisi file ALPHA
  (pck `eb20e7a9…`) — **Damar perlu staging ulang** (salin pck
  baru + chunk wasm + patch index.html seperti deploy alpha)
  lalu deploy ulang ke https://pesantren-verse-v2.pages.dev
  (link alpha sama, tidak berubah). v1 production tidak tersentuh.

## 6. Catatan terbuka / tindak lanjut (bukan blocker deploy)

1. **Peta Gilang**: persegi Surau di peta v2 (20×16, menjorok
   sampai z=−22) perlu jadi 16×20 (menjorok sampai z=−24);
   celah ke plot Taman Surau (0,−38) jadi 6 m (dulu 8 m).
   Peta di game (ui.gd) SUDAH benar otomatis.
2. **Wudu GLB** (bak + keran) kini di sudut barat-laut
   (belakang bangunan) — dulu di sisi selatan. Follow-up
   Bima: pindah ke sisi selatan dekat pintu, atau biarkan
   (masterplan sudah punya gedung Wudhu terpisah di (−16,−8)).
3. **Lantai serambi** (±0,25 m di atas tanah, tanpa collision):
   kaki pemain sedikit masuk ke lantai saat melintas serambi
   menuju pintu — kecil, hanya sepintas sebelum teleport.
4. **Integrasi lighting Cahya** (`scripts/pencahayaan.gd`,
   satu baris di main.gd) BELUM masuk export ini — masih
   menunggu keputusan Xam/Cahya; modulnya sudah ada di proyek
   tapi belum di-wire.
5. Mihrab bawaan GLB (interior dasar) kini di dinding utara —
   tidak berpengaruh ke sholat: ruang sholat yang dipakai
   pemain adalah interior terpisah (kiblat 295° tetap).
