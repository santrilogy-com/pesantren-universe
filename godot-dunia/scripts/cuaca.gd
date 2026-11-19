class_name Cuaca
extends Node
## Cuaca nyata mengikuti lokasi user (FITUR BARU v1, Wulan 17 Nov 2026,
## Mas DI-ACC 17 Nov ~20:52 WIB).
##
## Alur: minta izin lokasi HP sekali per sesi (Geolocation API lewat
## JavaScriptBridge, hanya di export web) -> panggil Open-Meteo
## (https://api.open-meteo.com, GRATIS, tanpa API key) dengan koordinat
## itu -> kode cuaca WMO dipetakan ke kondisi game (cerah / berawan /
## mendung / hujan) -> LangitDinamis menerapkan langit + awan + hujan.
##
## PRIVASI (KERAS, perintah Mas):
## - Koordinat dipakai HANYA untuk sekali panggil Open-Meteo.
## - Koordinat TIDAK PERNAH ditulis ke save file, TIDAK dikirim ke
##   server game, TIDAK dicatat di log (log hanya "lokasi diterima",
##   tanpa angka). Variabel lokal _lat/_lon dibuang setelah dipakai.
## - Izin TIDAK diberikan / API gagal / tidak ada internet -> fallback
##   "cerah", game tetap jalan normal. Izin hanya diminta SEKALI per
##   sesi (flag _sudah_diminta); tidak pernah dipaksa berulang.
## - Di luar web (editor/VM/desktop) geolocation dilewati: langsung
##   fallback cerah, tanpa prompt apa pun.

## Sinyal saat kondisi berubah (dipakai UI nanti kalau perlu).
signal cuaca_diperbarui(kondisi: String)

## Kondisi yang dikenal LangitDinamis.
const KONDISI_CERAH := "cerah"
const KONDISI_BERAWAN := "berawan"
const KONDISI_MENDUNG := "mendung"
const KONDISI_HUJAN := "hujan"

## Open-Meteo: cuaca saat ini saja di titik itu (current=weather_code).
## Tanpa API key, gratis. timeout 10 detik untuk geolocation, 12 detik HTTP.
const URL_TEMPLATE := "https://api.open-meteo.com/v1/forecast?latitude=%.6f&longitude=%.6f&current=weather_code"
const TIMEOUT_HTTP_DETIK := 12

## Kondisi saat ini (default = fallback cerah).
var kondisi: String = KONDISI_CERAH
## True sesudah mulai() dipanggil sekali (izin tidak diminta ulang).
var sudah_diminta: bool = false

var _langit: LangitDinamis = null
var _http: HTTPRequest = null


## Pemetaan kode cuaca WMO (Open-Meteo) -> kondisi game.
## Salju (71-77, 85-86) tidak relevan di Indonesia: dipetakan ke
## "mendung" (langit abu-abu, tanpa hujan) supaya tidak salah tampil.
## Kode tak dikenal -> "cerah" (fallback aman).
static func kondisi_dari_kode_wmo(kode: int) -> String:
	match kode:
		0, 1:
			return KONDISI_CERAH
		2:
			return KONDISI_BERAWAN
		3, 45, 48:
			return KONDISI_MENDUNG
		51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99:
			return KONDISI_HUJAN
		71, 73, 75, 77, 85, 86:
			return KONDISI_MENDUNG
	return KONDISI_CERAH


## Ambil kondisi dari teks JSON jawaban Open-Meteo (dipisah supaya bisa
## di-unit-test tanpa jaringan). Gagal parse / tidak ada weather_code
## -> "cerah".
static func kondisi_dari_json_teks(teks: String) -> String:
	var data: Variant = JSON.parse_string(teks)
	if typeof(data) != TYPE_DICTIONARY:
		return KONDISI_CERAH
	var saat_ini: Variant = (data as Dictionary).get("current", {})
	if typeof(saat_ini) != TYPE_DICTIONARY:
		return KONDISI_CERAH
	var kode: Variant = (saat_ini as Dictionary).get("weather_code", -1)
	if typeof(kode) != TYPE_FLOAT and typeof(kode) != TYPE_INT:
		return KONDISI_CERAH
	return kondisi_dari_kode_wmo(int(kode))


## Mulai alur cuaca sekali per sesi. Aman dipanggil berulang (mis.
## pemain masuk pesantren lagi): panggilan ke-2+ langsung kembali.
## langit = node LangitDinamis dari PesantrenBuilder ("langit").
func mulai(langit: LangitDinamis) -> void:
	_langit = langit
	if sudah_diminta:
		return
	sudah_diminta = true
	if not OS.has_feature("web"):
		# Editor/VM/desktop: tidak ada Geolocation API -> cerah.
		_terapkan(KONDISI_CERAH)
		return
	_minta_lokasi()


## Minta izin lokasi lewat Geolocation API (web saja). Callback JS
## didaftarkan di window supaya halaman web bisa memanggil balik ke
## Godot (pola JavaScriptBridge.create_callback yang didokumentasikan).
func _minta_lokasi() -> void:
	var jsb = Engine.get_singleton("JavaScriptBridge")
	if jsb == null:
		_terapkan(KONDISI_CERAH)
		return
	var window = jsb.get_interface("window")
	if window == null:
		_terapkan(KONDISI_CERAH)
		return
	window.__pv_cuaca_ok = jsb.create_callback(_on_lokasi_ok)
	window.__pv_cuaca_gagal = jsb.create_callback(_on_lokasi_gagal)
	# maximumAge 10 menit: posisi yang masih segar boleh dipakai ulang
	# tanpa prompt baru; timeout 10 detik.
	jsb.eval("navigator.geolocation.getCurrentPosition(function(p){ window.__pv_cuaca_ok(p.coords.latitude, p.coords.longitude); }, function(e){ window.__pv_cuaca_gagal(e.code); }, {timeout: 10000, maximumAge: 600000});")


## Callback sukses geolocation. args = [latitude, longitude].
## PRIVASI: angka koordinat TIDAK di-print / disimpan — hanya dipakai
## di sini untuk membentuk URL Open-Meteo, lalu dibuang.
func _on_lokasi_ok(args: Array) -> void:
	if args.size() < 2:
		_terapkan(KONDISI_CERAH)
		return
	var lat := float(args[0])
	var lon := float(args[1])
	print("[Cuaca] Lokasi diterima, mengambil cuaca saat ini.")
	_ambil_cuaca(lat, lon)


## Callback gagal geolocation (ditolak user / tidak tersedia / timeout).
## args[0] = kode error (1 ditolak, 2 tak tersedia, 3 timeout).
func _on_lokasi_gagal(args: Array) -> void:
	var kode := int(args[0]) if args.size() > 0 else 0
	print("[Cuaca] Izin lokasi tidak diberikan (kode %d) — langit tetap cerah." % kode)
	_terapkan(KONDISI_CERAH)


## Panggil Open-Meteo dengan koordinat (sekali pakai, tidak disimpan).
func _ambil_cuaca(lat: float, lon: float) -> void:
	if _http == null:
		_http = HTTPRequest.new()
		_http.timeout = TIMEOUT_HTTP_DETIK
		_http.request_completed.connect(_on_http_selesai)
		add_child(_http)
	var url := URL_TEMPLATE % [lat, lon]
	var err := _http.request(url)
	if err != OK:
		print("[Cuaca] HTTPRequest gagal dimulai — langit tetap cerah.")
		_terapkan(KONDISI_CERAH)


## Jawaban Open-Meteo: result != SUCCESS / HTTP != 200 / JSON rusak
## -> fallback cerah. Koordinat sudah tidak ada di sini (tidak disimpan).
func _on_http_selesai(result: int, kode_http: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or kode_http != 200:
		print("[Cuaca] Open-Meteo tidak terjangkau (result %d, http %d) — langit tetap cerah." % [result, kode_http])
		_terapkan(KONDISI_CERAH)
		return
	var kondisi_baru := kondisi_dari_json_teks(body.get_string_from_utf8())
	print("[Cuaca] Kondisi dari Open-Meteo: " + kondisi_baru)
	_terapkan(kondisi_baru)


## Terapkan kondisi ke langit + sinyal. Dipakai juga untuk tes/debug.
func _terapkan(kondisi_baru: String) -> void:
	kondisi = kondisi_baru
	if _langit != null:
		_langit.set_kondisi(kondisi_baru)
	cuaca_diperbarui.emit(kondisi_baru)


## Paksa kondisi tanpa jaringan (untuk tes + foto tiap kondisi).
## Tidak menyentuh flag sudah_diminta (izin asli tetap sekali per sesi).
func paksa_kondisi(kondisi_baru: String) -> void:
	_terapkan(kondisi_baru)
