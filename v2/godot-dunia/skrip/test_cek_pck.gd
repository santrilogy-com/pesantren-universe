extends Node
## TES CEK PCK — Tara (UI). Membuktikan apakah pck staging Deploy B
## (716a5831, digabung dari pck/part-00.bin + part-01.bin) benar berisi
## perbaikan overlay PUTAR HP-MU — BUKAN sekadar source tree.
## Cara: mount pck sebagai resource pack (load_resource_pack), lalu
## load res://scripts/ui.gd — pack MENIMPA filesystem, jadi yang
## diuji adalah ui.gd DI DALAM pck. Bukti pembeda: pack TIDAK punya
## stempel build (ditambah Xam 19 Nov 08:31, SETELAH staging) —
## has_method("stempel_build_teks") harus FALSE bila yang dimuat
## benar dari pack. Headless, tanpa input.

const PCK := "/home/hatch/workspace/.logs-gate-18nov/pck-gabung.bin"

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("PCK LULUS: ", nama)
	else:
		_gagal += 1
		print("PCK GAGAL: ", nama)


func _ready() -> void:
	var ok := ProjectSettings.load_resource_pack(PCK)
	_cek("load_resource_pack pck-gabung.bin", ok)
	var scr = load("res://scripts/ui.gd")
	_cek("load res://scripts/ui.gd dari pack", scr != null)
	var ui = scr.new()
	_cek("ui dari pack TIDAK punya stempel (bukti pack, bukan fs)", not ui.has_method("stempel_build_teks"))
	_cek("ui dari pack TIDAK punya _build_stempel_build", not ui.has_method("_build_stempel_build"))
	_cek("ui dari pack PUNYA _build_rotate_overlay", ui.has_method("_build_rotate_overlay"))
	add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var ov = ui.get("_rotate_overlay")
	_cek("overlay _rotate_overlay ada", ov != null)
	if ov != null:
		_cek("overlay root IGNORE", ov.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		var anak_ignore := true
		var anak_stop := 0
		for c in ov.get_children():
			if c.mouse_filter != Control.MOUSE_FILTER_IGNORE:
				anak_stop += 1
		_cek("anak langsung overlay semua IGNORE (stop=0)", anak_stop == 0)
		# Turun satu tingkat: isi CenterContainer (box) + isi box.
		for c in ov.get_children():
			if c is CenterContainer:
				for d in c.get_children():
					if d is VBoxContainer:
						for e in d.get_children():
							if e is Button:
								_cek("tombol di box '" + e.text + "' STOP", e.mouse_filter == Control.MOUSE_FILTER_STOP)
							else:
								_cek("isi box '" + str(e) + "' IGNORE", e.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	print("TES PCK: LULUS=", _lulus, " GAGAL=", _gagal)
	get_tree().quit(0 if _gagal == 0 else 1)
