extends Node
## Tes tangga gelar (Fase A, A5 — Nusa) — headless:
##   godot --headless --path . skrip/test_gelar.tscn
## Logika murni Gelar + kunci save baru; tidak memuat main.tscn.
## Acuan: DRAF-ALUR-MISI.md §2.6 (8 tier, cara dapat bintang,
## gagal tidak mengurangi, tier 8 terkunci) + §5 (tier poin lama).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Save segar (default_data baru tiap panggil — aman dimutasi).
func _baru() -> Dictionary:
	return SantriSave.default_data()


## Mahadiyah: N hari baik (tiap hari 5 kegiatan) mulai tanggal awal.
## Dipakai untuk membangun minggu kalender yang jelas batasnya.
## 2026-11-09 = Senin, 2026-11-15 = Ahad, 2026-11-16 = Senin.
func _mahadiyah_hari_baik(tanggal_awal: String, n_hari: int) -> Dictionary:
	var m := {}
	var bagian := tanggal_awal.split("-")
	var d := {"year": int(bagian[0]), "month": int(bagian[1]), "day": int(bagian[2]), "hour": 0, "minute": 0, "second": 0}
	var t: int = Time.get_unix_time_from_datetime_dict(d)
	for i in range(n_hari):
		var info := Time.get_datetime_dict_from_unix_time(t + i * 86400)
		var kunci := "%04d-%02d-%02d" % [info["year"], info["month"], info["day"]]
		m[kunci] = ["tahajjud", "subuh_berjamaah", "dzikir_pagi", "dhuha", "tilawah"]
	return m


func _ready() -> void:
	# --- Kunci save baru (A5 pemilik gelombang 1) ---
	var d0 := _baru()
	_cek("default punya tes_lulus []", d0.has("tes_lulus") and d0["tes_lulus"] is Array and (d0["tes_lulus"] as Array).is_empty())
	_cek("default punya bagian_lulus []", d0.has("bagian_lulus") and d0["bagian_lulus"] is Array and (d0["bagian_lulus"] as Array).is_empty())
	_cek("default punya tugas_selesai []", d0.has("tugas_selesai") and d0["tugas_selesai"] is Array and (d0["tugas_selesai"] as Array).is_empty())
	_cek("default punya baca_bab []", d0.has("baca_bab") and d0["baca_bab"] is Array and (d0["baca_bab"] as Array).is_empty())
	_cek("default punya onboarding {}", d0.has("onboarding") and d0["onboarding"] is Dictionary and (d0["onboarding"] as Dictionary).is_empty())

	# --- Santri baru = tier 1 divisi III, 0 bintang ---
	var t := Gelar.tier_saat_ini(d0)
	_cek("santri baru tier 1 (dapat %d)" % int(t["tier"]), int(t["tier"]) == 1)
	_cek("santri baru Thalib al-'Ilm", String(t["nama"]) == "Thalib al-'Ilm")
	_cek("santri baru divisi III", String(t["divisi"]) == "III")
	_cek("santri baru 0 bintang (total %d, divisi %d)" % [int(t["total_bintang"]), int(t["bintang_divisi"])], int(t["total_bintang"]) == 0 and int(t["bintang_divisi"]) == 0)
	_cek("santri baru butuh 3 bintang/divisi", int(t["bintang_butuh"]) == 3)
	_cek("nama_gelar santri baru", Gelar.nama_gelar(d0) == "Thalib al-'Ilm III")

	# --- 1 misi = 1 bintang ---
	var d1 := _baru()
	d1["misi_selesai"] = ["M1"]
	_cek("1 misi = 1 bintang (dapat %d)" % Gelar.bintang_dari_save(d1), Gelar.bintang_dari_save(d1) == 1)
	t = Gelar.tier_saat_ini(d1)
	_cek("1 bintang tetap III 1/3", String(t["divisi"]) == "III" and int(t["bintang_divisi"]) == 1)

	# --- 3 bintang -> naik divisi (III -> II, 0 di divisi baru) ---
	var d3 := _baru()
	d3["misi_selesai"] = ["M1", "M2", "M3"]
	_cek("3 misi = 3 bintang (dapat %d)" % Gelar.bintang_dari_save(d3), Gelar.bintang_dari_save(d3) == 3)
	t = Gelar.tier_saat_ini(d3)
	_cek("3 bintang naik ke divisi II 0/3 (dapat %s %d)" % [String(t["divisi"]), int(t["bintang_divisi"])], String(t["divisi"]) == "II" and int(t["bintang_divisi"]) == 0)

	# --- 4 bintang = divisi II 1/3; 8 bintang = divisi I 2/3 ---
	var d4 := _baru()
	d4["misi_selesai"] = ["M1", "M2", "M3", "N1.2"]
	t = Gelar.tier_saat_ini(d4)
	_cek("4 bintang = II 1/3 (dapat %s %d)" % [String(t["divisi"]), int(t["bintang_divisi"])], String(t["divisi"]) == "II" and int(t["bintang_divisi"]) == 1)
	var d8 := _baru()
	d8["misi_selesai"] = ["M1", "M2", "M3", "N1.2", "N1.3", "N1.4", "N1.5", "N1.6"]
	t = Gelar.tier_saat_ini(d8)
	_cek("8 bintang = I 2/3 (dapat %s %d)" % [String(t["divisi"]), int(t["bintang_divisi"])], String(t["divisi"]) == "I" and int(t["bintang_divisi"]) == 2)

	# --- 9 bintang = mentok Divisi I, tinggal gerbang Bagian 1 ---
	var d9 := _baru()
	d9["misi_selesai"] = ["M1", "M2", "M3", "N1.2", "N1.3", "N1.4", "N1.5", "N1.6", "N1.7"]
	t = Gelar.tier_saat_ini(d9)
	_cek("9 bintang mentok I 3/3 (dapat %s %d)" % [String(t["divisi"]), int(t["bintang_divisi"])], String(t["divisi"]) == "I" and int(t["bintang_divisi"]) == 3)
	_cek("mentok I -> naik minta Bagian 1", String(t["naik_berikutnya"]).contains("Bagian 1"))

	# --- Tes lulus = 2 bintang ---
	var dt := _baru()
	dt["tes_lulus"] = ["N1.T"]
	_cek("lulus 1 tes = 2 bintang (dapat %d)" % Gelar.bintang_dari_save(dt), Gelar.bintang_dari_save(dt) == 2)

	# --- Lulus Bagian 1 -> tier 2 Mubtadi' ---
	var dN1 := _baru()
	dN1["bagian_lulus"] = ["N1"]
	dN1["tes_lulus"] = ["N1.T"]
	t = Gelar.tier_saat_ini(dN1)
	_cek("lulus Bagian 1 -> tier 2 (dapat %d)" % int(t["tier"]), int(t["tier"]) == 2)
	_cek("tier 2 namanya Mubtadi'", String(t["nama"]) == "Mubtadi'")
	_cek("tier 2 mulai divisi III 0 bintang", String(t["divisi"]) == "III" and int(t["bintang_divisi"]) == 0)
	_cek("nama_gelar tier 2", Gelar.nama_gelar(dN1) == "Mubtadi' III")

	# --- Lulus Bagian 2 -> tier 3 (4 bintang/divisi); Bagian 3 -> tier 4 ---
	var dN2 := _baru()
	dN2["bagian_lulus"] = ["N1", "N2"]
	t = Gelar.tier_saat_ini(dN2)
	_cek("lulus Bagian 2 -> tier 3 Mutawassith", int(t["tier"]) == 3 and String(t["nama"]) == "Mutawassith")
	_cek("tier 3 butuh 4 bintang/divisi", int(t["bintang_butuh"]) == 4)
	var dN3 := _baru()
	dN3["bagian_lulus"] = ["N1", "N2", "N3"]
	t = Gelar.tier_saat_ini(dN3)
	_cek("lulus Bagian 3 -> tier 4 Mutamayyiz", int(t["tier"]) == 4 and String(t["nama"]) == "Mutamayyiz")

	# --- Tier 5 butuh Bagian 4 + gerbang (tanpa gerbang tetap tier 4) ---
	var dN4 := _baru()
	dN4["bagian_lulus"] = ["N1", "N2", "N3", "N4"]
	t = Gelar.tier_saat_ini(dN4)
	_cek("4 Bagian tanpa gerbang tetap tier 4 (dapat %d)" % int(t["tier"]), int(t["tier"]) == 4)
	dN4["gerbang_lulus"] = true
	t = Gelar.tier_saat_ini(dN4)
	_cek("4 Bagian + gerbang -> tier 5 Muntahi", int(t["tier"]) == 5 and String(t["nama"]) == "Muntahi")
	_cek("tier 5 butuh 5 bintang/divisi", int(t["bintang_butuh"]) == 5)

	# --- Ma'hadiyah >= 5/7 seminggu = 1 bintang ---
	var dm5 := _baru()
	dm5["mahadiyah"] = _mahadiyah_hari_baik("2026-11-09", 5)
	_cek("Ma'hadiyah 5 hari baik seminggu = 1 bintang (dapat %d)" % Gelar.bintang_dari_save(dm5), Gelar.bintang_dari_save(dm5) == 1)
	var dm4 := _baru()
	dm4["mahadiyah"] = _mahadiyah_hari_baik("2026-11-09", 4)
	_cek("Ma'hadiyah 4 hari baik = 0 bintang (dapat %d)" % Gelar.bintang_dari_save(dm4), Gelar.bintang_dari_save(dm4) == 0)
	# Hari dengan 4 kegiatan saja tidak dihitung sebagai hari baik.
	var dm45 := _baru()
	var m45 := {}
	for i in range(5):
		var info := Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_dict({"year": 2026, "month": 11, "day": 9, "hour": 0, "minute": 0, "second": 0}) + i * 86400)
		m45["%04d-%02d-%02d" % [info["year"], info["month"], info["day"]]] = ["tahajjud", "subuh_berjamaah", "dzikir_pagi", "dhuha"]
	dm45["mahadiyah"] = m45
	_cek("5 hari x 4 kegiatan = 0 bintang (dapat %d)" % Gelar.bintang_dari_save(dm45), Gelar.bintang_dari_save(dm45) == 0)
	# 3 hari minggu A + 2 hari minggu B = 0 (tidak gabung lintas minggu).
	var dm32 := _baru()
	var m32 := _mahadiyah_hari_baik("2026-11-11", 3)
	m32.merge(_mahadiyah_hari_baik("2026-11-16", 2))
	dm32["mahadiyah"] = m32
	_cek("Ma'hadiyah 3+2 hari beda minggu = 0 (dapat %d)" % Gelar.bintang_dari_save(dm32), Gelar.bintang_dari_save(dm32) == 0)
	# Batas minggu: Ahad 15 Nov + Senin-Kamis 16-19 Nov = 1 + 4 hari -> 0.
	var dmAhad := _baru()
	var mAhad := _mahadiyah_hari_baik("2026-11-15", 1)
	mAhad.merge(_mahadiyah_hari_baik("2026-11-16", 4))
	dmAhad["mahadiyah"] = mAhad
	_cek("Ahad + Senin-Kamis beda minggu = 0 (dapat %d)" % Gelar.bintang_dari_save(dmAhad), Gelar.bintang_dari_save(dmAhad) == 0)
	# 5 hari baik di 2 minggu berbeda = 2 bintang.
	var dm2 := _baru()
	var m2 := _mahadiyah_hari_baik("2026-11-09", 5)
	m2.merge(_mahadiyah_hari_baik("2026-11-16", 5))
	dm2["mahadiyah"] = m2
	_cek("Ma'hadiyah 5+5 hari dua minggu = 2 bintang (dapat %d)" % Gelar.bintang_dari_save(dm2), Gelar.bintang_dari_save(dm2) == 2)

	# --- Gagal TIDAK mengurangi bintang ---
	var dg := _baru()
	dg["misi_selesai"] = ["M1"]
	_cek("gagal tes (tidak ada di tes_lulus) tetap 1 bintang (dapat %d)" % Gelar.bintang_dari_save(dg), Gelar.bintang_dari_save(dg) == 1)
	var dg2 := _baru()
	dg2["misi_selesai"] = ["M1", "M1", "M1"]
	_cek("misi sama 3x dihitung sekali = 1 bintang (dapat %d)" % Gelar.bintang_dari_save(dg2), Gelar.bintang_dari_save(dg2) == 1)
	var dg3 := _baru()
	dg3["misi_selesai"] = ["N1.T"]
	_cek("id tes di misi_selesai bukan bintang misi (dapat %d)" % Gelar.bintang_dari_save(dg3), Gelar.bintang_dari_save(dg3) == 0)

	# --- Menang kuis mingguan / duel / bahtsul = 1 bintang ---
	var dk := _baru()
	dk["menang_kuis"] = ["kuis-2026-11-21"]
	_cek("1 kemenangan kuis = 1 bintang (dapat %d)" % Gelar.bintang_dari_save(dk), Gelar.bintang_dari_save(dk) == 1)

	# --- Tier 8 TERKUNCI untuk sekarang ---
	# Progres maksimal yang bisa dilacak save hari ini (4 Bagian +
	# gerbang + 4 tes + 30 misi) tetap mentok di tier 5.
	var dmax := _baru()
	dmax["bagian_lulus"] = ["N1", "N2", "N3", "N4"]
	dmax["gerbang_lulus"] = true
	dmax["tes_lulus"] = ["N1.T", "N2.T", "N3.T", "N4.T"]
	var misi30: Array[String] = []
	for i in range(30):
		misi30.append("X%d" % (i + 1))
	dmax["misi_selesai"] = misi30
	t = Gelar.tier_saat_ini(dmax)
	_cek("progres maksimal kini mentok tier 5, bukan 8 (dapat %d)" % int(t["tier"]), int(t["tier"]) == 5)
	_cek("nama gelar maksimal kini Muntahi", String(t["nama"]) == "Muntahi")
	# Kunci Tahap masa depan (belum ditulis game mana pun): Tahap 1
	# saja -> tier 6; Tahap 1+2 tanpa Tahap 3 -> tier 7, bukan 8.
	var dT1 := _baru()
	dT1["bagian_lulus"] = ["N1", "N2", "N3", "N4"]
	dT1["gerbang_lulus"] = true
	dT1["tahap_1_lulus"] = true
	t = Gelar.tier_saat_ini(dT1)
	_cek("tahap_1_lulus (kunci masa depan) -> tier 6 Faqih", int(t["tier"]) == 6 and String(t["nama"]) == "Faqih")
	dT1["tahap_2_lulus"] = true
	t = Gelar.tier_saat_ini(dT1)
	_cek("tahap_1+2 tanpa tahap_3 -> tier 7 'Alim, bukan 8", int(t["tier"]) == 7 and String(t["nama"]) == "'Alim")

	# --- tier_for_points lama TIDAK berubah ---
	_cek("tier poin 0 = Santri Baru", SantriSave.tier_for_points(0) == "Santri Baru")
	_cek("tier poin 25 = Penjelajah", SantriSave.tier_for_points(25) == "Penjelajah")
	_cek("tier poin 50 = Pembuka Peti", SantriSave.tier_for_points(50) == "Pembuka Peti")
	_cek("tier poin 100 = Penjaga Lentera", SantriSave.tier_for_points(100) == "Penjaga Lentera")

	print("TES GELAR: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
