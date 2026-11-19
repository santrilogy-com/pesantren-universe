# Laporan Penyelidikan: NPC Tembus Tembok / Pagar / Pohon

**Oleh:** Raka (lead game) — 19 Nov 2026 ~14:30 WIB
**Pemicu:** Laporan Mas 14:00 WIB — "NPC masih bisa tembus tembok, pagar, pohon, dll."
**Status:** Penyelidikan SELESAI, terbukti. Kode game TIDAK diubah (gate berjalan).
**Tes:** `skrip/test_npc_tembus.gd` + `.tscn` (13.494 B) | suplemen realistis `skrip/test_npc_tembus_suplemen.gd` | probe identifikasi `skrip/probe_tabrakan_surau.gd`
**Log:** `~/.logs-gate-18nov/test-npc-tembus-19nov.log` (679 baris) | CSV jejak live `~/.logs-gate-18nov/jejak-npc-tembus-19nov.csv` (319 baris)

## Metode (singkat)

Fisika dipakai sebagai **pendeteksi** — NPC sendiri tidak punya fisika.
Raycast marching 3 jalur paralel (±0,3 m, y=0,9) di sepanjang tiap
segmen + shape-query bola r=0,35 untuk titik yang berdiri di dalam
benda padat + cek geometris tapak 5 cangkang besar. Validasi metode
(Fase 0): tembok utara/selatan + BarrierGerbang terdeteksi; plaza
kosong; ray dari dalam Asrama mengenai dinding (tidak ada titik buta).

## Hasil — angka besar

| Fase | Temuan |
|---|---|
| A — semua pasangan waypoint bebas Bilal/Faris (91 pasang) | 430 mentah; **61/91 pasangan (67%) bermasalah**, 30 bersih |
| B — siklus patroli Kyai + Mariyah | 9 mentah (Kyai → tiang serambi; Mariyah → sudut Musholla; titik (-8,18) = pohon) |
| B-dalam — kursi↔pintu_dalam, spawn_dalam→kursi | **BERSIH (0)** |
| C — rute sholat dari tiap waypoint | 161 mentah (Surau 14/14 → tiang serambi; Musholla 14/14 → BarrierGerbangPutri, teoretis) |
| C-pulang | 3 mentah (Kyai + Bilal → tiang serambi; Mariyah pulang **BERSIH**) |
| D — jalan bebas live, 60 dtk nyata (~15 mnt game, time_scale 15) | 44 event; 30 pasangan dilalui; **~1,5 tembusan/NPC/menit game** |
| Suplemen — rute sholat dari titik berangkat REALISTIS | 10 temuan (Kyai 7/7 → tiang; Bilal dari SPAWN → tiang; Mariyah 1/5 → sudut Madrasah) |
| **Total** | **647 temuan (dedup per fase\|label\|apa\|pos-1m)** |

## Temuan #1 — Tiang serambi Surau: collider tersering (38 hit)

4 tiang depan serambi di **z=-1,1; x=-2,9 / -1 / +1 / +2,9**,
kotak 0,4×2,5×0,4 (teridentifikasi pasti via probe). Segmen
`(-2,2)→(0,-2,3)` — pendekatan pintu di `_rute_ke_pintu_surau`,
`_rute_pulang`, DAN siklus patroli Kyai — memotong **tiang (-1,-1,1)**
di (-1,0,-0,9). Komentar rute (`main.gd:3977-3995`) hanya
memverifikasi dinding depan (z=-4); tiang tidak diperiksa
(kemungkinan collision tiang GLB ditambahkan Bagas belakangan).
**Dampak: SETIAP jalan Kyai/Bilal/Faris ke dan dari sholat menembus
tiang; setiap siklus patroli Kyai juga.** Jalur tengah NPC
(radius ~0,35 m) tetap menyenggol sudut tiang — bukan artefak
jalur offset tes.

## Temuan #2 — Jalan bebas = garis lurus acak (61/91 pasangan)

`npc.gd:219-222` `_pick_target()` pilih waypoint acak, `_langkah_ke`
jalan lurus — tanpa validasi segmen, tanpa koridor. Yang paling
sering dipotong (jumlah pasangan): Surau 15, dinding Asrama Putra
15, tembok pemisah 15, AnnexTangga 8, PagarBata 8, PagarTaman
timur 8 / barat 5 / selatan 5 / utara-barat 6, Cangkruk 5,
Gubuk santri (26,30) 4, tiang lampu 5, Pos Satpam 1, pohon taman 1.
Live (Fase D): Bilal + Faris menembus PagarTaman, PagarBata,
TembokPemisah, Asrama Putra (Faris jalan diagonal penuh di dalam
tapak, (-15,2,4,6)→(-21,9,4,5)), Cangkruk, pohon taman, Gubuk —
di depan mata pemain, terus-menerus.

## Temuan #3 — Waypoint / titik patroli yang bermasalah

| Titik | Masalah | Bukti |
|---|---|---|
| Waypoint **(-6,-4)** | PERSIS di garis dinding selatan Surau (z=-4); bola r=0,35 menyentuh kotak dinding @47 (-4,6,-4,0) | shape-query; semua segmen dari/ke (-6,-4) menabrak dinding + masuk tapak Surau |
| Waypoint **(-60,-40)** | TEPAT di batang pohon | pohon `_dekor` di (-60,-40) (`pesantren_builder.gd:1512`); TITIK DI DALAM @1261 |
| Waypoint **(0,30)** | DI DALAM taman berpagar (pintu hanya di (0,25,5), daun pintunya pun punya collision) | segmen dari utara/barat/timur menembus PagarTaman + PintuTaman_Daun |
| Titik patroli Kyai **(-8,18)** | TEPAT di batang pohon | pohon `_dekor` dipindah ke (-8,18) oleh Nadia 18 Nov ("bersih dari plot") — tapi itu titik patroli Kyai; TITIK DI DALAM @1191 |
| Segmen patroli Mariyah **(148,-24)→(134,-17,5)** | Memotong sudut timur-laut Musholla | masuk (140,1,-20,0), keluar (136,8,-19,1); di dalam tapak (139,2,-19,9), (138,4,-19,5), (137,5,-19,1) |
| Segmen patroli Kyai **(-2,2)→pintu_luar** | Tiang serambi (lihat #1) | hit (-0,8,-1,0) |

## Temuan #4 — Rute sholat selatan = garis lurus tanpa koridor

`_rute_ke_pintu_surau`: bila `dari.z >= -7` rute langsung
`[(-2,2), (0,-2,3)]` — tanpa koridor. Dari (-100,80)/(-40,120)/
(100,60)/(20,20) dst garis lurus memotong Asrama Putra, pagar
taman, PagarBata, tembok pemisah. Komentar fungsi hanya mengakui
batasan "NPC di dalam tapak"; kasus selatan tidak disebut.
Dipakai oleh Kyai + Bilal + Faris (`main.gd:3767,3794`).

## Temuan #5 — Rute Musholla: langkah "ke z=-14 dulu" buta tapak

`_rute_ke_pintu_musholla` mempertahankan x saat menuju z=-14.
Dari titik patroli Mariyah **(148,-24)**: segmen (148,-24)→(148,-14)
berjalan sepanjang x=148 — di dalam rentang x Madrasah (147..157)
— menembus sudut Madrasah di (148,3,-16,1) dan (147,1,-13,7).
Satu-satunya temuan realistis Mariyah (1 dari 5 titik; lainnya
bersih). Selain itu: dari barat tembok, rute lewat gerbang (115,0)
tapi gerbang **TERTUTUP** (BarrierGerbangPutri) — 14/14 hit di Fase C;
teoretis untuk Mariyah (tak pernah di barat tembok), tapi
membuktikan gerbang tertutup bukan jalur.

## Temuan #6 — Waypoint di kedua sisi tembok/pagar tertutup (butuh keputusan desain)

- **Tembok pemisah x=14:** waypoint timur (20,20), (32,28), (60,30),
  (100,60) berada di zona penyangga (x 14..115, sah dijelajahi),
  tapi satu-satunya jalan adalah gerbang (14,0) yang TERTUTUP.
  15 pasangan memotong tembok. NPC hanya bisa mencapai waypoint
  timur dengan menembus tembok/gerbang.
- **PagarBata utara (z=39):** waypoint (-40,120), (-100,80) di utara
  pagar; 8 pasangan memotongnya. Tidak ada gerbang di pagar itu.
- Pilihan desain (bukan sekadar kode): (a) waypoint timur/utara
  dihapus dari set Bilal/Faris; (b) gerbang jadi jalur resmi NPC
  (rute via (14,0) — tapi gerbang tertutup juga bagi pemain, NPC
  lewat gerbang tertutup terlihat aneh); (c) NPC "lolos" di gerbang
  via teleport seperti sholat. **Perlu keputusan Xam/Mas.**

## Yang BUKAN masalah (dicatat supaya tidak diperbaiki sia-sia)

- Patroli dalam ruangan BERSIH; Mariyah pulang BERSIH; 30/91
  pasangan bebas bersih.
- SEMUA pohon punya collision (raycast menangkap) — masalahnya NPC
  yang mengabaikan collision yang ada, bukan pohon tanpa collision.
- Tembok pemisah + gerbang: collision ADA dan rapat (probe Fase 0) —
  tembok tidak bolong; NPC menembus karena jalannya lurus.
- Pintu Surau: celah 2,4 m ada; masalahnya tiang di depannya.
- Perbaikan Kyai-tembok (rute pulang, 13:04) TERBUKTI menutup
  jalurnya — `_rute_pulang` kini hanya menyisakan tiang serambi.

## Akar penyebab (ringkas)

1. **NPC bergerak tanpa fisika** (`npc.gd` gerak langsung via
   posisi) — akar tunggal; semua yang lain pemicu.
2. Jalan bebas = garis lurus antar waypoint acak, tanpa validasi.
3. Waypoint/patroli ditaruh di dalam/di atas benda (dinding, pohon,
   taman berpagar) tanpa cek tabrakan.
4. Segmen pintu Surau (-2,2)→(0,-2,3) tidak diperiksa terhadap
   tiang serambi (hanya dinding yang diverifikasi).
5. Rute sholat selatan tanpa koridor; rute Musholla buta tapak.
6. Waypoint ada di kedua sisi pembatas tertutup tanpa rute gerbang.

## Usulan perbaikan (berurutan, setelah deploy + ACC)

### A. Perbaiki titik bermasalah — MURAH, risiko ~nol, kerjakan dulu
- Waypoint (-6,-4) → pindah ke luar garis dinding, mis. (-6,-6)
  (2 m di selatan dinding; di luar tapak, di barat tangga).
- Waypoint (-60,-40) → geser dari batang pohon, mis. (-58,-38),
  atau hapus dari daftar (sudah ada (-70,30) dkk. sebagai pengganti
  jauh); pohonnya JANGAN dipindah (sudah benar di tempatnya).
- Titik patroli (-8,18) → pindah pohon ke (-10,20) ATAU titik
  patroli ke (-8,20) — putuskan satu; jangan keduanya.
- Waypoint (0,30) → hapus dari set bebas (taman hanya bisa
  dimasuki lewat pintu; tanpa routing gerbang, NPC tak bisa ke
  sana dengan benar).
- Validasi ulang dengan tes ini (target: 0 TITIK DI DALAM).

### B. Luruskan pendekatan pintu Surau — MURAH, dampak TERBESAR
- Ubah titik plaza (-2,2) → **(0,2)** (atau tambah waypoint (0,0))
  di `_rute_ke_pintu_surau` + `_rute_pulang` sehingga segmen akhir
  lurus sepanjang **x=0** — celah antar tiang -1/+1 selebar 2 m,
  pusat x=0. Satu perubahan menutup SEMUA tembusan tiang:
  patroli Kyai, ke-pintu Surau 14/14, pulang Kyai/Bilal, suplemen 8/8.
- Risiko kecil (hanya geser jalur jalan ~2 m; tidak ada visual
  berubah). Verifikasi: jalankan ulang tes ini + Fase D singkat.
- Catatan samping (bukan blocker): NPC berjalan di y=0 melewati
  tangga (naik 0,5 m) menuju serambi — kaki tenggelam ~0,5 m di
  1 m terakhir sebelum teleport masuk. Sudah ada sejak dulu
  (segmen lama juga begitu); perbaiki bila ada ronde polish.

### C. Koridor selatan + rute Musholla sadar-tapak — SEDANG
- `_rute_ke_pintu_surau` untuk `dari.z >= -7`: jangan garis lurus
  ke (-2,2). Arahkan dulu ke koridor yang sudah terbukti aman —
  mis. via (-28,2) bila dari.x < 0, atau via (0,2) bila dari.x >= 0
  dengan segmen yang sudah divalidasi — lalu (0,2)→(0,-2,3).
  Dari timur tembok (x>14): putuskan dulu soal #6 (butuh gerbang
  atau waypoint dihapus).
- `_rute_ke_pintu_musholla`: langkah ke z=-14 harus memilih x yang
  aman — mis. geser dulu ke x=142 (jalan internal, sudah jadi titik
  patroli Mariyah) bila x saat ini dalam rentang tapak Madrasah
  (147..157), baru ke (134,-14). Atau: rute (148,-24)→(142,-6)→
  (134,-14) memakai titik patroli yang sudah ada.
- Risiko sedang: mengubah logika rute; wajib tes ulang Fase C +
  suplemen (target: 0 temuan realistis).

### D. Validasi segmen di `_pick_target` — SEDANG, pertahanan lapis kedua
- Saat memilih target acak, cek segmen (raycast seperti tes ini);
  tolak target yang segmennya menabrak, pilih target lain.
  Biaya: 1 raycast per pemilihan, 2 NPC — murah.
  Risiko: NPC bisa kehabisan target bersih dari posisinya (mis.
  sedang di dalam taman) — perlu fallback (teleport ke plaza /
  pilih target terdekat yang bersih). Menutup SEMUA kasus jalan
  bebas, termasuk yang belum terpikir. Kerjakan SETELAH A–C
  (kalau A–C sudah bersih, D jadi jaring pengaman, bukan penambal).

### E. Penghindar / tabrakan pada gerak NPC — MAHAL, TIDAK direkomendasikan sekarang
- Ubah NPC jadi CharacterBody3D + move_and_slide, atau steering
  avoidance. Biaya besar (fisika per NPC, risiko regresi
  gerak/sholat/teleport, performa) dan TIDAK menyelesaikan
  waypoint-di-dalam-benda (NPC tetap berdiri di dalam pohon).
  Alternatif murah ("belok 45° bila ada halangan 1 m di depan")
  berisiko NPC nyangkut di sudut — perlu tes ekstensif.
  Hanya bila A–D dinilai belum cukup.

## Rekomendasi

**Terapkan A + B + C + D, berurutan, setelah deploy 20261119-2
selesai dan setelah ACC Xam.** A+B menutup mayoritas tembusan yang
dilihat Mas (tiang di setiap sholat + waypoint di dinding/pohon);
C menutup rute sholat dari selatan; D jadi jaring pengaman.
**Keputusan desain #6 (waypoint timur/utara vs tembok/pagar
tertutup) harus diputus dulu** — tanpa itu, C tidak bisa menutup
pasangan yang memotong tembok/pagar utara.

**Kaitan dengan ronde berikutnya:** sistem NPC 20 (desain Laras,
ACC Mas 14:10) memakai waypoint/zona — **perbaiki waypoint dan
rute DULU (A–C), baru bangun 20 NPC di atasnya**, atau 20 NPC
akan menembus 10× lebih terlihat. Desain Laras sudah mensyaratkan
"segmen divalidasi vs tapak bangunan" — data validasi ada di
laporan ini (log + daftar pasangan bermasalah di atas).
