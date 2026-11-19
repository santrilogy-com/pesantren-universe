class_name InteriorCangkruk
extends Node3D
## Interior kamar cangkruk — MAP TERPISAH kedua ala GTA (RONDE 6).
##
## Kamar kayu 14 x 10 m, tinggi 3,6 m, pusat (-60, 0, -300): tempat
## TIDUR + GANTI BAJU. Pintu di dinding selatan (z=-295, celah 1,6 m
## |x+60|<0,8) — sama persis dengan koridor pintu yang di-hardcode
## di main.gd (_cek_pintu_cangkruk: keluar saat |x+60|<0,8 dan z di
## (-295, -293,5)). Dinding selatan TETAP di z=-295 supaya koridor
## itu bekerja tanpa perubahan.
##
## REVISI 23:01 WIB (Mas: "ala POS RONDA tapi tertutup dan luas,
## ada kamar di dalam, isi 5 kasur dulu buat santri"): ruangan
## diperbesar dari 8x6 m menjadi 14x10 m, dinding penuh (tertutup),
## isi LIMA tempat tidur berjajar rapi — 2 di dinding barat, 2 di
## dinding timur, 1 di tengah dinding utara — dengan jalan di tengah
## (koridor 3 m dari pintu ke kasur utara). Tidur bisa di kasur mana
## saja (main.gd snap ke kasur TERDEKAT). Lemari ganti baju tetap di
## dinding timur dekat pintu, meja + lampu tetap di barat dekat pintu.
##
## ISI: 5 tempat tidur + lemari pakaian (dinding timur, LEMARI_SPOT
## untuk interaksi ganti baju) + meja kecil + lampu hangat + karpet
## + label KELUAR di atas pintu + 3 JENDELA (RONDE 10: barat, timur,
## selatan — bingkai kayu + kaca terang + cahaya jendela supaya
## interior tidak gelap di siang hari). TIDAK ADA papan di sini.
##
## INTERFACE (sama seperti InteriorSurau.build()):
##   build() -> {
##     "root": Node3D, "interior_door": Vector3(-60,0,-295),
##     "interior_spawn": Vector3(-60,0,-296.5),
##     "bed_pos_list": [Vector3 x5],
##     "lemari_spot": Vector3(-54.6,0,-296.8),
##     "cangkruk_bounds": {"min_x":-67, "max_x":-53, "min_z":-305, "max_z":-295},
##   }
##
## Dipakai dua cara: (1) InteriorCangkruk.build() dari main.gd;
## (2) scene res://scenes/interior_cangkruk.tscn untuk tes/isolasi —
## _ready() membangun isi kalau belum ada.
## RONDE 6 (perbaikan DOUBLE SURAU): interior ini DISEMBUNYIKAN
## (visible=false) saat pemain di luar — main.gd yang mengatur.

const ROOM_CENTER := Vector3(-60, 0, -300)
const ROOM_HALF_X := 7.0
const ROOM_HALF_Z := 5.0
const WALL_HEIGHT := 3.6
const DOOR_HALF := 0.8
const DOOR_TOP := 2.2
const INTERIOR_DOOR := Vector3(-60, 0, -295)
const INTERIOR_SPAWN := Vector3(-60, 0, -296.5)
## 5 kasur (kepala di utara): barat-utara, barat-selatan,
## timur-utara, timur-selatan, utara-tengah. Jalan 3 m di tengah.
const BED_POS_LIST: Array[Vector3] = [
	Vector3(-66.0, 0, -303.3),
	Vector3(-66.0, 0, -300.3),
	Vector3(-54.0, 0, -303.3),
	Vector3(-54.0, 0, -300.3),
	Vector3(-60.0, 0, -303.7),
]
const LEMARI_SPOT := Vector3(-54.6, 0, -296.8)
const CANGKRUK_BOUNDS := {"min_x": -67.0, "max_x": -53.0, "min_z": -305.0, "max_z": -295.0}


func _ready() -> void:
	if get_child_count() == 0:
		_bangun()


## Bangun interior (dipakai main.gd). Mengembalikan dict dengan
## interface yang sama seperti InteriorSurau.build().
static func build() -> Dictionary:
	var node := InteriorCangkruk.new()
	node.name = "InteriorCangkruk"
	node._bangun()
	return {
		"root": node,
		"interior_door": INTERIOR_DOOR,
		"interior_spawn": INTERIOR_SPAWN,
		"bed_pos_list": BED_POS_LIST,
		"lemari_spot": LEMARI_SPOT,
		"cangkruk_bounds": CANGKRUK_BOUNDS,
	}


func _bangun() -> void:
	# --- Lantai kayu + karpet (di jalan tengah) ---
	_static_box(self, Vector3(14, 0.14, 10), Vector3(-60, -0.05, -300), Palette.KAYU_GELAP).name = "Lantai"
	add_child(Palette.box(Vector3(3.0, 0.05, 2.0), Vector3(-60, 0.05, -300.5), Color("#a33b3b")))
	# --- Dinding kayu (collision): utara, barat, timur utuh; selatan
	# dua segmen + ambang pintu 1,6 m. Tebal 0,25, tinggi 3,6.
	_static_box(self, Vector3(14.5, WALL_HEIGHT, 0.25), Vector3(-60, 1.8, -305), Palette.KAYU).name = "DindingUtara"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 10), Vector3(-67, 1.8, -300), Palette.KAYU).name = "DindingBarat"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 10), Vector3(-53, 1.8, -300), Palette.KAYU).name = "DindingTimur"
	_static_box(self, Vector3(6.2, WALL_HEIGHT, 0.25), Vector3(-63.9, 1.8, -295), Palette.KAYU).name = "DindingSelatan_Kiri"
	_static_box(self, Vector3(6.2, WALL_HEIGHT, 0.25), Vector3(-56.1, 1.8, -295), Palette.KAYU).name = "DindingSelatan_Kanan"
	_static_box(self, Vector3(1.6, 1.4, 0.25), Vector3(-60, 2.9, -295), Palette.KAYU).name = "AmbangPintu"
	# --- Plafon kayu (RONDE 7: pakai _static_box — plafon HARUS punya
	# collision supaya SpringArm3D kamera memendek saat kamera akan
	# keluar ruangan ke atas; tanpa collision, kamera tidur di y≈4,0
	# menembus plafon 3,6 m dan layar penuh kayu) ---
	_static_box(self, Vector3(14.5, 0.25, 10.5), Vector3(-60, 3.72, -300), Palette.KAYU_GELAP).name = "Plafon"
	# --- Lis emas di atas pintu + tiang pintu bundar (dalam) ---
	add_child(Palette.box(Vector3(1.6, 0.1, 0.3), Vector3(-60, 2.25, -295), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.06, 0.06, 2.2, Vector3(-60.72, 1.1, -295), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.06, 0.06, 2.2, Vector3(-59.28, 1.1, -295), Palette.EMAS, 0.4))
	# Label KELUAR di atas pintu (menghadap ke dalam ruangan).
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari LUAR ruangan, lewat pintu) — sisi belakang
	# label lama terbaca cermin dari luar (pola yang sama seperti
	# KELUAR Surau/Musholla).
	var keluar := Palette.label3d("KELUAR", Vector3(-60, 2.7, -294.8), 22, Color("#f2c14e"), false)
	keluar.name = "LabelKeluar"
	keluar.rotation_degrees = Vector3(0, 180, 0)
	keluar.double_sided = false
	add_child(keluar)
	var keluar_luar := Palette.label3d("KELUAR", Vector3(-60, 2.7, -294.7), 22, Color("#f2c14e"), false)
	keluar_luar.name = "LabelKeluarBelakang"
	keluar_luar.double_sided = false
	add_child(keluar_luar)
	# --- Lampu hangat gantung (1, di sudut barat-laut) ---
	# RONDE 8 (retest: bangun tidur -> layar 80% hitam, kamera terjepit
	# bola lampu): lampu DULU di tengah ruangan (-60,-300) — TEPAT di
	# garis kamera saat bangun dari kasur utara-tengah (kamera di
	# (-60,2.97,-299.8), bola di (-60,3.05,-300), jarak 0,22 m).
	# Dipindah ke sudut barat-laut (-65.5,-303.5, di atas kasur barat-
	# utara — jauh dari garis kamera semua kasur), dinaikkan (bola
	# 3.05 -> 3.28), + collision bola supaya SpringArm mengerut kalau
	# kamera mendekat dari arah mana pun.
	_lampu_hangat(Vector3(-65.5, 0, -303.5))
	# --- JENDELA (RONDE 10, Mas: "Tambah jendela") — interior siang
	# hari gelap (tanpa jendela, 1 lampu). 3 jendela kayu gaya pos
	# ronda: barat + timur di celah antara 2 kasur tiap sisi
	# (z=-301.8, di antara kasur -303.3 dan -300.3) + selatan
	# mengapit pintu sisi barat (x=-63.9, di antara meja dan pintu).
	# Tiap jendela: bingkai kayu + kaca biru terang + jeruji silang
	# + ambang + lampu cahaya jendela (OmniLight, grup "CahayaJendela"
	# — LangitDinamis menyalakan di siang hari, meredupkan di malam
	# hari; BUKAN grup "LampuCahaya" yang justru 2x lebih terang di
	# malam hari). Dinding TIDAK dilubangi (collision utuh).
	_jendela(Vector3(-66.875, 1.7, -301.8), PI / 2.0, "JendelaBarat")
	_jendela(Vector3(-53.125, 1.7, -301.8), -PI / 2.0, "JendelaTimur")
	_jendela(Vector3(-63.9, 1.7, -294.875), 0.0, "JendelaSelatan")
	# --- LIMA tempat tidur (barat 2, timur 2, utara-tengah 1) ---
	for i in range(BED_POS_LIST.size()):
		_tempat_tidur(BED_POS_LIST[i], i + 1)
	# --- Lemari pakaian (dinding timur, dekat pintu) ---
	_lemari(Vector3(-53.6, 0, -296.8))
	# --- Meja kecil + lampu meja (dinding barat, dekat pintu) ---
	_meja_kecil(Vector3(-66.2, 0, -296.8))


## Kotak visual + collision (pola yang sama seperti InteriorSurau).
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


## Lampu hangat gantung: OmniLight3D + gantungan kayu + kap emas +
## bola lampu kuning hangat. Masuk grup "LampuCahaya" supaya
## LangitDinamis menerangkannya di malam hari (pola InteriorSurau).
## RONDE 8: bola lampu punya COLLISION (StaticBody3D, r=0,28) supaya
## SpringArm kamera mengerut sebelum kamera masuk ke dalam bola —
## tanpa ini kamera bisa terjepit di bola dan layar jadi hitam.
func _lampu_hangat(pos: Vector3) -> void:
	var grup := Node3D.new()
	grup.name = "LampuCangkruk"
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


## Jendela kayu gaya pos ronda di dinding interior (RONDE 10).
## Grup diposisikan di MUKA DALAM dinding, local +Z menghadap ke
## dalam ruangan (diputar via rot_y). Isi: bingkai kayu 4 sisi +
## kaca biru terang (emissive, grup "KacaJendela" — LangitDinamis
## mengatur terangnya ikut siang/malam) + jeruji silang kayu +
## ambang bawah + lampu cahaya jendela (OmniLight 0.7 m di dalam
## ruangan, grup "CahayaJendela", energi siang 0.55 — inilah yang
## membuat interior lebih terang di siang hari, bukan hiasan).
## Dinding TIDAK dilubangi (collision utuh) — kaca menempel di muka
## dinding seperti jendela sungguhan dari dalam.
func _jendela(pos: Vector3, rot_y: float, nama: String) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	# Bingkai kayu (KAYU_GELAP): atas, bawah, kiri, kanan.
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, 0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, -0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(-0.51, 0, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(0.51, 0, 0.03), Palette.KAYU_GELAP))
	# Kaca biru terang (emissive — membaca sebagai cahaya siang).
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
	# Jeruji silang kayu (gaya pos ronda) + ambang bawah.
	g.add_child(Palette.box(Vector3(0.05, 1.12, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.94, 0.05, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.2, 0.06, 0.12), Vector3(0, -0.65, 0.06), Palette.KAYU_GELAP))
	# Cahaya jendela: OmniLight hangat di dalam ruangan. RONDE 10
	# (koreksi pengukuran): energi 0.55 + range 6.0 TERLALU REDUP —
	# foto interior siang mean luminance 47 (sama gelapnya dengan
	# ronde 9: 51) — jendela jadi hiasan, bukan sumber cahaya. Kini
	# 1.6 + range 9.0: jelas lebih kuat dari lampu gantung (0.7,
	# range 10) supaya siang hari ruangan TERANG karena jendela.
	# LangitDinamis tetap meredupkannya di malam hari (x0.05).
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


## Tempat tidur: rangka kayu + kasur krem + bantal putih + selimut
## zamrud. Panjang 2,1 m (sumbu z), lebar 1,1 m (sumbu x), kepala di
## utara (menempel dinding utara). pos = pusat tempat tidur.
## idx = nomor kasur (1..5) — nama node unik "TempatTidur1..5".
func _tempat_tidur(pos: Vector3, idx: int) -> void:
	var t := Node3D.new()
	t.name = "TempatTidur%d" % idx
	add_child(t)
	# Rangka + kepala tempat tidur.
	t.add_child(Palette.box(Vector3(1.1, 0.25, 2.1), Vector3(pos.x, 0.2, pos.z), Palette.KAYU_GELAP))
	t.add_child(Palette.box(Vector3(1.1, 0.9, 0.08), Vector3(pos.x, 0.55, pos.z - 1.05), Palette.KAYU_GELAP))
	# Kasur + bantal + selimut (menutupi setengah bawah kasur).
	t.add_child(Palette.box(Vector3(1.0, 0.18, 2.0), Vector3(pos.x, 0.42, pos.z), Color("#faf3e3")))
	t.add_child(Palette.box(Vector3(0.7, 0.12, 0.4), Vector3(pos.x, 0.55, pos.z - 0.75), Color("#ffffff")))
	t.add_child(Palette.box(Vector3(1.02, 0.08, 1.1), Vector3(pos.x, 0.55, pos.z + 0.45), Palette.ZAMRUD))
	# Kaki tempat tidur.
	for sx in [-0.45, 0.45]:
		for sz in [-0.95, 0.95]:
			t.add_child(Palette.cylinder(0.05, 0.05, 0.2, Vector3(pos.x + sx, 0.1, pos.z + sz), Palette.KAYU_GELAP))


## Lemari pakaian: badan kayu tinggi + 2 pintu + kenop emas + rak
## dalam (terlihat dari depan sebagai garis). pos = pusat lemari,
## menempel dinding timur (x=-53,6). LEMARI_SPOT (-54,6, 0, -296,8)
## adalah tempat pemain berdiri saat membuka panel ganti baju.
func _lemari(pos: Vector3) -> void:
	var l := Node3D.new()
	l.name = "Lemari"
	add_child(l)
	l.add_child(Palette.box(Vector3(0.55, 2.2, 1.6), Vector3(pos.x, 1.1, pos.z), Palette.KAYU))
	l.add_child(Palette.box(Vector3(0.06, 2.0, 0.72), Vector3(pos.x - 0.3, 1.1, pos.z - 0.4), Palette.KAYU_GELAP))
	l.add_child(Palette.box(Vector3(0.06, 2.0, 0.72), Vector3(pos.x - 0.3, 1.1, pos.z + 0.4), Palette.KAYU_GELAP))
	l.add_child(Palette.sphere(0.05, Vector3(pos.x - 0.35, 1.1, pos.z - 0.08), Palette.EMAS, 0.4))
	l.add_child(Palette.sphere(0.05, Vector3(pos.x - 0.35, 1.1, pos.z + 0.08), Palette.EMAS, 0.4))
	# Cermin kecil di pintu kanan.
	l.add_child(Palette.box(Vector3(0.02, 1.2, 0.5), Vector3(pos.x - 0.34, 1.3, pos.z + 0.4), Color("#cfe0f0"), 0.15))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): lemari tanpa collision —
	# pemain tembus (probe baseline). Kotak (0,55 x 2,2 x 1,6)
	# mengikuti badan lemari persis. LEMARI_SPOT (-54,6,-296,8)
	# 0,375 m dari muka barat lemari — tetap terjangkau.
	var lemari_body := StaticBody3D.new()
	lemari_body.position = Vector3(pos.x, 1.1, pos.z)
	var lemari_shape := CollisionShape3D.new()
	var lemari_box := BoxShape3D.new()
	lemari_box.size = Vector3(0.55, 2.2, 1.6)
	lemari_shape.shape = lemari_box
	lemari_body.add_child(lemari_shape)
	l.add_child(lemari_body)


## Meja kecil di samping pintu: papan bundar + kaki + lampu meja.
func _meja_kecil(pos: Vector3) -> void:
	var m := Node3D.new()
	m.name = "MejaKecil"
	add_child(m)
	var atas := Palette.cylinder(0.45, 0.45, 0.06, Vector3(pos.x, 0.55, pos.z), Palette.KAYU)
	m.add_child(atas)
	m.add_child(Palette.cylinder(0.04, 0.05, 0.55, Vector3(pos.x, 0.28, pos.z), Palette.KAYU_GELAP))
	# Lampu meja: tiang + kap + bola hangat.
	m.add_child(Palette.cylinder(0.03, 0.03, 0.3, Vector3(pos.x, 0.75, pos.z), Palette.EMAS, 0.4))
	m.add_child(Palette.cylinder(0.12, 0.16, 0.18, Vector3(pos.x, 0.95, pos.z), Color("#ffe6b8")))
	# Kitab di atas meja.
	m.add_child(Palette.box(Vector3(0.3, 0.05, 0.22), Vector3(pos.x + 0.2, 0.61, pos.z + 0.15), Palette.ZAMRUD_GELAP))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): meja kecil tanpa collision
	# — pemain tembus (probe baseline). Silinder r=0,45 h=0,6
	# mengikuti papan atas (r=0,45, y 0,55); lampu di atasnya
	# (y 0,6..1,04) di atas kapsul pemain, tak perlu.
	var meja_body := StaticBody3D.new()
	meja_body.position = Vector3(pos.x, 0.3, pos.z)
	var meja_shape := CollisionShape3D.new()
	var meja_cyl := CylinderShape3D.new()
	meja_cyl.radius = 0.45
	meja_cyl.height = 0.6
	meja_shape.shape = meja_cyl
	meja_body.add_child(meja_shape)
	m.add_child(meja_body)
