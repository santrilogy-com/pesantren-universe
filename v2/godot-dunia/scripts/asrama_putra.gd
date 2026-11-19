class_name AsramaPutra
## CANGKANG LUAR ASRAMA PUTRA (Nadia, 18 Nov 2026 — desain DI-ACC
## Mas 09:37 WIB, termasuk annex menjorok tapak total 21,5x12 m).
##
## BAHASA SURAU (arahan Mas 09:38 WIB: "Desain 3d harus konsisten
## seperti surau" — acuan GLB Surau + surau-v2-konsep.png + pola
## PesantrenBuilder._surau): dinding krem #F2EAD6, lis emas #C9A227
## antar lantai + di bawah parapet, parapet + atap datar zamrud
## #065F46, alas batu #B8B2A4 di kaki dinding, pintu jati #7B4B2A
## dua daun TERTUTUP + gagang emas + ambang emas + tiang emas,
## jendela LENGKUNG (kotak gelap + bingkai emas + cakram lengkung,
## pola _jendela_lengkung builder), plakat papan zamrud berbingkai
## emas + teks emas, serambi lantai batu + tiang krem + atap miring
## zamrud. TIDAK ada kubah/menara/mihrab — itu elemen masjid,
## bukan bahasa umum; Asrama tetap atap datar + parapet sesuai
## desain ACC.
##
## LOKASI: pusat (-24,10), selatan jalan E-W (tepi utara jalan
## z=1,25; dinding utara gedung z=4 — bersih 2,75 m), Zona Asrama.
## Tapak: badan 18x12 m (x -33..-15, z 4..16) + annex tangga timur
## 3,5x2,6 m (x -15..-11,5, z 8,7..11,3) = total 21,5x12 m.
## Tinggi: 3 lantai x 3,2 m = 9,6 m + parapet zamrud 0,6 m = 10,2 m.
## Pintu utama di dinding BARAT (x=-33, z=10), lebar 1,6 m, hanya
## lantai 1 — sama sisi dengan pintu interior (lokal x=-9).
## Cangkang ini TERTUTUP (daun pintu ber-collision, pemain mentok
## seperti mentok dinding — pola _daun_pintu kampus_putri): masuk
## tetap pakai tombol MASUK -> teleport ke interior (main.gd,
## tugas Lestari). Interior TIDAK dibangun di sini.
##
## TABRAKAN TAPAK (dicek 18 Nov sebelum membangun):
##   - Pohon (-24,16) tepat di garis dinding selatan + pohon
##     (-12,10) di dalam annex — KEDUANYA DIPINDAH di _dekor
##     (pesantren_builder.gd) ke (-24,22) dan (-8,18).
##   - Papan plot "Asrama" (-16,4,6) berdiri di dalam Kamar 002 —
##     plot TIDAK digambar lagi (_plots melewati tahap "Asrama").
##   - Jalan E-W (z -1,25..1,25) + jalan N-S (x -1,5..1,5) bersih;
##     spawn putra (-4,14) 7,5 m di timur annex; waypoint NPC
##     terdekat (-20,18) 2 m di selatan dinding + (-8,8) 3,5 m di
##     timur annex; Cangkruk (-22,-18) 18 m di utara; Surau jauh.
##   - Cadangan Asrama ke-2 di barat (masterplan) tetap kosong.
##
## Kontrak: static func build(root: Node3D) -> Dictionary {
##   "asrama_putra_door": Vector3(-33,0,10),
##   "asrama_putra_exit": Vector3(-34.5,0,10),
##   "asrama_putra_pos": Vector3(-24,0,10),
## }
## Dipanggil PesantrenBuilder.build() (sekali). Wiring pintu/
## teleport/kamera/kasur di main.gd — tugas Lestari, BUKAN di sini.
##
## RONDE TEKSTUR P2+P6 (Arsa, 18 Nov 2026 — DI-ACC Mas 14:01 WIB):
## P2 = 6 jendela lengkung fasad barat (2/lantai, z 6,5/13,5) +
## lis emas vertikal di kedua sudut fasad barat; P6 = plakat
## diperbesar (papan 4,0 m, font 32). Hanya file ini yang diubah.

## Posisi (konstanta — dipakai dict kembalian juga).
const ASRAMA_PUTRA_POS := Vector3(-24, 0, 10)
const ASRAMA_DOOR := Vector3(-33, 0, 10)
const ASRAMA_EXIT := Vector3(-34.5, 0, 10)

## Ukuran.
const LANTAI_TINGGI := 3.2
const JUMLAH_LANTAI := 3
const LEBAR_BADAN := 18.0
const DALAM_BADAN := 12.0
const LEBAR_PINTU := 1.6
const TINGGI_PINTU := 2.6
const TINGGI_PARAPET := 0.6


static func build(root: Node3D) -> Dictionary:
	var a := Node3D.new()
	a.name = "AsramaPutra"
	root.add_child(a)
	_badan(a)
	_annex(a)
	_serambi(a)
	_plakat(a)
	return {
		"asrama_putra_door": ASRAMA_DOOR,
		"asrama_putra_exit": ASRAMA_EXIT,
		"asrama_putra_pos": ASRAMA_PUTRA_POS,
	}


## P5 FASE 2 (Bima, 18 Nov 2026): permukaan BESAR bertekstur —
## dinding KREM pakai plester (MaterialTekstur.dinding), BATU tipis
## (lantai/teras, y<=0,15) pakai lantai batu, BATU tebal (fondasi/
## alas) pakai blok batu. Tinta + ukuran/posisi TIDAK berubah, hanya
## material — palet tetap persis (tekstur ternormalisasi 0,90).
## Detail kecil (lis emas, jendela, pintu jati, plakat) tetap polos.
## skala_uv ~= ukuran / 2 m (tekstur berulang tiap ~2 m).
static func _skala_uv(size: Vector3) -> Vector3:
	return Vector3(size.x / 2.0, size.y / 2.0, size.z / 2.0)


static func _mat_permukaan(size: Vector3, warna: Color) -> Material:
	if warna == Palette.KREM:
		return MaterialTekstur.dinding(warna, _skala_uv(size))
	if warna == Palette.BATU:
		if size.y <= 0.15:
			return MaterialTekstur.lantai_batu(warna, _skala_uv(size))
		return MaterialTekstur.pondasi(warna, _skala_uv(size))
	return Palette.mat(warna)


## Helper lokal (pola _static_box builder): box visual + StaticBody3D.
## Hiasan (lis, parapet, atap, jendela, plakat) TIDAK pakai ini —
## visual saja.
static func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, collide: bool = true) -> MeshInstance3D:
	var mi := MaterialTekstur.kotak(size, pos, _mat_permukaan(size, color))
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
		parent.add_child(body)
	return mi


## ------------------------------------------------------------------
## Badan utama 18x12 m, 3 lantai (y 0..9,6) + parapet zamrud.
## Dinding krem; lis emas antar lantai (y 3,2 / 6,4) + di bawah
## parapet (y 9,6) — pola lis emas Surau (di bawah atap).
## ------------------------------------------------------------------
static func _badan(a: Node3D) -> void:
	var g := Node3D.new()
	g.name = "Badan"
	a.add_child(g)
	var cx := -24.0
	var cz := 10.0
	# Lantai.
	_static_box(g, Vector3(LEBAR_BADAN, 0.14, DALAM_BADAN), Vector3(cx, -0.05, cz), Palette.PASIR_GELAP)
	# Dinding utara + selatan (utuh, 9,6 m).
	_static_box(g, Vector3(18.5, 9.6, 0.25), Vector3(cx, 4.8, 4), Palette.KREM)
	_static_box(g, Vector3(18.5, 9.6, 0.25), Vector3(cx, 4.8, 16), Palette.KREM)
	# Dinding timur (utuh — annex menempel di luarnya).
	_static_box(g, Vector3(0.25, 9.6, 12.25), Vector3(-15, 4.8, cz), Palette.KREM)
	# Dinding barat: lantai 1 bercelah pintu (1,6 m, z 9,2..10,8);
	# lantai 2-3 utuh.
	_static_box(g, Vector3(0.25, 3.2, 5.2), Vector3(-33, 1.6, 6.6), Palette.KREM)
	_static_box(g, Vector3(0.25, 3.2, 5.2), Vector3(-33, 1.6, 13.4), Palette.KREM)
	_static_box(g, Vector3(0.25, 0.6, 1.6), Vector3(-33, 2.9, 10), Palette.KREM)
	_static_box(g, Vector3(0.25, 3.2, 12.25), Vector3(-33, 4.8, cz), Palette.KREM)
	_static_box(g, Vector3(0.25, 3.2, 12.25), Vector3(-33, 8.0, cz), Palette.KREM)
	# Alas batu di kaki dinding (pola gambar konsep Surau — strip
	# abu-abu di bawah dinding; visual saja, 0,095 m di depan muka
	# dinding, kapsul pemain berhenti 0,35 m dari dinding jadi
	# tidak pernah menyentuhnya).
	for alas in [
		[Vector3(18.6, 0.4, 0.1), Vector3(cx, 0.2, 3.83)],
		[Vector3(18.6, 0.4, 0.1), Vector3(cx, 0.2, 16.17)],
		[Vector3(0.1, 0.4, 12.6), Vector3(-14.83, 0.2, cz)],
		[Vector3(0.1, 0.4, 5.2), Vector3(-33.17, 0.2, 6.6)],
		[Vector3(0.1, 0.4, 5.2), Vector3(-33.17, 0.2, 13.4)],
	]:
		g.add_child(MaterialTekstur.kotak(alas[0], alas[1], MaterialTekstur.pondasi(Palette.BATU, _skala_uv(alas[0]))))
	# Lis emas antar lantai + di bawah parapet (visual saja, pola
	# lis emas Surau di bawah atap — menonjol 0,3 m dari dinding).
	for y_lis in [3.2, 6.4, 9.6]:
		g.add_child(Palette.box(Vector3(18.6, 0.1, 12.6), Vector3(cx, y_lis, cz), Palette.EMAS_DESAIN, 0.4))
	# Atap datar zamrud (visual saja) + parapet zamrud 0,6 m.
	g.add_child(Palette.box(Vector3(18.4, 0.22, 12.4), Vector3(cx, 9.71, cz), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(18.5, 0.6, 0.25), Vector3(cx, 9.9, 4), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(18.5, 0.6, 0.25), Vector3(cx, 9.9, 16), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(0.25, 0.6, 12.25), Vector3(-33, 9.9, cz), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(0.25, 0.6, 12.25), Vector3(-15, 9.9, cz), Palette.ZAMRUD_GELAP))
	# Pintu jati dua daun TERTUTUP di celah barat (pola _daun_pintu
	# kampus_putri "W" — collision, pemain mentok; masuk pakai
	# tombol MASUK -> teleport, BUKAN jalan tembus).
	_static_box(g, Vector3(0.25, TINGGI_PINTU, 0.8), Vector3(-33, 1.3, 9.6), Palette.JATI)
	_static_box(g, Vector3(0.25, TINGGI_PINTU, 0.8), Vector3(-33, 1.3, 10.4), Palette.JATI)
	# Gagang emas di sisi luar (visual saja, tanpa collision).
	g.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(-33.16, 1.05, 9.94), Palette.EMAS, 0.4))
	g.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(-33.16, 1.05, 10.06), Palette.EMAS, 0.4))
	# Ambang emas di depan pintu + tiang emas di sisi pintu
	# (pola Surau — visual saja).
	g.add_child(Palette.box(Vector3(0.35, 0.024, 1.6), Vector3(-33, 0.012, 10), Palette.EMAS, 0.4))
	g.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(-33.2, 1.6, 9.05), Palette.EMAS, 0.4))
	g.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(-33.2, 1.6, 10.95), Palette.EMAS, 0.4))
	# Jendela lengkung (pola Surau): 1 per kamar per lantai di
	# dinding luar — utara (x -28,5 / -19,5, menghadap utara) +
	# selatan (sama, menghadap selatan). Pusat y = lantai+1,5 —
	# cakram atas (lantai+2,85) bersih dari lis emas (lantai+3,15).
	for lantai in range(3):
		var fy: float = float(lantai) * LANTAI_TINGGI
		for wx in [-28.5, -19.5]:
			_jendela_lengkung(g, "Jendela_U%d_%d" % [lantai + 1, 1 if wx < -24.0 else 2], Vector3(wx, fy + 1.5, 3.87), 0.0)
			_jendela_lengkung(g, "Jendela_S%d_%d" % [lantai + 1, 1 if wx < -24.0 else 2], Vector3(wx, fy + 1.5, 16.13), PI)
	# RONDE TEKSTUR P2 (Arsa, 18 Nov 2026 — DI-ACC Mas 14:01 WIB):
	# jendela lengkung di fasad BARAT (pintu utama) — sebelumnya
	# polos tanpa satu pun jendela (audit §2.2). Gaya PERSIS
	# utara/selatan (_jendela_lengkung yang sama), rot_y +PI/2 =
	# muka menghadap barat (-X). 2 per lantai (z 6,5 / 13,5,
	# simetris terhadap pintu z=10): bersih dari pintu (9,2..10,8),
	# tiang emas pintu (9,05 / 10,95), atap serambi (8,5..11,5),
	# dan plakat (8,0..12,0). x=-33,13 = 0,005 di luar muka
	# dinding barat (-33,125), sama seperti utara/selatan.
	for lantai in range(3):
		var fy: float = float(lantai) * LANTAI_TINGGI
		for wz in [6.5, 13.5]:
			_jendela_lengkung(g, "Jendela_B%d_%d" % [lantai + 1, 1 if wz < 10.0 else 2], Vector3(-33.13, fy + 1.5, wz), PI / 2.0)
	# RONDE TEKSTUR P2 (Arsa): lis emas VERTIKAL di kedua sudut
	# fasad barat — pilaster emas dari alas batu (y 0,4) sampai
	# parapet (y 9,6), menonjol 0,065 m dari muka dinding. z 4,3 /
	# 15,7 = di muka barat, bersih dari dinding utara/selatan
	# (z 3,875..4,125 / 15,875..16,125) dan dari alas batu.
	for lz in [4.3, 15.7]:
		g.add_child(Palette.box(Vector3(0.08, 9.2, 0.16), Vector3(-33.15, 5.0, lz), Palette.EMAS_DESAIN, 0.4))


## ------------------------------------------------------------------
## Annex tangga timur (x -15..-11,5, z 8,7..11,3, tinggi 9,6 +
## parapet) — dinding krem, lis emas, parapet + atap zamrud,
## 1 jendela lengkung kecil per lantai di dinding timur.
## ------------------------------------------------------------------
static func _annex(a: Node3D) -> void:
	var g := Node3D.new()
	g.name = "AnnexTangga"
	a.add_child(g)
	_static_box(g, Vector3(3.5, 0.14, 2.6), Vector3(-13.25, -0.05, 10), Palette.PASIR_GELAP)
	_static_box(g, Vector3(3.75, 9.6, 0.25), Vector3(-13.25, 4.8, 8.7), Palette.KREM)
	_static_box(g, Vector3(3.75, 9.6, 0.25), Vector3(-13.25, 4.8, 11.3), Palette.KREM)
	_static_box(g, Vector3(0.25, 9.6, 2.85), Vector3(-11.375, 4.8, 10), Palette.KREM)
	# Lis emas antar lantai + di bawah parapet (visual saja).
	for y_lis in [3.2, 6.4, 9.6]:
		g.add_child(Palette.box(Vector3(3.8, 0.1, 2.9), Vector3(-13.25, y_lis, 10), Palette.EMAS_DESAIN, 0.4))
	# Atap datar zamrud + parapet zamrud (visual saja).
	g.add_child(Palette.box(Vector3(3.9, 0.22, 3.0), Vector3(-13.25, 9.71, 10), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(3.75, 0.6, 0.25), Vector3(-13.25, 9.9, 8.7), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(3.75, 0.6, 0.25), Vector3(-13.25, 9.9, 11.3), Palette.ZAMRUD_GELAP))
	g.add_child(Palette.box(Vector3(0.25, 0.6, 2.85), Vector3(-11.375, 9.9, 10), Palette.ZAMRUD_GELAP))
	# Jendela lengkung kecil di dinding timur, 1 per lantai.
	for lantai in range(3):
		var fy: float = float(lantai) * LANTAI_TINGGI
		_jendela_lengkung(g, "JendelaAnnex%d" % (lantai + 1), Vector3(-11.44, fy + 1.5, 10), -PI / 2.0)


## ------------------------------------------------------------------
## Serambi di depan pintu barat (pola Serambi Surau — diperkecil
## untuk pintu 1,6 m): lantai batu + 2 tiang krem + atap miring
## zamrud berlis emas + 1 anak tangga batu. Tiang punya collision
## (pola perbaikan Musholla — tiang tanpa collision bikin pemain
## tembus). Atap menempel ke dinding (ujung timur masuk dinding).
## ------------------------------------------------------------------
static func _serambi(a: Node3D) -> void:
	var s := Node3D.new()
	s.name = "Serambi"
	a.add_child(s)
	_static_box(s, Vector3(3.0, 0.14, 2.6), Vector3(-34.6, -0.05, 10), Palette.BATU)
	for tz in [9.0, 11.0]:
		s.add_child(Palette.cylinder(0.09, 0.09, 2.6, Vector3(-35.9, 1.3, tz), Palette.KREM))
		# Kotak terinskripsi 0,212 (r=0,09) h=2,6 — anti-slip (fix3 Bagas).
		var tg := StaticBody3D.new()
		tg.position = Vector3(-35.9, 1.3, tz)
		var tg_shape := CollisionShape3D.new()
		var tg_box := BoxShape3D.new()
		tg_box.size = Vector3(0.212, 2.6, 0.212)
		tg_shape.shape = tg_box
		tg.add_child(tg_shape)
		s.add_child(tg)
	# Atap miring zamrud: miring 20° (ujung barat rendah, ujung
	# timur tinggi masuk dinding) + lis emas di tepi barat.
	var atap := Node3D.new()
	atap.name = "AtapSerambi"
	atap.position = Vector3(-34.6, 3.2, 10)
	atap.rotation.z = deg_to_rad(20.0)
	s.add_child(atap)
	atap.add_child(Palette.box(Vector3(3.4, 0.12, 3.0), Vector3(0, 0, 0), Palette.ZAMRUD_GELAP))
	atap.add_child(Palette.box(Vector3(0.1, 0.14, 3.0), Vector3(-1.65, 0, 0), Palette.EMAS_DESAIN, 0.4))
	# Anak tangga batu di depan serambi (visual saja).
	s.add_child(MaterialTekstur.kotak(Vector3(0.5, 0.08, 2.4), Vector3(-36.35, 0.04, 10), MaterialTekstur.pondasi(Palette.BATU, Vector3(0.25, 0.04, 1.2))))


## ------------------------------------------------------------------
## Plakat "ASRAMA PUTRA" di atas pintu (pola PlakatSurau: papan
## zamrud berbingkai emas + teks emas, menghadap barat).
## y=4,4 — di atas atap serambi (ujung timur y~3,84) supaya tidak
## tertutup/bertabrakan dengan atap; di bawah lis lantai 2 (6,4).
## RONDE TEKSTUR P6 (Arsa, 18 Nov 2026 — DI-ACC Mas 14:01 WIB):
## plakat DIPERBESAR supaya terbaca dari jarak normal 8–15 m
## (audit §3.4: plakat lama kecil, hanya terbaca dari dekat).
## Papan emas 2,9 -> 4,0 m, papan zamrud 2,8 -> 3,9 m, tinggi
## 0,72 -> 1,0 m (y 3,9..4,9 — bersih dari atap serambi di bawah
## dan lis lantai 2 di atas, bersih dari jendela barat Lt 1 di
## z 5,95..7,05 / 12,95..14,05), font label 20 -> 32.
## ------------------------------------------------------------------
static func _plakat(a: Node3D) -> void:
	var p := Node3D.new()
	p.name = "PlakatAsramaPutra"
	a.add_child(p)
	p.add_child(Palette.box(Vector3(0.06, 1.0, 4.0), Vector3(-33.16, 4.4, 10), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.08, 0.88, 3.9), Vector3(-33.20, 4.4, 10), Palette.ZAMRUD_GELAP))
	var label := Palette.label3d("ASRAMA PUTRA", Vector3(-33.27, 4.4, 10), 32, Color("#f2c14e"), false)
	label.name = "PlakatTeks"
	label.rotation.y = -PI / 2.0
	label.double_sided = false
	p.add_child(label)


## ------------------------------------------------------------------
## Jendela lengkung Surau (salin PERSIS PesantrenBuilder.
## _jendela_lengkung, ronde 21): kotak emas + kotak gelap + cakram
## emas + cakram gelap di atas. `pos` = pusat kotak di bidang
## dinding; `rot_y` memutar muka jendela ke luar (0 = utara,
## PI = selatan, -PI/2 = timur).
## ------------------------------------------------------------------
static func _jendela_lengkung(parent: Node3D, nama: String, pos: Vector3, rot_y: float) -> void:
	var j := Node3D.new()
	j.name = nama
	j.position = pos
	j.rotation.y = rot_y
	parent.add_child(j)
	j.add_child(Palette.box(Vector3(1.1, 1.8, 0.12), Vector3(0, 0, 0), Palette.EMAS, 0.3))
	j.add_child(Palette.box(Vector3(0.9, 1.6, 0.1), Vector3(0, 0, -0.02), Palette.ZAMRUD_GELAP))
	var cakram_emas := Palette.cylinder(0.55, 0.55, 0.06, Vector3(0, 0.8, -0.02), Palette.EMAS, 0.3)
	cakram_emas.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_emas)
	var cakram_gelap := Palette.cylinder(0.45, 0.45, 0.06, Vector3(0, 0.8, -0.04), Palette.ZAMRUD_GELAP)
	cakram_gelap.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_gelap)
