# ULASAN KELAYAKAN — Revisi Draf Alur Misi v2 (5 Arahan Mas, 13:30 WIB)

**Dari:** Raka (game) — untuk Laras (lead Tim Alur Misi)
**Tanggal:** 18 November 2026, ~13:35 WIB
**Status:** LAPORAN KELAYAKAN SAJA. Tidak ada file game yang diubah — hanya baca kode.
**Dasar:** `v2/konsep/DRAF-ALUR-MISI.md` v1 (§8 kelayakan + §9) + pengecekan kode 18 Nov 2026:
`v2/godot-dunia/scripts/{main,mission_data,ui,save_data,player}.gd`,
`scripts/multiplayer/{room_config,network_manager}.gd`, `server/server.py`,
`MULTIPLAYER-FASE2-SPEC.md`, `pesantren_builder.gd`.

---

## Ringkasan eksekutif

| # | Arahan Mas | Usaha | Fase | Prasyarat kunci |
|---|---|---|---|---|
| 1 | Gerbang "baca kitab kuning" di ujung Nahwu Dasar | **SEDANG** | A (mesin) → B (penegakan) | Mesin tes 10 soal + konten Bagian 4 + jalur poin→server |
| 2 | Level + gelar ala Mobile Legends per misi | **SEDANG** | A (lokal) → B (server) | Jalur poin game→server (risiko 1 draf v1) |
| 3 | Kuis mingguan + challenge antar player | **BESAR** | B (serentak) → C (duel) | Jam server + chat teks + multiplayer stabil + jalur poin |
| 4 | Event Bahtsul Masail antar santri | **SEDANG–BESAR** | C (sosial) | Chat teks + jam server + penilaian ustadz/musyrif |
| 5 | Game olahraga (sepak bola dll) | **BESAR** (terbesar dari 5 butir) | **D — baru** | Lapangan + fisika bola + sinkronisasi multiplayer + tim |

**Satu kalimat:** butir 1–2 bisa mulai di Fase A dengan fondasi yang sudah ada; butir 3–4 menunggu Fase B/C selesai; butir 5 adalah satu game di dalam game — jangan dijadwalkan sebelum multiplayer Fase 1 lolos T1 dan cap 50 teruji.

---

## Butir 1 — Ujung rantai Nahwu Dasar: BISA BACA + TERJEMAH + PAHAM KITAB KUNING

**Maksud Mas:** santri baru menyelesaikan misi Nahwu Dasar sampai bisa baca + terjemah + paham kitab kuning; ada misi/tes "baca kitab kuning" sebagai gerbang kelulusan Jenjang 0 (bukan sekadar lulus tes pilihan ganda Bagian 4).

### (a) Yang SUDAH ADA dan bisa dipakai ulang

- **Tes naik bagian N4.T sudah dirancang di draf v1** (§2.1: kuis 10 soal, lulus bila benar ≥8, 20 poin, lokasi di dalam Surau/Musholla) — tinggal dijadikan gerbang, bukan sekadar tes biasa.
- **Reader kitab Tara sudah live** (5 kitab, 184 bab, semua `dicek_ustadz`) + endpoint `GET /api/kitab` — kitab kuning sungguhan (Jurumiyah, Safinatun Naja, dll) sudah bisa dibaca di dalam game; tes "baca kitab kuning" bisa memakai teks kitab yang sama, bukan konten baru.
- **Pola syarat lokasi sudah ada** (`main.gd`: syarat lokasi surau/peti sebelum kuis) — gerbang bisa dikunci ke lokasi Surau/Musholla seperti tes lain.
- **Peti Oranye Bagian 4 + badge "Nahwu Dasar Lulus"** sudah dirancang di v1 — gerbang ini tinggal dipasang di antara N4.6 dan badge.

### (b) Yang BARU dan harus dibangun

- **Mesin tes "baca kitab" — bukan kuis pilihan ganda biasa.** "Bisa baca + terjemah + paham" itu tiga keterampilan, bukan satu soal:
  1. *Baca:* tampilkan 1–2 baris teks kitab kuning (Arab gundul, dari reader) — santri membaca; validasi otomatis paling banter cek harakat/i'rob lewat pilihan ganda ("kalimat ini marfu'/manshub/majrur karena…").
  2. *Terjemah:* pilih terjemahan yang benar dari 4 opsi (atau susun kata terjemahan).
  3. *Paham:* 2–3 soal isi (apa hukum/isi kalimat ini?).
  Jadi formatnya: **tes gabungan 3 tahap dalam satu sesi**, bukan 10 soal sejenis. Mesin kuis sekarang hanya 1 soal per misi (`mission_data.gd`: `"kuis"` + `"jawaban"` indeks tunggal) — mesin multi-soal saja belum ada, apalagi multi-tahap.
- **Bank soal baca kitab** (konten): potongan kitab + kunci i'rob + terjemahan + soal paham — harus disusun Laras/Zahra dari kitab yang sudah `dicek_ustadz`. Ini konten, bukan kode.
- **Font Arab di proyek belum diverifikasi ada/tidak** (catatan v1 §8.2) — teks Arab gundul di tes WAJIB dicek dulu; kalau font tidak ada, tes ini tidak bisa tampil benar di HP.
- **Gating kelulusan Jenjang 0** diperketat: lulus = 4 Bagian + tes gerbang ini + Ma'hadiyah ≥5/7 selama 4 minggu (syarat Ma'hadiyah baru bisa ditegakkan di Fase B, lihat risiko).

### (c) Usaha: SEDANG

Alasan: mesin kuis multi-soal + tes 10 soal memang sudah masuk Fase A v1 (usaha sedang–besar untuk 27 misi). Tambahan butir 1 di atasnya hanya **satu format tes baru (3 tahap) + satu bank soal**, bukan sistem baru. Yang membuatnya tidak "kecil": validasi "bisa baca" yang jujur tidak bisa 100% otomatis — pilihan ganda hanya menguji *pengenalan*, bukan *kemampuan membaca*. Kalau Mas mau validasi sungguhan, perlu setoran ke ustadz (rekam suara / dinilai musyrif) — itu BESAR dan saya sarankan ditunda.

### (d) Prasyarat

1. Mesin kuis multi-soal + ambang lulus ≥8 (Fase A v1).
2. Konten Bagian 4 selesai + 4 kaidah "perlu dicek ustadz" dikunci (konten Bagian 2–4 masih terblokir — risiko 2 v1).
3. Font Arab diverifikasi di proyek.
4. Jalur poin game→server (Fase B) — kalau gerbang kelulusan harus tercatat di server/ranking; kalau lokal dulu, gerbang bisa jalan di Fase A tanpa server.

### (e) Fase: A (mesin + tes lokal) → B (penegakan kelulusan di server)

### ⚠️ Risiko terbesar

**Validasi palsu.** Kalau tes "baca kitab kuning" hanya pilihan ganda, santri bisa lulus dengan menebak tanpa benar-benar bisa baca — gerbang kelulusan jadi formalitas. Jujur: tanpa setoran lisan ke ustadz/musyrif, game hanya bisa menguji *pengenalan* i'rob dan terjemahan, bukan kemampuan membaca. Keputusan yang perlu Laras ajukan ke Mas nanti: apakah gerbang ini cukup diuji otomatis (cepat, tapi longgar), atau ada setoran suara/dinilai manusia (jujur, tapi butuh sistem penilaian — BESAR, Fase C).

---

## Butir 2 — Tiap misi dibagi LEVEL GAME + GELAR ala Mobile Legends

**Maksud Mas:** tiap misi punya beberapa level game; tiap user punya GELAR seperti di ML (tier + sub-level); gelar naik dengan poin + lulus tes + kehadiran; gelar tampil di Kartu Santri + label nama.

### (a) Yang SUDAH ADA dan bisa dipakai ulang

- **Sistem tier poin SUDAH ADA di dua tempat, sinkron:** `save_data.gd` `tier_for_points()` (lokal) dan `server.py` `tier_for_points()` (server) — ambang sama: ≥25 Penjelajah · ≥50 Pembuka Peti · ≥100 Penjaga Lentera. Tampil di dashboard Kartu Santri (`ui.gd:3581`: `"Tier: " + tier`). Ini kerangka gelar yang tinggal diperluas, bukan dibangun dari nol.
- **Server sudah punya `GET /api/ranking`** (leaderboard global + tier per santri) — gelar berbasis poin server sudah bisa ditampilkan di mana saja.
- **Kartu Santri (dashboard) sudah ada** (`ui.gd`: tombol "Kartu Santri", panel dashboard, Ma'hadiyah 7 checklist + streak) — tempat gelar + progres level ditampilkan sudah tersedia.
- **Label nama sudah ada** (`player.gd`: `Label3D` via `Palette.label_nama`, y≈2.05–2.12; nama tampil selalu per keputusan Mas 13:19) — gelar tinggal ditempel di bawah/di samping nama, pola yang sama.
- **Poin per misi sudah ada** (M1=10/M2=15/M3=25, skema kurikulum §5: materi 10 / latihan 15 / hafalan 10 / peti 25 / tes 20) — bahan bakar level sudah tersedia.

### (b) Yang BARU dan harus dibangun

- **Sub-level di dalam tiap tier (ala ML: Bronze I–III, Silver I–III, dst).** Sekarang hanya 3 tier kasar tanpa sub-level. Perlu diputuskan: berapa tier, berapa sub-level per tier, ambang poin tiap sub-level, dan apakah naik gelar butuh syarat selain poin (lulus tes + kehadiran, sesuai arahan Mas). Ini **desain sistem + tabel ambang**, lalu satu fungsi `gelar_for(poin, tes_lulus, hadir)` menggantikan `tier_for_points` di dua tempat (lokal + server harus diubah bersamaan supaya tidak selisih).
- **Level per misi (bukan hanya level akun).** "Tiap misi dibagi beberapa level game" — artinya tiap misi (mis. N1.2 Isim) punya level 1–3 (mis. level 1: kenal isim, level 2: latihan, level 3: hafalan/tes mini)? Atau level = Bagian 1–4? Ini perlu dikunci Laras dulu, karena dampaknya beda jauh:
  - *Kalau level = sub-tahap di dalam tiap misi:* 30 misi × 2–3 level = ~60–90 unit konten — konten membengkak, usaha BESAR.
  - *Kalau level = Bagian + tes (yang sudah ada di v1):* tidak ada konten baru, hanya penamaan ulang + gelar — usaha KECIL–SEDANG. **Saya rekomendasikan yang ini.**
- **Gelar di label nama:** tambah satu baris kecil di bawah nama (Label3D kedua) + aturan tampil di mode Drone (keputusan Mas 13:19: nama harus terbaca jelas di Drone — gelar ikut aturan yang sama; label mengecil di FOV lebar, kemungkinan perlu skala menurut jarak/ukuran minimum — belum diuji).
- **Syarat naik gelar dari kehadiran:** kehadiran khataman/Ma'hadiyah sekarang lokal saja + jam HP (bisa diakali) — syarat "kehadiran" untuk gelar TIDAK BISA ditegakkan sebelum Fase B (jam server + endpoint kehadiran). Kalau gelar naik hanya dari poin + lulus tes, bisa jalan di Fase A.

### (c) Usaha: SEDANG

Alasan: kerangka tier + ranking + Kartu Santri + label nama semuanya sudah ada. Pekerjaannya: perluas tabel tier → sub-level, tambah gelar di dua tempat tampil, dan kunci definisi "level per misi". Menjadi BESAR hanya kalau level per misi berarti melipatgandakan konten (lihat (b) di atas) atau kalau syarat kehadiran dipaksakan sebelum Fase B.

### (d) Prasyarat

1. **Jalur poin game→server — WAJIB sebelum gelar berbasis poin server bisa dipercaya.** Ini risiko 1 draf v1: game tidak pernah memanggil `POST /api/santri/points` (hanya disebut di komentar); `X-PV-Token` TIDAK BOLEH masuk file game. Tanpa keputusan Saka (relay via server realtime tepercaya vs endpoint baru pakai token sesi login), gelar di server basi dan gelar lokal bisa diakali. **Putuskan ini dulu sebelum Fase B; gelar lokal (Fase A) boleh jalan tanpa server.**
2. Jam server + endpoint kehadiran — HANYA bila naik gelar mensyaratkan kehadiran (kalau tidak, tidak perlu).
3. Keputusan desain Laras: definisi "level per misi" (sub-tahap vs Bagian) + daftar tier/sub-level + ambang.

### (e) Fase: A (gelar lokal: tier diperluas + tampil di Kartu Santri + label nama) → B (gelar server: sinkron poin + syarat kehadiran)

### ⚠️ Risiko terbesar

**Gelar tanpa jalur poin ke server = gelar yang bisa dipalsukan dan tidak sinkron.** Poin masih lokal saja; dua HP bisa punya gelar berbeda untuk santri yang sama, dan ranking server tidak mengenal gelar baru. Kalau gelar diluncurkan sebelum jalur poin beres, nanti harus migrasi/penyesuaian dan santri yang sudah naik gelar lokal bisa turun — itu merusak kepercayaan. Urutan yang benar: gelar lokal dulu (Fase A, jelas-jelas "lokal"), gelar server setelah jalur poin (Fase B).

---

## Butir 3 — Kuis tiap pekan + CHALLENGE antar player (multiplayer)

**Maksud Mas:** kuis mingguan serentak + papan skor, duel kuis 1 lawan 1, tantangan hafalan — antar player dalam satu server.

### (a) Yang SUDAH ADA dan bisa dipakai ulang

- **Mesin kuis 1 soal sudah ada** (`mission_data.gd` + panel misi + kuis di `main.gd`/`ui.gd`) — pola tampil soal + 4 opsi jawaban + kunci sudah terbukti jalan (M1–M3 live).
- **Papan skor sudah ada:** `GET /api/ranking` (leaderboard global + tier) — papan skor mingguan tinggal varian "filter 7 hari terakhir" dari data yang sama.
- **Server poin sudah punya `event_id` UNIQUE + dedup anti-dobel** (tes lolos) — poin kuis/challenge tidak bisa dikirim ganda, pola yang sama bisa dipakai untuk skor duel.
- **Feed chat MLBB (lokal) sudah ada** (`ui.gd`: panel chat + input + `chat_sent`) — UI chatnya sudah ada; yang belum ada hanya relay ke server (Fase 2).
- **Sholat berjamaah otomatis sudah diputuskan** (server broadcast pemicu) — pola "server memicu kegiatan serentak di jam tertentu" yang sama bisa dipakai untuk kuis mingguan serentak.
- **Khataman terjadwal 3×/hari sudah live** (05:00/13:00/18:30 + tombol hadir) — pola "event terjadwal + tombol hadir" sudah terbukti; kuis mingguan tinggal event terjadwal ke-4 dengan format berbeda.

### (b) Yang BARU dan harus dibangun

- **Kuis mingguan serentak:** (i) jadwal mingguan dari server (bukan jam HP — jam HP bisa diakali dan tidak sinkron antar pemain); (ii) soal yang sama untuk semua peserta dalam satu sesi; (iii) penguncian jawaban + penghitungan skor + papan skor sesi; (iv) anti-curang minimal (soal dikirim saat sesi mulai, bukan sebelumnya; jawaban setelah waktu habis ditolak). Ini **sistem event server baru**, bukan sekadar kuis lokal.
- **Duel kuis 1 lawan 1:** matchmaking (cari lawan di ruangan yang sama → undang → terima/tolak) + sesi duel sinkron (soal sama, timer sama, skor live) + penentuan pemenang + poin. Perlu **protokol duel di server realtime** — belum ada sama sekali; server realtime Fase 1 hanya relay posisi/pose (cek `network_manager.gd`: tidak ada RPC game-logic).
- **Tantangan hafalan antar player:** formatnya belum didefinisikan — apakah adu cepat susun bait (butuh mekanik hafalan yang di v1 saja masih "BARU — nol"), atau setor hafalan dinilai lawan/ustadz? Mekanik hafalan (susun/isi bait) belum ada; tanpa itu, "tantangan hafalan" tidak punya bentuk permainan.
- **Papan skor mingguan:** endpoint ranking per periode + UI papan skor di game (baru; ranking sekarang hanya global total).
- **Chat teks** (prasyarat koordinasi: undang duel, tantang hafalan) — Fase 2, belum ada relay server.

### (c) Usaha: BESAR

Alasan: kuis mingguan serentak saja sudah SEDANG (event server + jam server + soal serentak + papan skor sesi). Duel 1v1 menambah matchmaking + sesi sinkron + protokol realtime baru — itu satu fitur multiplayer lagi di atas Fase 2. Tantangan hafalan menambah mekanik hafalan yang belum ada. **Total butir 3 = 3 sub-fitur, masing-masing sedang; gabungannya besar.** Jangan dibungkus jadi satu paket — pecah per sub-fitur.

### (d) Prasyarat (berurutan — tidak bisa dilompati)

1. **Multiplayer Fase 1 lolos T1** (tes 2 HP — masih berjalan, diagnosis Dimas) — kalau 2 pemain saja belum stabil, duel 1v1 tidak ada artinya.
2. **Jalur poin game→server** (risiko 1 v1) — skor kuis/duel harus tercatat di server, kalau tidak papan skor basi.
3. **Jam server** (endpoint waktu server — sekarang TIDAK ADA; `now_iso()` hanya dipakai internal server untuk sesi/tiket) — kuis "serentak" mustahil tanpa jam bersama.
4. **Chat teks Fase 2** (relay + rate limit 1 pesan/2 detik, per FASE2-SPEC) — untuk undangan duel/tantangan.
5. **Cap 50 teruji beban (T5)** — kuis serentak dengan puluhan peserta di satu ruangan = beban relay tertinggi; cap kode sekarang 8 (`room_config.gd: MAX_PLAYERS_PER_ROOM := 8`), 50 × 10 Hz relay di VPS 2 vCPU belum teruji.
6. **Mekanik hafalan** (untuk tantangan hafalan saja; kuis mingguan dan duel tidak butuh ini).

### (e) Fase: B (kuis mingguan serentak — setelah jam server + jalur poin) → C (duel 1v1 + tantangan hafalan — setelah chat teks + multiplayer stabil)

### ⚠️ Risiko terbesar

**Tiga risiko menumpuk: jam, beban, dan curang.** (1) Tanpa jam server, "serentak" hanya pura-pura — tiap HP mulai di waktu berbeda. (2) Kuis serentak 50 orang = momen beban puncak server realtime; kalau belum uji beban T5, sesi bisa macet di tengah kuis dan semua peserta dirugikan bersamaan. (3) Soal + jawaban di tangan klien = bisa dibocorkan/diintip sebelum sesi; perlu soal dikirim server saat sesi mulai + jawaban kedaluwarsa — itu desain anti-curang yang belum dirancang. **Jangan janjikan kuis mingguan sebelum jam server + uji beban selesai.**

---

## Butir 4 — Event BAHTSUL MASAIL antar santri

**Maksud Mas:** event terjadwal, format musyawarah kelompok, dinilai ustadz/musyrif.

### (a) Yang SUDAH ADA dan bisa dipakai ulang

- **Musyawarah sudah dirancang di draf v1 §2.3** (musyawarah mingguan 15 poin + Bahtsul Masail bulanan 25 poin, lokasi Kelas/Masjid Besar, syarat buka: lulus Tahap 1) — butir 4 ini pada dasarnya **menaikkan status Bahtsul Masail dari "rencana Tahap 2–3" menjadi event yang diminta Mas**, bukan ide baru.
- **Sistem lamaran pengurus server v1.4.0** (alur Musyrif→Pengasuh, role di save) — peran ustadz/musyrif sebagai penilai sudah punya pola role di server; penilai Bahtsul Masail bisa memakai peran yang sama.
- **Pola event terjadwal + tombol hadir sudah live** (khataman 3×/hari) — kerangka "event di jam tertentu, santri hadir sebagai karakter" sudah terbukti.
- **Pola sholat berjamaah otomatis** (broadcast pemicu server) — pola pemicu serentak yang sama untuk membuka sesi Bahtsul Masail.
- **Lokasi sudah ada:** Surau/Musholla sekarang; Kelas (ambang 25) dan Masjid Besar (ambang 100, masih rencana) untuk sesi besar.

### (b) Yang BARU dan harus dibangun

- **Mekanik musyawarah kelompok — ini yang paling besar di butir 4.** Formatnya perlu dirancang Laras dulu: (i) satu masalah fiqih dari kitab (soal + dalil rujukan); (ii) tiap santri menyampaikan pendapat + dalil (lewat chat teks — ketik, bukan suara); (iii) musyawarah memutuskan (vote? mufakat? dinilai?); (iv) penilaian ustadz/musyrif (skor per santri atau per kelompok?). Tanpa format yang dikunci, tidak ada yang bisa dibangun — ini pekerjaan desain, bukan kode.
- **Chat teks** (prasyarat mutlak — musyawarah tanpa chat = tidak ada musyawarah; tidak ada jalan pintas).
- **Ruang musyawarah per kelompok:** sesi terpisah per kelompok di dalam ruangan (atau semua di satu tempat tapi percakapan terpisah per kelompok) — perlu desain server (channel/grup per sesi).
- **Sistem penilaian ustadz/musyrif:** siapa yang bisa menilai (role), antarmuka penilaian (di game atau di app web?), skor masuk `points_log` dengan `event_id` (pola sudah ada). Penilaian manusia = **moderasi manusia** — butuh ustadz/musyrif yang hadir di jam event; ini beban operasional, bukan cuma kode.
- **Jadwal event + pengumuman** (pola khataman bisa dipakai ulang; pengumuman event besar belum ada).

### (c) Usaha: SEDANG–BESAR

Alasan: SEDANG kalau formatnya sederhana (sesi terjadwal + chat kelompok + ustadz memberi skor manual lewat perintah/app). BESAR kalau formatnya lengkap (ruang kelompok terpisah + vote + penilaian per santri + papan hasil). Yang menentukan bukan kode, melainkan **format musyawarah yang dikunci Laras + ketersediaan penilai manusia**. Saran saya: mulai dari format paling sederhana (satu masalah, diskusi chat kelompok, musyrif memberi skor kelompok) — itu SEDANG.

### (d) Prasyarat

1. **Chat teks Fase 2** — mutlak, tidak bisa diganti.
2. **Jam server** — event terjadwal yang adil antar pemain.
3. **Multiplayer stabil + cap teruji** — musyawarah = banyak orang mengetik bersamaan; beban chat + kehadiran bersamaan.
4. **Keputusan format** (Laras + Mas): masalah dari kitab apa, berapa orang per kelompok, vote atau mufakat, siapa penilai, skor per santri atau per kelompok.
5. **Syarat buka Tahap 1** (lulus Ibtidaiyah — sesuai pesantren: musyawarah itu kelas tertinggi) — artinya butir 4 baru relevan setelah santri melewati Jenjang 0–1; jangan dibuka untuk santri baru.
6. **Lokasi:** Surau/Musholla cukup untuk awal; Masjid Besar (ambang 100, masih rencana) untuk Bahtsul Masail besar.

### (e) Fase: C (sosial — setelah chat teks + jam server; format dikunci Laras dulu)

### ⚠️ Risiko terbesar

**Penilaian manusia adalah bottleneck, bukan kode.** Game bisa menyediakan ruang + chat + vote, tapi kalau tidak ada ustadz/musyrif yang hadir menilai di jam event, Bahtsul Masail jadi diskusi tanpa penutup — santri berdebat, tidak ada yang memutuskan, tidak ada skor. Ini beda dengan kuis (otomatis) — **event ini hanya jalan kalau ada manusia yang bertugas**. Sebelum bangun, pastikan: siapa musyrif penilai, apakah mereka sanggup hadir terjadwal, dan lewat antarmuka apa mereka menilai. Kalau penilai belum ada, tunda ke Fase C akhir.

---

## Butir 5 — GAME OLAHRAGA: sepak bola dll antar santri

**Maksud Mas:** mode permainan terpisah di dalam dunia; tim putra vs putra, putri vs putri, terpisah sesuai aturan gender.

### (a) Yang SUDAH ADA dan bisa dipakai ulang

- **Lapangan Putra sudah ada sebagai lahan** — koordinat (−30,50) di masterplan; pagar bata tepi utara sudah dibangun (`pesantren_builder.gd:726`, z=39, x −44..−16). Lahan datar + pagar = tapak lapangan sudah tersedia.
- **Lapangan Putri (198,12)** — DITUNDA per keputusan Mas 13:19 (nanti, bareng Asrama ke-2); tapak sudah dipetakan, belum dibangun.
- **Karakter pemain sudah ada** (primitif Godot, gerak + kamera + mode Drone/Low/High Angle — mode kamera baru Raka 13:12) — kamera olahraga (mode Drone untuk lihat lapangan) hampir gratis dari pekerjaan kamera yang sedang jalan.
- **Zona gender + gerbang sudah ditegakkan server** (tembok x=14, aturan zona) — pemisahan tim putra vs putri bisa memakai zona yang sama; pertandingan putra dan putri otomatis terpisah wilayah.
- **Multiplayer Fase 1 (posisi/pose relay)** — pemain lain terlihat bergerak di dunia; itu fondasi minimal "main bareng".

### (b) Yang BARU dan harus dibangun — SEMUANYA, kecuali lahan

- **Lapangan yang benar-benar lapangan:** garis lapangan, gawang (2 buah — TIDAK ADA di kode sekarang; grep "gawang/goal" nol hasil), tiang, jaring. Sekadar lahan + pagar belum bisa dipakai main bola.
- **Bola + fisika bola:** TIDAK ADA satu pun `RigidBody3D` di proyek (grep `player.gd`/`npc.gd`: hanya `CharacterBody3D` untuk pemain). Bola butuh RigidBody3D (guling, pantul, tendang, gesek) + sinkronisasi posisi bola antar pemain. Ini **sistem fisika baru** di proyek yang selama ini tidak punya fisika benda bergerak.
- **Mekanik tendang/oper/gol:** tendang = dorong bola searah pemain; oper = arahkan ke teman; gol = deteksi bola masuk gawang (`Area3D` di gawang + skor). Belum ada satu pun mekanik interaksi fisik pemain↔benda di game.
- **Aturan pertandingan:** tim (pembagian tim, jumlah pemain per tim, kapten?), durasi, skor, pelanggaran/offside (atau tanpa wasit — perlu diputuskan), jeda, dan akhir pertandingan. Ini desain game baru.
- **Sinkronisasi multiplayer bola:** bola adalah SATU objek bersama yang diperebutkan — siapa yang "memiliki" otoritas atas bola? Kalau tiap klien menghitung fisika sendiri, bola akan berada di tempat berbeda di tiap HP (desync). Perlu **otoritas server atas bola** (server realtime menghitung/mengirim posisi bola) atau otoritas pemilik tendangan terakhir — keduanya belum ada di server realtime Fase 1 (yang hanya relay posisi/pose, tanpa logika game).
- **Mode permainan terpisah:** masuk mode olahraga (teleport ke lapangan, UI skor, keluar mode) + pembagian tim + tunggu pemain cukup — alur masuk/keluar mode baru.
- **Lapangan Putri:** belum dibangun sama sekali (ditunda 13:19) — olahraga putri tidak bisa jalan sebelum tapaknya dibangun.
- **"dll" (olahraga lain):** tiap olahraga = fisika + aturan + arena sendiri. Sepak bola saja sudah besar; "dll" jangan dihitung sebagai bonus — tiap cabang = satu paket besar lagi.

### (c) Usaha: BESAR — terbesar dari 5 butir, dengan jarak

Alasan: ini bukan "fitur di atas game", ini **satu game di dalam game** (arena + fisika + aturan + mode + sinkronisasi otoritatif). Perbandingan: kuis mingguan memakai mesin kuis yang sudah ada; gelar memakai tier yang sudah ada; olahraga tidak memakai apa pun yang sudah ada kecuali lahan kosong. Satu-satunya pengurang beban: kamera mode Drone/Low/High yang sedang dibangun Raka bisa dipakai ulang untuk sudut pandang lapangan.

### (d) Prasyarat (berurutan)

1. **Multiplayer Fase 1 lolos T1 + stabil** — olahraga multiplayer tanpa multiplayer yang stabil = tidak ada.
2. **Cap 50 teruji beban (T5)** — pertandingan = 10–22 pemain aktif bergerak cepat + bola; beban relay dan beban HP (draw call) di titik tertinggi.
3. **Keputusan otoritas bola di server realtime** (Saka — arsitektur; server realtime sekarang tanpa logika game).
4. **Lapangan Putra lengkap** (garis + gawang + jaring) dan **Lapangan Putri dibangun** (sesuai keputusan 13:19 — nanti, bareng Asrama ke-2; jadi olahraga putri otomatis menunggu Asrama ke-2).
5. **Desain aturan** (Laras + Mas): berapa pemain per tim, durasi, wasit atau tidak, skor masuk poin santri atau tidak.
6. **Mode kamera olahraga** — bisa pakai mode Drone yang sedang dibangun (Raka).

### (e) Fase: D — BARU, setelah Fase C selesai

Bukan A/B/C. Olahraga butuh semua fondasi (multiplayer stabil + cap teruji + otoritas server) yang baru selesai di akhir Fase C. Menjadwalkannya lebih awal = membangun di atas fondasi yang belum teruji.

### ⚠️ Risiko terbesar (tiga, semuanya besar)

1. **Desync bola.** Satu bola, banyak HP, fisika dihitung di mana-mana = bola yang berbeda di tiap layar. Tanpa otoritas server atas bola, pertandingan tidak adil dan tidak bisa diputuskan siapa yang mencetak gol. Ini risiko arsitektur — salah desain di awal, perbaikannya mahal.
2. **Beban performa HP.** 20+ pemain bergerak cepat + bola + fisika + label nama di satu lapangan, di HP santri (bukan HP flagship). Belum ada uji beban untuk ini; kemungkinan perlu interest management + pengurangan detail — pekerjaan optimasi tersendiri.
3. **"Dll" mengembang tanpa batas.** Sepak bola → voli → badminton → ... tiap cabang = satu paket besar. Tanpa daftar cabang yang dikunci Mas, butir 5 tidak punya ujung. **Minta Mas kunci SATU cabang dulu (sepak bola), cabang lain ditunda.**

---

## Peta fase gabungan (untuk Laras — susun ke draf v2)

| Fase | Isi (v1 + 5 butir baru) |
|---|---|
| **A — Fondasi** | Mesin kuis multi-soal + tes ≥8 + gating Bagian + peti dinamis + slide smartboard + **tes gerbang baca kitab (lokal) + gelar diperluas (lokal, tampil di Kartu Santri + label nama)** |
| **B — Server & serentak** | Jalur poin game→server (keputusan Saka) + jam server + khataman/kehadiran ke server + badge lulus + ranking per asrama + **penegakan gerbang kelulusan + gelar server + kuis mingguan serentak + papan skor mingguan** |
| **C — Sosial** | Chat teks + sholat serentak server + voting + label jabatan + pelantikan + misi bersama + **duel kuis 1v1 + tantangan hafalan + Bahtsul Masail** |
| **D — Olahraga (baru)** | **Sepak bola: lapangan lengkap + bola + fisika + otoritas server + aturan + mode pertandingan** (putri menunggu Lapangan Putri/Asrama ke-2). Cabang "dll" ditunda sampai sepak bola jalan. |

## Tiga risiko lintas butir (untuk §9 draf v2)

1. **Jalur poin game→server belum ada** — mengunci butir 2 (gelar server) dan butir 3 (papan skor). Keputusan Saka tetap prasyarat Fase B; jangan luncurkan gelar/papan skor server sebelum ini.
2. **Jam server belum ada** — mengunci butir 3 (serentak) dan butir 4 (terjadwal). Endpoint waktu server tidak ada; `now_iso()` hanya internal. Butuh endpoint + pemakaian di game.
3. **Konten tetap bottleneck** — bank soal baca kitab (butir 1), soal kuis mingguan (butir 3), masalah fiqih musyawarah (butir 4) semuanya konten Laras/Zahra + cek ustadz. Mesin yang sudah jadi tanpa soal = fitur kosong.

## Yang perlu Laras kunci sebelum revisi v2 ditulis

1. **Definisi "level per misi"** (butir 2): sub-tahap di tiap misi (konten ×2–3) atau Bagian + tes yang sudah ada (tanpa konten baru)? Rekomendasi Raka: yang kedua.
2. **Format Bahtsul Masail** (butir 4): masalah dari kitab apa, berapa orang/kelompok, vote atau mufakat, siapa penilai, skor per santri atau per kelompok — dan siapa musyrif penilai yang sanggup hadir terjadwal.
3. **Cabang olahraga pertama** (butir 5): sepak bola saja dulu? Dan apakah skor pertandingan masuk poin santri?
4. **Tes gerbang baca kitab** (butir 1): cukup uji otomatis (pengenalan i'rob + terjemahan) atau perlu setoran ke ustadz? Kalau perlu setoran, itu Fase C dan butuh sistem penilaian.
5. **Daftar tier/sub-level gelar** (butir 2): berapa tier, berapa sub-level, ambang poin tiap tingkat, dan apakah kehadiran menjadi syarat naik gelar (kalau ya, gelar server menunggu jam server + endpoint kehadiran).

---
*Raka — game. Laporan saja; tidak ada file game yang diubah.*
