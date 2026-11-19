# DRAF — Sistem Petunjuk Teka-Teki Mencari Guru

**Status:** DRAF v1 — 18 Nov 2026 ~23:00 WIB, oleh Laras (lead Tim Materi).
**Menunggu ACC Mas. BELUM diimplementasi ke game.**
**Asal usul:** perintah Mas 22:59 WIB — *"Misal bisa tanya ke NPC atau satpam.. jadi dibikin kek teka-teki.."*
**Berkaitan:** DRAF-ALUR-MISI.md §9 butir 18 (lokasi acak, tanpa marker — TETAP berlaku, lihat §7) dan
draf babak 5 baru (Lampiran A — perbaikan penutup dialog Ust. Aqsal, juga perintah Mas 22:59 WIB).

---

## 1. Masalah yang dipecahkan

Misi "Cari Ust. Sanusi" (putra) / "Cari Ustzh. Fatimah" (putri): lokasi guru diacak tiap misi
dimulai, tanpa marker di peta (§9 butir 18). Yang santri dengar selama ini hanya dialog babak 4:
*"Tempatnya berpindah-pindah, jadi carilah baik-baik."* — setelah itu santri dilepas tanpa
petunjuk apa pun. Santri baru yang belum hafal peta bisa kebingungan dan berhenti di tengah jalan.

Usul Mas: santri boleh BERTANYA ke NPC/satpam — tapi jawabannya bukan lokasi langsung,
melainkan TEKA-TEKI. Santri tetap harus berpikir dan mencari sendiri; yang diberi hanya arah.

---

## 2. Siapa yang bisa ditanya (dicek di tree, 18 Nov ~23:00 WIB)

### Putra — sudah ada semua, tidak perlu NPC baru

| NPC | Posisi di game | Sifat | Bisa ditanya? |
|---|---|---|---|
| Bilal | (−4, 4), patroli area putra | SantriNPC, jalan keliling | Ya |
| Faris | (−5, 8), patroli area putra | SantriNPC, jalan keliling | Ya |
| Satpam | (17, 8), diam di luar Pos Satpam | SantriNPC, diam di pos, TIDAK ikut sholat | Ya — ini yang Mas maksud "satpam" |
| Ust. Aqsal M (Kyai) | (−3,5, −2), patroli ke Surau | Pemberi misi (dialog 5 babak) | **Tidak dulu** — beliau sudah memberi tugas di babak 4; tanya ke santri lain/satpam (lihat §7) |

Sumber: `scripts/main.gd` — `npc1.setup("Bilal"...)` :714, `npc2.setup("Faris"...)` :725,
`npc5.setup("Satpam", Vector3(17,0,8)...)` :828, `_satpam = npc5` :832.

### Putri — ada celah, butuh keputusan Mas

| NPC | Posisi di game | Bisa ditanya? |
|---|---|---|
| Ustzh. Mariyah | (134, −17), pengasuh putri | Ya — wajar ditanya ulang ("Ustadzah, Fatimah di mana?") |
| Ustzh. Fatimah | lokasi acak | Tidak — beliau yang dicari |
| **Penjaga Pos Jaga putri** | **TIDAK ADA** — Pos Jaga putri (176, −20) hanya bangunan + interior, tanpa NPC penjaga | — |

Tidak ada NPC santriwati generik di area putri (hanya Mariyah & Fatimah). Opsi untuk Mas:

- **Opsi A (tanpa NPC baru):** putri hanya bisa bertanya ke Ustzh. Mariyah. Cukup, tapi satu-satunya sumber.
- **Opsi B (tambah 1 NPC):** tambah penjaga Pos Jaga putri (perempuan, diam di pos seperti Satpam
  putra, TIDAK ikut sholat) — simetri dengan putra, dan Mas sendiri yang menyebut "satpam".
- **Rekomendasi Laras: Opsi B** — murah (pola Satpam sudah ada, tinggal salin + outfit putri),
  dan membuat putri tidak kalah dari putra. Keputusan tetap di tangan Mas.

---

## 3. Cara bertanya (alur yang diusulkan)

1. **Syarat:** misi "Cari Ust. Sanusi" / "Cari Ustzh. Fatimah" sedang AKTIF (langkah 4).
   Di luar misi itu, tombol ✕ dekat NPC tetap seperti sekarang (sapaan biasa) — tidak berubah.
2. Santri mendekati NPC yang bisa ditanya → tombol **✕** muncul (mekanisme sudah ada).
3. Tekan ✕ → panel pilihan kecil (reuse UI dialog misi): **"Tanya tentang Ust. Sanusi"**
   / **"Sapa saja"** (tutup). Putri: "Tanya tentang Ustzh. Fatimah".
4. Pilih "Tanya…" → NPC menjawab dengan **satu teka-teki** (teks di §4), tampil di panel
   dialog yang sama seperti dialog misi.
5. **Teka-teki terakhir juga dicatat di Panel Misi** (bagian misi aktif, baris "Petunjuk
   terakhir: …") — supaya santri tidak lupa setelah menutup dialog. (Rekomendasi; butuh
   ACC Mas — lihat §8.)

Kalimat pembuka boleh beda tiap NPC (mis. Satpam: *"Hmm, terakhir kulihat beliau ke arah…"*,
Bilal: *"Aku tadi lihat beliau lewat, coba tebak…"*), tapi **isi teka-tekinya sama** untuk
lokasi yang sama — supaya santri tidak bingung oleh petunjuk yang bertentangan.

---

## 4. Teka-teki per lokasi (TEKS DRAF — menunggu tashih Mas)

Aturan penulisan: satu baris singkat, menunjuk ke lokasi TANPA menyebut namanya langsung.
Nama lokasi hanya ada di kolom kiri (untuk pembaca draf), TIDAK PERNAH muncul di teks teka-teki.

### Putra — 6 lokasi (`scripts/lokasi_acak.gd`, KANDIDAT)

| Lokasi (id) | Status di game | Teka-teki (teks NPC) |
|---|---|---|
| Surau (`surau`) | live | "Tempat sholat berjamaah paling ramai di pesantren — beliau sering duduk di sana menunggu waktu sholat." |
| Kelas Putra (`kelas_putra`) | rencana | "Di barat, tempat bangku berderet dan papan tulis menunggu — beliau mungkin sedang menyiapkan pelajaran di sana." |
| Taman Surau (`taman_surau`) | rencana | "Taman di balik Surau, tempat bunga dan pohon rindang — beliau suka duduk tenang di sana." |
| Perpustakaan & Taman (`perpustakaan_taman`) | lahan berpapan | "Tempat buku-buku akan tinggal — lahannya masih berpapan, tapi beliau kadang membaca di sekitar sana." |
| Masjid Besar (`masjid_besar`) | rencana | "Di timur, lahan luas yang sudah dipancang untuk bangunan besar — beliau suka melihat-lihat ke sana." |
| Kantin (`kantin`) | rencana | "Kalau perut lapar, santri larinya ke mana? Ke sanalah beliau mungkin pergi." |

**Catatan jujur (penting):** dari 6 lokasi putra, hanya **Surau yang sudah berupa bangunan jadi**;
5 lainnya masih lahan/papan/rencana. Itu tidak menghalangi sistem ini — Sanusi berdiri di
koordinatnya (bukan di dalam bangunan), jadi santri tetap bisa menemukannya di plot itu.
Tapi bila nanti Raka memfilter lokasi acak ke yang live saja (wacana di `lokasi_acak.gd`),
pencarian putra akan runtuh jadi selalu Surau. **Rekomendasi: JANGAN filter sampai
bangunan-bangunannya jadi** — biarkan 6 lokasi tetap dipakai.

### Putri — 6 lokasi (`scripts/lokasi_acak.gd`, KANDIDAT_PUTRI; semua live)

| Lokasi (id) | Teka-teki (teks NPC) |
|---|---|
| Musholla Ar-Raudhah (`musholla_putri`) | "Tempat sholat para santriwati — beliau sering duduk di sana." |
| Kelas Putri (`kelas_putri`) | "Tempat bangku berderet dan papan tulis menunggu — beliau mungkin sedang menyiapkan pelajaran di sana." |
| Taman Putri (`taman_putri`) | "Tempat bunga warna-warni bermekaran — beliau suka duduk tenang di sana." |
| Asrama Putri (`asrama_putri`) | "Gedung tempat para santriwati tidur — beliau mungkin sedang memeriksa kamar di sana." |
| Kantor Ustadzah (`kantor_ustadzah`) | "Tempat para ustadzah mengurus pesantren — beliau mungkin sedang di sana." |
| Halaman Putri (`halaman_putri`) | "Halaman terbuka di tengah kawasan putri — beliau suka berjalan-jalan di sana." |

---

## 5. Cara sistem memilih teka-teki yang SESUAI lokasi guru saat itu

1. Saat misi "cari guru" dimulai, lokasi guru diacak **sekali** (`LokasiAcak.lokasi_berikutnya`)
   dan disimpan di save — kunci yang **sudah ada**: `sanusi_lokasi` / `fatimah_lokasi`
   (di `onboarding.gd`). Tidak ada kunci save baru untuk lokasi.
2. Saat santri bertanya, sistem **membaca id lokasi dari save itu**, lalu mengambil teka-teki
   dari tabel baru `TEKA_TEKI` (id lokasi → teks) di file data baru yang diusulkan,
   `scripts/ui_misi/data_teka_teki.gd` — pola sama seperti `data_dialog_misi.gd`
   (data murni, tanpa UI).
3. Semua NPC memberi teka-teki yang **sama** untuk lokasi yang sama (lihat §3) — yang boleh
   beda hanya kalimat pembuka tiap NPC.
4. **Jaga-jaga:** bila save kosong / id tidak valid (seharusnya tidak terjadi), NPC menjawab
   sapaan biasa + *"Coba tanya lagi nanti"* — JANGAN bocorkan lokasi, JANGAN crash.

---

## 6. Batasan anti-spam

- **Satu NPC, satu petunjuk per misi.** Setelah memberi teka-teki, NPC yang sama bila ditanya
  ulang (sebelum misi selesai) menjawab: *"Itu tadi petunjuknya — coba cari dulu, nanti tanya
  lagi kalau masih bingung."* (Flag per-NPC disimpan di save, mis. kunci baru `tanya_guru`
  — detail implementasi, diputuskan saat coding.)
- **Tanya ke NPC LAIN tetap boleh** — tapi teka-tekinya sama (bukan petunjuk baru). Jadi
  spam ke banyak NPC tidak memberi info lebih; yang dibatasi hanya pengulangan ke NPC yang sama.
- **Bertanya GRATIS, tanpa biaya poin.** Bertanya itu adab yang baik — jangan dihukum.
- **Setelah guru ditemukan** (misi lanjut ke langkah berikut), pilihan "Tanya tentang guru"
  hilang — ✕ kembali ke sapaan biasa.

---

## 7. Yang TIDAK diubah

- **Tetap tanpa marker di peta (§9 butir 18).** Teka-teki BUKAN marker — santri tetap harus
  mencari sendiri dengan kakinya. Bila Mas suatu hari mau marker, itu keputusan baru yang
  mengubah butir 18 — bukan bagian draf ini.
- Lokasi tetap **acak tiap misi dimulai** (`REFRESH_PER_MISI = true`).
- Dialog Kyai/Mariyah **babak 1–4 tidak berubah**; hanya babak 5 (Lampiran A) + alur tanya (baru).
- **Putra: tidak ada NPC baru** (Bilal/Faris/Satpam sudah ada). Putri: NPC penjaga Pos Jaga
  hanya bila Mas memilih Opsi B (§2).
- Semua teks di draf ini = **TEKS DRAF**, menunggu tashih Mas (sama seperti dialog misi).

---

## 8. Yang masih butuh keputusan Mas

1. **Putri: Opsi A (hanya Mariyah) atau Opsi B (tambah penjaga Pos Jaga putri)?**
   (Rekomendasi Laras: Opsi B.)
2. **Teka-teki terakhir ditampilkan di Panel Misi?** (Rekomendasi: ya.)
3. **Kyai/Mariyah boleh ditanya ulang setelah percakapan 5 babak selesai?**
   (Rekomendasi: tidak dulu — beliau sudah memberi tugas; tanya ke santri lain/satpam.)

---

## Lampiran A — Draf babak 5 baru (perbaikan penutup dialog Ust. Aqsal)

**Masalah (ditemukan Xam):** `TEKS_BABAK_5` yang lama — *"Penutup — santri mengiyakan, misi
'Cari Ust. Sanusi' terbuka."* — adalah catatan panggung, BUKAN kalimat yang diucapkan Kyai.
Pilihan jawabannya pun mengulang babak 1 (*"Baik, Ustadz. Saya siap belajar."*).
**Babak 1–4 TIDAK diubah** (Mas hanya menegur penutup).

### Teks baru (TEKS DRAF — menunggu tashih Mas)

**Putra** (`TEKS_BABAK_5_PUTRA`):
> "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat
> belajarnya. Sekarang berangkatlah mencari Ust. Sanusi — beliau yang akan mengajarimu
> Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya
> saja ke santri lain atau ke satpam di pos jaga. Semoga Allah mudahkan langkahmu."

**Putri** (`TEKS_BABAK_5_PUTRI`) — ditulis terpisah (mengikuti pola babak 1 yang sudah punya
konstanta PUTRA/PUTRI sendiri), karena pengait bertanyanya beda: putri TIDAK punya satpam:
> "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat
> belajarnya. Sekarang berangkatlah mencari Ustzh. Fatimah — beliau yang akan mengajarimu
> Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya
> saja ke santriwati lain atau kembali ke saya. Semoga Allah mudahkan langkahmu."

**Pilihan jawaban santri** (keduanya `ke: -1`, percakapan selesai — ini pamit, bukan ulangan
babak 1; sapaan mengikuti gender seperti pola yang sudah ada):
1. *"Baik, Ustadz/Ustadzah. Saya berangkat mencari beliau sekarang."* → −1
2. *"Terima kasih, Ustadz/Ustadzah. Saya pamit dulu."* → −1

**Catatan implementasi (untuk Raka, bila Mas ACC):** di `data_dialog_misi.gd`, babak 5 memakai
pola babak 1 — `teks = TEKS_BABAK_5_PUTRI if putri else TEKS_BABAK_5_PUTRA` — dan blok
substitusi mekanis `replace("Ust. Sanusi", "Ustzh. Fatimah")` untuk babak 5 tidak lagi
diperlukan (sudah tertulis langsung di konstanta PUTRI). Babak 4 tetap memakai substitusi
mekanis seperti sekarang.
