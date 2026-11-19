# HIJAB PUTRI RONDE 2 — Rencana penerapan (Kirana, 18 Nov 2026, ~07:55 WIB)

Verdict Mas (07:47 WIB, dari foto): "Masih tetap.. di bawah kepala (di bahu)
kaya ada piringan. Terus bagian belakang aneh.. kek bukan jilbab penutup
kepala.. bagian belakang kepala terlihat."

## Diagnosis (baca sendiri dari foto `v2/foto-hijab/*_sesudah.png` ronde 1)

- Belakang: kubah duduk seperti topi/beret terpisah; kulit peach TERLIHAT di
  kedua sisi kepala di bawah kubah; drape belakang lempeng oval terpisah
  (terbaca panel/backpack), tidak menyatu dengan kubah.
- Depan: cape masih terbaca piringan datar di bahu (cakram 0,68 x 0,10 m).
- Samping: cape seperti pelampung di sekeliling leher; drape belakang panel
  datar menggantung di belakang kepala.

## Akar geometri (kepala: bola r=0,24 di y=1,66; R(y)=sqrt(0,24^2-(y-1,66)^2))

1. Kubah lama (r=0,25 di (0,1,78,-0,04), skala 1,02/0,58/1,02): di y=1,70
   lebarnya cuma ±0,213 < kepala ±0,237; di y=1,66 cuma ±0,143 < kepala
   ±0,24. Kepala menggelembung keluar di bawah rim kubah — itulah kulit
   yang terlihat di kedua sisi.
2. Drape lama (elipsoid, pusat y=1,36): menyempit ke atas — di y=1,66
   lebarnya cuma ±0,136 < kepala ±0,24. Elipsoid TIDAK BISA lebar di atas
   sekaligus panjang ke bawah (puncaknya ikut naik menembus kubah).
   Solusi: frustum/silinder — radius (hampir) konstan sepanjang tinggi.
3. Cape (cakram datar 0,68 m): bentuknya memang piringan; harus dihapus.
   Di bawahnya TIDAK ada mesh leher (kepala bawah y=1,42; torso puncak
   1,39; abaya atas 1,42) — pita leher y 1,42..1,47 terbuka. Pengganti cape
   harus menutup pita ini dari semua sisi + celah samping antara kerah
   dan strip sisi.
4. Celah samping yang selama ini ditutup cape: di y~1,44, x~±0,17 (antara
   kerah dan strip sisi) ada lubang tembus pandang kalau cape dihapus
   begitu saja. Pengganti cape harus mencapai x ±0,20 di y 1,42..1,47.

## Nilai lama -> nilai baru (hanya cabang hijab player.gd, ~781-905)

### 1. HijabKubah — DIPERBESAR + digeser (bukan lagi topi kecil)
- Lama: sphere r=0,25 di (0, 1,78, -0,04), skala (1,02, 0,58, 1,02).
- Baru: sphere r=0,26 di (0, 1,74, -0,04), skala (1,05, 0,75, 0,95).
  Sumbu: x ±0,273, y 1,545..1,935, z -0,287..0,207.
- Bukti hitung: lebar di y=1,66 -> ±0,249 (kepala 0,24, margin +0,009);
  y=1,70 -> ±0,267 (kepala 0,237); belakang z di y=1,66 -> -0,265
  (kepala -0,24). Rim depan menyilang wajah di y~1,80 (tengah) s.d.
  ~1,745 (sisi) — busur lembut di atas alis (1,735), bukan garis topi.
- Wajah aman: permukaan kubah di tinggi mata (y=1,69, x=±0,085) z=0,186
  vs mata belakang 0,202 (clear 0,016); di tinggi alis z=0,195 vs alis
  belakang 0,214 (clear 0,019). Kacamata tidak tersentuh (depan z>0,23).

### 2. HijabDrape — ELIPSOID -> FRUSTUM SILINDER (lebar di atas)
- Lama: sphere r=0,28 di (0, 1,36, -0,24), skala (0,80, 1,35, 0,22).
- Baru: `Palette.cylinder(0,25, 0,22, 0,70, Vector3(0, 1,43, -0,15))`,
  skala (1, 1, 0,52). y 1,08..1,78; x ±0,25 (atas) -> ±0,22 (bawah);
  z -0,280..-0,020 (atas) -> -0,264..-0,036 (bawah).
- Bukti hitung: r(1,63)=0,244 > kepala 0,238; r(1,55)=0,239 > 0,213;
  r(1,50)=0,238 > 0,179. Dari belakang, siluet: drape 0,25 lebar sampai
  y~1,66 lalu kubah 0,249..0,273 — SATU garis luar kontinu, terlebar di
  kepala, mengecil ke bawah seperti kain jatuh. Bukan panel lagi.
- Sambungan ke kubah: di rim atas (y=1,78) belakang drape -0,280 vs
  belakang kubah -0,282 — kubah 0,002 lebih ke belakang, rim drape
  tersembunyi di balik kubah; warna SAMA: terbaca lipatan kain.
- Posisi maju (z -0,185 -> -0,15) + tebal (skala z 0,42 -> 0,52):
  menutup pita sisi y 1,55..1,66, z -0,08..-0,13 yang ditemukan saat
  verifikasi grid (di belakang strip, di depan drape lama). Verifikasi
  grid final: 0 celah belakang; 0 celah samping di z<=-0,05; 50 titik
  tersisa hanya di z~-0,01..0,01 = sisi pipi/rahang — itu wajah,
  memang harus terlihat.
- Audit: belakang z -0,280 >= -0,32 (lolos); bukan BoxMesh (CylinderMesh).
- Ujung bawah y=1,08: belakang -0,264, praktis rata dengan abaya
  (-0,263) — ujung kain menyatu ke punggung, bukan tepi menggantung.

### 3. HijabCape — DIHAPUS (seluruh blok)
- Piringan cakram 0,68 x 0,10 m hilang. Tidak ada pengganti berbentuk
  cakram. Fungsinya (menutup leher) diganti HijabLeher di bawah.

### 4. HijabLeher — BARU (pengganti cape: bungkus dagu/leher, bukan piring)
- Baru: sphere r=0,21 di (0, 1,42, 0), skala (1,0, 0,45, 0,58).
  Sumbu: x ±0,21, y 1,33..1,51, z ±0,122. Warna SAMA kubah (tak digelap).
- Bukti hitung: di y=1,44 lebar x ±0,205 — menutup celah samping sampai
  tepi dalam strip (0,169); di y=1,47 x ±0,174 vs tepi dalam strip 0,172
  (tumpang tindih, tak ada celah). Depan z di y=1,45 = 0,115 vs rahang
  0,116 (rata, TIDAK menonjol seperti bundel); di y=1,47 depan z=0,101
  vs dagu 0,147 (tersembunyi di balik dagu); rim samping ±0,174 di y=1,47
  vs kepala 0,147 (pita kain 0,027 membingkai rahang — wajar untuk jilbab).
  Ujung atas (y=1,51) masuk ke dalam kepala; ujung bawah (y=1,33) masuk
  ke dalam abaya (r 0,239) — tidak ada tepi menggantung.
- Belakang leher: di y=1,44, drape (x ±0,235, z -0,27..-0,03) menutup
  punggung leher; leher + drape bertemu tanpa celah.
- Saat duduk: abaya melebar 1,65x, atas tetap ~1,42 — leher tetap
  tertutup (oleh abaya bila leher tenggelam; kubah+drape+depan+strip
  tetap terbaca, seperti kompromi ronde 1 untuk cape).

### 5. HijabDepan — TIDAK BERUBAH (ronde 1 sudah benar, telur hilang)
- sphere r=0,20 di (0, 1,18, 0,20), skala (0,72, 1,15, 0,30), rot.x -0,10.

### 6. HijabSisiKiri/Kanan — DIGESER + DITEBALKAN (menutup pita sisi)
- Lama: kapsul r=0,035 tinggi 0,40 di (±0,225, 1,56, 0), rot.z ∓0,10.
- Baru: kapsul r=0,04 tinggi 0,40 di (±0,225, 1,56, -0,05), rot.z ∓0,10.
  Alasan: strip lama di z=0 tidak mencapai pita sisi z -0,08..-0,13
  (kulit terlihat dari samping di y 1,55..1,66). Strip baru duduk di
  tepi belakang wajah (z -0,09..-0,01): dari samping menutup sampai
  drape; dari depan bingkai wajah tetap sama (sumbu x tak berubah).
  Bukaan: tepi dalam di tinggi mata ~0,198 (bukaan ~0,40); AABB lebar
  0,12 <= 0,13 (audit).
  Ujung atas masuk ke kubah baru (kubah di y=1,76: x ±0,272, z
  -0,176..0,096 — strip di z -0,09..-0,01 di dalamnya); ujung bawah
  masuk ke bahu abaya (tepi luar 0,245 vs abaya 0,236 di y=1,36 —
  muncul 0,009 dari bahu, terbaca strip menyambung ke bahu).

## Warna (fungsi recolor di player.gd ~1164-1174, jalur yang sama)
- Daftar warna-sama: ["HijabKubah", "HijabCape", "HijabDepan"] ->
  ["HijabKubah", "HijabDrape", "HijabDepan", "HijabLeher"].
  (HijabCape dihapus; HijabLeher masuk; HijabDrape PINDAH dari daftar
  gelap — build ronde 1 memang membangun drape dengan warna SAMA
  (tanpa penggelapan), tapi recolor masih menggelapkannya 0,03:
  komentar recolor-nya basi. Diselaraskan ke build.)
- Daftar gelap (0,03): ["HijabDrape", "HijabSisiKiri", "HijabSisiKanan"]
  -> ["HijabSisiKiri", "HijabSisiKanan"] saja.
- Berlaku juga untuk Ustadzah Mariyah (konstruksi sama, krem #f2ead6).

## Audit (skrip/audit_karakter_primitif.gd, blok hijab saja — preseden ronde 1)
- 2 cek cape jadi vakum bila node dihapus (AABB kosong: 0 <= 0,72 lolos
  tanpa arti). Diganti cek ronde 2: cape TIDAK ada; HijabLeher ada;
  leher beririsan kepala DAN abaya; drape lebar di atas (size.x >= 0,48,
  aktual 0,50); kubah lebih lebar dari kepala (size.x >= 0,52, aktual
  0,546 vs kepala 0,48).
- Cek lain tetap: drape ada, bukan BoxMesh, strip bukan kotak, depan
  z <= 0,30, drape belakang z >= -0,32, bukaan wajah (strip pusat
  |x| >= 0,20, lebar <= 0,13).

## Cara verifikasi (tanpa celah kulit)
1. Hitung: tabel R(y) kepala vs lebar kubah/drape/leher di tiap y
   1,42..1,93 + verifikasi grid (langkah 0,01): 0 celah dari belakang,
   0 celah dari samping di z<=-0,05; sisa hanya z~-0,01..0,01 = sisi
   pipi/rahang (wajah — memang harus terlihat).
2. Audit headless: `godot --headless --path . skrip/audit_karakter_primitif.tscn`
   — harus 0 gagal (ronde 1: 122/0).
3. Foto: `xvfb-run godot --path . skrip/foto_hijab.tscn -- sesudah`
   (arsipkan dulu `*_sesudah.png` ronde 1 ke `foto-hijab/ronde1-sesudah/`
   supaya bukti sebelum/sesudah tidak hilang). Baca sendiri foto
   BELAKANG siang+malam, putri+ustadzah: tidak ada kulit di sisi
   kepala, satu penutup menyatu; depan: tidak ada piringan; samping:
   tidak ada panel terpisah; wajah: mata/alis/mulut utuh, bukaan 0,38.
4. Jalan (depan+samping, siang+malam): siluet hijab tetap menyatu saat
   lengan/kaki mengayun.

## Yang TIDAK disentuh
- main.gd, kampus_putri.gd, file export/staging (Rangga staging paralel).
- Hanya cabang hijab player.gd + blok cek hijab di skrip audit.
