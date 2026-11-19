# HIJAB PUTRI RONDE 5 — RENCANA + HASIL

Gambar konsep jilbab v1 DI-ACC Mas (18 Nov 09:56 WIB): "Nah ini bagus..
jilbab beneran." 3D ronde 5 dibangun mengikuti gambar persis.

## Dua cacat ronde 4 yang diperbaiki

1. **Pita HIJAU di kerah** (y 1,35..1,42) — ujung atas drape ronde 4 di
   y=1,35, abaya kelihatan di antara bungkus leher dan panel dada.
2. **Panel KOTAK** — frustum tunggal: sisi lurus vertikal + bawah rata
   horizontal seperti celemek (Mas: "Jelek", 09:54 WIB).

## Desain (mengikuti gambar konsep)

Geometri acuan (terukur): abaya frustum 0,23 -> 0,36, pusat y=0,76 —
permukaan depan dada 0,230 (y=1,42) -> 0,286 (y=0,85). Drape dada
mengikuti kemiringan itu, 0,012..0,018 m di depan abaya.

Drape dada kini **3 BAGIAN** (semua frustum/bola — bukan kotak, bukan
elipsoid menggembung; pelajaran ronde 1+3):

1. **HijabDepan** (tier atas, nama node tetap): frustum 0,15 -> 0,175,
   tinggi 0,27, pusat (0, 1,285, 0,168), skala (1,32, 1,0, 0,55),
   rot.x -0,06. Jatuh dari y=1,42 (puncak abaya — TIDAK ADA lagi celah
   hijau di kerah) sampai y=1,15. Depan kain 0,242 -> 0,272, gap
   0,012..0,015 di depan abaya. Ujung atas masuk di balik HijabDagu
   (depan 0,188 di y=1,42) — sambungan tanpa celah.
2. **HijabDepanBawah** (tier bawah, node BARU): frustum 0,175 -> 0,192,
   tinggi 0,21, pusat (0, 1,055, 0,178), skala dan rotasi sama.
   y 1,16..0,95 (tumpang tindih 0,01 dengan tier atas supaya sambungan
   tidak berambut). Kemiringan beda dari tier atas — garis lipatan
   lembut di y~1,15 seperti lipatan kain di gambar. Depan 0,268 ->
   0,290, gap 0,012..0,014.
3. **HijabDepanUjung** (lidah bawah, node BARU): bola pipih r=0,20,
   pusat (0, 0,94, 0,185), skala (1,25, 0,60, 0,55). Tepi bawah
   MELENGKUNG U (bukan rata): rim bawah tier bawah di y=0,95, lidah
   menjuntai sampai ~0,89 di tengah (terukur keluar dari permukaan
   abaya), sisi melengkung naik — seperti ujung drape di gambar
   konsep. Depan maks 0,295 (batas audit 0,30), gap 0,013..0,018.
   Catatan: bola TIDAK BISA menjuntai lebih rendah — permukaannya
   melengkung ke belakang sementara abaya melebar ke depan; di bawah
   y~0,89 lidah masuk ke dalam abaya. Ujung yang terlihat (~0,89)
   sudah di dada tengah sesuai gambar.

Gabungan ketiganya: puncak y=1,42, bawah ~0,89, lebar ±0,25, depan
maks 0,295.

## Dipertahankan (jangan dirusak)

- Kubah LONGGAR ronde 4 (r 0,28) — sesuai gambar (kubah longgar,
  bukan topi ketat).
- Belakang satu kerudung menyatu (ronde 2) — HijabDrape TIDAK BERUBAH.
- Depan sampai garis dagu (ronde 3) — HijabDagu TIDAK BERUBAH.
- Strip sisi ronde 4 (bawah y=1,28) — menyambung ke drape dada.
- HijabCape tetap DIHAPUS.
- Recolor: dua node baru masuk daftar warna-sama di `_warnai_ulang`.

## Verifikasi

- Audit karakter: **162/0** (ronde 4: 152/0 + 10 cek ronde 5 baru
  x 2 karakter — putri + ustadzah: 3 bagian ada; bukan kotak;
  puncak y 1,43 >= 1,41; rim bawah 0,94 >= 0,93 + lidah bawah
  0,82 <= 0,90; lidah lebar x 0,50 >= 0,44). Depan gabungan
  z 0,29 <= 0,30.
- test_v2: **60/0**.
- Foto 22/22 (foto_hijab.gd, -- sesudah). Foto ronde 4 diarsipkan ke
  `foto-hijab/ronde4-sesudah/` (22 file).
- Hanya player.gd + skrip audit + foto + dokumen ini yang disentuh.
  main.gd, kampus_putri.gd, interior, kamera.gd TIDAK disentuh.
  TIDAK deploy — export + deploy urusan Xam.

## Catatan jujur (penilaian Mas)

1. **Pita hijau di kerah HILANG** — kain krem mengalir terus dari bawah
   dagu sampai dada tengah (foto depan + close-up putri dan ustadzah).
   Tepi bawah MELENGKUNG U: tengah menjuntai sampai ~0,89, sisi naik
   ke rim 0,95 — bukan garis rata seperti ronde 4.
2. **Sisi drape masih cukup lurus** dari depan — primitif tidak bisa
   membuat lipatan lembut seperti di gambar konsep; garis lipatan di
   y~1,15 hampir tidak terlihat di render. Drape tetap terbaca agak
   panel dari depan, walau ujung bawahnya sudah melengkung.
3. **Dua bintik gelap kecil** di panel dada pada foto depan (putri +
   ustadzah, titik yang sama) — kemungkinan sambungan tier 1/tier 2
   atau lidah yang menembus; kecil, tapi terlihat kalau diperhatikan.
4. Rim atas drape di bawah dagu terlihat sebagai garis horizontal di
   close-up — terbaca sebagai lipatan kain di bawah dagu, wajar.
5. Ujung bawah belakang masih agak kotak/bersisi tegak (catatan ronde
   2, di luar brief ronde 5 — gambar konsep belakang juga ujungnya
   agak lurus).
6. Rim kubah di dahi ~1,81 (ronde 4, tidak berubah).
