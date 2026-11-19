extends Node
## Tes pose duduk kursi + 4 bug sarung/pose (Kirana, 20 Nov 2026 —
## laporan Mas 00:24 WIB dari T1 live 20261119-4).
## Bug 1: sarung mekar pas berdiri setelah duduk (PAKAIAN_DUDUK
## menempel di jalur duduk->berdiri selain sholat).
## Bug 2: duduk bersila mekar kayak bunga (kerucut, bukan gundukan).
## Bug 3: duduk di kursi malah bersila di kursi (kaki harus menjuntai).
## Bug 4: berdiri dari kursi malah berdiri DI ATAS kursi (harus turun
## ke lantai di depan kursi).
## SUSULAN (Kirana, 20 Nov 2026 — verdict Mas 01:28 WIB "Ketika duduk
## bersila masih mekar sarungnya"): gundukan v2 masih kerucut mulus
## dari depan — tonjolan lutut (mesh baru, bukan retune skala):
## dua bola pipih di posisi lutut, muncul HANYA saat bersila.
## DRAPE v3 (Kirana, 20 Nov 2026 — koreksi Mas 06:05 WIB "Yg jelas
## duduk bersila" + 06:06 "sama yg duduk kursi juga aneh"): tonjolan
## lutut v2 DIPENSIUNKAN — drape ArrayMesh (loft) mengikuti paha
## menyilang, sarung silinder jadi inti kecil di dalamnya; duduk
## kursi: tabung sarung DIROTASI mengikuti paha (rot_x 1,69).
## Jalankan headless (HOME terisolasi — jangan pakai save VM):
##   HOME=/tmp/iso-pose-kursi godot --headless --path . --scene res://skrip/test_pose_kursi.tscn
## NPC diuji langsung (set_process(false) — mesin otonom tidak boleh
## menimpa pose yang dipasang manual, pelajaran dari foto pose kursi).
## Pemain diuji lewat API duduk_di_kursi / berdiri_dari_kursi.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _kursi_npc(jenis: String) -> Dictionary:
	for k in SantriNPC.KURSI_LUAR:
		if String(k["jenis"]) == jenis:
			return k
	return {}


func _kasur_npc() -> Dictionary:
	for k in SantriNPC.KURSI_DALAM:
		if String(k["jenis"]) == "kasur":
			return k
	return {}


func _npc_baru(nama: String, pos: Vector3, outfit: Dictionary, muslimah: bool) -> SantriNPC:
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup(nama, pos, [], outfit, muslimah)
	npc.set_process(false)
	return npc


func _tunggu_fisika(jumlah: int) -> void:
	for i in jumlah:
		await get_tree().physics_frame


func _ready() -> void:
	# ---------- Konstanta pakaian baru ----------
	_cek("PAKAIAN_DUDUK v3 = inti kecil (0.80,0.28,0.80) + drape",
		SantriPlayer.PAKAIAN_DUDUK["sarung_scale"].is_equal_approx(Vector3(0.80, 0.28, 0.80))
		and SantriPlayer.PAKAIAN_DUDUK["drape_scale"].is_equal_approx(Vector3.ONE))
	_cek("PAKAIAN_KURSI v2 = sarung miring (1.15,0.55,0.55) rot 1.69 z 0.13",
		SantriPlayer.PAKAIAN_KURSI["sarung_scale"].is_equal_approx(Vector3(1.15, 0.55, 0.55))
		and is_equal_approx(SantriPlayer.PAKAIAN_KURSI["sarung_rot_x"], 1.69)
		and is_equal_approx(SantriPlayer.PAKAIAN_KURSI["sarung_z"], 0.13))
	_cek("PAKAIAN_ABAYA_KURSI v2 = gamis miring (1.05,0.35,0.55)",
		SantriPlayer.PAKAIAN_ABAYA_KURSI["sarung_scale"].is_equal_approx(Vector3(1.05, 0.35, 0.55))
		and is_equal_approx(SantriPlayer.PAKAIAN_ABAYA_KURSI["sarung_rot_x"], 1.69))
	_cek("PAKAIAN_ABAYA_DUDUK v3 = inti (0.75,0.50,0.75) + drape",
		SantriPlayer.PAKAIAN_ABAYA_DUDUK["sarung_scale"].is_equal_approx(Vector3(0.75, 0.50, 0.75))
		and SantriPlayer.PAKAIAN_ABAYA_DUDUK["drape_scale"].is_equal_approx(Vector3.ONE))
	_cek("PAKAIAN_DUDUK/ABAYA_DUDUK lutut_scale = 0 (tonjolan pensiun, drape ganti)",
		SantriPlayer.PAKAIAN_DUDUK["lutut_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_ABAYA_DUDUK["lutut_scale"].is_equal_approx(Vector3.ZERO))
	_cek("PAKAIAN_DEFAULT/KURSI/TIDUR drape_scale = 0",
		SantriPlayer.PAKAIAN_DEFAULT["drape_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_KURSI["drape_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_ABAYA_KURSI["drape_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_TIDUR["drape_scale"].is_equal_approx(Vector3.ZERO))
	_cek("PAKAIAN_DEFAULT/KURSI/TIDUR lutut_scale = 0",
		SantriPlayer.PAKAIAN_DEFAULT["lutut_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_KURSI["lutut_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_ABAYA_KURSI["lutut_scale"].is_equal_approx(Vector3.ZERO)
		and SantriPlayer.PAKAIAN_TIDUR["lutut_scale"].is_equal_approx(Vector3.ZERO))
	_cek("PoseIds POSE_DUDUK_KURSI = 8", PoseIds.POSE_DUDUK_KURSI == 8)
	_cek("PoseIds dari_aksi(duduk_kursi) = 8", PoseIds.dari_aksi("duduk_kursi") == 8)
	_cek("PoseIds ke_aksi(8) = duduk_kursi", PoseIds.ke_aksi(8) == "duduk_kursi")
	_cek("PoseIds aksi_diam(8) = true", PoseIds.aksi_diam(8))

	var bangku: Dictionary = _kursi_npc("kursi")
	var bersila: Dictionary = _kursi_npc("bersila")
	var kasur: Dictionary = _kasur_npc()
	_cek("Registry NPC punya kursi", not bangku.is_empty())
	_cek("Registry NPC punya bersila", not bersila.is_empty())
	_cek("Registry NPC punya kasur", not kasur.is_empty())

	# ---------- BUG 2: bersila v3 (NPC) — drape, bukan gundukan ----------
	var npc := _npc_baru("Hasan", Vector3.ZERO, MissionData.OUTFIT_DEFAULT, false)
	npc._terapkan_duduk_baca(1.0, true, 0.0)
	_cek("BUG2 bersila: visual y = -0.42", is_equal_approx(npc._visual.position.y, -0.42))
	_cek("BUG2 bersila: sarung inti kecil (0.80,0.28,0.80)", npc._sarung.scale.is_equal_approx(Vector3(0.80, 0.28, 0.80)))
	_cek("BUG2 bersila: lutut MELEBAR (leg y kiri -0.50)", is_equal_approx(npc._leg_l.rotation.y, -0.50))
	_cek("BUG2 bersila: lutut MELEBAR (leg y kanan +0.50)", is_equal_approx(npc._leg_r.rotation.y, 0.50))
	_cek("BUG2 bersila: paha -0.85, lutut +2.30",
		is_equal_approx(npc._leg_l.rotation.x, -0.85) and is_equal_approx(npc._knee_l.rotation.x, 2.30))
	_cek("DRAPE bersila: drape tampil + skala penuh",
		npc._drape.visible and npc._drape.scale.is_equal_approx(Vector3.ONE))
	_cek("DRAPE bersila: tonjolan pensiun (sembunyi)",
		not npc._lutut_l.visible and not npc._lutut_r.visible)
	_cek("DRAPE bersila: sarung tegak (rot_x 0, z 0)",
		is_equal_approx(npc._sarung.rotation.x, 0.0) and is_equal_approx(npc._sarung.position.z, 0.0))

	# ---------- BUG 3: duduk di KURSI = kaki menjuntai (NPC) ----------
	npc.position = Vector3(bangku["pos"].x, 0.0, bangku["pos"].z)
	npc._aktivitas = "duduk"
	npc._aktivitas_kursi = bangku
	npc._aktivitas_yaw = float(bangku["yaw"])
	npc._aktivitas_timer = 60.0
	for i in 3:
		npc._proses_aktivitas(1.0)
	_cek("BUG3 kursi: node di TANAH (y=0, bukan 0.45)", is_equal_approx(npc.position.y, 0.0))
	_cek("BUG3 kursi: visual y = -0.17 (pinggul di 0.45)", is_equal_approx(npc._visual.position.y, -0.17))
	_cek("BUG3 kursi: paha horizontal (-1.45)", is_equal_approx(npc._leg_l.rotation.x, -1.45))
	_cek("BUG3 kursi: betis vertikal (lutut +1.45)", is_equal_approx(npc._knee_l.rotation.x, 1.45))
	_cek("BUG3 kursi: BUKAN bersila (lutut bukan 2.30)", not is_equal_approx(npc._knee_l.rotation.x, 2.30))
	_cek("BUG3 kursi: sarung = PAKAIAN_KURSI v2 (1.15,0.55,0.55)", npc._sarung.scale.is_equal_approx(Vector3(1.15, 0.55, 0.55)))
	_cek("BUG3 kursi: sarung miring ikut paha (rot_x 1.69, z 0.13)",
		is_equal_approx(npc._sarung.rotation.x, 1.69) and is_equal_approx(npc._sarung.position.z, 0.13))
	_cek("DRAPE kursi: drape SEMBUNYI (bukan bersila)", not npc._drape.visible)
	_cek("LUTUT kursi: tonjolan SEMBUNYI (bukan bersila)",
		not npc._lutut_l.visible and not npc._lutut_r.visible)

	# ---------- BUG 4: berdiri dari kursi = turun ke "bangun" (NPC) ----------
	npc._akhiri_aktivitas()
	var bangun: Vector3 = KursiPemain.dari_id(String(bangku["id"]))["bangun"]
	_cek("BUG4 kursi: posisi = bangun registry %s" % str(bangun),
		npc.position.is_equal_approx(bangun))
	_cek("BUG4 kursi: node y = tanah (0)", is_equal_approx(npc.position.y, 0.0))
	_cek("BUG4 kursi: visual y kembali 0", is_equal_approx(npc._visual.position.y, 0.0))
	_cek("BUG4 kursi: aktivitas selesai", npc._aktivitas == "")

	# ---------- BUG 1: pakaian kembali DEFAULT di semua jalur berdiri ----------
	# (a) _animate_idle (pause/jeda/diam) — jalur yang dulu tidak
	# memulihkan pakaian sama sekali.
	npc._terapkan_duduk_baca(1.0, true, 0.0)
	npc._animate_idle(1.0)
	_cek("BUG1 idle: sarung kembali DEFAULT", npc._sarung.scale.is_equal_approx(Vector3.ONE))
	_cek("DRAPE idle: drape sembunyi", not npc._drape.visible)
	_cek("LUTUT idle: tonjolan sembunyi", not npc._lutut_l.visible and not npc._lutut_r.visible)
	# (b) _akhiri_aktivitas langsung snap DEFAULT (tanpa tunggu idle).
	npc._aktivitas = "duduk"
	npc._aktivitas_kursi = bersila
	npc._aktivitas_yaw = float(bersila["yaw"])
	npc.position = Vector3(bersila["pos"].x, 0.0, bersila["pos"].z)
	npc._terapkan_duduk_baca(1.0, true, 0.0)
	npc._akhiri_aktivitas()
	_cek("BUG1 akhiri: sarung snap DEFAULT", npc._sarung.scale.is_equal_approx(Vector3.ONE))
	_cek("DRAPE akhiri: drape sembunyi", not npc._drape.visible)
	_cek("LUTUT akhiri: tonjolan sembunyi", not npc._lutut_l.visible and not npc._lutut_r.visible)
	_cek("BUG1 akhiri bersila: berdiri di tempat", npc.position.is_equal_approx(Vector3(bersila["pos"].x, 0.0, bersila["pos"].z)))
	# (c) duduk_belajar -> berdiri_belajar (adegan belajar).
	npc._terapkan_duduk_baca(1.0, true, 0.0)
	npc.berdiri_belajar()
	_cek("BUG1 belajar: sarung kembali DEFAULT", npc._sarung.scale.is_equal_approx(Vector3.ONE))
	_cek("DRAPE belajar: drape sembunyi", not npc._drape.visible)
	_cek("LUTUT belajar: tonjolan sembunyi", not npc._lutut_l.visible and not npc._lutut_r.visible)

	# ---------- Kasur: bersila di atas kasur, bangun menjauh ----------
	npc._aktivitas = "duduk"
	npc._aktivitas_kursi = kasur
	npc._aktivitas_yaw = float(kasur["yaw"])
	npc._aktivitas_timer = 60.0
	npc.position = Vector3(kasur["pos"].x, 0.0, kasur["pos"].z)
	for i in 3:
		npc._proses_aktivitas(1.0)
	_cek("KASUR: visual y = +0.09 (pinggul 0.71)", is_equal_approx(npc._visual.position.y, 0.09))
	_cek("KASUR: kaki bersila (lutut 2.30)", is_equal_approx(npc._knee_l.rotation.x, 2.30))
	_cek("DRAPE kasur: drape tampil (bersila di kasur)",
		npc._drape.visible and npc._drape.scale.is_equal_approx(Vector3.ONE))
	var kasur_pos: Vector3 = kasur["pos"]
	npc._akhiri_aktivitas()
	_cek("KASUR: bangun menjauh dari kasur (>1 m)",
		Vector2(npc.position.x, npc.position.z).distance_to(Vector2(kasur_pos.x, kasur_pos.z)) > 1.0)
	_cek("KASUR: sarung DEFAULT setelah bangun", npc._sarung.scale.is_equal_approx(Vector3.ONE))
	_cek("DRAPE kasur bangun: drape sembunyi", not npc._drape.visible)
	_cek("LUTUT kasur bangun: tonjolan sembunyi", not npc._lutut_l.visible)

	# ---------- Abaya: PAKAIAN_KURSI dipetakan ke ABAYA_KURSI ----------
	var ustadzah := _npc_baru("Ustadzah Mariyah", Vector3(134, 0, -17), MissionData.OUTFIT_USTADZAH, true)
	ustadzah._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_KURSI)
	_cek("ABAYA kursi: skala = ABAYA_KURSI v2 (1.05,0.35,0.55)",
		ustadzah._sarung.scale.is_equal_approx(Vector3(1.05, 0.35, 0.55)))
	_cek("ABAYA kursi: gamis miring (rot_x 1.69)", is_equal_approx(ustadzah._sarung.rotation.x, 1.69))
	_cek("LUTUT abaya kursi: tonjolan SEMBUNYI",
		not ustadzah._lutut_l.visible and not ustadzah._lutut_r.visible)
	# ---------- Abaya bersila: drape di gamis ----------
	ustadzah._terapkan_duduk_baca(1.0, true, 0.0)
	_cek("DRAPE abaya bersila: drape tampil + skala penuh",
		ustadzah._drape.visible and ustadzah._drape.scale.is_equal_approx(Vector3.ONE))
	_cek("LUTUT abaya bersila: tonjolan pensiun (sembunyi)",
		not ustadzah._lutut_l.visible and not ustadzah._lutut_r.visible)
	_cek("DRAPE abaya bersila: sarung inti = ABAYA_DUDUK v3 (0.75,0.50,0.75)",
		ustadzah._sarung.scale.is_equal_approx(Vector3(0.75, 0.50, 0.75)))

	# ---------- "ke_kursi": node tiba di TANAH, bukan di tinggi kursi ----------
	var npc2 := _npc_baru("Budi", Vector3(-3.4, 0, 24.0), MissionData.OUTFIT_DEFAULT, false)
	npc2._aktivitas = "ke_kursi"
	npc2._aktivitas_kursi = bangku
	npc2._aktivitas_yaw = float(bangku["yaw"])
	npc2._aktivitas_rute = [Vector3(bangku["pos"].x, 0.0, bangku["pos"].z)]
	npc2._aktivitas_rute_idx = 0
	for i in 5:
		if npc2._aktivitas == "duduk":
			break
		npc2._proses_aktivitas(1.0)
	_cek("KE_KURSI: sampai jadi duduk", npc2._aktivitas == "duduk")
	_cek("KE_KURSI: node y = 0 (tanah)", is_equal_approx(npc2.position.y, 0.0))

	# ---------- PEMAIN: API duduk_di_kursi / berdiri_dari_kursi ----------
	var pemain := SantriPlayer.new()
	var bentuk := CollisionShape3D.new()
	var kapsul := CapsuleShape3D.new()
	kapsul.radius = 0.35
	kapsul.height = 1.7
	bentuk.shape = kapsul
	bentuk.position = Vector3(0, 0.85, 0)
	pemain.add_child(bentuk)
	add_child(pemain)
	await _tunggu_fisika(2)
	var kursi_pemain: Dictionary = KursiPemain.dari_id("bangku_taman_putra_1a")
	_cek("Registry pemain punya bangku_taman_putra_1a", not kursi_pemain.is_empty())
	pemain.duduk_di_kursi(kursi_pemain)
	await _tunggu_fisika(30)
	_cek("PEMAIN kursi: aksi = duduk_kursi", pemain.aksi_saat_ini() == "duduk_kursi")
	_cek("PEMAIN kursi: pose_id = 8", pemain.pose_id == PoseIds.POSE_DUDUK_KURSI)
	_cek("PEMAIN kursi: sedang_aksi_diam", pemain.sedang_aksi_diam())
	_cek("PEMAIN kursi: node di tanah (y=0)", is_equal_approx(pemain.global_position.y, 0.0))
	_cek("PEMAIN kursi: node di x,z kursi",
		is_equal_approx(pemain.global_position.x, -3.4) and is_equal_approx(pemain.global_position.z, 25.45))
	_cek("PEMAIN kursi: visual y = -0.17 (+-0.05)", absf(pemain._visual.position.y - (-0.17)) < 0.05)
	_cek("PEMAIN kursi: paha -1.45 (+-0.1)", absf(pemain._leg_l.rotation.x - (-1.45)) < 0.1)
	_cek("PEMAIN kursi: lutut +1.45 (+-0.1)", absf(pemain._knee_l.rotation.x - 1.45) < 0.1)
	_cek("PEMAIN kursi: sarung = PAKAIAN_KURSI v2 (+-0.05)",
		absf(pemain._sarung.scale.x - 1.15) < 0.05 and absf(pemain._sarung.scale.y - 0.55) < 0.05)
	_cek("PEMAIN kursi: sarung miring (rot_x 1.69 +-0.1)", absf(pemain._sarung.rotation.x - 1.69) < 0.1)
	_cek("PEMAIN kursi: drape sembunyi", not pemain._drape.visible)
	_cek("PEMAIN kursi: tonjolan sembunyi", not pemain._lutut_l.visible and not pemain._lutut_r.visible)
	_cek("PEMAIN kursi: collision dimatikan", bentuk.disabled)
	_cek("PEMAIN kursi: fisika beku (velocity 0)", pemain.velocity.is_equal_approx(Vector3.ZERO))
	pemain.berdiri_dari_kursi()
	_cek("PEMAIN bangun: posisi = bangun registry",
		pemain.global_position.is_equal_approx(Vector3(-3.4, 0, 26.25)))
	_cek("PEMAIN bangun: aksi = berdiri", pemain.aksi_saat_ini() == "berdiri")
	_cek("PEMAIN bangun: state kursi bersih", pemain.kursi_duduk().is_empty())
	await _tunggu_fisika(2)
	_cek("PEMAIN bangun: collision aktif lagi", not bentuk.disabled)
	await _tunggu_fisika(30)
	_cek("PEMAIN bangun: sarung kembali DEFAULT (+-0.05)",
		absf(pemain._sarung.scale.x - 1.0) < 0.05 and absf(pemain._sarung.scale.y - 1.0) < 0.05)

	# ---------- PEMAIN: bersila + kasur via API ----------
	var kursi_bersila := {"id": "tes_bersila", "pos": Vector3(2, 0, 2), "yaw": PI, "jenis": "bersila", "lantai_y": 0.0, "bangun": Vector3(2, 0, 2)}
	pemain.duduk_di_kursi(kursi_bersila)
	await _tunggu_fisika(30)
	_cek("PEMAIN bersila: aksi = duduk", pemain.aksi_saat_ini() == "duduk")
	_cek("PEMAIN bersila: visual y = -0.42 (+-0.05)", absf(pemain._visual.position.y - (-0.42)) < 0.05)
	_cek("PEMAIN bersila: lutut +2.30 (+-0.1)", absf(pemain._knee_l.rotation.x - 2.30) < 0.1)
	_cek("PEMAIN bersila: drape tampil (+-0.05)",
		pemain._drape.visible and absf(pemain._drape.scale.x - 1.0) < 0.05 and absf(pemain._drape.scale.y - 1.0) < 0.05 and absf(pemain._drape.scale.z - 1.0) < 0.05)
	_cek("PEMAIN bersila: tonjolan pensiun (sembunyi)", not pemain._lutut_l.visible)
	pemain.berdiri_dari_kursi()
	_cek("PEMAIN bersila bangun: berdiri di tempat",
		pemain.global_position.is_equal_approx(Vector3(2, 0, 2)))
	var kursi_kasur := {"id": "tes_kasur", "pos": Vector3(-20, 0.51, -18), "yaw": 0.0, "jenis": "kasur", "lantai_y": 0.0, "bangun": Vector3(-20, 0, -16.5)}
	pemain.duduk_di_kursi(kursi_kasur)
	await _tunggu_fisika(30)
	_cek("PEMAIN kasur: aksi = duduk", pemain.aksi_saat_ini() == "duduk")
	_cek("PEMAIN kasur: visual y = +0.09 (+-0.05)", absf(pemain._visual.position.y - 0.09) < 0.05)
	_cek("PEMAIN kasur: node di tanah (y=0)", is_equal_approx(pemain.global_position.y, 0.0))
	pemain.berdiri_dari_kursi()
	_cek("PEMAIN kasur bangun: posisi = bangun",
		pemain.global_position.is_equal_approx(Vector3(-20, 0, -16.5)))

	# ---------- Safety net: set_aksi("berdiri") langsung dari duduk_kursi ----------
	pemain.duduk_di_kursi(kursi_pemain)
	await _tunggu_fisika(5)
	pemain.set_aksi("berdiri")
	await _tunggu_fisika(2)
	_cek("SAFETY NET: state kursi bersih walau set_aksi langsung", pemain.kursi_duduk().is_empty())
	_cek("SAFETY NET: collision aktif lagi walau set_aksi langsung", not bentuk.disabled)

	print("TES POSE KURSI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
