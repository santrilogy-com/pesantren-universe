extends Node
## Tes ujung-ke-ujung rantai cuaca (Wulan, 17 Nov 2026). Headless:
##   godot --headless --path . test_cuaca_e2e.tscn
## Mensimulasikan callback geolocation dengan koordinat Sidogiri
## (BUKAN lokasi nyata user — angka ini hanya data tes, bukan hasil
## pelacakan), lalu menunggu jawaban Open-Meteo yang sebenarnya dan
## memeriksa kondisi diterapkan ke LangitDinamis.
## Satu-satunya bagian yang TIDAK bisa dites di VM: prompt izin
## Geolocation API di browser HP (butuh JavaScriptBridge + Chrome).

var _gagal: int = 0
var _cuaca: Cuaca
var _sinyal_diterima: bool = false


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		print("PASS " + nama + " " + detail)
	else:
		_gagal += 1
		print("FAIL " + nama + " " + detail)


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var langit := LangitDinamis.build()
	add_child(langit)
	_cuaca = Cuaca.new()
	add_child(_cuaca)
	_cuaca.cuaca_diperbarui.connect(func(_k: String) -> void: _sinyal_diterima = true)
	# Jalur non-web dilewati: set flag manual supaya _on_lokasi_ok
	# bisa jalan (mulai() di VM langsung fallback cerah).
	_cuaca._langit = langit
	_cuaca.sudah_diminta = true
	# Simulasi callback geolocation sukses (Sidogiri, -7.65, 112.90).
	_cuaca._on_lokasi_ok([-7.65, 112.90])
	# Tunggu jawaban Open-Meteo (maks ~15 detik).
	var menunggu := 0.0
	while not _sinyal_diterima and menunggu < 15.0:
		await get_tree().create_timer(0.5).timeout
		menunggu += 0.5
	# Cuaca Sidogiri 17 Nov 2026 ~21:00 WIB: kode berapa pun, yang
	# dicek rantai lengkapnya: jawaban API sampai + kondisi valid +
	# langit mengikutinya. (Sinyal membedakan "API menjawab" dari
	# fallback diam — fallback tanpa API tidak memicu sinyal ini di
	# jalur ini karena _on_lokasi_ok selalu memanggil HTTP dulu.)
	_cek("e2e-api-menjawab", _sinyal_diterima)
	_cek("e2e-kondisi-valid", _cuaca.kondisi in ["cerah", "berawan", "mendung", "hujan"], "kondisi=" + _cuaca.kondisi)
	_cek("e2e-langit-ikut", langit.get_kondisi() == _cuaca.kondisi, "langit=" + langit.get_kondisi())
	if _cuaca.kondisi == "hujan":
		_cek("e2e-hujan-nyala", langit._hujan.visible)
	elif _cuaca.kondisi == "mendung":
		_cek("e2e-mendung-gelap", langit._env.ambient_light_energy < 0.65, "ambient=%.2f" % langit._env.ambient_light_energy)
	if _gagal == 0:
		print("TES CUACA E2E: SEMUA LULUS")
	else:
		print("TES CUACA E2E: " + str(_gagal) + " GAGAL")
	get_tree().quit(_gagal)
