# RONDE 22 — STATUS

**Koordinator: Raka. SELESAI + EXPORT 17 Nov ~06:44 WIB. TIDAK deploy.**

## Perintah Mas
- 17 Nov ~06:11 WIB: ACC desain tembok keliling (Gilang) → bangun Ronde 22.
- 17 Nov ~06:05 WIB: "Sama jalan kok belum rapi ya.. terutama yg ke surau itu tidak lurus" → perbaiki jalan ke Surau.
- 17 Nov ~06:21 WIB: "Perbaiki juga gunungnya.. yg warna biru kek ada toping putih di pucuknya." → hapus topi salju + ganti warna biru.
- 17 Nov ~06:23 WIB: "Jangan raka semua yg ngerjain.. ada timnya kan? Biar cepet selesai." → Raka KOORDINATOR saja; tim kerja paralel, tiap orang file-nya sendiri.

## Scope (desain ACC Gilang)
1. **Tembok keliling pondok putri:** persegi x 115..180, z −52..+22 (65×74 m), krem #F2EAD6 + lis emas + fondasi batu, 3 m × 0,4 m, collision penuh. Gerbang barat (115,0), bukaan z −2..+2, pintu TERTUTUP + barrier penuh. Tembok x=14 TETAP; pagar kayu taman Musholla TETAP; Pos Jaga TL (160,−35) TETAP.
2. **Jalan akses + jalan masuk:** jalan E-W (14,0)→(115,0) bersih dan lurus; jalan masuk internal (115,0)→(115,8)→(142,8) membelok lewat selatan Kelas Putri (130,0).
3. **Audit pohon di garis tembok** (catatan jujur Gilang: belum diaudit).
4. **Perbaiki jalan ke Surau** (lurus + rapi); jalan pendek ke plot Masjid (0,−19) jangan menabrak Surau.
5. **Masjid Putri (134,−40) TIDAK dibangun** — reserve saja.
6. **Gunung (tambahan 06:21 WIB):** hapus topi salju putih, ganti biru #6b7a8a jadi hijau alami.

## Pembagian tim (file sendiri-sendiri)
- **Cakra — tembok keliling + gerbang barat:** `scripts/tembok_putri.gd` (BARU, `class_name TembokPutri`, `bangun(root)`); konstanta `KELILING_*` + `GERBANG_PUTRI_POS` di file ini. Juga hapus `_jalan_masuk` dari `kampus_putri.gd` (jalan pindah ke Sinta).
- **Sinta — semua jalan:** `scripts/jalan_ronde22.gd` (BARU, `class_name JalanRonde22`, `bangun(root)`); 3 segmen N-S + jalan masuk (grup `JalanMasuk`); verifikasi jalan E-W sudah tercakup (tanpa duplikat). Tugas lamanya (selesai lebih dulu): `mission_data.gd` plot Masjid (0,−26)→(0,−32); `main.gd` rute Ustadzah lewat gerbang (115,0) + default `_musholla_exit` diperbaiki (15.67,−19.01)→(134,−17.5); `ui.gd` tembok keliling di peta besar + minimap.
- **Wulan — audit + tes + foto:** `ronde-22/skrip/` (`test_ronde22.gd`, `audit_jalan_lampu.gd`, `foto_ronde22.gd` + `.tscn`).
- **Raka — koordinasi + gunung + merge + verifikasi + export:** gunung di `pesantren_builder.gd` (`_gunung`: salju dihapus, #6b7a8a→#5f7055); merge; smoke test; export. Hanya Raka yang edit `pesantren_builder.gd`.

## Merge (Raka)
- `build()`: `_tembok_keliling(root)` → `TembokPutri.bangun(root)` + `JalanRonde22.bangun(root)` (sekali).
- Dihapus dari `pesantren_builder.gd`: fungsi `_tembok_keliling` (89 baris), konstanta `KELILING_*` + `GERBANG_PUTRI_POS` (dict kini membaca `TembokPutri.*`), 3 box N-S di `_ground` (E-W + stub selatan + jalan sawah tetap).
- Catatan jujur: tembok + jalan Surau + jalan masuk sempat dibangun Raka/Cakra dalam susunan lama (smoke 29/29) — sesuai perintah Mas 06:23, pekerjaan itu diambil alih tim di file baru dari spesifikasi persis yang sudah terverifikasi; versi lama dihapus saat merge.

## Verifikasi (semua lolos)
- **Tes `test_ronde22.gd`: 259 LOLOS / 0 GAGAL** (197 baseline Ronde 21 + 62 baru), exit 0, 0 SCRIPT ERROR, 0 NaN, smoke 600 frame selesai. Log: `/tmp/wulan_test_r22.log`.
- **Audit jalan+lampu: 161 LOLOS / 0 GAGAL** (17 jalan, 13 lampu, 4 pilar gerbang, 8 tiang papan, 61 pohon, 3 tiang tinggi; semua ≥ ambang 1,0 m / 0,5 m gerbang). Log: `/tmp/wulan_audit_r22.log`.
- **Smoke test Raka (gabungan): 33/33 LOLOS, gagal=0** (tembok + jalan dari file baru + 4 cek gunung).
- `--check-only` 7 file tersentuh OK; `--headless --import` OK. Root proyek bersih (hanya `main.tscn` + 4 `.uid` yatim dihapus).
- **Foto 10/10 (25–34) di `foto-ronde-20/`, semua DILIHAT Raka:**
  - 25 tembok barat + gerbang: krem + lis emas, pintu coklat TERTUTUP, label GERBANG PUTRI kecil dari jauh, jalan pasir ke gerbang, kubah Musholla di balik tembok.
  - 26 tembok utara, 27 tembok timur: dinding panjang + lis emas, kampus putri + kubah Musholla di baliknya.
  - 28 tembok selatan: sisi luar tampak **abu-abu gelap, bukan krem** (shading sisi selatan — lihat catatan).
  - 29 jalan masuk: gerbang + jalan membelok 2 kaki + Kelas Putri + Musholla + tembok, semua jelas (terbaik).
  - 30 jalan Surau utara: RETAKE dari (12,6,−34) — dinding utara Surau (3 jendela lengkung berlis emas), kubah + menara, gunung hijau di latar, jalan putih membelok di depan dinding, tidak menabrak Surau.
  - 31 jalan Surau selatan: Surau + serambi, jalan membelok + persimpangan T dengan jalan E-W, lampu, santri baju putih.
  - 32 plot Masjid baru: alas putih + papan LAHAN MASJID BESAR + jalan E-W (komposisi kurang ideal: dinding Surau ¼ kiri, pohon menutupi kanan bawah).
  - 33 Musholla regresi: Musholla utuh (kubah + sabit emas, plakat, serambi + pagar kayu).
  - 34 gunung: **dua kerucut hijau (gelap + muda), puncak runcing tanpa topi salju putih, tanpa biru** — perintah Mas terpenuhi.

## Catatan jujur / bukan blocker
- Sisi luar tembok selatan (foto 28) tampak abu-abu gelap, bukan krem seperti sisi lain — kemungkinan shading (sisi selatan membelakangi matahari). Perlu verdict Mas; bukan blocker.
- Mepet ambang (lolos, dicatat): 7 lampu di x=−2,5 tepat 1,00 m dari tepi jalan; PosJagaTL (160,−35) 1,03 m dari jalan; ujung jalan utara (0,−24) 1,06 m dari footprint Surau.
- 1 pohon DI DALAM keliling: (130,−40), 11,80 m dari tembok selatan — pohon yang sudah dikenal (4 m di barat calon Masjid Putri Opsi A), bukan di garis tembok; pindah saat Fase D.
- Label GERBANG PUTRI kecil/kurang terbaca dari jauh (foto 25).

## Export (Raka, 17 Nov ~06:44 WIB) — TIDAK deploy
- Perintah: `godot --headless --export-release "Web"`, exit 0.
- **`index.pck` BARU 1.596.276 byte, sha256 `df62aa350fb18b25708037d5568926989d9ec4448e42b8437cd5a6577a8e3279`** (tumbuh 5.492 byte dari Ronde 21: 1.590.784).
- `tembok_putri.gd/.gdc` + `jalan_ronde22.gd/.gdc` terkonfirmasi DI DALAM pck.
- wasm TIDAK berubah (`fc74679e…`, 39.514.754 byte); index.js TIDAK berubah (`33c94cb3…`, 279.815 byte); worklet `index.audio.position.worklet.js` ada (2.973 byte, `be33985b…`).
- Fresh export `index.html`: 2 `<script>` / 2 `</script>` (normal — patch wasm jadi 3/3 dikerjakan Damar saat sinkron staging); GODOT_CONFIG `fileSizes` pck 1596276, wasm 39514754.
- Staging `export/web-pages/` TIDAK disentuh — sinkron + deploy urusan Damar setelah ACC Mas.
