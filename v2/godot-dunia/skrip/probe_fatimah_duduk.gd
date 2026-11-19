extends Node
## Probe Sinta (19 Nov 2026, koreksi meja): apakah Fatimah BENAR-BENAR
## duduk saat adegan belajar? Foto m1 putri terlihat berdiri padahal
## guru_duduk=true — ukur angkanya: visual_y + kepala_y sebelum/sesudah.
## Jalankan: HOME=/tmp/iso-probe DISPLAY=:96 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/probe_fatimah_duduk.tscn

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}


func _ready() -> void:
	get_window().size = Vector2i(1280, 720)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putri"
	_main._save["nama"] = "Foto Misi"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	_main._save["rb_chat_pos"] = ""
	_main._save["rb_chat_modul"] = 0
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Misi")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame
	var guru: Node = _main._fatimah
	var pos_guru := Vector3(140, 0, 16)
	guru.position = pos_guru
	_main._player.global_position = pos_guru + Vector3(0, 0, 4)
	_main._pos_legal_terakhir = pos_guru + Vector3(0, 0, 4)
	for i in 10:
		await get_tree().process_frame
	var kepala0 := _main._fatimah._rig.get("kepala") as Node3D
	print("PROBE sebelum: duduk=%s visual_y=%.3f kepala_y=%.3f" % [str(guru.sedang_duduk_belajar()), guru._visual.position.y, kepala0.global_position.y])
	_main._mulai_adegan_belajar()
	_main._manajer_misi.buka_ruang_belajar("Ustzh. Fatimah", _main._save)
	await get_tree().create_timer(2.0).timeout
	var kepala := _main._fatimah._rig.get("kepala") as Node3D
	print("PROBE sesudah 2dtk: duduk=%s visual_y=%.3f visual_rot_x=%.3f kepala_y=%.3f guru_y=%.3f" % [str(guru.sedang_duduk_belajar()), guru._visual.position.y, guru._visual.rotation.x, kepala.global_position.y, guru.global_position.y])
	_main._manajer_misi.tutup_semua()
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	SantriSave.save_data(_main._save)
	print("PROBE SELESAI — save dipulihkan")
	get_tree().quit()
