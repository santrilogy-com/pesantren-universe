# KAMERA — Status (Cakra, tim kamera Pesantren Universe)

## Ringkas
- **v1 (17 Nov ~23:45):** kamera "hidup" gaya handheld acuan reel
  @jipraks — follow halus + goyang napas/langkah + dinamika framing
  (FOV 60→66, spring +0,6 m, rig merendah saat kencang).
- **v2 (18 Nov ~00:16) — PERBAIKAN BUG MABUK, prioritas #1:** laporan
  Mas dari HP (alpha `ecd7e2e9`, 00:15 WIB): *"saat jalan kamera
  goyang seperti gempa; saat diam kamera bergerak sendiri sampai
  bikin pusing."* Goyang + dinamika framing **DIMATIKAN TOTAL**.
  Kamera sekarang: follow halus saja, diam = diam total (terukur
  nol), jalan = tanpa goyang. **Verdict akhir tetap HP Mas** setelah
  deploy ronde berikut. Tidak ada export/deploy di ronde ini.

## File yang diubah
- `scripts/kamera.gd` (BARU, ditulis ulang v2) — seluruh logika
  kamera: follow, orbit, penghalusan spring, kunci rotasi/FOV.
- `scripts/main.gd` (3 edit berjangkar, bagian kamera saja):
  member `_kamera`, instansiasi di `_ready` (setelah `_cam = cam`),
  blok follow di `_process` → panggil `_kamera.perbarui()` +
  `_kamera.terapkan_panjang_spring()`. Login/daftar/pintu/batas
  TIDAK disentuh. `_jarak_kamera_aman` (penjaga Eka) TIDAK diubah.
- `skrip/test_kamera.gd` + `skrip/test_kamera.tscn` (BARU) — tes ukur.
- `skrip/foto_kamera.gd` + `.tscn` (BARU) — foto framing
  sebelum/sesudah; `skrip/foto_kamera_k3.gd` + `.tscn` — K3 terpisah
  (VM padat: satu run penuh > 10 menit).

## Akar masalah bug mabuk (v1) — terukur, bukan tebakan
1. **Diam bergerak sendiri:** sway "napas" saat diam ±0,20°
   (0,0035 rad) TERUS-MENERUS — kamera tidak pernah benar-benar
   diam. Di layar HP kecil itu terbaca sebagai kamera bergerak
   sendiri.
2. **Jalan seperti gempa:** sway jalan 3 sumbu (yaw ±0,40°,
   pitch ±0,29°, roll ±0,34°) pada ~2,3 Hz + FOV berdenyut 60↔66
   mengikuti kecepatan joystick. Kombinasi itu = goyang gempa.
3. **Bukan penyebab:** bob badan pemain (`player.gd`) hanya
   menggerakkan `_visual`, bukan origin CharacterBody yang diikuti
   kamera — disingkirkan lewat grep. Raycast anti-tembus juga bukan
   penyebab getar di jalur tes (spring tetap 7,00 m), tapi tetap
   dihaluskan (lihat bawah) sebagai pertahanan.

## Perilaku v2 (yang berlaku sekarang)
- **Diam = DIAM TOTAL.** Tidak ada sway, drift, bob, atau denyut.
  Follow eksponensial frame-rate independent
  (`1-exp(-k·delta)`, selalu ≤ 1,0) + **SNAP**: rig < 5 mm dari
  target langsung ditempel persis (tanpa snap, pendekatan
  eksponensial merangkak selamanya — itulah "bergerak sendiri").
  `cam.rotation` di-NOL-kan tiap frame; FOV dikunci 60.
- **Jalan = follow halus saja.** Tanpa bob, tanpa sway, tanpa
  perubahan FOV/spring/tinggi. Orbit drag tetap jalan seperti dulu
  (lerp yaw/pitch 12/dtk).
- **Spring dihaluskan ASIMETRIS** (`terapkan_panjang_spring`):
  memendek CEPAT 25/dtk (keselamatan anti-tembus diutamakan),
  memanjang PELAN 4/dtk (kamera tidak melonjak keluar saat halangan
  lewat). Hasil raycast `_jarak_kamera_aman` TIDAK dipotong — hanya
  cara panjang itu diterapkan yang dihaluskan. SpringArm3D tetap
  lapis pertama anti-tembus.
- **"Hidup" gaya handheld DIPARKIR** sampai verdict HP Mas atas
  versi tenang ini. Kalau dihidupkan lagi, jalurnya lewat modul ini
  dengan amplitudo jauh di bawah ambang mabuk + tes ukur yang sama.
- Bokeh tetap TIDAK dipakai (keputusan tugas awal).

## Parameter (scripts/kamera.gd)
| Parameter | Nilai |
|---|---|
| Follow datar (X/Z) | 8,0 /dtk |
| Follow tegak (Y) | 6,0 /dtk |
| Lerp yaw/pitch orbit | 12,0 /dtk |
| Snap rig | < 0,005 m |
| FOV | tetap 60 |
| Spring memendek | 25,0 /dtk |
| Spring memanjang | 4,0 /dtk |
| Goyang (semua sumbu) | 0 |
| Tinggi rig | 0,9 tidur / 1,6 biasa |

## Hasil tes (headless, `nice -n -10`, 18 Nov ~00:35–00:45 WIB)
### Tes kamera — 21 lulus, 0 gagal (`skrip/test_kamera.tscn`)
- DIAM: posisi kamera tidak bergerak sama sekali (maks 0,000000 m)
- DIAM: rotasi kamera = 0 (maks 0,000000 rad)
- DIAM: FOV tetap 60 (selisih 0,00)
- Jalan maju 13,80 m (syarat ≥ 1,20 m)
- JALAN: rotasi kamera = 0 di semua frame (maks 0,000000 rad)
- JALAN: tanpa lompatan rotasi antar frame (maks 0,000000)
- JALAN: FOV tetap 60 (selisih 0,00)
- JALAN: spring memendek ≤ 26 m/dtk (dapat 0,0); memanjang
  ≤ 4,5 m/dtk (dapat 0,0) — di jalur lurus tidak ada halangan
- Rig menempel target 0,01 m (syarat < 1,5 m)
- Dorong ke tembok selatan Surau: garis pandang bersih
- Dekat dinding (0,0,-2): pemain betah di posisi; garis pandang
  bersih; kamera tidak di dalam benda padat; spring 7,00 m
- Dorong ke tembok barat Surau: garis pandang bersih
- Spring di balik tembok x=14: memendek CEPAT 1,99 m dalam 0,25 dtk
  (syarat < 3,0 m); menetap 1,95 m; memanjang PELAN 4,84 m dalam
  0,25 dtk (syarat < 6,0 m); kembali 6,91 m setelah 1 dtk
### Tes regresi v2 — 60 lulus, 0 gagal (`skrip/test_v2.tscn`)
- Satu kali sempat 59/60 ("Pintu tertutup saat start" — pintu
  taman, area Raka/Alur B); run ulang setelahnya 60/60. Bukan
  dari perubahan kamera (kamera tidak menyentuh `pintu_taman`).

## Foto framing (kamera game sendiri, 1280×720)
`~/workspace/pesantren-verse/v2/foto-kamera/sebelum/` (17 Nov ~16:48)
dan `.../sesudah/` (17 Nov ~17:52–18:03):
- `K1-diam-spawn.png` — spawn, Surau di depan. Sesudah: framing
  sama, FOV 60 (tanpa zoom). Beda waktu: sebelum = senja, sesudah
  = malam (jam game ikut jam nyata).
- `K2-jalan.png` — jalan maju. Sesudah: pemain berjalan sampai
  dinding Surau (joystick tertahan selama run lambat), kamera
  mengikuti sampai dekat dinding tanpa menembus.
- `K3-dekat-dinding.png` — pemain (0,0,-2) menghadap selatan,
  kamera di sisi dinding. Sebelum/sesudah SAMA: pemain terlihat
  lewat pintu Surau yang terbuka, dinding mengisi frame.
- Foto hanya membuktikan framing (foto diam tidak bisa menunjukkan
  goyang) — bukti gerak adalah angka tes di atas.

## Catatan yang ditemukan saat kerja (di luar kamera, diteruskan)
1. **Kamera bisa masuk ruang udara Surau lewat pintu TERBUKA**
   (perilaku LAMA, bukan regresi v2): sinar spring + sinar penjaga
   sama-sama lolos lewat bukaan pintu, jadi kamera di (0,~4,−8,6)
   berada di dalam aula lewat pintu, bukan menembus tembok padat
   (tes bola 0,3 m: tidak ada tumpang tindih). Framing K3 jelek
   (dinding memenuhi layar) tapi bukan clipping. Perbaikan
   penjaga (mis. tolak posisi kamera di dalam footprint gedung)
   adalah pekerjaan lanjutan — bukan di ronde ini.
2. **Bahaya tes paralel: `santri.json` bersama.** Save game di
   `~/.local/share/godot/app_userdata/Pesantren Universe v2/santri.json`
   ditulis bergantian oleh tes agen paralel. Saat K3 pertama
   diambil, isinya sempat `putri` → `_cek_batas` mendorong pemain
   dari (0,0,-2) kembali ke spawn putri (foto K3 pertama SALAH:
   area putri + toast "Santriwati tidak boleh masuk area putra").
   Perbaikan: `test_kamera.gd`, `foto_kamera.gd`,
   `foto_kamera_k3.gd` kini memaksa `_save["jenis_kelamin"] =
   "putra"` + asersi posisi pemain di tes (gagal keras kalau
   terdorong). Run foto di VM padat lambat: frame ~2–20 dtk
   (render software + 4–5 proses Godot paralel) — skrip foto
   diubah ke jeda berbasis WAKTU, bukan jumlah frame.
3. Warning baru (bukan dari kamera): `gubuk_masuk.gd:61` —
   "Adding 'Pintu' as child … owner 'GLB_GubukSawah' inconsistent"
   saat build (pekerjaan Alur B gubuk).

## Sisa / tindak lanjut
- Verdict HP Mas setelah deploy ronde berikut (Rangga export +
  Damar deploy) — kamera tenang ini yang diuji.
- Kalau Mas ACC versi tenang, "hidup" handheld boleh dicoba lagi
  SANGAT halus (di bawah ambang ukur tes ini) — jangan langsung
  kembalikan amplitudo v1.
