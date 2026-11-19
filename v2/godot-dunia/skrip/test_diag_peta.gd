extends Node
## DIAG PETA — Tara (UI). Satu-satunya cek gagal di test_tombol_telepon
## 412c: "A2 peta rect di dalam layar". Cetak angka rect panel peta
## vs viewport supaya jelas seberapa jauh meleset. Output ke file
## ~/workspace/.logs-gate-18nov/diag-peta.txt. Xvfb 412x892.

const MAIN_SCENE := "res://main.tscn"
const OUT := "/home/hatch/workspace/.logs-gate-18nov/diag-peta.txt"

var _main: Node
var _f: FileAccess


func _tulis(s: String) -> void:
	if _f == null:
		_f = FileAccess.open(OUT, FileAccess.WRITE)
	if _f == null:
		return
	_f.store_line(s)
	_f.flush()


func _tunggu(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func _ke_piksel(pos_kanvas: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	var win := DisplayServer.window_get_size()
	return Vector2(pos_kanvas.x * float(win.x) / vp.x, pos_kanvas.y * float(win.y) / vp.y)


func _tap(pos: Vector2) -> void:
	pos = _ke_piksel(pos)
	var tekan := InputEventScreenTouch.new()
	tekan.index = 0
	tekan.pressed = true
	tekan.position = pos
	get_viewport().push_input(tekan)
	await get_tree().process_frame
	var lepas := InputEventScreenTouch.new()
	lepas.index = 0
	lepas.pressed = false
	lepas.position = pos
	get_viewport().push_input(lepas)
	await get_tree().process_frame


func _cari_tombol_ikon(jenis: String) -> Button:
	var ui = _main._ui
	for c in ui._hud.get_children():
		if c is HBoxContainer:
			for t in (c as HBoxContainer).get_children():
				if t is Button and (t as Button).has_meta("ikon"):
					var ik = ui._ikon_dari(t as Button)
					if ik != null and ik.jenis == jenis:
						return t as Button
	return null


func _cari_x_di(node: Node) -> Button:
	for c in node.get_children():
		if c is Button and (c as Button).text == "X":
			return c as Button
		var r := _cari_x_di(c)
		if r != null:
			return r
	return null


func _ready() -> void:
	var scene: PackedScene = load(MAIN_SCENE)
	_main = scene.instantiate()
	add_child(_main)
	await _tunggu(2)
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["petunjuk_tombol_ditutup"] = false
	_main._save["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Diag peta")
	await _tunggu(3)
	var ui = _main._ui
	if ui.is_petunjuk_visible() and ui._petunjuk_mengerti_btn != null:
		await _tap(ui._petunjuk_mengerti_btn.get_global_rect().get_center())
	_tulis("PETA viewport visible_rect=" + str(get_viewport().get_visible_rect()))
	_tulis("PETA window size=" + str(DisplayServer.window_get_size()))
	_tulis("PETA skala_layar=" + str(ui._skala_layar()))
	var peta_btn := _cari_tombol_ikon("peta")
	if peta_btn != null:
		await _tap(peta_btn.get_global_rect().get_center())
		await _tunggu(2)
	_tulis("PETA panel visible=" + str(ui.is_peta_visible()))
	_tulis("PETA panel global_rect=" + str(ui._peta_panel.get_global_rect()))
	_tulis("PETA panel size=" + str(ui._peta_panel.size))
	_tulis("PETA panel min size=" + str(ui._peta_panel.get_combined_minimum_size()))
	_tulis("PETA viewport encloses panel=" + str(get_viewport().get_visible_rect().encloses(ui._peta_panel.get_global_rect())))
	# Bandingkan: dashboard + aksi + chat (yang LULUS).
	var kartu_btn := _cari_tombol_ikon("kartu")
	if kartu_btn != null:
		await _tap(kartu_btn.get_global_rect().get_center())
		await _tunggu(2)
		_tulis("DASH panel global_rect=" + str(ui._dashboard_panel.get_global_rect()) + " encloses=" + str(get_viewport().get_visible_rect().encloses(ui._dashboard_panel.get_global_rect())))
	# CACAT #1 (Tara, 19 Nov 2026): tombol X peta harus di dalam layar
	# + bisa diketuk (dulu jatuh di luar layar karena panel meluber).
	var x_btn := _cari_x_di(ui._peta_panel)
	if x_btn != null:
		var xr := x_btn.get_global_rect()
		_tulis("PETA X rect=" + str(xr) + " di_layar=" + str(get_viewport().get_visible_rect().encloses(xr)))
		# Tutup dashboard dulu (kartu) supaya X peta tidak tertutup.
		if ui.is_dashboard_visible() and kartu_btn != null:
			await _tap(kartu_btn.get_global_rect().get_center())
			await _tunggu(2)
		await _tap(x_btn.get_global_rect().get_center())
		await _tunggu(2)
		_tulis("PETA TAP X -> tertutup=" + str(not ui.is_peta_visible()))
	# CACAT #2 (Tara, 19 Nov 2026): ketuk DI LUAR panel (di bawah
	# panel, kanvas (640,2600)) harus menutupnya — dulu terbaca "di
	# dalam" karena klik piksel vs rect kanvas, panel tidak mau tutup.
	if peta_btn != null:
		await _tap(peta_btn.get_global_rect().get_center())
		await _tunggu(2)
		_tulis("PETA buka lagi=" + str(ui.is_peta_visible()))
		await _tap(Vector2(640, 2600))
		await _tunggu(2)
		_tulis("PETA TAP luar bawah -> tertutup=" + str(not ui.is_peta_visible()))
	_tulis("PETA SELESAI")
	get_tree().quit(0)
