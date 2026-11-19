# DESAIN SISTEM NPC — 50 Santri Baru, Aktivitas, & Hormat (v1)

**Tanggal:** 19 November 2026, ~14:00 WIB
**Pembuat:** Laras, lead Tim Materi/Alur Game
**Status:** DESAIN untuk dinilai Mas — **belum dibangun, belum ada kode game yang diubah.**
**Perintah Mas (19 Nov 14:00 WIB):** (1) tambah 50 NPC putra-putri (nama random, wajah beda-beda); (2) [songkok — dikerjakan Kirana paralel, bukan dokumen ini]; (3) NPC tidak hanya mondar-mandir — juga duduk di kursi / samping musholla / kamar sambil baca kitab / jalan sambil bawa kitab; (4) [NPC tembus tembok — diselidiki Raka paralel, bukan dokumen ini]; (5) bila Kyai/Ustadz/pengurus lewat, NPC minggir sambil nunduk menyilangkan tangan (hormat) ATAU menghampiri lalu salaman + cium tangan bergantian.

**Yang dibaca sebagai dasar:** `scripts/npc.gd` (576 baris — mesin NPC: jalan bebas, patroli Kyai/Ustadzah, sholat, duduk baca), `scripts/player.gd` (`build_visual`, `_kitab()`, pose salaman, `PAKAIAN_*`), `scripts/main.gd` (`_spawn_npcs`, 8 NPC yang ada), `scripts/mission_data.gd` (outfit + NPC_LINES), `scripts/pesantren_builder.gd` + `scripts/kampus_putri.gd` (tata letak + kursi/bangku), `v2/konsep/karakter/KONSEP-KARAKTER.md` (sistem wajah datar Kirana).

**Prinsip yang dipegang:**
- Pakai ulang yang sudah ada: `SantriNPC.setup()`, `build_visual()`, `_kitab()`, `PAKAIAN_DUDUK`, mesin patroli (teleport GTA lewat pintu), pose salaman pemain. Tidak ada sistem baru dari nol kecuali yang benar-benar belum ada (pose nunduk + tangan menyilang + cium tangan, mesin aktivitas, mesin hormat).
- NPC tetap BUKAN pemain dan BUKAN multiplayer — lokal saja, tidak tersinkron ke server (seperti Bilal/Faris sekarang).
- Gender tetap terpisah: NPC putra tidak pernah masuk area putri dan sebaliknya (tembok x=14, gerbang tertutup). Ini aturan desain, bukan sekadar kebetulan waypoint.
- Semua angka pose di dokumen ini adalah **nilai awal untuk tuning di foto** — bukan final. Yang final adalah yang terlihat benar di foto verifikasi.

---

## BAGIAN 1 — TAMBAH 50 NPC PUTRA-PUTRI

### 1.1 Pembagian: 25 putra + 25 putri

Usulan: **25 santri putra + 25 santriwati = 50 NPC baru**. Total NPC di dunia menjadi 58 (8 lama + 50 baru). Alasan 25+25: seimbang, dan angka 25 sama dengan ambang Ruang Kelas — dunia terasa "penuh" tanpa menumpuk di satu zona.

- Putra tinggal di zona putra (barat tembok x=14). Putri di zona putri (x 115..216). Tidak ada NPC yang menyeberang.
- NPC baru **ikut sholat berjamaah** seperti Bilal/Faris (jalan ke Surau/Musholla sesuai gender). **TAPI ada yang belum terjawab:** berapa slot sajadah yang tersedia di interior Surau/Musholla? Bila slot kurang dari 50, NPC sisa sholat di serambi/halaman (sajadah luar) atau tetap di tempat. → **Ditandai untuk Raka saat bangun** (cek kapasitas sajadah dulu, jangan asumsikan muat semua).
- NPC baru **bisa diajak bicara** seperti Bilal/Faris (kalimat acak `NPC_LINES`, feed melayang) — tetapi **tidak bisa ditanya teka-teki** (itu hanya Kyai/Bilal/Faris/Satpam/Mariyah/Penjaga). Alasan: teka-teki terikat langkah 4 misi; 50 penanya baru mengacaukan alur.

### 1.2 Nama random — pool nama santri Indonesia

Nama tampil = nama depan saja (seperti "Bilal", "Faris"). Saat spawn, tiap NPC mengambil satu nama dari pool gendernya dengan RNG berseed (seed = nomor urut NPC) — **tidak ada dua NPC yang bernama sama** dalam satu dunia. Pool 30 nama per gender (lebih dari 25, supaya ada sisa untuk ganti bila ada yang bentrok dengan nama pemain/NPC lama):

**Putra (30):** Ahmad, Rizky, Fajar, Yusuf, Umar, Ali, Hasan, Zaid, Hamzah, Thoriq, Irfan, Dimas, Bagus, Fikri, Naufal, Rafi, Syakir, Luqman, Imran, Salman, Azzam, Danish, Haikal, Iqbal, Wildan, Lutfi, Fadhil, Rayhan, Ghani, Taufik.

**Putri (30):** Aisyah, Maryam, Khadijah, Zahra, Salsabila, Nabila, Putri, Dewi, Rania, Aqila, Syifa, Laila, Hana, Najwa, Amira, Safa, Talita, Kirana, Nadia, Wulan, Sinta, Laras, Dita, Nusa, Bilqis, Humaira, Raudhah, Syakira, Zakia, Fathia.

- Nama-nama ini **pool acak, bukan tokoh nyata** — tidak ada yang merujuk santri sungguhan.
- Bila nanti ada pemain bernama sama dengan NPC (mis. pemain bernama "Rizky"), NPC yang bentrok memakai nama cadangan dari sisa pool. Aturan ini ditulis di kode, bukan dihafal.

### 1.3 Wajah beda-beda — sumbu variasi

Hari ini `build_visual()` sudah membedakan NPC lewat: warna kulit (3 preset: Terang `#e8b98a`, Sawo Matang `#c68e5e`, Gelap `#8a5a33`), kacamata (ya/tidak), warna songkok (putih/hitam), warna koko (4), warna sarung (4), abaya (4), jilbab (4), plus serban/jenggot/kumis (khusus Kyai). Yang **belum ada** dan diusulkan sebagai kunci outfit baru (opsional, default = tampilan sekarang — save lama dan NPC lama tidak berubah):

| Sumbu | Pilihan | Catatan |
|---|---|---|
| Jarak mata | rapat / normal / lebar (±0,015 m dari posisi baku ±0,085) | Perubahan kecil, efek besar di wajah |
| Ukuran mata | kecil 0,022 / normal 0,025 / besar 0,028 | 0,028 sudah dipakai muslimah hari ini |
| Alis | lurus / miring ke dalam / naik | 2 kapsul tipis di atas mata (sudah ada polanya di wajah Ustadzah, `player.gd` ~:1100) |
| Hidung | kecil / sedang (skala bola hidung 0,8 / 1,0) | — |
| Senyum | tipis / lebar (lengkung mulut dari 5 bola — tambah 2 bola ujung) | Tetap senyum tertutup (keputusan KONSEP-KARAKTER) |
| Rambut (putra) | poni pendek kiri / tengah / kanan (pinggiran rambut di bawah peci) | Rambut tetap pendek rapi, dahi terlihat (keputusan Mas 17 Nov) |
| Model peci (putra) | songkok bulat putih (yang ada) / **peci hitam nasional** (atas rata) | Spesifikasi ikut konsep Kirana `KONSEP-SONGKOK-v1.md` (14:04, menunggu ACC Mas): kunci outfit baru `peci_model`: `"bulat"`\|`"nasional"`; peci nasional = kerucut terpancung atas rata (r atas 0,205 / bawah 0,235, tinggi 0,18, pusat y=1,825, #151515); usulan pembagian santri putra NPC **campur 50/50 acak** per NPC |
| Tinggi badan | skala visual 0,95 / 1,00 / 1,05 | Hanya visual — kecepatan jalan tetap 1,6 m/s |
| Kacamata | ya / tidak (sudah ada) | — |

**Kombinasi putra:** 3 kulit × 3 jarak mata × 3 ukuran mata × 2 kacamata × 2 model peci × 4 koko × 4 sarung = **1.728 kombinasi** — 25 NPC pasti beda. Putri: 3 kulit × 3 jarak mata × 3 ukuran mata × 2 kacamata × 4 abaya × 4 jilbab = **1.728 kombinasi**. RNG berseed per NPC supaya tampilannya tetap sama tiap kali game dibuka (tidak ganti wajah tiap login).

**Yang TIDAK diubah:** sistem wajah datar Kirana (mata titik, senyum tertutup, tanpa bola mata 3D), palet resmi (krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A`, batu `#B8B2A4`), dan proporsi chibi santri (3,0 kepala putra / 2,5 putri).

### 1.4 Zona spawn & patroli — di mana 50 NPC tinggal

**Aturan keras (dampak bug tembusan, Raka sedang menyelidiki):**
1. Setiap NPC baru mendapat **waypoint-nya sendiri di dalam satu sub-zona** — bukan `NPC_WAYPOINTS` global yang lama (24 titik, x −100..100, z −100..120; titik `(0,−20)` terbukti DI DALAM tapak Surau, dan segmen antar titik jauh menyeberang bangunan).
2. Segmen antar waypoint **divalidasi saat bangun** terhadap daftar tapak bangunan (tes otomatis: tidak ada segmen yang memotong tapak; bila ada, waypoint digeser — bukan dibiarkan).
3. NPC tidak pernah diberi waypoint di dalam interior (interior hanya lewat teleport pola patroli Kyai/Ustadzah — lihat Bagian 2.6).

**Zona putra (25 NPC)** — tapak yang dihindari: Surau (x −8..8, z −24..−4), Cangkruk (−22,−18) ±3 m, Asrama Putra (−34,75..−13,25, z 4..16), tembok x=14 (z −60..+16), peti (0,26) radius 2 m:

| Sub-zona | Koordinat jalan | Jumlah | Keterangan |
|---|---|---|---|
| Plaza Surau | x −8..8, z −2..14 | 8 | Depan Surau, jalur utama santri baru |
| Halaman Asrama–Cangkruk | x −32..−14, z −24..16 | 6 | Di luar tapak Asrama + Cangkruk |
| Taman selatan | x −8..8, z 22..34 | 6 | Sekitar bangku taman + peti (jaga jarak 2 m dari peti) |
| Jalur barat / sawah | x −60..−30, z 0..40 | 5 | Lapang terbuka, waypoint berjauhan |

**Zona putri (25 NPC)** — tapak yang dihindari: Musholla (x 128..140, z −29..−19), Kelas (130,0)/(130,10), Asrama Putri (x 144..166, z 3..15), Kantor (148,−33), Madrasah (152,−12), Studio (166,−12), Pos Jaga (176,−20), tembok keliling (x 115..216, z −70..+40):

| Sub-zona | Koordinat jalan | Jumlah | Keterangan |
|---|---|---|---|
| Halaman Musholla | x 126..142, z −32..−16 | 8 | Depan Musholla Ar-Raudhah |
| Halaman Kelas–Madrasah | x 124..138, z −4..14 | 6 | Antara Kelas dan Madrasah |
| Taman Putri | x 117..127, z 28..36 | 6 | Sekitar 2 bangku taman |
| Halaman Asrama Putri | x 146..164, z 14..28 | 5 | Di luar tapak Asrama Putri |

Koordinat tapak di atas diambil dari `pesantren_builder.gd` / `kampus_putri.gd` + MEMORY — **wajib diverifikasi ulang dari builder saat bangun** (beberapa tapak dibulatkan). Bila tapak ternyata bergeser, zonanya ikut bergeser — jangan hardcode buta.

### 1.5 Beban performa — perkiraan jujur (untuk review Rangga)

Per karakter `build_visual()` membangun **~45 MeshInstance3D** (54 pemanggilan primitif Palette + label nama). Perkiraan kasar per NPC **~3.000–4.500 segitiga** (bola kecil mata/kancing tetap memakai segmen penuh 12×6 — boros, lihat mitigasi).

| Ukuran | Hari ini (8 NPC) | +50 NPC (perkiraan) | Kenaikan |
|---|---|---|---|
| Segitiga dunia | 510.652 | ~660.000–735.000 | +30–44% |
| Draw call | ~6.000 | ~8.250 | +~38% |
| Label3D nama | 144 | ~194 | +50 (sudah cull >40 m) |
| `_process` NPC | 8 | 58 | +50 (logika ringan, tanpa fisika) |

**Ini perkiraan, bukan pengukuran — wajib diukur Rangga sebelum ACC final.** Mitigasi yang diusulkan (pilih saat bangun, bukan sekarang):
- (a) Segmen rendah khusus NPC: bola kecil (mata, kancing, hidung) pakai segmen 6×4, bukan 12×6 — penghematan terbesar dengan perubahan terkecil.
- (b) LOD jarak: NPC di luar 60 m dari kamera disembunyikan detail kecilnya (kancing, mata) atau seluruhnya bila di luar 100 m dan bukan guru — dunia 800 m, sebagian besar NPC tidak terlihat sekaligus.
- (c) **Bangun bertahap:** gelombang 1 = 20 NPC (10+10), ukur di HP Mas, baru tambah ke 50 bila masih ringan. Ini usulan Laras — lihat keputusan no. 8.
- (d) MultiMesh untuk NPC (menggabungkan mesh yang sama) — pekerjaan besar, ditunda seperti MultiMesh kotak (Rangga).
- Nama tetap tampil <28 m seperti sekarang (aturan `npc.gd` + `player.gd`).

**Catatan:** NPC tidak menambah beban server sama sekali (lokal saja, tidak masuk multiplayer).

---

## BAGIAN 2 — AKTIVITAS NPC (TIDAK HANYA MONDAR-MANDIR)

### 2.1 Inventaris tempat duduk yang sudah ada di dunia

Duduk hanya di tempat yang memang ada kursinya — tidak ada kursi yang dimunculkan dari nol di v1 (kecuali bila Mas minta tambah — lihat keputusan no. 7).

**Luar ruangan (tanpa teleport, langsung dipakai):**

| Tempat | Koordinat | Kursi | Kapasitas duduk | Keterangan |
|---|---|---|---|---|
| Bangku Taman Putra 1 | (−3, 25,45) | bangku kayu GLB 1,6 m | 2 | Barat taman, sudah digeser dari sumbu pintu |
| Bangku Taman Putra 2 | (3,45, 28,2) | bangku kayu GLB 1,6 m | 2 | Timur taman, dekat peti — jaga jarak |
| Bangku Taman Putri Utara | (122, 30,4) | bangku kayu 1,6 m | 2 | Menghadap selatan ke jalur tengah |
| Bangku Taman Putri Selatan | (122, 33,6) | bangku kayu 1,6 m | 2 | Menghadap utara |
| Tepi teras Musholla | (134, −18) ±2 m | — (duduk di lantai teras) | 3 | Bersila di lantai, bukan kursi — lihat 2.3 |
| Bawah pohon Taman Putri | (124, 29,8) | — (duduk di rumput) | 2 | Bersila di bawah pohon |

**Dalam ruangan (pakai teleport pola patroli — lihat 2.6):**

| Tempat | Koordinat interior | Kursi | Kapasitas | Keterangan |
|---|---|---|---|---|
| Kelas Putri (interior) | z ≈ −298 | 18 kursi murid + 1 kursi Ustadzah | 6 dipakai NPC (maks) | 3 baris × 3 meja, 2 kursi per meja — NPC hanya pakai baris belakang supaya tidak menutupi Ustadzah |
| Madrasah Putri | interior | 2 kursi murid + 1 kursi guru | 2 | Kecil — hanya bila Kelas penuh |
| Cangkruk Putra | interior (offset −60) | 5 kasur | 3 | Duduk di tepi kasur sambil baca (bukan tidur) |
| Asrama Putra/Putri | interior (offset −240/−300) | 96 kasur per asrama | 4 per asrama (maks) | Duduk di tepi kasur; batasi supaya tidak berkerumun di kamar |
| Kursi Kyai / Ustadzah | Surau (5,6,−305) / Musholla (65,6,−305) | 1 + 1 | 0 | **TERLARANG untuk NPC** — kursi guru, bukan santri |

Total kapasitas duduk luar ruangan: **13 NPC sekaligus**. Dalam ruangan: **15 NPC sekaligus**. Sisanya tetap jalan/berdiri — dunia tidak pernah sepi dan tidak pernah semua duduk.

### 2.2 Mesin aktivitas — state baru di samping jalan bebas

Hari ini `npc.gd` punya 4 mode: sholat (`_mode_sholat`) > patroli (`_patroli`, Kyai/Ustadzah) > diam (`_diam`, Satpam/Penjaga) > jalan bebas (waypoint acak + jeda 3–8 dtk + ngobrol 25–45 dtk). Desain ini menambah **mode ke-5: aktivitas** — hanya untuk 50 NPC baru (Bilal/Faris tetap jalan bebas seperti sekarang; Kyai/Ustadzah tetap patroli).

```
JALAN (waypoint, seperti sekarang)
  │  setelah 1–3 waypoint tercapai, lempar dadu:
  ├─ 35% → DUDUK_KURSI (bangku/kursi luar, 60–180 dtk, baca kitab di pangkuan)
  ├─ 20% → BACA_MUSHOLLA (bersila di teras Musholla / bawah pohon, 90–240 dtk)
  ├─ 15% → BACA_KAMAR (teleport ke Cangkruk/Kelas/Asrama, duduk, 120–300 dtk)
  ├─ 15% → JALAN_KITAB (jalan 2–4 waypoint sambil bawa kitab di tangan kanan)
  └─ 15% → tetap JALAN (tidak ada aktivitas kali ini)
DUDUK_KURSI / BACA_MUSHOLLA / BACA_KAMAR
  │  timer habis → berdiri → JALAN
  │  (BACA_KAMAR: teleport keluar dulu, pola patroli)
JALAN_KITAB
  │  setelah waypoint habis → JALAN (kitab disimpan)
```

- **Sholat tetap mengambil alih segalanya** (`_mode_sholat` dicek pertama, seperti sekarang): NPC yang sedang duduk/baca ikut jalan ke Surau/Musholla saat adzan, dan kembali ke aktivitasnya setelah selesai sholat.
- **Hormat (Bagian 3) mengambil alih sementara** di atas aktivitas — NPC duduk yang dihampiri guru berdiri dulu, lalu salaman.
- **Ngobrol tetap jalan** — NPC duduk boleh mengucapkan kalimat acak (feed melayang), seperti NPC jalan sekarang. NPC yang sedang baca kitab khusyu' tidak mengobrol (timer ngobrol dijeda selama BACA_*).
- **Jeda acak per NPC** (seed seperti nama) supaya tidak semua duduk/berdiri serempak.

### 2.3 Pose duduk — dua jenis, jangan dicampur

| Pose | Dipakai di | Cara | Pakai ulang apa |
|---|---|---|---|
| **DUDUK_KURSI** (baru) | Bangku taman, kursi Kelas/Madrasah | Duduk normal: paha ke depan horizontal, lutut 90°, punggung tegak, tangan ke pangkuan memegang kitab | Nilai awal: paha rotation.x −1,4; lutut +1,4; torso tegak; lengan −0,5 ke pangkuan. **Sarung NORMAL** (bukan mengembang) |
| **BERSILA_BACA** (pakai ulang) | Teras Musholla, bawah pohon, tepi kasur | Bersila seperti Kyai/Ustadzah baca kitab | `_terapkan_duduk_baca()` di `npc.gd` + `PAKAIAN_DUDUK` / `PAKAIAN_ABAYA_DUDUK` — persis yang dipakai patroli hari ini |

Perbedaan ini penting: `PAKAIAN_DUDUK` (sarung mengembang 1,70×, hem naik) hanya benar untuk bersila di lantai. Di kursi, sarung mengembang terlihat seperti "mekar" — cacat yang baru saja diperbaiki Kirana (19 Nov). Jadi **DUDUK_KURSI memakai `PAKAIAN_DEFAULT`**, bukan `PAKAIAN_DUDUK`.

### 2.4 Prop kitab — pakai ulang `_kitab()`

Kitab sudah ada: `SantriPlayer._kitab()` — sampul marun 0,30×0,045×0,22 + halaman krem + punggung emas. Dipakai dua cara:

- **Jalan sambil bawa kitab (JALAN_KITAB):** kitab menempel di tangan kanan (pivot `arm_r`), lengan kanan sedikit ditekuk ke depan (rotation.x −0,6, siku −0,5) supaya kitab terbaca dipegang, bukan melayang. Tangan kiri tetap mengayun normal saat jalan.
- **Duduk baca (DUDUK_KURSI / BACA_*):** kitab di pangkuan (posisi seperti `_kitab_pangku` di `npc.gd`), kedua tangan terulur ke kitab (lengan −0,70, siku −0,35 — nilai yang sama dengan duduk baca Kyai). **Beda dari Kyai:** kitab Kyai disembunyikan saat duduk karena kitabnya ada di atas rehal di depan; NPC santri TIDAK punya rehal — kitabnya tetap terlihat di pangkuan.
- Kitab **disembunyikan** saat NPC jalan biasa, sholat, atau hormat (tangan harus bebas untuk salaman).

### 2.5 Kapasitas & alokasi kursi — jangan sampai dua NPC satu kursi

Kursi didaftar di `main.gd` sebagai **registry** (daftar kursi + siapa yang duduk). Saat NPC memilih DUDUK_KURSI/BACA_KAMAR, ia mengambil kursi kosong terdekat di zonanya; kursi ditandai terisi sampai ia berdiri. Bila semua kursi penuh, NPC kembali jalan (tidak menunggu di depan kursi). Bangku 1,6 m menampung 2 NPC (kiri + kanan, offset ±0,4 m dari tengah bangku).

### 2.6 Duduk di kamar (interior) — teleport, jangan jalan menembus dinding

NPC yang memilih BACA_KAMAR **tidak berjalan ke dalam gedung** — ia memakai pola yang sama dengan patroli Kyai/Ustadzah: jalan ke pintu luar → **teleport (GTA)** ke dalam → jalan ke kursi/kasur → duduk. Pulang: jalan ke pintu dalam → teleport keluar → lanjut jalan. Ini satu-satunya cara yang terbukti aman dari tembusan dinding (Raka, item 4).

Batasan interior: maks **4 NPC di dalam satu gedung** dalam satu waktu (Kelas Putri 6 — lihat tabel 2.1), dan NPC interior **tidak ikut sholat dari dalam** — saat adzan, mereka teleport keluar dulu seperti patroli, lalu ikut rute sholat normal.

---

## BAGIAN 3 — HORMAT KE KYAI / USTADZ / PENGURUS YANG LEWAT

### 3.1 Siapa yang dihormati, siapa yang menghormat

**Yang dihormati (Tier H — memicu hormat):**

| Tokoh | Alasan | Bergerak? |
|---|---|---|
| Kyai — Ust. Aqsal Murad | Pengasuh pesantren | Ya — patroli keliling pondok |
| Ustadzah Mariyah | Pimpinan pesantren putri | Ya — patroli kampus putri |
| Ust. Sanusi | Guru (Nahwu), dicari di langkah 4 misi | Jarang — diam di lokasi acak |
| Ustzh. Fatimah | Guru putri, cerminan Sanusi | Jarang — diam di lokasi acak |

**Yang TIDAK memicu hormat (keputusan desain — minta ACC Mas, lihat no. 5):** Bilal & Faris (mereka santri biasa, bukan ustadz); Satpam & Penjaga Pos Jaga (petugas, bukan guru); pemain (santri biasa). **Pengurus (musyrif) belum ada sebagai NPC** — sistem jabatan/lamaran (§9 butir 7–9) belum dibangun; begitu ada NPC atau pemain yang menjadi pengurus, namanya otomatis masuk Tier H (aturan ditulis sekarang, diberlakukan nanti).

**Yang menghormat:** semua NPC santri — Bilal, Faris, dan 50 NPC baru. Kyai/Ustadzah/Sanusi/Fatimah tidak saling menghormat satu sama lain (mereka setara guru; Kyai + Ustadzah tidak nunduk ke Sanusi). Satpam/Penjaga tetap diam di pos (tidak menghormat — mereka sedang bertugas jaga; bila Mas minta mereka ikut, lihat keputusan no. 5).

### 3.2 Aturan varian — "atau" Mas dijadikan aturan jelas

Mas menulis "minggir sambil nunduk menyilangkan tangan (hormat) **ATAU** menghampiri lalu salaman + cium tangan bergantian". Aturannya:

| Keadaan NPC saat guru lewat | Varian | Alasan |
|---|---|---|
| **Sedang JALAN** (jalan bebas / jalan kitab / patroli santri) | **A — Minggir + nunduk** | Ia sedang di jalur; menghampiri berarti memotong jalan guru dan menumpuk di tengah jalan |
| **Sedang DIAM / DUDUK** (jeda waypoint, duduk kursi, baca kitab, idle) | **B — Hampiri + salaman + cium tangan** | Ia tidak sedang ke mana-mana; menghampiri adalah adab yang pantas |
| Guru sedang **salaman dengan NPC lain** (lihat 3.4) | **A — Minggir + nunduk** (apa pun keadaannya) + masuk antre bila diam | Satu guru, satu salaman dalam satu waktu |

### 3.3 Pemicu — kapan hormat jalan

- **Jarak:** guru masuk radius **4 m** dari NPC (satu keluarga dengan jarak interact 3,5 m — sudah terbukti terasa wajar di game).
- **Cooldown:** tiap pasangan NPC–guru **60 detik**; tiap NPC **20 detik** antar hormat apa pun (supaya Kyai yang patroli melewati kerumunan tidak memicu hormat beruntun dari NPC yang sama).
- **Hanya di luar ruangan (v1).** Di dalam Surau/Musholla/Kelas, NPC yang duduk tetap duduk (tidak berdiri menyambut — mengganggu yang sedang belajar/sholat). Bila guru masuk ruangan yang sama, NPC cukup menundukkan kepala dari tempat duduk (tanpa berdiri, tanpa salaman) — varian A versi duduk.
- **Tidak saat sholat.** Selama sesi sholat (`_mode_sholat`), hormat dimatikan — semua orang sedang berjalan ke tempat sholat.
- **Tidak saat dialog misi / tes / Ruang Belajar terbuka** (panel misi terbuka = `AnimasiMixamo.panel_misi_terbuka()` — pola yang sama dengan siwak/menoleh yang ditekan saat panel terbuka).
- **Guru harus terlihat "lewat":** Kyai/Ustadzah yang sedang duduk baca di kursinya tidak memicu hormat (ia tidak lewat — ia sedang mengajar/membaca). Pemicu hanya bila guru **bergerak** (patroli/jalan) — kecuali Sanusi/Fatimah yang diam: NPC yang berjalan melewati mereka dalam 4 m tetap varian A.

### 3.4 Antrean — salaman bergantian, tidak berebut

Satu guru hanya salaman dengan **satu NPC dalam satu waktu**. Keadaan guru dicatat di `main.gd` (`hormat_sedang`: NPC atau null; `hormat_antre`: antrean maks **3 NPC**):

1. NPC diam dalam radius 4 m, guru bebas → varian B (hampiri + salaman + cium tangan). Guru **berhenti berjalan** selama salaman (±4 detik) — Kyai/Ustadzah patroli dijeda, lalu lanjut.
2. NPC diam dalam radius 4 m, guru sedang salaman → varian A (minggir + nunduk) + **masuk antre** (bila antre < 3). Saat gilirannya tiba, ia menghampiri dari posisi minggirnya.
3. Antre penuh (3) → NPC hanya varian A, tidak masuk antre.
4. Guru berjalan menjauh (>6 m) sebelum giliran tiba → antrean dibubarkan, NPC kembali ke aktivitasnya.
5. NPC yang sedang salaman **tidak bisa ditanya** (tombol ✕/TANYA nonaktif selama ±4 detik) — sama seperti pemain yang sedang salaman tidak bisa bergerak.

### 3.5 Urutan gerakan tiap varian (spesifikasi pose)

Semua pose memakai rig yang sudah ada (`_rig`: `arm_l`/`arm_r`, `elbow_l`/`elbow_r`, `kepala` pivot, `_visual`). **Tidak ada pose yang sudah ada hari ini** kecuali salaman pemain — nunduk, tangan menyilang, dan cium tangan adalah pose baru. Nilai sudut di bawah adalah **nilai awal untuk tuning di foto**.

**Varian A — Minggir + nunduk menyilangkan tangan (±3 detik):**
1. Berhenti jalan. Geser **1,0 m tegak lurus jalur guru** — pilih sisi yang lebih jauh dari dinding terdekat (cek 2 titik kandidat terhadap daftar tapak bangunan; pilih yang bersih).
2. Hadap guru (`_visual.rotation.y` ke arah guru).
3. Nunduk: kepala pivot rotation.x **+0,45** (menunduk), badan `_visual.rotation.x` **+0,12** (membungkuk sedikit).
4. Tangan menyilang di depan dada: lengan kiri rotation.x −1,1 + rotation.z +0,6 (tangan ke dada kanan); lengan kanan cermin (rotation.x −1,1, rotation.z −0,6). Siku −0,4.
5. Tahan 3 detik (atau sampai guru lewat >4 m), lalu kembali ke aktivitas (kepala + badan + lengan lerp kembali, pola `delta * 8` seperti pose lain).

**Varian B — Hampiri + salaman + cium tangan (±4 detik + jalan):**
1. Bila duduk: **berdiri dulu** (pakaian kembali `PAKAIAN_DEFAULT`, ~0,5 detik — pola Kirana 19 Nov).
2. Jalan ke **1,0 m di depan guru**, hadap guru.
3. **Salaman (±2 detik):** tangan kanan terulur ke depan — pakai ulang nilai pose salaman pemain (`player.gd` "salaman", ~:1951): lengan kanan rotation.x ≈ −1,2, siku −0,4; goyangan kecil ±0,15 rad. Guru mengulurkan tangan kanan juga (guru dijeda dari patrolinya; tangan kanannya memakai pose yang sama).
4. **Cium tangan (±1,5 detik):** tangan kanan NPC (yang masih berjabat) terangkat ke mulut — lengan kanan rotation.x −1,9, siku −1,2; kepala nunduk +0,35. Lepas.
5. Mundur setengah langkah, kembali ke aktivitas (bila tadi duduk, kembali ke kursinya — kursinya masih ditandai miliknya selama ±10 detik, lihat 2.5).

**Varian A versi duduk (dalam ruangan):** hanya kepala nunduk +0,45 selama 2 detik, tanpa berdiri dan tanpa tangan menyilang (tangan tetap di kitab).

### 3.6 Yang TIDAK dilakukan hormat

- NPC tidak hormat ke **pemain** (pemain santri biasa). Bila pemain kelak menjadi pengurus/musyrif, aturan ini ditinjau ulang.
- NPC tidak hormat ke **sesama santri** (Bilal/Faris/NPC baru saling lewat tanpa hormat).
- NPC tidak hormat saat **membawa kitab sambil jalan**? — **Tetap hormat varian A** (kitab dipindah ke tangan kiri sejenak / diselipkan di lengan — tangan kanan menyilang; detail prop ditangani saat bangun).
- Tidak ada suara/ucapan khusus — NPC yang hormat tidak mengucapkan kalimat (feed melayang tetap diam) supaya tidak berisik saat kerumunan lewat.

---

## KEPUTUSAN YANG BUTUH MAS (jawab sebelum bangun)

1. **Pembagian 25 putra + 25 putri — ACC?** Atau jumlah lain (mis. 30+20)?
2. **Zona bersama selatan (taman/peti):** NPC putra/putri boleh masuk kawasan bersama, atau tetap di zona gender masing-masing?
3. **Hormat di dalam ruangan:** v1 luar ruangan saja + nunduk dari tempat duduk bila guru masuk ruangan — ACC?
4. **Satpam & Penjaga Pos Jaga:** tetap tidak menerima hormat (desain ini), atau mereka juga dihormati sebagai petugas?
5. **Bilal & Faris:** tetap santri biasa (tidak dihormati) — ACC?
6. **Bangun bertahap:** gelombang 1 = 20 NPC dulu, ukur di HP Mas, baru ke 50 — atau langsung 50 sekaligus?
7. **Kursi tambahan:** bila 13 kursi luar ruangan dirasa kurang, tambah bangku di halaman Surau/Musholla (2 bangku per sisi) — atau cukup yang ada?
8. **Nama di atas kepala:** 50 nama tampil seperti sekarang (<28 m) — atau hanya tampil bila dekat (<15 m) supaya layar lebih bersih?

---

## LAMPIRAN — YANG AKAN DISENTUH SAAT BANGUN (SETELAH ACC + SETELAH DEPLOY RONDE INI)

- `scripts/npc.gd`: mode aktivitas (`_aktivitas`, state JALAN/DUDUK_KURSI/BACA_MUSHOLLA/BACA_KAMAR/JALAN_KITAB), pose `DUDUK_KURSI` + `BACA`, pose hormat (nunduk, tangan menyilang, salaman NPC, cium tangan), `_kitab_pangku` terlihat saat baca.
- `scripts/player.gd`: kunci outfit baru (jarak/ukuran mata, alis, hidung, senyum, rambut, tinggi) di `build_visual()` — semua opsional + default = tampilan sekarang.
- `scripts/mission_data.gd`: pool nama `NPC_NAMA_PUTRA` / `NPC_NAMA_PUTRI` (30+30), konstanta Tier H.
- `scripts/main.gd`: `_spawn_npcs()` (spawn 50 + registry kursi + registry hormat/antre), validasi segmen waypoint vs tapak bangunan, kapasitas sajadah saat sholat.
- `scripts/pesantren_builder.gd` + `scripts/kampus_putri.gd`: daftar tapak bangunan (untuk validasi segmen) + koordinat kursi/bangku (registry).
- `skrip/test_npc_50.gd` (baru): spawn 50 tanpa error, nama unik, waypoint bersih dari tapak, kursi tidak bentrok, hormat varian A/B + antre, performa (segitiga/draw call sesudah).
- Visual konsep: `v2/konsep/konsep-npc-50-zona-v1.png`, `konsep-npc-wajah-v1.png`, `konsep-npc-hormat-v1.png`.

**Yang SENGAJA tidak masuk desain ini:** perbaikan songkok/peci hitam (Kirana, item 2); perbaikan tembusan tembok (Raka, item 4); debounce tombol (Tara, 14:02 — diputuskan Xam, ikut deploy ronde ini); layar Pengaturan penuh (Rangga — panel kualitas saja dulu).
