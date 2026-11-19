# Mode Kamera — Pesantren Universe v2

Penulis: Cakra, 18 Nov 2026 (~13:13 WIB, permintaan Mas: "Camera tambah..
drone, low angel, high angel dll. Biar enak" + koreksi 13:13 "Cukup
dicubit enak ngga? Kek biasanya. Cuma yg biasa ini masih belum luas
kameranya" + keputusan 13:19 soal nama di Drone & marker Asrama Putra).

Kode: `godot-dunia/scripts/kamera.gd` (modul `KameraPesantren`, semua
logika mode/transisi/zoom di sini) + integrasi minimal di `main.gd`
(panggilan per frame, input C + pinch, meta label Drone) dan `ui.gd`
(tombol "Kamera: ...", marker Asrama Putra) + `palette.gd` (boost label
Drone — satu baris meta, lihat bawah).
Tes: `godot-dunia/skrip/test_kamera.gd` (Bagian 6). Foto:
`v2/foto-kamera-mode/`.

## Cara ganti mode

- **Tombol UI** "Kamera: Normal" di kanan atas HUD (di samping tombol
  Suara) — ketuk = ganti mode. Label tombol selalu menunjukkan mode aktif.
- **Keyboard C** — siklus mode (di HP tidak ada keyboard; di sana
  pakai tombol UI).
- Siklus: Normal → Drone → Low Angle → High Angle → Sinematik → Normal.
- Mode aktif tersimpan selama sesi (variabel modul; ganti mode tidak
  me-reset zoom).

## Daftar mode (luar ruangan)

| Mode | Tinggi rig | Spring | Pitch | FOV | Keterangan |
|---|---|---|---|---|---|
| Normal (default) | 1,6 m | 8,0 m | ikut drag pemain (-1,0..-0,1) | 68 | Lebih LUAS dari sebelumnya (dulu 7,0 m / FOV 60) — koreksi Mas 13:13 |
| Drone | 1,6 m | 10,0 m | -1,05 rad (-60°) | 60 | Kamera tinggi dari atas, melihat ke bawah |
| Low Angle | 1,0 m | 4,0 m | +0,15 rad | 65 | Kamera rendah dekat tanah, melihat ke atas — rig 1,0 m (BUKAN 0,9): di 0,9 m kamera duduk 0,2995 m di atas tanah dan bola probe 0,3 m menyentuh tanah persis; 1,0 m → kamera ~0,40 m, aman dari gundukan/paving |
| High Angle | 1,6 m | 6,0 m | -0,85 rad (-49°) | 60 | Di atas pemain, lebih rendah dari Drone |
| Sinematik | 1,6 m | 8,0 m | -0,35 rad | 68 | Orbit SANGAT pelan: yaw +0,05 rad/dtk (1 putaran ~2 menit), tanpa goyang |

Di mode selain Normal, pitch dikunci ke target mode; drag yaw (orbit)
tetap jalan di semua mode.

## Transisi halus (tidak lompat)

Ganti mode TIDAK memindahkan kamera seketika: tinggi rig, pitch, dan
FOV efektif di-lerp eksponensial (3,5/dtk, pola `1-exp(-k*delta)` yang
sama seperti follow) ke target mode baru, lalu di-SNAP saat selisih
< 0,005 (supaya diam = diam total, bukan merangkak). Panjang spring
tidak di-lerp di sini — target spring diteruskan ke
`terapkan_panjang_spring()` yang sudah punya penghalusan asimetris
(memendek cepat 25/dtk, memanjang pelan 4/dtk). Tes mengukur laju
transisi per jendela 10 frame (jam mikrodetik — laju per frame
tunggal berantakan di bawah beban VM karena pasangan delta-vs-gerak
tidak stabil): FOV ≤ 30°/dtk (terukur 19,0), pitch ≤ 4 rad/dtk
(terukur 1,93), tanpa lompatan spring per frame ≤ 1,0 m (terukur
0,62 m), tanpa overshoot melewati target (terukur maks 10,00 m).
Penghalusan asimetris dibuktikan terpisah di Bagian 5 lewat prediksi
eksponensial pada waktu aktual (terukur: prediksi 5,86 m di t=0,26
dtk, dapat 5,49 m — cocok).

## Pinch-to-zoom (dicubit, "seperti biasa")

- Gestur: dua jari di layar. **Merenggang = zoom in** (kamera
  mendekat), **merapat = zoom out** (menjauh) — konvensi game HP biasa.
- Zoom = **pengali panjang spring (dolly), BUKAN FOV** — FOV tetap per
  mode/zona supaya framing tidak berubah rasa.
- Faktor target dijepit **0,55..1,30**, lalu dihaluskan eksponensial
  8/dtk (responsif tapi tanpa lompat; cubit tidak pernah mengubah
  kamera secara langsung).
- Faktor zoom itu **GLOBAL** (satu nilai untuk semua mode, selama sesi)
  — ganti mode tidak me-reset zoom, supaya cubit terasa konsisten.
- Batas keras per frame: spring efektif ≥ 2,0 m (tidak masuk ke pemain)
  dan ≤ 3,0 m bila tidur / ≤ 5,5 m bila di Asrama / ≤ 4,0 m bila di
  ruangan lain / ≤ 12,0 m di luar. Zoom-out TETAP lewat penjaga
  `_jarak_kamera_aman` + SpringArm3D (tidak tembus dinding).
- Selama cubit dua jari, drag satu jari bukan orbit (tidak bentrok).
- Trackpad (pengujian desktop): `InputEventMagnifyGesture` juga
  didukung (factor > 1 = merenggang = zoom in).

## Aturan Asrama & ruangan — KONTRAK LAMA MENANG

Keputusan: mode **dijepit** (bukan dinonaktifkan) di dalam ruangan —
mode tetap tercatat + nama tetap tampil di tombol, tapi parameter
efektif mengikuti kontrak ruangan. Alasan: tombol yang mati terasa
rusak; menjepit menjaga kamera tetap aman di semua mode.

- **Di Asrama (Putri & Putra):** spring 5,5 m (3,0 m bila tidur),
  pitch dijepit -0,22..-0,10, FOV 65, tinggi rig 1,6 m (0,9 m bila
  tidur). Kamera (y ≈ 2,8 m) tetap DI BAWAH pelat lantai atas (y 3,0).
  Drone di dalam Asrama TIDAK PERNAH menembus pelat. Yaw orbit +
  Sinematik tetap jalan (hanya memutar, tidak mengubah tinggi).
  **Dua lapis, jangan dicampur:** 5,5 m itu TARGET modul (dibuktikan
  tes 6a: `parameter_target` Asrama = 5,50 / -0,22 / 65,0). Di dunia
  nyata penjaga anti-tembus bisa memendekkan LEBIH JAUH — koridor
  Asrama hanya 2,6 m lebar: bila pemain menghadap melintang, kamera
  menghantam dinding koridor dan spring jadi 1,2 m (terukur); bila
  menghadap memanjang koridor (yaw PI/2, ke pintu barat), spring
  penuh 5,50 m tercapai, kamera y 2,82 m (terukur, tes 6d + foto M6).
  Keduanya benar — yang pertama penjaga bekerja, yang kedua jepit
  bekerja.
- **Di ruangan lain (Surau/Cangkruk/Kelas/Musholla/dll):** spring
  dijepit ≤ 4,0 m (kontrak RONDE 7: kamera di bawah plafon 3,6 m) +
  pitch dijepit -0,35..+0,15, FOV tetap ikut mode.
- **Saat tidur (di mana saja):** spring 3,0 m, tinggi rig 0,9 m.

## Anti-tembus (berlaku semua mode + zoom)

`_jarak_kamera_aman` (raycast kamera→pemain, main.gd) + SpringArm3D
tetap berlaku untuk SEMUA mode dan zoom-out. Kamera tidak menembus
dinding/lantai dan tidak keluar dunia — tes mendorong pemain ke tembok
dari 3 arah + memeriksa garis pandang bersih di mode Drone dan Low.

## Anti-mabuk (tetap penuh)

Goyang + denyut FOV DIMATIKAN TOTAL (v2). Diam = DIAM TOTAL (posisi
< 1e-6 m + rotasi < 1e-6 rad di tiap mode — 1e-6 m = lantai noise
float32, bukan gerak; cek DIAM Bagian 1 tetap == 0.0 persis —
kecuali Sinematik yang memang berputar pelan: rotasi kamera tetap 0,
hanya yaw orbit yang bergerak ~0,05 rad/dtk). FOV dikunci per
mode/zona, tanpa denyut.

## Nama pemain di mode Drone (keputusan Mas 13:19)

Nama tampil SELALU (keputusan multiplayer Fase 2), dan di Drone harus
**tampil dan terbaca jelas**. Tanpa boost, nama dari ketinggian ~10 m
hanya ~2,6% tinggi layar (tidak terbaca). Karena itu:

- `kamera.gd`: `pengali_label_drone()` = **2,5** saat Drone, 1,0 saat
  mode lain.
- `main.gd` menulis meta `drone_label_boost` pada kamera tiap frame.
- `palette.gd` `batasi_label_kamera()`: meta itu dipakai sebagai skala
  MAKS label (default 1,0) — berlaku untuk nama pemain, nama NPC, dan
  ikon misi (semuanya lewat fungsi ini).
- Hasil: nama di Drone **9,7% tinggi layar** (terukur, run hijau
  terakhir — skala 2,50), mode lain TIDAK BERUBAH (skala tetap maks
  1,0 — dites eksplisit).
- Tinggi label dihitung dari **metrik font** (`font.get_height() *
  pixel_size` = 0,43 m), BUKAN `Label3D.get_aabb()` — get_aabb
  mengembalikan kubus bersisi = LEBAR teks ("A" 0,43 m; "Tes kamera"
  1,25 m; "Ahmad Muntahal Hadi" 2,44 m), padahal tinggi teks sama.
  Memakai get_aabb sebagai tinggi membuat nama panjang nyaris tidak
  ter-boost (skala 0,88) — ini akar kegagalan boost di run tes
  pertama.
- Aturan tampil nama lainnya tidak berubah: nama muncul bila kamera
  < 28 m, disembunyikan saat tidur / panel chat terbuka.

## Marker peta Asrama Putra (keputusan Mas 13:19: "Tambah")

Setelah kotak emas plot hilang (tahap 2 "Asrama" di
`MissionData.GROWTH_STAGES` sudah `"dibangun"`), gedung Asrama Putra
harus bertanda di peta:

- `ui.gd` `PetaControl.GEDUNG_PUTRA` = `[["ASRAMA PUTRA",
  Vector2(-24, 10), Vector2(18, 12)]]` — posisi + ukuran dari
  `AsramaPutra` (pos (-24,0,10), badan 18×12 m), ditulis literal
  mengikuti pola `GEDUNG_PUTRI`.
- **Peta besar:** kotak krem berbingkai zamrud tergambar di mana-mana
  (pass kotak, seperti gedung putri); label "ASRAMA PUTRA" tampil saat
  zoom detail (`tampil_label`, seperti MUSHOLLA/CANGKRUK).
- **Minimap:** kotak krem 8×8 bila dalam jangkauan (45 m), seperti
  gedung putri.
- `_data_peta()` (main.gd) tidak butuh kunci baru: peta membaca
  konstanta gedung langsung, sama seperti GEDUNG_PUTRI.

## Nilai kunci (untuk tes)

- Normal luar: FOV 68, spring ~8,0 m. Asrama: FOV 65, spring target
  5,5 m (terukur memanjang koridor 5,50 m, y 2,82; melintang koridor
  1,20 m karena penjaga). Ruangan: spring ≤ 4,0 m.
- Drone: spring target 10,0 m, pitch -1,05, FOV 60, label 9,7% layar.
- Zoom: target dijepit 0,55..1,30 (0,5x TIDAK ADA — dijepit ke 0,55);
  zoom 0,6x → spring ~4,8 m (Normal). Zoom GLOBAL, bukan per mode.
- Sinematik: laju yaw 0,03..0,08 rad/dtk (target 0,05; terukur 0,050).
- DIAM tiap mode: posisi < 1e-6 m, rotasi < 1e-6 rad (1e-6 m = lantai
  noise float32, bukan gerak — kontrak 5 mm Bagian 1 tetap == 0.0).

## Tombol "Main Bersama" pindah (temuan Nadia 13:43 WIB)

Tombol "Main Bersama" (Dimas) dulu anak VBox kiri, di bawah label
status (y~96..140, x 16..176) — TERTUTUP lingkaran minimap (16,96,
190×190) yang digambar belakangan; teks "Main" setengah hilang
(lihat foto `v2/foto-area-putri/halaman-revisi-dari-jalan.png`).
Dipindah Cakra 18 Nov 13:44 ke anak `_hud` langsung di **(216, 116)**:
di kanan minimap, di bawah toast tengah-atas (y 70..110), di atas
feed chat (y≥256), jauh dari bar kanan-atas (y 12..56). HANYA posisi
yang pindah — teks, ukuran (160×44), sinyal tidak berubah. Bukti:
foto M1–M7 (tombol terlihat penuh di semuanya) + foto revisi taman
ronde-2 Nadia (13:54) yang sudah menunjukkan tombol penuh.

## Tombol Kamera lebar tetap (temuan dari foto M3/M4/M5)

Nama mode terpanjang "Kamera: High Angle" melebihi minimum 150 px —
Button mengembang mengikuti teks, bar kanan-atas bergeser, "Layar
Penuh" terpotong di tepi kanan (terlihat di foto M3/M4/M5 run
pertama). Perbaikan: tombol Kamera **lebar tetap 240 px +
`clip_text = true`**, offset bar kanan-atas -870 → **-960**
(160+84+64+84+84+240+160 = 876 + 6×8 = 924, +36 = 960). 190 px
ternyata masih memotong teks jadi "Kamera: High An" (foto M4 run
kedua) — 240 px muat semua nama mode lengkap. Semua nama mode muat
tanpa mengembang; "Layar Penuh" tidak lagi terpotong
(verifikasi di foto M3/M4/M5 run terakhir).

## Hasil tes + foto (final)

- `test_kamera`: **77 lulus, 0 gagal** (log `/tmp/test_kamera_v3l.log`,
  18 Nov ~14:1x WIB). `test_v2`: **60 lulus, 0 gagal**
  (`/tmp/test_v2_kamera3.log`).
- Foto (lanskap 1280×720, avatar putra "Foto Kamera", offline):
  `v2/foto-kamera-mode/` — M1 Normal luas, M2 Drone (nama terbaca),
  M3 Low Angle, M4 High Angle, M5 Sinematik, M7 Normal zoom-in 0,6x,
  M6 Drone-di-Asrama dijepit (koridor, spring 5,5 m). M1 sekaligus
  bukti tombol "Main Bersama" terlihat penuh. Potret tidak bisa
  difoto in-game (game memaksa lanskap — overlay "PUTAR HP-MU").
- TIDAK deploy (sesuai batasan). Isolasi MP di tes + foto mengikuti
  pola `test_v2.gd` (kosongkan `ig_username` + paksa gender sebelum
  masuk — save disk bisa tertinggal akun tes MP Dimas).
- **Skrip foto memulihkan save di akhir (Cakra, 18 Nov 14:3x):**
  foto memakai nama "Foto Kamera" + gender putra di MEMORI — tapi
  `_masuk_pesantren` memanggil `_terapkan_gender_pemain()` yang
  MENYIMPAN seluruh `_save` ke disk, jadi nilai palsu itu tertinggal
  di `santri.json` dan label "Foto Kamera" muncul di sesi/foto agen
  lain (temuan Kirana 14:28). Skrip kini menyimpan nama + gender +
  outfit asli di awal, lalu memulihkan ketiganya + `save_data`
  SEBELUM quit. Disk sudah dibersihkan manual 14:38 (nama kembali
  "Tes MP Putri", putri, muslimah/hijab true; backup file
  terkontaminasi di `/tmp/santri-sebelum-bersih.json`). Catatan jujur:
  bila proses foto mati paksa di tengah jalan, disk tetap
  terkontaminasi — bersihkan manual seperti di atas. Pola yang sama
  (gender di memori ikut tersimpan saat masuk) juga berlaku untuk
  skrip tes — ranah Eka sekarang.
