# ROADMAP ALUR MISI — Pesantren Verse

**Tim Alur Game:** Laras (lead) · Gilang (Maps) · Raka (game — kelayakan) · Zahra (riset)
**Tanggal:** 18 November 2026 (menyertai DRAF-ALUR-MISI.md v4 — misi = Ruang Belajar, baca kitab di rak kitab — keputusan Mas 15:14 WIB)
**Status:** ROADMAP — untuk dinilai Mas bersama draf v4. **JANGAN bangun sebelum Mas ACC draf v4.**
**Sumber:** `DRAF-ALUR-MISI.md` v3 (§8 kelayakan Raka, §9 keputusan) · `MULTIPLAYER-PLAN.md` · `MULTIPLAYER-FASE2-SPEC.md` · masterplan ACC (`KONSEP-TATA-LETAK.md`)

**Prinsip urutan:** fondasi lokal dulu → server & serentak → sosial → olahraga. Satu fase tidak dimulai sebelum prasyaratnya lolos — terutama 3 kunci: **jalur poin game→server** (keputusan Saka), **jam server**, dan **multiplayer Fase 1 lolos T1**.

---

## 0. Yang sudah live hari ini (Fase 0 — fondasi yang ada)

Tidak perlu dibangun — dipakai ulang sebagai fondasi semua fase:

- Misi M1–M3 (+10/+15/+25 poin, pola rantai terkunci + kuis 1 soal + panel misi)
- Peti Kayu M3 (0,26) · smartboard 3 slide Bagian 1 · reader kitab (5 kitab, 184 bab, `dicek_ustadz`)
- Jadwal khataman 05:00/13:00/18:30 + tombol hadir · Ma'hadiyah 7 checklist + streak · sholat berjamaah lokal
- Server lamaran pengurus v1.4.0 · ranking + tier poin (25/50/100) · `GET /api/ranking` · `POST /api/santri/points` (server siap, game belum memanggil)
- Asrama Putra/Putri 96 kasur · Lapangan Putra (−30,50) masih lahan saja · multiplayer Fase 1 (server realtime live; tombol gabung UI sedang dibuat Dimas)

---

## Fase A — Fondasi misi (lokal)

**Tujuan:** santri bisa menyelesaikan Jenjang 0 (Nahwu Dasar) secara lokal — dari N1.1 sampai lulus gerbang ruang belajar — mengikuti pola baku tiap modul: cari Ustadz (petunjuk di peta) → belajar → tugas dari Ustadz — dengan gelar yang terlihat.

| # | Yang dibangun | Prasyarat | Keluar (yang bisa Mas lihat) |
|---|---|---|---|
| A1 | **Mesin ruang belajar** — kuis multi-soal (1/5/10 soal) + tes naik Bagian (lulus ≥8/10) + gating Bagian + progres per Bagian di Kartu Santri | — (kode saja) | Kuis tidak lagi 1 soal; Bagian terkunci sampai tes lulus |
| A2 | 27 modul ruang belajar lanjutan (N1.2–N4.T) + bank soal dari ebook Nahwu | Konten Bagian 2–4 — **BOTTLENECK: materi menunggu tashih Mas** (keputusan 15:14 — Mas sendiri yang tashih; tim khusus kurikulum DIBENTUK SEKARANG per Mas 15:16, mengerjakan satu modul per hari) | Modul ruang belajar Nahwu Dasar lengkap sampai N4.T |
| A3 | Peti dinamis 4 warna (satu peti, warna/isi berubah per Bagian) + 9 slide smartboard Bagian 2–4 | A1; video smartboard belum ada (tombol tetap nonaktif) | Peti Hijau/Biru/Ungu/Oranye berganti per Bagian |
| A4 | **Gerbang ruang belajar (lokal)** — kuis kaidah Nahwu Dasar yang mudah (10 soal, lulus ≥8/10); badge "Bisa Baca Kitab Kuning" syaratnya ruang belajar selesai + baca kitab di rak kitab + setoran ustadz (jumlah bab butuh ACC Mas, §9 butir 12 draf) | A1; font Arab di proyek diverifikasi ada | Santri lulus Jenjang 0 = selesai ruang belajar Nahwu Dasar + lulus gerbang kaidah; badge "Bisa Baca Kitab Kuning" (syarat baca + setoran, lihat draf §2.1) |
| A5 | **Tangga gelar (lokal)** — 8 tier (Thalib al-'Ilm → 'Allamah) + divisi + bintang; tampil di Kartu Santri + label nama | A1; nama gelar puncak dikunci Mas (§9 butir 10) | Gelar terlihat di Kartu Santri + di atas kepala pemain |
| A6 | **Perlengkapan Lapangan Putra** — 2 gawang + garis lapangan + bola (statis) + lampu lapangan | — (venue saja, tanpa mekanik bola) | Lapangan Putra siap secara visual untuk Fase D |
| A7 | **Marker/petunjuk Ustadz di peta + sistem tugas dari Ustadz** — peta besar + minimap menandai lokasi Ustadz pengajar modul aktif (pola baku §2.1 draf: cari Ustadz → belajar → tugas); setelah kuis lulus, Ustadz memberi tugas (baca kitab di rak kitab / hafalan / latihan) + pelacak tugas selesai | A1; lokasi Ustadz per mapel mengikuti §6 draf | Santri tahu harus ke mana (cari Ustadz), dan ada tugas lanjutan setelah belajar |

**Selesai bila:** santri baru bisa main dari N1.1 → N4.T → gerbang ruang belajar → naik gelar, mengikuti pola cari Ustadz → belajar → tugas, semuanya lokal, tanpa error. **Poin tetap lokal** (belum ke server).

---

## Fase B — Server & serentak

**Tujuan:** poin, gelar, dan kehadiran tersinkron ke server; kuis mingguan serentak jalan.

| # | Yang dibangun | Prasyarat | Keluar |
|---|---|---|---|
| B1 | **Jalur poin game→server** — game memanggil `POST /api/santri/points` (atau relay via server realtime tepercaya) | **Keputusan Saka (arsitektur) — kunci dulu** (§9 butir 8 draf v4); `X-PV-Token` TIDAK BOLEH masuk file game | Poin misi masuk ranking server; tidak bisa dipalsukan dari HP |
| B2 | **Jam server** + kirim kehadiran khataman (aktivitas baca)/Ma'hadiyah ke server + endpoint kehadiran | B1; T1 multiplayer lolos | Khataman/sholat/Ma'hadiyah tersinkron + tercatat di server |
| B3 | **Penegakan gerbang ruang belajar + gelar server** — syarat naik jenjang diaktifkan (Ma'hadiyah ≥5/7 selama 4 minggu + gerbang ruang belajar lulus) + badge lulus + ranking per asrama | B1, B2 | Syarat lulus benar-benar ditegakkan; gelar di ranking = gelar server |
| B4 | **Kuis Mingguan Serentak** — event terjadwal (usulan Sabtu 09:00, 10 soal, soal dari server saat sesi mulai) + papan skor sesi + papan skor mingguan | B2 (jam server — tanpa ini "serentak" itu pura-pura); cap 50 teruji beban (T5) | Kuis tiap pekan jalan, dua sesi paralel per area, ada juara mingguan |

**Selesai bila:** poin dari HP sampai ke server tanpa dobel; kuis mingguan pertama selesai dengan papan skor benar. **Baru di fase ini syarat naik jenjang diaktifkan.**

---

## Fase C — Sosial

**Tujuan:** santri bisa main bersama — chat, sholat serentak, duel, musyawarah, bahtsul masail.

| # | Yang dibangun | Prasyarat | Keluar |
|---|---|---|---|
| C1 | Chat teks (feed MLBB + relay server + rate limit) + sholat berjamaah serentak server | Fase B selesai; T1 multiplayer lolos; cap 50 teruji (T5) | Santri bisa koordinasi + sholat bersamaan |
| C2 | Voting Ketua Asrama/Kepala Kamar + label jabatan di nama + pengumuman pelantikan | C1; §9 butir 7 (vote atau tunjuk musyrif) | Pengurus dipilih + terlihat jabatannya |
| C3 | **Duel 1 lawan 1** (kuis 5 soal, matchmaking dalam satu server) + **tantangan hafalan** mingguan | C1; mekanik hafalan (susun bait) | Santri bisa menantang santri lain |
| C4 | **Bahtsul Masail** — format musyawarah kelompok (masalah → muthala'ah → pendapat + ta'bir → perumusan → pengesahan Kyai) + ruang per kelompok + penilaian ustadz/musyrif | C1; **musyrif/moderator sanggup hadir terjadwal** (§9 butir 13 — tanpa penilai, event tanpa penutup/skor); venue: Surau/Musholla terpisah (atau Aula bila dibangun) | Event bulanan jalan dengan putusan yang disahkan |
| C5 | **Setoran baca kitab ke ustadz** (bukti kemampuan baca kitab — syarat badge "Bisa Baca Kitab Kuning"; pelengkap gerbang ruang belajar A4) | C1; ustadz/musyrif yang sanggup menilai | Kemampuan baca santri teruji sungguhan, bukan hanya pilihan ganda |

**Selesai bila:** satu kuis mingguan + satu duel + satu bahtsul masail selesai ujung-ke-ujung dengan skor tercatat.

---

## Fase D — Olahraga (BARU, fitur TERBESAR)

**Tujuan:** liga sepak bola antar santri jalan di dalam dunia.

| # | Yang dibangun | Prasyarat | Keluar |
|---|---|---|---|
| D1 | Mekanik bola — bola + fisika tendang/giring + garis/gawang aktif (deteksi gol) | A6 (perlengkapan lapangan); **tidak ada satu pun RigidBody3D di proyek sekarang — dibangun dari nol** | Bola bisa ditendang + gol terdeteksi (lokal dulu) |
| D2 | Mode pertandingan terpisah — tim (per asrama/kelas) + skor + klasemen + jadwal liga musiman + wasit (musyrif/NPC, §9 butir 11) | D1; multiplayer stabil (Fase C selesai) | Pertandingan 5v5 bisa dimainkan |
| D3 | **Otoritas server atas bola** — posisi bola dihitung server, bukan tiap HP | D2; server realtime Fase 2 | Bola sama di semua layar (tanpa ini = desync) |
| D4 | Liga musiman — menyambut Hari Santri (22 Oktober) + semesteran; hadiah poin tim + trofi + badge "Juara Liga Santri" | D3 | Liga pertama selesai dengan juara |
| D5 | Cabang "dll" (voli, lari, dsb) | D4 selesai — **DITUNDA sampai sepak bola jalan** | Cabang kedua, bila Mas minta |

**Catatan putri:** olahraga putri menunggu **Lapangan Putri (198,12)** — DITUNDA per keputusan 13:19 (nanti, bareng Asrama ke-2). Sementara: hanya voli/lari ringan di halaman/taman (128,−12). Sepak bola putri dimulai setelah lapangan putri ada.

**Selesai bila:** satu pertandingan 5v5 selesai tanpa desync bola + satu musim liga selesai dengan juara.

---

## Urutan ketergantungan (ringkas)

```
Fase 0 (live) ──→ Fase A (fondasi lokal: ruang belajar + gerbang + gelar + lapangan + marker Ustadz)
                      │
                      ├─→ Fase B (server: poin + jam server + kuis mingguan)
                      │         │  (kunci: keputusan Saka + T1 lolos + T5 beban)
                      │         └─→ Fase C (sosial: chat + duel + bahtsul masail)
                      │                   │  (kunci: penilai musyrif hadir)
                      │                   └─→ Fase D (olahraga: sepak bola)
                      │                             (kunci: multiplayer stabil)
                      │
                      └─→ paralel sejak Fase A: konten ebook Fiqih Dasar
                          (mapel prioritas 1 setelah Nahwu — Laras)
```

**Yang mengunci tiap fase (keputusan Mas, §9 draf v4):**
- Masuk Fase A: butir 10 (nama gelar puncak 'Allamah) + butir 12 (syarat badge "Bisa Baca Kitab Kuning") + butir 15 (mapel ruang belajar setelah Nahwu Dasar).
- Masuk Fase B: butir 8 (jalur poin — keputusan Saka) + butir 14 (hari/jam kuis mingguan).
- Masuk Fase C: butir 7 (voting atau tunjuk) + butir 13 (penilai bahtsul masail + venue Aula atau pecah).
- Masuk Fase D: butir 11 (sepak bola saja dulu? skor masuk poin? wasit siapa?).
- Sepanjang jalan: butir 1–2 (Masjid Besar + wudhu putri) menentukan venue event besar.

## 3 risiko lintas fase (dari Raka)

1. **Jalur poin game→server belum ada** — mengunci gelar server (B3) + kuis mingguan (B4) + semua skor sosial. Putuskan dulu sebelum Fase B.
2. **Jam server belum ada** — mengunci semua yang "serentak" (B2, B4, C1, C4). Tanpa jam server, serentak itu pura-pura.
3. **Konten adalah bottleneck, bukan kode** — bank soal (kuis mingguan, gerbang ruang belajar, duel), masalah fiqih bahtsul masail, materi Bagian 2–4 yang menunggu tashih Mas. Kalau konten telat, mesin yang sudah jadi tidak ada isinya.

---

*Roadmap ini pendamping DRAF-ALUR-MISI.md v4 — keputusan akhir di tangan Mas (Pengasuh) setelah menilai keduanya.*
