extends Node
## Foto verifikasi Panel Misi v2 ATAS (Tara, 19 Nov 2026 — konsep
## ACC Mas 19:06 WIB): baris aktif N1.2 + chip AKTIF isi penuh +
## kartu gelar + bilah progres gradien. Pola foto_panel_pola.gd
## (main.tscn asli, web-faithful via foto-web-v2.sh).
##   bash foto-web-v2.sh   (log: foto-panel-misi-v2-web.log)

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _tag := "web"


func _foto(nama: String) -> void:
	for i in 15:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tag="):
			_tag = arg.trim_prefix("--tag=")
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	await _tunggu(5)
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await _tunggu(3)
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Panel"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Panel")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	await _tunggu(3)
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	await _tunggu(3)

	# Panel misi — gulir 0 (atas): kartu gelar + N1.1/N1.2 + AKTIF.
	_main._manajer_misi.buka_panel_misi({"misi_selesai": ["M1"], "tes_lulus": [], "tugas_selesai": []})
	await _tunggu(10)
	var panel: PanelMisiUI = _main._manajer_misi._panel_misi
	panel._gulung.scroll_vertical = 0
	print("FOTO-CEK v2-atas: scroll_vertical=0")
	await _tunggu(10)
	await _foto("panel-misi-v2-atas-%s.png" % _tag)
	print("FOTO-CEK selesai")
	get_tree().quit(0)
