# Audit Interior — Perabot & Props Primitif Godot

**Auditor:** Dewa (Interior) · **Tanggal:** 17 November 2026
**Ruang lingkup:** semua interior di `~/workspace/pesantren-verse/godot-dunia/`
**Sifat:** RENCANA/AUDIT SAJA — tidak ada file game yang dibangun atau diubah.
**Gaya yang dituju:** 3D halus seperti model Asian Boy (studi: `blender-santri/riset-model-dasar/ASIANBOY-STUDY.md` — chibi 3,66 kepala, wajah bulat lembut, permukaan halus, bukan balok). Palet: krem `#F2EAD6`, zamrud `#065F46`, emas `#C9A227`, jati `#7B4B2A` (`desain-arsitektur/DESAIN-ARSITEKTUR.md` §4).

## Metode & temuan umum

- File yang dibaca: `scripts/interior_surau.gd`, `scripts/interior_musholla.gd`, `scripts/interior_cangkruk.gd`, `scripts/kampus_putri.gd`, `scripts/pesantren_builder.gd` (cangkang Cangkruk Putra + Surau), `scripts/main.gd` (wiring pintu/interior), `scripts/palette.gd`, `scenes/interior_surau.tscn`.
- **Tidak ada satu pun model 3D halus di game.** Grep `glb|gltf|obj|PackedScene` di seluruh `scripts/`, `scenes/`, `main.tscn`, `project.godot` menghasilkan NOL. Semua perabot dibangun dari helper `Palette` (`palette.gd`): `box()` = BoxMesh, `cylinder()` = CylinderMesh, `sphere()` = SphereMesh, `capsule()` = CapsuleMesh — semuanya primitif polos bermaterial warna datar.
- Hanya **3 ruangan yang punya interior beneran** (map terpisah ala GTA): Surau, Musholla Ar-Raudhah, Cangkruk Putra. **6 ruangan lain hanya cangkang luar** (lantai + dinding + atap + jendela kotak) tanpa satu pun perabot di dalamnya — lihat §5.
- Dua kursi yang dipakai NPC **tidak punya mesh sama sekali**: Kyai dan Ustadzah Mariyah "duduk" di posisi kosong (lihat §6).

---

## 1. Interior Surau — 18 × 14 m, pusat (0, 0, −301), tinggi 4,6 m

Sumber: `scripts/interior_surau.gd` (InteriorSurau.build(), dipakai `main.gd`). Ruangan diputar −25° mengelilingi pintu (0,0,−294) supaya mihrab menghadap kiblat 295°. Semua perabot di bawah ini primitif.

| # | Elemen | Primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|
| 1 | Karpet ruangan | 1 × BoxMesh, zamrud gelap | 17,4 × 0,06 × 13,4 m | Satu kotak datar raksasa menutupi hampir seluruh lantai; tanpa motif, tanpa pinggiran, tanpa tekstur tenun |
| 2 | Sajadah ×15 (3 baris × 5) | 15 × BoxMesh, zamrud | tiap 0,65 × 0,03 × 1,15 m | Kotak tipis datar di atas karpet; tanpa motif mihrab, tanpa pinggiran, tanpa lipatan — 15 lempeng identik |
| 3 | Mihrab | 2 × BoxMesh (panel zamrud gelap + lis emas) | panel 1,6 × 2,4 × 0,18 m; lis 1,9 × 0,14 × 0,24 m | Bukan ceruk: hanya papan datar menempel dinding barat; tanpa lengkung, tanpa relung, tanpa ornamen |
| 4 | Smartboard | 2 × BoxMesh (bingkai kayu gelap + layar putih) + 4 × SphereMesh emas sudut + Label3D kosong | bingkai 0,12 × 2,4 × 4,6 m; layar 0,06 × 2,2 × 4,4 m | Papan datar raksasa 4,6 m; layar 3D kini KOSONG (RONDE 10: tulisan dihapus, konten pindah ke popup UI) |
| 5 | Rak kitab ×2 (barat-selatan, timur-utara) | Tiap rak: 4 × BoxMesh (2 papan + 2 tiang) + 5 × BoxMesh kitab warna-warni = 9 primitif | rak 0,35 × 1,6 × 1,8 m; kitab 0,22 × 0,35 × 0,28 m | Rak terbuka tanpa pintu/sisi; kitab = balok warna polos tanpa punggung/judul, 3 di rak bawah + 2 di rak atas |
| 6 | Meja sampar ×3 (lesehan) | Tiap meja: 1 × CylinderMesh pipih (oval, scale z 0,55) + 4 × CylinderMesh kaki + 4 × BoxMesh kitab = 9 primitif | atas Ø 2,2 m (oval 2,2 × 1,2 m), tinggi 0,45 m; kitab 0,35 × 0,06 × 0,25 m | Papan atas "oval" hanya silinder dipipih — tepinya tetap tajam; kitab di atasnya balok tipis warna polos |
| 7 | Lampu hangat ×4 | Tiap lampu: 1 × CylinderMesh gantungan kayu + 1 × CylinderMesh kap emas + 1 × SphereMesh bola kuning + OmniLight3D = 3 primitif visual | gantungan Ø 0,06 × 0,5 m; kap Ø 0,2 × 0,06 m; bola r 0,16 m | Bola lampu polos tanpa kap sungguhan (hanya cakram emas + bola); tanpa rantai/kabel yang berlekuk |
| 8 | Pilar sudut ×4 | 4 × CylinderMesh, putih | r 0,2/0,22 m, tinggi 4,6 m | Silinder polos tanpa alas/kepala pilar, tanpa ukiran |
| 9 | Lis + tiang pintu | 1 × BoxMesh lis emas 2,4 × 0,12 × 0,3 m + 2 × CylinderMesh tiang r 0,08 m, tinggi 2,5 m | — | Tiang bundar polos; tanpa daun pintu (celah terbuka) |
| 10 | Label "KELUAR" | Label3D (teks, bukan perabot) | font 24 | Penanda jalan; bukan elemen 3D |

**Subtotal Surau: 34 unit perabot, 88 mesh primitif** (karpet 1 + sajadah 15 + mihrab 2 + smartboard 6 + rak 18 + meja 27 + lampu 12 + pilar 4 + lis/tiang 3).

**Yang dihapus dan TIDAK ADA lagi (jangan dibangun ulang tanpa ACC Mas):** papan tulis dinding (RONDE 5) dan papan jadwal Ngaji Aja (RONDE 6) — keduanya sengaja dihapus; di Surau kini tidak ada papan kecuali smartboard.

---

## 2. Interior Musholla Ar-Raudhah (putri) — 14 × 10 m, zona interior x=60, tinggi 3,4 m

Sumber: `scripts/interior_musholla.gd` (InteriorMusholla.build(), RONDE 20). Diputar −25° mengelilingi pintu (60,0,−296), mihrab di dinding barat menghadap kiblat 295°.
**Koreksi ukuran:** brief menyebut 12 × 10 m, tapi kode memakai `RUANG_LEBAR 14,0` × `RUANG_DALAM 10,0` — interior map 14 × 10 m, lebih besar dari cangkang luarnya (12 × 10 m di `kampus_putri.gd`, pola GTA yang sama seperti Surau).

| # | Elemen | Primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|
| 1 | Sajadah ×15 (3 × 5) | 15 × BoxMesh, zamrud | tiap 0,65 × 0,04 × 1,15 m | Sama seperti Surau: lempeng datar tanpa motif |
| 2 | Mihrab | 1 × BoxMesh emas + Label3D Arab "محراب" | 0,2 × 2,6 × 1,4 m | Lebih datar dari Surau: hanya satu balok emas menempel dinding; tanpa lis, tanpa lengkung |
| 3 | Smartboard M2 Putri | 1 × BoxMesh layar putih-biru + 1 × BoxMesh stand kayu gelap | layar 0,08 × 1,7 × 3,0 m; stand 0,1 × 0,9 × 3,0 m | Lebih kecil dari Surau (3,0 m vs 4,6 m); tanpa bingkai, tanpa bola sudut, tanpa Label3D layar |
| 4 | Rak kitab ×1 (timur-utara) | 1 × BoxMesh badan kayu + 3 × BoxMesh kitab | badan 0,35 × 2,0 × 1,6 m; kitab 0,25 × 0,28 × 0,12 m | Badan rak SATU balok pejal (bukan papan + tiang seperti Surau); kitab menempel di muka, 3 buah saja |
| 5 | Meja sampar ×1 (tenggara) | 1 × BoxMesh papan + 2 × BoxMesh kaki | papan 1,2 × 0,1 × 0,7 m, tinggi 0,45 m; kaki 0,08 × 0,45 × 0,08 m | Kotak persegi (bukan oval seperti Surau); hanya 2 kaki; tanpa kitab di atasnya |
| 6 | Lampu hangat ×2 | 2 × SphereMesh bola kuning + 2 × OmniLight3D | bola r 0,12 m, di y 3,1 m | **Paling mentah:** bola melayang tanpa gantungan, tanpa kap, tanpa kabel — tidak seperti Surau/Cangkruk yang punya gantungan + kap |
| 7 | Pilar sudut ×4 | 4 × CylinderMesh, putih | r 0,22/0,26 m, tinggi 3,4 m | Silinder polos, sama seperti Surau |
| 8 | Trim plafon | 1 × BoxMesh zamrud | 14 × 0,15 × 10 m | Satu lempeng datar di bawah plafon; bukan lis profil |
| 9 | Label "KELUAR" | Label3D (teks) | font 28 | Penanda jalan |

**Subtotal Musholla: 26 unit perabot, 32 mesh primitif** (trim 1 + mihrab 1 + sajadah 15 + smartboard 2 + rak 4 + meja 3 + lampu 2 + pilar 4).

---

## 3. Interior Cangkruk Putra — 14 × 10 m, pusat (−60, 0, −300), tinggi 3,6 m

Sumber: `scripts/interior_cangkruk.gd` (InteriorCangkruk.build(), RONDE 6 + revisi 23:01). Pintu selatan (z=−295, celah 1,6 m). Cangkang luarnya di `pesantren_builder.gd` `_cangkruk`, kini di (−22,−18).

| # | Elemen | Primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|
| 1 | Tempat tidur ×5 | Tiap kasur: 5 × BoxMesh (rangka, kepala, kasur, bantal, selimut) + 4 × CylinderMesh kaki = 9 primitif | 1,1 × 2,1 m, tinggi rangka 0,25 m; kepala 1,1 × 0,9 × 0,08 m | Rangka + kasur + bantal + selimut semuanya kotak tajam; selimut = balok zamrud menutupi setengah kasur; bantal = balok putih; tanpa guling, tanpa lipatan, tanpa seprai berlekuk |
| 2 | Lemari pakaian ×1 (timur, dekat pintu) | 1 × BoxMesh badan + 2 × BoxMesh pintu + 2 × SphereMesh kenop emas + 1 × BoxMesh cermin = 6 primitif | badan 0,55 × 2,2 × 1,6 m; pintu 0,06 × 2,0 × 0,72 m; cermin 0,02 × 1,2 × 0,5 m | Badan satu balok pejal; pintu = lempeng tipis menempel; cermin = kotak biru muda datar; kenop = bola kecil |
| 3 | Meja kecil ×1 (barat, dekat pintu) | 1 × CylinderMesh atas + 1 × CylinderMesh kaki + 1 × CylinderMesh tiang lampu + 1 × CylinderMesh kap lampu + 1 × BoxMesh kitab = 5 primitif | atas Ø 0,9 m, tinggi 0,55 m; kap Ø 0,24/0,32 × 0,18 m | Meja bundar silinder polos; lampu meja = tiang + kerucut terpotong warna krem; kitab = balok zamrud tipis |
| 4 | Jendela ×3 (barat, timur, selatan) | Tiap jendela: 7 × BoxMesh (4 bingkai + kaca + 2 jeruji + ambang) = 8 primitif | bingkai 1,1 × 1,2 m; kaca 0,94 × 1,12 × 0,03 m | Bingkai kotak + kaca kotak biru terang (emissive) + jeruji silang kotak; dinding TIDAK dilubangi — kaca menempel di muka dinding; tanpa daun jendela, tanpa gorden |
| 5 | Karpet tengah | 1 × BoxMesh, merah (#a33b3b) | 3,0 × 0,05 × 2,0 m | Satu kotak datar di jalan tengah; tanpa motif |
| 6 | Lampu hangat ×1 (sudut barat-laut) | 1 × CylinderMesh gantungan + 1 × CylinderMesh kap emas + 1 × SphereMesh bola + OmniLight3D = 3 primitif | bola r 0,16 m di y 3,28 m | Sama polanya dengan Surau; dipindah ke sudut (RONDE 8) supaya kamera bangun tidur tidak terjepit bola |
| 7 | Lis + tiang pintu | 1 × BoxMesh lis emas + 2 × CylinderMesh tiang r 0,06 m, tinggi 2,2 m | lis 1,6 × 0,1 × 0,3 m | Sama seperti Surau, lebih kecil |

**Subtotal Cangkruk Putra: 15 unit perabot, 87 mesh primitif** (kasur 45 + lemari 6 + meja 5 + jendela 24 + karpet 1 + lampu 3 + lis/tiang 3).

---

## 4. Cangkruk Putri (128, −12) — cangkang 10 × 8 m, interior BELUM ADA

Sumber: `kampus_putri.gd` `_cangkruk_putri` + grep `main.gd` (nol hasil).

| # | Elemen | Primitif sekarang | Perkiraan ukuran | Catatan |
|---|---|---|---|---|
| — | **Tidak ada interior sama sekali** | — | — | Hanya cangkang luar: lantai kayu, 4 dinding, atap segitiga 2 lereng + bubungan, 6 jendela kotak (box zamrud gelap), pintu selatan 1,6 m, 1 OmniLight, label "CANGKRUK PUTRI", sandal di luar pintu (2 × silinder pipih) |
| — | Ranjang susun ×5 (= 10 kasur) | **TIDAK ADA — 0 buah** | — | **Temuan penting:** kapasitas "5 kasur susun = 10 santri" hanya tertulis sebagai KOMENTAR di header `_cangkruk_putri` ("isi sebenarnya di map interior terpisah") — map interior terpisah itu BELUM DIBUAT, tidak ada file `interior_cangkruk_putri.gd`, tidak ada fungsi ranjang susun di mana pun, dan `main.gd` tidak punya wiring pintu/teleport ke Cangkruk Putri. Pintu cangkang saat ini tidak mengarah ke mana-mana. |

**Subtotal Cangkruk Putri: 0 unit perabot interior.**

---

## 5. Kelas, Asrama, Kantor Ustadzah, Madrasah, Studio — cangkang saja, interior KOSONG

Sumber: `kampus_putri.gd` `_gedung` (generik, dipakai 5 gedung) + grep `main.gd` (nol hasil untuk kelimanya — tidak ada wiring pintu/interior).

| Ruangan | Posisi | Ukuran cangkang | Isi cangkang (semua primitif) | Perabot interior |
|---|---|---|---|---|
| Kelas Putri | (130, 0) | 10 × 8 m, tinggi 3,6 m, pintu S | Lantai, 4 dinding krem, atap datar zamrud + lis emas, 4 jendela kotak (box emas + box zamrud gelap), ambang + lis pintu, label "KELAS PUTRI" | **0 — tanpa meja-kursi belajar, tanpa papan tulis/smartboard, tanpa rak, tanpa lampu interior** |
| Asrama Putri | (152, 0) | 12 × 8 m, tinggi 4,0 m, pintu W | Sama (pola `_gedung`) | **0 — tanpa kasur/ranjang, tanpa lemari, tanpa lampu interior** |
| Kantor Ustadzah | (150, −28) | 8 × 6 m, tinggi 3,4 m, pintu W | Sama (pola `_gedung`) | **0 — tanpa meja kerja, kursi, lemari arsip, papan, lampu interior** |
| Madrasah | (152, −12) | 10 × 8 m, tinggi 3,8 m, pintu W | Sama (pola `_gedung`) | **0 — tanpa meja-kursi, papan, rak, lampu interior** |
| Studio | (166, −12) | 10 × 8 m, tinggi 3,6 m, pintu N | Sama (pola `_gedung`) | **0 — tanpa meja, kursi, peralatan, lampu interior** |

Catatan: kelima gedung ini bahkan tidak punya OmniLight di dalam cangkang (berbeda dengan Cangkruk Putri dan Musholla yang punya 1 lampu). Pintu-pintu mereka saat ini tidak mengarah ke interior mana pun — pemain tidak bisa masuk.

**Subtotal 5 gedung: 0 unit perabot interior.**

---

## 6. Elemen yang HILANG (bukan balok — tidak ada mesh sama sekali)

| # | Elemen | Ruangan | Bukti | Catatan |
|---|---|---|---|---|
| 1 | Kursi Kyai | Surau | `main.gd:410` — NPC Kyai punya `"kursi": InteriorSurau.ke_dunia(Vector3(5.6, 0, -305.0))`; `npc.gd:128-133` — NPC duduk di posisi itu. `interior_surau.gd` TIDAK membangun kursi apa pun. | Kyai duduk di udara kosong di depan mihrab; tidak ada kursi, tidak ada rehal/kitab di depannya |
| 2 | Kursi Ustadzah | Musholla | `interior_musholla.gd:33` `KURSI_USTADZAH := Vector3(65.6, 0, -305.0)`; `main.gd:445`; `npc.gd` sama. `interior_musholla.gd` TIDAK membangun kursi. | Ustadzah Mariyah duduk di udara kosong; komentar file menyebut "duduk di KURSI_USTADZAH membaca kitab" — kitabnya pun tidak ada mesh-nya |

---

## 7. Hitungan akhir

### Total elemen balok/primitif di interior

| Ruangan | Unit perabot | Mesh primitif (visual) | Status |
|---|---|---|---|
| Surau (18 × 14 m) | 34 | 88 | Interior lengkap, semua primitif |
| Musholla Ar-Raudhah (14 × 10 m) | 26 | 32 | Interior lengkap, semua primitif |
| Cangkruk Putra (14 × 10 m) | 15 | 87 | Interior lengkap, semua primitif |
| Cangkruk Putri (10 × 8 m) | 0 | 0 | Cangkang saja; ranjang susun belum ada |
| Kelas Putri (10 × 8 m) | 0 | 0 | Cangkang saja |
| Asrama Putri (12 × 8 m) | 0 | 0 | Cangkang saja |
| Kantor Ustadzah (8 × 6 m) | 0 | 0 | Cangkang saja |
| Madrasah (10 × 8 m) | 0 | 0 | Cangkang saja |
| Studio (10 × 8 m) | 0 | 0 | Cangkang saja |
| **TOTAL** | **75 unit** | **207 mesh primitif** | + 2 kursi hilang (0 mesh) |

Rincian hitungan primitif: Surau 88 (karpet 1, sajadah 15, mihrab 2, smartboard 6, rak 18, meja 27, lampu 12, pilar 4, lis/tiang 3) + Musholla 32 (trim 1, mihrab 1, sajadah 15, smartboard 2, rak 4, meja 3, lampu 2, pilar 4) + Cangkruk Putra 87 (kasur 45, lemari 6, meja 5, jendela 24, karpet 1, lampu 3, lis/tiang 3) = **207**. Label3D (KELUAR, nama gedung, teks Arab) dan OmniLight tidak dihitung sebagai mesh primitif. Struktur ruangan (lantai, dinding, plafon, ambang pintu) tidak dihitung sebagai perabot.

### 5 elemen paling mencolok secara visual (prioritas upgrade)

1. **Karpet Surau — satu kotak datar 17,4 × 13,4 m.** Elemen terbesar di seluruh interior; memenuhi hampir semua yang terlihat saat masuk. Satu lempeng zamrud gelap polos tanpa motif tenun, tanpa pinggiran, tanpa pola saf. Paling murah diganti dampaknya paling besar.
2. **30 sajadah kotak datar (Surau 15 + Musholla 15).** Lempeng tipis 0,65 × 1,15 m tanpa motif mihrab, tanpa pinggiran, tanpa ketebalan/lekuk kain — terlihat seperti ubin hijau, bukan kain. Paling sering terlihat kedua setelah karpet.
3. **5 tempat tidur Cangkruk Putra (45 primitif kotak).** Mendominasi kamar: rangka, kasur, bantal, dan selimut semuanya balok tajam; selimut = balok zamrud yang menutupi setengah kasur seperti papan. Kamar tidur adalah ruangan yang paling lama dilihat pemain (tidur + ganti baju).
4. **Smartboard Surau 4,6 m — papan datar raksasa + layar KOSONG.** Papan terbesar di game; bingkai + layar hanya dua kotak menempel dinding, 4 bola emas di sudut, dan layarnya kini kosong total (RONDE 10) sehingga terlihat seperti papan putih polos. Smartboard Musholla (3,0 m, tanpa bingkai) satu paket masalah yang sama.
5. **Meja sampar Surau ×3 + rak kitab (Surau 2 + Musholla 1).** Meja "oval" hanya silinder dipipih dengan tepi tajam; kitab di atasnya balok warna polos tanpa punggung, tanpa halaman, tanpa judul — 4 kitab identik per meja, 5 per rak. Rak Musholla lebih parah: badannya satu balok pejal, kitab menempel di muka.

**Di luar 5 besar, satu yang paling mencolok karena TIDAK ADA:** Kursi Kyai dan Kursi Ustadzah — dua NPC pimpinan duduk di udara kosong di depan mihrab. Kalau ada satu hal yang langsung terlihat "salah" saat masuk Surau/Musholla, ini dia.

### Catatan untuk rencana upgrade (bukan keputusan)

- Upgrade paling berdampak per usaha: karpet + sajadah (motif/tekstur kain), kasur (lekuk bantal/selimut), smartboard (bingkai + layar berisi), rak + kitab (punggung kitab, rak berongga), lampu Musholla (tambah gantungan + kap — saat ini bola melayang).
- Ruangan kosong (Kelas, Asrama, Kantor, Madrasah, Studio, Cangkruk Putri) butuh desain interior dari nol + wiring pintu di `main.gd` — itu pekerjaan terpisah dari mengganti primitif yang sudah ada, dan ranjang susun putri belum pernah dibangun sama sekali.
- Gaya acuan tetap Asian Boy: permukaan halus membulat, proporsi chibi, warna palet krem/zamrud/emas/jati — bukan sekadar "kotak dengan bevel", melainkan mesh halus seperti karakter.
