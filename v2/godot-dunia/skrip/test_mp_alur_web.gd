extends Node
## Tes alur WEB multiplayer (Dimas, 18 Nov 2026) — TANPA flag --mp-join /
## --mp-ticket (itulah yang dipakai smoke test Fase 1, dan itulah yang
## membuat alur asli HP tidak pernah teruji).
##
## Mensimulasikan pemain kembali (save tersimpan, TANPA token sesi —
## kondisi pemain yang masuk lewat "Lanjut" / baru daftar) yang menekan
## tombol "Main Bersama" di HUD — persis alur HP Mas 13:10 WIB
## ("Belum bisa main multiplayer", "Dimana itu?").
##
## Dijalankan (2 klien paralel, seperti T1 — putra + putri):
##   godot --headless --path . skrip/test_mp_alur_web.tscn -- \
##     --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" \
##     --mp-web-jk putra --mp-web-id PV-0004
##   (klien 2: test_mp_putri / "Tes MP Putri" / putri / PV-0005)
## Santri tes sudah ada di DB (PV-0004/PV-0005, dibuat smoke test);
## login diam-diam memakai POST /api/santri/login username saja.
##
## Kriteria:
##   (a) tombol "Main Bersama" ada + terlihat saat offline.
##   (b) tekan tombol -> status keluar dari "offline".
##   (c) login diam-diam mengisi token sesi (bukan "").
##   (d) online + avatar sendiri diadopsi main.gd.
##   (e) avatar peer terlihat (butuh klien kedua jalan).
## Exit 0 = semua lulus; bukan-nol = ada gagal/blokir.

var _main: Node
var _lulus := 0
var _gagal := 0
var _blokir := 0
var _peer_saya := 0
var _ditolak_alasan := ""
var _save_awal: Dictionary = {}


func _pulihkan_save() -> void:
	# Kembalikan save asal sebelum quit (lihat _save_awal).
	if _main != null and not _save_awal.is_empty():
		_main._save = _save_awal.duplicate(true)
		SantriSave.save_data(_main._save)


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _cek_blokir(nama: String, alasan: String) -> void:
	_blokir += 1
	print("BLOKIR: %s — %s" % [nama, alasan])


func _tunggu_sampai(kondisi: Callable, detik: float, label: String) -> bool:
	var langkah := 0.5
	var sudah := 0.0
	while sudah < detik:
		if kondisi.call():
			return true
		await get_tree().create_timer(langkah).timeout
		sudah += langkah
	print("[MP-WEB-TEST] timeout %s detik menunggu: %s" % [str(detik), label])
	return false


func _avatar_sendiri() -> Node:
	if _main._players == null:
		return null
	return _main._players.get_node_or_null(str(_peer_saya))


func _avatar_peer() -> Node:
	if _main._players == null:
		return null
	for c in _main._players.get_children():
		if String(c.name) != str(_peer_saya):
			return c
	return null


func _arg(nama: String, default: String) -> String:
	var args := OS.get_cmdline_user_args()
	var i := args.find(nama)
	if i >= 0 and i + 1 < args.size():
		return String(args[i + 1])
	return default


func _ready() -> void:
	var ig := _arg("--mp-web-ig", "test_mp_putra")
	var nama := _arg("--mp-web-nama", "Tes MP Putra")
	var jk := _arg("--mp-web-jk", "putra")
	var id_santri := _arg("--mp-web-id", "PV-0004")
	print("[MP-WEB-TEST] mulai sebagai %s (%s, %s) — TANPA flag --mp-join/--mp-ticket" % [ig, nama, jk])
	_main = get_parent()
	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null:
		nm.bergabung_ditolak.connect(func(alasan: String) -> void: _ditolak_alasan = alasan)
	# TUNGGU Main selesai _ready (pola test_multiplayer_fase1.gd).
	var main_siap := await _tunggu_sampai(
		func() -> bool: return _main._players != null and _main._spawner != null and _main._ui != null and _main._player != null,
		180.0, "Main selesai _ready (Players/Spawner/UI/Player)")
	if not main_siap:
		print("[MP-WEB-TEST] GAGAL: Main tidak selesai _ready dalam 180 dtk — harness, bukan game")
		print("[MP-WEB-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	print("[MP-WEB-TEST] Main siap")

	# Simpan save asal — dipulihkan sebelum quit supaya tes ini tidak
	# mencemari tes lain (test_v2 pernah 13 gagal karena save tertinggal
	# test_mp_putri lalu auto-join MP).
	_save_awal = (_main._save as Dictionary).duplicate(true)

	# --- (a) tombol "Main Bersama" ada + terlihat saat offline ---
	var btn: Button = _main._ui._mp_gabung_btn
	_cek("(a) tombol Main Bersama ada di HUD", btn != null)
	if btn != null:
		_cek("(a2) tombol terlihat saat offline (status=%s)" % String(_main._mp_status), bool(btn.visible))
		_cek("(a3) teks tombol 'Main Bersama'", String(btn.text) == "Main Bersama")
	else:
		_cek_blokir("(a2/a3) tombol tidak ada — tidak bisa dicek", "ui.gd belum punya _mp_gabung_btn")

	# Simulasikan pemain kembali: save tersimpan, TANPA token sesi
	# (kondisi "Lanjut" / baru daftar — akar bug 18 Nov 2026).
	_main._save["id_santri"] = id_santri
	_main._save["nama"] = nama
	_main._save["ig_username"] = ig
	_main._save["jenis_kelamin"] = jk
	_main._session_token = ""
	print("[MP-WEB-TEST] save disiapkan (%s, token dikosongkan) — menekan tombol Main Bersama ..." % ig)

	# --- (b) tekan tombol -> status keluar dari "offline" ---
	if btn != null:
		btn.pressed.emit()
	var keluar_offline := await _tunggu_sampai(
		func() -> bool: return String(_main._mp_status) != "offline",
		30.0, "status keluar dari offline setelah tekan tombol")
	_cek("(b) tekan tombol Main Bersama -> status bukan offline (dapat %s)" % String(_main._mp_status), keluar_offline)
	if not keluar_offline:
		print("[MP-WEB-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return

	# Masuk dunia seperti pemain (alur normal: _mp_mulai di sini
	# no-op karena status sudah bukan offline).
	_main._masuk_pesantren("Tes alur web")
	for i in 3:
		await get_tree().process_frame

	# --- (c)+(d) online + token + avatar diadopsi ---
	var online := await _tunggu_sampai(
		func() -> bool: return String(_main._mp_status) == "online" or _ditolak_alasan != "",
		120.0, "status online")
	_peer_saya = multiplayer.get_unique_id()
	_cek("(d) status online (peer id %d)" % _peer_saya, online and String(_main._mp_status) == "online")
	if _ditolak_alasan != "":
		_cek_blokir("(d) server menolak", _ditolak_alasan)
	if not online:
		print("[MP-WEB-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	_cek("(c) login diam-diam mengisi token sesi", String(_main._session_token) != "")
	var diadopsi := await _tunggu_sampai(
		func() -> bool: return _main._mp_avatar_sendiri != null,
		15.0, "adopsi avatar sendiri jadi _player")
	_cek("(d2) avatar sendiri diadopsi main.gd (kamera mengikuti)", diadopsi)
	var status_ui := String(_main._ui._mp_status_label.text) if _main._ui._mp_status_label != null else "?"
	_cek("(d3) UI status Online", status_ui.begins_with("Online"))
	if btn != null:
		_cek("(d4) tombol Main Bersama sembunyi saat online", not bool(btn.visible))

	# --- (e) avatar peer terlihat ---
	var _tunggu_e := await _tunggu_sampai(
		func() -> bool: return _avatar_peer() != null,
		60.0, "avatar peer di Players")
	var peer := _avatar_peer() as Node3D
	if peer != null:
		var nama_peer: String = _main._mp_nama_avatar(peer)
		print("[MP-WEB-TEST] (e) avatar peer terlihat: peer=%s nama=%s pos=%s" % [String(peer.name), nama_peer, str(peer.global_position)])
		_cek("(e) avatar peer terlihat di Players", true)
		_cek("(e2) nama peer dari spawn DB (bukan default/kosong)", nama_peer != "" and nama_peer != "Santri")
	else:
		_cek_blokir("(e) avatar peer terlihat", "tidak ada anak Players lain — klien kedua mungkin belum jalan")

	print("[MP-WEB-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
	_pulihkan_save()
	get_tree().quit(0 if _gagal == 0 and _blokir == 0 else 1)
