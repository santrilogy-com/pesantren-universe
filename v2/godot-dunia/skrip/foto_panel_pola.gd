extends Node
## Foto verifikasi baris "Pola misi" Panel Misi (Tara, 19 Nov 2026 —
## perbaikan terakhir sebelum gate: "→" U+2192 tofu di web diganti
## "›" U+203A di panel_misi_ui.gd:352). Pola foto_panel_arab.gd
## (main.tscn asli) tapi HANYA Panel Misi + gulir ke baris pola —
## baris itu ada di ujung _tambah_strip_tugas(), di bawah lipatan
## pada tangkapan panel biasa. Web-faithful: jalankan via
## foto-web-pola.sh (mount namespace tanpa font sistem, Xvfb :95).
##   bash foto-web-pola.sh   (log: foto-panel-pola-web.log)

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _tag := "web"


func _cari_label_pola(node: Node) -> Label:
	if node is Label and String((node as Label).text).begins_with("Pola misi"):
		return node as Label
	for anak in node.get_children():
		var ketemu := _cari_label_pola(anak)
		if ketemu != null:
			return ketemu
	return null


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

	# Panel misi (sama seperti foto_panel_arab.gd §5).
	_main._manajer_misi.buka_panel_misi({"misi_selesai": ["M1"], "tes_lulus": [], "tugas_selesai": []})
	await _tunggu(10)
	var panel: PanelMisiUI = _main._manajer_misi._panel_misi
	# Cari label "Pola misi" di _konten, gulir supaya tepat terlihat.
	# V2 (19 Nov 2026): baris pola kini HBox segmen (› emas) — cari
	# rekursif, bukan hanya anak langsung _konten.
	var label_pola: Label = _cari_label_pola(panel._konten)
	if label_pola == null:
		print("FOTO-CEK pola: LABEL TIDAK KETEMU")
	else:
		print("FOTO-CEK pola: teks='%s'" % label_pola.text)
		var gulung: ScrollContainer = panel._gulung
		var atas_gulung := gulung.get_global_rect().position.y
		var y_label := label_pola.get_global_rect().position.y
		# Posisi label relatif terhadap isi gulung (scroll saat ini 0).
		gulung.scroll_vertical = int(y_label - atas_gulung - 300)
		print("FOTO-CEK pola: scroll_vertical=%d" % gulung.scroll_vertical)
	await _tunggu(10)
	await _foto("panel-pola-misi-%s.png" % _tag)
	# Cadangan: gulir ke bawah mentah (maks) — baris pola di dekat
	# ujung _tambah_strip_tugas(), kartu bagian-berikut sesudahnya.
	panel._gulung.scroll_vertical = 100000
	await _tunggu(10)
	await _foto("panel-pola-misi-bawah-%s.png" % _tag)
	print("FOTO-CEK selesai")
	get_tree().quit()
