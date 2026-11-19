extends Node
## Tes WIRING ASRAMA PUTRA (Lestari, 18 Nov 2026) — headless:
##   ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --headless --path . skrip/test_wiring_putra.tscn
## Adaptasi test_wiring_putri.gd (salin persis kontraknya): tombol
## MASUK/KELUAR + jalan menembus pintu masuk/keluar + root terlihat/
## sembunyi + tidur Asrama (body nonaktif via collision_layer/mask 0
## + snap posisi_tidur_list + TIDAK JATUH (jepit _process) + aktif
## lagi saat bangun; kasur sendiri vs overflow vs save lama) +
## konsistensi ledger kasur putra (Cangkruk -> Asrama -> Surau)
## + peta (titik pemain di cangkang (-24,10)) + kamera Asrama
## (spring 5,5 m, pitch dijepit -0,22, FOV 65 — hanya di Asrama).
## Pintu LUAR (konsep, di-ACC Mas 09:37 WIB): lokasi (-24,10),
## tapak 18x12, pintu dinding barat (-33,10), keluar (-34,5,10).
## Pintu DALAM / spawn / beds dibaca runtime dari dict build
## InteriorAsramaPutra (Nadia) — TIDAK ada angka interior yang
## dikarang di sini. SCAFFOLD: bila interior belum mendarat
## (root null), hanya cek scaffold (konstanta pintu + guard +
## ledger) yang jalan, lalu berhenti dengan pesan jelas — bagian
## interior DITUNDA, bukan dianggap lulus.

var _main: Node
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _tombol() -> String:
	if not _main._ui._interact_btn.visible:
		return ""
	return String(_main._ui._interact_btn.text)


## Satu gedung penuh: tombol masuk -> masuk -> tombol keluar ->
## keluar -> jalan masuk -> jalan keluar.
func _tes_gedung(nama: String, tombol_masuk: String, tombol_keluar: String,
		spot_tombol_luar: Vector3, spot_jalan_luar: Vector3,
		spot_tombol_dalam: Vector3, spot_jalan_dalam: Vector3,
		pintu_keluar_luar: Vector3, flag: String, root_var: String) -> void:
	# Tombol MASUK di dekat pintu luar (di luar zona jalan-masuk).
	_main._teleport_player(spot_tombol_luar, 0.0)
	await _frames(10)
	_cek(nama + ": tombol " + tombol_masuk, _tombol() == tombol_masuk)
	_main._on_interact()
	await _frames(5)
	_cek(nama + ": masuk lewat tombol (flag)", bool(_main.get(flag)))
	_cek(nama + ": masuk lewat tombol (root terlihat)", bool(_main.get(root_var).visible))
	# Tombol KELUAR di dekat pintu dalam (di luar koridor jalan-keluar).
	_main._teleport_player(spot_tombol_dalam, 0.0)
	await _frames(10)
	_cek(nama + ": tombol " + tombol_keluar, _tombol() == tombol_keluar)
	_main._on_interact()
	await _frames(5)
	_cek(nama + ": keluar lewat tombol (flag mati)", not bool(_main.get(flag)))
	_cek(nama + ": keluar lewat tombol (root sembunyi)", not bool(_main.get(root_var).visible))
	_cek(nama + ": keluar lewat tombol (di exit luar)", _main._player.global_position.distance_to(pintu_keluar_luar) < 0.5)
	# Jalan menembus pintu luar -> masuk.
	_main._teleport_player(spot_jalan_luar, 0.0)
	await _frames(10)
	_cek(nama + ": masuk jalan menembus pintu", bool(_main.get(flag)))
	# Jalan menembus pintu dalam -> keluar.
	_main._teleport_player(spot_jalan_dalam, 0.0)
	await _frames(10)
	_cek(nama + ": keluar jalan menembus pintu", not bool(_main.get(flag)))
	_cek(nama + ": keluar jalan (di exit luar)", _main._player.global_position.distance_to(pintu_keluar_luar) < 0.5)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await _frames(3)
	# Santriwan (supaya _cek_batas tidak mendorong balik di area putra).
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Tes wiring putra")
	await _frames(3)
	_main._audio.mulai()

	# ---------- scaffold (jalan TANPA interior Nadia) ----------
	_cek("Pintu luar (-33,10)", _main._asrama_putra_door_luar == Vector3(-33, 0, 10))
	_cek("Keluar luar (-34.5,10)", _main._asrama_putra_exit == Vector3(-34.5, 0, 10))
	_cek("Pusat cangkang (-24,10)", _main._asrama_putra_pos == Vector3(-24, 0, 10))
	# Guard: interior belum ada -> _masuk menolak (flag mati, tidak
	# teleport ke mana-mana) dan _cek_pintu tidak bereaksi.
	if _main._asrama_putra_root == null:
		_cek("Scaffold: root null sebelum interior mendarat", _main._asrama_putra_root == null)
		var pos_awal: Vector3 = _main._player.global_position
		_main._masuk_asrama_putra()
		await _frames(3)
		_cek("Scaffold: _masuk ditolak saat root null (flag mati)", not _main._di_dalam_asrama_putra)
		_cek("Scaffold: _masuk ditolak saat root null (tidak teleport)", _main._player.global_position.distance_to(pos_awal) < 0.5)
		_main._teleport_player(Vector3(-33.8, 0, 10), 0.0)
		await _frames(10)
		_cek("Scaffold: jalan menembus pintu tidak bereaksi saat root null", not _main._di_dalam_asrama_putra)
		# Ledger putra (tidak butuh interior — logika murni).
		var ledger_s := {"versi": 1, "tugas": {}}
		for i in range(1, 11):
			PembagianKasur.buat_tugas("PV-TES-PUTRA-%02d" % i, "putra", ledger_s)
		var t11 := PembagianKasur.buat_tugas("PV-TES-PUTRA-11", "putra", ledger_s)
		_cek("Scaffold ledger: putra 11 -> Asrama Putra A-PUTRA-001",
			String(t11.get("gedung", "")) == "Asrama Putra" and String(t11.get("kasur_id", "")) == "A-PUTRA-001")
		var t107 := {}
		for i in range(12, 108):
			t107 = PembagianKasur.buat_tugas("PV-TES-PUTRA-%03d" % i, "putra", ledger_s)
		_cek("Scaffold ledger: putra 107 -> Surau (overflow setelah 96 Asrama)", String(t107.get("gedung", "")) == "Surau")
		print("TES WIRING PUTRA: SCAFFOLD lulus %d, gagal %d — INTERIOR BELUM DIUJI (menunggu interior_asrama_putra.gd Nadia)" % [_lulus, _gagal])
		get_tree().quit(0 if _gagal == 0 else 1)
		return

	# ---------- struktur wiring (butuh interior) ----------
	var pintu_dalam: Vector3 = _main._asrama_putra_interior_door
	var spawn_dalam: Vector3 = _main._asrama_putra_interior_spawn
	var scr_putra = load("res://scripts/interior_asrama_putra.gd")
	_cek("Asrama Putra: root ada + sembunyi", _main._asrama_putra_root != null and not _main._asrama_putra_root.visible)
	_cek("Asrama Putra: pintu dalam = INTERIOR_DOOR Nadia", pintu_dalam == scr_putra.INTERIOR_DOOR)
	_cek("Asrama Putra: spawn dalam = INTERIOR_SPAWN Nadia", spawn_dalam == scr_putra.INTERIOR_SPAWN)
	_cek("Asrama Putra: 96 posisi tidur", _main._asrama_putra_beds.size() == 96)
	_cek("Asrama Putra: 48 body kasur (1 per unit)", _main._asrama_putra_kasur_bodies.size() == 48)

	# ---------- gedung penuh (tombol + jalan) ----------
	await _tes_gedung("Asrama Putra", "MASUK ASRAMA PUTRA", "KELUAR ASRAMA PUTRA",
		Vector3(-35.8, 0, 10), Vector3(-33.8, 0, 10),
		spawn_dalam, pintu_dalam + Vector3(-0.8, 0, 0),
		Vector3(-34.5, 0, 10), "_di_dalam_asrama_putra", "_asrama_putra_root")

	# ---------- hanya satu interior terlihat dalam satu waktu ----------
	_main._masuk_asrama_putra()
	await _frames(3)
	_cek("Satu interior: Asrama Putra terlihat, Asrama Putri+Musholla sembunyi",
		_main._asrama_putra_root.visible and not _main._asrama_putri_root.visible and not _main._musholla_root.visible)
	# Kamera Asrama (kontrak Putri): FOV 65 di dalam; spring tidak
	# boleh melebihi target 5,5 m (tembok boleh memendekkannya —
	# itu tugas _jarak_kamera_aman; yang dicek di sini: target
	# Asrama dipakai, bukan 7,0 luar). 60 frame supaya spring
	# (memendek cepat) menetap dulu.
	await _frames(60)
	_cek("Kamera Asrama Putra: FOV 65", absf(_main._cam.fov - 65.0) < 0.5)
	_cek("Kamera Asrama Putra: spring <= 5,5 m (target Asrama)",
		_main._spring.spring_length <= 5.5 + 0.6)
	_main._keluar_asrama_putra()
	await _frames(3)
	_cek("Semua interior sembunyi setelah keluar",
		not _main._asrama_putra_root.visible and not _main._asrama_putri_root.visible and not _main._musholla_root.visible and not _main._interior_root.visible)
	# Kamera kembali normal di luar (spring 7,0 luar / FOV 60).
	_cek("Kamera luar: FOV 60", absf(_main._cam.fov - 60.0) < 0.5)

	# ---------- tidur Asrama: kasur sendiri bawah (A-PUTRA-001) ----------
	_main._kasur_saya = {"kasur_id": "A-PUTRA-001", "gedung": "Asrama Putra", "kamar": "Kamar 001", "susun": 1, "tingkat": "bawah", "fisik": false}
	_main._masuk_asrama_putra()
	await _frames(3)
	var tidur1: Vector3 = _main._asrama_putra_beds[0]
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama Putra: dekat kasur sendiri (001)", _main._dekat_tempat_tidur())
	_cek("Asrama Putra: tombol TIDUR", _tombol() == "TIDUR")
	_main._on_interact()
	await _frames(5)
	_cek("Asrama Putra: pose tidur", _main._player.aksi_saat_ini() == "tidur")
	_cek("Asrama Putra: snap ke posisi_tidur_list[0]", _main._player.global_position.distance_to(tidur1) < 0.05)
	_cek("Asrama Putra: body kasur 001 nonaktif", (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_layer == 0 and (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_mask == 0)
	_cek("Asrama Putra: idx tidur tercatat 1", _main._kasur_tidur_idx == 1)
	await _frames(60)
	_cek("Asrama Putra: TIDAK JATUH saat tidur (y tetap)", absf(_main._player.global_position.y - tidur1.y) < 0.05)
	_main._on_aksi("berdiri")
	await _frames(5)
	_cek("Asrama Putra: bangun -> pose berdiri", _main._player.aksi_saat_ini() == "berdiri")
	_cek("Asrama Putra: body kasur 001 aktif lagi", (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_layer == 1 and (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_mask == 1)
	# Prioritas: di koridor (lebih dekat pintu daripada kasur) -> KELUAR.
	# (Pola Putri: +2,9 dari kasur sampai koridor, relatif terhadap OFFSET.)
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 2.9), 0.0)
	await _frames(10)
	_cek("Asrama Putra: di koridor tombol KELUAR (lebih dekat pintu)", _tombol() == "KELUAR ASRAMA PUTRA")

	# ---------- tidur Asrama: kasur sendiri atas (A-PUTRA-002, y 1,65) ----------
	_main._kasur_saya = {"kasur_id": "A-PUTRA-002", "gedung": "Asrama Putra", "kamar": "Kamar 001", "susun": 1, "tingkat": "atas", "fisik": false}
	var tidur2: Vector3 = _main._asrama_putra_beds[1]
	_main._teleport_player(Vector3(tidur2.x, 0, tidur2.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama Putra atas: dekat kasur sendiri (002)", _main._dekat_tempat_tidur())
	_main._on_interact()
	await _frames(5)
	_cek("Asrama Putra atas: snap y 1,65", absf(_main._player.global_position.y - tidur2.y) < 0.05 and absf(tidur2.y - 1.65) < 0.01)
	_cek("Asrama Putra atas: body unit yang SAMA nonaktif", (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_layer == 0 and (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_mask == 0)
	_cek("Asrama Putra atas: kapsul dikecilkan 0,8 (muat di bawah pelat)", absf(_main._player_capsule.height - 0.8) < 0.01)
	await _frames(60)
	_cek("Asrama Putra atas: TIDAK JATUH saat tidur (y tetap)", absf(_main._player.global_position.y - tidur2.y) < 0.05)
	# Bangun lewat GERAK (bukan tombol) — _process memanggil _on_aksi("berdiri").
	_main._ui._joystick.output = Vector2(0, -1)
	await _frames(10)
	_main._ui._joystick.output = Vector2.ZERO
	_cek("Asrama Putra atas: bangun lewat gerak", _main._player.aksi_saat_ini() == "berdiri")
	_cek("Asrama Putra atas: body aktif lagi", (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_layer == 1 and (_main._asrama_putra_kasur_bodies[0] as StaticBody3D).collision_mask == 1)
	_cek("Asrama Putra atas: kapsul kembali 1,7", absf(_main._player_capsule.height - 1.7) < 0.01)

	# ---------- tidur Asrama: overflow Surau TIDAK boleh tidur di Asrama ----------
	_main._kasur_saya = {"kasur_id": "S-PUTRA-01", "gedung": "Surau", "kamar": "", "susun": 0, "tingkat": "", "fisik": false}
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama Putra: overflow Surau tidak bisa tidur di Asrama", not _main._dekat_tempat_tidur())
	# ---------- tidur Asrama: save lama tanpa tugas = kasur terdekat ----------
	_main._kasur_saya = {}
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama Putra: save lama dekat kasur mana saja", _main._dekat_tempat_tidur())
	_main._on_interact()
	await _frames(5)
	_cek("Asrama Putra: save lama bisa tidur (kasur terdekat)", _main._player.aksi_saat_ini() == "tidur" and _main._kasur_tidur_idx == 1)
	_main._on_aksi("berdiri")
	await _frames(3)
	_main._keluar_asrama_putra()
	await _frames(3)

	# ---------- konsistensi ledger kasur putra ----------
	var ledger := {"versi": 1, "tugas": {}}
	for i in range(1, 11):
		PembagianKasur.buat_tugas("PV-TES-LESTARI-P%02d" % i, "putra", ledger)
	var t1 := PembagianKasur.buat_tugas("PV-TES-LESTARI-P11", "putra", ledger)
	_cek("Ledger: putra 11 -> Asrama Putra A-PUTRA-001", String(t1.get("gedung", "")) == "Asrama Putra" and String(t1.get("kasur_id", "")) == "A-PUTRA-001")
	var t2 := PembagianKasur.buat_tugas("PV-TES-LESTARI-P12", "putra", ledger)
	_cek("Ledger: putra 12 -> A-PUTRA-002", String(t2.get("kasur_id", "")) == "A-PUTRA-002")
	var ids: Array = scr_putra.kasur_id_list()
	_cek("Ledger x interior: id kasur sama (001/002)", String(ids[0]) == "A-PUTRA-001" and String(ids[1]) == "A-PUTRA-002")
	# Putra 11 = tugas non-fisik ke-6 yang memakai titik Surau
	# (5 titik pertama dipakai Cangkruk atas 06-10) -> spot [5],
	# bukan [0] seperti putri (putri 1 = tugas pertama -> [0]).
	_cek("Ledger: posisi tidur putra 11 = titik Surau ke-6 (fallback, tidak berubah)",
		PembagianKasur.posisi_tidur(t1) != Vector3.INF and PembagianKasur.posisi_tidur(t1).distance_to(PembagianKasur.tempat_tidur_surau()[5]) < 0.01)
	var t107 := {}
	for i in range(13, 108):
		t107 = PembagianKasur.buat_tugas("PV-TES-LESTARI-P%03d" % i, "putra", ledger)
	_cek("Ledger: putra 107 -> Surau (overflow setelah 96 Asrama)", String(t107.get("gedung", "")) == "Surau")

	# ---------- peta: titik pemain di cangkang saat di interior ----------
	_main._masuk_asrama_putra()
	await _frames(3)
	var peta: Dictionary = _main._data_peta()
	_cek("Peta: di Asrama Putra -> titik di cangkang (-24,10)",
		(peta["player"] as Vector2).distance_to(Vector2(-24, 10)) < 0.01)
	_main._keluar_asrama_putra()
	await _frames(3)

	print("TES WIRING PUTRA: lulus %d, gagal %d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
