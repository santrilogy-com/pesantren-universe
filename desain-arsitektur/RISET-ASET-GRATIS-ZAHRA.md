# Riset Aset 3D Gratis — Pengganti Elemen Balok Pesantren Universe

**Tanggal:** 17 November 2026 · **Periset:** Zahra (Tim Riset)
**Tujuan:** cari aset 3D halus GRATIS (lisensi CC0 atau CC-BY saja) untuk mengganti elemen balok di game — lingkungan + interior. **Bukan karakter** (itu jalur Bima/Kirana, sudah diriset terpisah).
**Status:** rencana saja — **tidak ada file model yang diunduh, tidak ada akun yang dibuat, tidak ada pembayaran.**

## Acuan gaya & palet

- **Gaya target:** 3D halus/stylized seperti "cartoon Asian Boy" (giyasudeen31) — wajah/bentuk bulat lembut, permukaan halus, **bukan balok/voxel, bukan low-poly faceted kasar**. Lihat `blender-santri/riset-model-dasar/ASIANBOY-STUDY.md` dan `RISET-MODEL-DASAR.md`.
- **Palet arsitektur (wajib dijaga):** krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A`. Sebagian besar model gratis datang dengan warna sendiri — **retexture/recolor ke palet ini adalah pekerjaan wajib** sebelum masuk game (Bima/Kirana).
- **Catatan gaya yang jujur:** hampir semua aset gratis yang benar-benar CC0/CC-BY adalah **low-poly** dengan derajat faceted yang berbeda-beda. Yang "halus" seperti Asian Boy hampir tidak ada untuk lingkungan. Jadi penilaian di bawah membedakan: **✅ cocok** (halus/stylized, tinggal recolor), **⚠️ bisa dipakai** (low-poly ringan tapi masih enak dilihat, perlu smoothing/retexture), **❌ tidak cocok** (balok/faceted kasar atau fotorealistik scan).

## Metode & sumber yang dicek

- **Sketchfab** — pencarian per kata kunci, filter "Download Free 3D model" + lisensi CC Attribution yang tercantum di hasil. **Catatan:** unduh Sketchfab butuh **akun gratis** (sama seperti Asian Boy — login wajib, bukan bayar). Semua tris/verts di bawah diambil dari halaman hasil pencarian Sketchfab, 17 Nov 2026.
- **Quaternius** (quaternius.com) — halaman paket resmi dibuka & diverifikasi (Stylized Nature MegaKit: CC0, FBX/OBJ/glTF).
- **Poly Pizza** (poly.pizza) — agregator 10.600+ model low-poly, lisensi per model CC0/CC-BY 3.0, format GLB, tanpa login.
- **KayKit** (kaylousberg.itch.io + GitHub) — paket CC0, ada repo GitHub berbentuk addon Godot.
- **Kenney** (kenney.nl/assets) — semua CC0, tapi gaya **balok** — dicatat hanya sebagai fallback, Mas sudah menolak balok.
- **OpenGameArt** — lisensi per aset (CC0/CC-BY/OGA-BY/GPL); hati-hati aset GPL (share-alike).
- **BlendSwap** — hanya CC0/CC-BY/CC-BY-SA; akun gratis dibatasi **5 unduhan/hari**; banyak file Blender lama (2.6x–2.8x) yang mungkin perlu perbaikan material.
- **Poly Haven / ambientCG** — tekstur PBR + HDRI **CC0**, tanpa akun, API gratis tanpa key. Solusi utama untuk jalan setapak & karpet (lihat §5).
- **Meshy (galeri komunitas)** — diklaim CC0, **tapi unduh model komunitas ternyata berlabel PRO untuk akun gratis (terverifikasi 17 Nov ~14:36 WIB)** — **JANGAN dijadikan andalan**. Hanya dicatat di mana relevan, bukan rekomendasi.
- **Fab (fab.com)** — sebagian besar berbayar; batch gratisnya terbatas waktu dan sudah lewat — **tidak diandalkan**.
- **Ditolak dari daftar:** semua model **berbayar**, lisensi **CC-BY-NC / CC-BY-SA / CC-BY-NC-SA / CC-BY-ND** (di luar mandat CC0/CC-BY), lisensi **"Free Standard" Sketchfab** (bukan CC — contoh: Turkish style minaret), dan **Royalty Free CGTrader/TurboSquid** (risiko .pck yang bisa dibongkar, sama seperti ronde 1–2 karakter).

> ⚠️ **Aturan sebelum unduh:** lisensi di bawah dibaca dari hasil pencarian 17 Nov 2026. Penulis bisa mengubah lisensi setelahnya — **cek ulang lisensi di halaman model saat mengunduh**, dan simpan screenshot lisensi. Semua model CC-BY wajib masuk daftar atribusi game (lihat §7).

---

## 1. Pohon + semak/bunga

Kategori **paling ter-cover**. Satu paket (Quaternius) + beberapa model satuan sudah cukup untuk seluruh vegetasi game.

| Model | Pembuat | Link | Lisensi | Format | Tris/verts | Penilaian |
|---|---|---|---|---|---|---|
| **Stylized Nature MegaKit (116 model: 40 pohon, 35 tanaman/bunga, 27 batu, rumput, semak)** | Quaternius | https://quaternius.com/packs/stylizednaturemegakit.html | **CC0** | FBX, OBJ, glTF | per model, pohon ~3.600 tris (ukur 2026-09-23) | ✅ **PILIHAN UTAMA kategori ini.** Gaya stylized konsisten (Ghibli-inspired), bertekstur, daun bisa ditukar 7 varian. Tier gratis = 60–70% isi paket (cukup). Recolor daun ke hijau zamrud. |
| **Stylized Toon Tree** | ahingel | https://sketchfab.com/3d-models/stylized-toon-tree-c97cc0cc657c43a89c7332e3c28ac8aa | CC-BY | GLB (standar Sketchfab) | 22,5k / 11,3k | ✅ Pohon toon hand-painted, gaya paling dekat dengan Asian Boy. Agak berat — 1–2 pohon hero saja. |
| **Stylized Tree** | ChrisCLP | https://sketchfab.com:443/3d-models/stylized-tree-113e4e48d4214b958d017157aeb6c8dd | CC-BY | GLB | 3,8k / 2,1k | ✅ Ringan, stylized, dibuat di Maya + Substance. Penulis yang sama dengan Stylized Mosque (§2) — gaya konsisten. |
| **Low-Poly Stylized Tree** | Kostas3D | https://sketchfab.com/3d-models/low-poly-stylized-tree-free-3d-model-game-asset-0adf522a14634f4fab0252233ab5f48a | CC-BY | GLB | 42k / 20,9k | ⚠️ Hand-painted, cantik, tapi 42k tris — terlalu berat untuk pohon yang diulang banyak. Pakai 1× atau skip. |
| **Date palm tree from Poly by Google** | IronEqual | https://sketchfab.com/3d-models/date-palm-tree-from-poly-by-google-590ed25eeba94324946fc2fecddfa21a | CC-BY | GLB | 1,1k / 592 | ✅ **Palem/kurma — satu-satunya palem CC-BY ringan yang ketemu.** Backup arsip Google Poly. Gaya Poly agak sederhana tapi halus, recolor mudah. |
| **Hand Painted Stylized Coconut Palm Tree Island** | Kigha | https://sketchfab.com/3d-models/hand-painted-stylized-coconut-palm-tree-island-0935d409de024174b2a231b47263a7cd | CC-BY | GLB | 25,9k / 13,1k | ⚠️ Palem kelapa hand-painted + pulau kecil. Berat; ambil pohonnya saja kalau bisa dipisah, atau skip. |
| **Pine Tree Trio** | Laurie Annis | https://sketchfab.com/3d-models/none-3d23f50333be4e34a3516af231d86f1c | CC-BY | GLB | 3,1k | ✅ Tiga pinus stylized pose lucu, tekstur albedo sederhana. Cocok untuk pembatas/hutan jauh. |
| **Pine Tree — Proto Series** | BitGem | https://sketchfab.com/3d-models/pine-tree-proto-series-free-08014e92a59244c992884091218230b8 | CC-BY | GLB/GLTF/USDZ | 876 faces / 452 verts | ✅ Pinus proto super ringan (386 KB). Gaya proto sederhana — bagus untuk pinus latar yang jumlahnya banyak. |
| **Low Poly Pine Tree** | kiritochi | https://sketchfab.com/3d-models/low-poly-pine-tree-47c47a6910ad43a88afc54a4508fc4ed | CC-BY | GLB | 300 / 195 | ⚠️ Pinus sederhana 300 tris. Faceted ringan — oke untuk latar jauh, jangan untuk hero. |
| **Bamboo with plant pot** | Snowism (@snowvy) | https://sketchfab.com/3d-models/bamboo-with-plant-pot-19c7ca832f4246638cbbd53be9ff6184 | CC-BY | GLB | 9,4k / 4,3k | ✅ Bambu berpot, hand-painted, 4.020 unduhan. Cocok di dekat musholla/teras. |
| **Low Poly Stylized Plant Tree** | Natural_Disbuster (@lemedesign) | https://sketchfab.com/3d-models/low-poly-stylized-plant-tree-d75cc0ef27104d04a5cf389d82411cec | CC-BY | GLB | 550 / 745 | ✅ Tanaman stylized 550 tris, warna saturasi kartun. Bagus untuk semak hias. |
| **Stylized handpainted tree [Alura's Course]** | EduardoIkeda | https://sketchfab.com/3d-models/stylized-handpainted-tree-aluras-course-0ccdbff7120140c598a51544f49728fe | CC-BY | GLB | 1,7k / 915 | ⚠️ Hand-painted, tapi hanya 31 unduhan — kualitas belum terbukti ramai. Cadangan. |
| **Kenney Nature Kit** | Kenney | https://kenney.nl/assets (filter: 3D) | **CC0** | GLB, FBX, OBJ | pohon median ~166 tris | ❌ **Gaya balok** — Mas menolak balok. Hanya fallback darurat kalau butuh pohon massal super ringan. |

**Verdict §1: TER-COVER.** Ambil Quaternius Stylized Nature MegaKit sebagai basis vegetasi + Stylized Tree/Toon Tree ChrisCLP & ahingel untuk pohon hero + Date palm IronEqual untuk kurma. Semak/bunga ikut dari MegaKit (35 tanaman/bunga). Tidak ada yang perlu dibuat di Blender, kecuali recolor ke palet.

---

## 2. Bangunan: rumah/pondok, musholla/masjid kecil, gapura/gerbang, pagar, tembok

Kategori **paling penting dan paling timpang**: masjid kecil stylized ADA yang bagus, tapi pondok bergaya pesantren dan gapura TIDAK ADA yang gratis-cocok.

| Model | Pembuat | Link | Lisensi | Format | Tris/verts | Penilaian |
|---|---|---|---|---|---|---|
| **Stylized Mosque** | ChrisCLP | https://sketchfab.com/3d-models/stylized-mosque-f18722b66d1e459b94e189fb3f41781f | CC-BY | GLB | 35,2k / 20,7k | ✅✅ **PILIHAN UTAMA — Masjid Besar / musholla.** Stylized (berdasar Masjid Muhammad Ali, Kairo), kubah + menara, 3.226 unduhan, 215 likes. Gaya SAMA dengan Stylized Tree penulis yang sama — konsisten dengan pohon hero. Recolor dinding krem + kubah zamrud/emas. 35k tris wajar untuk bangunan hero. |
| **Mosque** | shaysergod | https://sketchfab.com/3d-models/mosque-1ad552241193400992ded686e04f4929 | CC-BY | GLB | 88,6k / 44,3k | ⚠️ Masjid utuh kedua, tapi 88,6k tris dan hanya 69 unduhan. Cadangan kalau Stylized Mosque kurang cocok. |
| **Kholishakande (Moddhopara) Mosque** | Md.Faruk | https://sketchfab.com/3d-models/kholishakande-moddhopara-mosque-a59a181319004f5eaf88662187ea86a7 | CC-BY | GLB | **1,7 JUTA** / 806k | ❌ Terlalu berat (scan/detail mentah). Jangan dipakai. |
| **Sinan Pasha Mosque** | Sadik Šaipi (@IbnSead) | https://sketchfab.com/3d-models/sinan-pasha-mosque-b5b7396d8ea84201a3c782d34476ddf2 | (tidak tercantum di hasil — cek halaman) | GLB | 999,6k / 633,8k | ❌ Terlalu berat + dibuat dari drone/AI (Lumelabs). Jangan dipakai. |
| **Muhamed Bek Abu Al Dahab Mosque** | FayrouzRehan | https://sketchfab.com/3d-models/muhamed-bek-abu-al-dahab-mosque-988ba97db984483aacbe62b010ac417f | (tidak tercantum di hasil — cek halaman) | GLB | tidak tercantum | ⚠️ Masjid bersejarah Kairo, kubah + menara. Hanya cadangan; cek lisensi + berat dulu. |
| **Marrakech minaret tower** | 333DDD | https://sketchfab.com/3d-models/marrakech-minaret-tower-b70c5c9ad1ab4ebfab108e02b5e165be | (tidak tercantum di hasil — cek halaman) | GLB | 198,5k / 99,3k | ❌ Menara hasil rekonstruksi drone, 198k tris. Terlalu berat untuk menara. |
| **Turkish style minaret** | bluegini3d | https://sketchfab.com/3d-models/turkish-style-minaret-5cbcefd27812481991528b658a0a0165 | **Free Standard (BUKAN CC)** | GLB | 1,3k / 661 | ❌ **DITOLAK — lisensi bukan CC0/CC-BY.** Dicatat karena ini satu-satunya menara ringan yang ketemu; jangan dipakai. Menara harus ikut dari model masjid atau dibuat Bima. |
| **Casa Simples** | Syron (@Rafesy) | https://sketchfab.com/3d-models/casa-simples-facc477f8d8e4e18bbeab5ed43596eb2 | CC-BY | GLB | 4,9k / 2,5k | ⚠️ Rumah sederhana 4,9k tris, baru (Okt 2026, 4 unduhan). Bentuk dasar rumah — bisa jadi pondok kecil setelah recolor + ganti atap. Belum terbukti kualitasnya. |
| **Medieval Village MegaKit (300+ potong modular: dinding, atap, lantai, tangga)** | Quaternius | https://quaternius.com (paket Medieval Village MegaKit; juga di Fab — gratis) | **CC0** | FBX, OBJ, glTF | per potong, ringan | ✅ **PILIHAN UTAMA untuk pondok/asrama/tembok.** Kitbash modular: dinding + atap + lantai disusun jadi pondok/asrama/tembok keliling. Gaya medieval-Eropa — atap & jendela harus dirombak/recolor ke gaya pesantren (atap joglo/limasan tidak ada di kit ini). Tetap jauh lebih cepat daripada bangun dari nol. |
| **Ultimate House Interior Pack / Farm Buildings Pack (13 model: lumbung/gudang)** | Quaternius | https://quaternius.com/packs/farmbuildings.html | **CC0** | FBX, OBJ, Blend | tidak tercantum | ⚠️ Farm Buildings berisi lumbung/gudang — bentuknya bisa dipinjam untuk gudang/pondok utilitas. House Interior Pack untuk interior (lihat §3). |
| **Kenney Building Kit** | Kenney | https://kenney.nl/assets (filter: 3D) | **CC0** | GLB, FBX, OBJ | ringan | ❌ Gaya balok — Mas menolak balok. Fallback saja. |
| **adam127 — Wooden gate / Fence / Withe Fence / Brick House Fbx** | adam127 | https://sketchfab.com/adam127/ | **BELUM TERVERIFIKASI — cek lisensi per model di halaman** | GLB | tidak tercantum | ⚠️ Kreator low-poly populer (Wooden gate 270 likes, Withe Fence 410 likes, Fence 156 likes). Gayanya low-poly bersih dan kemungkinan besar CC-BY seperti karya sejenis — TAPI lisensi tidak tercantum di hasil pencarian, jadi **jangan pakai sebelum dicek di halaman model**. Kalau CC-BY, ini kandidat pagar/gerbang kayu terbaik. |
| **Modular palisade and gate** | ice_screen | https://sketchfab.com/3d-models/odular-palisade-and-gate-312521930df04abba81feac5b0461897 | **BELUM TERVERIFIKASI — cek halaman** | GLB | 8,8k / 5,4k | ⚠️ Pagar kayu modular + gerbang, game-ready (Unity), 109 likes. Lisensi tidak tercantum di hasil — cek halaman sebelum pakai. Gaya palisade (benteng) — perlu recolor. |
| **Japanese Village Props — Stylized Low Poly (torii gate, sumur, lonceng)** | Oleksii Soloviov | https://sketchfab.com/3d-models/japanese-village-props-stylized-low-poly-7819570dbc584be2b29f6aa958a1a197 | (tidak tercantum di hasil — cek halaman) | GLB | 18,5k (satu paket) | ⚠️ Ada torii gate — tapi **torii itu gerbang Shinto Jepang, bukan gapura pesantren**. Jangan pakai mentah; paling jauh jadi referensi struktur gerbang. |

**Yang TIDAK ADA (jujur):**
- **Gapura pesantren — TIDAK ADA model gratis yang cocok.** Yang ada hanya torii (Jepang, salah budaya), palisade (benteng), dan gerbang kayu generik. → **Harus dibuat di Blender — Bima** (gapura + papan nama pesantren, satu paket pekerjaan; bentuknya sederhana: 2 pilar + atap lengkung + ornamen, palet krem/zamrud/emas).
- **Rumah/pondok bergaya pesantren (joglo/limasan, atap khas Jawa) — TIDAK ADA.** Yang ada rumah generik Barat + kitbash medieval. → **Kitbash dulu dari Medieval Village MegaKit + recolor (jalan cepat), atau Bima buatkan 1–2 pondok hero bergaya pesantren** kalau Mas menilai kitbash terlalu "Eropa". Rekomendasi: kitbash dulu, tunjukkan ke Mas, baru putuskan.
- **Menara standalone — TIDAK ADA yang CC0/CC-BY dan ringan.** Menara ikut dari Stylized Mosque (pisahkan mesh menaranya kalau perlu menara terpisah) atau dibuat Bima.
- **Tembok keliling — TER-COVER via kitbash** Medieval Village MegaKit (dinding modular) + pagar kayu adam127/ice_screen (setelah cek lisensi).
- **Lead belum terverifikasi:** "Leworahang Traditional House, Indonesia" muncul di sitemap Sketchfab — rumah tradisional Indonesia, tapi link + lisensi + tris tidak berhasil diverifikasi dari pencarian. Kalau ada yang sempat buka, cek — ini satu-satunya lead rumah Indonesia.

**Verdict §2: SEPARUH TER-COVER.** Masjid ✅ (Stylized Mosque). Tembok/pagar ⚠️ (kitbash + cek lisensi). Pondok ⚠️ (kitbash, belum bergaya pesantren). Gapura ❌ (buat di Blender — Bima). Menara standalone ❌ (ambil dari model masjid / buat di Blender).

---

## 3. Perabot interior: rak kitab/lemari, meja-kursi, mimbar, kasur/ranjang susun, karpet/sajadah, lampu gantung, papan tulis

Kategori **paling ter-cover setelah pohon** — hampir semua ada, kecuali sajadah 3D.

| Model | Pembuat | Link | Lisensi | Format | Tris/verts | Penilaian |
|---|---|---|---|---|---|---|
| **Antique wooden bookcase — Game model (buku bisa dilepas/disusun ulang)** | Lorenzo Drago | https://sketchfab.com/3d-models/antique-wooden-bookcase-game-model-75aa9519195647d99cf1e2d4863dbe87 | CC-BY | GLB | 3k / 1,9k | ✅ **PILIHAN UTAMA rak kitab.** Kayu antik, ringan, buku terpisah — isi rak bisa diganti kitab (recolor sampul zamrud/emas). |
| **Bookshelf with Books, Light Wood** | Tigrotto | https://sketchfab.com/3d-models/bookshelf-with-books-light-wood-ed84a5aa815244b58a91d01bd686aa46 | CC-BY | GLB | 7k / 3,5k | ✅ Rak kayu terang + buku, 1.127 unduhan. Alternatif rak kitab (warna kayu terang dekat krem). |
| **Bookshelf — tall wooden** | MozillaHubs | https://sketchfab.com/3d-models/bookshelf-tall-wooden-efe2a35b92c443519fab5a5b515e92ab | CC-BY | GLB | 268 / 136 | ✅ Rak kayu tinggi super ringan (268 tris). Remix dari Pixel-bit. Untuk rak latar yang banyak. |
| **bookshelves** | slavkaslavka | https://sketchfab.com/3d-models/bookshelves-a5f26735572746fb83b4daf50bfbc6b4 | CC-BY | GLB | 972 / 648 | ✅ Rak sederhana 972 tris. Cadangan. |
| **Bookshelf (format .blend/.stl/.obj)** | Nostradamuz | https://sketchfab.com/3d-models/bookshelf-dade79ad4ae449bba7f741e1f739bb39 | CC-BY | .blend, .stl, .obj | 2,2k / 1,1k | ✅ Ada file .blend — paling mudah diedit Bima. |
| **Bookshelf — Doug C (BlendSwap)** | Doug C | https://blendswap.com (cari "Bookshelf" by Doug C) | **CC0** | **.blend** | tidak tercantum | ✅ CC0 + .blend asli. Cadangan rak kitab. Catatan: BlendSwap akun gratis max 5 unduhan/hari, file lama (Blender 2.6x). |
| **Low Poly Classroom Assets (2 kursi, 2 meja, pintu, 2 tempat sampah — satu paket)** | Paolo Mercogliano | https://sketchfab.com/3d-models/low-poly-classroom-assets-3cdd052414544149a1f4edff9d9198c3 | CC-BY | GLB | 151,7k (total paket) | ✅✅ **PILIHAN UTAMA ruang kelas.** Satu paket langsung mengisi kelas: meja + kursi + pintu + tempat sampah. 151,7k tris total paket itu berat — tapi modelnya terpisah, ambil yang perlu saja (meja/kursi satuan jauh lebih ringan). |
| **Low Poly School Desk** | DumApe | https://sketchfab.com/3d-models/low-poly-school-desk-09dcc64a1b2542628defe9d274985a1d | CC-BY | GLB | 256 / 142 | ✅ Meja sekolah 256 tris, 980 unduhan. Pasangan kursinya ada di link deskripsi (skfb.ly/o7DWC). |
| **Lowpoly classroom chair** | tgtom | https://sketchfab.com/3d-models/lowpoly-classroom-chair-645b8ab01e05498e8dbb2a5b5d62fa3b | CC-BY | GLB | 5k / 2,5k | ✅ Kursi kelas kayu + kaki besi, dibuat di Blender. |
| **Desk Chair** | KaitlinKelly | https://sketchfab.com/3d-models/desk-chair-4f0ac4fecf2841648f167bf851b72d2c | CC-BY | GLB | 714 / 371 | ✅ Kursi meja low-poly 714 tris. Cadangan. |
| **PULPIT_PODIUM_MIMBAR** | atsaqib200021 | https://sketchfab.com/3d-models/pulpit-podium-mimbar-a7bb7c6802fa4d5bb3e0251d98ddb529 | **BELUM TERVERIFIKASI — cek halaman** | GLB | 28,7k / 14,4k | ⚠️ **Satu-satunya mimbar yang ketemu.** 28,7k tris. Lisensi tidak tercantum di hasil pencarian — **wajib cek di halaman sebelum pakai**. Kalau CC-BY, langsung pakai (recolor kayu jati + aksen emas). Kalau bukan CC, mimbar harus dibuat Bima. |
| **Mosque pulpit (minbar) — Maritime Asia Heritage Survey** | Maritime Asia Heritage Survey | https://sketchfab.com/models/82f907d17fd346f0a75d9ec393650adc/embed | **CC BY-NC-ND (dataset MAHS) — TIDAK MEMENUHI mandat** | GLB | tidak tercantum | ❌ **DITOLAK — NC + ND.** Dicatat supaya tidak ada yang salah ambil. |
| **Low Poly Bunk Bed #2** | JustBlender | https://sketchfab.com/3d-models/low-poly-bunk-bed-2-7e5f290cf4474aba93979b6c7244f142 | CC-BY | GLB | 462 / 384 | ✅✅ **PILIHAN UTAMA ranjang susun.** 462 tris, ukuran 1,99 × 1,03 × 1,59 m, 654 unduhan. Recolor rangka kayu jati + kasur krem. Asrama butuh 10 kasur = 10× instansi model ini (murah). |
| **Bunk Bed** | neverfollow81 | https://sketchfab.com/3d-models/bunk-bed-3ddab7a93381496eba3c36677e777912 | CC-BY | GLB | 1,3k / 803 | ✅ Ranjang susun sederhana, dibuat untuk game (proyek "On Your Own"). Alternatif. |
| **Military Bunk Bed** | KurtSteiner | https://sketchfab.com/3d-models/military-bunk-bed-03fa59009cb344ee9241128bad9bba13 | CC-BY | GLB | 708 / 504 | ✅ Ranjang susun gaya militer 708 tris, 446 unduhan. Cocok untuk asrama (kesan rapi/seragam). |
| **BB Bunk Bed** | BPB (@zjv) | https://sketchfab.com/3d-models/bb-bunk-bed-04b7eaa9e214436ba47c0ba19b1c3fac | CC-BY | GLB | 10,7k / 5,8k | ⚠️ Ranjang kayu + tangga + kuningan, bagus tapi 10,7k tris. Untuk asrama hero saja. |
| **Triple ceiling hanging lamp** | gorzi | https://sketchfab.com/3d-models/triple-ceiling-hanging-lamp-7d73fd18c28a431ea896558411bce07d | CC-BY | GLB | 4k / 2k | ✅ **PILIHAN UTAMA lampu gantung.** 9.733 unduhan, 103 likes — paling terbukti. Tiga lampu gantung sekaligus. |
| **Hanging Lamp** | nyanpie1 | https://sketchfab.com/3d-models/hanging-lamp-957b782080ae48cb800abcc6e01bf941 | CC-BY | GLB | 1,5k / 939 | ✅ Lampu gantung 1,5k tris (rekreasi lampu kebun raya). Cadangan satuan. |
| **Low Poly Office (termasuk hanging lamp + perabot kantor)** | Paolo Mercogliano | https://sketchfab.com/3d-models/low-poly-office-cc81191e0e90409c94df23ad4045f175 | CC-BY | GLB | 6,4k / 3,2k | ✅ Satu paket kantor low-poly, ada lampu gantungnya. Penulis sama dengan Classroom Assets. |
| **School whiteboard 90cm × 120cm** | Pedro-Martins | https://sketchfab.com:443/3d-models/school-whiteboard-90cm-x-120cm-280856e261974ed093d9d15892ef045e | CC-BY | GLB | 7,7k / 3,9k | ✅ Whiteboard ukuran sekolah asli (90×120 cm), 216 unduhan. |
| **Chalkboard** | Luis Vidal | https://sketchfab.com/3d-models/chalkboard-5359e67814bf447aa73fc0665ce6c5dc | CC-BY | GLB | 128 / 84 | ✅✅ **PILIHAN UTAMA papan tulis.** 128 tris, game-ready, tekstur PBR 2K, rak kapur + penghapus, 1.085 unduhan. Pesantren pakai papan hijau — recolor gampang. |
| **Blackboard** | barism09 | https://sketchfab.com/3d-models/blackboard-34e922aab07a47df9f6032a8ac700cfd | CC-BY | GLB | 1,1k / 538 | ✅ Papan tulis 1,1k tris, 2.866 unduhan, 188 likes. Alternatif. |
| **Small chalkboard** | Sousinho | https://sketchfab.com/3d-models/small-chalkboard-dec5d047dbdd4388a931fbf1bd79febd | CC-BY | GLB | 28 / 16 | ✅ Papan tulis kecil A1, 28 tris. Untuk papan pengumuman kecil. |
| **Chalkboard Whiteboard Reversible FREE Low Poly** | Lady Lion Studios | https://sketchfab.com:443/3d-models/chalkboard-whiteboard-reversible-free-low-poly-760799da34734f43bd03457fbde8764b | CC-BY | GLB | 1,6k / 874 | ✅ Papan dua sisi (kapur + whiteboard), Blender 3.0.1. |
| **Ultimate Furniture Pack / Ultimate House Interior Pack** | Quaternius | https://quaternius.com (paket Ultimate Furniture, Ultimate House Interior) | **CC0** | FBX, OBJ, Blend | tidak tercantum | ✅ **PILIHAN UTAMA bulk interior.** Perabot lengkap gaya Quaternius yang konsisten. Cek isi paket sebelum ambil — sebagian model gaya Barat modern, recolor/retexture wajib. |
| **KayKit Furniture Bits (50+ perabot: meja, kursi, kasur, rak)** | Kay Lousberg (KayKit) | https://kaylousberg.itch.io/furniture-bits | **CC0** | OBJ, FBX, glTF (+ repo GitHub addon Godot) | ringan (atlas gradien tunggal) | ✅ **PILIHAN UTAMA bulk interior kedua.** CC0, ada di Godot Asset Library (https://godotengine.org/asset-library/asset/2125), gaya low-poly konsisten satu atlas. Catatan: tier EXTRA (20 aset gaming setup, $3,95) dan SOURCE (.blend, $5,95) berbayar — **jangan beli, tier gratis 50+ model sudah cukup**. Gayanya low-poly sederhana (bukan halus) — cocok untuk perabot latar, bukan hero. |

**Yang TIDAK ADA (jujur):**
- **Sajadah / karpet sholat 3D — TIDAK ADA model CC0/CC-BY yang ketemu.** Yang ada hanya foto produk (Adobe Stock, berbayar) dan karpet generik CGTrader (Royalty Free, bukan CC — ditolak). → **Solusi tanpa model 3D: buat sajadah sebagai bidang datar (plane) + tekstur kain CC0 dari Poly Haven/ambientCG, digambar motif mihrab sederhana di Blender (Kirana — pekerjaan kecil).** Alternatif: karpet masjid sebagai tekstur lantai ruangan sholat. Jangan cari model 3D sajadah lagi — jalurnya tekstur.
- **Lemari pakaian santri (untuk asrama) — tidak dicari khusus, tapi ter-cover** oleh KayKit Furniture Bits + Quaternius Furniture Pack (ada lemari/wardrobe di keduanya).
- **Mimbar — STATUS: BELUM PASTI.** Satu-satunya kandidat (atsaqib200021) lisensinya belum terverifikasi. Kalau ternyata bukan CC-BY → **buat di Blender — Bima** (mimbar kayu sederhana + tangga 3 anak tangga, aksen emas).

**Verdict §3: HAMPIR TER-COVER.** Rak kitab ✅, meja-kursi ✅, ranjang susun ✅, lampu gantung ✅, papan tulis ✅. Sajadah ❌ (solusi tekstur — Kirana). Mimbar ⚠️ (verifikasi lisensi dulu, kalau gagal → Bima).

---

## 4. Props: lampu jalan/taman, bangku, papan nama, tempat sampah, pot bunga, pagar kayu

| Model | Pembuat | Link | Lisensi | Format | Tris/verts | Penilaian |
|---|---|---|---|---|---|---|
| **Lamp post light** | Sousinho | https://sketchfab.com:443/3d-models/lamp-post-light-ff5e3bc99dd146d986cb662813ec988e | CC-BY | GLB | 3,8k | ✅ **PILIHAN UTAMA lampu jalan.** Sederhana, kaca lampu objek terpisah, tekstur PBR 4K. Penulis sama dengan Small chalkboard. |
| **Medellin Street Lamp** | Sebastian ramirez muñoz | https://sketchfab.com/3d-models/medellin-street-lamp-6cfedb57645b42b4a11d6c06411014b6 | CC-BY | GLB | 13,9k / 7,5k | ✅ Lampu jalan 6.202 unduhan, 182 likes — paling terbukti. Agak berat (13,9k). |
| **Modern Chinese Street Lamp** | Cyrus_JS | https://sketchfab.com/3d-models/modern-chinese-street-lamp-ce9d029fe1c14d01b9193b2c31f7c484 | CC-BY | GLB | 1,9k / 996 | ✅ Lampu taman gaya Asia 1,9k tris, 3.573 unduhan, 264 likes. Bentuknya cocok untuk taman pesantren (nuansa Timur). |
| **Street lamp** | woulfric | https://sketchfab.com/3d-models/street-lamp-99ba51e3246e4b82b2dd512f0a4e1808 | CC-BY | GLB | 21,1k / 10,7k | ⚠️ Low-poly Blender, tapi 21,1k tris. Cadangan. |
| **Park Bench Stylized Handpainted [Game Ready]** | Raphael C (@Qurka) | https://sketchfab.com/3d-models/park-bench-stylized-handpainted-game-ready-fc8ccc0807f34b709c0a8f735dd70f03 | CC-BY | GLB | **196** | ✅✅ **PILIHAN UTAMA bangku.** 196 tris, hand-painted stylized, FBX/glTF — gaya paling dekat target. Bangku taman pesantren = ini + recolor kayu jati. |
| **Park bench (Game ready)** | PT34 | https://sketchfab.com/3d-models/park-bench-game-ready-fd4d821a9e5f46cab786d4530133fc30 | CC-BY | GLB | 2k / 992 | ✅ Bangku kayu game-ready, 694 unduhan. Alternatif. |
| **Wooden Bench** | ItsRobin (@Robin-Dwivedi) | https://sketchfab.com/3d-models/d50d52a14683457ab789cf669ba2e21b | CC-BY | GLB | 3k / 1,5k | ✅ Bangku kayu baru (Okt 2026). Cadangan. |
| **Park table** | olliej08 | https://sketchfab.com/3d-models/park-table-d11000116adb4ed782e2bec130b61dce | CC-BY | GLB | 11k / 5,6k | ⚠️ Meja + bangku taman 11k tris, tekstur 4K. Berat — untuk area cangkruk hero saja. |
| **Free Flower Pot — Cartoon Style Plant** | Mrxxx (@sanjaysinghfazilka) | https://sketchfab.com/3d-models/free-flower-pot-cartoon-style-plant-3d-model-2be0a24fecee4e38978391b3f02623ab | CC-BY | GLB | 32,3k / 16,2k | ✅✅ **PILIHAN UTAMA pot bunga.** Gaya kartun (sesuai target!), game-ready, topologi bersih. 32,3k tris agak berat — pakai secukupnya / decimate. |
| **Lowpoly flower pot** | Luiza Moreira | https://sketchfab.com/3d-models/lowpoly-flower-pot-e547b70f8bb549e3ad5cea9a4eed800d | CC-BY | GLB | 336 / 186 | ✅ Pot bunga 336 tris. Untuk pot massal di sepanjang jalan. |
| **Flower pot** | Ryoce | https://sketchfab.com/3d-models/flower-pot-ea1e03b01f8d45039d900e379f1f87d0 | CC-BY | GLB | 2,2k / 1,1k | ✅ Pot bunga low-poly + normal map, 3.560 unduhan, 235 likes. Alternatif teruji. |
| **Bamboo with plant pot** (juga §1) | Snowism | https://sketchfab.com/3d-models/bamboo-with-plant-pot-19c7ca832f4246638cbbd53be9ff6184 | CC-BY | GLB | 9,4k / 4,3k | ✅ Pot + bambu sekaligus. |
| **Tempat sampah — ikut paket Low Poly Classroom Assets (2 bins)** | Paolo Mercogliano | https://sketchfab.com/3d-models/low-poly-classroom-assets-3cdd052414544149a1f4edff9d9198c3 | CC-BY | GLB | bagian dari 151,7k total | ✅ **TER-COVER** — 2 tempat sampah dalam paket kelas. Ambil mesh bin-nya saja. (Catatan: "Simples Garbage Bin" BlendSwap adalah CC-BY-NC-SA — ditolak, jangan pakai itu.) |
| **Pagar kayu — adam127 Fence / Wooden gate / Withe Fence** | adam127 | https://sketchfab.com/adam127/ | **BELUM TERVERIFIKASI** | GLB | tidak tercantum | ⚠️ Lihat §2 — kandidat terbaik, tapi cek lisensi dulu. |
| **Pagar kayu — Modular palisade and gate** | ice_screen | https://sketchfab.com/3d-models/odular-palisade-and-gate-312521930df04abba81feac5b0461897 | **BELUM TERVERIFIKASI** | GLB | 8,8k / 5,4k | ⚠️ Lihat §2 — modular, game-ready. Cek lisensi dulu. |
| **Pagar — Quaternius Medieval Village MegaKit (pagar/dinding modular)** | Quaternius | https://quaternius.com | **CC0** | FBX, OBJ, glTF | ringan | ✅ Fallback pagar yang lisensinya PASTI CC0 — pakai ini kalau adam127/ice_screen ternyata bukan CC. |

**Yang TIDAK ADA (jujur):**
- **Papan nama (signage "Pesantren Verse" / nama gedung) — TIDAK ADA model gratisnya.** Wajar: papan nama itu teks kustom. → **Buat di Blender — Kirana** (pekerjaan kecil: papan kayu jati + teks timbul + cat emas; bisa juga sebagai tekstur di atas bidang — 1 jam kerja).
- **Lampu taman gaya lampion pesantren — tidak ada yang spesifik**, tapi Modern Chinese Street Lamp (§4) + lampu gantung (§3) sudah cukup untuk penerangan taman.

**Verdict §4: HAMPIR TER-COVER.** Lampu jalan ✅, bangku ✅, pot bunga ✅, tempat sampah ✅ (ikut paket kelas). Pagar kayu ⚠️ (kandidat ada, lisensi wajib dicek — fallback CC0 Quaternius tersedia). Papan nama ❌ (buat di Blender — Kirana, kecil).

---

## 5. Terrain/alam: bukit, batu, jalan setapak (atau tekstur jalan)

| Model / sumber | Pembuat | Link | Lisensi | Format | Tris/verts | Penilaian |
|---|---|---|---|---|---|---|
| **70 stylized rocks** | ondrasaur | https://sketchfab.com/3d-models/70-stylized-rocks-bf0051544c9c41f998c154c546b09669 | CC-BY | GLB | 5,6k / 3k (total 70 batu) | ✅✅ **PILIHAN UTAMA batu.** 70 variasi, 12.112 unduhan, 972 likes. Bisa ditumpuk jadi dinding/tebing/bukit kecil. |
| **Low Poly Stylized Rocks** | Erdem Dağdelen | https://sketchfab.com/3d-models/low-poly-stylized-rocks-99544bd16600463fa5a34ecbd98eb980 | CC-BY | GLB | 1,1k / 571 | ✅ Variasi batu stylized, Blender + Substance, 3.978 unduhan, 562 likes. |
| **Stylized Rock** | Jaspreet Singh (@gurjasstudios) | https://sketchfab.com/3d-models/stylized-rock-f0309cd2e4a347c3996cd7d887cd2d4a | CC-BY | GLB | 196 / 100 | ✅ Batu stylized 196 tris, sculpt + retopo dari 1 juta face. Penulis bilang "no credit required" (tetap CC-BY, atribusi sopan saja). |
| **Low Polygon Stylized Rock [FREE]** | Jesus Fernandez Garcia (@jamyzgenius) | https://sketchfab.com/3d-models/low-polygon-stylized-rock-free-c34bba04360e47268c0099b1842f0add | CC-BY | GLB | 188 / 96 | ✅ Batu 188 tris, sculpt + bake. |
| **Stylized Small Low Poly Rocks [FREE]** | Jesus Fernandez Garcia | https://sketchfab.com/3d-models/stylized-small-low-poly-rocks-free-73cb74949e574f51a2f328ffd3628dda | CC-BY | GLB | 300 (60 tris/batu) | ✅ Batu kecil 60 tris/biji, FBX, UV, tekstur 2K PBR. Untuk sebaran batu kecil. |
| **Rock [Free Asset Download]** | scrampunk | https://sketchfab.com/3d-models/rock-free-asset-download-6d2b001a0a374c4c80bb22fa2d82393f | CC-BY | GLB | 1,5k / 801 | ✅ Batu low-poly + tekstur 1024, 1.118 unduhan. |
| **Quaternius Stylized Nature MegaKit (27 batu + tanah)** | Quaternius | https://quaternius.com/packs/stylizednaturemegakit.html | **CC0** | FBX, OBJ, glTF | — | ✅ Batu + ground sudah termasuk di paket §1. |
| **Jalan setapak — TEKSTUR, bukan model: Poly Haven (cobblestone, paving, stone, ground)** | Poly Haven | https://polyhaven.com (cari: cobblestone / paving / ground) | **CC0** | JPG/PNG (1K–8K) + peta normal/roughness/AO | — | ✅✅ **PILIHAN UTAMA jalan.** Tekstur PBR CC0 tanpa akun, API gratis. Jalan = plane + tekstur cobblestone/paving, diwarnai krem. Jauh lebih ringan daripada model jalan 3D. |
| **Jalan setapak — TEKSTUR: ambientCG (2.000+ material, paving/stone/ground)** | ambientCG | https://ambientcg.com | **CC0** | JPG/PNG + peta PBR | — | ✅ Alternatif Poly Haven, sama-sama CC0. |
| **Avramania — Low Poly Medieval Models, 163 CC0 (termasuk paths/jalan, pagar, rumah modular)** | Avramania | https://opengameart.org/node/195910 (juga avramania.itch.io/free-collection) | **CC0** (klaim) | GLB, FBX | — | ⚠️ **File di OpenGameArt saat ini TIDAK TERSEDIA ("File(s) currently unavailable due to potential licensing issues").** Jangan andalkan sampai file-nya kembali. Kalau kembali, ini paket kitbash besar kedua setelah Quaternius. |

**Yang TIDAK ADA (jujur):**
- **Bukit sebagai model 3D standalone — TIDAK ADA yang stylized-cocok.** Batu (ondrasaur 70 variasi) bisa ditumpuk jadi bukit kecil/tebing, tapi bukit besar harus dari terrain. → **Buat di Godot (heightmap/terrain) atau Blender — Kirana** (bukit = mesh sederhana + tekstur rumput CC0; pekerjaan kecil-menengah). Bukan Bima — Bima fokus karakter.
- **Jalan setapak sebagai model 3D — tidak perlu dicari.** Solusi tekstur (Poly Haven/ambientCG) lebih ringan dan lebih fleksibel. ✅ dianggap ter-cover via tekstur.

**Verdict §5: TER-COVER (dengan catatan).** Batu ✅ melimpah. Jalan ✅ via tekstur CC0. Bukit ⚠️ (Godot terrain / Kirana — bukan model unduhan).

---

## 6. Paket bulk — rekomendasi pemakaian (biar gaya konsisten)

Satu-satu model di atas bagus, tapi gaya bisa belang kalau dicampur sembarangan. Prioritas pemakaian:

| Prioritas | Sumber | Isi untuk game | Lisensi | Catatan |
|---|---|---|---|---|
| **1** | **Quaternius — Stylized Nature MegaKit + Medieval Village MegaKit + Fantasy Props MegaKit + Ultimate Furniture Pack + Ultimate House Interior Pack** | Vegetasi, batu, pondok/tembok kitbash, props, interior | **CC0** | Basis dunia. Tier gratis 60–70% per paket. Unduh via itch (gratis, tanpa akun berbayar). Format glTF langsung ke Godot. Satu-satunya sumber yang gaya + skalanya konsisten antar paket. |
| **2** | **KayKit — Furniture Bits (+ Mini Game Kit, City Builder Bits)** | Perabot interior, bangunan kota kecil | **CC0** | Repo GitHub = addon Godot, tinggal drop-in. JANGAN beli tier EXTRA ($3,95) / SOURCE ($5,95) — gratis sudah cukup. |
| **3** | **Sketchfab satuan CC-BY (pilihan utama per tabel)** | Masjid (ChrisCLP), pohon hero, mimbar (?), bangku, lampu, papan tulis, ranjang | CC-BY | Wajib atribusi (§7). Butuh **akun gratis Sketchfab** untuk unduh (bukan bayar). Recolor ke palet. |
| **4** | **Poly Haven + ambientCG** | Tekstur jalan, karpet/sajadah, lantai, dinding, HDRI langit | **CC0** | Tanpa akun. Solusi sajadah + jalan. |
| **5** | **Poly Pizza** | Pencarian cepat model satuan (GLB, ringan) | Per model CC0/CC-BY 3.0 | Mesin pencari — cek lisensi tiap model. Cocok untuk mengisi kekosongan kecil. |
| Fallback | **Kenney (Nature/Furniture/Building kits)** | Apa saja, super ringan | **CC0** | ⚠️ **Gaya balok — hanya kalau Mas mengizinkan kompromi gaya untuk objek latar jauh.** Bukan pilihan utama. |
| Fallback | **BlendSwap** | .blend perabot/arsitektur | CC0/CC-BY (hindari CC-BY-SA) | Akun gratis max 5 unduhan/hari; file lama. |
| ❌ Jangan | **Meshy galeri komunitas** | Apa saja | Klaim CC0 | **Unduh terkunci PRO untuk akun gratis (terverifikasi 17 Nov).** Bukan andalan. |
| ❌ Jangan | **Fab** | Apa saja | Per listing | Sebagian besar berbayar; gratisnya musiman. |
| ❌ Jangan | **CGTrader / TurboSquid "Royalty Free"** | Apa saja | Royalty Free (bukan CC) | Risiko .pck bisa dibongkar (ronde 1–2). |

---

## 7. Daftar atribusi CC-BY (wajib masuk kredit game)

Semua model CC-BY di atas wajib dikreditkan. Daftar ini adalah **draf awal** — finalisasi setelah model benar-benar dipilih & diunduh (hapus yang tidak jadi dipakai, tambah yang ditambahkan):

- "Stylized Mosque" & "Stylized Tree" by **ChrisCLP**, CC BY 4.0
- "Stylized Toon Tree" by **ahingel**, CC BY 4.0
- "Low-Poly Stylized Tree" by **Kostas3D**, CC BY 4.0
- "Date palm tree from Poly by Google" by **IronEqual**, CC BY 4.0
- "Hand Painted Stylized Coconut Palm Tree Island" by **Kigha**, CC BY 4.0
- "Pine Tree Trio" by **Laurie Annis**, CC BY 4.0
- "Pine Tree — Proto Series" by **BitGem**, CC BY 4.0
- "Low Poly Pine Tree" by **kiritochi**, CC BY 4.0
- "Bamboo with plant pot" by **Snowism**, CC BY 4.0
- "Low Poly Stylized Plant Tree" by **Natural_Disbuster**, CC BY 4.0
- "Antique wooden bookcase" by **Lorenzo Drago**, CC BY 4.0
- "Bookshelf with Books, Light Wood" by **Tigrotto**, CC BY 4.0
- "Bookshelf — tall wooden" by **MozillaHubs**, CC BY 4.0
- "bookshelves" by **slavkaslavka**, CC BY 4.0
- "Bookshelf" by **Nostradamuz**, CC BY 4.0
- "Low Poly Classroom Assets" & "Low Poly Office" by **Paolo Mercogliano**, CC BY 4.0
- "Low Poly School Desk" by **DumApe**, CC BY 4.0
- "Lowpoly classroom chair" by **tgtom**, CC BY 4.0
- "Desk Chair" by **KaitlinKelly**, CC BY 4.0
- "Low Poly Bunk Bed #2" by **JustBlender**, CC BY 4.0
- "Bunk Bed" by **neverfollow81**, CC BY 4.0
- "Military Bunk Bed" by **KurtSteiner**, CC BY 4.0
- "BB Bunk Bed" by **BPB**, CC BY 4.0
- "Triple ceiling hanging lamp" by **gorzi**, CC BY 4.0
- "Hanging Lamp" by **nyanpie1**, CC BY 4.0
- "School whiteboard 90cm × 120cm" by **Pedro-Martins**, CC BY 4.0
- "Chalkboard" by **Luis Vidal**, CC BY 4.0
- "Blackboard" by **barism09**, CC BY 4.0
- "Small chalkboard" by **Sousinho**, CC BY 4.0
- "Chalkboard Whiteboard Reversible" by **Lady Lion Studios**, CC BY 4.0
- "Lamp post light" by **Sousinho**, CC BY 4.0
- "Medellin Street Lamp" by **Sebastian ramirez muñoz**, CC BY 4.0
- "Modern Chinese Street Lamp" by **Cyrus_JS**, CC BY 4.0
- "Park Bench Stylized Handpainted" by **Raphael C (Qurka)**, CC BY 4.0
- "Park bench (Game ready)" by **PT34**, CC BY 4.0
- "Wooden Bench" by **ItsRobin**, CC BY 4.0
- "Free Flower Pot — Cartoon Style Plant" by **Mrxxx**, CC BY 4.0
- "Lowpoly flower pot" by **Luiza Moreira**, CC BY 4.0
- "Flower pot" by **Ryoce**, CC BY 4.0
- "70 stylized rocks" by **ondrasaur**, CC BY 4.0
- "Low Poly Stylized Rocks" by **Erdem Dağdelen**, CC BY 4.0
- "Stylized Rock" by **Jaspreet Singh**, CC BY 4.0
- "Low Polygon Stylized Rock" & "Stylized Small Low Poly Rocks" by **Jesus Fernandez Garcia**, CC BY 4.0
- "Rock [Free Asset Download]" by **scrampunk**, CC BY 4.0
- (+ "PULPIT_PODIUM_MIMBAR" by **atsaqib200021**, "Wooden gate/Fence" by **adam127**, "Modular palisade and gate" by **ice_screen** — **HANYA kalau lisensinya terverifikasi CC-BY di halaman**)
- Model CC0 (Quaternius, KayKit, Poly Haven, ambientCG, Kenney) **tidak wajib** atribusi — tapi tetap bagus dicantumkan di kredit sebagai terima kasih.

---

## 8. Ringkasan — mana ter-cover gratis, mana kosong

| Kategori | Status | Keterangan |
|---|---|---|
| 1. Pohon + semak/bunga | ✅ **TER-COVER** | Quaternius Nature MegaKit (CC0) + pohon hero CC-BY + palem kurma. Tidak perlu dibuat. |
| 2a. Masjid/musholla kecil | ✅ **TER-COVER** | Stylized Mosque ChrisCLP (CC-BY) — recolor krem/zamrud/emas. |
| 2b. Rumah/pondok pesantren | ⚠️ **SEPARUH** | Kitbash Medieval Village MegaKit (CC0) + recolor — bisa jalan, tapi belum bergaya pesantren (atap joglo tidak ada). Opsi: Bima buatkan 1–2 pondok hero kalau Mas menolak hasil kitbash. |
| 2c. Gapura/gerbang | ❌ **KOSONG — buat di Blender (Bima)** | Tidak ada gapura pesantren gratis. Torii = salah budaya. |
| 2d. Pagar + tembok | ⚠️ **SEPARUH** | Kitbash Quaternius (CC0, pasti) + adam127/ice_screen (lisensi wajib dicek dulu). |
| 2e. Menara standalone | ❌ **KOSONG** | Ambil menara dari model Stylized Mosque (pisah mesh) atau Bima buatkan. |
| 3a. Rak kitab/lemari | ✅ **TER-COVER** | Lorenzo Drago / Tigrotto / MozillaHubs + Quaternius/KayKit. |
| 3b. Meja-kursi kelas | ✅ **TER-COVER** | Paket Low Poly Classroom Assets + satuan DumApe/tgtom. |
| 3c. Mimbar | ⚠️ **BELUM PASTI** | Satu kandidat (atsaqib200021) — lisensi belum terverifikasi. Kalau gagal → Bima. |
| 3d. Kasur/ranjang susun | ✅ **TER-COVER** | Low Poly Bunk Bed #2 JustBlender (462 tris) — instansi 10× untuk asrama. |
| 3e. Karpet/sajadah | ❌ **KOSONG (model 3D) — solusi tekstur (Kirana)** | Tidak ada model 3D sajadah CC0/CC-BY. Pakai plane + tekstur kain CC0 Poly Haven/ambientCG. |
| 3f. Lampu gantung | ✅ **TER-COVER** | Triple ceiling hanging lamp gorzi + nyanpie1. |
| 3g. Papan tulis | ✅ **TER-COVER** | Chalkboard Luis Vidal (128 tris) + whiteboard Pedro-Martins. |
| 4a. Lampu jalan/taman | ✅ **TER-COVER** | Sousinho / Medellin / Chinese Street Lamp. |
| 4b. Bangku | ✅ **TER-COVER** | Park Bench Qurka (196 tris, hand-painted). |
| 4c. Papan nama | ❌ **KOSONG — buat di Blender (Kirana, kecil)** | Teks kustom, wajar tidak ada modelnya. |
| 4d. Tempat sampah | ✅ **TER-COVER** | Ikut paket Low Poly Classroom Assets (2 bins). |
| 4e. Pot bunga | ✅ **TER-COVER** | Mrxxx cartoon pot + Luiza Moreira + Ryoce. |
| 4f. Pagar kayu | ⚠️ **SEPARUH** | Lihat 2d. |
| 5a. Bukit | ⚠️ **SEPARUH — Godot terrain / Kirana** | Batu bisa ditumpuk; bukit besar dari heightmap Godot. |
| 5b. Batu | ✅ **TER-COVER** | ondrasaur 70 batu + Erdem + Quaternius. |
| 5c. Jalan setapak | ✅ **TER-COVER (via tekstur)** | Tekstur CC0 Poly Haven/ambientCG di atas plane. |

### Hitungan akhir
- **Ter-cover penuh (13):** pohon/semak, masjid, rak kitab, meja-kursi, ranjang susun, lampu gantung, papan tulis, lampu jalan, bangku, tempat sampah, pot bunga, batu, jalan (tekstur).
- **Separuh (5):** pondok pesantren, pagar/tembok, mimbar (lisensi), bukit, + menara (solusi: pisah mesh masjid).
- **Kosong, harus dibuat di Blender (3):** **gapura (Bima)**, **papan nama (Kirana, kecil)**, **sajadah 3D (ganti solusi tekstur — Kirana, kecil)**.
- **Pekerjaan Blender yang tersisa kecil** dibanding membangun semua dari nol: gapura adalah satu-satunya item besar; sisanya kitbash + recolor + tekstur.

### Langkah berikut yang disarankan
1. **Mas ACC dulu** daftar pilihan utama (§6) — terutama: (a) Stylized Mosque sebagai Masjid Besar, (b) kitbash Quaternius untuk pondok/tembok, (c) gapura dibuat Bima.
2. **Buat akun gratis Sketchfab** (sudah disetujui Mas untuk Asian Boy — akun yang sama bisa dipakai untuk semua model CC-BY di atas; tanpa bayar).
3. **Unduh paket Quaternius + KayKit dulu** (CC0, tanpa akun berbayar), lalu model Sketchfab pilihan utama.
4. **Verifikasi 3 lisensi yang belum pasti** sebelum dipakai: mimbar atsaqib200021, pagar adam127, pagar ice_screen — buka halaman modelnya, cek label lisensi.
5. **Recolor massal ke palet** (krem/zamrud/emas/jati) sebelum masuk Godot — ini pekerjaan Kirana/Bima, bukan cari model baru.
6. **Jangan sentuh Meshy komunitas / Fab / CGTrader** untuk aset ini — jalurnya sudah terbukti buntu atau berisiko.

---

## File yang diserahkan

- Laporan ini: `desain-arsitektur/RISET-ASET-GRATIS-ZAHRA.md`
- **Tidak ada file model yang diunduh, tidak ada akun yang dibuat, tidak ada pembayaran.**
- Referensi gaya yang dibaca: `blender-santri/riset-model-dasar/ASIANBOY-STUDY.md`, `blender-santri/riset-model-dasar/RISET-MODEL-DASAR.md` (ronde 1–2).
