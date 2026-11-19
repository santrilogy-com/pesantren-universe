extends Node
## Tes integrasi pencahayaan v2 — headless:
##   godot --headless --path . skrip/test_integrasi_pencahayaan.tscn
## BEDA dengan test_pencahayaan.gd: skrip ini TIDAK memanggil
## PencahayaanV2.pasang() sendiri — ia membuktikan main.gd sudah
## memasang modul di _ready() (satu baris, LIGHTING-PLAN.md §7).
## Cek: tepat 1 modul terpasang, 11 lampu baru, modulasi siang/malam,
## perbaikan 2 lampu interior Musholla, lampu pintu di pintu runtime.

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


func _hitung_modul(n: Node) -> int:
	var c := 0
	if n is PencahayaanV2:
		c += 1
	for ch in n.get_children():
		c += _hitung_modul(ch)
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
	_main._masuk_pesantren("Tes integrasi cahaya")
	for i in 3:
		await get_tree().process_frame
	# TANPA pasang() manual — modul harus sudah ada dari main.gd _ready().
	_modul = _main.find_child("PencahayaanV2", true, false) as PencahayaanV2
	_cek("Modul terpasang oleh main.gd", _modul != null)
	_cek("Tepat 1 modul (tidak ganda)", _hitung_modul(_main) == 1)
	_cek("22 lampu baru", _modul != null and _modul.jumlah_lampu_baru() == 22 and _hitung_omni(_modul) == 22)
	_cek("Omni total 86 (64 dasar + 22 modul, dapat %d)" % _hitung_omni(_main), _hitung_omni(_main) == 86)
	_cek("Semua lampu modul tanpa bayangan", _modul != null and _semua_tanpa_bayangan(_modul))
	_cek("Jangkauan maks <= 12 m (dapat %.1f)" % _jangkauan_maks(_modul), _modul != null and _jangkauan_maks(_modul) <= 12.01)
	# Pintu Surau lurus -90°: _outdoor_door harus (0,0,-3.8).
	_cek("Pintu runtime (0,0,-3.8) (dapat %s)" % str(_main._outdoor_door), _main._outdoor_door.distance_to(Vector3(0, 0, -3.8)) < 0.1)
	var lampu_pintu := _modul.find_child("LampuV2_PintuSurau", true, false) as OmniLight3D
	var target_pintu: Vector3 = _main._outdoor_door + Vector3(0, 3.0, 1.5)
	_cek("Lampu pintu Surau di pintu runtime", lampu_pintu != null and lampu_pintu.global_position.distance_to(target_pintu) < 0.5)
	# 4 lampu samping Surau (23:45): 2 per sisi, z=-9/-19, x=±8,6, y=3,0.
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
	_cek("4 lampu samping Surau di posisi benar", samping_ok)
	# Perbaikan lampu interior Musholla.
	var om1 := _main.find_child("LampuOmni_1", true, false) as OmniLight3D
	var om2 := _main.find_child("LampuOmni_2", true, false) as OmniLight3D
	_cek("Musholla interior: 2 lampu ditemukan", om1 != null and om2 != null)
	_cek("Musholla lampu di grup LampuCahaya", om1 != null and om1.is_in_group("LampuCahaya") and om2 != null and om2.is_in_group("LampuCahaya"))
	_cek("Musholla meta energi_siang 1.3", om1 != null and float(om1.get_meta("energi_siang")) == 1.3)
	var bola1 := _main.find_child("Lampu_1", true, false) as MeshInstance3D
	var emisi_ok := false
	if bola1 != null and bola1.material_override != null:
		var mat := bola1.material_override as StandardMaterial3D
		emisi_ok = mat != null and mat.emission_enabled
	_cek("Musholla bola beremisi", emisi_ok)
	# Modulasi malam: energi harus 2x dasar.
	LangitDinamis.debug_jam = 21.0
	for i in 10:
		await get_tree().process_frame
	var e_malam := _modul.energi_lampu("LampuV2_PintuSurau")
	_cek("Modulasi malam: PintuSurau ~2,0 (dapat %.2f)" % e_malam, absf(e_malam - 2.0) < 0.05)
	var e_samping_malam := _modul.energi_lampu("LampuV2_SurauTimur_B")
	_cek("Modulasi malam: SampingSurau ~1,8 (dapat %.2f)" % e_samping_malam, absf(e_samping_malam - 1.8) < 0.05)
	var e_mus_malam := -1.0
	if om1 != null:
		e_mus_malam = om1.light_energy
	_cek("Modulasi malam: Musholla ~2,6 (dapat %.2f)" % e_mus_malam, absf(e_mus_malam - 2.6) < 0.05)
	# Modulasi siang: lampu MATI (energi ~0) — perubahan disengaja Rangga
	# 19 Nov 2026 (dulu dasar 1,0; ekspektasi lama "~1,0" sudah usang,
	# diperbaiki 20 Nov). Sama seperti test_pencahayaan.
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
	print("TES INTEGRASI PENCAHAYAAN: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
