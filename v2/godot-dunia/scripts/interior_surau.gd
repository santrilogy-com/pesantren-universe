class_name InteriorSurau
extends Node3D
## Interior Surau — MAP TERPISAH ala GTA (RONDE 4, Dewa).
##
## Ruangan 18 x 14 m, tinggi 4,6 m, pusat (0, 0, -301): LEBIH LUAS dari
## interior lama (14 x 12 m) dan dari cangkang luar Surau (12 x 10 m).
## Interior yang lebih besar dari cangkangnya adalah trik standar map
## terpisah ala GTA — dari luar tidak kelihatan, dari dalam terasa lapang.
##
## Dinding selatan TETAP di z=-294 (sama seperti interior lama) supaya
## koridor pintu yang di-hardcode di main.gd (_cek_pintu_surau:
## keluar saat |x|<1,2 dan z di (-294, -292,5)) tetap bekerja tanpa
## perubahan. Pintu 2,4 m (|x|<1,2), ambang atas 3,5 m.
## ASUMSI (laporan Gilang belum ada saat file ini ditulis): pintu luar
## Surau 2,4 m — sama dengan cangkang di pesantren_builder.gd saat ini.
##
## ISI (semua wajib): 3 meja sampar lesehan + kitab, 2 rak kitab,
## 4 lampu hangat, smartboard 3D (barat) + layar Label3D, mihrab +
## 15 sajadah, papan jadwal Ngaji Aja, label KELUAR.
## RONDE 5 (15 Nov — Mas: "Papan tulis di surau hapus. Cukup smartboard
## aja"): papan dinding (papan tulis) DIHAPUS dari interior ini —
## sebagai papan tulis, yang tersisa hanyalah Smartboard.
##
## INTERFACE (dipakai Raka saat wiring, sama persis dengan yang
## dikembalikan PesantrenBuilder.build() hari ini):
##   build() -> {
##     "root": Node3D, "interior_door": Vector3(0,0,-294),
##     "interior_spawn": Vector3(0,0,-295.5),
##     "smartboard_spot": Vector3(-6.8,0,-301),
##     "smartboard_screen": Label3D,
##     "surau_bounds": {"min_x":-9, "max_x":9, "min_z":-308, "max_z":-294},
##   }
## Smartboard: interaksi BUKAN dari file ini. main.gd sudah memanggil
## _ui.open_smartboard() (milik Tara, ui.gd) saat pemain dekat
## smartboard_spot dan menekan interaksi; konten slide tampil di
## POPUP UI. RONDE 10 (Mas: tulisan di smartboard dihapus): layar
## 3D "SmartboardScreen" kini KOSONG — main.gd tidak lagi menulis
## teks ke papan (lihat _on_slide_changed).
## (Catatan koreksi: brief menyebut show_smartboard(), tapi fungsi itu
## TIDAK ADA di ui.gd — yang ada open_smartboard().)
##
## Dipakai dua cara: (1) InteriorSurau.build() dari main.gd (Raka);
## (2) scene res://scenes/interior_surau.tscn untuk tes/isolasi —
## _ready() membangun isi kalau belum ada.

const ROOM_CENTER := Vector3(0, 0, -301)
const ROOM_HALF_X := 9.0
const ROOM_HALF_Z := 7.0
const WALL_HEIGHT := 4.6
const DOOR_HALF := 1.2
const DOOR_TOP := 3.5
const INTERIOR_DOOR := Vector3(0, 0, -294)
const INTERIOR_SPAWN := Vector3(0, 0, -295.5)
## RONDE 14: smartboard pindah ke ujung utara dinding barat (-305.2)
## karena mihrab kini di tengah dinding (z=-301) — titik berdiri ikut.
const SMARTBOARD_SPOT := Vector3(-6.8, 0, -305.2)
## BACA BUKU (Tara, 17 Nov 2026): titik interaksi rak kitab — posisi
## LOKAL pra-rotasi (sama seperti _rak_kitab di _bangun); dunia =
## ke_dunia() di build(). Rak barat (-8.8,-296) di dinding barat
## selatan; rak timur (8.8,-306) di dinding timur utara.
const RAK_BARAT := Vector3(-8.8, 0, -296.0)
const RAK_TIMUR := Vector3(8.8, 0, -306.0)
const SURAU_BOUNDS := {"min_x": -9.0, "max_x": 9.0, "min_z": -308.0, "max_z": -294.0}
## RONDE 10: arah kiblat dari Indonesia ≈ 295° (barat-barat laut).
## rotation.y = -azimut: node yang menghadap -Z (utara) diputar ke
## 295° (muka -Z -> (-sin(-295°), -cos(-295°)) = (-0.906, -0.423)
## = arah 295°). Matahari terbenam di 252° (RONDE 12, K_MATAHARI jam
## 18.0) — 43° di KIRI mihrab saat menghadap kiblat.
const KIBLAT_AZIMUT := 295.0
## RONDE 14 (Mas: "Putar Suraunya 25°" + "Mihrab harusnya di tengah
## tembok"): ruangan diputar -25° (= kiblat 295° - normal dinding barat
## 270°) mengelilingi PINTU (0,0,-294) — pintu sendiri TIDAK berpindah
## sehingga koridor keluar di main.gd tetap berlaku tanpa perubahan.
## Rotasi lokal untuk node yang menghadap -Z (mihrab, sajadah): -270°
## = -295° (kiblat) + 25° (rotasi ruangan) — di dunia jadi -295°.
const PINTU_PIVOT := Vector3(0, 0, -294)
const ROTASI_LOKAL_KIBLAT := -270.0
## REVISI (Mas 17 Nov 22:51 WIB: "Surau lurus aja. Jangan miring."):
## HANYA bangunan luar yang diluruskan (PesantrenBuilder.
## SURAU_ROTASI_DEG = 0°). Interior TETAP miring -25° supaya mihrab
## tetap menghadap kiblat 295° — rotasi ruangan kini konstanta
## SENDIRI di file ini (dulu ikut SURAU_ROTASI_DEG bersama). JANGAN
## ubah nilai ini tanpa perintah Mas (kiblat di dalam = 295°).
const ROTASI_RUANGAN_DEG := -25.0


## Frame pintu DALAM (0,-294) — TETAP miring -25° seperti ruangan.
## Dipakai main.gd untuk koridor keluar dari dalam Surau (pemain
## berjalan keluar lewat celah pintu dalam yang miring). Rumus sama
## seperti surau_pintu() dulu: sumbu = 90° - rotasi, keluar = 180° -
## rotasi (rotasi -25° -> sumbu 115°, keluar 205°).
static func frame_pintu_dalam() -> Dictionary:
	return {
		"sumbu": PesantrenBuilder.arah(90.0 - ROTASI_RUANGAN_DEG),
		"keluar": PesantrenBuilder.arah(180.0 - ROTASI_RUANGAN_DEG),
	}

var _smartboard_screen: Label3D


func _ready() -> void:
	if get_child_count() == 0:
		_bangun()


## Bangun interior (dipakai Raka dari main.gd). Mengembalikan dict
## dengan interface yang sama seperti PesantrenBuilder.build().
## RONDE 14: nilai posisi yang dikembalikan adalah koordinat DUNIA
## setelah rotasi -25° mengelilingi pintu (ke_dunia); konstanta di atas
## adalah posisi pra-rotasi (lokal/absolut sebelum ruangan diputar).
static func build() -> Dictionary:
	var node := InteriorSurau.new()
	node.name = "InteriorSurau"
	node._bangun()
	return {
		"root": node,
		"interior_door": ke_dunia(INTERIOR_DOOR),
		"interior_spawn": ke_dunia(INTERIOR_SPAWN),
		"smartboard_spot": ke_dunia(SMARTBOARD_SPOT),
		"smartboard_screen": node._smartboard_screen,
		"surau_bounds": SURAU_BOUNDS,
		# BACA BUKU (Tara): titik interaksi rak kitab (dunia).
		"rak_spots": [ke_dunia(RAK_BARAT), ke_dunia(RAK_TIMUR)],
	}


## Koordinat pra-rotasi (lokal/absolut, z -308..-294) -> koordinat dunia
## setelah rotasi -25° mengelilingi pintu (0,0,-294).
## (ROTASI_RUANGAN_DEG sendiri, bukan SURAU_ROTASI_DEG — revisi
## Surau lurus 17 Nov 22:51 WIB: interior tetap miring.)
static func ke_dunia(lokal: Vector3) -> Vector3:
	var rot := deg_to_rad(ROTASI_RUANGAN_DEG)
	var c := cos(rot)
	var s := sin(rot)
	var q := lokal - PINTU_PIVOT
	return PINTU_PIVOT + Vector3(q.x * c + q.z * s, q.y, -q.x * s + q.z * c)


func get_smartboard_screen() -> Label3D:
	return _smartboard_screen


func _bangun() -> void:
	# --- Lantai + karpet ---
	_static_box(self, Vector3(18, 0.14, 14), Vector3(0, -0.05, -301), Palette.PASIR_GELAP).name = "Lantai"
	add_child(Palette.box(Vector3(17.4, 0.06, 13.4), Vector3(0, 0.05, -301), Palette.ZAMRUD_GELAP))
	# --- Dinding (collision): utara, barat, timur utuh; selatan dua
	# segmen + ambang pintu 2,4 m. Tebal 0,25, tinggi 4,6.
	_static_box(self, Vector3(18.5, WALL_HEIGHT, 0.25), Vector3(0, 2.3, -308), Palette.PUTIH).name = "DindingUtara"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 14), Vector3(-9, 2.3, -301), Palette.PUTIH).name = "DindingBarat"
	_static_box(self, Vector3(0.25, WALL_HEIGHT, 14), Vector3(9, 2.3, -301), Palette.PUTIH).name = "DindingTimur"
	_static_box(self, Vector3(7.8, WALL_HEIGHT, 0.25), Vector3(-5.1, 2.3, -294), Palette.PUTIH).name = "DindingSelatan_Kiri"
	_static_box(self, Vector3(7.8, WALL_HEIGHT, 0.25), Vector3(5.1, 2.3, -294), Palette.PUTIH).name = "DindingSelatan_Kanan"
	_static_box(self, Vector3(2.4, 1.1, 0.25), Vector3(0, 4.05, -294), Palette.PUTIH).name = "AmbangPintu"
	# --- Plafon (RONDE 7: pakai _static_box — plafon HARUS punya
	# collision supaya SpringArm3D kamera memendek saat pitch curam
	# akan membawa kamera ke atas plafon; lihat interior_cangkruk) ---
	_static_box(self, Vector3(18.5, 0.25, 14.5), Vector3(0, 4.72, -301), Palette.ZAMRUD_GELAP).name = "Plafon"
	# --- Lis emas + tiang pintu bundar (dalam) ---
	add_child(Palette.box(Vector3(2.4, 0.12, 0.3), Vector3(0, 3.52, -294), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.08, 0.08, 2.5, Vector3(-1.06, 1.25, -294), Palette.EMAS, 0.4))
	add_child(Palette.cylinder(0.08, 0.08, 2.5, Vector3(1.06, 1.25, -294), Palette.EMAS, 0.4))
	# Label KELUAR di atas pintu (menghadap ke dalam ruangan).
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari LUAR ruangan/zona peta, lewat pintu) — sisi
	# belakang label lama terbaca cermin dari luar (temuan retest).
	var keluar := Palette.label3d("KELUAR", Vector3(0, 3.0, -293.8), 24, Color("#065f46"), false)
	keluar.name = "LabelKeluar"
	keluar.rotation_degrees = Vector3(0, 180, 0)
	keluar.double_sided = false
	add_child(keluar)
	var keluar_luar := Palette.label3d("KELUAR", Vector3(0, 3.0, -293.7), 24, Color("#065f46"), false)
	keluar_luar.name = "LabelKeluarBelakang"
	keluar_luar.double_sided = false
	add_child(keluar_luar)
	# --- Pilar sudut bundar ---
	for cx in [-8.88, 8.88]:
		for cz in [-307.88, -294.12]:
			add_child(Palette.cylinder(0.2, 0.22, 4.6, Vector3(cx, 2.3, cz), Palette.PUTIH))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): 4 pilar tanpa collision —
	# pemain tembus (probe baseline). Kotak terinskripsi 0,311
	# (r=0,22) h=4,6 mengikuti visual — fix3 anti-slip.
	for cx in [-8.88, 8.88]:
		for cz in [-307.88, -294.12]:
			var pil := StaticBody3D.new()
			pil.position = Vector3(cx, 2.3, cz)
			var pil_shape := CollisionShape3D.new()
			var pil_box := BoxShape3D.new()
			pil_box.size = Vector3(0.311, 4.6, 0.311)
			pil_shape.shape = pil_box
			pil.add_child(pil_shape)
			add_child(pil)
	# --- Lampu hangat (4) + gantungan ---
	for lx in [-4.5, 4.5]:
		for lz in [-297.5, -304.5]:
			_lampu_hangat(Vector3(lx, 0, lz))
	# --- Mihrab (relung imam) RONDE 10: kiblat 295° (barat-barat
	# laut), BUKAN utara lagi. Mas: "Arah kiblat tidak sesuai dg arah
	# matahari" — dari Indonesia kiblat ≈295°, matahari terbenam
	# 252° (RONDE 12, K_MATAHARI jam 18.0), jadi saat maghrib matahari
	# ada 43° di KIRI mihrab. Mihrab di dinding BARAT, menghadap 295°.
	# RONDE 14 (Mas: "Mihrab harusnya di tengah tembok. Bukan di
	# pojok."): dari (-8.4,-306.0) — dekat pojok utara — ke TENGAH
	# dinding barat (z=-301, sama dengan pusat ruangan + grid sajadah).
	# Rotasi lokal -270° (= -295° kiblat + 25° rotasi ruangan) supaya
	# di dunia mihrab menghadap 295° dan rata dengan dindingnya.
	var mihrab := Node3D.new()
	mihrab.name = "Mihrab"
	mihrab.position = Vector3(-8.4, 0, -301.0)
	mihrab.rotation.y = deg_to_rad(ROTASI_LOKAL_KIBLAT)
	add_child(mihrab)
	mihrab.add_child(Palette.box(Vector3(1.6, 2.4, 0.18), Vector3(0, 1.2, 0), Palette.ZAMRUD_GELAP))
	mihrab.add_child(Palette.box(Vector3(1.9, 0.14, 0.24), Vector3(0, 2.46, 0), Palette.EMAS, 0.4))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): mihrab tanpa collision —
	# pemain tembus (probe baseline). Kotak mengikuti visual
	# (1,6 x 2,4 x 0,18 -> 0,20 tebal); menonjol 0,56 m dari
	# dinding barat, jadi pemain yang menempel dinding tetap
	# tertahan mihrab.
	var mihrab_body := StaticBody3D.new()
	var mihrab_shape := CollisionShape3D.new()
	var mihrab_box := BoxShape3D.new()
	mihrab_box.size = Vector3(1.6, 2.4, 0.2)
	mihrab_shape.shape = mihrab_box
	mihrab_body.add_child(mihrab_shape)
	mihrab_body.position = Vector3(0, 1.2, 0)
	mihrab.add_child(mihrab_body)
	# --- Sajadah 3 baris x 5, menghadap kiblat 295° (WNW) ---
	# RONDE 14: pusat grid dipindah dari z=-301.8 ke z=-301.0 (pusat
	# ruangan = sumbu mihrab yang sudah di tengah dinding) dan rotasi
	# lokal dari -295° ke -270° — di dunia sajadah tetap menghadap 295°
	# tapi kini SEJAJAR dinding ruangan (tidak diagonal lagi terhadap
	# ruangan setelah ruangan diputar -25°).
	var sajadah := Node3D.new()
	sajadah.name = "Sajadah"
	sajadah.position = Vector3(0, 0, -301.0)
	sajadah.rotation.y = deg_to_rad(ROTASI_LOKAL_KIBLAT)
	add_child(sajadah)
	var n := 1
	for baris in range(3):
		for kolom in range(5):
			var sj := Palette.box(Vector3(0.65, 0.03, 1.15), Vector3(-4.8 + kolom * 2.4, 0.095, -2.0 + baris * 2.0), Palette.ZAMRUD)
			sj.name = "Sajadah_%02d" % n
			n += 1
			sajadah.add_child(sj)
	# RONDE DUDUK: sajadah Kyai di bawah kursinya (5.6,-305) — di luar
	# grid 3x5 (grid hanya x -4.8..4.8). Anak root langsung (bukan anak
	# node "Sajadah" yang berotasi) supaya koordinatnya sama persis
	# dengan kursi di main.gd.
	var sj_kyai := Palette.box(Vector3(0.65, 0.03, 1.15), Vector3(5.6, 0.095, -305.0), Palette.ZAMRUD)
	sj_kyai.name = "Sajadah_Kyai"
	sj_kyai.rotation.y = deg_to_rad(ROTASI_LOKAL_KIBLAT)
	add_child(sj_kyai)
	# --- SMARTBOARD di dinding barat ---
	_smartboard()
	# RONDE 5: papan dinding (papan tulis) DIHAPUS — cukup smartboard saja.
	# RONDE 6 (Mas: "Papan di dalam surau buang aja.. mengganggu"):
	# papan jadwal Ngaji Aja JUGA DIHAPUS dari dinding timur — jadwal
	# khataman sudah ada di dashboard Kartu Santri (ui.gd) + bisa
	# ditanyakan lewat smartboard. Di dalam Surau kini TIDAK ADA papan
	# sama sekali — yang tersisa: smartboard, mihrab, sajadah, rak
	# kitab, meja sampar, lampu hangat. (Label "KELUAR" di atas pintu
	# dipertahankan — itu teks penunjuk jalan, bukan papan.)
	# --- RAK KITAB x2: barat-selatan + timur-utara ---
	_rak_kitab(RAK_BARAT, "RakKitab_Barat")
	_rak_kitab(RAK_TIMUR, "RakKitab_Timur")
	# --- MEJA SAMPAR x3 ---
	_meja_sampar(Vector3(-6.5, 0, -298.5), "MejaSampar_1")
	_meja_sampar(Vector3(6.5, 0, -298.5), "MejaSampar_2")
	# RONDE DUDUK susulan (Mas 21:34 WIB, "Ini kok tembus meja?"):
	# MejaSampar_3 TADINYA di (6.5,-305.0) — 0,9 m dari kursi Kyai
	# (5.6,-305): papan oval (radius-x 1,1) + kaki baratnya MENEMBUS
	# sarung Kyai (radius 0,577). DIGESER tenggara ke (7.3,-303.5):
	# celah elips–lingkaran ~0,82 m (cek_tembus, lihat test_meja_kyai);
	# bebas rak timur (tepi 8,4 < 8,625) + grid sajadah (tepi timur 2,6).
	_meja_sampar(Vector3(7.3, 0, -303.5), "MejaSampar_3")
	# RONDE DUDUK: rehal (penyangga kitab) di depan kursi Kyai —
	# 0,55 m ke arah kiblat lokal (-X) dari kursinya, menghadap
	# pembaca; kitab terbuka di atasnya (kitab_pangku NPC kini
	# disembunyikan — kitabnya dibaca di rehal ini).
	_rehal(Vector3(5.05, 0, -305.0), "Rehal_Kyai")
	# RONDE 14 (Mas: "Putar Suraunya 25°"): ruangan diputar -25°
	# mengelilingi PINTU (0,0,-294) supaya dinding mihrab (barat)
	# menghadap kiblat 295°. Root diposisikan di P = pintu - R·pintu
	# lalu diputar — semua anak (dibangun di koordinat absolut) ikut
	# berputar mengelilingi pintu; pintu sendiri TETAP di (0,0,-294)
	# sehingga koridor keluar di main.gd tetap berlaku tanpa perubahan.
	# P = (-124.25, 0, -27.55) (diverifikasi numerik di test_ronde14).
	# (ROTASI_RUANGAN_DEG sendiri — revisi Surau lurus 17 Nov 22:51
	# WIB: interior tetap miring -25°.)
	var rot := deg_to_rad(ROTASI_RUANGAN_DEG)
	var c := cos(rot)
	var s := sin(rot)
	var rp := Vector3(PINTU_PIVOT.x * c + PINTU_PIVOT.z * s, 0, -PINTU_PIVOT.x * s + PINTU_PIVOT.z * c)
	position = PINTU_PIVOT - rp
	rotation.y = rot


## Kotak visual + collision (pola yang sama seperti builder).


## Kotak visual + collision (pola yang sama seperti builder).
func _static_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := Palette.box(size, pos, color)
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


## Lampu hangat gantung: OmniLight3D + gantungan kayu + kap emas +
## bola lampu kuning hangat (visual). RONDE 5: cahaya masuk grup
## "LampuCahaya" supaya LangitDinamis bisa menerangkannya di malam hari.
## RONDE 8: bola lampu punya COLLISION (seperti cangkruk) supaya
## SpringArm kamera mengerut sebelum kamera masuk ke dalam bola.
func _lampu_hangat(pos: Vector3) -> void:
	var grup := Node3D.new()
	grup.name = "Lampu_%d_%d" % [int(pos.x), int(pos.z)]
	grup.position = pos
	add_child(grup)
	var lampu := OmniLight3D.new()
	lampu.name = "Cahaya"
	lampu.position = Vector3(0, 3.9, 0)
	lampu.light_color = Color("#ffd9a0")
	lampu.light_energy = 0.7
	lampu.set_meta("energi_siang", 0.7)
	lampu.add_to_group("LampuCahaya")
	lampu.omni_range = 10.0
	lampu.shadow_enabled = false
	grup.add_child(lampu)
	grup.add_child(Palette.cylinder(0.03, 0.03, 0.5, Vector3(0, 4.35, 0), Palette.KAYU_GELAP))
	grup.add_child(Palette.cylinder(0.1, 0.1, 0.06, Vector3(0, 4.2, 0), Palette.EMAS, 0.4))
	grup.add_child(Palette.sphere(0.16, Vector3(0, 4.05, 0), Color("#ffe6b8")))
	var body := StaticBody3D.new()
	body.name = "LampuCollision"
	grup.add_child(body)
	var bentuk := CollisionShape3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.28
	bentuk.shape = bola
	bentuk.position = Vector3(0, 4.05, 0)
	body.add_child(bentuk)


## Smartboard: bingkai kayu + layar putih + 4 bola emas di sudut.
## RONDE 10 (Mas: "Tulisan di smartboard dihapus"): layar 3D kini
## BERSIH — Label3D SmartboardScreen dipertahankan (interface
## build() tetap mengembalikannya) tapi teksnya KOSONG, dan main.gd
## _on_slide_changed tidak lagi menulis ke papan. Konten pelajaran
## (Isim/Fi'il/Huruf) tetap tampil di POPUP UI saat smartboard
## dibuka — yang dihapus hanya tulisan di papan 3D-nya.
func _smartboard() -> void:
	# RONDE 14: pindah dari z=-301 ke z=-305.2 (ujung utara dinding
	# barat). Mihrab kini di TENGAH dinding (z=-301) — kalau smartboard
	# tetap di -301, mihrab menutupi layarnya. Posisi baru: papan
	# -307.5..-302.9, celah 1,1 m dari mihrab (-301.8) dan 0,4 m dari
	# dinding utara; rak kitab barat (-8.8,-296) tidak tersentuh.
	var sb := Node3D.new()
	sb.name = "Smartboard"
	add_child(sb)
	sb.add_child(Palette.box(Vector3(0.12, 2.4, 4.6), Vector3(-8.85, 2.0, -305.2), Palette.KAYU_GELAP))
	sb.add_child(Palette.box(Vector3(0.06, 2.2, 4.4), Vector3(-8.78, 2.0, -305.2), Palette.KOKO))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): smartboard tanpa collision.
	# Papan menempel dinding barat (muka -8,79 vs dinding -8,875:
	# hanya 0,085 menonjol) — kotak mengikuti bingkai (0,12 ->
	# 0,14 tebal) supaya pemain yang menempel dinding tidak
	# menembus layar. Titik interaksi SMARTBOARD_SPOT (-6,8,-301)
	# 2 m dari papan — tetap terjangkau.
	var sb_body := StaticBody3D.new()
	sb_body.position = Vector3(-8.85, 2.0, -305.2)
	var sb_shape := CollisionShape3D.new()
	var sb_box := BoxShape3D.new()
	sb_box.size = Vector3(0.14, 2.4, 4.6)
	sb_shape.shape = sb_box
	sb_body.add_child(sb_shape)
	sb.add_child(sb_body)
	for sy in [-1.2, 1.2]:
		for sz in [-2.3, 2.3]:
			sb.add_child(Palette.sphere(0.09, Vector3(-8.78, 2.0 + sy, -305.2 + sz), Palette.EMAS, 0.4))
	var layar := Palette.label3d("", Vector3(-8.72, 2.0, -305.2), 28, Color("#065f46"), false)
	layar.name = "SmartboardScreen"
	layar.rotation_degrees = Vector3(0, 90, 0)
	layar.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layar.width = 400.0
	sb.add_child(layar)
	_smartboard_screen = layar


## Rak kitab: 2 papan rak + 2 tiang + 5 kitab warna-warni.
## pos = pusat rak (menempel dinding, sumbu z sejajar dinding).
func _rak_kitab(pos: Vector3, nama: String) -> void:
	var rak := Node3D.new()
	rak.name = nama
	add_child(rak)
	rak.add_child(Palette.box(Vector3(0.35, 0.05, 1.8), Vector3(pos.x, 1.0, pos.z), Palette.KAYU))
	rak.add_child(Palette.box(Vector3(0.35, 0.05, 1.8), Vector3(pos.x, 1.5, pos.z), Palette.KAYU))
	rak.add_child(Palette.box(Vector3(0.35, 1.6, 0.05), Vector3(pos.x, 0.8, pos.z - 0.88), Palette.KAYU_GELAP))
	rak.add_child(Palette.box(Vector3(0.35, 1.6, 0.05), Vector3(pos.x, 0.8, pos.z + 0.88), Palette.KAYU_GELAP))
	var warna_rak := [Color("#b91c1c"), Color("#1d4ed8"), Color("#15803d"), Color("#b45309"), Color("#7e22ce")]
	for i in range(3):
		rak.add_child(Palette.box(Vector3(0.22, 0.35, 0.28), Vector3(pos.x, 1.20, pos.z - 0.6 + i * 0.35), warna_rak[i]))
	for i in range(2):
		rak.add_child(Palette.box(Vector3(0.22, 0.35, 0.28), Vector3(pos.x, 1.70, pos.z - 0.4 + i * 0.35), warna_rak[3 + i]))
	# TABRAKAN-DUNIA (Bagas, 18 Nov): rak tanpa collision — pemain
	# tembus (probe baseline). Kotak (0,4 x 1,9 x 1,85) mengikuti
	# badan rak (0,35 x 1,6-1,9 x 1,8); titik interaksi rak_spot
	# 3,0 m dari rak — tetap terjangkau dari depan rak.
	var rak_body := StaticBody3D.new()
	rak_body.position = Vector3(pos.x, 0.95, pos.z)
	var rak_shape := CollisionShape3D.new()
	var rak_box := BoxShape3D.new()
	rak_box.size = Vector3(0.4, 1.9, 1.85)
	rak_shape.shape = rak_box
	rak_body.add_child(rak_shape)
	rak.add_child(rak_body)


## Meja sampar: meja kayu rendah lesehan. Papan atas OVAL (silinder
## dipipih) supaya sudutnya membulat — bukan kotak. 4 kaki bundar
## pendek + 4 kitab warna-warni di atasnya.
func _meja_sampar(pos: Vector3, nama: String) -> void:
	var m := Node3D.new()
	m.name = nama
	m.position = pos
	add_child(m)
	var atas := Palette.cylinder(1.1, 1.1, 0.08, Vector3(0, 0.45, 0), Palette.KAYU)
	atas.scale = Vector3(1.0, 1.0, 0.55)
	m.add_child(atas)
	for sx in [-0.8, 0.8]:
		for sz in [-0.45, 0.45]:
			m.add_child(Palette.cylinder(0.05, 0.06, 0.45, Vector3(sx, 0.225, sz), Palette.KAYU_GELAP))
	var warna_kitab: Array[Color] = [Palette.EMAS, Palette.ZAMRUD, Color("#a33b3b"), Color("#3b5aa3")]
	for i in range(4):
		m.add_child(Palette.box(Vector3(0.35, 0.06, 0.25), Vector3(-0.6 + i * 0.4, 0.52 + (0.03 if i % 2 == 1 else 0.0), -0.15 + (0.2 if i % 2 == 0 else -0.1)), warna_kitab[i]))
	# TABRAKAN-DUNIA (Bagas, 18 Nov — Mas 21:34 WIB "Ini kok tembus
	# meja?"): meja tanpa collision. Kotak (1,5 x 0,5 x 0,8) DI
	# DALAM elips oval (2,2 x 1,21) di y 0..0,5 — mengikuti visual,
	# tidak lebih besar dari papan.
	var meja_body := StaticBody3D.new()
	meja_body.position = Vector3(0, 0.25, 0)
	var meja_shape := CollisionShape3D.new()
	var meja_box := BoxShape3D.new()
	meja_box.size = Vector3(1.5, 0.5, 0.8)
	meja_shape.shape = meja_box
	meja_body.add_child(meja_shape)
	m.add_child(meja_body)


## Rehal (RONDE DUDUK): penyangga kitab bentuk X — dua papan kayu
## jati bersilangan (miring ±28°, puncaknya bertemu di y≈0.36) +
## kitab TERBUKA di atasnya (sampul marun + dua halaman krem miring
## ±18°, punggung buku searah kiri-kanan pembaca). Node diputar
## ROTASI_LOKAL_KIBLAT supaya sumbu +Z-nya menghadap pembaca
## (kursi ada di +X lokal dari rehal).
func _rehal(pos: Vector3, nama: String) -> void:
	var r := Node3D.new()
	r.name = nama
	r.position = pos
	r.rotation.y = deg_to_rad(ROTASI_LOKAL_KIBLAT)
	add_child(r)
	var papan_a := Palette.box(Vector3(0.45, 0.38, 0.03), Vector3(0, 0.19, -0.09), Palette.KAYU)
	papan_a.rotation.x = deg_to_rad(28.0)
	r.add_child(papan_a)
	var papan_b := Palette.box(Vector3(0.45, 0.38, 0.03), Vector3(0, 0.19, 0.09), Palette.KAYU)
	papan_b.rotation.x = deg_to_rad(-28.0)
	r.add_child(papan_b)
	var sampul := Palette.box(Vector3(0.46, 0.015, 0.30), Vector3(0, 0.375, 0), Color("#7a1f1f"))
	r.add_child(sampul)
	var hal_jauh := Palette.box(Vector3(0.44, 0.02, 0.13), Vector3(0, 0.40, -0.075), Color("#f5f0e6"))
	hal_jauh.rotation.x = deg_to_rad(-18.0)
	r.add_child(hal_jauh)
	var hal_dekat := Palette.box(Vector3(0.44, 0.02, 0.13), Vector3(0, 0.40, 0.075), Color("#f5f0e6"))
	hal_dekat.rotation.x = deg_to_rad(18.0)
	r.add_child(hal_dekat)
	# TABRAKAN-DUNIA (Bagas, 18 Nov): rehal tanpa collision —
	# pemain tembus (probe baseline). Kotak (0,45 x 0,4 x 0,35)
	# mengikuti badan X + kitab (0,46 x 0,40 x 0,30); ikut rotasi
	# node rehal.
	var rehal_body := StaticBody3D.new()
	rehal_body.position = Vector3(0, 0.2, 0)
	var rehal_shape := CollisionShape3D.new()
	var rehal_box := BoxShape3D.new()
	rehal_box.size = Vector3(0.45, 0.4, 0.35)
	rehal_shape.shape = rehal_box
	rehal_body.add_child(rehal_shape)
	r.add_child(rehal_body)
