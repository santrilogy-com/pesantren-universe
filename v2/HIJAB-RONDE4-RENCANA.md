# HIJAB PUTRI RONDE 4 — RENCANA + HASIL

Verdict Mas (18 Nov 09:37 WIB): "Ya kayak jilbab.. menutup sampai dada."
Masalah ronde 1–3: kubah ketat + bungkus leher — dari depan terbaca topi/hoodie,
bukan jilbab. Abaya terekspos penuh dari kerah ke bawah; tidak ada kain di dada.

## Desain (redesign, bukan tambal)

Geometri acuan (terukur): abaya frustum 0,23 -> 0,36, pusat y=0,76 —
permukaan depan dada 0,237 (y=1,35) -> 0,286 (y=0,85). Drape dada harus
mengikuti kemiringan itu, 0,013..0,018 m di depan abaya.

1. **HijabDada** (node tetap `HijabDepan` — recolor + audit tidak berubah):
   frustum silinder (bukan elipsoid — elipsoid menggembung di tengah,
   cacat ronde 1), atas r=0,17 -> bawah r=0,19, tinggi 0,50, pusat
   (0, 1,10, 0,1765), skala (1,29, 1,0, 0,55), rotasi x -0,06.
   Jatuh dari bawah dagu (y=1,35, ujung atas masuk di balik HijabDagu)
   sampai dada tengah (y=0,85), lebar 0,44 -> 0,49. Depan kain 0,255 ->
   0,296 (batas audit 0,30), selalu 0,013..0,018 m di depan abaya.
   Sisi kain (x ±0,22..0,25) membungkus dada, tepi di depan permukaan abaya.
2. **Kubah LONGGAR**: r 0,26 -> 0,28, pusat mundur z -0,04 -> -0,065,
   skala (1,07, 0,78, 0,93). Depan di tinggi mata z 0,189 (mata belakang
   0,202 — wajah aman); rim menyilang wajah y~1,81 (di atas alis 1,735).
   Lebar di y=1,66 -> ±0,279 (overhang 0,039, dulu 0,009); belakang
   -0,307 (overhang 0,067, dulu 0,025). Puncak 1,958 (< 2,10 audit).
3. **Strip sisi DIPANJANGKAN**: tinggi 0,40 -> 0,46, pusat y 1,56 -> 1,51
   (ujung bawah 1,28) — bingkai wajah menyambung ke drape dada (atas 1,35).
   Miring 0,10 -> 0,08 supaya lebar AABB tetap <= 0,13 (audit).

## Dipertahankan (jangan dirusak)

- Belakang satu kerudung menyatu (ronde 2) — HijabDrape TIDAK BERUBAH.
- Depan sampai garis dagu (ronde 3) — HijabDagu TIDAK BERUBAH.
- HijabCape tetap DIHAPUS. Frustum, bukan elipsoid (pelajaran ronde 1+3).
- Recolor: nama node tidak berubah, daftar warna-sama tidak berubah.

## Verifikasi

- Audit karakter: **152/0** (ronde 3: 142/0 + 10 cek ronde 4 baru x 2
  karakter — putri + ustadzah: drape bawah y<=0,90; lebar x>=0,44;
  irisan dgn abaya; kubah longgar x>=0,58; strip bawah y<=1,32).
- test_v2: **60/0**.
- Foto 22/22 (foto_hijab.gd, -- sesudah). Foto ronde 3 diarsipkan ke
  `foto-hijab/ronde3-sesudah/` (22 file).
- Hanya player.gd + skrip audit + foto + dokumen ini yang disentuh.
  main.gd, kampus_putri.gd, interior, kamera.gd TIDAK disentuh.
  TIDAK deploy — export + deploy urusan Xam.

## Catatan jujur (penilaian Mas)

1. Panel dada terbaca agak KOTAK dari depan (sisi lurus vertikal +
   bawah rata horizontal) — frustum memang bersisi lurus; ini primitif,
   bukan kain berlipat. Inti "menutup sampai dada" tercapai, tapi kalau
   Mas mau drape lebih lembut, ronde 5 bisa melengkungkan tepi bawah.
2. Ada pita HIJAU di kerah (dada atas/bahu, y~1,35..1,42) — ujung atas
   drape di y=1,35, di bawah garis bahu, jadi abaya terlihat di antara
   bungkus leher dan panel dada. Kalau Mas mau tertutup penuh sampai
   leher, drape harus naik ke y~1,42 (menutup bahu).
3. Sisi bawah dagu yang berbayang masih persik di close-up — itu lekuk
   bawah dagu sendiri (kulit y 1,51..1,55), BUKAN sisa leher (catatan
   ronde 3, tidak berubah).
4. Rim kubah di dahi ~1,81 (dulu 1,80) — naik 0,01 karena kubah membesar;
   penilaian Mas.
5. Drape belakang masih agak kotak/bersisi tegak dengan ujung bawah
   datar (catatan ronde 2, tidak berubah — di luar brief ronde 4).
