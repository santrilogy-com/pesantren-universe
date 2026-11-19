# SFX Sinkron — Status (Sinta, 17 Nov 2026)

Acuan: reel @jipraks (https://www.instagram.com/reel/Dfwu_24k-8a/ —
studi di `~/workspace/pesantren-verse/riset-dunia-virtual/REEL-jipraks-STUDY.md`),
perbaikan #5: **efek suara sinkron tepat di momennya** (langkah kaki,
cangkir, kasir). Di game: langkah kaki + buka/tutup pintu.

## SFX yang sudah terpasang (semua CC0, terverifikasi di halaman sumber)

Format semua file: Ogg Vorbis mono 22050 Hz, dinormalisasi −20 LUFS
(seperti ambience — lihat `audio/README.md`). Total 9 file, ±50 KB.

| File | Isi | Sumber | Lisensi | Durasi | Volume |
|---|---|---|---|---|---|
| `audio/langkah_tanah_1.ogg` | Langkah di tanah/rumput (kaki kiri 1) | Fantozzi's Footsteps (Grass/Sand & Stone), Fantozzi — https://opengameart.org/content/fantozzis-footsteps-grasssand-stone (file `Fantozzi-SandL1.ogg` dari `Fantozzi-footsteps.7z`) | CC0 | 0,44 dtk | −14 dB |
| `audio/langkah_tanah_2.ogg` | Langkah di tanah/rumput (kaki kiri 2) | Sama, `Fantozzi-SandL2.ogg` | CC0 | 0,32 dtk | −14 dB |
| `audio/langkah_tanah_3.ogg` | Langkah di tanah/rumput (kaki kanan 1) | Sama, `Fantozzi-SandR1.ogg` | CC0 | 0,41 dtk | −14 dB |
| `audio/langkah_lantai_1.ogg` | Langkah di lantai kayu 1 | Different steps on wood, stone, leaves, gravel and mud, TinyWorlds — https://opengameart.org/content/different-steps-on-wood-stone-leaves-gravel-and-mud (file `wood01.ogg` dari `[kdd]DifferentSteps.zip`) | CC0 | 0,24 dtk | −14 dB |
| `audio/langkah_lantai_2.ogg` | Langkah di lantai kayu 2 | Sama, `wood02.ogg` | CC0 | 0,24 dtk | −14 dB |
| `audio/langkah_lantai_3.ogg` | Langkah di lantai kayu 3 | Sama, `wood03.ogg` | CC0 | 0,32 dtk | −14 dB |
| `audio/pintu_buka.ogg` | Pintu kayu dibuka | 100 CC0 SFX, rubberduck — https://opengameart.org/content/100-cc0-sfx (file `door_open.ogg`; deskripsi paket: "1x wooden door open") | CC0 | 0,45 dtk | −10 dB |
| `audio/pintu_tutup.ogg` | Pintu kayu ditutup | Sama, `door_close_01.ogg` (deskripsi paket: "4x door close") | CC0 | 0,50 dtk | −10 dB |
| `audio/klik.ogg` | Klik tombol/panel | Sama, `switch_01.ogg` | CC0 | 0,23 dtk | −16 dB |

Catatan sumber: halaman OpenGameArt masing-masing menampilkan
"License(s): CC0" — diverifikasi Sinta 17 Nov 2026 sebelum unduh.
"Pasir" Fantozzi "sounds like grass too" (deskripsi halaman) — cocok
untuk tanah/rumput pesantren. Atribusi tidak wajib (CC0), tapi sumber
dicatat di sini + `audio/README.md` seperti ambience.

## Momen sinkron (kapan tiap SFX bunyi)

- **Langkah kaki** — `scripts/player.gd`: signal `langkah`
  dipancarkan tiap kali satu kaki menyentuh tanah, yaitu saat
  `sin(_walk_time)` melewati nol (kaki lewat posisi vertikal, kaki
  satunya terangkat). Bukan loop asal-asalan: bunyi terikat fase
  ayunan jalan (laju fase 9,0 rad/dtk → 1 langkah tiap ±0,35 dtk
  saat jalan penuh). Blend < 0,3 tidak berbunyi (langkah pertama
  yang masih pelan tidak bersuara). `scripts/main.gd` menyambung
  signal ke `AudioPesantren.mainkan_langkah()` (`_saat_langkah()`).
  - **Permukaan dipilih dari posisi**: di dalam Surau / Musholla /
    Cangkruk → varian lantai kayu; di luar → varian tanah/rumput.
  - **Anti mesin**: tiap langkah dipilih acak dari 3 variasi +
    pitch acak 0,95–1,05, jadi tidak terdengar berulang.
  - Catatan paralel: refactor jalan ke modul `AnimasiMixamo`
    (agen lain, ronde ini) TIDAK mengubah fase — komentar modul
    menegaskan kontak kaki tetap di fase ≡ 0 (mod π), persis
    deteksi di atas. Emit Sinta tetap di tempatnya.
- **Pintu** — `scripts/main.gd`, satu baris pemicu per momen:
  `_masuk_surau` / `_masuk_musholla` / `_masuk_cangkruk` →
  `mainkan_pintu(true)` (buka); `_keluar_surau` /
  `_keluar_musholla` / `_keluar_cangkruk` → `mainkan_pintu(false)`
  (tutup). Pintu di game adalah teleport lewat koridor pintu, jadi
  momen buka/tutup = momen teleport itu — bunyi tepat saat pemain
  melangkah masuk/keluar.
- **Klik** — file + fungsi `mainkan_klik()` SUDAH ADA, tapi
  **pemicu BELUM dipasang**: tombol/panel hidup di `ui.gd`, di luar
  batas file ronde ini (hanya `player.gd`/`main.gd`). Tinggal satu
  baris `mainkan_klik()` di handler tombol saat ronde UI berikutnya.

## Aturan yang dihormati

- **Autoplay web**: SFX diam sebelum gestur pertama (`_dimulai`
  false) — sama seperti ambience/adzan. Di headless, tes memanggil
  `mulai()` manual.
- **Tombol Suara/Senyap tetap jalan**: SFX lewat bus Master, jadi
  mute membisukan semuanya tanpa kode tambahan.
- **File boleh hilang**: bila satu file SFX tidak ada,
  `mainkan_*` diam + peringatan di log — game TIDAK error.
- **Slot wirid/quran/nadzom/adzan TIDAK disentuh** — tetap kosong
  menunggu rekaman bersih (aturan yang sama seperti sebelumnya).

## Hasil tes (headless, 17 Nov 2026 ~24:00 WIB)

`godot --headless --path . skrip/test_v2.tscn` — **42 lulus, 2 gagal**
(total 44 cek; sebelumnya 23 cek — file tes ikut ditambah agen lain
untuk gubuk + tangga). 6/6 cek SFX LULUS:

- SFX langkah bunyi saat jalan (dapat 4 langkah dalam jalan 9,40 m)
- SFX langkah luar = tanah (varian benar di luar ruangan)
- SFX pintu buka saat masuk Surau (dapat 1)
- SFX pintu tutup saat keluar Surau (dapat 2)
- SFX langkah lantai (API langsung — varian lantai + penanda benar)
- SFX klik (API langsung)
- **0 error audio** di log (tidak ada `[SFX] ... hilang`, tidak ada
  SCRIPT ERROR; satu-satunya WARNING di log adalah soal owner
  Gubuk — pekerjaan agen lain, bukan audio).

**2 GAGAL bukan SFX — milik TanggaSurau (agen lain, masih jalan):**
"Naik tangga tanpa macet (macet=46)" dan "Sampai serambi + masuk
pintu (di_dalam)". Bukan regresi SFX: semua 23 cek lama tetap lulus
+ 6 cek SFX baru lulus.

Catatan jalan tes: dua kali jalan pertama gagal BUKAN karena SFX —
(1) `var l0 :=` tidak bisa infer tipe (diperbaiki jadi `var l0: int`);
(2) race dengan agen paralel: `scripts/tangga_surau.gd` masih ditulis
saat tes jalan (`TanggaSurau` belum terdaftar) — jalan ulang setelah
file selesai langsung lulus.

## Yang BELUM (dicatat, bukan dipasang yang meragukan)

- **Suara duduk** (duduk bersila di Surau/Musholla): TIDAK KETEMU
  yang bersih. Dicek: isi ketiga paket di atas (Fantozzi 12 file,
  TinyWorlds 8 file, 100 CC0 SFX ±100 file) — tidak ada satu pun
  suara duduk/geser kain duduk. Freesound tidak dicoba unduh (butuh
  login; OpenGameArt sudah memenuhi semua kebutuhan ronde ini).
  Opsi ke depan: rekam sendiri (geser sarung di lantai) atau cari
  khusus di Freesound dengan filter CC0 + verifikasi per-file.
- **Klik panel**: file + fungsi siap (lihat di atas) — pemicu di
  `ui.gd` menunggu ronde berikutnya.
- **Gerbang (14,0)**: TIDAK ada SFX — gerbang TERTUTUP permanen
  (barrier, Ronde 21), tidak ada momen buka/tutup. Yang ada hanya
  toast + dorong balik saat pemain menabrak tembok; itu bukan momen
  pintu.
- **Adzan / wirid / quran / nadzom**: tetap BELUM (lihat
  `audio/README.md` + `FITUR-ADZAN-STATUS.md`) — bukan bagian ronde
  ini.

## File yang diubah ronde ini

- `audio/` (baru): 9 file `.ogg` di atas.
- `scripts/audio_pesantren.gd`: konstanta `PATH_SFX_*`, volume
  `DB_LANGKAH/DB_PINTU/DB_KLIK`, 3 player SFX, pemuatan stream,
  `mainkan_langkah(di_lantai)` / `mainkan_pintu(membuka)` /
  `mainkan_klik()` + penghitung `langkah_jumlah()` /
  `pintu_jumlah()` / `klik_jumlah()` / `langkah_lantai_terakhir()`.
- `scripts/player.gd`: signal `langkah` + deteksi persilangan nol
  `sin(_walk_time)` di cabang jalan (+ var `_langkah_sin_sebelum`).
- `scripts/main.gd`: sambung `_player.langkah` → `_saat_langkah()`
  (pilih lantai/tanah dari `_di_dalam*`) + 6 baris pemicu pintu.
- `skrip/test_v2.gd`: `mulai()` manual + jalan 120 frame (bukan 30,
  supaya fase jalan pasti melewati nol) + 6 cek SFX baru.
- Dokumen: file ini + seksi SFX di `audio/README.md`.
- v1 TIDAK disentuh. TIDAK ada export/deploy.
