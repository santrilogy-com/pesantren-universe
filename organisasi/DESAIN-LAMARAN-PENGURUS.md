# Desain Sistem Lamaran Pengurus — Pesantren Universe

Status: **DI-ACC Mas 16 Nov ~15:55 WIB — sedang dibangun.** (Dibuat 16 Nov 2026 ~15:46 WIB, dari keputusan Mas 12:51 WIB: "santri bisa melamar jadi pengurus — Kepala Kamar, Keamanan, Ubudiyah, dll").
Dasar: `STRUKTUR-ORGANISASI.md` (Ketua Asrama = santri; musyrif = jabatan ustadz, diangkat Pengasuh — BUKAN lewat lamaran santri; pelantikan oleh Pengasuh; khidmah 1 tahun usulan).

**Keputusan ACC (Mas, 15:55 WIB):** syarat Misi M1 selesai; Kepala Kamar TIDAK boleh masuk kamar lain (aturan santri tetap); masa khidmah 1 tahun; bila ditolak boleh lamar lagi setelah 1 minggu. Urutan bangun: server (Saka, v1.4.0) → app → game (pengumuman + label jabatan, Raka, setelah perbaikan Surau).

## 1. Posisi yang bisa dilamar santri (usulan — 5 posisi)

**DIPUTUSKAN Mas 16 Nov ~15:50 WIB: Kepala Kamar lewat VOTE (bukan lamaran)** — sama seperti Ketua Asrama, dipilih/ditunjuk lewat musyawarah/vote. Kepala Kamar dikeluarkan dari daftar lamaran.

| Posisi | Lingkup | Tugas pokok |
|---|---|---|
| Keamanan | **Umum — seluruh pesantren** (DIPUTUSKAN Mas 15:50: bukan per asrama) | Jaga ketertiban; piket di **pos jaga di pojok-pojok pesantren** (dibangun nanti); ingatkan adab & tata tertib; laporan pelanggaran ke musyrif |
| Ubudiyah | Per asrama | Jadwal muadzin/imam; ingatkan sholat berjamaah & khataman; takmir musholla (putra: Musholla Al-Ikhlas; putri: Musholla Ar-Raudhah, pimpinan **Ustadzah Mariyah**) |
| Kebersihan | Per asrama | Koordinator piket kebersihan asrama & musholla |
| Pendidikan | Per asrama | Absensi kelas; ingatkan tugas & misi; bantu ustadz di kelas |
| Humas & Media | Seluruh pesantren | Bantu konten IG/TikTok (foto, ide caption); dokumentasi kegiatan |

Catatan: **Ketua Asrama dan Kepala Kamar TIDAK dilamar** — keduanya lewat vote/musyawarah (keputusan Mas).

## 2. Syarat melamar (usulan)

- Santri terdaftar (punya ID PV-XXXX).
- Sudah menyelesaikan **Misi M1** (bukti santri aktif, bukan akun baru yang langsung melamar).
- Tidak sedang menjalani sanksi (bila sistem sanksi sudah ada).

## 3. Isi form lamaran (di app)

- Posisi yang dilamar (1 pilihan utama + 1 cadangan, opsional).
- Alasan singkat (maks 200 huruf).
- Pengalaman/skill yang relevan (opsional, maks 200 huruf).
- Centang kesiapan khidmah 1 tahun.

Satu santri hanya boleh punya **1 lamaran aktif** dalam satu waktu (tidak boleh melamar 2 posisi sekaligus; bila ditolak boleh melamar lagi).

## 4. Alur persetujuan (usulan)

1. Santri kirim lamaran lewat app → status **"Menunggu Musyrif"**.
2. Musyrif asrama memberi rekomendasi (setuju / tidak + catatan singkat) → status **"Menunggu Pengasuh"**.
3. **Pengasuh (Ustadz Aqsal Murad) keputusan akhir** (terima / tolak + alasan singkat bila ditolak).
4. Bila diterima → **pelantikan** (ikrar khidmah di Musholla Al-Ikhlas, di dalam game; SK dicatat) → nama + jabatan tampil di Kartu Santri dan di seksi Struktur Organisasi app (yang saat ini disembunyikan — tampil setelah pelantikan pertama, sesuai keputusan Mas 15 Nov).
5. Masa khidmah **1 tahun**, dapat diperpanjang atau dicopot oleh Pengasuh setelah evaluasi.

## 5. Tempatnya

- **App:** menu "Lamaran Pengurus" — form lamaran, status lamaran, riwayat lamaran; musyrif melihat daftar lamaran asramanya + memberi rekomendasi; Pengasuh melihat semua + memutuskan.
- **Game:** pengumuman hasil pelantikan (toast/papan pengumuman di Surau); jabatan tampil di label nama pengurus (mis. "Bilal — Kepala Kamar 001").
- **Server:** tabel lamaran baru (id, santri_id, posisi, alasan, status, rekomendasi musyrif, keputusan Pengasuh, tanggal). Endpoint: kirim lamaran, lihat status, rekomendasi musyrif (butuh token musyrif), keputusan Pengasuh.

## 6. Pertanyaan terbuka untuk Mas (belum diputuskan)

1. ~~Daftar 6 posisi di atas ACC, atau ada yang dihapus/ditambah?~~ **TERJAWAB 15:50 — Kepala Kamar via vote (dikeluarkan dari lamaran); Keamanan umum + pos jaga di pojok.**
2. ~~Ketua Asrama ikut sistem lamaran, atau tetap dipilih lewat vote/musyawarah?~~ **TERJAWAB 15:50 — Ketua Asrama dan Kepala Kamar lewat vote.**
3. Syarat "Misi M1 selesai" ACC, atau tanpa syarat (siapa saja boleh melamar)? — **TERJAWAB 15:55 (ACC): syarat M1 selesai.**
4. **Kepala Kamar boleh masuk kamar lain di asramanya?** — **TERJAWAB 15:55: TIDAK boleh** (aturan santri tetap — hanya kamarnya sendiri; membangunkan lewat cara lain).
5. Masa khidmah 1 tahun ACC? — **TERJAWAB 15:55 (ACC): 1 tahun.**
6. Bila santri ditolak, boleh langsung melamar lagi, atau ada jeda (mis. 1 minggu)? — **TERJAWAB 15:55: jeda 1 minggu.**

## 7. Keputusan baru terkait (Mas, 16 Nov ~15:50 WIB — di luar lamaran, dicatat di sini karena menyangkut pengurus & dunia)

- **Musholla putri TERPISAH: Musholla Ar-Raudhah (مصلى الروضة)** — bukan partisi Surau (rencana Fase A-P lama diganti). Dipisah dari pesantren putra dengan **pagar dan gerbang**; di luar gerbang ada **satpam** yang jaga. Pimpinannya **Ustadzah Mariyah**. Gilang sedang memperbarui roadmap (plot, posisi gerbang + pos satpam, pos jaga keamanan di pojok); bangun in-game menyusul setelah perbaikan Surau selesai (Raka).

**Langkah berikut setelah ACC:** bangun tabel + endpoint server (Saka), form + status di app, pengumuman di game (Raka). Tidak dibangun sebelum Mas ACC desain ini.
