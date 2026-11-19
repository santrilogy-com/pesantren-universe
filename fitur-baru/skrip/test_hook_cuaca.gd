extends Node
## Tes hook cuaca Raka — _masuk_pesantren() membuat Cuaca + mulai()
## sekali, fallback cerah di luar web (headless, tanpa JavaScriptBridge).
## godot --headless --path . test_hook_cuaca.tscn

var _main: Node


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	var gagal := 0
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes hook cuaca")
	await get_tree().process_frame
	await get_tree().process_frame
	if _main._cuaca == null:
		gagal += 1
		print("FAIL hook-cuaca-ada: _cuaca null setelah masuk")
	else:
		print("LULUS hook-cuaca-ada")
	if _main._cuaca != null and _main._cuaca.sudah_diminta:
		print("LULUS hook-cuaca-diminta")
	else:
		gagal += 1
		print("FAIL hook-cuaca-diminta: sudah_diminta false")
	if _main._cuaca != null and _main._cuaca.get_parent() == _main:
		print("LULUS hook-cuaca-anak-main")
	else:
		gagal += 1
		print("FAIL hook-cuaca-anak-main")
	var langit: LangitDinamis = _main._pesantren["langit"]
	print("KONDISI: ", langit.get_kondisi())
	if langit.get_kondisi() == "cerah":
		print("LULUS hook-cuaca-fallback-cerah")
	else:
		gagal += 1
		print("FAIL hook-cuaca-fallback-cerah")
	# Panggil masuk kedua: mulai() tidak boleh prompt ulang / ganda.
	_main._masuk_pesantren("Tes hook cuaca ulang")
	await get_tree().process_frame
	if _main._cuaca != null and _main._cuaca.sudah_diminta:
		print("LULUS hook-cuaca-masuk-kedua-aman")
	else:
		gagal += 1
		print("FAIL hook-cuaca-masuk-kedua-aman")
	if gagal == 0:
		print("TES HOOK CUACA: SEMUA LULUS")
	else:
		print("TES HOOK CUACA: %d GAGAL" % gagal)
	get_tree().quit(gagal)
