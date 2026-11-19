extends Node
## Repro: Kyai muncul dari tembok (Raka, 19 Nov 2026).
## Laporan Mas 12:51 WIB: "kyai tiba-tiba muncul dari tembok".
## Simulasi sesi Dzuhur yang MULAI saat Kyai duduk di dalam Surau
## (kursi baca kitab), lalu lacak posisi Kyai sampai ia duduk lagi.
## Deteksi: teleport (loncatan > 5 m/frame), masuk tapak cangkang
## Surau luar (x -8..8, z -24..-4), masuk ruangan interior (rotasi
## -25° mengelilingi pintu (0,-294)), dan persilangan dengan tiap
## segmen dinding interior (A selatan-kiri, B selatan-kanan,
## C utara, D barat, E timur).
## Jalankan headless:
##   godot --headless --path . skrip/test_kyai_tembok.tscn

const LOG_PATH := "/home/hatch/workspace/.logs-gate-18nov/test-kyai-tembok-19nov.log"
const CSV_PATH := "/home/hatch/workspace/.logs-gate-18nov/jejak-kyai-tembok-19nov.csv"

var _main: Node
var _kyai: Node
var _tahap := 0
var _t_game := 0.0
var _t_nyata_mulai := 0
var _pos_terakhir := Vector3.ZERO
var _fase_sholat := ""
var _fase_patroli := ""
var _jejak: Array[Vector3] = []
var _loncatan: Array = []
var _tabrakan: Array = []
var _transisi: Array = []
var _masuk_cangkang := false
var _masuk_interior := false


func _seg_potongan(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 := (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
	var d2 := (p2.x - p1.x) * (p4.y - p1.y) - (p2.y - p1.y) * (p4.x - p1.x)
	var d3 := (p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)
	var d4 := (p4.x - p3.x) * (p2.y - p3.y) - (p4.y - p3.y) * (p2.x - p3.x)
	return ((d1 > 0.0) != (d2 > 0.0)) and ((d3 > 0.0) != (d4 > 0.0))


func _di_dalam_interior(p: Vector3) -> bool:
	# Putar balik +25° mengelilingi pintu (0,-294) -> koordinat lokal.
	var rot := deg_to_rad(25.0)
	var c := cos(rot)
	var s := sin(rot)
	var qx := p.x - 0.0
	var qz := p.z - (-294.0)
	var lx := qx * c + qz * s
	var lz := -qx * s + qz * c
	return lx >= -9.0 and lx <= 9.0 and lz >= -308.0 and lz <= -294.0


func _di_dalam_cangkang(p: Vector3) -> bool:
	return p.x >= -8.0 and p.x <= 8.0 and p.z >= -24.0 and p.z <= -4.0


func _ready() -> void:
	_t_nyata_mulai = Time.get_ticks_msec()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Profil")
	for i in 5:
		await get_tree().process_frame
	_kyai = _main._kyai
	var kursi: Vector3 = _kyai._patroli["kursi"]
	print("KYAI-TEMBOK: posisi_imam=%s" % str(_main._posisi_imam()))
	print("KYAI-TEMBOK: sajadah_03=%s" % str(_main._posisi_sajadah("Sajadah_03")))
	print("KYAI-TEMBOK: interior_spawn=%s interior_door=%s" % [str(_main._interior_spawn), str(_main._interior_door)])
	print("KYAI-TEMBOK: outdoor_exit=%s outdoor_door=%s surau_keluar=%s" % [str(_main._outdoor_exit), str(_main._outdoor_door), str(_main._surau_keluar)])
	print("KYAI-TEMBOK: kursi_dunia=%s" % str(kursi))
	var mihrab := _main._interior_root.find_child("Mihrab", true, false) as Node3D
	if mihrab != null:
		print("KYAI-TEMBOK: mihrab_dunia=%s" % str(mihrab.global_position))
	print("KYAI-TEMBOK: kyai_awal=%s patroli_fase=%s di_dalam=%s" % [str(_kyai.global_position), _kyai._patroli_fase, str(_kyai.di_dalam())])
	# Rute pulang STATIS: rumah = kursi (kasus sesi mulai saat Kyai duduk).
	_main._npc_rumah[_kyai] = kursi
	var rute: Array = _main._rute_pulang(_kyai)
	print("KYAI-TEMBOK: rute_pulang_dari_pintu_ke_kursi=%s" % str(rute))
	# Kembalikan "rumah" ke nilai SETUP (luar, serambi) — seperti di game
	# nyata sebelum _mulai_sholat; guard RONDE 24 harus mempertahankannya.
	_main._npc_rumah[_kyai] = Vector3(-3.5, 0, -2.0)
	print("KYAI-TEMBOK: rumah_setup_dipulihkan=%s" % str(_main._npc_rumah.get(_kyai)))
	# Paksa Kyai duduk di kursi (keadaan awal sesi Dzuhur).
	_kyai.global_position = kursi
	_kyai._patroli_fase = "duduk"
	_kyai._patroli_timer = 120.0
	_pos_terakhir = kursi
	_jejak.append(kursi)
	# Mulai sesi Dzuhur langsung (jam sistem ~12:5x, bukan jendela sholat).
	_main._mulai_sholat({"nama": "Dzuhur", "jam": "12:00", "durasi_menit": 1})
	print("KYAI-TEMBOK: sesi Dzuhur dimulai; rumah_kyai=%s" % str(_main._npc_rumah.get(_kyai)))
	Engine.time_scale = 15.0
	_tahap = 1


func _process(delta: float) -> void:
	if _tahap != 1:
		return
	_t_game += delta
	var pos: Vector3 = _kyai.global_position
	_jejak.append(pos)
	var fs := String(_main._npc_sholat_fase.get(_kyai, ""))
	var fp := String(_kyai._patroli_fase)
	if fs != _fase_sholat or fp != _fase_patroli:
		_transisi.append("t=%.1f fase_sholat=%s->%s patroli=%s->%s pos=%s" % [_t_game, _fase_sholat, fs, _fase_patroli, fp, str(pos)])
		_fase_sholat = fs
		_fase_patroli = fp
	# Teleport = loncatan > 5 m dalam satu frame. Frame teleport
	# DILEWATI dari cek dinding (segmen loncatan memotong garis
	# dinding di proyeksi 2D — artefak, bukan jalan kaki).
	var lompat := pos.distance_to(_pos_terakhir)
	var teleport := false
	if lompat > 5.0:
		teleport = true
		_loncatan.append("t=%.1f LONCAT %.1f m: %s -> %s (fase=%s)" % [_t_game, lompat, str(_pos_terakhir), str(pos), fs])
	# Persilangan dinding interior (segmen gerak vs tiap segmen dinding).
	if not teleport:
		var dinding := {
			"A_selatan_kiri": [Vector2(-8.16, -297.80), Vector2(-1.09, -294.51)],
			"B_selatan_kanan": [Vector2(1.09, -293.49), Vector2(8.16, -290.20)],
			"C_utara": [Vector2(-2.24, -310.49), Vector2(14.07, -302.89)],
			"D_barat": [Vector2(-2.24, -310.49), Vector2(-8.16, -297.80)],
			"E_timur": [Vector2(8.16, -290.20), Vector2(14.07, -302.89)],
		}
		var a := Vector2(_pos_terakhir.x, _pos_terakhir.z)
		var b := Vector2(pos.x, pos.z)
		for nama in dinding:
			var seg: Array = dinding[nama]
			if _seg_potongan(a, b, seg[0], seg[1]):
				_tabrakan.append("t=%.1f TABRAK dinding %s: %s -> %s (fase=%s)" % [_t_game, nama, str(_pos_terakhir), str(pos), fs])
		if _di_dalam_cangkang(pos) and not _masuk_cangkang:
			_masuk_cangkang = true
			_tabrakan.append("t=%.1f MASUK tapak cangkang Surau luar: %s (fase=%s)" % [_t_game, str(pos), fs])
		if _di_dalam_interior(pos) and not _masuk_interior:
			_masuk_interior = true
			_transisi.append("t=%.1f Kyai MASUK ruangan interior: %s (fase=%s)" % [_t_game, str(pos), fs])
	_pos_terakhir = pos
	# Selesai: Kyai duduk lagi + fase sholat kosong + sudah ada jejak pulang.
	var nyata := (Time.get_ticks_msec() - _t_nyata_mulai) / 1000.0
	if (fs == "" and fp == "duduk" and _t_game > 30.0) or nyata > 90.0:
		_tahap = 2
		Engine.time_scale = 1.0
		print("KYAI-TEMBOK: === TRANSISI ===")
		for t in _transisi:
			print("KYAI-TEMBOK: " + t)
		print("KYAI-TEMBOK: === LONCATAN (teleport) ===")
		for t in _loncatan:
			print("KYAI-TEMBOK: " + t)
		print("KYAI-TEMBOK: === TABRAKAN DINDING ===")
		for t in _tabrakan:
			print("KYAI-TEMBOK: " + t)
		print("KYAI-TEMBOK: jejak=%d titik t_game=%.1f posisi_akhir=%s patroli=%s" % [_jejak.size(), _t_game, str(_kyai.global_position), _kyai._patroli_fase])
		var f := FileAccess.open(CSV_PATH, FileAccess.WRITE)
		if f != null:
			f.store_line("t,x,z,fase_sholat,fase_patroli")
			var tt := 0.0
			for p in _jejak:
				f.store_line("%.2f,%.2f,%.2f,," % [tt, p.x, p.z])
				tt += 0.25
			f.close()
			print("KYAI-TEMBOK: csv tersimpan %s" % CSV_PATH)
		var log := FileAccess.open(LOG_PATH, FileAccess.WRITE)
		if log != null:
			for t in _transisi:
				log.store_line(t)
			for t in _loncatan:
				log.store_line(t)
			for t in _tabrakan:
				log.store_line(t)
			log.close()
		get_tree().quit()
