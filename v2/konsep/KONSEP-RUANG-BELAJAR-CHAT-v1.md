# KONSEP — Ruang Belajar versi CHAT (Dialog Mengajar) v1

**Ide Mas (19 Nov 2026, 14:35 WIB):** Ruang Belajar diubah jadi sistem dialog
seperti mengajar betulan — player berdialog dengan ustadznya, modelnya seperti
chat: pesan ustadz muncul seperti sedang diketik (efek ketik), lalu player
menjawab seperti di game-game. BUKAN kolom ketik bebas — jawaban lewat tombol
pilihan (pola dialog game yang sudah ada).

**Status:** KONSEP — menunggu ACC Mas. Kode game TIDAK diubah.
**Gambar:** `konsep-ruang-belajar-chat-v1.png` (menunggu jawaban),
`konsep-ruang-belajar-chat-ketik-v1.png` (efek ketik + cabang),
`konsep-ruang-belajar-chat-alur-v1.png` (diagram alur).
**REVISI GENSHIN (19 Nov 14:50, §7):** `konsep-ruang-belajar-genshin-v1.png`
(menunggu jawaban), `konsep-ruang-belajar-genshin-ketik-v1.png` (efek ketik
+ cabang). Mockup gelembung chat v1 DIGANTI tampilannya oleh §7 — alur,
naskah, dan poin TIDAK berubah.
**REVISI DUDUK + BICARA (19 Nov 15:00, §8):** `konsep-ruang-belajar-genshin-duduk-v1.png`
(Sanusi duduk + papan tulis, menunggu jawaban),
`konsep-ruang-belajar-genshin-duduk-bicara-v1.png` (sedang bicara — TANPA
status mengetik, TANPA tombol terkunci),
`konsep-ruang-belajar-genshin-duduk-fatimah-v1.png` (putri: Ustzh. Fatimah
duduk + papan tulis, latar Musholla). Mockup Genshin §7 DIGANTI oleh §8 —
alur, naskah, dan poin TIDAK berubah.
**Skrip gambar:** `gambar_ruang_belajar_chat.py` (PIL, palet GayaMisi),
`gambar_ruang_belajar_genshin.py` (revisi Genshin),
`gambar_ruang_belajar_genshin_duduk.py` (revisi §8).

**Catatan angka (jujur):** brief menyebut "10 materi + 15 latihan + 10 kuis" —
itu isi dokumen Modul 01. Yang sudah masuk game hari ini
(`data_modul_01.gd` + `ruang_belajar_ui.gd`): materi 4 kartu (kalam, 3 kartu
kata, rumus, bait), latihan 5 soal, kuis 1 soal (dari bank 10 soal N1.T).
Konsep ini memetakan isi game yang ADA. Bila isi dokumen penuh masuk nanti,
pola yang sama dipakai (tiap § jadi 1–3 pesan).

---

## 1. Tampilan (mockup A + B)

> **REVISI 19 Nov 14:50 — gaya Genshin (referensi Mas, §7):** tampilan
> gelembung chat di dalam panel di bawah ini DIGANTI: portrait ustadz
> BESAR di dunia + kotak dialog bawah dengan nama emas + baris player
> sebagai gelembung kecil. Alur (§2), naskah, aturan (§3), dan poin
> TIDAK berubah — yang berubah hanya tampilannya. Mockup A + B di bawah
> ini (gelembung chat) sudah tidak dipakai; pakai mockup Genshin §7.
>
> **REVISI 19 Nov 15:00 — ustadz BICARA + DUDUK (§8):** dua hal di §7
> DIHAPUS — status "sedang mengetik" dan tombol jawaban terkunci/redup
> — karena ustadz sedang BICARA, bukan mengetik; dan ustadz DUDUK dengan
> papan tulis kecil di sampingnya. Lihat §8.

Panel yang sama seperti sekarang (gradien zamrud + rim emas, lebar 1480 / 96%
landscape, dim di belakang) — isinya diganti chat:

- **Header:** tab emas "RUANG BELAJAR", judul "Nahwu Dasar — Modul 01",
  subjudul "Mengenal Kata • Bagian 1 (Hijau)", baris pengajar: medali avatar +
  "Ust. Sanusi" / "Pengajar Nahwu Dasar" + titik hijau "sedang mengajar".
  Putri: pengajar "Ustzh. Fatimah", avatar jilbab krem — alur dan pesan SAMA.
- **Gelembung ustadz (kiri):** kartu zamrud gelap + outline krem tipis, nama
  kecil emas di pesan pertama, jam kecil di kanan bawah, medali mini di kiri.
- **Gelembung player (kanan):** isi emas, teks zamrud gelap — jawaban yang
  dipilih dari tombol langsung jadi gelembung.
- **Efek bicara (REVISI §8, 19 Nov 15:00 — dulu "efek ketik"):** ustadz
  sedang BICARA, bukan mengetik — jadi TIDAK ADA lagi status "sedang
  mengetik…" dan TIDAK ADA lagi gelembung tiga titik "berpikir". Huruf
  muncul satu-satu ±40 ms/karakter sebagai EFEK BICARA (alasan di §8),
  kursor blok emas di ujung teks = penanda "sedang bicara", hilang
  begitu kalimat selesai. **Tap kotak dialog = tampil penuh** (lewati
  bicara). Selama ustadz bicara, tombol jawaban TIDAK TAMPIL sama sekali
  — bukan redup/terkunci; begitu kalimat selesai, pilihan muncul
  langsung aktif penuh.
- **Tombol jawaban (di bawah chat):** maks 2 untuk cek ("Paham, lanjut ›"
  emas / "Belum, jelaskan lagi" outline); 4 untuk soal (A–D outline, huruf
  seperti sekarang). Pola tombol = DialogMisi (emas pertama + panah ›).
- **Footer:** ~~"Pesan X dari 14 • Materi/Latihan/Kuis" +~~ bilah progres
  emas + chip "× Tutup". **(Teks "Pesan X dari 14" DIHAPUS §8,
  19 Nov 15:09 — hanya bilah emas yang tetap.)** Pill 3 langkah
  ("Materi/Latihan/Kuis") DIGANTI bilah progres — posisi dalam
  percakapan lebih penting daripada nama langkah.
- **Catatan mockup:** "×" di mockup ditulis "×" (U+00D7) karena Baloo 2 di
  PIL tak membawa glif "✕" (U+2715); di game tetap "✕" seperti sekarang.
  Contoh Arab di mockup ditulis transliterasi (PIL tak membentuk huruf
  Arab); di game tetap font Amiri seperti sekarang.

---

## 2. Naskah percakapan Modul 01 (14 pesan)

Semua teks di bawah = TEKS DRAF (menunggu tashih Modul 01/02 seperti
sekarang). Isi diambil PERSIS dari `DataModul01` — hanya diubah bentuknya
dari kartu/soal menjadi kalimat ustadz.

### Materi (7 pesan, mengalir otomatis)

| # | Pesan ustadz |
|---|---|
| 1 | "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar — Modul 01: Mengenal Kata." |
| 2 | "kalam itu artinya adalah susunan kalimat. Kalimat disini maksudnya adalah kata dalam bahasa indonesia. Paham?" — **contoh PERSIS Mas.** → CEK 1 |
| 3 | "Kata itu ada tiga macam. Pertama, isim — kata benda dan nama. Cirinya: tanwin, al-, dan jer. Contohnya madrasatun — sekolah." |
| 4 | "Kedua, fi'il — kata kerja yang terikat waktu. Cirinya: qad, sin, dan saufa. Contohnya yaqra'u — dia sedang membaca." |
| 5 | "Ketiga, huruf — kata penghubung yang kecil. Dia baru bermakna bila digabung dengan kata lain. Contohnya 'alaa — di atas." |
| 6 | "Ada rumus cepatnya — hafalkan ini: ada tanwin atau al-? Itu isim. Ada qad, sin, atau saufa? Itu fi'il. Kata pendek penghubung? Itu huruf." |
| 7 | "Terakhir, hafalkan bait ini: 'Kata itu tiga, hafalkanlah: isim, fi'il, dan huruf yang datang untuk suatu makna — maka ketahuilah ia.'" |

**CEK 1 (setelah pesan 2):** tombol "Paham, lanjut ›" / "Belum, jelaskan lagi".

- **Belum (ke-1):** "Baik, coba contoh ini: Qaama Muhammadun — 'Muhammad telah
  berdiri.' Itu kalam, karena pendengar sudah paham dan tidak bertanya lagi.
  Kalau saya hanya bilang 'Muhammad' saja, kamu pasti bertanya: Muhammad
  kenapa? Itu belum kalam. Paham sekarang?" → CEK 1b.
- **Belum (ke-2):** "Tidak apa-apa, pelan-pelan. Ingat saja ini: kalam =
  susunan kata yang memberi arti sempurna. Kita lanjut dulu, nanti ketemu
  lagi di latihan. Siap?" → tombol "Siap, lanjut" → lanjut otomatis ke
  pesan 3. **Tidak ada pilihan Belum ketiga** (supaya tidak muter tanpa
  ujung).

**CEK AKHIR (setelah pesan 7):** "Sudah paham semua? Kalau sudah, kita
latihan." → "Paham, mulai latihan" / "Belum, ulangi dari awal".
Belum → ulang materi dari pesan 2 (maks 1× ulang penuh), lalu lanjut ke
latihan apa pun jawabannya. **→ +10 poin materi** (emit `langkah_selesai`
"materi", sama seperti sekarang).

### Latihan (5 pesan soal, L1–L5)

Ustadz mengirim soal sebagai pesan + 4 tombol opsi. **Salah → ustadz
menjelaskan (memakai "petunjuk" dari data) + soal yang sama diulang,
opsi yang salah dimatikan** (pola sekarang). Benar → pujian ustadz + lanjut.

| # | Soal ustadz | Benar → | Salah → |
|---|---|---|---|
| L1 | "Coba tebak — madrasatun (sekolah) itu jenis kata apa?" | "Benar! Bertanwin, jadi isim." | "Belum tepat. Madrasatun bertanwin — jadi isim. Coba lagi." |
| L2 | "yaqra'u (dia sedang membaca) itu jenis kata apa?" | "Benar! Kata kerja mudhori', terikat waktu." | "Belum tepat. Yaqra'u itu kata kerja mudhori' — terikat waktu. Coba lagi." |
| L3 | "'alaa (di atas) itu jenis kata apa?" | "Benar! Kata penghubung, tidak berciri isim maupun fi'il." | "Belum tepat. 'Alaa itu kata penghubung. Coba lagi." |
| L4 | "qalamun (pena) itu jenis kata apa?" | "Benar! Bertanwin, jadi isim." | "Belum tepat. Qalamun bertanwin. Coba lagi." |
| L5 | "jalasa (dia telah duduk) itu jenis kata apa?" | "Benar! Kata kerja madhi, perbuatan lampau." | "Belum tepat. Jalasa itu kata kerja madhi. Coba lagi." |

**→ +15 poin latihan** setelah 5 soal benar.

### Kuis (1 pesan soal, K1 — soal pertama bank N1.T)

"Terakhir, satu soal kuis: Apa yang dipelajari ilmu Nahwu?" — opsi:
Perubahan akhir kata (i'rab) / Cara menghafal Al-Quran / Sejarah Islam /
Cara berwudhu. Benar → lanjut penutup. Salah → "Belum tepat. Nahwu itu
ilmu tentang perubahan akhir kata (i'rab). Coba lagi." → ulang soal.
**→ +10 poin kuis.**

### Penutup (pesan 14)

"Alhamdulillah, Modul 01 tuntas. Kamu dapat 35 poin. Besok kita lanjut
Modul 02 — atau langsung tes kenaikan di Surau." + kartu "Selesai — 35
poin" + tombol "Tutup" → emit `selesai(35)` → maju langkah 5→6 (tes
kenaikan), toast seperti sekarang.

---

## 3. Aturan main

- **Pesan materi mengalir otomatis:** setelah satu pesan selesai
  diucapkan, jeda ±800 ms, lalu pesan berikut mulai diucapkan. Berhenti
  HANYA di titik "Paham?" dan di soal. Tap kotak dialog = tampil penuh
  (tidak menunggu).
- **Tombol jawaban TIDAK PERNAH terkunci/redup (REVISI §8):** selama
  ustadz bicara, pilihan jawaban tidak tampil; begitu kalimat selesai,
  pilihan muncul langsung aktif penuh. Tidak ada status "sedang
  mengetik" di mana pun.
- **Tutup di tengah → lanjut dari pesan terakhir.** Kunci save baru
  `rb_chat_pos` (indeks node terakhir SELESAI) + `rb_chat_modul` (modul yang
  sedang berjalan). Buka lagi → riwayat sampai posisi itu dibangun
  TANPA efek bicara (langsung penuh), lalu lanjut node berikut.
  **Poin langkah yang sudah selesai TIDAK hilang** — main sudah membank
  poin per langkah saat sinyal `langkah_selesai` diterima (`rb_selesai`
  "1:materi" dst, `main.gd` — tidak berubah).
- **Buka ulang setelah selesai → mode baca ulang:** riwayat tampil penuh
  tanpa efek bicara, tombol hanya "Tutup" — TANPA poin lagi (guard
  `rb_selesai` yang sudah ada).
- **Anti-farming tetap:** `rb_selesai` + sinyal `langkah_selesai` /
  `selesai` tidak berubah; main.gd tidak berubah.
- **Bukan pengajian kitab:** ide "suara live ustadz / santri duduk pegang
  kitab" (Mas, 18 Nov) DITUNDA — konsep ini tetap chat teks, dalam koridor
  Ruang Belajar + dialog misi yang sudah ACC.

---

## 4. Catatan teknis (untuk yang membangun)

### Dipakai ulang (tidak ditulis dari nol)

- **GayaMisi:** palet, `gaya_panel_gradien`, `gaya_kartu`,
  `buat_tombol_emas` / `buat_tombol_outline`, `buat_chip`, `buat_label` (+
  `buat_label_arab` Amiri), `buat_tab_judul`, `buat_bilah_progres`,
  animasi masuk 180 ms + umpan tekan 0.97.
- **DialogMisi:** pola PanelContainer + dim + manajer, header tab+✕,
  footer chip keycap, tombol pilihan (emas pertama + panah ›), sinyal
  `selesai` / `ditutup`, animasi masuk.
- **AvatarMisi:** medali Sanusi / Fatimah. ⚠️ **FLAG:** tipe "sanusi"
  masih menggambar songkok PUTIH; build Kirana 19 Nov memberi Sanusi peci
  hitam NASIONAL (rata) → medali perlu diperbarui (±10 baris di `_gambar`)
  supaya avatar chat sama dengan Sanusi di dunia. Fatimah ("ustadzah",
  jilbab krem) sudah cocok.
- **MesinKuis + DataModul01:** data TIDAK berubah — soal + "petunjuk"
  dipakai ulang (petunjuk jadi kalimat ustadz saat jawaban salah).
- **main.gd + ManajerUIMisi:** TIDAK berubah — `buka_ruang_belajar(pengajar)`
  + LEBAR 1480 / fraksi 0.96 tetap; sinyal `langkah_selesai` / `selesai`
  tetap; poin per langkah + maju langkah 5→6 tetap.

### Baru

- **Data percakapan** — file baru `scripts/ui_misi/data_chat_modul_01.gd`
  (class `DataChatModul01`, pola `DataDialogMisi`): array node
  `{id, tipe: "pesan"|"cek"|"soal"|"penutup", teks, opsi[], cabang}`.
  Data murni, tanpa UI. Naskah §2 masuk sini.
- **UI chat** — `scripts/ui_misi/ruang_belajar_ui.gd` ditulis ulang isinya
  jadi chat. Class + sinyal + `tampilkan(pengajar)` TETAP supaya
  manajer/main tidak berubah. Simpan versi lama sebagai
  `ruang_belajar_ui.gd.bak` sampai tes hijau.
- **Efek bicara (REVISI §8 — dulu "efek ketik")** — Timer per karakter
  ±40 ms (konstanta `BICARA_MS_PER_HURUF`); TIDAK ADA jeda "berpikir"
  dan TIDAK ADA gelembung tiga titik; tap kotak dialog → tampil penuh.
  Kursor blok = ColorRect tipis berkedip di akhir teks (BUKAN glif font
  — "▍" tidak ada di Baloo 2) = penanda "sedang bicara", hilang begitu
  kalimat selesai dan pilihan jawaban muncul.
- **Gelembung** — helper baru di `GayaMisi`: `gaya_gelembung_ustadz()`
  (ZAMRUD_KARTU + outline krem alpha 120, radius 16) +
  `gaya_gelembung_pemain()` (EMAS isi, teks ZAMRUD_GELAP, radius 16).
  ScrollContainer + auto-scroll ke bawah tiap pesan baru
  (`scroll_vertical` maks, deferred satu frame).
- **Tombol jawaban** — dibangun ulang tiap node (pola `_pilihan_box`
  DialogMisi); TIDAK PERNAH terkunci/redup — muncul setelah kalimat
  selesai diucapkan, langsung aktif penuh (REVISI §8).
- **Duduk + papan tulis (REVISI §8)** — saat dialog dibuka, ustadz
  DUDUK di atas tikar dengan papan tulis KECIL di sampingnya. Pose duduk
  dipakai ulang dari yang sudah ada (`_terapkan_duduk_baca` /
  PAKAIAN_DUDUK di `player.gd`/`npc.gd` — pose yang sama dipakai NPC
  saat baca kitab). Papan tulis = prop kecil di dunia di samping ustadz
  (papan putih + bingkai emas di atas kaki easel) + teks keterangan
  (Label3D / Control) yang isinya mengikuti pesan yang sedang dibahas
  (contoh: pesan kalam → papan "kalam = susunan kalimat"; penjelasan
  ulang → papan "Qaama Muhammadun"). Isi papan v1 = transliterasi/Latin
  saja — teks Arab di panel sedang diselidiki Tara (temuan Mas 19 Nov
  15:00: teks Arab + sebagian ikon di panel tidak terbaca; klarifikasi
  15:02: biasanya yang di PANEL) — tulisan Arab di papan mengikuti
  hasil penyelidikan itu, JANGAN dipaksakan dulu.
- **Resume** — kunci save baru `rb_chat_pos` + `rb_chat_modul` — WAJIB
  tambah di `save_data.gd default_data()` (pelajaran lama: kunci baru
  yang tidak ada di sana tidak tersalin saat load).
- **Tes** — skrip baru `test_ruang_belajar_chat.gd` (pola test_ui_misi):
  14 pesan lengkap, cabang Belum 2×, jawaban salah lalu benar, resume
  dari `rb_chat_pos`, mode baca ulang tanpa poin, tanpa SCRIPT ERROR.
  Hijau sebelum gate.

---

## 5. Pertanyaan untuk Mas (jawab saat ACC)

1. Kecepatan bicara ±40 ms/huruf — terlalu lambat / cepat? (Usulan: 40 ms,
   tap = lewati.)
2. Materi mengalir otomatis (ustadz lanjut sendiri setelah jeda ±800 ms)
   atau tiap pesan butuh tap "Lanjut"? (Usulan: otomatis — lebih terasa
   mengajar.)
3. Cabang "Belum" maks 2× lalu ringkasan + lanjut — setuju? (Supaya tidak
   muter tanpa ujung.)
4. Suara saat ustadz bicara (efek suara)? (Usulan: tidak ada dulu — jaga
   scope; suara live ustadz sudah DITUNDA Mas 18 Nov.)
5. Putri: pesan dan alur sama, pengajar Ustzh. Fatimah — setuju?

---

## 6. Rekomendasi Sinta

**Bangun v1 untuk Modul 01 saja, dengan pola di atas.** Ini lebih hidup
dari form 3 langkah sekarang dan lebih dekat ke "mengajar betulan" yang
Mas maksud — ustadz yang bertanya "Paham?" lalu menjelaskan lagi kalau
belum paham, persis seperti di kelas. Sekitar 70% sistem sudah ada
(GayaMisi, DialogMisi, MesinKuis, DataModul01, banking poin di main), jadi
yang baru hanya data percakapan + efek bicara + gelembung + resume.

Risiko utama: naskah = TEKS DRAF (menunggu tashih Modul 01/02) — isi final
tetap dari Tim Kurikulum + tashih Mas, bukan dari konsep ini. Jangan tambah
suara bicara / animasi avatar / suara ustadz dulu (scope — suara live
ustadz sudah DITUNDA Mas 18 Nov).

---

## 7. Revisi 19 Nov 14:50 — Gaya GENSHIN (referensi Mas)

**Referensi Mas (gambar Genshin, 14:50):** dialog mau seperti Genshin —
portrait karakter tampil BESAR, kotak dialog di bawah dengan NAMA
pembicara emas, baris player sebagai gelembung kecil. Gambar referensi:
`workspace/user/files/1795074645570_6_ljwa.jpeg`.

**Yang TIDAK berubah:** alur 14 pesan (§2), poin 35, cabang "Belum" maks
2×, efek bicara (dulu "efek ketik" — direvisi §8), resume `rb_chat_pos`,
anti-farming (§3), diagram alur.
Yang berubah HANYA tampilannya.

### Anatomi referensi Genshin (yang ditiru)

- **Portrait besar:** karakter pembicara tampil BESAR di dunia (bukan
  medali kecil) — setengah atas layar adalah karakternya.
- **Kotak dialog bawah:** kotak gelap tembus pandang di ~30% bawah layar;
  nama pembicara ("Elynas") EMAS di kiri atas kotak + garis emas di
  bawah nama; teks pesan putih di bawahnya.
- **Baris player = gelembung kecil:** kalimat player muncul sebagai
  gelembung kecil di ATAS kotak dialog (kanan), dengan ikon chat kecil
  di kirinya — bukan gelembung besar di dalam chat.
- **Tombol "Auto"** kecil di kiri atas layar (putar dialog otomatis).
- **Pilihan jawaban = gelembung melayang:** saat memilih, opsi tampil
  sebagai gelembung di tengah layar, di atas kotak dialog.
- **Dunia tetap terlihat:** latar belakang adalah dunia game yang sedang
  berjalan (karakter lain kecil di dunia, seperti Paimon).

### Adaptasi ke Ruang Belajar (mockup Genshin)

**Gambar:** `konsep-ruang-belajar-genshin-v1.png` (menunggu jawaban
"Paham?"), `konsep-ruang-belajar-genshin-ketik-v1.png` (efek ketik +
cabang "Belum"). Skrip: `gambar_ruang_belajar_genshin.py`.
> **REVISI §8 (19 Nov 15:00):** mockup `...-ketik-v1.png` di atas
> DIGANTI — status "sedang mengetik" + tombol redup dihapus, ustadz
> DUDUK + papan tulis kecil. Pakai mockup §8.

- **Portrait = karakter 3D ustadz di dunia (live, bukan aset baru).**
  Saat dialog dibuka, kamera membingkai ustadz besar di kanan layar
  (seperti mockup: Ust. Sanusi peci hitam nasional + jubah putih).
  Putri: Ustzh. Fatimah (jilbab krem) — sama.
- **Kotak dialog bawah:** gelap tembus pandang + garis emas di tepi atas
  (palet GayaMisi, BUKAN panel gradien v1); nama "Ust. Sanusi" emas
  tebal + garis emas di bawahnya; teks putih; "× Tutup" kecil di kanan
  atas kotak.
- **Baris player = gelembung kecil** di atas kotak (kanan) dengan ikon
  chat (lingkaran + tiga titik): "Belum, jelaskan lagi."
- **Pilihan jawaban = gelembung melayang** di tengah layar: "Paham,
  lanjut ›" emas / "Belum, jelaskan lagi" outline gelap.
  ~~Selama ustadz mengetik, keduanya REDUP (terkunci).~~ **DIHAPUS §8:**
  pilihan tidak tampil selama ustadz bicara; begitu kalimat selesai,
  muncul langsung aktif penuh — tidak pernah redup/terkunci.
- **Tombol "Auto" kiri atas** = saklar alur otomatis (pertanyaan §5
  no. 2): Auto ON = materi mengalir sendiri; Auto OFF = tiap pesan
  butuh tap.
- **Progres tetap ada** — bilah emas tipis di tepi bawah kotak.
  ~~+ teks kecil "Pesan X dari 14 • Materi" di kanan bawah kotak.~~
  **DIHAPUS §8 (koreksi Mas 19 Nov 15:09)** — penghitung pesan
  dihapus; bilah emas tipis tetap sebagai progres tanpa teks.
- **Efek bicara (REVISI §8 — dulu "efek ketik"):** huruf muncul
  satu-satu + kursor blok emas (digambar, bukan glif font) = penanda
  "sedang bicara". ~~Status "Ust. Sanusi sedang mengetik…" di kiri
  bawah kotak.~~ **DIHAPUS §8** — tidak ada lagi status mengetik di
  mana pun.
- **Riwayat tidak tampil sebagai scrollback** (Genshin hanya menampilkan
  satu pesan): ditambah tombol kecil "Riwayat" di kotak dialog untuk
  membuka log percakapan (daftar pesan yang sudah lewat) — lihat
  pertanyaan no. 6 di bawah.
- **Catatan mockup:** latar = render gerbang (stand-in dunia); di game
  latarnya dunia LIVE tempat ustadz berdiri (plaza/Surau/musholla).
  Santri kecil di tengah latar = player di dunia (seperti Paimon).
  Potret di mockup dipotong dari foto songkok-v2 Sanusi; di game potret
  adalah karakter 3D-nya langsung.

### Catatan teknis (tambahan dari §4)

- **Portrait live:** dialog dibuka dengan kamera membingkai ustadz
  (handoff kamera di `main.gd`/manajer saat `buka_ruang_belajar`) —
  TIDAK ada aset portrait baru; yang dipakai karakter 3D yang sudah
  ada. Setelah dialog ditutup, kamera kembali ke player.
- **Kotak dialog:** helper baru di GayaMisi (mis.
  `gaya_kotak_dialog_genshin()`: gelap tembus pandang + garis emas
  tepi atas + nama emas + garis bawah nama). Panel gradien v1 TIDAK
  dipakai di tampilan ini.
- **Gelembung kecil player + pilihan melayang:** helper baru di
  GayaMisi (gelembung kecil + ikon chat; pilihan melayang emas/outline
  — TANPA status redup, lihat §8). Helper gelembung chat v1
  (`gaya_gelembung_ustadz` / `gaya_gelembung_pemain`) TIDAK dipakai
  dalam tampilan Genshin — coret dari scope build.
- **Tombol "Auto":** chip kecil kiri atas, saklar boolean
  `rb_auto` (default ON = alur otomatis §3); tap = toggle.
- **Tombol "Riwayat":** membuka panel log sederhana (daftar pesan
  sampai posisi sekarang, tanpa efek bicara) — pakai ulang pola Scroll.
- **Sisanya sama seperti §4:** data percakapan, efek bicara, resume
  `rb_chat_pos` + `rb_chat_modul`, tes `test_ruang_belajar_chat.gd`
  (tambah cek: portrait ustadz tampil, kotak dialog di bawah, gelembung
  kecil player, Auto toggle, Riwayat).

### Pertanyaan tambahan untuk Mas (di luar §5)

6. Tombol "Riwayat" (log percakapan) perlu, atau cukup lanjut dari pesan
   terakhir tanpa log? (Usulan: ada, kecil di pojok kotak dialog.)

### Rekomendasi Sinta (revisi)

Bangun v1 Modul 01 dengan tampilan Genshin ini, bukan tampilan gelembung
chat v1 — tampilannya lebih dekat ke game yang Mas tunjukkan, dan
portrait besar membuat ustadznya terasa hadir mengajar, bukan sekadar
teks. Biayanya sama dengan v1 (yang baru hanya gaya kotak + gelembung
kecil + pilihan melayang + Auto + Riwayat; data, alur, dan poin tidak
berubah).

---

## 8. Revisi 19 Nov 15:00 — Ustadz BICARA (bukan mengetik) + DUDUK + papan tulis

**Koreksi Mas (19 Nov 15:00):**
1. "Tidak usah ustadz sanusi mengetik… karena ini dia lagi bicara."
   → HAPUS status "Ust. Sanusi sedang mengetik…" + tombol jawaban
   terkunci/redup.
2. "Saat belajar ke ustadz sanusi… maka duduk sambil ada papan tulis
   kecil buat keterangan."
   → Saat belajar, ustadz DUDUK dengan papan tulis KECIL di sampingnya
   untuk keterangan.

**Koreksi Mas (19 Nov 15:09):**
3. "Tidak usah pesan .. dari ..." → HAPUS tulisan "Pesan X dari 14 •
   Materi" (penghitung pesan di pojok kanan bawah kotak dialog).
   Bilah emas tipis di tepi bawah kotak TETAP sebagai indikator
   progres tanpa teks. Ketiga mockup §8 di-render ulang tanpa teks
   penghitung.

**Yang TIDAK berubah:** alur 14 pesan (§2), poin 35, cabang "Belum" maks
2×, resume `rb_chat_pos`, anti-farming (§3), diagram alur, tampilan
dasar Genshin (§7: portrait besar + kotak dialog bawah + nama emas +
gelembung kecil player + Auto + Riwayat).

### Gambar (baru)

- `konsep-ruang-belajar-genshin-duduk-v1.png` — Sanusi DUDUK di atas
  tikar + papan tulis kecil ("KALAM — kalam = susunan kalimat"), menunggu
  jawaban "Paham?" (pilihan aktif penuh).
- `konsep-ruang-belajar-genshin-duduk-bicara-v1.png` — Sanusi sedang
  BICARA (penjelasan ulang contoh Qaama Muhammadun): teks muncul
  progresif + kursor blok emas, TANPA status mengetik, TANPA pilihan
  jawaban di frame itu; papan tulis mengikuti pesan ("CONTOH — Qaama
  Muhammadun").
- `konsep-ruang-belajar-genshin-duduk-fatimah-v1.png` — Putri: Ustzh.
  Fatimah DUDUK + papan tulis, latar Musholla, pesan dan alur SAMA.
- Skrip: `gambar_ruang_belajar_genshin_duduk.py`.

### 1. Ustadz BICARA — apa yang dihapus, apa yang tetap

**DIHAPUS total:**
- Status "Ust. Sanusi sedang mengetik…" (dan segala variannya) — tidak
  ada lagi di mana pun.
- Gelembung tiga titik "berpikir" sebelum pesan.
- Tombol jawaban TERKUNCI / REDUP dalam keadaan apa pun.

**TETAP — efek huruf muncul satu-satu, sekarang bernama EFEK BICARA.
Alasan Sinta memilih ini (bukan tampil langsung penuh):**
- Di dialog visual-novel (termasuk Genshin yang Mas tunjukkan), teks
  yang muncul progresif DIBACA sebagai ucapan tokoh yang sedang bicara
  — bukan sebagai ketikan. Yang membuatnya terasa "mengetik" dulu
  bukanlah hurufnya, melainkan status "sedang mengetik…" + tombol
  terkunci yang menyiratkan keyboard/HP. Begitu keduanya dihapus,
  huruf progresif + kursor blok hanya berarti "beliau sedang bicara".
- Efek ini memberi ritme belajar: player membaca mengikuti ucapan
  ustadz, dan tap kotak dialog = tampil penuh (lewati ucapan) tetap
  memberi kendali ke player.
- Tampil langsung penuh akan membuat kalimat panjang (mis. penjelasan
  ulang) jadi tembok teks tanpa jeda — lebih berat dibaca di HP.

**Aturan baru (menggantikan "terkunci selama mengetik"):**
- Selama ustadz bicara → pilihan jawaban TIDAK TAMPIL sama sekali.
- Begitu kalimat selesai → pilihan muncul langsung AKTIF penuh.
- Kursor blok emas = penanda "sedang bicara"; hilang begitu kalimat
  selesai dan pilihan muncul.

### 2. DUDUK + papan tulis kecil

- **Adegan belajar:** ustadz DUDUK di atas tikar (bukan berdiri),
  kamera membingkai beliau besar di kanan layar seperti mockup §7 —
  hanya posisinya lebih rendah, di atas tikar. Putri: Ustzh. Fatimah
  duduk di Musholla, sama.
- **Papan tulis kecil:** easel di samping ustadz (kiri beliau), papan
  putih + bingkai emas. Isinya KETERANGAN materi yang sedang dibahas
  dan MENGIKUTI pesan yang sedang diucapkan:
  - pesan kalam (pesan 2) → papan: "KALAM — kalam = susunan kalimat /
    kata = isim • fi'il • huruf";
  - penjelasan ulang (cabang Belum) → papan: "CONTOH — Qaama
    Muhammadun / Muhammad telah berdiri. / Itu kalam.";
  - latihan/kuis → papan: soal yang sedang dijawab / poin kunci
    (mis. "tanwin → isim").
- **Isi papan v1 = transliterasi/Latin saja.** Teks Arab di panel
  sedang diselidiki Tara (temuan Mas 19 Nov 15:00: teks Arab + sebagian
  ikon di panel tidak terbaca jadi karakter aneh; klarifikasi 15:02:
  biasanya yang di PANEL) — tulisan Arab di papan mengikuti hasil
  penyelidikan itu, jangan dipaksakan dulu.

### Catatan teknis (tambahan dari §4 + §7)

- **Pose duduk:** dipakai ulang dari yang sudah ada
  (`_terapkan_duduk_baca` / PAKAIAN_DUDUK di `player.gd`/`npc.gd` —
  pose yang sama dipakai NPC saat baca kitab). TIDAK ada pose baru.
  Kamera saat dialog dibuka membingkai ustadz yang sedang duduk
  (handoff kamera seperti §7); setelah dialog ditutup, kamera kembali
  ke player dan ustadz kembali ke aktivitasnya.
- **Papan tulis:** prop kecil di dunia di samping ustadz (papan putih +
  bingkai emas di atas kaki easel) + teks keterangan yang isinya
  diperbarui tiap node percakapan (dari `DataChatModul01` — tiap node
  membawa `papan: {judul, baris[]}` opsional; bila node tidak membawa
  papan, papan menampilkan poin node terakhir). Papan hanya ada selama
  dialog belajar terbuka.
- **Tes** (`test_ruang_belajar_chat.gd`, tambahan dari §4/§7): ustadz
  duduk saat dialog (pose duduk aktif), papan tulis tampil dengan isi
  mengikuti pesan, TIDAK ADA teks "mengetik" di mana pun, TIDAK ADA
  teks penghitung "Pesan X dari 14" di mana pun (bilah emas tipis
  tetap), tombol jawaban tidak pernah dalam keadaan redup/terkunci,
  pilihan muncul setelah kalimat selesai.

### Catatan mockup (jujur)

- Potret di mockup dipotong dari foto yang ada (Sanusi: foto
  songkok-v2; Fatimah: `fatimah_depan.png`), latar datar dihapus flood
  fill, diposisikan duduk di atas tikar yang digambar. Di game,
  portraitnya adalah karakter 3D ustadz yang sedang duduk — jadi pose
  duduk yang sebenarnya akan terlihat lebih natural daripada mockup.
- Latar = render gerbang (Sanusi) / Musholla (Fatimah) sebagai stand-in
  dunia; di game latarnya dunia LIVE tempat ustadz duduk. Nit kecil:
  papan tulis di mockup menutupi sebagian plakat "GERBANG" /
  "PESANTREN UNIVERSE" di latar stand-in — di game, posisi papan
  diatur terhadap dunia live, bukan terhadap plakat.
- Tombol "Riwayat" kini DIGAMBAR di mockup (pojok kanan atas kotak,
  di samping "× Tutup") — pertanyaan §5 no. 6 tetap menunggu jawaban
  Mas.

### Rekomendasi Sinta (revisi §8)

Bangun v1 Modul 01 dengan tampilan ini (Genshin + duduk + papan tulis
+ bicara) — ini yang paling dekat dengan "mengajar betulan" yang Mas
maksud: ustadz duduk mengajar seperti di kelas, papan tulisnya
menunjukkan keterangan, dan beliau bicara, bukan mengetik. Biayanya
tetap sama dengan v1 (yang baru hanya pose duduk yang sudah ada +
prop papan tulis + penamaan ulang efek ketik → efek bicara; data,
alur, dan poin tidak berubah).
