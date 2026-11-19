class_name AnimasiMixamo
extends RefCounted
## Animasi karakter primitif berbasis motion capture Mixamo (GRATIS).
##
## Latar: karakter game adalah PRIMITIF Godot (bagian badan = node
## terpisah, bukan mesh ter-rig), jadi klip FBX Mixamo tidak bisa
## di-retarget langsung. Yang dipakai dari Mixamo adalah KURVA
## mocap-nya: timing + bentuk pose kunci (ayunan lengan/kaki,
## tekuk lutut ganda, angguk badan, bob pinggul) — lalu diterapkan
## sebagai animasi prosedural pada rig primitif (player.gd / npc.gd).
##
## SUMBER TIMING (file Mixamo TIDAK terunduh — unduh Mixamo butuh
## login akun Adobe gratis, dan tidak ada kredensial Adobe di VM
## ini; mixamo.com terjangkau (HTTP 200, dicek 17 Nov 2026) tapi
## API-nya 401 tanpa login — jadi JANGAN diklaim "pakai file Mixamo"):
## - Mixamo "Walking" (Female Basic Locomotion Pack, in-place):
##   durasi 0,967 dtk, 30 frame @30 fps — diukur AnimSmith 0.14.0
##   dari FBX aslinya (github.com/mmannerm/animsmith, laporan
##   2026-09-16). Satu siklus penuh = 2 langkah.
## - Siklus jalan standar: 24 frame @24 fps = 1,0 dtk per 2 langkah
##   (Richard Williams, "The Animator's Survival Kit").
## - Idle Mixamo/Quaternius UAL: loop ~2,5 dtk (napas + geser berat).
## Angka di bawah (amplitudo, fase lutut) mengikuti bentuk kurva
## mocap itu, BUKAN sinus tunggal seperti kode lama.
##
## ATURAN ANTI-TEMBUS (reel @jipraks): kaki tidak boleh menembus
## lantai dan tangan tidak boleh menembus badan. Dijaga dua cara:
## (1) bob pinggul TURUN saat kontak (bukan naik) + lutut menekuk
## saat ayun, jadi kaki tidak pernah di bawah lantai;
## (2) tinggi_sandal() menghitung posisi sandal lewat FK 2-segmen
## supaya tes headless bisa membuktikan tidak ada penetrasi.
##
## Konvensi fase: `fase` = sudut siklus kaki KIRI (radian).
## fase 0 = kontak kiri (tumit kiri mendarat), fase PI = kontak
## kanan. Satu siklus penuh (TAU) = 2 langkah.
## Konvensi rotasi: rotation.x NEGATIF = anggota gerak mengayun ke
## DEPAN (wajah karakter di +Z). Lutut rotation.x POSITIF = menekuk
## ke belakang (betis terlipat).

## Amplitudo ayunan pinggul (rad, ~20 derajat): pada kontak, kaki
## depan menyentuh lantai saat pinggul turun 3 cm (lihat bob).
const AMPLITUDO_PINGGUL := 0.35
## Amplitudo ayunan lengan (rad): berlawanan fase dengan kaki
## sisi yang sama (mocap: lengan kiri maju saat kaki kiri mundur).
const AMPLITUDO_LENGAN := 0.30
## Bob pinggul: TERENDAH saat kontak (double support), TERTINGGI
## saat mid-stance (satu kaki tegak). Rumus: -0.015-0.015*cos(2u)
## -> 0 di mid-stance (kaki tegak = tinggi berdiri), -0.03 di kontak.
## Kode lama memakai |sin|*0.03 (selalu NAIK) — kaki melayang.
const BOB_TENGAH := 0.015
const BOB_AMPLITUDO := 0.015
## Goyang lateral (berat pindah kiri-kanan tiap langkah).
const GOYANG_SAMPING := 0.015
## Condong badan ke depan saat jalan (rad) + anggukan kecil.
const CONDONG_BADAN := 0.05
## Durasi loop idle (napas) — 2,5 dtk, lihat header.
## RONDE 10 (18 Nov 2026, keluhan Mas 14:03 WIB "kamera saat diam
## kek aneh, gerakannya melayang"): napas + geser berat yang
## menggerakkan SELURUH badan DIHAPUS — badan diam total, yang
## bergerak hanya lengan (ayunan kecil + bersiwak berkala).
## Idle Mixamo/Quaternius UAL: loop ~2,5 dtk (dulu napas + geser
## berat; kini hanya ayunan kecil lengan + bersiwak).
const IDLE_LENGAN_DETIK := 2.5
## Bersiwak berkala (RONDE 21, 18 Nov 2026, perintah Mas 21:19 WIB
## "gerakan garuk-garuk kepala kok aneh" — garuk kepala diganti
## bersiwak): jendela siwak 2,5 dtk, masuk/keluar halus 0,6 dtk.
## RONDE 21b (18 Nov 2026, perintah Mas 21:50 WIB "jangan
## sering-sering"): siklus 11 dtk -> 24-30 dtk PER KARAKTER
## (variasi dari fase_acak — pemain 24,0 dtk, NPC 24-30 dtk);
## jendela tetap di ujung siklus (mulai = siklus - 6,0 dtk).
const IDLE_SIWAK_SIKLUS_MIN := 24.0
const IDLE_SIWAK_SIKLUS_RENTANG := 6.0
const IDLE_SIWAK_LAMA := 2.5
const IDLE_SIWAK_HALUS := 0.6
## Menoleh saat diam (RONDE 21b, perintah Mas 21:50 WIB "kasih
## gerakan menoleh juga kalau lagi diem"): kepala melirik pelan
## kiri/kanan lalu kembali tegak — amplitudo ~20 derajat, jendela
## 4 dtk (naik-tahan-turun halus), siklus 18-25 dtk per karakter,
## arah selang-seling tiap siklus. Hanya saat idle MURNI (bukan
## saat dialog, sama seperti siwak) dan TIDAK bersamaan dengan
## jendela siwak (siwak menang bila bentrok).
const IDLE_MENOLEH_SIKLUS_MIN := 18.0
const IDLE_MENOLEH_SIKLUS_RENTANG := 7.0
const IDLE_MENOLEH_MULAI := 2.0
const IDLE_MENOLEH_LAMA := 4.0
const IDLE_MENOLEH_AMP := 0.35
## Pose bersiwak (sudut target, dari probe FK skrip/probe_siwak.gd):
## tangan kanan naik ke depan-bawah mulut (12-16 cm dari mulut),
## siku menekuk, lengan sedikit masuk ke garis tengah.
const SIWAK_ARM_X := -1.35
const SIWAK_ELBOW_X := -1.30
const SIWAK_ARM_Z := 0.70
## Gosok bolak-balik di depan gigi: siku goyang lateral ±0,06 rad.
const SIWAK_GOSOK_AMP := 0.06
const SIWAK_GOSOK_HZ := 2.5
## Mulut di bingkai lokal visual (kepala bola r=0,24 di y=1,66;
## mulut y=1,55, permukaan wajah z~0,22) + panjang siwak.
const SIWAK_MULUT := Vector3(0, 1.55, 0.22)
const SIWAK_PANJANG := 0.24
## Geometri lengan (sama seperti build_visual): bahu y=1,30,
## lengan atas 0,30, tangan di siku-lokal (0,-0,29,0,01).
const SIWAK_LENGAN_ATAS := 0.30
const SIWAK_TANGAN_OFSET := Vector3(0, -0.29, 0.01)
## Geometri kaki primitif (player.gd build_visual): pinggul y=0,62,
## paha 0,30, betis 0,28, sandal di lokal-lutut y=-0,285 dengan
## tebal 0,035 (dasar sandal = pusat - 0,0175).
const TINGGI_PINGGUL := 0.62
const PANJANG_PAHA := 0.30
const PANJANG_BETIS := 0.28
const SANDAL_JARAK_LUTUT := 0.285
const SANDAL_SETENGAH_TEBAL := 0.0175


## Bangun dict rig dari hasil SantriPlayer.build_visual() — dipakai
## player.gd (_pasang_visual), npc.gd (setup), dan skrip foto/tes.
static func rig_dari_built(built: Dictionary) -> Dictionary:
	return {
		"visual": built["root"],
		"arm_l": built["arm_l"],
		"arm_r": built["arm_r"],
		"elbow_l": built["elbow_l"],
		"elbow_r": built["elbow_r"],
		# RONDE 21: siwak di tangan kanan (null bila rig dibuat dari
		# built lama) — terapkan_idle mengarahkan + menampilkan.
		"siwak": built.get("siwak"),
		# RONDE 21b: pivot kepala (null bila rig dibuat dari built
		# lama) — terapkan_idle memutarnya saat menoleh.
		"kepala": built.get("kepala"),
		# KOREKSI Mas 22:17 WIB: jilbab ikut pivot kepala (null
		# untuk santriwan / built lama) — ikut pivot otomatis, tidak
		# perlu diubah terapkan_idle.
		"hijab": built.get("hijab"),
		"leg_l": built["leg_l"],
		"leg_r": built["leg_r"],
		"knee_l": built["knee_l"],
		"knee_r": built["knee_r"],
	}


## Gauss melingkar (jarak sudut dibungkus ke [-PI, PI]).
static func _gauss_sudut(u: float, pusat: float, lebar: float) -> float:
	var d := fposmod(u - pusat + PI, TAU) - PI
	return exp(-(d / lebar) * (d / lebar))


## Tekuk lutut mocap untuk satu kaki, u = fase lokal kaki itu
## (0 = kontak kaki itu). DUA puncak per siklus (bukan satu):
## - kecil (~0,30 rad) sesaat SETELAH kontak: "loading response",
##   lutut menyerap benturan tumit;
## - besar (~0,95 rad) di tengah AYUNAN (u ~ 4,5): lutut terlipat
##   supaya kaki tidak menyeret lantai saat maju.
## Di mid-stance (u ~ PI/2) lutut hampir lurus lagi (~0).
static func tekuk_lutut(u: float) -> float:
	return 0.30 * _gauss_sudut(u, 0.4, 0.45) + 0.95 * _gauss_sudut(u, 4.5, 0.85)


## Semua sudut jalan untuk satu fase. Mengembalikan dict:
## leg_l/leg_r, knee_l/knee_r, arm_l/arm_r, elbow_l/elbow_r
## (rotation.x), badan_x (condong), badan_z (miring lateral),
## bob (posisi y visual), sway (posisi lateral visual).
static func sudut_jalan(fase: float) -> Dictionary:
	var u := fposmod(fase, TAU)
	var ur := fposmod(fase + PI, TAU)
	var cos_u := cos(u)
	# Kaki: -A*cos(u) -> depan maksimal (-A) saat kontak (u=0),
	# belakang maksimal (+A) saat kontak kaki lain (u=PI).
	var kaki_kiri := -AMPLITUDO_PINGGUL * cos_u
	var kaki_kanan := AMPLITUDO_PINGGUL * cos_u
	# Lengan: berlawanan fase dengan kaki sisi yang sama.
	var lengan_kiri := AMPLITUDO_LENGAN * cos_u
	var lengan_kanan := -AMPLITUDO_LENGAN * cos_u
	# Siku: sedikit menekuk natural (-0,18), LEBIH menekuk saat
	# lengan itu mengayun ke depan (mocap: siku tidak pernah lurus
	# penuh saat jalan).
	var maju_kiri := maxf(0.0, -cos_u)
	var maju_kanan := maxf(0.0, cos_u)
	var siku_kiri := -0.18 - 0.12 * maju_kiri
	var siku_kanan := -0.18 - 0.12 * maju_kanan
	return {
		"leg_l": kaki_kiri,
		"leg_r": kaki_kanan,
		"knee_l": tekuk_lutut(u),
		"knee_r": tekuk_lutut(ur),
		"arm_l": lengan_kiri,
		"arm_r": lengan_kanan,
		"elbow_l": siku_kiri,
		"elbow_r": siku_kanan,
		"badan_x": CONDONG_BADAN + 0.008 * sin(2.0 * u),
		"badan_z": 0.03 * sin(u),
		"bob": -BOB_TENGAH - BOB_AMPLITUDO * cos(2.0 * u),
		"sway": GOYANG_SAMPING * sin(u),
	}


## Terapkan pose jalan pada rig primitif. `blend` 0..1 = amplitudo
## mulai/berhenti bertahap (dipakai pemain; NPC jalan penuh = 1,0).
## Juga MERESET rotasi y/z kaki + lutut ke 0 — pose duduk (yaw
## silang +-0,50) tidak boleh menempel saat jalan (cacat laten:
## _langkah_ke NPC dulu hanya menyentuh rotation.x, jadi Kyai yang
## habis duduk baca lalu patroli tetap jalan dengan kaki menyilang).
static func terapkan_jalan(rig: Dictionary, fase: float, blend: float) -> void:
	var s := sudut_jalan(fase)
	var b := clampf(blend, 0.0, 1.0)
	var vis := rig["visual"] as Node3D
	var arm_l := rig["arm_l"] as Node3D
	var arm_r := rig["arm_r"] as Node3D
	var elbow_l := rig["elbow_l"] as Node3D
	var elbow_r := rig["elbow_r"] as Node3D
	var leg_l := rig["leg_l"] as Node3D
	var leg_r := rig["leg_r"] as Node3D
	var knee_l := rig["knee_l"] as Node3D
	var knee_r := rig["knee_r"] as Node3D
	# Siwak hanya hidup di idle bersiwak — begitu jalan, siwak
	# disembunyikan (jangan menempel di tangan saat bergerak).
	var siwak := rig.get("siwak") as Node3D
	if siwak != null:
		siwak.visible = false
	# RONDE 21b: kepala kembali tegak begitu jalan (jangan menempel
	# menoleh dari idle).
	var kepala := rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.y = 0.0
	arm_l.rotation.x = float(s["arm_l"]) * b
	arm_r.rotation.x = float(s["arm_r"]) * b
	arm_l.rotation.z = 0.05 * b
	arm_r.rotation.z = -0.05 * b
	elbow_l.rotation.x = float(s["elbow_l"]) * b
	elbow_r.rotation.x = float(s["elbow_r"]) * b
	# Goyang lateral siku (gosok siwak) direset — jangan menempel
	# sebagai siku miring saat jalan.
	elbow_l.rotation.z = 0.0
	elbow_r.rotation.z = 0.0
	leg_l.rotation.x = float(s["leg_l"]) * b
	leg_r.rotation.x = float(s["leg_r"]) * b
	leg_l.rotation.y = 0.0
	leg_r.rotation.y = 0.0
	leg_l.rotation.z = 0.0
	leg_r.rotation.z = 0.0
	knee_l.rotation.x = float(s["knee_l"]) * b
	knee_r.rotation.x = float(s["knee_r"]) * b
	knee_l.rotation.y = 0.0
	knee_r.rotation.y = 0.0
	knee_l.rotation.z = 0.0
	knee_r.rotation.z = 0.0
	vis.rotation.x = float(s["badan_x"]) * b
	vis.rotation.z = float(s["badan_z"]) * b
	# Goyang lateral mengikuti sumbu kanan visual (bukan sumbu X
	# dunia — karakter bisa menghadap ke mana saja).
	var kanan := vis.transform.basis.x
	vis.position = kanan * (float(s["sway"]) * b) + Vector3(0.0, float(s["bob"]) * b, 0.0)


## Siklus bersiwak per karakter (RONDE 21b): 24-30 dtk, variasi
## dari fase_acak supaya NPC tidak serempak (pemain fase 0 = 24,0).
static func siklus_siwak(fase_acak: float) -> float:
	return IDLE_SIWAK_SIKLUS_MIN + fposmod(fase_acak, IDLE_SIWAK_SIKLUS_RENTANG)


## Amplop bersiwak 0..1: 0 di luar jendela, naik-turun halus
## (smoothstep 0,6 dtk) di dalam jendela [mulai, mulai+LAMA] di
## ujung tiap siklus. Dipisah supaya bisa dites langsung.
static func amplop_siwak(waktu: float, fase_acak: float) -> float:
	var siklus := siklus_siwak(fase_acak)
	var mulai := siklus - IDLE_SIWAK_LAMA - 3.5
	var t := fposmod(waktu + fase_acak, siklus)
	if t < mulai or t > mulai + IDLE_SIWAK_LAMA:
		return 0.0
	var masuk := clampf((t - mulai) / IDLE_SIWAK_HALUS, 0.0, 1.0)
	var keluar := clampf((mulai + IDLE_SIWAK_LAMA - t) / IDLE_SIWAK_HALUS, 0.0, 1.0)
	var s := minf(masuk, keluar)
	return s * s * (3.0 - 2.0 * s)


## Siklus menoleh per karakter (RONDE 21b): 18-25 dtk, variasi
## dari fase_acak (pemain fase 0 = 18,0).
static func siklus_menoleh(fase_acak: float) -> float:
	return IDLE_MENOLEH_SIKLUS_MIN + fposmod(fase_acak, IDLE_MENOLEH_SIKLUS_RENTANG)


## Arah menoleh -1..+1 (dikalikan IDLE_MENOLEH_AMP oleh pemanggil):
## 0 di luar jendela, bump sinus-kuadrat halus di dalam jendela
## [MULAI, MULAI+LAMA], arah selang-seling kiri/kanan tiap siklus
## (paritas indeks siklus). Dipisah supaya bisa dites langsung.
static func arah_menoleh(waktu: float, fase_acak: float) -> float:
	var siklus := siklus_menoleh(fase_acak)
	var t := fposmod(waktu + fase_acak, siklus)
	if t < IDLE_MENOLEH_MULAI or t > IDLE_MENOLEH_MULAI + IDLE_MENOLEH_LAMA:
		return 0.0
	var u := (t - IDLE_MENOLEH_MULAI) / IDLE_MENOLEH_LAMA
	var bump := sin(PI * u)
	bump *= bump
	var indeks := int(floor((waktu + fase_acak) / siklus))
	return (1.0 if indeks % 2 == 0 else -1.0) * bump


## Panel misi (dialog / Ruang Belajar / tes / Panel Misi) sedang
## terbuka? Dibaca dari ManajerUIMisi di tree (grup
## "manajer_ui_misi"); false bila tidak ada (tes headless / rig
## mandiri / avatar remote tanpa tree). Dipakai menekan siwak +
## menoleh saat dialog — siwak hanya saat idle MURNI. Sengaja
## keempat panel (bukan cuma dialog): saat panel apa pun terbuka,
## pemain sedang berinteraksi dengan UI, bukan diam santai.
static func panel_misi_terbuka(tree: SceneTree) -> bool:
	if tree == null:
		return false
	var m := tree.get_first_node_in_group("manajer_ui_misi") as ManajerUIMisi
	if m == null:
		return false
	return m.ada_panel_terbuka()


## Arahkan siwak ke mulut. Dihitung analitik di bingkai lokal
## visual (tanpa baca global transform — deterministis di tes
## headless maupun di game). Sudut yang dipakai = sudut TARGET
## pose (bukan hasil lerp) supaya arah stabil selama tangan naik.
## Alasan dinamis (bukan hardcode): bahu putri 10,5 cm lebih lebar
## dari putra, jadi arah siwak yang tepat di mulut berbeda jauh
## antar gender (probe v2: putra (0,55,0,11,0,83), putri
## (0,98,-0,02,0,22)) — satu orientasi tetap pasti meleset di
## satu gender. Ujung siwak SELALU tepat di mulut; pusat batang =
## mulut - setengah panjang (bila tangan lebih dekat dari setengah
## panjang, pusat dijepit di tangan supaya ujung tidak menembus
## wajah). Skala tangan z 0,8 ikut dihitung, kalau tidak arah
## meleset.
static func _arahkan_siwak(rig: Dictionary, arm_x: float, elbow_x: float, arm_z: float, elbow_z: float) -> void:
	var siwak := rig.get("siwak") as Node3D
	if siwak == null:
		return
	var arm_r := rig["arm_r"] as Node3D
	var basis_lengan := Basis.from_euler(Vector3(arm_x, 0.0, arm_z))
	var basis_siku := basis_lengan * Basis.from_euler(Vector3(elbow_x, 0.0, elbow_z))
	var tangan := (arm_r.position as Vector3) + basis_lengan * Vector3(0, -SIWAK_LENGAN_ATAS, 0) + basis_siku * SIWAK_TANGAN_OFSET
	var d := SIWAK_MULUT - tangan
	var jarak := d.length()
	if jarak < 0.02:
		return
	d = d / jarak
	var setengah := SIWAK_PANJANG * 0.5
	var pusat := SIWAK_MULUT - d * setengah
	if (pusat - tangan).dot(d) < 0.0:
		pusat = tangan
	var basis_tangan := basis_siku * Basis.from_scale(Vector3(1.0, 1.0, 0.8))
	var inv := basis_tangan.inverse()
	var v_lokal := (inv * d).normalized()
	siwak.quaternion = Quaternion(Vector3.UP, v_lokal)
	siwak.position = inv * (pusat - tangan)


## Idle berdiri/diam (RONDE 10 — diubah 18 Nov 2026 atas keluhan Mas
## 14:03 WIB "kamera saat diam kek aneh, gerakannya melayang"):
## BADAN DIAM TOTAL — tidak ada lagi napas naik-turun (±1,5 cm) dan
## geser berat (±2 cm) yang menggerakkan seluruh visual; itulah yang
## terasa seperti kena angin. Yang bergerak hanya TANGAN/LENGAN:
## ayunan kecil ±0,02 rad + bersiwak berkala (tangan kanan
## terangkat ke mulut, siwak digosok bolak-balik di depan gigi,
## 2,5 dtk tiap siklus 24-30 dtk) + menoleh pelan (kepala melirik
## kiri/kanan ~20 derajat, selang-seling dengan siwak).
## RONDE 21b (perintah Mas 21:50 WIB "kalau diam aja bersiwak..
## jangan sering-sering.. kasih gerakan menoleh juga kalau lagi
## diem"): siwak + menoleh HANYA saat idle MURNI — `dialog_terbuka`
## = true (panel misi terbuka) menekan keduanya sampai 0.
## `waktu` = jam berjalan (detik), `fase_acak` = offset per
## karakter supaya NPC tidak serempak. Semua target di-lerp
## (bobot dijepit 1,0 — pola anti-divergen yang sama seperti
## _animate_idle NPC) supaya peralihan jalan -> diam tidak patah.
static func terapkan_idle(rig: Dictionary, delta: float, waktu: float, fase_acak: float, dialog_terbuka: bool = false) -> void:
	var k := minf(1.0, delta * 8.0)
	var vis := rig["visual"] as Node3D
	var arm_l := rig["arm_l"] as Node3D
	var arm_r := rig["arm_r"] as Node3D
	var elbow_l := rig["elbow_l"] as Node3D
	var elbow_r := rig["elbow_r"] as Node3D
	var leg_l := rig["leg_l"] as Node3D
	var leg_r := rig["leg_r"] as Node3D
	var knee_l := rig["knee_l"] as Node3D
	var knee_r := rig["knee_r"] as Node3D
	# BADAN DIAM: posisi + rotasi visual di-lerp ke NOL — tidak ada
	# napas, tidak ada geser berat, tidak ada miring.
	vis.position = vis.position.lerp(Vector3.ZERO, k)
	vis.rotation.x = lerpf(vis.rotation.x, 0.0, k)
	vis.rotation.z = lerpf(vis.rotation.z, 0.0, k)
	# Lengan: ayunan kecil saja (±0,02 rad) — badan tidak ikut.
	var goyang_lengan := sin(TAU * waktu / IDLE_LENGAN_DETIK + fase_acak + 0.7) * 0.02
	# Bersiwak: tangan kanan naik ke depan-bawah mulut + siku
	# menekuk + lengan sedikit masuk ke garis tengah; ujung siwak
	# digosok bolak-balik di depan gigi (goyang lateral siku
	# ~2,5 Hz) selama jendela amplop. Kepala tetap tegak.
	# RONDE 21b: amplop dipaksa 0 saat dialog terbuka (idle murni
	# saja yang bersiwak).
	var murni := not dialog_terbuka
	var e := amplop_siwak(waktu, fase_acak) if murni else 0.0
	# Menoleh: kepala melirik pelan kiri/kanan (bump halus), lalu
	# kembali tegak. Hanya saat idle murni; ditekan saat dialog;
	# digate (1-e) supaya TIDAK bersamaan dengan jendela siwak
	# (siwak menang bila bentrok — kepala tegak saat bersiwak).
	var kepala := rig.get("kepala") as Node3D
	var yaw_kepala := 0.0
	if murni:
		yaw_kepala = IDLE_MENOLEH_AMP * arah_menoleh(waktu, fase_acak) * (1.0 - e)
	if kepala != null:
		kepala.rotation.y = lerpf(kepala.rotation.y, yaw_kepala, k)
	var gosok := sin(TAU * waktu * SIWAK_GOSOK_HZ + fase_acak) * SIWAK_GOSOK_AMP * e
	var arm_r_x := lerpf(-goyang_lengan, SIWAK_ARM_X, e)
	var elbow_r_x := lerpf(0.0, SIWAK_ELBOW_X, e)
	var arm_r_z := lerpf(-0.05, SIWAK_ARM_Z, e)
	arm_l.rotation.x = lerpf(arm_l.rotation.x, goyang_lengan, k)
	arm_r.rotation.x = lerpf(arm_r.rotation.x, arm_r_x, k)
	arm_l.rotation.z = lerpf(arm_l.rotation.z, 0.05, k)
	arm_r.rotation.z = lerpf(arm_r.rotation.z, arm_r_z, k)
	elbow_l.rotation.x = lerpf(elbow_l.rotation.x, 0.0, k)
	elbow_r.rotation.x = lerpf(elbow_r.rotation.x, elbow_r_x, k)
	elbow_l.rotation.z = lerpf(elbow_l.rotation.z, 0.0, k)
	elbow_r.rotation.z = lerpf(elbow_r.rotation.z, gosok, k)
	leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.0, k)
	leg_r.rotation.x = lerpf(leg_r.rotation.x, 0.0, k)
	leg_l.rotation.y = lerpf(leg_l.rotation.y, 0.0, k)
	leg_r.rotation.y = lerpf(leg_r.rotation.y, 0.0, k)
	leg_l.rotation.z = lerpf(leg_l.rotation.z, 0.0, k)
	leg_r.rotation.z = lerpf(leg_r.rotation.z, 0.0, k)
	knee_l.rotation.x = lerpf(knee_l.rotation.x, 0.0, k)
	knee_r.rotation.x = lerpf(knee_r.rotation.x, 0.0, k)
	knee_l.rotation.y = lerpf(knee_l.rotation.y, 0.0, k)
	knee_r.rotation.y = lerpf(knee_r.rotation.y, 0.0, k)
	knee_l.rotation.z = lerpf(knee_l.rotation.z, 0.0, k)
	knee_r.rotation.z = lerpf(knee_r.rotation.z, 0.0, k)
	# Siwak: muncul hanya selama gerakan bersiwak (di luar itu
	# tersembunyi — jangan menempel permanen di tangan), dan
	# diarahkan ke mulut setiap frame supaya ujungnya tetap di
	# gigi walau tangan bergoyang. Sudut target dipakai (bukan
	# hasil lerp) supaya arah stabil selama tangan naik.
	var siwak := rig.get("siwak") as Node3D
	if siwak != null:
		siwak.visible = e > 0.05
		if e > 0.05:
			_arahkan_siwak(rig, SIWAK_ARM_X, SIWAK_ELBOW_X, SIWAK_ARM_Z, gosok)


## Tinggi DASAR SANDAL di atas lantai (meter) pada satu fase jalan,
## dihitung FK 2-segmen (paha + betis) + bob pinggul. Dipakai tes
## anti-tembus: hasilnya harus >= 0 di semua fase (tidak menembus
## lantai). `kiri` = true untuk kaki kiri, false untuk kanan.
## Catatan: modelnya sendiri melayang ~1,75 cm saat berdiri diam
## (geometri sandal di build_visual) — yang dicek di sini adalah
## animasi tidak MENAMBAH penetrasi, bukan nol absolut.
static func tinggi_sandal(fase: float, kiri: bool) -> float:
	var s := sudut_jalan(fase)
	var theta: float = float(s["leg_l"]) if kiri else float(s["leg_r"])
	var kappa: float = float(s["knee_l"]) if kiri else float(s["knee_r"])
	# Paha dari pinggul: (0,-cos, -sin); betis: sudut paha+lutut.
	var dasar := TINGGI_PINGGUL - PANJANG_PAHA * cos(theta) - SANDAL_JARAK_LUTUT * cos(theta + kappa) - SANDAL_SETENGAH_TEBAL
	return dasar + float(s["bob"])
