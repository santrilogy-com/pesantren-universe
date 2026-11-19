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
## PERBAIKAN 20 Nov 2026 (Raka — temuan tes salaman: guru diacak ke
## tempat TAK TERJANGKAU, misi "cari guru" §1A langkah 4-5 bisa macet
## karena pemain tidak bisa mendekati guru (jangkauan interaksi 3,5 m):
##   - "surau" (0,0.5,-14) -> serambi timur (3.5,0,-2): (0,-14) =
##     TENGAH cangkang Surau TERTUTUP (dinding + collision, celah
##     pintu hanya di depan) — pemain di luar paling dekat 8,5 m.
##   - "masjid_besar" (64,-24) DIHAPUS -> diganti "taman_putra"
##     (0,0,27): (64,-24) di zona LARANGAN putra (x>14, z<16,
##     balik tembok x=14, gerbang tertutup).
##   - "musholla_putri" (134,-24) -> depan pagar (131,-16): tengah
##     cangkang Musholla — dari pintu selatan masih 5 m.
##   - "asrama_putri" (152,9) -> exit barat (144.5,9): tengah
##     cangkang Asrama Putri — dari pintu barat masih 6 m.
##   - "kantor_ustadzah" (148,-33) -> exit barat (142.5,-33):
##     tengah cangkang 8x6 — dari luar dinding selatan 3,0 m,
##     PAS di batas jangkauan (margin 0, rapuh).
## Aturan audit (skrip/test_lokasi_acak.gd): tiap kandidat HARUS di
## tanah terbuka (di luar semua tapak + margin 0,5 m), di zona gender
## yang benar, dan punya segmen bersih (_segmen_bersih) ke titik
## jangkar terdekat. Jumlah tetap 6 + 6; mekanisme acak
## (REFRESH_PER_MISI, tanpa marker) TIDAK berubah. Save lama dengan
## id yang dihapus dibersihkan Onboarding.baca (id tak dikenal -> "").
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
##   - Masjid Besar (64,−24) — DULU kandidat ("masjid_besar"),
##     DIHAPUS 20 Nov 2026 (Raka): di zona larangan putra (x>14,
##     z<16, balik tembok x=14) — pemain putra tidak pernah bisa
##     mendekati Sanusi di sana; diganti Taman Putra (0,27).

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
		# SERAMBI TIMUR Surau (3.5,-2), BUKAN pusat (0,-14) lagi
		# (Raka, 20 Nov 2026 — perbaikan lokasi tak terjangkau):
		# (0,-14) = TENGAH cangkang Surau yang TERTUTUP (dinding
		# + collision, celah pintu hanya di depan) — pemain di
		# luar paling dekat 8,5 m, JAUH di luar jangkauan interaksi
		# 3,5 m, jadi misi "cari Sanusi" bisa macet 1 dari 6 kali.
		# Posisi baru di rumput timur serambi (cermin rumah Kyai
		# (-3.5,-2) di barat) — tanah datar y=0, di luar lebar
		# anak tangga serambi (3,2 m) jadi _lantai_visual_y = 0.
		# y=0,5 lama HANYA berlaku di dalam plinth Surau.
		"pos": Vector3(3.5, 0, -2),
		"status": "live",
		"sumber": "Serambi timur Surau — pintu (0,-3.8), cangkang x -8..8, z -24..-4 (pesantren_builder.gd)",
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
		"id": "taman_putra",
		"nama": "Taman Putra",
		# PENGGANTI "masjid_besar" (Raka, 20 Nov 2026): (64,-24)
		# ada di zona LARANGAN putra (x>14, z<16 — balik tembok
		# x=14, gerbang tertutup) — pemain putra TIDAK PERNAH bisa
		# mendekati Sanusi di sana. Taman Putra = taman terbuka di
		# selatan plaza (bangku 1a/1b (-3.4/-2.6, 25.45) + bangku
		# 2a/2b (3.45, 27.8/28.6); rute NPC (0,24)/(0,27.5) di
		# npc.gd KURSI_LUAR) — tanah terbuka, bisa didatangi.
		"pos": Vector3(0, 0, 27),
		"status": "live",
		"sumber": "Bangku Taman Putra + rute NPC (0,24)/(0,27.5) — npc.gd KURSI_LUAR",
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
		# DEPAN PAGAR Musholla (131,-16), BUKAN pusat (134,-24)
		# lagi (Raka, 20 Nov 2026): (134,-24) = TENGAH cangkang
		# Musholla (tapak x 128..140, z -29..-19) — pemain di pintu
		# selatan (134,-19) masih 5 m, di luar jangkauan 3,5 m.
		# Posisi baru 1 m di SELATAN pagar halaman (pagar z=-17,
		# celah x 133..135 depan pintu; Mariyah di (134,-17)) —
		# tanah datar y=0, di luar serambi (x 131,75..136,25) jadi
		# tidak tenggelam. Sempat dicoba (131,-17.5) DI DALAM
		# halaman — terjangkau lewat celah, TAPI segmen lurusnya
		# menyerempet pagar (offset raycast 0,3 m); di luar pagar
		# lebih kokoh. Fatimah tetap "di Musholla" untuk teka-teki.
		"pos": Vector3(131, 0, -16),
		"status": "live",
		"sumber": "Depan pagar Musholla Ar-Raudhah — pagar z=-17, celah x 133..135, kampus_putri.gd",
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
		# EXIT BARAT Asrama Putri (144.5,9), BUKAN pusat (152,9)
		# lagi (Raka, 20 Nov 2026): (152,9) = TENGAH cangkang
		# (tapak x 146..164, z 3..15) — dari pintu barat (146,9)
		# masih 6 m, di luar jangkauan 3,5 m. Posisi baru =
		# ASRAMA_EXIT kampus_putri.gd (pintu + 1,5 m ke barat) —
		# tanah terbuka y=0.
		"pos": Vector3(144.5, 0, 9),
		"status": "live",
		"sumber": "ASRAMA_EXIT (144.5,9) — kampus_putri.gd",
	},
	{
		"id": "kantor_ustadzah",
		"nama": "Kantor Ustadzah",
		# EXIT BARAT Kantor Ustadzah (142.5,-33), BUKAN pusat
		# (148,-33) lagi (Raka, 20 Nov 2026): (148,-33) = TENGAH
		# cangkang 8x6 (x 144..152, z -36..-30) — dari luar dinding
		# selatan jaraknya 3,0 m, PAS di batas jangkauan 3,5 m
		# (margin 0 — rapuh, tembok + collider menebalkan jarak).
		# Posisi baru = KANTOR_EXIT kampus_putri.gd (pintu barat
		# (144,-33) + 1,5 m) — tanah terbuka y=0, margin aman.
		"pos": Vector3(142.5, 0, -33),
		"status": "live",
		"sumber": "KANTOR_EXIT (142.5,-33) — kampus_putri.gd",
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
