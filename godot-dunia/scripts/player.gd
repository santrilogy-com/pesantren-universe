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
const PAKAIAN_DEFAULT := {"sarung_scale": Vector3.ONE, "sarung_y": 0.50, "hem_scale": Vector3(1.0, 0.25, 1.0), "hem_y": 0.12, "trim_y": 0.14, "torso_scale": Vector3.ONE, "peci_z": 1.0}
const PAKAIAN_DUDUK := {"sarung_scale": Vector3(1.70, 0.45, 1.70), "sarung_y": 0.65, "hem_scale": Vector3(1.70, 0.20, 1.70), "hem_y": 0.50, "trim_y": 0.50, "torso_scale": Vector3.ONE, "peci_z": 1.0}
const PAKAIAN_TIDUR := {"sarung_scale": Vector3(1.15, 1.0, 0.55), "sarung_y": 0.50, "hem_scale": Vector3(1.15, 0.25, 0.5), "hem_y": 0.12, "trim_y": 0.14, "torso_scale": Vector3(1.0, 1.0, 0.6), "peci_z": 0.7}
# SUSULAN RONDE 20 (Mas 19:42 WIB: kostum Ustadzah "malah kek ustadz"
# — koko + sarung batik + penutup kepala seperti songkok): ABAYA +
# JILBAB. Abaya = SATU gamis panjang longgar (bahu -> mata kaki),
# menggantikan koko + sarung sekaligus. Target duduknya SENDIRI:
# PAKAIAN_DUDUK (sarung mengerut y 0.45) akan menghancurkan gamis
# 1,32 m sampai lutut dan membuka kaki bersila — abaya duduk justru
# MELEBAR (1.55) + sedikit memendek (0.78), tetap menutupi kaki
# bersila sampai lantai (hem dunia ~0.04 saat visual turun -0.42).
const PAKAIAN_ABAYA_DEFAULT := {"sarung_scale": Vector3.ONE, "sarung_y": 0.76, "hem_scale": Vector3(1.0, 0.25, 1.0), "hem_y": 0.12, "trim_y": 0.14, "torso_scale": Vector3.ONE, "peci_z": 1.0}
const PAKAIAN_ABAYA_DUDUK := {"sarung_scale": Vector3(1.65, 0.72, 1.65), "sarung_y": 0.95, "hem_scale": Vector3(1.65, 0.25, 1.65), "hem_y": 0.44, "trim_y": 0.46, "torso_scale": Vector3.ONE, "peci_z": 1.0}

## Arah gerak di ruang pesantren (sudah relatif kamera), panjang 0..1.
var move_dir: Vector3 = Vector3.ZERO

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
# Perbaikan 15 Nov ~12:00 WIB: ayunan jalan dihaluskan — amplitudo naik/
# turun bertahap (blend) saat mulai/berhenti, bukan langsung penuh lalu
# berhenti mendadak; badan sedikit condong ke depan saat berjalan.
var _anim_blend: float = 0.0
# RONDE 6 — pose/aksi karakter.
var _aksi: String = "berdiri"
var _aksi_timer: float = 0.0
var _bawa_kitab: bool = false
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
var _torso: MeshInstance3D
var _peci: MeshInstance3D
## Nama pemain (label di atas kepala) — disimpan supaya
## bangun_ulang_visual() membangun ulang dengan nama yang sama.
var _nama: String = "Santri"


func _ready() -> void:
	_pasang_visual(SantriPlayer.build_visual(_nama, MissionData.OUTFIT_DEFAULT))
	_outfit = MissionData.OUTFIT_DEFAULT.duplicate()


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
	_torso = built["torso"]
	_peci = built["peci"]
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
	if lama != null:
		remove_child(lama)
		lama.queue_free()


## Apakah visual saat ini muslimah (abaya + jilbab)?
func apakah_muslimah() -> bool:
	return bool(_outfit.get("muslimah", false))


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
	var terang := warna.lerp(krem, 0.55)
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
		if m != null and m.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED:
			if m.albedo_texture != null:
				m.roughness = 0.45
			else:
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
	var muslimah: bool = bool(outfit.get("muslimah", false))
	var warna_abaya: Color = Color(String(outfit.get("abaya", "#065f46")))
	# KIRANA 17 Nov 2026 (Mas: abaya bisa dikostum): untuk muslimah,
	# torso + lengan sewarna abaya (bukan koko) — sama seperti
	# Ustadzah (koko-nya = warna abaya). Santriwan tidak berubah.
	var warna_baju: Color = warna_abaya if muslimah else koko
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
	var warna_paha: Color = warna_abaya if muslimah else sarung_color
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
	var sandal_l := Palette.cylinder(0.11, 0.11, 0.035, Vector3(0, -0.285, -0.02), Color("#5a3a22"))
	sandal_l.scale = Vector3(0.9, 1.0, 1.5)
	sandal_l.name = "SandalKiri"
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
	var sandal_r := Palette.cylinder(0.11, 0.11, 0.035, Vector3(0, -0.285, -0.02), Color("#5a3a22"))
	sandal_r.scale = Vector3(0.9, 1.0, 1.5)
	sandal_r.name = "SandalKanan"
	knee_r.add_child(sandal_r)
	root.add_child(leg_r)

	# Pakaian bawah — dua bentuk, SATU slot ("sarung" di dictionary,
	# supaya _lerp_pakaian / _terapkan_pakaian NPC tetap jalan):
	# muslimah = ABAYA (satu gamis panjang longgar bahu -> mata kaki,
	# tanpa motif batik, tanpa sarung terpisah); yang lain = sarung.
	var sarung: MeshInstance3D = null
	var hem: MeshInstance3D = null
	var sarung_trim: MeshInstance3D = null
	var abaya: MeshInstance3D = null
	if muslimah:
		# ABAYA (SUSULAN RONDE 20, Mas 19:42 WIB): tabung meruncing
		# atas r=0.23 (bahu) -> bawah r=0.36 (hem lebar), tinggi
		# 1.32, pusat y=0.76 — bawah di y=0.10 (mata kaki, sama
		# seperti sarung ronde 6), atas di y=1.42 (menutupi pinggang
		# + dada bawah; torso di atasnya sewarna jadi satu gamis).
		# Polos zamrud gelap #065f46 — BUKAN batik (motif batik itu
		# yang membuat roknya terbaca "sarung santri").
		abaya = Palette.cylinder(0.23, 0.36, 1.32, Vector3(0, 0.76, 0), warna_abaya)
		abaya.name = "Abaya"
		root.add_child(abaya)
		sarung = abaya
		hem = Palette.sphere(0.36, Vector3(0, 0.12, 0), warna_abaya)
		hem.scale = Vector3(1.0, 0.25, 1.0)
		hem.name = "AbayaHem"
		root.add_child(hem)
		# Lis emas di ujung abaya (palet pesantren, seperti sarung).
		sarung_trim = Palette.cylinder(0.36, 0.36, 0.04, Vector3(0, 0.14, 0), Palette.EMAS, 0.4)
		sarung_trim.name = "AbayaTrim"
		root.add_child(sarung_trim)
	else:
		# Sarung SAMPAI MATA KAKI (RONDE 6): tabung zamrud tinggi 0.80,
		# pusat y=0.50 — bawah di y=0.10 (pergelangan kaki), atas di y=0.90
		# (menutupi pinggang). Hem membulat + lis emas mengikuti bawah.
		sarung = Palette.cylinder(0.20, 0.29, 0.80, Vector3(0, 0.50, 0), sarung_color)
		sarung.material_override = _motif_sarung(sarung_color)
		sarung.name = "Sarung"
		root.add_child(sarung)
		hem = Palette.sphere(0.29, Vector3(0, 0.12, 0), sarung_color)
		hem.scale = Vector3(1.0, 0.25, 1.0)
		hem.name = "SarungHem"
		root.add_child(hem)
		# Lis emas di ujung sarung.
		sarung_trim = Palette.cylinder(0.29, 0.29, 0.04, Vector3(0, 0.14, 0), Palette.EMAS, 0.4)
		sarung_trim.name = "SarungTrim"
		root.add_child(sarung_trim)

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
	# abaya — pivot ±0.34 (di luar permukaan abaya 0.242 di
	# y=1.30) + miring keluar 0.12 + lengan sedikit lebih tebal
	# supaya sleeve abaya terbaca, bukan lidi yang tenggelam di
	# gamis. Lengan santriwan/Kyai tetap ±0.235 / 0.05.
	var lengan_x := 0.34 if muslimah else 0.235
	var lengan_miring := 0.12 if muslimah else 0.05
	var r_lengan_atas := 0.11 if muslimah else 0.10
	var r_lengan_bawah := 0.085 if muslimah else 0.08
	var arm_l := Node3D.new()
	arm_l.position = Vector3(lengan_x, 1.30, 0)
	arm_l.rotation.z = lengan_miring
	var bahu_l := Palette.sphere(0.095, Vector3(0, 0, 0), warna_baju)
	bahu_l.name = "BahuKiri"
	arm_l.add_child(bahu_l)
	var lengan_atas_l := Palette.cylinder(r_lengan_atas, r_lengan_bawah, 0.30, Vector3(0, -0.15, 0), warna_baju)
	lengan_atas_l.name = "LenganAtasKiri"
	arm_l.add_child(lengan_atas_l)
	var elbow_l := Node3D.new()
	elbow_l.position = Vector3(0, -0.30, 0)
	arm_l.add_child(elbow_l)
	var siku_l := Palette.sphere(0.08, Vector3(0, 0, 0), warna_baju)
	siku_l.name = "SikuKiri"
	elbow_l.add_child(siku_l)
	var lengan_bawah_l := Palette.cylinder(r_lengan_bawah, 0.06 if muslimah else 0.058, 0.26, Vector3(0, -0.13, 0), warna_baju)
	lengan_bawah_l.name = "LenganBawahKiri"
	elbow_l.add_child(lengan_bawah_l)
	var tangan_l := Palette.sphere(0.072, Vector3(0, -0.29, 0.01), kulit)
	tangan_l.scale = Vector3(1.0, 0.7, 1.3)
	tangan_l.name = "TanganKiri"
	elbow_l.add_child(tangan_l)
	root.add_child(arm_l)
	var arm_r := Node3D.new()
	arm_r.position = Vector3(-lengan_x, 1.30, 0)
	arm_r.rotation.z = -lengan_miring
	var bahu_r := Palette.sphere(0.095, Vector3(0, 0, 0), warna_baju)
	bahu_r.name = "BahuKanan"
	arm_r.add_child(bahu_r)
	var lengan_atas_r := Palette.cylinder(r_lengan_atas, r_lengan_bawah, 0.30, Vector3(0, -0.15, 0), warna_baju)
	lengan_atas_r.name = "LenganAtasKanan"
	arm_r.add_child(lengan_atas_r)
	var elbow_r := Node3D.new()
	elbow_r.position = Vector3(0, -0.30, 0)
	arm_r.add_child(elbow_r)
	var siku_r := Palette.sphere(0.08, Vector3(0, 0, 0), warna_baju)
	siku_r.name = "SikuKanan"
	elbow_r.add_child(siku_r)
	var lengan_bawah_r := Palette.cylinder(r_lengan_bawah, 0.06 if muslimah else 0.058, 0.26, Vector3(0, -0.13, 0), warna_baju)
	lengan_bawah_r.name = "LenganBawahKanan"
	elbow_r.add_child(lengan_bawah_r)
	var tangan_r := Palette.sphere(0.072, Vector3(0, -0.29, 0.01), kulit)
	tangan_r.scale = Vector3(1.0, 0.7, 1.3)
	tangan_r.name = "TanganKanan"
	elbow_r.add_child(tangan_r)
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
	if muslimah:
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
		jenggot = Palette.sphere(0.19, Vector3(0, 1.51, 0.06), warna_jenggot)
		jenggot.scale = Vector3(1.05, 0.85, 0.72)
		jenggot.name = "Jenggot"
		root.add_child(jenggot)
		uban = Palette.sphere(0.11, Vector3(0, 1.395, 0.09), warna_uban)
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
		# SUSULAN RONDE 20 (Mas 19:42 WIB: kostum Ustadzah "malah
		# kek ustadz"): JILBAB, bukan topi. Yang lama (kubah kecil +
		# drape + cape, semuanya zamrud gelap) dari jauh terbaca
		# songkok hijau di atas koko putih + sarung batik — siluet
		# laki-laki. Kini: krem #f2ead6 di atas abaya zamrud gelap —
		# kontrasnya yang membuat jilbab terbaca dari jauh. Enam
		# bagian: kubah + drape belakang + cape bahu + drape depan
		# (dada) + 2 strip sisi pembingkai wajah.
		# Geometri terukur dari kepala (bola r=0.24 di y=1.66, mata
		# di (±0.085, 1.69, 0.222), alis 1.735, mulut 1.55, dagu
		# ~1.47): kubah r=0.255 di (0,1.79,-0.04) — permukaan depan
		# di tinggi mata z~0.16 (mata di 0.222 + alis 0.222 tetap
		# di depan kubah, wajah TIDAK tertutup); tepi depan kubah
		# menyilang wajah di y~1.73 (tepat di atas alis, seperti
		# jilbab sungguhan); puncak kubah 1.94 menutupi ubun.
		# KIRANA 16 Nov ~21:45 WIB (kubah lama r=0.28 terlalu
		# besar dan bulat seperti boneka): kubah dikecilkan.
		hijab = Node3D.new()
		hijab.name = "Hijab"
		var kubah := Palette.sphere(0.255, Vector3(0, 1.79, -0.04), warna_hijab)
		kubah.scale = Vector3(1.05, 0.58, 1.05)
		kubah.name = "HijabKubah"
		hijab.add_child(kubah)
		# Drape belakang: menutupi belakang kepala + tengkuk +
		# punggung atas (y 0.98..1.73, z -0.29..-0.23), sedikit miring.
		var drape := Palette.box(Vector3(0.50, 0.75, 0.06), Vector3(0, 1.35, -0.26), warna_hijab.darkened(0.03))
		drape.rotation.x = -0.08
		drape.name = "HijabDrape"
		hijab.add_child(drape)
		# Cape bahu: menutupi leher + bahu (y 1.27..1.49, x ±0.46),
		# lengan keluar dari bawah cape seperti gamis sungguhan.
		# Sengaja LEBIH BESAR dari abaya saat duduk (abaya melebar
		# 1.55x + puncaknya naik ke 1.48 — cape lama r=0.34 tenggelam
		# di balik abaya sehingga bahu terbaca tabung polos).
		# KIRANA 16 Nov ~21:45 WIB: cape lama scale y 0.40 terlalu
		# menggembung seperti pelampung — dipipihkan (0.28) jadi
		# drape bahu, lebar x tetap ±0.46 supaya saat duduk tetap
		# di luar abaya yang melebar.
		var cape := Palette.sphere(0.40, Vector3(0, 1.38, -0.04), warna_hijab)
		cape.scale = Vector3(1.15, 0.28, 0.90)
		cape.name = "HijabCape"
		hijab.add_child(cape)
		# Drape depan: kain jilbab di depan dada, dari bawah dagu
		# (y 1.41, di bawah mulut 1.55) sampai pinggang (y 0.95).
		# KIRANA 16 Nov ~21:45 WIB (drape lama kotak 0.44×0.48
		# terbaca celemek persegi): kini elipsoid pipih — atas
		# meruncing ke bawah dagu, tengah terlebar di dada,
		# bawah membulat seperti ujung kain; ujung atas terselip
		# di balik cape (depan cape z~0.32 di y=1.38, drape 0.28).
		# KIRANA revisi 21:52 WIB: drape lama (skala x 0.85) di
		# foto 05g terlalu lebar — menutupi hampir seluruh dada
		# seperti pelat. Dipersempit ke 0.72 supaya terbaca kain
		# jilbab, bukan celemek.
		var depan := Palette.sphere(0.20, Vector3(0, 1.18, 0.24), warna_hijab)
		depan.scale = Vector3(0.72, 1.15, 0.45)
		depan.name = "HijabDepan"
		hijab.add_child(depan)
		# Strip sisi: membingkai wajah kiri-kanan (y 1.36..1.76) —
		# ujung atas masuk ke dalam kubah, ujung bawah bertemu cape;
		# permukaan depan strip (z=0.10) tepat di luar pipi (0.095),
		# jadi wajah tetap terbuka, bukan tertutup kain. KIRANA
		# 16 Nov ~21:45 WIB: strip lama (lebar 0.10 di x=±0.21)
		# menjepit wajah jadi 0.32 — dipindah ke ±0.235 dan
		# dipersempit 0.08 supaya bukaan wajah 0.39, tidak topeng.
		for sx in [-1.0, 1.0]:
			var sisi := Palette.box(Vector3(0.08, 0.40, 0.20), Vector3(sx * 0.235, 1.56, 0.0), warna_hijab.darkened(0.03))
			sisi.name = "HijabSisiKiri" if sx < 0.0 else "HijabSisiKanan"
			hijab.add_child(sisi)
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
		# samping, DAN belakang, atas kepala PUTIH. Duduk rendah
		# (pusat y=1.77, tepi bawah ~1.70 di atas mata 1.69), puncak
		# 1.934 (0.034 di atas puncak kepala 1.90). Lis lama diganti
		# PeciBand yang mengikuti radius kubah baru (0.26/0.27 di y=1.75).
		peci = Palette.sphere(0.265, Vector3(0, 1.77, 0), songkok)
		peci.scale = Vector3(1.0, 0.62, 1.0)
		peci.name = "Peci"
		root.add_child(peci)
		# Lis songkok: pita tipis di tepi bawah kubah (sedikit lebih gelap).
		peci_band = Palette.cylinder(0.26, 0.27, 0.04, Vector3(0, 1.75, 0), songkok.darkened(0.12))
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
		"sarung": sarung,
		"sarung_hem": hem,
		"sarung_trim": sarung_trim,
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
	}


## Kacamata (RONDE 11): bingkai hitam + lensa bening. Tiap lensa =
## bingkai kotak (4 batang tipis) + kaca lensa tembus pandang
## (alpha 0.35 supaya mata tetap terlihat) di depan mata; jembatan
## di atas hidung + 2 gagang ke arah telinga. Posisi dihitung dari
## mata (±0.085, 1.69, 0.222): bingkai 0.11 x 0.08 di z=0.24 (1-2 cm
## di depan permukaan wajah — wajar untuk kacamata), gagang ke
## belakang sampai permukaan kepala (z~0.19 di x=±0.14).
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
		_batang(g, Vector3(0.11, 0.012, 0.012), Vector3(cx, 1.73, 0.24), bingkai)
		_batang(g, Vector3(0.11, 0.012, 0.012), Vector3(cx, 1.65, 0.24), bingkai)
		_batang(g, Vector3(0.012, 0.08, 0.012), Vector3(cx - 0.055, 1.69, 0.24), bingkai)
		_batang(g, Vector3(0.012, 0.08, 0.012), Vector3(cx + 0.055, 1.69, 0.24), bingkai)
		var lensa := MeshInstance3D.new()
		var lensa_mesh := BoxMesh.new()
		lensa_mesh.size = Vector3(0.10, 0.07, 0.006)
		lensa.mesh = lensa_mesh
		lensa.position = Vector3(cx, 1.69, 0.238)
		lensa.material_override = lensa_mat
		g.add_child(lensa)
		_batang(g, Vector3(0.012, 0.012, 0.10), Vector3(sx * 0.14, 1.70, 0.19), bingkai)
	_batang(g, Vector3(0.06, 0.012, 0.012), Vector3(0, 1.71, 0.24), bingkai)
	return g


## Satu batang bingkai kacamata (kotak tipis).
static func _batang(parent: Node3D, ukuran: Vector3, pos: Vector3, bahan: Material) -> void:
	var batang := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = ukuran
	batang.mesh = mesh
	batang.position = pos
	batang.material_override = bahan
	parent.add_child(batang)


func set_facing(yaw: float) -> void:
	_visual.rotation.y = yaw


## Arah hadap karakter (radian, 0 = utara/-Z) — untuk minimap GTA.
func get_facing_yaw() -> float:
	return _visual.rotation.y


func set_nama(nama: String) -> void:
	_nama = nama
	# Label nama adalah Label3D di y=2.05 (dulu bubble chat di y=2.45
	# — BUBBLE-ML: bubble dimatikan, hanya label nama yang dicari).
	for c in _visual.get_children():
		if c is Label3D and c.position.y > 2.0 and c.position.y < 2.2:
			(c as Label3D).text = nama
			return


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
	var muslimah: bool = bool(outfit.get("muslimah", false))
	var warna_abaya: Color = Color(String(outfit.get("abaya", "#065f46")))
	var warna_baju: Color = warna_abaya if muslimah else koko
	# RONDE 11: cari node REKURSIF (find_child), bukan get_node_or_null
	# — dulu "BahuKiri"/"LenganAtasKiri" dll TIDAK PERNAH ketemu karena
	# mereka anak dari pivot lengan (bukan anak langsung visual), jadi
	# ganti koko hanya mewarnai torso + kerah, lengan tetap putih.
	# Temuan laten saat mengerjakan kulit; kini semua bagian terwarnai.
	for nama_node in ["Torso", "Kerah", "BahuKiri", "BahuKanan", "SikuKiri", "SikuKanan", "LenganAtasKiri", "LenganAtasKanan", "LenganBawahKiri", "LenganBawahKanan"]:
		var n := _visual.find_child(nama_node, true, false)
		if n is MeshInstance3D:
			(n as MeshInstance3D).material_override = Palette.mat(warna_baju, 0.0, 0.45)
	var peci := _visual.find_child("Peci", true, false)
	if peci is MeshInstance3D:
		(peci as MeshInstance3D).material_override = Palette.mat(songkok, 0.0, 0.45)
	# RONDE 9: lis songkok ikut warna songkok (sedikit lebih gelap).
	var peci_band := _visual.find_child("PeciBand", true, false)
	if peci_band is MeshInstance3D:
		(peci_band as MeshInstance3D).material_override = Palette.mat(songkok.darkened(0.12), 0.0, 0.45)
	var sarung := _visual.find_child("Sarung", true, false)
	if sarung is MeshInstance3D:
		(sarung as MeshInstance3D).material_override = _motif_sarung(sarung_color)
	var hem := _visual.find_child("SarungHem", true, false)
	if hem is MeshInstance3D:
		(hem as MeshInstance3D).material_override = Palette.mat(sarung_color, 0.0, 0.45)
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
			(na as MeshInstance3D).material_override = Palette.mat(warna_abaya, 0.0, 0.45)
	var warna_hijab: Color = Color(String(outfit.get("hijab_warna", "#f2ead6")))
	for nama_hijab in ["HijabKubah", "HijabCape", "HijabDepan"]:
		var nh := _visual.find_child(nama_hijab, true, false)
		if nh is MeshInstance3D:
			(nh as MeshInstance3D).material_override = Palette.mat(warna_hijab, 0.0, 0.45)
	# Drape + strip sisi memakai warna yang sama, sedikit digelapkan
	# (0.03) seperti saat build_visual membangunnya.
	for nama_hijab_gelap in ["HijabDrape", "HijabSisiKiri", "HijabSisiKanan"]:
		var ng := _visual.find_child(nama_hijab_gelap, true, false)
		if ng is MeshInstance3D:
			(ng as MeshInstance3D).material_override = Palette.mat(warna_hijab.darkened(0.03), 0.0, 0.45)


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
	_aksi = nama
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
## sholat): main.gd menolkan input gerak selama pose ini supaya pose
## tidak rusak oleh animasi jalan. Berdiri + bawa kitab boleh jalan.
func sedang_aksi_diam() -> bool:
	return _aksi in ["duduk", "menulis", "tidur", "salaman", "melambai", "sholat"]


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


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	var v := move_dir
	if v.length() > 1.0:
		v = v.normalized()
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
	# Pose berwaktu (salaman/melambai 3 detik) kembali berdiri sendiri.
	if _aksi_timer > 0.0:
		_aksi_timer -= delta
		if _aksi_timer <= 0.0:
			set_aksi("berdiri")
	# Pose diam (duduk/menulis/tidur/salaman/melambai) menggantikan
	# animasi jalan — anggota gerak di-lerp ke target pose.
	if sedang_aksi_diam():
		_terapkan_pose(delta)
		return
	# Animasi jalan (halus): amplitudo mengikuti blend 0..1.
	# SUSULAN RONDE 20: bobot lerp DIJEPIT ke 1.0 — alasan sama
	# seperti yaw di atas (RONDE 5) dan _animate_idle NPC: di frame
	# lambat, delta*8 / delta*10 > 1 membuat lerp divergen sampai
	# nilai tak-hingga (Satpam NPC kena ini). Semua lerp pose di
	# bawah (_terapkan_pose) sudah dijepit; yang di sini ketinggalan.
	var k8 := minf(1.0, delta * 8.0)
	var k10 := minf(1.0, delta * 10.0)
	if v.length() > 0.1:
		_anim_blend = minf(1.0, _anim_blend + delta * 6.0)
		_walk_time += delta * 9.0
		var s := sin(_walk_time) * 0.5 * _anim_blend
		_arm_l.rotation.x = s
		_arm_r.rotation.x = -s
		_leg_l.rotation.x = -s
		_leg_r.rotation.x = s
		# RONDE DUDUK: lutut menekuk saat paha mengayun ke depan
		# (kaki tidak lagi kaku seperti papan saat jalan).
		_knee_l.rotation.x = clampf(s, 0.0, 1.0) * 0.5
		_knee_r.rotation.x = clampf(-s, 0.0, 1.0) * 0.5
		_visual.position.y = absf(sin(_walk_time)) * 0.03 * _anim_blend
		_visual.rotation.x = lerpf(_visual.rotation.x, 0.05 * _anim_blend, k8)
	else:
		_anim_blend = maxf(0.0, _anim_blend - delta * 8.0)
		_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k10)
		_arm_r.rotation.x = lerpf(_arm_r.rotation.x, 0.0, k10)
		_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k10)
		_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k10)
		_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 0.0, k10)
		_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 0.0, k10)
		# Napas idle (RONDE 4, bonus "tampilan masih kaku"): naik-turun
		# halus ~1,5 cm saat diam — badan tidak lagi seperti patung.
		_visual.position.y = lerpf(_visual.position.y, sin(Time.get_ticks_msec() * 0.002) * 0.015, k8)
		_visual.rotation.x = lerpf(_visual.rotation.x, 0.0, k10)
	# Bawa kitab (toggle): tangan kanan sedikit ke depan memegang
	# kitab — menimpa ayunan/idle lengan kanan (tangan kiri tetap
	# mengayun normal). Siku kanan menekuk memegang kitab.
	if _bawa_kitab:
		_arm_r.rotation.x = -0.55 - sin(_walk_time) * 0.1 * _anim_blend
		_elbow_r.rotation.x = -0.5
	# RONDE 9: di luar pose diam, kembalikan pakaian ke normal
	# (sarung mengerut saat duduk, sarung+torso pipih saat tidur —
	# tanpa ini pakaian pose terakhir menempel saat berdiri/jalan).
	# Dijalankan di sini karena fungsi ini return lebih awal saat
	# sedang_aksi_diam(), jadi baris ini hanya jalan di luar pose diam.
	_lerp_pakaian(delta, PAKAIAN_DEFAULT)


## Pose prosedural (RONDE 6): semua target di-lerp halus (bobot
## dijepit 1.0) supaya perubahan pose tidak patah.
func _terapkan_pose(delta: float) -> void:
	var k := minf(1.0, delta * 8.0)
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
			_visual.position.y = lerpf(_visual.position.y, -0.42, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -0.85, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -0.85, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.50, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, -0.50, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.10, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, -0.10, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 2.30, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 2.30, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.20, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, -0.20, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.35, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.35, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.20, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.20, k)
			_lerp_pakaian(delta, PAKAIAN_DUDUK)
		"menulis":
			# Menulis RONDE DUDUK: kaki sama seperti duduk (paha -0.85,
			# lutut +2.30 — bersila terlipat, bukan batang kaku);
			# badan membungkuk 0.20 ke kitab; tangan MENULIS (lengan
			# -0.50, siku -0.50) sampai ke kitab di pangkuan, bukan
			# melayang di dada; tangan kanan menulis bergoyang.
			_menulis_t += delta
			_visual.position.y = lerpf(_visual.position.y, -0.42, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.20, k)
			_leg_l.rotation.x = lerpf(_leg_l.rotation.x, -0.85, k)
			_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -0.85, k)
			_leg_l.rotation.y = lerpf(_leg_l.rotation.y, 0.50, k)
			_leg_r.rotation.y = lerpf(_leg_r.rotation.y, -0.50, k)
			_leg_l.rotation.z = lerpf(_leg_l.rotation.z, 0.10, k)
			_leg_r.rotation.z = lerpf(_leg_r.rotation.z, -0.10, k)
			_knee_l.rotation.x = lerpf(_knee_l.rotation.x, 2.30, k)
			_knee_r.rotation.x = lerpf(_knee_r.rotation.x, 2.30, k)
			_knee_l.rotation.y = lerpf(_knee_l.rotation.y, 0.20, k)
			_knee_r.rotation.y = lerpf(_knee_r.rotation.y, -0.20, k)
			_knee_l.rotation.z = lerpf(_knee_l.rotation.z, 0.0, k)
			_knee_r.rotation.z = lerpf(_knee_r.rotation.z, 0.0, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -0.50, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -0.50 + sin(_menulis_t * 6.0) * 0.06, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, -0.20, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, 0.20, k)
			_elbow_l.rotation.x = lerpf(_elbow_l.rotation.x, -0.50, k)
			_elbow_r.rotation.x = lerpf(_elbow_r.rotation.x, -0.45, k)
			_lerp_pakaian(delta, PAKAIAN_DUDUK)
		"salaman":
			# Salaman: tangan kanan terulur ke depan (jabat tangan),
			# badan sedikit condong. Hadap ke NPC diatur main.gd.
			_visual.position.y = lerpf(_visual.position.y, 0.0, k)
			_visual.rotation.x = lerpf(_visual.rotation.x, 0.08, k)
			_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
			_arm_r.rotation.x = lerpf(_arm_r.rotation.x, -1.45, k)
			_arm_l.rotation.z = lerpf(_arm_l.rotation.z, 0.05, k)
			_arm_r.rotation.z = lerpf(_arm_r.rotation.z, -0.05, k)
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
	if _sarung_hem != null:
		_sarung_hem.scale = _sarung_hem.scale.lerp(target["hem_scale"], k)
		_sarung_hem.position.y = lerpf(_sarung_hem.position.y, target["hem_y"], k)
	if _sarung_trim != null:
		_sarung_trim.position.y = lerpf(_sarung_trim.position.y, target["trim_y"], k)
	if _torso != null:
		_torso.scale = _torso.scale.lerp(target["torso_scale"], k)
	if _peci != null:
		_peci.scale.z = lerpf(_peci.scale.z, target["peci_z"], k)


func _process(delta: float) -> void:
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
