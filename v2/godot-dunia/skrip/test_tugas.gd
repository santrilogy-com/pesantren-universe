extends Node
## Tes tracker tugas dari Ustadz (Fase A, A7) — headless:
##   godot --headless --path . skrip/test_tugas.tscn
## Logika murni Tugas + kunci save "tugas_selesai"; tidak memuat main.tscn.
## Acuan: DRAF-ALUR-MISI.md §2.1 (pola baku cari Ustadz -> belajar ->
## tugas; poin jenis misi materi 10 / latihan 15 / hafalan 10 /
## peti 25 / tes 20; rantai Nahwu Dasar 30 misi + 4 tes = 420 poin).
##
## CATATAN: definisi tugas di bawah ini HANYA data uji berbentuk
## placeholder (id + modul + jenis + poin) — bukan isi tugas Modul 01.
## Isi tugas sungguhan datang dari A2 setelah tashih Mas.

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


## Definisi uji: 2 modul, tiap tugas {id, modul, jenis, poin}.
## Modul "N1.2": materi 10 + latihan 15 = 25 bila keduanya selesai.
## Modul "N1.3": hafalan 10 + peti 25.
func _definisi() -> Array:
	return [
		{"id": "N1.2-t1", "modul": "N1.2", "jenis": "materi", "poin": 10},
		{"id": "N1.2-t2", "modul": "N1.2", "jenis": "latihan", "poin": 15},
		{"id": "N1.3-t1", "modul": "N1.3", "jenis": "hafalan", "poin": 10},
		{"id": "N1.3-t2", "modul": "N1.3", "jenis": "peti", "poin": 25},
	]


func _ready() -> void:
	# --- Kunci save "tugas_selesai" ada di default ---
	var d0 := _baru()
	_cek("default punya tugas_selesai []", d0.has("tugas_selesai") and d0["tugas_selesai"] is Array and (d0["tugas_selesai"] as Array).is_empty())

	# --- Modul tanpa tugas = daftar kosong ---
	var defs := _definisi()
	_cek("modul tanpa tugas = daftar kosong (N9.9)", Tugas.tugas_untuk_modul(defs, "N9.9").is_empty())
	_cek("definisi kosong = daftar kosong", Tugas.tugas_untuk_modul([], "N1.2").is_empty())

	# --- tugas_untuk_modul hanya mengambil modul itu ---
	var n12 := Tugas.tugas_untuk_modul(defs, "N1.2")
	_cek("N1.2 punya 2 tugas (dapat %d)" % n12.size(), n12.size() == 2)
	_cek("N1.2 isinya t1+t2", n12[0]["id"] == "N1.2-t1" and n12[1]["id"] == "N1.2-t2")
	var n13 := Tugas.tugas_untuk_modul(defs, "N1.3")
	_cek("N1.3 punya 2 tugas (dapat %d)" % n13.size(), n13.size() == 2)

	# --- tandai_selesai menulis ke tugas_selesai ---
	var d1 := _baru()
	Tugas.tandai_selesai(d1, "N1.2-t1")
	_cek("tandai selesai menulis id ke tugas_selesai", (d1["tugas_selesai"] as Array) == ["N1.2-t1"])
	_cek("sudah_selesai true untuk id yang ditandai", Tugas.sudah_selesai(d1, "N1.2-t1"))
	_cek("sudah_selesai false untuk id lain", not Tugas.sudah_selesai(d1, "N1.2-t2"))

	# --- Duplikat id dihitung sekali ---
	var d2 := _baru()
	Tugas.tandai_selesai(d2, "N1.2-t1")
	Tugas.tandai_selesai(d2, "N1.2-t1")
	Tugas.tandai_selesai(d2, "N1.2-t1")
	_cek("tandai 3x id sama -> tugas_selesai berisi 1 (dapat %d)" % (d2["tugas_selesai"] as Array).size(), (d2["tugas_selesai"] as Array).size() == 1)
	_cek("duplikat id dihitung sekali di poin (dapat %d)" % Tugas.poin_tugas(d2, defs), Tugas.poin_tugas(d2, defs) == 10)
	# Duplikat juga di sisi definisi: entri sama dua kali tetap 10.
	var defs_dup := defs.duplicate()
	defs_dup.append({"id": "N1.2-t1", "modul": "N1.2", "jenis": "materi", "poin": 10})
	_cek("id duplikat di definisi dihitung sekali (dapat %d)" % Tugas.poin_tugas(d2, defs_dup), Tugas.poin_tugas(d2, defs_dup) == 10)

	# --- Poin dijumlah benar: 2 tugas 10+15 = 25 ---
	var d3 := _baru()
	Tugas.tandai_selesai(d3, "N1.2-t1")
	Tugas.tandai_selesai(d3, "N1.2-t2")
	_cek("2 tugas 10+15 = 25 (dapat %d)" % Tugas.poin_tugas(d3, defs), Tugas.poin_tugas(d3, defs) == 25)
	_cek("poin per modul N1.2 = 25 (dapat %d)" % Tugas.poin_tugas(d3, n12), Tugas.poin_tugas(d3, n12) == 25)

	# --- Tugas modul lain tidak ikut kehitung ---
	_cek("poin N1.3 = 0 padahal N1.2 selesai (dapat %d)" % Tugas.poin_tugas(d3, n13), Tugas.poin_tugas(d3, n13) == 0)
	var d4 := _baru()
	Tugas.tandai_selesai(d4, "N1.3-t1")
	Tugas.tandai_selesai(d4, "N1.3-t2")
	_cek("N1.3 hafalan+peti = 35 (dapat %d)" % Tugas.poin_tugas(d4, n13), Tugas.poin_tugas(d4, n13) == 35)
	_cek("total semua modul = 35 bila hanya N1.3 selesai (dapat %d)" % Tugas.poin_tugas(d4, defs), Tugas.poin_tugas(d4, defs) == 35)

	# --- Poin dari definisi; default POIN_JENIS bila tanpa "poin" ---
	var defs_tanpa_poin := [
		{"id": "X-t1", "modul": "X", "jenis": "materi"},
		{"id": "X-t2", "modul": "X", "jenis": "latihan"},
		{"id": "X-t3", "modul": "X", "jenis": "hafalan"},
		{"id": "X-t4", "modul": "X", "jenis": "peti"},
		{"id": "X-t5", "modul": "X", "jenis": "tes"},
	]
	var dx := _baru()
	for t in defs_tanpa_poin:
		Tugas.tandai_selesai(dx, String(t["id"]))
	_cek("default POIN_JENIS: 10+15+10+25+20 = 80 (dapat %d)" % Tugas.poin_tugas(dx, defs_tanpa_poin), Tugas.poin_tugas(dx, defs_tanpa_poin) == 80)
	_cek("poin_untuk materi tanpa poin = 10", Tugas.poin_untuk(defs_tanpa_poin[0]) == 10)
	_cek("poin_untuk tes tanpa poin = 20", Tugas.poin_untuk(defs_tanpa_poin[4]) == 20)
	# Poin di definisi mengalahkan default.
	_cek("poin definisi mengalahkan default (5, bukan 10)", Tugas.poin_untuk({"id": "Y", "modul": "Y", "jenis": "materi", "poin": 5}) == 5)
	# Jenis tidak dikenal -> 0, bukan karangan angka.
	_cek("jenis tidak dikenal = 0 poin", Tugas.poin_untuk({"id": "Z", "modul": "Z", "jenis": "ngarang"}) == 0)

	# --- Save lama tanpa kunci tugas_selesai tetap aman ---
	var dlama := _baru()
	dlama.erase("tugas_selesai")
	_cek("save lama: sudah_selesai false, bukan error", not Tugas.sudah_selesai(dlama, "N1.2-t1"))
	_cek("save lama: poin_tugas 0 (dapat %d)" % Tugas.poin_tugas(dlama, defs), Tugas.poin_tugas(dlama, defs) == 0)
	Tugas.tandai_selesai(dlama, "N1.2-t1")
	_cek("save lama: tandai_selesai membuat kunci tugas_selesai", dlama.has("tugas_selesai") and (dlama["tugas_selesai"] as Array) == ["N1.2-t1"])
	_cek("save lama: poin jadi 10 setelah ditandai (dapat %d)" % Tugas.poin_tugas(dlama, defs), Tugas.poin_tugas(dlama, defs) == 10)
	# Id kosong tidak ditulis.
	var dk := _baru()
	Tugas.tandai_selesai(dk, "")
	_cek("id kosong tidak ditulis ke tugas_selesai", (dk["tugas_selesai"] as Array).is_empty())

	print("TES TUGAS: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
