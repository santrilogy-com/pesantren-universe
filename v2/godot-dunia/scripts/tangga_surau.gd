class_name TanggaSurau
## Tangga + lantai serambi Surau v2 (Rangga, 17 Nov 23:xx WIB).
## UKURAN (dump node surau-v2.glb, 17 Nov — lokal +X = depan):
##   T3 (bawah):  z  0.4.. 1.0, atas 0.166, lebar 7.2
##   T2 (tengah): z -0.2.. 0.4, atas 0.333, lebar 6.6
##   T1 (atas):   z -0.8..-0.2, atas 0.500, lebar 6.0
##   Serambi:     z -4.1..-0.7, atas 0.500, lebar 6.4
##   (dunia, Surau lurus -90°, pintu (0,-3.8) menghadap selatan)
##
## MASALAH LAMA: GLB TIDAK PUNYA collision sama sekali (visual saja)
## + anak tangga primitif lama di _surau() sudah tidak dipakai —
## pemain jalan di y=0: kaki tenggelam 0,166 m di anak tangga dan
## 0,5 m di lantai serambi, lalu "masuk" lewat teleport.
## PERCOBAAN 23:5x WIB (probe): collision KOTAK per anak tangga
## saja TIDAK BISA — CharacterBody3D (kapsul r=0,35, tanpa step-up)
## tersangkut di riser pertama (z=1.30 = muka T3 + radius).
##
## SOLUSI: permukaan jalan berupa RAMPS + DATAR selapis — tiap
## tanjakan dimulai dari permukaan bawahnya (tanpa muka vertikal
## yang bisa menyangkut kapsul) dan SELESAI sebelum ujung sandal
## (±0,16 m di depan pusat kapsul) melewati bidang riser, supaya
## kaki tidak pernah menembus anak tangga:
##   jalan y=0 --rampa A (20,7°)--> datar 0.166 --rampa B (27,6°)-->
##   datar 0.333 --rampa C (27,6°)--> datar 0.5 (T1 + serambi).
## Semua sudut < floor_max_angle (45°) — pemain + NPC jalan naik
## normal dengan move_and_slide; kaki menapak tepat di atas pijakan
## (tanpa tenggelam, tanpa melayang — lihat tes + foto).
## Rampa = kotak miring TANPA visual (GLB yang tampil); ujung-ujung
## rampa ditanam ke dalam kotak datar / tanah supaya tidak ada muka
## ujung yang menyangkut kapsul.
## PERBAIKAN 18 Nov 00:xx WIB (probe v2): pemain naik rampa A
## sampai datar T3 (y=0,167, clearance +0,001) lalu MACET di
## z=0,95 — datar-0,333 lama (z 0,05..0,65) mukanya jadi tembok
## 0,167 m: kapsul berhenti saat hemisfer bawahnya (di tinggi
## muka 0,333) menyentuh muka itu (pusat 0,65+0,298=0,95) sebelum
## pusat mencapai awal rampa B (0,84). Obat: rampa B DIMULAI lebih
## selatan (z=0,90, masih di atas datar T3) dan datar-0,333
## DIPENDEKKAN ke z 0,30..0,58, supaya pusat kapsul sudah naik di
## atas rampa B sebelum hemisfernya mencapai muka datar; pola sama
## untuk rampa C / datar T1 (0,30 -> -0,02 / z -0,85..-0,02).

## Tinggi lantai serambi (dipakai outdoor_exit + sandal di builder).
const LANTAI_SERAMBI_Y := 0.5

## Tebal kotak collision (ujung bawah selalu di bawah tanah / di
## dalam kotak datar — tidak ada muka vertikal di atas permukaan).
const TEBAL := 0.6


## Pijakan visual (atas anak tangga / lantai) pada posisi z dunia.
## Dipakai tes headless (clearance kaki) — cermin ukuran GLB.
static func pijakan(z: float) -> float:
	if z >= 1.0:
		return 0.0
	if z >= 0.4:
		return 0.166
	if z >= -0.2:
		return 0.333
	if z >= -4.1:
		return 0.5
	return 0.0


static func build(root: Node3D) -> Node3D:
	var t := Node3D.new()
	t.name = "TanggaSurau"
	root.add_child(t)
	# Rampa A: jalan (z=1.6, y=0) -> datar T3 (z=1.16, y=0.166).
	# Ujung sandal melewati muka selatan T3 (z=1.0) saat pusat di
	# z=1.16 — tepat saat kaki sampai di atas T3 (0.166).
	_rampa(t, 1.6, 0.0, 1.16, 0.166, 7.2)
	# Datar T3 (atas 0.166), menutupi kedua ujung rampa A + B.
	_datar(t, Vector3(7.2, 0.186, 0.53), Vector3(0, 0.073, 0.985))
	# Rampa B: datar T3 (z=0.90, y=0.166) -> datar T2 (z=0.58,
	# y=0.333). Mulai di ATAS datar T3 (z 0.72..1.25) supaya pusat
	# kapsul sudah naik sebelum hemisfer bawahnya mencapai muka
	# datar-0,333 (z=0.58); muka itu hanya 0,167 m di atas kaki
	# yang sudah terangkat rampa — kapsul meluncur melewatinya.
	_rampa(t, 0.90, 0.166, 0.58, 0.333, 6.6)
	# Datar T2 (atas 0.333), z 0.30..0.58 — pendek: menutupi ujung
	# rampa B + awal rampa C, mukanya tidak lagi menghadang.
	_datar(t, Vector3(6.6, 0.353, 0.28), Vector3(0, 0.1565, 0.44))
	# Rampa C: datar T2 (z=0.30, y=0.333) -> datar T1 (z=-0.02,
	# y=0.5). Pola sama seperti rampa B.
	_rampa(t, 0.30, 0.333, -0.02, 0.5, 6.0)
	# Datar T1 (atas 0.5), z -0.85..-0.02, + lantai serambi penuh.
	_datar(t, Vector3(6.0, 0.52, 0.83), Vector3(0, 0.24, -0.435))
	_datar(t, Vector3(6.4, 0.52, 3.4), Vector3(0, 0.24, -2.4))
	return t


## Kotak datar dengan collision (tanpa visual).
static func _datar(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)


## Kotak miring (tanpa visual): permukaan atasnya garis lurus dari
## (z_a, y_a) ujung selatan-bawah ke (z_b, y_b) ujung utara-atas.
## Ujung-ujung kotak menembus ke bawah (tebal 0.6) — muka ujungnya
## terkubur di tanah / kotak datar, bukan penghalang.
static func _rampa(parent: Node3D, z_a: float, y_a: float, z_b: float, y_b: float, lebar: float) -> void:
	var dz := z_b - z_a
	var dy := y_b - y_a
	var panjang := sqrt(dz * dz + dy * dy)
	var sudut := atan2(dy, -dz)
	var mid_z := (z_a + z_b) * 0.5
	var mid_y := (y_a + y_b) * 0.5
	# Normal atas permukaan (y,z) = (cos, sin) — miring ke selatan.
	var n_y := cos(sudut)
	var n_z := sin(sudut)
	var body := StaticBody3D.new()
	body.position = Vector3(0, mid_y - n_y * TEBAL * 0.5, mid_z - n_z * TEBAL * 0.5)
	body.rotation.x = sudut
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(lebar, TEBAL, panjang)
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)
