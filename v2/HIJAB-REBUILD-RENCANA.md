# HIJAB REBUILD — RENCANA & LAPORAN (Kirana, 18 Nov 2026)

Reset total setelah verdict Mas 12:10 WIB atas ronde 8:
"Jelek.. coba bikin dari awal lagi supaya sesuai gambar referensi"

## 1. Referensi satu-satunya

`v2/konsep/karakter/konsep-jilbab-v1.png` (di-ACC Mas 09:56 WIB):
kubah longgar; drape melengkung LEMBUT sampai dada tengah tepi U
(bukan kotak, bukan kolom lurus); tanpa pita hijau di kerah; belakang
satu kerudung menyatu; bukaan wajah OVAL LEMBUT — pipi tertutup, yang
terlihat hanya tengah wajah (mata, hidung, mulut, kacamata).
Palet: krem #F2EAD6 / zamrud #065F46 / emas #C9A227 / kulit #FFC09F.

## 2. Pendekatan — mesh prosedural satu permukaan

Semua node hijab ronde 1–8 DIHAPUS (kubah, HijabPanelSamping, strip,
HijabDagu, HijabLeher, drape 3 tier, lipatan, cape). Backup ronde 8:
`v2/backup-ronde8/` (player.gd.ronde8 + audit .ronde8, sha cocok).
Backup ronde 7 tetap di `v2/backup-ronde7/`.

Kerudung = SATU ArrayMesh yang digenerate dari kode
(`scripts/player.gd`, `_jilbab_kerudung_mesh()` + `_bahan_jilbab()` +
`_jilbab_profil/_jilbab_theta_buka/_jilbab_tepi_bawah/_jilbab_lipatan/
_jilbab_titik/_jilbab_interp`):
- Bagian A (hood): 21 baris y horizontal 1,975..1,44; pita wajah
  y 1,515..1,775 dipotong elips (tepi oval lembut, pipi tertutup).
- Bagian B (rok): 9 baris t, y 1,44 -> tepi bawah U (depan 0,88,
  45° 0,97, sisi 1,06, 135° 1,04, belakang 1,00), lingkaran penuh.
- Baris 0 Bagian B = seam baris terakhir A (simpul dibagi -> normal
  mulus); kipas apex; normal halus dihitung manual (akumulasi normal
  muka); UV u=θ/2π, v=(1,98−y)/1,10; kolom C=48.
- Lipatan lembut: modulasi radius ±3%, 6 lipatan, amplop 0 di atas
  y 1,50 -> penuh di bawah y 1,30.
- Kubah: bola R 0,30 pusat y 1,68 -> puncak 1,98 (bulat, bukan kerucut).
- Satu anak saja di container Hijab: `HijabKerudung` (MeshInstance3D).
  Recolor: 1 entri `HijabKerudung` (build + `_warnai_ulang`).

Geometri tubuh (otoritatif, dari player.gd): kepala bola r=0,24 di
(0, 1,66, 0); mata (±0,085, 1,69, 0,222); alis 1,735; mulut 1,55;
dagu ~1,47; kacamata lensa z≈0,238; abaya tabung r 0,23 (y 1,42) ->
0,36 (y 0,10); torso kapsul r=0,21 di y=1,06.

## 3. Tiga bug yang ditemukan & diperbaiki (iterasi v1 -> v4)

Semua ditemukan karena foto v1 dibaca sendiri + diukur pikselnya,
bukan karena tes hijau (audit + test_v2 hijau di semua versi).

### v1 -> v2: bahan COKELAT (tekstur jersey)
- Gejala: kubah (173,141,116) cokelat, padahal albedo krem #f5e4cc.
- Akar: `_bahan_kain` memakai tekstur cotton jersey (rata-rata tan
  #C2AB9D, 0% piksel terang) — albedo krem x tekstur tan = cokelat.
  Ronde 8 tampak krem karena tekstur saat itu belum termuat.
- Perbaikan: `_bahan_jilbab` kini PLAIN (`Palette.mat(warna, 0, 0.45)`,
  tanpa tekstur) + `cull_mode = CULL_DISABLED` (double-sided: sisi
  dalam terlihat lewat bukaan + hem). `_lembutkan` dikecualikan untuk
  `HijabKerudung` supaya bahan double-sided tidak diganti
  `Palette.mat` biasa (itu mengembalikan backface-culling).
- Hasil v2: kubah (224,203,173) — lebih terang, tapi MASIH tan.

### v2 -> v3: puncak kerucut (profil kubah)
- Gejala: puncak agak runcing + kubah tetap tan.
- Akar: kunci profil (1,74, 0,28) -> (1,995, 0,005) satu interpolasi
  panjang = kerucut; normal atas miring ~70° dari vertikal.
- Perbaikan: puncak diturunkan ke 1,98 (bola R 0,30 pusat y 1,68),
  baris 1,975 (r 0,055) ditambah, kunci profil (1,975, 0,055) +
  (1,98, 0,005); UV v ikut (1,98−y)/1,10.
- Hasil v3: puncak (239,233,220) lebih terang, kubah tetap
  (224,203,173) — belum cukup.

### v3 -> v4: WINDING TERBALIK (akar utama warna tan)
- Gejala: kubah (224,203,173) di SEMUA kondisi — bayangan on/off,
  cast_shadow on/off tidak mengubah apa-apa; bola primitif dgn bahan
  SAMA di adegan sama render putih terang; wajah tidak berubah.
- Diagnosis (debug shader normal -> warna): normal render TERBALIK
  dari normal array (array terverifikasi benar: apex (0,1,0),
  dot radial tengah 0,933, drape 0,984). Mesh asli vs mesh winding
  dibalik berdampingan: yang dibalik render BENAR (puncak hijau =
  normal ke atas, drape biru = normal ke depan).
- Akar: **Godot menganggap front face = CW bila dilihat dari luar**
  (bukan CCW seperti asumsi awal). Winding (a,c,b) terbaca backface
  -> renderer membalik normal -> permukaan hanya kena ambient +
  fill, tanpa matahari -> tan kusam ~12% lebih gelap.
- Perbaikan: SEMUA segitiga dibalik — kipas (puncak,b,a), quad A
  (a,b,c)/(b,d,c), quad B (a,b,c)/(b,d,c) — DAN cross normal dibalik
  ((vc−va)x(vb−va)) supaya normal array tetap mengarah KELUAR.
  `cast_shadow = OFF` (hipotesis bayangan, terbukti salah) DIHAPUS
  lagi — kerudung kembali cast shadow normal.
- Hasil v4: kubah (255,255,255) — krem terang, SAMA seperti ronde 8
  (255,255,219) dan sesuai konsep. Wajah tetap (255,192,145).

Catatan: bug winding ini pelajaran umum untuk SEMUA mesh prosedural
berikutnya — selalu uji visual normal (shader normal->warna) atau
bandingkan dgn primitif, jangan hanya percaya cek numerik (cek
winding Python tidak menangkapnya: ia memakai normal geometri, bukan
konvensi front-face Godot).

## 4. Verifikasi (v4 final)

- Prototipe Python `skrip/grid_jilbab_rebuild.py`: 1.393 simpul,
  2.716 segitiga; 0 winding mencurigakan; normal keluar 1392/1393
  (1 sisanya apex, radial ~0); normal puncak (0, 1, 0,004);
  jarak min ke pusat kepala 0,2481 (>0,24); margin min ke abaya
  0,0120 (>0); 0 simpul kain di depan tengah wajah; pipi 7/7;
  dagu 28 simpul; tepi bukaan y=1,69 x±0,157 z=0,191, y=1,62
  ±0,159 z=0,196, y=1,55 ±0,109 z=0,229; AABB x ±0,295,
  y 0,88..1,98, z −0,314..0,323.
- Audit karakter: **168 lulus, 0 gagal**.
- test_v2: **60 lulus, 0 gagal**.
- Foto: **22/22** (`skrip/foto_hijab.tscn -- sesudah`), putri +
  Ustadzah Mariyah (depan/samping/belakang/tigaperempat/wajah/
  jalan, siang + malam). Arsip: `v2/foto-hijab/rebuild-sesudah/`.

## 5. Perbandingan dgn gambar konsep (dibaca sendiri)

| Butir konsep | Hasil v4 |
|---|---|
| Kubah longgar | ✅ dome bulat (bola R 0,30), bukan topi ketat |
| Drape lembut sampai dada tengah, tepi U | ✅ satu kain utuh kubah->dada, tepi bawah U (depan 0,88) |
| Tanpa pita hijau | ✅ tidak ada hijau di kerah |
| Belakang satu kerudung menyatu | ✅ belakang mulus, tanpa sambungan |
| Bukaan wajah oval lembut | ✅ oval, tepi halus |
| Pipi tertutup, hanya tengah wajah | ✅ grid 0 kain di tengah wajah, pipi 7/7; foto: mata/hidung/mulut/kacamata terlihat, pipi tertutup |
| Kacamata terlihat | ✅ penuh (putri) |
| Krem | ✅ (255,255,255) di foto siang — sama terangnya dgn ronde 8 |
| Satu kain (bukan potongan) | ✅ 1 ArrayMesh, 1 permukaan |

Catatan jujur:
- Di foto siang, area kena matahari nyaris putih polos (clipping) —
  sama seperti ronde 8; di dalam game (pencahayaan lebih hangat/
  redup) akan terbaca krem lembut seperti konsep. Bentuk kubah
  tetap terbaca dari siluet + sisi berbayang.
- Siluet kubah di close-up masih sedikit faset (48-gon) — wajar
  untuk gaya primitif/low-poly karakter ini.
- Bukaan wajah cukup lebar (oval besar) — sesuai elips spec
  (pusat 1,645, setengah tinggi 0,13, setengah sudut 0,63 rad).

## 6. File yang diubah (hanya yang diizinkan)

- `v2/godot-dunia/scripts/player.gd` — hapus semua node hijab
  ronde 1–8; tambah `_jilbab_kerudung_mesh()` +
  `_bahan_jilbab()` + helper `_jilbab_*`; branch `elif pakai_hijab:`
  baru (1 anak `HijabKerudung`); recolor 1 entri; pengecualian
  `_lembutkan` untuk `HijabKerudung`.
- `v2/godot-dunia/skrip/audit_karakter_primitif.gd` — ditulis ulang
  (229 baris): cek `HijabKerudung` ada, Hijab 1 anak, ArrayMesh
  1 permukaan, 19 node lama tidak ada, AABB, cek simpul mesh.
- `v2/godot-dunia/skrip/grid_jilbab_rebuild.py` — prototipe +
  verifikasi numerik (cermin kode GDScript, termasuk winding CW).
- `v2/godot-dunia/skrip/foto_hijab.gd/.tscn` — tidak diubah
  (hanya dipakai; flag shadow sementara sudah dikembalikan).
- `v2/HIJAB-REBUILD-RENCANA.md` — dokumen ini.
- Debug sementara (`skrip/debug_jilbab.gd/.tscn`) sudah DIHAPUS.
- TIDAK disentuh: main.gd, kampus_putri.gd, file interior,
  kamera.gd. TIDAK deploy (Xam yang urus export + deploy).

## 7. Status

SELESAI + TERUJI, menunggu verdict Mas. Foto 22/22 di
`v2/foto-hijab/*_sesudah.png` (+ arsip `rebuild-sesudah/`).
