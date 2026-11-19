# STATUS — Integrasi Login Game↔Server + Gender Santriwati

**Selesai 17 Nov 2026 ~07:15 WIB (Raka). TIDAK deploy — menunggu ACC Mas.**

Mas (17 Nov ~06:55 WIB): "daftar by gender belum ada. Saya mau daftar
sebagai santriwati pengen cek pondok putri." Game sudah punya logika
gender (`_pemain_adalah_putri()` + spawn putri (130,14) + aturan batas
cermin) tapi kuncinya tidak pernah ditulis — login game belum terhubung
ke server. Sekarang terhubung.

## Kontrak (disepakati dengan tim server — Saka, v1.5.1 LIVE 17 Nov ~07:00 WIB)
- `POST /api/santri/login` dengan `ig_username` (+ `password` bila sudah
  diset) → sukses mengembalikan `id` + `nama` + `jenis_kelamin`
  (`"putra"`/`"putri"`) + `session` (token sesi, 1 jam).
- Nilai `jenis_kelamin` SAMA PERSIS dengan save key game — TIDAK ada mapping.
- `X-PV-Token` TIDAK dipakai di game (hanya untuk `POST /api/santri/points`
  dari server tepercaya) — tidak ada di file game mana pun.
- Santri lama tanpa gender mengembalikan `jenis_kelamin: null` (PV-0001
  "Tes") → game memperlakukannya sebagai `"putra"` (perilaku lama).

## Yang diubah (3 file, hanya Raka)
- `scripts/save_data.gd`: `default_data()` + kunci baru `"ig_username": ""`,
  `"jenis_kelamin": "putra"`, `"role": "santri"` — PENTING: `load_data()`
  hanya menyalin kunci yang ada di `default_data()`, jadi tanpa ini kunci
  gender akan terbuang saat load. Helper baru `normalisasi_ig()` (tanpa
  `@`, huruf kecil — sama dengan server).
- `scripts/ui.gd`: form MASUK kini **Username Instagram + Kata sandi
  (opsional)** — menggantikan ID PV-XXXX + nama. Kata sandi field `secret`.
  Sinyal `login_submitted(ig_username, password)`. Baru:
  `show_login_error(pesan)` + `set_login_loading(busy)` (kunci tombol,
  teks "MENGHUBUNGKAN…" selama request — cegah ketukan ganda).
  Catatan login diperbarui. Kotak DAFTAR **tidak diubah** (masih lokal —
  lihat catatan jujur).
- `scripts/main.gd`: `_on_login(ig_username, password)` → HTTPRequest POST
  ke `https://43-173-39-166.sslip.io/api/santri/login` (timeout 15 dtk);
  `_on_login_http_selesai(...)` → `_terapkan_login_server(data)` (murni,
  bisa dites stub) → `_masuk_pesantren(...)`. Sukses: tulis `id_santri` +
  `nama` + `ig_username` + `jenis_kelamin` ke save + token sesi HANYA di
  memori (tidak disimpan). Gagal: pesan jelas di bawah tombol MASUK, save
  tidak disentuh, tidak crash (offline / 401 kata sandi salah /
  `found:false` / jawaban bukan JSON / ID tidak valid).
  `_masuk_pesantren()` kini teleport ke spawn sesuai gender + perbarui
  jangkar dorong-balik `_pos_legal_terakhir` — `_ready` jalan SEBELUM
  login (saat save masih putra), jadi tanpa ini santriwati pertama kali
  login akan berdiri di area putra dan langsung didorong balik ke titik
  yang salah.

## Verifikasi
- **Tes `login-gender/skrip/test_login_gender.gd`: 63 LOLOS / 0 GAGAL,
  exit 0, 0 SCRIPT ERROR, 0 NaN, smoke 300 frame selesai.**
  Log: `/tmp/tes_login_gender3.log`.
  Isi: kunci save + round-trip load (dulu kunci baru terbuang) +
  terapkan putri/putra (stub) + batas cermin putri live (didorong balik
  dari zona putra + toast, tetap di zona putri) + ID sama pertahankan
  poin / ID baru reset + gender hilang/`"x"`/`null` → putra + handler
  gagal (offline/401/found:false/bukan JSON/ID tidak valid) + UI
  (field, secret, loading, validasi form) + **live lewat klien game
  sungguhan**: login `tes.putri.raka` → PV-0002 putri → spawn (130,14);
  login `tes.putra.raka` → PV-0003 putra → spawn (-4,14); login username
  tidak dikenal → "tidak ditemukan", save utuh.
- **Regresi baseline Ronde 22 (`test_ronde22.gd`): 259 LOLOS / 0 GAGAL.**
  Log: `/tmp/tes_ronde22_regresi.log`.
- **Export:** `godot --headless --export-release "Web"`, exit 0.
  **`index.pck` BARU: 1.600.228 byte,
  sha256 `7619033ff4543a23964fcce2e51c3feddb4820b3b9a9be16c3a20ca19b74fe2b`**
  (+3.952 dari Ronde 22: 1.596.276). wasm TIDAK berubah (`fc74679e…`),
  index.js TIDAK berubah (`33c94cb3…`), worklet ada (2.973 byte,
  `be33985b…`). File tes dihapus dari proyek sebelum export.

## Akun tes live (sudah dibersihkan)
- PV-0002 "Tes Putri" (`tes.putri.raka`, putri) + PV-0003 "Tes Putra"
  (`tes.putra.raka`, putra) — didaftarkan Raka untuk tes live, lalu
  **dihapus dari DB produksi** (santri + sesi login) via SSH. Verifikasi:
  ranking kembali total 1 (hanya PV-0001 "Tes"), sesi 0.

## Bug yang ditemukan + diperbaiki saat tes
1. **`String(null)` crash** — `String(data.get("jenis_kelamin"))` error
   saat server mengembalikan `null` (santri lama). Tes pertama lolos
   PALSU karenanya (fungsi abort, save menyimpan nilai putra lama, `var
   r3: String = null` jadi `""`). Perbaikan: helper `_str_atau()`
   (null → default) untuk semua field jawaban server; tes null kini
   mengecek id ikut berubah (bukti fungsi jalan sampai akhir).
2. **Label galat basi** — handler sukses tidak menghapus galat login
   sebelumnya (terlihat saat handler dipanggil langsung di tes).
   Perbaikan: handler menghapus galat di awal setiap jawaban.

## Catatan jujur (bukan blocker)
- **Visual santriwati BELUM berubah** — santriwati masih tampil sebagai
  santriwan (koko + songkok + sarung). Konstruksi abaya + jilbab sudah ada
  di `player.gd` (`muslimah: true`), tapi warna abaya santriwati vs
  Ustadzah belum diputuskan Mas — itu tugas Tim Karakter, bukan ronde ini.
  Yang ronde ini berikan: spawn putri + aturan batas cermin.
- **Kotak DAFTAR di game masih lokal** (terbitkan ID sendiri, tanpa
  server, tanpa gender). Pendaftaran dengan gender ada di **app**
  (Xam). Bila santri daftar lokal di game lalu login server, ia akan
  mendapat "Username IG tidak ditemukan" — pesannya mengarahkan daftar
  lewat aplikasi.
- **Skrip Ronde 22 yang memanggil `_on_login` lama diperbarui**
  (Wulan — mohon dicatat): `test_ronde22.gd`, `audit_jalan_lampu.gd`,
  `foto_ronde22.gd`, `foto_ronde22_retake30.gd` kini masuk lewat stub
  `_terapkan_login_server(...)` + `_masuk_pesantren(...)` (deterministik,
  tanpa jaringan). Skrip Ronde 21 tidak diubah (historis).
- **Pipeline screenshot video (Nara)** masih mengetik ID + nama di form
  login lama — perlu diperbarui saat video Hari ke-1 dilanjutkan.
- Login di browser sungguhan (fetch) belum teruji — headless membuktikan
  klien + server; retest browser setelah deploy tetap perlu (form baru,
  login putri live, spawn putri, batas cermin dari HP Mas).

## Perintah deploy (Damar, setelah ACC Mas)
Salin pck baru ke staging + update GODOT_CONFIG **1596276 → 1600228** +
cek guard 3/3 + verifikasi hash live `7619033f…`.
