class_name KampusPutri
## RONDE 21 (16 Nov) — Relokasi kampus putri ke Opsi A — Terjauh (ACC Mas 22:03 WIB).
## File ini HANYA berisi kampus putri. Dibangun oleh Cakra, digabung oleh Raka.
## Kontrak: static func build(root: Node3D) -> Dictionary.
## Anak KampusPutri: Musholla, CangkrukPutri, KelasPutri, AsramaPutri,
## KantorUstadzah, Madrasah, Studio, PosJagaTL, JalanInternal.
## Sumbu: +x timur, +z selatan, y=0 tanah. Semua koordinat anak ditulis
## absolut (pola builder: root di origin, anak berkoordinat dunia).
## JANGAN sebut pesantren "dunia".

## Posisi Opsi A (konstanta — dipakai dict kembalian juga).
const MUSHOLLA_POS := Vector3(134, 0, -24)
const CANGKRUK_PUTRI_POS := Vector3(128, 0, -12)
const KELAS_PUTRI_POS := Vector3(130, 0, 0)
const ASRAMA_PUTRI_POS := Vector3(152, 0, 0)
const KANTOR_USTADZAH_POS := Vector3(150, 0, -28)
const MADRASAH_POS := Vector3(152, 0, -12)
const STUDIO_POS := Vector3(166, 0, -12)
const POS_JAGA_TL_POS := Vector3(160, 0, -35)
const SPAWN_PUTRI := Vector3(130, 0, 14)
const JALAN_INTERNAL_X := 142.0

## Pintu Musholla baru: sisi selatan (menghadap spawn putri).
const MUSHOLLA_DOOR := Vector3(134, 0, -19)
## Keluar = pintu + normal selatan (0,0,1) x 1,5 m.
const MUSHOLLA_EXIT := Vector3(134, 0, -17.5)

## Ukuran pintu gedung generik.
const LEBAR_PINTU := 1.6
const TINGGI_PINTU := 2.6


static func build(root: Node3D) -> Dictionary:
	var kampus := Node3D.new()
	kampus.name = "KampusPutri"
	root.add_child(kampus)
	_musholla(kampus)
	_cangkruk_putri(kampus)
	_gedung(kampus, "KelasPutri", KELAS_PUTRI_POS.x, KELAS_PUTRI_POS.z, 10, 8, 3.6, "S", "KELAS PUTRI")
	# RONDE PERBAIKAN (Raka, integrasi item 14 permanen): daun pintu
	# TERTUTUP di celah pintu selatan KelasPutri — interior Kelas masih
	# cangkang kosong (belum ada map interior seperti Surau/Musholla),
	# jadi pintunya dikunci rapat; pemain tidak lagi bisa masuk lalu
	# mentok di dinding utara. Kalau suatu hari Kelas punya interior,
	# daun ini dibuka/diganti logika pintu.
	_daun_pintu_kelas_putri(kampus)
	_gedung(kampus, "AsramaPutri", ASRAMA_PUTRI_POS.x, ASRAMA_PUTRI_POS.z, 12, 8, 4.0, "W", "ASRAMA PUTRI")
	_gedung(kampus, "KantorUstadzah", KANTOR_USTADZAH_POS.x, KANTOR_USTADZAH_POS.z, 8, 6, 3.4, "W", "KANTOR USTADZAH")
	_gedung(kampus, "Madrasah", MADRASAH_POS.x, MADRASAH_POS.z, 10, 8, 3.8, "W", "MADRASAH")
	_gedung(kampus, "Studio", STUDIO_POS.x, STUDIO_POS.z, 10, 8, 3.6, "N", "STUDIO")
	_pos_jaga_tl(kampus)
	_jalan_internal(kampus)
	return {
		"musholla_door": MUSHOLLA_DOOR,
		"musholla_exit": MUSHOLLA_EXIT,
		"spawn_putri": SPAWN_PUTRI,
		"musholla_pos": MUSHOLLA_POS,
		"cangkruk_putri_pos": CANGKRUK_PUTRI_POS,
		"kelas_putri_pos": KELAS_PUTRI_POS,
		"asrama_putri_pos": ASRAMA_PUTRI_POS,
		"kantor_ustadzah_pos": KANTOR_USTADZAH_POS,
		"madrasah_pos": MADRASAH_POS,
		"studio_pos": STUDIO_POS,
		"pos_jaga_tl": POS_JAGA_TL_POS,
		"jalan_internal_x": JALAN_INTERNAL_X,
	}


## Helper lokal (pola _static_box builder): box visual + StaticBody3D.
## Hiasan (kubah, bunga, pagar) TIDAK pakai ini — visual saja.
static func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, collide: bool = true) -> MeshInstance3D:
	var mi := Palette.box(size, pos, color)
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
		parent.add_child(body)
	return mi


## ------------------------------------------------------------------
## Musholla Ar-Raudhah BARU (134,-24) — desain ACC (DESAIN-ARSITEKTUR.md §2).
## Luar 12x10 m, dinding krem 4,0 m, 1 kubah zamrud kecil + bulan sabit
## emas, TANPA menara, serambi kayu di depan pintu selatan, 4 jendela
## lengkung (2 tiap sisi), pagar kayu keliling + taman bunga.
## Ini hanya CANGKANG LUAR — interior ada di map terpisah (JANGAN disentuh).
## ------------------------------------------------------------------
static func _musholla(kampus: Node3D) -> void:
	var m := Node3D.new()
	m.name = "Musholla"
	kampus.add_child(m)
	var cx := 134.0
	var cz := -24.0
	# Lantai.
	_static_box(m, Vector3(12, 0.14, 10), Vector3(cx, -0.05, cz), Palette.PUTIH)
	# Dinding: utara, barat, timur utuh; selatan dua segmen + ambang pintu.
	# Celah pintu 2,0 m di tengah dinding selatan (x 133..135, z=-19).
	_static_box(m, Vector3(12, 4.0, 0.25), Vector3(cx, 2.0, cz - 5), Palette.KREM)
	_static_box(m, Vector3(0.25, 4.0, 10), Vector3(cx - 6, 2.0, cz), Palette.KREM)
	_static_box(m, Vector3(0.25, 4.0, 10), Vector3(cx + 6, 2.0, cz), Palette.KREM)
	_static_box(m, Vector3(5.0, 4.0, 0.25), Vector3(cx - 3.5, 2.0, cz + 5), Palette.KREM)
	_static_box(m, Vector3(5.0, 4.0, 0.25), Vector3(cx + 3.5, 2.0, cz + 5), Palette.KREM)
	_static_box(m, Vector3(2.0, 1.0, 0.25), Vector3(cx, 3.5, cz + 5), Palette.KREM)
	# Atap datar zamrud + lis emas di bawahnya.
	m.add_child(Palette.box(Vector3(12.8, 0.1, 10.8), Vector3(cx, 4.0, cz), Palette.EMAS, 0.4))
	m.add_child(Palette.box(Vector3(12.6, 0.25, 10.6), Vector3(cx, 4.12, cz), Palette.ZAMRUD_GELAP))
	# Pilar sudut bundar BARAT saja (2) — pilar timur (cx+5.7) DIHAPUS Ronde 21:
	# audit jalan/lampu menemukan pilar timur mepet/di atas jalan: (139,7,-28,7)
	# mepet 0,80 m ke JalanUtama, dan (139,7,-19,3) berdiri 0,00 m di tengah
	# konektor Musholla. Sisi timur menghadap jalan internal — tidak boleh ada
	# tiang di dekat jalan (aturan Mas); pilar barat bersih dari jalan.
	for pz in [cz - 4.7, cz + 4.7]:
		m.add_child(Palette.cylinder(0.2, 0.22, 4.0, Vector3(cx - 5.7, 2.0, pz), Palette.KREM))
	# Jendela lengkung di dinding barat/timur (2 tiap sisi).
	for z in [cz - 2.5, cz + 2.5]:
		for x in [cx - 6.05, cx + 6.05]:
			m.add_child(Palette.box(Vector3(0.12, 1.4, 1.1), Vector3(x, 1.8, z), Palette.EMAS, 0.3))
			m.add_child(Palette.box(Vector3(0.1, 1.2, 0.9), Vector3(x, 1.8, z), Palette.ZAMRUD_GELAP))
	# --- KubahMusholla: 1 kubah zamrud kecil + bulan sabit emas ---
	# RONDE PERBAIKAN (Fajar): kubah LAMA menjuntai ke dalam ruangan —
	# drum r=1,6 (y 4,15..4,45) lebih kecil dari kubah r=2,0, dan bawah
	# bola y=3,01 (1 m di bawah plafon/atap 3,995): dari dalam, bola
	# hijau gelap melayang di langit-langit; dari luar, perut kubah
	# menjorok melewati drum (celah bayangan, "melayang"). Sekarang
	# pola Surau (drum + kubah): drum r=2,0 setinggi 1,44 m (y
	# 4,0..5,44, kaki di dalam pelat atap), kubah di atasnya (pusat
	# y=5,44; bawah y=4,0 = rata pelat atap, tidak menjuntai;
	# ekuator r=2,0 = rata drum, tidak menjorok). Tangkai + sabit ikut
	# naik ~1 m (puncak ~7,6 m).
	var kubah := Node3D.new()
	kubah.name = "KubahMusholla"
	m.add_child(kubah)
	kubah.add_child(Palette.cylinder(2.0, 2.0, 1.44, Vector3(cx, 4.72, cz), Palette.ZAMRUD_GELAP))
	var dome := Palette.sphere(2.0, Vector3(cx, 5.44, cz), Palette.ZAMRUD_GELAP, 0.3)
	dome.scale = Vector3(1, 0.72, 1)
	kubah.add_child(dome)
	kubah.add_child(Palette.cylinder(0.06, 0.06, 0.7, Vector3(cx, 7.05, cz), Palette.EMAS, 0.5))
	# Bulan sabit emas: torus tipis miring di puncak (pendekatan primitif).
	var sabit := MeshInstance3D.new()
	var sabit_mesh := TorusMesh.new()
	sabit_mesh.inner_radius = 0.14
	sabit_mesh.outer_radius = 0.3
	sabit_mesh.rings = 12
	sabit_mesh.ring_segments = 24
	sabit.mesh = sabit_mesh
	sabit.material_override = Palette.mat(Palette.EMAS, 0.5, 0.4)
	sabit.position = Vector3(cx, 7.45, cz)
	sabit.rotation.x = 0.5
	kubah.add_child(sabit)
	# --- PintuMusholla: ambang + tiang + lis emas (celah terbuka, pola lama) ---
	var pintu := Node3D.new()
	pintu.name = "PintuMusholla"
	m.add_child(pintu)
	pintu.add_child(Palette.box(Vector3(2.0, 0.024, 0.35), Vector3(cx, 0.012, cz + 5), Palette.EMAS, 0.4))
	pintu.add_child(Palette.box(Vector3(2.0, 0.12, 0.3), Vector3(cx, 3.06, cz + 5), Palette.EMAS, 0.4))
	pintu.add_child(Palette.cylinder(0.08, 0.08, 2.5, Vector3(cx - 1.06, 1.25, cz + 5), Palette.EMAS, 0.4))
	pintu.add_child(Palette.cylinder(0.08, 0.08, 2.5, Vector3(cx + 1.06, 1.25, cz + 5), Palette.EMAS, 0.4))
	# --- PlakatMusholla: papan zamrud berbingkai emas + "مصلى الروضة" ---
	var plakat := Node3D.new()
	plakat.name = "PlakatMusholla"
	m.add_child(plakat)
	plakat.add_child(Palette.box(Vector3(2.9, 0.7, 0.06), Vector3(cx, 3.65, cz + 5.16), Palette.EMAS, 0.4))
	plakat.add_child(Palette.box(Vector3(2.8, 0.6, 0.08), Vector3(cx, 3.65, cz + 5.19), Palette.ZAMRUD_GELAP))
	var plakat_label := Palette.label_arab("مصلى الروضة", Vector3(cx, 3.65, cz + 5.26), 36, Color("#f2c14e"))
	plakat_label.name = "PlakatTeks"
	plakat.add_child(plakat_label)
	# --- SerambiMusholla: lantai batu + 2 tiang jati + atap kayu + 1 anak tangga ---
	var serambi := Node3D.new()
	serambi.name = "SerambiMusholla"
	m.add_child(serambi)
	serambi.add_child(Palette.box(Vector3(4.5, 0.1, 2.8), Vector3(cx, 0.0, cz + 6.4), Palette.BATU))
	serambi.add_child(Palette.cylinder(0.12, 0.14, 3.0, Vector3(cx - 1.8, 1.5, cz + 7.4), Palette.JATI))
	serambi.add_child(Palette.cylinder(0.12, 0.14, 3.0, Vector3(cx + 1.8, 1.5, cz + 7.4), Palette.JATI))
	serambi.add_child(Palette.box(Vector3(4.8, 0.12, 3.0), Vector3(cx, 3.05, cz + 6.4), Palette.JATI))
	serambi.add_child(Palette.box(Vector3(4.8, 0.08, 0.1), Vector3(cx, 2.98, cz + 7.85), Palette.EMAS, 0.4))
	# Anak tangga rendah, visual saja (tanpa collision).
	serambi.add_child(Palette.box(Vector3(3.2, 0.08, 0.5), Vector3(cx, 0.04, cz + 8.05), Palette.BATU))
	# --- TamanMusholla: 2 bedeng bunga di TAMAN (luar bangunan) ---
	# RONDE PERBAIKAN (Fajar): bedeng LAMA di (138,5,-27,8) dan
	# (138,5,-20,2) jatuh DI DALAM ruang sholat (bangunan x 128..140,
	# z -29..-19) — dari dalam, "2 platform rendah + bola warna"
	# itu dibaca retest Ronde 23 sebagai rak kitab placeholder.
	# Bedeng kini di luar dinding, dalam pagar: timur-laut (strip
	# utara) dan barat-daya (strip selatan, barat serambi). Sudut
	# tenggara TIDAK dipakai — di sana jalan konektor ke pintu.
	var taman := Node3D.new()
	taman.name = "TamanMusholla"
	m.add_child(taman)
	for bed in [Vector2(cx + 4.5, cz - 6.0), Vector2(cx - 4.5, cz + 6.0)]:
		var bv: Vector2 = bed
		taman.add_child(Palette.box(Vector3(2.0, 0.3, 1.2), Vector3(bv.x, 0.15, bv.y), Palette.PASIR_GELAP))
		var warna_bunga: Array = [Color("#e88bb0"), Color("#f2c14e"), Color("#ffffff")]
		for i in range(6):
			var fx := bv.x - 0.7 + float(i) * 0.28
			var fz := bv.y + (0.25 if i % 2 == 0 else -0.25)
			taman.add_child(Palette.sphere(0.12, Vector3(fx, 0.42, fz), warna_bunga[i % 3]))
	# --- PagarMusholla: pagar kayu keliling, visual saja (tanpa collision) ---
	# Petak x 126..140, z -31..-17. Celah: selatan x 133..135 (depan pintu),
	# timur z -20.25..-17.75 (konektor ke jalan internal).
	var pagar := Node3D.new()
	pagar.name = "PagarMusholla"
	m.add_child(pagar)
	_pagar_kayu(pagar, Vector2(126, -31), Vector2(140, -31))
	_pagar_kayu(pagar, Vector2(126, -31), Vector2(126, -17))
	_pagar_kayu(pagar, Vector2(126, -17), Vector2(133, -17))
	_pagar_kayu(pagar, Vector2(135, -17), Vector2(140, -17))
	_pagar_kayu(pagar, Vector2(140, -31), Vector2(140, -20.25))
	_pagar_kayu(pagar, Vector2(140, -17.75), Vector2(140, -17))
	# Lampu hangat di dalam cangkang (pola lama).
	var lampu := OmniLight3D.new()
	lampu.position = Vector3(cx, 3.0, cz)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.5
	lampu.set_meta("energi_siang", 0.5)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 7.0
	lampu.shadow_enabled = false
	m.add_child(lampu)
	# Sandal Ustadzah di depan pintu (pola lama; muncul saat Ustadzah di dalam).
	var sandal_luar := Node3D.new()
	sandal_luar.name = "SandalLuarMusholla"
	sandal_luar.position = Vector3(cx + 0.8, 0, cz + 5.8)
	sandal_luar.visible = false
	m.add_child(sandal_luar)
	for sx in [-0.16, 0.16]:
		var sd := Palette.cylinder(0.11, 0.11, 0.035, Vector3(sx, 0.02, 0), Color("#5a3a22"))
		sd.scale = Vector3(0.9, 1.0, 1.5)
		sandal_luar.add_child(sd)


## Segmen pagar kayu lurus: tiang tiap ~2 m + 2 rel. Visual saja.
static func _pagar_kayu(parent: Node3D, a: Vector2, b: Vector2) -> void:
	var panjang := a.distance_to(b)
	if panjang < 0.1:
		return
	var arah := (b - a).normalized()
	var n_tiang := int(panjang / 2.0) + 1
	for i in range(n_tiang + 1):
		var p := a + arah * (float(i) * panjang / float(n_tiang))
		parent.add_child(Palette.box(Vector3(0.12, 1.0, 0.12), Vector3(p.x, 0.5, p.y), Palette.JATI))
	for y in [0.35, 0.85]:
		var rel := Palette.box(Vector3(panjang, 0.08, 0.06), Vector3((a.x + b.x) / 2.0, y, (a.y + b.y) / 2.0), Palette.JATI)
		rel.rotation.y = atan2(-arah.y, arah.x)
		parent.add_child(rel)


## ------------------------------------------------------------------
## Cangkruk Putri (128,-12) — konstruksi SAMA seperti Cangkruk Putra
## (pola _cangkruk builder): cangkang kayu 10x8 m, tinggi 3,4 m,
## pintu selatan (celah 1,6 m), atap segitiga. Kapasitas 5 kasur susun
## = 10 santri (isi sebenarnya di map interior terpisah).
## ------------------------------------------------------------------
static func _cangkruk_putri(kampus: Node3D) -> void:
	var c := Node3D.new()
	c.name = "CangkrukPutri"
	kampus.add_child(c)
	var cx := 128.0
	var cz := -12.0
	_static_box(c, Vector3(10, 0.14, 8), Vector3(cx, -0.05, cz), Palette.KAYU)
	# Ambang pintu kayu (visual, tanpa collision).
	c.add_child(Palette.box(Vector3(1.6, 0.024, 0.35), Vector3(cx, 0.012, cz + 4.0), Palette.KAYU_GELAP))
	# Dinding: utara, barat, timur utuh; selatan dua segmen + ambang pintu.
	_static_box(c, Vector3(10, 3.4, 0.25), Vector3(cx, 1.7, cz - 4), Palette.KAYU)
	_static_box(c, Vector3(0.25, 3.4, 8), Vector3(cx - 5, 1.7, cz), Palette.KAYU)
	_static_box(c, Vector3(0.25, 3.4, 8), Vector3(cx + 5, 1.7, cz), Palette.KAYU)
	_static_box(c, Vector3(4.2, 3.4, 0.25), Vector3(cx - 2.9, 1.7, cz + 4), Palette.KAYU)
	_static_box(c, Vector3(4.2, 3.4, 0.25), Vector3(cx + 2.9, 1.7, cz + 4), Palette.KAYU)
	_static_box(c, Vector3(1.6, 1.2, 0.25), Vector3(cx, 2.8, cz + 4), Palette.KAYU)
	# Lis emas di atas pintu.
	c.add_child(Palette.box(Vector3(1.6, 0.1, 0.3), Vector3(cx, 2.6, cz + 4), Palette.EMAS, 0.4))
	# Atap segitiga dua sisi + bubungan.
	var atap_kiri := Palette.box(Vector3(6.0, 0.12, 9.6), Vector3(cx - 2.8, 4.0, cz), Palette.KAYU_GELAP)
	atap_kiri.rotation.z = 0.27
	c.add_child(atap_kiri)
	var atap_kanan := Palette.box(Vector3(6.0, 0.12, 9.6), Vector3(cx + 2.8, 4.0, cz), Palette.KAYU_GELAP)
	atap_kanan.rotation.z = -0.27
	c.add_child(atap_kanan)
	c.add_child(Palette.box(Vector3(0.25, 0.25, 9.6), Vector3(cx, 4.85, cz), Palette.KAYU_GELAP))
	# RONDE PERBAIKAN (Fajar): SEGITIGA PELANA (pola Cangkruk putra) —
	# ujung atap (z=cz±4) selama ini terbuka, langit menembus.
	# Prisma kayu 10×1,4×0,25, alas di puncak dinding (y=3,4).
	for gz in [cz - 4.0, cz + 4.0]:
		var pelana := MeshInstance3D.new()
		pelana.name = "PelanaAtap_Selatan" if gz > cz else "PelanaAtap_Utara"
		var prisma := PrismMesh.new()
		prisma.size = Vector3(10, 1.4, 0.25)
		prisma.left_to_right = 0.5
		pelana.mesh = prisma
		pelana.material_override = Palette.mat(Palette.KAYU, 0.0, 0.45)
		pelana.position = Vector3(cx, 4.1, gz)
		c.add_child(pelana)
	# Jendela: 2 timur + 2 barat + 2 mengapit pintu selatan.
	for wz in [cz + 1.5, cz - 1.5]:
		c.add_child(Palette.box(Vector3(0.1, 0.9, 0.8), Vector3(cx - 5.15, 1.7, wz), Palette.ZAMRUD_GELAP))
		c.add_child(Palette.box(Vector3(0.1, 0.9, 0.8), Vector3(cx + 5.15, 1.7, wz), Palette.ZAMRUD_GELAP))
	for wx in [cx - 2.9, cx + 2.9]:
		c.add_child(Palette.box(Vector3(0.8, 0.9, 0.1), Vector3(wx, 1.7, cz + 4.15), Palette.ZAMRUD_GELAP))
	# Lampu hangat di dalam cangkang.
	var lampu := OmniLight3D.new()
	lampu.position = Vector3(cx, 2.6, cz)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.5
	lampu.set_meta("energi_siang", 0.5)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 9.0
	lampu.shadow_enabled = false
	c.add_child(lampu)
	# Label di atas pintu.
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari DALAM cangkruk, di atas pintu) — sisi
	# belakang label lama terbaca cermin dari dalam.
	var label := Palette.label3d("CANGKRUK PUTRI", Vector3(cx, 2.9, cz + 4.15), 20, Color("#f2c14e"), false)
	label.name = "LabelCangkrukPutri"
	label.double_sided = false
	c.add_child(label)
	var label_dalam := Palette.label3d("CANGKRUK PUTRI", Vector3(cx, 2.9, cz + 3.85), 20, Color("#f2c14e"), false)
	label_dalam.name = "LabelCangkrukPutriBelakang"
	label_dalam.rotation.y = PI
	label_dalam.double_sided = false
	c.add_child(label_dalam)
	# Sandal di depan pintu (muncul saat pemain di dalam; main.gd mengaturnya).
	var sandal_luar := Node3D.new()
	sandal_luar.name = "SandalLuarCangkrukPutri"
	sandal_luar.position = Vector3(cx + 1.4, 0, cz + 4.7)
	sandal_luar.visible = false
	c.add_child(sandal_luar)
	for sx in [-0.16, 0.16]:
		var sd := Palette.cylinder(0.11, 0.11, 0.035, Vector3(sx, 0.02, 0), Color("#5a3a22"))
		sd.scale = Vector3(0.9, 1.0, 1.5)
		sandal_luar.add_child(sd)


## ------------------------------------------------------------------
## Gedung generik gaya yang sama: dinding krem, atap datar zamrud +
## lis emas, pintu 1,6 m di sisi yang diminta, 4 jendela (2+2),
## label di atas pintu. Mengembalikan posisi pintu (dunia).
## ------------------------------------------------------------------
static func _gedung(kampus: Node3D, nama: String, cx: float, cz: float, sx: float, sz: float, tinggi: float, pintu_sisi: String, label_teks: String) -> Vector3:
	var g := Node3D.new()
	g.name = nama
	kampus.add_child(g)
	var t := 0.25
	# Lantai.
	_static_box(g, Vector3(sx, 0.14, sz), Vector3(cx, -0.05, cz), Palette.PASIR_GELAP)
	# Dinding (4 sisi; sisi pintu bercelah + ambang).
	var sisi_dinding: Array = [
		["N", Vector3(cx, tinggi / 2.0, cz - sz / 2.0), true],
		["S", Vector3(cx, tinggi / 2.0, cz + sz / 2.0), true],
		["W", Vector3(cx - sx / 2.0, tinggi / 2.0, cz), false],
		["E", Vector3(cx + sx / 2.0, tinggi / 2.0, cz), false],
	]
	for s in sisi_dinding:
		var kode: String = s[0]
		var tengah: Vector3 = s[1]
		var horizontal: bool = s[2]
		var panjang: float = sx if horizontal else sz
		if kode != pintu_sisi:
			if horizontal:
				_static_box(g, Vector3(panjang, tinggi, t), tengah, Palette.KREM)
			else:
				_static_box(g, Vector3(t, tinggi, panjang), tengah, Palette.KREM)
		else:
			var seg := (panjang - LEBAR_PINTU) / 2.0
			var off := LEBAR_PINTU / 2.0 + seg / 2.0
			var y_ambang := TINGGI_PINTU + (tinggi - TINGGI_PINTU) / 2.0
			if horizontal:
				_static_box(g, Vector3(seg, tinggi, t), Vector3(tengah.x - off, tengah.y, tengah.z), Palette.KREM)
				_static_box(g, Vector3(seg, tinggi, t), Vector3(tengah.x + off, tengah.y, tengah.z), Palette.KREM)
				_static_box(g, Vector3(LEBAR_PINTU, tinggi - TINGGI_PINTU, t), Vector3(tengah.x, y_ambang, tengah.z), Palette.KREM)
			else:
				_static_box(g, Vector3(t, tinggi, seg), Vector3(tengah.x, tengah.y, tengah.z - off), Palette.KREM)
				_static_box(g, Vector3(t, tinggi, seg), Vector3(tengah.x, tengah.y, tengah.z + off), Palette.KREM)
				_static_box(g, Vector3(t, tinggi - TINGGI_PINTU, LEBAR_PINTU), Vector3(tengah.x, y_ambang, tengah.z), Palette.KREM)
	# Atap datar zamrud + lis emas.
	g.add_child(Palette.box(Vector3(sx + 0.6, 0.08, sz + 0.6), Vector3(cx, tinggi - 0.04, cz), Palette.EMAS, 0.4))
	g.add_child(Palette.box(Vector3(sx + 0.8, 0.22, sz + 0.8), Vector3(cx, tinggi + 0.11, cz), Palette.ZAMRUD_GELAP))
	# Jendela: 4 (2+2) di dua sisi yang tegak lurus sisi pintu.
	if pintu_sisi == "S" or pintu_sisi == "N":
		for sisi in [-1.0, 1.0]:
			var sf: float = sisi
			var wx := cx + sf * sx / 2.0
			for wz in [cz - sz / 4.0, cz + sz / 4.0]:
				g.add_child(Palette.box(Vector3(0.12, 1.2, 1.1), Vector3(wx + sf * 0.02, 1.8, wz), Palette.EMAS, 0.3))
				g.add_child(Palette.box(Vector3(0.1, 1.0, 0.9), Vector3(wx + sf * 0.07, 1.8, wz), Palette.ZAMRUD_GELAP))
	else:
		for sisi in [-1.0, 1.0]:
			var sf: float = sisi
			var wz := cz + sf * sz / 2.0
			for wx in [cx - sx / 4.0, cx + sx / 4.0]:
				g.add_child(Palette.box(Vector3(1.1, 1.2, 0.12), Vector3(wx, 1.8, wz + sf * 0.02), Palette.EMAS, 0.3))
				g.add_child(Palette.box(Vector3(0.9, 1.0, 0.1), Vector3(wx, 1.8, wz + sf * 0.07), Palette.ZAMRUD_GELAP))
	# Posisi pintu + arah keluar (untuk ambang, lis, label).
	var pintu_pos := Vector3.ZERO
	var keluar := Vector3.ZERO
	var putar_label := 0.0
	match pintu_sisi:
		"S":
			pintu_pos = Vector3(cx, 0, cz + sz / 2.0)
			keluar = Vector3(0, 0, 1)
			putar_label = 0.0
		"N":
			pintu_pos = Vector3(cx, 0, cz - sz / 2.0)
			keluar = Vector3(0, 0, -1)
			putar_label = PI
		"W":
			pintu_pos = Vector3(cx - sx / 2.0, 0, cz)
			keluar = Vector3(-1, 0, 0)
			putar_label = -PI / 2.0
		"E":
			pintu_pos = Vector3(cx + sx / 2.0, 0, cz)
			keluar = Vector3(1, 0, 0)
			putar_label = PI / 2.0
	# Ambang emas + lis emas di atas pintu (visual, tanpa collision).
	g.add_child(Palette.box(Vector3(LEBAR_PINTU, 0.024, 0.35), pintu_pos + Vector3(0, 0.012, 0), Palette.EMAS, 0.4))
	var lis := Palette.box(Vector3(LEBAR_PINTU, 0.1, 0.3), pintu_pos + Vector3(0, TINGGI_PINTU + 0.05, 0) + keluar * 0.1, Palette.EMAS, 0.4)
	lis.rotation.y = putar_label
	g.add_child(lis)
	# Label di atas pintu, menghadap keluar.
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# di sisi DALAM dinding (terbaca benar dari dalam gedung, di atas
	# pintu) — sisi belakang label lama terbaca cermin dari dalam.
	var label := Palette.label3d(label_teks, pintu_pos + Vector3(0, 3.0, 0) + keluar * 0.18, 20, Color("#f2c14e"), false)
	label.name = "Label" + nama
	label.rotation.y = putar_label
	label.double_sided = false
	g.add_child(label)
	var label_dalam := Palette.label3d(label_teks, pintu_pos + Vector3(0, 3.0, 0) - keluar * 0.18, 20, Color("#f2c14e"), false)
	label_dalam.name = "Label" + nama + "Belakang"
	label_dalam.rotation.y = putar_label + PI
	label_dalam.double_sided = false
	g.add_child(label_dalam)
	return pintu_pos


## ------------------------------------------------------------------
## Daun pintu TERTUTUP KelasPutri (RONDE PERBAIKAN, integrasi item 14
## permanen) — dua daun jati rapat di celah pintu selatan (x 129,2..
## 130,8, z=4), rata dengan dinding (tebal 0,25), + collision via
## _static_box (pola PintuGerbangPutri) + dua gagang emas di sisi luar.
## ------------------------------------------------------------------
static func _daun_pintu_kelas_putri(kampus: Node3D) -> void:
	var p := Node3D.new()
	p.name = "PintuKelasPutri"
	kampus.add_child(p)
	_static_box(p, Vector3(0.8, 2.6, 0.25), Vector3(129.6, 1.3, 4.0), Palette.JATI)
	_static_box(p, Vector3(0.8, 2.6, 0.25), Vector3(130.4, 1.3, 4.0), Palette.JATI)
	# Gagang emas di sisi luar (selatan), di pertemuan dua daun.
	p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(129.94, 1.05, 4.16), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(130.06, 1.05, 4.16), Palette.EMAS, 0.4))


## ------------------------------------------------------------------
## Pos jaga Timur Laut (160,-35) — gubuk kayu 3x3 m pola _gubuk_pos
## builder, pintu menghadap BARAT (ke jalan internal). Tanpa lampu
## jalan (brief: tidak ada tiang/lampu di jalan).
## ------------------------------------------------------------------
static func _pos_jaga_tl(kampus: Node3D) -> void:
	var g := Node3D.new()
	g.name = "PosJagaTL"
	g.position = POS_JAGA_TL_POS
	kampus.add_child(g)
	_static_box(g, Vector3(3, 0.14, 3), Vector3(0, -0.05, 0), Palette.KAYU)
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, -1.5), Palette.KAYU)
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, 1.5), Palette.KAYU)
	_static_box(g, Vector3(0.2, 2.6, 3), Vector3(1.5, 1.3, 0), Palette.KAYU)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(-1.5, 1.3, -1.05), Palette.KAYU)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(-1.5, 1.3, 1.05), Palette.KAYU)
	_static_box(g, Vector3(0.2, 0.8, 1.2), Vector3(-1.5, 2.2, 0), Palette.KAYU)
	# Atap piramida (visual saja).
	var atap := MeshInstance3D.new()
	atap.name = "AtapPos"
	var atap_mesh := CylinderMesh.new()
	atap_mesh.top_radius = 0.0
	atap_mesh.bottom_radius = 2.3
	atap_mesh.height = 1.0
	atap_mesh.radial_segments = 4
	atap.mesh = atap_mesh
	atap.material_override = Palette.mat(Palette.ZAMRUD_GELAP, 0.0, 0.45)
	atap.position = Vector3(0, 3.1, 0)
	atap.rotation.y = PI / 4.0
	g.add_child(atap)
	# Label di atas pintu (menghadap barat).
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari dalam pos).
	var label := Palette.label3d("POS JAGA", Vector3(-1.6, 2.6, 0), 20, Color("#f2c14e"), false)
	label.name = "LabelPos"
	label.rotation.y = -PI / 2.0
	label.double_sided = false
	g.add_child(label)
	var label_dalam := Palette.label3d("POS JAGA", Vector3(-1.35, 2.6, 0), 20, Color("#f2c14e"), false)
	label_dalam.name = "LabelPosBelakang"
	label_dalam.rotation.y = PI / 2.0
	label_dalam.double_sided = false
	g.add_child(label_dalam)


## ------------------------------------------------------------------
## Jalan internal N-S x=142, lebar 3 m, z -35..+14 (49 m), pasir,
## tebal 0.06, y=0.03 — plus konektor E-W 2,5 m dari jalan ke tiap
## pintu gedung. TIDAK ada tiang/lampu di tengah jalan.
## Konektor hanya menyentuh tepi jalan (tidak tumpang tindih) supaya
## tidak z-fighting; konektor Studio lewat koridor z=-18 (utara
## Madrasah, selatan Kantor Ustadzah) karena pintu Studio di utara.
## ------------------------------------------------------------------
static func _jalan_internal(kampus: Node3D) -> void:
	var j := Node3D.new()
	j.name = "JalanInternal"
	kampus.add_child(j)
	var utama := Palette.box(Vector3(3, 0.06, 49), Vector3(JALAN_INTERNAL_X, 0.03, -10.5), Palette.PASIR)
	utama.name = "JalanUtama"
	j.add_child(utama)
	# (nama, ukuran, posisi) — konektor E-W lebar 2,5 m.
	var konektor: Array = [
		["KonekMusholla", Vector3(6.5, 0.06, 2.5), Vector3(137.25, 0.03, -19)],
		["KonekCangkruk", Vector3(7.5, 0.06, 2.5), Vector3(136.75, 0.03, -8)],
		["KonekKelas", Vector3(5.5, 0.06, 2.5), Vector3(137.75, 0.03, 4)],
		["KonekAsrama", Vector3(2.5, 0.06, 2.5), Vector3(144.75, 0.03, 0)],
		["KonekKantor", Vector3(2.5, 0.06, 2.5), Vector3(144.75, 0.03, -28)],
		["KonekMadrasah", Vector3(3.5, 0.06, 2.5), Vector3(145.25, 0.03, -12)],
		["KonekStudio", Vector3(22.5, 0.06, 2.5), Vector3(154.75, 0.03, -18)],
		# KonekPosJaga DIPENDEKKAN 1 m Ronde 21 (audit: ujung lama x=158,5 menempel
		# dinding barat pos, sudut terdekat 0,25 m): panjang 14 m, akhir x=157,5 —
		# dinding barat pos (x=158,5) kini 1,0 m dari ujung konektor.
		# RONDE PERBAIKAN (Raka, integrasi item 14 permanen): konektor
		# spawn putri (130,14) -> JalanInternal x=142 — rute utara yang
		# benar: dari spawn jalan ke TIMUR di atas aspal, lalu belok
		# utara menyusuri jalan internal; bukan lagi menembus Kelas.
		["KonekSpawn", Vector3(12, 0.06, 2.5), Vector3(136, 0.03, 14)],
		["KonekPosJaga", Vector3(14, 0.06, 2.5), Vector3(150.5, 0.03, -35)],
	]
	for k in konektor:
		var slab := Palette.box(k[1], k[2], Palette.PASIR)
		slab.name = k[0]
		j.add_child(slab)
