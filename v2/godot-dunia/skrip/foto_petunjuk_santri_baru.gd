extends Node
## Foto petunjuk misi santri baru (Raka, 18 Nov 2026 — perintah Mas
## 21:32 WIB: "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang").
## Jalankan TANPA --headless (headless membuat save_png null), pola
## skrip/foto_audit_lighting_20nov.gd:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . skrip/foto_petunjuk_santri_baru.tscn
## 1 shot: santri baru putra baru masuk dunia (langkah 1 -> 2), kamera
## game apa adanya (arah spawn menghadap Surau) + banner petunjuk di
## atas. Pop-up petunjuk tombol dimatikan (flag di save) supaya tidak
## menutupi tengah foto; MP diisolasi (ig kosong, pola test_v2.gd).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-misi/"

var _main: Node


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	_main._save["poin"] = 0
	_main._save["nama"] = "Tes"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 1, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._masuk_pesantren("Foto petunjuk santri baru")
	for i in 10:
		await get_tree().process_frame
	print("langkah=%d banner=%s teks='%s'" % [
		Onboarding.langkah_saat_ini(_main._save),
		str(_main._ui.is_petunjuk_misi_visible()),
		_main._ui.teks_petunjuk_misi(),
	])
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "petunjuk-santri-baru-putra.png")
	print("FOTO PETUNJUK SANTRI BARU SELESAI err=%d" % err)
	get_tree().quit(0)
