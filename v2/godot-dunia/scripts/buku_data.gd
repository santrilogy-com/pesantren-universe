class_name BukuData
extends RefCounted
## Logika data pembaca kitab — MURNI (tanpa I/O jaringan), dites headless.
##
## Kontrak data lokal (Laras): res://data/buku.json — ARRAY buku (atau
## {"buku": [...]}); tiap buku: {id, judul, judul_latin, bahasa ("ar"/"id"),
## jenis ("teks"/"gambar"), dicek_ustadz (bool), atribusi, lisensi,
## bab:[{nomor, judul, teks}] untuk jenis teks,
## halaman:[{nomor, gambar (res://...), keterangan}] untuk jenis gambar}.
## File data/buku.json saat ini (Laras, 17 Nov 2026): Puisi Chairil Anwar
## (teks, 6 bab, domain publik) + Atlas Pesantren Universe (gambar, 6 hal.).
## File data/buku-draft-nahwu.json adalah DRAFT (dicek_ustadz:false) dan
## TIDAK PERNAH dimuat reader — hanya data/buku.json yang dibaca.
##
## ATURAN (Mas, 23:49 WIB — koreksi: Jurumiyah + kitab antrean SUDAH OK,
## cek ustadz lolos): reader HANYA menampilkan buku dicek_ustadz:true.
## Filter client-side di sini yang menegakkannya — jangan hardcode kitab
## masuk, jangan ubah flag dari game. Lencana "Belum dicek ustadz" TIDAK
## dipakai (semua buku yang tampil sudah dicek).
##
## Server kitab (publik, TANPA token — X-PV-Token TIDAK dipakai di file
## game mana pun, sama seperti login/registrasi): GET
## {KITAB_API_BASE}/api/kitab -> {"ok": true, "kitab": [...]}; isi kitab
## via GET /api/kitab/<id> (semua bab) atau ?bab=N (satu bab).
## Saat ini server hanya punya Jurumiyah (25 bab, dicek_ustadz:true
## sejak 23:49 WIB) — kitab antrean (Safinatun Naja, Imrithi, Matn Abi
## Shuja, Arba'in Nawawi) muncul otomatis begitu ada di server.

const KITAB_API_BASE := "https://43-173-39-166.sslip.io"
const BUKU_LOKAL_PATH := "res://data/buku.json"


## Ambil string dari Variant apa pun tanpa crash pada null (pelajaran
## login-gender: String(null) error) — "" bila kosong/null.
static func str_aman(v: Variant, default: String = "") -> String:
	if v == null:
		return default
	return String(v).strip_edges()


## Satu-satunya gerbang tampil: dicek_ustadz HARUS bool true.
## Nilai lain (false, null, "true", 1) = TIDAK lolos. (Godot 4
## STRICT: String == bool itu runtime error, jadi dicek via `is`.)
static func buku_lolos(b: Dictionary) -> bool:
	return _bool_true(b.get("dicek_ustadz", false))


static func _bool_true(v: Variant) -> bool:
	return v is bool and v


## Normalisasi satu entri buku (lokal/server) ke bentuk yang dipakai
## reader. Field hilang -> default aman; bab/halaman rusak -> dibuang.
static func normalisasi_buku(d: Dictionary, sumber: String = "lokal") -> Dictionary:
	var b: Dictionary = {
		"id": str_aman(d.get("id", "")),
		"judul": str_aman(d.get("judul", "")),
		"judul_latin": str_aman(d.get("judul_latin", "")),
		"bahasa": _bahasa_buku(d),
		"jenis": str_aman(d.get("jenis", "teks"), "teks"),
		"dicek_ustadz": _bool_true(d.get("dicek_ustadz", false)),
		"atribusi": str_aman(d.get("atribusi", "")),
		"lisensi": str_aman(d.get("lisensi", "")),
		"sumber": sumber,
		"jumlah_bab": int(d.get("jumlah_bab", 0)),
		"bab": [],
		"halaman": [],
	}
	if b["judul_latin"] == "":
		b["judul_latin"] = b["judul"]
	var bab_raw: Variant = d.get("bab", [])
	if bab_raw is Array:
		for entri in (bab_raw as Array):
			if not (entri is Dictionary):
				continue
			var e := entri as Dictionary
			var teks := str_aman(e.get("teks", ""))
			if teks == "":
				continue
			(b["bab"] as Array).append({
				"nomor": int(e.get("nomor", (b["bab"] as Array).size() + 1)),
				"judul": str_aman(e.get("judul", "Bab " + str((b["bab"] as Array).size() + 1))),
				"teks": teks,
			})
	var hal_raw: Variant = d.get("halaman", [])
	if hal_raw is Array:
		for entri in (hal_raw as Array):
			if not (entri is Dictionary):
				continue
			var e := entri as Dictionary
			var gambar := str_aman(e.get("gambar", ""))
			if gambar == "":
				continue
			(b["halaman"] as Array).append({
				"nomor": int(e.get("nomor", (b["halaman"] as Array).size() + 1)),
				"gambar": gambar,
				"keterangan": str_aman(e.get("keterangan", "")),
			})
	if b["jenis"] not in ["teks", "gambar"]:
		b["jenis"] = "teks"
	if b["bahasa"] not in ["ar", "id"]:
		b["bahasa"] = "id"
	return b


## Bahasa buku: pakai field "bahasa" bila ada; bila tidak ada, deteksi
## dari judul. Kitab server tidak mengirim field bahasa — judul Arab
## -> "ar", sisanya "id". (Label "Indonesia" untuk kitab Arab pernah
## lolos ke foto F2 karena default "id" buta — jangan ulangi.)
static func _bahasa_buku(d: Dictionary) -> String:
	var b := str_aman(d.get("bahasa", ""), "")
	if b == "ar" or b == "id":
		return b
	if _mengandung_arab(str_aman(d.get("judul", ""))):
		return "ar"
	return "id"


static func _mengandung_arab(teks: String) -> bool:
	for ch in teks:
		var c := ch.unicode_at(0)
		if (c >= 0x0600 and c <= 0x06FF) or (c >= 0x0750 and c <= 0x077F) or (c >= 0xFB50 and c <= 0xFEFF):
			return true
	return false


## Muat buku lokal dari res://data/buku.json. Hanya yang lolos filter
## (dicek_ustadz:true) yang dikembalikan. File hilang/rusak/bukan
## JSON -> [] (reader tetap jalan dengan buku server saja).
static func muat_lokal(path: String = BUKU_LOKAL_PATH) -> Array[Dictionary]:
	var hasil: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		return hasil
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return hasil
	var teks := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(teks)
	var daftar: Array = []
	if parsed is Array:
		daftar = parsed
	elif parsed is Dictionary and (parsed as Dictionary).get("buku", []) is Array:
		daftar = (parsed as Dictionary)["buku"]
	for entri in daftar:
		if not (entri is Dictionary):
			continue
		var b := normalisasi_buku(entri, "lokal")
		if b["id"] == "" or not buku_lolos(b):
			continue
		hasil.append(b)
	return hasil


## Parse jawaban GET /api/kitab -> daftar kitab server yang LOLOS
## filter (dicek_ustadz:true). Bukan JSON / ok:false / tanpa daftar
## -> [] (pemanggil menampilkan buku lokal + pesan singkat).
static func parse_daftar_server(teks: String) -> Array[Dictionary]:
	var hasil: Array[Dictionary] = []
	var t := teks.strip_edges()
	if not t.begins_with("{"):
		return hasil
	var parsed: Variant = JSON.parse_string(t)
	if not (parsed is Dictionary):
		return hasil
	var data := parsed as Dictionary
	if not bool(data.get("ok", false)):
		return hasil
	var daftar: Variant = data.get("kitab", [])
	if not (daftar is Array):
		return hasil
	for entri in (daftar as Array):
		if not (entri is Dictionary):
			continue
		var b := normalisasi_buku(entri, "server")
		if b["id"] == "" or not buku_lolos(b):
			continue
		hasil.append(b)
	return hasil


## Parse jawaban GET /api/kitab/<id> (semua bab) -> satu buku lengkap.
## Juga menerima bentuk ?bab=N (bab = Dictionary tunggal) -> dibungkus
## jadi array satu bab. Gagal/ok:false -> {}.
static func parse_kitab_server(teks: String) -> Dictionary:
	var t := teks.strip_edges()
	if not t.begins_with("{"):
		return {}
	var parsed: Variant = JSON.parse_string(t)
	if not (parsed is Dictionary):
		return {}
	var data := parsed as Dictionary
	if not bool(data.get("ok", false)):
		return {}
	var b := normalisasi_buku(data, "server")
	if b["id"] == "" or not buku_lolos(b):
		return {}
	var bab_raw: Variant = data.get("bab", [])
	if bab_raw is Dictionary:
		b["bab"] = [normalisasi_bab(bab_raw, 1)]
		b["jumlah_bab"] = 1
	elif bab_raw is Array:
		var bab_bersih: Array = []
		var n := 1
		for entri in (bab_raw as Array):
			if not (entri is Dictionary):
				continue
			var nb := normalisasi_bab(entri, n)
			if String(nb["teks"]) != "":
				bab_bersih.append(nb)
			n += 1
		b["bab"] = bab_bersih
		if int(b["jumlah_bab"]) <= 0:
			b["jumlah_bab"] = bab_bersih.size()
	return b


## Parse jawaban GET /api/kitab/<id>?bab=N -> satu bab
## {nomor, judul, teks}. Gagal -> {}.
static func parse_bab_server(teks: String) -> Dictionary:
	var t := teks.strip_edges()
	if not t.begins_with("{"):
		return {}
	var parsed: Variant = JSON.parse_string(t)
	if not (parsed is Dictionary):
		return {}
	var data := parsed as Dictionary
	if not bool(data.get("ok", false)):
		return {}
	var bab_raw: Variant = data.get("bab", {})
	if not (bab_raw is Dictionary):
		return {}
	return normalisasi_bab(bab_raw, 1)


## Normalisasi satu bab server {nomor, judul, teks} (nomor default n).
static func normalisasi_bab(e: Dictionary, n: int) -> Dictionary:
	return {
		"nomor": int(e.get("nomor", n)),
		"judul": str_aman(e.get("judul", "Bab " + str(n)), "Bab " + str(n)),
		"teks": str_aman(e.get("teks", "")),
	}


## Gabung daftar server + lokal untuk reader: server dulu (kitab),
## lalu lokal; id kembar -> server menang (satu entri saja).
static func gabung(lokal: Array, server: Array) -> Array[Dictionary]:
	var hasil: Array[Dictionary] = []
	var lihat: Dictionary = {}
	for entri in server:
		if not (entri is Dictionary):
			continue
		var b := entri as Dictionary
		if String(b.get("id", "")) == "":
			continue
		hasil.append(b)
		lihat[String(b["id"])] = true
	for entri in lokal:
		if not (entri is Dictionary):
			continue
		var b := entri as Dictionary
		if String(b.get("id", "")) == "" or lihat.has(String(b["id"])):
			continue
		hasil.append(b)
	return hasil


## Label bahasa untuk daftar: "ar" -> "Arab", "id" -> "Indonesia".
static func label_bahasa(bahasa: String) -> String:
	if bahasa == "ar":
		return "Arab"
	return "Indonesia"


## Jumlah bagian yang bisa dibaca: bab (teks) atau halaman (gambar).
static func jumlah_bagian(b: Dictionary) -> int:
	if String(b.get("jenis", "teks")) == "gambar":
		return (b.get("halaman", []) as Array).size()
	return (b.get("bab", []) as Array).size()


## Judul bagian ke-idx (0-based): judul bab / "Halaman N".
static func judul_bagian(b: Dictionary, idx: int) -> String:
	if String(b.get("jenis", "teks")) == "gambar":
		var hal: Array = b.get("halaman", [])
		if idx < 0 or idx >= hal.size():
			return ""
		return "Halaman " + str(int((hal[idx] as Dictionary).get("nomor", idx + 1)))
	var bab: Array = b.get("bab", [])
	if idx < 0 or idx >= bab.size():
		return ""
	return str_aman((bab[idx] as Dictionary).get("judul", ""))
