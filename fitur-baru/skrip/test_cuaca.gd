extends Node
## Tes logika FITUR CUACA (Wulan, 17 Nov 2026). Dijalankan HEADLESS:
##   godot --headless --path . test_cuaca.tscn
## Memeriksa (tanpa jaringan — jaringan Open-Meteo TIDAK bisa diuji dari
## VM ini: HTTPRequest Godot tidak menembus proxy, lihat status doc):
##  1) pemetaan kode WMO 0-99 -> kondisi game (tabel lengkap);
##  2) parse JSON jawaban Open-Meteo (sukses / rusak / kosong);
##  3) fallback: di luar web (VM) mulai() langsung cerah tanpa prompt;
##  4) izin hanya diminta sekali per sesi (panggilan ke-2 no-op);
##  5) hook LangitDinamis: set_kondisi/get_kondisi, jumlah awan,
##     faktor gelap, hujan menyala hanya saat "hujan", debug_kondisi.
## TIDAK menyimpan PNG (headless tidak bisa save_png).

var _gagal: int = 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		print("PASS " + nama + " " + detail)
	else:
		_gagal += 1
		print("FAIL " + nama + " " + detail)


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	LangitDinamis.debug_kondisi = ""

	# ---- 1) Pemetaan WMO (tabel lengkap 0-99, kode tak dikenal -> cerah) ----
	var peta := {
		0: "cerah", 1: "cerah", 2: "berawan", 3: "mendung",
		45: "mendung", 48: "mendung",
		51: "hujan", 53: "hujan", 55: "hujan", 56: "hujan", 57: "hujan",
		61: "hujan", 63: "hujan", 65: "hujan", 66: "hujan", 67: "hujan",
		71: "mendung", 73: "mendung", 75: "mendung", 77: "mendung",
		80: "hujan", 81: "hujan", 82: "hujan",
		85: "mendung", 86: "mendung",
		95: "hujan", 96: "hujan", 99: "hujan",
	}
	for kode in peta:
		_cek("wmo-%d" % kode, Cuaca.kondisi_dari_kode_wmo(kode) == peta[kode], "-> " + Cuaca.kondisi_dari_kode_wmo(kode))
	_cek("wmo-tak-dikenal-4", Cuaca.kondisi_dari_kode_wmo(4) == "cerah")
	_cek("wmo-tak-dikenal-100", Cuaca.kondisi_dari_kode_wmo(100) == "cerah")
	_cek("wmo-negatif", Cuaca.kondisi_dari_kode_wmo(-1) == "cerah")

	# ---- 2) Parse JSON Open-Meteo ----
	_cek("json-cerah", Cuaca.kondisi_dari_json_teks('{"current":{"weather_code":0}}') == "cerah")
	_cek("json-hujan", Cuaca.kondisi_dari_json_teks('{"current":{"weather_code":63}}') == "hujan")
	_cek("json-mendung", Cuaca.kondisi_dari_json_teks('{"current":{"weather_code":3}}') == "mendung")
	_cek("json-berawan", Cuaca.kondisi_dari_json_teks('{"current":{"weather_code":2}}') == "berawan")
	_cek("json-rusak", Cuaca.kondisi_dari_json_teks('bukan json') == "cerah")
	_cek("json-kosong", Cuaca.kondisi_dari_json_teks('') == "cerah")
	_cek("json-tanpa-current", Cuaca.kondisi_dari_json_teks('{"latitude":1.0}') == "cerah")
	_cek("json-tanpa-kode", Cuaca.kondisi_dari_json_teks('{"current":{}}') == "cerah")
	_cek("json-kode-string", Cuaca.kondisi_dari_json_teks('{"current":{"weather_code":"63"}}') == "cerah")

	# ---- 3) + 4) Fallback non-web + sekali per sesi ----
	var langit := LangitDinamis.build()
	add_child(langit)
	var cuaca := Cuaca.new()
	add_child(cuaca)
	_cek("bukan-web", not OS.has_feature("web"))
	cuaca.mulai(langit)
	_cek("fallback-cerah", cuaca.kondisi == "cerah" and langit.get_kondisi() == "cerah", "kondisi=" + cuaca.kondisi)
	_cek("sudah-diminta", cuaca.sudah_diminta)
	cuaca.paksa_kondisi("hujan")
	_cek("paksa-hujan", cuaca.kondisi == "hujan" and langit.get_kondisi() == "hujan")
	cuaca.mulai(langit)
	_cek("mulai-kedua-noop", cuaca.kondisi == "hujan", "tetap hujan, izin tidak diminta ulang")

	# ---- 5) Hook LangitDinamis ----
	langit.set_kondisi("ngawur")
	_cek("set-tak-dikenal-cerah", langit.get_kondisi() == "cerah")
	langit.set_kondisi("berawan")
	_cek("set-berawan", langit.get_kondisi() == "berawan")
	_cek("faktor-cerah", is_equal_approx(LangitDinamis.faktor_gelap("cerah"), 1.0))
	_cek("faktor-berawan", is_equal_approx(LangitDinamis.faktor_gelap("berawan"), 0.92))
	_cek("faktor-mendung", is_equal_approx(LangitDinamis.faktor_gelap("mendung"), 0.72))
	_cek("faktor-hujan", is_equal_approx(LangitDinamis.faktor_gelap("hujan"), 0.55))
	_cek("awan-cerah-3", LangitDinamis.jumlah_awan("cerah") == 3)
	_cek("awan-berawan-7", LangitDinamis.jumlah_awan("berawan") == 7)
	_cek("awan-mendung-12", LangitDinamis.jumlah_awan("mendung") == 12)
	_cek("awan-hujan-12", LangitDinamis.jumlah_awan("hujan") == 12)
	_cek("awan-dibangun-12", langit._awan.size() == 12)
	_cek("tetes-dibangun-160", langit._tetes_pos.size() == 160)

	# Visibilitas awan + hujan mengikuti kondisi (via _terapkan jam 10).
	langit.set_kondisi("cerah")
	langit._terapkan(10.0)
	var n_terlihat := 0
	for a in langit._awan:
		if a.visible:
			n_terlihat += 1
	_cek("awan-terlihat-cerah-3", n_terlihat == 3, "n=" + str(n_terlihat))
	_cek("hujan-mati-cerah", not langit._hujan.visible)
	_cek("langit-cerah-terang", langit._env.ambient_light_energy > 0.8, "ambient=%.2f" % langit._env.ambient_light_energy)
	langit.set_kondisi("mendung")
	langit._terapkan(10.0)
	n_terlihat = 0
	for a in langit._awan:
		if a.visible:
			n_terlihat += 1
	_cek("awan-terlihat-mendung-12", n_terlihat == 12, "n=" + str(n_terlihat))
	_cek("hujan-mati-mendung", not langit._hujan.visible)
	_cek("langit-mendung-gelap", langit._env.ambient_light_energy < 0.65, "ambient=%.2f" % langit._env.ambient_light_energy)
	langit.set_kondisi("hujan")
	langit._terapkan(10.0)
	_cek("hujan-nyala", langit._hujan.visible)
	_cek("langit-hujan-paling-gelap", langit._env.ambient_light_energy < 0.5, "ambient=%.2f" % langit._env.ambient_light_energy)
	# debug_kondisi mengalahkan kondisi dari Cuaca.
	LangitDinamis.debug_kondisi = "cerah"
	_cek("debug-kondisi-menang", langit.get_kondisi() == "cerah")
	LangitDinamis.debug_kondisi = ""

	if _gagal == 0:
		print("TES CUACA: SEMUA LULUS")
	else:
		print("TES CUACA: " + str(_gagal) + " GAGAL")
	get_tree().quit(_gagal)
