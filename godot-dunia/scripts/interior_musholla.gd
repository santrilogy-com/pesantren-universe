class_name InteriorMusholla
extends RefCounted
## Interior Musholla Ar-Raudhah (pesantren PUTRI) — ronde 20.
## Pola GTA seperti interior Surau (interior_surau.gd): ruangan
## terpisah di zona interior (x=60), 14x10 m, diputar -25 derajat
## mengelilingi PINTU, supaya mihrab + sajadah menghadap kiblat 295
## derajat (sama persis seperti Surau — perintah Mas ronde 10/12/14).
## KONTRADIKSI CATAT: brief + roadmap menulis mihrab "di dinding
## utara" — itu mengikuti prinsip LAMA yang sudah dikoreksi Mas
## (utara = 65 derajat meleset dari kiblat; barat = 25 derajat,
## sama seperti Surau). Maka mihrab di dinding BARAT.
##
## Pimpinan: Ustadzah Mariyah (duduk di KURSI_USTADZAH membaca kitab).
## Isi: 15 sajadah (3x5), mihrab sendiri, smartboard Misi M2 PUTRI
## (M2 putra tetap di Surau), 1 rak kitab, 1 meja sampar, 2 lampu
## hangat. Santri putra tidak pernah masuk ke sini (pagar + barrier).

const RUANG_PUSAT := Vector3(60, 0, -301)
const RUANG_LEBAR := 14.0 # x: 53..67
const RUANG_DALAM := 10.0 # z: -306..-296
const RUANG_TINGGI := 3.4
const ROTASI_DEG := -25.0 # sama seperti Surau (ROTASI_LOKAL_KIBLAT)
const PINTU := Vector3(60, 0, -296) # pintu selatan (tengah)
const SPAWN := Vector3(60, 0, -297.5) # tepat di depan pintu
const KIBLAT := Vector3(-0.9063, 0, -0.4226) # 295 derajat
const KIBLAT_YAW := -2.0071 # hadap 295 derajat (sama dgn Surau)
# RONDE 20 KOREKSI (bug rotasi): KELUAR/KE_DALAM/SUMBU dihitung
# dengan rotasi -25 derajat (bukan +25) — pintu keluar ruangan ke
# arah selatan-barat-daya; sumbu = sumbu panjang bangunan (115°).
const KELUAR := Vector3(-0.423, 0, 0.906) # pintu -> keluar ruangan
const KE_DALAM := Vector3(0.423, 0, -0.906) # pintu -> dalam ruangan
const SUMBU := Vector3(0.906, 0, 0.423) # sumbu pintu (sejajar dinding)
const KURSI_USTADZAH := Vector3(65.6, 0, -305.0) # cermin kursi Kyai (5.6,-305)


static func ke_dunia(pos_lokal: Vector3) -> Vector3:
	## Putar koordinat lokal mengelilingi PINTU (bukan pusat ruangan),
	## persis pola interior Surau (ruang 14x10 vs 18x14 Surau).
	## RONDE 20 KOREKSI (bug rotasi): sudut = ROTASI_DEG (-25°),
	## BUKAN -ROTASI_DEG (+25°). Dengan +25°, normal dinding barat
	## mengarah 245° (meleset 50° dari kiblat 295°); dengan -25°,
	## normal dinding barat = (-0.906, 0, -0.423) = azimuth 295°
	## persis seperti Surau (terverifikasi: mihrab + sajadah kiblat).
	var rel := pos_lokal - PINTU
	var sudut := deg_to_rad(ROTASI_DEG)
	var x := rel.x * cos(sudut) + rel.z * sin(sudut)
	var z := -rel.x * sin(sudut) + rel.z * cos(sudut)
	return Vector3(PINTU.x + x, pos_lokal.y, PINTU.z + z)


## Kebalikan ke_dunia (untuk tes: mihrab harus di dinding barat
## dalam koordinat LOKAL — posisi dunia-nya sudah diputar -25°).
static func ke_lokal(pos_dunia: Vector3) -> Vector3:
	var rel := pos_dunia - PINTU
	var sudut := deg_to_rad(-ROTASI_DEG)
	var x := rel.x * cos(sudut) + rel.z * sin(sudut)
	var z := -rel.x * sin(sudut) + rel.z * cos(sudut)
	return Vector3(PINTU.x + x, pos_dunia.y, PINTU.z + z)


static func arah_putar(dir_lokal: Vector3) -> Vector3:
	var sudut := deg_to_rad(ROTASI_DEG)
	var x := dir_lokal.x * cos(sudut) + dir_lokal.z * sin(sudut)
	var z := -dir_lokal.x * sin(sudut) + dir_lokal.z * cos(sudut)
	return Vector3(x, dir_lokal.y, z)


static func sajadah_grid() -> Array[Vector3]:
	## 15 sajadah (3 baris x 5 kolom), pusat (60,-301), searah dinding.
	var posisi: Array[Vector3] = []
	for baris in 3:
		for kolom in 5:
			posisi.append(Vector3(55.2 + float(kolom) * 2.4, 0, -303 + float(baris) * 2.0))
	return posisi


static func sajadah_03() -> Vector3:
	## Sajadah imam (baris depan tengah, kolom 3) — posisi imam
	## Ustadzah Mariyah = sajadah ini + kiblat x 1.5 m (pola
	## _posisi_imam() di main.gd untuk Kyai di Surau).
	return Vector3(60.0, 0, -303.0)


static func build() -> Dictionary:
	var root := Node3D.new()
	root.name = "InteriorMusholla"
	# Lantai: 14x10 m, kayu (sama seperti lantai Surau).
	var lantai := MeshInstance3D.new()
	lantai.name = "Lantai"
	var lantai_mesh := BoxMesh.new()
	lantai_mesh.size = Vector3(RUANG_LEBAR, 0.1, RUANG_DALAM)
	lantai.mesh = lantai_mesh
	lantai.material_override = Palette.mat(Palette.KAYU, 0.0, 0.45)
	lantai.position = ke_dunia(Vector3(RUANG_PUSAT.x, -0.05, RUANG_PUSAT.z))
	lantai.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(lantai)
	# Plafon + collision atas (pola Surau).
	var plafon := MeshInstance3D.new()
	plafon.name = "Plafon"
	var plafon_mesh := BoxMesh.new()
	plafon_mesh.size = Vector3(RUANG_LEBAR, 0.1, RUANG_DALAM)
	plafon.mesh = plafon_mesh
	plafon.material_override = Palette.mat(Palette.PUTIH, 0.0, 0.45)
	plafon.position = ke_dunia(Vector3(RUANG_PUSAT.x, RUANG_TINGGI, RUANG_PUSAT.z))
	plafon.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(plafon)
	var plafon_body := StaticBody3D.new()
	plafon_body.name = "PlafonBody"
	var plafon_col := CollisionShape3D.new()
	var plafon_box := BoxShape3D.new()
	plafon_box.size = Vector3(RUANG_LEBAR, 0.1, RUANG_DALAM)
	plafon_col.shape = plafon_box
	plafon_col.position = plafon.position
	plafon_col.rotation.y = deg_to_rad(ROTASI_DEG)
	plafon_body.add_child(plafon_col)
	root.add_child(plafon_body)
	# Dinding: 4 sisi, putih krem + trim zamrud di kaki dinding.
	# Dinding selatan BERLUBANG di tengah (pintu 2.4 m) — dua panel.
	_dinding(root, Vector3(0.2, RUANG_TINGGI, RUANG_DALAM), ke_dunia(Vector3(53, RUANG_TINGGI / 2.0, -301)), "DindingBarat") # x=53
	_dinding(root, Vector3(0.2, RUANG_TINGGI, RUANG_DALAM), ke_dunia(Vector3(67, RUANG_TINGGI / 2.0, -301)), "DindingTimur") # x=67
	_dinding(root, Vector3(RUANG_LEBAR, RUANG_TINGGI, 0.2), ke_dunia(Vector3(60, RUANG_TINGGI / 2.0, -306)), "DindingUtara")
	_dinding(root, Vector3(5.8, RUANG_TINGGI, 0.2), ke_dunia(Vector3(55.9, RUANG_TINGGI / 2.0, -296)), "DindingSelatanBarat")
	_dinding(root, Vector3(5.8, RUANG_TINGGI, 0.2), ke_dunia(Vector3(64.1, RUANG_TINGGI / 2.0, -296)), "DindingSelatanTimur")
	for dinding in root.find_children("Dinding*", "MeshInstance3D", true, false):
		(dinding as MeshInstance3D).material_override = Palette.mat(Palette.PUTIH, 0.0, 0.45)
	# Plafon trim: garis zamrud di bawah plafon (pola Surau, lebih pendek).
	var trim := MeshInstance3D.new()
	trim.name = "TrimPlafon"
	var trim_mesh := BoxMesh.new()
	trim_mesh.size = Vector3(RUANG_LEBAR, 0.15, RUANG_DALAM)
	trim.mesh = trim_mesh
	trim.material_override = Palette.mat(Palette.ZAMRUD, 0.0, 0.45)
	trim.position = ke_dunia(Vector3(60, RUANG_TINGGI - 0.075, -301))
	trim.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(trim)
	# MIHRAB (dinding BARAT, tengah) — ceruk + bingkai + tulisan,
	# cermin mihrab Surau (lebih kecil: 1.2 m, ruang 14x10).
	var mihrab := MeshInstance3D.new()
	mihrab.name = "Mihrab"
	var mihrab_mesh := BoxMesh.new()
	mihrab_mesh.size = Vector3(0.2, 2.6, 1.4)
	mihrab.mesh = mihrab_mesh
	mihrab.material_override = Palette.mat(Palette.EMAS, 0.0, 0.45)
	mihrab.position = ke_dunia(Vector3(53.15, 1.3, -301))
	mihrab.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(mihrab)
	var mihrab_label := _teks_3d("محراب", Palette.ZAMRUD, 28)
	mihrab_label.name = "LabelMihrab"
	mihrab_label.position = ke_dunia(Vector3(53.3, 2.9, -301))
	mihrab_label.rotation.y = deg_to_rad(ROTASI_DEG) + PI / 2.0
	root.add_child(mihrab_label)
	# SAJADAH 3x5 — hijau pola bata (pola Surau).
	var sajadah_list: Array[MeshInstance3D] = []
	for i in sajadah_grid().size():
		var s := MeshInstance3D.new()
		s.name = "Sajadah_%02d" % (i + 1)
		var s_mesh := BoxMesh.new()
		s_mesh.size = Vector3(0.65, 0.04, 1.15)
		s.mesh = s_mesh
		s.material_override = Palette.mat(Palette.ZAMRUD, 0.0, 0.45)
		s.position = ke_dunia(sajadah_grid()[i])
		s.rotation.y = KIBLAT_YAW
		root.add_child(s)
		sajadah_list.append(s)
	# RONDE DUDUK: sajadah Ustadzah di bawah kursinya (65.6,-305) —
	# di luar grid 3x5 (grid hanya x 55.2..64.8, z -303..-299).
	# Koordinat lokal → dunia via ke_dunia, sama seperti grid.
	var sj_ustadzah := MeshInstance3D.new()
	sj_ustadzah.name = "Sajadah_Ustadzah"
	var sj_u_mesh := BoxMesh.new()
	sj_u_mesh.size = Vector3(0.65, 0.04, 1.15)
	sj_ustadzah.mesh = sj_u_mesh
	sj_ustadzah.material_override = Palette.mat(Palette.ZAMRUD, 0.0, 0.45)
	sj_ustadzah.position = ke_dunia(Vector3(65.6, 0.095, -305.0))
	sj_ustadzah.rotation.y = KIBLAT_YAW
	root.add_child(sj_ustadzah)
	# (Surau 4.6 m; ruang ini lebih sempit, papan diperpendek
	# supaya tidak menabrak mihrab). Konten: Misi M2 (putri).
	var board := MeshInstance3D.new()
	board.name = "Smartboard"
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(0.08, 1.7, 3.0)
	board.mesh = board_mesh
	board.material_override = Palette.mat(Color(0.85, 0.9, 0.92), 0.0, 0.45)
	board.position = ke_dunia(Vector3(53.2, 1.8, -304))
	board.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(board)
	var board_stand := MeshInstance3D.new()
	board_stand.name = "SmartboardStand"
	var stand_mesh := BoxMesh.new()
	stand_mesh.size = Vector3(0.1, 0.9, 3.0)
	board_stand.mesh = stand_mesh
	board_stand.material_override = Palette.mat(Palette.KAYU_GELAP, 0.0, 0.45)
	board_stand.position = ke_dunia(Vector3(53.2, 0.45, -304))
	board_stand.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(board_stand)
	# RAK KITAB (1) — dinding timur utara, isi kitab Jurumiyah dkk.
	# (Fase 2: rak interaktif — buka kitab tampil isinya.)
	var rak := MeshInstance3D.new()
	rak.name = "RakKitab"
	var rak_mesh := BoxMesh.new()
	rak_mesh.size = Vector3(0.35, 2.0, 1.6)
	rak.mesh = rak_mesh
	rak.material_override = Palette.mat(Palette.KAYU, 0.0, 0.45)
	rak.position = ke_dunia(Vector3(66.8, 1.0, -304.5))
	rak.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(rak)
	for k in 3:
		var buku := MeshInstance3D.new()
		buku.name = "Kitab_%d" % (k + 1)
		var buku_mesh := BoxMesh.new()
		buku_mesh.size = Vector3(0.25, 0.28, 0.12)
		buku.mesh = buku_mesh
		buku.material_override = Palette.mat([Palette.ZAMRUD, Color("#1d4e6b"), Color("#c96a1e")][k], 0.0, 0.45)
		buku.position = ke_dunia(Vector3(66.7, 0.55 + float(k) * 0.4, -305.0 + float(k) * 0.5))
		buku.rotation.y = deg_to_rad(ROTASI_DEG)
		root.add_child(buku)
	# MEJA SAMPAR (1) — tenggara, tempat kitab Ustadzah Mariyah.
	var meja := MeshInstance3D.new()
	meja.name = "MejaSampar"
	var meja_mesh := BoxMesh.new()
	meja_mesh.size = Vector3(1.2, 0.1, 0.7)
	meja.mesh = meja_mesh
	meja.material_override = Palette.mat(Palette.KAYU, 0.0, 0.45)
	meja.position = ke_dunia(Vector3(64.5, 0.45, -297.5))
	meja.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(meja)
	for k in 2:
		var kaki := MeshInstance3D.new()
		kaki.name = "MejaKaki_%d" % k
		var kaki_mesh := BoxMesh.new()
		kaki_mesh.size = Vector3(0.08, 0.45, 0.08)
		kaki.mesh = kaki_mesh
		kaki.material_override = Palette.mat(Palette.KAYU_GELAP, 0.0, 0.45)
		kaki.position = ke_dunia(Vector3(64.0 + float(k) * 1.0, 0.22, -297.5))
		kaki.rotation.y = deg_to_rad(ROTASI_DEG)
		root.add_child(kaki)
	# RONDE DUDUK: rehal (penyangga kitab) di depan kursi Ustadzah —
	# 0,55 m ke arah kiblat lokal (-X) dari kursinya, menghadap
	# pembaca; kitab terbuka di atasnya (kitab_pangku NPC kini
	# disembunyikan — kitabnya dibaca di rehal ini).
	_rehal(root, Vector3(65.05, 0, -305.0), "Rehal_Ustadzah")
	# LAMPU HANGAT (2) — gantung di langit-langit, cahaya kuning.
	for i in 2:
		var pos_lampu := Vector3(56.5 if i == 0 else 63.5, 3.1, -298.5 if i == 0 else -303.5)
		var bola := MeshInstance3D.new()
		bola.name = "Lampu_%d" % (i + 1)
		var bola_mesh := SphereMesh.new()
		bola_mesh.radius = 0.12
		bola_mesh.height = 0.24
		bola.mesh = bola_mesh
		bola.material_override = Palette.mat(Color("#ffd9a0"), 0.0, 0.45)
		bola.position = ke_dunia(pos_lampu)
		root.add_child(bola)
		var lampu := OmniLight3D.new()
		lampu.name = "LampuOmni_%d" % (i + 1)
		lampu.light_color = Color("#ffd9a0")
		lampu.light_energy = 0.9
		lampu.omni_range = 6.0
		lampu.position = ke_dunia(pos_lampu)
		root.add_child(lampu)
	# LABEL "KELUAR" di atas pintu (pola Surau).
	# RONDE PERBAIKAN (Fajar): double_sided=false + label belakang
	# (terbaca benar dari LUAR ruangan, lewat pintu) — sisi belakang
	# label lama terbaca cermin dari luar (temuan retest Ronde 23).
	var keluar_label := _teks_3d("KELUAR", Palette.EMAS, 28)
	keluar_label.name = "LabelKeluar"
	keluar_label.position = ke_dunia(Vector3(60, 2.6, -295.8))
	keluar_label.rotation.y = deg_to_rad(ROTASI_DEG) + PI
	keluar_label.double_sided = false
	root.add_child(keluar_label)
	var keluar_luar := _teks_3d("KELUAR", Palette.EMAS, 28)
	keluar_luar.name = "LabelKeluarBelakang"
	keluar_luar.position = ke_dunia(Vector3(60, 2.6, -295.7))
	keluar_luar.rotation.y = deg_to_rad(ROTASI_DEG)
	keluar_luar.double_sided = false
	root.add_child(keluar_luar)
	# PILAR sudut (4) — penyangga, pola Surau.
	for p in [Vector3(53.6, 1.7, -305.4), Vector3(66.4, 1.7, -305.4), Vector3(53.6, 1.7, -296.6), Vector3(66.4, 1.7, -296.6)]:
		var pilar := MeshInstance3D.new()
		pilar.name = "Pilar"
		var pilar_mesh := CylinderMesh.new()
		pilar_mesh.top_radius = 0.22
		pilar_mesh.bottom_radius = 0.26
		pilar_mesh.height = 3.4
		pilar.mesh = pilar_mesh
		pilar.material_override = Palette.mat(Palette.PUTIH, 0.0, 0.45)
		pilar.position = ke_dunia(p)
		root.add_child(pilar)
	return {
		"root": root,
		"interior_door": ke_dunia(PINTU),
		"interior_spawn": ke_dunia(SPAWN),
		"kursi_ustadzah": ke_dunia(KURSI_USTADZAH),
		"mihrab": ke_dunia(Vector3(53.15, 1.3, -301)),
		"sajadah_03": ke_dunia(sajadah_03()),
		"smartboard": board,
		"bounds": Rect2(Vector2(53, -306), Vector2(14, 10)),
	}


static func _dinding(root: Node3D, ukuran: Vector3, pos: Vector3, nama: String) -> void:
	## Dinding visual + collision (pola interior Surau).
	var mesh := MeshInstance3D.new()
	mesh.name = nama
	var box := BoxMesh.new()
	box.size = ukuran
	mesh.mesh = box
	mesh.position = pos
	mesh.rotation.y = deg_to_rad(ROTASI_DEG)
	root.add_child(mesh)
	var body := StaticBody3D.new()
	body.name = nama + "Body"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = ukuran
	col.shape = shape
	col.position = pos
	col.rotation.y = deg_to_rad(ROTASI_DEG)
	body.add_child(col)
	root.add_child(body)


static func _teks_3d(teks: String, warna: Color, ukuran_font: int) -> Label3D:
	var label := Label3D.new()
	label.text = teks
	label.font_size = ukuran_font
	label.modulate = warna
	label.outline_size = 8
	label.outline_modulate = Color(0.06, 0.1, 0.08, 0.85)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = false
	return label


## Rehal (RONDE DUDUK): penyangga kitab bentuk X — dua papan kayu
## jati bersilangan (miring ±28°) + kitab TERBUKA di atasnya (sampul
## marun + dua halaman krem miring ±18°). Posisi diberikan LOKAL
## (seperti kursi) lalu diubah ke dunia via ke_dunia; putaran
## KIBLAT_YAW + PI supaya sumbu +Z-nya menghadap pembaca.
static func _rehal(root: Node3D, pos_lokal: Vector3, nama: String) -> void:
	var r := Node3D.new()
	r.name = nama
	r.position = ke_dunia(pos_lokal)
	r.rotation.y = KIBLAT_YAW + PI
	root.add_child(r)
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
