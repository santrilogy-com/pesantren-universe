# RONDE 14 — Putar Surau 25° + mihrab ke tengah dinding (16 Nov ~06:56–07:30 WIB, Raka)

**Pemicu:** Mas 06:31 WIB *"Putar Suraunya 25° — mihrab rata dengan
dinding."* + koreksi Mas 06:47 WIB *"Mihrab harusnya di tengah tembok.
Bukan di pojok."*

**Aturan:** ronde 13 (sholat berjamaah) sudah export tapi BELUM deploy
— deploy ditahan sampai ronde 14 export, supaya 13+14 deploy sekali.
**TIDAK deploy** — deploy urusan Damar (staging `export/web-pages/`
masih berisi pck ronde 12; Damar menyalin pck ronde 14 ke staging +
cek guard seperti biasa — pck ronde 13 di `export/web/` sudah
tergantikan pck ronde 14).

## 1. Yang dibangun

**Cara putar (bukan pindah anak satu-satu):** node `"Surau"`
(eksterior) diposisikan di P = pusat − R·pusat lalu diputar −25°
mengelilingi PUSATNYA (0,−12) — semua anak (yang dibangun di
koordinat absolut) ikut berputar mengelilingi pusat. Interior
diputar −25° mengelilingi PINTUNYA (0,0,−294) — pintu sendiri TIDAK
berpindah sehingga koridor keluar tetap berlaku tanpa perubahan.
Rumus putar di `PesantrenBuilder._putar_sekitar` /
`_posisi_root_putar` + `InteriorSurau.ke_dunia` (untuk nilai yang
dikembalikan `build()`). Konstanta tunggal:
`PesantrenBuilder.SURAU_ROTASI_DEG = -25.0` (−25° = kiblat 295° −
normal dinding barat 270°). Nilai dunia (dihitung independen,
Python, lalu dites): pintu luar (0,−7) → **(−2.11,−7.47)**; titik
keluar (0,−5.5) → **(−2.75,−6.11)**; spawn dalam (0,−295.5) →
**(0.63,−295.36)**; pintu dalam TETAP (0,−294); root eksterior di
(−5.07,−1.12); root interior di (−124.25,−27.55).

**Mihrab ke TENGAH dinding** (`interior_surau.gd`) — dari
(−8.4,−306.0) — dekat pojok utara — ke **(−8.4,−301.0)**, tengah
dinding barat (z=−301 = pusat ruangan = pusat grid sajadah).
Rotasi lokal −270° (= −295° kiblat + 25° rotasi ruangan) supaya di
dunia mihrab menghadap 295° dan RATA dengan dindingnya. Grid sajadah
ikut: pusat (0,−301.8) → **(0,−301.0)**, rotasi lokal −295° →
−270° — di dunia sajadah tetap menghadap 295° tapi kini SEJAJAR
dinding ruangan (tidak diagonal lagi). Tes membuktikan: offset
mihrab sepanjang dinding ~0, jarak mihrab ke dinding 0,6 m, grid
5 posisi sepanjang dinding × 3 baris ke arah mihrab, semua di
dalam ruangan.

**Smartboard pindah (konsekuensi yang tidak ada di brief, ditemukan
saat implementasi):** mihrab di z=−301 TEPAT di depan smartboard
(z=−301, lebar 4,6 m) — mihrab akan menutupi layarnya. Smartboard
pindah ke ujung utara dinding barat, pusat **z=−305.2** (papan
−307.5..−302.9; celah 1,1 m dari mihrab, 0,4 m dari dinding utara;
rak kitab barat (−8.8,−296) tidak tersentuh). Ikut pindah:
`SMARTBOARD_SPOT` → (−6.8,−305.2) dan penanda M2 (posisi DUNIA,
marker anak root luar yang berimpit dengan interior) →
**(0.14,−305.19)** = `ke_dunia((-4.6,−304.2))`. Penanda M1 (3.0,−6.5)
TETAP — masih 1,4 m di depan dinding selatan yang sudah miring.
Jarak penanda M2 ke spot smartboard 2,4 m (< radius interaksi
3,5 m).

**Menara pindah (konsekuensi kedua):** posisi lama (7.6,−16.6,
sudut timur laut) setelah rotasi mendarat di (8.83,−12.96) — di
depan dinding barat cangkruk (x=9) dan menutup jalannya. Menara
pindah ke sudut BARAT LAUT **(−7.6,−16.6)** → dunia (−4.94,−19.38),
aman. Tes membuktikan: tidak ada bagian Surau di zona cangkruk
(x 8.7..19.3, z −18.2..−9.8); sudut cangkang terjauh x=7.55 < 8,5.

**Jalan setapak baru** (`pesantren_builder.gd` `_ground`) — pintu
kini 2,1 m di barat jalan utama (x=0): segmen pasir 3,0×2,5 m di
(−1.0,−6.5) menyambungkan jalan ke ambang pintu.

**Koridor pintu dalam frame pintu** (`main.gd` `_cek_pintu_surau`)
— u = jarak sepanjang celah (sumbu 115°), v = jarak ke dalam/luar
(normal masuk 25° / keluar 205°); pemicu |u|<1,2 dan 0<v<1,5
(sama dengan koridor lama, hanya diputar). Frame dari
`PesantrenBuilder.surau_pintu()` — berlaku juga untuk pintu dalam
karena interior diputar −25° juga. **Rute NPC**
(`_rute_ke_pintu_surau`): titik akhir (0,−6.2) → **depan pintu
(−2.75,−6.11)** = pintu + 1,5 m ke arah luar/plaza (205°).
Segmen plaza (0,2) → depan pintu TIDAK menabrak dinding selatan
yang sudah miring (perpotongan garis t=1.24, di luar segmen —
dites). Koridor Manhattan utara/barat tidak berubah.

**Peta** (`main.gd` `_data_peta` + `ui.gd`) — data peta kini berisi
`"surau_rotasi": -25.0`; peta besar menggambar Surau sebagai
**poligon miring** (4 sudut diputar rumus yang sama), bukan persegi
tegak. Minimap dibiarkan: kotak 10×10 px di pusat (0,−12) — pusat
tidak bergeser, rotasi 25° tak terlihat di skala itu.

## 2. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: 12 script (termasuk yang diubah) — semua lolos.
- **Tes headless `test_ronde14.gd`: 66 LOLOS / 0 GAGAL, exit 0** —
  rotasi eksterior + interior + frame pintu (sumbu 115° / masuk 25° /
  keluar 205°), pintu dalam tetap, spawn + spot smartboard, mihrab
  dunia (−4.65,−303.89) + menghadap 115° + di TENGAH dinding +
  0,6 m dari dinding, sajadah dunia (2.96,−300.34) + menghadap 115°
  + di sumbu mihrab + 15 mat (5 kolom × 3 baris, semua di dalam
  ruangan), menara/cangkang tidak di zona cangkruk, papan + layar
  smartboard dunia, mihrab tidak menutupi smartboard (> 2,5 m),
  penanda M1/M2, data peta `surau_rotasi`, rute ke pintu (plaza 2
  titik, utara jauh 4, utara dekat 5 — semua berakhir di depan
  pintu), segmen plaza→pintu tidak menabrak dinding (t=1.24),
  pintu masuk-keluar fungsional (masuk → spawn dalam; keluar →
  titik keluar), regresi ronde 13 (sesi Dzuhur mulai, Bilal + Faris
  sampai di sajadahnya (< 0,5 m) + pose sholat + menghadap kiblat
  295°, pemain ikut via tombol Ikut Sholat → Sajadah_03 + menghadap
  kiblat, sesi berakhir 12.30, NPC tidak lagi pose sholat).
  3 gagal di run pertama adalah BUG TES (node "Smartboard" sendiri
  di (0,0,0) lokal — yang diukur papannya; rute plaza 2 titik bukan
  1; rute utara jauh 4 titik bukan 5), diperbaiki, bukan bug game.
  `Engine.time_scale = 10` dipakai supaya jalan kaki NPC tidak
  menunggu waktu nyata.
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR.**
- **8 foto bukti** di `~/workspace/pesantren-verse/foto-ronde14/`
  (960×540, xvfb-run + opengl3, via `LangitDinamis.debug_jam`):
  - `01-surau-luar.png` — jam 10.00, dari (6,0,6): Surau MIRING
    25° terhadap jalan, pintu + plakat مصلى الإخلاص benar, menara
    di barat-laut, cangkruk di kanan. ✓
  - `01b-surau-luar-tenggara.png` — dari (12,0,0): kemiringan
    dinding selatan vs jalan paling terbaca. ✓
  - `02-mihrab-dalam.png` — RETAKE (pemain digeser 3 m ke utara
    dari sumbu mihrab): mihrab (panel hijau tua + lis emas) JELAS
    di TENGAH dinding, tidak tertutup pemain; sajadah sejajar
    dinding; smartboard bersih di kanan; label TERKUNCI di bawah
    smartboard (penanda M2 di posisi baru). ✓
  - `02b-dalam-lebar.png` — dari spawn dalam: pintu + label KELUAR
    di kiri, rak kitab, mihrab di tengah dinding, smartboard di
    kanan, tombol KELUAR SURAU. ✓
  - `03-sholat-berjamaah.png` — Maghrib 18.00: Bilal + Tes + Faris
    QIYAM di saf (lengan bersedekap), sajadah sejajar dinding,
    mihrab di tengah dinding di belakang Tes, smartboard bersih. ✓
  - `03b-sholat-samping.png` — dari sisi timur: ketiganya qiyam,
    mihrab terlihat penuh di tengah dinding. ✓
  - `04-peta-surau.png` — RETAKE (zoom 4.0x): Surau berupa jajar
    genjang MIRING 25° di peta, cangkruk + plot + label terbaca. ✓
  - `05-pintu-luar.png` — dari (0,0,−1): pintu + plakat + jalan
    setapak dari jalan utama, dinding miring, pemain di ambang
    pintu. ✓
- **Export `export/web/`:** pck BARU **1.001.536 byte** sha256
  `45f5be3b54f3eb82e0e08ec7a274d09a0bc601ccf2503ef9d8530a420e93c45b`
  (+2.800 dari ronde 13 — murni perubahan kode ronde 14; export
  pertama 1.016.084 byte masih berisi skrip tes/foto, dihapus lalu
  re-export mengikuti pola ronde 13); wasm TIDAK berubah
  (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…`); worklet ada (2.973 byte). Smoke pck via
  `--main-pack` 600 frame 0 error. File tes/foto dihapus sebelum
  export (pck bersih; `ls *.gd` root = 0). **TIDAK deploy** —
  deploy urusan Damar.

## 3. Jujur / belum sempurna

- **Foto 02 pertama mihrab tertutup badan pemain** (kamera di
  belakang pemain yang menghadap mihrab — pemain selalu di tengah
  frame). Di-retake dengan pemain digeser 3 m ke utara dari sumbu
  mihrab; foto 02 sekarang jelas. Pelajaran untuk foto interior
  berikutnya: jangan taruh pemain tepat di sumbu objek yang
  difoto.
- **Foto 04 pertama di zoom 1.0x** — Surau cuma ~10 px, kemiringan
  tak terbaca. Di-retake di zoom 4.0x; poligon miring terlihat.
- **Mihrab tampak "miring" di foto 02** — itu benar: mihrab rata
  dengan dinding yang sudah diputar 25°, jadi di frame ia tampak
  miring terhadap horizontal. Bukan bug — itu bukti rotasinya.
- **Pintu luar TIDAK lagi segaris dengan jalan utama** (2,1 m di
  barat) — konsekuensi yang diminta Mas (putar Surau). Jalan
  setapak baru menyambungkannya; rute NPC + koridor sudah
  disesuaikan. Kalau Mas mau pintu tetap di jalan, bangunannya
  harus digeser — itu ronde lain.
- **Matahari sore tidak lagi di tampilan default** (diketahui ronde
  12, tidak berubah): menghadap utara = membelakangi matahari
  terbenam (252°). Foto 03 diambil jam 18.00 di DALAM ruangan,
  jadi tidak terlihat.
- **Waktu sholat tetap** (bukan hisab dinamis) — warisan ronde 13.
- Portrait 390×844 belum teruji — perlu HP Mas (seperti biasa).
- **Retest browser ronde 10+11+12 TERHENTI di tengah jalan**
  (browser crash, bukan game — info dari MEMORY.md 07:10–07:16
  WIB): yang sudah lolos — kopyah 360°, salaman tangan kanan,
  variasi karakter, zoom peta 3 tingkat, jendela cangkruk dari luar.
  Yang belum terverifikasi — interior cangkruk siang, smartboard
  bersih, mihrab + matahari sore, foto trio, panel Ganti Baju
  (kulit Gelap + kacamata), sarung biru + console `[RONDE8]`,
  regresi duduk/tidur/Chat/Khataman. Satu retest ulang setelah
  deploy 13+14 (mencakup sisa + Surau diputar + sholat berjamaah).

## 4. File yang diubah

- `scripts/pesantren_builder.gd` — `SURAU_ROTASI_DEG`, `SURAU_PUSAT`,
  `_putar_sekitar`, `_posisi_root_putar`, `arah`, `surau_pintu()`,
  rotasi root Surau, menara ke barat-laut, jalan setapak, pintu
  luar/keluar dari frame (konstanta lama jadi dokumentasi).
- `scripts/interior_surau.gd` — `PINTU_PIVOT`, `ROTASI_LOKAL_KIBLAT`,
  `ke_dunia`, mihrab ke (−8.4,−301.0) + rotasi −270°, sajadah ke
  (0,−301.0) + rotasi −270°, smartboard ke z=−305.2,
  `SMARTBOARD_SPOT` → (−6.8,−305.2), rotasi root di akhir `_bangun`.
- `scripts/mission_data.gd` — penanda M2 → (0.14,−305.19) (dunia).
- `scripts/main.gd` — frame pintu (`_surau_pintu` dkk.),
  `_cek_pintu_surau` dalam frame, `_rute_ke_pintu_surau` berakhir
  di depan pintu, `_data_peta` + `surau_rotasi`.
- `scripts/ui.gd` — peta besar: Surau sebagai poligon miring.

## 5. Handoff DEPLOY (Damar) — baca sebelum deploy

1. **Deploy ronde 13+14 SEKALI:** pck ronde 14
   (`45f5be3b…`, 1.001.536 byte) sudah mencakup fitur ronde 13
   (sholat berjamaah) + ronde 14 (putar Surau). Pck ronde 13
   (`edba6cf9…`) TIDAK dipakai lagi.
2. Staging `export/web-pages/` masih berisi pck ronde 12
   (`8d72a1ae…`): salin `index.pck` baru ke staging (sha256 cocok),
   salin 3 file `.import` bila berubah, update GODOT_CONFIG
   `index.pck` di staging index.html 988896 → **1001536**,
   lalu cek guard seperti biasa (3 `<script>` / 3 `</script>`;
   `})();` → `</script>` → `<script src="index.js">`).
   Wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte, 5 chunk) —
   jangan sentuh chunk-nya. index.js TIDAK berubah (`33c94cb3…`).
   Worklet `index.audio.position.worklet.js` wajib ikut (2.973 byte).
3. Setelah deploy: retest browser SATU KALI untuk ronde 13+14
   (mencakup sisa retest 10+11+12 yang terhenti karena crash +
   Surau diputar + sholat berjamaah) — lihat §3.
4. Setelah deploy + retest lolos: Mas tes di HP-nya (landscape),
   lalu (a) hapus pilihan jalur dari form Daftar app + endpoint
   register server (sistem satu jalur); (b) integrasi game ke
   server (verify login, kirim poin, ranking); (c) set alamat game
   di app (Panel Ustadz → Gerbang Game →
   https://pesantren-verse.pages.dev).
