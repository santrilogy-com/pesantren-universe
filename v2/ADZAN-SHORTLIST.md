# Shortlist Rekaman Adzan — Freesound (lisensi bersih)

**Dicari:** Cakra, 18 Nov 2026, atas keputusan Mas (13:19 WIB): "Ya cari.."
**Kebutuhan:** adzan lengkap, suara jelas dan merdu, lisensi bersih (CC0 diutamakan, CC-BY boleh dengan atribusi), untuk diputar saat waktu sholat (Subuh 04:30, Dzuhur 12:00, Ashar 15:00, Maghrib 18:00, Isya 19:00).
**Status:** SHORTLIST — Mas yang pilih. BELUM dimasukkan ke game.

## Rekomendasi urutan

### 1. "Islamic Call to Prayer - Mosque Marylebone" — Emanuele_Correani ⭐ PILIHAN UTAMA
- **Link:** https://freesound.org/people/Emanuele_Correani/sounds/459704/
- **Lisensi:** **CC0** (terverifikasi dari halaman Freesound — teks "Creative Commons 0: You can copy, modify, distribute and perform the sound, even for commercial purposes, all without asking permission")
- **Durasi:** 2:16 — adzan lengkap gaya ringkas
- **Format:** WAV, 37,4 MB, 48 kHz, 24-bit, stereo
- **Rekaman:** di Marylebone Mosque / London Central Mosque, alat profesional (Wisycom wireless, mic Sanken COS11, recorder Sound Devices 633). Muadzin: Sheikh Rafaat, orang Mesir, muadzin masjid itu 30+ tahun.
- **Penilaian:** rating 4,7 (21 rating), 1.400+ download. Rekaman close-mic di dalam masjid — suara paling bersih dan jelas dari semua kandidat; paling cocok untuk game.
- **Atribusi:** tidak wajib (CC0), tapi catat pembuatnya: Emanuele_Correani / Sheikh Rafaat.

### 2. "Call Of Prayer - ADHAN - Marrakech" — Redalemage
- **Link:** https://freesound.org/people/Redalemage/sounds/583206/
- **Lisensi:** **CC0** (terverifikasi dari halaman Freesound)
- **Durasi:** 3:05 — adzan lengkap
- **Format:** WAV, 102,2 MB, 96 kHz, 24-bit, stereo
- **Rekaman:** dari teras kafe di Place Jemaa El-Fna, Marrakech, saat Maghrib, direkam dengan Zoom H6 (pasangan MS).
- **Penilaian:** 76 download. Rekaman lapangan (outdoor) — ada suasana alun-alun kota di latar. Lebih atmosferik, suara muadzin tidak sebersih nomor 1. Cocok kalau Mas mau nuansa "adzan dari kejauhan".
- **Preview (ditemukan di halaman):** https://cdn.freesound.org/previews/583/583206_7145976-lq.mp3
- **Atribusi:** tidak wajib (CC0).

### Cadangan (di luar Freesound, sudah terverifikasi CC0)
### 3. "Beautiful adhan" — Adam-synagda (Wikimedia Commons)
- **Link:** https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg
- **Lisensi:** **CC0 1.0** — diverifikasi proyek aplikasi Taqwa (README audio mereka): "Chosen because it is a CC0 dedication by the person who made the recording."
- **Durasi:** 2:34, Ogg Vorbis, stereo 44,1 kHz
- **Catatan:** sudah dipakai sebagai adzan default aplikasi sholat Taqwa — sinyal kualitas bagus. Format OGG langsung cocok untuk Godot (tidak perlu konversi).

## Yang DITOLAK (dan alasannya)
- **wshintani — "call to prayer.aif" (195076):** label CC0, tapi komentar di halaman menunjukkan pembuatnya menuntut pembatasan ("not to be used in any music loop or soundtrack") dan asal rekaman tidak jelas. Lisensi bermasalah → tolak.
- **iainmccurdy — "Adhan (call to prayer). Aroumd, Morocco." (807484):** hanya 1:13 — adzan TIDAK lengkap (potongan awal saja), muadzin berdeham, ada suara sungai. → tolak.
- **sonically_sound — sounds/639494:** label CC0, tapi deskripsinya sendiri bilang diekstrak dari YouTube — pengunggah tidak berhak mewakafkan rekaman orang lain. (Temuan riset proyek Taqwa.) → tolak.
- **"Call to prayer from the Prophet's Mosque" (CC BY 3.0 via Freesound):** masih membawa tag ID3 album komersial tempat ia di-rip. → tolak.

## Catatan unduhan (PENTING)
- **File audio TIDAK berhasil diunduh dari VM ini:** freesound.org dan CDN-nya mengembalikan 403 untuk semua permintaan langsung dari VM (sudah dicoba curl biasa, dengan User-Agent + Referer, varian lq/hq/mp3/ogg). Lisensi + durasi + metadata di atas terverifikasi dari halaman Freesound (dibaca lewat peramban), tapi saya TIDAK mendengarkan audionya langsung — Mas/Xam mohon dengarkan preview di halaman Freesound sebelum memilih.
- **File WAV penuh di Freesound butuh login** untuk mengunduh ("Login to download"). Setelah Mas memilih, unduh file WAV-nya, lalu konversi ke **OGG** (game memakai .ogg; WAV 37–102 MB terlalu besar untuk web — target OGG beberapa MB).
- **Adzan Subuh:** tidak ada kandidat yang menyatakan versi Subuh (tambahan "ash-shalatu khairun minan-naum"). Praktik umum game: satu rekaman yang sama untuk kelima waktu. Kalau Mas mau beda untuk Subuh, perlu cari lagi khusus Subuh.

## Yang harus dilakukan setelah Mas memilih
1. Mas pilih nomor 1 / 2 / 3 (atau minta cari lagi).
2. Unduh file pilihan (login Freesound bila perlu) → konversi ke OGG → masukkan ke game sebagai `adzan.ogg` (slot yang selama ini kosong).
3. Catat atribusi di dalam game/dokumen bila lisensinya CC-BY (untuk dua kandidat di atas tidak wajib karena CC0, tapi nama pembuat tetap dicatat).
