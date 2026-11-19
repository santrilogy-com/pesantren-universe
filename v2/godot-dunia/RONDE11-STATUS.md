# RONDE 11 — Variasi karakter: kulit, kacamata, songkok hitam (16 Nov ~06:30–06:55 WIB, Raka)

**Pemicu:** arahan Mas 16 Nov ~06:00 WIB: *"Karakter harus beda² ya..
bisa kulit, kacamata, kopyah hitam nasional dll."* Scope RONDE 11
(dikerjakan SETELAH export ronde 10, tidak dicampur).

**Aturan:** sistem variasi di `build_visual` (dipakai pemain + NPC) —
tidak ada perubahan logika misi/poin/save. Panel Ganti Baju pemain
ikut ditambah (ternyata MUDAH — pola yang sama seperti baris
koko/songkok/sarung). **TIDAK deploy** — deploy urusan Damar.

## 1. Warna kulit — 3 pilihan

**Yang diubah (`mission_data.gd` `OUTFIT_KULIT`, `player.gd`
`build_visual`):** Terang `#e8b98a` / Sawo Matang `#c68e5e`
(default lama `Palette.KULIT`) / Gelap `#8a5a33`. Warna kulit dari
outfit dipakai kepala + hidung + tangan + kaki (dulu konstanta).
`OUTFIT_DEFAULT` ditambah `"kulit": "#c68e5e"` — tampilan default
pemain TIDAK berubah. Save lama tanpa kunci kulit mendapat default
via `.get()`.

## 2. Kacamata — aksesori opsional

**Yang diubah (`player.gd` `_kacamata()` + `_batang()`):** bingkai
hitam `#171717` (2 lensa kotak 0.11×0.08 di depan mata + jembatan
hidung + 2 gagang ke telinga, total 13 bagian mesh) + lensa tembus
pandang (alpha 0.35, `TRANSPARENCY_ALPHA`) supaya mata tetap
terlihat. Node "Kacamata" selalu dibuat, hanya `visible` kalau
outfit `"kacamata": true`. **Jebakan yang dihindari:** `_lembutkan()`
dulu mengganti SEMUA material dengan `Palette.mat` (opaque) — lensa
akan jadi kaca gelap menutupi mata. Kini `_lembutkan` melewatkan
bahan transparan.

## 3. Kopyah hitam nasional — hitam pekat

**Yang diubah (`mission_data.gd`):** songkok Hitam diperdalam
`#2b2b2b` → `#1a1a1a` (hitam pekat) + lis `PeciBand` ikut menggelap.
Bentuk tetap kubah songkok nasional (ronde 10). Save lama yang sudah
memilih Hitam menyimpan `#2b2b2b` — tetap tampil hitam gelap, hanya
tanda ✓ di panel yang tidak cocok sampai dipilih ulang (tidak ada
santri produksi yang terkena: 0 santri).

## 4. Bilal vs Faris vs pemain — beda sekilas pandang

**Yang diubah (`main.gd` `_spawn_npcs`, `npc.gd` `setup` kini terima
outfit lengkap, bukan cuma warna sarung):**

| Karakter | Kulit | Kacamata | Songkok | Sarung |
|---|---|---|---|---|
| **Bilal** | Gelap `#8a5a33` | Ya | Hitam `#1a1a1a` | Biru `#1d4e6b` |
| **Pemain** (default) | Sawo Matang `#c68e5e` | Tidak | Putih `#faf7f0` | Zamrud `#0b6b4f` |
| **Faris** | Terang `#e8b98a` | Tidak | Putih `#faf7f0` | Coklat `#6b3a1d` |

Ketiganya beda warna kulit; Bilal beda juga kacamata + songkok.
(Catatan: contoh brief memakai Bilal = sawo matang — saya pilih
Gelap supaya ketiga pilihan kulit terwakili, satu karakter satu
nada; brief memperbolehkan kombinasi akhir ditentukan Raka.)

**Bukti:** `foto-ronde11/01-trio.png` (ketiganya berdampingan di
depan Surau — beda jelas), `02-bilal-closeup.png` (kulit gelap +
kacamata bingkai hitam + songkok hitam pekat), `03-faris-closeup.png`
(kulit terang + tanpa kacamata + songkok putih),
`04-pemain-closeup.png` (sawo matang, tengah-tengah keduanya).

## 5. Panel Ganti Baju pemain — kulit + kacamata (MUDAH, jadi dikerjakan)

**Yang diubah (`ui.gd`, `main.gd` `_on_outfit_dipilih`):** baris
"Kulit" (3 swatch, pola sama seperti koko/songkok/sarung, tanda ✓
jalan) + baris "Kacamata" (tombol Pakai/Lepas, kunci
`kacamata:ya`/`kacamata:tidak`, sinyal `outfit_dipilih` membawa
"ya"/"tidak", `main.gd` mengubah jadi bool sebelum disimpan).
Pilihan langsung diterapkan via `terapkan_outfit` + disimpan seperti
biasa.

## 6. Bug laten yang ditemukan + diperbaiki (bonus)

`terapkan_outfit` memakai `get_node_or_null(nama)` — nama seperti
"BahuKiri"/"LenganAtasKiri" TIDAK PERNAH ketemu karena mereka anak
dari pivot lengan (bukan anak langsung visual). Akibatnya ganti koko
dulu hanya mewarnai torso + kerah, **lengan tetap putih**. Kini
memakai `find_child(nama, true, false)` (rekursif) — lengan ikut
berubah warna. Teruji: lengan `#cfe8d0` setelah ganti koko Hijau
Muda, kembali `#faf7f0` setelah reset.

## Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: `player.gd`, `npc.gd`, `main.gd`, `ui.gd`,
  `mission_data.gd`, `test_ronde11.gd`, `test_ronde11_ui.gd`,
  `foto_ronde11.gd` — semua lolos (1x parse error di tengah jalan:
  inferensi tipe `cx` dari loop untyped — diperbaiki dengan anotasi
  `float` eksplisit + helper `_batang`).
- **Tes headless `test_ronde11.gd`: 29/29 LOLOS, exit 0** (opsi data
  7, Bilal 5, Faris 3, pemain 2, beda 2, kulit di tangan/hidung/kaki
  3, `terapkan_outfit` live 7 — termasuk lengan ikut ganti koko).
- **Tes headless `test_ronde11_ui.gd`: 12/12 LOLOS, exit 0** (tombol
  kulit ×3 + kacamata ×2 + songkok hitam ada; ✓ di kulit Gelap +
  kacamata Pakai; sinyal kacamata=tidak + kulit Terang benar).
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR.**
- **4 foto bukti** di `~/workspace/pesantren-verse/foto-ronde11/`
  (960×540, xvfb-run + opengl3, siang via `LangitDinamis.debug_jam`
  =10.0 — hanya di skrip foto, game tidak diubah). Semua ditinjau
  satu per satu.
- **Export `export/web/`:** pck BARU **988.928 byte** sha256
  `e327d052a80cf461…` (tumbuh 3.600 byte dari ronde 10 — geometri
  kacamata + kode baru); wasm TIDAK berubah sha256 `fc74679e…`;
  index.js tidak berubah sha256 `33c94cb3…`; worklet ada (2.973
  byte). File tes/foto dihapus sebelum export (pck bersih).
  **TIDAK deploy** — deploy urusan Damar.

## Belum sempurna / jujur

- Kacamata primitif: bingkai kotak (bukan bulat — Godot tidak punya
  primitif torus), lensa kotak tembus pandang. Dari depan terbaca
  jelas sebagai kacamata; dari samping, gagang lurus tipis.
- Mulut (`#7a4a30`) di kulit Gelap kontrasnya tipis (hanya sedikit
  lebih gelap dari kulit) — masih terbaca, tapi kalau Mas mau, mulut
  bisa digelapkan untuk kulit gelap.
- Panel Ganti Baju: tombol kacamata + baris kulit teruji headless
  (sinyal + tanda ✓), TAPI belum diklik di browser live — retest
  browser ronde 11 harus mengkliknya (buka panel → pilih kulit Gelap
  → Pakai kacamata → karakter berubah + tersimpan).
- NPC santriwati (karakter perempuan) belum ada — itu Tim Karakter
  fase berikutnya (butuh field gender di registrasi, lihat
  KURIKULUM.md §4.4). Sistem variasi ini sudah siap dipakai untuknya
  (kulit + kacamata + songkok tinggal di outfit).
- Retest browser ronde 9 masih jalan saat ronde 11 dibuat; retest
  browser ronde 10 + 11 (salaman kanan, smartboard bersih, kiblat,
  variasi karakter) menunggu deploy Damar + penilaian Mas di HP
  (juri akhir).
