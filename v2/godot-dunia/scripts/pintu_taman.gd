class_name PintuTaman
extends Node3D
## PINTU PAGAR TAMAN — Gilang (Tim Maps), 17 Nov 2026.
##
## TEMUAN UKUR (dump GLB + probe headless, sebelum perbaikan):
## - Segmen pagar-bambu.glb: panel bambu 3,61 m (x -1,915..1,695,
##   y 0..1,5) + rangka jati 4,17 m (x -2,09..2,09, y 0..1,76).
##   10 segmen menutup keliling taman (utara/selatan z 25,5/31,5,
##   barat/timur x -6,5/6,5) secara VISUAL — tapi 0 StaticBody3D
##   di bawah GLB mana pun: pemain TEMBUS dari mana saja.
## - Celah visual kecil: antar panel 0,39 m (hanya rangka jati) +
##   sudut pagar (±6,09 vs dinding samping ±6,5) — terlalu sempit
##   untuk kapsul r=0,35, tapi tetap ditutup collision di sini.
## - Jalan batu taman (GLB_Taman) lurus dari sisi utara (z 25,3)
##   ke tengah taman — pintu ditaruh di sisi UTARA, tengah (0,25,5),
##   segaris spawn (-4,14) + peti (0,28) di dalam pagar (peti
##   dipindah (0,26)->(0,28) 18 Nov 2026 — peti lama mentok di
##   muka pintu, pemain tak bisa masuk; lihat PETI_POS builder).
##
## YANG MODUL INI LAKUKAN (SEMUA tanpa ubah file GLB):
##  1. Pintu GESER bambu 2,0 m (bilah + rel jati, senada pagar) di
##     bukaan utara x -1..1 — menggantikan segmen GLB tengah utara
##     (dihapus builder). Tiang jati di x ±1,05 + balok atas +
##     label "TAMAN" dua sisi (preseden gerbang (14,0)).
##  2. Pintu TERBUKA OTOMATIS saat pemain/NPC mendekat (<= 4,0 m)
##     dan MENUTUP sendiri 1,2 dtk setelah semua menjauh (> 5,0 m).
##     Dipilih pemicu-proksimitas (bukan tombol interact) karena:
##     (a) pintu game lain (Surau/Musholla/Cangkruk) utamanya jalan
##     tembus/pemicu, tombol cuma cadangan; (b) taman bukan ruangan
##     — tak ada kunci/alasan menahan pemain di depan pagar;
##     (c) TANPA edit main.gd/ui.gd (batas file ronde ini) — modul
##     mandiri, cukup pasang dari builder; (d) waypoint NPC (0,30)
##     tepat di sumbu pintu — NPC yang menuju taman ikut membuka
##     pintu, bukan menembus pagar.
##  3. Anti-tembus (reel @jipraks): pintu geser ke TIMUR (bukan
##     ayun — daun ayun 2 m akan menyapu peti (0,28) + jalur batu);
##     geser di bidang z=25,72 (0,14 m di selatan rel pagar, tanpa
##     intersection visual); collision daun ikut bergeser; saat
##     tertutup celah TERTUTUP PENUH (collision 2,0 m). Jalur geser
##     timur (x 1,0..3,3, z 25,2..26,2) dicek kosong sebelum pintu
##     bergerak — pintu menahan diri daripada mendorong pemain.
##     Collision pagar keliling (5 kotak, termasuk ujung panel yang
##     menjorok) dipasang builder di _pagar_taman — lihat sana.
##
## Pemasangan (di PesantrenBuilder._lingkungan_glb, setelah loop GLB):
##   PintuTaman.pasang(root)
## Idempotent: kalau sudah terpasang (ada anak "PintuTaman"), lewati.
##
## Hook tes/foto (dipakai test_v2 + foto_pintu_taman):
##   buka_paksa() / tutup_paksa() — set target + loncat ke ujung.
##   set_tahan_terbuka(v) / set_tahan_tertutup(v) — kunci keadaan,
##   logika otomatis dimatikan selama terkunci.
##   set_abaikan_npc(v) — kalau true, NPC TIDAK dihitung sebagai
##   aktor pemicu (18 Nov 2026: NPC yang kebetulan lewat waypoint
##   (0,30) / melintas gerbang menahan pintu terbuka, membuat tes
##   tutup-otomatis tidak deterministik). HANYA untuk tes — perilaku
##   game (NPC ikut membuka pintu) TIDAK berubah.

## Geometri pintu (diukur dari GLB, lihat header).
const PUSAT := Vector3(0, 0, 25.5)
const LEBAR_BUKAAN := 2.0
const GESER_X := 2.1
const GESER_Z := 0.22
const TINGGI_DAUN := 1.5
## Pemicu + gerak.
## RONDE EXPORT BERIKUTNYA (Gilang, 18 Nov 2026 — temuan Bagas,
## audit tabrakan): pintu lama butuh ~1,3 dtk membuka (1,6 m/dtk x
## 2,11 m) sementara pemain 6 m/dtk tiba dalam ~0,43 dtk dari
## JARAK_BUKA 2,6 m — menunggu ~1 dtk di gerbang, di HP terasa
## "kehalang benda". Perbaikan: buka LEBIH AWAL (JARAK_BUKA 2,6 ->
## 4,0 m: pemain tiba 0,67 dtk setelah pemicu) + LEBIH CEPAT
## (KECEPATAN_GESER 1,6 -> 3,2 m/dtk: buka penuh 0,66 dtk, celah
## cukup untuk kapsul r=0,35 tercapai ~0,42 dtk) — pemain jalan
## normal TIDAK menunggu di gerbang. JARAK_TAHAN ikut naik 3,6 ->
## 5,0 m supaya histeresis buka/tahan tetap terjaga (tahan > buka).
## Tutup-otomatis (TUTUP_TUNDA 1,2 dtk) + hook set_abaikan_npc
## TIDAK berubah; jalur_terhalang tetap menahan daun (anti-tembus:
## pintu menahan diri daripada mendorong pemain/NPC — lihat _process).
const JARAK_BUKA := 4.0
const JARAK_TAHAN := 5.0
const TUTUP_TUNDA := 1.2
const KECEPATAN_GESER := 3.2
## Warna: BAMBU = baseColorFactor L_bambu GLB (0.694, 0.451, 0.144);
## JATI dari Palette (sama dengan rangka pagar).
const BAMBU := Color("#b17325")
const EMAS_LABEL := Color("#f2c14e")

var _daun: Node3D
var _kemajuan := 0.0
var _target_buka := false
var _waktu_tanpa_aktor := 0.0
var _tahan_terbuka := false
var _tahan_tertutup := false
var _abaikan_npc := false
var _main_ref: Node = null


static func pasang(root: Node3D) -> void:
	if root == null:
		push_error("PintuTaman: root null")
		return
	if root.find_child("PintuTaman", false, false) != null:
		return
	var m := PintuTaman.new()
	m.name = "PintuTaman"
	root.add_child(m)
	m._bangun()


func _bangun() -> void:
	# --- Tiang jati di kedua tepi bukaan (x ±1,05) + tutup emas ---
	# Collision tiang: kotak 0,2 m — bukaan efektif 1,92 m (kapsul
	# 0,70 m tetap lewat longgar).
	var tiang_body := StaticBody3D.new()
	tiang_body.name = "PintuTaman_Tiang"
	add_child(tiang_body)
	for sx in [-1.05, 1.05]:
		add_child(Palette.cylinder(0.09, 0.09, 1.76, Vector3(sx, 0.88, PUSAT.z), Palette.JATI))
		var tutup := Palette.sphere(0.11, Vector3(sx, 1.8, PUSAT.z), Palette.EMAS_DESAIN)
		tutup.scale = Vector3(1.0, 0.6, 1.0)
		add_child(tutup)
		var col := CollisionShape3D.new()
		var kotak := BoxShape3D.new()
		kotak.size = Vector3(0.2, 1.76, 0.2)
		col.shape = kotak
		col.position = Vector3(sx, 0.88, PUSAT.z)
		tiang_body.add_child(col)
	# --- Balok atas (mini gapura) + label TAMAN dua sisi ---
	add_child(Palette.box(Vector3(2.3, 0.12, 0.14), Vector3(0, 1.85, PUSAT.z), Palette.JATI))
	var label_u := Palette.label3d("TAMAN", Vector3(0, 2.04, PUSAT.z - 0.06), 32, EMAS_LABEL, false)
	label_u.name = "LabelTamanUtara"
	label_u.rotation.y = PI
	add_child(label_u)
	var label_s := Palette.label3d("TAMAN", Vector3(0, 2.04, PUSAT.z + 0.06), 32, EMAS_LABEL, false)
	label_s.name = "LabelTamanSelatan"
	add_child(label_s)
	# --- Panel pengisi di kiri-kanan pintu (x -1,91..-1 dan 1..1,91):
	# bilah bambu + rel jati, menutup sisa segmen GLB yang dilepas.
	# Collision-nya sudah ditutup kotak pagar utara (builder).
	for x0 in [-1.91, 1.0]:
		_bangun_panel_pengisi(x0)
	# --- Daun pintu geser (anak Node3D yang bergerak) ---
	_daun = Node3D.new()
	_daun.name = "PintuTaman_Daun"
	_daun.position = PUSAT
	add_child(_daun)
	for i in 9:
		var x := -0.88 + float(i) * 0.22
		_daun.add_child(Palette.cylinder(0.045, 0.045, TINGGI_DAUN, Vector3(x, TINGGI_DAUN * 0.5, 0), BAMBU))
	_daun.add_child(Palette.box(Vector3(LEBAR_BUKAAN, 0.12, 0.06), Vector3(0, 0.15, 0), Palette.JATI))
	_daun.add_child(Palette.box(Vector3(LEBAR_BUKAAN, 0.12, 0.06), Vector3(0, 1.35, 0), Palette.JATI))
	_daun.add_child(Palette.box(Vector3(LEBAR_BUKAAN, 0.09, 0.05), Vector3(0, 0.75, 0), Palette.JATI))
	# Gagang di tepi timur, sisi utara (arah pemain datang).
	var gagang := Palette.cylinder(0.03, 0.03, 0.25, Vector3(0.8, 1.0, -0.15), BAMBU)
	gagang.rotation.x = PI * 0.5
	_daun.add_child(gagang)
	# Collision daun: ikut bergeser bersama visual.
	var body := StaticBody3D.new()
	body.name = "PintuTaman_DaunCollision"
	_daun.add_child(body)
	var col := CollisionShape3D.new()
	var kotak := BoxShape3D.new()
	kotak.size = Vector3(LEBAR_BUKAAN, TINGGI_DAUN, 0.12)
	col.shape = kotak
	col.position = Vector3(0, TINGGI_DAUN * 0.5, 0)
	body.add_child(col)


func _bangun_panel_pengisi(x0: float) -> void:
	# Panel 0,91 m: 5 bilah bambu + 2 rel jati (y 0,35 / 1,15).
	for i in 5:
		var x := x0 + 0.09 + float(i) * 0.18
		add_child(Palette.cylinder(0.045, 0.045, TINGGI_DAUN, Vector3(x, TINGGI_DAUN * 0.5, PUSAT.z), BAMBU))
	add_child(Palette.box(Vector3(0.91, 0.09, 0.05), Vector3(x0 + 0.455, 0.35, PUSAT.z), Palette.JATI))
	add_child(Palette.box(Vector3(0.91, 0.09, 0.05), Vector3(x0 + 0.455, 1.15, PUSAT.z), Palette.JATI))


## Kemajuan geser 0 (tertutup) .. 1 (terbuka penuh).
func kemajuan_buka() -> float:
	return _kemajuan


func apakah_terbuka() -> bool:
	return _kemajuan > 0.95


func apakah_tertutup() -> bool:
	return _kemajuan < 0.05


func buka_paksa() -> void:
	_target_buka = true
	_kemajuan = 1.0
	_terapkan_posisi()


func tutup_paksa() -> void:
	_target_buka = false
	_kemajuan = 0.0
	_terapkan_posisi()


func set_tahan_terbuka(v: bool) -> void:
	_tahan_terbuka = v
	if v:
		_tahan_tertutup = false
		buka_paksa()


func set_tahan_tertutup(v: bool) -> void:
	_tahan_tertutup = v
	if v:
		_tahan_terbuka = false
		tutup_paksa()


## Hook tes: abaikan NPC sebagai aktor pemicu (lihat header).
## Tidak mengubah perilaku game — default false.
func set_abaikan_npc(v: bool) -> void:
	_abaikan_npc = v


func _terapkan_posisi() -> void:
	if _daun == null:
		return
	_daun.position = PUSAT + Vector3(GESER_X * _kemajuan, 0, GESER_Z * _kemajuan)


func _cari_main() -> Node:
	if _main_ref != null and is_instance_valid(_main_ref):
		return _main_ref
	var n := get_parent()
	while n != null:
		if n.get("_player") != null:
			_main_ref = n
			return n
		n = n.get_parent()
	return null


func _posisi_aktor() -> Array[Vector3]:
	var hasil: Array[Vector3] = []
	var m := _cari_main()
	if m == null:
		return hasil
	var pemain: Node3D = m.get("_player")
	if pemain != null and is_instance_valid(pemain):
		hasil.append(pemain.global_position)
	if _abaikan_npc:
		return hasil
	var npcs: Array = m.get("_npcs")
	if npcs != null:
		for npc in npcs:
			if npc != null and is_instance_valid(npc):
				hasil.append((npc as Node3D).global_position)
	return hasil


func _di_jalur_geser(p: Vector3) -> bool:
	# Zona yang disapu daun saat geser ke timur (di DALAM taman):
	# x 1,0..3,3, z 25,2..26,2. Jalur masuk (x -1..1) sengaja TIDAK
	# termasuk — pemain yang berdiri di ambang tidak boleh membuat
	# pintu macet tertutup (ia didorong pelan ke selatan, bukan
	# ditembus — lihat header).
	return p.x > 1.0 and p.x < 3.3 and p.z > 25.2 and p.z < 26.2


func _process(delta: float) -> void:
	if _tahan_terbuka or _tahan_tertutup:
		return
	var aktor := _posisi_aktor()
	var dekat := false
	var tahan := false
	var jalur_terhalang := false
	for p in aktor:
		var d := Vector2(p.x - PUSAT.x, p.z - PUSAT.z).length()
		if d <= JARAK_BUKA:
			dekat = true
		if d <= JARAK_TAHAN:
			tahan = true
		if _di_jalur_geser(p):
			jalur_terhalang = true
	if dekat:
		_target_buka = true
		_waktu_tanpa_aktor = 0.0
	elif not tahan:
		_waktu_tanpa_aktor += delta
		if _waktu_tanpa_aktor >= TUTUP_TUNDA:
			_target_buka = false
	else:
		_waktu_tanpa_aktor = 0.0
	# Jangan bergerak kalau ada yang berdiri di jalur geser.
	var target := 1.0 if _target_buka else 0.0
	if jalur_terhalang and not is_equal_approx(_kemajuan, target):
		return
	if is_equal_approx(_kemajuan, target):
		return
	var langkah := KECEPATAN_GESER * delta / Vector2(GESER_X, GESER_Z).length()
	if target > _kemajuan:
		_kemajuan = minf(target, _kemajuan + langkah)
	else:
		_kemajuan = maxf(target, _kemajuan - langkah)
	_terapkan_posisi()
