extends Node
## Tes gerbang naik Bagian + gerbang Jenjang 0 + badge "Bisa Baca
## Kitab Kuning" (Fase A, A4) — headless:
##   godot --headless --path . skrip/test_gerbang.tscn
## Logika murni Gerbang + MesinKuis + Gelar; tidak memuat main.tscn.
## Acuan: DRAF-ALUR-MISI.md v5.2 §2.1 (tes N*.T 10 soal lulus
## >= 8/10, gerbang kaidah setelah N4.T, syarat badge 3 bab +
## setoran) + §2.6 (tier 5 butuh Bagian 4 + gerbang) + §1A
## langkah 6-7 (tes di Kantor, gagal = ulangi tesnya saja).

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


## n soal dummy: pertanyaan "Soal i", opsi A-D, jawaban benar 0.
## (Sama seperti test_mesin_kuis.gd — soal DUMMY untuk logika
## saja; soal sungguhan datang dari bank soal A2, bukan dari sini.)
func _buat_soal(n: int) -> Array:
	var soal := []
	for i in range(n):
		soal.append({
			"pertanyaan": "Soal %d" % (i + 1),
			"opsi": ["A", "B", "C", "D"],
			"jawaban": 0,
		})
	return soal


## Sesi tes 10 soal yang sudah dijawab: k benar pertama, sisanya
## salah (salah = pilih 1). Mengembalikan MesinKuis yang selesai.
func _tes_selesai(benar: int, jumlah := 10, jenis := "tes") -> MesinKuis:
	var m := MesinKuis.new()
	m.mulai(_buat_soal(jumlah), jenis)
	for i in range(jumlah):
		m.jawab(0 if i < benar else 1)
	return m


## Data santri yang sudah lulus 4 Bagian (N1-N4 + 4 tes).
func _empat_bagian() -> Dictionary:
	var d := _baru()
	d["bagian_lulus"] = ["N1", "N2", "N3", "N4"]
	d["tes_lulus"] = ["N1.T", "N2.T", "N3.T", "N4.T"]
	return d


func _ready() -> void:
	# --- Santri baru: belum lulus gerbang apa pun ---
	var d0 := _baru()
	_cek("santri baru: gerbang N1 belum lulus", not Gerbang.gerbang_lulus(d0, "N1"))
	_cek("santri baru: gerbang Jenjang 0 belum terbuka", not Gerbang.gerbang_terbuka(d0))
	_cek("santri baru: jenjang0 belum lulus", not Gerbang.jenjang0_lulus(d0))
	_cek("santri baru: bagian tidak dikenal (N5) false", not Gerbang.gerbang_lulus(d0, "N5"))
	var b0: Dictionary = Gerbang.badge_bisa_baca(d0)
	_cek("santri baru: badge belum lulus", not bool(b0["lulus"]))
	_cek("santri baru: badge 0 bab dibaca (dapat %d)" % int(b0["bab_dibaca"]), int(b0["bab_dibaca"]) == 0)
	_cek("santri baru: semua syarat badge false", not bool(b0["ruang_belajar_selesai"]) and not bool(b0["gerbang_lulus"]) and not bool(b0["baca_3_bab"]) and not bool(b0["setoran_lulus"]))

	# --- Tes 8/10 LULUS: N1 tercatat di bagian_lulus + tes_lulus ---
	var d8 := _baru()
	var m8 := _tes_selesai(8)
	_cek("tes 8/10: MesinKuis lulus ambang default", m8.lulus())
	_cek("tes 8/10: catat_tes N1 diterima", Gerbang.catat_tes(d8, "N1", m8))
	_cek("tes 8/10: bagian_lulus berisi N1", (d8["bagian_lulus"] as Array) == ["N1"])
	_cek("tes 8/10: tes_lulus berisi N1.T", (d8["tes_lulus"] as Array) == ["N1.T"])
	_cek("tes 8/10: gerbang_lulus(N1) true", Gerbang.gerbang_lulus(d8, "N1"))
	_cek("tes 8/10: gerbang_lulus(N2) masih false", not Gerbang.gerbang_lulus(d8, "N2"))
	_cek("tes 8/10: catat_tes TIDAK mengubah gerbang_lulus (tetap false)", not bool(d8.get("gerbang_lulus", false)))

	# --- Tes 7/10 GAGAL: tidak ada yang ditulis ---
	var d7 := _baru()
	var m7 := _tes_selesai(7)
	_cek("tes 7/10: MesinKuis tidak lulus", not m7.lulus())
	_cek("tes 7/10: catat_tes N1 ditolak", not Gerbang.catat_tes(d7, "N1", m7))
	_cek("tes 7/10: bagian_lulus tetap kosong", (d7["bagian_lulus"] as Array).is_empty())
	_cek("tes 7/10: tes_lulus tetap kosong", (d7["tes_lulus"] as Array).is_empty())
	_cek("tes 7/10: gerbang_lulus(N1) false", not Gerbang.gerbang_lulus(d7, "N1"))
	# Gagal = ulangi tesnya saja (MesinKuis bisa_ulang), tanpa penalti.
	_cek("tes 7/10: sesi gagal bisa_ulang", m7.bisa_ulang())
	var d7u := _baru()
	_cek("tes 7/10: ulang lalu 10 benar -> catat diterima", m7.ulang() and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and m7.jawab(0) and Gerbang.catat_tes(d7u, "N1", m7))
	_cek("tes 7/10: setelah ulang, bagian_lulus berisi N1", (d7u["bagian_lulus"] as Array) == ["N1"])

	# --- Catat tes yang tidak valid: tidak ada yang ditulis ---
	var dX := _baru()
	var m_belum := MesinKuis.new()
	m_belum.mulai(_buat_soal(10), "tes")
	_cek("sesi belum selesai ditolak", not Gerbang.catat_tes(dX, "N1", m_belum))
	_cek("sesi belum selesai: tidak ada yang ditulis", (dX["bagian_lulus"] as Array).is_empty() and (dX["tes_lulus"] as Array).is_empty())
	var m_lat := _tes_selesai(10, 10, "latihan")
	_cek("jenis latihan 10/10 ditolak (bukan tes)", not Gerbang.catat_tes(dX, "N1", m_lat))
	var m_5 := _tes_selesai(5, 5, "tes")
	_cek("tes 5 soal ditolak (tes = 10 soal)", not Gerbang.catat_tes(dX, "N1", m_5))
	_cek("bagian tidak dikenal (N5) ditolak", not Gerbang.catat_tes(dX, "N5", _tes_selesai(10)))
	_cek("setelah semua penolakan: tetap kosong", (dX["bagian_lulus"] as Array).is_empty() and (dX["tes_lulus"] as Array).is_empty())

	# --- Catat dua kali (idempotent, tanpa duplikat) ---
	var dD := _baru()
	_cek("catat N1 pertama diterima", Gerbang.catat_tes(dD, "N1", _tes_selesai(9)))
	_cek("catat N1 kedua diterima (idempotent)", Gerbang.catat_tes(dD, "N1", _tes_selesai(10)))
	_cek("bagian_lulus tetap 1 entri N1", (dD["bagian_lulus"] as Array).size() == 1)
	_cek("tes_lulus tetap 1 entri N1.T", (dD["tes_lulus"] as Array).size() == 1)
	# Gerbang butuh PASANGAN kunci: bagian saja tanpa tes = belum lulus.
	var dS := _baru()
	dS["bagian_lulus"] = ["N1"]
	_cek("bagian tanpa tes_lulus = belum lulus gerbang", not Gerbang.gerbang_lulus(dS, "N1"))
	var dT := _baru()
	dT["tes_lulus"] = ["N1.T"]
	_cek("tes tanpa bagian_lulus = belum lulus gerbang", not Gerbang.gerbang_lulus(dT, "N1"))

	# --- Gerbang Jenjang 0: tertutup sebelum N4, terbuka setelah N4.T ---
	var dg0 := _baru()
	_cek("gerbang tertutup sebelum N4: catat ditolak", not Gerbang.catat_gerbang(dg0, _tes_selesai(10)))
	_cek("gerbang tertutup: kunci tetap false", not bool(dg0.get("gerbang_lulus", false)))
	var dg1 := _empat_bagian()
	_cek("4 Bagian lulus: gerbang terbuka", Gerbang.gerbang_terbuka(dg1))
	_cek("4 Bagian lulus: jenjang0 belum lulus", not Gerbang.jenjang0_lulus(dg1))
	# Gerbang 7/10 gagal -> kunci tidak ditulis.
	_cek("gerbang 7/10: catat ditolak", not Gerbang.catat_gerbang(dg1, _tes_selesai(7)))
	_cek("gerbang 7/10: kunci tetap false", not bool(dg1.get("gerbang_lulus", false)))
	# Gerbang 8/10 lulus -> kunci gerbang_lulus = true.
	_cek("gerbang 8/10: catat diterima", Gerbang.catat_gerbang(dg1, _tes_selesai(8)))
	_cek("gerbang 8/10: kunci gerbang_lulus true", bool(dg1.get("gerbang_lulus", false)))
	_cek("gerbang 8/10: jenjang0_lulus true", Gerbang.jenjang0_lulus(dg1))
	_cek("gerbang: hanya kunci gerbang_lulus yang ditulis", (dg1["bagian_lulus"] as Array) == ["N1", "N2", "N3", "N4"] and (dg1["tes_lulus"] as Array) == ["N1.T", "N2.T", "N3.T", "N4.T"])
	# Gerbang yang tidak valid ditolak.
	_cek("gerbang jenis latihan ditolak", not Gerbang.catat_gerbang(_empat_bagian(), _tes_selesai(10, 10, "latihan")))
	_cek("gerbang 5 soal ditolak", not Gerbang.catat_gerbang(_empat_bagian(), _tes_selesai(5, 5, "tes")))

	# --- Badge: 2 bab saja belum cukup ---
	var db2 := _empat_bagian()
	db2["gerbang_lulus"] = true
	db2["baca_bab"] = ["jurumiyah:3", "safinatun:1"]
	var bb2: Dictionary = Gerbang.badge_bisa_baca(db2)
	_cek("badge 2 bab: baca_3_bab false (dapat %d)" % int(bb2["bab_dibaca"]), not bool(bb2["baca_3_bab"]) and int(bb2["bab_dibaca"]) == 2)
	_cek("badge 2 bab: belum lulus", not bool(bb2["lulus"]))
	# Bab yang sama dibaca dua kali dihitung satu.
	var dbD := _empat_bagian()
	dbD["gerbang_lulus"] = true
	dbD["baca_bab"] = ["jurumiyah:3", "jurumiyah:3", "safinatun:1"]
	var bbD: Dictionary = Gerbang.badge_bisa_baca(dbD)
	_cek("badge bab duplikat dihitung unik (dapat %d)" % int(bbD["bab_dibaca"]), int(bbD["bab_dibaca"]) == 2 and not bool(bbD["baca_3_bab"]))

	# --- Badge: 3 bab + gerbang + ruang belajar selesai TANPA setoran = belum lulus ---
	var db3 := _empat_bagian()
	db3["gerbang_lulus"] = true
	db3["baca_bab"] = ["jurumiyah:3", "safinatun:1", "imrithi:2"]
	var bb3: Dictionary = Gerbang.badge_bisa_baca(db3)
	_cek("badge 3 bab: ruang_belajar_selesai true", bool(bb3["ruang_belajar_selesai"]))
	_cek("badge 3 bab: gerbang_lulus true", bool(bb3["gerbang_lulus"]))
	_cek("badge 3 bab: baca_3_bab true (dapat %d)" % int(bb3["bab_dibaca"]), bool(bb3["baca_3_bab"]) and int(bb3["bab_dibaca"]) == 3)
	_cek("badge 3 bab: setoran_lulus false (Fase C)", not bool(bb3["setoran_lulus"]))
	_cek("badge 3 bab tanpa setoran: BELUM lulus", not bool(bb3["lulus"]))
	# Bila Fase C nanti menulis "setoran_lulus" = true, badge lulus.
	var dbS := _empat_bagian()
	dbS["gerbang_lulus"] = true
	dbS["baca_bab"] = ["jurumiyah:3", "safinatun:1", "imrithi:2"]
	dbS["setoran_lulus"] = true
	var bbS: Dictionary = Gerbang.badge_bisa_baca(dbS)
	_cek("badge + setoran (kunci masa depan): lulus", bool(bbS["lulus"]))
	# Tanpa gerbang, 3 bab + setoran pun belum lulus.
	var dbG := _empat_bagian()
	dbG["baca_bab"] = ["jurumiyah:3", "safinatun:1", "imrithi:2"]
	dbG["setoran_lulus"] = true
	_cek("badge tanpa gerbang: belum lulus", not bool(Gerbang.badge_bisa_baca(dbG)["lulus"]))
	# badge_bisa_baca hanya membaca — tidak menulis kunci.
	var dbR := _empat_bagian()
	dbR["gerbang_lulus"] = true
	dbR["baca_bab"] = ["jurumiyah:3", "safinatun:1", "imrithi:2"]
	Gerbang.badge_bisa_baca(dbR)
	_cek("badge_bisa_baca tidak menulis setoran_lulus", not dbR.has("setoran_lulus"))

	# --- Tier 5 tetap terkunci tanpa gerbang_lulus (konsisten test_gelar) ---
	var dt4 := _empat_bagian()
	var t4: Dictionary = Gelar.tier_saat_ini(dt4)
	_cek("4 Bagian tanpa gerbang: tier 4, bukan 5 (dapat %d)" % int(t4["tier"]), int(t4["tier"]) == 4)
	var dt5 := _empat_bagian()
	dt5["gerbang_lulus"] = true
	var t5: Dictionary = Gelar.tier_saat_ini(dt5)
	_cek("4 Bagian + gerbang: tier 5 Muntahi (dapat %d %s)" % [int(t5["tier"]), String(t5["nama"])], int(t5["tier"]) == 5 and String(t5["nama"]) == "Muntahi")
	# Alur penuh lewat Gerbang (bukan kunci tulis tangan): N1-N4
	# dicatat dari sesi tes + gerbang dicatat dari sesi kuis.
	var dFull := _baru()
	for b in ["N1", "N2", "N3", "N4"]:
		Gerbang.catat_tes(dFull, b, _tes_selesai(8))
	_cek("alur penuh: 4 Bagian tercatat dari sesi tes", (dFull["bagian_lulus"] as Array) == ["N1", "N2", "N3", "N4"])
	_cek("alur penuh: tier masih 4 sebelum gerbang", int(Gelar.tier_saat_ini(dFull)["tier"]) == 4)
	Gerbang.catat_gerbang(dFull, _tes_selesai(9))
	_cek("alur penuh: gerbang tercatat, tier 5", int(Gelar.tier_saat_ini(dFull)["tier"]) == 5)

	print("TES GERBANG: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
