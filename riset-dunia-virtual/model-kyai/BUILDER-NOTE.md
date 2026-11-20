# BUILDER-NOTE — Karakter Ust. Aqsal (GLB hasil Blender)

Untuk builder artifact web "Karakter Ust. Aqsal" (slug `karakter-ust-aqsal`).
Baca ini sebelum mengedit artifact. File GLB sudah jadi dan terverifikasi.

## File

- **GLB:** `~/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/ust-aqsal.glb`
- **Ukuran:** 4,22 MB (target ≤15 MB ✓)
- **Tris:** 58.525 (target ≤60.000 ✓ — mepet, sisa 1.475 tris; jangan tambah
  geometri lagi tanpa decimate dulu)
- **Mesh:** 30 | **Material:** 13 (semua Principled BSDF, kompatibel glTF)
- **Tekstur:** 7 gambar (atlas kulit 2048px + `lipatan-jubah.png` 512×64)
- **Blend (sumber):** `ust-aqsal.blend` (folder yang sama)
- **Render verifikasi:** `kyai-depan.png`, `kyai-samping.png`, `kyai-wajah.png`
- **Versi GLB ini:** tahap 12 (perbaikan "balok" Mas 23:55 WIB 20 Nov 2026)

## Cara memuat

- Pakai **GLTFLoader** (Three.js). Model statis (tanpa rig/animasi di GLB).
- **Tinggi:** ±1,90 m (puncak serban ±1,94 m). Kaki di y=0 — letakkan model di
  atas panggung dengan posisi y=0.
- **Arah hadap:** wajah menghadap **+Z** (glTF). Kamera depan bawaan:
  posisi kira-kira (0, 1,35, 3,4), target (0, 1,05, 0).
- Kamera yang sudah ada bisa dipakai ulang (Depan/Samping/Belakang/Wajah/Tubuh):
  - Depan: (0, -3.4, 1.35) → dalam Three.js (0, 1.35, 3.4), target (0, 1.05, 0)
  - Samping: (3.4, 1.35, 0.35) → Three.js (3.4, 1.35, 0.35), target (0, 1.05, 0)
  - Wajah: (0.25, 1.72, 0.9) → Three.js, target (0, 1.66, 0)
- Putar 360°: putar model (atau kamera orbit) seperti sebelumnya.
- **PENTING — pencahayaan artifact:** jangan terlalu terang. Jubah putih
  (0.92) + lampu kuat = lipatan hilang (blown out). Pakai cahaya sedang
  (directional ~1–2 + ambient/hemisphere) supaya lipatan jubah dan jenggot
  gelap terbaca. Jenggot (0.05) memutih kalau lampu terlalu kuat.

## Node & material (untuk kustomisasi)

| Node | Material (warna glTF) | Kustomisasi |
|---|---|---|
| `GEO-jubah` | `MAT-jubah` (Base Color putih × **tekstur garis lipatan** `lipatan-jubah.png`) | **Warna jubah:** ubah `material.color` — warnanya mengalikan tekstur, jadi garis lipatan ikut terbawa (tetap terlihat). Jubah punya 9 lipatan geometri + tekstur garis selaras + hem bergelombang. |
| `GEO-lengan-kiri/kanan` | `MAT-lengan` (0.92, 0.92, 0.90 — putih polos) | Lengan jubah (tabung terpisah, miring keluar). Ikut warna jubah kalau mau — ubah juga `MAT-lengan`. |
| `GEO-serban` | `MAT-serban` (0.90, 0.90, 0.88 — putih) | **5 cincin torus tumpang tindih + tutup kubah + ekor** (satu node). Sembunyikan node = tanpa serban. Terbaca lilitan dari samping & depan. |
| `GEO-jenggot` | `MAT-jenggot` (0.05, 0.04, 0.03 — hitam pekat) | Skala node (panjang/pendek) atau sembunyikan (= halik) |
| `GEO-kumis` | `MAT-jenggot` | **Satu ellipsoid** (bukan dua bola lagi). Ikut jenggot; sembunyikan bila jenggot disembunyikan |
| `GEO-kancing-1..5` | `MAT-kancing` (0.85, 0.85, 0.82) | Kancing di dada jubah |
| `GEO-tutup-dada` | `MAT-gelap` (0.02 — hitam) | Piringan kecil gelap penutup lubang dada; jangan dihapus |
| `GEO-leher-dalam` | `MAT-kulit-polos` (0.55, 0.38, 0.30) | **Baru (tahap 11/12):** piringan kulit r=0.100 di z=1.555, menutup lubang hitam di leher. Jangan dihapus. |
| `GEO-tasbih-01..11`, `GEO-tasbih-rumbai` | `MAT-tasbih` (0.20, 0.10, 0.04 — cokelat) | Tasbih di tangan kanan |
| `maasai-style-herder_head` | `skin` (tekstur atlas 2048px) | Wajah + leher; **jangan** diubah warnanya |
| `maasai-style-herder_eyes` | `eyes` | Mata (mesh bola, tekstur) |
| `maasai-style-herder_body` | `skin` | Badan di balik jubah (cangkang berlubang — tertutup jubah) |
| `maasai-style-herder_sandals` | `shoes` | Sandal |
| `maasai-style-herder_teeth` | `teeth` | Gigi (di dalam mulut, nyaris tak terlihat) |

Catatan: **tidak ada lagi `GEO-kerah`** (dihapus tahap 10) dan **tidak ada
`GEO-ekor-serban` terpisah** (ekor tergabung di `GEO-serban` sejak tahap 9).
Ada **dua entri `MAT-jenggot`** di daftar material GLB (duplikat ekspor,
warnanya sama persis) — tidak berbahaya, abaikan saja.

## Yang TIDAK bisa dipertahankan dari UI lama (jujur)

- **Mode wajah "Tanpa Wajah":** kepala adalah satu mesh dengan wajah
  (mata/hidung/bibir) yang dimodelkan + dicat di tekstur. Tidak ada mesh
  kepala polos pengganti. Opsi ini harus dihapus atau diganti (mis. sembunyikan
  kepala bukan solusi — leher ikut hilang).
- **Serban / Peci / Tanpa:** serban bisa disembunyikan (node terpisah), tapi
  **peci butuh mesh topi baru** — belum ada. Sediakan "Serban / Tanpa" saja,
  atau tambahkan peci sederhana sendiri.
- **Jenggot Panjang / Pendek / Halik:** hanya bisa via skala node
  `GEO-jenggot` (dan kumis) atau sembunyikan. Tidak ada model jenggot panjang.
- **Warna kulit (4 pilihan):** tekstur kulit baked di atlas 2048px — tidak
  bisa diganti lewat swatch. Hapus opsi ini, atau ganti dengan tint
  `material.color` (hasilnya kasar, tidak disarankan).
- **Nama:** tetap bisa (teks UI biasa, tidak terkait model).
- **Warna jubah:** BISA — ubah `MAT-jubah.color` (mengalikan tekstur garis
  lipatan; garisnya ikut terbawa, tetap terlihat). `MAT-lengan` diubah juga
  supaya lengan senada.

## Batasan yang perlu diketahui (jangan dijanjikan ke Mas)

- Wajah model dasar halus seperti manekin (kulit licin, wajah sempit-panjang)
  — mata/hidung/bibir terbentuk, tapi belum semi-realistis penuh. Rambut
  pendek dicat ke tekstur (abu-abu, tertutup serban).
- Jenggot adalah cangkang halus (tanpa helai rambut) — jenggot pendek rapi
  mengikuti profil wajah. Kumis satu ellipsoid di bibir atas. Di render
  Blender dengan lampu studio ia tampak abu-abu; di bawah cahaya normal
  (Three.js) ia gelap/hitam — sudah diverifikasi (`kyai-wajah-redup.png`).
  Jangan menaikkan intensitas lampu artifact terlalu tinggi, nanti jenggot
  memutih lagi.
- Jubah punya 9 lipatan (geometri + tekstur garis, kontras 0.72–0.95) dan hem
  bergelombang — lipatan terbaca halus, bukan garis tegas. Di analisis piksel
  render: variasi kecerahan ~15% (206–245). **Jangan memakai lampu terlalu
  terang** (blown out = lipatan hilang lagi); cahaya sedang adalah kuncinya.
- Serban adalah 5 cincin torus tumpang tindih + tutup kubah + ekor (satu node
  `GEO-serban`) — terbaca lilitan dari depan dan samping.
- Badan di balik jubah adalah cangkang berlubang (model dasar tidak
  memodelkan torso di bawah kain) — **jangan lepas jubahnya**.
- Lengan menggantung lurus (pose dibekukan ke verteks, bukan rig) — model
  statis; putar modelnya, jangan coba gerakkan lengan.
- **Penilaian jujur (tahap 12):** ini batas maksimal jalur model gratis +
  perintah teks. Yang sudah diperbaiki: serban lilitan, lengan terpisah,
  bahu bersih, lubang leher tertutup, lipatan jubah terukur. Yang tetap
  kurang: jubah masih terasa polos dari jauh, jenggot masih gumpalan halus
  tanpa helai, wajah masih manekin. Perbaikan lebih lanjut butuh sculptor
  manusia (atau model dasar yang lebih baik) — bukan iterasi perintah teks.

## Lisensi model dasar

Maasai-Style Herder, 1DesignTool 3D Library — gratis pemakaian komersial,
tanpa atribusi, boleh dimodifikasi dan dikirim di dalam produk. DILARANG
menjual kembali file modelnya apa adanya / di dalam paket model.
Salinan lisensi: `LISENSI-1designtool.html`. URL sumber:
https://1designtool.com/3d/models/maasai-style-herder
