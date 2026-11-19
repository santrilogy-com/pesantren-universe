extends Node
## Tes 20 NPC sistem baru (Raka, 19 Nov 2026 — desain Laras
## v2/konsep/DESAIN-SISTEM-NPC-v1.md, ACC Mas 14:10).
## Fase 0 statis (spawn/nama/zona/wajah/peci/guru group) | Fase 1 live
## patroli+aktivitas (time_scale 15, ~60 dtk nyata: tembusan Fase D,
## aktivitas terlihat, registry kursi, cap 4/gedung) | Fase 2 hormat
## A/B (guru diteleport ke dekat NPC) | Fase 3 sholat (paksa
## _mulai_sholat jam sekarang: sajadah unik per gender + interior
## benar + semua sampai).
## Jalankan headless (HOME terisolasi — jangan pakai save VM):
##   HOME=/tmp/iso-npc20 godot --headless --path . --scene res://skrip/test_npc_20.tscn
## Pola test_npc_tembus.gd: load main.tscn + _masuk_pesantren.
## JANGAN ubah kode game — skrip tes saja.

var _lulus := 0
var _gagal := 0
var _main: Node
var _baru: Array = []
var _tahap := 0
var _t_fase_mulai := 0
var _aktivitas_terlihat := {}
var _gedung_terlihat := {}
var _tembus_d := 0
var _sisi_d := 0
var _kursi_ganda := 0
var _f2_npc_a: Node = null
var _f2_npc_b: Node = null
var _f2_guru_a: Node = null
var _f2_guru_b: Node = null
var _f2_pos_guru_a := Vector3.ZERO
var _f2_pos_guru_b := Vector3.ZERO
var _f2_varian_a := ""
var _f2_varian_b := ""
var _f2_jeda_b := false
var _f2_paksa_terakhir := 0
var _f2_coba_a := 0
var _f2_aktivitas_a := ""
var _f3_sampai_maks := 0

const CANGKANG := {
	"Surau": [Vector2(-8, -24), Vector2(8, -4)],
	"Cangkruk": [Vector2(-27, -22), Vector2(-17, -14)],
	"AsramaPutra": [Vector2(-33.25, 4), Vector2(-14.75, 16)],
	"Musholla": [Vector2(128, -29), Vector2(140, -19)],
	"AsramaPutri": [Vector2(146, 3), Vector2(164, 15)],
}
const NAMA_LARANG := ["Bilal", "Faris", "Sanusi", "Aqsal", "Mariyah", "Fatimah", "Yusuf", "Atul", "Mamad", "rehan", "Salsa"]


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _di_dalam_tapak(p: Vector3) -> String:
	for nama in CANGKANG:
		var r: Array = CANGKANG[nama]
		if p.x >= r[0].x and p.x <= r[1].x and p.z >= r[0].y and p.z <= r[1].y:
			return nama
	return ""


func _mat_albedo(node: Node, nama_node: String) -> Color:
	var m := node.find_child(nama_node, true, false) as MeshInstance3D
	if m == null:
		return Color.TRANSPARENT
	var mat := m.material_override as StandardMaterial3D
	if mat == null:
		return Color.TRANSPARENT
	return mat.albedo_color


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes NPC 20")
	for i in 5:
		await get_tree().process_frame

	# ---------- FASE 0: statis ----------
	print("NPC20: === FASE 0 statis ===")
	var semua: Array = _main._npcs
	_cek("total NPC di _npcs = 26 (6 lama + 20 baru)", semua.size() == 26)
	for npc in semua:
		if bool(npc.get("_aktivitas_aktif")):
			_baru.append(npc)
	_cek("NPC baru (_aktivitas_aktif) = 20", _baru.size() == 20)
	var putra := 0
	var putri := 0
	var nama_set := {}
	var peci_bulat := 0
	var peci_nasional := 0
	var kacamata_ya := 0
	var kacamata_tidak := 0
	var tinggi_set := {}
	var kulit_set := {}
	var mesh_total := 0
	for npc in _baru:
		if bool(npc.adalah_putri()):
			putri += 1
		else:
			putra += 1
		var nama: String = npc._nama
		_cek("nama %s tidak kembar" % nama, not nama_set.has(nama))
		nama_set[nama] = true
		_cek("nama %s bukan nama larangan" % nama, not NAMA_LARANG.has(nama))
		# Peci: bulat = SphereMesh, nasional = CylinderMesh.
		var peci := npc.find_child("Peci", true, false) as MeshInstance3D
		if peci != null and peci.mesh is SphereMesh:
			peci_bulat += 1
		elif peci != null and peci.mesh is CylinderMesh:
			peci_nasional += 1
		var kc := npc.find_child("Kacamata", true, false) as Node3D
		if kc != null and kc.visible:
			kacamata_ya += 1
		else:
			kacamata_tidak += 1
		tinggi_set[snappedf(npc._visual.scale.y, 0.01)] = true
		kulit_set[_mat_albedo(npc, "Kepala").to_html()] = true
		# Zona: putra x<14, putri x>115; spawn + waypoint di luar tapak.
		var p: Vector3 = npc.global_position
		var sisi_ok := (p.x < 14.0) if not bool(npc.adalah_putri()) else (p.x > 115.0)
		_cek("spawn %s di sisi benar (%.1f,%.1f)" % [nama, p.x, p.z], sisi_ok)
		_cek("spawn %s di luar tapak" % nama, _di_dalam_tapak(p) == "")
		var wp_ok := true
		for w in npc._waypoints:
			if _di_dalam_tapak(w) != "":
				wp_ok = false
			var ws_ok: bool = (w.x < 14.0) if not bool(npc.adalah_putri()) else (w.x > 115.0)
			if not ws_ok:
				wp_ok = false
		_cek("waypoint %s semua di sisi benar + luar tapak" % nama, wp_ok)
		# Performa: jumlah MeshInstance3D per NPC (proxy tris).
		var meshes := 0
		var stack: Array[Node] = [npc._visual]
		while not stack.is_empty():
			var n: Node = stack.pop_back()
			if n is MeshInstance3D:
				meshes += 1
			for c in n.get_children():
				stack.append(c)
		mesh_total += meshes
	_cek("putra baru = 10", putra == 10)
	_cek("putri baru = 10", putri == 10)
	_cek("peci putra campur (bulat %d + nasional %d)" % [peci_bulat, peci_nasional], peci_bulat > 0 and peci_nasional > 0)
	_cek("kacamata bervariasi (pakai %d, tidak %d)" % [kacamata_ya, kacamata_tidak], kacamata_ya > 0 and kacamata_tidak > 0)
	_cek("tinggi bervariasi (>=3 dari 4 langkah: %d)" % tinggi_set.size(), tinggi_set.size() >= 3)
	_cek("kulit bervariasi (>=3 dari 6 tone: %d)" % kulit_set.size(), kulit_set.size() >= 3)
	print("NPC20: mesh per NPC rata-rata %.1f (total %d utk 20 NPC)" % [float(mesh_total) / 20.0, mesh_total])
	# Group guru_hormat: Kyai + Mariyah + Sanusi + Fatimah.
	var guru := get_tree().get_nodes_in_group("guru_hormat")
	var guru_nama: Array[String] = []
	for g in guru:
		guru_nama.append(String(g._nama))
	_cek("group guru_hormat = 4", guru.size() == 4)
	_cek("guru_hormat berisi Kyai+Mariyah+Sanusi+Fatimah", guru_nama.has("Ust. Aqsal Murad") and guru_nama.has("Ustadzah Mariyah") and guru_nama.has("Ust. Sanusi") and guru_nama.has("Ustzh. Fatimah"))
	print("NPC20: fase 0 selesai: %d lulus, %d gagal" % [_lulus, _gagal])

	# ---------- FASE 1: live patroli + aktivitas ----------
	print("NPC20: === FASE 1 live (60 dtk nyata, time_scale 15) ===")
	Engine.time_scale = 15.0
	_t_fase_mulai = Time.get_ticks_msec()
	_tahap = 1


func _process(_delta: float) -> void:
	if _tahap == 1:
		# Sample tiap frame: tembusan outdoor + sisi + registry kursi.
		for npc in _baru:
			var p: Vector3 = npc.global_position
			if p.z > -100.0:
				if _di_dalam_tapak(p) != "":
					_tembus_d += 1
					if _tembus_d <= 5:
						print("NPC20: TEMBUS-D %s di (%.1f,%.1f) tapak %s" % [npc._nama, p.x, p.z, _di_dalam_tapak(p)])
				var sisi_ok := (p.x < 14.0) if not bool(npc.adalah_putri()) else (p.x > 115.0)
				if not sisi_ok:
					_sisi_d += 1
					if _sisi_d <= 5:
						print("NPC20: SISI %s di (%.1f,%.1f) — menyeberang!" % [npc._nama, p.x, p.z])
			var a: String = npc._aktivitas
			if a != "":
				_aktivitas_terlihat[a] = true
			var k: Dictionary = npc._aktivitas_kursi
			if not k.is_empty():
				var g: String = String(k.get("gedung", "?"))
				_gedung_terlihat[g] = true
		# Kursi ganda: dua NPC klaim id yang sama di frame ini.
		var klaim := {}
		var per_gedung := {}
		for npc in _baru:
			var k2: Dictionary = npc._aktivitas_kursi
			if k2.is_empty():
				continue
			var id2: String = String(k2.get("id", "?"))
			if klaim.has(id2):
				_kursi_ganda += 1
			klaim[id2] = true
			var g2: String = String(k2.get("gedung", "?"))
			per_gedung[g2] = int(per_gedung.get(g2, 0)) + 1
		for g3 in per_gedung:
			if int(per_gedung[g3]) > 4:
				_kursi_ganda += 1
				print("NPC20: GEDUNG %s dipakai %d NPC (>4)!" % [g3, int(per_gedung[g3])])
		if Time.get_ticks_msec() - _t_fase_mulai >= 60000:
			Engine.time_scale = 1.0
			_cek("Fase D live: tembusan outdoor = 0 (ditemukan %d)" % _tembus_d, _tembus_d == 0)
			_cek("Fase D live: NPC tidak menyeberang sisi (ditemukan %d)" % _sisi_d, _sisi_d == 0)
			_cek("registry kursi: tidak ada klaim ganda / gedung >4 (ditemukan %d)" % _kursi_ganda, _kursi_ganda == 0)
			_cek("aktivitas DUDUK_KURSI terlihat (duduk)", _aktivitas_terlihat.has("duduk"))
			_cek("aktivitas JALAN_KITAB terlihat", _aktivitas_terlihat.has("jalan_kitab"))
			_cek("aktivitas BACA_KAMAR terlihat (ke_kamar/baca_kamar)", _aktivitas_terlihat.has("ke_kamar") or _aktivitas_terlihat.has("baca_kamar"))
			_cek("aktivitas BACA_MUSHOLLA terlihat (gedung serambi/teras)", _gedung_terlihat.has("serambi_surau") or _gedung_terlihat.has("teras_musholla"))
			print("NPC20: aktivitas terlihat: %s | gedung kursi: %s" % [str(_aktivitas_terlihat.keys()), str(_gedung_terlihat.keys())])
			print("NPC20: fase 1 selesai: %d lulus, %d gagal" % [_lulus, _gagal])
			# ---------- FASE 2: hormat A + B ----------
			print("NPC20: === FASE 2 hormat A/B ===")
			_t_fase_mulai = Time.get_ticks_msec()
			_tahap = 2
		return
	if _tahap == 2:
		# Varian A: NPC putra yang sedang JALAN (jauh dari targetnya
		# >3 m — tidak akan sampai waypoint + duduk dalam 1-2 frame
		# ke depan) + guru Sanusi di dekatnya. Catat _hormat PERTAMA
		# apa pun + _aktivitas saat itu; "a" = lolos. Bila "b" yang
		# muncul (NPC keburu duduk di antara pilih dan picu), coba
		# NPC lain (maks 3 percobaan).
		if _f2_npc_a == null and _f2_coba_a < 3:
			for npc in _baru:
				if not bool(npc.adalah_putri()) and String(npc._aktivitas) == "" and String(npc._hormat) == "" and npc.global_position.distance_to(npc._target) > 3.0:
					_f2_npc_a = npc
					_f2_guru_a = _main._sanusi
					_f2_pos_guru_a = _f2_guru_a.global_position
					_f2_guru_a.global_position = npc.global_position + Vector3(1.5, 0, 0)
					_f2_coba_a += 1
					print("NPC20: hormat A #%d: Sanusi diteleport ke %s (%.1f,%.1f)" % [_f2_coba_a, npc._nama, npc.global_position.x, npc.global_position.z])
					break
		elif _f2_npc_a != null and _f2_varian_a == "":
			var h: String = String(_f2_npc_a._hormat)
			if h != "":
				_f2_varian_a = h
				_f2_aktivitas_a = String(_f2_npc_a._aktivitas)
				print("NPC20: hormat A terpicu: %s -> %s (aktivitas saat itu: '%s')" % [_f2_npc_a._nama, h, _f2_aktivitas_a])
				_f2_guru_a.global_position = _f2_pos_guru_a
				if not h.begins_with("a"):
					# Bukan varian A — NPC keburu duduk; coba lagi.
					_f2_npc_a = null
					_f2_varian_a = ""
		# Varian B: NPC putri yang sedang DUDUK + guru Fatimah di dekatnya.
		if _f2_npc_b == null:
			for npc in _baru:
				if bool(npc.adalah_putri()) and String(npc._aktivitas) in ["duduk", "baca_kamar"] and String(npc._hormat) == "":
					_f2_npc_b = npc
					_f2_guru_b = _main._fatimah
					_f2_pos_guru_b = _f2_guru_b.global_position
					_f2_guru_b.global_position = npc.global_position + Vector3(1.5, 0, 0)
					print("NPC20: hormat B: Fatimah diteleport ke %s (%.1f,%.1f)" % [npc._nama, npc.global_position.x, npc.global_position.z])
					break
			# Tidak ada yang duduk saat ini — paksa satu putri duduk.
			# _f2_paksa_terakhir (bukan _t_fase_mulai!) supaya timeout
			# 60 dtk fase 2 tidak bisa ditunda selamanya.
			if _f2_npc_b == null and Time.get_ticks_msec() - _f2_paksa_terakhir > 20000:
				for npc in _baru:
					if bool(npc.adalah_putri()) and String(npc._aktivitas) == "" and String(npc._hormat) == "":
						npc._mulai_duduk_kursi()
						print("NPC20: hormat B: paksa %s duduk kursi dulu" % npc._nama)
						break
				_f2_paksa_terakhir = Time.get_ticks_msec()
		elif _f2_varian_b == "":
			var h2: String = String(_f2_npc_b._hormat)
			if h2.begins_with("b"):
				_f2_varian_b = h2
				_f2_jeda_b = float(_f2_guru_b._jeda_sampai) > Time.get_ticks_msec() / 1000.0
				print("NPC20: hormat B terpicu: %s -> %s (guru jeda=%s)" % [_f2_npc_b._nama, h2, str(_f2_jeda_b)])
				_f2_guru_b.global_position = _f2_pos_guru_b
		if _f2_varian_a != "" and _f2_varian_b != "":
			_cek("hormat varian A (jalan -> minggir/tunduk)", _f2_varian_a.begins_with("a"))
			_cek("hormat varian B (duduk -> hampiri/salaman)", _f2_varian_b.begins_with("b"))
			_cek("hormat B: guru berhenti (jeda_patroli 4 dtk)", _f2_jeda_b)
			print("NPC20: fase 2 selesai: %d lulus, %d gagal" % [_lulus, _gagal])
			_mulai_fase_3()
		elif Time.get_ticks_msec() - _t_fase_mulai > 60000:
			# Timeout fase 2 — laporkan apa adanya, lanjut fase 3.
			_cek("hormat varian A terpicu (timeout 60 dtk)", _f2_varian_a != "")
			_cek("hormat varian B terpicu (timeout 60 dtk)", _f2_varian_b != "")
			if _f2_guru_a != null:
				_f2_guru_a.global_position = _f2_pos_guru_a
			if _f2_guru_b != null:
				_f2_guru_b.global_position = _f2_pos_guru_b
			print("NPC20: fase 2 TIMEOUT: A=%s B=%s" % [_f2_varian_a, _f2_varian_b])
			_mulai_fase_3()
		return
	if _tahap == 3:
		# Peak: jumlah NPC baru di fase "sholat" terbanyak yang
		# pernah terlihat — sesi berakhir sendiri ~30 dtk game
		# (timeout kumpul 25 dtk + takbir + gelap), jadi cek di
		# akhir saja akan selalu 0.
		var sampai_skrg := 0
		for npc in _baru:
			if String(_main._npc_sholat_fase.get(npc, "")) == "sholat":
				sampai_skrg += 1
		_f3_sampai_maks = maxi(_f3_sampai_maks, sampai_skrg)
		if Time.get_ticks_msec() - _t_fase_mulai >= 8000:
			Engine.time_scale = 1.0
			var sajadah: Dictionary = _main._sajadah_npc
			var punya := 0
			var posisi: Array[Vector3] = []
			var interior_ok := true
			var surau_tengah: Vector3 = _main._posisi_sajadah("Sajadah_03")
			var musholla_tengah: Vector3 = _main._posisi_sajadah_musholla("Sajadah_03")
			for npc in _baru:
				if sajadah.has(npc):
					punya += 1
					var sp: Vector3 = sajadah[npc]
					posisi.append(sp)
					var tengah: Vector3 = musholla_tengah if bool(npc.adalah_putri()) else surau_tengah
					# Grid sajadah 3x5: sudut ~6,25 m dari tengah.
					if sp.distance_to(tengah) > 7.0:
						interior_ok = false
						print("NPC20: SAJADAH SALAH %s di %s (tengah %s)" % [npc._nama, str(sp), str(tengah)])
			_cek("sholat: 20 NPC baru semua dapat sajadah (%d)" % punya, punya == 20)
			var unik := true
			for i in range(posisi.size()):
				for j in range(i + 1, posisi.size()):
					if posisi[i].distance_to(posisi[j]) < 0.5:
						unik = false
						print("NPC20: SAJADAH GANDA di %s" % str(posisi[i]))
			_cek("sholat: sajadah unik (tidak ada 2 NPC 1 sajadah)", unik)
			_cek("sholat: sajadah di interior benar (putra Surau / putri Musholla)", interior_ok)
			_cek("sholat: 20 NPC baru sampai di sajadah (peak %d/20)" % _f3_sampai_maks, _f3_sampai_maks == 20)
			print("NPC20: fase 3 selesai: %d lulus, %d gagal" % [_lulus, _gagal])
			print("TES NPC 20: %d lulus, %d gagal" % [_lulus, _gagal])
			get_tree().quit(0 if _gagal == 0 else 1)
		return


func _mulai_fase_3() -> void:
	# ---------- FASE 3: sholat ----------
	print("NPC20: === FASE 3 sholat ===")
	# Cek statis dulu: rute ke pintu dari spawn tiap NPC (tanpa
	# jalan) — titik rute + titik tengah segmen di luar tapak dan
	# di sisi benar. Ini menutup jalan panjang yang tidak sempat
	# ditempuh dalam timeout kumpul 25 dtk game.
	var rute_ok := true
	for npc in _baru:
		var dari: Vector3 = npc._waypoints[0]
		var rute: Array = _main._rute_ke_pintu_musholla(dari) if bool(npc.adalah_putri()) else _main._rute_ke_pintu_surau(dari)
		var titik: Array[Vector3] = [dari]
		for p in rute:
			titik.append(p)
		for i in range(titik.size() - 1):
			var tengah := (titik[i] + titik[i + 1]) * 0.5
			for t in [titik[i], tengah]:
				if _di_dalam_tapak(t) != "":
					rute_ok = false
					print("NPC20: RUTE-SHOLAT %s menabrak tapak %s di %s" % [npc._nama, _di_dalam_tapak(t), str(t)])
				var s_ok: bool = (t.x < 14.0) if not bool(npc.adalah_putri()) else (t.x > 115.0)
				if not s_ok:
					rute_ok = false
					print("NPC20: RUTE-SHOLAT %s menyeberang sisi di %s" % [npc._nama, str(t)])
	_cek("sholat: rute ke pintu dari spawn bersih (tapak + sisi)", rute_ok)
	# Teleport 20 NPC ke dekat pintu (putra: plaza Surau (0,2);
	# putri: selatan Musholla (134,-14)) — supaya semua sempat
	# sampai sajadah dalam timeout kumpul 25 dtk game (jalan
	# panjangnya sudah dibuktikan cek statis di atas + Fase 1).
	# Tanpa ini sesi berakhir sendiri sebelum NPC terjauh sampai
	# (P4 ~60 m = 38 dtk game > 25 dtk timeout — by design game).
	var i := 0
	for npc in _baru:
		var dekat: Vector3 = Vector3(134 + float(i % 5 - 2) * 1.5, 0, -14 + float(i / 5) * 1.5) if bool(npc.adalah_putri()) else Vector3(float(i % 5 - 2) * 1.5, 0, 2 + float(i / 5) * 1.5)
		npc.global_position = dekat
		i += 1
	var jam_skrg := Time.get_time_string_from_system().substr(0, 5)
	_main._mulai_sholat({"nama": "Dzuhur", "jam": jam_skrg, "durasi_menit": 1})
	Engine.time_scale = 15.0
	_f3_sampai_maks = 0
	_t_fase_mulai = Time.get_ticks_msec()
	_tahap = 3
