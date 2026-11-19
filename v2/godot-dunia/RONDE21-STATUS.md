# RONDE 21 — STATUS (Tim Maps: Gilang)

**Status: RENCANA — MENUNGGU ACC MAS (pilih Opsi A atau B). JANGAN bangun di game dulu.**
Revisi peta 16 Nov ~21:49 WIB (keputusan Mas: "Ok acc desainnya.. tapi untuk letak bangunan harus sesuai maps ini.. ini jaraknya kalau bisa lebih jauh antara pondok putra dan putri. Terus butuh tembok pemisah.. ini santri putra masih bisa masuk pondok putri..").

Detail lengkap + tabel jarak: `maps/ROADMAP-MAPS.md` (§ "Perubahan — revisi 16 Nov ~21:49 WIB", §2, §3, §7 butir 7/14/15/17, §8). Miniatur peta: artifact `miniatur-peta-pembangunan-pondok-putri` (sudah diperbarui ke layout revisi, toggle Opsi A/B).

## Keputusan Mas yang mendasari ronde ini
- Desain arsitektur Surau + Musholla **DI-ACC** (Arsa) — Musholla baru dibangun sesuai desain ACC (12×10 m, 1 kubah kecil, tanpa menara, serambi kayu).
- Jarak putra–putri **lebih jauh** dari rencana 19:42 (Musholla 62,−24 — DIBATALKAN).
- **Tembok pemisah solid** (bukan pagar) — santri putra tidak boleh bisa masuk pondok putri dengan cara apa pun.

## Opsi A — Terjauh (REKOMENDASI Tim Maps)
Musholla Ar-Raudhah **(134,−24)**; Cangkruk Putri (128,−12); Kelas Putri (130,0); Asrama Putri (152,0); Kantor Ustadzah (150,−28); Madrasah (152,−12); Studio (166,−12); Lapangan Putri TETAP (48,62); spawn putri (130,14); pos jaga Timur Laut (160,−35); jalan internal N–S x=142 (z 0..−20, setapak ke pintu selatan Musholla (134,−20)).
Jarak: Surau → Musholla 134,5 m pusat / 118 m dinding; gerbang (14,0) → Musholla 122 m (≈20 dtk); tembok → Musholla 114 m; spawn putri → Musholla 38 m (≈6 dtk).

## Opsi B — Timur-Jauh
Musholla Ar-Raudhah **(98,−24)**; Cangkruk Putri (92,−12); Kelas Putri (94,0); Asrama Putri (116,0); Kantor Ustadzah (114,−28); Madrasah (116,−12); Studio (130,−12); Lapangan Putri TETAP (48,62); spawn putri (94,14); pos jaga Timur Laut (124,−35); jalan internal N–S x=106.
Jarak: Surau → Musholla 98,7 m pusat / 82 m dinding; gerbang → Musholla 87 m (≈15 dtk); tembok → Musholla 78 m; spawn putri → Musholla 38 m (≈6 dtk).

## Spesifikasi tembok pemisah (berlaku kedua opsi)
- **Garis:** lurus x=14, z −60..+16 (76 m). Menggantikan pagar kayu Ronde 20 (dibongkar total).
- **Bentuk:** solid TERTUTUP, tinggi 3 m, tebal 0,4 m, tidak tembus pandang; plester krem #F2EAD6 + lis emas di puncak + fondasi batu abu-abu. Collision penuh (StaticBody) di sepanjang garis.
- **Gerbang:** satu-satunya bukaan, di (14,0); bukaan 4 m (z −2..+2) + 2 pilar batu (14,±2) + balok gapura + atap piramida zamrud + label GERBANG dua sisi; **pintu TERTUTUP (daun pintu kayu) + barrier collision penuh melintasi bukaan** — celah visual, bukan celah lewat.
- **Pos satpam:** 3×3 m di (17,5) + satpam NPC.
- **Aturan keras `_cek_batas` (main.gd):** toast bila santri dalam 1,5 m dari tembok; santri putra di (x>14 DAN z<16) → toast + didorong balik ke posisi legal terakhir; cermin untuk santriwati (x<14 DAN z<16 → didorong balik ke timur). Pengecualian peran: Pengasuh + musyrif/musyrifah + Keamanan boleh lintas. NPC mengabaikan barrier. Kawasan selatan (z≥16) tetap bersama.
- **Mengapa x=14 (bukan x=2.5):** belokan pagar lama (x=9) dibuat untuk Surau lama (dinding timur x=7,55); Surau baru (20×16 m, tetap −25°, `SURAU_ROTASI_DEG`) menjorok sampai x≈12,4 — belokan x=9 akan memotong bangunan dan jatuh di atas jalan E-W. Tembok lurus x=14 membersihkan Surau baru (jarak 1,56 m).
- **Celah yang ditutup:** pagar Ronde 20 hanya z −60..+16 tanpa penegakan keras — santri bisa memutar lewat ujung utara (z<−60) atau lewat selatan (z>16 lalu ke utara). Tembok + aturan keras menutup keduanya.
- **Dampak Masjid Besar (Fase D):** tembok lewat 4 m di timur plot masjid — masjid utuh putra, rencana partisi DIBATALKAN; Masjid Putri terpisah (kandidat A (134,−40), B (98,−40)).

## Checklist Ronde 21 (dikerjakan Raka setelah ACC)
- [ ] BONGKAR: pagar kayu x=2.5 + gerbang (2.5,0) + pos satpam (5.5,5); Musholla lama (18,−24) + interiornya; jalan lama ke musholla (x≈11..16, z −9..−20, kembali rumput); pohon (14,−6) → (18,−6).
- [ ] BANGUN: tembok x=14 + gerbang (14,0) + pos satpam (17,5); Musholla baru (desain ACC) + interior di posisi opsi terpilih; Cangkruk Putri baru; jalan internal baru (x=142 / x=106); `_cek_batas` keras (x≥14).
- [ ] PINDAH: spawn putri (4,14) → (130,14) / (94,14); pos jaga Timur Laut (40,−35) → (160,−35) / (124,−35).
- [ ] KEMBALI JADI PENYANGGA: plot lama Musholla (18,−24), Kelas Putri (16,0), Cangkruk Putri (12,−12) + rencana 19:42 — kebun/taman, tanpa bangunan.
- [ ] Verifikasi: tes headless lengkap (termasuk asersi baru: tembok utuh + gerbang tertutup + `_cek_batas` keras kedua arah + spawn putri baru); audit jarak; smoke 600 frame 0 error 0 NaN; foto bukti (tembok + gerbang + jalan internal + musholla baru); export pck (TIDAK deploy — Damar setelah verifikasi Xam).

## TIDAK termasuk ronde ini
- Surau baru (desain ACC) — sedang dibangun Raka terpisah di (0,−12), footprint/interior sama.
- Perbaikan figur Ustadzah (Kirana, SELESAI 16 Nov ~21:52 WIB, tes 127/127) — ada di source (`scripts/player.gd`), ikut export gabungan.
- Deploy jalan + lampu (pck 1.574.360 byte sha256 `8343a6dd…`, berisi pagar x=2.5) — DITAHAN sampai peta revisi ini di-ACC; export Ronde 21 menggantikannya (pagar tidak pernah deploy).

## Catatan cek lapangan (Tim Maps, dari kode)
- Tidak ada pohon di footprint bangunan baru A maupun B (margin ≥1,5 m); tidak ada bangunan baru menabrak sawah (x 30..90, z 10..50) atau kebun/kolam rencana Fase H.
- Konflik masa depan (bukan Ronde 21): pohon (130,−40) 4 m di barat calon Masjid Putri Opsi A (134,−40) — pindah saat Fase D; Opsi B bebas konflik ini.
- Opsi A = batas terjauh yang masuk akal: front kampus (130) masih di jalan E-W (ujung x=160); Studio (166) dilayani jalan internal. Musholla ≥140 akan lepas dari jalan E-W.
