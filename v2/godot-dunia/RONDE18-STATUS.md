# RONDE 18 — Skema sholat sinematik: takbir → blackout → selesai (16 Nov ~12:10–12:33 WIB, Raka)

**Pemicu:** Mas 12:09 WIB *"Sholat 1 menit aja.. terus sholatnya kok
cuma takbir sama rukuk aja? Tidak sesuai sholat pada umumnya.."*
— rencana awal: sesi 1 menit + rangkaian 1 rakaat lengkap 60 dtk
(takbir → qiyam → ruku → i'tidal → sujud → duduk → sujud → tasyahud
→ salam; sujud WAJIB dibuat).
**PERUBAHAN ARAH Mas 12:14 WIB — rencana itu BATAL:** *"adegan sholat
cukup diambil pas TAKBIR saja, lalu BLACK OUT, lalu selesai sholat"*.
Ronde 18 = skema sinematik singkat. Sujud TIDAK dibuat sama sekali
dalam skema ini.

**Aturan:** posisi imam Kyai, rute NPC, pulang setelah sesi, banner
tidak memaksa, pemain tetap di Surau setelah sesi — SEMUA TETAP.
Hook audio ronde 17 (wirid saat sholat) tetap. Sistem 21 regu CCS
TIDAK disentuh. **TIDAK deploy** — deploy ditahan sampai retest
browser ronde 10+11+12+13+14 selesai; deploy berikutnya jadi ronde
**15+16+17+18 SEKALI**.

## 1. Yang dibangun

**Durasi sesi: 10 menit → 1 menit** (`scripts/mission_data.gd`):
`WAKTU_SHOLAT` — semua 5 sesi `durasi_menit: 10 → 1`. Jam mulai tetap
(Subuh 04:30, Dzuhur 12:00, Ashar 15:00, Maghrib 18:00, Isya 19:00).
`sholat_saat_ini()` default durasi ikut jadi 1. Jendela 1 menit cukup
untuk adegan (±30 dtk): kumpul ±10–20 dtk jalan + takbir 4 dtk +
blackout 2,5 dtk + fade masuk 0,8 dtk.

**Mesin adegan sinematik** (`scripts/main.gd` — `_sholat_adegan`,
`_proses_adegan_sholat()`, dipanggil tiap frame selama adegan ada):
- `"kumpul"` — NPC jalan ke Surau seperti ronde 13; banner IKUT
  SHOLAT masih tampil. Takbir mulai kalau SEMUA NPC sudah di sajadah
  (fase `"sholat"`), atau timeout **`KUMPUL_TIMEOUT_DETIK = 25.0`**
  (NPC nyangkut di jalan; takbir jalan dengan yang ada).
- `"takbir"` — semua di sajadah, tangan terangkat, tahan
  **`TAKBIR_TAHAN_DETIK = 4.0`**. Banner disembunyikan saat takbir
  mulai = pendaftaran ikut DITUTUP.
- `"gelap"` — overlay menghitam, fade out
  **`BLACKOUT_FADE_DETIK = 0.5`**, tahan hitam sampai
  **`BLACKOUT_DETIK = 2.5`**, teks kecil *"Sholat berjamaah..."*.
- `"selesai"` — sesi berakhir (NPC pulang, pemain berdiri) TAPI layar
  tetap hitam dulu; fade masuk **`FADE_MASUK_DETIK = 0.8`**, lalu
  overlay hilang total. Timer adegan di waktu GAME (delta `_process`),
  bukan jam perangkat (supaya tes dengan `debug_jam` beku tetap jalan).
- `_akhiri_sholat(fade_in: bool = false)` — `fade_in=true` (akhir
  sinematik) membiarkan overlay untuk fade masuk; `false` (batas jam /
  abort) menyembunyikan overlay langsung supaya pemain tidak terjebak
  di layar hitam.
- Guard baru: `_on_ikut_sholat()` hanya selama `"kumpul"`;
  `_respawn_ke_spawn()` hanya menampilkan lagi banner selama
  `"kumpul"` (bukan saat takbir/blackout).

**Pose TAKBIR statis** (`scripts/player.gd` + `scripts/npc.gd`) —
siklus qiyam 5 dtk ↔ ruku 3 dtk ronde 13 **DIHAPUS**:
- Pemain (`_terapkan_pose` cabang `"sholat"`): berdiri di sajadah,
  kedua lengan TERANGKAT ke telinga (`rotation.x = -2.6`, siku `-0.6`,
  lengan sedikit membuka `rotation.z ±0.15`), badan tegak (`0.05`).
- NPC (`_animasi_sholat`): target pose yang sama, statis.
- `_sholat_t` DIHAPUS di kedua file (deklarasi + reset + increment).

**Overlay BLACKOUT** (`scripts/ui.gd`): `_build_blackout_overlay()`
(dibangun TERAKHIR di `_ready` supaya selalu paling atas) — Control
full-rect + ColorRect hitam + label *"Sholat berjamaah..."* (26 pt,
putih) di tengah; `mouse_filter = IGNORE` (tidak memblokir klik saat
fade). API: `show_blackout()` / `set_blackout_alpha(a)` (modulate.a —
bg + teks fade bersama) / `hide_blackout()` / `is_blackout_visible()`
/ `get_blackout_alpha()`.

## 2. Dua bug yang ditemukan & diperbaiki selama ronde ini

**(a) Sesi akan jalan DUA KALI dalam 1 jendela (bug nyata, akibat
langsung jendela 1 menit).** Adegan sinematik selesai ±30 dtk —
SEBELUM jendela 1 menit habis — jadi `_cek_waktu_sholat()` langsung
memulai sesi yang sama lagi (NPC jalan balik, takbir kedua). Perbaikan
(`main.gd`): kunci anti-ulang `_sholat_sudah` = nama + jam mulai +
tanggal (ditandai di `_akhiri_sholat()`, dicek di `_cek_waktu_sholat()`,
dibersihkan saat tanggal berganti). Sesi lain di hari yang sama tetap
bisa jalan (kunci berbeda). Dibuktikan tes: setelah Dzuhur selesai di
jam 12:00 beku, sesi TIDAK mulai lagi; Ashar 15:00 tetap bisa mulai.

**(b) NPC melompati waypoint lalu berosilasi, tidak pernah sampai
(bug laten rute, ketahuan dari foto).** `_langkah_ke()` + jalan bebas
NPC melangkah `SPEED × delta` tanpa batas — dengan delta besar (lag /
`time_scale` tinggi di bawah llvmpipe) satu langkah 16 m melompati
target 0,4 m, lalu bolak-balik melewatinya selamanya. Foto takbir
pertama menangkap ini: Bilal masih di dekat meja, lengan turun, saat
timeout kumpul memicu takbir. Perbaikan (`npc.gd`, 2 tempat):
langkah dijepit `minf(SPEED * delta, to.length())` — NPC mendarat
TEPAT di target berapa pun deltanya. Ini juga membuat game tahan lag
spike di HP lambat (bukan cuma urusan tes).

## 3. Verifikasi

- `--import` exit 0, 0 error.
- `--check-only`: `mission_data.gd`, `main.gd`, `player.gd`, `npc.gd`,
  `ui.gd` — semua lolos.
- **Tes headless `test_ronde18.gd`: 65 LOLOS / 0 GAGAL, exit 0, tanpa
  SCRIPT ERROR** — durasi 5 sesi = 1 menit + batas jendela (12.00 =
  Dzuhur; 12.016 = Dzuhur [12:00:57]; 12.017 = kosong [12:01:01];
  11.99/08.00 kosong; Subuh/Ashar/Maghrib) + sesi Dzuhur penuh
  (kumpul → banner tampil → pemain ikut [di Surau, aksi sholat,
  1,5 m di belakang imam] → takbir [banner hilang, pemain + SEMUA NPC
  lengan −2.6, tidak ada yang ruku (badan 0.55), Kyai di posisi imam,
  takbir STATIS di 3 sampel] → gelap [overlay tampil, alpha 1, teks
  "Sholat berjamaah..."] → selesai [blackout hilang, pemain berdiri,
  tetap di Surau, semua NPC pulang, Kyai kembali ke serambi + diam,
  ANTI-ULANG]) + abort jam saat kumpul (Ashar 15.02 → sesi berakhir,
  adegan bersih, overlay tidak tampil, tidak mulai lagi) + abort jam
  saat takbir (Maghrib 18.02, pemain ikut → sesi berakhir, pemain
  berdiri, tetap di Surau, tidak terjebak hitam) + regresi (posisi
  imam deterministik + > 5 m dari pintu dalam, 3 sajadah berbeda,
  node audio + tombol Suara ada, save default `suara_mati=false`,
  langkah dijepit [delta 10 dtk mendarat TEPAT, panggilan berikut =
  sampai]) + smoke 600 frame. Save lokal di-backup + dikembalikan
  (terverifikasi: PV-0001 "Tes", 0 poin, `suara_mati=false`).
  1 gagal di run pertama adalah BUG TES (12.016 dikira di luar
  jendela — padahal 12:00:57 masih di dalam; diperbaiki, bukan bug
  game). 1 baris `ERROR: Condition "status < 0" ... ERR_CANT_OPEN`
  di awal run xvfb adalah driver audio VM tanpa soundcard (sama
  seperti ronde 17, bukan SCRIPT ERROR).
- **3 foto bukti** di `~/workspace/pesantren-verse/foto-ronde18/`
  (960×540, xvfb-run + opengl3, `debug_jam` 12.00):
  - `01-takbir.png` — keempatnya di sajadah, tangan terangkat: Bilal
    (gelap + kacamata + songkok hitam + sarung biru), Kyai (serban
    putih, label "Ust. Aqsal Murad"), pemain "Tes" (songkok putih +
    sarung biru), Faris (songkok putih + sarung coklat). Catatan:
    Bilal ~60% di frame kiri-bawah (terpotong tepi + joystick) —
    2 retake kamera (rig manual + pitch diratakan) tidak mengubah
    banyak; foto ini sudah membuktikan adegan.
  - `02-blackout.png` — layar hitam penuh + teks "Sholat berjamaah..."
    di tengah. ✓
  - `03-selesai.png` — toast "Sholat Dzuhur selesai.", Kyai berjalan
    pulang (kiri), Tes + Faris berdiri di sajadah. ✓
  Trik foto: fase takbir (4 dtk) + blackout (2,5 dtk) singkat — begitu
  fase terdeteksi, game di-freeze (`time_scale=0`) lalu foto diambil;
  `time_scale` foto = 2.0 (bukan 10 — pada 10, satu frame llvmpipe
  melompati satu fase utuh).
- **Export `export/web/`:** pck BARU **1.544.020 byte** sha256
  `d086954d854b0473df3aab85322321928f09a04291761412625fa1fe2895dea4`
  (+2.480 dari ronde 17); wasm TIDAK berubah (`fc74679e…`,
  39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet
  ada (2.973 byte). Smoke pck via `--main-pack` 30 detik: **0 SCRIPT
  ERROR**. File tes/foto dihapus sebelum export (pck bersih;
  `ls *.gd` root = 0).
  **TIDAK deploy** — deploy urusan Damar, DITAHAN sampai retest
  browser ronde 10+11+12+13+14 selesai; deploy berikutnya jadi ronde
  **15+16+17+18 SEKALI**.

## 4. Jujur / belum sempurna

- **Adegan sholat BELUM teruji di browser sungguhan.** Headless
  membuktikan logika + urutan + timing; takbir/blackout/fade di
  browser nyata + HP Mas perlu retest browser (sama seperti ronde
  13–17 — foto di atas dari llvmpipe, bukan browser).
- **Timeout kumpul 25 dtk tetap ada sebagai jaring pengaman:** kalau
  satu NPC benar-benar nyangkut (bukan karena bug langkah — itu sudah
  diperbaiki), takbir jalan dengan yang ada. Di tes headless semua NPC
  selalu sampai sebelum timeout.
- **Foto takbir:** Bilal terpotong di kiri-bawah (posisi paling dekat
  kamera + joystick menutupi). Kyai/Tes/Faris penuh di frame.
- **Label "TERKUNCI" (penanda M2) masih melayang di interior** sampai
  M1 selesai — bukan bug ronde 18 (sudah ada sejak ronde 12).
- **Waktu sholat masih jam TETAP** (bukan hisab dinamis) — batasan
  sejak ronde 13, tidak diubah ronde ini.
- **Portrait 390×844 belum teruji** — perlu penilaian Mas di HP.
- Satu baris `ERROR: Condition "status < 0" ... ERR_CANT_OPEN` di
  awal run xvfb = driver audio VM tanpa soundcard, bukan bug game
  (sama seperti ronde 17).
