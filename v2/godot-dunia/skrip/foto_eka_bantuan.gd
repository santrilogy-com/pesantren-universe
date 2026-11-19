extends Node
## Foto BUKTI Eka (bantu Raka, 18 Nov 2026 — Mas: "Dia kerja sendirian"):
## F1: tombol "Main Bersama" di HUD — sudah dipindah Cakra ke (216,116),
## kanan minimap; buktikan terlihat penuh. F2: peta besar dibuka di zoom
## 2.0x dengan pemain di Asrama Putra — label "ASRAMA PUTRA" harus
## terbaca + markernya di minimap. Jalankan TANPA --headless:
##   xvfb-run -a godot --path . skrip/foto_eka_bantuan.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _main: Node


func _foto(nama: String) -> void:
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (pola test_kamera.gd): kosongkan ig supaya offline,
	# tombol "Main Bersama" tampil dalam keadaan offline.
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto Eka")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# F1: HUD gameplay — pemain di spawn putra, kamera game normal.
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	for i in 10:
		await get_tree().process_frame
	var btn: Button = _main._ui._mp_gabung_btn
	var mm: Control = _main._ui._minimap
	print("FOTO-CEK tombol: rect=%s visible=%s | minimap: rect=%s | tumpang=%s" % [
		str(btn.get_global_rect()) if btn != null else "null",
		str(btn.visible) if btn != null else "?",
		str(mm.get_global_rect()) if mm != null else "null",
		str(btn.get_global_rect().intersects(mm.get_global_rect())) if btn != null and mm != null else "?"])
	await _foto("eka-tombol-main-bersama.png")
	# F2: peta besar zoom 2.0x, pemain di Asrama Putra.
	_main._teleport_player(Vector3(-24, 0, 14), 0.0)
	for i in 10:
		await get_tree().process_frame
	_main._ui.open_peta(_main._data_peta())
	_main._ui._peta_zoom_masuk()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK peta: zoom=%.1f label=%.1fx" % [_main._ui._peta_map.zoom, _main._ui._peta_zoom_idx])
	await _foto("eka-peta-asrama-putra.png")
	get_tree().quit()
