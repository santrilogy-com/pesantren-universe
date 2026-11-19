class_name RoomConfig
## ROOM-CONFIG — SATU sumber kebenaran aturan ruangan multiplayer Fase 1.
##
## Cap, zona, kecepatan, dan angka validasi HANYA di sini. DILARANG
## menulis angka cap (8/20/100) atau angka zona di file lain — semua
## kode (NetworkManager, tes) MEMBACA dari sini. Menaikkan cap nanti
## = ubah SATU baris MAX_PLAYERS_PER_ROOM + uji (PREP §2.2).
##
## ZONA — DIVERIFIKASI dari kode dunia 18 Nov 2026 (Saka), bukan karangan:
## - Tembok keliling putri x 115..216, z -70..+40:
##   scripts/tembok_putri.gd KELILING_X_MIN/MAX, KELILING_Z_MIN/MAX.
## - Tembok pemisah x=14 (z -60..+16) + gerbang (14,0):
##   scripts/pesantren_builder.gd TEMBOK_X, TEMBOK_GARIS, GERBANG_POS.
## - Gerbang putri (115,0): tembok_putri.gd GERBANG_PUTRI_POS.
## - Titik spawn: PesantrenBuilder.SPAWN (-4,0,14),
##   KampusPutri.SPAWN_PUTRI (140,0,16).
## CATATAN: komentar lama "zona penyangga x 14..124" di
## pesantren_builder.gd BASI (sebelum perluasan Mira 18 Nov) — yang
## benar 14..115 (tembok keliling barat kini x=115).
##
## Aturan Fase 1 (brief Dimas): putra DILARANG masuk persegi kampus
## putri (x 115..216, z -70..+40); putri DILARANG masuk x < 14; zona
## penyangga (14 <= x < 115) dipakai bersama. Ini aturan SERVER yang
## otoritatif. _cek_batas klien (main.gd, Ronde 21) masih memakai
## aturan lama yang LEBIH KETAT untuk putra (dilarang x>14 & z<16)
## dan LEBIH LONGGAR untuk putri (boleh x<14 bila z>=16) — perbedaan
## itu dicatat untuk Dimas; server yang memutuskan.
##
## Outfit: endpoint validate v1.5.2 hanya mengembalikan
## {"id","nama","jenis_kelamin"} (server.py _realtime_ticket_validate)
## — TIDAK ADA kolom outfit di DB. Outfit dibangun dari
## MissionData.OUTFIT_DEFAULT + flag muslimah/hijab dari jenis
## kelamin — aturan yang SAMA dengan main.gd:967-971 (login lokal).

## Cap kode Fase 1 (PREP §2.2 butir 4: cap operasi 20 nanti hanya
## ubah baris ini). Peer ke-9 DITOLAK server ("ruangan penuh").
const MAX_PLAYERS_PER_ROOM := 8

## --- Zona (dirujuk dari kode dunia — nilai terverifikasi di komentar) ---
## Tembok pemisah putra/putri (pesantren_builder.gd TEMBOK_X).
const TEMBOK_X: float = PesantrenBuilder.TEMBOK_X  # 14.0
## Persegi kampus putri (tembok_putri.gd KELILING_*).
const PUTRI_X_MIN: float = TembokPutri.KELILING_X_MIN  # 115.0
const PUTRI_X_MAX: float = TembokPutri.KELILING_X_MAX  # 216.0
const PUTRI_Z_MIN: float = TembokPutri.KELILING_Z_MIN  # -70.0
const PUTRI_Z_MAX: float = TembokPutri.KELILING_Z_MAX  # 40.0

## --- Gerak + validasi posisi server ---
## Kecepatan jalan maksimal (PREP §1.2: 6 m/s pada 10 Hz).
const MAX_SPEED_MPS := 6.0
## Langkah maksimal antar dua sampel posisi berurutan yang diamati
## server (10 Hz): 6 m/s x 0,2 dtk (dua langkah replikasi bila fase
## tick server dan replikasi tidak sejajar) + slack 0,8 m. Di atas
## ini = teleport / terlalu cepat -> ditolak.
const MAX_LANGKAH_METER := 2.0
## Interval tick validasi server (sama dengan laju replikasi 10 Hz).
const VALIDATION_INTERVAL_SEC := 0.1
## Batas waktu peer mengirim tiket setelah connect (detik).
const TICKET_TIMEOUT_SEC := 10.0
## Jeda minimum antar RPC zone_reject ke peer yang sama (detik) —
## supaya klien yang mengabaikan penolakan tidak dibanjiri RPC.
const REJECT_COOLDOWN_SEC := 0.5
## Batas z peta interior (semua interior di z ~ -295..-300):
## posisi dengan z < -200 dianggap di dalam interior — teleport
## masuk/keluar interior dilewati validasi kecepatan (lihat
## NetworkManager._validasi_posisi).
const INTERIOR_Z_MAX := -200.0
## Arah hadap saat spawn (main.gd _teleport_player(spawn, PI)).
const SPAWN_YAW_RAD := PI
## Timeout HTTP validasi tiket ke API (detik).
const VALIDATE_TIMEOUT_SEC := 5.0


## Titik spawn sesuai gender — dari kode dunia, JANGAN karang.
static func titik_spawn(jenis_kelamin: String) -> Vector3:
	return KampusPutri.SPAWN_PUTRI if jenis_kelamin == "putri" else PesantrenBuilder.SPAWN


## Apakah posisi ini di zona larangan untuk gender itu (aturan Fase 1)?
static func di_zona_larangan(jenis_kelamin: String, pos: Vector3) -> bool:
	if jenis_kelamin == "putri":
		return pos.x < TEMBOK_X
	return pos.x >= PUTRI_X_MIN and pos.x <= PUTRI_X_MAX and pos.z >= PUTRI_Z_MIN and pos.z <= PUTRI_Z_MAX


## Apakah posisi ini titik teleport yang sah di dunia luar (bukan
## cheat)? Dipakai validasi: reset posisi ("Kamu kembali ke depan
## Surau", main.gd) selalu ke titik spawn — lompatan ke sana
## diterima, bukan ditolak sebagai teleport.
static func di_titik_teleport_sah(pos: Vector3) -> bool:
	return pos.distance_to(PesantrenBuilder.SPAWN) <= 1.5 or pos.distance_to(KampusPutri.SPAWN_PUTRI) <= 1.5


## Outfit spawn dari jenis_kelamin DB (aturan sama dengan main.gd
## login lokal: OUTFIT_DEFAULT + muslimah/hijab untuk putri).
static func outfit_untuk(jenis_kelamin: String) -> Dictionary:
	var outfit: Dictionary = MissionData.OUTFIT_DEFAULT.duplicate()
	var putri := jenis_kelamin == "putri"
	outfit["muslimah"] = putri
	outfit["hijab"] = putri
	return outfit
