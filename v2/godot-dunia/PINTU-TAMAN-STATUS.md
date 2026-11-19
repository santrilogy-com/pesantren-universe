# PINTU PAGAR TAMAN — STATUS (Gilang, Tim Maps)

**18 Nov 2026, ~02:40 WIB. Ronde export BERIKUTNYA (bukan build 00:03 yang sedang di-deploy Damar).**
**Tidak ada export / deploy dari ronde ini.**

## PINTU LEBIH CEPAT + PAPAN RUANG KELAS GESER — SELESAI (Gilang, 18 Nov 2026, ~02:40 WIB — 2 item audit tabrakan Bagas)

**Item 1 — Pintu taman buka lebih cepat/awal (PRIORITAS):**
`scripts/pintu_taman.gd` — `JARAK_BUKA` 2,6 → **4,0 m**, `JARAK_TAHAN`
3,6 → **5,0 m** (histeresis tetap: tahan > buka), `KECEPATAN_GESER` 1,6 →
**3,2 m/dtk**. Hitungan: pemain 6 m/dtk tiba 0,67 dtk setelah pemicu;
buka penuh 0,66 dtk; celah cukup untuk kapsul r=0,35 (~0,42 dtk).
**Ukur headless** (`skrip/ukur_pintu_taman.gd`, 2 run): transit (0,21)→(0,25,5)
**0,77–0,80 dtk (ideal 0,75)**; dwell di zona blokir z 24,9..25,6 cuma
**0,05–0,17 dtk** (isinya transit 0,7 m ÷ 6 m/dtk ≈ 0,12 dtk — praktis
TANPA menunggu, target ≤0,3 dtk TERCAPAI); kemajuan 0,81–0,91 saat
z=25,0, pintu terbuka penuh sebelum pemain tiba. **Tutup-otomatis tetap
jalan** (regresi di probe yang sama); hook `set_abaikan_npc` TIDAK
disentuh; `jalur_terhalang` tetap menahan daun (anti-tembus — pintu
menahan diri daripada mendorong pemain/NPC; dampaknya mengecil karena
pintu kini sudah terbuka sebelum siapa pun tiba di jalur geser).

**Item 2 — Papan plot Ruang Kelas geser 5 m ke timur:**
`scripts/pesantren_builder.gd` `_plot` — `geser_x = 5.0` untuk
"Ruang Kelas" (preseden geser papan Masjid Besar/Perpus; barat =
tembok, jadi timur satu-satunya arah bersih). Papan **(16,4,6) →
(21,4,6)**, tiang **(14/18,4,6) → (19/23,4,6)**. Papan node TERPISAH
di kode builder (bukan GLB) — geser via kode, tanpa Bima.
**Ukur headless** (`skrip/ukur_pintu_taman.gd`, 15/15): tepi barat
papan 18,90 (0,40 m dari dinding pos 18,5); tiang barat 19,0 (0,5 m
dari pos, 4,7 m dari tembok 14,2); tiang timur 23,0 di luar pos;
**6/6 mesh pohon rindang (22,6) bersih** — tajuk terendah y 4,38
(2,38 m di atas papan), batang x 21,6..22,4 / z 5,6..6,4 (0,94 m
dari bidang papan); dorong fisik: papan baru menahan dari utara
(z 4,19) + dari timur (x 23,45). Pos satpam + tembok TIDAK digeser.
**Foto:** `~/workspace/pesantren-verse/v2/foto-papan-kelas/` F1
(tenggara) + F2 (selatan, siang paksa jam 10:00) — papan putih
"LAHAN RUANG KELAS / Dibuka saat 25 santri" berdiri sendiri di
dua tiang, celah jelas ke pos satpam (cokelat, di barat) + tembok
di belakangnya; tiang barat tidak lagi di tembok. **Catatan jujur:**
dari arah selatan, batang pohon rindang (22,6) berdiri TEPAT di
depan papan (1,4 m di selatannya) sehingga sebagian label
tertutup batang di F1/F2 — BUKAN tabrakan (probe: batang 0,94 m
dari bidang papan, tajuk 2,38 m di atas papan), tapi keterbacaan
papan dari selatan berkurang. Kalau Raka/Mas menilai mengganggu,
pohon (22,6) yang digeser — bukan papan (follow-up, bukan ronde ini).

**Tes: `test_v2` 60 lulus, 0 gagal (exit 0, run 18 Nov ~02:35 WIB)** —
blok pintu taman 16/16 tetap hijau. Probe ukur 15/15 (run ke-2;
run ke-1 14/15 — 1 gagal semu: cek AABB gabungan pohon terlalu
kasar, diperbaiki jadi cek per-mesh).

**Ronde pintu cepat + papan geser (18 Nov 2026, ~02:40 WIB):**

- `scripts/pintu_taman.gd` — `JARAK_BUKA` 2,6 → 4,0; `JARAK_TAHAN`
  3,6 → 5,0; `KECEPATAN_GESER` 1,6 → 3,2; komentar header +
  konstanta diperbarui (temuan Bagas + hitungan).
- `scripts/pesantren_builder.gd` — `_plot`: `geser_x = 5.0` untuk
  "Ruang Kelas" + komentar (alasan geser + jarak bersih); komentar
  lama "perlu diputuskan" diperbarui jadi keputusan geser papan.
- Probe + foto sementara `skrip/ukur_pintu_taman.gd/.tscn`,
  `skrip/foto_papan_kelas.gd/.tscn` (+ `.uid`) **sudah dihapus**
  setelah dipakai (log: `/tmp/ukur_pintu_taman3.log`,
  `/tmp/test_v2_gilang.log`). Foto F1–F2 di
  `~/workspace/pesantren-verse/v2/foto-papan-kelas/`.
- Cache `.godot` diregenerasi via `--import` (±25 dtk, hanya cache).
- `nice -n -10` tetap ditolak (bukan root, sama seperti ronde lalu).

## GESER BANGKU — SELESAI (Gilang, 18 Nov 2026, ~01:10 WIB — keputusan Raka opsi a)

**Bangku utara pindah (0,25,45) → (-3,25,45), rotasi tetap 0 (tetap
menghadap pintu/jalur batu).** Jalur masuk x=0 kini bersih: pemain
berdiri di titik bangku lama tanpa menyentuh apa pun (foto F6),
sudah lewat garis bangku menuju peti (foto F6b).

**Struktur GLB (dump `taman.glb` 18 Nov, probe sudah dihapus): bangku
node TERPISAH, bukan satu mesh** — langsung di bawah root GLB, rotY 0
semua: `Bangku_Duduk` (0,0,45,-2,55), `Bangku_Sandaran` (0,0,75,-2,31),
`Bangku_Sandaran_001` (0,0,95,-2,31), `Bangku_Kaki` (-0,80,0,22,-2,55),
`Bangku_Kaki_001` (0,80,0,22,-2,55). Jadi geser via kode BISA, tanpa
edit GLB. Verifikasi posisi di dunia hasil build (probe `cek_bangku`,
sudah dihapus): kelima node di x=-3,00, rotY 0,0; bangku timur
`Bangku_Duduk_001` (3,45, 28,20, rotY 90°) TIDAK tersentuh.

**Sisi BARAT dipilih (bukan timur):** timur sudah ada Bangku_001
(3,45, 28,2) — geser ke timur menumpuk dua bangku di satu sisi.
**CATATAN JUJUR — petak bunga:** tidak ada sisi yang sepenuhnya
lapang di z yang sama. Bedeng_0 barat (x -3,8..-1,4, z 25,2..26,4,
tanah y 0..0,25) ikut tertutup sebagian bangku baru (x -3,9..-2,1,
z 25,2..25,72): kedua kaki berdiri di atas bedeng, ±3 bunga
(y 0,44..0,56) di bawah papan duduk. Sisi timur SAMA SAJA (Bedeng_1
x 1,4..3,8 simetris, 3 bunga juga di bawah duduk). Di foto F6 bangku
terlihat duduk di tepi bedeng — terbaca wajar dari jauh, tapi
kakinya memang di atas tanah bedeng. Kalau Raka/Mas menilai
janggal, perlu edit GLB (Bima): geser bangku juga ke selatan /
putar, bukan hanya x. Bangku tetap TANPA collision (seperti semua
GLB taman) — tapi kini di luar jalur masuk, jadi pemain di x=0
tidak lagi menembusnya. Jarak ke muka peti tetap 1,83 m (geser x saja).

**Tes: `test_v2` 60 lulus, 0 gagal (run ke-2, exit 0) — blok pintu
taman 16/16** (pagar ada, pintu ada, 9 segmen, tengah utara dilepas,
tertutup saat start, menahan dari utara/dalam + pagar 4 sisi + sudut
barat-laut, buka otomatis, daun geser ke timur (2,07, 0, 25,72),
masuk berhenti di depan peti (0, 27,27), tutup otomatis).
Run ke-1: 59/1 — `Kolong tertutup` gagal sekali (pemain (24,41,
-0,31, 30,0)), lalu LOLOS di run ke-2 tanpa perubahan kode:
**flaky, bukan efek geser bangku** (kolong gubuk di (24..26,30),
±27 m dari bangku; `gubuk_masuk.gd` + `test_v2.gd` tak berubah sejak
17 Nov). Raka yang menilai apakah kolong flaky ini perlu ditindak.

**Insiden saat run — cache kelas Godot basi (BUKAN dari ronde ini):**
probe pertama gagal kompilasi `main.gd` — `RakBukuPutri` (modul Dewi,
17 Nov) tidak terdaftar di `.godot/global_script_class_cache.cfg`
(0 entri; 3 file tanpa `.uid`: `rak_buku_putri.gd`,
`interior_kelas_putri.gd`, `interior_gedung_putri.gd`). Diperbaiki
dengan `godot --headless --path . --import` (±1 mnt, hanya
regenerasi cache `.godot`, tidak menyentuh source) — setelah itu
probe + `test_v2` bersih tanpa SCRIPT ERROR. Kalau run headless
tim lain tiba-tiba gagal kompilasi kelas baru, ini penyebabnya.

## Ringkasan

Bug yang dikonfirmasi Mas dari HP (00:20 WIB, alpha `ecd7e2e9`): **taman tidak bisa
dimasuki — kehalang benda**. Itu persis tes gagal export "Masuk lewat pintu taman
berhenti di z=25,27". **Selesai di ronde ini (kode + tes + foto).** Verdict akhir
tetap dari HP Mas setelah deploy ronde berikut.

**Hasil tes: `test_v2` 60 lulus, 0 gagal — blok pintu taman 16/16.**
Pintu tertutup menahan dari 4 sisi + sudut + dari dalam; buka otomatis saat pemain
mendekat; daun geser ke timur (2,02, 0, 25,71); **masuk lewat pintu berhenti di
depan peti (0, 27,26447)**; tutup otomatis saat pemain menjauh.

## Perbaikan 1 — peti pindah (0,26) → (0,28)

Diagnosis: peti lama hanya 0,5 m di belakang garis pagar (z 25,5): muka utaranya
z 25,625, kapsul r=0,35 mentok di z 25,275 — pemain tak bisa lewat garis pagar
(|x|≤0,65 lewati pagar, |x|≥0,9 lewati peti: tak ada jalur).

- `scripts/pesantren_builder.gd`: `PETI_POS := Vector2(0, 28)` (+ komentar ukur).
- Peti baru di tengah taman, di jalur batu: muka utara z 27,625, pemain berhenti
  z ~27,28 (tes: 27,26447 — sesuai hitungan).
- **TEMUAN saat menerapkan — penanda M3 ternyata HARDCODE, bukan baca konstanta:**
  `scripts/mission_data.gd` M3 `"penanda": Vector3(0, 0, 26)` (dipakai
  `_misi_terdekat` + target peta/minimap). Kalau tidak ikut diubah, penanda misi +
  target peta tetap menunjuk titik lama (2 m meleset, di dekat bangku). Sudah
  diubah ke `Vector3(0, 0, 28)` + komentar peringatan ("kalau peti pindah lagi,
  ubah juga"). Pembaca lain TERKONFIRMASI dinamis dari `PETI_POS`: `_peti`
  (builder), syarat misi `peti` di `main.gd` (`chest_pos` dari `PETI_POS`),
  peta/minimap (`data["peti"]` dari `PETI_POS`).
- Jarak interaksi misi tetap aman: pemain di depan peti (27,28) berjarak 0,72 m
  dari peti (ambang 3,5 m).
- `skrip/test_v2.gd`: dorongan masuk 60 → 120 frame (pemain sempat menunggu daun
  geser terbuka), asersi z 25,7..26,5 → **26,5..27,6**.
- `skrip/foto_pintu_taman.gd`: F4 teleport (0,27,5) → **(0,27,0)** — (0,27,5)
  kini menabrak collision peti (muka utara z 27,625).

### Cek bangku vs peti — TIDAK bertabrakan

Dump `taman.glb` (probe sementara, sudah dihapus): bangku utara di **(0, 25,45)**
— duduk x −0,9..0,9, y 0,41..0,49, z 25,20..25,70; sandaran z 25,66..25,72.
Muka utara peti baru z 27,625 → **jarak 1,83 m**. Foto F5 (overview) mengonfirmasi:
peti di tengah taman, bangku 2,5 m di utaranya, tidak bersentuhan.

## Perbaikan 2 — hook tes `set_abaikan_npc(true)`

`scripts/pintu_taman.gd`: `var _abaikan_npc`, `func set_abaikan_npc(v)` — kalau
true, NPC tidak dihitung sebagai aktor pemicu di `_posisi_aktor()`. **Hanya
untuk tes; perilaku game tidak berubah** (NPC tetap ikut membuka pintu — waypoint
(0,30) memang di dalam taman). `test_v2.gd` memanggilnya sebelum tes buka-otomatis
supaya buka/tutup deterministik (hanya pemain). Sebelumnya NPC yang kebetulan
melintas gerbang menahan pintu terbuka dan tes tutup-otomatis gagal.

## Foto — `~/workspace/pesantren-verse/v2/foto-pintu-taman/`

| Foto | Isi | Verifikasi |
|---|---|---|
| F1-tertutup-luar.png | Pintu tertutup dari luar | Bilah bambu menutup bukaan penuh; tiang + balok + label TAMAN; bangku terlihat tepat di belakang pintu |
| F2-terbuka-luar.png | Pintu terbuka dari luar, pemain (0,23) | Bukaan bersih; daun geser ke timur menumpuk di pagar timur; bangku terlihat lewat bukaan |
| F3-tertutup-dalam.png | Pintu tertutup dari dalam (pemain di (0,14)) | Bilah menutup penuh; peti di foreground; bangku di belakang pintu |
| F4-terbuka-dalam.png | Pintu terbuka dari dalam, pemain (0,27,0) | Bukaan bersih; pemain berdiri bebas di selatan bangku, di samping peti |
| F5-overview.png | Overview pagar + taman (pintu terbuka) | Pagar keliling utuh; peti (0,28) di tengah; bangku di utara; pemain kecil di samping peti |
| F6a-bangku-luar.png | **Pemain tepat di bangku (0,25,45), pintu terbuka** | **Bukti tembus bangku — lihat bawah** |
| F6-bangku-samping.png | **Pemain di (0,25,45) — titik bangku lama — menghadap selatan; bangku (-3,25,45) di kiri jalur** | **Bukti geser: pemain bersih di jalur, tidak menyentuh bangku; bangku terlihat di depan pagar utara, kakinya di tepi bedeng barat (bunga merah di bawah/depan duduk)** |
| F6b-jalur-bersih.png | **Pemain di (0,26,8), sudah lewat garis bangku, menuju peti; overview dari timur-laut** | **Jalur batu x=0 bersih sampai peti; bangku barat jelas di samping jalur; peti (0,28) di depan pemain** |

Catatan run foto: run pertama kena `timeout 300` (baru F1–F2); run kedua
`timeout 900` selesai 5 foto (~11 mnt, render software lambat). Run F6 sempat
kena reboot VM di tengah F6b — F6a selamat, F6b tidak diambil (F6a sudah cukup
sebagai bukti). `nice -n -10` ditolak (`Permission denied` — sesi exec bukan
root); semua run jalan tanpa nice.

## ⚠️ TEMUAN UNTUK RAKA — pemain menembus bangku saat masuk taman

**SELESAI ronde ini (opsi a — geser bangku, lihat bagian atas).**
Dulu: bangku utara (0, 25,45) tepat di jalur masuk (sumbu x=0), tanpa
collision. Pemain yang jalan lurus dari pintu ke peti (jalur batu, x=0)
melewati z 25,20..25,80 — persis tapak bangku: duduk y 0,41..0,49 +
2 bilah sandaran y 0,69..1,01. **Bukti visual F6a: papan duduk menembus
sarung di lutut pemain, bilah sandaran melintang di badan.** (F4 tidak
menangkap ini karena pemain di (0,27,0) sudah lewat bangku.)
Kini bangku di (-3,25,45) — bukti bersih F6 + F6b. Sisa catatan:
bangku kini berdiri di atas petak bunga Bedeng_0 (lihat bagian atas) —
Raka/Mas yang menilai janggal atau tidak.

## Catatan visual lain (di luar lingkup — TIDAK diperbaiki ronde ini)

- **Label "TAMAN" tampak mirror (terbalik) di kedua sisi** — terlihat di F1–F4,
  dikonfirmasi lewat crop perbesaran, dan MASIH terlihat di F6 (tulisan di
  papan belakang bangku). Label dari ronde sebelumnya, bukan ronde ini.
  **Tidak diperbaiki ronde ini: tidak ada edit GLB** (geser bangku via kode
  saja) — tetap follow-up terpisah (perlu edit GLB oleh Bima).
- Tiang lampu di sumbu jalan (x≈0) menutupi sebagian pandangan pintu dari dalam
  di F3/F4 — bukan cacat pintu, sekadar catatan framing foto.

## Bonus info (bukan wilayah Gilang — sekadar hasil run yang sama)

3 gagal export ronde Raka yang masih jalan saat export 00:03 — tangga Surau
macet, serambi/pintu — **kini LOLOS di run ini** (`Naik tangga tanpa macet
(macet=0)`, `Sampai serambi + masuk pintu (di_dalam)`). Raka yang menilai apakah
itu memang sudah selesai di pihaknya.

## File yang diubah (v2 saja — v1 tidak disentuh)

**Ronde geser bangku (18 Nov 2026, ~01:10 WIB):**

- `scripts/pesantren_builder.gd` — `_lingkungan_glb` tangkap instans
  `GLB_Taman` + panggil `_geser_bangku_taman()` baru (5 node bangku
  utara `position.x -= 3.0`, rotasi tetap); komentar `PETI_POS`
  diperbarui (posisi bangku baru + catatan bedeng).
- Probe sementara `skrip/dump_taman.gd/.tscn`, `skrip/cek_bangku.gd/.tscn`,
  `skrip/foto_bangku_baru.gd/.tscn`, `skrip/foto_f6_ulangi.gd/.tscn`
  **sudah dihapus** setelah dipakai. Foto F6 diambil 2x (v1 framing
  gagal — bangku ketutup pagar utara dari luar; v2 dari dalam taman,
  kamera (1,0, 1,5, 26,8) → target (-3,0, 0,6, 25,45)), F6b 1x
  (kamera (6,0, 4,5, 20,0) → target (-0,5, 0,5, 27,5)).
- Cache `.godot/global_script_class_cache.cfg` diregenerasi via
  `--import` (perbaikan cache basi `RakBukuPutri` — bukan source).

**Ronde sebelumnya (peti + hook tes):**

- `scripts/pesantren_builder.gd` — `PETI_POS` (0,26) → (0,28).
- `scripts/mission_data.gd` — penanda M3 (0,0,26) → (0,0,28).
- `scripts/pintu_taman.gd` — hook `set_abaikan_npc()` + komentar peti.
- `skrip/test_v2.gd` — `set_abaikan_npc(true)`; dorong masuk 120 frame +
  asersi z 26,5..27,6; komentar tutup-otomatis diperbarui.
- `skrip/foto_pintu_taman.gd` — F4 (0,27,5) → (0,27,0).
- Probe sementara `skrip/dump_taman.gd/.tscn` + `skrip/foto_bangku_taman.gd/.tscn`
  **sudah dihapus** setelah dipakai.

## Siap untuk Raka

- ✅ Pintu taman buka cepat/awal: dwell gerbang 0,05–0,17 dtk
  (target ≤0,3), `test_v2` 60/60, blok pintu taman 16/16.
- ✅ Papan Ruang Kelas geser ke (21,4,6) — bersih dari pos +
  tembok + pohon (probe 15/15 + foto F1–F2 siang).
- ✅ Bangku geser (0,25,45) → (-3,25,45) — keputusan opsi (a) selesai.
- ⏳ Menunggu: penilaian Raka/Mas atas bangku di atas bedeng (janggal
  atau diterima) + deploy ronde berikut + verdict HP Mas.
- ⏳ Follow-up terpisah (bukan ronde ini): label "TAMAN" mirror —
  perlu edit GLB (Bima); batang pohon (22,6) menutupi sebagian label
  papan Ruang Kelas dari selatan (bukan tabrakan — pohon yang
  digeser kalau dinilai mengganggu).
- ❌ Tidak ada export/deploy dari ronde ini.
