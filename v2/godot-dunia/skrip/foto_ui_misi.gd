extends Node
## Foto BUKTI implementasi 4 UI misi (Raka, 18 Nov 2026 — mockup
## DI-ACC Mas 18:58 WIB: dialog-aqsal-v2, ruang-belajar-v1,
## tes-kenaikan-v1, panel-misi-v1).
## F1: dialog Ust. Aqsal M (langkah 2, dekat Kyai) — 5 babak, TEKS DRAF.
## F2: Ruang Belajar Modul 01 (langkah 5, dekat Ust. Sanusi) — Materi.
## F3: Tes Kenaikan N1.T (langkah 6, di venue Surau) — 10 soal.
## F4: Panel Misi (✕ tanpa misi dekat, di spawn) — gelar + progres.
## Nama file BARU (ui-misi-*.png) — mockup di folder yang sama JANGAN
## ditimpa. Foto juga MENGETES routing _on_interact (print panel yang
## terbuka); bila routing gagal, panel dibuka langsung via manajer
## (dicatat di log) supaya foto tetap membuktikan tampilan panel.
## Jalankan di Xvfb :98 (layar 800x1700, muat portrait 720x1560):
##   DISPLAY=:98 godot --path . skrip/foto_ui_misi.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-misi/"

var _main: Node
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _onboarding_asli := {}


func _foto(nama: String) -> void:
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _dekat_npc(npc: Node3D) -> void:
	# Teleport pemain 1,5 m di selatan NPC (masih dalam radius 3,5 m).
	var pos: Vector3 = npc.global_position
	_main._teleport_player(Vector3(pos.x, 0, pos.z + 1.5), PI)
	for i in 10:
		await get_tree().process_frame


func _set_langkah(n: int) -> void:
	var ob := Onboarding.baca(_main._save)
	ob["langkah"] = n
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(720, 1560)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# SIMPAN save asli (pola foto_hud_v3.gd — jangan kontaminasi
	# santri.json; dipulihkan sebelum quit).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	_onboarding_asli = (_main._save.get("onboarding", {}) as Dictionary).duplicate()
	# ISOLASI: putra, flag petunjuk true (pop-up tidak menutupi foto),
	# onboarding langkah 2 (dialog). Nama foto, ig kosong (offline).
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Misi"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 2, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Misi")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	for i in 3:
		await get_tree().process_frame

	# F1: dialog — dekat Kyai, langkah 2, ✕.
	await _dekat_npc(_main._kyai)
	_main._on_interact()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK F1 dialog: panel='%s' (harap dialog)" % _main._manajer_misi.panel_terbuka())
	if _main._manajer_misi.panel_terbuka() != "dialog":
		_main._manajer_misi.buka_dialog("putra")
		print("FOTO-CEK F1: routing gagal, panel dibuka langsung")
	await _foto("ui-misi-dialog.png")
	_main._manajer_misi.tutup_semua()
	for i in 5:
		await get_tree().process_frame

	# F2: ruang belajar — langkah 5, dekat Ust. Sanusi (lokasi acak).
	_set_langkah(5)
	await _dekat_npc(_main._sanusi)
	_main._on_interact()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK F2 ruang belajar: panel='%s' (harap ruang_belajar)" % _main._manajer_misi.panel_terbuka())
	if _main._manajer_misi.panel_terbuka() != "ruang_belajar":
		_main._manajer_misi.buka_ruang_belajar("Ust. Sanusi")
		print("FOTO-CEK F2: routing gagal, panel dibuka langsung")
	await _foto("ui-misi-ruang-belajar.png")
	_main._manajer_misi.tutup_semua()
	for i in 5:
		await get_tree().process_frame

	# F3: tes kenaikan — langkah 6, di venue Surau (0,-14), ✕.
	_set_langkah(6)
	_main._teleport_player(Vector3(0, 0, -14), PI)
	for i in 10:
		await get_tree().process_frame
	_main._on_interact()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK F3 tes: panel='%s' (harap tes)" % _main._manajer_misi.panel_terbuka())
	if _main._manajer_misi.panel_terbuka() != "tes":
		_main._manajer_misi.buka_tes("N1")
		print("FOTO-CEK F3: routing gagal, panel dibuka langsung")
	await _foto("ui-misi-tes.png")
	_main._manajer_misi.tutup_semua()
	for i in 5:
		await get_tree().process_frame

	# F4: panel misi — langkah 5 (bukan 6, supaya venue tidak menang),
	# di spawn (-4,14), tidak ada misi dekat, ✕.
	_set_langkah(5)
	_main._teleport_player(PesantrenBuilder.SPAWN, PI)
	for i in 10:
		await get_tree().process_frame
	_main._on_interact()
	for i in 10:
		await get_tree().process_frame
	print("FOTO-CEK F4 panel misi: panel='%s' (harap panel_misi)" % _main._manajer_misi.panel_terbuka())
	if _main._manajer_misi.panel_terbuka() != "panel_misi":
		_main._manajer_misi.buka_panel_misi(_main._save)
		print("FOTO-CEK F4: routing gagal, panel dibuka langsung")
	await _foto("ui-misi-panel.png")
	_main._manajer_misi.tutup_semua()

	# Pulihkan save asli sebelum quit.
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	_main._save["onboarding"] = _onboarding_asli
	SantriSave.save_data(_main._save)
	print("FOTO UI MISI SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit()
