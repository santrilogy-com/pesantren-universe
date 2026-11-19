extends Node
## Tes TOMBOL ✕ + TOMBOL HUD LAIN (Sinta, 18 Nov 2026) — verifikasi
## perbaikan Raka atas laporan Mas 20:20-20:30 WIB.
##   HOME=/tmp/iso-interact XDG_DATA_HOME=/tmp/iso-interact/.local/share \
##     godot --headless --path . --scene res://skrip/test_interact.tscn
##   (HARNESS — Kirana/Wulan 18 Nov: argumen scene posisional DIIABAIKAN
##   Godot 4.7.2 ini (diam-diam jalan main.tscn); --user-dir TIDAK ADA
##   di binary ini. WAJIB --scene + isolasi save lewat HOME/XDG.
##   Raka sedang menjalankan skrip/test_reset.gd paralel — file/log
##   itu JANGAN diganggu; tes ini pakai HOME isolasi sendiri.)
## Akar BUG 1: _update_interact_button() di main.gd tidak punya cabang
## untuk NPC alur santri baru, jadi tombol ✕ tidak pernah muncul di
## dekat Kyai/Ustadzah/Sanusi/Fatimah padahal _on_interact() sudah
## punya routing dialognya. Perbaikan: cabang _dekat_npc_misi() ->
## "MULAI MISI". Tes ini mengukur ujung-ke-ujung di scene asli:
## (a) putra langkah 2 dekat Kyai -> ✕ MULAI MISI -> dialog putra
## (b) putri langkah 2 dekat Mariyah -> ✕ MULAI MISI -> dialog putri
## (c) putra langkah 5 dekat Sanusi -> ✕ -> Ruang Belajar
## (d) putri langkah 5 dekat Fatimah -> ✕ -> Ruang Belajar
## (e) tombol lain merespon: □ Chat, ○ Reset, △ Aksi, Main Bersama
##     (bedakan "satu tombol mati" vs "semua HUD mati").
## CATATAN TAP vs ROUTING (info Mas 21:00 WIB: tombol bermasalah
## HANYA di HP, di PC aman): tes ini memanggil sinyal tombol
## (_interact_btn/_chat_btn/_reset_btn/aksi/_mp_gabung_btn
## .pressed.emit()) — membuktikan sambungan sinyal ui.gd->main.gd
## + tombolnya MUNCUL (visible + teks) headless. Itu BUKAN bukti
## tap sentuhan (hit-testing layar sentuh tidak tercakup): tap
## fisik di HP tetap BUTUH T1 HP Mas.
## CATATAN geometri (bukan asumsi): Mariyah berdiri di (134,-17)
## sedangkan pintu Musholla di (134,-17.5) — pemain yang berdiri
## persis di samping Mariyah masuk zona pintu (2,5 m) dan ✕ malah
## menampilkan "MASUK MUSHOLLA". Karena itu tiap fase memakai
## _titik_dekat_npc(): cari titik yang dekat NPC (<= 3,5 m) TAPI
## tombolnya benar-benar "MULAI MISI" — seperti pemain yang
## mendekat dari arah yang benar.

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


## Cari teks di semua Label di bawah node (rekursif).
func _ada_teks(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	for anak in node.get_children():
		if _ada_teks(anak, cari):
			return true
	return false


func _dekat(a: Vector3, b: Vector3, toleransi: float) -> bool:
	return a.distance_to(b) <= toleransi


## Cari titik di dekat NPC yang tombol ✕-nya benar-benar
## "MULAI MISI" (bukan label pintu). Mengembalikan Vector3.INF
## bila tidak ada offset yang memenuhi (dicetak apa adanya).
func _titik_dekat_npc(npc: Node3D) -> Vector3:
	var offsets: Array[Vector3] = [
		Vector3(0, 0, 2.0), Vector3(2.0, 0, 0), Vector3(0, 0, -2.0),
		Vector3(-2.0, 0, 0), Vector3(1.4, 0, 1.4), Vector3(-1.4, 0, -1.4),
		Vector3(1.4, 0, -1.4), Vector3(-1.4, 0, 1.4),
	]
	for off in offsets:
		var p: Vector3 = npc.global_position + off
		_main._teleport_player(p, 0.0)
		await _tunggu_waktu(0.3)
		_main._update_interact_button()
		var btn = _main._ui._interact_btn
		print("TITIK coba %s jarak_npc=%.2f tombol=%s teks='%s'" % [
			str(p), _main._player.global_position.distance_to(npc.global_position),
			str(btn.visible), String(btn.text)])
		if btn.visible and String(btn.text) == "MULAI MISI":
			return _main._player.global_position
	return Vector3.INF


func _atur_langkah(n: int) -> void:
	var ob := Onboarding.baca(_main._save)
	ob["langkah"] = n
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


func _ganti_gender(g: String) -> void:
	_main._save["jenis_kelamin"] = g
	SantriSave.save_data(_main._save)
	_main._terapkan_gender_pemain()


func _tutup_panel() -> void:
	_main._manajer_misi.tutup_semua()
	await _tunggu_waktu(0.2)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP: kosongkan ig supaya tes jalan OFFLINE.
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putra"
	_main._masuk_pesantren("Tes interact")
	await _tunggu_waktu(2.5)
	print("AWAL: langkah=%d gender=%s pos=%s" % [
		Onboarding.langkah_saat_ini(_main._save),
		String(_main._save.get("jenis_kelamin", "?")),
		str(_main._player.global_position)])

	# ---------- (a) PUTRA langkah 2, dekat Kyai ----------
	_cek("A: login putra -> langkah 2", Onboarding.langkah_saat_ini(_main._save) == 2)
	var titik_a := await _titik_dekat_npc(_main._kyai)
	_cek("A: titik dekat Kyai ditemukan (tombol MULAI MISI)", titik_a != Vector3.INF)
	if titik_a != Vector3.INF:
		await _tunggu_waktu(0.5)
		_main._update_interact_button()
		var btn_a = _main._ui._interact_btn
		_cek("A: tombol ✕ terlihat + teks MULAI MISI (dapat '%s')" % String(btn_a.text), btn_a.visible and String(btn_a.text) == "MULAI MISI")
		_main._ui._interact_btn.pressed.emit()
		await _tunggu_waktu(0.3)
		_cek("A: ✕ dekat Kyai -> dialog terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "dialog")
		_cek("A: dialog putra teks babak 1 (Ahlan wa sahlan)", _ada_teks(_main._manajer_misi._dialog, "Ahlan wa sahlan"))
		_main._ui._interact_btn.pressed.emit() # toggle: panel terbuka -> tutup
		await _tunggu_waktu(0.2)
		_cek("A: ✕ kedua menutup dialog (toggle)", not _main._manajer_misi.ada_panel_terbuka())

	# ---------- kontrol negatif: jauh dari NPC/pintu -> ✕ sembunyi ----------
	_main._teleport_player(Vector3(-40, 0, 60), 0.0)
	await _tunggu_waktu(0.5)
	_main._update_interact_button()
	var btn_neg = _main._ui._interact_btn
	print("NEGATIF: pos=%s tombol=%s teks='%s'" % [str(_main._player.global_position), str(btn_neg.visible), String(btn_neg.text)])
	_cek("NEGATIF: jauh dari NPC/pintu -> tombol ✕ sembunyi", not btn_neg.visible)

	# ---------- (b) PUTRI langkah 2, dekat Ustadzah Mariyah ----------
	_ganti_gender("putri")
	Onboarding.reset(_main._save)
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes interact putri")
	await _tunggu_waktu(1.5)
	_cek("B: login putri -> langkah 2", Onboarding.langkah_saat_ini(_main._save) == 2)
	_cek("B: login putri mendarat di area putri (x > 14, x=%.1f)" % _main._player.global_position.x, _main._player.global_position.x > 14.0)
	var titik_b := await _titik_dekat_npc(_main._ustadzah)
	_cek("B: titik dekat Mariyah ditemukan (tombol MULAI MISI)", titik_b != Vector3.INF)
	if titik_b != Vector3.INF:
		await _tunggu_waktu(0.5)
		_main._update_interact_button()
		var btn_b = _main._ui._interact_btn
		_cek("B: tombol ✕ terlihat + teks MULAI MISI (dapat '%s')" % String(btn_b.text), btn_b.visible and String(btn_b.text) == "MULAI MISI")
		_main._ui._interact_btn.pressed.emit()
		await _tunggu_waktu(0.3)
		_cek("B: ✕ dekat Mariyah -> dialog terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "dialog")
		_cek("B: dialog putri menyebut Ustzh. Mariyah", _ada_teks(_main._manajer_misi._dialog, "Ustzh. Mariyah"))
		await _tutup_panel()
		_cek("B: panel tertutup setelah tutup_semua", not _main._manajer_misi.ada_panel_terbuka())

	# ---------- (c) PUTRA langkah 5, dekat Sanusi -> Ruang Belajar ----------
	_ganti_gender("putra")
	_atur_langkah(5)
	_main._teleport_player(Vector3(-4, 0, 14), PI)
	await _tunggu_waktu(0.5)
	print("C: Sanusi di %s (save sanusi_lokasi='%s')" % [str(_main._sanusi.global_position), String(Onboarding.baca(_main._save).get("sanusi_lokasi", ""))])
	var titik_c := await _titik_dekat_npc(_main._sanusi)
	_cek("C: titik dekat Sanusi ditemukan (tombol MULAI MISI)", titik_c != Vector3.INF)
	if titik_c != Vector3.INF:
		await _tunggu_waktu(0.5)
		_main._update_interact_button()
		var btn_c = _main._ui._interact_btn
		_cek("C: tombol ✕ terlihat + teks MULAI MISI (dapat '%s')" % String(btn_c.text), btn_c.visible and String(btn_c.text) == "MULAI MISI")
		_main._ui._interact_btn.pressed.emit()
		await _tunggu_waktu(0.3)
		_cek("C: ✕ dekat Sanusi -> Ruang Belajar terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "ruang_belajar")
		_cek("C: Ruang Belajar pengajar Ust. Sanusi", _ada_teks(_main._manajer_misi._ruang_belajar, "Ust. Sanusi"))
		await _tutup_panel()
		_cek("C: panel tertutup setelah tutup_semua", not _main._manajer_misi.ada_panel_terbuka())

	# ---------- (d) PUTRI langkah 5, dekat Fatimah -> Ruang Belajar ----------
	_ganti_gender("putri")
	_atur_langkah(5)
	_main._teleport_player(Vector3(130, 0, 14), PI)
	await _tunggu_waktu(0.5)
	_cek("D: NPC Fatimah ada", _main._fatimah != null)
	if _main._fatimah != null:
		print("D: Fatimah di %s (save fatimah_lokasi='%s')" % [str(_main._fatimah.global_position), String(Onboarding.baca(_main._save).get("fatimah_lokasi", ""))])
		_cek("D: Fatimah berdiri di area putri (x=%.1f > 14)" % _main._fatimah.global_position.x, _main._fatimah.global_position.x > 14.0)
		var titik_d := await _titik_dekat_npc(_main._fatimah)
		_cek("D: titik dekat Fatimah ditemukan (tombol MULAI MISI)", titik_d != Vector3.INF)
		if titik_d != Vector3.INF:
			await _tunggu_waktu(0.5)
			_main._update_interact_button()
			var btn_d = _main._ui._interact_btn
			_cek("D: tombol ✕ terlihat + teks MULAI MISI (dapat '%s')" % String(btn_d.text), btn_d.visible and String(btn_d.text) == "MULAI MISI")
			_main._ui._interact_btn.pressed.emit()
			await _tunggu_waktu(0.3)
			_cek("D: ✕ dekat Fatimah -> Ruang Belajar terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "ruang_belajar")
			_cek("D: Ruang Belajar pengajar Ustzh. Fatimah", _ada_teks(_main._manajer_misi._ruang_belajar, "Ustzh. Fatimah"))
			await _tutup_panel()
			_cek("D: panel tertutup setelah tutup_semua", not _main._manajer_misi.ada_panel_terbuka())

	# ---------- (e) TOMBOL LAIN (masih mode putri, langkah 5) ----------
	# -- e1. □ Chat --
	var chat_awal: bool = _main._ui._chat_panel.visible
	_main._ui._chat_btn.pressed.emit()
	await _tunggu_waktu(0.2)
	_cek("E1: □ Chat membuka panel chat (awal %s -> %s)" % [str(chat_awal), str(_main._ui._chat_panel.visible)], _main._ui._chat_panel.visible and not chat_awal)
	_main._ui._chat_btn.pressed.emit()
	await _tunggu_waktu(0.2)
	_cek("E1: □ Chat kedua menutup panel chat", not _main._ui._chat_panel.visible)
	# -- e2. ○ Reset (putri -> spawn putri) --
	_main._teleport_player(Vector3(160, 0, 30), 0.0)
	await _tunggu_waktu(0.3)
	_main._ui._reset_btn.pressed.emit()
	await _tunggu_waktu(0.5)
	var pos_reset: Vector3 = _main._player.global_position
	print("E2: reset putri pos=%s jangkar=%s spawn=%s" % [str(pos_reset), str(_main._pos_legal_terakhir), str(_main._spawn_putri)])
	_cek("E2: ○ Reset putri -> mendarat di spawn putri (jarak %.2f m)" % pos_reset.distance_to(_main._spawn_putri), _dekat(pos_reset, _main._spawn_putri, 2.0))
	_cek("E2: ○ Reset putri -> jangkar legal ikut ke spawn putri", _dekat(_main._pos_legal_terakhir, _main._spawn_putri, 2.0))
	# -- e3. △ Aksi --
	var aksi_awal: bool = _main._ui._aksi_panel.visible
	(_main._ui._tombol_gamepad["segitiga"] as Button).pressed.emit()
	await _tunggu_waktu(0.2)
	_cek("E3: △ Aksi membuka panel aksi (awal %s -> %s)" % [str(aksi_awal), str(_main._ui._aksi_panel.visible)], _main._ui._aksi_panel.visible and not aksi_awal)
	_main._ui._on_aksi_pressed("melambai")
	await _tunggu_waktu(0.3)
	print("E3: aksi pemain setelah melambai = '%s'" % _main._player.aksi_saat_ini())
	_cek("E3: △ Aksi melambai -> handler _on_aksi jalan (aksi='melambai')", String(_main._player.aksi_saat_ini()) == "melambai")
	_main._ui._on_aksi_pressed("berdiri")
	await _tunggu_waktu(0.2)
	_cek("E3: △ Aksi berdiri -> kembali berdiri", String(_main._player.aksi_saat_ini()) == "berdiri")
	_main._ui.close_aksi()
	# -- e4. Main Bersama (level sinyal saja: MP tidak bisa jalan
	#      headless tanpa server; yang diuji = wiring tombol) --
	var mp_ev: Array = []
	_main._ui.mp_gabung_ditekan.connect(func() -> void: mp_ev.append(true))
	_main._ui._mp_gabung_btn.pressed.emit()
	await _tunggu_waktu(0.5)
	print("E4: sinyal mp_gabung_ditekan=%s status=%s" % [str(mp_ev), String(_main._mp_status)])
	_cek("E4: Main Bersama -> sinyal mp_gabung_ditekan terpanggil", not mp_ev.is_empty())
	_cek("E4: Main Bersama headless (ig kosong) -> tetap offline, tanpa crash", String(_main._mp_status) == "offline")

	print("HASIL: LULUS=%d GAGAL=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
