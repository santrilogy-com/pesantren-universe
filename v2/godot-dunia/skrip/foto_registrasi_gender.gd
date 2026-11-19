extends Node
## Foto form DAFTAR baru (Tara, 17 Nov 2026) — jalankan TANPA --headless
## (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_registrasi_gender.tscn
## Dua foto: portrait HP 390x844 (pemilih gender terlihat penuh) +
## landscape 844x390 (mode kompak). Form diisi contoh supaya foto
## menunjukkan keadaan nyata (nama + akun IG + putri terpilih).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-registrasi-gender/"

var _main: Node


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	var ui = _main._ui
	ui._tampil_daftar()
	ui._reg_nama_input.text = "Tes Tara"
	ui._reg_ig_input.text = "tes.tara.231139"
	ui._on_gender_dipilih("putri")
	# Portrait HP. Resize ke portrait memicu _update_rotate_overlay()
	# -> overlay "PUTAR HP-MU" muncul (perilaku NORMAL game di layar
	# sentuh portrait, bukan bug form). Foto butuh form-nya terlihat:
	# tutup overlay seperti santri mengetuk "Tetap main portrait"
	# (ui._tutup_rotate_overlay) — HANYA skrip foto, logika game
	# tidak diubah. Dismiss bertahan sampai resize berikutnya, dan
	# _foto() tidak me-resize, jadi overlay tetap tertutup saat jepret.
	get_window().size = Vector2i(390, 844)
	for i in 10:
		await get_tree().process_frame
	ui._tutup_rotate_overlay()
	await _foto("daftar-gender-portrait.png")
	# Landscape HP (mode kompak).
	get_window().size = Vector2i(844, 390)
	for i in 10:
		await get_tree().process_frame
	await _foto("daftar-gender-landscape.png")
	print("FOTO REGISTRASI SELESAI")
	get_tree().quit(0)


func _foto(nama: String) -> void:
	for i in 20:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
