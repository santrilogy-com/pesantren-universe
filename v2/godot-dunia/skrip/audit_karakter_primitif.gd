extends Node
## Audit anti-tembus karakter primitif v2 (Kirana, 17 Nov 2026) — headless:
##   godot --headless --path . skrip/audit_karakter_primitif.tscn
## Cek geometri 7 karakter (putra/putri/Bilal/Faris/Kyai/Ustadzah/
## Satpam): penutup kepala menempel (tidak melayang), tangan + bahu
## menyambung (tidak putus), kacamata di depan wajah, sarung menutupi
## kaki, sandal menyentuh tanah, tinggi wajar, semua transform finite.
## BUKAN tes gerak/pose — itu ranah agen lain. Keluar 0 bila lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## AABB gabungan sebuah node + semua turunannya, di ruang dunia,
## dihitung dari mesh (bukan rendering server — jalan di headless).
func _aabb_dunia(n: Node) -> AABB:
	var a := AABB()
	var ada := false
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh != null:
			a = mi.global_transform * mi.mesh.get_aabb()
			ada = true
	for c in n.get_children():
		var sub := _aabb_dunia(c)
		if sub.size.x > 0.0 and sub.size.y > 0.0 and sub.size.z > 0.0:
			if ada:
				a = a.merge(sub)
			else:
				a = sub
				ada = true
	return a


func _bagian(root: Node, nama: String) -> Node:
	return root.find_child(nama, true, false)


func _aabb_bagian(root: Node, nama: String) -> AABB:
	var n := _bagian(root, nama)
	if n == null:
		return AABB()
	return _aabb_dunia(n)


## AABB gabungan beberapa node (mis. drape dada 3 bagian ronde 5).
func _aabb_gabungan(root: Node, nama_list: Array) -> AABB:
	var a := AABB()
	var ada := false
	for nama in nama_list:
		var sub := _aabb_bagian(root, String(nama))
		if sub.size.x > 0.0 and sub.size.y > 0.0 and sub.size.z > 0.0:
			if ada:
				a = a.merge(sub)
			else:
				a = sub
				ada = true
	return a


func _semua_finite(n: Node) -> bool:
	if n is Node3D:
		var t := (n as Node3D).global_transform
		if not t.origin.is_finite():
			return false
		for i in range(3):
			if not t.basis[i].is_finite():
				return false
	for c in n.get_children():
		if not _semua_finite(c):
			return false
	return true


func _karakter() -> Array:
	var putri := MissionData.OUTFIT_USTADZAH.duplicate()
	putri["abaya"] = "#007a61"
	putri["hijab_warna"] = "#f5e4cc"
	putri["kacamata"] = true
	putri["kulit"] = "#ffc09f"
	var putra := MissionData.OUTFIT_DEFAULT.duplicate()
	putra["kacamata"] = true
	var bilal := MissionData.OUTFIT_DEFAULT.duplicate()
	bilal["sarung"] = "#1d4e6b"
	bilal["kulit"] = "#8a5a33"
	bilal["kacamata"] = true
	bilal["songkok"] = "#1a1a1a"
	var faris := MissionData.OUTFIT_DEFAULT.duplicate()
	faris["sarung"] = "#6b3a1d"
	faris["kulit"] = "#e8b98a"
	faris["kacamata"] = false
	faris["songkok"] = "#faf7f0"
	return [
		["putra", "Santri Putra", putra, "peci"],
		["putri", "Santriwati", putri, "hijab"],
		["bilal", "Bilal", bilal, "peci"],
		["faris", "Faris", faris, "peci"],
		["kyai", "Ust. Aqsal Murad", MissionData.OUTFIT_KYAI, "serban"],
		["ustadzah", "Ustadzah Mariyah", MissionData.OUTFIT_USTADZAH, "hijab"],
		["satpam", "Satpam", MissionData.OUTFIT_SATPAM, "peci"],
	]


func _ready() -> void:
	var daftar: Array = _karakter()
	for item in daftar:
		var slug: String = item[0]
		var nama: String = item[1]
		var outfit: Dictionary = item[2]
		var tutup: String = item[3]
		var built: Dictionary = SantriPlayer.build_visual(nama, outfit)
		var root: Node3D = built["root"]
		add_child(root)
		for i in 3:
			await get_tree().process_frame
		_cek("%s: transform semua finite" % slug, _semua_finite(root))
		var a_kepala := _aabb_bagian(root, "Kepala")
		_cek("%s: kepala ada" % slug, a_kepala.size.x > 0.1)
		# Penutup kepala MENEMPEL: AABB-nya beririsan dengan kepala
		# (bukan melayang di atas) dan puncaknya di atas ubun.
		var a_tutup := AABB()
		if tutup == "peci":
			a_tutup = _aabb_bagian(root, "Peci")
		elif tutup == "serban":
			a_tutup = _aabb_bagian(root, "Serban")
		else:
			a_tutup = _aabb_bagian(root, "HijabKerudung")
		_cek("%s: penutup kepala menempel (irisan dgn kepala)" % slug, a_tutup.intersects(a_kepala))
		_cek("%s: penutup kepala di atas ubun (puncak %.2f > %.2f)" % [slug, a_tutup.end.y, a_kepala.end.y], a_tutup.end.y > a_kepala.end.y - 0.05)
		# Bahu + tangan menyambung (tidak putus / tidak melayang).
		# Bahu menyambung: santriwan/Kyai/Satpam ke torso; muslimah ke
		# ABAYA (lengan keluar dari gamis, torso tersembunyi di dalam).
		var badan := "Abaya" if bool(outfit.get("muslimah", false)) else "Torso"
		_cek("%s: bahu kiri menyatu %s" % [slug, badan.to_lower()], _aabb_bagian(root, "BahuKiri").intersects(_aabb_bagian(root, badan)))
		_cek("%s: bahu kanan menyatu %s" % [slug, badan.to_lower()], _aabb_bagian(root, "BahuKanan").intersects(_aabb_bagian(root, badan)))
		_cek("%s: tangan kiri menyatu lengan bawah" % slug, _aabb_bagian(root, "TanganKiri").intersects(_aabb_bagian(root, "LenganBawahKiri")))
		_cek("%s: tangan kanan menyatu lengan bawah" % slug, _aabb_bagian(root, "TanganKanan").intersects(_aabb_bagian(root, "LenganBawahKanan")))
		# Tangan TIDAK menembus torso: pusat tangan di luar radius torso.
		var a_tl := _aabb_bagian(root, "TanganKiri")
		var a_tr := _aabb_bagian(root, "TanganKanan")
		_cek("%s: tangan kiri di luar badan (|x| %.2f)" % [slug, absf(a_tl.get_center().x)], absf(a_tl.get_center().x) > 0.20)
		_cek("%s: tangan kanan di luar badan (|x| %.2f)" % [slug, absf(a_tr.get_center().x)], absf(a_tr.get_center().x) > 0.20)
		# Sarung/abaya menutupi kaki sampai mata kaki.
		var a_sarung := _aabb_bagian(root, "Sarung")
		if a_sarung.size.x <= 0.0:
			a_sarung = _aabb_bagian(root, "Abaya")
		_cek("%s: sarung/abaya bawah di mata kaki (%.2f)" % [slug, a_sarung.position.y], a_sarung.position.y <= 0.15)
		_cek("%s: sarung/abaya atas menutupi pinggang (%.2f)" % [slug, a_sarung.end.y], a_sarung.end.y >= 0.85)
		# Sandal menyentuh tanah (tidak melayang / tidak tenggelam).
		var a_sandal := _aabb_bagian(root, "SandalKiri")
		_cek("%s: sandal kiri menyentuh tanah (bawah %.3f)" % [slug, a_sandal.position.y], a_sandal.position.y >= -0.01 and a_sandal.position.y <= 0.03)
		# Tinggi total wajar (puncak penutup kepala).
		var a_semua := _aabb_dunia(root)
		_cek("%s: tinggi total wajar (%.2f m)" % [slug, a_semua.end.y], a_semua.end.y >= 1.85 and a_semua.end.y <= 2.10)
		# Kacamata (bila dipakai): bidang depan lensa/bingkai di depan
		# wajah (z > 0.23, tidak menembus kepala); gagang memang
		# menjulur ke belakang (z min ~0.13) menuju telinga.
		if bool(outfit.get("kacamata", false)):
			var a_kc := _aabb_bagian(root, "Kacamata")
			_cek("%s: kacamata di depan wajah (depan z %.2f)" % [slug, a_kc.end.z], a_kc.end.z > 0.23 and a_kc.end.z < 0.32 and a_kc.position.z > 0.05)
		# Detail khas per peran.
		if slug == "kyai":
			_cek("kyai: jenggot ada", _bagian(root, "Jenggot") != null)
			_cek("kyai: kumis ada", _bagian(root, "Kumis") != null)
			_cek("kyai: jenggot di bawah dagu (bawah %.2f)" % _aabb_bagian(root, "Jenggot").position.y, _aabb_bagian(root, "Jenggot").position.y < 1.45)
		if slug == "satpam":
			var lencana := _bagian(root, "Lencana")
			_cek("satpam: lencana ada", lencana != null)
			if lencana != null:
				var a_l := _aabb_dunia(lencana)
				_cek("satpam: lencana di dada kiri (x %.2f, y %.2f, z %.2f)" % [a_l.get_center().x, a_l.get_center().y, a_l.get_center().z], a_l.get_center().x > 0.03 and a_l.get_center().y > 1.05 and a_l.get_center().y < 1.35 and a_l.get_center().z > 0.18)
		if slug == "putri" or slug == "ustadzah":
			# REBUILD (Kirana, 18 Nov 2026 — reset total, verdict Mas
			# 12:10 WIB "Jelek.. coba bikin dari awal lagi"): jilbab
			# kini SATU mesh prosedural "HijabKerudung" (ArrayMesh,
			# 1 permukaan). Semua node primitif ronde 1-8 DIHAPUS.
			var ker := _bagian(root, "HijabKerudung")
			_cek("%s: jilbab kerudung prosedural ada" % slug, ker != null)
			_cek("%s: jilbab satu kain (Hijab cuma 1 anak)" % slug, _bagian(root, "Hijab") != null and _bagian(root, "Hijab").get_child_count() == 1)
			_cek("%s: kerudung ArrayMesh 1 permukaan" % slug, ker is MeshInstance3D and (ker as MeshInstance3D).mesh is ArrayMesh and (ker as MeshInstance3D).mesh.get_surface_count() == 1)
			for nama_lama in ["HijabKubah", "HijabDrape", "HijabDepan", "HijabDepanBawah", "HijabDepanUjung", "HijabLeher", "HijabDagu", "HijabPanelKiri", "HijabPanelKanan", "HijabPipiKiri", "HijabPipiKanan", "HijabSisiKiri", "HijabSisiKanan", "HijabLipatanKiriAtas", "HijabLipatanKananAtas", "HijabLipatanKiriBawah", "HijabLipatanKananBawah", "HijabCape"]:
				_cek("%s: node primitif lama %s sudah dihapus" % [slug, nama_lama], _bagian(root, nama_lama) == null)
			var a_ker := _aabb_bagian(root, "HijabKerudung")
			_cek("%s: kubah longgar di atas ubun (puncak %.2f >= 1.95)" % [slug, a_ker.end.y], a_ker.end.y >= 1.95 and a_ker.end.y <= 2.10)
			_cek("%s: kubah lebih lebar dari kepala (lebar x %.2f >= 0.54)" % [slug, a_ker.size.x], a_ker.size.x >= 0.54)
			_cek("%s: drape sampai dada tengah (bawah y %.2f <= 0.92)" % [slug, a_ker.position.y], a_ker.position.y <= 0.92)
			_cek("%s: drape menempel dada (depan z %.2f <= 0.33)" % [slug, a_ker.end.z], a_ker.end.z <= 0.33)
			_cek("%s: drape menutupi punggung (belakang z %.2f <= -0.26)" % [slug, a_ker.position.z], a_ker.position.z <= -0.26)
			_cek("%s: drape menyambung ke abaya (irisan dgn abaya)" % slug, a_ker.intersects(_aabb_bagian(root, "Abaya")))
			# Cek simpul mesh: bukaan wajah bersih, pipi + dagu tertutup.
			var mi := ker as MeshInstance3D
			var _arr := (mi.mesh as ArrayMesh).surface_get_arrays(0)
			var verts := _arr[Mesh.ARRAY_VERTEX] as PackedVector3Array
			var tengah := 0
			var pipi_l := 0
			var pipi_r := 0
			var dagu_n := 0
			var min_kepala := 9.9
			for v in verts:
				var w := mi.global_transform * v
				if absf(w.x) < 0.10 and w.y >= 1.55 and w.y <= 1.72 and w.z > 0.15:
					tengah += 1
				if w.y >= 1.58 and w.y <= 1.68 and w.z > 0.15:
					if w.x >= 0.14 and w.x <= 0.20:
						pipi_r += 1
					if w.x >= -0.20 and w.x <= -0.14:
						pipi_l += 1
				if w.y >= 1.44 and w.y <= 1.50 and absf(w.x) < 0.10 and w.z > 0.18:
					dagu_n += 1
				if w.y >= 1.42 and w.y <= 1.90:
					min_kepala = minf(min_kepala, Vector3(w.x, w.y - 1.66, w.z).length())
			_cek("%s: tengah wajah bersih dari kain (%d simpul)" % [slug, tengah], tengah == 0)
			_cek("%s: pipi tertutup kain (kiri %d, kanan %d)" % [slug, pipi_l, pipi_r], pipi_l > 0 and pipi_r > 0)
			_cek("%s: dagu tertutup kain (%d simpul)" % [slug, dagu_n], dagu_n > 0)
			_cek("%s: kain di luar kepala (jarak min %.3f > 0.24)" % [slug, min_kepala], min_kepala > 0.24)

		remove_child(root)
		root.queue_free()
	print("AUDIT KARAKTER: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
