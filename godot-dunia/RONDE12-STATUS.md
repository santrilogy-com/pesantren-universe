# RONDE 12 — Jalur azimut matahari DIPERBAIKI (fisik) (16 Nov ~06:20–06:35 WIB, Raka)

**Pemicu:** Mas 06:20 WIB *"Di versi sebelumnya matahari ada di
sebelah kanan mihrab."* Itu yang salah. Aturan dunia nyata: menghadap
kiblat 295° (barat-barat laut), matahari sore/maghrib ada di sebelah
**KIRI** (~43° kiri saat terbenam); pagi hari matahari di timur = di
**BELAKANG** orang yang menghadap kiblat.

**Aturan:** hanya `scripts/langit_dinamis.gd` (`K_MATAHARI`) yang
diubah — tidak ada perubahan logika misi/poin/save, mihrab/sajadah
TIDAK disentuh (kiblat tetap 295°). **TIDAK deploy** — deploy urusan
Damar.

## 1. Verifikasi — dugaan brief TERKONFIRMASI dengan hitungan independen

Dihitung sendiri (Python, Jawa ~7°LS, 16 Nov, deklinasi −18,9°;
bukan percaya begitu saja):

| Jam (WIB) | Game LAMA | Benar (hitung) | Meleset |
|---|---|---|---|
| 06.00 | 92,6° | ~108° | ~15° |
| 15.00 | **325°** | **~251°** | **~74°** |
| 18.00 (terbenam) | **290°** | **~251°** | **~39°** |

Jadi klaim ronde 10 ("terbenam 290° sudah benar") adalah SALAH —
290° itu barat-barat laut, padahal matahari November terbenam di
barat sedikit selatan (~251°). Dan 325° jam 15.00 (pilihan deliberate
ronde 4 supaya matahari masuk tampilan default menghadap utara)
adalah barat laut — matahari jam 15.00 yang benar ada di
barat-barat daya (~251°).

## 2. Yang diubah — keyframe azimuth K_MATAHARI

| Jam | Lama | Baru | Keterangan |
|---|---|---|---|
| 0.0 / 24.0 | 290° | 252° | di bawah cakrawala, konsistensi |
| 5.5 | 90° | 107° | terbit timur-tenggara |
| 8.0 | 115° | 108° | pagi |
| 10.0 | 140° | 118° | pagi |
| 12.0 | 180° | 200° | siang, sedikit lewat selatan |
| 15.0 | 325° | **252°** | sore (perbaikan utama) |
| 17.0 | 300° | **252°** | sore |
| 18.0 | 290° | **252°** | terbenam |

**Elevasi TIDAK diubah** (8° jam 15.00, 3° jam 17.00) — golden hour
gaya ronde 4 dipertahankan; yang diperbaiki hanya AZIMUT. Di
tropika matahari turun hampir vertikal menjelang terbenam, jadi
azimut 15.00–18.00 yang nyaris konstan (252°) adalah benar secara
fisik. Bulan (K_BULAN) tidak disentuh — jalurnya sudah mengikuti
busur timur→selatan→barat.

**Dampak yang dikorbankan (sesuai brief):** matahari senja TIDAK
LAGI masuk tampilan default (menghadap utara) — kini ada di
barat-barat daya, kiri-belakang pemain saat spawn. Kebenaran arah
lebih penting daripada matahari selalu kelihatan.

## 3. Verifikasi (angka, bukan klaim)

- `--import` exit 0, 0 error.
- `--check-only`: `langit_dinamis.gd`, `test_ronde12.gd`,
  `foto_ronde12.gd` — semua lolos.
- **Tes headless `test_ronde12.gd`: 16/16 LOLOS, exit 0** — azimut
  tiap jam (05.30: 107,0°; 06.00: 107,1°; 08.00: 108,0°; 10.00:
  118,0°; 12.00: 200,0°; 15.00/17.00/17.45/18.00: 252,0°);
  matahari **43,0° di KIRI kiblat** jam 15.00 dan 17.45; pagi 08.00
  matahari 7,0° dari arah berlawanan kiblat (di belakang); elevasi
  15.00/17.00 > 0 (tampak), 18.00 < 0 (terbenam); kiblat tetap 295°.
  1 gagal di run pertama adalah **BUG TES** (rumus selisih
  berlawanan salah — `fmod(a-295+540,360)-180` memberi 173, bukan
  7) — diperbaiki, bukan bug game.
- **Smoke headless 600 frame scene utama: 0 SCRIPT ERROR.**
- **5 foto bukti** di `~/workspace/pesantren-verse/foto-ronde12/`
  (960×540, xvfb-run + opengl3, via `LangitDinamis.debug_jam`):
  - `01-dalam-mihrab-1500.png` — dari DALAM Surau menghadap mihrab
    jam 15.00: mihrab (panel hijau tua + lis emas) di tengah,
    sajadah diagonal menghadap kiblat, smartboard bersih. Retake
    2× (retake 1 GAGAL: kamera terlalu dekat, label TERKUNCI
    raksasa menutupi mihrab — label marker M2 di (-4.6, 1.6, -300)
    tepat di depan lensa; retake 2 dari (0, 1.6, -297.5) fov 60
    berhasil).
  - `02-luar-kiblat-1500.png` — plaza menghadap kiblat 295° jam
    15.00: **cakram + halo matahari JELAS di sebelah KIRI frame**,
    rendah di cakrawala; bayangan panjang ke kanan (timur). ✓
  - `03-luar-kiblat-maghrib.png` — arah kiblat yang sama jam
    17.25: pijar oranye terbenam di KIRI, bayangan sangat panjang
    ke timur. ✓
  - `04-matahari-terbenam.png` — menghadap barat (270°) jam 17.25:
    pijar terbenam di kiri-tengah (252° = 18° kiri dari barat). ✓
  - `05-pagi-timur.png` — menghadap timur (90°) jam 06.00:
    **matahari terbit di KANAN frame** (timur-tenggara ~108°),
    bayangan panjang ke barat (ke arah kamera). ✓
  - **Insiden skrip foto (bukan game):** run pertama foto 05
    HILANG — `_foto()` dipanggil tanpa `await`, coroutine terakhir
    mati saat `quit(0)` sebelum sempat menyimpan. Diperbaiki
    (`await _foto(...)`), run kedua 5/5 foto jadi. Pelajaran:
    fungsi ber-await HARUS dipanggil dengan await.
- **Export `export/web/`:** pck BARU **988.896 byte** sha256
  `8d72a1aeaaadb92504d472f67e65fcb99e45bc805d8a49975330999bc52afe8c`
  (32 byte LEBIH KECIL dari ronde 11 — hanya angka keyframe yang
  berubah); wasm TIDAK berubah (`fc74679e…`); index.js TIDAK berubah
  (`33c94cb3…`); worklet ada (2.973 byte). File tes/foto dihapus
  sebelum export (pck bersih). **TIDAK deploy** — deploy urusan
  Damar.

## Belum sempurna / jujur

- Foto 03 (maghrib): cakram matahari redup di garis cakrawala
  (alpha 0,27 pada elev ~1,6°) — yang terbaca jelas adalah pijar
  oranyenya di kiri, bukan bola penuh. Itu konsisten secara fisik
  (matahari baru terbenam), tapi kalau Mas mau bola maghrib yang
  lebih tegas, alpha dekat cakrawala harus dinaikkan (keputusan
  visual).
- Jam terbenam di game ~17.23 (elev 0 antara keyframe 17.00–18.00),
  sedangkan maghrib nyata di Jawa November ~17.45 — selisih ~20
  menit. TIDAK diubah (desain fase sore 15.00–18.00); kalau mau
  tepat, keyframe elevasi sore harus digeser — itu ronde lain.
- Foto maghrib diambil jam 17.25 (bukan 17.45) karena jam 17.45
  matahari sudah di bawah cakrawala di game.
- Label "TERKUNCI" (marker misi M2) masih melayang di interior
  sampai M1 selesai — terlihat di foto 01 (kecil, di atas
  smartboard). Bukan bug ronde 12.
- Retest browser ditahan sampai ronde 12 deploy (perintah parent)
  supaya satu retest menguji ronde 10+11+12 sekaligus.
