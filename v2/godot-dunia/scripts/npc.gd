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
	# 19 Nov (Gilang): Kantor Putra SEMENTARA — PINDAH 18:40 WIB
	# (perintah Mas "sebelah asrama tapi agak jauh"): (-18,22.5),
	# 6x5 m, celah 4 m dari dinding selatan Asrama Putra.
	# Salinan di skrip/test_npc_tembus.gd CANGKANG ikut diubah.
	"KantorPutra": [Vector2(-21, 20), Vector2(-15, 25)],
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
var _lutut_l: MeshInstance3D
var _lutut_r: MeshInstance3D
var _drape: MeshInstance3D
var _juntai: MeshInstance3D
var _torso: MeshInstance3D
# RONDE 20 — ikut sholat berjamaah? Satpam TIDAK (tetap di pos).
var _ikut_sholat: bool = true
# RUANG BELAJAR CHAT (Sinta, 19 Nov 2026 — §8): duduk belajar —
# ustadz duduk selama dialog belajar terbuka (pose baca kitab
# yang sama, tanpa pose baru). yaw = arah hadap saat duduk.
var _duduk_belajar: bool = false
var _duduk_belajar_yaw: float = 0.0
# 20 NPC v1 (Raka, 19 Nov 2026) — MESIN AKTIVITAS santri (duduk/baca/
# jalan kitab). Hanya untuk NPC sistem baru (`_aktivitas_aktif` dari
# setup()); Bilal/Faris/Kyai/dll tidak berubah. Prioritas di _process:
# sholat > duduk_belajar > jeda hormat > patroli > diam > aktivitas >
# keliling bebas. _aktivitas: "" / "ke_kursi" / "duduk" / "ke_kamar" /
# "baca_kamar" / "jalan_kitab" / "baca_musholla".
var _aktivitas_aktif: bool = false
var _aktivitas: String = ""
var _aktivitas_timer: float = 0.0
var _aktivitas_kursi: Dictionary = {}
var _aktivitas_rute: Array[Vector3] = []
var _aktivitas_rute_idx: int = 0
var _aktivitas_tunggu: float = 0.0
var _aktivitas_yaw: float = 0.0
var _kitab_tangan: Node3D = null
# 20 NPC v1 — HORMAT ke guru. _hormat: "" / "a_minggir" / "b_hampiri" /
# "b_salaman" / "b_cium" / "b_kembali". _hormat_dari_duduk = hormat
# dimulai saat duduk (kursi DITAHAN, kembali duduk sesudahnya).
var _hormat: String = ""
var _hormat_timer: float = 0.0
var _hormat_guru: Node3D = null
var _hormat_pos_awal: Vector3 = Vector3.ZERO
var _hormat_tujuan: Vector3 = Vector3.ZERO
var _hormat_dari_duduk: bool = false
var _hormat_aktivitas_tersimpan: Dictionary = {}
var _hormat_cooldown_npc: float = 0.0
var _hormat_pasangan: Dictionary = {}
# SALAMAN PEMAIN (Raka, 20 Nov 2026) — NPC merespons salaman yang
# dipicu pemain (main.gd _on_aksi "salaman"). _salaman: "" / "hadap" /
# "hampiri" / "jabat". _salaman_aktivitas_tersimpan = simpanan
# aktivitas pola hormat (kursi DITAHAN, dipulihkan di _akhiri_salaman).
var _salaman: String = ""
var _salaman_timer: float = 0.0
var _salaman_pemain: Node3D = null
var _salaman_cooldown: float = 0.0
var _salaman_aktivitas_tersimpan: Dictionary = {}
# 20 NPC v1 — jeda patroli (guru berhenti ±4 dtk saat disalami).
var _jeda_sampai: float = 0.0


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


func setup(nama_santri: String, pos: Vector3, wps: Array[Vector3], outfit: Dictionary, diam: bool = false, patroli: Dictionary = {}, ikut_sholat: bool = true, aktivitas: bool = false, tinggi_skala: float = 1.0) -> void:
	_nama = nama_santri
	_waypoints = wps
	_diam = diam
	_patroli = patroli
	_ikut_sholat = ikut_sholat
	# 20 NPC v1: mesin aktivitas + variasi tinggi badan (skala visual).
	_aktivitas_aktif = aktivitas
	_rng.randomize()
	_idle_phase = _rng.randf_range(0.0, TAU)
	position = pos
	# RONDE 11: outfit LENGKAP (kulit + kacamata + songkok), bukan
	# cuma warna sarung — supaya tiap NPC beda sekilas pandang.
	var built: Dictionary = SantriPlayer.build_visual(nama_santri, outfit)
	_visual = built["root"]
	# 20 NPC v1: variasi tinggi badan — skala visual (0.96..1.05).
	# Anak-anak visual (sarung/hem/pakaian) memakai skala lokal
	# sendiri, jadi lerp pakaian tidak terganggu; label nama ikut
	# skala ±5% (diabaikan). Posisi _visual tidak diskala.
	if tinggi_skala != 1.0:
		_visual.scale = Vector3(1.0, tinggi_skala, 1.0)
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
	# 20 NPC v1: kitab tangan (JALAN_KITAB) — anak arm_r, tersembunyi
	# sampai aktivitas jalan kitab. built lama tanpa kunci ini -> null.
	_kitab_tangan = built.get("kitab_tangan")
	_sarung = built["sarung"]
	_sarung_hem = built["sarung_hem"]
	_sarung_trim = built["sarung_trim"]
	_lutut_l = built["lutut_l"]
	_lutut_r = built["lutut_r"]
	_drape = built["drape"]
	_juntai = built["juntai"]
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


## 20 NPC v1 — apakah NPC ini santriwati? (rute sholat ke Musholla +
## kursi putri). Dibaca dari outfit (muslimah).
func adalah_putri() -> bool:
	return _muslimah


## 20 NPC v1 — guru berhenti ±4 dtk saat disalami (varian B).
## Dicek di _process (di bawah sholat/duduk_belajar, di atas patroli)
## supaya berlaku untuk guru patroli MAUPUN keliling bebas.
func jeda_patroli(detik: float) -> void:
	_jeda_sampai = Time.get_ticks_msec() / 1000.0 + detik


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
	# SALAMAN PEMAIN: cooldown berkurang terus (bukan cuma saat
	# _cek_hormat jalan — NPC patroli/diam tidak pernah ke sana).
	if _salaman_cooldown > 0.0:
		_salaman_cooldown -= delta
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
	# ADEGAN TES DI DALAM KANTOR (Gilang, 20 Nov 2026): penguji
	# duduk di kursi penguji — di atas patroli/diam (seperti
	# duduk_belajar). Kursi tes selalu jenis "kursi" (kaki
	# menjuntai); kitab pangku terlihat (penguji membawa kitab).
	if _duduk_tes:
		_visual.rotation.y = lerpf(_visual.rotation.y, _duduk_tes_yaw, minf(1.0, delta * 6.0))
		_terapkan_duduk_kursi(delta, float((_duduk_tes_kursi["pos"] as Vector3).y), true)
		return
	# SALAMAN PEMAIN (Raka, 20 Nov 2026): NPC merespons salaman yang
	# dipicu pemain — di bawah sholat/duduk_belajar, di atas
	# jeda/patroli/aktivitas: NPC berhenti sejenak, hadap pemain,
	# jabat tangan, lalu lanjut aktivitas semula.
	if _salaman != "":
		_proses_salaman(delta)
		return
	# 20 NPC v1 — jeda hormat: guru yang sedang disalami berhenti
	# ±4 dtk (di bawah sholat/duduk_belajar, di atas patroli/keliling).
	if _jeda_sampai > 0.0 and Time.get_ticks_msec() / 1000.0 < _jeda_sampai:
		_animate_idle(delta)
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
	# 20 NPC v1 — hormat ke guru (di atas aktivitas/keliling; mati
	# saat sholat — sudah return di atas — dan saat panel misi terbuka,
	# dicek di dalam _cek_hormat).
	if _aktivitas_aktif and _hormat == "":
		_cek_hormat(delta)
	if _hormat != "":
		_proses_hormat(delta)
		return
	# 20 NPC v1 — mesin aktivitas (duduk/baca/jalan kitab).
	if _aktivitas != "":
		_proses_aktivitas(delta)
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
		# 20 NPC v1: sampai di waypoint = kesempatan mulai aktivitas.
		_coba_mulai_aktivitas()
		return
	var dir := to.normalized()
	# RONDE 18: langkah DIJEPIT ke jarak tersisa — tanpa ini, delta
	# besar (lag / time_scale tinggi) membuat NPC melompati target
	# lalu berosilasi di sekitarnya dan tidak pernah sampai.
	position += dir * minf(SPEED * delta, to.length())
	# PERBAIKAN BUG 1+4 (Kirana, 20 Nov 2026): jalur keliling bebas
	# tidak lewat _langkah_ke — NPC yang selesai duduk lalu jalan
	# bebas tetap memakai PAKAIAN_DUDUK + melayang di tinggi kursi
	# sampai ada rute yang memanggil _langkah_ke. Pulihkan pakaian +
	# jepit y ke tanah di sini (cermin _langkah_ke).
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
	position.y = _tinggi_tanah(position)
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
	# PERBAIKAN BUG 1 (Kirana, 20 Nov 2026 — Mas: "sarung mekar pas
	# berdiri setelah duduk"): idle = keadaan BERDIRI — pakaian WAJIB
	# kembali normal di sini. Sebelumnya hanya _langkah_ke yang
	# memulihkan, jadi NPC yang selesai duduk lalu DIAM (pause/idle/
	# jeda hormat) berdiri dengan PAKAIAN_DUDUK menempel sampai ia
	# jalan lagi. Modul idle me-lerp visual ke 0 — pakaian ikut.
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
	AnimasiMixamo.terapkan_idle(_rig, delta, Time.get_ticks_msec() * 0.001, _idle_phase, AnimasiMixamo.panel_misi_terbuka(get_tree()))


# ---------- sholat berjamaah (RONDE 13) ----------
## Mulai menempuh rute (antrean titik). NPC berhenti mengobrol dan
## berjalan mengikuti titik-titik itu; saat rute habis, sinyal
## rute_selesai dipancarkan sekali dan NPC menunggu (idle) sampai
## main.gd memberi rute/pose berikutnya.
func mulai_rute(titik: Array[Vector3]) -> void:
	# 20 NPC v1: sholat membatalkan hormat + aktivitas (kursi dilepas,
	# NPC kembali keliling bebas setelah sholat via selesai_sholat).
	if _hormat != "":
		_batalkan_hormat()
	if _salaman != "":
		_batalkan_salaman()
	if _aktivitas != "":
		_akhiri_aktivitas()
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
## `laju` (20 NPC v1): pengali kecepatan — JALAN_KITAB jalan 0,5x
## (fase animasi ikut diperlambat supaya kaki tidak moonwalk).
## Default 1.0 = semua pemanggil lama tidak berubah.
func _langkah_ke(target: Vector3, delta: float, laju: float = 1.0) -> bool:
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
	position += dir * minf(SPEED * laju * delta, to.length())
	# EKA 18 Nov 2026 (temuan Rangga): ikuti tinggi medan — NPC yang
	# berjalan ke pintu Surau naik anak tangga 0,166/0,333/0,5 dan
	# serambi 0,5; tanpa ini kaki tenggelam sampai 0,5 m ke dalam
	# anak tangga/serambi. Berlaku dua arah (naik + turun).
	position.y = _tinggi_tanah(position)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(dir.x, dir.z), delta * 6.0)
	_walk_time += delta * 8.0 * laju
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
## 20 NPC v1: `kitab_terlihat=true` untuk santri (tidak ada rehal —
## kitab tetap di pangkuan). Default false = perilaku lama.
## REVISI BERSILA v2 (Kirana, 20 Nov 2026 — bug 2 Mas): yaw kaki
## DIBALIK (dulu kiri +0.50 / kanan -0.50 — kedua lutut bertemu di
## tengah depan, alas sempit seperti kerucut; kini kiri -0.50 / kanan
## +0.50 — lutut melebar ±0,22 ke samping, betis menyilang di bawah
## paha). `tinggi_duduk` = tinggi permukaan duduk di atas tanah node
## (0 lantai; 0,51 kasur -> visual +0,09) — node SELALU di tanah.
func _terapkan_duduk_baca(delta: float, kitab_terlihat: bool = false, tinggi_duduk: float = 0.0) -> void:
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
	_visual.position.y = lerpf(_visual.position.y, tinggi_duduk - 0.42, k)
	_visual.rotation.x = lerpf(_visual.rotation.x, 0.20, k)
	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -0.85, k_kaki)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -0.85, k_kaki)
	_leg_l.rotation.y = lerpf(_leg_l.rotation.y, -0.50, k_kaki)
	_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.50, k_kaki)
	_leg_l.rotation.z = lerpf(_leg_l.rotation.z, -0.10, k_kaki)
	_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.10, k_kaki)
	_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 2.30, k_kaki)
	_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 2.30, k_kaki)
	_knee_l.rotation.y = lerpf(_knee_l.rotation.y, -0.20, k_kaki)
	_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.20, k_kaki)
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
		_kitab_pangku.visible = kitab_terlihat


## Pose DUDUK KURSI (Kirana, 20 Nov 2026 — bug 3 Mas: "duduk di kursi
## malah bersila di kursi"): kaki MENJUNTAI, bukan bersila — paha
## hampir horizontal ke depan (-1.45), betis vertikal ke bawah
## (lutut +1.45), telapak menggantung ~13 cm di atas lantai. Pinggul
## di tinggi kursi: visual = tinggi_duduk - 0,62 (kursi 0,45 ->
## -0,17). Tangan di pangkuan (lengan -0,50, siku -0,30). Pakaian =
## PAKAIAN_KURSI (sarung pendek menutupi paha + lutut; abaya ikut
## dipetakan di _terapkan_pakaian). Cermin player.gd "duduk_kursi".
func _terapkan_duduk_kursi(delta: float, tinggi_duduk: float = 0.45, kitab_terlihat: bool = true) -> void:
	var k := minf(1.0, delta * 8.0)
	var siwak_k := _rig.get("siwak") as Node3D
	if siwak_k != null:
		siwak_k.visible = false
	var kepala_k := _rig.get("kepala") as Node3D
	if kepala_k != null:
		kepala_k.rotation.y = lerpf(kepala_k.rotation.y, 0.0, k)
	var k_kaki := minf(1.0, delta * 12.0)
	var k_tangan := minf(1.0, delta * 5.0)
	_visual.position.y = lerpf(_visual.position.y, tinggi_duduk - 0.62, k)
	_visual.rotation.x = lerpf(_visual.rotation.x, 0.05, k)
	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -1.45, k_kaki)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -1.45, k_kaki)
	_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k_kaki)
	_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k_kaki)
	_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.06, k_kaki)
	_leg_r.rotation.z = lerpf(_leg_r.rotation.z, -0.06, k_kaki)
	_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 1.45, k_kaki)
	_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 1.45, k_kaki)
	_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k_kaki)
	_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k_kaki)
	_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k_kaki)
	_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k_kaki)
	_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.50, k_tangan)
	_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.50, k_tangan)
	_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k_tangan)
	_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k_tangan)
	_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.30, k_tangan)
	_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.30, k_tangan)
	_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_KURSI)
	if _kitab_pangku != null:
		_kitab_pangku.visible = kitab_terlihat


## Pose duduk mengikuti JENIS kursi yang sedang diduduki
## (_aktivitas_kursi): "kursi" = duduk_kursi (kaki menjuntai),
## "kasur" = bersila di atas kasur (visual +0,09), "bersila" =
## bersila di lantai. Dipakai cabang "duduk" + "baca_kamar".
func _terapkan_duduk_sesuai_kursi(delta: float, kitab_terlihat: bool) -> void:
	if _aktivitas_kursi.is_empty():
		_terapkan_duduk_baca(delta, kitab_terlihat)
		return
	var jenis := String(_aktivitas_kursi.get("jenis", "bersila"))
	var sp: Vector3 = _aktivitas_kursi["pos"]
	if jenis == "kursi":
		_terapkan_duduk_kursi(delta, sp.y, kitab_terlihat)
	else:
		_terapkan_duduk_baca(delta, kitab_terlihat, sp.y)


## Titik lantai DI DEPAN kursi untuk bangun (bug 4): pakai "bangun"
## dari registry kursi pemain (KursiPemain) bila id-nya cocok (28
## kursi berbagi NPC/pemain — bangun kelas di lorong, BUKAN ke arah
## meja); bila tidak ada: 0,8 m ke arah hadap duduk ("kursi") atau
## 1,5 m ke selatan kaki kasur ("kasur"). y dihitung pemanggil via
## _tinggi_tanah (bangun registry sudah y = lantai).
func _titik_bangun(kursi: Dictionary) -> Vector3:
	# Kursi tes (KURSI_TES) + registry pemain membawa "bangun"
	# sendiri — pakai itu dulu (bangun di lorong / belakang kursi,
	# BUKAN ke arah meja).
	if kursi.has("bangun"):
		return kursi["bangun"]
	var id := String(kursi.get("id", ""))
	if id != "":
		var entri: Dictionary = KursiPemain.dari_id(id)
		if not entri.is_empty() and entri.has("bangun"):
			return entri["bangun"]
	var sp: Vector3 = kursi["pos"]
	if String(kursi.get("jenis", "")) == "kasur":
		return sp + Vector3(0, 0, 1.5)
	var depan := Vector3(sin(_aktivitas_yaw), 0.0, cos(_aktivitas_yaw))
	return sp + depan * 0.8


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


## ADEGAN TES DI DALAM KANTOR (Gilang, 20 Nov 2026 — konsep Laras,
## ACC Mas 00:37 WIB): penguji duduk deterministik di kursi penguji.
## Teleport langsung (tanpa rute jalan, tanpa mesin aktivitas:
## Sanusi/Fatimah mode DIAM, _proses_aktivitas tidak jalan untuk
## mereka). Duduk sampai berdiri_tes() dipanggil main.gd — BUKAN
## timer acak seperti aktivitas DUDUK_KURSI biasa. Dipakai
## _cek_penguji_tes() di main.gd (hanya saat langkah 6).
var _duduk_tes: bool = false
var _duduk_tes_yaw: float = 0.0
var _duduk_tes_kursi: Dictionary = {}


func duduk_tes(kursi: Dictionary) -> void:
	if kursi.is_empty():
		return
	if _aktivitas != "":
		_akhiri_aktivitas()
	# Adegan belajar (langkah 5) sudah selesai saat langkah 6
	# dimulai — pastikan flag-nya bersih supaya cabang _process
	# duduk_tes tidak kalah oleh duduk_belajar.
	berdiri_belajar()
	_duduk_tes = true
	_duduk_tes_kursi = kursi
	_duduk_tes_yaw = float(kursi.get("yaw", 0.0))
	_aktivitas_yaw = _duduk_tes_yaw
	var sp: Vector3 = kursi["pos"]
	position = Vector3(sp.x, _tinggi_tanah(sp), sp.z)
	_visual.rotation.y = _duduk_tes_yaw


func berdiri_tes() -> void:
	if not _duduk_tes:
		return
	_duduk_tes = false
	var bangun := _titik_bangun(_duduk_tes_kursi)
	position = Vector3(bangun.x, _tinggi_tanah(bangun), bangun.z)
	_terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)
	_visual.position.y = 0.0
	_duduk_tes_kursi = {}


func sedang_duduk_tes() -> bool:
	return _duduk_tes


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
		elif target == SantriPlayer.PAKAIAN_KURSI:
			target = SantriPlayer.PAKAIAN_ABAYA_KURSI
	var k := minf(1.0, delta * 8.0)
	if _sarung != null:
		_sarung.scale = _sarung.scale.lerp(target["sarung_scale"], k)
		_sarung.position.y = lerpf(_sarung.position.y, target["sarung_y"], k)
		_sarung.position.z = lerpf(_sarung.position.z, target["sarung_z"], k)
		_sarung.rotation.x = lerpf(_sarung.rotation.x, target["sarung_rot_x"], k)
	if _sarung_hem != null:
		_sarung_hem.scale = _sarung_hem.scale.lerp(target["hem_scale"], k)
		_sarung_hem.position.y = lerpf(_sarung_hem.position.y, target["hem_y"], k)
		_sarung_hem.position.z = lerpf(_sarung_hem.position.z, target["hem_z"], k)
	if _sarung_trim != null:
		_sarung_trim.position.y = lerpf(_sarung_trim.position.y, target["trim_y"], k)
		_sarung_trim.scale = _sarung_trim.scale.lerp(target["trim_scale"], k)
	if _lutut_l != null:
		_lutut_l.scale = _lutut_l.scale.lerp(target["lutut_scale"], k)
		_lutut_l.visible = _lutut_l.scale.length_squared() > 0.0025
	if _lutut_r != null:
		_lutut_r.scale = _lutut_r.scale.lerp(target["lutut_scale"], k)
		_lutut_r.visible = _lutut_r.scale.length_squared() > 0.0025
	if _drape != null:
		_drape.scale = _drape.scale.lerp(target["drape_scale"], k)
		_drape.visible = _drape.scale.length_squared() > 0.0025
		# DRAPE v6 (Kirana): drape TIDAK ikut condong badan —
		# rotasi node drape melawan condong visual (NPC 0,20)
		# supaya alas drape tetap DATAR di lantai; tanpa ini lutut
		# + cincin bawah terkubur ~20 cm di bawah lantai (akar
		# masalah v1–v5, terukur cek_drape_dunia.gd).
		if _visual != null:
			_drape.rotation.x = -_visual.rotation.x
	if _juntai != null:
		_juntai.scale = _juntai.scale.lerp(target["juntai_scale"], k)
		_juntai.visible = _juntai.scale.length_squared() > 0.0025
	if _torso != null:
		_torso.scale = _torso.scale.lerp(target["torso_scale"], k)

# ======================================================================
# 20 NPC v1 (Raka, 19 Nov 2026) — kursi, aktivitas, hormat
# ======================================================================
## Inventaris kursi. Tiap kursi: {id, pos, yaw, gedung, jenis, putri,
## dalam, rute, pintu_luar, pintu_dalam, spawn_dalam}.
## - pos: posisi DUDUK (y = tinggi duduk: 0 lantai, 0.45 bangku/kursi,
##   0.51 kasur Cangkruk — atas kasur, lihat interior_cangkruk.gd).
## - yaw: hadap saat duduk (0 = +z/selatan, PI = -z/utara).
## - gedung: untuk batas "maks 4 NPC per gedung".
## - jenis: "kursi" (bangku/kursi kayu) / "bersila" (lantai) / "kasur".
## - dalam=true: kursi di interior — NPC jalan ke pintu_luar lalu
##   TELEPORT ke spawn_dalam, jalan ke kursi (pola GTA patroli Kyai).
## - rute: titik perantara SEBELUM kursi (y=0) — gerbang taman,
##   celah pagar timur, titik selatan Musholla. Kosong = langsung.
## Kursi Kyai (Surau) / Ustadzah (Musholla) / Guru (Madrasah) TIDAK
## ADA di sini (terlarang — desain §6). Kasur Asrama DITUNDA ke v1.1
## (perlu probe bed_pos_list dulu; Cangkruk+Kelas+Madrasah cukup).
const KURSI_LUAR = [
	# --- Taman Putra: bangku 1 (-3,25.45) sumbu X, hadap selatan.
	{"id": "bangku_taman_putra_1a", "pos": Vector3(-3.4, 0.45, 25.45), "yaw": 0.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "rute": [Vector3(0, 0, 24.0)]},
	{"id": "bangku_taman_putra_1b", "pos": Vector3(-2.6, 0.45, 25.45), "yaw": 0.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "rute": [Vector3(0, 0, 24.0)]},
	# --- Taman Putra: bangku 2 (3.45,28.2) sumbu Z, hadap barat
	# (ke jalur tengah). Rute lewat selatan zona geser pintu
	# (z>=27.5) supaya tidak menabrak daun pintu yang terbuka.
	{"id": "bangku_taman_putra_2a", "pos": Vector3(3.45, 0.45, 27.8), "yaw": -PI / 2.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "rute": [Vector3(0, 0, 24.0), Vector3(0, 0, 27.5)]},
	{"id": "bangku_taman_putra_2b", "pos": Vector3(3.45, 0.45, 28.6), "yaw": -PI / 2.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "rute": [Vector3(0, 0, 24.0), Vector3(0, 0, 27.5)]},
	# --- Serambi Surau (BACA_MUSHOLLA putra): bersila di plaza
	# selatan, menghadap Surau (utara).
	{"id": "serambi_surau_a", "pos": Vector3(-2, 0, 2), "yaw": PI, "gedung": "serambi_surau", "jenis": "bersila", "putri": false, "dalam": false, "rute": []},
	{"id": "serambi_surau_b", "pos": Vector3(2, 0, 2), "yaw": PI, "gedung": "serambi_surau", "jenis": "bersila", "putri": false, "dalam": false, "rute": []},
	# --- Taman Putri: bangku utara (122,30.4) hadap selatan; bangku
	# selatan (122,33.6) hadap utara. Pagar TANPA collision + celah
	# timur (127,32) — rute lewat celah supaya tidak menembus bilah.
	{"id": "bangku_taman_putri_utara_a", "pos": Vector3(121.6, 0.45, 30.4), "yaw": 0.0, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	{"id": "bangku_taman_putri_utara_b", "pos": Vector3(122.4, 0.45, 30.4), "yaw": 0.0, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	{"id": "bangku_taman_putri_selatan_a", "pos": Vector3(121.6, 0.45, 33.6), "yaw": PI, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	{"id": "bangku_taman_putri_selatan_b", "pos": Vector3(122.4, 0.45, 33.6), "yaw": PI, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	# --- Bawah pohon Taman Putri (124,29.8): bersila, hadap selatan.
	{"id": "pohon_taman_putri_a", "pos": Vector3(123.2, 0, 29.8), "yaw": 0.0, "gedung": "taman_putri", "jenis": "bersila", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	{"id": "pohon_taman_putri_b", "pos": Vector3(124.8, 0, 29.8), "yaw": 0.0, "gedung": "taman_putri", "jenis": "bersila", "putri": true, "dalam": false, "rute": [Vector3(127, 0, 32)]},
	# --- Teras Musholla (134,-18): bersila, menghadap Musholla
	# (utara). Rute lewat (134,-14) — titik selatan Musholla yang
	# sudah dipakai patroli Mariyah (aman dari sudut bangunan).
	{"id": "teras_musholla_a", "pos": Vector3(132, 0, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "rute": [Vector3(134, 0, -14)]},
	{"id": "teras_musholla_b", "pos": Vector3(134, 0, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "rute": [Vector3(134, 0, -14)]},
	{"id": "teras_musholla_c", "pos": Vector3(136, 0, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "rute": [Vector3(134, 0, -14)]},
]


const KURSI_DALAM = [
	# --- Cangkruk Putra: 5 kasur, kepala utara, duduk menghadap
	# selatan (ke lorong tengah). y 0.51 = atas kasur.
	{"id": "cangkruk_kasur_1", "pos": Vector3(-66, 0.51, -303.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_2", "pos": Vector3(-66, 0.51, -300.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_3", "pos": Vector3(-54, 0.51, -303.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_4", "pos": Vector3(-54, 0.51, -300.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_5", "pos": Vector3(-60, 0.51, -303.7), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	# --- Kelas Putri: 6 kursi baris BELAKANG (z=-299.0 -> kursi
	# z=-298.45), menghadap papan tulis (utara). Kursi baris depan/
	# tengah TIDAK dipakai NPC (untuk pemain + guru).
	{"id": "kelas_putri_kursi_1", "pos": Vector3(117.0, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_2", "pos": Vector3(117.6, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_3", "pos": Vector3(119.7, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_4", "pos": Vector3(120.3, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_5", "pos": Vector3(122.4, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_6", "pos": Vector3(123.0, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	# --- Madrasah Putri: 2 kursi murid, menghadap utara (papan).
	{"id": "madrasah_kursi_1", "pos": Vector3(-182.0, 0.45, -297.4), "yaw": PI, "gedung": "madrasah", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(147, 0, -12), "pintu_dalam": Vector3(-185, 0, -300), "spawn_dalam": Vector3(-183.5, 0, -300)},
	{"id": "madrasah_kursi_2", "pos": Vector3(-178.8, 0.45, -297.4), "yaw": PI, "gedung": "madrasah", "jenis": "kursi", "putri": true, "dalam": true, "pintu_luar": Vector3(147, 0, -12), "pintu_dalam": Vector3(-185, 0, -300), "spawn_dalam": Vector3(-183.5, 0, -300)},
]


## Kursi TES (DICADANGKAN — Gilang, 20 Nov 2026, konsep
## tes-di-dalam-kantor Laras, ACC Mas 00:37 WIB). 4 kursi: penguji +
## pemain di Kantor Putra (baru, interior z=-300 slot x=-90) dan di
## Kantor Ustadzah (meja pindah ke tengah). Sengaja TIDAK masuk
## KURSI_LUAR/KURSI_DALAM: kursi_bebas() hanya membaca dua const
## itu, jadi NPC DUDUK_KURSI TIDAK PERNAH ditawari kursi tes —
## cadangan pola Sajadah_03 (sajadah imam bukan dari pool NPC).
## Wiring adegan tes (ronde berikut, menunggu pose duduk_kursi
## Kirana) memakai _kursi_dari_id() di bawah untuk posisi kursi.
const KURSI_TES = [
	# --- Kantor Putra: pemain utara meja menghadap selatan (yaw 0),
	# penguji selatan meja menghadap utara (yaw PI). Bangun ke
	# BELAKANG kursi (menjauhi meja — ke depan mendarat DI DALAM
	# meja; pola bangun lorong kursi kelas).
	{"id": "tes_kantor_putra_pemain", "pos": Vector3(-90, 0.45, -300.65), "yaw": 0.0, "gedung": "kantor_putra", "jenis": "kursi", "putri": false, "dalam": true, "bangun": Vector3(-90, 0, -301.45), "pintu_luar": Vector3(-18, 0, 20), "pintu_dalam": Vector3(-90, 0, -302.5), "spawn_dalam": Vector3(-90, 0, -301.9), "tes": true},
	{"id": "tes_kantor_putra_penguji", "pos": Vector3(-90, 0.45, -298.95), "yaw": PI, "gedung": "kantor_putra", "jenis": "kursi", "putri": false, "dalam": true, "bangun": Vector3(-90, 0, -298.15), "pintu_luar": Vector3(-18, 0, 20), "pintu_dalam": Vector3(-90, 0, -302.5), "spawn_dalam": Vector3(-90, 0, -301.9), "tes": true},
	# --- Kantor Ustadzah: pemain barat meja menghadap timur (yaw
	# PI/2), penguji timur meja menghadap barat (yaw -PI/2). Bangun
	# ke belakang kursi (barat / timur).
	{"id": "tes_kantor_ustadzah_pemain", "pos": Vector3(-121.15, 0.45, -300), "yaw": PI / 2.0, "gedung": "kantor_ustadzah", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(-121.95, 0, -300), "pintu_luar": Vector3(144, 0, -33), "pintu_dalam": Vector3(-124, 0, -300), "spawn_dalam": Vector3(-122.5, 0, -300), "tes": true},
	{"id": "tes_kantor_ustadzah_penguji", "pos": Vector3(-118.85, 0.45, -300), "yaw": -PI / 2.0, "gedung": "kantor_ustadzah", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(-118.05, 0, -300), "pintu_luar": Vector3(144, 0, -33), "pintu_dalam": Vector3(-124, 0, -300), "spawn_dalam": Vector3(-122.5, 0, -300), "tes": true},
]


## Registry kursi (static — dipakai semua NPC): id kursi -> NPC pemakai.
## Satu kursi tidak pernah dipakai dua NPC. Lepas saat aktivitas
## selesai / sholat mulai / hormat TIDAK melepas (ditahan).
static var _kursi_registry: Dictionary = {}
## Antrean hormat (static): guru -> jumlah NPC yang sedang varian B.
static var _hormat_antrean: Dictionary = {}


static func _kursi_dari_id(id: String) -> Dictionary:
	for k in KURSI_LUAR:
		if String(k["id"]) == id:
			return k
	for k in KURSI_DALAM:
		if String(k["id"]) == id:
			return k
	# Kursi tes (dicadangkan — dicari di sini, bukan di kursi_bebas).
	for k in KURSI_TES:
		if String(k["id"]) == id:
			return k
	return {}


static func _pemakai_gedung(gedung: String) -> int:
	var n := 0
	for id in _kursi_registry.keys():
		var kursi := _kursi_dari_id(String(id))
		if not kursi.is_empty() and String(kursi["gedung"]) == gedung:
			n += 1
	return n


## Kursi bebas untuk gender + lokasi + (opsional) jenis.
static func kursi_bebas(putri: bool, dalam: bool, jenis: String = "") -> Array:
	var hasil: Array = []
	var semua: Array = KURSI_DALAM if dalam else KURSI_LUAR
	for k in semua:
		if bool(k["putri"]) != putri:
			continue
		if jenis != "" and String(k["jenis"]) != jenis:
			continue
		if _kursi_registry.has(String(k["id"])):
			continue
		if _pemakai_gedung(String(k["gedung"])) >= 4:
			continue
		hasil.append(k)
	return hasil


static func klaim_kursi(id: String, npc: SantriNPC) -> bool:
	if _kursi_registry.has(id):
		return false
	_kursi_registry[id] = npc
	return true


static func lepas_kursi(npc: SantriNPC) -> void:
	for id in _kursi_registry.keys():
		if _kursi_registry[id] == npc:
			_kursi_registry.erase(id)
			return


## ---------- mesin aktivitas (20 NPC v1) ----------
func _coba_mulai_aktivitas() -> void:
	if not _aktivitas_aktif or _aktivitas != "" or _hormat != "":
		return
	# Dadu desain §5: 35% DUDUK_KURSI, 20% BACA_MUSHOLLA, 15%
	# BACA_KAMAR, 15% JALAN_KITAB, 15% tetap jalan bebas. Bila
	# sumber daya (kursi) habis, _mulai_* diam-diam gagal dan NPC
	# tetap jalan — aktivitas itu oportunistik, bukan wajib.
	var d := _rng.randf()
	if d < 0.35:
		_mulai_duduk_kursi()
	elif d < 0.55:
		_mulai_baca_musholla()
	elif d < 0.70:
		_mulai_baca_kamar()
	elif d < 0.85:
		_mulai_jalan_kitab()


func _siapkan_rute_kursi(kursi: Dictionary, aktivitas_barikut: String) -> void:
	_aktivitas_kursi = kursi
	_aktivitas_yaw = float(kursi["yaw"])
	_aktivitas_rute = []
	for p in kursi.get("rute", []):
		_aktivitas_rute.append(p)
	var sp: Vector3 = kursi["pos"]
	_aktivitas_rute.append(Vector3(sp.x, 0.0, sp.z))
	_aktivitas_rute_idx = 0
	_aktivitas_tunggu = 0.0
	_aktivitas = aktivitas_barikut


func _mulai_duduk_kursi() -> void:
	var pilihan: Array = kursi_bebas(_muslimah, false, "kursi")
	if pilihan.is_empty():
		return
	var kursi: Dictionary = pilihan[_rng.randi_range(0, pilihan.size() - 1)]
	if not klaim_kursi(String(kursi["id"]), self):
		return
	_siapkan_rute_kursi(kursi, "ke_kursi")


func _mulai_baca_musholla() -> void:
	var pilihan: Array = kursi_bebas(_muslimah, false, "bersila")
	if pilihan.is_empty():
		return
	var kursi: Dictionary = pilihan[_rng.randi_range(0, pilihan.size() - 1)]
	if not klaim_kursi(String(kursi["id"]), self):
		return
	_siapkan_rute_kursi(kursi, "ke_kursi")


func _mulai_baca_kamar() -> void:
	var pilihan: Array = kursi_bebas(_muslimah, true)
	if pilihan.is_empty():
		return
	var kursi: Dictionary = pilihan[_rng.randi_range(0, pilihan.size() - 1)]
	if not klaim_kursi(String(kursi["id"]), self):
		return
	_aktivitas_kursi = kursi
	_aktivitas_yaw = float(kursi["yaw"])
	# Jalan ke pintu luar gedung dulu; teleport masuk di _proses.
	var pl: Vector3 = kursi["pintu_luar"]
	_aktivitas_rute = [pl]
	_aktivitas_rute_idx = 0
	_aktivitas_tunggu = 0.0
	_aktivitas = "ke_kamar"


func _mulai_jalan_kitab() -> void:
	_aktivitas = "jalan_kitab"
	_aktivitas_timer = _rng.randf_range(30.0, 90.0)
	_pick_target()


## Jalan mengikuti _aktivitas_rute kaki demi kaki. Tiap kaki
## divalidasi _segmen_bersih saat dimulai (pintu taman yang belum
## terbuka / sudut bangunan = kaki tidak bersih). Mengembalikan
## "jalan" / "sampai" / "batal" (batal = kursi dilepas di pemanggil
## via _akhiri_aktivitas).
func _jalan_rute_aktivitas(delta: float) -> String:
	if _aktivitas_rute_idx >= _aktivitas_rute.size():
		return "sampai"
	if _aktivitas_tunggu > 0.0:
		_aktivitas_tunggu -= delta
		_animate_idle(delta)
		return "jalan"
	var titik: Vector3 = _aktivitas_rute[_aktivitas_rute_idx]
	if not _segmen_bersih(position, titik):
		return "batal"
	if _langkah_ke(titik, delta):
		_aktivitas_rute_idx += 1
		if _aktivitas_rute_idx < _aktivitas_rute.size():
			# Jeda antar kaki rute — pintu taman sempat terbuka
			# penuh sebelum kaki berikutnya divalidasi.
			_aktivitas_tunggu = 1.0
			return "jalan"
		return "sampai"
	return "jalan"


func _proses_aktivitas(delta: float) -> void:
	match _aktivitas:
		"ke_kursi":
			match _jalan_rute_aktivitas(delta):
				"sampai":
					var sp: Vector3 = _aktivitas_kursi["pos"]
					# Node di TANAH di x,z kursi (bug 4: JANGAN di
					# tinggi kursi — visual yang naik ke tinggi
					# duduk; node di 0,45 akan berdiri di atas
					# bangku saat aktivitas berakhir).
					position = Vector3(sp.x, _tinggi_tanah(sp), sp.z)
					_visual.rotation.y = _aktivitas_yaw
					_aktivitas = "duduk"
					_aktivitas_timer = _rng.randf_range(60.0, 180.0)
				"batal":
					_akhiri_aktivitas()
		"duduk":
			_visual.rotation.y = lerpf(_visual.rotation.y, _aktivitas_yaw, minf(1.0, delta * 6.0))
			# Bug 3: pose ikut JENIS kursi (kursi = menjuntai,
			# kasur/bersila = bersila) — bukan selalu bersila.
			_terapkan_duduk_sesuai_kursi(delta, true)
			_aktivitas_timer -= delta
			if _aktivitas_timer <= 0.0:
				_akhiri_aktivitas()
		"ke_kamar":
			match _jalan_rute_aktivitas(delta):
				"sampai":
					# Teleport masuk (pola GTA patroli) ke spawn
					# dalam, lalu jalan ke kursi di dalam ruangan.
					var sd: Vector3 = _aktivitas_kursi["spawn_dalam"]
					position = sd
					var sp: Vector3 = _aktivitas_kursi["pos"]
					_aktivitas_rute = [Vector3(sp.x, 0.0, sp.z)]
					_aktivitas_rute_idx = 0
					_aktivitas_tunggu = 0.0
					_aktivitas = "ke_kursi_dalam"
				"batal":
					_akhiri_aktivitas()
		"ke_kursi_dalam":
			match _jalan_rute_aktivitas(delta):
				"sampai":
					var sp2: Vector3 = _aktivitas_kursi["pos"]
					# Node di TANAH (interior y=0) — sama seperti
					# "ke_kursi" (bug 4).
					position = Vector3(sp2.x, _tinggi_tanah(sp2), sp2.z)
					_visual.rotation.y = _aktivitas_yaw
					_aktivitas = "baca_kamar"
					_aktivitas_timer = _rng.randf_range(60.0, 180.0)
				"batal":
					_akhiri_aktivitas()
		"baca_kamar":
			_visual.rotation.y = lerpf(_visual.rotation.y, _aktivitas_yaw, minf(1.0, delta * 6.0))
			# Bug 3: kasur = bersila di atas kasur (visual +0,09),
			# kursi interior = duduk_kursi.
			_terapkan_duduk_sesuai_kursi(delta, true)
			_aktivitas_timer -= delta
			if _aktivitas_timer <= 0.0:
				# Keluar dulu (teleport ke pintu luar), baru akhiri
				# — supaya _pick_target berikutnya dihitung dari luar.
				var pl: Vector3 = _aktivitas_kursi["pintu_luar"]
				position = pl
				_akhiri_aktivitas()
		"jalan_kitab":
			if _kitab_tangan != null:
				_kitab_tangan.visible = true
			# Jalan PELAN (0.5x) ke target waypoint sambil bawa kitab.
			if _langkah_ke(_target, delta, 0.5):
				_pick_target()
			# Pose bawa kitab (cermin player.gd): tangan kanan ke
			# depan memegang kitab — menimpa ayunan jalan lengan kanan.
			_arm_r.rotation.x = -0.55 - sin(_walk_time) * 0.1
			_elbow_r.rotation.x = -0.5
			_aktivitas_timer -= delta
			if _aktivitas_timer <= 0.0:
				_akhiri_aktivitas()


## Akhiri aktivitas apa pun: kitab disembunyikan, kursi dilepas,
## kembali keliling bebas. Aman dipanggil saat tidak ada aktivitas.
func _akhiri_aktivitas() -> void:
	if _kitab_pangku != null:
		_kitab_pangku.visible = false
	if _kitab_tangan != null:
		_kitab_tangan.visible = false
	# DUDUK KURSI (Kirana, 20 Nov 2026 — bug 4 + bug 1): berdiri dari
	# kursi/kasur HARUS turun ke lantai DI DEPAN perabot. Node selama
	# duduk memang sudah di tanah, tapi x,z-nya DI DALAM bangku/kasur
	# — tanpa melangkah ke "bangun", NPC berdiri menembus bangku.
	# Penjaga < 1,5 m: jalur "baca_kamar -> teleport ke pintu_luar
	# dulu" memanggil fungsi ini SETELAH teleport — NPC sudah jauh
	# dari kursi, jadi langkah bangun TIDAK boleh membatalkannya.
	# Pakaian di-snap ke DEFAULT di sini (bug 1): setiap jalur keluar
	# dari duduk WAJIB mengembalikan sarung — jangan tunggu idle.
	if _aktivitas in ["duduk", "baca_kamar"] and not _aktivitas_kursi.is_empty():
		var jenis_akhiri := String(_aktivitas_kursi.get("jenis", "bersila"))
		if jenis_akhiri in ["kursi", "kasur"]:
			var sp_akhiri: Vector3 = _aktivitas_kursi["pos"]
			if Vector2(position.x, position.z).distance_to(Vector2(sp_akhiri.x, sp_akhiri.z)) < 1.5:
				var bangun := _titik_bangun(_aktivitas_kursi)
				position = Vector3(bangun.x, _tinggi_tanah(bangun), bangun.z)
		_terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)
		_visual.position.y = 0.0
	lepas_kursi(self)
	_aktivitas = ""
	_aktivitas_kursi = {}
	_aktivitas_rute = []
	_aktivitas_rute_idx = 0
	_aktivitas_timer = 0.0
	_aktivitas_tunggu = 0.0
	_pick_target()


## 20 NPC v1 — keluarkan NPC dari interior (BACA_KAMAR) sebelum rute
## sholat dihitung (pola teleport_ke_pintu_luar untuk patroli).
## Dipanggil main.gd di _mulai_sholat untuk semua NPC.
func keluar_dari_dalam() -> void:
	if _aktivitas == "baca_kamar" and not _aktivitas_kursi.is_empty():
		var pl: Vector3 = _aktivitas_kursi["pintu_luar"]
		position = pl
		_akhiri_aktivitas()
	elif _aktivitas == "ke_kamar" or _aktivitas == "ke_kursi_dalam":
		_akhiri_aktivitas()


## ---------- hormat ke guru (20 NPC v1) ----------
## Yang dihormati (group "guru_hormat", dipasang main.gd): Kyai,
## Ustadzah Mariyah, Ust. Sanusi, Ustzh. Fatimah. BUKAN Bilal/Faris,
## Satpam/Penjaga, pemain. v1 luar ruangan saja; mati saat sholat
## dan panel misi terbuka. NPC jalan -> varian A; NPC diam/duduk ->
## varian B. Antrean varian B maks 3, sisanya varian A.
const HORMAT_RADIUS := 4.0
const HORMAT_COOLDOWN_PASANGAN := 60.0
const HORMAT_COOLDOWN_NPC := 20.0
const HORMAT_ANTREAN_MAKS := 3


func _cek_hormat(delta: float) -> void:
	if _hormat_cooldown_npc > 0.0:
		_hormat_cooldown_npc -= delta
	if _mode_sholat or _duduk_belajar or not _patroli.is_empty() or _diam:
		return
	# v1 luar ruangan saja (interior z≈-300 tidak hormat).
	if global_position.z < -100.0:
		return
	if AnimasiMixamo.panel_misi_terbuka(get_tree()):
		return
	if _hormat_cooldown_npc > 0.0:
		return
	var sekarang := Time.get_ticks_msec() / 1000.0
	var guru_terdekat: Node3D = null
	var jarak_min := HORMAT_RADIUS
	for g in get_tree().get_nodes_in_group("guru_hormat"):
		var guru := g as Node3D
		if guru == null or guru == self:
			continue
		var j := global_position.distance_to(guru.global_position)
		if j >= jarak_min:
			continue
		var terakhir: float = float(_hormat_pasangan.get(guru, -9999.0))
		if sekarang - terakhir < HORMAT_COOLDOWN_PASANGAN:
			continue
		jarak_min = j
		guru_terdekat = guru
	if guru_terdekat == null:
		return
	_mulai_hormat(guru_terdekat)


func _mulai_hormat(guru: Node3D) -> void:
	var sedang_duduk := _aktivitas in ["duduk", "baca_kamar"]
	var sedang_diam := _pause_timer > 0.0
	# Simpan aktivitas (bila ada) — kursi DITAHAN selama hormat,
	# dipulihkan sesudahnya (lihat _akhiri_hormat).
	if _aktivitas != "":
		_hormat_aktivitas_tersimpan = {
			"aktivitas": _aktivitas, "timer": _aktivitas_timer,
			"kursi": _aktivitas_kursi, "rute": _aktivitas_rute,
			"rute_idx": _aktivitas_rute_idx, "yaw": _aktivitas_yaw,
		}
		_aktivitas = ""
		_aktivitas_rute = []
		_aktivitas_rute_idx = 0
		if _kitab_pangku != null:
			_kitab_pangku.visible = false
		if _kitab_tangan != null:
			_kitab_tangan.visible = false
	_hormat_guru = guru
	_hormat_pos_awal = global_position
	var sekarang := Time.get_ticks_msec() / 1000.0
	_hormat_pasangan[guru] = sekarang
	_hormat_cooldown_npc = HORMAT_COOLDOWN_NPC
	if sedang_duduk or sedang_diam:
		_mulai_hormat_b(guru)
	else:
		_mulai_hormat_a(guru)


## Varian A (NPC jalan): minggir 1 m + nunduk + tangan menyilang ±3 dtk.
func _mulai_hormat_a(guru: Node3D) -> void:
	_hormat = "a_minggir"
	_hormat_timer = 0.0
	var ke_guru := guru.global_position - global_position
	ke_guru.y = 0.0
	var arah := ke_guru.normalized()
	var tegak := Vector3(-arah.z, 0.0, arah.x)
	var calon := global_position + tegak * 1.0
	if not _segmen_bersih(global_position, calon):
		calon = global_position - tegak * 1.0
	_hormat_tujuan = calon


## Varian B (NPC diam/duduk): berdiri, hampiri 1 m, salaman 2 dtk,
## cium tangan 1,5 dtk, kembali; guru berhenti ±4 dtk.
func _mulai_hormat_b(guru: Node3D) -> void:
	var antrean := int(_hormat_antrean.get(guru, 0))
	if antrean >= HORMAT_ANTREAN_MAKS:
		# Antrean penuh — jatuh ke varian A (minggir + nunduk).
		_mulai_hormat_a(guru)
		return
	_hormat_antrean[guru] = antrean + 1
	if guru is SantriNPC:
		(guru as SantriNPC).jeda_patroli(4.0)
	_hormat = "b_hampiri"
	_hormat_timer = 0.0


func _proses_hormat(delta: float) -> void:
	var k := minf(1.0, delta * 8.0)
	match _hormat:
		"a_minggir":
			if _langkah_ke(_hormat_tujuan, delta):
				_hormat = "a_tunduk"
				_hormat_timer = 3.0
		"a_tunduk":
			# Nunduk (kepala ikut jilbab — pivot kepala) + tangan menyilang.
			var kepala := _rig.get("kepala") as Node3D
			if kepala != null:
				kepala.rotation.x = lerpf(kepala.rotation.x, 0.35, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.5, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.5, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.45, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.45, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -1.3, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -1.3, k)
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			_hormat_timer -= delta
			if _hormat_timer <= 0.0:
				_akhiri_hormat()
		"b_hampiri":
			if _hormat_guru == null or not is_instance_valid(_hormat_guru):
				_batalkan_hormat()
				return
			# Target 1 m dari guru, di sisi NPC (guru diam karena jeda).
			var ke_npc := global_position - _hormat_guru.global_position
			ke_npc.y = 0.0
			var tujuan := _hormat_guru.global_position + ke_npc.normalized() * 1.0
			if _langkah_ke(tujuan, delta):
				# Hadap guru, mulai salaman.
				var ke_guru := _hormat_guru.global_position - global_position
				_visual.rotation.y = atan2(ke_guru.x, ke_guru.z)
				_hormat = "b_salaman"
				_hormat_timer = 2.0
		"b_salaman":
			# Salaman (cermin player.gd "salaman"): tangan kanan terulur.
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -1.45, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.05, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.05, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, 0.0, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.1, k)
			_hormat_timer -= delta
			if _hormat_timer <= 0.0:
				_hormat = "b_cium"
				_hormat_timer = 1.5
		"b_cium":
			# Cium tangan: nunduk + tangan kanan ke wajah.
			var kepala2 := _rig.get("kepala") as Node3D
			if kepala2 != null:
				kepala2.rotation.x = lerpf(kepala2.rotation.x, 0.4, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.12, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -1.0, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -1.4, k)
			_hormat_timer -= delta
			if _hormat_timer <= 0.0:
				# Antrean dibebaskan saat meninggalkan guru.
				if _hormat_guru != null and _hormat_antrean.has(_hormat_guru):
					_hormat_antrean[_hormat_guru] = maxi(0, int(_hormat_antrean[_hormat_guru]) - 1)
				_hormat = "b_kembali"
		"b_kembali":
			if _langkah_ke(_hormat_pos_awal, delta):
				_akhiri_hormat()


## Hormat selesai normal: pulihkan aktivitas yang disimpan.
func _akhiri_hormat() -> void:
	# Kepala kembali tegak (bow tidak direset modul idle/jalan).
	var kepala := _rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.x = 0.0
	_visual.rotation.x = 0.0
	_hormat = ""
	_hormat_guru = null
	_hormat_timer = 0.0
	if not _hormat_aktivitas_tersimpan.is_empty():
		var s: Dictionary = _hormat_aktivitas_tersimpan
		_aktivitas = String(s.get("aktivitas", ""))
		_aktivitas_timer = float(s.get("timer", 0.0))
		_aktivitas_kursi = s.get("kursi", {})
		_aktivitas_rute = []
		for p in s.get("rute", []):
			_aktivitas_rute.append(p)
		_aktivitas_rute_idx = int(s.get("rute_idx", 0))
		_aktivitas_yaw = float(s.get("yaw", 0.0))
		_hormat_aktivitas_tersimpan = {}
		if _aktivitas in ["duduk", "baca_kamar"] and not _aktivitas_kursi.is_empty():
			# Kembali ke posisi kursi (b_kembali sudah jalan ke sana).
			# Node di TANAH (bug 4: kursi pos.y 0,45 bukan y node).
			var sp: Vector3 = _aktivitas_kursi["pos"]
			position = Vector3(sp.x, _tinggi_tanah(sp), sp.z)
			_visual.rotation.y = _aktivitas_yaw
		elif _aktivitas == "jalan_kitab" and _kitab_tangan != null:
			_kitab_tangan.visible = true


## Hormat dibatalkan paksa (mis. sholat mulai): bebaskan antrean,
## buang simpanan aktivitas (kursi tetap dilepas _akhiri_aktivitas
## oleh pemanggil — di sini hanya state hormat yang dibersihkan).
func _batalkan_hormat() -> void:
	if _hormat in ["b_hampiri", "b_salaman", "b_cium"]:
		if _hormat_guru != null and _hormat_antrean.has(_hormat_guru):
			_hormat_antrean[_hormat_guru] = maxi(0, int(_hormat_antrean[_hormat_guru]) - 1)
	var kepala := _rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.x = 0.0
	_visual.rotation.x = 0.0
	_hormat = ""
	_hormat_guru = null
	_hormat_timer = 0.0
	_hormat_aktivitas_tersimpan = {}


## ---------- salaman pemain (Raka, 20 Nov 2026) ----------
## Salaman yang DIPICU PEMAIN (△ Aksi → Salaman, main.gd _on_aksi) —
## beda dari hormat varian B (NPC→guru, otomatis). NPC: hadap pemain
## (±0,4 dtk, berdiri dulu bila sedang duduk) → HAMPIRI sampai jarak
## jabat 1,05 m → jabat tangan 2 dtk (pose = b_salaman hormat, tangan
## kanan terulur KE DALAM ke garis tengah) → kembali ke aktivitas
## semula (kursi DITAHAN seperti hormat). Cooldown 10 dtk per NPC
## supaya tidak spam. v1 luar ruangan saja; tolak saat sholat /
## duduk belajar / hormat / panel misi terbuka (dicek pemanggil).
## POLISH 20 Nov 2026 (verdict Mas "Kok tidak jabat tangan?"): dulu
## NPC diam di tempat (jarak 1,4 m, lengan ~0,45 m) + lengan lurus
## ke depan — tangan tidak pernah bersentuhan. Kini NPC melangkah
## mendekat sampai 1,20 m dan kedua lengan mengarah ke dalam
## (sudut_salaman_dalam) supaya tangan bertemu di garis tengah
## (< 0,1 m). Jarak 1,20 m (bukan 1,05): jangkau tangan nyata
## ~0,64 m × 2 — 0,59 lengan + ~0,10 condong badan 0,08 rad —
## sehingga di 1,20 m telapak tangan bertumpuk (jabat), sedangkan
## di 1,05 m tangan justru saling melewati 0,23 m (terukur run4).
const SALAMAN_JARAK_MAKS := 3.0
const SALAMAN_JABAT_DURASI := 2.0
const SALAMAN_COOLDOWN := 10.0
const SALAMAN_JABAT_JARAK := 1.20
const SALAMAN_HAMPIRI_MAKS := 2.0


## Dipanggil main.gd saat pemain menekan Salaman di dekat NPC ini.
## true = NPC menerima (mulai hadap + jabat); false = tolak (pemain
## tetap pose salaman solo).
func terima_salaman(pemain: Node3D) -> bool:
	if _salaman != "" or _mode_sholat or _duduk_belajar or _hormat != "":
		return false
	if global_position.z < -100.0:
		return false
	if _salaman_cooldown > 0.0:
		return false
	if pemain == null or not is_instance_valid(pemain):
		return false
	if global_position.distance_to(pemain.global_position) > SALAMAN_JARAK_MAKS:
		return false
	# Simpan aktivitas (pola _mulai_hormat) — kursi DITAHAN selama
	# salaman, dipulihkan sesudahnya (lihat _akhiri_salaman).
	if _aktivitas != "":
		_salaman_aktivitas_tersimpan = {
			"aktivitas": _aktivitas, "timer": _aktivitas_timer,
			"kursi": _aktivitas_kursi, "rute": _aktivitas_rute,
			"rute_idx": _aktivitas_rute_idx, "yaw": _aktivitas_yaw,
		}
		_aktivitas = ""
		_aktivitas_rute = []
		_aktivitas_rute_idx = 0
		if _kitab_pangku != null:
			_kitab_pangku.visible = false
		if _kitab_tangan != null:
			_kitab_tangan.visible = false
	_salaman_pemain = pemain
	_salaman = "hadap"
	_salaman_timer = 0.0
	_salaman_cooldown = SALAMAN_COOLDOWN
	return true


func _proses_salaman(delta: float) -> void:
	var k := minf(1.0, delta * 8.0)
	match _salaman:
		"hadap":
			if _salaman_pemain == null or not is_instance_valid(_salaman_pemain):
				_batalkan_salaman()
				return
			# Hadap pemain + berdiri dari duduk (kaki lurus, badan naik).
			var ke_pemain := _salaman_pemain.global_position - global_position
			ke_pemain.y = 0.0
			if ke_pemain.length() > 0.05:
				_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(ke_pemain.x, ke_pemain.z), minf(1.0, delta * 6.0))
			_visual.position.y = lerpf(_visual.position.y, 0.0, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.0, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.0, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.0, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
			_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			_salaman_timer += delta
			if _salaman_timer >= 0.4:
				_salaman = "hampiri"
				_salaman_timer = 0.0
		"hampiri":
			# POLISH 20 Nov 2026 (verdict Mas "Kok tidak jabat
			# tangan?"): NPC MELANGKAH mendekat sampai jarak jabat
			# 1,05 m — dulu diam di tempat (1,4 m) sehingga tangan
			# tidak pernah bersentuhan. Gerak = pola _langkah_ke
			# (posisi langsung, tanpa fisika — NPC tidak punya
			# collision, jadi tidak tertahan pemain; animasi jalan
			# dari terapkan_jalan supaya tidak meluncur).
			if _salaman_pemain == null or not is_instance_valid(_salaman_pemain):
				_batalkan_salaman()
				return
			var ke_pemain2 := _salaman_pemain.global_position - global_position
			ke_pemain2.y = 0.0
			var jarak2 := ke_pemain2.length()
			# Pemain kabur jauh (gerak membatalkan pose salaman) —
			# jangan kejar, batalkan.
			if jarak2 > SALAMAN_JARAK_MAKS:
				_batalkan_salaman()
				return
			if jarak2 > SALAMAN_JABAT_JARAK:
				var dir2 := ke_pemain2 / jarak2
				position += dir2 * minf(SPEED * delta, jarak2 - SALAMAN_JABAT_JARAK)
				position.y = _tinggi_tanah(position)
				_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(dir2.x, dir2.z), minf(1.0, delta * 6.0))
				_walk_time += delta * 8.0
				AnimasiMixamo.terapkan_jalan(_rig, _walk_time, 1.0)
				_terapkan_pakaian(delta, SantriPlayer.PAKAIAN_DEFAULT)
			_salaman_timer += delta
			if jarak2 <= SALAMAN_JABAT_JARAK + 0.02 or _salaman_timer >= SALAMAN_HAMPIRI_MAKS:
				_salaman = "jabat"
				_salaman_timer = 0.0
		"jabat":
			# Jabat tangan (nilai = b_salaman hormat): tangan kanan
			# terulur KE DALAM ke garis tengah (sudut_salaman_dalam)
			# supaya bertemu tangan pemain — bukan lurus ke depan.
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -1.45, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.05, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, SantriPlayer.sudut_salaman_dalam(_arm_r.position.x), k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, 0.0, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.1, k)
			_salaman_timer += delta
			if _salaman_timer >= SALAMAN_JABAT_DURASI:
				_akhiri_salaman()


## Salaman selesai normal: pulihkan aktivitas yang disimpan (pola
## _akhiri_hormat — kembali duduk di kursi / kitab di tangan).
func _akhiri_salaman() -> void:
	_visual.rotation.x = 0.0
	_salaman = ""
	_salaman_pemain = null
	_salaman_timer = 0.0
	if not _salaman_aktivitas_tersimpan.is_empty():
		var s: Dictionary = _salaman_aktivitas_tersimpan
		_aktivitas = String(s.get("aktivitas", ""))
		_aktivitas_timer = float(s.get("timer", 0.0))
		_aktivitas_kursi = s.get("kursi", {})
		_aktivitas_rute = []
		for p in s.get("rute", []):
			_aktivitas_rute.append(p)
		_aktivitas_rute_idx = int(s.get("rute_idx", 0))
		_aktivitas_yaw = float(s.get("yaw", 0.0))
		_salaman_aktivitas_tersimpan = {}
		if _aktivitas in ["duduk", "baca_kamar"] and not _aktivitas_kursi.is_empty():
			# Kembali ke posisi kursi.
			var sp: Vector3 = _aktivitas_kursi["pos"]
			position = sp
			_visual.rotation.y = _aktivitas_yaw
		elif _aktivitas == "jalan_kitab" and _kitab_tangan != null:
			_kitab_tangan.visible = true


## Salaman dibatalkan paksa (mis. sholat mulai / pemain hilang):
## buang simpanan aktivitas (pola _batalkan_hormat — kursi dilepas
## _akhiri_aktivitas oleh pemanggil, di sini hanya state yang bersih).
func _batalkan_salaman() -> void:
	_visual.rotation.x = 0.0
	_salaman = ""
	_salaman_pemain = null
	_salaman_timer = 0.0
	_salaman_aktivitas_tersimpan = {}
