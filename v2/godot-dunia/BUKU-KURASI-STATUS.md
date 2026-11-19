# BUKU — KURASI & STATUS

Kurator: Laras (Tim Materi, tim Tara) — 17 Nov 2026, ~23:5x WIB.
Aturan yang dipakai: reader di game HANYA menampilkan buku `dicek_ustadz:true`.
File reader: `data/buku.json` (format kontrak, lihat §5).
Draf yang DITAHAN (jangan dimuat reader): `data/buku-draft-nahwu.json`.

## Ringkasan status

| # | Buku | Status | Di `buku.json`? |
|---|------|--------|-----------------|
| 1 | Nahwu Dasar — Belajar Membaca Kitab (orisinal kita, 78 hal) | **DITAHAN — menunggu cek ustadz (4 kaidah)** | TIDAK — draf di `buku-draft-nahwu.json` |
| 2 | Puisi Pilihan Chairil Anwar (5 sajak + pengantar) | **BOLEH DIBACA** — domain publik, teks terverifikasi | YA |
| 3 | Atlas Pesantren Universe — Peta & Masterplan v2 (6 halaman gambar) | **BOLEH DIBACA** — karya tim sendiri | YA |
| 4 | Azab dan Sengsara — Merari Siregar | **TERVERIFIKASI (domain publik)** — teks Bab 1 belum ditarik (lihat §2) | BELUM |
| 5 | Sengsara Membawa Nikmat — Tulis Sutan Sati | **TERVERIFIKASI (domain publik)** — rencana isi | BELUM |
| 6 | Habis Gelap Terbitlah Terang — R.A. Kartini | **TERVERIFIKASI (domain publik)** — rencana isi, catatan ejaan lama | BELUM |
| 7 | Hikayat Hang Tuah (anonim, Melayu klasik) | **TERVERIFIKASI (domain publik)** — perlu adaptasi ejaan, belum siap | BELUM |
| 8 | Jurumiyah | **SUDAH LOLOS CEK USTADZ (Mas, 23:49 WIB)** — boleh dibaca | TIDAK — isi dari server (Saka) |
| 9 | Safinatun Naja | **SUDAH LOLOS CEK USTADZ (Mas, 23:49 WIB)** — boleh dibaca | TIDAK — isi dari server (Saka) |
| 10 | Imrithi | **SUDAH LOLOS CEK USTADZ (Mas, 23:49 WIB)** — boleh dibaca | TIDAK — isi dari server (Saka) |
| 11 | Matn Abi Shuja | **SUDAH LOLOS CEK USTADZ (Mas, 23:49 WIB)** — boleh dibaca | TIDAK — isi dari server (Saka) |
| 12 | Arba'in Nawawi | **SUDAH LOLOS CEK USTADZ (Mas, 23:49 WIB)** — boleh dibaca | TIDAK — isi dari server (Saka) |

## 1. Ebook Nahwu Dasar v2 — DITAHAN (4 kaidah "perlu dicek ustadz")

- Sumber: `~/workspace/goals/pesantren-verse/files/ebook-nahwu-dasar-pesantren-verse/ebook-nahwu-dasar-pesantren-verse.pdf` — 78 hal. B5, format Al-Miftah, materi orisinal Pesantren Universe (bukan kitab Al-Miftah).
- Isi sudah diekstrak per bagian ke `data/buku-draft-nahwu.json` (8 bab, hal. PDF 1–78) sebagai STAGING. File itu memuat field `PERINGATAN` + `dicek_ustadz:false` dan **dilarang dimuat reader**.
- Empat kaidah yang ditahan (kutipan persis dari PDF, dengan penanganannya):
  1. **Daftar muannats tanpa tanda (muannats samai)** — PDF hal. 33, Bagian 2. *"Perlu dicek ustadz: daftar muannats tanpa tanda (muannats samai) cukup panjang dan berbeda-beda rincinya antar kitab."* Penanganan: daftar lengkap TIDAK disajikan; hanya contoh yang paling sering muncul yang dipakai, sisanya dirujuk ke ustadz.
  2. **Perubahan bentuk mu'tal / i'lal** — PDF hal. 50, Bagian 3. *"Perlu dicek ustadz: perubahan bentuk mu'tal saat bertemu pelaku yang berbeda (i'lal) adalah materi tashrif lanjutan."* Penanganan: i'lal tidak diajarkan; hanya pengenalan golongan shahih/mu'tal.
  3. **Syarat isim laa nafi jins** — PDF hal. 62, Bagian 4. *"Isim laa nafi jins — rincian syaratnya perlu dicek ustadz."* Penanganan: hanya disebut sekilas sebagai pengantar; rincian syarat tidak disajikan.
  4. **Rincian bentuk munada** — PDF hal. 65, Bagian 4. *"Perlu dicek ustadz: munada punya rincian bentuk (mufrad alam dibina atas dhammah, mudhaf manshub)."* Penanganan: hanya pola munada yang paling sering yang ditampilkan.
- Di draf, tiap bab yang mengandung butir ditahan membawa field `bagian_ditahan_menunggu_cek_ustadz`.
- **Clearance ustadz 23:49 WIB (Jurumiyah + antrean) TIDAK mencakup keempat kaidah ini** — tetap ditahan sampai ada konfirmasi eksplisit Mas/ustadz untuk ebook ini.
- Catatan teknis draf: teks Arab hasil ekstraksi `pdftotext` tampil terpisah-pisah (artefak ekstraksi, bukan isi asli) — WAJIB cek visual terhadap PDF sebelum tayang; jangan jadikan draf ini acuan harakat. Penjelasan berbahasa Indonesia tersalin utuh.
- Begitu keempat butir dikonfirmasi ustadz: ubah `dicek_ustadz` jadi `true` di draf, pindahkan entrinya ke `buku.json`, hapus field `PERINGATAN`/`catatan_cek_ustadz`.

## 2. Buku bahasa Indonesia — set awal (domain publik, terverifikasi)

Semua judul di bawah ini lisensinya dicek satu per satu; tidak ada yang diklaim tanpa sumber.

### 2a. SUDAH MASUK READER — Puisi Pilihan Chairil Anwar

- Pengarang: Chairil Anwar (Medan, 26 Juli 1922 — Jakarta, 28 April 1949).
- Lisensi: **domain publik di Indonesia** — UU No. 28 Tahun 2014, pengarang wafat >70 tahun lalu.
- Bukti: halaman pengarang Wikisource bahasa Indonesia memuat daftar karya + koleksi 1949; indeks `Kerikil Tadjam Dan Jang Terampas Dan Jang Putus` (1949) ada di Wikisource.
- Sumber: https://id.wikisource.org/wiki/Chairil_Anwar — https://id.wikisource.org/wiki/Indeks:Kerikil_Tadjam_Dan_Jang_Terampas_Dan_Jang_Putus_-_Chairil_Anwar.pdf
- Isi di reader (`puisi-chairil-anwar-pilihan`, 6 bab): pengantar "Tentang Penyair" + 5 sajak asli lengkap — "Aku" (Mar 1943), "Diponegoro" (Feb 1943), "Doa" (13 Nov 1943), "Hampa" (Mar 1943), "Senja di Pelabuhan Kecil" (1946). Teks tiap sajak dicek silang dengan halaman uji-baca Wikisource dan Badan Bahasa Kemendikdasmen.
- Ringkasan: sajak-sajak pendek Angkatan '45 tentang semangat hidup, perjuangan, dan doa — cocok dibaca santri dalam 1–2 menit per sajak.
- Yang SENGAJA tidak dimasukkan: "Karawang-Bekasi" — di daftar Wikisource karya itu ditandai `#Saduran puitis` (saduran dari sajak asing Archibald MacLeish), jadi tidak disajikan sebagai karya asli.
- Catatan varian ejaan (dicatat di bab pengantar reader): ejaan mengikuti teks sumber Wikisource — "pedih peri" (edisi modern: "pedih perih"), "tidak perduli" (edisi modern: "tidak peduli"), "Dalam termangu" / "kerdip lilin" (sebagian sumber modern: "termenung" / "kerlip"), dedikasi "buat Sri Ayati" (Badan Bahasa menulis "Sri Ajati").

### 2b. TERVERIFIKASI, RENCANA ISI — Azab dan Sengsara

- Pengarang: Merari Siregar (13 Juli 1896 — 23 April 1941).
- Lisensi: **domain publik di Indonesia** — halaman Wikisource-nya sendiri memuat templat: *"Karya ini berada pada domain publik di Indonesia karena penciptanya telah meninggal dunia lebih dari 70 tahun yang lalu… (Bab IX UU No. 28 Tahun 2014)"*.
- Sumber: https://id.wikisource.org/wiki/Azab_dan_Sengsara
- Ringkasan: novel modern Indonesia pertama (Balai Pustaka, 1920) — kisah Mariamin dan Aminuddin yang cintanya terhalang adat kawin paksa di Sipirok; 9 bab ("Waktu Senja" s.d. "Penutup Kalam").
- Rencana isi: Bab 1 "Waktu Senja" dulu, lalu Bab 2–9 menyusul per bab.
- **Kendala (jujur): teks lengkap Bab 1 BELUM berhasil ditarik.** Halaman utama Wikisource berhasil dibuka dan daftar isinya terverifikasi, tetapi sub-halaman Bab 1 tidak bisa dibuka dari perkakas yang tersedia (tidak ada tautan yang bisa diikuti; menebak URL dilarang). Perlu tindak lanjut: tarik teks Bab 1 lewat browser live / API Wikisource, lalu masukkan sebagai bab di `buku.json`.

### 2c. TERVERIFIKASI, RENCANA ISI — Sengsara Membawa Nikmat

- Pengarang: Tulis Sutan Sati (1898–1942, Bukittinggi–Jakarta).
- Lisensi: **domain publik di Indonesia** — pengarang wafat 1942 (>70 tahun lalu, UU No. 28/2014).
- Sumber: https://id.wikisource.org/wiki/Sengsara_Membawa_Nikmat_(1972) (pindaian edisi Balai Pustaka 1972 dari cetakan pertama 1929; halaman-halaman sudah uji-baca).
- Ringkasan: novel Minangkabau tentang Midun, pemuda sabar yang hidup melarat sebelum akhirnya bahagia — dibuka dengan adegan mengaji di surau tepi sungai; sangat dekat dengan kehidupan santri. Bab 1: "Bermain Sepak Raga".
- Rencana isi: Bab 1 dulu, lalu bab-bab berikutnya.

### 2d. TERVERIFIKASI, RENCANA ISI — Habis Gelap Terbitlah Terang

- Pengarang: R.A. Kartini (wafat 17 September 1904).
- Lisensi: **domain publik di Indonesia** — pengarang wafat >70 tahun lalu; terbitan Balai Poestaka 1922.
- Sumber: https://id.wikisource.org/wiki/Habis_Gelap_Terbitlah_Terang
- Ringkasan: kumpulan surat Kartini tentang pendidikan perempuan dan kemajuan Jawa — relevan untuk santriwati; termasuk surat peringatan "Berilah Orang Djawa Pendidikan!" (Januari 1903).
- Catatan: ini TERJEMAHAN Melayu (oleh "Empat Saudara") dari kumpulan surat berbahasa Belanda, dengan ejaan lama (oe, dj, tj). Sebelum masuk reader perlu diputuskan: tampilkan ejaan asli 1922 apa adanya (dengan catatan), atau ejaan yang dimodernkan. Rencana isi: Pendahuluan + "Berilah Orang Djawa Pendidikan!" dulu.

### 2e. TERVERIFIKASI, BELUM SIAP — Hikayat Hang Tuah

- Pengarang: anonim, sastra Melayu klasik (abad ke-17, kisah Hang Tuah, Hang Jebat, dan empat sahabat).
- Lisensi: **domain publik** — karya anonim berabad-abad lalu.
- Sumber: https://ms.wikisource.org/wiki/Hikayat_Hang_Tuah_(Rumi) (Wikisource bahasa Melayu — transliterasi Rumi + teks Jawi).
- Ringkasan: epos kepahlawanan Melayu tentang kesetiaan Hang Tuah kepada raja — nilai kesetiaan dan adab yang dekat dengan pesantren.
- Belum siap masuk reader karena: sumbernya di Wikisource Melayu (bukan Indonesia), sebagian besar teks masih aksara Jawi, dan bahasa Melayu klasik perlu penyuntingan ejaan sebelum enak dibaca santri. Rencana: ambil 1 episode (mis. Hang Tuah kecil di Sungai Duyung) setelah ada penyuntingan.

## 3. Atlas — isi pertama (karya tim sendiri, lisensi bersih)

- Sumber gambar: `~/workspace/pesantren-verse/v2/konsep/peta-tata-letak-v2-masterplan.png` dan `peta-tata-letak-v2.png` (karya tim, 17–18 Nov 2026). Disalin ke `data/atlas/`; tidak ada peta/data geografis luar yang dibuat-buat.
- Entri reader: `atlas-pesantren-verse`, jenis `gambar`, 6 halaman:
  1. Masterplan v2 utuh — keseluruhan pesantren (tembok x=14, Masjid Besar ±2.000 jamaah di tengah).
  2. Area Putra (crop) — Surau (0,−14) 16×20 m, Kelas Putra 5 lantai, Asrama Putra 3 lantai, Cangkruk, spawn putra.
  3. Zona Penyangga (crop) — Masjid Besar, kebun/taman, jarak Surau → Musholla ±134 m.
  4. Kampus Putri (crop) — tembok baru x 115..216, z −70..+40 (18 Nov 2026); Musholla Ar-Raudhah (134,−24), Masjid Putri (rencana), Kelas/Asrama Putri 1 lantai + tapak cadangan 5L/3L (garis putus-putus), bekas Cangkruk jadi halaman/taman, Lapangan Putri di dalam tembok (tapak saja), Asrama ke-2 cadangan halaman selatan, spawn putri.
  5. Kawasan Bersama (crop) — Perpustakaan & Taman, Kantin, Aula, Sawah, Kebun, Kolam, Lapangan Putra.
  6. Sketsa awal v2 utuh — arsip perbandingan (Masjid Besar masih rencana, gedung masih 1 lantai).
- Tiap halaman membawa `keterangan` berisi koordinat/ukuran dari `KONSEP-TATA-LETAK.md` (mis. jejak Surau terverifikasi Rangga 23:19).
- Catatan: masterplan DI-ACC Mas 18 Nov 11:57 WIB; bila Mas merevisi peta, atlas harus ikut diperbarui dari file konsep terbaru (skrip `v2/konsep/buat_atlas.py` — kotak crop dalam meter).
- **Update 18 Nov 13:40 WIB (Gilang):** atlas digambar ulang dari masterplan baru — 6 halaman diperbarui (masterplan + konsep utuh disalin; 4 crop digambar ulang; crop kampus-putri kotak baru x 100..222, z −76..44). Keterangan hal. 1 + 4 di `data/buku.json` diselaraskan. File `.import` tidak diubah — Godot akan reimport PNG baru saat editor dibuka berikutnya.

## 4. Kitab Arab — UPDATE 23:49 WIB (Mas: cek ustadz lolos)

- **Jurumiyah, Safinatun Naja, Imrithi, Matn Abi Shuja, dan Arba'in Nawawi SUDAH LOLOS CEK USTADZ dan BOLEH DIBACA di reader.** Koreksi sebelumnya (status false) TIDAK berlaku lagi.
- **Lencana "Belum dicek ustadz" TIDAK perlu untuk kitab-kitab ini.**
- Isi kitab-kitab itu datang dari server (Saka: membalik flag Jurumiyah jadi `true` di VPS + ingest antrean) — BUKAN tugas kurasi ini menyiapkan teksnya, dan teksnya TIDAK dimasukkan ke `buku.json` (supaya tidak ada dua sumber isi yang beradu). Bila reader ternyata hanya membaca `buku.json`, Saka/builder yang menambahkan entri kitab ke sana dari server.
- Yang tetap DITAHAN: 4 kaidah di ebook Nahwu Dasar v2 (§1) — clearance 23:49 WIB mencakup Jurumiyah + antrean, bukan ebook.

## 5. Format kontrak — keputusan yang diambil

- `data/buku.json` adalah **array JSON polos** berisi objek buku (tiap buku persis field kontrak: `id, judul, judul_latin, bahasa, jenis, dicek_ustadz, atribusi, lisensi`, lalu `bab:[{nomor, judul, teks}]` untuk `teks` atau `halaman:[{nomor, gambar, keterangan}]` untuk `gambar`). Tidak ada field tambahan di `buku.json`.
- Bila builder mengharapkan objek pembungkus (`{"buku": [...]}`), beri tahu Laras/Tara — jangan diam-diam mengubah; satu baris pembungkus cukup.
- Arti `dicek_ustadz:true` di file ini: untuk kitab Arab = lolos cek ustadz; untuk buku Indonesia/karya tim = lisensi terverifikasi + lolos kurasi Laras (kontennya bukan materi agama yang butuh cek ustadz). `false` = jangan tampilkan.
- `data/buku.json` saat ini HANYA berisi 2 buku yang boleh dibaca (Chairil + Atlas). Semua yang belum siap TIDAK dimasukkan — daftarnya hanya ada di dokumen ini.

## 6. Yang masih butuh tindak lanjut / keputusan

1. **Teks Bab 1 Azab dan Sengsara** — perlu ditarik dari Wikisource (lihat §2b) sebelum novel ini bisa masuk reader.
2. **Format pembungkus `buku.json`** — konfirmasi builder: array polos (seperti sekarang) atau objek `{"buku": [...]}`.
3. **Habis Gelap Terbitlah Terang** — putuskan ejaan asli 1922 vs dimodernkan sebelum diisi.
4. **Ebook Nahwu v2** — menunggu konfirmasi Mas/ustadz atas 4 kaidah §1; setelah itu balik flag dan pindahkan draf ke `buku.json`.
5. **Cek visual teks Arab draf Nahwu** terhadap PDF sebelum tayang (§1).
