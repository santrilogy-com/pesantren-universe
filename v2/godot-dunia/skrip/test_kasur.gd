extends Node
## Tes PEMBAGIAN KASUR (Wulan, 18 Nov 2026) — headless:
##   nice -n -10 godot --headless --path . skrip/test_kasur.tscn
## JANGAN edit skrip/test_v2.gd (Rangga + Gilang mengeditnya paralel).
##
## Isi: (A) logika murni — urutan PUTRA Cangkruk 1-10 -> Asrama Kamar
## 001 -> overflow Surau; PUTRI Asrama 1-96 -> overflow Musholla
## (KOREKSI Mas 00:25 WIB — tanpa Cangkruk Putri); 1 kasur = 1 santri
## (tanpa dobel); idempotent; pemisahan gender; fisik vs logis. (B) geometri anti-
## tembus — semua titik tidur (kasur Cangkruk + titik Surau/Musholla)
## dicek terhadap AABB dunia interior ASLI (bukan hitungan tangan).
## (C) ledger file — simpan/muat. (D) hook main.gd — login + daftar
## (stub, TANPA jaringan) menerbitkan kasur; aksi tidur di kasur
## sendiri (Cangkruk) + di titik tugas (Surau); tidur di kasur orang
## lain DITOLAK.
## Akun tes: PV-9001 dst (BUKAN PV-0001 "Tes" — data produksi).
## File user://santri.json + user://kasur.json di-backup lalu
## dikembalikan di akhir tes.

const ID_PUTRA_1 := "PV-9001"
const ID_PUTRI_1 := "PV-9002"

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _kunci_posisi(p: Vector3) -> String:
	return "%d|%d" % [int(round(p.x * 100.0)), int(round(p.z * 100.0))]


func _ready() -> void:
	_tes_logika()
	await _tes_geometri()
	_tes_ledger()
	await _tes_hook()
	print("TES KASUR: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


# ---------- (A) logika murni ----------
func _tes_logika() -> void:
	var ledger: Dictionary = {"versi": 1, "tugas": {}}
	# Putra 1..10 -> Cangkruk Putra.
	for i in range(1, 11):
		var t := PembagianKasur.buat_tugas("PV-91%02d" % i, "putra", ledger)
		_cek("putra #%d Cangkruk Putra" % i, String(t["gedung"]) == "Cangkruk Putra")
		_cek("putra #%d kasur C-PUTRA-%02d" % [i, i], String(t["kasur_id"]) == "C-PUTRA-%02d" % i)
	_cek("putra #1 susun 1 bawah", int(ledger["tugas"]["PV-9101"]["susun"]) == 1 and String(ledger["tugas"]["PV-9101"]["tingkat"]) == "bawah")
	_cek("putra #2 susun 1 atas", int(ledger["tugas"]["PV-9102"]["susun"]) == 1 and String(ledger["tugas"]["PV-9102"]["tingkat"]) == "atas")
	_cek("putra #10 susun 5 atas", int(ledger["tugas"]["PV-9110"]["susun"]) == 5 and String(ledger["tugas"]["PV-9110"]["tingkat"]) == "atas")
	# Putra 11 -> Asrama Kamar 001; 18 -> kasur 8 Kamar 001; 19 -> Kamar 002.
	var t11 := PembagianKasur.buat_tugas("PV-9111", "putra", ledger)
	_cek("putra #11 Asrama Putra", String(t11["gedung"]) == "Asrama Putra")
	_cek("putra #11 Kamar 001 A-PUTRA-001", String(t11["kamar"]) == "Kamar 001" and String(t11["kasur_id"]) == "A-PUTRA-001")
	for i in range(12, 20):
		PembagianKasur.buat_tugas("PV-91%02d" % i, "putra", ledger)
	var t18: Dictionary = ledger["tugas"]["PV-9118"]
	_cek("putra #18 Kamar 001 susun 4 atas", String(t18["kamar"]) == "Kamar 001" and int(t18["susun"]) == 4 and String(t18["tingkat"]) == "atas")
	var t19: Dictionary = ledger["tugas"]["PV-9119"]
	_cek("putra #19 Kamar 002 A-PUTRA-009", String(t19["kamar"]) == "Kamar 002" and String(t19["kasur_id"]) == "A-PUTRA-009")
	# Putri (KOREKSI Mas 00:25 WIB — tanpa Cangkruk): 1..96 Asrama Putri.
	for i in range(1, 12):
		var t := PembagianKasur.buat_tugas("PV-92%02d" % i, "putri", ledger)
		_cek("putri #%d Asrama Putri" % i, String(t["gedung"]) == "Asrama Putri" and String(t["kasur_id"]) == "A-PUTRI-%03d" % i)
	var w1: Dictionary = ledger["tugas"]["PV-9201"]
	_cek("putri #1 Kamar 001 A-PUTRI-001", String(w1["kamar"]) == "Kamar 001" and String(w1["kasur_id"]) == "A-PUTRI-001")
	var w8: Dictionary = ledger["tugas"]["PV-9208"]
	_cek("putri #8 Kamar 001 susun 4 atas", String(w8["kamar"]) == "Kamar 001" and int(w8["susun"]) == 4 and String(w8["tingkat"]) == "atas")
	var w9: Dictionary = ledger["tugas"]["PV-9209"]
	_cek("putri #9 Kamar 002 A-PUTRI-009", String(w9["kamar"]) == "Kamar 002" and String(w9["kasur_id"]) == "A-PUTRI-009")
	# Idempotent: daftar ulang ID yang sama -> kasur yang sama.
	var ulang := PembagianKasur.buat_tugas("PV-9101", "putra", ledger)
	_cek("idempotent PV-9101 tetap C-PUTRA-01", String(ulang["kasur_id"]) == "C-PUTRA-01")
	_cek("idempotent tidak menambah isi", PembagianKasur.jumlah_terisi("putra", ledger) == 19)
	# Fisik vs logis.
	for i in range(1, 6):
		var t: Dictionary = ledger["tugas"]["PV-91%02d" % i]
		_cek("putra #%d kasur fisik" % i, bool(t["fisik"]))
		_cek("putra #%d posisi = kasur interior %d" % [i, i], PembagianKasur.posisi_tidur(t) == InteriorCangkruk.BED_POS_LIST[i - 1])
	for i in range(6, 11):
		var t: Dictionary = ledger["tugas"]["PV-91%02d" % i]
		_cek("putra #%d tingkat atas belum fisik" % i, not bool(t["fisik"]))
		_cek("putra #%d tidur sementara di Surau" % i, PembagianKasur.posisi_tidur(t) in PembagianKasur.tempat_tidur_surau())
	for i in range(1, 7):
		var t: Dictionary = ledger["tugas"]["PV-92%02d" % i]
		_cek("putri #%d Asrama belum fisik" % i, not bool(t["fisik"]))
		_cek("putri #%d tidur sementara di Musholla" % i, PembagianKasur.posisi_tidur(t) in PembagianKasur.tempat_tidur_musholla())
	_cek("putra #11 Asrama belum fisik", not bool(t11["fisik"]))
	# Isi penuh: 106 putra + 96 putri, tanpa dobel, pisah gender.
	for i in range(20, 107):
		PembagianKasur.buat_tugas("PV-93%03d" % i, "putra", ledger)
	for i in range(12, 97):
		PembagianKasur.buat_tugas("PV-94%03d" % i, "putri", ledger)
	# Putra 11..106 -> Asrama Putra A-PUTRA-001..096, Kamar 001..012
	# (Lestari, 18 Nov 2026 — wiring Asrama Putra: 1 santri = 1 kasur).
	for n in range(11, 107):
		var idx := n - 10
		var t: Dictionary = ledger["tugas"][_id_putra(n)]
		_cek("putra #%d Asrama A-PUTRA-%03d Kamar %03d" % [n, idx, (idx - 1) / 8 + 1],
			String(t["gedung"]) == "Asrama Putra" and String(t["kasur_id"]) == "A-PUTRA-%03d" % idx and String(t["kamar"]) == "Kamar %03d" % ((idx - 1) / 8 + 1))
	var kasur_putra := {}
	var kasur_putri := {}
	var posisi_putra := {}
	var posisi_putri := {}
	var dobel := false
	var campur := false
	for id in (ledger["tugas"] as Dictionary).keys():
		var t: Dictionary = ledger["tugas"][id]
		var kid := String(t["kasur_id"])
		if String(t["gender"]) == "putra":
			if kasur_putra.has(kid):
				dobel = true
			kasur_putra[kid] = true
			if "PUTRI" in kid or String(t["gedung"]).contains("Putri"):
				campur = true
			if PembagianKasur.ada_posisi_tidur(t):
				var k := _kunci_posisi(PembagianKasur.posisi_tidur(t))
				if posisi_putra.has(k):
					dobel = true
				posisi_putra[k] = true
		else:
			if kasur_putri.has(kid):
				dobel = true
			kasur_putri[kid] = true
			if "PUTRA" in kid or String(t["gedung"]).contains("Putra"):
				campur = true
			if PembagianKasur.ada_posisi_tidur(t):
				var k := _kunci_posisi(PembagianKasur.posisi_tidur(t))
				if posisi_putri.has(k):
					dobel = true
				posisi_putri[k] = true
	_cek("106 putra tanpa kasur dobel", kasur_putra.size() == 106 and not dobel)
	_cek("96 putri tanpa kasur dobel", kasur_putri.size() == 96 and not dobel)
	_cek("tidak ada posisi tidur dobel", not dobel)
	_cek("gender tidak pernah campur", not campur)
	_cek("PV-0001 tidak pernah dipakai", not (ledger["tugas"] as Dictionary).has("PV-0001"))
	# Overflow: santri ke-107 (putra) / ke-97 (putri) -> Surau / Musholla.
	var o_p := PembagianKasur.buat_tugas("PV-9399", "putra", ledger)
	_cek("putra #107 Surau S-PUTRA-01", String(o_p["gedung"]) == "Surau" and String(o_p["kasur_id"]) == "S-PUTRA-01")
	var o_w := PembagianKasur.buat_tugas("PV-9499", "putri", ledger)
	_cek("putri #97 Musholla S-PUTRI-01", String(o_w["gedung"]) == "Musholla" and String(o_w["kasur_id"]) == "S-PUTRI-01")
	# Titik terverifikasi habis -> posisi null + flag (bukan dobel diam-diam).
	var n_surau := PembagianKasur.tempat_tidur_surau().size()
	var n_musholla := PembagianKasur.tempat_tidur_musholla().size()
	var habis_p: Dictionary = ledger["tugas"][_id_putra(5 + n_surau + 1)]
	_cek("putra ke-%d titik Surau habis -> flag" % (5 + n_surau + 1), not PembagianKasur.ada_posisi_tidur(habis_p) and bool(habis_p["tempat_fisik_belum_terverifikasi"]))
	var habis_w: Dictionary = ledger["tugas"][_id_putri(n_musholla + 1)]
	_cek("putri ke-%d titik Musholla habis -> flag" % (n_musholla + 1), not PembagianKasur.ada_posisi_tidur(habis_w) and bool(habis_w["tempat_fisik_belum_terverifikasi"]))
	print("LOGIKA: Surau %d titik, Musholla %d titik" % [n_surau, n_musholla])


## ID tes putra/putri urutan ke-`n` (pola penomoran tes di atas).
func _id_putra(n: int) -> String:
	return ("PV-91%02d" % n) if n <= 19 else ("PV-93%03d" % n)


func _id_putri(n: int) -> String:
	return ("PV-92%02d" % n) if n <= 11 else ("PV-94%03d" % n)


# ---------- (B) geometri anti-tembus ----------
func _tes_geometri() -> void:
	var cangkruk: Dictionary = InteriorCangkruk.build()
	var surau: Dictionary = InteriorSurau.build()
	var musholla: Dictionary = InteriorMusholla.build()
	add_child(cangkruk["root"])
	add_child(surau["root"])
	add_child(musholla["root"])
	for i in 5:
		await get_tree().process_frame
	# Kasur Cangkruk 1..5: badan (1,1 x 2,1 + margin 0,1) tidak boleh
	# menyentuh furnitur lain (kasur sendiri = alas tidur, dikecualikan).
	var rint_c := _kumpulkan_rintangan(cangkruk["root"])
	for i in range(5):
		var bed: Vector3 = InteriorCangkruk.BED_POS_LIST[i]
		var bentur := _bentur_pertama(bed, rint_c, "TempatTidur%d" % (i + 1))
		_cek("kasur Cangkruk %d anti-tembus" % (i + 1), bentur == "")
		if bentur != "":
			print("  bentur kasur %d: %s" % [i + 1, bentur])
	# Titik Surau + Musholla: badan tidak boleh menyentuh apa pun
	# (lantai kosong — tidak ada alas yang dikecualikan).
	var rint_s := _kumpulkan_rintangan(surau["root"])
	var spots_s := PembagianKasur.tempat_tidur_surau()
	for i in range(spots_s.size()):
		var bentur := _bentur_pertama(spots_s[i], rint_s, "")
		_cek("titik Surau %d anti-tembus" % (i + 1), bentur == "")
		if bentur != "":
			print("  bentur Surau %d di %s: %s" % [i + 1, str(spots_s[i]), bentur])
	var rint_m := _kumpulkan_rintangan(musholla["root"])
	var spots_m := PembagianKasur.tempat_tidur_musholla()
	for i in range(spots_m.size()):
		var bentur := _bentur_pertama(spots_m[i], rint_m, "")
		_cek("titik Musholla %d anti-tembus" % (i + 1), bentur == "")
		if bentur != "":
			print("  bentur Musholla %d di %s: %s" % [i + 1, str(spots_m[i]), bentur])
	# Titik-titik saling berjauhan (>= 1,3 m antar pusat — badan 1,1 m
	# + celah) supaya dua santri tidak bersentuhan saat tidur.
	_cek("titik Surau saling berjauhan", _jarak_min(spots_s) >= 1.3)
	_cek("titik Musholla saling berjauhan", _jarak_min(spots_m) >= 1.3)
	cangkruk["root"].queue_free()
	surau["root"].queue_free()
	musholla["root"].queue_free()


## Kumpulkan jejak kaki furnitur (segi empat 2D di XZ + rentang Y).
## AABB dunia TIDAK dipakai untuk uji sentuh — dinding/mebel yang
## miring -25° punya AABB dunia yang mengembang (dinding barat Surau
## 6,1 x 12,8 m!) dan menelan titik tidur yang sebenarnya bersih
## (semua titik Surau/Musholla gagal di ronde pertama karena ini).
## Jejak diambil dari 4 sudut bawah AABB lokal — semua putaran di
## interior hanya yaw, jadi jejak = persegi panjang yang diputar,
## bukan kotak sumbu. Uji sentuhnya SAT 2D (_quad_bersentuhan).
func _kumpulkan_rintangan(root: Node3D) -> Array:
	var hasil: Array = []
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		var nama := String(m.name)
		if "Lantai" in nama or "Karpet" in nama or "Plafon" in nama or "Trim" in nama:
			continue
		var lokal: AABB = m.get_aabb()
		var gab: AABB = m.global_transform * lokal
		if gab.end.y < 0.25 or gab.position.y > 1.2:
			continue
		var sudut: Array[Vector2] = []
		# URUTAN SUDUT PENTING: harus melingkar (x0,z0)->(x1,z0)->
		# (x1,z1)->(x0,z1). Loop bersarang [min,max]x[min,max] memberi
		# (x0,z0),(x0,z1),(x1,z0),(x1,z1) = DASIH (bowtie) — sumbu
		# SAT-nya diagonal dan semua titik dinyatakan bentur (temuan
		# tes 00:45 WIB: dinding barat Surau menelan 6 titik bersih).
		var xs := [lokal.position.x, lokal.end.x]
		var zs := [lokal.position.z, lokal.end.z]
		for k in [[0, 0], [1, 0], [1, 1], [0, 1]]:
			var w: Vector3 = m.global_transform * Vector3(xs[k[0]], lokal.position.y, zs[k[1]])
			sudut.append(Vector2(w.x, w.z))
		var induk := ""
		var ortu := m.get_parent()
		if ortu != null:
			induk = String(ortu.name)
		hasil.append([nama, induk, sudut])
	return hasil


## Nama rintangan pertama yang bersentuhan dengan badan tidur di
## `pusat` ("" bila bersih). `kecuali_induk` = grup alas sendiri.
func _bentur_pertama(pusat: Vector3, rintangan: Array, kecuali_induk: String) -> String:
	var hx := PembagianKasur.TIDUR_SETENGAH_X + 0.10
	var hz := PembagianKasur.TIDUR_SETENGAH_Z + 0.10
	var tidur: Array[Vector2] = [
		Vector2(pusat.x - hx, pusat.z - hz), Vector2(pusat.x + hx, pusat.z - hz),
		Vector2(pusat.x + hx, pusat.z + hz), Vector2(pusat.x - hx, pusat.z + hz),
	]
	for r in rintangan:
		if kecuali_induk != "" and String(r[1]) == kecuali_induk:
			continue
		var quad: Array = r[2]
		if _quad_bersentuhan(tidur, quad):
			return "%s (induk %s)" % [String(r[0]), String(r[1])]
	return ""


## SAT 2D: dua segi empat bersentuhan bila proyeksinya bertumpuk di
## SEMUA sumbu (2 sisi A + 2 sisi B). Ada satu sumbu yang renggang
## = tidak bersentuhan.
func _quad_bersentuhan(a: Array, b: Array) -> bool:
	var sumbu: Array[Vector2] = []
	for q in [a, b]:
		for i in range(2):
			var p0: Vector2 = q[i]
			var p1: Vector2 = q[(i + 1) % 4]
			var e: Vector2 = p1 - p0
			if e.length() > 0.001:
				sumbu.append(e.normalized())
	for s in sumbu:
		var min_a := 1e9
		var max_a := -1e9
		for p in a:
			var pv: Vector2 = p
			var d := pv.dot(s)
			min_a = minf(min_a, d)
			max_a = maxf(max_a, d)
		var min_b := 1e9
		var max_b := -1e9
		for p in b:
			var pv: Vector2 = p
			var d := pv.dot(s)
			min_b = minf(min_b, d)
			max_b = maxf(max_b, d)
		if max_a < min_b or max_b < min_a:
			return false
	return true


func _jarak_min(daftar: Array[Vector3]) -> float:
	var paling_kecil := 1e9
	for a in range(daftar.size()):
		for b in range(a + 1, daftar.size()):
			var d := daftar[a].distance_to(daftar[b])
			if d < paling_kecil:
				paling_kecil = d
	return paling_kecil


# ---------- (C) ledger file ----------
func _tes_ledger() -> void:
	var jalur := "user://kasur_test.json"
	if FileAccess.file_exists(jalur):
		DirAccess.remove_absolute(jalur)
	var p1 := PembagianKasur.new(jalur)
	var a1 := p1.daftarkan("PV-9101", "putra")
	var a2 := p1.daftarkan("PV-9102", "putri")
	_cek("ledger: putra pertama C-PUTRA-01", String(a1["kasur_id"]) == "C-PUTRA-01")
	_cek("ledger: putri pertama A-PUTRI-001", String(a2["kasur_id"]) == "A-PUTRI-001")
	var p2 := PembagianKasur.new(jalur)
	p2.muat()
	_cek("ledger: muat ulang putra sama", String(p2.ambil("PV-9101")["kasur_id"]) == "C-PUTRA-01")
	_cek("ledger: muat ulang putri sama", String(p2.ambil("PV-9102")["kasur_id"]) == "A-PUTRI-001")
	_cek("ledger: ID tak dikenal kosong", p2.ambil("PV-9999").is_empty())
	DirAccess.remove_absolute(jalur)


# ---------- (D) hook main.gd ----------
func _tes_hook() -> void:
	var santri_path := "user://santri.json"
	var kasur_path := "user://kasur.json"
	var bak_santri := _baca_file(santri_path)
	var bak_kasur := _baca_file(kasur_path)
	if FileAccess.file_exists(kasur_path):
		DirAccess.remove_absolute(kasur_path)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Login stub santri baru putra -> kasur pertama.
	var galat: String = _main._terapkan_login_server({"id": ID_PUTRA_1, "nama": "Tes Kasur Satu", "jenis_kelamin": "putra", "ig_username": "tes.kasur.9001", "session": "x"})
	_cek("hook login: tanpa galat", galat == "")
	_cek("hook login: PV-9001 C-PUTRA-01", String(_main._kasur_saya.get("kasur_id", "")) == "C-PUTRA-01")
	_cek("hook login: kasur fisik bed 1", bool(_main._kasur_saya.get("fisik", false)) and PembagianKasur.posisi_tidur(_main._kasur_saya) == InteriorCangkruk.BED_POS_LIST[0])
	# Login ulang ID sama -> kasur tetap (idempotent, tanpa daftar ulang).
	var galat2: String = _main._terapkan_login_server({"id": ID_PUTRA_1, "nama": "Tes Kasur Satu", "jenis_kelamin": "putra", "ig_username": "tes.kasur.9001", "session": "x"})
	_cek("hook login ulang: tetap C-PUTRA-01", galat2 == "" and String(_main._kasur_saya.get("kasur_id", "")) == "C-PUTRA-01")
	# Daftar stub santri baru putri -> kasur putri pertama.
	var galat3: String = _main._terapkan_register_server({"id": ID_PUTRI_1, "nama": "Tes Kasur Dua", "jenis_kelamin": "putri", "ig_username": "tes.kasur.9002"})
	_cek("hook daftar: tanpa galat", galat3 == "")
	_cek("hook daftar: PV-9002 A-PUTRI-001", String(_main._kasur_saya.get("kasur_id", "")) == "A-PUTRI-001")
	_cek("hook daftar: putri belum fisik", not bool(_main._kasur_saya.get("fisik", false)))
	# Tidur di kasur SENDIRI (Cangkruk bed 1) -> berhasil.
	_main._terapkan_login_server({"id": ID_PUTRA_1, "nama": "Tes Kasur Satu", "jenis_kelamin": "putra", "ig_username": "tes.kasur.9001", "session": "x"})
	var bed1: Vector3 = InteriorCangkruk.BED_POS_LIST[0]
	_main._di_dalam_cangkruk = true
	_main._set_interior_terlihat(false, true, false)
	_main._player.global_position = bed1 + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	_cek("tidur kasur sendiri: pose tidur", _main._player.aksi_saat_ini() == "tidur")
	_cek("tidur kasur sendiri: snap ke kasur", _main._player.global_position.distance_to(bed1 + Vector3(0, 0, 0.95)) < 0.05)
	_main._on_aksi("berdiri")
	_cek("bangun: kembali berdiri", _main._player.aksi_saat_ini() == "berdiri")
	# Tidur di kasur ORANG LAIN (bed 2) -> ditolak.
	var bed2: Vector3 = InteriorCangkruk.BED_POS_LIST[1]
	_main._player.global_position = bed2 + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	_cek("tidur kasur orang lain: ditolak", _main._player.aksi_saat_ini() == "berdiri")
	# Tidur di titik tugas Surau (santri Asrama #11) -> berhasil.
	var ledger_s: Dictionary = {"versi": 1, "tugas": {}}
	for i in range(1, 11):
		PembagianKasur.buat_tugas("PV-95%02d" % i, "putra", ledger_s)
	var t11 := PembagianKasur.buat_tugas("PV-9511", "putra", ledger_s)
	_cek("santri #11 Asrama tidur sementara di Surau", String(t11["gedung"]) == "Asrama Putra" and PembagianKasur.ada_posisi_tidur(t11))
	_main._kasur_saya = t11
	_main._di_dalam_cangkruk = false
	_main._di_dalam = true
	_main._set_interior_terlihat(true, false, false)
	var spot := PembagianKasur.posisi_tidur(t11)
	_main._player.global_position = spot + Vector3(0, 0, 1.5)
	_main._on_aksi("tidur")
	_cek("tidur titik Surau: pose tidur", _main._player.aksi_saat_ini() == "tidur")
	_cek("tidur titik Surau: snap ke titik", _main._player.global_position.distance_to(spot + Vector3(0, 0, 0.95)) < 0.05)
	_main._on_aksi("berdiri")
	# Tidur di luar ruangan -> ditolak.
	_main._di_dalam = false
	_main._di_dalam_cangkruk = false
	_main._di_dalam_musholla = false
	_main._player.global_position = Vector3(-4, 0, 14)
	_main._on_aksi("tidur")
	_cek("tidur di luar: ditolak", _main._player.aksi_saat_ini() == "berdiri")
	# Bersihkan jejak: kembalikan save + ledger seperti sebelum tes.
	_tulis_file(santri_path, bak_santri)
	_tulis_file(kasur_path, bak_kasur)
	_cek("jejak: santri.json dikembalikan", _baca_file(santri_path) == bak_santri)
	_cek("jejak: kasur.json dikembalikan", _baca_file(kasur_path) == bak_kasur)


func _baca_file(jalur: String) -> String:
	if not FileAccess.file_exists(jalur):
		return ""
	var f := FileAccess.open(jalur, FileAccess.READ)
	if f == null:
		return ""
	var isi := f.get_as_text()
	f.close()
	return isi


func _tulis_file(jalur: String, isi: String) -> void:
	if isi == "":
		if FileAccess.file_exists(jalur):
			DirAccess.remove_absolute(jalur)
		return
	var f := FileAccess.open(jalur, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(isi)
	f.close()
