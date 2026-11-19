# DRAF ALUR MISI — Pesantren Verse

**Tim Alur Game (dibentuk Mas 13:19 WIB, 18 Nov 2026):** Laras (lead, Tim Materi) · Gilang (Tim Maps — lokasi) · Raka (game — kelayakan implementasi) · Zahra (riset kurikulum pesantren)
**Status:** DRAF v4 — misi = Ruang Belajar, baca kitab pindah ke rak kitab (keputusan Mas 15:14 WIB). **JANGAN diimplementasi ke game sebelum Mas ACC.**
**Tanggal:** 18 November 2026 (v1) · revisi v2: 18 November 2026 · revisi v3: 18 November 2026 · revisi v4: 18 November 2026
**Revisi v2:** + gerbang baca kitab kuning (§2.1) · + gelar ala ML (§2.6) · + kuis mingguan & challenge (§2.7) · + event Bahtsul Masail (§2.3) · + olahraga sepak bola (§2.8) · + roadmap terpisah (`ROADMAP-ALUR-MISI.md`). Isi v1 dipertahankan (tangga kitab Sidogiri+Lirboyo, sorogan/bandongan/musyawarah/khidmah, ritme harian, gating ambang).
**Revisi v3:** tangga kitab diselaraskan PERSIS kurikulum MMU Sidogiri — nama + urutan kitab (§1, §2.1, §2.2, §2.3, §2.5, §5, §9, §11); Lirboyo/Gontor/Tebuireng dipindah jadi catatan pembanding saja. Struktur draf (prinsip, mekanik misi, gelar, kuis, bahtsul masail, sepak bola, fase roadmap) TIDAK berubah.
**Revisi v4:** misi = Ruang Belajar (arahan Mas 15:14) — sorogan/bandongan/khataman/setoran PINDAH keluar dari misi ke §2.2 "Rak Kitab & Perpustakaan (bukan misi)"; gerbang diubah jadi kuis kaidah mudah (bukan tes baca); konsep baru Ruang Belajar per mapel (§2.1, model ruang belajar Mantiq, materi Sidogiri, tashih Mas, tim khusus kurikulum DIBENTUK SEKARANG per Mas 15:16); koleksi rak kitab ditambah (batch kurasi); Perpustakaan = gedung ambang 200. Tangga kitab v3, gelar, kuis, bahtsul masail, sepak bola TIDAK berubah.
**Sumber:** `kurikulum/KURIKULUM.md` · `v2/konsep/KONSEP-TATA-LETAK.md` (masterplan, ACC Mas) · `MULTIPLAYER-PLAN.md` · `organisasi/STRUKTUR-ORGANISASI.md` · `organisasi/DESAIN-LAMARAN-PENGURUS.md` · **kurikulum MMU Sidogiri** — daftar kurikulum MMU Ibtidaiyah/Tsanawiyah/Aliyah + Al-Miftah lil Ulum + pengajian ma'hadiyah (sumber: 123dok "Sistem Pendidikan Pondok Pesantren Sidogiri", dibaca penuh Xam 14:58 WIB) · pembanding: riset Zahra 18 Nov 2026 (Lirboyo, Gontor, Tebuireng — sumber web, lihat §1)

**Arahan Mas (13:22 WIB):** *"Saya ingin player serasa belajar pesantren tapi seperti main game... coba pelajari kurikulum pesantren Sidogiri, Lirboyo dll."*

**Arahan Mas (15:14 WIB):** *"Untuk roadmap misi: itu bukan baca kitab ya.. baca kitab cukup di rak kitab.. tambah koleksinya.. nanti kalau santri banyak kita bikin perpustakaan. Misi itu kayak ruang belajar mantiq tadi.. mudah.. materinya diambilkan dari kurikulum sidogiri.. nanti ada tim khusus kurikulum, saya yg tashih."*

---

## 0. Prinsip desain — belajar pesantren, dibungkus game

1. **Tulang punggungnya tangga kitab pesantren salaf sungguhan** (§1) — santri naik tingkat dengan KHATAM KITAB, dari alat baca (nahwu–sharaf) ke kitab yang makin tebal dan makin berdalil. Urutan kitabnya mengikuti kurikulum MMU Sidogiri persis (keputusan Mas 15:01 WIB), bukan karangan tim.
2. **Cara belajarnya: ruang belajar per mapel** — tiap mapel punya satu ruang belajar interaktif (materi singkat + latihan mudah + kuis), modelnya ruang belajar Mantiq; urutannya mengikuti tangga Sidogiri (§1), mulai Nahwu Dasar → Mantiq → Fiqih → dst. Tiap modul mengikuti pola baku: **cari Ustadz (petunjuk di peta) → belajar ke Ustadz → tugas dari Ustadz** (§2.1). **Baca kitab BUKAN misi** — itu aktivitas di rak kitab (§2.2). Musyawarah tetap ujian tertinggi (§2.3).
3. **Dibungkus mekanik game** — misi berantai yang terkunci, poin/XP, naik kelas/jenjang, ranking, streak harian, badge, peti, event terjadwal, ujian kenaikan kelas. Belajarnya sungguhan (materi + kuis dari kitab), hadiahnya terasa seperti main game.
4. **Satu sistem, satu jalur berurutan** (keputusan Mas 15 Nov) — tidak ada pilihan jalur di pendaftaran. Semua santri menempuh rantai yang sama; yang membedakan adalah kecepatan dan ketekunan masing-masing.
5. **Dunia tumbuh bersama santri** — gedung baru terbuka saat ambang santri tercapai (Kelas 25, Masjid Besar 100, Perpus & Taman 200), dan lokasi misi pindah mengikuti gedung (§7). Pesantren yang sepi terasa kecil; pesantren yang ramai terasa besar.
6. **Misi mandiri tetap jalan offline** — progres rantai N tidak digantungkan ke koneksi. Yang server-driven hanya kegiatan serentak (khataman, sholat berjamaah, misi bersama). (Saran Raka.)
7. **Tiap misi punya level dan gelar — seperti Mobile Legends, tapi pesantren.** Tiap santri naik tangga gelar (tier + divisi + bintang) lewat misi, tes, dan kehadiran; gelar tampil di Kartu Santri + label nama. Beda dari ML: gagal kuis tidak menurunkan gelar — di pesantren, gagal itu coba lagi, bukan turun kelas (§2.6).
8. **Ujung belajarnya nyata: bisa baca kitab kuning.** Lulus Jenjang 0 = selesai ruang belajar Nahwu Dasar + lulus gerbang kuis kaidah (§2.1) + baca kitab di rak kitab + setoran ke ustadz (syarat badge 'Bisa Baca Kitab Kuning', §2.2).

**Yang sudah live hari ini (M1–M3):** rantai misi M1→M2→M3 (+10/+15/+25 poin), peti kayu, smartboard 3 slide Bagian 1, jadwal khataman + tombol hadir, Ma'hadiyah 7 checklist di Kartu Santri, sholat berjamaah lokal (adegan takbir + blackout), sistem lamaran pengurus (server v1.4.0), ranking + tier poin (25 Penjelajah / 50 Pembuka Peti / 100 Penjaga Lentera). Semua itu DIPERTAHANKAN dan menjadi fondasi draf ini — bukan dibuang.

---

## 1. Tangga kitab — tulang punggung alur misi (kurikulum MMU Sidogiri, persis — v3)

Tangga di bawah ini = **kurikulum Madrasah Miftahul Ulum (MMU) Sidogiri persis** (keputusan Mas 15:01 WIB): santri baru dikunci dulu pada alat baca (nahwu–sharaf) dan amaliyah dasar, baru naik ke kitab yang makin tebal dan makin berdalil, dan cara belajarnya berubah seiring naik. Sumber tiap baris: daftar kurikulum MMU Ibtidaiyah/Tsanawiyah/Aliyah + Al-Miftah lil Ulum + pengajian ma'hadiyah (123dok "Sistem Pendidikan Pondok Pesantren Sidogiri", dibaca penuh 18 Nov 2026). Lirboyo, Gontor, dan Tebuireng hanya pembanding (lihat catatan pembanding di akhir §1) — bukan tangga utama. Catatan v4: kolom "Cara belajar" di tabel-tabel di bawah = cara belajar **tradisional pesantren** untuk kitab itu; di game semuanya disampaikan lewat **Ruang Belajar (§2.1) + rak kitab (§2.2)**.

### Tahap 0 — Santri Baru (tutorial, ±2–4 minggu game)

Pintu masuk resmi pesantren salaf: **Metode Al-Miftah lil Ulum** (Sidogiri, 4 jilid, tiap jilid ±3 pekan, naik jilid lewat 2 tes: tulis + lisan; target akhir: bisa baca Fathul Qarib dengan dalil nahwu-sharaf + hafal matannya). Isi tiap jilid: Jilid 1 pembagian kalimat + mu'rob-mabni · Jilid 2 ma'rifat-nakiroh + mudzakar-muannats · Jilid 3 kalimat fi'il + mujarrod-mazid · Jilid 4 isim-isim yang dibaca rafa', nashab, jer. Di game, Tahap 0 = **Nahwu Dasar Bagian 1** yang sudah ada (ebook orisinal Pesantren Verse, 4 Bagian × ±25 hari = 100 hari) — isinya setara Al-Miftah: isim/fi'il/huruf → mabni/mu'rob.

| Mapel | Kitab / materi | Cara belajar |
|---|---|---|
| Nahwu (alat baca) | Nahwu Dasar Bag. 1 (ebook PV — setara Al-Miftah Jilid I–IV) | Ruang belajar + baca kitab (rak kitab) |
| Sharaf (alat baca) | Amtsilah Tashrifiyah (mulai dikenalkan) | Sorogan |
| Fiqih amaliyah | Adzkar ash-Shalah → Safinatun Naja (awal) | Bandongan + praktik |
| Tauhid | Aqidatul Awam (awal) | Bandongan |
| Akhlak | Taisir al-Khallaq (awal) | Bandongan |

### Tahap 1 — Ibtidaiyah (dasar)

| Mapel | Kitab (urutan) | Cara belajar |
|---|---|---|
| Nahwu | Jurumiyah → Imrithi → Alfiyah Ibn Malik (mulai kelas VI) | Sorogan → bandongan |
| Sharaf | Amtsilah Tashrifiyah → Nadzm al-Maqsud | Sorogan |
| Fiqih | Adzkar ash-Shalah → Safinatun Naja → Sullam at-Taufiq → Fathul Qarib | Bandongan + sorogan |
| Tauhid | Aqidatul Awam → Kharidah al-Bahiyyah → al-Jawahir al-Kalamiyah → Kifayah al-Awam | Bandongan |
| Akhlak | al-Muntakhabat → Taisir al-Khallaq → at-Tahliyah wa at-Targhib → Ta'lim al-Muta'allim | Bandongan |
| Tajwid | Hidayah ash-Shibyan → Nadzm al-Jazariyyah | Ruang belajar + setor bacaan (rak kitab) |
| Tafsir | Tafsir al-Jalalain | Bandongan |
| Hadits | Arbain Nawawi | Hafalan |
| Tarikh | Khulashah Nur al-Yaqin I–IV | Bandongan |
| I'lal | Qawaid al-I'lal | Bandongan |
| I'rab | Qawaid al-I'rab → Tashil Nail al-Amani | Bandongan |
| Faraid | Tuhfah as-Saniyah → 'Iddaf al-Faridl | Bandongan |
| Falak | Badi'ah al-Mitsal | Bandongan |
| Balaghah | Durus al-Balaghah | Bandongan |

### Tahap 2 — Tsanawiyah (menengah)

| Mapel | Kitab (urutan) | Cara belajar |
|---|---|---|
| Nahwu | **Alfiyah Ibn Malik** — "boss" tahap ini (nadzam ±1.000 bait, dihafal; dimulai kelas VI Ibtidaiyah, berlanjut di Tsanawiyah) | Bandongan + hafalan + musyawarah |
| Fiqih | Tuhfah ath-Thullab | Sorogan + bandongan |
| Tauhid | Umm al-Barahin | Bandongan |
| Tafsir | Tafsir al-Jalalain | Bandongan |
| Hadits | Bulugh al-Maram | Bandongan + hafalan |
| Mantiq | Syarh Sullam al-Munawraq | Bandongan |
| Balaghah | Hilyah al-Lubb al-Mashun | Bandongan |
| Ushul Fiqih | Qurrah al-'Ain bi Syarh Waraqat → Lubb al-Ushul | Bandongan |
| Tarikh | al-Khulafa' ar-Rasyidun | Bandongan |
| Akhlak | 'Idzah an-Nasyiin | Bandongan |
| Falak | Durus al-Falakiyah → Fath ar-Rauf al-Mannan | Bandongan |
| Qaidah Fiqh | al-Farid al-Bahiyah | Bandongan |
| 'Arudl | al-Mukhtashar asy-Syafi | Bandongan |
| Musthalah al-Hadits | Taqrirat as-Saniyah | Bandongan |
| Ilmu Tafsir | al-Iksir | Bandongan |

### Tahap 3 — Aliyah (tinggi / alim)

| Mapel | Kitab (urutan) | Cara belajar |
|---|---|---|
| Fiqih | Fath al-Mu'in (Syafi'i) — + Kanz ad-Daqaiq (Hanafi) + al-Umdah (Hanbali) | Musyawarah |
| Ushul Fiqih | Ghayah al-Ushul | Musyawarah |
| Tauhid | Syarh al-Hikam | Bandongan |
| Balaghah | al-Balaghah al-Wadhihah | Bandongan |
| Tafsir | Muqtathafat at-Tafasir | Bandongan |
| Hadits | Tajrid ash-Sharih | Bandongan |
| Akhlak | Riyadh ash-Shalihin | Bandongan |
| Nahwu | Kifayah al-Habib | Bandongan |
| Tarikh | Tasyri' Syariah Allah al-Khalidah | Bandongan |
| Musthalah al-Hadits | al-Manhal al-Lathif | Bandongan |
| Ilmu Tafsir | Zubdah al-Itqan | Bandongan |
| Penutup | **Khidmah (tugas mengabdi) sebagai syarat ijazah** (Sidogiri) + **musyawarah/bahtsul masail sebagai ujian tertinggi** | Khidmah + musyawarah |

Catatan: Ihya' Ulumiddin dipelajari di pengajian Pengasuh (ma'hadiyah, tiap pagi), bukan di kelas MMU Aliyah — jadi tidak masuk tangga madrasah di atas; di game ia hadir sebagai kitab pengajian Kyai (§2.2).

### Pembanding modern — Gontor (bukan tangga kitab)

Gontor (KMI, 6 tahun reguler / 4 tahun intensif) TIDAK memakai tangga kitab kuning per jenjang — kurikulumnya 4 rumpun (Dirasah Lughawiyah, Islamiyah, Kauniyah, Ammah), klasikal modern, ujian semester, dan "ujian akhir" berupa praktik mengajar (Amaliyat at-Tadris) + baca kitab (Fath al-Kutub) + buka kamus (Fath al-Mu'jam). **Yang diambil dari Gontor untuk game:** sistem "misi harian bahasa" dan "ujian praktik" (praktik mengajar sebagai misi akhir), BUKAN tangga kitabnya. Salaf = naik tingkat dengan KHATAM KITAB; Gontor = naik KELAS per tahun ajaran.

### Pembanding — Lirboyo & Tebuireng (bukan tangga kitab)

Lirboyo: tangga kitabnya mirip Sidogiri (Jurumiyah → Imrithi → Alfiyah; Fathul Qarib → Fathul Mu'in → al-Mahalli sebagai standar musyawarah). Perbedaan yang dicatat: Fiqih Tsanawiyah Lirboyo = Fathul Mu'in (Sidogiri = Tuhfah ath-Thullab); puncak Fiqih Lirboyo = al-Mahalli (Sidogiri = Fath al-Mu'in). Tebuireng: musyawarah adalah "kelas tertinggi". Yang diambil dari tradisi musyawarah pesantren untuk game: format musyawarah + bahtsul masail (§2.3) — bukan urutan kitabnya.

### Pemetaan ke kurikulum Pesantren Verse yang sudah ada

| Jenjang game | Isi | Status |
|---|---|---|
| **Jenjang 0 — Kelas Isti'dad** | Nahwu Dasar 100 hari (4 Bagian, 30 modul ruang belajar + 4 tes, 420 poin) + Fiqih Ibadah Dasar + Adab Santri + Tahsin | Nahwu ✅ ebook jadi; Fiqih/Adab/Tahsin ⏳ ebook belum dibuat |
| **Jenjang 1 — Kelas Jurumiyah** | Nahwu menengah (Jurumiyah) + Shorof dasar (Amtsilah) | ⏳ Peta jalan (kitab Jurumiyah 25 bab SUDAH LIVE di reader server) |
| **Jenjang 2 — Kelas Imrithi** | Nahwu lanjut (Imrithi) + Fiqih (Safinatun Naja) + Aqidah (Aqidatul Awam) | ⏳ Peta jalan (ketiga kitab SUDAH LIVE di reader server) |
| **Jenjang 3 — Kelas Kitab Kuning** | Membaca kitab kuning utuh + Alfiyah (pilihan) | ⏳ Peta jalan |

**Tahap ini yang dibangun: Jenjang 0 saja.** Jenjang 1–3 adalah peta jalan; khataman yang sekarang (Jurumiyah, Amtsilah, Safinatun Naja, Aqidatul Awam) adalah **cicipan** Jenjang 1–2, bukan berarti santri Isti'dad sudah belajar kitab itu penuh. (Kurikulum §2.)

---

## 2. Sistem pesantren jadi misi yang dimainkan

Inti misi sekarang adalah **Ruang Belajar** (§2.1) — satu ruang interaktif per mapel. Baca kitab, khataman, dan setoran BUKAN misi — itu aktivitas di rak kitab (§2.2). Skema poin mengikuti kurikulum §5 (materi 10 / latihan 15 / hafalan 10 / peti 25 / tes 20) — angka di bawah ini USULAN Laras dengan pola yang sama.

### 2.1 Ruang Belajar — inti misi (BARU v4, arahan Mas 15:14)

**Misi = Ruang Belajar.** Tiap mapel punya satu ruang belajar interaktif di dalam dunia — modelnya ruang belajar Mantiq (slide interaktif tasawwur di Asisten Ustadz: materi singkat → latihan → kuis). Sifatnya **MUDAH**: materi singkat, latihan ringan, kuis pengenalan — bukan ujian berat. Santri masuk ruang, belajar satu topik, kerjakan latihan, lulus kuis, dapat poin + bintang gelar.
**Urutan ruang belajar mengikuti tangga Sidogiri v3 (§1):** mulai dari **Nahwu Dasar** (M1–M3 sudah live di game — itu Ruang Belajar Nahwu Bagian 1) → **Mantiq** (ruang belajarnya sudah ada contohnya) → **Fiqih** → Tauhid → Akhlak → dst. Mapel setelah Nahwu Dasar diputuskan di §9 butir 15 (usulan tim: Mantiq).
**Materi dari kurikulum Sidogiri** — tiap modul ruang belajar mengambil materinya dari kitab tangga §1 (bukan karangan tim). **Tashih oleh Mas sendiri** (keputusan 15:14) — semua materi ruang belajar harus lewat tashih Mas sebelum dimuat. **Tim khusus kurikulum DIBENTUK SEKARANG** (keputusan Mas 15:16 — "segera dibentuk, biar ngerjain secara bertahap"): mengerjakan modul satu per satu secara bertahap (satu modul per hari, mulai Nahwu-Sharaf → Mantiq → Fiqih mengikuti tangga Sidogiri); tiap modul selesai langsung dikirim ke Mas untuk tashih. Laras penasihat materi.
**Di game (misi mandiri, rantai N):** santri masuk ruang belajar → materi singkat (slide smartboard) → latihan → kuis → lanjut modul berikut (terkunci berurutan).
- Jenis misi: **Materi** — baca 1 topik + kuis 1 soal — **10 poin** — lokasi: ruang belajar / smartboard.
- Jenis misi: **Latihan** — kuis 5 soal dari latihan ebook — **15 poin**.
- Jenis misi: **Hafalan** — kuis bait hafalan (susun/isi bait yang benar) — **10 poin**.
- Jenis misi: **Peti** — penutup Bagian, kuis + buka peti — **25 poin** — lokasi: Peti Kayu (0,26).
- Jenis misi: **Tes naik bagian** — kuis 10 soal, lulus bila benar ≥8 — **20 poin (hanya bila lulus)** — lokasi: di dalam Surau/Musholla.
- **Status:** rantai M1–M3 ✅ live (pola terkunci + panel misi + kuis 1 soal) sebagai Ruang Belajar Nahwu Bagian 1. BARU: 27 modul lanjutan + mesin kuis 5/10 soal + hafalan + gating Bagian + progres per Bagian di Kartu Santri + badge. (Raka: usaha SEDANG–BESAR.)

### Pola baku tiap modul — cari Ustadz → belajar → tugas (BARU v4, arahan Mas 15:17)

Tiap modul ruang belajar mengikuti 3 langkah yang sama — ini gambaran alur misi yang Mas mau:

1. **Cari Ustadz** — modul dibuka dengan perintah: cari Ustadz pengajar mapel itu. Ada **petunjuk/marker di peta** (peta besar + minimap) yang menunjukkan lokasi Ustadz — santri berjalan ke sana, bukan teleport. Tiap mapel punya Ustadz pengajar + tempat tetapnya sendiri (lokasi mengikuti §6 — mis. Ustadz Nahwu di Surau/Kelas; Ustadz Mantiq menyusul saat modulnya dibuat).
2. **Belajar ke Ustadz** — sampai di Ustadz, terbuka Ruang Belajar: materi singkat (slide) → latihan mudah → kuis. Lulus kuis = modul selesai (poin + bintang gelar).
3. **Tugas dari Ustadz** — habis belajar, Ustadz memberi tugas — misal: suruh baca buku/kitab tertentu di rak kitab (§2.2), hafal bait, atau latihan tambahan. Tugas selesai = modul benar-benar tuntas (poin tugas **5 poin**, usulan — pola misi harian).
- **Ustadz pengajar per mapel** = NPC baru (atau Ustadz yang sudah ada bila mapelnya cocok — Kyai, Ustadzah Mariyah). (Raka: usaha SEDANG — NPC + dialog + marker peta + pelacak tugas.)

**Modul ruang belajar Nahwu Dasar yang sudah dipetakan (kurikulum §5 — dipertahankan apa adanya; tiap modul = 1 misi):**

| Bagian | Misi | Total |
|---|---|---|
| 1 — Hijau: Mengenal Kata (±25 hari) | N1.1 Kenalan dengan Nahwu (M1 ✅) · N1.2 Isim · N1.3 Fi'il · N1.4 Huruf · N1.5 Latihan mabni/mu'rob · N1.6 Hafalan · N1.7 Peti Hijau (M3 ✅) · N1.T Tes Naik Bagian 2 | 110 poin |
| 2 — Biru: Isim Lebih Dalam (±25 hari) | N2.1 Makrifat & nakiroh · N2.2 Mudzakar & muannats · N2.3 Jamid & musytaq · N2.4 Latihan · N2.5 Hafalan · N2.6 Peti Biru · N2.T Tes Naik Bagian 3 | 100 poin |
| 3 — Ungu: Fi'il dan I'robnya (±25 hari) | N3.1 Fi'il menurut waktu · N3.2 Mujarrod & mazid · N3.3 Muta'addi & lazim, ma'lum & majhul · N3.4 Shahih & mu'tal · N3.5 I'rob mudhori' · N3.6 Hafalan · N3.7 Peti Ungu · N3.T Tes Naik Bagian 4 | 110 poin |
| 4 — Oranye: Keadaan Isim (±25 hari) | N4.1 Marfu'atul asma' · N4.2 Manshubatul asma' · N4.3 Makhfudzatul asma' · N4.4 Membaca kalimat utuh · N4.5 Hafalan · N4.6 Peti Oranye · N4.T Tes Akhir Nahwu Dasar | 100 poin |
| **Total Nahwu Dasar** | **30 misi + 4 tes** | **420 poin** |

### Gerbang ruang belajar Jenjang 0 — kuis kaidah yang mudah (DIUBAH v4, arahan Mas 15:14)

Gerbang BUKAN tes baca kitab — baca kitab dibuktikan lewat rak kitab + setoran (§2.2). Setelah N4.T, terbuka **Gerbang Ruang Belajar** (lokasi: di dalam Surau/Musholla): **kuis kaidah Nahwu Dasar yang MUDAH** — pengenalan kaidah yang sudah dipelajari di 4 Bagian (mis. tentukan isim/fi'il/huruf, tentukan i'rob marfu'/manshub/makhfudh), 10 soal pilihan ganda, lulus ≥8/10. Gagal = ulangi kuisnya saja, bukan dari awal.
- Hadiah lulus gerbang: naik ke Kelas Jurumiyah (Jenjang 1). Badge **"Bisa Baca Kitab Kuning"** tetap ada, tapi syaratnya BUKAN gerbang ini — syarat badge: (a) ruang belajar Nahwu Dasar selesai (4 Bagian + gerbang lulus), (b) baca kitab di rak kitab (§2.2 — jumlah bab **butuh ACC Mas, jangan dikarang**), (c) setoran baca kitab ke ustadz (Fase C). Tiga syarat itu ditanyakan ke Mas di §9 butir 12.
- **Catatan jujur (Raka):** kuis pilihan ganda hanya menguji *pengenalan* kaidah, bukan kemampuan membaca sungguhan. Bukti baca yang jujur adalah baca di rak kitab + **setoran ke ustadz** (santri membaca di depan ustadz/musyrif) — itu usaha BESAR, Fase C. Gerbang kuis di Fase A adalah langkah pertama, bukan pengganti setoran.
- Syarat lulus Jenjang 0 di §5 diperbarui: 4 Bagian ruang belajar + gerbang ini + baca kitab di rak kitab + setoran (Fase C) + Ma'hadiyah.

Catatan: M2 saat ini mengajarkan materi Bagian 4 terlalu dini (isim marfu'). Kurikulum mengusulkan M2 diganti isinya menjadi N1.2 dan marfu' pindah ke N4.1 — **DITUNDA per Mas 13:21 (item 16, skip dulu, jangan ditanya lagi untuk sekarang).** Draf ini mencatatnya apa adanya tanpa meminta keputusan.

### 2.2 Rak Kitab & Perpustakaan — BUKAN misi (BARU v4, arahan Mas 15:14)

**Baca kitab cukup di rak kitab.** Sorogan, bandongan, khataman, dan setoran adalah aktivitas baca — bukan misi. Di game, semuanya terjadi di **rak kitab (reader Tara)**: santri membuka kitab, membaca, menyimak pengajian — tanpa poin misi. Yang dicatat hanya **kehadiran** (untuk status Santri Aktif / Ma'hadiyah) dan **jejak baca** (bab yang sudah dibaca — dipakai sebagai syarat badge "Bisa Baca Kitab Kuning", §2.1).
**Di pesantren sungguhan:** kyai baca–terjemah (Pegon)–terangkan kitab, santri menyimak kitab yang sama + mencatat makna (halaqah, 5–500 santri). Cara belajar utama Sidogiri (ma'hadiyah) — di Sidogiri, Fath al-Mu'in disorogankan (pengajian ma'hadiyah).
- **Rak kitab (sudah live):** reader interaktif — 5 kitab server (Jurumiyah 25 bab, Safinatun Naja 66, Imrithi 34, Abi Shuja 17, Arba'in Nawawi 42; 184 bab, semua `dicek_ustadz`) + Chairil Anwar 6 bab + Atlas 6 halaman. Titik rak: 2 Surau + 2 Musholla + 2 Kelas Putri (radius interaksi 3 m).
- **Khataman terjadwal (aktivitas baca, bukan misi):** sesi baca kitab bersama — santri hadir sebagai karakternya di Surau/Musholla, menyimak (bandongan), membaca bersama. Jadwal LIVE: 05:00 Jurumiyah · 13:00 Amtsilah Tashrifiyyah · 18:30 Safinatun Naja (60 menit, tombol "Hadir Khataman Hari Ini" + centang hadir tersimpan lokal). **Perubahan v4: khataman tidak lagi memberi poin misi 10** — kehadiran tetap tercatat (Santri Aktif), dan kuis singkat pasca-bandongan pindah menjadi bagian modul ruang belajar mapel terkait (§2.1). Usulan kurikulum §4.2 (rotasi harian + sesi siang + Maghrib kitab adab + Jumat tanya jawab + Sabtu–Ahad libur): **DITUNDA per Mas 13:21 (item 14, jadwal khataman + aturan kehadiran — skip dulu).** Draf ini memakai jadwal LIVE.
- **Koleksi rak kitab DITAMBAH (batch berikut — butuh ACC Mas, §9 butir 16):** antrean kurasi yang sudah ada — Azab dan Sengsara, Sengsara Membawa Nikmat, Habis Gelap Terbitlah Terang, Hikayat Hang Tuah (sastra klasik, domain publik) — ditambah 5 kitab server yang sudah di reader. Koleksi bertambah bertahap, bukan sekaligus.
- **Perpustakaan (bangunan, nanti):** kalau santri sudah banyak, koleksi rak kitab pindah ke **Perpustakaan & Taman (0,20) — gedung di ambang 200 santri** (masterplan, tidak berubah). Bukan sekarang — sekarang rak kitab tetap di Surau/Musholla/Kelas. Khidmah perpustakaan (§2.4) tetap jalan setelah gedung ada.
- **Setoran baca kitab ke ustadz:** santri membaca di depan ustadz/musyrif — ini bukti kemampuan baca yang jujur (syarat badge, §2.1) — usaha BESAR, Fase C.
- **Status:** reader + jadwal khataman + tombol hadir ✅ live (lokal saja). BARU: tambah koleksi batch berikut + jam server + kirim kehadiran khataman ke server + sesi baca bersama sebagai karakter. (Raka: usaha SEDANG. Setoran ke ustadz sungguhan = BESAR, Fase C.)

### 2.3 Musyawarah — diskusi kelompok (debat, menguji)

**Di Sidogiri:** musyawarah kitab kuning anggota Kuliah Syariah tiap malam 21.00–22.00. Kitab yang dibahas di musyawarah game: Fathul Mu'in dan Fathul Qarib (keduanya kitab Sidogiri). al-Mahalli adalah standar musyawarah Lirboyo (pembanding) — tidak dipakai di tangga Sidogiri. Bahtsul Masail (forum masalah fiqih, tingkat MTs/MA + antar-pondok) diadaptasi dari tradisi musyawarah pesantren — formatnya di bawah, bukan jiplakan satu pondok. **Musyawarah adalah ujian tertinggi pesantren salaf — bukan kelas biasa.**
**Di game (Tahap 2–3, setelah Alfiyah):**
- Jenis misi: **Musyawarah mingguan** — kelompok santri membahas satu masalah fiqih (soal dari kitab), tiap santri menyampaikan pendapat + dalil, lalu musyawarah memutuskan — **15 poin** (usulan) — lokasi: Kelas / Masjid Besar (setelah ambang).
- Jenis misi: **Bahtsul Masail (event bulanan + Musyawarah Besar semesteran)** — satu masalah fiqih besar, musyawarah terbuka antar asrama — **25 poin** (usulan) — lokasi: Surau/Musholla terpisah per area (sebelum ambang 100) → Masjid Besar (setelah 100); Aula (0,52) sebagai jembatan bila dibangun.
  - **Format (dari tradisi pesantren sungguhan, dipadatkan untuk game):** (1) Persiapan — masalah diumumkan ±2 minggu sebelum event, peserta *muthala'ah* (baca kitab dulu); (2) Pembukaan + *tashawwur* masalah oleh moderator; (3) Musyawarah inti — tiap kelompok menyampaikan jawaban + *ta'bir* (kutipan dalil dari kitab), kelompok lain boleh menyanggah; (4) Perumusan — Tim Perumus menyusun rumusan jawaban; (5) Pengesahan — *mushahhih* (Kyai) mengesahkan putusan. Satu masalah, satu sesi ±30–45 menit (forum sungguhan ±3 jam — dipadatkan, bukan ditiru mentah).
  - **Peran:** moderator (musyrif/ustadz) · muharrir/perumus (santri senior) · **mushahhih = Kyai** (Mas) · musyawirin (santri Tahap 2–3) · notulen.
  - **Syarat ikut:** lulus Tahap 1 (Ibtidaiyah) — sama seperti musyawarah mingguan. Hadiah: 25 poin + badge event.
  - **Risiko (Raka): penilaian manusia adalah bottleneck, bukan kode** — tanpa musyrif/Kyai yang hadir menilai di jam event, ini jadi diskusi tanpa penutup dan tanpa skor. Pastikan penilai + antarmukanya sebelum bangun (Fase C).
- Syarat buka: lulus Tahap 1 (Ibtidaiyah) — musyawarah tidak dibuka untuk santri baru (sesuai pesantren: musyawarah itu kelas tertinggi).
- **Status:** BARU total — mekanik diskusi kelompok + vote belum dirancang. Chat teks (Fase 2 multiplayer) adalah prasyaratnya. (Raka: usaha SEDANG–BESAR.)

### 2.4 Khidmah — tugas pengurus (mengabdi)

**Di pesantren sungguhan:** lulus Tsanawiyah Sidogiri → **wajib tugas/khidmah dulu** sebagai syarat pengambilan ijazah, baru boleh lanjut ke Aliyah. Masa khidmah 1 tahun (usulan organisasi). Jabatan: Keamanan, Ubudiyah, Kebersihan, Pendidikan, Humas & Media (5 posisi lamaran, DI-ACC Mas 16 Nov).
**Di game:**
- Jenis misi: **Khidmah harian** — piket kebersihan (taman/jalan/masjid/lapangan), jaga pos (pos satpam + 4 pos jaga), bantu dapur/koperasi/perpustakaan — **5 poin/hari** (usulan) — lokasi: sesuai tugas (§7).
- Jenis misi: **Lamaran pengurus** — syarat M1 selesai (M1 = N1.1, tetap valid) → lamar 1 posisi → Musyrif → Pengasuh → dilantik (acara di Musholla/Surau) — **badge jabatan di Kartu Santri + label nama** — masa khidmah 1 tahun.
- Jenis misi: **Voting Ketua Asrama / Kepala Kamar** — santri memilih lewat vote/komen — **status: BELUM dirancang** (organisasi §13 butir 5 masih terbuka: vote atau tunjuk musyrif — ditunda, bukan pertanyaan ke Mas sekarang).
- **Status:** server lamaran v1.4.0 ✅ SUDAH ADA (tabel + endpoint + alur Musyrif→Pengasuh). BARU di game: pengumuman pelantikan + label jabatan di nama + form lamaran di app. (Raka: usaha SEDANG; game = kecil, voting = sedang–besar.)

### 2.5 Hafalan — muhafadhah (takrar nadham)

**Di pesantren sungguhan:** takrar nadham tiap pagi 06.30–06.45 (Sidogiri, kelas I–V); hafalan nadzam Alfiyah (±1.000 bait) sebagai syarat tahap; target hafal Matan Fathul Qarib (target akhir Al-Miftah). Tahfidz Qur'an di Sidogiri dikoordinir TTQ (Ta'limiyah wa Tahfidz al-Qur'an) — jenjang/tahapan tahfidznya belum terverifikasi dari sumber, ditandai (bukan pola MMQ Lirboyo).
**Di game:**
- Jenis misi: **Hafalan bait** (tiap Bagian Nahwu punya 1 bait hafalan — sudah di kurikulum §5) — **10 poin**.
- Jenis misi: **Hafalan nadzam Alfiyah** (Tahap 2, dicicil per 10 bait) — **10 poin per cicilan** (usulan).
- Jenis misi: **Tahfidz Qur'an** (koordinasi TTQ Sidogiri) — **badge per tingkat** (usulan, Tahap 3; rincian tingkat tahfidz Sidogiri belum terverifikasi — ditandai, jangan pakai pola MMQ Lirboyo).
- **Status:** mekanik hafalan (susun/isi bait) BARU — nol. (Raka: bagian dari usaha BESAR konten.)

### 2.6 Gelar — level game ala Mobile Legends (BARU v2, arahan Mas 13:30)

**Pola yang dipinjam dari ML (riset Zahra):** tangga bertingkat, tiap tingkat punya sub-level (divisi) yang naik dengan bintang; meter bonus dari performa bagus; di puncak, divisi hilang diganti satu angka berjalan; reset musiman parsial supaya tangga tidak mati. **Nama tier-nya pesantren, bukan jiplakan ML.**

| Tier | Nama gelar | Divisi | Bintang/divisi | Dibuka oleh |
|---|---|---|---|---|
| 1 | Thalib al-'Ilm (Penuntut Ilmu) | III–I | 3 | Daftar (santri baru) |
| 2 | Mubtadi' (Pemula) | III–I | 3 | Lulus Bagian 1 |
| 3 | Mutawassith (Menengah) | IV–I | 4 | Lulus Bagian 2 |
| 4 | Mutamayyiz (Mahir) | IV–I | 4 | Lulus Bagian 3 |
| 5 | Muntahi (Tingkat Akhir) | V–I | 5 | Lulus Bagian 4 + gerbang ruang belajar |
| 6 | Faqih (Ahli Fiqih) | V–I | 5 | Lulus Tahap 1 (Ibtidaiyah) |
| 7 | 'Alim (Orang Berilmu) | V–I | 5 | Lulus Tahap 2 (Tsanawiyah) |
| 8 | 'Allamah (Sangat Berilmu) ⭐ | tanpa divisi — poin berjalan (25/50/100) | — | Lulus Tahap 3 (Aliyah) |

**Cara dapat bintang:** selesaikan 1 misi = 1 bintang · lulus tes naik Bagian = 2 bintang · Ma'hadiyah ≥5/7 dalam seminggu = 1 bintang · menang kuis mingguan / duel / bahtsul masail = 1 bintang.
**Yang beda dari ML (sengaja):** gagal misi/kuis TIDAK mengurangi bintang — di pesantren, gagal itu coba lagi, bukan turun kelas. Gelar tidak turun karena satu kegagalan; yang ada hanya **reset musiman parsial** (tiap ±3 bulan, turun 1–2 divisi, bukan ke nol — seperti reset season ML) supaya tangga tetap hidup.
**Tampil di mana:** Kartu Santri (dashboard + gelar besar) · label nama pemain (ikut aturan keterbacaan mode Drone, §7) · ranking.
**Catatan (Zahra):** 'Allamah/Musnid di dunia nyata adalah gelar ulama besar yang sangat tinggi dan langka — menaruh 'Allamah sebagai puncak justru pas secara rasa (sulit dicapai = prestisius), tapi kepantasannya memakai gelar ulama untuk game perlu dikunci Mas (§9 butir 10). Alternatif bila Mas keberatan: puncak diganti "Kyai Muda" atau "Alim Pesantren Verse".

### 2.7 Kuis mingguan + challenge antar player (BARU v2, arahan Mas 13:30 — butuh multiplayer)

**Kuis Mingguan Serentak** — tiap pekan, satu sesi serentak (usulan: Sabtu 09:00 WIB, ±30 menit, 10 soal, soal sama untuk semua peserta). Dua sesi paralel per area (putra di Surau/Kelas Putra, putri di Musholla/Kelas Putri — tidak bisa satu ruangan fisik, disinkronkan jam server). Papan skor sesi + papan skor mingguan (7 hari, varian dari `GET /api/ranking`). Hadiah: 3 besar 10 poin + badge "Juara Kuis Pekan Ini" · partisipasi 5 poin · pemenang +1 bintang gelar.
**Duel 1 lawan 1** — santri menantang santri lain duel kuis (5 soal, cepat + benar yang menang; matchmaking dalam satu server/ruangan). Pemenang +5 poin + 1 bintang gelar; kalah tidak minus gelar. Prasyarat: chat teks + multiplayer stabil.
**Tantangan Hafalan** — tantangan hafalan bait/ayat antar santri (mingguan; dinilai otomatis susun bait dulu, validasi ustadz menyusul).
**Prasyarat (Raka):** T1 multiplayer lolos → jalur poin game→server → jam server → chat teks → cap 50 teruji beban (T5). Tanpa jam server, "serentak" itu pura-pura; soal kuis mingguan harus datang dari server saat sesi mulai, bukan tersimpan di game (soal di tangan klien bisa dibocorkan).
**Fase:** kuis mingguan di Fase B · duel + tantangan hafalan di Fase C.

### 2.8 Olahraga — sepak bola antar santri (BARU v2, arahan Mas 13:30 — fitur TERBESAR, Fase D)

**Cabang pertama yang dikunci: SEPAK BOLA (mini soccer).** "Dll" (voli, lari, dsb) DITUNDA sampai sepak bola jalan — tanpa batas, cabang mengembang tanpa ujung (Raka).
**Format (dari tradisi pesantren sungguhan, riset Zahra):** liga antar asrama/kelas, musiman — menyambut Hari Santri Nasional (22 Oktober) + semesteran; tim putra vs putra, putri vs putri (terpisah, zona gender tetap); mini soccer 5 lawan 5, 2×10 menit; hadiah = poin + trofi + badge (bukan uang — di dunia nyata hadiahnya uang pembinaan + trofi + medali + sertifikat; di game diganti poin + trofi + badge). Narasi: pembinaan + sportivitas + silaturahmi, bukan sekadar kompetisi.
**Aturan main (usulan):** daftar tim per asrama/kelas → jadwal liga → pertandingan di lapangan → gol + skor + klasemen → juara liga dapat trofi + badge "Juara Liga Santri" + poin tim. Wasit: musyrif/NPC (diputuskan di §9).
**Yang dibutuhkan (Gilang + Raka):** Lapangan Putra (−30,50) — lahan sudah ada, yang kurang: 2 gawang + garis lapangan + bola + lampu lapangan (prioritas TINGGI, bisa dibangun sebagai venue di Fase A — tanpa mekanik). Lapangan Putri (198,12) masih DITUNDA (keputusan 13:19, bareng Asrama ke-2) — olahraga putri sementara hanya voli/lari ringan di halaman/taman (128,−12). Mekanik (Fase D): bola + fisika tendang/giring (tidak ada satu pun RigidBody3D di proyek sekarang) + mode permainan terpisah + otoritas server atas bola + tim + skor.
**Catatan jujur (Raka):** ini fitur TERBESAR dari 5 arahan Mas. Risiko terbesar: **desync bola** — satu bola dihitung di tiap HP = posisi berbeda di tiap layar; butuh otoritas server atas bola. Plus beban HP 20+ pemain bergerak cepat + fisika. Jangan mulai sebelum multiplayer stabil (Fase C selesai).

---

## 3. Ritme harian — loop harian game (seperti pesantren sungguhan)

Ritme harian pesantren salaf selalu sama di mana-mana (riset Zahra): **tahajud–Subuh berjamaah → ngaji pagi → madrasah siang → Ashar → ngaji sore → Maghrib (Qur'an) → Isya → musyawarah/wajib belajar malam.** Ritme inilah loop harian game:

| Waktu (WIB) | Kegiatan di game | Jenis | Poin |
|---|---|---|---|
| 03:30–04:30 | Tahajud (Ma'hadiyah) | Checklist harian | — (status Santri Aktif) |
| 04:30 | **Subuh berjamaah** (event waktu, Kyai/Ustadzah imam) | Event serentak | 5 (usulan, bila hadir) |
| 05:00–05:45 | **Khataman ba'da Subuh** (Jurumiyah — aktivitas baca, rak kitab §2.2) | Aktivitas baca | — (kehadiran tercatat) |
| 06:30 | Takrar nadham / hafalan pagi | Misi harian | 5 (usulan) |
| 08:00–11:00 | Belajar mandiri — modul ruang belajar (§2.1) | Misi utama | 10/15/25 |
| 12:00 | **Dzuhur berjamaah** (event waktu) | Event serentak | 5 (usulan) |
| 13:00–13:30 | **Khataman siang** (Amtsilah — muraja'ah + tilawah, rak kitab §2.2) | Aktivitas baca | — (kehadiran tercatat) |
| 15:00 | **Ashar berjamaah** (event waktu) | Event serentak | 5 (usulan) |
| 15:30–17:00 | Belajar mandiri (ruang belajar) / khidmah (piket sore) | Misi utama / khidmah | 10/15 · 5 |
| 18:00 | **Maghrib berjamaah** (event waktu) | Event serentak | 5 (usulan) |
| 18:30–19:15 | **Khataman ba'da Maghrib** (Safinatun Naja — aktivitas baca, rak kitab §2.2) | Aktivitas baca | — (kehadiran tercatat) |
| 19:00 | **Isya berjamaah** (event waktu) | Event serentak | 5 (usulan) |
| 20:00–21:00 | Musyawarah / wajib belajar malam (Tahap 2–3) | Misi mingguan | 15 |
| Jumat | **Sholat Jumat** (gabung, sekat tengah — setelah Masjid Besar ada; sementara Surau/Musholla terpisah) | Event mingguan | 10 (usulan) |

**Ma'hadiyah 7/hari** (tahajjud, subuh berjamaah, dzikir pagi, dhuha, tilawah, lima waktu berjamaah, dzikir petang) — checklist di Kartu Santri, syarat naik jenjang: rata-rata **≥5 dari 7 per hari** selama 4 minggu terakhir. Ma'hadiyah TIDAK memberi poin misi — ia memberi status "Santri Aktif". ✅ checklist + streak sudah live (lokal saja).
**Streak harian** (sudah ada di Kartu Santri) + **ranking** (sudah ada) + **ranking per asrama** (baru — mengikuti struktur kompleks asrama).

---

## 4. Misi harian / mingguan / event

| Jenis | Isi | Frekuensi | Poin |
|---|---|---|---|
| **Misi rantai (utama)** | N1.1 → N4.T berurutan, terkunci (modul ruang belajar, §2.1) | Kapan saja (mandiri) | 10/15/25/20 |
| **Misi harian** | Sholat berjamaah 5 waktu · takrar pagi · khidmah piket · tilawah | Harian | 5 per kegiatan (usulan) |
| **Misi mingguan** | Musyawarah (Tahap 2–3) · muraja'ah mingguan (Jumat) · tanya jawab ustadz | Mingguan | 15 |
| **Aktivitas baca terjadwal** | Khataman 3×/hari (rak kitab §2.2) — bukan misi | Terjadwal | — (kehadiran tercatat) |
| **Event terjadwal** | Sholat Jumat · khataman akbar · pelantikan pengurus | Terjadwal | 10–25 |
| **Event musiman** | Khataman akbar (kitab khatam) · wisuda/takhtiman (khatam 30 juz) · Musyawarah Besar (semesteran) · pelantikan pengurus baru (tahunan) | Musiman | 25 + badge (usulan) |
| **Kuis mingguan** | Kuis serentak 10 soal (Sabtu 09:00, usulan) + duel 1v1 + tantangan hafalan | Mingguan | 10 (juara) · 5 (partisipasi) · duel 5 (usulan) |
| **Bahtsul Masail** | Event bulanan: masalah fiqih → musyawarah kelompok → putusan Kyai | Bulanan (+ besar semesteran) | 25 + badge (usulan) |
| **Liga sepak bola** | Liga antar asrama/kelas (musiman, Hari Santri) — Fase D | Musiman | Poin tim + trofi + badge (usulan) |
| **Misi eksplorasi** | Kunjungi sawah/kebun/kolam/lapangan/taman (Sejarah Islam — sirah + peradaban, format cerita + timeline) | Sekali per lokasi | 5 (usulan) |

---

## 5. Progresi — santri baru sampai lulus

| Tahap | Syarat masuk | Syarat lulus | Hadiah |
|---|---|---|---|
| **Santri Baru** (daftar) | Daftar (nama + gender) → langsung dapat kasur (1 santri = 1 kasur) → misi N1.1 terbuka | — | Kartu Santri |
| **Tahap 0 — Isti'dad** (Nahwu Dasar) | N1.1 terbuka | 4 Bagian ruang belajar lulus (baca semua + latihan ≥80% + hafal bait + tes ≥8/10) + **gerbang ruang belajar (kuis kaidah ≥8/10)** + baca kitab di rak kitab + setoran ke ustadz (Fase C; syarat badge — jumlah bab butuh ACC Mas, §9 butir 12) + Ma'hadiyah ≥5/7 selama 4 minggu terakhir | Badge **"Nahwu Dasar Lulus"** + badge **"Bisa Baca Kitab Kuning"** + naik ke Kelas Jurumiyah |
| **Tahap 1 — Ibtidaiyah** | Lulus Isti'dad + ambang Kelas 25 tercapai (gedung Kelas terbuka) | Selesai modul ruang belajar Jurumiyah + Imrithi + Fathul Qarib + ujian kenaikan | Badge + naik ke Tsanawiyah |
| **Tahap 2 — Tsanawiyah** | Lulus Ibtidaiyah + ambang Masjid Besar 100 tercapai | Selesai modul ruang belajar Alfiyah (hafal nadzam) + Tuhfah ath-Thullab + Umm al-Barahin + Bulugh al-Maram + ujian kenaikan | Badge + naik ke Aliyah |
| **Tahap 3 — Aliyah** | Lulus Tsanawiyah + ambang Perpus 200 tercapai | Selesai modul ruang belajar Fath al-Mu'in + Ghayah al-Ushul + Syarh al-Hikam + musyawarah/bahtsul masail + **khidmah sebagai syarat ijazah** | Badge **"Alim"** + ijazah + jabatan pengurus |

**Tier poin server (sudah ada, dipertahankan):** ≥25 Penjelajah · ≥50 Pembuka Peti · ≥100 Penjaga Lentera. Milestone: 25 poin tercapai di tengah Bagian 1 · 50 di akhir Bagian 1 · 100 di akhir Bagian 2.
**Gating ambang bangunan (masterplan §1.7):** Kelas 25 per gender · Masjid Besar 100 total · Perpustakaan & Taman 200 total · Asrama = cangkruk penuh (10 kasur), bukan ambang santri.

---

## 6. Lokasi misi — peta (Gilang, dari masterplan ACC + status live)

Semua koordinat disalin dari `KONSEP-TATA-LETAK.md` — tidak ada yang dikarang. Status: ✅ sudah 3D di game live · 🟡 hanya lahan/papan/plot · ❌ masih rencana (peta saja). Peta v2 (U1–U5) masih KONSEP — pergeseran bangunan ditunda di v2 alpha, jadi game live masih di posisi v1 untuk bangunan yang digeser.

### 6.1 Lokasi tiap kelompok misi

| Kelompok misi | Lokasi (putra / putri) | Koordinat | Status |
|---|---|---|---|
| Belajar Nahwu di smartboard (N1.2–N1.4, N2.1–N2.2, N3.1–N3.2, N4.1–N4.2) | Smartboard Surau / Smartboard Musholla Ar-Raudhah | (0,−14) / (134,−24) | ✅ (slide Bag. 1 ✅; slide Bag. 2–4 belum dibuat) |
| Misi "di mana saja" (N1.1, latihan, hafalan) | Bebas di pesantren | — | ✅ |
| Tes naik bagian (N1.T–N4.T) | Di dalam Surau / Musholla | (0,−14) / (134,−24) | ✅ |
| Peti per Bagian (Hijau/Biru/Ungu/Oranye) | Peti Kayu M3 (satu peti, isi/warna menyesuaikan Bagian) | (0,26) | ✅ (M3 live; tidak ada 4 peti terpisah) |
| Aktivitas baca: khataman / pengajian kitab (rak kitab §2.2 — bukan misi) | Surau / Musholla | (0,−14) / (134,−24) | ✅ (tempat + reader ada; setoran ke ustadz ❌ Fase C) |
| Sholat 5 waktu berjamaah harian | Surau (Kyai imam) / Musholla (Ustadzah imam) | (0,−14) / (134,−24) | ✅ |
| Sholat Jumat + tarawih (gabung, sekat tengah) | Masjid Besar (pusat) | (64,−24) masterplan | ❌ MASIH RENCANA — sementara Jumat di Surau/Musholla terpisah ✅ |
| Praktik wudhu (putra) | Tempat Wudhu (Surau) | (−16,−8) masterplan | ❌ MASIH RENCANA |
| Praktik wudhu (putri) | Sisi Musholla/Kelas Putri | **belum ada di masterplan** — hanya Wudhu Putri Masjid Besar (98,−6) | ❌ MASIH RENCANA — lubang peta, lihat §9 |
| Praktik shalat | Surau / Musholla | (0,−14) / (134,−24) | ✅ |
| Pengajian kitab adab | Surau / Musholla | (0,−14) / (134,−24) | ✅ |
| Misi adab harian | Surau/Musholla, Perpus & Taman, Kantin | (0,−14) / (134,−24) / (0,20) / (0,40) | 🟡 Perpus baru lahan + papan; Kantin ❓ status 3D belum terverifikasi |
| Khidmah kebersihan | Taman (0,28), Surau, Musholla, Lapangan Putra (−30,50) | — | ✅ (kecuali Taman Surau, rencana) |
| Khidmah keamanan (jaga pos) | Pos Satpam (17,5); Pos Jaga TL/BL/BD/TG | — | ✅ (4 pos jaga + pos satpam) |
| Khidmah dapur | Dapur Umum | (16,36) masterplan | ❌ MASIH RENCANA |
| Khidmah koperasi | Koperasi / Toko Santri | (−10,32) masterplan | ❌ MASIH RENCANA |
| Khidmah perpustakaan | Perpustakaan & Taman | (0,20) | 🟡 lahan + papan + taman saja — gedung ❌ belum ada |
| Eksplorasi Sejarah | Sawah (60,30) · Kebun (100,30) · Kolam (100,60) · Lapangan Putra (−30,50) · Gunung (latar) | — | ✅ |
| Lapangan Putri | (198,12) (U4) | — | ❌ DITUNDA (keputusan 13:19: nanti, bareng Asrama ke-2) |
| Event besar (khataman akbar, pelantikan) | Aula (sementara) → Masjid Besar (setelah ambang 100) | (0,52) / (64,−24) | Aula ❓ status 3D belum terverifikasi; Masjid ❌ rencana |
| Tamu / wali santri | Balai Tamu | (12,74) masterplan | ❌ MASIH RENCANA |

### 6.2 Gating ambang — perpindahan lokasi misi

| Ambang | Yang pindah | Dari → Ke |
|---|---|---|
| **< 25 santri** (sekarang: 3 santri terdaftar) | Semua belajar + khataman + tes | Surau (0,−14) putra / Musholla (134,−24) putri — tidak pindah |
| **25 per gender** | Ruang belajar Jenjang 1 (Kelas Jurumiyah) + khataman (aktivitas baca) | Surau/Musholla → **Ruang Kelas**: Kelas Putra (−44,−14) / Kelas Putri (128,10) masterplan — gedung 5 lantai + lift + eskalator |
| **100 total** | Ruang belajar Jenjang 2 (Kelas Imrithi) + sholat Jumat + khataman akbar + event besar | Kelas → **Masjid Besar (64,−24)** (putra sayap barat x 37–64, putri sayap timur x 64–91, sekat tengah; pintu putra x≈48, pintu putri x≈80) |
| **200 total** | Ruang belajar Jenjang 3 (Kelas Kitab Kuning) | Masjid Besar → **Perpustakaan & Taman (0,20)** |
| **Cangkruk penuh (10 kasur)** | Hunian (bukan lokasi misi belajar) | Cangkruk → **Asrama 3 lantai**: Putra (−24,10), Putri (154,10) masterplan (±96 santri/gedung) |

**Yang TIDAK pindah:** Peti Kayu tetap di (0,26) semua Bagian; tes naik bagian tetap di Surau/Musholla selama Jenjang 0 (kurikulum §5 menulis semua N.T "Di dalam Surau") — pindah gedung baru berlaku mulai Jenjang 1 ke atas; sholat 5 waktu harian tetap di Surau/Musholla (Masjid Besar hanya untuk Jumat/tarawih/acara besar).
**Catatan jujur (Gilang):** kurikulum hanya eksplisit soal khataman Surau→Kelas di ambang 25 (§4.2). Rantai Kelas→Masjid Besar→Perpus untuk khataman/event adalah penerapan §2 kurikulum + ambang masterplan, bukan kalimat eksplisit — perlu dikunci apakah khataman ikut pindah ke Masjid Besar di 100 dan ke Perpus di 200, atau tetap di Kelas. (Masuk §9 sebagai keputusan.)

### 6.3 Lokasi yang BELUM ADA tapi dibutuhkan misi (prioritas)

| # | Lokasi | Koordinat masterplan | Dibutuhkan untuk | Prioritas |
|---|---|---|---|---|
| 1 | Ruang Kelas Putra — 5 lantai (lift + eskalator) | (−44,−14) | Belajar Jenjang 1 + khataman setelah ambang 25 | **TINGGI** |
| 2 | Ruang Kelas Putri — 5 lantai | (128,10) | Sama, putri | **TINGGI** — tapi tapak DITUNDA per keputusan 13:19 sampai santri putri ≥25 |
| 3 | Tempat Wudhu (Surau) | (−16,−8) | Misi Fiqih wudhu putra | **TINGGI** — Fiqih mapel prioritas 1 setelah Nahwu |
| 4 | Tempat Wudhu Putri (sisi Musholla/Kelas Putri) | belum ada koordinatnya | Misi Fiqih wudhu putri | **TINGGI** — kekosongan peta (§9) |
| 5 | Masjid Besar (pusat) | (64,−24) | Jumat, tarawih, Jenjang 2, khataman akbar, event besar | **SEDANG** — baru di ambang 100 |
| 6 | Perpustakaan & Taman (gedung) | (0,20) | Ruang belajar Jenjang 3 + rumah koleksi rak kitab + khidmah perpus + misi Adab | **SEDANG** — di ambang 200 |
| 7 | Dapur Umum | (16,36) | Khidmah dapur | **SEDANG** |
| 8 | Koperasi / Toko Santri | (−10,32) | Khidmah koperasi | **SEDANG** |
| 9 | Wudhu Putra/Putri (Masjid Besar) | (30,−6) / (98,−6) | Wudhu saat Jumat/event | RENDAH — ikut Masjid Besar |
| 10 | Masjid Putri | (166,−40) | Cadangan ibadah putri | RENDAH |
| 11 | Lapangan Putri | (198,12) | Olahraga/eksplorasi putri | RENDAH — ditunda 13:19 |
| 12 | Taman Surau | (0,−38) | Taman/eksplorasi | RENDAH |
| 13 | Klinik (16,44), Balai Tamu (12,74), Gudang (−51,62) | masterplan | Bukan lokasi misi inti | RENDAH |
| 14 | **Perlengkapan Lapangan Putra** — 2 gawang + garis + bola + lampu (lahan sudah ada) | (−30,50) | Sepak bola antar santri (arahan Mas 13:30) | **TINGGI** — lahan siap; tanpa ini sepak bola tidak bisa dimainkan |
| 15 | **Aula** — gedung 16×12 m | (0,52) | Bahtsul masail + upacara besar SEBELUM Masjid Besar (ambang 100 masih jauh — baru 3 santri); satu-satunya venue besar kawasan bersama sebelum 100 | **TINGGI** — tanpa Aula, semua event besar terpaksa dipecah Surau/Musholla sampai 100 santri |
| 16 | **Lapangan Putri** — lapangan 30×20 m | (198,12) | Olahraga putri (sepak bola/voli/lari) | **RENDAH** — tetap DITUNDA per keputusan 13:19 (nanti, bareng Asrama ke-2); sementara pakai halaman/taman (128,−12) |
| 17 | **Masjid Besar** — sudah ada di no. 5 (SEDANG); naikkan catatan: venue utama bahtsul masail + upacara kelulusan setelah ambang 100 | (64,−24) | Bahtsul masail, khataman akbar, wisuda, Jumat | **SEDANG** — tetap (baru di ambang 100); tapi jadi venue kunci untuk 2 dari 5 arahan baru Mas |

---

## 7. Multiplayer dalam misi (keputusan Mas 13:19 WIB)

Keputusan Mas atas 6 pertanyaan §8 rencana multiplayer — DIPUTUSKAN, masuk draf sebagai aturan main:

| Keputusan | Isi | Implikasi ke misi |
|---|---|---|
| **Cap 50/ruangan** | 50 pemain per ruangan | Misi bersama + khataman + sholat bisa ramai. Catatan Raka: cap kode sekarang 8; 50 × 10 Hz relay di VPS 2 vCPU **belum teruji** — perlu uji beban sebelum cap 50 dipakai untuk misi. |
| **Chat TEKS dulu** | Chat teks (bukan suara) | Kanal tanya jawab + musyawarah + koordinasi misi bersama (feed MLBB yang sudah ada + relay server + rate limit 1 pesan/2 detik). Tanpa chat, misi bersama tidak punya koordinasi. |
| **Sholat berjamaah OTOMATIS** | Sholat serentak dari server | Jam sholat dari server + broadcast pemicu — semua pemain mulai bersamaan. Yang masih perlu desain: apakah pemain ikut teleport ke Surau, atau jalan sendiri seperti NPC (±10–20 dtk)? Pemain manusia sekarang tidak dipaksa ikut. |
| **Terlihat dari seberang gerbang BOLEH** | Pemain boleh melihat pemain lain dari seberang gerbang/tembok | Misi bersama lintas gender **tidak bisa satu ruangan fisik** — harus dirancang per-area (khataman serentak dua area) atau virtual. Zona gender tetap ditegakkan server. |
| **Satu akun dua perangkat BOLEH** | 1 santri boleh 2 perangkat bersamaan | Perlu dicek Saka: apakah tiket realtime membolehkan 2 koneksi bersamaan untuk 1 santri? Kalau tidak, pemain kedua ditolak. |
| **Nama tampil SELALU** | Nama pemain lain selalu tampil — **termasuk di mode Drone harus tampil dan terbaca jelas** | Label nama di mode Drone harus diuji khusus (FOV lebar + jarak jauh = label mengecil/tidak terbaca; kemungkinan perlu skala label menurut jarak atau ukuran minimum). |

**Kuis mingguan + challenge (§2.7) memakai baris di atas:** chat teks untuk koordinasi + jam server untuk serentak + nama selalu tampil untuk papan skor.
**Prinsip (Raka):** misi mandiri (rantai N) tetap jalan offline/lokal seperti sekarang — jangan gantungkan progres misi ke koneksi. Yang server-driven hanya kegiatan serentak (khataman, sholat, misi bersama).

---

## 8. Kelayakan implementasi (Raka — baca kode, tidak ada file yang diubah)

### 8.1 Yang SUDAH ADA (pakai ulang langsung)

- Pola rantai berurutan terkunci (`main.gd` `_misi_terbuka`/`_misi_selesai`) + panel misi + kuis 1 soal + HUD "Poin + Misi" + syarat lokasi (surau/peti) + penanda di dunia.
- Server `POST /api/santri/points` + `event_id` UNIQUE + dedup anti-dobel (tes lolos). Skema poin M1=10/M2=15/M3=25 cocok dengan kurikulum.
- Reader buku Tara (kitab interaktif — pakai ulang, jangan bangun reader baru) + sumber kitab server `GET /api/kitab` (5 kitab, 184 bab, semua dicek_ustadz).
- Smartboard 3 slide Bagian 1 + tombol video (URL masih kosong).
- Jadwal khataman + tombol hadir + Ma'hadiyah 7 checklist + streak di Kartu Santri.
- Server lamaran pengurus v1.4.0 (5 posisi, alur Musyrif→Pengasuh) + role di save + pengecualian batas gerbang untuk pengurus.
- Satu Peti Kayu (M3) + logika buka peti.

### 8.2 Yang BARU (harus dibangun)

- 27 modul ruang belajar baru + 4 tes naik bagian (mekanik nol — kuis sekarang 1 soal, tanpa ambang lulus, tanpa bank soal) + kuis 5 soal + hafalan bait + gating Bagian + progres per Bagian di Kartu Santri + badge "Nahwu Dasar Lulus".
- Kitab interaktif Nahwu (port ebook → data misi, 30 topik) — reader sekarang berisi kitab klasik + buku umum; draf Nahwu sengaja tidak dimuat (`dicek_ustadz:false`).
- Peti dinamis 4 warna (saran Raka: SATU peti yang berubah warna/isi per Bagian — jauh lebih murah daripada 4 peti fisik; posisi sudah di kawasan bersama, terjangkau putra + putri).
- 9 slide smartboard (Bagian 2–4) + 4 URL video (video belum ada).
- Kuis modul ruang belajar + jam server + kirim kehadiran khataman (aktivitas baca)/Ma'hadiyah ke server (server belum punya endpointnya).
- Rotasi koleksi rak kitab untuk khataman harian (Senin Jurumiyah, Selasa Amtsilah, dst).
- Chat teks + sholat serentak server + voting Ketua Asrama/Kepala Kamar + label jabatan + pengumuman pelantikan + misi bersama.
- **Integrasi game→server poin: BELUM ADA.** Game tidak pernah memanggil `POST /api/santri/points` (hanya disebut di komentar). Poin M1–M3 sekarang lokal saja.
- Font Arab di proyek belum diverifikasi ada/tidak — perlu dicek sebelum port (teks Arab butuh font Arab).
- **BARU v2 (diubah v4):** mesin kuis gerbang ruang belajar (kaidah Nahwu Dasar, mudah) — bank soal dari materi ruang belajar yang sudah ditashih Mas; gelar: tier + divisi + bintang di `save_data.gd` (lokal dulu) + tampil di Kartu Santri + label nama; kuis mingguan: event serentak server + soal dari server + papan skor sesi/mingguan; duel 1v1: matchmaking + sesi sinkron + protokol realtime baru (server Fase 1 hanya relay posisi/pose, tanpa logika game); bahtsul masail: format musyawarah kelompok + ruang per kelompok + penilaian ustadz/musyrif; olahraga: gawang + garis + bola + lampu di Lapangan Putra (venue, tanpa mekanik — Fase A) dan SEMUA mekanik bola/tim/skor (Fase D).

### 8.3 Risiko terbesar (Raka)

1. **Jalur poin game→server belum ada (arsitektur, bukan kode).** `X-PV-Token` TIDAK BOLEH masuk file game mana pun. Tanpa keputusan Saka (relay via server realtime tepercaya vs endpoint baru pakai token sesi login), semua misi baru poinnya lokal saja dan ranking server basi. **Putuskan ini dulu sebelum Fase B.**
2. **Konten adalah bottleneck, bukan kode.** 30 topik + bank soal + bait hafalan harus ditulis/di-port dari ebook, dan materi Bagian 2–4 **menunggu tashih Mas** (keputusan 15:14 — Mas sendiri yang tashih; tim khusus kurikulum DIBENTUK SEKARANG per Mas 15:16, mengerjakan satu modul per hari). Kalau konten telat, mesin kuis yang sudah jadi tidak ada isinya.
3. **Jam & kehadiran dari perangkat lokal.** Khataman, sholat, Ma'hadiyah semua pakai jam HP + simpan lokal — bisa diakali, tidak tersinkron, tidak sampai ke server. Syarat naik jenjang (§5: Ma'hadiyah ≥5/7 selama 4 minggu, kehadiran khataman) **tidak bisa ditegakkan** sampai ada jam server + endpoint kehadiran. Jangan aktifkan syarat lulus sebelum ini beres.
4. **Gelar tanpa jalur poin ke server = bisa dipalsukan dan tidak sinkron.** Gelar lokal dulu (Fase A) aman untuk dilihat sendiri, tapi gelar yang tampil di ranking/label nama orang lain harus dari server (Fase B). Jangan tampilkan gelar server sebelum jalur poin ada.
5. **Penilaian manusia adalah bottleneck bahtsul masail (bukan kode).** Tanpa musyrif/Kyai yang hadir menilai di jam event, event jadi diskusi tanpa penutup dan tanpa skor — pastikan penilai + antarmukanya sebelum bangun (Fase C).
6. **Desync bola (olahraga, Fase D).** Satu bola dihitung di tiap HP = posisi berbeda di tiap layar; butuh otoritas server atas bola + beban HP 20+ pemain bergerak cepat + fisika. Fitur terbesar dari 5 arahan Mas — jangan mulai sebelum multiplayer stabil.

### 8.4 Urutan bangun yang disarankan (Raka)

- **Fase A — Fondasi (kecil–sedang):** mesin kuis multi-soal (1/5/10) + tes ≥8 + gating Bagian + progres per Bagian di Kartu Santri + peti dinamis 4 warna + 9 slide smartboard + **gerbang ruang belajar (kuis kaidah, lokal) + gelar diperluas (lokal) + perlengkapan Lapangan Putra (gawang + garis + bola + lampu — venue siap, tanpa mekanik) + marker/petunjuk Ustadz di peta + sistem tugas dari Ustadz (§2.1)**. Poin tetap lokal dulu seperti sekarang.
- **Fase B — Server & serentak (sedang):** jalur poin game→server (keputusan Saka) + jam server + khataman sebagai aktivitas baca (hadir + kirim kehadiran) + kuis modul ruang belajar + Ma'hadiyah ke server + badge lulus + ranking per asrama + **penegakan gerbang + gelar server + kuis mingguan serentak + papan skor mingguan**. **Baru di sini syarat naik jenjang diaktifkan.**
- **Fase C — Sosial (sedang–besar):** chat teks + sholat serentak server + voting Ketua Asrama/Kepala Kamar + label jabatan + pengumuman pelantikan + misi bersama + **duel 1v1 + tantangan hafalan + Bahtsul Masail (format kelompok + penilaian ustadz/musyrif)**. Setelah Fase 1 multiplayer lolos T1.
- **Fase D — Olahraga (baru, BESAR):** sepak bola lengkap (fisika bola + otoritas server atas bola + tim + skor + mode pertandingan + liga musiman); putri menunggu Lapangan Putri/Asrama ke-2; cabang "dll" (voli, lari) ditunda sampai sepak bola jalan. Prasyarat: multiplayer stabil (Fase C selesai) + perlengkapan lapangan (Fase A).

---

## 9. Yang sudah live / baru / butuh keputusan Mas

### ✅ SUDAH LIVE (dipertahankan — fondasi draf)

M1–M3 (+10/+15/+25) · peti kayu · smartboard 3 slide Bag. 1 · jadwal khataman 05:00/13:00/18:30 + tombol hadir · Ma'hadiyah 7 checklist + streak · sholat berjamaah lokal (Kyai/Ustadzah imam) · lamaran pengurus server v1.4.0 · ranking + tier poin · reader kitab (5 kitab, 184 bab) · Asrama Putra/Putri 96 kasur · multiplayer Fase 1 (server realtime live; tombol gabung UI sedang dibuat Dimas — "belum bisa main" 13:10).

### 🆕 BARU dari draf ini (belum dibangun — tunggu ACC Mas)

- Tangga kitab Tahap 0–3 sebagai tulang punggung (Sidogiri persis — v3) — menggantikan rantai Nahwu saja sebagai satu-satunya progresi.
- 27 modul ruang belajar lanjutan + 4 tes naik bagian + kuis 5/10 soal + hafalan bait + gating Bagian + badge.
- Rak kitab: tambah koleksi batch berikut + khataman sebagai aktivitas baca (bukan misi) + sesi baca bersama sebagai karakter.
- Ruang Belajar per mapel (inti misi v4, pola: cari Ustadz → belajar → tugas) + gerbang ruang belajar (kuis kaidah mudah) + badge "Bisa Baca Kitab Kuning" (syarat baru: ruang belajar + baca di rak kitab + setoran).
- Musyawarah mingguan + Bahtsul Masail bulanan (Tahap 2–3).
- Khidmah harian (5 poin) + pelantikan + label jabatan (voting Ketua Asrama belum dirancang).
- Hafalan nadzam Alfiyah dicicil + tahfidz Qur'an (koordinasi TTQ Sidogiri; rincian tingkat belum terverifikasi).
- Misi harian (sholat 5 poin) + misi eksplorasi Sejarah (5 poin/lokasi) + event musiman.
- Ranking per asrama + progres per Bagian di Kartu Santri.
- Jam server + kirim kehadiran khataman/Ma'hadiyah ke server + jalur poin game→server.

### ❓ BUTUH KEPUTUSAN MAS (sebelum/saat bangun — bukan sekarang, draf dulu dinilai)

1. **Penempatan Masjid Besar di (64,−24), tengah zona penyangga — setuju atau opsi lain?** (Juga pertanyaan no. 2 masterplan.) Tanpa ini, Jumat/tarawih/Jenjang 2/khataman akbar/event besar di ambang 100 tidak punya tujuan — dan dua tempat wudhunya (30,−6)/(98,−6) ikut menggantung.
2. **Tempat Wudhu Putri di kampus putri — di mana?** Masterplan punya wudhu putra di Surau (−16,−8) tapi tidak punya wudhu putri sebelum Masjid Besar (98,−6, ambang 100). Kalau misi Fiqih wudhu putri harus jalan sebelum itu, perlu satu titik di kampus putri.
3. **Khataman ikut pindah gedung di ambang 100/200, atau tetap di Kelas?** Kurikulum hanya eksplisit Surau→Kelas di 25.
4. **Peti: satu peti dinamis (warna/isi berubah per Bagian) atau 4 peti fisik?** (Saran Raka: satu peti dinamis.)
5. **Sholat berjamaah otomatis: pemain ikut teleport ke Surau, atau jalan sendiri?** (Keputusan desain Fase 2 multiplayer.)
6. **Video smartboard (4 video Nahwu) — siapa yang membuat?** (Tanpa video, tombol tetap nonaktif "Belum ada video".)
7. **Voting Ketua Asrama/Kepala Kamar: vote/komen santri atau tunjuk musyrif?**
8. **Jalur poin game→server — relay via server realtime tepercaya atau endpoint baru?** (Keputusan Saka, arsitektur — lihat §8.3 risiko 1.)
9. **Syarat lamaran pengurus naik (mis. "Bagian 1 lulus") atau tetap "M1 selesai"?**

### ❓ TAMBAHAN v2 (arahan Mas 13:30) + v4 (arahan Mas 15:14) — ditanyakan setelah Mas menilai draf v4

10. **Nama gelar puncak 'Allamah — pantas dipakai untuk game, atau ganti?** (Alternatif: "Kyai Muda" / "Alim Pesantren Verse".) Tier 1–7 sudah aman; yang sensitif hanya puncak.
11. **Cabang olahraga pertama: sepak bola saja dulu?** (Usulan tim: ya — voli/lari ditunda sampai sepak bola jalan.) Dan apakah skor olahraga masuk poin santri / bintang gelar? Wasit pertandingan: musyrif atau NPC?
12. **Badge "Bisa Baca Kitab Kuning": syaratnya apa?** (Usulan tim: ruang belajar Nahwu Dasar selesai + gerbang ruang belajar lulus + baca kitab di rak kitab + setoran ke ustadz. Yang perlu Mas kunci: **berapa bab** yang harus dibaca di rak kitab, dan **bentuk setorannya** — baca di depan ustadz langsung, atau rekam suara/kirim video? Setoran = Fase C, usaha besar.)
13. **Bahtsul Masail: siapa musyrif/moderator yang sanggup hadir terjadwal tiap bulan?** (Tanpa penilai yang hadir, event tidak punya penutup/skor.) Dan venue gabungan sebelum Masjid Besar: bangun Aula (0,52) dulu, atau tetap pecah Surau/Musholla sampai ambang 100?
14. **Kuis mingguan: hari + jamnya kapan?** (Usulan tim: Sabtu 09:00 WIB, ±30 menit, 10 soal.)
15. **Ruang belajar per mapel: mulai dari mapel apa setelah Nahwu Dasar?** (Usulan tim: **Mantiq** — ruang belajarnya sudah ada contohnya di Asisten Ustadz; kitabnya Syarh Sullam al-Munawraq, Tsanawiyah.)
16. **Koleksi rak kitab batch berikut: ACC daftar antreannya?** (Azab dan Sengsara, Sengsara Membawa Nikmat, Habis Gelap Terbitlah Terang, Hikayat Hang Tuah + 5 kitab server yang sudah di reader.)

---

## 10. Yang DITUNDA (per Mas 13:21 — item 10–20, skip dulu, jangan ditanya lagi untuk sekarang)

- Koreksi M2 → N1.2 (marfu' pindah ke N4.1) — dicatat di §2.1 apa adanya, tidak dimintakan keputusan.
- Jadwal khataman + aturan minimal kehadiran (usulan ≥60%) — draf memakai jadwal LIVE.
- 4 kaidah "perlu dicek ustadz" (muannats samai, i'lal, syarat isim laa, rincian munada) — Bagian 2–4 tidak boleh di-port dulu; **tashihnya oleh Mas sendiri** (keputusan 15:14) — tim khusus kurikulum DIBENTUK SEKARANG per Mas 15:16, mengerjakan satu modul per hari.
- Rencana upgrade visual §11 · Meshy · Syumra · nama PV-0001 "Tes" · pengurus pertama + jadwal pelantikan · bayangan label nama · panel Musholla · plakat Surau.

---

## 11. Ringkasan satu halaman (untuk Mas)

- **Prinsip:** belajar seperti di pesantren salaf sungguhan (tangga kitab MMU Sidogiri persis), main seperti game (quest, XP, naik kelas, ranking, streak, event).
- **Tangga:** Santri Baru (Al-Miftah/Nahwu Bag. 1) → Ibtidaiyah (Jurumiyah, Imrithi, Fathul Qarib) → Tsanawiyah (Alfiyah, Tuhfah ath-Thullab, Umm al-Barahin, Bulugh al-Maram) → Aliyah (Fath al-Mu'in, Ghayah al-Ushul, Syarh al-Hikam, musyawarah, khidmah sebagai syarat ijazah).
- **Cara belajar:** ruang belajar per mapel — pola: cari Ustadz (petunjuk di peta) → belajar → tugas dari Ustadz (materi singkat + latihan mudah + kuis; model ruang belajar Mantiq; tashih Mas) → musyawarah (Tahap 2–3) → khidmah (tugas pengurus). Baca kitab di rak kitab (bukan misi); khataman = aktivitas baca.
- **Ritme harian:** tahajud → Subuh berjamaah → khataman 05:00 → belajar/misi → Dzuhur → khataman 13:00 → Ashar → belajar/khidmah → Maghrib → khataman 18:30 → Isya → musyawarah malam.
- **Poin:** materi 10 · latihan 15 · hafalan 10 · peti 25 · tes 20 · harian 5 · musyawarah 15 · event 25. Tier: 25 Penjelajah · 50 Pembuka Peti · 100 Penjaga Lentera.
- **Dunia tumbuh:** Kelas 25 → Masjid Besar 100 → Perpus 200; Asrama saat cangkruk penuh.
- **Multiplayer (diputuskan Mas 13:19):** cap 50/ruangan · chat teks · sholat berjamaah otomatis · terlihat dari seberang gerbang boleh · satu akun dua perangkat boleh · nama tampil selalu (termasuk di mode Drone).
- **Bangun bertahap (Raka):** Fase A fondasi (mesin kuis + tes + gating + peti + slide + gerbang ruang belajar lokal + gelar lokal + marker Ustadz + sistem tugas) → Fase B server & serentak (poin + jam server + khataman + badge + gelar server + kuis mingguan) → Fase C sosial (chat + sholat serentak + voting + misi bersama + duel + bahtsul masail) → Fase D olahraga (sepak bola).
- **BARU v2 (arahan Mas 13:30):** ujung Nahwu Dasar = selesai ruang belajar + gerbang kuis kaidah; badge "Bisa Baca Kitab Kuning" (syarat: ruang belajar + baca di rak kitab + setoran ustadz) · tangga gelar 8 tier ala ML (Thalib al-'Ilm → 'Allamah) · kuis mingguan serentak + duel 1v1 + tantangan hafalan · event Bahtsul Masail bulanan (Kyai sebagai mushahhih) · sepak bola antar santri (liga musiman, Fase D — fitur terbesar).
- **BARU v4 (arahan Mas 15:14 + 15:17):** misi = Ruang Belajar (mudah, interaktif, materi Sidogiri, tashih Mas; pola baku: cari Ustadz → belajar → tugas dari Ustadz) · baca kitab/khataman/setoran pindah ke rak kitab (bukan misi) · koleksi rak kitab ditambah (batch kurasi) · Perpustakaan = gedung ambang 200 · tim khusus kurikulum dibentuk sekarang, mengerjakan satu modul per hari.
- **Yang sudah live:** M1–M3, peti, smartboard Bag. 1, khataman + Ma'hadiyah, sholat lokal, lamaran server, ranking, reader kitab, Asrama 96 kasur, multiplayer Fase 1 (tombol gabung sedang dibuat).

*Draf ini rancangan — keputusan akhir di tangan Mas (Pengasuh) setelah menilai. Bila Mas ACC, langkah berikut: (1) kunci §9 butir 1–2 (lokasi Masjid Besar + wudhu putri) dan butir 10–16 (gelar puncak, sepak bola, syarat badge, penilai bahtsul masail, jadwal kuis mingguan, mapel ruang belajar setelah Nahwu, koleksi rak kitab); (2) tim mulai Fase A sesuai `ROADMAP-ALUR-MISI.md`; (3) konten ebook Fiqih Dasar dikerjakan paralel (mapel prioritas 1 setelah Nahwu — catatan: urutan mapel ruang belajar diputuskan di butir 15).*
