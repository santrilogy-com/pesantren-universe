extends Node
## Foto ulang dialog v2 — DIALOG SAJA, bingkai landscape (Sinta, 19 Nov 2026).
## Mas protes foto v1 (13:56 WIB): "Gambar 1 kok tidak fullscreen?
## Malah mojok gitu."
## Penyebab v1: harness minimal membuat DialogMisi mentah di CanvasLayer
## sendiri — tanpa ManajerUIMisi._pusatkan() dialog memakai anchor
## default (0,0 = pojok kiri-atas) + ukuran minimum, dan jendela
## portrait 720x1560 membuat panel kecil itu makin tenggelam di latar
## kosong. Di game asli manajer menaruh dialog di TENGAH layar
## (anchor 0.5/0.5, offset ±lebar/2, ±tinggi/2; 660x560 desain di
## 1280x720) — BUKAN tengah-bawah (koreksi atas laporan sebelumnya).
## Perbaikan: pakai ManajerUIMisi ASLI + buka_dialog("putra") (jalur
## produksi persis seperti main.gd), jendela landscape 1280x720
## (konvensi foto tim), nama baru dialog-v2-implementasi-v2.png.
## F2/F3 (popup/banner v1) tidak difoto ulang — sudah diterima Mas.
## Jalankan di Xvfb :95 + --audio-driver Dummy:
##   DISPLAY=:95 godot --audio-driver Dummy --path . --resolution 1280x720 skrip/foto_ui_teks_popup_v2_minimal.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"


func _foto(nama: String) -> void:
	for i in 15:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	for i in 3:
		await get_tree().process_frame

	# Latar pengganti dunia: krem-pasir terang (siang).
	var latar := ColorRect.new()
	latar.color = Color("#d8cfba")
	latar.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(latar)

	# Manajer ASLI (jalur produksi persis seperti main.gd): ia yang
	# menaruh dialog di tengah layar + menampilkan dim.
	var manajer := ManajerUIMisi.new()
	add_child(manajer)
	for i in 3:
		await get_tree().process_frame
	manajer.buka_dialog("putra")
	# Tunggu layout + animasi masuk (0.18 dtk) selesai.
	for i in 30:
		await get_tree().process_frame
	print("FOTO-CEK dialog: visible=%s rect=%s dim=%s" % [
		str(manajer._dialog.visible),
		str(manajer._dialog.get_global_rect()),
		str(manajer._dim.visible),
	])
	await _foto("dialog-v2-implementasi-v2.png")

	print("FOTO DIALOG V2 (V2) SELESAI")
	get_tree().quit()
