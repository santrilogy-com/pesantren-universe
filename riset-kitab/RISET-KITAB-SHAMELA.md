# Riset Rak Kitab Interaktif — Sumber Kitab Open-Source (Shamela / MCP / OpenITI)

**Tanggal:** 16 Nov 2026 · **Peneliti:** Zahra · **Status:** riset saja (bukan bangun)
**Permintaan Mas (16 Nov ~18:37 WIB):** di Surau ada rak dan kitab-kitab; santri klik tombol "Baca" → daftar buku/kitab → baca isinya di dalam game. Koleksi diambil dari sumber open-source, mis. **MCP Shamela** — beberapa kitab saja, kitab-kitab pesantren / buku keislaman.

---

## 1. Ringkasan eksekutif

- **MCP Shamela ADA dan sudah saya uji langsung (live).** Yang paling layak: **Quran Gallery MCP** (`https://qurangallery.com/mcp/shamela`) — hosted, gratis tanpa akun, 8.594 kitab, 15 tool. Saya berhasil `initialize` + `shamela_find` dan menemukan متن الآجرومية (48 hasil, termasuk kitabnya Ibn Ajrum id 11371 dan الدرة البهية/Imrithi id 2084).
- **TAPI: MCP bukan untuk dipakai game saat runtime.** MCP dipakai di sisi riset/kurasi (Xam + Laras mencari dan memverifikasi kutipan). Alasannya di §5: Godot tidak bisa bicara MCP, limit 200 panggilan/hari/IP (tanpa kunci), potongan teks maks ±1.600 karakter, dan syarat layanan Shamela Link melarang mirror seluruh pustaka.
- **Sumber teks untuk dibundel: OpenITI — TERBUKTI.** Saya unduh metadata resmi (14.107 baris) dan ambil 2 file asli dari GitHub: Jurumiyah (21.326 byte) dan Safinatun Naja (46.872 byte) — isinya teks Arab asli yang bisa dibaca, lengkap dengan metadata Shamela. Lisensi **CC BY-NC-SA 4.0** (atribusi + non-komersial + share-alike) — cocok selama game non-komersial.
- **Hadis + terjemahan Indonesia: fawazahmed0/hadith-api (Unlicense).** 10 koleksi, edisi Arab + Indonesia (`ind-*`) untuk 7 koleksi, via CDN jsDelivr, tanpa kunci dan tanpa limit. Arba'in Nawawi ada (Arab + Inggris; **tidak ada edisi Indonesia** di v1). Riyadhus Shalihin **tidak ada** di API ini — ambil Arabnya dari OpenITI.
- **Shortlist: 9 dari 12 kitab target ADA di OpenITI** (lihat tabel §4). **TIDAK ADA di OpenITI maupun Shamela (terverifikasi): Aqidatul Awam, Ta'lim al-Muta'allim, Amtsilah Tashrifiyyah** — ketiganya butuh sumber lain (lihat §4.3).
- **Terjemahan Indonesia kitab kuning: JANGAN dibundel dari internet.** Hampir semua terjemahan modern berhak cipta; yang beredar di archive.org adalah scan buku cetak (status hukum abu-abu). Solusi: tampilkan **Arab + ringkasan Indonesia orisinal** dari tim materi (Laras, dari ebook Nahwu) — ini juga yang membuat rak kitab jadi materi kurikulum, bukan sekadar salinan.
- **Arsitektur yang disarankan: VPS sebagai pustaka** (§5) — server Pesantren Universe menyajikan JSON per kitab/bab, game fetch saat santri buka rak kitab. Kitab pertama yang disarankan: **Jurumiyah** (8 KB, sudah jadi materi Nahwu Dasar + misi M1–M3).

---

## 2. MCP Shamela — yang ada, yang teruji

### 2.1 Quran Gallery MCP — PALING LAYAK ✅ (diuji live 16 Nov 2026)

| | |
|---|---|
| Endpoint | `https://qurangallery.com/mcp/shamela` (Streamable HTTP, POST) |
| Operator | Quran Gallery (qurangallery.com) — **bukan** shamela.ws; servernya salinan Shamela |
| Korpus | **8.594 kitab**, 3.188 pengarang, 41 kategori, dari Maktabah al-Shamela |
| Tool | **15 tool read-only** (+ 3 prompt, 1 resource). Yang utama: `shamela_search_library` (cari per 12 scope: hadith-primary, tafsir-canonical, fiqh-hanafi, aqeedah, lugha, …), `shamela_find` (cari kitab/pengarang/bab), `shamela_read` (baca halaman/bab), `shamela_verify_quote` (cek kutipan), `shamela_lookup_hadith`, `shamela_lookup_tafsir`, `shamela_lookup_quran`, `shamela_cite`, `search` + `fetch` (format ChatGPT) |
| Akses | **Tanpa akun, tanpa kunci.** Keyless: 10 panggilan/menit + **200/hari per IP**; kunci gratis (accounts.qurangallery.com/developers) → 60/menit |
| Yang dikembalikan | Teks Arab verbatim **maks ±1.600 karakter per potongan**, + jilid/halaman cetak (`printedPage`), edisi/editor/penerbit bila tercatat, `bookId`/`pageId`, tautan ke pembaca Maktabah; penanda `matchedIn` (teks utama vs catatan kaki editor) |
| Bahasa query | **Arab saja** (query Inggris ditolak) |
| Lisensi | Repo dokumentasi CC BY 4.0; **source server TIDAK dipublikasikan — tidak bisa self-host** |
| Batasan | Tidak memberi derajat hadis / fatwa / terjemahan; **tidak mengembalikan kitab utuh** (halaman per halaman); tidak bisa tambah kitab sendiri |

**Bukti uji live (16 Nov 2026, via curl JSON-RPC):**
- `initialize` → HTTP 200, server `qurangallery-shamela` v0.3.0, protokol MCP 2025-11-25.
- `shamela_find` kind=book query `الآجرومية` → **48 kitab cocok**, termasuk متن الآجرومية (id 11371, Ibn Ajrum w. 723H), الدرة البهية نظم الآجرومية (id 2084, al-Imriti), متممة الأجرومية (id 4234).
- `shamela_find` query `عقيدة العوام` → **0 kitab yang judulnya cocok** — server sendiri memperingatkan bahwa tidak ada kitab dengan judul itu di pustaka (8.594 kitab). Jadi Aqidatul Awam **tidak ada** di Shamela. (Detail §4.3.)

### 2.2 Shamela Link — alternatif hosted (tidak diuji live)

| | |
|---|---|
| Endpoint | `https://shamela.link/mcp` |
| Operator | Proyek independen, **tidak terafiliasi** shamela.ws; gratis, read-only |
| Syarat (terms, diperbarui 29 Agu 2026) | "Use it for research and study. **Do not mirror the whole library through it.**" Tidak ada jaminan layanan terus berjalan atau hasil bebas galat. Teks dan kerja editorial milik pengarang/penerbitnya. |

### 2.3 MCP lokal — butuh install Shamela di komputer (TIDAK cocok untuk game/server)

| Repo | Cara kerja | Kenapa tidak dipakai |
|---|---|---|
| `alhoqbani/shamela-mcp` | Ekstensi `.mcpb` untuk Claude Desktop; butuh **Maktabah al-Shamela 4 terinstall lokal** (folder `C:\shamela4`) | Desktop saja; tidak ada server yang bisa dipanggil game/VPS |
| `omerfaruk-oz/shamela-chatgpt` | Shamela MCP v1.2.0, **30 tool**; butuh Shamela lokal + Node.js + JDK; database Shamela ±20 GB | Sama — lokal Windows/Mac/Linux; instalasi berat (5 aplikasi) |

**Kesimpulan §2:** MCP Shamela itu nyata dan berguna — **untuk riset dan kurasi konten oleh tim**, bukan sebagai feed runtime game. Jalur yang benar: tim (Xam/Laras) memakai Quran Gallery MCP untuk mencari + memverifikasi teks saat menyiapkan materi; teks yang sudah dikurasi disimpan sebagai JSON di VPS; game membaca dari VPS.

---

## 3. Alternatif sumber teks (untuk dibundel ke game/server)

### 3.1 OpenITI — SUMBER UTAMA (terverifikasi penuh) ✅

**Open Islamicate Texts Initiative (OpenITI)** — korpus teks Islam pra-modern yang bisa dibaca mesin, dari proyek KITAB (Tufts → Leipzig → Hamburg).

- **Isi:** ±8.700 judul, 3.300+ pengarang, 861 juta kata (versi primer; 2,4 miliar kata dengan semua versi). Hampir semua teks Arab; sumbernya Shamela, Shia Online Library, dan al-Jami' al-Kabir.
- **Akses:** GitHub `github.com/OpenITI` (repo per 25 tahun wafat pengarang, mis. `0725AH` untuk pengarang w. 701–725H) + rilis Zenodo **DOI 10.5281/zenodo.3082463** (rilis 2025.1.9: data 5,9 GB; **metadata TSV 12,1 MB**).
- **Format:** teks polos **mARkdown** (dialek Markdown) + header `#META#` (pengarang, judul, edisi, URI Shamela). Perlu satu kali proses bersih → JSON (buang `#META#`, penanda halaman `# PageV00P000`, heading `### |`, lanjutan baris `~~`).
- **Lisensi: CC BY-NC-SA 4.0** (tertera di openiti.org/documentation + Terms of Use). Atribusi wajib, **non-komersial**, turunan harus share-alike. OpenITI menyatakan: edisi yang masih berhak cipta dibersihkan dari konten editorial berhak cipta (catatan kaki, pendahuluan) saat anotasi.
- **Kualitas:** sebagian teks masih butuh koreksi (ada kolom `uncorrected_OCR`); komunitas pengguna MCP Shamela juga memperingatkan teks Shamela kadang tidak presisi (OCR, diakritik salah tempat, kutipan tidak lengkap). **Artinya: tiap kitab yang masuk rak WAJIB dicek ustadz sebelum terbit di game** — jangan tampilkan mentah-mentah.

**Bukti uji (16 Nov 2026):**
- Metadata TSV 2025.1.9 diunduh (12.092.756 byte, 14.107 baris) dan digrep untuk shortlist (§4).
- File asli diambil dari GitHub dan dibaca isinya:
  - `OpenITI/0725AH` → Jurumiyah, 21.326 byte — teks asli terbaca: *"الكلام: هو اللفظ المركب المفيد بالوضع. وأقسامه ثلاثة: اسم، وفعل، وحرف جاء لمعنى."*
  - `OpenITI/1275AH` → Safinatun Naja, 46.872 byte (termasuk lampiran Safinat al-Salat) — terbaca: *"أركان الإسلام خمسة: شهادة أن لاإله إلاالله وأن محمد رسول الله…"*

### 3.2 fawazahmed0/hadith-api — hadis + terjemahan Indonesia (Unlicense) ✅

- **Isi (v1, terverifikasi via `editions.json`):** 10 koleksi — Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasai, Ibn Majah, Muwatta Malik, **Arba'in Nawawi**, Forty Hadith Qudsi, Forty Hadith Dehlawi.
- **Bahasa:** Arab + Inggris + **Indonesia (`ind-*`)** untuk 7 koleksi (Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasai, Ibn Majah, Malik). **Tidak ada `ind-nawawi`** (Arba'in hanya Arab/Inggris/Bengali/Prancis/Turki) dan **tidak ada Riyadhus Shalihin** di v1.
- **Akses:** CDN jsDelivr, tanpa kunci, tanpa rate limit. Lisensi dataset: **Unlicense** (domain publik dari penyusunnya); terjemahan tetap karya penerjemahnya masing-masing.
- **Catatan:** tidak ada informasi derajat (sahih/hasan/da'if) per hadis di API ini — bila derajat ditampilkan, ambil dari sumber lain (mis. HadithAPI.com atau isnady-data).

### 3.3 fawazahmed0/quran-api — teks Al-Qur'an + terjemahan (Unlicense)

- Teks Uthmani + 90+ bahasa / 400+ edisi, termasuk terjemahan Indonesia (Kemenag), via CDN jsDelivr, tanpa kunci. Berguna bila rak kitab nanti juga menampilkan ayat (mis. untuk khataman) — bukan kitab, tapi dicatat di sini karena satu keluarga sumber.

### 3.4 Lainnya (dicatat, tidak diuji mendalam)

| Sumber | Isi | Lisensi / catatan |
|---|---|---|
| sunnah.com API | Semua koleksi hadis besar | Kunci gratis via GitHub; tidak diuji live |
| isnady-data (bayramkotan) | 17 koleksi hadis Sunni + 16 Syiah, 99.746 hadis, **dengan derajat**; Arba'in + Riyadhus Shalihin + Bulugh al-Maram | Lisensi per sumber (tier A/B/C); data dalam format sendiri |
| AhmedBaset/hadith-json | 50.884 hadis, 17 kitab, Arab + Inggris | **Tanpa lisensi eksplisit** — hasil scrape sunnah.com (abu-abu); jangan pakai untuk produksi |
| archive.org (terjemahan Indonesia kitab kuning/hadis) | Scan buku cetak (mis. Terjemah 9 Imam, Riyadhus Shalihin, Arba'in) | **Status hak cipta tidak jelas** — scan buku cetak modern; jangan dibundel |

### 3.5 Lisensi — ringkasan per sumber

| Sumber | Lisensi | Boleh di game (non-komersial)? | Yang wajib dicantumkan |
|---|---|---|---|
| OpenITI (teks Arab klasik) | **CC BY-NC-SA 4.0** | ✅ Ya, selama non-komersial | Atribusi OpenITI + URI file + pengarang; turunan share-alike |
| Quran Gallery MCP (saat riset) | Docs CC BY 4.0; teks milik pengarang/penerbit | ✅ Untuk riset/kurasi; ❌ jangan jadikan feed runtime | Kutipan: kitab + pengarang + jilid/halaman cetak |
| Shamela Link MCP | Syarat: riset/studi, **dilarang mirror** | ✅ Riset saja | — |
| fawazahmed0 hadith-api / quran-api | **Unlicense** | ✅ Ya | Sebaiknya tetap cantumkan sumber + penerjemah |
| Terjemahan Indonesia kitab kuning (internet) | Mayoritas **berhak cipta** (penerjemah/penerbit modern) | ❌ Jangan dibundel | — |
| Pengarang klasik (w. berabad lalu) | Teks aslinya **domain publik** | ✅ Ya (teksnya) | — |
| Ringkasan Indonesia orisinal (Laras) | Milik Pesantren Universe | ✅ Ya | — |

**Peringatan penting:** CC BY-NC-SA 4.0 berarti **bila game suatu hari menjadi komersial, teks OpenITI tidak boleh dipakai begitu saja** — harus diganti dengan teks domain-publik murni atau diurus izinnya. Selama non-komersial, aman dengan atribusi. Atribusi bisa ditampilkan di dalam rak kitab (mis. baris kecil "Teks: OpenITI, CC BY-NC-SA 4.0").

---

## 4. Shortlist kitab pesantren — ketersediaan terverifikasi

Ukuran = `char_length` dari metadata OpenITI 2025.1.9 (jumlah karakter teks Arab; file UTF-8 bersih ≈ 2 byte/karakter + struktur JSON). "OpenITI" = ada di korpus (status `pri` = versi primer, kecuali dicatat). "Shamela MCP" = ditemukan lewat Quran Gallery MCP (diuji untuk Jurumiyah/Imrithi/Aqidatul Awam; sisanya disimpulkan dari ID Shamela yang sama di metadata OpenITI — perlu cek ulang satu per satu saat kurasi).

### 4.1 Sembilan kitab yang ADA di OpenITI

| # | Kitab (Arab) | Pengarang (w.) | OpenITI | Ukuran teks | Shamela MCP | Terjemahan Indonesia (open) |
|---|---|---|---|---|---|---|
| 1 | **متن الآجرومية** — Jurumiyah | Ibn Ajrum (723H) | ✅ `0723IbnAjrum.Ajrumiyya.Shamela0011371` | 8.020 kar ≈ **16 KB** (file mentah 21 KB) | ✅ id 11371 (diuji live) | ❌ Tidak ada (open) — pakai ringkasan Laras |
| 2 | **الدرة البهية نظم الآجرومية** — Imrithi | al-Imriti (989H) | ✅ `0989SharafDinCimriti.DurraBahiyya.Shamela0002084` | 10.138 kar ≈ **20 KB** | ✅ id 2084 (diuji live) | ❌ Tidak ada (open) |
| 3 | **ألفية ابن مالك** — Alfiyah | Ibn Malik (672H) | ✅ `0672IbnMalik.Alfiyya.Shamela0008522` | 38.923 kar ≈ **78 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada (open) |
| 4 | **متن سفينة النجا** — Safinatun Naja | Salim al-Hadrami (1271H) | ✅ `1271SalimHadrami.MatnSafinatNaja.ShamAY0037367` | 19.181 kar ≈ **38 KB** (file mentah 47 KB, termasuk Safinat al-Salat) | ✅ (ID Shamela 37367) | ❌ Tidak ada (open) |
| 5 | **متن قطر الندى** — Qatr al-Nada | Ibn Hisham (761H) | ✅ `0761JamalDinIbnHisham.MatnQatrNada.Shamela0011376` | 15.956 kar ≈ **32 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada (open) |
| 6 | **متن شذور الذهب** — Shudhur al-Dhahab | Ibn Hisham (761H) | ✅ `0761JamalDinIbnHisham.MatnShudhurDhahab.Shamela0096770` | 18.553 kar ≈ **37 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada (open) |
| 7 | **الغاية والتقريب** — Matn Abi Shuja | Abu Shuja (593H) | ✅ `0593IbnHusaynShihabDinIsbahani.GhayaWaTaqrib.Shamela0011370` | 36.371 kar ≈ **73 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada (open) |
| 8 | **بداية الهداية** — Bidayat al-Hidayah | al-Ghazali (505H) | ✅ `0505Ghazali.BidayatHidaya.Shamela0012718` | 60.605 kar ≈ **121 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada (open) |
| 9 | **بلوغ المرام** — Bulugh al-Maram | Ibn Hajar (852H) | ✅ `0852IbnHajarCasqalani.BulughMaram.Shamela0009111` | 212.674 kar ≈ **425 KB** | ✅ (ID Shamela sama) | ❌ Tidak ada di fawazahmed0 v1 |

**Tiga kitab besar (ada, tapi sajikan per bab, jangan sekaligus):**

| # | Kitab | Pengarang (w.) | OpenITI | Ukuran teks | Catatan |
|---|---|---|---|---|---|
| 10 | **رياض الصالحين** — Riyadhus Shalihin | al-Nawawi (676H) | ✅ `0676Nawawi.RiyadSalihin.Shamela0012014` (pri) | 119.900 token / 494.315 kar ≈ **1 MB** | Tidak ada di fawazahmed0 v1; tampilkan per bab (ada ±400 bab — cocok untuk struktur JSON per bab) |
| 11 | **تفسير الجلالين** — Tafsir Jalalayn | al-Mahalli (864H) + al-Suyuti (911H) | ✅ `0911Suyuti.TafsirJalalayn.JK000818` (pri) | 224.855 token / 938.909 kar ≈ **1,9 MB** | Sajikan per surah/ayat — jangan dimuat utuh |
| 12 | **الأربعون النووية** — Arba'in Nawawi | al-Nawawi (676H) | ⚠️ **Matn tidak ditemukan** — yang ada hanya syarahnya (Ibn Daqiq al-Id, al-Munawi, al-Khudayr) | — | Ambil matn dari **fawazahmed0** (`ara-nawawi` + `eng-nawawi`; 42 hadis, kecil); **tidak ada `ind-nawawi`** di v1 |

**Total 12 kitab (Arab, bersih): ±1,87 juta karakter ≈ 3,7 MB UTF-8** (±4 MB sebagai JSON). Delapan kitab kecil (no. 1–8) saja: ±223 ribu karakter ≈ **450 KB**. Sebagai perbandingan: pck game saat ini 1,54 MB, wasm 39,5 MB — membundel 8 kitab kecil menambah ±1% total unduhan game; membundel semua 12 menambah ±10%.

### 4.2 Kitab pendukung lain yang ADA di OpenITI (cadangan)

| Kitab | Pengarang | Ukuran | Untuk |
|---|---|---|---|
| متن العقيدة الطحاوية (Matn al-Aqida al-Tahawiyya) | al-Tahawi (321H) | 9.409 kar ≈ 19 KB | Pengganti Aqidatul Awam (aqidah) |
| الشافية في علم التصريف (al-Shafiya) | Ibn al-Hajib (646H) | 42.645 kar ≈ 85 KB | Pengganti Amtsilah (sarf klasik) |
| فتح القريب المجيب (syarah Abi Shuja) | Ibn Qasim al-Ghazzi (918H) | 171.521 kar ≈ 343 KB | Syarah fiqih, bila Matn Abi Shuja kurang |
| إحياء علوم الدين (Ihya Ulumuddin) | al-Ghazali (505H) | 4.120.661 kar ≈ **8 MB** | Terlalu besar — hanya kutipan/bab pilihan, bukan utuh |
| شرح الآجرومية (Dahlan) | Ahmad Zayni Dahlan (1304H) | 64.584 kar ≈ 129 KB | Syarah Jurumiyah |

### 4.3 Tiga kitab yang TIDAK ditemukan (jujur dicatat)

| Kitab | Hasil cek | Dugaan penyebab | Jalan keluar |
|---|---|---|---|
| **عقيدة العوام** — Aqidatul Awam (Ahmad al-Marzuqi, w. 1281H) | OpenITI: 0 hit. Shamela MCP: 0 judul cocok (server sendiri menyatakan tidak ada). | Karya abad 19, nazm pendek — belum masuk digitalisasi Shamela/OpenITI. | Pakai **Matn al-Aqida al-Tahawiyya** (ada, §4.2) untuk aqidah; atau cari teks Aqidatul Awam dari sumber lain (mis. situs pesantren / archive.org — cek lisensinya dulu) dan ketik manual dengan izin. |
| **تعليم المتعلم** — Ta'lim al-Muta'allim (al-Zarnuji, w. ±620H) | OpenITI: 0 hit (termasuk pencarian longgar 'الزرنوجي'). Shamela MCP: 0 hasil relevan. | Belum masuk kedua korpus (mungkin ada di Shamela dengan judul berbeda / di mustawda' yang tidak terindeks). | Cek judul alternatif di Shamela MCP (`تعليم المتعلم طريق التعلم`); bila tetap tidak ada, sumber lain: archive.org (scan) atau ketik dari cetakan dengan izin ustadz. |
| **أمثلة التصريفية** — Amtsilah Tashrifiyyah | OpenITI: 0 hit (yang muncul hanya kitab sarf klasik lain). Shamela MCP: 0 hasil relevan. | **Kitab pesantren modern Indonesia** (KH Muhammad Ma'shum ibn Ali, Jombang, abad 20) — bukan klasik, kemungkinan masih berhak cipta dan memang tidak ada di Shamela. | Pakai **al-Shafiya fi Ilm al-Tasrif** (ada, §4.2) sebagai sarf klasik; atau tulis materi Amtsilah sendiri dari kurikulum (Laras) — jangan salin dari buku cetak tanpa izin. |

---

## 5. Arsitektur yang disarankan

### 5.1 Rekomendasi: VPS sebagai pustaka (game fetch JSON per kitab)

**Cara kerja:** teks kitab disimpan sebagai **JSON per kitab/bab di server VPS Pesantren Universe** (server yang sama dengan API santri v1.4.0). Game memanggil endpoint mis. `GET /api/kitab/daftar` dan `GET /api/kitab/{id}?bab=n` lewat HTTPRequest saat santri mengklik rak kitab → tombol "Baca". Hasil di-cache di `user://` supaya buka kedua kalinya tidak perlu unduh ulang.

| | VPS sebagai pustaka (disarankan) | JSON di dalam pck game |
|---|---|---|
| Tambah kitab baru | ✅ Tanpa redeploy game (tambah file JSON + endpoint) | ❌ Tiap kitab baru = export + deploy ulang game ±40 MB |
| Koreksi teks (salah OCR/diakritik) | ✅ Perbaiki di server, langsung berlaku | ❌ Redeploy penuh |
| Kontrol akses (kitab terbuka sesuai jenjang/progres santri) | ✅ Server bisa cek progres santri sebelum menyajikan bab | ❌ Semua teks ikut terunduh siapa pun |
| Ketergantungan pihak ketiga saat bermain | ✅ Tidak ada (teks di server sendiri) | ✅ Tidak ada |
| Butuh internet | ⚠️ Ya — tapi game web memang selalu online | ❌ Bisa offline |
| Ukuran unduhan awal | ✅ pck tetap 1,54 MB | ⚠️ +450 KB (8 kitab) s.d. +4 MB (12 kitab) |
| Kerja bangun | Endpoint baru di server (Saka) + konverter OpenITI→JSON (sekali) + UI baca di game (Raka) | Konverter + UI baca di game (Raka) |

**Kenapa bukan MCP saat runtime (tegas):**
1. Godot tidak bisa bicara protokol MCP — MCP butuh klien JSON-RPC/SSE; game hanya bisa HTTP biasa.
2. Limit Quran Gallery MCP keyless **200 panggilan/hari per IP** — habis oleh segelintir pemain dalam sehari; kunci gratis pun 60/menit per IP server, bukan per pemain.
3. Potongan teks **maks ±1.600 karakter** — membaca satu bab butuh puluhan panggilan.
4. Syarat Shamela Link **melarang mirror** seluruh pustaka; mengandalkan layanan pihak ketiga yang bisa mati kapan saja untuk fitur inti game adalah risiko yang tidak perlu.
5. Peran MCP yang benar: **alat riset/kurasi di tangan tim** (mencari kitab, memverifikasi kutipan, membandingkan edisi) — bukan feed data game.

### 5.2 Alur kurasi yang disarankan (sebelum kitab tayang di game)

1. **Ambil** — unduh file OpenITI/fawazahmed0 untuk kitab yang dipilih (jalurnya sudah terverifikasi di §4).
2. **Konversi** — skrip sekali jalan: buang `#META#` + penanda mARkdown → JSON `{kitab, pengarang, bab:[{judul, teks}]}`. Untuk hadis fawazahmed0, JSON sudah jadi.
3. **Cek ustadz** — WAJIB: teks Arab dicek (OCR Shamela/OpenITI kadang salah diakritik/kata). Jangan tayang mentah.
4. **Ringkasan Indonesia** — Laras menulis ringkasan/penjelasan orisinal per bab (dari materi ebook Nahwu/Fiqih) — ini yang membuat rak kitab jadi materi belajar, bukan sekadar teks Arab.
5. **Terbit di VPS** — Saka tambah endpoint + file JSON; cantumkan atribusi (OpenITI CC BY-NC-SA 4.0 + pengarang + edisi) di tiap kitab.
6. **Baca di game** — Raka: UI daftar kitab di rak → halaman baca (teks Arab font Amiri + ringkasan Indonesia + tombol bab sebelumnya/berikutnya + penanda progres baca).

### 5.3 Kitab pertama yang disarankan

**Jurumiyah** — 8 KB, teks paling kecil; sudah jadi materi Nahwu Dasar (ebook + misi M1–M3), jadi rak kitab langsung nyambung dengan kurikulum dan progres santri. Urutan berikut: Safinatun Naja (Fiqih, 19 KB) → Durra Bahiyya/Imrithi (nahwu lanjutan, 10 KB) → Matn Abi Shuja (Fiqih, 36 KB) → Arba'in Nawawi (hadis, via fawazahmed0).

---

## 6. Yang masih perlu diputuskan Mas

1. **Kitab pertama:** setuju Jurumiyah dulu? (usul Zahra: ya)
2. **Bahasa tampilan:** Arab saja dulu, atau Arab + ringkasan Indonesia orisinal dari tim materi (butuh kerja Laras per bab)?
3. **Kitab besar (Riyadhus Shalihin ±1 MB, Tafsir Jalalayn ±1,9 MB):** tampilkan per bab/surah — setuju?
4. **Pengganti tiga kitab yang tidak ditemukan:** Aqidatul Awam → Tahawiyya (atau cari sumber lain)? Ta'lim al-Muta'allim → cari sumber lain / ketik manual? Amtsilah → tulis materi sarf sendiri / pakai al-Shafiya?
5. **Atribusi lisensi:** tampilkan baris kecil "Teks: OpenITI (CC BY-NC-SA 4.0)" di dalam rak kitab — setuju?

---

## 7. Sumber (yang benar-benar dibuka/diverifikasi 16 Nov 2026)

- Quran Gallery MCP — repo dokumentasi: https://github.com/qurangallery/kb-mcp — endpoint `https://qurangallery.com/mcp/shamela` — **diuji live** (initialize + `shamela_find` Jurumiyah 48 hasil + Aqidatul Awam 0 hasil).
- Shamela Link — https://shamela.link/mcp — syarat: https://shamela.link/en/terms.
- MCP lokal: https://github.com/alhoqbani/shamela-mcp · https://github.com/omerfaruk-oz/shamela-chatgpt (ditemukan lewat pencarian; tidak diuji install).
- OpenITI — https://kitab-project.org/data/download · metadata Zenodo DOI 10.5281/zenodo.3082463 (rilis 2025.1.9) · lisensi: https://openiti.org/documentation/ (CC BY-NC-SA 4.0) — **metadata 14.107 baris diunduh + 2 file asli diambil dari GitHub dan dibaca isinya**.
- fawazahmed0/hadith-api — `editions.json` via jsDelivr (10 koleksi; `ind-*` untuk 7 koleksi; tanpa `ind-nawawi`; tanpa riyadussalihin) — **diunduh dan diperiksa**.
- fawazahmed0/quran-api — https://github.com/fawazahmed0/quran-api (Unlicense).
- Catatan lisensi tambahan: https://openiti.org/docs/Terms%20of%20Use.html · https://www.visualdhikr.org/en/terms (menyebut OpenITI CC BY-NC-SA 4.0).

## Keputusan Mas (16 Nov ~18:47 WIB — ACC)

1. Kitab pertama: **Jurumiyah** — ACC.
2. Tampilan: **Arab saja** (tanpa ringkasan Indonesia untuk sekarang).
3. Kitab besar (Riyadhus Shalihin, Tafsir Jalalayn) disajikan **per bab/surah** — ACC.
4. Pengganti 3 kitab yang tidak ditemukan (Tahawiyya, al-Shafiya) — ACC.
5. Atribusi **"Teks: OpenITI (CC BY-NC-SA 4.0)"** ditampilkan di dalam rak kitab — ACC.
6. **Full MCP Shamela + fitur terjemahan DITUNDA sampai ada gedung Perpustakaan** (200 santri) — tidak dibangun sekarang. Arsitektur sekarang: VPS sebagai pustaka (OpenITI), game fetch JSON saat buka rak.
7. Saka sedang membangun pustaka VPS v1.5.0 (Jurumiyah, `dicek_ustadz: false` — teks wajib dicek ustadz sebelum dibaca santri). Pembaca di game (Raka) menyusul setelah Ronde 20.
