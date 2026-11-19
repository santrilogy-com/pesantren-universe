extends Node
## Foto verifikasi bintang Panel Misi (Eka, gate 20261119-4): bintang
## kosong Panel Misi digambar ulang Tara (stroke TEBAL_TIPIS — dulu
## garis tebal terbaca seperti bintang isi; foto lama Mas 18:03).
## Pola foto_panel_pola.gd tapi TANPA gulir — baris bintang ada di
## kepala panel (di atas lipatan). Web-faithful: jalankan via
## foto-web-bintang.sh (mount namespace tanpa font sistem, Xvfb :95).
##   bash foto-web-bintang.sh   (log: gate-20261119-4/foto-panel-bintang-web.log)

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


func _cari_label_bintang(n: Node) -> Label:
	if n is Label and String((n as Label).text).contains("bintang"):
		return n as Label
	for ch in n.get_children():
		var r := _cari_label_bintang(ch)
		if r != null:
			return r
	return null


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
	_main._save["nama"] = "Foto Bintang"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Bintang")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	await _tunggu(3)
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	await _tunggu(3)

	# Panel misi — TANPA gulir (baris bintang di kepala panel).
	_main._manajer_misi.buka_panel_misi({"misi_selesai": ["M1"], "tes_lulus": [], "tugas_selesai": []})
	await _tunggu(10)
	var panel: PanelMisiUI = _main._manajer_misi._panel_misi
	var lbl := _cari_label_bintang(panel)
	if lbl == null:
		print("FOTO-CEK bintang: LABEL TIDAK KETEMU")
	else:
		print("FOTO-CEK bintang: teks='%s'" % lbl.text)
	print("FOTO-CEK bintang: scroll_vertical=%d" % panel._gulung.scroll_vertical)
	await _tunggu(10)
	await _foto("panel-bintang-%s.png" % _tag)
	print("FOTO-CEK selesai")
	get_tree().quit()
