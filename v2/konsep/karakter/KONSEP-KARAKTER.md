# KONSEP KARAKTER v2 — Lembar Gambar (Bukan 3D)

**Tanggal:** 17 November 2026, ~17:20 WIB (lembar 1–2) · **Revisi + lembar 3–5:** 17 November 2026, ~22:33–22:40 WIB
**Pembuat:** Kirana, Tim Karakter
**Cara kerja (perintah Mas 17:13):** karakter digambar dulu, disetor ke Mas, baru dinilai; kalau ACC baru dibangun 3D. Tidak ada 3D yang dibuat dari lembar ini sebelum ada verdict Mas.
**Metode gambar:** ilustrasi vektor datar hasil image generation yang dipandu gambar referensi Mas (`referensi-mas.jpg`) dan lembar lama, lalu disusun jadi lembar konsep dengan proporsi + palet yang DIUKUR dari gambar (bukan kira-kira). Gaya mengikuti pelajaran Syumra: wajah DATAR satu sistem, identitas dibawa peci/kacamata/jilbab/kostum.
**Metode ukur (mulai revisi 22:40):** kepala = puncak penutup kepala (peci/surban/jilbab/songkok) ke dagu — untuk Ustadz sampai ujung jenggot. Lembar lama memakai metode leher (batas bawah = leher), jadi angka lama tidak sebanding langsung: putra lama 3,4 (leher) = 3,0 (dagu) pada gambar baru.

## Daftar karakter v2 = 5 orang (Mas, 17 Nov ~22:33 WIB)

| # | File | Isi |
|---|---|---|
| 1 | [konsep-santri-putra.png](sandbox://workspace/pesantren-verse/v2/konsep/karakter/konsep-santri-putra.png) | Santri putra — depan + samping + tiga-perempat — **REVISI** |
| 2 | [konsep-santriwati.png](sandbox://workspace/pesantren-verse/v2/konsep/karakter/konsep-santriwati.png) | Santriwati — depan + samping + tiga-perempat — **REVISI** |
| 3 | [konsep-ustadz.png](sandbox://workspace/pesantren-verse/v2/konsep/karakter/konsep-ustadz.png) | Ustadz Aqsal Murad — depan + samping + tiga-perempat — **BARU** |
| 4 | [konsep-ustadzah.png](sandbox://workspace/pesantren-verse/v2/konsep/karakter/konsep-ustadzah.png) | Ustadzah Mariyah — depan + samping + tiga-perempat — **BARU** |
| 5 | [konsep-satpam.png](sandbox://workspace/pesantren-verse/v2/konsep/karakter/konsep-satpam.png) | Satpam — depan + samping + tiga-perempat — **BARU** |

File kerja (gambar mentah hasil generate + script komposisi): `kerja/` (`compose_sheets.py` — pengganti `compose.py` untuk 5 lembar; layout dibuat dinamis karena kepala dewasa > 4).

## Koreksi Mas yang sudah diterapkan (22:33–22:34 WIB)

1. **Santri putra pakai KOKO PUTIH + SANDAL** (bukan polo kuning + sepatu merah-putih). Koko: kerah tegak (mandarin) + kancing depan. Sandal coklat gelap sederhana (usulan Kirana — Mas yang nilai).
2. **Santri putra rambut PENDEK RAPI ala santri** (bukan poni lurus menutupi dahi seperti di konsep lama). Dahi terlihat.
3. **Santriwati JANGAN kelihatan rambut** — jilbab krem menutup rambut SEPENUHNYA, poni hitam di konsep lama DIHAPUS total.
4. **Santriwati pakai SANDAL juga** (bukan sepatu merah-putih). Kedua santri pakai sandal. (Membatalkan rencana awal mempertahankan sepatu putri.)

## Yang sudah sesuai referensi / v1

- **Wajah (semua):** satu sistem wajah datar — mata titik kecil, alis tebal, senyum tipis tertutup. Tanpa bola mata 3D, tanpa mulut merah (pelajaran Syumra; catatan: mulut di referensi sebenarnya terbuka dengan bibir merah + gigi, tapi konsep ini sengaja pakai senyum tertutup — lihat keputusan no. 6 di bawah).
- **Putra:** peci putih berkubah menempel, koko putih, sarung batik parang zamrud + emas, sandal coklat gelap, kacamata bundar besar.
- **Putri:** wajah sama persis gayanya dengan putra (satu keluarga karakter), jilbab krem menutup rambut sepenuhnya + drape ke bahu, abaya zamrud lengan panjang, hem emas motif parang, sandal coklat gelap, kacamata.
- **Ustadz (Ust. Aqsal Murad):** surban krem, janggut gelap beruban di ujung + kumis tipis, koko krem kerah tegak lengan panjang, sarung hitam sampai mata kaki, sandal gelap, TANPA kacamata. Warna ikut v1 (`OUTFIT_KYAI` di `mission_data.gd`: koko #F2EAD6, sarung #23282E, serban #F5F0E0, jenggot #2B241D).
- **Ustadzah (Mariyah):** jilbab krem menutup rambut sepenuhnya, abaya zamrud + hem emas parang, sandal gelap, TANPA kacamata. Warna ikut v1 (`OUTFIT_USTADZAH`: abaya #065F46, jilbab #F2EAD6).
- **Satpam:** koko biru gelap + songkok hitam + sarung hitam + lencana emas di dada + sandal hitam. Warna ikut v1 (`OUTFIT_SATPAM` di `mission_data.gd`: koko #2B3A4A, songkok #1A1A1A, sarung #2B2B2B) — BUKAN seragam navy + topi satpam standar seperti usulan awal; lencana ditambahkan supaya terbaca sebagai petugas, bukan santri. Sandal hitam usulan Kirana (v1 tidak menentukan alas kaki).
- **Tangan (semua):** sederhana, menggantung vertikal di sisi badan (bukan T-pose).
- **Palet terukur dari gambar** (bukan perkiraan): koko putih #E8E8E8, koko krem #F2EAD6, surban #F5F0E0, zamrud sarung #008062 / abaya #065F46 / putri #007A61, emas motif #E2B955 / hem #E4B955, kulit #FFC09F (Ustadz #D59E78 — kulitnya digambar lebih gelap), jilbab krem #F5E4CC / #F2EAD6, sandal coklat #4A3226, koko satpam #2B3A4A, songkok #1A1A1A, sarung hitam #2B2B2B / #23282E, jenggot #2B241D, emas lencana #C9A227.

## Proporsi terukur (metode dagu, dari gambar)

| Karakter | Kepala | Catatan |
|---|---|---|
| Santri putra | **3,0** | Lembar lama 3,4 (metode leher). Kepala di gambar baru sedikit lebih besar, tetap chibi dan terbaca di HP. |
| Santriwati | **2,5** | Lembar lama 2,8 (metode leher). Kepala+jilbab tampak LEBIH BESAR dari putra. |
| Ustadz | **4,7** | Dewasa, tinggi dan ramping. Usulan awal 5,5–6; gambar r2 (kepala dikecilkan sekali) mencapai 4,7. |
| Ustadzah | **5,1** | Dewasa, paling mendekati usulan 5,5–6 di antara tiga dewasa. |
| Satpam | **3,8** | Dewasa, tegap dan lebih kekar dari Ustadz (badan lebih lebar, kaki lebih pendek). |

## Yang masih ragu (catatan jujur)

1. **Proporsi dewasa belum sampai 5,5–6 kepala.** Gambar pertama dewasa terukur 3,1–4,6; setelah satu ronde "kecilkan kepala" jadi 3,8–5,1. Mereka terbaca dewasa (tinggi, ramping, bukan chibi anak) dan satu keluarga gaya dengan santri — tapi bukan realis 6 kepala. Perlu Mas putuskan: terima keluarga gaya ini, atau gambar ulang dengan kepala lebih kecil lagi.
2. **Proporsi kepala santri sedikit lebih besar dari lembar lama.** Putra 3,0 (dagu) vs lama 3,4 (leher); putri 2,5 (dagu) vs lama 2,8 (leher). Sebagian selisihnya karena ganti metode ukur, sebagian karena gambar baru memang berkepala sedikit lebih besar.
3. **Sarung putra di tampak depan terbaca seperti celana pendek** — ada belahan tengah di bawah yang membagi sarung jadi dua kaki. Di tampak samping terbaca benar sebagai satu lembar. Saat bangun 3D nanti sarung HARUS satu lembar melilit tanpa belahan kaki (sudah ditulis di lembar).
4. **Kacamata dari samping** terbaca sebagai batang hitam vertikal (lensa dilihat dari tepi). Masih terbaca sebagai kacamata, tapi agak berat. Opsi: biarkan, atau tipiskan jadi garis.
5. **Warna gambar sedikit lebih terang dari palet resmi PV** (zamrud gambar #008062 vs palet #065F46; emas gambar #E2B955 vs palet #C9A227). Perlu diputuskan: ikut warna gambar atau kunci ke palet PV.
6. **Peci dari samping** agak lebar/datar. Masih proporsional, tapi di 3D perlu dijaga jangan jadi helm.
7. **Panjang sarung** di gambar selutut (seperti celana pendek panjang). Sarung asli biasanya sampai mata kaki — perlu diputuskan. (Sarung Ustadz di gambar sudah sampai mata kaki.)
8. **Tangan** di gambar sederhana (seperti mitten halus). Di 3D nanti tetap tangan sederhana membulat, bukan jari-jari detail.
9. **Hem abaya Ustadzah** di gambar motifnya lebih mirip api/daun daripada parang — motif parang tidak terbaca jelas. Perlu diputuskan: terima, atau tegaskan motif parang saat bangun 3D.
10. **Sarung satpam** di gambar bermotif batik samar (bukan hitam polos seperti v1). Masih terbaca hitam; motifnya usulan gambar, bukan dari v1.

## Yang perlu Mas putuskan

1. **ACC kelima lembar ini?** (atau revisi — sebut bagian mana)
2. **Proporsi dewasa:** terima 3,8–5,1 kepala (satu keluarga gaya dengan santri), atau gambar ulang dengan kepala lebih kecil mendekati 5,5–6?
3. **Proporsi kepala santri:** pertahankan 3,0 (putra) / 2,5 (putri) yang terukur di gambar baru, atau kecilkan kepala mendekati angka lembar lama?
4. **Warna:** pakai warna persis seperti gambar, atau kunci ke palet PV (zamrud #065F46, emas #C9A227)?
5. **Panjang sarung putra:** selutut seperti gambar, atau sampai mata kaki?
6. **Putri:** jilbab dirampingkan sedikit supaya kepala tampak seumuran putra, atau biarkan?
7. **Mulut:** senyum tipis tertutup seperti konsep ini, atau mulut terbuka seperti referensi asli?
8. **Satpam:** sandal hitam seperti gambar, atau ganti sepatu hitam?
9. **Hem abaya Ustadzah:** terima motif gambar (mirip api/daun), atau tegaskan motif parang?
10. Kalau ACC — **jalur bangun 3D-nya yang mana:** lanjut game-skills fase 3–5 dari blockout Kirana, lanjut jalur Three.js Tara, atau Bima bangun dari lembar ini?

### Sudah diputuskan Mas (coret dari daftar tanya)
- ~~Santri putra koko putih + sandal (ganti polo kuning + sepatu)~~ — 22:33 WIB
- ~~Rambut putra pendek rapi (ganti poni lurus)~~ — 22:34 WIB
- ~~Santriwati jilbab tutup rambut penuh, tanpa poni~~ — 22:33 WIB
- ~~Santriwati sandal (ganti sepatu merah-putih)~~ — 22:34 WIB

## Langkah berikut (setelah verdict Mas)

- Kalau ACC: bangun 3D mengikuti lembar ini (proporsi + palet + catatan di atas), lalu setor render ke Mas seperti biasa — mulai dari clay putra.
- Kalau revisi: perbaiki gambarnya dulu, setor ulang — tetap belum sentuh 3D.
- v1 dibiarkan apa adanya (live, Ronde 24). Folder v2 tidak menyentuh file v1, Blender, Godot, atau game-skills-test.

## Catatan kerja clay putra (dihentikan 22:33 WIB)

Tugas clay putra v2 (22:17 WIB) DIHENTIKAN di tengah jalan karena konsep berubah (polo kuning + sepatu merah-putih sudah tidak berlaku). Yang sudah dibuat TERSIMPAN dan tidak dihapus — kepala/wajah mungkin masih terpakai saat bangun ulang dari lembar baru:
- `~/workspace/pesantren-verse/v2/model-3d/karakter/santri-putra-clay.blend` (4.622 tris, proporsi 3,43 kepala ke ubun — polo kuning, sepatu, poni lurus: semua sudah tidak berlaku)
- `~/workspace/pesantren-verse/v2/model-3d/karakter/build_santri_putra_clay.py` (skrip build)
- `~/workspace/pesantren-verse/v2/model-3d/karakter/render_clay.py` (skrip render)
- `~/workspace/pesantren-verse/v2/model-3d/karakter/render/santri-putra-clay_depan.png` (hanya 1 render selesai sebelum render dihentikan; samping + tiga-perempat tidak jadi)
- **TIDAK ADA 3D sampai 5 lembar konsep baru di-verdict Mas.**

## Clay putra v2 — lembar revisi (ACC Mas 22:47, dibangun Bima 22:52–22:57 WIB)

- `~/workspace/pesantren-verse/v2/model-3d/karakter/santri-putra-clay-v2.blend` (4.530 tris, proporsi **3,00 kepala** — puncak peci 1,020 m / kepala 0,340 m)
- `build_santri_putra_clay_v2.py` (skrip build, parametrik dari skrip clay lama) + `render_clay_v2.py` (kamera lebih dekat — render lama figurnya terlalu kecil)
- Render 3 view: `render/santri-putra-clay-v2_depan.png`, `..._samping.png`, `..._tiga-perempat.png`
- Sesuai lembar revisi: koko putih (kerah tegak mandarin + plakat + 3 kancing), sandal (sol + 2 tali), rambut pendek rapi — dahi telanjang (cangkang rambut dipotong di depan), peci berkubah menempel, sarung SATU lembar tanpa belahan, kacamata bundar besar, 3,0 kepala.
- Catatan jujur: peci dari depan agak datar/lebar (kubah dangkal); pita kerah mandarin samar di clay (plakat + kancing yang membawa bacaan koko); kacamata dari samping garis vertikal tipis (sama seperti tampak samping di lembar konsep); lengan agak pendek/kaku.
- **MENUNGGU VERDICT MAS (dikirim Xam 23:00). Jangan lanjut ke karakter lain / detail / tekstur sebelum clay ini di-verdict.**
