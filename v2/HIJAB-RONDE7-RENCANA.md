# HIJAB PUTRI RONDE 7 — RENCANA + HASIL

Koreksi Mas atas 3D ronde 6 (18 Nov 10:54 WIB): "Jilbab harus menutupi
pipi lalu ke dagu dan ke dada. Seperti referensi."

## Diagnosis — arah ronde 6 salah

Ronde 6 MELEBARKAN bukaan wajah (trapesium, strip dibalik miring ke
luar) supaya tidak terbaca biarawati. Tapi itu justru mengekspos pipi
penuh. Yang Mas mau kebalikannya: kain MENUTUPI PIPI — bukaan wajah
menyempit di sisi pipi sehingga yang terlihat hanya bagian tengah
wajah (mata, hidung, mulut), lalu kain turun ke dagu, lalu ke dada.
Seperti tampilan DEPAN di gambar konsep (konsep-jilbab-v1.png): bukaan
wajah oval, pipi tertutup kain.

## Desain (bukaan wajah saja — yang lain dipertahankan)

Alasan teknik — strip sisi TIDAK BISA menutupi pipi: strip duduk di
z -0,05 (depan z -0,01), sedangkan permukaan pipi di y 1,55..1,66
ada di z 0,12..0,20 — strip berada 0,13..0,21 m DI BELAKANG pipi,
jadi dari depan strip tidak pernah menutupi kulit pipi. Yang
menutupi pipi harus kain yang duduk DI DEPAN permukaan pipi:

1. **HijabPipi BARU (2 bola pipih)** — membungkus pipi kiri-kanan
   seperti kain jilbab, teknik yang sama seperti HijabLeher di
   leher. Bola r=0,12 di (±0,16, 1,60, 0,10), skala (0,7, 1,0,
   0,9) — depan maks z 0,208 (di depan permukaan pipi 0,12..0,20),
   tepi dalam x 0,076. Bukaan jadi OVAL: ±0,13 di pipi, ±0,16 di
   mata, seperti gambar konsep. Atas menyatu ke kubah (y 1,72),
   bawah menindih HijabDagu (y 1,48) — satu kain pipi -> dagu ->
   dada, tanpa celah.
2. **Strip sisi dibawa MASUK** (pusat x 0,232 -> 0,22) supaya
   bingkai merapat ke pipi. Tepi dalam strip di tinggi mata ~0,16;
   bukaan wajah ditentukan HijabPipi.
3. **Kacamata aman**: lensa di z 0,238 selalu di depan pad (maks
   0,208); gagang masuk di bawah kain (wajar seperti kacamata di
   balik jilbab asli). Mata/hidung/mulut/alis tetap terlihat.

## Verifikasi numerik (grid Python, SEBELUM menyentuh kode)

Grid (x -0,24..0,24, y 1,45..1,78, langkah 0,01): permukaan
terdepan di tiap titik dihitung untuk kepala, kubah, leher, dagu,
pad, kacamata.

- TANPA pad (ronde 6): **194 titik kulit di zona pipi**
  (y 1,55..1,66, |x| 0,14..0,22) — pipi terekspos penuh.
- DENGAN pad: **0 titik kulit di zona pipi DAN 0 kain di tengah
  wajah** (mata/hidung/mulut/alis). Desain terukur, bukan tebakan.

## Dipertahankan (jangan dirusak)

- Dagu tertutup (HijabDagu), leher terbungkus tanpa celah hijau,
  dada tertutup sampai dada tengah dengan tepi bawah U, lipatan
  diagonal ronde 6, kubah longgar, belakang satu kerudung menyatu.
- Recolor: HijabPipiKiri + HijabPipiKanan masuk daftar warna-sama
  di `_warnai_ulang`.

## Verifikasi

- Audit karakter: **178/0** (ronde 6: 170/0 + 8 cek ronde 7 baru
  x 2 karakter — putri + ustadzah: 2 pipi ada; pipi bukan kotak;
  pipi menutupi pipi (depan z 0,21 >= 0,19, irisan dgn kepala);
  pipi tidak menutupi tengah wajah (tepi dalam |x| 0,08 >= 0,07)).
- test_v2: **60/0**.
- Foto 22/22 (foto_hijab.gd, -- sesudah). Foto ronde 6 diarsipkan
  ke `foto-hijab/ronde6-sesudah/` (22 file).
- Hanya player.gd + skrip audit + foto + dokumen ini yang disentuh.
  main.gd, kampus_putri.gd, interior, kamera.gd TIDAK disentuh.
  TIDAK deploy — export + deploy urusan Xam.

## Catatan jujur (penilaian Mas)

1. **Pipi TERTUTUP** — bukaan wajah kini oval sempit: yang terlihat
   hanya tengah wajah (kacamata, mata, hidung, mulut). Grid
   membuktikan 0 titik kulit di zona pipi; foto depan + close-up
   (putri + ustadzah) mengonfirmasi. Arah ronde 6 sudah dibalik.
2. **Pad pipi agak GEMBUNG** — bola pipih terbaca sebagai dua
   gumpalan kain bulat lembut di sisi wajah, bukan kain yang
   menempel rata seperti di gambar konsep. Masih jelas jilbab
   (bukan biarawati, bukan topi), tapi ini batas primitif: bola
   tidak bisa diratakan lebih jauh tanpa menelan pipi.
3. Dari SAMPING, pad menyatu dengan kubah + drape — tidak ada
   tonjolan aneh; profil wajah (hidung + kacamata) tetap terbaca.
4. Lipatan diagonal di dada masih garis lurus tipis (catatan
   ronde 6, batas primitif).
5. Ujung bawah belakang masih agak kotak (catatan ronde 2, di
   luar brief — gambar konsep belakang juga ujungnya agak lurus).
