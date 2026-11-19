# RONDE 13 — Sholat berjamaah otomatis (16 Nov ~06:30–07:00 WIB, Raka)

**Pemicu:** Mas 06:30 WIB *"Terus nambah 1 fitur kalau masuk waktu
sholat maka semuanya ke surau untuk sholat."*

**Aturan:** mihrab/sajadah TIDAK disentuh (keputusan mihrab miring
belum ada saat ronde ini dikerjakan — lihat §6, koreksi Mas 06:47
sudah masuk handoff ronde 14). **TIDAK deploy** — deploy urusan
Damar (staging `export/web-pages/` masih berisi pck ronde 12;
Damar perlu menyalin pck baru ke staging + cek guard seperti biasa).

## 1. Yang dibangun

**Waktu sholat (jam perangkat, WIB, tetap)** — `MissionData.WAKTU_SHOLAT`
+ `sholat_saat_ini(jam)`: Subuh 04:30, Dzuhur 12:00, Ashar 15:00,
Maghrib 18:00, Isya 19:00; jendela sesi = mulai + **10 menit**.
`sholat_saat_ini` menerima jam sebagai parameter (cermin
`khataman_saat_ini`, tapi itu membaca jam sistem langsung) supaya
`LangitDinamis.jam_saat_ini()` — termasuk override `debug_jam` —
yang dipakai. **Batasan (jujur):** waktu asli berubah tiap hari;
versi ini pakai jam tetap dulu, hisab dinamis adalah ronde lain.

**Pose sholat (player.gd)** — aksi baru `"sholat"`, siklus 8 dtk:
qiyam 5 dtk (berdiri tegak, lengan bersedekap: lengan −0,75,
siku −1,1) ↔ ruku 3 dtk (badan condong 0,55, lengan −0,25,
siku −0,1). Dimulai dari qiyam (`_sholat_t` di-reset di `set_aksi`).
**Sujud TIDAK dibuat** — badan telungkup dari primitif terbaca
seperti pose tidur yang sudah ada, membingungkan. `"sholat"` masuk
`sedang_aksi_diam()` (menahan gerak).

**NPC (npc.gd)** — mode rute: sinyal `rute_selesai(npc)`,
`mulai_rute(Array[Vector3])`, `mulai_pose_sholat(yaw)`,
`selesai_sholat()`, `sedang_sholat()`, `sedang_pose_sholat()`;
jalan memakai animasi jalan yang sama (`_langkah_ke`); pose sholat
identik dengan pemain; NPC tidak mengobrol selama mode sholat
(timer ngobrol dilewati).

**Rute NPC (main.gd)** — `_rute_ke_pintu_surau(dari)`, SEGMENTASI
(Manhattan), BUKAN garis lurus: garis lurus dari utara akan
menembus dinding Surau/cangkruk. Koridor aman: z ≤ −22 (utara
kedua bangunan), x ≤ −12 (barat Surau), z ≥ 2 (plaza selatan).
Urutan: (1) ke z=−22 kalau masih di utara; (2) ke x=−12;
(3) ke selatan sampai plaza (z=2); (4) ke depan pintu (0, 2);
(5) pintu (0, −6,2). NPC masuk interior lewat TELEPORT di pintu
(pindah map ala GTA, sama seperti pemain — bukan menembus dinding).
Pulang: `_rute_pulang(npc)` cermin dari rute berangkat.

**Sajadah** — Bilal → Sajadah_02, Faris → Sajadah_04, pemain →
Sajadah_03 (baris depan, tengah). Posisi diambil dari scene SAAT
ITU (`_posisi_sajadah`, `find_child` + `global_position`), JANGAN
hardcode — supaya rotasi Surau ronde 14 tetap benar otomatis.
**Hadap kiblat:** `KIBLAT_YAW = −2,0071` rad (−115°; arah kiblat
(sin 295°, −cos 295°) = (−0,906, −0,423), wajah di +Z lokal →
yaw = atan2(x, z)).

**Banner pemain (ui.gd)** — sinyal `ikut_sholat_pressed`;
PanelContainer gelap semi-transparan di tengah-atas (y=120, di
bawah toast y=70): label "Waktu sholat [nama] — ayo ke Surau!" +
tombol emas "IKUT SHOLAT". `show_sholat_banner(nama)` /
`hide_sholat_banner()` / `is_sholat_banner_visible()`; layout
saat resize. NON-modal (boleh diabaikan). Tumpang tindih yang
diketahui: kalau panel chat terbuka, banner menutupi sebagian
atasnya (jarang, sesi cuma 10 menit).

**Driver sesi (main.gd)** — `_cek_waktu_sholat()` tiap frame
(setelah `_cek_pintu_cangkruk()`, hanya saat dunia terlihat):
masuk jendela → `_mulai_sholat` (toast + banner + per NPC: simpan
posisi rumah, tetapkan sajadah, ucap "Ayo sholat berjamaah di
Surau!", mulai rute); jendela habis → `_akhiri_sholat` (banner
hilang, toast, pemain yang ikut berdiri lagi, NPC di dalam jalan
ke pintu dalam dulu, NPC yang masih di luar langsung pulang).
Mesin fase per NPC: `ke_pintu` → (teleport ke `_interior_spawn`)
`ke_sajadah` → (pose sholat) `sholat` → `pulang_dalam` →
(teleport ke `_outdoor_exit`) `pulang_luar` → selesai.
`_on_ikut_sholat()`: bangunkan kalau tidur, tutup semua panel,
teleport pemain ke Sajadah_03 menghadap kiblat, kamera di belakang
pemain, aksi "sholat". Aksi apa pun / gerak / Reset Posisi
mengakhiri keikutsertaan (banner tampil lagi selama sesi berjalan).
Pemain yang sedang misi/tidur TIDAK dipaksa teleport — toast dulu,
pemain yang memilih ikut.

**Ma'hadiyah sengaja TIDAK diintegrasikan:** ikut satu sholat
tidak boleh menandai "Lima waktu berjamaah" (itu artinya kelimanya);
pelacak `sholat_hadir` adalah tindak lanjut yang mungkin.

## 2. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: `mission_data.gd`, `player.gd`, `npc.gd`, `ui.gd`,
  `main.gd` — semua lolos.
- **Tes headless `test_ronde13.gd`: 44 LOLOS / 0 GAGAL, exit 0** —
  jadwal 8 (termasuk jendela 18:09 masuk, 18:17 habis), KIBLAT_YAW
  −115°, tidak ada sesi jam 10:00, sesi Maghrib mulai + banner,
  kedua NPC fase sholat + di sajadahnya (< 0,6 m) + menghadap kiblat
  (±0,05 rad) + pose aktif, rute aman dari 7 arah (disampel per
  segmen, tidak menyentuh tapak Surau/cangkruk), pemain ikut
  (di dalam, di Sajadah_03, aksi sholat, banner hilang), pose pemain
  (qiyam lengan −0,75; ruku condong > 0,4), keluar lewat Aksi →
  Berdiri (flag mati, banner tampil lagi), sesi berakhir 18:12
  (banner hilang, pemain berdiri, NPC pulang_dalam → pulang_luar →
  keliling bebas), banner API. 1 gagal di run pertama adalah BUG
  TES (cek KIBLAT_YAW sebelum main.tscn dimuat — `_main` masih
  null), diperbaiki, bukan bug game. `Engine.time_scale = 10`
  dipakai supaya jalan kaki NPC tidak menunggu waktu nyata.
- **Smoke headless 600 frame scene utama (sesi Dzuhur aktif):
  0 SCRIPT ERROR.**
- **5 foto bukti** di `~/workspace/pesantren-verse/foto-ronde13/`
  (960×540, xvfb-run + opengl3, via `LangitDinamis.debug_jam`):
  - `03-banner-ikut-sholat.png` — Dzuhur 12:00, kamera game: toast
    "Waktu sholat Dzuhur — ayo ke Surau!" + banner + tombol emas
    IKUT SHOLAT, keduanya terbaca. ✓
  - `01-npc-jalan-maghrib.png` — Maghrib 18:00 (senja, lampu
    menyala): Bilal + Faris berjalan di jalan setapak menuju pintu
    Surau, banner Maghrib tampil. ✓
  - `02-npc-sholat-sajadah.png` — dari dalam Surau: Bilal + Tes +
    Faris di sajadah baris depan membelakangi kamera menghadap
    mihrab (panel hijau tua + lis emas, di tengah frame). Figur
    dalam foto ini sedang RUKU (badan condong) — lihat §3. ✓
  - `05-qiyam-closeup.png` — close-up dari samping: Tes + Faris
    condong (ruku), BUKAN qiyam seperti rencana — lihat §3. ✓
    (sebagai bukti pose, bukan qiyam).
  - `04-npc-kembali-luar.png` — RETAKE (run diagnosis): Faris di
    rumput kiri, Bilal di tanah kanan jalan — keduanya di luar,
    kembali keliling bebas. ✓
- **Export `export/web/`:** pck BARU **998.736 byte** sha256
  `edba6cf9fae6692b9c74e02feccce1b3f6a0bd7d68f3a4ff64be6c6b6b733329`
  (+9.840 dari ronde 12 — fitur baru); wasm TIDAK berubah
  (`fc74679e…`); index.js TIDAK berubah (`33c94cb3…`); worklet ada
  (2.973 byte). Smoke pck via `--main-pack` 600 frame 0 error.
  File tes/foto/diagnosis dihapus sebelum export (pck bersih;
  `ls *.gd` root = 0). **TIDAK deploy** — deploy urusan Damar.

## 3. Jujur / belum sempurna

- **Foto 02 + 05 menangkap RUKU, bukan qiyam.** Di bawah llvmpipe
  frame lambat (~5–10 fps), 40 frame tunggu setelah ikut ≈ 4–8
  detik waktu game — masuk jendela ruku (5–8 dtk). Qiyam (lengan
  bersedekap −0,75) terbukti NUMERIK oleh tes, bukan oleh foto.
  Kalau Mas mau foto qiyam, ambil ≤ 3 detik setelah ikut.
- **Sosok "di atap Surau" di foto 04 pertama BUKAN bug — oklusi
  benar.** Bilal selesai pulang lalu keliling bebas ke UTARA balik
  Surau; dari kamera plaza, badannya tertutup Surau, hanya kepala
  + torso + atas sarung tampak di atas garis atap. Terbukti lewat
  diagnosis: posisi akhir headless NPC0 (6,09, 0, 6,36) dan NPC1
  (−5,81, 0, 9,74) — semua y=0, fase kosong; run diagnosis
  (xvfb, dengan print posisi) NPC0 (7,76, 0, −0,92), NPC1
  (−5,88, 0, 9,83), visual = posisi node. Foto 04 di-retake dari
  run diagnosis supaya Bilal terlihat jelas di tanah.
- **Sajadah miring 25° (diketahui, ini urusan ronde 14).**
  Diagnosis mencetak posisi sajadah sebenarnya: Sajadah_02
  (−2,83, −300,47), Sajadah_03 (−1,81, −302,65), Sajadah_04
  (−0,80, −304,82) — baris depan berjalan DIAGONAL (diputar
  −295° sejak ronde 10), bukan sejajar dinding. Di foto 02 baris
  sajadah memang tampak diagonal. Bukan bug ronde 13 (lookup
  runtime sudah benar); ronde 14 yang meluruskan.
- **Pemain tetap di dalam Surau setelah sesi habis** (berdiri di
  Sajadah_03) — sengaja, pemain keluar lewat pintu seperti biasa.
  Di foto 04 pemain tidak tampak karena masih di interior.
- **Batasan rute (didokumentasikan di kode):** NPC yang PERSIS di
  dalam tapak bangunan saat sesi mulai (transien keliling bebas
  yang memang sudah menembus dinding di segmen (8,−2)↔(0,−20))
  tetap jalan lurus keluar di kaki pertama — kasus langka, sama
  seperti keliling bebas yang sudah ada.
- **Waktu sholat tetap** (Subuh 04:30 dst.) — bukan hisab dinamis.
- Portrait 390×844 belum teruji — perlu HP Mas (seperti biasa).

## 4. File yang diubah

- `scripts/mission_data.gd` — `WAKTU_SHOLAT` + `sholat_saat_ini(jam)`.
- `scripts/player.gd` — aksi `"sholat"` (qiyam/ruku), `_sholat_t`.
- `scripts/npc.gd` — sinyal `rute_selesai`, mode rute/pose sholat.
- `scripts/ui.gd` — banner sholat + sinyal `ikut_sholat_pressed`.
- `scripts/main.gd` — driver sesi + rute Manhattan + `_on_ikut_sholat`.

## 5. Handoff RONDE 14 (putar Surau 25°) — WAJIB dibaca

1. **Koreksi Mas 06:47 WIB: "Mihrab harusnya di tengah tembok.
   Bukan di pojok."** Mihrab sekarang di (−8,4, −306,0) — dekat
   pojok utara dinding barat (tengah dinding = z=−301). Saat
   memutar Surau 25°, letakkan mihrab di **TENGAH dinding kiblat**
   (pusat dinding, bukan dekat pojok), dan barisan sajadah ikut
   terpusat menghadap mihrab. Foto bukti ronde 14 harus menunjukkan
   mihrab di tengah dinding dari dalam Surau.
   - Angka yang membantu: dinding barat membentang z=−308..−294
     (14 m), tengah z=−301. Grid sajadah SUDAH terpusat di
     (0, −301) (lokal x −4,8..+4,8, z −2..+2) — yang melenceng
     hanya mihrabnya (5 m ke utara dari pusat barisan). Jadi di
     ronde 14: pindahkan mihrab z −306 → −301 (koordinat
     pra-rotasi), lalu putar semuanya 25°; barisan sajadah akan
     sejajar dinding + terpusat pada mihrab.
   - Perhatian: posisi sajadah di-lookup runtime
     (`_posisi_sajadah`), jadi pemindahan mihrab + rotasi Surau
     TIDAK merusak fitur sholat ronde 13 — tapi verifikasi ulang
     tetap wajib (NPC harus tetap sampai ke sajadah yang sudah
     diputar; foto (c) ronde 14 adalah bukti itu).
2. Putar SELURUH Surau (eksterior + interior) 25°; sesuaikan pintu,
   jalan setapak, plakat, trigger masuk, keselarasan pintu
   eksterior ↔ interior; peta menyesuaikan kalau penanda bergeser.
3. Setelah diputar, verifikasi ulang fitur ronde 13 (tes ronde 13
   bisa dipakai ulang — 44 cek — plus foto NPC sholat di Surau
   yang sudah diputar).
4. Foto ronde 14: (a) Surau dari luar — miring 25° terhadap jalan,
   pintu + plakat benar; (b) dari dalam menghadap mihrab — mihrab
   RATA dengan dinding DAN DI TENGAH dinding, sajadah sejajar
   dinding; (c) NPC sholat berjamaah di Surau yang sudah diputar.
5. Staging `export/web-pages/` masih berisi pck ronde 12
   (8d72a1ae…) + index.html ber-patch (3 script, `})();` baris
   144) — Damar menyalin pck ronde 13 (edba6cf9…) ke staging saat
   deploy, guard seperti biasa.
