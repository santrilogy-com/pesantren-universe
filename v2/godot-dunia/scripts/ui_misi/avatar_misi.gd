class_name AvatarMisi
extends Control
## Medali potret pembicara UI misi — Fase A, A9 (Dita, 18 Nov 2026).
## Digambar kode di _draw(), meniru medali_potret() di
## v2/konsep/desain-ui-misi.py (Sinta): lingkaran latar krem,
## wajah, songkok putih (kyai) / peci hitam nasional (sanusi)
## ATAU hijab krem (ustadzah), jubah zamrud + kerah emas bentuk V,
## senyum sederhana.
## Tanpa texture eksternal, tanpa emoji.
## tipe: "kyai" (Ust. Aqsal M) | "ustadzah" | "sanusi";
## nilai lain -> "kyai".

## Warna kulit sesuai kontrak tugas (bukan KULIT skrip mockup
## #deb896): kyai #d59e78, sanusi/ustadzah #c68e5e.
const KULIT_KYAI := Color("#d59e78")
const KULIT_LAIN := Color("#c68e5e")
## Hijab krem sedikit lebih gelap dari latar medali supaya
## bentuknya tetap kebaca (latar sudah krem #f2ead6).
const HIJAB := Color("#e2d5b0")
const GELAP_MATA := Color("#281e19")
const PUTIH := Color("#ffffff")
## Peci hitam NASIONAL (rata) untuk Sanusi — build Kirana 19 Nov
## 2026: Sanusi di dunia memakai peci_model "nasional" hitam
## (#151515 + lis #0d0d0d, lihat player.gd PAKAIAN).
const PECI_HITAM := Color("#151515")
const LIS_HITAM := Color("#0d0d0d")
const ABU_GARIS := Color("#5a5a5a")
const ABU_TERANG := Color("#c8c8c8")
const RIM_DALAM := Color("#8a6d1f")

var tipe: String = "kyai"


func _init() -> void:
	custom_minimum_size = Vector2(96, 96)
	# Hiasan saja — jangan menahan klik dari kontrol di bawahnya.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Ganti tipe potret ("kyai" | "ustadzah" | "sanusi"; nilai
## lain, termasuk huruf besar, jatuh ke "kyai"). Gambar ulang
## hanya bila tipenya benar-benar berubah.
func atur_tipe(t: String) -> void:
	var baru := t.strip_edges().to_lower()
	if baru != "ustadzah" and baru != "sanusi":
		baru = "kyai"
	if baru == tipe:
		return
	tipe = baru
	queue_redraw()


func _draw() -> void:
	var sisi := minf(size.x, size.y)
	if sisi <= 0.0:
		return
	# Semua gambar di bawah memakai ruang 120x120 ala tile
	# medali_potret() di skrip mockup; skala + pusatkan di sini.
	var s := sisi / 120.0
	var off := Vector2((size.x - 120.0 * s) * 0.5, (size.y - 120.0 * s) * 0.5)
	draw_set_transform(off, 0.0, Vector2(s, s))
	_gambar()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _gambar() -> void:
	var c := Vector2(60, 60)
	var kulit := KULIT_KYAI if tipe == "kyai" else KULIT_LAIN
	# Latar medali krem.
	draw_circle(c, 60.0, GayaMisi.KREM)
	# Jubah zamrud (bawah, terpotong lingkaran medali).
	draw_colored_polygon(_jubah_poin(), GayaMisi.ZAMRUD)
	if tipe == "ustadzah":
		# Selendang hijab menutup dada di atas jubah.
		var drape := PackedVector2Array([
			Vector2(42, 72), Vector2(78, 72),
			Vector2(88, 104), Vector2(32, 104)])
		draw_colored_polygon(drape, HIJAB)
	if tipe == "ustadzah":
		# Tudung hijab, wajah di dalamnya.
		_elips(Vector2(60, 52), 32.0, 38.0, HIJAB)
		_elips(Vector2(60, 54), 16.0, 19.0, kulit)
		_elips(Vector2(53, 55), 2.5, 2.5, GELAP_MATA)
		_elips(Vector2(67, 55), 2.5, 2.5, GELAP_MATA)
		_busur(Vector2(60, 64), 7.0, 5.0, 10.0, 170.0, GELAP_MATA, 2.0)
	else:
		# Leher + wajah.
		draw_rect(Rect2(52, 68, 16, 14), kulit)
		_elips(Vector2(60, 53), 22.0, 23.0, kulit)
		if tipe == "sanusi":
			# Peci HITAM NASIONAL (rata, tanpa kubah) + lis gelap
			# tipis di bawahnya — sama dengan Sanusi di dunia
			# (peci_model "nasional"). FLAG §4 SELESAI: medali ini
			# dulu menggambar songkok putih.
			var peci := PackedVector2Array([
				Vector2(38, 33), Vector2(38, 18), Vector2(42, 14),
				Vector2(78, 14), Vector2(82, 18), Vector2(82, 33)])
			draw_colored_polygon(peci, PECI_HITAM)
			draw_line(Vector2(38, 35), Vector2(82, 35), LIS_HITAM, 2.0, true)
		else:
			# Songkok putih (setengah elips atas) + pita gelap
			# tipis di bawahnya, persis medali_potret().
			var peci := PackedVector2Array([Vector2(60, 33)])
			for i in range(0, 25):
				var a := deg_to_rad(lerpf(180.0, 360.0, float(i) / 24.0))
				peci.append(Vector2(60, 33) + Vector2(cos(a) * 24.0, sin(a) * 21.0))
			draw_colored_polygon(peci, PUTIH)
			_busur(Vector2(60, 33), 24.0, 21.0, 180.0, 360.0, ABU_TERANG, 2.0)
			draw_line(Vector2(38, 46), Vector2(82, 46), ABU_GARIS, 2.0, true)
		# Mata + senyum.
		_elips(Vector2(50.5, 54.5), 2.5, 2.5, GELAP_MATA)
		_elips(Vector2(69.5, 54.5), 2.5, 2.5, GELAP_MATA)
		_busur(Vector2(60, 66), 8.0, 6.0, 10.0, 170.0, GELAP_MATA, 2.0)
	# Kerah emas bentuk V (di atas jubah/selendang; untuk
	# ustadzah digeser ke bawah supaya tidak tertutup tudung).
	if tipe == "ustadzah":
		draw_line(Vector2(60, 88), Vector2(46, 104), GayaMisi.EMAS, 3.0, true)
		draw_line(Vector2(60, 88), Vector2(74, 104), GayaMisi.EMAS, 3.0, true)
	else:
		draw_line(Vector2(60, 80), Vector2(42, 98), GayaMisi.EMAS, 3.0, true)
		draw_line(Vector2(60, 80), Vector2(78, 98), GayaMisi.EMAS, 3.0, true)
	# Rim emas tebal + garis emas gelap tipis di dalamnya
	# (lapisan paling atas, persis medali_potret()).
	draw_arc(c, 57.0, 0.0, TAU, 96, GayaMisi.EMAS, 5.0, true)
	draw_arc(c, 53.5, 0.0, TAU, 96, RIM_DALAM, 1.0, true)


## Jubah: persegi membulat (x 16..104, y 80 ke bawah, sudut
## atas radius 10) yang bawahnya mengikuti busur lingkaran
## medali — supaya tidak ada sudut yang keluar dari medali.
func _jubah_poin() -> PackedVector2Array:
	var pts := PackedVector2Array()
	# y tempat sisi x=16/104 memotong lingkaran r=60.
	var y_potong := 60.0 + sqrt(3600.0 - 44.0 * 44.0)
	pts.append(Vector2(26, 80))
	pts.append(Vector2(94, 80))
	# Sudut kanan atas (pusat 94,90 r 10, -90..0 derajat).
	for i in range(1, 7):
		var a := deg_to_rad(lerpf(-90.0, 0.0, float(i) / 6.0))
		pts.append(Vector2(94, 90) + Vector2(cos(a), sin(a)) * 10.0)
	pts.append(Vector2(104, y_potong))
	# Busur bawah lingkaran (pusat 60,60 r 60) dari kanan ke
	# kiri lewat bawah.
	var a0 := rad_to_deg(atan2(y_potong - 60.0, 44.0))
	var a1 := rad_to_deg(atan2(y_potong - 60.0, -44.0))
	for i in range(1, 24):
		var a := deg_to_rad(lerpf(a0, a1, float(i) / 24.0))
		pts.append(Vector2(60, 60) + Vector2(cos(a), sin(a)) * 60.0)
	pts.append(Vector2(16, y_potong))
	# Sudut kiri atas (pusat 26,90 r 10, 180..270 derajat).
	for i in range(1, 7):
		var a := deg_to_rad(lerpf(180.0, 270.0, float(i) / 6.0))
		pts.append(Vector2(26, 90) + Vector2(cos(a), sin(a)) * 10.0)
	return pts


## Titik-titik elips penuh (untuk draw_colored_polygon).
func _elips_poin(pusat: Vector2, rx: float, ry: float, jumlah: int = 40) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in jumlah:
		var a := TAU * float(i) / float(jumlah)
		pts.append(pusat + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


func _elips(pusat: Vector2, rx: float, ry: float, warna: Color) -> void:
	draw_colored_polygon(_elips_poin(pusat, rx, ry), warna)


## Busur elips sebagai garis (sudut derajat, 0 = timur,
## 90 = selatan — sama seperti PIL di skrip mockup).
func _busur(pusat: Vector2, rx: float, ry: float, awal_deg: float, akhir_deg: float, warna: Color, lebar: float) -> void:
	var pts := PackedVector2Array()
	for i in range(0, 25):
		var a := deg_to_rad(lerpf(awal_deg, akhir_deg, float(i) / 24.0))
		pts.append(pusat + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, warna, lebar, true)
