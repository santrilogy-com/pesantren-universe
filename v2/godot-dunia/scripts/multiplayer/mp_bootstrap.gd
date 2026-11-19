extends Node
## MP-BOOTSTRAP — bootstrap minimal multiplayer (Fase 0).
##
## Autoload ini HANYA aktif bila game dijalankan dengan argumen:
##   --mp-host            : jadi server WebSocket di port 8791
##   --mp-join <alamat>   : jadi klien ke server itu (alamat boleh
##                          "127.0.0.1", "127.0.0.1:8791", atau URL
##                          ws://... / wss://... lengkap)
##   --mp-ticket <tiket>  : tiket realtime (opsional, Fase 1; lihat bawah)
## Tanpa --mp-host / --mp-join, autoload ini TIDAK melakukan apa pun —
## game berjalan normal seperti sebelum ada multiplayer.
##
## Transport WAJIB WebSocket (WebSocketMultiplayerPeer), bukan ENet:
## klien web hanya bisa WebSocket. Server dan klien dibangun dari
## commit/proyek yang sama supaya checksum RPC cocok.
## Tidak ada gameplay, auth, atau spawn di sini — itu Fase 1.
##
## SEAM TIKET REALTIME (Fase 1, kontrak REST v1.5.2 cara (a) — Saka):
##   1. Klien login seperti biasa, lalu POST /api/santri/realtime_ticket
##      body {"session": "<token sesi login>"} -> 200 {"ticket",
##      "expires_in": 300, "id", "nama", "jenis_kelamin"}. Tiket acak,
##      5 menit, sekali pakai; token sesi TIDAK hangus.
##   2. Fase 1 (network_manager) memanggil set_ticket(tiket) SEBELUM
##      join, atau menjalankan game dengan --mp-ticket <tiket>.
##      Tiket disimpan DI MEMORI saja, TIDAK PERNAH ditulis ke log
##      dan TIDAK PERNAH dikirim ke pemain lain.
##   3. Setelah connected_to_server, Fase 1 memanggil consume_ticket()
##      (mengambil tiket SEKALI lalu mengosongkannya — cerminan sifat
##      sekali-pakai di server) dan mengirimnya ke server lewat RPC.
##      Fase 0 belum punya RPC itu, jadi tiket di sini hanya disimpan.
##   4. Server realtime (Fase 1, komponen tepercaya di VPS) memvalidasi
##      lewat POST http://127.0.0.1:8790/api/santri/realtime_ticket/validate
##      body {"ticket": "..."} dengan header X-PV-Token. Nilai X-PV-Token
##      dibaca server dari ENVIRONMENT "PV_TOKEN" (OS.get_environment)
##      — JANGAN PERNAH di-hardcode ke file/proyek mana pun (token itu
##      hanya ada di VPS .env). Respons 200 {"id", "nama",
##      "jenis_kelamin"} dari DB adalah SATU-SATUNYA identitas yang
##      dipakai; nama pemain lain SELALU dari DB, bukan dari klien.
##      Koneksi tanpa tiket valid langsung diputus server.
##   5. Token sesi login TIDAK BOLEH dipakai untuk handshake (token itu
##      juga mengesahkan set_password).

const MP_PORT := 8791
const MP_MAX_CLIENTS := 20

## RETRY JOIN (diukur 18 Nov 2026 ~00:45 WIB): _ready main.tscn memakan
## ~58 dtk di VM ini (PesantrenBuilder.build sinkron) sebelum frame
## pertama sempat mem-poll peer. Sementara itu server sudah menutup
## koneksi handshake yang menggantung, jadi percobaan join PERTAMA dari
## klien game SELALU connection_failed. Percobaan ULANG sesudah _ready
## (loop sudah jalan) langsung tersambung — terbukti: klien scene
## minimal (tanpa world build) connect dalam ~1-2 dtk, klien main.tscn
## gagal 4x tanpa retry. Karena itu _join mengulang otomatis sampai
## MP_MAX_JOIN_ATTEMPTS kali; smoke test harus memberi waktu klien
## >60 dtk (bukan 8 dtk). Retry TIDAK menyentuh gameplay — hanya
## percobaan ulang koneksi yang sama.
const MP_MAX_JOIN_ATTEMPTS := 4
const MP_RETRY_DELAY_SEC := 1.0

var _join_url := ""
var _join_attempts := 0

## Tiket realtime untuk handshake (Fase 1). Kosong di Fase 0 / smoke
## test tanpa auth. Hanya di memori; tidak pernah dicetak ke log.
var ticket: String = ""


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--mp-ticket" in args:
		var ti := args.find("--mp-ticket")
		if ti + 1 < args.size():
			set_ticket(args[ti + 1])
	if "--mp-host" in args:
		_host()
	elif "--mp-join" in args:
		var i := args.find("--mp-join")
		var addr := args[i + 1] if i + 1 < args.size() else "127.0.0.1"
		_join(addr)
	# Tanpa --mp-host / --mp-join: sengaja diam, game normal.


## Fase 1: simpan tiket realtime (dari POST /api/santri/realtime_ticket).
## Nilainya tidak pernah ditulis ke log.
func set_ticket(t: String) -> void:
	ticket = t
	if ticket != "":
		print("[MP-BOOTSTRAP] tiket realtime disiapkan (nilai disembunyikan)")


## Fase 1: ambil tiket SEKALI untuk dikirim saat handshake, lalu kosongkan.
## Meniru sifat sekali-pakai tiket di server; pemakaian kedua
## mengembalikan "" sehingga tiket tidak terkirim dua kali.
func consume_ticket() -> String:
	var t := ticket
	ticket = ""
	return t


func _host() -> void:
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_server(MP_PORT)
	if err != OK:
		push_error("[MP-BOOTSTRAP] gagal host di port %d: %s" % [MP_PORT, error_string(err)])
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("[MP-BOOTSTRAP] hosting WebSocket server di port %d (peer id saya: %d)" % [MP_PORT, multiplayer.get_unique_id()])


func _join(address: String) -> void:
	var url := address
	if not url.begins_with("ws://") and not url.begins_with("wss://"):
		if ":" in url:
			url = "ws://" + url
		else:
			url = "ws://%s:%d" % [url, MP_PORT]
	_join_url = url
	_join_attempts = 1
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_do_join(url)


func _do_join(url: String) -> void:
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_client(url)
	if err != OK:
		push_error("[MP-BOOTSTRAP] gagal join ke %s: %s" % [url, error_string(err)])
		return
	multiplayer.multiplayer_peer = peer
	print("[MP-BOOTSTRAP] joining %s ... (percobaan %d/%d)" % [url, _join_attempts, MP_MAX_JOIN_ATTEMPTS])


func _on_peer_connected(id: int) -> void:
	print("[MP-BOOTSTRAP] peer_connected %d" % id)


func _on_peer_disconnected(id: int) -> void:
	print("[MP-BOOTSTRAP] peer_disconnected %d" % id)


func _on_connected_to_server() -> void:
	print("[MP-BOOTSTRAP] connected_to_server (peer id saya: %d)" % multiplayer.get_unique_id())
	if ticket != "":
		print("[MP-BOOTSTRAP] tiket realtime tersedia — handshake tiket dikirim Fase 1 (network_manager via consume_ticket)")


func _on_connection_failed() -> void:
	print("[MP-BOOTSTRAP] connection_failed (percobaan %d/%d)" % [_join_attempts, MP_MAX_JOIN_ATTEMPTS])
	if _join_url != "" and _join_attempts < MP_MAX_JOIN_ATTEMPTS:
		_join_attempts += 1
		print("[MP-BOOTSTRAP] mencoba lagi dalam %d detik ..." % int(MP_RETRY_DELAY_SEC))
		await get_tree().create_timer(MP_RETRY_DELAY_SEC).timeout
		_do_join(_join_url)
	else:
		print("[MP-BOOTSTRAP] gagal terhubung setelah %d percobaan" % MP_MAX_JOIN_ATTEMPTS)


func _on_server_disconnected() -> void:
	print("[MP-BOOTSTRAP] server_disconnected")
