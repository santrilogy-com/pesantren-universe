extends Node
## Tes WIRING INTERIOR PUTRI (Lestari, 18 Nov 2026) — headless:
##   ~/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64 --headless --path . skrip/test_wiring_putri.tscn
## Cek: rak spots 6 (Surau 2 + Musholla 2 + Kelas 2) + 6 interior
## ter-wiring (tombol MASUK/KELUAR + jalan menembus pintu masuk/
## keluar + root terlihat/sembunyi + Musholla regresi) + tidur
## Asrama (body nonaktif via collision_layer/mask 0 + snap
## posisi_tidur_list + TIDAK JATUH (jepit _process) + aktif lagi
## saat bangun; kasur sendiri vs overflow vs save lama)
## + reader di Kelas + konsistensi ledger kasur putri (Asrama ->
## Musholla overflow, TIDAK diubah wiring ini).

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
	# Santriwati (supaya _cek_batas tidak mendorong balik di area putri).
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes wiring putri")
	await _frames(3)
	_main._audio.mulai()

	# ---------- struktur wiring ----------
	_cek("Rak spots = 6 (2 Surau + 2 Musholla + 2 Kelas)", _main._rak_spots.size() == 6)
	_cek("Kelas: root ada + sembunyi", _main._kelas_putri_root != null and not _main._kelas_putri_root.visible)
	_cek("Asrama: root ada + sembunyi", _main._asrama_putri_root != null and not _main._asrama_putri_root.visible)
	_cek("Kantor: root ada + sembunyi", _main._kantor_root != null and not _main._kantor_root.visible)
	_cek("Madrasah: root ada + sembunyi", _main._madrasah_root != null and not _main._madrasah_root.visible)
	_cek("Studio: root ada + sembunyi", _main._studio_root != null and not _main._studio_root.visible)
	_cek("Pos Jaga: root ada + sembunyi", _main._pos_jaga_root != null and not _main._pos_jaga_root.visible)
	_cek("Kelas: pintu dalam (120,-297)", _main._kelas_putri_interior_door == Vector3(120, 0, -297))
	_cek("Asrama: pintu dalam (-249,-300)", _main._asrama_putri_interior_door == Vector3(-249, 0, -300))
	_cek("Kantor: pintu dalam (-124,-300)", _main._kantor_interior_door == Vector3(-124, 0, -300))
	_cek("Madrasah: pintu dalam (-185,-300)", _main._madrasah_interior_door == Vector3(-185, 0, -300))
	_cek("Studio: pintu dalam (240,-304)", _main._studio_interior_door == Vector3(240, 0, -304))
	_cek("Pos Jaga: pintu dalam (178.5,-300)", _main._pos_jaga_interior_door == Vector3(178.5, 0, -300))
	_cek("Asrama: 96 posisi tidur", _main._asrama_putri_beds.size() == 96)
	_cek("Asrama: 48 body kasur (1 per unit)", _main._asrama_putri_kasur_bodies.size() == 48)

	# ---------- regresi Musholla (SUDAH ter-wiring — verifikasi saja) ----------
	_main._teleport_player(Vector3(134, 0, -18.2), 0.0)
	await _frames(10)
	_cek("Musholla: masuk jalan menembus pintu (regresi)", _main._di_dalam_musholla)
	_main._teleport_player(Vector3(59.7, 0, -295.3), 0.0)
	await _frames(10)
	_cek("Musholla: keluar jalan menembus pintu (regresi)", not _main._di_dalam_musholla and _main._player.global_position.distance_to(Vector3(134, 0, -17.5)) < 0.5)

	# ---------- 6 gedung putri ----------
	await _tes_gedung("Kelas Putri", "MASUK KELAS PUTRI", "KELUAR KELAS PUTRI",
		Vector3(130, 0, 16.8), Vector3(130, 0, 14.7),
		Vector3(120, 0, -298.5), Vector3(120, 0, -296.2),
		Vector3(130, 0, 15.5), "_di_dalam_kelas_putri", "_kelas_putri_root")
	await _tes_gedung("Asrama Putri", "MASUK ASRAMA PUTRI", "KELUAR ASRAMA PUTRI",
		Vector3(143.2, 0, 9), Vector3(145.2, 0, 9),
		Vector3(-247.5, 0, -300), Vector3(-249.8, 0, -300),
		Vector3(144.5, 0, 9), "_di_dalam_asrama_putri", "_asrama_putri_root")
	await _tes_gedung("Kantor Ustadzah", "MASUK KANTOR USTADZAH", "KELUAR KANTOR USTADZAH",
		Vector3(141.2, 0, -33), Vector3(143.2, 0, -33),
		Vector3(-122.5, 0, -300), Vector3(-124.8, 0, -300),
		Vector3(142.5, 0, -33), "_di_dalam_kantor", "_kantor_root")
	await _tes_gedung("Madrasah", "MASUK MADRASAH", "KELUAR MADRASAH",
		Vector3(144.2, 0, -12), Vector3(146.2, 0, -12),
		Vector3(-183.5, 0, -300), Vector3(-185.8, 0, -300),
		Vector3(145.5, 0, -12), "_di_dalam_madrasah", "_madrasah_root")
	await _tes_gedung("Studio", "MASUK STUDIO", "KELUAR STUDIO",
		Vector3(166, 0, -18.8), Vector3(166, 0, -16.7),
		Vector3(240, 0, -302.5), Vector3(240, 0, -304.8),
		Vector3(166, 0, -17.5), "_di_dalam_studio", "_studio_root")
	await _tes_gedung("Pos Jaga", "MASUK POS JAGA", "KELUAR POS JAGA",
		Vector3(171.7, 0, -20), Vector3(173.7, 0, -20),
		Vector3(179.6, 0, -299.6), Vector3(177.7, 0, -300),
		Vector3(173, 0, -20), "_di_dalam_pos_jaga", "_pos_jaga_root")

	# ---------- hanya satu interior terlihat dalam satu waktu ----------
	_main._masuk_kelas_putri()
	await _frames(3)
	_cek("Satu interior: Kelas terlihat, Asrama+Musholla sembunyi",
		_main._kelas_putri_root.visible and not _main._asrama_putri_root.visible and not _main._musholla_root.visible)
	_main._keluar_kelas_putri()
	await _frames(3)
	_cek("Semua interior sembunyi setelah keluar",
		not _main._kelas_putri_root.visible and not _main._asrama_putri_root.visible and not _main._musholla_root.visible and not _main._interior_root.visible)

	# ---------- reader di Kelas ----------
	_main._masuk_kelas_putri()
	await _frames(3)
	var rak_kelas: Vector3 = _main._rak_spots[4]
	_main._teleport_player(rak_kelas, 0.0)
	await _frames(10)
	_cek("Kelas: dekat rak", _main._dekat_rak())
	_cek("Kelas: tombol BACA KITAB", _tombol() == "BACA KITAB")
	_main._on_interact()
	await _frames(3)
	_cek("Kelas: reader terbuka", _main._ui.is_baca_buku_visible())
	_main._ui.close_baca_buku()
	_main._keluar_kelas_putri()
	await _frames(3)

	# ---------- tidur Asrama: kasur sendiri bawah (A-PUTRI-001) ----------
	_main._kasur_saya = {"kasur_id": "A-PUTRI-001", "gedung": "Asrama Putri", "kamar": "Kamar 001", "susun": 1, "tingkat": "bawah", "fisik": false}
	_main._masuk_asrama_putri()
	await _frames(3)
	var tidur1: Vector3 = _main._asrama_putri_beds[0]
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama: dekat kasur sendiri (001)", _main._dekat_tempat_tidur())
	_cek("Asrama: tombol TIDUR", _tombol() == "TIDUR")
	_main._on_interact()
	await _frames(5)
	_cek("Asrama: pose tidur", _main._player.aksi_saat_ini() == "tidur")
	_cek("Asrama: snap ke posisi_tidur_list[0]", _main._player.global_position.distance_to(tidur1) < 0.05)
	_cek("Asrama: body kasur 001 nonaktif", (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_layer == 0 and (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_mask == 0)
	_cek("Asrama: idx tidur tercatat 1", _main._kasur_tidur_idx == 1)
	await _frames(60)
	_cek("Asrama: TIDAK JATUH saat tidur (y tetap)", absf(_main._player.global_position.y - tidur1.y) < 0.05)
	_main._on_aksi("berdiri")
	await _frames(5)
	_cek("Asrama: bangun -> pose berdiri", _main._player.aksi_saat_ini() == "berdiri")
	_cek("Asrama: body kasur 001 aktif lagi", (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_layer == 1 and (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_mask == 1)
	# Prioritas: di koridor (lebih dekat pintu daripada kasur) -> KELUAR.
	# KOREKSI 18 Nov 2026 (perbesaran Nadia): +1,5 dari kasur kini
	# masih di lorong kaki kasur (z -302,25, koridor mulai -301,3)
	# — +2,9 baru sampai koridor (z -300,85).
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 2.9), 0.0)
	await _frames(10)
	_cek("Asrama: di koridor tombol KELUAR (lebih dekat pintu)", _tombol() == "KELUAR ASRAMA PUTRI")

	# ---------- tidur Asrama: kasur sendiri atas (A-PUTRI-002, y 1,65) ----------
	_main._kasur_saya = {"kasur_id": "A-PUTRI-002", "gedung": "Asrama Putri", "kamar": "Kamar 001", "susun": 1, "tingkat": "atas", "fisik": false}
	var tidur2: Vector3 = _main._asrama_putri_beds[1]
	_main._teleport_player(Vector3(tidur2.x, 0, tidur2.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama atas: dekat kasur sendiri (002)", _main._dekat_tempat_tidur())
	_main._on_interact()
	await _frames(5)
	_cek("Asrama atas: snap y 1,65", absf(_main._player.global_position.y - tidur2.y) < 0.05 and absf(tidur2.y - 1.65) < 0.01)
	_cek("Asrama atas: body unit yang SAMA nonaktif", (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_layer == 0 and (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_mask == 0)
	_cek("Asrama atas: kapsul dikecilkan 0,8 (muat di bawah pelat)", absf(_main._player_capsule.height - 0.8) < 0.01)
	await _frames(60)
	_cek("Asrama atas: TIDAK JATUH saat tidur (y tetap)", absf(_main._player.global_position.y - tidur2.y) < 0.05)
	# Bangun lewat GERAK (bukan tombol) — _process memanggil _on_aksi("berdiri").
	_main._ui._joystick.output = Vector2(0, -1)
	await _frames(10)
	_main._ui._joystick.output = Vector2.ZERO
	_cek("Asrama atas: bangun lewat gerak", _main._player.aksi_saat_ini() == "berdiri")
	_cek("Asrama atas: body aktif lagi", (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_layer == 1 and (_main._asrama_putri_kasur_bodies[0] as StaticBody3D).collision_mask == 1)
	_cek("Asrama atas: kapsul kembali 1,7", absf(_main._player_capsule.height - 1.7) < 0.01)

	# ---------- tidur Asrama: overflow Musholla TIDAK boleh tidur di Asrama ----------
	_main._kasur_saya = {"kasur_id": "S-PUTRI-01", "gedung": "Musholla", "kamar": "", "susun": 0, "tingkat": "", "fisik": false}
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama: overflow Musholla tidak bisa tidur di Asrama", not _main._dekat_tempat_tidur())
	# ---------- tidur Asrama: save lama tanpa tugas = kasur terdekat ----------
	_main._kasur_saya = {}
	_main._teleport_player(Vector3(tidur1.x, 0, tidur1.z + 0.55), 0.0)
	await _frames(10)
	_cek("Asrama: save lama dekat kasur mana saja", _main._dekat_tempat_tidur())
	_main._on_interact()
	await _frames(5)
	_cek("Asrama: save lama bisa tidur (kasur terdekat)", _main._player.aksi_saat_ini() == "tidur" and _main._kasur_tidur_idx == 1)
	_main._on_aksi("berdiri")
	await _frames(3)
	_main._keluar_asrama_putri()
	await _frames(3)

	# ---------- konsistensi ledger kasur putri (TIDAK diubah wiring ini) ----------
	var ledger := {"versi": 1, "tugas": {}}
	var t1 := PembagianKasur.buat_tugas("PV-TES-LESTARI-1", "putri", ledger)
	_cek("Ledger: putri 1 -> Asrama Putri A-PUTRI-001", String(t1.get("gedung", "")) == "Asrama Putri" and String(t1.get("kasur_id", "")) == "A-PUTRI-001")
	var t2 := PembagianKasur.buat_tugas("PV-TES-LESTARI-2", "putri", ledger)
	_cek("Ledger: putri 2 -> A-PUTRI-002", String(t2.get("kasur_id", "")) == "A-PUTRI-002")
	var ids: Array = InteriorAsramaPutri.kasur_id_list()
	_cek("Ledger x interior: id kasur sama (001/002)", String(ids[0]) == "A-PUTRI-001" and String(ids[1]) == "A-PUTRI-002")
	_cek("Ledger: posisi tidur putri 1 = titik Musholla (overflow, tidak berubah)",
		PembagianKasur.posisi_tidur(t1) != Vector3.INF and PembagianKasur.posisi_tidur(t1).distance_to(PembagianKasur.tempat_tidur_musholla()[0]) < 0.01)
	var t97 := {}
	for i in range(97):
		t97 = PembagianKasur.buat_tugas("PV-TES-LESTARI-%03d" % (i + 1), "putri", ledger)
	_cek("Ledger: putri 97 -> Musholla (overflow setelah 96 Asrama)", String(t97.get("gedung", "")) == "Musholla")

	# ---------- peta: titik pemain di cangkang saat di interior ----------
	_main._masuk_kelas_putri()
	await _frames(3)
	var peta: Dictionary = _main._data_peta()
	_cek("Peta: di Kelas -> titik di cangkang Kelas (130,10)",
		(peta["player"] as Vector2).distance_to(Vector2(130, 10)) < 0.01)
	_main._keluar_kelas_putri()
	await _frames(3)

	print("TES WIRING PUTRI: lulus %d, gagal %d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
