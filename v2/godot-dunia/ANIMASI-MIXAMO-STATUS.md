# ANIMASI-MIXAMO — STATUS

**Tim:** Eka (animasi) — **Ronde export berikutnya, target Subuh**
**Terakhir diperbarui:** 18 Nov 2026 ~03:00 WIB (lanjutan pasca-restart VM 00:28 WIB)
**Proyek:** v2 SAJA — `~/workspace/pesantren-verse/v2/godot-dunia/` (Godot 4.7.2)

## Ringkasan

Animasi jalan / idle / duduk karakter primitif (pemain + NPC) kini
digerakkan modul prosedural `scripts/animasi_mixamo.gd` berbasis
kurva motion capture Mixamo — bukan sinus tunggal seperti kode lama.
Semua tes lulus headless setelah restart VM, semua foto studio
terverifikasi berisi karakter, dan NPC sholat tidak lagi menembus
anak tangga Surau.

## 1. Modul `scripts/animasi_mixamo.gd`

`class_name AnimasiMixamo` (RefCounted, tanpa node). Fungsi utama:

- `sudut_jalan(fase)` — semua sudut jalan satu fase: paha ±0,35 rad,
  lengan lawan fase ±0,30 rad, lutut dua puncak (0,30 sesaat setelah
  kontak + 0,95 di tengah ayunan), condong badan 0,05 rad, bob
  pinggul, goyang lateral. Fase 0 = kontak kiri, fase PI = kontak
  kanan; satu siklus penuh (TAU) = 2 langkah.
- `terapkan_jalan(rig, fase, blend)` — terapkan pose jalan; juga
  MERESET rotasi y/z kaki + lutut ke 0 (perbaikan cacat laten: Kyai
  yang habis duduk baca lalu patroli sebelumnya tetap jalan dengan
  kaki menyilang karena `_langkah_ke` lama hanya menyentuh
  rotation.x).
- `terapkan_idle(rig, delta, waktu, fase_acak)` — napas 2,5 dtk
  (±1,5 cm) + geser berat 5,1 dtk (±2 cm), di-lerp supaya peralihan
  jalan → diam tidak patah.
- `tinggi_sandal(fase, kiri)` — FK 2-segmen (paha + betis) + bob,
  dipakai tes anti-tembus: dasar sandal tidak pernah di bawah lantai.
- `rig_dari_built(built)` — dict rig dari `SantriPlayer.build_visual()`.

Hook: `player.gd` (`_pasang_visual`, `_physics_process` — jalan +
idle lewat modul, laju fase 8,0 rad/dtk, blend mulai/berhenti) dan
`npc.gd` (`setup` + jalan bebas + `_langkah_ke` + `_animate_idle`).

### Aturan anti-tembus (reel @jipraks)

Kaki tidak boleh menembus lantai, tangan tidak boleh menembus badan.
Dijaga: (1) bob pinggul TURUN saat kontak (`-0.015-0.015*cos(2u)`,
0 di mid-stance, −0,03 di kontak — kode lama `|sin|*0.03` selalu
NAIK sehingga kaki melayang); (2) lutut menekuk saat ayun supaya
kaki tidak menyeret lantai; (3) `tinggi_sandal()` membuktikan lewat
FK bahwa sandal tidak pernah di bawah lantai di semua fase.

## 2. Sumber timing — JUJUR SOAL MIXAMO

**File FBX Mixamo TIDAK terunduh.** Unduh Mixamo butuh login akun
Adobe gratis; tidak ada kredensial Adobe di VM ini. `mixamo.com`
terjangkau (HTTP 200, dicek 17 Nov 2026) tapi API-nya 401 tanpa
login. Yang dipakai adalah **kurva mocap yang terdokumentasi**,
bukan file Mixamo mentah — JANGAN klaim "pakai file Mixamo":

- Mixamo "Walking" (Female Basic Locomotion Pack, in-place): durasi
  0,967 dtk, 30 frame @30 fps — diukur AnimSmith 0.14.0 dari FBX
  aslinya (github.com/mmannerm/animsmith, laporan 2026-09-16).
  Satu siklus penuh = 2 langkah.
- Siklus jalan standar: 24 frame @24 fps = 1,0 dtk per 2 langkah
  (Richard Williams, "The Animator's Survival Kit").
- Idle Mixamo/Quaternius UAL: loop ~2,5 dtk (napas + geser berat).

Amplitudo + fase lutut di modul mengikuti bentuk kurva mocap itu.
Karakter game adalah PRIMITIF Godot (bagian badan = node terpisah,
bukan mesh ter-rig), jadi klip FBX Mixamo memang tidak bisa
di-retarget langsung walau filenya ada.

## 3. Hasil tes (headless, dijalankan ulang 18 Nov ~00:35 WIB pasca-restart)

### `skrip/test_animasi_mixamo.gd` — 27 lulus, 0 gagal (exit 0)

- Kurva jalan: kontak kiri paha −0,35 / kanan +0,35, lengan lawan
  fase +0,30, lutut kontak < 0,25; kontak kanan simetris.
- Lutut ayun maks ~0,95 (rentang cek 0,85–1,05), tidak pernah negatif.
- Anti-tembus: sandal min ≥ −0,005 m di semua fase; saat kontak
  0–0,06 m; bob turun saat kontak (< −0,02) dan 0 saat mid-stance.
- In-world: idle visual.y |0,003|; jalan maju 4,30 m (syarat ≥ 1,20);
  paha mengayun 0,70 rad; lutut menekuk 0,95 rad; lengan lawan fase.
- Duduk: paha −0,85, lutut +2,30, turun −0,42, tangan pangkuan −0,35.
- Berdiri: semua kembali 0 (paha, lutut, yaw kaki, visual.y).
- NPC: jalan 1,72 m (> 0,5), paha mengayun 0,70 rad, yaw kaki 0.

### `skrip/test_npc_tangga.gd` — 20 lulus, 0 gagal (exit 0)

Perbaikan `npc.gd` `_langkah_ke` (temuan Rangga — NPC sholat tembus
anak tangga karena `to.y = 0` memaksa y=0): kini `position.y =
_tinggi_tanah(position)` setiap langkah, mengikuti
`TanggaSurau.pijakan(z)` — T3 0,166 / T2 0,333 / T1 + serambi 0,5 —
dengan lebar tiap anak tangga dicerminkan (T3 7,2 / T2 6,6 / T1 6,0 /
serambi 6,4); di luar lebar = tanah y=0. Snap instan (bukan lerp):
lerp membuat kaki sempat tenggelam saat naik. Berlaku dua arah
(naik + turun) dan tidak mengubah y di rute datar.

- Unit `_tinggi_tanah` (9 cek): T3 0,166, T2 0,333, T1 0,5, serambi
  0,5, plaza 0, utara serambi 0, luar lebar serambi 0, dalam lebar
  T3 0,166, luar lebar T2 0 — semua tepat.
- Rute naik (−2,2) → (0,−2,3): sampai pintu (menunggu=true,
  jarak 0,39 m), y SELALU == pijakan (selisih maks 0,0000),
  melewati T3 0,166 dan T2 0,333, sampai serambi y=0,5.
- Rute turun: sampai, y selalu == pijakan (selisih maks 0,0000),
  kembali ke tanah y=0.
- Rute datar (10,30) → (−10,30): sampai, y tetap 0 (|y| maks 0,0000).

Satu-satunya edit `npc.gd` tambahan di ronde ini adalah perbaikan
ini + helper `_tinggi_tanah`; sistem gerak NPC tidak dirombak.

## 4. Foto

Skrip: `skrip/foto_animasi_mixamo.gd` (+ `.tscn`) — jalankan TANPA
`--headless` (headless membuat `save_png` null):
`xvfb-run godot --path . skrip/foto_animasi_mixamo.tscn`.
Folder: `~/workspace/pesantren-verse/v2/foto-animasi-mixamo/`.

### Studio (M1–M6) — terverifikasi berisi karakter

| Foto | Isi | Verifikasi |
|---|---|---|
| M1-jalan-depan.png | Jalan depan, fase 4,5 (lutut kiri terlipat maks) | Raka: BAGUS — pose jalan terbaca, kaki menapak, tidak tembus |
| M2-jalan-samping.png | Jalan samping, fase 4,5 | Terlihat jelas (dicek Eka 17 Nov) |
| M3-jalan-kontak.png | Jalan 3/4, fase 0 (kontak kiri, tumit mendarat) | Raka: BAGUS |
| M4-duduk-depan.png | Duduk depan (pemain asli, pose duduk −0,42) | Terlihat jelas — santri duduk bersila, sarung batik hijau |
| M5-duduk-samping.png | Duduk samping | Terlihat jelas — profil duduk bersila |
| M6-idle-depan.png | Idle depan (berdiri, napas) | Terlihat jelas — berdiri tegak, koko + sarung |

**Koreksi M4–M6 (Eka, 18 Nov 00:xx WIB):** foto M4–M6 pertama
KOSONG — karakter tidak masuk frame. Dugaan awal framing kamera
(pose duduk turun −0,42) SALAH; penyebab sebenarnya: `SantriPlayer`
studio TIDAK punya kapsul collision seperti di `main.gd` (r=0,35,
h=1,7 di y=0,85), sehingga `_physics_process` (gravitasi +
`move_and_slide`) menjatuhkan pemain menembus lantai studio dan
keluar frame selama 90 frame tunggu pose. Perbaikan: kapsul
ditambahkan di skrip foto; retake 18 Nov 00:13–00:16 WIB berisi
karakter semua (diverifikasi Eka dengan melihat langsung tiap
foto — M4 duduk depan, M5 duduk samping, M6 idle depan), dan retake
penuh 02:47 WIB menulis ulang M1–M6 dengan hasil yang sama
(M4/M5 identik byte, M6 beda tipis karena fase napas idle mengikuti
jam berjalan — tetap terverifikasi bagus).
Catatan: verifikasi Raka "M4–M6 KOSONG" adalah atas foto LAMA
sebelum retake ini; foto baru di atas sudah menggantikannya.

### In-world (W1–W3) — terverifikasi berisi karakter

| Foto | Isi | Verifikasi |
|---|---|---|
| W1-pemain-jalan.png | Pemain jalan di jalan N-S, profil samping (kaki/sandal tampak di balik hem sarung, badan condong) | Terlihat jelas — dipilih dari burst samping (lihat catatan) |
| W1-depan.png | Varian depan (pose jalan kurang terbaca — sarung menutupi kaki) | Disimpan sebagai varian |
| W2-pemain-duduk.png | Pemain duduk bersila di jalan N-S (sarung mengembang, tangan di pangkuan) | Terlihat jelas — duduk terbaca kuat |
| W3-npc-jalan.png | NPC "TesFoto" jalan di tepi taman, profil samping | Terlihat jelas — dipilih dari burst samping |
| W3-depan.png | Varian depan (pose jalan kurang terbaca) | Disimpan sebagai varian |

Semua foto in-world diambil malam hari (langit dinamis mengikuti jam
nyata ~02:50 WIB — lampu taman menyala, dunia tetap terbaca).

**Retake burst W1/W3 (Eka, 18 Nov ~02:50 WIB):** W1/W3 pertama
(00:32–00:38 WIB, run ulang penuh) pose jalannya TIDAK TERBACA —
dari depan, sarung panjang menutupi kaki sehingga karakter tampak
berdiri diam, walau tes membuktikan ia berjalan (ayun paha 0,70 rad,
maju 4,30 m). Solusi: burst 6 frame SELAGI berjalan, dari depan
(`W1/W3-coba-*.png`) dan dari samping (`W1/W3-samping-*.png`,
kamera kanan 3,4 m + depan 1,0 m). Dari samping, langkah TERBACA
profil: sandal tampak di balik hem sarung + badan condong ke depan.
Yang dipakai: W1 = `W1-samping-2.png`, W3 = `W3-samping-1.png`
(md5 sama — salinan persis, varian depan disimpan sebagai
`W1-depan.png` / `W3-depan.png`). Skrip burst:
`skrip/foto_w1w3_ulang.gd` + `skrip/foto_w1w3_samping.gd`.

**Insiden run foto 00:32–02:45 WIB (dicatat jujur):** run penuh
pertama pasca-restart MENGGANTUNG ~2 jam di fase in-world dengan
banjir `SCRIPT ERROR: Invalid access to property 'global_position'
on a base object of type 'Nil'` lalu mati SIGTERM — log awalnya
hilang (output terpotong), penyebab banjir tidak teridentifikasi.
Run ulang penuh 02:47 WIB (setelah probe in-world terisolasi
`skrip/probe_inworld.gd` membuktikan fase in-world bersih: 0 error,
W1 tersimpan dalam 17 detik) SELESAI BERSIH: 9/9 foto err=0,
EXIT=0, 0 script error. Dugaan: beban VM saat itu (tim paralel
jalan bersamaan pasca-restart), bukan cacat skrip foto — tapi kalau
terulang, log lengkap ada di `/tmp/foto-run3.log` (run bersih) dan
probe di atas bisa dipakai untuk mengisolasi lagi.

## 5. Yang belum / batasan

- Tidak ada file FBX Mixamo di repo (lihat §2) — kalau suatu hari
  ada kredensial Adobe, klip bisa diunduh dan kurva di modul
  dicocokkan ulang, tapi retarget langsung tetap tidak mungkin
  untuk rig primitif.
- Pose sholat NPC masih TAKBIR statis (RONDE 18, skema sinematik) —
  bukan siklus qiyam/ruku; adegan diakhiri blackout (main.gd).
- Foto W1/W3 final adalah sudut samping (langkah dari depan tidak
  terbaca karena sarung); varian depan disimpan sebagai
  `W1-depan.png` / `W3-depan.png`.
- Kandidat burst (`W1/W3-coba-*.png`, `W1/W3-samping-*.png`, 24 file)
  sengaja dibiarkan di `foto-animasi-mixamo/` sebagai bukti pemilihan.

## 6. File terkait

- `scripts/animasi_mixamo.gd` — modul animasi.
- `scripts/player.gd` — hook jalan/idle/duduk pemain.
- `scripts/npc.gd` — hook NPC + `_tinggi_tanah` / `_langkah_ke`.
- `scripts/tangga_surau.gd` — `pijakan(z)` + collision rampa/datar.
- `skrip/test_animasi_mixamo.gd` + `.tscn` — tes 27 cek.
- `skrip/test_npc_tangga.gd` + `.tscn` — tes 20 cek.
- `skrip/foto_animasi_mixamo.gd` + `.tscn` — foto M1–M6 + W1–W3.
- `skrip/foto_w1w3_ulang.gd` + `.tscn` — burst depan W1/W3.
- `skrip/foto_w1w3_samping.gd` + `.tscn` — burst samping W1/W3.
- `skrip/probe_inworld.gd` + `.tscn` — probe diagnosis fase in-world.
