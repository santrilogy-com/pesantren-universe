# BUILDER-NOTE — Karakter Ust. Aqsal (GLB hasil Blender)

Untuk builder artifact web "Karakter Ust. Aqsal" (slug `karakter-ust-aqsal`).
Baca ini sebelum mengedit artifact. File GLB sudah jadi dan terverifikasi.

## File

- **GLB:** `~/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/ust-aqsal.glb`
- **Ukuran:** 4,05 MB (target ≤15 MB ✓)
- **Tris:** 55.129 (target ≤60.000 ✓)
- **Mesh:** 32 | **Material:** 11 (semua Principled BSDF, kompatibel glTF)
- **Blend (sumber):** `ust-aqsal.blend` (folder yang sama)
- **Render verifikasi:** `kyai-depan.png`, `kyai-samping.png`, `kyai-wajah.png`
  (juga `kyai-wajah-redup.png` = jenggot di bawah cahaya redup, `kyai-wajah-standard.png`)

## Cara memuat

- Pakai **GLTFLoader** (Three.js). Model statis (tanpa rig/animasi di GLB).
- **Tinggi:** ±1,90 m (puncak serban ±1,93 m). Kaki di y=0 — letakkan model di
  atas panggung dengan posisi y=0.
- **Arah hadap:** wajah menghadap **+Z** (glTF). Kamera depan bawaan:
  posisi kira-kira (0, 1,35, 3,4), target (0, 1,05, 0).
- Kamera yang sudah ada bisa dipakai ulang (Depan/Samping/Belakang/Wajah/Tubuh):
  - Depan: (0, -3.4, 1.35) → dalam Three.js (0, 1.35, 3.4), target (0, 1.05, 0)
  - Samping: (3.4, 1.35, 0.35) → Three.js (3.4, 1.35, 0.35), target (0, 1.05, 0)
  - Wajah: (0.25, 1.72, 0.9) → Three.js, target (0, 1.66, 0)
- Putar 360°: putar model (atau kamera orbit) seperti sebelumnya.

## Node & material (untuk kustomisasi)

| Node | Material (warna glTF) | Kustomisasi |
|---|---|---|
| `GEO-jubah` | `MAT-jubah` (0.96, 0.96, 0.94 — putih) | **Warna jubah:** ubah `material.color` |
| `GEO-serban` | `MAT-serban` (0.93, 0.93, 0.90 — putih) | Sembunyikan node = tanpa serban |
| `GEO-ekor-serban` | `MAT-serban` | Ekor serban di belakang leher; ikut `GEO-serban` |
| `GEO-jenggot` | `MAT-jenggot` (0.05, 0.04, 0.03 — hitam pekat) | Skala node (panjang/pendek) atau sembunyikan (= halik) |
| `GEO-kumis-kiri`, `GEO-kumis-kanan` | `MAT-jenggot` | Ikut jenggot; sembunyikan bila jenggot disembunyikan |
| `GEO-kerah`, `GEO-kancing-1..5` | `MAT-jubah` / `MAT-kancing` | Ikut warna jubah |
| `GEO-tutup-dada` | `MAT-gelap` (0.02 — hitam) | Penutup lubang dada; jangan dihapus |
| `GEO-lengan-kiri/kanan` | `MAT-jubah` | Lengan jubah |
| `GEO-tasbih-01..11`, `GEO-tasbih-rumbai` | `MAT-tasbih` (0.20, 0.10, 0.04 — cokelat) | Tasbih di tangan kanan |
| `maasai-style-herder_head` | `skin` (tekstur atlas 2048px) | Wajah + leher; **jangan** diubah warnanya |
| `maasai-style-herder_eyes` | `eyes` | Mata (mesh bola, tekstur) |
| `maasai-style-herder_body` | `skin` | Badan di balik jubah (cangkang berlubang — tertutup jubah) |
| `maasai-style-herder_sandals` | `shoes` | Sandal |
| `maasai-style-herder_teeth` | `teeth` | Gigi (di dalam mulut, nyaris tak terlihat) |

Catatan: ada **dua entri `MAT-jenggot`** di daftar material GLB (duplikat
ekspor, warnanya sama persis) — tidak berbahaya, abaikan saja.

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
- **Warna jubah:** BISA (material `MAT-jubah` polos, tanpa tekstur).

## Batasan yang perlu diketahui (jangan dijanjikan ke Mas)

- Wajah model dasar halus seperti manekin (kulit licin, wajah sempit-panjang)
  — mata/hidung/bibir terbentuk, tapi belum semi-realistis penuh. Rambut
  pendek dicat ke tekstur (abu-abu, tertutup serban).
- Jenggot adalah cangkang halus (tanpa helai rambut) — jenggot pendek rapi.
  Di render Blender dengan lampu studio 900W ia tampak abu-abu; di bawah
  cahaya normal (Three.js) ia gelap/hitam — sudah diverifikasi
  (`kyai-wajah-redup.png`). Jangan menaikkan intensitas lampu artifact
  terlalu tinggi, nanti jenggot memutih lagi.
- Badan di balik jubah adalah cangkang berlubang (model dasar tidak
  memodelkan torso di bawah kain) — **jangan lepas jubahnya**.
- Lengan menggantung lurus (pose dibekukan ke verteks, bukan rig) — model
  statis; putar modelnya, jangan coba gerakkan lengan.
- Serban adalah lathe beralur (bukan lilitan kain asli) — dari depan terbaca
  seperti topi/peci putih membulat; dari samping cukup meyakinkan.

## Lisensi model dasar

Maasai-Style Herder, 1DesignTool 3D Library — gratis pemakaian komersial,
tanpa atribusi, boleh dimodifikasi dan dikirim di dalam produk. DILARANG
menjual kembali file modelnya apa adanya / di dalam paket model.
Salinan lisensi: `LISENSI-1designtool.html`. URL sumber:
https://1designtool.com/3d/models/maasai-style-herder
