class_name GubukMasuk
extends Node3D
## Gubuk santri BISA DIMASUKI — Dewa (interior), 17 Nov 2026.
##
## Temuan ukur model (Blender headless + dump Godot gubuk-santri.glb):
## - Gubuk PANGGUNG: lantai atas (Lantai) Z 1,20..1,32 -> permukaan
##   pijak y=1,32 m. Jejak badan 4,0 (X) x 3,0 (Z) m, dinding sampai
##   y=3,52, atap sampai 4,71. Kolong 0..1,20 m (ada Kayu_Bakar).
## - TANGGA SUDAH ADA di model: 5 Anak_Tangga (naik 0,22 m tiap anak,
##   dari tanah z=-3,82 ke Beranda z=-2,41) + Beranda 1,2x1,0 m di
##   depan pintu. TIDAK perlu Bima — tangga tinggal diberi collision.
## - PINTU ADA tapi TERTUTUP: daun Pintu (0,86 x 1,76 m) + Gagang
##   menutup penuh bukaan depan (X 0,45..1,35, y 1,32..3,12). Bukaan
##   muat kapsul pemain (lebar 0,70, tinggi 1,70): celah 0,90 x 1,80 m.
## - Jendela depan: bukaan X -1,30..-0,50, y 2,02..2,82 — tapi Kaca
##   OPAK (albedo alpha 1,0, transp 0), jadi TIDAK tembus cahaya.
##   Cahaya interior: pintu terbuka + 1 OmniLight hangat di modul ini.
## - Dinding lain TERTUTUP penuh (belakang/kiri/kanan + segmen depan).
##   Rak kitab di dinding kanan (X 1,53..1,88) perlu collision sendiri.
##
## Yang modul ini lakukan (SEMUA di ruang LOKAL instance GLB, jadi
## berlaku sama untuk GLB_GubukSawah (26,0,30, rot 0°) maupun
## GLB_GubukKebun (90,0,10, rot 90°) — tanpa ubah file GLB:
##  1. Pintu dibuka: daun + gagang dipindah ke pivot engsel (X=1,33,
##     sisi kanan — gagang di X~0,58) lalu pivot diputar -110° (keluar,
##     ke beranda; preseden daun Surau ±110°). Daun terbuka diberi
##     collision sendiri supaya tidak tembus.
##  2. Collision lantai (badan + beranda), 5 segmen dinding depan +
##     belakang/kiri/kanan (celah HANYA di pintu + jendela atas;
##     ambang jendela y=2,02 = 0,70 m di atas lantai, tak bisa
##     dilangkahi kapsul), rak kitab, dan 4 dinding kolong (0..1,20 m)
##     supaya pemain tidak bisa jalan menembus bawah gubuk.
##  3. Ramp TANGGA (bukan anak-tangga satu-satu — kapsul CharacterBody
##     tidak bisa naik pijakan tegak 0,22 m): satu bidang miring
##     38,2° (di bawah batas floor_max_angle 45°) dari tanah
##     (z=-4,09, y=0) sampai tepi beranda (z=-2,41, y=1,32). Garis
##     ramp lewat titik tengah tiap anak tangga: kaki melayang MAKS
##     0,11 m di atas papan (tengah papan) dan ramp masuk 0,05 m ke
##     dalam ujung papan (tak terlihat — collision tak kasatmata).
##  4. 1 OmniLight hangat (#ffd9a0, 0,5, jangkauan 6 m, tanpa bayangan)
##     di tengah interior (0, 2,7, 0) — jendela kacanya opak.
##
## Pemasangan (di PesantrenBuilder._lingkungan_glb, setelah _glb):
##   GubukMasuk.pasang(instansi_gubuk)
## Idempotent: kalau sudah terpasang (ada anak "GubukMasuk"), lewati.

const PINTU_SUDUT_BUKA_DEG := -110.0
const LANTAI_Y := 1.32
const WARNA_LAMPU := Color("#ffd9a0")


static func pasang(gubuk: Node3D) -> void:
	if gubuk == null:
		push_error("GubukMasuk: gubuk null")
		return
	if gubuk.find_child("GubukMasuk", false, false) != null:
		return
	var m := GubukMasuk.new()
	m.name = "GubukMasuk"
	gubuk.add_child(m)
	m._buka_pintu(gubuk)
	m._bangun_collision()
	m._bangun_lampu()


## Daun + gagang ke pivot engsel, putar terbuka ke beranda.
func _buka_pintu(gubuk: Node3D) -> void:
	var pintu := gubuk.find_child("Pintu", true, false) as Node3D
	var gagang := gubuk.find_child("Gagang_Pintu", true, false) as Node3D
	if pintu == null:
		push_error("GubukMasuk: node Pintu tidak ketemu di " + String(gubuk.name))
		return
	# Engsel di tepi kanan daun (X=1,33 — gagang di X~0,58).
	# Posisi daun/gagang diukur dari dump Godot (Y-up):
	# Pintu (0,90, 2,22, -1,32), Gagang (0,58, 2,22, -1,28).
	var pivot := Node3D.new()
	pivot.name = "GubukMasuk_PintuPivot"
	pivot.position = Vector3(1.33, 2.22, -1.32)
	gubuk.add_child(pivot)
	pintu.get_parent().remove_child(pintu)
	pivot.add_child(pintu)
	pintu.position = Vector3(-0.43, 0, 0)
	if gagang != null:
		gagang.get_parent().remove_child(gagang)
		pivot.add_child(gagang)
		gagang.position = Vector3(-0.75, 0, 0.04)
	pivot.rotation.y = deg_to_rad(PINTU_SUDUT_BUKA_DEG)
	# Collision daun terbuka (ikut pivot): 0,86 x 1,76 x 0,06.
	var body := StaticBody3D.new()
	body.name = "GubukMasuk_PintuBody"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.86, 1.76, 0.06)
	shape.shape = box
	shape.position = Vector3(-0.43, 0, 0)
	body.add_child(shape)
	pivot.add_child(body)


func _kotak(body: StaticBody3D, size: Vector3, pos: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = pos
	body.add_child(shape)


func _bangun_collision() -> void:
	var body := StaticBody3D.new()
	body.name = "GubukMasuk_Collision"
	add_child(body)
	# --- Lantai (permukaan pijak y=1,32) ---
	_kotak(body, Vector3(4.0, 0.12, 3.0), Vector3(0, 1.26, 0)) # badan
	_kotak(body, Vector3(1.2, 0.12, 1.0), Vector3(0.9, 1.26, -1.91)) # beranda
	# --- Dinding (y 1,32..3,52, tebal 0,12 di bidang depan/belakang) ---
	_kotak(body, Vector3(4.0, 2.2, 0.12), Vector3(0, 2.42, 1.35)) # belakang
	_kotak(body, Vector3(0.12, 2.2, 2.58), Vector3(-1.925, 2.42, 0)) # kiri
	_kotak(body, Vector3(0.12, 2.2, 2.58), Vector3(1.925, 2.42, 0)) # kanan
	# Depan (z=-1,35): kiri, bawah+atas jendela, tengah, atas pintu,
	# kanan. CELAH: pintu X 0,45..1,35 (y 1,32..3,12) + jendela
	# X -1,30..-0,50 (y 2,02..2,82, ambang 0,70 m — tak terlompati).
	_kotak(body, Vector3(0.70, 2.2, 0.12), Vector3(-1.65, 2.42, -1.35))
	_kotak(body, Vector3(0.80, 0.70, 0.12), Vector3(-0.90, 1.67, -1.35))
	_kotak(body, Vector3(0.80, 0.70, 0.12), Vector3(-0.90, 3.17, -1.35))
	_kotak(body, Vector3(0.95, 2.2, 0.12), Vector3(-0.025, 2.42, -1.35))
	_kotak(body, Vector3(0.90, 0.40, 0.12), Vector3(0.90, 3.32, -1.35))
	_kotak(body, Vector3(0.65, 2.2, 0.12), Vector3(1.675, 2.42, -1.35))
	# --- Rak kitab dinding kanan (X 1,53..1,88, y 1,35..2,35) ---
	_kotak(body, Vector3(0.35, 1.0, 0.75), Vector3(1.70, 1.85, 0.60))
	# --- Kolong (0..1,20 m): pemain tak bisa jalan bawah gubuk ---
	_kotak(body, Vector3(4.0, 1.2, 0.12), Vector3(0, 0.6, -1.5)) # depan
	_kotak(body, Vector3(4.0, 1.2, 0.12), Vector3(0, 0.6, 1.5)) # belakang
	_kotak(body, Vector3(0.12, 1.2, 3.0), Vector3(-2.0, 0.6, 0)) # kiri
	_kotak(body, Vector3(0.12, 1.2, 3.0), Vector3(2.0, 0.6, 0)) # kanan
	# --- Ramp TANGGA: tanah (z=-4,09, y=0) -> beranda (z=-2,41, y=1,32).
	# Sudut 38,2° < floor_max_angle 45°. Lebar 1,2 m (X 0,3..1,5).
	var naik := LANTAI_Y
	var lari := 4.09 - 2.41
	var sudut := atan2(naik, lari)
	var panjang := sqrt(naik * naik + lari * lari) + 0.3
	var tebal := 0.12
	var tengah := Vector3(0.9, naik * 0.5, -(2.41 + 4.09) * 0.5)
	var normal := Vector3(0, cos(sudut), -sin(sudut))
	var ramp := CollisionShape3D.new()
	var rbox := BoxShape3D.new()
	rbox.size = Vector3(1.2, tebal, panjang)
	ramp.shape = rbox
	ramp.position = tengah - normal * (tebal * 0.5)
	ramp.rotation.x = -sudut
	body.add_child(ramp)


func _bangun_lampu() -> void:
	var lampu := OmniLight3D.new()
	lampu.name = "GubukMasuk_Lampu"
	lampu.position = Vector3(0, 2.7, 0)
	lampu.light_color = WARNA_LAMPU
	lampu.light_energy = 0.5
	lampu.omni_range = 6.0
	lampu.shadow_enabled = false
	add_child(lampu)
