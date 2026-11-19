extends Node
## Foto ulang sholat 20 NPC (Raka, 19 Nov 2026) — run 1 menunjukkan
## NPC sudah di saf tapi interior TIDAK TERENDER (latar hijau void)
## karena _interior_root/_musholla_root visible=false saat pemain di
## luar. Perbaikan: _set_interior_terlihat(true, false, true) sebelum
## foto; peak tracking (bukan sampel terakhir — jendela "sholat"
## singkat di 1,4 fps Xvfb).
## Jalankan di Xvfb :97 (masih jalan):
##   HOME=/tmp/iso-npc20-foto2 DISPLAY=:97 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_npc_20_sholat.tscn
## Nama file BARU (v2) — jangan timpa run 1.

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
	_main._masuk_pesantren("Foto NPC 20 Sholat v2")
	for i in 5:
		await get_tree().process_frame
	_main._ui.set_hud_visible(false)
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	_cam.current = true
	# Teleport 20 NPC ke dekat pintu + mulai sholat (pola test).
	var i := 0
	for npc in _npc_baru():
		var dekat: Vector3 = Vector3(134 + float(i % 5 - 2) * 1.5, 0, -14 + float(i / 5) * 1.5) if bool(npc.adalah_putri()) else Vector3(float(i % 5 - 2) * 1.5, 0, 2 + float(i / 5) * 1.5)
		npc.global_position = dekat
		i += 1
	var jam_skrg := Time.get_time_string_from_system().substr(0, 5)
	_main._mulai_sholat({"nama": "Dzuhur", "jam": jam_skrg, "durasi_menit": 1})
	Engine.time_scale = 15.0
	var t0 := Time.get_ticks_msec()
	var peak := 0
	while peak < 15 and Time.get_ticks_msec() - t0 < 15000:
		var sampai := 0
		for npc in _npc_baru():
			if String(_main._npc_sholat_fase.get(npc, "")) == "sholat":
				sampai += 1
		peak = maxi(peak, sampai)
		await _tunggu(0.5)
	Engine.time_scale = 1.0
	print("FOTO sholat v2: peak %d/20 di sajadah" % peak)
	# Nyalakan interior (pemain di luar = interior tersembunyi).
	_main._set_interior_terlihat(true, false, true)
	_main._ui.hide_sholat_banner()
	await _bidik(Vector3(1.1, 2.5, -294.5), Vector3(1.1, 0.5, -301.5))
	await _foto("npc20-sholat-surau-v2.png")
	await _bidik(Vector3(63.0, 2.5, -295.5), Vector3(63.0, 0.5, -302.5))
	await _foto("npc20-sholat-musholla-v2.png")
	print("FOTO NPC 20 SHOLAT v2 SELESAI")
	get_tree().quit(0)
