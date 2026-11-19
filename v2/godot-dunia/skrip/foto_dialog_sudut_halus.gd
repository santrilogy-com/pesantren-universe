extends Node
## Foto verifikasi perbaikan sudut dialog — panggang latar 660x560
## (Sinta, 19 Nov 2026). Pola foto_ui_teks_popup_v2_minimal.gd:
## ManajerUIMisi ASLI + buka_dialog("putra"), jendela 1280x720.
## Output NAMA BARU: dialog-v2-sudut-halus.png (bukan menimpa
## dialog-v2-implementasi-v2.png — itu foto SEBELUM perbaikan).
## Jalankan di Xvfb :95 + --audio-driver Dummy:
##   DISPLAY=:95 godot --audio-driver Dummy --path . --resolution 1280x720 skrip/foto_dialog_sudut_halus.tscn

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

	var latar := ColorRect.new()
	latar.color = Color("#d8cfba")
	latar.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(latar)

	# Ukur biaya panggang 660x560: DialogMisi dibuat di _ready manajer
	# (buat_latar_gradien jalan di sana).
	var t0 := Time.get_ticks_msec()
	var manajer := ManajerUIMisi.new()
	add_child(manajer)
	for i in 3:
		await get_tree().process_frame
	var t1 := Time.get_ticks_msec()
	print("FOTO-CEK waktu bangun manajer+dialog (termasuk panggang 660x560): %d ms" % (t1 - t0))
	manajer.buka_dialog("putra")
	for i in 30:
		await get_tree().process_frame
	print("FOTO-CEK dialog: visible=%s rect=%s dim=%s" % [
		str(manajer._dialog.visible),
		str(manajer._dialog.get_global_rect()),
		str(manajer._dim.visible),
	])
	await _foto("dialog-v2-sudut-halus.png")

	print("FOTO DIALOG SUDUT HALUS SELESAI")
	get_tree().quit()
