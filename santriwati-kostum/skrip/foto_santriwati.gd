extends Node
## Foto santriwati kostum (KIRANA 17 Nov 2026 — Mas: "Abaya dan
## jilbab warnanya bisa dikostum ganti ketika ganti baju").
## Santriwati dengan 3 kombinasi warna + panel Ganti Baju.
## Dijalankan sebagai SCENE (.tscn), pola foto_ronde22.gd.
## Jam dibekukan 10.00 (pagi, langit biru). Kamera bebas. Timer
## patroli dibekukan supaya Kyai/Ustadzah tetap duduk baca kitab.
## PENTING: jalankan TANPA --headless (xvfb-run saja, render
## llvmpipe) — dengan --headless save_png mengembalikan null.
## Output ke foto-ronde-20/ dengan nomor BARU (35-38); foto lama
## 01-34 JANGAN ditimpa. Save lokal di-backup dan dikembalikan.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/foto-ronde-20/"

var _main: Node
var _cam: Camera3D
var _save_backup := ""
var _save_ada := false


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	if FileAccess.file_exists(SantriSave.SAVE_PATH):
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.READ)
		if f != null:
			_save_backup = f.get_as_text()
			_save_ada = true
			f.close()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	# Masuk sebagai santriwati (stub login server, tanpa jaringan).
	_main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri", "jenis_kelamin": "putri", "session": "stub"})
	_main._masuk_pesantren("Tes Putri")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Bekukan patroli: Kyai + Ustadzah tetap duduk baca kitab.
	_main._kyai._patroli_timer = 9999.0
	_main._ustadzah._patroli_timer = 9999.0
	_main._player.global_position = Vector3(130, 0, 14)
	_main._player.velocity = Vector3.ZERO
	# Pemain menghadap selatan (+Z) supaya kamera di selatan
	# menangkap wajah + jilbab dari depan.
	_main._player.set_facing(PI)
	# --- 35. Santriwati default: abaya Zamrud + jilbab Krem ---
	await _foto("35-santriwati-default.png", Vector3(130, 2.0, 20.5), Vector3(130, 1.2, 14), "luar")
	# --- 36. Abaya Hitam + jilbab Putih ---
	_main._ui._on_outfit_swatch("abaya", "#23282e")
	_main._ui._on_outfit_swatch("hijab_warna", "#faf7f0")
	await _foto("36-santriwati-hitam-putih.png", Vector3(130, 2.0, 20.5), Vector3(130, 1.2, 14), "luar")
	# --- 37. Abaya Navy + jilbab Zamrud ---
	_main._ui._on_outfit_swatch("abaya", "#2b3a4a")
	_main._ui._on_outfit_swatch("hijab_warna", "#065f46")
	await _foto("37-santriwati-navy-zamrud.png", Vector3(130, 2.0, 20.5), Vector3(130, 1.2, 14), "luar")
	# --- 38. Panel Ganti Baju sebagai santriwati (baris Abaya +
	# Jilbab tampil, Koko/Songkok/Sarung sembunyi). Kembalikan dulu
	# ke default supaya tanda ✓ di Zamrud + Krem. ---
	_main._ui._on_outfit_swatch("abaya", "#065f46")
	_main._ui._on_outfit_swatch("hijab_warna", "#f2ead6")
	_main._ui.open_outfit(_main._save.get("outfit", MissionData.OUTFIT_DEFAULT))
	await _foto("38-panel-ganti-baju-putri.png", Vector3(130, 2.0, 20.5), Vector3(130, 1.2, 14), "luar")
	_main._ui.close_outfit()
	_pulihkan_save()
	print("FOTO SELESAI")
	get_tree().quit(0)


func _pulihkan_save() -> void:
	if _save_ada:
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.WRITE)
		if f != null:
			f.store_string(_save_backup)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3, _mode: String) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
