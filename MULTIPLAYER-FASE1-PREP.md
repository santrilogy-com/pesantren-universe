# Persiapan Fase 1 Multiplayer + Desain Ruangan Cap Configurable

**Disusun:** Arsa (arsitek), 18 Nov 2026 ~00:10 WIB
**Induk:** `MULTIPLAYER-PLAN.md` (17 Nov 2026 ~23:52 WIB) — baca itu dulu; dokumen ini TIDAK menggantikan rencana induk, hanya menyiapkan Fase 1 sampai ke tingkat yang bisa langsung dikerjakan.
**Status:** DOKUMEN DESAIN — belum ada kode yang ditulis di sini. Semua file di bawah ini dikerjakan tim eksekusi setelah ronde Raka di-deploy (lihat §4).
**Perintah Mas (00:07 WIB):** "Kalau bisa jangan lama.. segera selesain. Bikin tim yg banyak." — karena itu dokumen ini menyiapkan SEMUA yang bisa disiapkan sekarang, supaya Fase 1 langsung jalan tanpa waktu tunggu kosong begitu ronde Raka selesai.

**Batas kerja dokumen ini (dipatuhi):** hanya dokumen. Tidak menyentuh file Raka (`main.gd`, `player.gd`, `npc.gd`, `registrasi_server.gd`, `gubuk_masuk.gd`, `tangga_surau.gd`, `animasi_mixamo.gd`, `buku_data.gd`). Tidak menulis kode di `scripts/multiplayer/` — itu wilayah Bara.

---

## 1. Desain sync Fase 1

### 1.1 Ringkasnya

Dua pemain saling lihat bergerak + nama di atas kepala. Server otoritatif, klien web lewat `WebSocketMultiplayerPeer` (bukan ENet — ENet tidak jalan di browser). Satu-satunya yang direplikasi Fase 1: **gerak + pose + outfit**. Bukan chat (Fase 2), bukan interior (Fase 3), bukan NPC, bukan poin.

### 1.2 Properti yang direplikasi + rate

| Properti | Isi | Mode replikasi | Rate | Keterangan |
|---|---|---|---|---|
| `sync_position: Vector3` | posisi avatar (x, y, z) | `REPLICATION_MODE_ALWAYS` | 10 Hz (`replication_interval = 0.1`) | Bukan `position` langsung (lihat 1.3 — interpolasi). Naik ±0,8 KB/detik per pemain (§3 rencana induk). |
| `sync_yaw: float` | arah hadap (rotasi Y, radian) | `REPLICATION_MODE_ALWAYS` | 10 Hz | Satu float, bukan `rotation` utuh — avatar tidak pernah miring (pitch/roll tidak dipakai). |
| `pose_id: int` | keadaan animasi: 0 idle, 1 jalan, 2 duduk, 3 sholat, dst. | `REPLICATION_MODE_ON_CHANGE` | hanya saat berubah | Enum int, bukan string — hemat byte dan tidak ambigu. Daftar nilai pose HARUS ditulis di satu tempat (`scripts/multiplayer/pose_ids.gd` atau konstanta di `remote_player.gd`) supaya klien dan server tidak beda tafsir. |
| `outfit: Dictionary` | koko/songkok/sarung (putra) atau abaya/hijab_warna (putri) | `REPLICATION_MODE_ON_CHANGE` | saat spawn + saat ganti outfit | Diset sekali saat spawn dari data DB terverifikasi; berubah hanya kalau pemain ganti outfit. |
| `nama_tampil: String` | nama dari DB | **TIDAK via synchronizer** | sekali saat spawn | Dikirim server lewat spawn (lihat 1.4); klien tidak pernah mengirim namanya sendiri. |

Yang SENGAJA TIDAK direplikasi Fase 1: `velocity` (server menghitung kecepatan dari selisih posisi, bukan dari angka kiriman klien — angka kiriman klien bisa dipalsu), kesehatan/poin (tidak ada di Fase 1), posisi NPC, isi interior.

Kecepatan jalan 6 m/s pada 10 Hz berarti tiap paket menempuh ±0,6 m — celah ini ditutup interpolasi di klien (§1.3), bukan dengan menaikkan rate.

### 1.3 MultiplayerSynchronizer — konfigurasi

Satu `MultiplayerSynchronizer` per avatar, sebagai anak dari node avatar, dikonfigurasi **dari kode** (pola skill `godot-multiplayer` Pattern 4 — tanpa klik Replication dock, supaya build server headless dan klien web memakai konfigurasi yang sama persis):

```gdscript
# Di _ready() avatar (player.gd / remote_player.gd) — PSEUDOCODE DESAIN, bukan kode final.
var config := SceneReplicationConfig.new()
config.add_property(^"sync_position")
config.property_set_replication_mode(^"sync_position",
    SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
config.add_property(^"sync_yaw")
config.property_set_replication_mode(^"sync_yaw",
    SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
config.add_property(^"pose_id")
config.property_set_replication_mode(^"pose_id",
    SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
config.add_property(^"outfit")
config.property_set_replication_mode(^"outfit",
    SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
sync.replication_config = config
sync.replication_interval = 0.1   # 10 Hz, eksplisit — jangan andalkan default
```

**Keputusan desain — interpolasi, bukan tulis langsung ke `position`:**

- Synchronizer TIDAK menulis ke `position` node secara langsung. Ia menulis ke `sync_position` / `sync_yaw` (variabel biasa).
- Avatar remote (bukan otoritas) menggerakkan `position`-nya sendiri tiap frame dengan lerp menuju `sync_position` (`position = position.lerp(sync_position, delta * 10)` — konstanta lerp diputuskan saat implementasi, bukan di sini).
- Alasan: kalau synchronizer menulis `position` langsung, gerakan pemain lain melompat 0,6 m tiap 100 ms (patah-patah). Dengan variabel perantara + lerp, gerakan terlihat halus tanpa menaikkan rate di atas 10 Hz.
- Pemilik avatar sendiri TIDAK memakai jalur ini: posisinya hasil `move_and_slide()` lokal, dan `sync_position` diisi dari `position` tiap frame (pemilik adalah otoritas — lihat 1.5).

### 1.4 MultiplayerSpawner — konfigurasi

- Satu `MultiplayerSpawner` di node `Players` (anak dari root scene main, dibuat di `main.gd`), `spawn_path = ^"Players"`, `add_spawnable_scene(player_scene)` dengan scene avatar yang sama untuk putra dan putri (visual dibedakan `build_visual`, bukan scene berbeda).
- `spawn_function` kustom (wajib — `MultiplayerSpawner.spawn()` error tanpa ini, per skill): server memanggil `spawn_function(peer_id)` → membangun avatar lewat `SantriPlayer.build_visual(nama, outfit)` yang SUDAH ADA dan dipakai pemain + NPC — avatar pemain lain memakai pabrik yang sama, bukan membangun pabrik baru.
- **Nama node = `str(peer_id)`.** Ini yang membuat pemetaan otoritas bekerja (skill Pattern 3: `set_multiplayer_authority(name.to_int())`). NodePath harus sama di semua peer, kalau tidak RPC salah alamat.
- Spawn HANYA dilakukan server (peer id 1). Klien tidak pernah spawn avatar sendiri — klien yang mencoba spawn lokal langsung ditolak (bukan otoritas spawn).
- Data spawn (nama, jenis_kelamin, outfit) diambil server dari DB saat handshake tiket — BUKAN dari paket kiriman klien. Klien yang mengirim nama/outfit berbeda dari DB: server memakai data DB dan mengabaikan kiriman klien.
- Despawn: `peer_disconnected` → server menghapus node avatar itu → spawner menghapusnya di semua klien otomatis. Disconnect = avatar hilang di semua klien (kriteria Fase 1).
- Spawn point sesuai gender (dari rencana induk §0): putra (−4, 14), putri (130, 14). Reconnect → respawn di titik spawn (bukan posisi terakhir — itu Fase 3).

### 1.5 Otoritas per avatar

| Avatar | Otoritas | Yang boleh dilakukan |
|---|---|---|
| Avatar sendiri (lokal) | Klien pemilik (`set_multiplayer_authority(peer_id)` di `_ready`, dari nama node) | Baca input, `move_and_slide()`, isi `sync_position`/`sync_yaw`/`pose_id`. |
| Avatar pemain lain | Pemiliknya masing-masing (bukan klien lokal, bukan server) | Klien lokal HANYA menampilkan: lerp posisi, putar yaw, mainkan animasi sesuai `pose_id`, tampilkan nama. DILARANG: baca input, jalankan fisika, ubah `sync_*`. |
| Validasi | **Server (id 1)** — bukan otoritas node, tapi otoritas aturan | Cek tiap posisi yang masuk: kecepatan ≤ 6 m/s + toleransi; zona gender (§1.4 rencana induk); tolak teleport mendadak. |

**Aturan emas (dari skill):** klien tidak dipercaya. Server tidak menerima posisi begitu saja — server menyimpan `posisi_legal_terakhir` tiap pemain; posisi yang melanggar (di luar zona, teleport, terlalu cepat) DITOLAK dan pemain dikembalikan ke posisi legal terakhir. Pola snap-back ini SUDAH ADA di `main.gd:319` — dipakai ulang, bukan dibuat baru.

**RPC Fase 1 — sesedikit mungkin** (set RPC HARUS identik di build klien dan server, kalau tidak checksum gagal — skill Gotchas):

| RPC | Arah | Mode | Fungsi |
|---|---|---|---|
| `submit_ticket(ticket: String)` | klien → server | `@rpc("any_peer", "reliable")`, hanya server yang memproses | Handshake setelah connect WebSocket. Server validasi tiket ke DB/API, lalu spawn avatar. Tanpa tiket valid → koneksi diputus. |
| `zone_reject(pos_legal: Vector3)` | server → klien pemilik | `@rpc("any_peer", "reliable")` di node server-owned (bukan di node avatar — lihat catatan) | Beri tahu pemilik: posisimu ditolak, kembali ke `pos_legal`. |

Catatan RPC: mode default `@rpc` adalah `"authority"` — panggilan server ke node yang otoritasnya dipegang klien akan DITOLAK engine ("RPC not allowed ... Mode is authority"). Karena itu RPC dari server ke klien HARUS `"any_peer"` + cek `multiplayer.get_remote_sender_id() == 1` di dalam fungsi (skill Pattern 2), ATAU diletakkan di node yang dimiliki server (mis. `network_manager` / game manager). Tim implementasi memilih salah satu dan konsisten — jangan campur.

**Mode offline (kriteria Fase 1, jangan dilupakan):** kalau server realtime mati / tidak ada koneksi, game TETAP jalan seperti sekarang — pemain lokal spawn seperti biasa (`SantriPlayer.new()`), tanpa peer (`OfflineMultiplayerPeer`), tanpa synchronizer/spawner aktif. Game tidak boleh rusak hanya karena server realtime mati. Tombol "Masuk Dunia" yang gagal connect menampilkan status di UI, bukan crash.

### 1.6 Urutan refactor `player.gd` (langkah-demi-langkah, kerjakan berurutan)

File ini 1.445 baris dan SEDANG DIEDIT Raka — JANGAN disentuh sebelum ronde Raka di-deploy. Begitu ronde itu selesai, kerjakan dalam urutan ini (satu langkah selesai + dites dulu sebelum langkah berikutnya):

**Langkah 1 — Bekukan perilaku sekarang.** Sebelum mengubah apa pun: catat (di komentar / dokumen ronde) perilaku `player.gd` yang sekarang: input apa saja dibaca, kapan animasi ganti, kapan `build_visual` dipanggil. Tes main offline sekali sebagai baseline. Tujuannya: kalau refactor merusak sesuatu, ketahuan di langkah mana.

**Langkah 2 — Pisah visual dari input.** Pindahkan SEMUA pembacaan input (`Input.get_vector`, aksi, dsb.) ke satu fungsi, mis. `_baca_input() -> Vector3`. Semua pemakaian input di `_physics_process` diganti panggilan ke fungsi itu. Visual (`build_visual`, ganti pose/animasi, label nama) TIDAK BOLEH memanggil fungsi input. Hasil: file tetap jalan offline persis seperti sebelumnya, tapi input sudah terkumpul di satu tempat.

**Langkah 3 — Tambah gerbang otoritas.** Di `_ready()`: `set_multiplayer_authority(name.to_int())` bila node berada di bawah `Players` multiplayer (nama node = peer id); bila spawn offline seperti sekarang (nama bukan angka peer), otoritas = lokal. Di awal `_physics_process`: `if not is_multiplayer_authority(): return` — avatar remote tidak membaca input dan tidak menjalankan fisika. Di awal `_baca_input()`: kembalikan vektor nol bila bukan otoritas (pengaman ganda).

**Langkah 4 — Pisah properti sync.** Tambah variabel `sync_position: Vector3`, `sync_yaw: float`, `pose_id: int` (enum, lihat 1.2). Pemilik: tiap frame isi ketiganya dari keadaan lokal (`sync_position = position`, dst.). BUKAN pemilik: JANGAN isi variabel ini dari logika lokal — nilainya datang dari synchronizer. Pasang `MultiplayerSynchronizer` (konfigurasi §1.3) sebagai anak avatar.

**Langkah 5 — Interpolasi remote.** Di `_process(delta)` (bukan `_physics_process`): bila BUKAN otoritas, `position = position.lerp(sync_position, delta * 10)` dan `rotation.y = lerp_angle(rotation.y, sync_yaw, delta * 10)`. Bila otoritas, lewati blok ini sepenuhnya (posisi pemilik dari fisika lokal).

**Langkah 6 — Pose dari `pose_id`, bukan dari input.** Ganti pemicu ganti animasi: pemilik mengeset `pose_id` saat keadaannya berubah (mulai jalan → 1, berhenti → 0, duduk → 2, dst.); SEMUA avatar (termasuk pemilik) memainkan animasi visual berdasarkan `pose_id`, bukan berdasarkan input langsung. Dengan begitu pemain lain terlihat duduk/sholat dengan animasi yang sama persis. `animasi_mixamo.gd` (file Raka — jangan disentuh sebelum deploy) hanya dipanggil lewat `pose_id`, tidak langsung dari input.

**Langkah 7 — Nama di atas kepala dari data spawn.** Label nama (Label3D) diisi dari data yang diberikan server saat spawn (nama DB), bukan dari `save_data` lokal dan bukan dari kiriman klien. Untuk avatar lokal sendiri, nama tetap dari login seperti sekarang.

**Langkah 8 — `remote_player.gd` (file baru, wilayah Bara — koordinasi, jangan tabrakan).** Keputusan arsitektur: avatar remote memakai script ini (visual + interpolasi + label nama + `pose_id` → animasi; TANPA input, TANPA fisika, TANPA kamera), sedangkan `player.gd` yang sudah direfactor hanya untuk avatar lokal. Alternatif (satu script dengan cabang otoritas) DITOLAK untuk Fase 1 — dua script lebih mudah dites terpisah, dan `remote_player.gd` tidak berisiko merusak jalan offline pemain lokal. Konsekuensi yang harus dijaga: set `@rpc` di kedua script HARUS identik di build klien dan server (checksum), dan `build_visual` dipakai bersama — jangan duplikasi pabrik visual.

**Langkah 9 — `main.gd`: `_player` tunggal → `Players` + spawner.** (File Raka juga — sesudah deploy.) Tambah node `Players` + `MultiplayerSpawner` (§1.4). Alur baru: login → tombol "Masuk Dunia" → `network_manager` connect + `submit_ticket` → server spawn avatar di `Players` → kamera mengikuti avatar milik sendiri (cari anak `Players` yang namanya = peer id sendiri). Alur offline: tidak ada peer → spawn lokal seperti sekarang. **Jangan hapus alur offline** — itu kriteria lolos Fase 1.

**Langkah 10 — `ui.gd`: status koneksi + daftar pemain mini.** Tambah indikator status (Offline / Menghubungkan / Online + jumlah pemain) dan daftar nama pemain yang sedang online (dari `multiplayer.get_peers()` + nama spawn). Feed chat MLBB TIDAK disentuh Fase 1 (itu Fase 2).

**Langkah 11 — Tes 2 pemain (kriteria rencana induk §2 Fase 1).** Dua HP/browser (satu putra, satu putri): saling lihat bergerak + nama; putra mencoba masuk area putri → ditolak server (snap-back, BUKAN cuma ditahan klien — buktikan dengan mematikan validasi klien di tes, server tetap menolak); keluar-masuk ulang tanpa error; matikan server realtime → game tetap bisa dimainkan offline.

### 1.7 Yang SENGAJA TIDAK dikerjakan Fase 1 (jangan ditambah diam-diam)

Chat antar pemain, sinkron interior, sholat berjamaah multiplayer, poin dari kejadian multiplayer, suara, sinkron NPC, ranking dalam game, uji lebih dari 2 pemain (cap kode 8 dulu — lihat §2.1 soal dari mana angka 8 itu diganti).

---

## 2. Desain ruangan dengan cap yang bisa dinaikkan

### 2.1 Masalahnya — pertanyaan Mas (00:07 WIB)

> "Kalau 1 ruang 100 santri apakah aman?"

Rencana induk (§2 Fase 2) mengusulkan cap **20/ruangan** dan (§7) satu ruangan = satu proses server realtime. Jawaban jujur dokumen ini: **20 adalah angka awal yang aman menurut hitungan; 100 BELUM terbukti aman — aman atau tidaknya ditentukan uji beban (§3), bukan asumsi.** Karena itu cap dirancang sebagai **pengaturan, bukan hardcode**, supaya menaikkan cap nanti adalah ubah satu angka + uji, bukan ubah kode di banyak tempat.

### 2.2 Aturan desain cap

1. **Satu sumber kebenaran.** Cap tinggal di SATU tempat: konstanta di server realtime, mis. `room_config.gd` (server) — `const MAX_PLAYERS_PER_ROOM := 20`. Semua kode lain (transport, spawner, UI "ruangan penuh") MEMBACA dari konstanta ini. DILARANG menulis angka 20 (atau 8, atau 100) di file lain.
2. **Ditegakkan server, bukan klien.** Saat peer ke-(cap+1) mencoba join, SERVER menolak: tidak spawn avatar, kirim alasan "ruangan penuh", putuskan koneksi. Klien hanya menampilkan pesan itu. Klien yang memodifikasi angka cap di pihaknya sendiri tidak mendapat apa-apa — server tetap menolak.
3. **Satu ruangan = satu proses server.** Tiap proses realtime melayani SATU ruangan, di satu port (ruangan 1 → `127.0.0.1:8791`, ruangan 2 → `8792`, dst. — port per ruangan diputuskan Fase 0/ops, bukan di sini). Menambah ruangan = menjalankan proses baru, bukan mengubah kode game. REST API tetap satu sumber kebenaran untuk akun/poin/ranking; server realtime tidak menyimpan data permanen (§7 rencana induk).
4. **Cap kode Fase 1 = 8, cap operasi = 20.** Rencana induk Fase 1 menulis "cap kode 8 dulu, dites 2". Artinya: konstanta di kode boleh ditulis 8 selama Fase 1 (supaya tidak ada yang menguji 20 orang sebelum sistemnya siap), TAPI angka itu tetap SATU konstanta yang sama — menaikkan ke 20 di Fase 2 adalah ubah satu baris + uji, bukan refactor. Jangan menulis 8 di satu file dan 20 di file lain.
5. **Pemain yang ditolak harus dapat jalan keluar.** Klien yang ditolak "ruangan penuh" menampilkan: nama ruangan, jumlah pemain saat ini, dan tombol pindah ke ruangan lain (bila ruangan lain ada) — bukan layar hitam / error mentah.

### 2.3 Angka-angka: 20 vs 100 pemain per ruangan

Dasar hitungan dari §3 rencana induk: paket sinkron ±50–80 byte, 10 Hz, naik ±0,8 KB/detik per pemain, turun ±0,6 KB/detik per pemain lain. Server relay 20 pemain: 20 × 10 Hz × 19 penerima ≈ **3.800 paket/detik**.

| Ukuran | 2 pemain | 20 pemain (cap awal) | 50 pemain | 100 pemain |
|---|---|---|---|---|
| Paket relay server/detik (N × 10 × (N−1)) | 20 | **3.800** | 24.500 | **99.000** |
| Turun per klien (KB/detik) | 0,6 | ±11,4 | ±29,4 | ±59,4 |
| Turun per klien (kbit/detik) | ±5 | ±91 | ±235 | ±475 |
| Naik per klien | 0,8 KB/detik | 0,8 KB/detik | 0,8 KB/detik | 0,8 KB/detik |
| Validasi posisi server/detik (N × 10) | 20 | 200 | 500 | 1.000 |
| Avatar yang harus digambar tiap klien | 1 | 19 | 49 | 99 |

Beban naik **kuadrat** terhadap jumlah pemain (tiap pemain baru menambah paket ke SEMUA pemain yang sudah ada) — 100 pemain bukan 5× beban 20 pemain, melainkan **±26×** (99.000 vs 3.800 paket/detik).

**Bandwidth: bukan masalah.** ±59 KB/detik turun (≈ 475 kbit/detik) masih ringan untuk data seluler 4G. Kalau ada yang bilang 100 pemain gagal karena bandwidth, itu salah diagnosis.

**Dua bottleneck yang sesungguhnya:**

1. **Server (VPS 2 vCPU, berbagi dengan Hermes, jembatan WA 3000/3001, Next.js).** 99.000 paket/detik relay + 1.000 validasi/detik + framing WebSocket per paket, di satu proses Godot headless. Validasi posisinya ringan (1.000/detik bukan apa-apa); yang berat adalah fan-out relay + overhead per paket WebSocket. Apakah 2 vCPU sanggup? **Tidak diketahui — belum pernah diuji.** Perkiraan arsitek: 20 pemain (≈ 3.800 paket/detik) ringan; 50 (≈ 24.500) mungkin masih sanggup; 100 (≈ 99.000) meragukan di VPS yang berbagi layanan lain. Tapi ini perkiraan, bukan fakta — §3 yang membuktikan.
2. **HP klien (Galaxy A35, target uji Mas).** 99 avatar × ±6–10 MeshInstance3D primitif per avatar (torso, peci, sarung, sandal, label nama, dst. — pabrik `build_visual`) = **±600–1.000 draw call hanya untuk pemain lain**, ditambah 99 synchronizer yang tiap 100 ms memperbarui `sync_position`. HP kemungkinan besar kehabisan napas di gambar SEBELUM server kehabisan napas di relay. Ini alasan kedua kenapa 100/ruangan belum boleh diasumsikan aman.

### 2.4 Interest management — pengurang beban, BUKAN pengaman

**Ide:** server hanya mengirim update posisi pemain yang "relevan" bagi penerima — yang dekat atau satu zona — bukan semua pemain di ruangan. Di Godot 4.7 ini memakai filter visibilitas per-peer pada `MultiplayerSynchronizer` (`public_visibility` / `set_visibility_for(peer_id, visible)` — lihat referensi skill `references/replication-and-rpc.md`).

**Aturan relevansi yang diusulkan (Fase 2, bukan Fase 1):**

- Satu zona = satu kelompok relevansi: putra hanya menerima update pemain putra (zona putra + area bersama), putri hanya putri. Ini otomatis membagi ruangan jadi dua — pemain putra tidak pernah menerima paket pemain putri, dan sebaliknya.
- Di dalam satu zona: hanya pemain dalam radius pandang, mis. **±50 m** dari penerima (angka awal — diputuskan dari ukuran dunia + tes HP, bukan dari dokumen ini). Pemain di luar radius: tidak dikirimi update posisi (avatarnya tidak digambar / digambar diam di posisi terakhir — diputuskan di Fase 2).
- Nama + daftar pemain mini tetap memakai data ruangan (bukan radius) — pemain tetap tahu siapa saja online, hanya gerakannya yang tidak dikirim kalau jauh.

**Efek pada angka (perkiraan):**

| Ukuran | Tanpa interest mgmt (paket relay/detik) | Dengan interest mgmt, pemain tersebar (perkiraan) |
|---|---|---|
| 20 pemain | 3.800 | ±1.500–2.500 (tetangga dekat saja) |
| 100 pemain | 99.000 | ±10.000–25.000 (bila rata-rata tiap pemain hanya melihat 10–25 tetangga) |

**Batasan JUJUR yang wajib dicatat:**

- Interest management mengurangi beban **tipikal**, bukan beban **terburuk**. Kalau 100 santri berkumpul di satu tempat (mis. Surau saat sholat berjamaah — skenario yang PASTI terjadi), semua saling dalam radius → interest set = 100 → beban kembali ke 99.000 paket/detik + 99 avatar digambar. Tidak ada interest management yang menyelamatkan skenario berkumpul.
- Karena itu cap tetap ditegakkan server (§2.2 butir 2) berapapun interest management-nya. Interest management membuat 20 pemain lebih ringan dan membuat 50 pemain mungkin; ia TIDAK membuat 100 pemain otomatis aman.
- Interest management TIDAK dibangun di Fase 1. Fase 1: semua pemain di ruangan saling melihat (2 pemain — tidak ada yang perlu difilter). Desainnya ditulis sekarang supaya Fase 2 tidak membangun ulang synchronizer.

### 2.5 Kesimpulan untuk Mas

- **Cap awal tetap 20/ruangan** sampai uji beban (§3) membuktikan lebih.
- **100/ruangan BELUM terbukti aman.** Bandwidth-nya aman; yang belum terbukti adalah CPU server relay 99.000 paket/detik dan HP yang menggambar 99 avatar. Keduanya hanya bisa dijawab dengan uji, bukan hitungan di atas kertas.
- **Kalau 100 santri online bersamaan sebelum cap naik:** mereka terbagi ke ±5 ruangan @20 — tetap bisa main, tetap terhubung lewat ranking + chat global (server pusat, di luar dunia 3D), hanya tidak saling lihat semua dalam satu dunia 3D. Itu trade-off sharding yang sudah dijawab Mas 23:56 — dan jawabannya tetap sama: kumpulkan acara bersama (sholat, khataman) di satu ruangan.
- **Jalur naik cap:** 20 → (uji lolos) → 50 → (uji lolos) → 100. Tiap kenaikan = ubah SATU konstanta + restart service + uji ulang. Tidak ada refactor.

---

## 3. Rencana uji beban ke arah 100 pemain/ruangan

**Status: RENCANA — dijalankan nanti, bukan sekarang.** Server realtime-nya belum ada (Fase 0 belum selesai), jadi tidak ada yang bisa diuji hari ini. Rencana ini ditulis sekarang supaya saat server selesai, tim QA langsung jalan tanpa merancang dari nol.

### 3.1 Prinsip

- Uji **bertahap, satu tahap lolos baru naik**. Tidak ada lompat dari 2 langsung ke 100.
- Tiap tahap diuji di **dua sisi**: server (angka VPS) DAN HP (rasa main). Server lolos tapi HP patah-patah = GAGAL.
- Bot **tidak boleh** memakai jalan pintas auth. Bot login lewat REST seperti pemain biasa, memakai akun santri tes khusus (dibuat lewat `POST /api/santri/register`, BUKAN data santri produksi, BUKAN token `X-PV-Token`). Tidak ada "mode tes" yang mematikan validasi zona/kecepatan di server — kalau validasi dimatikan saat uji, hasil uji tidak berarti apa-apa.
- Bot bergerak seperti pemain sungguhan: jalan acak dalam zonanya (kecepatan ≤ 6 m/s), kadang berhenti, kadang berkumpul di satu titik (simulasi sholat — skenario terburuk §2.4), kadang keluar-masuk. Bot yang diam di tempat TIDAK menguji apa-apa.

### 3.2 Yang perlu dibangun dulu (sebelum uji pertama — Fase 1/2)

- Mode bot di klien headless: jalankan game dengan argumen `-- --bot <id_santri_tes>` (pola skill Pattern 5: `OS.get_cmdline_user_args()`), bot login + join + jalan acak otomatis. Satu proses headless = satu bot.
- Pencatat metrik di server realtime: tiap 10 detik tulis ke log: jumlah peer, paket relay/detik, CPU proses (%), RAM proses, paket ditolak validasi. Tanpa ini, uji hanya "kelihatannya lancar" — tidak ada angka.
- Akun santri tes: 100 akun (mis. `PV-TEST-001` s.d. `PV-TEST-100`, putra/putri seimbang) — dibuat sekali, dipakai ulang tiap uji.

### 3.3 Tahapan

| Tahap | Klien | Skenario | Yang dibuktikan |
|---|---|---|---|
| T0 — Asap (smoke) | 2 headless | Host + join, jalan 60 detik | Handshake + sync dasar jalan (ini kriteria Fase 0, sudah direncanakan) |
| T1 — MVP | 2 HP (putra + putri) | Saling lihat, zona ditolak, disconnect/reconnect | Kriteria Fase 1 (§1.6 langkah 11) — rasa main di HP |
| T2 — Ruangan kecil | 5 (2 HP + 3 headless) | Chat + sholat serentak | Kriteria Fase 2 |
| T3 — Cap awal | 20 headless + 2 HP | 20 bot tersebar + 2 HP ikut main 10 menit | **Cap 20 terbukti aman** — ini gerbang sebelum cap boleh naik |
| T4 — Setengah jalan | 50 headless + 2 HP | 50 bot: 5 menit tersebar, 5 menit berkumpul di Surau | Apakah 50 aman? Termasuk skenario berkumpul (terburuk) |
| T5 — Target Mas | 100 headless + 2 HP | 100 bot: 5 menit tersebar, 5 menit berkumpul di Surau | **Apakah 100/ruangan aman?** — jawaban pertanyaan Mas |

**Catatan praktis T4–T5:** 50–100 proses Godot headless TIDAK BOLEH dijalankan di VPS yang sama dengan server yang diuji — bot-bot itu sendiri memakan CPU dan akan merusak hasil. Bot dijalankan dari mesin lain (VM Xam atau mesin kedua), atau bertahap dalam gelombang bila mesin bot terbatas. Kalau mesin bot tidak sanggup 100 proses sekaligus, uji T5 dijalankan sebagai 4 gelombang × 25 bot yang overlap — dicatat di laporan uji sebagai keterbatasan, bukan disembunyikan.

### 3.4 Metrik yang diukur tiap tahap

| Metrik | Cara ukur | Ambang lolos (tahap T3–T5) |
|---|---|---|
| CPU server realtime | `systemd` / `ps` per proses, rata-rata 5 menit | < 70% dari 1 core sustained (sisa untuk Hermes/WA/Next.js) |
| RAM server realtime | `ps` RSS | < 500 MB (angka awal — direvisi setelah T3 memberi baseline) |
| Paket relay/detik | pencatat metrik server (§3.2) | sesuai hitungan §2.3 ±20% (lebih tinggi jauh = ada relay ganda / bug) |
| Bandwidth server (naik+turun) | `iftop`/`nload` atau pencatat metrik | < 5 MB/detik total (ruangan 100 tanpa interest mgmt ≈ 100 × 0,8 KB/s naik + 100 × 59 KB/s turun ≈ 6 MB/detik — ambang ini akan direvisi setelah T3; yang penting angkanya TERCATAT) |
| Latensi (ping antar peer) | log klien: waktu kirim → update diterima | median < 150 ms di data seluler |
| ERROR di log | `grep ERROR` di log server + klien | NOL baris `ERROR:` selama tahap berjalan |
| Frame time HP | pengamatan + FPS counter di HP Mas (2 HP) | ≥ 30 fps stabil saat jumlah avatar terlihat = jumlah pemain dalam radius; tidak ada freeze > 500 ms |
| Rubber-banding / teleport | pengamatan di HP: avatar lain melompat / kembali ke belakang | tidak ada yang terlihat mata telanjang selama 10 menit |
| Validasi zona | bot "nakal" khusus: 1 bot mencoba teleport + masuk zona lawan | server menolak 100% (snap-back tercatat di log) |

### 3.5 Kriteria lolos / gagal dan kapan cap boleh naik

- **Satu tahap DINYATAKAN LOLOS bila:** semua metrik §3.4 dalam ambang SELAMA 10 menit penuh, di skenario tersebar DAN berkumpul, dan NOL `ERROR` di semua log. Laporan uji ditulis (angka + tanggal + siapa menguji) sebelum cap disentuh.
- **GAGAL bila:** satu metrik saja melewati ambang, atau ada `ERROR`, atau HP patah-patah. Gagal = berhenti di tahap itu, cari penyebab, perbaiki, ULANG tahap yang sama dari awal. DILARANG menaikkan cap untuk "mengakali" hasil gagal.
- **Cap boleh naik bila:** tahap pada cap itu LOLOS. Urutan: T3 lolos → cap 20 dikunci sebagai cap operasi Fase 2. T4 lolos → cap boleh 50. T5 lolos → cap boleh 100. Tiap kenaikan: ubah SATU konstanta (§2.2 butir 1) + restart service + uji ulang 10 menit pada cap baru.
- **Bila T5 gagal tapi T4 lolos:** cap berhenti di 50. Itu HASIL yang sah, bukan kegagalan proyek — 50/ruangan × banyak ruangan tetap melayani ratusan santri bersamaan (§7 rencana induk). Jangan memaksa 100 dengan mengorbankan HP Mas yang patah-patah.
- **Interest management (§2.4)** diuji sebagai varian T4/T5: jalankan tahap yang sama dua kali (tanpa dan dengan interest management) dan bandingkan angka — supaya klaim "interest management membantu" punya bukti, bukan asumsi.

---

## 4. Daftar siap Fase 1

Dicek langsung ke workspace + `server/` pada 18 Nov 2026 ~00:10 WIB (bukan dari ingatan — yang tidak ditemukan ditulis BELUM, bukan diasumsikan ada).

### 4.1 Sudah siap

| # | Item | Bukti |
|---|---|---|
| 1 | Rencana induk multiplayer | `MULTIPLAYER-PLAN.md` (§1–§9) — arsitektur, fase, angka, risiko, skala |
| 2 | Desain sync Fase 1 | Dokumen ini §1 — properti, rate, spawner, synchronizer, otoritas, urutan refactor `player.gd` langkah 1–11 |
| 3 | Desain ruangan cap configurable | Dokumen ini §2 — satu konstanta, ditegakkan server, angka 20 vs 100 |
| 4 | Rencana uji beban ke 100 pemain | Dokumen ini §3 — tahap T0–T5, metrik, kriteria lolos/gagal |
| 5 | Aturan pesantren yang ditegakkan server | Rencana induk §1.4 + pola snap-back sudah ada di `main.gd:319` (dipakai ulang) |
| 6 | Pabrik visual avatar bersama | `SantriPlayer.build_visual(nama, outfit)` sudah ada — dipakai pemain, NPC, dan nanti avatar remote |
| 7 | UI feed chat MLBB (untuk Fase 2) | `ui.gd` `tampilkan_pesan_melayang` sudah ada — tinggal relay server di Fase 2 |
| 8 | Skill + pola yang dipakai | `godot-multiplayer` (ENet/`@rpc`/spawner/synchronizer, smoke test 2 instance) — transport diganti WebSocket untuk web |

### 4.2 Sedang dikerjakan orang lain — perlu konfirmasi Dimas (bukan ditebak)

| # | Item | Pemilik | Status saat dokumen ini ditulis |
|---|---|---|---|
| 9 | Bootstrap multiplayer (`scripts/multiplayer/` — `network_manager.gd` + `remote_player.gd`) | Bara | **Belum ada di workspace** — folder `v2/godot-dunia/scripts/multiplayer/` tidak ditemukan saat dicek. Perlu konfirmasi Dimas: sudah mulai / belum. |
| 10 | Tiket auth realtime (endpoint `POST /api/santri/realtime_ticket` cara (a), atau validasi read-only cara (b)) | Saka | **Belum ada di `server/server.py`** — tidak ditemukan string `realtime_ticket`. Keputusan cara (a)/(b) belum tercatat. |
| 11 | Route Caddy `/ws/` → `127.0.0.1:8791` | Wira | **Belum ada di salinan `server/Caddyfile`** — tidak ditemukan baris `ws`. Dikerjakan di VPS (Fase 0). |
| 12 | Preset export "Dedicated Server" + skrip build web+server satu commit + service systemd `pesantren-verse-realtime` | Lead multiplayer + Saka | Belum ada (Fase 0) — `export_presets.cfg` saat ini hanya preset `Web`. |

### 4.3 Masih menunggu — Fase 1 TIDAK BOLEH mulai sebelum ini selesai

| # | Item | Keterangan |
|---|---|---|
| 13 | **Ronde Raka selesai di-deploy** | File yang disentuh Raka: `main.gd`, `player.gd`, `npc.gd`, `registrasi_server.gd`, `gubuk_masuk.gd`, `tangga_surau.gd`, `animasi_mixamo.gd`, `buku_data.gd`. Refactor `player.gd` §1.6 dan perubahan `main.gd` §1.6 langkah 9 baru boleh dimulai setelah ronde ini live. |
| 14 | Fase 0 selesai + dites | Smoke test 2 instance headless lulus, service jalan, `wss://` terjangkau dari browser, `GET /health` REST tetap menjawab (kriteria rencana induk §2 Fase 0). Tanpa ini, Fase 1 tidak punya server untuk dihubungi. |
| 15 | Keputusan Mas yang masih terbuka (rencana induk §8) | Cap ruangan (usul tim: 20 — dipakai sebagai awal di dokumen ini), suara teks-dulu, prioritas sholat berjamaah, visibilitas lintas gerbang, satu akun dua perangkat, nama tampil selalu / hanya saat dekat. Tidak ada yang diputuskan sendiri di dokumen ini. |

### 4.4 Begitu ronde Raka di-deploy — urutan jalan Fase 1 (tanpa waktu tunggu)

1. Dimas konfirmasi butir 9–12 (siapa sudah selesai, siapa belum).
2. Lead multiplayer + tim gameplay kerjakan §1.6 langkah 1–11 berurutan.
3. QA (Xam + Mas): tes T1 (2 HP) → kriteria Fase 1.
4. Bila T1 lolos → Fase 1 selesai → lanjut Fase 2 (cap 20 + chat + sholat, §2 rencana induk) dengan uji T2–T3.

---

**Catatan penutup (jujur):** dokumen ini menyiapkan desain + rencana uji, bukan hasil uji. Jawaban "100 santri satu ruangan aman atau tidak" belum ada — dan tidak akan ada sampai T5 dijalankan. Yang dokumen ini jamin: (a) cap-nya bisa diubah dengan satu baris, (b) server yang menolak kelebihan pemain, (c) rencana uji yang akan memberi jawaban itu dengan angka. Kalau T5 nanti gagal, cap berhenti di angka yang lolos — dan itu tetap jawaban yang benar.
