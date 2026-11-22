extends Node
## Tes SENTUH Ruang Belajar TEKS v4 (Sinta, 22 Nov 2026 — keputusan
## Mas 16:03: lanjut MANUAL, pemain yang mengetuk; naskah v4
## DI-ACC Mas 16:12).
## Membuktikan ketuk LAYAR (bukan panggilan metode) benar-benar
## menggerakkan dialog: ketuk gelembung saat bicara -> tampil
## penuh; ketuk lagi -> lanjut node; ketuk tombol Lanjut -> lanjut;
## ketuk tombol "Belum" di node cek -> node ulang.
## WAJIB Xvfb + push_input + --resolution (pola tes sentuh lama):
##   Xvfb :95 -screen 0 1280x720x24 &
##   HOME=/tmp/iso-rb-sentuh DISPLAY=:95 godot --path . --resolution 1280x720 --audio-driver Dummy --scene res://skrip/test_ruang_belajar_teks_sentuh.tscn
## Display SEGAR (jangan :98 yang macet). EXIT 0 bila semua lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Ketuk layar (sentuh tekan + lepas) di posisi piksel layar.
func _ketuk_layar(pos: Vector2) -> void:
	var tekan := InputEventScreenTouch.new()
	tekan.index = 0
	tekan.position = pos
	tekan.pressed = true
	get_viewport().push_input(tekan)
	var lepas := InputEventScreenTouch.new()
	lepas.index = 0
	lepas.position = pos
	lepas.pressed = false
	get_viewport().push_input(lepas)


## Cari tombol pilihan dengan teks yang mengandung `cari`.
func _cari_tombol(rb: RuangBelajarUI, cari: String) -> Button:
	for c in rb._pilihan_box.get_children():
		if c is Button and not c.is_queued_for_deletion() and String((c as Button).text).contains(cari):
			return c
	return null


func _ready() -> void:
	var mj := ManajerUIMisi.new()
	add_child(mj)
	mj.buka_ruang_belajar("Ust. Sanusi", SantriSave.default_data())
	for i in 5:
		await get_tree().process_frame
	var rb: RuangBelajarUI = mj._ruang_belajar
	_cek("Sentuh: panel ruang_belajar terbuka + node p1 bicara", mj.panel_terbuka() == "ruang_belajar" and rb.node_saat_ini() == "p1" and rb.sedang_bicara())
	# Pusat gelembung dialog (layar) — titik ketuk.
	var pusat: Vector2 = rb._kotak_dialog.get_global_rect().get_center()
	_cek("Sentuh: gelembung dialog punya rect layar (bukan 0)", pusat.x > 100.0 and pusat.y > 100.0)
	# Ketuk 1 (saat bicara) -> tampil penuh, node tetap p1.
	_ketuk_layar(pusat)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("Sentuh 1: ketuk gelembung saat bicara -> tampil penuh, node tetap p1", not rb.sedang_bicara() and rb.node_saat_ini() == "p1")
	# Ketuk 2 (ucapan selesai, Lanjut tampil) -> lanjut ke n1.
	_ketuk_layar(pusat)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("Sentuh 2: ketuk gelembung setelah selesai -> lanjut ke n1", rb.node_saat_ini() == "n1")
	# Ketuk tombol Lanjut LANGSUNG (bukan gelembung) -> lanjut ke n2.
	rb._selesaikan_bicara()
	await get_tree().process_frame
	var tombol_lanjut := _cari_tombol(rb, "Lanjut")
	_cek("Sentuh 3: tombol Lanjut tampil di n1", tombol_lanjut != null and tombol_lanjut.text == "Lanjut ›")
	if tombol_lanjut != null:
		_ketuk_layar(tombol_lanjut.get_global_rect().get_center())
		await get_tree().process_frame
		await get_tree().process_frame
		_cek("Sentuh 3: ketuk tombol Lanjut -> lanjut ke n2", rb.node_saat_ini() == "n2")
	# Jalan ke c1 (ketuk gelembung 2x: tampil penuh + lanjut).
	rb._selesaikan_bicara()
	_ketuk_layar(pusat)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("Sentuh 4: ketuk Lanjut di n2 -> lanjut ke c1 (cek)", rb.node_saat_ini() == "c1")
	# Node cek: 2 tombol opsi tampil; ketuk "Belum" -> node ulang u1.
	rb._selesaikan_bicara()
	await get_tree().process_frame
	var tombol_belum := _cari_tombol(rb, "Belum")
	_cek("Sentuh 5: node cek tampil 2 opsi (Paham + Belum)", _cari_tombol(rb, "Paham") != null and tombol_belum != null)
	if tombol_belum != null:
		_ketuk_layar(tombol_belum.get_global_rect().get_center())
		await get_tree().process_frame
		await get_tree().process_frame
		_cek("Sentuh 5: ketuk tombol Belum -> node ulang u1", rb.node_saat_ini() == "u1")
	# Modul 02 lewat SENTUH (dispatch _chat — port 22 Nov 23:05):
	# buka ulang dengan save modul 2, ketuk gelembung -> n1.
	mj.tutup_semua()
	await get_tree().process_frame
	var save2 := SantriSave.default_data()
	save2["onboarding"] = {"modul": 2}
	var papan2: Array = []
	rb.papan_berubah.connect(func(judul: String, baris: PackedStringArray) -> void: papan2.append([judul, baris]))
	mj.buka_ruang_belajar("Ust. Sanusi", save2)
	for i in 5:
		await get_tree().process_frame
	_cek("Sentuh M02: panel terbuka modul 2 + papan NAHWU DASAR / Modul 02 + node p1 bicara", mj.panel_terbuka() == "ruang_belajar" and rb.node_saat_ini() == "p1" and rb.sedang_bicara() and papan2 == [["NAHWU DASAR", PackedStringArray(["Modul 02 — Isim Lebih Dalam"])]])
	_cek("Sentuh M02: _chat = DataChatModul02 (dispatch per modul)", rb._chat == DataChatModul02)
	var pusat2: Vector2 = rb._kotak_dialog.get_global_rect().get_center()
	_ketuk_layar(pusat2)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("Sentuh M02: ketuk gelembung saat bicara -> tampil penuh, node tetap p1", not rb.sedang_bicara() and rb.node_saat_ini() == "p1")
	_ketuk_layar(pusat2)
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("Sentuh M02: ketuk gelembung setelah selesai -> lanjut ke n1", rb.node_saat_ini() == "n1")
	mj.tutup_semua()
	print("TES RUANG BELAJAR TEKS SENTUH: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
