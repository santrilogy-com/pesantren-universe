# Rencana Multiplayer — Pesantren Universe

**Disusun:** Arsa (arsitek), 17 Nov 2026 ~23:52 WIB, atas permintaan Mas ("Buat rencananya.. nanti ada tim khusus buat ini.. sekiranya cepet selesai").
**Status:** RENCANA — belum ada kode yang ditulis. Tim eksekusi dibentuk nanti.
**Prinsip:** MVP dulu yang kecil tapi bisa dites cepat; tiap fase selesai dengan kriteria tes yang jelas; tidak ada layanan berbayar baru.

## 0. Keadaan awal (dicek langsung sebelum menulis)

- Game: Godot 4.7.2, proyek v2 `v2/godot-dunia/`, export Web saja (preset `Web`, `dedicated_server=false`), live di https://pesantren-verse-v2.pages.dev.
- **Tidak ada kode multiplayer.** Dicek: tidak ada `MultiplayerPeer` / `ENet` / `WebSocket` / `rpc` di `scripts/`. Satu-satunya yang menyebut kata itu adalah komentar di `scripts/npc.gd:9` — "BUKAN pemain sungguhan dan BUKAN multiplayer".
- Pemain: `SantriPlayer` extends `CharacterBody3D` (1.445 baris), dibuat di kode oleh `main.gd:309` (`SantriPlayer.new()`), gerak `velocity` + `move_and_slide()`, kecepatan `SPEED := 6.0` m/s. Visual dibangun pabrik statis `SantriPlayer.build_visual(nama, outfit)` (primitif MeshInstance3D: torso, peci, sarung, sandal) — dipakai pemain DAN semua NPC, jadi avatar pemain lain bisa memakai pabrik yang sama.
- NPC (`SantriNPC`, Node3D): gerak langsung via posisi (tanpa fisika), waypoint + sinyal; Bilal, Faris, Kyai, Ustadzah, satpam.
- Identitas: `save_data.gd` menyimpan `id_santri` (PV-XXXX), `ig_username`, `nama`, `jenis_kelamin` ("putra"/"putri"), `outfit` (koko/songkok/sarung/abaya/hijab_warna).
- Login: `main.gd` HTTPRequest `POST /api/santri/login` → ID + nama + jenis_kelamin + **token sesi (1 jam, hanya di memori)**. Daftar: `RegistrasiServer` (`POST /api/santri/register`, publik). Spawn sesuai gender: putra (−4,14), putri (130,14) — catatan: masterplan menanyakan (140,16), belum diputuskan Mas.
- Server sekarang: Python 3.12 **stdlib saja** (`http.server` + sqlite3 WAL), systemd `pesantren-verse-api`, dengar `127.0.0.1:8790`, Caddy reverse proxy → https://43-173-39-166.sslip.io (Let's Encrypt, sslip.io, tanpa domain berbayar). VPS: 2 vCPU, RAM 7,4 GB, Ubuntu 24.04. Layanan lain di VPS (Hermes, jembatan WA 3000/3001, Next.js) **tidak boleh disentuh**. README server sendiri sudah menulis: "Multiplayer belakangan (butuh desain ENet server-authoritative terpisah)."
- **Fakta kunci untuk auth:** token sesi login bersifat **sekali pakai** — `server.py`: "hangus setelah dipakai", `UPDATE sesi_login SET used=1`, 1 jam, satu sesi per santri. Karena itu handshake realtime TIDAK BOLEH memakai token sesi login secara langsung (lihat Fase 0).
- Poin/misi: `POST /api/santri/points` memakai `X-PV-Token` (token bersama server tepercaya) — **tidak pernah ada di file game mana pun**. Aturan ini tetap berlaku di multiplayer.
- Chat teks sudah ada sebagai UI: feed melayang gaya MLBB di `ui.gd` (`tampilkan_pesan_melayang`) — NPC `say()` sudah memakainya. Yang belum ada: chat antar pemain.
- Ronde yang sedang jalan (Raka, sejak 23:39) sedang mengubah file di sekitar area ini: `registrasi_server.gd`, `gubuk_masuk.gd`, `tangga_surau.gd`, `animasi_mixamo.gd`, `buku_data.gd`. **Karena itu Fase 1 dimulai setelah ronde itu selesai di-deploy.** Fase 0 bisa jalan sekarang (tidak menyentuh gameplay).

## 1. Arsitektur yang dipilih

### 1.1 Pilihan: server khusus Godot (dedicated server) + WebSocket

- **Klien (web):** `WebSocketMultiplayerPeer` — bukan ENet. ENet tidak jalan di browser (export web Godot tidak mendukungnya); WebSocket adalah satu-satunya jalur multiplayer untuk klien web. Klien tetap export Web yang sama seperti sekarang.
- **Server realtime:** build **dedicated server Godot** (Linux headless) dari proyek yang sama, jalan sebagai service di VPS yang sama, berdampingan dengan API REST yang sudah ada. Server ini otoritatif: ia yang punya dunia, memvalidasi gerak, dan menyiarkan keadaan ke semua klien.
- **Transport:** `wss://43-173-39-166.sslip.io/ws/` → Caddy (pakai sertifikat Let's Encrypt yang sudah ada) → `127.0.0.1:8791` (server realtime). Browser dari halaman `https://` menolak `ws://` (mixed content), jadi harus `wss` — ini gratis karena Caddy sudah ada.
- **Auth:** klien login dulu lewat REST seperti sekarang, lalu memakai **tiket realtime** (bukan token sesi login — lihat 1.3) untuk handshake WebSocket. Server realtime memvalidasi tiket ke DB/API di localhost, lalu mengikat koneksi itu ke `id_santri` + `nama` + `jenis_kelamin` dari DB. Nama yang tampil ke pemain lain SELALU dari DB, tidak pernah dari yang dikirim klien.
- **Sinkronisasi:** `MultiplayerSpawner` (avatar pemain muncul/hilang di semua klien) + `MultiplayerSynchronizer` (posisi/rotasi/pose). Otoritas per avatar dipegang pemiliknya (`set_multiplayer_authority(peer_id)`); server memvalidasi, bukan mempercayai begitu saja.
- **Poin/misi:** tetap di REST. Server realtime tidak pernah memberi poin langsung. Kalau suatu kejadian multiplayer perlu memberi poin, server realtime (komponen tepercaya di VPS yang sama) yang memanggil `POST /api/santri/points` ke localhost dengan `X-PV-Token`. Token itu tetap tidak pernah keluar dari VPS dan tidak pernah masuk file game.

### 1.2 Kenapa bukan server Python WebSocket

Server REST sekarang Python stdlib — menggiurkan untuk memakai Python juga buat realtime. Tapi:

- Godot high-level multiplayer di atas WebSocket memakai protokol paket milik engine. Server Python harus mengimplementasikan ulang protokol itu (atau turun ke `WebSocketPeer` level rendah + protokol JSON buatan sendiri: spawn/despawn, interpolasi, urutan pesan — semua ditulis tangan).
- Python stdlib **tidak punya** server WebSocket — framing RFC 6455 harus ditulis tangan (~ratusan baris, rawan bug ping/pong dan fragmentasi).
- Dengan server Godot, sinkronisasi, spawn, dan RPC sudah ditangani engine; yang ditulis tim hanya aturan mainnya (zona gender, validasi gerak, chat). Bug multiplayer yang paling sulit (desync, checksum RPC) hilang karena klien dan server dibangun dari commit yang sama.
- Harga yang dibayar: satu preset export baru + deploy biner Godot ke VPS (pekerjaan ops satu kali, pola yang sama dengan deploy yang sudah ada: systemd + Caddy).

Jalur Python tetap dicatat sebagai **cadangan** kalau nanti tim memutuskan tidak mau biner Godot di VPS — tapi bukan jalur utama, karena total kode dan risiko bug-nya lebih besar.

### 1.3 Auth: tiket realtime (keputusan Fase 0)

Token sesi login sekali pakai ("hangus setelah dipakai") sehingga tidak bisa dipakai ulang untuk handshake. Fase 0 harus memilih satu dari dua cara (tanyakan ke Saka, jangan ditebak):

- **(a) Endpoint tiket baru** di REST API: `POST /api/santri/realtime_ticket` (pakai sesi login yang masih berlaku) → mengembalikan tiket singkat (±5 menit, sekali pakai) khusus untuk handshake WebSocket. Paling bersih, tapi menambah satu endpoint.
- **(b) Validasi read-only:** server realtime membaca tabel `sesi_login` di sqlite secara read-only (cek token ada + belum kedaluwarsa) tanpa mengubah flag `used`. Tanpa endpoint baru, tapi server realtime terikat ke skema DB REST.

Mana pun yang dipilih, aturannya sama: tiket/token tidak pernah ditulis ke log, tidak pernah dikirim ke pemain lain, dan koneksi tanpa tiket yang valid langsung diputus.

> **KEPUTUSAN FASE 0 (Saka, 18 Nov 2026 ~00:14 WIB — LIVE di REST v1.5.2): dipilih cara (a).**
> Alasan (dicek dari `server.py` yang sebenarnya): token sesi login juga mengesahkan `set_password`, jadi mengirimnya ke handshake realtime memperluas permukaan serangannya; dan server realtime Godot tanpa driver sqlite tidak bisa membaca tabel `sesi_login` — cara (b) memaksanya membaca DB langsung dan menduplikasi logika `_cek_sesi` di GDScript. Cara (a) membiarkan REST tetap satu-satunya sumber kebenaran auth.
> Kontrak yang sudah jalan di `https://43-173-39-166.sslip.io`:
> - Klien: login seperti biasa → `POST /api/santri/realtime_ticket` body `{"session": "<token sesi>"}` → `200 {"ticket", "expires_in": 300, "id", "nama", "jenis_kelamin"}`. Token sesi **TIDAK hangus** (tetap berlaku untuk `set_password` dan minta tiket lagi bila reconnect). Sesi tidak valid → 401.
> - Klien: kirim tiket itu saat handshake `wss` (bukan token sesi).
> - Server realtime (localhost, komponen tepercaya): `POST /api/santri/realtime_ticket/validate` ke `127.0.0.1:8790` dengan header `X-PV-Token`, body `{"ticket": "<tiket>"}` → `200 {"id", "nama", "jenis_kelamin"}` dari DB, tiket langsung ditandai terpakai (sekali pakai). Tanpa X-PV-Token yang benar / tiket palsu / sudah dipakai / kedaluwarsa → 401. Nama pemain lain SELALU dari respons ini, bukan dari klien.
> - Tiket/token tidak pernah ditulis ke log (dicek di journal: hanya method + path + status). Tes: `server/test-v1.5.2.sh` (13 cek, semua lolos, santri tes PV-0003 sudah dibersihkan).

### 1.4 Aturan pesantren yang WAJIB dipertahankan (server yang menegakkan, bukan klien)

Klien tidak boleh dipercaya — semua aturan ini dicek **di server realtime**:

- Satu dunia dua area: tembok solid x=14 + gerbang tertutup; kampus putri Opsi A (x 115..180, z −52..+22); gerbang putri barat (115,0) tertutup.
- Server memuat `jenis_kelamin` tiap pemain dari DB saat join dan menolak posisi di luar zona pemain itu (putra tidak boleh masuk area putri, begitu pula sebaliknya; zona penyangga di tengah mengikuti peta final Gilang — tim WAJIB mengonfirmasi batas pastinya ke peta sebelum membangun, jangan mengarang angka).
- Posisi yang ditolak: server mengembalikan pemain ke **posisi legal terakhir** (pola ini sudah ada di `main.gd:319` — dipakai ulang, bukan dibuat baru).
- Validasi gerak: kecepatan maks 6 m/s + toleransi; teleport mendadak ditolak.
- Nama + outfit pemain lain diambil dari DB/save yang terverifikasi (outfit warna abaya/jilbab santriwati dari `save_data`).
- Gerbang tetap tertutup di dunia; tidak ada "jalan pintas" lewat multiplayer.

## 2. Fase bertahap (MVP dulu)

### Fase 0 — Persiapan (tanpa ubah gameplay)

- **Ruang lingkup:** (1) putuskan cara tiket auth (1.3) bersama Saka; (2) Caddy: tambah route `/ws/` → `127.0.0.1:8791`, reload, REST tidak disentuh; (3) preset export baru "Dedicated Server" (Linux, `dedicated_server=true`) + satu skrip build yang membangun **web + server dari commit yang sama** (agar checksum RPC cocok); (4) service systemd `pesantren-verse-realtime` (auto-start saat reboot, sama polanya dengan `pesantren-verse-api`); (5) smoke test 2 instance headless (host + join, sesuai skill `godot-multiplayer` langkah 8) + cek log tanpa `ERROR`.
- **File yang disentuh:** `export_presets.cfg`, `server/pesantren-verse-realtime.service` (baru), salinan `/etc/caddy/Caddyfile`, skrip build (baru, mis. `export/build_multiplayer.sh`), `server/server.py` HANYA bila dipilih cara (a) (endpoint tiket).
- **Kriteria selesai (bisa dites):** 2 instance headless saling terhubung (log `connected` di keduanya, tanpa baris `ERROR:`); service jalan di VPS; `wss://` bisa dijangkau dari browser (cek TLS); `GET /health` REST tetap menjawab versi yang sama (API tidak terganggu).
- **SENGAJA TIDAK DIBANGUN:** gameplay apa pun; tidak ada perubahan `player.gd` / `main.gd` / `npc.gd`.

### Fase 1 — MVP: dua pemain saling lihat bergerak + nama

- **Ruang lingkup:** tombol "Masuk Dunia" setelah login → hubung `wss`; handshake tiket; server spawn avatar tiap pemain (`MultiplayerSpawner`); sinkron posisi/rotasi/pose 10 Hz (`MultiplayerSynchronizer`: posisi `REPLICATION_MODE_ALWAYS`, pose/outfit `ON_CHANGE`); nama di atas kepala dari DB; spawn sesuai gender; server menolak posisi lintas zona (snap back ke posisi legal terakhir); disconnect → avatar hilang di semua klien; reconnect → respawn di titik spawn; **mode offline tetap jalan seperti sekarang** bila tidak ada koneksi (game tidak boleh rusak kalau server realtime mati).
- **File yang disentuh:** `scripts/multiplayer/` (baru: `network_manager.gd` + `remote_player.gd`), `scripts/player.gd` (refactor: otoritas per avatar + pisah visual dari input), `scripts/main.gd` (ganti `_player` tunggal → spawn via spawner; mode offline), `scripts/ui.gd` (status koneksi + daftar pemain mini), `project.godot` bila perlu.
- **Kriteria selesai (bisa dites):** 2 HP/browser (satu putra, satu putri) masuk bersamaan, saling lihat bergerak + nama; pemain putra yang mencoba masuk area putri ditolak server (bukan cuma ditahan klien); keluar-masuk ulang tanpa error; matikan server realtime → game tetap bisa dimainkan offline seperti sekarang.
- **SENGAJA TIDAK DIBANGUN:** chat antar pemain; sinkron interior (Surau/Musholla/Cangkruk); sholat berjamaah multiplayer; poin; suara; sinkron NPC; ranking dalam game; uji lebih dari 2 pemain (cap kode 8 dulu, dites 2).

### Fase 2 — Satu ruangan penuh: chat + jam sholat dari server

- **Ruang lingkup:** cap 20 pemain per ruangan; chat teks antar pemain memakai feed MLBB yang sudah ada (`ui.gd`), relay lewat server, rate limit server (mis. 1 pesan/2 detik), nama dari DB; daftar pemain + toast masuk/keluar; **jam sholat dari server** (server menyiarkan pemicu sesi pada jam yang sama — semua pemain mulai bersamaan; Kyai imam tetap NPC lokal per klien untuk fase ini); log koneksi server (siapa masuk/keluar, untuk pengawasan); anti-spam dasar.
- **File yang disentuh:** server realtime (relay chat + jam), `scripts/ui.gd` (feed + daftar pemain), `scripts/main.gd` (jam server menggantikan jam lokal untuk pemicu sesi).
- **Kriteria selesai (bisa dites):** 5+ pemain bersamaan (2 HP + 3 headless); chat terkirim dan tampil di feed semua pemain; sholat mulai serentak di semua perangkat; tidak ada pemain yang bisa menembus zona gender; log server mencatat semua join/leave.
- **SENGAJA TIDAK DIBANGUN:** suara; sinkron interior; sinkron NPC penuh; poin dari kejadian multiplayer; moderasi (lapor/blokir/tendang) — itu Fase 3.

### Fase 3 — Polish: interior, suara (bila diputuskan), moderasi, uji beban

- **Ruang lingkup:** sinkron interior (pemain di interior yang sama saling terlihat; yang di luar tidak melihat yang di dalam); suara — HANYA bila Mas memutuskan (butuh server token LiveKit terpisah yang belum ada — bukan bagian rencana ini); reconnect dengan posisi terakhir (bukan respawn); moderasi: lapor, bisu, tendang oleh musyrif (memakai jabatan dari sistem lamaran yang sudah ada); uji beban 20 klien headless; izin `INTERNET` untuk export Android/APK; dokumentasi operasi (cara restart, baca log, backup).
- **File yang disentuh:** `scripts/multiplayer/` + interior (`interior_surau.gd`, `interior_musholla.gd`, `interior_cangkruk.gd`), UI moderasi (baru), dokumen operasi (baru).
- **Kriteria selesai (bisa dites):** semua kriteria Fase 2 + interior tersinkron + uji beban 20 klien lulus tanpa error + Mas tes di HP dan ACC.
- **SENGAJA TIDAK DIBANGUN:** apa pun di luar daftar ini tanpa keputusan Mas.

## 3. Angka-angka (supaya perkiraan jujur)

- Paket sinkron per pemain: posisi (3 float) + rotasi Y + pose ≈ 50–80 byte (biner, bukan JSON). Pada 10 Hz: naik ±0,8 KB/detik per pemain; turun ±0,6 KB/detik per pemain lain di dekatnya. Pada 20 pemain: ±12 KB/detik turun per klien — ringan untuk data seluler.
- Server: 20 pemain × 10 Hz × 19 penerima ≈ 3.800 paket/detik relay + validasi gerak — ringan untuk server Godot headless di VPS 2 vCPU; berat bila ditulis tangan di Python stdlib (satu alasan lagi memilih server Godot).
- Kecepatan jalan 6 m/s → update 10 Hz berarti tiap paket menempuh ±0,6 m; interpolasi di klien menutup celah ini supaya gerakan pemain lain terlihat halus.

## 4. Risiko + jalan keluar

| Risiko | Jalan keluar |
|---|---|
| Lag di HP (Galaxy A35, data seluler) | Update 10 Hz, paket biner kecil, interpolasi di klien; uji di HP Mas, bukan cuma headless. Bila masih patah-patah, turunkan ke 8 Hz atau batasi jarak pandang pemain lain. |
| `wss` di browser (mixed content) | Wajib `wss`, bukan `ws`; Caddy sudah punya sertifikat untuk hostname yang sama; uji dari link Pages yang live, bukan dari localhost saja. |
| Checksum RPC tidak cocok (klien vs server) | Satu skrip build: web + server dari commit yang sama; jangan pernah deploy salah satunya dari commit berbeda. |
| Token sesi sekali pakai disalahgunakan | Jangan pakai token login langsung; tiket realtime (Fase 0, cara a/b). Tiket tidak pernah masuk log. |
| Klien nakal: bypass zona, teleport, nama palsu | Server otoritatif: validasi kecepatan 6 m/s, zona gender, tolak teleport; nama selalu dari DB. Klien tidak dipercaya. |
| Penyalahgunaan chat / gangguan lintas gender | Auth lewat login; rate limit chat; nama dari DB; gerbang tetap tertutup di dunia. Moderasi (lapor/bisu/tendang) di Fase 3. |
| Beban VPS (berbagi dengan Hermes/WA/Next.js) | Server Godot ringan untuk ≤20 pemain; cap pemain ditegakkan; jangan sentuh service lain; awasi log. Bila ruangan penuh terus, baru bicara soal naikkan cap — bukan sekarang. |
| Tabrakan dengan ronde yang sedang jalan | Fase 1 mulai setelah ronde Raka selesai di-deploy. Fase 0 boleh jalan sekarang (tidak sentuh gameplay). |
| Tes headless lulus tapi di browser gagal | Aturan tetap: tes akhir selalu 2 HP/browser + HP Mas. Headless hanya membuktikan handshake, bukan rasa main. |
| Biaya membengkak | Tetap Rp0 tambahan: VPS sudah ada, Caddy + sslip.io sudah ada, Godot gratis, tidak ada layanan berbayar baru. Bila ada yang mengusulkan layanan berbayar (mis. LiveKit berbayar, server game pihak ketiga), tolak sampai Mas memutuskan. |

## 5. Perkiraan usaha (JUJUR — satuan kerja, bukan tanggal)

Perkiraan untuk tim khusus kecil (2–3 orang) yang bekerja fokus. Ini **perkiraan, bukan janji tanggal**; mulainya setelah ronde yang sedang jalan selesai di-deploy.

| Fase | Perkiraan | Hasil |
|---|---|---|
| Fase 0 — Persiapan | 1–2 hari kerja | wss jalan, service jalan, smoke test 2 instance lulus |
| Fase 1 — MVP 2 pemain | 3–5 hari kerja | 2 pemain saling lihat + nama, zona ditegakkan server |
| Fase 2 — Ruangan 20 + chat + sholat | 5–8 hari kerja | 1 ruangan penuh, chat, sholat serentak |
| Fase 3 — Polish | 1–2 minggu kerja | interior, moderasi, uji beban, dokumen operasi |
| **Total sampai MVP bisa dites** | **±1 minggu kerja fokus** | Fase 0 + 1 |
| **Total sampai ruangan penuh** | **±2–3 minggu kerja fokus** | Fase 0 + 1 + 2 |

Yang bisa memperlambat (dicatat di depan, bukan disembunyikan): keputusan tiket auth yang berlarut (Fase 0), ronde yang sedang jalan belum selesai, dan tes HP yang menemukan masalah yang tidak terlihat di headless.

## 6. Urutan kerja tim khusus nanti (peran)

1. **Lead multiplayer (game)** — pemilik arsitektur ini; klien networking, build server, set RPC; kerja dari Fase 0 sampai selesai.
2. **Server (Saka)** — Caddy, systemd, tiket auth, deploy, log; paling sibuk di Fase 0, lalu mendampingi.
3. **Gameplay (tim Raka)** — refactor pemain, zona gender, chat UI, interior; paling sibuk di Fase 1–3.
4. **QA (Xam + Mas)** — Xam: tes headless + verifikasi deploy; Mas: tes akhir di HP (2 perangkat untuk multiplayer).

Urutan: Fase 0 (Lead + Saka) → Fase 1 (Lead + Gameplay) → Fase 2 (Gameplay + Server) → Fase 3 (semua + QA). Satu fase selesai + dites dulu sebelum fase berikutnya dimulai; jangan kerjakan tiga fase sekaligus.

## 7. Skala ke depan (supaya tidak mentok)

Mas bertanya (23:54) soal ratusan ribu santri — ini jawabannya sebagai bagian dari rencana:

- **Yang menentukan beban adalah pemain ONLINE BERSAMAAN, bukan total santri terdaftar.** Ratusan ribu santri terdaftar tidak masalah; yang berat adalah kalau ratusan ribu main di saat yang sama.
- **Desain ruangan membuat skala jadi urusan "tambah ruangan", bukan "server makin besar":** satu ruangan = satu proses server realtime; tiap ruangan independen (cap 20); satu pemain hanya ada di satu ruangan dalam satu waktu. REST API tetap satu sumber kebenaran untuk akun/poin/ranking — server realtime tidak menyimpan data permanen apa pun.
- **Tangga skala (perkiraan, bukan janji):** puluhan–ratusan bersamaan → VPS sekarang cukup (perkiraan ±50–100 bersamaan); ~1.000 bersamaan → VPS lebih besar (8 vCPU/16–32 GB); ~10.000 bersamaan → beberapa server + load balancer + Postgres/Redis (sqlite tidak cocok untuk tulis bersamaan dari banyak proses); 100.000+ bersamaan → klaster, skala MMO (proyek besar tersendiri, bukan rencana ini).
- **Yang dijaga sejak MVP supaya tidak mentok:** (1) server realtime tidak menyimpan data permanen (semua tulis permanen lewat REST); (2) ruangan independen, tanpa state bersama antar ruangan; (3) auth lewat tiket, bukan koneksi langsung ke DB dari klien; (4) cap per ruangan ditegakkan sejak Fase 1.
- **SENGAJA TIDAK DIBANGUN sekarang:** sharding otomatis, load balancer, migrasi DB. Itu nanti, bila pemain benar-benar membludak. MVP dulu.

## 8. Keputusan yang masih butuh Mas (jangan diputuskan sendiri)

1. **Batas pemain per ruangan:** 10 / 20 / 50? (Usul tim: 20 — cukup ramai, masih ringan untuk VPS.)
2. **Chat suara ikut atau teks dulu?** (Usul tim: teks dulu di Fase 2; suara butuh server token LiveKit terpisah yang belum ada, jadi itu proyek sendiri bila Mas mau.)
3. **Sholat berjamaah multiplayer** jadi prioritas Fase 2, atau nanti saja?
4. **Pemain boleh melihat pemain lain dari seberang gerbang/tembok**, atau sepenuhnya tidak terlihat sampai satu ruangan?
5. **Satu akun boleh dipakai dua perangkat bersamaan**, atau tetap satu sesi per santri seperti sekarang?
6. **Nama pemain lain tampil selalu**, atau hanya saat dekat?

## 9. Referensi yang dipakai

- Skill `godot-multiplayer` (`~/workspace/custom-skills/godot-multiplayer/SKILL.md`) — pola ENet/`@rpc`/`MultiplayerSpawner`/`MultiplayerSynchronizer`, smoke test 2 instance headless. Catatan: pola ENet di skill itu untuk desktop; untuk klien web, transportnya diganti `WebSocketMultiplayerPeer` (API high-level yang sama).
- `server/README.md` + `server/server.py` — kontrak REST v1.5.1, token sekali pakai, `X-PV-Token` hanya di server.
- `v2/godot-dunia/scripts/player.gd` (1.445 baris), `main.gd` (2.390 baris), `npc.gd`, `save_data.gd`, `ui.gd` — struktur yang akan disentuh Fase 1.
- `v2/godot-dunia/export_presets.cfg` — saat ini hanya preset `Web`.
