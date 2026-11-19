# STATUS — Santriwati Kostum (Abaya + Jilbab Bisa Dikostum)

**Perintah Mas (17 Nov ~07:21 WIB): "Abaya dan jilbab warnanya bisa dikostum ganti ketika ganti baju."**
Keputusan warna abaya santriwati vs Ustadzah SELESAI — bukan satu warna paten, pemain yang
memilih lewat panel Ganti Baju. **SELESAI + EXPORT (Kirana, 17 Nov ~07:35 WIB). TIDAK deploy**
— deploy urusan Damar setelah ACC Mas.

## Yang dibangun (5 file, proyek `~/workspace/pesantren-verse/godot-dunia/`)

- **`scripts/player.gd`** — (1) `bangun_ulang_visual(outfit)` + `_pasang_visual(built)` +
  `apakah_muslimah()` + `_nama`: visual pemain dibangun ulang saat gender berubah (login
  sebagai santriwati) karena Abaya/Hijab adalah node yang BERBEDA, bukan sekadar warna —
  `terapkan_outfit` saja tidak bisa mengubah koko + songkok jadi abaya + jilbab. Nama
  pemain dipertahankan saat bangun ulang. (2) `build_visual`: torso + lengan muslimah
  sewarna abaya (bukan koko) — sama seperti Ustadzah; santriwan tidak berubah (warna_baju
  = koko bila bukan muslimah). (3) `terapkan_outfit`: warnai ulang Abaya/AbayaHem +
  HijabKubah/HijabCape/HijabDepan (warna jilbab) + HijabDrape/HijabSisiKiri/HijabSisiKanan
  (digelapkan 0.03, sama seperti saat dibangun); lis emas AbayaTrim sengaja tetap emas.
- **`scripts/main.gd`** — `_terapkan_gender_pemain()`: samakan visual pemain dengan gender
  save (muslimah + hijab = putri / bukan = putra), bangun ulang HANYA bila flag berubah,
  flag disimpan di save. Dipanggil di awal `_masuk_pesantren()` (sebelum teleport) — satu
  pintu masuk untuk login/daftar/lanjut.
- **`scripts/ui.gd`** — panel Ganti Baju: 6 baris (Koko/Songkok/Sarung untuk santriwan,
  Abaya/Jilbab untuk santriwati, Kulit untuk semua). Baris Abaya/Jilbab hanya tampil bila
  outfit muslimah; Koko/Songkok/Sarung hanya bila bukan. Baris "jilbab" menulis kunci
  save `hijab_warna` (yang dibaca `build_visual`); label panel tetap "Jilbab".
  Wadah tiap baris disimpan di `_outfit_baris` supaya `open_outfit()` bisa
  menyembunyikannya. Pola swatch + tanda ✓ + ACTION_MODE_BUTTON_PRESS (Ronde 19) tidak
  diubah. **Catatan koordinasi:** panel ini di `ui.gd` (file UI, bukan file karakter) —
  perubahan di sini HANYA baris outfit di atas, mengikuti pola yang sudah ada persis,
  dan dilaporkan eksplisit di dokumen ini.
- **`scripts/mission_data.gd`** — `OUTFIT_ABAYA` (Zamrud #065f46 / Hitam #23282e / Navy
  #2b3a4a / Coklat #5a3a22) + `OUTFIT_JILBAB` (Krem #f2ead6 / Putih #faf7f0 / Hitam
  #23282e / Zamrud #065f46); `OUTFIT_DEFAULT` + kunci `abaya`/`hijab_warna` (default =
  tampilan Ustadzah). `OUTFIT_USTADZAH` TIDAK diubah — Ustadzah tetap tampilannya.
- **`scripts/save_data.gd`** — default outfit + kunci `abaya`/`hijab_warna` (default =
  tampilan Ustadzah). Save lama tanpa kunci ini tetap jalan (default di `outfit.get`).

## Verifikasi

- **Tes `santriwati-kostum/skrip/test_santriwati_kostum.gd`: 69 LOLOS / 0 GAGAL, exit 0,
  0 SCRIPT ERROR, 0 NaN** (log `/tmp/tes_santriwati_kostum2.log`): kunci save + pilihan
  warna; `build_visual` muslimah (Abaya + Hijab ada, Peci/Sarung/Kerah tidak ada, torso +
  lengan sewarna abaya, drape digelapkan 0.03); santriwan (regresi); Ustadzah tetap
  (statik + live); ganti gender live putri → muslimah + spawn (130,14) + nama
  dipertahankan, putra → bukan muslimah + spawn (−4,14); baris panel per gender; ganti
  warna lewat swatch panel → save + visual berubah + tanda ✓; persistensi load_data;
  santriwan tidak terpengaruh.
- **Regresi Ronde 22: 259 LOLOS / 0 GAGAL** (log `/tmp/tes_ronde22_regresi_kostum.log`).
- **Foto 5/5 (35–39), sudah saya LIHAT sendiri:** 35 default (abaya Zamrud + jilbab
  Krem); 36 Abaya Hitam + Jilbab Putih; 37 Abaya Navy + Jilbab Zamrud — ketiganya
  terbaca jelas sebagai santriwati (gamis panjang + jilbab, tanpa koko/songkok/sarung);
  38 panel Ganti Baju sebagai santriwati (baris Abaya + Jilbab + Kulit + Kacamata, tanda
  ✓ di Zamrud + Krem; TIDAK ada baris Koko/Songkok/Sarung); **39 close-up depan:
  jilbab krem (kubah + strip sisi + drape depan + cape bahu), wajah (mata + alis +
  senyum), abaya zamrud + lis emas — terbaca jelas sebagai santriwati.**

## Export

- `godot --headless --export-release "Web"`, exit 0.
- **`index.pck` BARU: 1.602.820 byte, sha256
  `e02f3c28eb65da2c88fd8500f5e94b49fc3ebf2f4a126efbdf2fa7863b5ac6b0`**
  (+2.592 dari login-gender 1.600.228, `7619033f…`).
- wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah
  (`33c94cb3…`); worklet ada (2.973 byte, `be33985b…`). File tes/foto TIDAK ada di pck
  (grep 0) — skrip tes + foto sudah dihapus dari proyek sebelum export.

## Catatan jujur (bukan blocker)

- Foto 35–37 diambil dari selatan (6,5 m) sementara wajah menghadap utara — yang
  terlihat punggung jilbab, bukan wajah. Foto 39 (close-up, kamera dihitung dari arah
  mata) membuktikan wajah depan dengan benar.
- Satu baris `ERROR: Condition "status < 0"... ERR_CANT_OPEN` muncul sekali di log foto
  (kemungkinan audio/file startup) — keempat foto tersimpan err=0, tidak berpengaruh.
- Bug tes yang ditemukan + diperbaiki saat tes: (1) `var r :=` gagal infer tipe karena
  `_main` bertipe Node — diganti `var r: String`; (2) cek sarung Biru sempat GAGAL
  palsu karena warna sarung ada di TEKSTUR batik (albedo putih) — cek diganti
  membandingkan objek material cache motif; (3) `pkill -f` sempat mematikan shell
  sendiri (pola mengenai perintahnya) — pakai PID, jangan `pkill -f` (pelajaran lama,
  terulang).
- Login di browser sungguhan belum teruji — retest browser setelah deploy tetap perlu.
- Pipeline screenshot video (Nara) masih mengetik form login lama — perlu diperbarui
  saat video Hari ke-1 dilanjutkan (catatan Raka, masih berlaku).

## Perintah deploy (Damar, setelah ACC Mas)

Salin pck baru ke staging + update GODOT_CONFIG **1600228 → 1602820** + cek guard 3/3 +
verifikasi hash live `e02f3c28…`.

## Dokumen

- Skrip tes: `~/workspace/pesantren-verse/santriwati-kostum/skrip/test_santriwati_kostum.gd`
  (+ `.tscn`).
- Skrip foto: `~/workspace/pesantren-verse/santriwati-kostum/skrip/foto_santriwati.gd`
  (+ `.tscn`) + `foto_santriwati_retake39.gd` (+ `.tscn`).
- Foto: `~/workspace/pesantren-verse/foto-ronde-20/35-santriwati-default.png`,
  `36-santriwati-hitam-putih.png`, `37-santriwati-navy-zamrud.png`,
  `38-panel-ganti-baju-putri.png`, `39-santriwati-dekat.png`.
