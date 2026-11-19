extends Node
## NETWORK-MANAGER — otak multiplayer Fase 1 (Saka, 18 Nov 2026).
##
## Autoload (project.godot, sesudah MpBootstrap). TIDAK memakai
## class_name — nama autoload "NetworkManager" SUDAH menjadi akses
## global (class_name di sini hanya memicu warning "hides an autoload
## singleton"). SATU-SATUNYA file yang berisi @rpc Fase 1 — checksum RPC klien vs server dijamin
## sama karena kedua build memakai file ini dari commit yang sama
## (v2/export/build_multiplayer.sh). Bara memastikan remote_player.gd
## TIDAK berisi RPC; player.gd juga tidak (cek 18 Nov 2026).
##
## RPC FASE 1 (daftar persis — HARUS identik di build klien & server):
##   submit_ticket(ticket: String)   @rpc("any_peer", "reliable")
##       klien -> server. Handshake sesudah connected_to_server.
##   zone_reject(pos_legal: Vector3) @rpc("any_peer", "reliable")
##       server -> klien pemilik. Posisi ditolak, snap-back.
##   join_rejected(alasan: String)   @rpc("any_peer", "reliable")
##       server -> klien. Penolakan bergabung ("ruangan penuh" /
##       "tiket tidak valid"); disconnect menyusul 0,5 dtk kemudian.
##   ajak_salaman(dari_peer: int, nama: String) @rpc("any_peer", "reliable")
##       peer -> peer (Raka, 20 Nov 2026). Ajakan salaman pemain ke
##       pemain lain — routing lewat server, dieksekusi HANYA di peer
##       target (rpc_id); server tidak ikut bermain pose.
##
## ALUR (klien):
##   main.gd _mp_mulai() -> _mp_minta_tiket() (REST, async) ->
##   hubungkan(url) -> MpBootstrap join (WebSocket + retry) ->
##   connected_to_server -> consume_ticket() SEKALI ->
##   submit_ticket.rpc_id(1, tiket). Tiket TIDAK PERNAH ditulis ke log.
##   (Tiket bisa belum ada saat connected_to_server — HTTP tiket bisa
##   kalah cepat dari handshake — jadi pengiriman menunggu sampai 8
##   detik; server menutup peer tanpa tiket setelah 10 detik.)
##
## ALUR (server, peer id 1):
##   peer_connected -> cap (RoomConfig.MAX_PLAYERS_PER_ROOM, dihitung
##   dari pemain tervalidasi + peer yang menunggu tiket) -> tunggu
##   tiket (10 dtk) -> submit_ticket -> validasi HTTP POST ke API
##   (X-PV-Token dari ENVIRONMENT PV_TOKEN, JANGAN PERNAH di-hardcode)
##   -> 200 {"id","nama","jenis_kelamin"} dari DB adalah SATU-SATUNYA
##   identitas; outfit dari RoomConfig.outfit_untuk(jenis_kelamin) ->
##   spawner.spawn(data) -> avatar di Players.
##   Tanpa tiket valid -> join_rejected + disconnect_peer.
##   peer_disconnected -> hapus avatar (queue_free di server ->
##   spawner mereplikasi hapusan ke semua klien).
##
## KONTRAK DENGAN main.gd (Wira — JANGAN diubah sepihak):
## - spawn_function spawner = NetworkManager.spawn_player (main.gd
##   _mp_pasang_players mengikat Callable ini; spawn_function() di
##   bawah hanya alias nama dari brief awal).
## - hubungkan(url) dipanggil main.gd _mp_mulai().
## - zone_reject memanggil main._mp_terapkan_zone_reject(pos_legal)
##   (snap-back pola main.gd: global_position + velocity = ZERO +
##   _pos_legal_terakhir); bila Main tidak ada (scene tes headless),
##   fallback snap avatar sendiri langsung.
## - Spawner dicari malas (lazy) dari scene Main — main.gd _ready
##   membangun dunia ~58 dtk, jadi spawner belum ada saat peer
##   pertama connect; peer tervalidasi diantre di _menunggu_spawn.
##
## VALIDASI POSISI SERVER (otoritatif, tiap 0,1 dtk, hanya di luar
## interior): langkah antar sampel > 2,0 m (= teleport / >6 m/s
## dengan slack fase replikasi) ATAU posisi di zona larangan ->
## zone_reject(pos_legal) + salinan server dikembalikan ke legal.
## Teleport SAH yang dilewati: masuk/keluar interior (z < -200,
## semua interior di z ~ -295..-300) dan reset ke titik spawn.
## Batasan jujur Fase 1: klien yang MENGABAIKAN zone_reject tetap
## terlihat di posisi ilegal oleh pemain lain sampai ia patuh
## (synchronizer client-authoritative) — kick sesudah N penolakan
## adalah pengerasan Fase 2, bukan di sini.
##
## MODE OFFLINE: tanpa --mp-host / --mp-join, autoload ini diam —
## game jalan seperti sekarang. Tanpa NetworkManager pun main.gd
## tetap jalan (semua pemakaian di sana dijaga null-check).

## URL validasi tiket (API di VPS yang sama — hanya dijangkau proses
## server realtime; klien TIDAK PERNAH memanggil URL ini).
const VALIDATE_URL := "http://127.0.0.1:8790/api/santri/realtime_ticket/validate"

## Sinyal untuk UI (main.gd/ui.gd — Wira). NetworkManager TIDAK
## memanggil UI langsung; yang butuh tampil memakai sinyal ini.
## (Pengecualian: zone_reject memanggil _mp_terapkan_zone_reject —
## itu seam snap-back main.gd, bukan UI.)
signal pemain_bergabung(peer_id: int, nama: String)
signal pemain_keluar(peer_id: int)
signal bergabung_ditolak(alasan: String)
signal zona_ditolak(pos_legal: Vector3)
signal koneksi_gagal()
signal terputus_dari_server()
## Salaman pemain -> pemain (Raka, 20 Nov 2026): ajakan salaman masuk
## dari peer lain — main.gd yang memutuskan menerima atau tidak
## (jarak + tidak sholat/belajar/tes + cooldown).
signal salaman_diajak(dari_peer: int, nama: String)

## peer_id -> {"deadline": float, "memvalidasi": bool}
var _tiket_menunggu: Dictionary = {}
## peer_id -> {"nama": String, "jenis_kelamin": String,
##             "outfit": Dictionary, "pos_legal": Vector3,
##             "pos_teramati": Vector3, "pertama": bool,
##             "melanggar": bool, "tolak_terakhir": float}
var _pemain: Dictionary = {}
## Peer tervalidasi yang avatarnya belum bisa di-spawn karena
## spawner (main.gd _mp_pasang_players) belum ada.
var _menunggu_spawn: Array[int] = []
var _spawner: MultiplayerSpawner = null
var _menghubungkan: bool = false
var _tiket_terkirim: bool = false
var _validasi_t: float = 0.0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	# Sinyal connected bisa sudah lewat sebelum handler terpasang
	# (pola yang sama dipakai main.gd _mp_pasang_players). Guard
	# is_server(): di server, unique_id == 1 dan peer-nya juga
	# WebSocket — JANGAN kira itu "sudah connect sebagai klien".
	if not multiplayer.is_server() and multiplayer.multiplayer_peer is WebSocketMultiplayerPeer and multiplayer.get_unique_id() != 0:
		_on_connected_to_server()


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_validasi_t += delta
	if _validasi_t < RoomConfig.VALIDATION_INTERVAL_SEC:
		return
	_validasi_t = 0.0
	_cek_tiket_timeout()
	_coba_spawn_tertunda()
	_validasi_posisi()


## ------------------------------------------------------------------
## Klien: gabung (dipanggil main.gd _mp_mulai).
## ------------------------------------------------------------------

## Gabung ke server realtime. Tiket sudah disiapkan pemanggil via
## MpBootstrap.set_ticket() (main.gd _mp_minta_tiket, atau
## --mp-ticket di CLI). Koneksi dikerjakan MpBootstrap (WebSocket +
## retry); file ini hanya memicu + menangani handshake tiket.
func hubungkan(url: String) -> void:
	if _menghubungkan:
		return
	# JANGAN pakai get_unique_id() != 0 sendirian sebagai "sudah terhubung":
	# saat offline (tanpa peer) Godot mengembalikan 1, sehingga guard lama
	# selalu keluar lebih awal dan WebSocket TIDAK PERNAH dicoba — inilah
	# akar utama "Belum bisa main multiplayer" dari game web (temuan Dimas,
	# 18 Nov 2026: tes 2 klien stuck "menghubungkan", jurnal server kosong,
	# tidak ada baris "joining"). "Sudah terhubung" = peer WebSocket ADA
	# dan status koneksinya CONNECTED (bukan sekadar id != 0).
	if multiplayer.multiplayer_peer is WebSocketMultiplayerPeer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		return  # sudah terhubung
	var bs := _mp_bootstrap()
	if bs == null or not bs.has_method("_join"):
		push_error("[MP] MpBootstrap tidak ada — tidak bisa hubungkan")
		return
	_menghubungkan = true
	bs._join(url)


## Cari MpBootstrap (autoload Fase 0) bila ada — pemegang tiket.
## Pola yang sama dipakai main.gd _mp_bootstrap(): akses lewat path
## node, bukan identifier global (identifier autoload tidak dikenali
## --check-only --script).
func _mp_bootstrap() -> Node:
	return get_node_or_null("/root/MpBootstrap")


## ------------------------------------------------------------------
## Spawn (dipakai MultiplayerSpawner di SEMUA peer).
## ------------------------------------------------------------------

## spawn_function MultiplayerSpawner (Wira: main.gd _mp_pasang_players
## mengikat Callable(NetworkManager, "spawn_player")).
## Dipanggil spawner di SEMUA peer dengan data yang sama — jadi nama
## node (= peer id) dan visual identik di server + semua klien.
## data = {"peer_id": int, "nama": String, "jenis_kelamin": String,
##         "outfit": Dictionary} — SEMUA dari DB (server), bukan klien.
func spawn_player(data: Dictionary) -> Node:
	var peer_id := int(data.get("peer_id", 0))
	var nama := String(data.get("nama", "Santri"))
	var jenis_kelamin := String(data.get("jenis_kelamin", "putra"))
	var outfit := (data.get("outfit", {}) as Dictionary).duplicate()
	var titik: Vector3 = RoomConfig.titik_spawn(jenis_kelamin)
	if peer_id == multiplayer.get_unique_id():
		# Avatar sendiri — SantriPlayer (player.gd, Jaka).
		var lokal := SantriPlayer.new()
		lokal.name = str(peer_id)
		lokal.set_multiplayer_authority(peer_id)
		# KAPSUL FISIKA (Saka, 18 Nov 2026 — run 3): SantriPlayer
		# TIDAK membawa CollisionShape3D sendiri; kapsul hanya
		# dibuat main.gd _ready untuk avatar offline (radius 0,35,
		# tinggi 1,7, pusat y 0,85; floor_snap_length 0,3). Tanpa
		# kapsul, avatar MP ini is_on_floor() selalu false ->
		# gravitasi (GRAVITY 20) menariknya jatuh menembus tanah,
		# lalu jaring pengaman main.gd (y < -5) me-respawn — y
		# berosilasi 0 -> ~-4 -> 0 tiap ~15 dtk di log klien.
		# Maka kapsul dipasang di sini dengan parameter YANG SAMA
		# seperti main.gd:541-551. CATATAN FASE 2: sumber kebenaran
		# kapsul sebaiknya pindah ke SantriPlayer._ready (Jaka)
		# supaya offline + MP tidak menduplikasi angka ini; main.gd
		# _player_capsule juga masih menunjuk kapsul offline (bukan
		# kapsul ini) — duduk di mode MP belum mengecilkan kapsul.
		var bentuk := CollisionShape3D.new()
		var kapsul := CapsuleShape3D.new()
		kapsul.radius = 0.35
		kapsul.height = 1.7
		bentuk.shape = kapsul
		bentuk.position = Vector3(0, 0.85, 0)
		lokal.add_child(bentuk)
		lokal.floor_snap_length = 0.3
		# _nama diset SEBELUM masuk tree supaya _ready() membangun
		# visual dengan nama DB yang benar (set_nama_spawn butuh
		# _visual — hanya ada sesudah _ready — jadi jangan dipanggil
		# di sini).
		lokal._nama = nama
		lokal.position = titik
		# HADAP (Raka, 18 Nov 2026 — bug "player jalannya mundur",
		# laporan Mas 16:11 WIB): JANGAN set node rotation.y di sini.
		# Hadap avatar lokal HANYA dari _visual.rotation.y (set_facing
		# + lerp hadap di _physics_process, player.gd) — persis seperti
		# avatar offline (node rotation.y = 0). Baris lama
		# `lokal.rotation.y = SPAWN_YAW_RAD (PI)` + visual PI =
		# yaw dunia 2PI = 0: wajah menghadap kamera (selatan)
		# sementara badan bergerak ke utara — pemain jalan mundur
		# (di layar sendiri; klien lain melihatnya benar karena
		# sync_yaw = _visual.rotation.y). Terbukti tes
		# test_jalan_mundur Bagian D (dot wajah·kecepatan -0,976,
		# kaki mundur -3,06 m/dtk). sync_yaw di bawah TETAP PI:
		# itu nilai replikasi untuk RemotePlayer di klien lain
		# (node rotation.y = hadap di sana, visual selalu 0).
		if "sync_position" in lokal:
			lokal.set("sync_position", titik)
		if "sync_yaw" in lokal:
			lokal.set("sync_yaw", RoomConfig.SPAWN_YAW_RAD)
		# _ready() membangun visual DEFAULT (OUTFIT_DEFAULT); bangun
		# ulang dengan outfit DB begitu node masuk tree (deferred =
		# jalan sesudah spawner add_child + _ready). Tanpa ini
		# santriwati tampil koko+songkok, bukan abaya+hijab.
		# (Bila refactor Jaka nanti menyediakan seam outfit
		# pra-_ready, deferred ini tetap benar — hanya jadi redundan.)
		lokal.call_deferred("bangun_ulang_visual", outfit)
		# Hadap awal = PI (menghadap Surau/utara, seperti avatar
		# offline sesudah _teleport_player). Dijalankan deferred
		# SETELAH bangun_ulang_visual (antrean deferred berurutan)
		# karena bangun ulang mengganti _visual baru (rotation 0) —
		# tanpa ini avatar MP berdiri menghadap kamera (+Z) sampai
		# pertama kali jalan. set_facing menulis _visual.rotation.y.
		lokal.call_deferred("set_facing", RoomConfig.SPAWN_YAW_RAD)
		print("[MP] spawn avatar sendiri (peer %d, %s, %s) di %s" % [peer_id, nama, jenis_kelamin, str(titik)])
		return lokal
	# Avatar pemain lain — RemotePlayer (Bara).
	var remote := RemotePlayer.dari_data_spawn(data)
	# Bara: WAJIB set BOTH position DAN sync_position ke titik spawn
	# — kalau hanya position, frame pertama avatar remote lerp balik
	# ke sync_position (0,0,0). Titik dari kode dunia:
	# putra PesantrenBuilder.SPAWN (-4,0,14),
	# putri KampusPutri.SPAWN_PUTRI (140,0,16) — angka prep doc
	# §1.4 (130,14) BASI, jangan dipakai.
	remote.position = titik
	remote.sync_position = titik
	remote.rotation.y = RoomConfig.SPAWN_YAW_RAD
	remote.sync_yaw = RoomConfig.SPAWN_YAW_RAD
	print("[MP] spawn avatar peer %d (%s, %s) di %s" % [peer_id, nama, jenis_kelamin, str(titik)])
	return remote


## Alias nama dari brief awal (spawn_function) — implementasi sama.
## Spawner Wira memakai spawn_player; alias ini supaya kedua nama
## kontrak tetap ada.
func spawn_function(data: Dictionary) -> Node:
	return spawn_player(data)


## Serahkan spawner secara eksplisit (dipakai bila ada yang
## memasangnya manual). Jalur utama: main.gd mengikat spawn_function
## sendiri + NetworkManager menemukannya malas via _cari_spawner().
func bind_spawner(spawner: MultiplayerSpawner) -> void:
	_spawner = spawner
	if spawner.spawn_function.is_null():
		spawner.spawn_function = Callable(self, "spawn_player")
	_coba_spawn_tertunda()


## ------------------------------------------------------------------
## Handshake tiket (klien -> server).
## ------------------------------------------------------------------

func _on_connected_to_server() -> void:
	if multiplayer.is_server():
		return
	_menghubungkan = false
	_tiket_terkirim = false
	print("[MP] connected_to_server (peer id saya: %d)" % multiplayer.get_unique_id())
	_kirim_tiket_saat_siap()


## Kirim tiket SEKALI ke server. Tiket bisa belum ada saat
## connected_to_server (alur UI: _mp_mulai meminta tiket REST lalu
## langsung hubungkan — HTTP tiket bisa kalah cepat dari handshake
## WebSocket). Karena itu tunggu sampai 8 detik (server menutup peer
## tanpa tiket setelah 10 detik) sebelum menyerah. Tiket TIDAK PERNAH
## ditulis ke log.
func _kirim_tiket_saat_siap() -> void:
	var bs := _mp_bootstrap()
	if bs == null or not bs.has_method("consume_ticket"):
		print("[MP] MpBootstrap tidak ada — tiket tidak bisa dikirim")
		return
	var tunggu := 0.0
	while tunggu < 8.0:
		if _tiket_terkirim:
			return
		if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
			return
		var tiket := String(bs.consume_ticket())
		if tiket != "":
			submit_ticket.rpc_id(1, tiket)
			_tiket_terkirim = true
			print("[MP] tiket realtime dikirim ke server (nilai disembunyikan)")
			return
		await get_tree().create_timer(0.25).timeout
		tunggu += 0.25
	# Menyerah menunggu — kirim string kosong supaya server menolak
	# cepat dengan alasan jelas, bukan menunggu timeout 10 detik.
	if multiplayer.multiplayer_peer != null and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		submit_ticket.rpc_id(1, "")
		_tiket_terkirim = true
		print("[MP] tidak ada tiket realtime saat handshake — dikirim kosong, server akan menolak")


## Handshake tiket (klien -> server). Hanya server yang memproses.
@rpc("any_peer", "reliable")
func submit_ticket(ticket: String) -> void:
	if not multiplayer.is_server():
		return
	var pengirim := multiplayer.get_remote_sender_id()
	if pengirim <= 1:
		return
	if not _tiket_menunggu.has(pengirim):
		print("[MP] tiket dari peer %d diabaikan (tidak menunggu tiket)" % pengirim)
		return
	var info: Dictionary = _tiket_menunggu[pengirim]
	if bool(info["memvalidasi"]):
		return  # tiket sekali pakai — pengiriman kedua diabaikan
	info["memvalidasi"] = true
	print("[MP] tiket diterima dari peer %d (nilai disembunyikan) — memvalidasi ..." % pengirim)
	_validasi_tiket(pengirim, ticket)


## Validasi tiket ke API (server saja). Token dibaca dari ENVIRONMENT
## PV_TOKEN — JANGAN PERNAH di-hardcode ke file mana pun.
func _validasi_tiket(peer_id: int, ticket: String) -> void:
	if ticket == "":
		_tolak_peer(peer_id, "tiket tidak valid")
		return
	var token := OS.get_environment("PV_TOKEN")
	if token == "":
		# print (BUKAN push_error): tanpa PV_TOKEN adalah keadaan
		# yang DIHARAPKAN di run tes lokal (validasi tiket hanya
		# mungkin di VPS — lihat test_multiplayer_fase1.gd), dan
		# baris "ERROR:" akan menggagalkan CEK ERROR smoke test.
		# Peer tetap ditolak dengan alasan yang jelas.
		print("[MP] PV_TOKEN tidak ada di environment server — validasi tiket tidak mungkin; peer %d ditolak" % peer_id)
		_tolak_peer(peer_id, "server belum dikonfigurasi")
		return
	var http := HTTPRequest.new()
	http.timeout = RoomConfig.VALIDATE_TIMEOUT_SEC
	add_child(http)
	http.request_completed.connect(_on_validasi_selesai.bind(peer_id, http))
	var headers: PackedStringArray = ["Content-Type: application/json", "X-PV-Token: " + token]
	var body := JSON.stringify({"ticket": ticket})
	var err := http.request(VALIDATE_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
		push_error("[MP] gagal meminta validasi tiket (peer %d): %s" % [peer_id, error_string(err)])
		_tolak_peer(peer_id, "validasi tiket gagal")


func _on_validasi_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, peer_id: int, http: HTTPRequest) -> void:
	if is_instance_valid(http):
		http.queue_free()
	if not _tiket_menunggu.has(peer_id):
		return  # peer sudah pergi selama validasi
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[MP] validasi tiket peer %d gagal (result=%d, http=%d)" % [peer_id, result, response_code])
		_tolak_peer(peer_id, "tiket tidak valid")
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary) or not bool((parsed as Dictionary).get("ok", false)):
		_tolak_peer(peer_id, "tiket tidak valid")
		return
	var d: Dictionary = parsed
	var sid := String(d.get("id", ""))
	var nama := String(d.get("nama", ""))
	var jenis_kelamin := String(d.get("jenis_kelamin", "putra"))
	if sid == "" or nama == "":
		_tolak_peer(peer_id, "tiket tidak valid")
		return
	_tiket_menunggu.erase(peer_id)
	var titik: Vector3 = RoomConfig.titik_spawn(jenis_kelamin)
	_pemain[peer_id] = {
		"nama": nama,
		"jenis_kelamin": jenis_kelamin,
		"outfit": RoomConfig.outfit_untuk(jenis_kelamin),
		"pos_legal": titik,
		"pos_teramati": titik,
		"pertama": true,
		"melanggar": false,
		"tolak_terakhir": 0.0,
	}
	print("[MP] tiket peer %d valid — %s (%s, %s)" % [peer_id, sid, nama, jenis_kelamin])
	_spawn_peer(peer_id)


## ------------------------------------------------------------------
## Server: connect / disconnect / cap / penolakan.
## ------------------------------------------------------------------

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	# Cap dihitung dari pemain tervalidasi + peer yang menunggu tiket
	# (supaya peer ke-9 tidak bisa "mengantre" melewati cap).
	var jumlah := _pemain.size() + _tiket_menunggu.size()
	if jumlah >= RoomConfig.MAX_PLAYERS_PER_ROOM:
		print("[MP] ruangan penuh (%d/%d) — peer %d ditolak" % [jumlah, RoomConfig.MAX_PLAYERS_PER_ROOM, id])
		_tolak_peer(id, "ruangan penuh")
		return
	_tiket_menunggu[id] = {
		"deadline": Time.get_ticks_msec() / 1000.0 + RoomConfig.TICKET_TIMEOUT_SEC,
		"memvalidasi": false,
	}
	print("[MP] peer_connected %d — menunggu tiket (batas %d dtk)" % [id, RoomConfig.TICKET_TIMEOUT_SEC])


func _on_peer_disconnected(id: int) -> void:
	_tiket_menunggu.erase(id)
	if _pemain.has(id):
		_pemain.erase(id)
		print("[MP] pemain %d keluar" % id)
		pemain_keluar.emit(id)
	_menunggu_spawn.erase(id)
	if multiplayer.is_server():
		# queue_free di server; spawner mereplikasi hapusan ke
		# semua klien (lihat _hapus_avatar — despawn() tidak ada).
		_hapus_avatar(id)


func _on_connection_failed() -> void:
	_menghubungkan = false
	# Pesan dibedakan dari main.gd _mp_saat_connection_failed (teks
	# sama persis = baris ganda di log saat keduanya jalan).
	print("[MP] connection_failed (network_manager) — tetap offline")
	koneksi_gagal.emit()


func _on_server_disconnected() -> void:
	_menghubungkan = false
	_tiket_terkirim = false
	print("[MP] server_disconnected")
	terputus_dari_server.emit()


## Putuskan peer yang tidak mengirim tiket tepat waktu.
func _cek_tiket_timeout() -> void:
	var sekarang := Time.get_ticks_msec() / 1000.0
	var kedaluwarsa: Array[int] = []
	for peer_id in _tiket_menunggu.keys():
		var info: Dictionary = _tiket_menunggu[peer_id]
		if bool(info["memvalidasi"]):
			continue  # sedang divalidasi HTTP — jangan diputus
		if sekarang > float(info["deadline"]):
			kedaluwarsa.append(int(peer_id))
	for peer_id in kedaluwarsa:
		print("[MP] peer %d tidak mengirim tiket tepat waktu" % peer_id)
		_tolak_peer(peer_id, "tiket tidak valid")


## Tolak peer: kirim alasan dulu (RPC), lalu putuskan koneksi
## sesudah jeda singkat supaya RPC sempat terkirim.
func _tolak_peer(peer_id: int, alasan: String) -> void:
	var masih_menunggu := _tiket_menunggu.has(peer_id)
	var masih_pemain := _pemain.has(peer_id)
	_tiket_menunggu.erase(peer_id)
	_pemain.erase(peer_id)
	_menunggu_spawn.erase(peer_id)
	if masih_pemain:
		_hapus_avatar(peer_id)
	if not (masih_menunggu or masih_pemain):
		return
	if multiplayer.get_peers().has(peer_id):
		join_rejected.rpc_id(peer_id, alasan)
		print("[MP] peer %d ditolak: %s" % [peer_id, alasan])
		get_tree().create_timer(0.5).timeout.connect(_putuskan_peer.bind(peer_id))


func _putuskan_peer(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.multiplayer_peer == null:
		return
	if multiplayer.get_peers().has(peer_id):
		multiplayer.multiplayer_peer.disconnect_peer(peer_id)
		print("[MP] koneksi peer %d diputus" % peer_id)


## Server -> klien: penolakan bergabung (ruangan penuh / tiket tidak
## valid). Klien hanya menampilkan alasan; disconnect menyusul dari
## server (0,5 dtk).
@rpc("any_peer", "reliable")
func join_rejected(alasan: String) -> void:
	if multiplayer.get_remote_sender_id() != 1:
		return
	if multiplayer.is_server():
		return
	print("[MP] bergabung ditolak server: %s" % alasan)
	bergabung_ditolak.emit(alasan)


## Salaman pemain -> pemain (Raka, 20 Nov 2026). Dipanggil main.gd
## _on_aksi("salaman") saat target terdekat adalah pemain lain.
## rpc_id ke peer target — server hanya merutekan, tidak mengeksekusi.
func kirim_ajak_salaman(peer_target: int, nama_pengirim: String) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if peer_target <= 0 or peer_target == multiplayer.get_unique_id():
		return
	ajak_salaman.rpc_id(peer_target, multiplayer.get_unique_id(), nama_pengirim)


## Peer -> peer: ajakan salaman masuk. Server ikut punya method ini
## (kode sama) tapi tidak pernah jadi target rpc_id — yang mengeksekusi
## hanya klien target. Server mengabaikan bila entah bagaimana sampai.
@rpc("any_peer", "reliable")
func ajak_salaman(dari_peer: int, nama: String) -> void:
	if multiplayer.is_server():
		return
	salaman_diajak.emit(dari_peer, nama)


## ------------------------------------------------------------------
## Server: spawn / despawn.
## ------------------------------------------------------------------

func _spawn_peer(peer_id: int) -> void:
	if not _pemain.has(peer_id):
		return
	var spawner := _cari_spawner()
	if spawner == null:
		if not _menunggu_spawn.has(peer_id):
			_menunggu_spawn.append(peer_id)
			print("[MP] spawner belum ada — spawn peer %d ditunda" % peer_id)
		return
	if spawner.spawn_function.is_null():
		spawner.spawn_function = Callable(self, "spawn_player")
	var info: Dictionary = _pemain[peer_id]
	spawner.spawn({
		"peer_id": peer_id,
		"nama": String(info["nama"]),
		"jenis_kelamin": String(info["jenis_kelamin"]),
		"outfit": (info["outfit"] as Dictionary).duplicate(),
	})
	print("[MP] avatar peer %d di-spawn" % peer_id)
	pemain_bergabung.emit(peer_id, String(info["nama"]))


func _coba_spawn_tertunda() -> void:
	if _menunggu_spawn.is_empty():
		return
	if _cari_spawner() == null:
		return
	var antrean: Array[int] = _menunggu_spawn.duplicate()
	_menunggu_spawn.clear()
	for peer_id in antrean:
		_spawn_peer(peer_id)


## Cari spawner dari scene Main (dibuat main.gd _mp_pasang_players).
## Malas (lazy): di _ready autoload, Main belum ada.
func _cari_spawner() -> MultiplayerSpawner:
	if _spawner != null and is_instance_valid(_spawner):
		return _spawner
	var main := get_tree().current_scene
	if main != null:
		var s := main.get_node_or_null("MultiplayerSpawner")
		if s is MultiplayerSpawner:
			_spawner = s
			return _spawner
	return null


func _players_node() -> Node:
	var main := get_tree().current_scene
	if main != null:
		var p := main.get_node_or_null("Players")
		if p != null:
			return p
	var spawner := _cari_spawner()
	if spawner != null:
		return spawner.get_node_or_null(spawner.spawn_path)
	return null


func _hapus_avatar(peer_id: int) -> void:
	var players := _players_node()
	if players == null:
		# Diagnostik (1 baris per disconnect): tanpa ini kegagalan
		# hapus tidak terlihat di log sama sekali — persis yang
		# terjadi di jurnal VPS (avatar menumpuk tanpa ERROR yang
		# jelas di baris sekitarnya).
		print("[MP] avatar peer %d TIDAK dihapus: Players null" % peer_id)
		return
	var node := players.get_node_or_null(str(peer_id))
	if node == null:
		print("[MP] avatar peer %d TIDAK dihapus: node tidak ada di Players" % peer_id)
		return
	# JANGAN spawner.despawn(node): MultiplayerSpawner TIDAK PUNYA
	# method despawn di Godot 4.7.2 — terbukti 18 Nov 2026:
	# has_method("despawn") == false, dan tiap disconnect melempar
	# SCRIPT ERROR "Invalid call. Nonexistent function 'despawn' in
	# base 'MultiplayerSpawner'" sehingga node TIDAK PERNAH di-free
	# (avatar basi menumpuk 2 -> 4 -> 6 di jurnal VPS walau "pemain X
	# keluar" tercetak — baris itu dicetak SEBELUM _hapus_avatar).
	# queue_free() di server SUDAH cukup: spawner melacak anak hasil
	# spawn() di bawah spawn_path dan mereplikasi penghapusan ke
	# semua klien (terbukti probe headless 18 Nov: server 2 -> 1 dan
	# klien pengamat ikut 2 -> 1, tanpa SCRIPT ERROR). Catatan:
	# queue_free itu deferred — hitungan anak di frame yang sama
	# masih menunjukkan jumlah lama; itu artefak, bukan bug.
	node.queue_free()
	print("[MP] avatar peer %d dihapus dari Players" % peer_id)


## ------------------------------------------------------------------
## Server: validasi posisi (otoritatif).
## ------------------------------------------------------------------

## Posisi yang dilaporkan avatar: sync_position (ditulis synchronizer
## dari otoritas = pemilik) bila ada, kalau tidak position.
## (sync_position di player.gd masih dikerjakan Jaka — sebelum itu
## avatar lokal memakai position; avatar remote sudah punya.)
func _posisi_laporan(avatar: Node) -> Vector3:
	var v: Variant = avatar.get("sync_position")
	if v is Vector3:
		return v
	return (avatar as Node3D).position


## Validasi tiap 0,1 dtk (server saja). Pola snap-back dipakai ulang
## dari main.gd _cek_batas (pos_legal_terakhir): posisi yang melanggar
## DITOLAK dan pemilik dikembalikan ke posisi legal terakhir lewat
## zone_reject — server TIDAK menggeser avatar klien secara diam-diam.
func _validasi_posisi() -> void:
	if not multiplayer.is_server():
		return
	var players := _players_node()
	if players == null:
		return
	var sekarang := Time.get_ticks_msec() / 1000.0
	for peer_id in _pemain.keys():
		var info: Dictionary = _pemain[peer_id]
		var avatar := players.get_node_or_null(str(int(peer_id)))
		if avatar == null:
			continue
		var pos: Vector3 = _posisi_laporan(avatar)
		if bool(info["pertama"]):
			# Sampel pertama = jangkar (posisi spawn) — tanpa ini
			# sync_position awal (0,0,0) akan terbaca sebagai teleport.
			info["pos_legal"] = pos
			info["pos_teramati"] = pos
			info["pertama"] = false
			continue
		var legal: Vector3 = info["pos_legal"]
		var teramati: Vector3 = info["pos_teramati"]
		# Teleport SAH — terima apa adanya sebagai legal baru:
		# (a) masuk/keluar interior (z < -200; semua interior di
		#     z ~ -295..-300, main.gd _teleport_player ke
		#     *_interior_spawn / *_exit);
		# (b) reset ke titik spawn ("Kamu kembali ke depan Surau").
		if pos.z < RoomConfig.INTERIOR_Z_MAX or legal.z < RoomConfig.INTERIOR_Z_MAX or RoomConfig.di_titik_teleport_sah(pos):
			info["pos_legal"] = pos
			info["pos_teramati"] = pos
			info["melanggar"] = false
			continue
		var langkah := pos.distance_to(teramati)
		info["pos_teramati"] = pos
		var melanggar := bool(info["melanggar"])
		if langkah > RoomConfig.MAX_LANGKAH_METER:
			melanggar = true
		elif RoomConfig.di_zona_larangan(String(info["jenis_kelamin"]), pos):
			melanggar = true
		elif melanggar and pos.distance_to(legal) > RoomConfig.MAX_LANGKAH_METER:
			# Masih dalam pelanggaran: belum kembali ke dekat legal.
			melanggar = true
		else:
			melanggar = false
		info["melanggar"] = melanggar
		if melanggar:
			if sekarang - float(info["tolak_terakhir"]) >= RoomConfig.REJECT_COOLDOWN_SEC:
				info["tolak_terakhir"] = sekarang
				zone_reject.rpc_id(int(peer_id), legal)
				print("[MP] posisi peer %d ditolak (di %s, legal %s)" % [int(peer_id), str(pos), str(legal)])
			# Paksa salinan server kembali ke legal (sampai pemilik
			# patuh + mengirim posisi legal lagi).
			if "sync_position" in avatar:
				avatar.set("sync_position", legal)
			continue
		info["pos_legal"] = pos


## ------------------------------------------------------------------
## Klien: terima penolakan posisi dari server.
## ------------------------------------------------------------------

## Server -> klien pemilik: posisimu ditolak, kembali ke pos_legal.
## RPC HARUS "any_peer" + cek pengirim == 1 (skill Pattern 2):
## RPC ini tinggal di NetworkManager (node milik server secara
## logika), BUKAN di node avatar (otoritasnya klien pemilik).
@rpc("any_peer", "reliable")
func zone_reject(pos_legal: Vector3) -> void:
	if multiplayer.get_remote_sender_id() != 1:
		return
	if multiplayer.is_server():
		return
	print("[MP] zone_reject dari server — snap-back ke %s" % str(pos_legal))
	zona_ditolak.emit(pos_legal)
	var main := get_tree().current_scene
	if main != null and main.has_method("_mp_terapkan_zone_reject"):
		# Seam main.gd (Wira): pola snap-back main.gd
		# (global_position + velocity = ZERO + _pos_legal_terakhir)
		# + toast + flag untuk tes headless.
		main._mp_terapkan_zone_reject(pos_legal)
		return
	# Fallback (scene tes tanpa main.gd): snap avatar sendiri langsung.
	_snap_avatar_sendiri(pos_legal)


## Snap-back avatar sendiri (fallback bila Main tidak ada).
func _snap_avatar_sendiri(pos_legal: Vector3) -> void:
	var players := _players_node()
	if players == null:
		return
	var avatar := players.get_node_or_null(str(multiplayer.get_unique_id()))
	if avatar == null:
		return
	(avatar as Node3D).global_position = pos_legal
	if "velocity" in avatar:
		avatar.set("velocity", Vector3.ZERO)
	if "sync_position" in avatar:
		avatar.set("sync_position", pos_legal)
