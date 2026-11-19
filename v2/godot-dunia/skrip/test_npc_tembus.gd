extends Node
## Repro: NPC tembus tembok/pagar/pohon (Raka, 19 Nov 2026).
## Laporan Mas 14:00 WIB: "NPC ternyata masih bisa tembus tembok,
## pagar, pohon, dll."
## Metode: raycast marching (3 jalur paralel ±0,3 m, y=0,9) di sepanjang
## SETIAP segmen yang bisa ditempuh NPC + shape-query titik untuk
## waypoint yang berdiri DI DALAM benda padat + cek geometris tapak
## 5 cangkang besar (pintu = celah; NPC luar tidak pernah boleh
## berada di dalam tapak — masuk ruangan hanya via teleport).
## Fisika dipakai sebagai PENDETEKSI — NPC sendiri tidak punya
## fisika (gerak langsung via posisi, npc.gd).
## Fase: 0 probe detektor | A semua pasangan waypoint bebas Bilal/Faris
## (91 pasang) | B siklus patroli Kyai + Mariyah (luar + dalam) |
## C rute sholat dari tiap titik berangkat | D simulasi jalan bebas
## live (time_scale 15, ~60 dtk nyata).
## JANGAN ubah kode game — skrip tes saja.
## Jalankan headless:
##   godot --headless --path . skrip/test_npc_tembus.tscn

const LOG_PATH := "/home/hatch/workspace/.logs-gate-18nov/test-npc-tembus-19nov.log"
const CSV_PATH := "/home/hatch/workspace/.logs-gate-18nov/jejak-npc-tembus-19nov.csv"

var _main: Node
var _ruang: PhysicsDirectSpaceState3D
var _bilal: Node
var _faris: Node
var _kyai: Node
var _ustadzah: Node
var _wps: Array[Vector3] = []
var _temuan: Array[String] = []
var _dilihat := {}
var _t_nyata_mulai := 0
var _tahap := 0
var _dinamis_mulai := 0
var _pos_sebelum := {}
var _pasangan_dilalui := {}
var _target_sebelum := {}
var _csv: FileAccess

# Cangkang besar: [min_xz, max_xz]. NPC luar TIDAK PERNAH boleh
# berada di dalam tapak (masuk ruangan hanya via teleport GTA).
const CANGKANG := {
	"Surau": [Vector2(-8, -24), Vector2(8, -4)],
	"Cangkruk": [Vector2(-27, -22), Vector2(-17, -14)],
	"AsramaPutra": [Vector2(-33.25, 4), Vector2(-14.75, 16)],
	"Musholla": [Vector2(128, -29), Vector2(140, -19)],
	"AsramaPutri": [Vector2(146, 3), Vector2(164, 15)],
}


func _nama_tabrakan(c: Node) -> String:
	if c == null:
		return "?"
	var induk := c.get_parent()
	var nama_induk := "" if induk == null else String(induk.name)
	var p := Vector3.ZERO
	if c is Node3D:
		p = (c as Node3D).global_position
	return "%s/%s@(%.1f,%.1f)" % [nama_induk, String(c.name), p.x, p.z]


func _ray_dari_ke(dari: Vector2, ke: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(Vector3(dari.x, 0.9, dari.y), Vector3(ke.x, 0.9, ke.y))
	q.collision_mask = 0xFFFFFFFF
	q.collide_with_areas = false
	q.collide_with_bodies = true
	return _ruang.intersect_ray(q)


func _cek_titik(p: Vector3) -> Array:
	var q := PhysicsShapeQueryParameters3D.new()
	var bola := SphereShape3D.new()
	bola.radius = 0.35
	q.shape = bola
	q.transform = Transform3D(Basis(), Vector3(p.x, 0.9, p.z))
	q.collision_mask = 0xFFFFFFFF
	q.collide_with_areas = false
	q.collide_with_bodies = true
	var hasil := _ruang.intersect_shape(q)
	var out: Array = []
	for h in hasil:
		var c := h.get("collider") as Node
		if c == null or not (c is StaticBody3D):
			continue
		out.append(_nama_tabrakan(c))
	return out


func _catat(fase: String, label: String, apa: String, pos: Vector2) -> void:
	var kunci := "%s|%s|%s|%d,%d" % [fase, label, apa, int(round(pos.x)), int(round(pos.y))]
	if _dilihat.has(kunci):
		return
	_dilihat[kunci] = true
	var baris := "%s | %s | %s @ (%.1f, %.1f)" % [fase, label, apa, pos.x, pos.y]
	_temuan.append(baris)
	print("NPC-TEMBUS: " + baris)


func _cek_segmen(a: Vector3, b: Vector3, fase: String, label: String) -> void:
	var d := Vector2(b.x - a.x, b.z - a.z)
	var panjang := d.length()
	if panjang < 0.05:
		return
	var arah := d / panjang
	var tegak := Vector2(-arah.y, arah.x)
	for jalur: float in [-0.3, 0.0, 0.3]:
		var off := tegak * jalur
		var pos := Vector2(a.x, a.z) + off
		var sisa := panjang
		var guard := 0
		while sisa > 0.01 and guard < 128:
			guard += 1
			var target := pos + arah * sisa
			var hit := _ray_dari_ke(pos, target)
			if hit.is_empty():
				break
			var c := hit.get("collider") as Node
			if c == null or not (c is StaticBody3D):
				break
			var hp := hit.get("position") as Vector3
			var hp2 := Vector2(hp.x, hp.z)
			_catat(fase, label, "TABRAK " + _nama_tabrakan(c), hp2)
			var maju := hp2.distance_to(pos) + 0.5
			pos = pos + arah * maju
			sisa = sisa - maju
	# Cek geometris cangkang: sampel tiap 1 m — titik di dalam tapak
	# = tembus (raycast tidak menangkap jalan lewat celah pintu).
	var n := int(panjang / 1.0) + 1
	for i in range(n + 1):
		var t := float(i) / float(n)
		var p := Vector2(a.x, a.z) + d * t
		for nama in CANGKANG:
			var r: Array = CANGKANG[nama]
			var mn: Vector2 = r[0]
			var mx: Vector2 = r[1]
			if p.x >= mn.x and p.x <= mx.x and p.y >= mn.y and p.y <= mx.y:
				_catat(fase, label, "DI DALAM CANGKANG " + nama, p)
				break


func _cek_rute(titik: Array, fase: String, label: String) -> void:
	for i in range(titik.size() - 1):
		_cek_segmen(titik[i], titik[i + 1], fase, label)


func _ready() -> void:
	_t_nyata_mulai = Time.get_ticks_msec()
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes Tembus")
	for i in 5:
		await get_tree().process_frame
	_ruang = get_viewport().get_world_3d().direct_space_state
	_bilal = _main._bilal
	_faris = _main._faris
	_kyai = _main._kyai
	_ustadzah = _main._ustadzah
	# Waypoint Bilal/Faris = filter yang sama seperti _spawn_npcs.
	for wp in PesantrenBuilder.NPC_WAYPOINTS:
		if wp.x < -0.5 or wp.z > 16.5:
			_wps.append(wp)
	print("NPC-TEMBUS: waypoint_bebas=%d %s" % [_wps.size(), str(_wps)])
	print("NPC-TEMBUS: bilal=%s faris=%s kyai=%s ustadzah=%s" % [str(_bilal.global_position), str(_faris.global_position), str(_kyai.global_position), str(_ustadzah.global_position)])

	# ---------- FASE 0: probe detektor ----------
	print("NPC-TEMBUS: === FASE 0 probe ===")
	var probe := {
		"TembokUtara(14,-30)": Vector3(14, 0, -30),
		"BarrierGerbang(14,0)": Vector3(14, 0, 0),
		"TembokSelatan(14,9)": Vector3(14, 0, 9),
		"Surau(0,-14)": Vector3(0, 0, -14),
		"Cangkruk(-22,-18)": Vector3(-22, 0, -18),
		"AsramaPutra(-24,10)": Vector3(-24, 0, 10),
		"Musholla(134,-24)": Vector3(134, 0, -24),
		"AsramaPutri(155,9)": Vector3(155, 0, 9),
		"Kantor(148,-33)": Vector3(148, 0, -33),
		"Pohon(-26,-8)": Vector3(-26, 0, -8),
		"Plaza(0,30)": Vector3(0, 0, 30),
	}
	for nama in probe:
		var isi: Array = _cek_titik(probe[nama])
		print("NPC-TEMBUS: probe %s -> %s" % [nama, "KOSONG (tak ada collision!)" if isi.is_empty() else str(isi)])
	# Raycast dari dalam Asrama ke luar — apakah ray dari dalam
	# benda padat tetap melaporkan hit (menentukan blind spot)?
	var r_dalam := _ray_dari_ke(Vector2(-24, 10), Vector2(-24, 40))
	print("NPC-TEMBUS: probe ray-dari-dalam-Asrama -> %s" % ("KOSONG" if r_dalam.is_empty() else str(r_dalam.get("collider"))))
	await get_tree().process_frame

	# ---------- FASE A: semua pasangan waypoint bebas ----------
	print("NPC-TEMBUS: === FASE A pasangan bebas (91) ===")
	for i in range(_wps.size()):
		for j in range(i + 1, _wps.size()):
			var a: Vector3 = _wps[i]
			var b: Vector3 = _wps[j]
			_cek_segmen(a, b, "bebas", "pasangan (%d,%d)<->(%d,%d)" % [int(a.x), int(a.z), int(b.x), int(b.z)])
		await get_tree().process_frame
	# Waypoint yang berdiri DI DALAM benda padat.
	for w in _wps:
		var isi2: Array = _cek_titik(w)
		if not isi2.is_empty():
			_catat("bebas", "waypoint (%.0f,%.0f)" % [w.x, w.z], "TITIK DI DALAM " + str(isi2), Vector2(w.x, w.z))
	print("NPC-TEMBUS: fase A selesai, temuan=%d" % _temuan.size())
	await get_tree().process_frame

	# ---------- FASE B: siklus patroli Kyai + Mariyah ----------
	print("NPC-TEMBUS: === FASE B patroli ===")
	var pk: Dictionary = _kyai._patroli
	var pm: Dictionary = _ustadzah._patroli
	var pintu_luar_kyai: Vector3 = pk["pintu_luar"]
	var pintu_luar_mar: Vector3 = pm["pintu_luar"]
	var rute_kyai: Array = [pintu_luar_kyai]
	for p in (pk["rute_luar"] as Array):
		rute_kyai.append(p)
	rute_kyai.append(pintu_luar_kyai)
	_cek_rute(rute_kyai, "patroli", "Kyai siklus luar")
	var rute_mar: Array = [pintu_luar_mar]
	for p in (pm["rute_luar"] as Array):
		rute_mar.append(p)
	rute_mar.append(pintu_luar_mar)
	_cek_rute(rute_mar, "patroli", "Mariyah siklus luar")
	# Segmen dalam ruangan: kursi <-> pintu dalam, spawn dalam -> kursi.
	_cek_segmen(pk["kursi"], pk["pintu_dalam"], "patroli-dalam", "Kyai kursi->pintu_dalam")
	_cek_segmen(pk["spawn_dalam"], pk["kursi"], "patroli-dalam", "Kyai spawn_dalam->kursi")
	_cek_segmen(pm["kursi"], pm["pintu_dalam"], "patroli-dalam", "Mariyah kursi->pintu_dalam")
	_cek_segmen(pm["spawn_dalam"], pm["kursi"], "patroli-dalam", "Mariyah spawn_dalam->kursi")
	for p in (pk["rute_luar"] as Array) + (pm["rute_luar"] as Array) + [pintu_luar_kyai, pintu_luar_mar]:
		var isi3: Array = _cek_titik(p)
		if not isi3.is_empty():
			_catat("patroli", "titik patroli (%.0f,%.0f)" % [p.x, p.z], "TITIK DI DALAM " + str(isi3), Vector2(p.x, p.z))
	print("NPC-TEMBUS: fase B selesai, temuan=%d" % _temuan.size())
	await get_tree().process_frame

	# ---------- FASE C: rute sholat ----------
	print("NPC-TEMBUS: === FASE C rute sholat ===")
	for w in _wps:
		var r1: Array = _main._rute_ke_pintu_surau(w)
		var titik1: Array = [w]
		for p in r1:
			titik1.append(p)
		_cek_rute(titik1, "sholat-ke-pintu", "Surau dari (%.0f,%.0f)" % [w.x, w.z])
		var r1m: Array = _main._rute_ke_pintu_musholla(w)
		var titik1m: Array = [w]
		for p in r1m:
			titik1m.append(p)
		_cek_rute(titik1m, "sholat-ke-pintu", "Musholla dari (%.0f,%.0f)" % [w.x, w.z])
	# Rute pulang: Kyai + Mariyah dari pintu keluar ke rumah.
	var pos_awal_kyai: Vector3 = _kyai.global_position
	var pos_awal_mar: Vector3 = _ustadzah.global_position
	_kyai.global_position = _main._outdoor_exit
	var rp_k: Array = _main._rute_pulang(_kyai)
	var tk: Array = [_main._outdoor_exit]
	for p in rp_k:
		tk.append(p)
	_cek_rute(tk, "sholat-pulang", "Kyai pulang")
	_kyai.global_position = pos_awal_kyai
	_ustadzah.global_position = _main._musholla_exit
	var rp_m: Array = _main._rute_pulang(_ustadzah)
	var tm: Array = [_main._musholla_exit]
	for p in rp_m:
		tm.append(p)
	_cek_rute(tm, "sholat-pulang", "Mariyah pulang")
	_ustadzah.global_position = pos_awal_mar
	# Rute pulang Bilal/Faris (rumah default = SPAWN) dari pintu keluar.
	var pos_awal_b: Vector3 = _bilal.global_position
	_bilal.global_position = _main._outdoor_exit
	var rp_b: Array = _main._rute_pulang(_bilal)
	var tb: Array = [_main._outdoor_exit]
	for p in rp_b:
		tb.append(p)
	_cek_rute(tb, "sholat-pulang", "Bilal pulang")
	_bilal.global_position = pos_awal_b
	print("NPC-TEMBUS: fase C selesai, temuan=%d" % _temuan.size())

	# ---------- FASE D: simulasi jalan bebas live ----------
	print("NPC-TEMBUS: === FASE D jalan bebas live (60 dtk) ===")
	_csv = FileAccess.open(CSV_PATH, FileAccess.WRITE)
	if _csv != null:
		_csv.store_line("t,npc,x,z,fase")
	_pos_sebelum[_bilal] = _bilal.global_position
	_pos_sebelum[_faris] = _faris.global_position
	_target_sebelum[_bilal] = _bilal._target
	_target_sebelum[_faris] = _faris._target
	Engine.time_scale = 15.0
	_dinamis_mulai = Time.get_ticks_msec()
	_tahap = 4


func _process(_delta: float) -> void:
	if _tahap != 4:
		return
	var t_game := float(Time.get_ticks_msec() - _dinamis_mulai) / 1000.0
	for npc in [_bilal, _faris]:
		var nama := String(npc._nama)
		var pos: Vector3 = npc.global_position
		var sebelum: Vector3 = _pos_sebelum.get(npc, pos)
		if pos.distance_to(sebelum) > 0.01:
			var hit := _ray_dari_ke(Vector2(sebelum.x, sebelum.z), Vector2(pos.x, pos.z))
			if not hit.is_empty():
				var c := hit.get("collider") as Node
				if c != null and (c is StaticBody3D):
					var hp := hit.get("position") as Vector3
					_catat("bebas-dinamis", nama, "TABRAK " + _nama_tabrakan(c), Vector2(hp.x, hp.z))
			# Cek geometris cangkang pada posisi baru.
			for cnama in CANGKANG:
				var r: Array = CANGKANG[cnama]
				var mn: Vector2 = r[0]
				var mx: Vector2 = r[1]
				if pos.x >= mn.x and pos.x <= mx.x and pos.z >= mn.y and pos.z <= mx.y:
					_catat("bebas-dinamis", nama, "DI DALAM CANGKANG " + cnama, Vector2(pos.x, pos.z))
					break
		_pos_sebelum[npc] = pos
		var tgt: Vector3 = npc._target
		if tgt != _target_sebelum.get(npc, tgt):
			var kunci := "%s|%s->%s" % [nama, str(_target_sebelum.get(npc, Vector3.ZERO)), str(tgt)]
			_pasangan_dilalui[kunci] = true
			_target_sebelum[npc] = tgt
		if _csv != null and int(t_game * 2.0) != int((t_game - 0.05) * 2.0):
			_csv.store_line("%.1f,%s,%.2f,%.2f,%s" % [t_game, nama, pos.x, pos.z, "sholat" if npc.sedang_sholat() else "bebas"])
	var nyata := (Time.get_ticks_msec() - _dinamis_mulai) / 1000.0
	if nyata >= 60.0:
		_tahap = 5
		Engine.time_scale = 1.0
		if _csv != null:
			_csv.close()
		print("NPC-TEMBUS: === RINGKASAN ===")
		print("NPC-TEMBUS: pasangan_dilalui_live=%d" % _pasangan_dilalui.size())
		for k in _pasangan_dilalui:
			print("NPC-TEMBUS: live " + k)
		print("NPC-TEMBUS: total_temuan=%d" % _temuan.size())
		for t in _temuan:
			print("NPC-TEMBUS: " + t)
		var log := FileAccess.open(LOG_PATH, FileAccess.WRITE)
		if log != null:
			log.store_line("total_temuan=%d" % _temuan.size())
			log.store_line("pasangan_dilalui_live=%d" % _pasangan_dilalui.size())
			for k in _pasangan_dilalui:
				log.store_line("live " + k)
			for t in _temuan:
				log.store_line(t)
			log.close()
			print("NPC-TEMBUS: log tersimpan %s" % LOG_PATH)
		get_tree().quit()
