extends Node
## Foto konsep splash screen (Gilang, 19 Nov 2026) — 3 varian:
## A = gerbang tembok (14,0) + plakat "PESANTREN UNIVERSE" di atas pintu.
## B = Musholla Ar-Raudhah (134,-24) + plakat yang sama di bawah atap serambi.
## C = karakter (Kyai + santri pemain) di depan Surau — judul besar
##     ditambahkan di post (PIL + Baloo 2, lihat skrip/post_splash_c.py).
## KONSEP SAJA — tidak ada kode game yang diubah. Plakat dibuat di
## scene foto ini (runtime, anak _main) dan TIDAK masuk tree game.
## Jalankan (Xvfb privat :93, pola foto_halaman_putri_r4):
##   Xvfb :93 -screen 0 1280x720x24 &
##   DISPLAY=:93 <godot-4.7> --audio-driver Dummy --path . --resolution 1280x720 skrip/foto_splash_konsep.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/konsep/"
const TEKS_PLAKAT := "PESANTREN UNIVERSE"
const EMAS_TULIS := Color("#f2c14e")

var _main: Node
var _cam: Camera3D


func _lebar_teks(teks: String, font_size: int) -> float:
	var f: Font = Palette.FONT_GAME
	if f == null:
		return float(teks.length()) * 0.18
	return f.get_string_size(teks, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x * 0.01


## Plakat papan: bingkai emas + papan zamrud gelap + teks emas.
## `tebal_sumbu`: sumbu ketebalan papan ("x" = menghadap barat/timur,
## "z" = menghadap selatan/utara). Label diputar mengikuti hadap.
func _plakat(pos: Vector3, rot_y: float, tebal_sumbu: String, font_size: int) -> void:
	var label := Palette.label3d(TEKS_PLAKAT, pos, font_size, EMAS_TULIS, false)
	label.rotation.y = rot_y
	_main.add_child(label)
	var lebar := _lebar_teks(TEKS_PLAKAT, font_size) + 0.45
	var tinggi := 0.78
	var uk_emas := Vector3(0.06, tinggi + 0.14, lebar) if tebal_sumbu == "x" else Vector3(lebar, tinggi + 0.14, 0.06)
	var uk_zamrud := Vector3(0.08, tinggi, lebar - 0.15) if tebal_sumbu == "x" else Vector3(lebar - 0.15, tinggi, 0.08)
	# LAPISAN (dilihat dari sisi baca): label PALING DEPAN, lalu papan
	# zamrud, lalu bingkai emas PALING BELAKANG. Arah "belakang":
	# gerbang (hadap barat) -> +x (timur); musholla (hadap selatan) -> -z (utara).
	# (Run 1 salah: emas di depan zamrud + label tertimbun papan — teks tak terlihat.)
	var arah := Vector3(1, 0, 0) if tebal_sumbu == "x" else Vector3(0, 0, -1)
	var emas := Palette.box(uk_emas, pos + arah * 0.12, Palette.EMAS, 0.4)
	var zamrud := Palette.box(uk_zamrud, pos + arah * 0.06, Palette.ZAMRUD_GELAP)
	_main.add_child(emas)
	_main.add_child(zamrud)
	print("SPLASH plakat di %s rot=%.2f lebar_teks=%.2f papan=%.2f" % [str(pos), rot_y, lebar - 0.45, lebar])


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	# Paksa kamera foto jadi current (kamera game di-snap tiap teleport).
	_cam.make_current()
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	print("SPLASH %s: cam_saya current=%s pos=%s | cam_game pos=%s | pemain=%s di_belakang_cam=%s" % [
		nama, str(_cam.is_current()), str(_cam.global_position),
		str(_main._cam.global_position), str(_main._player.global_position),
		str(_cam.is_position_behind(_main._player.global_position)),
	])
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _sembunyikan_label_nama(node: Node) -> void:
	for l in node.find_children("*", "Label3D", true, false):
		(l as Label3D).visible = false


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	# Siang terang (jam 10 — pola foto taman putri r4).
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto splash konsep")
	for i in 3:
		await get_tree().process_frame
	# HUD bersih untuk splash: sembunyikan seluruh UI.
	# (Label nama pemain disembunyikan SETELAH tiap teleport — lihat
	# di bawah — karena teleport membangun ulang visual + label.)
	_main._ui.visible = false
	_main._ui._tutup_rotate_overlay()

	# --- Plakat A: gerbang (14,0), di atas pintu (pintu y 0..2.6,
	# balok gapura y 3.4..3.9) — muka barat, label hadap barat.
	_plakat(Vector3(13.56, 3.0, 0), -PI / 2.0, "x", 36)
	# --- Plakat B: musholla, gantung di bawah atap serambi
	# (atap y ~3.05, depan z=-16.1) — muka selatan, label hadap selatan.
	_plakat(Vector3(134, 2.55, -15.96), 0.0, "z", 36)

	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true

	# --- A: GERBANG. Santri pemain DI TENGAH JALAN menghadap gerbang
	# (run 1: pemain di rumput kiri jalan — pindah ke tengah jalan).
	# Bekukan pemain LANGSUNG setelah teleport: _process pemain
	# menghidupkan lagi label nama tiap frame (player.gd:2149) +
	# animasi menoleh — keduanya merusak foto (run 2-3: "Tes" tetap
	# terlihat meski sudah disembunyikan sebelum _foto).
	_main._teleport_player(Vector3(8, 0, 0.8), atan2(14.0 - 8.0, 0.0 - 0.8))
	_main._player.set_process(false)
	for i in 10:
		await get_tree().process_frame
	_sembunyikan_label_nama(_main._player)
	await _foto("konsep-splash-a-gerbang.png", Vector3(4, 2.6, 4), Vector3(14, 2.6, 0))

	# --- B: MUSHOLLA. Santri di halaman selatan, hadap pintu.
	# Run 2-3: pemain (138,-13) lalu (137,-15) TIDAK PERNAH masuk
	# frame (gambar B identik byte-per-byte) — pindah ke sumbu
	# kamera + kamera mundur/naik + bidik sedikit ke bawah.
	_main._teleport_player(Vector3(137.5, 0, -14.5), atan2(134.0 - 137.5, -19.0 - (-14.5)))
	# AKAR SNAP-BACK (run 2-4): pemain default PUTRA — _cek_batas
	# (main.gd:2316) menarik balik tiap frame posisi x>14 ke
	# _pos_legal_terakhir. Jangkar disetel ke posisi foto supaya
	# snap-back jadi no-op (skrip foto saja, bukan kode game).
	_main._pos_legal_terakhir = Vector3(137.5, 0, -14.5)
	_main._punya_pos_legal = true
	_main._player.set_process(false)
	for i in 10:
		await get_tree().process_frame
	_sembunyikan_label_nama(_main._player)
	await _foto("konsep-splash-b-musholla.png", Vector3(140, 3.0, -9), Vector3(134, 3.0, -23))

	# --- C: KARAKTER. Kyai + santri di PLAZA selatan tangga serambi
	# (run 1: keduanya di atas/di balik lantai serambi y~0.5 — Kyai
	# tampak jongkok di balik tepi platform). Kamera mundur + naik
	# supaya badan penuh terlihat, Surau tetap jadi latar.
	# Kyai MULAI dalam fase "duduk" baca kitab (patroli_kyai) — paksa
	# pose BERDIRI penuh (kaki/lutut/lengan + sarung via
	# _terapkan_pakaian snap) SEBELUM dibekukan, kalau tidak ia tetap
	# bersila (run 2).
	var kyai: Node = _main._kyai
	# Bersihkan frame dari NPC lain (run 5: Bilal masuk frame kiri +
	# label namanya terlihat). Bekukan + sembunyikan label + pindah
	# ke titik tunggu jauh di selatan (di luar frame). Kyai dilewati.
	for npc in _main._npcs:
		if npc == kyai:
			continue
		_sembunyikan_label_nama(npc)
		npc.global_position = Vector3(30, 0, 30)
		npc.set_process(false)
	kyai.global_position = Vector3(-1.5, 0, 2.0)
	kyai._visual.rotation.y = 0.0
	kyai._visual.position.y = 0.0
	kyai._visual.rotation.x = 0.0
	for sendi in [kyai._leg_l, kyai._leg_r, kyai._knee_l, kyai._knee_r, kyai._arm_l, kyai._arm_r, kyai._elbow_l, kyai._elbow_r]:
		(sendi as Node3D).rotation = Vector3.ZERO
	var kepala := kyai._rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.y = 0.0
	kyai._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)
	_sembunyikan_label_nama(kyai)
	_main._teleport_player(Vector3(1.0, 0, 2.5), 0.0)
	# BEKUKAN SEKARANG JUGA (sinkron, tanpa await): _process Kyai
	# fase "duduk" akan mengembalikan pose bersila dalam 1 frame
	# bila dibiarkan jalan; pemain juga dibekukan sebelum animasi
	# idle (siwak/menoleh) sempat jalan.
	kyai.set_process(false)
	_main._player.set_process(false)
	for i in 3:
		await get_tree().process_frame
	_sembunyikan_label_nama(_main._player)
	for i in 5:
		await get_tree().process_frame
	print("SPLASH C: kyai=%s pemain=%s" % [str(kyai.global_position), str(_main._player.global_position)])
	await _foto("konsep-splash-c-karakter-mentah.png", Vector3(-0.2, 2.2, 9.0), Vector3(-0.3, 1.4, 1.0))

	LangitDinamis.debug_jam = -1.0
	print("FOTO SPLASH KONSEP SELESAI")
	get_tree().quit(0)
