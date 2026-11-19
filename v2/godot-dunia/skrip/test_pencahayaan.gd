extends Node
## Tes pencahayaan v2 — headless:
##   godot --headless --path . skrip/test_pencahayaan.tscn
## Cek: modul terpasang, 21 lampu baru tanpa bayangan, modulasi siang/malam,
## perbaikan 2 lampu interior Musholla (diterangkan 20 Nov: dasar 1,3,
## malam 2,6, jangkauan 8 m), lampu pintu Surau ikut pintu runtime,
## 7 lampu pintu Fase 2 (20 Nov).

var _main: Node
var _modul: PencahayaanV2
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _hitung_omni(n: Node) -> int:
	var c := 0
	if n is OmniLight3D:
		c += 1
	for ch in n.get_children():
		c += _hitung_omni(ch)
	return c


func _semua_tanpa_bayangan(n: Node) -> bool:
	if n is OmniLight3D and (n as OmniLight3D).shadow_enabled:
		return false
	for ch in n.get_children():
		if not _semua_tanpa_bayangan(ch):
			return false
	return true


func _jangkauan_maks(n: Node) -> float:
	var m := 0.0
	if n is OmniLight3D:
		m = maxf(m, (n as OmniLight3D).omni_range)
	for ch in n.get_children():
		m = maxf(m, _jangkauan_maks(ch))
	return m


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Tes cahaya")
	for i in 3:
		await get_tree().process_frame
	# ISOLASI TINGKAT KUALITAS (Eka, gate 20261119-2): energi lampu
	# diukur pada pengali 1,0x (Sedang). Tanpa pin ini, save lokal
	# yang tersisa dari test_kualitas_adaptif (tingkat "ringan",
	# pengali 0,6x) membuat cek malam gagal tepat 0,6x — BUKAN bug
	# produk. atur_mode("sedang") juga mematikan probe/pantau.
	if _main._kualitas != null:
		_main._kualitas.atur_mode("sedang")
	var omni_sebelum := _hitung_omni(_main)
	print("OMNI SEBELUM: %d" % omni_sebelum)
	_modul = PencahayaanV2.pasang(_main, _main._outdoor_door)
	for i in 3:
		await get_tree().process_frame
	_cek("Modul terpasang", _modul != null and _main.find_child("PencahayaanV2", true, false) != null)
	_cek("21 lampu baru", _modul.jumlah_lampu_baru() == 21 and _hitung_omni(_modul) == 21)
	_cek("Omni total +21 (dapat %d)" % _hitung_omni(_main), _hitung_omni(_main) == omni_sebelum + 21)
	_cek("Semua lampu modul tanpa bayangan", _semua_tanpa_bayangan(_modul))
	_cek("Jangkauan maks <= 12 m (dapat %.1f)" % _jangkauan_maks(_modul), _jangkauan_maks(_modul) <= 12.01)
	# Lampu pintu Surau harus di pintu runtime (bukan hardcode lama).
	var lampu_pintu := _modul.find_child("LampuV2_PintuSurau", true, false) as OmniLight3D
	var target_pintu: Vector3 = _main._outdoor_door + Vector3(0, 3.0, 1.5)
	_cek("Lampu pintu Surau di pintu runtime", lampu_pintu != null and lampu_pintu.global_position.distance_to(target_pintu) < 0.5)
	# 4 lampu samping Surau: 2 per sisi, di tengah bentang (z=-9, -19),
	# 0,6 m di luar dinding (x=±8,6), y=3,0, hangat, jangkauan 10 m.
	var samping := {
		"LampuV2_SurauBarat_A": Vector3(-8.6, 3.0, -9),
		"LampuV2_SurauBarat_B": Vector3(-8.6, 3.0, -19),
		"LampuV2_SurauTimur_A": Vector3(8.6, 3.0, -9),
		"LampuV2_SurauTimur_B": Vector3(8.6, 3.0, -19),
	}
	var samping_ok := true
	for nama in samping:
		var l := _modul.find_child(nama, true, false) as OmniLight3D
		if l == null or l.global_position.distance_to(samping[nama]) > 0.5:
			samping_ok = false
		elif l.light_color != PencahayaanV2.WARNA_HANGAT or absf(l.omni_range - 10.0) > 0.01:
			samping_ok = false
	_cek("4 lampu samping Surau di posisi benar (hangat, 10 m)", samping_ok)
	# 7 lampu pintu Fase 2 (20 Nov, Mas ACC): di EXIT tiap gedung (1,5 m
	# di luar pintu), hangat, jangkauan 10 m. Satu cek per lampu.
	var pintu_f2 := {
		"LampuV2_PintuAsramaPutri": Vector3(144.5, 3.0, 9),
		"LampuV2_PintuAsramaPutra": Vector3(-34.5, 3.0, 10),
		"LampuV2_PintuKelasPutri": Vector3(130, 3.0, 15.5),
		"LampuV2_PintuKantorUstadzah": Vector3(142.5, 3.0, -33),
		"LampuV2_PintuMadrasah": Vector3(145.5, 3.0, -12),
		"LampuV2_PintuStudio": Vector3(166, 3.0, -17.5),
		"LampuV2_PintuPosJaga": Vector3(173, 3.0, -20),
	}
	for nama in pintu_f2:
		var l := _modul.find_child(nama, true, false) as OmniLight3D
		var ok := l != null and l.global_position.distance_to(pintu_f2[nama]) < 0.5
		ok = ok and l.light_color == PencahayaanV2.WARNA_HANGAT and absf(l.omni_range - 10.0) < 0.01 and not l.shadow_enabled
		_cek("Fase 2 %s di EXIT (hangat, 10 m, tanpa bayangan)" % nama, ok)
	# Perbaikan lampu interior Musholla.
	var om1 := _main.find_child("LampuOmni_1", true, false) as OmniLight3D
	var om2 := _main.find_child("LampuOmni_2", true, false) as OmniLight3D
	_cek("Musholla interior: 2 lampu ditemukan", om1 != null and om2 != null)
	var r_mus := -1.0
	if om1 != null and om2 != null:
		r_mus = minf(om1.omni_range, om2.omni_range)
	_cek("Musholla jangkauan 8 m (dapat %.1f)" % r_mus, absf(r_mus - 8.0) < 0.01)
	_cek("Musholla lampu di grup LampuCahaya", om1 != null and om1.is_in_group("LampuCahaya") and om2 != null and om2.is_in_group("LampuCahaya"))
	_cek("Musholla meta energi_siang 1.3", om1 != null and float(om1.get_meta("energi_siang")) == 1.3)
	var bola1 := _main.find_child("Lampu_1", true, false) as MeshInstance3D
	var emisi_ok := false
	if bola1 != null and bola1.material_override != null:
		var mat := bola1.material_override as StandardMaterial3D
		emisi_ok = mat != null and mat.emission_enabled
	_cek("Musholla bola beremisi", emisi_ok)
	# Faktor lampu (statis, tanpa frame).
	_cek("faktor_lampu siang 0", PencahayaanV2.faktor_lampu(12.0) == 0.0)
	_cek("faktor_lampu malam 1", PencahayaanV2.faktor_lampu(21.0) == 1.0)
	var f_senja := PencahayaanV2.faktor_lampu(17.75)
	_cek("faktor_lampu senja 0,4..1 (dapat %.2f)" % f_senja, f_senja > 0.4 and f_senja < 1.0)
	# Modulasi malam: energi harus 2x dasar.
	LangitDinamis.debug_jam = 21.0
	for i in 10:
		await get_tree().process_frame
	var e_malam := _modul.energi_lampu("LampuV2_PintuSurau")
	_cek("Modulasi malam: PintuSurau ~2,0 (dapat %.2f)" % e_malam, absf(e_malam - 2.0) < 0.05)
	var e_samping_malam := _modul.energi_lampu("LampuV2_SurauBarat_A")
	_cek("Modulasi malam: SampingSurau ~1,8 (dapat %.2f)" % e_samping_malam, absf(e_samping_malam - 1.8) < 0.05)
	var e_mus_malam := -1.0
	if om1 != null:
		e_mus_malam = om1.light_energy
	_cek("Modulasi malam: Musholla ~2,6 (dapat %.2f)" % e_mus_malam, absf(e_mus_malam - 2.6) < 0.05)
	# Modulasi siang: lampu MATI (energi ~0) — perubahan disengaja
	# Rangga 19 Nov 2026 (lampu omni mati siang, malam 2x).
	LangitDinamis.debug_jam = 12.0
	for i in 10:
		await get_tree().process_frame
	var e_siang := _modul.energi_lampu("LampuV2_PintuSurau")
	_cek("Modulasi siang: PintuSurau ~0,0 (dapat %.2f)" % e_siang, absf(e_siang - 0.0) < 0.05)
	# Jalan maju masih jalan (regresi gerak).
	var awal: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 30:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var jalan: float = _main._player.global_position.distance_to(awal)
	_cek("Jalan maju > 1 m (dapat %.2f m)" % jalan, jalan > 1.0)
	LangitDinamis.debug_jam = -1.0
	print("TES PENCAHAYAAN: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
