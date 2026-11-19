# Rencana Upgrade Visual — Dari Balok Primitif ke 3D Halus

**Status: RENCANA UNTUK REVIEW MAS — belum ada yang dibangun.**
**Tanggal:** 17 November 2026 · **Koordinator:** Arsa (arsitek) · **Tim:** Gilang (maps), Dewa (interior), Zahra (riset aset)
**Arah baru dari Mas (17 Nov ~15:01 WIB):** "intinya saya ingin upgrade tampilan gim, dr sekedar balok².. jadi benar² 3d seperti asian boy atau yg satunya itu..termasuk pohon, bangunan dll.. semunya diupgrade."

## Ringkasan eksekutif

- **Kondisi sekarang: 0 (nol) model 3D halus di seluruh game.** Semua geometri dibangun runtime dari primitif Godot (`BoxMesh`, `CylinderMesh`, `SphereMesh`, `TorusMesh`) lewat helper `Palette`. Tidak ada satu pun `load()` GLB/gltf di codebase — satu-satunya `preload` adalah font.
- **Total yang masih balok: 39 kelompok elemen luar (~726 mesh primitif) + 75 unit perabot interior (207 mesh primitif) = ~933 mesh primitif.** Karakter pemain/NPC juga masih primitif — tapi itu jalur terpisah yang sudah berjalan (Bima/Kirana, lihat §1).
- **Kabar baik: sebagian besar pengganti sudah ada GRATIS (CC0/CC-BY).** Dari riset Zahra: 13 kategori ter-cover penuh gratis, 5 separuh, 3 kosong dan harus dibuat di Blender. Pekerjaan Blender yang tersisa kecil dibanding membangun semua dari nol — gapura adalah satu-satunya item besar.
- **Prinsip:** bentuk dan bahasa desain yang sudah di-ACC Mas di `DESAIN-ARSITEKTUR.md` (kubah bawang, lengkung lancip, menara, hierarki Surau > Musholla, palet krem/zamrud/emas/jati) **tetap dipakai** — yang berubah adalah cara membangunnya: dari primitif Godot menjadi model 3D halus impor + buatan Blender. Desain dulu, Mas review, baru dibangun — per fase, game live (Ronde 23) tidak disentuh sampai tiap fase lolos retest.

## Blocker saat ini — akun Sketchfab (15:06 WIB)

**Pembuatan akun Sketchfab TERHALANG.** Google OAuth akun billishitam@gmail.com sudah disetujui Mas (verifikasi ketuk angka 51 selesai di HP), tapi Sketchfab menolak pembuatan akun baru lewat Google — pesan: *"Account creation is only available through Epic Games"* (terjadi 2×, halaman kembali ke `sketchfab.com/login?error_code=1`).

**Dampak ke rencana ini:** semua model CC-BY dari Sketchfab (Stylized Mosque, pohon hero, rak kitab, ranjang susun, lampu, bangku, papan tulis, batu, dan semua "pilihan utama" CC-BY di §2–§7) **tidak bisa diunduh sampai akun ada**. Termasuk Asian Boy (§1) — unduhnya tertunda. Yang **tidak** terdampak: sumber CC0 tanpa akun (Quaternius, KayKit, Poly Haven, ambientCG) dan semua yang dibuat di Blender.

**Opsi untuk Mas (keputusan §11 no. 8):** (a) lanjut lewat Epic Games — perlu akun Epic; (b) pakai akun Sketchfab yang sudah ada (kalau Mas/bukan punya); (c) berhenti — maka semua item CC-BY Sketchfab diganti fallback CC0 (Quaternius/KayKit) + dibuat di Blender. Rencana ini ditulis dengan asumsi akun Sketchfab akhirnya ada; kalau opsi (c) yang dipilih, Fase 1–2 harus direvisi (Masjid Besar dan sebagian perabot jadi pekerjaan Bima).

## 0. Prinsip & batasan keras

- **GRATIS SAJA** — tidak ada model berbayar, tidak ada tier berbayar. Lisensi hanya CC0/CC-BY. Meshy galeri komunitas **bukan sumber** (unduh terkunci PRO untuk akun gratis, terverifikasi 17 Nov). Fab, CGTrader/TurboSquid "Royalty Free" ditolak (risiko .pck bisa dibongkar).
- **Game tetap Godot 4.7.2, export GLB.** Model impor masuk sebagai GLB; collision dibangun ulang (model impor tidak membawa setup collision yang sekarang).
- **Palet arsitektur dipertahankan:** krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A`. Hampir semua model gratis datang dengan warna sendiri — **recolor ke palet adalah pekerjaan wajib** sebelum masuk game (Kirana/Bima).
- **Gaya target:** 3D halus/stylized seperti "cartoon Asian Boy" — permukaan bulat lembut, bukan balok/voxel, bukan low-poly faceted kasar. Catatan jujur Zahra: aset gratis yang benar-benar halus seperti Asian Boy hampir tidak ada untuk lingkungan; yang ada adalah low-poly stylized dengan derajat faceted berbeda. Penilaian di rencana ini membedakan "cocok" vs "bisa dipakai (perlu smoothing/retexture)" vs "tidak cocok".
- **Jalur karakter berjalan terpisah** (Bima adaptasi Sloyd + Asian Boy + eksperimen Meshy) — rencana ini **merujuk** ke jalur itu, tidak mengulang dan tidak mengganggunya.
- **Posisi & ukuran bangunan mengikuti game live saat ini** (hasil audit), bukan angka lama di `DESAIN-ARSITEKTUR.md` (dokumen itu menyebut Surau (0,−12) dan Musholla (62,−24) — sudah kedaluwarsa; posisi live: Surau (0,−14) diputar −25°, Musholla (134,−24)).

## 1. Karakter — SUDAH BERJALAN (dirujuk, bukan bagian rencana ini)

| Jalur | Status 17 Nov | Budget |
|---|---|---|
| Bima: adaptasi Sloyd ChibiCharacter → putra + putri | Berjalan sejak 13:27. Base selesai + putra dibangun + 4 render 14:36–14:37. ⚠️ Render putra masih rusak (wajah robek berserpihan, kepala melayang, tangan belum ada); putri belum dibuat. Penyebab: mesh Sloyd hasil AI berantakan + wajah/badan menyatu | Rig ringan (Rigify), export GLB; target <30 ribu tris per karakter |
| Asian Boy (Sketchfab, giyasudeen31) | Studi Kirana selesai: LAYAK jadi base putra (3,66 kepala — lebih chibi dari referensi; wajah+rambut paling mirip; 62.434 tris, paling ringan; CC-BY). Unduh butuh akun gratis Sketchfab — Mas sudah ACC (14:20), browser task jalan, menunggu Mas pilih akun Google di kartu | Diet ke <30 ribu tris; scale kepala ~0,85; tambah kacamata besar + alis tebal |
| Eksperimen Meshy image-to-3D | SELESAI & berhasil: 1 model bertekstur ter-generate dari referensi, GLB 8,5 MB, 20 kredit, saldo 120. ⚠️ Cacat: gambar referensi berisi 2 figur + logo Blender → hasil berisi 2 figur + bidang logo melayang. Generate ulang dengan gambar dipotong — keputusan Mas ditunggu | 145.674 wajah (mentah) — butuh retopology berat sebelum bisa dipakai |

Keputusan karakter yang masih menggantung (di luar rencana ini, sudah disampaikan ke Mas): generate ulang Meshy dengan gambar dipotong? Base putra final: Asian Boy vs Sloyd vs hasil Meshy?

## 2. Bangunan

### 2.1 Surau (0,−14) — bangunan utama, ~88 mesh primitif

| Kondisi sekarang | Usulan pengganti | Sumber | Tris |
|---|---|---|---|
| Dinding box, atap pelat box, kubah = bola digepeng (skala Y 0,9), 4 kubah kecil bola gepeng, menara = tumpukan silinder, portal = 7 keping box, jendela box + cakram | Bangun ulang sebagai **model Blender hero mengikuti desain ACC** (kubah bawang zamrud + sabit emas, 4 kubah kecil, menara ramping sudut tenggara, portal lengkung lancip, 6 jendela lengkung, serambi 3 lengkung) — atau kitbash masjid + elemen Blender | **Dibuat Bima** di Blender (mengacu `DESAIN-ARSITEKTUR.md` §1 + gambar `media-generation-01/02`) — bukan model unduhan, karena tidak ada masjid 20×16 m bergaya pesantren yang gratis-cocok. Stylized Mosque (di bawah) dipakai untuk Masjid Besar, bukan Surau | Target ≤ 40 ribu |

### 2.2 Musholla Ar-Raudhah (134,−24) — ~97 mesh primitif

| Kondisi sekarang | Usulan pengganti | Sumber | Tris |
|---|---|---|---|
| Dinding box, atap datar box zamrud, kubah = bola digepeng (skala Y 0,72) + sabit TorusMesh, serambi box jati | Model Blender hero mengikuti desain ACC (1 kubah zamrud ramping + sabit emas, **tanpa menara**, serambi kayu, pintu lengkung kecil, 4 jendela lengkung, pagar kayu + taman) | **Dibuat Bima** di Blender (mengacu `DESAIN-ARSITEKTUR.md` §2 + gambar `media-generation-03/04`) | Target ≤ 30 ribu |

### 2.3 Masjid Besar (plot terkunci (0,−32)) — belum dibangun

| Usulan | Sumber | Tris |
|---|---|---|
| Pakai model masjid stylized utuh (kubah + menara), recolor dinding krem + kubah zamrud/emas | **Stylized Mosque — ChrisCLP, CC-BY** — https://sketchfab.com/3d-models/stylized-mosque-f18722b66d1e459b94e189fb3f41781f — 35,2k tris, 3.226 unduhan. Gaya sama dengan Stylized Tree penulis yang sama (konsisten dengan pohon hero, §3) | 35,2 ribu |

### 2.4 Lima gedung generik kampus putri + 2 Cangkruk + 6 pos jaga

Kondisi sekarang: kelima gedung (Kelas (130,0), Asrama (152,0), Kantor Ustadzah (150,−28), Madrasah (152,−12), Studio (166,−12)) adalah **klon pola yang sama** — 6 box dinding + atap datar box zamrud + lis emas + 8 box jendela (~19 mesh tiap gedung, total ~95). Cangkruk Putra/Putri 10×8 m (~21 mesh tiap): cangkang box kayu + atap segitiga 2 pelat box. Pos jaga/satpam 6× (3×3 m): gubuk box + atap piramida kerucut 4-segmen.

| Usulan pengganti | Sumber | Tris |
|---|---|---|
| Kitbash modular jadi 2–3 varian gedung berbeda (supaya kampus tidak terlihat copy-paste): dinding + atap + jendela disusun ulang per gedung, recolor ke palet | **Medieval Village MegaKit — Quaternius, CC0** — https://quaternius.com (paket Medieval Village MegaKit, juga di Fab gratis) — potongan modular ringan (FBX/OBJ/glTF). Gaya medieval-Eropa: atap & jendela harus dirombak/recolor. Atap joglo/limasan tidak ada di kit ini | Per gedung ≤ 5 ribu (varian dipakai ulang/instansi) |
| Pondok hero bergaya pesantren (1–2 buah, kalau Mas menolak hasil kitbash yang terlalu "Eropa") | **Dibuat Bima** di Blender — hanya kalau Mas minta (keputusan §11 no. 3) | ≤ 8 ribu tiap |
| Pos jaga/satpam: gubuk kayu kitbash + atap limasan halus (bukan piramida 4-segmen) | Medieval Village MegaKit (CC0) + recolor | ≤ 2 ribu tiap, instansi 6× |
| Cangkruk: cangkang kayu kitbash + atap 2 lereng halus + bubungan | Medieval Village MegaKit (CC0) + recolor | ≤ 5 ribu tiap |

## 3. Pepohonan & vegetasi — 61 pohon "lollipop" (183 mesh), 6 semak, 4 batu

Kondisi sekarang: tiap pohon = batang silinder + 2 bola tajuk (pola "lollipop" yang sama diulang 61× sampai radius 210 m). Semak = bola gepeng, batu = bola abu-abu gepeng. **Tidak ada pohon di dalam kampus putri.**

| Usulan pengganti | Sumber | Tris |
|---|---|---|
| Basis vegetasi: 40 pohon + 35 tanaman/bunga + 27 batu + rumput + semak dari satu paket konsisten (Ghibli-inspired, bertekstur, daun 7 varian). Recolor daun ke hijau zamrud | **Stylized Nature MegaKit — Quaternius, CC0** — https://quaternius.com/packs/stylizednaturemegakit.html — FBX/OBJ/glTF; pohon ~3.600 tris. Tier gratis = 60–70% isi paket (cukup) | Massal ≤ 1 ribu (pakai varian ringan + instansi MultiMesh); hero ≤ 4 ribu |
| Pohon hero (1–2 di dekat Surau/Musholla, gaya paling dekat Asian Boy) | **Stylized Toon Tree — ahingel, CC-BY** — https://sketchfab.com/3d-models/stylized-toon-tree-c97cc0cc657c43a89c7332e3c28ac8aa — 22,5k tris (berat: 1–2 pohon saja) | 22,5 ribu (hero saja) |
| Pohon hero ringan (penulis sama dengan Stylized Mosque — gaya konsisten) | **Stylized Tree — ChrisCLP, CC-BY** — https://sketchfab.com:443/3d-models/stylized-tree-113e4e48d4214b958d017157aeb6c8dd — 3,8k tris | 3,8 ribu |
| Palem/kurma (satu-satunya palem CC-BY ringan yang ketemu) | **Date palm tree from Poly by Google — IronEqual, CC-BY** — https://sketchfab.com/3d-models/date-palm-tree-from-poly-by-google-590ed25eeba94324946fc2fecddfa21a — 1,1k tris | 1,1 ribu |
| Pinus latar (jumlah banyak, jauh) | **Pine Tree — Proto Series — BitGem, CC-BY** — https://sketchfab.com/3d-models/pine-tree-proto-series-free-08014e92a59244c992884091218230b8 — 876 faces | 876 faces |
| Bambu berpot (dekat musholla/teras) | **Bamboo with plant pot — Snowism, CC-BY** — https://sketchfab.com/3d-models/bamboo-with-plant-pot-19c7ca832f4246638cbbd53be9ff6184 — 9,4k tris | 9,4 ribu |

Catatan: Kenney Nature Kit (CC0) **tidak dipakai** sebagai utama — gayanya balok, Mas sudah menolak balok. Hanya fallback darurat untuk pohon massal super ringan.

## 4. Terrain, gunung, sawah & jalan

| Elemen | Kondisi sekarang | Usulan pengganti | Sumber |
|---|---|---|---|
| Tanah 800×800 m | 1 BoxMesh raksasa, datar sempurna, tanpa relief | Terrain Godot (heightmap) + tekstur rumput CC0 — bukit landai + relief, bukan datar | **Dibuat Gilang/Kirana** di Godot + tekstur **Poly Haven / ambientCG (CC0)** — https://polyhaven.com, https://ambientcg.com |
| Gunung ×2 (70 & 85 m) | Kerucut 8-segmen raksasa, faceting terlihat dari jauh | Gunung stylized halus (mesh sculpt + tekstur) atau ganti siluet dengan bukit + pepohonan | **Dibuat Kirana** (mesh sederhana + tekstur rumput CC0) — bukan model unduhan (tidak ada bukit standalone yang cocok) |
| Sawah (60,30) 60×40 m | 12 petak air box + 9 pematang box + 24 rumpun padi kerucut 6-segmen + gubuk sawah box | Air = plane + tekstur air CC0; padi = tanaman instansi dari Nature MegaKit; gubuk = kitbash | Quaternius Nature MegaKit (CC0) + tekstur Poly Haven (CC0) |
| Jalan (5 ruas, total ~700 m) | Pelat box pasir tipis, tanpa trotoar/batas | Plane + **tekstur PBR CC0** (cobblestone/paving/stone), diwarnai krem + tepi/batas jalan | **Poly Haven / ambientCG (CC0)** — tanpa akun, API gratis. Bukan model 3D (lebih ringan & fleksibel) |
| Batu hias | 4 bola abu-abu gepeng | Batu stylized variasi | **70 stylized rocks — ondrasaur, CC-BY** — https://sketchfab.com/3d-models/70-stylized-rocks-bf0051544c9c41f998c154c546b09669 — 5,6k tris total 70 batu, 12.112 unduhan |

## 5. Tembok, pagar, gerbang & gapura — ~103 mesh primitif

| Elemen | Kondisi sekarang | Usulan pengganti | Sumber |
|---|---|---|---|
| Tembok pemisah x=14 (76 m) + tembok keliling putri (~274 m) | Box krem lurus + lis emas box + fondasi batu box | Dinding modular kitbash + lis + fondasi, recolor krem/emas; tambah pilaster/ornamen di interval supaya tidak monoton | **Medieval Village MegaKit — Quaternius, CC0** (dinding modular) |
| Pagar kayu Musholla (~51,5 m) | Tiang box + 2 rel box per segmen | Pagar kayu modular halus | **Kandidat: adam127 (Fence/Wooden gate) — https://sketchfab.com/adam127/ — LISENSI BELUM TERVERIFIKASI, cek halaman dulu**; atau **Modular palisade and gate — ice_screen, CC-BY?** — https://sketchfab.com/3d-models/odular-palisade-and-gate-312521930df04abba81feac5b0461897 — **lisensi belum terverifikasi**. Fallback yang lisensinya PASTI: Quaternius Medieval Village MegaKit (CC0) |
| Gerbang (14,0) + Gerbang Putri (115,0) | 2 pilar box + gapura box + 2 daun pintu box jati + Label3D | **Gapura pesantren dibuat di Blender** (2 pilar + atap lengkung + ornamen, palet krem/zamrud/emas) + daun pintu kayu kitbash | **Dibuat Bima** — satu-satunya item besar yang harus dibuat dari nol; torii Jepang **ditolak** (salah budaya) |
| Papan nama gedung ("GERBANG", "KELAS PUTRI", dll.) | Label3D teks datar 2 sisi | Papan kayu jati + teks timbul cat emas (model kecil) | **Dibuat Kirana** (~1 jam per papan, bisa tekstur di atas bidang) |

## 6. Interior & props — 75 unit perabot (207 mesh primitif), 3 interior beneran + 6 cangkang kosong

### 6.1 Surau (18×14 m, 34 unit, 88 primitif) & Musholla (14×10 m, 26 unit, 32 primitif)

| Elemen | Kondisi sekarang | Usulan pengganti | Sumber |
|---|---|---|---|
| Karpet Surau 17,4×13,4 m | 1 box datar zamrud gelap, tanpa motif | Plane + **tekstur karpet CC0** (motif tenun/saf) — dampak terbesar per usaha, elemen terbesar di interior | **Poly Haven / ambientCG (CC0)** + motif digambar Kirana |
| Sajadah ×30 (Surau 15 + Musholla 15) | Lempeng box tipis tanpa motif, seperti ubin hijau | Bidang datar + **tekstur kain CC0** motif mihrab sederhana (tidak ada model 3D sajadah CC0/CC-BY yang ketemu — jalurnya tekstur, bukan model) | **Dibuat Kirana** (plane + tekstur kain CC0 Poly Haven/ambientCG, motif digambar di Blender) |
| Mihrab | Papan datar menempel dinding (Surau 2 box, Musholla 1 box emas) | Ceruk lengkung + ornamen (model Blender, mengikuti desain ACC) | **Dibuat Bima** (kecil — ceruk + lengkung + lis emas) |
| Smartboard (Surau 4,6 m, Musholla 3,0 m) | 2 box (bingkai + layar KOSONG sejak Ronde 10) | Bingkai kayu halus + layar berisi (konten tetap popup UI seperti sekarang) | **Chalkboard — Luis Vidal, CC-BY** — https://sketchfab.com/3d-models/chalkboard-5359e67814bf447aa73fc0665ce6c5dc — 128 tris (papan tulis; smartboard dibuat dari bingkai ini + layar) — atau **School whiteboard — Pedro-Martins, CC-BY** — 7,7k tris |
| Rak kitab (Surau ×2, Musholla ×1) | Papan + tiang box; kitab = balok warna polos; rak Musholla satu balok pejal | Rak kayu antik + kitab terpisah (recolor sampul zamrud/emas) | **Antique wooden bookcase — Lorenzo Drago, CC-BY** — https://sketchfab.com/3d-models/antique-wooden-bookcase-game-model-75aa9519195647d99cf1e2d4863dbe87 — 3k tris, buku bisa dilepas/disusun ulang |
| Meja sampar ×3 (Surau) + ×1 (Musholla) | Silinder dipipih (tepi tajam) / box persegi; kitab balok tipis | Meja kayu halus + kitab berpunggung | **Ultimate Furniture Pack — Quaternius, CC0** / **KayKit Furniture Bits — CC0** — https://kaylousberg.itch.io/furniture-bits (50+ perabot, repo GitHub addon Godot; JANGAN beli tier EXTRA $3,95 / SOURCE $5,95) |
| Lampu gantung (Surau ×4, Musholla ×2, Cangkruk ×1) | Kap cakram + bola; Musholla: bola MELAYANG tanpa gantungan/kap | Lampu gantung 3-titik + gantungan + kap (Musholla wajib ditambah gantungan) | **Triple ceiling hanging lamp — gorzi, CC-BY** — https://sketchfab.com/3d-models/triple-ceiling-hanging-lamp-7d73fd18c28a431ea896558411bce07d — 4k tris, 9.733 unduhan |
| Pilar sudut (Surau ×4, Musholla ×4) | Silinder polos tanpa alas/kepala | Pilar + alas + kepala (kitbash atau Blender kecil) | Medieval Village MegaKit (CC0) / **Bima** (kecil) |

### 6.2 Cangkruk Putra (14×10 m, 15 unit, 87 primitif)

| Elemen | Kondisi sekarang | Usulan pengganti | Sumber |
|---|---|---|---|
| Tempat tidur ×5 (45 primitif) | Rangka + kasur + bantal + selimut semua kotak tajam; selimut = balok zamrud seperti papan | Kasur + bantal + selimut berlekuk halus | **Low Poly Bunk Bed #2 — JustBlender, CC-BY** — https://sketchfab.com/3d-models/low-poly-bunk-bed-2-7e5f290cf4474aba93979b6c7244f142 — 462 tris (untuk kasur susun; kasur tunggal ambil varian yang sama tanpa tingkat atas) — atau **KayKit Furniture Bits (CC0)** |
| Lemari pakaian | 1 balok pejal + pintu lempeng + cermin kotak biru | Lemari kayu halus (pintu + kenop + cermin) | Quaternius Ultimate Furniture Pack (CC0) / KayKit Furniture Bits (CC0) |
| Meja kecil + lampu meja + kitab | Silinder polos + lampu tiang + kitab balok | Meja bundar halus + lampu meja | Quaternius / KayKit (CC0) |
| Jendela ×3 | Bingkai kotak + kaca kotak emissive, dinding tidak dilubangi | Jendela lengkung berkisi (mengikuti desain ACC) | **Dibuat Bima** (kecil, satu varian dipakai ulang) |
| Karpet tengah 3×2 m | 1 box datar merah | Plane + tekstur karpet CC0 | Poly Haven / ambientCG (CC0) + Kirana |

### 6.3 Yang HILANG — bukan balok, tidak ada mesh sama sekali (paling terlihat "salah")

| Elemen | Bukti | Usulan |
|---|---|---|
| **Kursi Kyai** (Surau, 5.6,−305) dan **Kursi Ustadzah** (Musholla, 65.6,−305) | NPC duduk di posisi itu (`main.gd`, `npc.gd`) tapi `interior_surau.gd` / `interior_musholla.gd` tidak membangun kursi apa pun — kedua pimpinan duduk di udara kosong | Buat kursi kayu + rehal + kitab di depannya — **Bima** (kecil, satu varian dipakai 2×) — prioritas tinggi karena langsung terlihat salah saat masuk ruangan |

### 6.4 Enam ruangan kosong — cangkang saja, 0 perabot (pekerjaan TERPISAH dari ganti primitif)

Kelas Putri (130,0), Asrama Putri (152,0), Kantor Ustadzah (150,−28), Madrasah (152,−12), Studio (166,−12), Cangkruk Putri (128,−12) — hanya lantai + dinding + atap + jendela kotak, tanpa wiring pintu di `main.gd` (pemain tidak bisa masuk). **Temuan penting Dewa: ranjang susun putri (5 kasur susun = 10 kasur) TIDAK ADA** — hanya tertulis sebagai komentar di header `_cangkruk_putri` ("isi sebenarnya di map interior terpisah") — map itu belum pernah dibuat, tidak ada file `interior_cangkruk_putri.gd`.

| Ruangan | Isi interior yang dibutuhkan | Sumber |
|---|---|---|
| Kelas Putri | Meja-kursi belajar + papan tulis + rak | **Low Poly Classroom Assets — Paolo Mercogliano, CC-BY** — https://sketchfab.com/3d-models/low-poly-classroom-assets-3cdd052414544149a1f4edff9d9198c3 — 151,7k tris total paket (ambil satuan yang perlu saja) + **Low Poly School Desk — DumApe, CC-BY** (256 tris) + **Chalkboard Luis Vidal** (128 tris) |
| Asrama Putri | Ranjang susun ×5 (= 10 kasur) + lemari | **Low Poly Bunk Bed #2 — JustBlender, CC-BY** (462 tris) — instansi 10× |
| Kantor Ustadzah | Meja kerja + kursi + lemari arsip | **Low Poly Office — Paolo Mercogliano, CC-BY** — https://sketchfab.com/3d-models/low-poly-office-cc81191e0e90409c94df23ad4045f175 — 6,4k tris |
| Madrasah | Meja-kursi + papan + rak | Sama dengan Kelas Putri (paket Classroom Assets) |
| Studio | Meja + kursi + peralatan | Low Poly Office + Classroom Assets (CC-BY) |
| Cangkruk Putri | Ranjang susun ×5 + lemari + meja (interior map BARU + wiring pintu) | Low Poly Bunk Bed #2 (462 tris) instansi 10× + perabot Quaternius/KayKit (CC0) |

Catatan: ruangan kosong butuh **desain interior dari nol + wiring pintu di `main.gd`** (Raka) — itu pekerjaan terpisah dari mengganti primitif yang sudah ada. Masuk Fase 4, bukan Fase 1.

### 6.5 Mimbar — status BELUM PASTI

Satu-satunya kandidat: **PULPIT_PODIUM_MIMBAR — atsaqib200021** — https://sketchfab.com/3d-models/pulpit-podium-mimbar-a7bb7c6802fa4d5bb3e0251d98ddb529 — 28,7k tris — **lisensi BELUM TERVERIFIKASI, wajib cek di halaman sebelum pakai**. Kalau bukan CC-BY → **dibuat Bima** (mimbar kayu + tangga 3 anak tangga, aksen emas). (Catatan: "Mosque pulpit (minbar)" MAHS adalah CC BY-NC-ND — **ditolak**, jangan dipakai.)

## 7. Props luar — lampu jalan ×13, bangku, pot bunga, tempat sampah, peti M3, sandal

| Elemen | Kondisi sekarang | Usulan pengganti | Sumber |
|---|---|---|---|
| Lampu jalan ×13 | Tiang silinder hitam + bola emissive, tanpa lengan | Lampu jalan/taman stylized | **Lamp post light — Sousinho, CC-BY** — https://sketchfab.com:443/3d-models/lamp-post-light-ff5e3bc99dd146d986cb662813ec988e — 3,8k tris (PILIHAN UTAMA; kaca lampu objek terpisah) — alternatif: **Modern Chinese Street Lamp — Cyrus_JS, CC-BY** (1,9k tris, nuansa Timur, cocok taman pesantren) |
| Bangku taman | (belum ada — perlu ditambah di taman/serambi) | Bangku kayu hand-painted | **Park Bench Stylized Handpainted — Raphael C (Qurka), CC-BY** — https://sketchfab.com/3d-models/park-bench-stylized-handpainted-game-ready-fc8ccc0807f34b709c0a8f735dd70f03 — **196 tris** (gaya paling dekat target) |
| Pot bunga | Bedeng box + bunga bola kecil | Pot bunga kartun + tanaman | **Free Flower Pot — Cartoon Style Plant — Mrxxx, CC-BY** — https://sketchfab.com/3d-models/free-flower-pot-cartoon-style-plant-3d-model-2be0a24fecee4e38978391b3f02623ab — 32,3k tris (pakai secukupnya/decimate) — massal: **Lowpoly flower pot — Luiza Moreira, CC-BY** (336 tris) |
| Tempat sampah | (ikut paket kelas) | 2 bins dari paket kelas | Low Poly Classroom Assets — Paolo Mercogliano, CC-BY (ambil mesh bin-nya saja) |
| Peti Kayu M3 (0,26) | ~9 box (badan + tutup + pita emas + kunci) | Peti kayu halus (tutup melengkung + pita + kunci) | **Dibuat Bima** (kecil) atau kitbash Quaternius Fantasy Props (CC0) |
| Sandal ×4 set | 2 silinder pipih cokelat | Sandal jepit halus | **Dibuat Kirana** (kecil) atau cari model satuan CC-BY di Poly Pizza |

## 8. Budget poligon, performa & ukuran file

### 8.1 Angka dasar (dari audit)

- Luar: ~726 mesh primitif / 39 kelompok — hampir semua mesh primitif itu sendiri murah (box = 12 tris, silinder puluhan, bola ratusan), jadi **jumlah tris sekarang bukan masalah — jumlah draw call yang masalah** (~933 MeshInstance3D ≈ ~933 draw call di web).
- Interior: 207 mesh primitif / 75 unit.
- `.pck` live sekarang: 1.623.472 B (~1,6 MB) — hampir seluruhnya kode; model akan menaikkan ukuran ini.

### 8.2 Budget yang diusulkan (untuk diuji di Fase 1, bukan angka mati)

| Item | Budget |
|---|---|
| Bangunan hero (Surau / Musholla / Masjid Besar) | ≤ 40 ribu tris tiap |
| Gedung generik / Cangkruk / pos jaga (kitbash, dipakai ulang) | ≤ 5 ribu tris tiap |
| Pohon massal (instansi MultiMesh) | ≤ 1 ribu tris tiap |
| Pohon hero | ≤ 4 ribu tris tiap (kecuali Toon Tree 22,5k — maks 1–2 buah) |
| Perabot interior satuan | ≤ 2 ribu tris tiap |
| Ranjang susun | 462 tris (instansi 10×) |
| Karakter (player/NPC) | < 30 ribu tris tiap (sesuai rekomendasi Kirana untuk Asian Boy) |
| **Total adegan terlihat** | **≤ 500 ribu tris** |
| **Draw call** | **≤ 150** (turun dari ~933 — via MultiMeshInstance3D untuk pohon/batu/bunga/pagar + material bersama) |
| **Ukuran .pck** | **≤ 15 MB** (dari 1,6 MB sekarang) — impor HANYA model yang dipakai, bukan paket utuh; hero ≤ 5 MB/file, massal ≤ 500 KB/file |
| **Collision** | Bentuk sederhana (box/capsule) untuk dinding/lantai; trimesh HANYA untuk objek kecil yang benar-benar butuh |

### 8.3 Cara uji

- Setelah Fase 1: ukur FPS + waktu muat di HP Mas (Galaxy A35 5G) dan di browser — bukan hanya di VM. Kalau berat, turunkan: ganti pohon massal ke varian ≤ 500 tris, kurangi jarak pandang (culling), matikan bayangan untuk objek kecil.
- Setiap fase deploy ke staging dulu, retest browser, baru ganti live. Ronde 23 tetap live sampai penggantinya lolos.

## 9. Urutan fase (prioritas)

| Fase | Isi | Siapa | Perkiraan |
|---|---|---|---|
| **Fase 0 — Karakter (SUDAH BERJALAN)** | Bima Sloyd putra+putri; Asian Boy (unduh → verifikasi rig/mesh → adaptasi); Meshy (generate ulang? — keputusan Mas) | Bima, Kirana | Berjalan |
| **Fase 1 — Wajah pesantren** | Surau + Musholla model Blender hero (mengikuti desain ACC) + pohon massal Quaternius + 1–2 pohon hero + rumput/semak | Bima (bangunan), Kirana (recolor + pohon), Gilang (penempatan di peta), Raka (impor + collision + deploy + retest) | Paling terasa: 2 bangunan yang dilihat dari detik pertama + pola lollipop hilang |
| **Fase 2 — Kampus lengkap** | 5 gedung generik kitbash (2–3 varian) + Cangkruk + pos jaga + tembok/pagar kitbash + gapura Bima + papan nama + terrain/jalan/gunung/sawah | Bima (gapura), Kirana (recolor, papan nama, terrain), Gilang (layout jalan + penempatan), Raka (impor + deploy) | Kampus putri berhenti terlihat copy-paste |
| **Fase 3 — Interior** | Karpet + sajadah (tekstur), kasur Cangkruk, smartboard, rak kitab, lampu Musholla, kursi Kyai/Ustadzah yang hilang, mimbar (verifikasi lisensi / Bima) | Dewa (interior), Kirana (tekstur), Bima (mimbar + kursi + mihrab), Raka (wiring + deploy) | Interior berhenti terasa kotak; pimpinan tidak lagi duduk di udara |
| **Fase 4 — Ruangan kosong + props** | Interior 6 ruangan (Kelas, Asrama, Kantor, Madrasah, Studio, Cangkruk Putri incl. ranjang susun ×5 + wiring pintu) + props luar (lampu jalan, bangku, pot, tempat sampah, peti, sandal) | Dewa (interior), Raka (wiring pintu + deploy), Kirana (props kecil) | Semua gedung bisa dimasuki; tidak ada lagi cangkang kosong |

Urutan ini mengikuti arahan Mas: karakter dulu (sudah berjalan) → bangunan → pohon/props → interior. Fase 1 dan 2 bisa digabung kalau Mas mau lebih cepat, tapi risikonya retest lebih besar — rekomendasi Arsa: tetap per fase, supaya tiap deploy bisa dinilai Mas dengan mata.

## 10. Risiko (jujur)

1. **Performa web.** Model halus = lebih banyak tris + file .pck lebih besar (1,6 MB → s.d. 15 MB). Mitigasi: budget §8, instansi MultiMesh, impor hanya yang dipakai, uji FPS di HP Mas setelah Fase 1. Kalau berat, turunkan kualitas pohon massal dulu.
2. **Gaya belang.** Model datang dari banyak penulis (Quaternius, ChrisCLP, KayKit, puluhan penulis Sketchfab) — tanpa recolor + satu pengarah gaya, dunia bisa terlihat campur aduk. Mitigasi: recolor massal ke palet (§0) + Kirana sebagai penanggung jawab konsistensi gaya; paket Quaternius sebagai basis karena gayanya konsisten antar paket.
3. **Lisensi.** 3 kandidat belum terverifikasi (mimbar atsaqib200021, pagar adam127, pagar ice_screen) — **jangan dipakai sebelum dicek di halaman modelnya**. Semua CC-BY wajib masuk daftar atribusi di kredit game (draf lengkap di `RISET-ASET-GRATIS-ZAHRA.md` §7 — finalisasi setelah model benar-benar dipilih & diunduh; lisensi bisa berubah, cek ulang saat unduh + simpan screenshot lisensi).
4. **Akun unduhan — Sketchfab TERHALANG (lihat Blocker di atas).** Sketchfab menolak pembuatan akun baru lewat Google ("Account creation is only available through Epic Games", 15:06 WIB). Semua unduhan CC-BY Sketchfab tertunda sampai Mas memilih: Epic Games, akun Sketchfab yang sudah ada, atau berhenti (fallback CC0 + Blender). Quaternius/KayKit/Poly Haven/ambientCG tidak butuh akun berbayar (Quaternius via itch, gratis) — jalur CC0 tetap jalan.
5. **Karakter tetap risiko terbesar.** Mesh Sloyd hasil AI sudah terbukti bermasalah (render putra 14:36 rusak: wajah robek, kepala melayang). Jalur karakter berjalan terpisah — rencana ini tidak mengubahnya, tapi kalau base karakter gagal total, Fase 0 mundur dan Fase 1–4 tetap bisa jalan (bangunan/pohon tidak tergantung karakter).
6. **Ruang lingkup merayap.** 933 primitif + 6 ruangan kosong + ranjang susun yang belum ada = pekerjaan beronde-ronde, bukan satu ronde. Mitigasi: fase per fase, Mas ACC tiap fase sebelum lanjut. Jangan tambah bangunan/area baru selama upgrade berjalan.
7. **Collision & gameplay.** Mengganti mesh berarti membangun ulang collision (dinding, pintu, batas). Risiko regresi: pemain nyangkut/tembus (sudah pernah terjadi di Musholla). Mitigasi: tiap fase retest browser penuh (jalan masuk semua gedung, gerbang, batas) sebelum deploy live.
8. **Desain lama vs posisi baru.** `DESAIN-ARSITEKTUR.md` masih menyebut posisi lama (Surau (0,−12), Musholla (62,−24)); posisi live sudah pindah (Surau (0,−14) −25°, Musholla (134,−24)). Rencana ini memakai posisi live dari audit — desain bentuknya yang dipakai, bukan angka posisinya.

## 11. Keputusan yang dibutuhkan dari Mas (sebelum ada yang dibangun)

1. **ACC rencana + urutan fase?** Fase 1 dulu (Surau + Musholla + pohon), lalu Fase 2–4 — atau ada yang mau didahulukan/diubah?
2. **Stylized Mosque (ChrisCLP) sebagai Masjid Besar — boleh?** Masjid stylized gaya Kairo (kubah + menara), recolor krem/zamrud/emas. Kalau tidak cocok, Masjid Besar dibuat Bima.
3. **Pondok: kitbash Quaternius dulu, atau Bima buatkan 1–2 pondok hero bergaya pesantren (joglo/limasan)?** Kitbash cepat tapi nuansanya Eropa; pondok hero lebih Indonesia tapi makan waktu Bima (yang juga sedang mengerjakan karakter + gapura + Surau/Musholla).
4. **Gapura dibuat Bima — ACC?** Satu-satunya item besar yang harus dibuat dari nol (tidak ada model gratis yang cocok; torii Jepang ditolak karena salah budaya).
5. **Kenney (gaya balok) boleh dipakai untuk objek latar jauh saja, atau tidak sama sekali?** Rekomendasi Arsa: tidak sama sekali, supaya gaya konsisten.
6. **Ruangan kosong (Kelas, Asrama, Kantor, Madrasah, Studio, Cangkruk Putri + ranjang susun) — masuk scope upgrade ini (Fase 4), atau ditunda?** Ini pekerjaan besar: desain interior dari nol + wiring pintu.
7. **Budget .pck s.d. 15 MB + uji FPS di HP Mas setelah Fase 1 — setuju?** Kalau 15 MB terasa berat, turunkan ke 10 MB (pohon massal lebih ringan, kurangi varian).
8. **Akun Sketchfab — bagaimana lanjut? (BLOCKER, paling mendesak)** Pembuatan akun lewat Google ditolak Sketchfab ("hanya lewat Epic Games"). Pilih: (a) lanjut lewat Epic Games (perlu akun Epic), (b) pakai akun Sketchfab yang sudah ada, atau (c) berhenti — semua item CC-BY Sketchfab diganti fallback CC0 + dibuat Bima (Fase 1–2 direvisi).

## Lampiran

- Audit dunia luar: `AUDIT-LUAR-GILANG.md` (39 kelompok, ~726 mesh primitif, 0 model halus)
- Audit interior: `AUDIT-INTERIOR-DEWA.md` (75 unit perabot, 207 mesh primitif, 6 cangkang kosong, 2 kursi hilang, ranjang susun putri tidak ada)
- Riset aset gratis: `RISET-ASET-GRATIS-ZAHRA.md` (13 kategori ter-cover, 5 separuh, 3 kosong; daftar atribusi CC-BY §7)
- Studi karakter: `blender-santri/riset-model-dasar/ASIANBOY-STUDY.md`, `blender-santri/riset-model-dasar/RISET-MODEL-DASAR.md`
- Desain arsitektur (ACC): `desain-arsitektur/DESAIN-ARSITEKTUR.md` + gambar `media-generation-01..04`, denah `05-denah-surau.png`, `06-denah-musholla.png`
- Referensi gaya: `blender-santri/karakter-baru/referensi-mas.jpg`
