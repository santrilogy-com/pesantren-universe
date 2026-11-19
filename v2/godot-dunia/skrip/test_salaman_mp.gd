extends Node
## Tes salaman pemain -> pemain, 2 klien paralel (Raka, 20 Nov 2026).
## Pola test_mp_alur_web.gd (Dimas): alur web Main Bersama, lalu
## pengajak menekan Salaman di dekat penjawab (keduanya putra, spawn
## sama (-4,14) — jarak ~0), penjawab auto-terima lewat RPC
## ajak_salaman. Kriteria: pose_id peer == 5 di kedua arah + lengan
## kanan avatar remote terulur (cabang POSE_SALAMAN remote_player.gd).
##
## Dijalankan 2 klien paralel (seperti gate test_mp_alur_web):
##   godot --headless --fixed-fps 60 --path . skrip/test_salaman_mp.tscn -- \
##     --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" \
##     --mp-web-jk putra --mp-web-id PV-0004 \
##     --mp-salaman-peran pengajak
##   (klien 2: test_mp_putra2 / "Tes MP Putra 2" / putra / PV-0014 /
##     --mp-salaman-peran penjawab)
## Akun PV-0014 dibuat via register publik (pola smoke test PV-0004/0005).
## Exit 0 = semua lulus; bukan-nol = ada gagal/blokir.

var _main: Node
var _lulus := 0
var _gagal := 0
var _blokir := 0
var _peer_saya := 0
var _ditolak_alasan := ""
var _save_awal: Dictionary = {}


func _pulihkan_save() -> void:
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
	print("[SALAMAN-MP] timeout %s detik menunggu: %s" % [str(detik), label])
	return false


func _arg(nama: String, default: String) -> String:
	var args := OS.get_cmdline_user_args()
	var i := args.find(nama)
	if i >= 0 and i + 1 < args.size():
		return String(args[i + 1])
	return default


func _avatar_peer() -> Node:
	if _main._players == null:
		return null
	for c in _main._players.get_children():
		if String(c.name) != str(_peer_saya):
			return c
	return null


func _peer_pose_id() -> int:
	var peer := _avatar_peer()
	if peer == null:
		return -1
	return int(peer.get("pose_id"))


func _peer_tangan_terulur() -> bool:
	var peer := _avatar_peer()
	if peer == null:
		return false
	var rig: Dictionary = peer.get("_rig")
	if rig.is_empty() or not rig.has("arm_r"):
		return false
	return float((rig["arm_r"] as Node3D).rotation.x) < -1.0


func _ready() -> void:
	var ig := _arg("--mp-web-ig", "test_mp_putra")
	var nama := _arg("--mp-web-nama", "Tes MP Putra")
	var jk := _arg("--mp-web-jk", "putra")
	var id_santri := _arg("--mp-web-id", "PV-0004")
	var peran := _arg("--mp-salaman-peran", "pengajak")
	print("[SALAMAN-MP] mulai sebagai %s (%s, %s, peran=%s)" % [ig, nama, jk, peran])
	_main = get_parent()
	var nm := get_node_or_null("/root/NetworkManager")
	if nm != null:
		nm.bergabung_ditolak.connect(func(alasan: String) -> void: _ditolak_alasan = alasan)
	var main_siap := await _tunggu_sampai(
		func() -> bool: return _main._players != null and _main._spawner != null and _main._ui != null and _main._player != null,
		180.0, "Main selesai _ready")
	if not main_siap:
		print("[SALAMAN-MP] GAGAL: Main tidak selesai _ready dalam 180 dtk — harness, bukan game")
		print("[SALAMAN-MP] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	print("[SALAMAN-MP] Main siap")
	_save_awal = (_main._save as Dictionary).duplicate(true)

	var btn: Button = _main._ui._mp_gabung_btn
	_main._save["id_santri"] = id_santri
	_main._save["nama"] = nama
	_main._save["ig_username"] = ig
	_main._save["jenis_kelamin"] = jk
	_main._session_token = ""
	if btn != null:
		btn.pressed.emit()
	var keluar_offline := await _tunggu_sampai(
		func() -> bool: return String(_main._mp_status) != "offline",
		30.0, "status keluar dari offline")
	_cek("online: tekan Main Bersama -> status bukan offline", keluar_offline)
	if not keluar_offline:
		print("[SALAMAN-MP] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	_main._masuk_pesantren("Tes salaman MP")
	for i in 3:
		await get_tree().process_frame
	var online := await _tunggu_sampai(
		func() -> bool: return String(_main._mp_status) == "online" or _ditolak_alasan != "",
		120.0, "status online")
	_peer_saya = multiplayer.get_unique_id()
	_cek("online: status online (peer id %d)" % _peer_saya, online and String(_main._mp_status) == "online")
	if _ditolak_alasan != "":
		_cek_blokir("online: server menolak", _ditolak_alasan)
	if not online:
		print("[SALAMAN-MP] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	var diadopsi := await _tunggu_sampai(
		func() -> bool: return _main._mp_avatar_sendiri != null,
		15.0, "adopsi avatar sendiri")
	_cek("online: avatar sendiri diadopsi", diadopsi)
	var peer_terlihat := await _tunggu_sampai(
		func() -> bool: return _avatar_peer() != null,
		60.0, "avatar peer di Players")
	_cek("online: avatar peer terlihat", peer_terlihat)
	if not peer_terlihat:
		_cek_blokir("online: avatar peer terlihat", "klien kedua mungkin belum jalan")
		print("[SALAMAN-MP] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
		_pulihkan_save()
		get_tree().quit(1)
		return
	var peer := _avatar_peer() as Node3D
	print("[SALAMAN-MP] peer: %s nama=%s pos=%s (saya di %s)" % [String(peer.name), _main._mp_nama_avatar(peer), str(peer.global_position), str(_main._player.global_position)])

	if peran == "pengajak":
		# Tunggu peer cukup dekat (spawn sama — seharusnya langsung).
		var dekat := await _tunggu_sampai(
			func() -> bool:
				var p := _avatar_peer() as Node3D
				return p != null and _main._player.global_position.distance_to(p.global_position) < 2.5,
			30.0, "peer dalam jarak salaman")
		_cek("pengajak: peer dalam jarak salaman (<2,5 m)", dekat)
		_main._on_aksi("salaman")
		_cek("pengajak: pose sendiri salaman", String(_main._player.aksi_saat_ini()) == "salaman")
		var peer_pose := await _tunggu_sampai(
			func() -> bool: return _peer_pose_id() == PoseIds.POSE_SALAMAN,
			60.0, "pose_id peer == 5 (penjawab auto-terima)")
		_cek("pengajak: pose_id peer == 5 (penjawab membalas salaman)", peer_pose)
		if peer_pose:
			await get_tree().create_timer(1.0).timeout
			_cek("pengajak: lengan kanan avatar peer terulur", _peer_tangan_terulur())
	else:
		# Penjawab: tunggu ajakan masuk (pose sendiri jadi salaman).
		var diterima := await _tunggu_sampai(
			func() -> bool: return String(_main._player.aksi_saat_ini()) == "salaman",
			60.0, "pose sendiri salaman (auto-terima ajakan)")
		_cek("penjawab: auto-terima ajakan (pose sendiri salaman)", diterima)
		var peer_pose := await _tunggu_sampai(
			func() -> bool: return _peer_pose_id() == PoseIds.POSE_SALAMAN,
			30.0, "pose_id peer == 5 (pengajak salaman)")
		_cek("penjawab: pose_id peer == 5 (pengajak salaman)", peer_pose)
		if peer_pose:
			await get_tree().create_timer(1.0).timeout
			_cek("penjawab: lengan kanan avatar peer terulur", _peer_tangan_terulur())

	print("[SALAMAN-MP] RINGKASAN: %d lulus, %d gagal, %d blokir" % [_lulus, _gagal, _blokir])
	_pulihkan_save()
	get_tree().quit(0 if _gagal == 0 and _blokir == 0 else 1)
