# Model dasar Kyai — Ust. Aqsal (Three.js, dari model gratis)

## Model yang dipilih
- **Model:** Maasai-Style Herder (1DesignTool 3D library, model #36 dari 2361)
- **URL sumber:** https://1designtool.com/3d/models/maasai-style-herder
- **File unduhan langsung:** https://assets.stoicsoft.com/1designtool/3d/models/maasai-style-herder/ea5ccbdf77/model.glb
- **File lokal (asli, belum diubah):** `herder-asli.glb` (9.162.676 byte / 8,7 MB)
- **Lisensi:** 1DesignTool 3D Library License — gratis untuk pemakaian komersial, TANPA atribusi; boleh dimodifikasi (recolour, dipotong, digabung ke scene sendiri) dan dikirim di dalam produk. YANG TIDAK BOLEH: menjual kembali file modelnya apa adanya / di dalam paket model.
- **Salinan lisensi:** `LISENSI-1designtool.html` (diunduh 20 Nov 2026)
- **Dibuat oleh:** Claude Code (Opus 5.5) di dalam template 3D 1DesignTool, dari brief tertulis — BUKAN scan manusia, BUKAN sculpt tangan. Wajah dibangun dengan landmark terukur (hidung lurus, bibir tertutup, mata almond simetris). Kualitas semi-realistis harus diverifikasi lewat render sebelum dipakai.

## Spesifikasi teknis (terverifikasi dari file)
- 116.411 tris, 10 mesh, 63.279 vertices, 8 material (skin, eyes, teeth, top, bottoms, shoes, accent, prop), 9 tekstur (atlas 2048px)
- Tinggi 1,90 m, pose T-pose, rig Mixamo 65 tulang (mixamorig:*, termasuk jari lengkap)
- Tanpa animasi. Mata, gigi, telinga menempel di kepala.
- CATATAN PENTING: kulit yang tertutup kain (paha, sebagian besar torso) TIDAK dimodelkan — shuka tidak bisa dilepas begitu saja. Jubah panjang menutupi area itu, jadi aman selama jubah menutup torso + paha.
- Rambut pendek dicat ke dalam tekstur kulit (tidak ada mesh rambut terpisah). Serban akan menutupi kepala, jadi tidak masalah.

## Kenapa model ini
- Gratis, tanpa daftar/akun, unduhan langsung (tanpa login) — sesuai aturan Mas "GRATIS SAJA".
- Laki-laki dewasa, proporsi realistis, wajah lengkap dengan hidung/bibir/mata yang terbentuk.
- Kandidat lain yang dipertimbangkan: Grab3D Human Head (CC0, kepala saja — sulit digabung badan), Grab3D Medieval Villager (CC0, gaya stylized), Meshy AI (CC0, kualitas tidak konsisten + sempat di-skip Mas), Mixamo (butuh login Adobe), MakeHuman/MPFB (perlu install addon berat + hasil cenderung manekin).

## Hasil olahan Blender (selesai 20 Nov 2026, ~16:36 WIB — Bima)

**File akhir:** `ust-aqsal.glb` (4,05 MB, 55.129 tris, 32 mesh, 11 material) +
`ust-aqsal.blend`. Render verifikasi: `kyai-depan.png`, `kyai-samping.png`,
`kyai-wajah.png` (+ `kyai-wajah-redup.png`, `kyai-wajah-standard.png`).

**Tahapan:**
1. **Impor + cek:** wajah halus seperti manekin (kulit licin, wajah
   sempit-panjang, rambut abu-abu dicat) — mata/hidung/bibir terbentuk, lebih
   baik dari karakter primitif, tapi belum semi-realistis penuh. Dada
   berlubang besar di bawah shuka (torso tak dimodelkan).
2. **Pose + kulit:** pose armature GAGAL 3x (sumbu tulang Mixamo/GLB tak
   lazim) — solusi: rotasi verteks langsung (bmesh) ±84° di pivot bahu,
   lengan menggantung natural. Kulit diterangkan ×1,35 (sawo matang).
3. **Dandan:** jubah lathe + kerah + 5 kancing + tutup-dada, serban torus,
   jenggot ellipsoid, kumis, tasbih 11 butir. Render awal gelap (lampu hilang).
4. **Perbaiki:** studio 4 lampu, serban diberi inti padat, jubah dibangun
   ulang. Sisa cacat: jenggot terbaca dasi kupu-kupu abu-abu melayang,
   gundukan abu-abu di leher (tutup-dada), serban terlalu besar seperti topi
   koki, jubah bahu kotak.
5. **Perbaiki 2:** bahu diratakan lebih kuat (R 0,27 → 0,193), serban diganti
   SATU lathe beralur, jenggot dibangun ulang menempel rahang, tutup-dada
   diganti piringan kecil gelap, lengan ditempel ke badan jubah.
6. **Diagnosis jenggot (kunci):** pengukuran profil wajah asli membuktikan
   dagu tahap 2 SALAH (1,549 — itu leher atas). Profil benar: bibir atas
   z=1,69, mulut z=1,655, dagu z=1,60–1,64 (sangat masuk ke dalam, y=-0,035,
   sementara bibir y=-0,097). Jenggot tahap 3–6 terpasang 0,10 TERLALU RENDAH
   — makanya tampak di leher. Ray-cast membuktikan jenggot tahap 6 sebenarnya
   sudah menutupi dagu; yang menipu adalah render + kerah jubah yang
   menutupi bagian bawah jenggot.
7. **Jenggot profil (final):** cangkang yang mengikuti profil wajah
   (bibir bawah → dagu → menggantung, ujung meruncing), kumis kecil menempel
   di bibir atas. Jenggot final: ramping, membungkus rahang, menggantung di
   bawah dagu.
8. **Warna jenggot:** material `MAT-jenggot` (0.05, 0.04, 0.03) terverifikasi
   GELAP. Di render Blender lampu studio 900W ia tampak abu-abu terang —
   itu artefak cahaya, BUKAN materialnya. Di bawah cahaya redup/normal ia
   gelap (`kyai-wajah-redup.png`). Di artifact Three.js (cahaya normal) ia
   akan hitam. Jangan menaikkan intensitas lampu artifact terlalu tinggi.

**Penilaian jujur akhir:** badan terbaca Kyai (serban putih, jubah putih
A-line berkancing, sandal, tasbih). Wajah model dasar tetap manekin-halus.
Jenggot final adalah cangkang halus tanpa helai — jenggot pendek rapi,
bukan jenggot lebat realistis. Serban lathe terbaca seperti topi putih
membulat dari depan. Ini batas maksimal jalur model-gratis + perintah teks;
sculpt wajah/helai jenggot butuh tangan manusia.

**Detail builder:** lihat `BUILDER-NOTE.md` (path GLB, nama node/material,
kustomisasi yang bisa/tidak bisa, batasan).
