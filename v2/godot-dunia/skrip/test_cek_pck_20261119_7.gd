extends Node
## TES CEK PCK 20261119-7 — Eka (gate). Membuktikan pck STAGED ronde ini
## (gabungan pck/part-00.bin + part-01.bin) benar berisi kode baru —
## BUKAN sekadar source tree. Bukti pembeda: stempel_build_teks()
## harus ADA dan mengembalikan "Build 20261119-7" (stempel baru ronde
## ini; pack lama TIDAK punya stempel ini). Bukti ronde -7: Ruang
## Belajar v4 Modul 02/03/04 — data_chat_modul_02/03/04.gd dari pack
## PUNYA POIN_TOTAL 40 + SPINE (24/28/28) diawali "p1" + fase_node,
## dan data_modul_02/03/04.gd dari pack PUNYA kuis_soal() 10 soal.
## Headless, tanpa input.

const PCK := "/tmp/pck-gabung-20261119-7.bin"

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("PCK4 LULUS: ", nama)
	else:
		_gagal += 1
		print("PCK4 GAGAL: ", nama)


func _cek_chat(nomor: String, spine_ukuran: int) -> void:
	var jalan := "res://scripts/ui_misi/data_chat_modul_" + nomor + ".gd"
	var dscr = load(jalan)
	_cek("load " + jalan + " dari pack", dscr != null)
	if dscr == null:
		return
	_cek("M" + nomor + " POIN_TOTAL pack == 40 (v4)", dscr.POIN_TOTAL == 40)
	var spine: Array = dscr.SPINE
	_cek("M" + nomor + " SPINE pack " + str(spine_ukuran) + " node, diawali 'p1'", spine.size() == spine_ukuran and spine[0] == "p1")
	var ada_fase := false
	for m in dscr.get_script_method_list():
		if m.get("name", "") == "fase_node":
			ada_fase = true
	_cek("M" + nomor + " data_chat_modul pack PUNYA fase_node (v4)", ada_fase)


func _cek_modul(nomor: String) -> void:
	var jalan := "res://scripts/ui_misi/data_modul_" + nomor + ".gd"
	var dscr = load(jalan)
	_cek("load " + jalan + " dari pack", dscr != null)
	if dscr == null:
		return
	var kuis: Array = dscr.kuis_soal()
	_cek("M" + nomor + " kuis_soal() pack == 10 soal", kuis.size() == 10)


func _ready() -> void:
	var ok := ProjectSettings.load_resource_pack(PCK)
	_cek("load_resource_pack pck-gabung-20261119-7.bin", ok)
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
		_cek("stempel pack == 'Build 20261119-7'", teks == "Build 20261119-7")
	# Bukti ronde -7: Ruang Belajar v4 Modul 02/03/04 di pack.
	_cek_chat("01", 28)
	_cek_chat("02", 24)
	_cek_chat("03", 28)
	_cek_chat("04", 28)
	_cek_modul("02")
	_cek_modul("03")
	_cek_modul("04")
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
