# RONDE 15 — Karakter pemimpin pesantren: Ust. Aqsal Murad (16 Nov ~08:09–08:35 WIB, Raka)

**Pemicu:** Mas 08:09 WIB *"Buat karakter pemimpin pesantren: Ust. Aqsal
Murad. Berjanggut dan berkumis tipis. Menggunakan serban"*

**Aturan:** primitif Godot yang sama (`player.gd build_visual`, dipakai
bersama NPC via `npc.gd`) — JANGAN pakai Blender (jalur Blender sudah
dihentikan Mas). **TIDAK deploy** — deploy ditahan sampai retest browser
ronde 10+11+12+13+14 selesai (retest sedang jalan melawan build live
ad5074ed; jangan ganggu).

## 1. Yang dibangun

**Visual Kyai** (`scripts/player.gd` `build_visual` + `scripts/mission_data.gd`
`OUTFIT_KYAI` — kunci baru `"serban"` / `"jenggot"` / `"kumis"` dibaca
`build_visual`; panel Ganti Baju TIDAK menawarkannya, hanya Kyai):
- **Serban** (pengganti songkok): 3 lilitan bertingkat (silinder bersusun,
  jari-jari 0.27 / 0.285 / 0.26 — lapisannya terbaca) + kubah atas +
  simpul depan + ekor kain di belakang (turun sampai kerah). Warna
  **putih krem `#f5f0e0`**. Rambut disembunyikan (serban menutupi seluruh
  kepala) — dari belakang atas kepala PUTIH, bukan hitam. Node
  dikelompokkan di wadah `"Serban"` (6 bagian).
- **Jenggot**: bola pipih (r=0.19, skala 1.05/0.85/0.72) membungkus dagu
  bawah + menggantung sampai kerah. Warna **gelap `#2b241d` dengan uban
  abu kecokelatan `#7d7468` di ujung bawah** (bola kedua, hanya menonjol
  di ujung depan-bawah — keputusan Raka: jenggot Kyai gelap dengan
  sedikit uban). Mulut tetap di depan jenggot (z mulut 0.219 vs
  permukaan jenggot ~0.193 di tinggi mulut — dibuktikan numerik di tes).
- **Kumis tipis**: satu kapsul r=0.011, panjang 0.10, di atas bibir di
  bawah hidung, warna sama seperti jenggot.
- **Outfit**: koko **KREM `#f2ead6`** + sarung **HITAM `#23282e`** (gelap,
  berwibawa; motif batik parang tetap jalan di warna gelap); kulit sawo
  matang `#c68e5e` (sama seperti pemain — pembedanya serban + jenggot +
  kumis + sarung gelap); TANPA kacamata (itu ciri Bilal).
- **Label nama**: `"Ust. Aqsal Murad"` (putih tanpa outline, sama seperti
  karakter lain).

**Penempatan** (`scripts/main.gd` `_spawn_npcs`): Kyai berdiri di **serambi
barat pintu Surau, (−4.8, 0, −4.8), menghadap selatan** (plaza/spawn —
pemain yang datang langsung melihat wajahnya). Jarak terukur: pintu luar
(−2.11,−7.47) ~3,8 m; titik keluar (−2.75,−6.11) ~2,4 m; ~3,6 m di
selatan dinding selatan Surau; ~2,4 m dari koridor jalan NPC ke pintu —
tidak menghalangi pintu/jalan. (Koreksi saat pengerjaan: klaim awal
"sudut barat-daya (−3.33,−4.93)" SALAH — titik itu bukan sudut; sudut
sebenarnya (−7.55,−10.01) ke (3.33,−4.93); tes diperbaiki mengukur jarak
ke segmen dinding, hasilnya 3,55 m.)

**Perilaku** (`scripts/npc.gd` mode baru `diam`): Kyai **berdiri TETAP** —
napas idle saja, TIDAK keliling, TIDAK mengobrol (tidak ada dialog, sesuai
brief). `setup(..., diam := false)` — Bilal/Faris tidak berubah.
**Sholat berjamaah**: Kyai TIDAK ikut jalan ke Surau — tetap di serambi
selama sesi (`_mulai_sholat` melewati NPC `berdiri_tetap()`); sajadah tetap
Sajadah_02 (Bilal) / Sajadah_04 (Faris). Kyai tetap muncul di peta
(`_data_peta` membaca semua `_npcs`) dan bisa jadi target salaman
terdekat (mekanisme lama, tidak diubah).

## 2. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: semua script lolos (tanpa ERROR).
- **Tes headless `test_ronde15.gd`: 53 LOLOS / 0 GAGAL, exit 0** —
  build_visual Kyai (Serban 6 bagian, peci + rambut tidak ada, lilitan
  tengah r≥0.28, jenggot + uban + kumis ada, kumis tipis r≤0.015,
  mulut di depan jenggot, kacamata tersembunyi, koko krem #f2ead6,
  sarung hitam #23282e, label "Ust. Aqsal Murad") + regresi default
  (peci + rambut ada, serban/jenggot/kumis null) + NPC diam unit (posisi
  tetap 600 frame, tidak mengobrol; kontrol NPC biasa bergerak) +
  integrasi scene (3 NPC, nama benar, Kyai di (−4.8,0,−4.8) menghadap
  selatan, jarak pintu/keluar/dinding/koridor, Kyai di peta, Kyai tetap
  + Bilal bergerak setelah 600 frame) + regresi sholat (sesi Dzuhur
  mulai jam 12.00, Bilal + Faris pose sholat di sajadah, Kyai TIDAK
  masuk fase sholat + tetap di serambi, sesi berakhir 12.30, Kyai tetap
  di serambi). 4 gagal di run pertama adalah BUG TES (to_html() pakai
  alpha; jeda awal NPC 2 dtk membuat kontrol "bergerak" gagal di 120
  frame; titik sudut Surau salah — lihat §1), diperbaiki, bukan bug game.
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR.**
- **5 foto bukti** di `~/workspace/pesantren-verse/foto-ronde15/`
  (960×540, xvfb-run + opengl3, jam 10.00):
  - `01-kyai-depan.png` — close-up: serban berlapis + jenggot gelap +
    kumis tipis (garis gelap di bawah hidung) + mulut (garis cokelat
    tipis di bawah kumis) + uban abu di ujung jenggot. ✓
  - `02-kyai-samping.png` — profil: serban + jenggot menonjol ke depan,
    kumis terbaca. ✓
  - `03-kyai-belakang.png` — dari belakang: atas kepala PUTIH (serban),
    ekor kain turun di belakang leher. ✓
  - `04-kyai-bertiga.png` — RETAKE (susunan pertama pemain di (−4.8,−3.0)
    TEPAT menutupi Kyai di (−4.8,−4.8)): kini berderet Bilal – Tes –
    Kyai – Faris; Kyai paling mencolok (serban + jenggot + sarung hitam).
    ✓
  - `05-kyai-serambi.png` — RETAKE (alasan sama): Kyai sendiri di serambi,
    dinding Surau + plakat مصلى الإخلاص + tiang lampu + jalan setapak
    di belakangnya. ✓
- **Export `export/web/`:** pck BARU **1.004.080 byte** sha256
  `0c13e27d442946bcedf8ba5869f9b9ea6b323cfc47eee8aed4232728cf1ec5c4`
  (+2.544 dari ronde 14 — murni kode ronde 15); wasm TIDAK berubah
  (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`);
  worklet ada (2.973 byte). Smoke pck via `--main-pack` 600 frame
  0 error. File tes/foto dihapus sebelum export (pck bersih;
  `ls *.gd` root = 0). **TIDAK deploy** — deploy urusan Damar, DITAHAN
  sampai retest browser ronde 10+11+12+13+14 selesai.

## 3. Jujur / belum sempurna

- **Jenggot + kumis menyatu secara visual di jarak jauh** (sama-sama
  gelap): di close-up keduanya terpisah jelas (kulit + garis mulut di
  antaranya), tapi di jarak main biasa wajah bawah terbaca sebagai satu
  massa gelap. Kalau Mas mau mulut lebih terbaca, kumis bisa ditipiskan
  lagi atau warna mulut dicerahkan — tidak diubah di ronde ini.
- **Uban hanya terbaca di close-up** — di jarak jauh ujung jenggot
  tampak gelap saja (tonjolannya cuma ~1–2 cm).
- **Simpul serban kecil** — hanya terbaca dari depan-atas; dari sudut
  main biasa serban terbaca lewat lilitannya, bukan simpulnya.
- **Motif batik sarung hitam sangat kontras** (garis putih/emas tebal di
  atas hitam) — paling mencolok di antara keempat sarung; disengaja
  supaya Kyai beda, tapi kalau Mas merasa terlalu ramai, kontras motif
  untuk sarung gelap bisa dilembutkan.
- **Kyai TIDAK ikut sholat berjamaah** — ia tetap di serambi saat Bilal +
  Faris ke Surau. Secara tema, Pengasuh seharusnya MEMIMPIN sholat
  (imam di saf depan). Itu ronde lanjutan, bukan ronde ini: Kyai jalan
  ke Sajadah_01/depan + pose qiyam/ruku sebagai imam.
- **Kyai belum bisa diajak bicara** — tidak ada sapaan/dialog khusus
  (kalimat NPC lama "Ustadz Aqsal Murad sedang di surau." sudah ada —
  diucapkan Bilal/Faris). Interaksi (salam/salaman/dialog) ronde lanjutan.
- Sarung pemain (zamrud) + Bilal (biru) sama-sama terbaca biru kehijauan
  di cahaya pagi — masalah lama ronde 8, tidak disentuh di sini.
- Portrait 390×844 belum teruji — perlu HP Mas (seperti biasa).

## 4. File yang diubah

- `scripts/player.gd` — `build_visual`: kunci outfit baru
  (`serban`/`serban_warna`, `jenggot`/`jenggot_warna`/`uban_warna`,
  `kumis`); cabang serban (wadah `"Serban"` 6 bagian) vs peci + rambut;
  jenggot + uban + kumis; return dict + 4 kunci Kyai (null untuk
  karakter biasa).
- `scripts/mission_data.gd` — konstanta baru `OUTFIT_KYAI`.
- `scripts/npc.gd` — mode `diam` (`_diam`, `berdiri_tetap()`,
  parameter `setup(..., diam := false)`, early-return di `_process`).
- `scripts/main.gd` — `_spawn_npcs`: NPC ke-3 Ust. Aqsal Murad
  (diam, di serambi); `_mulai_sholat`: lewati NPC diam (counter `j`
  terpisah supaya sajadah Bilal/Faris tetap 02/04).

## 5. Handoff DEPLOY (Damar) — baca sebelum deploy

1. **JANGAN deploy dulu:** deploy ronde 15 DITAHAN sampai retest browser
   ronde 10+11+12+13+14 selesai (retest sedang jalan melawan build live
   ad5074ed). Deploy setelah retest selesai + laporan diterima.
2. Saat deploy: pck ronde 15 (`0c13e27d…`, 1.004.080 byte) — salin
   `index.pck` baru ke staging `export/web-pages/` (sha256 cocok),
   update GODOT_CONFIG `index.pck` di staging index.html
   1001536 → **1004080**, lalu cek guard seperti biasa (3 `<script>` /
   3 `</script>`; `})();` → `</script>` → `<script src="index.js">`).
   Wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte, 5 chunk) — jangan
   sentuh chunk-nya. index.js TIDAK berubah (`33c94cb3…`). Worklet
   `index.audio.position.worklet.js` wajib ikut (2.973 byte).
3. Setelah deploy: retest browser SEGERA untuk ronde 15 (Kyai di serambi
   + wajah close-up + berempat + regresi sholat berjamaah) — atau
   gabung dengan retest berikutnya bila ada ronde 16. Lalu Mas tes di
   HP-nya (landscape).
