extends Node
## TEST TABRAKAN DUNIA — Pesantren Universe v2 (Bagas, 18 Nov 2026).
## Audit Mas (HP, alpha ecd7e2e9): tiang + pohon bisa dilewati.
## Cara: instantiate main.tscn, masuk pesantren, dorong pemain
## lurus ke objek N frame, ukur jarak tempuh MAKSIMUM sepanjang
## arah dorong (bukan posisi akhir — logika dorong-balik _cek_batas
## bisa memindahkan pemain setelah tertahan).
##   LOLOS bila tempuh dalam [ideal-0,6, ideal+0,1]
##   (ideal = jarak_muka - 0,35 kapsul); TEMBUS bila jauh lebih besar.
## Jalankan headless:
##   godot --headless --path . skrip/test_tabrakan_dunia.tscn
## REVISI 18 Nov 2026 (setelah baseline 13 LULUS / 28 GAGAL):
## - role "keamanan" diset di tes supaya _cek_batas TIDAK menarik
##   teleport uji (putra di zona putri kena yank ke posisi legal —
##   3 probe pohon rindang + 2 probe plot gagal karena ini, bukan
##   karena collision). Satu run gabungan putra+putri.
## - Probe yang terkonfound baseline diperbaiki: lampu (-2,5,30)
##   didekati dari DALAM taman; dinding cangkruk off-axis (x=-24,
##   bukan sumbu pintu -22); papan+tiang plot memakai ASRAMA (papan
##   Ruang Kelas TIDAK BISA diprobe: papan + tiang timur berdiri DI
##   DALAM PosSatpam (17,5), tiang barat DI DALAM tembok x=14 —
##   tembok/pos menahan dari segala arah; collision kodenya sama,
##   tapi layout-nya perlu Raka/Bima putuskan); rak Surau head-on
##   (bukan sepanjang dinding — start lama di luar ruangan);
##   smartboard Surau menyusuri dinding; jalan E-W di z=1,1 (tangga
##   Surau menutup sumbu z=0 — probe terpisah, lapor ke Raka).
## - KONVENSI: jarak_muka = jarak START ke MUKA objek (bukan ideal).
##   ideal = jarak_muka - 0,35 (radius kapsul). Baseline sempat
##   memakai ideal sebagai jarak_muka di beberapa probe — diperbaiki.
## - Probe interior Musholla memakai rak BARU RakBukuPutri (Dewi,
##   18 Nov — SUDAH punya collision); posisi lama sudah tidak ada.
## - Smartboard Musholla + mihrab Musholla pakai band KETAT
##   (toleransi atas 0,03): mukanya hanya 0,085-0,125 di depan
##   dinding — dinding di belakangnya hampir menahan di titik sama.
## - Diagnosis pintu taman (Gilang) dipertahankan: 4 sub-probe.
## Jangan edit skrip/test_v2.gd (Gilang mengeditnya paralel).

var _main: Node
var _t_fwd: Vector3
var _t_right: Vector3
var _lulus := 0
var _gagal := 0


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Role keamanan: _pemain_boleh_lewat_batas() lolos — _cek_batas
	# tidak menarik teleport uji. Hanya di tes (save di memori).
	_main._save["role"] = "keamanan"
	_main._masuk_pesantren("Tes tabrakan")
	for i in 3:
		await get_tree().process_frame
	# WAJIB await (bukan panggil biasa): _kalibrasi async — tanpa
	# await, _ready lanjut ke probe sementara kalibrasi belum
	# selesai dan _t_fwd/_t_right masih (0,0,0) -> semua probe
	# tempuh 0,00 (run fix1: 9 LULUS / 49 GAGAL palsu).
	await _kalibrasi()
	print("MODE: GABUNGAN putra+putri fwd=%s right=%s" % [str(_t_fwd), str(_t_right)])
	# Pintu taman: abaikan NPC supaya deterministik (kecuali
	# sub-probe diagnosis a2 yang memakai NPC nyata).
	var pintu: Node = _main._pesantren["root"].find_child("PintuTaman", true, false)
	if pintu != null and pintu.has_method("set_abaikan_npc"):
		pintu.set_abaikan_npc(true)

	# ================= PUTRA — luar =================
	# Tiang lampu jalan Cahya (8 di x=-2,5 + pos satpam).
	# Mode tiang (penetrasi): kotak 0,141 — pemain bisa tergelincir
	# mengelilingi tanpa menembus; jaga = 0,0705+0,35-0,05 = 0,37.
	await _cek_tiang("lampu jalan (-2.5,10)", Vector3(-2.5, 0, 14), Vector3(0, 0, -1), Vector3(-2.5, 0, 10), 0.37)
	await _cek_tiang("lampu jalan (-2.5,30) dari dalam taman", Vector3(-2.5, 0, 27), Vector3(0, 0, 1), Vector3(-2.5, 0, 30), 0.37)
	await _cek_tiang("lampu jalan (-2.5,-30)", Vector3(-2.5, 0, -26), Vector3(0, 0, -1), Vector3(-2.5, 0, -30), 0.37)
	await _cek_tiang("lampu jalan (-6.89,-2.67)", Vector3(-6.89, 0, 1.5), Vector3(0, 0, -1), Vector3(-6.89, 0, -2.67), 0.37)
	# Pohon: hias (_tree) vs rindang penyangga (baru). Mode tiang
	# (penetrasi): hias kotak 0,283 -> jaga 0,44; rindang kotak
	# 0,453 -> jaga 0,53.
	await _cek_tiang("pohon hias (-10,-8) [collision lama]", Vector3(-10, 0, -4), Vector3(0, 0, -1), Vector3(-10, 0, -8), 0.44)
	await _cek_tiang("pohon rindang penyangga (35,5)", Vector3(30, 0, 5), Vector3(1, 0, 0), Vector3(35, 0, 5), 0.53)
	await _cek_tiang("pohon rindang penyangga (70,-15)", Vector3(65, 0, -15), Vector3(1, 0, 0), Vector3(70, 0, -15), 0.53)
	await _cek_tiang("pohon rindang jauh (60,-50) [_tree]", Vector3(60, 0, -45), Vector3(0, 0, -1), Vector3(60, 0, -50), 0.53)
	await _cek_tiang("pohon hias jauh (-60,-40) [_tree]", Vector3(-60, 0, -35), Vector3(0, 0, -1), Vector3(-60, 0, -40), 0.44)
	# Pagar bata (z=39).
	await _cek_tahan("pagar bata (-30,39)", Vector3(-30, 0, 35), Vector3(0, 0, 1), 3.9)
	await _cek_tahan("pagar bata (-16,39) ujung timur", Vector3(-16, 0, 35), Vector3(0, 0, 1), 3.9)
	# Regresi: tembok x=14 + peti (sudah benar).
	await _cek_tahan("tembok x=14 (10,0)", Vector3(10, 0, 0), Vector3(1, 0, 0), 3.875)
	await _cek_tahan("peti (0,28) dari utara", Vector3(0, 0, 24), Vector3(0, 0, 1), 3.625)
	# Surau GLB (teleport y=0,5 ke lantai serambi untuk tiang).
	await _cek_tahan("menara surau (-8.85,-3.15)", Vector3(-8.85, 0, 1), Vector3(0, 0, -1), 2.95)
	await _cek_tahan("bak wudu (-8.4,-21.5) dari selatan", Vector3(-8.6, 0, -18), Vector3(0, 0, -1), 2.0)
	await _cek_tahan("pot serambi (4.2,-0.4)", Vector3(6, 0, -0.4), Vector3(-1, 0, 0), 1.55)
	await _cek_tahan("tiang serambi (-1,-1.1)", Vector3(-2.3, 0.5, -1.1), Vector3(1, 0, 0), 1.1)
	await _cek_tahan("tiang serambi (2.9,-1.1)", Vector3(1.7, 0.5, -1.1), Vector3(1, 0, 0), 1.0)
	# Dinding bangunan (regresi).
	await _cek_tahan("dinding selatan cangkruk (-24,-14)", Vector3(-24, 0, -10), Vector3(0, 0, -1), 3.875)
	await _cek_tahan("dinding selatan pos jaga (-40,-35)", Vector3(-40, 0, -30), Vector3(0, 0, -1), 3.4)
	# Papan plot (dari utara — pos satpam menghalangi dari selatan).
	await _cek_tahan("papan plot Asrama (-16,4.6)", Vector3(-16, 0, 1), Vector3(0, 0, 1), 3.54)
	await _cek_tiang("tiang papan plot Asrama (-18,4.6)", Vector3(-18, 0, 1), Vector3(0, 0, 1), Vector3(-18, 0, 4.6), 0.36) # kotak 0,127 -> jaga 0,36
	# Taman GLB.
	await _cek_tahan("bangku taman 1 (-3,25.45) dari dalam", Vector3(-3, 0, 28.5), Vector3(0, 0, -1), 2.78)
	await _cek_tahan("bangku taman 2 (3.45,28.2)", Vector3(1, 0, 28.2), Vector3(1, 0, 0), 2.175)
	await _cek_tiang("pohon taman (-2.2,27.4) dari dalam", Vector3(-2.2, 0, 29.5), Vector3(0, 0, -1), Vector3(-2.2, 0, 27.4), 0.44) # kotak 0,283 -> jaga 0,44
	# Gubuk (Dewa) — verifikasi saja, jangan sentuh.
	# Pendekatan dari LUAR (selatan): pemain 1,7 m tidak muat di
	# kolong 1,32 m — teleport ke dalam kolong (fix2) malah menjepit
	# pemain di lantai gubuk. Dinding kolong selatan yang diuji.
	# (test_v2 Rangga juga gagal "Kolong tertutup": selip 0,41 m
	# ke kolong + 0,09 m di bawah lantai — file gubuk_masuk.gd
	# Dewa/Raka, lapor ke Raka.)
	await _cek_tahan("kolong gubuk sawah (26,30) dari luar", Vector3(26, 0, 34), Vector3(0, 0, -1), 2.44) # muka selatan dinding 31,56 (bukan 32,09 — itu posisi berhenti dari dalam)
	# Jalan bebas (harus lewat).
	await _cek_lewat("jalan N-S bebas (0,20)->(0,0)", Vector3(0, 0, 20), Vector3(0, 0, -1), 20.0, 400)
	_main._di_dalam = false
	# Probe jalan N-S men-teleport pemain masuk Surau lewat pintu
	# (koridor _cek_pintu_surau) — yaw kamera berubah, basis
	# kalibrasi tidak berlaku lagi: kalibrasi ulang.
	await _kalibrasi()
	# Jalan E-W: sumbu z=0..1,1 DITUTUP tangga+serambi Surau (bukan
	# bug collision — Surau duduk di jalur jalan; pemain memutar
	# lewat utara, z=-25, di luar dinding utara Surau z=-24).
	# Jarak 30,0 (bukan 33,875): tembok menahan di 33,5 — _cek_lewat
	# butuh tempuh > jarak+1, jadi target 30 membuktikan jalan
	# bersih sampai tembok.
	await _cek_lewat("jalan E-W detour utara Surau z=-25", Vector3(-20, 0, -25), Vector3(1, 0, 0), 30.0, 700)
	# INFO: tangga Surau menutup sumbu jalan E-W (z=0) — LOLOS =
	# tangga menahan (diketahui, lapor ke Raka); bukan kegagalan tes.
	# Jarak_muka 17,0: di z=0 yang menghadang adalah segmen 3 ramp
	# (lebar 6,0, muka barat x=-3,0 — bukan segmen 1 lebar 7,2);
	# pemain berhenti di -3,35 = -3,0+0,35 (fix4: tempuh 16,65).
	await _cek_tahan("jalan E-W tengah (tangga Surau menahan)", Vector3(-20, 0, 0), Vector3(1, 0, 0), 17.0, 0.1, 300)

	# ================= DIAGNOSIS PINTU TAMAN (Gilang) =================
	await _diag_pintu_taman()

	# ================= INTERIOR SURAU =================
	await _kalibrasi()
	_main._di_dalam = true
	# Rak head-on (dari tengah ruangan ke dinding).
	await _cek_tahan_interior_surau("rak surau barat (head-on)", Vector3(-7.0, 0, -296), Vector3(-8.8, 0, -296), 1.6)
	await _cek_tahan_interior_surau("rak surau timur (head-on)", Vector3(7.0, 0, -306), Vector3(8.8, 0, -306), 1.6)
	await _cek_tahan_interior_surau("meja sampar 1 (-6.5,-298.5)", Vector3(-4, 0, -298.5), Vector3(-6.5, 0, -298.5), 1.75)
	await _cek_tahan_interior_surau("meja sampar 3 (7.3,-303.5)", Vector3(7.3, 0, -301), Vector3(7.3, 0, -303.5), 2.1)
	await _cek_tahan_interior_surau("rehal Kyai (5.05,-305)", Vector3(5.05, 0, -303.5), Vector3(5.05, 0, -305), 1.32)
	await _cek_tiang_interior_surau("pilar sudut interior (-8.88,-294.12)", Vector3(-7.0, 0, -296.0), Vector3(-8.88, 0, -294.12), Vector3(-8.88, 0, -294.12), 0.46) # diagonal (start lama menempel dinding selatan); kotak 0,311 -> jaga 0,46
	await _cek_tahan_interior_surau("smartboard surau (-8.85,-305.2)", Vector3(-7.0, 0, -305.2), Vector3(-8.85, 0, -305.2), 1.78, 0.03) # head-on dari timur; start lama di dalam footprint mihrab
	await _cek_tahan_interior_surau("mihrab (-8.4,-301)", Vector3(-6.5, 0, -301), Vector3(-8.4, 0, -301), 1.81)
	_main._di_dalam = false

	# ================= INTERIOR CANGKRUK =================
	await _kalibrasi()
	_main._di_dalam_cangkruk = true
	await _cek_tahan_interior_cangkruk("lemari cangkruk (-53.6,-296.8)", Vector3(-56, 0, -296.8), Vector3(-53.6, 0, -296.8), 2.125)
	await _cek_tahan_interior_cangkruk("meja kecil cangkruk (-66.2,-296.8)", Vector3(-64, 0, -296.8), Vector3(-66.2, 0, -296.8), 1.75)
	_main._di_dalam_cangkruk = false

	# ================= PUTRI — luar =================
	await _kalibrasi()
	# Pagar kayu Musholla (segmen) + celah (harus lewat).
	await _cek_tahan("pagar kayu Musholla utara (133,-31)", Vector3(133, 0, -34), Vector3(0, 0, 1), 2.925) # dari utara pagar; start lama di dalam cangkang Musholla
	await _cek_tahan("pagar kayu Musholla barat (126,-24)", Vector3(123, 0, -24), Vector3(1, 0, 0), 2.925) # jarak_muka benar 2,925 (muka pagar), bukan 2,65
	await _cek_lewat("celah pagar Musholla selatan (134,-17)", Vector3(134, 0, -14), Vector3(0, 0, -1), 5.0, 100)
	_main._di_dalam_musholla = false
	# Celah selatan men-teleport masuk Musholla lewat pintu —
	# yaw kamera berubah: kalibrasi ulang.
	await _kalibrasi()
	await _cek_lewat("celah pagar Musholla timur (140,-18)", Vector3(143, 0, -18), Vector3(-1, 0, 0), 5.0, 100)
	_main._di_dalam_musholla = false
	# Celah timur juga men-teleport masuk Musholla: kalibrasi ulang.
	await _kalibrasi()
	# Pilar + tiang serambi Musholla.
	await _cek_tiang("pilar barat Musholla (128.3,-28.7)", Vector3(131, 0, -28.7), Vector3(-1, 0, 0), Vector3(128.3, 0, -28.7), 0.46) # kotak 0,311 -> jaga 0,46
	await _cek_tiang("tiang serambi Musholla (132.2,-16.6)", Vector3(130, 0, -16.6), Vector3(1, 0, 0), Vector3(132.2, 0, -16.6), 0.41) # kotak 0,212 -> jaga 0,41
	# Regresi putri: tembok keliling + gerbang.
	await _cek_tahan("barrier gerbang putri (115,0)", Vector3(112, 0, 0), Vector3(1, 0, 0), 2.8)
	await _cek_tahan("tembok keliling putri timur (216,0)", Vector3(213, 0, 0), Vector3(1, 0, 0), 2.8)
	await _cek_lewat("jalan internal putri (142,14)->(142,-28)", Vector3(142, 0, 14), Vector3(0, 0, -1), 40.0, 700)

	# ================= INTERIOR MUSHOLLA =================
	await _kalibrasi()
	_main._di_dalam_musholla = true
	# Rak RakBukuPutri (Dewi, 18 Nov — sudah ada collision):
	# rak1 (66.7,-298) rot -25-90; rak2 (57.5,-305.7) rot -25.
	# Didekati head-on dari depan muka rak (+Z lokal rak).
	var rak1_pos := InteriorMusholla.ke_dunia(Vector3(66.7, 0, -298.0))
	var rak1_rot := deg_to_rad(-25.0) - PI / 2.0
	var rak1_dir := Vector3(sin(rak1_rot), 0, cos(rak1_rot))
	await _cek_tahan("rak Musholla timur (RakBukuPutri)", rak1_pos + rak1_dir * 2.0, -rak1_dir, 1.825)
	var rak2_pos := InteriorMusholla.ke_dunia(Vector3(57.5, 0, -305.7))
	var rak2_rot := deg_to_rad(-25.0)
	var rak2_dir := Vector3(sin(rak2_rot), 0, cos(rak2_rot))
	await _cek_tahan("rak Musholla utara (RakBukuPutri)", rak2_pos + rak2_dir * 2.0, -rak2_dir, 1.825)
	await _cek_tahan_interior_musholla("meja Musholla (64.5,-297.5)", Vector3(64.5, 0, -299), Vector3(64.5, 0, -297.5), 1.15) # dari utara; start lama 0,5 m dari dinding selatan (kapsul nyaris menempel)
	await _cek_tahan_interior_musholla("rehal Ustadzah (65.05,-305)", Vector3(65.05, 0, -303), Vector3(65.05, 0, -305), 1.775)
	await _cek_tahan_interior_musholla("smartboard Musholla (53.2,-304)", Vector3(55.0, 0, -304), Vector3(53.2, 0, -304), 1.74, 0.03)
	await _cek_tahan_interior_musholla("mihrab Musholla (53.15,-301)", Vector3(55.0, 0, -301), Vector3(53.15, 0, -301), 1.75, 0.03)
	_main._di_dalam_musholla = false

	print("HASIL TABRAKAN: %d LULUS, %d GAGAL" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


func _kalibrasi() -> void:
	# Ukur basis joystick -> arah dunia pada yaw kamera SAAT INI.
	# Teleport dulu ke spawn (-4,14, jalan lapang) supaya kedua
	# arah ukur bebas halangan; posisi LANGSUNG (bukan
	# _teleport_player) supaya yaw kamera tidak berubah — basis
	# hanya valid selama yaw kamera tetap (pola test_v2).
	_main._player.global_position = Vector3(-4, 0, 14)
	_main._player.velocity = Vector3.ZERO
	for i in 3:
		await get_tree().process_frame
	var start: Vector3 = _main._player.global_position
	_main._player.set_aksi("berdiri")
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 20:
		await get_tree().process_frame
	var d: Vector3 = _main._player.global_position - start
	d.y = 0
	if d.length() > 0.05:
		_t_fwd = d.normalized()
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	start = _main._player.global_position
	_main._ui._joystick.output = Vector2(1, 0)
	for i in 20:
		await get_tree().process_frame
	d = _main._player.global_position - start
	d.y = 0
	if d.length() > 0.05:
		_t_right = d.normalized()
	_main._ui._joystick.output = Vector2.ZERO


func _set_joystick_arah(arah: Vector3) -> void:
	# Joystick untuk arah dunia (memakai basis kalibrasi).
	# Rumus test_v2: (ja, -jb) — Y joystick terbalik terhadap
	# forward (main.gd: move_dir = right*x + forward*(-y)).
	var ja := arah.dot(_t_right)
	var jb := arah.dot(_t_fwd)
	_main._ui._joystick.output = Vector2(ja, -jb)


func _taruh(pos: Vector3) -> void:
	# _teleport_player(pos, PI) — posisi + facing + snap kamera.
	# yaw PI -> _cam_yaw = 0, SAMA dengan yaw kalibrasi
	# (_masuk_pesantren juga _teleport_player(spawn, PI)), jadi
	# basis _t_fwd/_t_right tetap valid. Posisi langsung saja
	# (fix2) membuat pemain di kolong gubuk (1,7 m di ruang 1,32 m)
	# terjepit lantai — teleport resmi berperilaku seperti baseline.
	_main._teleport_player(pos, PI)
	for i in 3:
		await get_tree().process_frame


func _dorong(arah: Vector3, frame: int, pusat := Vector3.ZERO, lacak_pusat := false) -> Dictionary:
	var start: Vector3 = _main._player.global_position
	_set_joystick_arah(arah.normalized())
	var maks := 0.0
	var min_jarak := 9999.0
	for i in frame:
		await get_tree().process_frame
		var pp: Vector3 = _main._player.global_position
		var t: float = (pp - start).dot(arah)
		if t > maks:
			maks = t
		if lacak_pusat:
			var d2 := Vector2(pp.x - pusat.x, pp.z - pusat.z).length()
			if d2 < min_jarak:
				min_jarak = d2
	_main._ui._joystick.output = Vector2.ZERO
	var akhir: Vector3 = _main._player.global_position
	return {"tempuh": maks, "akhir": akhir, "min_jarak": min_jarak}


func _cek_tahan(nama: String, start: Vector3, arah: Vector3, jarak_muka: float, tol_atas: float = 0.1, frame: int = 90) -> void:
	await _taruh(start)
	var r: Dictionary = await _dorong(arah.normalized(), frame)
	var tempuh: float = r["tempuh"]
	var akhir: Vector3 = r["akhir"]
	var ideal := jarak_muka - 0.35
	var ok := tempuh >= ideal - 0.6 and tempuh <= ideal + tol_atas
	if ok:
		_lulus += 1
		print("LULUS: %s (tempuh=%.2f ideal=%.2f akhir=%s)" % [nama, tempuh, ideal, str(akhir)])
	else:
		_gagal += 1
		print("GAGAL: %s (tempuh=%.2f ideal=%.2f akhir=%s)" % [nama, tempuh, ideal, str(akhir)])


func _cek_tiang(nama: String, start: Vector3, arah: Vector3, pusat_objek: Vector3, jaga: float, frame: int = 150) -> void:
	# Tiang/pohon/pilar (kotak sempit): pemain yang didorong lurus
	# 1,5-2,5 dtk BISA tergelincir mengelilingi muka sempit (fisika
	# kontak — drive terbukti lurus, diag_drift lateral 0,00 m)
	# tanpa pernah MENEMBUS objek. Kriteria di sini: kapsul tidak
	# boleh menembus — jarak minimum pusat pemain ke pusat objek
	# (bidang XZ) harus >= jaga (setengah lebar muka + 0,35 kapsul
	# - 0,05 toleransi). Tembus (tanpa collision) = pemain lewat
	# sumbu objek, min_jarak ~0. Tergelincir mengelilingi =
	# min_jarak ~jaga+0,05 (muka) atau lebih (sudut). Tempuh hanya
	# info (defleksi, bukan kegagalan).
	await _taruh(start)
	var r: Dictionary = await _dorong(arah.normalized(), frame, pusat_objek, true)
	var min_jarak: float = r["min_jarak"]
	var tempuh: float = r["tempuh"]
	var akhir: Vector3 = r["akhir"]
	if min_jarak >= jaga:
		_lulus += 1
		print("LULUS: %s (min_jarak=%.2f >= jaga=%.2f; tempuh=%.2f info, akhir=%s)" % [nama, min_jarak, jaga, tempuh, str(akhir)])
	else:
		_gagal += 1
		print("GAGAL: %s (min_jarak=%.2f < jaga=%.2f TEMBUS; tempuh=%.2f akhir=%s)" % [nama, min_jarak, jaga, tempuh, str(akhir)])


func _cek_lewat(nama: String, start: Vector3, arah: Vector3, jarak: float, frame: int) -> void:
	await _taruh(start)
	var r: Dictionary = await _dorong(arah.normalized(), frame)
	var tempuh: float = r["tempuh"]
	var akhir: Vector3 = r["akhir"]
	var ok := tempuh > jarak + 1.0
	if ok:
		_lulus += 1
		print("LULUS: %s (tempuh=%.2f butuh>%.2f akhir=%s)" % [nama, tempuh, jarak + 1.0, str(akhir)])
	else:
		_gagal += 1
		print("GAGAL: %s (tempuh=%.2f butuh>%.2f akhir=%s)" % [nama, tempuh, jarak + 1.0, str(akhir)])


func _arah_interior_surau(dari_lokal: Vector3, ke_lokal: Vector3) -> Vector3:
	var a := InteriorSurau.ke_dunia(dari_lokal)
	var b := InteriorSurau.ke_dunia(ke_lokal)
	return (b - a).normalized()


func _cek_tahan_interior_surau(nama: String, dari_lokal: Vector3, ke_lokal: Vector3, jarak_muka: float, tol_atas: float = 0.1) -> void:
	var start := InteriorSurau.ke_dunia(dari_lokal)
	var arah := _arah_interior_surau(dari_lokal, ke_lokal)
	await _cek_tahan(nama, start, arah, jarak_muka, tol_atas)


func _cek_tiang_interior_surau(nama: String, dari_lokal: Vector3, ke_lokal: Vector3, pusat_lokal: Vector3, jaga: float) -> void:
	var start := InteriorSurau.ke_dunia(dari_lokal)
	var arah := _arah_interior_surau(dari_lokal, ke_lokal)
	var pusat := InteriorSurau.ke_dunia(pusat_lokal)
	await _cek_tiang(nama, start, arah, pusat, jaga)


func _arah_interior_cangkruk(dari: Vector3, ke: Vector3) -> Vector3:
	return (ke - dari).normalized()


func _cek_tahan_interior_cangkruk(nama: String, dari: Vector3, ke: Vector3, jarak_muka: float) -> void:
	await _cek_tahan(nama, dari, _arah_interior_cangkruk(dari, ke), jarak_muka)


func _arah_interior_musholla(dari_lokal: Vector3, ke_lokal: Vector3) -> Vector3:
	var a := InteriorMusholla.ke_dunia(dari_lokal)
	var b := InteriorMusholla.ke_dunia(ke_lokal)
	return (b - a).normalized()


func _cek_tahan_interior_musholla(nama: String, dari_lokal: Vector3, ke_lokal: Vector3, jarak_muka: float, tol_atas: float = 0.1) -> void:
	var start := InteriorMusholla.ke_dunia(dari_lokal)
	var arah := _arah_interior_musholla(dari_lokal, ke_lokal)
	await _cek_tahan(nama, start, arah, jarak_muka, tol_atas)


func _diag_pintu_taman() -> void:
	# (a) OTOMATIS, NPC diabaikan: pemain harus masuk (z>26) dalam 4 dtk.
	var pintu: Node = _main._pesantren["root"].find_child("PintuTaman", true, false)
	await _taruh(Vector3(0, 0, 20))
	for i in 240:
		# Dorong ke SELATAN dunia (+Z, ke arah taman) memakai basis
		# kalibrasi — bukan joystick mentah (0,-1) yang artinya
		# "maju kamera" dan bergantung yaw kamera saat itu.
		_set_joystick_arah(Vector3(0, 0, 1))
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var z1: float = _main._player.global_position.z
	var k1: float = pintu.kemajuan_buka() if pintu != null else -1.0
	if z1 > 26.0:
		_lulus += 1
		print("LULUS: pintu taman OTOMATIS (NPC abaikan): pemain masuk (z>26) (akhir z=%.2f kemajuan=%.2f)" % [z1, k1])
	else:
		_gagal += 1
		print("GAGAL: pintu taman OTOMATIS (NPC abaikan): pemain TIDAK masuk (akhir z=%.2f kemajuan=%.2f)" % [z1, k1])
	# (a2) OTOMATIS, NPC nyata: pintu tidak boleh membeku total.
	if pintu != null and pintu.has_method("set_abaikan_npc"):
		pintu.set_abaikan_npc(false)
	await _taruh(Vector3(0, 0, 20))
	for i in 240:
		# Dorong ke SELATAN dunia (+Z, ke arah taman) memakai basis
		# kalibrasi — bukan joystick mentah (0,-1) yang artinya
		# "maju kamera" dan bergantung yaw kamera saat itu.
		_set_joystick_arah(Vector3(0, 0, 1))
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var z2: float = _main._player.global_position.z
	var k2: float = pintu.kemajuan_buka() if pintu != null else -1.0
	if z2 > 26.0:
		_lulus += 1
		print("LULUS: pintu taman OTOMATIS (NPC nyata): pemain masuk (z>26) (akhir z=%.2f kemajuan=%.2f)" % [z2, k2])
	else:
		_gagal += 1
		print("GAGAL: pintu taman OTOMATIS (NPC nyata): pemain TIDAK masuk (akhir z=%.2f kemajuan=%.2f)" % [z2, k2])
	if pintu != null and pintu.has_method("set_abaikan_npc"):
		pintu.set_abaikan_npc(true)
	# (b) TAHAN TERBUKA: pemain sampai peti (z 26..27,4).
	if pintu != null and pintu.has_method("set_tahan_terbuka"):
		pintu.set_tahan_terbuka(true)
	await _taruh(Vector3(0, 0, 20))
	for i in 240:
		# Dorong ke SELATAN dunia (+Z, ke arah taman) memakai basis
		# kalibrasi — bukan joystick mentah (0,-1) yang artinya
		# "maju kamera" dan bergantung yaw kamera saat itu.
		_set_joystick_arah(Vector3(0, 0, 1))
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var z3: float = _main._player.global_position.z
	if z3 > 26.0 and z3 < 27.4:
		_lulus += 1
		print("LULUS: pintu taman TAHAN TERBUKA: sampai peti (z 26..27.4) (akhir z=%.2f)" % z3)
	else:
		_gagal += 1
		print("GAGAL: pintu taman TAHAN TERBUKA: akhir z=%.2f (harap 26..27.4)" % z3)
	if pintu != null and pintu.has_method("set_tahan_terbuka"):
		pintu.set_tahan_terbuka(false)
	# (c) TAHAN TERTUTUP: pemain tertahan (z 24,9..25,3).
	if pintu != null and pintu.has_method("set_tahan_tertutup"):
		pintu.set_tahan_tertutup(true)
	await _taruh(Vector3(0, 0, 20))
	for i in 240:
		# Dorong ke SELATAN dunia (+Z, ke arah taman) memakai basis
		# kalibrasi — bukan joystick mentah (0,-1) yang artinya
		# "maju kamera" dan bergantung yaw kamera saat itu.
		_set_joystick_arah(Vector3(0, 0, 1))
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	var z4: float = _main._player.global_position.z
	if z4 > 24.9 and z4 < 25.3:
		_lulus += 1
		print("LULUS: pintu taman TAHAN TERTUTUP: tertahan (z 24.9..25.3) (akhir z=%.2f)" % z4)
	else:
		_gagal += 1
		print("GAGAL: pintu taman TAHAN TERTUTUP: akhir z=%.2f (harap 24.9..25.3)" % z4)
	if pintu != null and pintu.has_method("set_tahan_tertutup"):
		pintu.set_tahan_tertutup(false)
