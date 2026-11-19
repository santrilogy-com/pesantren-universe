# FITUR CUACA — STATUS (Wulan, 17 Nov 2026)

Fitur baru v1, DI-ACC Mas 17 Nov 2026 ~20:52 WIB. Langit/awan/hujan game
mengikuti cuaca nyata di lokasi user (HP, Chrome Android).

## File yang dibuat / diubah

| File | Status |
|---|---|
| `scripts/cuaca.gd` (BARU, `class_name Cuaca`) | Izin lokasi (Geolocation API via JavaScriptBridge, web saja) + panggil Open-Meteo (gratis, tanpa API key) + pemetaan kode WMO -> kondisi game + fallback cerah |
| `scripts/langit_dinamis.gd` (DIUBAH, hook saja) | `set_kondisi()` / `get_kondisi()` / `debug_kondisi`; 12 awan (bola pipih, melayang) + hujan 160 tetes (MultiMesh, mengikuti kamera) + penggelapan langit/cahaya per kondisi |
| `scripts/cuaca.gd.uid` | Dibuat otomatis Godot saat import (cache class baru) |
| `FITUR-CUACA-STATUS.md` (file ini) | Status + spesifikasi hook untuk Raka |

**TIDAK disentuh:** `main.gd`, `ui.gd`, `audio_pesantren.gd`, file agen lain,
folder v2. **JANGAN deploy** (perintah tugas).

## Cara kerja

1. `Cuaca.mulai(langit)` dipanggil sekali saat pemain masuk game (hook di
   `main.gd`, lihat bawah). Flag `sudah_diminta` mencegah izin diminta ulang
   dalam satu sesi.
2. Bukan web (editor/VM/desktop) -> langsung fallback `cerah`, tanpa prompt.
3. Web: `navigator.geolocation.getCurrentPosition` lewat JavaScriptBridge
   (`create_callback` + `get_interface("window")`, timeout 10 detik,
   `maximumAge` 10 menit). Izin ditolak / tidak tersedia / timeout ->
   fallback `cerah`.
4. Lokasi diterima -> `HTTPRequest` ke
   `https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=weather_code`
   (timeout 12 detik). Gagal / HTTP != 200 / JSON rusak -> fallback `cerah`.
5. `weather_code` dipetakan (lihat tabel) -> `LangitDinamis.set_kondisi()`
   -> langit + awan + hujan berubah. Sinyal `cuaca_diperbarui(kondisi)`
   dipancarkan tiap penerapan (dipakai UI nanti kalau perlu).

## Pemetaan kode WMO (Open-Meteo) -> kondisi game

| Kode WMO | Arti | Kondisi game |
|---|---|---|
| 0, 1 | Cerah / sebagian besar cerah | cerah |
| 2 | Berawan sebagian | berawan |
| 3, 45, 48 | Mendung / kabut | mendung |
| 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99 | Gerimis / hujan / badai petir | hujan |
| 71, 73, 75, 77, 85, 86 | Salju (tidak relevan di Indonesia) | mendung (langit abu-abu, tanpa hujan) |
| lainnya / tak dikenal | — | cerah (fallback aman) |

## Efek visual per kondisi (jam 10.00, langit siang)

| Kondisi | Langit | Awan | Hujan | Ambient (jam 10) |
|---|---|---|---|---|
| cerah | normal | 3, putih, alpha 0.55 | mati | 0.85 |
| berawan | x0.92 | 7, putih keabu, alpha 0.75 | mati | 0.78 |
| mendung | x0.72 | 12, abu-abu, alpha 0.90 | mati | 0.61 |
| hujan | x0.55 | 12, abu gelap, alpha 0.90 | 160 tetes menyala | 0.47 |

Penggelap juga meredupkan energi + bola matahari (bulan tidak ikut redup).
Awan: 12 gumpalan (2 bola pipih tiap awan, tinggi 45-70 m, radius 30-150 m,
seed tetap 777), melayang pelan ke +X, bungkus di ±200 m. Hujan: 160 tetes
(BoxMesh 0.04 x 1.4 m, alpha 0.45) jatuh 16-24 m/s di kotak 40 x 24 x 40 m
mengikuti kamera — 1 draw call, tanpa sistem partikel baru.

## PRIVASI (KERAS)

- Koordinat dipakai HANYA untuk sekali panggil Open-Meteo. Variabel lokal
  di `_on_lokasi_ok` -> `_ambil_cuaca`, lalu dibuang.
- Koordinat TIDAK ditulis ke save file, TIDAK dikirim ke server game,
  TIDAK dicatat di log (log hanya "[Cuaca] Lokasi diterima…" tanpa angka).
  Cek sendiri: `grep -n "print" scripts/cuaca.gd` — tidak ada print lat/lon.
- Izin hanya diminta SEKALI per sesi; ditolak = fallback cerah, tidak
  pernah dipaksa / diminta ulang.

## Hasil uji (17 Nov 2026, VM)

### 1. Unit test logika — `fitur-baru/skrip/test_cuaca.gd` — **66/66 LULUS**
`godot --headless --path . test_cuaca.tscn`
- Pemetaan WMO: semua kode 0-99 yang terdaftar + kode tak dikenal (4, 100, -1) -> cerah.
- Parse JSON Open-Meteo: cerah/hujan/mendung/berawan benar; JSON rusak /
  kosong / tanpa `current` / tanpa `weather_code` / kode string -> cerah.
  (Dua baris `ERROR: Parse JSON failed` di output adalah stderr Godot dari
  input rusak yang sengaja dites — fallback-nya benar.)
- Fallback non-web: `mulai()` di VM langsung cerah, tanpa prompt.
- Sekali per sesi: `mulai()` ke-2 no-op (kondisi paksa tetap hujan).
- Hook langit: `set_kondisi` tak dikenal -> cerah; faktor gelap
  1.00 / 0.92 / 0.72 / 0.55; awan terlihat 3 / 7 / 12 / 12; hujan hanya
  nyala saat "hujan"; ambient jam 10: cerah 0.85, mendung 0.61, hujan 0.47;
  `debug_kondisi` mengalahkan kondisi Cuaca.

### 2. Tes jaringan Godot -> Open-Meteo — **BERHASIL (mengejutkan)**
`fitur-baru/skrip/test_cuaca_jaringan.gd` — `HTTPRequest` Godot dari VM
mencapai `api.open-meteo.com`: `result=0 http=200`, JSON valid. Jadi
masalah proxy lama (login server gagal dari Godot) TIDAK berlaku untuk
Open-Meteo — kemungkinan karena host-nya berbeda / proxy mengizinkan.
Bukti: `curl` shell ke koordinat Sidogiri (-7.65, 112.90) juga valid.

### 3. Tes ujung-ke-ujung — `fitur-baru/skrip/test_cuaca_e2e.gd` — **LULUS**
Simulasi callback geolocation (Sidogiri) -> HTTPRequest nyata -> kondisi
diterapkan ke langit. Cuaca Sidogiri saat tes (~21:00 WIB): **berawan**,
langit ikut `berawan`. Satu-satunya yang tidak bisa dites di VM: prompt
izin Geolocation di browser (butuh JavaScriptBridge + Chrome HP).

### 4. Foto 4 kondisi — `fitur-baru/foto/` (xvfb-run, 1280x720, jam 10.00)
Kamera sama persis tiap foto (depan Surau (-4,2,22) -> (-4,40,-60)):

| Foto | Isi | Verdict |
|---|---|---|
| `C1-cerah.png` | Langit biru terang, matahari kuat, 1 awan putih di pojok kanan atas | OK |
| `C2-berawan.png` | Sedikit lebih redup, 1 awan putih | OK |
| `C3-mendung.png` | Langit biru lebih gelap, 3 awan abu-abu, matahari redup | OK |
| `C4-hujan.png` | Paling gelap, awan abu gelap, **tetes hujan jelas terlihat** di seluruh frame | OK |

Catatan jujur foto: di C1/C2 hanya 1 awan masuk frame (3/7 awan yang aktif
tersebar di sekeliling 360°, sebagian di luar frustum kamera yang menghadap
utara). Di dalam game pemain menoleh, jadi awan tetap terlihat; bukan bug.
Awan terbaca sebagai elips pipih — sederhana sesuai brief v1, bisa
diperhalus di ronde perbaikan kalau Mas minta.

## Spesifikasi HOOK untuk Raka (pasang di main.gd — Wulan TIDAK edit main.gd)

**1. Deklarasi member** — di dekat `_audio` (sekitar baris 60-an):
```gdscript
# FITUR CUACA (Wulan, 17 Nov): cuaca nyata mengikuti lokasi user.
var _cuaca: Cuaca = null
```

**2. Panggil saat pemain masuk game** — di `_masuk_pesantren(pesan: String)`,
tepat sesudah `_ui.show_world()` (sekitar baris 694):
```gdscript
	# FITUR CUACA: minta izin lokasi sekali per sesi; langit mengikuti
	# cuaca nyata; fallback cerah kalau ditolak / gagal / bukan web.
	if _cuaca == null:
		_cuaca = Cuaca.new()
		_cuaca.name = "Cuaca"
		add_child(_cuaca)
	_cuaca.mulai(_pesantren["langit"])
```
Alasan posisi: `_pesantren["langit"]` (node `LangitDinamis` dari
`PesantrenBuilder.build()`) sudah ada sejak `_ready`; `mulai()` aman
dipanggil ulang tiap masuk (flag `sudah_diminta` mencegah prompt kedua).
Tidak perlu hook lain: `Cuaca` mengatur langit sendiri lewat
`set_kondisi()`; tidak ada perubahan UI / audio / save.

## Batasan jujur (apa yang belum terverifikasi)

- [ ] **Prompt izin lokasi di HP Mas** — kode JavaScriptBridge
  (`get_interface("window")` + `create_callback`) mengikuti pola yang
  didokumentasikan Godot, tapi HANYA bisa dibuktikan di export web di
  Chrome Android. Kalau callback tidak terpanggil, game tetap cerah
  (fallback aman) — tidak ada crash.
- [ ] **Tampilan hujan/awan di HP** — foto di atas dari render software
  xvfb (gl_compatibility). Seharusnya sama di web (renderer sama), tapi
  verdict akhir tetap mata Mas di HP.
- [ ] **Cuaca malam hari** — faktor gelap diterapkan di semua fase
  (termasuk malam, langit sudah gelap). Hujan malam belum difoto; tetes
  tetap terlihat karena material unshaded, tapi belum dibuktikan visual.
- [ ] **Tidak ada refresh berkala** — cuaca diambil sekali saat masuk
  game. Kalau pemain main berjam-jam dan cuaca berubah, langit tidak
  ikut berubah sampai masuk ulang. (Sengaja: hemat kuota + privasi;
  bisa ditambah timer refresh kalau Mas minta.)

## Skrip tes / foto (arsip, JANGAN di root proyek)

- `~/workspace/pesantren-verse/fitur-baru/skrip/test_cuaca.gd` (+ `.tscn`) — unit test 66 cek
- `~/workspace/pesantren-verse/fitur-baru/skrip/test_cuaca_jaringan.gd` (+ `.tscn`) — tes HTTPRequest -> Open-Meteo
- `~/workspace/pesantren-verse/fitur-baru/skrip/test_cuaca_e2e.gd` (+ `.tscn`) — rantai geolocation simulasi -> API nyata -> langit
- `~/workspace/pesantren-verse/fitur-baru/skrip/foto_cuaca.gd` (+ `.tscn`) — foto C1-C4
- `~/workspace/pesantren-verse/fitur-baru/foto/C1-cerah.png` … `C4-hujan.png`
- Copy sementara di root proyek sudah DIHAPUS setelah tes (arsip tetap di `fitur-baru/`).
