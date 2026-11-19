class_name RegistrasiServer
## Helper MURNI untuk pendaftaran santri ke server (tanpa I/O jaringan).
## Dipakai main.gd saat DAFTAR ditekan + dites headless dengan stub.
## Kontrak server v1.5.1 (POST /api/santri/register, PUBLIK, tanpa token):
## body {ig_username, nama, jenis_kelamin} -> 201 {ok, created, id
## "PV-XXXX", nama, ig_username, jenis_kelamin, ...}; duplikat
## ig_username -> 409; isian tidak valid -> 400. X-PV-Token TIDAK
## dipakai di sini (hanya untuk POST /api/santri/points dari server
## tepercaya) — tidak ada di file game mana pun.


static func gender_valid(jk: String) -> bool:
	return jk.strip_edges().to_lower() in ["putra", "putri"]


## Body request register. Username dinormalisasi sama seperti server
## (tanpa "@", huruf kecil); gender di luar putra/putri jadi "putra".
static func bangun_body(ig_username: String, nama: String, jenis_kelamin: String) -> Dictionary:
	var jk := jenis_kelamin.strip_edges().to_lower()
	if not gender_valid(jk):
		jk = "putra"
	return {
		"ig_username": SantriSave.normalisasi_ig(ig_username),
		"nama": nama.strip_edges(),
		"jenis_kelamin": jk,
	}


## Pesan galat dari hasil request HTTP mentah. "" = jawaban sukses
## (200/201) — lanjut ke validasi isi JSON. Jaringan gagal, 409
## (username sudah dipakai), 400 (isian ditolak server), dan kode
## lain dipetakan ke pesan yang jelas untuk form daftar.
static func pesan_galat_respons(result: int, response_code: int, teks: String) -> String:
	if result != HTTPRequest.RESULT_SUCCESS:
		return "Server tidak terjangkau. Periksa koneksi internet, lalu coba lagi."
	if response_code == 409:
		return "Username IG itu sudah dipakai santri lain. Pakai username IG lain."
	if response_code == 400:
		var pesan_server := _pesan_error_server(teks)
		if pesan_server != "":
			return pesan_server
		return "Isian ditolak server. Periksa nama (maks 30 huruf) dan username IG, lalu coba lagi."
	if response_code != 200 and response_code != 201:
		return "Server menjawab %d. Coba lagi nanti." % response_code
	return ""


## Ambil field "error" dari jawaban JSON server (mis. 400) — pesan
## server sudah Bahasa Indonesia. "" bila tidak ada / bukan JSON.
static func _pesan_error_server(teks: String) -> String:
	var t := teks.strip_edges()
	if not t.begins_with("{"):
		return ""
	var parsed: Variant = JSON.parse_string(t)
	if not (parsed is Dictionary):
		return ""
	var e: Variant = (parsed as Dictionary).get("error", "")
	if e == null:
		return ""
	return String(e).strip_edges()


## Validasi isi jawaban register sukses. "" = valid. Nilai null
## (mis. jenis_kelamin:null) TIDAK boleh masuk ke String(...) —
## konstruktor itu error pada null (pelajaran login-gender).
static func validasi_jawaban(data: Dictionary) -> String:
	var id_santri := ""
	var v_id: Variant = data.get("id", "")
	if v_id != null:
		id_santri = String(v_id).strip_edges().to_upper()
	if not SantriSave.id_valid(id_santri):
		return "Server mengembalikan ID yang tidak valid."
	var nama := ""
	var v_nama: Variant = data.get("nama", "")
	if v_nama != null:
		nama = String(v_nama).strip_edges()
	if nama.length() < 2:
		return "Server mengembalikan nama yang tidak valid."
	var jk := ""
	var v_jk: Variant = data.get("jenis_kelamin", "")
	if v_jk != null:
		jk = String(v_jk).strip_edges().to_lower()
	if jk != "putra" and jk != "putri":
		return "Server mengembalikan gender yang tidak valid."
	return ""
