extends Node
## Tes REGISTRASI-GENDER (Tara, 17 Nov 2026) — headless:
##   godot --headless --path . skrip/test_registrasi_gender.tscn
## UI form daftar (gender default putra, toggle putri, validasi form,
## sinyal register, loading) + helper murni RegistrasiServer
## (body, pesan galat 409/400/offline, validasi jawaban) +
## _terapkan_register_server stub (putri/putra/gagal) + spawn sesuai
## gender + LIVE: daftar akun tes ke server sungguhan.
## Akun tes: tes.tara.231139 ("Tes Tara", putri) — BUKAN PV-0001.
## Bila akun sudah ada (tes diulang -> 409), fallback: login live
## untuk mengambil id + gender yang sama, lalu verifikasi spawn.

const IG_TES := "tes.tara.231139"
const NAMA_TES := "Tes Tara"

var _main: Node
var _lulus := 0
var _gagal := 0
var _sinyal_register: Array = []


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _on_register_sinyal(ig: String, nama: String, jk: String) -> void:
	_sinyal_register.append([ig, nama, jk])


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	var ui = _main._ui
	ui.register_submitted.connect(_on_register_sinyal)

	# ---------- UI form daftar ----------
	ui._tampil_daftar()
	_cek("kotak daftar terlihat", ui._register_box.visible)
	_cek("kotak masuk sembunyi", not ui._login_box.visible)
	_cek("field nama daftar ada", ui._reg_nama_input != null)
	_cek("field IG daftar ada", ui._reg_ig_input != null)
	_cek("tombol putra ada", ui._reg_putra_btn != null)
	_cek("tombol putri ada", ui._reg_putri_btn != null)
	_cek("gender default putra", ui.gender_daftar_terpilih() == "putra")
	_cek("tombol putra bertanda terpilih", ui._reg_putra_btn.text.begins_with("✓"))
	_cek("tombol putri belum terpilih", not ui._reg_putri_btn.text.begins_with("✓"))
	# Metrik: kotak daftar muat di layar HP portrait 390x844.
	# tinggi_viewport di sini LOGIS (visible rect), bukan fisik:
	# skala 0.3 -> tinggi logis = 844 / 0.3. Mode kompak tidak
	# boleh aktif di ukuran ini (form penuh muat).
	var m := PesantrenUI.login_metrics(0.3, 390.0, 844.0 / 0.3)
	_cek("estimasi form daftar muat portrait", float(m["perkiraan_tinggi_form"]) < (844.0 / 0.3) * 0.94)
	_cek("portrait bukan mode kompak", not bool(m["compact"]))
	# Toggle ke putri.
	ui._on_gender_dipilih("putri")
	_cek("toggle putri", ui.gender_daftar_terpilih() == "putri")
	_cek("tombol putri bertanda terpilih", ui._reg_putri_btn.text.begins_with("✓"))
	_cek("tombol putra lepas tanda", not ui._reg_putra_btn.text.begins_with("✓"))
	ui._on_gender_dipilih("putra")
	_cek("toggle kembali putra", ui.gender_daftar_terpilih() == "putra")
	# Validasi: nama terlalu pendek -> galat, sinyal TIDAK jalan.
	_sinyal_register.clear()
	ui._reg_nama_input.text = "A"
	ui._reg_ig_input.text = "tes.tara.231139"
	ui._on_daftar_pressed()
	_cek("nama 1 huruf ditolak", ui._reg_error.text != "")
	_cek("nama 1 huruf tanpa sinyal", _sinyal_register.is_empty())
	# Validasi: IG kosong -> galat, sinyal TIDAK jalan.
	ui._reg_nama_input.text = "Tes Tara"
	ui._reg_ig_input.text = ""
	ui._on_daftar_pressed()
	_cek("IG kosong ditolak", ui._reg_error.text != "")
	_cek("IG kosong tanpa sinyal", _sinyal_register.is_empty())
	# Validasi: IG berspasi -> galat, sinyal TIDAK jalan.
	ui._reg_ig_input.text = "tes tara"
	ui._on_daftar_pressed()
	_cek("IG berspasi ditolak", ui._reg_error.text != "")
	_cek("IG berspasi tanpa sinyal", _sinyal_register.is_empty())
	# Validasi: IG dengan @ + huruf besar dinormalisasi di sinyal.
	ui._reg_ig_input.text = "@Tes.Tara.231139"
	ui._on_gender_dipilih("putri")
	ui._on_daftar_pressed()
	_cek("input valid kirim sinyal", _sinyal_register.size() == 1)
	if _sinyal_register.size() == 1:
		_cek("sinyal IG ternormalisasi", _sinyal_register[0][0] == "tes.tara.231139")
		_cek("sinyal nama", _sinyal_register[0][1] == "Tes Tara")
		_cek("sinyal gender putri", _sinyal_register[0][2] == "putri")
	# Loading: tombol + field dikunci, teks berubah, lalu kembali.
	ui.set_register_loading(true)
	_cek("loading kunci tombol daftar", ui._reg_daftar_btn.disabled)
	_cek("loading kunci field nama", not ui._reg_nama_input.editable)
	_cek("loading kunci field IG", not ui._reg_ig_input.editable)
	_cek("loading kunci tombol gender", ui._reg_putra_btn.disabled and ui._reg_putri_btn.disabled)
	_cek("loading teks MENDAFTAR", ui._reg_daftar_btn.text == "MENDAFTAR…")
	ui.set_register_loading(false)
	_cek("loading lepas kunci tombol", not ui._reg_daftar_btn.disabled)
	_cek("loading teks kembali", ui._reg_daftar_btn.text == "DAFTAR & MASUK PESANTREN")

	# ---------- Helper murni RegistrasiServer ----------
	_cek("gender_valid putra", RegistrasiServer.gender_valid("putra"))
	_cek("gender_valid putri", RegistrasiServer.gender_valid("putri"))
	_cek("gender_valid tolak x", not RegistrasiServer.gender_valid("x"))
	_cek("gender_valid tolak kosong", not RegistrasiServer.gender_valid(""))
	var body := RegistrasiServer.bangun_body("@Tes.Tara.231139", "  Tes Tara  ", "putri")
	_cek("body IG normal", String(body["ig_username"]) == "tes.tara.231139")
	_cek("body nama trim", String(body["nama"]) == "Tes Tara")
	_cek("body gender", String(body["jenis_kelamin"]) == "putri")
	var body2 := RegistrasiServer.bangun_body("tes.x", "Tes", "bukan-gender")
	_cek("body gender aneh jadi putra", String(body2["jenis_kelamin"]) == "putra")
	_cek("galat offline", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_CANT_CONNECT, 0, "") == "Server tidak terjangkau. Periksa koneksi internet, lalu coba lagi.")
	_cek("galat 409 duplikat", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 409, "") == "Username IG itu sudah dipakai santri lain. Pakai username IG lain.")
	_cek("galat 400 pakai pesan server", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 400, "{\"ok\":false,\"error\":\"Nama terlalu panjang\"}") == "Nama terlalu panjang")
	_cek("galat 400 tanpa pesan server", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 400, "bukan json") != "")
	_cek("galat 500", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 500, "").begins_with("Server menjawab 500"))
	_cek("201 tanpa galat", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 201, "{}") == "")
	_cek("200 tanpa galat", RegistrasiServer.pesan_galat_respons(HTTPRequest.RESULT_SUCCESS, 200, "{}") == "")
	_cek("validasi jawaban bagus", RegistrasiServer.validasi_jawaban({"id": "PV-0004", "nama": "Tes Tara", "jenis_kelamin": "putri"}) == "")
	_cek("validasi tolak ID buruk", RegistrasiServer.validasi_jawaban({"id": "XX-1", "nama": "Tes", "jenis_kelamin": "putri"}) != "")
	_cek("validasi tolak ID null", RegistrasiServer.validasi_jawaban({"id": null, "nama": "Tes", "jenis_kelamin": "putri"}) != "")
	_cek("validasi tolak nama 1 huruf", RegistrasiServer.validasi_jawaban({"id": "PV-0004", "nama": "T", "jenis_kelamin": "putri"}) != "")
	_cek("validasi tolak gender x", RegistrasiServer.validasi_jawaban({"id": "PV-0004", "nama": "Tes", "jenis_kelamin": "x"}) != "")
	_cek("validasi tolak gender null", RegistrasiServer.validasi_jawaban({"id": "PV-0004", "nama": "Tes", "jenis_kelamin": null}) != "")

	# ---------- _terapkan_register_server (stub, tanpa jaringan) ----------
	var id_sebelum := String(_main._save.get("id_santri", ""))
	var galat_putri: String = _main._terapkan_register_server({"id": "PV-0004", "nama": "Tes Tara", "ig_username": "tes.tara.231139", "jenis_kelamin": "putri"})
	_cek("terapkan putri sukses", galat_putri == "")
	_cek("terapkan putri tulis id", String(_main._save.get("id_santri", "")) == "PV-0004")
	_cek("terapkan putri tulis nama", String(_main._save.get("nama", "")) == "Tes Tara")
	_cek("terapkan putri tulis ig", String(_main._save.get("ig_username", "")) == "tes.tara.231139")
	_cek("terapkan putri tulis gender", String(_main._save.get("jenis_kelamin", "")) == "putri")
	_cek("terapkan putri flag putri", _main._pemain_adalah_putri())
	var galat_putra: String = _main._terapkan_register_server({"id": "PV-0005", "nama": "Tes Putra", "ig_username": "tes.putra.x", "jenis_kelamin": "putra"})
	_cek("terapkan putra sukses", galat_putra == "")
	_cek("terapkan putra tulis gender", String(_main._save.get("jenis_kelamin", "")) == "putra")
	_cek("terapkan putra bukan putri", not _main._pemain_adalah_putri())
	var id_putra := String(_main._save.get("id_santri", ""))
	var galat_buruk: String = _main._terapkan_register_server({"id": "BURUK", "nama": "Tes", "jenis_kelamin": "putri"})
	_cek("terapkan jawaban buruk ditolak", galat_buruk != "")
	_cek("terapkan buruk save utuh", String(_main._save.get("id_santri", "")) == id_putra)

	# ---------- Spawn sesuai gender ----------
	_main._terapkan_register_server({"id": "PV-0004", "nama": "Tes Tara", "ig_username": "tes.tara.231139", "jenis_kelamin": "putri"})
	_main._masuk_pesantren("Tes spawn putri")
	for i in 3:
		await get_tree().process_frame
	var pos_putri: Vector3 = _main._player.global_position
	_cek("spawn putri (130,14)", absf(pos_putri.x - 130.0) < 1.0 and absf(pos_putri.z - 14.0) < 1.0)
	_cek("visual putri abaya+jilbab", _main._player.apakah_muslimah())
	_main._terapkan_register_server({"id": "PV-0005", "nama": "Tes Putra", "ig_username": "tes.putra.x", "jenis_kelamin": "putra"})
	_main._masuk_pesantren("Tes spawn putra")
	for i in 3:
		await get_tree().process_frame
	var pos_putra: Vector3 = _main._player.global_position
	_cek("spawn putra (-4,14)", absf(pos_putra.x - (-4.0)) < 1.0 and absf(pos_putra.z - 14.0) < 1.0)
	_cek("visual putra bukan muslimah", not _main._player.apakah_muslimah())

	# ---------- LIVE: daftar ke server sungguhan ----------
	# Reset save ke keadaan kosong dulu supaya hasil live terbaca jelas.
	_main._save = SantriSave.default_data()
	SantriSave.save_data(_main._save)
	_main._on_register(IG_TES, NAMA_TES, "putri")
	var menunggu := 0
	while _main._register_http != null and menunggu < 300:
		await get_tree().process_frame
		menunggu += 1
	var id_live := String(_main._save.get("id_santri", ""))
	if id_live != "" and SantriSave.id_valid(id_live):
		_cek("LIVE register terbitkan id", true)
		print("LIVE ID: " + id_live + " | ig=" + IG_TES + " | gender=putri")
		_cek("LIVE gender putri tersimpan", String(_main._save.get("jenis_kelamin", "")) == "putri")
		var pos_live: Vector3 = _main._player.global_position
		_cek("LIVE spawn putri (130,14)", absf(pos_live.x - 130.0) < 1.0 and absf(pos_live.z - 14.0) < 1.0)
	elif ui._reg_error.text.contains("sudah dipakai"):
		# Tes diulang: akun sudah ada dari jalan sebelumnya — verifikasi
		# lewat login live bahwa akun itu memang putri, lalu masuk.
		print("LIVE: akun sudah ada, fallback login live")
		_main._on_login(IG_TES, "")
		menunggu = 0
		while _main._login_http != null and menunggu < 300:
			await get_tree().process_frame
			menunggu += 1
		id_live = String(_main._save.get("id_santri", ""))
		_cek("LIVE fallback login dapat id", SantriSave.id_valid(id_live))
		print("LIVE ID (fallback login): " + id_live + " | ig=" + IG_TES + " | gender=putri")
		_cek("LIVE fallback gender putri", String(_main._save.get("jenis_kelamin", "")) == "putri")
	else:
		_cek("LIVE register terbitkan id", false)
		print("LIVE GAGAL: galat form = '" + ui._reg_error.text + "'")

	# Bersihkan jejak: kembalikan save headless ke default (putra,
	# tanpa id) supaya tes lain (test_v2: spawn putra (-4,14)) tidak
	# ikut kena gender putri dari tes live ini.
	_main._save = SantriSave.default_data()
	SantriSave.save_data(_main._save)
	_cek("save dikembalikan default", String(_main._save.get("jenis_kelamin", "")) == "putra" and String(_main._save.get("id_santri", "")) == "")

	print("TES REGISTRASI-GENDER: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
