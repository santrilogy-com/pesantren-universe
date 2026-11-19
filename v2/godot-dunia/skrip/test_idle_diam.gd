extends Node
## Tes IDLE DIAM (Kirana, 18 Nov 2026) — headless:
##   godot --headless --path . skrip/test_idle_diam.tscn
## Keluhan Mas 14:03 WIB: "kamera saat diam kek aneh, gerakannya
## melayang.. harusnya yg gerak cuma tangan misal garuk-garuk kepala
## dll.. bukan badannya yg gerak kem kena angin".
## Akar: AnimasiMixamo.terapkan_idle lama menggerakkan SELURUH
## visual (napas ±1,5 cm + geser ±2 cm + miring) — RONDE 10
## menghapusnya: badan diam total, hanya lengan + garuk kepala
## (saat itu); RONDE 21 mengganti garuk kepala dengan bersiwak.
## RONDE 21 (18 Nov 2026, perintah Mas 21:19 WIB "gerakan
## garuk-garuk kepala kok aneh"): garuk kepala diganti BERSIWAK —
## tangan kanan naik ke mulut, siwak digosok bolak-balik di depan
## gigi, siwak muncul hanya selama gerakan.
## Tes ini membuktikan: (A) modul — badan (posisi+rotasi+kaki)
## diam < 2 mm / < 0,005 rad selama 2 siklus penuh, tangan kanan
## terangkat saat jendela siwak dan kembali diam di luar jendela,
## lengan tetap bergerak halus (bukan patung), siwak terlihat
## hanya di jendela dan ujungnya tepat di mulut (putra + putri);
## (B) integrasi — pemain di dunia v2 saat idle benar-benar diam.
## RONDE 21b (18 Nov 2026, perintah Mas 21:50 WIB "kalau diam
## aja bersiwak.. jangan sering-sering.. kasih gerakan menoleh
## juga kalau lagi diem"): siwak lebih jarang (siklus 24-30 dtk),
## ditekan saat dialog terbuka; menoleh pelan kiri/kanan saat
## idle murni, tidak bersamaan dengan siwak, kepala kembali tegak.

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
	# --- A. Modul: rig mandiri, waktu disimulasi 1/60 dtk ---
	# RONDE 21b: fase_acak 0 -> siklus siwak 24 dtk, jendela
	# 18,0-20,5 dtk; menoleh siklus 18 dtk, jendela 2,0-6,0 dtk.
	_cek("Amplop siwak: 0 di luar jendela (t=2,0)", AnimasiMixamo.amplop_siwak(2.0, 0.0) == 0.0)
	_cek("Amplop siwak: ~1 di tengah jendela (t=19,0)", AnimasiMixamo.amplop_siwak(19.0, 0.0) > 0.9)
	_cek("Amplop siwak: ramp halus di tepi jendela (t=18,3)", AnimasiMixamo.amplop_siwak(18.3, 0.0) > 0.0 and AnimasiMixamo.amplop_siwak(18.3, 0.0) < 1.0)
	_cek("Amplop siwak: 0 setelah jendela (t=22,0)", AnimasiMixamo.amplop_siwak(22.0, 0.0) == 0.0)
	_cek("Siwak tidak tiap 11 dtk lagi (t=11,0)", AnimasiMixamo.amplop_siwak(11.0, 0.0) == 0.0)
	_cek("Siklus siwak pemain 24,0 dtk", AnimasiMixamo.siklus_siwak(0.0) == 24.0)
	_cek("Siklus siwak bervariasi per karakter (fase 3 -> 27,0)", AnimasiMixamo.siklus_siwak(3.0) == 27.0)
	_cek("Menoleh: +1 di tengah jendela siklus 0 (t=4,0)", AnimasiMixamo.arah_menoleh(4.0, 0.0) > 0.9)
	_cek("Menoleh: -1 di siklus 1, arah selang-seling (t=22,0)", AnimasiMixamo.arah_menoleh(22.0, 0.0) < -0.9)
	_cek("Menoleh: 0 di luar jendela (t=10,0)", AnimasiMixamo.arah_menoleh(10.0, 0.0) == 0.0)

	var built := SantriPlayer.build_visual("TesIdle", MissionData.OUTFIT_DEFAULT)
	var rig := AnimasiMixamo.rig_dari_built(built)
	# Rig masuk tree supaya global transform valid saat cek ujung
	# siwak (to_global) di bawah.
	add_child(built["root"])
	var vis := rig["visual"] as Node3D
	var arm_l := rig["arm_l"] as Node3D
	var arm_r := rig["arm_r"] as Node3D
	var leg_l := rig["leg_l"] as Node3D
	var knee_l := rig["knee_l"] as Node3D
	# Bibit goyangan sisa jalan: badan harus kembali diam, bukan
	# mempertahankan goyangannya.
	vis.position = Vector3(0.02, -0.015, 0.01)
	vis.rotation = Vector3(0.03, 0.0, 0.05)
	var delta := 1.0 / 60.0
	var maks_pos := 0.0
	var maks_rot := 0.0
	var maks_kaki := 0.0
	var maks_yaw_kepala := 0.0
	var arm_r_min := 99.0
	var arm_r_di_luar_jendela := 0.0
	var arm_l_min := 99.0
	var arm_l_maks := -99.0
	var waktu := 0.0
	var kepala := rig["kepala"] as Node3D
	# 2 siklus siwak penuh (48 dtk = 2880 langkah).
	for i in range(2880):
		AnimasiMixamo.terapkan_idle(rig, delta, waktu, 0.0)
		waktu += delta
		if waktu > 1.0:
			# Setelah 1 dtk settle, badan harus sudah diam.
			maks_pos = maxf(maks_pos, vis.position.length())
			maks_rot = maxf(maks_rot, absf(vis.rotation.x))
			maks_rot = maxf(maks_rot, absf(vis.rotation.z))
			maks_kaki = maxf(maks_kaki, absf(leg_l.rotation.x))
			maks_kaki = maxf(maks_kaki, absf(knee_l.rotation.x))
			maks_yaw_kepala = maxf(maks_yaw_kepala, absf(kepala.rotation.y))
			arm_r_min = minf(arm_r_min, arm_r.rotation.x)
			arm_l_min = minf(arm_l_min, arm_l.rotation.x)
			arm_l_maks = maxf(arm_l_maks, arm_l.rotation.x)
			# Sampel lengan kanan di luar jendela siwak (t=3,0).
			if absf(fposmod(waktu, 24.0) - 3.0) < delta:
				arm_r_di_luar_jendela = arm_r.rotation.x
	_cek("Badan diam: posisi visual < 2 mm (maks %.4f m)" % maks_pos, maks_pos < 0.002)
	_cek("Badan diam: rotasi visual < 0,005 rad (maks %.4f)" % maks_rot, maks_rot < 0.005)
	_cek("Kaki diam saat idle (maks %.4f rad)" % maks_kaki, maks_kaki < 0.005)
	_cek("Tangan kanan naik ke mulut saat siwak (min %.2f rad)" % arm_r_min, arm_r_min < -1.2)
	_cek("Tangan kanan kembali diam di luar jendela (%.2f rad)" % arm_r_di_luar_jendela, absf(arm_r_di_luar_jendela) < 0.15)
	_cek("Lengan kiri tetap bergerak halus (rentang %.3f rad)" % (arm_l_maks - arm_l_min), (arm_l_maks - arm_l_min) > 0.01)
	_cek("Kepala menoleh saat idle (yaw maks %.2f rad)" % maks_yaw_kepala, maks_yaw_kepala > 0.2)
	_cek("Menoleh tidak berlebihan (yaw maks %.2f rad)" % maks_yaw_kepala, maks_yaw_kepala < 0.40)

	# Siwak: terlihat hanya di jendela, ujungnya tepat di mulut.
	# Settle di tengah jendela (t=19,0) lalu di luar jendela (t=3,0).
	var siwak := rig["siwak"] as Node3D
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 19.0, 0.0)
	await get_tree().process_frame
	_cek("Siwak terlihat di tengah jendela siwak", siwak.visible)
	var ujung_putra: Vector3 = siwak.to_global(Vector3(0, 0.12, 0))
	_cek("Ujung siwak di mulut putra (jarak %.3f m)" % ujung_putra.distance_to(Vector3(0, 1.55, 0.22)), ujung_putra.distance_to(Vector3(0, 1.55, 0.22)) < 0.04)
	var tangan_putra := (siwak.get_parent() as Node3D).global_position
	_cek("Tangan tidak menembus kepala putra (jarak %.3f m)" % tangan_putra.distance_to(Vector3(0, 1.66, 0)), tangan_putra.distance_to(Vector3(0, 1.66, 0)) > 0.25)
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 3.0, 0.0)
	await get_tree().process_frame
	_cek("Siwak tersembunyi di luar jendela siwak", not siwak.visible)

	# RONDE 21b: menoleh tidak tumpang siwak — di tengah jendela
	# siwak kepala harus tegak (gate 1-e).
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 19.0, 0.0)
	_cek("Menoleh tidak tumpang siwak (yaw %.3f saat jendela siwak)" % kepala.rotation.y, absf(kepala.rotation.y) < 0.05)
	# Menoleh: kepala melirik di tengah jendela (t=4,0, siklus 0
	# arah +1) lalu kembali tegak di luar jendela (t=10,0).
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 4.0, 0.0)
	_cek("Kepala menoleh saat idle (yaw %.2f rad)" % kepala.rotation.y, kepala.rotation.y > 0.2)
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 10.0, 0.0)
	_cek("Kepala kembali tegak di luar jendela menoleh (yaw %.3f)" % kepala.rotation.y, absf(kepala.rotation.y) < 0.05)
	# Dialog terbuka: siwak + menoleh ditekan (idle murni saja).
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 19.0, 0.0, true)
	await get_tree().process_frame
	_cek("Siwak tersembunyi saat dialog terbuka (t=19,0)", not siwak.visible)
	_cek("Tangan kanan diam saat dialog (%.2f rad)" % arm_r.rotation.x, absf(arm_r.rotation.x) < 0.15)
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig, delta, 4.0, 0.0, true)
	_cek("Kepala tegak saat dialog (yaw %.3f)" % kepala.rotation.y, absf(kepala.rotation.y) < 0.05)

	# Putri (bahu 10,5 cm lebih lebar — arah siwak berbeda):
	# ujung siwak harus tetap di mulut.
	var built_putri := SantriPlayer.build_visual("TesIdlePutri", NPCFatimah.OUTFIT_FATIMAH)
	var rig_putri := AnimasiMixamo.rig_dari_built(built_putri)
	add_child(built_putri["root"])
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig_putri, delta, 19.0, 0.0)
	await get_tree().process_frame
	var siwak_putri := rig_putri["siwak"] as Node3D
	var ujung_putri: Vector3 = siwak_putri.to_global(Vector3(0, 0.12, 0))
	_cek("Ujung siwak di mulut putri (jarak %.3f m)" % ujung_putri.distance_to(Vector3(0, 1.55, 0.22)), ujung_putri.distance_to(Vector3(0, 1.55, 0.22)) < 0.04)

	# KOREKSI Mas 22:17 WIB ("harusnya jilbab ikut noleh"): jilbab
	# harus berputar bersama kepala — bukaan wajah ikut wajah, jadi
	# mata sisi jauh tidak ketutup tepi kain di puncak putaran.
	var kepala_putri := rig_putri["kepala"] as Node3D
	var hijab_putri := rig_putri["hijab"] as Node3D
	_cek("Jilbab ada di rig putri", hijab_putri != null)
	_cek("Jilbab anak KepalaPivot (ikut menoleh)", hijab_putri != null and hijab_putri.get_parent() == kepala_putri)
	for i in range(90):
		AnimasiMixamo.terapkan_idle(rig_putri, delta, 4.0, 0.0)
	await get_tree().process_frame
	_cek("Jilbab berputar bersama kepala di puncak menoleh (yaw hijab %.2f vs kepala %.2f)" % [hijab_putri.global_rotation.y, kepala_putri.global_rotation.y], absf(hijab_putri.global_rotation.y - kepala_putri.global_rotation.y) < 0.01 and absf(kepala_putri.global_rotation.y) > 0.2)

	# --- B. Integrasi: pemain di dunia v2, idle 90 frame fisika ---
	var packed := load("res://main.tscn") as PackedScene
	var main := packed.instantiate()
	add_child(main)
	for i in 3:
		await get_tree().process_frame
	main._masuk_pesantren("Tes idle diam")
	for i in 3:
		await get_tree().process_frame
	var player = main._player
	var pos_maks := 0.0
	var rot_maks := 0.0
	var yaw_maks := 0.0
	var kepala_main := player._rig.get("kepala") as Node3D
	for i in 90:
		await get_tree().physics_frame
		pos_maks = maxf(pos_maks, player._visual.position.length())
		rot_maks = maxf(rot_maks, absf(player._visual.rotation.z))
		yaw_maks = maxf(yaw_maks, absf(kepala_main.rotation.y))
	_cek("Integrasi idle: posisi visual < 5 mm (maks %.4f m)" % pos_maks, pos_maks < 0.005)
	_cek("Integrasi idle: miring visual < 0,01 rad (maks %.4f)" % rot_maks, rot_maks < 0.01)
	_cek("Integrasi idle: visual.y berhingga", is_finite(player._visual.position.y))
	_cek("Integrasi idle: kepala tegak sebelum jendela menoleh (yaw maks %.4f)" % yaw_maks, yaw_maks < 0.05)
	print("TES IDLE-DIAM: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
