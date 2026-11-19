class_name PembagianKasur
extends RefCounted
## Pembagian kasur — 1 santri = 1 kasur (Wulan, 18 Nov 2026, tugas Mas 00:06 WIB).
##
## ATURAN (brief Mas):
##   1 santri baru = 1 kasur. Kasur susun (tingkat). Santri yang tidak
##   kebagian kasur tidur di Surau dulu (sementara). Pemisahan gender
##   WAJIB: putra tidak pernah dapat kasur putri, begitu pula sebaliknya.
##   1 kasur = 1 santri — tidak boleh dobel. Tidak ada santri tanpa
##   tempat: selalu ada fallback Surau (putra) / Musholla (putri).
##
## URUTAN PEMBAGIAN (per gender, masing-masing punya gedung sendiri):
##   PUTRA: Cangkruk (10) -> Asrama (96) -> Surau (overflow).
##   PUTRI: Asrama (96) -> Musholla (overflow) — KOREKSI Mas 00:25 WIB
##     18 Nov ("Jangan cangkruk.. asrama aja.."): kasur susun HANYA
##     di Asrama Putri, BUKAN Cangkruk Putri. Cangkruk Putri (128,-12)
##     bukan tempat tidur — tidak ada tugas kasur ke sana.
##   Cangkruk: 5 kasur susun x 2 tingkat = 10 tempat.
##   Asrama: 3 lantai x 4 kamar/lantai x 4 kasur susun (8 kasur/kamar)
##     = 96 kasur/gedung. Kamar "Kamar 001".."Kamar 012" (lantai 1 =
##     001-004, lantai 2 = 005-008, lantai 3 = 009-012).
##
## FISIK vs LOGIS — CATAT APA ADANYA (cek 18 Nov ~00:15 WIB):
##   - Cangkruk PUTRA: interior (-60,0,-300) punya 5 kasur TUNGGAL
##     (InteriorCangkruk.BED_POS_LIST). Jadi CP-01..05 punya kasur
##     fisik; CP-06..10 (tingkat atas) LOGIS — kasur susun fisiknya
##     belum dibangun (follow-up Gilang/Bima).
##   - Cangkruk PUTRI (128,-12): cangkang luar SAJA, tanpa interior
##     dan tanpa kasur — dan per KOREKSI Mas 00:25 WIB kasur susun
##     TIDAK ditaruh di sana. Putri TIDAK ditugaskan ke Cangkruk.
##   - Asrama PUTRA: interior dibangun 18 Nov 2026 (Nadia: geometri
##     reuse modul Putri; Lestari: wiring main.gd) — 96 kasur fisik
##     A-PUTRA-001..096 di map interior terpisah, lokasi (-24,10)
##     (ACC Mas 09:37 WIB). Tidur di Asrama diselesaikan main.gd via
##     InteriorAsramaPutra.posisi_tidur_list() (preseden Asrama
##     Putri) — ledger `posisi` tetap titik Surau fallback +
##     `fisik` false (preseden Putri: A-PUTRI juga fisik=false meski
##     interior sudah ada; lihat test_wiring_putri "posisi tidur
##     putri 1 = titik Musholla"). Batas fisik putra: 5 kasur
##     Cangkruk + 96 Asrama = 101 tempat tidur fisik (+ 14 titik
##     Surau untuk Cangkruk atas 06-10 + overflow 107+).
##   - Asrama PUTRI (152,0): cangkang luar SAJA, tanpa interior/kasur.
##     SEMUA logis.
##   - Karena itu "posisi_tidur" (tempat tidur FISIK malam ini):
##     kasur fisik sendiri kalau ada; kalau tidak, satu titik lantai
##     terverifikasi di Surau (putra, 14 titik) / Musholla (putri,
##     6 titik) — titik-titik itu dicek anti-tembus terhadap interior
##     ASLI di test_kasur.gd. Kalau titik terverifikasi habis,
##     posisi_tidur = null + flag tempat_fisik_belum_terverifikasi
##     (JANGAN pernah menumpuk dua santri di satu titik / kasur).
##     Batas fisik darurat: 19 putra (5 kasur + 14 titik Surau),
##     6 putri (0 kasur + 6 titik Musholla). Asrama Putra dibangun
##     18 Nov 2026 (ACC Mas 09:37 WIB) — batas fisik putra kini
##     101 (5 Cangkruk + 96 Asrama) + 14 titik Surau.
##
## PENYIMPANAN: ledger lokal user://kasur.json — logika di GAME, bukan
## field server (brief: jangan ubah server/API). Satu baris per santri:
## id_santri -> tugas kasur. Idempotent: ID yang sama selalu kembali
## ke kasur yang sama. TIDAK PERNAH memakai PV-0001 "Tes" untuk tes.
## Multiplayer nanti (tim Dimas) butuh pembagian sisi server; ledger
## lokal ini jembatan sementara, bukan sumber kebenaran akhir.

const LEDGER_PATH := "user://kasur.json"
const LEDGER_VERSI := 1

## Kapasitas logis per gender.
const CANGKRUK_KAPASITAS := 10
const CANGKRUK_SUSUN := 5
const ASRAMA_LANTAI := 3
const ASRAMA_KAMAR_PER_LANTAI := 4
const ASRAMA_SUSUN_PER_KAMAR := 4
const ASRAMA_KASUR_PER_KAMAR := 8
const ASRAMA_KAPASITAS := 96
## Kasur Cangkruk putra yang BENAR-BENAR ada fisiknya (5 tunggal).
const CANGKRUK_FISIK_PUTRA := 5

## Titik tidur fallback di Surau — koordinat LOKAL pra-rotasi (ruangan
## 18x14, x -9..9, z -308..-294, pintu (0,-294)); dikonversi ke dunia
## via InteriorSurau.ke_dunia() (ruangan miring -25° mengelilingi
## pintu). Badan tidur 1,1 x 2,1 m, kepala ke utara (dunia -Z).
## Baris selatan z=-296 (6 titik, |x|>=2,5 supaya koridor pintu +
## spawn (0,-295.5) tetap kosong) + baris utara z=-306,5 (6 titik)
## + tengah timur/barat z=-300,5 (2 titik — lolos SAT 00:45 WIB).
## Total 14 titik terverifikasi.
const SURAU_SPOT_LOKAL: Array[Vector3] = [
	Vector3(-7.0, 0, -296.0), Vector3(-4.5, 0, -296.0),
	Vector3(-2.5, 0, -296.0), Vector3(2.5, 0, -296.0),
	Vector3(4.5, 0, -296.0), Vector3(7.0, 0, -296.0),
	Vector3(-7.0, 0, -306.5), Vector3(-4.5, 0, -306.5),
	Vector3(-2.5, 0, -306.5), Vector3(2.5, 0, -306.5),
	Vector3(4.5, 0, -306.5), Vector3(7.0, 0, -306.5),
	Vector3(7.0, 0, -300.5), Vector3(-7.0, 0, -300.5),
]
## Titik tidur fallback di Musholla — koordinat LOKAL pra-rotasi
## (ruangan 14x10, x 53..67, z -306..-296, pintu (60,-296));
## dikonversi via InteriorMusholla.ke_dunia() (-25° keliling pintu).
## Baris selatan z=-298,0 (3 titik — pintu + spawn (60,-297,5) +
## meja sampar (64,5,-297,5) dihindari) + baris utara z=-304,0
## (3 titik — dinding utara + sajadah Ustadzah + rak dihindari).
## CATAT (tes 00:45 WIB): baris LAMA (selatan -297,3 / utara -304,7)
## gagal SAT — badan tidur sejajar sumbu DUNIA (kepala utara),
## sedangkan ruangan miring -25°: badan memproyeksi 1,32 m ke arah
## normal dinding, bukan 1,15 m. Digelar 0,7 m menjauhi dinding.
## CATAT (Dewi, 00:31 WIB): rak kitab 2 BARU di (57,5,-305,7) —
## titik utara x=57,5 DIHAPUS dari daftar ini (rak berdiri di sana).
## Total 6 titik (bukan 7).
const MUSHOLLA_SPOT_LOKAL: Array[Vector3] = [
	Vector3(55.0, 0, -298.0), Vector3(57.0, 0, -298.0),
	Vector3(62.5, 0, -298.0),
	Vector3(55.0, 0, -304.0), Vector3(60.0, 0, -304.0),
	Vector3(62.5, 0, -304.0),
]

## Setengah badan tidur (meter) — dipakai test anti-tembus.
const TIDUR_SETENGAH_X := 0.55
const TIDUR_SETENGAH_Z := 1.05

var jalur: String = LEDGER_PATH
var ledger: Dictionary = {"versi": LEDGER_VERSI, "tugas": {}}


func _init(jalur_ledger: String = LEDGER_PATH) -> void:
	jalur = jalur_ledger


## --- gender / nama -------------------------------------------------

static func normalisasi_gender(jk: String) -> String:
	return "putri" if jk.strip_edges().to_lower() == "putri" else "putra"


static func nama_kamar(nomor_kamar_1based: int) -> String:
	return "Kamar %03d" % clampi(nomor_kamar_1based, 1, 12)


## --- posisi tidur fisik --------------------------------------------

## Titik tidur Surau (dunia) — dipakai tidur sementara putra.
static func tempat_tidur_surau() -> Array[Vector3]:
	var hasil: Array[Vector3] = []
	for lokal in SURAU_SPOT_LOKAL:
		hasil.append(InteriorSurau.ke_dunia(lokal))
	return hasil


## Titik tidur Musholla (dunia) — dipakai tidur sementara putri.
static func tempat_tidur_musholla() -> Array[Vector3]:
	var hasil: Array[Vector3] = []
	for lokal in MUSHOLLA_SPOT_LOKAL:
		hasil.append(InteriorMusholla.ke_dunia(lokal))
	return hasil


static func tempat_tidur_sementara(gender: String) -> Array[Vector3]:
	return tempat_tidur_musholla() if normalisasi_gender(gender) == "putri" else tempat_tidur_surau()


## --- logika murni (tanpa I/O — bisa dites tanpa file) ---------------

## Tugas kasur untuk satu santri. Murni: hanya membaca/menulis dict
## ledger yang diberikan. Idempotent — ID yang sudah ada kembali ke
## tugas yang sama (tidak pernah pindah kasur / dobel).
static func buat_tugas(id_santri: String, gender: String, ledger_dict: Dictionary) -> Dictionary:
	var id := id_santri.strip_edges().to_upper()
	var jk := normalisasi_gender(gender)
	var tugas_map: Dictionary = ledger_dict.get("tugas", {})
	if tugas_map.has(id):
		var lama: Dictionary = tugas_map[id]
		return lama.duplicate(true)
	var urutan := _hitung_terisi(jk, tugas_map) + 1
	var tugas := _tugas_baru(id, jk, urutan, tugas_map)
	tugas_map[id] = tugas
	ledger_dict["tugas"] = tugas_map
	return tugas.duplicate(true)


## Tugas kasur yang sudah dicatat untuk ID ini ({} bila belum ada).
static func kasur_milik(id_santri: String, ledger_dict: Dictionary) -> Dictionary:
	var tugas_map: Dictionary = ledger_dict.get("tugas", {})
	if tugas_map.has(id_santri.strip_edges().to_upper()):
		return (tugas_map[id_santri.strip_edges().to_upper()] as Dictionary).duplicate(true)
	return {}


## Jumlah santri satu gender yang sudah punya kasur.
static func jumlah_terisi(gender: String, ledger_dict: Dictionary) -> int:
	return _hitung_terisi(normalisasi_gender(gender), ledger_dict.get("tugas", {}))


## Posisi tidur fisik (dunia) dari sebuah tugas — Vector3.INF bila
## belum ada titik terverifikasi (jangan tidur di titik orang lain).
static func posisi_tidur(tugas: Dictionary) -> Vector3:
	if not tugas.has("posisi") or tugas["posisi"] == null:
		return Vector3.INF
	var p: Array = tugas["posisi"]
	return Vector3(float(p[0]), float(p[1]), float(p[2]))


static func ada_posisi_tidur(tugas: Dictionary) -> bool:
	return posisi_tidur(tugas) != Vector3.INF


static func _hitung_terisi(jk: String, tugas_map: Dictionary) -> int:
	var n := 0
	for id in tugas_map.keys():
		var t: Dictionary = tugas_map[id]
		if String(t.get("gender", "putra")) == jk:
			n += 1
	return n


## Susun tugas baru untuk santri ke-`urutan` (1-based) satu gender.
## PUTRA: Cangkruk 1-10 -> Asrama 11-106 -> Surau 107+.
## PUTRI: Asrama 1-96 -> Musholla 97+ (KOREKSI Mas 00:25 WIB — tanpa
## Cangkruk; kasur susun hanya Asrama Putri).
static func _tugas_baru(id: String, jk: String, urutan: int, tugas_map: Dictionary) -> Dictionary:
	var putri := jk == "putri"
	var gedung := ""
	var kasur_id := ""
	var kamar := ""
	var susun := 0
	var tingkat := ""
	var fisik := false
	var posisi: Variant = null
	var spot_idx := -1
	var ambang_cangkruk := 0 if putri else CANGKRUK_KAPASITAS
	if urutan <= ambang_cangkruk:
		gedung = "Cangkruk Putra"
		susun = (urutan - 1) / 2 + 1
		tingkat = "bawah" if (urutan - 1) % 2 == 0 else "atas"
		kasur_id = "C-PUTRA-%02d" % urutan
		# Fisik HANYA kasur tunggal 1-5 Cangkruk putra. Tingkat atas
		# (06-10) LOGIS — kasur susun fisiknya belum dibangun
		# (follow-up Gilang/Bima).
		fisik = urutan <= CANGKRUK_FISIK_PUTRA
		if fisik:
			var bed: Vector3 = InteriorCangkruk.BED_POS_LIST[urutan - 1]
			posisi = [bed.x, bed.y, bed.z]
	elif urutan <= ambang_cangkruk + ASRAMA_KAPASITAS:
		var idx := urutan - ambang_cangkruk # 1..96
		var nomor_kamar := (idx - 1) / ASRAMA_KASUR_PER_KAMAR + 1
		gedung = "Asrama Putri" if putri else "Asrama Putra"
		kamar = nama_kamar(nomor_kamar)
		susun = ((idx - 1) % ASRAMA_KASUR_PER_KAMAR) / 2 + 1
		tingkat = "bawah" if (idx - 1) % 2 == 0 else "atas"
		kasur_id = ("A-PUTRI-%03d" % idx) if putri else ("A-PUTRA-%03d" % idx)
		# Tidur di Asrama diselesaikan main.gd via posisi_tidur_list()
		# interior (preseden Asrama Putri) — ledger `fisik` tetap
		# false + `posisi` titik Surau/Musholla fallback (lihat
		# header FISIK vs LOGIS). Semua tugas Asrama logis di sini.
		fisik = false
	else:
		gedung = "Musholla" if putri else "Surau"
		var idx := urutan - ambang_cangkruk - ASRAMA_KAPASITAS # 1..
		kasur_id = ("S-PUTRI-%02d" % idx) if putri else ("S-PUTRA-%02d" % idx)
		fisik = false
	# Tanpa kasur fisik -> satu titik lantai terverifikasi (Surau /
	# Musholla), diambil berurutan per gender. Habis -> posisi null +
	# flag (jangan dobel titik orang lain).
	if not fisik:
		spot_idx = _spot_bebas(jk, tugas_map)
		if spot_idx >= 0:
			var spot: Vector3 = tempat_tidur_sementara(jk)[spot_idx]
			posisi = [spot.x, spot.y, spot.z]
	return {
		"id_santri": id,
		"gender": jk,
		"kasur_id": kasur_id,
		"gedung": gedung,
		"kamar": kamar,
		"susun": susun,
		"tingkat": tingkat,
		"fisik": fisik,
		"posisi": posisi,
		"spot_idx": spot_idx,
		"tempat_fisik_belum_terverifikasi": posisi == null,
		"urutan_gender": urutan,
	}


## Indeks titik sementara pertama yang belum dipakai santri se-gender
## (-1 bila semua titik terverifikasi sudah terisi).
static func _spot_bebas(jk: String, tugas_map: Dictionary) -> int:
	var terpakai := {}
	for id in tugas_map.keys():
		var t: Dictionary = tugas_map[id]
		if String(t.get("gender", "putra")) != jk:
			continue
		var s := int(t.get("spot_idx", -1))
		if s >= 0:
			terpakai[s] = true
	var total := tempat_tidur_sementara(jk).size()
	for i in range(total):
		if not terpakai.has(i):
			return i
	return -1


## --- ledger file (lokal, bukan server) ------------------------------

func muat() -> void:
	ledger = {"versi": LEDGER_VERSI, "tugas": {}}
	if not FileAccess.file_exists(jalur):
		return
	var f := FileAccess.open(jalur, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary and (parsed as Dictionary).has("tugas"):
		ledger = parsed


func simpan() -> void:
	var f := FileAccess.open(jalur, FileAccess.WRITE)
	if f == null:
		push_warning("PembagianKasur: gagal menulis " + jalur)
		return
	f.store_string(JSON.stringify(ledger))
	f.close()


## Daftarkan santri (muat ledger dulu bila kosong) + simpan.
## Idempotent — ID yang sama kembali ke kasur yang sama TANPA tulis
## ulang file (login ulang tidak mengotak-atik ledger).
func daftarkan(id_santri: String, gender: String) -> Dictionary:
	if (ledger.get("tugas", {}) as Dictionary).is_empty() and FileAccess.file_exists(jalur):
		muat()
	var sudah_ada := (ledger.get("tugas", {}) as Dictionary).has(id_santri.strip_edges().to_upper())
	var tugas := PembagianKasur.buat_tugas(id_santri, gender, ledger)
	if not sudah_ada:
		simpan()
	return tugas


func ambil(id_santri: String) -> Dictionary:
	if (ledger.get("tugas", {}) as Dictionary).is_empty() and FileAccess.file_exists(jalur):
		muat()
	return PembagianKasur.kasur_milik(id_santri, ledger)


## Jalan pintas sekali pakai (dipakai hook main.gd): muat, daftar,
## simpan, kembalikan tugas.
static func daftarkan_baru(id_santri: String, gender: String) -> Dictionary:
	var inst := PembagianKasur.new()
	inst.muat()
	return inst.daftarkan(id_santri, gender)


## Satu instance bersama (dipakai main.gd supaya ledger tidak
## dibaca dari disk tiap frame).
static var _bersama: PembagianKasur = null


static func bersama() -> PembagianKasur:
	if _bersama == null:
		_bersama = PembagianKasur.new()
		_bersama.muat()
	return _bersama
