extends Node
## Probe Sinta (19 Nov 2026, koreksi meja): transform MEJA di adegan
## PUTRA — foto Sanusi tidak menunjukkan panel depan padahal kode ada
## dan render Fatimah menunjukkannya. Ukur: posisi/yaw meja, tiap anak
## (ukuran + posisi global), posisi kamera + pemain + guru.
## Jalankan: HOME=/tmp/iso-probe DISPLAY=:96 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/probe_meja_putra.tscn

var _main: Node


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
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
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
	var guru: Node = _main._sanusi
	var pos_guru := Vector3(0, 0, -14)
	guru.position = pos_guru
	_main._player.global_position = pos_guru + Vector3(0, 0, 4)
	_main._pos_legal_terakhir = pos_guru + Vector3(0, 0, 4)
	for i in 10:
		await get_tree().process_frame
	print("PROBE-MEJA sebelum adegan: pemain=%s guru=%s" % [str(_main._player.global_position), str(guru.global_position)])
	_main._mulai_adegan_belajar()
	_main._manajer_misi.buka_ruang_belajar("Ust. Sanusi", _main._save)
	await get_tree().create_timer(2.0).timeout
	var meja: Node3D = _main._meja_belajar
	print("PROBE-MEJA meja ada=%s pos=%s rot_y=%.3f" % [str(meja != null), str(meja.global_position) if meja != null else "-", meja.rotation.y if meja != null else 0.0])
	if meja != null:
		for anak in meja.get_children():
			var ukuran := Vector3.ZERO
			if anak is MeshInstance3D and (anak as MeshInstance3D).mesh is BoxMesh:
				ukuran = ((anak as MeshInstance3D).mesh as BoxMesh).size
			print("PROBE-MEJA anak=%s pos_lokal=%s pos_global=%s ukuran=%s" % [anak.name, str(anak.position), str((anak as Node3D).global_position), str(ukuran)])
	var cam := get_viewport().get_camera_3d()
	print("PROBE-MEJA kamera=%s pemain=%s guru=%s dialog_yaw=%.3f" % [str(cam.global_position), str(_main._player.global_position), str(guru.global_position), _main._dialog_cam_yaw])
	# LANTAI: raycast ke bawah di posisi meja/guru/papan — dugaanku
	# panel tidak ter-render karena lantai Surau LEBIH TINGGI dari
	# y=0 (meja tenggelam; hanya atasnya yang menyembul).
	var ruang := get_viewport().get_world_3d().direct_space_state
	for label in [["meja", Vector3(0, 0, -13.11)], ["guru", Vector3(0, 0, -14)], ["papan", Vector3(-1.04, 0, -13.04)], ["pemain", Vector3(0, 0, -10)]]:
		var q := PhysicsRayQueryParameters3D.create(Vector3(label[1].x, 3, label[1].z), Vector3(label[1].x, -1, label[1].z))
		q.collision_mask = 0xFFFFFFFF
		var hit := ruang.intersect_ray(q)
		print("PROBE-LANTAI %s: %s" % [label[0], str(hit.get("position", "TIDAK-KENA"))])
	# PANEL: kenapa tidak ter-render? Cetak visible/material/AABB tiap
	# anak meja, lalu paksa panel depan jadi MERAH TERANG — kalau merah
	# muncul di screenshot, nodenya me-render dan mat_kayu-nya yang
	# bermasalah; kalau tetap tidak ada, node-nya tidak ter-render.
	var meja2: Node3D = _main._meja_belajar
	if meja2 != null:
		for anak in meja2.get_children():
			var mi := anak as MeshInstance3D
			if mi == null:
				continue
			var mat := mi.material_override as StandardMaterial3D
			var uk := Vector3.ZERO
			if mi.mesh is BoxMesh:
				uk = (mi.mesh as BoxMesh).size
			print("PROBE-PANEL anak ukuran=%s visible=%s mat=%s albedo=%s aabb=%s" % [str(uk), str(mi.visible), str(mat != null), str(mat.albedo_color) if mat != null else "-", str(mi.get_aabb())])
			if uk == Vector3(1.07, 0.5, 0.03):
				var merah := StandardMaterial3D.new()
				merah.albedo_color = Color("#ff0000")
				mi.material_override = merah
				print("PROBE-PANEL panel depan dipaksa MERAH")
	# SINAR KAMERA->PANEL: apa yang menghalangi? Raycast dari kamera
	# ke tengah panel depan — laporkan collider PERTAMA yang kena.
	var cam2 := get_viewport().get_camera_3d()
	if cam2 != null and meja2 != null:
		var target_panel := Vector3(0, 0.30, -13.11)
		var q2 := PhysicsRayQueryParameters3D.create(cam2.global_position, target_panel)
		q2.collision_mask = 0xFFFFFFFF
		var hit2 := ruang.intersect_ray(q2)
		print("PROBE-SINAR kamera=%s target=%s hit=%s" % [str(cam2.global_position), str(target_panel), str(hit2.get("position", "TIDAK-KENA")) + " collider=" + str(hit2.get("collider", "-"))])
		# Bola uji visual: merah di posisi panel, hijau 1 m lebih dekat
		# ke kamera (y sama), biru di atas meja (y=1,0), kuning 2 m ke
		# samping (y sama) — screenshot membuktikan mana yang kelihatan.
		# Tangga bola: cari tinggi PASTI permukaan yang menyembunyikan
		# semua benda di y=0,3 (bola merah/hijau/kuning tak kelihatan,
		# biru y=1,0 kelihatan) — dugaanku lantai visual Surau di
		# ~0,5 (raycast fisika tak bisa melihatnya: tak ada collider).
		for uji in [
			["tangga-04", Vector3(-0.8, 0.40, -13.11), Color("#ff8800")],
			["tangga-05", Vector3(-0.4, 0.50, -13.11), Color("#ff00ff")],
			["tangga-06", Vector3(0, 0.60, -13.11), Color("#00ffff")],
			["tangga-07", Vector3(0.4, 0.70, -13.11), Color("#ffffff")],
			["tangga-08", Vector3(0.8, 0.80, -13.11), Color("#8800ff")],
		]:
			var bola := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.12
			sm.height = 0.24
			bola.mesh = sm
			var bm := StandardMaterial3D.new()
			bm.albedo_color = uji[2]
			bola.material_override = bm
			bola.position = uji[1]
			bola.name = "BolaUji_" + String(uji[0])
			_main.add_child(bola)
			print("PROBE-BOLA %s di %s" % [uji[0], str(uji[1])])
	# kalau panel ADA di screenshot ini tapi TIDAK di foto script,
	# maka jalurnya yang beda; kalau sama-sama tidak ada, panelnya
	# memang tidak ter-render di adegan putra walau ada di tree.
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("/home/hatch/workspace/pesantren-verse/v2/foto-ui/probe-meja-putra-cek.png")
	print("PROBE-MEJA screenshot -> probe-meja-putra-cek.png (err=%s)" % str(err))
	_main._manajer_misi.tutup_semua()
	print("PROBE-MEJA SELESAI")
	get_tree().quit()
