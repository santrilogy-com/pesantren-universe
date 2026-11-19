extends Node
## Tes kualitas adaptif (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB):
##   (Xvfb :98) godot --path . --resolution 1280x720 skrip/test_kualitas_adaptif.tscn
## Verifikasi: tiap tingkat menerapkan nilainya (baca-balik), probe
## FPS hanya menurunkan (tidak menaikkan), pantau dinamis turun +
## cooldown + lantai ringan, mode manual mematikan probe/pantau, dan
## pilihan tersimpan + terbaca lagi (save/load). TIDAK menguji deteksi
## perangkat web (headless/Xvfb bukan web -> deteksi default sedang).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("KUALITAS-CEK OK: %s" % nama)
	else:
		_gagal += 1
		print("KUALITAS-CEK GAGAL: %s" % nama)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var main = packed.instantiate()
	add_child(main)
	for i in 10:
		await get_tree().process_frame
	main._masuk_pesantren("Tes kualitas")
	for i in 10:
		await get_tree().process_frame
	var k = main._kualitas
	_cek("manager ada", k != null)
	if k == null:
		print("KUALITAS ADAPTIF: 0/%d LULUS" % (_lulus + _gagal))
		get_tree().quit(1)
		return
	var cam := get_viewport().get_camera_3d()
	var matahari := main.find_child("CahayaMatahariBulan", true, false) as DirectionalLight3D
	_cek("matahari ketemu", matahari != null)

	# --- Tingkat Tinggi: baca-balik semua tuas ---
	k.atur_mode("tinggi")
	_cek("tinggi: max_fps=0", Engine.max_fps == 0)
	_cek("tinggi: far=600", cam != null and absf(cam.far - 600.0) < 0.01)
	_cek("tinggi: bayangan nyala", matahari != null and matahari.shadow_enabled)
	_cek("tinggi: shadow_jarak=200", matahari != null and absf(matahari.directional_shadow_max_distance - 200.0) < 0.01)
	_cek("tinggi: msaa=4X", int(get_viewport().msaa_3d) == int(Viewport.MSAA_4X))
	_cek("tinggi: omni=1.0", absf(PencahayaanV2.pengali_energi - 1.0) < 0.001 and absf(LangitDinamis.pengali_lampu - 1.0) < 0.001)
	_cek("tinggi: label cull=60", _cull_label_saat_ini() == 60.0)

	# --- Tingkat Ringan ---
	k.atur_mode("ringan")
	_cek("ringan: max_fps=30", Engine.max_fps == 30)
	_cek("ringan: far=350", cam != null and absf(cam.far - 350.0) < 0.01)
	_cek("ringan: bayangan mati", matahari != null and not matahari.shadow_enabled)
	_cek("ringan: msaa=0", int(get_viewport().msaa_3d) == 0)
	_cek("ringan: omni=0.6", absf(PencahayaanV2.pengali_energi - 0.6) < 0.001 and absf(LangitDinamis.pengali_lampu - 0.6) < 0.001)
	_cek("ringan: label cull=25", _cull_label_saat_ini() == 25.0)

	# --- Tingkat Sedang ---
	k.atur_mode("sedang")
	_cek("sedang: max_fps=60", Engine.max_fps == 60)
	_cek("sedang: far=450", cam != null and absf(cam.far - 450.0) < 0.01)
	_cek("sedang: bayangan nyala", matahari != null and matahari.shadow_enabled)
	_cek("sedang: shadow_jarak=100", matahari != null and absf(matahari.directional_shadow_max_distance - 100.0) < 0.01)
	_cek("sedang: omni=1.0", absf(PencahayaanV2.pengali_energi - 1.0) < 0.001)
	_cek("sedang: label cull=40", _cull_label_saat_ini() == 40.0)

	# --- Save/load: pilihan tersimpan dan terbaca lagi ---
	k.atur_mode("ringan")
	var muat := SantriSave.load_data()
	_cek("save: mode=ringan", String(muat.get("kualitas_mode", "")) == "ringan")
	_cek("save: tingkat=ringan", String(muat.get("kualitas_tingkat", "")) == "ringan")

	# --- Probe: hanya menurunkan, tidak menaikkan ---
	k.atur_mode("otomatis") # non-web -> deteksi sedang + probe mulai
	_cek("otomatis: deteksi non-web=sedang", k.tingkat_saat_ini() == "sedang")
	k._koreksi_probe(20.0)
	_cek("probe fps rendah -> turun ke ringan", k.tingkat_saat_ini() == "ringan")
	k._koreksi_probe(55.0)
	_cek("probe fps tinggi TIDAK naik otomatis", k.tingkat_saat_ini() == "ringan")

	# --- Pantau: 5 jendela rendah -> turun; cooldown blokir; lantai ---
	k.atur_mode("otomatis") # kembali sedang
	for i in 5:
		k._catat_jendela(20.0)
	_cek("pantau 5 jendela rendah -> turun ke ringan", k.tingkat_saat_ini() == "ringan")
	for i in 5:
		k._catat_jendela(20.0)
	_cek("pantau: cooldown blokir penurunan kedua", k.tingkat_saat_ini() == "ringan")
	k._cooldown = 0.0
	for i in 5:
		k._catat_jendela(20.0)
	_cek("pantau: lantai ringan (tidak turun lagi)", k.tingkat_saat_ini() == "ringan")
	k._catat_jendela(60.0)
	_cek("pantau: jendela bagus reset hitungan", k._jendela_rendah == 0)

	# --- Mode manual mematikan probe/pantau ---
	k.atur_mode("tinggi")
	_cek("manual: fase idle", k._fase == "idle")
	k.mulai_probe()
	_cek("manual: mulai_probe tidak jalan", k._fase == "idle")

	# Kembalikan save lokal ke keadaan awal (deteksi ulang lain kali).
	k.atur_mode("otomatis")
	var s := SantriSave.load_data()
	s["kualitas_tingkat"] = ""
	SantriSave.save_data(s)

	print("KUALITAS ADAPTIF: %d/%d LULUS" % [_lulus, _lulus + _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


## Jarak cull label yang sedang diterapkan (baca dari satu label grup).
func _cull_label_saat_ini() -> float:
	var daftar := get_tree().get_nodes_in_group("label_kualitas")
	if daftar.is_empty():
		return -1.0
	return float((daftar[0] as Label3D).visibility_range_end)
