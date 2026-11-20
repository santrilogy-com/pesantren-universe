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

## Hasil olahan Blender — VERSI FINAL (tahap 12, 20 Nov 2026 ~17:39 WIB — Bima)

**File akhir:** `ust-aqsal.glb` (4,22 MB, 58.525 tris, 30 mesh, 13 material) +
`ust-aqsal.blend`. Render verifikasi: `kyai-depan.png`, `kyai-samping.png`,
`kyai-wajah.png`. Skrip: `skrip-11-lipatan-dalam.py` + `skrip-12-tekstur-kuat.py`.
Tekstur lipatan: `lipatan-jubah.png` (512×64, dibuat via PIL).

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
9. **Perbaiki "balok" (tahap 9, 23:55 WIB):** jubah lathe dengan 9 lipatan
   geometri (modulasi sinus amp 1,2% → 5% + harmonik + noise), hem
   bergelombang ±0,02, lengan terpisah miring keluar, serban dibangun ulang
   jadi 6 cincin torus + tutup kubah + ekor (satu node `GEO-serban`), kumis
   jadi SATU ellipsoid, jenggot lebih ramping. Hasil: serban terbaca lilitan,
   lengan terpisah, hem bergelombang — tapi lipatan tidak kebaca (overexposure)
   dan ada bercak kulit di bahu + lubang hitam di leher.
10. **Perbaiki "balok" 2 (tahap 10):** deltoid badan diratakan (R bahu
    0,193 → ~0,154), profil jubah bahu dilebarkan, lipatan diperdalam
    (1,5% → 6%), warna jubah/serban diredupkan, serban 5 cincin lebih ramping,
    jenggot dipendekkan, kerah DIHAPUS, lampu verifikasi diredupkan (Key 500).
    Hasil: bercak bahu hilang, serban lilitan bagus — tapi lipatan tetap tidak
    kebaca. Analisis piksel membuktikan: scanline jubah 236–249, variasi
    hanya ±6, tanpa pola periodik — jubah overexposure, bukan geometri hilang.
11. **Lipatan dalam + tekstur (tahap 11):** lipatan geometri diperdalam
    (3% → 10%) + **tekstur garis lipatan** `lipatan-jubah.png`
    (B(u)=0,88+0,06·sin(18πu)) di `MAT-jubah` dengan UV silinder; lengan pakai
    `MAT-lengan` polos; piringan penutup leher `GEO-leher-dalam` (r=0,095,
    z=1,53, `MAT-kulit-polos`). **Pelajaran:** `img.pixels = [...]` di
    Blender GAGAL diam-diam dalam sesi ini (piksel terbaca 0,0 = hitam) —
    tekstur pertama membuat jubah jadi arang. Solusi: buat PNG via PIL, lalu
    `bpy.data.images.load()`. Proses sempat terbunuh SIGTERM saat restart
    drain (17:17 WIB) — Blender hilang karena VM diganti; diinstal ulang via
    `dpkg -i /var/cache/apt/archives/*.deb` (Blender 4.0.2 kembali jalan).
12. **Tekstur kuat + tutup leher (tahap 12, final):** kontras tekstur
    dinaikkan (0,72–0,95, puncak 242 / lembah 184) + `img.reload()`; penutup
    leher dinaikkan (z=1,555) dan dibesarkan (r=0,100) — lubang hitam leher
    tertutup. Hasil render: lipatan TERUKUR (scanline jubah variasi 34–39
    level, ~15%, pola periodik 9 lipatan), hem bergelombang, lengan terpisah,
    serban lilitan terbaca, bahu bersih, leher tertutup rapat.

**Penilaian jujur akhir (tahap 12):** badan terbaca Kyai (serban lilitan
putih, jubah putih A-line berkancing dengan lipatan terukur, sandal, tasbih).
Wajah model dasar tetap manekin-halus. Jenggot cangkang halus tanpa helai —
jenggot pendek rapi, bukan jenggot lebat realistis. Jubah masih terasa polos
dari jauh (lipatan ~15%, halus, bukan garis tegas). **Ini batas maksimal
jalur model-gratis + perintah teks** — tiga iterasi "balok" (tahap 9, 10,
11/12) masing-masing memperbaiki satu lapis, tapi tidak mengubah kesan dasar.
Sculpt wajah/helai jenggot/lipatan kain yang meyakinkan butuh tangan manusia
(atau model dasar yang lebih baik). Jangan dipoles laporannya: kalau Mas
masih bilang "balok", jalurnya sudah mentok di sini.

**Detail builder:** lihat `BUILDER-NOTE.md` (path GLB, nama node/material,
kustomisasi yang bisa/tidak bisa, batasan).
