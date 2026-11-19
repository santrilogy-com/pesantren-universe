# Server Backend Pesantren Universe — Fase 1

**Status: LIVE — v1.5.2 sejak 18 Nov 2026 ~00:14 WIB.**
URL dasar API: **https://43-173-39-166.sslip.io**

Fase 1 mencakup: pendaftaran santri (publik), login + token sesi, verifikasi
ID Santri, sinkron poin + progres misi, ranking, **lamaran pengurus**
(v1.4.0), dan **pustaka kitab** (v1.5.0 — Jurumiyah, Arab saja, dari
OpenITI), **jenis kelamin** di registrasi (v1.5.1 — `"putra"`/`"putri"`),
dan **tiket realtime** untuk handshake WebSocket multiplayer (v1.5.2 —
keputusan Fase 0 cara (a), MULTIPLAYER-PLAN.md §1.3).
Server VPS adalah
**satu-satunya penyimpanan santri** — app memakai API ini, bukan DB lokal.
Multiplayer belakangan (butuh desain ENet server-authoritative terpisah).

## Arsitektur

| Lapisan | Pilihan | Alasan |
|---|---|---|
| Bahasa | Python 3.12, **stdlib saja** (http.server + sqlite3) | Tanpa dependensi — tidak ada npm/pip build, tidak ada yang bisa rusak saat update; cukup untuk traffic fase 1 (ribuan santri, request sesekali) |
| Data | SQLite (WAL) di `~/pesantren-verse-server/data/pesantren.db` | Pola yang sama seperti server CCS; satu file, backup = copy file |
| Proses | systemd `pesantren-verse-api` (auto-start saat reboot) | — |
| HTTPS | Caddy 2.11.9, reverse proxy ke `127.0.0.1:8790` | Sertifikat Let's Encrypt otomatis, auto-renew |
| Hostname | `43-173-39-166.sslip.io` | Memetakan otomatis ke IP publik VPS — **tanpa beli domain**. Kalau IP VPS berubah, hostname ini ikut berubah (perlu update URL di game/app). Domain sendiri bisa dipasang kapan saja tanpa mengubah API. |

VPS: `VM-32-104-ubuntu` (43.173.39.166), Ubuntu 24.04.4 LTS, 2 vCPU, RAM 7,4 GB.
API mendengarkan **hanya di 127.0.0.1:8790** — tidak bisa diakses langsung dari internet,
hanya lewat Caddy di 443. Port 80 dipakai Caddy untuk redirect + validasi sertifikat.
Layanan lain di VPS (Hermes, jembatan WhatsApp di 3000/3001, Next.js, dsb.) **tidak disentuh**.

## File di server

```
/home/ubuntu/pesantren-verse-server/
├── server.py            # API v1.5.2 (salinan juga ada di folder ini)
├── kitab/
│   └── jurumiyah.json   # Jurumiyah 25 bab, Arab saja, dicek_ustadz: false
├── konversi-jurumiyah.py # OpenITI mARkdown -> kitab/jurumiyah.json (sekali jalan)
├── patch-1.5.2.py       # script patch v1.5.1 -> v1.5.2 (7 penggantian, dicek)
├── test-v1.5.2.sh       # tes end-to-end tiket realtime (13 cek, dari mana saja)
├── cleanup-v1.5.2.py    # hapus santri tes v1.5.2 dari DB
├── server.py.1.5.1.bak  # backup kode sebelum patch v1.5.2
├── patch-1.5.1.py       # script patch v1.5.0 -> v1.5.1 (8 penggantian, dicek)
├── test-v1.5.1.sh       # tes end-to-end jenis_kelamin (6 cek, dari mana saja)
├── cleanup-v1.5.1.py    # hapus santri tes v1.5.1 dari DB
├── server.py.1.5.0.bak  # backup kode sebelum patch v1.5.1
├── test-v1.5.0.sh       # tes end-to-end pustaka kitab (dijalankan di VPS)
├── server.py.1.4.0.bak  # backup kode sebelum patch v1.5.0
├── patch-1.4.0.py       # script patch v1.3.0 -> v1.4.0 (10 penggantian, dicek)
├── test-v1.4.0.sh       # tes end-to-end lamaran (dijalankan di VPS)
├── cleanup-v1.4.0.py    # hapus santri tes v1.4.0 dari DB
├── server.py.1.2.0.bak  # backup kode sebelum patch v1.3.0
├── patch-1.3.0.py       # script patch v1.2.0 -> v1.3.0 (9 penggantian, dicek)
├── test-v1.3.0-token.sh # tes sisi-token (dijalankan di VPS)
├── cleanup-v1.3.0.py    # hapus santri tes v1.3.0 dari DB
├── .env                 # PV_TOKEN, PV_PORT, PV_DB — mode 600, JANGAN disebar
├── backup.sh            # backup DB (cron harian 03:00, simpan 7 hari)
├── backups/             # backup DB harian
└── data/
    └── pesantren.db     # SQLite (+ -wal, -shm)
```

Konfigurasi sistem:
- `/etc/systemd/system/pesantren-verse-api.service` (salinan: `pesantren-verse-api.service`)
- `/etc/caddy/Caddyfile` (salinan: `Caddyfile`)

## Token & sesi

- **X-PV-Token** (shared secret, 32 byte hex acak, di `.env` mode 600):
  **HANYA untuk `POST /api/santri/points`** (pemberian poin oleh game/server
  tepercaya). Token ini **tidak pernah keluar dari server** kecuali ke client
  tepercaya — app TIDAK memegangnya.
- **Register PUBLIK** (tanpa token): pendaftaran memang perbuatan publik
  (siapa pun boleh daftar jadi santri). Rate limit 120/menit/IP tetap berlaku.
- **Login publik**, mengembalikan **token sesi**: acak (`token_urlsafe(32)`),
  berlaku **1 jam**, **satu sesi per santri** (login baru menghapus sesi lama),
  **sekali pakai** untuk `set_password` (hangus setelah dipakai/kedaluwarsa).
- **`set_password` memakai token sesi** (field `"session"` di body), BUKAN
  X-PV-Token. Jadi app bisa memakai server sebagai satu-satunya penyimpanan
  santri tanpa memegang token bersama.
- **Tiket realtime (v1.5.2, MULTIPLAYER-PLAN.md §1.3 — cara (a)):** token sesi
  login **TIDAK BOLEH** dipakai langsung untuk handshake WebSocket (token itu
  juga mengesahkan `set_password`, dan server realtime Godot tanpa driver
  sqlite tidak bisa membaca tabel `sesi_login`). Alurnya: klien login seperti
  biasa, lalu `POST /api/santri/realtime_ticket` dengan token sesi yang masih
  berlaku → tiket acak, **5 menit, sekali pakai**. Token sesi **TIDAK hangus**
  saat minta tiket (tetap berlaku untuk `set_password` dan minta tiket lagi
  bila reconnect). Server realtime memvalidasi tiket lewat
  `POST /api/santri/realtime_ticket/validate` (**wajib X-PV-Token**, pola yang
  sama seperti `/points` — hanya komponen tepercaya di VPS yang sama);
  validasi yang berhasil langsung menandai tiket terpakai dan mengembalikan
  `id` + `nama` + `jenis_kelamin` dari DB (nama pemain lain selalu dari DB,
  bukan dari klien). Tiket/token **tidak pernah ditulis ke log**.
- Password santri **diisi sendiri oleh user** (saat daftar atau lewat
  set_password), disimpan sebagai hash `sha256$salt$digest` — plaintext tidak
  pernah disimpan dan tidak pernah dikembalikan endpoint mana pun.
- **Lamaran pengurus (v1.4.0):** `kirim` + `saya` **publik** (perbuatan santri
  sendiri, seperti register); `rekomendasi`, `keputusan`, dan `daftar` butuh
  X-PV-Token (musyrif/Pengasuh lewat app — token dipegang server app, bukan
  klien). Posisi valid: Keamanan, Ubudiyah, Kebersihan, Pendidikan,
  Humas & Media. Syarat kirim: santri terdaftar + Misi M1 selesai
  (asumsi v1.4.0: misi berurutan, jadi `misi_selesai >= 1` berarti M1 selesai);
  1 santri = 1 lamaran aktif; jeda 1 minggu setelah penolakan terakhir.
  Alur status: `menunggu_musyrif` → `menunggu_pengasuh` → `diterima` /
  `ditolak`. Rekomendasi musyrif (`"setuju"`/`"tidak"`) selalu meneruskan ke
  Pengasuh — keputusan akhir di Pengasuh; penolakan wajib `alasan_tolak`.

## Endpoint

Base URL: `https://43-173-39-166.sslip.io`

### GET /health
```bash
curl -s https://43-173-39-166.sslip.io/health
# {"ok":true,"service":"pesantren-verse-api","version":"1.3.0","time":"..."}
```

### POST /api/santri/register — PUBLIK (tanpa token)
Daftar santri baru, terbitkan ID `PV-XXXX` berurutan (transaksional, anti-duplikat).
Nama maks 30 huruf; `ig_username` **wajib + unik** (dinormalisasi: tanpa `@`,
huruf kecil); `jenis_kelamin` **wajib**: `"putra"` atau `"putri"` (nilai lain
atau kosong → 400); password opsional (min 6, maks 64); kota/email opsional.
**Sistem tunggal** (keputusan 15 Nov 2026): field `"jalur"` bila dikirim
diabaikan, bukan error. Duplikat `ig_username` → 409; tanpa `ig_username` → 400.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/register \
  -H 'Content-Type: application/json' \
  -d '{"nama":"Ahmad","ig_username":"ahmad.santri","password":"rahasia123","jenis_kelamin":"putra","kota":"Jakarta"}'
# {"ok":true,"created":true,"id":"PV-0002","nama":"Ahmad","ig_username":"ahmad.santri",
#  "jenis_kelamin":"putra","kota":"Jakarta","email":null,"total_poin":0,"tier":"Santri Baru"}   (HTTP 201)
```

### POST /api/santri/login — publik
Login pakai `ig_username`. Bila santri **belum punya password**, username saja
cukup; bila sudah punya, password wajib cocok. Login berhasil mengembalikan
token sesi (field `"session"`, `"session_expires_in": 3600`) dan
`"jenis_kelamin"` santri (`"putra"`/`"putri"`; `null` untuk santri lama).
Username tak dikenal → `found:false` (HTTP 200). Password salah → 401.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/login \
  -H 'Content-Type: application/json' \
  -d '{"ig_username":"ahmad.santri"}'
# {"id":"PV-0002","nama":"Ahmad","jenis_kelamin":"putra","jalur":"Misi","total_poin":0,"tier":"Santri Baru",
#  "created_at":"...","ok":true,"found":true,"login":true,"ig_username":"ahmad.santri",
#  "misi_selesai":0,"session":"wpx3kvZn-gFyGCNGSc5kb5c-q2ZHj9X8-WauifEelE8",
#  "session_expires_in":3600}
```

### POST /api/santri/set_password — token sesi (BUKAN X-PV-Token)
Isi/ubah password sendiri. Body: `{"session":"<token>","password":"<baru>"}`.
Field `"id"` opsional — bila diisi harus sama dengan pemilik token (kalau tidak
→ 403). Token sesi hangus setelah dipakai (dipakai lagi → 401
`"Token sesi sudah dipakai"`), kedaluwarsa 1 jam → 401, X-PV-Token sebagai
`"session"` → 401 `"Token sesi tidak valid"`.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/set_password \
  -H 'Content-Type: application/json' \
  -d '{"session":"<token-dari-login>","password":"baru1234"}'
# {"ok":true,"id":"PV-0002","password_set":true}
```

### POST /api/santri/realtime_ticket — token sesi (v1.5.2)
Terbitkan tiket realtime untuk handshake WebSocket server realtime.
Body: `{"session":"<token sesi login>"}`. Token sesi harus masih berlaku
(belum dipakai `set_password`, belum kedaluwarsa 1 jam) — kalau tidak → 401.
Token sesi **TIDAK hangus** karena ini. Respons: tiket acak
(`"expires_in": 300`, 5 menit, sekali pakai) + identitas santri dari DB.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/realtime_ticket \
  -H 'Content-Type: application/json' \
  -d '{"session":"<token-dari-login>"}'
# {"ok":true,"ticket":"<tiket>","expires_in":300,"id":"PV-0002","nama":"Ahmad","jenis_kelamin":"putra"}
```

### POST /api/santri/realtime_ticket/validate — butuh X-PV-Token (v1.5.2)
Validasi tiket realtime — **hanya server realtime tepercaya di VPS yang sama**
(wajib `X-PV-Token`, pola yang sama seperti `/points`). Body:
`{"ticket":"<tiket>"}`. Tiket yang valid langsung ditandai terpakai
(dipakai lagi → 401 `"Tiket realtime sudah dipakai"`); tiket tidak dikenal /
kedaluwarsa → 401; tanpa X-PV-Token yang benar → 401. Respons membawa
identitas dari DB supaya nama yang tampil ke pemain lain selalu dari DB.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/realtime_ticket/validate \
  -H 'Content-Type: application/json' \
  -H 'X-PV-Token: <TOKEN>' \
  -d '{"ticket":"<tiket>"}'
# {"ok":true,"id":"PV-0002","nama":"Ahmad","jenis_kelamin":"putra"}
```

### POST /api/santri/verify — publik
Verifikasi ID + kembalikan status santri. ID tidak dikenal → `found:false` (HTTP 200).
Respons menyertakan `"jenis_kelamin"` (`null` untuk santri lama tanpa gender).
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/verify \
  -H 'Content-Type: application/json' \
  -d '{"id":"PV-0001"}'
# {"ok":true,"found":true,"id":"PV-0001","nama":"Tes","jenis_kelamin":null,"jalur":"Misi",
#  "total_poin":0,"tier":"Santri Baru","misi_selesai":0,"created_at":"..."}
```

### POST /api/santri/points — butuh X-PV-Token (tetap)
Kirim poin misi. `poin` 1–100. `event_id` opsional tapi **dianjurkan**:
kirim ulang event yang sama tidak menggandakan poin (`duplicate:true`).
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/santri/points \
  -H 'Content-Type: application/json' \
  -H 'X-PV-Token: <TOKEN>' \
  -d '{"id":"PV-0001","misi":"M1","poin":10,"event_id":"PV-0001-M1-20261115"}'
# {"ok":true,"duplicate":false,"id":"PV-0001","total_poin":10,
#  "tier":"Santri Baru","misi_selesai":1}
```

### GET /api/ranking?limit=N — publik
Leaderboard global, urut poin turun (seri → pendaftar lebih dulu di atas). `limit` 1–50, default 10.
```bash
curl -s "https://43-173-39-166.sslip.io/api/ranking?limit=10"
# {"ok":true,"total_santri":1,"ranking":[
#   {"rank":1,"id":"PV-0001","nama":"Tes","jalur":"Misi","total_poin":0,"tier":"Santri Baru"}]}
```

## Lamaran pengurus (v1.4.0)

Desain: `organisasi/DESAIN-LAMARAN-PENGURUS.md` (ACC Mas 16 Nov 2026 ~15:55 WIB).
Tabel `lamaran` (id INTEGER PK, santri_id FK, posisi, posisi_cadangan,
alasan, pengalaman, status, rekomendasi_musyrif, catatan_musyrif, keputusan,
alasan_tolak, created_at, updated_at, diputuskan_at). Respons lamaran selalu
memuat `lamaran_id`, `santri_id`, `nama`, `ig_username`, `posisi`,
`posisi_cadangan`, `alasan`, `pengalaman`, `status`, `rekomendasi_musyrif`,
`catatan_musyrif`, `keputusan`, `alasan_tolak`, `created_at`, `updated_at`,
`diputuskan_at`.

### POST /api/lamaran/kirim — PUBLIK (tanpa token)
Kirim lamaran. Body: `{"id":"PV-XXXX"}` **atau** `{"ig_username":"..."}`,
ditambah `{"posisi":"Keamanan","alasan":"...","posisi_cadangan":"Ubudiyah" (opsional),
"pengalaman":"..." (opsional)}`. `alasan` wajib, maks 200 huruf;
`pengalaman` maks 200 huruf; `posisi_cadangan` bila diisi harus posisi lain
yang valid. Error: santri tidak ditemukan → 404; posisi tidak valid → 400;
M1 belum selesai → 400 `"Syarat belum terpenuhi: selesaikan Misi M1 dulu"`;
masih ada lamaran aktif → 409; dalam jeda 1 minggu setelah penolakan → 409
(dengan tanggal bisa melamar lagi).
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/lamaran/kirim \
  -H 'Content-Type: application/json' \
  -d '{"id":"PV-0002","posisi":"Keamanan","alasan":"Saya ingin menjaga pesantren"}'
# {"ok":true,"created":true,"lamaran_id":1,"santri_id":"PV-0002","posisi":"Keamanan",
#  "status":"menunggu_musyrif","created_at":"..."}   (HTTP 201)
```

### GET /api/lamaran/saya?santri_id=PV-XXXX — publik
Daftar lamaran satu santri (terbaru dulu). `ig_username` bisa dipakai sebagai
ganti `santri_id`. Santri tidak ditemukan → 404.
```bash
curl -s "https://43-173-39-166.sslip.io/api/lamaran/saya?santri_id=PV-0002"
# {"ok":true,"santri_id":"PV-0002","nama":"Uji Lamaran","total":1,"lamaran":[...]}
```

### GET /api/lamaran/daftar?status=... — butuh X-PV-Token
Semua lamaran (terbaru dulu) untuk musyrif/Pengasuh di app. Filter `status`
opsional (`menunggu_musyrif`, `menunggu_pengasuh`, `diterima`, `ditolak`);
status tidak valid → 400. Tanpa token → 401.
```bash
curl -s "https://43-173-39-166.sslip.io/api/lamaran/daftar?status=diterima" \
  -H 'X-PV-Token: <TOKEN>'
# {"ok":true,"total":1,"lamaran":[...]}
```

### POST /api/lamaran/rekomendasi — butuh X-PV-Token
Rekomendasi musyrif. Body: `{"lamaran_id":1,"rekomendasi":"setuju","catatan":"..."}`.
`rekomendasi` harus `"setuju"` atau `"tidak"`; `catatan` opsional (maks 200 huruf).
Hanya dari status `menunggu_musyrif` → jadi `menunggu_pengasuh` (rekomendasi
`"tidak"` pun diteruskan — keputusan akhir tetap di Pengasuh). Status lain → 409;
lamaran tidak ada → 404.
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/lamaran/rekomendasi \
  -H 'Content-Type: application/json' -H 'X-PV-Token: <TOKEN>' \
  -d '{"lamaran_id":1,"rekomendasi":"setuju","catatan":"Rajin sholat berjamaah"}'
# {"ok":true,"lamaran_id":1,"rekomendasi_musyrif":"setuju","status":"menunggu_pengasuh"}
```

### POST /api/lamaran/keputusan — butuh X-PV-Token
Keputusan Pengasuh. Body: `{"lamaran_id":1,"keputusan":"diterima"}` atau
`{"lamaran_id":1,"keputusan":"ditolak","alasan_tolak":"..."}` — `alasan_tolak`
**wajib** bila ditolak (tanpa itu → 400). Hanya dari status
`menunggu_pengasuh` → `diterima`/`ditolak`; `diputuskan_at` diisi saat itu
(jeda 1 minggu dihitung dari sini).
```bash
curl -s -X POST https://43-173-39-166.sslip.io/api/lamaran/keputusan \
  -H 'Content-Type: application/json' -H 'X-PV-Token: <TOKEN>' \
  -d '{"lamaran_id":1,"keputusan":"diterima"}'
# {"ok":true,"lamaran_id":1,"keputusan":"diterima","status":"diterima",
#  "diputuskan_at":"..."}
```

## Pustaka kitab (v1.5.0)

Rak kitab interaktif (ACC Mas 16 Nov 2026 ~18:47 WIB): **Arab saja**,
kitab pertama **Jurumiyah** dari OpenITI (CC BY-NC-SA 4.0). File-based:
`kitab/*.json` di folder yang sama dengan `server.py` — tambah kitab =
tambah file JSON, tanpa migrasi DB dan tanpa ubah kode. Tiap kitab
ditandai `dicek_ustadz` — **Jurumiyah masih `false`** (teks BELUM dicek
ustadz; pengecekan adalah langkah manusia, bukan tugas server).
Pembaca di game hanya menampilkan kitab yang `dicek_ustadz: true`.
Full MCP Shamela + fitur terjemahan **DITUNDA sampai ada gedung
Perpustakaan** (200 santri). Tiap respons kitab mencantumkan atribusi
`"Teks: OpenITI (CC BY-NC-SA 4.0)"`.

Konversi OpenITI mARkdown → JSON: `konversi-jurumiyah.py` (unduh ulang
file asli dari GitHub, buang `#META#` + penanda halaman `PageV...` +
penanda scan `msN`, pecah 25 bab dari heading `### |`, sambung lanjutan
baris `~~`). Teks Arab disimpan **apa adanya** (diakritik tidak
"diperbaiki"). Jurumiyah: 25 bab, 10.265 karakter (metadata OpenITI
menyebut 8.020 dengan cara hitung sendiri — tanpa spasi; teks bersih di
sini 8.493 tanpa spasi; tidak ada baris isi yang dibuang).

### GET /api/kitab — publik
Daftar kitab (urut abjad id): id, judul, pengarang, jumlah_bab,
ukuran_karakter, `dicek_ustadz`, atribusi.
```bash
curl -s https://43-173-39-166.sslip.io/api/kitab
# {"ok":true,"atribusi":"Teks: OpenITI (CC BY-NC-SA 4.0)","total":1,
#  "kitab":[{"id":"jurumiyah","judul":"متن الآجرومية","judul_latin":"Jurumiyah",
#  "pengarang":"ابن آجروم... (المتوفى: 723هـ)","pengarang_latin":"Ibn Ajrum (w. 723H)",
#  "jumlah_bab":25,"ukuran_karakter":10265,"dicek_ustadz":false,
#  "atribusi":"Teks: OpenITI (CC BY-NC-SA 4.0)"}]}
```

### GET /api/kitab/<id>[?bab=N] — publik
Isi kitab utuh (semua bab) atau satu bab (`?bab=N`). Kitab tidak ada →
404; bab tidak ada → 404; `bab` bukan angka → 400. Respons selalu
memuat `dicek_ustadz` + `atribusi`; kitab utuh juga memuat
`sumber`, `sumber_url`, `edisi`, `lisensi`.
```bash
curl -s "https://43-173-39-166.sslip.io/api/kitab/jurumiyah?bab=1"
# {"ok":true,"id":"jurumiyah","judul":"متن الآجرومية","dicek_ustadz":false,
#  "atribusi":"Teks: OpenITI (CC BY-NC-SA 4.0)",
#  "bab":{"nomor":1,"judul":"مدخل","teks":"...\n\nبسم الله الرحمن الرحيم\n\n...",
#  "jumlah_karakter":...}}
```

## Aturan yang disamakan dengan game

- ID `PV-XXXX` (4 angka, huruf besar), dari `scripts/save_data.gd`.
- Tier dari total poin (sama persis dengan game + app web):
  `>=100 Penjaga Lentera`, `>=50 Pembuka Peti`, `>=25 Penjelajah`, sisanya `Santri Baru`.
- Nama santri maks 30 huruf (sama dengan form daftar game).
- Login pakai `ig_username` (bukan ID): username saja bila belum berpassword,
  password wajib bila sudah punya (keputusan Mas 16 Nov 2026 — TIDAK ADA
  password via DM; password diisi sendiri user, opsional).

## Keamanan

- `X-PV-Token` hanya untuk `points`; tanpa/salah token → 401.
- `register`/`login` publik tapi rate limit 120 request/menit per IP → 429.
- `set_password` butuh token sesi sekali pakai (1 jam, satu sesi per santri).
- CORS: `Access-Control-Allow-Origin: *`, header `X-PV-Token` diizinkan
  (game di `pesantren-verse.pages.dev` perlu ini; preflight OPTIONS dijawab 204).
- Body maks 64 KB; validasi ketat (format ID, rentang poin, panjang nama/misi).
- API tidak pernah membuka port publik sendiri — hanya lewat Caddy.

## Operasional

```bash
# SSH (selalu pakai -i; exec jalan sebagai root, kunci ada di /home/hatch/.ssh)
ssh -i /home/hatch/.ssh/id_ed25519 ubuntu@43.173.39.166

# Restart API
sudo systemctl restart pesantren-verse-api
sudo systemctl status pesantren-verse-api --no-pager

# Lihat log API (live)
sudo journalctl -u pesantren-verse-api -f

# Lihat log Caddy
sudo journalctl -u caddy -f

# Cek data langsung (sqlite3 CLI tidak terpasang; pakai python)
python3 -c "import sqlite3; c=sqlite3.connect('/home/ubuntu/pesantren-verse-server/data/pesantren.db'); print(c.execute('SELECT id,nama,total_poin FROM santri ORDER BY total_poin DESC LIMIT 10').fetchall())"

# Backup DB manual (backup.sh dipakai cron harian 03:00, simpan 7 hari)
./backup.sh
```

**Pelajaran SSH (16 Nov 2026):** bila SSH gagal `Host key verification failed`,
kunci host harus ada di `/root/.ssh/known_hosts` — OpenSSH mengambil home dari
getpwuid (`/root`), BUKAN `$HOME` (`/home/hatch`), jadi `~/.ssh/known_hosts`
tidak dibaca. Fingerprint host VPS ED25519 yang benar:
`SHA256:MEaWdbRHdxO3NORavqRLkRfzidSAPdHmwbC7IPB2png` — cocokkan dulu dengan
`ssh-keyscan` sebelum menulis known_hosts. (Kadang SSH juga sempat timeout di
banner exchange lewat proxy egress — coba lagi; `nc` ke port 22 membuktikan
sshd hidup bila banner `SSH-2.0-OpenSSH...` muncul.)

## Verifikasi yang sudah dilakukan

### v1.0.0 (15 Nov 2026 ~18:30 WIB)
End-to-end lewat URL HTTPS publik, 13 cek — semua lolos:
register 2 santri (PV-0001, PV-0002 berurutan), verify ketemu/tidak ketemu,
poin M1+10/M2+15/M3+25 → total 50 tier "Pembuka Peti", kirim ulang `event_id`
yang sama tidak menggandakan poin, ranking urut benar, 401 tanpa/salah token,
404 poin ke ID tak dikenal, 400 format ID salah, CORS preflight 204 dari
origin `pesantren-verse.pages.dev`, restart service → data tetap ada.
**Data tes sudah dihapus — DB produksi mulai kosong (0 santri).**

Bug yang sempat muncul saat tes: body request yang tidak dibaca sebelum
menjawab 401 merusak request berikutnya di koneksi keep-alive yang dipakai
ulang Caddy (400 "Bad request syntax"). Diperbaiki: body selalu dibaca dulu
di `do_POST` sebelum routing.

### v1.3.0 (16 Nov 2026 ~15:31–15:33 WIB)
End-to-end lewat URL HTTPS publik, **26 cek — semua lolos** (skrip tes:
`test-v1.3.0.sh` + `test-v1.3.0-token.sh`):
- health = version 1.3.0.
- Register PUBLIK tanpa token → 201 (PV-0002, PV-0003 berurutan); duplikat
  `ig_username` → 409; tanpa `ig_username` → 400.
- Login username saja (belum berpassword) → 200 + `session` +
  `session_expires_in: 3600`; login dengan password baru → 200 + session
  baru yang berbeda; password salah → 401; username tak dikenal → `found:false`.
- `set_password` dengan session → 200; dipakai lagi → 401
  `"Token sesi sudah dipakai"`; tanpa session → 401; session orang lain +
  id orang lain → 403; **X-PV-Token sebagai session → 401 ditolak**.
- Satu sesi per santri: login 2× → session pertama hangus (401 saat dipakai).
- Session kedaluwarsa (di-expired-kan di DB) → 401 `"Token sesi sudah kedaluwarsa"`.
- `points` tanpa token → 401 (tetap); dengan token → 200; duplikat `event_id`
  → `duplicate:true`, total tidak ganda.
- Regresi: `verify` PV-0001 tetap jalan; ranking tetap jalan.
**Data tes sudah dihapus** (`cleanup-v1.3.0.py`) — DB kembali hanya PV-0001
"Tes" (0 poin); pendaftar berikut PV-0002. Backup DB sebelum migrasi:
`backups/pesantren-20261116-1630.db`; backup kode: `server.py.1.2.0.bak`.

### v1.4.0 (16 Nov 2026 ~15:58–16:00 WIB)
End-to-end lewat URL HTTPS publik, **40 cek — semua lolos** (skrip tes:
`test-v1.4.0.sh`, dijalankan di VPS; token dibaca dari .env, tidak dicetak):
- health = version 1.4.0.
- Register santri uji → PV-0002; kirim lamaran sebelum M1 → 400
  `"Syarat belum terpenuhi: selesaikan Misi M1 dulu"`; posisi tidak valid → 400;
  santri tidak dikenal → 404.
- Points M1 (token) → 200, `misi_selesai` 1; kirim lamaran Keamanan → 201,
  status `menunggu_musyrif`; duplikat lamaran aktif → 409; posisi cadangan =
  posisi utama → 400.
- `GET /api/lamaran/saya` → total 1; `daftar` tanpa token → 401, dengan token
  → 200 total 1.
- `rekomendasi` tanpa token → 401; id salah → 404; `setuju` (token) → 200,
  status `menunggu_pengasuh`; rekomendasi ulang → 409.
- `keputusan` tanpa token → 401; ditolak tanpa `alasan_tolak` → 400; ditolak
  (token, dengan alasan) → 200 status `ditolak`; kirim lagi dalam jeda
  1 minggu → 409 (pesan menyebut tanggal bisa melamar lagi: 2026-11-23).
- Jeda 1 minggu diuji dengan memundurkan `diputuskan_at` 8 hari di DB →
  kirim lagi → 201; rekomendasi `"tidak"` → 200; keputusan `diterima` → 200.
- `saya` total 2 (1 ditolak + 1 diterima); `daftar?status=diterima` total 1;
  status tidak valid → 400.
- Regresi: `verify` PV-0001, `login` unknown → `found:false`, duplikat
  `event_id` points → `duplicate:true`, ranking total 2 selama tes.
**Data tes sudah dihapus** (`cleanup-v1.4.0.py`) — DB kembali hanya PV-0001
"Tes" (0 poin), 0 lamaran; pendaftar berikut PV-0002. Backup DB sebelum
migrasi: `backups/pesantren-20261116-1657-pre-1.4.0.db`; backup kode:
`server.py.1.3.0.bak`. Asumsi yang dicatat: M1 selesai = `misi_selesai >= 1`
(misi berurutan); lamaran "aktif" = status menunggu (yang sudah `diterima`
boleh melamar posisi lain).

### v1.5.2 (18 Nov 2026 ~00:14 WIB)
Keputusan + implementasi tiket realtime, butir 1 Fase 0 multiplayer
(MULTIPLAYER-PLAN.md §1.3 — cara (a) dipilih berdasarkan kode server yang
sebenarnya). End-to-end lewat URL HTTPS publik, **13 cek — semua lolos**
(skrip tes: `test-v1.5.2.sh`; 1 santri tes dibuat lalu dibersihkan dengan
`cleanup-v1.5.2.py`):
- health = version 1.5.2.
- `POST /api/santri/realtime_ticket` dengan sesi tidak valid → 401; dengan
  sesi valid → 200, `"expires_in": 300`, tiket diterbitkan (santri tes
  PV-0003 "Tes Tiket").
- `POST /api/santri/realtime_ticket/validate` tanpa X-PV-Token → 401; token
  salah → 401; tiket palsu → 401; tiket valid → 200 + `"nama"` dan
  `"jenis_kelamin"` dari DB; tiket yang sama dipakai lagi → 401 (sekali pakai).
- Minta tiket ke-2 dengan sesi yang sama → 200, dan `set_password` dengan
  sesi yang sama → 200 — token sesi TIDAK hangus karena alur tiket.
- Regresi: `verify` PV-0001 → `"nama": "Tes"`, data lain utuh.
- Log dicek: hanya method + path + status, 0 baris mengandung nilai
  tiket/token.
- DB produksi kembali hanya PV-0001 "Tes" + PV-0002 "Atul" (putri, pendaftar
  asli — bukan data tes); `tiket_realtime` tersisa 0. Backup DB sebelum
  deploy: `backups/pesantren-20261118-0113-pre-1.5.2.db`; backup kode:
  `server.py.1.5.1.bak`. Kontrak untuk server realtime (Dimas): klien login
  → `realtime_ticket` → kirim tiket saat handshake `wss`; server realtime
  memanggil `realtime_ticket/validate` ke `127.0.0.1:8790` dengan
  X-PV-Token, lalu mengikat koneksi ke `id`/`nama`/`jenis_kelamin` dari
  respons itu.

### v1.5.1 (17 Nov 2026 ~07:58 WIB)
End-to-end lewat URL HTTPS publik, **6 cek — semua lolos** (skrip tes:
`test-v1.5.1.sh`; 1 santri tes dibuat lalu dibersihkan dengan
`cleanup-v1.5.1.py`):
- health = version 1.5.1.
- `POST /api/santri/register` dengan `jenis_kelamin: "putri"` → 201,
  respons berisi `"jenis_kelamin": "putri"`, ID PV-0002.
- `POST /api/santri/login` dan `POST /api/santri/verify` untuk PV-0002 →
  `"jenis_kelamin": "putri"`.
- Register dengan `jenis_kelamin: "laki-laki"` → 400; tanpa
  `jenis_kelamin` → 400.
- `verify` PV-0001 (lama) → `"jenis_kelamin": null`, data lain utuh.
- DB produksi kembali hanya PV-0001 "Tes" (0 poin), 0 lamaran, 0
  points_log. Backup DB sebelum deploy:
  `backups/pesantren-20261117-0758-pre-1.5.1.db`; backup kode:
  `server.py.1.5.0.bak`. md5 `server.py` live = workspace
  (`445c5e67…`).
- Catatan: SSH sempat gagal `Host key verification failed` lagi —
  `/root/.ssh/` kosong (VM baru); kunci host ditulis ulang setelah
  verifikasi fingerprint ED25519 `SHA256:MEaWdbRHdxO3NORavqRLkRfzidSAPdHmwbC7IPB2png`
  lewat `ssh-keyscan` (cocok).

### v1.5.0 (16 Nov 2026 ~19:51 WIB)
End-to-end lewat URL HTTPS publik, **12 cek — semua lolos** (skrip tes:
`test-v1.5.0.sh`, dijalankan di VPS; semua endpoint kitab publik, tanpa token):
- health = version 1.5.0.
- `GET /api/kitab` → total 1: Jurumiyah, 25 bab, `dicek_ustadz: false`,
  atribusi `"Teks: OpenITI (CC BY-NC-SA 4.0)"` di daftar dan di tiap respons.
- `GET /api/kitab/jurumiyah?bab=1` → bab "مدخل", berisi pembuka matn
  `"الكلام: هو اللفظ المركب المفيد بالوضع..."`; `?bab=25` → bab
  "باب المخفوضات من الأسماء", berakhir `"تم بحمد الله"`; kitab utuh → 25 bab.
- Bab 99 → 404; kitab tidak ada → 404; `bab=abc` → 400.
- Regresi: ranking total 1 (PV-0001); `verify` PV-0001 found;
  `lamaran/saya` PV-0001 total 0; login unknown → `found:false`.
- **Tidak ada data tes yang dibuat** (semua tes baca saja) — DB tetap hanya
  PV-0001 "Tes" (0 poin), 0 lamaran. Backup DB sebelum deploy:
  `backups/pesantren-20261116-1950-pre-1.5.0.db`; backup kode:
  `server.py.1.4.0.bak`. md5 `server.py` live = workspace
  (`7ff2c61f…`), `kitab/jurumiyah.json` live = workspace (`5514ae5f…`).
- Catatan: SSH sempat gagal `Host key verification failed` — `/root/.ssh/`
  ternyata kosong (VM baru); kunci host ditulis ulang setelah verifikasi
  fingerprint ED25519 `SHA256:MEaWdbRHdxO3NORavqRLkRfzidSAPdHmwbC7IPB2png`
  lewat `ssh-keyscan` (cocok). Konverter sempat gagal assert (bab 26 —
  hitungan awal salah; file asli punya **25** heading `### |`); diperbaiki
  dan divalidasi ulang (spot-check bab 1/5/20/25 lawan sumber).

## Yang belum teruji / butuh keputusan

1. **Integrasi game belum dilakukan** — game Godot masih mode lokal (ID + poin
   hanya di perangkat). Raka perlu menambahkan panggilan HTTP ke API ini
   (verify saat login, kirim poin saat misi selesai, ambil ranking) + menyimpan
   token dengan aman. Token harus diberikan ke Raka lewat jalur aman.
2. **App pindah ke server** (pekerjaan terpisah, setelah v1.3.0): app memakai
   register/login/set_password publik + token sesi di atas, bukan DB lokal.
3. **Sinkronisasi follower → santri otomatis** (follow @pesantren.verse → jadi
   santri): butuh desain + persetujuan Mas. Tidak ada webhook follower dari
   Instagram — sinkronisasi berkala yang mungkin.
4. **Ranking per asrama** belum ada (struktur asrama A, B, C… — bukan 21 regu;
   21 regu itu CCS, proyek lain).
5. **Sistem lamaran pengurus — server v1.4.0 SELESAI (16 Nov 2026).**
   Tinggal: form + status lamaran di app, dan pengumuman + label jabatan di
   game (Raka, setelah perbaikan Surau).
6. **Hostname sslip.io** bergantung pada IP VPS yang tetap + layanan sslip.io
   gratis. Kalau Mas nanti punya domain sendiri, ganti 1 baris di Caddyfile
   dan Caddy akan menerbitkan sertifikat baru otomatis — API tidak berubah.
7. Belum diuji beban (load test); untuk traffic fase 1 (request sesekali)
   Python stdlib + SQLite lebih dari cukup.
