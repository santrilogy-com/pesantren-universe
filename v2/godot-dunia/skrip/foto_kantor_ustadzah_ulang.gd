extends Node
## RETAKE foto Kantor Ustadzah (Gilang, 20 Nov 2026). Foto v1
## (kantor-ustadzah-interior-baru.png) gagal sebagai bukti: kamera
## hanya 0,8 m di belakang spawn (-122.5,-300) sehingga pemain
## menutupi meja tengah + 2 kursi. Retake ini: pemain dipindah ke
## sudut barat-laut (-123.3,-302.3, aman dari cek pintu keluar —
## |d2.z| = 2,3 > 1,2), kamera dari sudut tenggara (-116.9, 2.4,
## -297.9) membidik meja tengah (-120,-300): kursi penguji timur +
## kursi pemain barat berhadapan, papan dinding utara, lemari barat.
## Nama file BARU — jangan timpa v1.
## Dijalankan di Xvfb display SEGAR:
##   HOME=/tmp/iso-kantor-putra-interior DISPLAY=:93 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/foto_kantor_ustadzah_ulang.tscn

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-ui/"

var _main: Node
var _cam: Camera3D


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
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Kantor"
	_main._save["petunjuk_tombol_ditutup"] = true
	_main._save["onboarding"] = {"langkah": 6, "modul": 1, "sanusi_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto Kantor")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 5:
		await get_tree().process_frame
	_main._audio.mulai()
	_main._ui._tutup_rotate_overlay()
	_cam = Camera3D.new()
	_cam.fov = 50.0
	add_child(_cam)
	_cam.current = true
	_main._masuk_kantor()
	await get_tree().create_timer(1.0).timeout
	print("FOTO-CEK masuk kantor ustadzah _di_dalam_kantor = %s (harap true)" % str(_main._di_dalam_kantor))
	# Pindah pemain ke sudut barat-laut, keluar dari garis bidik.
	_main._teleport_player(Vector3(-123.3, 0, -302.3), PI)
	await get_tree().create_timer(0.5).timeout
	print("FOTO-CEK pemain di sudut = %s (harap dekat (-123.3, 0, -302.3))" % str(_main._player.global_position))
	print("FOTO-CEK masih di dalam = %s (harap true)" % str(_main._di_dalam_kantor))
	_cam.global_position = Vector3(-116.9, 2.4, -297.9)
	_cam.look_at(Vector3(-121.3, 0.9, -300.3), Vector3.UP)
	await get_tree().create_timer(0.5).timeout
	_main._ui.set_hud_visible(false)
	await get_tree().create_timer(0.3).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + "kantor-ustadzah-interior-baru-v2.png")
	print("FOTO kantor-ustadzah-interior-baru-v2.png -> %s (err=%s)" % [OUT_DIR + "kantor-ustadzah-interior-baru-v2.png", str(err)])
	_main._ui.set_hud_visible(true)
	print("FOTO-SELESAI")
	get_tree().quit()
