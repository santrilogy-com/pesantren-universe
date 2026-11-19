extends Node
## Tes ANIMASI-MIXAMO (Eka, 17 Nov 2026) — headless:
##   godot --headless --path . skrip/test_animasi_mixamo.tscn
## Cek modul AnimasiMixamo (kurva mocap + anti-tembus) + integrasi
## di player.gd / npc.gd (jalan, duduk/berdiri, idle, NPC jalan).
## Syarat lolos: test_v2.tscn tetap lulus + jalan maju >= 1,20 m
## + transisi duduk/berdiri jalan tanpa error.

var _main: Node
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	# --- 1. Modul: bentuk kurva jalan mocap ---
	var s0 := AnimasiMixamo.sudut_jalan(0.0)
	_cek("Kontak kiri: paha depan -0,35 (dapat %.2f)" % float(s0["leg_l"]), absf(float(s0["leg_l"]) - (-0.35)) < 0.01)
	_cek("Kontak kiri: paha kanan belakang +0,35 (dapat %.2f)" % float(s0["leg_r"]), absf(float(s0["leg_r"]) - 0.35) < 0.01)
	_cek("Kontak kiri: lengan lawan fase +0,30 (dapat %.2f)" % float(s0["arm_l"]), absf(float(s0["arm_l"]) - 0.30) < 0.01)
	_cek("Kontak kiri: lutut hampir lurus (dapat %.2f)" % float(s0["knee_l"]), float(s0["knee_l"]) > 0.0 and float(s0["knee_l"]) < 0.25)
	var s_pi := AnimasiMixamo.sudut_jalan(PI)
	_cek("Kontak kanan: paha kiri belakang +0,35 (dapat %.2f)" % float(s_pi["leg_l"]), absf(float(s_pi["leg_l"]) - 0.35) < 0.01)
	_cek("Kontak kanan: lengan kiri depan -0,30 (dapat %.2f)" % float(s_pi["arm_l"]), absf(float(s_pi["arm_l"]) - (-0.30)) < 0.01)
	# Lutut: 2 puncak per siklus — maks saat ayun ~0,95, tidak negatif.
	var lutut_maks := 0.0
	var lutut_min := 99.0
	for i in range(64):
		var u := TAU * float(i) / 64.0
		var k := AnimasiMixamo.tekuk_lutut(u)
		lutut_maks = maxf(lutut_maks, k)
		lutut_min = minf(lutut_min, k)
	_cek("Lutut ayun menekuk ~0,95 (maks %.2f)" % lutut_maks, lutut_maks >= 0.85 and lutut_maks <= 1.05)
	_cek("Lutut tidak pernah negatif (min %.2f)" % lutut_min, lutut_min >= 0.0)
	# --- 2. Anti-tembus: sandal tidak pernah di bawah lantai ---
	var sandal_min := 99.0
	var sandal_kontak := 0.0
	for i in range(64):
		var u := TAU * float(i) / 64.0
		for kiri in [true, false]:
			var h := AnimasiMixamo.tinggi_sandal(u, kiri)
			sandal_min = minf(sandal_min, h)
		if i == 0:
			sandal_kontak = AnimasiMixamo.tinggi_sandal(u, true)
	_cek("Sandal tidak tembus lantai (min %.3f m)" % sandal_min, sandal_min >= -0.005)
	_cek("Sandal saat kontak dekat lantai (%.3f m)" % sandal_kontak, sandal_kontak >= 0.0 and sandal_kontak < 0.06)
	# Bob pinggul: turun saat kontak, 0 saat mid-stance.
	var bob_kontak := float(AnimasiMixamo.sudut_jalan(0.0)["bob"])
	var bob_tengah := float(AnimasiMixamo.sudut_jalan(PI / 2.0)["bob"])
	_cek("Bob turun saat kontak (%.3f) dan 0 saat mid-stance (%.3f)" % [bob_kontak, bob_tengah], bob_kontak < -0.02 and absf(bob_tengah) < 0.005)

	# --- 3. Integrasi di dunia v2 ---
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Tes animasi")
	for i in 3:
		await get_tree().process_frame
	var player = _main._player
	# Idle: berdiri diam 60 frame FISIKA — napas kecil, tidak ada
	# NaN/inf. (physics_frame, bukan process_frame: di bawah beban
	# mesin paralel, tick fisika lebih jarang dari frame proses —
	# menunggu frame proses saja memberi tick terlalu sedikit dan
	# tes jadi flaky. Pose pemain hidup di _physics_process.)
	for i in 60:
		await get_tree().physics_frame
	var vy: float = player._visual.position.y
	# RONDE 10 (18 Nov 2026, keluhan Mas "badan melayang saat diam"):
	# idle = badan DIAM total, bukan napas ±1,5 cm — posisi harus
	# nyaris nol, bukan sekadar "kecil".
	_cek("Idle: visual.y berhingga dan diam (|y|=%.3f)" % absf(vy), is_finite(vy) and absf(vy) <= 0.005)
	_cek("Idle: posisi visual diam (panjang %.4f m)" % player._visual.position.length(), player._visual.position.length() <= 0.005)
	_cek("Idle: visual tidak miring (|rot.z|=%.4f)" % absf(player._visual.rotation.z), absf(player._visual.rotation.z) <= 0.01)
	# Jalan maju 45 frame FISIKA lewat joystick (pola test_v2):
	# 45 tick = 6,75 rad fase (>1 siklus penuh) dengan blend sudah
	# 1,0 — cukup untuk puncak lutut ayun + lengan lawan fase.
	# Teleport dulu ke jalan N-S (0,20) supaya ~4,5 m jalan tetap
	# di area terbuka.
	player.global_position = Vector3(0, 0, 20)
	player.velocity = Vector3.ZERO
	var awal: Vector3 = player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	var kaki_min := 99.0
	var kaki_maks := -99.0
	var lutut_min_j := 99.0
	var lutut_maks_j := -99.0
	var lengan_lawan := false
	for i in 45:
		await get_tree().physics_frame
		var kl: float = player._leg_l.rotation.x
		var kn: float = player._knee_l.rotation.x
		var ar: float = player._arm_l.rotation.x
		kaki_min = minf(kaki_min, kl)
		kaki_maks = maxf(kaki_maks, kl)
		lutut_min_j = minf(lutut_min_j, kn)
		lutut_maks_j = maxf(lutut_maks_j, kn)
		if kl < -0.2 and ar > 0.1:
			lengan_lawan = true
	_main._ui._joystick.output = Vector2.ZERO
	var jalan: float = player.global_position.distance_to(awal)
	_cek("Jalan maju >= 1,20 m (dapat %.2f m)" % jalan, jalan >= 1.20)
	_cek("Paha mengayun (rentang %.2f rad)" % (kaki_maks - kaki_min), (kaki_maks - kaki_min) > 0.2)
	_cek("Lutut menekuk saat jalan (rentang %.2f rad)" % (lutut_maks_j - lutut_min_j), (lutut_maks_j - lutut_min_j) > 0.3)
	_cek("Lengan berlawanan fase dengan kaki", lengan_lawan)
	# Duduk: transisi 90 frame fisika, lalu berdiri 90 frame fisika.
	player.set_aksi("duduk")
	for i in 90:
		await get_tree().physics_frame
	_cek("Duduk: paha -0,85 (dapat %.2f)" % player._leg_l.rotation.x, absf(player._leg_l.rotation.x - (-0.85)) < 0.12)
	_cek("Duduk: lutut +2,30 (dapat %.2f)" % player._knee_l.rotation.x, absf(player._knee_l.rotation.x - 2.30) < 0.15)
	_cek("Duduk: turun -0,42 (dapat %.2f)" % player._visual.position.y, absf(player._visual.position.y - (-0.42)) < 0.06)
	_cek("Duduk: tangan di pangkuan -0,35 (dapat %.2f)" % player._arm_l.rotation.x, absf(player._arm_l.rotation.x - (-0.35)) < 0.12)
	player.set_aksi("berdiri")
	for i in 90:
		await get_tree().physics_frame
	_cek("Berdiri: paha kembali 0 (dapat %.2f)" % player._leg_l.rotation.x, absf(player._leg_l.rotation.x) < 0.05)
	_cek("Berdiri: lutut kembali 0 (dapat %.2f)" % player._knee_l.rotation.x, absf(player._knee_l.rotation.x) < 0.05)
	_cek("Berdiri: yaw kaki kembali 0 (dapat %.2f)" % player._leg_l.rotation.y, absf(player._leg_l.rotation.y) < 0.05)
	_cek("Berdiri: visual.y kembali 0 (dapat %.2f)" % player._visual.position.y, absf(player._visual.position.y) < 0.05)
	# NPC keliling buatan tes (tidak bergantung pada NPC main):
	# jalan ke target, kaki harus mengayun + posisi berpindah.
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("TesAnim", Vector3(0, 0, 30), [Vector3(10, 0, 30), Vector3(-10, 0, 30)], MissionData.OUTFIT_DEFAULT)
	for i in 3:
		await get_tree().process_frame
	npc._pause_timer = 0.0
	npc._target = Vector3(10, 0, 30)
	var npc_awal: Vector3 = npc.position
	var npc_kaki_min := 99.0
	var npc_kaki_maks := -99.0
	for i in 60:
		await get_tree().process_frame
		var kl2: float = npc._leg_l.rotation.x
		npc_kaki_min = minf(npc_kaki_min, kl2)
		npc_kaki_maks = maxf(npc_kaki_maks, kl2)
	var npc_jalan: float = npc.position.distance_to(npc_awal)
	_cek("NPC jalan > 0,5 m (dapat %.2f m)" % npc_jalan, npc_jalan > 0.5)
	_cek("NPC paha mengayun (rentang %.2f rad)" % (npc_kaki_maks - npc_kaki_min), (npc_kaki_maks - npc_kaki_min) > 0.2)
	_cek("NPC yaw kaki 0 saat jalan (dapat %.2f)" % npc._leg_l.rotation.y, absf(npc._leg_l.rotation.y) < 0.01)
	print("TES ANIMASI-MIXAMO: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
