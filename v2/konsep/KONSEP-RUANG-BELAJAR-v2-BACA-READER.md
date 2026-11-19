# KONSEP — Ruang Belajar v2: "Baca di reader, chat jadi pemandu"

**Keputusan Mas (20 Nov 2026, 00:21 WIB):** Ruang Belajar chat v1 dinilai
kurang dalam — "enak baca atau liat video aja". Dipilih: **baca di reader,
chat jadi pemandu.**

**Status:** KONSEP — menunggu ACC Mas. Kode game TIDAK diubah.
**Gambar:** `konsep-ruang-belajar-v2-pemandu.png` (chat pemandu),
`konsep-ruang-belajar-v2-reader.png` (halaman reader modul),
`konsep-ruang-belajar-v2-kuis.png` (chat latihan/kuis + tugas).
**Sumber:** `KONSEP-RUANG-BELAJAR-CHAT-v1.md` §7+§8 (v1 yang diganti),
`DRAF-ALUR-MISI.md` v5.4.1 (§1A langkah 5, §2.1, §2.9), Modul 01–03
Tim Kurikulum (`ruang-belajar-nahwu-dasar-01/02/03-*.md`), reader rak kitab
Tara (`ui.gd` `_build_baca_buku_panel`, ~:3628), `data_chat_modul_01.gd` +
`data_modul_01.gd`.

---

## 0. Masalah yang diperbaiki (kata Mas, 19 Nov 23:36)

Chat v1 (14 pesan dialog ala Genshin, live di build 20261119-4) dinilai
dangkal untuk belajar beneran:

1. **Materi terpotong jadi gelembung** — satu § modul jadi 1–2 kalimat
   ustadz; tabel, contoh, dan rumus tidak bisa tampil utuh.
2. **Susah diulang** — mau baca ulang §2 harus tap-tap mundur lewat
   riwayat; tidak ada daftar isi, tidak ada lompat ke bagian.
3. **Strukturnya tidak kelihatan** — santri tidak tahu modul ini ada
   berapa bagian, sudah sampai mana, dan apa yang belum dibaca.

Padahal materinya SUDAH ditulis rapi oleh Tim Kurikulum sebagai dokumen
terstruktur (Modul 01: 441 baris, 7 § materi + bait + rangkuman + latihan
14 + kuis 10 + 2 uraian; Modul 02: 421 baris, 6 §; Modul 03: 486 baris,
6 §). Di chat, semua struktur itu hilang. Di reader, struktur itu justru
yang tampil.

**Prinsip v2:** materi dibaca seperti membaca buku (dalam, terstruktur,
bisa diulang); chat hanya memandu (menyapa, mengarahkan, menguji,
memberi tugas). Ustadz tetap hadir mengajar — beliau yang menyuruh baca,
beliau yang menguji sesudahnya. Bukan "chat diganti buku", melainkan
"ustadz memberi buku, lalu menguji".

---

## 1. Alur baru end-to-end (Modul 01 sebagai contoh)

Pola baku "Cari Ustadz → Belajar → Tugas dari Ustadz" (draf v5.4.1 §2.1)
**TETAP** — yang berubah hanya isi langkah "Belajar".

```
1. Cari Ustadz (TETAP)
   Santri menemukan Ust. Sanusi (lokasi random, tanpa marker) /
   Ustzh. Fatimah (putri). Ketuk → adegan belajar terbuka:
   ustadz DUDUK di atas tikar + meja + papan tulis kecil di sampingnya,
   kamera membingkai beliau (seperti v1 §8 — TIDAK berubah).

2. Chat pemandu — SINGKAT (BARU: 3 pesan, bukan 14)
   P1  "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar —
        Modul 01: Mengenal Kata."
   P2  "Modulnya ada 7 bagian — kalam, isim, fi'il, huruf, rumus,
        mabni-mu'rob, dan perubahan akhir kata. Baca dulu di reader,
        santai saja. Kalau sudah, kembali ke saya."
   P3  [tombol emas] "Buka Modul ›"  → membuka reader modul (§3).
       [tombol outline] "Nanti dulu" → tutup, bisa kembali kapan saja.
   Efek bicara TETAP (huruf satu-satu ±40 ms, tap = tampil penuh).
   TIDAK ADA cabang "Belum, jelaskan lagi" — penjelasan ada di modul,
   bukan di chat. TIDAK ADA status mengetik (sudah dihapus §8 v1).

3. Baca di reader (BARU — §3)
   Reader modul terbuka (layar penuh, kertas krem, seperti rak kitab).
   Santri membaca §1–§7 + bait hafalan + rangkuman, dalam urutan bebas
   (daftar isi di atas, bisa lompat). Setiap bagian yang dibuka
   dicatat (kunci save `rb_baca_bagian`, §5).
   Tombol "Mulai Latihan" di footer reader AKTIF setelah semua 7 bagian
   dibuka (opsi A, §5) — sebelum itu redup dengan keterangan
   "Baca dulu semua bagian (X/7)".

4. Kembali ke chat — latihan + kuis (TETAP di chat, dipersingkat)
   Tap "Mulai Latihan" → reader tertutup → chat pemandu muncul lagi:
   P4  "Sudah dibaca semua? Bagus. Sekarang kita latihan — 5 soal."
   L1–L5  Soal latihan (5 soal, format v1: ustadz bertanya, 4 opsi;
           salah → ustadz menjelaskan dari "petunjuk" + soal diulang,
           opsi salah dimatikan). → +15 poin latihan.
   K1  Kuis (1 soal dari bank N1.T). → +10 poin kuis.
   P5  Penutup: "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin."
       + kartu "Selesai — 35 poin".

5. Tugas dari Ustadz (TETAP)
   P6  "Tugasmu: hafalkan baitnya, lalu baca 1 bab di rak kitab."
       → +5 poin saat selesai (sesuai tashih Modul 01).
       → maju langkah 5→6 (tes kenaikan), toast seperti sekarang.
```

**Total pesan chat v2: 6** (P1–P3 pemandu, P4–P6 sesudah baca) — turun
dari 14. Yang hilang dari chat: 7 pesan materi + 2 cabang "Belum".
Yang pindah ke reader: seluruh isi materi (§1–§7, bait, rangkuman).

**Buka ulang setelah selesai → mode baca ulang:** reader bisa dibuka
kapan saja dari Ruang Belajar (tombol "Baca Ulang Modul"), chat pemandu
hanya menampilkan P1 singkat + tombol "Buka Modul" — TANPA poin lagi
(guard `rb_selesai` yang sudah ada). Tutup di tengah baca → lanjut dari
bagian terakhir yang dibuka (resume `rb_fase` + `rb_baca_bagian`, §5).

---

## 2. Nasib chat v1 — apa yang dipensiunkan, apa yang tetap

| Elemen v1 | Nasib di v2 | Alasan |
|---|---|---|
| 14 pesan dialog materi | **DIPENSIUNKAN** | Inilah yang dangkal — materi pindah ke reader. Data `NOD` di `data_chat_modul_01.gd` diganti 6 node pemandu (§1). |
| Cabang "Belum" maks 2× | **DIPENSIUNKAN** | Penjelasan ulang sudah ada di modul (bagian + "Ingat/Rumus"). Chat tidak lagi menjelaskan materi. |
| Efek bicara (±40 ms/huruf) | **TETAP** | Pesan pemandu tetap ucapan ustadz, bukan ketikan. Tap = tampil penuh. |
| Papan tulis kecil | **TETAP, isi berubah** | Adegan duduk + papan (§8 v1) tetap — papan kini menampilkan **judul modul + bagian yang sedang dibaca** ("MODUL 01 — §2 Isim"), bukan ringkasan materi. Papan = penanda posisi, bukan pengganti reader. |
| Ustadz duduk + meja | **TETAP** | Adegan belajar di dunia tidak berubah (meja Sinta, lantai Surau y=0,5). |
| Latihan 5 soal + kuis 1 soal di chat | **TETAP** | Format tanya-jawab memang cocok dengan dialog — soal + opsi + penjelasan saat salah. Isi soal TIDAK berubah. |
| Tombol Auto + Riwayat | **TETAP** | Auto = alur pemandu otomatis; Riwayat = log 6 pesan pemandu (kecil, jarang dipakai — pesan sedikit). |
| Bilah progres emas | **TETAP, makna berubah** | Kini progres FASE (pemandu → baca → latihan → selesai), bukan "pesan X dari 14". |
| Poin 35 (10+15+10) + tugas 5 | **TETAP** | Poin materi 10 diberikan saat semua bagian dibuka (§5 opsi A); latihan 15 + kuis 10 seperti v1; tugas 5 seperti tashih Modul 01. |
| Resume `rb_chat_pos` | **DIGANTI** | Node chat lama tidak ada lagi. Diganti `rb_fase` + `rb_baca_bagian` (§5). `rb_chat_modul` TETAP (modul yang sedang berjalan). |

---

## 3. Reader modul — bagaimana materi tampil di game

**Bukan rak kitab.** Rak kitab (§2.2 draf) adalah kitab-kitab umum dari
server — daftar buku → bab → baca. Reader modul adalah panel baca
sendiri untuk materi misi: satu modul = satu buku, isinya sudah
terstruktur per bagian, punya progres baca + poin. Pola visualnya
dipakai ulang dari reader Tara (layar penuh, kertas krem, header hijau,
teks besar, zona tap ‹ ›), tapi datanya dari `DataModul` (bukan
`BukuData`) dan navigasinya per BAGIAN, bukan per halaman kitab.

### 3.1 Anatomi layar (mockup `konsep-ruang-belajar-v2-reader.png`)

- **Header (krem, teks hijau):** "RUANG BELAJAR" kecil emas di atas,
  judul "Nahwu Dasar — Modul 01" (30), subjudul "Mengenal Kata •
  Bagian 1 (Hijau)" (16, abu-hijau). Tombol "× Tutup" kanan atas.
- **Daftar isi (chip horizontal, bisa digulir):** "1 Kalam • 2 Isim •
  3 Fi'il • 4 Huruf • 5 Rumus • 6 Mabni • 7 Akhir Kata • Bait •
  Rangkuman". Chip bagian yang sudah dibaca = centang emas; bagian
  aktif = isi emas. Tap chip = lompat ke bagian itu.
- **Isi bagian (gulir vertikal):** judul § emas besar; teks Latin
  Baloo 2 (28–30, gelap, rata kiri, autowrap); contoh Arab **Amiri
  besar rata kanan** + transliterasi miring + arti — satu blok contoh
  (pola reader Tara: Arab besar atau Latin); **tabel modul → kartu
  baris**: tiap baris tabel jadi satu kartu krem (Arab besar kanan +
  Latin + arti) — Godot tidak me-render tabel Markdown, jadi tabel
  dipecah jadi kartu; kotak **"Ingat:" / "Rumus:"** berbingkai emas
  dengan latar krem gelap; **"Rujukan:"** kecil abu-abu di bawah
  tiap § (Jurumiyah / Al-Miftah — seperti di dokumen).
- **Footer:** tombol "‹ Bagian" / "Bagian ›" (outline, besar, ramah
  jempol) + bilah progres emas tipis "Dibaca 4/7 bagian" + tombol
  emas "Mulai Latihan ›" (aktif hanya bila 7/7 — §5) atau, bila belum,
  teks redup "Baca dulu semua bagian (4/7)".
- **Perilaku baca:** gulir vertikal dalam § (ScrollContainer, pola
  reader); tap zona ‹ › di pinggir = pindah bagian (pola reader
  Tara); ukuran teks mengikuti reader (30) — tidak ada zoom gambar
  (modul tidak punya gambar halaman kitab).

### 3.2 Contoh isi — §2 Isim (Modul 01) di reader

```
§2  Isim — Kata Benda dan Nama                    [chip: 2 Isim ✓]

Isim adalah kata yang menunjukkan arti pada dirinya sendiri
dan tidak terikat waktu. Orang, benda, tempat, sifat, dan
nama kegiatan bisa menjadi isim.

  ┌─ kartu contoh ─────────────────────────────┐
  │  مُحَمَّدٌ                    (Amiri, besar) │
  │  Muhammadun — "Muhammad" · nama orang      │
  ├────────────────────────────────────────────┤
  │  مَسْجِدٌ                                  │
  │  masjidun — "masjid" · tempat              │
  │  ... (5 baris, satu kartu per baris)       │
  └────────────────────────────────────────────┘

Ciri-ciri isim — ini kuncinya
  1. Bisa diberi tanwin: kitaabun (kitab), masjidan (masjid).
  2. Bisa diawali al-: al-kitaabu (kitab itu).
  3. Bisa di-jer dengan huruf jer di depannya: fi al-masjidi.
  4. Bisa disandarkan (idhafah): kitaabu Muhammadin.

  ┌─ Rumus ────────────────────────────────────┐
  │ Ada tanwin / al- / huruf jer / disandarkan │
  │ = pasti ISIM.                              │
  └────────────────────────────────────────────┘

Rujukan: Jurumiyah, Bab al-Kalam; Al-Miftah Jilid 1.
```

### 3.3 Modul 02 & 03 — pola sama, konten sudah ada

Modul 02 (6 §: makrifat/nakiroh, 6 jalan makrifat, mudzakar/muannats,
tanda muannats, jamid/musytaq, keluarga musytaq) dan Modul 03 (6 §:
fi'il menurut waktu, mujarrod/mazid, muta'addi/lazim, ma'lum/majhul,
shahih/mu'tal, i'rob mudhori') tampil dengan pola yang sama persis —
hanya judul, jumlah chip, dan isi yang berganti. **Catatan:** data game
untuk Modul 02/03 BELUM ADA (hanya Modul 01 yang punya
`data_modul_01.gd`) — porting .md → data GDScript adalah bagian
implementasi (pekerjaan A2), BUKAN bagian konsep ini. Konsep ini memakai
Modul 01 sebagai contoh; pola datanya sama untuk 02/03.

### 3.4 Yang TIDAK masuk reader

- **Kunci jawaban** — tetap disembunyikan (hanya dipakai mesin kuis
  untuk menilai; tidak tampil di reader).
- **Pertanyaan tashih / penanda "belum terverifikasi"** — itu urusan
  dokumen kurikulum, bukan tampilan santri. Kaidah yang DITAHAN
  (muannats samai lengkap, i'lal) memang TIDAK ADA di modul — reader
  hanya menampilkan yang sudah lolos tashih.
- **Soal uraian** — uraian adalah soal Tes Naik, bukan latihan modul;
  tidak tampil di reader.

---

## 4. Chat pemandu + kuis — contoh teks (mockup 1 & 3)

### Mockup 1 — chat pemandu (`konsep-ruang-belajar-v2-pemandu.png`)

Adegan: Sanusi duduk + meja + papan tulis ("MODUL 01 — Mengenal
Kata"), kotak dialog bawah ala Genshin (nama emas "Ust. Sanusi"):

> "Modulnya ada 7 bagian — kalam, isim, fi'il, huruf, rumus,
> mabni-mu'rob, dan perubahan akhir kata. Baca dulu di reader,
> santai saja. Kalau sudah, kembali ke saya."
>
> [ Buka Modul › ]  (emas)      [ Nanti dulu ]  (outline)

### Mockup 3 — chat latihan/kuis + tugas (`konsep-ruang-belajar-v2-kuis.png`)

Setelah baca selesai, kembali ke ustadz:

> "Sudah dibaca semua? Bagus. Sekarang kita latihan — 5 soal."
>
> **L1 — "Coba tebak — madrasatun (sekolah) itu jenis kata apa?"**
> [ A. Isim ] [ B. Fi'il ] [ C. Huruf ] [ D. Kata ganti ]
>
> Benar → "Benar! Bertanwin, jadi isim." + lanjut L2.
> Salah → "Belum tepat. Madrasatun bertanwin — jadi isim. Coba lagi."
> (soal diulang, opsi salah dimatikan — pola v1, tidak berubah.)

Penutup + tugas (setelah K1 benar):

> "Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin. Tugasmu:
> hafalkan baitnya, lalu baca 1 bab di rak kitab."
> [ Tutup ] → +5 poin tugas saat selesai → langkah 5→6.

---

## 5. Penanda selesai baca + anti-farming

### Opsi yang dipertimbangkan

| Opsi | Cara kerja | Kelebihan | Kelemahan |
|---|---|---|---|
| **A. Semua bagian dibuka (REKOMENDASI)** | Tiap § yang dibuka ≥3 detik dicatat di `rb_baca_bagian` (bitmask). "Mulai Latihan" aktif saat 7/7. Poin materi 10 diberikan saat 7/7 tercapai. | Murah; tidak bisa di-farm sekali tap (butuh 3 detik × 7 bagian ≈ 21 detik minimal); tidak memaksa baca kata-per-kata; santri bebas lompat via daftar isi. | Santri bisa membuka lalu menunggu tanpa membaca — tapi itu sama dengan membuka buku di dunia nyata; kuis tetap menguji paham. |
| B. Gulir sampai akhir tiap § | `scroll_vertical` mencapai bawah tiap § baru terhitung dibaca. | Lebih ketat — membuktikan mata melewati isi. | Gampang di-farm (seret cepat ke bawah); § pendek selesai dalam 1 seretan; memberi kesan "dipaksa", bertentangan dengan "santai saja". |
| C. Tanpa gate (percaya santri) | "Mulai Latihan" langsung aktif; poin materi 10 diberikan saat latihan dimulai. | Paling sederhana, nol friksi. | Poin materi tanpa syarat apa pun; santri bisa lompat ke kuis tanpa pernah membuka modul — tujuan "baca" gagal. |

### Rekomendasi Sinta: Opsi A

Gate-nya ringan dan jujur: yang diukur adalah "sudah membuka semua
bagian", bukan "sudah membaca tiap kata" — karena yang benar-benar
menguji paham adalah latihan + kuis (15+10 poin), bukan gate baca.
Poin materi 10 adalah hadiah menyelesaikan bacaan, bukan hadiah
menghafal. Kunci save baru:

- `rb_baca_bagian` — bitmask per modul (bit i = § i sudah dibuka ≥3
  detik). WAJIB tambah di `save_data.gd default_data()` (pelajaran
  lama: kunci baru yang tidak ada di sana tidak tersalin saat load).
- `rb_fase` — "pemandu" | "baca" | "latihan" | "selesai" (ganti
  `rb_chat_pos`; `rb_chat_modul` tetap).
- `rb_selesai` — TETAP (anti-farming per langkah: materi/latihan/
  kuis/tugas; `langkah_selesai` + `selesai` tidak berubah).

---

## 6. Yang TETAP (tidak berubah dari v1 / draf)

- **Tes kenaikan** — ambang 8/10, +20 poin, venue Kantor Putra
  (−18,18.5) / Kantor Ustadzah (148,−33); N2–N4 "belum tersedia".
- **Poin** — materi 10 / latihan 15 / kuis 10 / tugas 5; bank soal
  Modul 01–03 (N1/N2/N3 final setelah tashih); kuis modul = N.T.
- **Pola baku** — "Cari Ustadz → Belajar → Tugas dari Ustadz"
  (draf v5.4.1 §9 TERKUNCI); alur santri baru §1A langkah 5.
- **Adegan belajar** — ustadz duduk + meja + papan tulis, kamera
  dialog, avatar Sanusi (peci hitam nasional) / Fatimah (jilbab krem).
- **Syarat tampilan §2.9** — enak dibaca, tidak primitif, nuansa 3D
  style game; gradien zamrud + rim emas + Baloo 2 + Amiri (pola
  GayaMisi / Panel Misi v2).
- **Video** — tetap DITUNDA (smartboard video ditunda §9 butir 6;
  belum ada pembuat). v2 ini menjawab "baca atau video" dengan
  "baca" — video tetap untuk nanti, hanya untuk topik yang susah
  dijelaskan teks (diputuskan Mas bila ada).

---

## 7. Yang BERUBAH saat implementasi nanti (daftar file — JANGAN diubah sekarang)

| File | Perubahan (nanti, setelah ACC konsep) |
|---|---|
| `scripts/ui_misi/data_chat_modul_01.gd` | 14 node → 6 node pemandu (P1–P6, §1); cabang "Belum" + papan-per-node dihapus; papan kini diisi judul modul + § aktif. |
| `scripts/ui_misi/data_modul_01.gd` | Tambah struktur BAGIAN untuk reader (§1–§7 + bait + rangkuman sebagai array bagian: `{judul, paragraf[], contoh[], tabel[], rumus, rujukan}`) — atau file data baru `data_modul_baca_01.gd`. Pola diputuskan saat bangun. |
| `scripts/ui_misi/data_modul_02.gd` + `data_modul_03.gd` | BARU — port Modul 02/03 (.md → data). Ini pekerjaan A2 (bank soal + materi). |
| `scripts/ui_misi/ruang_belajar_ui.gd` | Chat dipersingkat (6 node) + memanggil reader modul saat "Buka Modul" + menerima kembali saat "Mulai Latihan". Class + sinyal + `tampilkan(pengajar)` TETAP supaya manajer/main tidak berubah. Simpan v1 sebagai `.bak` sampai tes hijau. |
| `scripts/ui_misi/reader_modul_ui.gd` | BARU — panel reader modul (§3): daftar isi chip, isi § (gulir), kartu tabel, kotak Rumus/Ingat, footer nav + gate 7/7. Pakai ulang pola `_build_baca_buku_panel` (ui.gd) + helper `GayaMisi` (gradien, chip, tombol). |
| `scripts/ui_misi/manajer_ui_misi.gd` | Orkestrasi fase pemandu → baca → latihan (panggil reader, terima sinyal selesai-baca). |
| `scripts/save_data.gd` | Kunci baru `rb_baca_bagian` + `rb_fase` di `default_data()`. |
| `scripts/main.gd` | Adegan belajar: isi papan tulis = judul modul + § aktif (bukan ringkasan pesan); sinyal selesai-baca → lanjut chat latihan. Perubahan kecil, di satu tempat. |
| `skrip/test_ruang_belajar_chat.gd` | Diganti/ditambah `test_ruang_belajar_v2.gd`: 6 node pemandu, reader tampil + gate 7/7 (buka § <3 detik tidak terhitung), latihan/kuis tetap, resume `rb_fase`, baca ulang tanpa poin, tanpa SCRIPT ERROR. |
| `scripts/ui_misi/data_chat_modul_01.gd` (papan) | `papan: {judul, baris[]}` per node dihapus — papan diisi dari reader (modul + § aktif), bukan dari node chat. |

**Tidak disentuh:** `dialog_misi.gd` (percakapan aturan pesantren),
`tes_kenaikan_ui.gd`, `panel_misi_ui.gd`, `data_misi_bagian.gd`,
`data_dialog_misi.gd`, `avatar_misi.gd`, `gaya_misi.gd` (helper
dipakai ulang, bukan diubah), `ui.gd` reader rak kitab (tetap untuk
kitab umum — reader modul adalah panel terpisah).

---

## 8. Pertanyaan untuk Mas (jawab saat ACC)

1. **Gate baca opsi A (semua bagian dibuka ≥3 detik) — setuju?**
   Atau tanpa gate (opsi C), atau gulir-sampai-akhir (opsi B)?
2. **Latihan + kuis tetap di chat — setuju?** Atau pindah juga ke
   dalam reader (soal tampil di bawah materi, seperti buku latihan)?
3. **Papan tulis isi judul + § aktif — setuju?** Atau papan dihapus
   saja karena materi sudah di reader?
4. **Tombol "Baca Ulang Modul"** di Ruang Belajar setelah selesai —
   perlu, atau cukup dari rak kitab saja? (Usulan: ada — biar santri
   gampang mengulang tanpa cari ustadz lagi.)
5. **Modul 02/03 ikut pola ini langsung saat datanya di-port (A2)?**
   (Usulan: ya — satu pola untuk semua modul.)

---

## 9. Rekomendasi Sinta

**Bangun v2 dengan pola di atas, Modul 01 dulu.** Ini menjawab
langsung penilaian Mas: materi kini dibaca sebagai buku yang
terstruktur (daftar isi, §, tabel kartu, contoh Arab, rumus) — dalam,
bisa diulang, strukturnya kelihatan. Chat tidak dibuang: ustadz tetap
menyapa, mengarahkan, menguji, dan memberi tugas — peran yang memang
cocok untuk dialog. Sekitar 70% sistem sudah ada (reader Tara, GayaMisi,
MesinKuis, DataModul01, banking poin di main), jadi yang baru hanya
panel reader modul + data bagian + 6 node pemandu + 2 kunci save.

Risiko utama: **konten Modul 02/03 belum ada datanya di game** — v2
untuk Modul 01 bisa jalan, tapi Modul 02/03 menunggu porting A2.
Jangan tambah video / suara bicara / animasi avatar dulu (scope —
video smartboard sudah DITUNDA Mas; suara live ustadz DITUNDA 18 Nov).
