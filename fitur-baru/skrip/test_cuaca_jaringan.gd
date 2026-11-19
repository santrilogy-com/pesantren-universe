extends Node
## Tes jaringan Open-Meteo dari Godot (Wulan, 17 Nov 2026).
## Headless: godot --headless --path . test_cuaca_jaringan.tscn
## Membuktikan apakah HTTPRequest Godot di VM ini mencapai
## api.open-meteo.com (curl shell BISA — lihat status doc).
## Hasil yang diharapkan dari pengalaman lama: GAGAL (proxy) — ini
## BUKAN bukti kode salah; verifikasi akhir tetap di HP Mas.

var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 12
	_http.request_completed.connect(_on_selesai)
	add_child(_http)
	var err := _http.request("https://api.open-meteo.com/v1/forecast?latitude=-7.65&longitude=112.90&current=weather_code")
	print("JARINGAN request() err=" + str(err))
	await get_tree().create_timer(20.0).timeout
	print("JARINGAN TIMEOUT tanpa jawaban")
	get_tree().quit(1)


func _on_selesai(result: int, kode_http: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("JARINGAN result=%d http=%d body=%s" % [result, kode_http, body.get_string_from_utf8().left(200)])
	get_tree().quit(0 if result == HTTPRequest.RESULT_SUCCESS and kode_http == 200 else 1)
