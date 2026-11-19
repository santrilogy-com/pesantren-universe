class_name Palette
## Palet Pesantren Universe: zamrud + pasir + emas.
## Satu tempat untuk semua material supaya warna konsisten di seluruh pesantren.

const RUMPUT := Color("#4e8a4f")
const PASIR := Color("#e3d3ae")
const PASIR_GELAP := Color("#cbb27f")
const PUTIH := Color("#f5f0e6")
const ZAMRUD := Color("#0e7a5f")
const ZAMRUD_GELAP := Color("#065f46")
const EMAS := Color("#d4a017")
const EMAS_TERANG := Color("#f2c14e")
const KAYU := Color("#8a5a2b")
const KAYU_GELAP := Color("#6b4423")
const KULIT := Color("#c68e5e")
const KOKO := Color("#faf7f0")
## RONDE 21 (16 Nov — desain arsitektur Surau/Musholla ACC Mas):
## warna desain Arsa (lihat desain-arsitektur/DESAIN-ARSITEKTUR.md).
const KREM := Color("#f2ead6")
const JATI := Color("#7b4b2a")
const BATU := Color("#b8b2a4")
const EMAS_DESAIN := Color("#c9a227")
const SARUNG := Color("#0b6b4f")
const HITAM := Color("#2b2b2b")
const ABU := Color("#9aa0a6")

static var _cache: Dictionary = {}

## RONDE 6 (15 Nov — Mas: font harus nuansa game, jangan Arial kasar):
## Baloo 2 (OFL, rounded, nuansa game) untuk semua teks Latin —
## Bold untuk Label3D/papan, SemiBold untuk UI (juga default font
## proyek, lihat project.godot). Amiri Bold (OFL) untuk teks Arab
## (plakat مصلى الإخلاص). Font di-bundle di fonts/ supaya sama di web.
const FONT_GAME := preload("res://fonts/Baloo2-Bold.tres")
const FONT_UI := preload("res://fonts/Baloo2-SemiBold.tres")
const FONT_ARAB := preload("res://fonts/Amiri-Bold.ttf")


static func mat(color: Color, metallic: float = 0.0, roughness: float = 0.9) -> StandardMaterial3D:
	var key := str(color.to_html()) + "|" + str(metallic) + "|" + str(roughness)
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = roughness
	_cache[key] = m
	return m


static func box(size: Vector3, pos: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color, metallic)
	return mi


static func cylinder(top_r: float, bottom_r: float, height: float, pos: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bottom_r
	mesh.height = height
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color, metallic)
	return mi


static func capsule(radius: float, height: float, pos: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	# Kapsul (silinder berujung setengah bola) — untuk lengan/kaki karakter
	# supaya tidak balok. height adalah tinggi total termasuk kedua ujung.
	var mi := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.rings = 12
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color, metallic)
	return mi


static func sphere(radius: float, pos: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color, metallic)
	return mi


static func label3d(text: String, pos: Vector3, font_size: int, color: Color, billboard: bool = true, tanpa_outline: bool = false) -> Label3D:
	# PERBAIKAN 15 Nov ~10:52 WIB (cacat teks raksasa): JANGAN pakai
	# fixed_size=true + no_depth_test=true di sini. fixed_size membuat label
	# tampil raksasa dengan ukuran layar konstan (font 36-96 x pixel 0.01 =
	# berkali-kali tinggi viewport) dan no_depth_test menggambarnya menembus
	# semua geometri — 19 label menumpuk menutupi ~85% layar setelah login.
	# Label sekarang teks 3D biasa: ukurannya mengikuti jarak (perspektif)
	# dan tertutup dinding/geometri seperti objek lain.
	# PERBAIKAN 15 Nov ~12:50 WIB: label yang MENEMPEL DI PAPAN harus
	# billboard=false. Billboard berputar mengikuti kamera — dari sudut
	# samping ≥10°, tepi label berayun ke belakang bidang muka papan
	# (celah hanya 0,06 m) lalu tertutup papan, terlihat "terpotong".
	# Label papan kini sejajar papan seperti papan sungguhan. Label
	# MELAYANG (nama, bubble, ikon "!") tetap billboard=true, tapi
	# ukurannya dibatasi batasi_label_kamera() supaya tidak membesar
	# menutupi layar saat dekat kamera.
	# RONDE 5 (15 Nov ~20:36 WIB, Mas: "hampir semua tulisan jelek tidak
	# enak dilihat"): outline label SEBELUMNYA PUTIH untuk semua teks —
	# teks putih + outline putih = gumpalan putih yang tidak terbaca
	# (inilah "nama set di atas karakter itu jelek"). Sekarang outline
	# BERLAWANAN dengan warna teks: teks terang -> outline GELAP,
	# teks gelap -> outline TERANG. Ukuran outline ikut font.
	# KOREKSI RONDE 5 (15 Nov ~20:41 WIB, Mas: "Label nama tanpa outline..
	# kaya di game sepak bola gitu lo"): label NAMA karakter dibuat
	# tanpa outline sama sekali (tanpa_outline=true) — kecil, bersih,
	# simpel seperti nama pemain FIFA/eFootball. Keterbacaan dari font
	# yang bersih + ukuran pas, bukan outline.
	var l := Label3D.new()
	l.text = text
	l.position = pos
	l.font_size = font_size
	# RONDE 6: font game (Baloo 2 Bold) untuk SEMUA Label3D — bukan
	# lagi font default yang terasa seperti Arial.
	l.font = FONT_GAME
	l.pixel_size = 0.01
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED if billboard else BaseMaterial3D.BILLBOARD_DISABLED
	l.fixed_size = false
	l.shaded = false
	l.no_depth_test = false
	l.modulate = color
	if tanpa_outline:
		l.outline_size = 0
	else:
		l.outline_size = clampi(font_size / 3, 8, 20)
		# Luminansi teks: terang -> outline gelap, gelap -> outline terang.
		var lum := 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
		l.outline_modulate = Color(0.05, 0.05, 0.05, 0.9) if lum > 0.5 else Color(1, 1, 1, 0.9)
	return l


## Label nama karakter ala game sepak bola (RONDE 5): kecil, bersih,
## TANPA outline, putih — seperti nama pemain di FIFA/eFootball.
## Dipakai pemain + semua NPC (lihat player.gd build_visual).
static func label_nama(nama: String, pos: Vector3) -> Label3D:
	return label3d(nama, pos, 26, Color("#ffffff"), true, true)


## Label teks Arab (RONDE 6): font Amiri Bold, shaping RTL benar
## (Godot 4 pakai HarfBuzz). Dipakai plakat مصلى الإخلاص di atas
## pintu Surau. billboard=false (menempel di dinding seperti papan).
static func label_arab(teks: String, pos: Vector3, font_size: int, color: Color) -> Label3D:
	var l := label3d(teks, pos, font_size, color, false)
	l.font = FONT_ARAB
	return l


## Potong teks bubble chat dengan rapi (RONDE 6 — Mas: bubble terlalu
## besar, teks panjang menutupi layar): maks karakter, sisanya diganti
## "…". Dipakai show_chat pemain + say() NPC.
static func rapikan_bubble(teks: String, maks: int = 100) -> String:
	var t := teks.strip_edges()
	if t.length() > maks:
		t = t.substr(0, maks - 1) + "…"
	return t


## Menjaga label 3D melayang (nama, bubble chat, ikon "!") supaya tidak
## membesar menutupi layar saat pemiliknya dekat kamera. Tanpa ini, bubble
## sapaan NPC setinggi ~1,18 m menutupi 94% tinggi layar HP landscape
## pada jarak 2 m (terukur headless, kamera fov 60). Caranya: skala label
## dijaga supaya tinggi tampaknya tidak melebihi maks_fraksi dari tinggi
## viewport — hanya mengecilkan, tidak pernah membesarkan (skala maks 1).
## PENGECUALIAN — mode Drone (keputusan Mas 13:19: nama tampil SELALU
## dan di Drone harus TERBACA JELAS): main.gd menulis meta
## "drone_label_boost" pada kamera (2,5 saat Drone, 1,0 mode lain);
## meta itu dipakai sebagai skala MAKS di sini — dari ketinggian
## 10 m nama tanpa boost hanya ~2,6% tinggi layar (tidak terbaca),
## dengan boost 2,5x jadi ~6,5% (jelas) tanpa mengubah mode lain.
## Tinggi teks Label3D yang STABIL (bukan dari get_aabb()).
## Label3D.get_aabb() TIDAK bisa dipakai sebagai tinggi: ia
## mengembalikan KUBUS bersisi = LEBAR teks (terukur headless:
## "A" 0,43 / "Probe" 0,66 / "Tes kamera" 1,25 /
## "Ahmad Muntahal Hadi" 2,44 — padahal tinggi teksnya sama).
## Memakai size.y sebagai tinggi membuat nama panjang dikecilkan
## 3-6x berlebihan (di Drone: "Tes kamera" skala 0,88, tidak
## terbaca — padahal boost 2,5 sudah benar). Tinggi stabil dari
## metrik font: get_height(font_size) x pixel_size (0,43 m untuk
## font nama 26 px). Fallback ke AABB bila font tidak ada.
static func _tinggi_label(label: Label3D) -> float:
	if label.font != null and label.pixel_size > 0.0:
		return float(label.font.get_height(label.font_size)) * label.pixel_size
	return label.get_aabb().size.y


static func batasi_label_kamera(label: Label3D, kamera: Camera3D, maks_fraksi: float = 0.11) -> void:
	if label == null or kamera == null or not label.visible:
		return
	var h := _tinggi_label(label)
	if h <= 0.001:
		return
	var d := kamera.global_position.distance_to(label.global_position)
	if d < 0.05:
		d = 0.05
	var target := maks_fraksi * 2.0 * d * tan(deg_to_rad(kamera.fov * 0.5))
	var skala_maks := 1.0
	if kamera.has_meta("drone_label_boost"):
		skala_maks = float(kamera.get_meta("drone_label_boost"))
	var s := clampf(target / h, 0.08, skala_maks)
	label.scale = Vector3.ONE * s
