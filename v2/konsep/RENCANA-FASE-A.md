# RENCANA FASE A — Fondasi misi lokal (Draf v5.2 DI-ACC Mas 18:32 WIB)

**Koordinator:** Raka. **Acuan:** `DRAF-ALUR-MISI.md` v5.2 (557 baris) + `ROADMAP-ALUR-MISI.md` (Fase A, A1–A9).
**Aturan:** desain dulu untuk semua UI (mockup → ACC Mas → implementasi); JANGAN deploy; JANGAN sentuh `scripts/ui.gd`, `scripts/gaya_tombol.gd`, `scripts/virtual_joystick.gd`, `scripts/ikon_hud.gd` (wilayah Tara — perbaikan kontras HUD v3 masih berjalan); pertanyaan §9 terbuka JANGAN dikarang.

## Urutan A1–A9 + pemilik + status

| # | Item | Pemilik | Status / prasyarat |
|---|---|---|---|
| A1 | Mesin ruang belajar: kuis multi-soal (1/5/10) + tes naik Bagian (lulus ≥8/10) + gating Bagian + progres per Bagian di Kartu Santri | Arka | **GELOMBANG 1** — logika murni di file baru `scripts/mesin_kuis.gd`; UI kuis di `ui.gd` (Tara) TIDAK disentuh — wiring UI menyusul setelah HUD mendarat |
| A2 | 27 modul lanjutan (N1.2–N4.T) + bank soal dari ebook Nahwu | — | **TERTAHAN konten** — modul menunggu tashih Mas (Modul 01 sudah dikirim, 5 pertanyaan tashih belum dijawab; cron malam jalan 21:43). Gelombang 2: skema data + loader + port Modul 01 SETELAH tashih |
| A3 | Peti dinamis 4 warna + 9 slide smartboard Bag. 2–4 | — | **TERTAHAN butir 4** (satu peti dinamis vs 4 peti fisik — belum diputuskan Mas). Slide Bag. 2–4 juga menunggu tashih. Gelombang 2 setelah butir 4 terjawab |
| A4 | Gerbang ruang belajar (lokal): kuis kaidah 10 soal ≥8/10; badge "Bisa Baca Kitab Kuning" (ruang belajar selesai + gerbang lulus + baca 3 bab + setoran langsung Fase C) | — | **GELOMBANG 2** — butuh A1 (mesin kuis). Syarat badge (b) baca 3 bab butuh jejak baca dari reader (ui.gd) → tracker disiapkan, hook menyusul |
| A5 | Tangga gelar (lokal): 8 tier Thalib al-'Ilm → **'Santri Senior'** + divisi + bintang; tampil di Kartu Santri + label nama | Nusa | **GELOMBANG 1** — logika di file baru `scripts/gelar.gd`; tampil di Kartu Santri (ui.gd) menyusul. Nusa pemilik SEMUA penambahan kunci `save_data.gd` gelombang 1 |
| A6 | Perlengkapan Lapangan Putra (gawang + garis + bola + lampu) | — | **DITUNDA** (keputusan Mas 18:22 'Nanti' — olahraga) |
| A7 | Marker/petunjuk Ustadz di peta + sistem tugas dari Ustadz | — | **GELOMBANG 2** — tracker tugas (logika, file baru) + marker peta (ui.gd) menyusul setelah HUD mendarat |
| A8 | Alur santri baru — onboarding (§1A): dialog Ust. Aqsal M + NPC Ust. Sanusi BARU + lokasi random + tes kenaikan di Kantor + loop sampai hatam | Lukman | **GELOMBANG 1 (kerangka)** — `scripts/onboarding.gd` (state machine langkah 1–7) + `scripts/lokasi_acak.gd` (mekanik acak, parameter = konstanta, default = usulan draf). Dialog UI = mockup A9. Wiring spawn di `main.gd` gelombang 2 (satu agen saja, jangan tabrakan) |
| A9 | Persyaratan tampilan UI misi (§2.9): mockup UI percakapan, Ruang Belajar, tes kenaikan, panel misi — enak dibaca, tidak primitip, nuansa 3D style game | Sinta | **GELOMBANG 1 (mockup dialog dulu)** — skrip baru `v2/konsep/desain-ui-misi.py` (pola `desain-hud-v3.py` Tara — BACA saja, jangan ubah); hasil di `v2/foto-misi/`. Mockup lain (Ruang Belajar, tes, panel misi) menyusul setelah dialog |

## Peta kepemilikan file (gelombang 1 — jangan tabrakan)

- **Arka:** BARU `scripts/mesin_kuis.gd` + BARU `skrip/test_mesin_kuis.gd` (+ `.tscn`). BACA saja: `mission_data.gd`, `main.gd`, `ui.gd`.
- **Nusa:** BARU `scripts/gelar.gd` + BARU `skrip/test_gelar.gd` (+ `.tscn`). BOLEH ubah `scripts/save_data.gd` HANYA tambah kunci baru ke `default_data()` (wajib — `load_data` hanya menyalin kunci yang ada di sana; pelajaran bug flag pop-up Tara).
- **Lukman:** BARU `scripts/onboarding.gd` + BARU `scripts/lokasi_acak.gd` + BARU `skrip/test_onboarding.gd` (+ `.tscn`). TIDAK BOLEH ubah file yang sudah ada. Kunci save dibaca defensif (`data.get("onboarding", {})`) — Nusa yang menambahkan default-nya.
- **Sinta:** BARU `v2/konsep/desain-ui-misi.py` + BARU `v2/foto-misi/*.png`. TIDAK BOLEH ubah kode game apa pun. BACA saja `v2/konsep/desain-hud-v3.py` (pola) + `v2/foto-hud/hud-v3-idle.png` (latar).
- **Yang lain (Raka):** wiring `main.gd` gelombang 2; koordinasi; laporan ke Xam.

## Dependensi yang menahan (bukan ditebak)

1. **HUD Tara** — `ui.gd` dkk. terkunci sampai perbaikan kontras mendarat. Dampak: wiring UI kuis (A1), tampil gelar di Kartu Santri (A5), marker peta (A7), jejak baca reader (A4), semua implementasi UI (A9) — semuanya disiapkan sebagai modul/hook, dipasang setelah HUD bebas. **Perubahan pemetaan 18:33 WIB:** tombol □ klaster diamond = **Chat** (bukan Kamera); Kamera pindah ke menu atas. Mockup A9 WAJIB pakai pemetaan baru; Tara merevisi mockup kontrasnya sendiri.
2. **§9 butir 19 (kantor putra)** — kantor putra BELUM ADA di peta. Tes kenaikan: logika dibangun lokasi-agnostik; venue default sementara = Surau putra (0,−14) / Kantor Ustadzah putri (150,−28) — dicatat sebagai SEMENTARA, bukan keputusan. Kontradiksi §6.2 (tes tetap di Surau/Musholla Jenjang 0 vs pindah ke Kantor) dibersihkan di v5.3 begitu butir 19 terjawab.
3. **§9 butir 18 (mekanik random Sanusi)** — aturan refresh + daftar lokasi final + petunjuk samar belum dikunci. Mekanik dibangun dengan parameter konstanta (default = usulan draf: diacak tiap misi "cari Ust. Sanusi" dimulai, dari daftar kandidat §1A) — jelas ditandai "usulan, menunggu butir 18".
4. **§9 butir 22 (onboarding putri)** — Ust. Aqsal M di Surau (area putra) + Ust. Sanusi laki-laki. Gelombang 1 membangun jalur PUTRA dulu; kode distruktur per-gender (NPC + lokasi per gender sebagai konfigurasi) supaya varian putri tinggal diisi begitu butir 22 terjawab.
5. **§9 butir 17 (isi percakapan aturan)** — draf §1A punya garis besar 6 topik. Mockup dialog (Sinta) memakai teks DRAF dari garis besar itu, ditandai "draf, menunggu tashih Mas" — kalimat final ikut kurikulum/tashih.
6. **§9 butir 4 (peti)** — menahan A3. **Butir 20 (hatam)** — konfirmasi saja; loop dibangun per modul sesuai §1A langkah 7 (hatam = selesai 4 Bagian Nahwu Dasar).
7. **Tashih Modul 01** — menahan port konten A2 (5 pertanyaan tashih belum dijawab Mas).

## Gate tiap item selesai

- Tes spesifik item hijau (file `skrip/test_<item>.gd`, pola `test_v2.gd`: `_cek` + hitung lulus/gagal, EXIT 0) + `test_v2` 60/60 regresi (satu gagal pra-ada "Pintu tertutup saat start" sudah dikenal — laporkan bila muncul yang lain).
- Godot 4.7.2: `~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64`; headless: `godot --headless --path . skrip/<tes>.tscn`; bila butuh UI: `xvfb-run -a` tanpa `--headless`. VM 1,5 CPU — jangan jalankan 2 Godot berat bersamaan dengan sengaja; bila tes menggantung >10 menit, laporkan, jangan diulang-ulang.
- Foto bila ada UI (mockup dibaca sendiri 2 ronde seperti Tara).
- JANGAN deploy. Kerja di tree kerja saja.

## Pertanyaan untuk Mas (via Xam — urutan prioritas)

1. **Butir 19** — kantor tes kenaikan putra di mana, atau tes putra tetap di Surau dulu? (menahan venue tes A8)
2. **Butir 18** — lokasi random Sanusi: diacak kapan (tiap misi/hari/sesi)? Daftar lokasi final? Petunjuk samar atau tanpa petunjuk? (menahan wiring randomizer A8)
3. **Butir 22** — onboarding santri putri: Kyai + Sanusi hadir di area putri, atau ada Ustadzah pendamping? (menahan jalur putri A8)
4. **Butir 17** — isi percakapan aturan: daftar aturan final + kalimat dialog, atau cukup topiknya (detail ikut tashih)? (menahan teks dialog A8)
5. **Butir 4** — peti: satu peti dinamis atau 4 peti fisik? (menahan A3)
- Nanti (Fase B/C): butir 3 (khataman pindah gedung), 5 (sholat teleport), 6 (video smartboard), 7 (voting), 8 (jalur poin — Saka), 9 (syarat lamaran).
