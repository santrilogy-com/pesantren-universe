extends Node
## Foto ASRAMA PUTRA (Lestari, 18 Nov 2026) — bukti wiring Asrama
## Putra (ACC Mas 09:37 WIB) dengan PEMAIN ASLI, bukan boneka skala:
## pemain utama + 2 SantriPlayer tambahan (koko, nama Ahmad/Bilal)
## berdampingan di (1) koridor lantai 1 dan (2) lorong kaki kasur
## Kamar 001 — masing-masing portrait (390x844) + landscape
## (844x390), lewat kamera pemain asli (spring 5,5 m, pitch -0,22,
## FOV 65 di Asrama — kontrak kamera Asrama Putri/Putra main.gd).
## Shot kamar LANDSCAPE diambil dengan tombol TIDUR tampil (pemain
## utama berdiri di dekat kasur sendiri A-PUTRA-007). Jalankan
## TANPA --headless (headless = save_png null):
##   xvfb-run ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --path . skrip/foto_asrama_putra.tscn
## Posisi RELATIF terhadap OFFSET interior (root.position) — TIDAK
## ada angka interior yang dikarang: denah salin persis Putri
## (pintu barat, koridor E-W 2,6 m, kamar 9x4,7 m).
## - Koridor: trio x=off.x-3, z off.z-0,85/0/+0,85 (3 kapsul 2,1 m
##   di koridor bersih 2,6 m), hadap timur; lampu koridor + annex
##   terlihat jauh di timur.
## - Kamar 001: trio x=off.x-2,5, z off.z-1,8/-2,55/-3,3 (lorong
##   kaki kasur; digeser ke timur supaya spring dapat 5,5 m penuh
##   — pola foto_asrama_lapang.gd), hadap timur (kasur di
##   kiri/utara, partisi di depan). Kasur sendiri A-PUTRA-007
##   (susun 4 bawah, tidur di off+(-1,2, 0,55, -3,75)): pemain
##   utama di tengah trio berjarak 1,85 m darinya (< 2,5 m) dan
##   jauh dari pintu — tombol TIDUR menang atas KELUAR.
## Butuh interior_asrama_putra.gd (Nadia): bila root null, skrip
## berhenti dengan pesan jelas (bukan memotret tanah kosong).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-asrama-putra/"

var _main: Node
var _ekstra: Array = []


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Foto asrama putra")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	if _main._asrama_putra_root == null:
		print("FOTO ASRAMA PUTRA: BLOKIR — interior_asrama_putra.gd belum mendarat (Nadia); skrip foto sudah siap, jalankan lagi setelah interior ada.")
		get_tree().quit(1)
		return
	# MASUK ASRAMA (wajib): root interior terlihat + flag
	# _di_dalam_asrama_putra=true (kamera FOV 65 / spring 5,5 m).
	# Tanpa ini foto gelap (ruangan + lampu tidak dirender).
	_main._masuk_asrama_putra()
	for i in 3:
		await get_tree().process_frame
	# 2 pemain tambahan (SantriPlayer ASLI — visual dibangun
	# player.gd, sama seperti pemain utama; BUKAN boneka kapsul).
	# Koko dibedakan warnanya supaya ketiganya terbaca terpisah.
	var off: Vector3 = _main._asrama_putra_root.position
	_tambah_ekstra("Ahmad", "#1d4e6b", "#008062")
	_tambah_ekstra("Bilal", "#6b3a1d", "#3b5aa3")
	# Koridor lantai 1, portrait + landscape.
	await _foto_trio("asrama-putra-koridor-portrait.png", Vector2i(390, 844),
		off.x - 3.0, [off.z - 0.85, off.z, off.z + 0.85], PI / 2.0)
	await _foto_trio("asrama-putra-koridor-landscape.png", Vector2i(844, 390),
		off.x - 3.0, [off.z - 0.85, off.z, off.z + 0.85], PI / 2.0)
	# Lorong kaki kasur Kamar 001, portrait + landscape — dengan
	# tombol TIDUR tampil (kasur sendiri A-PUTRA-007).
	_main._kasur_saya = {"kasur_id": "A-PUTRA-007", "gedung": "Asrama Putra", "kamar": "Kamar 001", "susun": 4, "tingkat": "bawah", "fisik": false}
	await _foto_trio("asrama-putra-kamar-portrait.png", Vector2i(390, 844),
		off.x - 2.5, [off.z - 1.8, off.z - 2.55, off.z - 3.3], PI / 2.0)
	await _foto_trio("asrama-putra-kamar-landscape.png", Vector2i(844, 390),
		off.x - 2.5, [off.z - 1.8, off.z - 2.55, off.z - 3.3], PI / 2.0)
	print("FOTO ASRAMA PUTRA SELESAI")
	get_tree().quit(0)


## Satu pemain tambahan: kapsul + visual putra (bangun ulang dari
## outfit pemain utama supaya koko + peci, bukan abaya).
func _tambah_ekstra(nama: String, koko: String, sarung: String) -> void:
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
	outfit["muslimah"] = false
	outfit["hijab"] = false
	outfit["koko"] = koko
	outfit["sarung"] = sarung
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
	print("FOTO %s -> %s (err=%s) spring=%.2f fov=%.0f cam=%s pemain=%s tombol=%s" % [
		nama, OUT_DIR + nama, str(err),
		_main._spring.spring_length, _main._cam.fov,
		str(_main._cam.global_position), str(_main._player.global_position),
		String(_main._ui._interact_btn.text) if _main._ui._interact_btn.visible else "-"])
