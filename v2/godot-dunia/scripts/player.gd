extends CharacterBody3D
class_name SantriPlayer
## Santri yang dikendalikan pemain (third-person).
## Visual: karakter santri low-poly dari primitif yang dirapikan —
## peci/songkok, koko, sarung zamrud, wajah sawo matang, RAMBUT hitam
## (RONDE 6: di bawah songkok, terlihat di tepi).
## Gerak: virtual joystick ATAU keyboard WASD / panah. Arah gerak relatif
## terhadap kamera (dihitung main.gd, diteruskan lewat move_dir).
## Animasi jalan: ayunan lengan + kaki + bob kecil, semua prosedural.
## Aksi/pose (RONDE 6): duduk bersila, berdiri, salaman, menulis,
## bawa kitab (toggle), melambai, tidur — pose prosedural di sini.
## Outfit (RONDE 6): koko/songkok/sarung bisa diganti warna
## (terapkan_outfit) — dipakai panel Ganti Baju di kamar cangkruk.

## SFX LANGKAH (Sinta, 17 Nov 2026 — acuan reel @jipraks: langkah kaki
## sinkron tepat di momennya): dipancarkan tiap kali satu kaki
## menyentuh tanah — yaitu saat sin(_walk_time) melewati nol (kaki
## lewat posisi vertikal, kaki satunya terangkat). main.gd
## menghubungkannya ke AudioPesantren.mainkan_langkah().
signal langkah

## MULTIPLAYER FASE 1 — L1 BEKUKAN PERILAKU (Jaka, 18 Nov 2026).
## Baseline sebelum refactor: test_v2 headless 60 lulus / 0 gagal
## (skrip/log-jaka/test_v2_baseline.log). Perilaku yang dibekukan:
## - INPUT: file ini TIDAK PERNAH memanggil Input.*. Input dibaca
##   main.gd:1159-1166 (joystick via ui + keyboard WASD/panah via
##   Input.get_vector + KEY_A/D/W/S), diubah jadi arah relatif-kamera,
##   lalu ditulis ke var `move_dir` tiap frame (main.gd:1190). Satu-
##   satunya "input" yang dibaca _physics_process adalah `move_dir`.
##   Pose diam menahan gerak: main.gd menolkan input_vec saat
##   sedang_aksi_diam(), dan memanggil set_aksi("berdiri") saat ada
##   input gerak selama tidur/salaman/melambai/sholat.
## - ANIMASI GANTI: (a) sedang_aksi_diam() (duduk/menulis/tidur/
##   salaman/melambai/sholat) -> _terapkan_pose(delta), return lebih
##   awal (animasi jalan/idle dilewati); (b) kalau tidak, v.length() >
##   0.1 -> AnimasiMixamo.terapkan_jalan (fase 9 rad/dtk; signal
##   `langkah` saat sin(_walk_time) melewati nol, blend > 0.3),
##   kalau tidak -> AnimasiMixamo.terapkan_idle; (c) _bawa_kitab
##   (toggle) menimpa lengan kanan; (d) _lerp_pakaian ke
##   PAKAIAN_DEFAULT di luar pose diam. Hadap: _visual.rotation.y
##   di-lerp ke atan2(v.x, v.z) saat bergerak (bukan pose diam).
## - BUILD_VISUAL dipanggil: _ready() sekali (outfit default) dan
##   bangun_ulang_visual() (ganti gender -> abaya/jilbab). TIDAK
##   PERNAH dari _physics_process/_process.
## - NAMA: set_nama() dari login (main.gd:993); _process menampilkan
##   label bila kamera < 28 m, tidak ditahan chat, dan _aksi != tidur.
## Kalau refactor merusak sesuatu, bandingkan dengan perilaku di atas.

# Kecepatan jalan 6,0 m/dtk (dulu 5,0 — penguji ronde 3: gerak terasa
# lambat; peta kini 112 m, menyeberang butuh ~19 dtk, bukan ~22 dtk).
const SPEED := 6.0
const GRAVITY := 20.0
## BUBBLE-ML (Gita, 17 Nov 2026 — koreksi Mas ~21:30 WIB: bubble kotak
## di atas kepala jelek): bubble 3D DIMATIKAN — pesan chat kini tampil
## sebagai teks melayang ala Mobile Legends di feed ui.gd (di atas
## joystick). Konstanta ini tetap dipakai untuk memotong teks feed
## (maks 100 karakter + "…", lihat Palette.rapikan_bubble()).
const BUBBLE_MAKS := 100
## RONDE 9 — target skala/posisi pakaian per pose (lihat _lerp_pakaian):
## duduk/menulis = sarung mengerut jadi lipatan di pangkuan; tidur =
## sarung + torso pipih (bukan kubah); berdiri/salaman/melambai = normal.
## SUSULAN SARUNG TERHAMPAR (Dara, 17 Nov 2026 — koreksi Mas ~20:57 WIB:
## "Kalau duduk bersila itu sarungnya terhampar.."): PAKAIAN_DUDUK lama
## (1.20, 0.45, 1.20 / sarung_y 0.68 / hem_y 0.52) membuat sarung jadi
## kerucut lonceng — rim bawah melayang 4,8 cm di atas lantai (diukur
## headless, foto D1) dan radius bawah cuma 0,348. Yang baru: radius
## bawah 1,70x (0,493 — menutupi lutut bersila + menyebar ke samping),
## sarung_y 0,65 (rim bawah lokal 0,47 -> dunia ~0,01 saat condong
## 0,08), hem_y 0,50 (titik terendah hem menyentuh lantai ~0,01 —
## 0,48 masih menembus 1,4 cm karena titik terendah elipsoid miring
## bukan di kutubnya; diukur headless 17 Nov).
## sarung_scale y TETAP 0,45 (bukan 0,35) supaya tepi atas sarung
## tetap di 0,83 — kitab pangku menulis (tepi bawahnya y 0,78) tetap
## terselip di dalam bukaan sarung, tidak melayang. Motif batik parang
## tidak berubah (kompresi y sama seperti sebelumnya).
## CATATAN TERUKUR: menulis + Kyai condong 0,20 (bukan 0,08) sehingga
## tepi depan sarung lebar PASTI lebih rendah ~5-6 cm di bawah lantai
## (konstanta bersama tidak bisa memuaskan dua condongan sekaligus —
## lihat RONDE-DUDUK-SARUNG-STATUS.md); clip itu di balik rehal/kitab
## dan tertutup lantai, verdict akhir dari foto S3/S4.
## REVISI BERSILA v2 (Kirana, 20 Nov 2026 — bug 2 Mas: "duduk bersila
## juga mekar kayak bunga", foto pose-bersila-*-sebelum): kerucut
## (1.70, 0.45, 1.70) masih terbaca seperti POT/BEL bunga — sisi
## lurus curam, atas sempit (Ø0,68), lutut tersembunyi total di
## dalamnya. Yang baru: GUNDUKAN RENDAH LEBAR — sarung (1.95, 0.32,
## 1.95) / sarung_y 0,66: tinggi dunia cuma 0,26 (dulu 0,36), atas
## Ø0,78 (pangkuan datar, badan muncul dari tengah kain), bawah
## Ø1,13; hem (1.95, 0.20, 1.95) / hem_y 0,49 (titik terendah dunia
## 0,012 — menyentuh lantai, tanpa celah ke rim bawah sarung 0,092:
## hem atas 0,128 menutupinya). Tepi atas dunia 0,368 — kitab menulis
## (bawah y 0,36) tetap terselip. Lutut bersila kini MELEBAR ke
## samping (yaw kaki dibalik, lihat _terapkan_pose "duduk") supaya
## alasnya terbaca seperti orang bersila beneran, bukan kerucut.
## TONJOLAN LUTUT BERSILA (Kirana, 20 Nov 2026 — verdict Mas: "Ketika
## duduk bersila masih mekar sarungnya"): skala dasar dua tonjolan
## lutut (bola pipih r=0.20) — penuh saat bersila (DUDUK), 0 di
## pose lain (lihat _lerp_pakaian).
## REVISI v2 (foto lutut v1: tonjolan TERLALU KECIL — dari depan
## masih kerucut, cuma dua lobus kecil di sudut bawah): tonjolan
## dibesarkan (r 0.17 -> 0.20), didorong ke luar-depan (±0,33,
## 0,55, 0,30) supaya tepi luarnya 10 cm LEBIH LEBAR dari rim
## gundukan (0,566), dan sumbu panjangnya diputar mengikuti arah
## paha (yaw ±0.50) — bukan bola menempel, melainkan kain yang
## menutupi paha + lutut yang mengarah ke depan-samping.
## DRAPE BERSILA v3 (Kirana, 20 Nov 2026 — koreksi Mas 06:05 WIB "Yg
## jelas duduk bersila" atas tonjolan lutut v2): gundukan + dua benjol
## TETAP terbaca aneh — siluet kerucut mulus, lutut cuma lobus di
## sudut bawah. Yang baru: DRAPE ArrayMesh (loft) yang mengikuti
## paha menyilang — pinggang sempit (r 0,22), tonjolan di ARAH LUTUT
## (±48° dari depan, r 0,39 di tinggi lutut), cekungan di tengah
## depan (r 0,27), bawah menutup di atas kaki bersila. Sarung
## silinder lama jadi INTI kecil tersembunyi di dalam drape
## ((0.85,0.30,0.85) / sarung_y 0,70 — muat di dalam drape di semua
## tinggi), hem + trim dikecilkan sampai tak terlihat. Tonjolan
## lutut v2 DIPENSIUNKAN (LUTUT_SKALA tetap ada sebagai konstanta
## warisan, tapi semua PAKAIAN_* kini lutut_scale = 0 — drape yang
## membentuk lututnya). Kunci baru di SEMUA dict: "drape_scale"
## (penuh saat bersila, 0 di pose lain), "sarung_rot_x"/"sarung_z"/
## "hem_z"/"trim_scale" (untuk duduk kursi, lihat bawah).
## DUDUK KURSI v2 (Kirana, 20 Nov 2026 — verdict Mas 06:04 + 06:06
## WIB "Duduk di tamannya kok aneh" / "Yg sarung aneh" / "sama yg
## duduk kursi juga aneh"): tabung sarung VERTIKAL (1.10,0.42,1.10)
## menggantung seperti tirai di depan bangku — ujung bawah garis
## lurus, betis menjuntai terpisah. Yang baru: tabung DIROTASI
## mengikuti paha (sarung_rot_x 1,69 — sumbu tabung sejajar paha
## horizontal, ujung sempit di lutut + ujung lebar di pinggang),
## dipipihkan vertikal ((1.15,0.55,0.55) — tebal 0,32, bukan
## 0,64) + digeser ke depan (sarung_z 0,13, pusat di atas paha).
## Betis keluar dari BAWAH ujung tabung, seperti sarung asli.
## Hem + trim dikecilkan (tersembunyi di dalam tabung).
const LUTUT_SKALA := Vector3(1.0, 0.65, 1.25) # LEGACY v2 — digantikan drape (semua dict kini 0).
const PAKAIAN_DEFAULT := {"sarung_scale": Vector3.ONE, "sarung_y": 0.50, "sarung_z": 0.0, "sarung_rot_x": 0.0, "hem_scale": Vector3(1.0, 0.25, 1.0), "hem_y": 0.12, "hem_z": 0.0, "trim_y": 0.14, "trim_scale": Vector3.ONE, "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ZERO}
const PAKAIAN_DUDUK := {"sarung_scale": Vector3(0.80, 0.28, 0.80), "sarung_y": 0.70, "sarung_z": 0.0, "sarung_rot_x": 0.0, "hem_scale": Vector3(0.30, 0.20, 0.30), "hem_y": 0.75, "hem_z": 0.0, "trim_y": 0.34, "trim_scale": Vector3(0.05, 0.05, 0.05), "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ONE}
const PAKAIAN_TIDUR := {"sarung_scale": Vector3(1.15, 1.0, 0.55), "sarung_y": 0.50, "sarung_z": 0.0, "sarung_rot_x": 0.0, "hem_scale": Vector3(1.15, 0.25, 0.5), "hem_y": 0.12, "hem_z": 0.0, "trim_y": 0.14, "trim_scale": Vector3.ONE, "torso_scale": Vector3(1.0, 1.0, 0.6), "peci_z": 0.7, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ZERO}
## DUDUK KURSI (Kirana, 20 Nov 2026 — bug 3 Mas): sarung DIPENDEKKAN
## supaya menutupi paha horizontal + lutut, betis polos menggantung
## di bawah hem: sarung (1.10, 0.42, 1.10) / sarung_y 0,72 — tepi
## atas dunia 0,718 (menutupi bawah torso 0,56), rim bawah dunia
## 0,382 (tepat di bawah lutut 0,414); hem (1.10, 0.25, 1.10) /
## hem_y 0,56 menutup rim. Paha (warna sarung) menjorok ~4 cm ke
## depan tabung — terbaca sebagai kain yang meregang di atas paha.
const PAKAIAN_KURSI := {"sarung_scale": Vector3(1.15, 0.55, 0.55), "sarung_y": 0.60, "sarung_z": 0.13, "sarung_rot_x": 1.69, "hem_scale": Vector3(0.30, 0.25, 0.30), "hem_y": 0.60, "hem_z": 0.15, "trim_y": 0.56, "trim_scale": Vector3(0.05, 0.05, 0.05), "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ZERO}
const PAKAIAN_ABAYA_KURSI := {"sarung_scale": Vector3(1.05, 0.35, 0.55), "sarung_y": 0.60, "sarung_z": 0.13, "sarung_rot_x": 1.69, "hem_scale": Vector3(0.30, 0.25, 0.30), "hem_y": 0.60, "hem_z": 0.15, "trim_y": 0.50, "trim_scale": Vector3(0.05, 0.05, 0.05), "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ZERO}
# SUSULAN RONDE 20 (Mas 19:42 WIB: kostum Ustadzah "malah kek ustadz"
# — koko + sarung batik + penutup kepala seperti songkok): ABAYA +
# JILBAB. Abaya = SATU gamis panjang longgar (bahu -> mata kaki),
# menggantikan koko + sarung sekaligus. Target duduknya SENDIRI:
# PAKAIAN_DUDUK (sarung mengerut y 0.45) akan menghancurkan gamis
# 1,32 m sampai lutut dan membuka kaki bersila — abaya duduk justru
# MELEBAR (1.55) + sedikit memendek (0.78), tetap menutupi kaki
# bersila sampai lantai (hem dunia ~0.04 saat visual turun -0.42).
# REVISI BERSILA v2 (Kirana, 20 Nov 2026 — bug 2, sama seperti sarung):
# gamis duduk ikut diratakan + dilebarkan: (1.85, 0.55, 1.85) /
# sarung_y 0,82 — gundukan dunia 0,037..0,763, bawah Ø1,07; hem
# (1.85, 0.20, 1.85) / hem_y 0,50 (titik terendah dunia 0,022).
const PAKAIAN_ABAYA_DEFAULT := {"sarung_scale": Vector3.ONE, "sarung_y": 0.76, "sarung_z": 0.0, "sarung_rot_x": 0.0, "hem_scale": Vector3(1.0, 0.25, 1.0), "hem_y": 0.12, "hem_z": 0.0, "trim_y": 0.14, "trim_scale": Vector3.ONE, "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ZERO}
const PAKAIAN_ABAYA_DUDUK := {"sarung_scale": Vector3(0.75, 0.50, 0.75), "sarung_y": 0.82, "sarung_z": 0.0, "sarung_rot_x": 0.0, "hem_scale": Vector3(0.30, 0.20, 0.30), "hem_y": 0.75, "hem_z": 0.0, "trim_y": 0.34, "trim_scale": Vector3(0.05, 0.05, 0.05), "torso_scale": Vector3.ONE, "peci_z": 1.0, "lutut_scale": Vector3.ZERO, "drape_scale": Vector3.ONE}

## Arah gerak di ruang pesantren (sudah relatif kamera), panjang 0..1.
var move_dir: Vector3 = Vector3.ZERO

## MULTIPLAYER FASE 1 — L4: properti yang direplikasi (prep §1.2).
## PEMILIK mengisi ketiganya tiap frame dari keadaan lokal (lihat
## _isi_properti_sync + _perbarui_pose_id). BUKAN pemilik: JANGAN isi
## dari logika lokal — nilainya datang dari MultiplayerSynchronizer.
## `sync_position`/`sync_yaw` ALWAYS 10 Hz; `pose_id`/`outfit` ON_CHANGE.
var sync_position: Vector3 = Vector3.ZERO
var sync_yaw: float = 0.0
var pose_id: int = PoseIds.POSE_IDLE
## Cerminan `_outfit` untuk synchronizer (ON_CHANGE). Pemilik mengisinya
## tiap kali outfit berubah (terapkan_outfit / bangun_ulang_visual /
## _ready); avatar remote MENERIMA nilainya dari synchronizer dan
## menerapkannya di _process (lihat _terapkan_outfit_sync, L4).
var outfit: Dictionary = {}
## MultiplayerSynchronizer anak avatar; null saat offline — tanpa peer,
## tanpa synchronizer aktif, game jalan persis seperti sebelumnya.
var _sync: MultiplayerSynchronizer = null

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
# lagi — tidak ada kode yang menyalakannya. Lihat show_chat().
var _name_label: Label3D
var _walk_time: float = 0.0
# ANIMASI-MIXAMO: dict rig primitif untuk AnimasiMixamo (dibangun di
# _pasang_visual dari hasil build_visual) + jam idle (detik, maju
# terus supaya bersiwak idle deterministis dan bisa dites).
var _rig: Dictionary = {}
var _idle_t: float = 0.0
## Tanda sin(_walk_time) frame sebelumnya — deteksi persilangan nol
## untuk pemicu signal langkah (lihat di atas).
var _langkah_sin_sebelum: float = 0.0
# Perbaikan 15 Nov ~12:00 WIB: ayunan jalan dihaluskan — amplitudo naik/
# turun bertahap (blend) saat mulai/berhenti, bukan langsung penuh lalu
# berhenti mendadak; badan sedikit condong ke depan saat berjalan.
var _anim_blend: float = 0.0
# RONDE 6 — pose/aksi karakter.
var _aksi: String = "berdiri"
var _aksi_timer: float = 0.0
var _bawa_kitab: bool = false
## DUDUK KURSI (Kirana, 20 Nov 2026 — bug 3+4 Mas): kursi yang sedang
## diduduki pemain (entry scripts/kursi_pemain.gd) + tinggi duduknya
## di atas lantai node (0,45 kursi biasa, 0,51 kasur). Kosong = pemain
## tidak duduk di kursi terdaftar. Dipakai _terapkan_pose
## ("duduk_kursi" + "duduk" via API), pembeku fisika, dan bangun.
var _kursi_duduk: Dictionary = {}
var _kursi_tinggi_duduk: float = 0.45
var _menulis_t: float = 0.0
var _sandal_l: MeshInstance3D
var _sandal_r: MeshInstance3D
var _kitab_tangan: Node3D
var _kitab_pangku: Node3D
var _outfit: Dictionary = {}
# RONDE 9 — referensi bagian pakaian untuk pose (sarung mengerut saat
# duduk, sarung + torso pipih saat tidur).
var _sarung: MeshInstance3D
var _sarung_hem: MeshInstance3D
var _sarung_trim: MeshInstance3D
var _lutut_l: MeshInstance3D
var _lutut_r: MeshInstance3D
var _drape: MeshInstance3D
var _torso: MeshInstance3D
var _peci: MeshInstance3D
## Nama pemain (label di atas kepala) — disimpan supaya
## bangun_ulang_visual() membangun ulang dengan nama yang sama.
var _nama: String = "Santri"


## MULTIPLAYER FASE 1 — L4: synchronizer dipasang di _enter_tree (BUKAN
## _ready) — lihat _pasang_synchronizer() di bawah kenapa.
func _enter_tree() -> void:
	_pasang_synchronizer() # MULTIPLAYER FASE 1 — L4 (di bawah).


func _ready() -> void:
	_atur_otoritas() # MULTIPLAYER FASE 1 — L3 (di bawah).
	_pasang_visual(SantriPlayer.build_visual(_nama, MissionData.OUTFIT_DEFAULT))
	_outfit = MissionData.OUTFIT_DEFAULT.duplicate()
	outfit = _outfit.duplicate() # MULTIPLAYER FASE 1 — L4.


## MULTIPLAYER FASE 1 — L3: gerbang otoritas (pola skill godot-multiplayer
## Pattern 3). Nama node = peer id pemilik (spawn multiplayer, prep §1.4)
## -> otoritas = peer itu. Spawn offline seperti sekarang (nama
## "SantriPlayer", bukan angka) -> otoritas = peer lokal, jadi game
## offline jalan persis seperti sebelumnya. Dipanggil PALING AWAL di
## _ready(), sebelum visual dipasang.
func _atur_otoritas() -> void:
	if name.is_valid_int() and name.to_int() > 0:
		set_multiplayer_authority(name.to_int())
	else:
		set_multiplayer_authority(multiplayer.get_unique_id())


## MULTIPLAYER FASE 1 — L4: pasang MultiplayerSynchronizer sebagai anak
## avatar, konfigurasi dari kode (skill godot-multiplayer Pattern 4).
## Offline (multiplayer_peer = OfflineMultiplayerPeer): TIDAK dipasang —
## tidak ada peer, tidak ada yang direplikasi, game jalan seperti dulu.
## PERBAIKAN BUG (Jaka, 18 Nov 2026 — smoke test Wira, client1.log:57,
## :59): cek offline SAJA tidak cukup. Begitu ada peer multiplayer,
## pemain LOKAL offline (main.gd:541-556, SantriPlayer.new() + add_child
## tanpa ganti nama — nama auto "@CharacterBody3D@…") ikut dipasangi
## synchronizer, padahal nama itu TIDAK PERNAH direplikasi ke peer lain:
## di klien muncul ERROR `Node not found:
## "Main/@CharacterBody3D@5092/MultiplayerSynchronizer"` + `Parameter
## "node" is null`, dan di game asli pemain lokal server ikut tersinkron
## diam-diam ke pemain lokal klien (cross-talk). Maka synchronizer
## HANYA dipasang bila nama node NUMERIK (= peer id, avatar hasil spawn
## multiplayer — NetworkManager.spawn_player menamai `str(peer_id)`
## SEBELUM masuk tree, jadi _enter_tree() sudah melihat nama angka;
## predikat sama seperti _atur_otoritas L3). Pemain lokal offline (nama
## auto "@…") TIDAK PERNAH dapat synchronizer, peer ada atau tidak.
## HARUS di _enter_tree, BUKAN _ready (Jaka, 18 Nov 2026 — smoke wss
## run terbaru: 4× ERROR `The MultiplayerSynchronizer at path
## "/root/Main/Players/<peer>/MultiplayerSynchronizer" is unable to
## process the pending spawn since it has no network ID. This might
## happen when changing the multiplayer authority during the "_ready"
## callback. Make sure to only change the authority of multiplayer
## synchronizers during the "_enter_tree" callback of their multiplayer
## spawner.`): set_multiplayer_authority() di _ready() terjadi sesudah
## synchronizer diberi network ID, jadi spawn pending gagal diproses.
## Di _enter_tree, nama node SUDAH `str(peer_id)`. Tapi "di _enter_tree"
## SAJA tidak cukup (koreksi Dimas, 18 Nov 2026): add_child(sync)
## memasukkan synchronizer ke tree dan replication system langsung
## mulai memproses spawn-nya — jadi authority HARUS sudah benar
## SEBELUM add_child, bukan sesudahnya. _enter_tree() hanya memanggil
## ini sekali dan _ready() TIDAK lagi memanggilnya, jadi synchronizer
## tidak pernah terpasang dua kali.
## Konfigurasi dari helper Bara `MpSync.buat_config()` (SATU sumber
## kebenaran, dipakai bersama player.gd + remote_player.gd — Jaka
## 18 Nov 2026: konfigurasi inline §1.3 DIGANTI helper ini begitu
## scripts/multiplayer/mp_sync.gd ada, sesuai brief; isinya identik:
## sync_position/sync_yaw ALWAYS, pose_id/outfit ON_CHANGE).
func _pasang_synchronizer() -> void:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		return
	if not (name.is_valid_int() and name.to_int() > 0):
		return
	var sync := MultiplayerSynchronizer.new()
	sync.name = "MultiplayerSynchronizer"
	sync.replication_config = MpSync.buat_config()
	sync.replication_interval = MpSync.REPLICATION_INTERVAL # 10 Hz.
	# PERBAIKAN OTORITAS (Jaka, 18 Nov 2026 — smoke wss run 5: pengamat
	# gagal, peer beku di spawn): MultiplayerSynchronizer TIDAK mewarisi
	# otoritas parent-nya — tanpa baris ini authority-nya tetap 1
	# (server) dan pemilik TIDAK PERNAH mengirim delta. Eksplisit:
	# samakan dengan otoritas parent. Authority HARUS diset SEBELUM
	# add_child (koreksi Dimas, 18 Nov 2026): add_child memasukkan
	# synchronizer ke tree dan replication system langsung mulai
	# memproses spawn-nya, jadi mengubah authority SESUDAH add_child —
	# meski masih di _enter_tree — tetap terlambat dan tetap memicu
	# engine ERROR "unable to process the pending spawn since it has
	# no network ID" (lihat komentar di atas). set_multiplayer_authority
	# bekerja pada node yang belum masuk tree (nilainya tersimpan dan
	# berlaku saat masuk tree).
	sync.set_multiplayer_authority(name.to_int())
	add_child(sync)
	_sync = sync


## MULTIPLAYER FASE 1 — L4: pemilik mengisi properti sync dari keadaan
## lokal. HANYA dipanggil dari _physics_process SETELAH gerbang otoritas
## (L3), jadi avatar remote tidak pernah sampai sini — nilainya di
## remote datang dari synchronizer, bukan dari logika lokal.
func _isi_properti_sync() -> void:
	sync_position = position
	sync_yaw = _visual.rotation.y


## MULTIPLAYER FASE 1 — L4: avatar remote menerapkan outfit yang
## diterima dari synchronizer. Hanya dipanggil dari _process bila BUKAN
## otoritas dan `outfit` (sync) berbeda dari `_outfit` lokal. Kalau
## flag muslimah/tunik berubah, visual harus DIBANGUN ULANG (abaya/
## sarung adalah node berbeda, bukan sekadar warna — lihat
## bangun_ulang_visual); kalau tidak, cukup warnai ulang di tempat.
func _terapkan_outfit_sync() -> void:
	if outfit.is_empty() or outfit == _outfit:
		return
	if bool(outfit.get("muslimah", false)) != bool(_outfit.get("muslimah", false)) or bool(outfit.get("tunik", false)) != bool(_outfit.get("tunik", false)):
		bangun_ulang_visual(outfit)
	else:
		terapkan_outfit(outfit)


## Pasang visual yang sudah dibangun (tetapkan semua referensi node
## + tambahkan ke scene). Dipakai _ready() dan bangun_ulang_visual().
func _pasang_visual(built: Dictionary) -> void:
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
	_sandal_l = built["sandal_l"]
	_sandal_r = built["sandal_r"]
	_kitab_tangan = built["kitab_tangan"]
	_kitab_pangku = built["kitab_pangku"]
	_sarung = built["sarung"]
	_sarung_hem = built["sarung_hem"]
	_sarung_trim = built["sarung_trim"]
	_lutut_l = built["lutut_l"]
	_lutut_r = built["lutut_r"]
	_drape = built["drape"]
	_torso = built["torso"]
	_peci = built["peci"]
	# ANIMASI-MIXAMO: rig untuk modul animasi (dibangun ulang tiap
	# kali visual dibangun ulang — lihat bangun_ulang_visual).
	_rig = AnimasiMixamo.rig_dari_built(built)
	add_child(_visual)


## Bangun ulang visual dengan outfit baru (KIRANA 17 Nov 2026 —
## Mas: santriwati tampil abaya + jilbab): dipakai saat gender
## pemain berubah (login sebagai santriwati) karena Abaya/Hijab
## adalah node yang BERBEDA (bukan sekadar warna) — terapkan_outfit
## saja tidak bisa mengubah koko + songkok jadi abaya + jilbab.
## Nama pemain dipertahankan; visual lama dibuang setelah yang baru
## terpasang supaya tidak ada frame tanpa karakter.
func bangun_ulang_visual(outfit: Dictionary) -> void:
	var lama: Node3D = _visual
	_pasang_visual(SantriPlayer.build_visual(_nama, outfit))
	_outfit = outfit.duplicate()
	self.outfit = _outfit.duplicate() # MULTIPLAYER FASE 1 — L4: cermin sync (parameter `outfit` menutupi member, pakai `self.`).
	if lama != null:
		remove_child(lama)
		lama.queue_free()


## Apakah visual saat ini muslimah (abaya + jilbab)?
func apakah_muslimah() -> bool:
	return bool(_outfit.get("muslimah", false))


## SERAGAM UTAMA v2: apakah visual saat ini tunik (santriwati
## baju+sarung, bukan abaya)?
func apakah_tunik() -> bool:
	return bool(_outfit.get("tunik", false))


## Membangun visual santri dari primitif. Dipakai pemain dan NPC.
## Desain (15 Nov ~12:00 WIB, meniru hero CCS — peci putih, koko putih
## kancing emas, sarung zamrud kotak putih, sandal coklat; lihat
## game-nahwu/.../assets/hero/make_hero_santri.py): kepala + peci lebih
## tegas, mata + senyum sederhana, koko bertaper + kerah + kancing emas
## di atas lis, sarung kotak putih depan-belakang, sandal coklat yang
## ikut mengayun bersama kaki, tangan di ujung lengan.
## REVISI 15 Nov ~14:26 WIB (Mas: "karakter ga terlalu balok kek ini",
## CCS lebih halus): SEMUA bagian kotak diganti bulat — kaki/lengan
## kapsul, mata/hidung bola, senyum lengkung dari 5 bola kecil, pola
## sarung cakram bundar, lis dada strip bulat, sandal oval. TIDAK ADA
## lagi BoxMesh di karakter. Pivot ayunan jalan dipertahankan (kaki
## y=0.62, lengan y=1.34); kapsul collision pemain tidak berubah.
## REVISI KARAKTER 15 Nov ~18:45 WIB (Mas: "karakter/avatarnya lebih
## bagus yg game nahwu... yg pesantren universe ini kek aneh.. balok
## banget" — build live masih ronde 3, tapi kapsul saja belum cukup):
## lengan 0.045->0.065 + tangan 0.05->0.07 (dulu seperti lidi),
## kaki 0.06->0.07, sarung taper diperjelas 0.19/0.27 + hem membulat,
## kepala 0.19->0.21 di y=1.62 (hero CCS chibi: kepala+peci ~37%
## tinggi badan; banding make_hero_santri.py 16x16: peci 3 + kepala 3
## dari 16 baris). Wajah/peci dihitung ulang di permukaan bola baru.
## REVISI 15 Nov ~18:46 WIB (Mas, setelah lihat gambar avatar):
## (1) senyum 5 bola = benjolan — diganti busur torus tipis yang
## menyambung (bagian atas cincin tersembunyi di dalam kepala);
## (2) motif sarung cakram = polkadot — diganti tekstur checker
## prosedural (ImageTexture 8x3, kotak zamrud/putih ala hero CCS).
## REVISI ROBLOX 15 Nov ~18:49 WIB (Mas kirim referensi-avatar-
## roblox.jpg — "Ini keren ya"): target gaya chunky — kepala BESAR
## bulat (0.21->0.24, lebih lebar dari torso), badan pendek-tebal
## (torso 0.21->0.23), lengan/kaki TEBAL membulat (lengan 0.065->
## 0.08, tangan 0.07->0.09, kaki 0.07->0.085, sandal 0.095->0.11),
## semua sudut halus, shading LEMBUT mengkilap (roughness 0.9->
## 0.45 via _lembutkan), wajah simpel (mata 2 titik, mulut GARIS
## LURUS kecil — torus diganti kapsul tipis dibaringkan). Yang
## TIDAK ditiru: hoodie/sneakers/headphone/visor/logo "B" —
## identitas tetap SANTRI (peci, koko putih, sarung kotak zamrud,
## sandal). Model Blender (Bima, 18:53 WIB) jalan paralel — swap
## model nanti, bukan di ronde ini.
## REVISI RONDE 6 (15 Nov ~22:04 WIB, Mas: "Karakter game udah bagus...
## tinggal tangannya aja yg masih keliatan balok ga nyambung dg badan"):
## lengan DUA SEGMEN (lengan atas + lengan bawah + siku) dengan SENDI
## BAHU (bola koko) yang menjembatani torso dan lengan — tidak ada
## lagi kapsul lurus yang ditempel dengan celah. Lengan atas lebih
## tebal di pangkal (r=0.085) mengecil ke pergelangan (r=0.07), siku
## sedikit menekuk natural (-0.18 rad), tangan menyatu di ujung lengan
## bawah. Lengan baju koko (putih) menutupi sampai pergelangan.
## REVISI RONDE 6 (15 Nov ~22:04 WIB, Mas: "Pakai karakter di game
## aja.. tapi kasih rambut"): RAMBUT hitam di bawah songkok — bola
## hitam yang menutupi atas/belakang kepala, tepinya terlihat di bawah
## songkok + di sisi wajah (songkok menutupi puncaknya).
## REVISI RONDE 6 (Mas: sarung sampai mata kaki): sarung DIPERPANJANG
## (tinggi 0.55 -> 0.80, bawah di y=0.10) — hanya kaki + sandal yang
## terlihat di bawah hem.
## Mengembalikan dict berisi root visual + pivot anggota gerak + label.
# Motif BATIK PARANG sarung (prosedural, ImageTexture 256x128).
# Mas 22:55 WIB: ganti motif kotak-kotak (checker) menjadi BATIK —
# pola parang (pita diagonal mengalir) + isen-isen (garis tepi tipis)
# + mlinion (titik-titik emas). Dibuat prosedural seperti checker
# sebelumnya, bukan gambar impor. Keempat warna sarung (Zamrud/Biru/
# Coklat/Hitam) tetap — masing-masing dirender batik dalam warnanya.
# Pita 16 px: 256 px melingkari sarung (~1,54 m) = pita ~9,6 cm.
# Pola periodik 32 px di kedua sumbu (256/32=8, 128/32=4) supaya
# menyambung mulus saat melingkari tabung (tanpa jahitan terlihat).
# Cache per warna supaya pemain + semua NPC berbagi satu material.
static var _motif_sarung_cache: Dictionary = {}


static func _motif_sarung(warna: Color) -> StandardMaterial3D:
	var key := "batik:" + warna.to_html()
	if _motif_sarung_cache.has(key):
		return _motif_sarung_cache[key]
	var img := Image.create(256, 128, false, Image.FORMAT_RGBA8)
	var krem := Color("#f8f6ee")
	var emas := Color("#d4a017")
	# Pencerahan ADAPTIF (Kirana, 19 Nov 2026 — sarung Kyai terbaca
	# ZEBRA): pita terang selalu dicerahkan 0,55 ke krem membuat
	# sarung gelap (#23282e Kyai, #2b2b2b Satpam) jadi garis abu-abu
	# terang di atas dasar nyaris hitam. Di bawah luminansi 0,25
	# faktor mengecil mulus ke 0,22 (motif samar gelap-di-atas-gelap
	# seperti batik hitam sungguhan); di atasnya tetap 0,55 supaya
	# sarung zamrud/biru/coklat santri tidak berubah.
	# CATATAN: Color.get_luminance() Godot 4.7 memakai nilai sRGB
	# TANPA linearisasi (terukur: #23282e -> 0,154; #2b2b2b -> 0,169;
	# #5a3a22 -> 0,247; #008062 -> 0,387) — ambang di bawah ini
	# disesuaikan dengan angka terukur itu, bukan luminansi relatif.
	var lum := warna.get_luminance()
	var t := clampf((lum - 0.15) / 0.10, 0.0, 1.0)
	var faktor_terang := lerpf(0.22, 0.55, t * t * (3.0 - 2.0 * t))
	var terang := warna.lerp(krem, faktor_terang)
	var gelap := warna.darkened(0.3)
	var periode := 32.0
	for y in range(128):
		for x in range(256):
			# Pita diagonal parang (x+y) dengan tepi bergelombang
			# (sinus) supaya mengalir seperti parang sungguhan.
			var d := fmod(float(x + y) + 6.0 * sin((float(x) - float(y)) * 0.08), periode)
			if d < 0.0:
				d += periode
			var fase := d / periode
			var c: Color = warna if fase < 0.5 else terang
			# Garis tepi tipis di batas pita (isen-isen parang).
			var jarak_tepi := minf(absf(fase - 0.5), minf(fase, 1.0 - fase))
			if jarak_tepi < 0.045:
				c = gelap
			# Titik-titik kecil (mlinion) di tengah pita terang.
			if fase >= 0.5:
				var gx := fmod(float(x), 16.0)
				var gy := fmod(float(y) + (8.0 if int(x / 16) % 2 == 1 else 0.0), 16.0)
				var dx := gx - 8.0
				var dy := gy - 8.0
				if dx * dx + dy * dy < 6.0:
					c = emas
			img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	# REVISI Roblox 15 Nov ~18:49 WIB: shading lembut (roughness
	# 0.45, bukan 0.9 karton) — ada kilap halus seperti render sculpt.
	m.roughness = 0.45
	_motif_sarung_cache[key] = m
	return m


# SERAGAM UTAMA v2 (Kirana, 19 Nov 2026 — ACC Mas 15:41): motif sarung
# dipilih kunci outfit "sarung_motif": "parang" (default, perilaku
# lama — Kyai/Satpam/sarung lain), "garis" (seragam putra: garis
# kuning emas vertikal tipis di atas warna dasar), "batik" (seragam
# putri: tekstur batik coklat PNG impor, warna dasar dibakar di file).
static func _bahan_sarung(outfit: Dictionary) -> StandardMaterial3D:
	var warna := Color(String(outfit.get("sarung", "#0b6b4f")))
	match String(outfit.get("sarung_motif", "parang")):
		"garis":
			return _motif_garis_kuning(warna)
		"batik":
			return _motif_batik_putri()
		_:
			return _motif_sarung(warna)


# SERAGAM UTAMA v2 — motif garis kuning (putra): garis VERTIKAL emas
# #C9A227 lebar 2 px tiap 32 px (periodik 32 px -> menyambung mulus
# melingkari tabung 256 px = 8 garis) di atas warna dasar sarung.
# Tipis sampai hampir tidak ketara dari jauh (bukti: mockup detail
# panel C di KONSEP-SERAGAM-UTAMA-v1.md). Cache per warna.
static var _motif_garis_cache: Dictionary = {}


static func _motif_garis_kuning(warna: Color) -> StandardMaterial3D:
	var key := "garis:" + warna.to_html()
	if _motif_garis_cache.has(key):
		return _motif_garis_cache[key]
	var img := Image.create(256, 128, false, Image.FORMAT_RGBA8)
	var emas := Color("#c9a227")
	for y in range(128):
		for x in range(256):
			var d := fmod(float(x), 32.0)
			img.set_pixel(x, y, emas if d < 2.0 else warna)
	var tex := ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.45
	_motif_garis_cache[key] = m
	return m


# SERAGAM UTAMA v2 — motif batik putri (coklat sogan): tekstur PNG
# impor (models/batik_putri_coklat.png, 512x256, 1.066 byte, palet
# 5 warna, periodik 64 px). Satu material untuk semua santriwati.
# Gagal muat -> jatuh ke parang coklat supaya sarung tetap batik.
static var _motif_batik_cache: StandardMaterial3D = null


static func _motif_batik_putri() -> StandardMaterial3D:
	if _motif_batik_cache != null:
		return _motif_batik_cache
	var tex := load("res://models/batik_putri_coklat.png") as Texture2D
	if tex == null:
		_motif_batik_cache = _motif_sarung(Color("#4a2c17"))
		return _motif_batik_cache
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.45
	_motif_batik_cache = m
	return m


# SERAGAM UTAMA v2 — hem sarung mengikuti motif: batik memakai dasar
# coklat tekstur (#4A2C17), bukan warna kunci "sarung" (tekstur PNG
# tidak memakai kunci itu; hem warna lain akan belang dengan badan).
static func _hem_sarung_warna(outfit: Dictionary) -> Color:
	if String(outfit.get("sarung_motif", "parang")) == "batik":
		return Color("#4a2c17")
	return Color(String(outfit.get("sarung", "#0b6b4f")))


# BAHAN KAIN (Kirana, 17 Nov 2026 — ronde karakter primitif):
# koko/abaya/jilbab memakai tekstur kain cotton jersey Poly Haven
# (CC0, models/cotton_jersey_diff_1k.jpg) supaya tidak lagi plastik
# polos. Tekstur diwarnai (albedo_color = warna baju) dan roughness
# 0.85 (matte kain, bukan kilap 0.45). Cache per warna seperti motif
# sarung. Kalau tekstur gagal dimuat, jatuh ke Palette.mat polos.
static var _bahan_kain_cache: Dictionary = {}
static var _kain_tex: Texture2D = null


static func _bahan_kain(warna: Color) -> StandardMaterial3D:
	var key := "kain:" + warna.to_html()
	if _bahan_kain_cache.has(key):
		return _bahan_kain_cache[key]
	if _kain_tex == null:
		_kain_tex = load("res://models/cotton_jersey_diff_1k.ktx2") as Texture2D
	if _kain_tex == null:
		var polos := Palette.mat(warna, 0.0, 0.85)
		_bahan_kain_cache[key] = polos
		return polos
	var m := StandardMaterial3D.new()
	m.albedo_color = warna
	m.albedo_texture = _kain_tex
	m.roughness = 0.85
	m.uv1_scale = Vector3(3.0, 3.0, 3.0)
	_bahan_kain_cache[key] = m
	return m

# ---------- jilbab rebuild: mesh prosedural satu kain ----------
# JILBAB REBUILD (Kirana, 18 Nov 2026 — reset total setelah verdict Mas
# 12:10 WIB "Jelek.. coba bikin dari awal lagi"): tambal-sulam primitif
# 8 ronde TIDAK PERNAH sampai — kubah + panel + drape selalu terbaca
# potongan yang disambung. Kerudung kini SATU ArrayMesh yang digenerate
# dari kode: kubah + rok kain melebar ke dada, satu permukaan utuh,
# bukaan wajah oval dibentuk oleh mesh-nya sendiri.
#   Bagian A (hood): baris y horizontal 1.975..1.44; pita wajah
#   y 1.515..1.775 dipotong elips (tepi oval lembut, pipi tertutup).
#   Bagian B (rok): baris t, y 1.44 -> tepi bawah U (depan 0.88,
#   sisi 1.06, belakang 1.00), lingkaran penuh, melebar menutupi abaya.
#   Lipatan lembut: modulasi radius +-3% (6 lipatan) di bawah dagu.
# Geometri terukur dari tubuh: kepala bola r=0.24 di (0,1.66,0), mata
# (±0.085,1.69,0.222), alis 1.735, mulut 1.55, dagu ~1.47; abaya
# tabung r 0.23 (y 1.42) -> 0.36 (y 0.10). Grid Python pembuktian:
# skrip/grid_jilbab_rebuild.py (jarak min ke kepala 0.2481, margin
# min ke abaya 0.0120, 0 simpul di depan tengah wajah, pipi 7/7).
static var _bahan_jilbab_cache: Dictionary = {}


# Bahan jilbab rebuild: kain yang sama seperti _bahan_kain, tapi
# DOUBLE-SIDED — mesh satu permukaan, sisi dalamnya terlihat lewat
# bukaan wajah + dari bawah hem; tanpa ini sisi dalam tembus pandang.
static func _bahan_jilbab(warna: Color) -> StandardMaterial3D:
	var key := "jilbab:" + warna.to_html()
	if _bahan_jilbab_cache.has(key):
		return _bahan_jilbab_cache[key]
	# REBUILD v2 (Kirana, 18 Nov 2026): PLAIN, tanpa tekstur jersey.
	# Tekstur jersey (rata-rata tan #C2AB9D) dikali albedo krem =
	# COKELAT — foto rebuild v1: kubah (173,141,116), bukan krem
	# (ronde 8: (255,255,219)). Gambar konsep + foto yang di-ACC
	# Mas = krem polos. Double-sided: mesh satu permukaan, sisi
	# dalamnya terlihat lewat bukaan wajah + dari bawah hem.
	var m := Palette.mat(warna, 0.0, 0.45)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_bahan_jilbab_cache[key] = m
	return m


static func _jilbab_interp(kunci: Array, y: float, col: int) -> float:
	if y <= float(kunci[0][0]):
		return float(kunci[0][col])
	if y >= float(kunci[kunci.size() - 1][0]):
		return float(kunci[kunci.size() - 1][col])
	for i in range(kunci.size() - 1):
		var y0 := float(kunci[i][0])
		var y1 := float(kunci[i + 1][0])
		if y0 <= y and y <= y1:
			var t := (y - y0) / (y1 - y0)
			t = 0.5 - 0.5 * cos(PI * t)
			return float(kunci[i][col]) + (float(kunci[i + 1][col]) - float(kunci[i][col])) * t
	return float(kunci[kunci.size() - 1][col])


static func _jilbab_profil(y: float) -> Vector3:
	# (y, rx, rz, cz) — kunci menaik y; interpolasi kosinus.
	var kunci := [
		[0.88, 0.298, 0.298, 0.01],
		[0.94, 0.303, 0.303, 0.01],
		[1.00, 0.305, 0.305, 0.01],
		[1.06, 0.302, 0.302, 0.01],
		[1.12, 0.296, 0.296, 0.01],
		[1.18, 0.29, 0.29, 0.01],
		[1.24, 0.282, 0.282, 0.01],
		[1.30, 0.275, 0.275, 0.008],
		[1.34, 0.268, 0.268, 0.008],
		[1.38, 0.26, 0.26, 0.005],
		[1.42, 0.252, 0.252, 0.005],
		[1.44, 0.25, 0.25, 0.0],
		[1.46, 0.242, 0.235, 0.0],
		[1.48, 0.242, 0.232, 0.0],
		[1.50, 0.247, 0.237, 0.005],
		[1.52, 0.25, 0.24, 0.005],
		[1.54, 0.26, 0.252, 0.0],
		[1.58, 0.268, 0.26, -0.01],
		[1.62, 0.275, 0.265, -0.02],
		[1.66, 0.278, 0.268, -0.03],
		[1.70, 0.282, 0.272, -0.035],
		[1.74, 0.28, 0.275, -0.04],
		[1.78, 0.275, 0.27, -0.04],
		[1.82, 0.26, 0.26, -0.045],
		[1.86, 0.24, 0.24, -0.045],
		[1.90, 0.20, 0.20, -0.04],
		[1.93, 0.16, 0.16, -0.035],
		[1.96, 0.10, 0.10, -0.03],
		[1.975, 0.055, 0.055, -0.025],
		[1.98, 0.005, 0.005, -0.02],
	]
	return Vector3(_jilbab_interp(kunci, y, 1), _jilbab_interp(kunci, y, 2), _jilbab_interp(kunci, y, 3))


static func _jilbab_theta_buka(y: float) -> float:
	# Bukaan wajah: elips di y, pusat 1.645, setengah tinggi 0.13
	# (pita 1.515..1.775: di bawah mulut 1.55, di atas alis 1.735),
	# setengah sudut maks 0.63 rad — tepi oval lembut, pipi tertutup.
	var d := (y - 1.645) / 0.13
	if absf(d) >= 1.0:
		return 0.0
	return 0.63 * sqrt(1.0 - d * d)


static func _jilbab_tepi_bawah(theta: float) -> float:
	# Tepi bawah rok (U): depan 0.88, sisi 1.06, belakang 1.00.
	var kunci := [[0.0, 0.88], [45.0, 0.97], [90.0, 1.06], [135.0, 1.04], [180.0, 1.00]]
	var deg := fposmod(rad_to_deg(theta), 360.0)
	if deg > 180.0:
		deg = 360.0 - deg
	return _jilbab_interp(kunci, deg, 1)


static func _jilbab_lipatan(y: float) -> float:
	# Amplop lipatan: 0 di atas dagu, penuh di bawah y 1.30.
	if y >= 1.50:
		return 0.0
	if y <= 1.30:
		return 1.0
	var t := (1.50 - y) / 0.20
	return 0.5 - 0.5 * cos(PI * t)


static func _jilbab_titik(y: float, theta: float) -> Vector3:
	var p := _jilbab_profil(y)
	var f := 1.0 + 0.03 * cos(6.0 * theta) * _jilbab_lipatan(y)
	return Vector3(p.x * f * sin(theta), y, p.z + p.y * f * cos(theta))


static func _jilbab_kerudung_mesh() -> ArrayMesh:
	var C := 48
	var rows_a := [1.975, 1.96, 1.93, 1.90, 1.87, 1.84, 1.81, 1.78, 1.75, 1.72, 1.69, 1.66, 1.63, 1.60, 1.57, 1.54, 1.52, 1.50, 1.48, 1.46, 1.44]
	var ts_b := [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tris := PackedInt32Array()
	# Puncak kubah (bola R 0.30 pusat y 1.68 -> puncak 1.98).
	verts.append(Vector3(0.0, 1.98, -0.02))
	uvs.append(Vector2(0.5, 0.0))
	# Bagian A (hood): baris y horizontal, busur dipotong di pita wajah.
	var idx_a: Array = []
	for y in rows_a:
		var th_a := _jilbab_theta_buka(y)
		var row: Array = []
		for j in range(C):
			var th := 0.0
			if th_a <= 0.0:
				th = TAU * float(j) / float(C)
			else:
				th = th_a + (TAU - 2.0 * th_a) * float(j) / float(C - 1)
			row.append(verts.size())
			verts.append(_jilbab_titik(y, th))
			uvs.append(Vector2(th / TAU, (1.98 - y) / 1.10))
		idx_a.append(row)
	# Kipas puncak -> baris 0 (busur penuh). Urutan (puncak, b, a):
	# GODOT: front face = CW bila dilihat dari luar — (puncak, a, b)
	# terbaca backface dan normalnya dibalik renderer (kerudung jadi
	# cokelat kusam, hanya ambient; dibuktikan debug winding 18 Nov).
	# Normal array tetap dihitung mengarah ATAS (cross dibalik di bawah).
	var row0: Array = idx_a[0]
	for j in range(C):
		var a := int(row0[j])
		var b := int(row0[(j + 1) % C])
		tris.append_array([0, b, a])
	# Quad antar baris A (kolom terakhir -> pertama hanya bila kedua
	# baris busur penuh — kalau tidak, tepi bukaan tetap terbuka).
	# Urutan DIBALIK (a,b,c): front face Godot = CW dari luar.
	for r in range(rows_a.size() - 1):
		var lo: Array = idx_a[r]
		var hi: Array = idx_a[r + 1]
		var penuh := _jilbab_theta_buka(float(rows_a[r])) <= 0.0 and _jilbab_theta_buka(float(rows_a[r + 1])) <= 0.0
		var sampai := C if penuh else C - 1
		for j in range(sampai):
			var j2 := (j + 1) % C
			var a2 := int(lo[j])
			var b2 := int(lo[j2])
			var c2 := int(hi[j])
			var d2 := int(hi[j2])
			tris.append_array([a2, b2, c2])
			tris.append_array([b2, d2, c2])
	# Bagian B (rok): baris t, lingkaran penuh; baris 0 = seam baris A.
	var idx_b: Array = [idx_a[idx_a.size() - 1]]
	for t in ts_b.slice(1):
		var y_depan := 1.44 + float(t) * (0.88 - 1.44)
		var row: Array = []
		for j in range(C):
			var th := TAU * float(j) / float(C)
			var y := 1.44 + float(t) * (_jilbab_tepi_bawah(th) - 1.44)
			var p := _jilbab_profil(y_depan)
			var f := 1.0 + 0.03 * cos(6.0 * th) * _jilbab_lipatan(y_depan)
			row.append(verts.size())
			verts.append(Vector3(p.x * f * sin(th), y, p.z + p.y * f * cos(th)))
			uvs.append(Vector2(th / TAU, (1.98 - y_depan) / 1.10))
		idx_b.append(row)
	for r in range(idx_b.size() - 1):
		for j in range(C):
			var j2 := (j + 1) % C
			var a3 := int(idx_b[r][j])
			var b3 := int(idx_b[r][j2])
			var c3 := int(idx_b[r + 1][j])
			var d3 := int(idx_b[r + 1][j2])
			tris.append_array([a3, b3, c3])
			tris.append_array([b3, d3, c3])
	# Normal halus: akumulasi normal muka per simpul (seam berbagi
	# simpul -> normal mulus melewati sambungan A/B). Cross DIBALIK
	# ((vc-va)x(vb-va)) supaya normal array tetap mengarah KELUAR
	# meski winding dibalik untuk front face Godot (CW dari luar).
	var nrm: Array = []
	nrm.resize(verts.size())
	for i in range(nrm.size()):
		nrm[i] = Vector3.ZERO
	for t in range(0, tris.size(), 3):
		var va := verts[tris[t]]
		var vb := verts[tris[t + 1]]
		var vc := verts[tris[t + 2]]
		var n := (vc - va).cross(vb - va)
		if n.length() > 0.000001:
			n = n.normalized()
			nrm[tris[t]] += n
			nrm[tris[t + 1]] += n
			nrm[tris[t + 2]] += n
	var normals := PackedVector3Array()
	for i in range(nrm.size()):
		var nv := nrm[i] as Vector3
		normals.append(nv.normalized() if nv.length() > 0.000001 else Vector3.UP)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = tris
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh



# Shading lembut ala referensi Roblox (Mas 18:49 WIB): primitif Godot
# dengan roughness 0.9 terlihat seperti karton (matte, datar, tanpa
# highlight). Semua bahan karakter diganti ke roughness 0.45 (kilap
# halus) supaya ada highlight lembut di kepala/badan/lengan — seperti
# render sculpt Roblox. Dijalankan sekali setelah visual dibangun.
# Tekstur (motif sarung) dipertahankan, hanya roughness-nya yang
# diturunkan. Bahan Palette.mat TIDAK dimutasi (cache bersama) —
# material_override diganti dengan bahan baru dari cache Palette.
static func _lembutkan(root: Node) -> void:
	if root is MeshInstance3D:
		var mi := root as MeshInstance3D
		var m := mi.material_override as StandardMaterial3D
		# RONDE 11: bahan TRANSPARAN (lensa kacamata) jangan disentuh
		# — menggantinya dengan Palette.mat akan menghilangkan
		# transparency dan lensa jadi kaca gelap yang menutupi mata.
		# REBUILD (Kirana, 18 Nov 2026): kerudung prosedural juga
		# jangan disentuh — bahannya double-sided (sisi dalam
		# terlihat lewat bukaan + hem); menggantinya dengan
		# Palette.mat akan mengembalikan backface-culling.
		if m != null and m.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED and mi.name != "HijabKerudung":
			# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): bahan BERTEKSTUR
			# (motif batik sarung, bahan kain) dibiarkan apa adanya —
			# roughness-nya sudah ditentukan saat dibuat (batik 0.45,
			# kain 0.85); menimpa jadi 0.45 akan membuat kain mengkilap
			# seperti plastik. Hanya bahan polos yang dilembutkan.
			if m.albedo_texture == null:
				mi.material_override = Palette.mat(m.albedo_color, m.metallic, 0.45)
	for c in root.get_children():
		_lembutkan(c)


## Kitab kecil (sampul + halaman) — dipakai sebagai prop: di tangan
## (aksi bawa kitab) dan di pangkuan (aksi menulis).
static func _kitab() -> Node3D:
	var k := Node3D.new()
	k.name = "Kitab"
	# RONDE 9: sampul MARUN (bukan zamrud gelap) — kitab harus KONTRAS
	# dengan sarung zamrud + koko putih, supaya terlihat jelas di
	# pangkuan saat menulis (foto ronde 6: kitab menyatu dengan sarung).
	var sampul := Palette.box(Vector3(0.30, 0.045, 0.22), Vector3(0, 0, 0), Color("#7a1f1f"))
	sampul.name = "KitabSampul"
	k.add_child(sampul)
	var halaman := Palette.box(Vector3(0.28, 0.03, 0.20), Vector3(0, 0.012, 0), Color("#f5f0e6"))
	halaman.name = "KitabHalaman"
	k.add_child(halaman)
	var garis := Palette.box(Vector3(0.30, 0.05, 0.03), Vector3(0, 0, 0), Palette.EMAS, 0.4)
	garis.name = "KitabPunggung"
	k.add_child(garis)
	return k


## KONSEP SONGKOK v1 (Kirana, 19 Nov 2026 — ACC Mas 14:07): model peci
## santri putra: "bulat" (songkok bulat putih, posisi baru — mata
## terlihat penuh) atau "nasional" (peci hitam nasional, atas rata).
## Campur 50/50 acak tapi TETAP per NPC — hash nama, supaya model
## peci seseorang tidak ganti-ganti tiap masuk. Dipakai main.gd
## (Bilal/Faris), onboarding.gd (Sanusi), dan Raka untuk 20 NPC baru
## (DESAIN-SISTEM-NPC-v1). JANGAN ubah nama/aturan hash ini.
static func peci_model_untuk(nama: String) -> String:
	return "nasional" if abs(nama.hash()) % 2 == 0 else "bulat"


## DRAPE BERSILA v3 — tonjolan Gaussian di arah lutut (helper loft).
static func _gauss_bump(d: float, sigma: float) -> float:
	var w := wrapf(d, -PI, PI)
	return exp(-(w * w) / (sigma * sigma))


## DRAPE BERSILA v3 — bangun mesh loft sarung bersila (ArrayMesh).
## Cincin [y_dasar, R0, tonjolan, geser_z, naik_depan]: pinggang
## sempit (r 0,22) -> lutut melebar ke arah lutut (±0,83 rad dari
## depan, r 0,42 di tinggi lutut, menutupi lutut 0,294 + kapsul
## 0,085) -> bawah menutup di atas kaki bersila (kaki bersilang di
## tengah, x ±0,05). "naik_depan" = tepi bawah NAIK di tengah depan
## saja (faktor cos — 0 di samping/belakang) supaya dari depan
## terbaca DUA LUTUT + cekungan di tengahnya, bukan garis lurus:
## tepi bawah di lutut menyentuh lantai, di tengah naik 0,25.
## Cincin bawah ikut naik bertahap (0,06/0,12/0,25) supaya tidak
## ada lipatan terbalik. UV: u = sudut/2π (motif garis/batik
## melingkar seperti tabung), v = tinggi cincin.
static func _bangun_drape_bersila(bahan: Material) -> MeshInstance3D:
	var cincin: Array = [
		[0.90, 0.22, 0.00, 0.00, 0.00],
		[0.74, 0.235, 0.03, 0.01, 0.00],
		[0.60, 0.25, 0.08, 0.03, 0.00],
		[0.52, 0.24, 0.16, 0.05, 0.06],
		[0.44, 0.24, 0.18, 0.05, 0.12],
		[0.30, 0.25, 0.10, 0.05, 0.25],
	]
	var seg := 40
	var arah_lutut := 0.83
	var sigma := 0.30
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var idx := PackedInt32Array()
	for ri in cincin.size():
		var y_dasar: float = cincin[ri][0]
		var r0: float = cincin[ri][1]
		var amp: float = cincin[ri][2]
		var cz: float = cincin[ri][3]
		var naik: float = cincin[ri][4]
		for si in seg + 1:
			var th := TAU * float(si) / float(seg)
			var tonjol := _gauss_bump(th - arah_lutut, sigma) + _gauss_bump(th + arah_lutut, sigma)
			var r := r0 + amp * tonjol
			var y := y_dasar + naik * (1.0 - clampf(tonjol, 0.0, 1.0)) * maxf(0.0, cos(th))
			verts.append(Vector3(r * sin(th), y, cz + r * cos(th)))
			normals.append(Vector3(sin(th), 0.0, cos(th)).normalized())
			uvs.append(Vector2(float(si) / float(seg), float(ri) / float(cincin.size() - 1)))
	var langkah := seg + 1
	for ri in cincin.size() - 1:
		for si in seg:
			var a := ri * langkah + si
			var b := a + 1
			var c := (ri + 1) * langkah + si
			var d := c + 1
			idx.append_array([a, b, c, b, d, c])
	var pusat_idx := verts.size()
	verts.append(Vector3(0, 0.28, 0.05))
	normals.append(Vector3(0, -1, 0))
	uvs.append(Vector2(0.5, 1.0))
	var cincin_akhir := (cincin.size() - 1) * langkah
	for si in seg:
		idx.append_array([pusat_idx, cincin_akhir + si + 1, cincin_akhir + si])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = bahan
	mi.name = "SarungDrape"
	mi.scale = Vector3.ZERO
	mi.visible = false
	return mi


static func build_visual(nama: String, outfit: Dictionary) -> Dictionary:
	var koko: Color = Color(String(outfit.get("koko", "#faf7f0")))
	var songkok: Color = Color(String(outfit.get("songkok", "#faf7f0")))
	var sarung_color: Color = Color(String(outfit.get("sarung", "#0b6b4f")))
	# RONDE 11 (Mas: karakter harus beda-beda): warna kulit dari
	# outfit ("kulit", default = Palette.KULIT lama #c68e5e) dipakai
	# kepala + hidung + tangan + kaki — bukan lagi konstanta.
	var kulit: Color = Color(String(outfit.get("kulit", "#c68e5e")))
	var pakai_kacamata: bool = bool(outfit.get("kacamata", false))
	# SUSULAN RONDE 20 (Mas 19:42 WIB: kostum Ustadzah "malah kek
	# ustadz"): "muslimah" = abaya + jilbab (Ustadzah Mariyah sekarang;
	# konstruksinya nanti dipakai ulang untuk karakter santriwati).
	# SERAGAM UTAMA v2 (Kirana, 19 Nov 2026 — ACC Mas 15:41): santriwati
	# TIDAK lagi abaya — "tunik" = muslimah berbaju+sarung (tunik biru
	# langit + sarung batik coklat + jilbab putih). Abaya tetap untuk
	# Ustadzah Mariyah / Penjaga Pos Jaga (muslimah tanpa tunik).
	var muslimah: bool = bool(outfit.get("muslimah", false))
	var tunik: bool = bool(outfit.get("tunik", false))
	# 20 NPC v1 (Raka, 19 Nov 2026): kunci "alis" — NPC putra boleh
	# punya alis DATAR (varian wajah; default false = pemain + NPC
	# lama tidak berubah). Muslimah selalu beralis (aturan lama).
	var pakai_alis: bool = bool(outfit.get("alis", false))
	var pakai_abaya: bool = muslimah and not tunik
	var warna_abaya: Color = Color(String(outfit.get("abaya", "#065f46")))
	# KIRANA 17 Nov 2026 (Mas: abaya bisa dikostum): untuk muslimah,
	# torso + lengan sewarna abaya (bukan koko) — sama seperti
	# Ustadzah (koko-nya = warna abaya). Santriwan tidak berubah.
	# SERAGAM UTAMA v2: tunik memakai warna koko (biru langit),
	# bukan abaya — walau muslimah.
	var warna_baju: Color = koko if (not muslimah or tunik) else warna_abaya
	var root := Node3D.new()
	root.name = "Visual"

	# Kaki (pivot di pinggul, y=0.62) — ayunan saat jalan. Kapsul kulit
	# (bukan balok hitam) seperti kaki hero CCS; sandal oval menempel di
	# pivot kaki supaya ikut mengayun (bukan diam di tanah).
	# REVISI karakter 15 Nov (Mas: "balok banget", banding hero CCS):
	# kaki ditebalkan 0.06 -> 0.07 supaya anggota gerak tidak lidi.
	# REVISI Roblox 15 Nov ~18:49 WIB: kaki 0.07 -> 0.085, sandal
	# 0.095 -> 0.11, posisi +-0.09 -> +-0.11 — kaki tebal chunky
	# (hampir menempel di tengah) + sandal besar membulat.
	# RONDE 6: sarung panjang menutupi kaki sampai mata kaki — kapsul
	# kaki tetap ada (mengayun di balik sarung), yang terlihat di bawah
	# hem hanya ujung kaki + sandal.
	# RONDE DUDUK (17 Nov — Mas: cara duduk semua karakter perlu
	# direvisi): kaki DIBELAH jadi paha + lutut + betis supaya bersila
	# benar-benar terlipat, bukan batang kaku yang diputar utuh.
	# Paha 0.30 m (pivot pinggul y=0.62) + betis 0.28 m (pivot lutut
	# y=0.32) = total 0.58 m ≈ kaki lama; mata kaki tetap ~0.02 m,
	# jadi jalan/idle/tidur dan semua pose lama tetap berlaku.
	# Nama "KakiKiri/KakiKanan" dipertahankan di BETIS (kulit) supaya
	# loop warna kulit RONDE 11 tetap menemukannya; paha memakai warna
	# sarung/abaya supaya kalau mengintip dari balik sarung tetap nyatu.
	var warna_paha: Color = warna_abaya if pakai_abaya else sarung_color
	var leg_l := Node3D.new()
	leg_l.position = Vector3(-0.11, 0.62, 0)
	var paha_l := Palette.capsule(0.085, 0.30, Vector3(0, -0.15, 0), warna_paha)
	paha_l.name = "PahaKiri"
	leg_l.add_child(paha_l)
	var knee_l := Node3D.new()
	knee_l.name = "LututKiri"
	knee_l.position = Vector3(0, -0.30, 0)
	leg_l.add_child(knee_l)
	var kaki_l := Palette.capsule(0.085, 0.28, Vector3(0, -0.14, 0), kulit)
	kaki_l.name = "KakiKiri"
	knee_l.add_child(kaki_l)
	var sandal_l := Palette.cylinder(0.11, 0.11, 0.035, Vector3(0, -0.285, -0.02), Color("#4a3226"))
	sandal_l.scale = Vector3(0.9, 1.0, 1.5)
	sandal_l.name = "SandalKiri"
	# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): SOL sandal — lapisan
	# gelap di bawah sandal (anak dari node sandal, jadi ikut skala
	# 0.9/1.5 + ikut sembunyi saat sandal dilepas). Bawah sol dunia
	# 0.009 (sandal 0.035 - sol 0.02 - setengah tebal 0.006) — tetap
	# menyentuh tanah menurut audit (batas -0.01..0.03).
	var sol_l := Palette.cylinder(0.105, 0.105, 0.012, Vector3(0, -0.02, 0), Color("#2e1d12"))
	sol_l.name = "SolKiri"
	sandal_l.add_child(sol_l)
	knee_l.add_child(sandal_l)
	root.add_child(leg_l)
	var leg_r := Node3D.new()
	leg_r.position = Vector3(0.11, 0.62, 0)
	var paha_r := Palette.capsule(0.085, 0.30, Vector3(0, -0.15, 0), warna_paha)
	paha_r.name = "PahaKanan"
	leg_r.add_child(paha_r)
	var knee_r := Node3D.new()
	knee_r.name = "LututKanan"
	knee_r.position = Vector3(0, -0.30, 0)
	leg_r.add_child(knee_r)
	var kaki_r := Palette.capsule(0.085, 0.28, Vector3(0, -0.14, 0), kulit)
	kaki_r.name = "KakiKanan"
	knee_r.add_child(kaki_r)
	var sandal_r := Palette.cylinder(0.11, 0.11, 0.035, Vector3(0, -0.285, -0.02), Color("#4a3226"))
	sandal_r.scale = Vector3(0.9, 1.0, 1.5)
	sandal_r.name = "SandalKanan"
	var sol_r := Palette.cylinder(0.105, 0.105, 0.012, Vector3(0, -0.02, 0), Color("#2e1d12"))
	sol_r.name = "SolKanan"
	sandal_r.add_child(sol_r)
	knee_r.add_child(sandal_r)
	root.add_child(leg_r)

	# Pakaian bawah — dua bentuk, SATU slot ("sarung" di dictionary,
	# supaya _lerp_pakaian / _terapkan_pakaian NPC tetap jalan):
	# pakai_abaya = ABAYA (satu gamis panjang longgar bahu -> mata kaki,
	# tanpa motif batik, tanpa sarung terpisah); yang lain = sarung.
	var sarung: MeshInstance3D = null
	var hem: MeshInstance3D = null
	var sarung_trim: MeshInstance3D = null
	var abaya: MeshInstance3D = null
	if pakai_abaya:
		# ABAYA RAMPING (Kirana, 19 Nov 2026 — Mas: "badannya kayak
		# tabung elpiji"): siluet A-line LEMBUT, bukan silinder
		# seragam. Atas r=0.19 (bahu, selebar torso kapsul r=0.21
		# yang sewarna di dalamnya) -> bawah r=0.30 (hem), tinggi
		# 1.32, pusat y=0.76 — bawah di y=0.10 (mata kaki, sama
		# seperti sarung ronde 6), atas di y=1.42 (menutupi pinggang
		# + dada bawah; torso di atasnya sewarna jadi satu gamis).
		# Polos zamrud gelap #065f46 — BUKAN batik (motif batik itu
		# yang membuat roknya terbaca "sarung santri"). Lengan
		# muslimah (pivot ±0.34) kini BERDIRI DI LUAR permukaan
		# abaya di semua ketinggian (dulu lengan atas tenggelam di
		# kerucut 0.23->0.36), jadi lengan terbaca sebagai anggota
		# badan terpisah, bukan bagian tabung.
		abaya = Palette.cylinder(0.19, 0.30, 1.32, Vector3(0, 0.76, 0), warna_abaya)
		abaya.name = "Abaya"
		# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): abaya kain jersey.
		abaya.material_override = _bahan_kain(warna_abaya)
		root.add_child(abaya)
		sarung = abaya
		hem = Palette.sphere(0.30, Vector3(0, 0.12, 0), warna_abaya)
		hem.scale = Vector3(1.0, 0.25, 1.0)
		hem.name = "AbayaHem"
		root.add_child(hem)
		# Lis emas di ujung abaya (palet pesantren, seperti sarung).
		sarung_trim = Palette.cylinder(0.30, 0.30, 0.04, Vector3(0, 0.14, 0), Palette.EMAS, 0.4)
		sarung_trim.name = "AbayaTrim"
		root.add_child(sarung_trim)
	else:
		# Sarung SAMPAI MATA KAKI (RONDE 6): tabung zamrud tinggi 0.80,
		# pusat y=0.50 — bawah di y=0.10 (pergelangan kaki), atas di y=0.90
		# (menutupi pinggang). Hem membulat + lis emas mengikuti bawah.
		# SERAGAM UTAMA v2: motif dari kunci "sarung_motif" (garis/batik/
		# parang) + hem mengikuti motif — lihat _bahan_sarung().
		sarung = Palette.cylinder(0.20, 0.29, 0.80, Vector3(0, 0.50, 0), sarung_color)
		sarung.material_override = _bahan_sarung(outfit)
		sarung.name = "Sarung"
		root.add_child(sarung)
		hem = Palette.sphere(0.29, Vector3(0, 0.12, 0), _hem_sarung_warna(outfit))
		hem.scale = Vector3(1.0, 0.25, 1.0)
		hem.name = "SarungHem"
		root.add_child(hem)
		# Lis emas di ujung sarung.
		sarung_trim = Palette.cylinder(0.29, 0.29, 0.04, Vector3(0, 0.14, 0), Palette.EMAS, 0.4)
		sarung_trim.name = "SarungTrim"
		root.add_child(sarung_trim)

	# TONJOLAN LUTUT BERSILA (Kirana, 20 Nov 2026 — verdict Mas:
	# "Ketika duduk bersila masih mekar sarungnya"): gundukan v2
	# (1.95,0.32,1.95) jauh membaik dari samping, tapi dari DEPAN
	# sarung tetap kerucut mulus — lutut tidak menonjol. Dua tonjolan
	# (bola pipih, bahan SAMA seperti sarung/abaya supaya motif +
	# warna nyatu) di posisi lutut saat bersila. Lutut terukur di
	# (±0,22, 0,42, 0,20) saat paha -0.85 + yaw ±0.50; tonjolan
	# didorong ke luar-depan (±0,33, 0,55, 0,30) supaya tepi
	# luarnya 10 cm LEBIH LEBAR dari rim gundukan (0,566) — lutut
	# jadi titik TERLEBAR alas, seperti orang bersila beneran.
	# Sumbu panjang (z) diputar yaw ±0.50 mengikuti arah paha.
	# Bawah tonjolan menyentuh lantai (0,55 - 0,20*0,65 - 0,42
	# ≈ 0), atasnya menyatu ke kerucut — seperti kain menutupi
	# lutut. Skala di-lerp lewat kunci "lutut_scale" di PAKAIAN_*:
	# penuh saat duduk/menulis (bersila), 0 di pose lain —
	# duduk_kursi TIDAK tersentuh.
	var lutut_l: MeshInstance3D = null
	var lutut_r: MeshInstance3D = null
	var bahan_lutut: Material = _bahan_kain(warna_abaya) if pakai_abaya else _bahan_sarung(outfit)
	for sisi in [-1.0, 1.0]:
		var lutut := Palette.sphere(0.20, Vector3(0.33 * sisi, 0.55, 0.30), sarung_color)
		lutut.scale = Vector3.ZERO
		lutut.visible = false
		lutut.rotation.y = 0.50 * sisi
		lutut.material_override = bahan_lutut
		lutut.name = "TonjolanLututKiri" if sisi < 0.0 else "TonjolanLututKanan"
		root.add_child(lutut)
		if sisi < 0.0:
			lutut_l = lutut
		else:
			lutut_r = lutut

	# DRAPE BERSILA v3 (Kirana, 20 Nov 2026 — koreksi Mas "Yg jelas
	# duduk bersila"): loft ArrayMesh yang mengikuti paha menyilang —
	# MENGGANTIKAN gundukan + tonjolan lutut v2 (keduanya dipensiunkan:
	# tonjolan lutut_scale = 0 di semua PAKAIAN_*, sarung silinder
	# jadi inti kecil di dalam drape). Cincin loft (y lokal, R0,
	# tonjolan, geser z): pinggang sempit -> lutut melebar ke arah
	# lutut (±48° dari depan) -> bawah menutup di atas kaki bersila.
	# UV: u = sudut/2π (motif garis/batik melingkar seperti tabung),
	# v = tinggi cincin. Skala di-lerp lewat kunci "drape_scale":
	# penuh saat duduk/menulis (bersila), 0 di pose lain.
	var drape := _bangun_drape_bersila(bahan_lutut)
	root.add_child(drape)

# Perbaikan 15 Nov ~17:20 WIB (penguji ronde 3: badan masih kotak —
# kemeja putih persegi panjang, lengan silinder tipis). Torso kini
# KAPSUL (ujung atas-bawah membulat), bukan silinder bertaper.
# Kapsul r=0,21 tinggi total 0,62 di y=1,08: silinder di y 0,98..1,18,
# kubah di luar itu — kancing + lis mengikuti permukaan kapsul.
# REVISI Roblox 15 Nov ~18:49 WIB: torso 0.21 -> 0.23 (selebar
# hampir kepala — badan chunky ala Roblox); silinder kapsul kini
# y 1.00..1.16, kancing + lis dihitung ulang di permukaan baru.
	# RONDE 9 (Mas: "Bahu dan dada aneh"): torso DIPERSEMPIT (r 0.23 ->
	# 0.21) dan DIPANJANG (0.62 -> 0.66) supaya dada tidak kotak-pipih;
	# lis dada (strip putih terpisah = rompi) DIHAPUS; kancing 4 -> 3
	# butir kecil langsung di permukaan kapsul (tanpa strip).
	var torso := Palette.capsule(0.21, 0.66, Vector3(0, 1.06, 0), warna_baju)
	torso.name = "Torso"
	# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): koko/abaya kain jersey.
	torso.material_override = _bahan_kain(warna_baju)
	root.add_child(torso)
	# Kerah + kancing koko HANYA untuk santriwan/Kyai — muslimah
	# TIDAK pakai: abaya itu satu gamis polos tanpa kerah dan tanpa
	# kancing (kerah + kancing emas di dada yang membuat Ustadzah
	# lama terbaca "koko putih"). Torso muslimah sewarna abaya
	# (koko #065f46 dari OUTFIT_USTADZAH) jadi satu gamis.
	if not muslimah:
		# Kerah koko: cincin pendek di leher (warna koko, bukan krem pucat).
		var kerah := Palette.cylinder(0.11, 0.13, 0.07, Vector3(0, 1.40, 0), koko)
		kerah.name = "Kerah"
		kerah.material_override = _bahan_kain(koko)
		root.add_child(kerah)
		# Kancing emas di dada (3 butir, z mengikuti permukaan kapsul r=0.21:
		# silinder y 0.94..1.18, kubah atas berpusat di y=1.18).
		for i in range(3):
			var ky := 1.27 - i * 0.11
			var dz := 0.21
			if ky > 1.18:
				dz = sqrt(maxf(0.0, 0.21 * 0.21 - (ky - 1.18) * (ky - 1.18)))
			var kancing := Palette.sphere(0.016, Vector3(0, ky, dz + 0.008), Palette.EMAS, 0.5)
			kancing.name = "Kancing%d" % (i + 1)
			root.add_child(kancing)

	# LENGAN (RONDE 9, Mas: "Bahu dan dada aneh"): BahuYoke DIHAPUS —
	# elipsoid pipih 0.62 m itu yang membuat bantalan bahu seperti
	# pemain football. Sebagai gantinya lengan muncul DARI DALAM torso:
	# pivot di (±0.235, 1.30) — hanya 0.025 di luar permukaan torso
	# (r=0.21) — tabung lengan (r=0.10) menembus torso 0.08 m sehingga
	# menyatu tanpa celah; bola bahu kecil (r=0.095) hanya mengisi
	# sudut ketiak, bukan bantalan terpisah. Lebar bahu total 0.66 m
	# (dulu 0.77 m). Lengan tetap meruncing 0.10 -> 0.08 -> 0.058,
	# siku lurus saat berdiri, tangan bola pipih.
	# Lengan menggantung sedikit menjauh dari badan (rotasi z ±0.05)
	# supaya tidak menempel di sarung. Shading tetap lembut
	# (roughness 0.45 via _lembutkan) supaya sudut tidak keras.
	# RONDE 10 (Mas: "Salaman harusnya pakai tangan kanan bukan
	# kiri"): pivot lengan TERTUKAR dengan anatomi — wajah karakter
	# di +Z (mata z=+0.222), jadi saat menghadap +Z (selatan) tangan
	# KANAN anatomis ada di -X (barat), bukan +X. Dulu arm_r di +X =
	# tangan KIRI anatomis, sehingga salaman/melambai/menulis/bawa
	# kitab memakai tangan kiri. Kini arm_r di -X (kanan) dan arm_l
	# di +X (kiri); SEMUA rotation.z lengan dibalik tandanya supaya
	# "ke dalam / ke luar" tetap sama (duduk, menulis, salaman,
	# melambai, tidur, reset berdiri). rotation.x tidak berubah
	# (ayunan maju-mundur simetris). Anak-anak (BahuKanan/TanganKanan)
	# ikut pivot — namanya kini benar secara anatomi.
	# KIRANA 16 Nov ~21:45 WIB (Mas: figur Ustadzah "kok aneh" —
	# badan kerucut tanpa lengan): lengan muslimah KELUAR dari
	# abaya — pivot ±0.34 (di luar permukaan abaya 0.20 di
	# y=1.30, ramping 19 Nov 2026) + miring keluar 0.12 + lengan
	# sedikit lebih tebal supaya sleeve abaya terbaca, bukan lidi
	# yang tenggelam di gamis. Lengan santriwan/Kyai tetap
	# ±0.235 / 0.05.
	var lengan_x := 0.34 if muslimah else 0.235
	var lengan_miring := 0.12 if muslimah else 0.05
	var r_lengan_atas := 0.11 if muslimah else 0.10
	var r_lengan_bawah := 0.085 if muslimah else 0.08
	var arm_l := Node3D.new()
	arm_l.position = Vector3(lengan_x, 1.30, 0)
	arm_l.rotation.z = lengan_miring
	var bahu_l := Palette.sphere(0.095, Vector3(0, 0, 0), warna_baju)
	bahu_l.name = "BahuKiri"
	bahu_l.material_override = _bahan_kain(warna_baju)
	arm_l.add_child(bahu_l)
	var lengan_atas_l := Palette.cylinder(r_lengan_atas, r_lengan_bawah, 0.30, Vector3(0, -0.15, 0), warna_baju)
	lengan_atas_l.name = "LenganAtasKiri"
	lengan_atas_l.material_override = _bahan_kain(warna_baju)
	arm_l.add_child(lengan_atas_l)
	var elbow_l := Node3D.new()
	elbow_l.position = Vector3(0, -0.30, 0)
	arm_l.add_child(elbow_l)
	var siku_l := Palette.sphere(0.08, Vector3(0, 0, 0), warna_baju)
	siku_l.name = "SikuKiri"
	siku_l.material_override = _bahan_kain(warna_baju)
	elbow_l.add_child(siku_l)
	var lengan_bawah_l := Palette.cylinder(r_lengan_bawah, 0.06 if muslimah else 0.058, 0.26, Vector3(0, -0.13, 0), warna_baju)
	lengan_bawah_l.name = "LenganBawahKiri"
	lengan_bawah_l.material_override = _bahan_kain(warna_baju)
	elbow_l.add_child(lengan_bawah_l)
	# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): TANGAN KAPSUL (dulu bola
	# pipih r=0.072 skala 1/0.7/1.3) — kapsul vertikal r=0.055 tinggi
	# 0.12, sedikit pipih depan-belakang (skala z 0.8): telapak yang
	# menggantung natural, menyatu dengan lengan bawah (rentang
	# -0.23..-0.35 vs lengan bawah sampai -0.26) dan tetap di luar
	# badan (|x| pusat = lengan_x, audit > 0.20).
	var tangan_l := Palette.capsule(0.055, 0.12, Vector3(0, -0.29, 0.01), kulit)
	tangan_l.scale = Vector3(1.0, 1.0, 0.8)
	tangan_l.name = "TanganKiri"
	elbow_l.add_child(tangan_l)
	root.add_child(arm_l)
	var arm_r := Node3D.new()
	arm_r.position = Vector3(-lengan_x, 1.30, 0)
	arm_r.rotation.z = -lengan_miring
	var bahu_r := Palette.sphere(0.095, Vector3(0, 0, 0), warna_baju)
	bahu_r.name = "BahuKanan"
	bahu_r.material_override = _bahan_kain(warna_baju)
	arm_r.add_child(bahu_r)
	var lengan_atas_r := Palette.cylinder(r_lengan_atas, r_lengan_bawah, 0.30, Vector3(0, -0.15, 0), warna_baju)
	lengan_atas_r.name = "LenganAtasKanan"
	lengan_atas_r.material_override = _bahan_kain(warna_baju)
	arm_r.add_child(lengan_atas_r)
	var elbow_r := Node3D.new()
	elbow_r.position = Vector3(0, -0.30, 0)
	arm_r.add_child(elbow_r)
	var siku_r := Palette.sphere(0.08, Vector3(0, 0, 0), warna_baju)
	siku_r.name = "SikuKanan"
	siku_r.material_override = _bahan_kain(warna_baju)
	elbow_r.add_child(siku_r)
	var lengan_bawah_r := Palette.cylinder(r_lengan_bawah, 0.06 if muslimah else 0.058, 0.26, Vector3(0, -0.13, 0), warna_baju)
	lengan_bawah_r.name = "LenganBawahKanan"
	lengan_bawah_r.material_override = _bahan_kain(warna_baju)
	elbow_r.add_child(lengan_bawah_r)
	var tangan_r := Palette.capsule(0.055, 0.12, Vector3(0, -0.29, 0.01), kulit)
	tangan_r.scale = Vector3(1.0, 1.0, 0.8)
	tangan_r.name = "TanganKanan"
	elbow_r.add_child(tangan_r)
	# Siwak (RONDE 21, 18 Nov 2026 — ganti garuk kepala di idle atas
	# perintah Mas 21:19 WIB "gerakan garuk-garuk kepala kok aneh"):
	# batang kayu tipis di tangan kanan (r 0,011, panjang 0,24 —
	# cukup tebal supaya terbaca di kamera game). Arah + posisi
	# diatur dinamis tiap frame oleh terapkan_idle (_arahkan_siwak)
	# supaya ujungnya tepat di mulut. Tersembunyi sampai gerakan
	# bersiwak (visibilitas diatur terapkan_idle).
	var siwak := Palette.cylinder(0.011, 0.011, 0.24, Vector3(0, -0.10, 0.02), Color("#7B4B2A"))
	siwak.name = "Siwak"
	siwak.visible = false
	tangan_r.add_child(siwak)
	root.add_child(arm_r)
	# Kitab di tangan kanan (aksi "Bawa Kitab") — tersembunyi dulu.
	var kitab_tangan := _kitab()
	kitab_tangan.position = Vector3(0, -0.52, 0.10)
	kitab_tangan.visible = false
	arm_r.add_child(kitab_tangan)
	# RONDE 9: kitab di pangkuan DIPERBESAR (1.2 -> 1.5) dan DIPOSISIKAN
	# DI ATAS pangkuan saat duduk — dulu di (0, 0.30, 0.30) sehingga
	# saat visual turun -0.42 kitab tenggelam di bawah lantai (tidak
	# terlihat di foto menulis). Kini y=0.86 -> dunia 0.44 saat duduk.
	var kitab_pangku := _kitab()
	kitab_pangku.scale = Vector3(1.5, 1.0, 1.5)
	kitab_pangku.position = Vector3(0, 0.86, 0.38)
	kitab_pangku.rotation.x = -0.35
	kitab_pangku.visible = false
	root.add_child(kitab_pangku)

	# Kepala + wajah: mata gelap, hidung, senyum tipis (ala hero CCS).
	# SEMUA bulat: mata bola (sedikit lonjong), hidung bola kecil,
	# senyum lengkung dari 5 bola kecil di permukaan kepala.
	# REVISI karakter 15 Nov: kepala diperbesar 0.19 -> 0.21 dan
	# dinaikkan ke y=1.62 (hero CCS chibi: kepala+peci ~37% tinggi;
	# karakter ini dulu ~24%) — wajah dihitung ulang di permukaan
	# bola baru, peci ikut membesar, kerah tetap terlihat di leher.
	# REVISI Roblox 15 Nov ~18:49 WIB (referensi-avatar-roblox.jpg):
	# kepala 0.21 -> 0.24 di y=1.66 (diameter 0.48 = ~25% tinggi,
	# LEBIH LEBAR dari torso — kepala besar bulat ala Roblox),
	# mata/hidung/peci dihitung ulang di permukaan bola baru.
	var kepala := Palette.sphere(0.24, Vector3(0, 1.66, 0), kulit)
	kepala.name = "Kepala"
	root.add_child(kepala)
	# KIRANA 16 Nov ~21:45 WIB (wajah Ustadzah "seperti topeng"):
	# mata muslimah sedikit lebih besar (0.028) supaya tidak
	# tinggal dua titik di balik jilbab.
	var r_mata := 0.028 if muslimah else 0.025
	var mata_l := Palette.sphere(r_mata, Vector3(-0.085, 1.69, 0.222), Color("#2a2018"))
	mata_l.scale = Vector3(1.0, 1.25, 0.7)
	mata_l.name = "MataKiri"
	root.add_child(mata_l)
	var mata_r := Palette.sphere(r_mata, Vector3(0.085, 1.69, 0.222), Color("#2a2018"))
	mata_r.scale = Vector3(1.0, 1.25, 0.7)
	mata_r.name = "MataKanan"
	root.add_child(mata_r)
	var hidung := Palette.sphere(0.025, Vector3(0, 1.62, 0.237), kulit)
	hidung.name = "Hidung"
	root.add_child(hidung)
	# Mulut: GARIS LURUS kecil yang menyambung (bukan bola-bola,
	# bukan busur torus) — referensi Roblox Mas 18:49 WIB: mulutnya
	# garis lurus tipis, tanpa benjolan. Satu kapsul tipis yang
	# dibaringkan (rotasi Z 90°) — ujung membulat, garis halus dan
	# bersih. Pusat sedikit ditanam (z 0.210 vs permukaan 0.213)
	# supaya ujung garis tidak melayang di atas lengkung kepala.
	var senyum := Palette.capsule(0.009, 0.08, Vector3(0, 1.55, 0.210), Color("#7a4a30"))
	senyum.name = "Senyum"
	senyum.rotation.z = PI / 2.0
	root.add_child(senyum)
	# Alis — HANYA muslimah (KIRANA 16 Nov ~21:45 WIB): tanpa
	# alis + strip jilbab yang sempit, wajah Ustadzah terbaca
	# topeng coklat datar. Dua kapsul tipis di atas mata
	# (±0.085, 1.735, 0.222 — tepat di permukaan kepala, di
	# depan tepi kubah 0.209) memberi wajah ekspresi.
	# 20 NPC v1 (Raka): + NPC putra dengan kunci outfit "alis".
	# Alis SELALU DATAR (PI/2) — alis miring pernah dicoba Kirana
	# (21:52) dan terbaca "marah/jutek", jangan dimiringkan lagi.
	if muslimah or pakai_alis:
		for sx in [-1.0, 1.0]:
			var alis := Palette.capsule(0.008, 0.07, Vector3(sx * 0.085, 1.735, 0.222), Color("#2a2018"))
			# KIRANA revisi 21:52 WIB: alis miring (PI/2 ± 0.10)
			# membuat ujung dalam turun ke hidung — wajah jadi
			# terlihat marah/jutek di foto 05f. Kini DATAR.
			alis.rotation.z = PI / 2.0
			alis.name = "AlisKiri" if sx < 0.0 else "AlisKanan"
			root.add_child(alis)
	# JENGGOT + KUMIS (RONDE 15, Mas: Kyai berjanggut + berkumis
	# tipis). Jenggot rapi mengikuti dagu/rahang: bola pipih yang
	# membungkus dagu bawah + menggantung sampai kerah; ujungnya
	# sedikit beruban (bola kedua abu kecokelatan, hanya menonjol di
	# ujung depan-bawah). Mulut tetap di depan jenggot (z mulut 0.210
	# vs permukaan jenggot ~0.198 di tinggi mulut). Kumis TIPIS: satu
	# kapsul ramping di atas bibir, di bawah hidung, warna sama
	# seperti jenggot.
	var pakai_jenggot: bool = bool(outfit.get("jenggot", false))
	var warna_jenggot: Color = Color(String(outfit.get("jenggot_warna", "#2b241d")))
	var warna_uban: Color = Color(String(outfit.get("uban_warna", "#7d7468")))
	var pakai_kumis: bool = bool(outfit.get("kumis", false))
	var jenggot: MeshInstance3D = null
	var uban: MeshInstance3D = null
	var kumis: MeshInstance3D = null
	if pakai_jenggot:
		# KARAKTER PRIMITIF (Kirana, 17 Nov 2026): jenggot DIPANJANGKAN
		# (skala y 0.85 -> 0.95, pusat 1.51 -> 1.50; bawah 1.35 -> 1.32,
		# menggantung melewati kerah) + uban ujung diperbesar (r 0.11 ->
		# 0.12) supaya "beruban di ujung" terbaca dari jauh. Mulut tetap
		# di depan jenggot (permukaan jenggot z~0.197 di tinggi mulut
		# vs mulut z 0.210); bawah jenggot tetap < 1.45 (audit).
		jenggot = Palette.sphere(0.19, Vector3(0, 1.50, 0.06), warna_jenggot)
		jenggot.scale = Vector3(1.05, 0.95, 0.72)
		jenggot.name = "Jenggot"
		root.add_child(jenggot)
		uban = Palette.sphere(0.12, Vector3(0, 1.385, 0.09), warna_uban)
		uban.scale = Vector3(0.9, 0.6, 0.7)
		uban.name = "JenggotUban"
		root.add_child(uban)
	if pakai_kumis:
		kumis = Palette.capsule(0.011, 0.10, Vector3(0, 1.583, 0.222), warna_jenggot)
		kumis.rotation.z = PI / 2.0
		kumis.name = "Kumis"
		root.add_child(kumis)
	# RAMBUT hitam (RONDE 10, Mas 05:54 WIB: "harusnya rambut itu
	# dibawah kopyah.. ini bagian belakang malah ga ada kopyah cuma
	# rambut aja"). Akar: bola rambut lama (r=0.235 di (0,1.76,-0.08))
	# menonjol 0.085 m DI BELAKANG peci (z=-0.315 vs peci -0.23) dan
	# setinggi peci — dari belakang kepala jadi helm hitam penuh.
	# Kini rambut KECIL + RENDAH + di bawah peci: hanya pinggiran
	# tipis yang mengintip di bawah tepi kopyah (sisi di atas telinga
	# + tengkuk). Terukur: punggung rambut z=-0.26 hanya 0.022 di
	# luar kepala (-0.238) pada y~1.69; sisi x=±0.252 hanya 0.011 di
	# luar peci pada y~1.70; depan z=+0.16 tetap di dalam kepala
	# (tidak menutupi wajah); puncak 1.805 jauh di bawah puncak peci.
	# RONDE 15 (Mas: Kyai memakai serban): serban MENGGANTIKAN songkok
	# — kain lilit, bukan topi polos: 3 lilitan bertingkat (silinder
	# bersusun, jari-jari sedikit berbeda supaya lapisannya terbaca)
	# + kubah atas + simpul depan + ekor kain di belakang (turun
	# sampai kerah). Rambut disembunyikan — serban menutupi seluruh
	# kepala. Node serban dikelompokkan di "Serban" (satu node untuk
	# tes + perubahan outfit nanti).
	var pakai_serban: bool = bool(outfit.get("serban", false))
	var warna_serban: Color = Color(String(outfit.get("serban_warna", "#f5f0e0")))
	var pakai_hijab: bool = bool(outfit.get("hijab", false))
	var warna_hijab: Color = Color(String(outfit.get("hijab_warna", "#065f46")))
	var peci: MeshInstance3D = null
	var peci_band: MeshInstance3D = null
	var serban: Node3D = null
	var hijab: Node3D = null
	if pakai_serban:
		serban = Node3D.new()
		serban.name = "Serban"
		var lilit1 := Palette.cylinder(0.27, 0.28, 0.06, Vector3(0, 1.74, 0), warna_serban)
		lilit1.name = "SerbanLilit1"
		serban.add_child(lilit1)
		var lilit2 := Palette.cylinder(0.285, 0.275, 0.06, Vector3(0, 1.795, 0), warna_serban)
		lilit2.name = "SerbanLilit2"
		serban.add_child(lilit2)
		var lilit3 := Palette.cylinder(0.26, 0.275, 0.05, Vector3(0, 1.845, 0), warna_serban)
		lilit3.name = "SerbanLilit3"
		serban.add_child(lilit3)
		var kubah_serban := Palette.sphere(0.24, Vector3(0, 1.855, 0), warna_serban)
		kubah_serban.scale = Vector3(1.0, 0.5, 1.0)
		kubah_serban.name = "SerbanKubah"
		serban.add_child(kubah_serban)
		var simpul := Palette.sphere(0.05, Vector3(0, 1.93, 0.07), warna_serban)
		simpul.scale = Vector3(1.0, 0.7, 1.0)
		simpul.name = "SerbanSimpul"
		serban.add_child(simpul)
		var ekor := Palette.capsule(0.045, 0.26, Vector3(0, 1.60, -0.245), warna_serban.darkened(0.06))
		ekor.scale = Vector3(1.0, 1.0, 0.35)
		ekor.name = "SerbanEkor"
		serban.add_child(ekor)
		root.add_child(serban)
	elif pakai_hijab:
		# JILBAB REBUILD (Kirana, 18 Nov 2026 — reset total, verdict Mas
		# 12:10 WIB "Jelek.. coba bikin dari awal lagi supaya sesuai
		# gambar referensi"): SEMUA node primitif ronde 1-8 DIHAPUS
		# (kubah, drape, leher, dagu, drape dada 3 tier, panel, strip,
		# lipatan). Kerudung kini SATU mesh prosedural — lihat
		# _jilbab_kerudung_mesh(): kubah longgar + rok kain yang
		# melebar ke dada, satu permukaan utuh, bukaan wajah OVAL
		# LEMBUT yang dibentuk mesh-nya sendiri (pipi tertutup, hanya
		# tengah wajah terlihat: mata, hidung, mulut, kacamata).
		# Acuan satu-satunya: konsep-jilbab-v1.png. Warna krem
		# #f2ead6 di atas abaya zamrud gelap (RONDE 20) — kontrasnya
		# yang membuat jilbab terbaca dari jauh.
		hijab = Node3D.new()
		hijab.name = "Hijab"
		var kerudung := MeshInstance3D.new()
		kerudung.name = "HijabKerudung"
		kerudung.mesh = _jilbab_kerudung_mesh()
		kerudung.material_override = _bahan_jilbab(warna_hijab)
		hijab.add_child(kerudung)
		root.add_child(hijab)

	else:
		# RAMBUT hitam (RONDE 10, Mas 05:54 WIB: "harusnya rambut itu
		# dibawah kopyah.. ini bagian belakang malah ga ada kopyah cuma
		# rambut aja"). Akar: bola rambut lama (r=0.235 di (0,1.76,-0.08))
		# menonjol 0.085 m DI BELAKANG peci (z=-0.315 vs peci -0.23) dan
		# setinggi peci — dari belakang kepala jadi helm hitam penuh.
		# Kini rambut KECIL + RENDAH + di bawah peci: hanya pinggiran
		# tipis yang mengintip di bawah tepi kopyah (sisi di atas telinga
		# + tengkuk). Terukur: punggung rambut z=-0.26 hanya 0.022 di
		# luar kepala (-0.238) pada y~1.69; sisi x=±0.252 hanya 0.011 di
		# luar peci pada y~1.70; depan z=+0.16 tetap di dalam kepala
		# (tidak menutupi wajah); puncak 1.805 jauh di bawah puncak peci.
		var rambut := Palette.sphere(0.21, Vector3(0, 1.69, -0.05), Color("#1a1a1a"))
		rambut.scale = Vector3(1.2, 0.55, 1.0)
		rambut.name = "Rambut"
		root.add_child(rambut)
		# Songkok (RONDE 10): kubah LEBIH BESAR dari kepala (r=0.265 >
		# kepala 0.24) supaya menutupi ubun-ubun 360° — dari depan,
		# samping, DAN belakang, atas kepala PUTIH.
		# KONSEP SONGKOK v1 (Kirana, 19 Nov 2026 — ACC Mas 14:07):
		# songkok lama menutupi SETENGAH ATAS mata (tepi bawah y=1.688
		# di posisi mata). Perbaikan: pusat naik (0,1.77,0) -> (0,1.82,0),
		# skala y 0.70 -> 0.68, band (0.26/0.27 @ y=1.75) ->
		# (0.255/0.265 @ y=1.80) — tepi bawah di mata jadi y=1.740
		# (1,9 cm di atas puncak mata 1.721); puncak kubah 2.00
		# (tetap < 2.10 audit).
		# Kunci outfit "peci_model": "bulat" (default, songkok bulat)
		# atau "nasional" (peci hitam nasional, atas RATA — kerucut
		# terpancung, selalu hitam #151515 apa pun warna "songkok").
		# Node varian nasional tetap bernama "Peci" supaya audit +
		# terapkan_outfit tidak perlu diubah.
		var peci_model: String = String(outfit.get("peci_model", "bulat"))
		if peci_model == "nasional":
			peci = Palette.cylinder(0.205, 0.235, 0.18, Vector3(0, 1.825, 0), Color("#151515"))
			peci.name = "Peci"
			root.add_child(peci)
			peci_band = Palette.cylinder(0.235, 0.24, 0.03, Vector3(0, 1.75, 0), Color("#0d0d0d"))
			peci_band.name = "PeciBand"
			root.add_child(peci_band)
		else:
			peci = Palette.sphere(0.265, Vector3(0, 1.82, 0), songkok)
			peci.scale = Vector3(1.0, 0.68, 1.0)
			peci.name = "Peci"
			root.add_child(peci)
			# Lis songkok: pita tipis di tepi bawah kubah (sedikit lebih gelap).
			peci_band = Palette.cylinder(0.255, 0.265, 0.04, Vector3(0, 1.80, 0), songkok.darkened(0.12))
			peci_band.name = "PeciBand"
			root.add_child(peci_band)
	# Kacamata (RONDE 11, Mas: karakter harus beda-beda): bingkai
	# hitam + lensa, opsional (outfit "kacamata"). Dua lensa kotak di
	# depan mata (±0.085, 1.69) + jembatan hidung + gagang ke telinga.
	# Node selalu dibuat (supaya terapkan_outfit bisa toggle), hanya
	# visible kalau outfit minta kacamata.
	var kacamata := _kacamata()
	kacamata.visible = pakai_kacamata
	root.add_child(kacamata)
	# LENCANA SATPAM (Kirana, 17 Nov 2026 — ronde karakter primitif):
	# audit baseline gagal "satpam: lencana ada" karena node-nya belum
	# pernah dibuat. Lencana emas di dada KIRI anatomis (x=+0.09, sisi
	# yang sama dengan audit: x > 0.03, y 1.05..1.35, z > 0.18).
	# Permukaan torso di titik itu z=0.186 (kubah atas kapsul r=0.21,
	# y=1.22, x=0.09) — cakram luar di z=0.19 (belakang 0.184, masuk
	# 0.002 ke torso; depan 0.196 menonjol 0.010), cakram dalam +
	# titik tengah menumpuk di depannya. Emas konsep #e2b955, dalam
	# #c9a227 (EMAS_DESAIN), titik tengah biru satpam.
	var lencana: Node3D = null
	if bool(outfit.get("lencana", false)):
		lencana = Node3D.new()
		lencana.name = "Lencana"
		var cakram_luar := Palette.cylinder(0.032, 0.032, 0.012, Vector3(0.09, 1.22, 0.19), Color("#e2b955"), 0.4)
		cakram_luar.rotation.x = PI / 2.0
		cakram_luar.name = "LencanaLuar"
		lencana.add_child(cakram_luar)
		var cakram_dalam := Palette.cylinder(0.018, 0.018, 0.006, Vector3(0.09, 1.22, 0.196), Color("#c9a227"), 0.4)
		cakram_dalam.rotation.x = PI / 2.0
		cakram_dalam.name = "LencanaDalam"
		lencana.add_child(cakram_dalam)
		var titik := Palette.sphere(0.007, Vector3(0.09, 1.22, 0.20), Color("#2b3a4a"))
		titik.name = "LencanaTitik"
		lencana.add_child(titik)
		root.add_child(lencana)

	# Nama di atas kepala — RONDE 5 (Mas: "Label nama tanpa outline..
	# kaya di game sepak bola gitu lo"): kecil, bersih, TANPA outline,
	# seperti nama pemain FIFA/eFootball (lihat Palette.label_nama).
	# Dulu font 32 + outline putih = gumpalan putih tidak terbaca.
	var name_label := Palette.label_nama(nama, Vector3(0, 2.12, 0))
	root.add_child(name_label)

	# BUBBLE-ML (Gita, 17 Nov 2026 — koreksi Mas ~21:30 WIB: bubble
	# kotak di atas kepala jelek): node bubble TETAP DIBUAT supaya
	# kontrak dict build_visual tidak berubah (pemakaian di
	# _pasang_visual + npc.gd setup), tapi SELALU tersembunyi — tidak
	# ada kode lagi yang menyalakan visible-nya. Pesan chat tampil di
	# feed melayang ui.gd (tampilkan_pesan_melayang), bukan di sini.
	var bubble := Palette.label3d("", Vector3(0, 2.50, 0), 22, Color("#065f46"), true, true)
	bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.width = 240.0
	bubble.visible = false
	root.add_child(bubble)

	# Shading lembut ala Roblox (18:49 WIB): semua bahan karakter
	# ke roughness 0.45 supaya ada kilap halus, bukan karton matte.
	_lembutkan(root)

	# KEPALA PIVOT (Kirana, 18 Nov 2026 — menoleh saat diam,
	# perintah Mas 21:50 WIB "kasih gerakan menoleh juga kalau
	# lagi diem"): kepala + wajah + penutup kepala (peci/serban/
	# rambut/kacamata) dikelompokkan di bawah satu pivot di leher
	# (0,1.66,0) supaya menoleh = putar pivot.rotation.y saja.
	# Posisi anak disesuaikan ke bingkai pivot (dikurangi posisi
	# pivot) — posisi DUNIA tiap bagian tidak berubah.
	# KOREKSI Mas 22:17 WIB ("Noleh itu sama kepala nya.. harusnya
	# jilbab ikut noleh"): jilbab SATU kain ikut di bawah pivot —
	# bukaan wajah berputar bersama wajah, jadi mata sisi jauh tidak
	# lagi ketutup tepi kain di puncak putaran (itu yang Mas bilang
	# aneh). Rok kain ikut berputar juga, tapi bentuknya hampir
	# simetri putar terhadap sumbu leher, jadi siluetnya nyaris
	# tidak berubah. Label nama + bubble tetap tidak ikut (bukan
	# bagian kepala). Cari rekursif aman: audit_karakter_primitif
	# memakai find_child (rekursif).
	var pivot_kepala := Node3D.new()
	pivot_kepala.name = "KepalaPivot"
	pivot_kepala.position = Vector3(0, 1.66, 0)
	root.add_child(pivot_kepala)
	for nama_bagian in ["Kepala", "MataKiri", "MataKanan", "Hidung", "Senyum", "AlisKiri", "AlisKanan", "Jenggot", "JenggotUban", "Kumis", "Rambut", "Serban", "Peci", "PeciBand", "Kacamata"]:
		var bagian := root.get_node_or_null(nama_bagian)
		if bagian != null:
			root.remove_child(bagian)
			pivot_kepala.add_child(bagian)
			bagian.position -= pivot_kepala.position
	# Jilbab ikut pivot (koreksi Mas 22:17 WIB) — node "Hijab"
	# (satu kain, posisi identitas di root) dipindah sama seperti
	# bagian kepala di atas; null untuk santriwan (tanpa hijab).
	var hijab_node := root.get_node_or_null("Hijab")
	if hijab_node != null:
		root.remove_child(hijab_node)
		pivot_kepala.add_child(hijab_node)
		hijab_node.position -= pivot_kepala.position

	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): Palette default
	# cast_shadow OFF — nyalakan lagi untuk bagian karakter yang
	# besar (>= 0,35 m: koko/sarung/kepala/jenggot/serban/songkok/
	# jilbab). Paha/lengan/sandal/betis/kitab tetap tanpa bayangan —
	# siluet karakter utuh dari torso + sarung + kepala; ambang 0,30 m
	# masih menyalakan ~22 mesh/karakter (194 total), 0,15 m dulu 325.
	# Semua karakter (pemain + NPC + remote MP) lewat build_visual
	# ini, jadi satu tempat cukup.
	var tumpuk: Array[Node] = [root]
	while not tumpuk.is_empty():
		var n: Node = tumpuk.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			var s: Vector3 = mi.get_aabb().size * mi.scale
			if maxf(maxf(s.x, s.y), s.z) >= 0.35:
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		for ch in n.get_children():
			tumpuk.append(ch)

	return {
		"root": root,
		"arm_l": arm_l,
		"arm_r": arm_r,
		"elbow_l": elbow_l,
		"elbow_r": elbow_r,
		"leg_l": leg_l,
		"leg_r": leg_r,
		"knee_l": knee_l,
		"knee_r": knee_r,
		"name_label": name_label,
		"bubble": bubble,
		"sandal_l": sandal_l,
		"sandal_r": sandal_r,
		"kitab_tangan": kitab_tangan,
		"kitab_pangku": kitab_pangku,
		# RONDE 21: siwak di tangan kanan (tersembunyi sampai idle
		# bersiwak) — untuk tes + terapkan_idle.
		"siwak": siwak,
		# RONDE 21b: pivot kepala (menoleh) — untuk tes + terapkan_idle.
		"kepala": pivot_kepala,
		"sarung": sarung,
		"sarung_hem": hem,
		"sarung_trim": sarung_trim,
		"lutut_l": lutut_l,
		"lutut_r": lutut_r,
		"drape": drape,
		"torso": torso,
		"peci": peci,
		"kacamata": kacamata,
		# RONDE 15: node Kyai (null untuk karakter biasa) — untuk tes.
		"serban": serban,
		"jenggot": jenggot,
		"jenggot_uban": uban,
		"kumis": kumis,
		# RONDE 20: node hijab Ustadzah Mariyah (null untuk yang lain).
		"hijab": hijab,
		# SUSULAN RONDE 20: node abaya + flag muslimah (null/false
		# untuk yang lain) — untuk tes + pemakaian ulang santriwati.
		"abaya": abaya,
		"muslimah": muslimah,
		# SERAGAM UTAMA v2: flag tunik (santriwati baju+sarung, bukan
		# abaya) — untuk tes + pemetaan PAKAIAN NPC + sinkron MP.
		"tunik": tunik,
		# KARAKTER PRIMITIF: node lencana satpam (null untuk yang lain).
		"lencana": lencana,
	}


## Kacamata (RONDE 11): bingkai hitam + lensa bening. Tiap lensa =
## bingkai kotak (4 batang tipis) + kaca lensa tembus pandang
## (alpha 0.35 supaya mata tetap terlihat) di depan mata; jembatan
## di atas hidung + 2 gagang ke arah telinga. Posisi dihitung dari
## mata (±0.085, 1.69, 0.222): bingkai 0.11 x 0.08 di z=0.24 (1-2 cm
## di depan permukaan wajah — wajar untuk kacamata), gagang ke
## belakang sampai permukaan kepala (z~0.19 di x=±0.14).
## KARAKTER PRIMITIF (Kirana, 17 Nov 2026): KACAMATA BUNDAR — bingkai
## kotak + lensa kotak diganti cincin TORUS (luar r=0.06, dalam
## r=0.048, menghadap +Z) + lensa CAKRAM (silinder r=0.05, bening
## alpha 0.35) + jembatan + gagang kapsul. Sesuai lembar konsep
## ("kacamata bundar besar"). Amplop AABB tetap: depan z 0.246,
## gagang sampai z 0.14 (audit: depan 0.23..0.32, z min > 0.05).
static func _kacamata() -> Node3D:
	var g := Node3D.new()
	g.name = "Kacamata"
	var bingkai := Palette.mat(Color("#171717"), 0.0, 0.35)
	var lensa_mat := StandardMaterial3D.new()
	lensa_mat.albedo_color = Color(0.12, 0.16, 0.22, 0.35)
	lensa_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lensa_mat.roughness = 0.1
	for sx in [-1.0, 1.0]:
		var cx: float = sx * 0.085
		var cincin := MeshInstance3D.new()
		var cincin_mesh := TorusMesh.new()
		cincin_mesh.inner_radius = 0.048
		cincin_mesh.outer_radius = 0.06
		cincin_mesh.rings = 32
		cincin_mesh.ring_segments = 12
		cincin.mesh = cincin_mesh
		cincin.position = Vector3(cx, 1.69, 0.24)
		cincin.rotation.x = PI / 2.0
		cincin.material_override = bingkai
		g.add_child(cincin)
		var lensa := MeshInstance3D.new()
		var lensa_mesh := CylinderMesh.new()
		lensa_mesh.top_radius = 0.05
		lensa_mesh.bottom_radius = 0.05
		lensa_mesh.height = 0.006
		lensa.mesh = lensa_mesh
		lensa.position = Vector3(cx, 1.69, 0.238)
		lensa.rotation.x = PI / 2.0
		lensa.material_override = lensa_mat
		g.add_child(lensa)
		var gagang := Palette.capsule(0.008, 0.10, Vector3(sx * 0.145, 1.70, 0.19), Color("#171717"))
		gagang.rotation.x = PI / 2.0
		g.add_child(gagang)
	var jembatan := Palette.capsule(0.008, 0.055, Vector3(0, 1.71, 0.24), Color("#171717"))
	jembatan.rotation.z = PI / 2.0
	g.add_child(jembatan)
	return g


func set_facing(yaw: float) -> void:
	_visual.rotation.y = yaw


## Arah hadap karakter (radian, 0 = utara/-Z) — untuk minimap GTA.
func get_facing_yaw() -> float:
	return _visual.rotation.y


func set_nama(nama: String) -> void:
	# MULTIPLAYER FASE 1 — L7: fungsi ini dipakai avatar LOKAL (nama
	# dari login, main.gd:993). Untuk avatar pemain LAIN, spawner
	# memanggil set_nama_spawn() (nama dari DB server) — JANGAN pakai
	# fungsi ini untuk nama kiriman klien.
	_nama = nama
	# Label nama adalah Label3D di y=2.05 (dulu bubble chat di y=2.45
	# — BUBBLE-ML: bubble dimatikan, hanya label nama yang dicari).
	for c in _visual.get_children():
		if c is Label3D and c.position.y > 2.0 and c.position.y < 2.2:
			(c as Label3D).text = nama
			return


## MULTIPLAYER FASE 1 — L7: nama dari data spawn server (nama DB).
## Dipanggil spawner saat avatar pemain lain dibuat — nama SELALU dari
## DB terverifikasi (tiket realtime), BUKAN dari kiriman klien dan
## BUKAN dari save_data lokal. Untuk avatar lokal sendiri, nama tetap
## dari login seperti sekarang (main.gd memanggil set_nama()).
func set_nama_spawn(nama: String) -> void:
	set_nama(nama)


## Ganti outfit (RONDE 6): warnai ulang bagian koko/songkok/sarung
## di tempat (tanpa membangun ulang visual) — dipakai panel Ganti
## Baju di kamar cangkruk. outfit = {"koko": hex, "songkok": hex,
## "sarung": hex} (lihat MissionData.OUTFIT_DEFAULT).
func terapkan_outfit(outfit: Dictionary) -> void:
	_outfit = outfit.duplicate()
	var koko: Color = Color(String(outfit.get("koko", "#faf7f0")))
	var songkok: Color = Color(String(outfit.get("songkok", "#faf7f0")))
	var sarung_color: Color = Color(String(outfit.get("sarung", "#0b6b4f")))
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): untuk
	# muslimah, torso + lengan sewarna abaya (bukan koko) — sama
	# seperti build_visual. Kerah tidak ada pada muslimah.
	# SERAGAM UTAMA v2: tunik memakai warna koko (biru langit).
	var muslimah: bool = bool(outfit.get("muslimah", false))
	var tunik: bool = bool(outfit.get("tunik", false))
	var warna_abaya: Color = Color(String(outfit.get("abaya", "#065f46")))
	var warna_baju: Color = koko if (not muslimah or tunik) else warna_abaya
	# RONDE 11: cari node REKURSIF (find_child), bukan get_node_or_null
	# — dulu "BahuKiri"/"LenganAtasKiri" dll TIDAK PERNAH ketemu karena
	# mereka anak dari pivot lengan (bukan anak langsung visual), jadi
	# ganti koko hanya mewarnai torso + kerah, lengan tetap putih.
	# Temuan laten saat mengerjakan kulit; kini semua bagian terwarnai.
	for nama_node in ["Torso", "Kerah", "BahuKiri", "BahuKanan", "SikuKiri", "SikuKanan", "LenganAtasKiri", "LenganAtasKanan", "LenganBawahKiri", "LenganBawahKanan"]:
		var n := _visual.find_child(nama_node, true, false)
		if n is MeshInstance3D:
			# KARAKTER PRIMITIF: bagian kain tetap kain jersey saat
			# ganti baju (bukan kembali ke Palette.mat polos).
			(n as MeshInstance3D).material_override = _bahan_kain(warna_baju)
	# KONSEP SONGKOK v1 (Kirana, 19 Nov 2026 — ACC Mas 14:07): peci
	# nasional SELALU hitam (#151515, lis #0d0d0d) apa pun warna
	# "songkok" outfit — jangan diwarnai ulang jadi putih.
	var model_peci: String = String(outfit.get("peci_model", "bulat"))
	var peci := _visual.find_child("Peci", true, false)
	if peci is MeshInstance3D:
		var warna_peci: Color = Color("#151515") if model_peci == "nasional" else songkok
		(peci as MeshInstance3D).material_override = Palette.mat(warna_peci, 0.0, 0.45)
	# RONDE 9: lis songkok ikut warna songkok (sedikit lebih gelap).
	var peci_band := _visual.find_child("PeciBand", true, false)
	if peci_band is MeshInstance3D:
		var warna_lis: Color = Color("#0d0d0d") if model_peci == "nasional" else songkok.darkened(0.12)
		(peci_band as MeshInstance3D).material_override = Palette.mat(warna_lis, 0.0, 0.45)
	var sarung := _visual.find_child("Sarung", true, false)
	if sarung is MeshInstance3D:
		# SERAGAM UTAMA v2: motif dari kunci "sarung_motif".
		(sarung as MeshInstance3D).material_override = _bahan_sarung(outfit)
	# TONJOLAN LUTUT BERSILA: bahan ikut sarung/abaya saat ganti outfit.
	var pakai_abaya_warna: bool = muslimah and not tunik
	for nama_lutut in ["TonjolanLututKiri", "TonjolanLututKanan"]:
		var nl := _visual.find_child(nama_lutut, true, false)
		if nl is MeshInstance3D:
			(nl as MeshInstance3D).material_override = _bahan_kain(warna_abaya) if pakai_abaya_warna else _bahan_sarung(outfit)
	# DRAPE BERSILA v3: bahan ikut sarung/abaya saat ganti outfit.
	var drape_node := _visual.find_child("SarungDrape", true, false)
	if drape_node is MeshInstance3D:
		(drape_node as MeshInstance3D).material_override = _bahan_kain(warna_abaya) if pakai_abaya_warna else _bahan_sarung(outfit)
	var hem := _visual.find_child("SarungHem", true, false)
	if hem is MeshInstance3D:
		(hem as MeshInstance3D).material_override = Palette.mat(_hem_sarung_warna(outfit), 0.0, 0.45)
	# RONDE 11: warna kulit — kepala + hidung + tangan + kaki.
	var kulit: Color = Color(String(outfit.get("kulit", "#c68e5e")))
	for nama_kulit in ["Kepala", "Hidung", "TanganKiri", "TanganKanan", "KakiKiri", "KakiKanan"]:
		var nk := _visual.find_child(nama_kulit, true, false)
		if nk is MeshInstance3D:
			(nk as MeshInstance3D).material_override = Palette.mat(kulit, 0.0, 0.45)
	# RONDE 11: kacamata — tampil/sembunyi.
	var kc := _visual.find_child("Kacamata", true, false)
	if kc != null:
		kc.visible = bool(outfit.get("kacamata", false))
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): warnai
	# ulang abaya + jilbab di tempat. Node ini hanya ada pada visual
	# muslimah — find_child mengembalikan null untuk santriwan, jadi
	# aman. Lis emas AbayaTrim sengaja tidak diwarnai (tetap emas).
	for nama_abaya in ["Abaya", "AbayaHem"]:
		var na := _visual.find_child(nama_abaya, true, false)
		if na is MeshInstance3D:
			(na as MeshInstance3D).material_override = _bahan_kain(warna_abaya)
	var warna_hijab: Color = Color(String(outfit.get("hijab_warna", "#f2ead6")))
	# REBUILD (Kirana, 18 Nov 2026): jilbab kini SATU mesh prosedural
	# "HijabKerudung" — semua node primitif lama dihapus, daftar
	# warna-sama tinggal satu entri (bahan double-sided).
	for nama_hijab in ["HijabKerudung"]:
		var nh := _visual.find_child(nama_hijab, true, false)
		if nh is MeshInstance3D:
			(nh as MeshInstance3D).material_override = _bahan_jilbab(warna_hijab)

	# MULTIPLAYER FASE 1 — L4: cermin outfit ke properti sync (ON_CHANGE).
	self.outfit = _outfit.duplicate()


func outfit_saat_ini() -> Dictionary:
	return _outfit.duplicate()


## Sandal dilepas/dipakai (RONDE 6, Mas: sandal dilepas kalau masuk
## ruangan): sembunyikan/tampilkan sandal di kedua kaki.
func set_sandal(pakai: bool) -> void:
	if _sandal_l != null:
		_sandal_l.visible = pakai
	if _sandal_r != null:
		_sandal_r.visible = pakai


func sandal_dipakai() -> bool:
	return _sandal_l != null and _sandal_l.visible


# ---------- aksi / pose (RONDE 6) ----------
func set_aksi(nama: String) -> void:
	# "bawa_kitab" adalah TOGGLE yang tidak mengubah pose dasar —
	# kitab di tangan tetap dibawa sambil berdiri/berjalan.
	if nama == "bawa_kitab":
		_bawa_kitab = not _bawa_kitab
		if _kitab_tangan != null:
			_kitab_tangan.visible = _bawa_kitab
		return
	_set_aksi_visual(nama)
	# MULTIPLAYER FASE 1 — L6: pemilik mengeset pose_id saat aksi
	# berubah (bawa_kitab toggle tidak mengubah pose — lihat atas).
	var pid := PoseIds.dari_aksi(nama)
	if pid >= 0:
		pose_id = pid


## MULTIPLAYER FASE 1 — L6: terapkan aksi ke visual TANPA menyentuh
## pose_id. Dipakai _sinkron_aksi_dari_pose_id (avatar remote): pose_id
## remote adalah milik synchronizer — tulisan lokal ke pose_id akan
## menimpa nilai kiriman pemilik dan TIDAK diperbaiki sampai pemilik
## ganti pose lagi (replikasi ON_CHANGE cuma kirim saat nilai PEMILIK
## berubah). Isi = badan set_aksi lama yang dipindah utuh ke sini.
func _set_aksi_visual(nama: String) -> void:
	_aksi = nama
	# DUDUK KURSI (Kirana, 20 Nov 2026 — bug 4): keluar dari
	# duduk_kursi lewat jalur APA PUN (teleport/reset/sholat/Aksi)
	# WAJIB mengembalikan collision + membersihkan state kursi —
	# tanpa ini pemain yang di-teleport saat duduk di kursi tetap
	# beku + tembus. Posisi TIDAK digeser di sini (berdiri_dari_kursi
	# yang menggeser ke "bangun"); jalur lain memang memindahkan
	# pemain sendiri (teleport/reset/sholat).
	if nama != "duduk_kursi" and not _kursi_duduk.is_empty():
		_aktifkan_fisik_duduk()
		_kursi_duduk = {}
	# RONDE 18: pose "sholat" kini TAKBIR statis (bukan siklus) —
	# tidak ada timer yang perlu di-reset.
	# RONDE 8 (retest: pose 5 dtk terlalu singkat — penguji mengecek 20
	# dtk kemudian dan mengira pose tidak jalan): salaman/melambai
	# TIDAK auto-reset lagi; tahan sampai pemain bergerak (main.gd
	# memanggil set_aksi("berdiri") saat ada input gerak) atau menekan
	# Berdiri. Dulu: _aksi_timer = 5.0 untuk salaman/melambai.
	_aksi_timer = 0.0
	if _kitab_pangku != null:
		_kitab_pangku.visible = nama == "menulis"
	if nama == "berdiri":
		# Kembalikan rotasi yang hanya dipakai pose (silang kaki saat
		# duduk, lambaian) supaya animasi jalan/idle mulai dari nol.
		# Lengan kembali menggantung sedikit menjauh dari badan
		# (rotasi z ±0.05 — posisi natural lengan, bukan 0).
		_leg_l.rotation.z = 0.0
		_leg_r.rotation.z = 0.0
		_leg_l.rotation.y = 0.0
		_leg_r.rotation.y = 0.0
		_knee_l.rotation.x = 0.0
		_knee_r.rotation.x = 0.0
		_knee_l.rotation.y = 0.0
		_knee_r.rotation.y = 0.0
		_knee_l.rotation.z = 0.0
		_knee_r.rotation.z = 0.0
		_arm_r.rotation.z = -0.05
		_arm_l.rotation.z = 0.05
		_elbow_l.rotation.x = 0.0
		_elbow_r.rotation.x = 0.0


func aksi_saat_ini() -> String:
	return _aksi


func bawa_kitab_aktif() -> bool:
	return _bawa_kitab


## Pose yang menahan gerak (duduk/menulis/tidur/salaman/melambai/
## sholat/duduk_kursi): main.gd menolkan input gerak selama pose ini
## supaya pose tidak rusak oleh animasi jalan. Berdiri + bawa kitab
## boleh jalan.
func sedang_aksi_diam() -> bool:
	return _aksi in ["duduk", "menulis", "tidur", "salaman", "melambai", "sholat", "duduk_kursi"]


## DUDUK KURSI — API untuk Gilang (wiring kursi pemain) + Laras
## (adegan tes di dalam kantor). Dipanggil main.gd saat pemain menekan
## DUDUK di dekat kursi terdaftar (scripts/kursi_pemain.gd).
## - "kursi" -> pose "duduk_kursi" (kaki menjuntai);
##   "bersila"/"kasur" -> pose "duduk" (bersila, visual ikut tinggi).
## - Node dipindah ke TANAH di x,z kursi (y = lantai_y) — TIDAK
##   PERNAH di atas kursi; visual yang naik ke tinggi duduk.
## - Fisika dibekukan + collision dimatikan selama duduk (kotak
##   collision bangku 0,5 m akan mendorong kapsul keluar).
func duduk_di_kursi(kursi: Dictionary) -> void:
	if kursi.is_empty():
		return
	var jenis := String(kursi.get("jenis", "kursi"))
	# URUTAN PENTING: set_aksi DULU, baru isi _kursi_duduk — jaring
	# pengaman di _set_aksi_visual membersihkan state kursi setiap
	# kali aksi berubah ke selain "duduk_kursi"; kalau state sudah
	# terisi saat set_aksi("duduk") dipanggil (jalur bersila/kasur),
	# jaring itu langsung menghapus kursi yang baru saja diduduki
	# (fisika tidak beku, bangun tidak jalan — terukur di tes).
	set_aksi("duduk_kursi" if jenis == "kursi" else "duduk")
	var pos: Vector3 = kursi["pos"]
	var lantai_y := float(kursi.get("lantai_y", 0.0))
	_kursi_duduk = kursi.duplicate()
	_kursi_tinggi_duduk = pos.y - lantai_y
	global_position = Vector3(pos.x, lantai_y, pos.z)
	_visual.rotation.y = float(kursi.get("yaw", 0.0))
	_nonaktifkan_fisik_duduk()


## Berdiri dari kursi (bug 4 Mas): turun ke lantai DI DEPAN kursi —
## titik "bangun" dari registry (kelas: lorong, BUKAN ke arah meja;
## madrasah/studio: belakang kursi; kasur: 1,5 m selatan kaki).
## Tanpa "bangun" (entry lama): 0,8 m ke arah hadap. Collision
## diaktifkan lagi SETELAH pindah (supaya tidak terdorong bangku).
func berdiri_dari_kursi() -> void:
	if _kursi_duduk.is_empty():
		set_aksi("berdiri")
		return
	var bangun: Vector3
	if _kursi_duduk.has("bangun"):
		bangun = _kursi_duduk["bangun"]
	else:
		var depan := Vector3(sin(_visual.rotation.y), 0.0, cos(_visual.rotation.y))
		bangun = global_position + depan * 0.8
		bangun.y = float(_kursi_duduk.get("lantai_y", 0.0))
	velocity = Vector3.ZERO
	global_position = bangun
	_kursi_duduk = {}
	_aktifkan_fisik_duduk()
	set_aksi("berdiri")


## Kursi yang sedang diduduki ({} bila tidak duduk di kursi) —
## dipakai main.gd untuk label/tombol DUDUK + wiring tes kantor.
func kursi_duduk() -> Dictionary:
	return _kursi_duduk


func _bentuk_fisik() -> CollisionShape3D:
	for c in get_children():
		if c is CollisionShape3D:
			return c
	return null


func _nonaktifkan_fisik_duduk() -> void:
	var b := _bentuk_fisik()
	if b != null:
		b.set_deferred("disabled", true)


func _aktifkan_fisik_duduk() -> void:
	var b := _bentuk_fisik()
	if b != null:
		b.set_deferred("disabled", false)


## Pemain memakai abaya (muslimah tanpa tunik)? Dipakai _terapkan_pose
## untuk memilih varian pakaian duduk/kursi yang benar.
func _pakai_abaya() -> bool:
	return bool(_outfit.get("muslimah", false)) and not bool(_outfit.get("tunik", false))


## BUBBLE-ML (Gita, 17 Nov 2026): bubble 3D DIMATIKAN — fungsi ini
## kini NO-OP yang dipertahankan supaya main.gd _on_chat_sent (baris
## ~1522) tetap jalan sampai Raka memasang reroute ke
## _ui.tampilkan_pesan_melayang(nama, teks). Pesan pemain TIDAK lagi
## tampil di atas kepala.
func show_chat(teks: String, durasi: float = 5.0) -> void:
	pass


# RONDE 7: bubble ditahan selama panel chat terbuka — BUBBLE-ML:
# fungsi dipertahankan (main.gd:856 memanggilnya tiap frame) tapi
# kini NO-OP: tidak ada lagi bubble yang perlu ditahan. Flag disimpan
# saja supaya pemanggil lama tidak pecah.
var _bubble_ditahan: bool = false


func set_bubble_ditahan(ditahan: bool) -> void:
	_bubble_ditahan = ditahan


## RONDE 8: label nama ditahan saat panel chat terbuka (retest: panel
## chat memotong label nama "Tes" jadi setengah — label nama adalah
## Label3D terpisah, jadi butuh flag sendiri).
var _nama_ditahan: bool = false


## RONDE 8: sembunyikan label nama saat panel chat terbuka (dipanggil
## main.gd tiap frame dari _ui.is_chat_visible(), seperti bubble).
func set_nama_ditahan(ditahan: bool) -> void:
	_nama_ditahan = ditahan


## RONDE PERBAIKAN (Eka) — label NAMA + BUBBLE terpotong tembok:
## Label3D billboard berpusat di pemain; saat pemain menempel tembok
## (jarak pusat label ke muka tembok cuma 0,35 m = radius kapsul)
## sementara lebar label ~0,9 m ("Uji Putri"), ujung label MASUK ke
## dalam tembok dan tertutup (no_depth_test=false) — retest Ronde 23:
## "Uji Putr". Perbaikan: raycast pendek dari tengah label ke kiri +
## kanan (sumbu horizontal billboard = kanan kamera); kalau ada dinding
## dalam jangkauan setengah lebar, label DIKECILKAN sampai kedua
## ujungnya muat di depan dinding. Tidak pernah membesar, hanya
## mengecil (skala min 0,08). Dipanggil tiap frame setelah
## batasi_label_kamera (yang mengatur skala dasar dari jarak kamera).
## Dipakai pemain (di bawah) + NPC (npc.gd).
static func _batasi_label_dinding(label: Label3D, cam: Camera3D, ruang: PhysicsDirectSpaceState3D, kecualikan: RID = RID()) -> void:
	if label == null or cam == null or ruang == null or not label.visible:
		return
	var setengah := label.get_aabb().size.x * 0.5 * label.scale.x
	if setengah <= 0.01:
		return
	var tengah := label.global_position
	var kanan := cam.global_transform.basis.x
	kanan.y = 0.0
	kanan = kanan.normalized()
	var muat := setengah
	for arah in [1.0, -1.0]:
		var q := PhysicsRayQueryParameters3D.create(tengah, tengah + kanan * arah * (setengah + 0.05))
		q.collision_mask = 1
		if kecualikan.is_valid():
			q.exclude.append(kecualikan)
		var hit := ruang.intersect_ray(q)
		if not hit.is_empty():
			var jarak: float = tengah.distance_to(hit["position"])
			muat = minf(muat, maxf(0.05, jarak - 0.05))
	if muat < setengah:
		var s := clampf(label.scale.x * (muat / setengah), 0.08, label.scale.x)
		label.scale = Vector3.ONE * s


## MULTIPLAYER FASE 1 — L2: SATU-SATUNYA tempat "input" dibaca di file
## ini. Isinya HANYA `move_dir` (ditulis main.gd dari joystick/keyboard,
## sudah relatif-kamera) + normalisasi bila panjang > 1. Visual
## (build_visual, ganti pose/animasi, label nama) TIDAK BOLEH memanggil
## fungsi ini — visual hanya membaca keadaan (`_aksi`, `pose_id`, `v`
## yang sudah dibaca di sini). Gerbang otoritas ada di L3 (di bawah).
func _baca_input() -> Vector3:
	# MULTIPLAYER FASE 1 — L3: pengaman ganda — avatar remote tidak
	# pernah membaca input, sekalipun ada yang menulis move_dir-nya.
	if not is_multiplayer_authority():
		return Vector3.ZERO
	var v := move_dir
	if v.length() > 1.0:
		v = v.normalized()
	return v


## MULTIPLAYER FASE 1 — L6: pemilik mengeset pose_id saat keadaannya
## berubah. Dipanggil tiap frame fisika (dan langsung di set_aksi saat
## aksi diganti dari UI/main). Jalan = bergerak (v > 0,1), bukan aksi.
func _perbarui_pose_id(v: Vector3) -> void:
	if sedang_aksi_diam():
		var pid := PoseIds.dari_aksi(_aksi)
		if pid >= 0:
			pose_id = pid
	elif v.length() > 0.1:
		pose_id = PoseIds.POSE_JALAN
	else:
		pose_id = PoseIds.POSE_IDLE


## MULTIPLAYER FASE 1 — L6: avatar remote menyelaraskan _aksi string-nya
## dari pose_id yang diterima synchronizer — supaya _terapkan_pose(),
## sedang_aksi_diam(), dan logika label (tidur) yang membaca _aksi
## tetap jalan tanpa diubah. POSE_JALAN bukan aksi (lihat PoseIds):
## _aksi kembali "berdiri", jalan dibaca dari pose_id di
## _jalankan_animasi_visual. Memakai _set_aksi_visual (BUKAN set_aksi)
## supaya pose_id TIDAK pernah ditimpa tulisan lokal. Hanya dipanggil
## dari _process bila BUKAN otoritas.
func _sinkron_aksi_dari_pose_id() -> void:
	if pose_id == PoseIds.POSE_JALAN:
		if sedang_aksi_diam():
			_set_aksi_visual("berdiri")
		return
	var nama := PoseIds.ke_aksi(pose_id)
	if nama != _aksi:
		_set_aksi_visual(nama)


## MULTIPLAYER FASE 1 — L6: SATU jalur animasi visual untuk pemilik DAN
## avatar remote — dipicu keadaan/pose_id, BUKAN input langsung.
## Pemilik memanggil dari _physics_process (bergerak = v > 0,1);
## avatar remote dari _process (bergerak = pose_id == POSE_JALAN).
## Isi = kode animasi lama yang dipindah UTUH dari _physics_process
## (pose diam -> _terapkan_pose; jalan/idle via AnimasiMixamo; kitab;
## pakaian normal). `langkah` ikut dipancarkan untuk remote — tidak
## ada yang mendengarkan signal avatar remote (main.gd hanya connect
## _player lokal), jadi tidak ada bunyi langkah ganda.
## Siwak disembunyikan di luar gerakan bersiwak (pose diam/kitab).
func _sembunyikan_siwak() -> void:
	var siwak := _rig.get("siwak") as Node3D
	if siwak != null:
		siwak.visible = false


func _jalankan_animasi_visual(delta: float, bergerak: bool) -> void:
	# Pose diam (duduk/menulis/tidur/salaman/melambai/sholat) menggantikan
	# animasi jalan — anggota gerak di-lerp ke target pose.
	if sedang_aksi_diam():
		_sembunyikan_siwak()
		_terapkan_pose(delta)
		return
	# ANIMASI-MIXAMO: jalan + idle kini lewat modul AnimasiMixamo
	# (kurva mocap: lutut menekuk 2x per siklus, lengan berlawanan
	# fase dengan kaki, bob pinggul TURUN saat kontak, idle RONDE 10:
	# badan diam total, hanya lengan + bersiwak). Laju fase tetap 9,0 rad/dtk seperti
	# sebelumnya supaya rasa geraknya tidak berubah — dan deteksi
	# SFX langkah di bawah tetap benar: kontak kaki terjadi saat
	# fase ≡ 0 (mod PI), tepat saat sin(_walk_time) melewati nol.
	_idle_t += delta
	if bergerak:
		_anim_blend = minf(1.0, _anim_blend + delta * 6.0)
		_walk_time += delta * 9.0
		# SFX LANGKAH: kaki menyentuh tanah saat sin melewati nol.
		# Hanya bila ayunan sudah cukup terbentuk (blend > 0,3)
		# supaya langkah pertama yang masih pelan tidak berbunyi.
		var sin_kini := sin(_walk_time)
		if _anim_blend > 0.3 and _langkah_sin_sebelum != 0.0 and signf(sin_kini) != signf(_langkah_sin_sebelum):
			langkah.emit()
		_langkah_sin_sebelum = sin_kini
		AnimasiMixamo.terapkan_jalan(_rig, _walk_time, _anim_blend)
	else:
		_anim_blend = maxf(0.0, _anim_blend - delta * 8.0)
		# RONDE 21b: siwak + menoleh HANYA saat idle murni —
		# ditekan saat panel misi (dialog/RB/tes) terbuka. Avatar
		# remote (bukan authority) tidak membaca UI lokal — tetap
		# idle biasa (dialog pemain lokal bukan urusan mereka).
		var dialog := false
		if is_multiplayer_authority():
			dialog = AnimasiMixamo.panel_misi_terbuka(get_tree())
		AnimasiMixamo.terapkan_idle(_rig, delta, _idle_t, 0.0, dialog)
	# Bawa kitab (toggle): tangan kanan sedikit ke depan memegang
	# kitab — menimpa ayunan/idle lengan kanan (tangan kiri tetap
	# mengayun normal). Siku kanan menekuk memegang kitab.
	if _bawa_kitab:
		_sembunyikan_siwak()
		_arm_r.rotation.x = -0.55 - sin(_walk_time) * 0.1 * _anim_blend
		_elbow_r.rotation.x = -0.5
	# RONDE 9: di luar pose diam, kembalikan pakaian ke normal
	# (sarung mengerut saat duduk, sarung+torso pipih saat tidur —
	# tanpa ini pakaian pose terakhir menempel saat berdiri/jalan).
	# Dijalankan di sini karena fungsi ini return lebih awal saat
	# sedang_aksi_diam(), jadi baris ini hanya jalan di luar pose diam.
	_lerp_pakaian(delta, PAKAIAN_DEFAULT)


func _physics_process(delta: float) -> void:
	# MULTIPLAYER FASE 1 — L3: avatar remote tidak membaca input dan
	# tidak menjalankan fisika — posisinya datang dari synchronizer
	# (L4) + interpolasi di _process (L5).
	if not is_multiplayer_authority():
		return
	var v := _baca_input()
	if not _kursi_duduk.is_empty():
		# DUDUK KURSI (Kirana, 20 Nov 2026): fisika BEKU selama duduk
		# di kursi — gravitasi + move_and_slide dimatikan supaya badan
		# (collision dimatikan) tidak jatuh/melorot dari kursi; pose
		# dipertahankan _terapkan_pose. Input sudah nol via main.gd
		# (sedang_aksi_diam), v dinolkan juga supaya hadap + pose_id
		# tidak berubah.
		v = Vector3.ZERO
		velocity = Vector3.ZERO
	else:
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		else:
			velocity.y = -0.5
		velocity.x = v.x * SPEED
		velocity.z = v.z * SPEED
		move_and_slide()
	# Hadap ke arah gerak (putar visual dengan halus).
	if v.length() > 0.1 and not sedang_aksi_diam():
		var target_yaw := atan2(v.x, v.z)
		# RONDE 5: bobot lerp dijepit ke 1.0 (alasan sama seperti rig
		# kamera di main.gd — di frame lambat, delta*10 > 1 membuat
		# visual berputar melewati target lalu berosilasi).
		_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, minf(1.0, delta * 10.0))
	# MULTIPLAYER FASE 1 — L4: pemilik mengisi sync_position/sync_yaw
	# dari keadaan lokal (pose_id diisi L6 di bawah, sebelum animasi).
	_isi_properti_sync()
	# Pose berwaktu (salaman/melambai 3 detik) kembali berdiri sendiri.
	if _aksi_timer > 0.0:
		_aksi_timer -= delta
		if _aksi_timer <= 0.0:
			set_aksi("berdiri")
	# MULTIPLAYER FASE 1 — L6: pemilik mengeset pose_id dari keadaan
	# (aksi diam / bergerak / diam), lalu SEMUA avatar memainkan
	# animasi visual dari pose_id — lewat _jalankan_animasi_visual.
	_perbarui_pose_id(v)
	_jalankan_animasi_visual(delta, v.length() > 0.1)


## Sudut lengan kanan ke dalam saat salaman (Raka, 20 Nov 2026 —
## verdict Mas "Kok tidak jabat tangan?"): bahu kanan di |x| =
## lengan_x, jangkau tangan ~0,59 m (lengan atas 0,30 + bawah 0,29).
## Dulu rotation.z -0,05 = lengan lurus ke depan — tangan kanan
## kedua pihak terpaut ~0,5 m secara lateral (kanan masing-masing
## ada di sisi berlawanan saat berhadapan), jadi tidak pernah
## bertemu. Sudut ini membawa tangan tepat ke garis tengah badan.
const SALAMAN_JANGKAU_TANGAN := 0.59


static func sudut_salaman_dalam(lengan_x: float) -> float:
	return asin(clampf(absf(lengan_x) / SALAMAN_JANGKAU_TANGAN, 0.0, 0.9))


## Pose prosedural (RONDE 6): semua target di-lerp halus (bobot
## dijepit 1.0) supaya perubahan pose tidak patah.
func _terapkan_pose(delta: float) -> void:
	var k := minf(1.0, delta * 8.0)
	# RONDE 21b: kepala kembali tegak saat pose diam (jangan
	# menempel menoleh dari idle).
	var kepala := _rig.get("kepala") as Node3D
	if kepala != null:
		kepala.rotation.y = lerpf(kepala.rotation.y, 0.0, k)
	match _aksi:
		"duduk":
			# Duduk bersila RONDE DUDUK (17 Nov — Mas: cara duduk semua
			# karakter perlu direvisi): paha TIDAK lagi diputar -1.35
			# sebagai batang kaku — paha hanya -0.85 (lutut mendarat
			# di lantai, bukan menusuk ke depan) dan LUTUT melipat
			# +2.30 sehingga betis terlipat ke bawah paha, kaki
			# menyilang (yaw lutut searah paha) — bersila TERBACA
			# dari depan/samping; tangan beristirahat di pangkuan
			# (lengan -0.35, siku -0.20), bukan melayang di dada.
			# ANIMASI-MIXAMO: sekuens transisi duduk ala mocap — kaki
			# melipat DULU (k_kaki cepat), badan menyusul, tangan
			# TERAKHIR ke pangkuan (k_tangan lambat); sebelumnya semua
			# bergerak serentak sehingga transisi terasa "teleport".
			# REVISI BERSILA v2 (Kirana, 20 Nov 2026 — bug 2 Mas):
			# yaw kaki DIBALIK — dulu kaki kiri +0.50 / kanan -0.50
			# membuat KEDUA LUTUT BERTEMU di tengah depan (x≈0),
			# alasnya sempit seperti kerucut; kini kiri -0.50 /
			# kanan +0.50 (lutut MELEBAR ke samping ±0,22, betis
			# menyilang di bawah paha) — alas bersila yang lebar,
			# seperti orang bersila beneran. z + yaw lutut ikut
			# dibalik supaya lipatan tetap searah.
			# Tinggi visual ikut _kursi_tinggi_duduk bila duduk via
			# duduk_di_kursi("kasur") — kasur 0,51 -> visual +0,09
			# (pinggul 0,71); duduk biasa/bersila -> -0,42.
			var k_kaki := minf(1.0, delta * 12.0)
			var k_tangan := minf(1.0, delta * 5.0)
			var duduk_y := -0.42 if _kursi_duduk.is_empty() else _kursi_tinggi_duduk - 0.42
			_visual.position.y = lerpf(_visual.position.y, duduk_y, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
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
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.35, k_tangan)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.35, k_tangan)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k_tangan)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k_tangan)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.20, k_tangan)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.20, k_tangan)
			_lerp_pakaian(delta, PAKAIAN_ABAYA_DUDUK if _pakai_abaya() else PAKAIAN_DUDUK)
		"duduk_kursi":
			# DUDUK KURSI (Kirana, 20 Nov 2026 — bug 3 Mas: "duduk
			# di kursi malah bersila di kursi"): kaki MENJUNTAI,
			# bukan bersila — paha hampir horizontal ke depan
			# (-1.45), betis vertikal ke bawah (lutut +1.45),
			# telapak menggantung ~13 cm di atas lantai (betis rig
			# cuma 0,28 m — memang menjuntai, sesuai kata Mas).
			# Pinggul di tinggi kursi: visual = _kursi_tinggi_duduk
			# - 0,62 (kursi 0,45 -> -0,17). Badan tegak condong
			# 0,05; tangan di pangkuan (lengan -0,50, siku -0,30).
			var k_kaki_k := minf(1.0, delta * 12.0)
			var k_tangan_k := minf(1.0, delta * 5.0)
			_visual.position.y = lerpf(_visual.position.y, _kursi_tinggi_duduk - 0.62, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.05, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -1.45, k_kaki_k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -1.45, k_kaki_k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k_kaki_k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k_kaki_k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.06, k_kaki_k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, -0.06, k_kaki_k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 1.45, k_kaki_k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 1.45, k_kaki_k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k_kaki_k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k_kaki_k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k_kaki_k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k_kaki_k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.50, k_tangan_k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.50, k_tangan_k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k_tangan_k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k_tangan_k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.30, k_tangan_k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.30, k_tangan_k)
			_lerp_pakaian(delta, PAKAIAN_ABAYA_KURSI if _pakai_abaya() else PAKAIAN_KURSI)
		"menulis":
			# Menulis RONDE DUDUK: kaki sama seperti duduk (paha -0.85,
			# lutut +2.30 — bersila terlipat, bukan batang kaku);
			# badan membungkuk 0.20 ke kitab; tangan MENULIS (lengan
			# -0.50, siku -0.50) sampai ke kitab di pangkuan, bukan
			# melayang di dada; tangan kanan menulis bergoyang.
			_menulis_t += delta
			# ANIMASI-MIXAMO: sekuens yang sama seperti duduk — kaki
			# dulu, badan, tangan terakhir (lihat arm "duduk").
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
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.50, k_tangan)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.50 + sin(_menulis_t * 6.0) * 0.06, k_tangan)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k_tangan)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k_tangan)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.50, k_tangan)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.45, k_tangan)
			_lerp_pakaian(delta, PAKAIAN_DUDUK)
		"salaman":
			# Salaman: tangan kanan terulur ke depan (jabat tangan),
			# badan sedikit condong. Hadap ke NPC diatur main.gd.
			# Lengan kanan mengarah KE DALAM (sudut_salaman_dalam)
			# supaya tangan sampai ke garis tengah dan bertemu tangan
			# lawan — bukan lurus ke depan (verdict Mas 20 Nov 2026).
			_visual.position.y = lerpf(_visual.position.y, 0.0, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -1.45, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.05, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, sudut_salaman_dalam(_arm_r.position.x), k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, 0.0, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.1, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.0, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.0, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_lerp_pakaian(delta, PAKAIAN_DEFAULT)
		"melambai":
			# Melambai: tangan kanan terangkat + bergoyang.
			_visual.position.y = lerpf(_visual.position.y, 0.0, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.0, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -2.6, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.05, k)
			_arm_r.rotation.z = -(0.4 + sin(Time.get_ticks_msec() * 0.008) * 0.35)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.2, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.0, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.0, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_lerp_pakaian(delta, PAKAIAN_DEFAULT)
		"tidur":
			# Tidur RONDE 9: badan berbaring (visual diputar -86° ke
			# belakang, kepala ke utara) — tapi sarung + torso DIPIPIHKAN
			# (bukan kubah): sarung skala z 0.55 + torso skala z 0.6 —
			# badan terbaring DATAR seperti orang di bawah selimut,
			# kepala di bantal tetap terlihat, lengan di sisi badan.
			# Target y=0.58 supaya badan berbaring DI ATAS kasur (atas
			# matras 0.51, atas selimut 0.59), bukan tenggelam ke
			# dalam kasur (y=0.22 lama: badan hilang di dalam bed).
			_visual.position.y = lerpf(_visual.position.y, 0.58, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, -1.5, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, 0.0, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.30, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.30, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, 0.0, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, 0.0, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.0, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.0, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_lerp_pakaian(delta, PAKAIAN_TIDUR)
			# Label nama disembunyikan saat tidur (saat berbaring
			# label melayang 2,1 m melewati kepala, di luar kasur) —
			# _process menjaga label tetap tersembunyi. (BUBBLE-ML:
			# baris bubble lama dihapus — bubble tidak pernah tampil.)
			_name_label.visible = false
		"sholat":
			# Sholat RONDE 18 (skema sinematik, Mas 12:14 WIB): adegan
			# sholat HANYA takbiratul ihram — berdiri di sajadah
			# menghadap kiblat, KEDUA TANGAN TERANGKAT ke telinga
			# (lengan -2.6, siku sedikit menekuk -0.6). Pose STATIS:
			# tahan ±4 dtk, lalu layar menghitam (blackout, main.gd)
			# dan sholat selesai. TIDAK ada qiyam/ruku/sujud di
			# adegan ini (siklus 8 dtk ronde 13 DIHAPUS).
			_visual.position.y = lerpf(_visual.position.y, 0.0, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.05, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -2.6, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -2.6, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.15, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.15, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.6, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.6, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.0, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, 0.0, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.0, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, 0.0, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.0, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, 0.0, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_lerp_pakaian(delta, PAKAIAN_DEFAULT)


## RONDE 9: lerp skala/posisi pakaian ke target pose (sarung mengerut
## saat duduk, sarung + torso pipih saat tidur, normal saat berdiri).
## Dipanggil dari _terapkan_pose (pose diam) dan _physics_process
## (di luar pose diam — kembalikan ke normal).
func _lerp_pakaian(delta: float, target: Dictionary) -> void:
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
	if _torso != null:
		_torso.scale = _torso.scale.lerp(target["torso_scale"], k)
	if _peci != null:
		_peci.scale.z = lerpf(_peci.scale.z, target["peci_z"], k)


func _process(delta: float) -> void:
	# MULTIPLAYER FASE 1 — L5: interpolasi remote (di _process, BUKAN
	# _physics_process). BUKAN otoritas: posisi di-lerp menuju
	# sync_position dan yaw menuju sync_yaw — gerakan pemain lain
	# terlihat halus walau paket sync cuma 10 Hz (tiap paket menempuh
	# ±0,6 m). Bobot dijepit ke 1,0 seperti lerp hadap di
	# _physics_process (RONDE 5: delta*10 tanpa jepit berosilasi di
	# frame lambat). rotation.y NODE yang di-lerp (bukan _visual):
	# _visual.rotation.y avatar remote selalu 0 (tidak pernah diputar
	# _physics_process / set_facing), jadi yaw node = arah hadapnya.
	# Pemilik: lewati blok ini sepenuhnya — posisinya hasil
	# move_and_slide() lokal, bukan lerp.
	if not is_multiplayer_authority():
		var w := minf(1.0, delta * MpSync.LERP_LANCAR)
		position = position.lerp(sync_position, w)
		rotation.y = lerp_angle(rotation.y, sync_yaw, w)
		_terapkan_outfit_sync() # L4: outfit remote dari synchronizer.
		_sinkron_aksi_dari_pose_id() # L6: _aksi remote dari pose_id.
		_jalankan_animasi_visual(delta, pose_id == PoseIds.POSE_JALAN) # L6: animasi remote dari pose_id.
	# BUBBLE-ML: blok timer bubble DIHAPUS — bubble 3D tidak pernah
	# tampil lagi, jadi tidak ada timer yang perlu jalan.
	# Perbaikan 15 Nov ~12:50 WIB (gelembung NPC raksasa): batasi ukuran
	# tampak NAMA supaya tidak membesar menutupi layar saat karakter
	# dekat kamera.
	var cam := get_viewport().get_camera_3d()
	Palette.batasi_label_kamera(_name_label, cam)
	# RONDE 5: label nama hanya tampil saat kamera cukup dekat (28 m) —
	# dari jauh namanya toh tidak terbaca, dan layar jadi bersih seperti
	# game bola (nama muncul saat pemain dekat).
	# RONDE 8: + ditahan saat panel chat terbuka (lihat set_nama_ditahan).
	# RONDE 9: + disembunyikan saat tidur — saat berbaring label
	# melayang 2,1 m melewati kepala, di luar kasur (_terapkan_pose
	# tidur sudah menyembunyikannya, tapi _process ini menampilkannya
	# lagi tiap frame tanpa kondisi ini).
	if cam != null:
		_name_label.visible = (not _nama_ditahan) and _aksi != "tidur" and cam.global_position.distance_to(_name_label.global_position) < 28.0
		# RONDE PERBAIKAN (Eka): label NAMA tidak boleh terpotong
		# tembok (lihat _batasi_label_dinding di atas; baris bubble
		# lama dihapus — BUBBLE-ML).
		var ruang := get_viewport().get_world_3d().direct_space_state
		_batasi_label_dinding(_name_label, cam, ruang, get_rid())
