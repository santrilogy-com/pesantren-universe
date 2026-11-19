extends Node3D
class_name SantriNPC
## Santri NPC yang berjalan-jalan di halaman pesantren.
## MVP: hanya berjalan antar titik + sesekali mengucapkan kalimat.
## BUBBLE-ML (Gita, 17 Nov 2026 — koreksi Mas ~21:30 WIB): kalimat
## TIDAK LAGI tampil sebagai bubble kotak di atas kepala — say()
## memancarkan sinyal `pesan` yang disambung main.gd ke feed melayang
## ui.gd (tampilkan_pesan_melayang). BUKAN pemain sungguhan dan BUKAN
## multiplayer — lihat CATATAN.md. Tidak memakai fisika (gerak langsung
## via posisi).

const SPEED := 1.6

## RONDE 25 (Raka — perbaikan tembusan, D): tapak cangkang besar.
## NPC luar TIDAK PERNAH boleh berada di dalam tapak (masuk ruangan
## hanya via teleport GTA). Disalin dari skrip/test_npc_tembus.gd —
## bila tapak berubah, ubah di kedua tempat.
const TAPAK := {
	"Surau": [Vector2(-8, -24), Vector2(8, -4)],
	"Cangkruk": [Vector2(-27, -22), Vector2(-17, -14)],
	"AsramaPutra": [Vector2(-33.25, 4), Vector2(-14.75, 16)],
	"Musholla": [Vector2(128, -29), Vector2(140, -19)],
	"AsramaPutri": [Vector2(146, 3), Vector2(164, 15)],
}

## RONDE 13 — sholat berjamaah: NPC selesai menempuh satu rute
## (ke pintu / ke sajadah / pulang) — main.gd memutuskan langkah
## berikutnya (teleport masuk/keluar interior, mulai pose sholat).
signal rute_selesai(npc: SantriNPC)

## BUBBLE-ML (Gita, 17 Nov 2026): NPC mengucapkan kalimat — main.gd
## menyambung sinyal ini ke _ui.tampilkan_pesan_melayang(nama, teks)
## (satu connect per NPC di tempat NPC dibuat, di samping
## rute_selesai.connect). Tanpa sambungan, pesan hanya tidak tampil
## di mana-mana — tidak ada error.
signal pesan(nama: String, teks: String)

var _nama: String = "Santri"
var _waypoints: Array[Vector3] = []
var _visual: Node3D
var _arm_l: Node3D
var _arm_r: Node3D
var _elbow_l: Node3D
var _elbow_r: Node3D
var _leg_l: Node3D
var _leg_r: Node3D
var _knee_l: Node3D
var _knee_r: Node3D
var _bubble: Label3D # BUBBLE-ML: node dipertahankan (kontrak dict
# build_visual dipakai pemain + semua NPC) tapi TIDAK PERNAH visible
# lagi — tidak ada kode yang menyalakannya. Lihat say().
var _name_label: Label3D
# RONDE 8: label nama ditahan saat panel chat terbuka (main.gd).
var _nama_ditahan: bool = false
# RONDE 15: mode DIAM (Kyai) — berdiri tenang di tempat, idle
# badan diam saja; tidak keliling, tidak mengobrol. Dipakai SATPAM di pos (3,3)
# (ronde 20). RONDE 16: saat sesi sholat, NPC diam ikut jalan ke
# Surau sebagai IMAM (main.gd _mulai_sholat memberi rute + posisi
# imam) — _mode_sholat dicek SEBELUM _diam di _process, jadi rute
# sholat mengambil alih mode diam; selesai_sholat() mengembalikannya.
var _diam: bool = false
# RONDE 20 — perilaku ustadz/ustadzah (Mas 15:56 WIB: "duduk bersila
# sambil baca kitab khusyu'.. sesekali dia keliling pondok untuk
# ngontrol"): mesin PATROLI untuk Kyai + Ustadzah Mariyah.
# _patroli = {} (tidak patroli) atau kamus:
#   "kursi"       Vector3  posisi duduk di dalam surau/musholla
#   "kursi_yaw"   float    hadap saat duduk (kiblat)
#   "pintu_dalam" Vector3  pintu interior (untuk teleport masuk)
#   "spawn_dalam" Vector3  spawn interior (tujuan teleport masuk)
#   "pintu_luar"  Vector3  pintu luar / titik keluar (teleport keluar)
#   "rute_luar"   Array[Vector3] titik patroli di luar (sekali jalan)
# Fase: "duduk" (baca kitab, timer 45-90 dtk) -> "ke_pintu_dalam"
# (jalan ke pintu dalam) -> teleport keluar -> "patroli" (rute luar
# sekali jalan) -> "ke_pintu_luar" (jalan ke pintu luar) -> teleport
# masuk -> "ke_kursi" (jalan ke kursi) -> "duduk" lagi.
# Pintu dilewati TELEPORT (pola GTA, seperti pemain) supaya NPC tidak
# pernah menembus dinding. Sholat (_mode_sholat) dicek SEBELUM patroli
# di _process — sesi sholat mengambil alih; selesai_sholat() mengembalikan
# NPC ke fase "ke_pintu_luar" (jalan ke pintu, masuk, duduk lagi).
# Selama patroli NPC TIDAK mengobrol (khusyu' / fokus kontrol).
var _patroli: Dictionary = {}
var _patroli_fase: String = "duduk"
var _patroli_timer: float = 60.0
var _patroli_rute: Array[Vector3] = []
var _patroli_idx: int = 0
var _kitab_pangku: Node3D # RONDE 20: _kitab() player.gd mengembalikan Node3D (wadah sampul+halaman), BUKAN MeshInstance3D — deklarasi lama MeshInstance3D membuat assignment di setup() gagal (runtime error) dan setup() BERHENTI di tengah jalan: add_child(_visual) tidak jalan (NPC tidak terlihat!), blok patroli tidak jalan (Kyai/Ustadzah tetap di spawn).
# SUSULAN RONDE 20: Ustadzah Mariyah pakai abaya + jilbab — target
# lerp pakaiannya (duduk/berdiri) beda dari koko+sarung.
var _muslimah: bool = false
var _tunik: bool = false
var _sarung: MeshInstance3D
var _sarung_hem: MeshInstance3D
var _sarung_trim: MeshInstance3D
var _torso: MeshInstance3D
# RONDE 20 — ikut sholat berjamaah? Satpam TIDAK (tetap di pos).
var _ikut_sholat: bool = true
# RUANG BELAJAR CHAT (Sinta, 19 Nov 2026 — §8): duduk belajar —
# ustadz duduk selama dialog belajar terbuka (pose baca kitab
# yang sama, tanpa pose baru). yaw = arah hadap saat duduk.
var _duduk_belajar: bool = false
var _duduk_belajar_yaw: float = 0.0


## RONDE 8: sembunyikan label nama saat panel chat terbuka.
func set_nama_ditahan(ditahan: bool) -> void:
	_nama_ditahan = ditahan


## RONDE 15: apakah NPC ini berdiri tetap (mode diam)?
func berdiri_tetap() -> bool:
	return _diam


var _target: Vector3 = Vector3.ZERO
var _pause_timer: float = 2.0
var _talk_timer: float = 18.0
var _walk_time: float = 0.0
# ANIMASI-MIXAMO: dict rig primitif untuk AnimasiMixamo (dibangun
# di setup() dari hasil build_visual).
var _rig: Dictionary = {}
var _rng := RandomNumberGenerator.new()
# RONDE 4: fase idle (acak per NPC supaya tidak serempak).
var _idle_phase: float = 0.0
# RONDE 13 — sholat berjamaah: mode rute menggantikan keliling bebas.
# _rute = antrean titik jalan (koridor aman, bukan garis lurus
# menembus bangunan); _menunggu = rute habis, menunggu perintah
# main.gd (teleport / pose); _pose_sholat = sedang sholat di sajadah.
var _mode_sholat: bool = false
var _rute: Array[Vector3] = []
var _rute_idx: int = 0
var _menunggu: bool = false
var _pose_sholat: bool = false


func setup(nama_santri: String, pos: Vector3, wps: Array[Vector3], outfit: Dictionary, diam: bool = false, patroli: Dictionary = {}, ikut_sholat: bool = true) -> void:
	_nama = nama_santri
	_waypoints = wps
	_diam = diam
	_patroli = patroli
	_ikut_sholat = ikut_sholat
	_rng.randomize()
	_idle_phase = _rng.randf_range(0.0, TAU)
	position = pos
	# RONDE 11: outfit LENGKAP (kulit + kacamata + songkok), bukan
	# cuma warna sarung — supaya tiap NPC beda sekilas pandang.
	var built: Dictionary = SantriPlayer.build_visual(nama_santri, outfit)
	_visual = built["root"]
	_arm_l = built["arm_l"]
	_arm_r = built["arm_r"]
	_elbow_l = built["elbow_l"]
	_elbow_r = built["elbow_r"]
	_leg_l = built["leg_l"]
	_leg_r = built["leg_r"]
	_knee_l = built["knee_l"]
	_knee_r = built["knee_r"]
	_bubble = built["bubble"]
	_name_label = built["name_label"]
	_kitab_pangku = built["kitab_pangku"]
	_sarung = built["sarung"]
	_sarung_hem = built["sarung_hem"]
	_sarung_trim = built["sarung_trim"]
	_torso = built["torso"]
	# ANIMASI-MIXAMO: rig untuk modul animasi.
	_rig = AnimasiMixamo.rig_dari_built(built)
	# SUSULAN RONDE 20: Ustadzah Mariyah = abaya + jilbab.
	_muslimah = bool(built.get("muslimah", false))
	# SERAGAM UTAMA v2: santriwati tunik (baju+sarung) memakai
	# PAKAIAN_DEFAULT/DUDUK biasa, bukan varian abaya.
	_tunik = bool(built.get("tunik", false))
	# RONDE 20: NPC patroli (Kyai/Ustadzah) MULAI duduk di kursinya
	# di dalam surau/musholla sambil baca kitab — bukan di pos
	# spawn-nya. Kursi + hadap kiblat dari kamus patroli.
	if not _patroli.is_empty():
		position = _patroli["kursi"]
		_visual.rotation.y = float(_patroli.get("kursi_yaw", 0.0))
		_patroli_fase = "duduk"
		_patroli_timer = _rng.randf_range(45.0, 90.0)
		_patroli_rute = []
		_patroli_idx = 0
		_terapkan_duduk_baca(1.0)
	# RONDE 6 revisi 23:01 WIB: siku NPC LURUS (0.0, sama seperti
	# pemain) — lengan satu bentuk meruncing tanpa patahan sudut;
	# animasi jalan NPC tidak menyentuh siku.
	_elbow_l.rotation.x = 0.0
	_elbow_r.rotation.x = 0.0
	add_child(_visual)
	_pick_target()
	_talk_timer = _rng.randf_range(12.0, 30.0)


## RONDE 20 — apakah NPC ini ikut sholat berjamaah? (Satpam tidak.)
func ikut_sholat() -> bool:
	return _ikut_sholat


## RONDE 20 — apakah NPC patroli ini sedang di DALAM ruangan
## (duduk baca kitab / menuju pintu dalam / menuju kursi)?
func di_dalam() -> bool:
	return not _patroli.is_empty() and _patroli_fase in ["duduk", "ke_pintu_dalam", "ke_kursi"]


## RONDE 20 — apakah sedang duduk bersila baca kitab?
func sedang_duduk_baca() -> bool:
	return not _patroli.is_empty() and _patroli_fase == "duduk"


## RONDE 20 — fase patroli saat ini (untuk tes).
func patroli_fase() -> String:
	return _patroli_fase


## RONDE 20 — keluarkan NPC patroli dari ruangan ke pintu luar
## (teleport, pola GTA). Dipanggil main.gd saat sesi sholat mulai
## sementara NPC sedang duduk di dalam — rute sholat dihitung dari
## luar, bukan dari dalam ruangan.
func teleport_ke_pintu_luar() -> void:
	if not di_dalam():
		return
	position = _patroli["pintu_luar"]
	_patroli_fase = "patroli"
	_patroli_rute = []
	_patroli_idx = 0


func nama_santri() -> String:
	return _nama


## BUBBLE-ML (Gita, 17 Nov 2026): bubble 3D DIMATIKAN — say() tidak
## lagi menampilkan Label3D di atas kepala; ia memancarkan sinyal
## `pesan` supaya kalimat tampil di feed melayang ui.gd (gaya Mobile
## Legends, di atas joystick). Dipakai obrolan acak _process + ajakan
## sholat dari main.gd (baris ~1854/1864/1877) — keduanya mengalir
## lewat sini, jadi satu sambungan sinyal di main.gd menjangkau semua.
func say(teks: String, durasi: float = 5.0) -> void:
	# RONDE 6: teks panjang dipotong rapi (lihat Palette.rapikan_bubble).
	pesan.emit(_nama, Palette.rapikan_bubble(teks, 100))


## RONDE 25 (Raka — perbaikan tembusan, D): apakah segmen lurus
## dari->ke bersih dari tabrakan? Jaring pengaman jalan bebas —
## NPC jalan lurus tanpa fisika, jadi satu-satunya pertahanan adalah
## tidak memilih target yang jalurnya tertutup. Ceknya sama seperti
## skrip/test_npc_tembus.gd: 3 raycast paralel (±0,3 m, y=0,9) +
## sampel tapak tiap 1 m. Hanya StaticBody3D yang dihitung.
func _segmen_bersih(dari: Vector3, ke: Vector3) -> bool:
	var d := Vector2(ke.x - dari.x, ke.z - dari.z)
	var panjang := d.length()
	if panjang < 0.05:
		return true
	var ruang := get_viewport().get_world_3d().direct_space_state
	var arah := d / panjang
	var tegak := Vector2(-arah.y, arah.x)
	for jalur: float in [-0.3, 0.0, 0.3]:
		var off := tegak * jalur
		var q := PhysicsRayQueryParameters3D.create(
			Vector3(dari.x + off.x, 0.9, dari.z + off.y),
			Vector3(ke.x + off.x, 0.9, ke.z + off.y))
		q.collision_mask = 0xFFFFFFFF
		q.collide_with_areas = false
		q.collide_with_bodies = true
		var hit := ruang.intersect_ray(q)
		if not hit.is_empty():
			var c := hit.get("collider") as Node
			if c != null and (c is StaticBody3D):
				return false
	var n := int(panjang / 1.0) + 1
	for i in range(n + 1):
		var t := float(i) / float(n)
		var p := Vector2(dari.x, dari.z) + d * t
		for nama in TAPAK:
			var r: Array = TAPAK[nama]
			var mn: Vector2 = r[0]
			var mx: Vector2 = r[1]
			if p.x >= mn.x and p.x <= mx.x and p.y >= mn.y and p.y <= mx.y:
				return false
	return true


func _pick_target() -> void:
	if _waypoints.is_empty():
		return
	# RONDE 25 (Raka — perbaikan tembusan, D): tolak target yang
	# segmennya menabrak (raycast + tapak, lihat _segmen_bersih).
	# Belum masuk tree (setup() sebelum add_child): belum bisa
	# raycast — ambil waypoint TERDEKAT saja (segmen pendek di
	# plaza terbuka, aman); pilihan acak berikutnya (sudah di
	# dalam tree) divalidasi penuh.
	if not is_inside_tree():
		_target = _waypoint_terdekat()
		return
	var urutan: Array[Vector3] = _waypoints.duplicate()
	# Acak urutan coba dengan _rng (bukan shuffle global).
	for i in range(urutan.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := urutan[i]
		urutan[i] = urutan[j]
		urutan[j] = tmp
	for w in urutan:
		if _segmen_bersih(position, w):
			_target = w
			return
	# Fallback (jujur): tidak ada target bersih — mis. NPC sedang
	# di dalam tapak (transien sebelum D). Ambil yang terdekat
	# (berusaha keluar); pilihan berikutnya divalidasi lagi.
	_target = _waypoint_terdekat()


func _waypoint_terdekat() -> Vector3:
	var terdekat := _waypoints[0]
	var jarak_min := position.distance_squared_to(terdekat)
	for w in _waypoints:
		var j := position.distance_squared_to(w)
		if j < jarak_min:
			jarak_min = j
			terdekat = w
	return terdekat


func _process(delta: float) -> void:
	# BUBBLE-ML: blok timer bubble DIHAPUS — bubble 3D tidak pernah
	# tampil lagi (say() memancarkan sinyal `pesan`, bukan menyalakan
	# Label3D).
	# Perbaikan 15 Nov ~12:50 WIB (gelembung sapaan raksasa saat NPC dekat
	# kamera): batasi ukuran tampak NAMA. RONDE 6: bubble lebih ketat
	# (0.09) — tidak berlaku lagi, yang dibatasi kini hanya nama.
	var cam := get_viewport().get_camera_3d()
	Palette.batasi_label_kamera(_name_label, cam)
	# RONDE 5: label nama NPC hanya tampil saat kamera cukup dekat (28 m),
	# sama seperti pemain — layar bersih ala game bola.
	# RONDE 8: + ditahan saat panel chat terbuka (sama seperti pemain).
	if cam != null:
		_name_label.visible = (not _nama_ditahan) and cam.global_position.distance_to(_name_label.global_position) < 28.0
		# RONDE PERBAIKAN (Eka): label NAMA NPC juga tidak boleh
		# terpotong tembok (helper player.gd; NPC tidak punya body
		# fisika jadi tidak ada RID yang dikecualikan). Baris bubble
		# lama dihapus — BUBBLE-ML.
		var ruang := get_viewport().get_world_3d().direct_space_state
		SantriPlayer._batasi_label_dinding(_name_label, cam, ruang)
	# RONDE 13 — sholat berjamaah: alur rute/pose MENGGANTIKAN keliling
	# + ngobrol selama mode sholat (NPC tidak mengobrol sambil berjalan
	# ke Surau atau sholat).
	if _mode_sholat:
		_proses_sholat(delta)
		return
	# RUANG BELAJAR CHAT (Sinta, 19 Nov 2026 — §8): duduk belajar.
	# Di bawah sholat (sholat menang bila bentrok), di atas
	# patroli/keliling/idle. Hadap di-lerp ke yaw yang diminta,
	# pose duduk dipakai ulang dari baca kitab.
	if _duduk_belajar:
		_visual.rotation.y = lerpf(_visual.rotation.y, _duduk_belajar_yaw, minf(1.0, delta * 6.0))
		_terapkan_duduk_baca(delta)
		return
	# RONDE 20: NPC patroli (Kyai/Ustadzah) — duduk baca kitab +
	# keliling kontrol menggantikan diam/keliling bebas + ngobrol.
	if not _patroli.is_empty():
		_proses_patroli(delta)
		return
	# RONDE 15: NPC diam (Satpam) — berdiri tenang di tempat, napas
	# idle saja; tidak keliling, tidak mengobrol.
	if _diam:
		_animate_idle(delta)
		return
	_talk_timer -= delta
	if _talk_timer <= 0.0:
		say(MissionData.NPC_LINES[_rng.randi_range(0, MissionData.NPC_LINES.size() - 1)])
		_talk_timer = _rng.randf_range(25.0, 45.0)
	if _pause_timer > 0.0:
		_pause_timer -= delta
		_animate_idle(delta)
		return
	var to: Vector3 = _target - position
	to.y = 0.0
	if to.length() < 0.4:
		_pause_timer = _rng.randf_range(3.0, 8.0)
		_pick_target()
		return
	var dir := to.normalized()
	# RONDE 18: langkah DIJEPIT ke jarak tersisa — tanpa ini, delta
	# besar (lag / time_scale tinggi) membuat NPC melompati target
	# lalu berosilasi di sekitarnya dan tidak pernah sampai.
	position += dir * minf(SPEED * delta, to.length())
	_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(dir.x, dir.z), delta * 6.0)
	_walk_time += delta * 8.0
	# ANIMASI-MIXAMO: jalan lewat modul (kurva mocap, bukan sinus
	# tunggal — lihat AnimasiMixamo). Laju fase tetap 8,0 rad/dtk.
	AnimasiMixamo.terapkan_jalan(_rig, _walk_time, 1.0)


func _animate_idle(delta: float) -> void:
	# ANIMASI-MIXAMO: idle lewat modul (RONDE 10: badan diam total,
	# hanya lengan + bersiwak; fase acak per NPC supaya tidak serempak). Bobot lerp
	# dijepit 1,0 di dalam modul (pola anti-divergen yang sama
	# seperti komentar lama di bawah — dipertahankan alasannya).
	# RONDE 21b: siwak + menoleh HANYA saat idle murni — ditekan
	# saat panel misi (dialog/RB/tes) terbuka.
	AnimasiMixamo.terapkan_idle(_rig, delta, Time.get_ticks_msec() * 0.001, _idle_phase, AnimasiMixamo.panel_misi_terbuka(get_tree()))


# ---------- sholat berjamaah (RONDE 13) ----------
## Mulai menempuh rute (antrean titik). NPC berhenti mengobrol dan
## berjalan mengikuti titik-titik itu; saat rute habis, sinyal
## rute_selesai dipancarkan sekali dan NPC menunggu (idle) sampai
## main.gd memberi rute/pose berikutnya.
func mulai_rute(titik: Array[Vector3]) -> void:
	_mode_sholat = true
	_pose_sholat = false
	_menunggu = false
	_rute = titik
	_rute_idx = 0
	_pause_timer = 0.0
	# BUBBLE-ML: baris sembunyikan bubble lama dihapus — bubble tidak
	# pernah tampil, tidak ada yang perlu disembunyikan saat mulai rute.


## Mulai pose sholat di sajadah, menghadap kiblat (yaw sudah dihitung
## main.gd). RONDE 18: pose = TAKBIR statis (tangan terangkat).
func mulai_pose_sholat(yaw: float) -> void:
	_pose_sholat = true
	_visual.rotation.y = yaw
	_visual.rotation.x = 0.0
	_leg_l.rotation.x = 0.0
	_leg_r.rotation.x = 0.0
	_knee_l.rotation.x = 0.0
	_knee_r.rotation.x = 0.0


## Kembali ke keliling bebas (dipanggil main.gd saat NPC sampai rumah
## setelah sholat). Pose sholat dihentikan, arah hadap dilepas.
## RONDE 20: NPC patroli (Kyai/Ustadzah) TIDAK kembali ke keliling
## bebas — ia kembali ke siklus patroli: jalan ke pintu luar, masuk,
## duduk baca kitab lagi.
func selesai_sholat() -> void:
	_mode_sholat = false
	_pose_sholat = false
	_menunggu = false
	_rute = []
	_rute_idx = 0
	_visual.rotation.x = 0.0
	_pause_timer = _rng.randf_range(1.0, 3.0)
	if not _patroli.is_empty():
		# RONDE 20 KOREKSI: pulang ke kursi di DALAM ruangan — kalau
		# sudah di kursi (pulang_luar berakhir di rumah = kursi),
		# langsung "ke_kursi", JANGAN "ke_pintu_luar" (itu jalan
		# ~300 m keluar lewat dinding lalu masuk lagi — terlihat
		# menembus bangunan + buang 2 menit waktu game).
		if position.distance_to(_patroli["kursi"]) < 3.0:
			_patroli_fase = "ke_kursi"
		else:
			_patroli_fase = "ke_pintu_luar"
		_patroli_rute = []
		_patroli_idx = 0
		return
	_pick_target()


func sedang_sholat() -> bool:
	return _mode_sholat


func sedang_pose_sholat() -> bool:
	return _pose_sholat


## Tinggi lantai di posisi dunia (tangga + serambi Surau, EKA 18 Nov
## 2026 — temuan Rangga: NPC sholat tembus anak tangga karena
## _langkah_ke memaksa y=0). Cermin TanggaSurau.pijakan(z) + lebar
## tiap anak tangga (T3 7,2 / T2 6,6 / T1 6,0 / serambi 6,4 — lihat
## tangga_surau.gd): di luar lebar anak tangga = tanah y=0. NPC
## tidak punya fisika, jadi _langkah_ke menyetel y ke nilai ini
## supaya kaki menapak DI ATAS pijakan, bukan menembus anak tangga
## atau melayang di luar tangga. Snap instan (bukan lerp): lerp
## membuat kaki sempat tenggelam ke dalam anak tangga saat naik.
static func _tinggi_tanah(pos: Vector3) -> float:
	var h := TanggaSurau.pijakan(pos.z)
	if h <= 0.0:
		return 0.0
	var setengah_lebar := 3.6
	if pos.z < 0.4 and pos.z >= -0.2:
		setengah_lebar = 3.3
	elif pos.z < -0.2 and pos.z >= -0.8:
		setengah_lebar = 3.0
	elif pos.z < -0.8:
		setengah_lebar = 3.2
	return h if absf(pos.x) <= setengah_lebar else 0.0


## Satu langkah jalan ke `target` (animasi jalan yang sama seperti
## keliling bebas). Mengembalikan true kalau sudah sampai (< 0,4 m).
func _langkah_ke(target: Vector3, delta: float) -> bool:
	# PERBAIKAN 19 Nov 2026 (Kirana — laporan Mas "sarung mekar kek
	# lagi sila padahal dia jalan"): pulihkan pakaian normal di SETIAP
	# langkah — satu tempat ini menjangkau semua jalur jalan (patroli
	# + rute sholat + rute lain). Sebelumnya _terapkan_pakaian(DEFAULT)
	# hanya ada di 4 fase patroli; jalur sholat tidak pernah memanggil-
	# nya, jadi Kyai yang habis duduk baca (PAKAIAN_DUDUK: sarung
	# 1,70x lebar, hem y=0,50) jalan ke sajadah dengan sarung tetap
	# terhampar. Lerp menyatu dalam ~0,5 dtk (k = delta * 8).
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
	var to: Vector3 = target - position
	to.y = 0.0
	if to.length() < 0.4:
		return true
	var dir := to.normalized()
	# RONDE 18: langkah DIJEPIT ke jarak tersisa (alasan sama seperti
	# jalan bebas di atas) — rute sholat harus sampai walau delta besar.
	position += dir * minf(SPEED * delta, to.length())
	# EKA 18 Nov 2026 (temuan Rangga): ikuti tinggi medan — NPC yang
	# berjalan ke pintu Surau naik anak tangga 0,166/0,333/0,5 dan
	# serambi 0,5; tanpa ini kaki tenggelam sampai 0,5 m ke dalam
	# anak tangga/serambi. Berlaku dua arah (naik + turun).
	position.y = _tinggi_tanah(position)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(dir.x, dir.z), delta * 6.0)
	_walk_time += delta * 8.0
	# ANIMASI-MIXAMO: jalan lewat modul (sama seperti jalan bebas).
	AnimasiMixamo.terapkan_jalan(_rig, _walk_time, 1.0)
	return false


## Pose takbir (RONDE 18, skema sinematik): berdiri di sajadah,
## kedua tangan terangkat (takbiratul ihram). STATIS — tidak ada
## siklus qiyam/ruku lagi; adegan diakhiri blackout (main.gd).
func _animasi_sholat(delta: float) -> void:
	# PERBAIKAN 19 Nov 2026 (Kirana): pose takbir di sajadah juga
	# bersarung normal — Kyai yang rute sholatnya pendek bisa sampai
	# di sajadah sebelum lerp pakaian selesai.
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
	var k := minf(1.0, delta * 8.0)
	_visual.rotation.x = lerpf(_visual.rotation.x, 0.05, k)
	_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -2.6, k)
	_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -2.6, k)
	_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.15, k)
	_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.15, k)
	_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.6, k)
	_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.6, k)
	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
	_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
	_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
	_visual.position.y = lerpf(_visual.position.y, 0.0, k)


## Per-frame selama mode sholat: pose, menunggu, atau menempuh rute.
func _proses_sholat(delta: float) -> void:
	if _pose_sholat:
		_animasi_sholat(delta)
		return
	if _menunggu:
		_animate_idle(delta)
		return
	if _rute_idx >= _rute.size():
		_menunggu = true
		rute_selesai.emit(self)
		return
	if _langkah_ke(_rute[_rute_idx], delta):
		_rute_idx += 1


# ---------- patroli ustadz/ustadzah (RONDE 20) ----------
## Mesin fase patroli (lihat _patroli_fase). Pintu dilewati TELEPORT
## (pola GTA) — NPC tidak pernah berjalan menembus dinding/pagar.
func _proses_patroli(delta: float) -> void:
	match _patroli_fase:
		"duduk":
			_patroli_timer -= delta
			_terapkan_duduk_baca(delta)
			if _patroli_timer <= 0.0:
				# Selesai baca — kitab disimpan, jalan ke pintu dalam.
				if _kitab_pangku != null:
					_kitab_pangku.visible = false
				_patroli_fase = "ke_pintu_dalam"
		"ke_pintu_dalam":
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			if _langkah_ke(_patroli["pintu_dalam"], delta):
				# Teleport keluar (GTA): pintu dalam -> pintu luar.
				position = _patroli["pintu_luar"]
				# RONDE 20 KOREKSI: assign(), BUKAN "=" — rute_luar
				# dari Dictionary main.gd itu Array TAK-BERTIPE;
				# "=" ke Array[Vector3] melempar SCRIPT ERROR dan
				# _proses_patroli BERHENTI sebelum fase jadi
				# "patroli" (NPC macet di ke_pintu_dalam, teleport
				# bolak-balik pintu — tes ronde 20 kedua menangkapnya).
				_patroli_rute.assign(_patroli["rute_luar"])
				_patroli_idx = 0
				_patroli_fase = "patroli"
		"patroli":
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			if _patroli_rute.is_empty() or _patroli_idx >= _patroli_rute.size():
				_patroli_fase = "ke_pintu_luar"
				return
			if _langkah_ke(_patroli_rute[_patroli_idx], delta):
				_patroli_idx += 1
		"ke_pintu_luar":
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			if _langkah_ke(_patroli["pintu_luar"], delta):
				# Teleport masuk (GTA): pintu luar -> spawn dalam.
				position = _patroli["spawn_dalam"]
				_patroli_fase = "ke_kursi"
		"ke_kursi":
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			if _langkah_ke(_patroli["kursi"], delta):
				_visual.rotation.y = float(_patroli.get("kursi_yaw", 0.0))
				_patroli_timer = _rng.randf_range(45.0, 90.0)
				_patroli_fase = "duduk"


## Pose duduk bersila baca kitab (RONDE DUDUK 17 Nov — Mas: cara duduk
## semua karakter perlu direvisi): kaki DIBELAH paha + lutut (player.gd)
## — paha -0.85 + lutut +2.30, betis terlipat ke bawah paha, kaki
## menyilang; tangan terulur ke REHAL (lengan -0.70, siku -0.35),
## bukan di dada; kitab di pangkuan DISEMBUNYIKAN — kitabnya kini di
## atas rehal di depan Kyai/Ustadzah (interior_surau/musholla).
func _terapkan_duduk_baca(delta: float) -> void:
	var k := minf(1.0, delta * 8.0)
	# Siwak hanya hidup di idle bersiwak — begitu duduk baca,
	# siwak disembunyikan (jangan menempel di tangan saat duduk).
	var siwak := _rig.get("siwak") as Node3D
	if siwak != null:
		siwak.visible = false
	# RONDE 21b: kepala kembali tegak saat duduk baca (jangan
	# menempel menoleh dari idle).
	var kepala := _rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.y = lerpf(kepala.rotation.y, 0.0, k)
	# ANIMASI-MIXAMO: sekuens transisi duduk ala mocap — kaki
	# melipat dulu, badan menyusul, tangan terakhir ke rehal
	# (sama seperti pemain; lihat player.gd arm "duduk").
	var k_kaki := minf(1.0, delta * 12.0)
	var k_tangan := minf(1.0, delta * 5.0)
	_visual.position.y = lerpf(_visual.position.y, -0.42, k)
	_visual.rotation.x = lerpf(_visual.rotation.x, 0.20, k)
	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -0.85, k_kaki)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -0.85, k_kaki)
	_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.50, k_kaki)
	_leg_r.rotation.y = lerpf(_leg_r.rotation.y, -0.50, k_kaki)
	_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.10, k_kaki)
	_leg_r.rotation.z = lerpf(_leg_r.rotation.z, -0.10, k_kaki)
	_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 2.30, k_kaki)
	_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 2.30, k_kaki)
	_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.20, k_kaki)
	_knee_r.rotation.y = lerpf(_knee_r.rotation.y, -0.20, k_kaki)
	_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k_kaki)
	_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k_kaki)
	_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.70, k_tangan)
	_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.70, k_tangan)
	_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.18, k_tangan)
	_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.18, k_tangan)
	_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.35, k_tangan)
	_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.35, k_tangan)
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DUDUK)
	if _kitab_pangku != null:
		_kitab_pangku.visible = false


## RUANG BELAJAR CHAT (§8): duduk belajar — pakai ulang pose
## baca kitab, TANPA pose baru. yaw = arah hadap (radian).
## berdiri_belajar() mengembalikan NPC ke aktivitasnya (idle
## _process me-lerp pose kembali berdiri + pakaian default).
func duduk_belajar(yaw: float) -> void:
	_duduk_belajar = true
	_duduk_belajar_yaw = yaw


func berdiri_belajar() -> void:
	_duduk_belajar = false
	# Snap pakaian kembali ke default (delta 1.0 = lerp penuh,
	# abaya ikut dipetakan di _terapkan_pakaian) — _animate_idle
	# di _process mengembalikan pose badan/kaki ke berdiri.
	_terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)


func sedang_duduk_belajar() -> bool:
	return _duduk_belajar


## Lerp pakaian NPC ke target (pola player.gd _lerp_pakaian):
## sarung mengerut saat duduk, normal saat jalan.
func _terapkan_pakaian(delta: float, target: Dictionary) -> void:
	# SUSULAN RONDE 20: abaya Ustadzah punya target duduk/berdiri
	# SENDIRI — PAKAIAN_DUDUK (sarung mengerut y 0.45) akan
	# menghancurkan gamis panjang (1,32 m) sampai lutut dan membuka
	# kaki bersila; abaya duduk = melebar + sedikit memendek, tetap
	# menutupi kaki bersila sampai lantai. Satu pemetaan di sini
	# menjangkau semua pemanggil (duduk baca + 4 fase patroli).
	# SERAGAM UTAMA v2: santriwati tunik TIDAK dipetakan ke abaya —
	# sarungnya tabung biasa (PAKAIAN_DEFAULT/DUDUK).
	if _muslimah and not _tunik:
		if target == SantriPlayer.PAKAIAN_DUDUK:
			target = SantriPlayer.PAKAIAN_ABAYA_DUDUK
		elif target == SantriPlayer.PAKAIAN_DEFAULT:
			target = SantriPlayer.PAKAIAN_ABAYA_DEFAULT
	var k := minf(1.0, delta * 8.0)
	if _sarung != null:
		_sarung.scale = _sarung.scale.lerp(target["sarung_scale"], k)
		_sarung.position.y = lerpf(_sarung.position.y, target["sarung_y"], k)
	if _sarung_hem != null:
		_sarung_hem.scale = _sarung_hem.scale.lerp(target["hem_scale"], k)
		_sarung_hem.position.y = lerpf(_sarung_hem.position.y, target["hem_y"], k)
	if _sarung_trim != null:
		_sarung_trim.position.y = lerpf(_sarung_trim.position.y, target["trim_y"], k)
	if _torso != null:
		_torso.scale = _torso.scale.lerp(target["torso_scale"], k)
