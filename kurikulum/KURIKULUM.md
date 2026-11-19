# KURIKULUM PESANTREN UNIVERSE

**Dokumen:** Rancangan kurikulum — Tim Materi & Kurikulum (ketua: Laras)
**Tanggal:** 15 November 2026
**Status:** RANCANGAN (belum diubah ke dalam kode game/app/ebook)
**Revisi 1 — 15 Nov 2026 ~22:17 WIB (keputusan Mas):** sistem pesantren SATU — tidak ada lagi pilihan jalur di pendaftaran. Yang dulu "Jalur Misi" sekarang adalah mode belajar mandiri di dalam sistem tunggal; yang dulu "Jalur Ngaji Aja" diganti **pengajian kitab (khataman) terjadwal**. Kurikulum berangsur/berurutan: santri menyelesaikan 1 materi baru ke materi selanjutnya.
**Sumber:** Ebook Nahwu Dasar v2 (78 hlm B5), `mission_data.gd` (rantai M1→M3), keputusan Mas 15 Nov 2026, `GOAL.md`

---

## 1. Prinsip kurikulum

1. **Satu sistem, satu jalur berurutan.** Pesantren Universe punya SATU sistem belajar untuk semua santri — tidak ada lagi pilihan jalur di pendaftaran. Santri menempuh materi satu per satu dalam rantai yang terkunci: selesaikan 1 materi sampai lulus, baru materi berikutnya terbuka. Yang dulu disebut "Jalur Misi" sekarang adalah **mode belajar mandiri** di dalam sistem tunggal itu (baca materi → kuis → latihan → hafal → tes, §4.1); yang dulu "Jalur Ngaji Aja" sekarang adalah **pengajian kitab (khataman) terjadwal** (§4.2) — kegiatan bersama pada jam-jam tertentu, bukan jalur pilihan.
2. **Bertahap dan berurutan.** Materi tidak boleh dilompat: Bagian 2 memakai ilmu Bagian 1. Tes di akhir tiap bagian adalah pintu ke bagian berikutnya (prinsip yang sama dengan ebook).
3. **Nahwu dulu, kitab kemudian.** Target pertama: santri bisa membaca kalimat kitab. Karena itu mapel pertama dan paling lengkap adalah **Nahwu Dasar** (ebook sudah jadi). Mapel lain menyusul dengan format yang sama.
4. **Ma'hadiyah bukan mapel — tapi wajib.** 7 kegiatan harian (tahajjud, subuh berjamaah, dzikir pagi, dhuha, tilawah, lima waktu berjamaah, dzikir petang) adalah syarat "Santri Aktif" untuk naik jenjang, bukan mata pelajaran yang diujikan.
5. **Materi orisinal, kaidah standar.** Semua ebook ditulis orisinal (bukan salinan teks kitab lain), dengan kaidah merujuk Jurumiyah/Imrithi/Alfiyah/Safinatun Naja/Aqidatul Awam sebagai rujukan. Kaidah yang disederhanakan ditandai jujur; yang masih "perlu dicek ustadz" harus diselesaikan ustadz sebelum materi dipindahkan ke game.
6. **Kelas Isti'dad TIDAK memakai metode Al-Miftah.** Metode kelasnya adalah metode Pesantren Universe sendiri: baca materi → kuis → latihan → hafal bait → tes naik bagian.

---

## 2. Jenjang (tingkat)

Pesantren dimulai dari satu jenjang yang lengkap dulu, baru membuka jenjang berikutnya. Santri naik jenjang hanya bila lulus syarat jenjangnya (§6).

| Jenjang | Nama | Materi inti | Kitab rujukan | Bangunan di game |
|---|---|---|---|---|
| 0 | **Kelas Isti'dad** (persiapan) | Nahwu Dasar 100 hari + Fiqih Ibadah Dasar + Adab Santri + Tahsin | Ebook orisinal Pesantren Universe | Surau Kecil (sudah ada) |
| 1 | **Kelas Jurumiyah** | Nahwu menengah (Jurumiyah) + Shorof dasar (Amtsilah Tashrifiyyah) | Jurumiyah, Amtsilah Tashrifiyyah | Ruang Kelas (ambang 25 santri) |
| 2 | **Kelas Imrithi** | Nahwu lanjut (Imrithi) + Fiqih (Safinatun Naja) + Aqidah (Aqidatul Awam) | Imrithi, Safinatun Naja, Aqidatul Awam | Masjid Besar (ambang 100 santri) |
| 3 | **Kelas Kitab Kuning** | Membaca kitab kuning utuh + Alfiyah (pilihan) | Alfiyah, kitab-kitab kuning | Perpustakaan & Taman (ambang 200 santri) |

Catatan:

- **Tahap ini yang dibangun: Jenjang 0 (Kelas Isti'dad) saja.** Jenjang 1–3 adalah peta jalan; jadwal pengajian kitab (khataman) yang sekarang (Jurumiyah, Amtsilah, Safinatun Naja, Aqidatul Awam) adalah **cicipan** jenjang 1–2, bukan berarti santri Isti'dad sudah belajar kitab itu secara penuh.
- Asrama (ambang 50 santri) adalah bangunan hunian, bukan jenjang — di sana tinggal santri semua jenjang.
- Materi **sama untuk santriwan dan santriwati** (Tim Karakter sedang menyiapkan karakter + field gender di pendaftaran; kurikulum tidak membedakan isi materi).

---

## 3. Mata pelajaran (mapel)

| # | Mapel | Status | Ebook | Keterangan |
|---|---|---|---|---|
| 1 | **Nahwu** (inti) | ✅ Sudah ada | Nahwu Dasar v2 (78 hlm) | Mapel pertama; 4 Bagian × ±25 hari = 100 hari |
| 2 | **Fiqih** | ⏳ Berikutnya (prioritas 1) | Belum dibuat | Fiqih Ibadah Dasar — wudhu, shalat, puasa, zakat, haji (berbasis Safinatun Naja, orisinal) |
| 3 | **Shorof / Tashrif** | ⏳ Prioritas 2 | Belum dibuat | Shorof Dasar — tashrif fi'il (berbasis Amtsilah Tashrifiyyah, orisinal); pendamping wajib Nahwu |
| 4 | **Adab & Akhlak** | ⏳ Prioritas 3 | Belum dibuat | Adab Santri — adab kepada Allah, ustadz, kitab, teman, masjid; format ringkas |
| 5 | **Aqidah** | ⏳ Prioritas 4 | Belum dibuat | Aqidah Dasar — 50 aqidah (berbasis Aqidatul Awam, orisinal) |
| 6 | **Sejarah Islam** | ⏳ Prioritas 5 | Belum dibuat | Sejarah Islam — sirah Nabi, sahabat, peradaban (format cerita + timeline) |
| 7 | **Al-Quran (Tahsin & Tilawah)** | ⏳ Prioritas 6 | Belum dibuat | Tahsin (makhraj + tajwid dasar) + tilawah harian; butuh audio (catat batasan: audio game format OGG) |

Urutan belajar santri: **satu rantai berurutan** (§4) — santri menyelesaikan satu materi sampai lulus, baru materi berikutnya terbuka. Nahwu adalah tulang punggung rantai (pemetaan §5); modul Fiqih/Adab/Tahsin terselip pada titik-titik buka yang ditetapkan saat ebooknya jadi (usulan awal titik buka, §6.3).

---

## 4. Satu sistem belajar

Sistemnya satu: **satu rantai berurutan** untuk semua santri. Di dalam sistem itu ada tiga unsur yang saling melengkapi — belajar mandiri (§4.1), pengajian kitab terjadwal (§4.2), dan Ma'hadiyah wajib (§4.3). Tidak ada pilihan jalur di pendaftaran (§4.4).

### 4.1 Belajar mandiri di dalam game (mode utama)

- Belajar **mandiri, kapan saja**, di dalam pesantren 3D — ini mode utama sistem tunggal (dulu disebut "Jalur Misi").
- Pola tiap topik: **baca materi (kitab interaktif) → kuis singkat → latihan → hafal bait → tes naik bagian**.
- Misi berantai dan berurutan (seperti M1→M2→M3 sekarang): misi berikut terkunci sampai misi sebelumnya selesai.
- Setiap misi memberi **poin** ke Kartu Santri dan dikirim ke server (dengan `event_id` per misi supaya tidak dobel poin).
- Tempat belajar: di mana saja di pesantren; sebagian misi mensyaratkan lokasi (mis. di dalam Surau, dekat smartboard, dekat peti) — seperti M2/M3 sekarang.
- Smartboard di Surau menampilkan **3 slide per Bagian** + tombol video (video YouTube dibuka di tab baru — video TIDAK bisa diputar di dalam scene Godot web).

### 4.2 Pengajian Kitab (Khataman) — terjadwal, untuk semua santri

- **Bukan jalur pilihan.** Pengajian kitab adalah sesi baca kitab bersama pada jam-jam tertentu yang diikuti semua santri. Santri tidak memilih antara belajar mandiri dan pengajian — keduanya bagian dari satu sistem yang sama.
- **Khataman:** satu kitab dibaca berurutan dari awal sampai khatam (selesai), sesi demi sesi melanjutkan dari halaman terakhir. Bila satu kitab khatam, sesi berikutnya pindah ke kitab selanjutnya dalam rotasi.
- **Metode bandongan:** ustadz membaca + menjelaskan, santri menyimak dan mencatat. Di game: santri "hadir" sebagai karakternya di Surau (nanti di Ruang Kelas setelah ambang 25 santri), menyimak, lalu kuis singkat (1–3 soal) sesudahnya.
- **Metode sorogan:** santri membaca/menyetorkan satu-satu ke ustadz. Di game: santri "menyetor" (rekam bacaan / jawab lisan — validasi oleh ustadz; teknis setoran menyusul, bukan di tahap ini).
- **Cara ikut:** masuk game beberapa menit sebelum jam sesi; sesi berlangsung di Surau pada jam yang dijadwalkan. Kehadiran tercatat otomatis di Kartu Santri (hadir bila masuk sebelum sesi berakhir dan mengikuti sampai kuis singkat). Kehadiran tampil di kartu; aturan minimal kehadiran untuk naik jenjang masih diputuskan (§9.7).
- **Jadwal yang diusulkan (WIB):**

| Sesi | Jam | Hari | Isi |
|---|---|---|---|
| Ba'da Subuh | 05:00–05:45 | Senin–Jumat | Kitab bergilir (bandongan): Senin Jurumiyah, Selasa Amtsilah Tashrifiyyah, Rabu Safinatun Naja, Kamis Jurumiyah, Jumat Aqidatul Awam |
| Siang | 13:00–13:30 | Senin–Jumat | Muraja'ah materi rantai yang sedang dipelajari + tilawah Al-Quran |
| Ba'da Maghrib | 18:30–19:15 | Senin–Kamis | Kitab adab (bandongan; kitab ditentukan setelah ebook Adab jadi — sementara materi adab dari ustadz) |
| Ba'da Maghrib | 18:30–19:15 | Jumat | Muraja'ah mingguan + tanya jawab dengan ustadz |
| — | — | Sabtu–Ahad | Tidak ada pengajian terjadwal — santri fokus belajar mandiri + Ma'hadiyah |

Catatan: jadwal di atas adalah usulan Tim Materi — jam dan kitabnya perlu ACC Mas (§9.7). Rotasi kitab ba'da Subuh mempertahankan jadwal lama (dulu 08:00, dipindah ke ba'da Subuh karena itu jam pesantren yang wajar).

### 4.3 Ma'hadiyah — wajib untuk semua santri

7 kegiatan harian (sudah ada di game dan app, dipertahankan): tahajjud, subuh berjamaah, dzikir pagi, dhuha, tilawah, lima waktu berjamaah, dzikir petang.

- Dicatat harian di Kartu Santri (checklist 7).
- Syarat naik jenjang (§6): rata-rata **≥5 dari 7 per hari** selama 4 minggu terakhir sebelum naik jenjang.
- Ma'hadiyah TIDAK memberi poin misi — ia memberi status "Santri Aktif" (bukan angka).

### 4.4 Pendaftaran — tanpa pilihan jalur

Saat daftar, santri hanya ditanya identitas — **TANPA pilihan modul atau ngaji**:

- Nama (maks 30 huruf), **gender L/P** (menentukan karakter santriwan/santriwati + asrama putra/putri), kota & email opsional.
- Santri baru langsung masuk di awal rantai: misi pertama N1.1 terbuka, sisanya terkunci sampai lulus berurutan.
- Tidak ada lagi pilihan "Misi" atau "Ngaji Aja" di form pendaftaran (app + game menyesuaikan — implementasi menyusul, sesudah ronde 6).

---

## 5. Pemetaan materi ke game — Nahwu Dasar (Jenjang 0)

Pemetaan di bawah ini adalah **rantai tunggal** sistem pesantren (§4.1): N1.1 → N1.2 → … → N4.T, berurutan dan terkunci.

Skema poin per jenis misi (konsisten di semua Bagian, melanjutkan pola M1=10 / M2=15 / M3=25 yang sudah ada):

| Jenis misi | Isi | Poin |
|---|---|---|
| Misi materi | Baca 1 topik + kuis 1 soal | 10 |
| Misi latihan | Kuis 5 soal dari latihan ebook | 15 |
| Misi hafalan | Kuis bait hafalan (susun/isi bait yang benar) | 10 |
| Misi peti | Penutup Bagian — kuis + buka peti | 25 |
| Tes naik bagian | Kuis 10 soal, lulus bila benar ≥8 | 20 (hanya bila lulus) |

### 5.1 Bagian 1 — Hijau: Mengenal Kata (±25 hari)

Topik ebook: Kalam & tiga jenis kata; Isim; Fi'il; Huruf; cara membedakan dalam 10 detik; Isim mabni & mu'rob; isim-isim yang mabni; mu'rob.

| Kode | Misi | Jenis | Poin | Lokasi / syarat |
|---|---|---|---|---|
| N1.1 | Kenalan dengan Nahwu | Materi | 10 | Di mana saja (M1 yang sudah ada — dipertahankan) |
| N1.2 | Isim — kata benda | Materi | 10 | Smartboard Surau |
| N1.3 | Fi'il — kata kerja | Materi | 10 | Smartboard Surau |
| N1.4 | Huruf — kata sambung | Materi | 10 | Smartboard Surau |
| N1.5 | Mabni atau mu'rob? | Latihan | 15 | Di mana saja |
| N1.6 | Bait hafalan Bagian 1 | Hafalan | 10 | Di mana saja |
| N1.7 | Peti Hijau — memilah satu kalimat utuh | Peti | 25 | Peti Kayu (M3 yang sudah ada — dipertahankan, isinya tetap isim/fi'il/huruf) |
| N1.T | **Tes Naik Bagian 2** (10 soal, lulus ≥8) | Tes | 20 | Di dalam Surau |

**Total Bagian 1: 110 poin.** Milestone server: 25 poin (Penjelajah) tercapai di tengah Bagian 1; 50 poin (Pembuka Peti) di akhir Bagian 1.

> ⚠️ **Koreksi isi M2 yang sudah ada:** M2 saat ini ("Isim marfu' ditandai dhammah", 15 poin) mengajarkan materi **Bagian 4** terlalu dini. Dalam pemetaan ini M2 diganti isinya menjadi **N1.2 (Isim — kata benda)**; materi isim marfu' pindah ke rantai Bagian 4 (N4.1). M1 dan M3 dipertahankan apa adanya.

### 5.2 Bagian 2 — Biru: Isim Lebih Dalam (±25 hari)

Topik ebook: Makrifat & nakiroh; enam jalan menjadi makrifat; mudzakar & muannats; tanda-tanda muannats; jamid & musytaq; keluarga musytaq.

| Kode | Misi | Jenis | Poin | Lokasi / syarat |
|---|---|---|---|---|
| N2.1 | Makrifat & nakiroh | Materi | 10 | Smartboard Surau |
| N2.2 | Mudzakar & muannats | Materi | 10 | Smartboard Surau |
| N2.3 | Jamid & musytaq | Materi | 10 | Di mana saja |
| N2.4 | Golongkan dengan tiga pertanyaan | Latihan | 15 | Di mana saja |
| N2.5 | Bait hafalan Bagian 2 | Hafalan | 10 | Di mana saja |
| N2.6 | Peti Biru — tiga pasang kacamata isim | Peti | 25 | Peti Kayu |
| N2.T | **Tes Naik Bagian 3** (10 soal, lulus ≥8) | Tes | 20 | Di dalam Surau |

**Total Bagian 2: 100 poin. Kumulatif: 210 poin.** Milestone server: 100 poin (Penjaga Lentera) tercapai di akhir Bagian 2.

### 5.3 Bagian 3 — Ungu: Fi'il dan I'robnya (±25 hari)

Topik ebook: Fi'il menurut waktu (madhi/mudhori'/amar); mujarrod & mazid; muta'addi & lazim; ma'lum & majhul; shahih & mu'tal; i'rob fi'il mudhori' (rafa', nashob, jazm).

| Kode | Misi | Jenis | Poin | Lokasi / syarat |
|---|---|---|---|---|
| N3.1 | Fi'il menurut waktu | Materi | 10 | Smartboard Surau |
| N3.2 | Mujarrod & mazid | Materi | 10 | Smartboard Surau |
| N3.3 | Muta'addi & lazim, ma'lum & majhul | Materi | 10 | Di mana saja |
| N3.4 | Shahih & mu'tal | Materi | 10 | Di mana saja |
| N3.5 | I'rob fi'il mudhori' — rafa', nashob, jazm | Latihan | 15 | Di mana saja |
| N3.6 | Bait hafalan Bagian 3 | Hafalan | 10 | Di mana saja |
| N3.7 | Peti Ungu — mesin kalimat | Peti | 25 | Peti Kayu |
| N3.T | **Tes Naik Bagian 4** (10 soal, lulus ≥8) | Tes | 20 | Di dalam Surau |

**Total Bagian 3: 110 poin. Kumulatif: 320 poin.**

### 5.4 Bagian 4 — Oranye: Keadaan Isim (±25 hari)

Topik ebook: Marfu'atul asma'; manshubatul asma'; makhfudzatul asma'; membaca satu kalimat utuh.

| Kode | Misi | Jenis | Poin | Lokasi / syarat |
|---|---|---|---|---|
| N4.1 | Marfu'atul asma' — isim di-rafa' | Materi | 10 | Smartboard Surau |
| N4.2 | Manshubatul asma' — isim di-nashob | Materi | 10 | Smartboard Surau |
| N4.3 | Makhfudzatul asma' — isim di-jer | Materi | 10 | Di mana saja |
| N4.4 | Membaca satu kalimat utuh | Latihan | 15 | Di mana saja |
| N4.5 | Bait hafalan Bagian 4 | Hafalan | 10 | Di mana saja |
| N4.6 | Peti Oranye — kalimat lengkap | Peti | 25 | Peti Kayu |
| N4.T | **Tes Akhir Nahwu Dasar** (10 soal, lulus ≥8) | Tes | 20 | Di dalam Surau |

**Total Bagian 4: 100 poin. Kumulatif Nahwu Dasar: 420 poin.**

### 5.5 Smartboard per Bagian

Smartboard Surau menampilkan 3 slide per Bagian (pola yang sama dengan 3 slide Bagian 1 yang sudah ada — Isim/Fi'il/Huruf):

- Bagian 1: Isim / Fi'il / Huruf (sudah ada).
- Bagian 2: Makrifat / Muannats / Musytaq.
- Bagian 3: Fi'il menurut waktu / Mujarrod–Mazid / I'rob mudhori'.
- Bagian 4: Marfu' / Manshub / Makhfud.
- Tiap Bagian boleh punya 1 video YouTube (tombol di smartboard, dibuka di tab baru; URL diisi bila videonya sudah ada — sekarang masih kosong).

---

## 6. Syarat lulus

### 6.1 Lulus satu Bagian (berlaku untuk semua Bagian 1–4)

1. Semua misi materi + latihan + hafalan Bagian itu selesai.
2. Latihan Bagian benar **≥80%** (boleh mengulang latihan sampai lulus — latihan tidak mengunci).
3. Bait hafalan Bagian itu lulus (kuis bait benar).
4. **Tes Naik Bagian lulus (benar ≥8 dari 10).** Tes boleh diulang; tiap pengulangan memakai bank soal yang sama (10 soal ebook) sampai lulus.

### 6.2 Lulus Jenjang 0 — Kelas Isti'dad (badge "Nahwu Dasar Lulus")

1. Keempat Bagian (1–4) lulus (§6.1).
2. **Tes Akhir Nahwu Dasar lulus (≥8/10)** — ini N4.T.
3. Ma'hadiyah rata-rata **≥5 dari 7 per hari** selama 4 minggu terakhir.
4. Hadiah: **badge "Nahwu Dasar Lulus"** di Kartu Santri + **naik ke Kelas Jurumiyah** (Jenjang 1) + misi Jenjang 1 terbuka.

### 6.3 Lulus satu modul mapel lain (Fiqih/Adab/dst — bila ebooknya sudah ada)

Prinsip yang sama dengan §6.1: baca semua + latihan ≥80% + hafal (bila ada bait/doa) + tes akhir modul ≥8/10. **Dan modul-modul itu juga berurutan dan terkunci** — santri tidak bisa membuka modul berikutnya sebelum modul sebelumnya lulus. Usulan awal titik buka di Jenjang 0: Fiqih Thaharah terbuka setelah Bagian 1 Nahwu lulus; Adab setelah Bagian 2; Fiqih Shalat setelah Bagian 3; Tahsin setelah Bagian 4. Titik buka final ditetapkan saat tiap ebook selesai (§9.7).

---

## 7. Cara materi masuk ke game (mekanik Fase 2)

Yang sudah diputuskan Mas (10:36 WIB): isi ebook menjadi **kitab interaktif di dalam Godot**.

| Mekanik | Isi | Catatan teknis |
|---|---|---|
| Kitab interaktif | Tiap topik ebook jadi 1 halaman kitab di game (teks asli ebook, bukan ringkasan) | Teks Arab butuh font Arab di proyek; PDF tidak bisa di-render di Godot — isi harus di-port jadi data misi (seperti `mission_data.gd`) |
| Rantai tunggal | N1.1 → N1.2 → … → N4.T, berurutan, terkunci sampai sebelumnya selesai | Satu-satunya rantai sistem (§4.1); pola sama dengan M1→M2→M3 sekarang |
| Kuis | 1 soal per misi materi; 5 soal per misi latihan; 10 soal per tes | Bank soal = soal latihan + tes di ebook (sudah ada kunci jawabannya) |
| Peti per Bagian | 1 peti per Bagian (Hijau/Biru/Ungu/Oranye) | Peti Kayu yang sama, isi/warna menyesuaikan Bagian |
| Smartboard | 3 slide per Bagian + video (tab baru) | Slide dari ringkasan Bagian; video URL diisi bila ada |
| Kartu Santri | Progres per Bagian (misi x/y), streak harian, Ma'hadiyah 7, badge | Badge "Nahwu Dasar Lulus" tampil di kartu |
| Poin & server | Poin misi dikirim ke server (event_id per misi, anti-dobel) | Sudah ada endpoint `/api/santri/points`; integrasi game→server masih antre (sesudah ronde 6) |
| Pengajian Kitab (Khataman) | Jadwal §4.2 + centang hadir + kuis singkat sesudah bandongan; sorogan = setoran ke ustadz | Sesi terjadwal untuk semua santri (bukan jalur pilihan); setoran sorogan butuh validasi ustadz — teknis menyusul |
| Ranking | Ranking santri (sudah ada) + ranking per asrama | Ranking per asrama mengikuti struktur kompleks asrama (Asrama A, B, C… — lihat STRUKTUR-ORGANISASI.md §4) |

---

## 8. Materi yang harus dibuat selanjutnya (urutan)

Format tiap ebook baru **meniru Nahwu Dasar v2**: B5, full colour, 4 bagian berwarna, satu topik per halaman, bahasa Indonesia sederhana, teks Arab besar, latihan + kunci + bait/doa hafalan + tes naik bagian, target ±25 hari per bagian, materi orisinal.

| Urutan | Materi | Alasan urutan | Perkiraan isi |
|---|---|---|---|
| 1 | **Ebook Fiqih Dasar — Ibadah** | Fiqih sudah ada di pengajian kitab (Rabu ba'da Subuh, Safinatun Naja) tapi belum ada materi tertulis/misi; santri Isti'dad butuh fiqih ibadah dari hari pertama | Wudhu, shalat, puasa, zakat, haji — 4 bagian (Thaharah, Shalat, Puasa & Zakat, Haji & Muamalah dasar) |
| 2 | **Ebook Shorof Dasar — Tashrif** | Pendamping wajib Nahwu; sudah ada di pengajian kitab (Selasa ba'da Subuh, Amtsilah) | Tashrif fi'il madhi–mudhori'–amar, wazan dasar, latihan tashrif — 4 bagian |
| 3 | **Ebook Adab Santri** | Ringkas, bisa dibuat cepat, dipakai sehari-hari | Adab kepada Allah, ustadz, kitab, teman, masjid, makan/tidur — format pendek, banyak contoh |
| 4 | **Ebook Aqidah Dasar** | Sudah ada di pengajian kitab (Jumat ba'da Subuh, Aqidatul Awam) | 50 aqidah (sifat wajib/mustahil/jaiz) — 4 bagian, hafalan nadhom |
| 5 | **Ebook Sejarah Islam** | Format cerita; bagus untuk konten video juga | Sirah Nabi, Khulafaur Rasyidin, peradaban Islam — timeline + kisah |
| 6 | **Ebook Tahsin & Tilawah** | Butuh audio — dikerjakan setelah format audio game diputuskan | Makhraj, tajwid dasar, tilawah harian; audio OGG per huruf/ayat |
| 7 | **Ebook Nahwu Menengah — Jurumiyah** | Untuk Kelas Jurumiyah (Jenjang 1); dikerjakan setelah Isti'dad lengkap | Jurumiyah bab per bab, orisinal, format sama |

**Sebelum port Fase 2, 4 kaidah ini harus dicek ustadz dulu** (ditandai di ebook Nahwu v2):

1. Muannats samai — daftar muannats tanpa tanda (Bagian 2, hlm. 23).
2. I'lal mu'tal — perubahan bentuk fi'il mu'tal (Bagian 3, hlm. 37).
3. Isim laa nafi jins — rincian syaratnya (Bagian 4, hlm. 47).
4. Rincian munada — mufrad alam vs mudhaf (Bagian 4, hlm. 49).

---

## 9. Yang masih butuh keputusan Mas

1. **4 kaidah "perlu dicek ustadz" (§8)** — siapa ustadz yang memeriksa, dan kapan? Materi Bagian terkait tidak boleh di-port ke game sebelum ini beres.
2. **Struktur kompleks asrama** — untuk ranking per asrama dan pengelompokan santri (nama asrama, pembagian, musyrif per asrama). Sistem regu dihapus Mas 16 Nov 2026 — diganti Asrama A, B, C… (lihat STRUKTUR-ORGANISASI.md §4 dan §13).
3. **Cakupan Kelas Isti'dad** — apakah Isti'dad = Nahwu Dasar + Fiqih + Adab + Tahsin (seperti §2), atau Nahwu saja dulu?
4. **Video pelajaran per Bagian** — siapa yang membuat video smartboard (4 video Nahwu)? Tanpa video, tombol video tetap nonaktif ("Belum ada video").
5. **Setoran sorogan** — bagaimana santri menyetor bacaan ke ustadz dari dalam game (rekam suara? jawab lisan di kelas? tulis?).
6. **Koreksi M2 (§5.1)** — setuju M2 diganti isinya menjadi "Isim — kata benda" dan marfu' pindah ke Bagian 4?
7. **Jadwal khataman + titik buka modul (§4.2, §6.3)** — ACC jam sesi (ba'da Subuh 05:00 / siang 13:00 / ba'da Maghrib 18:30), kitab tiap sesi, dan titik buka modul Fiqih/Adab/Tahsin? Termasuk aturan minimal kehadiran khataman untuk naik jenjang (usulan: ≥60% sesi dalam 4 minggu terakhir — perlu diputuskan).

---

## 10. Ringkasan satu halaman

- **Jenjang:** Isti'dad (100 hari) → Jurumiyah → Imrithi → Kitab Kuning. Tahap ini hanya Isti'dad.
- **Mapel:** Nahwu ✅ → Fiqih → Shorof → Adab → Aqidah → Sejarah → Tahsin.
- **Sistem:** satu jalur berurutan — belajar mandiri di game (§4.1) + pengajian kitab terjadwal (§4.2) + Ma'hadiyah wajib 7/hari (§4.3); pendaftaran tanpa pilihan jalur (§4.4).
- **Nahwu Dasar:** 4 Bagian × ±25 hari = 100 hari; 30 misi + 4 tes; total 420 poin; lulus = baca semua + latihan ≥80% + hafal bait + tes ≥8/10; badge "Nahwu Dasar Lulus" → naik ke Kelas Jurumiyah.
- **Materi berikutnya:** Ebook Fiqih Dasar (Ibadah).
- **Prasyarat port Fase 2:** 4 kaidah dicek ustadz + keputusan Mas §9.
