extends Node
## Tes RANTAI MISI PUTRI end-to-end (Sinta, 18 Nov 2026) — verifikasi
## perintah Mas 20:30 WIB "Ini segera realisasikan".
##   HOME=/tmp/iso-rantai XDG_DATA_HOME=/tmp/iso-rantai/.local/share \
##     godot --headless --path . --scene res://skrip/test_rantai_putri.tscn
##   (HARNESS — Kirana/Wulan 18 Nov: argumen scene posisional DIIABAIKAN
##   Godot 4.7.2 ini (diam-diam jalan main.tscn); --user-dir TIDAK ADA
##   di binary ini. WAJIB --scene + isolasi save lewat HOME/XDG.)
## Rantai yang diuji (routing, bukan isi panel — isi panel sudah
## ditutup test_ui_misi 78/78):
##   putri login (langkah 2) -> dekat Mariyah -> dialog putri ->
##   dialog selesai x2 (langkah 2->3, 3->4) -> fatimah_lokasi terisi
##   + node Fatimah ikut pindah ke lokasi save -> dekat Fatimah
##   (langkah 4) -> ✕ -> maju ke langkah 5 + Ruang Belajar ->
##   venue tes putri (148,-33) langkah 6 -> panel tes.
## CATATAN PERBAIKAN (Raka, 18 Nov ~21:00 WIB): dua temuan Sinta
## dari draf tes ini SUDAH DIPERBAIKI di main.gd dan tes ini
## MEMBUKTIKANNYA (bukan mendokumentasikan): (1) cabang langkah 4
## di _buka_ui_misi_terdekat() + _dekat_npc_misi() — dekat guru =
## maju ke 5 + buka RB; (2) _pindah_guru_ke_lokasi_save() —
## node guru pindah ke lokasi acak baru tiap save diacak ulang
## (dipanggil dialog_selesai baru==4 dan tes_selesai lulus baru==5).
## CATATAN TAP vs ROUTING (info Mas 21:00 WIB: tombol bermasalah
## HANYA di HP, di PC aman): tes ini memanggil sinyal tombol
## (_interact_btn.pressed.emit()) — membuktikan sambungan sinyal
## ui.gd->main.gd + tombolnya MUNCUL (visible + teks MULAI MISI)
## headless. Itu BUKAN bukti tap sentuhan (hit-testing layar
## sentuh tidak tercakup): tap fisik ✕ di HP tetap BUTUH T1 HP Mas.

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


func _ada_teks(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	for anak in node.get_children():
		if _ada_teks(anak, cari):
			return true
	return false


## Cari titik di dekat NPC yang tombol ✕-nya benar-benar
## "MULAI MISI" (bukan label pintu). Vector3.INF bila tidak ada.
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
		if btn.visible and String(btn.text) == "MULAI MISI":
			return _main._player.global_position
	return Vector3.INF


func _atur_langkah(n: int) -> void:
	var ob := Onboarding.baca(_main._save)
	ob["langkah"] = n
	_main._save["onboarding"] = ob
	SantriSave.save_data(_main._save)


## Jalankan dialog yang sedang terbuka sampai pilihan terakhir
## (ke == -1) lewat pilihan pertama tiap babak — jalur produksi
## DataDialogMisi, bukan lompat langsung ke -1.
func _jalan_dialog_sampai_selesai(pembicara: String) -> bool:
	var dlg = _main._manajer_misi._dialog
	for i in 8:
		if not dlg.visible:
			print("DIALOG: tidak terlihat di iterasi %d" % i)
			return false
		var babak: Dictionary = DataDialogMisi.babak(int(dlg._babak), pembicara)
		var pil: Array = babak.get("pilihan", [])
		if pil.is_empty():
			print("DIALOG: babak %d tanpa pilihan" % int(dlg._babak))
			return false
		var ke := int((pil[0] as Dictionary).get("ke", -1))
		print("DIALOG: babak %d -> ke %d" % [int(dlg._babak), ke])
		dlg._on_pilihan_ditekan(ke)
		await _tunggu_waktu(0.15)
		if ke == -1:
			return true
	print("DIALOG: tidak selesai dalam 8 iterasi")
	return false


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes rantai putri")
	await _tunggu_waktu(2.5)

	# ---------- 1. Login putri -> langkah 2 ----------
	_cek("1: login putri -> langkah 2", Onboarding.langkah_saat_ini(_main._save) == 2)
	_cek("1: login putri mendarat di area putri (x=%.1f > 14)" % _main._player.global_position.x, _main._player.global_position.x > 14.0)

	# ---------- 2. Dekat Mariyah -> dialog putri ----------
	var titik_m := await _titik_dekat_npc(_main._ustadzah)
	_cek("2: titik dekat Mariyah ditemukan (tombol MULAI MISI)", titik_m != Vector3.INF)
	if titik_m != Vector3.INF:
		# Sinyal tombol (bukan _on_interact() langsung): bukti
		# sambungan ui.gd->main.gd. BUKAN bukti tap sentuhan HP.
		_main._ui._interact_btn.pressed.emit()
		await _tunggu_waktu(0.3)
		_cek("2: ✕ dekat Mariyah -> dialog putri terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "dialog")
		_cek("2: dialog putri menyebut Ustzh. Mariyah", _ada_teks(_main._manajer_misi._dialog, "Ustzh. Mariyah"))

		# ---------- 3. Dialog selesai x2: 2->3, lalu 3->4 ----------
		var ok1 := await _jalan_dialog_sampai_selesai("putri")
		await _tunggu_waktu(0.3)
		print("3: setelah dialog ke-1: langkah=%d dialog_selesai=%s" % [Onboarding.langkah_saat_ini(_main._save), str(ok1)])
		_cek("3: dialog selesai ke-1 -> langkah 3", ok1 and Onboarding.langkah_saat_ini(_main._save) == 3)
		# Dialog kedua (langkah 3, masih dekat Mariyah).
		_main._ui._interact_btn.pressed.emit()
		await _tunggu_waktu(0.3)
		_cek("3: ✕ dekat Mariyah langkah 3 -> dialog terbuka lagi", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "dialog")
		var ok2 := await _jalan_dialog_sampai_selesai("putri")
		await _tunggu_waktu(0.3)
		print("3: setelah dialog ke-2: langkah=%d dialog_selesai=%s" % [Onboarding.langkah_saat_ini(_main._save), str(ok2)])
		_cek("3: dialog selesai ke-2 -> langkah 4", ok2 and Onboarding.langkah_saat_ini(_main._save) == 4)

		# ---------- 4. Langkah 4: fatimah_lokasi terisi + Fatimah di putri ----------
		var ob4 := Onboarding.baca(_main._save)
		var id_f := String(ob4.get("fatimah_lokasi", ""))
		var pos_f_save: Vector3 = LokasiAcak.pos_dari_id_putri(id_f)
		print("4: fatimah_lokasi='%s' pos_save=%s Fatimah_node=%s" % [id_f, str(pos_f_save), str(_main._fatimah.global_position)])
		_cek("4: fatimah_lokasi terisi id putri valid ('%s')" % id_f, id_f != "" and LokasiAcak.id_valid_putri(id_f))
		_cek("4: target misi Fatimah di area putri (x=%.1f > 14)" % pos_f_save.x, pos_f_save.x > 14.0)
		_cek("4: node Fatimah berdiri di area putri (x=%.1f > 14)" % _main._fatimah.global_position.x, _main._fatimah.global_position.x > 14.0)
		var jarak_node_save: float = (_main._fatimah.global_position as Vector3).distance_to(pos_f_save)
		print("4: jarak node Fatimah ke target save = %.2f m" % jarak_node_save)
		_cek("4: node Fatimah BERDIRI di lokasi target save (jarak %.2f m <= 1)" % jarak_node_save, jarak_node_save <= 1.0)

		# ---------- 5. Langkah 4: ✕ dekat Fatimah -> maju 5 + RB ----------
		# PERBAIKAN Raka: cabang langkah 4 di _dekat_npc_misi() +
		# _buka_ui_misi_terdekat() — dulu rantai PUTUS di sini (✕
		# hanya membuka Panel Misi, tidak ada pemicu 4->5).
		var titik_f4 := await _titik_dekat_npc(_main._fatimah)
		_cek("5: langkah 4 dekat Fatimah -> tombol ✕ MULAI MISI muncul", titik_f4 != Vector3.INF)
		if titik_f4 != Vector3.INF:
			_main._ui._interact_btn.pressed.emit()
			await _tunggu_waktu(0.3)
			print("5: setelah ✕ langkah 4: panel='%s' langkah=%d" % [_main._manajer_misi.panel_terbuka(), Onboarding.langkah_saat_ini(_main._save)])
			_cek("5: ✕ dekat Fatimah langkah 4 -> maju ke langkah 5", Onboarding.langkah_saat_ini(_main._save) == 5)
			_cek("5: ✕ dekat Fatimah langkah 4 -> Ruang Belajar terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "ruang_belajar")
			_cek("5: Ruang Belajar pengajar Ustzh. Fatimah", _ada_teks(_main._manajer_misi._ruang_belajar, "Ustzh. Fatimah"))
			_main._manajer_misi.tutup_semua()
			await _tunggu_waktu(0.2)

		# ---------- 6. Jalur langkah 5 (buka ulang RB dekat Fatimah) ----------
		# RB sudah terbuka di bagian 5; verifikasi cabang langkah 5
		# sendiri: tutup, tekan ✕ lagi -> RB terbuka lagi.
		_cek("6: masih langkah 5 setelah RB bagian 5 ditutup", Onboarding.langkah_saat_ini(_main._save) == 5)
		var titik_f5 := await _titik_dekat_npc(_main._fatimah)
		_cek("6: titik dekat Fatimah ditemukan lagi (tombol MULAI MISI)", titik_f5 != Vector3.INF)
		if titik_f5 != Vector3.INF:
			_main._ui._interact_btn.pressed.emit()
			await _tunggu_waktu(0.3)
			_cek("6: ✕ dekat Fatimah langkah 5 -> Ruang Belajar terbuka lagi", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "ruang_belajar")
			_cek("6: Ruang Belajar pengajar Ustzh. Fatimah", _ada_teks(_main._manajer_misi._ruang_belajar, "Ustzh. Fatimah"))
			_main._manajer_misi.tutup_semua()
			await _tunggu_waktu(0.2)

		# ---------- 6b. Pemicu 5->6: RB selesai -> maju ke tes ----------
		# PERBAIKAN Raka (temuan Sinta): _on_manajer_rb_selesai dulu
		# hanya toast — tidak ada pemicu in-game 5->6. Kini RB selesai
		# (kuis terakhir dijawab) memajukan langkah 5 -> 6.
		# Diuji lewat handler langsung: jalur emisi kuis->selesai->
		# manajer sudah ditutup test_ui_misi; yang diuji di sini
		# hanya logika majunya + guard-nya.
		_main._on_manajer_rb_selesai(30)
		await _tunggu_waktu(0.2)
		_cek("6b: RB selesai di langkah 5 -> maju ke langkah 6", Onboarding.langkah_saat_ini(_main._save) == 6)
		_main._on_manajer_rb_selesai(30)
		await _tunggu_waktu(0.2)
		_cek("6b: RB selesai lagi di langkah 6 -> tetap langkah 6 (guard)", Onboarding.langkah_saat_ini(_main._save) == 6)

	# ---------- 7. Venue tes putri langkah 6 -> panel tes ----------
	# Langkah 6 berasal dari 6b (RB selesai -> maju); tidak lagi
	# diatur manual — rantai kini utuh tanpa lompatan.
	var venue: Vector3 = Onboarding.venue_tes("putri")
	print("7: venue_tes putri = %s" % str(venue))
	_cek("7: venue_tes putri == Kantor Ustadzah (148,0,-33)", venue.distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("7: masih langkah 6 dari pemicu RB (bukan manual)", Onboarding.langkah_saat_ini(_main._save) == 6)
	_main._teleport_player(venue, 0.0)
	await _tunggu_waktu(0.5)
	_main._update_interact_button()
	var btn7 = _main._ui._interact_btn
	print("7: di venue: tombol=%s teks='%s' jarak_venue=%.2f" % [str(btn7.visible), String(btn7.text), _main._player.global_position.distance_to(venue)])
	_cek("7: di venue tes langkah 6 -> tombol ✕ MULAI MISI", btn7.visible and String(btn7.text) == "MULAI MISI")
	_main._ui._interact_btn.pressed.emit()
	await _tunggu_waktu(0.3)
	_cek("7: ✕ di venue tes -> panel tes terbuka", _main._manajer_misi.ada_panel_terbuka() and _main._manajer_misi.panel_terbuka() == "tes")
	_cek("7: panel tes N1 tampil", _ada_teks(_main._manajer_misi._tes, "Tes Naik Bagian 2 (N1.T)"))
	_main._manajer_misi.tutup_semua()
	await _tunggu_waktu(0.2)

	print("HASIL: LULUS=%d GAGAL=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
