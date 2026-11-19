extends SceneTree
## Tes headless P5 Fase 1 (Bima, 18 Nov 2026):
## membuktikan texture termuat + helper MaterialTekstur bekerja.
## Jalankan:
##   ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script skrip/tes_material_tekstur.gd
## Keluar 0 = LULUS semua, 1 = ada yang gagal.
##
## Catatan: pakai preload, bukan class_name global -- skrip SceneTree
## yang dijalankan lewat --script tidak selalu melihat cache
## class_name yang belum di-refresh editor (MaterialTekstur baru).
## Builder Fase 2 nanti tetap bisa pakai MaterialTekstur langsung
## setelah project dibuka/di-import editor sekali.

const MaterialTekstur = preload("res://scripts/material_tekstur.gd")
const Palette = preload("res://scripts/palette.gd")
## Yang dicek:
##  1. Ketiga file texture ada, termuat sebagai Texture2D, 1024x1024.
##  2. Rata-rata tiap channel tekstur ~= 0.90 (netral, tanpa cast)
##     dan selisih antar channel kecil -- bukti normalisasi.
##  3. Helper dinding()/pondasi()/lantai_batu(): albedo_color SAMA
##     PERSIS dengan warna palet (KREM/BATU), albedo_texture terisi,
##     roughness sesuai, dan cache mengembalikan material yang sama.
##  4. Warna tampil rata-rata (tekstur x tinta, aproksimasi sRGB)
##     dekat dengan tinta palet (selisih <= 0.12 per channel) --
##     palet tidak berubah jadi cokelat/gelap.
##  5. Fallback: bertekstur(null, warna) = material polos Palette
##     (gedung tetap tampil bila texture gagal dimuat).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("  OK   " + nama + (" — " + detail if detail != "" else ""))
	else:
		_gagal += 1
		print("  GAGAL " + nama + (" — " + detail if detail != "" else ""))


func _rata_channel(tex: Texture2D) -> Array:
	var img := tex.get_image()
	if img == null:
		return []
	img.convert(Image.FORMAT_RGB8)
	var kecil := img.duplicate() as Image
	kecil.resize(64, 64)
	var jumlah := [0.0, 0.0, 0.0]
	for y in range(64):
		for x in range(64):
			var c := kecil.get_pixel(x, y)
			jumlah[0] += c.r
			jumlah[1] += c.g
			jumlah[2] += c.b
	var n := 64.0 * 64.0
	return [jumlah[0] / n, jumlah[1] / n, jumlah[2] / n]


func _init() -> void:
	print("TES MATERIAL TEKSTUR P5 FASE 1")
	var berkas := {
		"dinding": MaterialTekstur.TEX_DINDING,
		"pondasi": MaterialTekstur.TEX_PONDASI,
		"lantai": MaterialTekstur.TEX_LANTAI,
	}
	var tex: Dictionary = {}
	for kunci in berkas:
		var path: String = berkas[kunci]
		var t := load(path) as Texture2D
		_cek("file termuat: " + path, t != null)
		if t == null:
			continue
		tex[kunci] = t
		_cek("ukuran 1024x1024: " + kunci, t.get_width() == 1024 and t.get_height() == 1024, str(t.get_width()) + "x" + str(t.get_height()))
		var rata: Array = _rata_channel(t)
		var netral := rata.size() == 3
		if netral:
			for c in range(3):
				if absf(float(rata[c]) - MaterialTekstur.RATA_TEKSTUR) > 0.03:
					netral = false
			var sebar := float(rata.max()) - float(rata.min())
			if sebar > 0.03:
				netral = false
		_cek("rata-rata netral ~0.90: " + kunci, netral, str(rata))

	# Helper dinding (default KREM).
	var m_dinding := MaterialTekstur.dinding()
	_cek("dinding(): albedo == KREM", m_dinding.albedo_color.to_html() == Palette.KREM.to_html(), m_dinding.albedo_color.to_html() + " vs " + Palette.KREM.to_html())
	_cek("dinding(): ada albedo_texture", m_dinding.albedo_texture != null)
	_cek("dinding(): roughness 0.95", is_equal_approx(m_dinding.roughness, 0.95), str(m_dinding.roughness))
	_cek("dinding(): cache sama", MaterialTekstur.dinding() == m_dinding)

	# Helper pondasi + lantai (default BATU).
	var m_pondasi := MaterialTekstur.pondasi()
	_cek("pondasi(): albedo == BATU", m_pondasi.albedo_color.to_html() == Palette.BATU.to_html(), m_pondasi.albedo_color.to_html())
	_cek("pondasi(): ada albedo_texture", m_pondasi.albedo_texture != null)
	var m_lantai := MaterialTekstur.lantai_batu()
	_cek("lantai_batu(): albedo == BATU", m_lantai.albedo_color.to_html() == Palette.BATU.to_html(), m_lantai.albedo_color.to_html())
	_cek("lantai_batu(): ada albedo_texture", m_lantai.albedo_texture != null)

	# Tint lain tetap tepat: zamrud + jati (dipakai atap/pintu Fase 2).
	var m_zamrud := MaterialTekstur.dinding(Palette.ZAMRUD_GELAP)
	_cek("dinding(ZAMRUD_GELAP): albedo tepat", m_zamrud.albedo_color.to_html() == Palette.ZAMRUD_GELAP.to_html(), m_zamrud.albedo_color.to_html())
	var m_jati := MaterialTekstur.dinding(Palette.JATI)
	_cek("dinding(JATI): albedo tepat", m_jati.albedo_color.to_html() == Palette.JATI.to_html(), m_jati.albedo_color.to_html())

	# Warna tampil rata-rata (tekstur x tinta) dekat dengan tinta.
	var pasangan := [
		["dinding x KREM", "dinding", Palette.KREM],
		["pondasi x BATU", "pondasi", Palette.BATU],
		["lantai x BATU", "lantai", Palette.BATU],
	]
	for p in pasangan:
		var nama: String = p[0]
		if not tex.has(p[1]):
			_cek("warna tampil dekat palet: " + nama, false, "tekstur tidak termuat")
			continue
		var rata: Array = _rata_channel(tex[p[1]])
		var tinta: Color = p[2]
		var tampil := Color(float(rata[0]) * tinta.r, float(rata[1]) * tinta.g, float(rata[2]) * tinta.b)
		var d := maxf(absf(tampil.r - tinta.r), maxf(absf(tampil.g - tinta.g), absf(tampil.b - tinta.b)))
		_cek("warna tampil dekat palet: " + nama, d <= 0.12, "tampil " + tampil.to_html() + " vs tinta " + tinta.to_html() + " (selisih maks %.3f)" % d)

	# Fallback tanpa tekstur + kotak bertekstur.
	var m_polos := MaterialTekstur.bertekstur(null, Palette.KREM)
	_cek("fallback null -> polos", m_polos.albedo_texture == null and m_polos.albedo_color.to_html() == Palette.KREM.to_html())
	var k := MaterialTekstur.kotak(Vector3(2, 3, 0.2), Vector3.ZERO, m_dinding)
	_cek("kotak(): MeshInstance3D + material", k is MeshInstance3D and k.material_override == m_dinding)

	print("TES MATERIAL TEKSTUR: %d lulus, %d gagal" % [_lulus, _gagal])
	if _gagal > 0:
		print("TES MATERIAL TEKSTUR: GAGAL")
		quit(1)
	else:
		print("TES MATERIAL TEKSTUR: LULUS")
		quit(0)
