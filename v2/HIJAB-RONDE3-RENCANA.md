# HIJAB PUTRI RONDE 3 — Rencana penerapan (Kirana, 18 Nov 2026, ~08:20 WIB)

Verdict Mas (08:12 WIB, dari foto ronde 2): "Jilbabnya harusnya di bagian
depan juga. Sampai dagu."

## Diagnosis (baca sendiri dari foto `v2/foto-hijab/putri_wajah_siang_sesudah.png` ronde 2)

- Belakang: benar (satu kerudung menyatu, tidak ada kulit) — JANGAN disentuh.
- Depan: di bawah dagu sampai kerah abaya ada pita kulit persik selebar
  wajah — itulah "leher" yang dilihat Mas. Bahu bersih (piringan hilang),
  dada benar (patch HijabDepan menempel).
- Akar: HijabLeher ronde 2 (elipsoid r=0,21 di (0,1,42,0), skala
  1,0/0,45/0,58) di y=1,47..1,51 duduk DI DALAM kepala — depan z-nya
  0,103 (y=1,47) / 0,037 (y=1,51) vs permukaan kepala 0,147 / 0,187.
  Kulit kepala (dagu/rahang bawah) lebih depan daripada kain, jadi dari
  depan yang terlihat kulit, bukan kain. Puncak elipsoid 1,51 tidak
  relevan kalau z-nya kalah dengan kepala.

## Catatan soal angka "dagu ~1,58" di brief

Dagu TIDAK BISA di 1,58: mulut ada di y=1,55 (node Senyum), hidung 1,62,
mata 1,69 — dagu pasti DI BAWAH mulut. Yang benar: kepala bola r=0,24 di
y=1,66; permukaan depan z(y) = sqrt(0,24^2-(y-1,66)^2): 1,55 -> 0,213;
1,51 -> 0,187; 1,50 -> 0,179; 1,48 -> 0,159; 1,44 -> 0,096; dasar 1,42.
"Garis dagu" (tempat tepi kain harus bertemu) diambil y~1,51 di tengah:
tepat di bawah mulut (1,55) dengan dagu terlihat 1,51..1,55 (~0,04 m),
dan di bawah 1,51 kain menutup semua. Kalau kain naik sampai 1,58 ia
menutupi mulut — dilarang brief sendiri ("jangan menutupi mulut/dagu").

## Kenapa bukan elipsoid leher yang diperbesar

Elipsoid TIDAK BISA mengikuti lengkung bawah kepala: permukaan kepala
jatuh curam (z 0,213 di 1,55 -> 0,096 di 1,44), sedangkan elipsoid
dekat ekuatornya datar. Supaya depan z >= 0,19 di y=1,51, elipsoid butuh
az ~0,19 — lalu di ekuatornya (y~1,47) depan z jadi ~0,23, hampir
setinggi hidung (0,237): tonjolan bundel/janggut di bawah dagu, persis
cacat "gendong benda aneh" ronde 1. Solusi: FRUSTUM (kerucut terpancung)
— depan z-nya turun LINEAR mengikuti dagu, tanpa menggembung.

## Nilai baru: HijabDagu — BARU (frustum di bawah dagu, bukan ganti leher)

- Baru: `Palette.cylinder(0,178, 0,155, 0,21, Vector3(0, 1,405, 0,02), warna_hijab)`
  y 1,30..1,51; r atas 0,178 -> bawah 0,155; pusat z +0,02. Warna SAMA
  kubah (masuk daftar recolor warna-sama, sejajar HijabLeher).
- HijabLeher ronde 2 TIDAK BERUBAH (tetap membungkus leher bawah/samping
  y 1,33..1,51 dan bertemu abaya; frustum baru duduk DI DEPANNYA).
- HijabDepan TIDAK BERUBAH. HijabCape tetap DIHAPUS (tidak dihidupkan).

Bukti hitung (depan z frustum vs permukaan kepala, x=0):
- y=1,51: kain 0,198 vs kepala 0,187 (kain +0,011 — tepi kain bertemu dagu)
- y=1,50: kain 0,197 vs kepala 0,179 (+0,018)
- y=1,48: kain 0,195 vs kepala 0,159 (+0,036)
- y=1,45: kain 0,191 vs kepala 0,116 (+0,075 — kain jatuh hampir vertikal
  dari dagu ke dada, seperti kain jilbab sungguhan; depan maks 0,198
  masih 0,012 DI BELAKANG mulut 0,210, jadi mulut tidak tertutup dan
  dari samping siluet dagu-dada tidak melewati garis mulut/hidung)
- y=1,42: kain 0,188; y=1,41: kain 0,187 vs ujung HijabDepan 0,200 —
  dada menutupi sambungan; y=1,30: r=0,155, jauh di dalam abaya (r 0,242)
  — cap bawah tersembunyi, tidak ada tepi menggantung.
- Verifikasi grid (Python, langkah 0,01, semua permukaan): 0 titik kulit
  terdepan di daerah leher (y 1,42..1,51, |x| <= 0,16); wajah y 1,52..1,60
  tetap kulit penuh (|x| <= 0,12). Varian pertama (r atas 0,172) masih
  menyisakan 10 titik kulit di y=1,51, |x| >= 0,12 (tepi rahang) — varian
  0,178 menutup semuanya.
- Sisi: lebar frustum di y=1,48 x ±0,175 (strip dalam ~0,185); celah
  0,01 di antaranya didukung drape belakang (depan z -0,06 di titik itu,
  warna sama) — tidak ada kulit dari depan/samping, seperti ronde 2.

## Audit (skrip/audit_karakter_primitif.gd, blok hijab saja)

Cek ronde 3 (baru, per karakter putri + ustadzah):
- HijabDagu ada; bukan BoxMesh (CylinderMesh).
- Puncak mencapai garis dagu: end.y 1,50..1,53 (di bawah mulut 1,55).
- Depan menutupi leher: end.z >= 0,19 (permukaan kepala di y=1,50 = 0,179).
- Tidak menutupi mulut: end.z < 0,21 (mulut z=0,210) dan end.y < 1,55.
- Menyambung ke bawah: position.y <= 1,35 dan beririsan dengan Abaya.
- Cek lama tetap: cape tidak ada, leher ada + irisan kepala/abaya, kubah
  lebih lebar dari kepala, drape lebar di atas, bukaan wajah terbuka.

## Cara verifikasi

1. Hitung: tabel z(y) di atas + grid Python (0 titik kulit di leher).
2. Audit headless: `godot --headless --path . skrip/audit_karakter_primitif.tscn`
   — harus 0 gagal (ronde 2: 130/0). test_v2 (60/0) harus hijau lagi.
3. Foto: `xvfb-run godot --path . skrip/foto_hijab.tscn -- sesudah`
   (foto ronde 2 SUDAH diarsip ke `foto-hijab/ronde2-sesudah/`, 22 file).
   Baca sendiri: close-up DEPAN wajah+dagu+leher (bukti kunci — tidak
   boleh ada pita kulit persik di bawah dagu), samping (dagu-dada satu
   garis kain, tidak ada bundel), depan jauh, belakang (tetap menyatu).

## Yang TIDAK disentuh

- main.gd, kampus_putri.gd, interior_asrama_putri.gd, v2/export/
  (tim Nadia/Lestari: perbesaran Asrama Putri, deploy bundled yang sama).
- Hanya cabang hijab scripts/player.gd (node baru + 1 nama di recolor)
  + blok cek hijab di skrip audit.
