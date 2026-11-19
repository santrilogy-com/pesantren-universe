extends Node
## TES CEK PCK 20261119-4 — Eka (gate). Membuktikan pck STAGED ronde ini
## (gabungan pck/part-00.bin + part-01.bin) benar berisi kode baru —
## BUKAN sekadar source tree. Bukti pembeda: stempel_build_teks()
## harus ADA dan mengembalikan "Build 20261119-4" (stempel baru ronde
## ini; pack lama TIDAK punya stempel ini).
## Headless, tanpa input.

const PCK := "/tmp/pck-gabung-20261119-4.bin"

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("PCK4 LULUS: ", nama)
	else:
		_gagal += 1
		print("PCK4 GAGAL: ", nama)


func _ready() -> void:
	var ok := ProjectSettings.load_resource_pack(PCK)
	_cek("load_resource_pack pck-gabung-20261119-4.bin", ok)
	var scr = load("res://scripts/ui.gd")
	_cek("load res://scripts/ui.gd dari pack", scr != null)
	if scr == null:
		print("TES PCK4: LULUS=", _lulus, " GAGAL=", _gagal)
		get_tree().quit(1)
		return
	var ui = scr.new()
	_cek("ui dari pack PUNYA stempel_build_teks", ui.has_method("stempel_build_teks"))
	if ui.has_method("stempel_build_teks"):
		var teks: String = ui.stempel_build_teks()
		print("PCK4 stempel dari pack: '", teks, "'")
		_cek("stempel pack == 'Build 20261119-4'", teks == "Build 20261119-4")
	# Bukti tambahan: pack berisi kualitas adaptif + ikon HUD baru.
	_cek("pack PUNYA skrip kualitas_adaptif", ResourceLoader.exists("res://scripts/kualitas_adaptif.gd"))
	_cek("pack PUNYA skrip ikon_hud", ResourceLoader.exists("res://scripts/ikon_hud.gd"))
	print("TES PCK4: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)
