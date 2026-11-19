extends Control
class_name IkonHUD
## Ikon HUD digambar kode — tanpa aset gambar, tanpa emoji (Baloo 2
## tidak punya glif emoji, pelajaran ronde 7). Dipakai rombakan HUD
## 18 Nov 2026 (Tara; arahan Mas 14:41 WIB: "bagian lain cukup pakai
## icon aja, misal chat maka icon amplop").
## Jenis: amplop (chat), peta, kartu (Kartu Santri), speaker (suara),
## kamera, expand (layar penuh), aksi (pose), bintang (interaksi),
## reset (reset posisi). Varian: speaker nyala/senyap, expand/ciut.
## Digambar dalam kotak desain -20..20 (skala ikut ukuran kontrol).
## V2 (Tara, 18 Nov 2026 — arahan Mas 15:10 WIB: jangan primitif,
## tiru MLBB): garis TEBAL (4.5, bukan 3.0), tiap icon digambar dua
## kali — bayangan gelap geser (1.5, 2) dulu lalu icon utama — plus
## isi padat di beberapa icon (badan amplop/kamera, kepala, lensa,
## pin) supaya terbaca seperti icon game, bukan sketsa garis tipis.

var jenis: String = "amplop":
	set(v):
		jenis = v
		queue_redraw()
var varian: String = "":
	set(v):
		varian = v
		queue_redraw()
var warna: Color = Color.WHITE:
	set(v):
		warna = v
		queue_redraw()
# ROMBAKAN HUD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB):
# icon bentuk gamepad + icon bar atas digambar TANPA bayangan gelap
# (mockup: putih polos transparan, tanpa bayang). Default true
# supaya icon lama (yang mengandalkan bayangan) tidak berubah.
var bayangan: bool = true:
	set(v):
		bayangan = v
		queue_redraw()

const TEBAL := 4.5
# ROMBAKAN HUD v3: lebar garis icon bentuk gamepad — TIPIS saja,
# hanya outline (arahan Mas 17:15 WIB, referensi stik PS5 DualSense).
const TEBAL_TIPIS := 2.5
# VARIAN B rev1 (DI-ACC Mas 18:43 WIB, mockup hud-v3-perbaikan-b-rev1.png):
# icon bentuk di tombol gamepad sedikit lebih tebal (3->4, X 4->5
# di skala mockup) supaya terbaca di atas kaca bertinta. Diatur
# per-instans lewat `tebal_tipis` (default TEBAL_TIPIS — dipakai
# icon baris pop-up yang tetap tipis); bentuk X selalu +1.0.
var tebal_tipis: float = TEBAL_TIPIS:
	set(v):
		tebal_tipis = v
		queue_redraw()

# Warna + geser gambar yang SEDANG digambar (bayangan lalu utama).
var _c: Color = Color.WHITE
var _of: Vector2 = Vector2.ZERO


func set_varian(v: String) -> void:
	varian = v


func _s() -> float:
	return minf(size.x, size.y) / 40.0


func _p(x: float, y: float) -> Vector2:
	return size * 0.5 + (Vector2(x, y) + _of) * _s()


func _v(x: float, y: float) -> Vector2:
	return Vector2(x, y) * _s()


func _garis(a: Vector2, b: Vector2) -> void:
	draw_line(_p(a.x, a.y), _p(b.x, b.y), _c, TEBAL, true)


func _kotak(x: float, y: float, w: float, h: float) -> void:
	draw_rect(Rect2(_p(x, y), Vector2(w, h) * _s()), _c, false, TEBAL)


func _isi_kotak(x: float, y: float, w: float, h: float, gelap: float) -> void:
	draw_rect(Rect2(_p(x, y), Vector2(w, h) * _s()), _c.darkened(gelap))


func _lingkar(x: float, y: float, r: float) -> void:
	draw_arc(_p(x, y), r * _s(), 0.0, TAU, 32, _c, TEBAL, true)


# --- garis tipis (ROMBAKAN HUD v3: icon bentuk gamepad) ---
# X digambar 1.0 lebih tebal dari bentuk lain (varian B rev1:
# 4 untuk △□○, 5 untuk ✕ — skala mockup).
func _garis_tipis(a: Vector2, b: Vector2, tebal: float = -1.0) -> void:
	var w := tebal_tipis if tebal < 0.0 else tebal
	draw_line(_p(a.x, a.y), _p(b.x, b.y), _c, w, true)


func _kotak_tipis(x: float, y: float, w: float, h: float) -> void:
	draw_rect(Rect2(_p(x, y), Vector2(w, h) * _s()), _c, false, tebal_tipis)


func _lingkar_tipis(x: float, y: float, r: float) -> void:
	draw_arc(_p(x, y), r * _s(), 0.0, TAU, 32, _c, tebal_tipis, true)


func _titik(x: float, y: float, r: float) -> void:
	draw_circle(_p(x, y), r * _s(), _c)


func _bintang() -> void:
	var titik: PackedVector2Array = []
	for i in 10:
		var r := 15.0 if i % 2 == 0 else 6.5
		var a := -PI * 0.5 + float(i) * PI / 5.0
		titik.append(_p(cos(a) * r, sin(a) * r))
	draw_colored_polygon(titik, _c)


func _gambar() -> void:
	match jenis:
		"amplop":
			_isi_kotak(-16, -10, 32, 20, 0.35)
			_kotak(-16, -10, 32, 20)
			_garis(Vector2(-16, -10), Vector2(0, 4))
			_garis(Vector2(16, -10), Vector2(0, 4))
		"peta":
			_kotak(-15, -12, 30, 24)
			_garis(Vector2(-5, -12), Vector2(-5, 12))
			_garis(Vector2(5, -12), Vector2(5, 12))
			_titik(0, 0, 4.0)
		"kartu":
			_kotak(-16, -11, 32, 22)
			_titik(-9, -2, 4.5)
			_garis(Vector2(-13, 7), Vector2(-5, 7))
			_garis(Vector2(2, -6), Vector2(12, -6))
			_garis(Vector2(2, 0), Vector2(12, 0))
			_garis(Vector2(2, 6), Vector2(9, 6))
		"speaker":
			var badan := PackedVector2Array([
				_p(-14, -5), _p(-6, -5), _p(4, -12),
				_p(4, 12), _p(-6, 5), _p(-14, 5),
			])
			draw_colored_polygon(badan, _c)
			if varian == "senyap":
				_garis(Vector2(8, -8), Vector2(17, 8))
				_garis(Vector2(17, -8), Vector2(8, 8))
			else:
				draw_arc(_p(6, 0), 8.0 * _s(), -0.9, 0.9, 12, _c, TEBAL, true)
				draw_arc(_p(6, 0), 13.0 * _s(), -0.9, 0.9, 12, _c, TEBAL, true)
		"kamera":
			_isi_kotak(-15, -7, 30, 17, 0.35)
			draw_rect(Rect2(_p(-6, -12), Vector2(10, 5) * _s()), _c)
			_kotak(-15, -7, 30, 17)
			_lingkar(0, 1, 6.5)
			# VARIAN B rev1: icon kamera di strip atas — titik lensa
			# ZAMRUD GELAP supaya lensa terbaca di atas tile terang
			# (mockup hud-v3-perbaikan-b-rev1.png; icon lain di strip
			# tetap putih polos). Hanya di pass utama (_of == ZERO),
			# bukan di pass bayangan — supaya tidak ada noda hijau
			# di belakang icon.
			if varian == "lensa_zamrud" and _of == Vector2.ZERO:
				var c_lama := _c
				_c = GayaTombol.ZAMRUD_GELAP
				_titik(0, 1, 2.5)
				_c = c_lama
			else:
				_titik(0, 1, 2.5)
		"expand":
			# Empat panah sudut: keluar (expand) atau masuk (ciut).
			var masuk := varian == "ciut"
			for sx in [-1.0, 1.0]:
				for sy in [-1.0, 1.0]:
					var ujung := Vector2(13 * sx, 13 * sy) if not masuk else Vector2(5 * sx, 5 * sy)
					var pangkal := Vector2(5 * sx, 5 * sy) if not masuk else Vector2(13 * sx, 13 * sy)
					_garis(pangkal, ujung)
					_garis(ujung, Vector2(ujung.x - 6 * sx, ujung.y))
					_garis(ujung, Vector2(ujung.x, ujung.y - 6 * sy))
		"aksi":
			_titik(0, -8, 5.0)
			_garis(Vector2(0, -3), Vector2(0, 4))
			draw_arc(_p(0, 15), 11.0 * _s(), PI, TAU, 24, _c, TEBAL, true)
		"bintang":
			_bintang()
		"reset":
			var a := 5.9
			draw_arc(_p(0, 0), 12.0 * _s(), 0.7, a, 40, _c, TEBAL, true)
			var n := Vector2(cos(a), sin(a))
			var t := Vector2(-sin(a), cos(a))
			var ujung := _p(n.x * 12.0, n.y * 12.0)
			var dasar := ujung - t * 6.0 * _s()
			draw_line(ujung, dasar + n * 3.0 * _s(), _c, TEBAL, true)
			draw_line(ujung, dasar - n * 3.0 * _s(), _c, TEBAL, true)
		# ROMBAKAN HUD v3: bentuk gamepad ala stik PS5 — TIPIS, hanya
		# outline (bukan padat). Dipakai tombol aksi diamond + baris
		# pop-up "PETUNJUK TOMBOL". "lingkaran" = tombol bulat ○
		# (bukan sabit — koreksi Mas 17:15 WIB).
		"segitiga":
			_garis_tipis(Vector2(-13, 10), Vector2(13, 10))
			_garis_tipis(Vector2(13, 10), Vector2(0, -14))
			_garis_tipis(Vector2(0, -14), Vector2(-13, 10))
		"kotak":
			_kotak_tipis(-12, -12, 24, 24)
		"lingkaran":
			_lingkar_tipis(0, 0, 13.0)
		"x":
			_garis_tipis(Vector2(-11, -11), Vector2(11, 11), tebal_tipis + 1.0)
			_garis_tipis(Vector2(11, -11), Vector2(-11, 11), tebal_tipis + 1.0)
		"kualitas":
			# KUALITAS ADAPTIF (Rangga, 19 Nov 2026): tiga batang
			# menanjak (sinyal kualitas) — dipakai tombol strip atas.
			draw_rect(Rect2(_p(-15, 5), Vector2(7, 8) * _s()), _c)
			draw_rect(Rect2(_p(-4, -1), Vector2(7, 14) * _s()), _c)
			draw_rect(Rect2(_p(7, -7), Vector2(7, 20) * _s()), _c)
		_:
			_kotak(-12, -12, 24, 24)


func _draw() -> void:
	# Bayangan dulu (gelap, geser kanan-bawah), lalu icon utama —
	# icon terasa berdimensi, bukan garis datar menempel tombol.
	# ROMBAKAN HUD v3: bayangan dimatikan untuk icon gamepad + bar
	# atas (bayangan=false) — mockup: tanpa bayang.
	if bayangan:
		_c = Color(0, 0, 0, 0.4)
		_of = Vector2(1.5, 2.0)
		_gambar()
	_c = warna
	_of = Vector2.ZERO
	_gambar()
