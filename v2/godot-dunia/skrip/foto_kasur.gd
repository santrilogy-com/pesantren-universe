extends Node
## Foto PEMBAGIAN KASUR (Wulan, 18 Nov 2026) — jalankan TANPA --headless
## (headless membuat save_png null):
##   xvfb-run godot --path . skrip/foto_kasur.tscn
## Tiga foto: (1) santri tidur di kasur Cangkruk (bed 1, fisik);
## (2) santri Asrama Kamar 001 tidur SEMENTARA di Surau (Cangkruk
## penuh -> Asrama logis -> titik Surau); (3) santriwati Cangkruk
## Putri tidur sementara di Musholla (interior putri belum ada).
## Ledger FOTO sendiri (user://kasur_foto.json) — ledger utama
## (user://kasur.json) TIDAK disentuh. PERHATIAN: _save diubah di
## memori, TAPI _masuk_pesantren() memanggil _terapkan_gender_pemain()
## yang MENYIMPAN _save ke disk (main.gd ~845) — foto meninggalkan
## jejak santri tes di user://santri.json. Bersihkan manual setelah
## foto: reset id/nama/ig ke kosong + gender putra (dilakukan
## 00:58 WIB; ledger kasur_foto.json juga dihapus).

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-kasur/"
const LEDGER_FOTO := "user://kasur_foto.json"

var _main: Node
var _cam: Camera3D


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_cam = Camera3D.new()
	_cam.fov = 60.0
	add_child(_cam)
	_cam.current = true
	await _foto_cangkruk()
	await _foto_surau()
	await _foto_musholla()
	print("FOTO KASUR SELESAI")
	get_tree().quit(0)


## (1) Putra PV-9001 -> C-PUTRA-01, tidur di kasur fisik bed 1.
func _foto_cangkruk() -> void:
	var ledger := PembagianKasur.new(LEDGER_FOTO)
	var tugas := ledger.daftarkan("PV-9001", "putra")
	print("FOTO cangkruk: %s fisik=%s" % [String(tugas["kasur_id"]), str(bool(tugas["fisik"]))])
	_main._save["id_santri"] = "PV-9001"
	_main._save["nama"] = "Tes Kasur Satu"
	_main._save["jenis_kelamin"] = "putra"
	_main._kasur_saya = tugas
	_main._masuk_pesantren("Foto kasur")
	for i in 3:
		await get_tree().process_frame
	var bed1: Vector3 = InteriorCangkruk.BED_POS_LIST[0]
	_main._di_dalam_cangkruk = true
	_main._set_interior_terlihat(false, true, false)
	_main._player.global_position = bed1 + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	for i in 60:
		await get_tree().process_frame
	print("FOTO cangkruk: aksi=%s pos=%s" % [_main._player.aksi_saat_ini(), str(_main._player.global_position)])
	await _foto("kasur-cangkruk-terisi.png", Vector3(-54.5, 2.8, -296.5), Vector3(-63.5, 0.3, -302.0))


## (2) Putra PV-9011 (ke-11: 10 Cangkruk penuh) -> Asrama Kamar 001,
## tidur sementara di titik Surau.
func _foto_surau() -> void:
	var ledger := PembagianKasur.new(LEDGER_FOTO)
	ledger.muat()
	for i in range(2, 11):
		ledger.daftarkan("PV-900%d" % i, "putra")
	var tugas := ledger.daftarkan("PV-9011", "putra")
	print("FOTO surau: %s %s spot=%s" % [String(tugas["kasur_id"]), String(tugas["kamar"]), str(PembagianKasur.posisi_tidur(tugas))])
	_main._save["id_santri"] = "PV-9011"
	_main._save["nama"] = "Tes Kasur Sebelas"
	_main._save["jenis_kelamin"] = "putra"
	_main._kasur_saya = tugas
	_main._masuk_pesantren("Foto kasur Surau")
	for i in 3:
		await get_tree().process_frame
	var spot := PembagianKasur.posisi_tidur(tugas)
	_main._di_dalam_cangkruk = false
	_main._di_dalam = true
	_main._set_interior_terlihat(true, false, false)
	_main._player.global_position = spot + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	for i in 60:
		await get_tree().process_frame
	print("FOTO surau: aksi=%s pos=%s" % [_main._player.aksi_saat_ini(), str(_main._player.global_position)])
	var cam_pos := InteriorSurau.ke_dunia(Vector3(5.0, 2.6, -295.6))
	await _foto("kasur-surau-penuh.png", cam_pos, spot + Vector3(0, 0.5, 0))


## (3) Putri PV-9021 -> A-PUTRI-001 (Asrama Putri, KOREKSI Mas 00:25
## — tanpa Cangkruk), tidur sementara di Musholla.
func _foto_musholla() -> void:
	var ledger := PembagianKasur.new(LEDGER_FOTO)
	ledger.muat()
	var tugas := ledger.daftarkan("PV-9021", "putri")
	print("FOTO musholla: %s spot=%s" % [String(tugas["kasur_id"]), str(PembagianKasur.posisi_tidur(tugas))])
	_main._save["id_santri"] = "PV-9021"
	_main._save["nama"] = "Tes Kasur Putri"
	_main._save["jenis_kelamin"] = "putri"
	_main._kasur_saya = tugas
	_main._masuk_pesantren("Foto kasur Musholla")
	for i in 3:
		await get_tree().process_frame
	var spot := PembagianKasur.posisi_tidur(tugas)
	_main._di_dalam_cangkruk = false
	_main._di_dalam = false
	_main._di_dalam_musholla = true
	_main._set_interior_terlihat(false, false, true)
	_main._player.global_position = spot + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	for i in 60:
		await get_tree().process_frame
	print("FOTO musholla: aksi=%s pos=%s" % [_main._player.aksi_saat_ini(), str(_main._player.global_position)])
	var cam_pos := InteriorMusholla.ke_dunia(Vector3(64.5, 2.4, -297.2))
	await _foto("kasur-musholla-putri.png", cam_pos, spot + Vector3(0, 0.5, 0))


func _foto(nama: String, pos_kamera: Vector3, target: Vector3) -> void:
	_cam.global_position = pos_kamera
	_cam.look_at(target, Vector3.UP)
	for i in 40:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(OUT_DIR + nama)
	print("FOTO %s -> %s (err=%s)" % [nama, OUT_DIR + nama, str(err)])
