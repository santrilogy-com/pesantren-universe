extends Node
## Tes headless Multiplayer Fase 1 (Wira, 18 Nov 2026):
##   godot --headless --path . skrip/test_multiplayer_fase1.tscn -- \
##     --mp-join <url> --mp-ticket <tiket> [--mp-test-gerak | --mp-test-zona]
##
## STRUKTUR SCENE — opsi (a) (perbaikan harness 18 Nov 2026, Wira):
## Root scene ini = INSTANCE main.tscn (node bernama `Main`), dan
## driver tes ini (`TestDriver`) adalah ANAK di bawah Main. Alasannya:
## replikasi spawn Godot menyelesaikan spawner BERDASARKAN PATH dari
## scene root — server VPS menjalankan main.tscn langsung, jadi path
## spawner di server = `Main/MultiplayerSpawner`. Struktur LAMA (root
## `TestMultiplayerFase1` + Main di-instance sebagai anak) membuat
## path klien = `TestMultiplayerFase1/Main/MultiplayerSpawner`, sehingga
## spawn server tidak bisa di-resolve klien: `Node not found:
## "Main/MultiplayerSpawner" (relative to "/root")` + `ID 1 not found
## in cache of peer 1` + `spawner is null` (log 18 Nov). Dengan root =
## Main, path klien IDENTIK dengan server. Bonus: NetworkManager
## mencari spawner/Players lewat `get_tree().current_scene` — yang
## dulu `TestMultiplayerFase1` (salah), kini `Main` (benar).
## Opsi (b) (driver ditambahkan main.gd saat argumen --mp-test-*)
## DITOLAK: menyentuh main.gd (kode game) padahal perbaikan ini murni
## harness — .tscn + .gd ini saja yang berubah.
##
## URUTAN _ready (PENTING): _ready anak jalan SEBELUM _ready parent,
## jadi _ready driver ini jalan SEBELUM _ready Main selesai (Main
## membangun dunia ~58 dtk di VM). Driver TIDAK BOLEH mengasumsikan
## Main siap — ia MENUNGGU via polling (_players/_spawner/_ui/_player
## != null, timeout 180 dtk) sebelum memanggil _masuk_pesantren().
## Await pertama di _ready driver mengembalikan kontrol, _ready Main
## lalu jalan sinkron sampai selesai, baru frame berjalan dan timer
## polling berdetak — jadi polling melihat Main siap di cek pertama
## setelah frame pertama.
##
## Dijalankan skrip/test_smoke_multiplayer.sh mode fase1 (2 klien:
## klien 1 putra + --mp-test-gerak + --mp-test-zona, klien 2 putri
## sebagai pengamat). Tiket diperoleh skrip shell lewat REST publik
## (register/login santri tes -> POST /api/santri/realtime_ticket) —
## JANGAN pakai X-PV-Token di sisi klien.
##
## Kriteria yang dicek (dari log + keadaan):
##   (a) connected_to_server tanpa baris ERROR (cek ERROR di shell).
##   (b) server men-spawn avatar sendiri (anak Players bernama
##       str(peer id sendiri)) + diadopsi main.gd jadi _player.
##   (c) avatar peer terlihat (anak Players lain) + nama dari DB.
##   (d) gerak tersinkron: klien --mp-test-gerak jalan maju; klien
##       pengamat mencatat posisi avatar peer tiap detik — penyebaran
##       posisi > 1 m = peer bergerak terlihat.
##   (e) zona ditolak server: klien --mp-test-zona (putra) dipaksa ke
##       area putri (140,0,0) — di dalam persegi kampus putri
##       (x 115..216, z -70..+40) — dengan validasi klien MATI —
##       lolos HANYA bila _mp_zone_reject_diterima (zone_reject
##       server) + snap-back. (20,0,0) TIDAK dipakai: penyangga
##       14 ≤ x < 115 dipakai bersama (keputusan Dimas 18 Nov),
##       jadi (20,0,0) LEGAL untuk putra dan server dengan benar
##       tidak akan menolaknya.
##
## BLOKIR (bukan GAGAL): NetworkManager.spawn_player / submit_ticket /
## synchronizer (Saka/Bara) belum ada, jadi (b)-(e) belum BISA lolos —
## tes mencatat BLOKIR + alasan, bukan memalsukan lolos. Exit 0 =
## semua lolos; bukan-nol = ada gagal/blokir (lihat ringkasan).

var _main: Node
var _lulus := 0
var _gagal := 0
var _blokir := 0
var _mode_gerak := false
var _mode_zona := false
var _peer_saya := 0
# Alasan penolakan server (sinyal NetworkManager.bergabung_ditolak) —
# supaya BLOKIR menyebut sebab sebenarnya (mis. "server belum
# dikonfigurasi" karena PV_TOKEN tidak ada di VM ini), bukan tebakan.
var _ditolak_alasan := ""


func _alasan_blokir_spawn() -> String:
	if _ditolak_alasan != "":
		return "server menolak: " + _ditolak_alasan + " (validasi tiket hanya mungkin di VPS — PV_TOKEN + API 127.0.0.1:8790)"
	return "NetworkManager.spawn_player / submit_ticket belum jalan (menunggu Saka)"


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
	print("[MP-TEST] timeout %s detik menunggu: %s" % [str(detik), label])
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


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	_mode_gerak = "--mp-test-gerak" in args
	_mode_zona = "--mp-test-zona" in args
	print("[MP-TEST] mulai (gerak=%s, zona=%s)" % [str(_mode_gerak), str(_mode_zona)])
	# Main = parent (scene root = instance main.tscn — lihat header).
	_main = get_parent()
	# Tangkap alasan penolakan server (bila ada) supaya BLOKIR presisi.
	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null:
		nm.bergabung_ditolak.connect(func(alasan: String) -> void: _ditolak_alasan = alasan)
	# TUNGGU Main selesai _ready: _ready anak jalan SEBELUM _ready
	# parent, jadi di titik ini _players/_spawner/_ui/_player Main
	# masih null. _players dipasang di AKHIR _ready Main
	# (_mp_pasang_players), jadi _players != null == Main siap.
	# Timeout 180 dtk (_ready Main ~58 dtk di VM ini).
	var main_siap := await _tunggu_sampai(
		func() -> bool: return _main._players != null and _main._spawner != null and _main._ui != null and _main._player != null,
		180.0, "Main selesai _ready (Players/Spawner/UI/Player)")
	if not main_siap:
		print("[MP-TEST] GAGAL: Main tidak selesai _ready dalam 180 dtk — harness, bukan game")
		print("[MP-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		get_tree().quit(1)
		return
	print("[MP-TEST] Main siap: path spawner=%s current_scene=%s" % [str(_main._spawner.get_path()), str(get_tree().current_scene.name)])
	# Masuk dunia seperti pemain (pola test_v2): memicu _mp_mulai().
	_main._masuk_pesantren("Tes MP Fase 1")
	for i in 3:
		await get_tree().process_frame

	# --- (a) connected_to_server ---
	var konek := await _tunggu_sampai(
		func() -> bool: return multiplayer.get_unique_id() != 0,
		120.0, "connected_to_server")
	_peer_saya = multiplayer.get_unique_id()
	_cek("(a) connected_to_server (peer id %d)" % _peer_saya, konek)
	if konek:
		print("[MP-TEST] (a) connected_to_server peer_id=%d" % _peer_saya)
	else:
		print("[MP-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		get_tree().quit(1)
		return

	# --- (b) avatar sendiri di-spawn server + diadopsi ---
	# Berhenti menunggu lebih awal bila server sudah menolak (tidak
	# akan ada avatar — jangan buang 60 dtk). PERHATIAN: tunggu bisa
	# berakhir karena DITOLAK, bukan karena avatar ada — karena itu
	# cabang sukses mengecek NODE-nya (bukan hasil tunggu), kalau
	# tidak av=null -> SCRIPT ERROR + _ready abort (kejadian run
	# 18 Nov ~10:00 WIB).
	var _tunggu_b := await _tunggu_sampai(
		func() -> bool: return _avatar_sendiri() != null or _ditolak_alasan != "",
		60.0, "avatar sendiri di Players")
	var av_sendiri := _avatar_sendiri() as Node3D
	if av_sendiri != null:
		print("[MP-TEST] (b) avatar sendiri spawn: peer=%s pos=%s" % [str(_peer_saya), str(av_sendiri.global_position)])
		_cek("(b) avatar sendiri di-spawn server (Players/%d)" % _peer_saya, true)
		var diadopsi := await _tunggu_sampai(
			func() -> bool: return _main._mp_avatar_sendiri != null,
			15.0, "adopsi avatar sendiri jadi _player")
		_cek("(b2) avatar sendiri diadopsi main.gd (kamera mengikuti)", diadopsi)
		if diadopsi:
			var status_ui := String(_main._ui._mp_status_label.text) if _main._ui._mp_status_label != null else "?"
			_cek("(b3) UI status Online", status_ui.begins_with("Online"))
	else:
		_cek_blokir("(b) avatar sendiri di-spawn server",
			"tidak muncul di Players — " + _alasan_blokir_spawn())

	# --- (c) avatar peer terlihat ---
	var _tunggu_c := await _tunggu_sampai(
		func() -> bool: return _avatar_peer() != null or _ditolak_alasan != "",
		60.0, "avatar peer di Players")
	var peer := _avatar_peer() as Node3D
	if peer != null:
		var nama_peer: String = _main._mp_nama_avatar(peer)
		print("[MP-TEST] (c) avatar peer terlihat: peer=%s nama=%s pos=%s" % [String(peer.name), nama_peer, str(peer.global_position)])
		_cek("(c) avatar peer terlihat di Players", true)
		# Nama default SantriPlayer = "Santri" — nama DB dari spawn
		# (mis. "Tes MP Putra") membuktikan data spawn mengalir.
		_cek("(c2) nama peer dari spawn DB (bukan default/kosong)", nama_peer != "" and nama_peer != "Santri")
	else:
		_cek_blokir("(c) avatar peer terlihat",
			"tidak ada anak Players lain — " + _alasan_blokir_spawn())

	# --- (d) gerak tersinkron ---
	if _mode_gerak:
		var av_gerak := _avatar_sendiri() as Node3D
		if av_gerak == null:
			_cek_blokir("(d) gerak sendiri", "avatar sendiri belum ada — tidak bisa jalan")
		else:
			var awal: Vector3 = av_gerak.global_position
			_main._ui._joystick.output = Vector2(0, -1)
			for i in 10:
				await get_tree().create_timer(1.0).timeout
				print("[MP-TEST] gerak saya pos=%s" % str((_avatar_sendiri() as Node3D).global_position))
			_main._ui._joystick.output = Vector2.ZERO
			var akhir: Vector3 = (_avatar_sendiri() as Node3D).global_position
			_cek("(d) gerak sendiri > 1 m (dapat %.2f m)" % awal.distance_to(akhir), awal.distance_to(akhir) > 1.0)
	else:
		# Pengamat: amati SEMUA peer non-diri, penyebaran MAKSIMUM.
		# Alasan (18 Nov, run fase1-wss pertama pasca-perbaikan path):
		# server mengirim spawn untuk peer BASI (1442226019 +
		# 1535575914 — avatar dari run lain, diam di titik spawn,
		# tidak pernah disconnect selama run) SEBELUM avatar klien
		# 1 — _avatar_peer() lama mengunci peer basi pertama, jadi
		# (d) gagal 0,00 m walau peer yang bergerak mungkin
		# tersinkron. Lolos bila ADA peer yang bergerak > 1 m.
		# Peer yang muncul di tengah pengamatan ikut dilacak (posisi
		# pertama terlihat = baseline-nya).
		var pos_awal := {}
		for c in _main._players.get_children():
			if String(c.name) != str(_peer_saya):
				pos_awal[String(c.name)] = (c as Node3D).global_position
		if pos_awal.is_empty():
			_cek_blokir("(d) peer bergerak terlihat", "avatar peer belum ada — tidak ada yang diamati")
		else:
			var jarak_maks := 0.0
			var peer_bergerak := ""
			for i in 12:
				await get_tree().create_timer(1.0).timeout
				for c in _main._players.get_children():
					var k := String(c.name)
					if k == str(_peer_saya):
						continue
					var pp: Vector3 = (c as Node3D).global_position
					if not pos_awal.has(k):
						pos_awal[k] = pp
						continue
					print("[MP-TEST] lihat peer %s pos=%s" % [k, str(pp)])
					var d := pp.distance_to(pos_awal[k])
					if d > jarak_maks:
						jarak_maks = d
						peer_bergerak = k
			_cek("(d) peer bergerak terlihat (posisi berubah %.2f m)" % jarak_maks, jarak_maks > 1.0)
			if jarak_maks > 1.0:
				print("[MP-TEST] (d) peer yang bergerak: %s" % peer_bergerak)

	# --- (e) zona ditolak server (hanya klien --mp-test-zona, putra) ---
	if _mode_zona:
		var av_zona := _avatar_sendiri() as Node3D
		if av_zona == null:
			_cek_blokir("(e) zona ditolak server", "avatar sendiri belum ada — tidak bisa dipaksa ke area putri")
		else:
			_main._mp_validasi_klien_mati = true
			_main._player.global_position = Vector3(140, 0, 0)
			_main._player.velocity = Vector3.ZERO
			print("[MP-TEST] zona: paksa ke area putri (140,0,0), validasi klien MATI — menunggu zone_reject server")
			var ditolak := false
			for i in 24:
				await get_tree().create_timer(0.5).timeout
				if _main._mp_zone_reject_diterima:
					ditolak = true
					break
			if ditolak:
				print("[MP-TEST] (e) zone_reject server diterima — snap-back ke %s" % str(_main._mp_zone_reject_pos))
				_cek("(e) zona ditolak server (zone_reject + snap-back)", true)
			else:
				var px: float = (_avatar_sendiri() as Node3D).global_position.x
				if px < 115.0:
					_cek("(e) zona ditolak server (zone_reject + snap-back)", false)
					print("[MP-TEST] (e) avatar kembali ke x<115 TANPA zone_reject — snap-back dari validasi klien, bukan server")
				else:
					_cek("(e) zona ditolak server (zone_reject + snap-back)", false)
					print("[MP-TEST] (e) avatar TETAP di area putri (x=%.1f) setelah 12 dtk — server tidak menolak" % px)

	print("[MP-TEST] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
	get_tree().quit(0 if _gagal == 0 and _blokir == 0 else 1)
