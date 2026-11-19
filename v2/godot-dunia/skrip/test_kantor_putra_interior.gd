extends Node
## TES INTERIOR KANTOR PUTRA + PENATAAN ULANG KANTOR USTADZAH
## (Gilang, 20 Nov 2026 — konsep tes-di-dalam-kantor Laras, ACC Mas
## 00:37 WIB). Membuktikan tanpa memuat dunia (build statis +
## konstanta saja):
##   1. Slot x=-90: bounds Kantor Putra (x -93..-87, z -302.5..-297.5)
##      TIDAK menumpuk interior lain di garis z=-300 (cek tumpang
##      tindih vs semua bounds interior yang ada).
##   2. Build Kantor Putra: semua kunci dict ada, node bernama
##      benar, perabot di posisi konsep (meja, 2 kursi, lemari,
##      rak, papan, lampu, 2 jendela, dinding pintu utara + plafon).
##   3. Geometri aman: lemari/rak/papan/meja/kursi di dalam muka
##      dalam dinding (tidak menembus dinding).
##   4. Penataan ulang Kantor Ustadzah: meja di tengah (-120,-300),
##      kursi penguji timur (-118.85) + kursi pemain BARU barat
##      (-121.15); node KursiKerja lama hilang.
##   5. Registrasi kursi tes: 4 entri KURSI_TES (tes=true);
##      kursi_bebas() TIDAK PERNAH mengembalikannya (putra maupun
##      putri, dalam maupun luar); _kursi_dari_id() menemukannya dan
##      posisinya sama dengan perabot interior.
##   6. Pencahayaan: lampu hangat + 2 jendela punya OmniLight
##      (energi > 0, grup LampuCahaya/CahayaJendela) + kaca emissive
##      terang (grup KacaJendela).
## Jalankan headless (tanpa Xvfb, tanpa dunia):
##   HOME=/tmp/iso-kantor-putra-interior godot --headless --path . --scene res://skrip/test_kantor_putra_interior.tscn

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("KANTOR-PUTRA-INTERIOR LULUS %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("KANTOR-PUTRA-INTERIOR GAGAL %s %s" % [nama, detail])


func _tumpang_tindih(a: Dictionary, b: Dictionary) -> bool:
	return float(a["min_x"]) <= float(b["max_x"]) and float(b["min_x"]) <= float(a["max_x"]) and float(a["min_z"]) <= float(b["max_z"]) and float(b["min_z"]) <= float(a["max_z"])


func _pos_dalam_muka_dalam(p: Vector3, min_x: float, max_x: float, min_z: float, max_z: float) -> bool:
	return p.x >= min_x and p.x <= max_x and p.z >= min_z and p.z <= max_z


func _ready() -> void:
	var kp: Dictionary = InteriorGedungPutri.build_kantor_putra()
	var root: Node = kp["root"]
	add_child(root)
	# --- 1) Slot x=-90 tidak menumpuk interior lain ---
	var bounds: Dictionary = InteriorGedungPutri.KANTOR_PUTRA_BOUNDS
	_cek("bounds putra 6x5", bounds["min_x"] == -93.0 and bounds["max_x"] == -87.0 and bounds["min_z"] == -302.5 and bounds["max_z"] == -297.5, str(bounds))
	var tetangga: Array = [
		["kantor_ustadzah", InteriorGedungPutri.KANTOR_BOUNDS],
		["madrasah", InteriorGedungPutri.MADRASAH_BOUNDS],
		["studio", InteriorGedungPutri.STUDIO_BOUNDS],
		["pos_jaga", InteriorGedungPutri.POS_BOUNDS],
		["cangkruk", InteriorCangkruk.CANGKRUK_BOUNDS],
		["surau", InteriorSurau.SURAU_BOUNDS],
		["kelas_putri", InteriorKelasPutri.KELAS_BOUNDS],
		["asrama_putri", InteriorAsramaPutri.ASRAMA_BOUNDS],
		["asrama_putra", InteriorAsramaPutra.ASRAMA_BOUNDS],
		# Musholla: tanpa const BOUNDS (interior_musholla.gd) — interval
		# dari header interior_gedung_putri.gd (x 53..67).
		["musholla", {"min_x": 53.0, "max_x": 67.0, "min_z": -305.0, "max_z": -295.0}],
	]
	for t in tetangga:
		_cek("slot bebas vs " + String(t[0]), not _tumpang_tindih(bounds, t[1]), "")
	# Jarak ke tetangga terdekat (x): barat Kantor Ustadzah 23 m,
	# timur Cangkruk 20 m — sesuai konsep (20 m+).
	_cek("celah barat >= 20 m", float(bounds["min_x"]) - float(InteriorGedungPutri.KANTOR_BOUNDS["max_x"]) >= 20.0, "")
	_cek("celah timur >= 20 m", float(InteriorCangkruk.CANGKRUK_BOUNDS["min_x"]) - float(bounds["max_x"]) >= 20.0, "")
	# --- 2) Kunci dict + nama node ---
	for kunci in ["root", "interior_door", "interior_spawn", "bounds", "meja_pos", "kursi_pemain_pos", "kursi_penguji_pos", "lemari_pos", "rak_pos", "papan_pos"]:
		_cek("kunci dict " + kunci, kp.has(kunci), "")
	_cek("nama root InteriorKantorPutra", String(root.name) == "InteriorKantorPutra", String(root.name))
	_cek("pintu dalam (-90,-302.5)", (kp["interior_door"] as Vector3).is_equal_approx(Vector3(-90, 0, -302.5)), str(kp["interior_door"]))
	_cek("spawn dalam (-90,-301.9)", (kp["interior_spawn"] as Vector3).is_equal_approx(Vector3(-90, 0, -301.9)), str(kp["interior_spawn"]))
	# --- 2b) Perabot ada di posisi konsep ---
	var harap := {
		"MejaKerja": Vector3(-90, 0, -299.8),
		"KursiPemain": Vector3(-90, 0, -300.65),
		"KursiPenguji": Vector3(-90, 0, -298.95),
		"LemariArsip": Vector3(-92.15, 0, -298.05),
		"RakBuku": Vector3(-87.35, 0, -300.1),
		"PapanPengumuman": Vector3(-90, 1.6, -297.68),
		"LampuKantorPutra": Vector3(-88.5, 0, -301.0),
		"JendelaTimur": Vector3(-87.125, 1.7, -300.0),
		"JendelaBarat": Vector3(-92.875, 1.7, -300.0),
	}
	for nama in harap.keys():
		var node: Node = root.find_child(String(nama), true, false)
		var ok := node != null and (node as Node3D).global_position.is_equal_approx(harap[nama])
		_cek("perabot putra " + String(nama), ok, "" if node == null else str((node as Node3D).global_position))
	# Dinding pintu utara: dua segmen + ambang + plafon + lantai.
	for nama in ["DindingSelatan", "DindingBarat", "DindingTimur", "DindingUtara_Barat", "DindingUtara_Timur", "AmbangPintu", "Plafon", "Lantai", "LabelKeluar"]:
		_cek("struktur putra " + nama, root.find_child(nama, true, false) != null, "")
	# Arah hadap kursi: pemain menghadap selatan (rot 0), penguji
	# menghadap utara (rot PI) — berhadapan di seberang meja.
	var kp_pemain := root.find_child("KursiPemain", true, false) as Node3D
	var kp_penguji := root.find_child("KursiPenguji", true, false) as Node3D
	_cek("kursi pemain hadap selatan", kp_pemain != null and absf(kp_pemain.rotation.y) < 0.01, "")
	_cek("kursi penguji hadap utara", kp_penguji != null and absf(absf(kp_penguji.rotation.y) - PI) < 0.01, "")
	# --- 3) Geometri aman (di dalam muka dalam dinding) ---
	# Muka dalam: x -92.875..-87.125, z -302.375..-297.625.
	var min_x := -92.875
	var max_x := -87.125
	var min_z := -302.375
	var max_z := -297.625
	_cek("lemari tidak tembus dinding", _pos_dalam_muka_dalam(Vector3(-92.15, 0, -298.05), min_x + 0.7, max_x - 0.7, min_z + 0.25, max_z - 0.25), "")
	_cek("rak tidak tembus dinding", _pos_dalam_muka_dalam(Vector3(-87.35, 0, -300.1), min_x + 0.175, max_x - 0.175, min_z + 0.8, max_z - 0.8), "")
	_cek("meja di dalam ruangan", _pos_dalam_muka_dalam(Vector3(-90, 0, -299.8), min_x + 0.8, max_x - 0.8, min_z + 0.4, max_z - 0.4), "")
	_cek("kursi pemain di dalam ruangan", _pos_dalam_muka_dalam(Vector3(-90, 0, -300.65), min_x + 0.225, max_x - 0.225, min_z + 0.225, max_z - 0.225), "")
	_cek("kursi penguji di dalam ruangan", _pos_dalam_muka_dalam(Vector3(-90, 0, -298.95), min_x + 0.225, max_x - 0.225, min_z + 0.225, max_z - 0.225), "")
	# --- 4) Penataan ulang Kantor Ustadzah ---
	var ku: Dictionary = InteriorGedungPutri.build_kantor()
	var root_u: Node = ku["root"]
	add_child(root_u)
	_cek("meja ustadzah di tengah (-120,-300)", (ku["meja_pos"] as Vector3).is_equal_approx(Vector3(-120, 0, -300)), str(ku["meja_pos"]))
	_cek("kursi penguji ustadzah (-118.85)", (ku["kursi_penguji_pos"] as Vector3).is_equal_approx(Vector3(-118.85, 0, -300)), str(ku["kursi_penguji_pos"]))
	_cek("kursi pemain ustadzah (-121.15)", (ku["kursi_pemain_pos"] as Vector3).is_equal_approx(Vector3(-121.15, 0, -300)), str(ku["kursi_pemain_pos"]))
	_cek("node KursiPenguji ada", root_u.find_child("KursiPenguji", true, false) != null, "")
	_cek("node KursiPemain ada", root_u.find_child("KursiPemain", true, false) != null, "")
	_cek("node KursiKerja lama hilang", root_u.find_child("KursiKerja", true, false) == null, "")
	var ku_pemain := root_u.find_child("KursiPemain", true, false) as Node3D
	var ku_penguji := root_u.find_child("KursiPenguji", true, false) as Node3D
	_cek("kursi pemain ustadzah hadap timur", ku_pemain != null and absf(ku_pemain.rotation.y - PI / 2.0) < 0.01, "")
	_cek("kursi penguji ustadzah hadap barat", ku_penguji != null and absf(ku_penguji.rotation.y + PI / 2.0) < 0.01, "")
	# --- 5) Registrasi kursi tes (dicadangkan) ---
	var tes: Array = SantriNPC.KURSI_TES
	_cek("KURSI_TES 4 entri", tes.size() == 4, "(dapat %d)" % tes.size())
	var ids := {}
	for k in tes:
		ids[String(k["id"])] = true
		_cek("tes flag " + String(k["id"]), bool(k.get("tes", false)), "")
	for id in ["tes_kantor_putra_pemain", "tes_kantor_putra_penguji", "tes_kantor_ustadzah_pemain", "tes_kantor_ustadzah_penguji"]:
		_cek("KURSI_TES punya " + id, ids.has(id), "")
	# kursi_bebas() tidak pernah mengembalikan kursi tes.
	for putri in [false, true]:
		for dalam in [false, true]:
			var bebas: Array = SantriNPC.kursi_bebas(putri, dalam, "kursi")
			var bocor := false
			for k in bebas:
				if String(k["id"]).begins_with("tes_kantor_"):
					bocor = true
			_cek("kursi_bebas tanpa tes (putri=%s dalam=%s)" % [str(putri), str(dalam)], not bocor, "")
	# _kursi_dari_id menemukan kursi tes + posisi = perabot interior.
	var d1: Dictionary = SantriNPC._kursi_dari_id("tes_kantor_putra_pemain")
	_cek("dari_id pemain putra", not d1.is_empty() and (d1["pos"] as Vector3).is_equal_approx(Vector3(-90, 0.45, -300.65)), str(d1.get("pos", "")))
	var d2: Dictionary = SantriNPC._kursi_dari_id("tes_kantor_ustadzah_penguji")
	_cek("dari_id penguji ustadzah", not d2.is_empty() and (d2["pos"] as Vector3).is_equal_approx(Vector3(-118.85, 0.45, -300)), str(d2.get("pos", "")))
	# --- 6) Pencahayaan ---
	var lampu: Node = root.find_child("LampuKantorPutra", true, false)
	var cahaya: OmniLight3D = null
	if lampu != null:
		cahaya = lampu.find_child("Cahaya", true, false) as OmniLight3D
	_cek("lampu putra omni energi > 0", cahaya != null and cahaya.light_energy > 0.0, "")
	_cek("lampu putra grup LampuCahaya", cahaya != null and cahaya.is_in_group("LampuCahaya"), "")
	for jnama in ["JendelaTimur", "JendelaBarat"]:
		var j: Node = root.find_child(jnama, true, false)
		var cj: OmniLight3D = null
		var kaca: MeshInstance3D = null
		if j != null:
			cj = j.find_child("CahayaJendela", true, false) as OmniLight3D
			kaca = j.find_child("Kaca", true, false) as MeshInstance3D
		_cek(jnama + " cahaya energi > 0", cj != null and cj.light_energy > 0.0, "")
		var kaca_terang := false
		if kaca != null and kaca.material_override != null:
			var m := kaca.material_override as StandardMaterial3D
			kaca_terang = m.emission_enabled and m.emission_energy_multiplier > 0.0
		_cek(jnama + " kaca terang emissive", kaca_terang, "")
		_cek(jnama + " kaca grup KacaJendela", kaca != null and kaca.is_in_group("KacaJendela"), "")
	print("KANTOR-PUTRA-INTERIOR SELESAI lulus=%d gagal=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
