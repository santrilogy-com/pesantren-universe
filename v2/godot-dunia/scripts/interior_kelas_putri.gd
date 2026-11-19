class_name InteriorKelasPutri
extends Node3D
## Interior Kelas Putri — MAP TERPISAH keempat ala GTA (Dewi, 18 Nov 2026).
##
## Ruang kelas 10 x 8 m, tinggi 3,4 m, pusat (120, 0, -301) — zona
## interior kosong di timur Musholla (Surau x=0, Cangkruk x=-60,
## Musholla x=60). Pintu di dinding SELATAN (z=-297, celah 1,6 m,
## |x-120|<0,8) — sama sisi dengan pintu selatan cangkang Kelas
## Putri (130, 0) di kampus_putri.gd, yang menghadap konektor ke
## jalan internal. BELUM DI-WIRE ke main.gd — Nadia yang integrasikan.
##
## ISI: papan tulis (dinding utara) + meja + kursi Ustadzah, 9 meja
## santriwati (3 baris x 3 kolom, 2 kursi tiap meja = 18 kursi),
## 2 rak buku jati (modul RakBukuPutri, dinding barat), 2 lampu
## hangat gantung, 3 jendela (timur 2 + selatan 1), label KELUAR
## di atas pintu + label KELAS PUTRI di atas papan tulis.
##
## INTERFACE (sama seperti InteriorCangkruk.build()):
##   build() -> {
##     "root": Node3D, "interior_door": Vector3(120,0,-297),
##     "interior_spawn": Vector3(118.6,0,-298.5),
##     "rak_spots": [Vector3 x2], "papan_tulis": Vector3(120,1.6,-304.85),
##     "meja_ustadzah": Vector3(120,0,-303.3),
##     "bounds": {"min_x":115, "max_x":125, "min_z":-305, "max_z":-297},
##   }
##
## Dipakai dua cara: (1) InteriorKelasPutri.build() dari main.gd
## (Nadia, saat wiring); (2) scene res://skrip/tes_rak_kelas_putri.tscn
## untuk tes/isolasi — _ready() membangun isi kalau belum ada.
## Interior ini DISEMBUNYIKAN (visible=false) saat pemain di luar —
## main.gd yang mengatur (pola double-surau ronde 6).

const ROOM_CENTER := Vector3(120, 0, -301)
const ROOM_HALF_X := 5.0
const ROOM_HALF_Z := 4.0
const WALL_HEIGHT := 3.4
const DOOR_HALF := 0.8
const DOOR_TOP := 2.2
const INTERIOR_DOOR := Vector3(120, 0, -297)
## Spawn 1,5 m di dalam pintu, DIGESER ke lorong barat (x=118.6):
## spawn tengah (120,-298.5) jatuh TEPAT di kursi baris terakhir
## kolom tengah (120,-298.45) — pemain muncul di dalam kursi.
const INTERIOR_SPAWN := Vector3(118.6, 0, -298.5)
const PAPAN_TULIS := Vector3(120, 1.6, -304.85)
const MEJA_USTADZAH := Vector3(120, 0, -303.3)
## 9 meja santri (3 baris x 3 kolom), menghadap utara (papan tulis).
const MEJA_POS_LIST: Array[Vector3] = [
	Vector3(117.3, 0, -301.8), Vector3(120.0, 0, -301.8), Vector3(122.7, 0, -301.8),
	Vector3(117.3, 0, -300.4), Vector3(120.0, 0, -300.4), Vector3(122.7, 0, -300.4),
	Vector3(117.3, 0, -299.0), Vector3(120.0, 0, -299.0), Vector3(122.7, 0, -299.0),
]
## 2 rak buku (dinding barat, menghadap timur ke tengah ruangan).
const RAK_POS_LIST: Array[Vector3] = [
	Vector3(115.35, 0, -303.5),
	Vector3(115.35, 0, -300.8),
]
const KELAS_BOUNDS := {"min_x": 115.0, "max_x": 125.0, "min_z": -305.0, "max_z": -297.0}


func _ready() -> void:
	if get_child_count() == 0:
		_bangun()


## Bangun interior (dipakai main.gd saat wiring). Mengembalikan dict
## dengan interface yang sama seperti InteriorCangkruk.build().
static func build() -> Dictionary:
	var node := InteriorKelasPutri.new()
	node.name = "InteriorKelasPutri"
	node._bangun()
	var rak_spots: Array[Vector3] = []
	for p in RAK_POS_LIST:
		rak_spots.append(RakBukuPutri.spot(p, PI / 2.0))
	return {
		"root": node,
		"interior_door": INTERIOR_DOOR,
		"interior_spawn": INTERIOR_SPAWN,
		"rak_spots": rak_spots,
		"papan_tulis": PAPAN_TULIS,
		"meja_ustadzah": MEJA_USTADZAH,
		"bounds": KELAS_BOUNDS,
	}


func _bangun() -> void:
	# --- Lantai kayu + dinding krem (collision): utara, barat, timur
	# utuh; selatan dua segmen + ambang pintu 1,6 m. Tebal 0,25.
	_static_box(self, Vector3(10, 0.14, 8), Vector3(120, -0.05, -301), Palette.KAYU).name = "Lantai"
	_static_box(self, Vector3(10.5, WALL_HEIGHT, 0.25), Vector3(120, 1.7, -305), Palette.KREM).name = "DindingUtara"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 8), Vector3(115, 1.7, -301), Palette.KREM).name = "DindingBarat"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 8), Vector3(125, 1.7, -301), Palette.KREM).name = "DindingTimur"
	_static_box(self, Vector3(4.2, WALL_HEIGHT, 0.25), Vector3(117.1, 1.7, -297), Palette.KREM).name = "DindingSelatan_Kiri"
	_static_box(self, Vector3(4.2, WALL_HEIGHT, 0.25), Vector3(122.9, 1.7, -297), Palette.KREM).name = "DindingSelatan_Kanan"
	_static_box(self, Vector3(1.6, 1.2, 0.25), Vector3(120, 2.8, -297), Palette.KREM).name = "AmbangPintu"
	# --- Plafon krem (HARUS punya collision — pola Cangkruk ronde 7:
	# SpringArm kamera memendek saat akan keluar ruangan ke atas).
	_static_box(self, Vector3(10.5, 0.25, 8.5), Vector3(120, 3.52, -301), Palette.PUTIH).name = "Plafon"
	# --- Lis emas di atas pintu + tiang pintu bundar (dalam) ---
	add_child(Palette.box(Vector3(1.6, 0.1, 0.3), Vector3(120, 2.25, -297), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.06, 0.06, 2.2, Vector3(119.28, 1.1, -297), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.06, 0.06, 2.2, Vector3(120.72, 1.1, -297), Palette.EMAS, 0.4))
	# Label KELUAR di atas pintu (menghadap ke dalam ruangan) +
	# label belakang (terbaca benar dari LUAR ruangan, pola Cangkruk).
	var keluar := Palette.label3d("KELUAR", Vector3(120, 2.7, -296.8), 22, Color("#f2c14e"), false)
	keluar.name = "LabelKeluar"
	keluar.rotation_degrees = Vector3(0, 180, 0)
	keluar.double_sided = false
	add_child(keluar)
	var keluar_luar := Palette.label3d("KELUAR", Vector3(120, 2.7, -297.2), 22, Color("#f2c14e"), false)
	keluar_luar.name = "LabelKeluarBelakang"
	keluar_luar.double_sided = false
	add_child(keluar_luar)
	# --- Papan tulis (dinding utara) + label KELAS PUTRI di atasnya ---
	_papan_tulis()
	# --- Meja + kursi Ustadzah (depan kelas, menghadap murid) ---
	_meja_ustadzah()
	# --- 9 meja santriwati + 18 kursi (2 per meja) ---
	for i in range(MEJA_POS_LIST.size()):
		_meja_santri(MEJA_POS_LIST[i], i + 1)
	# --- 2 rak buku jati (modul RakBukuPutri, dinding barat) ---
	for i in range(RAK_POS_LIST.size()):
		var rak := RakBukuPutri.build(RAK_POS_LIST[i], PI / 2.0, "RakKitab_Kelas_%d" % (i + 1))
		add_child(rak)
	# --- 2 lampu hangat gantung (di atas lorong antar kolom meja) ---
	_lampu_hangat(Vector3(118.5, 0, -302.5), "LampuKelas_1")
	_lampu_hangat(Vector3(121.5, 0, -299.5), "LampuKelas_2")
	# --- 3 jendela: timur 2 + selatan 1 (mengapit pintu sisi timur) ---
	_jendela(Vector3(124.875, 1.7, -302.5), -PI / 2.0, "JendelaTimur_Utara")
	_jendela(Vector3(124.875, 1.7, -299.5), -PI / 2.0, "JendelaTimur_Selatan")
	_jendela(Vector3(122.7, 1.7, -296.875), 0.0, "JendelaSelatan")


## Kotak visual + collision (pola yang sama seperti InteriorCangkruk).
func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := Palette.box(size, pos, color)
	parent.add_child(mi)
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)
	return mi


## Papan tulis hijau zamrud + bingkai emas + rak kapur di bawahnya.
## Label KELAS PUTRI di atas papan (menghadap ke dalam ruangan).
func _papan_tulis() -> void:
	var p := Node3D.new()
	p.name = "PapanTulis"
	add_child(p)
	p.add_child(Palette.box(Vector3(3.2, 1.2, 0.06), Vector3(PAPAN_TULIS.x, PAPAN_TULIS.y, PAPAN_TULIS.z), Palette.ZAMRUD_GELAP))
	p.add_child(Palette.box(Vector3(3.3, 0.08, 0.08), Vector3(120, 2.24, -304.85), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(3.3, 0.08, 0.08), Vector3(120, 0.96, -304.85), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.08, 1.2, 0.08), Vector3(118.36, 1.6, -304.85), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.08, 1.2, 0.08), Vector3(121.64, 1.6, -304.85), Palette.EMAS, 0.4))
	# Rak kapur + 2 batang kapur putih di bawah papan.
	p.add_child(Palette.box(Vector3(1.0, 0.04, 0.1), Vector3(119.0, 0.92, -304.78), Palette.KAYU_GELAP))
	p.add_child(Palette.box(Vector3(0.12, 0.03, 0.03), Vector3(118.8, 0.96, -304.78), Color("#ffffff")))
	p.add_child(Palette.box(Vector3(0.12, 0.03, 0.03), Vector3(119.1, 0.96, -304.78), Color("#ffffff")))
	# Coretan kapur: garis + lingkaran sederhana (tulisan "بسم الله").
	var tulis := Palette.label_arab("بسم الله", Vector3(120, 1.6, -304.80), 36, Color("#f5f0e6"))
	tulis.name = "TulisanPapan"
	add_child(tulis)
	var label := Palette.label3d("KELAS PUTRI", Vector3(120, 2.6, -304.8), 22, Color("#f2c14e"), false)
	label.name = "LabelKelasPutri"
	label.double_sided = false
	add_child(label)


## Meja Ustadzah: papan jati 1,4x0,7 + 4 kaki + kitab di atasnya;
## kursi di belakang meja (sisi utara), menghadap murid (selatan).
func _meja_ustadzah() -> void:
	var m := Node3D.new()
	m.name = "MejaUstadzah"
	add_child(m)
	var p: Vector3 = MEJA_USTADZAH
	m.add_child(Palette.box(Vector3(1.4, 0.07, 0.7), Vector3(p.x, 0.75, p.z), Palette.JATI))
	for sx in [-0.6, 0.6]:
		for sz in [-0.28, 0.28]:
			m.add_child(Palette.box(Vector3(0.07, 0.75, 0.07), Vector3(p.x + sx, 0.375, p.z + sz), Palette.KAYU_GELAP))
	# Kitab + tempat pensil di atas meja.
	m.add_child(Palette.box(Vector3(0.35, 0.06, 0.25), Vector3(p.x - 0.35, 0.82, p.z), Palette.ZAMRUD_GELAP))
	m.add_child(Palette.cylinder(0.06, 0.05, 0.14, Vector3(p.x + 0.5, 0.86, p.z - 0.15), Palette.EMAS, 0.4))
	# Kursi Ustadzah (sandaran di utara, menghadap selatan).
	var k := Node3D.new()
	k.name = "KursiUstadzah"
	add_child(k)
	k.add_child(Palette.box(Vector3(0.5, 0.06, 0.5), Vector3(p.x, 0.45, p.z - 0.75), Palette.JATI))
	k.add_child(Palette.box(Vector3(0.5, 0.6, 0.06), Vector3(p.x, 0.78, p.z - 0.97), Palette.JATI))
	for sx in [-0.2, 0.2]:
		for sz in [-0.95, -0.55]:
			k.add_child(Palette.box(Vector3(0.05, 0.45, 0.05), Vector3(p.x + sx, 0.225, p.z + sz), Palette.KAYU_GELAP))


## Meja santriwati: papan jati 1,2x0,55 + 4 kaki + 1 kitab di atas
## (beberapa meja). 2 kursi di sisi selatan (menghadap papan tulis
## di utara — sandaran di selatan). pos = pusat meja.
func _meja_santri(pos: Vector3, idx: int) -> void:
	var m := Node3D.new()
	m.name = "MejaSantri_%d" % idx
	add_child(m)
	m.add_child(Palette.box(Vector3(1.2, 0.06, 0.55), Vector3(pos.x, 0.72, pos.z), Palette.JATI))
	for sx in [-0.52, 0.52]:
		for sz in [-0.2, 0.2]:
			m.add_child(Palette.box(Vector3(0.06, 0.72, 0.06), Vector3(pos.x + sx, 0.36, pos.z + sz), Palette.KAYU_GELAP))
	# Kitab di atas meja (meja ganjil: zamrud, genap: krem).
	var warna_kitab := Palette.ZAMRUD_GELAP if idx % 2 == 1 else Color("#f2ead6")
	m.add_child(Palette.box(Vector3(0.3, 0.05, 0.22), Vector3(pos.x - 0.25, 0.78, pos.z - 0.1), warna_kitab))
	# 2 kursi (kiri-kanan), sandaran di selatan.
	for c in range(2):
		var kx := pos.x - 0.3 + float(c) * 0.6
		var kz := pos.z + 0.55
		var kursi := Node3D.new()
		kursi.name = "Kursi_%02d" % ((idx - 1) * 2 + c + 1)
		add_child(kursi)
		kursi.add_child(Palette.box(Vector3(0.45, 0.05, 0.45), Vector3(kx, 0.45, kz), Palette.KAYU))
		kursi.add_child(Palette.box(Vector3(0.45, 0.5, 0.05), Vector3(kx, 0.72, kz + 0.22), Palette.KAYU))
		for sx in [-0.18, 0.18]:
			for sz in [-0.18, 0.18]:
				kursi.add_child(Palette.box(Vector3(0.04, 0.45, 0.04), Vector3(kx + sx, 0.225, kz + sz), Palette.KAYU_GELAP))


## Lampu hangat gantung: OmniLight3D + gantungan + kap emas + bola
## (pola Cangkruk ronde 8 — bola punya COLLISION r=0,28 supaya
## SpringArm kamera mengerut sebelum masuk ke dalam bola).
func _lampu_hangat(pos: Vector3, nama: String) -> void:
	var grup := Node3D.new()
	grup.name = nama
	grup.position = pos
	add_child(grup)
	var lampu := OmniLight3D.new()
	lampu.name = "Cahaya"
	lampu.position = Vector3(0, 3.3, 0)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.7
	lampu.set_meta("energi_siang", 0.7)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 10.0
	lampu.shadow_enabled = false
	grup.add_child(lampu)
	grup.add_child(Palette.cylinder(0.03, 0.03, 0.2, Vector3(0, 3.5, 0), Palette.KAYU_GELAP))
	grup.add_child(Palette.cylinder(0.1, 0.1, 0.06, Vector3(0, 3.35, 0), Palette.EMAS, 0.4))
	grup.add_child(Palette.sphere(0.16, Vector3(0, 3.28, 0), Color("#ffe6b8")))
	var body := StaticBody3D.new()
	body.name = "LampuCollision"
	grup.add_child(body)
	var bentuk := CollisionShape3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.28
	bentuk.shape = bola
	bentuk.position = Vector3(0, 3.28, 0)
	body.add_child(bentuk)


## Jendela kayu (pola Cangkruk ronde 10): bingkai + kaca emissive +
## jeruji silang + ambang + cahaya jendela (grup "CahayaJendela").
## Dinding TIDAK dilubangi (collision utuh).
func _jendela(pos: Vector3, rot_y: float, nama: String) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, 0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, -0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(-0.51, 0, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(0.51, 0, 0.03), Palette.KAYU_GELAP))
	var kaca_mat := StandardMaterial3D.new()
	kaca_mat.albedo_color = Color("#bcd8e8")
	kaca_mat.emission_enabled = true
	kaca_mat.emission = Color("#cfe8f5")
	kaca_mat.emission_energy_multiplier = 1.0
	kaca_mat.roughness = 0.15
	var kaca := MeshInstance3D.new()
	var kaca_mesh := BoxMesh.new()
	kaca_mesh.size = Vector3(0.94, 1.12, 0.03)
	kaca.mesh = kaca_mesh
	kaca.position = Vector3(0, 0, 0.015)
	kaca.material_override = kaca_mat
	kaca.name = "Kaca"
	kaca.add_to_group("KacaJendela")
	g.add_child(kaca)
	g.add_child(Palette.box(Vector3(0.05, 1.12, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.94, 0.05, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.2, 0.06, 0.12), Vector3(0, -0.65, 0.06), Palette.KAYU_GELAP))
	var cahaya := OmniLight3D.new()
	cahaya.name = "CahayaJendela"
	cahaya.position = Vector3(0, 0, 0.7)
	cahaya.light_color = Color("#ffeecf")
	cahaya.light_energy = 1.6
	cahaya.omni_range = 9.0
	cahaya.shadow_enabled = false
	cahaya.set_meta("energi_siang", 1.6)
	cahaya.add_to_group("CahayaJendela")
	g.add_child(cahaya)
