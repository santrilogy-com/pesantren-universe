# HIJAB PUTRI RONDE 6 — RENCANA + HASIL

Verdict Mas atas 3D ronde 5 (18 Nov 10:35 WIB): "Ya belum seperti
referensi.. bagian depannya.. Malah jadi kek orang kristen."

## Diagnosis — kenapa depan terbaca seperti biarawati

Bukan warna atau panjangnya — keduanya sudah benar (krem, menutup
sampai dada tengah). Yang salah bentuk depannya:

1. **Lubang wajah bundar rapat** — rim kubah (busur halus) + 2 strip
   sisi yang miring ke DALAM di bawah + bungkus dagu membentuk
   lubang bundar sempurna di sekeliling wajah, persis wimple
   biarawati. Di gambar konsep lubang wajahnya melebar ke bawah
   (kain membuka ke arah bahu).
2. **Drape depan panel datar** — permukaan halus tanpa lipatan sama
   sekali, sisi lurus vertikal — persis veil datar. Di gambar konsep
   drape berlipat lembut dan melebar melewati bahu.

## Desain (bagian DEPAN saja — belakang/kubah/dagu dipertahankan)

Dibandingkan render depan 3D berdampingan dengan tampilan DEPAN di
gambar konsep (konsep-jilbab-v1.png), bukan menebak:

1. **Strip sisi DIBALIK arah miringnya** (pusat x 0,225 -> 0,232,
   rotasi -sx*0,08 -> +sx*0,10): ujung bawah kini MELEBAR ke luar
   (±0,255), ujung atas masuk (±0,209) — bukaan wajah jadi
   TRAPESIUM lembut, melebar ke bawah seperti gambar. Lebar AABB
   0,117 tetap <= 0,13 (audit); bawah y 1,317 tetap <= 1,32.
2. **Lipatan LEMBUT yang TERLIHAT di drape** — 2 segmen kapsul
   diagonal per sisi, warna digelapkan (garis lipat di gambar),
   mengalir dari rahang ke arah bahu:
   - Atas: (±0,125, 1,27), r 0,018, panjang 0,187, rot.z ±0,271
     — dari (±0,10, 1,36) ke (±0,15, 1,18).
   - Bawah: (±0,185, 1,09), r 0,018, panjang 0,193, rot.z ±0,370
     — dari (±0,15, 1,18) ke (±0,22, 1,00).
   - Depan maks 0,294 (<= 0,30); ujung-ujung di dalam lebar drape.
   - Percobaan pertama (r 0,022, gelap 0,08, mulai dari x ±0,05)
     terbaca seperti BATANG membentuk huruf A — diperhalus di
     dalam ronde ini: r 0,018, gelap 0,06, mulai dari x ±0,10
     (puncak tidak setajam), lalu foto ulang.
3. **Lidah bawah DILEBARKAN** (skala x 1,25 -> 1,38, lebar ±0,276)
   supaya drape melebar melewati bahu seperti gambar.
4. **Bintik gelap sambungan tier DIPERBAIKI** — ujung atas tier
   bawah DIPERKECIL (r 0,175 -> 0,15) + overlap diperdalam
   (tinggi 0,21 -> 0,23, pusat y 1,055 -> 1,065, atas y 1,18):
   ujung atas kini masuk ke DALAM tier atas (depan 0,254 vs tier
   atas 0,269 di y 1,18) — permukaan tidak bersilangan lagi di
   sambungan. Sambungannya sendiri terbaca sebagai lipatan
   bertumpuk (tier atas menindih tier bawah 0,014) — wajar untuk
   kain berlapis.

## Dipertahankan (jangan dirusak)

- Dada tertutup sampai dada tengah (bawah ~0,89), TANPA pita hijau
  di kerah (puncak drape y 1,42).
- Tepi bawah melengkung U (rim tier bawah 0,95, lidah ~0,89).
- Kubah LONGGAR ronde 4 (r 0,28); belakang satu kerudung menyatu
  (ronde 2); depan sampai garis dagu (ronde 3, HijabDagu); HijabCape
  tetap DIHAPUS.
- Recolor: 4 node lipatan masuk daftar gelap 0,06 di `_warnai_ulang`.

## Verifikasi

- Audit karakter: **170/0** (ronde 5: 162/0 + 8 cek ronde 6 baru
  x 2 karakter — putri + ustadzah: 4 lipatan ada; lipatan bukan
  kotak; strip melebar ke bawah (tepi luar |x| >= 0,25); lidah
  lebar >= 0,50).
- test_v2: **60/0**.
- Foto 22/22 (foto_hijab.gd, -- sesudah). Foto ronde 5 diarsipkan ke
  `foto-hijab/ronde5-sesudah/` (22 file).
- Hanya player.gd + skrip audit + foto + dokumen ini yang disentuh.
  main.gd, kampus_putri.gd, interior, kamera.gd TIDAK disentuh.
  TIDAK deploy — export + deploy urusan Xam.

## Catatan jujur (penilaian Mas)

1. **Bacaan "biarawati" HILANG** — bukaan wajah kini trapesium
   melebar ke bawah, drape berlipat dan melebar ke bahu. Dua bintik
   gelap di panel dada HILANG (tidak ada lagi di foto depan).
2. **Lipatan masih segmen lurus** — sudah tipis dan lembut (bukan
   batang), tapi tetap garis lurus bersudut, bukan lipatan
   melengkung mengalir seperti di gambar konsep. Primitif tidak
   bisa membuat lipatan melengkung sungguhan; ini batas metode.
3. Dari SAMPING, ujung-ujung lipatan terbaca sebagai tonjolan kecil
   di tepi depan drape — halus, tapi ada.
4. Garis sambungan tier di y~1,15 masih terbaca sebagai garis
   horizontal samar di dada — terbaca sebagai lipatan, wajar.
5. Ujung bawah belakang masih agak kotak (catatan ronde 2, di luar
   brief — gambar konsep belakang juga ujungnya agak lurus).
6. Rim kubah di dahi ~1,81 (ronde 4, tidak berubah).
