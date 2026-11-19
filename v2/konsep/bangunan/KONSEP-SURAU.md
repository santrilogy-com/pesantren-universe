# Konsep Surau v2 — Lembar Konsep 2D

**Status: KONSEP UNTUK DINILAI MAS — belum ada yang dibangun 3D.**
**Tanggal:** 17 November 2026 · **Arsitek:** Arsa
**Aturan baru v2:** digambar dulu → Mas nilai → baru dibangun 3D kalau ACC.
Game v1 dibiarkan apa adanya (live, Ronde 23) dan tidak disentuh.

## File

| File | Isi |
|---|---|
| `surau-v2-konsep.png` | Lembar konsep (1080 × 2600, 2× render 2160 × 5200) — tampak depan, tampak samping, tiga-perempat, denah, palet |
| `surau-v2-konsep.svg` | Sumber vektor (bisa diedit / dipakai ulang) |
| `gambar_surau.py` | Generator parametrik lembar ini (skala & ukuran tinggal diubah angkanya) |
| `render.mjs` | Render SVG → PNG via Chrome Headless Shell |
| `KONSEP-SURAU.md` | Catatan ini |

Cara gambar: ilustrasi vektor datar (SVG, digambar dari angka — bukan AI
generatif), supaya **ukurannya terukur dan warnanya persis hex palet**.
Tampak depan 40 px = 1 m, tampak samping 30 px = 1 m, tiga-perempat
isometri 16 px = 1 m.

## Isi lembar

- **A · Tampak depan** (dari timur / jalan): portal lengkung lancip, plakat
  مصلى الإخلاص, pintu jati dua daun + kisi ukir, serambi 3 lengkung,
  3 anak tangga batu, kubah utama + 4 kubah kecil, menara sudut tenggara.
- **B · Tampak samping** (dari selatan): 3 jendela lengkung, tempat wudu.
- **C · Tiga-perempat** (dari tenggara): muka timur + muka selatan sekaligus,
  supaya bentuk atap dan posisi menara terbaca.
- **D · Denah & palet**: denah 20 × 16 m (mihrab barat, mimbar, 6 saf,
  rak kitab utara & selatan, pintu timur, serambi, menara, wudu) + 6 warna
  palet dengan kode hex + ukuran jejak.

## Yang dipertahankan dari v1 (desain ACC di DESAIN-ARSITEKTUR.md)

- Bahasa bentuk: kubah bawang zamrud + bulan sabit emas, 4 kubah kecil,
  menara ramping, lengkung lancip, lis emas, palet krem/zamrud/emas/jati.
- Ukuran: jejak luar 20 × 16 m, interior 18 × 14 m, dinding 5 m,
  puncak kubah ±11 m, menara ±14 m, serambi 3 m, 3 anak tangga.
- Denah: mihrab di tengah dinding barat (kiblat), mimbar kayu di sisi utara
  mihrab, 6 baris saf menghadap barat, rak kitab utara & selatan,
  pintu menghadap timur/jalan, plakat مصلى الإخلاص.
- Tutup menara **zamrud** (bukan emas) — sesuai catatan §6 desain v1
  (di gambar perspektif v1 tutup menara sempat ter-render emas; yang dipakai
  tetap zamrud kecuali Mas minta emas).

## Yang diubah dari v1 (dan kenapa)

1. **Gambarnya digambar dari angka, bukan render AI.** Gambar v1 dulu
   (media-generation-01/02) adalah render AI bergaya cat air — cantik tapi
   tidak terukur dan warnanya tidak persis palet. Lembar v2 ini vektor datar
   dengan skala tertulis, jadi tukang 3D bisa mengikuti angkanya persis.
2. **Serambi digambar eksplisit di tampak depan.** Di gambar depan v1,
   serambi tersembunyi di balik portal — pembangun 3D tidak bisa melihat
   kedalamannya. Di v2, pelat serambi + 2 tiang ramping + 3 lengkung
   digambar jelas (kedalaman 3 m).
3. **Tempat wudu digambar.** Desain v1 menyebut tempat wudu di sisi selatan
   tapi tidak pernah menggambarnya. Di v2 ada di tampak samping (ujung barat)
   dan di denah.
4. **Keempat kubah kecil terlihat.** Gambar depan v1 hanya menunjukkan 2
   kubah kecil (2 di belakang tersembunyi). Di tampak tiga-perempat v2,
   keempat posisi sudutnya terlihat.
5. **Posisi plakat ditetapkan.** Gambar v1 tidak menunjukkan plakat dengan
   jelas. Di v2, plakat مصلى الإخلاص di atas lengkung portal, di blok portal.
6. **Warna datar dengan hex persis.** Tidak ada gradasi cat air — setiap
   bidang memakai hex palet persis (kecuali bayangan tipis zamrud gelap
   #04402F pada rusuk kubah dan krem gelap #EADFC6 pada muka yang teduh).
7. **Denah + palet + ukuran dalam satu lembar.** Supaya Mas menilai bentuk,
   ukuran, dan warna sekaligus tanpa membuka dokumen lain.

## Yang TIDAK diputuskan di lembar ini

- **Posisi Surau di peta v2** — mengikuti sketsa tata letak Gilang
  (`v2/konsep/peta-tata-letak-v2.png`), bukan lembar ini. Lembar ini hanya
  memberi bentuk dan jejak bangunannya (20 × 16 m + serambi 3 m).
- **Interior detail** (karpet, sajadah, mimbar, rak kitab, smartboard) —
  mengikuti audit interior v1; digambar terpisah kalau Mas minta.

## Keputusan yang perlu Mas buat

1. **ACC bentuk & proporsi Surau ini?** (kubah bawang, 4 kubah kecil,
   menara, portal, serambi) — atau ada yang mau diubah?
2. **Tutup menara: kubah zamrud** (seperti digambar) **atau emas?**
3. **Serambi: 3 lengkung seperti digambar**, atau mau lebih dalam / lebih lebar?
4. **Jendela depan: 2 tiap sisi seperti digambar**, atau muka depan polos
   hanya portal saja?
5. **Tempat wudu di sisi selatan — tetap, pindah, atau hapus?**
6. **Kubah: bawang seperti digambar, atau lebih bulat?**
7. **Denah: 6 saf + rak kitab utara & selatan, mihrab barat + mimbar — tetap?**
8. **Kalau ACC: bangun Surau 3D dulu** (model hero), **atau gambar lembar
   Musholla dulu** baru bangun keduanya sekaligus?

## Kalau Mas ACC — langkah berikutnya

1. Bima membangun Surau sebagai model 3D hero mengikuti lembar ini
   (target ≤ 40 ribu tris, sesuai RENCANA-UPGRADE-VISUAL.md §2.1).
2. Raka mengimpor + collision + foto dari game untuk cek ulang Mas
   sebelum ganti yang live.
3. Lembar konsep Musholla digambar dengan cara yang sama (Arsa).

## Catatan jujur

- Tampak tiga-perempat adalah isometri sederhana (bukan perspektif
  fotoreal) — bentuk atap dan posisi menara terbaca, tapi kedalaman
  serambi di gambar itu lebih datar dari aslinya.
- Lengkung di gambar ini adalah lengkung lancip yang disederhanakan
  (dua busur bertemu di puncak) — di 3D nanti tetap terbaca sebagai
  lengkung masjid.
- Kisi jendela/pintu digambar sebagai pola diagonal sederhana —
  motif ukir akhirnya diputuskan saat pembangunan 3D (bukan di lembar ini).
