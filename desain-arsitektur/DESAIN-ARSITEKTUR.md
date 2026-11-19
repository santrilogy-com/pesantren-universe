# Desain Arsitektur — Surau Putra & Musholla Putri (Ar-Raudhah)

**Status: DESAIN UNTUK REVIEW MAS — belum dibangun di game.**
Dibuat 16 Nov 2026 oleh Arsa (arsitek). Menanggapi koreksi Mas 16 Nov ~21:38 WIB:
"Bagunan suraunya jelek.. tidak seperti.. baik yg putra apalagi yg putri.. coba bikin
desain arsiteknya dulu.. daya review."

**Masalah bangunan lama:** kotak polos beratap datar, tidak ada ciri surau/musholla —
tidak ada kubah, tidak ada lengkung, tidak ada menara. Desain baru ini memakai bahasa
bentuk masjid/surau pesantren Indonesia: kubah bawang, lengkung lancip di pintu dan
jendela, lis emas, warna zamrud + krem + emas (sesuai branding Pesantren Universe).

**Yang TIDAK berubah:** posisi bangunan (Surau (0,−12), Musholla pindah ke (62,−24)
di Ronde 21), mihrab tetap di dinding barat (kiblat 295°), pintu tetap menghadap
timur/jalan, plakat Surau tetap مصلى الإخلاص, interior Surau tetap 18 × 14 m.

## Gambar

| # | File | Isi |
|---|------|-----|
| 1 | `media-generation-01-surau-tampak-depan-0-f63f316b-5985-40af-8a3d-94b43e1e04d6.png` | Surau — tampak depan |
| 2 | `media-generation-02-surau-perspektif-0-37318a3b-44df-4cc2-a5fd-5bb87114166b.png` | Surau — perspektif 3D |
| 3 | `media-generation-03-musholla-tampak-depan-0-c89f5a39-4d49-4a08-89dc-bdd5c7be1d11.png` | Musholla — tampak depan |
| 4 | `media-generation-04-musholla-perspektif-0-370372a7-2355-4a6c-9b68-8b0d89b12e92.png` | Musholla — perspektif 3D |
| 5 | `05-denah-surau.png` | Denah Surau (tampak atas) |
| 6 | `06-denah-musholla.png` | Denah Musholla (tampak atas) |

## 1. Surau Putra — bangunan utama pesantren

**Ukuran:** luar 20 × 16 m, interior 18 × 14 m (tetap). Dinding 5 m, kubah utama
puncak ±11 m, menara ±14 m.

**Elemen khas:**
- **Kubah utama zamrud** (bawang) di tengah atap + bulan sabit emas di puncaknya.
- **4 kubah kecil zamrud** di keempat sudut atap — penanda "ini bangunan utama".
- **1 menara ramping** di sudut tenggara: badan silinder krem + lis emas, balkon
  kecil, tutup kubah zamrud. Fungsi: penanda + tempat adzan.
- **Portal pintu utama lengkung lancip** (iwan) menghadap timur/jalan: pintu jati
  dua daun + lis emas + kisi ukir di atas pintu. Plakat مصلى الإخلاص di atas portal.
- **6 jendela lengkung** (3 utara + 3 selatan) berkisi kayu.
- **Serambi depan** 3 m: 3 lengkung di atas tiang ramping — tempat lepas sandal
  dan duduk sebelum masuk.
- **3 anak tangga batu** di depan serambi; lis emas di sekeliling tepi atap.
- **Tempat wudu** di sisi selatan, di luar bangunan.

**Denah (05):** mihrab di tengah dinding barat + mimbar kayu di kanannya (sisi
utara), 6 baris saf menghadap barat, rak kitab di dinding utara & selatan,
pintu timur, serambi + tangga di depan, menara di sudut tenggara.

## 2. Musholla Putri — Ar-Raudhah

**Ukuran:** luar 12 × 10 m, interior 10 × 8 m (lebih kecil dari Surau — sengaja,
supaya hierarki bangunannya terbaca: Surau = utama, Musholla = pendamping).

**Elemen khas:**
- **1 kubah zamrud saja** (lebih kecil & ramping dari kubah Surau) + bulan sabit emas.
- **TANPA menara** — ini pembeda utama dari Surau.
- **Serambi kayu** di depan pintu: tiang + lengkung kayu, atap kayu — terasa hangat,
  bukan kaku.
- **Pintu lengkung kecil** + **4 jendela lengkung** (2 tiap sisi) berkisi kayu.
- **Pagar kayu keliling** + **taman bunga** di depan (sesuai miniatur yang sudah
  di-ACC Mas: pagar keliling putri = kayu).
- Lis emas lebih tipis/halus dari Surau.

**Denah (06):** mihrab di tengah dinding barat + mimbar kecil, 4 baris saf, rak
kitab di dinding utara, pintu timur, serambi kayu + tangga, pagar kayu keliling
dengan celah jalan masuk di timur, taman di timur laut & tenggara.

## 3. Yang membedakan Surau vs Musholla

| | Surau Putra | Musholla Putri |
|---|---|---|
| Ukuran luar | 20 × 16 m | 12 × 10 m |
| Kubah | 1 besar + 4 kecil | 1 kecil |
| Menara | Ada (1, tenggara) | Tidak ada |
| Serambi | Batu/plester, 3 lengkung | Kayu, lengkung kayu |
| Pagar | — (pagar kawasan terpisah) | Pagar kayu keliling + taman |
| Jendela | 3 tiap sisi | 2 tiap sisi |
| Saf | 6 baris | 4 baris |
| Rak kitab | Utara + selatan | Utara saja |
| Kesan | Megah, utama | Hangat, ramping |

## 4. Warna (kode warna untuk Godot)

| Elemen | Warna | Hex |
|---|---|---|
| Dinding | Krem | `#F2EAD6` |
| Kubah | Zamrud gelap | `#065F46` |
| Lis / bulan sabit / cornice | Emas | `#C9A227` |
| Pintu, jendela, serambi kayu | Jati | `#7B4B2A` |
| Tangga / lantai serambi | Batu abu | `#B8B2A4` |
| Lantai interior | Krem muda | `#FAF4E6` |

Warna kubah `#065F46` sama dengan abaya Ustadzah; krem `#F2EAD6` sama dengan
jilbabnya — satu keluarga warna dengan karakter yang sudah ada.

## 5. Bisa dibangun dari primitif Godot?

Ya — semua elemen memakai primitif sederhana saja:
- Dinding, lantai, tangga, mimbar, rak kitab, pagar: **BoxMesh**.
- Menara, tiang serambi, lis: **CylinderMesh**.
- Kubah (utama + kecil + tutup menara): **SphereMesh** setengah (dipipihkan sedikit
  untuk bentuk bawang) + bola kecil + bulan sabit (torus dipotong / dua bola).
- Lengkung pintu/jendela: **setengah silinder** di atas bukaan kotak + kusen kotak.
  Lengkung lancip disederhanakan jadi lengkung setengah lingkaran di game — tetap
  terbaca sebagai lengkung masjid.
- Mihrab: ceruk kotak + lengkung setengah silinder di atasnya.

Tidak ada elemen yang butuh mesh impor atau bentuk rumit.

## 6. Catatan jujur (yang perlu Mas tahu sebelum ACC)

- Gambar tampak depan vs perspektif Surau: tutup menara di tampak depan berwarna
  zamrud, di perspektif ter-render emas. Saat dibangun akan dipakai **zamrud**,
  kecuali Mas minta emas.
- Gambar tampak depan Musholla: ada panel lengkung kayu tinggi di atas serambi
  (tengah, lantai atas). Itu dimaksudkan sebagai **jendela lengkung tinggi**,
  bukan pintu kedua. Kalau Mas merasa aneh, panel itu dihapus saat dibangun.
- Denah digambar tangan (bukan dari gambar AI) supaya ukuran dan labelnya benar:
  1 kotak grid = 1 m, utara di atas, kiblat di kiri (barat).

## 7. Kalau Mas ACC — langkah berikutnya

1. Raka membangun Surau baru di (0,−12) dengan footprint & interior yang sama
   (interior 18 × 14 m tetap, supaya semua yang sudah ada di dalam — smartboard,
   rak kitab, posisi Kyai — tidak perlu dipindah).
2. Musholla baru dibangun bersamaan dengan relokasi Ronde 21 ke (62,−24).
3. Foto dari game dikirim ke Mas untuk cek ulang sebelum deploy.
