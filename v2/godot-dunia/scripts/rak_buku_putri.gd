class_name RakBukuPutri
extends RefCounted
## Rak buku kayu jati + kitab untuk area PUTRI (Dewi, 18 Nov 2026).
## Dipakai ulang di Musholla Ar-Raudhah DAN Kelas Putri — satu modul,
## dua tempat, supaya raknya konsisten.
##
## Rak berdiri sendiri (Node3D): panggil build(pos_dunia, rot_y, nama)
## lalu add_child ke root interior. Sumbu lokal rak: +Z = muka rak
## (punggung buku menghadap +Z), lebar sepanjang X, kaki di y=0.
## Posisi + rotasi diberikan dalam koordinat DUNIA interior (sudah
## lewat ke_dunia() kalau interior memakai rotasi, seperti Musholla).
##
## Isi (gaya rak Surau — 5 kitab/rak, dibulatkan ke 3 ambalan):
## 3 ambalan x 3 kitab berdiri + 1 kitab rebah di atas = 10 kitab/rak.
## Punggung zamrud / emas / krem (+ marun, biru), 3 kitab berjudul
## Arab singkat (Judul dari daftar kitab server — buku_data.gd:
## Jurumiyah, Safinatun Naja, Arba'in Nawawi).
##
## Collision: SATU StaticBody3D menutupi badan rak (tidak tembus).
## Interaksi "baca" (Tara): spot(pos, rot_y) = titik berdiri 0,9 m
## di depan muka rak, y=0 (jarak diukur dari kaki pemain, pola
## rak_spots Surau). Isi kitab BUKAN di sini — reader baca dari
## server + buku_data.gd; rak ini hanya perabot + titik interaksi.
##
## Palet: jati #7B4B2A, zamrud #065F46, emas #C9A227, krem #F2EAD6.

const LEBAR := 1.8
const TINGGI := 2.0
const DALAM := 0.35
const JARAK_SPOT := 0.9
const JUMLAH_BUKU := 10

## Warna punggung kitab (putar tiap buku).
const WARNA_BUKU: Array[Color] = [
	Color("#065f46"), # zamrud
	Color("#c9a227"), # emas
	Color("#f2ead6"), # krem
	Color("#7a1f1f"), # marun
	Color("#1d4e6b"), # biru
]

## Judul Arab singkat di punggung — satu per ambalan (bawah-tengah-atas).
const JUDUL_ARAB: Array[String] = ["الآجرومية", "سفينة النجا", "الأربعين"]

## Tinggi ambalan (papan) — buku berdiri di atasnya.
const AMBALAN_Y: Array[float] = [0.35, 0.90, 1.45]
## Posisi x kitab di tiap ambalan (3 kitab, tengah agak renggang).
const KITAB_X: Array[float] = [-0.55, 0.0, 0.55]


## Bangun satu rak di pos_dunia, menghadap rot_y (yaw, radian).
## +Z lokal rak = muka rak. Kembalikan Node3D "RakBuku..." (belum
## di-add ke tree — pemanggil yang add_child ke root interior).
static func build(pos: Vector3, rot_y: float, nama: String = "RakBuku") -> Node3D:
	var rak := Node3D.new()
	rak.name = nama
	rak.position = pos
	rak.rotation.y = rot_y
	# --- Badan rak: 2 tiang samping + panel belakang + 3 ambalan
	# + papan atas + plinth bawah. Kayu jati, ambalan jati gelap.
	rak.add_child(Palette.box(Vector3(0.05, TINGGI, DALAM), Vector3(-0.875, TINGGI / 2.0, 0), Palette.JATI))
	rak.add_child(Palette.box(Vector3(0.05, TINGGI, DALAM), Vector3(0.875, TINGGI / 2.0, 0), Palette.JATI))
	rak.add_child(Palette.box(Vector3(LEBAR, TINGGI, 0.04), Vector3(0, TINGGI / 2.0, -0.155), Palette.JATI))
	for y in AMBALAN_Y:
		rak.add_child(Palette.box(Vector3(1.7, 0.05, 0.31), Vector3(0, y, 0), Palette.KAYU_GELAP))
	rak.add_child(Palette.box(Vector3(LEBAR, 0.05, DALAM), Vector3(0, 1.95, 0), Palette.JATI))
	rak.add_child(Palette.box(Vector3(LEBAR, 0.08, DALAM), Vector3(0, 0.04, 0), Palette.KAYU_GELAP))
	# Lis emas tipis di tepi atas (aksen, pola lis pintu gedung putri).
	rak.add_child(Palette.box(Vector3(LEBAR, 0.04, 0.05), Vector3(0, 1.98, 0.16), Palette.EMAS_DESAIN, 0.4))
	# --- Kitab berdiri: 3 per ambalan, warna putar, satu buku tiap
	# ambalan sedikit miring (bersandar) supaya tidak kaku.
	var idx := 0
	for a in AMBALAN_Y.size():
		var y_ambalan: float = AMBALAN_Y[a]
		for k in KITAB_X.size():
			var warna: Color = WARNA_BUKU[idx % WARNA_BUKU.size()]
			var buku := Palette.box(
				Vector3(0.28, 0.38, 0.22),
				Vector3(KITAB_X[k], y_ambalan + 0.025 + 0.19, 0.02),
				warna
			)
			buku.name = "Kitab_%02d" % (idx + 1)
			# Buku ketiga tiap ambalan miring 8 derajat (bersandar).
			if k == 2:
				buku.rotation.z = deg_to_rad(-8.0)
				buku.position.x += 0.03
			rak.add_child(buku)
			# Judul Arab di punggung buku pertama tiap ambalan.
			if k == 0:
				var judul := Palette.label_arab(JUDUL_ARAB[a], Vector3(KITAB_X[k], y_ambalan + 0.025 + 0.19, 0.135), 14, Color("#f2ead6"))
				judul.name = "Judul_%02d" % (idx + 1)
				rak.add_child(judul)
			idx += 1
	# --- 1 kitab rebah di atas rak (sampul zamrud, halaman krem).
	var rebah := Palette.box(Vector3(0.32, 0.05, 0.24), Vector3(-0.45, 2.0, 0.0), Palette.ZAMRUD_GELAP)
	rebah.name = "Kitab_%02d" % (idx + 1)
	rak.add_child(rebah)
	rak.add_child(Palette.box(Vector3(0.30, 0.02, 0.22), Vector3(-0.45, 2.03, 0.0), Color("#f5f0e6")))
	# --- Collision: satu kotak menutupi badan rak (tidak tembus).
	var body := StaticBody3D.new()
	body.name = nama + "Body"
	var col := CollisionShape3D.new()
	var bentuk := BoxShape3D.new()
	bentuk.size = Vector3(LEBAR, TINGGI, DALAM)
	col.shape = bentuk
	col.position = Vector3(0, TINGGI / 2.0, 0)
	body.add_child(col)
	rak.add_child(body)
	return rak


## Titik interaksi "baca": 0,9 m di depan muka rak, y=0 (diukur
## dari kaki pemain). pos + rot_y SAMA dengan yang dipakai build().
static func spot(pos: Vector3, rot_y: float) -> Vector3:
	var depan := Vector3(sin(rot_y), 0, cos(rot_y))
	return Vector3(pos.x + depan.x * JARAK_SPOT, 0, pos.z + depan.z * JARAK_SPOT)


## Hitung jumlah kitab dalam satu rak yang sudah dibangun (untuk tes).
static func hitung_buku(rak: Node3D) -> int:
	return rak.find_children("Kitab_*", "MeshInstance3D", true, false).size()
