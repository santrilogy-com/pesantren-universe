# RONDE PERBAIKAN — STATUS GABUNGAN (Godot v1, 17 Nov 2026)

**Sumber:** retest Ronde 23 (17 Nov 09:20–13:02 WIB). **ACC Mas 17 Nov ~19:08 WIB.**
**Status: 15/15 item SELESAI (termasuk integrasi Raka). TIDAK deploy — menunggu ACC Mas.**
**Koordinator:** Raka. **Pelaksana:** Eka (main.gd/player.gd/npc.gd), Gita (ui.gd),
Fajar (world/interior), Raka (integrasi + main.gd/kampus_putri.gd/ui.gd).

Laporan rinci tiap agen: `RONDE-PERBAIKAN-EKA.md`, `RONDE-PERBAIKAN-GITA.md`,
`RONDE-PERBAIKAN-FAJAR.md` (di folder ini). Foto bukti:
`~/workspace/pesantren-verse/ronde-perbaikan/foto/` (E1–E6, G1–G7, A1–A13,
M1–M7, I1–I5). Skrip tes/foto: `~/workspace/pesantren-verse/ronde-perbaikan/skrip/`.
Root proyek bersih (hanya `main.tscn` + file lama).

## Ringkasan per item

| # | Item | Agen | Status | Akar masalah (satu baris) | Bukti |
|---|------|------|--------|---------------------------|-------|
| 1 | Gerbang x=14: toast + dorong balik tidak jalan (7x gagal) | Eka | SELESAI | `BarrierGerbang` menahan kapsul di x≈13,449 — kondisi `x > 14` tidak pernah tercapai. Perbaikan: penegakan jarak — sentuh tembok sambil menekan ke arahnya → toast + dorong balik 1,5 m. | Tes: toast putra 2x, putri 4x, tak ada yang lolos (x_max 13,30 / x_min 14,70). Foto E1. |
| 2 | Bubble chat tidak muncul | Eka | SELESAI | Panel chat tidak menutup sendiri setelah kirim; bubble ditekan selama panel terbuka + timer 5 dtk terus jalan. Perbaikan: `close_chat()` di `_on_chat_sent`. | Bubble pemain + NPC Bilal muncul dengan teks persis. Foto E2. |
| 3 | Papan nama terbalik dari satu sisi | Fajar | SELESAI | Semua Label3D `double_sided=true` — sisi belakang terbaca cermin. Perbaikan: `double_sided=false` + label belakang di semua papan (GERBANG, GERBANG PUTRI, Cangkruk, gedung putri, Pos Jaga, 3× KELUAR). | Foto A4, A6, A11, M7 — terbaca benar dari dalam + luar. |
| 4 | Celah bubungan atap Cangkruk | Fajar | SELESAI | BUKAN ridge — segitiga pelana (gable) di kedua ujung atap tidak ada penutupnya (lubang ~10×1,25 m). Perbaikan: 2 prisma segitiga kayu di tiap Cangkruk (putra + putri). | Foto A7/A8 — segitiga kini cokelat dinding, diterangi matahari. |
| 5 | Kamera tembus model | Eka | SELESAI | Tidak ada penahan kamera. Perbaikan: `_jarak_kamera_aman` — raycast dari posisi kamera ke kepala pemain, spring memendek ke titik kena −0,3 m; clamp 2,0 m bila NPC < 0,9 m dari kamera. | Lapangan terbuka spring tetap 7,00; utara KelasPutri 1,87; tembok sementara 2,4 m → spring 2,49, pulih 7,00 setelah dihapus. |
| 6 | Jalan aspal Surau meleset ~7 m dari pintu | Fajar | SELESAI | Jalan N-S di x=0, pintu Surau di x=−3,38. Perbaikan: jalan N-S geser ke x=−3,38; segmen utara dipendekkan (z −200..−25,5); taji baru `JalanNS_Surau` dari jalan E-W ke serambi. | Garis spawn→pintu 41/41 titik di atas aspal (dulu 5/41). Foto A9. |
| 7 | Interior Musholla lengkap | Fajar + Raka | SELESAI | Retest melihat SHELL kosong (lantai biru polos) — interior terpisah tidak pernah ditampilkan karena TIDAK ADA logika pintu Musholla di `main.gd`. (a)(b)(e) sudah benar di kode; (d) kubah memang rusak; (c) bedeng bunga TamanMusholla jatuh di dalam ruang sholat; (f) pintu — dikerjakan Raka (lihat § Integrasi). | Foto M1–M7 + I1–I2. |
| 8 | Tombol panel mati (Ganti Baju, Tutup Map + Kartu Santri, Reset) | Gita | SELESAI | Tombol `ACTION_MODE_BUTTON_RELEASE` (default): hanya menyala bila lepas DI DALAM tombol; ketukan HP hampir selalu bergeser. Perbaikan: 13 tombol → `ACTION_MODE_BUTTON_PRESS`. | Tes klik xvfb 16/16 LULUS (bersih + seret 400 px). Foto G2/G3. |
| 9 | Zoom peta terkunci 1.0x | Gita | SELESAI | Logika zoom TIDAK rusak — tombol zoom-nya yang mati (akar sama dengan item 8). Perbaikan: tombol zoom → PRESS-mode; logika tidak disentuh. | Zoom bersih 1.0→2.0→4.0x + seret tetap jalan; label ikut. Foto G4. |
| 10 | Satpam NPC tidak ketemu | Eka | SELESAI | Posisi lama (17,5) = tengah gubuk PosSatpam 3×3 m — ia berdiri DI DALAM gubuk. Perbaikan: pindah ke (17,0, 8,0), 1,5 m selatan gubuk, yaw −2,78 menghadap gerbang. | Garis pandang bersih dari timur + tenggara, label terlihat. Foto E3. |
| 11 | Peta putri cuma tampil area putra | Gita | SELESAI | (a) peta selalu membingkai seluruh 800 m — kampus putri hanya 32 px; (b) `main.gd` tidak mengirim data tembok keliling/gerbang putri; (c) gedung putri tidak pernah digambar. Perbaikan: bingkai kampus putri bila pemain di timur tembok + gambar 7 gedung putri + jalan internal + fallback tembok/gerbang. | Kampus putri kini 220 px (33%) di peta. Foto G5/G6. |
| 12 | Placeholder password login terpotong | Gita | SELESAI | Placeholder 50 karakter = 431 px vs 332 px tersedia (desktop) / 315 px (HP). Perbaikan: "Kata sandi" (89/151/267 px), IG → "Akun IG", daftar → "Nama santri". | Semua placeholder muat di s=1,5/0,54/0,30. Foto G1 desktop + portrait. |
| 13 | Label nama putri terpotong ("Uji Putr") | Eka | SELESAI | Label 0,890 m vs celah 0,35 m ke muka tembok — satu ujung masuk tembok. Perbaikan: `_batasi_label_dinding` — raycast kiri/kanan, label mengecil (min skala 0,08) sampai muat di depan tembok. | Skala 0,676, ujung timur x=13,750 ≤ 13,8. Foto E4a/E4b. |
| 14 | Rute utara spawn putri lewat sawah, kamera masuk tanah, mentok tembok | Eka + Raka | SELESAI | Celah pintu selatan KelasPutri (1,6 m) masuk ke cangkang kosong, mentok di dinding utara. Eka: penjaga sementara (toast + teleport ke titik aman). Raka (permanen): daun pintu jati TERTUTUP di celah + konektor aspal `KonekSpawn` (130,14)→JalanInternal x=142. | Penjaga: z_min=4,10, toast 3x. Permanen: raycast celah kena daun; spawn di atas aspal. Foto E5a/E5b + I3/I4. |
| 15 | Banner Dzuhur tulis "Surau" untuk putri | Eka + Raka | SELESAI | Toast sudah mengikuti gender (Eka); teks banner hardcoded "Surau" di `ui.gd show_sholat_banner()`. Raka: parameter `tempat` + 3 call site di `main.gd` mengirim "Musholla" untuk putri. | Putri: "Waktu sholat Dzuhur — ayo ke Musholla!" (langsung + via `_mulai_sholat`); default tetap "Surau". Foto E6. |

## Integrasi Raka (setelah ketiga agen selesai)

1. **Item 7(f) — pintu Musholla** (`scripts/main.gd`, cermin `_cek_pintu_surau`,
   spesifikasi Fajar): flag `_di_dalam_musholla`; `_cek_pintu_musholla()` (koridor
   luar sumbu dunia |x−134|<1,0, z −19..−17,5 — pemicu HARUS di luar dinding
   supaya pemain di-teleport SEBELUM masuk shell kosong; koridor dalam pakai
   `InteriorMusholla.SUMBU/KELUAR`); `_masuk/_keluar_musholla()` (flag +
   `_set_interior_terlihat(false,false,true/false)` + teleport spawn/exit +
   toast + sandal lepas/pakai); prompt "MASUK/KELUAR MUSHOLLA" + tombol
   interaksi; pengecualian `_cek_batas`, spring kamera, `_sinkron_sandal`,
   `_respawn_ke_spawn`, dan titik pemain di `_data_peta()` (MUSHOLLA_POS).
   `_on_ikut_sholat` putri kini ke Musholla (Sajadah_03 + flag + interior);
   putra tetap Surau. Sistem sholat NPC sudah bercabang gender sejak Ronde 20
   (Ustadzah → imam Musholla), jadi perubahan ini konsisten.
2. **Item 14 permanen** (`scripts/kampus_putri.gd`): `_daun_pintu_kelas_putri` —
   dua daun jati rapat (0,8×2,6×0,25 m, rata dinding) + collision + 2 gagang
   emas; `KonekSpawn` (12×2,5 m di z=14, x 130..142) dari spawn ke JalanInternal.
   Penjaga sementara Eka dibiarkan sebagai jaring pengaman (kini dorman —
   pemain tidak bisa lagi masuk cangkang).
3. **`_data_peta()`** (`scripts/main.gd`, catatan Gita): mengirim
   `tembok_keliling_garis` + `gerbang_putri_pos` (konstanta TembokPutri) +
   pemetaan titik pemain/target saat di dalam Musholla; komentar "PERHATIAN"
   tentang `pagar_garis` diperbaiki (sudah kedaluwarsa — ui.gd membaca
   `tembok_garis` + fallback).
4. **Tombol tautan login** (`scripts/ui.gd`, catatan Gita): "Belum terdaftar?
   Daftar baru" + "Sudah punya ID? Masuk di sini" tadinya berukuran TETAP
   (360×48, font 20) — kini ikut metrik form via `_apply_login_metrics`
   (member baru `_daftar_link` / `_kembali_btn`).

**Tes integrasi Raka: 35/35 LULUS** (`test_integrasi.gd`, headless) — masuk/keluar
Musholla (flag, posisi, interior terlihat/tersembunyi, sandal, prompt,
tombol, tanpa re-trigger dari titik keluar), sholat putri → Musholla +
putra → Surau (regresi), kunci + nilai `_data_peta`, daun pintu (ada +
posisi + raycast collision), KonekSpawn (ada + posisi + mencakup spawn),
tombol tautan (lebar + font ikut metrik). Foto I1–I5 (I2 di-retake dari
dalam ruangan — versi pertama terfoto dari luar lewat celah pintu).

## Hasil uji tiap agen

- **Eka:** tes headless akhir **32/32 PASS, 0 FAIL**. Foto E1–E6.
- **Gita:** tes logika headless **SEMUA LULUS** + tes klik xvfb **16/16 LULUS**.
  Foto G1–G7.
- **Fajar:** baseline **49 LULUS / 10 GAGAL** → setelah perbaikan
  **103 LULUS / 1 GAGAL**. Satu-satunya gagal (`pintu-musholla-logika-ada`)
  SESUAI RENCANA — logika itu ada di `main.gd` milik Raka, dan kini sudah
  diimplementasikan + lulus di tes integrasi (7f-*). Foto baseline 20 +
  sesudah A1–A13, M1–M7.
- **Raka (integrasi):** **35/35 LULUS**. Foto I1–I5.

Semua file yang diubah lolos `--check-only`. Total foto bukti sesudah: 41
(E 8 + G 8 + A 13 + M 7 + I 5, termasuk varian a/b).

## File yang diubah

- `scripts/main.gd` — Eka (item 1, 2, 5, 10, 13, 14-sementara, 15-toast) +
  Raka (item 7f, 14-permanen di kampus_putri, `_data_peta`, sholat putri,
  15-banner call site).
- `scripts/player.gd`, `scripts/npc.gd` — Eka (item 13).
- `scripts/ui.gd` — Gita (item 8, 9, 11, 12) + Raka (item 15-banner, tombol
  tautan login).
- `scripts/pesantren_builder.gd`, `scripts/kampus_putri.gd`,
  `scripts/interior_musholla.gd`, `scripts/interior_surau.gd`,
  `scripts/interior_cangkruk.gd`, `scripts/tembok_putri.gd`,
  `scripts/jalan_ronde22.gd` — Fajar (item 3, 4, 6, 7) + Raka
  (item 14-permanen di kampus_putri.gd).

## Catatan / tindak lanjut (bukan blocker)

- Gedung `_gedung` lain di kampus putri (Asrama, Kantor Ustadzah, Madrasah,
  Studio) masih bercelah pintu terbuka ke cangkang kosong — pola yang sama
  dengan KelasPutri sebelum diperbaiki. Tidak dilaporkan di retest Ronde 23;
  kalau Mas mau, daun tertutup yang sama bisa dipasang (atau interior dibangun).
- Penjaga sementara Eka di `_cek_batas` untuk KelasPutri kini dorman (pintu
  tertutup) — dibiarkan sebagai jaring pengaman, bukan dihapus.
- Foto E5a/E5b (penjaga sementara) tetap valid sebagai bukti perilaku darurat;
  perilaku normal kini pintu tertutup + jalan aspal (I3/I4).
- Komentar lama di `main.gd` soal `pagar_garis` sudah diperbaiki; tidak ada
  lagi catatan "PERHATIAN" yang menggantung dari ronde ini.
