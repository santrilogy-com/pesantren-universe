# CATATAN — Pesantren Universe (Godot 4.3)

> Proyek BARU di `~/workspace/pesantren-verse/godot-dunia/`, terpisah dari
> proyek CCS `game-nahwu`. **Tidak ada satu pun file CCS yang diubah.**
> Dibangun headless di VM oleh Raka, 15 Nov 2026. Fase 1 (MVP).

## Keputusan Mas yang diterapkan

1. **Arsitektur (15 Nov ~09:05 WIB):** daftar lewat app web (Kartu Santri +
   ID Santri) → masuk game Godot ini. Kelas, misi, ngaji, Ma'hadiyah, chat,
   dan dashboard santri semuanya **DI DALAM game 3D ini**, bukan di app
   terpisah. App hanya pintu masuk.
2. **Mulai dari surau kecil (15 Nov ~09:08 WIB):** pesantren dirintis dari
   nol banget — Surau kecil sebagai fondasi Fase 1. Pesantren membesar
   mengikuti jumlah santri: Ruang Kelas, Asrama, Masjid Besar,
   Perpustakaan & Taman. Lahan bangunan berikutnya sudah disiapkan di
   halaman sebagai plot bertanda (terkunci).
3. **Bahasa (15 Nov ~09:09 WIB):** jangan pakai istilah "dunia" — pakainya
   **"pesantren"**. Semua label/teks di game ini memakai "pesantren"
   ("Masuk Pesantren", "Pertumbuhan pesantren", dst). Catatan: nama folder
   teknis `godot-dunia` berasal dari perintah awal dan hanya path folder,
   bukan teks yang terlihat di game.
4. **Chat ganti mic:** kalau mic belum bisa di Godot, pakai chat — pesan
   muncul sebagai bubble di atas karakter.
5. **Dashboard di dalam game** (keputusan Mas, terjawab dari koreksi
   arsitektur): Kartu Santri ada di dalam game, bukan di app.

## Yang sudah jalan (Fase 1)

- **Pesantren 3D low-poly, 1 zona:** Surau kecil yang bisa dimasuki
  (pintu, sajadah, mihrab, papan tulis, rak kitab, kubah emas, menara
  kecil), jalan pasir, pohon, lampu, pagar hidup, papan selamat datang,
  langit + matahari + bayangan. Palet zamrud + pasir + emas.
- **4 plot pertumbuhan bertanda:** Ruang Kelas, Asrama, Masjid Besar,
  Perpustakaan & Taman — masing-masing dengan papan "Dibuka saat N santri".
  Ambang santri **DISETUJUI Mas 15 Nov ~11:37 WIB: Ruang Kelas 25, Asrama 50, Masjid Besar 100, Perpustakaan & Taman 200**.
- **Karakter santri third-person:** peci, koko putih kancing emas, sarung
  zamrud, animasi jalan prosedural (ayunan lengan/kaki + bob). Gerak:
  joystick virtual (HP) + WASD/panah (keyboard). Kamera mengikuti +
  orbit dengan drag.
- **Layar masuk:** ID Santri `PV-XXXX` + nama + jalur (Misi / Ngaji Aja).
  Sesi tersimpan lokal (`user://santri.json`); kalau ID sama, progres
  dilanjutkan; kalau ID baru, mulai dari nol.
- **Chat bubble:** ketik pesan → bubble muncul di atas karaktermu (5 detik)
  + masuk log chat. 2 NPC santri (Bilal, Faris) berjalan-jalan di halaman
  dan sesekali mengucapkan kalimat sebagai bubble.
- **Misi Nahwu (rantai M1 → M2 → M3, berurutan, tidak bisa dilompati):**
  M1 Kenalan dengan Nahwu (materi + kuis, +10), M2 I'rab Marfu' (harus di
  dalam surau, +15), M3 Buka Peti Kayu (kuis, +25, tutup peti terbuka
  dengan animasi). Jawaban salah tidak dapat poin, boleh coba lagi.
  Poin + progres tersimpan lokal.
- **Dashboard Kartu Santri (di dalam game):** ID, nama, jalur, tier
  (Santri Baru → Penjelajah → Pembuka Peti → Penjaga Lentera), poin,
  misi x/3, streak Ma'hadiyah, checklist Ma'hadiyah harian (7 kegiatan:
  tahajjud, Subuh berjamaah, dzikir pagi, dhuha, tilawah, lima waktu
  berjamaah, dzikir petang), jadwal Ngaji Aja + tombol hadir,
  daftar pertumbuhan pesantren.
- **Jalur Ngaji Aja:** santri jalur ini tidak bisa mengerjakan misi
  (sesuai model 2 jalur + perilaku app web) — penanda misi menampilkan
  "JALUR MISI" dan interaksi memberi penjelasan. Kelas Ngaji Aja
  (bandongan/sorogan) untuk sementara diadakan di surau, sampai Ruang
  Kelas (Tahap 1) dibangun.
- **Export Web HTML5:** `export/web/` total 35 MB (index.wasm 34 MB
  no-threads, index.pck 58 KB). Tanpa threads = TIDAK butuh header
  COOP/COEP, jalan di hosting statis biasa.

## Verifikasi (angka, bukan klaim)

| Tes | Hasil |
|---|---|
| `--import` | exit 0, 0 error |
| `--check-only` semua 9 script | lolos semua |
| Smoke test headless 600 frame | exit 0, **0 SCRIPT ERROR** |
| Tes logika headless (28 cek) | **28/28 LOLOS** — validasi ID, tier, rantai misi terkunci, kuis salah/benar, poin 10+15+25=50, peti terbuka, posisi surau, blokir jalur Ngaji Aja, Ma'hadiyah, hadir ngaji, chat |
| Export Web `--export-release` | exit 0 |
| Tes HTTP lokal (127.0.0.1:8941) | semua file 200; wasm GET penuh sha256 **cocok** dengan file asli |
| Boot di browser headless VM | **TIDAK BISA DITES** — Chromium sistem menolak start: "Hatch WebGL domain policy is required for browser startup" (exit 13, batasan yang sama seperti Remotion). Boot sungguhan harus dites di browser beneran / HP Mas begitu link dibuat. |

## Perbaikan cacat teks raksasa (15 Nov ~10:52 WIB, Raka)

**Gejala (tes boot browser beneran, 1920×1080):** setelah login berhasil,
~85% layar tertutup teks raksasa hijau-putih-abu yang tumpang-tindih
("PESANTREN VERSE", "Tes", dll), persisten; dunia 3D hanya tampak di strip
bawah. HUD normal.

**Penyebab (bukan overlay login):** `Palette.label3d()` di
`scripts/palette.gd` memakai `fixed_size = true` + `pixel_size = 0.01` +
`no_depth_test = true` untuk SEMUA Label3D (19 label: papan selamat datang,
papan plot, papan misi, penanda "!", nama pemain/NPC, bubble chat).
`fixed_size` diimplementasikan di shader material (bukan skala node — makanya
AABB/skala tampak normal), membuat label tampil dengan ukuran layar konstan
yang sangat besar, dan `no_depth_test` menggambarnya menembus semua geometri.
Panel login (hijau penuh layar) menutupi cacat ini sebelum login — makanya
tampak seperti overlay login yang gagal hilang. Terukur headless: label
papan "PESANTREN VERSE" memproyeksikan 572×141 px di viewport 64×64
(2,2× tinggi viewport).

**Perbaikan:**
- `scripts/palette.gd` `label3d()`: `fixed_size = false`,
  `no_depth_test = false` (+ komentar larangan supaya tidak dihidupkan lagi).
  Label kini teks 3D biasa: ukuran mengikuti jarak (perspektif) dan tertutup
  geometri seperti objek lain.
- `scripts/pesantren_builder.gd`: papan selamat datang + papan plot + papan
  misi font 36/32 → 24 (dan papan dilebarkan supaya teks muat di papan);
  penanda "!" font 96 → 64.
- `scripts/player.gd`: nama santri font 42 → 32; bubble chat font 40 → 28
  + `autowrap` (lebar 300 font-px) supaya pesan panjang tidak jadi satu
  baris raksasa — 300 dipilih agar bubble muat di HP portrait (FOV
  horizontal sempit).

**Verifikasi ukuran label (proyeksi perspektif manual, fov 60):**
| Tampilan | Label terbesar | Ukuran |
|---|---|---|
| Spawn, 1920×1080 | bubble chat pemain (pesan 60 karakter) | 381×159 px (20% × 15% layar) |
| Spawn, 1920×1080 | papan "PESANTREN VERSE" | 325×80 px (17% × 7%) |
| Spawn, 390×844 (HP portrait) | bubble chat pemain | 298×124 px (76% × 15% — muat) |
| Spawn, 390×844 | papan "PESANTREN VERSE" | 254×62 px (65% × 7% — muat) |
| Dekat papan (1,6 m), 390×844 | papan "PESANTREN VERSE" | 337×81 px (86% × 10% — wajar, berdiri di depan papan) |
| Semua label lain | nama, penanda, papan plot | ≤ 12% dimensi layar |

**Verifikasi (angka, bukan klaim):** `--import` exit 0; `--check-only`
9/9 script lolos; smoke test headless 600 frame: **11/11 cek LOLOS**
(login + HUD, tagline, guard regresi fixed_size/no_depth_test, M1 salah
0 poin → benar +10, M2 +15, M3 +25 + peti terbuka, chat bubble,
dashboard), poin akhir 50, **0 SCRIPT ERROR**; export ulang
`--export-release "Web"` exit 0 (pck baru 96.848 byte, sha256
`29655435…7960a`); HTTP lokal semua file 200, wasm sha256 cocok
(`fe5cebc5…028b9`).

**Typo tagline:** source sudah tertulis benar "Merangkak dari surau kecil"
(`scripts/ui.gd:138`) — kemungkinan salah baca saat teks raksasa menumpuk,
atau build lama. Export ulang ini menjamin build live sama dengan source.

**Belum teruji:** boot di browser beneran / HP (tidak bisa dari VM —
Chromium menolak WebGL). Itu urusan tes deploy berikutnya, bukan bagian
perbaikan ini.

## Batasan yang jujur

1. **Bukan multiplayer.** NPC Bilal dan Faris adalah karakter buatan
   (bot lokal), bukan pemain sungguhan. Chat hanya tampil lokal di
   perangkatmu. Multiplayer antar pemain butuh server (WebSocket/LiveKit)
   — itu fase berikutnya, belum dibangun.
2. **ID Santri belum terverifikasi server.** Login hanya mengecek format
   `PV-XXXX`; UI menyatakan ini apa adanya ("verifikasi ke server
   menyusul — mode lokal"). Poin/progres tersimpan lokal dulu; struktur
   data (`SantriSave`) sengaja dibuat 1:1 dengan yang akan dikirim ke
   server app nanti, jadi tinggal sambung.
3. **Belum ada video materi.** Langkah "nonton video" di misi belum ada
   di Fase 1 (materi berupa teks). Video di dalam Godot web juga
   bermasalah secara teknis (lihat riset CCS) — materi video kemungkinan
   dibuka lewat app di samping game.
4. **Belum ada suara/partikel.** Game saat ini bisu. Belum ada efek
   partikel saat misi selesai / peti terbuka (hanya animasi tutup peti).
5. **Belum dites main dari HP.** Yang terverifikasi: export + file tersaji
   + logika jalan. Apakah joystick sentuh terasa enak dan tampilan pas
   di layar HP — baru ketahuan saat dibuka dari HP.
6. **Belum di-deploy.** TIDAK ada link publik — sesuai perintah, link baru
   dibuat nanti atas keputusan Mas. Catatan deploy: `index.wasm` 34 MB
   **melebihi batas 25 MiB/file Cloudflare Pages** — saat deploy nanti
   pakai pola yang sama seperti CCS: potong wasm jadi 4 chunk ~8,4 MB +
   patch fetch di `index.html` (lihat `game-nahwu/.../export/WEB-EXPORT.md`
   §5 — dibaca saja, tidak diubah).
7. **Aset dari primitif, bukan model 3D impor.** Surau, karakter, dan
   dekor dibangun dari primitif Godot yang dirapikan (bukan placeholder
   mentah, tapi juga bukan model 3D berlisensi). Walk-cycle hanya
   ayunan prosedural, belum animasi tulang.
8. **Ambang pertumbuhan disetujui Mas (15 Nov ~11:37 WIB).** Angka
   25/50/100/200 santri untuk membuka bangunan berikutnya sudah final:
   Ruang Kelas 25, Asrama 50, Masjid Besar 100, Perpustakaan & Taman 200.
9. **Kelas di surau.** Sampai Ruang Kelas dibangun (Tahap 1), kelas
   Nahwu dan Ngaji Aja diadakan di dalam surau.

## Struktur file

```
~/workspace/pesantren-verse/godot-dunia/
  project.godot            # Pesantren Universe, gl_compatibility, 1280x720 landscape
  export_presets.cfg       # Web, no-threads (tanpa COOP/COEP)
  icon.svg                 # ikon surau zamrud/emas
  main.tscn                # root -> scripts/main.gd
  CATATAN.md               # file ini
  export/web/              # hasil export (index.html/js/wasm/pck, 35 MB)
  scripts/
    main.gd                # orkestrator: login, kamera, misi, chat, dashboard
    pesantren_builder.gd   # membangun surau + plot + peti + dekor + penanda
    player.gd              # santri pemain (CharacterBody3D + visual + animasi)
    npc.gd                 # santri NPC yang berkeliling + bubble
    virtual_joystick.gd    # joystick virtual (pola CCS, ditulis ulang)
    ui.gd                  # semua UI: login, HUD, panel misi, dashboard, chat
    palette.gd             # palet zamrud/pasir/emas + helper primitif
    mission_data.gd        # data misi Nahwu, Ma'hadiyah, jadwal ngaji, tahap tumbuh
    save_data.gd           # simpanan lokal + validasi ID + tier + streak
```

## Langkah berikutnya (usulan, belum diputuskan)

- Fase 2: rantai misi mapel lain (Fiqih, Sejarah, Adab) + peti
  Perunggu/Emas; ambang pertumbuhan SUDAH diputuskan Mas 15 Nov ~11:37 WIB
  (25/50/100/200); bangunan Tahap 1 (Ruang Kelas) saat santri mencapai ambang.
- Server: verifikasi ID Santri + sinkronisasi poin/progres ke server app;
  multiplayer/chat antar pemain sungguhan; suara (LiveKit butuh token
  server — sama seperti catatan app).
- Deploy: link baru (Cloudflare Pages, pola chunked wasm CCS) + tes
  sungguhan dari HP Mas.

## Perbaikan login HP + daftar baru (15 Nov ~11:26 WIB, Raka)

Mas mencoba dari HP: (1) kolom login tidak bisa diisi, (2) tidak ada
halaman daftar, (3) form kekecilan di HP portrait.

### Masalah 1 — kolom tidak bisa diisi (penyebab + perbaikan)
**Penyebab:** `export_presets.cfg` punya `html/experimental_virtual_keyboard=false`
(default Godot). Tanpa flag ini, LineEdit di web mobile dapat fokus tapi
keyboard virtual tidak pernah muncul — ketikan tidak masuk. Gejala persis
yang didokumentasikan komunitas Godot ("can't type on phone, works with
hardware keyboard"). Faktor kedua: shell HTML default memakai viewport
`user-scalable=no`, yang membuat iOS Safari menolak memunculkan keyboard.
**Perbaikan:**
- `export_presets.cfg`: `html/experimental_virtual_keyboard=true`, dan
  `html/head_include` diisi meta viewport `user-scalable=yes` (meta kedua,
  sesudah default — yang terakhir yang menang).
- `scripts/ui.gd` `_minta_keyboard()`: tiap LineEdit (login, daftar, chat)
  memanggil `DisplayServer.virtual_keyboard_show("")` di `focus_entered`
  (sinkron di dalam gesture ketuk).
- Terverifikasi di `export/web/index.html` hasil export: ada
  `"experimentalVK":true` dan meta viewport kedua `user-scalable=yes`.

### Masalah 2 — alur daftar baru di dalam game
- Layar masuk kini punya dua kotak: MASUK (ID + nama) dan DAFTAR (nama +
  jalur). Tombol "Belum punya ID Santri? Daftar baru" / "Sudah punya ID?
  Masuk di sini" mengalihkan keduanya; `show_login()` selalu kembali ke
  mode masuk.
- `scripts/save_data.gd`: data simpan punya `id_terakhir` (counter nomor
  ID lokal). `terbitkan_id_baru(data)` menerbitkan nomor berikutnya setelah
  nomor tertinggi yang dikenal perangkat (termasuk ID yang pernah dipakai
  login, via `catat_id()`), mis. setelah PV-0007 -> PV-0008. `main.gd`
  `_on_register()` memakai itu, menyimpan, lalu langsung masuk dengan
  pesan "ID Santrimu: PV-XXXX — simpan baik-baik ya."
- UI tetap jujur: "ID diterbitkan otomatis dan disimpan di perangkat ini.
  Verifikasi ke server menyusul (mode lokal)."
- `_on_login()` juga menjaga counter (login dengan ID app yang lebih besar
  menaikkan counter supaya daftar berikutnya tidak bertabrakan).

### Masalah 3 — form kekecilan di HP portrait
**Penyebab:** viewport dasar 1280x720 landscape + stretch `canvas_items` /
`expand`: di HP 390x844 skala stretch ~0,305, jadi field 360x44 piksel
logis hanya ~110x13 piksel di layar — nyaris tidak bisa diketuk.
**Perbaikan:** `PesantrenUI.login_metrics(scale, lebar_viewport)` (fungsi
murni) menghitung ukuran dari skala stretch: target fisik field 56 px,
tombol 64 px, font field 20 px, judul 40 px, lebar form ~340 px
(~87% lebar HP); di desktop nilainya kembali ke ukuran desain (360 px).
`_layout_login()` menerapkannya ke kotak masuk + daftar dan dipanggil
lagi tiap `size_changed`. Skala dijepit 0,2–3,0 supaya jendela super-kecil
tidak menghasilkan font ribuan piksel.

### Ambang buka bangunan — DISETUJUI Mas 15 Nov ~11:37 WIB
Ruang Kelas 25, Asrama 50, Masjid Besar 100, Perpustakaan & Taman 200
santri. Angka ini SUDAH ada di `MissionData.GROWTH_STAGES` (dulu usulan
Raka) — yang diubah: keterangan "masih usulan" di `mission_data.gd`,
`pesantren_builder.gd`, catatan dashboard di `ui.gd`, dan file ini.
Papan tanda plot (`"Dibuka saat N santri"`) dan daftar pertumbuhan di
dashboard membaca angka dari data yang sama, jadi kini menampilkan angka
resmi tersebut.

### Verifikasi ronde ini
- `--import` exit 0, 0 error; `--check-only` 9/9 script lolos.
- Tes headless `test_daftar.gd` (dihapus setelah jalan): **45/45 cek
  LOLOS** — penerbitan ID berurutan (PV-0001, PV-0002, lanjut setelah
  PV-0010 -> PV-0011), migrasi save lama (PV-0007 -> PV-0008), roundtrip
  simpan-muat, metrik layout HP (0,305) + desktop (1,5) + scale 0,
  alur UI daftar (tolak nama 1 huruf, sinyal terbit benar, kembali ke
  masuk, login lama tetap jalan), ambang 25/50/100/200.
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR**.
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`:
  pck baru 102.704 byte (sha256 `4f77a35f…1ee19f78`), wasm TIDAK berubah
  (`fe5cebc5…028b9`). File tes dihapus; save lokal dikembalikan seperti
  semula (PV-0007, "Uji", 50 poin).
- **Belum teruji:** ketik sungguhan di keyboard HP + tampil form di HP
  beneran (tidak bisa dari VM — Chromium sistem menolak WebGL).
  Perlu tes dari HP Mas setelah deploy ulang.

## Layar hitam total — deploy 6e4e9d6a (11:41 WIB) — PENYEBAB KETEMU + DIPERBAIKI (Raka, 15 Nov ~11:52 WIB)
**Gejala:** game hitam total di HP Mas dan di browser pengujian (tanpa splash/loading/login/pesan error).
**Penyebab PASTI (bukan export, bukan browser):** `export/web-pages/index.html` hasil staging kehilangan tag penutup `</script>` blok patch fetch wasm. Buktinya: `<script` 3x vs `</script>` 2x (file lama yang jalan: 3x/3x). Akibatnya parser HTML menelan `<script src="index.js">` sebagai TEKS di dalam blok patch -> blok patch gagal parse (SyntaxError) -> `index.js` tidak pernah dimuat -> `Engine` undefined -> `new Engine(GODOT_CONFIG)` throw sebelum `setStatusMode('progress')` -> overlay status tetap hidden, canvas hitam, tanpa pesan apa pun di layar. Mekanisme ini cocok persis dengan gejala (hitam total, tanpa splash).
**Yang dibuktikan BUKAN penyebab:** wasm byte-identik dengan deploy lama yang jalan (sha256 fe5cebc5...028b9, dari chunk live); index.js byte-identik (8b649683...); pck baru valid (`--main-pack` headless 600 frame, exit 0, 0 SCRIPT ERROR); experimentalVK hanya diteruskan ke `GodotConfig.virtual_keyboard`, kode VK-nya (`GodotDisplayVK`) benign dan tidak jalan saat boot; meta viewport tidak berpengaruh ke JS; browser sehat (deploy lama tampil normal di browser yang sama 11:47 WIB).
**Perbaikan:** satu baris — tambah `</script>` sesudah `})();` blok patch di `export/web-pages/index.html` (sebelum `<script src="index.js">`). Tidak ada re-export (export/web sudah benar), tidak ada perubahan kode game.
**Verifikasi perbaikan:** parser HTML kini melihat 3 elemen script (patch 1447 karakter, src index.js, config+boot 3095 karakter) — identik dengan file lama yang jalan; diff staging-vs-live-lama hanya 2 perbedaan yang disengaja (meta viewport + GODOT_CONFIG experimentalVK/pck); wasm rakitan staging sha256 cocok; pck staging cocok. **Staging siap deploy ulang (Damar) — live saat ini (6e4e9d6a) MASIH file rusak.**
**Pelajaran / guard ke depan:** setiap staging WAJIB dicek keseimbangan tag script (`grep -c` open vs close harus sama) dan diff vs deploy lama yang jalan sebelum deploy. Hash file saja tidak menangkap kerusakan struktur HTML.

## Ronde perbaikan 5 masalah HP (15 Nov ~12:00 WIB, Raka)
Mas mengetes dari HP (game sudah jalan setelah layar hitam beres) dan menemukan 5 masalah. Semua diperbaiki di ronde ini.

### 1. Form kurang modern — tampilan baru
Form Masuk/Daftar dulu teks putih langsung di atas hijau polos. Sekarang: **kartu krem** (`PanelContainer`, radius 20, border emas 2px, bayangan halus) di atas latar zamrud; judul hijau zamrud + **pembatas emas** di bawah judul; field putih bersudut membulat (radius 12, border abu-hijau; saat fokus border zamrud + latar hijau muda); tombol emas utama berteks **gelap** (lebih terbaca); teks error merah gelap + catatan abu-hijau (terbaca di kartu krem, dulu merah muda/pucat di atas hijau). Panel misi/dashboard ikut membulat (radius 10 -> 14), tombol radius 8 -> 12 + bayangan halus. **Logika login/daftar/ID tidak diubah**; ukuran besar tetap (field 56px, tombol 64px).

### 2. Karakter jelek — model santri baru (meniru hero CCS)
Referensi: `game-nahwu/.../assets/hero/hero_santri.png` + `make_hero_santri.py` (peci putih, koko putih kancing emas, sarung zamrud kotak putih, sandal coklat). Perubahan di `player.gd build_visual()` (dipakai pemain + NPC): kepala lebih kecil + **mata gelap + senyum tipis** (ala hero CCS), **peci putih lebih tinggi** + lis bawah, koko bertaper + **kerah + lis dada + 4 kancing emas**, lengan lebih ramping + **tangan kulit** di ujungnya, **sarung kotak putih** (12 kotak depan-belakang, kamera third-person paling sering melihat punggung), **sandal coklat menempel di pivot kaki** (ikut mengayun, bukan diam). Animasi jalan dihaluskan: amplitudo naik/turun bertahap (blend) + badan sedikit condong ke depan + bob lebih kecil. Kontrol (joystick/WASD) dan kamera tidak diubah.
**Bonus temuan:** kapsul collision pemain dulu tinggi 1,2 berpusat y=0,95 — alas kapsul 0,35 DI ATAS origin, jadi pemain **tenggelam 0,35 m ke dalam tanah** (terukur y=-0,349). Sekarang kapsul tinggi 1,7 berpusat y=0,85: alas tepat di origin, kaki menapak tanah (terukur y=0,019).

### 3. BUG: tidak bisa masuk surau — penyebab + perbaikan
**Penyebab:** lantai surau setebal 0,15 m (permukaan y=0,15) — bibir 15 cm itu lebih tinggi dari `floor_snap_length` (0,1) sehingga pemain tertahan di ambang pintu. Terukur sebelum perbaikan: pemain berhenti di z=-8,71 (pintu di z=-9). **Perbaikan:** permukaan lantai diturunkan ke y=0,02 (praktis rata dengan tanah), karpet + sajadah ikut turun, `floor_snap_length` pemain 0,3, plus ambang pintu emas sebagai penanda visual. Terverifikasi headless: pemain jalan lurus dari spawn sampai ke dinding utara surau (z=-14,52).

### 4. Mode HP miring (landscape)
- `project.godot`: `window/handheld/orientation=0` (Landscape). Catatan: di export web yang benar-benar menegakkan ini adalah overlay di bawah (manifest PWA tidak berlaku karena PWA tidak diaktifkan).
- **Overlay "Putar HP"** (`ui.gd`): muncul saat layar portrait DI PERANGKAT SENTUH — satu overlay di atas layar masuk MAUPUN di dalam game; ikon panah melingkar digambar kode (tanpa aset), judul "PUTAR HP-MU", pesan landscape lebih lega, tombol "Tetap main portrait" untuk menutup (muncul lagi kalau orientasi berubah). Di desktop berjendela sempit tidak muncul (tanpa sentuhan).
- **Form kompak landscape:** `login_metrics()` kini menerima tinggi viewport; kalau form penuh tidak muat (HP landscape 844x390, tinggi logis ~722), mode kompak aktif: target fisik lebih kecil + sub-judul & catatan disembunyikan. Perkiraan tinggi form 712,8 <= 722 (teruji). Portrait tidak berubah (judul tetap 132, mode longgar).
- **HUD berjangkar:** joystick, tombol interaksi, log chat, dan tombol reset kini berjangkar ke sudut layar (dulu koordinat tetap 1280x720 — di HP portrait/landscape posisinya melayang).

### 5. BUG: masuk jurang tidak bisa kembali — 3 lapis pengaman
**Penyebab:** pagar hidup hanya visual (tanpa collision) dan tanah hanya 70x70 — pemain bisa jalan keluar tepi tanah lalu jatuh selamanya (terukur: y=-160). **Perbaikan:** (a) **dinding tak terlihat** di garis pagar seluruh keliling (±28, termasuk celah gerbang selatan — gerbang hanya dekorasi, di luarnya tidak ada apa-apa); (b) **respawn otomatis** di `main.gd`: y < -5 atau |x|/|z| > 40 -> teleport ke spawn depan Surau + toast; (c) tombol **"Reset Posisi"** di HUD kanan bawah (di atas tombol interaksi) sebagai jaring pengaman manual. Terverifikasi: jalan ke selatan tertahan di z=27,40; jatuh dari (0,0,40) respawn ke spawn (y_min -4,90 lalu kembali).

### Verifikasi ronde ini
- `--import` exit 0; `--check-only` 9/9 script lolos.
- Tes headless `test_bugs.gd` (dihapus setelah jalan): **21/21 cek LOLOS** — masuk surau, tidak melayang, dinding selatan, jatuh -> respawn, reset posisi, metrik landscape kompak + muat, metrik portrait tetap, rotate overlay (3 kasus), karakter (mata/peci/sandal/sarung kotak/tangan), form (kartu radius 20, field radius 12, error gelap, tombol emas teks gelap).
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR**.
- Pck hasil export dijalankan headless 30 detik (`--main-pack`): **0 SCRIPT ERROR**.
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`: pck baru 110.960 byte (sha256 `4580c6f2…b186`), wasm TIDAK berubah (`fe5cebc5…028b9`); `experimentalVK:true` + viewport `user-scalable=yes` tetap ada di index.html. File tes dihapus.
- **Tidak diubah:** perbaikan layar hitam (staging — urusan deploy), logika misi M1–M3, skor, Kartu Santri, chat bubble, ambang 25/50/100/200, save data. Tidak menyentuh CCS, game-nahwu, atau app.
- **Belum teruji:** tampilan karakter + form di HP beneran tetap perlu dinilai Mas dari HP (VM tidak bisa render WebGL); overlay "Putar HP" di HP portrait sungguhan; joystick di HP landscape sungguhan. Perlu deploy ulang + tes HP Mas.
- Catatan: dinding utara z=-28 memotong 2 m ujung utara plot Masjid Besar (plot z -30..-22) — plot masih dekorasi; saat bangunan dibangun, tata dinding ditinjau lagi.

## Ronde perbaikan 15 Nov ~12:50 WIB — 3 masalah dari tes browser deployment 887ed80f

### 1. BUG: masuk surau masih gagal — penyebab + perbaikan
**Penyebab (terukur headless):** DUA hal. (a) Fisik: celah pintu hanya 1,6 m (x∈[-0,8, 0,8]); kapsul pemain 0,7 m — dari kiri/kanan lurus ke utara pemain menabrak segmen dinding dan berhenti di z=-8,52 (muka dinding + jari-jari kapsul). Dari tengah lurus MASUK (z=-9,57) — tapi (b) visual: papan "Papan Misi 1" berdiri TEPAT di tengah ambang pintu (0,0,-8), mengisi celah 1,6 m itu, sehingga penguji mengira pintu tertutup dan steering joystick di sekitarnya selalu berakhir di dinding. Papan itu sendiri TIDAK punya collision (`Palette.box` murni visual) — yang menahan adalah dinding.
**Perbaikan:** penanda M1 dipindah ke (3,0, 0, -6,5) — di samping kanan Surau, tepi kiri papan x=2,05, jauh dari koridor masuk |x|<=1,5 (`mission_data.gd`); celah pintu dilebarkan jadi 2,0 m — segmen dinding 2,5 m di x=±2,25, ambang atas 2,0 m (`pesantren_builder.gd _surau`).
**Terverifikasi:** jalan masuk dari tengah (tick 92, z=-9,57), kiri (tick 87, steering mentok-dinding -> arah ke tengah pintu -> masuk), kanan (tick 87) — semua BERAKHIR DI DALAM Surau, bukan cuma sampai dinding utara.

### 2. BUG: gelembung sapaan NPC raksasa — penyebab + perbaikan
**Penyebab (terukur headless, kamera fov 60):** gelembung sapaan NPC adalah Label3D billboard 4 baris, AABB 2,54×1,18 m, `fixed_size=false` — ukuran tampaknya = tinggi dunia / (2·jarak·tan 30°), membesar tanpa batas saat NPC mendekati kamera: 204% tinggi layar di 0,5 m, 102% di 1 m, **51% di 2 m**, 25% di 4 m. Di HP landscape (tinggi 390 px) 2 m = ~94% layar. Beda dari chat bubble biasa (sudah kecil) karena teks sapaan lebih panjang (4 baris).
**Perbaikan:** helper baru `Palette.batasi_label_kamera(label, kamera, maks_fraksi=0,11)` — skala label dijaga supaya tinggi tampaknya ≤11% viewport; hanya mengecilkan, tidak pernah membesarkan (skala maks 1, min 0,08). Dipanggil tiap frame di `player.gd` + `npc.gd` (bubble + label nama) dan di loop penanda `main.gd` (ikon "!" + status). Ikon "!" (0,9 m, font 64) dan status juga tercakup.
**Terverifikasi:** gelembung 0,5 m 204%->16% (batas bawah skala), 1 m 102%->10%, 2 m 51%->10%, 4 m 25%->10%, 7 m 14%->10%, 10 m tetap 10%; ikon "!" + nama di 2 m = 11%; bubble NPC asli di scene 5% di 17,4 m.

### 3. BUG: teks papan terpotong + Kartu Santri tidak bisa ditutup
**Penyebab teks (terukur headless):** label papan adalah BILLBOARD yang berputar mengikuti kamera, sementara papan diam — dari sudut ≥10°, tepi label berayun ke belakang bidang muka papan (celah 0,06 m) lalu tertutup papan oleh depth test (terukur: tepi kanan label M1 di z=-8,028 vs muka papan -7,96 pada azimut 10°; makin miring makin dalam). Bukan teksnya yang terpotong di data (lebar AABB penuh terukur: LAHAN PERPUS 3,89 m dll.) — melainkan tertutup papan. Tambahan: teks "Papan Tulis Surau" 2,08 m > papan 1,9 m.
**Perbaikan teks:** `Palette.label3d()` kini punya parameter `billboard` — label papan TIDAK billboard (menempel sejajar papan seperti papan sungguhan), digeser 0,15 m ke depan; papan selamat datang dilebarkan 2,8->3,0 m; papan M2 dilebarkan 1,9->2,4 m. Label melayang (nama/bubble/ikon/status) tetap billboard.
**Terverifikasi:** 7/7 papan tidak billboard, lebar teks ≤ lebar papan (LAHAN PERPUS 3,89 ≤ 4,2 m; PESANTREN VERSE 2,57 ≤ 3,0 m; Papan Tulis 2,08 ≤ 2,4 m), offset label 0,15 m; angka 25/50/100/200 tertulis penuh.
**Penyebab Kartu Santri (terukur headless):** `_build_dashboard_panel` memanggil `set_anchors_preset(PRESET_CENTER)` SEBELUM `add_child`, saat ukuran panel masih 0 — offset semua 0, sudut kiri-atas panel jatuh tepat di tengah viewport, tombol Tutup (504 px di bawah atas panel) di luar layar pada viewport <1100 px. Tidak ada tombol X, tidak ada Escape, tidak ada klik-di-luar (`ui.gd` sama sekali tidak punya `_unhandled_input`).
**Perbaikan Kartu Santri:** `_layout_dashboard()` — ukuran eksplisit min(700, 92% lebar viewport) × min(560, 92% tinggi viewport), dipusatkan dengan offset simetris, dipanggil saat build + `size_changed`; header berisi judul + tombol **X** (48×44); tombol Tutup footer tetap; `_unhandled_input` menutup lewat **Escape** atau **klik/ketuk di luar panel** (HUD sudah `MOUSE_FILTER_IGNORE`, jadi klik area kosong memang sampai ke sini); `main.gd _on_open_dashboard` kini **toggle** (tutup kalau sudah terbuka). `is_dashboard_visible()` + `close_dashboard()` baru.
**Terverifikasi:** panel offset simetris -350/-280, ukuran sesuai rumus, tombol Tutup + X di dalam rect panel; tutup lewat X, toggle, Escape, klik-di-luar, ketuk-di-luar, tombol Tutup — semua lolos; klik DI DALAM panel tidak menutup.
**Catatan:** panel misi (`_build_mission_panel`, ui.gd:637) memakai pola preset-sebelum-add_child yang SAMA — tombolnya terbukti masih bisa dipakai penguji, jadi TIDAK diubah di ronde ini; catat untuk ronde berikut.

### Verifikasi ronde ini
- `--import` exit 0; `--check-only` 10/10 script lolos (9 game + 1 tes).
- Tes headless `test_perbaikan.gd` (dihapus setelah jalan): **44/44 cek LOLOS** — 3 arah masuk Surau, gelembung (6 jarak + ikon + nama + NPC asli), 7 papan (billboard/ukuran/offset/angka), 12 label melayang tetap billboard, dashboard (layout + 6 cara tutup + klik-dalam).
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR** (hanya noise dummy-renderer headless "Parameter 'm' is null" yang sama seperti ronde-ronde sebelumnya).
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`: pck baru 113.760 byte (sha256 `055fc8c4…a7d22`), wasm TIDAK berubah (`fe5cebc5…028b9`). File tes dihapus sebelum export ulang (pck bersih, tanpa script tes).
- **Tidak diubah:** logika misi M1–M3, skor, chat bubble, ambang 25/50/100/200, save data, mode landscape + overlay "Putar HP", karakter, form, HUD, tombol Reset Posisi, dinding tepi/pagar. Tidak menyentuh CCS, game-nahwu, atau app.
- **Belum teruji:** tampilan di HP beneran tetap perlu dinilai Mas (ukuran gelembung + teks papan + panel Kartu Santri di layar HP sungguhan); jalur 92% viewport di HP landscape/portrait dihitung dari rumus (700×359 di 844×390, 359×560 di 390×844 — muat), tapi headless viewport-nya 1280×1280 sehingga jalur itu tidak terpicu di tes headless. Perlu deploy ulang + tes HP Mas.

## Karakter bulat — tidak balok lagi (15 Nov ~14:26 WIB, Raka)
Mas menilai karakter PV masih terlalu balok dibanding hero CCS ("Kok bagusan tampilan ccs ya", "Karakter ga terlalu balok kek ini.."). Referensi: hero CCS `game-nahwu/.../assets/hero/hero_santri.png` — sprite 2D kartun halus, tanpa sudut tajam.
**Penyebab:** kaki/lengan/mata/hidung/senyum memakai `Palette.box` — kaki 0.12×0.55×0.12, lengan 0.09×0.50×0.09, mata/hidung/senyum kotak datar. Kepala memang sudah bola dan badan/sarung sudah tabung, tapi bagian kotak itulah yang memberi kesan balok.
**Perubahan (`player.gd build_visual()`, dipakai pemain + NPC):**
- Kaki → kapsul r=0.06 h=0.55 warna **kulit** (dulu balok hitam; hero CCS kakinya kulit di bawah sarung); lengan → kapsul r=0.045 h=0.50 koko putih. Helper baru `Palette.capsule()` di `palette.gd` (CapsuleMesh, 24 segmen).
- Mata → bola r=0.021 agak lonjong (scale y 1.25); hidung → bola kecil r=0.025; senyum → lengkung dari **5 bola kecil** r=0.011 di permukaan kepala (ujung lebih tinggi dari tengah).
- Pola sarung → 12 **cakram** bundar (silinder r=0.05 diputar 90°, depan + belakang); lis dada → strip bulat vertikal (silinder dipipih z); sandal → **oval** (silinder r=0.085 dipipih memanjang, scale z 1.5), dinaikkan sedikit (y=-0.575) supaya menutup ujung kapsul kaki.
- **TIDAK ADA lagi BoxMesh di karakter** (terukur: 0). Pivot ayunan dipertahankan (kaki y=0.62, lengan y=1.34); kapsul collision pemain TIDAK berubah (h 1.7, center y 0.85, di `main.gd`); palet zamrud/pasir/emas tetap.
**Verifikasi:**
- `--import` exit 0; `--check-only` 10/10 script lolos (9 game + 1 tes).
- Tes headless `test_karakter.gd` (dihapus setelah jalan): **28/28 cek LOLOS** — 0 BoxMesh, kapsul 4, bola 15, tabung 21, pivot kaki/lengan, kaki kulit, sandal oval, mata bola lonjong, senyum 5 bola melengkung, hidung bola, pola 12 cakram depan-belakang, kepala/peci/4 kancing emas, ayunan jalan (kaki ±0.47 rad, lengan berlawanan arah kaki). Catatan tes: `_physics_process` TIDAK boleh dipanggil manual dari `_init` script SceneTree (tree belum jalan → `get_space()` null, `_ready` belum terpanggil) — ayunan dites lewat `_process` setelah 60 frame, mesin memanggil `_physics_process` tiap tick.
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR** (hanya noise dummy-renderer "Parameter 'm' is null" seperti ronde sebelumnya).
- Pck hasil export dijalankan headless 600 frame (`--main-pack`): exit 0, **0 SCRIPT ERROR**.
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`: pck baru 114.432 byte (sha256 `d9112a5f…9e8c`), wasm TIDAK berubah (`fe5cebc5…028b9`). File tes dihapus sebelum export ulang (pck bersih). **TIDAK deploy** — tes boot deployment 7c3ac095 masih jalan di browser; deploy ronde ini urusan Damar setelah tes selesai.
- **Tidak diubah:** perbaikan ronde 2 (pintu Surau, gelembung NPC, teks papan, Kartu Santri), logika misi M1–M3, skor, save data, mode landscape + overlay "Putar HP". Tidak menyentuh CCS, game-nahwu, atau app.
- **Belum teruji:** tampilan karakter di HP beneran tetap perlu dinilai Mas — dialah yang memutuskan cukup halus atau belum.

## UPGRADE Godot 4.3 → 4.7.2 + pesantren lebih hidup (15 Nov ~14:36 WIB, Raka)
Mas: "Kenapa ga pake godot terbaru? ... sila upgrade pake skill tadi.. biar lebih hidup dan tidak terkesan hanya balok kotak-kotak aja". Skill: `godot-3d-essentials` + `godot-export` dari `~/workspace/references/awesome-gamedev-agent-skills/skills/godot/` (ditulis untuk 4.7).
**Toolchain:** Godot 4.7.2 stable di `~/workspace/.tools/godot-4.7/` (biner `Godot_v4.7.2-stable_linux.x86_64`, `--version` = `4.7.2.stable.official.ed1daf0bf`; zip sha256 `cadd3204…35329e4`), template di `~/.local/share/godot/export_templates/4.7.2.stable/` (tpz sha256 `f298490b…248011`, 1.281.349.702 byte). Godot 4.3 di `~/workspace/.tools/godot/` TIDAK disentuh (fallback). Backup proyek 4.3 di `../godot-dunia-backup-4.3/` (115 MB, dibuat sebelum re-import).
**Ketidakcocokan API 4.3→4.7 (hanya 1):** `class_name VirtualJoystick` di `scripts/virtual_joystick.gd` menabrak class native baru di 4.7 ("hides a native class", `--check-only` gagal) → diganti `SantriJoystick` (3 tempat: `virtual_joystick.gd:2`, `ui.gd:49`, `ui.gd:536`). `project.godot` `config/features` "4.3" → "4.7". Script 4.7 membuat file `.uid` baru di `scripts/` (normal di 4.4+).
**Pesantren lebih hidup (`pesantren_builder.gd _environment`, skill godot-3d-essentials):** matahari golden-hour — elevasi ~28° (dulu -52°), warna hangat `#ffd9a8`, energi 1.15, bayangan tetap aktif; langit horizon hangat `#ffe0ae` (dulu `#cfe8f5`), ground horizon pasir `#e8d9b8`; ambient dari langit 0.75; **tonemap AgX** (`TONE_MAPPER_AGX`, baru ada sejak 4.4); **kabut tipis** `fog_density 0.01`, warna `#ffe6c0`, energi 0.6, sun_scatter 0.25 — kabut biasa DIDUKUNG Compatibility renderer (web), TIDAK memakai SDFGI/SSIL/SSR/volumetric fog (tidak ada di Compatibility). Palet tetap zamrud/pasir/emas.
**Pelunakan prop (visual saja, tanpa ubah collision):** 4 pilar sudut bundar di surau (silinder r=0.18–0.2 h=3.2 di (±3.62, -15.12/-8.88)); drum emas r=1.55 h=0.3 di bawah kubah; tiang pintu emas kotak → silinder r=0.08 h=2.5; lampu hangat `OmniLight3D` di dalam surau (`#ffd9a0`, energi 0.5, range 7, tanpa bayangan); 15 tiang bundar di sepanjang pagar hidup (r=0.14–0.16 h=1.2, tiap 14 m; selatan x=0 dilewati karena celah gerbang). Papan tanda tetap kotak (papan memang datar) — yang butuh art pass lebih besar: dinding surau masih kotak (butuh model/bevel), atap datar, peti kayu, sajadah/mihrab/rak kitab kotak.
**Pelajaran instalasi:** JANGAN ekstrak template di `/tmp` — tmpfs 512 MB, unzip gagal "disk full" di `ios.zip`. Ekstrak di disk (`~/workspace/.tools/godot-4.7/extract/`, 2,0 GB), lalu pindahkan `templates/*` ke folder export_templates.
**Verifikasi (Godot 4.7.2):**
- `--import` exit 0; `--check-only` **9/9 script lolos** (setelah rename + re-import refresh cache global class).
- Tes headless `test_upgrade47.gd` (dihapus setelah jalan): **26/26 cek LOLOS** — AgX, kabut 0.01, langit/matahari hangat, matahari -28°, pilar 4, drum 1, tiang pintu 2, lampu interior 1, tiang pagar 15, koridor pintu bebas collision, kapsul pemain 1.7/0.35 utuh, 0 BoxMesh di karakter, `close_dashboard`/`is_dashboard_visible` ada, ambang 25/50/100/200 utuh, kamera current ada. INFO: physics engine 3D = `DEFAULT` (di 4.7 default-nya Jolt — dulu 4.3 GodotPhysics; rasa gerak perlu dites ulang di browser, headless tidak menangkap perbedaan halus ini).
- Headless check scene 3D dari skill (`check_3d_scene.gd`): kamera current ada, **2 lampu terlihat** (matahari + omni interior), ambient true — TAPI 7–12 "MeshInstance3D is behind the camera" (jumlah berubah tiap run karena NPC bergerak): semuanya mesh di selatan kamera spawn (papan selamat datang, plot Perpustakaan, tiang pagar selatan) yang terlihat saat kamera diputar — BUKAN cacat, hanya batas cek statis satu sudut kamera di dunia 360°. Tidak ada error "no light"/"no sky"/"cull_mask"/"past far".
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR**.
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`: pck baru 116.008 byte (sha256 `2d1accff…7ce22ef`), **wasm BARU 39.514.754 byte (sha256 `fc74679e…fa57d0`)** — lebih besar dari 4.3 (35.376.909 byte); `index.js` baru 279.815 byte (sha256 `33c94cb3…5bb6ba`, dulu 331.495 byte). File tes dihapus sebelum export (pck bersih). **File baru di export 4.7: `index.audio.position.worklet.js` (2.973 byte) — Damar WAJIB ikut deploy (bagian dari export web 4.7).** `index.html` fresh TANPA patch chunking (Damar yang rebuild staging + patch; wasm 39,5 MB → chunking jadi ~5 chunk @8,4 MB, dulu 4 chunk). `thread_support=false` tetap (tidak butuh header COOP/COEP).
- Pck hasil export dijalankan headless 600 frame (`--main-pack`): exit 0, **0 SCRIPT ERROR**.
- **Tidak diubah:** perbaikan ronde 2, karakter bulat, logika misi M1–M3, skor, save data, mode landscape + overlay "Putar HP", form, HUD, Reset Posisi. Tidak menyentuh CCS, game-nahwu, atau app. **TIDAK deploy** — deploy urusan Damar setelah tes boot 7c3ac095 selesai.
- **Belum teruji:** tampilan golden-hour + kabut + prop baru di HP beneran tetap perlu dinilai Mas; rasa gerak dengan physics Jolt (default 4.7) perlu dites di browser (jalan, masuk surau, tabrakan).

## Perbaikan tes 4.7 — langit senja, lahan 100/200, X Kartu Santri, pintu (15 Nov ~15:00 WIB, Raka)
Hasil tes browser build 4.7.2 (3e8e35bc, 14:49–15:48 WIB): sebagian besar LULUS, tapi 3 masalah. Semua diperbaiki di sini, diverifikasi headless + render software, export ulang. TIDAK deploy.
**1. GOLDEN-HOUR TIDAK KELIHATAN (penyebab terukur, bukan tebakan):** penguji melihat langit bidang datar krem/abu-abu, tanpa gradasi, tanpa matahari. Nilai environment sudah benar (BG_SKY, AgX, horizon hangat, matahari -28°) — jadi penyebabnya di RENDER. Render software Movie Maker (xvfb-run, opengl3 = Compatibility): (a) fog on 0.01 = langit datar krem persis laporan penguji; (b) fog off = gradasi biru→krem + matahari terlihat jelas. **Penyebab: kabut Godot JUGA menutupi langit** — langit di jarak tak hingga sehingga faktor kabutnya jenuh (1.0) dan seluruh langit jadi warna kabut, matahari ikut tertutup. **Perbaikan (`pesantren_builder.gd _environment`): `e.fog_sky_affect = 0.0`** — kabut tetap berlaku di objek/tanah, tidak di langit. Terverifikasi render: fog on + sky_affect 0 = langit senja terlihat + tanah di horizon tetap berkabut. Sekalian horizon dihangatkan `#ffe0ae` → `#ffbe78` (oranye) supaya gradasi senja jelas (penguji minta "oranye/merah muda"). Render ulang (sunset + utara + selatan, fog on) DILIHAT langsung: langit gradasi biru→oranye + matahari bersinar, surau + bayangan panjang + tanah berkabut di horizon.
**2. LAHAN 100 DAN 200 "HILANG" (bukan hilang — tidak terbaca):** headless membuktikan keempat plot TER-SPAWN dengan teks benar (25/50/100/200). Penyebab: label papan hanya menghadap selatan (+Z); dari utara yang terlihat adalah sisi belakang teks CERMIN (double_sided=true) sehingga papan tidak dikenali — persis plot selatan (didekati dari spawn di utara) dan plot utara (didekati dari pagar utara). **Perbaikan (`_plot`): tiap papan kini punya label KEDUA di sisi belakang (diputar 180°, menghadap utara)** sehingga terbaca benar dari dua sisi; dari tiap sisi, label lawan tersembunyi di balik papan (papan 4,2 m > teks 3,9 m). Terverifikasi render selatan: dari spawn, papan "LAHAN PERPUSTAKAAN & TAMAN / Dibuka saat 200 santri" terbaca benar.
**3. Catatan kecil:** (a) Tombol X Kartu Santri 48x44 → **56x48** (`ui.gd`) supaya tepi tombol tetap kena klik. (b) "Misi 1 — Kenalan dengan Faris": **BUKAN bug** — string itu tidak ada di kode mana pun (grep "Kenalan" hanya ada di `mission_data.gd:34` = "Kenalan dengan Nahwu"); HUD selalu menampilkan judul M1 dari data. Kemungkinan penguji membaca label nama NPC "Faris" yang melayang di dekat teks misi. Tidak ada yang diubah. (c) Celah pintu Surau **2,0 → 2,4 m** (segmen dinding ke x=±2,45, tepi dalam ±1,2; ambang atas/lis emas/ambang lantai/tiang pintu ikut dilebarkan) supaya karakter tidak tertahan di ambang dan perlu digeser A/D. Papan Misi 1 di (3.0, -6.5, tepi kiri x=2,05) tetap di luar koridor masuk.
**Verifikasi (Godot 4.7.2):**
- `--import` exit 0; `--check-only` 9/9 script lolos.
- Tes headless `test_masalah.gd` (dihapus setelah jalan): **12/12 cek LOLOS** — 4 plot + ambang 25/50/100/200 + papan 2 sisi (label belakang rot 180°, teks sama), BG_SKY + AgX + kabut 0.01 + fog_sky_affect 0.0, matahari hangat, judul M1 benar + tidak ada "Kenalan dengan Faris", celah pintu 2,4 m, tombol X 56x48. Catatan tes: cek UI harus di `_process` (frame 3), bukan `_init` — `_ready` UI baru jalan setelah tree memproses frame pertama.
- Render software Movie Maker 3 sudut (sunset/utara/selatan) dengan kode perbaikan: langit senja + matahari terlihat, papan 200 terbaca dari utara, dunia hangat + bayangan panjang. File tes + shots/ dihapus setelah jalan.
- Headless check scene 3D dari skill (`check_3d_scene.gd`): kamera current ada, **2 lampu terlihat**, ambient true — 7 "behind the camera" (sama seperti ronde upgrade: mesh selatan kamera spawn, terlihat saat kamera diputar; BUKAN cacat). Tidak ada error "no light"/"no sky"/"cull_mask"/"past far".
- Smoke test headless 600 frame scene utama: exit 0, **0 SCRIPT ERROR**.
- Export ulang `--export-release "Web"` exit 0 ke `export/web/`: pck baru **116.504 byte (sha256 `380de840…b343`)**; wasm TIDAK berubah (`fc74679e…fa57d0`), index.js + worklet.js tidak berubah. Pck hasil export dijalankan headless 600 frame (`--main-pack`): exit 0, **0 SCRIPT ERROR**. File tes dihapus sebelum export (pck bersih).
- **Tidak diubah:** logika misi M1–M3, skor, save data, mode landscape, karakter bulat, perbaikan ronde 2 lainnya. Tidak menyentuh CCS, game-nahwu, atau app. **TIDAK deploy** — deploy urusan Damar.
- **Belum teruji:** tampilan di HP beneran tetap perlu dinilai Mas (langit senja, papan 2 sisi, tombol X, pintu 2,4 m) — dialah yang memutuskan cukup hidup/halus atau belum. Observasi kecil (tidak diperbaiki di ronde ini): papan selamat datang terlihat polos abu-abu dari belakang (sisi utara) — sama seperti semua papan sebelum perbaikan 2 sisi; bisa ikut dibuat 2 sisi di ronde berikut bila Mas mau.

## Ronde 4 — 7 item Mas + langit + karakter (15 Nov ~16:46–19:05 WIB, Raka)

Ronde 4 dikerjakan Raka; **dipecah Mas 19:01 WIB** ("pekerjaan Raka biar cepet
selesai dulu") — Raka jadi ketua + integrator, Tara (UI), Gilang (pesantren
luar), Dewa (interior) mulai 19:02 WIB. Status lengkap di `RONDE4-STATUS.md`.
Yang di bawah ini slice Raka (karakter + langit) sampai titik aman.

### Slice Raka — karakter gaya Roblox (SELESAI, 18:49–19:05 WIB)
Referensi Mas: `~/workspace/pesantren-verse/referensi-avatar-roblox.jpg`.
**Perubahan `scripts/player.gd` (`build_visual` + `_lembutkan`):**
- Kepala 0.21 → **0.24** di y=1.66 (diameter 0.48, LEBIH LEBAR dari torso);
  mata 0.025 di (±0.085, 1.69, 0.222); hidung (0, 1.62, 0.237); peci
  0.19/0.225 di y=1.87 + lis 0.215/0.23 di y=1.81; kerah 0.10/0.12 di y=1.42.
- Torso kapsul 0.21 → **0.23** h=0.62 di y=1.08; lis 0.30 di z=0.225;
  kancing dihitung ulang (silinder kapsul y 1.00–1.16).
- Lengan 0.065 → **0.08**, pivot ±0.29; tangan 0.07 → **0.09**.
  Kaki 0.07 → **0.085**, pivot ±0.11; sandal 0.095 → **0.11**.
- Sarung 0.20/0.28 (hem 0.285); motif tetap checker prosedural.
- Mulut: torus → **kapsul tipis dibaringkan** (r=0.009, h=0.08, rotasi Z 90°,
  di (0, 1.55, 0.210)) — GARIS LURUS kecil menyambung ala referensi, bukan
  busur, bukan benjolan. (Menggantikan busur torus 18:46 WIB — Mas kirim
  referensi Roblox 18:49 WIB yang mulutnya garis lurus.)
- Shading lembut: `_lembutkan(root)` — semua bahan karakter ke roughness
  **0.45** (dari 0.9 karton); motif sarung dipertahankan. Label nama y=2.12,
  bubble y=2.50. Total tinggi ~1.94 m. 6 kapsul, 0 BoxMesh, 0 TorusMesh.
- Yang TIDAK ditiru dari referensi: hoodie/sneakers/headphone/visor/logo "B".
  Model Blender (Bima) jalan paralel dan **TIDAK masuk ronde ini**; v1
  ditolak Mas 19:08 WIB ("Jelek.. belum seperti referensi") — Bima revisi.

### Langit senja (SELESAI di kode — dari tes browser ronde 3)
`scripts/pesantren_builder.gd` (`_environment` + `_matahari`): kabut
**DIMATIKAN** (`fog_enabled=false`) — kabut menutupi langit di renderer web
meski `fog_sky_affect=0.0` (langit di jarak tak hingga, faktor kabut jenuh);
matahari ke barat-laut elevasi ~8° (`rotation_degrees (-8, -145, 0)`, energi
1.3); gradasi dikuatkan (atas `#3f8fd2`, horizon `#ff9e57`, dasar `#5a8f57`);
matahari 3D (bola r=18 `#ffdf6b` + halo r=27 alpha 0.30) di `sun_dir × 380 m`.

### Verifikasi slice Raka (Godot 4.7.2)
- `--import` exit 0; `--check-only` **10/10 script exit 0**.
- `test_karakter.gd`: **38 lolos, 0 gagal** (600 frame, 0 script error) —
  karakter 20, langit 5, login+panel 5, interior masuk 4, keluar 4.
- Foto render software (xvfb-run + opengl3, BUKAN build web):
  `~/workspace/pesantren-verse/foto-avatar-gameplay-belakang.png`,
  `foto-avatar-depan.png`, `foto-avatar-wajah.png`, `foto-avatar-sarung.png`,
  `foto-langit-utara.png` (skrip `foto_karakter.gd`).

### BLOKIR — screenshot build web (Chrome 157 Local Network Access)
Build web lokal (`https://pesantren-verse.pages.dev:8901/`, server HTTPS
127.0.0.1:8901) tidak bisa dibuka Chrome penuh: `ERR_BLOCKED_BY_LOCAL_NETWORK_ACCESS_CHECKS`
(hostname publik → IP lokal via host-resolver-rules). Dicoba dan gagal:
`--disable-features=LocalNetworkAccessChecks`, tab fresh, IP langsung,
enterprise policy `/etc/opt/chrome/policies/managed/pv-local.json` +
restart Chrome. Server lokal sehat (curl 200). Setelah Damar deploy ronde 4
ke pages.dev, LNA hilang (URL publik sungguhan) — screenshot build web bisa
diambil dari URL live. Detail di `RONDE4-STATUS.md`.

### Yang tersisa (Tara / Gilang / Dewa — Raka integrasi setelah mereka lapor)
- Tara (`ui.gd`): kartu kuis, overlay peta, smartboard.
- Gilang (`pesantren_builder.gd` + bounds/kamera `main.gd`): map luas, pagar
  solid, Surau luar besar, Reset Posisi + kamera.
- Dewa (file BARU + snippet wiring): interior GTA + isi interior.
- Integrasi Raka: gabung + verifikasi penuh + hapus file tes + export web ke
  `export/web/`. **JANGAN deploy** (Damar).

## Integrasi ronde 4 + export (15 Nov ~19:12–19:20 WIB, Raka)
Ketiga slice selesai dan terintegrasi (detail di `RONDE4-STATUS.md`):
- **Gilang (pesantren luar) 48/48:** hanya `_dekor` baru (2 pohon dipindah,
  +14 pohon = 37, +6 semak +4 batu, papan selamat datang 2 sisi).
  **SPEED tetap 6.0** (keputusan integrator).
- **Dewa (interior) 52/52:** file baru `scripts/interior_surau.gd` +
  `scenes/interior_surau.tscn`, ruangan 18×14 m. Wiring Raka di `main.gd`
  (`InteriorSurau.build()`); interior lama di `pesantren_builder.gd`
  dihapus (fungsi `_interior_surau` + `_meja_sampar`, 4 kunci dict,
  `static var _smartboard_screen`). Konstanta INTERIOR_SPAWN dipertahankan
  (dipakai tes). Konflik: tes Dewa menambahkan InteriorSurau kedua ke
  `_main` → nama jadi `InteriorSurau2` → cek nama gagal; perbaikan final:
  node tes ke `root` (Window), bukan `_main` → 52/52.
- **Tara (UI) 97/97:** hanya `scripts/ui.gd`. Akar keluhan Mas: panel
  portrait 213×171 px FISIK (font judul ~8 px, tombol X 17×15 px).
  Perbaikan: `panel_metrics` sadar-skala + `_terapkan_skala_panel()` +
  autowrap 3 judul header. `show_smartboard()` kini ada (alias).
- **Verifikasi penuh: 235 cek (97+52+38+48), 0 gagal.** `--import` exit 0;
  `--check-only` 14/14 script exit 0. File tes dihapus sebelum export.
- **Export web (`--export-release "Web"`, 19:20 WIB) exit 0:**
  `export/web/index.pck` 144.296 byte (sha256 `2f6041b4b8ad59d37…`),
  `index.wasm` 39.514.754 byte (sha256 `fc74679e3b97f768…`, TIDAK berubah —
  engine sama), `index.js` 279.815 byte, `index.audio.position.worklet.js`
  2.973 byte (WAJIB ikut deploy). Script tag fresh export 2/2 seimbang
  (angka 3/3 di deploy guard berlaku untuk staging Damar + patch chunking).
  Pck hasil export dijalankan headless 600 frame (`--main-pack`):
  exit 0, **0 SCRIPT ERROR**. **TIDAK deploy** — deploy urusan Damar.
- **Belum teruji:** tampilan di HP beneran + browser portrait (font judul
  ~26 px fisik, tombol X ~56×48 px fisik — Tara) tetap perlu dinilai Mas;
  screenshot build web lokal TIDAK BISA dari VM ini (Chrome 157 LNA —
  lihat `RONDE4-STATUS.md` §BLOKIR); verifikasi visual harus dari URL live
  setelah Damar deploy.

## RONDE 5 — SELESAI (15 Nov ~21:50 WIB, Raka)
- Langit dinamis jam nyata (5 fase, matahari/bulan 3D, bintang, lampu malam) — `scripts/langit_dinamis.gd` baru; kabut tetap mati.
- Label nama TANPA outline ala game bola (font 26, culling 28 m); papan/penanda dirapikan (outline kontras); M2 → "Smartboard Surau".
- Papan tulis Surau DIHAPUS (smartboard tetap).
- Map tanpa pagar: tanah 800×800 m (MAP_HALF 400), respawn limit hapus, 10 gunung, sawah (60×40 m) + gubuk, 61 pohon; pagar 4 lahan tetap.
- Peta GTA: minimap live heading-up di HUD kiri atas + peta penuh (target misi, sawah, gunung, zoom 1.0x/4.0x — 2.0x dihapus karena label tetap menumpuk; label 1 baris + geser diagonal, teks SURAU/Kamu/TUJUAN dihapus dari peta).
- Chat MLBB: tombol kecil + panel gelap membulat di tengah-atas (bukan bawah), riwayat di dalam panel, muat portrait 390.
- Bug kamera frame lambat diperbaiki: lerp rig dijepit (`minf(1.0, delta*8.0)`) — sebelumnya overshoot sampai kamera mendarat di papan selamat datang (terbukti di foto).
- Verifikasi: import 0, check-only 11/11, tes logika 70 LOLOS / 0 GAGAL / 1 SKIP (portrait via foto), smoke 600 frame 0 error (2×), 17 foto bukti.
- Export `export/web/`: pck BARU 158.132 byte sha256 `97f0359b…eefffe4e`; wasm + index.js + worklet TIDAK berubah. TIDAK deploy (Damar).
- Detail: `RONDE5-STATUS.md`. Retest browser ronde 4 tidak pernah sampai selama ronde 5.
- Belum sempurna: subuh 05:00 cukup terang; foto gunung kameranya terlalu dekat; foto sawah terhalang gubuk; label "TERKUNCI" melayang di atas smartboard (penanda misi, hilang setelah M1 selesai); verifikasi URL live menunggu deploy Damar.

## RONDE 6 — SELESAI (15 Nov ~23:50 WIB, Raka)
- Perintah Mas 21:58 (6 item) + 22:04 (9 item) + 22:08 (lengan) + 22:17 (sistem satu jalur) + 22:55 (plakat hamzah OK, sarung BATIK) + 23:01 (lengan diulang serius + cangkruk pos ronda 5 kasur).
- Font game: Baloo 2 (Variable, wght 600/700 via FontVariation `variation_opentype`) + Amiri Bold (Arab) — di-bundle di `fonts/`, terverifikasi masuk pck. **TEMUAN: `theme/default_font` TIDAK PERNAH aktif sejak ronde 6 karena komentar `#` di project.godot merusak parsing ConfigFile (parser hanya kenal `;`)** — diperbaiki, Baloo 2 SemiBold kini default UI. Jangan tulis komentar `#` di project.godot/export_presets.cfg.
- Lengan SATU BENTUK HALUS (revisi 23:01, ganti perbaikan 22:08 yang belum cukup): BahuYoke (elipsoid pipih 1.35/0.45/0.95) + bola bahu r=0.115 + tabung meruncing 0.105->0.085->0.062 + bola siku r=0.085 + tangan bola pipih (1.0/0.7/1.3); siku LURUS 0.0 saat berdiri (patahan -0.18 dihapus); lengan menggantung z ±0.07.
- Sarung motif BATIK PARANG prosedural (256×128: pita diagonal + isen-isen + titik emas), ganti checker; 4 warna outfit tetap, masing-masing batik dalam warnanya. Plakat PAKAI HAMZAH (مصلى الإخلاص) — dikonfirmasi Mas 22:55, tanpa perubahan.
- Cangkruk POS RONDA tertutup & luas: luar kayu 10×8 m tinggi 3,4 m, atap segitiga curam, 6 jendela, label 1 baris; interior 14×10 m tinggi 3,6 m, **5 kasur** (barat 2, timur 2, utara-tengah 1, jalan 3 m di tengah), lemari + meja + lampu tetap. Tidur snap ke kasur TERDEKAT. Pintu luar (14,0,-10.0), pintu dalam (-60,0,-295); `bed_pos` tunggal -> `bed_pos_list`.
- Sistem SATU jalur: login/daftar tanpa pilihan jalur; jadwal Ngaji Aja -> jadwal KHATAMAN (05:00 Jurumiyah, 13:00 Amtsilah Tashrifiyyah, 18:30 Safinatun Naja + penanda "sedang berlangsung").
- Aksi karakter (7): duduk bersila, berdiri, salaman (hadap NPC terdekat <=6 m), menulis, bawa kitab (toggle), melambai, tidur (hanya di cangkruk). Panel Aksi + Panel Ganti Baju (koko/songkok/sarung, tersimpan, preview langsung). **BUG ✓ diperbaiki: tanda "✓" panel outfit tidak pernah muncul karena kunci hex 8 digit tanpa `#` vs banding `"#rrggbb"`** — kini `"#"+to_html(false)`.
- Bubble kecil (font 22, lebar 240, potong 100 karakter + "…"). Sandal lepas otomatis saat masuk Surau/cangkruk, muncul di depan pintu; dipakai lagi saat keluar. Double Surau: kedua interior hidden saat di luar.
- **Diagnosis label bertumpuk foto 19/20 lama: BUKAN label ganda — bubble chat panjang tahap sebelumnya masih tampil 5 detik dan menimpa label.** Skrip foto baru menyembunyikan bubble di reset; foto 19 baru bersih.
- **Perbaikan tidur dari foto: pose tidur lama y=0.22 membuat badan TENGGELAM ke dalam kasur (foto kasur tampak kosong).** Target y diubah ke 0.58 (di atas matras) + snap tidur +0.15 (dari +0.6) supaya badan pas di kasur 2,1 m — terbukti foto 10 (badan di atas kasur, kepala di bantal).
- Verifikasi: import 0, check-only 12/12, tes logika **130 LOLOS / 0 GAGAL** (termasuk batik multi-warna + titik emas, lengan meruncing, 5 kasur + snap terdekat, tidur y 0.58), smoke 0 script error (tes headless + 3 run foto xvfb ~10 menit), 29 foto bukti (semua dilihat satu per satu).
- Export `export/web/`: pck BARU 976.240 byte sha256 `c85116fbd8582596cc7af1ae6d4f5749316b5e7a02c9e1feb9ce9289591ba35f` (membesar karena font ter-bundle); wasm + index.js + worklet TIDAK berubah. TIDAK deploy (Damar).
- Detail: `RONDE6-STATUS.md`. Foto: `~/workspace/pesantren-verse/foto-ronde6/` (29 foto).
- Belum sempurna: label nama putih tanpa outline sulit dibaca saat latar terang (foto 06 — keputusan ronde 5 Mas, tidak diubah sepihak; opsi: bayangan gelap halus); kitab pangkuan (menulis) kurang jelas di foto — sampul zamrud mirip sarung; foto interior 5 kasur memakai FOV 95 (bukan FOV game 60) supaya kelimanya masuk frame; dashboard foto 27 tidak menampilkan seksi Khataman (di bawah scroll — dibuktikan tes logika); verifikasi browser + HP Mas menunggu deploy Damar. Penilaian Mas atas lengan baru dari foto adalah penentunya.
- **Deploy ronde 6 LIVE 15 Nov 2026 23:29 WIB (Damar): deployment `8c7f05de` (https://pesantren-verse.pages.dev, alias https://8c7f05de.pesantren-verse.pages.dev), stage deploy/success 23:29:22 WIB. pck baru 976.240 byte sha256 `c85116fb…` — verifikasi live: 16/16 file manifest cocok (blake3), semua URL 200, index.html live sha256 sama dengan staging, tag script 3/3, `fileSizes` pck 976240, wasm rakitan dari 5 chunk live sha256 `fc74679e…` cocok. Retest browser + tes HP Mas berikutnya.**

## RONDE 7 — SELESAI (16 Nov ~03:40 WIB, Raka)
- Perintah: 8 temuan retest browser ronde 6 (01:30 WIB: 5 lolos, 3 gagal, 1 tak teruji). TIDAK deploy (Damar).
- **TEMUAN KUNCI item 1: reproduksi pertama adalah ARTEFAK TES, bukan bug game** — viewport headless 64×64 vs visible rect 1280×1280 mengalikan posisi klik ×20, jadi klik mendarat di luar panel dan handler klik-di-luar menutupnya (terbukti trace print, sudah dihapus). Perbaikan tes: kirim klik dalam koordinat WINDOW. Penyebab asli di browser sungguhan tetap tidak terbukti dari kode (jalur tombol/sinyal/pose identik dengan tombol login/chat yang bekerja) — mitigasi: toast tiap pose, duduk lebih dalam, salaman/melambai 5 dtk. **Bukti browser sungguhan item 1–3 tetap menunggu retest parent setelah deploy** (Chromium VM tidak bisa start — Hatch WebGL domain policy).
- Kamera tidur: akar terukur — spring 7 m + pitch −0,35 → kamera y≈4,0 di ATAS plafon 3,6 m, plafon tanpa collision. Perbaikan: spring 4,0 dalam ruangan / 3,0 tidur, rig tidur 0,9, collision plafon di kedua interior. **Koreksi dari foto: kepala tidur terbalik (selatan, kaki di bantal)** — `_on_aksi("tidur")` kini `set_facing(0.0)` dulu supaya kepala jatuh utara ke bantal (tes: basis.y.z=−1,0). Foto 03 retake membuktikan.
- Ganti Baju: jalur lemari bekerja (discoverability saja yang gagal) + tombol "Ganti Baju" baru di footer dashboard (di luar ScrollContainer — percobaan di dalam scroll gagal tertangkap tes). Foto 04/05/05b.
- Kasur ke-5: ada, tanpa perubahan kode — foto 06 membuktikan (5 terhitung). Label "TERKUNCI" turun y 2,9→1,6 (foto 07). Peta: legenda swatch warna (tanpa glif tofu), GERBANG masuk rect, de-collision label (foto 08/09). Kartu Santri: spacer 20 px + hover GELAP (foto 10). Chat: bubble sendiri ditahan saat panel terbuka (foto 11).
- Verifikasi: import 0, check-only 12/12, tes logika **31 LOLOS / 0 GAGAL** (termasuk klik mouse nyata koordinat window), smoke 600 frame 0 error, 12 foto bukti (semua ditinjau). **Pelajaran skrip foto: capture async (await 2 frame) menangkap state SETELAH berubah — foto 01 pertama malah "Berdiri."; ditulis ulang sinkron + refresh toast.** Semua skrip tes/foto dihapus sebelum export (`ls *.gd` root = 0).
- Export `export/web/`: pck BARU 978.512 byte sha256 `9cf7c26a…` (tumbuh 2.272 byte); wasm + index.js + worklet TIDAK berubah. TIDAK deploy (Damar).
- Detail: `RONDE7-STATUS.md`. Foto: `~/workspace/pesantren-verse/foto-ronde7/` (12 foto).
- Belum sempurna: bukti browser sungguhan item 1–3 menunggu retest; margin kamera tidur pitch curam tipis (y=3,44 vs plafon 3,595); label dunia bisa bertumpuk sesaat saat NPC dekat penanda (foto 02: "Faris"/"TERKUNCI"); portrait 390×844 belum teruji; foto interior FOV 95.
- **Deploy ronde 7: `ef4315d4` LIVE 16 Nov ~02:07 WIB (Damar)** — pck 978.512 byte sha256 `9cf7c26a…`, guard 3/3, verifikasi live 16/16 file cocok (pck + wasm rakitan + js + worklet + html). Tes boot menunggu retest browser + HP Mas; retest WAJIB untuk item 1 (Panel Aksi).

## RONDE 8 — SELESAI (16 Nov ~04:35 WIB, Raka)
- Perintah: 8 temuan retest browser ronde 7 (03:56 WIB: 2 gagal + catatan). TIDAK deploy (Damar).
- **Item 1 Ganti Baju: TIDAK ditemukan bug di jalur sinyal (headless)** — rantai lengkap lolos klik sungguhan (dict #1d4e6b, material batik biru cache, piksel rgb 0.30/0.44/0.51). Hipotesis terbuka: biru gelap terbaca zamrud di crop kecil saat malam — retest WAJIB cek siang hari. Perbaikan defensif: `_on_outfit_dipilih` visual dulu + print `[RONDE8] outfit_dipilih: %s=%s -> sarung=%s` untuk console retest.
- **Item 3 akar TERKONFIRMASI PERSIS:** kamera bangun 0,22 m dari bola lampu tengah ruangan (bola tanpa collision). Fix: lampu cangkruk pindah sudut NW (-65.5,-303.5) + naik (bola 3.28) + collision sphere r=0.28; 4 lampu Surau juga diberi collision r=0.28; snap kamera saat bangun. Bangun juga bisa lewat TIDUR lagi (toggle) + gerak (input mentah ditangkap sebelum pose menolkan gerakan).
- Item 2: label nama ditahan saat chat terbuka (`_nama_ditahan` player + NPC, diterapkan tiap frame dari `is_chat_visible()`). Item 4: salaman/melambai tahan (timer 0.0) sampai bergerak. Item 5: zoom 3 tingkat [1.0, 2.0, 4.0] + tombol nonaktif di ujung + label tingkat; GERBANG dijepit ke tepi (clamp dari RECT label, bukan titik tengah — jepit pertama meleset 3 px); marker pemain/tujuan dicadangkan di `_label_hindari`. Item 6: **akar terukur — drag dari CheckButton tidak menggulir (tombol STOP memakan event)**; diteruskan via `_on_dash_item_seret` ke ScrollContainer. Item 7: X chat 56×48 + toast IGNORE + klik-di-luar menutup. Item 8: EXONERATED — 6,00 m/detik tepat; joystick 1/6 = 1,00 m/detik (artefak ukur penguji).
- **Pelajaran tes:** scroll max = max_value - page (bukan max_value); tombol dicari exact-text ("Biru" cocok "Biru Muda" dulu); `_teks` kini kembalikan Rect2.
- **Insiden skrip foto (bukan game):** `open_dashboard(main._data_dashboard())` — fungsi tidak ada + butuh 4 argumen; error runtime menghentikan `_initialize` sebelum `quit(0)` → mesin terus jalan (CPU 143%, tampak "macet"), 2× + 1 runtime restart. Perbaikan: `open_dashboard(main._save, [], false, 0)`. Pelajaran: skrip foto pakai signature yang sama dengan tes headless. Juga: `pkill -f` dengan pola yang cocok command sendiri ikut membunuh sesinya — bunuh lewat PID.
- Verifikasi: import 0, check-only semua script OK, tes logika **51 LOLOS / 0 GAGAL**, smoke 600 frame 0 error, 8 foto bukti (semua ditinjau; foto 08 salaman profil + crop-03 close-up sarung biru adalah bukti terkuat item 4 dan 1).
- Export `export/web/`: pck BARU 981.264 byte sha256 `dca77670…` (tumbuh 2.752 byte); wasm + index.js + worklet TIDAK berubah. TIDAK deploy (Damar).
- Detail: `RONDE8-STATUS.md`. Foto: `~/workspace/pesantren-verse/foto-ronde8/` (8 foto + 3 crop).
- Belum sempurna: bukti browser sungguhan item 1–3 menunggu retest setelah deploy (khususnya print [RONDE8] di console + sarung biru di siang hari); foto diambil ~04:17–04:30 WIB (Subuh, gelap); label "Faris" di peta kadang menyentuh tepi kotak SAWAH (teks tetap terbaca, di atas fill); portrait 390×844 belum teruji.
- **Deploy ronde 8: MENUNGGU Damar** — staging `export/web-pages/` dibangun ulang dari export baru (wasm 5 chunk + patch fetch; guard 3/3; pck baru `dca77670…` 981.264 byte).
- **Deploy ronde 8 LIVE (Damar, 16 Nov ~04:33 WIB): deployment `01443d64`** (https://pesantren-verse.pages.dev) — guard 3/3 lolos, live vs staging semua file cocok (pck `dca77670…` 981.264 byte, wasm `fc74679e…` rakitan 5 chunk cocok). Retest browser ronde 8 berikutnya: wajib cek Ganti Baju di siang hari + print [RONDE8] di console, dan bangun tidur.

## RONDE 9 — Perbaikan KARAKTER (16 Nov ~05:25–06:00 WIB, Raka)

Verdict Mas 05:25 WIB: "Kopyah aneh.. Pose duduk aneh, Pose tidur aneh,
Pose menulis aneh, Bahu dan dada aneh. Banyak yg aneh² masih." + 05:33 WIB:
"Kalau tidur kepalanya tembus ke luar 🤣". Detail: `RONDE9-STATUS.md`.
- **Kopyah:** silinder ember → KUBAH bola pipih (r=0.23, skala y 0.62,
  puncak 1.933) + PeciBand; rambut diperkecil (skala y 0.68) jadi jambul.
- **Bahu + dada:** BahuYoke DIHAPUS; pivot lengan (±0.235, 1.30), bola
  bahu r=0.095, lebar bahu 0.77→0.66 m; torso kapsul r=0.21 h=0.66; lis
  dada DIHAPUS; kancing 4→3 butir kecil; kerah warna koko.
- **Duduk:** badan tegak (rot.x 0.05), kaki menyilang (yaw ±0.45),
  sarung mengerut (skala y 0.45, y 0.68) — kaki bersila terlihat.
- **Tidur:** sarung/torso dipipihkan (skala z 0.55/0.6), badan datar,
  lengan di sisi; **kepala tembus SELESAI:** akar masalah = origin di
  kaki, kepala jatuh 1.66 m ke utara (probe: ujung kepala -305.45,
  tembus 0.32 m melewati muka luar dinding); offset snap +0.15→**+0.95**
  (kepala kini di atas bantal, ujung -304.646, aman 0.23 m dari dinding;
  kasur tidak digeser). Label nama disembunyikan saat tidur (bug
  `_process` menampilkannya lagi).
- **Menulis:** kitab pangku naik ke (0, 0.86, 0.38) skala 1.5 (y dunia
  0.348, tidak lagi di bawah lantai), sampul MARUN #7a1f1f, kepala
  menunduk 0.20, lengan kanan menulis.
- **Pendukung:** restore pakaian ke normal saat berdiri/jalan
  (`_physics_process`); `terapkan_outfit` tanpa BahuYoke.
- **Verifikasi:** `--import` 0; `--check-only` semua lolos; tes headless
  `test_ronde9.gd` **66/66 LOLOS** (bentuk + 4 pose + snap tidur 5 kasur);
  smoke 600 frame 0 script error; pck hasil export 600 frame 0 error;
  **11 foto** di `~/workspace/pesantren-verse/foto-ronde9/` (siang via
  debug_jam=10.0; 06/07/11 retake sekali karena framing) — ditinjau
  satu per satu: berdiri/duduk/menulis BAGUS, tidur BAGUS (kepala di
  bantal, dinding luar bersih), dari kaki (07) wajar jadi gundukan.
- **Export `export/web/`:** pck BARU 983.408 byte sha256
  `62c9552a550ddbd519bcee03a7790e1747325a67cff119d1faca9762578f68bb`
  (tumbuh 2.144 byte); wasm TIDAK berubah (`fc74679e…`); worklet ada
  (2.973 byte); experimentalVK tetap. File tes/foto dihapus sebelum
  export. **TIDAK deploy** — deploy urusan Damar.
- **Belum sempurna / jujur:** lengan diam tetap tabung lurus sederhana;
  kepala besar chibi (~25% tinggi) adalah arah gaya yang disetujui —
  kalau Mas masih merasa aneh, yang perlu diputuskan adalah gaya, bukan
  tweak primitif lagi; interior cangkruk siang hari tetap GELAP (tanpa
  jendela, 1 lampu) — di luar scope ronde 9; verdict akhir tetap dari
  HP Mas + retest browser setelah deploy.
- **Deploy ronde 9 LIVE 16 Nov ~05:51 WIB (Damar): deployment `b55a6834`, https://pesantren-verse.pages.dev** — 17/17 file 200, guard 3/3 lolos, pck live sha256 `62c9552a…` cocok, HTML live sama dengan staging. Retest browser ronde 9 (karakter baru + kepala tidur) menunggu parent.
- **RONDE 10 SELESAI + EXPORT (Raka, 16 Nov ~06:30 WIB):** jendela cangkruk (3 jendela kayu + cahaya, energi dinaikkan 0.55→1.6 setelah ukur luminance 47.1→60.9), kopyah/rambut (peci r=0.265 menutupi ubun-ubun 360°, rambut pinggiran tipis), salaman tangan KANAN (akar: pivot arm_r/arm_l tertukar anatomi — wajah di +Z, kanan anatomis di -X; pivot ditukar + semua rotation.z dibalik; menulis/melambai/kitab ikut jadi kanan), tulisan smartboard DIHAPUS (papan 3D bersih, popup UI tetap), kiblat 295° (mihrab pindah ke dinding barat + sajadah diputar; matahari terbenam 290° sudah benar, TIDAK diubah; azimut 15.00 = 325° deliberate ronde 4, tidak diubah). Tes 99/99, smoke 600f 0 error, 9 foto bukti di foto-ronde10/ (06+08 retake). Export pck 985.328 byte sha256 `a892b3cf…`, wasm + index.js tidak berubah, worklet ada. **TIDAK deploy** — menunggu Damar. Retest browser ronde 10 + penilaian Mas di HP berikutnya.
- **RONDE 11 SELESAI + EXPORT (Raka, 16 Nov ~06:55 WIB):** variasi karakter — kulit 3 pilihan (Terang/Sawo Matang/Gelap), kacamata opsional (bingkai hitam + lensa tembus pandang, 13 mesh), songkok hitam diperdalam #2b2b2b→#1a1a1a; Bilal = gelap + kacamata + songkok hitam + sarung biru, Faris = terang + tanpa kacamata + songkok putih + sarung coklat, pemain default = sawo matang + tanpa kacamata + songkok putih + sarung zamrud (ketiganya beda kulit). Panel Ganti Baju ikut ditambah baris Kulit + tombol Kacamata Pakai/Lepas (mudah, pola sama). BUG LATEN diperbaiki: terapkan_outfit dulu tidak mewarnai lengan (get_node_or_null tidak menemukan anak pivot) — kini find_child rekursif. Tes 29/29 + UI 12/12, smoke 600f 0 error, 4 foto bukti di foto-ronde11/. Export pck 988.928 byte sha256 `e327d052…`, wasm + index.js tidak berubah, worklet ada. **TIDAK deploy** — menunggu Damar. Retest browser ronde 10+11 + penilaian Mas di HP berikutnya.
- **Deploy ronde 10+11 LIVE 16 Nov ~06:19 WIB (Damar): deployment `c771c3f0`, https://pesantren-verse.pages.dev** — 17/17 file 200, guard 3/3 lolos, pck live sha256 `e327d052a…` cocok, HTML live sama dengan staging. Retest browser ronde 10+11 + penilaian Mas di HP berikutnya.
- **RONDE 12 SELESAI + EXPORT (Raka, 16 Nov ~06:35 WIB):** jalur azimut matahari DIPERBAIKI ke fisik (Jawa ~7°LS, 16 Nov, deklinasi ~-19°; dihitung independen). Yang salah dulu: terbenam 290° (meleset ~39°, klaim ronde 10 "sudah benar" ternyata SALAH) dan jam 15.00 = 325° (meleset ~74°). Baru: terbit 107°, pagi 108-118°, siang 200°, sore/terbenam 252°. Kiblat 295° − terbenam 252° = **43°: matahari di SEBELAH KIRI mihrab** ✓; pagi di belakang orang menghadap kiblat ✓. Elevasi sore tetap rendah (golden hour); matahari senja tidak lagi di tampilan default (dikorbankan demi kebenaran arah). Tes **16/16**, smoke 600f 0 error, 5 foto bukti di foto-ronde12/ (02: matahari jelas di KIRI jam 15.00; 03: pijar maghrib di kiri; 04: terbenam di barat; 05: terbit di timur; 01: dalam Surau menghadap mihrab — retake 2× karena label TERKUNCI menutupi lensa). Insiden skrip foto: foto 05 hilang karena `_foto()` tanpa await — diperbaiki. Export pck 988.896 byte sha256 `8d72a1ae…` (32 byte lebih kecil dari ronde 11); wasm + index.js tidak berubah, worklet ada. **TIDAK deploy** — menunggu Damar. Retest browser ditahan sampai ronde 12 deploy.
- **DEPLOY RONDE 12 LIVE (Damar, 16 Nov ~06:32 WIB): deployment 923fbebc, https://pesantren-verse.pages.dev** — 17/17 file cocok, guard 3/3 lolos, pck live sha256 8d72a1ae… cocok; wasm/index.js/worklet tidak berubah. (`/index.html` 308 redirect ke `/` — normal.)
- **RONDE 13 SELESAI + EXPORT (Raka, 16 Nov ~07:00 WIB):** sholat berjamaah otomatis (Mas 06:30: "kalau masuk waktu sholat maka semuanya ke surau untuk sholat"). Waktu tetap (jam perangkat WIB): Subuh 04:30, Dzuhur 12:00, Ashar 15:00, Maghrib 18:00, Isya 19:00; sesi = mulai + 10 menit (`MissionData.WAKTU_SHOLAT` + `sholat_saat_ini(jam)`; jam tetap dulu — hisab dinamis ronde lain). Saat sesi mulai: toast + banner "Waktu sholat [nama] — ayo ke Surau!" + tombol emas IKUT SHOLAT (non-modal, boleh diabaikan); NPC Bilal + Faris jalan ke Surau lewat rute Manhattan (koridor aman z≤−22 / x≤−12 / plaza z≥2 — BUKAN garis lurus, supaya tidak menembus dinding), masuk interior lewat teleport di pintu (ala GTA), ambil sajadah (Bilal Sajadah_02, Faris Sajadah_04, pemain Sajadah_03 — posisi di-lookup runtime dari scene, bukan hardcode, supaya rotasi Surau ronde 14 tetap benar), pose sholat menghadap kiblat 295° (yaw −115°): siklus qiyam 5 dtk (lengan bersedekap −0,75) ↔ ruku 3 dtk (condong 0,55); sujud TIDAK dibuat (primitif telungkup terbaca seperti tidur). Pemain ikut lewat tombol (teleport ke Sajadah_03, kamera di belakang); aksi/gerak/Reset Posisi mengakhiri ikut (banner tampil lagi). Sesi habis: NPC jalan ke pintu dalam → teleport keluar → pulang ke posisi rumah → keliling bebas lagi. Tes **44/44** (jadwal + jendela, rute aman dari 7 arah, NPC di sajadah + hadap kiblat, pose qiyam/ruku numerik, ikut + keluar, sesi habis + pulang, banner API), smoke 600f 0 error (sesi Dzuhur aktif), 5 foto bukti di foto-ronde13/ (03 banner + toast Dzuhur; 01 NPC jalan saat Maghrib; 02 NPC + pemain di sajadah menghadap mihrab; 05 close-up — keduanya menangkap RUKU, bukan qiyam, karena frame lambat llvmpipe: qiyam terbukti numerik oleh tes; 04 retake dari run diagnosis — foto pertama membingungkan karena Bilal sudah keliling bebas ke balik Surau sehingga hanya badan atas tampak di atas garis atap — itu OKLUSI BENAR, bukan bug; diagnosis: posisi akhir semua y=0, NPC pulang ke rumah). Sajadah terukur DIAGONAL (Sajadah_02 (−2,83, −300,47), _03 (−1,81, −302,65), _04 (−0,80, −304,82) — diputar −295° sejak ronde 10); bukan bug ronde 13, diluruskan ronde 14. Ma'hadiyah sengaja TIDAK diintegrasikan (ikut 1 sholat ≠ "Lima waktu berjamaah"). Export pck 998.736 byte sha256 `edba6cf9…` (+9.840); wasm + index.js tidak berubah, worklet ada; smoke pck 600f 0 error. File tes/foto/diagnosis dihapus sebelum export. **TIDAK deploy** — menunggu Damar (staging masih pck ronde 12 + index.html ber-patch 3 script; Damar salin pck baru ke staging + cek guard).
- **Koreksi Mas 06:47 WIB untuk RONDE 14: "Mihrab harusnya di tengah tembok. Bukan di pojok."** Mihrab sekarang di (−8,4, −306,0) — dekat pojok utara dinding barat (tengah dinding = z=−301). Saat memutar Surau 25° di ronde 14, mihrab diletakkan di TENGAH dinding kiblat, sajadah terpusat menghadap mihrab. Angka: dinding barat z=−308..−294 (14 m), tengah z=−301; grid sajadah SUDAH terpusat di (0, −301) — yang melenceng hanya mihrabnya (5 m ke utara dari pusat barisan). Ronde 14: pindahkan mihrab z −306 → −301 (koordinat pra-rotasi), lalu putar semuanya 25°; barisan sajadah akan sejajar dinding + terpusat pada mihrab. Foto bukti ronde 14 harus menunjukkan mihrab di tengah dinding dari dalam Surau. Verifikasi ulang fitur ronde 13 setelah diputar (tes ronde 13 bisa dipakai ulang — 44 cek — + foto NPC sholat di Surau yang sudah diputar).
- **RONDE 14 SELESAI + EXPORT (Raka, 16 Nov ~07:30 WIB):** putar Surau 25° (Mas 06:31: "Putar Suraunya 25° — mihrab rata dengan dinding") + mihrab ke TENGAH dinding (Mas 06:47: "Mihrab harusnya di tengah tembok. Bukan di pojok."). Cara putar: node "Surau" diposisikan di P = pusat − R·pusat lalu diputar −25° mengelilingi PUSAT (0,−12); interior diputar −25° mengelilingi PINTU (0,−294) — pintu sendiri tidak berpindah. Nilai dunia (dihitung independen): pintu luar (0,−7) → (−2.11,−7.47); titik keluar → (−2.75,−6.11); spawn dalam → (0.63,−295.36); pintu dalam TETAP (0,−294). Mihrab (−8.4,−306.0) → (−8.4,−301.0) tengah dinding barat, rotasi lokal −270° (di dunia menghadap 295°, rata dengan dinding); grid sajadah pusat (0,−301.0) rotasi −270° — kini SEJAJAR dinding + terpusat di sumbu mihrab (tes: offset mihrab sepanjang dinding ~0, jarak ke dinding 0,6 m, 15 mat 5 kolom × 3 baris). Dua konsekuensi ditemukan saat implementasi: (1) smartboard pindah ke ujung utara dinding barat (z=−305.2) karena mihrab di z=−301 menutupi layarnya — spot smartboard → (−6.8,−305.2), penanda M2 (posisi dunia) → (0.14,−305.19); penanda M1 (3.0,−6.5) tetap. (2) menara pindah ke sudut barat-laut (−7.6,−16.6) karena posisi lama mendarat di (8.83,−12.96) di depan dinding barat cangkruk. Jalan setapak baru (−1.0,−6.5) menyambung jalan utama ke pintu yang kini 2,1 m di barat jalan. Koridor pintu dalam FRAME pintu (sumbu 115° / masuk 25° / keluar 205°); rute NPC berakhir di depan pintu (−2.75,−6.11), segmen plaza→pintu tidak menabrak dinding (t=1.24). Peta besar: Surau sebagai poligon miring (data `surau_rotasi` −25°); minimap dibiarkan (kotak 10×10 px, pusat tidak bergeser). Tes **66/66** (rotasi + frame pintu, mihrab tengah, sajadah sejajar, menara/cangkang, smartboard, penanda, peta, rute, pintu masuk-keluar fungsional, regresi ronde 13: Bilal + Faris di sajadah + pose sholat + hadap kiblat 295°, pemain ikut via Ikut Sholat → Sajadah_03, sesi berakhir 12.30), smoke 600f 0 error, 8 foto bukti di foto-ronde14/ (01+01b Surau miring 25° vs jalan; 02 retake mihrab di tengah dinding — foto pertama tertutup badan pemain, pemain digeser 3 m dari sumbu; 02b dalam lebar; 03+03b NPC qiyam di saf; 04 retake peta 4.0x — Surau jajar genjang miring; 05 pintu + plakat + jalan setapak). Export pck 1.001.536 byte sha256 `45f5be3b…` (+2.800 dari ronde 13); wasm + index.js tidak berubah, worklet ada; smoke pck 600f 0 error. File tes/foto dihapus sebelum export. **TIDAK deploy** — menunggu Damar: deploy 13+14 SEKALI (pck ronde 14 sudah mencakup sholat berjamaah), staging masih pck ronde 12 — Damar salin pck baru + update GODOT_CONFIG 988896 → 1001536 + cek guard. Retest browser ronde 10+11+12 TERHENTI di tengah jalan (browser crash 07:10–07:16 WIB, bukan game): sudah lolos kopyah 360°, salaman kanan, variasi karakter, zoom peta, jendela cangkruk luar; belum terverifikasi interior cangkruk siang, smartboard bersih, mihrab + matahari sore, foto trio, panel Ganti Baju (kulit Gelap + kacamata), sarung biru + console `[RONDE8]`, regresi duduk/tidur/Chat/Khataman — satu retest ulang setelah deploy 13+14.
- **DEPLOY RONDE 13+14 LIVE (Damar, 16 Nov 07:30 WIB): deployment ad5074ed, https://pesantren-verse.pages.dev** — 17/17 file cocok, guard 3/3 lolos, pck live sha256 45f5be3b… cocok. Catatan: file .import staging (936/951/986 byte, hasil re-import Godot 23:39 WIB 15 Nov) diganti dengan versi export segar (760/945/980) — live lama terbukti byte-identik dengan versi segar; file .import hanya metadata editor. Retest browser SATU untuk ronde 10+11+12+13+14 menyusul (sisa ronde 10+11+12 yang tertunda karena browser crash + Surau diputar + sholat berjamaah).
- **RONDE 15 SELESAI + EXPORT (Raka, 16 Nov ~08:35 WIB):** karakter pemimpin pesantren — Ust. Aqsal Murad (Mas 08:09: "Buat karakter pemimpin pesantren: Ust. Aqsal Murad. Berjanggut dan berkumis tipis. Menggunakan serban"). Primitif Godot yang sama (build_visual, bukan Blender). Serban putih krem #f5f0e0 MENGGANTIKAN songkok: 3 lilitan bertingkat (r 0.27/0.285/0.26) + kubah + simpul depan + ekor kain di belakang; rambut disembunyikan (dari belakang atas kepala PUTIH). Jenggot gelap #2b241d (bola pipih membungkus dagu, sampai kerah) dengan uban abu kecokelatan #7d7468 di ujung bawah; kumis TIPIS (kapsul r=0.011, panjang 0.10) di atas bibir; mulut tetap di depan jenggot (z 0.219 vs ~0.193 — dibuktikan numerik). Koko KREM #f2ead6 + sarung HITAM #23282e (motif batik parang tetap jalan); kulit sawo matang (sama seperti pemain — pembedanya serban+jenggot+kumis+sarung gelap); TANPA kacamata (itu ciri Bilal). Label "Ust. Aqsal Murad". Penempatan: serambi barat pintu Surau (−4.8,0,−4.8), menghadap selatan (plaza/spawn); jarak pintu luar ~3,8 m, titik keluar ~2,4 m, ~3,6 m di selatan dinding selatan Surau, ~2,4 m dari koridor jalan NPC — tidak menghalangi pintu/jalan. Perilaku baru (npc.gd mode `diam`): Kyai berdiri TETAP — napas idle saja, TIDAK keliling, TIDAK mengobrol; TIDAK ikut jalan sholat berjamaah (tetap di serambi saat Bilal+Faris ke Surau; sajadah tetap 02/04); tetap muncul di peta + bisa jadi target salaman terdekat. Tes **53/53** (visual Kyai + regresi default + NPC diam unit + integrasi scene + regresi sholat Dzuhur 12.00→12.30), smoke 600f 0 error, 5 foto bukti di foto-ronde15/ (01 close-up depan — serban + jenggot + kumis + mulut + uban terbaca; 02 samping; 03 belakang — ekor serban; 04 RETAKE berempat Bilal–Tes–Kyai–Faris, Kyai paling mencolok — susunan pertama pemain tepat menutupi Kyai; 05 RETAKE penempatan di serambi + plakat). Jujur: jenggot+kumis menyatu di jarak jauh (terpisah jelas hanya di close-up); uban + simpul serban hanya terbaca di close-up; motif batik sarung hitam sangat kontras (paling mencolok di antara keempat sarung — disengaja); Kyai TIDAK ikut sholat (seharusnya memimpin sebagai imam — ronde lanjutan); belum ada dialog/interaksi khusus. Export pck 1.004.080 byte sha256 `0c13e27d…` (+2.544); wasm + index.js tidak berubah, worklet ada; smoke pck 600f 0 error. File tes/foto dihapus sebelum export. **TIDAK deploy** — deploy DITAHAN sampai retest browser ronde 10+11+12+13+14 selesai (Damar: saat deploy, salin pck baru + update GODOT_CONFIG 1001536 → 1004080 + cek guard).
- **RONDE 16 SELESAI + EXPORT (Raka, 16 Nov ~08:40 WIB):** Ust. Aqsal Murad memimpin sholat berjamaah sebagai imam (Mas 08:22: "Iya"). Posisi imam dihitung runtime dari Sajadah_03 (tengah baris depan) + arah kiblat × 1,5 m: 1,5 m di depan Sajadah_03 (≈0,9 m di depan tepi depan sajadah), 4,90 m dari mihrab (tidak menempel dinding), > 1 m dari Sajadah_02/04, di sumbu mihrab, 5,34 m dari smartboard; imam 1,52 m di depan Bilal. Saat sesi mulai Kyai jalan ke Surau seperti Bilal/Faris (rute Manhattan yang sama + teleport ala GTA di pintu) ke posisi imam (kalimat: "Ayo sholat berjamaah — saya jadi imam."); pose qiyam/ruku sama seperti jamaah (sujud TIDAK dibuat); sesi habis Kyai pulang ke serambi via plaza (0,2) lalu kembali mode `diam`. Mode `diam` di `_process` dicek SETELAH `_mode_sholat`, jadi rute sholat mengambil alih mode diam; `selesai_sholat()` mengembalikannya. Banner + IKUT SHOLAT tidak berubah (pemain tetap Sajadah_03); Kyai tetap di peta (posisi ikut berpindah). Tes **49/49** (geometri imam + sesi Dzuhur 12.00→12.30: Kyai di posisi imam 0,35 m + hadap kiblat, pemain ikut Sajadah_03, Kyai pulang ke serambi 0,34 m + kembali mode diam + regresi), smoke 600f 0 error (sesi Dzuhur aktif), 4 foto bukti di foto-ronde16/ (01 retake dari belakang saf — saf lengkap qiyam, Kyai di depan; 01b kamera BEBAS dari sisi mihrab — wajah Kyai jelas: serban + jenggot + kumis + lengan bersedekap, Tes–Faris–Bilal di belakangnya qiyam; 02 retake dari samping — barisan + mihrab di tengah dinding + smartboard bersih; 03 retake 2× — Kyai kembali di serambi, pintu + plakat di belakangnya). Jujur: foto 01 pertama gagal komposisi (skrip hanya menunggu Kyai — Bilal/Faris belum sampai; pelajaran: foto berjamaah tunggu ketiganya pose + jendela qiyam bersama); kamera pemain selalu menarget pemain sehingga Kyai tertutup sebagian dari belakang (solusi foto: kamera bebas — batasan kamera foto, bukan game); Kyai belum bisa diajak bicara. Export pck 1.004.512 byte sha256 `3a972311…` (+432); wasm + index.js tidak berubah, worklet ada; smoke pck 600f 0 error. File tes/foto dihapus sebelum export. **TIDAK deploy** — deploy 15+16 SEKALI, DITAHAN sampai retest browser ronde 10+11+12+13+14 selesai (Damar: salin pck baru + update GODOT_CONFIG 1001536 → 1004512 + cek guard).
- **RONDE 17 SELESAI + EXPORT (Raka, 16 Nov ~09:10 WIB): Audio suasana pesantren** (Mas 08:52 WIB: "perlu ada audio di gamenya.. seperti wirid-wirid, bacaan al-quran, baca nadzom dll. Untuk diluar kegiatan maka kasih sound yg menenangkan.. seperti bunyi burung dll"). Manajer baru `scripts/audio_pesantren.gd`: ambience menurut jam perangkat — 04:00–10:00 burung, 10:00–15:00 angin, 15:00–18:00 burung, 18:00–04:00 jangkrik (crossfade 2,5 dtk, −16 dB); hook kegiatan — sesi sholat → `wirid.ogg`, khataman Amtsilah → `nadzom.ogg`, khataman lain → `quran_khataman.ogg` (bila filenya ada; ambience di-duck −30 dB, kembali normal saat sesi habis); **slot bacaan SENGAJA KOSONG** (tidak ada suara palsu — bila file belum ada, ambience biasa tetap jalan tanpa error); tombol mute "Suara"/"Senyap" di HUD kanan-atas (teks saja, tanpa emoji) + status tersimpan (`suara_mati` di save); autoplay web — audio baru mulai pada gestur pertama (`_input` main.gd). Loop ambience CC0 dari Openverse/Freesound (burung 456766, angin 181801, jangkrik 453862; mono 22050 Hz Vorbis q0, loudnorm −24 LUFS, loop mulus 4 dtk crossfade; total 487.316 byte). Tes **55/55 LOLOS, 1 LEWAT** (pemetaan jam/kitab, crossfade, ducking, fallback slot kosong, kontrol positif wirid sementara, tombol Suara + save, smoke 600f sesi Dzuhur), 3 foto bukti di foto-ronde17/ (01 pagi — langit biru + tombol Suara; 02 malam — bintang + lampu menyala; 03 pagi setelah ditekan — label "Senyap"). Jujur: bacaan masih kosong menunggu keputusan Mas — referensi Zahra: Al-Fatihah Alafasy 47 dtk lisensi BERSIH non-komersial (kandidat `quran_khataman.ogg`, tapi akan me-loop selama sesi 60 mnt + perlu downmix mono; harus diganti kalau game komersial), Ratib + Nadzom Ajurumiyyah lisensi TIDAK JELAS (hanya didengar); audio BELUM teruji di browser sungguhan (headless Dummy membuktikan logika saja — bunyi nyata perlu retest browser + HP Mas); foto run pertama gagal karena `_foto()` tanpa `await` (coroutine fire-and-forget — pelajaran: coroutine foto HARUS di-await; retake sudah benar); pck membesar 1.004.512 → 1.541.540 byte (+537.028, +53% — tapi hanya +1,3% dari total unduhan karena wasm 39,5 MB). Export pck 1.541.540 byte sha256 `5357170d…`; wasm + index.js tidak berubah, worklet ada; smoke pck 30 dtk 0 SCRIPT ERROR. File tes/foto + wirid.ogg sementara dihapus sebelum export. **TIDAK deploy** — deploy 15+16+17 SEKALI, DITAHAN sampai retest browser ronde 10+11+12+13+14 selesai (Damar: salin pck baru + update GODOT_CONFIG 1004512 → 1541540 + cek guard).
- **RONDE 18 SELESAI + EXPORT (Raka, 16 Nov ~12:33 WIB): Skema sholat sinematik — takbir → blackout → selesai** (Mas 12:09 WIB: "Sholat 1 menit aja.. terus sholatnya kok cuma takbir sama rukuk aja? Tidak sesuai sholat pada umumnya.." — rencana awal rangkaian 1 rakaat lengkap 60 dtk + sujud WAJIB; **Mas 12:14 WIB membatalkan: "adegan sholat cukup diambil pas TAKBIR saja, lalu BLACK OUT, lalu selesai sholat"** — sujud TIDAK dibuat sama sekali). Durasi sesi 10 menit → 1 menit (`WAKTU_SHOLAT` semua `durasi_menit: 1`; jam mulai tetap 04:30/12:00/15:00/18:00/19:00). Mesin adegan baru di `main.gd` (`_sholat_adegan` + `_proses_adegan_sholat`, timer waktu game): "kumpul" (NPC jalan ke Surau, banner IKUT SHOLAT tampil; takbir mulai kalau semua NPC di sajadah atau timeout 25 dtk) → "takbir" (semua di sajadah, tangan terangkat, tahan 4,0 dtk; banner disembunyikan = ikut ditutup) → "gelap" (fade out 0,5 dtk, tahan hitam 2,5 dtk, teks "Sholat berjamaah...") → "selesai" (NPC pulang, pemain berdiri, fade masuk 0,8 dtk). Pose takbir STATIS (lengan −2.6, siku −0.6) menggantikan siklus qiyam 5 dtk ↔ ruku 3 dtk ronde 13 (`player.gd` + `npc.gd`; `_sholat_t` dihapus). Overlay blackout baru di `ui.gd` (full-rect, dibangun terakhir = paling atas, `mouse_filter` IGNORE; API show/set_alpha/hide/is_visible/get_alpha). Guard: ikut hanya saat "kumpul"; Reset Posisi hanya menampilkan lagi banner saat "kumpul". **Dua bug ditemukan + diperbaiki:** (a) sesi akan jalan 2× dalam 1 jendela (adegan ±30 dtk selesai sebelum jendela 1 menit habis → sesi langsung mulai lagi) — kunci anti-ulang `_sholat_sudah` (nama + jam + tanggal) di `_akhiri_sholat`/`_cek_waktu_sholat`; (b) NPC melompati waypoint lalu berosilasi tak pernah sampai (langkah `SPEED × delta` tanpa batas; ketahuan dari foto pertama — Bilal masih di dekat meja saat timeout) — langkah dijepit `minf(SPEED × delta, jarak)` di `_langkah_ke` + jalan bebas (juga tahan lag spike HP lambat). Tes **65/65** (durasi + batas jendela, sesi Dzuhur penuh kumpul→takbir→gelap→selesai + anti-ulang, abort jam saat kumpul [Ashar] + saat takbir [Maghrib, pemain ikut], regresi imam/sajadah/audio/Suara, unit langkah dijepit delta 10 dtk, smoke 600f), 3 foto bukti di foto-ronde18/ (01 takbir berempat tangan terangkat — Bilal ~60% di frame kiri-bawah; 02 blackout hitam + teks; 03 toast "Sholat Dzuhur selesai." + Kyai pulang). Jujur: adegan BELUM teruji di browser sungguhan (headless membuktikan logika saja); timeout kumpul 25 dtk tetap sebagai jaring pengaman; label "TERKUNCI" M2 masih melayang; waktu sholat masih jam tetap (bukan hisab); portrait belum teruji. Export pck 1.544.020 byte sha256 `d086954d…` (+2.480); wasm + index.js tidak berubah, worklet ada; smoke pck 30 dtk 0 SCRIPT ERROR. File tes/foto dihapus sebelum export. **TIDAK deploy** — deploy 15+16+17+18 SEKALI, DITAHAN sampai retest browser ronde 10+11+12+13+14 selesai (Damar: salin pck baru + update GODOT_CONFIG 1541540 → 1544020 + cek guard).

- **RONDE 19 SELESAI + EXPORT (Raka, 16 Nov ~13:00 WIB): Investigasi + perbaikan sarung biru gagal live ke-3×** (retest browser ronde 10–14: klik sarung "Biru" 2× + "Coklat" tidak mengubah apa-apa — centang tetap di Zamrud, karakter tetap hijau; baris Kulit + Kacamata normal). **Diselesaikan sebagai penyebab:** kode panel seragam semua baris; rantai sinyal utuh; handler klik-di-luar di `_unhandled_input` tidak bisa memakan klik tombol; `main._input` hanya membuka audio; tidak ada overlay di atas baris sarung; geometri terukur di ukuran browser live (1920×998, skala 1.386) — semua tombol di dalam rect panel, visible, tidak disabled. **Tes repro** (test_repro_sarung.gd/.tscn, salinan akhir /tmp): jebakan harness — mode `-s` membuat jendela 100×100 dan `--resolution` diabaikan (jalankan sebagai SCENE); skala "expand" = 1.386 (bukan 1.5 — rasio terkecil, visible rect 1385×720); posisi klik event = koordinat WINDOW (tengah rect kanvas × skala). **Klik bersih: SEMUA LOLOS** (38/38 — Biru 2×, Coklat, Gelap, Pakai, Biru Muda, Hitam) — kegagalan live TIDAK bisa direproduksi dengan klik bersih. **Mekanisme TERBUKTI:** tekan di tengah tombol → geser mouse 120 px (dengan InputEventMouseMotion) → lepas di luar tombol = tombol mode RELEASE TIDAK menyala (sinyal 7->7, centang tidak pindah) — PERSIS gejala live; bukti harness browser memang menggeser mouse saat menahan tombol (receipt retest: drag 480 px + tahan-klik 17 detik). **Perbaikan** (satu-satunya perubahan kode, scripts/ui.gd): semua tombol swatch + kacamata di `_build_outfit_panel` kini `action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS` — pilihan menyala SAAT TEKAN, kebal terhadap posisi lepas; tombol X tetap RELEASE. **Verifikasi:** tes repro **42/42** (termasuk kasus seret yang kini diassert dan lolos); `--import` 0; `--check-only` ui.gd OK; smoke 600f 0 error; 3 foto bukti di foto-ronde19/ (01 panel sebelum — ✓ Zamrud; 02 panel sesudah klik Biru — ✓ Biru; 03 close-up karakter depan — sarung BIRU batik parang + titik emas, jelas biru). Save lokal dikembalikan ke default sesudah tes. Export pck 1.544.260 byte sha256 `3b117b5b…` (+240); wasm + index.js tidak berubah, worklet ada. File tes/foto dihapus sebelum export. **TIDAK deploy** — deploy setelah verifikasi (Damar: salin pck baru + update GODOT_CONFIG 1544020 → 1544260 + cek guard). **Jujur:** akar masalah di browser live TIDAK diamati langsung (Chromium VM tidak bisa start) — mekanisme seret adalah penjelasan paling masuk akal, BUKAN kepastian; **retest browser live tetap dibutuhkan** (klik Biru + Coklat di build baru + cek console `[RONDE8]` bila bisa dibuka). Observasi kosmetik (sudah ada, tidak diperbaiki): tombol swatch yang di-hover tampil ABU-ABU (stylebox hover/pressed tidak di-override).

- **PERBAIKAN JALAN + LAMPU SURAU SELESAI + EXPORT (Raka, 16 Nov ~11:28 WIB):** Mas 12:36 WIB: "Suraunya aneh.. karena miring akhirnya jalannya ga lurus terus ada lampu yg mengganggu" — keputusan Mas 12:38 WIB: **"Tetap miring — perbaiki jalan + pindah lampu"** (Surau TETAP miring −25°, mihrab tetap rata dinding). **Lampu (-2.2,-6) → (-6.5,-7.5)** (sisi barat serambi): 4,39 m dari pintu (dulu 1,47), 3,99 m dari sumbu jalan (dulu 0,54), 4,00 m dari titik keluar NPC (dulu 0,56), 3,19 m dari Kyai, 1,83 m di luar dinding selatan; jumlah lampu tetap 8. **Jalan pasir diluruskan** — segmen ronde 14 (-1.0,-6.5) dihapus, diganti SATU box "JalanSurau" 2,5×0,06×8,5 m di (-3.91,0.03,-3.62), rotasi -25° (= rotasi Surau, tegak lurus pintu): ujung di pintu (-2.11,-7.47), ujung lain (-5.71,0.23) di lajur jalan E-W (normal pintu memotong jalan E-W di (-5.60,0), BUKAN jalan N-S). Pintu/bangunan/rotasi/rute NPC/Kyai/menara/M1/peta TIDAK disentuh. **Tes 33/33 LOLOS** (rute NPC dari 5 titik awal berakhir di titik keluar; titik keluar di atas jalan baru; pemain masuk + keluar lewat jalan lurus; smoke 600f 0 error; satu ERROR ERR_CANT_OPEN di awal = VM tanpa soundcard, bukan bug game). **5 foto bukti di foto-jalan-lampu/** (01 lebar, 02 pendekatan, 03 retake pintu+lampu, 04 dari pintu, 05 Kyai di tepi jalan — kaki di rumput, tanpa clipping; Kyai 1,31 m dari sumbu jalan, tepi jalan ~6 cm dari kakinya). Insiden: /tmp terhapus di tengah retake (VM restart — log tes hilang, hasil sudah tercatat); retake pertama gagal karena skrip ditulis `extends SceneTree` (asli `extends Node`) + path/login salah → error + proses menggantung ~7 jam sampai dimatikan; diperbaiki dengan menyalin pola foto_jalan_lampu.gd persis, retake kedua selesai 18 dtk. Export pck 1.544.388 byte sha256 `0897b366…` (+128 dari ronde 19); wasm + index.js tidak berubah, worklet ada; guard script export segar 2/2 (3/3 berlaku di staging setelah patch wasm-fetch Damar); smoke pck 600f 0 error. Skrip tes/foto dipindah ke perbaikan-jalan-lampu/skrip/. **TIDAK deploy** — menunggu Damar. Status lengkap: PERBAIKAN-JALAN-LAMPU-STATUS.md.

- **RONDE 20 SELESAI + EXPORT (Raka, 16 Nov ~19:35 WIB): Dunia Putri + perilaku ustadz/ustadzah + bubble tanpa outline.** (A) **Musholla Ar-Raudhah (مصلى الروضة)** terpisah di (18,−24), eksterior 10×8 m miring −25° (kubah emas + menara kecil (15.35,−29.20) + plakat Arab di atas pintu selatan (16.31,−20.37) + jalan pasir 2.5×22 m ke jalan E-W); interior 14×10 m di (60,0,−301) diputar −25° mengelilingi pintu (60,0,−296) — file baru `scripts/interior_musholla.gd` (class_name InteriorMusholla): 15 sajadah 3×5, **mihrab di dinding BARAT (kiblat 295°)**, smartboard 3.0 m dinding barat utara (M2 putri), 1 rak kitab (3 kitab), 1 meja sampar, 2 lampu hangat, label KELUAR, 4 pilar. **⚠️ FLAG UNTUK MAS: brief + roadmap menulis mihrab di dinding UTARA, tapi aturan kiblat game (koreksi Mas ronde 10/12/14) adalah 295° = dinding BARAT (utara = 65° melenceng; barat = 25°, sama seperti Surau) — diimplementasikan barat, perlu konfirmasi Mas.** (B) **Pagar** polyline (0,−60)→(0,−17.5)→(9,−17.5)→(9,−4)→(0,−4)→(0,16) membelok mengikuti dinding timur Surau; visual tiang ~4 m + rel y=1.1; barrier 6 StaticBody termasuk melintasi gerbang (gerbang hanya bukaan visual). **Gerbang (0,0)**: bukaan 4 m + 2 pilar batu (0,±2) + balok + atap piramida + label GERBANG. **Pos satpam 3×3 m di (3,3)** menghadap gerbang + **satpam NPC** (tidak ikut sholat, tidak patroli, tetap di pos). **4 pos jaga 3×3 m + 1 lampu** di (±40,−35) + (±40,80). Peta besar + minimap menampilkan musholla/pagar/gerbang ("GERBANG BATAS")/pos jaga/satpam. Papan selamat datang: **TIDAK digeser — sudah dihapus ronde 6** (brief no-op). (C) **Ustadzah Mariyah** (NPC baru): hijab zamrud gelap #065f46 (kubah + tirai belakang + cape bahu), gamis krem #e8dcc0, rok gamis zamrud #0b6b4f, kulit sawo matang, tanpa kacamata/jenggot; kunci outfit baru `hijab`/`hijab_warna` di `player.gd build_visual` (panel Ganti Baju TIDAK menawarkan hijab). **Patroli** (state machine `npc.gd`): duduk bersila baca kitab (kitab pangku terlihat, timer 45–90 dtk) → ke_pintu_dalam → teleport keluar → patroli rute luar → ke_pintu_luar → teleport masuk → ke_kursi → duduk; Kyai kursi Surau (samping MejaSampar_3, hadap kiblat) rute putra/plaza, Ustadzah kursi Musholla rute putri [(20,−10),(24,0),(20,8),(12,12)]; sholat meng-override patroli (`_mode_sholat` dicek paling dulu); sesudah sholat keduanya kembali ke kursi. **Sholat putri:** Ustadzah imam di Musholla (depan Sajadah_03); Kyai tetap imam Surau; satpam tidak ikut. (D) **Pakem batas:** barrier tak terlihat + toast "Santri putra tidak boleh masuk area putri." (jarak <1.5 m, throttle ~4 dtk); Bilal spawn (4,0,4)→(−4,0,4), waypoint difilter (14 dipertahankan, 7 dibuang); rute sholat koridor x=−12→−20, plaza (0,2)→(−2,2). **Konsekuensi pakem yang tidak tertulis di brief tapi wajib:** spawn pemain (0,0,14)→(−4,0,14) (tepat di garis pagar); **peti M3** (6,10)→(0,0,26) zona bersama; **Cangkruk** (14,−14)→(−12,−12); Cangkruk Putri (12,−12) TIDAK dibangun (belum ada pemain santriwati). (E) **Bubble tanpa outline (Mas 19:09 WIB, IKUT ronde ini):** `player.gd:613` bubble kini `tanpa_outline=true` → `outline_size = 0` (sebelumnya 8 putih di atas teks hijau gelap — itu yang bikin kolot); font tetap Baloo 2 Bold; satu perubahan memperbaiki pemain + semua NPC. **Bug ditemukan + diperbaiki:** (1) **NPC TIDAK TERLIHAT** — `npc.gd` `_kitab_pangku: MeshInstance3D` padahal `player.gd _kitab()` mengembalikan Node3D (wadah sejak Ronde 9) → penugasan gagal menggagalkan `setup()` di tengah (add_child(_visual) tak jalan, patroli tak jalan) — diperbaiki ke Node3D; **pertanyaan terbuka: apakah NPC sudah tak terlihat sejak Ronde 9?** retest live ronde 10–14 cek posisi/fase, bukan visibilitas — perlu dicek di build live. (2) `ke_dunia` musholla memutar +25° (salah arah) → diperbaiki −25° (normal dinding barat 295°, persis Surau); spawn musholla → (60.63,−297.36), kursi Ustadzah → (68.88,−301.79). (3) Nama duplikat BarrierPagar/PosJaga → berindeks _1..6/_1..4. (4) `_npc_rumah` Ustadzah default ke spawn putra → diisi di `_spawn_npcs` (Kyai serambi, Ustadzah (18,−16)). (5) Detour 300 m sesudah sholat → bila jarak ke kursi <3 m langsung "ke_kursi". (6) Patroli macet `npc.gd:402` (Array tak bertipe → Array[Vector3]) → `.assign()`. (7) Palette khayalan di interior_musholla (SAJADAH_IJO/HIJAU/BIRU/ORANYE/KUNING_LAMPU/KREM_PUTIH) → nilai yang ada. **Verifikasi:** tes headless `test_ronde20.gd` **104 LOLOS / 0 GAGAL, EXIT=0** (log /tmp/tes-ronde20d.log), 0 SCRIPT ERROR / 0 ERROR (run 1 gagal parse; run 2: 77/16 bug #1 dominan; run 3: 96/8 bug #6 + timeout kumpul; run 4: 103/1 tunggu kembali-duduk 3000→9000 frame; run 5: 104/0); bubble outline_size==0 + warna #065f46 + font Baloo 2 Bold LOLOS; **9 foto bukti** di foto-ronde20/ (01 eksterior menara, 01b pintu+plakat, 02 interior sajadah+mihrab+smartboard, 03 gerbang+satpam, 04 pos jaga, 05 Ustadzah duduk, 06 Kyai duduk, 07 toast batas, 08 bubble tanpa outline — 02+08 retake: 02 sudut tenggara, 08 Bilal dibekukan + say() tepat sebelum jepret + kamera rendah berlatar langit). **Export `export/web/`:** pck BARU 1.572.616 byte sha256 `c8b87483…` (+28.228); wasm TIDAK berubah (`fc74679e…`); index.js TIDAK berubah (`33c94cb3…`); worklet 2.973 byte ada; guard 2/2 (3/3 di staging setelah patch Damar); smoke pck 600f 0 error. Skrip tes/foto di `ronde-20/skrip/`. **TIDAK deploy** — menunggu Damar (salin pck + GODOT_CONFIG 1544388 → 1572616 + cek guard). **Jujur:** retest browser live MASIH dibutuhkan (musholla masuk/keluar, pagar+toast, NPC terlihat duduk, patroli, sholat putri, bubble); pohon (−20,−26) di koridor patroli Kyai (klip visual singkat, NPC abaikan collision); pagar memotong plakat Masjid Besar (sudah digeser 3 m ke barat); jalan musholla digeser ke x=24 saat Kelas Putri dibangun.

- **SUSULAN RONDE 20 — POHON PINDAH + PERBAIKAN NaN IDLE + EXPORT (Raka, 16 Nov ~13:23 WIB):** Pohon (22,−22) berdiri DI DALAM Musholla Ar-Raudhah (rect terputar −25°: lokal (22.47,−23.88), jarak dinding 0, tajuk menembus 1,15 m — foto 01) → **dipindah ke (22,−32)**: batang 4,94 m dari dinding utara (tajuk 3,79 m), 11,69 m dari tepi JalanMusholla, 16,49 m dari rute patroli Ustadzah (kandidat (26,−22) ditolak: batang cuma 3,10 m). **Tes pohon 6/6** (61 pohon dipindai di dunia); foto ulang sudut sama `01-musholla-eksterior-pindah-pohon.png` — dinding timur bersih. **Bug NaN ditemukan saat verifikasi:** tes lengkap 104/104 TAPI 28.590 ERROR `!v.is_finite()` sejak seksi F — `_animate_idle` npc.gd + lerp jalan/idle player.gd pakai bobot mentah `delta*8/10` tanpa jepit → di frame lambat bobot >1 membuat lerp divergen sampai −inf (probe: Satpam visual.pos=(0,−inf,0) frame 60; run 5 lolos karena kebetulan tidak kena frame lambat; BUKAN disebabkan pindah pohon). **Perbaikan:** jepit bobot `minf(1.0, ...)` (idiom yang sudah dipakai file itu + yaw pemain Ronde 5) — npc.gd 5 lerp + player.gd 7 lerp. **Verifikasi ulang:** probe 600 frame 0 NaN; tes lengkap **104/104, 0 is_finite, 0 SCRIPT ERROR, 0 ERROR non-audio**; tes pohon 6/6. Export pck **1.572.776 byte sha256 `212d995c…`** (+160); wasm + index.js tidak berubah, worklet ada; guard 2/2. Skrip susulan di `ronde-20/skrip-susulan-pohon/`. **TIDAK deploy** — menunggu Damar (GODOT_CONFIG 1572616 → 1572776). **TIDAK disentuh:** mihrab (tetap barat); posisi musholla (relokasi (62,−24) = Ronde 21 setelah deploy ini); kostum Ustadzah (abaya+jilbab antre sesudah ini).

- **SUSULAN RONDE 20 — KOSTUM USTADZAH ABAYA + JILBAB + EXPORT (Raka, 16 Nov ~20:24–20:45 WIB):** Mas 19:42 WIB: kostum Ustadzah lama (koko putih/krem + sarung batik zamrud + penutup kepala seperti songkok) "malah kek ustadz" → **ganti abaya + jilbab**. Abaya: satu gamis panjang longgar bahu→mata kaki (r 0.23→0.36, tinggi 1,32 m, bawah y=0.10), zamrud gelap #065f46 polos TANPA motif batik + lis emas; torso + lengan panjang sewarna; TANPA kerah/kancing. Jilbab krem #f2ead6, 6 bagian (kubah + drape belakang + cape bahu + drape depan + 2 strip sisi); tepi kubah di atas alis, mata tetap di depan kain. **Target pakaian sendiri** `PAKAIAN_ABAYA_DEFAULT/DUDUK` (pemetaan di `npc.gd _terapkan_pakaian`): abaya duduk MELEBAR 1.55 + memendek 0.78, hem ~0,04 m di atas lantai, kaki bersila tertutup (PAKAIAN_DUDUK sarung akan menghancurkan gamis). `OUTFIT_USTADZAH` baru + kunci `abaya`/`muslimah` (node "Abaya" baru; "Hijab" dipertahankan). Perilaku TIDAK berubah (duduk baca + patroli + imam putri); kitab pangku tetap. **Dua bug visual dari foto diperbaiki:** (1) cape lama tenggelam di balik abaya duduk → cape diperbesar r=0.40 + abaya duduk direndahkan; (2) drape depan lama tenggelam di dalam abaya (hanya tepi mencuat = dua bilah suspender) → panel pindah z=0.28 + miring -0.10. **Verifikasi:** tes lengkap **110/110, 0 ERROR / 0 SCRIPT ERROR / 0 is_finite** (104 lama + 6 baru; 3 asersi hijab diperbarui), smoke 600f; foto baru `05b/05c/05d-ustadzah-abaya-*.png` (05 lama tidak ditimpa) — siluet abaya + jilbab terbaca jelas, beda dari Kyai dan santriwan. Insiden: foto `--headless` gagal 3/3 (`save_png` null — foto harus tanpa --headless); foto 05d pertama salah hadap (rotation.y=0 = selatan; diperbaiki PI). Export pck **1.574.232 byte sha256 `8844375f…`** (+1.456); wasm + index.js tidak berubah, worklet ada; guard 2/2; pck bersih (skrip tes/foto dihapus sebelum export). Skrip susulan di `ronde-20/skrip-susulan-kostum/`. **TIDAK deploy** — menunggu Damar (GODOT_CONFIG 1572776 → 1574232). **TIDAK disentuh:** mihrab (tetap barat); musholla (relokasi (62,−24) = Ronde 21 setelah deploy); pagar. **Catatan untuk nanti:** seragam santri putri juga abaya/gamis + jilbab (Mas 19:45 WIB) — konstruksi `muslimah` di `build_visual` sudah bisa dipakai ulang untuk karakter santriwati; warna abaya santriwati vs Ustadzah belum diputuskan (saat ini sama #065f46).

- **SUSULAN RONDE 20 — PERBAIKAN JALAN + LAMPU + EXPORT (Raka, 16 Nov ~21:13–21:36 WIB):** Mas 21:12 WIB menanggapi game live Ronde 20: "Jalan dan lampu dibangun ulang. Yg rapi. Masa ada tiang di tengah jalan." **Audit** (skrip baru, ukur dari dunia yang dibangun): run pertama **89 LOLOS / 43 GAGAL** — **pilar gerbang (0,±2) DI ATAS jalan N-S** + **~20 tiang pagar x=0 DI ATAS jalan N-S** (pagar membelah tengah jalan); tiang pagar (9,−4) DI ATAS JalanMusholla + (9,−8.5) mepet 0,36 m; tiang papan Masjid (−1,−21.4) DI ATAS jalan N-S, papan Perpus (±2,24.6) mepet 0,50 m; pohon (10,−6) DI ATAS JalanMusholla, (−52,2) mepet 0,75 m ke jalan E-W; 7 lampu jalan mepet 0,70 m (x=±2.2, sisi acak); sudut pos satpam menyentuh tepi jalan N-S. **Perbaikan:** **pagar + gerbang + pos satpam PINDAH ke timur x=2.5** (belokan x=9 tetap; gerbang (2.5,0) pilar (2.5,±2) 1,0 m dari tepi jalan N-S; pos satpam (3,3)→(5.5,5); `_cek_batas` → x=2.5; barrier + peta ikut konstanta) — **catatan jujur: brief bilang jangan ubah pagar, tapi pagar di x=0 membuat "tidak ada tiang di atas jalan" mustahil dipenuhi; ini satu-satunya perbaikan geometris, dilaporkan ke Mas lewat Xam.** **Lampu dibangun ulang:** 7 lampu N-S semua sisi barat x=−2.5 (1,0 m dari tepi), z teratur 20 m; lampu JalanSurau (−6.89,−2.67) + lampu JalanMusholla (15.86,−13.96) masing-masing 1,05 m dari tepi jalan; lampu pos jaga/satpam tetap. **JalanMusholla dipendekkan 22 → 12 m** (ujung (11.24,−9.49)) — jalan lama menabrak belokan pagar dan koridor ke plot Kelas hanya 2 m; dipanjangkan lagi saat Ronde 21 memindah plot Kelas ke (58,0). **Papan Masjid + Perpus digeser −5.0** (tiang x=−7/−3); **pohon (10,−6)→(14,−6), (−52,2)→(−52,6)**. Pengecualian didokumentasikan: 2 pilar gerbang + 2 tiang ujung celah gerbang di (2.5,±2) 0,75 m dari tepi jalan E-W (di sudut persimpangan, disengaja). **Verifikasi:** audit ulang **129 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR** (9 jalan, 14 lampu, 29 tiang pagar, 60 pohon, 5 footprint); tes lengkap Ronde 20 **122 LOLOS / 0 GAGAL, EXIT=0, 0 ERROR, 0 NaN** (110 lama + 12 baru seksi G + `_tes_batas` disesuaikan pagar x=2.5), smoke 600f; 5 foto bukti `09/10/11/12/13-*.png` di foto-ronde20/ — tidak ada tiang di tengah jalan mana pun. Skrip di `perbaikan-jalan-lampu-2/skrip/` + `ronde-20/skrip-susulan-kostum/`. Export pck **1.574.360 byte sha256 `8343a6dd…`** (+128); wasm + index.js tidak berubah, worklet ada; guard 2/2. **TIDAK deploy** — menunggu Damar (GODOT_CONFIG 1574232 → 1574360).
- **RONDE 21 SELESAI + EXPORT GABUNGAN (Raka koordinator + Cakra + Sinta + Wulan, 16 Nov ~22:41 WIB):** Surau putra BARU (0,−12) sesuai desain ACC Arsa — luar 20×16 m, interior TETAP 18×14 m; kubah utama zamrud + 4 kubah kecil + bulan sabit emas; 1 menara ramping tenggara **tutup ZAMRUD** (puncak ~14,6 m) di (7.86,−2.82); portal lengkung 7 voussoir emas + pintu jati dua daun TERBUKA; 5 jendela lengkung (3 utara + 2 selatan); serambi 3 m + 3 anak tangga batu; tempat wudu barat laut (−9.22,−21.81); plakat مصلى الإخلاص tetap (sebagian tertutup atap serambi — minor). Pintu pindah ke (−3.38,−4.75), exit (−4.01,−3.39); JalanSurau lama DIHAPUS (ujungnya masuk ke Surau baru). **Tembok pemisah x=14, z −60..+16 (76 m), 3 m × 0,4 m**, krem + lis emas + fondasi batu, collision penuh — **pagar kayu Ronde 20 DIBONGKAR TOTAL**; gerbang satu-satunya bukaan (14,0): bukaan 4 m + 2 pilar (14,±2) + gapura + label GERBANG, **pintu TERTUTUP + barrier collision penuh**; pos satpam (17,5) + satpam NPC; pohon (14,−6)→(18,−6). **Relokasi kampus putri Opsi A (file baru `scripts/kampus_putri.gd`, Cakra):** Musholla Ar-Raudhah (134,−24) 12×10 m, 1 kubah kecil zamrud, TANPA menara, serambi kayu, pagar kayu keliling + taman bunga, mihrab barat, 4 saf, rak kitab utara, pintu selatan (134,−19); Cangkruk Putri (128,−12); Kelas Putri (130,0); Asrama Putri (152,0); Kantor Ustadzah (150,−28); Madrasah (152,−12); Studio (166,−12); spawn putri (130,14); pos jaga TL (160,−35); jalan internal N–S x=142 (49 m) + 8 konektor; Lapangan Putri TETAP (48,62). Jarak Surau→Musholla **134,5 m** (dinding-ke-dinding 118 m). **Aturan keras `_cek_batas` (Sinta, `main.gd`):** putra di (x>14 DAN z<16) → toast + dorong balik ke posisi legal terakhir; cermin santriwati; selatan (z≥16) bersama; pengecualian Pengasuh + musyrif/musyrifah + Keamanan; NPC mengabaikan barrier. **TIDAK ADA flag gender/role pemain di save_data** — Sinta menulis `_pemain_adalah_putri()` + `_pemain_boleh_lewat_batas()` yang aktif sendiri saat registrasi/server menulis kunci `jenis_kelamin`/`role`. Ustadzah pindah: rumah (134,−17), patroli putri, rute ke Musholla (18,−14)→(134,−14). Partisi Masjid Besar DIBATALKAN (utuh putra); Masjid Putri terpisah (kandidat (134,−40)) TIDAK dibangun sekarang. **Perbaikan Ustadzah Kirana ikut di export ini** (lengan terlihat, drape elipsoid, kubah r=0,255, alis — `scripts/player.gd`). **Konflik JUJUR menunggu keputusan Mas (tidak diubah sepihak):** (1) Cangkruk Putra menabrak Surau baru ~5 m (sudut (−7,−16)/(−7,−8) di dalam footprint Surau) — pindah Cangkruk vs perkecil Surau; (2) sudut tenggara Surau (5.68,−0.52) berdiri DI ATAS jalan E-W (~1,6 m dinding selatan); (3) segmen jalan Bilal/Faris masih bisa memotong tembok (waypoint acak, jalan lurus tanpa collision — visual saja, pemain tetap tertahan barrier + aturan keras; routing sadar-segmen = ronde berikutnya). **Verifikasi:** tes `test_ronde21.gd` **181 LOLOS / 0 GAGAL, 0 error, 0 NaN** (tahap 3 Wulan, 4 perbaikan skrip tes — bukan build); audit jalan+lampu **93 LOLOS / 0 GAGAL** (0 tiang pagar, 0 di atas jalan); foto 10/10 di-render ulang (14–23) di foto-ronde20/ — Raka melihat 7/10 langsung. Skrip di `ronde-21/skrip/`. Export pck gabungan **1.590.560 byte sha256 `1a26d99e…`**; wasm + index.js tidak berubah, worklet ada (2.973 byte), guard 2/2. **TIDAK deploy** — menunggu Damar (GODOT_CONFIG 1574360 → 1590560 + cek guard). Retest browser live setelah deploy.

Susulan Ronde 21 (16 Nov ~23:41 WIB, keputusan Mas 22:57 WIB "Pindah Cangkruk + geser Surau ke utara"): Cangkruk Putra (−12,−12) → (−22,−18) (kandidat (−22,−12) ditolak Cakra: pohon (−26,−8) di garis dinding selatan + waypoint NPC (−24,−12) di tengah bentang; jarak min ke Surau 5,41 m); Surau pusat (0,−12) → (0,−14), ukuran TETAP 20×16 m — pintu (−3.38,−6.75), exit (−4.01,−5.39), wudu (−9.22,−23.81), menara (7.86,−4.82), sudut tenggara (5.68,−2.52) 1,27 m dari tepi jalan E-W. PELAJARAN PIVOT: ganti SURAU_PUSAT saja membuat bangunan berayun (pusat (−0.85,−12.19), sudut tetap 0,54 m di jalan — tertangkap tes 186/193); perbaikan: konstanta SURAU_JANGKAR_LOKAL (0,0,−12) + rumus jangkar di surau_pintu() dan _surau. Koridor rute NPC (Sinta): utara z=−22 → −27, barat x=−20 → −28 (garis lama menembus Surau/Cangkruk baru). Waypoint (−24,−12) → (−24,−10) (segmen menyerempet sudut Cangkruk ~0,3 m). Pohon (9,−18) + (−7,−18) → (9,−28) + (−7,−28) (tajuk (9,−18) menembus dinding utara di jendela N3 setelah geseran). KNOWN ISSUE dibiarkan: waypoint (0,−20) di dalam tapak Surau (sudah sejak Surau lama; wilayah konflik #3). Verifikasi: tes 197/197, audit 93/0, foto 11/11. Export pck gabungan 1.590.784 byte sha256 697f736d… (wasm + index.js tidak berubah). TIDAK deploy — menunggu lampu hijau Mas (GODOT_CONFIG → 1590784).

- **RONDE 22 SELESAI + EXPORT (Raka koordinator, 17 Nov ~06:44 WIB):** tembok keliling pondok putri x 115..180, z −52..+22 (krem + lis emas + fondasi batu, 3 m × 0,4 m, collision penuh) + gerbang barat (115,0) pintu TERTUTUP + barrier; jalan akses E-W (14,0)→(115,0) terverifikasi bersih; jalan masuk (115,0)→(115,8)→(142,8) membelok; jalan ke Surau diperbaiki (segmen N-S berakhir bersih: selatan z +1,25..+14 di tepi jalan E-W, utara z −200..−24; stub plot Masjid (0,−19) dihapus, plot pindah (0,−26)→(0,−32)); audit pohon garis tembok (61 pohon, semua ≥1,0 m dari garis); gunung diperbaiki (topi salju putih dihapus, biru #6b7a8a→hijau #5f7055); rute Ustadzah lewat gerbang (115,0); tembok keliling di peta besar + minimap. Tim (perintah Mas 06:23 WIB "Jangan raka semua yg ngerjain"): Cakra `scripts/tembok_putri.gd` (baru), Sinta `scripts/jalan_ronde22.gd` (baru) + main.gd/ui.gd/mission_data.gd, Wulan tes/audit/foto; Raka koordinasi + gunung + merge + export. Tes **259/259**, audit **161/161**, smoke gabungan **33/33**, 0 error, 0 NaN, foto 10/10 (25–34, dilihat Raka; 30 retake; 34 gunung hijau tanpa salju/biru terbaca jelas). Export pck **1.596.276 byte sha256 `df62aa35…`**, wasm + index.js tidak berubah, worklet ada. **TIDAK deploy** — menunggu Damar setelah ACC Mas. Catatan: sisi luar tembok selatan tampak abu-abu gelap di foto 28 (shading, perlu verdict Mas, bukan blocker); 1 pohon (130,−40) di dalam keliling (dikenal, pindah Fase D).

- **LOGIN-GENDER SELESAI + EXPORT (Raka, 17 Nov ~07:15 WIB; Mas 06:55 WIB "daftar by gender belum ada. Saya mau daftar sebagai santriwati pengen cek pondok putri"):** login game ke server kontrak v1.5.1 (Saka, live ~07:00 WIB): form MASUK kini Username Instagram + Kata sandi (opsional) — ganti ID PV-XXXX + nama (`ui.gd`: sinyal `login_submitted(ig_username, password)`, field sandi `secret`, `show_login_error` + `set_login_loading` anti-ketukan ganda); `main.gd`: HTTPRequest POST `/api/santri/login` (timeout 15 dtk) → `_terapkan_login_server()` tulis `id_santri` + `nama` + `ig_username` + `jenis_kelamin` ke save + token sesi hanya di memori; gagal/offline = pesan jelas, save utuh, tidak crash. `save_data.gd`: kunci baru `ig_username`/`jenis_kelamin` (default `"putra"`)/`role` + `normalisasi_ig()` (tanpa ini `load_data()` membuang kunci gender). `_masuk_pesantren()` teleport ke spawn sesuai gender + perbarui jangkar `_pos_legal_terakhir` (tanpa ini santriwati pertama login berdiri di area putra dan didorong balik ke titik salah). X-PV-Token TIDAK dipakai di game. **Tes `test_login_gender.gd` 63/63 LOLOS, 0 GAGAL, 0 SCRIPT ERROR, 0 NaN** (log /tmp/tes_login_gender3.log) — termasuk live lewat klien game: `tes.putri.raka` → PV-0002 putri → spawn (130,14); `tes.putra.raka` → PV-0003 putra → spawn (-4,14); unknown → "tidak ditemukan", save utuh; batas cermin putri live (didorong balik + toast). Akun tes live sudah dihapus dari DB produksi (santri + sesi; ranking kembali total 1, hanya PV-0001). **Regresi Ronde 22: 259/259 LOLOS.** Export pck BARU 1.600.228 byte sha256 `7619033f…` (+3.952); wasm + index.js tidak berubah, worklet ada. **Bug ditemukan + diperbaiki:** (1) `String(null)` crash saat server kembalikan `jenis_kelamin: null` (santri lama) — helper `_str_atau()`; tes pertama sempat lolos palsu karenanya (fungsi abort, nilai lama, `String=null` jadi `""`) — tes null kini cek id ikut berubah. (2) Label galat basi setelah sukses — handler kini hapus galat di awal tiap jawaban. **Jujur:** visual santriwati MASIH santriwan (abaya + jilbab tugas Tim Karakter, warna belum diputuskan Mas); kotak DAFTAR game masih lokal (daftar bergender di app); skrip Ronde 22 pemanggil `_on_login` lama diperbarui ke stub (test/audit/foto/retake); pipeline screenshot video Nara masih mengetik ID + nama (perlu diperbarui saat video lanjut); login browser sungguhan belum teruji (perlu retest setelah deploy). **TIDAK deploy** — Damar setelah ACC Mas (GODOT_CONFIG 1596276 → 1600228 + guard 3/3 + verifikasi hash live). Dokumen: `LOGIN-GENDER-STATUS.md`; skrip tes: `login-gender/skrip/`.

- **SANTRIWATI KOSTUM SELESAI + EXPORT (Kirana, 17 Nov ~07:35 WIB; Mas 07:21 WIB "Abaya dan jilbab warnanya bisa dikostum ganti ketika ganti baju"):** santriwati pemain kini tampil abaya + jilbab (bukan koko) — visual dibangun ulang saat gender putri (`player.gd`: `bangun_ulang_visual()` + `_pasang_visual()` + `apakah_muslimah()` + `_nama` dipertahankan; torso + lengan muslimah sewarna abaya; `terapkan_outfit` warnai ulang Abaya/Hijab di tempat; `main.gd`: `_terapkan_gender_pemain()` di awal `_masuk_pesantren()`, bangun ulang hanya bila flag berubah); warna abaya (Zamrud/Hitam/Navy/Coklat) + jilbab (Krem/Putih/Hitam/Zamrud) dipilih lewat panel Ganti Baju (`ui.gd`: baris Abaya/Jilbab hanya untuk santriwati, Koko/Songkok/Sarung hanya untuk santriwan; kunci save `hijab_warna`, label "Jilbab") + tersimpan di save (`save_data.gd` + `mission_data.gd` OUTFIT_ABAYA/OUTFIT_JILBAB, default = tampilan Ustadzah). Ustadzah TIDAK berubah (OUTFIT_USTADZAH utuh). **Tes `test_santriwati_kostum.gd` 69/69 LOLOS, 0 GAGAL, 0 SCRIPT ERROR, 0 NaN** (log /tmp/tes_santriwati_kostum2.log) — build muslimah/santriwan, ganti gender live (putri → spawn 130,14, putra → −4,14, nama dipertahankan), baris panel per gender, ganti warna lewat swatch panel → save + visual + tanda ✓, persistensi load_data, Ustadzah tetap (statik + live). **Regresi Ronde 22: 259/259 LOLOS.** Foto 5/5 (35–39, dilihat Kirana): 3 kombinasi warna + panel Ganti Baju + close-up depan (jilbab krem + wajah + abaya zamrud + lis emas). Export pck BARU **1.602.820 byte sha256 `e02f3c28…`** (+2.592); wasm + index.js tidak berubah, worklet ada; file tes/foto tidak ada di pck. **TIDAK deploy** — Damar setelah ACC Mas (GODOT_CONFIG 1600228 → 1602820 + guard 3/3 + verifikasi hash live). Dokumen: `SANTRIWATI-KOSTUM-STATUS.md`; skrip tes/foto: `santriwati-kostum/skrip/`.
