# Perbaikan Hijab Putri — Status (Kirana, 18 Nov 2026)

Bug HP Mas 07:08 WIB (live alpha 2f90447b): "Karakter putri keliatan
aneh, jilbabnya kek bukan jilbab, kek lagi gendong benda aneh."
Berlaku santriwati + Ustadzah Mariyah (satu pabrik `build_visual()`).

## Diagnosis (foto SEBELUM — `v2/foto-hijab/*_sebelum.png`)

- **HijabDepan — pelaku utama "gendong benda aneh":** elipsoid telur
  depan z=0.33, 0.076 m di depan abaya, membulat penuh di tengah dada —
  dari depan/samping/jalan/malam terbaca bundel/bayi yang digendong.
- **HijabCape — piring/sombrero:** cakram 0.92 x 0.72 m, menjorok 0.09 m
  ke depan dada dan 0.17 m ke belakang punggung, 0.25 m melewati bahu.
- **HijabDrape — papan di punggung:** panel datar + digelapkan 0.03
  sehingga terbaca perisai/ransel terpisah.
- **HijabKubah + strip sisi — rambut bob pirang:** kubah halus + strip
  vertikal tebal, tiap bagian elipsoid halus dengan siluet keras
  sendiri; kontras krem vs abaya zamrud membuat tiap bagian "melompat"
  sebagai objek sendiri. Wajah sendiri TIDAK bermasalah (mata/alis/
  hidung/mulut terbuka, close-up wajah bersih).

## Perbaikan (hanya cabang hijab `player.gd`, ~baris 781–900)

| Bagian | Lama | Baru |
|---|---|---|
| Kubah | r 0.255, s 1.05/0.58/1.05 di (0,1.79,-0.04) | r 0.25, s 1.02/0.58/1.02 di (0,1.78,-0.04) — merapat ke kepala |
| Drape belakang | s 0.95/1.35/0.25 di (0,1.35,-0.26), digelapkan | s 0.80/1.30/0.22 di (0,1.33,-0.24), warna = kubah, miring dihapus |
| Cape | s 1.15/0.28/0.90 di (0,1.38,-0.04) — 0.92 m | s 0.85/0.25/0.66 di (0,1.40,0) — kerah bahu x ±0.34, z ±0.26 |
| Drape depan | s 0.72/1.15/0.45 di (0,1.18,0.24) — depan 0.33 | s 0.72/1.15/0.30 di (0,1.18,0.20), rot.x -0.10 — depan 0.26, kain menempel dada |
| Strip sisi | kapsul r 0.045 di x ±0.235, tegak | kapsul r 0.035 di x ±0.225, rot.z ∓0.10 mengikuti rahang |
| Drape belakang (ronde 2) | pusat 1.33, skala y 1.30 | pusat 1.36, skala y 1.35 — ujung atas lebih lebar di y~1.60-1.66, menutupi pita kulit tengkuk |

Prinsip: semua bagian diratakan/dempetkan ke tubuh supaya terbaca SATU
kain (kepala-bahu-dada-punggung), bukan benda terpisah. Bukaan wajah
tetap 0.38; warna abaya+jilbab tetap dari outfit (kustomisasi jalan);
koko/songkok/serban putra TIDAK disentuh; v1 TIDAK disentuh.

Kompromi dicatat: saat duduk abaya melebar 1.55x (radius atas 0.357)
sehingga sisi cape (±0.34) bisa tenggelam di balik abaya — jilbab saat
duduk tetap terbaca dari kubah + drape depan/belakang + strip, dan
tampilan berdiri/jalan (yang dilihat Mas di HP) diprioritaskan.

## Tes

- Audit karakter (`skrip/audit_karakter_primitif.tscn`, headless):
  **122/0** (dulu 112/0 — +10 cek regresi hijab baru, 5 per karakter
  berhijab: drape depan ≤0.30, cape lebar ≤0.72, cape depan ≤0.30,
  drape belakang ≥-0.32, strip di tepi wajah).
- Foto SEBELUM/SESUDAH (`skrip/foto_hijab.tscn`, xvfb-run): 22 foto
  per sufiks — 2 karakter x (depan, samping, belakang, tiga-perempat,
  wajah, jalan depan, jalan samping) siang + malam.
  HASIL FOTO SESUDAH (dibaca langsung, 18 Nov ~08:15 WIB):
  - Depan siang+malam: cape jadi kerah bahu (bukan piring), drape
    depan jadi panel kain rata di dada (bukan telur/bundel) — TIDAK
    ada lagi yang terbaca "gendong benda aneh", siang maupun malam.
  - Samping + jalan samping: cape tidak lagi menjorok seperti rak;
    drape belakang jatuh tipis di punggung seperti kain; strip sisi
    tipis membingkai wajah.
  - Belakang: sombrero hilang; drape belakang terbaca kain jatuh
    dari kepala ke punggung tengah. Sisa jujur: masih ada pita kulit
    kecil di tengkuk atas (sisi atas drape, y~1.60-1.66) — bawaan lama,
    sudah ada di foto SEBELUM, sedikit lebih kelihatan setelah drape
    dipersempit; ronde 2 (drape dinaikkan 1.33->1.36) mengecilkannya
    tapi tidak menghilangkannya. Menutup penuh butuh panel lebih
    lebar (risiko kembali terbaca papan) atau menutupi alis (kubah
    tidak boleh turun) — dibiarkan, menunggu verdict Mas.
  - Wajah close-up: mata/alis/hidung/mulut tetap terbuka penuh;
    tepi kubah tepat di atas alis; bukaan wajah 0.38 tidak menyempit.

## Untuk Raka (ronde export berikutnya)

- Kode hijab di atas siap masuk export — audit 122/0.
- test_v2 TIDAK dijalankan ronde ini (edit hanya MeshInstance3D
  visual, tidak ada collision shape yang disentuh; test_v2 ranah
  export Raka seperti biasa).
- Sisa menunggu: verdict Mas atas foto sesudah.
