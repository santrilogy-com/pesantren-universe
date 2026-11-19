# SURAU v2 — STATUS 3D

**Konsep:** `v2/konsep/bangunan/surau-v2-konsep.png` + `KONSEP-SURAU.md` (DI-ACC Mas 17 Nov ~17:40 WIB, "ACC, lanjut ke 3D")
**Dibangun:** 17 Nov 2026, Blender 4.5.16 LTS headless, Cycles CPU
**Skrip:** `build_surau.py` (parametrik, dari angka konsep + `gambar_surau.py`)
**Hasil:** `surau-v2.blend` (2,23 MB) + `surau-v2.glb` (841 KB, engine-agnostic: Godot / Three.js)
**Render:** `render/` — depan, samping, tiga-perempat (1024px, 96 sampel), interior (768px, 64 sampel) + interior sudut diagonal ke-2 (`surau_interior2.png`, 768px, 64 sampel)

## Revisi 1 — rak buku + dampar santri (17 Nov ~20:17 WIB, DI-ACC Mas 👍)

Mas: "Bagus bima.. saya suka. Cuma di surau perlu ada rak buku dan dampar santri ya" → ditambah di interior (edit `build_surau.py`, tidak bangun ulang dari nol):

- **Rak buku (2×):** rak jati 8 m × 0,45 m × 1,8 m menempel dinding utara (Y +6,75) & selatan (Y −6,75) — ganti 2 kotak polos lama. Rangka jati: 2 panel samping, papan atas, plinth, panel belakang, 2 papan tengah. **3 baris kitab warna-warni per rak** (satu mesh gabungan per baris, ~85 buku/baris, tebal 0,05–0,09 m, tinggi 0,26–0,38 m, 10 warna sampul, sesekali ada celah + 1–2 buku miring). Total ±510 buku.
- **Dampar santri (4×):** bangku kayu rendah 3,0 × 0,9 m, tinggi duduk 0,25 m, sumbu utara-selatan (duduk menghadap barat/kiblat). Papan jati + 4 kaki + apron + **3 kitab tergeletak di atas tiap dampar**. Posisi: timur (7,3, ±4,5) & barat (−7,3, ±4,5) — di luar garis saf (X ±5) dan jalur pintu (Y −2..2), tidak menabrak saf.
- **Ukuran baru:** 192 objek (dari 128), 16.967 verts, **30.922 tris** (dari 22.714 — masih ≤ 40.000 hero ✅), GLB 841 KB → 1,36 MB.
- **Render ulang:** `surau_interior.png` (sudut lama, ke arah mihrab: 2 dampar barat + rak di tepi kiri/kanan terlihat) + `surau_interior2.png` (sudut diagonal baru dari barat-daya: rak utara tampak dari depan, dampar timur terlihat, pintu + saf terbaca). Skrip sudut ke-2: `render_interior2.py`.
- **Verifikasi visual:** rak terbaca sebagai rak buku sungguhan (kitab warna-warni rapat, 3 baris); dampar rapi, kitab di atasnya terlihat. **Artefak lama tetap ada:** setengah lingkaran emas kecil di tengah lantai (kedua render) — kemungkinan pantulan lampu titik pada garis saf emas, minor, bukan cacat geometri; Mas ACC apa adanya.
- **Status revisi: SELESAI + DI-ACC Mas (👍 17 Nov ~20:17 WIB).**

## Ukuran akhir

| | Nilai | Target |
|---|---|---|
| Objek | 192 (128 + 64 rak/dampar) | — |
| Verts (evaluated) | 16.967 | — |
| **Tris (evaluated)** | **30.922** | ≤ 40.000 (hero) ✅ masih di bawah |
| GLB | 1,36 MB (dari 841 KB) | — |
| Jejak | 20 × 16 m | 20 × 16 ✅ |
| Dinding | 5 m | 5 m ✅ |
| Interior | 18 × 14 m | 18 × 14 ✅ |
| Kubah utama | Ø 9 m, puncak 11 m | ±11 m ✅ |
| Menara | puncak 14 m, tutup zamrud | ±14 m ✅ |
| Serambi | 3 m dalam, 3 lengkung | 3 m ✅ |

## Sesuai konsep

- Kubah bawang zamrud + sabit emas (finial: batang + bola + sabit), 4 kubah kecil (±8,5, ±6,5)
- Menara sudut tenggara (10,85, −8,85), balkon + pagar emas z=9, tutup zamrud
- Portal 6 m × 8 m, lengkung lancip (lebar 4,8 m, puncak 6,9 m), plakat **مصلى الإخلاص** di atas lengkung (tekstur Arab terverifikasi terbaca benar, emas di atas zamrud)
- Pintu jati dua daun + kisi ukir di atas pintu
- Serambi 3 lengkung (tabung emas), 2 kolom + tiang ujung, lantai batu, atap krem + lis emas, 3 anak tangga batu, 2 pot tanaman
- Jendela lengkung berkisi: 4 depan (Y ±4,2, ±6,0), 3 selatan + 3 utara (X −6, 0, +6), ambang batu
- Tempat wudu ujung barat-selatan: bak batu + tutup jati + 3 keran emas
- Interior dasar: lantai krem muda 18×14, mihrab barat (panel zamrud + trim emas), mimbar jati 3 anak tangga di utara mihrab, 6 garis saf emas, rak kitab jati utara & selatan
- Palet HEX PERSIS: krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A, batu #B8B2A4, krem muda #FAF4E6. Material matte, cahaya hangat. Gaya halus (bevel di objek kecil, kubah/silinder mulus), bukan primitif balok.

## Ketidakkonsistenan lembar konsep (diputuskan saat bangun)

1. **Lebar muka timur:** elevasi depan menggambar 20 m, tapi denah + isometri bilang 16 m → ikut denah/iso/brief (jejak T-B 20 m, U-S 16 m; muka timur 16 m).
2. **Lebar blok portal:** elevasi depan 8 m vs iso/denah 6 m → pakai 6 m.
3. **Posisi menara:** elevasi bertentangan dengan denah/iso → ikut denah/iso/`DESAIN-ARSITEKTUR.md`: sudut tenggara, pusat (10,85, −8,85).
4. **Elevasi samping tampak tercermin** (ujung serambi/wudu tertukar) → ikut denah/catatan: wudu di sisi selatan, ujung barat.

## Masalah render yang ditemukan & diperbaiki

1. **Muka hitam di sudut bangunan** (render pertama): kotak dinding tumpang tindih di sudut (muka koplanar) + bevel. Perbaikan: dinding timur/barat dipendekkan jadi Y −7..7 (terjepit di antara dinding utara/selatan), bevel dinding/atap/portal dilepas.
2. **Pita hitam di tepi atap** (tiga-perempat): muka tegak pelat atap yang menjorok/inset jatuh di bayangan dan render hitam; material emas pun tetap hitam. Perbaikan: pelat atap dibuat tipis (0,14 m) dan rata (20×16, puncak z 4,99) sehingga muka tegaknya tersembunyi di balik lis emas; sisi tegak juga diberi material emas. Pita hitam HILANG (terverifikasi per-piksel).
3. **Tris 45.232 → 22.714:** tabung lengkung (`resolution_u=12`) masing-masing 2.112 poli. Perbaikan: `resolution_u=2`; segmen kubah dikurangi (utama 48→40, kecil + tutup menara 32→24). Bentuk tidak berubah.
4. **Tekstur plakat tercoreng** (teks Arab jadi garis-garis): UV default kubus hanya memetakan 1/16 tekstur per muka. Perbaikan: UV muka +X dipetakan ulang ke seluruh tekstur; terverifikasi close-up: "مصلى الإخلاص" terbaca benar (tidak terbalik).
5. **Render interior lambat** (>15 menit di 96 sampel, sekali terputus restart runtime): diselesaikan di 64 sampel + batas bounce (difus 3, glossy 2, maks 4), ~9 menit.
6. **Framing:** kamera depan/samping awal memotong menara → kamera dimundurkan (40 m / 45 mm) agar menara masuk frame.

## Catatan / penyimpangan kecil

- **Kubah dari depan** terbaca segitiga kecil (hanya 3 m teratas terlihat di atas blok portal 8 m) — sesuai elevasi depan konsep, tapi kubah kurang dominan dari depan dibanding gambar isometri konsep.
- **Langit-langit interior polos** (krem rata, tanpa balok/interior kubah) — interior masih "dasar" sesuai brief; detail perabot menyusul, jangan dulu.
- **Artefak kecil:** setengah lingkaran emas kecil di lantai interior (tengah gambar) — belum teridentifikasi, minor; kemungkinan ujung garis saf / pantulan lampu. Perlu dicek kalau interior didetailkan.
- **Teks plakat** terbaca jelas dari dekat, tapi di render satu bangunan penuh (1024px) hanya terbaca garis emas — wajar pada skala itu; teksturnya sendiri benar.
- **Pelat atap** kini 0,14 m (bukan 0,3 m) dan rata dengan dinding — perubahan detail konstruksi demi menghilangkan pita hitam; hasil terlihat (garis lis emas di tepi atap) sesuai konsep.

## File

- `build_surau.py` — skrip bangun (baca dulu sebelum ubah)
- `surau-v2.blend`, `surau-v2.glb`
- `render/surau_depan.png`, `surau_samping.png`, `surau_tiga_perempat.png`, `surau_interior.png`, `surau_interior2.png` (sudut diagonal, rak + dampar)
- `render_surau.py` (skrip render awal), `render_verifikasi.py`, `render_interior.py`, `render_interior2.py`, `render_final_eksterior.py`
- `plakat.png` (مصلى الإخلاص), `kisi.png` (kisi diagonal emas)

## Status

**SELESAI — Surau v2 DI-ACC Mas (17 Nov ~17:40) + Revisi 1 (rak buku + dampar) DI-ACC Mas (17 Nov ~20:17 WIB, 👍).** Jangan lanjut ke bangunan lain sebelum Mas perintahkan; tugas berikutnya Bima: lembar konsep 5 elemen lingkungan v2.

## Revisi 2 — Pintu dibuka (Bima, 17 Nov ~23:00 WIB)

- Masalah: di foto alpha F1 pintu Surau GLB tampak tertutup (panel jati) — pemain tampak menembus pintu saat teleport.
- Perbaikan: dua daun jati `SR_Pintu_Kiri/Kanan` dibuka ±110° ke luar (terlipat ke dinding luar serambi, kenop ikut berputar); garis tengah emas dihapus; kisi di atas pintu tidak disentuh.
- File: `fix_pintu_surau.py` (skrip perbaikan) + `render_pintu_verifikasi.py`; `surau-v2.blend` + `surau-v2.glb` diekspor ulang (GLB 1.356.812 byte).
- Verifikasi: `render/pintu_pintu_dekat.png` + `render/pintu_pintu_jauh.png` — bukaan pintu gelap, interior terlihat, daun jati terlipat di sisi bukaan. Pintu terbaca TERBUKA dari luar.
- **Catatan integrasi: GLB baru masih di `model-3d/surau/` — BELUM masuk proyek Godot v2. Perlu disalin ke `v2/godot-dunia/` saat export ulang (Rangga, revisi Surau lurus) — jangan deploy alpha lama dengan GLB pintu tertutup.**
