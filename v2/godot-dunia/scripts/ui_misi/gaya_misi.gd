class_name GayaMisi
extends RefCounted
## Kit visual bersama 4 UI misi — Fase A (Dita, 18 Nov 2026).
## Palet + wajah panel/tombol/chip persis mockup ACC Mas
## (dialog-aqsal-v2, ruang-belajar-v1, tes-kenaikan-v1,
## panel-misi-v1; skrip v2/konsep/desain-ui-misi.py):
## panel gradien zamrud gelap (di sini StyleBoxFlat datar —
## StyleBoxFlat tidak bisa gradien, jadi dipakai warna panel
## ZAMRUD_PANEL), rim emas 3, radius ~18, bayangan jatuh;
## tab judul pill emas;
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


## ---------- GRADIEN v2 (Sinta, 19 Nov 2026 — Konsep UI v2 ACC Mas) ----------
## StyleBoxFlat tidak bisa gradien — gradien dibakar ke ImageTexture
## (sekali per panel) lalu dipakai StyleBoxTexture 9-slice
## (texture_margins = radius) atau TextureRect latar.
## Tekstur membawa sudut membulat + rim + pita/strip sekaligus.
## GradientTexture2D sengaja tidak dipakai: ia tidak bisa membawa
## sudut membulat + rim dalam satu tekstur.
## UKURAN BAKAR (pelajaran 19 Nov 2026): TextureRect latar direntang
## penuh ke ukuran panel — panggang HARUS seukuran panel sebenarnya
## (dialog 660x560, banner 560x88, pop-up 480x460). Panggang 96x96
## direntang ~7x bikin sudut bergerigi/tangga saat di-zoom (foto
## dialog v2 + "pita robek" pop-up). StyleBoxTexture 9-slice (tab,
## tombol) aman di 96 px karena sudut TIDAK direntang.

static func buat_tekstur_gradien(warna_atas: Color, warna_bawah: Color, radius: int, rim: Color, rim_lebar: int, pita: Color = Color(0, 0, 0, 0), pita_tinggi: int = 0, strip_bawah: Color = Color(0, 0, 0, 0), strip_tinggi: int = 0, ukuran := Vector2i(96, 96)) -> ImageTexture:
	var img := Image.create(ukuran.x, ukuran.y, false, Image.FORMAT_RGBA8)
	var cx := float(ukuran.x) * 0.5
	var cy := float(ukuran.y) * 0.5
	var hw := float(ukuran.x) * 0.5
	var hh := float(ukuran.y) * 0.5
	var r := float(radius)
	for y in range(ukuran.y):
		var t := float(y) / float(maxi(ukuran.y - 1, 1))
		var col := warna_atas.lerp(warna_bawah, t)
		for x in range(ukuran.x):
			# Jarak bertanda ke kotak bersudut membulat (SDF).
			var qx := absf(float(x) + 0.5 - cx) - (hw - r)
			var qy := absf(float(y) + 0.5 - cy) - (hh - r)
			var d := Vector2(maxf(qx, 0.0), maxf(qy, 0.0)).length() + minf(maxf(qx, qy), 0.0) - r
			if d > 0.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif rim_lebar > 0 and d > -float(rim_lebar):
				img.set_pixel(x, y, rim)
			elif pita_tinggi > 0 and y < pita_tinggi:
				img.set_pixel(x, y, pita)
			elif strip_tinggi > 0 and y >= ukuran.y - strip_tinggi:
				img.set_pixel(x, y, strip_bawah)
			else:
				img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)


## StyleBoxTexture gradien dari tekstur bakar (9-slice, sudut = radius).
static func _kotak_gradien(tekstur: Texture2D, radius: int) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tekstur
	s.texture_margin_left = float(radius)
	s.texture_margin_right = float(radius)
	s.texture_margin_top = float(radius)
	s.texture_margin_bottom = float(radius)
	s.draw_center = true
	return s


## Panel dialog v2: StyleBoxFlat TRANSPARAN (gradien datang dari
## TextureRect latar, anak pertama panel) + rim emas 2 + radius 26
## + bayangan lebih besar/lembut. Content margin 3 supaya latar
## gradien (radius 23) tidak menutupi rim emas.
static func gaya_panel_gradien() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)
	s.border_color = EMAS
	s.set_border_width_all(2)
	s.set_corner_radius_all(26)
	s.shadow_color = Color(0.0, 0.0, 0.0, 100.0 / 255.0)
	s.shadow_size = 16
	s.shadow_offset = Vector2(0, 8)
	s.content_margin_left = 3.0
	s.content_margin_right = 3.0
	s.content_margin_top = 3.0
	s.content_margin_bottom = 3.0
	return s


## TextureRect latar gradien vertikal — dipakai sebagai anak PERTAMA
## PanelContainer (PanelContainer menaruh semua anak di rect yang
## sama, jadi latar jatuh di belakang isi). Radius = radius panel - 3.
## `ukuran` = ukuran panel sebenarnya (1:1, tanpa rentang) — WAJIB
## diisi pemanggil; default 480x460 (pola pop-up) hanya jaga-jaga.
static func buat_latar_gradien(warna_atas: Color, warna_bawah: Color, radius: int, ukuran := Vector2i(480, 460)) -> TextureRect:
	var t := TextureRect.new()
	t.texture = buat_tekstur_gradien(warna_atas, warna_bawah, radius, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, ukuran)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


## Tab judul v2: gradien emas terang -> emas, radius 22.
static func gaya_tab_gradien() -> StyleBoxTexture:
	var tek := buat_tekstur_gradien(EMAS_TERANG, EMAS, 22, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, Vector2i(96, 48))
	return _kotak_gradien(tek, 22)


## Tombol emas v2: gradien emas terang -> emas + garis bawah lebih
## gelap (kesan 3D, bayangan tombol), radius 22.
static func gaya_tombol_emas_gradien() -> StyleBoxTexture:
	var tek := buat_tekstur_gradien(EMAS_TERANG, EMAS, 22, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, EMAS.darkened(0.25), 4, Vector2i(96, 56))
	return _kotak_gradien(tek, 22)


## Tombol emas v2 saat hover: gradien sedikit lebih terang.
static func gaya_tombol_emas_gradien_hover() -> StyleBoxTexture:
	var tek := buat_tekstur_gradien(EMAS_TERANG.lightened(0.12), EMAS.lightened(0.12), 22, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, EMAS.darkened(0.2), 4, Vector2i(96, 56))
	return _kotak_gradien(tek, 22)


## Tombol emas v2 saat ditekan: gradien sedikit lebih gelap.
static func gaya_tombol_emas_gradien_pressed() -> StyleBoxTexture:
	var tek := buat_tekstur_gradien(EMAS.darkened(0.08), EMAS.darkened(0.18), 22, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0, EMAS.darkened(0.35), 4, Vector2i(96, 56))
	return _kotak_gradien(tek, 22)


## Subjudul kepala dialog v2: kapital berjarak, emas terang, 14.
## font_spacing diabaikan engine bila tidak didukung — aman.
static func buat_label_subjudul(teks: String) -> Label:
	var l := buat_label(teks.to_upper(), 14, EMAS_TERANG)
	l.add_theme_constant_override("font_spacing", 2)
	return l


## Titik progres babak: aktif = emas terisi, sisanya outline krem.
static func buat_dot(aktif: bool) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(12, 12)
	var s := StyleBoxFlat.new()
	if aktif:
		s.bg_color = EMAS
	else:
		s.bg_color = Color(0, 0, 0, 0)
		var garis := KREM
		garis.a = 120.0 / 255.0
		s.border_color = garis
		s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	p.add_theme_stylebox_override("panel", s)
	return p


static func buat_dot_progres(jumlah: int, aktif: int) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	for i in range(jumlah):
		h.add_child(buat_dot(i + 1 == aktif))
	return h


## Chip keycap dengan IKON gambar-kode di kiri teks (Tara, 19 Nov
## 2026): "✕ Lanjut" / "□ Chat" memakai glif ✕/□ yang TIDAK ADA
## di Baloo 2 — tofu di web. Ikon digambar IkonHUD ("x" / "kotak"),
## teks tetap Label. (Versi teks buat_chip_kunci() DIHAPUS — tidak
## ada pemanggil lagi; jangan pasang glif ✕/□ sebagai teks.)
static func buat_chip_kunci_ikon(jenis_ikon: String, teks: String) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = ZAMRUD_KARTU
	var garis := KREM
	garis.a = 150.0 / 255.0
	s.border_color = garis
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	p.add_theme_stylebox_override("panel", s)
	p.add_theme_constant_override("margin_left", 8)
	p.add_theme_constant_override("margin_right", 8)
	p.add_theme_constant_override("margin_top", 4)
	p.add_theme_constant_override("margin_bottom", 4)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(h)
	var ikon := IkonHUD.new()
	ikon.jenis = jenis_ikon
	ikon.warna = KREM
	ikon.bayangan = false
	ikon.custom_minimum_size = Vector2(16, 16)
	h.add_child(ikon)
	var l := buat_label(teks, 14, KREM)
	h.add_child(l)
	return p


## Panah "›" di kanan tombol utama (anak Label, teks tombol TIDAK
## diubah — tes membaca .text tetap lolos). Dipakai tombol pilihan
## pertama dialog saja.
static func tambah_panah_kanan(b: Button) -> void:
	var panah := buat_label("›", 22, ZAMRUD_GELAP)
	panah.anchor_left = 1.0
	panah.anchor_right = 1.0
	panah.anchor_top = 0.5
	panah.anchor_bottom = 0.5
	panah.offset_left = -34.0
	panah.offset_top = -14.0
	panah.offset_right = -16.0
	panah.offset_bottom = 14.0
	panah.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panah.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(panah)


## Umpan tekan v2: tombol mengecil ke 0.97 sesaat saat ditekan lalu
## kembali — dipasang di buat_tombol_emas (semua tombol emas misi).
static func pasang_umpan_tekan(b: Button) -> void:
	b.resized.connect(func() -> void: b.pivot_offset = b.size * 0.5)
	b.button_down.connect(func() -> void: _tween_tekan(b, 0.97, 0.06))
	b.button_up.connect(func() -> void: _tween_tekan(b, 1.0, 0.10))


static func _tween_tekan(b: Button, target: float, durasi: float) -> void:
	if b.has_meta("_tween_tekan"):
		var lama := b.get_meta("_tween_tekan") as Tween
		if lama != null and lama.is_valid():
			lama.kill()
	b.pivot_offset = b.size * 0.5
	var tw := b.create_tween()
	tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(b, "scale", Vector2(target, target), durasi)
	b.set_meta("_tween_tekan", tw)


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
## garis vertikal, footer vertikal). Bungkus
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


## Label CAMPURAN Latin + Arab (Tara, 19 Nov 2026): kata Latin
## pakai Baloo 2 (font default proyek), kata Arab pakai Amiri —
## Baloo 2 tidak punya glif Arab, jadi kata Arab di Label biasa
## tampil kotak-kotak di web. Teks dipecah per kata (spasi); tiap
## run kata Arab dibalik urutannya supaya tampil benar (teks Arab
## dibaca kanan-ke-kiri di dalam run-nya). Mengembalikan
## HFlowContainer (membungkus kata per kata) — pakai sebagai
## pengganti Label untuk teks yang mengandung Arab (pertanyaan
## Tes Kenaikan Q4/Q5/Q9). Isi soal TIDAK diubah, hanya font
## per katanya.
static func buat_label_campur(teks: String, ukuran: int, warna: Color) -> HFlowContainer:
	var alir := HFlowContainer.new()
	alir.add_theme_constant_override("h_separation", 7)
	alir.add_theme_constant_override("v_separation", 2)
	alir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var kata := teks.split(" ", false)
	var i := 0
	while i < kata.size():
		if _mengandung_arab(String(kata[i])):
			var run: Array[String] = []
			while i < kata.size() and _mengandung_arab(String(kata[i])):
				run.append(String(kata[i]))
				i += 1
			run.reverse()
			for k in run:
				alir.add_child(_label_arab_sepotong(k, ukuran, warna))
		else:
			alir.add_child(buat_label(String(kata[i]), ukuran, warna))
			i += 1
	return alir


## True bila kata mengandung satu pun karakter blok Arab
## (huruf + harakat + tanda baca Arab).
static func _mengandung_arab(kata: String) -> bool:
	for j in kata.length():
		var k := kata.unicode_at(j)
		if (k >= 0x0600 and k <= 0x06FF) or (k >= 0x0750 and k <= 0x077F) or (k >= 0x08A0 and k <= 0x08FF) or (k >= 0xFB50 and k <= 0xFDFF) or (k >= 0xFE70 and k <= 0xFEFF):
			return true
	return false


## Satu kata Arab dengan font Amiri (tanpa rata tengah — ikut
## alur HFlowContainer).
static func _label_arab_sepotong(teks: String, ukuran: int, warna: Color) -> Label:
	var l := buat_label(teks, ukuran, warna)
	var font := load(FONT_ARAB) as Font
	if font != null:
		l.add_theme_font_override("font", font)
	return l


## Tombol emas: font 20, teks zamrud gelap, tanpa focus.
## v2 (19 Nov 2026): gradien emas + umpan tekan 0.97.
static func buat_tombol_emas(teks: String) -> Button:
	var b := Button.new()
	b.text = teks
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", ZAMRUD_GELAP)
	b.add_theme_color_override("font_hover_color", ZAMRUD_GELAP)
	b.add_theme_color_override("font_pressed_color", ZAMRUD_GELAP)
	b.add_theme_stylebox_override("normal", gaya_tombol_emas_gradien())
	b.add_theme_stylebox_override("hover", gaya_tombol_emas_gradien_hover())
	b.add_theme_stylebox_override("pressed", gaya_tombol_emas_gradien_pressed())
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", gaya_tombol_emas())
	pasang_umpan_tekan(b)
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


## Chip kecil dengan IKON gambar-kode di kiri teks (Tara, 19 Nov
## 2026): riwayat tes "Soal N ✓ Benar / ✗ Salah" memakai glif
## ✓/✗ yang tofu di web. Ikon digambar IkonHUD ("centang" /
## "silang"), teks tetap Label. Gaya pill sama seperti buat_chip.
static func buat_chip_ikon(jenis_ikon: String, teks: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", gaya_chip())
	p.add_theme_constant_override("margin_left", 14)
	p.add_theme_constant_override("margin_right", 14)
	p.add_theme_constant_override("margin_top", 7)
	p.add_theme_constant_override("margin_bottom", 7)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(h)
	var ikon := IkonHUD.new()
	ikon.jenis = jenis_ikon
	ikon.warna = EMAS_TERANG
	ikon.bayangan = false
	ikon.custom_minimum_size = Vector2(16, 16)
	h.add_child(ikon)
	var l := buat_label(teks, 14, EMAS_TERANG)
	h.add_child(l)
	return p


## (Chip "TEKS DRAF" DIHAPUS atas keputusan Mas, 19 Nov 2026
## 13:05 WIB — fungsi buat_pill_draf() ikut dihapus; jangan
## dipasang lagi.)

## Tab judul: pill emas berisi label judul ukuran 24 tebal
## warna zamrud gelap, rata tengah. Padding 28 kiri-kanan /
## 10 atas-bawah (mockup: lebar tab = lebar teks + 56).
## v2 (19 Nov 2026): pill bergradien emas terang -> emas.
static func buat_tab_judul(judul: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", gaya_tab_gradien())
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


## ---------- GENSHIN — Ruang Belajar chat (Sinta, 19 Nov 2026) ----------
## Konsep v2/konsep/KONSEP-RUANG-BELAJAR-CHAT-v1.md §7+§8 (ACC Mas):
## kotak dialog bawah gelap tembus pandang + garis emas tepi atas,
## nama pembicara emas tebal, gelembung kecil player emas.
## Panel gradien v1 TIDAK dipakai di tampilan ini. Helper gelembung
## ustadz (gaya_gelembung_ustadz) DICORET dari scope §7 — ustadz
## bicara di dalam kotak dialog, bukan gelembung.

## Kotak dialog Genshin: zamrud gelap alpha ~0.92, rim emas 1 px,
## garis emas 3 px di tepi atas, radius 18.
static func gaya_kotak_dialog_genshin() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	var bg := ZAMRUD_GELAP
	bg.a = 235.0 / 255.0
	s.bg_color = bg
	s.border_color = EMAS
	s.set_border_width_all(1)
	s.border_width_top = 3
	s.set_corner_radius_all(18)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s


## Gelembung kecil player: emas isi penuh, radius 16, teks
## zamrud gelap (dipakai label di dalam gelembung).
static func gaya_gelembung_pemain() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS
	s.set_corner_radius_all(16)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


## Label tebal Baloo 2 Bold (seperti judul tab) — nama pembicara
## di kotak dialog Genshin. Bila font tebal gagal dimuat, tetap
## tampil dengan font default proyek.
static func buat_label_tebal(teks: String, ukuran: int, warna: Color) -> Label:
	var l := buat_label(teks, ukuran, warna)
	var tebal := load(_FONT_TEBAL) as Font
	if tebal != null:
		l.add_theme_font_override("font", tebal)
	return l
