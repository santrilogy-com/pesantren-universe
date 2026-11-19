extends Node
## Foto ASRAMA PUTRI LAPANG (Lestari, 18 Nov 2026) — bukti perbesaran
## tapak 18x12 (Nadia) dengan PEMAIN ASLI, bukan boneka skala:
## pemain utama + 2 SantriPlayer tambahan (abaya + jilbab, nama
## Aisyah/Fatimah) berdampingan di (1) koridor lantai 1 dan
## (2) lorong kaki kasur Kamar 001 — masing-masing portrait
## (390x844) + landscape (844x390), lewat kamera pemain asli
## (spring 5,5 m, pitch -0,22, FOV 65 di Asrama — nilai baru
## main.gd). Jalankan TANPA --headless (headless = save_png null):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_asrama_lapang.tscn
## Posisi (dunia, tapak x -249..-227,5, z -306..-294):
## - Koridor: trio x=-243, z -300,85/0/+0,85 (3 kapsul 2,1 m di
##   koridor bersih 2,6 m), hadap timur; lampu koridor (-240)
##   + annex terlihat jauh di timur.
## - Kamar 001: trio x=-242,5, z -301,8/-302,55/-303,3 (jejak
##   boneka skala Nadia di lorong kaki kasur, digeser 2 m ke timur
##   supaya spring dapat 5,5 m penuh — di x=-244,5 tembok barat
##   menjepit ke 4,43 m), hadap timur (kasur di kiri/utara,
##   partisi di depan).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _main: Node
var _ekstra: Array = []


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Foto asrama lapang")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# MASUK ASRAMA (wajib): root interior terlihat + flag
	# _di_dalam_asrama_putri=true (kamera FOV 65 / spring 5,5 m).
	# Tanpa ini foto gelap (ruangan + lampu tidak dirender).
	_main._masuk_asrama_putri()
	for i in 3:
		await get_tree().process_frame
	# 2 pemain tambahan (SantriPlayer ASLI — visual dibangun
	# player.gd, sama seperti pemain utama; BUKAN boneka kapsul).
	# Abaya dibedakan warnanya supaya ketiganya terbaca terpisah.
	_tambah_ekstra("Aisyah", "#1d4e6b", "#f2ead6")
	_tambah_ekstra("Fatimah", "#6b3a1d", "#e8dcc0")
	# Koridor lantai 1, portrait + landscape.
	await _foto_trio("asrama-lapang-koridor-portrait.png", Vector2i(390, 844),
		-243.0, [-300.85, -300.0, -299.15], PI / 2.0)
	await _foto_trio("asrama-lapang-koridor-landscape.png", Vector2i(844, 390),
		-243.0, [-300.85, -300.0, -299.15], PI / 2.0)
	# Lorong kaki kasur Kamar 001, portrait + landscape.
	await _foto_trio("asrama-lapang-kamar-portrait.png", Vector2i(390, 844),
		-242.5, [-301.8, -302.55, -303.3], PI / 2.0)
	await _foto_trio("asrama-lapang-kamar-landscape.png", Vector2i(844, 390),
		-242.5, [-301.8, -302.55, -303.3], PI / 2.0)
	print("FOTO ASRAMA LAPANG SELESAI")
	get_tree().quit(0)


## Satu pemain tambahan: kapsul + visual putri (bangun ulang dari
## outfit pemain utama supaya abaya + jilbab, bukan koko).
func _tambah_ekstra(nama: String, abaya: String, hijab_warna: String) -> void:
	var p := SantriPlayer.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0, 0.85, 0)
	p.add_child(shape)
	p.floor_snap_length = 0.3
	_main.add_child(p)
	var outfit: Dictionary = (_main._save.get("outfit", MissionData.OUTFIT_DEFAULT)).duplicate()
	outfit["muslimah"] = true
	outfit["hijab"] = true
	outfit["abaya"] = abaya
	outfit["hijab_warna"] = hijab_warna
	p.bangun_ulang_visual(outfit)
	p.set_nama(nama)
	_ekstra.append(p)


## Trio berdampingan (pemain utama di tengah, ekstra di kiri/kanan
## sepanjang z), lalu jepret. yaw +PI/2 = hadap timur (wajah di +Z
## lokal; -PI/2 = barat — foto pertama salah arah ke pintu dekat).
func _foto_trio(nama: String, ukuran: Vector2i, x: float, daftar_z: Array, yaw: float) -> void:
	get_window().size = ukuran
	for i in 10:
		await get_tree().process_frame
	# Portrait memicu overlay "PUTAR HP-MU" (perilaku normal game)
	# — tutup seperti santri mengetuk "Tetap main portrait"
	# (pola foto_registrasi_gender.gd; HANYA skrip foto).
	_main._ui._tutup_rotate_overlay()
	_main._teleport_player(Vector3(x, 0, daftar_z[1]), yaw)
	(_ekstra[0] as Node3D).global_position = Vector3(x, 0, daftar_z[0])
	(_ekstra[0] as SantriPlayer).set_facing(yaw)
	(_ekstra[1] as Node3D).global_position = Vector3(x, 0, daftar_z[2])
	(_ekstra[1] as SantriPlayer).set_facing(yaw)
	# 60 frame: rig + spring (memanjang pelan 4/dtk) + pitch lerp
	# (12/dtk) menetap dulu sebelum jepret.
	for i in 60:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s) spring=%.2f fov=%.0f cam=%s pemain=%s" % [
		nama, OUT_DIR + nama, str(err),
		_main._spring.spring_length, _main._cam.fov,
		str(_main._cam.global_position), str(_main._player.global_position)])
