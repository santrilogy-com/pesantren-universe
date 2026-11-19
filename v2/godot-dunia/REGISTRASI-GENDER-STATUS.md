# STATUS — Form DAFTAR Game Terhubung Server + Gender

**Selesai 17 Nov 2026 ~23:58 WIB (Tara, tim UI). TIDAK deploy — untuk
ronde export BERIKUTNYA (Rangga).**

Mas (17 Nov ~06:55 WIB): "daftar by gender belum ada. Saya mau daftar
sebagai santriwati pengen cek pondok putri." Login game↔server + gender
sudah selesai Raka 17 Nov ~07:15 WIB (`LOGIN-GENDER-STATUS.md`), tapi
kotak DAFTAR di game masih lokal — terbitkan ID sendiri, tanpa server,
tanpa gender. Sekarang kotak DAFTAR terhubung ke server dan menanyakan
gender.

## Kontrak (tim server — Saka, v1.5.1 LIVE 17 Nov ~07:00 WIB)
- `POST /api/santri/register` PUBLIK, tanpa token. Body
  `{ig_username, nama, jenis_kelamin}` (`"putra"`/`"putri"`) → sukses
  `201` mengembalikan `id` (`"PV-XXXX"`) + `nama` + `ig_username` +
  `jenis_kelamin`.
- Username IG duplikat → `409`; isian tidak valid → `400`
  (nama maks 30 huruf; `ig_username` hanya huruf/angka/titik/garis
  bawah, maks 64 — lihat catatan tanda hubung di bawah).
- Nilai `jenis_kelamin` SAMA PERSIS dengan save key game — TIDAK ada
  mapping (pelajaran dari app: kode `"L"`/`"P"` ditolak server).
- `X-PV-Token` TIDAK dipakai di sini (hanya untuk
  `POST /api/santri/points` dari server tepercaya) — tidak ada di file
  game mana pun.

## Alur (dari layar masuk)
1. Santri mengetuk "Daftar" → kotak DAFTAR: field **Nama** + field
   **Username Instagram** + pemilih gender **Santri (Putra) /
   Santriwati (Putri)** (default Putra; yang terpilih emas + `"✓"`).
2. Tekan **DAFTAR & MASUK PESANTREN** → validasi lokal dulu: nama
   minimal 2 huruf; IG wajib diisi, tanpa spasi; gender harus valid.
   Galat tampil di bawah tombol; sinyal `register_submitted` TIDAK
   jalan bila validasi gagal.
3. `main.gd` POST ke server (timeout 15 dtk). Selama request: tombol +
   field + pemilih gender dikunci, teks tombol `"MENDAFTAR…"` (cegah
   ketukan ganda; ketukan ganda juga diabaikan di `main.gd`).
4. Sukses → ID + nama + IG + gender dari JAWABAN server ditulis ke
   save (pendaftar baru mulai dari nol; counter ID lokal dipertahankan)
   → langsung masuk, spawn sesuai gender (putri (130,14), putra
   (-4,14)) + flag muslimah aktif untuk putri.
5. Gagal → pesan jelas di form (offline / 409 username dipakai / 400
   pesan server / jawaban bukan JSON / ID tidak valid), save TIDAK
   disentuh, tidak crash, TIDAK ada daftar lokal diam-diam.

## Yang diubah (3 file game + 1 baru, hanya Tara)
- `scripts/ui.gd`: kotak DAFTAR kini punya pemilih gender
  (`_reg_putra_btn` / `_reg_putri_btn`, `_on_gender_dipilih`,
  `gender_daftar_terpilih()`), validasi form di `_on_daftar_pressed`,
  sinyal `register_submitted(ig_username, nama, jenis_kelamin)`.
  Baru: `show_register_error(pesan)` +
  `set_register_loading(busy)`. Normalisasi IG sama seperti server
  (tanpa `@`, huruf kecil).
- `scripts/registrasi_server.gd` (BARU): helper MURNI tanpa I/O —
  `gender_valid()`, `bangun_body()` (gender di luar putra/putri jadi
  `"putra"`), `pesan_galat_respons()` (offline / 409 / 400 pakai pesan
  server / 5xx), `validasi_jawaban()` (ID `PV-XXXX` + nama ≥2 huruf +
  gender putra/putri; `null` TIDAK boleh masuk `String(...)` —
  pelajaran login-gender).
- `scripts/main.gd`: `_on_register(...)` → HTTPRequest POST
  `/api/santri/register`; `_on_register_http_selesai(...)` →
  `_terapkan_register_server(data)` (murni, bisa dites stub) →
  `_masuk_pesantren(...)` dengan sapaan + ID santri baru.
- Kunci save `ig_username` / `jenis_kelamin` / `role` SUDAH ada dari
  ronde login-gender (Raka) — ronde ini tidak mengubah `save_data.gd`.
- Skrip tes: `skrip/test_registrasi_gender.gd` (headless).
  Skrip foto: `skrip/foto_registrasi_gender.gd` (lihat Foto).

## Verifikasi
- **Tes `skrip/test_registrasi_gender.gd`: 71 LOLOS / 0 GAGAL,
  exit 0.** Log final: `/tmp/tes_registrasi_gender4.log` (jalan
  ke-4, 17 Nov ~23:59 WIB). Jalan sebelumnya: log 2 = 69/1 (satu
  gagal: "estimasi form daftar muat portrait"), log 3 = 70/0 —
  final 71/0 yang dipakai.
  Isi: UI form daftar (kotak terlihat, gender default putra, toggle
  putri↔putra, tanda `✓`, metrik form muat portrait 390x844 bukan
  mode kompak) + validasi (nama 1 huruf / IG kosong / IG berspasi
  ditolak tanpa sinyal; `@Tes.Tara.231139` ternormalisasi di sinyal)
  + loading (kunci tombol + field + gender, teks `"MENDAFTAR…"`,
  lalu kembali) + helper murni (body, pesan galat 409/400/offline/
  500, validasi jawaban) + `_terapkan_register_server` stub
  (putri/putra/buruk; save utuh bila jawaban buruk) + spawn sesuai
  gender (putri (130,14) + flag muslimah; putra (-4,14) bukan
  muslimah) + **LIVE lewat klien game sungguhan** (lihat bawah) +
  save dikembalikan default sesudah tes (supaya tes lain tidak kena
  gender putri).
- **LIVE: akun tes `tes.tara.231139` ("Tes Tara", putri) → PV-0002,
  terdaftar 17 Nov ~23:58 WIB.** Tes live masuk lewat jalur
  fallback login — akun sudah ada dari jalan tes sebelumnya (register
  dijawab 409 "sudah dipakai"), lalu login live mengembalikan id +
  gender putri dan spawn putri (130,14) terverifikasi. BUKAN PV-0001
  ("Tes", santri produksi — tidak disentuh).
- **Foto:** `../foto-registrasi-gender/daftar-gender-portrait.png`
  (390x844) + `daftar-gender-landscape.png` (844x390) — form terisi
  contoh ("Tes Tara" / `tes.tara.231139` / Santriwati terpilih).
  Portrait di-retake 18 Nov ~00:10 WIB (lihat Foto).

## Akun tes live (sedang dibersihkan)
- PV-0002 "Tes Tara" (`tes.tara.231139`, putri) — didaftarkan Tara
  untuk tes live 17 Nov ~23:58 WIB. **Saka sedang memverifikasi +
  menghapusnya dari DB produksi** (backup dulu, verifikasi login
  `found:false` sesudah hapus, PV-0001 utuh). Status hapus BELUM
  terkonfirmasi saat dokumen ini ditulis — jangan anggap DB bersih
  sebelum laporan Saka masuk.

## Catatan username tanda hubung ditolak server
- Server (`server.py`, `IG_RE = ^[a-z0-9._]{1,64}$`) hanya menerima
  huruf/angka/titik/garis bawah. **Username IG dengan tanda hubung
  (`-`) ditolak 400** — pesan server: "ig_username wajib diisi
  (huruf/angka/titik/garis bawah, maks 64)".
- Form game TIDAK menolak `-` di validasi lokal (hanya spasi yang
  ditolak) — jadi santri dengan `-` di username akan menekan DAFTAR,
  lalu mendapat pesan 400 dari server. Itu perilaku benar (server
  sumber kebenaran), tapi pesannya teknis. Bila Mas mau, ronde
  berikutnya bisa menambahkan validasi lokal `-` dengan pesan yang
  lebih ramah — bukan blocker, jangan ubah diam-diam.

## Foto — retake portrait (18 Nov ~00:10 WIB, Tara)
- Foto portrait PERTAMA (17 Nov) lemah: overlay **"PUTAR HP-MU"**
  menutupi form. Itu perilaku NORMAL game (overlay muncul di layar
  sentuh portrait, `ui.gd: butuh_putar_hp`), BUKAN bug form daftar.
- Perbaikan HANYA di `skrip/foto_registrasi_gender.gd`: sebelum
  jepret portrait, skrip memanggil `ui._tutup_rotate_overlay()` —
  sama seperti santri mengetuk tombol "Tetap main portrait".
  Logika game TIDAK diubah.
- Retake: `xvfb-run -a <godot-4.7> --path . skrip/foto_registrasi_gender.tscn`,
  exit 0, dua foto `err=0`. Log: `/tmp/foto_registrasi_retake.log`.
  (Catatan: `xvfb-run` tanpa `-a` gagal — display :99 sedang dipakai
  Xvfb run foto lain; `godot` tidak ada di PATH — biner di
  `~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64`.)
- Hasil: portrait kini form penuh terlihat (Santriwati (Putri)
  emas + `✓`); landscape mode kompak juga bagus. Foto lama sudah
  tertimpa file yang sama (tidak ada versi `-lama`).

## Catatan jujur (bukan blocker)
- **Penghapusan akun tes PV-0002 belum terkonfirmasi** (menunggu
  Saka) — lihat atas.
- **Daftar di browser sungguhan belum teruji** — headless membuktikan
  klien + server; retest browser setelah deploy tetap perlu (form
  baru, daftar putri live, spawn putri dari HP Mas).
- **Visual santriwati**: flag muslimah aktif saat spawn putri
  (dites), tapi tampilan abaya + jilbab itu tugas Tim Karakter —
  warna belum diputuskan Mas.
- **Form login lama (ID + nama) sudah diganti** di ronde
  login-gender; pipeline screenshot video (Nara) yang masih mengetik
  form lama perlu diperbarui saat video dilanjutkan.

## Untuk ronde export berikutnya (Rangga)
- File berubah vs export v2 00:03 WIB: `scripts/ui.gd`,
  `scripts/main.gd`, `scripts/registrasi_server.gd` (baru),
  `skrip/test_registrasi_gender.gd`, `skrip/foto_registrasi_gender.gd`.
  Skrip tes/foto TIDAK ikut export (bukan scene game).
- Tidak ada perubahan `project.godot` / preset export dari ronde ini.
- Setelah export: retest browser — daftar sebagai santriwati baru
  (username IG lain yang belum dipakai, tanpa `-`), cek ID terbit +
  spawn putri (130,14), lalu hapus akun tes itu dari DB.
