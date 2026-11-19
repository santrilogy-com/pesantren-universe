extends Node
## Tes reroute BUBBLE-ML oleh Raka — jalur lengkap main.gd -> feed.
## _on_chat_sent (pemain) + npc.say() (Bilal + Kyai, lewat sinyal
## pesan) harus memunculkan baris di feed ML ui.gd, dan bubble 3D
## tetap mati. Panel riwayat tidak dicek di sini (sudah di tes Gita).
## godot --headless --path . test_reroute_bubble.tscn

var _main: Node
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		print("LULUS " + nama)
	else:
		_gagal += 1
		print("GAGAL " + nama)


func _baris_terakhir() -> Dictionary:
	var baris: Array = _main._ui._feed_baris
	if baris.is_empty():
		return {}
	var d: Dictionary = baris[baris.size() - 1]
	var row: HBoxContainer = d["row"]
	var nama_lbl: Label = row.get_child(0)
	var teks_lbl: Label = row.get_child(1)
	return {"nama": nama_lbl.text, "teks": teks_lbl.text}


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes reroute bubble ML")
	await get_tree().process_frame
	await get_tree().process_frame

	_cek("feed-kosong-awal", _main._ui.jumlah_pesan_melayang() == 0)
	# Penjaga regresi: _spawn_npcs() tidak boleh berhenti di tengah
	# (pernah: connect sinyal sebelum _ui ada -> hanya Bilal yang spawn).
	_cek("npc-lengkap-5", _main._npcs.size() == 5)
	# 1. Pesan pemain lewat _on_chat_sent (jalur panel kirim).
	_main._on_chat_sent("Halo dari pemain")
	await get_tree().process_frame
	_cek("pemain-feed-1-baris", _main._ui.jumlah_pesan_melayang() == 1)
	var b1: Dictionary = _baris_terakhir()
	# Label nama di feed memakai titik dua ("Tes:", lihat ui.gd).
	_cek("pemain-nama-teks", b1.get("nama") == "Tes:" and String(b1.get("teks")).begins_with("Halo dari pemain"))
	# 2. Pesan NPC Bilal lewat say() -> sinyal pesan -> feed.
	_main._npcs[0].say("Ayo sholat berjamaah di Surau!")
	await get_tree().process_frame
	_cek("bilal-feed-2-baris", _main._ui.jumlah_pesan_melayang() == 2)
	var b2: Dictionary = _baris_terakhir()
	_cek("bilal-nama-teks", b2.get("nama") == "Bilal:" and String(b2.get("teks")).begins_with("Ayo sholat berjamaah di Surau!"))
	# 3. Pesan Kyai lewat say() (jalur yang sama dengan _mulai_sholat).
	_main._npcs[2].say("Ayo sholat berjamaah — saya jadi imam.")
	await get_tree().process_frame
	_cek("kyai-feed-3-baris", _main._ui.jumlah_pesan_melayang() == 3)
	var b3: Dictionary = _baris_terakhir()
	_cek("kyai-nama-teks", b3.get("nama") == "Ust. Aqsal Murad:" and String(b3.get("teks")).begins_with("Ayo sholat berjamaah"))
	# 4. Bubble 3D tetap mati setelah semua pesan.
	_cek("bubble-pemain-mati", not _main._player._bubble.visible)
	_cek("bubble-bilal-mati", not _main._npcs[0]._bubble.visible)
	_cek("bubble-kyai-mati", not _main._npcs[2]._bubble.visible)
	if _gagal == 0:
		print("TES REROUTE BUBBLE: SEMUA LULUS")
	else:
		print("TES REROUTE BUBBLE: %d GAGAL" % _gagal)
	get_tree().quit(_gagal)
