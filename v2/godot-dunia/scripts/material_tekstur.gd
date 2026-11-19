class_name MaterialTekstur
## P5 FASE 1 (Bima, 18 Nov 2026 — ACC Mas 14:01 WIB):
## material bertekstur untuk gedung prosedural.
##
## Aturan utama: PALET TIDAK BOLEH BERUBAH. Godot mengalikan
## albedo_texture x albedo_color, jadi tekstur mentah Poly Haven
## (gelap, ber-cast warna) x tinta krem = cokelat -- palet rusak
## (pelajaran yang sama dari jilbab rebuild Kirana 18 Nov: jersey
## x krem = cokelat). Karena itu SEMUA tekstur di sini sudah
## dinormalisasi dulu (lihat v2/skrip/normalisasi_tekstur_p5.py):
## rata-rata tiap channel = 0.90, tanpa cast warna, kontras lokal
## dipertahankan. Hasilnya tekstur x tinta ~= 0.90 x tinta: warna
## palet tetap terbaca, permukaan dapat detail plester/batu.
##
## Tekstur (CC0, Poly Haven, lokal di models/ -- lihat
## models/README-TEKSTUR-P5.md):
##   - dinding:  White Plaster 02 (plester halus, dinding krem)
##   - pondasi:  Stone Block Wall (blok batu, fondasi/tangga)
##   - lantai:   Stone Floor (lantai batu, teras/lantai)
##
## FASE 2 (nanti, setelah geometri P1-P4/P6 selesai): ganti
## Palette.mat(...) di asrama_putra.gd / kampus_putri.gd /
## pesantren_builder.gd dengan MaterialTekstur.dinding(...) dst.
## UV: BoxMesh memakai UV 0..1 per sisi, jadi skala_uv mengatur
## pengulangan -- patokan: skala_uv ~= ukuran_dinding / 2 m
## (tekstur berulang tiap ~2 m, sambungan tidak terlihat karena
## tekstur seamless). Bila tekstur gagal dimuat, jatuh ke
## Palette.mat polos (gedung tetap tampil, tanpa crash).

const TEX_DINDING := "res://models/dinding_white_plaster_02_1k.ktx2"
const TEX_PONDASI := "res://models/pondasi_stone_block_wall_1k.ktx2"
const TEX_LANTAI := "res://models/lantai_stone_floor_1k.ktx2"

## Rata-rata tiap channel tekstur setelah normalisasi (dipakai tes).
const RATA_TEKSTUR := 0.90

static var _cache: Dictionary = {}
static var _tex_dinding: Texture2D = null
static var _tex_pondasi: Texture2D = null
static var _tex_lantai: Texture2D = null


## Material bertekstur umum. tinta = warna palet (albedo_color);
## tekstur hanya memberi detail permukaan, bukan warna.
static func bertekstur(tex: Texture2D, tinta: Color, roughness: float = 0.95, skala_uv: Vector3 = Vector3.ONE, metallic: float = 0.0) -> StandardMaterial3D:
	var kunci := str(tex.resource_path if tex != null else "tanpa-tekstur") + "|" + tinta.to_html() + "|" + str(roughness) + "|" + str(skala_uv) + "|" + str(metallic)
	if _cache.has(kunci):
		return _cache[kunci]
	if tex == null:
		var polos := Palette.mat(tinta, metallic, roughness)
		_cache[kunci] = polos
		return polos
	var m := StandardMaterial3D.new()
	m.albedo_color = tinta
	m.albedo_texture = tex
	m.roughness = roughness
	m.metallic = metallic
	m.uv1_scale = skala_uv
	_cache[kunci] = m
	return m


## Dinding plester halus. Default tinta KREM (dinding utama semua
## gedung, audit §1.1). roughness 0.95: plester matte, bukan kilap.
static func dinding(tinta: Color = Palette.KREM, skala_uv: Vector3 = Vector3.ONE) -> StandardMaterial3D:
	if _tex_dinding == null:
		_tex_dinding = load(TEX_DINDING) as Texture2D
	return bertekstur(_tex_dinding, tinta, 0.95, skala_uv)


## Fondasi / anak tangga batu. Default tinta BATU (#B8B2A4).
static func pondasi(tinta: Color = Palette.BATU, skala_uv: Vector3 = Vector3.ONE) -> StandardMaterial3D:
	if _tex_pondasi == null:
		_tex_pondasi = load(TEX_PONDASI) as Texture2D
	return bertekstur(_tex_pondasi, tinta, 0.9, skala_uv)


## Lantai / teras batu. Default tinta BATU (#B8B2A4).
static func lantai_batu(tinta: Color = Palette.BATU, skala_uv: Vector3 = Vector3.ONE) -> StandardMaterial3D:
	if _tex_lantai == null:
		_tex_lantai = load(TEX_LANTAI) as Texture2D
	return bertekstur(_tex_lantai, tinta, 0.9, skala_uv)


## Kotak bertekstur (cerminan Palette.box, tapi materialnya
## diberikan -- untuk Fase 2, supaya builder tinggal ganti
## Palette.box(...) dengan MaterialTekstur.kotak(..., mat)).
static func kotak(ukuran: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = ukuran
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	return mi
