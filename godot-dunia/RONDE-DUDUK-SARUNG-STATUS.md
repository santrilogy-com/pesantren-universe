# RONDE DUDUK — REVISI SUSULAN SARUNG TERHAMPAR

**Oleh:** Dara (anggota baru tim Godot, lead: Raka) — 17 Nov 2026 ~21:00 WIB
**Koreksi Mas:** 17 Nov 2026 ~20:57 WIB — "Kalau duduk bersila itu sarungnya terhampar.."
**Status:** SELESAI (kode + tes), foto S1–S4 diambil, menunggu verdict Mas.
**JANGAN deploy.** Folder v2 tidak disentuh.

## Masalah (foto D1/D2, Ronde Duduk 19:20 WIB)

Saat bersila, sarung terbaca seperti lonceng/kerucut tegak yang mengembang,
bukan kain yang menghampar di lantai sekeliling kaki:

- Siluet trapesium sempit: radius atas 0,24 → radius bawah 0,348, tinggi
  0,36 — seperti kap lampu, bukan kain terhampar.
- Rim bawah sarung MELAYANG 4,8 cm di atas lantai (diukur headless,
  sampling permukaan asli — bukan tebakan).
- Hem (bola pipih di bawah sarung) juga melayang: titik terendahnya
  2,3 cm di atas lantai, jadi ada celah + bayangan di bawah hem (kelihatan
  di D2 samping).

## Yang diubah (HANYA `scripts/player.gd`)

Satu konstanta: `PAKAIAN_DUDUK`. `PAKAIAN_DEFAULT` / `PAKAIAN_TIDUR` /
`PAKAIAN_ABAYA_*` TIDAK berubah. `scripts/npc.gd` TIDAK disentuh
(Kyai memakai konstanta yang sama — lihat catatan di bawah).

| Konstanta | Lama | Baru | Alasan |
|---|---|---|---|
| `sarung_scale` | (1.20, 0.45, 1.20) | **(1.70, 0.45, 1.70)** | Radius bawah 0,348 → 0,493 (diukur 0,529 dari sumbu, lihat bawah): menutupi lutut bersila (lutut di radius ~0,30) + menyebar ke samping. Skala y TETAP 0,45 supaya tepi atas sarung tetap di 0,83 — kitab pangku menulis (tepi bawahnya y 0,78) tetap terselip di bukaan sarung, tidak melayang. |
| `sarung_y` | 0.68 | **0.65** | Rim bawah lokal 0,68−0,18=0,50 → 0,65−0,18=0,47; saat badan condong 0,08 (duduk), rim dunia ~0,01 — menyentuh lantai. |
| `hem_scale` | (1.20, 0.25, 1.20) | **(1.70, 0.20, 1.70)** | Hem ikut melebar (radius 0,493) + lebih pipih (setengah-tinggi 0,058): kubah bawah jadi lensa pipih — hamparan, bukan bola. |
| `hem_y` | 0.52 | **0.50** | Titik terendah hem: −0,014 (0,48) → +0,006. Catatan: 0,48 masih menembus 1,4 cm karena titik terendah elipsoid miring bukan di kutubnya. |
| `trim_y` | 0.54 | **0.50** | Lis emas mengikuti hem. (Lis tetap tersembunyi di dalam sarung yang melebar — radius lis 0,29 < 0,493; lihat "Yang TIDAK diubah".) |

Perubahan diukur, bukan ditebak: rim bawah duduk pemain 0,048 → **0,006**,
hem −0,004 (kotak) / +0,023 (permukaan asli) → **+0,006**, radius bawah
0,348 → **0,529** (0,493 jari-jari rim + condongan mendorong tepi depan
sedikit ke depan).

## Yang TIDAK diubah (dan kenapa)

- **Abaya putri (`PAKAIAN_ABAYA_DUDUK`): TIDAK diubah.** Foto D3 membuktikan
  abaya TIDAK punya masalah yang sama: gamis panjang 1,32 m itu memang
  mengembang ke lantai (hem dunia ~0,04) dan terbaca sebagai gaun panjang,
  bukan lonceng melayang. Mas mengoreksi SARUNG.
- **Lis emas (trim) tidak diperbesar.** `_lerp_pakaian` (player.gd) dan
  `_terapkan_pakaian` (npc.gd) hanya me-lerp posisi Y trim, bukan skalanya;
  memperbesar trim butuh kunci baru di 4 konstanta + 2 fungsi lerp. Lis
  emas 4 cm itu detail kecil yang sudah tersembunyi di balik hem sejak
  awal; memperbesarnya berisiko tidak konsisten antara pemain dan Kyai.
  Kalau Mas merasa lis emasnya hilang, itu tindak lanjut kecil.
- **Pose duduk (paha −0,85, lutut +2,30, turun −0,42, condong) TIDAK
  disentuh** — itu revisi Raka yang sudah di-ACC jalurnya.
- **Motif batik parang tetap terbaca** — kompresi vertikal tekstur sama
  seperti sebelumnya (skala y 0,45 tidak berubah); hanya radius yang
  melebar, jadi pita parang merenggang horizontal, tidak gepeng.

## Hasil uji

### `test_sarung.gd` — BARU (ronde-duduk/skrip/, 19 cek)
Mengukur PERMUKAAN ASLI mesh (sampling 48 titik lingkaran rim silinder +
13×25 titik permukaan bola hem, ditransformasi `global_transform`) — AABB
kotak TIDAK dipakai karena melebih-lebihkan sampai 4 cm pada benda miring.
Dijalankan headless: `godot --headless --path . test_sarung.tscn`.

**SEMUA LULUS (19/19), 17 Nov ~21:05 WIB:**

| Cek | Hasil |
|---|---|
| duduk pemain: rim sarung tidak tembus lantai | min Y **+0,006** |
| duduk pemain: hem tidak tembus lantai | min Y **+0,006** |
| duduk pemain: hem menyentuh lantai | +0,006 ≤ 0,03 ✓ |
| duduk pemain: radius bawah melebar | **0,529** (lama 0,348) |
| duduk pemain: radius tidak balon | 0,529 ≤ 0,55 ✓ |
| duduk: tidak NaN | ✓ |
| duduk: lutut di atas lantai | y −0,016 ✓ |
| duduk: sandal di atas lantai | y −0,013 ✓ |
| menulis: rim sarung clip ≤ 7 cm | −0,060 ✓ (lihat catatan) |
| menulis: hem clip ≤ 7 cm | −0,046 ✓ (lihat catatan) |
| berdiri: sarung scale kembali (1,1,1) | ✓ |
| berdiri: sarung_y kembali 0,50 | ✓ |
| berdiri: hem_y kembali 0,12 | ✓ |
| berdiri: hem scale kembali (1, 0,25, 1) | ✓ |
| Kyai duduk baca | ✓ |
| Kyai: rim sarung clip ≤ 7 cm | −0,057 ✓ (lihat catatan) |
| Kyai: hem clip ≤ 7 cm | −0,043 ✓ (lihat catatan) |
| Kyai: radius bawah melebar | 0,577 ✓ |

### `test_duduk.gd` — regresi (33 cek, tidak diubah)
Dijalankan ulang headless setelah perubahan: **SEMUA LULUS (33/33)** —
pose duduk/menulis/berdiri, Kyai + Ustadzah duduk baca, sajadah + rehal
tetap benar. Tidak ada regresi dari revisi duduk 19:20 WIB.

## CATATAN PENTING — batas konstanta bersama (untuk Raka)

**Satu konstanta `PAKAIAN_DUDUK` tidak bisa membuat rim sarung menyentuh
lantai di SEMUA pose sekaligus — ini struktural, bukan salah angka:**

- Duduk pemain condong 0,08 rad; menulis + Kyai duduk-baca condong 0,20 rad.
- Rim depan sarung lebar turun sebesar `radius × sin(condong)`: pemain
  0,493×0,08 ≈ 0,04 m, menulis/Kyai 0,493×0,20 ≈ 0,10 m.
- Selisihnya ~5–6 cm untuk radius berapa pun yang berguna (di 0,35 pun
  selisihnya ~5 cm). Jadi: kalau rim pemain pas di 0, rim Kyai/menulis
  PASTI −0,06; kalau rim Kyai pas di 0, rim pemain melayang +0,05
  (itulah keadaan lama — konstanta lama ternyata ter-tuning ke Kyai).
- Yang dipilih: **tuning ke pemain duduk** (subjek koreksi Mas di foto
  D1). Konsekuensinya: tepi depan sarung Kyai + pemain-menulis menembus
  lantai 4–6 cm (terukur: Kyai rim −0,057 / hem −0,043; menulis rim
  −0,060 / hem −0,046).
- Kenapa ini (kemungkinan) tidak kelihatan di foto: tepi depan yang
  menembus itu TERTUTUP — pada Kyai di balik rehal + kitab, pada menulis
  di balik kitab pangku; sisanya tertutup lantai itu sendiri (benda di
  bawah y=0 tidak terlihat dari kamera di atas lantai). Yang terlihat
  dari kamera adalah permukaan sarung bertemu lantai — terbaca sebagai
  kain menempel di lantai, bukan karakter tenggelam. Verdict akhir dari
  foto S3/S4 di bawah.
- **Tindak lanjut kalau Mas / Raka menilai clip itu mengganggu:**
  konstanta duduk KHUSUS Kyai (dan/atau menulis) — mis. `PAKAIAN_DUDUK_KYAI`
  di `player.gd` + pemetaan di `npc.gd::_terapkan_pakaian`
  (saat ini npc.gd memetakan `PAKAIAN_DUDUK` mentah). Itu butuh edit
  `npc.gd`, jadi Dara TIDAK mengerjakannya sendiri — menunggu lampu hijau
  Raka. Perkiraan: sarung_y Kyai 0,71 / hem_y 0,56 (rim Kyai ~0,00).

## Foto (sudut persis D1/D2/D4/D6, jam 10.00, xvfb-run)

| Foto | Isi | File |
|---|---|---|
| S1 | Putra duduk, depan 3/4 (= D1) | `ronde-duduk/foto/S1-putra-duduk-depan.png` |
| S2 | Putra duduk, samping (= D2) | `ronde-duduk/foto/S2-putra-duduk-samping.png` |
| S3 | Kyai duduk baca + rehal (= D4) | `ronde-duduk/foto/S3-kyai-duduk.png` |
| S4 | Putra menulis, depan 3/4 (= D6, cek kitab pangku) | `ronde-duduk/foto/S4-putra-menulis-depan.png` |

Skrip: `ronde-duduk/skrip/foto_sarung.gd` (+ `.tscn`).

### Penilaian Dara dari foto (SEBELUM verdict Mas)

**S1 (depan 3/4) — PERBAIKAN JELAS vs D1.** Sarung kini hamparan kain yang
lebar dan rendah di lantai sekeliling kaki bersila — bukan lagi kerucut
lonceng. Hem bertemu lantai di depan dan samping, motif batik parang tetap
terbaca jelas, tangan tetap terlihat di pangkuan. D1: trapesium sempit
melayang + bayangan celah di bawah hem. S1: gundukan pipih lebar, kontak
lantai terbaca.

**S2 (samping) — PERBAIKAN JELAS vs D2.** Profil samping kini lereng
landai dari pinggang ke lantai, bukan dinding kerucut tegak. Tepi bawah
hem menyentuh jalan di depan dan belakang; tidak ada lagi celah melayang
yang terlihat di D2.

**S3 (Kyai) — BAGUS, clip terukur TIDAK KELIHATAN.** Sarung Kyai kini
gundukan batik gelap yang lebar di atas sajadah (D4: kerucut sempit).
Tepi depan yang terukur −0,057 di bawah lantai TIDAK terlihat dari sudut
ini: tertutup rehal + kitab di depan, dan sisi-sisinya bertemu lantai
dengan bersih. Tidak ada kesan karakter tenggelam.

**S4 (menulis) — TIDAK ADA REGRESI.** Kitab pangku tetap bertumpu benar
di pangkuan (tepi belakangnya terselip di bukaan sarung, tangan di atas
kitab), tidak melayang. Gundukan sarung terhampar sama seperti S1; clip
depan terukur (−0,060) tidak kelihatan — tertutup kitab + lantai.

**Catatan jujur (kecil):**
- Lis emas di ujung sarung TIDAK terlihat lagi (sudah diprediksi: lis
  radius 0,29 tersembunyi di dalam sarung yang melebar ke 0,493).
  Bukan cacat bentuk — tapi kalau Mas kangen garis emasnya, itu
  tindak lanjut kecil (skala trim, lihat atas).
- Gundukan S1 terbaca agak "pancake" — sangat pipih dan lebar. Tapi
  itu memang arti harfiah "terhampar"; kalau Mas mau lebih ber-volume,
  sarung_scale y bisa naik 0,45 → 0,55 (tepi atas naik, kitab tetap aman).

## File

- Diubah: `godot-dunia/scripts/player.gd` (konstanta `PAKAIAN_DUDUK` +
  komentar, baris ~23–45).
- Baru: `ronde-duduk/skrip/test_sarung.gd` + `test_sarung.tscn`,
  `ronde-duduk/skrip/foto_sarung.gd` + `foto_sarung.tscn`,
  `ronde-duduk/foto/S1..S4.png`, doc ini.
- Salinan `test_sarung.*`, `test_duduk.*`, `foto_sarung.*` di root
  `godot-dunia/` HANYA untuk jalan (res://) — **dihapus dari root setelah
  selesai**, arsip tetap di `ronde-duduk/skrip/`.
- TIDAK disentuh: `main.gd`, `ui.gd`, audio, langit, `npc.gd`,
  `PAKAIAN_ABAYA_*`, folder v2, file agen lain.

---

## Susulan: meja sampar menembus Kyai (Raka, 17 Nov ~21:34–21:50 WIB)

**Koreksi Mas (21:34 WIB, setelah lihat foto S3): "Ini kok tembus meja?"**
Diagnosis Xam terkonfirmasi: BUKAN rehal — rehal + kitab + tangan Kyai
sudah benar. Yang menembus = **MejaSampar_3** (meja bundar rendah lesehan
dengan kitab) di belakang Kyai.

**Akar masalah (diukur, bukan ditebak):** MejaSampar_3 di (6,5, −305,0),
hanya 0,9 m dari kursi Kyai (5,6, −305). Papan ovalnya radius-x 1,1 m —
tepi baratnya sampai x=5,4, melewati pusat Kyai sejauh 0,2 m; bahkan kaki
barat meja (x=5,7) berada di dalam radius sarung Kyai (0,577 m). Tes
kontrol membuktikan posisi lama menembus sedalam **0,377 m**.

**Perbaikan (satu baris, `scripts/interior_surau.gd`):** MejaSampar_3
digeser tenggara ke **(7,3, −303,5)** — celah elips–lingkaran terukur
**0,825 m** dari sarung Kyai (aturan cek_tembus ala @jipraks); bebas rak
kitab timur (tepi meja 8,4 < 8,625), bebas grid sajadah (tepi timur 2,6),
di dalam ruangan. Posisi duduk Kyai TIDAK diubah.

**Verifikasi:**
- Tes headless baru `test_meja_kyai.gd` — **5/5 LULUS** (meja ada,
  celah > 0,3 m, kontrol posisi lama menembus, kaki bebas, dalam ruangan
  + bebas rak). Arsip: `ronde-duduk/skrip/test_meja_kyai.*`.
- Foto ulang S3 dari sudut yang sama: **`S3b-kyai-duduk-meja-geser.png`**
  (nama baru supaya cache HP Mas tidak menampilkan foto lama) — Kyai
  duduk baca di rehal, sarung terhampar, meja bundar terpisah jelas di
  kanan-belakang dengan jarak karpet hijau di antaranya. Dicek Raka.
- File sementara dihapus dari root proyek; file agen lain yang masih
  jalan (adzan/bubble/fullscreen) TIDAK disentuh.
