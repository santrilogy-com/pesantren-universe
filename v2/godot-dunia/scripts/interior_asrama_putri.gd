class_name InteriorAsramaPutri
extends Node3D
## Interior ASRAMA PUTRI — MAP TERPISAH ala GTA (Rani, 18 Nov 2026,
## tugas Mas 00:24 WIB: area putri masih kosong, belum ada kasur).
##
## KOREKSI Mas 00:25 WIB ("Jangan cangkruk.. asrama aja.."): kasur
## susun HANYA di Asrama Putri, JANGAN di Cangkruk Putri. File ini
## TIDAK menyentuh Cangkruk Putri sama sekali.
##
## LOKASI MAP: cangkang luar Asrama Putri ada di (152,9) — posisi v2
## yang di-ACC (pindah dari (152,0), info Mira 01:03 WIB) — TAPI
## interior ini TIDAK dibangun di sana. Pola InteriorCangkruk /
## InteriorSurau: map interior terpisah jauh di dunia, masuk pintu =
## teleport (main.gd yang mengatur). Map ini di OFFSET (-240,0,-300):
## x -249..-227,5, z -306..-294 (tapak 18x12 + annex timur).
## KOORDINASI ZONA (info 01:01 WIB — bentrok Studio/Kelas di 120):
## zona x yang SUDAH TERPAKAI dan dihindari: Surau ~0, Cangkruk -60,
## Musholla 60, Kelas 120, Pos 180, Studio 240, Kantor -120,
## Madrasah -180. Zona Asrama = -240 (kosong; tetangga terdekat
## Madrasah -180, jarak 54 m — tapak baru max_x -227,5 masih 47 m
## darinya). Semua koordinat anak ditulis LOKAL
## (pusat gedung (0,0,0)); root.position = OFFSET.
## Pintu utama di dinding BARAT (lokal x=-9, dunia -249,-300) —
## sama sisi dengan pintu cangkang luar (barat).
##
## DENAH (per lantai, sama untuk lantai 1-3) — DIPERBESAR 18 Nov
## 2026 (verdict Mas 08:04 WIB: kamar terlalu sempit, apalagi
## portrait; + 08:06 WIB: koridor harus muat 3 orang jalan
## berdampingan tanpa tabrakan):
##   tapak 18x12 m, tinggi lantai 3,2 m (lantai 1 y 0..3,2; lantai 2
##   y 3,2..6,4; lantai 3 y 6,4..9,6). Koridor timur-barat 2,6 m
##   (z -1,3..1,3) membelah 4 kamar: barat-laut, timur-laut,
##   barat-daya, timur-daya — 3 kapsul (3 x 0,7 = 2,1 m) muat
##   berdampingan + 0,5 m ruang gerak (tes G membuktikan).
##   Tiap kamar 9x4,7 m, 4 kasur susun berjajar di dinding luar
##   (kepala di dinding luar), lorong kaki kasur 2,275 m, + lemari
##   + meja kecil + lampu + karpet + jendela.
##   Tangga di ANNEX timur (x 9..12,5, z -1,3..1,3): switchback dua
##   flight + bordes — flight A naik ke timur (y +1,6), bordes,
##   flight B balik ke barat (y +1,6 lagi). Rampa miring (pola
##   TanggaSurau: permukaan jalan rampa, bukan anak tangga kotak —
##   kapsul r=0,35 tanpa step-up tersangkut di riser kotak).
##
## KASUR (konvensi SAMA dengan PembagianKasur — JANGAN diubah):
##   3 lantai x 4 kamar x 4 susun x 2 tingkat = 96 kasur.
##   Kamar "Kamar 001".."Kamar 012" (lantai 1 = 001-004, lantai 2 =
##   005-008, lantai 3 = 009-012). Kasur "A-PUTRI-001".."A-PUTRI-096".
##   idx 1..96: nomor_kamar = (idx-1)/8+1; susun = ((idx-1)%8)/2+1
##   (1..4); tingkat = "bawah" bila (idx-1) genap, "atas" bila ganjil.
##   Urutan kamar per lantai: 1 = barat-laut, 2 = timur-laut,
##   3 = barat-daya, 4 = timur-daya.
##
## TIDUR — BACA SEBELUM WIRING (Nadia):
##   Tiap kasur susun punya SATU StaticBody3D penuh (1,1 x 1,9 x 2,1)
##   — tidak bisa ditembus saat jalan. Karena itu kapsul pemain
##   TIDAK BOLEH di-snap begitu saja ke POSISI_TIDUR: kapsul akan
##   berada DI DALAM collision kasur itu sendiri. Saat tidur,
##   main.gd WAJIB menonaktifkan dulu body kasur itu
##   (body.collision_layer = 0 dan body.collision_mask = 0 —
##   StaticBody3D TIDAK punya properti "disabled" di Godot 4.7.2,
##   set_deferred("disabled", ...) TIDAK JALAN) lalu
##   snap kapsul ke posisi_tidur_list()[idx-1]; saat bangun,
##   aktifkan lagi. POSISI_TIDUR sudah termasuk y kasur (bawah
##   +0,55 / atas +1,65 dari lantai) + offset kaki (0,95 m ke arah
##   kaki) — JANGAN pakai rumus Cangkruk (bed + (0,0,0.95), y=0);
##   kasur atas butuh y yang benar.
##
## INTERFACE (mirip InteriorCangkruk.build()):
##   build() -> {
##     "root": Node3D, "lantai_root": [Node3D x3],
##     "interior_door": Vector3(-249,0,-300),
##     "interior_spawn": Vector3(-247.5,0,-300),
##     "shell_door": Vector3(146,0,9),
##     "shell_exit": Vector3(144.5,0,9),
##     "bed_pos_list": [Vector3 x96] (pusat kasur, dunia),
##     "posisi_tidur_list": [Vector3 x96] (posisi kapsul tidur, dunia),
##     "kasur_id_list": [String x96], "kamar_list": [String x96],
##     "kasur_bodies": [StaticBody3D x96] (idx-1, untuk tidur),
##     "lantai_y": [0.0, 3.2, 6.4],
##     "bounds": {"min_x":-249.0, "max_x":-227.5, "min_z":-306.0, "max_z":-294.0},
##   }
## Dipakai dua cara: (1) InteriorAsramaPutri.build() dari main.gd
## (Nadia yang integrasikan); (2) scene tes — _ready() membangun
## isi kalau belum ada. Interior DISEMBUNYIKAN (visible=false) saat
## pemain di luar — main.gd yang mengatur (pola Surau/Cangkruk).

const OFFSET := Vector3(-240, 0, -300)
const LANTAI_TINGGI := 3.2
const LANTAI_Y := [0.0, 3.2, 6.4]
const JUMLAH_KASUR := 96
const KAMAR_PER_LANTAI := 4
const SUSUN_PER_KAMAR := 4
const KASUR_PER_KAMAR := 8
## Pusat kamar (lokal x): barat -4,5 / timur +4,5.
## Posisi kasur susun relatif terhadap pusat kamar (jarak 2,2 m).
const BUNK_X_OFF := [-3.3, -1.1, 1.1, 3.3]
## Pusat kasur dari dinding luar (lokal z): kamar utara -4,7,
## kamar selatan +4,7. Kepala kasur 0,125 m dari dinding luar;
## lorong kaki kasur 2,275 m ke dinding koridor. BED_Z = 4,7
## (BUKAN 4,75: kotak cek anti-tembus +0,1 m menyentuh dinding
## luar/jendela bila kasur 0,05 m lebih dekat ke dinding).
const BED_Z := 4.7
const INTERIOR_DOOR := Vector3(-249, 0, -300)
const INTERIOR_SPAWN := Vector3(-247.5, 0, -300)
const SHELL_DOOR := Vector3(146, 0, 9)
const SHELL_EXIT := Vector3(144.5, 0, 9)
const ASRAMA_BOUNDS := {"min_x": -249.0, "max_x": -227.5, "min_z": -306.0, "max_z": -294.0}

var _sudah_dibangun := false
var _kasur_bodies: Array[StaticBody3D] = []
var _lantai_root: Array[Node3D] = []


func _ready() -> void:
	if get_child_count() == 0:
		_bangun()


## Bangun interior (dipakai main.gd). Mengembalikan dict dengan
## interface yang sama seperti InteriorCangkruk.build().
static func build() -> Dictionary:
	var node := InteriorAsramaPutri.new()
	node.name = "InteriorAsramaPutri"
	node._bangun()
	return {
		"root": node,
		"lantai_root": node._lantai_root,
		"interior_door": INTERIOR_DOOR,
		"interior_spawn": INTERIOR_SPAWN,
		"shell_door": SHELL_DOOR,
		"shell_exit": SHELL_EXIT,
		"bed_pos_list": bed_pos_list(),
		"posisi_tidur_list": posisi_tidur_list(),
		"kasur_id_list": kasur_id_list(),
		"kamar_list": kamar_list(),
		"kasur_bodies": node._kasur_bodies,
		"lantai_y": LANTAI_Y,
		"bounds": ASRAMA_BOUNDS,
	}


## --- konvensi penamaan / posisi (satu sumber kebenaran) -----------

static func ke_dunia(lokal: Vector3) -> Vector3:
	return lokal + OFFSET


static func ke_lokal(dunia: Vector3) -> Vector3:
	return dunia - OFFSET


static func nama_kamar(nomor_kamar_1based: int) -> String:
	return "Kamar %03d" % clampi(nomor_kamar_1based, 1, 12)


static func kasur_id_untuk_idx(idx: int) -> String:
	return "A-PUTRI-%03d" % clampi(idx, 1, 96)


static func kamar_untuk_idx(idx: int) -> String:
	return nama_kamar((idx - 1) / KASUR_PER_KAMAR + 1)


static func susun_untuk_idx(idx: int) -> int:
	return ((idx - 1) % KASUR_PER_KAMAR) / 2 + 1


static func tingkat_untuk_idx(idx: int) -> String:
	return "bawah" if (idx - 1) % 2 == 0 else "atas"


static func lantai_untuk_idx(idx: int) -> int:
	return (idx - 1) / (KAMAR_PER_LANTAI * KASUR_PER_KAMAR) + 1


## Posisi pusat kasur idx (1..96) — LOKAL (belum + OFFSET).
## ruang 0 = barat-laut, 1 = timur-laut, 2 = barat-daya, 3 = timur-daya.
static func posisi_kasur_lokal(idx: int) -> Vector3:
	var nomor_kamar := (idx - 1) / KASUR_PER_KAMAR + 1
	var ruang := (nomor_kamar - 1) % KAMAR_PER_LANTAI
	var lantai := (nomor_kamar - 1) / KAMAR_PER_LANTAI + 1
	var susun := ((idx - 1) % KASUR_PER_KAMAR) / 2 + 1
	var cx := -4.5 if (ruang == 0 or ruang == 2) else 4.5
	var zs := -1.0 if (ruang == 0 or ruang == 1) else 1.0
	var fy: float = LANTAI_Y[lantai - 1]
	return Vector3(cx + BUNK_X_OFF[susun - 1], fy, zs * BED_Z)


## Daftar 96 pusat kasur (dunia). Urutan = idx 1..96.
static func bed_pos_list() -> Array[Vector3]:
	var hasil: Array[Vector3] = []
	for i in range(1, JUMLAH_KASUR + 1):
		hasil.append(ke_dunia(posisi_kasur_lokal(i)))
	return hasil


## Daftar 96 posisi kapsul tidur (dunia): pusat kasur + offset kaki
## 0,95 m ke arah kaki + y kasur (bawah +0,55 / atas +1,65).
static func posisi_tidur_list() -> Array[Vector3]:
	var hasil: Array[Vector3] = []
	for i in range(1, JUMLAH_KASUR + 1):
		var lokal := posisi_kasur_lokal(i)
		var nomor_kamar := (i - 1) / KASUR_PER_KAMAR + 1
		var ruang := (nomor_kamar - 1) % KAMAR_PER_LANTAI
		var zs := -1.0 if (ruang == 0 or ruang == 1) else 1.0
		var y_tidur := 0.55 if (i - 1) % 2 == 0 else 1.65
		hasil.append(ke_dunia(Vector3(lokal.x, lokal.y + y_tidur, lokal.z - zs * 0.95)))
	return hasil


static func kasur_id_list() -> Array[String]:
	var hasil: Array[String] = []
	for i in range(1, JUMLAH_KASUR + 1):
		hasil.append(kasur_id_untuk_idx(i))
	return hasil


static func kamar_list() -> Array[String]:
	var hasil: Array[String] = []
	for i in range(1, JUMLAH_KASUR + 1):
		hasil.append(kamar_untuk_idx(i))
	return hasil


## --- bangun ---------------------------------------------------------

func _bangun() -> void:
	if _sudah_dibangun:
		return
	_sudah_dibangun = true
	# Root di OFFSET — semua anak ditulis LOKAL.
	position = OFFSET
	# Lantai dasar (lantai 1) + lantai annex.
	_static_box(self, Vector3(18, 0.14, 12), Vector3(0, -0.05, 0), Palette.KAYU_GELAP, "LantaiDasar")
	_static_box(self, Vector3(3.5, 0.14, 2.6), Vector3(10.75, -0.05, 0), Palette.KAYU_GELAP, "LantaiAnnex")
	# Tiga lantai (identik denahnya).
	for lantai in range(1, 4):
		_lantai_root.append(_bangun_lantai(lantai))
	# Tangga (annex timur) + atap.
	_bangun_annex()
	_static_box(self, Vector3(18, 0.2, 12), Vector3(0, 9.5, 0), Palette.KAYU_GELAP, "PlafonAtap")
	_static_box(self, Vector3(3.75, 0.2, 2.85), Vector3(10.75, 9.5, 0), Palette.KAYU_GELAP, "PlafonAnnex")


## Satu lantai: pelat (lantai 2-3), dinding, 4 kamar, koridor.
func _bangun_lantai(lantai: int) -> Node3D:
	var fy: float = LANTAI_Y[lantai - 1]
	var g := Node3D.new()
	g.name = "Lantai%d" % lantai
	add_child(g)
	# Pelat lantai (lantai 1 memakai LantaiDasar). Pelat ini juga
	# plafon lantai di bawahnya — HARUS punya collision (pola
	# InteriorCangkruk: plafon tanpa collision bikin kamera
	# SpringArm menembus ke lantai atas).
	if lantai > 1:
		_static_box(g, Vector3(18, 0.2, 12), Vector3(0, fy - 0.1, 0), Palette.KAYU_GELAP, "Lantai%d" % lantai)
	# --- Dinding luar (krem, tebal 0,25, tinggi 3,0) ---
	_static_box(g, Vector3(18.5, 3.0, 0.25), Vector3(0, fy + 1.5, -6), Palette.KREM, "DindingUtara")
	_static_box(g, Vector3(18.5, 3.0, 0.25), Vector3(0, fy + 1.5, 6), Palette.KREM, "DindingSelatan")
	# Barat: lantai 1 bercelah pintu utama (1,6 m, |z|<0,8, tinggi
	# 2,6); lantai 2-3 utuh.
	if lantai == 1:
		_static_box(g, Vector3(0.25, 3.0, 5.2), Vector3(-9, fy + 1.5, -3.4), Palette.KREM, "DindingBaratUtara")
		_static_box(g, Vector3(0.25, 3.0, 5.2), Vector3(-9, fy + 1.5, 3.4), Palette.KREM, "DindingBaratSelatan")
		_static_box(g, Vector3(0.25, 0.4, 1.6), Vector3(-9, fy + 2.8, 0), Palette.KREM, "AmbangPintuUtama")
	else:
		_static_box(g, Vector3(0.25, 3.0, 12.25), Vector3(-9, fy + 1.5, 0), Palette.KREM, "DindingBarat")
	# Timur: celah koridor -> annex (z -1,3..1,3) di semua lantai.
	_static_box(g, Vector3(0.25, 3.0, 4.7), Vector3(9, fy + 1.5, -3.65), Palette.KREM, "DindingTimurUtara")
	_static_box(g, Vector3(0.25, 3.0, 4.7), Vector3(9, fy + 1.5, 3.65), Palette.KREM, "DindingTimurSelatan")
	# Partisi barat-timur (x=0) + dinding koridor (z=±1,3) dengan
	# celah pintu kamar (0,9 m, pusat x=±4,5, tinggi 2,2).
	_static_box(g, Vector3(0.15, 3.0, 4.7), Vector3(0, fy + 1.5, -3.65), Palette.KREM, "PartisiUtara")
	_static_box(g, Vector3(0.15, 3.0, 4.7), Vector3(0, fy + 1.5, 3.65), Palette.KREM, "PartisiSelatan")
	for zs in [-1.0, 1.0]:
		var zw: float = zs * 1.3
		var nama_sisi := "Utara" if zs < 0 else "Selatan"
		for seg in [[-6.975, 4.05], [-2.025, 4.05], [2.025, 4.05], [6.975, 4.05]]:
			_static_box(g, Vector3(seg[1], 3.0, 0.15), Vector3(seg[0], fy + 1.5, zw), Palette.KREM, "DindingKoridor%s_%s" % [nama_sisi, str(seg[0])])
		for dx in [-4.5, 4.5]:
			_static_box(g, Vector3(0.9, 0.8, 0.15), Vector3(dx, fy + 2.6, zw), Palette.KREM, "AmbangKamar%s_%s" % [nama_sisi, str(dx)])
	# --- 4 kamar ---
	for ruang in range(4):
		var nomor_kamar := (lantai - 1) * KAMAR_PER_LANTAI + ruang + 1
		_bangun_kamar(g, nomor_kamar, fy)
	# --- Koridor: lampu + rak buku + label ---
	_lampu_hangat(g, Vector3(0, fy, 0), "LampuKoridor")
	# Rak menempel dinding koridor utara (muka dalam z=-1,225),
	# di ruas barat antara dinding barat dan pintu Kamar 001 —
	# JANGAN di x=-4,6: itu tepat di depan pintu kamar (x -4,95..-4,05).
	_rak_buku(g, Vector3(-7.0, fy, -1.05))
	# Label lantai di dinding koridor utara dekat annex + label
	# tangga di ujung koridor timur.
	var label_lantai := Palette.label3d("LANTAI %d" % lantai, Vector3(7.5, fy + 2.5, -1.22), 20, Color("#f2c14e"), false)
	label_lantai.name = "LabelLantai"
	label_lantai.rotation.y = PI
	label_lantai.double_sided = false
	g.add_child(label_lantai)
	var teks_tangga := "TANGGA"
	if lantai == 1:
		teks_tangga = "TANGGA \u2191 LANTAI 2"
	elif lantai == 2:
		teks_tangga = "TANGGA \u2191 LANTAI 3"
	else:
		teks_tangga = "TANGGA \u2193 LANTAI 2"
	var label_tangga := Palette.label3d(teks_tangga, Vector3(8.4, fy + 2.5, -1.22), 16, Color("#f2c14e"), false)
	label_tangga.name = "LabelTangga"
	label_tangga.rotation.y = PI
	label_tangga.double_sided = false
	g.add_child(label_tangga)
	# Label KELUAR + ASRAMA PUTRI di atas pintu utama (lantai 1).
	if lantai == 1:
		var keluar := Palette.label3d("KELUAR", Vector3(-8.8, fy + 2.5, 0), 22, Color("#f2c14e"), false)
		keluar.name = "LabelKeluar"
		keluar.rotation.y = PI / 2.0
		keluar.double_sided = false
		g.add_child(keluar)
		var keluar_luar := Palette.label3d("KELUAR", Vector3(-9.2, fy + 2.5, 0), 22, Color("#f2c14e"), false)
		keluar_luar.name = "LabelKeluarBelakang"
		keluar_luar.rotation.y = -PI / 2.0
		keluar_luar.double_sided = false
		g.add_child(keluar_luar)
		var nama_gedung := Palette.label3d("ASRAMA PUTRI", Vector3(-8.8, fy + 2.85, 0), 16, Color("#f2c14e"), false)
		nama_gedung.name = "LabelAsramaPutri"
		nama_gedung.rotation.y = PI / 2.0
		nama_gedung.double_sided = false
		g.add_child(nama_gedung)
	else:
		var label_lt := Palette.label3d("LANTAI %d" % lantai, Vector3(-8.8, fy + 2.7, 0), 20, Color("#f2c14e"), false)
		label_lt.name = "LabelLantaiBarat"
		label_lt.rotation.y = PI / 2.0
		label_lt.double_sided = false
		g.add_child(label_lt)
	return g

## Satu kamar: 4 kasur susun + lemari + meja + karpet + lampu +
## jendela + label nama kamar di atas pintu (sisi koridor).
func _bangun_kamar(parent: Node3D, nomor_kamar: int, fy: float) -> void:
	var ruang := (nomor_kamar - 1) % KAMAR_PER_LANTAI
	var cx := -4.5 if (ruang == 0 or ruang == 2) else 4.5
	var zs := -1.0 if (ruang == 0 or ruang == 1) else 1.0
	var kg := Node3D.new()
	kg.name = "Kamar%03d" % nomor_kamar
	parent.add_child(kg)
	# 4 kasur susun (idx berurutan per kamar, bawah+atas selang-seling
	# mengikuti PembagianKasur: idx ganjil = bawah, genap = atas).
	for susun in range(1, SUSUN_PER_KAMAR + 1):
		var idx := (nomor_kamar - 1) * KASUR_PER_KAMAR + (susun - 1) * 2 + 1
		var bx: float = cx + float(BUNK_X_OFF[susun - 1])
		_kasur_susun(kg, idx, Vector3(bx, fy, zs * BED_Z), zs)
	# Lemari (menempel dinding koridor, ujung dekat partisi; depan
	# menghadap kasur — dekorasi, bukan interaksi ganti baju).
	var lemari_x := -0.95 if cx < 0 else 0.95
	_lemari(kg, Vector3(lemari_x, fy, zs * 1.65), zs)
	# Meja kecil di ujung lorong (dekat dinding luar).
	var meja_x := -8.3 if cx < 0 else 8.3
	_meja_kecil(kg, Vector3(meja_x, fy, zs * 1.65))
	# Karpet di lorong kaki kasur (visual saja, tanpa collision —
	# atasnya y 0,05, dilewati test anti-tembus seperti di Cangkruk).
	var karpet := Palette.box(Vector3(5.0, 0.04, 1.6), Vector3(cx, fy + 0.03, zs * 2.55), Color("#065f46"))
	karpet.name = "Karpet"
	kg.add_child(karpet)
	# Lampu hangat di atas lorong (bukan di atas kasur — pelajaran
	# InteriorCangkruk Ronde 8: bola lampu di garis kamera kasur
	# bikin layar hitam saat bangun tidur).
	_lampu_hangat(kg, Vector3(cx, fy, zs * 2.55), "LampuKamar")
	# Jendela di dinding luar (visual saja, tanpa lampu tambahan).
	_jendela_visual(kg, Vector3(cx, fy + 1.7, zs * 5.87), PI if zs < 0 else 0.0, "JendelaKamar")
	# Label nama kamar di atas pintu, sisi koridor.
	var label := Palette.label3d(nama_kamar(nomor_kamar), Vector3(cx, fy + 2.55, zs * 1.22), 20, Color("#f2c14e"), false)
	label.name = "LabelKamar"
	label.rotation.y = PI if zs < 0 else 0.0
	label.double_sided = false
	kg.add_child(label)


## Kasur susun (tingkat): rangka jati + kasur krem + bantal putih +
## selimut zamrud, bawah dan atas. pos = pusat unit (y = lantai).
## head_dir: -1 kepala di utara, +1 kepala di selatan.
## Collision: SATU StaticBody3D penuh (1,1 x 1,9 x 2,1) per unit —
## lihat catatan TIDUR di header (body ini HARUS dimatikan sesaat
## saat pemiliknya tidur di kasur ini).
func _kasur_susun(parent: Node3D, idx_bawah: int, pos: Vector3, head_dir: float) -> void:
	var t := Node3D.new()
	t.name = "Kasur%03d" % idx_bawah
	t.position = pos
	parent.add_child(t)
	# 4 tiang jati.
	for sx in [-0.51, 0.51]:
		for sz in [-1.01, 1.01]:
			t.add_child(Palette.box(Vector3(0.08, 1.9, 0.08), Vector3(sx, 0.95, sz), Palette.JATI))
	# Rangka + kasur + bantal + selimut, bawah (y 0,32..0,62) dan
	# atas (y 1,42..1,72). Bantal di ujung kepala, selimut di kaki.
	for tingkat in [0.0, 1.1]:
		var y0: float = tingkat
		t.add_child(Palette.box(Vector3(1.1, 0.14, 2.1), Vector3(0, y0 + 0.32, 0), Palette.JATI))
		t.add_child(Palette.box(Vector3(1.0, 0.16, 2.0), Vector3(0, y0 + 0.44, 0), Palette.KREM))
		t.add_child(Palette.box(Vector3(0.7, 0.12, 0.38), Vector3(0, y0 + 0.56, head_dir * 0.78), Color("#ffffff")))
		t.add_child(Palette.box(Vector3(1.02, 0.07, 1.05), Vector3(0, y0 + 0.55, -head_dir * 0.45), Palette.ZAMRUD_GELAP))
	# Pagar pengaman kasur atas (dua sisi panjang + ujung kaki).
	t.add_child(Palette.box(Vector3(0.05, 0.28, 2.1), Vector3(-0.53, 1.78, 0), Palette.JATI))
	t.add_child(Palette.box(Vector3(0.05, 0.28, 2.1), Vector3(0.53, 1.78, 0), Palette.JATI))
	t.add_child(Palette.box(Vector3(1.1, 0.28, 0.05), Vector3(0, 1.78, -head_dir * 1.02), Palette.JATI))
	# Tangga naik ke kasur atas (ujung kaki): 2 rel + 2 anak tangga.
	t.add_child(Palette.box(Vector3(0.05, 1.9, 0.05), Vector3(-0.35, 0.95, -head_dir * 1.12), Palette.JATI))
	t.add_child(Palette.box(Vector3(0.05, 1.9, 0.05), Vector3(0.35, 0.95, -head_dir * 1.12), Palette.JATI))
	t.add_child(Palette.box(Vector3(0.65, 0.05, 0.05), Vector3(0, 0.6, -head_dir * 1.12), Palette.JATI))
	t.add_child(Palette.box(Vector3(0.65, 0.05, 0.05), Vector3(0, 1.2, -head_dir * 1.12), Palette.JATI))
	# Collision penuh satu unit (idx bawah; kasur atas satu unit
	# dengannya — body disimpan sekali per unit, urutan idx bawah).
	var body := StaticBody3D.new()
	body.name = "CollisionKasur"
	body.position = Vector3(0, 0.95, 0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.1, 1.9, 2.1)
	shape.shape = box
	body.add_child(shape)
	t.add_child(body)
	_kasur_bodies.append(body)


## Lemari pakaian: badan jati + 2 pintu + kenop emas + cermin.
## pos = pusat lemari; facing: -1 pintu menghadap utara, +1 selatan
## (menghadap kasur — dekorasi).
func _lemari(parent: Node3D, pos: Vector3, facing: float) -> void:
	var l := Node3D.new()
	l.name = "Lemari"
	l.position = pos
	parent.add_child(l)
	l.add_child(Palette.box(Vector3(1.6, 2.0, 0.55), Vector3(0, 1.0, 0), Palette.KAYU))
	l.add_child(Palette.box(Vector3(0.72, 1.8, 0.06), Vector3(-0.38, 1.0, facing * 0.3), Palette.KAYU_GELAP))
	l.add_child(Palette.box(Vector3(0.72, 1.8, 0.06), Vector3(0.38, 1.0, facing * 0.3), Palette.KAYU_GELAP))
	l.add_child(Palette.sphere(0.05, Vector3(-0.08, 1.0, facing * 0.35), Palette.EMAS, 0.4))
	l.add_child(Palette.sphere(0.05, Vector3(0.08, 1.0, facing * 0.35), Palette.EMAS, 0.4))
	l.add_child(Palette.box(Vector3(0.5, 1.2, 0.02), Vector3(0.38, 1.2, facing * 0.34), Color("#cfe0f0"), 0.15))


## Meja kecil: papan bundar + kaki + lampu meja + kitab.
func _meja_kecil(parent: Node3D, pos: Vector3) -> void:
	var m := Node3D.new()
	m.name = "MejaKecil"
	m.position = pos
	parent.add_child(m)
	m.add_child(Palette.cylinder(0.3, 0.3, 0.06, Vector3(0, 0.55, 0), Palette.KAYU))
	m.add_child(Palette.cylinder(0.04, 0.05, 0.55, Vector3(0, 0.28, 0), Palette.KAYU_GELAP))
	m.add_child(Palette.cylinder(0.03, 0.03, 0.3, Vector3(0, 0.75, 0), Palette.EMAS, 0.4))
	m.add_child(Palette.cylinder(0.12, 0.16, 0.18, Vector3(0, 0.95, 0), Color("#ffe6b8")))
	m.add_child(Palette.box(Vector3(0.3, 0.05, 0.22), Vector3(0.2, 0.61, 0.15), Palette.ZAMRUD_GELAP))


## Rak buku koridor (1 per lantai): badan + 2 rak + buku warna-warni.
func _rak_buku(parent: Node3D, pos: Vector3) -> void:
	var r := Node3D.new()
	r.name = "RakBuku"
	r.position = pos
	parent.add_child(r)
	r.add_child(Palette.box(Vector3(1.2, 1.4, 0.35), Vector3(0, 0.7, 0), Palette.JATI))
	r.add_child(Palette.box(Vector3(1.1, 0.05, 0.3), Vector3(0, 0.5, 0), Palette.KAYU_GELAP))
	r.add_child(Palette.box(Vector3(1.1, 0.05, 0.3), Vector3(0, 0.95, 0), Palette.KAYU_GELAP))
	var warna_buku: Array = [Palette.ZAMRUD, Palette.EMAS, Palette.KREM, Color("#a33b3b"), Color("#3b5aa3")]
	for i in range(5):
		var bx := -0.42 + float(i) * 0.21
		r.add_child(Palette.box(Vector3(0.16, 0.32, 0.22), Vector3(bx, 0.71, 0), warna_buku[i % 5]))
		r.add_child(Palette.box(Vector3(0.16, 0.3, 0.22), Vector3(bx, 1.15, 0), warna_buku[(i + 2) % 5]))


## Kotak visual + collision (pola yang sama seperti InteriorSurau).
func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, nama: String = "") -> MeshInstance3D:
	var mi := Palette.box(size, pos, color)
	if nama != "":
		mi.name = nama
	parent.add_child(mi)
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	parent.add_child(body)
	return mi


## Lampu hangat gantung (pola InteriorCangkruk): OmniLight + kabel +
## kap emas + bola + collision bola (supaya SpringArm kamera mengerut
## sebelum masuk ke dalam bola). Grup "LampuCahaya".
func _lampu_hangat(parent: Node3D, pos: Vector3, nama: String) -> void:
	var grup := Node3D.new()
	grup.name = nama
	grup.position = pos
	parent.add_child(grup)
	var lampu := OmniLight3D.new()
	lampu.name = "Cahaya"
	lampu.position = Vector3(0, 2.7, 0)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.7
	lampu.set_meta("energi_siang", 0.7)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 9.0
	lampu.shadow_enabled = false
	grup.add_child(lampu)
	grup.add_child(Palette.cylinder(0.03, 0.03, 0.26, Vector3(0, 2.87, 0), Palette.KAYU_GELAP))
	grup.add_child(Palette.cylinder(0.1, 0.1, 0.06, Vector3(0, 2.82, 0), Palette.EMAS, 0.4))
	grup.add_child(Palette.sphere(0.16, Vector3(0, 2.72, 0), Color("#ffe6b8")))
	var body := StaticBody3D.new()
	body.name = "LampuCollision"
	grup.add_child(body)
	var bentuk := CollisionShape3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.25
	bentuk.shape = bola
	bentuk.position = Vector3(0, 2.72, 0)
	body.add_child(bentuk)


## Lampu dinding annex (tanpa kabel gantung — shaft tangga setinggi
## 9,6 m, lampu menempel dinding timur, tinggi y 8,5 supaya tidak
## menghalangi kepala pemain di bordes).
func _lampu_dinding(parent: Node3D, pos: Vector3, nama: String) -> void:
	var grup := Node3D.new()
	grup.name = nama
	grup.position = pos
	parent.add_child(grup)
	var lampu := OmniLight3D.new()
	lampu.name = "Cahaya"
	lampu.position = Vector3(0, 0, 0)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.8
	lampu.set_meta("energi_siang", 0.8)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 10.0
	lampu.shadow_enabled = false
	grup.add_child(lampu)
	grup.add_child(Palette.box(Vector3(0.5, 0.06, 0.06), Vector3(0.1, 0.12, 0), Palette.JATI))
	grup.add_child(Palette.sphere(0.16, Vector3(0, 0, 0), Color("#ffe6b8")))
	var body := StaticBody3D.new()
	body.name = "LampuCollision"
	grup.add_child(body)
	var bentuk := CollisionShape3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.25
	bentuk.shape = bola
	body.add_child(bentuk)


## Jendela kayu (visual saja, tanpa lampu tambahan — pola
## InteriorCangkruk tanpa CahayaJendela): bingkai + kaca emissive
## (grup "KacaJendela") + jeruji + ambang. Dinding TIDAK dilubangi.
func _jendela_visual(parent: Node3D, pos: Vector3, rot_y: float, nama: String) -> void:
	var g := Node3D.new()
	g.name = nama
	g.position = pos
	g.rotation.y = rot_y
	parent.add_child(g)
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, 0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.1, 0.08, 0.06), Vector3(0, -0.6, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(-0.51, 0, 0.03), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.08, 1.2, 0.06), Vector3(0.51, 0, 0.03), Palette.KAYU_GELAP))
	var kaca_mat := StandardMaterial3D.new()
	kaca_mat.albedo_color = Color("#bcd8e8")
	kaca_mat.emission_enabled = true
	kaca_mat.emission = Color("#cfe8f5")
	kaca_mat.emission_energy_multiplier = 1.0
	kaca_mat.roughness = 0.15
	var kaca := MeshInstance3D.new()
	var kaca_mesh := BoxMesh.new()
	kaca_mesh.size = Vector3(0.94, 1.12, 0.03)
	kaca.mesh = kaca_mesh
	kaca.position = Vector3(0, 0, 0.015)
	kaca.material_override = kaca_mat
	kaca.name = "Kaca"
	kaca.add_to_group("KacaJendela")
	g.add_child(kaca)
	g.add_child(Palette.box(Vector3(0.05, 1.12, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(0.94, 0.05, 0.05), Vector3(0, 0, 0.045), Palette.KAYU_GELAP))
	g.add_child(Palette.box(Vector3(1.2, 0.06, 0.12), Vector3(0, -0.65, 0.06), Palette.KAYU_GELAP))


## --- annex tangga ---------------------------------------------------

## Annex timur (x 9..12,5, z -1,3..1,3, tinggi 9,6): dinding + 2 transisi
## tangga (tiap transisi = flight A naik ke timur + bordes +
## flight B balik ke barat) + 1 lampu dinding tinggi.
## Lebar annex = lebar koridor (2,6 m): dinding barat annex tidak
## perlu — bukaannya selebar koridor.
func _bangun_annex() -> void:
	var a := Node3D.new()
	a.name = "AnnexTangga"
	add_child(a)
	# Dinding annex (tebal 0,25, tinggi 9,6 — menembus semua lantai).
	_static_box(a, Vector3(3.75, 9.6, 0.25), Vector3(10.75, 4.8, -1.3), Palette.KREM, "DindingAnnexUtara")
	_static_box(a, Vector3(3.75, 9.6, 0.25), Vector3(10.75, 4.8, 1.3), Palette.KREM, "DindingAnnexSelatan")
	_static_box(a, Vector3(0.25, 9.6, 2.85), Vector3(12.625, 4.8, 0), Palette.KREM, "DindingAnnexTimur")
	# Dua transisi: lantai 1->2 (dasar y 0) dan 2->3 (dasar y 3,2).
	for dasar in [0.0, 3.2]:
		# Flight A: koridor (9, dasar) -> bordes (11,5, dasar+1,6),
		# lajur utara (z -1..0).
		_rampa_x(a, 9.0, dasar, 11.5, dasar + 1.6, -0.5, 1.0, "TanggaA")
		# Bordes datar (top dasar+1,6) — tempat putar balik.
		_static_box(a, Vector3(1.0, 0.2, 2.0), Vector3(12.0, dasar + 1.5, 0), Palette.KAYU, "BordesTangga")
		# Flight B: bordes (11,5, dasar+1,6) -> lantai atas
		# (9, dasar+3,2), lajur selatan (z 0..1).
		_rampa_x(a, 11.5, dasar + 1.6, 9.0, dasar + 3.2, 0.5, 1.0, "TanggaB")
		# TANPA pembatas miring di antara flight (dihapus 18 Nov
		# 01:0x WIB — ujung baratnya menjorok ke koridor dan
		# menghalangi jalan ke tangga): kedua flight bersentuhan di
		# z=0, sisi flight B sendiri sudah jadi pagar — tidak ada
		# celah jatuh (kapsul 1,8 m tidak muat di celah 0,89 m di
		# bawah flight B).
	# Lampu dinding timur, tinggi (di atas kepala pemain di bordes 2).
	_lampu_dinding(a, Vector3(12.3, 8.5, 0), "LampuAnnex")


## Rampa miring (pola TanggaSurau._rampa, diputar ke sumbu X):
## permukaan atasnya garis lurus dari (x_a, y_a) ke (x_b, y_b).
## Satu papan kayu = visual + collision; ujung-ujung ditanam
## 0,05 m ke lantai/bordes/dinding supaya tidak ada muka vertikal
## yang menyangkut kapsul. Sudut 32,6° < floor_max_angle (45°).
## Anak tangga visual: strip jati 0,02 m di atas permukaan rampa.
func _rampa_x(parent: Node3D, x_a: float, y_a: float, x_b: float, y_b: float, z_tengah: float, lebar: float, nama: String) -> void:
	var dx := x_b - x_a
	var dy := y_b - y_a
	var panjang := sqrt(dx * dx + dy * dy) + 0.1
	var sudut := atan2(dy, dx)
	var g := Node3D.new()
	g.name = nama
	g.position = Vector3((x_a + x_b) * 0.5, (y_a + y_b) * 0.5, z_tengah)
	g.rotation.z = sudut
	parent.add_child(g)
	# Papan rampa (visual kayu). PENTING (pelajaran TanggaSurau +
	# probe flight B 18 Nov 01:0x WIB): permukaan ATAS papan HARUS
	# tepat pada garis lereng — papan digantung 0,3 m DI BAWAH garis.
	# "Di bawah" dalam koordinat lokal BERGANTUNG arah naik: bila
	# rampa naik ke timur (x_b > x_a, rotasi lancip) local +Y adalah
	# normal permukaan → papan di local y=-0,3; bila naik ke barat
	# (x_b < x_a, rotasi tumpul >90°) local +Y menunjuk ke bawah
	# sehingga papan harus di local y=+0,3. Salah tanda membuat papan
	# menggantung DI ATAS garis dan sudut bawahnya (8,865, 2,078)
	# menjepit pemain di bordes ke dinding timur annex.
	var off_y := -0.3 if x_b > x_a else 0.3
	g.add_child(Palette.box(Vector3(panjang, 0.6, lebar), Vector3(0, off_y, 0), Palette.KAYU))
	# Collision papan (kotak yang sama, di bawah garis lereng).
	var body := StaticBody3D.new()
	body.position = Vector3(0, off_y, 0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(panjang, 0.6, lebar)
	shape.shape = box
	body.add_child(shape)
	g.add_child(body)
	# Strip anak tangga visual (menempel permukaan, menonjol 0,01).
	for i in range(8):
		var xi := -panjang * 0.5 + (float(i) + 0.5) * panjang / 8.0
		g.add_child(Palette.box(Vector3(0.08, 0.02, lebar - 0.04), Vector3(xi, 0.0, 0), Palette.JATI))
