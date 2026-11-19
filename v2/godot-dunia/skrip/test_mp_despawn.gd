extends Node
## Tes despawn avatar — verifikasi perbaikan _hapus_avatar (Saka,
## 18 Nov 2026): queue_free(), BUKAN spawner.despawn() (method itu
## TIDAK ADA di Godot 4.7.2 — tiap disconnect melempar SCRIPT ERROR
## "Nonexistent function 'despawn'" dan avatar basi menumpuk 2->4->6
## di jurnal VPS).
##
## Harness ini menjalankan kode NetworkManager SUNGGUHAN, bukan
## tiruan: server memanggil nm._spawn_peer(id) (spawner.spawn ->
## NetworkManager.spawn_player -> RemotePlayer/SantriPlayer asli)
## dan penghapusan jalan lewat handler peer_disconnected NetworkManager
## sendiri (nm._on_peer_disconnected -> _hapus_avatar). Yang DILEWATI
## hanya validasi tiket: entri _pemain disuntik langsung karena
## PV_TOKEN tidak ada di VM ini, jadi mode fase1 penuh (tiket REST
## asli + validasi HTTP) tidak bisa jalan lokal — server fase1 akan
## menolak semua peer ("server belum dikonfigurasi"). Jalur yang
## diuji di sini (spawn + disconnect + hapus avatar + replikasi
## hapusan ke klien lain + tidak ada spawn basi untuk late joiner)
## adalah PERSIS jalur yang gagal di VPS.
##
## Cara pakai (dari godot-dunia; 4 proses, port 8791):
##   server:   godot --headless --path . skrip/test_mp_despawn.tscn -- --mp-host --despawn-role server
##   quitter:  godot --headless --path . skrip/test_mp_despawn.tscn -- --mp-join ws://127.0.0.1:8791 --despawn-role quitter --despawn-quit-after 4
##   observer: godot --headless --path . skrip/test_mp_despawn.tscn -- --mp-join ws://127.0.0.1:8791 --despawn-role observer
##   late:     godot --headless --path . skrip/test_mp_despawn.tscn -- --mp-join ws://127.0.0.1:8791 --despawn-role late
## Urutan: server dulu, quitter + observer ~1 dtk kemudian, late
## ~6 dtk sesudah quitter mati. Server mencetak HASIL-DESPAN
## (LOLOS/GAGAL) + keluar sendiri ~12 dtk. CEK ERROR (grep
## "SCRIPT ERROR" di log server) tetap wajib dicek pelari tes.
##
## CATATAN WAKTU: peer tanpa tiket ditolak server sesudah 10 dtk
## (TICKET_TIMEOUT_SEC) — jadi seluruh tes harus selesai < 10 dtk
## sesudah observer connect; itulah kenapa late joiner masuk cepat
## dan server keluar di ~12 dtk.

var _role := "server"
var _quit_after := 4.0
var _players: Node = null
var _spawner: MultiplayerSpawner = null
var _nm: Node = null
var _t := 0.0
var _telah_cetak := {}
var _terhubung := {}
var _jumlah_sebelum := -1
var _sudah_nilai := false


func _role_arg() -> String:
	var args := OS.get_cmdline_user_args()
	if "--despawn-role" in args:
		return String(args[args.find("--despawn-role") + 1])
	return "server"


func _ready() -> void:
	_role = _role_arg()
	var args := OS.get_cmdline_user_args()
	if "--despawn-quit-after" in args:
		_quit_after = float(args[args.find("--despawn-quit-after") + 1])
	_nm = get_node_or_null("/root/NetworkManager")
	# Pasang Players + spawner PERSIS seperti main.gd
	# _mp_pasang_players (spawn_path ../Players, spawn_function =
	# NetworkManager.spawn_player) — supaya _cari_spawner() dan
	# _players_node() NetworkManager menemukan node ini lewat
	# get_tree().current_scene (scene ini = current_scene).
	_players = Node.new()
	_players.name = "Players"
	add_child(_players)
	_spawner = MultiplayerSpawner.new()
	_spawner.name = "MultiplayerSpawner"
	_spawner.spawn_path = ^"../Players"
	if _nm != null and _nm.has_method("spawn_player"):
		_spawner.spawn_function = Callable(_nm, "spawn_player")
	add_child(_spawner)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	print("[MP-DESPAN] mulai role=%s nm=%s" % [_role, str(_nm != null)])


func _on_connected_to_server() -> void:
	print("[MP-DESPAN] connected_to_server id=%d role=%s" % [multiplayer.get_unique_id(), _role])
	if _role == "quitter":
		# Tunggu sampai avatar sendiri muncul (spawn server), lalu
		# hitung mundur quit — supaya disconnect terjadi SESUDAH
		# avatar ada (kalau tidak, tidak ada yang diuji).
		await _tunggu_avatar_sendiri(10.0)
		print("[MP-DESPAN] quitter: avatar ada, mati dalam %.0f dtk" % _quit_after)
		await get_tree().create_timer(_quit_after).timeout
		print("[MP-DESPAN] quitter: quit (disconnect)")
		get_tree().quit()


func _tunggu_avatar_sendiri(detik: float) -> void:
	var sudah := 0.0
	while sudah < detik:
		if _players.get_node_or_null(str(multiplayer.get_unique_id())) != null:
			return
		await get_tree().create_timer(0.5).timeout
		sudah += 0.5


func _on_peer_connected(id: int) -> void:
	print("[MP-DESPAN] peer_connected %d (saya %d, server=%s) Players=%d" % [id, multiplayer.get_unique_id(), str(multiplayer.is_server()), _players.get_child_count()])
	if not multiplayer.is_server():
		return
	if _nm == null:
		return
	# Suntik entri _pemain PERSIS seperti _on_validasi_selesai
	# (melewati validasi tiket — lihat header). Tanpa ini _spawn_peer
	# menolak (return awal: not _pemain.has(peer_id)).
	var jk := "putri" if _terhubung.size() % 2 == 1 else "putra"
	var titik: Vector3 = RoomConfig.titik_spawn(jk)
	_nm._pemain[id] = {
		"nama": "Tes Despawn %d" % id,
		"jenis_kelamin": jk,
		"outfit": RoomConfig.outfit_untuk(jk),
		"pos_legal": titik,
		"pos_teramati": titik,
		"pertama": true,
		"melanggar": false,
		"tolak_terakhir": 0.0,
	}
	_terhubung[id] = true
	_nm._spawn_peer(id)
	print("[MP-DESPAN] spawn peer %d (%s) -> Players=%d" % [id, jk, _players.get_child_count()])


func _on_peer_disconnected(id: int) -> void:
	print("[MP-DESPAN] peer_disconnected %d (saya %d, server=%s) Players=%d" % [id, multiplayer.get_unique_id(), str(multiplayer.is_server()), _players.get_child_count()])
	if not multiplayer.is_server():
		return
	if _sudah_nilai:
		return
	# Handler NetworkManager jalan DULUAN (autoload connect lebih
	# awal) dan queue_free itu deferred — jadi hitung di sini masih
	# angka lama; nilai SESUDAH 1,5 dtk.
	_jumlah_sebelum = _players.get_child_count()
	_sudah_nilai = true
	await get_tree().create_timer(1.5).timeout
	var sesudah := _players.get_child_count()
	var nama: Array = []
	for c in _players.get_children():
		nama.append(String(c.name))
	if sesudah == _jumlah_sebelum - 1:
		print("[MP-DESPAN] HASIL-DESPAN: LOLOS — Players %d -> %d sesudah disconnect peer %d (anak=%s)" % [_jumlah_sebelum, sesudah, id, str(nama)])
	else:
		print("[MP-DESPAN] HASIL-DESPAN: GAGAL — Players %d -> %d sesudah disconnect peer %d (anak=%s, harusnya turun 1)" % [_jumlah_sebelum, sesudah, id, str(nama)])


func _process(delta: float) -> void:
	_t += delta
	var detik := int(_t)
	if not _telah_cetak.has(detik) and detik % 2 == 0 and detik > 0:
		_telah_cetak[detik] = true
		var nama: Array = []
		for c in _players.get_children():
			nama.append(String(c.name))
		print("[MP-DESPAN] t=%ds role=%s Players=%d anak=%s" % [detik, _role, _players.get_child_count(), str(nama)])
	# Server keluar sendiri supaya run shell selesai (lihat header
	# soal batas 10 dtk tiket).
	if _role == "server" and _t >= 12.0:
		print("[MP-DESPAN] server: selesai, quit")
		get_tree().quit()
	if _role == "observer" and _t >= 13.0:
		get_tree().quit()
	if _role == "late" and _t >= 8.0:
		get_tree().quit()
