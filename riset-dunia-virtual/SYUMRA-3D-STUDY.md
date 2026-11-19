# Studi 3D Syumra Simulator — Kenapa Terlihat Bagus, dan Pelajarannya untuk Pesantren Universe

**Tanggal:** 17 November 2026
**Peneliti:** Zahra (riset Pesantren Universe)
**Tujuan:** Menjawab pertanyaan Mas — "Coba cek Syumra itu kok bisa bagus, 3D-nya" — dan menarik pelajaran konkret untuk ronde perbaikan Sloyd (Bima), yang Mas putuskan TETAP jadi base putra+putri dengan fokus perbaikan kostum + wajah.

**Batasan studi:** Masuk ke dalam simulasi butuh login (Google/email) dan login BELUM diizinkan Mas, jadi studi ini dari sumber publik saja: teks halaman situs (diambil 17 Nov 2026), pemberitaan, dan rekaman gameplay yang beredar di Instagram/Threads. Proporsi kepala karakter TIDAK bisa diukur persis tanpa login — angka proporsi di bawah ini dinyatakan sebagai perkiraan dari observasi layar pembuatan karakter, bukan hasil ukur.

---

## 1. Teknologi — Three.js + Rust, "vibe coding", 3 minggu

- **Engine/framework: Three.js** (pustaka JavaScript WebGL) **+ Rust**. Dikutip langsung dari pengembangnya, Erwin Hermanto (Bandung, alumni STMIK Bandung 2012), lewat akun Threads @erwinhermantodev: *"Bismillah Hasil vibe code three Js dan rust di simulator umroh versi 1."*
- **"Vibe coding"** = pengembangan dengan bantuan AI (kode dihasilkan/disusun dari instruksi pengembang). Versi 1 selesai dalam **~3 minggu** (wawancara detikHikmah, 6 Nov 2026).
- **Berjalan langsung di browser, tanpa unduh.** Gratis. Situs: https://simulator.syumra.id/
- **Peran Rust belum terkonfirmasi** — tidak ada sumber yang menjelaskan rincian implementasi Rust di dalamnya (kemungkinan dikompilasi ke WebAssembly untuk bagian yang butuh performa, tapi ini dugaan, bukan fakta).
- Catatan: satu ringkasan video IG menulis teknologinya "3GF" — hampir pasti salah transkripsi dari "Three.js"; semua sumber teks mengutip pengembang yang menyebut Three.js.
- **Struktur simulasi:** 9 tahap berurutan — pembuatan karakter jamaah, persiapan, keberangkatan, miqat, tawaf, salat + zamzam, sa'i, tahallul, perjalanan pulang. Tiga rute: Makkah (8 tahap), Madinah (6), Al-Aqsa (6).
- **Kontrol:** WASD/panah untuk jalan, drag mouse untuk kamera, roda mouse untuk zoom, Ctrl+←→ pindah tahap. Bahasa ID/EN/AR, mode terang/malam, efek suara + talbiyah. Denah Masjidil Haram memakai data OpenStreetMap (ODbL).

### Pelajaran teknologi untuk Pesantren Universe

- Syumra membuktikan **tiga dimensi di browser tidak butuh engine berat**: Three.js (WebGL) cukup untuk dunia 3D yang terasa hidup — sejajar dengan pilihan kami memakai Godot (Web export). Yang menentukan bukan engine-nya, melainkan **arah seni + pencahayaan + dunia yang dikenali**.
- **Waktu bangun v1 hanya 3 minggu** — karena scope dijaga (satu dunia, satu alur terpandu, karakter sederhana). Pelajaran untuk rencana upgrade visual kami: fase kecil yang selesai lebih baik daripada dunia besar yang setengah jadi.

---

## 2. Arah seni karakter — kenapa tidak terlihat aneh

### 2.1 Wajah: sengaja DATAR, bukan detail

Ini temuan terpenting. Teks pengaturan di situs Syumra sendiri:

> "Mata, alis, dan bibir semua karakter digambar polos sewarna kulit. Janggut, rambut, peci, dan hijab tetap tampil." — **Mode Karakter Tanpa Wajah (Faceless)**

Artinya: Syumra **tidak mencoba membuat wajah realistis sama sekali**. Mata, alis, dan bibir digambar datar sewarna kulit — praktis tanpa fitur wajah — dan ada mode tanpa wajah. Identitas karakter dibawa oleh:

- **Peci kubah putih, janggut hitam tebal** (putra), **hijab putih** (putri)
- **Kurta/gamis putih / ihram**, bukan wajah
- **Kustomisasi:** 7 warna pakaian, 5 warna kulit, pilihan outfit, janggut, mode sendiri/berpasangan/keluarga

Karakter ditampilkan di layar pembuatan dengan **putaran 360°** ("Geser untuk memutar karakter 360°") — model harus enak dilihat dari semua sudut.

### 2.2 Proporsi: dewasa, stylized, BUKAN chibi

Karakter Syumra adalah **jamaah dewasa** dengan proporsi mendekati realistis dan kepala sedikit lebih besar dari manusia asli (stylized, mudah dibaca di layar). Bukan chibi ~3 kepala seperti Sloyd kami. Kepala besar yang moderat + badan dewasa = tidak masuk "uncanny valley" karena tidak ada yang mencoba meniru wajah manusia secara detail.

### 2.3 Yang membuat karakter terasa hidup: GERAK + KERUMUNAN, bukan wajah

- Avatar **berjalan, tawaf, salat** (takbir, ruku, sujud, duduk, salam), minum zamzam, mencium/menyentuh Hajar Aswad — animasi ritual lengkap dengan petunjuk langkah di layar.
- **Kerumunan jamaah lain** di pelataran Masjidil Haram — banyak salinan avatar sederhana yang bergerak bersama. Dunia terasa hidup karena ramai, bukan karena satu karakter yang detail.
- **Kustomisasi = keterikatan emosional.** Karakter itu "punya saya" (nama, warna kulit, pakaian sendiri), jadi pengguna memaafkan kesederhanaan visualnya.

### 2.4 Perbandingan langsung dengan masalah Sloyd kami

| Syumra (bagus) | Sloyd kami (masih aneh) |
|---|---|
| Wajah datar / dilukis saja — satu sistem | Wajah lukis anime + bola mata 3D + mulut elipsoid ditumpuk — dua sistem wajah bertabrakan |
| Mata kecil / datar, tanpa kilau | Bola mata putih r 0,045 terlalu besar, mengkilap → melotot |
| Mulut nyaris tidak ada (datar sewarna kulit) | Elipsoid merah mengkilap + strip gigi putih kotak → seperti pil merah |
| Rambut/peci menempel kepala, proporsional | Mangkuk rambut r 0,198 seperti helm; peci menutupi sebagian rambut |
| Mesh bersih, karakter enak dilihat 360° | Tepi bergerigi "kertas sobek" di leher/rahang (sisa decimate), paling kentara dari samping dan close-up |
| Pakaian = bentuk tubuh (kurta/ihram jatuh natural) | Sarung kerucut polos; lengan baju tanpa tangan yang jelas; hood putri seperti bola; panel dada putih aneh |
| Identitas dari kostum + aksesori | Kostum masih bentuk dasar (kerucut, tabung) |

---

## 3. Arah seni dunia — kenapa dunianya terasa hidup

1. **Tempatnya nyata dan dikenali.** Masjidil Haram, Ka'bah, Menara Jam Abraj Al-Bait, Masjid Nabawi, Raudhah, Quba, Uhud, Kubah Shakhrah, Masjid Al-Qibli. Pengguna sudah tahu bentuknya — pengenalan mengerjakan separuh pekerjaan visual. Geometri sederhana pun terbaca sebagai "asli".
2. **Satu suasana cahaya yang kuat: matahari terbenam yang hangat.** Latar Ka'bah + Masjidil Haram saat sunset, langit gradasi hangat, plus mode malam/terang. Satu mood cahaya yang konsisten menyatukan model-model sederhana menjadi satu gambar yang utuh.
3. **Landmark hero detail, sisanya sederhana.** Ka'bah, menara, menara jam dibuat menonjol; bangunan latar dan kerumunan dibuat simpel. Detail hanya di titik yang dilihat pengguna.
4. **Alur terpandu, bukan sandbox kosong.** 9 tahap berurutan + petunjuk langkah di layar + penanda jalur hijau + prompt ritual (ambil gelas → bismillah → minum tiga teguk → doa → buang). Pengguna tidak pernah dibiarkan bingung di dunia kosong.
5. **Detail interaksi kecil:** dispenser zamzam, toko suvenir, kamar hotel dengan pemandangan Ka'bah, pilihan mencium/menyentuh Hajar Aswad.
6. **Suara:** talbiyah + nasheed sebagai atmosfer (Pesantren Universe sudah punya jalur serupa: ambience burung/angin/jangkrik).

### Pelajaran dunia untuk rencana upgrade visual kami

- **Satu mood cahaya hangat yang konsisten** lebih berpengaruh daripada menambah poligon. (Rencana upgrade visual sudah mengusulkan ini — pertahankan.)
- **Landmark hero dulu** (Surau, Musholla, gapura), bangunan latar boleh sederhana.
- **Kerumunan/NPC yang bergerak** (santri lain, Kyai, Ustadzah) membuat dunia terasa hidup — karakter utama tidak sendirian.
- **Alur terpandu** (misi berurutan seperti M1→M2→M3 yang sudah ada) lebih kuat daripada dunia bebas yang kosong.

---

## 4. Pelajaran konkret untuk Bima — ronde perbaikan Sloyd

Delapan hal, urut dari yang paling berpengaruh ke "aneh"-nya:

1. **SATU sistem wajah saja — jangan tumpuk wajah lukis + wajah geometri.**
   Ini penyebab utama "aneh". Pilih salah satu: (a) wajah **lukis datar** seperti aslinya Sloyd dan seperti Syumra — hapus bola mata 3D, hapus mulut elipsoid; atau (b) fitur geometri **minimal dan kecil**. Jangan dua-duanya. Mata anime yang dilukis masih mengintip di bawah bola mata = wajah ganda. Rekomendasi: jalur (a) — wajah lukis, karena wajah lukis putri sudah terbukti cantik di render.
2. **Kecilkan mata putra drastis.**
   Referensi Mas: mata = titik hitam kecil di dalam kacamata besar. Bola putih r 0,045 + pupil r 0,018 terlalu besar dan mengkilap → melotot. Target: mata kecil, datar, tanpa kilau specular yang kuat. Kacamata besar yang jadi bintang, bukan bola matanya.
3. **Mulut: buang elipsoid merah + strip gigi kotak.**
   Ganti senyum tipis datar (garis/lukis tipis sewarna bibir natural) atau senyum tertutup seperti wajah lukis putri. Mulut merah mengkilap adalah penyebab "aneh" nomor dua setelah mata.
4. **Rambut jangan helm; peci proporsional.**
   Mangkuk rambut r 0,198 terlalu besar dan menutupi kepala. Buat rambut tipis menempel tengkorak + poni sebagai bidang, bukan bola. Peci jangan menutupi rambut sepenuhnya; ukurannya proporsional dengan kepala (Syumra: peci kubah kecil menempel, rambut/janggut tetap terlihat).
5. **Retopology leher–rahang–pelipis, jangan andalkan decimate + "skinning".**
   Tepi bergerigi "kertas sobek" di leher/rahang adalah cacat paling kentara di render samping dan close-up wajah. Rapikan manual area itu (retopo), dan bersihkan sisa tint rambut AI (serpihan pink/oranye) dari tekstur wajah — termasuk noda pelipis putri.
6. **Kostum harus punya bentuk tubuh, bukan kerucut/tabungan.**
   - Sarung: beri bentuk pinggang + lipatan + ujung kaki dan sepatu terlihat — jangan kerucut polos dari dada ke lantai.
   - Lengan: lengan baju harus mengeluarkan lengan dan tangan yang jelas (tangan Sloyd baru sudah dibuat — pastikan kelihatan, tidak tersembunyi di balik lengan baju).
   - Hood putri: ikuti bentuk kepala + drape jatuh ke bahu, bukan bola; hapus panel dada putih, ganti dengan drape jilbab yang menyatu ke abaya.
7. **Material dan pencahayaan render: matte + hangat.**
   Kulit matte (kilau rendah), mata tanpa kilau putih besar, render dengan cahaya hangat 3-point + fill lembut — seperti suasana sunset Syumra. Render Cycles netral saat ini membuat setiap cacat makin kentara. Uji render dengan suasana hangat sebelum dinilai.
8. **Uji 360°: depan, samping, tiga-perempat, DAN belakang.**
   Syumra menampilkan karakter 360° di layar pembuatan — standar yang sama untuk santri. Sloyd saat ini gagal dari samping (tepi bergerigi) dan close-up wajah. Jangan ACC look sebelum keempat sudut + close-up wajah lolos.

### Catatan tambahan

- **Opsi mode tanpa wajah** (seperti Syumra) tidak diusulkan untuk santri — referensi Mas jelas memakai wajah. Tapi prinsipnya sama: kalau wajah terus gagal, jalan keluarnya adalah wajah yang **lebih sederhana**, bukan yang lebih detail.
- **Kustomisasi sebagai penguat:** sistem Ganti Baju yang sudah ada (warna sarung/abaya/jilbab, kulit, kacamata) sejalan dengan pelajaran Syumra — pertahankan dan tonjolkan saat karakter sudah masuk game.

---

## 5. Ringkasan satu paragraf

Syumra terlihat bagus **bukan karena modelnya paling detail**, melainkan karena ia menghindari semua hal yang sulit dengan cerdas: wajah dibuat datar (tidak ada wajah realistis yang bisa gagal), identitas dibawa kostum dan aksesori, proporsi dewasa yang wajar, satu suasana cahaya hangat yang menyatukan semuanya, dunia berupa tempat nyata yang sudah dikenali, dan kehidupan datang dari gerak, kerumunan, serta alur terpandu — semuanya dibangun satu orang dalam 3 minggu dengan Three.js + Rust dan bantuan AI. Pelajaran terbesar untuk Sloyd kami: **sederhanakan wajah (satu sistem, fitur kecil dan datar), rapikan mesh (retopo, bukan decimate), dan beri kostum bentuk tubuh yang benar** — sisanya (cahaya hangat, landmark, kerumunan) adalah pekerjaan dunia, bukan karakter.

---

## Sumber

- Situs resmi (teks halaman diambil 17 Nov 2026): https://simulator.syumra.id/
- Jatengku — "Erwin Hermanto Kembangkan Simulator Umroh Interaktif, Bisa Dicoba Secara Online" (14 Okt 2026): https://jatengku.com/erwin-hermanto-kembangkan-simulator-umroh-interaktif-bisa-dicoba-secara-online/
- IndonesiaLink — "Rindu Tanah Suci, Pria Bandung Ciptakan Game Simulator Umrah 3D!" (wawancara detikHikmah 6 Nov 2026): https://www.indonesialink.id/post/haji-dan-umroh/1976/rindu-tanah-suci-pria-bandung-ciptakan-game-simulator-umrah-3d-bisa-belajar-tawaf-dan-sai-secara
- Arina — "Belajar Manasik Umrah Lewat Gim 3D" (5 Nov 2026): https://www.arina.id/berita/ar-t9y9j/belajar-manasik-umrah-lewat-gim-3d
- HIMPUH — "Gim 3D Syumra Simulator: Belajar Manasik Umrah Lebih Seru" (5 Nov 2026): https://himpuh.or.id/blog/detail/5165/gim-3d-syumra-simulator-belajar-manasik-umrah-lebih-seru
- Babe Indonesia — "Viral Game Simulator Umrah 3D Terasa Nyata..." : https://babeindonesia.com/read/7029842/viral-game-simulator-umrah-3d-terasa-nyata-banyak-yang-doakan-developer-masuk-surga
- Islamipedia/Berita (kutipan Republika, A. Syalaby Ichsan, 6 Nov 2026): https://berita.islamipedia.id/read/pemuda-bandung-bikin-simulator-umrah-gratis-bisa-antar-keliling-5116956217
- Rekaman gameplay (Instagram): @ussfeeds (carousel 7 slide, 4 Nov 2026), @indonesian.core (4 Nov 2026), @shiftmedia.id (3 Nov 2026), @garudatv.official (7 Nov 2026), @jktlogy (2 Nov 2026), @grow.bareng (5 Nov 2026) — deskripsi gameplay: tawaf, salat, zamzam, Hajar Aswad, kustomisasi karakter, kerumunan jamaah.
- Threads pengembang: https://www.threads.com/@erwinhermantodev (dikutip lewat Jatengku)
- Internal: `blender-santri/karakter-baru/sloyd/SLOYD-STATUS.md` (catatan jujur Bima); studi Syumra sebelumnya (browser task, 17 Nov 12:38 WIB) — observasi layar karakter + kustomisasi.

## Batasan yang dicatat

- **Tidak login ke Syumra** (belum ada izin Mas) — isi simulasi, proporsi kepala persis, dan detail mesh/shader tidak bisa diperiksa langsung; semua angka proporsi di laporan ini adalah perkiraan observasi, bukan hasil ukur.
- Peran Rust dalam arsitektur Syumra belum terkonfirmasi dari sumber mana pun.
- Screenshot PDF/PNG studi sebelumnya gelap (canvas 3D tidak tercetak) — tidak dipakai sebagai bukti visual.
