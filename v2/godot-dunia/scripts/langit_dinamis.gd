class_name LangitDinamis
extends Node3D
## Langit dinamis mengikuti JAM NYATA perangkat (RONDE 5, Mas 15 Nov ~20:36 WIB).
##
## 5 fase dengan transisi halus (interpolasi keyframe + smoothstep, bukan
## lompat): subuh (04:00-05:30), pagi (05:30-10:00), siang (10:00-15:00),
## sore (15:00-18:00, golden hour ronde 4 dipertahankan nuansanya),
## malam (18:00-04:00, langit berbintang + BULAN, bukan matahari).
##
## Cara kerja: baca jam lokal perangkat (Time.get_datetime_dict_from_system),
## cari keyframe sebelum/sesudah jam itu, lerp warna langit + posisi
## matahari/bulan + energi cahaya + bintang + lampu. Satu DirectionalLight3D
## dipakai bergantian: siang/sore sebagai matahari, malam sebagai cahaya
## bulan (kebiruan, redup). Matahari & bulan 3D (bola emissive + halo)
## supaya terlihat di renderer web — cakram ProceduralSkyMaterial TIDAK
## tampil di web (pelajaran ronde 3/4). Kabut TETAP MATI (pelajaran ronde 4:
## kabut menutupi langit di renderer web meski fog_sky_affect=0.0).
##
## debug_jam >= 0: paksa jam ini (untuk tes + foto tiap fase). -1 (default):
## jam sistem nyata. Saat debug aktif, nilai diterapkan LANGSUNG (snap)
## supaya screenshot deterministik; saat jam nyata, transisi mengikuti
## keyframe yang memang sudah kontinu terhadap waktu.
##
## FITUR CUACA (Wulan, 17 Nov 2026): kondisi langit mengikuti cuaca
## nyata via scripts/cuaca.gd (Open-Meteo) — cerah / berawan / mendung /
## hujan. Awan = gumpalan bola pipih yang melayang; hujan = tetes tipis
## (MultiMesh, 160 tetes di sekitar kamera, tanpa sistem partikel baru
## yang berat). debug_kondisi != "" memaksa kondisi itu (tes + foto).

## Jam paksa untuk tes/foto (jam desimal, mis. 5.0 = 05:00). -1 = jam sistem.
static var debug_jam: float = -1.0
## Kondisi paksa untuk tes/foto ("cerah"/"berawan"/"mendung"/"hujan"). "" = ikut Cuaca.
static var debug_kondisi: String = ""

## Kondisi cuaca yang dikenal (sama dengan Cuaca.KONDISI_*).
const KONDISI_CERAH := "cerah"
const KONDISI_BERAWAN := "berawan"
const KONDISI_MENDUNG := "mendung"
const KONDISI_HUJAN := "hujan"
const SEMUA_KONDISI: Array[String] = ["cerah", "berawan", "mendung", "hujan"]

## Awan: 12 gumpalan, tinggi 45-70 m, radius sebar 30-150 m.
const JUMLAH_AWAN := 12
const TINGGI_AWAN_MIN := 45.0
const TINGGI_AWAN_MAX := 70.0
## Hujan: 160 tetes di kotak 40 x 24 x 40 m mengikuti kamera.
const JUMLAH_TETES := 160
const LEBAR_HUJAN := 40.0
const TINGGI_HUJAN := 24.0
const CEPAT_JATUH_MIN := 16.0
const CEPAT_JATUH_MAX := 24.0

## Azimuth: 0 = utara (-Z), 90 = timur (+X), 180 = selatan (+Z),
## 270 = barat (-X). Elevasi: 0 = cakrawala, 90 = zenit.
const JARAK_BENDA_LANGIT := 380.0
const JARAK_BINTANG := 360.0
const JUMLAH_BINTANG := 140

## Keyframe LANGIT: [jam, atas, horison, bawah, dasar, ambient, bintang, lampu].
## "bintang" = faktor malam (0 siang, 1 malam) — dipakai juga untuk
## visibilitas bulan; "lampu" = faktor lampu menyala (0 siang, 1 malam).
const K_LANGIT: Array = [
	{"jam": 0.0, "atas": Color("#0a0f24"), "horison": Color("#1a2440"), "bawah": Color("#0a0f1a"), "dasar": Color("#141c30"), "ambient": 0.30, "bintang": 1.0, "lampu": 1.0},
	{"jam": 4.0, "atas": Color("#0a0f24"), "horison": Color("#1a2440"), "bawah": Color("#0a0f1a"), "dasar": Color("#141c30"), "ambient": 0.30, "bintang": 1.0, "lampu": 1.0},
	{"jam": 5.5, "atas": Color("#7fb8e8"), "horison": Color("#ffd9a0"), "bawah": Color("#6a8f6a"), "dasar": Color("#e8d9b8"), "ambient": 0.60, "bintang": 0.0, "lampu": 0.0},
	{"jam": 10.0, "atas": Color("#3f9be0"), "horison": Color("#bfe3f5"), "bawah": Color("#5a8f57"), "dasar": Color("#e8d9b8"), "ambient": 0.85, "bintang": 0.0, "lampu": 0.0},
	{"jam": 15.0, "atas": Color("#3f8fd2"), "horison": Color("#ff9e57"), "bawah": Color("#5a8f57"), "dasar": Color("#e8d9b8"), "ambient": 0.75, "bintang": 0.0, "lampu": 0.0},
	{"jam": 17.5, "atas": Color("#4a6fb0"), "horison": Color("#ff8a4a"), "bawah": Color("#4a7a52"), "dasar": Color("#d9b98a"), "ambient": 0.55, "bintang": 0.1, "lampu": 0.4},
	{"jam": 18.0, "atas": Color("#0d1330"), "horison": Color("#2a2f55"), "bawah": Color("#0d1220"), "dasar": Color("#1a2038"), "ambient": 0.32, "bintang": 0.8, "lampu": 1.0},
	{"jam": 24.0, "atas": Color("#0a0f24"), "horison": Color("#1a2440"), "bawah": Color("#0a0f1a"), "dasar": Color("#141c30"), "ambient": 0.30, "bintang": 1.0, "lampu": 1.0},
]

## Keyframe MATAHARI: [jam, elevasi, azimuth, warna cahaya, energi].
## RONDE 12 — AZIMUT DIPERBAIKI ke jalur fisik (Jawa ~7°LS, 16 Nov,
## deklinasi ~-19°; dihitung independen, bukan tebakan): terbit ~107°
## (timur-tenggara), pagi 108-118°, siang ~200° (sedikit lewat
## selatan), sore 252° (barat-barat daya), terbenam ~252° (barat,
## sedikit selatan). YANG SALAH dulu: terbenam 290° (meleset ~38°) dan
## jam 15.00 = 325° (barat laut — meleset ~74°; pilihan deliberate
## ronde 4 supaya matahari masuk tampilan default menghadap utara, kini
## DIKORBANKAN demi kebenaran arah — Mas 06:20 WIB: "Di versi
## sebelumnya matahari ada di sebelah kanan mihrab." Kiblat 295° −
## terbenam 252° = 43°: matahari di SEBELAH KIRI mihrab saat menghadap
## kiblat. ✓ Pagi hari matahari di timur = di BELAKANG orang yang
## menghadap kiblat, tidak terlihat lewat dinding mihrab. ✓
## Elevasi sore tetap RENDAH (8° jam 15.00, 3° jam 17.00) — golden
## hour gaya ronde 4 dipertahankan; yang diperbaiki hanya AZIMUT.
## Dampak: matahari senja TIDAK LAGI di tampilan default (menghadap
## utara) — ada di barat-barat daya, kiri-belakang pemain saat spawn.
## REVISI (Mas 17 Nov 22:51 WIB: "Surau lurus aja... Biar matahari yg
## menyesuaikan dg arah barat."): bangunan LUAR diluruskan (Surau 0°),
## matahari TIDAK diubah angkanya — jalurnya SUDAH di barat: terbenam
## 252° (barat-barat daya; barat tepat = 270°). 252° adalah posisi
## BENAR matahari terbenam untuk Jawa (~7°LS) di November (deklinasi
## ~-19°); 270° tepat hanya terjadi sekitar ekuinoks (Mar/Sep).
## Terbit 107° + terbenam 252° simetris terhadap selatan (tengah
## 179,5°) — kalau terbenam dipaksa 270° tanpa mengubah terbit, jalur
## jadi miring. Dari depan pintu Surau lurus (menghadap selatan),
## matahari senja ada di kanan-depan (barat-barat daya). Diverifikasi
## foto jam 17:00 (revisi Surau lurus, R3). Kalau Mas mau tepat 270°,
## itu satu angka di keyframe jam 15.00/17.00/18.00 — tapi kurang
## tepat secara astronomi.
const K_MATAHARI: Array = [
	{"jam": 0.0, "elev": -6.0, "azim": 252.0, "warna": Color("#ff9a5c"), "energi": 0.0},
	{"jam": 5.5, "elev": 6.0, "azim": 107.0, "warna": Color("#ffcf9a"), "energi": 0.9},
	{"jam": 8.0, "elev": 32.0, "azim": 108.0, "warna": Color("#ffe8c0"), "energi": 1.1},
	{"jam": 10.0, "elev": 55.0, "azim": 118.0, "warna": Color("#fff3d6"), "energi": 1.25},
	{"jam": 12.0, "elev": 62.0, "azim": 200.0, "warna": Color("#fff6e0"), "energi": 1.25},
	{"jam": 15.0, "elev": 8.0, "azim": 252.0, "warna": Color("#ffd9a8"), "energi": 1.3},
	{"jam": 17.0, "elev": 3.0, "azim": 252.0, "warna": Color("#ffb27a"), "energi": 0.9},
	{"jam": 18.0, "elev": -6.0, "azim": 252.0, "warna": Color("#ff9a5c"), "energi": 0.0},
	{"jam": 24.0, "elev": -6.0, "azim": 252.0, "warna": Color("#ff9a5c"), "energi": 0.0},
]

## Keyframe BULAN: [jam, elevasi, azimuth]. Terbit di timur ~18:00,
## tertinggi di selatan tengah malam, terbenam di barat ~05:30.
const K_BULAN: Array = [
	{"jam": 0.0, "elev": 50.0, "azim": 180.0},
	{"jam": 3.0, "elev": 30.0, "azim": 225.0},
	{"jam": 5.0, "elev": 8.0, "azim": 260.0},
	{"jam": 5.5, "elev": -4.0, "azim": 265.0},
	{"jam": 18.0, "elev": 10.0, "azim": 90.0},
	{"jam": 21.0, "elev": 35.0, "azim": 135.0},
	{"jam": 24.0, "elev": 50.0, "azim": 180.0},
]

const WARNA_CAHAYA_BULAN := Color("#a8bce8")
const ENERGI_CAHAYA_BULAN := 0.35

var _env: Environment
var _sky_mat: ProceduralSkyMaterial
var _cahaya: DirectionalLight3D
var _matahari: MeshInstance3D
var _matahari_halo: MeshInstance3D
var _bulan: MeshInstance3D
var _bulan_halo: MeshInstance3D
var _bintang: MultiMeshInstance3D
var _mat_matahari: StandardMaterial3D
var _mat_matahari_halo: StandardMaterial3D
var _mat_bulan: StandardMaterial3D
var _mat_bulan_halo: StandardMaterial3D
var _mat_bintang: StandardMaterial3D
var _lampu_jalan: Array = []
var _lampu_cahaya: Array = []
var _cahaya_jendela: Array = []
var _kaca_jendela: Array = []
var _jam_terakhir: float = -1.0
var _fase_terakhir: String = ""
var _sun_dir_terakhir: Vector3 = Vector3(0, 1, 0)
# --- Cuaca (Wulan, 17 Nov 2026) ---
var _kondisi: String = KONDISI_CERAH
var _awan: Array[Node3D] = []
var _awan_cepat: Array[float] = []
var _mat_awan: StandardMaterial3D
var _hujan: MultiMeshInstance3D
var _mat_hujan: StandardMaterial3D
var _tetes_pos: Array[Vector3] = []
var _tetes_cepat: Array[float] = []


## Jam saat ini (desimal). debug_jam >= 0 menimpa jam sistem.
static func jam_saat_ini() -> float:
	if debug_jam >= 0.0:
		return debug_jam
	var d := Time.get_datetime_dict_from_system()
	return float(d["hour"]) + float(d["minute"]) / 60.0


static func fase_dari_jam(jam: float) -> String:
	var j := fmod(jam, 24.0)
	if j < 0.0:
		j += 24.0
	if j < 4.0:
		return "malam"
	if j < 5.5:
		return "subuh"
	if j < 10.0:
		return "pagi"
	if j < 15.0:
		return "siang"
	if j < 18.0:
		return "sore"
	return "malam"


## Arah KE benda langit dari azimuth + elevasi (azimuth 0 = utara).
static func arah(azim_deg: float, elev_deg: float) -> Vector3:
	var az := deg_to_rad(azim_deg)
	var el := deg_to_rad(elev_deg)
	return Vector3(sin(az) * cos(el), sin(el), -cos(az) * cos(el))


## Cari keyframe sebelum/sesudah jam + faktor smoothstep [a, b, f].
## Keyframe harus diawali 0.0 dan diakhiri 24.0 (duplikat nilai 0.0).
static func _antara(kunci: Array, jam: float) -> Array:
	var j := clampf(fmod(jam, 24.0), 0.0, 23.999)
	for i in range(kunci.size() - 1):
		var j0: float = kunci[i]["jam"]
		var j1: float = kunci[i + 1]["jam"]
		if j >= j0 and j < j1:
			var f := clampf((j - j0) / maxf(0.001, j1 - j0), 0.0, 1.0)
			f = f * f * (3.0 - 2.0 * f)
			return [kunci[i], kunci[i + 1], f]
	return [kunci[kunci.size() - 1], kunci[kunci.size() - 1], 0.0]


static func _campur_warna(a: Color, b: Color, f: float) -> Color:
	return a.lerp(b, f)


static func _campur_float(a: float, b: float, f: float) -> float:
	return lerpf(a, b, f)


## Bangun pengendali langit (node + semua benda langit). Dipanggil
## PesantrenBuilder._environment; node ditambahkan ke root pesantren.
static func build() -> LangitDinamis:
	var node := LangitDinamis.new()
	node.name = "LangitDinamis"
	node._bangun()
	return node


func get_matahari() -> MeshInstance3D:
	return _matahari


func get_bulan() -> MeshInstance3D:
	return _bulan


func get_sun_dir() -> Vector3:
	return _sun_dir_terakhir


func get_fase() -> String:
	return _fase_terakhir


func get_jam() -> float:
	return _jam_terakhir


## --- Cuaca ---
## Set kondisi dari Cuaca (atau tes). Nilai tak dikenal -> "cerah".
func set_kondisi(k: String) -> void:
	_kondisi = k if k in SEMUA_KONDISI else KONDISI_CERAH


func get_kondisi() -> String:
	return _kondisi_efektif()


## debug_kondisi (tes/foto) mengalahkan kondisi dari Cuaca.
func _kondisi_efektif() -> String:
	if debug_kondisi != "":
		return debug_kondisi if debug_kondisi in SEMUA_KONDISI else KONDISI_CERAH
	return _kondisi


## Faktor penggelap langit per kondisi (1.0 = tidak gelap).
static func faktor_gelap(kondisi: String) -> float:
	match kondisi:
		KONDISI_BERAWAN:
			return 0.92
		KONDISI_MENDUNG:
			return 0.72
		KONDISI_HUJAN:
			return 0.55
	return 1.0


## Berapa awan terlihat per kondisi (dari 12 yang dibangun).
static func jumlah_awan(kondisi: String) -> int:
	match kondisi:
		KONDISI_CERAH:
			return 3
		KONDISI_BERAWAN:
			return 7
	return JUMLAH_AWAN


## Warna awan per kondisi (putih -> abu-abu gelap saat hujan).
static func warna_awan(kondisi: String) -> Color:
	match kondisi:
		KONDISI_BERAWAN:
			return Color("#e8ecf0")
		KONDISI_MENDUNG:
			return Color("#b8bec8")
		KONDISI_HUJAN:
			return Color("#878fa0")
	return Color("#ffffff")


func _bangun() -> void:
	# --- Environment + langit prosedural ---
	var env_node := WorldEnvironment.new()
	env_node.name = "Lingkungan"
	_env = Environment.new()
	_env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	_sky_mat = ProceduralSkyMaterial.new()
	_sky_mat.sun_angle_max = 30.0
	sky.sky_material = _sky_mat
	_env.sky = sky
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	_env.ambient_light_energy = 0.75
	_env.tonemap_mode = Environment.TONE_MAPPER_AGX
	_env.tonemap_exposure = 1.0
	# Kabut MATI (pelajaran ronde 4 — kabut menutupi langit di web).
	_env.fog_enabled = false
	env_node.environment = _env
	add_child(env_node)
	# --- Cahaya utama (matahari di siang/sore, bulan di malam) ---
	_cahaya = DirectionalLight3D.new()
	_cahaya.name = "CahayaMatahariBulan"
	_cahaya.shadow_enabled = true
	add_child(_cahaya)
	# --- Matahari 3D (bola + halo, unshaded supaya terang konstan) ---
	_mat_matahari = _bahan_benda_langit(Color("#ffdf6b"), 1.0)
	_matahari = MeshInstance3D.new()
	_matahari.name = "Matahari"
	var bola_m := SphereMesh.new()
	bola_m.radius = 18.0
	bola_m.height = 36.0
	_matahari.mesh = bola_m
	_matahari.material_override = _mat_matahari
	_matahari.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_matahari)
	_mat_matahari_halo = _bahan_benda_langit(Color(1.0, 0.75, 0.28, 0.30), 1.0)
	_matahari_halo = MeshInstance3D.new()
	_matahari_halo.name = "MatahariHalo"
	var halo_m := SphereMesh.new()
	halo_m.radius = 27.0
	halo_m.height = 54.0
	_matahari_halo.mesh = halo_m
	_matahari_halo.material_override = _mat_matahari_halo
	_matahari_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_matahari_halo)
	# --- Bulan 3D (bola pucat + halo tipis) ---
	_mat_bulan = _bahan_benda_langit(Color("#e8ecf5"), 1.0)
	_bulan = MeshInstance3D.new()
	_bulan.name = "Bulan"
	var bola_b := SphereMesh.new()
	bola_b.radius = 12.0
	bola_b.height = 24.0
	_bulan.mesh = bola_b
	_bulan.material_override = _mat_bulan
	_bulan.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_bulan)
	_mat_bulan_halo = _bahan_benda_langit(Color(0.85, 0.9, 1.0, 0.20), 1.0)
	_bulan_halo = MeshInstance3D.new()
	_bulan_halo.name = "BulanHalo"
	var halo_b := SphereMesh.new()
	halo_b.radius = 18.0
	halo_b.height = 36.0
	_bulan_halo.mesh = halo_b
	_bulan_halo.material_override = _mat_bulan_halo
	_bulan_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_bulan_halo)
	# --- Bintang (MultiMesh 140 titik di kubah langit) ---
	_mat_bintang = _bahan_benda_langit(Color(1, 1, 1, 1), 1.0)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var bintang_mesh := SphereMesh.new()
	bintang_mesh.radius = 0.7
	bintang_mesh.height = 1.4
	mm.mesh = bintang_mesh
	mm.instance_count = JUMLAH_BINTANG
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for i in range(JUMLAH_BINTANG):
		var az := rng.randf_range(0.0, TAU)
		var el := deg_to_rad(rng.randf_range(5.0, 85.0))
		var arah_b := Vector3(sin(az) * cos(el), sin(el), -cos(az) * cos(el))
		mm.set_instance_transform(i, Transform3D(Basis(), arah_b * JARAK_BINTANG))
	_bintang = MultiMeshInstance3D.new()
	_bintang.name = "Bintang"
	_bintang.multimesh = mm
	_bintang.material_override = _mat_bintang
	_bintang.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_bintang)
	# --- Awan (FITUR CUACA): 12 gumpalan bola pipih, melayang pelan.
	# Satu material bersama (unshaded putih, alpha diatur per kondisi);
	# tiap awan 2 bola (besar + kecil di samping) supaya siluetnya
	# tidak sekadar elips. Posisi acak deterministik (seed tetap).
	_mat_awan = _bahan_benda_langit(Color("#ffffff"), 0.6)
	var rng_awan := RandomNumberGenerator.new()
	rng_awan.seed = 777
	for i in range(JUMLAH_AWAN):
		var awan := Node3D.new()
		awan.name = "Awan%02d" % i
		var az := rng_awan.randf_range(0.0, TAU)
		var rad := rng_awan.randf_range(30.0, 150.0)
		awan.position = Vector3(sin(az) * rad, rng_awan.randf_range(TINGGI_AWAN_MIN, TINGGI_AWAN_MAX), -cos(az) * rad)
		var besar := MeshInstance3D.new()
		var bola_besar := SphereMesh.new()
		bola_besar.radius = 1.0
		bola_besar.height = 2.0
		besar.mesh = bola_besar
		besar.scale = Vector3(rng_awan.randf_range(12.0, 19.0), rng_awan.randf_range(3.5, 5.5), rng_awan.randf_range(7.0, 11.0))
		besar.material_override = _mat_awan
		besar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		awan.add_child(besar)
		var kecil := MeshInstance3D.new()
		var bola_kecil := SphereMesh.new()
		bola_kecil.radius = 1.0
		bola_kecil.height = 2.0
		kecil.mesh = bola_kecil
		kecil.position = Vector3(rng_awan.randf_range(6.0, 10.0), rng_awan.randf_range(0.5, 1.5), rng_awan.randf_range(-2.0, 2.0))
		kecil.scale = Vector3(rng_awan.randf_range(7.0, 11.0), rng_awan.randf_range(2.5, 4.0), rng_awan.randf_range(5.0, 7.5))
		kecil.material_override = _mat_awan
		kecil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		awan.add_child(kecil)
		add_child(awan)
		_awan.append(awan)
		_awan_cepat.append(rng_awan.randf_range(0.6, 1.6))
	# --- Hujan (FITUR CUACA): 160 tetes tipis (MultiMesh, 1 draw call),
	# jatuh di kotak 40 x 24 x 40 m mengikuti kamera. Tanpa sistem
	# partikel baru — transform dihitung manual tiap frame (murah).
	_mat_hujan = _bahan_benda_langit(Color(0.75, 0.85, 1.0), 0.45)
	var mm_hujan := MultiMesh.new()
	mm_hujan.transform_format = MultiMesh.TRANSFORM_3D
	var tetes_mesh := BoxMesh.new()
	tetes_mesh.size = Vector3(0.04, 1.4, 0.04)
	mm_hujan.mesh = tetes_mesh
	mm_hujan.instance_count = JUMLAH_TETES
	var rng_hujan := RandomNumberGenerator.new()
	rng_hujan.seed = 4242
	for i in range(JUMLAH_TETES):
		_tetes_pos.append(Vector3(rng_hujan.randf_range(-LEBAR_HUJAN / 2.0, LEBAR_HUJAN / 2.0), rng_hujan.randf_range(0.0, TINGGI_HUJAN), rng_hujan.randf_range(-LEBAR_HUJAN / 2.0, LEBAR_HUJAN / 2.0)))
		_tetes_cepat.append(rng_hujan.randf_range(CEPAT_JATUH_MIN, CEPAT_JATUH_MAX))
		mm_hujan.set_instance_transform(i, Transform3D(Basis(), _tetes_pos[i]))
	_hujan = MultiMeshInstance3D.new()
	_hujan.name = "Hujan"
	_hujan.multimesh = mm_hujan
	_hujan.material_override = _mat_hujan
	_hujan.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_hujan.visible = false
	add_child(_hujan)
	# Nilai awal: siang (12:00) supaya frame pertama sudah waras;
	# _process langsung mengoreksi ke jam sebenarnya.
	_terapkan(12.0)


static func _bahan_benda_langit(warna: Color, alpha: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var c := warna
	c.a = alpha
	m.albedo_color = c
	return m


func _process(delta: float) -> void:
	_terapkan(jam_saat_ini())
	# --- Awan melayang pelan ke +X, bungkus di ±200 m ---
	for i in range(_awan.size()):
		var awan := _awan[i]
		if not awan.visible:
			continue
		awan.position.x += _awan_cepat[i] * delta
		if awan.position.x > 200.0:
			awan.position.x = -200.0
	# --- Hujan mengikuti kamera, tetes jatuh lalu naik lagi ke atas ---
	if _hujan.visible:
		var cam := get_viewport().get_camera_3d()
		if cam != null:
			var pos_cam := cam.global_position
			_hujan.global_position = Vector3(pos_cam.x, 0.0, pos_cam.z)
			var mm := _hujan.multimesh
			for i in range(JUMLAH_TETES):
				var p := _tetes_pos[i]
				p.y -= _tetes_cepat[i] * delta
				if p.y < 0.0:
					p.y = TINGGI_HUJAN
				_tetes_pos[i] = p
				mm.set_instance_transform(i, Transform3D(Basis(), p))


## Hitung + terapkan semua nilai langit untuk satu jam.
func _terapkan(jam: float) -> void:
	_jam_terakhir = jam
	_fase_terakhir = fase_dari_jam(jam)
	# --- Warna langit + ambient + bintang + lampu ---
	var lk := _antara(K_LANGIT, jam)
	var la: Dictionary = lk[0]
	var lb: Dictionary = lk[1]
	var fl: float = lk[2]
	_sky_mat.sky_top_color = _campur_warna(la["atas"], lb["atas"], fl)
	_sky_mat.sky_horizon_color = _campur_warna(la["horison"], lb["horison"], fl)
	_sky_mat.ground_bottom_color = _campur_warna(la["bawah"], lb["bawah"], fl)
	_sky_mat.ground_horizon_color = _campur_warna(la["dasar"], lb["dasar"], fl)
	_env.ambient_light_energy = _campur_float(la["ambient"], lb["ambient"], fl)
	var malam: float = _campur_float(la["bintang"], lb["bintang"], fl)
	var lampu_f: float = _campur_float(la["lampu"], lb["lampu"], fl)
	# --- Cuaca: gelapkan langit + cahaya sesuai kondisi nyata ---
	var kondisi := _kondisi_efektif()
	var gelap := faktor_gelap(kondisi)
	if gelap < 1.0:
		_sky_mat.sky_top_color *= gelap
		_sky_mat.sky_horizon_color *= gelap
		_sky_mat.ground_bottom_color *= gelap
		_sky_mat.ground_horizon_color *= gelap
		_env.ambient_light_energy *= gelap
	# Awan: jumlah + warna + alpha per kondisi; hujan: tetes menyala.
	var n_awan := jumlah_awan(kondisi)
	for i in range(_awan.size()):
		_awan[i].visible = i < n_awan
	var warna_a := warna_awan(kondisi)
	warna_a.a = 0.55 if kondisi == KONDISI_CERAH else (0.75 if kondisi == KONDISI_BERAWAN else 0.9)
	_mat_awan.albedo_color = warna_a
	_hujan.visible = kondisi == KONDISI_HUJAN
	# --- Matahari ---
	var mk := _antara(K_MATAHARI, jam)
	var ma: Dictionary = mk[0]
	var mb: Dictionary = mk[1]
	var fm: float = mk[2]
	var elev_m: float = _campur_float(ma["elev"], mb["elev"], fm)
	var azim_m: float = _campur_float(ma["azim"], mb["azim"], fm)
	var warna_m: Color = _campur_warna(ma["warna"], mb["warna"], fm)
	var energi_m: float = _campur_float(ma["energi"], mb["energi"], fm)
	var dir_m := arah(azim_m, elev_m)
	_sun_dir_terakhir = dir_m
	# --- Bulan ---
	var bk := _antara(K_BULAN, jam)
	var ba: Dictionary = bk[0]
	var bb: Dictionary = bk[1]
	var fb: float = bk[2]
	var dir_b := arah(_campur_float(ba["azim"], bb["azim"], fb), _campur_float(ba["elev"], bb["elev"], fb))
	# --- Cahaya utama: matahari di siang hari, bulan di malam hari ---
	var dir_cahaya := dir_m.lerp(dir_b, malam).normalized()
	_cahaya.basis = Basis.looking_at(-dir_cahaya, Vector3.UP)
	_cahaya.light_color = warna_m.lerp(WARNA_CAHAYA_BULAN, malam)
	# Cuaca: matahari redup saat mendung/hujan (bulan tidak ikut redup).
	_cahaya.light_energy = lerpf(energi_m * gelap, ENERGI_CAHAYA_BULAN, malam)
	# --- Bola matahari (sembunyi di bawah cakrawala) ---
	var alpha_m := clampf(elev_m / 6.0, 0.0, 1.0) * gelap
	_matahari.visible = alpha_m > 0.02
	_matahari_halo.visible = alpha_m > 0.02
	_matahari.position = dir_m * JARAK_BENDA_LANGIT
	_matahari_halo.position = dir_m * JARAK_BENDA_LANGIT
	_mat_matahari.albedo_color.a = alpha_m
	_mat_matahari_halo.albedo_color.a = 0.30 * alpha_m
	# --- Bola bulan (hanya di malam hari) ---
	_bulan.visible = malam > 0.02
	_bulan_halo.visible = malam > 0.02
	_bulan.position = dir_b * JARAK_BENDA_LANGIT
	_bulan_halo.position = dir_b * JARAK_BENDA_LANGIT
	_mat_bulan.albedo_color.a = malam
	_mat_bulan_halo.albedo_color.a = 0.20 * malam
	# --- Bintang ---
	_bintang.visible = malam > 0.02
	_mat_bintang.albedo_color.a = malam
	# --- Lampu (jalan + surau + interior): kumpulkan sekali, lalu atur ---
	if _lampu_jalan.is_empty() and is_inside_tree():
		_lampu_jalan = get_tree().get_nodes_in_group("LampuJalan")
	if _lampu_cahaya.is_empty() and is_inside_tree():
		_lampu_cahaya = get_tree().get_nodes_in_group("LampuCahaya")
	# RONDE 10 — cahaya jendela cangkruk: KEBALIKAN lampu (terang di
	# siang hari, redup di malam hari). Kaca ikut: terang di siang
	# hari (membaca sebagai cahaya siang), redup di malam hari.
	if _cahaya_jendela.is_empty() and is_inside_tree():
		_cahaya_jendela = get_tree().get_nodes_in_group("CahayaJendela")
	if _kaca_jendela.is_empty() and is_inside_tree():
		_kaca_jendela = get_tree().get_nodes_in_group("KacaJendela")
	for bohlam in _lampu_jalan:
		var mat := (bohlam as MeshInstance3D).material_override as StandardMaterial3D
		if mat != null:
			mat.emission_energy_multiplier = lerpf(1.5, 4.0, lampu_f)
	for cahaya in _lampu_cahaya:
		var omni := cahaya as OmniLight3D
		if omni != null:
			var dasar: float = float(omni.get_meta("energi_siang", 0.7))
			# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): lampu MATI di
			# siang hari — grup ini mencakup 72 lampu kamar asrama
			# (12 kamar x 3 lantai x 2 asrama) + cangkruk/gedung/
			# kelas/surau/musholla. Dulu siang tetap 1,0x dasar.
			# (CahayaJendela di bawah sengaja KEBALIKAN — biarkan.)
			omni.light_energy = dasar * lerpf(0.0, 2.0, lampu_f)
	for jendela_cahaya in _cahaya_jendela:
		var omni_j := jendela_cahaya as OmniLight3D
		if omni_j != null:
			var dasar_j: float = float(omni_j.get_meta("energi_siang", 0.55))
			omni_j.light_energy = dasar_j * lerpf(1.0, 0.05, lampu_f)
	for kaca in _kaca_jendela:
		var mat_kaca := (kaca as MeshInstance3D).material_override as StandardMaterial3D
		if mat_kaca != null:
			mat_kaca.emission_energy_multiplier = lerpf(0.8, 0.05, lampu_f)
