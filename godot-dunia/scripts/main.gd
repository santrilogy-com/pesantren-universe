extends Node
## Pesantren Universe — orkestrator utama.
## Alur: login server (username IG + kata sandi opsional, kontrak
## v1.5.0) -> masuk pesantren 3D, spawn sesuai gender pemain.
## RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): TIDAK ADA lagi pilihan
## jalur (Misi / Ngaji Aja) — semua santri ikut kurikulum tunggal
## berurutan (misi M1->M2->M3) + pengajian kitab terjadwal (khataman).
## Semua belajar ada DI DALAM pesantren ini: misi Nahwu, khataman,
## Ma'hadiyah, chat bubble, dashboard Kartu Santri.
## Istilah: "pesantren" (bukan "dunia") — keputusan Mas 15 Nov ~09:09 WIB.

const CHAT_JARAK_INTERAKSI := 3.5

var _save: Dictionary = {}
# Login server (integrasi login-gender, 17 Nov 2026): POST
# /api/santri/login mengembalikan ID + nama + jenis_kelamin +
# token sesi. Token sesi hanya di memori (berlaku 1 jam) — TIDAK
# disimpan di save. X-PV-Token TIDAK dipakai di game ini (hanya
# untuk POST /api/santri/points dari server tepercaya).
const SERVER_BASE_URL := "https://43-173-39-166.sslip.io"
const LOGIN_TIMEOUT_DETIK := 15.0
var _session_token: String = ""
var _login_http: HTTPRequest = null
var _pesantren: Dictionary = {}
var _player: SantriPlayer
var _rig: Node3D
var _spring: SpringArm3D
var _cam: Camera3D
var _cam_yaw: float = 0.0
var _cam_pitch: float = -0.35
var _ui: PesantrenUI
var _markers: Dictionary = {}
var _chest_lid: Node3D
var _chest_opened: bool = false
var _npcs: Array[SantriNPC] = []
# RONDE 20 — referensi NPC khusus (dipakai rute sholat + batas):
# _kyai = Ust. Aqsal Murad (imam Surau, patroli putra);
# _ustadzah = Ustadzah Mariyah (imam Musholla Ar-Raudhah, patroli
# putri); _satpam = penjaga gerbang (diam di pos, TIDAK ikut sholat).
var _kyai: SantriNPC
var _ustadzah: SantriNPC
var _satpam: SantriNPC
var _active_misi: Dictionary = {}
var _bob_time: float = 0.0
# RONDE 17 — audio suasana pesantren (ambience + bacaan kegiatan).
# _audio_unlocked = gestur pertama sudah terjadi (autoplay web).
var _audio: AudioPesantren
var _audio_unlocked: bool = false
# FITUR CUACA (Wulan, 17 Nov 2026; hook dipasang Raka): cuaca nyata
# lokasi pemain via Open-Meteo — dibuat sekali, mulai() aman dipanggil
# ulang (flag sudah_diminta cegah prompt izin kedua).
var _cuaca: Cuaca = null
# RONDE 13 — sholat berjamaah otomatis (Mas 06:30 WIB: "kalau masuk
# waktu sholat maka semuanya ke surau untuk sholat").
# _sholat_aktif + _sholat_nama + _sholat_akhir_menit = sesi berjalan;
# _pemain_ikut_sholat = pemain sudah menekan "Ikut Sholat";
# _npc_sholat_fase[npc] = "ke_pintu" | "ke_sajadah" | "sholat" |
# "pulang_dalam" | "pulang_luar" | "" (biasa);
# _npc_rumah[npc] = posisi sebelum sesi (untuk pulang);
# _sajadah_npc[npc] = posisi sajadah yang dipakai NPC itu.
var _sholat_aktif: bool = false
var _sholat_nama: String = ""
var _sholat_akhir_menit: int = 0
var _pemain_ikut_sholat: bool = false
var _npc_sholat_fase: Dictionary = {}
var _npc_rumah: Dictionary = {}
var _sajadah_npc: Dictionary = {}
# RONDE 18 — cegah sesi yang sama jalan 2x dalam 1 jendela: adegan
# sinematik (±30 dtk) selesai SEBELUM jendela 1 menit habis, jadi
# tanpa kunci ini sesi langsung mulai lagi (NPC jalan balik, takbir
# kedua). Kunci = nama + jam mulai + tanggal; dibersihkan saat
# tanggal berganti.
var _sholat_sudah: Dictionary = {}
var _sholat_tanggal: String = ""
# RONDE 18 — adegan sholat SINEMATIK (Mas 12:14 WIB: "adegan sholat
# cukup diambil pas takbir saja, lalu black out, lalu selesai").
# _sholat_adegan = "" (tidak ada adegan) | "kumpul" (NPC jalan ke
# Surau, banner IKUT SHOLAT masih tampil) | "takbir" (semua di
# sajadah, tangan terangkat, tahan TAKBIR_TAHAN_DETIK) | "gelap"
# (layar menghitam BLACKOUT_DETIK, teks "Sholat berjamaah...") |
# "selesai" (fade in + sesi berakhir, NPC pulang). Timer adegan
# berjalan di waktu GAME (delta _process), bukan jam perangkat.
var _sholat_adegan: String = ""
var _sholat_adegan_t: float = 0.0
const TAKBIR_TAHAN_DETIK := 4.0
const BLACKOUT_DETIK := 2.5
const BLACKOUT_FADE_DETIK := 0.5
const FADE_MASUK_DETIK := 0.8
const KUMPUL_TIMEOUT_DETIK := 25.0
## Yaw hadap kiblat 295° (InteriorSurau.KIBLAT_AZIMUT): arah kiblat
## (x,z) = (sin 295°, -cos 295°) = (-0.906, -0.423); wajah karakter
## di +Z lokal, jadi yaw = atan2(x, z) = -115° = -2.0071 rad.
const KIBLAT_YAW := -2.0071
# RONDE 16 — posisi imam: di depan baris depan saf, di sumbu mihrab.
# Dihitung runtime dari Sajadah_03 (tengah baris depan) + arah kiblat
# × jarak — supaya rotasi Surau ronde 14 tetap benar otomatis.
# 1.5 m dari pusat Sajadah_03 ≈ 0.9 m di depan tepi depan sajadah
# (sajadah 1.15 m); mihrab ~4.9 m di depan imam — jauh dari dinding.
const IMAM_JARAK_DEPAN := 1.5
# RONDE 4 — interior Surau sebagai map terpisah (ala GTA): pemain di
# dalam interior (z=-300) atau di peta luar? State santri (ID, nama,
# poin, misi) TIDAK disentuh saat bolak-balik — yang pindah hanya
# posisi pemain + kamera (teleport, lihat _teleport_player).
var _di_dalam: bool = false
# RONDE PERBAIKAN (Raka, integrasi item 7f): pemain di dalam map
# interior Musholla (60,-301)? Cermin _di_dalam (Surau) — dipakai
# _cek_pintu_musholla, _cek_batas, kamera, peta, dan sandal.
var _di_dalam_musholla: bool = false
var _smartboard_screen: Label3D
var _interior_door: Vector3 = Vector3(0, 0, -294)
# RONDE 21 (Sinta): nilai awal mengikuti Surau GESER (0,-14) —
# pintu (-3.38,-6.75), keluar (-4.01,-5.39). Nilai runtime tetap
# dibaca dari builder di _ready (surau_pintu() + dict build).
var _outdoor_door: Vector3 = Vector3(-3.38, 0, -6.75)
var _interior_spawn: Vector3 = Vector3(0, 0, -295.5)
var _outdoor_exit: Vector3 = Vector3(-4.01, 0, -5.39)
var _smartboard_spot: Vector3 = Vector3(-4.6, 0, -300)
# RONDE 14: frame pintu Surau (dunia, setelah rotasi -25°) dari
# PesantrenBuilder.surau_pintu() — "pintu" = pusat celah pintu luar,
# "sumbu" = arah memanjang celah (115°), "masuk" = normal ke dalam
# bangunan (25°), "keluar" = normal ke luar/plaza (205°). Dipakai
# koridor pintu + rute NPC (frame yang sama berlaku untuk pintu dalam
# karena interior diputar -25° juga, pivotnya di pintu itu sendiri).
# RONDE 21 (Sinta): nilai awal mengikuti Surau GESER (0,-14) —
# pintu (-3.38,-6.75); arah-arah di bawah = arah(115°/25°/205°).
var _surau_pintu: Vector3 = Vector3(-3.38, 0, -6.75)
var _surau_sumbu: Vector3 = Vector3(0.9063, 0, 0.4226)
var _surau_masuk: Vector3 = Vector3(0.4226, 0, -0.9063)
var _surau_keluar: Vector3 = Vector3(-0.4226, 0, 0.9063)
# RONDE 6 — kamar cangkruk (map interior kedua, ala GTA) + perbaikan
# DOUBLE SURAU: interior Surau + interior cangkruk DISEMBUNYIKAN saat
# pemain di luar (visible=false) — sebelumnya ruangan interior
# (18x14 m, dinding putih) berdiri di lapangan luar di z=-300 dan
# terlihat dari spawn sebagai bangunan kedua ("double surau").
var _di_dalam_cangkruk: bool = false
var _interior_root: Node3D
var _cangkruk_root: Node3D
# RONDE 21: cangkruk PINDAH (-12,-12) -> (-22,-18) (ACC Mas 22:57
# WIB, putra barat Surau baru) — pintu (-22,-14), keluar (-22,-12.5).
# Nilai awal di sini mengikuti builder (dipakai _cek_pintu_cangkruk).
var _cangkruk_door: Vector3 = Vector3(-22, 0, -14)
var _cangkruk_exit: Vector3 = Vector3(-22, 0, -12.5)
var _cangkruk_interior_door: Vector3 = Vector3(-60, 0, -295)
var _cangkruk_interior_spawn: Vector3 = Vector3(-60, 0, -296.5)
var _cangkruk_beds: Array = []
var _cangkruk_lemari: Vector3 = Vector3(-54.6, 0, -296.8)
var _sandal_luar_surau: Node3D
var _sandal_luar_cangkruk: Node3D
# RONDE 20 — Musholla Ar-Raudhah (putri, interior ketiga, ala GTA):
# ruangan 14x10 m di (60,0,-301), diputar -25° mengelilingi pintu
# (60,-296). Pemain putra TIDAK PERNAH masuk (pagar + barrier);
# yang masuk: Ustadzah Mariyah (patroli + imam putri).
var _musholla_root: Node3D
var _musholla_door: Vector3 = Vector3(60, 0, -296)
var _musholla_spawn: Vector3 = Vector3(60, 0, -297.5)
# RONDE 22 (Sinta): default pintu luar musholla PINDAH ke (134,-17.5)
# mengikuti Musholla baru (134,-24) — nilai lama (15.67,-19.01) posisi
# musholla Ronde 20 (18,-24), kini di BARAT tembok keliling (x=115):
# kalau dict build gagal memasok "musholla_exit", rute Ustadzah akan
# berakhir di barat tembok dan memotongnya lagi di segmen akhir.
# Nilai ini ditimpa dict build di _ready (lihat baris _musholla_exit).
var _musholla_exit: Vector3 = Vector3(134, 0, -17.5)
var _sandal_luar_musholla: Node3D
# RONDE 21 — penegakan batas putra/putri KERAS (Mas, pakem): tembok
# pemisah solid di x=14 (z -60..+16) menggantikan pagar kayu Ronde
# 20; gerbang (14,0) TERTUTUP + barrier collision penuh (builder).
# Aturan KERAS: pemain yang masuk zona larangan mendapat toast
# (dibatasi 1x per 4 detik) DAN didorong balik ke posisi legal
# terakhir — bukan cuma toast seperti Ronde 20. Selatan (z >= 16)
# tetap kawasan bersama. Nilai tembok dibaca dari dict build
# (_pesantren) di _ready — JANGAN hardcode ulang di sini.
# _batas_toast_count = jumlah toast batas yang tampil (dipakai tes
# headless). _pos_legal_terakhir = posisi legal terakhir pemain
# (dicatat tiap frame saat posisi legal).
var _batas_toast_timer: float = 0.0
var _batas_toast_count: int = 0
var _tembok_x: float = 14.0
var _tembok_z_min: float = -60.0
var _tembok_z_max: float = 16.0
var _batas_z_selatan: float = 16.0
var _gerbang_pos: Vector3 = Vector3(14, 0, 0)
var _gerbang_lebar: float = 4.0
var _spawn_putri: Vector3 = Vector3(130, 0, 14)
var _pos_satpam: Vector3 = Vector3(17, 0, 5)
var _pos_legal_terakhir: Vector3 = Vector3(-4, 0, 14)
var _punya_pos_legal: bool = false
# RONDE PERBAIKAN (Eka, 17 Nov) — kamera + Kelas Putri:
# _kelas_putri_pos = pusat Kelas Putri (dict build) untuk penjaga
# cangkang kosongnya; _kelas_toast_timer/_kelas_toast_count = throttle
# + hitung toast penjaga Kelas Putri (dipakai tes headless).
var _kelas_putri_pos: Vector3 = Vector3(130, 0, 0)
var _kelas_toast_timer: float = 0.0
var _kelas_toast_count: int = 0


func _ready() -> void:
	_save = SantriSave.load_data()
	# Bangun pesantren 3D (surau kecil + plot pertumbuhan).
	_pesantren = PesantrenBuilder.build()
	add_child(_pesantren["root"])
	_markers = _pesantren["markers"]
	_chest_lid = _pesantren["chest_lid"]
	# RONDE 4: posisi pintu luar (dari builder) + interior baru (Dewa).
	_outdoor_door = _pesantren["outdoor_door"]
	_outdoor_exit = _pesantren["outdoor_exit"]
	# RONDE 14: frame pintu Surau (Surau diputar -25°; RONDE 21 pintu
	# luar kini di (-3.38,-6.75) setelah Surau geser ke (0,-14)).
	# Dipakai koridor pintu + rute NPC.
	var frame := PesantrenBuilder.surau_pintu()
	_surau_pintu = frame["pintu"]
	_surau_sumbu = frame["sumbu"]
	_surau_masuk = frame["masuk"]
	_surau_keluar = frame["keluar"]
	# Interior Surau BARU (Dewa, ronde 4): InteriorSurau.build()
	# menggantikan _interior_surau lama di PesantrenBuilder (dihapus
	# supaya tidak ada dua interior menumpuk di z=-300). Ruangan 18x14
	# m (bukan 14x12); dinding selatan + pintu + spawn TIDAK berubah.
	# Smartboard spot Dewa (-6.8,0,-301), bukan (-4.6,0,-300) — jarak
	# ke penanda M2 ±2,4 m, masih dalam radius interaksi 3,5 m.
	var interior := InteriorSurau.build()
	add_child(interior["root"])
	_interior_root = interior["root"]
	_interior_door = interior["interior_door"]
	_interior_spawn = interior["interior_spawn"]
	_smartboard_spot = interior["smartboard_spot"]
	_smartboard_screen = interior["smartboard_screen"]
	# RONDE 6 — interior Surau DISEMBUNYIKAN saat pemain di luar
	# (perbaikan DOUBLE SURAU: ruangan 18x14 m di z=-300 sebelumnya
	# terlihat dari spawn sebagai bangunan kedua).
	_interior_root.visible = false
	# RONDE 6 — kamar cangkruk (map interior kedua, ala GTA).
	var cangkruk := InteriorCangkruk.build()
	add_child(cangkruk["root"])
	_cangkruk_root = cangkruk["root"]
	_cangkruk_interior_door = cangkruk["interior_door"]
	_cangkruk_interior_spawn = cangkruk["interior_spawn"]
	_cangkruk_beds = cangkruk["bed_pos_list"]
	_cangkruk_lemari = cangkruk["lemari_spot"]
	_cangkruk_root.visible = false
	# Posisi pintu luar cangkruk (dari builder) + sandal yang
	# ditinggalkan di depan kedua pintu (RONDE 6).
	_cangkruk_door = _pesantren["cangkruk_door"]
	_cangkruk_exit = _pesantren["cangkruk_exit"]
	_sandal_luar_surau = _pesantren["root"].find_child("SandalLuarSurau", true, false)
	_sandal_luar_cangkruk = _pesantren["root"].find_child("SandalLuarCangkruk", true, false)
	# RONDE 20 — interior Musholla Ar-Raudhah (map interior KETIGA,
	# ala GTA): ruangan 14x10 m di (60,0,-301). DISEMBUNYIKAN saat
	# pemain di luar (pola double-surau ronde 6). Pemain putra TIDAK
	# PERNAH masuk — yang memakai: Ustadzah Mariyah (patroli + imam
	# putri). Titik keluar luar (musholla_exit) dari builder.
	var musholla := InteriorMusholla.build()
	add_child(musholla["root"])
	_musholla_root = musholla["root"]
	_musholla_door = musholla["interior_door"]
	_musholla_spawn = musholla["interior_spawn"]
	_musholla_root.visible = false
	_musholla_exit = _pesantren["musholla_exit"]
	# RONDE 21 — tembok pemisah + gerbang + spawn putri + pos satpam
	# (kontrak dict build Raka): dibaca pakai .get() dengan nilai
	# kontrak sebagai default — supaya _ready TIDAK crash kalau game
	# dijalankan sebelum merge Raka (kunci-kunci ini baru ada di
	# build() setelah merge); begitu kuncinya ada, nilai dict yang
	# dipakai. "pos_satpam" sudah ada di dict sejak Ronde 20.
	_tembok_x = float(_pesantren.get("tembok_x", 14.0))
	_tembok_z_min = float(_pesantren.get("tembok_z_min", -60.0))
	_tembok_z_max = float(_pesantren.get("tembok_z_max", 16.0))
	_batas_z_selatan = float(_pesantren.get("batas_z_selatan", 16.0))
	_gerbang_pos = _pesantren.get("gerbang_pos", Vector3(14, 0, 0))
	_gerbang_lebar = float(_pesantren.get("gerbang_lebar", 4.0))
	_spawn_putri = _pesantren.get("spawn_putri", Vector3(130, 0, 14))
	_pos_satpam = _pesantren.get("pos_satpam", Vector3(17, 0, 5))
	# RONDE PERBAIKAN (Eka): pusat Kelas Putri untuk penjaga cangkang
	# kosong (lihat _cek_batas) — setengah ukuran (5,0 x 4,0 m) mengikuti
	# kampus_putri.gd (KelasPutri 10x8 m), ditulis di _cek_batas.
	_kelas_putri_pos = _pesantren.get("kelas_putri_pos", Vector3(130, 0, 0))
	_sandal_luar_musholla = _pesantren["root"].find_child("SandalLuarMusholla", true, false)
	# Pemain.
	# Perbaikan 15 Nov ~12:00 WIB: kapsul dulu tinggi 1.2 dengan pusat
	# y=0.95 — alas kapsul 0,35 DI ATAS origin, jadi origin pemain
	# tenggelam 0,35 ke dalam tanah (kaki masuk tanah) dan bibir lantai
	# surau 0,15 m tidak bisa dilangkahi. Sekarang kapsul tinggi 1,7
	# berpusat y=0,85: alas tepat di origin (kaki menapak tanah).
	_player = SantriPlayer.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0, 0.85, 0)
	_player.add_child(shape)
	_player.floor_snap_length = 0.3
	_player.position = PesantrenBuilder.SPAWN
	# RONDE 21: posisi legal awal = titik spawn sesuai gender pemain
	# (putra -> SPAWN (-4,14); santriwati -> _spawn_putri (130,14)).
	_pos_legal_terakhir = _spawn_putri if _pemain_adalah_putri() else PesantrenBuilder.SPAWN
	_punya_pos_legal = true
	add_child(_player)
	_player.set_facing(PI) # menghadap surau (utara). Harus sesudah add_child (visual dibuat di _ready).
	# Kamera third-person (rig mengikuti pemain, orbit dengan drag).
	_rig = Node3D.new()
	_rig.name = "CameraRig"
	add_child(_rig)
	_spring = SpringArm3D.new()
	_spring.spring_length = 7.0
	_spring.margin = 0.5
	_spring.rotation = Vector3(_cam_pitch, 0, 0)
	_rig.add_child(_spring)
	var cam := Camera3D.new()
	cam.current = true
	cam.fov = 60.0
	_spring.add_child(cam)
	_cam = cam
	# NPC santri.
	_spawn_npcs()
	# UI.
	_ui = PesantrenUI.new()
	add_child(_ui)
	_ui.login_submitted.connect(_on_login)
	_ui.register_submitted.connect(_on_register)
	_ui.continue_pressed.connect(_on_continue)
	_ui.interact_pressed.connect(_on_interact)
	_ui.chat_sent.connect(_on_chat_sent)
	_ui.quiz_answered.connect(_on_quiz_answered)
	_ui.mission_closed.connect(_on_mission_closed)
	_ui.mahadiyah_toggled.connect(_on_mahadiyah_toggled)
	_ui.khataman_joined.connect(_on_khataman_joined)
	_ui.open_dashboard_requested.connect(_on_open_dashboard)
	_ui.open_peta_requested.connect(_on_open_peta)
	_ui.slide_changed.connect(_on_slide_changed)
	_ui.reset_requested.connect(_respawn_ke_spawn)
	# RONDE 6: aksi karakter + ganti outfit (kamar cangkruk).
	_ui.aksi_dipilih.connect(_on_aksi)
	_ui.outfit_dipilih.connect(_on_outfit_dipilih)
	# RONDE 13: tombol "Ikut Sholat" di banner sholat berjamaah.
	_ui.ikut_sholat_pressed.connect(_on_ikut_sholat)
	# BUBBLE-ML: pesan NPC (say() -> sinyal pesan) tampil di feed ML.
	# HARUS di sini (setelah _ui dibuat) — _spawn_npcs() di atas jalan
	# SEBELUM _ui ada, jadi connect di sana error Nil dan menghentikan
	# pembuatan npc2-npc5 (ditemukan tes reroute Raka, 17 Nov 2026).
	for npc in _npcs:
		npc.pesan.connect(_ui.tampilkan_pesan_melayang)
	# RONDE 7: tombol "Ganti Baju" di Kartu Santri — buka panel outfit
	# dari mana saja (dashboard ditutup dulu supaya panel tidak menumpuk).
	_ui.ganti_baju_requested.connect(_on_ganti_baju_requested)
	_ui.show_login(_save)
	# RONDE 17: audio suasana — dibuat setelah UI (tombol Suara ada di
	# HUD). mulai() TIDAK dipanggil di sini — baru pada gestur pertama
	# (autoplay web, lihat _input). Status mute dibaca dari save.
	_audio = AudioPesantren.new()
	add_child(_audio)
	_audio.set_mute(bool(_save.get("suara_mati", false)))
	_ui.set_suara_mati(bool(_save.get("suara_mati", false)))
	_ui.suara_toggled.connect(_on_suara_toggled)
	_refresh_markers()
	_update_hud()


func _input(event: InputEvent) -> void:
	# RONDE 17: autoplay web — audio baru boleh bunyi setelah gestur
	# pertama (klik/sentuh/tombol). _input dipanggil SEBELUM kontrol
	# GUI menelan event, jadi klik apa pun (termasuk tombol login)
	# membuka audio.
	if _audio_unlocked:
		return
	if event is InputEventMouseButton or event is InputEventKey or event is InputEventScreenTouch:
		_audio_unlocked = true
		_audio.mulai()


func _spawn_npcs() -> void:
	# RONDE 21: waypoint Bilal/Faris DIFILTER ke area putra + kawasan
	# bersama — titik di area putri DIBUANG. Aturan: x < -0,5 (barat
	# tembok) ATAU z > 16,5 (selatan ujung tembok, kawasan bersama).
	# Tembok pemisah kini di x=14 (dulu pagar x=0, lalu x=2,5) —
	# filter lama tetap benar untuk TITIK waypoint: tidak ada titik
	# yang lolos dengan x >= -0,5 dan z <= 16,5, jadi tidak ada
	# waypoint di timur tembok dengan z < 16. CATATAN (laporan
	# Ronde 21 ke Raka): NPC jalan GARIS LURUS tanpa collision
	# (npc.gd, Node3D biasa) dan target waypoint DIPILIH ACAK —
	# segmen lurus antara dua waypoint yang lolos (mis. (60,30) <->
	# (-60,-40)) MASIH bisa memotong garis x=14 di z < 16 secara
	# visual. Itu perilaku lama sejak pagar Ronde 20, bukan
	# waypoint yang menyeberang — perlu keputusan Raka (batasi
	# waypoint ke sisi barat saja, atau terima dulu).
	var wps: Array[Vector3] = []
	for wp in PesantrenBuilder.NPC_WAYPOINTS:
		if wp.x < -0.5 or wp.z > 16.5:
			wps.append(wp)
	# RONDE 11 (Mas: karakter harus beda-beda): Bilal vs Faris vs
	# pemain beda sekilas pandang. Bilal = kulit GELAP + kacamata +
	# songkok HITAM pekat + sarung biru; Faris = kulit TERANG + tanpa
	# kacamata + songkok putih + sarung coklat; pemain (default) =
	# kulit SAWO MATANG + tanpa kacamata + songkok putih + sarung
	# zamrud. Ketiganya beda kulit; Bilal beda juga kacamata+songkok.
	var outfit_bilal := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_bilal["sarung"] = "#1d4e6b"
	outfit_bilal["kulit"] = "#8a5a33"
	outfit_bilal["kacamata"] = true
	outfit_bilal["songkok"] = "#1a1a1a"
	var npc1 := SantriNPC.new()
	# RONDE 20: Bilal PINDAH (4,4) -> (-4,4) sisi PUTRA — spawn lama
	# jatuh di AREA PUTRI setelah pagar dibangun.
	npc1.setup("Bilal", Vector3(-4, 0, 4), wps, outfit_bilal)
	add_child(npc1)
	_npcs.append(npc1)
	npc1.rute_selesai.connect(_on_npc_rute_selesai)

	var outfit_faris := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_faris["sarung"] = "#6b3a1d"
	outfit_faris["kulit"] = "#e8b98a"
	outfit_faris["kacamata"] = false
	outfit_faris["songkok"] = "#faf7f0"
	var npc2 := SantriNPC.new()
	npc2.setup("Faris", Vector3(-5, 0, 8), wps, outfit_faris)
	add_child(npc2)
	_npcs.append(npc2)
	npc2.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 15 (Mas: karakter pemimpin pesantren): Ust. Aqsal Murad —
	# Pengasuh. Serban putih krem + jenggot gelap beruban di ujung +
	# kumis tipis; koko KREM + sarung HITAM (lihat
	# MissionData.OUTFIT_KYAI).
	# RONDE 20 (Mas 15:56 WIB: "duduk bersila sambil baca kitab
	# khusyu'.. sesekali keliling pondok untuk ngontrol"): Kyai TIDAK
	# LAGI diam di serambi — default DUDUK di dalam Surau membaca
	# kitab (kursi (5.6,-305) lokal, hadap kiblat), sesekali PATROLI
	# area putra/plaza: pintu Surau -> (-4,4) -> (-8,8) -> (-4,12) ->
	# (0,20) kawasan bersama -> (-8,18) -> (-2,2) -> pintu Surau.
	# Serambi (-4.8,-4.8) TETAP jadi "rumah" luar-nya (tujuan pulang
	# sholat + jangkar patroli) — lihat _mulai_sholat/_rute_pulang.
	# RONDE 21 (Sinta): terverifikasi tetap di serambi Surau GESER —
	# 2,37 m di depan pintu baru (-3.38,-6.75) sepanjang normal keluar
	# (205°), 0,47 m dari sumbu pintu; serambi 3 m, jadi masih di
	# atas lantai serambi (dulu 3,56 m / 1,31 m lateral).
	# Saat sesi sholat Kyai jalan ke Surau sebagai IMAM (ronde 16).
	var patroli_kyai := {
		"kursi": InteriorSurau.ke_dunia(Vector3(5.6, 0, -305.0)),
		"kursi_yaw": KIBLAT_YAW,
		"pintu_dalam": _interior_door,
		"spawn_dalam": _interior_spawn,
		"pintu_luar": _outdoor_exit,
		"rute_luar": [
			Vector3(-4, 0, 4), Vector3(-8, 0, 8), Vector3(-4, 0, 12),
			Vector3(0, 0, 20), Vector3(-8, 0, 18), Vector3(-2, 0, 2),
		],
	}
	var npc3 := SantriNPC.new()
	npc3.setup("Ust. Aqsal Murad", Vector3(-4.8, 0, -4.8), [Vector3(-4.8, 0, -4.8)], MissionData.OUTFIT_KYAI, false, patroli_kyai)
	add_child(npc3)
	_npcs.append(npc3)
	_kyai = npc3
	# RONDE 20 KOREKSI: rumah luar Kyai = serambi (-4.8,-4.8) —
	# default _rute_pulang sebelum ada sesi sholat (sebelum ini
	# default-nya SPAWN pemain; untuk Kyai tidak masalah karena
	# serambi juga di area putra, tapi ini yang benar per desain).
	_npc_rumah[npc3] = Vector3(-4.8, 0, -4.8)
	npc3.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 21 — Ustadzah Mariyah PINDAH ke kampus putri BARU (Opsi A,
	# ACC Mas 22:03 WIB): Musholla Ar-Raudhah kini di (134,-24).
	# ABAYA zamrud gelap + JILBAB krem (lihat
	# MissionData.OUTFIT_USTADZAH; susulan Ronde 20, Mas 19:42 WIB).
	# Default DUDUK di dalam Musholla membaca kitab, sesekali
	# PATROLI area putri baru. Home di dekat pintu Musholla baru
	# (134,-17); patroli di dalam kawasan putri, semua di timur
	# tembok x=14: depan Musholla (134,-14) -> jalan internal x=142
	# depan Cangkruk/Kelas Putri (142,-6) -> (142,6) -> dekat Kantor
	# Ustadzah (148,-24) -> pintu musholla. Saat sesi sholat ia
	# memimpin sisi putri sebagai IMAM di Musholla Ar-Raudhah
	# (bukan ke Surau). "Rumah" luar-nya: dekat pintu musholla
	# (tujuan pulang sholat).
	var patroli_ustadzah := {
		"kursi": InteriorMusholla.ke_dunia(InteriorMusholla.KURSI_USTADZAH),
		"kursi_yaw": KIBLAT_YAW,
		"pintu_dalam": _musholla_door,
		"spawn_dalam": _musholla_spawn,
		"pintu_luar": _musholla_exit,
		"rute_luar": [
			Vector3(134, 0, -14), Vector3(142, 0, -6),
			Vector3(142, 0, 6), Vector3(148, 0, -24),
		],
	}
	var npc4 := SantriNPC.new()
	npc4.setup("Ustadzah Mariyah", Vector3(134, 0, -17), [Vector3(134, 0, -17)], MissionData.OUTFIT_USTADZAH, false, patroli_ustadzah)
	add_child(npc4)
	_npcs.append(npc4)
	_ustadzah = npc4
	# RONDE 21 KOREKSI: rumah luar Ustadzah = dekat pintu musholla
	# BARU (134,-17) — default _rute_pulang sebelum ada sesi sholat.
	# Rumah lama (18,-16) jatuh di AREA PUTRA setelah kampus putri
	# pindah ke timur (tembok x=14).
	_npc_rumah[npc4] = Vector3(134, 0, -17)
	npc4.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 21 — SATPAM gerbang: seragam gelap (lihat
	# MissionData.OUTFIT_SATPAM). Berdiri TETAP di timur gerbang —
	# posisi dari dict build (_pos_satpam, kontrak Ronde 21) — menghadap
	# BARAT ke gerbang (14,0). TIDAK keliling, TIDAK mengobrol, TIDAK
	# ikut sholat (tetap di pos selama sesi). Mode diam (npc.gd).
	# RONDE PERBAIKAN (Eka, 17 Nov): SEBELUMNYA di (17,5) — TITIK
	# TENGAH gubuk PosSatpam 3x3 m — jadi ia berdiri DI DALAM gubuk,
	# tersembunyi di balik dinding 2,6 m (retest Ronde 23 tidak
	# menemukannya; raycast dari sisi putri menabrak dinding gubuk).
	# Percobaan pertama (15,0,5, depan pintu barat) MASIH tersembunyi
	# dari timur — gubuk menutupi dari hampir semua sudut timur
	# (raycast (20,10)->satpam menabrak dinding selatan gubuk).
	# Kini di SELATAN gubuk (17,0,8,0) — 1,5 m di selatan dinding
	# selatan, di tanah terbuka — terlihat jelas dari timur (arah
	# datang santriwati dari spawn), utara, dan selatan, + masih
	# bisa melihat gerbang. Yaw -2,78 = atan2(-3,-8), arah dari
	# (17,8) ke gerbang (14,0).
	var pos_satpam_luar := Vector3(17.0, 0, 8.0)
	var npc5 := SantriNPC.new()
	npc5.setup("Satpam", pos_satpam_luar, [pos_satpam_luar], MissionData.OUTFIT_SATPAM, true, {}, false)
	npc5.rotation.y = -2.78
	add_child(npc5)
	_npcs.append(npc5)
	_satpam = npc5
	npc5.rute_selesai.connect(_on_npc_rute_selesai)



# ---------- login / sesi ----------
# RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): login/daftar TANPA
# pilihan jalur. Satu kurikulum berurutan untuk semua santri.
# Integrasi login-gender (17 Nov 2026): login ke server dengan
# username IG (+ kata sandi bila sudah diset). Server mengembalikan
# ID + nama + jenis_kelamin ("putra"/"putri") + token sesi — gender
# ditulis ke save supaya _pemain_adalah_putri() + spawn + aturan
# batas cermin aktif. Gagal/offline = pesan jelas, save tidak diubah.
func _on_login(ig_username: String, password: String) -> void:
	# Ketukan ganda saat request berjalan: abaikan (tombol sudah
	# dikunci UI, ini jaring pengaman kedua).
	if _login_http != null:
		return
	var ig := SantriSave.normalisasi_ig(ig_username)
	_ui.set_login_loading(true)
	_ui.show_login_error("")
	var http := HTTPRequest.new()
	http.timeout = LOGIN_TIMEOUT_DETIK
	_login_http = http
	add_child(http)
	http.request_completed.connect(_on_login_http_selesai)
	var body := {"ig_username": ig}
	if password != "":
		body["password"] = password
	var err := http.request(
		SERVER_BASE_URL + "/api/santri/login",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		_login_http = null
		http.queue_free()
		_ui.set_login_loading(false)
		_ui.show_login_error("Tidak bisa menghubungi server. Periksa koneksi internet, lalu coba lagi.")


func _on_login_http_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _login_http
	_login_http = null
	if http != null:
		http.queue_free()
	_ui.set_login_loading(false)
	# Jawaban (apa pun isinya) menghapus galat sebelumnya — galat
	# hanya ditulis lagi di bawah bila jawaban ini memang gagal.
	_ui.show_login_error("")
	# Jaringan gagal (offline / DNS / timeout): jangan crash, jangan
	# ubah save — pemain tetap di layar login dengan pesan jelas.
	if result != HTTPRequest.RESULT_SUCCESS:
		_ui.show_login_error("Server tidak terjangkau. Periksa koneksi internet, lalu coba lagi.")
		return
	# 401 = kata sandi salah (cek sebelum parse supaya halaman error
	# proxy yang bukan JSON tidak menutupi pesannya).
	if response_code == 401:
		_ui.show_login_error("Kata sandi salah. Coba lagi.")
		return
	# Bukan JSON sama sekali (mis. halaman error proxy): jangan panggil
	# JSON.parse_string — ia mencetak ERROR ke log tanpa perlu.
	var teks := body.get_string_from_utf8().strip_edges()
	if not teks.begins_with("{"):
		_ui.show_login_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var parsed: Variant = JSON.parse_string(teks)
	if not (parsed is Dictionary):
		_ui.show_login_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var data := parsed as Dictionary
	if response_code != 200:
		_ui.show_login_error("Server menjawab %d. Coba lagi nanti." % response_code)
		return
	if not bool(data.get("found", false)):
		_ui.show_login_error("Username IG tidak ditemukan. Daftar dulu lewat aplikasi, lalu coba lagi.")
		return
	var galat := _terapkan_login_server(data)
	if galat != "":
		_ui.show_login_error(galat)
		return
	_masuk_pesantren("Selamat datang di Pesantren Universe, " + String(_save["nama"]) + "!")


## Terapkan jawaban login server ke save lokal. Murni (tanpa I/O
## jaringan) supaya bisa dites headless dengan respons stub.
## Mengembalikan "" bila sukses, atau pesan galat untuk ditampilkan.
## Aturan: jenis_kelamin di luar "putra"/"putri" (termasuk field
## belum ada di server) = "putra" — perilaku lama tetap aman.
## Baca string dari dict jawaban server dengan aman: nilai null
## (mis. jenis_kelamin:null untuk santri lama) TIDAK boleh masuk ke
## String(...) — konstruktor itu error pada null. Kembalikan default.
static func _str_atau(d: Dictionary, kunci: String, default: String = "") -> String:
	var v: Variant = d.get(kunci, default)
	return default if v == null else String(v)


func _terapkan_login_server(data: Dictionary) -> String:
	var id_santri := _str_atau(data, "id").strip_edges().to_upper()
	if not SantriSave.id_valid(id_santri):
		return "Server mengembalikan ID yang tidak valid."
	var nama := _str_atau(data, "nama").strip_edges()
	if nama.length() < 2:
		return "Server mengembalikan nama yang tidak valid."
	var jk := _str_atau(data, "jenis_kelamin", "putra").strip_edges().to_lower()
	if jk != "putri" and jk != "putra":
		jk = "putra"
	var ig := SantriSave.normalisasi_ig(_str_atau(data, "ig_username"))
	# ID baru = santri baru: mulai dari nol. ID sama = lanjutkan progres.
	# Counter ID lokal dipertahankan supaya daftar berikutnya tidak
	# bertabrakan dengan ID yang pernah dipakai di perangkat ini.
	var counter := int(_save.get("id_terakhir", 0))
	if String(_save.get("id_santri", "")) != id_santri:
		_save = SantriSave.default_data()
	_save["id_terakhir"] = counter
	SantriSave.catat_id(_save, id_santri)
	_save["id_santri"] = id_santri
	_save["nama"] = nama
	_save["ig_username"] = ig
	_save["jenis_kelamin"] = jk
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	_session_token = _str_atau(data, "session")
	SantriSave.save_data(_save)
	return ""


func _on_register(nama: String) -> void:
	# Santri baru: terbitkan ID berikutnya, simpan, langsung masuk.
	# terbitkan_id_baru() menaikkan counter di _save lama — salin dulu
	# nilainya sebelum reset ke data baru.
	var id_baru := SantriSave.terbitkan_id_baru(_save)
	var counter := int(_save.get("id_terakhir", 0))
	_save = SantriSave.default_data()
	_save["id_terakhir"] = counter
	_save["id_santri"] = id_baru
	_save["nama"] = nama
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	SantriSave.save_data(_save)
	_masuk_pesantren("Selamat datang, " + nama + "! ID Santrimu: " + id_baru + " — simpan baik-baik ya.")


func _on_continue() -> void:
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	SantriSave.save_data(_save)
	_masuk_pesantren("Selamat datang kembali, " + String(_save["nama"]) + "!")


## KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): samakan
## visual pemain dengan gender save. Santriwati ("putri") memakai
## muslimah + hijab (abaya + jilbab); santriwan tidak. Visual
## dibangun ulang HANYA bila flag-nya berubah — masuk ulang sebagai
## santriwan tidak membangun ulang apa-apa. Flag disimpan di save
## supaya panel Ganti Baju tahu baris mana yang ditampilkan dan
## warna abaya/jilbab bertahan antar sesi.
func _terapkan_gender_pemain() -> void:
	var outfit: Dictionary = _save.get("outfit", MissionData.OUTFIT_DEFAULT).duplicate()
	var putri := _pemain_adalah_putri()
	outfit["muslimah"] = putri
	outfit["hijab"] = putri
	_save["outfit"] = outfit
	if putri != _player.apakah_muslimah():
		_player.bangun_ulang_visual(outfit)
	SantriSave.save_data(_save)


func _masuk_pesantren(pesan: String) -> void:
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): visual
	# pemain mengikuti gender save — santriwati tampil abaya +
	# jilbab, santriwan tetap koko. Dipanggil di awal sini (sebelum
	# teleport) karena _ready membangun santriwan dulu.
	_terapkan_gender_pemain()
	# Spawn sesuai gender: santriwati di kampus putri (130,14),
	# santriwan di depan Surau (-4,14). Jangkar dorong-balik
	# _cek_batas ikut diperbarui di sini — _ready jalan SEBELUM
	# login (saat save masih putra), jadi tanpa ini santriwati
	# pertama kali login akan berdiri di area putra dan langsung
	# didorong balik ke titik yang salah.
	var spawn := _spawn_putri if _pemain_adalah_putri() else PesantrenBuilder.SPAWN
	_teleport_player(spawn, PI)
	_pos_legal_terakhir = spawn
	_punya_pos_legal = true
	_player.set_nama(String(_save["nama"]))
	# RONDE 6: terapkan outfit tersimpan (koko/songkok/sarung) saat masuk.
	_player.terapkan_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))
	_player.set_sandal(true)
	_ui.show_world()
	# FITUR CUACA (Wulan; hook Raka): mulai cuaca lokasi — sekali per
	# sesi; di luar web / izin ditolak / API gagal = tetap cerah.
	if _cuaca == null:
		_cuaca = Cuaca.new()
		_cuaca.name = "Cuaca"
		add_child(_cuaca)
	_cuaca.mulai(_pesantren["langit"])
	_ui.toast(pesan)
	_refresh_markers()
	_update_hud()


# ---------- respawn (jatuh ke jurang / keluar batas / tombol reset) ----------
# Perbaikan 15 Nov ~12:00 WIB (Mas jatuh ke jurang dan terjebak): kalau
# pemain jatuh di bawah ambang Y atau keluar batas pesantren, teleport
# kembali ke titik spawn (depan Surau). Dipanggil tiap frame di _process
# dan dari tombol "Reset Posisi" di HUD.
func _respawn_ke_spawn() -> void:
	# RONDE 4: reset selalu ke peta LUAR (depan Surau) — kalau pemain
	# jatuh/nyangkut di dalam interior pun, ia kembali ke luar.
	# Perbaikan 15 Nov ~17:20 WIB (penguji ronde 3: Reset Posisi tidak
	# mengembalikan arah kamera): reset kini lewat _teleport_player
	# yang men-snap posisi + arah hadap + yaw kamera + pitch kamera.
	# RONDE 6: reset juga mengeluarkan pemain dari interior (sembunyikan
	# kedua interior — perbaikan double surau), mengembalikan pose
	# berdiri + sandal dipakai lagi.
	_di_dalam = false
	_di_dalam_cangkruk = false
	_di_dalam_musholla = false
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_player.set_aksi("berdiri")
	# RONDE 13: reset posisi mengeluarkan pemain dari sholat (kalau
	# sedang ikut) — banner ditampilkan lagi selama sesi berjalan.
	# RONDE 18: banner hanya kembali selama "kumpul" (takbir sudah
	# mulai = pendaftaran ikut ditutup).
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		if _sholat_aktif and _sholat_adegan == "kumpul":
			_ui.show_sholat_banner(_sholat_nama, "Musholla" if _pemain_adalah_putri() else "Surau")
	_teleport_player(PesantrenBuilder.SPAWN, PI)
	_ui.toast("Kamu kembali ke depan Surau.")


# ---------- per-frame ----------
func _process(delta: float) -> void:
	_bob_time += delta
	# Jaring pengaman jurang: jatuh ke bawah -> kembali ke spawn.
	# RONDE 5 (Mas: "tidak ada batasannya"): cek batas luar DIHAPUS —
	# tidak ada lagi teleport karena jalan terlalu jauh. Yang tersisa
	# hanya jatuh ke bawah (y < -5, mis. jatuh dari tepi tanah di
	# ±400 m) -> kembali ke spawn. Pemain di dalam interior (z=-300)
	# TIDAK BOLEH kena cek apa pun — interior punya lantai sendiri.
	var pp := _player.global_position
	if pp.y < -5.0:
		_respawn_ke_spawn()
	# Pintu Surau: jalan melewati ambang pintu = pindah map (ala GTA).
	_cek_pintu_surau()
	# RONDE 6: pintu kamar cangkruk — pola yang sama seperti Surau.
	_cek_pintu_cangkruk()
	# RONDE PERBAIKAN (Raka, integrasi item 7f): pintu Musholla —
	# pola yang sama (masuk = teleport ke map interior Musholla).
	_cek_pintu_musholla()
	# RONDE 20: penegakan batas putra/putri + sandal NPC di pintu.
	_cek_batas(delta)
	_sinkron_sandal()
	# RONDE 13: masuk jendela waktu sholat -> mulai sesi berjamaah.
	_cek_waktu_sholat()
	# RONDE 18: mesin adegan sholat sinematik (takbir -> blackout ->
	# selesai) — jalan selama ada adegan, termasuk fase "selesai"
	# (fade masuk) yang sudah menutup sesi.
	if _sholat_adegan != "":
		_proses_adegan_sholat(delta)
	# RONDE 17: audio kegiatan mengikuti sesi yang berjalan (sholat /
	# khataman) — ambience mengikuti jam (di dalam AudioPesantren).
	_perbarui_audio()
	# Kamera mengikuti pemain. RONDE 4 (bonus "tampilan masih kaku"):
	# yaw/pitch kamera di-lerp (dulu dipasang langsung) supaya orbit
	# drag terasa halus, tidak patah-patah.
	# RONDE 7 (retest: kamera tidur masuk dinding — layar penuh kayu):
	# akar masalah: spring 7,0 m + pitch -0,35 menaruh kamera di
	# y≈4,0 — DI ATAS plafon cangkruk (3,6 m) yang TIDAK punya
	# collision, jadi spring tidak memendek dan kamera keluar ruangan
	# melihat plafon dari atas. Perbaikan 2 lapis: (a) di dalam
	# ruangan, spring dipendekkan ke 4,0 m (kamera y≈3,0 < plafon);
	# (b) plafon cangkruk kini punya collision (interior_cangkruk.gd)
	# sebagai jaring pengaman. Saat tidur, target rig diturunkan ke
	# 0,9 m supaya kamera memandang badan yang berbaring, bukan
	# udara kosong di atas kasur.
	var di_ruangan := _di_dalam or _di_dalam_cangkruk or _di_dalam_musholla
	# RONDE 7 revisi: saat tidur spring 3,0 m (lebih dekat + lebih
	# rendah — kasur mengisi frame, plafon tidak mendominasi).
	var panjang_spring := 3.0 if _player.aksi_saat_ini() == "tidur" else (4.0 if di_ruangan else 7.0)
	# RONDE PERBAIKAN (Eka): panjang spring dijaga _jarak_kamera_aman —
	# kamera tidak boleh terhalang tembok/objek dari pemainnya (lihat
	# fungsi di bawah). SpringArm3D saja tidak cukup: sinarnya hanya
	# memeriksa sepanjang 7 m dari rig — tembok yang 8 m jauhnya di
	# sepanjang sinar (pemain di utara gedung, kamera 7 m di selatan)
	# tidak tertangkap, kamera mendarat di dalam gedung/atap (probe
	# ronde perbaikan: pemain masuk cangkang KelasPutri, kamera di
	# (130, 4.02, 3.05) — di dalam footprint gedung, di atas atap).
	# CATATAN: SpringArm3D TIDAK diberi shape (SphereShape3D) —
	# shape cast yang berawal di rig (di dalam kapsul pemain sendiri)
	# langsung bertabrakan dengan kapsul itu dan menjepit kamera ke
	# panjang ~0. Penjaga garis pandang di bawah memakai raycast
	# (sinar dari titik tidak menabrak bentuk yang memuat titik awal).
	_spring.spring_length = _jarak_kamera_aman(panjang_spring, delta)
	var tinggi_rig := 0.9 if _player.aksi_saat_ini() == "tidur" else 1.6
	var target := _player.global_position + Vector3(0, tinggi_rig, 0)
	# RONDE 5 (perbaikan dari foto): bobot lerp HARUS dijepit ke 1.0 —
	# di frame lambat (delta > 0,125 dtk, mis. HP kentang / render
	# software) delta*8 > 1 membuat rig OVERSHOOT lalu berosilasi,
	# kamera terbang menjauh dari pemain (terbukti di foto NPC ronde 5:
	# kamera mendarat di papan selamat datang). Rotasi sudah dijepit.
	_rig.global_position = _rig.global_position.lerp(target, minf(1.0, delta * 8.0))
	_rig.rotation.y = lerp_angle(_rig.rotation.y, _cam_yaw, minf(1.0, delta * 12.0))
	_spring.rotation.x = lerpf(_spring.rotation.x, _cam_pitch, minf(1.0, delta * 12.0))
	# Gerak: joystick atau keyboard, relatif terhadap kamera.
	var input_vec := Vector2.ZERO
	var joy := _ui.get_joystick_vector()
	if joy.length() > 0.05:
		input_vec = joy
	else:
		input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if Input.is_key_pressed(KEY_A):
			input_vec.x -= 1.0
		if Input.is_key_pressed(KEY_D):
			input_vec.x += 1.0
		if Input.is_key_pressed(KEY_W):
			input_vec.y -= 1.0
		if Input.is_key_pressed(KEY_S):
			input_vec.y += 1.0
	var forward := -_rig.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := _rig.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	# RONDE 6: pose diam (duduk/menulis/tidur/salaman/melambai) menahan
	# gerak — input jalan dinolkan supaya pose tidak rusak.
	# RONDE 8: gerak MEMBANGUNKAN dari tidur / MENGAKHIRI salaman dan
	# melambai (pose tahan sampai pemain bergerak — retest: 5 dtk terlalu
	# singkat, bangun hanya bisa lewat Aksi -> Berdiri). input_mentah
	# dibaca SEBELUM dinolkan di bawah.
	var input_mentah := input_vec
	if _player.sedang_aksi_diam():
		input_vec = Vector2.ZERO
	if input_mentah.length() > 0.3 and _player.aksi_saat_ini() in ["tidur", "salaman", "melambai", "sholat"]:
		_on_aksi("berdiri")
	_player.move_dir = (right * input_vec.x + forward * (-input_vec.y))
	# Penanda misi terdekat.
	_update_interact_button()
	# Peta hidup: posisi santri + NPC diperbarui tiap frame selama
	# panel peta terbuka (RONDE 4). RONDE 5: minimap GTA di HUD juga
	# diperbarui tiap frame selama dunia terlihat.
	if _ui.is_peta_visible():
		_ui.update_peta(_data_peta())
	if _ui.is_world_visible():
		_ui.update_minimap(_data_peta())
	# BUBBLE-ML: blok RONDE 7 DIHAPUS — bubble 3D dimatikan, jadi
	# set_bubble_ditahan() kini no-op (player.gd). Label nama di bawah
	# tetap ditahan saat panel chat terbuka (masih dipakai).
	# RONDE 8: label nama JUGA ditahan saat panel chat terbuka (retest:
	# panel chat memotong label nama "Tes" jadi setengah).
	var chat_buka := _ui.is_chat_visible()
	_player.set_nama_ditahan(chat_buka)
	for npc in _npcs:
		npc.set_nama_ditahan(chat_buka)
	# Animasi bobbing penanda misi + batasi ukuran tampak ikon/status
	# (15 Nov ~12:50 WIB: label melayang tidak boleh membesar menutupi
	# layar saat kamera dekat).
	var i := 0
	for id in _markers.keys():
		var node: Node3D = _markers[id]
		var icon: Label3D = node.get_node_or_null("Icon")
		if icon != null and icon.visible:
			icon.position.y = 2.9 + sin(_bob_time * 2.0 + float(i)) * 0.15
			Palette.batasi_label_kamera(icon, _cam)
		var status: Label3D = node.get_node_or_null("Status")
		if status != null:
			Palette.batasi_label_kamera(status, _cam)
		i += 1


## RONDE PERBAIKAN (Eka) — penjaga kamera third-person: panjang spring
## AMAN (<= target) supaya kamera tidak menembus bangunan/karakter.
## Cara: raycast dari posisi kamera PROSPEKTIF (spring penuh = target)
## ke pemain. Kalau garis pandang itu bersih -> pakai target. Kalau
## terhalang -> spring dipendekkan ke proyeksi titik tabrak ke sumbu
## lengan (dikurangi margin 0,3 m) — kamera berhenti di depan
## penghalang, stabil (tidak berosilasi: panjang dihitung langsung dari
## titik tabrak, bukan ditarik-mundur iteratif). SpringArm3D sendiri
## tetap menangani tembok di antara rig dan kamera; penjaga ini
## menangani tembok di antara KAMERA dan pemain yang sinar spring-nya
## lewati (mis. dinding rendah dekat pemain yang sinar spring lewati
## dari atas — probe: sinar spring melewati tembok 3,6 m, kamera
## mendarat di dalam cangkang KelasPutri).
## (b) NPC tidak punya body fisika (npc.gd), jadi sinar tidak bisa
## mendeteksinya: kalau ada NPC dalam 0,9 m dari posisi kamera
## efektif, spring dibatasi 2,0 m (kamera merapat, tidak menembus
## karakter itu). Mengembalikan panjang spring frame ini (min 1,2 m).
func _jarak_kamera_aman(target: float, _delta: float) -> float:
	var rig_pos := _rig.global_position
	var arah := _spring.global_transform.basis.z.normalized()
	var kamera_penuh := rig_pos + arah * target
	var target_pemain := _player.global_position + Vector3(0, 1.2, 0)
	var q := PhysicsRayQueryParameters3D.create(kamera_penuh, target_pemain)
	q.collision_mask = 0xFFFFFFFF
	q.exclude = [_player.get_rid()]
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(q)
	var batas := target
	if not hit.is_empty():
		var h: Vector3 = hit["position"]
		batas = clampf((h - rig_pos).dot(arah) - 0.3, 1.2, target)
	var kamera_efektif := rig_pos + arah * batas
	for npc in _npcs:
		if kamera_efektif.distance_to(npc.global_position + Vector3(0, 1.2, 0)) < 0.9:
			batas = minf(batas, 2.0)
	return maxf(1.2, batas)


func _unhandled_input(event: InputEvent) -> void:
	# Orbit kamera dengan drag (di area 3D, bukan di atas tombol UI).
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_cam_yaw -= drag.relative.x * 0.006
		_cam_pitch = clampf(_cam_pitch - drag.relative.y * 0.005, -1.0, -0.1)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var motion := event as InputEventMouseMotion
		_cam_yaw -= motion.relative.x * 0.006
		_cam_pitch = clampf(_cam_pitch - motion.relative.y * 0.005, -1.0, -0.1)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_on_interact()


# ---------- misi ----------
func _misi_tersedia(misi: Dictionary) -> bool:
	# Rantai berurutan: misi ke-n terbuka bila semua misi sebelumnya selesai.
	var idx := MissionData.MISSIONS.find(misi)
	if idx <= 0:
		return true
	for j in range(idx):
		if not (String(MissionData.MISSIONS[j]["id"]) in (_save["misi_selesai"] as Array)):
			return false
	return true


func _misi_selesai(id_misi: String) -> bool:
	return id_misi in (_save["misi_selesai"] as Array)


func _misi_aktif_saat_ini() -> Dictionary:
	for m in MissionData.MISSIONS:
		if not _misi_selesai(String(m["id"])):
			return m
	return {}


func _refresh_markers() -> void:
	# RONDE 6 (sistem SATU jalur): cabang "jalur Ngaji Aja" DIHAPUS —
	# semua santri ikut misi berurutan M1->M2->M3.
	for m in MissionData.MISSIONS:
		var id: String = m["id"]
		var node: Node3D = _markers[id]
		var icon: Label3D = node.get_node("Icon")
		var status: Label3D = node.get_node("Status")
		if _misi_selesai(id):
			icon.visible = false
			status.visible = true
			status.text = "SELESAI"
			status.modulate = Color("#2e7d32")
		elif _misi_tersedia(m):
			icon.visible = true
			status.visible = false
		else:
			icon.visible = false
			status.visible = true
			status.text = "TERKUNCI"
			status.modulate = Palette.ABU


func _update_interact_button() -> void:
	if not _ui.is_world_visible():
		_ui.set_interact_visible(false)
		return
	# RONDE 4 — prioritas tombol interaksi: pintu surau (masuk/keluar)
	# dulu, lalu misi, lalu smartboard. Pintu penting karena pemain yang
	# berdiri di depan pintu harus bisa masuk tanpa jalan menembus dulu.
	# RONDE 6: pintu cangkruk (masuk/keluar) + lemari (ganti baju) +
	# tempat tidur (tidur) ditambahkan dengan prioritas yang sama.
	if not _di_dalam and _dekat_pintu_luar():
		_ui.set_interact_visible(true, "MASUK SURAU")
		return
	if _di_dalam and _dekat_pintu_dalam():
		_ui.set_interact_visible(true, "KELUAR SURAU")
		return
	if not _di_dalam_musholla and _dekat_pintu_musholla_luar():
		_ui.set_interact_visible(true, "MASUK MUSHOLLA")
		return
	if _di_dalam_musholla and _dekat_pintu_musholla_dalam():
		_ui.set_interact_visible(true, "KELUAR MUSHOLLA")
		return
	if not _di_dalam_cangkruk and _dekat_pintu_cangkruk_luar():
		_ui.set_interact_visible(true, "MASUK CANGKRUK")
		return
	if _di_dalam_cangkruk and _dekat_pintu_cangkruk_dalam():
		_ui.set_interact_visible(true, "KELUAR CANGKRUK")
		return
	if _di_dalam_cangkruk and _dekat_lemari():
		_ui.set_interact_visible(true, "GANTI BAJU")
		return
	if _di_dalam_cangkruk and _dekat_tempat_tidur():
		_ui.set_interact_visible(true, "TIDUR")
		return
	var dekat := _misi_terdekat()
	if not dekat.is_empty():
		var teks := "BUKA PETI" if bool(dekat.get("peti", false)) else "MULAI MISI"
		_ui.set_interact_visible(true, teks)
		return
	if _di_dalam and _dekat_smartboard():
		_ui.set_interact_visible(true, "LIHAT SMARTBOARD")
		return
	_ui.set_interact_visible(false)


# ---------- pintu Surau: masuk = pindah ke map interior (ala GTA) ----------
# Cara paling andal di codebase ini: SATU scene, interior dibangun jauh
# di (0, 0, -300) + teleport. Tidak ada reload scene, jadi state santri
# (ID, nama, poin, misi) utuh — yang pindah hanya posisi pemain
# + kamera (di-snap supaya tidak terbang melintasi peta).
# Jalan melewati ambang pintu memicu pindah; tombol interaksi adalah
# cadangan (pemain yang berhenti di depan pintu tetap bisa masuk).
func _cek_pintu_surau() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam:
		# RONDE 14: koridor pintu luar dalam FRAME pintu (Surau diputar
		# -25°): u = jarak sepanjang celah (sumbu 115°), v = jarak ke
		# DALAM bangunan (normal masuk 25°). Pemicu: |u|<1,2 (celah
		# pintu) dan 0<v<1,5 (zona 1,5 m di dalam cangkang — pemain
		# tidak bisa sampai sini kecuali lewat celah, dinding menahan
		# sisanya). Sama dengan koridor lama, hanya diputar mengikuti
		# pintu.
		var d := p - _outdoor_door
		var u := d.x * _surau_sumbu.x + d.z * _surau_sumbu.z
		var v := d.x * _surau_masuk.x + d.z * _surau_masuk.z
		if absf(u) < 1.2 and v > 0.0 and v < 1.5:
			_masuk_surau()
	else:
		# RONDE 14: koridor pintu DALAM, frame yang sama — pintu dalam
		# (0,-294) adalah pivot rotasi interior, posisinya tidak
		# berubah; v diukur ke LUAR ruangan (normal keluar 205°),
		# 0<v<1,5 (zona 1,5 m di dalam ruangan, dekat pintu).
		var d2 := p - _interior_door
		var u2 := d2.x * _surau_sumbu.x + d2.z * _surau_sumbu.z
		var v2 := d2.x * _surau_keluar.x + d2.z * _surau_keluar.z
		if absf(u2) < 1.2 and v2 > 0.0 and v2 < 1.5:
			_keluar_surau()


func _teleport_player(pos: Vector3, yaw: float) -> void:
	_player.global_position = pos
	_player.velocity = Vector3.ZERO
	_player.set_facing(yaw)
	# RONDE 6: teleport apa pun mengembalikan pose berdiri (supaya
	# pemain tidak nyangkut dalam pose duduk/tidur di tempat baru).
	_player.set_aksi("berdiri")
	# Kamera di-snap (bukan lerp) supaya tidak terbang 300 m melintasi
	# peta saat teleport; kamera di belakang pemain (yaw + PI).
	# Pitch ikut di-reset ke -0,35 (awal) supaya Reset Posisi juga
	# mengembalikan arah pandang vertikal (bukan cuma yaw).
	_cam_yaw = fmod(yaw + PI, TAU)
	_cam_pitch = -0.35
	_rig.global_position = pos + Vector3(0, 1.6, 0)
	_rig.rotation.y = _cam_yaw
	_spring.rotation.x = _cam_pitch


func _masuk_surau() -> void:
	_di_dalam = true
	_set_interior_terlihat(true, false)
	_set_sandal_ruangan(true)
	_teleport_player(_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Surau. Selamat mengaji!")


func _keluar_surau() -> void:
	_di_dalam = false
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_outdoor_exit, 0.0)
	_ui.toast("Kamu keluar dari Surau.")


# ---------- pintu Musholla (RONDE PERBAIKAN, integrasi item 7f) ----------
# Cermin _cek_pintu_surau — bedanya: shell Musholla TIDAK diputar
# (rotasi 0°), jadi koridor LUAR cukup sumbu dunia; koridor DALAM
# memakai frame interior (SUMBU/KELUAR dari InteriorMusholla).
# Pemicu luar HARUS di luar dinding (z -19..-17,5): pemain di-teleport
# SEBELUM masuk shell (134,-24) — shell itu kosong (lantai biru
# polos), interior yang benar ada di map terpisah (60,-301).
func _cek_pintu_musholla() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_musholla:
		if absf(p.x - _musholla_exit.x) < 1.0 and p.z > -19.0 and p.z < -17.5:
			_masuk_musholla()
	else:
		var d2 := p - _musholla_door
		var u2 := d2.x * InteriorMusholla.SUMBU.x + d2.z * InteriorMusholla.SUMBU.z
		var v2 := d2.x * InteriorMusholla.KELUAR.x + d2.z * InteriorMusholla.KELUAR.z
		if absf(u2) < 1.2 and v2 > 0.0 and v2 < 1.5:
			_keluar_musholla()


func _masuk_musholla() -> void:
	_di_dalam_musholla = true
	_set_interior_terlihat(false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_musholla_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Musholla. Selamat mengaji!")


func _keluar_musholla() -> void:
	_di_dalam_musholla = false
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_musholla_exit, 0.0)
	_ui.toast("Kamu keluar dari Musholla.")


# ---------- kamar cangkruk (RONDE 6): pintu + transisi interior ----------
func _cek_pintu_cangkruk() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_cangkruk:
		# Koridor pintu luar cangkruk: |x - pintu.x| < 0.8 (celah
		# pintu 1.6 m), z melewati bidang pintu (zona 1.5 m di dalam
		# cangkang). RONDE 20: pintu PINDAH (14,-10) -> (-12,-8) —
		# dibaca dari _cangkruk_door (builder), JANGAN hardcode.
		if absf(p.x - _cangkruk_door.x) < 0.8 and p.z < _cangkruk_door.z and p.z > _cangkruk_door.z - 1.5:
			_masuk_cangkruk()
	elif absf(p.x + 60.0) < 0.8 and p.z > -295.0 and p.z < -293.5:
		_keluar_cangkruk()


## RONDE 21 — penegakan batas putra/putri KERAS (Mas, pakem):
## tembok pemisah solid di x=14 (z -60..+16) menggantikan pagar
## kayu Ronde 20; gerbang (14,0) TERTUTUP + barrier collision penuh
## di builder. Pemain yang masuk zona larangan mendapat toast
## peringatan (dibatasi 1x per 4 detik) DAN didorong balik ke posisi
## legal terakhir. Selatan (z >= _batas_z_selatan) kawasan bersama.
## Hanya di luar ruangan. Hanya berlaku untuk PEMAIN — NPC tidak
## lewat sini (npc.gd jalan lurus tanpa collision; lihat catatan
## segmen waypoint di _spawn_npcs + laporan Ronde 21 ke Raka).
## _jarak_ke_pagar DIHAPUS: aturan keras tidak lagi menghitung jarak
## ke polyline pagar (PAGAR_GARIS dihapus Raka saat merge).
func _cek_batas(delta: float) -> void:
	_batas_toast_timer = maxf(0.0, _batas_toast_timer - delta)
	_kelas_toast_timer = maxf(0.0, _kelas_toast_timer - delta)
	if not _ui.is_world_visible() or _di_dalam or _di_dalam_cangkruk or _di_dalam_musholla:
		return
	# Pengasuh + musyrif/musyrifah + Keamanan boleh lewat.
	if _pemain_boleh_lewat_batas():
		return
	var p := _player.global_position
	var putri := _pemain_adalah_putri()
	# Zona larangan: putra dilarang x > tembok saat z < batas selatan;
	# santriwati cerminnya (x < tembok). Tanpa batas z_min: aturan
	# ini JUGA menutup celah putar lewat ujung utara tembok (z<-60)
	# yang ditemukan Mas — lewat ujung utara tetap didorong balik.
	var melanggar := false
	if putri:
		melanggar = p.x < _tembok_x and p.z < _batas_z_selatan
	else:
		melanggar = p.x > _tembok_x and p.z < _batas_z_selatan
	if melanggar:
		if _batas_toast_timer <= 0.0:
			_batas_toast_timer = 4.0
			_batas_toast_count += 1
			if putri:
				_ui.toast("Santriwati tidak boleh masuk area putra.")
			else:
				_ui.toast("Santri putra tidak boleh masuk area putri.")
		if _punya_pos_legal:
			_player.global_position = _pos_legal_terakhir
			_player.velocity = Vector3.ZERO
		return
	# RONDE PERBAIKAN (Eka) — AKAR MASALAH GERBANG (7x gagal di kelas
	# ini): tembok FISIK (BarrierGerbang + segmen tembok, builder)
	# menahan kapsul pemain di x≈13,45 — syarat "x > 14" di atas
	# TIDAK PERNAH terpicu, jadi toast + dorong balik tidak pernah
	# jalan walau pemain mendorong tembok 73 detik (probe ronde
	# perbaikan: x mentok 13,449, toast_count tetap 0). Penegakan kini
	# PROKSIMITAS: pemain yang MENEMPEL tembok (jarak < 0,6 m) DAN
	# MENEKAN ke arahnya (move_dir ke tembok) mendapat toast +
	# didorong balik 1,5 m. Berlaku di sepanjang tembok (z -60..16),
	# bukan cuma di gerbang; kawasan bersama selatan (z >= 16) bebas.
	var tekan_tembok := false
	var dorong_x := 0.0
	if putri:
		if p.x > _tembok_x and p.x < _tembok_x + 0.6 and p.z >= _tembok_z_min and p.z < _batas_z_selatan and _player.move_dir.x < -0.05:
			tekan_tembok = true
			dorong_x = _tembok_x + 1.5
	else:
		if p.x < _tembok_x and p.x > _tembok_x - 0.6 and p.z >= _tembok_z_min and p.z < _batas_z_selatan and _player.move_dir.x > 0.05:
			tekan_tembok = true
			dorong_x = _tembok_x - 1.5
	if tekan_tembok:
		if _batas_toast_timer <= 0.0:
			_batas_toast_timer = 4.0
			_batas_toast_count += 1
			if putri:
				_ui.toast("Santriwati tidak boleh masuk area putra.")
			else:
				_ui.toast("Santri putra tidak boleh masuk area putri.")
		_player.global_position = Vector3(dorong_x, p.y, p.z)
		_player.velocity = Vector3.ZERO
		_pos_legal_terakhir = _player.global_position
		_punya_pos_legal = true
		return
	# RONDE PERBAIKAN (Eka) — KELAS PUTRI (rute utara spawn putri):
	# cangkang kosong di (_kelas_putri_pos, 10x8 m) pintunya TERBUKA
	# (celah 1,6 m di dinding selatan, kampus_putri.gd) sehingga
	# pemain yang jalan lurus ke utara dari spawn putri masuk ke dalam
	# cangkang kosong lalu mentok di dinding utara — dan kamera ikut
	# masuk ke dalam/atas atap (probe: kamera (130, 4.02, 3.05) di
	# dalam footprint gedung). Perbaikan permanen ada di kampus_putri.gd
	# (Raka: daun pintu + jalan penghubung spawn -> JalanInternal);
	# sementara itu, di sini pemain yang masuk cangkang didorong balik
	# ke posisi legal terakhir (di depan pintu) + diberi arah ke jalan
	# timur. Zona = footprint PENUH (5,0 x 4,0 = bidang dinding) —
	# KOREKSI 17 Nov (foto E5a ulangan): zona lama disempitkan 0,3 m
	# ke dalam (4,7 x 3,7) menciptakan STRIP MATI z 3,7..3,875:
	# pemain yang berhenti di ambang pintu (z=3,71) sudah DI DALAM
	# gedung tapi DI LUAR zona, jadi penjaga tidak menembak dan ia
	# tetap berdiri di ambang. Bidang dinding AMAN sebagai tepi zona:
	# kapsul pemain (r=0,35) dari luar tidak bisa lebih dekat dari
	# 0,475 m ke bidang dinding, jadi pemain yang jalan MENGELILINGI
	# gedung tidak kena — hanya yang benar-benar melewati bidang
	# dinding lewat celah pintu yang kena.
	# KOREKSI 17 Nov (foto E5a): teleport JANGAN ke _pos_legal_terakhir
	# — jangkar itu dicatat tiap frame di luar zona, termasuk strip
	# ambang pintu z 3,7..4,0 (antara tepi zona dan dinding), jadi
	# pemain mendarat 0,27 m DI DALAM ambang pintu (foto: z=3,61).
	# Teleport kini ke titik aman TETAP: 0,5 m di selatan dinding
	# selatan (pusat.z + 4,5), x dipertahankan (celah pintu) — pemain
	# jelas DI LUAR gedung. Jangkar ikut diperbarui ke titik itu.
	if p.x > _kelas_putri_pos.x - 5.0 and p.x < _kelas_putri_pos.x + 5.0 and p.z > _kelas_putri_pos.z - 4.0 and p.z < _kelas_putri_pos.z + 4.0:
		if _kelas_toast_timer <= 0.0:
			_kelas_toast_timer = 4.0
			_kelas_toast_count += 1
			_ui.toast("Kelas Putri belum dibuka — ke Musholla lewat jalan di timur.")
		var titik_aman := Vector3(p.x, p.y, _kelas_putri_pos.z + 4.5)
		_player.global_position = titik_aman
		_player.velocity = Vector3.ZERO
		_pos_legal_terakhir = titik_aman
		_punya_pos_legal = true
		return
	# Posisi legal — catat tiap frame sebagai jangkar dorong-balik.
	_pos_legal_terakhir = p
	_punya_pos_legal = true


## RONDE 21 — gender pemain. Kunci save "jenis_kelamin" ("putra" /
## "putri") ditulis login server (_terapkan_login_server, dari field
## jenis_kelamin API) — default "putra" bila field belum ada. Cabang
## santriwati di _cek_batas + spawn putri aktif sendiri begitu kunci
## itu tertulis. Visual santriwati (abaya + jilbab) BELUM: karakter
## masih santriwan sampai Tim Karakter membangunnya (warna abaya
## belum diputuskan Mas) — login ini hanya mengatur spawn + aturan.
func _pemain_adalah_putri() -> bool:
	return String(_save.get("jenis_kelamin", "putra")) == "putri"


## RONDE 21 — pengecualian batas: Pengasuh + musyrif/musyrifah +
## Keamanan boleh lewat tembok. TEMUAN (laporan ke Raka): TIDAK ADA
## flag role pemain di mana pun (save maupun main.gd). Pengecekan
## keyed pada kunci save "role" — AKTIF SENDIRI begitu registrasi/
## server menulis role itu ("pengasuh" / "musyrif" / "musyrifah" /
## "keamanan"). Default "santri" = aturan berlaku penuh.
func _pemain_boleh_lewat_batas() -> bool:
	return String(_save.get("role", "santri")) in ["pengasuh", "musyrif", "musyrifah", "keamanan"]


## RONDE 20 — sandal di depan pintu Surau/Musholla: terlihat kalau
## ada yang di dalam ruangan itu (pemain di Surau, Kyai di Surau,
## Ustadzah di Musholla). Disinkron tiap frame supaya sandal Kyai/
## Ustadzah tidak tertutup logika sandal pemain (_set_sandal_ruangan
## hanya mengatur sandal pemain + cangkruk).
func _sinkron_sandal() -> void:
	if _sandal_luar_surau != null:
		_sandal_luar_surau.visible = _di_dalam or (_kyai != null and _kyai.di_dalam())
	if _sandal_luar_musholla != null:
		_sandal_luar_musholla.visible = _di_dalam_musholla or (_ustadzah != null and _ustadzah.di_dalam())


func _masuk_cangkruk() -> void:
	_di_dalam_cangkruk = true
	_set_interior_terlihat(false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_cangkruk_interior_spawn, PI)
	_ui.toast("Kamu masuk ke kamar cangkruk. Sandal dilepas di depan pintu.")


func _keluar_cangkruk() -> void:
	_di_dalam_cangkruk = false
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_cangkruk_exit, 0.0)
	_ui.toast("Kamu keluar dari kamar cangkruk.")


## Tampilkan/sembunyikan interior saat pemain masuk/keluar ruangan.
## RONDE 6 (perbaikan DOUBLE SURAU): kedua interior DISEMBUNYIKAN saat
## pemain di luar — ruangan interior (18x14 m di z=-300) sebelumnya
## terlihat dari spawn sebagai bangunan kedua.
## RONDE 20: interior KETIGA (musholla, x=60) — parameter ketiga,
## default false (pemain putra tidak pernah masuk).
func _set_interior_terlihat(surau: bool, cangkruk: bool, musholla: bool = false) -> void:
	if _interior_root != null:
		_interior_root.visible = surau
	if _cangkruk_root != null:
		_cangkruk_root.visible = cangkruk
	if _musholla_root != null:
		_musholla_root.visible = musholla


## Sandal otomatis lepas saat masuk ruangan (Surau/cangkruk) dan
## dipakai lagi saat keluar. Sandal yang dilepas terlihat di depan
## pintu ruangan yang dimasuki (SandalLuarSurau / SandalLuarCangkruk).
## RONDE 20: sandal Surau + Musholla diatur _sinkron_sandal() tiap
## frame (tergantung pemain + Kyai/Ustadzah yang di dalam) — di sini
## hanya sandal pemain + sandal cangkruk.
func _set_sandal_ruangan(masuk_ruangan: bool) -> void:
	if masuk_ruangan:
		_player.set_sandal(false)
		if _di_dalam_cangkruk and _sandal_luar_cangkruk != null:
			_sandal_luar_cangkruk.visible = true
	else:
		_player.set_sandal(true)
		if _sandal_luar_cangkruk != null:
			_sandal_luar_cangkruk.visible = false


func _dekat_pintu_luar() -> bool:
	return _player.global_position.distance_to(_outdoor_door) < 2.5


func _dekat_pintu_dalam() -> bool:
	return _player.global_position.distance_to(_interior_door) < 2.5


## RONDE PERBAIKAN (integrasi item 7f): dekat pintu Musholla —
## luar = titik keluar (134,-17,5), dalam = pintu interior (60,-296).
func _dekat_pintu_musholla_luar() -> bool:
	return _player.global_position.distance_to(_musholla_exit) < 2.5


func _dekat_pintu_musholla_dalam() -> bool:
	return _player.global_position.distance_to(_musholla_door) < 2.5


func _dekat_pintu_cangkruk_luar() -> bool:
	return _player.global_position.distance_to(_cangkruk_door) < 2.5


func _dekat_pintu_cangkruk_dalam() -> bool:
	return _player.global_position.distance_to(_cangkruk_interior_door) < 2.5


func _dekat_lemari() -> bool:
	return _player.global_position.distance_to(_cangkruk_lemari) < 2.5


func _dekat_tempat_tidur() -> bool:
	# RONDE 6 revisi 23:01 WIB: 5 kasur — dekat kalau dalam 2,5 m
	# dari kasur MANA SAJA.
	for b in _cangkruk_beds:
		if _player.global_position.distance_to(b) < 2.5:
			return true
	return false


## Kasur terdekat dari pemain (untuk snap saat tidur).
func _kasur_terdekat() -> Vector3:
	var best: Vector3 = _cangkruk_beds[0] if not _cangkruk_beds.is_empty() else Vector3.ZERO
	var best_d := 1e9
	for b in _cangkruk_beds:
		var d := _player.global_position.distance_to(b)
		if d < best_d:
			best_d = d
			best = b
	return best


func _dekat_smartboard() -> bool:
	return _player.global_position.distance_to(_smartboard_spot) < 3.5


func _misi_terdekat() -> Dictionary:
	# RONDE 6 (sistem SATU jalur): tidak ada lagi pengembalian {} untuk
	# "jalur Ngaji Aja" — semua santri ikut misi berurutan.
	var best := {}
	var best_d := CHAT_JARAK_INTERAKSI
	for m in MissionData.MISSIONS:
		if _misi_selesai(String(m["id"])):
			continue
		if not _misi_tersedia(m):
			continue
		var pos: Vector3 = m["penanda"]
		var d := _player.global_position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = m
	return best


func _di_dalam_surau() -> bool:
	# RONDE 4: "di dalam surau" = pemain sedang di map interior
	# (flag _di_dalam, diset tepat saat teleport masuk/keluar).
	return _di_dalam


func _on_interact() -> void:
	# Toggle: panel misi / smartboard sedang terbuka -> tutup dulu.
	if _ui.is_mission_visible():
		_ui.close_mission()
		return
	if _ui.is_smartboard_visible():
		_ui.close_smartboard()
		return
	# Pintu Surau (cadangan tombol — jalan menembus pintu juga bisa).
	if not _di_dalam and _dekat_pintu_luar():
		_masuk_surau()
		return
	if _di_dalam and _dekat_pintu_dalam():
		_keluar_surau()
		return
	# RONDE PERBAIKAN (integrasi item 7f): pintu Musholla (cadangan
	# tombol — jalan menembus pintu juga bisa).
	if not _di_dalam_musholla and _dekat_pintu_musholla_luar():
		_masuk_musholla()
		return
	if _di_dalam_musholla and _dekat_pintu_musholla_dalam():
		_keluar_musholla()
		return
	# RONDE 6: pintu cangkruk (masuk/keluar) + lemari (ganti baju) +
	# tempat tidur (tidur). Lemari/tidur dicek sebelum misi/smartboard
	# karena hanya ada di dalam cangkruk.
	if not _di_dalam_cangkruk and _dekat_pintu_cangkruk_luar():
		_masuk_cangkruk()
		return
	if _di_dalam_cangkruk and _dekat_pintu_cangkruk_dalam():
		_keluar_cangkruk()
		return
	if _di_dalam_cangkruk and _dekat_lemari():
		_ui.open_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))
		return
	if _di_dalam_cangkruk and _dekat_tempat_tidur():
		_on_aksi("tidur")
		return
	# Smartboard (di dalam surau, dekat papan pintar).
	if _di_dalam and _dekat_smartboard():
		_ui.open_smartboard()
		return
	var misi := _misi_terdekat()
	if misi.is_empty():
		return
	var syarat := String(misi.get("syarat", ""))
	if syarat == "surau" and not _di_dalam_surau():
		_ui.toast("Masuk ke dalam surau dulu, lalu tekan lagi.")
		return
	if syarat == "peti":
		# RONDE 20: peti PINDAH (6,10) -> (0,26) kawasan bersama —
		# dibaca dari builder, JANGAN hardcode (posisi lama jatuh di
		# area putri setelah pagar dibangun).
		var chest_pos := Vector3(PesantrenBuilder.PETI_POS.x, 0, PesantrenBuilder.PETI_POS.y)
		if _player.global_position.distance_to(chest_pos) > CHAT_JARAK_INTERAKSI:
			_ui.toast("Dekati peti kayu dulu.")
			return
	_active_misi = misi
	_ui.open_mission(misi)


func _on_quiz_answered(index: int) -> void:
	if _active_misi.is_empty():
		return
	var benar: bool = index == int(_active_misi["jawaban"])
	if benar:
		var poin: int = int(_active_misi["poin"])
		_save["poin"] = int(_save["poin"]) + poin
		(_save["misi_selesai"] as Array).append(String(_active_misi["id"]))
		SantriSave.save_data(_save)
		_ui.quiz_result(true, poin)
		_update_hud()
		_refresh_markers()
		if bool(_active_misi.get("peti", false)):
			_buka_peti()
	else:
		_ui.quiz_result(false, 0)


func _buka_peti() -> void:
	if _chest_opened:
		return
	_chest_opened = true
	var tween := create_tween()
	tween.tween_property(_chest_lid, "rotation:x", -1.9, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_mission_closed() -> void:
	_active_misi = {}


func _update_hud() -> void:
	var aktif := _misi_aktif_saat_ini()
	var teks := "Semua misi selesai!" if aktif.is_empty() else String(aktif["judul"])
	_ui.set_hud(int(_save["poin"]), teks)


# ---------- chat ----------
func _on_chat_sent(teks: String) -> void:
	# BUBBLE-ML: pesan pemain tampil di feed ML di atas joystick
	# (bukan bubble kotak di atas kepala — show_chat kini no-op).
	_ui.tampilkan_pesan_melayang(String(_save["nama"]), teks)
	_ui.add_chat_line(String(_save["nama"]), teks)
	# RONDE PERBAIKAN (Eka) — AKAR MASALAH BUBBLE: panel chat TIDAK
	# menutup sendiri setelah kirim, sementara bubble DITAHAN selama
	# panel terbuka (Ronde 7: panel menutupi bubble) + timer 5 detik
	# terus jalan — jadi bubble tidak pernah muncul (probe ronde
	# perbaikan: kirim saat panel buka -> bubble=false, timer habis
	# -0,07, tutup panel pun bubble tetap false). Tutup panel saat
	# kirim: bubble langsung terlihat di atas kepala; riwayat chat
	# tetap ada, panel bisa dibuka lagi dengan tombol Chat.
	_ui.close_chat()


# ---------- dashboard ----------
func _on_open_dashboard() -> void:
	# Perbaikan 15 Nov ~12:50 WIB (Kartu Santri tidak bisa ditutup):
	# tombol "Kartu Santri" kini membuka-MENUTUP (toggle).
	if _ui.is_dashboard_visible():
		_ui.close_dashboard()
		return
	var hari := SantriSave.tanggal_hari_ini()
	var mh: Dictionary = _save["mahadiyah"]
	var today_done: Array = mh.get(hari, [])
	var khataman: Array = _save["khataman_hadir"]
	_ui.open_dashboard(_save, today_done, khataman.has(hari), SantriSave.streak_mahadiyah(mh))


func _on_mahadiyah_toggled(key: String, checked: bool) -> void:
	var hari := SantriSave.tanggal_hari_ini()
	var mh: Dictionary = _save["mahadiyah"]
	var done: Array = mh.get(hari, [])
	if checked and not done.has(key):
		done.append(key)
	elif not checked and done.has(key):
		done.erase(key)
	mh[hari] = done
	_save["mahadiyah"] = mh
	SantriSave.save_data(_save)
	_ui.set_mahadiyah_streak(SantriSave.streak_mahadiyah(mh))


func _on_khataman_joined() -> void:
	var hari := SantriSave.tanggal_hari_ini()
	var khataman: Array = _save["khataman_hadir"]
	if not khataman.has(hari):
		khataman.append(hari)
	_save["khataman_hadir"] = khataman
	SantriSave.save_data(_save)
	_ui.set_khataman_hadir(true)
	_ui.toast("Kamu tercatat hadir khataman hari ini.")


# ---------- peta (RONDE 4) ----------
func _on_open_peta() -> void:
	# Tombol "Peta" di HUD: buka-MENUTUP (toggle, seperti Kartu Santri).
	if _ui.is_peta_visible():
		_ui.close_peta()
		return
	_ui.open_peta(_data_peta())


## Data untuk PetaControl + MinimapControl: posisi pemain + NPC
## (Vector2 x,z) + arah hadap + tujuan misi aktif + sawah + gunung.
## Kalau pemain di dalam interior, titiknya digambar DI SURAU (peta
## luar) — dari luar, "di dalam surau" memang di situ. Tujuan misi
## yang di dalam interior (M2) juga dipetakan ke Surau.
func _data_peta() -> Dictionary:
	var pp := _player.global_position
	var pemain := Vector2(pp.x, pp.z)
	if _di_dalam:
		pemain = PesantrenBuilder.SURAU_POS
	# RONDE PERBAIKAN (Raka, integrasi item 7f): di dalam Musholla,
	# titik pemain digambar DI MUSHOLLA (peta luar) — seperti Surau.
	if _di_dalam_musholla:
		pemain = PesantrenBuilder.MUSHOLLA_POS
	var npcs: Array = []
	for npc in _npcs:
		npcs.append({"nama": npc.nama_santri(), "pos": Vector2(npc.global_position.x, npc.global_position.z)})
	var target := Vector2.INF
	var aktif := _misi_aktif_saat_ini()
	if not aktif.is_empty():
		var tp: Vector3 = aktif["penanda"]
		target = Vector2(tp.x, tp.z)
		if _di_dalam or tp.z < -100.0:
			target = PesantrenBuilder.SURAU_POS
		if _di_dalam_musholla:
			target = PesantrenBuilder.MUSHOLLA_POS
	return {
		"player": pemain,
		"yaw": _player.get_facing_yaw(),
		"target": target,
		"npcs": npcs,
		"surau": PesantrenBuilder.SURAU_POS,
		# RONDE 14: Surau diputar -25° — peta besar menggambar kotaknya
		# sebagai poligon miring (ui.gd), bukan persegi tegak.
		"surau_rotasi": PesantrenBuilder.SURAU_ROTASI_DEG,
		"cangkruk": PesantrenBuilder.CANGKRUK_POS,
		"peti": PesantrenBuilder.PETI_POS,
		# RONDE 21: Musholla Ar-Raudhah (putri, kampus baru) + TEMBOK
		# pemisah + gerbang + pos jaga + pos satpam — digambar di
		# peta besar + minimap. "pagar_garis" DIGANTI "tembok_garis"
		# (PesantrenBuilder.TEMBOK_GARIS = [(14,-60),(14,16)]).
		# RONDE PERBAIKAN (Gita): ui.gd membaca "tembok_garis"
		# (fallback "pagar_garis") + "tembok_keliling_garis" /
		# "gerbang_putri_pos" (fallback konstanta TembokPutri) —
		# main.gd kini mengirim ketiga kunci itu langsung.
		"musholla": PesantrenBuilder.MUSHOLLA_POS,
		"musholla_rotasi": PesantrenBuilder.MUSHOLLA_ROTASI_DEG,
		"tembok_garis": PesantrenBuilder.TEMBOK_GARIS,
		"gerbang_pos": PesantrenBuilder.GERBANG_POS,
		"tembok_keliling_garis": TembokPutri.KELILING_GARIS,
		"gerbang_putri_pos": TembokPutri.GERBANG_PUTRI_POS,
		"pos_jaga": PesantrenBuilder.POS_JAGA,
		"pos_satpam": PesantrenBuilder.POS_SATPAM,
		"sawah_pos": PesantrenBuilder.SAWAH_POS,
		"sawah_size": PesantrenBuilder.SAWAH_SIZE,
		"gunung": PesantrenBuilder.GUNUNG,
		"half": PesantrenBuilder.MAP_HALF,
	}


# ---------- aksi karakter + ganti outfit (RONDE 6) ----------
func _on_aksi(nama: String) -> void:
	# RONDE 8: tekan TIDUR saat sudah tidur = bangun (toggle) — retest:
	# bangun hanya bisa lewat Aksi -> Berdiri.
	if nama == "tidur" and _player.aksi_saat_ini() == "tidur":
		nama = "berdiri"
	# RONDE 13: aksi apa pun (termasuk "berdiri" karena pemain
	# bergerak — lihat _process) mengakhiri keikutsertaan sholat:
	# pemain memilih aksi lain. Banner ditampilkan lagi supaya bisa
	# ikut lagi selama sesi masih berjalan.
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		if _sholat_aktif:
			_ui.show_sholat_banner(_sholat_nama, "Musholla" if _pemain_adalah_putri() else "Surau")
	var aksi_sebelum := _player.aksi_saat_ini()
	# Salaman: hadap NPC terdekat (<= 6 m) dulu supaya pose-nya
	# mengarah ke lawan bicara.
	if nama == "salaman":
		var dekat := _npc_terdekat(6.0)
		if dekat != null:
			var arah := dekat.global_position - _player.global_position
			arah.y = 0.0
			if arah.length() > 0.05:
				_player.set_facing(atan2(-arah.x, -arah.z))
	# Tidur: hanya di kamar cangkruk, dekat tempat tidur — snap
	# pemain ke tempat tidur dulu, lalu pose berbaring.
	if nama == "tidur":
		if not _di_dalam_cangkruk:
			_ui.toast("Tidur itu di kamar cangkruk, di sebelah Surau.")
			return
		if not _dekat_tempat_tidur():
			_ui.toast("Dekati tempat tidur dulu.")
			return
		# Snap ke kasur TERDEKAT. Offset +0,95 ke selatan (RONDE 9,
		# Mas: "kepalanya tembus ke luar"): origin pemain ada di KAKI
		# (rotasi tidur memutar visual di origin), jadi kepala jatuh
		# 1,66 m ke utara origin — offset +0,15 lama menaruh kepala
		# di bed_z-1,51, menembus dinding utara (terukur headless:
		# kasur utara-tengah kepala z=-305,21, ujung -305,45, melewati
		# muka luar dinding -305,125). Dengan +0,95 kepala di
		# bed_z-0,71 (tepat di atas bantal, pusat -0,75), ujung kepala
		# -0,95 masih di atas kasur (tepi -1,0), kaki di +0,88 (tepi
		# +1,05) — badan 1,83 m pas di kasur 2,1 m, kepala 0,23 m
		# dari muka dalam dinding utara.
		_player.set_facing(0.0)
		_player.global_position = _kasur_terdekat() + Vector3(0, 0, 0.95)
	_player.set_aksi(nama)
	# RONDE 8: bangun dari tidur — jepret kamera ke posisi akhir +
	# pitch default (-0,35) supaya tidak menyapu melewati lampu gantung
	# saat lerp (retest: bangun -> layar 80% hitam, kamera terjepit bola
	# lampu). Lampu juga sudah dipindah + diberi collision (lihat
	# interior_cangkruk.gd) — jepretan ini lapis keduanya.
	if aksi_sebelum == "tidur" and nama == "berdiri":
		_cam_pitch = -0.35
		_rig.global_position = _player.global_position + Vector3(0, 1.6, 0)
		_spring.rotation.x = _cam_pitch
	# RONDE 7 (retest: pose dikira tidak jalan): konfirmasi toast
	# untuk SETIAP pose supaya ada umpan balik langsung — pose duduk
	# dari belakang memang halus (hanya badan turun), jadi toast
	# menegaskan aksinya berhasil.
	var label_pose := {"duduk": "Duduk bersila.", "berdiri": "Berdiri.", "salaman": "Salaman.", "menulis": "Menulis.", "melambai": "Melambai.", "tidur": "Selamat tidur, santri."}
	if nama == "bawa_kitab":
		_ui.toast("Kitab dipegang." if _player.bawa_kitab_aktif() else "Kitab disimpan.")
	elif label_pose.has(nama):
		_ui.toast(String(label_pose[nama]))


func _npc_terdekat(jarak_maks: float) -> SantriNPC:
	var best: SantriNPC = null
	var best_d := jarak_maks
	for npc in _npcs:
		var d := _player.global_position.distance_to(npc.global_position)
		if d < best_d:
			best_d = d
			best = npc
	return best


func _on_ganti_baju_requested() -> void:
	# RONDE 7: tombol "Ganti Baju" di Kartu Santri — tutup dashboard,
	# buka panel outfit dengan outfit saat ini (panel yang sama seperti
	# dari lemari; pilihan langsung diterapkan + disimpan).
	_ui.close_dashboard()
	_ui.open_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))


func _on_outfit_dipilih(jenis: String, warna_hex: String) -> void:
	var outfit: Dictionary = _save.get("outfit", MissionData.OUTFIT_DEFAULT).duplicate()
	# RONDE 11: kacamata disimpan sebagai bool, bukan hex — sinyal
	# membawa "ya"/"tidak" dari panel (lihat ui.gd _on_kacamata_dipilih).
	if jenis == "kacamata":
		outfit["kacamata"] = warna_hex == "ya"
	else:
		outfit[jenis] = warna_hex
	_save["outfit"] = outfit
	# RONDE 8 (retest: ganti baju tidak mengubah karakter di live —
	# headless membuktikan rantai sinyal→material jalan): visual DULU,
	# simpan belakangan — supaya kegagalan tulis save tidak mungkin
	# menggagalkan perubahan tampilan. Print diagnostik supaya retest
	# browser berikutnya bisa membuktikan sinyal ini sampai di sini.
	_player.terapkan_outfit(outfit)
	print("[RONDE8] outfit_dipilih: %s=%s -> sarung=%s" % [jenis, warna_hex, str(outfit.get("sarung", "?"))])
	SantriSave.save_data(_save)
	_ui.set_outfit_terpilih(jenis, warna_hex)


# ---------- sholat berjamaah (RONDE 13) ----------
## Cek jam perangkat tiap frame: masuk jendela sholat -> mulai sesi;
## jendela habis -> akhiri sesi. Hanya saat dunia terlihat (layar
## login menutupi dunia = sesi tidak mulai; begitu masuk di tengah
## jendela, sesi langsung mulai di frame berikutnya).
func _cek_waktu_sholat() -> void:
	if not _ui.is_world_visible():
		return
	var jam := LangitDinamis.jam_saat_ini()
	var s := MissionData.sholat_saat_ini(jam)
	# RONDE 18: bersihkan kunci sesi kemarin (tanggal berganti).
	var tgl := Time.get_date_string_from_system()
	if tgl != _sholat_tanggal:
		_sholat_tanggal = tgl
		_sholat_sudah.clear()
	if not _sholat_aktif and not s.is_empty():
		# RONDE 18: sesi yang sudah jalan di jendela ini (adegan
		# selesai sebelum 1 menit habis) TIDAK boleh mulai lagi.
		var kunci := String(s["nama"]) + "_" + String(s["jam"]) + "_" + tgl
		if not _sholat_sudah.has(kunci):
			_mulai_sholat(s)
	elif _sholat_aktif and int(jam * 60.0) >= _sholat_akhir_menit:
		_akhiri_sholat()


# ---------- audio suasana (RONDE 17) ----------
## Audio kegiatan mengikuti sesi yang berjalan — hanya saat dunia
## terlihat (layar login menutupi dunia = tidak ada kegiatan).
## Sholat -> wirid; khataman -> nadzom (Amtsilah) / khataman (kitab
## lain). Bila file bacaan belum ada, AudioPesantren diam-diam tetap
## memainkan ambience (fallback, tanpa error).
func _perbarui_audio() -> void:
	var kegiatan := ""
	if _ui.is_world_visible():
		if _sholat_aktif:
			kegiatan = "wirid"
		else:
			var kh := MissionData.khataman_saat_ini()
			if not kh.is_empty():
				kegiatan = AudioPesantren.kegiatan_untuk_kitab(String(kh.get("kitab", "")))
	_audio.set_kegiatan(kegiatan)


## Tombol "Suara"/"Senyap" di HUD: balik status mute + simpan.
func _on_suara_toggled() -> void:
	var mati := not bool(_save.get("suara_mati", false))
	_save["suara_mati"] = mati
	_audio.set_mute(mati)
	_ui.set_suara_mati(mati)
	SantriSave.save_data(_save)


## Mulai sesi: toast + banner untuk pemain, NPC jalan ke Surau.
func _mulai_sholat(s: Dictionary) -> void:
	var nama := String(s["nama"])
	var parts := String(s["jam"]).split(":")
	var mulai := int(parts[0]) * 60 + int(parts[1])
	_sholat_aktif = true
	_sholat_nama = nama
	_sholat_akhir_menit = mulai + int(s.get("durasi_menit", 1))
	# RONDE 18: adegan dimulai dari "kumpul" — NPC jalan ke Surau;
	# takbir baru mulai kalau semua NPC sudah di sajadah (atau
	# timeout, lihat _proses_adegan_sholat).
	_sholat_adegan = "kumpul"
	_sholat_adegan_t = 0.0
	# RONDE PERBAIKAN (Eka): toast mengikuti gender/area pemain —
	# santriwati sholat di Musholla, bukan Surau (retest Ronde 23:
	# banner Dzuhur tulis "Surau" bahkan untuk putri). CATATAN: teks
	# BANNER-nya sendiri dibangun di ui.gd show_sholat_banner()
	# (BUKAN file ini) — perlu patch 1 baris di sana (lihat
	# RONDE-PERBAIKAN-EKA.md): show_sholat_banner(nama, tempat) dengan
	# tempat "Musholla"/"Surau", dipanggil dari 3 tempat di main.gd.
	var tempat_sholat := "Musholla" if _pemain_adalah_putri() else "Surau"
	_ui.toast("Waktu sholat " + nama + " — ayo ke " + tempat_sholat + "!")
	_ui.show_sholat_banner(nama, tempat_sholat)
	# FITUR ADZAN (Sinta, 17 Nov 2026): adzan bunyi BERSAMAAN dengan
	# banner. Sekali per sesi — _mulai_sholat hanya dipanggil sekali
	# per jendela berkat kunci _sholat_sudah di _cek_waktu_sholat
	# (dan mainkan_adzan() sendiri menolak mulai ulang selagi bunyi).
	# Bila file adzan.ogg belum ada / suara dimatikan, fungsi itu
	# diam saja — banner + sesi tetap jalan normal.
	_audio.mainkan_adzan()
	# RONDE 15: NPC diam (Kyai, berdiri tetap di serambi) TIDAK ikut
	# jalan ke Surau — tetap di tempat selama sesi; sajadah tetap
	# Sajadah_02 (Bilal) / Sajadah_04 (Faris).
	# RONDE 16 (Mas: Pengasuh seharusnya memimpin sebagai imam):
	# Kyai TIDAK lagi dilewati — ia jalan ke Surau seperti Bilal/
	# Faris, tapi ke POSISI IMAM di depan saf (lihat _posisi_imam),
	# bukan ke sajadah jamaah. Counter j hanya untuk jamaah supaya
	# Bilal tetap Sajadah_02 dan Faris tetap Sajadah_04.
	# RONDE 20: Kyai TIDAK LAGI diam di serambi — ia patroli (duduk di
	# Surau / keliling). Imam dikenali dari referensi _kyai (bukan
	# berdiri_tetap()). Ustadzah Mariyah memimpin sisi PUTRI sebagai
	# imam di Musholla Ar-Raudhah (bukan ke Surau). SATPAM dilewati
	# total (ikut_sholat()=false — tetap di pos gerbang).
	var sajadah := ["Sajadah_02", "Sajadah_04"]
	var j := 0
	for i in range(_npcs.size()):
		var npc := _npcs[i]
		if not npc.ikut_sholat():
			continue
		if npc == _kyai:
			_npc_rumah[npc] = npc.global_position
			_sajadah_npc[npc] = _posisi_imam()
			_npc_sholat_fase[npc] = "ke_pintu"
			npc.say("Ayo sholat berjamaah — saya jadi imam.")
			if npc.di_dalam():
				# Kyai sedang duduk di dalam Surau — keluarkan dulu
				# (teleport ke pintu luar), rute dihitung dari luar.
				npc.teleport_ke_pintu_luar()
			npc.mulai_rute(_rute_ke_pintu_surau(npc.global_position))
			continue
		if npc == _ustadzah:
			_npc_rumah[npc] = npc.global_position
			_sajadah_npc[npc] = _posisi_imam_musholla()
			npc.say("Ayo sholat berjamaah di Musholla Ar-Raudhah — saya jadi imam.")
			if npc.di_dalam():
				# Ustadzah sudah di dalam musholla — langsung jalan ke
				# sajadah imam (tanpa keluar-masuk lagi).
				_npc_sholat_fase[npc] = "ke_sajadah"
				npc.mulai_rute([_sajadah_npc[npc]])
			else:
				_npc_sholat_fase[npc] = "ke_pintu"
				npc.mulai_rute(_rute_ke_pintu_musholla(npc.global_position))
			continue
		_npc_rumah[npc] = npc.global_position
		_sajadah_npc[npc] = _posisi_sajadah(sajadah[j % sajadah.size()])
		_npc_sholat_fase[npc] = "ke_pintu"
		npc.say("Ayo sholat berjamaah di Surau!")
		npc.mulai_rute(_rute_ke_pintu_surau(npc.global_position))
		j += 1


## Akhiri sesi: banner hilang, pemain yang ikut berdiri lagi, NPC
## pulang (yang di dalam jalan ke pintu dalam dulu; yang masih di
## luar langsung pulang dari posisinya).
## RONDE 18: fade_in=true (akhir sinematik) — layar TIDAK langsung
## terang: overlay blackout dibiarkan lalu di-fade masuk oleh mesin
## adegan ("selesai"); fade_in=false (batas jam / abort) — overlay
## langsung disembunyikan supaya pemain tidak terjebak di layar hitam.
func _akhiri_sholat(fade_in: bool = false) -> void:
	# RONDE 18: tandai sesi ini sudah jalan (nama + jam mulai +
	# tanggal) — adegan selesai sebelum jendela 1 menit habis, jadi
	# tanpa kunci ini sesi langsung mulai lagi di sisa jendela.
	if _sholat_aktif:
		var mulai := _sholat_akhir_menit - 1
		var kunci := _sholat_nama + "_%02d:%02d_" % [mulai / 60, mulai % 60] + Time.get_date_string_from_system()
		_sholat_sudah[kunci] = true
	_sholat_aktif = false
	_ui.hide_sholat_banner()
	_ui.toast("Sholat " + _sholat_nama + " selesai.")
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		_player.set_aksi("berdiri")
	for npc in _npcs:
		var fase := String(_npc_sholat_fase.get(npc, ""))
		if fase == "sholat" or fase == "ke_sajadah":
			_npc_sholat_fase[npc] = "pulang_dalam"
			# RONDE 20: Ustadzah pulang lewat pintu DALAM musholla
			# (bukan pintu Surau) — rute pulang_dalam dihitung dari
			# ruangan masing-masing.
			var pintu_dalam := _musholla_door if npc == _ustadzah else _interior_door
			var rute: Array[Vector3] = [pintu_dalam + Vector3(0, 0, 0.5)]
			npc.mulai_rute(rute)
		elif fase == "ke_pintu":
			_npc_sholat_fase[npc] = "pulang_luar"
			npc.mulai_rute(_rute_pulang(npc))
	if fade_in:
		_sholat_adegan = "selesai"
		_sholat_adegan_t = 0.0
	else:
		_sholat_adegan = ""
		_sholat_adegan_t = 0.0
		_ui.hide_blackout()


## Mesin adegan sholat sinematik (RONDE 18) — jalan tiap frame selama
## _sholat_adegan != "". Timer di waktu GAME (delta), bukan jam
## perangkat (supaya tes dengan debug_jam beku tetap jalan).
func _proses_adegan_sholat(delta: float) -> void:
	match _sholat_adegan:
		"kumpul":
			# Takbir mulai kalau SEMUA NPC sudah di sajadah (fase
			# "sholat" = sampai + pose takbir) — atau timeout 25 dtk
			# (NPC nyangkut di jalan; takbir jalan dengan yang ada).
			_sholat_adegan_t += delta
			var semua_sudah := true
			for npc in _npcs:
				# RONDE 20: satpam TIDAK ikut sholat — jangan ditunggu.
				if not npc.ikut_sholat():
					continue
				if String(_npc_sholat_fase.get(npc, "")) != "sholat":
					semua_sudah = false
					break
			if semua_sudah or _sholat_adegan_t >= KUMPUL_TIMEOUT_DETIK:
				_sholat_adegan = "takbir"
				_sholat_adegan_t = 0.0
				# Takbir dimulai = pendaftaran ikut DITUTUP.
				_ui.hide_sholat_banner()
		"takbir":
			_sholat_adegan_t += delta
			if _sholat_adegan_t >= TAKBIR_TAHAN_DETIK:
				_sholat_adegan = "gelap"
				_sholat_adegan_t = 0.0
				_ui.show_blackout()
		"gelap":
			_sholat_adegan_t += delta
			# Fade ke hitam 0,5 dtk, lalu tahan hitam sampai 2,5 dtk.
			_ui.set_blackout_alpha(clampf(_sholat_adegan_t / BLACKOUT_FADE_DETIK, 0.0, 1.0))
			if _sholat_adegan_t >= BLACKOUT_DETIK:
				# Selesai: sesi berakhir (NPC pulang, pemain berdiri)
				# TAPI layar tetap hitam dulu — fade masuk di bawah.
				_akhiri_sholat(true)
		"selesai":
			_sholat_adegan_t += delta
			# Fade masuk 0,8 dtk, lalu overlay hilang total.
			var a := 1.0 - clampf(_sholat_adegan_t / FADE_MASUK_DETIK, 0.0, 1.0)
			_ui.set_blackout_alpha(a)
			if _sholat_adegan_t >= FADE_MASUK_DETIK:
				_ui.hide_blackout()
				_sholat_adegan = ""
				_sholat_adegan_t = 0.0


## Posisi dunia sebuah sajadah — diambil dari scene SAAT ITU juga,
## JANGAN hardcode: ronde 14 memutar Surau, posisi sajadah ikut
## berubah; lookup runtime selalu benar.
func _posisi_sajadah(nama_node: String) -> Vector3:
	var node := _interior_root.find_child(nama_node, true, false)
	if node is Node3D:
		return (node as Node3D).global_position
	return _interior_spawn


## RONDE 16 — posisi imam: tengah baris depan (Sajadah_03) + arah
## kiblat × IMAM_JARAK_DEPAN. Lookup runtime (seperti _posisi_sajadah)
## supaya rotasi Surau ronde 14 tetap benar otomatis; arah kiblat
## dari KIBLAT_YAW (wajah karakter di +Z lokal).
func _posisi_imam() -> Vector3:
	var tengah := _posisi_sajadah("Sajadah_03")
	var arah := Vector3(sin(KIBLAT_YAW), 0, cos(KIBLAT_YAW))
	return tengah + arah * IMAM_JARAK_DEPAN


## RONDE 20 — posisi sajadah di dalam Musholla Ar-Raudhah (lookup
## runtime di _musholla_root, pola _posisi_sajadah untuk Surau).
func _posisi_sajadah_musholla(nama_node: String) -> Vector3:
	var node := _musholla_root.find_child(nama_node, true, false)
	if node is Node3D:
		return (node as Node3D).global_position
	return _musholla_spawn


## RONDE 20 — posisi imam PUTRI: tengah baris depan musholla
## (Sajadah_03) + arah kiblat × IMAM_JARAK_DEPAN. Ustadzah Mariyah
## memimpin sholat putri dari sini (Mas 15:56 WIB).
func _posisi_imam_musholla() -> Vector3:
	var tengah := _posisi_sajadah_musholla("Sajadah_03")
	var arah := Vector3(sin(KIBLAT_YAW), 0, cos(KIBLAT_YAW))
	return tengah + arah * IMAM_JARAK_DEPAN


## RONDE 21 — rute jalan kaki Ustadzah Mariyah ke pintu Musholla
## Ar-Raudhah (kampus putri BARU, Opsi A). Sederhana: dari area
## putri -> (134,-14) selatan musholla -> depan pintu (_musholla_exit,
## dari dict build — pintu + keluar x 1,5 m). Kalau dari utara
## musholla (z < -14, seharusnya tidak terjadi — patroli putri di
## selatan), keluar ke z=-14 dulu supaya tidak menembus musholla.
## Tidak ada koridor barat/timur: area putri terbuka, satu-satunya
## bangunan di jalur ini adalah musholla itu sendiri. Titik selatan
## lama (18,-14) ikut pindah ke (134,-14) mengikuti Musholla
## (18,-24) -> (134,-24); z=-14 tetap (pusat musholla z-nya sama).
func _rute_ke_pintu_musholla(dari: Vector3) -> Array[Vector3]:
	var rute: Array[Vector3] = []
	if dari.z < -14.0:
		rute.append(Vector3(dari.x, 0, -14.0))
	# RONDE 22 (Sinta): tembok keliling kampus putri (x=115,
	# z -52..+22; gerbang barat (115,0)). Kalau Ustadzah kebetulan di
	# barat tembok, garis lurus ke (134,-14) MEMOTONG tembok di
	# (115,-14) — belok lewat gerbang dulu: (18,-14) -> (115,0) ->
	# (134,-14). Mekanisme rute mendukung waypoint perantara
	# (mulai_rute menerima Array[Vector3]).
	if dari.x < 115.0:
		rute.append(Vector3(115, 0, 0))
	rute.append(Vector3(134, 0, -14.0))
	rute.append(_musholla_exit)
	return rute


## Rute jalan kaki NPC ke pintu Surau — SEGMENTASI (Manhattan),
## bukan garis lurus: garis lurus dari utara akan menembus dinding
## Surau/cangkruk. Koridor aman: z <= -27 (utara kedua bangunan),
## x <= -28 (barat Surau + cangkruk), z >= 2 (plaza selatan, terbuka).
## RONDE 21 (Sinta): koridor utara PINDAH -22 -> -27 — Surau geser
## ke (0,-14) dan sudut barat lautnya kini di z=-25,48, jadi garis
## z=-22 MEMOTONG tapak Surau (x -7,30..1,77). Koridor barat PINDAH
## -20 -> -28 — cangkruk pindah ke (-22,-18), membentang x -27..-17,
## z -22..-14; koridor lama x=-20 menembus cangkruk baru. Koridor
## baru x=-28: 1 m di barat dinding cangkruk, 2 m dari pohon (-26,-8)
## dan lampu (-30,-2); pohon (-20,-26) + lampu (-20,-28) kini di
## timur koridor (koridor lama x=-20 akan menabrak pohon itu kalau
## diperpanjang ke utara). Titik plaza (-2,2) TETAP — 7,3 m di selatan
## dinding selatan Surau, segmen (-2,2) -> depan pintu tidak menabrak
## dinding (terverifikasi geometris: kedua ujung di sisi luar).
## Urutan: (1) ke koridor utara z=-27 kalau masih di utara;
## (2) ke barat x=-28; (3) ke selatan sampai plaza (z=2);
## (4) ke depan pintu (-2, 2); (5) depan pintu (pintu + 1,5 m ke
## arah luar/plaza — RONDE 21: (-4.01,-5.39), bukan (-2.75,-6.11) lagi).
## BATASAN (jujur): NPC yang PERSIS di dalam tapak bangunan saat sesi
## mulai (transien keliling bebas yang memang sudah menembus dinding
## di segmen (8,-2)<->(0,-20)) tetap jalan lurus keluar — kasus langka,
## sama seperti keliling bebas yang sudah ada.
func _rute_ke_pintu_surau(dari: Vector3) -> Array[Vector3]:
	var rute: Array[Vector3] = []
	if dari.z < -7.0:
		if dari.z > -27.0:
			rute.append(Vector3(dari.x, 0, -27.0))
		if dari.x > -28.0:
			rute.append(Vector3(-28, 0, -27.0))
		rute.append(Vector3(-28, 0, 2.0))
	rute.append(Vector3(-2, 0, 2.0))
	# RONDE 21: pintu luar kini di (-3.38,-6.75) (Surau geser ke
	# (0,-14), diputar -25°) — titik akhir rute = depan pintu (pintu
	# + 1,5 m ke arah luar/plaza, 205°), bukan (-2.11,-7.47) lagi.
	# Segmen (-2,2) -> depan pintu tidak menabrak dinding selatan
	# yang sudah miring (terverifikasi geometris di atas).
	rute.append(_outdoor_door + _surau_keluar * 1.5)
	return rute


## Rute pulang NPC dari plaza luar ke posisi rumah (disimpan saat sesi
## mulai). Rumah di utara dicapai lewat koridor barat + utara, bukan
## diagonal menembus Surau dari plaza.
## RONDE 21: koridor barat putra -20 -> -28 (cangkruk pindah ke
## (-22,-18); koridor utara -22 -> -27 (Surau geser ke (0,-14)));
## plaza (-2,2) tetap (di barat tembok). Ustadzah
## Mariyah pulang ke area PUTRI BARU dengan rute SENDIRI: dari pintu
## musholla baru (_musholla_exit, dari dict build) keluar ke selatan
## dulu (134,-14) lalu langsung ke rumah — tanpa koridor barat/plaza
## putra (rute putra dari pintu musholla akan menembus musholla +
## tembok).
func _rute_pulang(npc: SantriNPC) -> Array[Vector3]:
	var rumah: Vector3 = _npc_rumah.get(npc, PesantrenBuilder.SPAWN)
	var rute: Array[Vector3] = []
	var dari := npc.global_position
	if npc == _ustadzah:
		# RONDE 21: Area putri BARU (timur tembok x=14) — satu-satunya
		# bangunan di jalur pulang adalah musholla baru (134,-24).
		# Keluar dari utara musholla lewat (134,-14) selatan musholla.
		# RONDE 22 (Sinta): tembok keliling kampus putri (x=115,
		# gerbang barat (115,0)) — kalau Ustadzah dan rumahnya di sisi
		# berlawanan tembok, garis lurus memotong tembok: lewat
		# gerbang dulu. Normalnya keduanya di dalam keliling (rumah
		# (134,-17)); ini pengaman posisi transien di barat tembok.
		if (dari.x < 115.0) != (rumah.x < 115.0):
			if dari.z < -14.0:
				rute.append(Vector3(dari.x, 0, -14.0))
			rute.append(Vector3(115, 0, 0))
			if rumah.z < -14.0:
				rute.append(Vector3(134, 0, -14.0))
			rute.append(rumah)
			return rute
		if dari.z < -14.0:
			rute.append(Vector3(134, 0, -14.0))
		rute.append(rumah)
		return rute
	if dari.z < -7.0:
		# Masih di utara (tidak seharusnya dari pintu keluar, tapi
		# aman): keluar ke koridor utara dulu.
		if dari.z > -27.0:
			rute.append(Vector3(dari.x, 0, -27.0))
		if dari.x > -28.0:
			rute.append(Vector3(-28, 0, -27.0))
		rute.append(Vector3(-28, 0, 2.0))
	elif rumah.z < -7.0:
		# Rumah di utara: lewat koridor barat + utara.
		rute.append(Vector3(-28, 0, 2.0))
		rute.append(Vector3(-28, 0, -27.0))
		if rumah.x > -28.0:
			rute.append(Vector3(rumah.x, 0, -27.0))
		rute.append(rumah)
		return rute
	if rumah.distance_to(Vector3(-2, 0, 2.0)) > 0.5:
		rute.append(Vector3(-2, 0, 2.0))
	rute.append(rumah)
	return rute


## NPC selesai satu rute — lanjutkan mesin fase sholatnya.
func _on_npc_rute_selesai(npc: SantriNPC) -> void:
	match String(_npc_sholat_fase.get(npc, "")):
		"ke_pintu":
			# Sampai di depan pintu luar -> pindah ke interior (ala
			# GTA, sama seperti pemain masuk Surau — bukan menembus
			# dinding). Interior tetap tersembunyi kalau pemain di
			# luar; NPC sudah "di dalam" saat pemain masuk nanti.
			# RONDE 20: Ustadzah masuk ke MUSHOLLA (bukan Surau).
			if npc == _ustadzah:
				npc.global_position = _musholla_spawn
			else:
				npc.global_position = _interior_spawn
			_npc_sholat_fase[npc] = "ke_sajadah"
			var tujuan: Array[Vector3] = [_sajadah_npc.get(npc, _interior_spawn)]
			npc.mulai_rute(tujuan)
		"ke_sajadah":
			_npc_sholat_fase[npc] = "sholat"
			npc.mulai_pose_sholat(KIBLAT_YAW)
		"pulang_dalam":
			# Sampai di pintu dalam -> keluar ke plaza luar.
			# RONDE 20: Ustadzah keluar ke pintu LUAR musholla.
			if npc == _ustadzah:
				npc.global_position = _musholla_exit
			else:
				npc.global_position = _outdoor_exit
			_npc_sholat_fase[npc] = "pulang_luar"
			npc.mulai_rute(_rute_pulang(npc))
		"pulang_luar":
			_npc_sholat_fase[npc] = ""
			npc.selesai_sholat()


## Pemain menekan "IKUT SHOLAT" di banner: antar ke Surau (teleport
## ala GTA, sama seperti masuk lewat pintu) — pemain yang sedang di
## cangkruk pun langsung dipindah, tidak jalan kaki 300 m; ini
## undangan sholat, bukan paksaan (banner bisa diabaikan). Pemain
## yang sedang tidur dibangunkan dulu; panel apa pun ditutup supaya
## langsung melihat saf sholat.
func _on_ikut_sholat() -> void:
	if not _sholat_aktif:
		return
	# RONDE 18: ikut hanya selama "kumpul" — begitu takbir dimulai,
	# banner disembunyikan dan pendaftaran ikut ditutup.
	if _sholat_adegan != "kumpul":
		return
	_ui.hide_sholat_banner()
	if _player.aksi_saat_ini() == "tidur":
		_player.set_aksi("berdiri")
		_cam_pitch = -0.35
		_rig.global_position = _player.global_position + Vector3(0, 1.6, 0)
		_spring.rotation.x = _cam_pitch
	if _ui.is_mission_visible():
		_ui.close_mission()
	if _ui.is_smartboard_visible():
		_ui.close_smartboard()
	if _ui.is_dashboard_visible():
		_ui.close_dashboard()
	if _ui.is_peta_visible():
		_ui.close_peta()
	if _ui.is_chat_visible():
		_ui.close_chat()
	if _ui.is_aksi_visible():
		_ui.close_aksi()
	if _ui.is_outfit_visible():
		_ui.close_outfit()
	# RONDE PERBAIKAN (Raka, integrasi item 7f + 15): pemain PUTRI
	# ikut sholat di Musholla (bukan Surau) — sajadah + flag + interior
	# mengikuti gender; Ustadzah sudah memimpin dari sana (lihat
	# _mulai_sholat: Ustadzah -> _posisi_imam_musholla).
	var putri := _pemain_adalah_putri()
	var sajadah := _posisi_sajadah_musholla("Sajadah_03") if putri else _posisi_sajadah("Sajadah_03")
	_di_dalam_cangkruk = false
	_di_dalam = not putri
	_di_dalam_musholla = putri
	_set_interior_terlihat(not putri, false, putri)
	_set_sandal_ruangan(true)
	_player.set_facing(KIBLAT_YAW)
	_player.global_position = sajadah
	_player.velocity = Vector3.ZERO
	_player.set_aksi("sholat")
	# Kamera di belakang pemain (menghadap kiblat = melihat mihrab).
	_cam_yaw = fmod(KIBLAT_YAW + PI, TAU)
	_cam_pitch = -0.35
	_rig.global_position = sajadah + Vector3(0, 1.6, 0)
	_rig.rotation.y = _cam_yaw
	_spring.rotation.x = _cam_pitch
	_pemain_ikut_sholat = true
	_ui.toast("Kamu ikut sholat " + _sholat_nama + " berjamaah.")


# ---------- smartboard (RONDE 4) ----------
func _on_slide_changed(index: int) -> void:
	# RONDE 10 (Mas: "Tulisan di smartboard dihapus"): papan 3D
	# smartboard di dalam Surau kini BERSIH — fungsi ini TIDAK LAGI
	# menulis judul/ringkas slide ke Label3D SmartboardScreen.
	# Konten slide tetap tampil di popup UI (ui.gd open_smartboard).
	# Fungsi dipertahankan sebagai no-op supaya koneksi signal
	# slide_changed (baris _ready) tidak perlu diubah.
	pass
