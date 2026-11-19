extends Node
## Tes login server + gender santriwati (integrasi login-gender, 17 Nov 2026).
## Login game ke server kontrak v1.5.1: POST /api/santri/login dengan
## ig_username (+ password bila diset) -> ID + nama + jenis_kelamin +
## token sesi; gender ditulis ke save supaya spawn putri (130,14) +
## aturan batas cermin aktif. Gagal/offline = pesan jelas, save utuh.
## Dijalankan sebagai SCENE (.tscn), pola test_ronde22.gd. Disalin ke
## godot-dunia/ saat jalan, dihapus sebelum export.
## Jam dibekukan 10.00 (debug_jam) supaya sesi sholat tidak mengganggu.
## Akun tes LIVE (didaftarkan Raka, dihapus setelah tes — BUKAN data
## produksi): PV-0002 "Tes Putri" (tes.putri.raka, putri) + PV-0003
## "Tes Putra" (tes.putra.raka, putra), keduanya tanpa password.
## Jujur: end-to-end live HANYA mungkin karena field jenis_kelamin
## sudah live di server v1.5.1 (Saka, 17 Nov ~07:00 WIB).
## Save lokal (user://santri.json) di-backup di awal tes dan
## dikembalikan di akhir — perangkat penguji tidak kehilangan progres.

var _main: Node
var _lolos := 0
var _gagal := 0
var _save_backup := ""
var _save_ada := false

const IG_PUTRI := "tes.putri.raka"
const IG_PUTRA := "tes.putra.raka"
const IG_TIDAK_ADA := "tidak.ada.orang.ini"


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	if FileAccess.file_exists(SantriSave.SAVE_PATH):
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.READ)
		if f != null:
			_save_backup = f.get_as_text()
			_save_ada = true
			f.close()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	# Bekukan timer patroli (Kyai/Ustadzah tetap duduk) seperti baseline.
	_main._kyai._patroli_timer = 9999.0
	_main._ustadzah._patroli_timer = 9999.0
	_tes_kunci_save()
	_tes_terapkan_putri()
	await _tes_batas_cermin_putri()
	_tes_terapkan_putra()
	_tes_gender_tidak_valid()
	_tes_handler_gagal()
	_tes_ui()
	await _tes_live_server()
	_pulihkan_save()
	print("HASIL TES LOGIN-GENDER: %d LOLOS / %d GAGAL" % [_lolos, _gagal])
	LangitDinamis.debug_jam = 10.0
	for i in 300:
		await get_tree().process_frame
	print("SMOKE 300 FRAME SELESAI")
	get_tree().quit(0 if _gagal == 0 else 1)


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _dekat(a: Vector3, b: Vector3, tol: float) -> bool:
	return a.distance_to(b) <= tol


func _pulihkan_save() -> void:
	if _save_ada:
		var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.WRITE)
		if f != null:
			f.store_string(_save_backup)
			f.close()
	else:
		DirAccess.remove_absolute(SantriSave.SAVE_PATH)


# ---------- A. Kunci save ----------
func _tes_kunci_save() -> void:
	print("== A. Kunci save ==")
	var d := SantriSave.default_data()
	_cek("default_data punya jenis_kelamin=putra", d.get("jenis_kelamin", "") == "putra", str(d.get("jenis_kelamin", "")))
	_cek("default_data punya ig_username kosong", d.has("ig_username") and String(d["ig_username"]) == "", "")
	_cek("default_data punya role=santri", d.get("role", "") == "santri", str(d.get("role", "")))
	# Round-trip: kunci baru TIDAK boleh dibuang load_data (bug yang
	# diperbaiki tugas ini — dulu load_data hanya menyalin kunci lama).
	var d2 := SantriSave.load_data()
	d2["jenis_kelamin"] = "putri"
	d2["ig_username"] = "tes.roundtrip"
	SantriSave.save_data(d2)
	var d3 := SantriSave.load_data()
	_cek("load_data mempertahankan jenis_kelamin=putri", String(d3.get("jenis_kelamin", "")) == "putri", str(d3.get("jenis_kelamin", "")))
	_cek("load_data mempertahankan ig_username", String(d3.get("ig_username", "")) == "tes.roundtrip", str(d3.get("ig_username", "")))
	_cek("normalisasi_ig buang @ + huruf kecil", SantriSave.normalisasi_ig("@Aisyah.Santri ") == "aisyah.santri", SantriSave.normalisasi_ig("@Aisyah.Santri "))


# ---------- B. Terapkan login putri (stub) ----------
func _tes_terapkan_putri() -> void:
	print("== B. Terapkan login putri (stub) ==")
	var r: String = _main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "Tes.Putri.Raka", "jenis_kelamin": "putri", "session": "tok-putri-123"})
	_cek("terapkan putri sukses (galat kosong)", r == "", r)
	_cek("save jenis_kelamin=putri", String(_main._save.get("jenis_kelamin", "")) == "putri", str(_main._save.get("jenis_kelamin", "")))
	_cek("save ig_username dinormalisasi", String(_main._save.get("ig_username", "")) == "tes.putri.raka", str(_main._save.get("ig_username", "")))
	_cek("save id=PV-0002 + nama=Tes Putri", String(_main._save.get("id_santri", "")) == "PV-0002" and String(_main._save.get("nama", "")) == "Tes Putri", str(_main._save.get("id_santri", "")))
	_cek("_pemain_adalah_putri() true", bool(_main._pemain_adalah_putri()), "")
	_cek("token sesi tersimpan di memori", String(_main._session_token) == "tok-putri-123", "")
	_main._masuk_pesantren("Tes putri")
	_cek("putri masuk di spawn putri (130,14)", _dekat(_main._player.global_position, Vector3(130, 0, 14), 0.5), str(_main._player.global_position))
	_cek("jangkar dorong-balik = spawn putri", _dekat(_main._pos_legal_terakhir, Vector3(130, 0, 14), 0.5), str(_main._pos_legal_terakhir))
	var f := FileAccess.open(SantriSave.SAVE_PATH, FileAccess.READ)
	var isi := "" if f == null else f.get_as_text()
	if f != null:
		f.close()
	_cek("file save berisi jenis_kelamin putri", isi.contains('"jenis_kelamin":"putri"'), "")


# ---------- C. Batas cermin putri (live _cek_batas) ----------
func _tes_batas_cermin_putri() -> void:
	print("== C. Batas cermin putri ==")
	var toast_awal := int(_main._batas_toast_count)
	# Teleport paksa ke zona putra (x<14, z<16): harus didorong balik.
	_main._player.global_position = Vector3(0, 0, 0)
	for i in 10:
		await get_tree().process_frame
	for i in 10:
		await get_tree().physics_frame
	_cek("putri di zona putra didorong balik ke spawn putri", _dekat(_main._player.global_position, Vector3(130, 0, 14), 1.0), str(_main._player.global_position))
	_cek("toast batas putri muncul (>=1)", int(_main._batas_toast_count) > toast_awal, str(int(_main._batas_toast_count) - toast_awal))
	# Zona putri legal: berdiri di (140,10) harus TETAP (tidak didorong).
	_main._player.global_position = Vector3(140, 0, 10)
	for i in 10:
		await get_tree().process_frame
	_cek("putri di zona putri tetap (tidak didorong)", _dekat(_main._player.global_position, Vector3(140, 0, 10), 1.0), str(_main._player.global_position))


# ---------- D. Terapkan login putra (stub) ----------
func _tes_terapkan_putra() -> void:
	print("== D. Terapkan login putra (stub) ==")
	var r: String = _main._terapkan_login_server({"id": "PV-0003", "nama": "Tes Putra", "ig_username": "tes.putra.raka", "jenis_kelamin": "putra", "session": "tok-putra"})
	_cek("terapkan putra sukses", r == "", r)
	_cek("save jenis_kelamin=putra", String(_main._save.get("jenis_kelamin", "")) == "putra", "")
	_cek("_pemain_adalah_putri() false", not bool(_main._pemain_adalah_putri()), "")
	_main._masuk_pesantren("Tes putra")
	_cek("putra masuk di spawn putra (-4,14)", _dekat(_main._player.global_position, Vector3(-4, 0, 14), 0.5), str(_main._player.global_position))
	_cek("jangkar dorong-balik = spawn putra", _dekat(_main._pos_legal_terakhir, Vector3(-4, 0, 14), 0.5), str(_main._pos_legal_terakhir))
	# ID sama = lanjutkan progres (poin tidak direset).
	_main._save["poin"] = 25
	SantriSave.save_data(_main._save)
	var r2: String = _main._terapkan_login_server({"id": "PV-0003", "nama": "Tes Putra", "ig_username": "tes.putra.raka", "jenis_kelamin": "putra", "session": "tok-putra-2"})
	_cek("login ulang ID sama sukses", r2 == "", r2)
	_cek("ID sama: poin 25 dipertahankan", int(_main._save.get("poin", 0)) == 25, str(_main._save.get("poin", 0)))
	# ID baru = santri baru (progres direset).
	var r3: String = _main._terapkan_login_server({"id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri.raka", "jenis_kelamin": "putri", "session": "tok-putri-2"})
	_cek("login ID baru sukses", r3 == "", r3)
	_cek("ID baru: poin direset ke 0", int(_main._save.get("poin", -1)) == 0, str(_main._save.get("poin", -1)))


# ---------- E. Gender tidak valid ----------
func _tes_gender_tidak_valid() -> void:
	print("== E. Gender tidak valid ==")
	var snap_id := String(_main._save.get("id_santri", ""))
	var r1: String = _main._terapkan_login_server({"id": "PV-0004", "nama": "Tes Hilang", "ig_username": "tes.hilang", "session": "tok"})
	_cek("jenis_kelamin hilang -> default putra", r1 == "" and String(_main._save.get("jenis_kelamin", "")) == "putra", r1 + " / " + str(_main._save.get("jenis_kelamin", "")))
	var r2: String = _main._terapkan_login_server({"id": "PV-0005", "nama": "Tes Aneh", "ig_username": "tes.aneh", "jenis_kelamin": "x", "session": "tok"})
	_cek("jenis_kelamin 'x' -> default putra", r2 == "" and String(_main._save.get("jenis_kelamin", "")) == "putra", r2)
	# PV-0001 "Tes" di server mengembalikan jenis_kelamin null (santri
	# lama tanpa gender) — null harus jadi putra, bukan crash. Cek
	# id ikut berubah ke PV-0001: bukti fungsi benar-benar jalan
	# sampai akhir (bukan abort lalu lolos palsu dari nilai lama).
	var r3: String = _main._terapkan_login_server({"id": "PV-0001", "nama": "Tes", "ig_username": "tes", "jenis_kelamin": null, "session": "tok"})
	_cek("jenis_kelamin null (santri lama) -> putra", r3 == "" and String(_main._save.get("jenis_kelamin", "")) == "putra" and String(_main._save.get("id_santri", "")) == "PV-0001", r3)
	var id_sebelum := String(_main._save.get("id_santri", ""))
	var r4: String = _main._terapkan_login_server({"id": "XX-1", "nama": "Tes", "ig_username": "tes", "jenis_kelamin": "putri", "session": "tok"})
	_cek("ID tidak valid -> galat + save utuh", r4 != "" and String(_main._save.get("id_santri", "")) == id_sebelum, r4)
	var r5: String = _main._terapkan_login_server({"id": "PV-0006", "nama": "A", "ig_username": "tes", "jenis_kelamin": "putri", "session": "tok"})
	_cek("nama <2 huruf -> galat + save utuh", r5 != "" and String(_main._save.get("id_santri", "")) == id_sebelum, r5)
	# Kembalikan ke keadaan bagian D (PV-0001 putra) supaya bagian
	# berikut mulai dari save yang dikenal — snap_id tidak dipakai
	# lagi setelah ini.
	_main._terapkan_login_server({"id": "PV-0001", "nama": "Tes", "ig_username": "tes", "jenis_kelamin": "putra", "session": "tok"})


# ---------- F. Handler gagal (stub, tanpa jaringan) ----------
func _tes_handler_gagal() -> void:
	print("== F. Handler gagal ==")
	var snap_id := String(_main._save.get("id_santri", ""))
	var snap_jk := String(_main._save.get("jenis_kelamin", ""))
	# Offline: RESULT_CONNECTION_ERROR.
	_main._on_login_http_selesai(HTTPRequest.RESULT_CONNECTION_ERROR, 0, [], PackedByteArray())
	_cek("offline -> pesan 'tidak terjangkau'", String(_main._ui._login_error.text).contains("tidak terjangkau"), String(_main._ui._login_error.text))
	_cek("offline -> save utuh", String(_main._save.get("id_santri", "")) == snap_id and String(_main._save.get("jenis_kelamin", "")) == snap_jk, "")
	_cek("offline -> request dibersihkan + tombol aktif", _main._login_http == null and not _main._ui._masuk_btn.disabled, "")
	# 401: kata sandi salah.
	_main._on_login_http_selesai(HTTPRequest.RESULT_SUCCESS, 401, [], JSON.stringify({"ok": false, "error": "Password salah"}).to_utf8_buffer())
	_cek("401 -> pesan 'Kata sandi salah'", String(_main._ui._login_error.text).contains("Kata sandi salah"), String(_main._ui._login_error.text))
	_cek("401 -> save utuh", String(_main._save.get("id_santri", "")) == snap_id, "")
	# 200 found:false.
	_main._on_login_http_selesai(HTTPRequest.RESULT_SUCCESS, 200, [], JSON.stringify({"ok": true, "found": false, "ig_username": "x"}).to_utf8_buffer())
	_cek("found:false -> pesan 'tidak ditemukan'", String(_main._ui._login_error.text).contains("tidak ditemukan"), String(_main._ui._login_error.text))
	_cek("found:false -> save utuh", String(_main._save.get("id_santri", "")) == snap_id, "")
	# 200 body bukan JSON.
	_main._on_login_http_selesai(HTTPRequest.RESULT_SUCCESS, 200, [], "bukan json{{{".to_utf8_buffer())
	_cek("body bukan JSON -> pesan 'tidak dapat dibaca'", String(_main._ui._login_error.text).contains("tidak dapat dibaca"), String(_main._ui._login_error.text))
	# 200 found:true tapi ID tidak valid.
	_main._on_login_http_selesai(HTTPRequest.RESULT_SUCCESS, 200, [], JSON.stringify({"ok": true, "found": true, "id": "XX-1", "nama": "A", "jenis_kelamin": "putri"}).to_utf8_buffer())
	_cek("ID tidak valid via handler -> galat + save utuh", String(_main._ui._login_error.text).contains("ID yang tidak valid") and String(_main._save.get("id_santri", "")) == snap_id, String(_main._ui._login_error.text))
	# 200 sukses putri via handler (rantai penuh handler->terapkan->masuk).
	_main._on_login_http_selesai(HTTPRequest.RESULT_SUCCESS, 200, [], JSON.stringify({"ok": true, "found": true, "login": true, "id": "PV-0002", "nama": "Tes Putri", "ig_username": "tes.putri.raka", "jenis_kelamin": "putri", "session": "tok-handler"}).to_utf8_buffer())
	_cek("sukses via handler -> error kosong", String(_main._ui._login_error.text) == "", String(_main._ui._login_error.text))
	_cek("sukses via handler -> save putri", String(_main._save.get("jenis_kelamin", "")) == "putri" and String(_main._save.get("id_santri", "")) == "PV-0002", "")
	_cek("sukses via handler -> pemain di spawn putri", _dekat(_main._player.global_position, Vector3(130, 0, 14), 0.5), str(_main._player.global_position))


# ---------- G. UI login ----------
func _tes_ui() -> void:
	print("== G. UI login ==")
	_cek("field username IG ada", _main._ui._ig_input != null, "")
	_cek("field kata sandi ada + secret", _main._ui._sandi_input != null and bool(_main._ui._sandi_input.secret), "")
	_main._ui.set_login_loading(true)
	_cek("loading: tombol dikunci + teks MENGHUBUNGKAN", bool(_main._ui._masuk_btn.disabled) and String(_main._ui._masuk_btn.text) == "MENGHUBUNGKAN…", String(_main._ui._masuk_btn.text))
	_main._ui.set_login_loading(false)
	_cek("selesai loading: tombol aktif + teks MASUK PESANTREN", not bool(_main._ui._masuk_btn.disabled) and String(_main._ui._masuk_btn.text) == "MASUK PESANTREN", String(_main._ui._masuk_btn.text))
	_main._ui.show_login_error("tes pesan")
	_cek("show_login_error menampilkan pesan", String(_main._ui._login_error.text) == "tes pesan", "")
	_main._ui.show_login_error("")
	# Validasi form: username kosong ditolak di UI (tanpa jaringan).
	_main._ui._ig_input.text = ""
	_main._ui._on_masuk_pressed()
	_cek("username kosong -> galat UI", String(_main._ui._login_error.text).contains("Isi username"), String(_main._ui._login_error.text))
	_main._ui._ig_input.text = "ada spasi"
	_main._ui._on_masuk_pressed()
	_cek("username berspasi -> galat UI", String(_main._ui._login_error.text).contains("spasi"), String(_main._ui._login_error.text))


# ---------- H. Live server lewat klien game ----------
func _tes_live_server() -> void:
	print("== H. Live server (klien game sungguhan) ==")
	# Login putri live: tes.putri.raka (PV-0002, tanpa password).
	_main._on_login(IG_PUTRI, "")
	var ok := await _tunggu_login_selesai()
	_cek("live putri: request selesai", ok, "timeout 30 dtk waktu nyata")
	_cek("live putri: save jenis_kelamin=putri", String(_main._save.get("jenis_kelamin", "")) == "putri", str(_main._save.get("jenis_kelamin", "")))
	_cek("live putri: save id=PV-0002", String(_main._save.get("id_santri", "")) == "PV-0002", str(_main._save.get("id_santri", "")))
	_cek("live putri: pemain di spawn putri", _dekat(_main._player.global_position, Vector3(130, 0, 14), 0.5), str(_main._player.global_position))
	_cek("live putri: error kosong", String(_main._ui._login_error.text) == "", String(_main._ui._login_error.text))
	# Login putra live: tes.putra.raka (PV-0003, tanpa password).
	_main._on_login(IG_PUTRA, "")
	ok = await _tunggu_login_selesai()
	_cek("live putra: request selesai", ok, "timeout 30 dtk waktu nyata")
	_cek("live putra: save jenis_kelamin=putra", String(_main._save.get("jenis_kelamin", "")) == "putra", str(_main._save.get("jenis_kelamin", "")))
	_cek("live putra: save id=PV-0003", String(_main._save.get("id_santri", "")) == "PV-0003", str(_main._save.get("id_santri", "")))
	_cek("live putra: pemain di spawn putra", _dekat(_main._player.global_position, Vector3(-4, 0, 14), 0.5), str(_main._player.global_position))
	# Login username tidak dikenal live.
	var snap_id := String(_main._save.get("id_santri", ""))
	_main._on_login(IG_TIDAK_ADA, "")
	ok = await _tunggu_login_selesai()
	_cek("live unknown: request selesai", ok, "timeout 30 dtk waktu nyata")
	_cek("live unknown: pesan 'tidak ditemukan'", String(_main._ui._login_error.text).contains("tidak ditemukan"), String(_main._ui._login_error.text))
	_cek("live unknown: save utuh (tetap PV-0003)", String(_main._save.get("id_santri", "")) == snap_id, str(_main._save.get("id_santri", "")))


## Tunggu request login selesai. Batas WAKTU NYATA (30 dtk), bukan
## jumlah frame — headless jalan lebih cepat dari realtime, jadi
## tunggu berbasis frame bisa habis sebelum request 2-3 dtk selesai.
func _tunggu_login_selesai() -> bool:
	var akhir := Time.get_ticks_msec() + 30000
	while Time.get_ticks_msec() < akhir:
		if _main._login_http == null:
			return true
		await get_tree().process_frame
	return _main._login_http == null
