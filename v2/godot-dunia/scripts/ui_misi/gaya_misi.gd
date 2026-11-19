class_name GayaMisi
extends RefCounted
## Kit visual bersama 4 UI misi — Fase A (Dita, 18 Nov 2026).
## Palet + wajah panel/tombol/chip persis mockup ACC Mas
## (dialog-aqsal-v2, ruang-belajar-v1, tes-kenaikan-v1,
## panel-misi-v1; skrip v2/konsep/desain-ui-misi.py):
## panel gradien zamrud gelap (di sini StyleBoxFlat datar —
## StyleBoxFlat tidak bisa gradien, jadi dipakai warna panel
## ZAMRUD_PANEL), rim emas 3, radius ~18, bayangan jatuh;
## tab judul pill emas; tag "TEKS DRAF" outline emas;
## tombol emas isi penuh + tombol outline krem.
## Font Latin: default proyek (Baloo 2 SemiBold, lihat
## project.godot); Arab: Amiri Bold (FONT_ARAB).
## Semua builder hanya membuat node/stylebox baru — aman
## dipanggil headless (tanpa scene tree).

const ZAMRUD := Color("#065f46")
const ZAMRUD_GELAP := Color("#043b2c")
const ZAMRUD_PANEL := Color("#0d3b2e")
const ZAMRUD_KARTU := Color("#032d22")
const EMAS := Color("#c9a227")
const EMAS_TERANG := Color("#e8c45a")
const KREM := Color("#f2ead6")
const KREM_REDUP := Color("#c9c2ae")
const FONT_ARAB := "res://fonts/Amiri-Bold.ttf"

## Baloo 2 Bold (satu keluarga dengan font default proyek) untuk
## teks yang harus tebal (judul tab). Bila berkas tidak ada,
## pemanggil tetap memakai font default proyek.
const _FONT_TEBAL := "res://fonts/Baloo2-Bold.tres"


## Panel utama: zamrud panel alpha 242, rim emas 3, radius 18,
## bayangan jatuh hitam alpha 90, offset (0, 6), blur 12.
static func gaya_panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var bg := ZAMRUD_PANEL
	bg.a = 242.0 / 255.0
	s.bg_color = bg
	s.border_color = EMAS
	s.set_border_width_all(3)
	s.set_corner_radius_all(18)
	s.shadow_color = Color(0.0, 0.0, 0.0, 90.0 / 255.0)
	s.shadow_size = 12
	s.shadow_offset = Vector2(0, 6)
	return s


## Kartu di dalam panel: zamrud kartu alpha 200, outline krem
## tipis alpha 120 lebar 1, radius 12.
static func gaya_kartu() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var bg := ZAMRUD_KARTU
	bg.a = 200.0 / 255.0
	s.bg_color = bg
	var garis := KREM
	garis.a = 120.0 / 255.0
	s.border_color = garis
	s.set_border_width_all(1)
	s.set_corner_radius_all(12)
	return s


## Tab judul: pill emas, radius 22.
static func gaya_tab() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS
	s.set_corner_radius_all(22)
	return s


## Tombol emas (pilihan utama): isi emas, radius 22.
static func gaya_tombol_emas() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS
	s.set_corner_radius_all(22)
	return s


## Tombol emas saat hover: sedikit lebih terang (emas terang).
static func gaya_tombol_emas_hover() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS_TERANG
	s.set_corner_radius_all(22)
	return s


## Tombol emas saat ditekan: sedikit lebih gelap dari emas.
static func gaya_tombol_emas_pressed() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS.darkened(0.18)
	s.set_corner_radius_all(22)
	return s


## Tombol outline (pilihan tanya): isi zamrud kartu, outline
## krem lebar 2, radius 22.
static func gaya_tombol_outline() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = ZAMRUD_KARTU
	s.border_color = KREM
	s.set_border_width_all(2)
	s.set_corner_radius_all(22)
	return s


## Chip: transparan, outline emas lebar 2, radius 13.
static func gaya_chip() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	s.border_color = EMAS
	s.set_border_width_all(2)
	s.set_corner_radius_all(13)
	return s


## Label Latin (font default proyek = Baloo 2), ukuran + warna diminta.
## bungkus=false (default): TANPA autowrap — label satu baris, lebar
## minimum = lebar teks. PENTING (Raka, 18 Nov 2026 — cacat foto
## ui-misi v1): autowrap di SEMUA label membuat lebar minimum label
## kolaps ke ~0 — di HBox (baris atas, footer, baris misi) label
## terjepit 1 px dan teks membungkus huruf-per-huruf (tab emas jadi
## garis vertikal, "TEKS DRAF" vertikal, footer vertikal). Bungkus
## HANYA untuk teks isi panjang di VBox/Scroll (pertanyaan,
## petunjuk, catatan) — lewat bungkus=true.
static func buat_label(teks: String, ukuran: int, warna: Color, bungkus := false) -> Label:
	var l := Label.new()
	l.text = teks
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if bungkus else TextServer.AUTOWRAP_OFF
	l.add_theme_font_size_override("font_size", ukuran)
	l.add_theme_color_override("font_color", warna)
	return l


## Label Arab: font Amiri Bold, rata tengah, warna emas terang
## (seperti contoh Arab di mockup Ruang Belajar). Bila font
## Amiri gagal dimuat, tetap tampil dengan font default.
static func buat_label_arab(teks: String, ukuran: int) -> Label:
	var l := buat_label(teks, ukuran, EMAS_TERANG)
	var font := load(FONT_ARAB) as Font
	if font != null:
		l.add_theme_font_override("font", font)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


## Tombol emas: font 20, teks zamrud gelap, tanpa focus.
static func buat_tombol_emas(teks: String) -> Button:
	var b := Button.new()
	b.text = teks
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", ZAMRUD_GELAP)
	b.add_theme_color_override("font_hover_color", ZAMRUD_GELAP)
	b.add_theme_color_override("font_pressed_color", ZAMRUD_GELAP)
	b.add_theme_stylebox_override("normal", gaya_tombol_emas())
	b.add_theme_stylebox_override("hover", gaya_tombol_emas_hover())
	b.add_theme_stylebox_override("pressed", gaya_tombol_emas_pressed())
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", gaya_tombol_emas())
	return b


## Tombol outline: font 20, teks krem, tanpa focus.
static func buat_tombol_outline(teks: String) -> Button:
	var b := Button.new()
	b.text = teks
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", KREM)
	b.add_theme_color_override("font_hover_color", KREM)
	b.add_theme_color_override("font_pressed_color", KREM)
	b.add_theme_stylebox_override("normal", gaya_tombol_outline())
	b.add_theme_stylebox_override("hover", gaya_tombol_outline())
	b.add_theme_stylebox_override("pressed", gaya_tombol_outline())
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", gaya_tombol_outline())
	return b


## Chip kecil: label emas terang ukuran 14 dalam pill outline
## emas, padding 14 kiri-kanan / 7 atas-bawah.
static func buat_chip(teks: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", gaya_chip())
	p.add_theme_constant_override("margin_left", 14)
	p.add_theme_constant_override("margin_right", 14)
	p.add_theme_constant_override("margin_top", 7)
	p.add_theme_constant_override("margin_bottom", 7)
	var l := buat_label(teks, 14, EMAS_TERANG)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	return p


## Pill penanda "TEKS DRAF" (isi draf, menunggu tashih).
static func buat_pill_draf() -> PanelContainer:
	return buat_chip("TEKS DRAF")


## Tab judul: pill emas berisi label judul ukuran 24 tebal
## warna zamrud gelap, rata tengah. Padding 28 kiri-kanan /
## 10 atas-bawah (mockup: lebar tab = lebar teks + 56).
static func buat_tab_judul(judul: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", gaya_tab())
	p.add_theme_constant_override("margin_left", 28)
	p.add_theme_constant_override("margin_right", 28)
	p.add_theme_constant_override("margin_top", 10)
	p.add_theme_constant_override("margin_bottom", 10)
	var l := buat_label(judul, 24, ZAMRUD_GELAP)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tebal := load(_FONT_TEBAL) as Font
	if tebal != null:
		l.add_theme_font_override("font", tebal)
	p.add_child(l)
	return p


## Bilah progres 0..1: trek zamrud kartu + garis krem tipis,
## isi emas; tanpa angka persen.
static func buat_bilah_progres() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = 0.0
	bar.show_percentage = false
	var trek := StyleBoxFlat.new()
	trek.bg_color = ZAMRUD_KARTU
	var garis := KREM
	garis.a = 90.0 / 255.0
	trek.border_color = garis
	trek.set_border_width_all(1)
	trek.set_corner_radius_all(8)
	var isi := StyleBoxFlat.new()
	isi.bg_color = EMAS
	isi.set_corner_radius_all(8)
	bar.add_theme_stylebox_override("background", trek)
	bar.add_theme_stylebox_override("fill", isi)
	return bar
