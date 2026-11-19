extends Node
## Tes headless khusus refactor multiplayer Fase 1 (Jaka, 18 Nov 2026).
## Jalankan: godot --headless --path . skrip/test_mp_fase1_jaka.tscn
## TIDAK memuat main.tscn/dunia (cepat, ~detik) — hanya SantriPlayer
## langsung. Diperluas tiap langkah refactor (L1..L7); tiap _cek
## bernama menurut langkahnya supaya ketahuan langkah mana yang rusak.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	# --- L1/L2: PoseIds + _baca_input (offline) ---
	_cek("L1 PoseIds konstanta 0..7", PoseIds.POSE_IDLE == 0 and PoseIds.POSE_JALAN == 1 and PoseIds.POSE_DUDUK == 2 and PoseIds.POSE_SHOLAT == 3 and PoseIds.POSE_MENULIS == 4 and PoseIds.POSE_SALAMAN == 5 and PoseIds.POSE_MELAMBAI == 6 and PoseIds.POSE_TIDUR == 7)
	_cek("L1 PoseIds dari_aksi semua nama set_aksi", PoseIds.dari_aksi("berdiri") == 0 and PoseIds.dari_aksi("duduk") == 2 and PoseIds.dari_aksi("menulis") == 4 and PoseIds.dari_aksi("salaman") == 5 and PoseIds.dari_aksi("melambai") == 6 and PoseIds.dari_aksi("tidur") == 7 and PoseIds.dari_aksi("sholat") == 3)
	_cek("L1 PoseIds dari_aksi bawa_kitab=-1 (toggle, bukan pose)", PoseIds.dari_aksi("bawa_kitab") == -1 and PoseIds.dari_aksi("tidak_ada") == -1)
	_cek("L1 PoseIds ke_aksi round-trip", PoseIds.ke_aksi(PoseIds.dari_aksi("duduk")) == "duduk" and PoseIds.ke_aksi(PoseIds.dari_aksi("sholat")) == "sholat" and PoseIds.ke_aksi(99) == "berdiri")

	var p := SantriPlayer.new()
	add_child(p) # _ready: nama "SantriPlayer" (bukan angka) -> offline
	_cek("L2 offline: otoritas lokal", p.is_multiplayer_authority())
	p.move_dir = Vector3(2, 0, 0)
	_cek("L2 _baca_input normalisasi panjang>1", p._baca_input().is_equal_approx(Vector3(1, 0, 0)))
	p.move_dir = Vector3(0, 0, -0.5)
	_cek("L2 _baca_input teruskan move_dir apa adanya", p._baca_input().is_equal_approx(Vector3(0, 0, -0.5)))
	p.move_dir = Vector3.ZERO

	# --- L3: gerbang otoritas ---
	var jauh := SantriPlayer.new()
	jauh.name = "7777" # nama = peer id lain -> BUKAN otoritas lokal
	add_child(jauh)
	_cek("L3 nama peer id: bukan otoritas lokal", not jauh.is_multiplayer_authority())
	jauh.move_dir = Vector3(1, 0, 0)
	_cek("L3 _baca_input avatar remote = NOL", jauh._baca_input().is_equal_approx(Vector3.ZERO))
	# Fisika remote tidak jalan: beri kecepatan + posisi, tunggu frame.
	jauh.velocity = Vector3(6, 0, 0)
	var pos_awal := jauh.position
	for i in 10:
		await get_tree().physics_frame
	_cek("L3 _physics_process remote diam (posisi tak berubah)", jauh.position.is_equal_approx(pos_awal))
	# Fisika lokal tetap jalan: move_dir -> posisi berubah (x saja;
	# y jatuh bebas karena tidak ada lantai di scene tes ini).
	p.move_dir = Vector3(1, 0, 0)
	var p_awal := p.position
	for i in 10:
		await get_tree().physics_frame
	_cek("L3 _physics_process lokal jalan (x bertambah)", p.position.x > p_awal.x + 0.05)
	p.move_dir = Vector3.ZERO

	# --- L4: properti sync + synchronizer ---
	_cek("L4 offline: tanpa synchronizer", p._sync == null)
	# `p` sudah bergerak di L3 (pemilik): sync_position HARUS sama
	# dengan position — pemilik mengisinya dari keadaan lokal.
	_cek("L4 offline: pemilik isi sync_position dari position", p.sync_position.is_equal_approx(p.position))
	# Mode multiplayer: host ENet lokal (port tes 18991, bukan 8791).
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(18991, 8)
	_cek("L4 host ENet tes dibuat", err == OK)
	multiplayer.multiplayer_peer = peer
	var mp_lokal := SantriPlayer.new()
	mp_lokal.name = "1" # host = peer id 1 -> otoritas lokal
	add_child(mp_lokal)
	_cek("L4 mp: synchronizer terpasang", mp_lokal._sync != null)
	_cek("L4 mp: replication_interval 0.1", mp_lokal._sync != null and is_equal_approx(mp_lokal._sync.replication_interval, 0.1))
	var cfg: SceneReplicationConfig = mp_lokal._sync.replication_config if mp_lokal._sync != null else null
	_cek("L4 mp: config punya 4 properti sync", cfg != null and cfg.get_properties().size() == 4)
	# Pemilik mengisi sync dari keadaan lokal setelah 1 frame fisika.
	mp_lokal.position = Vector3(3, 0, 4)
	for i in 3:
		await get_tree().physics_frame
	_cek("L4 mp: pemilik isi sync_position dari position", mp_lokal.sync_position.is_equal_approx(Vector3(3, mp_lokal.sync_position.y, 4)))
	var jauh_mp := SantriPlayer.new()
	jauh_mp.name = "8888" # peer id lain (beda dari "7777" L3 — nama node harus unik, kalau ganda Godot me-rename dan otoritas berubah!)
	add_child(jauh_mp)
	_cek("L4 mp: avatar remote juga punya synchronizer", jauh_mp._sync != null)
	jauh_mp.sync_position = Vector3(50, 0, 50) # simulasi nilai dari synchronizer
	var sp_awal := jauh_mp.sync_position
	for i in 3:
		await get_tree().physics_frame
	_cek("L4 mp: bukan-pemilik TIDAK menimpa sync_position", jauh_mp.sync_position.is_equal_approx(sp_awal))
	# Outfit sync: cermin _outfit saat terapkan.
	mp_lokal.terapkan_outfit({"koko": "#ff0000", "songkok": "#faf7f0", "sarung": "#0b6b4f"})
	_cek("L4 mp: outfit sync mengikuti terapkan_outfit", String(mp_lokal.outfit.get("koko", "")) == "#ff0000")

	# --- L5: interpolasi remote di _process ---
	jauh_mp.position = Vector3.ZERO
	jauh_mp.sync_position = Vector3(10, 0, 0)
	jauh_mp.rotation.y = 0.0
	jauh_mp.sync_yaw = PI / 2.0
	jauh_mp._process(0.016)
	_cek("L5 remote: position lerp menuju sync_position", jauh_mp.position.x > 0.5 and jauh_mp.position.x < 10.0)
	_cek("L5 remote: rotation.y lerp menuju sync_yaw", jauh_mp.rotation.y > 0.05 and jauh_mp.rotation.y < PI / 2.0)
	# Pemilik: _process TIDAK menggeser posisi.
	var mp_pos := mp_lokal.position
	mp_lokal.sync_position = Vector3(100, 0, 100)
	mp_lokal._process(0.016)
	_cek("L5 pemilik: _process tidak menggeser position", mp_lokal.position.is_equal_approx(mp_pos))
	# --- L6: pose dari pose_id ---
	mp_lokal.set_aksi("duduk")
	_cek("L6 set_aksi duduk -> pose_id DUDUK", mp_lokal.pose_id == PoseIds.POSE_DUDUK)
	mp_lokal.set_aksi("sholat")
	_cek("L6 set_aksi sholat -> pose_id SHOLAT", mp_lokal.pose_id == PoseIds.POSE_SHOLAT)
	var pose_sebelum := mp_lokal.pose_id
	mp_lokal.set_aksi("bawa_kitab")
	_cek("L6 toggle bawa_kitab tidak mengubah pose_id", mp_lokal.pose_id == pose_sebelum)
	mp_lokal.set_aksi("bawa_kitab") # toggle balik
	mp_lokal.set_aksi("berdiri")
	_cek("L6 set_aksi berdiri -> pose_id IDLE", mp_lokal.pose_id == PoseIds.POSE_IDLE)
	# Remote: pose_id -> _aksi (dipakai _terapkan_pose + label tidur).
	jauh_mp.pose_id = PoseIds.POSE_TIDUR
	jauh_mp._sinkron_aksi_dari_pose_id()
	_cek("L6 remote: pose_id TIDUR -> _aksi tidur", jauh_mp.aksi_saat_ini() == "tidur")
	jauh_mp.pose_id = PoseIds.POSE_JALAN
	jauh_mp._sinkron_aksi_dari_pose_id()
	_cek("L6 remote: pose_id JALAN -> _aksi berdiri (jalan bukan aksi)", jauh_mp.aksi_saat_ini() == "berdiri")
	jauh_mp.pose_id = PoseIds.POSE_DUDUK
	jauh_mp._sinkron_aksi_dari_pose_id()
	_cek("L6 remote: pose_id DUDUK -> _aksi duduk", jauh_mp.aksi_saat_ini() == "duduk")
	# Remote memainkan animasi jalan dari pose_id (tanpa input/fisika):
	# _walk_time harus maju saat pose JALAN di _process.
	jauh_mp.pose_id = PoseIds.POSE_JALAN
	var wt_awal := jauh_mp._walk_time
	jauh_mp._process(0.016)
	jauh_mp._process(0.016)
	_cek("L6 remote: animasi jalan maju dari pose_id (walk_time naik)", jauh_mp._walk_time > wt_awal)
	# REGRESI 18 Nov: _sinkron dari pose JALAN saat _aksi masih "duduk"
	# sempat memanggil set_aksi("berdiri") yang menimpa pose_id jadi
	# IDLE — avatar remote berhenti jalan walau pemilik masih jalan.
	_cek("L6 remote: pose_id TIDAK ditimpa tulisan lokal (tetap JALAN)", jauh_mp.pose_id == PoseIds.POSE_JALAN)
	# Pemilik: pose_id JALAN saat bergerak, IDLE saat diam (via fisika).
	mp_lokal.set_aksi("berdiri")
	mp_lokal.move_dir = Vector3(1, 0, 0)
	for i in 3:
		await get_tree().physics_frame
	_cek("L6 pemilik bergerak -> pose_id JALAN", mp_lokal.pose_id == PoseIds.POSE_JALAN)
	mp_lokal.move_dir = Vector3.ZERO
	for i in 3:
		await get_tree().physics_frame
	_cek("L6 pemilik diam -> pose_id IDLE", mp_lokal.pose_id == PoseIds.POSE_IDLE)

	# --- L7: nama dari data spawn ---
	jauh_mp.set_nama_spawn("Santri Remote")
	_cek("L7 set_nama_spawn isi label nama", jauh_mp._nama == "Santri Remote")
	p.set_nama("Santri Lokal")
	_cek("L7 avatar lokal: set_nama login tetap jalan", p._nama == "Santri Lokal")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	print("TES MP FASE1 JAKA: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
