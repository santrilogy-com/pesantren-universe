extends Node
## Foto 20 NPC sistem baru (Raka, 19 Nov 2026 — desain Laras).
## 7 zona + 1 duduk + 2 sholat (Surau + Musholla). Layar 1280x720.
## Jalankan di Xvfb display SEGAR (pola foto_ruang_belajar_chat.gd):
##   Xvfb :97 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-npc20-foto DISPLAY=:97 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_npc_20.tscn
## Nama file BARU di v2/foto-npc/ — jangan timpa yang lama.
## JANGAN ubah kode game — skrip foto saja.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-npc/"

var _main: Node
var _cam: Camera3D


func _foto(nama: String) -> void:
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])


func _tunggu(detik: float) -> void:
	await get_tree().create_timer(detik).timeout


func _bidik(pos: Vector3, target: Vector3) -> void:
	_cam.global_position = pos
	_cam.look_at(target, Vector3.UP)
	await _tunggu(0.5)


func _npc_baru() -> Array:
	var hasil: Array = []
	for npc in _main._npcs:
		if bool(npc.get("_aktivitas_aktif")):
			hasil.append(npc)
	return hasil


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	for i in 5:
		await get_tree().process_frame
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto NPC 20")
	for i in 5:
		await get_tree().process_frame
	_main._ui.set_hud_visible(false)
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	_cam.current = true
	# NPC menyebar dulu (time_scale 5, 10 dtk nyata = 50 dtk game).
	Engine.time_scale = 5.0
	await _tunggu(10.0)
	Engine.time_scale = 1.0

	# ---------- 7 zona ----------
	await _bidik(Vector3(0, 8, 26), Vector3(0, 1, 6))
	await _foto("npc20-p1-plaza.png")
	await _bidik(Vector3(-24, 8, 30), Vector3(-24, 1, 10))
	await _foto("npc20-p2-asrama.png")
	await _bidik(Vector3(-36, 8, -14), Vector3(-51, 1, -16))
	await _foto("npc20-p4-sawah.png")
	await _bidik(Vector3(134, 8, 0), Vector3(134, 1, -24))
	await _foto("npc20-w1-musholla.png")
	await _bidik(Vector3(131, 8, 26), Vector3(131, 1, 8))
	await _foto("npc20-w2-kelas.png")
	await _bidik(Vector3(155, 8, 28), Vector3(155, 1, 10))
	await _foto("npc20-w3-asrama-putri.png")
	await _bidik(Vector3(123, 8, 46), Vector3(123, 1, 32))
	await _foto("npc20-w4-taman-putri.png")

	# ---------- 1 duduk ----------
	# Cari NPC baru yang sedang duduk; bila tidak ada, paksa satu.
	var duduk: Node = null
	var t0 := Time.get_ticks_msec()
	while duduk == null and Time.get_ticks_msec() - t0 < 30000:
		for npc in _npc_baru():
			if String(npc._aktivitas) in ["duduk", "baca_kamar"]:
				duduk = npc
				break
		if duduk == null:
			await _tunggu(1.0)
	if duduk == null:
		for npc in _npc_baru():
			if String(npc._aktivitas) == "" and String(npc._hormat) == "":
				npc._mulai_duduk_kursi()
				duduk = npc
				break
		t0 = Time.get_ticks_msec()
		while duduk != null and String(duduk._aktivitas) != "duduk" and Time.get_ticks_msec() - t0 < 20000:
			await _tunggu(1.0)
	if duduk != null:
		var p: Vector3 = duduk.global_position
		var depan := p + Vector3(0, 0, 0) + Vector3(sin(duduk._visual.rotation.y), 0, cos(duduk._visual.rotation.y)) * 3.0
		await _bidik(Vector3(depan.x, p.y + 1.6, depan.z), Vector3(p.x, p.y + 0.9, p.z))
		await _foto("npc20-duduk.png")
		print("FOTO duduk: %s di (%.1f,%.1f) aktivitas=%s" % [duduk._nama, p.x, p.z, String(duduk._aktivitas)])
	else:
		print("FOTO duduk: TIDAK ADA NPC duduk (skip)")

	# ---------- 2 sholat ----------
	# Teleport 20 NPC ke dekat pintu (pola test_npc_20.gd), mulai
	# sholat, tunggu sampai >=15 di sajadah, lalu foto interior
	# (sebelum blackout: takbir hanya 4 dtk — foto cepat).
	var i := 0
	for npc in _npc_baru():
		var dekat: Vector3 = Vector3(134 + float(i % 5 - 2) * 1.5, 0, -14 + float(i / 5) * 1.5) if bool(npc.adalah_putri()) else Vector3(float(i % 5 - 2) * 1.5, 0, 2 + float(i / 5) * 1.5)
		npc.global_position = dekat
		i += 1
	var jam_skrg := Time.get_time_string_from_system().substr(0, 5)
	_main._mulai_sholat({"nama": "Dzuhur", "jam": jam_skrg, "durasi_menit": 1})
	Engine.time_scale = 15.0
	t0 = Time.get_ticks_msec()
	var sampai := 0
	while sampai < 15 and Time.get_ticks_msec() - t0 < 10000:
		sampai = 0
		for npc in _npc_baru():
			if String(_main._npc_sholat_fase.get(npc, "")) == "sholat":
				sampai += 1
		await _tunggu(0.5)
	Engine.time_scale = 1.0
	_main._ui.hide_sholat_banner()
	print("FOTO sholat: %d/20 di sajadah" % sampai)
	# Surau interior: sajadah tengah ~(1.1, 0.1, -301.2); kamera di
	# belakang saf, menghadap kiblat (z makin negatif).
	await _bidik(Vector3(1.1, 2.5, -294.5), Vector3(1.1, 0.5, -301.5))
	await _foto("npc20-sholat-surau.png")
	# Musholla interior: sajadah tengah ~(63.0, 0.0, -302.3).
	await _bidik(Vector3(63.0, 2.5, -295.5), Vector3(63.0, 0.5, -302.5))
	await _foto("npc20-sholat-musholla.png")

	print("FOTO NPC 20 SELESAI")
	get_tree().quit(0)
