class_name RemotePlayer
extends Node3D
## REMOTE-PLAYER — avatar pemain lain (Fase 1 multiplayer, Bara).
##
## Menampilkan SATU pemain lain: visual dari pabrik bersama
## `SantriPlayer.build_visual` (JANGAN duplikasi pabrik visual),
## posisi/yaw diinterpolasi menuju nilai sinkron, nama di atas kepala
## dari data spawn (nama DB, bukan dari klien), animasi dari `pose_id`.
##
## YANG DILARANG di script ini (prep doc §1.5–§1.6 langkah 8):
## - TANPA input (`Input.*` dilarang — tidak ada `_unhandled_input`,
##   tidak ada pembacaan aksi).
## - TANPA fisika (`move_and_slide` dilarang — ini Node3D, BUKAN
##   CharacterBody3D; posisi hanya hasil lerp di `_process`).
## - TANPA kamera.
## - Variabel sync (`sync_position`, `sync_yaw`, `pose_id`, `outfit`)
##   HANYA diisi MultiplayerSynchronizer — tidak ada satu baris pun
##   logika lokal yang menulis ke keempat variabel itu.
##
## TIDAK ADA `@rpc` di script ini. RPC Fase 1 (`submit_ticket`,
## `zone_reject`) tinggal di network_manager.gd (Saka) — jadi checksum
## RPC script ini kosong di klien maupun server, tidak ada yang perlu
## disamakan.
##
## Pose yang dimainkan (PoseIds): POSE_IDLE, POSE_JALAN, POSE_DUDUK,
## POSE_SHOLAT, POSE_SALAMAN — nilai target rotasi disalin dari
## `SantriPlayer._terapkan_pose` (player.gd) supaya avatar remote
## duduk/sholat/salaman PERSIS seperti avatar lokal. Pose lain
## (MENULIS, MELAMBAI, TIDUR) untuk sekarang jatuh ke idle — Fase 1
## hanya menyinkronkan pose 0–3 + 5; kalau player.gd mulai mengirim
## pose 4/6/7, cabang itu harus ditambahkan di sini.

## --- Variabel sync: HANYA MultiplayerSynchronizer yang menulis. ---
## Posisi avatar pemilik, direplikasi 10 Hz (ALWAYS).
var sync_position: Vector3 = Vector3.ZERO
## Arah hadap (rotasi Y, radian), direplikasi 10 Hz (ALWAYS).
var sync_yaw: float = 0.0
## Keadaan animasi (PoseIds), direplikasi saat berubah (ON_CHANGE).
var pose_id: int = PoseIds.POSE_IDLE
## Koko/songkok/sarung (putra) atau abaya/hijab (putri), direplikasi
## saat berubah (ON_CHANGE). Diset saat spawn dari data DB.
var outfit: Dictionary = {}

## Nama tampil (dari data spawn, nama DB) — TIDAK via synchronizer.
var _nama: String = "Santri"
## Jenis kelamin dari data spawn ("putra"/"putri") — disimpan untuk
## keperluan spawn/zonasi pemanggil, tidak dipakai logika di sini.
var _jenis_kelamin: String = ""

var _visual: Node3D = null
var _name_label: Label3D = null
## Rig primitif untuk AnimasiMixamo (dibangun dari hasil build_visual).
var _rig: Dictionary = {}
## Referensi pakaian untuk lerp pose duduk/sholat (cerminan player.gd).
var _sarung: MeshInstance3D = null
var _sarung_hem: MeshInstance3D = null
var _sarung_trim: MeshInstance3D = null
var _lutut_l: MeshInstance3D = null
var _lutut_r: MeshInstance3D = null
var _torso: MeshInstance3D = null
var _peci: MeshInstance3D = null

var _sync: MultiplayerSynchronizer = null
## Outfit yang sedang dipakai visual saat ini — kalau `outfit` (sync)
## berbeda, visual dibangun ulang dari data baru.
var _outfit_terpasang: Dictionary = {}
## Jam animasi: fase langkah + jam idle + fase acak per avatar (supaya
## bersiwak pemain lain tidak serempak).
var _walk_time: float = 0.0
var _idle_t: float = 0.0
var _fase_acak: float = 0.0
## Halusnya peralihan diam -> jalan (0..1, naik ~0,2 dtk).
var _blend_jalan: float = 0.0
## Posisi frame lalu (untuk menghitung kecepatan jalan -> fase langkah).
var _posisi_lalu: Vector3 = Vector3.ZERO


func _enter_tree() -> void:
	# Synchronizer HARUS dibuat di _enter_tree(), BUKAN di _ready().
	# Engine (smoke wss, 4× ERROR, 1× per avatar di kedua klien):
	# "The MultiplayerSynchronizer ... is unable to process the
	# pending spawn since it has no network ID. This might happen
	# when changing the multiplayer authority during the "_ready"
	# callback. Make sure to only change the authority of
	# multiplayer synchronizers during the "_enter_tree" callback
	# of their multiplayer spawner."
	# SET AUTHORITY SEBELUM add_child: synchronizer masuk tree di
	# add_child — dan saat itu juga replication system mulai
	# memproses spawn-nya. Mengubah authority SESUDAH add_child,
	# meski masih di dalam _enter_tree avatar, tetap terlambat dan
	# tetap memicu error yang sama. Authority harus sudah benar
	# sebelum synchronizer masuk tree; set_multiplayer_authority
	# bekerja pada node yang belum masuk tree (nilainya tersimpan
	# dan berlaku saat masuk tree). Di sini nama node SUDAH diset
	# str(peer_id) oleh dari_data_spawn (sebelum node masuk tree),
	# jadi guard nama int valid > 0 tetap bekerja.
	# Otoritas synchronizer TIDAK diwarisi dari parent: node yang
	# dibuat di kode (bukan di scene) default-nya authority 1
	# (server), sehingga salinan server ikut menyiarkan nilai beku
	# di spawn. Samakan dengan pemilik (nama node = str(peer_id)).
	# Config dipasang SEBELUM add_child supaya synchronizer masuk
	# tree dengan konfigurasi sudah lengkap.
	if _sync != null:
		return
	_sync = MultiplayerSynchronizer.new()
	_sync.name = "MultiplayerSynchronizer"
	_sync.root_path = ^".."
	_sync.replication_config = MpSync.buat_config()
	_sync.replication_interval = MpSync.REPLICATION_INTERVAL
	if name.is_valid_int() and name.to_int() > 0:
		_sync.set_multiplayer_authority(name.to_int())
	add_child(_sync)


func _ready() -> void:
	_fase_acak = randf() * TAU
	_posisi_lalu = position
	# Pengaman: node yang dibuat tanpa dari_data_spawn (mis. spawner
	# tanpa spawn_function) tetap punya visual, bukan node kosong.
	if _visual == null:
		_pasang_visual(SantriPlayer.build_visual(_nama, outfit))
		_outfit_terpasang = outfit.duplicate()


## Bangun avatar pemain lain dari data spawn server (nama/outfit dari
## DB, bukan dari klien). Dipanggil spawn_function MultiplayerSpawner
## di SEMUA peer dengan data yang sama — jadi nama node (= peer id)
## dan visual identik di server + semua klien.
## data = {"peer_id": int, "nama": String, "jenis_kelamin": String,
##         "outfit": Dictionary}.
## CATATAN: posisi spawn TIDAK diset di sini — pemanggil (spawn_function
## di main.gd) wajib mengeset `position` DAN `sync_position` ke titik
## spawn sesuai gender (putra (-4, 14), putri (130, 14), prep §1.4).
## Kalau hanya `position` yang diset, frame pertama remote akan lerp
## balik ke `sync_position` (0, 0, 0).
static func dari_data_spawn(data: Dictionary) -> RemotePlayer:
	var peer_id := int(data.get("peer_id", 0))
	var nama := String(data.get("nama", "Santri"))
	var outfit_data := (data.get("outfit", {}) as Dictionary).duplicate()
	var node := RemotePlayer.new()
	node.name = str(peer_id)
	if peer_id > 0:
		node.set_multiplayer_authority(peer_id)
	node._nama = nama
	node._jenis_kelamin = String(data.get("jenis_kelamin", ""))
	node.outfit = outfit_data
	node._pasang_visual(SantriPlayer.build_visual(nama, outfit_data))
	node._outfit_terpasang = outfit_data.duplicate()
	return node


## Pasang visual yang sudah dibangun (tetapkan semua referensi node +
## tambahkan ke scene). Cerminan `SantriPlayer._pasang_visual`.
func _pasang_visual(built: Dictionary) -> void:
	_visual = built["root"]
	_name_label = built["name_label"]
	_sarung = built["sarung"]
	_sarung_hem = built["sarung_hem"]
	_sarung_trim = built["sarung_trim"]
	_lutut_l = built["lutut_l"]
	_lutut_r = built["lutut_r"]
	_torso = built["torso"]
	_peci = built["peci"]
	_rig = AnimasiMixamo.rig_dari_built(built)
	add_child(_visual)


## Bangun ulang visual dengan outfit baru (ganti outfit via sync).
## Nama dipertahankan; visual lama dibuang setelah yang baru terpasang
## supaya tidak ada frame tanpa karakter.
func _bangun_ulang_visual(outfit_baru: Dictionary) -> void:
	var lama: Node3D = _visual
	_pasang_visual(SantriPlayer.build_visual(_nama, outfit_baru))
	_outfit_terpasang = outfit_baru.duplicate()
	if lama != null:
		remove_child(lama)
		lama.queue_free()


func _process(delta: float) -> void:
	# --- Interpolasi (TAMPILAN saja): lerp menuju nilai sinkron. ---
	# Bobot dijepit 1.0 supaya frame lambat (delta > 0,1 dtk) tidak
	# melompati target (Vector3.lerp mengekstrapolasi bila bobot > 1).
	var k_lerp := minf(1.0, delta * MpSync.LERP_LANCAR)
	position = position.lerp(sync_position, k_lerp)
	rotation.y = lerp_angle(rotation.y, sync_yaw, k_lerp)
	# --- Animasi dari pose_id (sinkron, bukan dari input). ---
	_terapkan_pose(delta)
	# --- Outfit berubah via synchronizer (ON_CHANGE) -> visual baru. ---
	if outfit != _outfit_terpasang:
		_bangun_ulang_visual(outfit)
	# --- Label nama: hanya tampil saat kamera cukup dekat (28 m,
	# seperti player.gd RONDE 5) + dijaga tidak membesar di layar. ---
	# Tanpa kamera (headless / server khusus) label dibiarkan tampil.
	var vp := get_viewport()
	if vp != null and _name_label != null:
		var cam := vp.get_camera_3d()
		if cam != null:
			_name_label.visible = cam.global_position.distance_to(
				_name_label.global_position) < 28.0
			Palette.batasi_label_kamera(_name_label, cam)


## Mainkan animasi visual sesuai `pose_id` (sinkron). Dipanggil tiap
## frame dari `_process`. Target rotasi = nilai yang sama dengan
## `SantriPlayer._terapkan_pose` (player.gd) untuk pose yang sama.
func _terapkan_pose(delta: float) -> void:
	if _rig.is_empty() or _visual == null:
		return
	# Kecepatan jalan dari gerakan hasil lerp frame ini -> fase langkah
	# mengikuti kecepatan sebenarnya (bukan jam buta), supaya kaki
	# tidak terlihat melayang/cepat-lambat sendiri.
	var kecepatan := 0.0
	if delta > 0.0001:
		kecepatan = position.distance_to(_posisi_lalu) / delta
	_posisi_lalu = position
	# Ramping blend jalan (masuk/keluar pose jalan tidak patah).
	var target_blend := 1.0 if pose_id == PoseIds.POSE_JALAN else 0.0
	_blend_jalan = move_toward(_blend_jalan, target_blend, delta * 5.0)
	match pose_id:
		PoseIds.POSE_JALAN:
			_walk_time += delta * kecepatan * 1.15
			AnimasiMixamo.terapkan_jalan(_rig, _walk_time, _blend_jalan)
			_lerp_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
		PoseIds.POSE_DUDUK:
			# Duduk bersila (RONDE DUDUK): paha -0.85, lutut +2.30,
			# kaki menyilang, tangan di pangkuan; kaki melipat dulu,
			# tangan menyusul (sekuens yang sama seperti player.gd).
			_idle_t = 0.0
			var k := minf(1.0, delta * 8.0)
			var k_kaki := minf(1.0, delta * 12.0)
			var k_tangan := minf(1.0, delta * 5.0)
			_visual.position.y = lerpf(_visual.position.y, -0.42, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			(_rig["leg_l"] as Node3D).rotation.x = lerpf((_rig["leg_l"] as Node3D).rotation.x, -0.85, k_kaki)
			(_rig["leg_r"] as Node3D).rotation.x = lerpf((_rig["leg_r"] as Node3D).rotation.x, -0.85, k_kaki)
			(_rig["leg_l"] as Node3D).rotation.y = lerpf((_rig["leg_l"] as Node3D).rotation.y, 0.50, k_kaki)
			(_rig["leg_r"] as Node3D).rotation.y = lerpf((_rig["leg_r"] as Node3D).rotation.y, -0.50, k_kaki)
			(_rig["leg_l"] as Node3D).rotation.z = lerpf((_rig["leg_l"] as Node3D).rotation.z, 0.10, k_kaki)
			(_rig["leg_r"] as Node3D).rotation.z = lerpf((_rig["leg_r"] as Node3D).rotation.z, -0.10, k_kaki)
			(_rig["knee_l"] as Node3D).rotation.x = lerpf((_rig["knee_l"] as Node3D).rotation.x, 2.30, k_kaki)
			(_rig["knee_r"] as Node3D).rotation.x = lerpf((_rig["knee_r"] as Node3D).rotation.x, 2.30, k_kaki)
			(_rig["knee_l"] as Node3D).rotation.y = lerpf((_rig["knee_l"] as Node3D).rotation.y, 0.20, k_kaki)
			(_rig["knee_r"] as Node3D).rotation.y = lerpf((_rig["knee_r"] as Node3D).rotation.y, -0.20, k_kaki)
			(_rig["knee_l"] as Node3D).rotation.z = lerpf((_rig["knee_l"] as Node3D).rotation.z, 0.0, k_kaki)
			(_rig["knee_r"] as Node3D).rotation.z = lerpf((_rig["knee_r"] as Node3D).rotation.z, 0.0, k_kaki)
			(_rig["arm_l"] as Node3D).rotation.x = lerpf((_rig["arm_l"] as Node3D).rotation.x, -0.35, k_tangan)
			(_rig["arm_r"] as Node3D).rotation.x = lerpf((_rig["arm_r"] as Node3D).rotation.x, -0.35, k_tangan)
			(_rig["arm_l"] as Node3D).rotation.z = lerpf((_rig["arm_l"] as Node3D).rotation.z, -0.20, k_tangan)
			(_rig["arm_r"] as Node3D).rotation.z = lerpf((_rig["arm_r"] as Node3D).rotation.z, 0.20, k_tangan)
			(_rig["elbow_l"] as Node3D).rotation.x = lerpf((_rig["elbow_l"] as Node3D).rotation.x, -0.20, k_tangan)
			(_rig["elbow_r"] as Node3D).rotation.x = lerpf((_rig["elbow_r"] as Node3D).rotation.x, -0.20, k_tangan)
			_lerp_pakaian(delta, SantriPlayer.PAKAIAN_DUDUK)
		PoseIds.POSE_SHOLAT:
			# Sholat RONDE 18: takbiratul ihram statis — kedua tangan
			# terangkat ke telinga (lengan -2.6, siku -0.6).
			_idle_t = 0.0
			var k2 := minf(1.0, delta * 8.0)
			_visual.position.y = lerpf(_visual.position.y, 0.0, k2)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.05, k2)
			(_rig["arm_l"] as Node3D).rotation.x = lerpf((_rig["arm_l"] as Node3D).rotation.x, -2.6, k2)
			(_rig["arm_r"] as Node3D).rotation.x = lerpf((_rig["arm_r"] as Node3D).rotation.x, -2.6, k2)
			(_rig["arm_l"] as Node3D).rotation.z = lerpf((_rig["arm_l"] as Node3D).rotation.z, 0.15, k2)
			(_rig["arm_r"] as Node3D).rotation.z = lerpf((_rig["arm_r"] as Node3D).rotation.z, -0.15, k2)
			(_rig["elbow_l"] as Node3D).rotation.x = lerpf((_rig["elbow_l"] as Node3D).rotation.x, -0.6, k2)
			(_rig["elbow_r"] as Node3D).rotation.x = lerpf((_rig["elbow_r"] as Node3D).rotation.x, -0.6, k2)
			(_rig["leg_l"] as Node3D).rotation.x = lerpf((_rig["leg_l"] as Node3D).rotation.x, 0.0, k2)
			(_rig["leg_r"] as Node3D).rotation.x = lerpf((_rig["leg_r"] as Node3D).rotation.x, 0.0, k2)
			(_rig["leg_l"] as Node3D).rotation.y = lerpf((_rig["leg_l"] as Node3D).rotation.y, 0.0, k2)
			(_rig["leg_r"] as Node3D).rotation.y = lerpf((_rig["leg_r"] as Node3D).rotation.y, 0.0, k2)
			(_rig["leg_l"] as Node3D).rotation.z = lerpf((_rig["leg_l"] as Node3D).rotation.z, 0.0, k2)
			(_rig["leg_r"] as Node3D).rotation.z = lerpf((_rig["leg_r"] as Node3D).rotation.z, 0.0, k2)
			(_rig["knee_l"] as Node3D).rotation.x = lerpf((_rig["knee_l"] as Node3D).rotation.x, 0.0, k2)
			(_rig["knee_r"] as Node3D).rotation.x = lerpf((_rig["knee_r"] as Node3D).rotation.x, 0.0, k2)
			(_rig["knee_l"] as Node3D).rotation.y = lerpf((_rig["knee_l"] as Node3D).rotation.y, 0.0, k2)
			(_rig["knee_r"] as Node3D).rotation.y = lerpf((_rig["knee_r"] as Node3D).rotation.y, 0.0, k2)
			(_rig["knee_l"] as Node3D).rotation.z = lerpf((_rig["knee_l"] as Node3D).rotation.z, 0.0, k2)
			(_rig["knee_r"] as Node3D).rotation.z = lerpf((_rig["knee_r"] as Node3D).rotation.z, 0.0, k2)
			_lerp_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
		PoseIds.POSE_SALAMAN:
			# Salaman (Raka, 20 Nov 2026): tangan kanan terulur,
			# badan sedikit condong — nilai = player.gd "salaman".
			_idle_t = 0.0
			var k3 := minf(1.0, delta * 8.0)
			_visual.position.y = lerpf(_visual.position.y, 0.0, k3)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k3)
			(_rig["arm_l"] as Node3D).rotation.x = lerpf((_rig["arm_l"] as Node3D).rotation.x, 0.0, k3)
			(_rig["arm_r"] as Node3D).rotation.x = lerpf((_rig["arm_r"] as Node3D).rotation.x, -1.45, k3)
			(_rig["arm_l"] as Node3D).rotation.z = lerpf((_rig["arm_l"] as Node3D).rotation.z, 0.05, k3)
			(_rig["arm_r"] as Node3D).rotation.z = lerpf((_rig["arm_r"] as Node3D).rotation.z, SantriPlayer.sudut_salaman_dalam((_rig["arm_r"] as Node3D).position.x), k3)
			(_rig["elbow_l"] as Node3D).rotation.x = lerpf((_rig["elbow_l"] as Node3D).rotation.x, 0.0, k3)
			(_rig["elbow_r"] as Node3D).rotation.x = lerpf((_rig["elbow_r"] as Node3D).rotation.x, -0.1, k3)
			(_rig["leg_l"] as Node3D).rotation.x = lerpf((_rig["leg_l"] as Node3D).rotation.x, 0.0, k3)
			(_rig["leg_r"] as Node3D).rotation.x = lerpf((_rig["leg_r"] as Node3D).rotation.x, 0.0, k3)
			(_rig["leg_l"] as Node3D).rotation.y = lerpf((_rig["leg_l"] as Node3D).rotation.y, 0.0, k3)
			(_rig["leg_r"] as Node3D).rotation.y = lerpf((_rig["leg_r"] as Node3D).rotation.y, 0.0, k3)
			(_rig["leg_l"] as Node3D).rotation.z = lerpf((_rig["leg_l"] as Node3D).rotation.z, 0.0, k3)
			(_rig["leg_r"] as Node3D).rotation.z = lerpf((_rig["leg_r"] as Node3D).rotation.z, 0.0, k3)
			(_rig["knee_l"] as Node3D).rotation.x = lerpf((_rig["knee_l"] as Node3D).rotation.x, 0.0, k3)
			(_rig["knee_r"] as Node3D).rotation.x = lerpf((_rig["knee_r"] as Node3D).rotation.x, 0.0, k3)
			(_rig["knee_l"] as Node3D).rotation.y = lerpf((_rig["knee_l"] as Node3D).rotation.y, 0.0, k3)
			(_rig["knee_r"] as Node3D).rotation.y = lerpf((_rig["knee_r"] as Node3D).rotation.y, 0.0, k3)
			(_rig["knee_l"] as Node3D).rotation.z = lerpf((_rig["knee_l"] as Node3D).rotation.z, 0.0, k3)
			(_rig["knee_r"] as Node3D).rotation.z = lerpf((_rig["knee_r"] as Node3D).rotation.z, 0.0, k3)
			_lerp_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
		_:
			# POSE_IDLE + pose lain yang belum didukung remote
			# (MENULIS/MELAMBAI/TIDUR): idle napas. Pose tak
			# dikenal tidak boleh membekukan avatar — jatuh ke idle.
			_idle_t += delta
			AnimasiMixamo.terapkan_idle(_rig, delta, _idle_t, _fase_acak)
			_lerp_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)


## Lerp skala/posisi pakaian ke target pose (sarung mengerut saat
## duduk, normal saat berdiri) — cerminan `SantriPlayer._lerp_pakaian`.
func _lerp_pakaian(delta: float, target: Dictionary) -> void:
	var k := minf(1.0, delta * 8.0)
	if _sarung != null:
		_sarung.scale = _sarung.scale.lerp(target["sarung_scale"], k)
		_sarung.position.y = lerpf(_sarung.position.y, target["sarung_y"], k)
	if _sarung_hem != null:
		_sarung_hem.scale = _sarung_hem.scale.lerp(target["hem_scale"], k)
		_sarung_hem.position.y = lerpf(_sarung_hem.position.y, target["hem_y"], k)
	if _sarung_trim != null:
		_sarung_trim.position.y = lerpf(_sarung_trim.position.y, target["trim_y"], k)
	if _lutut_l != null:
		_lutut_l.scale = _lutut_l.scale.lerp(target["lutut_scale"], k)
		_lutut_l.visible = _lutut_l.scale.length_squared() > 0.0025
	if _lutut_r != null:
		_lutut_r.scale = _lutut_r.scale.lerp(target["lutut_scale"], k)
		_lutut_r.visible = _lutut_r.scale.length_squared() > 0.0025
	if _torso != null:
		_torso.scale = _torso.scale.lerp(target["torso_scale"], k)
	if _peci != null:
		_peci.scale.z = lerpf(_peci.scale.z, target["peci_z"], k)
