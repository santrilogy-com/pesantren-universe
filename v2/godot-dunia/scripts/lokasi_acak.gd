class_name LokasiAcak
## Mekanik lokasi acak Ust. Sanusi — A8 Fase A (Lukman, 18 Nov 2026).
##
## Acuan: DRAF-ALUR-MISI.md §1A langkah 4 — "Ust. Sanusi (tempatnya
## random) ... santri harus benar-benar mencari keliling pesantren,
## bukan berjalan ke titik tetap. Tidak ada marker pasti di peta."
##
## FUNGSI INI TIDAK MENGEMBALIKAN MARKER PETA — hanya posisi
## (Vector3) + id lokasi. Penanda di peta sengaja TIDAK dibuat
## (§1A: pencariannya sungguhan, beda dari pola baku §2.1).
##
## DIKUNCI — §9 butir 18 (Mas, 21:24 WIB, draf v5.4):
##   - REFRESH_PER_MISI = true: lokasi diacak tiap misi "cari Ust.
##     Sanusi" dimulai. Tanpa marker di peta, tanpa petunjuk samar.
##   - Daftar kandidat di bawah = daftar final yang sudah
##     diimplementasi (6 nama dari §1A). Bila Mas mengubah aturan
##     nanti, ubah konstanta di sini saja — pemanggil tidak berubah.
##
## KOORDINAT: semuanya disalin dari KONSEP-TATA-LETAK.md (masterplan
## ACC Mas) — TIDAK ADA koordinat karangan. Kandidat HANYA area
## putra + kawasan bersama (Sanusi ustadz putra; varian putri ada
## di KANDIDAT_PUTRI di bawah, §9 butir 22). Kolom "status" = keadaan di game 3D
## saat ini (live / lahan berpapan / rencana) — lokasi berstatus
## rencana tetap masuk daftar karena koordinatnya ada di peta,
## tapi gelombang 2 (Raka) boleh memfilter ke live saja bila
## diputuskan begitu.
##
## Kandidat "dll" yang TIDAK dimasukkan (butir 18 sudah dikunci —
## daftar final = yang diimplementasi; di bawah ini yang sengaja
## TIDAK masuk):
##   - Cangkruk Putra (−22,−18) — koordinat ada di peta, tapi tidak
##     disebut di §1A; tanyakan ke Mas bila mau ditambah.
##   - Lokasi area putri (Musholla, Kelas Putri, dsb.) — Sanusi
##     laki-laki; jalur putri diputuskan di butir 22.

## DIKUNCI §9 butir 18 (Mas, 21:24 WIB): true = diacak tiap misi "cari
## Ust. Sanusi" dimulai. false = lokasi bertahan sampai misi
## selesai (dipakai lokasi_berikutnya() — lihat bawah).
const REFRESH_PER_MISI := true

## Daftar kandidat lokasi Sanusi (putra + kawasan bersama).
## "sumber" = baris masterplan tempat koordinat disalin.
const KANDIDAT: Array[Dictionary] = [
	{
		"id": "surau",
		"nama": "Surau",
		"pos": Vector3(0, 0, -14),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md §2 — Surau (0,−14), live di game",
	},
	{
		"id": "kelas_putra",
		"nama": "Kelas Putra",
		"pos": Vector3(-44, 0, -14),
		"status": "rencana",
		"sumber": "KONSEP-TATA-LETAK.md tabel gedung baru — Kelas Putra 5 lantai (−44,−14), GANTI plot lama; papan 'Ruang Kelas' di game masih di plot lama (16,0)",
	},
	{
		"id": "taman_surau",
		"nama": "Taman Surau",
		"pos": Vector3(0, 0, -38),
		"status": "rencana",
		"sumber": "KONSEP-TATA-LETAK.md tabel gedung baru — Taman Surau 20×16 (0,−38), GANTI plot Masjid Besar lama",
	},
	{
		"id": "perpustakaan_taman",
		"nama": "Perpustakaan & Taman",
		"pos": Vector3(0, 0, 20),
		"status": "lahan_berpapan",
		"sumber": "KONSEP-TATA-LETAK.md §2 — Perpustakaan & Taman 12×9 (0,20); di game baru lahan + papan plot (ambang 200 santri)",
	},
	{
		"id": "masjid_besar",
		"nama": "Masjid Besar",
		"pos": Vector3(64, 0, -24),
		"status": "rencana",
		"sumber": "KONSEP-TATA-LETAK.md tabel gedung baru — Masjid Besar pusat 54×44 (64,−24), DIKUNCI Mas 18:22, pembangunan nanti (ambang 100); papan plot di game masih di lokasi lama (0,−32)",
	},
	{
		"id": "kantin",
		"nama": "Kantin",
		"pos": Vector3(0, 0, 40),
		"status": "rencana",
		"sumber": "KONSEP-TATA-LETAK.md §2 — Kantin 12×8 (0,40); belum ada di game 3D sama sekali (belum ada bangunan/papan)",
	},
]

## Daftar kandidat lokasi Ustzh. Fatimah (area PUTRI saja —
## §9 butir 22, DI-ACC Mas 18:55 WIB, 18 Nov 2026).
## Semua x > 14 (di balik tembok x=14); koordinat disalin dari
## KONSEP-TATA-LETAK.md — TIDAK ADA koordinat karangan.
## "halaman_putri" = bekas plot Cangkruk (128,−12) yang kini
## halaman/taman putri (bukan Cangkruk lagi).
const KANDIDAT_PUTRI: Array[Dictionary] = [
	{
		"id": "musholla_putri",
		"nama": "Musholla Ar-Raudhah",
		"pos": Vector3(134, 0, -24),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Musholla Ar-Raudhah (134,−24), live di game",
	},
	{
		"id": "kelas_putri",
		"nama": "Kelas Putri",
		"pos": Vector3(130, 0, 0),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Kelas Putri (130,0), live di game",
	},
	{
		"id": "taman_putri",
		"nama": "Taman Putri",
		"pos": Vector3(122, 0, 32),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Taman Putri (122,32), live di game",
	},
	{
		"id": "asrama_putri",
		"nama": "Asrama Putri",
		"pos": Vector3(152, 0, 9),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Asrama Putri (152,9), live di game",
	},
	{
		"id": "kantor_ustadzah",
		"nama": "Kantor Ustadzah",
		"pos": Vector3(148, 0, -33),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Kantor Ustadzah (148,−33), live di game",
	},
	{
		"id": "halaman_putri",
		"nama": "Halaman Putri",
		"pos": Vector3(128, 0, -12),
		"status": "live",
		"sumber": "KONSEP-TATA-LETAK.md — Halaman Putri (128,−12), bekas plot Cangkruk, kini halaman/taman putri",
	},
]


## Cari kandidat berdasarkan id. {} bila id tidak dikenal.
static func cari(lokasi_id: String) -> Dictionary:
	for k in KANDIDAT:
		if String(k["id"]) == lokasi_id:
			return k
	return {}


## Apakah id ini ada di daftar kandidat?
static func id_valid(lokasi_id: String) -> bool:
	return not cari(lokasi_id).is_empty()


## Semua id kandidat (untuk tes + panel misi nanti).
static func semua_id() -> Array[String]:
	var out: Array[String] = []
	for k in KANDIDAT:
		out.append(String(k["id"]))
	return out


## Posisi kandidat berdasarkan id. Vector3.ZERO bila id tidak dikenal
## (pemanggil WAJIB cek id_valid()/cari() dulu — ZERO bukan lokasi).
static func pos_dari_id(lokasi_id: String) -> Vector3:
	var k := cari(lokasi_id)
	if k.is_empty():
		return Vector3.ZERO
	return k["pos"]


## Pilih satu lokasi acak. seed >= 0 = deterministik (untuk tes);
## seed < 0 (default) = acak dari perangkat. Mengembalikan dict
## kandidat (id/nama/pos/status/sumber) — BUKAN marker peta.
static func acak(seed: int = -1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	if seed >= 0:
		rng.seed = seed
	else:
		rng.randomize()
	return KANDIDAT[rng.randi_range(0, KANDIDAT.size() - 1)]


## Lokasi Sanusi untuk misi "cari Ust. Sanusi" berikutnya.
## DIKUNCI §9 butir 18 (lihat REFRESH_PER_MISI):
##   - REFRESH_PER_MISI = true: lokasi BARU diacak tiap misi
##     dimulai — dan dijamin BERBEDA dari lokasi saat ini (supaya
##     santri benar-benar mencari ulang, bukan jalan ke tempat
##     yang sama). Bila hanya ada 1 kandidat, lokasi itu dipakai.
##   - false: lokasi bertahan (mengembalikan lokasi saat ini bila
##     valid; bila kosong/tidak valid, acak satu).
static func lokasi_berikutnya(lokasi_id_sekarang: String, seed: int = -1) -> Dictionary:
	if not REFRESH_PER_MISI:
		var lama := cari(lokasi_id_sekarang)
		if not lama.is_empty():
			return lama
		return acak(seed)
	if KANDIDAT.size() <= 1:
		return acak(seed)
	var baru := acak(seed)
	var percobaan := 0
	while String(baru["id"]) == lokasi_id_sekarang and percobaan < 20:
		# Seed deterministik: geser seed supaya percobaan berikut
		# tidak mengulang hasil yang sama.
		baru = acak(seed + percobaan + 1) if seed >= 0 else acak()
		percobaan += 1
	return baru


## ---------- Cerminan putri (Ustzh. Fatimah — §9 butir 22) ----------
## Logika SAMA seperti versi Sanusi di atas, memakai
## REFRESH_PER_MISI + KANDIDAT_PUTRI.

## Cari kandidat putri berdasarkan id. {} bila id tidak dikenal.
static func cari_putri(lokasi_id: String) -> Dictionary:
	for k in KANDIDAT_PUTRI:
		if String(k["id"]) == lokasi_id:
			return k
	return {}


## Apakah id ini ada di daftar kandidat putri?
static func id_valid_putri(lokasi_id: String) -> bool:
	return not cari_putri(lokasi_id).is_empty()


## Posisi kandidat putri berdasarkan id. Vector3.ZERO bila id
## tidak dikenal (pemanggil WAJIB cek id_valid_putri() dulu).
static func pos_dari_id_putri(lokasi_id: String) -> Vector3:
	var k := cari_putri(lokasi_id)
	if k.is_empty():
		return Vector3.ZERO
	return k["pos"]


## Pilih satu lokasi putri acak. seed >= 0 = deterministik (tes);
## seed < 0 (default) = acak dari perangkat.
static func acak_putri(seed: int = -1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	if seed >= 0:
		rng.seed = seed
	else:
		rng.randomize()
	return KANDIDAT_PUTRI[rng.randi_range(0, KANDIDAT_PUTRI.size() - 1)]


## Lokasi Fatimah untuk misi "cari Ustzh. Fatimah" berikutnya.
## REFRESH_PER_MISI = true: lokasi BARU diacak tiap misi dimulai
## dan dijamin BERBEDA dari lokasi saat ini. false: lokasi
## bertahan (mengembalikan lokasi saat ini bila valid).
static func lokasi_berikutnya_putri(lokasi_id_sekarang: String, seed: int = -1) -> Dictionary:
	if not REFRESH_PER_MISI:
		var lama := cari_putri(lokasi_id_sekarang)
		if not lama.is_empty():
			return lama
		return acak_putri(seed)
	if KANDIDAT_PUTRI.size() <= 1:
		return acak_putri(seed)
	var baru := acak_putri(seed)
	var percobaan := 0
	while String(baru["id"]) == lokasi_id_sekarang and percobaan < 20:
		# Seed deterministik: geser seed supaya percobaan berikut
		# tidak mengulang hasil yang sama.
		baru = acak_putri(seed + percobaan + 1) if seed >= 0 else acak_putri()
		percobaan += 1
	return baru
