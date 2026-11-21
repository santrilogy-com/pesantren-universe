# Audit v6f — perbaikan cacat v6 chibi — 2026-11-21 ~07:50 WIB

Perbaikan atas 5 cacat dari screenshot v6 (depan / wajah / samping),
3 ronde edit + screenshot (chrome-headless-shell + SwiftShader,
1280x800 desktop + 390x844 HP). Verifikasi penuh terakhir: 0 console
error, 0 page error, canvas render OK.

## Cacat awal → perbaikan

1. **Jenggot 3 blob terpisah** (depan: dagu + 2 rahang terpisah celah
   kulit; close-up: 2 puff rahang + dagu terpisah).
   → Jenggot dibangun ulang sebagai SATU volume: massa utama bola besar
   (r 0.185, puncak terkubur di dalam kepala, hanya muncul di bawah garis
   rahang) + 2 puff rahang + 1 lobe dagu, semuanya tumpang-tindih DALAM
   ke massa utama. Tidak ada lagi celah kulit antar bagian.
2. **Kumis terbaca seperti lubang hidung** (2 titik terpisah di bawah
   hidung).
   → Diganti SATU batang kapsul utuh (lebar 0.132) di bawah hidung.
   Kini terbaca jelas sebagai kumis di depan maupun close-up.
3. **Serban navy kebaca topi polos** (dome halus tanpa tekstur lilitan).
   → 4 lipatan lathe di permukaan dome + dome sedikit lebih tinggi/
   sempit (R 0.41, skala y 0.92). Ronde 1 sempat overkoreksi: amplitudo
   0.030/sigma 0.07 membuat dome terbaca tumpukan piringan → ronde 2
   terlalu lembut (0.016–0.024) → ronde 3 final amplitudo 0.020–0.028,
   sigma 0.10–0.11: lipatan lembut terlihat di depan + samping tanpa
   bertingkat.
4. **Samping: serban overhang belakang seperti beret + jenggot runcing.**
   → Profil samping kini dome membulat lembut bergelombang (bukan
   beret datar); jenggot profil membulat, tidak runcing.
5. **Ekor serban seperti tetesan** (nub kecil menggantung).
   → Diganti tab kain PENDEK, LEBAR, PIPIH (0.126 × 0.15, tebal 0.035)
   menempel di belakang kepala — ujung lilitan yang terselip.

## Hasil periksa (verifikasi penuh, 8 shot)
- Depan: jenggot satu massa membulat proporsional (~50% lebar wajah),
  kumis satu batang, senyum terlihat, lipatan serban lembut.
- Wajah: jenggot satu massa, ujung atas melengkung halus di pipi
  (tanduk puff rahang dari ronde 1 sudah diturunkan), kumis batang utuh.
- Samping: dome bergelombang lembut, ekor tab pendek, jenggot membulat.
- Belakang: ekor tab kain di tengah belakang kepala, punggung jubah bersih.
- Kacamata / Senja / Jubah hijau / Mobile: tidak ada regresi.

## Catatan jujur
- Siluet serban masih berupa dome halus membulat — lipatannya lembut,
  bukan lilitan tegas. Itu sudah sesuai gaya vinyl-toy referensi (topi
  navy halus membulat), tapi kalau Mas masih membacanya "topi", langkah
  berikut yang tersisa adalah simpul (knot) di puncak depan atau satu
  pita lilit diagonal — keduanya belum dicoba karena berisiko artefak
  baru (pelajaran v5: cincin lepas terbaca simpai).
- Jenggot dari samping menonjol cukup jauh ke depan (rak) — wajar untuk
  chibi, tapi tetap dicatat.
- File diubah: hanya `index.html` (sumber); `.space-build/` tidak disentuh.
  Skrip verifikasi fokus 3 sudut: `~/workspace/tools/shot/verif-v6f.js`.
