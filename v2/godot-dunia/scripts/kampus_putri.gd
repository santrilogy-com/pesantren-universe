class_name KampusPutri
## RONDE 21 (16 Nov) — Relokasi kampus putri ke Opsi A — Terjauh (ACC Mas 22:03 WIB).
## PERLUASAN 18 NOV (Mira, perintah Mas 00:28 WIB "Langsung aja ya.. intinya diperluas.."):
## Cangkruk Putri DIHAPUS total (Mas 00:26 WIB — kasur susun HANYA di Asrama Putri);
## tembok keliling diperluas x 115..216, z -70..+40 (lihat tembok_putri.gd);
## posisi v2 ACC (KONSEP-TATA-LETAK.md U1-U5) akhirnya diterapkan di kode:
## Kelas (130,10), Asrama (155,9 — pusat badan 18 m; dinding barat
## x=146 = pintu, sama seperti sebelumnya), Kantor (148,-33),
## Pos Jaga TL (176,-20),
## Spawn (140,16) — Kelas & Asrama tidak lagi menutup sumbu jalan E-W (z=0);
## tapak gedung TETAP (Asrama 3 lantai / Kelas 5 lantai 20x12 = cadangan,
## lihat konsep/area-putri-perluasan.md — butuh ACC masterplan sebelum dibangun).
## File ini HANYA berisi kampus putri. Dibangun oleh Cakra, digabung oleh Raka.
## Kontrak: static func build(root: Node3D) -> Dictionary.
## Anak KampusPutri: Musholla, KelasPutri, AsramaPutri,
## KantorUstadzah, Madrasah, Studio, PosJagaTL, JalanInternal.
## Sumbu: +x timur, +z selatan, y=0 tanah. Semua koordinat anak ditulis
## absolut (pola builder: root di origin, anak berkoordinat dunia).
## JANGAN sebut pesantren "dunia".

## Posisi Opsi A (konstanta — dipakai dict kembalian juga).
const MUSHOLLA_POS := Vector3(134, 0, -24)
const KELAS_PUTRI_POS := Vector3(130, 0, 10)
const ASRAMA_PUTRI_POS := Vector3(155, 0, 9)
const KANTOR_USTADZAH_POS := Vector3(148, 0, -33)
const MADRASAH_POS := Vector3(152, 0, -12)
const STUDIO_POS := Vector3(166, 0, -12)
const POS_JAGA_TL_POS := Vector3(176, 0, -20)
const SPAWN_PUTRI := Vector3(140, 0, 16)
const JALAN_INTERNAL_X := 142.0
## Taman Putri (10x8 m) — RONDE 4 (Dewi, 18 Nov 2026; perintah Mas
## 14:17 WIB "Taman taruh di pojok aja.. jangan di depan musholla"):
## pindah dari (128,-12) ke pojok barat-daya (122,32), 2 m dari
## tembok barat (x=115), 4 m dari tembok selatan (z=+40). Rumput +
## bedeng bunga + pagar bambu + paving ke Jalan Internal.
const HALAMAN_CANGKRUK_POS := Vector3(122, 0, 32)

## Pintu Musholla baru: sisi selatan (menghadap spawn putri).
const MUSHOLLA_DOOR := Vector3(134, 0, -19)
## Keluar = pintu + normal selatan (0,0,1) x 1,5 m.
const MUSHOLLA_EXIT := Vector3(134, 0, -17.5)

## Pintu luar tiap gedung (kanonik — pusat celah di sisi pintu, dari
## _gedung/_pos_jaga_tl). Exit = pintu + 1,5 m ke arah luar.
## Daun TERTUTUP dipasang di tiap celah (Dewi, 18 Nov 2026, perintah
## Mas 07:09 WIB: pintu HARUS terlihat di luar; masuk tetap pakai
## tombol MASUK → teleport, BUKAN jalan tembus).
const KELAS_DOOR := Vector3(130, 0, 14)
const KELAS_EXIT := Vector3(130, 0, 15.5)
const ASRAMA_DOOR := Vector3(146, 0, 9)
const ASRAMA_EXIT := Vector3(144.5, 0, 9)
const KANTOR_DOOR := Vector3(144, 0, -33)
const KANTOR_EXIT := Vector3(142.5, 0, -33)
const MADRASAH_DOOR := Vector3(147, 0, -12)
const MADRASAH_EXIT := Vector3(145.5, 0, -12)
const STUDIO_DOOR := Vector3(166, 0, -16)
const STUDIO_EXIT := Vector3(166, 0, -17.5)
const POS_JAGA_DOOR := Vector3(174.5, 0, -20)
const POS_JAGA_EXIT := Vector3(173, 0, -20)

## Ukuran pintu gedung generik.
const LEBAR_PINTU := 1.6
const TINGGI_PINTU := 2.6


static func build(root: Node3D) -> Dictionary:
	var kampus := Node3D.new()
	kampus.name = "KampusPutri"
	root.add_child(kampus)
	_musholla(kampus)
	# Daun pintu TERTUTUP Musholla (celah 2,0x3,0 — lebih besar dari
	# celah gedung generik 1,6x2,6, jadi daun disesuaikan ukurannya).
	_daun_pintu(kampus, "DaunPintuMusholla", MUSHOLLA_DOOR, "S", 2.0, 3.0)
	_gedung(kampus, "KelasPutri", KELAS_PUTRI_POS.x, KELAS_PUTRI_POS.z, 10, 8, 3.6, "S", "KELAS PUTRI")
	# RONDE PERBAIKAN (Raka, integrasi item 14 permanen): daun pintu
	# TERTUTUP di celah pintu selatan KelasPutri — interior Kelas masih
	# cangkang kosong (belum ada map interior seperti Surau/Musholla),
	# jadi pintunya dikunci rapat; pemain tidak lagi bisa masuk lalu
	# mentok di dinding utara. Kalau suatu hari Kelas punya interior,
	# daun ini dibuka/diganti logika pintu.
	_daun_pintu_kelas_putri(kampus)
	# P1 (Nadia, 18 Nov 2026 — ACC Mas 14:01 WIB): cangkang Asrama
	# Putri dibangun sendiri (_asrama_putri), BUKAN _gedung generik
	# lagi — 21,5x12 m, 3 lantai, cermin Asrama Putra.
	_asrama_putri(kampus)
	_daun_pintu(kampus, "PintuAsramaPutri", ASRAMA_DOOR, "W")
	_gedung(kampus, "KantorUstadzah", KANTOR_USTADZAH_POS.x, KANTOR_USTADZAH_POS.z, 8, 6, 3.4, "W", "KANTOR USTADZAH")
	_daun_pintu(kampus, "PintuKantorUstadzah", KANTOR_DOOR, "W")
	_gedung(kampus, "Madrasah", MADRASAH_POS.x, MADRASAH_POS.z, 10, 8, 3.8, "W", "MADRASAH")
	_daun_pintu(kampus, "PintuMadrasah", MADRASAH_DOOR, "W")
	_gedung(kampus, "Studio", STUDIO_POS.x, STUDIO_POS.z, 10, 8, 3.6, "N", "STUDIO")
	_daun_pintu(kampus, "PintuStudio", STUDIO_DOOR, "N")
	_pos_jaga_tl(kampus)
	# Daun pintu TERTUTUP Pos Jaga (celah 1,2x1,8 — lebih kecil dari
	# celah gedung generik, daun disesuaikan ukurannya).
	_daun_pintu(kampus, "PintuPosJagaTL", POS_JAGA_DOOR, "W", 1.2, 1.8)
	_jalan_internal(kampus)
	_halaman_cangkruk(kampus)
	return {
		"musholla_door": MUSHOLLA_DOOR,
		"musholla_exit": MUSHOLLA_EXIT,
		"kelas_door": KELAS_DOOR,
		"kelas_exit": KELAS_EXIT,
		"asrama_door": ASRAMA_DOOR,
		"asrama_exit": ASRAMA_EXIT,
		"kantor_door": KANTOR_DOOR,
		"kantor_exit": KANTOR_EXIT,
		"madrasah_door": MADRASAH_DOOR,
		"madrasah_exit": MADRASAH_EXIT,
		"studio_door": STUDIO_DOOR,
		"studio_exit": STUDIO_EXIT,
		"pos_jaga_door": POS_JAGA_DOOR,
		"pos_jaga_exit": POS_JAGA_EXIT,
		"halaman_cangkruk_pos": HALAMAN_CANGKRUK_POS,
		"spawn_putri": SPAWN_PUTRI,
		"musholla_pos": MUSHOLLA_POS,
		"kelas_putri_pos": KELAS_PUTRI_POS,
		"asrama_putri_pos": ASRAMA_PUTRI_POS,
		"kantor_ustadzah_pos": KANTOR_USTADZAH_POS,
		"madrasah_pos": MADRASAH_POS,
		"studio_pos": STUDIO_POS,
		"pos_jaga_tl": POS_JAGA_TL_POS,
		"jalan_internal_x": JALAN_INTERNAL_X,
	}


## P5 FASE 2 (Bima, 18 Nov 2026): permukaan BESAR bertekstur —
## dinding KREM pakai plester (MaterialTekstur.dinding), BATU tipis
## (lantai/teras, y<=0,15) pakai lantai batu, BATU tebal (fondasi/
## alas) pakai blok batu. Tinta + ukuran/posisi TIDAK berubah, hanya
## material — palet tetap persis (tekstur ternormalisasi 0,90).
## Detail kecil (lis emas, jendela, pintu jati, plakat) tetap polos.
## skala_uv ~= ukuran / 2 m (tekstur berulang tiap ~2 m).
static func _skala_uv(size: Vector3) -> Vector3:
	return Vector3(size.x / 2.0, size.y / 2.0, size.z / 2.0)


static func _mat_permukaan(size: Vector3, warna: Color) -> Material:
	if warna == Palette.KREM:
		return MaterialTekstur.dinding(warna, _skala_uv(size))
	if warna == Palette.BATU:
		if size.y <= 0.15:
			return MaterialTekstur.lantai_batu(warna, _skala_uv(size))
		return MaterialTekstur.pondasi(warna, _skala_uv(size))
	return Palette.mat(warna)


## Helper lokal (pola _static_box builder): box visual + StaticBody3D.
## Hiasan (kubah, bunga, pagar) TIDAK pakai ini — visual saja.
static func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, collide: bool = true) -> MeshInstance3D:
	var mi := MaterialTekstur.kotak(size, pos, _mat_permukaan(size, color))
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
	# TABRAKAN-DUNIA (Bagas, 18 Nov): 2 pilar barat tanpa collision
	# — pemain tembus (probe baseline). Kotak terinskripsi 0,311
	# (r=0,22) h=4,0 mengikuti visual — fix3: kotak, bukan silinder,
	# supaya pemain tidak tergelincir mengelilingi tiang tipis.
	for pz in [cz - 4.7, cz + 4.7]:
		var pil := StaticBody3D.new()
		pil.position = Vector3(cx - 5.7, 2.0, pz)
		var pil_shape := CollisionShape3D.new()
		var pil_box := BoxShape3D.new()
		pil_box.size = Vector3(0.311, 4.0, 0.311)
		pil_shape.shape = pil_box
		pil.add_child(pil_shape)
		m.add_child(pil)
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
	# P4 (Nadia, 18 Nov 2026 — ACC Mas 14:01 WIB): kubah jadi BAWANG
	# seperti Surau (dulu bola gepeng scale y 0,72). Profil bawang
	# dari primitif: bola bawah r=2,0 (scale y 0,75, pusat 5,44,
	# puncak 6,94) + kerucut r=1,2 h=1,5 (pusat 6,85, puncak 7,60)
	# yang pangkalnya TERBENAM di dalam bola (bola r=1,80 di y=6,10
	# > pangkal kerucut 1,2 — tidak ada celah) lalu mengerucut ke
	# puncak; bola finial emas r=0,12 menutup ujung kerucut; tangkai
	# + sabit ikut naik (puncak ~8,6 m). Drum + warna zamrud + sabit
	# emas TIDAK berubah.
	kubah.add_child(Palette.cylinder(2.0, 2.0, 1.44, Vector3(cx, 4.72, cz), Palette.ZAMRUD_GELAP))
	var dome := Palette.sphere(2.0, Vector3(cx, 5.44, cz), Palette.ZAMRUD_GELAP, 0.3)
	dome.scale = Vector3(1, 0.75, 1)
	kubah.add_child(dome)
	kubah.add_child(Palette.cylinder(0.02, 1.2, 1.5, Vector3(cx, 6.85, cz), Palette.ZAMRUD_GELAP, 0.3))
	kubah.add_child(Palette.sphere(0.12, Vector3(cx, 7.62, cz), Palette.EMAS, 0.5))
	kubah.add_child(Palette.cylinder(0.06, 0.06, 0.7, Vector3(cx, 8.05, cz), Palette.EMAS, 0.5))
	# Bulan sabit emas: torus tipis miring di puncak (pendekatan primitif).
	var sabit := MeshInstance3D.new()
	var sabit_mesh := TorusMesh.new()
	sabit_mesh.inner_radius = 0.14
	sabit_mesh.outer_radius = 0.3
	sabit_mesh.rings = 12
	sabit_mesh.ring_segments = 24
	sabit.mesh = sabit_mesh
	sabit.material_override = Palette.mat(Palette.EMAS, 0.5, 0.4)
	sabit.position = Vector3(cx, 8.45, cz)
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
	# P6 (Nadia, 18 Nov 2026): plakat Arab diperbesar font 36 -> 44
	# (teks 1,88 m, ukur_label_plakat) + papan disesuaikan (emas
	# 2,35x0,95, zamrud 2,2x0,8), pusat y 3,52 (di atas ambang 3,06,
	# di bawah lis atap 3,95).
	plakat.add_child(Palette.box(Vector3(2.35, 0.95, 0.06), Vector3(cx, 3.52, cz + 5.16), Palette.EMAS, 0.4))
	plakat.add_child(Palette.box(Vector3(2.2, 0.8, 0.08), Vector3(cx, 3.52, cz + 5.19), Palette.ZAMRUD_GELAP))
	var plakat_label := Palette.label_arab("مصلى الروضة", Vector3(cx, 3.52, cz + 5.26), 44, Color("#f2c14e"))
	plakat_label.name = "PlakatTeks"
	plakat.add_child(plakat_label)
	# --- SerambiMusholla: lantai batu + 2 tiang jati + atap kayu + 1 anak tangga ---
	var serambi := Node3D.new()
	serambi.name = "SerambiMusholla"
	m.add_child(serambi)
	serambi.add_child(MaterialTekstur.kotak(Vector3(4.5, 0.1, 2.8), Vector3(cx, 0.0, cz + 6.4), MaterialTekstur.lantai_batu(Palette.BATU, Vector3(2.25, 0.05, 1.4))))
	serambi.add_child(Palette.cylinder(0.12, 0.14, 3.0, Vector3(cx - 1.8, 1.5, cz + 7.4), Palette.JATI))
	serambi.add_child(Palette.cylinder(0.12, 0.14, 3.0, Vector3(cx + 1.8, 1.5, cz + 7.4), Palette.JATI))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): 2 tiang serambi tanpa
	# collision — pemain tembus (probe baseline). Kotak terinskripsi
	# 0,212 (r=0,15) h=3,0 mengikuti visual — fix3 anti-slip.
	for tx in [cx - 1.8, cx + 1.8]:
		var tg := StaticBody3D.new()
		tg.position = Vector3(tx, 1.5, cz + 7.4)
		var tg_shape := CollisionShape3D.new()
		var tg_box := BoxShape3D.new()
		tg_box.size = Vector3(0.212, 3.0, 0.212)
		tg_shape.shape = tg_box
		tg.add_child(tg_shape)
		serambi.add_child(tg)
	serambi.add_child(Palette.box(Vector3(4.8, 0.12, 3.0), Vector3(cx, 3.05, cz + 6.4), Palette.JATI))
	serambi.add_child(Palette.box(Vector3(4.8, 0.08, 0.1), Vector3(cx, 2.98, cz + 7.85), Palette.EMAS, 0.4))
	# Anak tangga rendah, visual saja (tanpa collision).
	serambi.add_child(MaterialTekstur.kotak(Vector3(3.2, 0.08, 0.5), Vector3(cx, 0.04, cz + 8.05), MaterialTekstur.pondasi(Palette.BATU, Vector3(1.6, 0.04, 0.25))))
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
	# TABRAKAN-DUNIA (Bagas, 18 Nov): pagar kayu tadinya "visual
	# saja (tanpa collision)" — pemain tembus. Kotak mengikuti
	# garis pagar (tiang 0,12 + rel 0,06 -> tebal 0,15; tinggi
	# 1,0 = tinggi tiang). Celah yang dibiarkan terbuka di pemanggil
	# (selatan x 133..135 + timur z -20,25..-17,75) TETAP terbuka:
	# tidak ada segmen collision di sana.
	var kotak := StaticBody3D.new()
	var tengah := Vector3((a.x + b.x) / 2.0, 0.5, (a.y + b.y) / 2.0)
	kotak.position = tengah
	var kotak_shape := CollisionShape3D.new()
	var kotak_box := BoxShape3D.new()
	if absf(b.x - a.x) >= absf(b.y - a.y):
		kotak_box.size = Vector3(panjang, 1.0, 0.15)
	else:
		kotak_box.size = Vector3(0.15, 1.0, panjang)
	kotak_shape.shape = kotak_box
	kotak.add_child(kotak_shape)
	parent.add_child(kotak)


## ------------------------------------------------------------------
## P1 — CANGKANG LUAR ASRAMA PUTRI (Nadia, 18 Nov 2026 — ACC Mas
## 14:01 WIB, audit AUDIT-TEKSTUR-BANGUNAN.md §2.3: cangkang lama
## 12x8 m 1 lantai TIDAK SESUAI interior 21,5x12 m 3 lantai).
## Cermin scripts/asrama_putra.gd, disesuaikan ke putri:
## badan 18x12 m (x 146..164, z 3..15) + annex tangga timur
## 3,5x2,6 m (x 164..167,5, z 7,7..10,3) = tapak total 21,5x12 m,
## 3 lantai x 3,2 m = 9,6 m + parapet zamrud 0,6 m = 10,2 m.
## Pusat badan (155,9) — dinding barat x=146 = pintu (ASRAMA_DOOR
## tetap (146,0,9), ASRAMA_EXIT tetap (144,5,0,9)): pintu & exit
## TIDAK berubah, hanya pusat yang geser 152 -> 155 karena badan
## melebar ke timur (annex). Dinding krem, lis emas per lantai,
## parapet zamrud, alas batu, jendela lengkung N/S per lantai,
## serambi barat, plakat "ASRAMA PUTRI" di atas pintu.
## Daun pintu TERTUTUP tetap dari _daun_pintu di build() (bukan di
## sini) — pola Asrama Putra (daun di _badan) TIDAK dipakai supaya
## tidak dobel dengan PintuAsramaPutri yang sudah ada.
## ------------------------------------------------------------------
static func _asrama_putri(kampus: Node3D) -> void:
	var a := Node3D.new()
	a.name = "AsramaPutri"
	kampus.add_child(a)
	var cx := 155.0
	var cz := 9.0
	var lantai_tinggi := 3.2
	# Lantai.
	_static_box(a, Vector3(18, 0.14, 12), Vector3(cx, -0.05, cz), Palette.PASIR_GELAP)
	# Dinding utara + selatan (utuh, 9,6 m).
	_static_box(a, Vector3(18.5, 9.6, 0.25), Vector3(cx, 4.8, 3), Palette.KREM)
	_static_box(a, Vector3(18.5, 9.6, 0.25), Vector3(cx, 4.8, 15), Palette.KREM)
	# Dinding timur (utuh — annex menempel di luarnya).
	_static_box(a, Vector3(0.25, 9.6, 12.25), Vector3(164, 4.8, cz), Palette.KREM)
	# Dinding barat: lantai 1 bercelah pintu (1,6 m, z 8,2..9,8);
	# lantai 2-3 utuh.
	_static_box(a, Vector3(0.25, 3.2, 5.2), Vector3(146, 1.6, 5.6), Palette.KREM)
	_static_box(a, Vector3(0.25, 3.2, 5.2), Vector3(146, 1.6, 12.4), Palette.KREM)
	_static_box(a, Vector3(0.25, 0.6, 1.6), Vector3(146, 2.9, 9), Palette.KREM)
	_static_box(a, Vector3(0.25, 3.2, 12.25), Vector3(146, 4.8, cz), Palette.KREM)
	_static_box(a, Vector3(0.25, 3.2, 12.25), Vector3(146, 8.0, cz), Palette.KREM)
	# Alas batu di kaki dinding (pola Asrama Putra).
	for alas in [
		[Vector3(18.6, 0.4, 0.1), Vector3(cx, 0.2, 2.83)],
		[Vector3(18.6, 0.4, 0.1), Vector3(cx, 0.2, 15.17)],
		[Vector3(0.1, 0.4, 12.6), Vector3(164.17, 0.2, cz)],
		[Vector3(0.1, 0.4, 5.2), Vector3(145.83, 0.2, 5.6)],
		[Vector3(0.1, 0.4, 5.2), Vector3(145.83, 0.2, 12.4)],
	]:
		a.add_child(MaterialTekstur.kotak(alas[0], alas[1], MaterialTekstur.pondasi(Palette.BATU, _skala_uv(alas[0]))))
	# Lis emas antar lantai + di bawah parapet.
	for y_lis in [3.2, 6.4, 9.6]:
		a.add_child(Palette.box(Vector3(18.6, 0.1, 12.6), Vector3(cx, y_lis, cz), Palette.EMAS_DESAIN, 0.4))
	# Atap datar zamrud + parapet zamrud 0,6 m.
	a.add_child(Palette.box(Vector3(18.4, 0.22, 12.4), Vector3(cx, 9.71, cz), Palette.ZAMRUD_GELAP))
	a.add_child(Palette.box(Vector3(18.5, 0.6, 0.25), Vector3(cx, 9.9, 3), Palette.ZAMRUD_GELAP))
	a.add_child(Palette.box(Vector3(18.5, 0.6, 0.25), Vector3(cx, 9.9, 15), Palette.ZAMRUD_GELAP))
	a.add_child(Palette.box(Vector3(0.25, 0.6, 12.25), Vector3(146, 9.9, cz), Palette.ZAMRUD_GELAP))
	a.add_child(Palette.box(Vector3(0.25, 0.6, 12.25), Vector3(164, 9.9, cz), Palette.ZAMRUD_GELAP))
	# Ambang emas di depan pintu + tiang emas di sisi pintu.
	a.add_child(Palette.box(Vector3(0.35, 0.024, 1.6), Vector3(146, 0.012, 9), Palette.EMAS, 0.4))
	a.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(145.8, 1.6, 8.05), Palette.EMAS, 0.4))
	a.add_child(Palette.cylinder(0.08, 0.08, 3.2, Vector3(145.8, 1.6, 9.95), Palette.EMAS, 0.4))
	# Jendela lengkung (pola Asrama Putra): 2 per sisi per lantai,
	# dinding utara (z=2,87) + selatan (z=15,13).
	for lantai in range(3):
		var fy: float = float(lantai) * lantai_tinggi
		for wx in [150.5, 159.5]:
			_jendela_lengkung(a, "Jendela_U%d_%d" % [lantai + 1, 1 if wx < cx else 2], Vector3(wx, fy + 1.5, 2.87), 0.0)
			_jendela_lengkung(a, "Jendela_S%d_%d" % [lantai + 1, 1 if wx < cx else 2], Vector3(wx, fy + 1.5, 15.13), PI)
	# --- Annex tangga timur (x 164..167,5, z 7,7..10,3) ---
	var anx := Node3D.new()
	anx.name = "AnnexTangga"
	a.add_child(anx)
	_static_box(anx, Vector3(3.5, 0.14, 2.6), Vector3(165.75, -0.05, 9), Palette.PASIR_GELAP)
	_static_box(anx, Vector3(3.75, 9.6, 0.25), Vector3(165.75, 4.8, 7.7), Palette.KREM)
	_static_box(anx, Vector3(3.75, 9.6, 0.25), Vector3(165.75, 4.8, 10.3), Palette.KREM)
	_static_box(anx, Vector3(0.25, 9.6, 2.85), Vector3(167.625, 4.8, 9), Palette.KREM)
	for y_lis in [3.2, 6.4, 9.6]:
		anx.add_child(Palette.box(Vector3(3.8, 0.1, 2.9), Vector3(165.75, y_lis, 9), Palette.EMAS_DESAIN, 0.4))
	anx.add_child(Palette.box(Vector3(3.9, 0.22, 3.0), Vector3(165.75, 9.71, 9), Palette.ZAMRUD_GELAP))
	anx.add_child(Palette.box(Vector3(3.75, 0.6, 0.25), Vector3(165.75, 9.9, 7.7), Palette.ZAMRUD_GELAP))
	anx.add_child(Palette.box(Vector3(3.75, 0.6, 0.25), Vector3(165.75, 9.9, 10.3), Palette.ZAMRUD_GELAP))
	anx.add_child(Palette.box(Vector3(0.25, 0.6, 2.85), Vector3(167.625, 9.9, 9), Palette.ZAMRUD_GELAP))
	for lantai in range(3):
		var fy: float = float(lantai) * lantai_tinggi
		_jendela_lengkung(anx, "JendelaAnnex%d" % (lantai + 1), Vector3(167.69, fy + 1.5, 9), -PI / 2.0)
	# --- Serambi di depan pintu barat (pola Serambi Asrama Putra) ---
	var s := Node3D.new()
	s.name = "Serambi"
	a.add_child(s)
	_static_box(s, Vector3(3.0, 0.14, 2.6), Vector3(144.4, -0.05, 9), Palette.BATU)
	for tz in [8.0, 10.0]:
		s.add_child(Palette.cylinder(0.09, 0.09, 2.6, Vector3(143.1, 1.3, tz), Palette.KREM))
		var tg := StaticBody3D.new()
		tg.position = Vector3(143.1, 1.3, tz)
		var tg_shape := CollisionShape3D.new()
		var tg_box := BoxShape3D.new()
		tg_box.size = Vector3(0.212, 2.6, 0.212)
		tg_shape.shape = tg_box
		tg.add_child(tg_shape)
		s.add_child(tg)
	var atap := Node3D.new()
	atap.name = "AtapSerambi"
	atap.position = Vector3(144.4, 3.2, 9)
	atap.rotation.z = deg_to_rad(20.0)
	s.add_child(atap)
	atap.add_child(Palette.box(Vector3(3.4, 0.12, 3.0), Vector3(0, 0, 0), Palette.ZAMRUD_GELAP))
	atap.add_child(Palette.box(Vector3(0.1, 0.14, 3.0), Vector3(-1.65, 0, 0), Palette.EMAS_DESAIN, 0.4))
	s.add_child(MaterialTekstur.kotak(Vector3(0.5, 0.08, 2.4), Vector3(142.65, 0.04, 9), MaterialTekstur.pondasi(Palette.BATU, Vector3(0.25, 0.04, 1.2))))
	# --- Plakat "ASRAMA PUTRI" di atas pintu (pola PlakatAsramaPutra) ---
	# P6: label font 32 (teks 2,07 m, ukur_label_plakat) + papan
	# disesuaikan (emas 2,55x0,9, zamrud 2,4x0,75); bawah papan emas
	# y 3,85 bersih dari ujung atap serambi (~3,78).
	var p := Node3D.new()
	p.name = "PlakatAsramaPutri"
	a.add_child(p)
	p.add_child(Palette.box(Vector3(0.06, 0.9, 2.55), Vector3(145.84, 4.3, 9), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.08, 0.75, 2.4), Vector3(145.80, 4.3, 9), Palette.ZAMRUD_GELAP))
	var label := Palette.label3d("ASRAMA PUTRI", Vector3(145.73, 4.3, 9), 32, Color("#f2c14e"), false)
	label.name = "PlakatTeks"
	label.rotation.y = -PI / 2.0
	label.double_sided = false
	p.add_child(label)


## Jendela lengkung Surau (salin PERSIS AsramaPutra._jendela_lengkung):
## kotak emas + kotak gelap + cakram emas + cakram gelap di atas.
## `pos` = pusat kotak di bidang dinding; `rot_y` memutar muka
## jendela ke luar (0 = utara, PI = selatan, -PI/2 = timur).
static func _jendela_lengkung(parent: Node3D, nama: String, pos: Vector3, rot_y: float) -> void:
	var j := Node3D.new()
	j.name = nama
	j.position = pos
	j.rotation.y = rot_y
	parent.add_child(j)
	j.add_child(Palette.box(Vector3(1.1, 1.8, 0.12), Vector3(0, 0, 0), Palette.EMAS, 0.3))
	j.add_child(Palette.box(Vector3(0.9, 1.6, 0.1), Vector3(0, 0, -0.02), Palette.ZAMRUD_GELAP))
	var cakram_emas := Palette.cylinder(0.55, 0.55, 0.06, Vector3(0, 0.8, -0.02), Palette.EMAS, 0.3)
	cakram_emas.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_emas)
	var cakram_gelap := Palette.cylinder(0.45, 0.45, 0.06, Vector3(0, 0.8, -0.04), Palette.ZAMRUD_GELAP)
	cakram_gelap.rotation.x = deg_to_rad(90.0)
	j.add_child(cakram_gelap)


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
	# KOREKSI P2 (Nadia): offset LAMA (+0,02/+0,07 dari pusat dinding)
	# ternyata TERBENAM — muka dinding di +0,125 (tebal 0,25), jadi
	# kotak emas (tepi luar +0,08) dan zamrud (+0,12) tidak keluar
	# dari dinding: dari luar tidak terlihat sama sekali (foto P2
	# membuktikan: fasad Kelas/Madrasah polos). Offset baru +0,13/
	# +0,18: emas menonjol 0,065, zamrud 0,105 dari muka dinding.
	if pintu_sisi == "S" or pintu_sisi == "N":
		for sisi in [-1.0, 1.0]:
			var sf: float = sisi
			var wx := cx + sf * sx / 2.0
			for wz in [cz - sz / 4.0, cz + sz / 4.0]:
				g.add_child(Palette.box(Vector3(0.12, 1.2, 1.1), Vector3(wx + sf * 0.13, 1.8, wz), Palette.EMAS, 0.3))
				g.add_child(Palette.box(Vector3(0.1, 1.0, 0.9), Vector3(wx + sf * 0.18, 1.8, wz), Palette.ZAMRUD_GELAP))
	else:
		for sisi in [-1.0, 1.0]:
			var sf: float = sisi
			var wz := cz + sf * sz / 2.0
			for wx in [cx - sx / 4.0, cx + sx / 4.0]:
				g.add_child(Palette.box(Vector3(1.1, 1.2, 0.12), Vector3(wx, 1.8, wz + sf * 0.13), Palette.EMAS, 0.3))
				g.add_child(Palette.box(Vector3(0.9, 1.0, 0.1), Vector3(wx, 1.8, wz + sf * 0.18), Palette.ZAMRUD_GELAP))
	# P2 (Nadia, 18 Nov 2026 — ACC Mas 14:01 WIB): fasad pintu tidak
	# lagi polos — 2 jendela (gaya SAMA dengan jendela samping:
	# bingkai emas + isi zamrud, y 1,8) mengapit pintu, ±2,2 m dari
	# pusat pintu (di atas segmen dinding, bersih dari celah pintu
	# 0,8 m dan sudut), + lis EMAS vertikal di kedua sudut fasad
	# (tinggi = tinggi gedung - 0,15, bersih dari lis atap).
	if pintu_sisi == "S" or pintu_sisi == "N":
		var f: float = 1.0 if pintu_sisi == "S" else -1.0
		var zf := cz + f * sz / 2.0
		for jx in [cx - 2.2, cx + 2.2]:
			g.add_child(Palette.box(Vector3(1.1, 1.2, 0.12), Vector3(jx, 1.8, zf + f * 0.13), Palette.EMAS, 0.3))
			g.add_child(Palette.box(Vector3(0.9, 1.0, 0.1), Vector3(jx, 1.8, zf + f * 0.18), Palette.ZAMRUD_GELAP))
		for lx in [cx - sx / 2.0 + 0.07, cx + sx / 2.0 - 0.07]:
			g.add_child(Palette.box(Vector3(0.14, tinggi - 0.15, 0.12), Vector3(lx, (tinggi - 0.15) / 2.0, zf + f * 0.13), Palette.EMAS, 0.4))
	else:
		var f: float = -1.0 if pintu_sisi == "W" else 1.0
		var xf := cx + f * sx / 2.0
		for jz in [cz - 2.2, cz + 2.2]:
			g.add_child(Palette.box(Vector3(0.12, 1.2, 1.1), Vector3(xf + f * 0.13, 1.8, jz), Palette.EMAS, 0.3))
			g.add_child(Palette.box(Vector3(0.1, 1.0, 0.9), Vector3(xf + f * 0.18, 1.8, jz), Palette.ZAMRUD_GELAP))
		for lz in [cz - sz / 2.0 + 0.07, cz + sz / 2.0 - 0.07]:
			g.add_child(Palette.box(Vector3(0.12, tinggi - 0.15, 0.14), Vector3(xf + f * 0.13, (tinggi - 0.15) / 2.0, lz), Palette.EMAS, 0.4))
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
	# P6 (Nadia, 18 Nov 2026 — ACC Mas 14:01 WIB): label diperbesar
	# font 20 -> 32 (teks 0,52 m) + papan zamrud berbingkai emas di
	# belakangnya (pola plakat Asrama Putra) — lebar papan dihitung
	# dari lebar teks terukur (ukur_label_plakat: font 32), supaya
	# terbaca dari jarak normal 8-15 m. Papan y 2,98 (di atas lis
	# pintu 2,65, di bawah lis atap; Kantor 3,4 m paling mepet).
	var lebar_teks: float = Palette.FONT_GAME.get_string_size(label_teks, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x * 0.01
	var papan_emas := Palette.box(Vector3(lebar_teks + 0.45, 0.7, 0.06), pintu_pos + Vector3(0, 2.98, 0) + keluar * 0.10, Palette.EMAS, 0.4)
	papan_emas.rotation.y = putar_label
	g.add_child(papan_emas)
	var papan_zamrud := Palette.box(Vector3(lebar_teks + 0.3, 0.6, 0.08), pintu_pos + Vector3(0, 2.98, 0) + keluar * 0.14, Palette.ZAMRUD_GELAP)
	papan_zamrud.rotation.y = putar_label
	g.add_child(papan_zamrud)
	var label := Palette.label3d(label_teks, pintu_pos + Vector3(0, 2.98, 0) + keluar * 0.20, 32, Color("#f2c14e"), false)
	label.name = "Label" + nama
	label.rotation.y = putar_label
	label.double_sided = false
	g.add_child(label)
	var label_dalam := Palette.label3d(label_teks, pintu_pos + Vector3(0, 2.98, 0) - keluar * 0.18, 32, Color("#f2c14e"), false)
	label_dalam.name = "Label" + nama + "Belakang"
	label_dalam.rotation.y = putar_label + PI
	label_dalam.double_sided = false
	g.add_child(label_dalam)
	return pintu_pos


## ------------------------------------------------------------------
## Daun pintu TERTUTUP KelasPutri (RONDE PERBAIKAN, integrasi item 14
## permanen) — dua daun jati rapat di celah pintu selatan (x 129,2..
## 130,8, z=14 — Kelas geser ke (130,10) saat perluasan 18 Nov), rata
## dengan dinding (tebal 0,25), + collision via
## _static_box (pola PintuGerbangPutri) + dua gagang emas di sisi luar.
## ------------------------------------------------------------------
static func _daun_pintu_kelas_putri(kampus: Node3D) -> void:
	var p := Node3D.new()
	p.name = "PintuKelasPutri"
	kampus.add_child(p)
	_static_box(p, Vector3(0.8, 2.6, 0.25), Vector3(129.6, 1.3, 14.0), Palette.JATI)
	_static_box(p, Vector3(0.8, 2.6, 0.25), Vector3(130.4, 1.3, 14.0), Palette.JATI)
	# Gagang emas di sisi luar (selatan), di pertemuan dua daun.
	p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(129.94, 1.05, 14.16), Palette.EMAS, 0.4))
	p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(130.06, 1.05, 14.16), Palette.EMAS, 0.4))


## ------------------------------------------------------------------
## Daun pintu TERTUTUP generik (Dewi, 18 Nov 2026 — perintah Mas
## 07:09 WIB: tiap gedung putri HARUS punya pintu TERLIHAT di luar;
## masuk tetap pakai tombol MASUK → teleport, BUKAN jalan tembus).
## Pola persis _daun_pintu_kelas_putri: dua daun jati rapat di celah,
## rata dengan dinding (tebal 0,25), collision via _static_box
## (pemain mentok seperti mentok dinding — TIDAK bisa jalan tembus
## ke cangkang kosong), + dua gagang emas di sisi luar.
## `lebar`/`tinggi` = ukuran celah sebenarnya (Musholla 2,0x3,0;
## Pos Jaga 1,2x1,8; gedung generik 1,6x2,6 = LEBAR/TINGGI_PINTU).
## Gagang TIDAK punya collision (visual saja) supaya tidak ada yang
## menahan pemain di depan pintu. Daun TIDAK menonjol ke jalan.
## ------------------------------------------------------------------
static func _daun_pintu(kampus: Node3D, nama: String, pintu: Vector3, sisi: String, lebar: float = LEBAR_PINTU, tinggi: float = TINGGI_PINTU) -> void:
	var p := Node3D.new()
	p.name = nama
	kampus.add_child(p)
	var setengah_daun := lebar / 2.0
	var y_tengah := tinggi / 2.0
	match sisi:
		"S", "N":
			# Daun sejajar sumbu x, tebal di z; gagang di sisi luar.
			_static_box(p, Vector3(setengah_daun, tinggi, 0.25), Vector3(pintu.x - lebar / 4.0, y_tengah, pintu.z), Palette.JATI)
			_static_box(p, Vector3(setengah_daun, tinggi, 0.25), Vector3(pintu.x + lebar / 4.0, y_tengah, pintu.z), Palette.JATI)
			var zg := pintu.z + 0.16 if sisi == "S" else pintu.z - 0.16
			p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(pintu.x - 0.06, 1.05, zg), Palette.EMAS, 0.4))
			p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(pintu.x + 0.06, 1.05, zg), Palette.EMAS, 0.4))
		"W", "E":
			# Daun sejajar sumbu z, tebal di x; gagang di sisi luar.
			_static_box(p, Vector3(0.25, tinggi, setengah_daun), Vector3(pintu.x, y_tengah, pintu.z - lebar / 4.0), Palette.JATI)
			_static_box(p, Vector3(0.25, tinggi, setengah_daun), Vector3(pintu.x, y_tengah, pintu.z + lebar / 4.0), Palette.JATI)
			var xg := pintu.x - 0.16 if sisi == "W" else pintu.x + 0.16
			p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(xg, 1.05, pintu.z - 0.06), Palette.EMAS, 0.4))
			p.add_child(Palette.box(Vector3(0.06, 0.18, 0.06), Vector3(xg, 1.05, pintu.z + 0.06), Palette.EMAS, 0.4))


## ------------------------------------------------------------------
## Pos jaga Timur Laut (176,-20) — gubuk 3x3 m pola _gubuk_pos
## builder, pintu menghadap BARAT (ke jalan internal). Tanpa lampu
## jalan (brief: tidak ada tiang/lampu di jalan).
## P3 (18 Nov, ACC Mas): bahasa Surau — lantai BATU, dinding KREM
## (dulu KAYU penuh), lis EMAS_DESAIN di tepi atas + bawah dinding;
## atap piramida ZAMRUD_GELAP dipertahankan.
## ------------------------------------------------------------------
static func _pos_jaga_tl(kampus: Node3D) -> void:
	var g := Node3D.new()
	g.name = "PosJagaTL"
	g.position = POS_JAGA_TL_POS
	kampus.add_child(g)
	_static_box(g, Vector3(3, 0.14, 3), Vector3(0, -0.05, 0), Palette.BATU)
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, -1.5), Palette.KREM)
	_static_box(g, Vector3(3, 2.6, 0.2), Vector3(0, 1.3, 1.5), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 3), Vector3(1.5, 1.3, 0), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(-1.5, 1.3, -1.05), Palette.KREM)
	_static_box(g, Vector3(0.2, 2.6, 0.9), Vector3(-1.5, 1.3, 1.05), Palette.KREM)
	_static_box(g, Vector3(0.2, 0.8, 1.2), Vector3(-1.5, 2.2, 0), Palette.KREM)
	# Lis emas: pita atas (y 2,53, keliling penuh) + pita bawah
	# (y 0,10); pita bawah sisi pintu (barat) ikut segmen dinding
	# (tidak menutup celah pintu). Visual saja, tanpa collision.
	for z_lis in [-1.5, 1.5]:
		g.add_child(Palette.box(Vector3(3.14, 0.14, 0.26), Vector3(0, 2.53, z_lis), Palette.EMAS_DESAIN, 0.4))
		g.add_child(Palette.box(Vector3(3.14, 0.16, 0.26), Vector3(0, 0.10, z_lis), Palette.EMAS_DESAIN, 0.4))
	for x_lis in [-1.5, 1.5]:
		g.add_child(Palette.box(Vector3(0.26, 0.14, 3.14), Vector3(x_lis, 2.53, 0), Palette.EMAS_DESAIN, 0.4))
	g.add_child(Palette.box(Vector3(0.26, 0.16, 3.14), Vector3(1.5, 0.10, 0), Palette.EMAS_DESAIN, 0.4))
	for z_lis in [-1.05, 1.05]:
		g.add_child(Palette.box(Vector3(0.26, 0.16, 0.94), Vector3(-1.5, 0.10, z_lis), Palette.EMAS_DESAIN, 0.4))
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
	# P3 (18 Nov): label diperbesar font 20 -> 28 (P6, supaya terbaca
	# dari jarak normal) + digeser ke y 2,3 supaya seluruhnya di
	# dinding krem, tidak menabrak lis emas atas (y 2,53).
	var label := Palette.label3d("POS JAGA", Vector3(-1.6, 2.3, 0), 28, Color("#f2c14e"), false)
	label.name = "LabelPos"
	label.rotation.y = -PI / 2.0
	label.double_sided = false
	g.add_child(label)
	var label_dalam := Palette.label3d("POS JAGA", Vector3(-1.35, 2.3, 0), 28, Color("#f2c14e"), false)
	label_dalam.name = "LabelPosBelakang"
	label_dalam.rotation.y = PI / 2.0
	label_dalam.double_sided = false
	g.add_child(label_dalam)


## ------------------------------------------------------------------
## Jalan internal N-S x=142, lebar 3 m, z -35..+22 (57 m — diperpanjang
## 8 m ke selatan saat perluasan 18 Nov, supaya mencapai KonekSpawn z=16), pasir,
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
	var utama := Palette.box(Vector3(3, 0.06, 57), Vector3(JALAN_INTERNAL_X, 0.03, -6.5), Palette.PASIR)
	utama.name = "JalanUtama"
	j.add_child(utama)
	# (nama, ukuran, posisi) — konektor E-W lebar 2,5 m.
	var konektor: Array = [
		["KonekMusholla", Vector3(6.5, 0.06, 2.5), Vector3(137.25, 0.03, -19)],
		["KonekKelas", Vector3(5.5, 0.06, 2.5), Vector3(137.75, 0.03, 10)],
		["KonekAsrama", Vector3(2.5, 0.06, 2.5), Vector3(144.75, 0.03, 9)],
		["KonekKantor", Vector3(2.5, 0.06, 2.5), Vector3(144.75, 0.03, -33)],
		["KonekMadrasah", Vector3(3.5, 0.06, 2.5), Vector3(145.25, 0.03, -12)],
		["KonekStudio", Vector3(22.5, 0.06, 2.5), Vector3(154.75, 0.03, -18)],
		# KonekPosJaga DIPANJANGKAN saat perluasan 18 Nov (pos pindah ke
		# (176,-20)): panjang 31 m, x 143,5..174,5, di z=-21 — BUKAN z=-20,
		# supaya tidak tumpang tindih dengan KonekStudio (z=-18) dan tidak
		# z-fighting; pintu pos (174,5,-20) tetap terjangkau koridor ini.
		# RONDE PERBAIKAN (Raka, integrasi item 14 permanen): konektor
		# spawn putri (140,16) -> JalanInternal x=142 — dari spawn jalan
		# ke TIMUR di atas aspal, lalu belok utara menyusuri jalan
		# internal; bukan lagi menembus Kelas.
		["KonekSpawn", Vector3(7.5, 0.06, 2.5), Vector3(138.25, 0.03, 16)],
		["KonekPosJaga", Vector3(31, 0.06, 2.5), Vector3(159, 0.03, -21)],
	]
	for k in konektor:
		var slab := Palette.box(k[1], k[2], Palette.PASIR)
		slab.name = k[0]
		j.add_child(slab)


## ------------------------------------------------------------------
## Taman Putri (122,32) — tapak 10x8 m di pojok barat-daya kampus
## putri (RONDE 4, Dewi, 18 Nov 2026; perintah Mas 14:17 WIB "Taman
## taruh di pojok aja.. jangan di depan musholla"). Tapak LAMA
## (128,-12) kini TANAH KOSONG. Tapak baru: x 117..127, z 28..36 —
## 2 m dari tembok barat (x=115), 4 m dari tembok selatan (z=+40),
## jauh dari Musholla (134,-24), tidak menabrak gedung/tapak cadangan.
## Halaman TERBUKA: alas rumput + 6 bedeng bunga (48 bunga, 10 warna)
## + 3 semak + papan nama kecil + pagar bambu (celah timur 2,5 m).
## Paving cobblestone 13,5x2,5 m ke TIMUR (x 127..140,5) + strip
## penghubung ke utara (x 140,5..143,5, z 22..32) yang menyambung ke
## ujung selatan JalanInternal (z=+22, pola konektor: hanya berbagi
## tepi z=22, tidak tumpang tindih).
## SEMUA elemen visual saja (TANPA collision): rumput di atas tanah
## (y 0..0,06, pola slab jalan), bedeng/semak/papan rendah — pemain
## jalan bebas di atas halaman. Palet putri: krem / zamrud / emas.
## ------------------------------------------------------------------
static func _halaman_cangkruk(kampus: Node3D) -> void:
	# REVISI RONDE 4 (Dewi, 18 Nov 2026 — perintah Mas 14:17 WIB
	# "Taman taruh di pojok aja.. jangan di depan musholla"): SELURUH
	# isi ronde 3 DIPINDAH ke pojok barat-daya (122,32), layout SAMA
	# persis (offset dx=-6, dz=+44 dari pusat lama; semua koordinat
	# ditulis relatif ke cx/cz). Tapak lama (128,-12) KOSONG total.
	# RONDE 3 (perintah Mas 13:56 WIB "Samakan dng taman pondok
	# putra"): bahasa desain taman putra (foto F5/F6 +
	# _lingkungan_glb/_pagar_taman): pagar bambu keliling (bilah
	# vertikal + 2 rel), bunga BERTANGKAI di atas alas tanah gelap,
	# bangku kayu, pohon, lampu tiang, jalur cobblestone + rumput
	# leafy grass. Papan nama DINAIKKAN (tiang 1,9 m) supaya label
	# di atas pagar 1,5 m dan tetap terbaca dari jalan — seperti
	# papan taman putra di F6.
	var h := Node3D.new()
	h.name = "HalamanCangkruk"
	kampus.add_child(h)
	var cx := 122.0
	var cz := 32.0
	# Kotak bertekstur (tekstur GLB taman putra) — fallback warna
	# datar bila tekstur gagal dimuat.
	var kotak_tekstur := func(ukuran: Vector3, pos: Vector3, tex: Texture2D, skala: Vector3, darurat: Color) -> MeshInstance3D:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = ukuran
		mi.mesh = mesh
		mi.position = pos
		if tex != null:
			var m := StandardMaterial3D.new()
			m.albedo_texture = tex
			m.uv1_scale = skala
			m.roughness = 0.95
			mi.material_override = m
		else:
			mi.material_override = Palette.mat(darurat)
		return mi
	var tex_rumput := load("res://models/taman_leafy_grass_1k.ktx2") as Texture2D
	var tex_batu := load("res://models/taman_cobblestone_01_1k.ktx2") as Texture2D
	var tex_tanah := load("res://models/taman_farm_soil_1k.ktx2") as Texture2D
	# Alas rumput 10x8 m (slab di atas tanah, y 0..0,06) — tekstur
	# leafy grass seperti taman putra, bukan hijau datar.
	var rumput: MeshInstance3D = kotak_tekstur.call(Vector3(10, 0.06, 8), Vector3(cx, 0.03, cz), tex_rumput, Vector3(5, 4, 1), Palette.RUMPUT)
	rumput.name = "AlasRumput"
	h.add_child(rumput)
	# PAGAR BAMBU keliling (RONDE 3 — gaya taman putra, F5/F6:
	# bilah vertikal ±1,5 m + 2 rel horizontal, warna bambu/kayu).
	# Visual saja, TANPA collision. Utara + selatan + barat penuh;
	# timur bercelah 2,5 m di tengah (z cz±1,25, sejajar paving
	# ke jalan). Tiang sudut + tiang tepi celah (1,6 m).
	var pagar := Node3D.new()
	pagar.name = "PagarBambu"
	h.add_child(pagar)
	var warna_bambu := Color("#d3b578")
	var segmen_pagar: Array = [
		[Vector2(cx - 5, cz - 4), Vector2(cx + 5, cz - 4)],
		[Vector2(cx - 5, cz + 4), Vector2(cx + 5, cz + 4)],
		[Vector2(cx - 5, cz - 4), Vector2(cx - 5, cz + 4)],
		[Vector2(cx + 5, cz - 4), Vector2(cx + 5, cz - 1.25)],
		[Vector2(cx + 5, cz + 1.25), Vector2(cx + 5, cz + 4)],
	]
	var n_bilah := 0
	var n_rel := 0
	for seg in segmen_pagar:
		var a: Vector2 = seg[0]
		var b: Vector2 = seg[1]
		var panjang := a.distance_to(b)
		var arah := (b - a).normalized()
		var sepanjang_x := absf(b.x - a.x) >= absf(b.y - a.y)
		var n := int(panjang / 0.3)
		for i in range(n + 1):
			var p := a + arah * (float(i) * panjang / float(n))
			var bilah := Palette.box(
				Vector3(0.12, 1.5, 0.05) if sepanjang_x else Vector3(0.05, 1.5, 0.12),
				Vector3(p.x, 0.75, p.y), warna_bambu)
			bilah.name = "Bilah_%03d" % n_bilah
			n_bilah += 1
			pagar.add_child(bilah)
		for y_rel in [0.45, 1.15]:
			var rel := Palette.box(
				Vector3(panjang + 0.1, 0.07, 0.05) if sepanjang_x else Vector3(0.05, 0.07, panjang + 0.1),
				Vector3((a.x + b.x) / 2.0, y_rel, (a.y + b.y) / 2.0), Palette.KAYU)
			rel.name = "Rel_%02d" % n_rel
			n_rel += 1
			pagar.add_child(rel)
	var n_tiang := 0
	for tp in [Vector2(cx - 5, cz - 4), Vector2(cx + 5, cz - 4), Vector2(cx - 5, cz + 4),
			Vector2(cx + 5, cz + 4), Vector2(cx + 5, cz - 1.25), Vector2(cx + 5, cz + 1.25)]:
		var tiang := Palette.box(Vector3(0.14, 1.6, 0.14), Vector3(tp.x, 0.8, tp.y), Palette.JATI)
		tiang.name = "TiangPagar_%d" % n_tiang
		n_tiang += 1
		pagar.add_child(tiang)
	# Paving ke jalan internal (RONDE 4: x 127..140,5, z cz±1,25) —
	# cobblestone seperti jalur taman putra. RONDE 4: DITAMBAH strip
	# penghubung ke utara (x 140,5..143,5, z 22..32, cobblestone juga)
	# supaya paving benar-benar tersambung ke ujung selatan
	# JalanInternal (z=+22) — strip ini perpanjangan jalan ke selatan,
	# selebar jalan (3 m), hanya berbagi tepi z=22 dengan JalanUtama.
	var paving: MeshInstance3D = kotak_tekstur.call(Vector3(13.5, 0.06, 2.5), Vector3(133.75, 0.03, cz), tex_batu, Vector3(6.75, 1.25, 1), Palette.PASIR)
	paving.name = "PavingKeJalan"
	h.add_child(paving)
	var strip: MeshInstance3D = kotak_tekstur.call(Vector3(3, 0.06, 10), Vector3(142, 0.03, 27), tex_batu, Vector3(1.5, 5, 1), Palette.PASIR)
	strip.name = "PavingStripJalan"
	h.add_child(strip)
	# Paving dalam taman (RONDE 2 Dewi, 18 Nov 2026 — perintah Mas
	# 13:47 WIB "Tidak usah kotak putih gitu.. langsung bunga..
	# terus kasih paving.."): jalur tengah meneruskan PavingKeJalan
	# ke barat masuk taman (x cx±5, lebar sama 2,5 m) + bingkai
	# paving di tepi utara, selatan, dan barat tapak. RONDE 3:
	# jalur tengah pakai cobblestone yang sama (tekstur taman
	# putra); bingkai tetap PASIR. Paving 1,5 cm di atas rumput
	# (y atas 0,075 vs rumput 0,06) supaya tidak z-fighting; sisi
	# timur dibiarkan terbuka (pintu masuk lewat celah 2,5 m).
	var paving_tengah: MeshInstance3D = kotak_tekstur.call(Vector3(10, 0.06, 2.5), Vector3(cx, 0.045, cz), tex_batu, Vector3(5, 1.25, 1), Palette.PASIR)
	paving_tengah.name = "PavingTengah"
	h.add_child(paving_tengah)
	var bingkai_utara := Palette.box(Vector3(10, 0.06, 0.5), Vector3(cx, 0.045, cz - 3.75), Palette.PASIR)
	bingkai_utara.name = "PavingBingkaiUtara"
	h.add_child(bingkai_utara)
	var bingkai_selatan := Palette.box(Vector3(10, 0.06, 0.5), Vector3(cx, 0.045, cz + 3.75), Palette.PASIR)
	bingkai_selatan.name = "PavingBingkaiSelatan"
	h.add_child(bingkai_selatan)
	var bingkai_barat := Palette.box(Vector3(0.5, 0.06, 7.0), Vector3(cx - 4.75, 0.045, cz), Palette.PASIR)
	bingkai_barat.name = "PavingBingkaiBarat"
	h.add_child(bingkai_barat)
	# 6 rumpun bunga, 8 bunga tiap rumpun = 48 bunga, 10 warna
	# (posisi rumpun SAMA seperti revisi 13:38 — 2 baris x 4 kolom,
	# jarak 0,5 m — di luar jalur tengah (z cz±1,25) dan
	# jauh dari papan nama (126,2,33,8); tengah tapak (122,32)
	# tetap kosong untuk pemain). RONDE 3 (gaya taman putra, F6):
	# tiap rumpun duduk di atas alas TANAH cokelat gelap rendah
	# dan datar (2,0x0,06x0,9 m, tekstur farm soil — BUKAN kotak
	# putih) dan tiap bunga BERTANGKAI hijau tipis (bola r=0,12
	# di y 0,36, tangkai y 0,12..0,36).
	var rumpun: Array = [
		[Vector2(cx - 2.5, cz - 2.6), [Color("#e88bb0"), Color("#f2c14e"), Color("#ffffff")]],
		[Vector2(cx + 2.5, cz + 2.6), [Color("#d9382b"), Color("#ff8c1a"), Color("#ffd21a")]],
		[Vector2(cx - 2.5, cz + 2.6), [Color("#9b59b6"), Color("#2e86de"), Color("#ffffff")]],
		[Vector2(cx + 2.5, cz - 2.6), [Color("#e23b3b"), Color("#8e44ad"), Color("#e88bb0")]],
		[Vector2(cx, cz - 3.15), [Color("#ffd21a"), Color("#ff8c1a"), Color("#2e86de")]],
		[Vector2(cx, cz + 3.15), [Color("#2e86de"), Color("#9b59b6"), Color("#e88bb0")]],
	]
	var warna_tangkai := Color("#2f7d33")
	for rum in rumpun:
		var rv: Vector2 = rum[0]
		var warna_bunga: Array = rum[1]
		var bedeng: MeshInstance3D = kotak_tekstur.call(Vector3(2.0, 0.06, 0.9), Vector3(rv.x, 0.09, rv.y), tex_tanah, Vector3(2, 1, 1), Color("#5a3a22"))
		bedeng.name = "BedengTanah_%d_%d" % [int(rv.x), int(rv.y)]
		h.add_child(bedeng)
		for i in range(8):
			var fx := rv.x - 0.75 + float(i % 4) * 0.5
			var fz := rv.y + (0.28 if i < 4 else -0.28)
			h.add_child(Palette.cylinder(0.02, 0.02, 0.24, Vector3(fx, 0.24, fz), warna_tangkai))
			h.add_child(Palette.sphere(0.12, Vector3(fx, 0.36, fz), warna_bunga[i % 3]))
	# 3 semak zamrud di sudut (visual saja).
	for semak in [Vector2(cx - 4.2, cz - 3.2), Vector2(cx + 4.2, cz + 3.2), Vector2(cx - 4.2, cz + 3.2)]:
		var sv: Vector2 = semak
		h.add_child(Palette.sphere(0.4, Vector3(sv.x, 0.4, sv.y), Palette.ZAMRUD_GELAP))
	# 2 BANGKU KAYU (RONDE 3 — gaya bangku taman putra: papan
	# duduk + sandaran + 2 kaki; visual saja, tanpa collision).
	# Utara menghadap selatan ke jalur tengah, selatan menghadap
	# utara; keduanya di luar rumpun bunga dan tidak menutupi
	# papan nama maupun jalur.
	for bangku_data in [["BangkuUtara", Vector3(cx, 0, cz - 1.6), 0.0],
			["BangkuSelatan", Vector3(cx, 0, cz + 1.6), PI]]:
		var bangku := Node3D.new()
		bangku.name = String(bangku_data[0])
		bangku.position = bangku_data[1] as Vector3
		bangku.rotation.y = float(bangku_data[2])
		h.add_child(bangku)
		var duduk := Palette.box(Vector3(1.6, 0.08, 0.5), Vector3(0, 0.45, 0), Palette.KAYU)
		duduk.name = "Duduk"
		bangku.add_child(duduk)
		var sandaran := Palette.box(Vector3(1.6, 0.55, 0.07), Vector3(0, 0.78, -0.25), Palette.KAYU)
		sandaran.name = "Sandaran"
		bangku.add_child(sandaran)
		for kx in [-0.7, 0.7]:
			var kaki := Palette.box(Vector3(0.08, 0.45, 0.45), Vector3(kx, 0.225, 0), Palette.KAYU_GELAP)
			kaki.name = "Kaki_%s" % ("Kiri" if kx < 0.0 else "Kanan")
			bangku.add_child(kaki)
	# 1 POHON di dalam taman (RONDE 3 — batang + tajuk seperti
	# pohon taman putra; visual saja). Sudut barat-laut (124,29,8):
	# di luar jalur tengah, jauh dari rumpun bunga + semak.
	var pohon := Node3D.new()
	pohon.name = "PohonTaman"
	pohon.position = Vector3(cx + 2.0, 0, cz - 2.2)
	h.add_child(pohon)
	var batang := Palette.cylinder(0.14, 0.18, 1.9, Vector3(0, 0.95, 0), Palette.KAYU_GELAP)
	batang.name = "Batang"
	pohon.add_child(batang)
	var tajuk := Palette.sphere(0.95, Vector3(0, 2.45, 0), Palette.ZAMRUD_GELAP)
	tajuk.name = "Tajuk"
	pohon.add_child(tajuk)
	var tajuk_atas := Palette.sphere(0.55, Vector3(0.25, 3.15, 0.2), Palette.RUMPUT)
	tajuk_atas.name = "TajukAtas"
	pohon.add_child(tajuk_atas)
	# 1 LAMPU TIANG (RONDE 3 — gaya LampuV2_Taman / _lamp:
	# tiang gelap + bola putih menyala; visual saja). Di tepi
	# jalur, sisi utara celah masuk timur (126,5,30,5) — dekat
	# papan nama, tidak menutupi bunga maupun jalur.
	var lampu := Node3D.new()
	lampu.name = "LampuTaman"
	lampu.position = Vector3(cx + 4.5, 0, cz - 1.5)
	h.add_child(lampu)
	var tiang_lampu := Palette.cylinder(0.05, 0.07, 3.0, Vector3(0, 1.5, 0), Palette.HITAM)
	tiang_lampu.name = "Tiang"
	lampu.add_child(tiang_lampu)
	var mat_bohlam := StandardMaterial3D.new()
	mat_bohlam.albedo_color = Color("#ffffff")
	mat_bohlam.emission_enabled = true
	mat_bohlam.emission = Color("#ffffff")
	mat_bohlam.emission_energy_multiplier = 1.5
	var bohlam := MeshInstance3D.new()
	var mesh_bohlam := SphereMesh.new()
	mesh_bohlam.radius = 0.22
	mesh_bohlam.height = 0.44
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): 12x6 + tanpa bayangan.
	mesh_bohlam.radial_segments = 12
	mesh_bohlam.rings = 6
	bohlam.mesh = mesh_bohlam
	bohlam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bohlam.position = Vector3(0, 3.1, 0)
	bohlam.material_override = mat_bohlam
	bohlam.name = "BohlamLampu"
	bohlam.add_to_group("LampuJalan")
	lampu.add_child(bohlam)
	# Papan nama kecil di dekat pintu masuk timur (menghadap jalan).
	# RONDE 3: DINAIKKAN (tiang 1,9 m, papan y 1,5..2,0) — supaya
	# label "TAMAN PUTRI" berada DI ATAS pagar bambu 1,5 m dan tetap
	# terbaca dari jalan (seperti papan taman putra di F6). Sebelumnya
	# papan y 0,75 akan tertutup bilah pagar dari sudut pandang jalan.
	# RONDE 4: posisi XZ pindah mengikuti taman (126,2,33,8).
	var papan := Node3D.new()
	papan.name = "PapanTaman"
	h.add_child(papan)
	papan.add_child(Palette.cylinder(0.05, 0.05, 1.9, Vector3(cx + 4.2, 0.95, cz + 1.3), Palette.JATI))
	papan.add_child(Palette.cylinder(0.05, 0.05, 1.9, Vector3(cx + 4.2, 0.95, cz + 2.3), Palette.JATI))
	papan.add_child(Palette.box(Vector3(0.08, 0.5, 1.4), Vector3(cx + 4.2, 1.75, cz + 1.8), Palette.JATI))
	var label := Palette.label3d("TAMAN PUTRI", Vector3(cx + 4.26, 1.75, cz + 1.8), 20, Color("#f2c14e"), false)
	label.name = "LabelTaman"
	label.rotation.y = PI / 2.0
	label.double_sided = false
	papan.add_child(label)
