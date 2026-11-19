class_name MpSync
extends RefCounted
## MP-SYNC — SATU sumber kebenaran konfigurasi synchronizer multiplayer.
##
## Dipakai bersama oleh player.gd (avatar lokal, Jaka) dan
## remote_player.gd (avatar pemain lain, Bara) supaya konfigurasi
## replikasi TIDAK PERNAH beda antara kedua script. Kalau ada properti
## sync yang berubah di Fase 2, ubah DI SINI saja.
##
## Aturan (MULTIPLAYER-FASE1-PREP.md §1.2–§1.3):
## - sync_position + sync_yaw: REPLICATION_MODE_ALWAYS, 10 Hz.
## - pose_id + outfit: REPLICATION_MODE_ON_CHANGE (hanya saat berubah).
## - `replication_interval = 0.1` diset di MultiplayerSynchronizer-nya,
##   BUKAN di config ini (lihat REPLICATION_INTERVAL di bawah).
##
## KOREKSI terhadap pseudocode prep doc §1.3: path properti di
## SceneReplicationConfig WAJIB berbentuk `".:nama_properti"` (titik +
## titik-dua — relatif terhadap root_path synchronizer, yaitu node
## avatar). Bentuk `^"sync_position"` tanpa awalan `.` TIDAK valid;
## bentuk benarnya `^".:sync_position"` (lihat skill
## godot-multiplayer, references/replication-and-rpc.md: "e.g.
## `.:position`, `.:velocity`, ... relative to `root_path`").

## Laju replikasi sinkronisasi gerak: 10 Hz (prep doc §1.2).
## Dipakai sebagai `MultiplayerSynchronizer.replication_interval`.
const REPLICATION_INTERVAL := 0.1

## Faktor lerp interpolasi posisi/yaw avatar remote per detik.
## `position.lerp(sync_position, delta * LERP_LANCAR)` — pada 60 fps
## tiap frame menutup ~16% sisa jarak (lihat remote_player.gd).
const LERP_LANCAR := 10.0


## Bangun konfigurasi replikasi Fase 1 (objek BARU tiap panggilan —
## jangan simpan lalu ubah bersama-sama).
static func buat_config() -> SceneReplicationConfig:
	var config := SceneReplicationConfig.new()
	config.add_property(^".:sync_position")
	config.property_set_replication_mode(^".:sync_position",
		SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.add_property(^".:sync_yaw")
	config.property_set_replication_mode(^".:sync_yaw",
		SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	config.add_property(^".:pose_id")
	config.property_set_replication_mode(^".:pose_id",
		SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	config.add_property(^".:outfit")
	config.property_set_replication_mode(^".:outfit",
		SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	return config
