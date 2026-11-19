extends Node
## Tes NPC-TANGGA (Eka, 18 Nov 2026 — temuan Rangga: NPC sholat
## tembus anak tangga Surau karena _langkah_ke memaksa y=0) — headless:
##   godot --headless --path . skrip/test_npc_tangga.tscn
## NPC menempuh rute sholat ke pintu Surau (-2,2) -> (0,-2,3) NAIK
## anak tangga, lalu pulang TURUN; tiap frame dicek y == pijakan
## (tidak tenggelam, tidak melayang). Tanpa dunia penuh — _langkah_ke
## + _tinggi_tanah murni matematika posisi (TanggaSurau.pijakan).

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
	# --- 1. Unit: _tinggi_tanah di titik-titik kunci ---
	_cek("T3 (0, 0,7) = 0,166 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, 0.7)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, 0.7)) - 0.166) < 0.001)
	_cek("T2 (0, 0,1) = 0,333 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, 0.1)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, 0.1)) - 0.333) < 0.001)
	_cek("T1 (0, -0,5) = 0,5 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, -0.5)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, -0.5)) - 0.5) < 0.001)
	_cek("Serambi (0, -2,3) = 0,5 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, -2.3)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, -2.3)) - 0.5) < 0.001)
	_cek("Plaza (0, 2,0) = 0 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, 2.0)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, 2.0))) < 0.001)
	_cek("Utara serambi (0, -5,0) = 0 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(0, 0, -5.0)), absf(SantriNPC._tinggi_tanah(Vector3(0, 0, -5.0))) < 0.001)
	_cek("Luar lebar serambi (3,5, -2,3) = 0 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(3.5, 0, -2.3)), absf(SantriNPC._tinggi_tanah(Vector3(3.5, 0, -2.3))) < 0.001)
	_cek("Dalam lebar T3 (3,5, 0,7) = 0,166 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(3.5, 0, 0.7)), absf(SantriNPC._tinggi_tanah(Vector3(3.5, 0, 0.7)) - 0.166) < 0.001)
	_cek("Luar lebar T2 (3,5, 0,1) = 0 (dapat %.3f)" % SantriNPC._tinggi_tanah(Vector3(3.5, 0, 0.1)), absf(SantriNPC._tinggi_tanah(Vector3(3.5, 0, 0.1))) < 0.001)

	# --- 2. Rute NAIK: (-2,2) -> (0,-2,3), ekor rute sholat Surau ---
	var npc := SantriNPC.new()
	add_child(npc)
	npc.setup("TesTangga", Vector3(-2, 0, 2), [Vector3(-2, 0, 2)], MissionData.OUTFIT_DEFAULT)
	for i in 3:
		await get_tree().process_frame
	var rute_naik: Array[Vector3] = [Vector3(-2, 0, 2), Vector3(0, 0, -2.3)]
	npc.mulai_rute(rute_naik)
	var selisih_maks := 0.0
	var y_maks := 0.0
	var lewat_0166 := false
	var lewat_0333 := false
	var selesai := false
	for i in 900:
		await get_tree().process_frame
		var harap := SantriNPC._tinggi_tanah(npc.position)
		selisih_maks = maxf(selisih_maks, absf(npc.position.y - harap))
		y_maks = maxf(y_maks, npc.position.y)
		if absf(npc.position.y - 0.166) < 0.001:
			lewat_0166 = true
		if absf(npc.position.y - 0.333) < 0.001:
			lewat_0333 = true
		if npc._menunggu:
			selesai = true
			break
	_cek("Rute naik selesai sampai pintu (menunggu=%s, pos=%s)" % [str(selesai), str(npc.position)], selesai)
	_cek("Rute naik: y selalu == pijakan (selisih maks %.4f)" % selisih_maks, selisih_maks < 0.001)
	_cek("Rute naik: melewati T3 0,166", lewat_0166)
	_cek("Rute naik: melewati T2 0,333", lewat_0333)
	_cek("Rute naik: sampai serambi y=0,5 (dapat %.3f)" % npc.position.y, absf(npc.position.y - 0.5) < 0.001)
	_cek("Rute naik: dekat pintu (jarak %.2f)" % npc.position.distance_to(Vector3(0, 0.5, -2.3)), npc.position.distance_to(Vector3(0, 0.5, -2.3)) < 0.45)

	# --- 3. Rute TURUN: (0,-2,3) -> (-2,2), y harus turun lagi ke 0 ---
	var rute_turun: Array[Vector3] = [Vector3(0, 0.5, -2.3), Vector3(-2, 0, 2)]
	npc.mulai_rute(rute_turun)
	selisih_maks = 0.0
	selesai = false
	for i in 900:
		await get_tree().process_frame
		var harap2 := SantriNPC._tinggi_tanah(npc.position)
		selisih_maks = maxf(selisih_maks, absf(npc.position.y - harap2))
		if npc._menunggu:
			selesai = true
			break
	_cek("Rute turun selesai (menunggu=%s, pos=%s)" % [str(selesai), str(npc.position)], selesai)
	_cek("Rute turun: y selalu == pijakan (selisih maks %.4f)" % selisih_maks, selisih_maks < 0.001)
	_cek("Rute turun: kembali ke tanah y=0 (dapat %.3f)" % npc.position.y, absf(npc.position.y) < 0.001)

	# --- 4. Di luar tangga, _langkah_ke tidak mengubah y ---
	var npc2 := SantriNPC.new()
	add_child(npc2)
	npc2.setup("TesDatar", Vector3(10, 0, 30), [Vector3(10, 0, 30)], MissionData.OUTFIT_DEFAULT)
	for i in 3:
		await get_tree().process_frame
	var rute_datar: Array[Vector3] = [Vector3(10, 0, 30), Vector3(-10, 0, 30)]
	npc2.mulai_rute(rute_datar)
	var y_datar_maks := 0.0
	selesai = false
	for i in 1200:
		await get_tree().process_frame
		y_datar_maks = maxf(y_datar_maks, absf(npc2.position.y))
		if npc2._menunggu:
			selesai = true
			break
	_cek("Rute datar selesai (menunggu=%s)" % str(selesai), selesai)
	_cek("Rute datar: y tetap 0 (|y| maks %.4f)" % y_datar_maks, y_datar_maks < 0.001)

	print("TES NPC-TANGGA: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
