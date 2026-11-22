extends Node
## TES CEK PCK 20261119-6 — Eka (gate). Membuktikan pck STAGED ronde ini
## (gabungan pck/part-00.bin + part-01.bin) benar berisi kode baru —
## BUKAN sekadar source tree. Bukti pembeda: stempel_build_teks()
## harus ADA dan mengembalikan "Build 20261119-6" (stempel baru ronde
## ini; pack lama TIDAK punya stempel ini). Bukti ronde -6: Ruang
## Belajar v4 TEKS — data_chat_modul_01.gd dari pack PUNYA
## POIN_TOTAL 40 + SPINE 28 node diawali "p1" + fase_node().
## Headless, tanpa input.

const PCK := "/tmp/pck-gabung-20261119-6.bin"

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
	_cek("load_resource_pack pck-gabung-20261119-6.bin", ok)
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
		_cek("stempel pack == 'Build 20261119-6'", teks == "Build 20261119-6")
	# Bukti ronde -6: Ruang Belajar v4 TEKS di data_chat_modul_01.gd pack.
	var dscr = load("res://scripts/ui_misi/data_chat_modul_01.gd")
	_cek("load res://scripts/ui_misi/data_chat_modul_01.gd dari pack", dscr != null)
	if dscr != null:
		_cek("POIN_TOTAL pack == 40 (v4)", dscr.POIN_TOTAL == 40)
		var spine: Array = dscr.SPINE
		_cek("SPINE pack 28 node, diawali 'p1'", spine.size() == 28 and spine[0] == "p1")
		var ada_fase := false
		for m in dscr.get_script_method_list():
			if m.get("name", "") == "fase_node":
				ada_fase = true
		_cek("data_chat_modul_01.gd pack PUNYA fase_node (v4)", ada_fase)
	# Bukti ronde -5 tetap ada: drape v8 (_lap_pangkuan) di player.gd pack.
	var pscr = load("res://scripts/player.gd")
	_cek("load res://scripts/player.gd dari pack", pscr != null)
	if pscr != null:
		var ada_lap := false
		for m in pscr.get_script_method_list():
			if m.get("name", "") == "_lap_pangkuan":
				ada_lap = true
		_cek("player.gd pack PUNYA _lap_pangkuan (drape v8)", ada_lap)
	print("TES PCK4: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)
