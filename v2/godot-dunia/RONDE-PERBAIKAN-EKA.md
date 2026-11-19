# RONDE PERBAIKAN — Eka (Godot v1, 17 Nov 2026)

Tugas: 7 item retest Ronde 23 (file eksklusif: `scripts/main.gd`,
`scripts/player.gd`, `scripts/npc.gd`). **JANGAN deploy** — hasil
untuk ACC Mas. Proyek: `~/workspace/pesantren-verse/godot-dunia/`
(Godot 4.7.2). Folder v2 TIDAK disentuh.

Tes headless akhir: **32/32 PASS, 0 FAIL**
(`ronde-perbaikan/skrip/test_eka.gd`, `Engine.time_scale = 4.0`,
log terakhir `/tmp/test_eka5.log`). Foto bukti:
`ronde-perbaikan/foto/E1..E6` (8 file, dijalankan TANPA `--headless`
di bawah `xvfb-run`, jam dibekukan 10.00, masuk langsung tanpa login
server — pola `ronde-duduk/skrip/foto_duduk.gd`).

---

## 1. Gerbang x=14 — toast + dorong balik TIDAK jalan (7x gagal)

**Diagnosis akar masalah (probe headless, `test_probe.gd`):**
`_cek_batas` (main.gd) hanya bereaksi bila pemain melewati x=14 —
tapi pemain TIDAK PERNAH sampai ke sana: `BarrierGerbang` (kotak
0,4×3,0×4,0 di (14,1.5,0), `pesantren_builder.gd` `_tembok`) menahan
kapsul pemain diam-diam di x≈13,449. Syarat `x > 14` tidak pernah
terpicu → toast_count tetap 0 walau pemain mendorong tembok 73 detik.
Teleport balik yang lama terbukti jalan (foto D3 ronde duduk), tapi
tidak pernah terpanggil di gerbang. Bukan salah timer toast, bukan
toast tidak kelihatan — syaratnya yang tidak pernah benar.

**Yang diubah — `scripts/main.gd`, `_cek_batas` (~baris 1093–1157):**
Penegakan PROKSIMITAS, bukan penyeberangan: pemain yang menempel
tembok (jarak < 0,6 m) DAN menekan ke arahnya (`move_dir.x` ke
tembok) mendapat toast + didorong balik 1,5 m (putra → x=12,5,
putri → x=15,5), memakai throttle 4 detik + `_batas_toast_count`
yang sama. Berlaku di sepanjang tembok (z −60..16), bukan cuma di
gerbang; kawasan bersama selatan (z ≥ 16) bebas. Cek penyeberangan
lama (x > 14) dipertahankan sebagai fallback.

**Hasil uji headless:** putra toast_count=2, putri=4; x_maks putra
13,30 (< 14), x_min putri 14,70 (> 14) — tidak ada yang menembus.
**Catatan jujur:** cek "dorong-balik" di tes memakai min/max x
selama jalan — sampelnya termasuk posisi spawn (x=10/18), jadi cek
itu lemah. Bukti dorong balik yang kuat: toast_count naik + run
sebelumnya berakhir tepat di x=12,50 (posisi dorong balik).

**Foto:** `E1-gerbang-toast.png` — toast "Santri putra tidak boleh
masuk area putri." jelas di atas layar, pemain "Tes" berdiri di
pintu gerbang.

## 2. Bubble chat tidak muncul di atas kepala

**Diagnosis akar masalah (probe):** `_on_chat_submit` (ui.gd) TIDAK
pernah menutup panel chat setelah kirim; sementara bubble DITAHAN
(tidak terlihat) selama panel terbuka (aturan Ronde 7) dan timer
5 detiknya terus berjalan — jadi bubble tidak pernah muncul, bahkan
setelah panel ditutup manual (timer sudah habis).

**Yang diubah — `scripts/main.gd`, `_on_chat_sent` (baris 1440–1452):**
tambah `_ui.close_chat()` setelah kirim. Bubble langsung terlihat
di atas kepala; riwayat chat tetap ada, panel bisa dibuka lagi
dengan tombol Chat.

**Hasil uji:** panel tertutup saat kirim; bubble pemain muncul
dengan teks persis "Halo semua, assalamu'alaikum"; bubble NPC
(Bilal, via `say()`) muncul.

**Foto:** `E2-bubble-pemain-npc.png` — bubble pemain + bubble Bilal
keduanya terbaca di atas kepala (di lapangan selatan Surau).

## 5. Kamera tembus model

**Yang diubah — `scripts/main.gd`, `_jarak_kamera_aman` (baris 877)
+ pemakaian di `_process`:** panjang spring kini dijaga oleh
raycast garis pandang dari posisi kamera PROSPEKTIF (panjang target
penuh sepanjang sumbu spring) ke kepala pemain (+1,2 m). Kalau
terhalang, spring memendek ke proyeksi titik tabrak pada sumbu
lengan minus 0,3 m (dijepit 1,2..target) — stabil, tanpa osilasi.
Tambahan: kalau ada NPC dalam 0,9 m dari posisi kamera efektif,
spring dijepit ke 2,0 m (NPC tidak punya body fisika, jadi raycast
tidak bisa mendeteksinya). Variabel `_kamera_jarak_maks` yang sudah
tidak terpakai DIHAPUS.
**Sengaja TIDAK memberi SpringArm3D bentuk (shape):** shape bola
yang dilempar dari rig (di dalam kapsul pemain sendiri) akan
bertabrakan dengan kapsul itu dan menjepit kamera ke panjang ~0 —
didokumentasikan di komentar kode.

**Hasil uji:** lapangan terbuka spring tetap 7,00; di utara
KelasPutri panjang efektif 1,87 (kamera keluar dari cangkang,
z=−8,14); dinding sementara 2,4 m di antara kamera–pemain:
spring 2,49 (proyeksi ~2,3), kamera di luar solid dinding, dan
pulih ke 7,00 setelah dinding dicabut.

**Foto:** tidak ada foto khusus item ini — skrip foto memakai
Camera3D sendiri, bukan kamera game; buktinya angka tes headless
di atas (panjang spring + posisi kamera).

## 10. Satpam NPC tidak ketemu

**Diagnosis akar masalah:** posisi lama (17,5) = TITIK TENGAH gubuk
PosSatpam 3×3 m (dinding x 15,5..18,5, z 3,5..6,5) — ia berdiri DI
DALAM gubuk, tersembunyi di balik dinding 2,6 m; raycast dari sisi
putri menabrak dinding gubuk. Percobaan pertama (15,0,5, depan
pintu barat) MASIH tersembunyi dari timur — gubuk menutupi dari
hampir semua sudut timur (raycast (20,10)→satpam menabrak dinding
selatan gubuk).

**Yang diubah — `scripts/main.gd`, `_spawn_npcs` (baris 494–497):**
Satpam pindah ke SELATAN gubuk, (17,0,8,0) — 1,5 m di selatan
dinding selatan, di tanah terbuka — terlihat jelas dari timur
(arah datang santriwati dari spawn), utara, dan selatan, + masih
bisa melihat gerbang. Yaw −2,78 (= atan2(−3,−8), arah dari (17,8)
ke gerbang (14,0)). Lampu di (19,2,7,2) berjarak 2,3 m, tidak
bertabrakan.

**Hasil uji:** posisi (17,0,8,0); di luar gubuk (z=8,00 > 6,5);
garis pandang bersih dari timur (25,1,6,5) dan tenggara
(30,1,6,10); label "Satpam" terlihat dari dekat.

**Foto:** `E3-satpam-pos.png` — satpam jelas di depan gubuk
cokelat beratap hijau, label "Satpam" terbaca, gerbang di kiri.
Foto pertama gagal (tajuk pohon menutupi kamera dari timur) →
diulang dari barat-daya (14,2,2,11,5).

## 13. Label nama putri terpotong ("Uji Putr") saat menempel tembok

**Diagnosis akar masalah (geometri AABB):** label "Uji Putri"
lebar 0,890 m (setengah lebar 0,434 m) vs celah 0,35 m antara
pusat pemain dan muka tembok — satu ujung label masuk ke dalam
tembok. Bukan ukuran font atau billboard; labelnya memang lebih
lebar dari ruang yang tersedia.

**Yang diubah — `scripts/player.gd`, fungsi statis baru
`_batasi_label_dinding` (baris 1088), dipanggil di `_process`
(baris 1414–1415) untuk `_bubble` dan `_name_label` pemain, dan
di `scripts/npc.gd` (baris 224–225) untuk bubble + label NPC:**
raycast pendek dari pusat label ke kiri/kanan sepanjang vektor
kanan kamera; kalau ada dinding dalam setengah lebar label, label
dikecilkan (skala minimum 0,08, tidak pernah dibesarkan) supaya
kedua ujungnya muat di depan dinding.

**Hasil uji:** label skala 0,676, ujung timur x=13,750 ≤ 13,8
(muka tembok) dari kamera selatan maupun utara; bubble skala
0,306, ujung timur 13,750.

**Foto:** `E4a-label-putri-selatan.png` + `E4b-label-putri-utara.png`
— label "Uji Putri" utuh terbaca dari kedua sisi, pemain menempel
tembok. (Di E4a masih ada sisa bubble E2 yang samar di latar —
tidak mengganggu, bubble 5 detiknya belum habis saat foto diambil.)

## 14. Rute utara dari spawn putri (130,14) lewat sawah, kamera masuk tanah, mentok tembok

**Diagnosis akar masalah (probe):** jalan lurus ke utara dari spawn
putri masuk lewat celah pintu selatan KelasPutri (1,6 m,
`kampus_putri.gd`) ke dalam cangkang kosong, lalu mentok di dinding
utara (z=−3,52). Kamera (spring 7,0 m) tidak memendek karena sinar
spring melewati DI ATAS dinding 3,6 m — kamera mendarat di
(130,4,02,3,05), di dalam footprint gedung, tepat di atas atap.
Kamera tidak pernah di bawah y≈3,96 — "kamera masuk tanah" di
retest sebenarnya kamera di dalam/di atas cangkang, bukan di bawah
tanah. "Sawah" di deskripsi retest adalah salah label: sawah yang
sebenarnya ada di (60,30), ukuran 60×40, di area putra, jauh dari
rute utara putri. JalanInternal x=142 bersih sampai utara
(z=−51,4).

**Yang diubah — `scripts/main.gd`, `_cek_batas` (baris 1158–1195):**
penjaga cangkang KelasPutri — pemain di dalam footprint
(±5,0 × ±4,0 dari `_kelas_putri_pos`, dibaca dari dict build,
default (130,0,0)) mendapat toast "Kelas Putri belum dibuka — ke
Musholla lewat jalan di timur." + teleport ke titik aman TETAP
(x, pusat.z + 4,5) = 0,5 m di selatan dinding selatan, jangkar
ikut diperbarui ke titik itu. Dua koreksi selama verifikasi foto:
(1) teleport awal memakai `_pos_legal_terakhir` — jangkar itu
merayap ke strip ambang pintu z 3,7..4,0, jadi pemain mendarat di
ambang (foto pertama: z=3,61); (2) zona awal disempitkan 0,3 m
(±4,7/±3,7) menciptakan strip mati z 3,7..3,875 — pemain yang
berhenti di ambang (z=3,71) sudah di dalam gedung tapi di luar
zona (foto ulangan). Zona kini = bidang dinding penuh (±5,0/±4,0);
aman karena kapsul pemain (r=0,35) dari luar tidak bisa lebih
dekat dari 0,475 m ke bidang dinding, jadi yang jalan mengelilingi
gedung tidak kena.

**Hasil uji:** jalan lurus z_min=4,10 (tidak pernah melewati bidang
dinding z=4), toast KelasPutri 3x + terlihat; JalanInternal
mencapai z=−51,45 (tembok utara z=−52).

**Foto:** `E5a-rute-putri-pintu.png` — pemain berdiri JELAS di
depan pintu (z=4,5, di luar gedung) + toast arah terlihat
(diambil 3x: v1 z=3,61, ulangan z=3,71, ulangan ke-2 z=4,5).
`E5b-rute-putri-jalan.png` — pemain di JalanInternal putih ke
utara, Musholla + kubah hijau di ujung jalan.

## 15. Banner Dzuhur tulis "Surau" bahkan untuk putri

**Yang diubah — `scripts/main.gd`, `_mulai_sholat` (baris 1714–1735):**
toast kini mengikuti gender/area pemain — "Musholla" kalau putri,
"Surau" kalau putra.

**Yang BELUM bisa diperbaiki (bukan file saya):** teks BANNER-nya
sendiri dibangun di `ui.gd` `show_sholat_banner()` (baris 2613),
yang meng-hardcode "— ayo ke Surau!". Lihat "Untuk Raka" di bawah.

**Hasil uji:** toast putri "Waktu sholat Dzuhur — ayo ke
Musholla!" (tidak lagi "Surau"); toast putra tetap "Surau".
Banner masih "Surau" — dicatat, bukan digagalkan.

**Foto:** `E6-dzuhur-putri.png` — bukti jujur: toast atas
"Musholla!", banner hitam "Waktu sholat Dzuhur — ayo ke Surau!"
+ tombol IKUT SHOLAT.

---

## Untuk Raka (butuh file di luar milik Eka)

1. **`scripts/ui.gd` — patch banner sholat (item 15, 1 baris +
   3 tempat panggil):**
   ```gdscript
   # ui.gd, show_sholat_banner() (~baris 2613):
   func show_sholat_banner(nama: String, tempat: String = "Surau") -> void:
       _sholat_label.text = "Waktu sholat " + nama + " — ayo ke " + tempat + "!"
       _sholat_banner.visible = true
   ```
   Panggil dengan tempat "Musholla" kalau pemain putri, "Surau"
   kalau putra, dari 3 tempat di `main.gd`: baris 717, 1568, 1735
   (di 1735 variabel `tempat_sholat` sudah ada — pakai itu).
2. **`scripts/kampus_putri.gd` — perbaikan permanen item 14:**
   daun pintu di celah selatan KelasPutri + jalan penghubung
   beraspal dari spawn putri (130,14) ke JalanInternal x=142.
   Penjaga di `_cek_batas` di atas hanya penahan sementara.
3. **`scripts/main.gd` `_on_ikut_sholat` (baris 2081) — routing
   putri ke Musholla:** saat ini SELALU men-teleport pemain ke
   interior Surau (Sajadah_03) bahkan untuk putri. Perlu
   `_di_dalam_musholla` + logika masuk/keluar Musholla (di luar
   lingkup item 15 ini).

## Skrip (arsip, `ronde-perbaikan/skrip/`)

- `test_eka.gd` + `test_eka.tscn` — tes headless 32 cek (terakhir:
  SEMUA LULUS, `/tmp/test_eka5.log`).
- `test_probe.gd` + `test_probe.tscn` — probe diagnostik pra-perbaikan.
- `foto_eka.gd` + `foto_eka.tscn` — 8 foto E1..E6.
- `foto_eka_ulangan.gd` + `foto_eka_ulangan.tscn` — retake E3 + E5a.
- `foto_eka_e5a.gd` + `foto_eka_e5a.tscn` — retake ke-2 E5a.
- Semua salinan `res://` di proyek SUDAH DIHAPUS (cek: hanya
  `main.tscn` + file asli di root proyek).

## Yang tidak dikerjakan / batasan

- Item 5 tidak ada foto (kamera game ≠ kamera foto) — bukti berupa
  angka tes headless.
- Banner sholat (item 15) belum diperbaiki — menunggu patch ui.gd
  oleh Raka (lihat di atas).
- Perbaikan permanen item 14 (pintu + jalan) menunggu
  `kampus_putri.gd` oleh Raka.
- Tidak ada deploy. Tidak ada file v2 yang disentuh. Tidak ada file
  milik agen lain yang diubah.
