# ROADMAP MAPS — Pesantren Universe

**Tim Maps (ketua: Gilang) — dokumen rencana, 15 Nov 2026.**
Rencana saja: JANGAN ubah kode dari dokumen ini. Implementasi per fase dikerjakan
Raka (integrator) di ronde-ronde berikutnya, setelah Mas ACC fase-nya.
Angka koordinat memakai sistem game: **x+ = timur, z+ = selatan, utara = −z**,
pusat (0,0) = halaman tengah pesantren. Spawn pemain di (0, 0, 14) —
**revisi 16 Nov: spawn menurut gender, putra (−4, 0, 14), putri (4, 0, 14)**.

**Revisi 16 Nov 2026:** (1) pesantren putri = **satu dunia, dua area terpisah**
(keputusan Mas ~08:38 WIB) — detail di §2, §3, §4 (Fase A-P baru + Fase B/C/C-P/
D/F/G/H direvisi), §7; (2) desain asrama baru: **1 santri = 1 kasur** (kasur
susun diizinkan), **tiap kamar ada AC + rak kitab** (keputusan Mas ~08:37 WIB) —
detail di §4 Fase C/C-P. Rak kitab = tempat materi/kitab (kitab interaktif
Fase 2, buka kitab → baca isinya).

**Revisi 16 Nov 2026 ~08:44 WIB:** (3) pemicu bangun Asrama berubah:
**cangkruk penuh → langsung bangun kompleks asrama 3 lantai** (keputusan Mas)
— detail di §2 butir 7, §4 Fase C/C-P, §7 butir 6; (4) **aturan privasi
kamar: santri tidak bisa masuk kamar santri lain** (keputusan Mas) — detail
di §4 Fase C.

**Revisi 16 Nov 2026 ~15:50 WIB:** (5) putri mendapat **Musholla Ar-Raudhah
(مصلى الروضة) TERPISAH** di area putri (18,−24), dipimpin **Ustadzah
Mariyah** — rencana partisi Surau DIBATALKAN (keputusan Mas); (6) batas
putra/putri berupa **pagar fisik + gerbang (0,0) + pos satpam (3,3)** di
garis x=0; (7) **Keamanan = fungsi umum pesantren** (bukan per asrama) —
**4 pos jaga di sudut kampus inti** (±40,−35) + (±40,80) — detail di §2
butir 2/3/4/8, §3, §4 Fase A-P, §7 butir 7/9/14/15/16.

**Revisi 16 Nov 2026 ~19:42 WIB (KEPUTUSAN MAS — "agak jauh ya, jangan
berdekatan"):** (8) **pondok putri TERLALU DEKAT — zona putri pindah
lebih jauh ke timur** (USULAN, butuh ACC Mas — JANGAN bangun di game
dulu): Musholla Ar-Raudhah (18,−24) → **(62,−24)**; pagar + gerbang
TETAP di x=0 dengan **zona penyangga (kebun/taman) x 0..50** di
antaranya; semua plot putri ikut geser timur (Kelas Putri (58,0),
Asrama Putri (80,0), Kantor Ustadzah (78,−28), Madrasah (80,−12),
Studio (94,−12), Lapangan Putri (48,62)); spawn putri (4,14) →
(58,14); pos jaga Timur Laut (40,−35) → (88,−35). Detail + tabel jarak
di §2 butir 2/3/8, §3, §4 Fase A-P/B/C-P/D/G, §7 butir 17.

**Revisi 16 Nov 2026 ~21:49 WIB (KEPUTUSAN MAS — "Ok acc desainnya.. tapi untuk letak bangunan harus sesuai maps ini.. ini jaraknya kalau bisa lebih jauh antara pondok putra dan putri. Terus butuh tembok pemisah.. ini santri putra masih bisa masuk pondok putri.."):** (9) desain arsitektur Surau + Musholla **DI-ACC Mas** (Arsa, 16 Nov ~21:45 WIB); (10) **jarak putra–putri LEBIH JAUH lagi** (USULAN, butuh ACC Mas — JANGAN bangun dulu): Musholla (62,−24) → **(134,−24)** (Opsi A, Terjauh) atau **(98,−24)** (Opsi B, Timur-Jauh); (11) **pagar DIGANTI TEMBOK PEMISAH solid** (tertutup, tinggi 3 m) di garis lurus **x=14** — pagar x=0/x=2.5 + gerbang (2.5,0) + pos satpam (5.5,5) DIBONGKAR; gerbang pindah ke (14,0), pos satpam ke (17,5) — **soal pagar x=0 vs x=2.5 TERJAWAB: tidak ada pagar lagi**; (12) **aturan zona jadi KERAS** (`_cek_batas`: santri yang masuk area lawan didorong balik + toast) — menutup jalan memutar lewat ujung tembok (celah yang Mas temukan: pagar hanya z −60..+16, santri bisa memutar lewat utara/selatan); (13) **deploy jalan + lampu DITAHAN** sampai peta revisi ini di-ACC Mas (pck jalan+lampu berisi pagar x=2.5 — digantikan export Ronde 21); (14) Surau baru (desain ACC) sedang dibangun Raka di (0,−12) — BUKAN bagian Ronde 21; perbaikan figur Ustadzah (Kirana, selesai) ikut export gabungan. Detail + tabel jarak di §2 butir 2/3/8, §3, §4 Fase A-P/B/C-P/D/G, §7 butir 7/14/15/17.

**Revisi 17 Nov 2026 ~06:02 WIB (PERINTAH MAS — "Pagar tembok pondok putri mengelilingi pondok"):** (15) **Opsi A DIPILIH Mas 16 Nov 22:03 WIB dan sudah DIBANGUN Ronde 21 — LIVE (deployment 1e73fc16, 17 Nov ~06:03 WIB)**; §7 butir 17 (pilih A/B) DITUTUP. (16) **tembok keliling TAMBAHAN mengelilingi kampus putri Opsi A** (bukan cuma tembok x=14): persegi **x 115..180, z −52..+22** (65 × 74 m; barat 8 m dari Cangkruk, timur 9 m dari Studio, utara 8 m dari spawn, selatan 15,5 m dari Pos Jaga TL); **gerbang barat (115,0)** segaris gerbang (14,0) + **jalan akses** jalan E-W dari (14,0) menembus penyangga + **jalan masuk** (115,0)→(115,8)→(142,8) (Kelas Putri menghalangi jalan lurus z=0); pagar kayu taman Musholla TETAP di dalam keliling; **reserve Masjid Putri (134,−40) di dalam keliling** (alasan tembok selatan z=−52). Desain dulu di peta miniatur untuk review Mas; Raka bangun di **Ronde 22** setelah ACC. Detail di Perubahan 17 Nov, §3, §7 butir 18, §8.

---

## 1. Kondisi sekarang (Fase 0 — sudah dibangun, ronde 5 live)

| Item | Angka terukur (dari kode) |
|---|---|
| Tanah | 800×800 m (`MAP_HALF` 400), **tanpa pagar luar**, tanpa respawn limit |
| Surau Kecil | 12×10×4,2 m di (0, −12), pintu selatan z=−7, kubah emas + menara kecil |
| Interior Surau | Map terpisah 18×14 m di z=−301 (ala GTA): smartboard, mihrab, 15 sajadah (3×5), 2 rak kitab, 3 meja sampar, 4 lampu hangat |
| Kamar Cangkruk | Kayu, di sebelah Surau — **ronde 6 (Raka, sedang dikerjakan)**: tempat tidur + ganti baju |
| 4 plot terkunci | Ruang Kelas 25 di (16, 0) timur; Asrama 50 di (−16, 0) barat; Masjid Besar 100 di (0, −26) utara; Perpustakaan & Taman 200 di (0, 20) selatan. Plot 10×8 m, papan tanda 2 sisi. **Pagar plot DIHAPUS di ronde 6** (Mas: lahan tanpa pagar). **Revisi 16 Nov ~08:44: pemicu Asrama berubah (cangkruk penuh → bangun kompleks 3 lantai) — angka "50" di papan tanda asrama sudah tidak berlaku, diperbarui saat ronde Asrama (lihat Fase C).** |
| Gunung | Ronde 5: 10 gunung (jarak 330–370 m, tinggi 60–95 m, 4 bersalju). **Ronde 6: tinggal 1–2** (Mas) — usulan Tim Maps: pertahankan 2 sebagai latar utara, sudut ~15° (jarak 350 m, tinggi 70 m) dan ~335° (jarak 365 m, tinggi 75 m); Raka yang finalisasi |
| Sawah | 60×40 m di (60, 30) tenggara: 4×3 petak berair + 24 rumpun padi + gubuk kayu |
| Pohon / semak / batu | 61 pohon (3 mesh/pohon), 6 semak, 4 batu — tersebar sampai radius ~210 m |
| Jalan | N–S x=0 (z −200..+200); E–W z=0 (x −160..+160); jalan ke sawah z=30 (x 0..32); jalan ke tiap plot |
| Lampu | 8 lampu jalan + 1 omni Surau (tanpa bayangan) + 1 DirectionalLight matahari/bulan |
| Peti Kayu (M3) | di (6, 10). Papan selamat datang di (3,5, 13) |
| Langit | Dinamis 5 fase (Subuh/Pagi/Siang/Sore/Malam), kabut MATI |
| Peta | Minimap live heading-up 190×190 + peta penuh zoom 1.0x/4.0x. Marker: Surau, 4 lahan, peti, NPC, sawah, gunung, tujuan misi |
| NPC | Bilal + Faris, waypoint sampai radius ~130 m (sawah + kaki gunung) |
| Kecepatan jalan | 6,0 m/s → pusat ke tepi tanah (400 m) ≈ 67 detik jalan lurus; ke kaki gunung ≈ 55 detik |
| Performa sekarang | pck 158 KB; wasm 39,5 MB (engine, tetap); semua primitif low-poly tanpa tekstur; kamera fov 60, far plane default Godot 4 |

**Asumsi roadmap ini:** Surau hanya 1 (bug double Surau diperbaiki Raka di ronde 6),
dan semua bangunan yang bisa dimasuki memakai pola interior terpisah (ala GTA,
seperti Surau) supaya peta utama tetap ringan.

---

## 2. Prinsip layout (berlaku semua fase)

1. **Kampus inti kompak.** Semua bangunan utama dalam radius ~60 m dari Surau,
   supaya santri baru tidak jauh jalan. Yang jauh hanya kawasan alam (sawah,
   kebun, gunung).
2. **Kiblat = utara.** Mihrab Surau di dinding utara interior; Masjid Besar di
   utara Surau (plot (0, −26)). Bangunan ibadah selalu di sisi utara.
   **Revisi 16 Nov ~15:50 WIB (KEPUTUSAN MAS): Surau TIDAK dipartisi — Surau
   utuh untuk putra; putri mendapat Musholla Ar-Raudhah sendiri dengan
   mihrab sendiri** (lihat §4 Fase A-P; dinding mihrab menunggu konfirmasi
   Mas — Raka Ronde 20 memasang di dinding barat, flag 1 di
   RONDE20-STATUS.md). **Revisi 16 Nov ~19:42 WIB (KEPUTUSAN MAS —
   pondok putri terlalu dekat): Musholla Ar-Raudhah (18,−24) → (62,−24)
   (USULAN, butuh ACC Mas). Prinsip baru: jarak dinding-ke-dinding antar
   bangunan putra/putri ≥ 50 m** — Surau → Musholla baru 63 m
   (pusat-ke-pusat) / 51 m (dinding-ke-dinding), dulu 22 m / 7 m. **Revisi 21:49 WIB:** rencana 19:42 (62,−24) DIBATALKAN — Opsi A (134,−24): 134,5 m pusat / 118 m dinding; Opsi B (98,−24): 98,7 m / 82 m. Prinsip jarak: dinding-ke-dinding antar bangunan putra/putri ≥ 80 m (B), target 118 m (A).
   Masjid Besar tetap rencana dua sisi terpisah (partisi — Fase D) sampai
   Mas memutuskan apakah masjid juga dipisah penuh (lihat §7 butir 7 —
   jarak putri ke masjid kini ikut jadi pertimbangan). **Revisi 21:49 WIB:** partisi DIBATALKAN (tembok x=14 tidak memotong plot masjid) — masjid utuh putra; Masjid Putri terpisah (kandidat A (134,−40), B (98,−40)).
3. **Zonasi tetap (revisi 16 Nov — dua area; revisi 19:42 WIB — jarak):**
   **barat (x<0) = Area Putra; timur (x>0) = Area Putri** — dipisah
   **pagar fisik + gerbang di garis x=0** (keputusan Mas 16 Nov ~15:50 WIB
   — lihat butir 8). **Pagar TETAP di x=0** (revisi 19:42 WIB, USULAN);
   yang pindah adalah **kawasan TERBANGUN putri: mulai x≈51** — di
   antaranya **zona penyangga x 0..50: kebun/taman + pohon, tanpa bangunan
   hunian/belajar/ibadah** (pemisah hijau yang terlihat, seperti jeda lahan
   antar kompleks di pesantren sungguhan). Utara = ibadah (Surau putra +
   Musholla Ar-Raudhah putri + Masjid Besar); barat = hunian + belajar
   putra; timur (x≥51) = hunian + belajar putri; selatan = **kawasan
   bersama** (Perpustakaan & Taman, Kantin, Aula, Gerbang — tanpa hunian,
   terbuka untuk keduanya); tenggara = pertanian bersama (sawah/kebun/kolam).
   Pemisahan berlaku untuk asrama + musholla + kelas; kawasan bersama
   selatan terbuka untuk keduanya. **Revisi 21:49 WIB:** pagar DIGANTI tembok solid x=14 (gerbang (14,0)); Area Putra = x<14, Area Putri = x≥124 [A] / x≥88 [B]; zona penyangga x 14..124 [A] / x 14..88 [B].
4. **Tanpa pagar luar — selamanya.** Keputusan Mas (ronde 5): dunia tanpa batas.
   Gerbang Utama nanti hanya penanda, bukan pembatas; tidak ada pagar keliling.
   **Pagar baru (keputusan Mas 16 Nov ~15:50 WIB) adalah pagar DALAM —
   pemisah area putra/putri di garis x=0 — bukan pagar luar.**
5. **Jalan utama tidak pernah ditutup.** Jalan N–S (x=0) dan E–W (z=0) adalah
   tulang punggung; bangunan baru tidak boleh memotongnya. Jalan baru berupa
   cabang dari jalan utama.
6. **Interior terpisah untuk bangunan yang dimasuki.** Eksterior di peta utama
   hanya cangkang + pintu teleport (pola Surau). Interior dimuat hanya saat
   masuk — ini yang menjaga HP tetap lancar.
7. **Ambang 25/100/200 TETAP, tidak di-vote.** Sudah disetujui Mas 15 Nov
   ~11:37 WIB. Voting santri berlaku mulai ambang 300 (lihat §4).
   **Revisi 16 Nov (USULAN, butuh ACC Mas):** ambang bangunan **per area
   dihitung per jenis kelamin** — Kelas 25 santriwan → Ruang Kelas Putra,
   25 santriwati → Ruang Kelas Putri. Bangunan **bersama** dihitung dari
   total santri (Masjid Besar 100 total, Perpustakaan & Taman 200 total).
   **Revisi 16 Nov ~08:44 (KEPUTUSAN MAS): Asrama TIDAK lagi menunggu
   ambang 50** — begitu **Cangkruk penuh, langsung dibangun kompleks
   asrama 3 lantai** (L1 = Asrama A, L2 = B, L3 = C; lantai terisi
   mengikuti jumlah santri). Aturan 1 santri = 1 kasur terpenuhi tanpa
   celah: tidak ada lagi santri tanpa kasur. Definisi "penuh" (keputusan
   Mas 16 Nov ~08:46 WIB): **10 kasur — 5 kasur susun**; begitu 10 kasur
   terisi → langsung bangun kompleks asrama 3 lantai.
8. **Satu dunia, dua area (keputusan Mas 16 Nov ~08:38 WIB; pagar +
   gerbang + satpam 16 Nov ~15:50 WIB).** Putra dan putri di area berbeda
   dalam dunia yang sama, **tidak saling masuk**. Pemisah: **pagar fisik di
   garis x=0** (z −60..+16, ujung utara kawasan bersama) + **gerbang di
   (0, 0)** (persimpangan jalan N–S dan E–W — satu-satunya titik lintas) +
   **pos satpam di (3, 3)** di luar gerbang (sisi plaza, menghadap gerbang)
   + pembatas tak terlihat di garis batas. **Surau utuh di area putra**
   (pagar membelok mengikuti dinding timur Surau, x=6, z −17..−7 — Surau
   TIDAK dipartisi); **putri punya Musholla Ar-Raudhah sendiri di (18,
   −24), dipimpin Ustadzah Mariyah**. **Aturan zona (game):** santri putra
   tidak boleh berada di x>0 & z<+16; santriwati tidak boleh di x<0 &
   z<+16 — pagar adalah perwujudan fisiknya; di luar rentang pagar, aturan
   zona yang menegakkan (Raka yang tentukan mekanismenya: dinding tak
   terlihat / peringatan / teleport balik). **Pengasuh + musyrif/musyrifah
   boleh lintas** (pengawasan) — santri tidak. Asrama + kelas + musholla
   diduplikasi per area. Kawasan selatan (Perpustakaan, Gerbang, Aula,
   Kantin, z>+16) + pertanian tenggara = kawasan bersama (tanpa hunian,
   tanpa pagar). **Keamanan = fungsi umum pesantren (bukan per asrama)** —
   pengurus Keamanan piket di 4 pos jaga sudut kampus inti (±40, −35) +
   (±40, 80) + membantu satpam di gerbang (lihat Fase A-P).
   **Revisi 16 Nov ~19:42 WIB (KEPUTUSAN MAS — pondok putri terlalu dekat;
   USULAN, butuh ACC Mas): pagar + gerbang TETAP di x=0** — yang pindah
   hanya kawasan terbangun putri (ke timur, mulai x≈51) + zona penyangga
   kebun/taman x 0..50. Alasan: (a) pagar/gerbang/pos satpam baru saja
   dibangun Ronde 20 — memindahnya = bangun ulang 1 ronde + deploy
   sia-sia; (b) yang Mas minta jauh adalah ANTAR BANGUNAN, dan itu
   tercapai tanpa menggeser pagar (Surau → Musholla 51 m
   dinding-ke-dinding); (c) aturan zona (game) TIDAK berubah (putra
   dilarang x>0 & z<+16 — penyangga ikut terlarang, jadi tidak ada jalan
   pintas lewat kebun); (d) rute satpam + patroli tidak berubah (gerbang
   tetap satu-satunya titik lintas). Alternatif yang DITOLAK: pagar
   pindah ke x=45 — untungnya hanya lahan putra bertambah ±45 m,
   biayanya: pagar/gerbang/pos satpam dibangun ulang + spawn putri
   pindah + konstanta zona di kode berubah + pos jaga geser. **Pos jaga
   Timur Laut (40,−35) → (88,−35)** (tetap jadi sudut kampus inti yang
   kini membentang sampai x≈95); 3 pos lain tetap. **Spawn putri
   (4,14) → (58,14)** (masuk kampus putri, di depan Kelas Putri, di
   jalan E–W). **Revisi 21:49 WIB:** pagar DIGANTI tembok x=14 + gerbang (14,0) + pos satpam (17,5); kampus putri pindah ke (134,−24) [A] / (98,−24) [B]; spawn putri → (130,14) [A] / (94,14) [B]; pos TL → (160,−35) [A] / (124,−35) [B]; aturan zona jadi KERAS.

---

## 3. Peta kasar (denah, bukan skala)

```
        UTARA (−z) — kiblat
                        [Gunung]  [Gunung]
   Pos Jaga BL      Masjid Besar (utuh putra)    Pos Jaga TL
   (−40,−35)             (0,−26)                  (160,−35) [A]
   Kantor Pengasuh  [ZONA PENYANGGA: kebun/taman  Kantor Ustadzah
     (−36,−28)        x 14..124, tanpa bangunan]   (150,−28) [A]
   R. Kelas Putra    Surau (putra)  Musholla Ar-Raudhah  Madrasah
     (−24,−20)             (0,−12)       (134,−24) [A]   (152,−12) [A]
   Asrama Putra    [halaman tengah]    Kelas Putri  Asrama Putri
   (−16,0)      spawn P (−4,14) | spawn W (130,14) [A]  (130,0) (152,0) [A]
   Cangkruk Putra    TEMBOK x=14 + Gerbang (14,0)  Cangkruk Putri
   (−12,−12)      + Pos Satpam (17,5)      (128,−12) [A]
                Perpustakaan & Taman (0,20)  Studio (166,−12) [A]
   Kantin (bersama) (0,40)
   Lapangan Putra (−30,50)   Aula (bersama) (0,52)   Lapangan Putri (48,62)
   Pos Jaga BD      Gerbang Utama (0,80)   Pos Jaga TG   Sawah (60,30)
   (−40,80)                                 (40,80)
        SELATAN (+z)        Kebun (100,30) + Kolam (100,60)
   BARAT (x<14) = AREA PUTRA  |  TIMUR (x≥124) = AREA PUTRI [A]
                garis batas: TEMBOK x=14 (z −60..+16) + gerbang (14,0)
                zona penyangga: kebun/taman x 14..124 (tanpa bangunan)
   Peti Kayu (0,26) kawasan bersama; papan selamat datang (0,18)
   [A] = Opsi A Terjauh (default). Opsi B Timur-Jauh: Musholla (98,−24),
   Cangkruk Putri (92,−12), Kelas Putri (94,0), Asrama Putri (116,0),
   Kantor Ustadzah (114,−28), Madrasah (116,−12), Studio (130,−12),
   spawn putri (94,14), Pos Jaga TL (124,−35), jalan internal x=106,
   penyangga x 14..88. Masjid Putri (kandidat Fase D): A (134,−40), B (98,−40).
```

**Catatan denah (revisi 16 Nov ~21:49 WIB — tembok + jarak lebih jauh, USULAN, butuh ACC Mas):** garis batas = **TEMBOK solid x=14 (z −60..+16)** + gerbang (14,0) + pos satpam (17,5) — **pagar x=0/x=2.5 DIBONGKAR, diganti tembok** (belokan pagar lama x=9 tidak bisa dipakai: Surau baru menjorok sampai x≈12,4). Barat (x<14) = Area Putra, timur (x≥124 [A] / x≥88 [B]) = Area Putri; di antaranya **zona penyangga x 14..124 [A] (kebun/taman + pohon, tanpa bangunan)**. **Surau (0,−12) utuh di area putra** (desain baru ACC — kubah zamrud + menara, sedang dibangun Raka); **Musholla Ar-Raudhah (134,−24) [A] / (98,−24) [B]** di kampus putri, dipimpin Ustadzah Mariyah (lokasi lama (18,−24) + rencana 19:42 (62,−24) DIBATALKAN — terlalu dekat Surau). Masjid Besar (0,−26) **utuh putra** (tembok lewat 4 m di timurnya) — **rencana partisi masjid DIBATALKAN**, putri mendapat Masjid Putri terpisah (kandidat Fase D: A (134,−40), B (98,−40)). Perpustakaan & Taman (0,20), Kantin (0,40), Aula (0,52), Gerbang (0,80) di sumbu selatan = kawasan bersama (z>+16, tanpa tembok). Sawah/kebun/kolam tenggara = pertanian bersama. **4 pos jaga keamanan:** Barat Laut (−40,−35), **Timur Laut (160,−35) [A] / (124,−35) [B]** (dulu (40,−35), rencana 19:42 (88,−35)), Barat Daya (−40,80), Tenggara (40,80); pos satpam gerbang di (17,5). Plot lama putri — Musholla (18,−24), Kelas Putri (16,0), Cangkruk Putri (12,−12) — kembali jadi lahan penyangga (kebun).

---

## 4. Fase-fase

### Fase A — 0–25 santri: Surau Kecil (SELESAI, sudah live)

- Bangunan: Surau Kecil + interiornya, Kamar Cangkruk (ronde 6), peti kayu,
  papan selamat datang, 8 lampu jalan.
- Jalan: N–S + E–W + jalan ke sawah + jalan ke 4 plot.
- Peta: marker Surau, 4 lahan terkunci, peti, sawah, gunung.
- Performa: kondisi sekarang (§1). Tidak ada yang diubah di fase ini.

### Fase A-P — Pembukaan Area Putri (saat santriwati pertama — DITULIS ULANG, revisi 16 Nov ~15:50 WIB)

**KEPUTUSAN MAS 16 Nov ~15:50 WIB: putri mendapat MUSHOLLA SENDIRI —
Musholla Ar-Raudhah (مصلى الروضة) — di area putri, BUKAN partisi Surau.**
Rencana lama (partisi Surau: dinding + tirai di x=0, pintu timur, sajadah +
smartboard sisi putri, satu mihrab) **DIBATALKAN TOTAL**. Surau tetap utuh
untuk putra.

Area putri dibuka begitu santriwati pertama terdaftar (USULAN: buka langsung
saat santriwati pertama, atau tunggu 5 santriwati — butuh keputusan Mas).
Yang dikerjakan Raka dalam 1 ronde saat area putri dibuka:

- **Musholla Ar-Raudhah (مصلى الروضة) di (62, −24), area putri — REVISI
  19:42 WIB (USULAN, butuh ACC Mas; lokasi lama (18,−24) DIBATALKAN
  karena terlalu dekat Surau — 22 m pusat-ke-pusat, 7 m
  dinding-ke-dinding):** eksterior 10×8 m (kubah kecil + menara kecil,
  serasi Surau, warna zamrud/putih + aksen emas). Interior terpisah
  14×10 m: 15 sajadah (3×5), **mihrab sendiri** (dinding mihrab menunggu
  konfirmasi Mas — Raka Ronde 20 memasang di barat), smartboard (M2
  putri di sini — bukan di Surau), 1 rak kitab, 1 meja sampar, 2 lampu
  hangat. Pintu selatan (z=−20). **Dipimpin Ustadzah Mariyah** (keputusan
  Mas 16 Nov ~15:50 WIB — menjawab §7 butir 9). **Jarak baru (terukur):
  Surau → Musholla 63 m pusat-ke-pusat / 51 m dinding-ke-dinding;
  gerbang → Musholla 67 m (≈11 detik jalan).** Lokasi lama (18,−24) +
  cabang jalan x=18 kembali jadi lahan penyangga (kebun). **Revisi 21:49 WIB:** lokasi (62,−24) DIBATALKAN — Musholla baru di (134,−24) [A] / (98,−24) [B] (desain ACC); cabang jalan x=70 ikut dibatalkan, diganti jalan internal x=142 [A] / x=106 [B].
- **Pagar + gerbang + satpam — TETAP di x=0 (sudah dibangun Ronde 20;
  revisi 19:42 WIB: TIDAK ikut pindah — lihat §2 butir 8):** pagar fisik
  (kayu/bambu + gapura penanda) mengikuti garis x=0 dari z=−60 sampai
  z=+16 (ujung utara kawasan bersama); **gerbang di (0, 0)** — persimpangan
  jalan N–S dan E–W, bukaan 4 m + 2 pilar + gapura, satu-satunya titik
  lintas; **pos satpam 3×3 m di (3, 3)** di luar gerbang (sisi plaza,
  menghadap gerbang) + satpam NPC penjaga gerbang (dibangun Raka — NPC-nya
  boleh menyusul ronde berikutnya bila ronde ini kepenuhan).
  **Pengecualian pagar:** di sekitar Surau pagar membelok mengikuti
  dinding timur Surau (x=6, z −17..−7) supaya Surau utuh di area putra;
  di Masjid Besar pagar bertemu dinding selatan/utara masjid di x=0
  (partisi dalam masjid melanjutkan pemisah — lihat Fase D). **Zona
  penyangga (BARU, revisi 19:42 WIB):** lahan x 0..50, z −60..+16 di
  timur pagar = **kebun/taman + pohon, tanpa bangunan** — pemisah hijau
  antara pagar dan kampus putri (x≥51). Aturan zona TIDAK berubah: santri
  putra tetap dilarang x>0 & z<+16, jadi penyangga tidak bisa jadi jalan
  pintas. Pohon yang sudah ada di penyangga (mis. (22,6), (28,8),
  (52,−26)) dibiarkan sebagai pohon kebun. **Aturan zona (game):** santri
  putra tidak boleh di x>0 & z<+16; santriwati tidak boleh di x<0 &
  z<+16 (Raka yang tentukan mekanisme penegakan: dinding tak terlihat /
  peringatan / teleport balik); Pengasuh + musyrif/musyrifah boleh lintas
  (pengawasan). **Revisi 21:49 WIB:** pagar DIBONGKAR, diganti **tembok solid x=14** (gerbang (14,0), pos satpam (17,5)); zona penyangga x 14..124 [A] / x 14..88 [B]; aturan zona jadi KERAS (santri di area lawan didorong balik + toast); putra dilarang x>14 & z<16, santriwati dilarang x<14 & z<16.
- **4 pos jaga keamanan (umum — bukan per asrama):** 3×3 m + 1 lampu tiap
  pos, di sudut kampus inti: Barat Laut (−40,−35), **Timur Laut (88,−35)
  (revisi 19:42 WIB — dulu (40,−35); kampus inti kini membentang sampai
  x≈95)**, Barat Daya (−40,80), Tenggara (40,80). Tempat piket pengurus
  Keamanan (sistem lamaran) + patroli kampus. **Keamanan = fungsi umum
  pesantren** (keputusan Mas 16 Nov ~15:50 WIB; desain lamaran sudah ACC
  15:55 WIB dengan Keamanan umum).
- **Cangkruk pindah:** Cangkruk lama (14,−14) dipindah ke barat (−12,−12)
  jadi Cangkruk Putra (sudah dibangun Ronde 20); Cangkruk Putri dibangun
  di **(56,−12)** (revisi 19:42 WIB — lokasi lama (12,−12) DIBATALKAN,
  terlalu dekat Cangkruk Putra: 24 m → 68 m). Cermin, kayu, 5 kasur dulu
  seperti putra.
- **Peti + papan pindah ke kawasan bersama:** Peti Kayu (M3) dari (6,10) →
  (0,26) di depan Perpustakaan & Taman; papan selamat datang dari (3,5,13)
  → **(0,18)** (digeser dari (0,16) supaya tidak menempel ujung pagar
  z=+16). Keduanya di sumbu selatan, terjangkau kedua area.
- **Jalan (REVISI 19:42 WIB):** cabang dari jalan E–W timur di **x=70**
  ke utara sampai (70,−20), lalu setapak ke pintu selatan Musholla
  Ar-Raudhah (62,−20). Cabang lama x=18 DIBATALKAN (ikut lokasi lama
  musholla). Jalan internal kampus putri: lajur N–S x=70 melayani
  Musholla + Madrasah + Asrama Putri dari jalan E–W. Lahan plot Kelas
  Putri (58,0) masih kosong saat Fase A-P — ketika Kelas Putri dibangun
  (Fase B), tidak perlu geser jalur (kelas di barat jalan internal).
- **Peta:** marker "MUSHOLLA AR-RAUDHAH" + "AREA PUTRI" + garis pagar +
  gerbang + 5 pos (satpam + 4 pos jaga) di peta besar; minimap menampilkan
  pagar batas. **Spawn putri (4,14) → (58,14)** (revisi 19:42 WIB —
  spawn putri masuk kampus putri, di depan Kelas Putri, di jalan E–W).
- **NPC:** Bilal + Faris tetap di area putra; NPC santriwati pertama
  (Tim Karakter) spawn di area putri saat area dibuka; satpam NPC di pos
  (3,3) — boleh menyusul ronde berikutnya.
- Anggaran: musholla eksterior ≤ 30 mesh, interior ≤ 60 mesh; pagar
  ≈ 25 mesh; gerbang + pos satpam ≈ 15 mesh; 4 pos jaga ≈ 30 mesh
  (total paket pemisah + keamanan ≈ 70 mesh eksterior + 60 interior).
- **Belum diputuskan (tanya Mas):** ambang buka area (santriwati pertama
  atau 5?); apakah Masjid Besar tetap partisi atau dipisah penuh seperti
  musholla (§7 butir 7); siapa boleh lintas gerbang selain Pengasuh +
  musyrif (§7 butir 15); apakah kawasan selatan tetap bersama atau ikut
  dipisah; **lokasi baru pondok putri + pagar tetap x=0 + zona penyangga
  (§7 butir 17 — USULAN revisi 19:42 WIB, butuh ACC sebelum Raka pindah
  apa pun di game).**

### Perubahan — revisi 16 Nov ~19:42 WIB (pondok putri lebih jauh — USULAN, butuh ACC Mas)

**Keputusan Mas (16 Nov ~19:42 WIB): "Lokasi pondok putri agak jauh ya...
jgn berdekatan."** Musholla Ar-Raudhah (18,−24) hanya 22 m dari Surau
(0,−12) — 7 m dinding-ke-dinding, langsung di seberang pagar x=0.
Revisi ini memindah SELURUH kawasan terbangun putri ke timur (mulai
x≈51) dan menyisakan zona penyangga hijau di antaranya. Pagar +
gerbang + pos satpam TIDAK pindah (sudah dibangun Ronde 20).

**Tabel jarak (terukur, pusat-ke-pusat; kecepatan jalan 6 m/s):**

| Pasangan | Lama | Baru (usulan utama) | Alternatif (timur-jauh) |
|---|---|---|---|
| Surau → Musholla | 21,6 m | **63,2 m** | 98,7 m |
| Surau → Musholla (dinding-ke-dinding) | 7 m | **51 m** | 87 m |
| Gerbang → Musholla | 30 m (≈5 dtk) | **66,5 m (≈11 dtk)** | 100,9 m (≈17 dtk) |
| Cangkruk Putra → Cangkruk Putri | 24 m | **68 m** | 104 m |
| Asrama Putra → Asrama Putri | 46 m | **96 m** | 132 m |
| Kelas Putra → Kelas Putri | 44,7 m | **84,4 m** | 119,7 m |
| Kantor Pengasuh → Kantor Ustadzah | 66 m | **114 m** | 150 m |
| Lapangan Putra → Lapangan Putri | 60 m | **78,9 m** | 78,9 m (tetap) |

**Koordinat baru (usulan utama — kampus putri x≈51..99, pusat ±66 m):**
Musholla Ar-Raudhah (62,−24); Cangkruk Putri (56,−12); Kelas Putri
(58,0); Asrama Putri (80,0); Kantor Ustadzah (78,−28); Madrasah
(80,−12); Studio (94,−12); Lapangan Putri (48,62); spawn putri
(58,14); pos jaga Timur Laut (88,−35). Jalan internal N–S x=70 dari
jalan E–W ke pintu Musholla. Jarak internal kampus putri tetap pendek:
spawn putri → Musholla 38 m (≈6 dtk); Kantor Ustadzah → Musholla
17 m (≈3 dtk). **Dicek terhadap pohon/sawah yang sudah ada: tidak ada
pohon di dalam footprint bangunan baru (margin 1,5 m) dan tidak ada
bangunan baru yang menabrak sawah (x 30..90, z 10..50).**

**Alternatif (kampus timur-jauh, pusat ±100 m):** semua koordinat di
atas +36 m ke timur — Musholla (98,−24), Cangkruk Putri (92,−12),
Kelas Putri (94,0), Asrama Putri (116,0), Kantor Ustadzah (114,−28),
Madrasah (116,−12), Studio (130,−12), spawn putri (94,14), pos jaga
Timur Laut (124,−35); Lapangan Putri tetap (48,62). Jarak Surau →
Musholla 98,7 m (≈16 dtk jalan), gerbang → Musholla 100,9 m (≈17 dtk).
**Kelemahan alternatif:** kampus makin menyebar (jalan kaki harian
santriwati + Pengasuh makin jauh, putaran patroli Keamanan memanjang),
makin jauh dari kawasan bersama selatan, dan mendekati sabuk pohon
timur. **Rekomendasi Tim Maps: usulan utama (x≈62)** — pemisahan sudah
3× lipat dari sekarang dengan jalan kaki tetap ±11 detik dari gerbang.

**Yang sudah dibangun Ronde 20 — dampak usulan ini:**
- TETAP (tidak disentuh): pagar x=0, gerbang (0,0), pos satpam (3,3),
  3 pos jaga (BL (−40,−35), BD (−40,80), TG (40,80)), spawn putra
  (−4,14), peti M3 (0,26), Cangkruk Putra (−12,−12), aturan zona
  (game) — TIDAK berubah.
- PINDAH (bila Mas ACC): Musholla Ar-Raudhah (18,−24) → (62,−24)
  + interiornya; Cangkruk Putri (12,−12) → (56,−12); cabang jalan
  x=18 → x=70; spawn putri (4,14) → (58,14); pos jaga Timur Laut
  (40,−35) → (88,−35).
- KEMBALI JADI PENYANGGA: plot lama Musholla (18,−24), Kelas Putri
  (16,0), Cangkruk Putri (12,−12) — dibiarkan kebun/taman, tanpa
  bangunan.
- Pohon (22,−22) yang sedang dipindah Raka (susulan Ronde 20, di dalam
  Musholla lama) tetap dipindah — lokasinya di zona penyangga, tidak
  bentrok dengan rencana baru.

### Perubahan — revisi 16 Nov ~21:49 WIB (ACC desain + jarak lebih jauh + tembok pemisah — USULAN, butuh ACC Mas)

**Keputusan Mas (16 Nov ~21:49 WIB, menanggapi miniatur peta): "Ok acc desainnya.. tapi untuk letak bangunan harus sesuai maps ini.. ini jaraknya kalau bisa lebih jauh antara pondok putra dan putri. Terus butuh tembok pemisah.. ini santri putra masih bisa masuk pondok putri.."** Desain arsitektur Surau + Musholla DI-ACC (tetap dibangun sesuai desain Arsa); yang berubah adalah JARAK dan PEMISAH.

**Celah yang Mas temukan (terukur dari kode):** pagar + barrier tak terlihat Ronde 20 hanya sepanjang garis pagar (z −60..+16, termasuk melintasi bukaan gerbang — gerbang memang celah visual, bukan celah lewat). Di luar rentang itu TIDAK ADA penghalang: santri putra bisa jalan memutar lewat ujung utara pagar (z<−60) atau lewat kawasan bersama selatan (z>16, lalu ke utara) masuk kampus putri — begitu di dalam (x>2.5, z<16), `_cek_batas` lama hanya toast bila dekat pagar, tidak menahan. Karena itu revisi ini berisi DUA lapis: tembok fisik + aturan keras.

**Mengapa tembok di x=14 (bukan mengikuti garis pagar lama x=2.5):** belokan pagar lama (x=9, z −17.5..−4) dibuat untuk Surau lama (dinding timur x=7,55). Surau baru (desain ACC, 20×16 m, TETAP diputar −25° — `SURAU_ROTASI_DEG`, terikat kiblat 295°) menjorok sampai x≈12,4 — belokan x=9 akan MEMOTONG bangunan, dan kaki selatan belokan (z≈−0,5) akan jatuh DI ATAS jalan E-W. Tembok lurus x=14 membersihkan Surau baru (jarak 1,56 m) + Masjid Besar utuh putra + gerbang tetap di jalan E-W. Asumsi rotasi −25° sudah dicek dari kode (`SURAU_ROTASI_DEG := -25.0`); bila Raka membangun Surau axis-aligned pun tembok x=14 tetap aman (jarak 4 m).

**Tabel jarak (terukur, pusat-ke-pusat; kecepatan jalan 6 m/s; dinding-ke-dinding dari denah — Surau 20 m, Musholla 12 m; rotasi Surau −25° mengurangi celah sebenarnya ~2 m):**

| Pasangan | Rencana 19:42 (62) | Opsi A — Terjauh (134) | Opsi B — Timur-Jauh (98) |
|---|---|---|---|
| Surau → Musholla | 63 m | **134,5 m** | 98,7 m |
| Surau → Musholla (dinding-ke-dinding) | 46 m | **118 m** | 82 m |
| Gerbang (14,0) → Musholla | 64 m (≈11 dtk, dari gerbang lama) | **122 m (≈20 dtk)** | 87 m (≈15 dtk) |
| Tembok (x=14) → Musholla (dinding barat) | 42 m | **114 m** | 78 m |
| Cangkruk Putra → Cangkruk Putri | 68 m | **140 m** | 104 m |
| Asrama Putra → Asrama Putri | 96 m | **168 m** | 132 m |
| Kelas Putra → Kelas Putri | 84 m | **155 m** | 120 m |
| Kantor Pengasuh → Kantor Ustadzah | 114 m | **186 m (≈31 dtk)** | 150 m (≈25 dtk) |
| Spawn putri → Musholla | 38 m (≈6 dtk) | **38 m (≈6 dtk, sama)** | 38 m (≈6 dtk, sama) |
| Spawn putri → Lapangan Putri (48,62) | 49 m (≈8 dtk) | **95 m (≈16 dtk)** | 66 m (≈11 dtk) |

**Koordinat baru (Opsi A — kampus putri x≈124..172, pusat ±140 m):** Musholla Ar-Raudhah (134,−24); Cangkruk Putri (128,−12); Kelas Putri (130,0); Asrama Putri (152,0); Kantor Ustadzah (150,−28); Madrasah (152,−12); Studio (166,−12); Lapangan Putri TETAP (48,62); spawn putri (130,14); pos jaga Timur Laut (160,−35). Jalan internal N–S x=142 dari jalan E–W ke pintu Musholla (setapak ke pintu selatan (134,−20)). **Opsi B (kampus putri x≈88..136, pusat ±105 m):** semua koordinat di atas −36 m ke barat — Musholla (98,−24), Cangkruk Putri (92,−12), Kelas Putri (94,0), Asrama Putri (116,0), Kantor Ustadzah (114,−28), Madrasah (116,−12), Studio (130,−12), spawn putri (94,14), pos jaga Timur Laut (124,−35); jalan internal N–S x=106; Lapangan Putri tetap (48,62). **Zona penyangga (kebun/taman + pohon, tanpa bangunan): Opsi A x 14..124; Opsi B x 14..88.**

**Batas terjauh yang masuk akal (Opsi A = batasnya):** di Musholla 134, front kampus (Kelas/Spawn 130) masih di jalan E–W (ujung timur x=160); Studio (166) 6 m di luar ujung jalan — tidak masalah, dilayani jalan internal x=142. Lebih jauh lagi (Musholla ≥140) kampus lepas dari jalan E–W (butuh perpanjangan jalan 40 m+) dan makin lepas dari kawasan bersama selatan — jarak tambahannya (±6–16 m) tidak sebanding. **Rekomendasi Tim Maps: Opsi A** — Mas sudah dua kali minta lebih jauh (19:42 + 21:49); A memberi pemisahan maksimal dengan jalan kaki internal tetap ±6 detik.

**Dicek terhadap pohon/sawah yang sudah ada (dari kode):** tidak ada pohon di dalam footprint bangunan baru Opsi A maupun B (margin ≥1,5 m) dan tidak ada bangunan baru yang menabrak sawah (x 30..90, z 10..50) atau kebun/kolam rencana Fase H ((100,30)/(100,60)). **Satu konflik MASA DEPAN (bukan Ronde 21):** pohon (130,−40) berdiri 4 m di barat calon Masjid Putri Opsi A (134,−40) — pohon itu pindah saat Masjid Putri dibangun (Fase D); Opsi B bebas konflik ini (Masjid Putri (98,−40) bersih). Pohon (14,−6) berdiri DI ATAS garis tembok x=14 → pindah ke (18,−6) di Ronde 21 (kebun penyangga). **Revisi 17 Nov ~06:02 WIB:** tembok keliling pondok putri mengelilingi kampus putri Opsi A — persegi x 115..180, z −52..+22 + gerbang barat (115,0) + jalan akses dari gerbang (14,0) + jalan masuk (115,0)→(115,8)→(142,8); reserve Masjid Putri (134,−40) di dalam keliling — detail di Perubahan 17 Nov; butuh ACC Mas atas desain peta sebelum Ronde 22.

**Spesifikasi tembok pemisah (untuk Ronde 21):**
- **Garis:** lurus x=14, z −60..+16 (76 m). Menggantikan pagar kayu Ronde 20 (dibongkar total — termasuk gerbang (2.5,0) + pos satpam (5.5,5)).
- **Bentuk:** tembok solid TERTUTUP, tinggi 3 m, tebal 0,4 m, tidak tembus pandang; plester krem #F2EAD6 + lis emas di puncak + fondasi batu abu-abu (satu keluarga warna Surau baru). Collision penuh (StaticBody) di sepanjang garis.
- **Gerbang:** satu-satunya bukaan, di (14,0) — persimpangan jalan E–W dan tembok; bukaan 4 m (z −2..+2) + 2 pilar batu (14,±2) + balok gapura + atap piramida zamrud + label GERBANG dua sisi; **pintu gerbang TERTUTUP (daun pintu kayu) + barrier collision penuh melintasi bukaan** — gerbang adalah celah visual, bukan celah lewat (sama seperti barrier pagar Ronde 20). **Pos satpam 3×3 m di (17,5)** (3 m timur + 5 m utara gerbang, sisi putri, menghadap gerbang) + satpam NPC.
- **Aturan keras `_cek_batas` (main.gd, ganti toast-only):** (a) toast bila santri dalam 1,5 m dari tembok (kedua sisi, z<16); (b) **santri putra yang masuk persegi terlarang (x>14 DAN z<16) → toast + didorong balik ke posisi legal terakhir** (sisi barat tembok); (c) cermin untuk santriwati (x<14 DAN z<16 → didorong balik ke timur); (d) **pengecualian peran (bila peran sudah ada di pemain): Pengasuh + musyrif/musyrifah + Keamanan boleh lintas** — gerbang tetap satu-satunya titik lintas visual; santri tidak pernah; (e) NPC mengabaikan barrier (seperti sekarang). Kawasan selatan (z≥16) tetap bersama untuk keduanya.
- **Dampak Masjid Besar (Fase D):** tembok x=14 lewat 4 m di timur plot masjid (x −10..+10) — masjid jadi **utuh putra; rencana partisi masjid DIBATALKAN**; putri mendapat Masjid Putri terpisah (kandidat A (134,−40), B (98,−40)) — keputusan tetap di §7 butir 7, arahnya kini jelas.
- **Mesh/perf:** tembok 76 m ≈ beberapa box + gerbang ≈ 15 mesh — sebanding pagar lama (~25 mesh); anggaran tidak berubah. Peta: garis tembok + gerbang + pos satpam di peta besar + minimap (marker TEMBOK, bukan pagar).

**Yang dikerjakan Ronde 21 (bila Mas ACC opsi A atau B):**
- BONGKAR: pagar kayu x=2.5 + gerbang (2.5,0) + pos satpam (5.5,5); Musholla lama (18,−24) + interiornya; jalan lama ke musholla (x≈11..16, z −9..−20, kembali rumput); pohon (14,−6) → (18,−6).
- BANGUN: tembok x=14 + gerbang (14,0) + pos satpam (17,5); Musholla baru (desain ACC) + interior di posisi opsi terpilih; Cangkruk Putri baru; jalan internal baru (x=142 / x=106); `_cek_batas` keras (x≥14).
- PINDAH: spawn putri (4,14) → (130,14) / (94,14); pos jaga Timur Laut (40,−35) → (160,−35) / (124,−35).
- KEMBALI JADI PENYANGGA: plot lama Musholla (18,−24), Kelas Putri (16,0), Cangkruk Putri (12,−12) + rencana 19:42 (62,−24) dkk — dibiarkan kebun/taman, tanpa bangunan.
- TETAP (tidak disentuh): Surau baru Raka (0,−12, sedang dibangun — BUKAN Ronde 21); spawn putra (−4,14); peti M3 (0,26); Cangkruk Putra (−12,−12); 3 pos jaga lain; kawasan bersama selatan; aturan ambang.

### Perubahan — revisi 17 Nov ~06:02 WIB (tembok keliling pondok putri — USULAN, butuh ACC Mas atas desain)

**Perintah Mas (17 Nov ~06:02 WIB): "Pagar tembok pondok putri mengelilingi pondok."** Tembok x=14 tetap sebagai pemisah zona; yang baru adalah **tembok keliling tambahan yang mengelilingi kampus putri Opsi A**. Desain dulu di peta miniatur (artefak `miniatur-peta-pembangunan-pondok-putri`) untuk review Mas; Raka bangun di **Ronde 22** setelah ACC. **Opsi A sudah DIPILIH Mas (16 Nov 22:03 WIB) dan sudah DIBANGUN Ronde 21 (live, deployment 1e73fc16, 17 Nov ~06:03 WIB)** — toggle A/B di peta dihapus, peta kini hanya Opsi A.

**Persegi keliling (terukur dari tapak bangunan di `kampus_putri.gd`):** Musholla 12×10 (x 128..140, z −29..−19; pagar kayu x 126..140, z −31..−17) • Cangkruk Putri 10×8 (x 123..133, z −16..−8) • Kelas Putri 10×8 (x 125..135, z −4..+4) • Asrama Putri 12×8 (x 146..158, z −4..+4) • Kantor Ustadzah 8×6 (x 146..154, z −31..−25) • Madrasah 10×8 (x 147..157, z −16..−8) • Studio 10×8 (x 161..171, z −16..−8) • Pos Jaga TL 3×3 (x 158,5..161,5, z −36,5..−33,5) • spawn putri (130,14) • jalan internal x=142 (x 140,5..143,5, z −35..+14).
- **Barat x=115** (8 m dari tepi barat Cangkruk, x=123) • **Timur x=180** (9 m dari tepi timur Studio, x=171) • **Utara z=+22** (8 m dari spawn putri, z=+14) • **Selatan z=−52** (15,5 m dari tepi selatan Pos Jaga, z=−36,5). Persegi 65 × 74 m.
- **Bahan:** sama seperti tembok x=14 — plester krem #F2EAD6 + lis emas + fondasi batu, solid tertutup 3 m × 0,4 m, collision penuh.

**Gerbang Barat (115,0):** satu-satunya bukaan keliling, di sisi barat — segaris sumbu z=0 dengan gerbang (14,0). Bukaan 4 m (z −2..+2) + 2 pilar + gapura + label GERBANG PUTRI; **pintu TERTUTUP + barrier collision penuh** (seperti gerbang (14,0): celah visual, bukan jalan lewat — lintas tetap diatur peran, bukan gerbang terbuka).

**Jalan akses:** jalan E-W (z=0, sudah ada) dari gerbang (14,0) menembus zona penyangga ke gerbang barat (115,0) — ruas x 14..115 (±101 m, ≈17 dtk jalan). **Jalan masuk internal:** dari gerbang barat (115,0) ke utara di dalam tembok sampai z=+8, lalu ke timur di z=+8 sampai jalan internal x=142. (Jalan lurus z=0 ke dalam tidak bisa — Kelas Putri (130,0) tepat di jalurnya; jalan masuk membelok ke utara melewati sisi selatan Kelas, 4 m dari dindingnya.)

**Tetap di dalam keliling:** pagar kayu taman Musholla (x 126..140, z −31..−17) + taman bunga — tidak disentuh; Pos Jaga TL (160,−35) tetap di tempatnya (kini di dalam keliling, dekat tembok selatan).

**Reserve Masjid Putri:** petak (134,−40) (x 124..144, z −48..−32) dicadangkan DI DALAM keliling (outline putus-putus di peta) — alasan tembok selatan di z=−52: supaya tembok tidak perlu dipindah saat Masjid Putri dibangun (Fase D). Pohon (130,−40) tetap di dalam keliling (pindah saat masjid dibangun, seperti rencana lama).

**Yang dikerjakan Ronde 22 (bila Mas ACC desain ini):** bangun tembok keliling (4 sisi + gerbang barat (115,0) + gapura) + jalan masuk (115,0)→(115,8)→(142,8); jalan E-W tidak berubah (sudah jadi jalan akses); audit pohon di garis tembok (Raka — garis tembok belum dicek pohon satu per satu); aturan `_cek_batas` TIDAK berubah (tembok keliling = lapis fisik kedua; penegakan tetap di garis x=14 + aturan keras); peta + minimap diperbarui (marker TEMBOK KELILING + GERBANG PUTRI).
- **Mesh/perf:** keliling 278 m ≈ belasan box + gerbang ≈ 15 mesh — sebanding tembok x=14; anggaran tidak berubah.

### Fase B — 25 santri per gender: Ruang Kelas Putra + Ruang Kelas Putri (revisi 16 Nov)

- Bangunan: **Ruang Kelas Putri** di **(58, 0)** timur (revisi 19:42 WIB —
  lokasi lama (16,0) DIBATALKAN, masuk zona penyangga), 12×9 m,
  1 lantai, eksterior cangkang zamrud/putih (serasi Surau) + interior
  terpisah 14×10 m: 12 bangku santri (2×6), meja ustadz/ustadzah,
  smartboard (slide mengikuti materi kelas), rak kitab. Papan tanda plot
  Kelas (16,0) ikut pindah ke (58,0) saat kelas dibangun.
  **Ruang Kelas Putra** di (−24, −20) barat laut, ukuran + isi sama persis
  (cermin).
- Ambang (USULAN, butuh ACC Mas): **25 santriwan → Kelas Putra;
  25 santriwati → Kelas Putri** (dihitung per gender, bukan total).
  Kelas yang ambangnya belum tercapai tetap berupa plot terkunci di areanya.
- Fungsi: kelas Nahwu + khataman pindah dari Surau ke kelas masing-masing
  area (sesi terpisah per area). **Misi M2: putra di Surau, putri di Musholla
  Ar-Raudhah** (smartboard masing-masing — revisi 16 Nov ~15:50 WIB: tidak
  ada lagi smartboard sisi putri di Surau).
- Jalan: pintu kelas putri langsung menghadap jalan E–W (z=0) — tidak perlu
  cabang baru; cabang baru dari jalan N–S barat ke pintu kelas putra.
- Peta: marker Ruang Kelas Putra (ikon buku) + Ruang Kelas Putri (ikon buku,
  warna berbeda) menggantikan marker lahan terkunci.
- NPC: +1 waypoint di depan tiap kelas.
- Anggaran: tiap kelas eksterior ≤ 30 mesh; interior ≤ 60 mesh (hanya
  dimuat saat masuk); +0 pohon.
- Voting: tidak — ambang tetap.

### Fase C — Cangkruk penuh: Asrama Putra, kompleks 3 lantai (plot (−16, 0), barat) — DESAIN BARU 16 Nov

**Keputusan Mas ~08:37 WIB: gedung asrama tergantung santri — 1 santri =
1 kasur (kasur boleh kasur susun); tiap kamar ada AC + rak kitab.**

- Bangunan: **Asrama Putra** 14×10 m, **langsung 3 lantai saat dibangun**
  (L1 = Asrama A, L2 = B, L3 = C); **lantai terisi mengikuti jumlah
  santri** (bukan dibangun bertahap per lantai). Interior terpisah per
  lantai 14×10 m: **4 kamar per lantai** (tiap kamar ±25 m²): **4 kasur
  susun = 8 kasur** + **AC 1 unit** + **rak kitab 1** + lemari. Lorong
  tengah 14×2 m.
- **1 lantai = 1 unit asrama (sesuai struktur organisasi: Asrama A, B, C…):**
  lantai 1 = Asrama A (32 kasur), lantai 2 = Asrama B (32 kasur), lantai 3
  = Asrama C (32 kasur). Kapasitas 32 kasur/lantai ≥
  30 santri per unit (organisasi: 1 asrama = 20–30 santri, 1 musyrif per
  asrama). Lantai baru dibuka saat lantai di bawahnya penuh — bukan bangunan
  baru. Maks 3 lantai untuk tapak 14×10 m; bila perlu lebih, bangunan
  asrama kedua (Asrama D…) dibangun di samping (lahan cadangan barat).
- **Rak kitab (Fase 2):** tiap kamar 1 rak kitab berisi materi/kitab.
  Santri bisa membuka kitab di rak (mis. Jurumiyah) dan membaca isinya —
  kitab interaktif (butuh isi kitab dari Laras/Tim Materi; rak kitab Surau
  + Perpustakaan ikut cara yang sama).
- **Pemicu (KEPUTUSAN MAS 16 Nov ~08:44 WIB): Asrama Putra dibangun begitu
  Cangkruk Putra penuh — TIDAK menunggu ambang 50.** Begitu kasur cangkruk
  terisi semua, **langsung dibangun kompleks asrama 3 lantai** (L1 = Asrama
  A, L2 = B, L3 = C). Lantai terisi mengikuti jumlah santri: L1 penuh →
  L2 dibuka, L2 penuh → L3 dibuka. Masalah lama "santri ke-11 sampai ke-49
  tidak ada kasur" **SELESAI** dengan aturan ini. Definisi "penuh"
  (keputusan Mas 16 Nov ~08:46 WIB): **10 kasur — 5 kasur susun**.
- **Aturan privasi kamar (KEPUTUSAN MAS 16 Nov ~08:44 WIB): santri tidak
  bisa masuk kamar santri lain.** Setiap santri hanya bisa masuk kamarnya
  sendiri (beserta teman sekamarnya — kamar adalah kamar bersama bagi yang
  tinggal di dalamnya). Kamar santri lain terkunci/tidak bisa dimasuki.
  Implikasi untuk Raka: pintu kamar perlu kunci/izin per santri (data
  penghuni kamar di save/server); ruang bersama — lorong, koridor,
  musholla/ruang santai asrama — tetap bisa dimasuki semua santri.
- **Kasur milik sendiri (KEPUTUSAN MAS 16 Nov ~08:50 WIB): santri hanya
  bisa tidur di kasurnya sendiri.** Di dalam game harus ada **petunjuk
  kasur miliknya** (mis. label/nama di kasur atau penanda di peta kamar),
  supaya santri tahu kasur yang mana miliknya.
- **Nomor kamar (KEPUTUSAN MAS 16 Nov ~08:50 WIB): tiap kamar punya
  nomor — plakat di atas pintu kamar, mis. "Kamar 001", "Kamar 002",
  dst.** Penomoran berurutan per gedung asrama.
- Fungsi: tempat tidur santri putra (fitur tidur pindah dari cangkruk ke
  asrama; cangkruk tetap sebagai tempat santai + ganti baju).
- Jalan: cabang dari jalan E–W ke pintu asrama (sudah ada jalan plot).
- Peta: marker Asrama Putra (ikon bulan/ranjang).
- NPC: santri NPC "pulang" ke asrama di malam hari (waypoint (−16, 0, 4)).
- Anggaran: eksterior ≤ 35 mesh; interior ≤ 70 mesh per lantai (hanya
  dimuat saat masuk); +4 pohon di sisi barat asrama (peneduh).
- Voting: tidak — ambang tetap.

### Fase C-P — Cangkruk Putri penuh: Asrama Putri, kompleks 3 lantai (plot (80, 0), timur) — BARU, revisi 16 Nov (lokasi revisi 19:42 WIB)

- Bangunan: **Asrama Putri** di **(80, 0)** timur (revisi 19:42 WIB —
  lokasi lama (30,0) DIBATALKAN, masuk zona penyangga), **cermin Asrama Putra**:
  14×10 m, langsung 3 lantai saat dibangun, 4 kamar per lantai (4 kasur susun = 8 kasur
  + AC 1 unit + rak kitab 1 + lemari per kamar), 1 lantai = 1 unit asrama
  (Asrama A Putri, B Putri, … — penamaan per kompleks, lihat §7 butir 3).
  Interior terpisah per lantai seperti Asrama Putra.
- **Pemicu (KEPUTUSAN MAS 16 Nov ~08:44 WIB): sama seperti putra — dibangun
  begitu Cangkruk Putri penuh, langsung kompleks 3 lantai** (L1 = Asrama A
  Putri, L2 = B, L3 = C; lantai terisi mengikuti jumlah santriwati).
  Sampai pemicu tercapai, santriwati tidur di Cangkruk Putri (5 kasur).
  Aturan privasi kamar berlaku sama: santriwati hanya bisa masuk kamarnya
  sendiri (lihat Fase C).
- Fungsi: tempat tidur santriwati; fitur tidur + ganti baju putri di sini.
- Jalan: pintu asrama putri menghadap jalan internal x=70 + jalan E–W (z=0)
  — tidak perlu cabang baru.
- Peta: marker Asrama Putri (ikon bulan, warna berbeda dari Asrama Putra).
- NPC: santriwati NPC "pulang" ke asrama di malam hari.
- Anggaran: sama seperti Asrama Putra; +4 pohon di sisi timur asrama.
- Voting: tidak — ambang tetap.

### Fase D — 100 santri (total): Masjid Besar (plot (0, −26), utara) — DUA SISI, revisi 16 Nov

- Bangunan: **Masjid Besar** 20×16 m, kubah emas besar + 2 menara, eksterior
  + interior terpisah 20×14 m: 40 sajadah (5×8), mihrab besar, mimbar,
  rak kitab, tempat wudhu di samping timur masjid (12, −30), 6×4 m.
- **Dua sisi terpisah (revisi 16 Nov):** partisi di garis x=0 membagi masjid
  jadi sisi putra (barat) + sisi putri (timur); **mihrab SATU** di tengah
  dinding utara (terlihat dari kedua sisi); sajadah **20 per sisi**;
  pintu masuk barat (putra) + pintu masuk timur (putri); tempat wudhu
  diduplikasi (barat + timur). Shalat berjamaah per sisi; **imam sisi
  putri: Ustadzah Mariyah memimpin terpisah** (keputusan Mas 16 Nov ~15:50
  WIB untuk musholla; untuk Masjid Besar masih tanya Mas — §7 butir 7 + 9).
- **Pagar & Masjid (revisi 16 Nov ~15:50 WIB):** pagar x=0 bertemu dinding
  selatan masjid di (0,−18) dan dinding utara di (0,−34); partisi dalam
  masjid melanjutkan garis pemisah. **Pertanyaan terbuka (§7 butir 7):**
  apakah Masjid Besar tetap partisi, atau dipisah penuh (Masjid Putri
  terpisah) mengikuti logika Musholla Ar-Raudhah? **Revisi 19:42 WIB:**
  kampus putri pindah ke timur — sisi putri masjid partisi kini ±67 m
  jalan kaki dari Musholla baru (62,−24); bila Mas memilih masjid
  terpisah penuh, lokasi kandidat Masjid Putri: **(62,−40)** (utara
  Musholla, x 52..72, z −48..−32, di dalam kampus putri). **Revisi 21:49 WIB:** partisi DIBATALKAN — tembok x=14 tidak memotong plot masjid; masjid utuh putra; kandidat Masjid Putri baru: A (134,−40) (utara Musholla, x 124..144, z −48..−32), B (98,−40) (x 88..108, z −48..−32).
- Fungsi: shalat berjamaah 5 waktu + Subuh (Ma'hadiyah "lima waktu
  berjamaah" dan "subuh berjamaah" pindah ke sini dari Surau); Surau tetap
  dipakai untuk khataman dan kelas kecil (per sisi). Kapasitas interior 40
  sajadah = cukup sampai ~150 santri (tidak semua santri online bersamaan).
- Jalan: jalan N–S diperlebar di depan masjid (plaza kecil 12×8 m di
  (0, −20)); pintu masjid menghadap selatan ke Surau.
- Peta: marker Masjid Besar (ikon kubah) — jadi landmark utama peta;
  minimap menampilkan kubah emas.
- NPC: waypoint jamaah di plaza masjid (0, 0, −20).
- Anggaran: eksterior ≤ 45 mesh (kubah + 2 menara + dinding); interior
  ≤ 80 mesh; +6 pohon di plaza.
- Voting: tidak — ambang tetap (100 santri **total**, bangunan bersama).

### Fase E — 200 santri: Perpustakaan & Taman (plot (0, 20), selatan)

- Bangunan: **Perpustakaan** 12×9 m + **Taman** terbuka 20×14 m di
  sekelilingnya (plot total 10×8 m diperluas ke (0, 20) ± 14 m — lahan
  selatan masih kosong, tidak menabrak jalan E–W z=0 maupun sawah).
  Interior perpustakaan terpisah: 4 rak kitab besar, 6 meja baca, smartboard
  kecil (katalog kitab). Taman: 8 pohon baru, 4 bangku, 2 lampu taman, jalan
  setapak melingkar.
- Fungsi: baca kitab + belajar mandiri; taman = tempat santai + foto +
  titik kumpul sebelum misi kelompok. **Kawasan bersama** (terbuka untuk
  putra + putri — tanpa hunian). Rak kitab perpustakaan ikut kitab
  interaktif Fase 2 (buka kitab → baca isinya).
- Jalan: cabang dari jalan N–S (x=0) ke pintu perpustakaan (sudah ada jalan
  plot); jalan setapak taman melingkar.
- Peta: marker Perpustakaan (ikon buku) + marker Taman (ikon pohon).
- NPC: waypoint baca di taman (4, 0, 24).
- Anggaran: eksterior ≤ 30 mesh; interior ≤ 60 mesh; taman +8 pohon +4 bangku
  +2 lampu (total pohon jadi ~73).
- Voting: tidak — ambang tetap. **Sampai sini urutan bangunan sudah dikunci
  Mas. Mulai Fase F, santri ikut menentukan lewat voting.**

### Fase F — 300 santri: PILIHAN VOTING #1 (Kantin vs Lapangan) — lokasi revisi 16 Nov

- Saat santri mencapai 300, dibuka voting 3 hari di konten Hari ke-X:
  **(a) Kantin + Dapur Umum** di **(0, 40) sumbu selatan (kawasan bersama)**,
  12×8 m + interior: 6 meja makan, dapur; fungsi: makan bersama + titik
  kumpul santri (terbuka untuk putra + putri); **atau (b) Lapangan
  Olahraga Putra** di (−30, 50) barat daya, 30×20 m (futsal + voli, garis
  lapangan, 2 gawang, 4 lampu lapangan); fungsi: olahraga + acara luar
  ruang putra. **Lapangan Putri** (30, 50) timur dibangun di Fase G
  (cermin Lapangan Putra) — tidak ikut voting ini.
- Yang kalah voting dibangun di Fase G (tidak hilang, hanya ditunda).
- Jalan: cabang baru dari jalan N–S selatan ke lokasi pemenang (kantin:
  di sumbu, langsung dari jalan N–S; lapangan putra: cabang di
  (−16, 0)→(−30, 50)).
- Peta: marker bangunan pemenang. Anggaran: kantin ≤ 35 mesh eksterior;
  lapangan ≤ 25 mesh (garis + gawang + tiang lampu).
- Catatan: lokasi keduanya sudah dicadangkan dari sekarang — JANGAN tanam
  pohon/bangun apa pun di (0, 40) dan (−30, 50) sebelum voting.
  (Lokasi kantin lama (−32, 28) DIBATALKAN — pindah ke kawasan bersama.)

### Fase G — 500 santri: Zona timur selesai (Madrasah + Studio + Kantor Ustadzah + Lapangan Putri) — REVISI 16 Nov

**Asrama Putri PINDAH ke Fase C-P (cangkruk penuh) — tidak lagi di Fase G.**

- **Madrasah / Ruang Kelas 2** di **(80, −12)** timur laut (revisi 19:42 WIB —
  lokasi lama (36,−18) DIBATALKAN, masuk zona penyangga), 12×9 m, interior
  12 bangku — untuk kelas mapel kedua (Fiqih/Sejarah) supaya kelas tidak
  rebutan dengan Nahwu.
- **Studio Rekaman/Video** di **(94, −12)** timur (revisi 19:42 WIB —
  lokasi lama (35,16) DIBATALKAN, masuk zona penyangga), 10×8 m — konten
  video + rekaman (dipindah dari rencana Fase I karena dibutuhkan konten
  Hari ke-X).
- **Kantor Ustadzah** di **(78, −28)** timur laut (revisi 19:42 WIB —
  lokasi lama (30,−28) DIBATALKAN, masuk zona penyangga), 10×8 m (cermin
  Kantor Pengasuh) — ruang kerja pemimpin pesantren putri.
- **Lapangan Putri** di **(48, 62)** timur (revisi 19:42 WIB — lokasi lama
  (30,50) digeser ke selatan sawah supaya tidak menempel sawah), 30×20 m
  (cermin Lapangan Putra). Pohon (70,60) tetap di timur lapangan sebagai
  pohon peneduh.
- Yang kalah voting Fase F dibangun di sini juga (kantin/lapangan yang
  tertunda), jadi Fase G = sampai 5 bangunan.
- Jalan: jalan internal kampus putri x=70 ke Madrasah/Studio/Kantor Ustadzah;
  cabang dari jalan E–W timur (x=48) ke selatan menuju Lapangan Putri
  (48,62).
- Peta: marker Madrasah, Studio, Kantor Ustadzah, Lapangan Putri.
- Anggaran: tiap bangunan eksterior ≤ 35 mesh; +8 pohon (4 di timur,
  4 di lapangan). Total pohon jadi ~85.

### Fase H — 1000 santri: Gerbang Utama + perluasan tanah 1200×1200 m

- **Tanah membesar 800×800 → 1200×1200 m** (`MAP_HALF` 400 → 600).
  Ini perluasan tanah PERTAMA sejak awal — 800 m cukup sampai 1000 santri
  karena bangunan menumpuk di kampus inti (radius 60 m), bukan menyebar.
- **Gerbang Utama** di (0, 80) selatan, di ujung jalan N–S: 2 pilar + gapura
  "PESANTREN VERSE" + plaza 16×12 m. Gerbang = penanda masuk, BUKAN
  pembatas — tidak ada pagar keliling (tetap sesuai arahan Mas).
  Gerbang di kawasan bersama (pintu masuk utama kedua area).
- Bangunan di tanah baru: **Kantor Pengasuh + Ruang Ustadz** di (−36, −28)
  barat laut (dekat Masjid), 10×8 m; **Aula Serbaguna** di **(0, 52)
  sumbu selatan (kawasan bersama)**, 16×12 m (acara besar, wisuda,
  hajatan — terbuka untuk putra + putri, sesi terpisah bila perlu);
  **Kebun Sayur** (30×20 m) di (100, 30) timur sawah + **Kolam Ikan**
  12×8 m di (100, 60) — kawasan pertanian tenggara melengkapi sawah.
  (Lokasi Aula lama (45,−35) DIBATALKAN — pindah ke kawasan bersama.)
- Jalan: N–S diperpanjang ke z=±600; E–W diperpanjang ke x=±600; jalan baru
  ke Aula (x=45) dan ke Kantor (x=−30); jalan setapak ke kebun/kolam.
- Peta: peta penuh zoom 1.0x kini mencakup 1200 m (label tetap hanya di
  4.0x); marker baru: Gerbang, Aula, Kantor, Kebun, Kolam.
- NPC: waypoint diperluas ke zona baru (gerbang, aula, kebun).
- Anggaran: perluasan tanah = 1 mesh tanah (tetap 1 draw call, hanya
  ukurannya berubah) + jalan baru ~10 mesh; bangunan baru ≤ 40 mesh
  eksterior tiap bangunan; +20 pohon (total ~105 pohon).

### Fase I — 2000+ santri (rencana jauh, belum perlu ACC)

- Opsi: perluasan tanah kedua 1200 → 1600 m; **Klinik Santri**; **Toko
  Santri (koperasi)**; **Studio Rekaman/Video** (konten); **Asrama
  tambahan lantai 2/3**; **Masjid Besar diperluas** (serambi + kapasitas
  80 sajadah); **Hutan kecil** di barat laut sebagai zona eksplorasi.
- Ditentukan nanti dari voting santri + kebutuhan kurikulum (Tim Materi).

---

## 5. Anggaran performa web (HP) — aturan Tim Maps

Aturan ini mengikat semua fase. Target: game tetap jalan mulus di HP
menengah (browser HP, bukan PC).

| Anggaran | Batas | Status sekarang |
|---|---|---|
| Total draw call peta utama | ≤ 600 | ~450 (estimasi: pohon 183 + gunung ~20 + sawah 46 + bangunan ~100 + label ~25 + jalan ~10) |
| Pohon | maks 150 total; di atas 100 pohon, ganti ke MultiMesh (1 draw call per jenis pohon — contoh: bintang ronde 5 sudah MultiMesh) | 61 pohon |
| Mesh per bangunan baru (eksterior) | ≤ 45 | — |
| Mesh interior | ≤ 80, hanya dimuat saat masuk | Surau: ~60 |
| Lampu berbayang | 1 (DirectionalLight matahari/bulan saja). Lampu jalan/lampu ruangan TANPA bayangan | terpenuhi |
| Collision | hanya di kampus inti (radius 100 m). Pohon/bangunan di luar itu visual saja | pohon sekarang semua punya collision — saat melewati 100 pohon, pohon luar inti tanpa collision |
| Jarak pandang (far plane) | 600 m (usulan — gunung di 330–370 m tetap terlihat; langit tidak terpengaruh). Raka yang setel | default Godot 4 (4000 m) — terlalu jauh, boros |
| Label 3D | culling jarak seperti label nama (28 m) untuk label kecil; papan besar tetap | label nama sudah culling 28 m |
| Ukuran pck | < 500 KB sampai 500 santri; < 1 MB sampai 1000 santri | 158 KB |
| Wasm | tetap 39,5 MB (engine, tidak tumbuh) | 39,5 MB |
| Kabut | TETAP MATI (menutupi langit di renderer web — pelajaran ronde 4/5) | mati |

**Catatan performa penting:** tanah 800×800 m hanya 1 mesh — memperbesar
tanah hampir gratis. Yang mahal adalah OBJEK (pohon, bangunan, label).
Jadi perluasan lahan (§Fase H) murah; yang dijaga adalah jumlah objek.

**Dampak dua area (revisi 16 Nov; musholla + pagar 16 Nov ~15:50 WIB):**
bangunan hunian/belajar diduplikasi (2 asrama, 2 kelas, 2 cangkruk,
2 lapangan) + **Musholla Ar-Raudhah terpisah** (bukan partisi Surau) +
interior Masjid dua sisi. Interior tetap dimuat hanya saat masuk (pola GTA),
jadi duplikasi membebani ukuran pck, bukan draw call saat jalan. Perkiraan:
tiap bangunan area putri menambah ~30–70 mesh interior (tidak aktif
bersamaan dengan sisi putra) dan ~35 mesh eksterior; **paket pemisah +
keamanan (Fase A-P): pagar ≈ 25 mesh + gerbang/pos satpam ≈ 15 mesh +
4 pos jaga ≈ 30 mesh + musholla eksterior ≤ 30 mesh** — total ≈ 100 mesh
eksterior baru saat area putri dibuka. Batas total draw call tetap ≤ 600 —
hitung ulang saat area putri dibuka; bila mendekati batas, pohon beralih ke
MultiMesh lebih awal (di bawah 100 pohon) dan far plane 600 m diberlakukan.
Anggaran pck < 500 KB sampai 500 santri perlu ditinjau ulang setelah asrama
+ kelas putri masuk (interior ganda) — tandai sebagai pantauan, bukan
pelanggaran.

**Revisi 19:42 WIB (pindah kampus putri):** pemindahan lokasi TIDAK mengubah
anggaran — jumlah bangunan, mesh, dan interior sama, hanya koordinat yang
bergeser; kampus putri kini berpusat ±70 m dari titik pusat (dulu ±30 m),
masih di dalam radius collision 100 m dan jauh di dalam far plane 600 m.
Zona penyangga menambah 0 mesh wajib (pohon yang sudah ada dibiarkan;
opsional +6 pohon kebun saat ronde pemindahan).

---

## 6. Aturan voting santri (mulai Fase F)

1. Saat jumlah santri mencapai ambang voting (300, lalu tiap ambang
   berikutnya), Tim Maps mengajukan 2 opsi bangunan ke Mas + konten
   Hari ke-X ("Komen: bangun apa dulu?").
2. Voting 3 hari (komen IG/TikTok + vote di app). Pemenang dibangun di
   ronde berikutnya; yang kalah masuk antrean Fase G.
3. Ambang tetap (25/100/200) TIDAK pernah di-vote — sudah dikunci Mas.
   Asrama tidak pakai ambang lagi: pemicunya cangkruk penuh (keputusan Mas
   16 Nov ~08:44 WIB).
4. Hasil voting + bangunan yang dibangun diumumkan di konten Hari ke-X
   berikutnya (pola @kampungkomen: "ide paling rame dibangun besok").

---

## 7. Yang belum diputuskan (butuh ACC Mas)

1. **Gunung 1–2 di ronde 6** — Tim Maps mengusulkan 2 gunung latar utara
   (sudut ~15° dan ~335°); Raka yang finalisasi di ronde 6.
2. **Lokasi Kamar Cangkruk** — ronde 6 (Raka): usulan Tim Maps timur Surau,
   sekitar (12, −12). **Revisi 16 Nov:** cangkruk lama pindah ke barat
   (−12,−12) sebagai Cangkruk Putra saat area putri dibuka; Cangkruk Putri
   dibangun di (12,−12). **Revisi 19:42 WIB (USULAN): Cangkruk Putri
   (12,−12) → (56,−12)** (terlalu dekat Cangkruk Putra).
3. **Fase F ke atas (300+ santri)** — urutan Kantin vs Lapangan, Madrasah,
   Studio, Gerbang, Aula, Kebun, Kolam: semua USULAN Tim Maps, belum ACC
   Mas. Ambang 300/500/1000 juga usulan (bukan keputusan). **Revisi 16 Nov:**
   Kantin + Aula pindah ke kawasan bersama selatan ((0,40) + (0,52));
   Lapangan diduplikasi (Putra (−30,50), Putri (30,50)); Asrama Putri
   pindah ke Fase C-P (cangkruk penuh).
4. **Far plane 600 m** — usulan performa, Raka yang setel + uji.
5. **Ambang per gender vs total (BARU, 16 Nov)** — usulan: Kelas 25
   dihitung per gender (25 santriwan / 25 santriwati); Masjid Besar 100
   dan Perpustakaan 200 dihitung total. **Asrama tidak lagi pakai ambang
   50** — pemicunya cangkruk penuh (keputusan Mas 16 Nov ~08:44 WIB).
   Setuju, atau tetap total untuk semua?
6. **"Penuh" cangkruk = 5 atau 10 kasur? — DIPUTUSKAN Mas 16 Nov ~08:46 WIB: penuh = 10 kasur (kasur disusun).** Kasur Cangkruk disusun dulu (5 kasur susun = 10 kasur); begitu 10 kasur terisi → langsung bangun kompleks asrama 3 lantai. Usulan lama Tim Maps (penuh = 5 santri) TIDAK dipakai.
7. **Surau/Masjid dua sisi vs bangunan putri terpisah penuh — DIPUTUSKAN
   SEBAGIAN (Mas 16 Nov ~15:50 WIB): Surau TIDAK dipartisi; putri mendapat
   Musholla Ar-Raudhah terpisah (62,−24 — revisi lokasi 19:42 WIB).**
   Masih terbuka: **Masjid Besar tetap partisi (satu mihrab, dua sisi —
   Fase D) atau dipisah penuh** (Masjid Putri terpisah, duplikasi penuh)?
   **Revisi 19:42 WIB:** kampus putri pindah ke timur — sisi putri masjid
   partisi kini ±67 m dari Musholla baru; bila dipisah penuh, kandidat
   lokasi Masjid Putri (62,−40).
   **Revisi 21:49 WIB:** tembok x=14 lewat 4 m di timur plot masjid — **partisi masjid TIDAK LAGI MUNGKIN** (tembok tidak memotong plot); arahnya: **Masjid Putri terpisah** (kandidat A (134,−40), B (98,−40)) — keputusan tetap di tangan Mas, tapi partisi keluar dari opsi.
8. **Kawasan selatan bersama vs dipisah juga (BARU, 16 Nov)** — usulan:
   Perpustakaan & Taman, Kantin, Aula, Gerbang, sawah/kebun/kolam = kawasan
   bersama (terbuka untuk putra + putri, tanpa hunian). Alternatif: selatan
   ikut dibelah dua.
9. **Pimpinan putri — DIPUTUSKAN (Mas 16 Nov ~15:50 WIB): Ustadzah
   Mariyah** memimpin pesantren putri (Musholla Ar-Raudhah). Masih terbuka:
   untuk **Masjid Besar** (Fase D), apakah jamaah putri dipimpin Ustadzah
   Mariyah terpisah, atau mengikuti imam putra (Kyai)? (Untuk musholla,
   sudah jelas terpisah — Ustadzah Mariyah.)
10. **Ambang buka area putri (BARU, 16 Nov)** — dibuka saat santriwati
    pertama terdaftar, atau tunggu 5 santriwati?
11. **Kapasitas asrama (BARU, 16 Nov)** — 1 lantai = 1 unit asrama
    (32 kasur susun: 4 kamar × 8 kasur), maks 3 lantai, lalu bangunan
    kedua. ACC?
12. **Rak kitab interaktif (BARU, 16 Nov)** — buka kitab di rak → baca
    isinya (mis. Jurumiyah). Isi kitab dari Laras/Tim Materi (Fase 2).
    Kitab apa dulu yang diisi (Jurumiyah / Amtsilah / Safinatun Naja)?
13. **Aturan privasi kamar — detail pengawasan — DIPUTUSKAN Mas 16 Nov ~08:47 WIB: musyrif/pengasuh BOLEH masuk semua kamar** di asrama binaannya, untuk membangunkan santri saat ada kegiatan (sholat berjamaah, khataman, dll.) dan pengawasan. Santri tetap tidak bisa masuk kamar santri lain (kamar sendiri + teman sekamar boleh; lorong/ruang bersama tetap terbuka); kamar NPC santri terkunci seperti kamar santri biasa.
14. **Pos jaga keamanan — DIPUTUSKAN (Mas 16 Nov ~15:50 WIB): Keamanan
    umum (bukan per asrama); 4 pos jaga sudut kampus inti (±40,−35) +
    (±40,80) + 1 pos satpam di gerbang (3,3).** Bila Mas mau tambah/kurangi
    pos atau geser posisinya, tinggal ubah di Fase A-P. **Revisi 19:42 WIB
    (USULAN): pos Timur Laut (40,−35) → (88,−35)** (kampus inti membentang
    sampai x≈95); 3 pos lain tetap. **Revisi 21:49 WIB (USULAN): pos Timur Laut → (160,−35) [A] / (124,−35) [B]** (kampus inti membentang sampai x≈172 [A] / x≈136 [B]).
15. **Siapa boleh lintas gerbang (BARU, 16 Nov ~15:50 WIB)** — usulan:
    Pengasuh + musyrif/musyrifah boleh lintas (pengawasan); santri tidak
    boleh masuk area lawan. ACC, atau ada pengecualian lain (mis. pengurus
    Keamanan patroli lintas area)? **Revisi 19:42 WIB:** zona penyangga
    (x 0..50) ada di timur pagar — patroli Keamanan di penyangga berarti
    lintas pagar; bila Keamanan boleh patroli penyangga, sebutkan di
    keputusan butir ini. **Revisi 21:49 WIB:** tembok + aturan keras — yang boleh lintas: Pengasuh + musyrif/musyrifah + Keamanan (patroli, termasuk patroli zona penyangga); santri tidak pernah; gerbang (14,0) tetap satu-satunya titik lintas visual (pintu tertutup + barrier).
16. **Koreksi desain lamaran — SELESAI (Mas ACC 16 Nov ~15:55 WIB):**
    DESAIN-LAMARAN-PENGURUS.md sudah diperbaiki — Keamanan = **umum
    (pesantren-wide)** dan Kepala Kamar keluar dari lamaran (via vote).
    Desain sedang dibangun (server v1.4.0 → app → game).
17. **Lokasi pondok putri — pindah lebih jauh ke timur (USULAN, revisi 16 Nov ~21:49 WIB — keputusan Mas: 'jaraknya kalau bisa lebih jauh... butuh tembok pemisah')** — Musholla Ar-Raudhah (18,−24) → **(134,−24) (Opsi A, Terjauh)** atau **(98,−24) (Opsi B, Timur-Jauh)** (Surau → Musholla A 134,5 m pusat / 118 m dinding; B 98,7 m / 82 m; rencana 19:42 (62,−24) DIBATALKAN — terlalu dekat); Opsi A: Kelas Putri (130,0), Asrama Putri (152,0), Kantor Ustadzah (150,−28), Madrasah (152,−12), Studio (166,−12), Lapangan Putri (48,62) tetap; spawn putri → (130,14); pos jaga Timur Laut → (160,−35); jalan internal x=142. Opsi B: Kelas Putri (94,0), Asrama Putri (116,0), Kantor Ustadzah (114,−28), Madrasah (116,−12), Studio (130,−12); spawn putri → (94,14); pos jaga TL → (124,−35); jalan internal x=106. **Pagar DIGANTI TEMBOK solid x=14** (gerbang (14,0), pos satpam (17,5)) + zona penyangga kebun/taman x 14..124 [A] / x 14..88 [B] + aturan zona KERAS. **Rekomendasi Tim Maps: Opsi A.**
    **DITUTUP 16 Nov 22:03 WIB — Mas memilih Opsi A; dibangun Ronde 21 dan LIVE (deployment 1e73fc16, 17 Nov ~06:03 WIB).** Rencana 19:42 (62,−24) dan Opsi B DIBATALKAN; pagar x=0/x=2.5 DIBONGKAR, diganti tembok x=14.
18. **Tembok keliling pondok putri (BARU, 17 Nov ~06:02 WIB — perintah Mas: "Pagar tembok pondok putri mengelilingi pondok")** — USULAN, butuh ACC Mas atas desain peta sebelum Raka membangun di Ronde 22: persegi x 115..180, z −52..+22 (65 × 74 m); gerbang barat (115,0) segaris gerbang (14,0) + jalan akses E-W + jalan masuk (115,0)→(115,8)→(142,8); pagar kayu Musholla tetap di dalam; reserve Masjid Putri (134,−40) di dalam keliling. Detail di Perubahan 17 Nov.

---

## 8. Serah terima ke Raka (integrator)

- Fase B (Ruang Kelas, 25 santri) adalah pekerjaan Maps berikutnya — bisa
  mulai begitu santri mencapai 25 (saat ini 0 santri produksi) ATAU begitu
  Mas memerintahkan bangun duluan untuk konten.
- Tiap fase baru = 1 ronde Raka: bangun → verifikasi (import 0, check-only,
  tes logika, smoke 600 frame, foto bukti) → export → Damar deploy.
- File yang disentuh per fase: `scripts/pesantren_builder.gd` (eksterior +
  plot), `scripts/mission_data.gd` (tambah tahap ke GROWTH_STAGES +
  penanda misi bila perlu), `scripts/ui.gd` (marker peta + minimap),
  `scripts/main.gd` (waypoint NPC + data peta) — Raka yang menentukan
  file pastinya per ronde.
- Lahan cadangan Fase F ((0, 40) Kantin dan (−30, 50) Lapangan Putra)
  JANGAN dipakai untuk hal lain sampai voting selesai.
- **Dua area + tembok (revisi 16 Nov ~21:49 WIB — USULAN, BUTUH ACC MAS DULU, jangan bangun sebelum ACC):** Raka kerjakan dalam Ronde 21: **Musholla Ar-Raudhah (134,−24) [A] / (98,−24) [B] + interiornya** (desain ACC; lokasi lama (18,−24) + rencana 19:42 (62,−24) DIBATALKAN); **TEMBOK solid x=14 (z −60..+16) + gerbang (14,0) + pos satpam (17,5)** — pagar x=2.5 + gerbang (2.5,0) + pos satpam (5.5,5) DIBONGKAR; **aturan zona KERAS** (`_cek_batas`: dorong balik + toast; Pengasuh/musyrif/Keamanan boleh lintas); **4 pos jaga — Timur Laut pindah (40,−35) → (160,−35) [A] / (124,−35) [B]**, 3 lain tetap; spawn putri (4,14) → (130,14) [A] / (94,14) [B]; Cangkruk Putri di (128,−12) [A] / (92,−12) [B]; jalan internal baru x=142 [A] / x=106 [B] (cabang lama x=18 + jalan lama musholla dibongkar); zona penyangga x 14..124 [A] / x 14..88 [B] dibiarkan kebun/taman (tanpa bangunan); pohon (14,−6) → (18,−6). Ambang buka area putri (§7 butir 10) + Masjid Putri terpisah (§7 butir 7) + siapa boleh lintas gerbang (§7 butir 15) + lokasi baru pondok putri (§7 butir 17) menunggu keputusan Mas.
- **Tembok keliling pondok putri (revisi 17 Nov ~06:02 WIB — USULAN, BUTUH ACC MAS atas desain peta dulu, jangan bangun sebelum ACC):** Raka kerjakan dalam Ronde 22: **tembok keliling persegi x 115..180, z −52..+22 + gerbang barat (115,0) + gapura** (pintu tertutup + barrier, seperti gerbang (14,0)); **jalan masuk (115,0)→(115,8)→(142,8)**; pagar kayu Musholla + Pos Jaga TL TIDAK disentuh; audit pohon di garis tembok; aturan `_cek_batas` TIDAK berubah; peta + minimap diperbarui (marker TEMBOK KELILING + GERBANG PUTRI).
- **Asrama (revisi 16 Nov ~08:44):** pemicu bangun Asrama = cangkruk penuh
  (bukan 50 santri) — saat ronde Asrama dikerjakan, Raka: (a) ubah papan
  tanda plot Asrama ("50" → "Cangkruk penuh" atau tanpa angka — Raka yang
  putuskan tampilannya); (b) bangun kompleks 3 lantai sekaligus (L1 = A,
  L2 = B, L3 = C), lantai terisi mengikuti santri; (c) terapkan aturan
  privasi kamar: pintu kamar berkunci per santri (hanya penghuni kamar
  yang bisa masuk; lorong/ruang bersama tetap terbuka). Definisi "penuh" =
  10 kasur (DIPUTUSKAN Mas 16 Nov ~08:46 WIB, §7 butir 6).
