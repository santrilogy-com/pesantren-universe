class_name PencahayaanV2
extends Node3D
## Pencahayaan v2 — Cahya (lead lighting), 17 Nov 2026.
##
## Masalah: v2 GELAP di luar ruangan (Mas 22:52 WIB). 12 tiang lampu jalan
## hanya visual (bola emisif, tanpa OmniLight); gerbang, taman, dan pintu
## Musholla/Cangkruk tidak punya lampu nyata; interior Musholla tidak ikut
## terang di malam hari (2 lampunya tidak masuk grup LampuCahaya).
##
## Modul ini SATU file sendiri: 21 OmniLight baru (semua TANPA bayangan,
## hangat #ffd9a0, jangkauan 8-12 m) + perbaikan 2 lampu interior Musholla.
## 11 lampu Fase 1 (23:05, Cangkruk Putri dihapus 18 Nov -> 10 tersisa)
## + 4 lampu samping Surau (23:45, laporan Mas: sisi Surau masih gelap)
## + 7 lampu pintu Fase 2 (20 Nov, Mas ACC 20:41 WIB; audit 20:38).
## Matahari/key light + langit + ambient adalah urusan Rangga (langit_dinamis.gd)
## — modul ini TIDAK menyentuhnya.
##
## Pemasangan (SETELAH export ulang Rangga selesai), di main.gd:
##   var cahaya := PencahayaanV2.pasang(self, _outdoor_door)
## Posisi pintu Surau dibaca saat runtime supaya tetap benar setelah Surau
## diluruskan (pintu pindah dari (-3,38,-6,75)).

const WARNA_HANGAT := Color("#ffd9a0")
const WARNA_BOLA := Color("#ffe6b8")
const WARNA_TIANG := Color("#1a1a1a")

## Lampu yang dimodulasi modul ini: [{node, dasar}].
var _lampu: Array = []

## KUALITAS ADAPTIF (Rangga, 19 Nov 2026): pengali energi lampu omni
## per tingkat kualitas (Ringan 0.6 / Sedang-Tinggi 1.0). Hanya
## MENGALIKAN — faktor siang/malam lerpf(0.0, 2.0, f) di _process
## tetap jalan, tidak diganti.
static var pengali_energi: float = 1.0


## Pasang modul di world root. main = Main, pintu_surau = main._outdoor_door.
static func pasang(main: Node, pintu_surau: Vector3) -> PencahayaanV2:
	var p := PencahayaanV2.new()
	p.name = "PencahayaanV2"
	var root: Node = main._pesantren["root"]
	root.add_child(p)
	p._bangun(main, pintu_surau)
	return p


func _bangun(main: Node, pintu_surau: Vector3) -> void:
	# 1 — Pintu Surau (serambi): 1,5 m di selatan pintu, y=3,0.
	_tambah_lampu("LampuV2_PintuSurau", pintu_surau + Vector3(0, 3.0, 1.5), 1.0, 10.0, "dinding")
	# 2-5 — Jalan utama N-S: 4 dari 8 tiang yang ada (bola sudah ada).
	_tambah_lampu("LampuV2_Jalan_-50", Vector3(-2.5, 3.1, -50), 0.8, 12.0, "ada")
	_tambah_lampu("LampuV2_Jalan_10", Vector3(-2.5, 3.1, 10), 0.8, 12.0, "ada")
	_tambah_lampu("LampuV2_Jalan_50", Vector3(-2.5, 3.1, 50), 0.8, 12.0, "ada")
	_tambah_lampu("LampuV2_JalanSurau", Vector3(-6.89, 3.1, -2.67), 0.8, 12.0, "ada")
	# 6 — Gerbang x=14 (+ pos satpam di (17,5) ikut kena jangkauan 10 m).
	_tambah_lampu("LampuV2_Gerbang14", Vector3(15.5, 3.0, 0), 0.9, 10.0, "tiang")
	# 7 — Gerbang putri barat (115,0): 1,5 m di barat gerbang, di jalan E-W.
	_tambah_lampu("LampuV2_GerbangPutri", Vector3(113.5, 3.0, 0), 0.9, 10.0, "tiang")
	# 8 — Pintu Musholla putri (selatan): MUSHOLLA_EXIT (134,-17,5).
	_tambah_lampu("LampuV2_PintuMusholla", Vector3(134, 3.0, -17.5), 1.0, 10.0, "dinding")
	# 9 — Pintu Cangkruk putra: 1 m di selatan pintu (-22,-14).
	_tambah_lampu("LampuV2_PintuCangkrukPutra", Vector3(-22, 3.0, -13.0), 0.8, 8.0, "dinding")
	# 11 — Taman (pusat taman GLB (0,28)).
	_tambah_lampu("LampuV2_Taman", Vector3(0, 3.0, 28), 0.8, 10.0, "tiang")
	# 12-15 — Dinding samping Surau (23:45, laporan Mas: sisi masih gelap).
	# Surau 16x20, pusat (0,-14), dinding samping x=-8 dan x=+8, bentang
	# z=-4..-24. 2 lampu per sisi di tengah bentang (z=-9 dan z=-19,
	# jarak 10 m = jangkauan, jadi kolam cahaya saling bersentuhan).
	# Bola 0,6 m di luar dinding; braket diorientasikan ke samping (±X).
	_tambah_lampu("LampuV2_SurauBarat_A", Vector3(-8.6, 3.0, -9), 0.9, 10.0, "dinding", Vector3(-0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_SurauBarat_B", Vector3(-8.6, 3.0, -19), 0.9, 10.0, "dinding", Vector3(-0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_SurauTimur_A", Vector3(8.6, 3.0, -9), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_SurauTimur_B", Vector3(8.6, 3.0, -19), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	# 16-22 — 7 lampu pintu Fase 2 (20 Nov, Mas ACC 20:41 WIB; audit
	# 20:38: 7 fasad gelap di malam hari, interiornya terang — tidak ada
	# lampu pintu). Pola LampuV2_PintuMusholla: braket dinding + bola,
	# hangat, 0,9 -> 1,8 malam, jangkauan 10 m, tanpa bayangan.
	# Posisi = EXIT tiap gedung (1,5 m di luar pintu) dari konstanta
	# kampus_putri.gd (KELAS/ASRAMA/KANTOR/MADRASAH/STUDIO/POS_JAGA_EXIT)
	# + asrama_putra.gd ASRAMA_DOOR (-33,0,10). Koreksi dari usulan awal:
	# Asrama Putri di EXIT (144.5, 9), BUKAN di pintu (146, 9); Pos Jaga
	# di EXIT (173, -20), BUKAN (176, -20) — 176 itu di dalam gedung.
	# Braket: pintu barat (dinding di timur lampu) -> offset +X;
	# pintu selatan (Kelas) -> default; pintu utara (Studio, dinding di
	# selatan lampu) -> offset +Z.
	_tambah_lampu("LampuV2_PintuAsramaPutri", Vector3(144.5, 3.0, 9), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_PintuAsramaPutra", Vector3(-34.5, 3.0, 10), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_PintuKelasPutri", Vector3(130, 3.0, 15.5), 0.9, 10.0, "dinding")
	_tambah_lampu("LampuV2_PintuKantorUstadzah", Vector3(142.5, 3.0, -33), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_PintuMadrasah", Vector3(145.5, 3.0, -12), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	_tambah_lampu("LampuV2_PintuStudio", Vector3(166, 3.0, -17.5), 0.9, 10.0, "dinding", Vector3(0, 0.12, 0.25))
	_tambah_lampu("LampuV2_PintuPosJaga", Vector3(173, 3.0, -20), 0.9, 10.0, "dinding", Vector3(0.25, 0.12, 0), Vector3(0.5, 0.1, 0.3))
	# Perbaikan lampu lama: 2 lampu interior Musholla (lihat _perbaiki_musholla).
	_perbaiki_musholla(main)


## Faktor lampu menyala dari jam — bentuknya sama dengan keyframe "lampu"
## di LangitDinamis.K_LANGIT: 0 siang (05:30-17:30), 1 malam (18:00-04:00),
## transisi 17:30->18:00 (0,4->1,0) dan 04:00->05:30 (1->0).
static func faktor_lampu(jam: float) -> float:
	var j := jam
	if j < 0.0:
		j += 24.0
	if j >= 18.0 or j < 4.0:
		return 1.0
	if j >= 5.5 and j <= 17.5:
		return 0.0
	if j < 5.5:
		return 1.0 - smoothstep(4.0, 5.5, j)
	return lerpf(0.4, 1.0, smoothstep(17.5, 18.0, j))


func _process(_delta: float) -> void:
	var f := faktor_lampu(LangitDinamis.jam_saat_ini())
	for d in _lampu:
		var omni := d["node"] as OmniLight3D
		if omni != null:
			# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): lampu MATI di
			# siang hari (dulu energi = dasar x 1,0..2,0 — 82 lampu
			# omni nyala 24 jam, siang tetap 0,8-1,3). Malam tetap 2x.
			# KUALITAS ADAPTIF: dikali pengali_energi (Ringan 0.6) —
			# faktor siang/malam di atas TIDAK diganti.
			omni.light_energy = float(d["dasar"]) * lerpf(0.0, 2.0, f) * pengali_energi


## Jumlah lampu baru modul ini (untuk tes).
func jumlah_lampu_baru() -> int:
	return 21 # 10 Fase 1 tersisa + 4 samping Surau + 7 pintu Fase 2 (20 Nov)


## Energi lampu modul ini berdasarkan nama (untuk tes).
func energi_lampu(nama: String) -> float:
	for d in _lampu:
		var omni := d["node"] as OmniLight3D
		if omni != null and omni.name == nama:
			return omni.light_energy
	return -1.0


## Buat 1 OmniLight hangat tanpa bayangan + visualnya.
## visual: "ada" (bola sudah ada di tiang), "tiang" (tiang + bola),
## "dinding" (braket dinding + bola). braket_offset/ukuran: default untuk
## dinding menghadap selatan (pintu); untuk dinding samping isi ±X
## (mis. Vector3(-0.25, 0.12, 0) + ukuran (0.5, 0.1, 0.3) untuk x=-8).
func _tambah_lampu(nama: String, pos: Vector3, energi: float, jangkauan: float, visual: String, braket_offset: Vector3 = Vector3(0, 0.12, -0.25), braket_ukuran: Vector3 = Vector3(0.3, 0.1, 0.5)) -> OmniLight3D:
	var omni := OmniLight3D.new()
	omni.name = nama
	omni.position = pos
	omni.light_color = WARNA_HANGAT
	omni.light_energy = energi
	omni.omni_range = jangkauan
	omni.shadow_enabled = false
	omni.set_meta("energi_siang", energi)
	add_child(omni)
	_lampu.append({"node": omni, "dasar": energi})
	match visual:
		"tiang":
			add_child(_tiang(Vector3(pos.x, 0, pos.z), pos.y))
			add_child(_bola(pos, 0.2))
		"dinding":
			add_child(_braket(pos, braket_offset, braket_ukuran))
			add_child(_bola(pos, 0.16))
		"ada":
			pass
	return omni


func _bola(pos: Vector3, radius: float) -> MeshInstance3D:
	var bola := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): 12x6, bukan default
	# 64x32 — bola lampu 0,16 m tidak butuh 4.224 tris; tanpa bayangan.
	sm.radial_segments = 12
	sm.rings = 6
	bola.mesh = sm
	bola.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bola.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = WARNA_BOLA
	mat.emission_enabled = true
	mat.emission = WARNA_BOLA
	mat.emission_energy_multiplier = 2.0
	bola.material_override = mat
	return bola


func _tiang(dasar: Vector3, tinggi: float) -> MeshInstance3D:
	var tiang := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.05
	cm.bottom_radius = 0.07
	cm.height = tinggi
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): 10 segmen, tanpa bayangan.
	cm.radial_segments = 10
	tiang.mesh = cm
	tiang.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tiang.position = dasar + Vector3(0, tinggi * 0.5, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = WARNA_TIANG
	mat.roughness = 0.8
	tiang.material_override = mat
	return tiang


func _braket(pos: Vector3, offset: Vector3, ukuran: Vector3) -> MeshInstance3D:
	# Kotak kecil menempel di dinding di belakang bola. Default (pintu
	# menghadap selatan): dinding di utara bola, offset (0, 0.12, -0.25).
	# Dinding samping: offset ±X dan ukuran diputar (sumbu panjang = X).
	var braket := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = ukuran
	braket.mesh = bm
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): braket kecil tanpa bayangan.
	braket.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	braket.position = pos + offset
	var mat := StandardMaterial3D.new()
	mat.albedo_color = WARNA_TIANG
	mat.roughness = 0.8
	braket.material_override = mat
	return braket


## Perbaikan lampu lama: 2 lampu gantung interior Musholla tidak masuk grup
## LampuCahaya (interior_musholla.gd) — energinya tetap 0,9 siang-malam.
## Modul mengambil alih modulasinya (dasar -> 2x dasar malam) + menyalakan
## emisi bola lampunya. Palette.mat() memakai CACHE, jadi material bola harus
## di-duplicate() dulu sebelum diubah.
## Diterangkan 20 Nov (Mas: "Kurang terang" — verdict HP mengalahkan audit):
## dasar 0,9 -> 1,3 (malam 2,6) + jangkauan 6 -> 8 m (di interior_musholla.gd).
func _perbaiki_musholla(main: Node) -> void:
	for i in [1, 2]:
		var omni := main.find_child("LampuOmni_%d" % i, true, false) as OmniLight3D
		if omni == null:
			push_warning("PencahayaanV2: LampuOmni_%d tidak ketemu" % i)
			continue
		omni.set_meta("energi_siang", 1.3)
		omni.add_to_group("LampuCahaya")
		_lampu.append({"node": omni, "dasar": 1.3})
		var bola := main.find_child("Lampu_%d" % i, true, false) as MeshInstance3D
		if bola != null and bola.material_override != null:
			var mat := (bola.material_override as Material).duplicate() as StandardMaterial3D
			mat.emission_enabled = true
			mat.emission = WARNA_BOLA
			mat.emission_energy_multiplier = 2.0
			bola.material_override = mat
