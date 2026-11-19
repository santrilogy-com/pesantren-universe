# Riset Instagram: Akun-Akun Dunia Virtual — untuk Ditiru Pesantren Universe

**Tanggal riset:** 16 November 2026 (~08:26–08:35 WIB)
**Peneliti:** Zahra
**Tujuan:** menemukan akun Instagram tentang dunia virtual yang sudah jalan, lalu meniru model karakter, bangunan, dan formatnya untuk Pesantren Universe (game Godot 3D low-poly, karakter dari primitif Godot, bangunan tumbuh mengikuti jumlah santri).

**Yang TIDAK diteliti ulang:** @ponpes_netizen dan @kampungkomen — sudah jadi referensi Mas sejak awal.

---

## Ringkasan eksekutif

Ada **satu genre yang sedang meledak di Instagram sejak Oktober–November 2026**: seri harian "dunia yang dibangun netizen". Polanya selalu sama: mulai dari NOL (satu rumah/satu orang), 1 follow = 1 warga/rumah, komen terbanyak menentukan apa yang dibangun besok, dan tiap episode diakhiri statistik + ajakan follow. Akun-akunnya tumbuh ribuan follower dalam hitungan hari sampai minggu — @myworld.skill (Infinite Wood) 0 → 23 ribu dalam ~2 minggu, @desa_netizen 0 → 12 ribu dalam ~2 minggu, @sawitopia 0 → 1.100 dalam 3 hari.

**Temuan terpenting untuk Pesantren Universe:** genre ini membuktikan format "Hari ke-X + vote komen" yang sudah direncanakan Mas memang format yang sedang viral. Yang paling layak ditiru bukan teknologinya (mereka pakai Blender / render kode / AI), melainkan **mekanikanya**: tokoh bernama dari follower, statistik akhir episode, ancaman/event berjangka (countdown), dan monetisasi lewat "bangunan custom berbayar". Semuanya bisa dibuat dari primitif Godot tanpa Blender.

---

## Tabel akun

| # | Akun | Follower* | Tema dunia | Jenis konten | Status |
|---|------|-----------|-----------|--------------|--------|
| 1 | [@myworld.skill](https://www.instagram.com/myworld.skill) — Infinite Wood | 23.013 | Desa fantasi di hutan, 100 hari menuju Raja Naga | Reels harian "Day X", top-down | ⭐ Model utama |
| 2 | [@ollie.s_realm](https://www.instagram.com/ollie.s_realm) — Ollie's Realm | 13.786 | Desa fantasi low-poly, tumbuh per follower | Reels harian "Day X", isometrik | ⭐ Model utama |
| 3 | [@desa_netizen](https://www.instagram.com/desa_netizen) — Desa Netizen | 12.137 | Desa Indonesia, Kades Caqii | Reels harian "Day X jadi Kades" | ⭐ Model utama (lokal) |
| 4 | [@sawitopia](https://www.instagram.com/sawitopia) — Sawitopia | 1.157 | Pulau sawit, Pak Wit bangun peradaban dari nol | Reels "Hari X" + kartu statistik | Model lokal, baru |
| 5 | [@pinang_animation](https://www.instagram.com/pinang_animation) — Kampung Masyarakat IG | 7 | Kampung dari nol, Pak Noak | Reels "Day X" | Contoh tahap awal |
| 6 | [@minecraftbuilddecoration](https://www.instagram.com/minecraftbuilddecoration) | 108.943 | Kurasi bangunan Minecraft terbaik | Foto/carousel bangunan | Referensi desain bangunan |
| 7 | [@minecraft.construct.tips](https://www.instagram.com/minecraft.construct.tips) | 9.301 | Bangunan + desain Minecraft | Foto harian | Referensi desain bangunan |
| 8 | [@robloxavatar.id](https://www.instagram.com/robloxavatar.id) | 8.229 | Outfit avatar Roblox harian (OOTD) | Foto/carousel 4 gaya | Referensi outfit/karakter |
| 9 | [@lowpolystoriess](https://www.instagram.com/lowpolystoriess) — Low Poly Stories | 36.481 | Animasi low-poly (kucing, gaya PS1) | Reels cerita pendek | Referensi gaya visual |
| 10 | [@vrcgallery](https://www.instagram.com/vrcgallery) | 1.907 | Showcase avatar & world VRChat | Foto kurasi | Referensi showcase |
| — | [@officialvrchat](https://www.instagram.com/officialvrchat) | 85.828 | Platform VRChat (resmi) | Foto/video dunia & avatar | Pembanding (sulit ditiru) |
| — | [@lowpolylands](https://www.instagram.com/lowpolylands) | 551 | Eksperimen low-poly 3D | Reels pendek | Pendukung |

\* Jumlah follower terverifikasi lewat Instagram CLI pada 16 Nov 2026 ~08:26–08:30 WIB. Angka like/komen di bawah juga dari CLI (postingan terbaru). Detail visual (bentuk karakter/bangunan) disimpulkan dari caption + ringkasan pencarian — **saya tidak memutar video Reels-nya secara penuh**, jadi deskripsi visual adalah interpretasi, bukan pengamatan frame-per-frame.

---

## 1. @myworld.skill — Infinite Wood ⭐ MODEL UTAMA

- **Link:** https://www.instagram.com/myworld.skill — situs: https://infinitewood.vercel.app
- **Follower:** 23.013 (18 postingan). Tumbuh dari 0 → 17 ribu dalam 3 hari pertama (Day 1: 16 ribu like / 1,2 ribu komen; Day 2: 16 ribu like / 3 ribu komen), lalu stabil di 23 ribu pada Day 17.
- **Tema dunia:** desa fantasi di hutan ("Forest of Infinite Wood"). Satu kabin di hari pertama. Ada hitung mundur 100 hari menuju Raja Naga (Dragon King). Ada game gratis di situsnya + RPG spin-off @infwood_night_watch + masterclass berbayar di Gumroad.

### Model karakter
- Kamera **top-down** (dilihat dari atas, seperti city-builder). Karakternya kecil-kecil: narator satu figur kecil, lalu kerumunan warga sebagai titik/figur mungil. Wajah nyaris tidak terlihat — identitas karakter datang dari **nama + peran**, bukan dari wajah.
- Peran yang diminta komen: ksatria, penyihir, pandai besi, koki, pemanah, penjinak binatang, nekromanser. Komen terbanyak dijadikan tokoh (mis. Henry jadi ksatria, Colin & Tobias jadi bartender, Bence jadi koki, Teddy Jr. pegang pandai besi).

### Bangunan
- Rumah kayu kecil berderet melingkar, lalu **dinding batu melingkar** (2 lapis), menara, katedral, arena, aula besar, bar, sekolah sihir (menara + kubah kaca + jembatan), perpustakaan. Semua bangunan sederhana: balok + atap segitiga + menara silinder.
- Zonasi jelas: pemukiman melingkar di tengah, hutan di luar dinding, gerbang + ballista di tiap gerbang.

### Cara dunia berkembang
- Aturan keras yang diulang tiap episode: **1 follower = 1 rumah. Komen paling banyak like yang dibangun.** Setiap episode: rekap semalam → bangun hasil vote kemarin → krisis/kejutan (goblin menyerang, 595 rumah hangus, 214 warga gugur) → statistik akhir (jumlah warga, rumah, sisa hari) → tanya "besok bangun apa?".
- Ada **ancaman berjangka**: Raja Naga datang hari ke-100. Ini yang bikin penonton kembali tiap hari — bukan sekadar bangunan, ada cerita yang memanjat.

### Format konten
- Reels harian "Day X", durasi ±60–90 detik, narasi suara AI + teks di layar. Caption selalu memuat: judul episode (mis. "DAY 17 · THE CHOSEN ONE"), isi komen teratas yang dimenangkan (dengan jumlah like-nya), "Every follower = 1 house. 100 new houses today."
- Interaksi: Day 12: 972 like / 216 komen; Day 13: 730 like / 190 komen; Day 16: 492 like / 134 komen. Like menurun setelah ledakan awal, tapi **komen tetap 100–200 per episode** — komen adalah mata uangnya, bukan like.
- Komen didominasi roleplay: "Day X of asking" minta jadi peran tertentu. Kreator membalas dengan selektif, mengukuhkan peran itu di episode berikut.

### Yang bisa ditiru Pesantren Universe
- **Aturan "1 santri = 1 rumah/kamar" + "komen teratas dibangun"** — sudah sejalan dengan rencana Mas; tinggal ditegaskan di caption tiap episode.
- **Hitung mundur berjangka**: ganti Raja Naga dengan event pesantren — mis. "100 hari menuju Khataman Akbar / Maulid Akbar" — supaya ada alasan penonton kembali besok.
- **Tokoh dari komen**: santri yang komennya menang jadi tokoh episode (diberi peran: musyrif, ketua asrama, penjaga perpustakaan) + namanya disebut di video.
- **Statistik akhir episode**: warga, rumah, poin — persis seperti yang sudah direncanakan untuk Kartu Santri, tinggal divisualkan di akhir Reels.
- **Website "find your home"**: situs Infinite Wood membiarkan follower mencari rumahnya — Pesantren Universe sudah punya app + game; tinggal tambahkan "cari Kartu Santri-mu" di bio.
- **Dibuat dengan kode (Claude)**: dunia sebagai data, kamera, kerumunan, cahaya — pembuktian bahwa dunia virtual bisa dibangun dengan kode, bukan cuma Blender. Sejalan dengan Godot.

---

## 2. @ollie.s_realm — Ollie's Realm / Ollie's Farm ⭐ MODEL UTAMA

- **Link:** https://www.instagram.com/ollie.s_realm
- **Follower:** 13.786 (247 postingan). Seri sudah berjalan **±240 hari** (Day 240 saat dicek) — akun paling awet di genre ini. Day 37: 120 like / 27 komen; Day 235: 2.549 like / 85 komen; Day 236: 939 like / 81 komen.
- **Tema dunia:** desa fantasi low-poly yang hangat dan cozy. Dibangun harian di **Blender** oleh satu orang (paruh waktu, kerja kantoran). "Human-crafted by @floatingisles". Tokoh utama Ollie + warga bernama (Sophia, Ali, Luis, Peyton).

### Model karakter
- **Figur putih abstrak** — warga digambarkan sebagai figur low-poly sederhana berwarna putih polos, tanpa wajah detail. Identitasnya dari nama + bangunan yang mereka bangun (Ali membangun masjid, Sophia membangun taman, Luis membuka kedai teh di gedung tertinggi).
- "Meet the OGs": 14 pendiri pertama (3 minggu pertama) mendapat **skin unik** — pembeda visual permanen sebagai penghargaan.
- Gaya visual: hangat, cahaya lembut, warna-warni, low-poly konsisten. Kamera isometrik/aerial + close-up adegan.

### Bangunan
- Rumah-rumah kecil beratap (jendela menyala hangat), alun-alun + api unggun di tengah, taman, **masjid** (dibangun Ali — warga memilih tempat ibadahnya sendiri), sungai, taman, menara penyihir, pelabuhan zeppelin, restoran Italia, kios cokelat panas, bar, kasino. Desa berkembang ke biome baru: koloni musim dingin → Autumn Island → Crimson Woods.
- Skala: rumah mungil berderet; bangunan publik sedikit lebih besar dan diberi ciri khas (menara, kubah, bendera).

### Cara dunia berkembang
- "FOLLOW today = a HOUSE tomorrow!" — formula caption di hampir semua episode. 1 follower = 1 rumah. Komen menentukan bangunan berikutnya; kreator juga memakai **poll mingguan** (sampai 16 opsi) untuk hal yang menguntungkan desa secara keseluruhan.
- Ada musim dan biome: desa pindah/berkembang ke wilayah baru saat lahan habis ("we still have land!").

### Format konten
- Reels harian "Day X" ±60 detik, narasi suara laki-laki yang tenang + teks putih di layar. Caption pendek: hook + "Day 240🏡".
- Selain Reels harian: **carousel** ("Tag the one you'd spend a lifetime on Ollie's Farm with!") dan **Highlight RULES** (aturan main + cara dukung).
- Monetisasi lewat **Ko-fi** dengan tier yang sangat bisa ditiru: (1) custom suit, (2) custom house, (3) suit + house, (4) "ANYTHING YOU WANT" — bangunan besar (kuil, pelabuhan, mansion) didedikasikan untuk pendukung, (5) SOLID GOLD — skin emas + mansion emas. Kreator mengerjakan komisi dalam 3 hari. Semua visual dibuat tangan, tanpa AI kecuali voiceover.

### Yang bisa ditiru Pesantren Universe
- **Formula caption "FOLLOW today = a HOUSE tomorrow"** → "Follow = jadi santri. 1 santri = 1 kamar di asrama" (atau 1 rumah di kampung santri).
- **Skin unik untuk pendiri awal** — santri pertama (mis. 20 pendaftar pertama) dapat outfit/skin eksklusif permanen di game. Ini persis sejalan dengan sistem Ganti Baju + variasi karakter ronde 11.
- **Poll mingguan 16 opsi** untuk keputusan besar (bangunan berikutnya) — melengkapi vote komen harian.
- **Highlight RULES** di profil @pesantren.verse: aturan main (follow = santri, komen = vote, ambang bangunan 25/50/100/200).
- **Monetisasi Ko-fi → Lynk.id**: tier "rumah custom / skin custom / bangunan didedikasikan untukmu" — sudah sejalan dengan produk Lynk.id Mas; tinggal dibungkus sebagai dukungan Pesantren Universe.
- **Karakter figur putih abstrak**: bukti bahwa karakter TIDAK butuh wajah detail untuk dicintai penonton — primitif Godot (kepala bulat + koko + sarung) sudah lebih dari cukup. Jangan kejar realistis.
- **Biome/musim**: pesantren bisa punya "musim" (mis. musim hujan, Ramadhan) yang mengubah suasana dunia — murah dibuat (ganti warna langit + hujan partikel).

---

## 3. @desa_netizen — Desa Netizen ⭐ MODEL UTAMA (LOKAL)

- **Link:** https://www.instagram.com/desa_netizen
- **Follower:** 12.137 (16 postingan). **Day 1 meledak: 26 ribu like / 1,2 ribu komen.** Day 6: 610 like / 101 komen; Day 7: 1.568 like / 86 komen; Day 8: 273 like / 33 komen; Day 11: 154 like / 34 komen.
- **Tema dunia:** desa Indonesia yang diatur netizen. Kepala desa: **Caqii** (seragam coklat PNS + peci hitam). Ada Kantor Desa, papan jumlah penduduk, RT 1 & RT 2, pasar.

### Model karakter
- **Caqii**: karakter 3D low-poly, seragam coklat pegawai desa + peci hitam — satu tokoh sentral yang memandu tiap episode. Warga lain: Bu Amanda (RT 1), Pak Addin, Pak Ojek — tokoh bernama dari komen, dengan peran jabatan desa.
- Humor datang dari situasi: Kades dilantik tapi tidak digaji, penduduk cuma 1 orang (dirinya sendiri), menanyai ayam mau jadi warga atau tidak.

### Bangunan
- Kantor Desa, papan penduduk, jalan, sungai + jembatan, gunung, sirkuit balap, **Pasar Netizen** (lapak-lapak usaha nyata!). Lapak dibuka oleh akun usaha sungguhan yang disebut namanya (@aproncustom.id, @kedai_makcik_madiun, @pempekpalembangaxcelio, @dennymotor1 servis motor).
- Arsitektur desa Indonesia: balai desa, rumah kayu, warung, pasar — semuanya bentuk sederhana.

### Cara dunia berkembang
- Aturan: 1 follow = 1 KTP desa; **komen paling banyak like menentukan yang dibangun besok**. Jumlah warga ditampilkan di papan (10.990 → 11.699 dalam 2 hari).
- Ada **pemilihan RT** (Bu Amanda menang 276 like → Ketua RT 01), ada lomba antar-RT (balapan, sirkuit). Struktur organisasi desa tumbuh bersama jumlah warga — persis seperti rencana struktur Pesantren Universe (musyrif, asrama).
- Monetisasi: **lapak pasar disponsori usaha nyata** — lapak ke-4 (bengkel motor) dibuka oleh akun usaha yang disebut. Ini monetisasi tanpa jualan produk sendiri.

### Format konten
- Reels harian "Day X jadi Kepala Desa Netizen" + episode sampingan ("EPS 1" pasar). Narasi + teks layar. Caption: rekap kemarin ("Juara balapan kemarin: RT 1! Cuma menang 1 komen") + yang dibangun hari ini + ajakan komen.
- Interaksi: komen didominasi usulan bangunan (masjid, warung, sekolah, pasar, rumah sakit, "kopdes") + roleplay ("sudah follow", "mau jadi RT/guru/polisi").

### Yang bisa ditiru Pesantren Universe
- **Tokoh sentral yang memandu**: Kyai (Ust. Aqsal Murad) sebagai "Pak Kades"-nya pesantren — narator tiap episode, persis seperti Caqii. Ini sudah ada di game (ronde 15–16); tinggal jadikan dia pembawa acara video Hari ke-X.
- **Pemilihan jabatan dari like komen**: Ketua Asrama / Musyrif dipilih dari komen terbanyak — mekanik yang sama dengan pemilihan RT. Sangat cocok dengan struktur organisasi (kompleks asrama) yang sudah diriset Zahra.
  - > **Koreksi 16 Nov 2026:** Mas menghapus sistem 21 regu — diganti 1 kompleks asrama (Asrama A, B, C…). Mekanik pemilihan jabatan dari like komen tetap berlaku, tapi jabatannya **Ketua Asrama** (bukan Ketua Regu).
- **Lapak pasar disponsori**: "Lapak Santri" — usaha nyata (warung, percetakan, dll.) bisa "buka lapak" di Pesantren Universe dan disebut namanya. Monetisasi yang tidak terasa jualan.
- **Papan jumlah warga di dalam dunia**: papan "Jumlah Santri: X" di dalam game (sudah ada papan ambang 25/50/100/200) + ditampilkan di video tiap episode.
- **Humor birokrasi desa**: gaya "Kades tidak digaji, penduduk cuma saya" bisa diadaptasi ringan — mis. Kyai menghitung santri, ternyata baru 1 (dirinya sendiri) di Hari ke-1. Ini nada yang sama dengan draf Hari ke-1 ("Pesantren ini dimulai dari nol. Benar-benar nol.").

---

## 4. @sawitopia — Sawitopia (lokal, baru)

- **Link:** https://www.instagram.com/sawitopia
- **Follower:** 1.157 (4 postingan). Hari ke-1: **4.455 like / 193 komen** (meledak untuk akun 0 follower). Hari ke-2: 170 like / 49 komen; Hari ke-3: 70 like / 38 komen.
- **Tema dunia:** pulau sawit. Tokoh: **Pak Wit** (baju oranye + topi caping), warga pertama yang "nggak punya kapak, nggak punya tetangga, cuma punya kamu". Membangun peradaban dari nol.

### Model karakter
- Kartun 3D cerah, Pak Wit sebagai satu tokoh sentral (baju oranye + caping — siluet langsung dikenali). Warga lain belum banyak terlihat; malam hari warga tidur dengan ikon "Zzz" di atas kepala — detail kecil yang lucu dan murah dibuat.

### Bangunan
- Pondok kayu kecil berderet dalam blok (Blok A, B, C), rumah rahasia Pak Wit di antara pohon sawit (papan "POHON = RUMAH DILARANG TEBANG!"), KOPDES (koperasi desa, dibangun dari komen), kebun sawit yang meluas, angka "sawit tumbang" yang dihitung.

### Cara dunia berkembang
- Statistik di tiap episode: "1.452 Warga, 176 Pondok, 1 Rumah Rahasia" (Hari 3); "1.000 warga, 379 sawit tumbang, 126 rumah berdiri… tapi 496 warga masih tidur di luar" (Hari 2). Ada **KWS (Kartu Warga Sawitopia)** — penonton diminta cek KWS-nya di Story.
- Komen menentukan bangunan (kopdes dari komen "buat kopdes").

### Format konten
- Reels "Hari X" + kartu statistik di akhir. Caption pendek + hashtag (#Sawitopia #PakWit #MembangunPeradaban).

### Yang bisa ditiru Pesantren Universe
- **Kartu Warga (KWS) di Story** — persis Kartu Santri Pesantren Universe; tinggal rutinkan: tiap episode baru, Story menampilkan kartu santri baru.
- **Statistik akhir yang spesifik dan lucu**: "496 warga masih tidur di luar" — Pesantren Universe bisa pakai nada sama: "X santri, Y kamar terisi, Z santri masih ngaji di serambi karena kelas belum dibangun".
- **Satu tokoh sentral yang "tidak punya apa-apa"**: Pak Wit tanpa kapak = Kyai tanpa santri di Hari ke-1. Narasi "dimulai dari nol banget" yang sama.
- **Blok perumahan (Blok A/B/C)** — asrama bisa dibagi blok yang sama, gampang divisualkan di peta game.

---

## 5. @pinang_animation — Kampung Masyarakat Instagram (contoh tahap awal)

- **Link:** https://www.instagram.com/pinang_animation
- **Follower:** 7 (4 postingan). Baru mulai (Day 1–3).
- **Tema dunia:** kampung dari tanah kosong. Tokoh: **Pak Noak** (topi merah + baju biru gelap "The LEGEND of Djogja"), karakter blocky.
- Aturan: tiap like = dukungan pembangunan, tiap komen = saran, tiap follow = partisipasi. Day 3: tiga komen dijawab sekaligus (tambah jalan → alat berat meratakan jalan; tambah penduduk → rumah baru; tambah peternakan → kandang SAPI/KAMBING/BEBEK/AYAM). Diakhiri peta dari atas (ISTANA, RUMAH BARU, PAPAN NAMA, PETERNAKAN) + "Sampai jumpa di Day 4!"
- **Yang bisa ditiru:** format "3 komen dijawab dalam 1 episode" (efisien saat komen sudah banyak); **peta dari atas di akhir episode** (Pesantren Universe sudah punya peta GTA di game — tampilkan di video); karakter blocky Pak Noak sebagai bukti gaya blocky pun bisa jalan, tapi Pesantren Universe sudah lebih halus — jangan mundur ke blocky.

---

## 6. @minecraftbuilddecoration — referensi desain bangunan

- **Link:** https://www.instagram.com/minecraftbuilddecoration
- **Follower:** 108.943 (158 postingan). Akun kurasi terbesar di niche ini.
- **Isi:** foto/carousel bangunan Minecraft: Taipei 101, peternakan, "Minecraft vs Reality" (bangunan game vs aslinya), dimensi baru. Like 1.600–15.600 per postingan.
- **Yang bisa ditiru:** bukan dunianya (Minecraft voxel kasar), melainkan **referensi bentuk bangunan**: rumah beratap limas + jendela kuning menyala + cerobong, menara, jembatan, pasar beratap. Semua bentuk ini = kotak + prisma segitiga + silinder di Godot. Format "bangunan game vs aslinya" bisa diadaptasi: "Surau Pesantren Universe vs surau asli" (foto referensi vs tangkapan game).
- **Catatan:** ini akun kurasi (repost + kredit), bukan pembangun dunia. Jangan tiru model akunnya, hanya pakai sebagai bank ide bangunan.

---

## 7. @minecraft.construct.tips — referensi desain bangunan

- **Link:** https://www.instagram.com/minecraft.construct.tips
- **Follower:** 9.301 (92 postingan). "Builds and designs", posting harian.
- **Yang bisa ditiru:** bank ide bangunan harian + format "tips membangun" (mis. Reels singkat "3 trik bikin surau terlihat megah dari primitif"). Bukan model dunia.

---

## 8. @robloxavatar.id — referensi outfit / karakter

- **Link:** https://www.instagram.com/robloxavatar.id
- **Follower:** 8.229 (187 postingan). "Daily Inspo Roblox OOTD".
- **Isi:** carousel 4 gaya outfit avatar Roblox ("Four schoolgirl looks, four different aesthetics", "Which number is your favorite?"), like 70–990, komen hampir nol — kontennya dinikmati sebagai katalog, bukan diskusi.
- **Model karakter Roblox:** kepala + badan blocky, identitas dari **lapisan pakaian + aksesori** (topi, kacamata, tas, warna). Outfit diganti tiap hari sebagai konten tersendiri.
- **Yang bisa ditiru:** **outfit sebagai konten** — Pesantren Universe sudah punya panel Ganti Baju (koko 4 warna, songkok, sarung batik 4 warna, kulit, kacamata). Buat carousel/Reels "Outfit Santri Hari Ini" (4 kombinasi, penonton pilih nomor favorit). Ini konten murah (tangkapan layar game) yang menghidupkan sistem outfit yang sudah dibangun. Jangan tiru gaya blocky Roblox — primitif bulat Pesantren Universe sudah lebih bagus.

---

## 9. @lowpolystoriess — Low Poly Stories (referensi gaya visual)

- **Link:** https://www.instagram.com/lowpolystoriess
- **Follower:** 36.481 (39 postingan). Akun kreator India, ada YouTube + merchandise.
- **Isi:** animasi low-poly pendek bergaya PS1 — kebanyakan tentang kucing ("Why Did Ancient Egyptians Worship Cats?" 14.572 like / 70 komen). Bukan dunia virtual, bukan seri pembangunan.
- **Yang bisa ditiru:** hanya prinsip visualnya — bentuk sederhana + mata besar + warna hangat = karakter yang dicintai. Bukti bahwa low-poly "murah" bisa viral kalau karakternya kuat. Jangan tiru temanya (kucing/PS1) atau formatnya (cerita pendek lepas, bukan dunia yang tumbuh).

---

## 10. @vrcgallery — VRChat Avatar & World Showcase (referensi showcase)

- **Link:** https://www.instagram.com/vrcgallery
- **Follower:** 1.907 (18 postingan). "Only the best looking models and places that VRChat has to offer."
- **Isi:** foto kurasi avatar + world VRChat (anime, apartemen musim gugur, dll.), like 79–270. Kecil dan jarang posting.
- **Yang bisa ditiru:** format "showcase mingguan": satu postingan foto menampilkan avatar/world terbaik minggu itu + kredit kreatornya. Untuk Pesantren Universe: "Santri & Bangunan Terbaik Minggu Ini" (tangkapan layar game + nama santri). Jangan tiru avatarnya — avatar VRChat anime-realistis butuh model impor + rig; bukan primitif Godot.

---

## Pembanding: @officialvrchat (jangan ditiru mentah-mentah)

- **Link:** https://www.instagram.com/officialvrchat — 85.828 follower, 306 postingan. Akun resmi platform.
- Avatarnya anime/realistis 3D, world-nya dibuat komunitas dengan Unity + model impor. **Tidak bisa ditiru dengan primitif Godot** tanpa mengubah total cara kerja tim. Yang bisa diambil hanya idenya: dunia + avatar adalah dua hal yang dipamerkan terpisah (ada showcase avatar, ada showcase world).

---

## Pola yang berulang di semua akun dunia virtual

1. **Mulai dari NOL, dan NOL itu diceritakan.** Satu orang, satu rumah, satu kabin. Penonton datang karena ingin melihat nol menjadi sesuatu.
2. **1 follow = 1 warga/rumah.** Follow bukan angka — follow adalah penduduk yang kasatmata di dunia.
3. **Komen = kekuasaan.** Komen paling banyak like dibangun; komen yang menang disebut namanya. Ini mesin interaksi yang membuat orang kembali tiap hari.
4. **Statistik di akhir episode.** Warga, rumah, sisa hari. Angka membuat pertumbuhan terasa nyata.
5. **Satu tokoh sentral yang memandu.** Ollie, Caqii, Pak Wit, narator Infinite Wood. Penonton mengikuti orangnya, bukan cuma bangunannya.
6. **Ancaman atau tenggat.** Raja Naga 100 hari, goblin menyerang, musim dingin, lahan habis. Tanpa tenggat, tidak ada alasan kembali besok.
7. **Nama-nama dari follower.** Bangunan dan peran diberi nama orang sungguhan. Follower menjadi bagian dunia, bukan penonton.
8. **Ledakan awal, lalu stabil.** Day 1–2 selalu terbesar (16–26 ribu like), lalu turun ke ratusan. Yang bertahan adalah yang punya cerita berjangka, bukan yang mengandalkan ledakan.

---

## Rekomendasi: 5 hal paling layak ditiru duluan

### 1. Formula caption + statistik akhir episode (MUDAH — tanpa ubah game)
Pakai formula yang sama di semua episode "Membangun Pesantren Universe — Hari ke-X":
- Caption: "Follow = jadi santri. 1 santri = 1 kamar di asrama."
- Akhir video: kartu statistik — jumlah santri, kamar terisi, bangunan berikutnya + ambangnya (25/50/100/200).
- Contoh nada dari Sawitopia: "X santri, Y kamar terisi, Z santri masih ngaji di serambi karena kelas belum dibangun."

### 2. Kyai sebagai pembawa acara + tokoh dari komen (MUDAH — karakter sudah ada)
- Ust. Aqsal Murad (ronde 15–16) menjadi narator tiap episode, seperti Caqii di Desa Netizen.
- Tiap episode: sebut nama 1–3 santri yang komennya menang + beri mereka peran di game (ketua asrama, musyrif, penjaga perpustakaan). Peran ini tampil di video berikutnya.
- Santri 20 pendaftar pertama dapat skin/outfit eksklusif permanen (ala "OGs" Ollie's Realm).

### 3. Pemilihan jabatan dari like komen (MUDAH — tanpa ubah game)
- Adopsi pemilihan RT Desa Netizen: Ketua Asrama dan Musyrif dipilih dari komen terbanyak. Cocok dengan struktur organisasi kompleks asrama yang sudah diriset.
  - > **Koreksi 16 Nov 2026:** sistem 21 regu dihapus Mas — diganti 1 kompleks asrama (Asrama A, B, C…). Jabatan yang dipilih dari like komen adalah **Ketua Asrama** (bukan Ketua Regu).
- Umumkan pemenang di episode berikut + tampilkan namanya di papan dalam game.

### 4. Hitung mundur event pesantren (MUDAH — tanpa ubah game)
- Ganti "Raja Naga 100 hari" dengan tenggat pesantren: mis. "30 hari menuju Khataman Akbar" atau "Maulid Akbar di Hari ke-100". Tampilkan sisa hari di tiap episode.
- Event ini juga memberi alasan membangun bangunan tertentu tepat waktu (mis. Masjid Besar harus jadi sebelum Maulid).

### 5. Monetisasi "bangunan custom" + "lapak santri" (SEDANG — butuh paket Lynk.id)
- Tier ala Ko-fi Ollie's Realm, dijual lewat Lynk.id: (a) skin/outfit custom, (b) kamar/rumah custom di game, (c) bangunan didedikasikan untuk pendukung (mis. "Perpustakaan ini dibangun untuk @nama"), (d) tier emas.
- "Lapak Santri" ala Pasar Netizen: usaha nyata bisa buka lapak di Pesantren Universe dan disebut namanya di episode — monetisasi tanpa terasa jualan.

---

## Yang TIDAK usah ditiru (dan alasannya)

| Yang tidak ditiru | Alasan |
|---|---|
| Avatar anime/realistis VRChat | Butuh model impor + rig + Blender berat; primitif Godot bukan jalurnya. Pesantren Universe sudah memilih primitif (keputusan Mas). |
| Voxel Minecraft murni | Kotak-kotak kasar; Pesantren Universe sudah lebih halus (primitif bulat + batik). Mundur ke voxel = downgrade visual. |
| Top-down murni (Infinite Wood) | Pesantren Universe sudah third-person 3D yang bisa dijelajahi; top-down hanya cocok untuk video, bukan untuk game-nya. Boleh dipakai sebagai sudut kamera video sesekali, bukan sebagai arah game. |
| Kekerasan/konflik buatan (goblin menyerang, naga, perang) | Tidak cocok dengan nilai pesantren. Ganti dengan event positif: khataman, lomba hafalan, maulid, musim hujan. |
| 1 follower = 1 bangunan penuh secara literal | Di awal (0 santri) tidak masalah, tapi di 1.000 santri = 1.000 bangunan = game tidak muat di HP. Ambang 25/50/100/200 yang sudah disetujui Mas lebih sehat; 1 santri = 1 kamar/penanda kecil, bukan 1 bangunan. |
| Akun kurasi/repost (Minecraft builds, vrcgallery) sebagai model akun | Mereka tidak membangun dunia — hanya memamerkan karya orang. Boleh jadi bank ide, bukan model. |
| Tema Low Poly Stories (kucing, gaya PS1) | Bukan dunia virtual; hanya ambil prinsip "bentuk sederhana + karakter kuat". |
| Kejar ledakan Day 1 | Day 1 semua akun meledak (16–26 ribu like) lalu turun 90%+. Yang menentukan bukan ledakan, melainkan cerita berjangka yang membuat orang kembali di Day 30, Day 100, Day 240 (Ollie's Realm membuktikannya). |

---

## Catatan kejujuran data

- Semua jumlah follower, jumlah postingan, like, dan komen di laporan ini **terverifikasi lewat Instagram CLI** pada 16 Nov 2026 ~08:26–08:35 WIB, memakai akun terhubung aqsal.murad. Kalau sebuah angka tidak ada di laporan, artinya tidak terverifikasi — bukan perkiraan.
- Deskripsi visual karakter/bangunan disimpulkan dari caption postingan + ringkasan hasil pencarian web. **Saya tidak memutar video Reels secara penuh**, jadi detail seperti warna persis atau bentuk atap adalah interpretasi yang wajar, bukan pengamatan frame-per-frame. Sebelum meniru detail visual tertentu (mis. bentuk masjid Ollie's Realm), cek dulu Reels aslinya.
- @kampungkomen dan @ponpes_netizen sengaja tidak diteliti ulang (sudah jadi referensi Mas).
- Akun-akun kecil (@pinang_animation 7 follower, @lowpolylands 551 follower) dicantumkan sebagai contoh tahap awal — bukan sebagai bukti viral.
