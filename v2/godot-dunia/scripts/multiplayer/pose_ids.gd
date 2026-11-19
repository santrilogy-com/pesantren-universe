class_name PoseIds
## SATU SUMBER KEBENARAN nilai pose multiplayer (Fase 1, Jaka, 18 Nov 2026).
##
## `pose_id` adalah int yang direplikasi lewat MultiplayerSynchronizer
## (REPLICATION_MODE_ON_CHANGE) — hemat byte dan tidak ambigu, tidak
## seperti string aksi. SEMUA kode (player.gd, remote_player.gd, server)
## WAJIB memakai konstanta di sini; JANGAN hardcode angka pose di mana
## pun. Nilai mengikuti MULTIPLAYER-FASE1-PREP.md §1.2 (0 idle, 1 jalan,
## 2 duduk, 3 sholat) + lanjutan untuk aksi lain yang dipakai `set_aksi`
## di player.gd.
##
## "bawa_kitab" TIDAK punya pose — itu toggle overlay (kitab di tangan)
## yang menempel di atas pose dasar (berdiri/jalan), bukan pose sendiri.
## Karena itu `dari_aksi("bawa_kitab")` mengembalikan -1: pemanggil
## harus menanganinya sebagai toggle, bukan mengganti pose_id.

const POSE_IDLE := 0
const POSE_JALAN := 1
const POSE_DUDUK := 2
const POSE_SHOLAT := 3
const POSE_MENULIS := 4
const POSE_SALAMAN := 5
const POSE_MELAMBAI := 6
const POSE_TIDUR := 7


## Nama aksi (string `set_aksi`) -> pose_id. -1 = bukan pose
## ("bawa_kitab" = toggle; nama tak dikenal = bukan pose).
static func dari_aksi(nama_aksi: String) -> int:
	match nama_aksi:
		"berdiri":
			return POSE_IDLE
		# "jalan" BUKAN nama set_aksi UI — keadaan bergerak (dipakai
		# _perbarui_pose_id di player.gd); kebalikan ke_aksi-nya ada
		# supaya tabel round-trip, bukan untuk dipanggil set_aksi.
		"jalan":
			return POSE_JALAN
		"duduk":
			return POSE_DUDUK
		"sholat":
			return POSE_SHOLAT
		"menulis":
			return POSE_MENULIS
		"salaman":
			return POSE_SALAMAN
		"melambai":
			return POSE_MELAMBAI
		"tidur":
			return POSE_TIDUR
	return -1


## pose_id -> nama aksi (string `set_aksi`). Dipakai avatar remote
## untuk memainkan pose yang sama persis dari `pose_id` yang diterima.
## pose_id tak dikenal -> "berdiri" (aman: pose netral).
static func ke_aksi(pose_id: int) -> String:
	match pose_id:
		POSE_IDLE:
			return "berdiri"
		POSE_JALAN:
			return "jalan"
		POSE_DUDUK:
			return "duduk"
		POSE_SHOLAT:
			return "sholat"
		POSE_MENULIS:
			return "menulis"
		POSE_SALAMAN:
			return "salaman"
		POSE_MELAMBAI:
			return "melambai"
		POSE_TIDUR:
			return "tidur"
	return "berdiri"


## Apakah pose ini menahan gerak (avatar diam di tempat)? Cerminan
## `SantriPlayer.sedang_aksi_diam()` dalam bentuk pose_id — dipakai
## server/remote tanpa perlu tahu string aksi.
static func aksi_diam(pose_id: int) -> bool:
	return pose_id in [POSE_DUDUK, POSE_MENULIS, POSE_TIDUR, POSE_SALAMAN, POSE_MELAMBAI, POSE_SHOLAT]
