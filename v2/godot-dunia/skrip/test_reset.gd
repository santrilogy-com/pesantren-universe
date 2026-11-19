extends Node
## Tes RESET SESUAI GENDER (Raka, 18 Nov 2026) — reproduksi laporan Mas 20:20 WIB.
##   HOME=/tmp/iso-reset XDG_DATA_HOME=/tmp/iso-reset/.local/share godot --headless --path . --scene res://skrip/test_reset.tscn
##   (Isolasi WAJIB: --scene — argumen scene posisional DIIABAIKAN
##   Godot 4.7.2 ini, tanpa --scene yang jalan main.tscn — dan
##   HOME/XDG_DATA_HOME terisolasi (--user-dir TIDAK ADA di binary
##   ini). Save segar = role santri; save VM ber-role "keamanan" —
##   _cek_batas nonaktif di sana (pengasuh/musyrif/keamanan boleh
##   lewat tembok), dan tes ini TIDAK BOLEH mengubah save pemain.
##   Tanpa isolasi, jangkar legal tidak pernah tercatat dan
##   snap-back tidak jalan.)
## Laporan Mas (akun santriwati, live d08dfb5e): tekan Reset (tombol
## lingkaran) malah kembali ke depan Surau santri putra.
## Akar: _respawn_ke_spawn() di main.gd selalu teleport ke
## PesantrenBuilder.SPAWN (-4,0,14) tanpa peduli gender.
## Perbaikan: reset ke spawn sesuai gender (putri -> _spawn_putri
## (140,0,16) kampus putri; putra -> SPAWN (-4,0,14)) + jangkar
## dorong-balik (_pos_legal_terakhir) ikut diperbarui + toast benar.
## Tes mengukur ujung-ke-ujung di scene asli (bukan membaca kode):
## (a) reset putri -> mendarat di spawn putri (x > 14, area putri)
## (b) reset putra -> mendarat di spawn putra (x < 14, area putra)
## (c) jaring jurang putri (y < -5) -> kembali ke spawn putri
## (d) reset mengeluarkan dari interior (flag _di_dalam_musholla mati)
## (e) jangkar legal (_pos_legal_terakhir) ikut ke spawn yang benar
##     — kalau tidak, _cek_batas di frame berikut bisa menarik pemain
##     kembali ke posisi legal lama (area seberang).

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


func _tunggu_waktu(detik: float) -> void:
	var t := 0.0
	while t < detik:
		await get_tree().process_frame
		t += get_process_delta_time()


func _dekat(a: Vector3, b: Vector3, toleransi: float) -> bool:
	return a.distance_to(b) <= toleransi


func _pos() -> Vector3:
	return _main._player.global_position


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (pola test_kamera.gd): kosongkan ig di save supaya
	# tes jalan OFFLINE (tidak terhubung ke server live).
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes reset")
	await _tunggu_waktu(2.5)

	var spawn_putri: Vector3 = _main._spawn_putri
	var spawn_putra: Vector3 = PesantrenBuilder.SPAWN
	print("SPAWN putri=%s putra=%s" % [str(spawn_putri), str(spawn_putra)])

	# --- Sanity: login putri mendarat di area putri. ---
	_cek("LOGIN putri: posisi di area putri (x > 14)", _pos().x > 14.0)

	# --- (a) Reset putri dari titik lain di area putri. ---
	_main._teleport_player(Vector3(160, 0, 30), 0.0)
	await _tunggu_waktu(0.5)
	_main._respawn_ke_spawn()
	var langsung_putri := _pos()
	print("RESET putri langsung: pos=%s jangkar=%s" % [str(langsung_putri), str(_main._pos_legal_terakhir)])
	_cek("RESET putri: langsung mendarat di spawn putri (jarak <= 2 m)", _dekat(langsung_putri, spawn_putri, 2.0))
	_cek("RESET putri: langsung di area putri (x > 14)", langsung_putri.x > 14.0)
	await _tunggu_waktu(1.0)
	_cek("RESET putri: setelah 1 dtk tetap di spawn putri", _dekat(_pos(), spawn_putri, 2.0))
	_cek("RESET putri: jangkar legal ikut ke spawn putri", _dekat(_main._pos_legal_terakhir, spawn_putri, 2.0))

	# --- (d) Reset mengeluarkan dari interior Musholla. ---
	_main._di_dalam_musholla = true
	_main._respawn_ke_spawn()
	await _tunggu_waktu(0.5)
	_cek("RESET putri: flag _di_dalam_musholla mati", _main._di_dalam_musholla == false)
	_cek("RESET putri dari interior: mendarat di spawn putri", _dekat(_pos(), spawn_putri, 2.0))

	# --- (b) Reset putra (ganti gender, pola login putra). ---
	_main._save["jenis_kelamin"] = "putra"
	_main._terapkan_gender_pemain()
	_main._teleport_player(Vector3(150, 0, 20), 0.0)
	await _tunggu_waktu(0.5)
	_main._respawn_ke_spawn()
	var langsung_putra := _pos()
	print("RESET putra langsung: pos=%s jangkar=%s" % [str(langsung_putra), str(_main._pos_legal_terakhir)])
	_cek("RESET putra: langsung mendarat di spawn putra (jarak <= 2 m)", _dekat(langsung_putra, spawn_putra, 2.0))
	_cek("RESET putra: langsung di area putra (x < 14)", langsung_putra.x < 14.0)
	await _tunggu_waktu(1.0)
	_cek("RESET putra: setelah 1 dtk tetap di spawn putra", _dekat(_pos(), spawn_putra, 2.0))
	_cek("RESET putra: jangkar legal ikut ke spawn putra", _dekat(_main._pos_legal_terakhir, spawn_putra, 2.0))

	# --- (c) Jaring jurang putri (y < -5) -> spawn putri. ---
	_main._save["jenis_kelamin"] = "putri"
	_main._terapkan_gender_pemain()
	_main._teleport_player(Vector3(150, 0, 20), 0.0)
	await _tunggu_waktu(0.3)
	_main._player.global_position = Vector3(150, -10, 20)
	await _tunggu_waktu(1.0)
	print("JURANG putri: pos=%s" % str(_pos()))
	_cek("JURANG putri: kembali ke spawn putri (jarak <= 2 m)", _dekat(_pos(), spawn_putri, 2.0))
	_cek("JURANG putri: di area putri (x > 14)", _pos().x > 14.0)

	print("HASIL: LULUS=%d GAGAL=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
