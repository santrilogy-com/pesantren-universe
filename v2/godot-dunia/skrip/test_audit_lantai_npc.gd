extends Node
## AUDIT LANTAI NPC (Sinta, 19 Nov 2026 — tindak lanjut temuan
## lantai Surau y=0,5).
## Membuktikan tanpa memuat dunia (fungsi statis saja):
##   1. LokasiAcak "surau" y=0,5 (lantai visual Surau) — Sanusi
##      DIAM tidak pernah dipanggil _langkah_ke, jadi y spawn ini
##      yang menentukan ia tenggelam atau tidak.
##   2. Semua waypoint 20 NPC (sudut zona implementasi main.gd
##      _spawn_npc_sistem_baru + waypoint dokumen RENCANA-20-NPC-v1
##      + kursi luar KURSI_LUAR): y jalan (_tinggi_tanah) vs lantai
##      visual — selisih > 0,1 m = tenggelam/melayang NYATA.
##      Ambang 0,1 m: di bawah itu tak terlihat (lantai Musholla
##      0,02 / serambi 0,05 / anak tangga 0,08).
##   3. Lantai Musholla putri: lantai cangkang atas 0,02, serambi
##      0,05, anak tangga 0,08 (kampus_putri.gd) — Fatimah spawn
##      y=0 di (134,-24) tenggelam maks 0,02 m = tidak terlihat.
## Jalankan headless (tanpa Xvfb, tanpa dunia):
##   HOME=/tmp/iso-audit-lantai godot --headless --path . --scene res://skrip/test_audit_lantai_npc.tscn

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("AUDIT-LANTAI LULUS %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("AUDIT-LANTAI GAGAL %s %s" % [nama, detail])


## Lantai VISUAL di posisi dunia (cermin main.gd _lantai_visual_y +
## lantai Musholla putri — angka diukur dari kampus_putri.gd):
##   Surau |x|<=8, z -24..-4 -> 0,5 (GLB plinth).
##   Tangga+serambi Surau |x|<=3,6, z -4,1..1,6 -> pijakan(z).
##   Serambi Musholla x 131,75..136,25, z -19..-16,2 -> 0,05.
##   Anak tangga Musholla x 132,4..135,6, z -16,2..-15,7 -> 0,08.
##   Lantai cangkang Musholla x 128..140, z -29..-19 -> 0,02.
##   Di luar itu -> 0,0.
func _lantai_visual(pos: Vector3) -> float:
	if absf(pos.x) <= 8.0 and pos.z >= -24.0 and pos.z <= -4.0:
		return 0.5
	if absf(pos.x) <= 3.6 and pos.z >= -4.1 and pos.z <= 1.6:
		# Lebar PER ANAK TANGGA (cermin main.gd _lantai_visual_y +
		# npc.gd _tinggi_tanah): T3 3,6 / T2 3,3 / T1 3,0 /
		# serambi 3,2 — satu lebar 3,6 salah menaruh rumah Kyai
		# (-3,5,-2,0, rumput) di atas serambi 0,5.
		var lebar := 3.2
		if pos.z >= 0.4:
			lebar = 3.6
		elif pos.z >= -0.2:
			lebar = 3.3
		elif pos.z >= -0.8:
			lebar = 3.0
		if absf(pos.x) <= lebar:
			return TanggaSurau.pijakan(pos.z)
		return 0.0
	if pos.x >= 131.75 and pos.x <= 136.25 and pos.z >= -19.0 and pos.z <= -16.2:
		return 0.05
	if pos.x >= 132.4 and pos.x <= 135.6 and pos.z >= -16.2 and pos.z <= -15.7:
		return 0.08
	if pos.x >= 128.0 and pos.x <= 140.0 and pos.z >= -29.0 and pos.z <= -19.0:
		return 0.02
	return 0.0


func _ready() -> void:
	# --- 1) LokasiAcak "surau" ---
	var pos_surau: Vector3 = LokasiAcak.pos_dari_id("surau")
	_cek("surau y=0,5 (lantai visual)", absf(pos_surau.y - 0.5) < 0.01, str(pos_surau))
	_cek("surau xz tetap (0,-14)", absf(pos_surau.x) < 0.01 and absf(pos_surau.z + 14.0) < 0.01, str(pos_surau))
	for k in LokasiAcak.KANDIDAT:
		if String(k["id"]) == "surau":
			continue
		_cek("kandidat %s y=0 (tanah terbuka)" % String(k["id"]), absf((k["pos"] as Vector3).y) < 0.01, str(k["pos"]))
	for k in LokasiAcak.KANDIDAT_PUTRI:
		_cek("kandidat putri %s y=0 (lantai Musholla maks 0,08)" % String(k["id"]), absf((k["pos"] as Vector3).y) < 0.01, str(k["pos"]))
	# --- 2) Waypoint 20 NPC: sudut zona implementasi main.gd ---
	var zona: Array = [
		# Putra P1 (plaza Surau), P2 (Asrama-Cangkruk), P4 (barat).
		Vector3(-12, 0, 2), Vector3(12, 0, 2), Vector3(12, 0, 16), Vector3(-12, 0, 16),
		Vector3(-38, 0, 2), Vector3(-10, 0, 2), Vector3(-10, 0, 20), Vector3(-38, 0, 20),
		Vector3(-58, 0, -38), Vector3(-44, 0, -38), Vector3(-44, 0, 6), Vector3(-58, 0, 6),
		# Putri W1 (Musholla), W2 (Kelas), W3 (Asrama), W4 (Taman).
		Vector3(124, 0, -16), Vector3(144, 0, -16), Vector3(142, 0, -32), Vector3(124, 0, -32),
		Vector3(122, 0, 2), Vector3(140, 0, 2), Vector3(140, 0, 16), Vector3(122, 0, 16),
		Vector3(142, 0, 2), Vector3(168, 0, 2), Vector3(168, 0, 18), Vector3(142, 0, 18),
		Vector3(116, 0, 26), Vector3(130, 0, 26), Vector3(130, 0, 38), Vector3(116, 0, 38),
	]
	# Waypoint dokumen RENCANA-20-NPC-v1.md §3 (P1/P2/P4/W1-W4).
	var waypoint_dokumen: Array = [
		Vector3(-4, 0, 6), Vector3(-6, 0, -2), Vector3(-8, 0, 8), Vector3(0, 0, 2), Vector3(-2, 0, 12),
		Vector3(-20, 0, 18), Vector3(-32, 0, 24), Vector3(-28, 0, 10), Vector3(-16, 0, 22), Vector3(-30, 0, -2),
		Vector3(-58, 0, -38), Vector3(-44, 0, 10), Vector3(-52, 0, 24), Vector3(-40, 0, -4), Vector3(-58, 0, 8),
		Vector3(134, 0, -14), Vector3(136, 0, -10), Vector3(130, 0, -16), Vector3(138, 0, -18),
		Vector3(140, 0, 16), Vector3(144, 0, 4), Vector3(152, 0, 8), Vector3(136, 0, 0),
		Vector3(152, 0, 10), Vector3(160, 0, 16), Vector3(148, 0, 6), Vector3(162, 0, 4),
		Vector3(120, 0, 26), Vector3(126, 0, 26),
	]
	# Titik-titik kunci lain: rumah Kyai, pintu luar Surau, kursi luar.
	var titik_lain: Array = [
		Vector3(-3.5, 0, -2.0), Vector3(0, 0, -2.3), Vector3(0, 0, 2),
		Vector3(-4, 0, 4), Vector3(-5, 0, 8), Vector3(134, 0, -17),
	]
	var semua: Array = []
	semua.append_array(zona)
	semua.append_array(waypoint_dokumen)
	semua.append_array(titik_lain)
	for k in SantriNPC.KURSI_LUAR:
		semua.append((k as Dictionary)["pos"])
	var n_tenggelam := 0
	for p in semua:
		var pos: Vector3 = p
		var y_jalan: float = SantriNPC._tinggi_tanah(pos)
		var visual: float = _lantai_visual(pos)
		# NPC jalan: y=_tinggi_tanah. NPC DIAM/duduk di kursi: y=pos
		# kursi (KURSI_LUAR y eksplisit 0 / 0,45). Selisih visual
		# vs y dipakai = yang terlihat tenggelam/melayang.
		var y_pakai: float = pos.y if pos.y > 0.01 else y_jalan
		var selisih: float = visual - y_pakai
		if selisih > 0.1:
			n_tenggelam += 1
			print("AUDIT-LANTAI TENGGELAM %s jalan=%.2f visual=%.2f selisih=%.2f" % [str(pos), y_jalan, visual, selisih])
	_cek("0 titik waypoint/kursi tenggelam >0,1 m", n_tenggelam == 0, "(%d titik dicek)" % semua.size())
	# Kasus khusus yang diketahui (INFO, bukan gagal — di bawah ambang):
	# segmen W1 (124,-16)->(144,-16) memotong anak tangga Musholla
	# (atas 0,08) — NPC jalan di y=0, kaki tenggelam 0,08 m sesaat.
	var tengah_w1 := Vector3(134, 0, -16)
	_cek("INFO segmen W1 potong anak tangga Musholla <=0,08 m", _lantai_visual(tengah_w1) <= 0.08, "visual=%.2f" % _lantai_visual(tengah_w1))
	# --- 3) Musholla: Fatimah spawn y=0 vs lantai 0,02 ---
	var pos_fatimah: Vector3 = LokasiAcak.pos_dari_id_putri("musholla_putri")
	_cek("Fatimah Musholla tenggelam maks 0,02 m", _lantai_visual(pos_fatimah) - pos_fatimah.y <= 0.02, "visual=%.2f y=%.2f" % [_lantai_visual(pos_fatimah), pos_fatimah.y])
	print("AUDIT-LANTAI SELESAI lulus=%d gagal=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
