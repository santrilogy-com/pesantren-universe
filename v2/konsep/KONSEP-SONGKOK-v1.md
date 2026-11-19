# KONSEP — Perbaikan Songkok Putra + Songkok Hitam Nasional (v1)

Kirana, 19 Nov 2026 — masukan Mas 14:00 WIB. **KONSEP SAJA, belum dibangun
ke game** (menunggu ACC Mas). Tidak ada kode game yang diubah untuk konsep ini;
semua varian dirender lewat skrip foto `skrip/foto_songkok_konsep.gd`.

## 1. Masalah 1 — songkok menutupi sebagian mata: TERBUKTI + TERUKUR

Lokasi kode: `scripts/player.gd` ~:1248 (cabang `else`, santri putra).

| Bagian | Nilai sekarang |
|---|---|
| Kepala | bola r=0.24 di (0, 1.66, 0); puncak 1.90 |
| Mata | bola r=0.025 (skala y 1.25) di (±0.085, 1.69, 0.222) → membentang **y 1.659–1.721** |
| Peci (songkok bulat) | bola r=0.265 di (0, 1.77, 0), skala y 0.70 |
| PeciBand | silinder (0.26 / 0.27, h 0.04) di y=1.75 |

Tepi bawah peci di posisi mata (jarak horizontal dari sumbu d=0.2377):

```
y_tepi = 1.77 − 0.70·√(0.265² − 0.2377²) = 1.688
```

Mata membentang 1.659–1.721 → tepi peci di 1.688 **menutupi SETENGAH ATAS
mata** (1.688–1.721). Foto `konsep-songkok-sebelum-depan.png` membuktikannya:
mata hanya terlihat setengah bawahnya.

### Perbaikan — songkok bulat dinaikkan + sedikit dipipihkan

| Parameter | Sebelum | Sesudah (konsep) |
|---|---|---|
| Pusat peci | (0, 1.77, 0) | **(0, 1.82, 0)** |
| Skala peci | (1.0, 0.70, 1.0) | **(1.0, 0.68, 1.0)** |
| PeciBand | (0.26/0.27, h 0.04) @ y=1.75 | **(0.255/0.265, h 0.04) @ y=1.80** |

Hasil terukur: tepi bawah di posisi mata **y = 1.740** — 1,9 cm di atas
puncak mata (1.721). Puncak kubah 2.00 (tetap < 2.10 batas audit).
Sisi kubah di tinggi tepi: jari-jari 0.2375 vs kepala 0.2296 → kubah
tetap di luar kepala (tidak menembus). Foto
`konsep-songkok-sesudah-depan.png` + `-samping.png`: mata terlihat penuh,
dahi tampak wajar, rambut tepi di sisi kepala tetap mengintip seperti
sebelumnya (desain ronde 10, tidak berubah).

## 2. Masalah 2 — songkok hitam nasional (peci, atas rata)

Bentuk: **kerucut terpancung, atas RATA, sisi sedikit mengerucut ke dalam**
(bukan kubah). Dibangun dari primitif yang sama (tanpa model baru):

| Bagian | Nilai (konsep) |
|---|---|
| Badan peci | silinder atas r=0.205, bawah r=0.235, tinggi 0.18, pusat (0, 1.825, 0) → tepi bawah 1.735, puncak 1.915 |
| Lis bawah | silinder (0.235/0.24, h 0.03) di y=1.75 |
| Warna badan | **#151515** (hitam pekat) |
| Warna lis | **#0d0d0d** |

Tepi bawah 1.735 = 1,4 cm di atas puncak mata → mata terlihat penuh.
Puncak 1.915 masih di atas puncak kepala (1.90) tapi di bawah batas audit
2.10. Foto `konsep-peci-nasional-depan.png` + `-samping.png`: terbaca
jelas sebagai peci hitam Indonesia (atas rata, sisi lurus mengerucut),
bukan songkok bulat.

## 3. Siapa memakai apa (usulan — butuh keputusan Mas)

| Karakter | Usulan |
|---|---|
| Kyai (Ust. Aqsal Murad) | **Serban tetap** — tidak berubah |
| Ustadzah / santriwati | Jilbab — tidak terpengaruh |
| Satpam | **Peci hitam nasional** (cocok tampilan satpam Indonesia) |
| Santri putra NPC (Bilal, Faris, Sanusi + 50 NPC baru) | **Campur 50/50**: setengah songkok bulat putih (posisi baru), setengah peci hitam nasional — acak tapi tetap per NPC (hash nama/id, supaya tidak ganti-ganti tiap masuk) |
| Pemain (santri baru) | Default **songkok bulat putih** (outfit sekarang); peci nasional jadi pilihan ganti baju belakangan |

Kait implementasi (nanti, saat bangun): kunci outfit baru `peci_model`:
`"bulat"` | `"nasional"` di cabang `else` `build_visual` (`player.gd`);
nasional selalu hitam (`#151515`) apa pun warna `songkok`. Node varian
nasional sebaiknya tetap bernama `"Peci"` supaya `audit_karakter_primitif`
tidak perlu diubah (atau audit diperbarui menerima `"PeciNasional"`).

## 4. Foto konsep (7 file, `v2/konsep/`)

- `konsep-songkok-sebelum-depan.png` / `-samping.png` — masalah terbukti.
- `konsep-songkok-sesudah-depan.png` / `-samping.png` — bulat diperbaiki.
- `konsep-peci-nasional-depan.png` / `-samping.png` — peci hitam nasional.
- `konsep-songkok-banding.png` — ketiganya berdampingan, badan penuh.

Catatan jujur foto: label nama di close-up terpotong tepi atas frame
(artefak framing foto, bukan game); di foto samping peci, label "Bulat
Baru" karakter tengah sedikit mengintip di belakang (artefak foto).
Bercak rambut hitam di sisi kepala (tampak besar dari samping) SUDAH ADA
sebelum perbaikan — desain ronde 10, bukan akibat konsep ini.

## 5. Yang butuh keputusan Mas

1. Pembagian 50/50 acak per NPC — setuju, atau peci hanya untuk peran
   tertentu?
2. Satpam pakai peci hitam — setuju?
3. Pemain baru default tetap songkok bulat putih?
4. Warna peci: hitam pekat `#151515` seperti foto, atau lebih lembut?

Setelah ACC, dibangun ke game (ubah `player.gd` + kunci outfit +
`audit_karakter_primitif` bila perlu) lalu foto ulang verifikasi.
