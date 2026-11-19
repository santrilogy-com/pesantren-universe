# Perbaikan Jalan + Lampu Surau — STATUS

**Tanggal:** 16 Nov 2026 (pagi, ~09:00 WIB selesai tes; deploy BELUM — Damar setelah verifikasi)
**Pemicu:** Mas, 16 Nov ~12:36 WIB — "Suraunya aneh.. karena miring akhirnya jalannya ga lurus
terus ada lampu yg mengganggu". Keputusan Mas ~12:38 WIB (via options): **"Tetap miring —
perbaiki jalan + pindah lampu"**. Surau TETAP miring −25°, mihrab tetap rata dinding.
JANGAN putar balik bangunannya.

**Pekerjaan ini sempat diantrikan setelah investigasi sarung ronde 19, tidak pernah jalan,
lalu dikerjakan 16 Nov pagi.**

## Masalah (sudah diverifikasi sebelum edit)

- Tiang lampu jalan di **(-2.2, 0, -6)** berdiri 1,47 m dari pintu Surau yang diputar
  **(-2.11, -7.47)**, 0,54 m dari sumbu jalan ke pintu, 0,56 m dari titik keluar NPC —
  tepat di jalur belok dari jalan utama ke pintu.
- Pintu geser 2,1 m ke barat jalan (x=0) sehingga segmen pasir ronde 14 (3.0×2.5 m di
  (-1.0,-6.5)) menyambung diagonal / jog.
- `_lamp` di `pesantren_builder.gd` TIDAK punya collision body (pohon punya) — lampu
  mengganggu secara visual + posisi, bukan karena tabrakan fisik.

## Perubahan (hanya `scripts/pesantren_builder.gd`)

### 1. Lampu depan pintu pindah: (-2.2,-6) → (-6.5, 0, -7.5)

Baris 700–707. Daftar lampu sekarang (8 lampu, jumlah tetap):

```
(-2.2, 6), (2.2, -2), (-6.5, -7.5) [BARU], (-2.2, 24),
(2.2, 34), (-2.2, -24), (2.2, -34), (2.2, 44)
```

Jarak baru (diukur di tes, bukan perkiraan):

| Ukuran | Lama | Baru |
|---|---|---|
| Jarak ke pintu (-2.11,-7.47) | 1,47 m | **4,39 m** |
| Jarak ke sumbu jalan masuk | 0,54 m | **3,99 m** |
| Jarak ke titik keluar NPC (-2.75,-6.11) | 0,56 m | **4,00 m** |
| Jarak ke Kyai (-4.8,-4.8) | — | 3,19 m |
| Posisi vs tapak Surau | di jalur | 1,83 m di luar dinding selatan (lokal z 6,83 > 5) |

Lampu baru di sisi barat serambi — tidak menghalangi jalan, pintu, maupun rute NPC.
Semua lampu lain ≥ 2,7 m dari sumbu jalan (min 3,99 m — yaitu lampu baru itu sendiri).

### 2. Jalan pasir diluruskan: SATU garis lurus, tegak lurus pintu

Baris ~250–263. Segmen ronde 14 di (-1.0,-6.5) **dihapus**, diganti SATU box
bernama **"JalanSurau"**:

- Ukuran: **2,5 × 0,06 × 8,5 m** (lebar 2,5 m, panjang 8,5 m)
- Posisi: **(-3.91, 0.03, -3.62)**
- Rotasi: **rotation.y = -25°** (= `SURAU_ROTASI_DEG` — sejajar normal pintu)
- Ujung timur-laut: **pintu (-2.11,-7.47)** — bertemu pintu tegak lurus (sumbu pintu)
- Ujung barat-daya: **(-5.71, 0.23)** — di dalam lajur jalan timur-barat

Geometri yang menentukan (dihitung + diverifikasi di Python sebelum edit): normal pintu
(masuk 25° / keluar 205°) TIDAK memotong jalan utara-selatan (x=0) di luar bangunan —
ia memotong jalan timur-barat (z=0) di **(-5.60, 0)**. Jadi jalan baru berawal di
jalan E-W, bukan di jalan N-S. Titik keluar NPC (-2.75,-6.11) ada DI ATAS jalan baru
(jarak tegak lurus 0,005 m).

### Yang TIDAK disentuh

Pintu/bangunan/rotasi Surau (-25°), `outdoor_door`, `outdoor_exit`, koridor pintu
(sumbu 115° / masuk 25° / keluar 205°), rute NPC, Kyai (-4.8,-4.8), menara, penanda M1
(3,-6.5 — 5,21 m dari segmen jalan, tidak di jalan), peta (peta tidak menggambar
konektor — hanya dua jalan utama + poligon Surau miring — jadi tidak perlu diubah).

**Catatan Kyai vs jalan:** Kyai berdiri 1,31 m dari sumbu jalan; setengah lebar jalan
1,25 m — jadi tepi jalan hampir menyentuh kakinya (sisa ~6 cm). Alas pasir (top 0,06)
di bawah sandalnya (~0,10). Diperiksa di foto 05: Kyai berdiri di rumput, tidak ada
clipping. Kalau Mas menilai Kyai terlalu mepet jalan, opsi: geser Kyai ~0,5 m ke barat
— belum dilakukan (di luar brief).

## Verifikasi

### Tes headless — `test_jalan_lampu.gd` + `test_jalan_lampu.tscn`

**33 LOLOS / 0 GAGAL** (31 tercetak di ringkasan + 2 cek masuk/keluar pintu setelahnya),
smoke 600 frame, 0 script error.

> Catatan teknis: baris ringkasan "HASIL TES JALAN+LAMPU: 31 LOLOS / 0 GAGAL" tercetak
> SEBELUM 2 cek masuk/keluar pintu selesai — `_jalan()` adalah coroutine; `await` di
> loop jalan-masuk membuat `_ready` lanjut mencetak ringkasan dulu. Total sebenarnya
> 33/33. Bukan bug game, hanya urutan cetak.

Cek yang lolos (ringkas):
- Pintu tetap (-2.11,-7.47), rotasi Surau tetap -25°, `outdoor_door`/`outdoor_exit`
  tidak berubah.
- Node JalanSurau ada; ukuran 2.5×0.06×8.5; posisi (-3.91,0.03,-3.62); rotasi -25°;
  sumbu jalan sejajar normal pintu (|dot|=1.0000); ujung di pintu + ujung di lajur E-W.
- Segmen lama (-1.0,-6.5) hilang; lampu tetap 8; lampu lama hilang; lampu baru ada +
  semua jarak di atas.
- Kyai tetap (-4.8,-4.8), 1,31 m dari sumbu jalan; pohon ≥ 2 m dari segmen (min 7,37 m);
  penanda M1 5,21 m dari segmen.
- **Rute NPC dari 5 titik awal** — (0,2), (0,-30), (-20,0), (20,20), Kyai (-4.8,-4.8) —
  semuanya berakhir di titik keluar (-2.75,-6.11); titik keluar ada di atas jalan baru.
- **Pemain masuk Surau dengan jalan lurus dari titik keluar, lalu bisa keluar lagi**
  ke titik keluar yang sama.

Satu baris `ERROR: Condition "status < 0" ... ERR_CANT_OPEN` muncul sekali di awal run —
itu VM tanpa soundcard (sama seperti ronde 17), BUKAN bug game. Smoke 600 frame bersih.

### Foto — `~/workspace/pesantren-verse/foto-jalan-lampu/`

5 foto (960×540, jam debug 10:00, login PV-0001 "Tes"):

| Foto | Isi | Hasil |
|---|---|---|
| 01-jalan-lurus.png | Lebar dari (8,3.5,10) | ✅ Jalan diagonal lurus dari jalan E-W ke pintu; Surau tetap miring; lampu baru jauh di barat pintu |
| 02-pendekatan.png | Pendekatan dari (-6.5,2,4.5), pemain di jalan s=6 | ✅ Jalan pasir lurus langsung ke pintu; Kyai di kiri jalan; lampu baru berdiri bersih di barat pintu |
| 03-pintu-lampu.png | Close-up pintu + lampu | ✅ **Retake berhasil** (11:27 WIB) — pintu + plakat مصلى الإخلاص jelas, lampu baru berdiri bersih di barat pintu di samping Kyai, jalan pasir lurus ke pintu, tidak ada tiang yang menutupi frame |
| 04-dari-pintu.png | Dari pintu melihat kembali ke jalan | ✅ Jalan lurus dari pintu ke jalan E-W; pertemuan jalan bersih; tombol MASUK SURAU muncul; Kyai + Bilal terlihat |
| 05-kyai-jalan.png | Kyai + tepi jalan dari (0.5,2.2,5.0) | ✅ Kyai berdiri di rumput tepat di tepi jalan — kaki tidak kena pasir, tidak ada clipping; pintu + plakat مصلى الإخلاص terlihat |

### Insiden saat kerja

- **/tmp terhapus di tengah retake foto 03** (VM restart/penggantian — `/tmp` tmpfs 512 MB
  kosong total; log tes + log foto pertama hilang). Retake 03 pertama ikut mati
  (SIGTERM setelah ~117 menit, tanpa output). Pelajaran yang sudah ada di AGENTS.md
  terkonfirmasi lagi: log + hasil kerja jangan di /tmp. Retake diulang dengan log di
  workspace (`foto-jalan-lampu/retake03.log`).
- Foto 03 pertama: kegagalan framing skrip foto (kamera terlalu dekat lampu), bukan
  bug game — sama pola seperti insiden foto ronde 7/8/10/12/13/14/17/18.
- **Retake 03 pertama gagal total karena skrip salah ketik pola:** `foto_jalan_lampu_retake03.gd`
  ditulis `extends SceneTree` (padahal skrip foto asli `extends Node`) + path/main/login
  salah (`scenes/main.tscn`, `_masuk`, `_debug_jam`, `main._kamera`). Error: "Script inherits
  from native type 'SceneTree', so it can't be assigned to an object of type 'Node'" —
  lalu proses menggantung tanpa quit dan membakar CPU ~7 jam sampai dimatikan manual.
  Diperbaiki dengan menyalin pola `foto_jalan_lampu.gd` persis (extends Node, `_ready`,
  `res://main.tscn`, `_on_login`, kamera sendiri, `get_tree().quit(0)`); retake kedua
  selesai 18 detik, exit 0. Pelajaran: skrip foto/tes baru WAJIB meniru pola file yang
  sudah terbukti jalan, jangan tulis dari ingatan.

## Langkah berikut

1. ✅ Retake foto 03 selesai + diverifikasi (11:27 WIB) — semua 5 foto LOLOS.
2. ✅ Export ke `export/web/` SELESAI (11:28 WIB) — **TIDAK deploy** (menunggu Damar).
3. Antrian Raka berikutnya: (a) Musholla Ar-Raudhah; (b) perilaku ustadz/ustadzah
   (duduk-baca-kitab + patroli + penegakan batas area); (c) bagian game lamaran
   pengurus (pengumuman + label jabatan) setelah server v1.4.0 + app selesai.

## Export (11:28 WIB)

- `--import` exit 0 (hanya warning UID duplikat staging-vs-export yang sudah lama).
- `--export-release "Web"` exit 0 → `export/web/index.html`.
- **pck baru: 1.544.388 byte, sha256 `0897b3664a07c06064db5d34618ee5dc51885eb4a8e97dc8d39f0671635f5ac4`**
  (ronde 19: 1.544.260 byte `3b117b5b…` — +128 byte, hanya perubahan jalan+lampu).
- wasm `fc74679e…` TIDAK berubah; index.js `33c94cb3…` TIDAK berubah; worklet
  `index.audio.position.worklet.js` 2.973 byte ada.
- **Guard script di export segar: 2/2** — BENAR untuk export segar (2 script: `index.js` +
  `GODOT_CONFIG` inline, `fileSizes.index.pck: 1544388` cocok). Guard 3/3 berlaku di
  **staging** setelah Damar memasang patch wasm-fetch (script ke-3) — itu langkah Damar,
  bukan export.
- **Smoke pck: 600 frame dari pck hasil export (`--headless --main-pack`), exit 0,
  0 SCRIPT ERROR.**
- Skrip tes/foto dipindah keluar proyek sebelum export (pola ronde-ronde sebelumnya):
  `~/workspace/pesantren-verse/perbaikan-jalan-lampu/skrip/` (6 file) + log
  import/export/smoke-pck di `~/workspace/pesantren-verse/perbaikan-jalan-lampu/`.

## File terkait

- `scripts/pesantren_builder.gd` (baris ~250–263 jalan, ~700–707 lampu)
- `test_jalan_lampu.gd`, `test_jalan_lampu.tscn`
- `foto_jalan_lampu.gd`, `foto_jalan_lampu.tscn`
- `foto_jalan_lampu_retake03.gd`, `foto_jalan_lampu_retake03.tscn`
- Foto: `~/workspace/pesantren-verse/foto-jalan-lampu/`
