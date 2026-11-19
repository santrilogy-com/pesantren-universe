# KONSEP — Integrasi Claude (Santrilogy AI) ke Ruang Belajar versi Chat v1

**Pertanyaan Mas (19 Nov 2026, 14:46 WIB, menanggapi konsep chat Ruang Belajar):**
"Apa bisa terintegrasi dg Muse AI?" — maksudnya dialog belajar dengan ustadz
di game dijawab oleh AI, bukan hanya naskah yang sudah ditulis.

**Jawaban singkat: Bisa.** Pakai ulang backend Santrilogy AI yang sudah ada
di VPS (Claude lewat OpenRouter + pustaka kitab + MCP Shamela), dengan satu
endpoint baru. Materi inti tetap naskah yang sudah ditashih; AI hanya
menjelaskan ulang dan menjawab pertanyaan — dengan pengaman supaya AI tidak
mengarang kaidah.

**KOREKSI PENTING (Mas, 19 Nov 14:47): backend Santrilogy AI di VPS pakai
Claude lewat OpenRouter, BUKAN Muse.** Dokumen ini memakai Claude di semua
bagian (model, endpoint, biaya). Jangan lagi menyebut model Santrilogy AI
sebagai Muse.

**Status:** KONSEP — menunggu ACC Mas. Kode server/game TIDAK diubah.

---

## 1. Prinsip (tidak bisa ditawar)

1. **Naskah tashih tetap inti.** 14 pesan scripted Ruang Belajar versi chat
   (`KONSEP-RUANG-BELAJAR-CHAT-v1.md`) TIDAK berubah: materi, latihan, kuis,
   dan 35 poin tetap dari naskah yang ditashih Mas + Tim Kurikulum.
2. **AI hanya penjelas, bukan pengajar utama.** AI dipakai di dua tempat
   saja: (a) penjelasan ulang saat player jawab "Belum paham" dan jatah
   penjelasan scripted sudah habis; (b) pertanyaan player lewat tombol
   "Tanya Ustadz". AI tidak pernah memberi poin dan tidak pernah mengganti
   soal/kuis.
3. **Grounding pada teks yang sudah ditashih.** Jawaban AI harus berpegang
   pada kartu Modul 01 (ringkasan teks Modul 01 yang sudah lolos tashih
   18 Nov) + data soal game. AI menjelaskan ulang — BUKAN mengarang kaidah,
   contoh Arab, atau kutipan kitab baru.
4. **Jujur bila tidak tahu.** Di luar modul, AI menjawab terus terang
   "itu belum kita pelajari" — tidak mengarang, tidak menjawab soal tes
   kenaikan, tidak berfatwa.
5. **Tidak ada poin dari AI.** Ngobrol dengan AI = 0 poin. Poin hanya dari
   materi/latihan/kuis scripted (anti-farming).

---

## 2. Alur: kapan naskah, kapan AI

| Situasi di chat | Yang menjawab | Keterangan |
|---|---|---|
| Materi 7 pesan (salam → kalam → isim → fi'il → huruf → rumus → bait) | Naskah scripted | Mengalir otomatis, berhenti hanya di "Paham?" |
| "Belum, jelaskan lagi" ke-1 dan ke-2 | Naskah scripted | Contoh Qaama Muhammadun, lalu ringkasan (sudah di konsep chat) |
| "Belum" ke-3 (player masih belum paham setelah 2×) | **AI (Claude)** | Penjelasan ketiga, gaya baru, contoh baru dari kartu modul. Bila AI juga tidak membantu, ustadz mengajak lanjut ("nanti ketemu lagi di latihan") |
| Latihan L1–L5, kuis K1 | Naskah scripted | Soal + petunjuk dari `DataModul01`; salah → penjelasan scripted + ulang soal |
| Tombol **"Tanya Ustadz"** (baru, di bawah chat) | **AI (Claude)** | Muncul setelah materi selesai (atau kapan saja di luar soal). Player pilih pertanyaan siap — lihat §3 |
| Pertanyaan di luar Modul 01 | **AI, dengan penolakan jujur** | "Itu belum kita pelajari di Modul 01, Nak…" + arahkan ke ustadz asli / modul berikut |
| AI mati / offline / kuota habis | Naskah scripted (fallback) | Lihat §9 — alur belajar tidak pernah macet |

### Titik masuk "Tanya Ustadz" (v1)

Setelah materi selesai (atau kapan saja di luar soal), di bawah tombol
jawaban muncul tombol kecil **"Tanya Ustadz"**. Ditekan → muncul 3–4
pertanyaan siap (tombol pilihan, BUKAN kolom ketik bebas di v1):

- "Beri contoh kalam yang lain."
- "Apa bedanya isim dan fi'il?"
- "Jelaskan lagi dengan bahasa yang lebih mudah."
- "Kenapa huruf tidak bisa berdiri sendiri?"

Player tap satu pertanyaan → gelembung pertanyaan (emas, kanan) → ustadz
mengetik → jawaban AI (gelembung kiri). Setelah jawaban AI, tombol kembali
ke alur scripted (lanjut latihan / tutup). **Kolom ketik bebas = v2** (butuh
keputusan Mas, lihat §12 — ada risiko penyalahgunaan).

### Kenapa v1 tanpa kolom ketik bebas

- Santri bisa mengetik apa saja (iseng, kasar, di luar pelajaran, minta
  jawaban tes kenaikan). Moderasi kolom bebas butuh filter + review log
  yang belum ada.
- Tombol pertanyaan siap sudah menutup 90% kebutuhan nyata ("contoh lain",
  "jelaskan lagi", "apa bedanya X dan Y") dengan risiko nol.
- Bila Mas mau kolom bebas, v2 menambah filter panjang + daftar tolak +
  review log (lihat §12 pertanyaan 2).

---

## 3. Arsitektur (pakai ulang, jangan bangun AI kedua)

```
Game (Godot web, Cloudflare Pages)
  │ HTTPRequest, token sesi santri (sudah ada dari login)
  ▼
Caddy (VPS 43.173.39.166, https://43-173-39-166.sslip.io)
  │ /api/* → 127.0.0.1:8790 (sudah ada)
  ▼
pesantren-verse-api (Python, :8790) — BARU: POST /api/ajar
  │ 1. cek token sesi santri (fungsi _cek_sesi yang sudah ada)
  │ 2. cek kuota AI harian santri (hitung dari tabel ajar_log)
  │ 3. teruskan ke Santrilogy AI (localhost, service key)
  ▼
Santrilogy AI (Node.js, :8800) — BARU: POST /ai/api/ajar-internal
  │ 1. cek service key (bukan akun guru, bukan cookie)
  │ 2. susun system prompt + kartu Modul 01 (skill baru ajar-nahwu.md)
  │ 3. panggil openRouterStream() yang SUDAH ADA (tools MATI)
  ▼
OpenRouter → Claude Haiku 5.5 (anthropic/claude-haiku-5.5)
```

**Kenapa bentuk ini (tiga lapis, bukan game langsung ke Santrilogy AI):**

- **Game tidak pernah memegang kunci apa pun** selain token sesi santri
  (1 jam, satu sesi) yang memang sudah dipegangnya untuk login/poin.
  Kunci OpenRouter tetap di `.env` VPS Santrilogy AI; service key hanya
  di `.env` kedua layanan di VPS — tidak pernah keluar ke klien/repo.
- **Pesantren API adalah batas kepercayaan:** ia yang tahu identitas
  santri (PV-XXXX) + kuota. Santrilogy AI tidak kenal santri — ia hanya
  kenal akun guru (cookie). Jadi validasi santri + kuota harus di
  pesantren API, bukan di Santrilogy AI.
- **Tidak ada AI kedua:** OpenRouter, streaming, dan pemanggilan model
  sudah ada di `server.js` (`openRouterStream`, timeout 180 dtk). Jalur
  ajar hanya menambah satu skill (system prompt) + satu endpoint
  internal yang memanggil fungsi yang sama dengan `useTools=false`.
- **Tidak ada perubahan Caddy:** `/api/*` sudah ke :8790, `/ai/*` sudah
  ke :8800. Panggilan pesantren API → Santrilogy AI lewat localhost
  (127.0.0.1:8800), tidak lewat Caddy.

**Yang berubah di tiap layanan (ringkas — detail build nanti):**

- `pesantren-verse-api/server.py`: endpoint `POST /api/ajar` + tabel
  `ajar_log` (santri_id, modul, pertanyaan, jawaban, model, token_in,
  token_out, created_at; index santri_id+created_at) + env
  `AJAR_SERVICE_KEY` + `AJAR_SERVICE_URL` (default
  `http://127.0.0.1:8800`).
- `santrilogy-ai/server.js`: endpoint `POST /ai/api/ajar-internal`
  (cek header `X-Ajar-Service-Key`) + skill baru
  `server/skills/ajar-nahwu.md` (system prompt §5 + kartu modul) +
  panggil `openRouterStream(..., model quality, useTools=false)`,
  kumpulkan jawaban lengkap, balas JSON (bukan SSE — lihat §8).
- `santrilogy-ai/.env` (VPS saja, JANGAN disalin): `AJAR_SERVICE_KEY`
  (acak 32 byte hex, dibuat saat build). Model yang dipakai =
  `OPENROUTER_MODEL_QUALITY` yang sudah ada (nilai default di kode:
  `anthropic/claude-haiku-5.5`).

---

## 4. Endpoint (draf kontrak)

### Publik — POST /api/ajar (pesantren-verse-api :8790)

Header: `Authorization: Bearer <token sesi santri>` — token dari
`POST /api/santri/login` (1 jam, satu sesi per santri), pola yang sama
dengan `POST /api/santri/points`. Rate limit 120/menit/IP yang sudah ada
tetap berlaku.

Body (JSON):

```json
{
  "modul": "nahwu-01",
  "pengajar": "sanusi",
  "pertanyaan": "Beri contoh kalam yang lain.",
  "posisi": "tanya-bebas",
  "riwayat": [
    {"peran": "ustadz", "teks": "kalam itu artinya adalah susunan kalimat..."},
    {"peran": "santri", "teks": "Belum, jelaskan lagi."}
  ]
}
```

- `modul`: id modul (`nahwu-01` dulu; modul lain menyusul setelah
  tashih + kartu modulnya dibuat). Modul tak dikenal → 400.
- `pengajar`: `"sanusi"` (putra) / `"fatimah"` (putri) — hanya mengubah
  persona di system prompt; materi dan alur SAMA.
- `pertanyaan`: maks 300 karakter (v1: pertanyaan dari tombol siap,
  jadi selalu pendek; batas ini untuk v2 kolom bebas).
- `riwayat`: maks 6 gelembung terakhir (teks saja, tanpa poin/status) —
  supaya Claude ingat konteks percakapan. Lebih dari 6 dipotong dari
  depan oleh game.
- `posisi`: `"materi"` | `"latihan"` | `"tanya-bebas"` — konteks kapan
  pertanyaan diajukan (membantu system prompt memilih gaya).

Respons 200:

```json
{
  "ok": true,
  "jawaban": "Baik, contoh lain: 'Zaidun qaaimun' — Zaid sedang berdiri...",
  "sumber": "ai",
  "model": "anthropic/claude-haiku-5.5",
  "sisa_hari_ini": 17
}
```

Respons gagal (game WAJIB menangani semuanya dengan fallback §9):

| Kode | Arti | Yang dilakukan game |
|---|---|---|
| 400 | pertanyaan kosong / >300 karakter / modul tak dikenal | Tampilkan pesan scripted "Coba tanyakan dengan cara lain." (bukan error teknis) |
| 401 | token sesi tidak valid / kedaluwarsa | Minta login ulang (pola login yang sudah ada) |
| 429 | kuota AI hari ini habis | Gelembung ustadz: "Jatah tanya hari ini sudah habis, Nak. Besok tanya lagi, ya." + lanjut alur scripted |
| 502 | Santrilogy AI / OpenRouter tidak merespons | Fallback naskah (lihat §9) |
| 500 | galat server lain | Fallback naskah |

### Internal — POST /ai/api/ajar-internal (Santrilogy AI :8800)

Hanya dari localhost + header `X-Ajar-Service-Key`. Body:
`{modul, pengajar, pertanyaan, riwayat, kartu_modul}`. Respons:
`{jawaban, model, token_in, token_out}`. Tidak ada auth santri di sini —
kepercayaan dipegang pesantren API. Endpoint ini TIDAK dibuka ke publik
(Caddy tidak memetakannya; hanya localhost).

---

## 5. System prompt (draf — untuk skill `ajar-nahwu.md`)

System prompt disusun server dari tiga lapis: (a) persona dasar
Santrilogy AI yang sudah ada (bahasa Indonesia langsung, **jangan pernah
pakai em dash —**, jangan mengarang kutipan, yang belum yakin beri
peringatan "perlu dicek ustadz"); (b) persona pengajar; (c) kartu modul
(grounding). Draf persona pengajar:

> Kamu Ust. Sanusi, ustadz Nahwu di Pesantren Universe, sedang mengajar
> santri baru secara pribadi lewat chat. (Putri: Kamu Ustzh. Fatimah,
> ustadzah Nahwu. Materi dan aturan sama.)
>
> Gaya: sabar, sederhana, Bahasa Indonesia sehari-hari seperti contoh
> Mas: "kalam itu artinya adalah susunan kalimat. Kalimat disini
> maksudnya adalah kata dalam bahasa indonesia." Panggil santri "Nak".
> Jawaban SINGKAT: maks 100 kata, 2–4 kalimat. Satu contoh cukup.
> Jangan ceramah panjang, jangan pakai daftar bernomor kecuali diminta.
>
> ATURAN KERAS (tidak boleh dilanggar):
> 1. Jawab HANYA dari MATERI MODUL di bawah. Jangan menambah kaidah,
>    definisi, atau contoh dari luar materi itu.
> 2. Jangan mengarang teks Arab, kutipan kitab, hadis, atau ayat. Contoh
>    Arab hanya yang ada di materi di bawah, dengan transliterasi yang
>    sama seperti di materi.
> 3. Bila pertanyaan di luar Modul 01 (misal Mantiq, Fiqih, modul
>    berikutnya, atau soal tes kenaikan), jawab: "Itu belum kita pelajari
>    di Modul 01, Nak. Nanti di modul berikutnya, insya Allah. Sekarang
>    kita fokus yang ini dulu, ya." Jangan menjawab isi pertanyaan itu.
> 4. Bila kamu tidak yakin jawabannya ada di materi, katakan: "Yang itu
>    Ustadz belum bisa pastikan dari materi kita. Tanyakan langsung ke
>    ustadz di pesantren, ya." Jangan menebak.
> 5. Jangan pernah meminta data pribadi (nama asli, IG, nomor HP,
>    password). Jangan membahas topik di luar pelajaran (politik, gosip,
>    game lain). Arahkan kembali ke pelajaran dengan sopan.
> 6. Jangan memberi poin, nilai, atau janji hadiah. Itu urusan sistem
>    game, bukan kamu.
>
> MATERI MODUL (teks yang sudah ditashih — kartu Modul 01):
> [kartu modul dimasukkan server di sini — lihat §6]

### Kartu modul (grounding — isi, bukan salinan dokumen penuh)

Kartu Modul 01 (~1.500–2.000 token) disusun Tim Kurikulum dari dokumen
Modul 01 yang sudah lolos tashih
(`ruang-belajar-nahwu-dasar-01-mengenal-kata.md`, 441 baris) + soal dan
petunjuk `data_modul_01.gd`. Isinya: definisi kalam (contoh PERSIS Mas),
tiga jenis kata + ciri + contoh (madrasatun, yaqra'u, 'alaa, qalamun,
jalasa), rumus cepat, bait hafalan. **Bukan dokumen penuh** — kartu yang
ringkas supaya murah + cepat (lihat §7), dan supaya Claude tidak
"membaca" bagian yang belum diajarkan.

- Satu kartu per modul. Modul 02 menyusul setelah tashih Modul 02
  selesai — pola yang sama, kartu baru.
- Kartu disimpan di Santrilogy AI (file skill) dan dimuat saat server
  start; diubah hanya bila ada revisi tashih.
- v2 (nanti): untuk modul yang materinya mengutip kitab (misal
  Jurumiyah — sudah ada di pustaka kitab, `dicek_ustadz:true`), kartu
  boleh menyertakan kutipan bab yang relevan. v1 TIDAK memakai tool
  kitab/Shamela di jalur ajar — grounding dari kartu saja (lebih cepat,
  jawaban lebih ketat di modul).

---

## 6. Pengaman tashih (yang paling penting)

| Risiko | Pengaman di konsep ini |
|---|---|
| AI mengarang kaidah / contoh Arab | System prompt aturan 1–2 + grounding kartu modul; jawaban di luar kartu = pelanggaran prompt yang terukur di log |
| AI mengajar modul yang belum ditashih | Endpoint hanya kenal modul yang kartunya sudah dibuat dari dokumen TASHIH LOLOS. Modul tanpa kartu → 400 |
| AI menjawab soal tes kenaikan (curang) | Aturan 3: pertanyaan tentang tes → penolakan jujur + arahkan ke pelajaran |
| Santri tidak bisa bedakan jawaban tashih vs AI | **Label kecil pada gelembung AI** (usulan, butuh ACC Mas — lihat §12): chip mungil "AI" di sudut gelembung jawaban AI; gelembung naskah tanpa label |
| Jawaban AI yang salah lolos tanpa ketahuan | **Log penuh** (`ajar_log`): tiap giliran AI tersimpan (santri, modul, pertanyaan, jawaban, model, token). Tim Kurikulum me-review sampel berkala; pertanyaan yang sering muncul + jawaban yang diragukan → ditulis jadi jawaban scripted di update berikut |
| AI berubah sikap / menjawab kasar | System prompt persona + aturan 5; log membuat semua jawaban bisa diaudit |
| Naskah tashih "tercemar" AI | TIDAK PERNAH: kartu modul ditulis manusia dari dokumen tashih; AI tidak pernah menulis ke kartu modul, ke `data_modul_01.gd`, atau ke dokumen kurikulum |

**Catatan jujur:** pengaman ini mengurangi risiko, bukan menghilangkannya.
Claude bisa tetap salah dalam batas kecil (misal contoh yang kurang
pas). Karena itu log + review berkala + label AI adalah bagian wajib
konsep ini, bukan hiasan. Bila review menemukan jawaban AI yang salah
berulang, kartu modul diperbaiki atau pertanyaan itu dipindah ke jawaban
scripted.

---

## 7. Biaya (Claude Haiku 5.5 via OpenRouter — tarif terverifikasi)

Model: **`anthropic/claude-haiku-5.5`** — model "quality" yang sudah
dikonfigurasi di Santrilogy AI (`OPENROUTER_MODEL_QUALITY`, default di
`server.js`). Ini Claude termurah di keluarga Claude (sekitar sepersepuluh
harga Claude Haiku 4.5). Tarif publik OpenRouter, dicek 19 Nov 2026
([halaman model](https://openrouter.ai/anthropic/claude-haiku-5.5)):

| Komponen | Tarif |
|---|---|
| Input (prompt ≤100 ribu token) | **US$0,10 / 1 juta token** |
| Output | **US$0,50 / 1 juta token** |
| Cache read (prompt yang sama dipakai ulang) | US$0,01 / 1 juta token |
| Cache write | US$0,125 / 1 juta token |
| Fee top-up kredit OpenRouter | +5,5% (sudah dihitung di bawah) |
| Di atas 100 ribu token/prompt | US$0,50 / US$2,50 — TIDAK berlaku di sini (prompt kita ±3 ribu token) |

### Perkiraan per pesan AI (satu giliran tanya-jawab)

Asumsi isi satu panggilan: system prompt + kartu modul ±2.000 token
(biasanya cache hit — sama untuk semua santri di modul yang sama),
riwayat + pertanyaan ±850 token, jawaban ±200 token (maks 100 kata,
dibatasi `max_tokens` 400).

| Skenario | Hitungan | Biaya |
|---|---|---|
| Cache dingin (giliran pertama) | input 2.850 × $0,10 + output 200 × $0,50 | ±US$0,00041 ≈ **Rp6,5** |
| Cache hangat (giliran biasa) | input cache 2.000 × $0,01 + input baru 850 × $0,10 + output 200 × $0,50 | ±US$0,00021 ≈ **Rp3,5** |
| **Anggaran per pesan (dibulatkan, sudah termasuk fee 5,5%)** | | **±Rp5** |

Kurs asumsi Rp16.000/US$. **Tarif bisa berubah** — cek ulang halaman
OpenRouter saat build; bila tarif naik 2× pun anggaran di bawah tetap
masuk akal karena nominalnya kecil.

### Perkiraan per bulan

| Skenario | Pesan AI/bulan | Biaya/bulan |
|---|---|---|
| Awal (20 santri aktif × 5 pesan/hari) | 3.000 | ±Rp15 ribu |
| Ramai (100 santri × 10 pesan/hari) | 30.000 | ±Rp150 ribu |
| Penuh (200 santri × 20 pesan/hari = batas kuota) | 120.000 | ±Rp600 ribu |

Catatan: 9 santri terdaftar hari ini (19 Nov), jadi skenario awal pun
masih jauh — biaya bulan pertama hampir pasti di bawah Rp15 ribu. Kuota
harian (§8) adalah rem darurat: bila pemakaian meledak, biaya berhenti
di batas kuota, bukan di tagihan.

### Kenapa bukan model lain

- **Claude Sonnet (keluarga Claude yang lebih besar):** sekitar
  US$3 masuk / US$15 keluar per juta token — ±30× lipat Haiku.
  Tidak perlu untuk jawaban 100 kata dari kartu modul. JANGAN dipakai
  di jalur ajar.
- **Model default Santrilogy AI (DeepSeek V4 Flash, ±US$0,05/US$0,45):**
  lebih murah ±setengah, TETAPI koreksi Mas 19 Nov 14:47 menegaskan
  backend Santrilogy AI pakai Claude — konsep ini mengikuti keputusan
  itu. Selisih biaya ke DeepSeek hanya ±Rp2 per pesan; bukan alasan
  untuk melawan keputusan Mas.

---

## 8. Rate limit & anti-penyalahgunaan

| Aturan | Nilai (usulan) | Alasan |
|---|---|---|
| Per santri | **20 pesan AI/hari** (WIB, hitung balasan sukses saja — pola Santrilogy AI: giliran gagal/kosong TIDAK memotong kuota) | Cukup untuk belajar sungguhan; menutup spam + tagihan liar |
| Burst per santri | 5 pesan/menit | Mencegah ketuk beruntun |
| Panjang pertanyaan | maks 300 karakter | v1: pertanyaan dari tombol (pendek); v2: membatasi kolom bebas |
| Kuota global (rem darurat) | 2.000 pesan AI/hari untuk semua santri | Bila jebol, semua santri dapat pesan jujur "AI sedang istirahat, coba besok" + alur scripted tetap jalan |
| Rate limit IP | 120/menit/IP (sudah ada di pesantren API) | Tetap berlaku untuk semua endpoint |
| Poin dari AI | 0 (nol) | AI tidak bisa dipakai farming poin |
| Penyimpanan | `ajar_log` (90 hari, lalu prune) | Audit + bahan review tashih; bukan untuk pamer data santri |

Sisa kuota dikembalikan di tiap respons (`sisa_hari_ini`) supaya game
bisa menampilkan "Sisa tanya hari ini: 17" bila perlu — tanpa perlu
endpoint tambahan.

---

## 9. Latensi & efek ketik

- **Claude Haiku 5.5 cepat:** token pertama biasanya <1 detik,
  kecepatan ±80–150 token/detik. Jawaban ±200 token selesai dalam
  ±2–3 detik, ditambah jaringan VPS→OpenRouter. Total yang dirasakan
  player: **±2–5 detik** dari tap sampai jawaban mulai tampil.
- **Menutupi jeda:** selama menunggu HTTP, chat menampilkan gelembung
  tiga titik + "Ust. Sanusi sedang mengetik…" (pola konsep chat yang
  sudah ada). Player tidak melihat spinner mentah.
- **v1 = JSON biasa (bukan streaming):** jawaban lengkap tiba sekaligus,
  lalu efek ketik dimainkan lokal oleh game. Alasan: `HTTPRequest`
  Godot di export web paling gampang menangani satu respons JSON;
  streaming SSE dari game butuh penanganan khusus (v2 bila perlu).
- **Kecepatan ketik jawaban AI:** naskah scripted mengetik ±40 ms/huruf
  (konsep chat). Jawaban AI lebih panjang (±100 kata ≈ ±600 karakter) —
  di 40 ms/huruf itu 24 detik, terlalu lambat. **Untuk jawaban AI pakai
  ±12–15 ms/huruf** (≈7–9 detik untuk 600 karakter), tap gelembung =
  tampil penuh seperti biasa. Ini detail build, dicatat di sini supaya
  tidak lupa.

---

## 10. Fallback (bila AI tidak bisa menjawab)

Prinsip: **alur belajar tidak pernah macet karena AI.** Semua fallback
berupa gelembung ustadz yang jujur, lalu alur scripted lanjut seperti
biasa:

| Keadaan | Yang tampil di chat |
|---|---|
| Game offline / HTTP timeout (30 detik, tanpa retry beruntun — maks 1× ulang untuk galat 5xx) | "Maaf Nak, Ustadz sedang tidak bisa menjawab sekarang. Coba lagi nanti, ya." + tombol scripted kembali |
| Kuota santri habis (429) | "Jatah tanya hari ini sudah habis, Nak. Besok tanya lagi, ya." |
| Kuota global habis | "AI sedang istirahat hari ini, Nak. Pelajarannya tetap bisa dilanjutkan." |
| OpenRouter galat / jawaban kosong / jawaban rusak | Sama seperti offline — JANGAN tampilkan teks galat teknis ke santri |
| Model menjawab di luar aturan (terdeteksi di log belakangan) | Tidak ada yang tampil aneh saat itu; perbaikan lewat kartu modul / jawaban scripted di update berikut |

**Yang TIDAK berubah saat fallback:** 14 pesan scripted, latihan, kuis,
35 poin, dan maju langkah 5→6 tetap jalan penuh tanpa AI. Santri yang
tidak pernah menyentuh tombol "Tanya Ustadz" tidak akan pernah merasakan
ada AI di belakang game.

---

## 11. Yang dibutuhkan sisi game (ringkas — bukan tugas dokumen ini)

- `HTTPRequest` (atau klien kecil `ajar_client.gd`) di RuangBelajarUI:
  POST `https://43-173-39-166.sslip.io/api/ajar`, header
  `Authorization: Bearer <token sesi>` (token yang sama dengan login —
  game sudah memegangnya), timeout 30 detik.
- Tombol "Tanya Ustadz" + 3–4 tombol pertanyaan siap (v1); gelembung
  jawaban AI + chip mungil "AI" (bila ACC §12 no. 4); efek ketik
  ±12–15 ms/huruf untuk jawaban AI.
- Kirim `riwayat` (maks 6 gelembung terakhir, teks saja) + `modul` +
  `pengajar` (sanusi/fatimah dari gender player) + `posisi`.
- Tangani 401 (login ulang), 429 (pesan jujur kuota habis), 502/500
  (fallback naskah) — tanpa menampilkan teks galat teknis.
- TIDAK ada kunci save baru (riwayat AI tidak perlu disimpan di save;
  log ada di server). Poin tidak berubah.

---

## 12. Pertanyaan untuk Mas (jawab saat ACC)

1. **Model: Claude Haiku 5.5** (sudah dipakai Santrilogy AI, Claude
   termurah) — ACC? (Usulan: ya.)
2. **Pertanyaan bebas (kolom ketik) atau hanya tombol pertanyaan siap?**
   (Usulan v1: tombol siap saja; kolom bebas = v2 dengan filter.)
3. **Kuota 20 pesan AI/santri/hari** — setuju? (Terlalu kecil / besar?)
4. **Label kecil "AI" pada gelembung jawaban AI** — setuju? (Usulan: ya,
   supaya santri tahu mana jawaban tashih, mana jawaban AI.)
5. **Log jawaban AI boleh dibaca Tim Kurikulum** untuk review tashih
   berkala? (Usulan: ya — sampel saja, bukan mengintip semua chat.)
6. **Anggaran:** ±Rp150 ribu/bulan bila 100 santri aktif (skenario ramai)
   — setuju? (Bulan pertama hampir pasti <Rp15 ribu; rem darurat
   2.000 pesan/hari menahan tagihan.)

---

## 13. Rekomendasi Saka

**Bangun v1 untuk Modul 01 saja, dengan pola di atas.** Ini menjawab
pertanyaan Mas ("bisa terintegrasi?") dengan cara yang paling aman:
naskah tashih tetap yang mengajar; Claude hanya menjelaskan ulang dan
menjawab pertanyaan dari kartu modul — dengan log yang bisa diaudit Tim
Kurikulum. Biayanya kecil (Rp5/pesan, bulan pertama <Rp15 ribu), latensi
±2–5 detik tertutup efek ketik, dan bila AI mati pun belajar tetap jalan
penuh.

Urutan build (setelah ACC Mas + setelah konsep chat Ruang Belajar ACC
dan dibangun — AI menempel di atas chat itu, bukan mendahuluinya):

1. Kartu Modul 01 (Tim Kurikulum, dari dokumen tashih) + skill
   `ajar-nahwu.md`.
2. Endpoint internal Santrilogy AI + endpoint publik pesantren API +
   `ajar_log` + service key.
3. Tombol "Tanya Ustadz" + pertanyaan siap + efek ketik AI di game
   (Sinta) + tes `test_ruang_belajar_ai.gd`.
4. Uji beban kecil + review 20 jawaban AI pertama oleh Tim Kurikulum
   sebelum dibuka ke semua santri.

Kolom ketik bebas, streaming SSE, dan kartu Modul 02+ = v2, setelah v1
terbukti di tangan santri.

---

## 14. Referensi (yang dibaca untuk konsep ini)

- `v2/konsep/KONSEP-RUANG-BELAJAR-CHAT-v1.md` — 14 pesan scripted,
  efek ketik, tombol pilihan, 35 poin.
- `~/workspace/santrilogy-ai/server.js` — `openRouterStream()`
  (streaming + tools, temp 0.7, timeout 180 dtk),
  `MODEL_QUALITY_ENV = 'anthropic/claude-haiku-5.5'`,
  `MODEL_DEFAULT_ENV = 'deepseek/deepseek-v4-flash'`,
  limit chat 50/hari (hitung balasan sukses), KITAB_API :8790,
  SHAMELA_URL :8770, BASE_PATH `/ai`.
- `~/workspace/santrilogy-ai/server/skills/persona.md` — persona dasar
  (tanpa em dash, jangan mengarang kutipan, yang belum yakin → "perlu
  dicek ustadz").
- `~/workspace/pesantren-verse/server/server.py` — token sesi 1 jam
  (`_buat_sesi`/`_cek_sesi`, `SESI_TTL_DETIK = 3600`), rate limit
  120/menit/IP, pola `POST /api/santri/points`.
- `~/workspace/goals/pesantren-verse/files/ruang-belajar-nahwu-dasar-01-mengenal-kata.md`
  — sumber kartu Modul 01 (tashih lolos 18 Nov).
- Tarif Claude Haiku 5.5 via OpenRouter, dicek 19 Nov 2026:
  https://openrouter.ai/anthropic/claude-haiku-5.5
  ($0,10 masuk / $0,50 keluar per 1 juta token; cache read $0,01;
  di atas 100 ribu token/prompt $0,50/$2,50 — tidak berlaku di sini).
