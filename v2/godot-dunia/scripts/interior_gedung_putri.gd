class_name InteriorGedungPutri
extends Node3D
## Interior gedung putri LAINNYA — Tim Area Putri (Lestari, lead Nadia),
## 18 Nov 2026. Empat MAP TERPISAH pola InteriorCangkruk (GTA-style):
## Kantor Ustadzah, Madrasah, Studio, Pos Jaga TL. Asrama / Musholla /
## Kelas dikerjakan tim lain — JANGAN disentuh dari sini.
##
## Zona map: garis z=-300 (sama seperti Surau / Cangkruk / Musholla),
## pusat x -180 / -120 / +180 / +240 — jauh dari map yang sudah ada
## (Surau x~0, Cangkruk x -67..-53, Musholla x 53..67) supaya tidak
## tabrakan, dan jauh satu sama lain. Ukuran ruangan = ukuran cangkang
## di kampus_putri.gd (Kantor 8x6, Madrasah 10x8, Studio 10x8,
## Pos Jaga 3x3). Pintu interior menghadap sisi yang SAMA dengan pintu
## cangkang: Kantor W, Madrasah W, Studio N, Pos Jaga W.
##
## INTERFACE (satu fungsi build per gedung, dikembalikan dict):
##   build_kantor() -> {"root": Node3D, "interior_door": Vector3,
##     "interior_spawn": Vector3, "bounds": {...},
##     "meja_pos": Vector3, "lemari_pos": Vector3, "rak_pos": Vector3,
##     "papan_pos": Vector3}
##   build_madrasah() / build_studio() / build_pos_jaga() sama polanya
##   (kunci spot menyesuaikan isi tiap gedung).
## Dipakai dua cara: (1) build_*() dari main.gd saat integrasi (Nadia);
## (2) skrip tes/foto di skrip/ — _ready() TIDAK membangun apa-apa
## (satu node bisa jadi gedung mana saja, jadi bangun eksplisit).
##
## Palet (brief): krem #F2EAD6, zamrud #065F46, emas #C9A227,
## jati #7B4B2A. Gaya primitif Godot — tanpa Blender. SEMUA perabot
## punya collision (StaticBody3D) — tidak bisa ditembus.

## --- Kantor Ustadzah: 8x6 m, tinggi 3,4, pintu BARAT (x=-124) ---
const KANTOR_CENTER := Vector3(-120, 0, -300)
const KANTOR_DOOR := Vector3(-124, 0, -300)
const KANTOR_SPAWN := Vector3(-122.5, 0, -300)
const KANTOR_BOUNDS := {"min_x": -124.0, "max_x": -116.0, "min_z": -303.0, "max_z": -297.0}
const KANTOR_TINGGI := 3.4
const KANTOR_MEJA := Vector3(-116.55, 0, -300)
const KANTOR_KURSI := Vector3(-117.9, 0, -300)
const KANTOR_LEMARI := Vector3(-122.3, 0, -302.6)
const KANTOR_RAK := Vector3(-118.3, 0, -297.325)
const KANTOR_PAPAN := Vector3(-118.5, 1.6, -302.82)
## --- Madrasah: 10x8 m, tinggi 3,8, pintu BARAT (x=-185) ---
const MADRASAH_CENTER := Vector3(-180, 0, -300)
const MADRASAH_DOOR := Vector3(-185, 0, -300)
const MADRASAH_SPAWN := Vector3(-183.5, 0, -300)
const MADRASAH_BOUNDS := {"min_x": -185.0, "max_x": -175.0, "min_z": -304.0, "max_z": -296.0}
const MADRASAH_TINGGI := 3.8
const MADRASAH_PAPAN := Vector3(-180, 1.7, -303.82)
const MADRASAH_MEJA_GURU := Vector3(-175.55, 0, -302.6)
const MADRASAH_KURSI_GURU := Vector3(-177.4, 0, -302.6)
const MADRASAH_LEMARI := Vector3(-184.3, 0, -303.6)
const MADRASAH_RAK := Vector3(-180.5, 0, -296.325)
const MADRASAH_MEJA_MURID := [Vector3(-182.0, 0, -298.3), Vector3(-178.8, 0, -298.3)]
const MADRASAH_KURSI_MURID := [Vector3(-182.0, 0, -297.4), Vector3(-178.8, 0, -297.4)]
## --- Studio: 10x8 m, tinggi 3,6, pintu UTARA (z=-304) ---
const STUDIO_CENTER := Vector3(240, 0, -300)
const STUDIO_DOOR := Vector3(240, 0, -304)
const STUDIO_SPAWN := Vector3(240, 0, -302.5)
const STUDIO_BOUNDS := {"min_x": 235.0, "max_x": 245.0, "min_z": -304.0, "max_z": -296.0}
const STUDIO_TINGGI := 3.6
const STUDIO_MEJA := Vector3(244.45, 0, -301.0)
const STUDIO_KURSI := Vector3(243.1, 0, -301.0)
const STUDIO_MEJA2 := Vector3(235.55, 0, -299.0)
const STUDIO_KURSI2 := Vector3(236.9, 0, -299.0)
const STUDIO_RAK := Vector3(242.6, 0, -303.65)
const STUDIO_PAPAN := Vector3(238.0, 1.6, -296.18)
## --- Pos Jaga TL: 3x3 m, tinggi 2,6, pintu BARAT (x=178,5) ---
## Pintu cangkang 1,2 m (bukan 1,6 m) dan tinggi 1,8 m — interior ikut.
const POS_CENTER := Vector3(180, 0, -300)
const POS_DOOR := Vector3(178.5, 0, -300)
const POS_SPAWN := Vector3(179.6, 0, -299.6)
const POS_BOUNDS := {"min_x": 178.5, "max_x": 181.5, "min_z": -301.5, "max_z": -298.5}
const POS_TINGGI := 2.6
const POS_MEJA := Vector3(180.5, 0, -301.05)
const POS_KURSI := Vector3(180.5, 0, -300.35)
const POS_LEMARI := Vector3(181.15, 0, -299.3)
const POS_PAPAN := Vector3(179.8, 1.5, -298.68)

const TEBAL_DINDING := 0.25
const LEBAR_PINTU := 1.6
const TINGGI_PINTU := 2.6
const LEBAR_PINTU_POS := 1.2
const TINGGI_PINTU_POS := 1.8


func _ready() -> void:
	# Sengaja kosong: satu node bisa jadi gedung mana saja — bangun
	# eksplisit lewat build_kantor() / build_madrasah() /
	# build_studio() / build_pos_jaga() (pola InteriorCangkruk.build()).
	pass


## ------------------------- BUILD (satu per gedung) -------------------------

static func build_kantor() -> Dictionary:
	var node := InteriorGedungPutri.new()
	node.name = "InteriorKantorUstadzah"
	node._bangun_kantor()
	return {
		"root": node,
		"interior_door": KANTOR_DOOR,
		"interior_spawn": KANTOR_SPAWN,
		"bounds": KANTOR_BOUNDS,
		"meja_pos": KANTOR_MEJA,
		"kursi_pos": KANTOR_KURSI,
		"lemari_pos": KANTOR_LEMARI,
		"rak_pos": KANTOR_RAK,
		"papan_pos": KANTOR_PAPAN,
	}


static func build_madrasah() -> Dictionary:
	var node := InteriorGedungPutri.new()
	node.name = "InteriorMadrasah"
	node._bangun_madrasah()
	return {
		"root": node,
		"interior_door": MADRASAH_DOOR,
		"interior_spawn": MADRASAH_SPAWN,
		"bounds": MADRASAH_BOUNDS,
		"papan_pos": MADRASAH_PAPAN,
		"meja_guru_pos": MADRASAH_MEJA_GURU,
		"kursi_guru_pos": MADRASAH_KURSI_GURU,
		"lemari_pos": MADRASAH_LEMARI,
		"rak_pos": MADRASAH_RAK,
		"meja_murid_pos": MADRASAH_MEJA_MURID,
		"kursi_murid_pos": MADRASAH_KURSI_MURID,
	}


static func build_studio() -> Dictionary:
	var node := InteriorGedungPutri.new()
	node.name = "InteriorStudio"
	node._bangun_studio()
	return {
		"root": node,
		"interior_door": STUDIO_DOOR,
		"interior_spawn": STUDIO_SPAWN,
		"bounds": STUDIO_BOUNDS,
		"meja_pos": STUDIO_MEJA,
		"kursi_pos": STUDIO_KURSI,
		"meja2_pos": STUDIO_MEJA2,
		"kursi2_pos": STUDIO_KURSI2,
		"rak_pos": STUDIO_RAK,
		"papan_pos": STUDIO_PAPAN,
	}


static func build_pos_jaga() -> Dictionary:
	var node := InteriorGedungPutri.new()
	node.name = "InteriorPosJaga"
	node._bangun_pos_jaga()
	return {
		"root": node,
		"interior_door": POS_DOOR,
		"interior_spawn": POS_SPAWN,
		"bounds": POS_BOUNDS,
		"meja_pos": POS_MEJA,
		"kursi_pos": POS_KURSI,
		"lemari_pos": POS_LEMARI,
		"papan_pos": POS_PAPAN,
	}

## ------------------------- KANTOR USTADZAH -------------------------
## 8x6 m (x -124..-116, z -303..-297), pintu BARAT di (-124,-300).
## Isi: meja kerja + kursi (dinding timur), lemari arsip (utara),
## rak buku kecil (selatan), papan pengumuman (utara), lampu, karpet,
## 2 jendela (utara + selatan, ikut cangkang: pintu W -> jendela N/S).

func _bangun_kantor() -> void:
	var c := KANTOR_CENTER
	# Lantai krem + karpet zamrud di tengah (visual saja).
	_static_box(self, Vector3(8, 0.14, 6), Vector3(c.x, -0.05, c.z), Palette.KREM).name = "Lantai"
	add_child(Palette.box(Vector3(2.2, 0.05, 1.5), Vector3(c.x, 0.05, c.z), Palette.ZAMRUD_GELAP))
	# Dinding: utara, selatan, timur utuh; barat bercelah pintu 1,6 m.
	_static_box(self, Vector3(8.5, KANTOR_TINGGI, TEBAL_DINDING), Vector3(c.x, KANTOR_TINGGI / 2.0, c.z - 3), Palette.KREM).name = "DindingUtara"
	_static_box(self, Vector3(8.5, KANTOR_TINGGI, TEBAL_DINDING), Vector3(c.x, KANTOR_TINGGI / 2.0, c.z + 3), Palette.KREM).name = "DindingSelatan"
	_static_box(self, Vector3(TEBAL_DINDING, KANTOR_TINGGI, 6), Vector3(c.x + 4, KANTOR_TINGGI / 2.0, c.z), Palette.KREM).name = "DindingTimur"
	_static_box(self, Vector3(TEBAL_DINDING, KANTOR_TINGGI, 2.2), Vector3(c.x - 4, KANTOR_TINGGI / 2.0, c.z - 1.9), Palette.KREM).name = "DindingBarat_Utara"
	_static_box(self, Vector3(TEBAL_DINDING, KANTOR_TINGGI, 2.2), Vector3(c.x - 4, KANTOR_TINGGI / 2.0, c.z + 1.9), Palette.KREM).name = "DindingBarat_Selatan"
	_static_box(self, Vector3(TEBAL_DINDING, KANTOR_TINGGI - TINGGI_PINTU, LEBAR_PINTU), Vector3(c.x - 4, TINGGI_PINTU + (KANTOR_TINGGI - TINGGI_PINTU) / 2.0, c.z), Palette.KREM).name = "AmbangPintu"
	# Plafon krem (collision — pola InteriorCangkruk: kamera SpringArm).
	_static_box(self, Vector3(8.5, TEBAL_DINDING, 6.5), Vector3(c.x, KANTOR_TINGGI + 0.12, c.z), Palette.KREM).name = "Plafon"
	# Lis emas di atas pintu (dalam) + label KELUAR dua sisi.
	add_child(Palette.box(Vector3(0.3, 0.1, LEBAR_PINTU), Vector3(c.x - 3.85, TINGGI_PINTU + 0.05, c.z), Palette.EMAS_DESAIN, 0.4))
	_label_keluar(Vector3(c.x - 3.8, 2.7, c.z), PI / 2.0, Vector3(c.x - 4.2, 2.7, c.z), -PI / 2.0)
	# Perabot.
	_meja_kerja(KANTOR_MEJA, -PI / 2.0, "MejaKerja")
	_kursi(KANTOR_KURSI, PI / 2.0, "KursiKerja")
	_lemari(KANTOR_LEMARI, 0.0, "LemariArsip", 1.4, 2.0, 0.5)
	_rak_buku(KANTOR_RAK, PI, "RakBuku", 1.6, 1.8, 0.35)
	_papan(KANTOR_PAPAN, 0.0, "PapanPengumuman", "PENGUMUMAN", 2.0, 1.1, Palette.KREM, "pengumuman")
	# Lampu hangat di sudut timur-laut (jauh dari garis pintu->tengah,
	# pelajaran InteriorCangkruk ronde 8) + 2 jendela.
	_lampu_hangat(Vector3(-117.2, 0, -302.0), KANTOR_TINGGI, "LampuKantor")
	_jendela(Vector3(-121.0, 1.7, -302.875), 0.0, "JendelaUtara")
	_jendela(Vector3(-118.8, 1.7, -297.125), PI, "JendelaSelatan")


## ------------------------- MADRASAH -------------------------
## 10x8 m (x -185..-175, z -304..-296), pintu BARAT di (-185,-300).
## Ruang kelas/admin: papan tulis (utara), meja+kursi guru (timur),
## 2 meja+kursi murid, lemari (barat-laut), rak buku (selatan),
## lampu, 2 jendela (utara + selatan).

func _bangun_madrasah() -> void:
	var c := MADRASAH_CENTER
	_static_box(self, Vector3(10, 0.14, 8), Vector3(c.x, -0.05, c.z), Palette.KREM).name = "Lantai"
	add_child(Palette.box(Vector3(3.0, 0.05, 2.0), Vector3(c.x, 0.05, c.z + 1.0), Palette.ZAMRUD_GELAP))
	_static_box(self, Vector3(10.5, MADRASAH_TINGGI, TEBAL_DINDING), Vector3(c.x, MADRASAH_TINGGI / 2.0, c.z - 4), Palette.KREM).name = "DindingUtara"
	_static_box(self, Vector3(10.5, MADRASAH_TINGGI, TEBAL_DINDING), Vector3(c.x, MADRASAH_TINGGI / 2.0, c.z + 4), Palette.KREM).name = "DindingSelatan"
	_static_box(self, Vector3(TEBAL_DINDING, MADRASAH_TINGGI, 8), Vector3(c.x + 5, MADRASAH_TINGGI / 2.0, c.z), Palette.KREM).name = "DindingTimur"
	_static_box(self, Vector3(TEBAL_DINDING, MADRASAH_TINGGI, 3.2), Vector3(c.x - 5, MADRASAH_TINGGI / 2.0, c.z - 2.4), Palette.KREM).name = "DindingBarat_Utara"
	_static_box(self, Vector3(TEBAL_DINDING, MADRASAH_TINGGI, 3.2), Vector3(c.x - 5, MADRASAH_TINGGI / 2.0, c.z + 2.4), Palette.KREM).name = "DindingBarat_Selatan"
	_static_box(self, Vector3(TEBAL_DINDING, MADRASAH_TINGGI - TINGGI_PINTU, LEBAR_PINTU), Vector3(c.x - 5, TINGGI_PINTU + (MADRASAH_TINGGI - TINGGI_PINTU) / 2.0, c.z), Palette.KREM).name = "AmbangPintu"
	_static_box(self, Vector3(10.5, TEBAL_DINDING, 8.5), Vector3(c.x, MADRASAH_TINGGI + 0.12, c.z), Palette.KREM).name = "Plafon"
	add_child(Palette.box(Vector3(0.3, 0.1, LEBAR_PINTU), Vector3(c.x - 4.85, TINGGI_PINTU + 0.05, c.z), Palette.EMAS_DESAIN, 0.4))
	_label_keluar(Vector3(c.x - 4.8, 2.7, c.z), PI / 2.0, Vector3(c.x - 5.2, 2.7, c.z), -PI / 2.0)
	# Papan tulis hijau di dinding utara (tengah), menghadap selatan.
	_papan(MADRASAH_PAPAN, 0.0, "PapanTulis", "MADRASAH", 3.2, 1.3, Palette.ZAMRUD_GELAP, "tulis")
	# Meja + kursi guru (timur-laut), meja + kursi murid (2, selatan).
	_meja_kerja(MADRASAH_MEJA_GURU, -PI / 2.0, "MejaGuru")
	_kursi(MADRASAH_KURSI_GURU, PI / 2.0, "KursiGuru")
	for i in range(2):
		_meja_kerja(MADRASAH_MEJA_MURID[i], PI, "MejaMurid%d" % (i + 1), 1.2, 0.6)
		_kursi(MADRASAH_KURSI_MURID[i], PI, "KursiMurid%d" % (i + 1))
	_lemari(MADRASAH_LEMARI, 0.0, "LemariMadrasah", 1.2, 2.0, 0.5)
	_rak_buku(MADRASAH_RAK, PI, "RakBuku", 2.0, 1.8, 0.35)
	_lampu_hangat(Vector3(-177.0, 0, -302.8), MADRASAH_TINGGI, "LampuMadrasah")
	_jendela(Vector3(-182.5, 1.7, -303.875), 0.0, "JendelaUtara")
	_jendela(Vector3(-177.5, 1.7, -296.125), PI, "JendelaSelatan")


## ------------------------- STUDIO -------------------------
## 10x8 m (x 235..245, z -304..-296), pintu UTARA di (240,-304).
## Isi: 2 meja kerja + kursi (timur + barat), rak peralatan/media
## (utara), papan (selatan), lampu, 2 jendela (timur + barat,
## ikut cangkang: pintu N -> jendela E/W).

func _bangun_studio() -> void:
	var c := STUDIO_CENTER
	_static_box(self, Vector3(10, 0.14, 8), Vector3(c.x, -0.05, c.z), Palette.KREM).name = "Lantai"
	add_child(Palette.box(Vector3(2.5, 0.05, 1.8), Vector3(c.x, 0.05, c.z), Palette.ZAMRUD_GELAP))
	# Dinding: selatan, barat, timur utuh; utara bercelah pintu 1,6 m.
	_static_box(self, Vector3(10.5, STUDIO_TINGGI, TEBAL_DINDING), Vector3(c.x, STUDIO_TINGGI / 2.0, c.z + 4), Palette.KREM).name = "DindingSelatan"
	_static_box(self, Vector3(TEBAL_DINDING, STUDIO_TINGGI, 8), Vector3(c.x - 5, STUDIO_TINGGI / 2.0, c.z), Palette.KREM).name = "DindingBarat"
	_static_box(self, Vector3(TEBAL_DINDING, STUDIO_TINGGI, 8), Vector3(c.x + 5, STUDIO_TINGGI / 2.0, c.z), Palette.KREM).name = "DindingTimur"
	_static_box(self, Vector3(4.2, STUDIO_TINGGI, TEBAL_DINDING), Vector3(c.x - 2.9, STUDIO_TINGGI / 2.0, c.z - 4), Palette.KREM).name = "DindingUtara_Barat"
	_static_box(self, Vector3(4.2, STUDIO_TINGGI, TEBAL_DINDING), Vector3(c.x + 2.9, STUDIO_TINGGI / 2.0, c.z - 4), Palette.KREM).name = "DindingUtara_Timur"
	_static_box(self, Vector3(LEBAR_PINTU, STUDIO_TINGGI - TINGGI_PINTU, TEBAL_DINDING), Vector3(c.x, TINGGI_PINTU + (STUDIO_TINGGI - TINGGI_PINTU) / 2.0, c.z - 4), Palette.KREM).name = "AmbangPintu"
	_static_box(self, Vector3(10.5, TEBAL_DINDING, 8.5), Vector3(c.x, STUDIO_TINGGI + 0.12, c.z), Palette.KREM).name = "Plafon"
	add_child(Palette.box(Vector3(LEBAR_PINTU, 0.1, 0.3), Vector3(c.x, TINGGI_PINTU + 0.05, c.z - 3.85), Palette.EMAS_DESAIN, 0.4))
	_label_keluar(Vector3(c.x, 2.7, c.z - 3.8), 0.0, Vector3(c.x, 2.7, c.z - 4.2), PI)
	_meja_kerja(STUDIO_MEJA, -PI / 2.0, "MejaKerja")
	_kursi(STUDIO_KURSI, PI / 2.0, "KursiKerja")
	_meja_kerja(STUDIO_MEJA2, PI / 2.0, "MejaKerja2")
	_kursi(STUDIO_KURSI2, -PI / 2.0, "KursiKerja2")
	_rak_buku(STUDIO_RAK, 0.0, "RakPeralatan", 2.0, 1.8, 0.45, "alat")
	_papan(STUDIO_PAPAN, PI, "PapanStudio", "STUDIO", 2.0, 1.2, Palette.KREM, "pengumuman")
	_lampu_hangat(Vector3(243.5, 0, -297.8), STUDIO_TINGGI, "LampuStudio")
	_jendela(Vector3(244.875, 1.7, -299.0), -PI / 2.0, "JendelaTimur")
	_jendela(Vector3(235.125, 1.7, -301.0), PI / 2.0, "JendelaBarat")


## ------------------------- POS JAGA TL -------------------------
## 3x3 m (x 178,5..181,5, z -301,5..-298,5), pintu BARAT di (178,5,-300).
## Pintu 1,2 m x 1,8 m (ikut cangkang). Isi: meja jaga + kursi
## (utara), lemari kecil (timur), papan jadwal jaga (selatan), lampu.
## Tanpa jendela — cangkang pos tidak punya jendela.

func _bangun_pos_jaga() -> void:
	var c := POS_CENTER
	_static_box(self, Vector3(3, 0.14, 3), Vector3(c.x, -0.05, c.z), Palette.KREM).name = "Lantai"
	_static_box(self, Vector3(3.5, POS_TINGGI, TEBAL_DINDING), Vector3(c.x, POS_TINGGI / 2.0, c.z - 1.5), Palette.KREM).name = "DindingUtara"
	_static_box(self, Vector3(3.5, POS_TINGGI, TEBAL_DINDING), Vector3(c.x, POS_TINGGI / 2.0, c.z + 1.5), Palette.KREM).name = "DindingSelatan"
	_static_box(self, Vector3(TEBAL_DINDING, POS_TINGGI, 3), Vector3(c.x + 1.5, POS_TINGGI / 2.0, c.z), Palette.KREM).name = "DindingTimur"
	_static_box(self, Vector3(TEBAL_DINDING, POS_TINGGI, 0.9), Vector3(c.x - 1.5, POS_TINGGI / 2.0, c.z - 1.05), Palette.KREM).name = "DindingBarat_Utara"
	_static_box(self, Vector3(TEBAL_DINDING, POS_TINGGI, 0.9), Vector3(c.x - 1.5, POS_TINGGI / 2.0, c.z + 1.05), Palette.KREM).name = "DindingBarat_Selatan"
	_static_box(self, Vector3(TEBAL_DINDING, POS_TINGGI - TINGGI_PINTU_POS, LEBAR_PINTU_POS), Vector3(c.x - 1.5, TINGGI_PINTU_POS + (POS_TINGGI - TINGGI_PINTU_POS) / 2.0, c.z), Palette.KREM).name = "AmbangPintu"
	_static_box(self, Vector3(3.5, TEBAL_DINDING, 3.5), Vector3(c.x, POS_TINGGI + 0.12, c.z), Palette.KREM).name = "Plafon"
	add_child(Palette.box(Vector3(0.3, 0.08, LEBAR_PINTU_POS), Vector3(c.x - 1.35, TINGGI_PINTU_POS + 0.05, c.z), Palette.EMAS_DESAIN, 0.4))
	# Label KELUAR kecil (font 16, y 2,15 — di atas pintu 1,8 m).
	var keluar := Palette.label3d("KELUAR", Vector3(c.x - 1.3, 2.15, c.z), 16, Color("#f2c14e"), false)
	keluar.name = "LabelKeluar"
	keluar.rotation.y = PI / 2.0
	keluar.double_sided = false
	add_child(keluar)
	var keluar_luar := Palette.label3d("KELUAR", Vector3(c.x - 1.7, 2.15, c.z), 16, Color("#f2c14e"), false)
	keluar_luar.name = "LabelKeluarBelakang"
	keluar_luar.rotation.y = -PI / 2.0
	keluar_luar.double_sided = false
	add_child(keluar_luar)
	_meja_kerja(POS_MEJA, 0.0, "MejaJaga", 1.2, 0.6)
	_kursi(POS_KURSI, PI, "KursiJaga")
	_lemari(POS_LEMARI, -PI / 2.0, "LemariKecil", 0.8, 1.6, 0.4)
	_papan(POS_PAPAN, PI, "PapanJadwalJaga", "JADWAL JAGA", 1.2, 0.8, Palette.KREM, "jadwal")
	_lampu_hangat(Vector3(180.8, 0, -301.0), POS_TINGGI, "LampuPosJaga")

## ------------------------- HELPER (pola InteriorCangkruk) -------------------------
## Konvensi grup perabot: local +Z = arah hadap ke dalam ruangan
## (sisi pengguna untuk meja, sisi depan untuk lemari/rak/papan).
## _static_box(parent,...) = visual + StaticBody3D (collision).

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


## Label KELUAR di atas pintu: depan (menghadap ke dalam ruangan) +
## belakang (menghadap ke luar) — pola InteriorCangkruk ronde 6.
func _label_keluar(pos_depan: Vector3, rot_depan: float, pos_belakang: Vector3, rot_belakang: float) -> void:
	# y 3,0 (bukan 2,7): lis emas di atas pintu ada di y 2,65 — label
	# di 2,7 duduk TEPAT di atas lis sehingga teks tenggelam di
	# emasnya (ketahuan di foto Studio 18 Nov). Ambang pintu tinggi
	# 2,6..3,4+ jadi label di 3,0 masih di atas pintu.
	var depan := Palette.label3d("KELUAR", pos_depan + Vector3(0, 0.3, 0), 22, Color("#f2c14e"), false)
	depan.name = "LabelKeluar"
	depan.rotation.y = rot_depan
	depan.double_sided = false
	add_child(depan)
	var belakang := Palette.label3d("KELUAR", pos_belakang + Vector3(0, 0.3, 0), 22, Color("#f2c14e"), false)
	belakang.name = "LabelKeluarBelakang"
	belakang.rotation.y = rot_belakang
	belakang.double_sided = false
	add_child(belakang)


## Lampu hangat gantung (pola InteriorCangkruk ronde 8): OmniLight3D
## grup "LampuCahaya" + bola lampu BER-collision (r=0,28) supaya
## SpringArm kamera mengerut sebelum masuk ke bola. Tinggi lampu
## mengikuti plafon tiap gedung (Pos Jaga plafon 2,6 m — lampunya
## lebih pendek dari Kantor/Madrasah/Studio).
func _lampu_hangat(pos: Vector3, tinggi_plafon: float, nama: String) -> void:
	var grup := Node3D.new()
	grup.name = nama
	grup.position = pos
	add_child(grup)
	var y_cahaya := tinggi_plafon - 0.3
	var y_bola := tinggi_plafon - 0.32
	var lampu := OmniLight3D.new()
	lampu.name = "Cahaya"
	lampu.position = Vector3(0, y_cahaya, 0)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.7
	lampu.set_meta("energi_siang", 0.7)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 10.0
	lampu.shadow_enabled = false
	grup.add_child(lampu)
	grup.add_child(Palette.cylinder(0.03, 0.03, 0.25, Vector3(0, tinggi_plafon - 0.12, 0), Palette.KAYU_GELAP))
	grup.add_child(Palette.cylinder(0.1, 0.1, 0.06, Vector3(0, y_cahaya + 0.05, 0), Palette.EMAS_DESAIN, 0.4))
	grup.add_child(Palette.sphere(0.16, Vector3(0, y_bola, 0), Color("#ffe6b8")))
	var body := StaticBody3D.new()
	body.name = "LampuCollision"
	grup.add_child(body)
	var bentuk := CollisionShape3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.28
	bentuk.shape = bola
	bentuk.position = Vector3(0, y_bola, 0)
	body.add_child(bentuk)


## Jendela kayu gaya pos ronda (salinan InteriorCangkruk ronde 10):
## bingkai + kaca emissive (grup "KacaJendela") + jeruji + ambang +
## OmniLight grup "CahayaJendela" (energi siang 1,6). Dinding TIDAK
## dilubangi — kaca menempel di muka dalam dinding.
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


## Meja kerja jati: papan atas + blok laci penuh (collision menutup
## kolong — pemain tidak bisa merangkak lewat bawah meja) + kaki
## visual + kitab + tempat pena di atas. pos = pusat meja.
func _meja_kerja(pos: Vector3, rot_y: float, nama: String, lebar: float = 1.6, dalam: float = 0.8) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	_static_box(g, Vector3(lebar, 0.08, dalam), Vector3(0, 0.75, 0), Palette.JATI).name = "PapanMeja"
	_static_box(g, Vector3(lebar - 0.2, 0.68, dalam - 0.1), Vector3(0, 0.37, 0), Palette.KAYU).name = "BlokLaci"
	# Lis emas: BINGKAI tepi papan (4 strip tipis) — BUKAN pelat penuh:
	# pelat penuh menutupi seluruh papan dari atas sehingga meja
	# terbaca "meja emas" (ketahuan di foto 18 Nov). Jati tetap terlihat.
	for sx in [-1.0, 1.0]:
		var strip_sisi := Palette.box(Vector3(0.05, 0.03, dalam), Vector3(sx * (lebar / 2.0 - 0.025), 0.80, 0), Palette.EMAS_DESAIN, 0.4)
		strip_sisi.name = "LisMeja"
		g.add_child(strip_sisi)
	for sz in [-1.0, 1.0]:
		var strip_depan := Palette.box(Vector3(lebar, 0.03, 0.05), Vector3(0, 0.80, sz * (dalam / 2.0 - 0.025)), Palette.EMAS_DESAIN, 0.4)
		strip_depan.name = "LisMeja"
		g.add_child(strip_depan)
	# Kitab + tempat pena di atas meja (visual).
	g.add_child(Palette.box(Vector3(0.3, 0.05, 0.22), Vector3(-lebar / 4.0, 0.83, 0.1), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.cylinder(0.05, 0.05, 0.12, Vector3(lebar / 4.0, 0.86, -0.15), Palette.EMAS_DESAIN, 0.4))


## Kursi kayu: dudukan + sandaran (keduanya collision) + kaki visual.
## pos = pusat dudukan; local +Z = arah hadap yang duduk.
func _kursi(pos: Vector3, rot_y: float, nama: String) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	_static_box(g, Vector3(0.45, 0.08, 0.45), Vector3(0, 0.45, 0), Palette.JATI).name = "Dudukan"
	_static_box(g, Vector3(0.45, 0.55, 0.06), Vector3(0, 0.8, -0.2), Palette.JATI).name = "Sandaran"
	for sx in [-0.18, 0.18]:
		for sz in [-0.18, 0.18]:
			g.add_child(Palette.cylinder(0.03, 0.03, 0.45, Vector3(sx, 0.22, sz), Palette.KAYU_GELAP))


## Lemari arsip jati: badan penuh (collision) + 2 pintu visual +
## kenop emas + lis atas. pos = pusat lemari; local +Z = depan.
func _lemari(pos: Vector3, rot_y: float, nama: String, lebar: float, tinggi: float, dalam: float) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	_static_box(g, Vector3(lebar, tinggi, dalam), Vector3(0, tinggi / 2.0, 0), Palette.JATI).name = "BadanLemari"
	g.add_child(Palette.box(Vector3(lebar / 2.0 - 0.06, tinggi - 0.2, 0.04), Vector3(-lebar / 4.0, tinggi / 2.0, dalam / 2.0 + 0.01), Palette.KAYU))
	g.add_child(Palette.box(Vector3(lebar / 2.0 - 0.06, tinggi - 0.2, 0.04), Vector3(lebar / 4.0, tinggi / 2.0, dalam / 2.0 + 0.01), Palette.KAYU))
	g.add_child(Palette.sphere(0.04, Vector3(-0.06, tinggi / 2.0, dalam / 2.0 + 0.05), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.sphere(0.04, Vector3(0.06, tinggi / 2.0, dalam / 2.0 + 0.05), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(lebar + 0.06, 0.06, dalam + 0.06), Vector3(0, tinggi + 0.03, 0), Palette.EMAS_DESAIN, 0.4))


## Rak (buku / peralatan): 2 sisi + 3 ambalan (semua collision —
## celah antar-ambalan < tinggi badan, jadi tidak bisa ditembus) +
## isi di tiap ambalan. pos = pusat rak; local +Z = depan.
func _rak_buku(pos: Vector3, rot_y: float, nama: String, lebar: float, tinggi: float, dalam: float, isi: String = "buku") -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	_static_box(g, Vector3(0.06, tinggi, dalam), Vector3(-lebar / 2.0 + 0.03, tinggi / 2.0, 0), Palette.JATI).name = "SisiKiri"
	_static_box(g, Vector3(0.06, tinggi, dalam), Vector3(lebar / 2.0 - 0.03, tinggi / 2.0, 0), Palette.JATI).name = "SisiKanan"
	var tingkat: Array = [0.08, 0.68, 1.24, tinggi - 0.02]
	for y in tingkat:
		_static_box(g, Vector3(lebar - 0.12, 0.05, dalam), Vector3(0, y, 0), Palette.JATI).name = "Ambalan"
	# Panel belakang tipis (visual saja).
	g.add_child(Palette.box(Vector3(lebar - 0.12, tinggi, 0.04), Vector3(0, tinggi / 2.0, -dalam / 2.0 + 0.02), Palette.KAYU))
	# Isi ambalan (visual): buku warna-warni / peralatan media.
	var warna_buku: Array = [Palette.ZAMRUD_GELAP, Color("#a33b3b"), Palette.EMAS_DESAIN, Color("#3b5aa3"), Color("#7a4a8a")]
	for s in range(3):
		var y_ambal: float = tingkat[s] + 0.025
		var n_isi := 5 if isi == "buku" else 3
		for i in range(n_isi):
			var ix := -lebar / 2.0 + 0.25 + float(i) * (lebar - 0.5) / float(n_isi)
			if isi == "buku":
				var tb := 0.22 + 0.06 * float((i + s) % 3)
				g.add_child(Palette.box(Vector3(0.12, tb, 0.22), Vector3(ix, y_ambal + tb / 2.0, 0), warna_buku[(i + s) % warna_buku.size()]))
			else:
				if i == 0:
					g.add_child(Palette.cylinder(0.09, 0.09, 0.3, Vector3(ix, y_ambal + 0.15, 0), warna_buku[(i + s) % warna_buku.size()]))
				else:
					g.add_child(Palette.box(Vector3(0.28, 0.2, 0.24), Vector3(ix, y_ambal + 0.1, 0), warna_buku[(i + s) % warna_buku.size()]))


## Papan di dinding: papan (collision) + bingkai emas + label judul
## + hiasan sesuai jenis ("tulis": baki kapur; "pengumuman": kertas
## tempel; "jadwal": 4 baris jadwal). pos = pusat papan; local +Z
## menghadap ke dalam ruangan.
func _papan(pos: Vector3, rot_y: float, nama: String, teks: String, lebar: float, tinggi: float, warna: Color, jenis: String) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	add_child(g)
	_static_box(g, Vector3(lebar, tinggi, 0.06), Vector3(0, 0, 0), warna).name = "Papan"
	g.add_child(Palette.box(Vector3(lebar + 0.1, 0.07, 0.08), Vector3(0, tinggi / 2.0 + 0.02, 0), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(lebar + 0.1, 0.07, 0.08), Vector3(0, -tinggi / 2.0 - 0.02, 0), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(0.07, tinggi, 0.08), Vector3(-lebar / 2.0 - 0.02, 0, 0), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(0.07, tinggi, 0.08), Vector3(lebar / 2.0 + 0.02, 0, 0), Palette.EMAS_DESAIN, 0.4))
	var warna_teks := Color("#f2c14e") if warna == Palette.ZAMRUD_GELAP else Palette.ZAMRUD_GELAP
	# Font judul adaptif: teks tidak boleh lebih lebar dari papan.
	var fs := 18
	var lebar_teks := float(teks.length()) * 0.62 * float(fs) * 0.01
	if lebar_teks > lebar - 0.2:
		fs = maxi(10, int((lebar - 0.2) / (float(teks.length()) * 0.62 * 0.01)))
	var label_y := tinggi / 2.0 - 0.28
	if jenis == "jadwal":
		label_y = tinggi / 2.0 - 0.2
	var label := Palette.label3d(teks, Vector3(0, label_y, 0.05), fs, warna_teks, false)
	label.name = "JudulPapan"
	label.double_sided = false
	g.add_child(label)
	match jenis:
		"tulis":
			g.add_child(Palette.box(Vector3(lebar - 0.3, 0.05, 0.12), Vector3(0, -tinggi / 2.0 + 0.08, 0.08), Palette.JATI))
			g.add_child(Palette.box(Vector3(0.12, 0.03, 0.03), Vector3(-0.5, -tinggi / 2.0 + 0.12, 0.08), Color("#ffffff")))
			g.add_child(Palette.box(Vector3(0.12, 0.03, 0.03), Vector3(-0.3, -tinggi / 2.0 + 0.12, 0.08), Color("#ffffff")))
		"pengumuman":
			var kertas: Array = [Color("#ffffff"), Color("#f2c14e"), Color("#ffffff")]
			for i in range(3):
				var kx := -lebar / 2.0 + 0.35 + float(i) * (lebar - 0.7) / 2.0
				g.add_child(Palette.box(Vector3(0.42, 0.5, 0.02), Vector3(kx, -0.1, 0.05), kertas[i]))
		"jadwal":
			var n_baris := clampi(int((tinggi - 0.5) / 0.16), 2, 4)
			for i in range(n_baris):
				var jy := label_y - 0.35 - float(i) * 0.16
				g.add_child(Palette.box(Vector3(lebar - 0.3, 0.09, 0.02), Vector3(0, jy, 0.05), Color("#ffffff") if i % 2 == 0 else Color("#e8ddc0")))
