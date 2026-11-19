extends Node
## Tes salaman pemain (Raka, 20 Nov 2026 — permintaan Mas 00:24 WIB:
## "bisa salaman sama NPC atau player lain").
## Fase 1: salaman NPC berdiri (Bilal) — pemain pose + NPC hadap/jabat.
## Fase 2: cooldown NPC (10 dtk) + cooldown pemain (5 dtk).
## Fase 3: NPC sedang duduk — berdiri dulu untuk salaman, kembali duduk.
## Fase 4: tolak saat sholat. Fase 5: tolak saat duduk belajar.
## Fase 6: solo tanpa target (offline, tanpa RPC). Fase 7: Sanusi +
## Fatimah (tidak masuk _npcs) ikut bisa disalami. Fase 8: guard MP
## offline — watcher _salaman_cek_undangan_peer tanpa _players
## tidak crash (salaman MP tanpa RPC: ajakan = pose_id peer).
## Jalankan headless (HOME terisolasi — jangan pakai save VM):
##   HOME=/tmp/iso-salaman godot --headless --path . --scene res://skrip/test_salaman.tscn
## Exit 0 = semua lulus; bukan-nol = ada gagal. 0 SCRIPT ERROR dicek
## dari log oleh runner (pola gate).

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik).timeout


func _npc_sistem_baru() -> Array:
	var hasil: Array = []
	for npc in _main._npcs:
		if bool(npc.get("_aktivitas_aktif")):
			hasil.append(npc)
	return hasil


func _tidak_ada_yang_salaman() -> bool:
	for npc in _main._npcs:
		if String(npc.get("_salaman")) != "":
			return false
	for guru in [_main._sanusi, _main._fatimah]:
		if guru != null and String(guru.get("_salaman")) != "":
			return false
	return true


## Pindahkan NPC lain (kecuali yang dikecualikan) yang sedang dalam
## 3 m dari posisi pemain ke tempat jauh + bekukan — supaya target
## _on_aksi("salaman") deterministik (yang terdekat = yang diuji).
func _bersihkan_sekitar(pos: Vector3, kecuali: Array) -> void:
	for npc in _main._npcs:
		if npc in kecuali:
			continue
		if (npc.global_position as Vector3).distance_to(pos) < 3.0:
			npc.global_position = Vector3(-30, 0, 30)
			npc.set("_target", Vector3(-30, 0, 30))
			npc.set("_pause_timer", 15.0)
	for guru in [_main._sanusi, _main._fatimah]:
		if guru != null and not (guru in kecuali):
			if (guru.global_position as Vector3).distance_to(pos) < 3.0:
				guru.global_position = Vector3(-30, 0, 34)
				guru.set("_target", Vector3(-30, 0, 34))
				guru.set("_pause_timer", 15.0)


## Jarak tangan kanan pemain ↔ tangan kanan NPC (posisi dunia node
## "TanganKanan" — bukti tangan benar-benar bertemu, bukan sekadar
## pose terulur). 99 bila node tidak ketemu.
func _jarak_tangan(npc: Node) -> float:
	var tp: Node3D = _main._player.find_child("TanganKanan", true, false) as Node3D
	var tn: Node3D = npc.find_child("TanganKanan", true, false) as Node3D
	if tp == null or tn == null:
		return 99.0
	return (tp.global_position as Vector3).distance_to(tn.global_position as Vector3)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes Salaman")
	for i in 5:
		await get_tree().process_frame

	# ---------- FASE 1: salaman NPC berdiri (Bilal) ----------
	print("SALAMAN: === FASE 1 Bilal berdiri ===")
	var bilal: Node = _main._bilal
	bilal.global_position = Vector3(-4, 0, 4)
	bilal.set("_target", Vector3(-4, 0, 4))
	bilal.set("_pause_timer", 10.0)
	_main._player.global_position = Vector3(-4, 0, 6)
	_bersihkan_sekitar(Vector3(-4, 0, 6), [bilal])
	await _tunggu(0.3)
	_main._on_aksi("salaman")
	_cek("f1: pemain pose salaman", String(_main._player.aksi_saat_ini()) == "salaman")
	_cek("f1: Bilal merespons (hadap/hampiri/jabat)", String(bilal.get("_salaman")) != "")
	# Tunggu fase jabat (hadap 0,4 dtk + hampiri s.d. 2,0 dtk) —
	# jangan asumsi waktu tetap seperti sebelum polish.
	var tunggu_jabat := 0.0
	while String(bilal.get("_salaman")) != "jabat" and tunggu_jabat < 4.0:
		await _tunggu(0.2)
		tunggu_jabat += 0.2
	_cek("f1: Bilal fase jabat", String(bilal.get("_salaman")) == "jabat")
	_cek("f1: Bilal tangan kanan terulur", float(bilal.get("_arm_r").rotation.x) < -1.0)
	_cek("f1: Bilal tangan kanan mengarah ke dalam (ke garis tengah)", float(bilal.get("_arm_r").rotation.z) > 0.2)
	# Lengan butuh ~0,5 dtk mencapai sudut dalam penuh.
	await _tunggu(0.6)
	var d_tangan := _jarak_tangan(bilal)
	print("SALAMAN-DBG f1 jarak tangan=%.3f" % d_tangan)
	var tp_dbg: Node3D = _main._player.find_child("TanganKanan", true, false) as Node3D
	var tn_dbg: Node3D = bilal.find_child("TanganKanan", true, false) as Node3D
	print("SALAMAN-DBG f1 bilal arm_r=(%.2f, %.2f) pemain arm_r=(%.2f, %.2f) tangan_pemain=%s tangan_bilal=%s badan_pemain=%s badan_bilal=%s" % [
		float(bilal.get("_arm_r").rotation.x), float(bilal.get("_arm_r").rotation.z),
		float(_main._player.get("_arm_r").rotation.x), float(_main._player.get("_arm_r").rotation.z),
		str(tp_dbg.global_position) if tp_dbg != null else "(null)",
		str(tn_dbg.global_position) if tn_dbg != null else "(null)",
		str(_main._player.global_position), str(bilal.global_position)])
	_cek("f1: tangan pemain & Bilal bertemu (< 0,15 m)", d_tangan < 0.15)
	_cek("f1: jarak badan saat jabat ~1,05 m", absf((bilal.global_position as Vector3).distance_to(_main._player.global_position as Vector3) - 1.05) < 0.2)
	var tunggu_selesai := 0.0
	while String(bilal.get("_salaman")) != "" and tunggu_selesai < 4.0:
		await _tunggu(0.2)
		tunggu_selesai += 0.2
	_cek("f1: Bilal selesai salaman", String(bilal.get("_salaman")) == "")
	_cek("f1: pemain tetap pose salaman (tahan sampai gerak)", String(_main._player.aksi_saat_ini()) == "salaman")

	# ---------- FASE 2: cooldown ----------
	print("SALAMAN: === FASE 2 cooldown ===")
	_cek("f2: terima_salaman ditolak saat cooldown NPC", not bool(bilal.terima_salaman(_main._player)))
	_cek("f2: cooldown pemain aktif sesudah salaman sukses", not bool(_main._salaman_siap()))

	# ---------- FASE 3: NPC sedang duduk ----------
	print("SALAMAN: === FASE 3 NPC duduk ===")
	var duduk_npc: Node = null
	for npc in _npc_sistem_baru():
		if String(npc.get("_aktivitas")) == "":
			duduk_npc = npc
			break
	_cek("f3: ada NPC sistem baru untuk uji duduk", duduk_npc != null)
	if duduk_npc != null:
		var kursi_pos: Vector3 = (duduk_npc.global_position as Vector3) + Vector3(1.5, 0, 0)
		duduk_npc.set("_aktivitas", "duduk")
		duduk_npc.set("_aktivitas_timer", 60.0)
		duduk_npc.set("_aktivitas_kursi", {"id": "tes-salaman", "pos": kursi_pos, "yaw": 1.0})
		duduk_npc.set("_aktivitas_yaw", 1.0)
		duduk_npc.set("_aktivitas_rute", [])
		duduk_npc.set("_aktivitas_rute_idx", 0)
		await _tunggu(0.5)
		_cek("f3: NPC pose duduk dulu (visual turun)", float(duduk_npc.get("_visual").position.y) < -0.3)
		_main._player.global_position = (duduk_npc.global_position as Vector3) + Vector3(0, 0, 1.5)
		await _tunggu(0.2)
		_cek("f3: terima_salaman dari duduk = true", bool(duduk_npc.terima_salaman(_main._player)))
		await _tunggu(1.2)
		_cek("f3: NPC berdiri saat jabat (visual naik)", float(duduk_npc.get("_visual").position.y) > -0.2)
		await _tunggu(0.6)
		_cek("f3: tangan bertemu saat jabat dari duduk", _jarak_tangan(duduk_npc) < 0.15)
		await _tunggu(2.5)
		_cek("f3: NPC selesai salaman", String(duduk_npc.get("_salaman")) == "")
		_cek("f3: aktivitas duduk dipulihkan", String(duduk_npc.get("_aktivitas")) == "duduk")
		_cek("f3: NPC kembali ke posisi kursi", (duduk_npc.global_position as Vector3).distance_to(kursi_pos) < 0.1)
		_cek("f3: yaw kursi dipulihkan", absf(float(duduk_npc.get("_visual").rotation.y) - 1.0) < 0.05)

	# ---------- FASE 4: tolak saat sholat ----------
	print("SALAMAN: === FASE 4 tolak sholat ===")
	var sholat_npc: Node = _npc_sistem_baru()[0]
	var rute_sholat: Array[Vector3] = [(sholat_npc.global_position as Vector3)]
	sholat_npc.mulai_rute(rute_sholat)
	_cek("f4: terima_salaman ditolak saat sholat", not bool(sholat_npc.terima_salaman(_main._player)))
	sholat_npc.selesai_sholat()

	# ---------- FASE 5: tolak saat duduk belajar ----------
	print("SALAMAN: === FASE 5 tolak duduk belajar ===")
	var belajar_npc: Node = _npc_sistem_baru()[1]
	belajar_npc.duduk_belajar(0.0)
	_cek("f5: terima_salaman ditolak saat duduk belajar", not bool(belajar_npc.terima_salaman(_main._player)))
	belajar_npc.berdiri_belajar()

	# ---------- FASE 6: solo tanpa target ----------
	print("SALAMAN: === FASE 6 solo ===")
	var spot_ok := false
	for spot in [Vector3(0, 0, 40), Vector3(0, 0, 44), Vector3(-40, 0, 40), Vector3(20, 0, 30)]:
		_main._player.global_position = spot
		await _tunggu(0.2)
		if _main._salaman_npc_terdekat() == null and _main._salaman_pemain_lain_terdekat() == null:
			spot_ok = true
			break
	_cek("f6: ada spot tanpa target salaman", spot_ok)
	if spot_ok:
		_main._on_aksi("salaman")
		_cek("f6: solo tetap pose salaman", String(_main._player.aksi_saat_ini()) == "salaman")
		_cek("f6: tidak ada NPC yang merespons", _tidak_ada_yang_salaman())

	# ---------- FASE 7: Sanusi + Fatimah ----------
	print("SALAMAN: === FASE 7 Sanusi + Fatimah ===")
	for guru in [_main._sanusi, _main._fatimah]:
		var nama_guru: String = String(guru.get("_nama"))
		# Lokasi guru diacak tiap run (LokasiAcak) dan BISA jatuh di
		# zona seberang yang tidak bisa dicapai pemain uji — Sanusi
		# di (64,-24) plot Masjid Besar (x>14, z<16: larangan putra)
		# bikin run 7 gagal BUKAN karena salaman rusak. Uji mekanisme
		# di titik deterministik yang bisa dicapai (temuan terpisah:
		# lokasi acak guru kadang tak terjangkau — laporkan ke Xam).
		if guru == _main._sanusi:
			guru.global_position = Vector3(0, 0, -14)
			guru.set("_target", Vector3(0, 0, -14))
			_main._save["jenis_kelamin"] = "putra"
		else:
			guru.global_position = Vector3(122, 0, 32)
			guru.set("_target", Vector3(122, 0, 32))
			_main._save["jenis_kelamin"] = "putri"
		# RONDE 21 (batas putra/putri KERAS, _cek_batas): pemain putra
		# TIDAK BISA mencapai Fatimah (area putri, x>14) — didorong
		# balik ke posisi legal terakhir. Uji Fatimah sebagai
		# santriwati (save jenis_kelamin — yang dibaca
		# _pemain_adalah_putri); putra menguji Sanusi, putri Fatimah.
		# Tunggu cooldown pemain (5 dtk) dari salaman sebelumnya habis
		# DULU — baru teleport + bersihkan area, supaya tidak ada NPC
		# yang sempat berjalan masuk radius 1,5 m selama menunggu
		# (flake run 3: NPC putri lewat dan merebut target Fatimah).
		var tunggu_cd := 0.0
		while not bool(_main._salaman_siap()) and tunggu_cd < 8.0:
			await _tunggu(0.5)
			tunggu_cd += 0.5
		_main._player.global_position = (guru.global_position as Vector3) + Vector3(1.5, 0, 0)
		_main._player.global_position.y = (guru.global_position as Vector3).y
		_bersihkan_sekitar(_main._player.global_position, [guru])
		await _tunggu(0.3)
		# Diagnostik (flake Fatimah run 2–4): posisi + target + kesiapan.
		var dbg_target: Node = _main._salaman_npc_terdekat()
		print("SALAMAN-DBG f7 %s: guru=%s pemain=%s jarak=%.2f target=%s siap=%s salaman='%s'" % [
			nama_guru, str(guru.global_position), str(_main._player.global_position),
			(guru.global_position as Vector3).distance_to(_main._player.global_position),
			String(dbg_target.get("_nama")) if dbg_target != null else "(null)",
			str(bool(_main._salaman_siap())), String(guru.get("_salaman"))])
		_main._on_aksi("salaman")
		_cek("f7: %s merespons salaman" % nama_guru, String(guru.get("_salaman")) != "")
		# Tunggu jabat + lengan mengarah, lalu cek tangan bertemu
		# (Fatimah = muslimah, bahu lebih lebar — sudut dalamnya
		# dihitung dari lengan_x, jadi harus tetap bertemu).
		var tunggu_j7 := 0.0
		while String(guru.get("_salaman")) != "jabat" and tunggu_j7 < 4.0:
			await _tunggu(0.2)
			tunggu_j7 += 0.2
		_cek("f7: %s fase jabat" % nama_guru, String(guru.get("_salaman")) == "jabat")
		await _tunggu(0.6)
		var d7 := _jarak_tangan(guru)
		print("SALAMAN-DBG f7 %s jarak tangan=%.3f" % [nama_guru, d7])
		_cek("f7: tangan bertemu dengan %s (< 0,15 m)" % nama_guru, d7 < 0.15)
		var tunggu_s7 := 0.0
		while String(guru.get("_salaman")) != "" and tunggu_s7 < 5.0:
			await _tunggu(0.2)
			tunggu_s7 += 0.2
		_cek("f7: %s selesai salaman" % nama_guru, String(guru.get("_salaman")) == "")
	_main._save["jenis_kelamin"] = "putra"

	# ---------- FASE 8: guard MP offline ----------
	print("SALAMAN: === FASE 8 guard offline ===")
	_cek("f8: tidak ada pemain lain saat offline", _main._salaman_pemain_lain_terdekat() == null)
	var aksi_sebelum: String = String(_main._player.aksi_saat_ini())
	_main._salaman_cek_undangan_peer()
	_cek("f8: watcher tanpa _players tidak crash + pose tidak berubah", String(_main._player.aksi_saat_ini()) == aksi_sebelum)

	print("SALAMAN-SELESAI lulus=%d gagal=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
