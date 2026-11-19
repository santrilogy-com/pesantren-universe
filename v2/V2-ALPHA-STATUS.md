# v2 ALPHA — STATUS (Rangga, 17 Nov 2026 ~22:52 WIB)

**Metode: CLONE v1 lalu rombak** (perintah Mas 22:17 — bukan bangun dari nol).
**Target: ALPHA bisa dimainkan di browser sebelum 00:00. Status: EXPORT SIAP, menunggu deploy Damar.**

## 1. Clone
- `cp -a ~/workspace/pesantren-verse/godot-dunia/ → ~/workspace/pesantren-verse/v2/godot-dunia/` selesai 22:24 WIB, penanda `v2/CLONE-SELESAI.txt` (22:26).
- Verifikasi: diff -rq (kecuali .godot/export) exit 0, 91 file identik. Folder v1 TIDAK disentuh sesudahnya.
- Proyek dari-nol sebelumnya diarsipkan ke `v2/arsip-bangun-dari-nol/` (scripts + main.tscn + project.godot + skrip) — daftar posisi GLB-nya dipakai lagi di rombak ini.
- `export/` v1 (build lama) dihapus dari clone supaya tidak tertukar. Nama proyek: "Pesantren Verse v2". Export path: `v2/export/web/index.html`.

## 2. Rombak visual (hanya `scripts/pesantren_builder.gd`, clone saja)
- **Surau primitif → `surau-v2.glb`** di `SURAU_PUSAT` (0,0,-14) putar -25° + collision dinding tak terlihat 5 segmen (celah pintu 2,4 m tetap ada) + node `SandalLuarSurau`. Logika pintu/teleport (`surau_pintu()`) TIDAK diubah.
  - CATATAN: peta Gilang tulis Surau (0,-12) — itu JANGKAR LOKAL (`SURAU_JANGKAR_LOKAL`); pusat dunia live v1 = (0,-14). GLB dipasang di pusat live supaya pintu tetap sejajar koridor teleport.
- **61 pohon primitif → GLB**: dekat bangunan/jalan = pohon hias (3,5 m); jauh/zona penyangga = pohon rindang (8,5 m). Collision batang dipertahankan.
- **Sawah primitif 60x40 → `sawah.glb`** (20x12) di pusat yang sama (60,30).
- **Tambahan `_lingkungan_glb`**: taman (0,28), gubuk santri (26,30) + (90,10), pagar bambu keliling taman (10 segmen), pagar bata tepi utara Lapangan Putra (8 segmen, z=39), 10 pohon rindang zona penyangga.
- **Sistem v1 TIDAK disentuh**: login, misi, sholat, chat MLBB, peta, NPC, UI, interior (Surau/Cangkruk/Musholla), tembok, jalan.
- **Posisi bangunan v1 DIPERTAHANKAN** (Masjid Besar, Kelas, Asrama, dll. tetap di tempat v1) — pergeseran U1–U5 di peta Gilang DITUNDA ke iterasi berikutnya karena beberapa bangunan punya logika pintu/rute yang terikat koordinat (mis. Kelas Putri + KonekSpawn). Rombak ini = "ganti baju", bukan pindah rumah.

## 3. Tes headless — 10/10 LULUS
`skrip/test_v2.gd` (godot --headless, 3,5 dtk, exit 0):
Surau GLB ada + bermesh; Sawah GLB ada + bermesh; GLB_* = 92 (≥90); SandalLuarSurau ada; spawn putra (-4,14); pintu Surau (-3.38,-6.75); NPC ≥5; jalan maju 1,20 m / 30 frame lewat joystick.

## 4. Foto (xvfb-run) — diverifikasi Rangga
- `v2/foto-alpha/F1-spawn-surau.png` — BAGUS: dinding putih, kubah zamrud, menara, 3 lengkung selatan. **Catatan: pintu GLB tampak TERTUTUP** (panel cokelat), beda dengan primitif yang daunnya terbuka. Teleport tetap jalan (celah collision ada), tapi pemain tampak menembus pintu sesaat sebelum teleport. Follow-up: Bima buka daun pintu / hapus panel pintu di GLB.
- `v2/foto-alpha/F2-pemain-spawn.png` — BAGUS: santri primitif di spawn, NPC Faris, taman + pagar bambu + papan "LAHAN PERPUSTAKAAN & TAMAN" terbaca rapi, gubuk pos jaga, gunung.
- `v2/foto-alpha/F3-atas.png` — BAGUS: Surau miring -25°, tembok x=14 + kampus putri, sawah biru (60,30), pohon tersebar, feed MLBB "Faris: Assalamu'alaikum!" muncul, HUD lengkap (Poin, Misi 1, Kartu Santri/Peta/Chat/Aksi/Suara/Layar Penuh, joystick, Reset Posisi).

## 5. Export web — SIAP (22:52 WIB, sebelum deadline 23:10)
- `~/workspace/pesantren-verse/v2/export/web/index.html` — export-release EXIT 0 (~7 dtk).
- `index.pck` **21.446.948 B**, sha256 `eb20e7a9d2a0fcb5e07ab83c4dfce0a0008a7c117ee85c2c9ac3c9cfff88a780` (besar karena 8 GLB + tekstur; v1 1,67 MB).
- `index.wasm` 39.514.754 B, `index.js` 279.815 B, `index.audio.position.worklet.js` 2.973 B (ada).
- `index.html` mentah: 2 `<script>` (template standar Godot) — patch wasm-fetch (script ke-3) seperti biasa ditambahkan proses deploy Damar.

## 6. Serah terima ke Damar (JANGAN deploy sendiri — Rangga tidak deploy)
- Deploy dari `v2/export/web/` ke Pages (jalur v2, JANGAN timpa live v1).
- Pck 21,4 MB — unduhan pertama lebih berat dari v1; kalau lambat di HP Mas, kabari Rangga (opsi: kompres tekstur GLB).

## 7. Yang belum (di luar ALPHA malam ini)
- Pintu Surau GLB tertutup (lihat §4) — Bima.
- Pergeseran bangunan U1–U5 peta Gilang — butuh pemindahan logika pintu/rute, bukan malam ini.
- Karakter 3D final — tim Bima + Kirana (placeholder primitif v1 di ALPHA).
- Retest browser asli / HP Mas — setelah deploy Damar.
