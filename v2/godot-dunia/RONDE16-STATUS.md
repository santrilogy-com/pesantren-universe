# RONDE 16 — Ust. Aqsal Murad memimpin sholat berjamaah sebagai imam (16 Nov ~08:22–08:40 WIB, Raka)

**Pemicu:** Mas 08:22 WIB *"Iya"* (setuju dengan catatan ronde 15 — secara
tema Pengasuh seharusnya memimpin sebagai imam, bukan tetap di serambi
saat Bilal+Faris sholat).

**Aturan:** sistem sholat ronde 13 TIDAK diubah strukturnya (5 waktu tetap
+ sesi 10 menit + banner + IKUT SHOLAT); mihrab/sajadah TIDAK disentuh;
posisi imam dihitung runtime dari grid sajadah (seperti `_posisi_sajadah`,
supaya rotasi Surau ronde 14 tetap benar otomatis). **TIDAK deploy** —
deploy ditahan sampai retest browser ronde 10+11+12+13+14 selesai
(retest sedang jalan melawan build live ad5074ed; ronde 15 juga menunggu
deploy yang sama — deploy 15+16 SEKALI).

## 1. Yang dibangun

**Posisi imam** (`scripts/main.gd` `_posisi_imam()` + konstanta
`IMAM_JARAK_DEPAN = 1.5`): tengah baris depan (Sajadah_03) + arah kiblat
× 1,5 m. Terukur: 1,5 m di depan pusat Sajadah_03 (≈0,9 m di depan tepi
depan sajadah — sajadah 1,15 m); **4,90 m dari mihrab** (tidak menempel
dinding); > 1 m dari Sajadah_02/04 (tidak menabrak jamaah); **di sumbu
mihrab** (segaris Sajadah_03→mihrab, < 0,1 m); di dalam ruangan; 5,34 m
dari smartboard. Imam 1,52 m di depan Bilal (searah kiblat).

**Alur sesi** (`_mulai_sholat`): NPC diam (Kyai) TIDAK lagi dilewati —
ia jalan ke Surau seperti Bilal/Faris (rute Manhattan yang sama +
teleport ala GTA di pintu), tapi ke **posisi imam** (bukan sajadah
jamaah); counter sajadah `j` hanya untuk jamaah supaya Bilal tetap
Sajadah_02 dan Faris tetap Sajadah_04. Kalimat Kyai saat berangkat:
"Ayo sholat berjamaah — saya jadi imam." (Bilal/Faris tetap "Ayo sholat
berjamaah di Surau!").

**Pose** (`npc.gd` — tidak diubah): pose sholat Kyai sama seperti jamaah
(siklus qiyam 5 dtk bersedekap ↔ ruku 3 dtk; sujud TIDAK dibuat, sesuai
keputusan ronde 13). Mode `diam` di `_process` dicek SETELAH
`_mode_sholat`, jadi rute sholat mengambil alih mode diam selama sesi;
`selesai_sholat()` mengembalikannya (komentar di `npc.gd` diperbarui —
yang lama bilang NPC diam tidak ikut sholat).

**Pulang** (`_akhiri_sholat` + mesin fase — tidak diubah, generik): Kyai
di fase "sholat"/"ke_sajadah" → "pulang_dalam" (jalan ke pintu dalam) →
teleport ke `_outdoor_exit` → "pulang_luar" (rute `_rute_pulang` ke
serambi via plaza (0,2) — segmennya di selatan dinding Surau, tidak
menembus bangunan) → fase "" + `selesai_sholat()` → kembali mode `diam`
di serambi. Rumah Kyai tersimpan saat sesi mulai (serambi).

**Tidak berubah:** banner + tombol IKUT SHOLAT (pemain tetap ke
Sajadah_03); Kyai tetap muncul di peta (posisinya ikut berpindah saat
sholat — `_data_peta` membaca semua `_npcs`).

## 2. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: `main.gd`, `npc.gd` — semua lolos.
- **Tes headless `test_ronde16.gd`: 49 LOLOS / 0 GAGAL, exit 0** —
  keadaan awal (Kyai di serambi, diam, fase kosong) + geometri imam
  (1,5 m di depan Sajadah_03, 4,90 m dari mihrab, > 1 m dari 02/04,
  segaris sumbu mihrab, di dalam ruangan, 5,34 m dari smartboard,
  15 sajadah ada) + sesi Dzuhur 12.00 (banner tampil, Kyai/Bilal/Faris
  fase ke_pintu, rumah Kyai = serambi, rute Kyai 2 titik berakhir di
  depan pintu) + ketiganya pose (Kyai di posisi imam 0,35 m, Bilal di
  02, Faris di 04, ketiganya menghadap kiblat ±0,05 rad, lengan Kyai
  dalam rentang qiyam/ruku, badan tidak telungkup, imam 1,52 m di depan
  Bilal, Kyai di peta di posisi imam) + pemain ikut (Sajadah_03, aksi
  sholat, Kyai TETAP di posisi imam) + sesi berakhir 12.30 (banner
  hilang, Kyai pulang_dalam → fase kosong, kembali ke serambi 0,34 m,
  kembali mode diam, Bilal + Faris keluar mode sholat) + regresi
  (visual Kyai masih punya Serban, frame pintu Surau tetap, posisi
  Sajadah_03 stabil). 2 gagal di run pertama adalah BUG TES (await
  coroutine + inferensi tipe Variant — diperbaiki, bukan bug game).
  `Engine.time_scale = 10` dipakai supaya jalan kaki NPC tidak
  menunggu waktu nyata. Save lokal di-backup + dikembalikan di akhir
  tes (login PV-0001 menulis user://santri.json).
- **Smoke headless 600 frame scene utama (sesi Dzuhur aktif):
  0 SCRIPT ERROR.**
- **4 foto bukti** di `~/workspace/pesantren-verse/foto-ronde16/`
  (960×540, xvfb-run + opengl3, Dzuhur 12.00 via `LangitDinamis.debug_jam`):
  - `01-imam-dari-belakang.png` — RETAKE (skrip foto pertama hanya
    menunggu Kyai — Bilal/Faris belum sampai; retake menunggu ketiganya
    + orbit kamera −0,7 rad supaya Kyai tidak tertutup pemain): saf
    lengkap qiyam (Bilal–Tes–Kyai–Faris), Kyai di depan, smartboard
    bersih, mihrab di dinding kiri. Kyai masih sebagian tertutup
    pemain — lihat 01b. ✓
  - `01b-imam-dari-mihrab.png` — kamera BEBAS 3 m di depan Kyai (arah
    kiblat, tinggi 1,8 m — kamera pemain selalu menarget pemain
    sehingga Kyai tertutup badannya): wajah Kyai JELAS (serban 3
    lilitan + jenggot + kumis tipis + mulut + lengan bersedekap),
    Tes–Faris–Bilal di belakangnya semua qiyam, toast "Kamu ikut
    sholat Dzuhur berjamaah." ✓ (foto utama ronde ini)
  - `02-imam-samping.png` — RETAKE (alasan sama + yaw PI/2 − 0,26
    supaya mihrab lebih ke tengah): barisan qiyam dari samping,
    mihrab (panel hijau tua + lis emas) DI TENGAH dinding, smartboard
    bersih di dinding kanan, sajadah sejajar. ✓
  - `03-kyai-kembali-serambi.png` — RETAKE 2× (run pertama: Kyai
    kecil + jauh karena respawn di selatan; run kedua: Bilal kebetulan
    berdiri tepat di depan Kyai — diperbaiki dengan staging foto:
    Bilal + Faris dipindah ke rumahnya, pemain diteleport ke (0,0,−2)
    menghadap Kyai): Kyai kembali di serambi (serban + label
    "Ust. Aqsal Murad" terbaca), pintu + plakat مصلى الإخلاص di
    belakangnya. ✓
- **Export `export/web/`:** pck BARU **1.004.512 byte** sha256
  `3a972311296288cebe007458996291326dd16287631c5a1f21f89bf34463f7f5`
  (+432 dari ronde 15 — murni kode ronde 16); wasm TIDAK berubah
  (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…`); worklet ada (2.973 byte). Smoke pck via
  `--main-pack` 600 frame 0 error. File tes/foto dihapus sebelum
  export (pck bersih; `ls *.gd` root = 0). **TIDAK deploy** — deploy
  urusan Damar, DITAHAN sampai retest browser ronde 10+11+12+13+14
  selesai.

## 3. Jujur / belum sempurna

- **Foto 01 pertama gagal komposisi (bukan bug game):** skrip foto
  hanya menunggu Kyai pose — Bilal/Faris (rute lebih panjang) belum
  sampai saat foto diambil. Pelajaran: foto berjamaah harus menunggu
  KETIGA NPC pose + jendela qiyam bersama (ketiganya fmod(_sholat_t, 8)
  < 3,0 — siklus mereka bergeser ~1 dtk, jendela bersama ada tiap
  siklus).
- **Kamera pemain selalu menarget pemain** — dari belakang saf, Kyai
  (1,5 m di depan pemain) selalu tertutup sebagian badan pemain.
  Solusi foto: kamera bebas dari sisi mihrab (01b). Ini batasan
  kamera foto, bukan game — di game sungguhan pemain bisa mengorbit
  kamera sendiri.
- **Kyai belum bisa diajak bicara** — tidak ada sapaan/dialog khusus
  (warisan ronde 15). Interaksi (salam/salaman/dialog) ronde lanjutan.
- **Waktu sholat tetap** (bukan hisab dinamis) — warisan ronde 13.
- Portrait 390×844 belum teruji — perlu HP Mas (seperti biasa).

## 4. File yang diubah

- `scripts/main.gd` — konstanta baru `IMAM_JARAK_DEPAN` (1.5);
  `_posisi_imam()` (Sajadah_03 + arah kiblat × jarak, lookup runtime);
  `_mulai_sholat`: NPC diam (Kyai) ikut sebagai imam (rumah + posisi
  imam + fase ke_pintu + kalimat imam + rute ke pintu); komentar
  `_spawn_npcs` diperbarui (Kyai kini ikut sholat sebagai imam).
- `scripts/npc.gd` — hanya komentar `_diam` (mode diam diambil alih
  `_mode_sholat` saat sesi; `selesai_sholat()` mengembalikannya).

## 5. Handoff DEPLOY (Damar) — baca sebelum deploy

1. **JANGAN deploy dulu:** deploy ronde 15+16 DITAHAN sampai retest
   browser ronde 10+11+12+13+14 selesai (retest sedang jalan melawan
   build live ad5074ed). Deploy setelah retest selesai + laporan
   diterima.
2. Saat deploy: pck ronde 16 (`3a972311…`, 1.004.512 byte) — sudah
   mencakup karakter Kyai ronde 15 + imam ronde 16. Salin `index.pck`
   baru ke staging `export/web-pages/` (sha256 cocok), update
   GODOT_CONFIG `index.pck` di staging index.html 1001536 →
   **1004512**, lalu cek guard seperti biasa (3 `<script>` /
   3 `</script>`; `})();` → `</script>` → `<script src="index.js">`).
   Wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte, 5 chunk) — jangan
   sentuh chunk-nya. index.js TIDAK berubah (`33c94cb3…`). Worklet
   `index.audio.position.worklet.js` wajib ikut (2.973 byte).
3. Setelah deploy: retest browser untuk ronde 15+16 (Kyai di serambi +
   wajah close-up + berempat + Kyai jadi imam saat Dzuhur 12.00 +
   regresi sholat berjamaah) — atau gabung dengan retest berikutnya
   bila ada ronde 17. Lalu Mas tes di HP-nya (landscape).
