# RONDE 17 — Audio suasana pesantren (16 Nov ~08:52–09:10 WIB, Raka)

**Pemicu:** Mas 08:52 WIB *"biar ada suasana pesantren.. perlu ada
audio di gamenya.. seperti wirid-wirid, bacaan al-quran, baca nadzom
dll. Untuk diluar kegiatan maka kasih sound yg menenangkan.. seperti
bunyi burung dll."*

**Aturan:** sistem sholat/kiblat/mihrab/karakter ronde sebelumnya TIDAK
diubah; sistem 21 regu CCS TIDAK disentuh. **TIDAK deploy** — deploy
ditahan sampai retest browser ronde 10+11+12+13+14 selesai; deploy
berikutnya jadi ronde **15+16+17 SEKALI**.

## 1. Yang dibangun

**Manajer audio baru `scripts/audio_pesantren.gd`** (class
`AudioPesantren`, Node biasa — 2 player ambience crossfade + 1 player
kegiatan):
- **Ambience menurut jam perangkat** (selaras fase `langit_dinamis.gd`):
  04:00–10:00 kicau burung (subuh+pagi), 10:00–15:00 angin/daun
  (siang), 15:00–18:00 kicau burung (sore — kicau senja),
  18:00–04:00 jangkrik (malam). Crossfade halus 2,5 dtk saat fase
  berganti (dua AudioStreamPlayer bergantian; volume −16 dB).
- **Audio kegiatan (hook, hanya bila sesi berjalan + filenya ADA):**
  sesi sholat → `wirid.ogg`; sesi khataman kitab Amtsilah →
  `nadzom.ogg`; sesi khataman kitab lain (Jurumiyah/Safinatun Naja) →
  `quran_khataman.ogg`. Saat kegiatan berbunyi (−10 dB), ambience
  di-duck ke −30 dB; saat sesi habis, ambience kembali −16 dB.
- **Slot bacaan SENGAJA KOSONG.** `audio/wirid.ogg`,
  `audio/quran_khataman.ogg`, `audio/nadzom.ogg` TIDAK ADA di proyek.
  Bila file belum ada, sistem diam-diam tetap memainkan ambience
  (fallback, tanpa error, tanpa suara palsu — bacaan TIDAK PERNAH
  digenerate/dipalsukan). Cara mengisi: letakkan file `.ogg` dengan
  nama persis itu di `audio/` — tanpa ubah kode (lihat
  `audio/README.md`).
- **Tombol mute di HUD** (`ui.gd`): tombol teks "Suara"/"Senyap" di
  bar kanan-atas (setelah Aksi; teks saja — Baloo 2 tidak punya glif
  emoji, pelajaran ronde 7). Mute lewat bus Master; status tersimpan
  di save (`save_data.gd`: kunci baru `"suara_mati": false`) supaya
  bertahan antar sesi.
- **Autoplay web:** audio TIDAK mulai di `_ready` — `main.gd`
  memanggil `audio.mulai()` pada gestur pertama (`_input`: klik/
  sentuh/tombol; `_input` dipanggil SEBELUM kontrol GUI menelan
  event, jadi klik tombol login pun membuka audio). Bila sesi
  kegiatan sudah berjalan sebelum gestur pertama, bacaan baru
  diputar setelah `mulai()` (tidak ada suara sebelum gestur).
- Semua stream di-loop penuh (`AudioStreamOggVorbis.loop = true`
  di kode — import default `loop=false` ditimpa runtime, jadi
  re-import tidak merusaknya).

**Wiring `main.gd`:** `_perbarui_audio()` tiap frame (setelah
`_cek_waktu_sholat()`): sholat aktif → "wirid"; khataman aktif →
kitab Amtsilah "nadzom" / lainnya "khataman"; di luar itu "".
Kegiatan hanya saat dunia terlihat (layar login = tidak ada
kegiatan). `_on_suara_toggled()`: balik mute + simpan + label tombol.

## 2. File audio ambience (CC0 — sumber + lisensi di `audio/README.md`)

Dicari lewat Openverse (lisensi `cc0`), file dari Freesound (preview
HQ 128 kbps — cukup untuk ambience latar). Diolah ffmpeg: potong 40
dtk, loop mulus (4 dtk terakhir di-crossfade dengan 4 dtk pertama),
mono 22050 Hz, Vorbis q0, loudnorm −24 LUFS:

| File | Isi | Sumber | Durasi | Ukuran |
|---|---|---|---|---|
| `burung.ogg` | Kicau burung pagi + sedikit angin | Freesound 456766 (CC0) | 40 dtk | 163.097 byte |
| `angin.ogg` | Angin/daun (breeze) | Freesound 181801 (CC0) | 40 dtk | 171.840 byte |
| `jangkrik.ogg` | Jangkrik malam di hutan | Freesound 453862 (CC0) | 35,4 dtk | 152.379 byte |

Total audio: **487.316 byte**. (Percobaan q=−1 ternyata LEBIH BESAR
— 604.757 byte — dan q=1 di 192 kHz hasil loudnorm malah 1,1 MB;
q0 yang dipakai.)

**Dampak ukuran pck:** 1.004.512 → **1.541.540 byte (+537.028,
+53%)** — 487.316 byte di antaranya file Ogg; sisanya kode +
metadata import. Catatan jujur: pck membesar, TAPI total unduhan
game didominasi wasm 39,5 MB — tambahan ini hanya +1,3% dari total
unduhan (±40,5 MB → ±41 MB).

## 3. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error (peringatan UID duplicate export
  staging sudah ada sejak lama, bukan dari ronde ini).
- `--check-only`: `audio_pesantren.gd`, `main.gd`, `ui.gd`,
  `save_data.gd`, `mission_data.gd`, `langit_dinamis.gd` — semua lolos.
- **Tes headless `test_ronde17.gd`: 55 LOLOS / 0 GAGAL / 1 LEWAT,
  exit 0** — pemetaan jam→ambience 12 batas (03:59/04:00/09:59/
  10:00/14:59/15:00/17:59/18:00/21:00/00:00) + kitab→kegiatan 4 +
  save default `suara_mati=false` + regresi sholat 12:00 = Dzuhur +
  node audio (3 stream ada + loop, 2 slot kosong, mute bus Master,
  mulai() di 07:00 → burung −16 dB, crossfade 12:00 → angin −16 dB
  + pemain lama −40 dB, 21:00 → jangkrik −16 dB, fallback wirid/
  khataman kosong → kegiatan '' + ambience tetap −16 dB) +
  **kontrol positif** (wirid.ogg sementara dari salinan burung.ogg:
  kegiatan 'wirid' −10 dB + ambience di-duck −30 dB + kembali
  −16 dB saat sesi habis) + scene utama (node audio + UI ada,
  tombol "Suara" di HUD, gestur pertama → audio dimulai, login
  PV-0001 → dunia terlihat, sesi Dzuhur 12:00 aktif + ambience
  angin, tekan Suara → label "Senyap" + bus bisu + save
  `suara_mati=true`, tekan lagi → kembali) + smoke 600 frame (sesi
  Dzuhur aktif) selesai tanpa crash. 1 LEWAT = fallback wirid
  kosong (dilewat karena wirid.ogg sementara ADA saat itu — fallback
  tetap dibuktikan oleh khataman/nadzom). 3 gagal di run pertama
  adalah BUG TES (asersi fallback wirid tidak memperhitungkan file
  sementara yang ada — diperbaiki, bukan bug game). Save lokal
  di-backup + dikembalikan (terverifikasi: PV-0001 "Tes", 0 poin,
  `suara_mati=false`).
- **3 foto bukti** di `~/workspace/pesantren-verse/foto-ronde17/`
  (960×540, xvfb-run + opengl3, via `LangitDinamis.debug_jam`):
  - `01-suara-pagi.png` — pagi 08:00: langit biru pucat, lampu
    mati, tombol "Suara" di kanan-atas. ✓
  - `02-suara-malam.png` — malam 21:00: langit gelap + bintang,
    lampu jalan menyala, tombol "Suara". ✓
  - `03-senyap-pagi.png` — pagi 08:00 setelah tombol ditekan:
    label berubah "Senyap". ✓
- **Export `export/web/`:** pck BARU **1.541.540 byte** sha256
  `5357170dea5108fa473b7631ab88194513c41c8e6d1abed470c8a21ec0fe1d25`
  (+537.028 dari ronde 16); wasm TIDAK berubah (`fc74679e…`,
  39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`); worklet
  ada (2.973 byte). Smoke pck via `--main-pack` 30 detik: **0 SCRIPT
  ERROR**. File tes/foto + `audio/wirid.ogg` sementara (+ .import +
  cache `.godot`) dihapus sebelum export (pck bersih; `ls *.gd`
  root = 0; tidak ada sisa "wirid" di luar `audio_pesantren.gd`).
  **TIDAK deploy** — deploy urusan Damar, DITAHAN sampai retest
  browser ronde 10+11+12+13+14 selesai.

## 4. Jujur / belum sempurna

- **Bacaan kegiatan masih kosong (sesuai brief).** Isi slot menunggu
  keputusan Mas (rekam sendiri atau file berlisensi). Referensi yang
  sudah dikirim Zahra ke Mas (16 Nov ~08:57 WIB,
  `~/workspace/pesantren-verse/audio-referensi/`, ±1,9 MB):
  (1) **Al-Fatihah 47 dtk (Alafasy) — lisensi BERSIH non-komersial**
  (AlQuran Cloud: personal & edukasi; HARUS diganti kalau game jadi
  komersial) — kandidat pengisi `quran_khataman.ogg`, TAPI durasi
  47 dtk + player kegiatan me-loop → Al-Fatihah akan berulang selama
  sesi khataman 60 menit; rekaman lebih panjang lebih baik; file ini
  juga perlu di-downmix mono 22050 Hz dulu (saat ini 293 KB stereo).
  (2) Ratib al-Haddad 2 mnt — lisensi TIDAK JELAS, hanya untuk
  didengar. (3) Nadzom Ajurumiyyah 2 mnt — lisensi TIDAK JELAS +
  kualitas asli 16 kbps, hanya untuk didengar. Nadzom Aqidatul Awam /
  Imrithi berlisensi bebas tidak ketemu. Rekomendasi Zahra: jangka
  panjang paling aman **rekam sendiri** untuk wirid & nadzom.
- **Audio BELUM teruji di browser sungguhan.** Headless (driver
  Dummy) membuktikan logika + tidak ada error; bunyi nyata (mulai
  setelah gestur, crossfade, ducking) perlu retest browser + HP Mas.
  Satu baris `ERROR: Condition "status < 0" ... ERR_CANT_OPEN`
  muncul sekali di awal run xvfb (bukan SCRIPT ERROR; semua foto
  tersimpan; kemungkinan driver audio VM tanpa soundcard — bukan
  bug game; run headless + smoke pck bersih dari error apa pun).
- **Foto run pertama gagal (bug skrip foto, bukan game):** `_foto()`
  dipanggil tanpa `await` — coroutine jalan fire-and-forget, jadi
  foto 01/02 bergeser satu langkah (01 = langit malam, 02 = pagi +
  "Senyap") dan foto 03 tidak tersimpan karena `quit()` datang
  duluan. Pelajaran: coroutine foto HARUS di-`await`. Retake (run 2)
  sudah benar ketiganya.
- Ambience sore memakai burung (kicau senja); angin sore tidak
  dilapis terpisah — satu stream per fase (keputusan desain).
- Portrait 390×844 belum teruji — perlu HP Mas (seperti biasa);
  tombol Suara di bar kanan-atas menambah lebar bar (offset −452 →
  −544) — di portrait sempit, 5 tombol mungkin padat; perlu dilihat
  Mas di HP.

## 5. File yang diubah

- `scripts/audio_pesantren.gd` (BARU) — manajer audio: ambience per
  jam + crossfade + kegiatan + mute + autoplay-gate.
- `scripts/main.gd` — member `_audio`/`_audio_unlocked`; buat node
  audio di `_ready` + baca mute dari save; `_input` (gestur
  pertama → `mulai()`); `_perbarui_audio()` di `_process`;
  `_on_suara_toggled()`.
- `scripts/ui.gd` — sinyal `suara_toggled`; tombol "Suara" di HUD
  (offset bar −452 → −544); `set_suara_mati()`.
- `scripts/save_data.gd` — kunci baru `"suara_mati": false`.
- `audio/` (BARU) — `burung.ogg`, `angin.ogg`, `jangkrik.ogg` +
  `README.md` (sumber CC0 + slot bacaan kosong + referensi Zahra).

## 6. Handoff DEPLOY (Damar) — baca sebelum deploy

1. **JANGAN deploy dulu:** deploy ronde 15+16+17 DITAHAN sampai
   retest browser ronde 10+11+12+13+14 selesai (retest sedang jalan
   melawan build live ad5074ed). Deploy setelah retest selesai +
   laporan diterima — SEKALI untuk ketiganya.
2. Saat deploy: pck ronde 17 (`5357170d…`, 1.541.540 byte) — sudah
   mencakup Kyai ronde 15 + imam ronde 16 + audio ronde 17. Salin
   `index.pck` baru ke staging `export/web-pages/` (sha256 cocok),
   update GODOT_CONFIG `index.pck` di staging index.html 1004512 →
   **1541540**, lalu cek guard seperti biasa (3 `<script>` /
   3 `</script>`; `})();` → `</script>` → `<script src="index.js">`).
   Wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte, 5 chunk) —
   jangan sentuh chunk-nya. index.js TIDAK berubah (`33c94cb3…`).
   Worklet `index.audio.position.worklet.js` wajib ikut (2.973 byte).
3. Setelah deploy: retest browser untuk ronde 15+16+17 (Kyai di
   serambi + jadi imam saat Dzuhur 12.00 + **audio: bunyi setelah
   klik pertama, ambience pagi = burung, tombol Suara → Senyap +
   tidak ada suara, kembali → bunyi lagi** + regresi sholat
   berjamaah) — atau gabung dengan retest berikutnya. Lalu Mas tes
   di HP-nya (landscape) — terutama: apakah ambience terdengar di
   HP + apakah tombol Suara muat di portrait.
