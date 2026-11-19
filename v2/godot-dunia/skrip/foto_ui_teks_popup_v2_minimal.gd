extends Node
## Foto verifikasi implementasi UI teks + pop-up v2 — ADEGAN MINIMAL
## (Sinta, 19 Nov 2026). BEDA dengan foto_ui_teks_popup_v2.gd: skrip
## itu memuat main.tscn SELURUHNYA dan 2× gagal selesai dalam 400 dtk
## di bawah llvmpipe (startup dunia 3D saja tidak selesai — log hanya
## berisi banner engine + OpenGL; TIDAK ADA satu pun PNG). Pola ini
## mengikuti foto_sarung_mekar_v2.gd (Kirana): adegan minimal tanpa
## dunia 3D — hanya UI ASLI yang difoto: PesantrenUI sungguhan
## (pop-up + banner) + DialogMisi sungguhan. Semua panel/animasi yang
## difoto adalah kode produksi, bukan tiruan.
## Latar: ColorRect krem-pasir (#d8cfba) pengganti dunia siang — panel
## gelap + rim emas tetap terbaca seperti di atas dunia; posisi/ukuran
## panel SAMA karena semuanya berjangkar ke viewport 720x1560.
## Jalankan di Xvfb :97 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:97 godot --path . skrip/foto_ui_teks_popup_v2_minimal.tscn
## Nama file SAMA dengan skrip dunia-penuh (belum ada yang berhasil
## dibuat) — jangan timpa foto lain.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _ui: PesantrenUI


func _foto(nama: String) -> void:
	for i in 15:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(720, 1560)
	for i in 3:
		await get_tree().process_frame

	# Latar pengganti dunia: krem-pasir terang (siang).
	var latar := ColorRect.new()
	latar.color = Color("#d8cfba")
	latar.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(latar)

	# UI ASLI (bukan tiruan): _ready-nya membangun login + HUD +
	# panel misi + peta + pop-up + banner + overlay + stempel.
	_ui = PesantrenUI.new()
	add_child(_ui)
	for i in 3:
		await get_tree().process_frame

	# Sembunyikan semua yang bukan objek foto: form login, overlay
	# putar-HP, dan semua anak _hud KECUALI dim + panel pop-up.
	# PENTING: _hud sendiri hidden saat dibuat (HUD baru tampil saat
	# _masuk_pesantren di game asli) — tampilkan di sini supaya
	# pop-up (anak _hud) ikut ter-render.
	_ui._login_panel.visible = false
	_ui._hud.visible = true
	_ui._tutup_rotate_overlay()
	for anak in _ui._hud.get_children():
		if anak != _ui._petunjuk_dim and anak != _ui._petunjuk_panel:
			anak.visible = false
	print("FOTO-CEK UI siap: dim=%s panel=%s banner=%s" % [
		str(_ui._petunjuk_dim != null),
		str(_ui._petunjuk_panel != null),
		str(_ui._petunjuk_misi_banner != null),
	])

	# F2: pop-up PETUNJUK TOMBOL (jalur produksi yang sama seperti
	# saat pemain baru masuk: coba_tampilkan_petunjuk_awal).
	_ui.coba_tampilkan_petunjuk_awal(false)
	print("FOTO-CEK F2 popup visible=%s" % str(_ui.is_petunjuk_visible()))
	# DEBUG (Sinta, 19 Nov 2026): foto F2 pertama KOSONG (panel+dim
	# tidak ter-render padahal visible=true) — cetak state hidup
	# sebelum jepret supaya penyebabnya ketahuan, bukan ditebak.
	for i in 30:
		await get_tree().process_frame
	print("DBG popup: hud_vis=%s hud_size=%s dim_vis=%s dim_mod=%.2f panel_vis=%s panel_mod=%.2f panel_rect=%s tween_valid=%s" % [
		str(_ui._hud.visible), str(_ui._hud.size),
		str(_ui._petunjuk_dim.visible), _ui._petunjuk_dim.modulate.a,
		str(_ui._petunjuk_panel.visible), _ui._petunjuk_panel.modulate.a,
		str(_ui._petunjuk_panel.get_global_rect()),
		str(_ui._tween_petunjuk != null and _ui._tween_petunjuk.is_valid()),
	])
	# DEBUG tinggi: kenapa panel 1621 kanvas, bukan ~460 isi?
	var _dbg_panel := _ui._petunjuk_panel
	print("DBG popup-min: panel_min=%s" % str(_dbg_panel.get_minimum_size()))
	for _c in _dbg_panel.get_children():
		print("DBG popup-min: anak %s min=%s size=%s" % [_c.get_class(), str(_c.get_minimum_size()), str(_c.size)])
		for _g in _c.get_children():
			print("DBG popup-min:   cucu %s min=%s size=%s" % [_g.get_class(), str(_g.get_minimum_size()), str(_g.size)])
	await _foto("popup-v2-implementasi.png")

	# F3: banner misi (tutup pop-up dulu, lalu jalur produksi
	# show_petunjuk_misi seperti langkah 2 santri baru).
	_ui._tutup_petunjuk()
	for i in 3:
		await get_tree().process_frame
	_ui.show_petunjuk_misi(false)
	print("FOTO-CEK F3 banner visible=%s" % str(_ui._petunjuk_misi_banner.visible))
	await _foto("banner-v2-implementasi.png")
	_ui.hide_petunjuk_misi()

	# F1: dialog misi — UI utama disembunyikan, DialogMisi ASLI di
	# CanvasLayer sendiri (lapis 20, di atas UI) seperti di game.
	_ui.visible = false
	var lapis := CanvasLayer.new()
	lapis.layer = 20
	add_child(lapis)
	var dlg := DialogMisi.new()
	lapis.add_child(dlg)
	dlg.tampilkan("putra")
	print("FOTO-CEK F1 dialog visible=%s teks=%s" % [
		str(dlg.visible), str(_ada_teks(dlg, "Ust. Aqsal M"))])
	await _foto("dialog-v2-implementasi.png")

	print("FOTO UI TEKS POPUP V2 (MINIMAL) SELESAI")
	get_tree().quit()


func _ada_teks(akar: Node, teks: String) -> bool:
	if akar is Label and (akar as Label).text.contains(teks):
		return true
	if akar is Button and (akar as Button).text.contains(teks):
		return true
	for anak in akar.get_children():
		if _ada_teks(anak, teks):
			return true
	return false
