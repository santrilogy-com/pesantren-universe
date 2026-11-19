extends Node
## Foto INTERIOR ASRAMA PUTRI (Rani, 18 Nov 2026; koordinat kamera +
## boneka skala diperbarui Nadia 18 Nov 2026 setelah perbesaran
## tapak 12x8 -> 18x12) — jalankan TANPA --headless (headless
## membuat save_png null):
##   xvfb-run godot --path . skrip/foto_interior_asrama_putri.tscn
## Enam foto, interior saja (tanpa main.tscn): (1) Kamar 001
## (lantai 1, barat-laut); (2) koridor lantai 1; (3) tangga annex;
## (4) Kamar 009 (lantai 3, barat-laut); (5) koridor lantai 2;
## (6) close-up kasur susun. WorldEnvironment ambient 0,4 hanya
## untuk foto (mendekati ambient siang di game); lampu ruangan
## tetap lampu interior asli.
## Boneka skala ~1,74 m (3 berdampingan, visual saja) berdiri di
## koridor L1+L2 dan lorong kaki kasur Kamar 001+009 sebagai
## pembanding lebar — BUKAN pemain asli; foto 3 pemain asli
## (portrait/landscape) dikerjakan Lestari setelah wiring.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-area-putri/"

var _cam: Camera3D


func _ready() -> void:
	var hasil: Dictionary = InteriorAsramaPutri.build()
	add_child(hasil["root"])
	# Boneka skala 3 berdampingan (koridor L1+L2 di z -0,8/0/+0,8;
	# lorong kaki kasur Kamar 001+009 di z -1,8/-2,55/-3,3).
	for fy in [0.0, 3.2]:
		for z in [-0.8, 0.0, 0.8]:
			_boneka(hasil["root"], Vector3(0, fy, z))
	for fy in [0.0, 6.4]:
		for z in [-1.8, -2.55, -3.3]:
			_boneka(hasil["root"], Vector3(-4.5, fy, z))
	for i in 3:
		await get_tree().process_frame
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#0a0f0d")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#fff2dd")
	e.ambient_light_energy = 0.4
	env.environment = e
	add_child(env)
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	# Kamar 001: kamera di lorong kaki kasur (-1,5, -1,9) — JANGAN
	# di (-0,6, -1,1): itu tepat di atas lemari (atap lemari
	# menutupi 40% frame, ditemukan di foto 18 Nov 01:xx WIB).
	await _foto("asrama-kamar-001.png", InteriorAsramaPutri.ke_dunia(Vector3(-1.5, 2.4, -1.9)), InteriorAsramaPutri.ke_dunia(Vector3(-5.5, 0.7, -4.75)))
	await _foto("asrama-koridor-lantai-1.png", InteriorAsramaPutri.ke_dunia(Vector3(-8.0, 2.0, 0.0)), InteriorAsramaPutri.ke_dunia(Vector3(9.0, 1.2, 0.0)))
	# Tangga: dari BORDES menghadap ke bawah flight A — dari koridor
	# soffit flight B memenuhi separuh frame; dari bordes yang
	# terlihat permukaan kedua flight (switchback terbaca).
	await _foto("asrama-tangga-annex.png", InteriorAsramaPutri.ke_dunia(Vector3(11.8, 2.7, 0.0)), InteriorAsramaPutri.ke_dunia(Vector3(9.0, 0.9, -0.3)))
	# Kamar 009: sudut berlawanan dari 001 (dari barat menghadap
	# timur) supaya tidak identik dengan foto lantai 1.
	await _foto("asrama-kamar-009-lantai-3.png", InteriorAsramaPutri.ke_dunia(Vector3(-8.0, 8.8, -2.2)), InteriorAsramaPutri.ke_dunia(Vector3(-1.0, 7.1, -4.75)))
	await _foto("asrama-koridor-lantai-2.png", InteriorAsramaPutri.ke_dunia(Vector3(-8.0, 5.2, 0.0)), InteriorAsramaPutri.ke_dunia(Vector3(9.0, 4.4, 0.0)))
	await _foto("asrama-kasur-susun-closeup.png", InteriorAsramaPutri.ke_dunia(Vector3(-2.0, 1.4, -2.4)), InteriorAsramaPutri.ke_dunia(Vector3(-3.4, 0.8, -4.75)))
	print("FOTO ASRAMA PUTRI SELESAI")
	get_tree().quit(0)


## Boneka skala orang berdiri (~1,74 m): kapsul + kepala.
## Visual saja (tanpa collision) — pembanding skala ruangan.
func _boneka(parent: Node3D, pos: Vector3) -> void:
	var b := Node3D.new()
	b.name = "BonekaSkala"
	b.position = pos
	parent.add_child(b)
	var badan := MeshInstance3D.new()
	var kapsul := CapsuleMesh.new()
	kapsul.radius = 0.32
	kapsul.height = 1.5
	badan.mesh = kapsul
	badan.position = Vector3(0, 0.75, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#065f46")
	badan.material_override = mat
	b.add_child(badan)
	var kepala := MeshInstance3D.new()
	var bola := SphereMesh.new()
	bola.radius = 0.12
	bola.height = 0.24
	kepala.mesh = bola
	kepala.position = Vector3(0, 1.62, 0)
	var mat_kulit := StandardMaterial3D.new()
	mat_kulit.albedo_color = Color("#e8c39a")
	kepala.material_override = mat_kulit
	b.add_child(kepala)


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
