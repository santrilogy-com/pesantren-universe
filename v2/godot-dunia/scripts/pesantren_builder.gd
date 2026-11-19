class_name PesantrenBuilder
## Membangun pesantren Fase 1: SURAU KECIL sebagai titik awal.
## Keputusan Mas (15 Nov ~09:08 WIB): pesantren dirintis dari nol —
## mulai dari surau kecil, membesar mengikuti jumlah santri.
## Lahan bangunan berikutnya sudah disiapkan sebagai plot bertanda
## (terkunci, ambang disetujui Mas 15 Nov ~11:37 WIB — lihat MissionData.GROWTH_STAGES).
## Semua bangunan dari primitif yang dirapikan + palet zamrud/pasir/emas.

## Posisi spawn pemain — ronde 20: (-4, 14) area PUTRA (di sebelah
## BARAT pagar x=0). Dulu (0,14) tepat DI ATAS garis pagar — pemain
## lahir menempel barrier. Per roadmap Fase A-P: spawn putra (-4,14).
const SPAWN := Vector3(-4, 0, 14)

## Ukuran pesantren (RONDE 5, 15 Nov — Mas: "Map jangan dikasih pagar..
## biarkan luas seluas²nya.. ada gunung, sawah dll.. tidak ada
## batasannya"): tanah 800x800 m (setengah sisi 400 m), TANPA pagar
## batas luar dan TANPA batas respawn — pemain boleh jalan jauh.
## Pagar di sekeliling 4 lahan terkunci TETAP (itu penanda lahan).
## Dulu (ronde 3/4): MAP_HALF 56, RESPAWN_LIMIT 70, pagar luar solid.
const MAP_HALF := 400.0
## Posisi bangunan (dipakai juga peta + logika pintu).
const SURAU_POS := Vector2(0, -14)
const SURAU_PUSAT := Vector3(0, 0, -14)
## JANGKAR LOKAL Surau: semua anak Surau ditulis di koordinat lokal
## mengelilingi titik ini (lantai di (0,-12), dinding utara z=-20,
## pintu lokal z=-4). JANGAN UBAH — geser Surau hanya lewat
## SURAU_PUSAT + rumus jangkar (lihat surau_pintu() dan _surau).
## PELAJARAN susulan Ronde 21: mengganti SURAU_PUSAT saja membuat
## bangunan BERAYUN mengelilingi pivot baru, bukan bergeser —
## pusat mendarat di (-0,85,-12,19) dan sudut tenggara tetap 0,54 m
## di dalam jalan E-W (tes Wulan 186/193).
const SURAU_JANGKAR_LOKAL := Vector3(0, 0, -12)
## RONDE 14 (Mas 06:31 WIB: "Putar Suraunya 25° — mihrab rata dengan
## dinding"): SELURUH Surau diputar -25° mengelilingi PUSATNYA (0,-12)
## supaya dinding mihrab (barat) menghadap kiblat 295° (bukan 270°).
## -25° = kiblat 295° - normal dinding barat 270°.
## Implementasi (bukan pindah anak satu-satu): node "Surau" diposisikan
## di P = pusat - R·pusat lalu diputar -25° — semua anak (yang dibangun
## di koordinat absolut) ikut berputar mengelilingi pusat. Pintu luar
## ikut berputar: (0,-7) -> (-2.11,-7,47). Interior diputar terpisah
## mengelilingi PINTUNYA (0,-294) di interior_surau.gd — pintu luar dan
## dalam tetap selaras (celah sama, 1,5 m).
## REVISI (Mas 17 Nov 22:51 WIB, membalas peta v2: "Surau lurus aja.
## Jangan miring. Biar matahari yg menyesuaikan dg arah barat. Surau
## lurus seperti masjid."): bangunan LUAR kini LURUS (sejajar sumbu
## dunia, pintu menghadap selatan ke spawn/plaza). Interior TETAP
## miring -25° (lihat InteriorSurau.ROTASI_RUANGAN_DEG) supaya mihrab
## tetap menghadap kiblat 295°; frame pintu DALAM tetap miring (lihat
## InteriorSurau.frame_pintu_dalam()). Matahari TIDAK diputar mengikuti
## bangunan — jalurnya sudah benar (terbenam 252° = barat-barat daya,
## lihat LangitDinamis.K_MATAHARI).
## KOREKSI 23:15 WIB (Rangga, dump node GLB): muka depan GLB Bima
## (portal + pintu + serambi + plakat) ada di sisi LOKAL +X — BUKAN
## +Z seperti asumsi lama (primitif v1). Jadi "lurus" yang benar =
## -90°, BUKAN 0°: -90° memutar +X lokal ke +Z dunia (selatan),
## pintu di (0,-3.8). Rotasi 0° SALAH: pintu menghadap timur ke
## tembok x=14 (serambi menembus tembok 0,7 m) dan yang terlihat
## dari spawn hanyalah dinding samping (3 jendela) — pemain selama
## ini "masuk" lewat jendela, bukan pintu. Jejak jadi 16 (T-B) x
## 20 (U-S) m; dinding belakang di z=-24, depan di z=-4.
const SURAU_ROTASI_DEG := -90.0
## Posisi peti M3 — ronde 20: (0,26) kawasan bersama (depan
## Perpustakaan & Taman). Dulu (6,10) jatuh di AREA PUTRI setelah
## pagar dibangun (x>0, z<16) — M3 jadi tidak terjangkau santri
## putra. Penanda M3 di mission_data.gd ikut pindah.
## RONDE PINTU TAMAN susulan (Gilang, 18 Nov 2026): (0,26) -> (0,28).
## Peti lama hanya 0,5 m di belakang garis pagar (z 25,5): muka
## utaranya z 25,625, kapsul r=0,35 mentok di z 25,275 — pemain
## tak bisa lewat garis pagar (|x|<=0,65 lewati pagar, |x|>=0,9
## lewati peti: tak ada jalur). Peti baru di tengah taman, di
## jalur batu, muka utara z 27,625 — pemain berhenti z ~27,28.
## Bangku GLB taman — GESER BANGKU (Gilang, 18 Nov 2026, keputusan
## Raka opsi a): dulu di (0,25,45), tepat di sumbu jalur masuk
## (x=0) tanpa collision — papan duduk menembus sarung pemain
## (foto F6a). Kini di (-3,25,45), rotasi tetap 0 (tetap menghadap
## pintu/jalur batu); jarak ke muka peti 1,83 m — TIDAK berubah
## (cek dump taman.glb). Barat dipilih: timur sudah ada Bangku_001
## (3,45, 28,2). CATATAN: kaki bangku kini berdiri di atas petak
## bunga Bedeng_0 (x -3,8..-1,4, z 25,2..26,4) — sisi timur sama
## saja (Bedeng_1 simetris); lihat _geser_bangku_taman.
const PETI_POS := Vector2(0, 28)
## Sawah (RONDE 5): petak sawah berair di tenggara pesantren.
const SAWAH_POS := Vector2(60, 30)
const SAWAH_SIZE := Vector2(60, 40)
## Gunung di kejauhan (RONDE 5: 10 gunung; RONDE 6, Mas: "Gunung cukup
## 1-2 aja" — tinggal 2, keduanya di SELATAN (di belakang spawn, terlihat
## saat menoleh ke belakang dari Surau) supaya zona utara (map interior
## Surau di z=-300 + cangkruk) bersih dari penghalang. Gunung adalah
## PEMANDANGAN + penghalang alami (ada collision), BUKAN pagar.
const GUNUNG: Array = [
	{"sudut": 160.0, "jarak": 350.0, "tinggi": 70.0, "jejari": 60.0},
	{"sudut": 200.0, "jarak": 360.0, "tinggi": 85.0, "jejari": 70.0},
]

## Kamar Cangkruk (RONDE 6, Mas: bangun 1 kamar cangkruk kayu di sebelah
## Surau — tempat tidur + ganti baju). Cangkang luar di timur Surau
## (14, -14); interior terpisah di (-60, 0, -300) seperti Surau
## (lihat scripts/interior_cangkruk.gd). Pintu di sisi selatan.
## RONDE 20: cangkruk PINDAH ke (-12,-12) area PUTRA — posisi lama
## (14,-14) jatuh di AREA PUTRI setelah pagar dibangun (x>0, z<16):
## kamar tidur + panel Ganti Baju santri putra jadi tidak terjangkau.
## Per roadmap Fase A-P: cangkruk putra di (-12,-12). Cangkruk Putri
## di (12,-12) TIDAK dibangun ronde ini (belum ada pemain santriwati
## / sistem gender di game). Pintu tetap sisi selatan.
const CANGKRUK_POS := Vector2(-22, -18)
const CANGKRUK_DOOR := Vector3(-22, 0, -14)
const CANGKRUK_EXIT := Vector3(-22, 0, -12.5)

## --- RONDE 20: Musholla Ar-Raudhah (putri, terpisah) ---
## Plot (18,-24), eksterior 10x8 m (sedikit lebih kecil dari Surau
## 12x10), kubah + menara kecil serasi Surau, pintu selatan, diputar
## -25 derajat mengelilingi PUSAT — sama seperti Surau.
const MUSHOLLA_POS := Vector2(134, -24)
const MUSHOLLA_ROTASI_DEG := 0.0
const MUSHOLLA_LEBAR := 10.0 # x lokal: 13..23
const MUSHOLLA_DALAM := 8.0 # z lokal: -28..-20
## --- RONDE 20: Pagar putra/putri + gerbang + pos jaga ---
## Garis pagar (polyline XZ, putra di BARAT, putri di TIMUR):
## (2.5,-60) -> (2.5,-17.5) -> (9,-17.5) -> (9,-4) -> (2.5,-4) ->
## (2.5,16). Belokan di (9,-17.5)-(9,-4) menjaga Surau utuh di
## area putra: dinding timur Surau berakhir di x=7.55, pagar
## lewat 1.45 m di timurnya. Di Masjid Besar pagar menembus plot
## (0,-26) — papan tanda masjid digeser ke barat (lihat _plots)
## supaya tidak tertabrak pagar; saat masjid dibangun, pagar
## bertemu dinding masjid.
## PERBAIKAN JALAN + LAMPU (susulan Ronde 20): garis pagar PINDAH
## dari x=0 ke x=2.5 — pagar lama membelah TENGAH jalan N-S (tiang
## pagar + pilar gerbang berdiri DI ATAS jalan, itulah yang Mas
## lihat). Pagar baru 1,0 m di timur tepi jalan (tepi jalan x=1.5);
## gerbang + pos satpam ikut pindah. Belokan x=9 TETAP (menjaga
## Surau). Batas putra/putri di main.gd (_cek_batas) ikut pindah
## ke x=2.5. Zona penyangga x 0..50 TETAP.
## GERBANG di (2.5,0): bukaan 4 m (z -2..+2) + 2 pilar + gapura.
## Pilar (2.5,+-2) 1,0 m dari tepi jalan N-S; 0,75 m dari tepi
## jalan E-W — pilar gerbang di sudut persimpangan, disengaja.
## SATPAM di (5.5,5) — pos 3x3 m di luar gerbang (sisi plaza,
## menghadap gerbang) + satpam NPC berjaga. Pos lama (3,3) sudutnya
## menyentuh tepi jalan N-S (0,00 m) dan dinding utaranya 0,25 m
## dari jalan E-W; pos baru 2,5 m dari jalan N-S, 2,25 m dari E-W.
## 4 POS JAGA keamanan 3x3 m + 1 lampu di sudut kampus inti.
## RONDE 21 — pagar kayu di atas DIBONGKAR TOTAL (Mas ACC Opsi A
## 22:03 WIB): diganti tembok pemisah solid x=14, z -60..+16
## (lihat _tembok); gerbang (14,0) pintu TERTUTUP + barrier;
## pos satpam PINDAH ke (17,5) menghadap gerbang; zona penyangga
## x 14..124; Musholla lama (18,-24) DIBONGKAR, kampus putri
## pindah ke timur (KampusPutri.build, Cakra).
## RONDE 21 — PAGAR_GARIS DIHAPUS (pagar kayu Ronde 20 dibongkar
## total). Penggantinya: TEMBOK_GARIS — garis lurus x=14,
## z -60..+16. main.gd (_cek_batas + peta) memakai TEMBOK_GARIS /
## TEMBOK_X / BATAS_Z_SELATAN; ui.gd memakai kunci "tembok_garis".
const TEMBOK_X := 14.0
const TEMBOK_Z_MIN := -60.0
const TEMBOK_Z_MAX := 16.0
const TEMBOK_TINGGI := 3.0
const TEMBOK_TEBAL := 0.4
const TEMBOK_GARIS: Array[Vector2] = [
	Vector2(14, -60), Vector2(14, 16),
]
const GERBANG_LEBAR := 4.0
const BATAS_Z_SELATAN := 16.0
const GERBANG_POS := Vector3(14, 0, 0)
const POS_SATPAM := Vector3(17, 0, 5)
const POS_JAGA: Array[Vector3] = [
	Vector3(-40, 0, -35), Vector3(40, 0, -35),
	Vector3(-40, 0, 80), Vector3(40, 0, 80),
]

## --- RONDE 22: Tembok keliling pondok putri (ACC Mas 17 Nov ~06:11 WIB) ---
## Persegi x 115..180, z -52..+22 (65x74 m), bahan sama seperti tembok
## x=14 (krem + lis emas + fondasi batu, 3 m x 0,4 m, collision penuh).
## Gerbang barat (115,0), bukaan 4 m (z -2..+2), pintu TERTUTUP +
## barrier — satu-satunya bukaan, segaris sumbu z=0 dengan gerbang
## (14,0). Tembok x=14 TETAP (pemisah zona); pagar kayu taman
## Musholla + Pos Jaga TL TETAP di dalam keliling. Reserve Masjid
## Putri (134,-40) di dalam keliling (alasan tembok selatan z=-52) —
## TIDAK dibangun ronde ini.
## (Konstanta tembok keliling kini di tembok_putri.gd — Cakra;
## dict di bawah membaca TembokPutri.*.)

## Interior Surau (RONDE 4 — ala GTA: masuk pintu = pindah ke map
## interior). Ruangan 14 x 12 m di z=-300 — jauh di luar pagar + kabut
## sehingga tidak terlihat dari luar — pintu selatan di z=-294,
## smartboard di dinding barat, mihrab di dinding utara.
const INTERIOR_CENTER := Vector3(0, 0, -300)
const INTERIOR_DOOR := Vector3(0, 0, -294)
const INTERIOR_SPAWN := Vector3(0, 0, -295.5)
## RONDE 14: posisi pintu pra-rotasi (0,-7) — TIDAK dipakai lagi untuk
## logika; pintu dunia dihitung surau_pintu() (pintu (-2.11,-7.47),
## keluar (-2.75,-6.11)). Konstanta disimpan sebagai dokumentasi
## posisi sebelum rotasi.
const OUTDOOR_DOOR := Vector3(0, 0, -7)
const OUTDOOR_EXIT := Vector3(0, 0, -5.5)
## Titik berdiri di depan smartboard (interaksi + penanda M2).
const SMARTBOARD_SPOT := Vector3(-4.6, 0, -300)

## Batas dalam surau (untuk syarat misi M2: harus di dalam surau).
## RONDE 4: yang dihitung "di dalam surau" adalah map interior
## (main.gd memakai flag _di_dalam); konstanta ini batas interiornya.
const SURAU_BOUNDS := {"min_x": -7.0, "max_x": 7.0, "min_z": -306.0, "max_z": -294.0}

const NPC_WAYPOINTS: Array[Vector3] = [
	Vector3(4, 0, 4),
	Vector3(-4, 0, 6),
	Vector3(8, 0, -2),
	Vector3(-6, 0, -4),
	Vector3(2, 0, 12),
	Vector3(-8, 0, 8),
	Vector3(10, 0, 8),
	# RONDE 4: peta membesar — NPC ikut menjelajah lebih jauh.
	Vector3(20, 0, 20),
	Vector3(-20, 0, 18),
	Vector3(24, 0, -10),
	# SUSULAN Ronde 21: (-24,-12) -> (-24,-10) — Cangkruk pindah ke
	# (-22,-18); segmen (0,-20)->(-24,-12) menyerempet sudut
	# tenggara Cangkruk baru ~0,3 m (NPC menembus sudut). Titik
	# baru 4 m dari dinding selatan Cangkruk, segmen bersih ~1 m.
	Vector3(-24, 0, -10),
	Vector3(0, 0, 30),
	Vector3(0, 0, -20),
	Vector3(-32, 0, 24),
	Vector3(32, 0, 28),
	# RONDE 5: peta membesar (800 m) — NPC ikut menjelajah lebih jauh,
	# sampai sawah + kaki gunung.
	Vector3(60, 0, 30),
	Vector3(-60, 0, -40),
	Vector3(100, 0, 60),
	Vector3(-100, 0, 80),
	Vector3(40, 0, -100),
	Vector3(-40, 0, 120),
]


## ---------- geometri rotasi Surau (RONDE 14) ----------
## Putar titik p mengelilingi pusat (sumbu Y) sebesar derajat (rotasi
## Godot: x' = x·cos + z·sin, z' = -x·sin + z·cos).
static func _putar_sekitar(p: Vector3, pusat: Vector3, derajat: float) -> Vector3:
	var a := deg_to_rad(derajat)
	var c := cos(a)
	var s := sin(a)
	var q := p - pusat
	return pusat + Vector3(q.x * c + q.z * s, q.y, -q.x * s + q.z * c)


## Posisi root supaya rotasi mengelilingi `pusat` (bukan origin):
## root dipindah ke pusat - R·pusat, lalu diputar. PAKAI INI HANYA
## bila anak-anak ditulis mengelilingi titik lokal `pusat` — kalau
## tidak, bangunan berayun (lihat SURAU_JANGKAR_LOKAL).
static func _posisi_root_putar(pusat: Vector3, derajat: float) -> Vector3:
	return pusat - _putar_sekitar(pusat, Vector3.ZERO, derajat)


## Arah kompas -> vektor (x,z): azimut 0° = utara (-Z), 90° = timur.
static func arah(azimut_deg: float) -> Vector3:
	var a := deg_to_rad(azimut_deg)
	return Vector3(sin(a), 0, -cos(a))


## Frame pintu LUAR Surau (koordinat dunia, setelah rotasi):
## "pintu" = pusat celah pintu luar — REVISI Mas 17 Nov 22:51 WIB
## (Surau lurus, pintu menghadap selatan ke spawn/plaza).
## KOREKSI 23:15 WIB: frame ini DITURUNKAN DARI GLB, bukan dari
## primitif v1. Dump node surau-v2.glb: daun pintu SR_Pintu_Kiri/
## Kanan di lokal (10.2, ±1.97) — muka depan GLB ada di sisi
## LOKAL +X (portal + serambi + plakat di +X; dinding selatan
## lokal +Z cuma 3 jendela + wudu). Jadi:
## - pintu_lokal = (10.2, 0, 0) [pusat celah, daun di ±1,97]
## - "keluar" = R·(1,0,0) [normal muka depan]; "masuk" = -keluar
## - "sumbu" = R·(0,0,1) [arah memanjang muka depan]
## Dengan SURAU_ROTASI_DEG = -90°: pintu dunia (0,-3.8),
## keluar = selatan (0,0,1), masuk = utara (0,0,-1),
## sumbu = barat-timur. Dipakai main.gd (koridor pintu LUAR +
## rute NPC) dan build() (outdoor_door/outdoor_exit). Frame ini
## TIDAK berlaku untuk pintu DALAM (0,-294) — interior TETAP
## miring -25°, frame-nya sendiri di InteriorSurau.
## frame_pintu_dalam(). JANGKAR LOKAL tidak dipakai lagi di sini
## (itu frame primitif v1; GLB berpusat di titiknya sendiri).
static func surau_pintu() -> Dictionary:
	var rot := Basis(Vector3.UP, deg_to_rad(SURAU_ROTASI_DEG))
	var pintu := SURAU_PUSAT + rot * Vector3(10.2, 0, 0)
	return {
		"pintu": pintu,
		"sumbu": rot * Vector3(0, 0, 1),
		"masuk": rot * Vector3(-1, 0, 0),
		"keluar": rot * Vector3(1, 0, 0),
	}


static func build() -> Dictionary:
	var root := Node3D.new()
	root.name = "Pesantren"
	var pintu := surau_pintu()
	_environment(root)
	_ground(root)
	_surau_glb(root)
	var kampus := KampusPutri.build(root)
	# 18 Nov (Nadia): cangkang Asrama Putra (-24,10) — ACC Mas 09:37 WIB.
	var asrama_putra := AsramaPutra.build(root)
	_cangkruk(root)
	_tembok(root)
	# RONDE 22: tembok keliling (Cakra, tembok_putri.gd) + semua
	# jalan (Sinta, jalan_ronde22.gd) — file sendiri, bukan inline.
	TembokPutri.bangun(root)
	JalanRonde22.bangun(root)
	_pos_jaga(root)
	_pos_satpam(root)
	_plots(root)
	var chest := _peti(root)
	_dekor(root)
	_lingkungan_glb(root)
	var markers := _markers(root)
	return {
		"root": root,
		"markers": markers,
		"chest_lid": chest["lid"],
		"surau_bounds": SURAU_BOUNDS,
		"spawn": SPAWN,
		"npc_waypoints": NPC_WAYPOINTS,
		# RONDE 4: pintu luar (dipakai main.gd untuk teleport).
		# Interior (pintu dalam/spawn/smartboard) kini dari
		# InteriorSurau.build() (Dewa) — kunci itu dihapus dari sini
		# supaya tidak ada dua interior menumpuk di z=-300.
		# RONDE 14: pintu luar ikut berputar — pusat celah pintu dan
		# titik keluar dihitung dari frame pintu (surau_pintu()), bukan
		# konstanta sumbu dunia lagi. outdoor_exit = pintu + 1,5 m ke
		# arah luar/plaza (180° = selatan, revisi Surau lurus 17 Nov
		# 22:51 WIB; dulu 205°) — tempat pemain mendarat saat keluar.
		# TANGGA (Rangga, 17 Nov 23:xx WIB): titik keluar di atas
		# lantai serambi (y=0.5) — dulu y=0, pemain/NPC mendarat DI
		# DALAM kotak lantai serambi setelah collision dipasang.
		"outdoor_door": pintu["pintu"],
		"outdoor_exit": pintu["pintu"] + pintu["keluar"] * 1.5 + Vector3(0, TanggaSurau.LANTAI_SERAMBI_Y, 0),
		# RONDE 6: pintu kamar cangkruk (dipakai main.gd untuk teleport).
		"cangkruk_door": CANGKRUK_DOOR,
		"cangkruk_exit": CANGKRUK_EXIT,
		"cangkruk_pos": CANGKRUK_POS,
		# RONDE 21: Musholla Ar-Raudhah PINDAH ke kampus putri baru
		# (Opsi A, 134,-24) — dibangun KampusPutri.build() (Cakra).
		# Interior dari InteriorMusholla.build() (main.gd) TETAP.
		# Ustadzah Mariyah masuk lewat teleport pintu ini.
		"musholla_door": kampus["musholla_door"],
		"musholla_exit": kampus["musholla_exit"],
		"musholla_pos": MUSHOLLA_POS,
		"musholla_rotasi": MUSHOLLA_ROTASI_DEG,
		"spawn_putri": kampus["spawn_putri"],
		# 18 Nov (Mira): "cangkruk_putri_pos" DIHAPUS bersama Cangkruk Putri
		# (perintah Mas 00:26 WIB) — KampusPutri.build() tidak lagi mengembalikannya.
		"kelas_putri_pos": kampus["kelas_putri_pos"],
		"asrama_putri_pos": kampus["asrama_putri_pos"],
		# 18 Nov (Nadia): cangkang Asrama Putra (-24,10) — ACC Mas 09:37 WIB.
		"asrama_putra_door": asrama_putra["asrama_putra_door"],
		"asrama_putra_exit": asrama_putra["asrama_putra_exit"],
		"asrama_putra_pos": asrama_putra["asrama_putra_pos"],
		"kantor_ustadzah_pos": kampus["kantor_ustadzah_pos"],
		"madrasah_pos": kampus["madrasah_pos"],
		"studio_pos": kampus["studio_pos"],
		"pos_jaga_tl": kampus["pos_jaga_tl"],
		"jalan_internal_x": kampus["jalan_internal_x"],
		# RONDE 21: tembok pemisah x=14 + gerbang (14,0) + pos satpam
		# (17,5) — menggantikan pagar Ronde 20 (peta + _cek_batas
		# di main.gd memakai kunci-kunci ini).
		"tembok_garis": TEMBOK_GARIS,
		"tembok_x": TEMBOK_X,
		"tembok_z_min": TEMBOK_Z_MIN,
		"tembok_z_max": TEMBOK_Z_MAX,
		"batas_z_selatan": BATAS_Z_SELATAN,
		"gerbang_pos": GERBANG_POS,
		"gerbang_lebar": GERBANG_LEBAR,
		"pos_satpam": POS_SATPAM,
		# RONDE 22: tembok keliling pondok putri x 115..180, z -52..+22
		# + gerbang barat (115,0) — peta (ui.gd) memakai kunci ini.
		"tembok_keliling_garis": TembokPutri.KELILING_GARIS,
		"tembok_keliling_x_min": TembokPutri.KELILING_X_MIN,
		"tembok_keliling_x_max": TembokPutri.KELILING_X_MAX,
		"tembok_keliling_z_min": TembokPutri.KELILING_Z_MIN,
		"tembok_keliling_z_max": TembokPutri.KELILING_Z_MAX,
		"gerbang_putri_pos": TembokPutri.GERBANG_PUTRI_POS,
		"pos_jaga": POS_JAGA,
		"map_half": MAP_HALF,
		# RONDE 5: langit dinamis (pengendali LangitDinamis) + sawah/gunung
		# untuk peta. RESPAWN_LIMIT DIHAPUS (Mas: tidak ada batasan).
		"langit": _langit_node,
		# RONDE 4: langit (arah + bola matahari 3D, untuk tes).
		# "sun_dir" = arah matahari SAAT BUILD (siang, 12:00) — arah
		# terkini dibaca lewat _langit_node.get_sun_dir() (berubah
		# mengikuti jam nyata).
		"sun_dir": _sun_dir,
		"matahari": _matahari_node,
		"sawah_pos": SAWAH_POS,
		"sawah_size": SAWAH_SIZE,
		"gunung": GUNUNG,
	}


# Pengendali langit dinamis (RONDE 5) + arah/bola matahari (ronde 4).
static var _langit_node: LangitDinamis
static var _sun_dir: Vector3 = Vector3(0, 1, 0)
static var _matahari_node: MeshInstance3D


static func _environment(root: Node3D) -> void:
	# RONDE 5 (15 Nov — Mas: langit + matahari/bulan mengikuti jam nyata):
	# langit kini dibangun + diperbarui LangitDinamis (scripts/
	# langit_dinamis.gd) — 5 fase subuh/pagi/siang/sore/malam, matahari
	# + bulan 3D, bintang, lampu menyala di malam hari. Kabut TETAP MATI
	# (pelajaran ronde 4: kabut menutupi langit di renderer web meski
	# fog_sky_affect=0.0). Golden hour ronde 4 dipertahankan sebagai fase
	# "sore" (gradasi biru->oranye, matahari rendah di barat-laut).
	_langit_node = LangitDinamis.build()
	root.add_child(_langit_node)
	_sun_dir = _langit_node.get_sun_dir()
	_matahari_node = _langit_node.get_matahari()


## P5 FASE 2 (Bima, 18 Nov 2026): permukaan BESAR bertekstur —
## dinding KREM pakai plester (MaterialTekstur.dinding), BATU tipis
## (lantai/teras, y<=0,15) pakai lantai batu, BATU tebal (fondasi/
## alas) pakai blok batu. Tinta + ukuran/posisi TIDAK berubah, hanya
## material — palet tetap persis (tekstur ternormalisasi 0,90).
## Detail kecil (lis emas, jendela, pintu jati, plakat) tetap polos.
## skala_uv ~= ukuran / 2 m (tekstur berulang tiap ~2 m).
## CATATAN: _surau primitif di file ini kode mati (build memakai
## _surau_glb) — helper ini tetap berlaku bila _surau dipanggil lagi.
static func _skala_uv(size: Vector3) -> Vector3:
	return Vector3(size.x / 2.0, size.y / 2.0, size.z / 2.0)


static func _mat_permukaan(size: Vector3, warna: Color) -> Material:
	if warna == Palette.KREM:
		return MaterialTekstur.dinding(warna, _skala_uv(size))
	if warna == Palette.BATU:
		if size.y <= 0.15:
			return MaterialTekstur.lantai_batu(warna, _skala_uv(size))
		return MaterialTekstur.pondasi(warna, _skala_uv(size))
	return Palette.mat(warna)


static func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, collide: bool = true) -> MeshInstance3D:
	var mi := MaterialTekstur.kotak(size, pos, _mat_permukaan(size, color))
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
		parent.add_child(body)
	return mi


## TABRAKAN-DUNIA (Bagas, 18 Nov 2026 — audit Mas: tiang + pohon
## tembus). Helper collision TANPA visual — dipakai untuk objek
## yang visualnya sudah ada (GLB / Palette) tapi belum punya badan.
## Ukuran mengikuti visual, tidak lebih besar dari bendanya.
static func _tabrakan_kotak(parent: Node3D, nama: String, ukuran: Vector3, pos: Vector3, rot_y_deg: float = 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nama
	body.position = pos
	if rot_y_deg != 0.0:
		body.rotation.y = deg_to_rad(rot_y_deg)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = ukuran
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)
	return body


static func _tabrakan_silinder(parent: Node3D, nama: String, radius: float, tinggi: float, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nama
	body.position = pos
	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = tinggi
	shape.shape = cyl
	body.add_child(shape)
	parent.add_child(body)
	return body


static func _ground(root: Node3D) -> void:
	# RONDE 5 (15 Nov — Mas: "Map jangan dikasih pagar.. biarkan luas
	# seluas²nya.. ada gunung, sawah dll.. tidak ada batasannya"):
	# tanah 800x800 m (MAP_HALF 400), TANPA pagar hidup, TANPA dinding
	# tak terlihat, TANPA celah gerbang — pemain boleh jalan jauh ke
	# segala arah. Ujung dunia yang jauh ditandai gunung (lihat
	# _gunung: ada collision, jadi penghalang alami) — tanah sendiri
	# membentang sampai ±400 m, jauh di balik kaki gunung (±330 m).
	# Tanah rumput + collision (satu kotak besar, 1 draw call).
	_static_box(root, Vector3(800, 0.2, 800), Vector3(0, -0.1, 0), Palette.RUMPUT)
	# Jalan pasir: utara-selatan memanjang sampai kaki gunung, timur-
	# barat sampai plot samping + sawah, dan jalan ke plot-plot.
	# RONDE 22 (Mas 06:05 WIB: "jalan kok belum rapi.. terutama yg
	# ke surau itu tidak lurus"): jalan N-S di sekitar Surau kini
	# dibangun jalan_ronde22.gd (Sinta) — segmen DIPENDEKKAN supaya
	# berakhir BERSIH di luar dinding Surau (selatan z +1,25..+14 di
	# tepi jalan E-W; utara z -200..-24, 1,17 m di utara dinding
	# utara). Jalan pendek ke plot Masjid (0,-19) DIHAPUS; plot
	# Masjid Besar pindah (0,-26)->(0,-32) (mission_data.gd).
	root.add_child(Palette.box(Vector3(320, 0.06, 2.5), Vector3(0, 0.03, 0), Palette.PASIR))
	root.add_child(Palette.box(Vector3(2.5, 0.06, 5), Vector3(0, 0.03, 16.5), Palette.PASIR))
	# RONDE 21: JalanSurau lama DIHAPUS — ujung timur-lautnya
	# (-2,11,-7,47) jatuh DI DALAM cangkang Surau baru, dan serambi
	# + 3 anak tangga baru langsung bertemu jalan E-W (pintu baru
	# (-3,38,-4,75), tangga ujung (-5,03,-1,21)). Bukan perancangan
	# ulang jalan — konsekuensi pintu yang pindah 3 m ke selatan.
	# Lampu JalanSurau (-6,89,-2,67) TETAP (di luar footprint baru).
	# Pendekatan ke pintu Surau kini: jalan N-S -> persimpangan T
	# jalan E-W -> anak tangga serambi (tangga ujung sudah menyentuh
	# jalan E-W). Tidak ada jalan diagonal baru — Surau diputar -25°
	# (kiblat), jadi serambi memang bertemu jalan E-W dengan sudut;
	# jalan diagonal justru yang tampak "tidak lurus" di mata.
	# Jalan tanah ke sawah (tenggara): dari jalan utama ke tepi sawah.
	root.add_child(Palette.box(Vector3(32, 0.06, 2.5), Vector3(16, 0.03, 30), Palette.PASIR))
	# Gunung di kejauhan + sawah di tenggara (lihat _gunung/_sawah).
	_gunung(root)
	_sawah(root)


## Pegunungan di kejauhan (RONDE 5): kerucut low-poly sebagai
## pemandangan + penghalang alami di ujung peta. Ada collision
## (silinder) supaya pemain tidak jalan menembus gunung.
## RONDE 22 (Mas 06:21 WIB: "Perbaiki juga gunungnya.. yg warna
## biru kek ada toping putih di pucuknya"): topi salju putih
## DIHAPUS (dulu kerucut putih kecil di pucuk gunung tertinggi —
## kelihatan seperti kue bertoping, bukan gunung) dan warna biru
## #6b7a8a DIGANTI hijau pegunungan #5f7055 (senada dua warna lain).
## Tidak ada lagi gunung biru, tidak ada lagi toping putih.
static func _gunung(root: Node3D) -> void:
	var warna_gunung: Array[Color] = [Color("#5a6b52"), Color("#5f7055"), Color("#55684e")]
	var i := 0
	for g in GUNUNG:
		var sudut := deg_to_rad(float(g["sudut"]))
		var jarak: float = g["jarak"]
		var tinggi: float = g["tinggi"]
		var jejari: float = g["jejari"]
		var pos := Vector3(sin(sudut) * jarak, 0, -cos(sudut) * jarak)
		var grup := Node3D.new()
		grup.name = "Gunung_%d" % i
		grup.position = pos
		root.add_child(grup)
		var kerucut := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.5
		cm.bottom_radius = jejari
		cm.height = tinggi
		cm.radial_segments = 8
		kerucut.mesh = cm
		kerucut.position = Vector3(0, tinggi * 0.5 - 2.0, 0)
		kerucut.material_override = Palette.mat(warna_gunung[i % warna_gunung.size()])
		grup.add_child(kerucut)
		# RONDE 22: topi salju DIHAPUS (perintah Mas 06:21 WIB) —
		# dulu kerucut putih kecil di pucuk gunung tertinggi.
		# Collision (silinder, jejari 70% — lereng bawah boleh ditapaki).
		var body := StaticBody3D.new()
		body.position = pos
		var shape := CollisionShape3D.new()
		var cyl := CylinderShape3D.new()
		cyl.radius = jejari * 0.7
		cyl.height = tinggi
		shape.shape = cyl
		shape.position = Vector3(0, tinggi * 0.5, 0)
		body.add_child(shape)
		root.add_child(body)
		i += 1


## Sawah (RONDE 5): petak sawah berair di tenggara pesantren
## (pusat SAWAH_POS, ukuran SAWAH_SIZE). 4 kolom x 3 baris petak air
## (permukaan mengkilap seperti air) dipisah pematang tanah, + rumpun
## padi hijau + satu gubuk kayu di tepi sawah.
static func _sawah(root: Node3D) -> void:
	# V2 (Rangga): sawah primitif 60x40 diganti sawah.glb Bima (20x12,
	# 4 petak, DI-ACC Mas) di pusat yang sama (60,30).
	# GubukSawah primitif ikut diganti gubuk-santri.glb di _lingkungan_glb.
	_glb(root, "res://models/sawah.glb", Vector3(SAWAH_POS.x, 0, SAWAH_POS.y), 0.0, "Sawah")


static func _dinding(root: Node3D, size: Vector3, pos: Vector3) -> void:
	# Dinding collision tanpa visual.
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	root.add_child(body)


# ============================================================
# V2 (Rangga, 17 Nov 2026) — ROMBAK VISUAL: primitif diganti GLB.
# GLB Bima (Blender, DI-ACC Mas): Surau + 7 elemen lingkungan.
# Sistem v1 (login, misi, sholat, chat, peta, NPC, UI) TIDAK
# disentuh — hanya "baju" dunianya yang diganti (clone v1).
# ============================================================


static func _glb(root: Node3D, path: String, pos: Vector3, rot_y_deg: float, nama: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("V2 GLB gagal dimuat: " + path)
		return null
	var inst := packed.instantiate() as Node3D
	inst.name = nama
	inst.position = pos
	inst.rotation.y = deg_to_rad(rot_y_deg)
	root.add_child(inst)
	return inst


static func _surau_glb(root: Node3D) -> void:
	# Surau primitif diganti surau-v2.glb (20x16 m, desain Arsa).
	# Posisi + putaran mengikuti SURAU_PUSAT + SURAU_ROTASI_DEG —
	# REVISI Mas 17 Nov 22:51 WIB: LURUS (dulu -25°), supaya
	# logika pintu (surau_pintu()) + teleport tetap jalan.
	# KOREKSI 23:15 WIB: LURUS = -90° (bukan 0°) — muka depan GLB
	# di lokal +X, jadi -90° yang menghadapkan pintu ke selatan.
	# CATATAN: peta Gilang tulis (0,-12) — itu JANGKAR LOKAL
	# (SURAU_JANGKAR_LOKAL); pusat dunia live v1 = (0,-14).
	_glb(root, "res://models/surau-v2.glb", SURAU_PUSAT, SURAU_ROTASI_DEG, "Surau")
	# Collision dinding TAK TERLIHAT — 5 segmen mengikuti JEJAK
	# GLB (bukan primitif): jejak lokal 20 (X) x 16 (Z) m, muka
	# depan di lokal +X dengan celah pintu 2,4 m di tengahnya
	# (lokal z -1,2..+1,2 — koridor _cek_pintu_surau butuh pemain
	# masuk 1,5 m ke dalam cangkang). Segmen didefinisikan dalam
	# KOORDINAT LOKAL GLB (pusat = titik tengah bangunan) lalu
	# diputar SURAU_ROTASI_DEG + digeser ke SURAU_PUSAT — jadi
	# collision selalu selaras dengan GLB apa pun rotasinya.
	# -90°: belakang z=-24, depan z=-4 (celah x -1,2..+1,2),
	# sisi barat x=-8, sisi timur x=+8.
	var rot := Basis(Vector3.UP, deg_to_rad(SURAU_ROTASI_DEG))
	var dinding: Array = [
		[Vector3(0.25, 5, 16), Vector3(-10, 2.5, 0)],
		[Vector3(20, 5, 0.25), Vector3(0, 2.5, 8)],
		[Vector3(20, 5, 0.25), Vector3(0, 2.5, -8)],
		[Vector3(0.25, 5, 6.8), Vector3(10, 2.5, -4.6)],
		[Vector3(0.25, 5, 6.8), Vector3(10, 2.5, 4.6)],
	]
	for d in dinding:
		var body := StaticBody3D.new()
		body.position = SURAU_PUSAT + rot * (d[1] as Vector3)
		body.rotation.y = deg_to_rad(SURAU_ROTASI_DEG)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = d[0]
		shape.shape = box
		body.add_child(shape)
		root.add_child(body)
	# TABRAKAN-DUNIA (Bagas, 18 Nov): isi GLB Surau yang padat tapi
	# tanpa collision — pemain tembus (probe baseline). Koordinat
	# LOKAL GLB (dump 18 Nov), diputar + digeser seperti dinding.
	# Menara (lokal 10,85, 8,85) -> dunia (-8,85, -3,15); tiang
	# serambi lokal (12,9, ±1) & (12,9, ±2,9) -> dunia (∓1/∓2,9,
	# -1,1); bak wudu lokal (-7,5, 8,4) -> dunia (-8,4, -21,5);
	# pot lokal (13,6, ±4,2) -> dunia (∓4,2, -0,4).
	# Daun pintu terbuka + BlokPortal + rak/dampar di DALAM GLB
	# TIDAK diberi collision: pintu harus tetap bisa dilewati,
	# interior tak terjangkau pemain (cangkang luar saja).
	var isi_surau: Array = [
		[Vector3(2.4, 0.6, 2.4), Vector3(10.85, 0.3, 8.85)], # alas menara
		[Vector3(1.7, 6.0, 1.7), Vector3(10.85, 3.6, 8.85)], # badan menara
		[Vector3(0.4, 2.5, 0.4), Vector3(12.9, 1.75, 1.0)], # tiang serambi
		[Vector3(0.4, 2.5, 0.4), Vector3(12.9, 1.75, -1.0)],
		[Vector3(0.4, 2.5, 0.4), Vector3(12.9, 1.75, 2.9)],
		[Vector3(0.4, 2.5, 0.4), Vector3(12.9, 1.75, -2.9)],
		[Vector3(3.0, 0.95, 0.8), Vector3(-7.5, 0.475, 8.4)], # bak wudu — dimensi lokal (3,0 X, 0,8 Z) -> dunia (0,8 X, 3,0 Z) setelah rotasi -90°; dulu terbalik (fix3 Bagas)
		[Vector3(0.5, 0.45, 0.5), Vector3(13.6, 0.225, 4.2)], # pot serambi
		[Vector3(0.5, 0.45, 0.5), Vector3(13.6, 0.225, -4.2)],
	]
	for d in isi_surau:
		var body2 := StaticBody3D.new()
		body2.position = SURAU_PUSAT + rot * (d[1] as Vector3)
		body2.rotation.y = deg_to_rad(SURAU_ROTASI_DEG)
		var shape2 := CollisionShape3D.new()
		var box2 := BoxShape3D.new()
		box2.size = d[0]
		shape2.shape = box2
		body2.add_child(shape2)
		root.add_child(body2)
	# TANGGA + LANTAI SERAMBI (Rangga, 17 Nov 23:xx WIB — kaki
	# tenggelam): GLB tidak punya collision; lihat
	# scripts/tangga_surau.gd (ramps + datar, ukuran dari dump GLB).
	TanggaSurau.build(root)
	# Sandal di depan pintu (dipakai main.gd via find_child):
	# lokal (11.7, 0.5, 0.8) = 1,5 m di depan daun pintu (10.2)
	# ke arah luar (+X lokal), 0,8 m ke samping — di atas lantai
	# serambi (y=0.5, TanggaSurau.LANTAI_SERAMBI_Y; dulu y=0 jadi
	# sandal terkubur di dalam lantai GLB). -90°: dunia (-0.8, 0.5, -2.3).
	var sandal_luar := Node3D.new()
	sandal_luar.name = "SandalLuarSurau"
	sandal_luar.position = SURAU_PUSAT + rot * Vector3(11.7, TanggaSurau.LANTAI_SERAMBI_Y, 0.8)
	sandal_luar.rotation.y = deg_to_rad(SURAU_ROTASI_DEG)
	sandal_luar.visible = false
	root.add_child(sandal_luar)
	for sx in [-0.16, 0.16]:
		var sd := Palette.cylinder(0.11, 0.11, 0.035, Vector3(sx, 0.02, 0), Color("#5a3a22"))
		sd.scale = Vector3(0.9, 1.0, 1.5)
		sandal_luar.add_child(sd)


static func _lingkungan_glb(root: Node3D) -> void:
	# Elemen lingkungan GLB Bima di luar yang sudah ada (_tree/_sawah).
	# Taman 8x6 di selatan plot Perpustakaan (0,28).
	# GESER BANGKU (Gilang, 18 Nov 2026, keputusan Raka opsi a) —
	# lihat _geser_bangku_taman di bawah.
	var taman := _glb(root, "res://models/taman.glb", Vector3(0, 0, 28), 0.0, "GLB_Taman")
	if taman != null:
		_geser_bangku_taman(taman)
		# TABRAKAN-DUNIA (Bagas, 18 Nov): bangku + pohon taman kini
		# punya collision (koordinat LOKAL GLB, taman di (0,28)).
		# Bangku 1 SUDAH digeser 3 m ke barat (Gilang) — di luar
		# sumbu pintu (x -1..1), jadi collision aman. Bangku 2
		# (3,45, 28,2) rot 90°: memanjang arah z.
		_tabrakan_kotak(taman, "Tabrakan_Bangku1", Vector3(1.8, 0.5, 0.55), Vector3(-3, 0.25, -2.55))
		_tabrakan_kotak(taman, "Tabrakan_Bangku2", Vector3(0.55, 0.5, 1.8), Vector3(3.45, 0.25, 0.2))
		# Pohon taman: batang r≈0,16, tinggi 1,8.
		_tabrakan_kotak(taman, "Tabrakan_PohonTaman", Vector3(0.283, 1.8, 0.283), Vector3(-2.2, 0.9, -0.6)) # kotak terinskripsi r=0,20 (anti-slip, fix3 Bagas)
		# Bedeng bunga (0,24 m) + semak SENGAJA tanpa collision
		# (rendah, bisa dilangkahi — seperti pematang sawah).
	# Gubuk santri: tepi barat sawah (ganti GubukSawah primitif) + zona penyangga.
	# GUBUK MASUK (Dewa, 17 Nov 2026): pintu dibuka + collision lantai/
	# dinding/ramp tangga + lampu interior — lihat scripts/gubuk_masuk.gd.
	var gubuk_sawah := _glb(root, "res://models/gubuk-santri.glb", Vector3(26, 0, 30), 0.0, "GLB_GubukSawah")
	if gubuk_sawah != null:
		GubukMasuk.pasang(gubuk_sawah)
	var gubuk_kebun := _glb(root, "res://models/gubuk-santri.glb", Vector3(90, 0, 10), 90.0, "GLB_GubukKebun")
	if gubuk_kebun != null:
		GubukMasuk.pasang(gubuk_kebun)
	# Pagar bambu keliling taman (0,28).
	# PINTU TAMAN (Gilang, 17 Nov 2026): segmen tengah UTARA dilepas
	# — diganti pintu geser bambu (PintuTaman) + collision keliling
	# (lihat _pagar_taman di bawah). Sebelumnya 0 StaticBody3D di
	# bawah GLB mana pun: pemain tembus dari mana saja (probe: 14/14
	# titik tembus, termasuk lewat celah antar panel).
	var bambu: Array = [
		[Vector3(-4, 0, 25.5), 0.0], [Vector3(4, 0, 25.5), 0.0],
		[Vector3(-4, 0, 31.5), 0.0], [Vector3(0, 0, 31.5), 0.0], [Vector3(4, 0, 31.5), 0.0],
		[Vector3(-6.5, 0, 27), 90.0], [Vector3(-6.5, 0, 30), 90.0],
		[Vector3(6.5, 0, 27), 90.0], [Vector3(6.5, 0, 30), 90.0],
	]
	for i in bambu.size():
		_glb(root, "res://models/pagar-bambu.glb", bambu[i][0], float(bambu[i][1]), "GLB_PagarBambu_%d" % i)
	_pagar_taman(root)
	# Pagar bata tepi utara Lapangan Putra (z=39, x -44..-16).
	for i in 8:
		_glb(root, "res://models/pagar-bata.glb", Vector3(-44 + i * 4, 0, 39), 0.0, "GLB_PagarBata_%d" % i)
	# TABRAKAN-DUNIA (Bagas, 18 Nov): pagar bata tanpa collision —
	# pemain tembus (probe baseline). 1 kotak memanjang mengikuti
	# panel (4 m x 0,9 m, tebal 0,16) + 1 kotak per pilar (17 pilar
	# x -46..-14 step 2; pilar 0,3x0,3, tutup 0,42 — kotak 0,42
	# menutup keduanya, tidak lebih lebar dari tutup).
	_tabrakan_kotak(root, "Tabrakan_PagarBata", Vector3(32, 0.96, 0.2), Vector3(-30, 0.48, 39))
	for i in 17:
		var px := -46.0 + float(i) * 2.0
		_tabrakan_kotak(root, "Tabrakan_PagarBata_Pilar_%d" % i, Vector3(0.42, 1.25, 0.42), Vector3(px, 0.625, 39))
	# Pohon rindang tambahan zona penyangga (x 14..115).
	var rindang: Array = [
		Vector3(25, 0, -20), Vector3(35, 0, 5), Vector3(45, 0, -35),
		Vector3(55, 0, 25), Vector3(70, 0, -15), Vector3(85, 0, 40),
		Vector3(100, 0, -30), Vector3(116, 0, 12), Vector3(30, 0, 45),
		Vector3(66, 0, -44),
	]
	for i in rindang.size():
		_glb(root, "res://models/pohon-rindang.glb", rindang[i], float(i * 37 % 360), "GLB_PohonRindang_%d" % i)
		# TABRAKAN-DUNIA (Bagas, 18 Nov): 10 pohon ini dipasang
		# langsung via _glb TANPA collision — pemain tembus (keluhan
		# Mas). Batang r≈0,30, tinggi 6,0; silinder r=0,32 h=1,6
		# (sama seperti _tree rindang).
		_tabrakan_kotak(root, "Tabrakan_PohonRindang_%d" % i, Vector3(0.453, 1.6, 0.453), rindang[i] + Vector3(0, 0.8, 0)) # kotak terinskripsi r=0,32 (anti-slip, fix3 Bagas)


## GESER BANGKU TAMAN (Gilang, 18 Nov 2026 — keputusan Raka opsi a).
## Bangku utara GLB di (0,25,45) tepat di sumbu jalur masuk (x=0),
## tanpa collision — pemain jalan lurus pintu -> peti menembus papan
## duduk/sandaran (foto F6a). Digser 3 m ke BARAT, pusat (-3,25,45),
## rotasi tetap 0 (tetap menghadap pintu/jalur batu), hanya geser x.
## Barat dipilih karena timur sudah ada Bangku_001 (3,45, 28,2) —
## geser ke timur menumpuk dua bangku di satu sisi. Peti (0,28)
## 1,83 m di selatan bangku lama — jarak tak berubah (geser x saja).
## Node bangku TERPISAH di taman.glb (dump 18 Nov 2026): Bangku_Duduk,
## Bangku_Sandaran, Bangku_Sandaran_001, Bangku_Kaki, Bangku_Kaki_001
## — langsung di bawah root GLB, rotY 0 semua — jadi geser via kode
## bisa, tanpa edit GLB.
## CATATAN JUJUR — petak bunga: Bedeng_0 (x -3,8..-1,4, z 25,2..26,4,
## tanah y 0..0,25 + pagar y 0,11..0,29) ikut tertutup sebagian bangku
## baru (x -3,9..-2,1, z 25,2..25,72): kedua kaki berdiri di atas
## bedeng, ±3 bunga (y 0,44..0,56) di bawah papan duduk. Sisi timur
## SAMA SAJA (Bedeng_1 x 1,4..3,8 simetris, 3 bunga juga di bawah
## duduk). Tidak ada sisi yang sepenuhnya lapang di z yang sama —
## kalau Raka/Mas menilai bangku di atas bedeng janggal, perlu edit
## GLB (Bima): geser bangku juga ke selatan / putar, bukan hanya x.
## Bangku tetap TANPA collision (seperti semua GLB taman) — tapi kini
## di luar jalur masuk, jadi pemain di x=0 tidak lagi menembusnya.
static func _geser_bangku_taman(taman: Node3D) -> void:
	for nama in ["Bangku_Duduk", "Bangku_Sandaran", "Bangku_Sandaran_001", "Bangku_Kaki", "Bangku_Kaki_001"]:
		var n := taman.find_child(nama, false, false)
		if n is Node3D:
			(n as Node3D).position.x -= 3.0
		else:
			push_warning("GESER BANGKU: node tak ketemu: " + nama)


## PINTU PAGAR TAMAN (Gilang, 17 Nov 2026) — collision keliling
## taman + pintu geser (scripts/pintu_taman.gd).
## Ukur GLB pagar-bambu: panel x -1,915..1,695, rangka x -2,09..2,09,
## tinggi panel 1,5 / rangka 1,76. Kotak collision mengikuti garis
## visual + menutup celah sudut (rangka utara berakhir ±6,09 sedang
## dinding samping di ±6,5) dan ujung panel samping yang menjorok
## (z 24,91 / 32,09): utara sampai x ±6,5, barat/timur z 24,7..32,2.
## Sisi utara terbelah di bukaan pintu x -1..1 (collision daun ada
## di modul pintu — tertutup = penuh, terbuka = celah nyata).
## Tinggi kotak 1,8 (panel 1,5 + rangka 1,76 + margin) — kapsul
## pemain (r=0,35, tinggi 1,7, tanpa lompat) tak bisa lewat atas.
static func _pagar_taman(root: Node3D) -> void:
	var pagar := Node3D.new()
	pagar.name = "PagarTaman"
	root.add_child(pagar)
	# [nama, ukuran, posisi] — utara terbelah di bukaan pintu.
	var kotak: Array = [
		["PagarTaman_UtaraBarat", Vector3(5.5, 1.8, 0.3), Vector3(-3.75, 0.9, 25.5)],
		["PagarTaman_UtaraTimur", Vector3(5.5, 1.8, 0.3), Vector3(3.75, 0.9, 25.5)],
		["PagarTaman_Selatan", Vector3(13.0, 1.8, 0.3), Vector3(0, 0.9, 31.5)],
		["PagarTaman_Barat", Vector3(0.3, 1.8, 7.5), Vector3(-6.5, 0.9, 28.45)],
		["PagarTaman_Timur", Vector3(0.3, 1.8, 7.5), Vector3(6.5, 0.9, 28.45)],
	]
	for k in kotak:
		var body := StaticBody3D.new()
		body.name = String(k[0])
		body.position = k[2] as Vector3
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = k[1] as Vector3
		shape.shape = box
		body.add_child(shape)
		pagar.add_child(body)
	PintuTaman.pasang(root)


static func _surau(root: Node3D) -> void:
	# V2: TIDAK DIPAKAI LAGI — diganti _surau_glb (GLB Bima).
	# Disimpan supaya desain primitif lama tetap bisa dibaca.
	# RONDE 21 (16 Nov — desain arsitektur ACC Mas 21:49 WIB):
	# SURAU BARU sesuai DESAIN-ARSITEKTUR.md (Arsa) — menggantikan
	# cangkang kotak lama (12x10 m, atap datar, kubah emas).
	# Luar 20 x 16 m, dinding 5 m, pusat (0, 0, -14) — SUSULAN
	# Ronde 21 digeser 2 m ke utara (Mas 22:57 WIB), diputar
	# -25 derajat (kiblat 295°) seperti sebelumnya. Interior TETAP
	# 18 x 14 m (map terpisah InteriorSurau.build(), z=-301) —
	# smartboard, rak kitab, posisi Kyai/santri TIDAK pindah.
	# Elemen desain: kubah utama zamrud + 4 kubah kecil + bulan sabit
	# emas; 1 menara ramping di tenggara (TUTUP ZAMRUD, bukan emas —
	# catatan desain); portal pintu lengkung (voussoir emas) + pintu
	# jati dua daun (TERBUKA, menempel di kusen — celah tetap 2,4 m);
	# 5 jendela lengkung berkisi (3 utara + 2 selatan mengapit
	# serambi); serambi 3 m + atap miring + 3 anak tangga batu;
	# tempat wudu di barat-laut; plakat مصلى الإخلاص tetap di atas
	# pintu. Warna desain: dinding krem #F2EAD6, kubah zamrud
	# #065F46, lis emas #C9A227, jati #7B4B2A, batu #B8B2A4.
	# PENTING: ini hanya CANGKANG LUAR (lihat ronde 4).
	# CATATAN GEOMETRI (terukur Python, 16 Nov ~22:00 WIB):
	# - SUSULAN Ronde 21 (Mas 22:57 WIB: geser Surau ke utara):
	#   pusat (0,-12) -> (0,-14); sudut tenggara kini (5,68,-2,52),
	#   1,27 m dari tepi jalan E-W (z -1,25..1,25) — BERSIH.
	#   Pintu (-3,38,-6,75), exit (-4,01,-5,39), wudu (-9,22,-23,81),
	#   menara (7,86,-4,82). Ukuran TETAP 20x16 m.
	# - SUSULAN Ronde 21 (Mas 22:57 WIB: pindah Cangkruk): Cangkruk
	#   (-12,-12) -> (-22,-18); kandidat (-22,-12) ditolak Cakra
	#   (pohon (-26,-8) di garis dinding selatan + waypoint NPC
	#   (-24,-12) di tengah bentang). Jarak min ke Surau 5,41 m.
	# - JalanSurau lama DIHAPUS (lihat _ground): ujungnya
	#   (-2,11,-7,47) jatuh di dalam Surau baru; serambi + tangga
	#   kini langsung bertemu jalan E-W.
	var s := Node3D.new()
	s.name = "Surau"
	# SUSULAN Ronde 21: root dipindah supaya JANGKAR LOKAL (0,0,-12)
	# mendarat di SURAU_PUSAT — translasi murni 2 m ke utara.
	# JANGAN pakai _posisi_root_putar di sini (itu menjangkar titik
	# lokal SURAU_PUSAT sendiri, sehingga bangunan berayun, bukan
	# bergeser — pusat (-0,85,-12,19), sudut tetap di jalan).
	s.position = SURAU_PUSAT - _putar_sekitar(SURAU_JANGKAR_LOKAL, Vector3.ZERO, SURAU_ROTASI_DEG)
	s.rotation.y = deg_to_rad(SURAU_ROTASI_DEG)
	root.add_child(s)
	# Lantai (pola lama: permukaan y=0,02, rata dengan tanah).
	_static_box(s, Vector3(20, 0.14, 16), Vector3(0, -0.05, -12), Palette.PASIR_GELAP)
	# Ambang pintu emas (tanpa collision) — di pintu BARU (z=-4).
	s.add_child(Palette.box(Vector3(2.4, 0.024, 0.35), Vector3(0, 0.012, -4), Palette.EMAS, 0.4))
	# Dinding: utara, barat, timur utuh; selatan dua segmen + ambang pintu.
	_static_box(s, Vector3(20, 5, 0.25), Vector3(0, 2.5, -20), Palette.KREM).name = "DindingUtara"
	_static_box(s, Vector3(0.25, 5, 16), Vector3(-10, 2.5, -12), Palette.KREM).name = "DindingBarat"
	_static_box(s, Vector3(0.25, 5, 16), Vector3(10, 2.5, -12), Palette.KREM).name = "DindingTimur"
	# Celah pintu 2,4 m (segmen 8,8 m di x=±5,6; tepi dalam ±1,2).
	_static_box(s, Vector3(8.8, 5, 0.25), Vector3(-5.6, 2.5, -4), Palette.KREM).name = "DindingSelatanBarat"
	_static_box(s, Vector3(8.8, 5, 0.25), Vector3(5.6, 2.5, -4), Palette.KREM).name = "DindingSelatanTimur"
	# Ambang atas pintu (y 4,4..5,0) + spandrel di samping lengkung.
	_static_box(s, Vector3(2.4, 0.6, 0.25), Vector3(0, 4.7, -4), Palette.KREM).name = "AmbangPintu"
	_static_box(s, Vector3(0.35, 1.2, 0.25), Vector3(-1.02, 3.8, -4), Palette.KREM)
	_static_box(s, Vector3(0.35, 1.2, 0.25), Vector3(1.02, 3.8, -4), Palette.KREM)
	# Tiang pintu bundar emas (pola lama) — setinggi pintu baru (3,2 m).
	s.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(-1.06, 1.6, -4), Palette.EMAS, 0.4))
	s.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(1.06, 1.6, -4), Palette.EMAS, 0.4))
	# Lengkung portal (voussoir emas, 7 keping di setengah lingkaran
	# r=1,27 berpusat (0, 3,2) — cincin di atas bukaan pintu).
	for i in range(7):
		var a := deg_to_rad(15.0 + float(i) * 30.0)
		var keping := Palette.box(Vector3(0.55, 0.3, 0.34), Vector3(1.27 * cos(a), 3.2 + 1.27 * sin(a), -4), Palette.EMAS_DESAIN, 0.4)
		keping.rotation.z = a - deg_to_rad(90.0)
		keping.name = "Voussoir%d" % i
		s.add_child(keping)
	# Pintu jati dua daun — TERBUKA (menempel di kusen dalam, tanpa
	# collision supaya celah 2,4 m tetap bebas dilewati).
	var daun_kiri := Palette.box(Vector3(0.06, 3.0, 1.1), Vector3(-1.12, 1.5, -4.6), Palette.JATI)
	daun_kiri.name = "PintuDaunKiri"
	s.add_child(daun_kiri)
	var daun_kanan := Palette.box(Vector3(0.06, 3.0, 1.1), Vector3(1.12, 1.5, -4.6), Palette.JATI)
	daun_kanan.name = "PintuDaunKanan"
	s.add_child(daun_kanan)
	# Atap: lis emas + pelat zamrud + kubah utama + 4 kubah kecil.
	s.add_child(Palette.box(Vector3(20.6, 0.1, 16.6), Vector3(0, 5.0, -12), Palette.EMAS_DESAIN, 0.4))
	_static_box(s, Vector3(20.4, 0.25, 16.4), Vector3(0, 5.12, -12), Palette.ZAMRUD_GELAP)
	# Drum krem + kubah utama zamrud (puncak ~9,95 m) + cincin emas.
	s.add_child(Palette.cylinder(2.8, 2.8, 2.0, Vector3(0, 6.25, -12), Palette.KREM))
	s.add_child(Palette.cylinder(2.9, 2.9, 0.15, Vector3(0, 5.3, -12), Palette.EMAS_DESAIN, 0.4))
	var kubah := Palette.sphere(3.0, Vector3(0, 7.25, -12), Palette.ZAMRUD_GELAP, 0.5)
	kubah.scale = Vector3(1, 0.9, 1)
	kubah.name = "KubahUtama"
	s.add_child(kubah)
	# Hiasan puncak: tangkai emas + bulan sabit (bola emas + bola
	# zamrud menutup sebagian — sabit menghadap barat-daya).
	s.add_child(Palette.cylinder(0.07, 0.07, 1.0, Vector3(0, 10.4, -12), Palette.EMAS, 0.5))
	var sabit := Palette.sphere(0.32, Vector3(0, 11.15, -12), Palette.EMAS_TERANG, 0.5)
	sabit.name = "BulanSabit"
	s.add_child(sabit)
	s.add_child(Palette.sphere(0.30, Vector3(0.15, 11.22, -12), Palette.ZAMRUD_GELAP, 0.5))
	# 4 kubah kecil di sudut atap (drum + kubah + bola emas).
	var idx_kecil := 0
	for kx in [-8.0, 8.0]:
		for kz in [-18.0, -6.0]:
			idx_kecil += 1
			s.add_child(Palette.cylinder(0.85, 0.85, 0.6, Vector3(kx, 5.55, kz), Palette.KREM))
			var kecil := Palette.sphere(1.0, Vector3(kx, 5.85, kz), Palette.ZAMRUD_GELAP, 0.5)
			kecil.scale = Vector3(1, 0.8, 1)
			kecil.name = "KubahKecil%d" % idx_kecil
			s.add_child(kecil)
			s.add_child(Palette.sphere(0.09, Vector3(kx, 6.72, kz), Palette.EMAS, 0.5))
	# Lampu hangat di dalam cangkang (grup LampuCahaya).
	var lampu := OmniLight3D.new()
	lampu.position = Vector3(0, 3.5, -12)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.5
	lampu.set_meta("energi_siang", 0.5)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 9.0
	lampu.shadow_enabled = false
	s.add_child(lampu)
	# Menara ramping di tenggara (lokal (11,-7) -> dunia (7,86,-4,82):
	# 3,57 m dari tepi jalan E-W (SUSULAN geser 2 m ke utara), di
	# luar dinding timur, tidak menabrak pagar maupun jalan). Badan
	# tutup kubah ZAMRUD (bukan emas — catatan desain). Puncak ~14,6 m.
	var menara := Node3D.new()
	menara.name = "Menara"
	s.add_child(menara)
	menara.add_child(Palette.cylinder(0.6, 0.6, 0.8, Vector3(11, 0.4, -7), Palette.BATU))
	menara.add_child(Palette.cylinder(0.32, 0.38, 11.5, Vector3(11, 6.55, -7), Palette.KREM))
	menara.add_child(Palette.cylinder(0.42, 0.42, 0.12, Vector3(11, 4.0, -7), Palette.EMAS_DESAIN, 0.4))
	menara.add_child(Palette.cylinder(0.42, 0.42, 0.12, Vector3(11, 8.0, -7), Palette.EMAS_DESAIN, 0.4))
	menara.add_child(Palette.cylinder(0.85, 0.85, 0.18, Vector3(11, 12.4, -7), Palette.KREM))
	menara.add_child(Palette.cylinder(0.87, 0.87, 0.08, Vector3(11, 12.5, -7), Palette.EMAS_DESAIN, 0.4))
	menara.add_child(Palette.cylinder(0.26, 0.32, 1.5, Vector3(11, 13.25, -7), Palette.KREM))
	var tutup := Palette.sphere(0.42, Vector3(11, 14.15, -7), Palette.ZAMRUD_GELAP, 0.5)
	tutup.scale = Vector3(1, 0.85, 1)
	tutup.name = "TutupMenara"
	menara.add_child(tutup)
	menara.add_child(Palette.sphere(0.08, Vector3(11, 14.6, -7), Palette.EMAS, 0.5))
	# Jendela lengkung (kotak gelap + bingkai emas + cakram lengkung
	# di atasnya — pola ronde 20; cakram bawahnya tersembunyi di
	# dalam kotak). 3 di dinding utara + 2 di dinding selatan
	# mengapit serambi. (Desain bilang 6 — selatan tengah dipakai
	# pintu + serambi, jadi selatan 2; total bukaan lengkung 5
	# jendela + 3 lengkung serambi + 1 portal.)
	_jendela_lengkung(s, "Jendela_N1", Vector3(-6, 2.0, -20.16), 0.0)
	_jendela_lengkung(s, "Jendela_N2", Vector3(0, 2.0, -20.16), 0.0)
	_jendela_lengkung(s, "Jendela_N3", Vector3(6, 2.0, -20.16), 0.0)
	_jendela_lengkung(s, "Jendela_S1", Vector3(-7.5, 2.0, -3.84), 0.0)
	_jendela_lengkung(s, "Jendela_S2", Vector3(7.5, 2.0, -3.84), 0.0)
	# PLAKAT di atas pintu (pola ronde 6): papan zamrud berbingkai
	# emas di ambang atas (y 4,7), tulisan Arab "مصلى الإخلاص"
	# font Amiri Bold. Satu-satunya papan di depan Surau.
	var plakat := Node3D.new()
	plakat.name = "PlakatSurau"
	s.add_child(plakat)
	plakat.add_child(Palette.box(Vector3(2.5, 0.55, 0.06), Vector3(0, 4.7, -3.84), Palette.EMAS, 0.4))
	plakat.add_child(Palette.box(Vector3(2.4, 0.45, 0.08), Vector3(0, 4.7, -3.81), Palette.ZAMRUD_GELAP))
	var plakat_label := Palette.label_arab("مصلى الإخلاص", Vector3(0, 4.7, -3.74), 32, Color("#f2c14e"))
	plakat_label.name = "PlakatTeks"
	plakat.add_child(plakat_label)
	# Serambi 3 m di depan pintu: lantai batu + 4 tiang ramping +
	# balok + atap miring. (Tiang timur kini ~2,1-2,6 m dari tepi
	# jalan E-W — SUSULAN geser Surau 2 m ke utara; lihat catatan
	# geometri di atas.)
	var serambi := Node3D.new()
	serambi.name = "Serambi"
	s.add_child(serambi)
	_static_box(serambi, Vector3(6.0, 0.14, 3.0), Vector3(0, -0.05, -2.5), Palette.BATU)
	for tx in [-2.5, -0.85, 0.85, 2.5]:
		serambi.add_child(Palette.cylinder(0.09, 0.09, 3.375, Vector3(tx, 1.69, -1.2), Palette.KREM))
	serambi.add_child(Palette.box(Vector3(6.0, 0.25, 0.3), Vector3(0, 3.5, -1.2), Palette.KREM))
	var atap_serambi := Palette.box(Vector3(6.6, 0.12, 3.8), Vector3(0, 4.15, -2.5), Palette.ZAMRUD_GELAP)
	atap_serambi.rotation.x = deg_to_rad(20.0)
	serambi.add_child(atap_serambi)
	# 3 anak tangga batu di depan serambi (turun ke jalan E-W).
	# Bangunan di tanah datar (lantai y=0,02) jadi tangganya
	# dangkal — lempeng batu, bukan tangga tinggi.
	var tangga := Node3D.new()
	tangga.name = "TanggaSurau"
	s.add_child(tangga)
	_static_box(tangga, Vector3(2.4, 0.08, 0.3), Vector3(0, 0.01, -0.85), Palette.BATU)
	_static_box(tangga, Vector3(2.4, 0.08, 0.3), Vector3(0, -0.005, -0.55), Palette.BATU)
	_static_box(tangga, Vector3(2.4, 0.08, 0.3), Vector3(0, -0.02, -0.25), Palette.BATU)
	# Tempat wudu di barat-laut (lokal (-12,5,-17) -> dunia
	# (-9,22,-23,81)): bak batu + air + 2 keran. Di luar Surau
	# maupun Cangkruk; sisi selatan penuh serambi + jalan.
	var wudu := Node3D.new()
	wudu.name = "TempatWudu"
	s.add_child(wudu)
	_static_box(wudu, Vector3(2.0, 0.06, 1.2), Vector3(-12.5, 0.03, -17), Palette.BATU)
	_static_box(wudu, Vector3(1.6, 0.35, 0.8), Vector3(-12.5, 0.24, -17), Palette.KREM)
	wudu.add_child(Palette.box(Vector3(1.4, 0.05, 0.6), Vector3(-12.5, 0.44, -17), Color("#4a90c2")))
	wudu.add_child(Palette.cylinder(0.03, 0.03, 0.3, Vector3(-12.9, 0.6, -17), Palette.EMAS, 0.4))
	wudu.add_child(Palette.cylinder(0.03, 0.03, 0.3, Vector3(-12.1, 0.6, -17), Palette.EMAS, 0.4))
	# Sandal di depan pintu (pola ronde 6): muncul saat pemain di
	# dalam Surau (main.gd mengaturnya). Kini di serambi (z=-2,8).
	var sandal_luar := Node3D.new()
	sandal_luar.name = "SandalLuarSurau"
	sandal_luar.position = Vector3(0.8, 0, -2.8)
	sandal_luar.visible = false
	s.add_child(sandal_luar)
	for sx in [-0.16, 0.16]:
		var sd := Palette.cylinder(0.11, 0.11, 0.035, Vector3(sx, 0.02, 0), Color("#5a3a22"))
		sd.scale = Vector3(0.9, 1.0, 1.5)
		sandal_luar.add_child(sd)


## Jendela lengkung Surau baru (ronde 21): kotak gelap + bingkai
## emas + cakram lengkung di atas (paruh bawah cakram tersembunyi
## di dalam kotak/bingkai). `pos` = pusat kotak di bidang dinding.
static func _jendela_lengkung(s: Node3D, nama: String, pos: Vector3, rot_y: float) -> void:
	var j := Node3D.new()
	j.name = nama
	j.position = pos
	j.rotation.y = rot_y
	s.add_child(j)
	j.add_child(Palette.box(Vector3(1.1, 1.8, 0.12), Vector3(0, 0, 0), Palette.EMAS, 0.3))
	j.add_child(Palette.box(Vector3(0.9, 1.6, 0.1), Vector3(0, 0, -0.02), Palette.ZAMRUD_GELAP))
	var cakram_emas := Palette.cylinder(0.55, 0.55, 0.06, Vector3(0, 0.8, -0.02), Palette.EMAS, 0.3)
	cakram_emas.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_emas)
	var cakram_gelap := Palette.cylinder(0.45, 0.45, 0.06, Vector3(0, 0.8, -0.04), Palette.ZAMRUD_GELAP)
	cakram_gelap.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_gelap)

static func _cangkruk(root: Node3D) -> void:
	# KAMAR CANGKRUK — POS RONDA TERTUTUP & LUAS (RONDE 6 revisi
	# 23:01 WIB, Mas: "ala POS RONDA tapi tertutup dan luas, ada
	# kamar di dalam, isi 5 kasur dulu buat santri"). Cangkang luar
	# kayu 10 x 8 m, tinggi 3,4 m, pusat (14, 0, -14), timur Surau.
	# Nuansa pos ronda: bangunan kayu + atap segitiga, TAPI dinding
	# penuh (tertutup, bukan terbuka). Pintu di sisi selatan
	# (z=-10), celah 1,6 m. Ini hanya CANGKANG LUAR — isi sebenarnya
	# (5 tempat tidur + lemari) ada di MAP INTERIOR terpisah
	# (InteriorCangkruk.build(), z=-300) — masuk pintu = teleport
	# ke interior ala GTA, sama seperti Surau.
	# RONDE 20: posisi PINDAH (14,-14) -> (-12,-12) area putra
	# (lihat konstanta di atas). Semua koordinat di fungsi ini
	# ditulis relatif terhadap cx/cz — JANGAN hardcode lagi.
	# SUSULAN Ronde 21 (Mas 22:57 WIB): PINDAH (-12,-12) ->
	# (-22,-18); kandidat (-22,-12) ditolak Cakra (pohon (-26,-8)
	# di garis dinding selatan + waypoint NPC (-24,-12) di tengah
	# bentang). Jarak min ke Surau baru 5,41 m.
	var c := Node3D.new()
	c.name = "Cangkruk"
	root.add_child(c)
	var cx := CANGKRUK_POS.x
	var cz := CANGKRUK_POS.y
	# Lantai kayu.
	_static_box(c, Vector3(10, 0.14, 8), Vector3(cx, -0.05, cz), Palette.KAYU)
	# Ambang pintu kayu (penanda visual masuk, tanpa collision).
	c.add_child(Palette.box(Vector3(1.6, 0.024, 0.35), Vector3(cx, 0.012, cz + 4.0), Palette.KAYU_GELAP))
	# Dinding: utara, barat, timur utuh; selatan dua segmen + ambang pintu.
	_static_box(c, Vector3(10, 3.4, 0.25), Vector3(cx, 1.7, cz - 4), Palette.KAYU)
	_static_box(c, Vector3(0.25, 3.4, 8), Vector3(cx - 5, 1.7, cz), Palette.KAYU)
	_static_box(c, Vector3(0.25, 3.4, 8), Vector3(cx + 5, 1.7, cz), Palette.KAYU)
	# Celah pintu 1,6 m (segmen 4,2 m di cx±2,9; tepi dalam ±0,8).
	_static_box(c, Vector3(4.2, 3.4, 0.25), Vector3(cx - 2.9, 1.7, cz + 4), Palette.KAYU)
	_static_box(c, Vector3(4.2, 3.4, 0.25), Vector3(cx + 2.9, 1.7, cz + 4), Palette.KAYU)
	_static_box(c, Vector3(1.6, 1.2, 0.25), Vector3(cx, 2.8, cz + 4), Palette.KAYU)
	# Lis emas di atas pintu.
	c.add_child(Palette.box(Vector3(1.6, 0.1, 0.3), Vector3(cx, 2.6, cz + 4), Palette.EMAS, 0.4))
	# Atap segitiga dua sisi (kayu gelap) + bubungan — ala pos ronda.
	# Puncak y=4,8, lis y=3,2: lereng 6,0 m, sudut ~0,27 rad — ujung
	# lereng bertemu tepat di atas dinding (y=3,4 di x=9/19).
	var atap_kiri := Palette.box(Vector3(6.0, 0.12, 9.6), Vector3(cx - 2.8, 4.0, cz), Palette.KAYU_GELAP)
	atap_kiri.rotation.z = 0.27
	c.add_child(atap_kiri)
	var atap_kanan := Palette.box(Vector3(6.0, 0.12, 9.6), Vector3(cx + 2.8, 4.0, cz), Palette.KAYU_GELAP)
	atap_kanan.rotation.z = -0.27
	c.add_child(atap_kanan)
	c.add_child(Palette.box(Vector3(0.25, 0.25, 9.6), Vector3(cx, 4.85, cz), Palette.KAYU_GELAP))
	# RONDE PERBAIKAN (Fajar): SEGITIGA PELANA — ujung atap (z=cz±4)
	# selama ini TERBUKA (dinding hanya 3,4 m, bubungan 4,85 m:
	# lubang segitiga ~10×1,25 m di tiap ujung, langit menembus).
	# Prisma segitiga kayu, alas 10 m di y=3,4 (puncak dinding),
	# puncak (cx,4,8) tersembunyi di dalam panel atap + bubungan;
	# sisi miringnya (kemiringan 0,28) sejajar lereng atap (0,277)
	# sehingga tepinya bersembunyi di dalam panel, tidak menembus.
	for gz in [cz - 4.0, cz + 4.0]:
		var pelana := MeshInstance3D.new()
		pelana.name = "PelanaAtap_Selatan" if gz > cz else "PelanaAtap_Utara"
		var prisma := PrismMesh.new()
		prisma.size = Vector3(10, 1.4, 0.25)
		prisma.left_to_right = 0.5
		pelana.mesh = prisma
		pelana.material_override = Palette.mat(Palette.KAYU, 0.0, 0.45)
		pelana.position = Vector3(cx, 4.1, gz)
		c.add_child(pelana)
	# Jendela: 2 di timur + 2 di barat + 2 mengapit pintu selatan.
	for wz in [cz + 1.5, cz - 1.5]:
		c.add_child(Palette.box(Vector3(0.1, 0.9, 0.8), Vector3(cx - 5.15, 1.7, wz), Palette.ZAMRUD_GELAP))
		c.add_child(Palette.box(Vector3(0.1, 0.9, 0.8), Vector3(cx + 5.15, 1.7, wz), Palette.ZAMRUD_GELAP))
	for wx in [cx - 2.9, cx + 2.9]:
		c.add_child(Palette.box(Vector3(0.8, 0.9, 0.1), Vector3(wx, 1.7, cz + 4.15), Palette.ZAMRUD_GELAP))
	# Lampu hangat di dalam cangkang supaya pintu bercahaya.
	var lampu := OmniLight3D.new()
	lampu.position = Vector3(cx, 2.6, cz)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.5
	lampu.set_meta("energi_siang", 0.5)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 9.0
	lampu.shadow_enabled = false
	c.add_child(lampu)
	# Label SATU BARIS di atas pintu (teks 3D langsung di ambang
	# pintu; font 20, lebar ~1,4 m, pas di ambang 1,6 m).
	# Revisi 23:01 WIB: label lama terlihat bertumpuk di foto karena
	# bubble chat panjang dari shot sebelumnya masih tampil di atas
	# kepala pemain dan menimpa label ini — BUKAN labelnya ganda.
	# (Skrip foto kini menyembunyikan bubble sebelum shot cangkruk.)
	var label := Palette.label3d("KAMAR CANGKRUK", Vector3(cx, 2.9, cz + 4.15), 20, Color("#f2c14e"), false)
	label.name = "LabelCangkruk"
	label.double_sided = false
	c.add_child(label)
	# RONDE PERBAIKAN (Fajar): label belakang — terbaca benar dari
	# DALAM cangkruk (di atas pintu, menempel sisi dalam dinding).
	var label_dalam := Palette.label3d("KAMAR CANGKRUK", Vector3(cx, 2.9, cz + 3.85), 20, Color("#f2c14e"), false)
	label_dalam.name = "LabelCangkrukBelakang"
	label_dalam.rotation.y = PI
	label_dalam.double_sided = false
	c.add_child(label_dalam)
	# Sandal yang ditinggalkan di depan pintu (RONDE 6): muncul saat
	# pemain di dalam cangkruk (main.gd mengaturnya).
	var sandal_luar := Node3D.new()
	sandal_luar.name = "SandalLuarCangkruk"
	sandal_luar.position = Vector3(cx + 1.4, 0, cz + 4.7)
	sandal_luar.visible = false
	c.add_child(sandal_luar)
	for sx in [-0.16, 0.16]:
		var sd := Palette.cylinder(0.11, 0.11, 0.035, Vector3(sx, 0.02, 0), Color("#5a3a22"))
		sd.scale = Vector3(0.9, 1.0, 1.5)
		sandal_luar.add_child(sd)


## RONDE 21 — Tembok pemisah putra/putri (menggantikan pagar kayu
## Ronde 20 TOTAL — pagar dibongkar, tidak ada lagi).
## Garis lurus x=14, z -60..+16 (76 m), solid tertutup 3 m x 0,4 m,
## plester krem #F2EAD6 + lis emas + fondasi batu, collision penuh.
## Satu-satunya bukaan: GERBANG di (14,0), lebar 4 m (z -2..+2),
## 2 pilar (14,±2) + gapura + label GERBANG, PINTU TERTUTUP +
## barrier collision penuh melintasi bukaan (celah visual, bukan
## celah lewat). Pos satpam (17,5) + satpam NPC (main.gd).
## Tembok TIDAK mengikuti garis pagar lama (belokan x=9 dibuat
## untuk Surau lama; Surau baru menjorok sampai x≈12,4 — belokan
## x=9 akan memotong bangunan; tembok x=14 membersihkannya 1,56 m).
## Celah lama yang Mas temukan: pagar + barrier Ronde 20 hanya
## sepanjang z -60..+16 — santri bisa memutar lewat ujung utara
## (z<-60) atau kawasan bersama selatan (z>16 lalu ke utara).
## Aturan keras baru di main.gd (_cek_batas): putra di (x>14 DAN
## z<16) -> toast + dorong balik ke posisi legal terakhir.
static func _tembok(root: Node3D) -> void:
	var t := Node3D.new()
	t.name = "TembokPemisah"
	root.add_child(t)
	# Segmen utara: z -60..-2 (58 m), pusat z=-31.
	var utara := _static_box(t, Vector3(0.4, 3.0, 58), Vector3(14, 1.5, -31), Palette.KREM)
	utara.name = "TembokUtara"
	# Segmen selatan: z +2..+16 (14 m), pusat z=9.
	var selatan := _static_box(t, Vector3(0.4, 3.0, 14), Vector3(14, 1.5, 9), Palette.KREM)
	selatan.name = "TembokSelatan"
	# Lis emas di atas tembok + fondasi batu di bawah (visual).
	t.add_child(Palette.box(Vector3(0.44, 0.1, 58), Vector3(14, 3.05, -31), Palette.EMAS_DESAIN, 0.4))
	t.add_child(Palette.box(Vector3(0.44, 0.1, 14), Vector3(14, 3.05, 9), Palette.EMAS_DESAIN, 0.4))
	t.add_child(MaterialTekstur.kotak(Vector3(0.5, 0.3, 58), Vector3(14, 0.15, -31), MaterialTekstur.pondasi(Palette.BATU, Vector3(0.25, 0.15, 29))))
	t.add_child(MaterialTekstur.kotak(Vector3(0.5, 0.3, 14), Vector3(14, 0.15, 9), MaterialTekstur.pondasi(Palette.BATU, Vector3(0.25, 0.15, 7))))
	# Pilar gerbang (14,±2): 0,6x3,4x0,6 + tutup emas. (Pusat pilar
	# 0,75 m dari tepi jalan E-W — pilar sudut gerbang, ambang audit
	# 0,5 m; sama seperti pilar gerbang lama (2,5,±2).)
	var pilar_u := _static_box(t, Vector3(0.6, 3.4, 0.6), Vector3(14, 1.7, -2), Palette.KREM)
	pilar_u.name = "PilarGerbangUtara"
	var pilar_s := _static_box(t, Vector3(0.6, 3.4, 0.6), Vector3(14, 1.7, 2), Palette.KREM)
	pilar_s.name = "PilarGerbangSelatan"
	t.add_child(Palette.box(Vector3(0.7, 0.15, 0.7), Vector3(14, 3.45, -2), Palette.EMAS_DESAIN, 0.4))
	t.add_child(Palette.box(Vector3(0.7, 0.15, 0.7), Vector3(14, 3.45, 2), Palette.EMAS_DESAIN, 0.4))
	# Gapura: balok di atas bukaan (y 3,4..3,9) + lis emas + atap zamrud.
	var gapura := Node3D.new()
	gapura.name = "GapuraGerbang"
	t.add_child(gapura)
	_static_box(gapura, Vector3(0.5, 0.5, 4.6), Vector3(14, 3.65, 0), Palette.KREM)
	gapura.add_child(Palette.box(Vector3(0.54, 0.1, 4.6), Vector3(14, 3.92, 0), Palette.EMAS_DESAIN, 0.4))
	gapura.add_child(Palette.box(Vector3(0.8, 0.15, 5.0), Vector3(14, 4.0, 0), Palette.ZAMRUD_GELAP))
	# Label GERBANG menghadap barat (sisi putra) & timur (sisi putri).
	# RONDE PERBAIKAN (Fajar): tiap sisi punya label SENDIRI yang
	# menghadap keluar, dan double_sided=false — kalau tidak, sisi
	# belakang label (cermin) terlihat dari sisi seberang lewat
	# bawah gapura (terbaca terbalik, temuan retest Ronde 23).
	var label_barat := Palette.label3d("GERBANG", Vector3(13.7, 3.65, 0), 24, Color("#f2c14e"), false)
	label_barat.name = "LabelGerbangBarat"
	label_barat.rotation.y = -PI / 2.0
	label_barat.double_sided = false
	gapura.add_child(label_barat)
	var label_timur := Palette.label3d("GERBANG", Vector3(14.3, 3.65, 0), 24, Color("#f2c14e"), false)
	label_timur.name = "LabelGerbangTimur"
	label_timur.rotation.y = PI / 2.0
	label_timur.double_sided = false
	gapura.add_child(label_timur)
	# PINTU GERBANG TERTUTUP: dua daun jati rapat (visual) + barrier
	# collision penuh melintasi bukaan (inilah yang menahan pemain).
	var pintu := Node3D.new()
	pintu.name = "PintuGerbang"
	t.add_child(pintu)
	pintu.add_child(Palette.box(Vector3(0.1, 2.6, 1.9), Vector3(14, 1.3, -1), Palette.JATI))
	pintu.add_child(Palette.box(Vector3(0.1, 2.6, 1.9), Vector3(14, 1.3, 1), Palette.JATI))
	pintu.add_child(Palette.box(Vector3(0.12, 0.12, 3.8), Vector3(14, 2.65, 0), Palette.EMAS_DESAIN, 0.4))
	var barrier := StaticBody3D.new()
	barrier.name = "BarrierGerbang"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.4, 3.0, 4.0)
	col.shape = shape
	col.position = Vector3(14, 1.5, 0)
	barrier.add_child(col)
	pintu.add_child(barrier)

## RONDE 20 — 4 pos jaga keamanan 3x3 m + 1 lampu di sudut kampus
## inti: (±40,-35), (±40,80). P3 (18 Nov, ACC Mas): dinding KREM +
## lis emas, lantai BATU (dulu gubuk kayu penuh); atap piramida
## ZAMRUD_GELAP dipertahankan. TIDAK bisa dimasuki pemain
## (dinding ber-collision, tanpa interior).
static func _pos_jaga(root: Node3D) -> void:
	# RONDE 20 KOREKSI: nama berindeks (PosJaga_1..4) — nama kembar
	# "PosJaga" diganti otomatis Godot sehingga find_children pola
	# eksak hanya menemukan 1 (tes ronde 20 menemukan 1/4).
	var idx := 0
	for pos in POS_JAGA:
		idx += 1
		# Pintu menghadap tengah kampus: pos barat -> pintu timur,
		# pos timur -> pintu barat.
		var hadap_timur := pos.x < 0
		_gubuk_pos(root, pos, "PosJaga_%d" % idx, hadap_timur)


## RONDE 21 — Pos satpam 3x3 m PINDAH ke (17,5), di timur gerbang
## tembok (14,0), pintu menghadap BARAT ke gerbang. Satpam NPC
## berjaga di depannya (main.gd). Pos lama (5,5,5) dihapus.
static func _pos_satpam(root: Node3D) -> void:
	_gubuk_pos(root, POS_SATPAM, "PosSatpam", false)


static func _gubuk_pos(root: Node3D, pos: Vector3, nama: String, pintu_timur: bool) -> void:
	## Gubuk pos 3x3 m. Pintu di dinding timur (pintu_timur=true)
	## atau barat (false). Rotasi node 0/PI supaya dinding bercelah
	## selalu di sisi yang benar.
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	if not pintu_timur:
		g.rotation.y = PI
	root.add_child(g)
	# P3 (18 Nov, ACC Mas): bahasa Surau — lantai BATU, dinding KREM
	# (dulu KAYU penuh), lis EMAS_DESAIN di tepi atas + bawah dinding.
	# Atap piramida ZAMRUD_GELAP dipertahankan (sudah sesuai).
	# Lantai.
	_static_box(g, Vector3(3, 0.14, 3), Vector3(0, -0.05, 0), Palette.BATU)
	# Dinding utara + selatan utuh; dinding barat utuh; dinding
	# timur bercelah pintu 1,2 m (segmen 0,9 m di z=±1,05 + ambang).
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, -1.5), Palette.KREM)
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, 1.5), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 3), Vector3(-1.5, 1.3, 0), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(1.5, 1.3, -1.05), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(1.5, 1.3, 1.05), Palette.KREM)
	_static_box(g, Vector3(0.2, 0.8, 1.2), Vector3(1.5, 2.2, 0), Palette.KREM)
	# Lis emas: pita atas (y 2,53, di bawah atap, keliling penuh) +
	# pita bawah (y 0,10); pita bawah sisi pintu ikut segmen dinding
	# (tidak menutup celah pintu). Visual saja, tanpa collision.
	for z_lis in [-1.5, 1.5]:
		g.add_child(Palette.box(Vector3(3.14, 0.14, 0.26), Vector3(0, 2.53, z_lis), Palette.EMAS_DESAIN, 0.4))
		g.add_child(Palette.box(Vector3(3.14, 0.16, 0.26), Vector3(0, 0.10, z_lis), Palette.EMAS_DESAIN, 0.4))
	for x_lis in [-1.5, 1.5]:
		g.add_child(Palette.box(Vector3(0.26, 0.14, 3.14), Vector3(x_lis, 2.53, 0), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(0.26, 0.16, 3.14), Vector3(-1.5, 0.10, 0), Palette.EMAS_DESAIN, 0.4))
	for z_lis in [-1.05, 1.05]:
		g.add_child(Palette.box(Vector3(0.26, 0.16, 0.94), Vector3(1.5, 0.10, z_lis), Palette.EMAS_DESAIN, 0.4))
	# Atap piramida (visual saja).
	var atap := MeshInstance3D.new()
	atap.name = "AtapPos"
	var atap_mesh := CylinderMesh.new()
	atap_mesh.top_radius = 0.0
	atap_mesh.bottom_radius = 2.3
	atap_mesh.height = 1.0
	atap_mesh.radial_segments = 4
	atap.mesh = atap_mesh
	atap.material_override = Palette.mat(Palette.ZAMRUD_GELAP, 0.0, 0.45)
	atap.position = Vector3(0, 3.1, 0)
	atap.rotation.y = PI / 4.0
	g.add_child(atap)
	# Label nama pos di atas pintu. Nama dasar tanpa "_N" (PosJaga_1
	# -> "POS JAGA", PosSatpam -> "POS SATPAM").
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari dalam pos, pola yang sama seperti label
	# gedung kampus putri) — sisi belakang label lama terbaca cermin.
	# P3 (18 Nov): label diperbesar font 20 -> 28 (P6, supaya terbaca
	# dari jarak normal) + digeser ke y 2,3 supaya seluruhnya di
	# dinding krem, tidak menabrak lis emas atas (y 2,53).
	var label := Palette.label3d(nama.split("_")[0].replace("Pos", "POS ").to_upper(), Vector3(1.6, 2.3, 0), 28, Color("#f2c14e"), false)
	label.name = "LabelPos"
	label.rotation.y = PI / 2.0
	label.double_sided = false
	g.add_child(label)
	var label_dalam := Palette.label3d(nama.split("_")[0].replace("Pos", "POS ").to_upper(), Vector3(1.35, 2.3, 0), 28, Color("#f2c14e"), false)
	label_dalam.name = "LabelPosBelakang"
	label_dalam.rotation.y = -PI / 2.0
	label_dalam.double_sided = false
	g.add_child(label_dalam)
	# Lampu jalan di sudut gubuk (pola _lamp).
	_lamp(root, pos + Vector3(2.2, 0, 2.2))


static func _plots(root: Node3D) -> void:
	# Lahan kosong bertanda untuk bangunan berikutnya (lihat GROWTH_STAGES).
	for stage in MissionData.GROWTH_STAGES:
		if int(stage["tahap"]) == 0:
			continue
		# 18 Nov (Nadia): plot "Asrama" SUDAH DIBANGUN (AsramaPutra.build,
		# ACC Mas 09:37 WIB) — papannya berdiri di dalam Kamar 002
		# (x -18..-14, z 4,6) bila digambar; jangan digambar lagi.
		if String(stage["nama"]) == "Asrama":
			continue
		var plot: Vector2 = stage["plot"]
		var nama: String = stage["nama"]
		var ambang: int = stage["ambang_santri"]
		_plot(root, Vector3(plot.x, 0, plot.y), nama, ambang)


static func _plot(root: Node3D, center: Vector3, nama: String, ambang: int) -> void:
	var p := Node3D.new()
	p.name = "Plot_" + nama.replace(" ", "_")
	root.add_child(p)
	var size := Vector3(10, 0.08, 8)
	p.add_child(Palette.box(size, center + Vector3(0, 0.04, 0), Palette.PASIR))
	# RONDE 6 (15 Nov — Mas: "lahan-lahan tidak usah dikasih pagar..
	# rencana pembangunan nanti aja"): PAGAR LAHAN DIHAPUS — tidak ada
	# lagi tonggak sudut + tali pembatas + dinding tak terlihat di
	# keliling plot. Lahan kini hanya tanah kosong bertanda (alas pasir
	# + papan ambang di bawah). Penanda lahan di minimap/peta penuh +
	# papan ambang TETAP (rencana pertumbuhan yang disetujui 11:37 WIB).
	# Papan tanda di sisi selatan plot. Papan dilebarkan supaya teks muat
	# (font 24, teks terpanjang ~3,9 unit) — sebelumnya teks jauh lebih lebar
	# dari papan.
	# Perbaikan 15 Nov ~12:50 WIB (teks papan "terpotong" di mata penguji):
	# penyebabnya label billboard yang berputar mengikuti kamera — dari
	# sudut samping ≥10°, tepi label berayun ke belakang bidang muka papan
	# (celah hanya 0,06 m) lalu tertutup papan (terukur headless). Label
	# papan kini TIDAK billboard (menempel sejajar papan seperti papan
	# sungguhan) dan digeser 0,15 m ke depan — tidak bisa lagi tertutup papan.
	# RONDE 20: papan Masjid Besar DIGESER 3 m ke barat — posisi lama
	# (0,-21.4) tepat DI ATAS garis pagar putra/putri (x=0); tiang
	# pagar akan menembus papan. Papan baru di (-3,-21.4): tiang
	# papan di x=-5/-1, papan x -5.1..-0.9 — bersih dari pagar.
	# PERBAIKAN JALAN + LAMPU: tiang (-1,-21.4) ternyata berdiri DI
	# ATAS jalan N-S (jalan x -1.25..1.25) dan tiang papan Perpus
	# (+-2,24.6) hanya 0,50 m dari tepi jalan. Kedua papan DIGESER
	# 5 m ke barat — tiang Masjid di x=-7/-3 (1,75 m dari tepi jalan),
	# tiang Perpus di x=-7/-3 (1,50 m dari tepi jalan); papan di sudut
	# barat-daya plot, tetap menandai lahannya.
	var geser_x := 0.0
	if nama == "Masjid Besar" or nama == "Perpustakaan & Taman":
		geser_x = -5.0
	elif nama == "Ruang Kelas":
		# RONDE EXPORT BERIKUTNYA (Gilang, 18 Nov 2026 — temuan Bagas,
		# audit tabrakan): papan lama di (16, 4,6) ada DI DALAM footprint
		# PosSatpam (17,5; gubuk 3x3 -> x 15,5..18,5, z 3,5..6,5) dan
		# tiang barat (14, 4,6) DI DALAM tembok x=14 (x 13,8..14,2,
		# z -60..+16). Geser 5 m ke TIMUR (bukan barat — barat = tembok;
		# bukan utara/selatan saja — tiang barat tetap di x=14):
		# papan baru di (21, 4,6), tiang (19/23, 4,6) — tepi barat
		# papan 18,9 (0,4 m dari dinding pos), tiang barat 19,0
		# (0,5 m), tembok bersih 4,7 m. Tetap di sudut tenggara plot
		# (plot x 11..21, z -4..4), preseden geser papan Masjid Besar /
		# Perpus di atas. Pohon rindang (22,6): batang r~0,16, 1,4 m
		# dari bidang papan — tidak menyentuh (cek probe cek_papan_kelas).
		geser_x = 5.0
	var sign_pos := center + Vector3(geser_x, 0, 4.6)
	p.add_child(Palette.cylinder(0.06, 0.06, 1.6, sign_pos + Vector3(-2.0, 0.8, 0), Palette.KAYU))
	p.add_child(Palette.cylinder(0.06, 0.06, 1.6, sign_pos + Vector3(2.0, 0.8, 0), Palette.KAYU))
	p.add_child(Palette.box(Vector3(4.2, 1.0, 0.08), sign_pos + Vector3(0, 1.5, 0), Palette.PUTIH))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): tiang + papan papan tanda
	# tanpa collision — pemain tembus (probe baseline). Papan di
	# y 1,0..2,0: kapsul pemain (0..1,7) menabraknya bila jalan
	# menembus — collision di bawah membuat fakta visual menjadi fisik.
	# RONDE EXPORT BERIKUTNYA (Gilang, 18 Nov 2026 — temuan Bagas di
	# atas): papan Ruang Kelas DIGESER 5 m ke timur (lihat geser_x di
	# atas) — papan (21, 4,6) + tiang (19/23, 4,6) kini bersih dari
	# PosSatpam maupun tembok x=14. Keputusan: geser PAPAN (bukan pos
	# / tembok — sesuai tugas ronde ini).
	_tabrakan_kotak(p, "Tabrakan_TiangPlot_Barat", Vector3(0.127, 1.6, 0.127), sign_pos + Vector3(-2.0, 0.8, 0)) # kotak terinskripsi r=0,09 (anti-slip, fix3 Bagas)
	_tabrakan_kotak(p, "Tabrakan_TiangPlot_Timur", Vector3(0.127, 1.6, 0.127), sign_pos + Vector3(2.0, 0.8, 0))
	_tabrakan_kotak(p, "Tabrakan_PapanPlot", Vector3(4.2, 1.0, 0.12), sign_pos + Vector3(0, 1.5, 0))
	var label := Palette.label3d("LAHAN " + nama.to_upper() + "\nDibuka saat " + str(ambang) + " santri", sign_pos + Vector3(0, 1.5, 0.15), 24, Color("#065f46"), false)
	p.add_child(label)
	# Perbaikan 15 Nov ~15:05 WIB (lahan 100/200 "hilang" di mata penguji):
	# SEMUA plot sebenarnya ter-spawn dengan teks benar (terukur headless
	# 4/4) — yang hilang adalah KETERBACAAN. Label papan hanya menghadap
	# selatan (+Z); dari utara yang terlihat adalah sisi belakang teks
	# cermin (double_sided=true) sehingga papan tidak dikenali sebagai
	# lahan terkunci — persis untuk plot selatan (didekati dari spawn di
	# utara) dan plot utara (didekati dari pagar utara). Label belakang
	# (diputar 180°, menghadap utara) membuat papan terbaca benar dari
	# DUA sisi; dari tiap sisi, label lawannya tersembunyi di balik papan
	# (papan 4,2 m lebih lebar dari teks 3,9 m).
	var label_blk := Palette.label3d("LAHAN " + nama.to_upper() + "\nDibuka saat " + str(ambang) + " santri", sign_pos + Vector3(0, 1.5, -0.15), 24, Color("#065f46"), false)
	label_blk.rotation_degrees = Vector3(0, 180, 0)
	p.add_child(label_blk)


static func _peti(root: Node3D) -> Dictionary:
	# Peti Kayu di halaman (Misi 3). Tutup berengsel di tepi belakang.
	var chest := Node3D.new()
	chest.name = "PetiKayu"
	chest.position = Vector3(PETI_POS.x, 0, PETI_POS.y)
	root.add_child(chest)
	_static_box(chest, Vector3(1.1, 0.6, 0.75), Vector3(0, 0.3, 0), Palette.KAYU)
	chest.add_child(Palette.box(Vector3(1.14, 0.1, 0.79), Vector3(0, 0.62, 0), Palette.KAYU_GELAP))
	chest.add_child(Palette.box(Vector3(0.12, 0.62, 0.79), Vector3(-0.35, 0.3, 0), Palette.EMAS, 0.4))
	chest.add_child(Palette.box(Vector3(0.12, 0.62, 0.79), Vector3(0.35, 0.3, 0), Palette.EMAS, 0.4))
	# Kunci emas di depan.
	chest.add_child(Palette.box(Vector3(0.18, 0.22, 0.06), Vector3(0, 0.45, 0.4), Palette.EMAS, 0.6))
	# Tutup (pivot di tepi belakang atas).
	var lid := Node3D.new()
	lid.name = "Tutup"
	lid.position = Vector3(0, 0.65, -0.38)
	chest.add_child(lid)
	lid.add_child(Palette.box(Vector3(1.1, 0.22, 0.75), Vector3(0, 0.11, 0.38), Palette.KAYU))
	lid.add_child(Palette.box(Vector3(1.14, 0.06, 0.79), Vector3(0, 0.2, 0.38), Palette.EMAS, 0.4))
	return {"root": chest, "lid": lid}


static func _dekor(root: Node3D) -> void:
	# Pohon. RONDE 4: peta membesar (±56 m) — pohon disebar lebih jauh
	# supaya sudut-sudut baru tidak kosong (tetap low-poly, 3 mesh/pohon).
	# GILANG (ronde 4): 2 pohon dipindah — (-14,-2) ada DI DALAM plot
	# Asrama, (14,4) menempel pagar plot Ruang Kelas; keduanya kini di
	# (-26,-8) dan (22,6), di luar plot.
	# RONDE 20 susulan: (22,-22) ada DI DALAM Musholla Ar-Raudhah
	# (rect lokal x 13..23, z -28..-20, terputar -25°) — tajuknya
	# menembus dinding timur di foto 01. Dipindah ke (22,-32):
	# 4,94 m di utara dinding utara musholla (tajuk 3,79 m), 11,70 m
	# dari tepi JalanMusholla, 16,49 m dari rute patroli Ustadzah.
	# PERBAIKAN JALAN + LAMPU: (10,-6) berdiri DI ATAS JalanMusholla
	# (0,35 m dari sumbu jalan) — dipindah ke (14,-6): 3,14 m dari
	# tepi jalan, 2 m di utara plot Kelas, 1,82 m dari rute patroli.
	# RONDE 21: (14,-6) jatuh TEPAT di garis tembok x=14 — dipindah
	# ke (18,-6): 4 m di timur tembok (tajuk 1,15 m, tidak menyentuh
	# tembok maupun jalan internal putri).
	# (-52,2) hanya 0,75 m dari tepi jalan E-W (tajuk menggantung di
	# atas jalan) — dipindah ke (-52,6): 4,75 m dari tepi jalan.
	# SUSULAN Ronde 21 (geser Surau 2 m ke utara): (9,-18) jatuh
	# DI DALAM footprint Surau — tajuk (r=1,15) menembus dinding
	# utara di jendela N3 (foto 16, temuan Wulan); (-7,-18) juga
	# di dalam footprint (tersembunyi, tanpa cacat visual).
	# Keduanya dipindah 10 m ke utara: (9,-28) + (-7,-28) — di
	# luar plot Masjid Besar (x -5..5), tajuk tidak menyentuh dinding.
	# 18 Nov (Nadia — Asrama Putra): (-24,16) tepat di garis dinding
	# selatan gedung (z=16) -> dipindah ke (-24,22), 6 m di selatan
	# dinding; (-12,10) di dalam annex tangga (x -15..-11,5,
	# z 8,7..11,3) -> dipindah ke (-8,18), bersih dari plot
	# Perpustakaan (x -5..5) dan spawn (-4,14).
	for pos in [Vector3(-10, 0, -8), Vector3(18, 0, -6), Vector3(-8, 0, 18), Vector3(12, 0, 12), Vector3(-7, 0, -28), Vector3(9, 0, -28), Vector3(-26, 0, -8), Vector3(22, 0, 6), Vector3(-20, 0, -26), Vector3(22, 0, -32), Vector3(-24, 0, 22), Vector3(24, 0, 18), Vector3(-32, 0, -10), Vector3(32, 0, -14), Vector3(-20, 0, 32), Vector3(20, 0, 34), Vector3(-42, 0, 24), Vector3(42, 0, -32), Vector3(-44, 0, -32), Vector3(38, 0, 40), Vector3(-38, 0, 42), Vector3(48, 0, 10), Vector3(-48, 0, -14)]:
		_tree(root, pos)
	# GILANG (ronde 4): 14 pohon tambahan di sabuk luar + sudut supaya
	# peta 116 m tidak kosong di tepi. Semua sudah dicek: di luar plot
	# terkunci (jarak aman dari pagar), jalan, surau, spawn, dan penanda
	# misi. Total pohon jadi 37.
	for pos in [Vector3(-36, 0, 6), Vector3(36, 0, -6), Vector3(-30, 0, 34), Vector3(30, 0, 36), Vector3(-52, 0, 30), Vector3(52, 0, -26), Vector3(-52, 0, -40), Vector3(52, 0, 44), Vector3(-36, 0, -44), Vector3(36, 0, -44), Vector3(8, 0, -48), Vector3(-8, 0, 48), Vector3(14, 0, 48), Vector3(-52, 0, 6)]:
		_tree(root, pos)
	# RONDE 5: peta membesar (800 m) — 24 pohon tambahan tersebar sampai
	# radius ~210 m supaya padang terbuka tidak kosong. Semua di luar
	# jalan utama (x=0 / z=0), plot, sawah (x 30..90, z 10..50), surau,
	# dan spawn. Total pohon jadi 61 (37 + 24) — mesh sederhana (3/pohon),
	# masih ringan untuk web.
	for pos in [Vector3(-60, 0, -40), Vector3(60, 0, -50), Vector3(-70, 0, 30), Vector3(70, 0, 60), Vector3(-90, 0, -70), Vector3(90, 0, -80), Vector3(-110, 0, 10), Vector3(110, 0, 20), Vector3(-130, 0, -30), Vector3(130, 0, -40), Vector3(-150, 0, 60), Vector3(150, 0, 70), Vector3(-170, 0, -90), Vector3(170, 0, -100), Vector3(-190, 0, 30), Vector3(190, 0, 40), Vector3(-210, 0, -60), Vector3(210, 0, -70), Vector3(-90, 0, 120), Vector3(90, 0, 130), Vector3(28, 0, 8), Vector3(92, 0, 52), Vector3(-60, 0, 180), Vector3(60, 0, -180)]:
		_tree(root, pos)
	# Lampu di sepanjang jalan utama — DIBANGUN ULANG (susulan Ronde 20,
	# Mas: "Jalan dan lampu dibangun ulang. Yg rapi. Masa ada tiang di
	# tengah jalan."). Skema lama: 8 lampu di x=+-2,2 (hanya 0,70 m dari
	# tepi jalan, sisi acak, jarak z tak teratur) — di foto 03 lampu
	# (-2.2,6) tampak berdiri DI ATAS jalan. Skema baru: SEMUA lampu di
	# SISI BARAT jalan N-S, x=-2,5 (1,0 m dari tepi), jarak z teratur
	# 20 m (z -70,-50,-30,10,30,50,70 — dilewati z -10 = di dalam
	# Surau, z 0 = persimpangan E-W, z -20 = 1 m dari sudut NW Surau).
	# Lampu JalanSurau (-6.89,-2.67): 1,05 m di luar tepi barat jalan,
	# di 1/4 jalan dari E-W (menerangi pintu masuk jalan + serambi
	# Kyai, 2,98 m dari Kyai). Lampu JalanMusholla (15.86,-13.96)
	# DIHAPUS Ronde 21 (musholla lama dibongkar; lampunya berdiri
	# sendirian di zona penyangga). Lampu pos jaga/satpam
	# TETAP (sudah bersih, terukur di audit). (Offset 2,30 m dari
	# sumbu jalan = 1,05 m dari tepi; 2,25 m persis 1,00 m tapi
	# pembulatan koordinat 2 desimal membuat audit mengukur 0,9998 m.)
	for pos in [Vector3(-2.5, 0, -70), Vector3(-2.5, 0, -50), Vector3(-2.5, 0, -30), Vector3(-2.5, 0, 10), Vector3(-2.5, 0, 30), Vector3(-2.5, 0, 50), Vector3(-2.5, 0, 70), Vector3(-6.89, 0, -2.67)]:
		_lamp(root, pos)
	# GILANG (ronde 4): semak + batu sebagai prop pengisi di tepi jalan
	# dan sudut kosong (visual saja, TANPA collision supaya tidak
	# menghalangi jalan pemain/NPC; semua di luar plot dan jalan).
	for pos in [Vector3(-8, 0, 26), Vector3(8, 0, 26), Vector3(-20, 0, -28), Vector3(20, 0, -28), Vector3(-30, 0, -2), Vector3(30, 0, -2)]:
		var semak := Palette.sphere(0.7, pos + Vector3(0, 0.35, 0), Color("#2f6b33"))
		semak.scale = Vector3(1.0, 0.6, 1.0)
		root.add_child(semak)
	for pos in [Vector3(-40, 0, -2), Vector3(40, 0, 2), Vector3(-16, 0, 44), Vector3(16, 0, -44)]:
		var batu := Palette.sphere(0.5, pos + Vector3(0, 0.2, 0), Color("#8a8a8a"))
		batu.scale = Vector3(1.0, 0.55, 1.0)
		root.add_child(batu)
	# RONDE 6 (Mas: "Papan papan di depan surau dihapus semua"): papan
	# selamat datang DIHAPUS — yang tersisa di depan Surau hanya plakat
	# مصلى الإخلاص di atas pintu (lihat _surau).


static func _tree(root: Node3D, pos: Vector3) -> void:
	# V2 (Rangga): pohon primitif diganti GLB Bima.
	# Dekat bangunan/jalan = pohon hias (3,5 m, skala dekat primitif
	# lama); jauh / zona penyangga = pohon rindang (8,5 m).
	var jauh := absf(pos.x) > 45.0 or absf(pos.z) > 45.0 or (pos.x > 14.0 and pos.x < 115.0)
	var nama := "GLB_Pohon_%d_%d" % [int(pos.x), int(pos.z)]
	var rot_y := float(int(absf(pos.x * 31.0 + pos.z * 17.0)) % 360)
	if jauh:
		_glb(root, "res://models/pohon-rindang.glb", pos, rot_y, nama)
	else:
		_glb(root, "res://models/pohon-hias.glb", pos, rot_y, nama)
	# Collision batang (seperti dulu) supaya pemain/NPC tidak jalan menembus batang.
	# TABRAKAN-DUNIA (Bagas, 18 Nov): ukuran mengikuti batang GLB —
	# rindang r≈0,30; hias r≈0,16 (dulu silinder 0,25 untuk keduanya).
	# FIX3: KOTAK terinskripsi (sisi = r*√2), bukan silinder — pemain
	# yang mendorong lurus ke silinder tipis bisa tergelincir
	# mengelilinginya (probe fix2: lampu, pohon hias, 2 pilar);
	# muka datar kotak menahan pendekatan head-on dengan andal,
	# dan kotak terinskripsi tidak pernah melebihi visual.
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.453, 1.6, 0.453) if jauh else Vector3(0.283, 1.6, 0.283)
	shape.shape = box
	body.add_child(shape)
	root.add_child(body)


static func _lamp(root: Node3D, pos: Vector3) -> void:
	var l := Node3D.new()
	l.position = pos
	root.add_child(l)
	l.add_child(Palette.cylinder(0.05, 0.07, 3.0, Vector3(0, 1.5, 0), Palette.HITAM))
	var glow_mat := StandardMaterial3D.new()
	glow_mat.albedo_color = Palette.EMAS_TERANG
	glow_mat.emission_enabled = true
	glow_mat.emission = Palette.EMAS_TERANG
	glow_mat.emission_energy_multiplier = 1.5
	var bulb := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.22
	mesh.height = 0.44
	bulb.mesh = mesh
	bulb.position = Vector3(0, 3.1, 0)
	bulb.material_override = glow_mat
	# RONDE 5: bohlam masuk grup "LampuJalan" supaya LangitDinamis
	# bisa membuatnya menyala terang di malam hari.
	bulb.add_to_group("LampuJalan")
	l.add_child(bulb)
	# TABRAKAN-DUNIA (Bagas, 18 Nov — keluhan Mas: tiang lampu
	# jalan bisa dilewati): tiang r 0,05-0,07 -> silinder r=0,10
	# h=3,0 (bohlam di y=3,1 di atas kapsul pemain, tak perlu).
	_tabrakan_kotak(l, "Tabrakan_Tiang", Vector3(0.141, 3.0, 0.141), Vector3(0, 1.5, 0)) # kotak terinskripsi r=0,10 (anti-slip, fix3 Bagas)


static func _markers(root: Node3D) -> Dictionary:
	# Penanda misi: papan + tanda "!" melayang (atau "TERKUNCI" bila belum terbuka).
	var markers := {}
	for m in MissionData.MISSIONS:
		var id: String = m["id"]
		var pos: Vector3 = m["penanda"]
		var node := Node3D.new()
		node.name = "Marker_" + id
		node.position = pos
		root.add_child(node)
		# RONDE 6 (Mas: "Papan papan di depan surau dihapus semua" +
		# "Papan di dalam surau buang aja"): PAPAN MISI DIHAPUS —
		# penanda misi kini HANYA ikon "!" melayang + label status
		# (TERKUNCI/SELESAI). Papan M1 (dulu di depan pintu Surau)
		# dan papan M2 (dulu di dalam interior) sudah tidak ada.
		var icon := Palette.label3d("!", Vector3(0, 2.9, 0), 64, Palette.EMAS)
		icon.name = "Icon"
		node.add_child(icon)
		# RONDE 7 (retest: label "TERKUNCI" M3 di peti (6,0,10) tampak
		# menempel di dinding depan cangkruk dari titik spawn — label
		# melayang y=2,9 jatuh tepat di rentang dinding 3 m di belakangnya,
		# terkesan cangkruk yang terkunci): label status diturunkan ke
		# y=1,6 — menempel di atas objeknya (peti/penanda), bukan lagi
		# melayang setinggi dinding. Ikon "!" tetap di 2,9 (penanda jauh).
		var status := Palette.label3d("TERKUNCI", Vector3(0, 1.6, 0), 40, Palette.ABU)
		status.name = "Status"
		status.visible = false
		node.add_child(status)
		markers[id] = node
	return markers

