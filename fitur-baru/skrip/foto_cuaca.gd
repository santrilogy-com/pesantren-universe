extends Node
## Foto FITUR CUACA (Wulan, 17 Nov 2026). Dijalankan sebagai SCENE:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --resolution 1280x720 \
##     --path . foto_cuaca.tscn
## (TANPA --headless — headless membuat save_png null.)
## Jam dibekukan 10.00 (pagi). Kondisi dipaksa lewat
## LangitDinamis.debug_kondisi (bukan cuaca asli — cuaca asli hanya
## bisa dibuktikan di HP Mas). 4 foto, kamera sama persis supaya
## perbandingan adil: dari depan Surau, agak mendongak ke langit
## (awan terlihat) + lapangan di bawah (hujan terlihat).
## C1 cerah | C2 berawan | C3 mendung | C4 hujan.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/fitur-baru/foto/"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	# Masuk langsung TANPA login server: HTTPRequest Godot di VM ini
	# tidak menembus proxy (curl shell bisa, Godot tidak).
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes foto cuaca")
	await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true

	# Kamera: depan Surau (-4, 2, 22), mendongak ke langit utara
	# (target y=40) — awan di ketinggian 45-70 m masuk frame, atap
	# Surau + lapangan tetap terlihat di bawah sebagai pembanding.
	var pos_kamera := Vector3(-4, 2.0, 22.0)
	var target := Vector3(-4, 40.0, -60.0)
	for kondisi in ["cerah", "berawan", "mendung", "hujan"]:
		LangitDinamis.debug_kondisi = kondisi
		# Hujan butuh beberapa frame supaya tetes tersebar jatuh.
		await _foto("C%d-%s.png" % [_urutan(kondisi), kondisi], pos_kamera, target)
	LangitDinamis.debug_kondisi = ""
	print("FOTO CUACA SELESAI")
	get_tree().quit(0)


func _urutan(kondisi: String) -> int:
	match kondisi:
		"cerah":
			return 1
		"berawan":
			return 2
		"mendung":
			return 3
	return 4


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
