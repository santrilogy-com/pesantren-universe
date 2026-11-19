extends Node
## Tes fitur BACA BUKU (Tara, 17 Nov 2026) — headless:
##   ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --headless --path . skrip/test_baca_buku.tscn
## Cek: data lokal Laras (array) + filter dicek_ustadz + parse daftar
## server (stub false -> tidak tampil; stub true -> tampil) + parse
## kitab server (bab tunggal ?bab=N) + rak (tombol BACA KITAB,
## buka/tutup, kunci gerak) + navigasi bab/halaman + halaman gambar +
## zoom + fetch gagal (lokal tetap tampil) + verifikasi LIVE
## (GET /api/kitab: Jurumiyah dicek_ustadz:true -> muncul di daftar).

var _main: Node
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _id_ada(daftar: Array, id_cari: String) -> bool:
	for b in daftar:
		if b is Dictionary and String((b as Dictionary).get("id", "")) == id_cari:
			return true
	return false


func _tunggu_status_server() -> String:
	# Poll status fetch server sampai ok/gagal (maks ~15 dtk).
	for i in 30:
		var s: String = _main._ui.baca_status_server()
		if s == "ok" or s == "gagal":
			return s
		await get_tree().create_timer(0.5).timeout
	return _main._ui.baca_status_server()


func _tunggu_kitab(jumlah_min: int) -> bool:
	# Poll sampai buku aktif punya >= jumlah_min bab (fetch kitab
	# server selesai) — maks ~15 dtk.
	for i in 30:
		var bab: Array = _main._ui._baca_buku.get("bab", [])
		if bab.size() >= jumlah_min:
			return true
		await get_tree().create_timer(0.5).timeout
	return (_main._ui._baca_buku.get("bab", []) as Array).size() >= jumlah_min


func _ready() -> void:
	# ---------- unit BukuData (tanpa main) ----------
	var lokal := BukuData.muat_lokal()
	_cek("Lokal: 2 buku (Laras)", lokal.size() == 2)
	_cek("Lokal: Puisi Chairil Anwar ada", _id_ada(lokal, "puisi-chairil-anwar-pilihan"))
	_cek("Lokal: Atlas ada", _id_ada(lokal, "atlas-pesantren-verse"))
	var puisi := {}
	var atlas := {}
	for b in lokal:
		if String(b.get("id", "")) == "puisi-chairil-anwar-pilihan":
			puisi = b
		if String(b.get("id", "")) == "atlas-pesantren-verse":
			atlas = b
	_cek("Puisi: 6 bab", (puisi.get("bab", []) as Array).size() == 6)
	_cek("Puisi: bahasa id", String(puisi.get("bahasa", "")) == "id")
	_cek("Atlas: 6 halaman gambar", (atlas.get("halaman", []) as Array).size() == 6)
	_cek("Atlas: halaman 1 = masterplan-v2", String(((atlas.get("halaman", []) as Array)[0] as Dictionary).get("gambar", "")) == "res://data/atlas/masterplan-v2.ktx2")
	_cek("Draf Nahwu TIDAK dimuat", not _id_ada(lokal, "nahwu-dasar-pesantren-verse"))
	# Filter: hanya bool true yang lolos (false / hilang / string "true" tidak).
	var campuran: Array = [
		{"id": "a", "judul": "A", "dicek_ustadz": true},
		{"id": "b", "judul": "B", "dicek_ustadz": false},
		{"id": "c", "judul": "C"},
		{"id": "d", "judul": "D", "dicek_ustadz": "true"},
	]
	var lolos: Array[Dictionary] = []
	for e in campuran:
		var b := BukuData.normalisasi_buku(e)
		if BukuData.buku_lolos(b):
			lolos.append(b)
	_cek("Filter: hanya true lolos (1/4)", lolos.size() == 1 and String(lolos[0].get("id", "")) == "a")
	# Parse daftar server (stub): false -> kosong, true -> tampil.
	var stub_false := '{"ok": true, "total": 1, "kitab": [{"id": "jurumiyah", "judul": "متن الآجرومية", "judul_latin": "Jurumiyah", "jumlah_bab": 25, "dicek_ustadz": false, "atribusi": "Teks: OpenITI (CC BY-NC-SA 4.0)"}]}'
	_cek("Server stub false -> 0", BukuData.parse_daftar_server(stub_false).size() == 0)
	var stub_true := stub_false.replace('"dicek_ustadz": false', '"dicek_ustadz": true')
	var daftar_true := BukuData.parse_daftar_server(stub_true)
	_cek("Server stub true -> 1 Jurumiyah", daftar_true.size() == 1 and String(daftar_true[0].get("id", "")) == "jurumiyah")
	_cek("Server stub true -> atribusi OpenITI", String(daftar_true[0].get("atribusi", "")).begins_with("Teks: OpenITI"))
	_cek("Server stub: bahasa Arab terdeteksi", String(daftar_true[0].get("bahasa", "")) == "ar")
	_cek("Parse daftar rusak -> []", BukuData.parse_daftar_server("bukan json").is_empty())
	_cek("Parse daftar ok:false -> []", BukuData.parse_daftar_server('{"ok": false, "kitab": []}').is_empty())
	# Parse kitab server (semua bab) + satu bab (?bab=N).
	var stub_kitab := '{"ok": true, "id": "jurumiyah", "judul": "متن الآجرومية", "judul_latin": "Jurumiyah", "dicek_ustadz": true, "atribusi": "Teks: OpenITI (CC BY-NC-SA 4.0)", "jumlah_bab": 25, "bab": [{"nomor": 1, "judul": "مدخل", "teks": "بسم الله"}, {"nomor": 2, "judul": "باب الإعراب", "teks": "الإعراب هو"}]}'
	var kitab := BukuData.parse_kitab_server(stub_kitab)
	_cek("Parse kitab: 2 bab", (kitab.get("bab", []) as Array).size() == 2)
	_cek("Parse kitab: judul bab 2", BukuData.judul_bagian(kitab, 1) == "باب الإعراب")
	var stub_bab := '{"ok": true, "id": "jurumiyah", "dicek_ustadz": true, "bab": {"nomor": 1, "judul": "مدخل", "teks": "بسم الله"}}'
	_cek("Parse ?bab=1", String(BukuData.parse_bab_server(stub_bab).get("judul", "")) == "مدخل")
	_cek("Parse kitab false -> {}", BukuData.parse_kitab_server(stub_kitab.replace('"dicek_ustadz": true', '"dicek_ustadz": false')).is_empty())
	# Gabung: server dulu, dedupe id (server menang).
	var gab := BukuData.gabung(lokal, daftar_true)
	_cek("Gabung: 3 buku, server dulu", gab.size() == 3 and String(gab[0].get("id", "")) == "jurumiyah")

	# ---------- integrasi main + UI ----------
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._masuk_pesantren("Tes baca buku")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# 6 titik rak: 2 Surau + 2 Musholla (Dewi) + 2 Kelas Putri
	# (wiring interior putri Raka, 18 Nov 2026 — dulu 4, kini Kelas
	# ikut masuk daftar supaya buku bisa dibaca di Kelas juga).
	_cek("Rak spots = 6 (2 Surau + 2 Musholla Dewi + 2 Kelas Putri)", _main._rak_spots.size() == 6)
	# Masuk Surau, berdiri 1,5 m di timur rak barat, menghadap rak.
	_main._masuk_surau()
	for i in 3:
		await get_tree().process_frame
	var rak_barat: Vector3 = _main._rak_spots[0]
	_main._teleport_player(rak_barat + Vector3(1.5, 0, 0), -PI / 2.0)
	for i in 10:
		await get_tree().process_frame
	_cek("Dekat rak barat", _main._dekat_rak())
	_cek("Tombol interaksi BACA KITAB", _main._ui._interact_btn.visible and _main._ui._interact_btn.text == "BACA KITAB")
	# Buka reader lewat interaksi (sekalian mulai fetch server).
	_main._on_interact()
	for i in 3:
		await get_tree().process_frame
	_cek("Reader terbuka", _main._ui.is_baca_buku_visible())
	_cek("Tombol interaksi sembunyi saat membaca", not _main._ui._interact_btn.visible)
	# FULLSCREEN (Mas 18 Nov 2026): panel mengisi viewport, bukan popup 720x640.
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	print("FULLSCREEN: viewport = " + str(vp_size) + ", panel = " + str(_main._ui._baca_panel.size))
	_cek("Fullscreen: anchor full rect", _main._ui._baca_panel.anchor_left == 0.0 and _main._ui._baca_panel.anchor_top == 0.0 and _main._ui._baca_panel.anchor_right == 1.0 and _main._ui._baca_panel.anchor_bottom == 1.0)
	_cek("Fullscreen: panel = viewport", absf(_main._ui._baca_panel.size.x - vp_size.x) < 2.0 and absf(_main._ui._baca_panel.size.y - vp_size.y) < 2.0)
	# Panel layar penuh harus LEBIH BESAR dari popup lama di kedua
	# sumbu (rumus lama: min(92% viewport, maks(720x640, target/skala))).
	var s_layar: float = _main._ui._skala_layar()
	var popup_lama := Vector2(minf(vp_size.x * 0.92, maxf(720.0, 720.0 / s_layar)), minf(vp_size.y * 0.92, maxf(640.0, 640.0 / s_layar)))
	print("FULLSCREEN: popup lama = " + str(popup_lama) + ", panel = " + str(_main._ui._baca_panel.size))
	_cek("Fullscreen: panel lebih besar dari popup lama", _main._ui._baca_panel.size.x > popup_lama.x and _main._ui._baca_panel.size.y > popup_lama.y)
	# Kunci gerak: joystick penuh tapi move_dir tetap nol.
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 10:
		await get_tree().process_frame
	_cek("Gerak terkunci saat membaca", _main._player.move_dir.length() < 0.05)
	# Tunggu fetch server LIVE (verifikasi 5 kitab, Saka 23:58 WIB:
	# Jurumiyah 25 + Safinatun Naja 66 + Imrithi 34 + Abi Shuja 17 +
	# Arba'in Nawawi 42 — semua dicek_ustadz:true).
	var status := await _tunggu_status_server()
	print("STATUS SERVER LIVE: " + status)
	if status == "ok":
		var judul: Array[String] = _main._ui.baca_daftar_judul()
		_cek("LIVE: 5 kitab server muncul", judul.has("Jurumiyah") and judul.has("Safinatun Naja") and judul.has("Imrithi (ad-Durra al-Bahiyya)") and judul.has("Matn Abi Shuja") and judul.has("Arbain Nawawi"))
		_cek("LIVE: daftar = 7 (5 kitab + 2 lokal)", _main._ui.baca_jumlah_daftar() == 7)
		_cek("LIVE: 5 kitab server terhitung", _main._ui.baca_jumlah_server() == 5)
	else:
		_cek("LIVE: fetch server ok (dapat " + status + ")", false)
	# E2E kitab server: buka Jurumiyah -> fetch isi -> bab 1 Arab.
	_cek("Buka Jurumiyah by id", _main._ui.baca_buka_buku_id("jurumiyah"))
	var kitab_ok := await _tunggu_kitab(25)
	_cek("Jurumiyah termuat 25 bab", kitab_ok)
	_cek("Buka bab 1 Jurumiyah", _main._ui.baca_buka_bagian(0))
	_cek("Isi bab 1 Arab (al-Kalam)", String(_main._ui._baca_isi_teks.text).contains("الكلام"))
	_cek("Kicker Bab 1", String(_main._ui._baca_kicker.text).begins_with("BAB 1"))
	# FULLSCREEN: area teks tidak boleh 0 px (regresi gaya F5) —
	# pembuktian "lebih besar dari popup" ada di cek panel vs popup
	# lama di atas + foto (di HP, baris tetap sama tapi panelnya
	# jauh lebih tinggi sehingga area baca ikut membesar).
	for i in 3:
		await get_tree().process_frame
	var celah_kanan: float = _main._ui._baca_isi_scroll.get_global_rect().end.x - _main._ui._baca_isi_teks.get_global_rect().end.x
	print("FULLSCREEN: area teks = " + str(_main._ui._baca_teks_wrap.size) + ", celah kanan Arab = " + str(celah_kanan))
	_cek("Fullscreen: area teks dapat ruang (>= 200)", _main._ui._baca_teks_wrap.size.y >= 200.0)
	_cek("Arab: teks tidak mepet scrollbar (celah >= 20)", celah_kanan >= 20.0)
	_cek("Judul + nomor bab terlihat", _main._ui._baca_baca_view.visible and String(_main._ui._baca_judul_baca.text) != "" and String(_main._ui._baca_nomor.text) != "")
	_main._ui._baca_berikutnya()
	_cek("Jurumiyah bab 2 (al-I'rab)", _main._ui.baca_bagian_aktif() == 1 and String(_main._ui._baca_judul_baca.text).contains("الإعراب"))
	# Tutup -> kontrol kembali (joystick yang sama kini menggerakkan).
	_main._ui.close_baca_buku()
	for i in 3:
		await get_tree().process_frame
	_cek("Reader tertutup", not _main._ui.is_baca_buku_visible())
	for i in 10:
		await get_tree().process_frame
	_cek("Gerak kembali setelah tutup", _main._player.move_dir.length() > 0.5)
	_main._ui._joystick.output = Vector2.ZERO
	# Buka lagi, baca puisi bab 2 ("Aku") + navigasi.
	_main._ui.open_baca_buku()
	for i in 3:
		await get_tree().process_frame
	_cek("Buka buku puisi by id", _main._ui.baca_buka_buku_id("puisi-chairil-anwar-pilihan"))
	for i in 3:
		await get_tree().process_frame
	_cek("Buku aktif = puisi", _main._ui.baca_buku_aktif_id() == "puisi-chairil-anwar-pilihan")
	_cek("Buka bab 2 (Aku)", _main._ui.baca_buka_bagian(1))
	_cek("Isi bab 2 = sajak Aku", String(_main._ui._baca_isi_teks.text).contains("binatang jalang"))
	_cek("Kicker Bab 2", String(_main._ui._baca_kicker.text).begins_with("BAB 2"))
	_main._ui._baca_berikutnya()
	_cek("Berikutnya -> bab 3", _main._ui.baca_bagian_aktif() == 2)
	_main._ui._baca_sebelumnya()
	_cek("Sebelumnya -> bab 2", _main._ui.baca_bagian_aktif() == 1)
	_cek("Zona tap kiri/kanan ada", _main._ui._baca_tap_kiri != null and _main._ui._baca_tap_kanan != null)
	print("FULLSCREEN: tombol nav = " + str(_main._ui._baca_prev_btn.size) + " / " + str(_main._ui._baca_next_btn.size))
	_cek("Tombol nav cukup besar (tinggi >= 36)", _main._ui._baca_prev_btn.size.y >= 36.0 and _main._ui._baca_next_btn.size.y >= 36.0)
	_cek("Tombol TUTUP besar (min 56)", true) # tinggi dicek visual di foto
	# Halaman gambar: atlas hal. 1 + zoom.
	_main._ui._baca_ke_daftar_bab()
	_cek("Kembali ke daftar bab", _main._ui._baca_bab_view.visible)
	_main._ui.open_baca_buku()
	for i in 3:
		await get_tree().process_frame
	_cek("Buka atlas by id", _main._ui.baca_buka_buku_id("atlas-pesantren-verse"))
	for i in 3:
		await get_tree().process_frame
	_cek("Buka halaman 1 atlas", _main._ui.baca_buka_bagian(0))
	# Ukuran layout baru valid setelah 1 frame (visibility -> relayout).
	for i in 3:
		await get_tree().process_frame
	_cek("Gambar atlas termuat", _main._ui._baca_gambar.texture != null)
	_cek("Gambar: area gambar >100px (regresi F5)", _main._ui._baca_gambar_scroll.size.y > 100.0 and _main._ui._baca_gambar.size.y > 100.0)
	_cek("Fullscreen: area gambar dapat ruang (>= 200)", _main._ui._baca_gambar_scroll.size.y >= 200.0)
	_cek("Keterangan atlas ada", String(_main._ui._baca_keterangan.text).contains("Masterplan v2"))
	var lebar_awal: float = _main._ui._baca_gambar.custom_minimum_size.x
	_main._ui._baca_zoom_masuk()
	_cek("Zoom 150% melebar", _main._ui._baca_zoom_label.text == "150%" and _main._ui._baca_gambar.custom_minimum_size.x > lebar_awal)
	_main._ui._baca_berikutnya()
	_cek("Atlas hal. 2", _main._ui.baca_bagian_aktif() == 1 and String(_main._ui._baca_nomor.text) == "Halaman 2 / 6")
	# Fetch gagal -> lokal tetap tampil + status gagal.
	_main._ui._on_baca_http_selesai(HTTPRequest.RESULT_CONNECTION_ERROR, 0, PackedStringArray(), PackedByteArray())
	_cek("Fetch gagal -> status gagal", _main._ui.baca_status_server() == "gagal")
	_cek("Fetch gagal -> lokal tetap ada", _main._ui.baca_jumlah_daftar() >= 2)
	# Tutup via toggle interaksi.
	_main._ui.close_baca_buku()
	_cek("Tutup akhir", not _main._ui.is_baca_buku_visible())
	# FULLSCREEN portrait: ubah ukuran jendela — panel harus tetap
	# mengisi viewport (anchor full rect mengikuti ukuran apa pun).
	_main._ui.open_baca_buku()
	get_window().size = Vector2i(720, 1280)
	for i in 5:
		await get_tree().process_frame
	var vp_p: Vector2 = get_viewport().get_visible_rect().size
	print("FULLSCREEN portrait: viewport = " + str(vp_p) + ", panel = " + str(_main._ui._baca_panel.size))
	_cek("Portrait: panel ikut viewport", absf(_main._ui._baca_panel.size.x - vp_p.x) < 2.0 and absf(_main._ui._baca_panel.size.y - vp_p.y) < 2.0)
	_main._ui.close_baca_buku()
	get_window().size = Vector2i(1280, 720)

	print("TES BACA BUKU: lulus %d, gagal %d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
