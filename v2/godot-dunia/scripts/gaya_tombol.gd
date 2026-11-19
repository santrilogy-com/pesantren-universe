extends RefCounted
class_name GayaTombol
## Wajah tombol HUD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB,
## mockup hud-v3-desain-gamepad-v3.png): PUTIH polos transparan,
## TANPA gloss/glow/bayangan/timbul. MENGGANTIKAN desain v2 (glossy
## ala MLBB: gradien + ring + sorot + bayang) yang sudah ditolak
## lewat mockup.
## - disc tombol aksi: putih datar alpha ~0.28, tepi anti-alias;
## - rounded-rect (bar ikon atas, pill "Main Bersama"): putih datar
##   alpha ~0.5 / 0.32;
## - icon bentuk gamepad (△ □ ○ ✕) digambar IkonHUD, bukan di sini.
## StyleBoxFlat tidak bisa membuat disc, jadi wajah dibuat sebagai
## ImageTexture per-piksel lalu dipasang sebagai TextureRect anak
## Button; stylebox Button sendiri dikosongkan. Sinyal, .text, dan
## rect Button TIDAK berubah — hanya tampilannya.
##
## VARIAN B rev1 (Tara, 18 Nov 2026 — DI-ACC Mas 18:43 WIB, mockup
## hud-v3-perbaikan-b-rev1.png): kontras di lantai marmer putih
## TERBUKTI buruk untuk putih polos (disc nyaris hilang total) —
## wajah disc + pill kini KACA BURAM BERTINTA zamrud muda
## (222,234,228) alpha 150, TANPA bayangan (varian B); icon/
## chevron/teks pill ZAMRUD GELAP #043B2C (lihat ikon_hud.gd +
## virtual_joystick.gd). Bar ikon atas TETAP putih alpha 0.5
## (mockup: tile putih alpha 128 di atas langit — terbaca).

## Warna kaca buram bertinta (varian B rev1) + alpha-nya.
const TINT_KACA := Color(0.871, 0.918, 0.894)  # (222, 234, 228)
const TINT_KNOB := Color(0.831, 0.894, 0.863)  # (212, 228, 220)
const ALPHA_KACA := 150.0 / 255.0
const ALPHA_KNOB := 170.0 / 255.0
## Zamrud gelap #043B2C — icon/chevron/teks pill (bukan putih,
## bukan hitam — hitam ditolak Mas 17:04 WIB).
const ZAMRUD_GELAP := Color(0.016, 0.231, 0.173)


## Disc datar: isi seragam alpha, tepi anti-alias 1 px.
## Sudut transparan. `warna` default putih (v3) — varian B rev1
## memakai TINT_KACA (lihat disc_kaca).
static func disc_putih(diameter: int, alpha: float, warna: Color = Color.WHITE) -> ImageTexture:
	var img := Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var c := float(diameter) * 0.5
	var r := float(diameter) * 0.5
	for y in diameter:
		for x in diameter:
			var dx := float(x) - c + 0.5
			var dy := float(y) - c + 0.5
			var jarak := sqrt(dx * dx + dy * dy)
			if jarak > r:
				continue
			var col := Color(warna.r, warna.g, warna.b, alpha)
			col.a *= clampf(r - jarak, 0.0, 1.0)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)


## Disc kaca buram bertinta zamrud muda (varian B rev1).
static func disc_kaca(diameter: int) -> ImageTexture:
	return disc_putih(diameter, ALPHA_KACA, TINT_KACA)


## Rounded-rect datar (bar ikon atas + pill "Main Bersama").
static func bulat_putih(w: int, h: int, radius: int, alpha: float, warna: Color = Color.WHITE) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rad := float(radius)
	for y in h:
		for x in w:
			var d := _sdf_bulat(float(x) + 0.5, float(y) + 0.5, float(w), float(h), rad)
			if d > 1.0:
				continue
			var col := Color(warna.r, warna.g, warna.b, alpha)
			col.a *= clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)


## Pill kaca buram bertinta zamrud muda (varian B rev1).
static func bulat_kaca(w: int, h: int, radius: int) -> ImageTexture:
	return bulat_putih(w, h, radius, ALPHA_KACA, TINT_KACA)


## Jarak bertanda (signed distance) ke rounded-rect — negatif di
## dalam bentuk, positif di luar. Dipakai bulat_putih.
static func _sdf_bulat(x: float, y: float, w: float, h: float, radius: float) -> float:
	var cx := w * 0.5
	var cy := h * 0.5
	var qx := absf(x - cx) - (cx - radius)
	var qy := absf(y - cy) - (cy - radius)
	var luar := Vector2(maxf(qx, 0.0), maxf(qy, 0.0)).length()
	var dalam := minf(maxf(qx, qy), 0.0)
	return luar + dalam - radius


## Pasang wajah sebagai anak Button. Stylebox Button dikosongkan
## (wajah yang menggambar), anak TextureRect ikut ukuran Button
## (FULL_RECT) jadi tetap benar bila Button diskalakan.
## show_behind_parent: wajah digambar DI BELAKANG gambar Button
## sendiri — penting untuk tombol berteks ("Main Bersama"): tanpa
## ini TextureRect anak menutupi teks Button (temuan foto v2).
## Umpan balik tekan: wajah digelapkan saat button_down, pulih saat
## button_up — seperti tombol game yang "masuk" saat ditekan.
## Kembalikan TextureRect wajah (disimpan juga di meta "wajah"
## untuk dites test_hud_rombak.gd).
static func pasang_wajah(b: Button, tekstur: ImageTexture) -> TextureRect:
	for mode in ["normal", "hover", "pressed", "disabled", "focus"]:
		b.add_theme_stylebox_override(mode, StyleBoxEmpty.new())
	var wajah := TextureRect.new()
	wajah.texture = tekstur
	wajah.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wajah.stretch_mode = TextureRect.STRETCH_SCALE
	wajah.set_anchors_preset(Control.PRESET_FULL_RECT)
	wajah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wajah.show_behind_parent = true
	b.add_child(wajah)
	b.button_down.connect(func() -> void: wajah.modulate = Color(0.7, 0.7, 0.7))
	b.button_up.connect(func() -> void: wajah.modulate = Color.WHITE)
	b.set_meta("wajah", wajah)
	return wajah
