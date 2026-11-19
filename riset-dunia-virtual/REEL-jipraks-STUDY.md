# Studi Reel: @jipraks — "5 hal yang saya ubah di animasi 3D bikinan Claude"

- **Link:** https://www.instagram.com/reel/Dfwu_24k-8a/
- **Tanggal posting:** 15 Nov 2026 ~04:03 WIB (dicek 17 Nov 2026 ~20:45 WIB)
- **Kreator:** Aji Prakoso — **@jipraks** (akun creator, terverifikasi, Indonesia)
- **Profil:** 13.666 follower, 376 following, 116 postingan. Bio: "10+ YoE building software. Now mostly pressing Cmd + Enter on Claude Code. Somehow, things still ship." Website: https://link.jipraks.com
- **Angka reel:** 1.127 like, 52 komentar. Durasi ~48 detik (audio original 47,9 dtk).
- **Kreator BARU** — belum pernah dipelajari sebelumnya (bukan salah satu model dunia netizen yang sudah ada). Niche-nya sama dengan @agam.saputraex (Claude Code + Blender, bangun di depan publik, berbahasa Indonesia), tapi fokusnya animasi 3D Blender, bukan video explainer stickman/Remotion.

## 1. Isi reel

Video explainer animasi 3D, adegan kedai kopi, dibuat di **Blender × Claude**. Format **"dulu vs sekarang"**: membandingkan versi lama dan versi baru dari adegan yang sama. Lima hal yang dia ubah:

1. **Gerakan** — jalan yang tadinya kaku (rumus/keyframe) diganti motion capture dari **Mixamo**.
2. **Kamera** — dari satu shot statis dari atas menjadi kamera gaya handheld "kayak lensa beneran": sedikit goyang + background blur (bokeh).
3. **Material & cahaya** — dari warna datar polos menjadi tekstur dan pencahayaan realistis dari **Poly Haven**.
4. **Tabrakan (collision)** — karakter tadinya jalan menembus barang; sekarang memutar melewati kursi.
5. **Suara** — efek suara yang sinkron tepat di momennya (langkah kaki, cangkir, mesin kasir, uang, printer).

Penutupnya jujur: "hasilnya masih belum bagus banget" + minta penonton tulis di komen kurangnya di mana, nanti dia coba perbaiki.

**Stack yang terungkap di komentar (jawaban Aji sendiri):** Blender + Claude via **MCP**; model **Claude Opus 5.5**; paket **Claude Team Premium** (limit mingguan berkurang <1% per video, katanya); render video ~60 detik memakan **~30 menit**. Hari itu juga dia beli kredit **Tripo AI** dan bikin karakter pakai API Tripo ("lebih baik hasilnya"), video lanjutannya tayang 16 Nov jam 19:00.

**Ini seri harian yang iterasi dari feedback penonton.** Postingan berikutnya sudah ada: "Kemarin banyak yang bilang bajunya tenggelam dan mukanya kaku. Jadi sekarang karakternya saya bikin pakai Tripo…" — kritik penonton langsung jadi bahan episode besok.

## 2. Respons penonton (52 komentar — semuanya dibaca)

**Topik yang paling diramaikan: biaya token / paket Claude** (5+ pertanyaan): "ngga boros token bg?", "Satu video bisa berapa persen 5 hour limit?", "Abis token sebanyak apa pak", "minimal ambil plan Claude apa… per video abisin berapa dolar". Jawaban Aji: Team Premium, berkurang <1% per video; "pakai Claude yang Pro aja harusnya cukup".

**Permintaan tutorial** — paling banyak setelah soal token: "Tutor mass", "Ajarin dong", "Ajarkan suhu", "gmn caranya om?", "kurang tutorialnya aja 😂".

**Cara kerja** — "Ini di connect ke blender atau di Claude aja bang?" (jawab: konek ke Blender pakai MCP), "Pake model apaan bang?" (Opus 5.5), "Ada githubnya brother??", "Kalau VS Code bisa hasilin seperti ini ga?", "Kalo pake Adobe bisa gk bang?"

**Kritik langsung yang menjawab pertanyaannya** ("kurangnya di mana?"):
- "Badannya nabrak mas sama kakinya si topi Oren yang baju gari putih" — badan karakter masih menabrak kaki karakter lain.
- PITRA (kreator lain yang sudah coba juga): "masih ga sreg dgn pose n gerakan chara 3D dari Blender. N dari Claude jg mesti diminta spy ga ada intersection antara object, krn kadang tangan tembus ke badan sendiri 😂" — tangan menembus badan sendiri; Claude harus diminta eksplisit supaya tidak ada intersection.
- Aji sendiri mengakui: "ini masih dicoba coba, biar pakaiannya bisa ngikutin badannya 😂" (baju tenggelam / tidak mengikuti badan).
- "Saran lensa yang bagus apa aja bang, biar videonya variatif" — penonton minta variasi lensa kamera.

**Keluhan render** — komentar paling banyak like (9 like): "Laptop ku mau meledak pak rendernya lama bener".

**Pujian:** "Kereeeeennn", "mantap 👏", "Weh menarik", "Iterasi terus menerus dan hasilnya makin keren, lanjutkan mas! 🔥 izin saved videonya". Satu spam self-promo (Nusarastudio menawarkan jasa video via DM).

**Catatan penting:** reel 3D ini adalah postingan dengan like tertinggi di antara postingan terbarunya — 1.127 like vs 13–214 like untuk konten AI-app/automasi biasanya (n8n, admin WA AI, aplikasi kasir, clipper AI). Konten proses animasi 3D performanya ~5–10× konten biasanya.

## 3. Relevansi untuk Pesantren Universe

### Layak dicontoh
1. **Mixamo motion capture untuk gerakan** — memvalidasi temuan riset model dasar ronde 3 (Mixamo Auto-Rigger gratis). Jalan santri yang kaku jangan di-keyframe manual; pakai mocap Mixamo. Relevan langsung untuk animasi jalan/duduk karakter v2 dan perbaikan cara duduk v1.
2. **Poly Haven (CC0, GRATIS) untuk tekstur + cahaya** — cocok dengan aturan "gratis saja". Bangunan Blender kita (Surau v2 dll.) masih pakai warna datar; tekstur + HDRI Poly Haven adalah upgrade visual berikutnya untuk Bima. Poly Haven sudah tercatat di RENCANA-UPGRADE-VISUAL.md sebagai sumber tekstur CC0.
3. **Kamera kayak lensa beneran** — handheld shake halus + bokeh. Untuk video Hari ke-1 / motion: gerakan kamera pelan + lensa bervariasi, bukan satu shot statis.
4. **Disiplin tabrakan** — "karakter nggak boleh tembus barang". Masalah yang sama persis dengan kita: kamera tembus model di v1, gerbang/pushback, dan tangan karakter menembus badan. Pelajaran konkret dari PITRA: **minta Claude eksplisit di prompt supaya tidak ada intersection antar objek** — jangan anggap otomatis.
5. **SFX sinkron tepat di momennya** — sama dengan aturan motion kita (SFX non-tonal tepat di beat).
6. **Format "dulu vs sekarang" + jujur "masih belum bagus" + tanya penonton kurangnya di mana** — mengubah kritik jadi engagement. Cocok dengan model PV "seri harian + komen menentukan besok" (seperti @kampungkomen / @ponpes_netizen). Penonton memberi kritik teknis yang spesifik dan gratis.
7. **Iterasi harian dari feedback** — episode besok langsung menjawab kritik kemarin (baju tenggelam → ganti Tripo). Ini pola yang sama dengan ronde perbaikan kita.

### Jangan dicontoh
1. **Stack berbayarnya** — Claude Team Premium + kredit Tripo AI yang dibeli. Melanggar aturan "gratis saja". Jalur kita tetap: Mixamo gratis + Meshy kredit gratis + Blender.
2. **Jangan umbar janji tutorial** — penonton menuntut "Tutor mass" berkali-kali. Kalau PV posting konten proses, siap-siap ditagih tutorial; atau jadikan tutorial sebagai lead magnet (model Gege Vision) — jangan janji di komen lalu tidak ada.
3. **Jangan sembunyikan cacat** — penonton MELIHAT tabrakan badan yang luput dari mata kreator. Kejujuran membingkai kritik jadi engagement, tapi cacatnya tetap kelihatan. Tetap berlaku aturan kita: cek render 360° + close-up sebelum posting (pelajaran Syumra no. 8).
4. **Soal token akan jadi pertanyaan nomor satu** — kalau PV posting konten "dibikin Claude", penonton akan tanya biaya/token/paket. Siapkan jawaban jujur (limit free tier mingguan, token invite sebagai cadangan) — jangan pernah klaim token tidak terbatas.

## 4. Kaitan dengan studi yang sudah ada
- **@agam.saputraex (studi 17 Nov):** niche yang sama (kreator Indonesia, Claude Code + Blender, iterasi publik), tapi Agam di jalur video explainer stickman/Remotion; jipraks di jalur animasi 3D Blender. Keduanya membuktikan ada audiens Indonesia yang besar untuk konten "proses bikin pakai Claude".
- **RISET-MODEL-DASAR-RONDE3.md:** temuan Mixamo Auto-Rigger gratis — reel ini adalah bukti lapangan bahwa Mixamo memang memperbaiki gerakan kaku.
- **MCP-BLENDER-FEASIBILITY.md:** Aji memakai persis jalur itu (Claude → Blender via MCP) dan berhasil produksi harian — konfirmasi praktis bahwa MCP Blender bukan sekadar teori.
- **RENCANA-UPGRADE-VISUAL.md:** Poly Haven sudah tercatat sebagai sumber tekstur CC0 — reel ini menunjukkan hasil nyatanya (warna datar → tekstur realistis).
- **SYUMRA-3D-STUDY.md:** masalah karakter jipraks (muka kaku, baju tenggelam, tangan tembus badan) adalah masalah yang sama dengan yang kita hadapi di santri Blender — pelajarannya berlaku dua arah.

## 5. Batasan studi
- Video tidak ditonton frame-by-frame (CLI hanya memberi teks + ringkasan isi); detail visual berasal dari ringkasan media-understanding + caption + komentar.
- Angka like/komen per 17 Nov 2026 ~20:45 WIB; 52 komentar dibaca semua.
- Hanya membaca — tidak ada like, komen, follow, atau DM yang dikirim.
