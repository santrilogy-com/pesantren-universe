# RONDE PERBAIKAN — Item UI Gita (17 Nov 2026)

Koordinator: Raka. Game v1 (`godot-dunia/` saja, v2 tidak disentuh).
**BELUM DEPLOY** — hasil dulu untuk ACC Mas.

## Ringkasan

| Item | Diagnosis akar masalah | Perbaikan | Hasil uji |
|------|------------------------|-----------|-----------|
| 8. Tombol panel mati (Ganti Baju, Tutup Map + Kartu Santri, Reset Posisi) | Bukan sinyal putus / panel menutupi / mouse_filter — semua handler terhubung dan klik bersih BEKERJA. Akarnya: tombol masih `ACTION_MODE_BUTTON_RELEASE` (default Godot 4.7 = 1). Tombol release-mode hanya menyala bila lepas DI DALAM tombol; ketukan HP/browser yang bergeser sedikit lalu lepas di luar = sinyal tidak menyala sama sekali. Terbukti tes klik-seret 120 px pra-perbaikan: Reset `tekan=0` (tidak teleport), zoom+ `idx tetap 0`. | Semua tombol target jadi `ACTION_MODE_BUTTON_PRESS` (menyala saat TEKAN — preseden Ronde 19 untuk swatch warna + kacamata). | Tes klik xvfb 16/16 LULUS — klik bersih + klik seret 400 px semua menyala (Ganti Baju, Tutup dashboard, Reset → teleport ke spawn, zoom ±, Tutup peta, putri). |
| 9. Zoom peta terkunci 1.0x | Kode zoom TIDAK rusak: handler `_peta_zoom_masuk/_keluar` + `PETA_ZOOM [1.0, 2.0, 4.0]` benar; klik bersih pra-perbaikan sudah 1.0→2.0→4.0 normal. Yang mati adalah TOMBOL zoom-nya (akar yang sama dengan item 8: tombol 48 px release-mode, ketukan bergeser = lepas di luar = tidak menyala). | Tombol zoom − / + jadi `ACTION_MODE_BUTTON_PRESS` (item 8). Tidak ada perubahan logika zoom. | Tes klik: + bersih 2.0x → 4.0x, − bersih kembali 1.0x; + seret 400 px tetap 2.0x; putri juga. Label ikut ("2.0x"/"4.0x"). |
| 11. Peta putri cuma tampil area putra | (a) Peta besar selalu membingkai SELURUH dunia 800 m (`half` = 400) di zoom 1.0x — kampus putri (65×74 m) cuma 32 px lebar di peta 660 px (4,9%). (b) `main.gd _data_peta()` TIDAK mengirim `tembok_keliling_garis` / `gerbang_putri_pos`, dan `ui.gd` fallback-nya kosong — tembok keliling + gerbang putri tidak pernah tergambar di peta mana pun. (c) Gedung putri (Kelas/Asrama/Madrasah/Studio/Kantor/Cangkruk Putri/Pos Jaga) tidak digambar sama sekali — hanya Musholla. | `PetaControl.bingkai_peta()`: bila pemain di timur tembok (x > 60), zoom 1.0x membingkai kampus putri (pusat (147.5,−15), setengah 55 m) — kampus putri kini 220 px (33%) di peta 660 px; zoom > 1 berpusat pada pemain. Label tampil di tampilan putri (ruang cukup). Gedung putri digambar (kotak krem + label) dari konstanta `KampusPutri`; jalan internal x=142 digambar; tembok keliling + gerbang putri fallback ke konstanta `TembokPutri` (bukan kosong). Label "GERBANG" selatan putra tidak lagi dijepit ke tepi peta putri. Minimap: fallback yang sama + gedung putri (kotak krem 8×8). | Tes logika headless: bingkai putri pusat (147.5,−15) setengah 55, lebar 220 px ≥ 20%; batas x=60 putra / x=61 putri; putra tidak berubah (pusat 0,0 setengah 400). Foto G5/G6 membuktikan visual. |
| 12. Placeholder password terpotong | Placeholder 50 huruf ("Kata sandi (opsional — kosongkan bila belum diset)") = 431 px pada font 20, sementara field hanya 332 px tersedia (desktop) / 315 px (HP landscape & portrait). Terpotong di SEMUA skala — terukur dengan font game asli (Baloo 2 Bold). | Placeholder dipendekkan: sandi → "Kata sandi" (89/151/267 px di desktop/landscape/portrait — muat semua); IG → "Akun IG" ("Username IG" pun masih 329 vs 315 di portrait); daftar → "Nama santri". Keterangan "(opsional...)" tidak hilang — sudah ada di catatan bawah form. | Tes logika: ketiga placeholder muat di ketiga skala (desktop s=1.5, HP landscape s=0.54, HP portrait s=0.30). Foto G1 (+ G1 portrait) membuktikan visual. |

## File diubah (hanya `scripts/ui.gd`)

- **Placeholder (item 12):** `_ig_input` → "Akun IG"; `_sandi_input` → "Kata sandi"; `_reg_nama_input` → "Nama santri".
- **Action mode PRESS (item 8/9):** `_reset_btn` (HUD); peta: `zoom_out_btn`, `zoom_in_btn`, `x_btn`, `tutup`; dashboard: `x_btn`, `ganti_footer`, `tutup`; misi (pola yang sama): `_misi_x_btn`, `tutup1`, `_kuis_tutup_btn`; smartboard (pola yang sama): `x_btn`, `tutup`. Total 12 tombol. Semua pakai konstanta bernama `BaseButton.ACTION_MODE_BUTTON_PRESS` (di Godot 4.7 nilainya 0; RELEASE default = 1 — terverifikasi probe).
- **Peta putri (item 11):** `PetaControl.GEDUNG_PUTRI` (7 gedung, dari konstanta `KampusPutri`) + `PetaControl.bingkai_peta()` (fungsi murni, bisa dites) + `_draw` memakai bingkai (grid dibatasi bingkai, jalan internal x=142, pagar hijau 800 m hanya di tampilan putra, label tampil di tampilan putri, gedung putri + label, fallback `TembokPutri.KELILING_GARIS` / `GERBANG_PUTRI_POS`, label GERBANG selatan hanya di tampilan putra, `_rect_gerbang` di tampilan putri = rect GERBANG PUTRI); `MinimapControl`: fallback yang sama + gedung putri 8×8. **Susulan foto:** `_peta_map.clip_contents = true` + `_minimap.clip_contents = true` (tumpahan keluar rect); gedung putri dua pass (kotak dulu, label kemudian) + label gedung putri hanya bila `putri`.
- **Tidak disentuh:** `main.gd`, `player.gd`, `npc.gd`, interior, builder, v2. `--check-only` `ui.gd` OK.

## Cara diagnosis (bukan tebakan)

1. Baca `ui.gd` lengkap + `_data_peta()` di `main.gd` + konstanta `PesantrenBuilder`/`KampusPutri`/`TembokPutri`.
2. Tes diagnostik pra-perbaikan (`test_gita_diag.gd`, xvfb 1280×720, skala 1.0): klik bersih SEMUA tombol bekerja — Tutup dashboard menutup (`tekan=1`), Ganti Baju emit + outfit terbuka, Reset teleport ke SPAWN, zoom 1.0→2.0→4.0. Klik-seret 120 px: Reset `tekan=0` (posisi tetap (50,0,50)), zoom+ `idx tetap 0` — tombol sempit mati saat lepas bergeser. (Catatan: dua "PASS" semu di run headless murni — viewport 1280×1280 skala 0.2 membuat klik mendarat di luar panel sehingga handler klik-di-luar yang menutup panel; run xvfb yang sahih.)
3. Probe enum: Godot 4.7 `ACTION_MODE_BUTTON_RELEASE = 1` (default), `ACTION_MODE_BUTTON_PRESS = 0`.
4. Item 12 terukur dengan `Palette.FONT_GAME` + `login_metrics` di 3 skala; item 11 terukur lewat rumus skala peta (32 px) + kunci `_data_peta()` yang hilang.

## Hasil uji pasca-perbaikan

- **Tes logika headless** `test_gita_logika.gd` (Godot 4.7.2): **SEMUA LULUS** — 6 tombol target `action_mode = PRESS (0)`; handler zoom 1.0→2.0→4.0→mentok→1.0→mentok + label; ketiga placeholder muat di s=1.5/0.54/0.30; bingkai putri/putra/batas x=60/61/tanpa-data; fallback keliling 5 titik + gerbang putri (115,0,0) + 7 gedung putri. Satu FAIL awal ("Username IG" 329 vs 315 di portrait) diperbaiki jadi "Akun IG" → lulus semua.
- **Tes klik xvfb 1280×720** `test_gita_klik.gd`: **16/16 LULUS** — Ganti Baju bersih + seret 400 px (emit 1→2, outfit terbuka); Tutup dashboard bersih + seret; Reset bersih + seret (teleport ke SPAWN (−4,0,14)); zoom+ bersih 2.0x/4.0x + seret 400 px 2.0x; zoom− bersih + seret kembali 1.0x; Tutup peta bersih + seret; putri: bingkai putri aktif, zoom bersih 2.0x, zoom− seret kembali 1.0x.
- **Foto** (xvfb-run, jam 10.00, `ronde-perbaikan/foto/`): G1–G7 (lihat bawah).

## Foto bukti

- `G1-login.png` — layar login desktop: placeholder "Akun IG" + "Kata sandi" terbaca utuh.
- `G1-login-portrait.png` — layar login HP portrait 390×844 (mode kompak): placeholder tetap utuh.
- `G2-dashboard.png` — Kartu Santri: footer "Ganti Baju" + "Tutup" terlihat.
- `G3-outfit.png` — panel Ganti Baju terbuka dari tombol footer.
- `G4-peta-putra-2x.png` — peta putra zoom 2.0x, label "2.0x".
- `G5-peta-putri-1x.png` — peta putri 1.0x: kampus putri membingkai peta + gedung + label + tembok keliling + gerbang putri.
- `G6-peta-putri-2x.png` — peta putri 2.0x berpusat pada pemain.
- `G7-putri-hud.png` — santriwati di kampus putri: HUD + minimap.

## Penilaian Gita dari foto

- **G1 (login desktop + portrait):** placeholder "Kata sandi" terbaca utuh di kedua ukuran; field IG terisi "tes" (save lokal lama) jadi placeholder "Akun IG" tidak terlihat di foto — tapi terukur muat di tes (110/186/~170 px vs 332/315/315 tersedia).
- **G2 (Kartu Santri):** footer "Ganti Baju" (emas) + "Tutup" jelas, tombol X jelas, Reset Posisi terlihat di kanan bawah.
- **G3 (Ganti Baju):** panel outfit terbuka penuh — Koko/Songkok/Sarung/Kulit/Kacamata + tanda ✓ pada pilihan aktif (Putih, Zamrud, Sawo Matang, Lepas).
- **G4 (peta putra 2.0x):** label "2.0x" terbaca; tembok keliling putri + kotak gedung putri kini tergambar di kanan; label gedung putri TIDAK lagi menumpuk di gumpalan tengah (hanya kotaknya). Gumpalan label tengah (Masjid/Cangkruk/Pos Jaga/Ruang Kelas/Perpustakaan/Bilal/Faris) masih menumpuk — itu perilaku LAMA sejak Ronde 5/7/8 di zoom 2.0x, bukan regresi; tumpahan label Kyai/Ustadzah ke atas panel sudah hilang berkat clip.
- **G5 (peta putri 1.0x):** kampus putri mengisi peta — tembok keliling, Musholla hijau, 7 gedung krem, titik pemain hijau, label "MUSHOLLA", "KANTOR USTADZAH", "CANGKRUK PUTRI", "MADRASAH", "ASRAMA PUTRI", "KELAS PUTRI", "GERBANG PUTRI", "POS JAGA" semua terbaca utuh. Sawah + label putra terpotong rapi di tepi kiri map (bukan tumpah ke luar panel). "KANTOR USTADZAH" dan "MUSHOLLA" berdekatan tapi tidak saling menutupi.
- **G6 (peta putri 2.0x):** gedung besar-besar, label "CANGKRUK PUTRI", "KELAS PUTRI", "MADRASAH", "STUDIO", "ASRAMA PUTRI", "GERBANG PUTRI" terbaca; label "MUSHOLLA" terpotong setengah di tepi atas (gedungnya memang di luar tampilan 2.0x — wajar untuk peta).
- **G7 (santriwati di kampus putri):** HUD + minimap — minimap menampilkan tembok keliling coklat + gedung putri krem + jalan + panah pemain; santriwati abaya zamrud + jilbab berdiri di depan Kelas Putri/Madrasah.

## Perbaikan susulan saat verifikasi foto (masih `ui.gd` saja)

Foto pertama G5/G6 menemukan dua cacat gambar yang DIBUAT perubahan item 11 sendiri — diperbaiki sebelum diserahkan, lalu foto diulang:
1. **Gambar peta tumpah keluar rect** (label putra + kotak sawah raksasa menutupi HUD/dunia di luar panel): `PetaControl`/`MinimapControl` tidak di-clip. Perbaikan: `_peta_map.clip_contents = true` + `_minimap.clip_contents = true`. Foto ulang: tumpahan hilang; yang di luar bingkai terpotong rapi di tepi map.
2. **Kotak gedung menutupi label gedung lain** ("MUSHOLLA" tinggal "HOLLA", "CANGKRUK PUTRI" terpotong): loop gedung menggambar kotak+label per gedung secara bergantian. Perbaikan: dua pass — semua kotak dulu, semua label kemudian (label Musholla ikut pass label); label gedung putri hanya di tampilan putri (di tampilan putra 2.0x ketujuh label itu menumpuk di gumpalan tengah). Foto ulang: semua label utuh.
3. Tes logika diulang setelah perbaikan susulan: **SEMUA LULUS** lagi; `--check-only` OK.

## Yang belum / catatan untuk Raka

- **`main.gd` `_data_peta()` belum mengirim `tembok_keliling_garis` + `gerbang_putri_pos`** (file Raka — saya tidak menyentuh). Peta kini tetap lengkap karena `ui.gd` fallback ke konstanta `TembokPutri`, tapi sebaiknya `main.gd` mengirim kunci itu supaya jalur data yang benar yang dipakai (dan komentar "PERHATIAN (laporan ke Raka)" di `main.gd` ~1390 soal `pagar_garis` sudah kedaluwarsa — kodenya kini membaca `tembok_garis`).
- **Tombol yang TIDAK diubah (pola yang sama, belum dilaporkan mati):** opsi kuis (sengaja tetap RELEASE — pembatalan dengan geser justru berguna di kuis), tombol Aksi, Kirim chat, tombol login/daftar, banner "IKUT SHOLAT". Kalau retest menemukan yang sama di sana, perbaikannya satu baris per tombol seperti di atas.
- **Observasi di luar item (tidak diperbaiki):** di login portrait mode kompak, tombol tautan "Belum terdaftar? Daftar baru" tampil kecil/mungil — `_apply_login_metrics` tidak menyentuh tombol itu (hanya MASUK/DAFTAR/Lanjutkan). Quirk lama, bukan item 12; kalau mau diperbaiki, masukkan tombol itu ke loop `for btn in [...]` di `_apply_login_metrics`.
- **Tidak ada perubahan perilaku lain:** tampilan putra di zoom 1.0x identik dengan sebelumnya (pusat 0,0 setengah 400, grid mulai −400 seperti dulu); label peta putra tetap sembunyi di 1.0x.
- Skrip tes + foto diarsipkan di `~/workspace/pesantren-verse/ronde-perbaikan/skrip/` dan `~/workspace/pesantren-verse/ronde-perbaikan/foto/`; salinan sementara di root `godot-dunia/` sudah dihapus.
