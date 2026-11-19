class_name Gelar
## Tangga gelar santri — logika MURNI tanpa UI (Fase A, A5 — Nusa).
## Acuan: DRAF-ALUR-MISI.md §2.6 (8 tier ala Mobile Legends, nama
## pesantren) + §2.1 (poin misi) + §5 (progresi).
##
## ATURAN BINTANG (persis §2.6):
## - selesaikan 1 misi = 1 bintang
## - lulus tes naik Bagian = 2 bintang
## - Ma'hadiyah >= 5/7 dalam seminggu = 1 bintang
## - menang kuis mingguan / duel / bahtsul masail = 1 bintang
## - GAGAL TIDAK mengurangi bintang — fungsi di sini hanya
##   menjumlah; tidak ada satu pun pengurang di file ini.
##
## CARA BACA "Ma'hadiyah >= 5/7 dalam seminggu" (draf tidak
## merinci lebih jauh — ini tafsir yang dipakai, dicatat supaya
## bisa dikoreksi Mas/Raka): satu minggu kalender (Senin-Ahad)
## memberi 1 bintang bila santri mencatat >= 5 dari 7 kegiatan
## Ma'hadiyah pada >= 5 hari berbeda dalam minggu itu. Angka 5
## kegiatan/hari ikut §3 ("rata-rata >= 5 dari 7 per hari").
##
## TES vs MISI (supaya tidak dihitung ganda): tes naik Bagian
## (id "N*.T") BUKAN misi biasa — bintangnya dari "tes_lulus" (2),
## bukan dari "misi_selesai". Id tes yang nyasar ke "misi_selesai"
## diabaikan saat hitung bintang misi.
##
## MODEL DIVISI (draf tidak mengatur sisa bintang saat naik tier
## — ini aturan yang dipakai, dicatat supaya bisa dikoreksi):
## bintang adalah hitungan SEUMUR HIDUP. Tiap tier "memakai"
## kapasitas bintangnya (divisi x bintang/divisi); sisanya
## mengalir ke tier berikut. Santri yang naik tier lebih awal
## (bintang belum cukup untuk kapasitas tier lama) mulai dari
## 0 bintang di divisi terbawah tier baru — seperti promosi ML
## yang mulai dari divisi terbawah. Santri yang bintangnya sudah
## mentok di puncak tier (Divisi I penuh) tinggal menunggu
## gerbang tier berikut (lulus Bagian / gerbang / Tahap).
##
## GERBANG TIER ("Dibuka oleh", §2.6):
## - Tier 2 Mubtadi'   : lulus Bagian 1 ("N1" di "bagian_lulus")
## - Tier 3 Mutawassith: lulus Bagian 2
## - Tier 4 Mutamayyiz : lulus Bagian 3
## - Tier 5 Muntahi    : lulus Bagian 4 + gerbang ruang belajar
## - Tier 6 Faqih      : lulus Tahap 1 (Ibtidaiyah)
## - Tier 7 'Alim      : lulus Tahap 2 (Tsanawiyah)
## - Tier 8 'Santri Senior': lulus Tahap 3 (Aliyah)
## Kunci save "gerbang_lulus" (bool) dan "tahap_1_lulus" /
## "tahap_2_lulus" / "tahap_3_lulus" (bool) BELUM DITULIS game
## mana pun — dibaca defensif dengan .get(..., false), jadi
## tier 5-8 TERKUNCI untuk sekarang dan terbuka sendiri begitu
## A4 (gerbang) / Fase B-C (Tahap 1-3) menulis kuncinya. JANGAN
## mengarang cara lulus Tahap 1/2/3 di sini — kuncinya hanya
## dibaca, bukan ditentukan.
## Kunci "menang_kuis" (array id kemenangan kuis/duel/bahtsul)
## juga kunci MASA DEPAN (Fase B/C) — dibaca defensif, kini 0.
##
## RESET MUSIMAN (§2.6: tiap +-3 bulan turun 1-2 divisi) DICATAT
## SAJA — SENGAJA TIDAK diimplementasi di Fase A (sesuai tugas).
##
## Tier poin lama (SantriSave.tier_for_points: 25 Penjelajah /
## 50 Pembuka Peti / 100 Penjaga Lentera) TIDAK disentuh dan
## hidup berdampingan: gelar ini soal belajar, tier poin soal
## poin. Di tier 8, "poin berjalan (25/50/100)" = tier poin itu.

## Tangga tier §2.6: "divisi" = jumlah divisi, "bintang" =
## bintang per divisi. Divisi ditulis Romawi dari bawah:
## tier 3 divisi -> III (terbawah), II, I (teratas); tier 4
## divisi -> IV, III, II, I; tier 5 divisi -> V, IV, III, II, I.
## Tier 8 tanpa divisi (divisi 0, bintang 0).
const TIERS: Array[Dictionary] = [
	{"nama": "Thalib al-'Ilm", "divisi": 3, "bintang": 3},
	{"nama": "Mubtadi'", "divisi": 3, "bintang": 3},
	{"nama": "Mutawassith", "divisi": 4, "bintang": 4},
	{"nama": "Mutamayyiz", "divisi": 4, "bintang": 4},
	{"nama": "Muntahi", "divisi": 5, "bintang": 5},
	{"nama": "Faqih", "divisi": 5, "bintang": 5},
	{"nama": "'Alim", "divisi": 5, "bintang": 5},
	{"nama": "'Santri Senior", "divisi": 0, "bintang": 0},
]

const ROMAWI: Array[String] = ["I", "II", "III", "IV", "V"]

## Bagian Nahwu Dasar (§2.1): N1-N4, masing-masing lulus lewat
## tes "N*.T" (kuis 10 soal, lulus >= 8/10 — mesinnya A1).
const BAGIAN: Array[String] = ["N1", "N2", "N3", "N4"]

## Ambang bintang Ma'hadiyah mingguan (lihat catatan di atas).
const MAHADIYAH_MIN_KEGIATAN := 5
const MAHADIYAH_MIN_HARI := 5


## Total bintang dari data save (jumlah semua sumber §2.6).
## Murni penjumlahan — tidak ada pengurang (gagal = 0, bukan minus).
static func bintang_dari_save(data: Dictionary) -> int:
	var total := 0
	total += _bintang_misi(data)
	total += _bintang_tes(data)
	total += _bintang_mahadiyah(data)
	total += _bintang_kuis(data)
	return total


## 1 misi selesai = 1 bintang (id tes "N*.T" dikecualikan —
## lihat catatan di atas). Duplikat id dihitung sekali.
static func _bintang_misi(data: Dictionary) -> int:
	var selesai: Array = data.get("misi_selesai", [])
	var unik := _unik_string(selesai)
	var n := 0
	for id_misi in unik:
		if String(id_misi).ends_with(".T"):
			continue
		n += 1
	return n


## Lulus 1 tes naik Bagian = 2 bintang. Duplikat id dihitung sekali.
static func _bintang_tes(data: Dictionary) -> int:
	var lulus: Array = data.get("tes_lulus", [])
	return _unik_string(lulus).size() * 2


## 1 bintang per minggu kalender (Senin-Ahad) dengan >= 5 hari
## yang masing-masing mencatat >= 5 kegiatan Ma'hadiyah.
static func _bintang_mahadiyah(data: Dictionary) -> int:
	var mahadiyah: Dictionary = data.get("mahadiyah", {})
	# minggu (tanggal Senin) -> jumlah hari baik dalam minggu itu.
	var hari_baik_per_minggu := {}
	for kunci in mahadiyah.keys():
		var daftar: Array = mahadiyah[kunci]
		var n_kegiatan := 0
		var sudah_dihitung := {}
		for k in daftar:
			var ks := String(k)
			if sudah_dihitung.has(ks):
				continue
			sudah_dihitung[ks] = true
			if ks in MissionData.MAHADIYAH:
				n_kegiatan += 1
		if n_kegiatan < MAHADIYAH_MIN_KEGIATAN:
			continue
		var senin := _senin_dari_tanggal(String(kunci))
		if senin == "":
			continue
		hari_baik_per_minggu[senin] = int(hari_baik_per_minggu.get(senin, 0)) + 1
	var bintang := 0
	for minggu in hari_baik_per_minggu.keys():
		if int(hari_baik_per_minggu[minggu]) >= MAHADIYAH_MIN_HARI:
			bintang += 1
	return bintang


## Menang kuis mingguan / duel / bahtsul = 1 bintang per kemenangan.
## Kunci "menang_kuis" MASA DEPAN (Fase B/C) — kini selalu 0.
static func _bintang_kuis(data: Dictionary) -> int:
	var menang: Array = data.get("menang_kuis", [])
	return _unik_string(menang).size()


## Tanggal Senin (awal minggu kalender) dari "YYYY-MM-DD".
## "" bila tanggal tidak valid. Konversi pergi-pulang memakai
## waktu lokal seperti SantriSave.streak_mahadiyah — konsisten
## di kedua arah, jadi pengelompokan minggu tetap benar.
static func _senin_dari_tanggal(tanggal: String) -> String:
	var bagian := tanggal.split("-")
	if bagian.size() != 3:
		return ""
	if not bagian[0].is_valid_int() or not bagian[1].is_valid_int() or not bagian[2].is_valid_int():
		return ""
	var d := {"year": int(bagian[0]), "month": int(bagian[1]), "day": int(bagian[2]), "hour": 0, "minute": 0, "second": 0}
	var t: int = Time.get_unix_time_from_datetime_dict(d)
	if t < 0:
		return ""
	var info := Time.get_datetime_dict_from_unix_time(t)
	# "weekday": 0 = Ahad .. 6 = Sabtu (Godot).
	var sejak_senin: int = (int(info["weekday"]) + 6) % 7
	var senin := Time.get_datetime_dict_from_unix_time(t - sejak_senin * 86400)
	return "%04d-%02d-%02d" % [senin["year"], senin["month"], senin["day"]]


## Tier saat ini (indeks 0-7) dari gerbang yang sudah lulus.
## Tier 8 butuh SEMUA: Bagian 1-4 + gerbang + Tahap 1 + Tahap 2
## + Tahap 3 — karena kunci Tahap belum ditulis game mana pun,
## tier 8 TERKUNCI untuk sekarang (tidak tercapai).
static func _tier_index(data: Dictionary) -> int:
	var bagian: Array = data.get("bagian_lulus", [])
	var punya := {}
	for b in bagian:
		punya[String(b)] = true
	var gerbang: bool = data.get("gerbang_lulus", false)
	var tahap_1: bool = data.get("tahap_1_lulus", false)
	var tahap_2: bool = data.get("tahap_2_lulus", false)
	var tahap_3: bool = data.get("tahap_3_lulus", false)
	var semua_bagian := true
	for b in BAGIAN:
		if not punya.has(b):
			semua_bagian = false
			break
	if semua_bagian and gerbang and tahap_1 and tahap_2 and tahap_3:
		return 7
	if tahap_1 and tahap_2:
		return 6
	if tahap_1:
		return 5
	if semua_bagian and gerbang:
		return 4
	if punya.has("N1") and punya.has("N2") and punya.has("N3"):
		return 3
	if punya.has("N1") and punya.has("N2"):
		return 2
	if punya.has("N1"):
		return 1
	return 0


## Syarat naik dari tier ini ke tier berikut (teks untuk UI).
static func _syarat_naik_ke(tier_berikut: int) -> String:
	match tier_berikut:
		1:
			return "Lulus Bagian 1 (tes N1.T)"
		2:
			return "Lulus Bagian 2 (tes N2.T)"
		3:
			return "Lulus Bagian 3 (tes N3.T)"
		4:
			return "Lulus Bagian 4 + gerbang ruang belajar"
		5:
			return "Lulus Tahap 1 (Ibtidaiyah)"
		6:
			return "Lulus Tahap 2 (Tsanawiyah)"
		7:
			return "Lulus Tahap 3 (Aliyah)"
	return ""


## Posisi gelar santri saat ini.
## Kembali: {tier (1-8), nama, divisi ("III"/"II"/"I"/... atau ""
## untuk 'Santri Senior'), bintang_divisi, bintang_butuh,
## total_bintang, naik_berikutnya (teks langkah berikut)}.
static func tier_saat_ini(data: Dictionary) -> Dictionary:
	var total := bintang_dari_save(data)
	var idx := _tier_index(data)
	var tier: Dictionary = TIERS[idx]
	var nama: String = tier["nama"]
	# Tier 8: tanpa divisi — poin berjalan mengikuti tier poin
	# (SantriSave.tier_for_points: 25/50/100).
	if idx == 7:
		return {
			"tier": 8,
			"nama": nama,
			"divisi": "",
			"bintang_divisi": 0,
			"bintang_butuh": 0,
			"total_bintang": total,
			"naik_berikutnya": "Gelar puncak — poin berjalan mengikuti tier poin (25/50/100).",
		}
	var n_divisi: int = tier["divisi"]
	var per_divisi: int = tier["bintang"]
	# Bintang yang sudah "dipakai" tier-tier di bawah.
	var kapasitas_bawah := 0
	for i in range(idx):
		kapasitas_bawah += int(TIERS[i]["divisi"]) * int(TIERS[i]["bintang"])
	var di_tier: int = maxi(total - kapasitas_bawah, 0)
	var kapasitas: int = n_divisi * per_divisi
	var naik := ""
	var divisi := ""
	var bintang_divisi := 0
	if di_tier >= kapasitas:
		# Mentok di Divisi I — tinggal gerbang tier berikut.
		divisi = "I"
		bintang_divisi = per_divisi
		naik = "Mentok di Divisi I — %s untuk naik ke %s." % [_syarat_naik_ke(idx + 1), TIERS[idx + 1]["nama"]]
	else:
		var div_idx: int = di_tier / per_divisi
		# div_idx 0 = divisi terbawah (mis. III/V), makin besar
		# makin tinggi; divisi teratas selalu "I".
		divisi = ROMAWI[n_divisi - 1 - div_idx]
		bintang_divisi = di_tier % per_divisi
		var div_berikut := ROMAWI[n_divisi - 1 - (div_idx + 1)] if div_idx + 1 < n_divisi else "I"
		naik = "Kumpulkan %d bintang lagi untuk naik ke Divisi %s." % [per_divisi - bintang_divisi, div_berikut]
	return {
		"tier": idx + 1,
		"nama": nama,
		"divisi": divisi,
		"bintang_divisi": bintang_divisi,
		"bintang_butuh": per_divisi,
		"total_bintang": total,
		"naik_berikutnya": naik,
	}


## Nama gelar lengkap untuk Kartu Santri / label nama, mis.
## "Thalib al-'Ilm III", "Mubtadi' II", "'Santri Senior".
static func nama_gelar(data: Dictionary) -> String:
	var t := tier_saat_ini(data)
	var divisi: String = t["divisi"]
	if divisi == "":
		return String(t["nama"])
	return "%s %s" % [String(t["nama"]), divisi]


## Array -> array string unik (menjaga urutan pertama muncul).
static func _unik_string(arr: Array) -> Array[String]:
	var keluar: Array[String] = []
	var lihat := {}
	for v in arr:
		var s := String(v)
		if lihat.has(s):
			continue
		lihat[s] = true
		keluar.append(s)
	return keluar
