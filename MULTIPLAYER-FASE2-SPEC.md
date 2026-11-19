# MULTIPLAYER FASE 2 — SPEK (keputusan Mas, 18 Nov 2026 ~13:19 WIB)

Dikerjakan SETELAH Fase 1 lolos T1 (tes 2 HP oleh Mas). Bukan bagian
Fase 1 — jangan dicampur ke perbaikan tombol gabung yang sedang jalan.

## Keputusan Mas (6/6 pertanyaan §8 terjawab)

| # | Pertanyaan §8 | Keputusan Mas |
|---|---------------|---------------|
| 1 | Cap ruangan | **50 pemain/ruangan** |
| 2 | Chat suara atau teks dulu | **TEKS dulu** (bukan suara) |
| 3 | Sholat berjamaah multiplayer | **OTOMATIS** (prioritas Fase 2) |
| 4 | Pemain terlihat dari seberang gerbang | **BOLEH** |
| 5 | Satu akun dua perangkat | **BOLEH** |
| 6 | Nama tampil selalu atau hanya saat dekat | **SELALU** — termasuk saat mode kamera Drone, nama harus tampil dan terbaca jelas |

## Implikasi teknis (catatan Dimas — untuk dikerjakan di Fase 2)

### 1. Cap 50/ruangan
- `RoomConfig.MAX_PLAYERS_PER_ROOM`: 8 (kode Fase 1) → **50**.
- Beban relay (prep doc §2.3–2.4): 50 pemain = **24.500 paket/dtk**
  (N × 10 Hz × (N−1)); 20 pemain = 3.800; 100 = 99.000.
- Bandwidth BUKAN masalah (±59 KB/dtk turun di 100 pemain).
  Bottleneck: CPU VPS 2 vCPU + draw call HP (±50 avatar × 6–10 mesh).
- Interest management (radius pandang ±50 m) memangkas beban tipikal
  tapi BUKAN beban terburuk (100 santri kumpul sholat = beban penuh).
  Diputuskan di Fase 2: ukur dulu dengan uji beban T5 di 50 pemain,
  baru putuskan apakah interest management wajib.
- Uji beban T5 (prep doc §3) diperluas ke 50 pemain.

### 2. Chat teks
- Feed chat MLBB sudah ada untuk pesan lokal — Fase 2: kirim teks ke
  satu ruangan (broadcast), tampil di feed semua pemain di ruangan.
- Input teks di HUD (HP). Tanpa suara (keputusan Mas).
- Moderasi: di luar Fase 2 kecuali yang paling dasar (nanti).

### 3. Sholat berjamaah OTOMATIS
- Saat sesi sholat dimulai, pemain online OTOMATIS ikut jamaah
  (Kyai imam di Surau, Ustadzah imam putri di Musholla) — tanpa
  tombol "Ikut" manual.
- Butuh sinkronisasi state sholat antar klien (server otoritatif:
  fase kumpul → takbir → selesai). Rincian di MULTIPLAYER-PLAN.md.

### 4. Terlihat dari seberang gerbang: BOLEH
- Remote avatar sudah di-render tanpa peduli zona (spawn di Players
  untuk semua peer tervalidasi); zone_reject hanya membatasi GERAK,
  bukan visibilitas. Verifikasi di tes Fase 2: putra di dekat gerbang
  (x=14) harus melihat avatar putri di seberangnya, dan sebaliknya.
- Bila ada culling jarak di kemudian hari, JANGAN sembunyikan pemain
  di seberang gerbang.

### 5. Satu akun dua perangkat: BOLEH
- Server realtime saat ini tidak membatasi per ID santri (cap hanya
  per ruangan) — dua perangkat = dua login = dua token = dua tiket.
- YANG HARUS DIVERIFIKASI di Fase 2: apakah POST /api/santri/login
  kedua membatalkan token sesi pertama ("satu sesi per santri")?
  Bila ya: perangkat pertama tetap online (realtime tidak
  re-validasi setelah spawn), tapi reconnect-nya gagal sampai login
  ulang — dokumentasikan perilaku itu, jangan ubah kontrak API
  tanpa seizin Xam.
- Satu santri = dua avatar di dunia (satu per perangkat) — itu
  yang diminta ("boleh"), bukan satu avatar dikendalikan dua
  perangkat.

### 6. Nama tampil SELALU (termasuk mode Drone)
- Label nama di atas avatar TIDAK boleh hilang di jarak jauh atau
  di mode kamera Drone — harus tampil dan terbaca jelas.
- Sudah diteruskan ke Raka untuk mode Drone-nya (13:19 WIB):
  pastikan label nama ikut ter-render + terbaca di ketinggian drone.
- Verifikasi di tes Fase 2: screenshot mode Drone dengan beberapa
  pemain — nama semua terbaca.

## Yang TIDAK berubah dari Fase 1
- Sync posisi 10 Hz + lerp; tiket realtime 5 menit sekali pakai;
  validasi zona server (putra/putri tetap terpisah geraknya);
  nama dari DB (bukan dari klien); cap ditegakkan server.
- Default Fase 1 (cap kode 8, satu sesi/akun) diganti per keputusan
  di atas saat Fase 2 dimulai — JANGAN ubah sekarang.

## 7. Jalur poin game→server — KEPUTUSAN: relay via server realtime (Saka, §9 butir 8)

**Keputusan (18 Nov 2026 ~21:30 WIB, Saka — menjawab draf v5.3 §8.3 risiko 1
dan §9 butir 8): PILIHAN A — relay via server realtime tepercaya.**
Klien game TIDAK PERNAH memanggil `POST /api/santri/points` langsung dan
TIDAK PERNAH memegang `X-PV-Token`. REST **tidak berubah** (tidak ada
endpoint baru, tidak ada perubahan skema DB, tidak ada perubahan kontrak
sesi). Implementasi = Fase B; yang diputuskan di sini hanya arsitekturnya.

### Kenapa A, bukan B (endpoint baru pakai token sesi login)

1. **Token sudah di tempat yang benar.** Server realtime sudah memegang
   `X-PV-Token` (env `PV_TOKEN` dari `.env` yang sama dengan API —
   terbukti di `/proc/<pid>/environ` + `network_manager.gd:350,364`).
   Relay tidak membagikan rahasia baru ke mana pun.
2. **Jangan regangkan token sesi.** Token sesi login juga mengesahkan
   `set_password` (ganti password!) dan sekali pakai untuk itu
   (`server.py` `_cek_sesi` menolak `used`; `used=1` ditandai di
   `_set_password`). Preseden Fase 0 (§1.3, keputusan Saka 00:14 WIB):
   token sesi TIDAK BOLEH dipakai langsung untuk handshake justru karena
   ia juga mengesahkan `set_password` — REST menerbitkan tiket khusus
   yang sempit sebagai gantinya. Alasan yang sama berlaku untuk poin:
   memakai token sesi sebagai kunci API umum memperluas permukaan
   serang (bocor → palsukan poin + minta tiket + reset password bila
   belum dipakai). Catatan jujur: token sesi memang sudah ada di memori
   klien game untuk minta tiket — tapi itu pemakaian yang sudah
   diputuskan Fase 0 (1 jam, sekali pakai untuk `set_password`); menambah
   pemakaian baru tanpa perlu = menambah risiko tanpa perlu.
3. **Identitas dari server, bukan dari klien.** Relay mengikat tiap pesan
   poin ke `peer_id` yang sudah tervalidasi lewat tiket; `santri_id`
   diambil dari `_pemain[peer_id]` di sisi server — BUKAN dari body
   klien (jadi satu santri tidak bisa mengirim poin untuk santri lain).
   Catatan: saat ini `_on_validasi_selesai` menyimpan nama/jenis_kelamin/
   outfit/posisi tapi TIDAK menyimpan `id` (`sid` hanya dipakai di log)
   — Fase B wajib menambah `"id": sid` ke `_pemain[peer_id]`.
4. **Idempotensi sudah ada di REST.** `POST /api/santri/points` sudah
   dedup via `event_id UNIQUE` (duplikat → 200 `duplicate:true` + total
   saat ini, poin tidak dobel). Relay cukup meneruskan `event_id` apa
   adanya; retry klien/relay aman. Tidak ada yang perlu dibangun di
   sisi REST.
5. **Rate limit berlapis.** Relay menegakkan batas per-peer SEBELUM
   menyentuh REST (lihat bawah), melindungi bucket REST
   (120/menit/IP, dipakai bersama login/register). Kelak relay juga
   satu-satunya komponen yang bisa memvalidasi kewajaran (mis. posisi
   pemain saat misi selesai) — opsi B tidak punya konteks live itu.
6. **Beban VPS bukan pembeda.** Poin itu jarang (beberapa event per
   santri per hari) — satu HTTP localhost per event tidak berarti
   dibanding relay posisi 10 Hz × 50 pemain. REST `ThreadingHTTPServer`,
   jadi konkurensi bukan masalah.
7. **Kemudahan klien Godot.** Klien tidak perlu HTTP baru — cukup satu
   RPC baru `submit_poin(...)` ke server (pola sama seperti
   `submit_ticket`). Semua logika HTTP + token tetap di server.

### Alur

```
Misi selesai (klien)
  → poin lokal langsung diterapkan (UI tidak menunggu server)
  → event ditulis ke outbox lokal (save) dengan event_id SEKALI dibuat
  → bila WS sudah terhubung: RPC submit_poin(misi, poin, event_id)
    bila belum: silent connect (alur _mp_login_diam_diam + tiket,
    sudah ada) hanya untuk flush, lalu boleh putus
Server realtime (peer tervalidasi)
  → cek rate limit per-peer → ambil santri_id dari _pemain[peer_id]
  → HTTP POST http://127.0.0.1:8790/api/santri/points
    header X-PV-Token (dari env PV_TOKEN), body {id, misi, poin, event_id}
  → teruskan hasil ke klien via RPC ack (total_poin / duplicate / error)
Klien: event yang di-ack (termasuk duplicate:true) dihapus dari outbox.
```

### Format

- **RPC klien → server:** `submit_poin(misi: String, poin: int,
  event_id: String)` — `@rpc("any_peer", "reliable")`. Klien TIDAK
  mengirim `id` santri (server yang mengisi dari sesi tervalidasi).
- **HTTP relay → REST:** `POST /api/santri/points`, body
  `{"id": "<PV-XXXX>", "misi": "<kode>", "poin": <int 1-100>,
  "event_id": "<unik>"}`. Respons REST
  `{"ok": true, "duplicate": false, "total_poin": N, "tier": "...",
  "misi_selesai": N}` diteruskan ke klien sebagai ack.
- **`event_id`:** `"{santri_id}:{kode_misi}:{uuid8}"`, dibuat sekali saat
  misi selesai, disimpan di outbox sampai ack. Contoh:
  `PV-0003:M1:9f2c41ab`. Panjang ≤64 (REST menolak >64). Kode misi =
  kode yang sudah dipakai lokal (`M1/M2/M3`, `N1.T`, `RB`, dst. —
  maks 64 huruf, sesuai validasi REST).
- **Log:** server hanya mencatat peer_id + misi + poin + hasil.
  TIDAK PERNAH menulis token/tiket/event_id ke log (aturan yang sama
  seperti tiket, PLAN §1.3).

### Rate limit (usulan Fase B, boleh disetel)

- Relay per-peer: maks **5 event/menit/peer** + maks **100 poin/jam/peer**.
  Lebih dari itu → tolak + log (bukan ban; santri normal tidak pernah
  menyentuh angka ini — misi selesai beberapa kali sehari).
- REST tetap 120/menit/IP; relay dari `127.0.0.1` dan volume poin kecil,
  jadi tidak mengganggu bucket login/register. Fase B memverifikasi ini
  di tes beban ringan.

### Main solo / offline (outbox — jawaban atas keberatan utama opsi A)

Misi kebanyakan dimainkan solo tanpa "Main Bersama". Karena itu poin
TIDAK boleh hilang bila WS sedang tidak terhubung:

- Outbox = kunci save baru di `save_data.gd` `default_data()` (ingat:
  kunci save baru WAJIB didaftarkan di sana), mis. `"poin_outbox"`.
  Tiap event: `{event_id, misi, poin, dibuat_epoch, percobaan}`.
- Flush oportunistik: bila WS terhubung → kirim langsung; bila tidak →
  silent connect hanya untuk flush (pakai alur tiket yang sudah ada),
  lalu boleh putus. Retry dengan backoff; event yang belum ter-ack
  dicoba lagi di koneksi berikutnya.
- Poin lokal diterapkan langsung — status "menunggu kirim" hanya
  indikator di UI (detail UI diputuskan Fase B).

### Yang dibutuhkan Fase B (implementasi)

- **Server** (`scripts/multiplayer/network_manager.gd`, rebuild dedicated
  dari commit yang sama agar checksum RPC cocok, restart service
  realtime; REST tidak disentuh):
  - tambah `"id": sid` ke `_pemain[peer_id]` di `_on_validasi_selesai`;
  - RPC baru `submit_poin` + handler relay (rate limit per-peer,
    HTTP POST ke REST localhost dengan `X-PV-Token` dari env,
    teruskan `event_id`, ack hasil ke pengirim);
  - pola HTTPRequest sudah ada di file itu (`:360`, dipakai validasi
    tiket) — pakai pola yang sama.
- **Klien** (Godot): outbox di save + RPC `submit_poin` + silent
  connect untuk flush + retry/backoff; poin lokal langsung.
- **REST:** tidak ada perubahan. Hanya verifikasi rate limit localhost
  tidak menghambat relay.
- **Tes:** peer tervalidasi vs belum tervalidasi (ditolak); rate limit
  (event ke-6 dalam 1 menit ditolak); `event_id` duplikat → total tidak
  dobel; peer mengirim `id` orang lain di body → diabaikan (server
  pakai id sesi); outbox offline → online (flush + ack); uji beban
  ringan relay.
- **Hardening Fase B+ (opsional, bukan syarat):** validasi kewajaran di
  relay — mis. posisi teramati pemain vs venue misi saat event
  diterima. Boleh ditunda; tanpa ini pun relay sudah strictly lebih
  aman dari opsi B karena identitas + rate limit ditegakkan server.

### Yang TIDAK dilakukan

- Tidak ada endpoint baru di REST; tidak ada perubahan skema DB.
- Token sesi login TIDAK dipakai untuk poin — kontraknya tidak berubah
  (sekali pakai hanya untuk `set_password`; reusable hanya untuk minta
  tiket realtime).
- `X-PV-Token` TIDAK masuk file game mana pun (tetap di `.env` VPS +
  env proses realtime) — batasan keras ini dipenuhi penuh oleh opsi A.

## Referensi
- `MULTIPLAYER-PLAN.md` (Arsa) + `MULTIPLAYER-FASE1-PREP.md` (§2.3–2.4
  beban, §3/T5 uji beban).
- Server: `room_config.gd` (MAX_PLAYERS_PER_ROOM), `network_manager.gd`.
