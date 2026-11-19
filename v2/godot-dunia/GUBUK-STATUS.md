# Gubuk Santri Bisa Dimasuki — Status (Dewa, interior)

Tugas Raka 17 Nov 2026 ~23:42 WIB: gubuk santri (`models/gubuk-santri.glb`)
bisa dimasuki. Fokus `GLB_GubukSawah` (26,0,30); `GLB_GubukKebun`
(90,0,10, rot 90°) ikut dipasangi modul yang sama.

## 1. Temuan ukur model (Blender 4.5.16 headless + dump Godot)

| Ukuran | Nilai |
|---|---|
| Jejak badan | 4,0 (X) × 3,0 (Z) m; atap menjorok ±2,32 m |
| Lantai (Lantai) | Z 1,20..1,32 → **permukaan pijak y = 1,32 m (panggung)** |
| Dinding | y 1,32..3,52; atap sampai y 4,71 |
| Kolong | 0..1,20 m (ada Kayu_Bakar di bawah, y 0..0,35) |
| Tangga | **SUDAH ADA di model**: 5 Anak_Tangga, naik 0,22 m tiap anak, lebar 1,2 m (X 0,3..1,5), dari tanah (depan z=-3,82) ke Beranda (z=-2,41) |
| Beranda | 1,2 × 1,0 m, permukaan y 1,32 (sama dengan lantai) |
| Pintu | **ADA tapi TERTUTUP**: daun Pintu 0,86 × 1,76 m + Gagang menutup penuh bukaan depan X 0,45..1,35, y 1,32..3,12. Gagang di X~0,58 → engsel di kanan (X=1,33) |
| Bukaan pintu | 0,90 × 1,80 m — muat kapsul pemain (lebar 0,70, tinggi 1,70) |
| Jendela depan | Bukaan X -1,30..-0,50, y 2,02..2,82 — tapi **Kaca OPAK** (albedo alpha 1,0, transparency 0): tidak tembus cahaya |
| Dinding lain | Tertutup penuh (belakang/kiri/kanan + segmen depan) |
| Interior | 2 Tikar (y 1,335..1,365), Rak kitab dinding kanan (X 1,53..1,88, y 1,35..2,35) + 4 Kitab |

**Kesimpulan: TIDAK perlu ubah model GLB, TIDAK perlu Bima.** Tangga sudah
ada, pintu sudah ada (tinggal dibuka), dinding sudah tertutup. Yang kurang
hanya: pintu tertutup + GLB tanpa collision sama sekali (import default).

## 2. Yang dikerjakan (sisi Godot saja)

File baru: `scripts/gubuk_masuk.gd` (`class_name GubukMasuk`), dipasang dari
`scripts/pesantren_builder.gd` `_lingkungan_glb` (hanya 2 baris gubuk;
Surau/taman/pagar tidak disentuh). Semua dalam ruang LOKAL instance GLB —
berlaku sama untuk kedua gubuk, tanpa ubah file GLB. Idempotent (cek anak
`GubukMasuk`).

1. **Pintu dibuka**: daun + gagang dipindah ke pivot engsel (1,33, 2,22,
   -1,32), pivot diputar **-110° (keluar, ke beranda)** — preseden daun
   Surau ±110°. Daun terbuka diberi collision sendiri (0,86 × 1,76 × 0,06,
   ikut pivot) supaya tidak tembus.
2. **Collision lantai**: badan 4,0 × 3,0 + beranda 1,2 × 1,0 (puncak y=1,32).
3. **Collision dinding**: belakang/kiri/kanan penuh + 5 segmen depan
   (Depan_Kiri, Bawah/Atas_Jendela, Depan_Tengah, Atas_Pintu, Depan_Kanan).
   Celah HANYA di pintu (0,90 × 1,80 m) dan jendela atas (ambang y=2,02 =
   0,70 m di atas lantai — tak bisa dilangkahi kapsul).
4. **Collision rak kitab** (0,35 × 1,0 × 0,75 di X 1,53..1,88) + **4
   dinding kolong** (0..1,20 m) supaya pemain tak bisa jalan bawah gubuk.
5. **Ramp tangga** (bukan anak-tangga satu-satu — kapsul CharacterBody
   tidak bisa naik pijakan tegak 0,22 m): satu bidang miring **38,2°**
   (di bawah floor_max_angle 45°) dari tanah (z=-4,09, y=0) sampai tepi
   beranda (z=-2,41, y=1,32), lebar 1,2 m. Garis ramp lewat titik tengah
   tiap anak tangga: kaki melayang MAKS 0,11 m di atas papan (tengah
   papan); ramp masuk 0,05 m ke dalam ujung papan (tak terlihat —
   collision tak kasatmata).
6. **Lampu interior**: 1 OmniLight hangat #ffd9a0, energi 0,5, jangkauan
   6 m, tanpa bayangan, di (0, 2,7, 0) — kaca jendela opak, jadi cahaya
   siang dari pintu saja tidak cukup untuk sudut dalam.

## 3. Hasil tes headless

Re-run 17 Nov 2026 ~17:06 WIB (Dewa, setelah export Rangga 00:03):
`godot --headless --path . skrip/test_v2.tscn` — **TES V2: 57 lulus,
3 gagal** (sama persis dengan hasil tes export Rangga).

**9 asersi gubuk — SEMUA LULUS ✓:**

| Asersi | Hasil |
|---|---|
| GubukSawah GLB ada | LULUS |
| GubukMasuk terpasang (Sawah) | LULUS |
| Pintu gubuk terbuka -110 | LULUS |
| GubukKebun GLB ada + modul | LULUS |
| Masuk gubuk: di dalam di lantai | LULUS — pemain (26.9, 1.321, 30.20), y lantai 1,32 |
| Dinding belakang menahan | LULUS — mentok z=30.94, tetap y=1,32 |
| Dinding kanan/rak menahan | LULUS — mentok x=27.51, tetap y=1,32 |
| Kolong tertutup | LULUS — mentok x=23.59, y=0, tak bisa masuk bawah gubuk |
| Keluar gubuk ke tanah | LULUS — turun ramp, kaki (26.9, 0.001, 20.07) |

**3 gagal — SEMUANYA di luar gubuk, pekerjaan Raka yang masih jalan**
(sama dengan 3 gagal di tes export): tangga Surau masih macet=46;
serambi/pintu Surau; pintu taman berhenti z=25,27. Bukan urusan
gubuk — diteruskan ke Raka sebagai fokusnya.

Catatan run: `nice -n -10` ditolak OS ("cannot set niceness:
Permission denied" — shell ini tanpa CAP_SYS_NICE), run jalan di
prioritas normal dan tetap selesai <60 dtk. Warning owner
"Adding 'Pintu' as child to 'GubukMasuk_PintuPivot'..." muncul di
log (juga di run export) — warning saja, tidak menggagalkan tes.

### 3a. Asersi "Kolong tertutup" FLAKY — selidik Dewa 17 Nov ~18:12 WIB

**Gejala.** Di 3 re-run test_v2 (18:12 WIB, load ~5):
`GAGAL: Kolong tertutup (dapat (24.41094, -0.187262, 30.0))` —
TES V2 jadi 59/1, kolong satu-satunya gagal, posisi gagal IDENTIK
di ke-3 run. Run Kirana juga sempat 59/1 dengan gagal yang sama
(dapat (24.41, -0.31, 30.0)). Tapi di run 17:06 WIB asersi yang
sama LULUS (dapat (23.58906, -0.013511, 30.0)), dan probe fokus
Kirana 3× TERTUTUP + sempat 60/0 sebelum restart VM. Jadi:
kadang lulus, kadang gagal, di kode yang sama.

**Teori (dari parent) — TERKONFIRMASI: spawn tes mendarat tepat di
bidang tengah dinding kolong barat.** Bukti ukur (probe
`skrip/probe_kolong.gd`, dinding dibaca langsung dari scene):
dinding kolong barat `size=(0.12, 1.2, 3.0) pos_global=(24.0, 0.6,
30.0)` → bentang x **23.94..24.06**, pusat tepat **x=24.0**.
Teleport tes `(24, 0, 30)` = tepat di bidang tengah dinding.
Kapsul pemain r=0.35 (`main.gd:334`) overlap dinding 0,29 m di
kedua sisi — seri sempurna, arah depenetrasi ditentukan detail
mikroskopis run (fase frame/fisika, posisi NPC) sehingga bisa
flip antar run. Kedua hasil yang teramati persis dua sisi
depenetrasi: barat `23.94-0.35=23.59` (LULUS) vs timur
`24.06+0.35=24.41` (GAGAL).

**Bukti probe (3× `probe_kolong.gd` + 3× `probe_kolong2.gd`,
semua deterministik per varian):**
- Spawn bersih di barat dinding — dinding BEKERJA: x=23.5 →
  mentok 23.58906, y≈0; x=23.0 → mentok 23.58906, y≈0 (6/6 lulus).
- Spawn x=24.0 di probe terisolasi → barat (23.58906) 9/9; di
  test_v2 lengkap → timur 4/5, barat 1/5. Arah flip tergantung
  konteks run, bukan geometri.
- Spawn x=24.5 (di DALAM kolong, kontrol) → terjepit di bawah
  lantai y=-0.187262 — nilai y yang SAMA PERSIS dengan hasil gagal
  24.41. Jadi pemain yang terlempar ke timur berakhir dalam
  keadaan yang sama: terjepit antara pelat lantai (y 1,20..1,32)
  di atas dan tanah di bawah, tak bisa bergerak walau didorong
  +X 60 frame.

**Kesimpulan: geometri kolong BENAR, tidak diubah.** Dinding
menahan dengan benar setiap kali spawn tidak menabraknya.
**Rekomendasi ke Raka: pindahkan titik spawn tes kolong dari
`(24, 0, 30)` ke `(23.5, 0, 30)`** — kapsul 23.15..23.85,
bersih 0,09 m dari muka barat dinding (23.94). Itu perbaikan
TES, bukan geometri. Dewa TIDAK mengubah `test_v2.gd` /
`gubuk_masuk.gd` — menunggu keputusan Raka.

**RESOLUSI (Dewa, 18 Nov 2026 ~01:40 WIB — keputusan Raka,
disetujui).** Spawn tes kolong di `skrip/test_v2.gd:240`
dipindah `(24, 0, 30)` → `(23.5, 0, 30)` + komentar penjelasan
di baris atasnya. HANYA baris spawn tes itu yang berubah —
`scripts/gubuk_masuk.gd` dan semua geometri TIDAK disentuh.
Re-run `skrip/test_v2.tscn` headless 3× berturut-turut
(Godot 4.7.2, `~/workspace/.tools/godot-4.7/`):

| Run | Hasil | Kolong tertutup |
|-----|-------|-----------------|
| 1 | **60/0, exit 0** | LULUS (23.58906, -0.00022, 30.0) |
| 2 | **60/0, exit 0** | LULUS (23.58906, -0.007543, 30.0) |
| 3 | **60/0, exit 0** | LULUS (23.58906, -0.007535, 30.0) |

Flaky "Kolong tertutup" SELESAI — 60/0 stabil di ketiga run,
kolong konsisten mentok di x=23.589 (sisi barat, benar).
File probe sementara dihapus: `skrip/probe_kolong.gd/.tscn/.uid`
dan `skrip/probe_kolong2.gd/.tscn/.uid` (6 file). Status:
SELESAI, siap ronde export berikutnya. Tidak ada export/deploy
di tugas ini.

### 3b. "Kolong selatan tembus" (temuan Bagas fix4) — ARTEFAK, bukan cacat (Dewa, 18 Nov 2026 ~02:27 WIB)

**Temuan Bagas.** `test_tabrakan_dunia` fix4:
`GAGAL: kolong gubuk sawah (26,30) dari luar (tempuh=2.09 ideal=1.06
akhir=(26.0, -0.000921, 31.91094))` — diduga pemain menembus dinding
kolong selatan ~1,03 m.

**Bukti — geometri BENAR, ekspektasi probe yang salah:**

- **Dump dari scene hidup** (`probe_kolong_selatan.gd`, bentuk dibaca
  langsung dari `GubukMasuk_Collision`): dinding kolong selatan ADA,
  `size=(4.0, 1.2, 0.12) pos_global=(26.0, 0.6, 31.5)` → bentang
  z **31.44..31.56**, muka luar (selatan) **z=31.56**. Keempat dinding
  kolong ada dan benar posisinya: utara z 28.44..28.56, barat
  x 23.94..24.06, timur x 27.94..28.06 — semua dalam StaticBody3D
  yang sama dengan dinding barat yang TERBUKTI menahan.
- **Jarak_muka Bagas salah 1,03 m.** Spawn-nya (26,0,34) ke muka
  31.56 = **2,44 m**, bukan 1,41. Muka 32,59 yang ia tulis di
  komentar `test_tabrakan_dunia.gd:114` tidak ada di scene (tidak
  ada bentuk apa pun di z=32,59). Ideal BENAR = 2,44 − 0,35 =
  **2,09 — PERSIS tempuh yang ia ukur**. Selisih 1,03 m =
  persis galat jarak_mukanya (2,44 − 1,41). Posisi berhenti
  z=31.91 = 31,56 + 0,35 kapsul — tepat di muka dinding.
  Polanya sama dengan kasus "Jalan E-W tengah" fix4 Bagas sendiri
  (ekspektasi salah, objek menahan).
- **Probe bersih 17/17 LULUS** (semua tempuh SAMA PERSIS dengan
  ideal, kriteria band Bagas `[ideal-0,6, ideal+0,1]`):
  - Selatan→utara: (26,34) 3× tempuh 2.09 akhir z=31.91094
    (**identik** dengan log fix4 Bagas — ukurannya benar, harapannya
    yang salah); (26,35) 2× 3.09; (26,33.5) 2× 1.59 (spawn 1,94 m
    dari muka, masih bersih); (25,34) & (27,34) 1× 2.09 (off-center,
    dinding menahan di seluruh lebar 4 m).
  - Utara→selatan (dinding kolong utara): (26,26) 3× 2.09 akhir
    z≈28.09; (26,25) 2× 3.09; (25,26) 1× 2.09.
  - Kontrol: timur (30,30)→barat 1.59 akhir x=28.41; barat
    (22,30)→timur 1.59 akhir x=23.59.
- **Catatan:** dinding selatan TIDAK bisa diuji dari dalam kolong
  (utara→selatan dari sisi dalam) — pemain 1,7 m tidak muat di
  kolong 1,32 m, teleport ke dalam menjepit (sudah dibuktikan §3a).
  Bukti dari dalam diganti dump bentuk + dinding yang sama menahan
  di ketiga sisi lain.

**Kesimpulan: geometri kolong BENAR, `gubuk_masuk.gd` TIDAK diubah**
(sama seperti kasus kolong barat §3a). **Perbaikan yang diperlukan
ada di skrip Bagas, bukan geometri:** `skrip/test_tabrakan_dunia.gd:114`
— jarak_muka `1.41` → `2.44`, komentar "muka selatan dinding 32,59"
→ 31,56. Dewa TIDAK mengubah file Bagas — menunggu keputusan Raka.
Re-run `skrip/test_v2.tscn` 1× sesudah selidik: **60/0, exit 0**
("Kolong tertutup" LULUS (23.58906, -0.00028, 30.0)). File probe
sementara dihapus: `skrip/probe_kolong_selatan.gd/.tscn` (2 file,
tidak terbentuk `.uid`). `nice -n -10` tetap ditolak OS
("cannot set niceness: Permission denied", seperti §3) — run jalan
di prioritas normal, masing-masing selesai ~29 dtk. Tidak ada
export/deploy di tugas ini.

## 4. Foto

`foto-gubuk/sebelum/` + `foto-gubuk/sesudah/`, skrip
`skrip/foto_gubuk.gd` (+ `.tscn`), kamera game, **lanskap 1280×720**,
`xvfb-run godot --path . skrip/foto_gubuk.tscn -- <sebelum|sesudah>`.

**Sesudah — SELESAI 17 Nov 2026 ~18:26 WIB, 4/4 terverifikasi
visual (exit 0):**

| Foto | Isi (dicek mata) |
|---|---|
| G1-luar-depan.png (213 KB) | Gubuk dari utara: panggung, tangga depan, pintu terbuka, pemain di depan |
| G2-tangga.png (203 KB) | Pemain berdiri di tengah tangga, beranda + pintu terbuka di depan |
| G3-dalam-pintu.png (865 KB) | Dari dalam menghadap pintu: pemain di ambang pintu terbuka, dinding papan + jendela kiri terlihat |
| G4-dalam-rak.png (942 KB) | Dari dalam menghadap rak: rak kitab + 4 kitab warna (ungu/hijau/kuning/merah), lantai papan, lampu hangat |

Catatan foto:
- Run pertama (17:09–17:19 WIB) memakai potret 720×1280 — SEMUA
  foto ketutup overlay "PUTAR HP-MU" (game memaksa lanskap;
  preseden `foto_kamera.gd`). 4 PNG dihapus, skrip diubah ke
  1280×720, diulang.
- Run lanskap pertama: G3 gagal — posisi pemain z=30,6 bikin
  spring kamera tertekan dinding belakang (~0,9 m) + NPC lewat
  di depan kamera, kepala menutup seluruh frame. Posisi G3
  digeser ke z=29,2 (dekat pintu, kamera punya ruang 2,4 m ke
  dinding belakang) + re-run; G3 kedua bersih (pemain di ambang
  pintu terbuka). NPC kadang lewat di depan kamera dalam — kalau
  foto dalam terhalang lagi, itu NPC, bukan cacat framing.
- Chat bubble NPC (Bilal/Faris) kadang muncul di foto — insidental,
  bukan bagian staging.

**Sebelum — SELESAI 17 Nov 2026 ~18:35 WIB, 4/4 (exit 0, G1+G3
dicek visual):** pintu ditutup kembali (visual saja, collision
modul tak berubah) — G1: gubuk dari utara, pintu TERTUTUP (muka
depan gelap, tak ada bukaan); G3: dari dalam, daun pintu tertutup
terlihat jelas sebagai panel kayu di ambang. Kontras dengan
sesudah (pintu terbuka, cahaya luar masuk). Catatan: set sebelum
keambil saat waktu game malam (langit dinamis — G1 gelap), set
sesudah saat senja; perbedaan terang itu waktu game, bukan lampu
gubuk (lampu interior hangat sama di kedua set).

## 5. Catatan untuk Raka / Bima

- **Bima TIDAK diperlukan** untuk tugas ini (model sudah lengkap).
- Satu cacat visual model (bukan penghalang masuk, dicatat saja): tiang
  tengah + sudut (0,18 × 0,18 m) menembus bidang dinding ~2–10 cm ke
  luar (mis. Tiang.002 Z 1,33..1,51 vs dinding belakang Z 1,29..1,41).
- `GLB_GubukKebun` (90,0,10) ikut dipasangi modul yang sama (pintu
  terbuka, collision, ramp, lampu — terverifikasi node `GubukMasuk`
  ada), TAPI: posisinya di zona putri (x>14, z<16) — pemain putra
  didorong balik `_cek_batas` sebelum sampai ke sana; santriwati bisa.
  Tes jalan-masuk hanya untuk GubukSawah.
- Kaki melayang maks 0,11 m di tengah anak tangga saat naik ramp
  (kompromi ramp halus di atas tangga — lihat §2.5). Kalau Mas
  keberatan, alternatifnya: Bima ubah model tangga jadi ramp kayu
  (bukan anak tangga) — tapi itu ubah visual yang sudah DI-ACC, jadi
  tidak disarankan.
