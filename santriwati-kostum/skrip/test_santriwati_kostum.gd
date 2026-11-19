extends Node
## Tes santriwati kostum (KIRANA 17 Nov 2026 — Mas: "Abaya dan jilbab
## warnanya bisa dikostum ganti ketika ganti baju").
## Santriwati tampil abaya + jilbab (bukan koko), warna abaya +
## jilbab dipilih lewat panel Ganti Baju, tersimpan di save.
## Dijalankan sebagai SCENE (.tscn), pola test_login_gender.gd.
## Disalin ke godot-dunia/ saat jalan, dihapus sebelum export.
## Jam dibekukan 10.00 (debug_jam) supaya sesi sholat tidak mengganggu.
## Save lokal (user://santri.json) di-backup di awal tes dan
## dikembalikan di akhir — perangkat penguji tidak kehilangan progres.

var _main: Node
var _lolos := 0
var _gagal := 0
var _save_backup := ""
var _save_ada := false


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	if FileAccess.file_exists(SantriSave.SAVE_PATH):
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.READ)
		if f != null:
			_save_backup = f.get_as_text()
			_save_ada = true
			f.close()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	# Bekukan timer patroli (Kyai/Ustadzah tetap duduk) seperti baseline.
	_main._kyai._patroli_timer = 9999.0
	_main._ustadzah._patroli_timer = 9999.0
	_tes_kunci_save()
	_tes_build_muslimah()
	_tes_build_santriwan()
	_tes_ustadzah_tetap()
	await _tes_ganti_gender()
	_tes_panel_baris()
	await _tes_ganti_warna_panel()
	_tes_persistensi()
	await _tes_santriwan_tidak_terpengaruh()
	_tes_ustadzah_live_tetap()
	_pulihkan_save()
	print("HASIL TES SANTRIWATI-KOSTUM: %d LOLOS / %d GAGAL" % [_lolos, _gagal])
	LangitDinamis.debug_jam = 10.0
	for i in 300:
		await get_tree().process_frame
	print("SMOKE 300 FRAME SELESAI")
	get_tree().quit(0 if _gagal == 0 else 1)


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _pulihkan_save() -> void:
	if _save_ada:
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.WRITE)
		if f != null:
			f.store_string(_save_backup)


## Warna material sebuah node ("" bila node/material tidak ada).
func _warna_node(root: Node, nama_node: String) -> Color:
	var n := root.find_child(nama_node, true, false)
	if n is MeshInstance3D:
		var m := (n as MeshInstance3D).material_override
		if m is StandardMaterial3D:
			return (m as StandardMaterial3D).albedo_color
	return Color(-1, -1, -1)


func _warna_sama(a: Color, b: Color) -> bool:
	return a.is_equal_approx(b)


# ---------- A. Kunci save + pilihan warna ----------
func _tes_kunci_save() -> void:
	print("== A. Kunci save + pilihan warna ==")
	var d := SantriSave.default_data()
	var o: Dictionary = d.get("outfit", {})
	_cek("default_data outfit punya abaya #065f46", String(o.get("abaya", "")) == "#065f46", str(o.get("abaya", "")))
	_cek("default_data outfit punya hijab_warna #f2ead6", String(o.get("hijab_warna", "")) == "#f2ead6", str(o.get("hijab_warna", "")))
	_cek("OUTFIT_DEFAULT punya abaya + hijab_warna", String(MissionData.OUTFIT_DEFAULT.get("abaya", "")) == "#065f46" and String(MissionData.OUTFIT_DEFAULT.get("hijab_warna", "")) == "#f2ead6", "")
	_cek("OUTFIT_ABAYA 4 pilihan (Zamrud default)", MissionData.OUTFIT_ABAYA.size() == 4 and String(MissionData.OUTFIT_ABAYA[0]["warna"].to_html(false)) == "065f46", str(MissionData.OUTFIT_ABAYA.size()))
	_cek("OUTFIT_JILBAB 4 pilihan (Krem default)", MissionData.OUTFIT_JILBAB.size() == 4 and String(MissionData.OUTFIT_JILBAB[0]["warna"].to_html(false)) == "f2ead6", str(MissionData.OUTFIT_JILBAB.size()))


# ---------- B. build_visual muslimah (statik) ----------
func _tes_build_muslimah() -> void:
	print("== B. build_visual muslimah ==")
	var outfit := MissionData.OUTFIT_USTADZAH.duplicate()
	var built: Dictionary = SantriPlayer.build_visual("Tes Putri", outfit)
	var root: Node = built["root"]
	_cek("muslimah: node Abaya ada", built["abaya"] != null, "")
	_cek("muslimah: node Hijab ada", built["hijab"] != null, "")
	_cek("muslimah: Peci TIDAK ada", built["peci"] == null, "")
	_cek("muslimah: slot sarung = Abaya", String(built["sarung"].name) == "Abaya", str(built["sarung"].name))
	_cek("muslimah: torso sewarna abaya #065f46", _warna_sama(_warna_node(root, "Torso"), Color("#065f46")), str(_warna_node(root, "Torso")))
	_cek("muslimah: lengan (BahuKiri) sewarna abaya", _warna_sama(_warna_node(root, "BahuKiri"), Color("#065f46")), str(_warna_node(root, "BahuKiri")))
	_cek("muslimah: Abaya #065f46", _warna_sama(_warna_node(root, "Abaya"), Color("#065f46")), str(_warna_node(root, "Abaya")))
	_cek("muslimah: HijabKubah #f2ead6", _warna_sama(_warna_node(root, "HijabKubah"), Color("#f2ead6")), str(_warna_node(root, "HijabKubah")))
	_cek("muslimah: HijabDrape = krem digelapkan 0.03", _warna_sama(_warna_node(root, "HijabDrape"), Color("#f2ead6").darkened(0.03)), str(_warna_node(root, "HijabDrape")))
	_cek("muslimah: tidak ada node Sarung", root.find_child("Sarung", true, false) == null, "")
	_cek("muslimah: tidak ada Kerah", root.find_child("Kerah", true, false) == null, "")
	_cek("muslimah: alis ada (bukan topeng)", root.find_child("AlisKiri", true, false) != null, "")
	root.free()


# ---------- C. build_visual santriwan (statik, regresi) ----------
func _tes_build_santriwan() -> void:
	print("== C. build_visual santriwan ==")
	var built: Dictionary = SantriPlayer.build_visual("Tes Putra", MissionData.OUTFIT_DEFAULT.duplicate())
	var root: Node = built["root"]
	_cek("santriwan: Peci ada", built["peci"] != null, "")
	_cek("santriwan: Hijab TIDAK ada", built["hijab"] == null, "")
	_cek("santriwan: Abaya TIDAK ada", built["abaya"] == null, "")
	_cek("santriwan: slot sarung = Sarung", String(built["sarung"].name) == "Sarung", str(built["sarung"].name))
	_cek("santriwan: torso koko #faf7f0", _warna_sama(_warna_node(root, "Torso"), Color("#faf7f0")), str(_warna_node(root, "Torso")))
	_cek("santriwan: Kerah ada", root.find_child("Kerah", true, false) != null, "")
	root.free()


# ---------- D. Ustadzah tetap (statik) ----------
func _tes_ustadzah_tetap() -> void:
	print("== D. Ustadzah tetap ==")
	var built: Dictionary = SantriPlayer.build_visual("Ust. Aqsal Murad", MissionData.OUTFIT_USTADZAH.duplicate())
	var root: Node = built["root"]
	_cek("ustadzah: torso tetap #065f46", _warna_sama(_warna_node(root, "Torso"), Color("#065f46")), str(_warna_node(root, "Torso")))
	_cek("ustadzah: lengan tetap #065f46", _warna_sama(_warna_node(root, "BahuKiri"), Color("#065f46")), str(_warna_node(root, "BahuKiri")))
	_cek("ustadzah: abaya tetap #065f46", _warna_sama(_warna_node(root, "Abaya"), Color("#065f46")), str(_warna_node(root, "Abaya")))
	_cek("ustadzah: jilbab tetap #f2ead6", _warna_sama(_warna_node(root, "HijabKubah"), Color("#f2ead6")), str(_warna_node(root, "HijabKubah")))
	root.free()


# ---------- E. Ganti gender live ----------
func _tes_ganti_gender() -> void:
	print("== E. Ganti gender live ==")
	# Masuk sebagai santriwati (stub login server, tanpa jaringan).
	var r: String = _main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri", "jenis_kelamin": "putri", "session": "stub"})
	_cek("login stub putri sukses", r == "", r)
	_main._masuk_pesantren("Tes Putri")
	await get_tree().process_frame
	_cek("putri: visual muslimah", bool(_main._player.apakah_muslimah()), "")
	_cek("putri: save outfit muslimah=true", bool(_main._save["outfit"].get("muslimah", false)), "")
	_cek("putri: node Abaya ada di visual pemain", _main._player._visual.find_child("Abaya", true, false) != null, "")
	_cek("putri: node Hijab ada di visual pemain", _main._player._visual.find_child("Hijab", true, false) != null, "")
	_cek("putri: Peci TIDAK ada", _main._player._visual.find_child("Peci", true, false) == null, "")
	_cek("putri: spawn (130,14)", _main._player.global_position.distance_to(Vector3(130, 0, 14)) < 1.0, str(_main._player.global_position))
	_cek("putri: nama dipertahankan", String(_main._player._nama) == "Tes Putri", String(_main._player._nama))
	# Kembali sebagai santriwan.
	r = _main._terapkan_login_server({"id": "PV-0003", "nama": "Tes Putra", "ig_username": "tes.putra", "jenis_kelamin": "putra", "session": "stub"})
	_cek("login stub putra sukses", r == "", r)
	_main._masuk_pesantren("Tes Putra")
	await get_tree().process_frame
	_cek("putra: visual BUKAN muslimah", not bool(_main._player.apakah_muslimah()), "")
	_cek("putra: Peci ada lagi", _main._player._visual.find_child("Peci", true, false) != null, "")
	_cek("putra: Abaya TIDAK ada", _main._player._visual.find_child("Abaya", true, false) == null, "")
	_cek("putra: spawn (-4,14)", _main._player.global_position.distance_to(Vector3(-4, 0, 14)) < 1.0, str(_main._player.global_position))
	_cek("putra: nama dipertahankan", String(_main._player._nama) == "Tes Putra", String(_main._player._nama))


# ---------- F. Baris panel per gender ----------
func _tes_panel_baris() -> void:
	print("== F. Baris panel per gender ==")
	# Panel sebagai santriwati.
	var outfit_putri: Dictionary = _main._save.get("outfit", {}).duplicate()
	outfit_putri["muslimah"] = true
	outfit_putri["hijab"] = true
	_main._ui.open_outfit(outfit_putri)
	_cek("panel putri: baris Abaya tampil", bool(_main._ui._outfit_baris["abaya"].visible), "")
	_cek("panel putri: baris Jilbab tampil", bool(_main._ui._outfit_baris["jilbab"].visible), "")
	_cek("panel putri: baris Koko sembunyi", not bool(_main._ui._outfit_baris["koko"].visible), "")
	_cek("panel putri: baris Songkok sembunyi", not bool(_main._ui._outfit_baris["songkok"].visible), "")
	_cek("panel putri: baris Sarung sembunyi", not bool(_main._ui._outfit_baris["sarung"].visible), "")
	_cek("panel putri: baris Kulit tampil", bool(_main._ui._outfit_baris["kulit"].visible), "")
	# Panel sebagai santriwan.
	var outfit_putra: Dictionary = _main._save.get("outfit", {}).duplicate()
	outfit_putra["muslimah"] = false
	outfit_putra["hijab"] = false
	_main._ui.open_outfit(outfit_putra)
	_cek("panel putra: baris Koko tampil", bool(_main._ui._outfit_baris["koko"].visible), "")
	_cek("panel putra: baris Abaya sembunyi", not bool(_main._ui._outfit_baris["abaya"].visible), "")
	_cek("panel putra: baris Jilbab sembunyi", not bool(_main._ui._outfit_baris["jilbab"].visible), "")
	_main._ui.close_outfit()


# ---------- G. Ganti warna lewat panel ----------
func _tes_ganti_warna_panel() -> void:
	print("== G. Ganti warna lewat panel ==")
	# Kembali masuk sebagai santriwati (visual muslimah).
	_main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri", "jenis_kelamin": "putri", "session": "stub"})
	_main._masuk_pesantren("Tes Putri")
	await get_tree().process_frame
	# Abaya -> Hitam lewat swatch panel (sinyal -> main -> save + visual).
	_main._ui._on_outfit_swatch("abaya", "#23282e")
	_cek("panel: save abaya = #23282e", String(_main._save["outfit"].get("abaya", "")) == "#23282e", str(_main._save["outfit"].get("abaya", "")))
	_cek("panel: visual Abaya berubah hitam", _warna_sama(_warna_node(_main._player._visual, "Abaya"), Color("#23282e")), str(_warna_node(_main._player._visual, "Abaya")))
	_cek("panel: torso ikut abaya hitam", _warna_sama(_warna_node(_main._player._visual, "Torso"), Color("#23282e")), str(_warna_node(_main._player._visual, "Torso")))
	_cek("panel: tanda ✓ di swatch Hitam", String(_main._ui._outfit_buttons["abaya:#23282e"].text).begins_with("✓ "), String(_main._ui._outfit_buttons["abaya:#23282e"].text))
	# Jilbab -> Putih lewat swatch panel (kunci save "hijab_warna").
	_main._ui._on_outfit_swatch("hijab_warna", "#faf7f0")
	_cek("panel: save hijab_warna = #faf7f0", String(_main._save["outfit"].get("hijab_warna", "")) == "#faf7f0", str(_main._save["outfit"].get("hijab_warna", "")))
	_cek("panel: visual HijabKubah berubah putih", _warna_sama(_warna_node(_main._player._visual, "HijabKubah"), Color("#faf7f0")), str(_warna_node(_main._player._visual, "HijabKubah")))
	_cek("panel: HijabDrape putih digelapkan 0.03", _warna_sama(_warna_node(_main._player._visual, "HijabDrape"), Color("#faf7f0").darkened(0.03)), str(_warna_node(_main._player._visual, "HijabDrape")))
	_cek("panel: tanda ✓ di swatch Jilbab Putih", String(_main._ui._outfit_buttons["hijab_warna:#faf7f0"].text).begins_with("✓ "), String(_main._ui._outfit_buttons["hijab_warna:#faf7f0"].text))


# ---------- H. Persistensi ----------
func _tes_persistensi() -> void:
	print("== H. Persistensi ==")
	# Abaya Hitam + Jilbab Putih dari bagian G sudah disimpan handler.
	var d := SantriSave.load_data()
	var o: Dictionary = d.get("outfit", {})
	_cek("persistensi: load_data abaya = #23282e", String(o.get("abaya", "")) == "#23282e", str(o.get("abaya", "")))
	_cek("persistensi: load_data hijab_warna = #faf7f0", String(o.get("hijab_warna", "")) == "#faf7f0", str(o.get("hijab_warna", "")))
	_cek("persistensi: load_data muslimah = true", bool(o.get("muslimah", false)), "")
	# Kembalikan ke default (Zamrud + Krem) supaya save tes bersih.
	_main._ui._on_outfit_swatch("abaya", "#065f46")
	_main._ui._on_outfit_swatch("hijab_warna", "#f2ead6")
	_cek("reset: abaya kembali #065f46", String(_main._save["outfit"].get("abaya", "")) == "#065f46", "")
	_cek("reset: hijab_warna kembali #f2ead6", String(_main._save["outfit"].get("hijab_warna", "")) == "#f2ead6", "")


# ---------- I. Santriwan tidak terpengaruh ----------
func _tes_santriwan_tidak_terpengaruh() -> void:
	print("== I. Santriwan tidak terpengaruh ==")
	_main._terapkan_login_server({"id": "PV-0003", "nama": "Tes Putra", "ig_username": "tes.putra", "jenis_kelamin": "putra", "session": "stub"})
	_main._masuk_pesantren("Tes Putra")
	await get_tree().process_frame
	_main._ui._on_outfit_swatch("sarung", "#1d4e6b")
	# Sarung memakai motif batik prosedural — warnanya ada di TEKSTUR
	# (albedo material putih), jadi yang dicek adalah objek materialnya
	# sama dengan motif cache untuk warna Biru (bukan albedo_color).
	var sarung_node := _main._player._visual.find_child("Sarung", true, false) as MeshInstance3D
	_cek("putra: sarung berubah Biru", sarung_node != null and sarung_node.material_override == SantriPlayer._motif_sarung(Color("#1d4e6b")), "")
	_cek("putra: tidak ada node Abaya", _main._player._visual.find_child("Abaya", true, false) == null, "")
	_cek("putra: tidak ada node Hijab", _main._player._visual.find_child("Hijab", true, false) == null, "")
	# Kembalikan sarung ke default supaya save tes bersih.
	_main._ui._on_outfit_swatch("sarung", "#0b6b4f")


# ---------- J. Ustadzah live tetap ----------
func _tes_ustadzah_live_tetap() -> void:
	print("== J. Ustadzah live tetap ==")
	var v: Node = _main._ustadzah._visual
	_cek("ustadzah live: abaya tetap #065f46", _warna_sama(_warna_node(v, "Abaya"), Color("#065f46")), str(_warna_node(v, "Abaya")))
	_cek("ustadzah live: jilbab tetap #f2ead6", _warna_sama(_warna_node(v, "HijabKubah"), Color("#f2ead6")), str(_warna_node(v, "HijabKubah")))
	_cek("ustadzah live: torso tetap #065f46", _warna_sama(_warna_node(v, "Torso"), Color("#065f46")), str(_warna_node(v, "Torso")))
