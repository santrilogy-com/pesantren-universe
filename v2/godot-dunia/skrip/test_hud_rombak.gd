extends Node
## Tes ROMBAKAN HUD v3 — VARIAN B rev1 (Tara, 18 Nov 2026 —
## DI-ACC Mas 18:43 WIB, mockup hud-v3-perbaikan-b-rev1.png).
## V3: 4 tombol gamepad diamond (△ atas, □ kiri, ○ kanan, ✕ bawah),
## ukuran SAMA, TANPA teks di tombol; pop-up "PETUNJUK TOMBOL" saat
## pertama main (flag save) + bisa di-close; pemetaan contoh
## ✕=Mulai Misi, △=Aksi, □=Chat, ○=Reset sebagai TABEL (B rev1:
## □ dulu Kamera — kamera PINDAH ke strip atas, icon kamera slot
## ke-3 menggantikan amplop); GEDUNG_PUTRI Asrama Putri
## (155, 21,5x12).
## B rev1 (perbaikan kontras — putih polos TERBUKTI hilang di lantai
## marmer putih): disc + pill KACA BURAM BERTINTA zamrud muda
## (222,234,228) alpha 150, TANPA bayangan; icon bentuk + chevron
## analog + teks pill ZAMRUD GELAP #043B2C, garis sedikit lebih
## tebal (4, X 5); pop-up panel alpha 225 + dim 80; bar ikon atas
## TETAP tile putih alpha 0.5 + icon putih (icon kamera: titik
## lensa zamrud). Menggantikan tes v2 (wajah glossy MLBB, label di
## tombol, label mode singkat).
## Jalankan di Xvfb (bukan --headless, supaya resize portrait jalan):
##   DISPLAY=:98 godot --path . skrip/test_hud_rombak.tscn
## MENGUKUR (bukan "terlihat"):
## 1. Bar atas icon-only: 6 tombol 64x64 (kartu/peta/kamera/speaker/
##    expand/kualitas — tombol Kualitas ke-6, Rangga 19 Nov 2026),
##    transparan (teks tak tampil), bar tidak menabrak label misi di
##    portrait 720x1560; wajah putih translusen 64x64; icon kamera
##    varian "lensa_zamrud" (titik lensa zamrud gelap).
## 2. Tombol □ Chat yang ditekan BENAR-BENAR membuka panel chat;
##    tombol △ Aksi membuka panel aksi; tombol ○ Reset memancarkan
##    sinyal reset_requested; tombol kamera STRIP ATAS memancarkan
##    sinyal kamera_mode_pressed; tombol ✕ Interact memancarkan
##    sinyal interact_pressed.
## 3. Mode kamera tetap terbaca: .text "Kamera: <Mode>" di tombol
##    kamera strip atas (kontrak test_kamera.gd).
## 4. Suara + Layar Penuh: teks + varian icon ikut keadaan.
## 5. Diamond gamepad: 4 tombol ukuran SAMA 100x100, pusat membentuk
##    diamond (△ paling atas, ✕ paling bawah, □ paling kiri, ○
##    paling kanan), disc tidak saling tumpang (jarak pusat >= 100),
##    tidak menabrak joystick/minimap, semua di dalam viewport.
## 6. "Main Bersama" tidak berubah: teks, terlihat saat offline,
##    posisi (216,116). Interact: .text ikut kontekstual.
## 7. WAJAH B rev1 (GayaTombol): tiap tombol gamepad punya
##    TextureRect wajah (meta "wajah") ukuran = ukuran tombol,
##    piksel tengah KACA BERTINTA (222,234,228) alpha 150, HANYA 1
##    TextureRect (tanpa bayang); pill "Main Bersama" wajah kaca
##    alpha 150 + teks ZAMRUD GELAP; bar atas tetap putih alpha 0.5;
##    joystick gaya B rev1 + terlihat + 220x220; wajah menggelap
##    saat ditekan, pulih saat dilepas.
## 8. Icon bentuk: tiap tombol gamepad punya 1 IkonHUD jenis
##    segitiga/kotak/lingkaran/x, TANPA bayangan, warna ZAMRUD
##    GELAP #043B2C, garis tebal 4 (X 5); TIDAK ADA Label (teks)
##    di dalam tombol.
## 9. PEMETAAN: tabel bentuk -> aksi sesuai contoh yang di-ACC
##    (□ = chat, kamera di strip atas).
## 10. Pop-up "PETUNJUK TOMBOL": muncul saat pertama main (flag
##     false), berisi judul + 4 baris + catatan + "Mengerti" + ×,
##     teks + bentuk HITAM, panel alpha 225 + dim 80, tidak
##     menutupi klaster/analog; tutup via "Mengerti" -> flag save
##     true; tidak muncul lagi bila flag true; tutup via × juga
##     menulis flag.
## 11. GEDUNG_PUTRI: Asrama Putri (155,0) ukuran (21.5,12).
## Save dipulihkan di akhir (pola foto_kamera_mode.gd) — nama +
## gender + outfit + flag petunjuk asli dikembalikan sebelum quit;
## ig dibiarkan "" (isolasi MP, pola test_v2.gd).

var _main: Node
var _lulus := 0
var _gagal := 0
var _nama_asli := ""
var _jk_asli := "putra"
var _outfit_asli := {}
var _flag_petunjuk_asli := false
var _reset_ditekan := false
var _kamera_ditekan := false
var _interact_ditekan := false


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _tunggu(detik: float) -> void:
	var t := 0.0
	while t < detik:
		await get_tree().process_frame
		t += get_process_delta_time()


func _bar_ikon() -> HBoxContainer:
	for c in _main._ui._hud.get_children():
		if c is HBoxContainer:
			var anak := (c as HBoxContainer).get_children()
			if not anak.is_empty() and anak[0] is Button and (anak[0] as Button).has_meta("ikon"):
				return c as HBoxContainer
	return null


func _r(b: Control) -> Rect2:
	return b.get_global_rect() if b != null else Rect2()


# Wajah v3: Button punya meta "wajah" (TextureRect) dengan tekstur
# ImageTexture seukuran tombol — bukti wajah prosedural terpasang.
func _punya_wajah(b: Button, w: int, h: int) -> bool:
	if b == null or not b.has_meta("wajah"):
		return false
	var wajah := b.get_meta("wajah") as TextureRect
	if wajah == null or wajah.texture == null:
		return false
	return (wajah.texture as ImageTexture) != null and wajah.texture.get_size() == Vector2(w, h)


# Piksel tengah wajah harus KACA BERTINTA (222,234,228) dengan
# alpha sesuai desain (bukti wajah B rev1, bukan putih polos v3).
func _wajah_tengah_kaca(b: Button, alpha: float) -> bool:
	if b == null or not b.has_meta("wajah"):
		return false
	var wajah := b.get_meta("wajah") as TextureRect
	if wajah == null or wajah.texture == null:
		return false
	var img := (wajah.texture as ImageTexture).get_image()
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	return absf(c.r - 222.0 / 255.0) < 0.05 and absf(c.g - 234.0 / 255.0) < 0.05 and absf(c.b - 228.0 / 255.0) < 0.05 and absf(c.a - alpha) < 0.05


# Piksel tengah wajah bar atas harus PUTIH dengan alpha sesuai
# desain (tile strip atas tetap putih — mockup B rev1).
func _wajah_tengah_putih(b: Button, alpha: float) -> bool:
	if b == null or not b.has_meta("wajah"):
		return false
	var wajah := b.get_meta("wajah") as TextureRect
	if wajah == null or wajah.texture == null:
		return false
	var img := (wajah.texture as ImageTexture).get_image()
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	return c.r > 0.95 and c.g > 0.95 and c.b > 0.95 and absf(c.a - alpha) < 0.05


# Jumlah anak TextureRect (wajah) — v3 HANYA 1 (tanpa bayang).
func _jumlah_wajah(b: Button) -> int:
	var n := 0
	if b == null:
		return -1
	for c in b.get_children():
		if c is TextureRect:
			n += 1
	return n


# IkonHUD anak tombol (atau null).
func _ikon_tombol(b: Button) -> IkonHUD:
	if b == null:
		return null
	for c in b.get_children():
		if c is IkonHUD:
			return c as IkonHUD
	return null


# Kumpulkan semua teks Label + Button di bawah sebuah node (rekursif).
# ("Mengerti" adalah teks Button, bukan Label — tanpa ini cek pop-up
# selalu gagal di butir itu.)
func _teks_label_di(n: Node) -> Array[String]:
	var hasil: Array[String] = []
	var tumpuk: Array[Node] = [n]
	while not tumpuk.is_empty():
		var m: Node = tumpuk.pop_back()
		if m is Label:
			hasil.append((m as Label).text)
		if m is Button:
			hasil.append((m as Button).text)
		for c in m.get_children():
			tumpuk.append(c)
	return hasil


func _ready() -> void:
	# Portrait HP Mas (Galaxy A35 1080x2340 = 9:19,5; 720x1560 sama).
	get_window().size = Vector2i(720, 1560)
	for i in 5:
		await get_tree().process_frame
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# Simpan save asli (dipulihkan di akhir).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	_flag_petunjuk_asli = bool(_main._save.get("petunjuk_tombol_ditutup", false))
	# ISOLASI MP (pola test_v2.gd): kosongkan ig supaya offline.
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	# Pop-up HARUS muncul di tes ini (flag false).
	_main._save["petunjuk_tombol_ditutup"] = false
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes HUD rombak")
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()
	# Dekat penanda M1 (3,0,-6.5) supaya Interact tampil alami.
	_main._teleport_player(Vector3(3, 0, -4), PI)
	await _tunggu(1.0)

	var ui = _main._ui
	var vp := get_viewport().get_visible_rect().size
	_cek("jendela portrait 720x1560", get_window().size == Vector2i(720, 1560))
	# Pop-up pemain baru langsung tampil setelah masuk (flag false).
	_cek("v3: pop-up petunjuk muncul saat pertama main", ui.is_petunjuk_visible())

	# --- 1. Bar atas icon-only ---
	var bar := _bar_ikon()
	_cek("bar ikon atas ada", bar != null)
	if bar != null:
		var anak := bar.get_children()
		_cek("bar ikon berisi 6 tombol", anak.size() == 6)
		var jenis: Array[String] = []
		var semua_ikon := true
		var semua_transparan := true
		var semua_tanpa_bayangan := true
		for a in anak:
			if not (a is Button):
				semua_ikon = false
				continue
			var b := a as Button
			if not b.has_meta("ikon"):
				semua_ikon = false
				continue
			var ikon := b.get_meta("ikon") as IkonHUD
			jenis.append(String(ikon.jenis))
			if not ikon.bayangan:
				pass
			else:
				semua_tanpa_bayangan = false
			if b.get_theme_color("font_color").a > 0.01:
				semua_transparan = false
		_cek("urutan ikon kartu/peta/kamera/speaker/expand/kualitas", jenis == ["kartu", "peta", "kamera", "speaker", "expand", "kualitas"])
		_cek("semua tombol bar atas punya IkonHUD", semua_ikon)
		_cek("icon bar atas tanpa bayangan (v3)", semua_tanpa_bayangan)
		_cek("teks tombol bar atas transparan (tak tampil)", semua_transparan)
		var kamera_strip: Button = ui._kamera_ikon_btn
		_cek("tombol kamera strip atas ada + icon kamera varian lensa_zamrud", kamera_strip != null and ui._ikon_dari(kamera_strip) != null and String(ui._ikon_dari(kamera_strip).jenis) == "kamera" and String(ui._ikon_dari(kamera_strip).varian) == "lensa_zamrud")
		_cek("bar ikon tidak menabrak label misi", not _r(bar).intersects(_r(ui._misi_label)))
		_cek("bar ikon di dalam viewport", vp.x - _r(bar).end.x >= 0.0 and _r(bar).position.y >= 0.0)

	# --- 2. Tombol gamepad benar-benar bekerja ---
	_cek("panel chat awalnya tertutup", not ui.is_chat_visible())
	ui._chat_btn.pressed.emit()
	for i in 3:
		await get_tree().process_frame
	_cek("tekan tombol □ -> panel chat terbuka", ui.is_chat_visible())
	ui.close_chat()
	for i in 3:
		await get_tree().process_frame
	_cek("close_chat menutup panel", not ui.is_chat_visible())
	var aksi_btn := ui._tombol_gamepad.get("segitiga") as Button
	_cek("tombol △ Aksi ada di diamond", aksi_btn != null)
	if aksi_btn != null:
		aksi_btn.pressed.emit()
		for i in 3:
			await get_tree().process_frame
		_cek("tekan tombol △ -> panel aksi terbuka", ui.is_aksi_visible())
		ui.close_aksi()
	# ○ Reset: lepas handler main dulu supaya tes tidak me-respawn
	# pemain (sinyal tetap dites), lalu sambung lagi.
	ui.reset_requested.connect(func() -> void: _reset_ditekan = true)
	ui.reset_requested.disconnect(_main._respawn_ke_spawn)
	var reset_btn := ui._tombol_gamepad.get("lingkaran") as Button
	_cek("tombol ○ Reset ada di diamond", reset_btn != null)
	if reset_btn != null:
		reset_btn.pressed.emit()
		for i in 3:
			await get_tree().process_frame
		_cek("tekan tombol ○ -> sinyal reset_requested", _reset_ditekan)
	ui.reset_requested.connect(_main._respawn_ke_spawn)
	# Kamera di STRIP ATAS (B rev1 — dulu □): lepas handler main
	# dulu (supaya mode tidak ikut berubah saat tes sinyal), lalu
	# sambung lagi.
	ui.kamera_mode_pressed.connect(func() -> void: _kamera_ditekan = true)
	ui.kamera_mode_pressed.disconnect(_main._ganti_mode_kamera)
	var kamera_btn: Button = ui._kamera_ikon_btn
	_cek("tombol kamera strip atas ada", kamera_btn != null)
	if kamera_btn != null:
		kamera_btn.pressed.emit()
		for i in 3:
			await get_tree().process_frame
		_cek("tekan tombol kamera strip atas -> sinyal kamera_mode_pressed", _kamera_ditekan)
	ui.kamera_mode_pressed.connect(_main._ganti_mode_kamera)
	# ✕ Interact: lepas handler main dulu (supaya tidak memicu aksi
	# dunia di dekat penanda M1), lalu sambung lagi.
	ui.interact_pressed.connect(func() -> void: _interact_ditekan = true)
	ui.interact_pressed.disconnect(_main._on_interact)
	ui.set_interact_visible(true, "MULAI MISI")
	var interact_btn := ui._tombol_gamepad.get("x") as Button
	_cek("tombol ✕ Interact ada di diamond", interact_btn != null)
	if interact_btn != null:
		interact_btn.pressed.emit()
		for i in 3:
			await get_tree().process_frame
		_cek("tekan tombol ✕ -> sinyal interact_pressed", _interact_ditekan)
	ui.interact_pressed.connect(_main._on_interact)

	# --- 3. Mode kamera tetap terbaca (.text saja — di tombol kamera
	# strip atas, kontrak test_kamera.gd) ---
	_cek("teks kamera awal 'Kamera: Normal'", ui._kamera_ikon_btn.text == "Kamera: Normal")
	ui.set_mode_kamera("Drone")
	_cek("mode Drone: teks 'Kamera: Drone'", ui._kamera_ikon_btn.text == "Kamera: Drone")
	ui.set_mode_kamera("Low Angle")
	_cek("mode Low Angle: teks 'Kamera: Low Angle'", ui._kamera_ikon_btn.text == "Kamera: Low Angle")
	ui.set_mode_kamera("High Angle")
	_cek("mode High Angle: teks 'Kamera: High Angle'", ui._kamera_ikon_btn.text == "Kamera: High Angle")
	ui.set_mode_kamera("Sinematik")
	_cek("mode Sinematik: teks 'Kamera: Sinematik'", ui._kamera_ikon_btn.text == "Kamera: Sinematik")
	ui.set_mode_kamera("Normal")

	# --- 4. Suara + Layar Penuh: teks + varian icon ---
	ui.set_suara_mati(true)
	_cek("senyap: teks 'Senyap' + icon dicoret", ui._suara_btn.text == "Senyap" and String(ui._ikon_dari(ui._suara_btn).varian) == "senyap")
	ui.set_suara_mati(false)
	_cek("bunyi: teks 'Suara' + icon berombak", ui._suara_btn.text == "Suara" and String(ui._ikon_dari(ui._suara_btn).varian) == "nyala")
	ui._atur_teks_tombol_layar_penuh(true)
	_cek("penuh: teks 'Keluar Layar' + icon ciut", ui._layar_penuh_btn.text == "Keluar Layar" and String(ui._ikon_dari(ui._layar_penuh_btn).varian) == "ciut")
	ui._atur_teks_tombol_layar_penuh(false)
	_cek("jendela: teks 'Layar Penuh' + icon expand", ui._layar_penuh_btn.text == "Layar Penuh" and String(ui._ikon_dari(ui._layar_penuh_btn).varian) == "expand")

	# --- 5. Diamond gamepad: geometri ---
	ui.set_interact_visible(true, "MULAI MISI")
	var tombol := {
		"segitiga": ui._tombol_gamepad.get("segitiga") as Button,
		"kotak": ui._tombol_gamepad.get("kotak") as Button,
		"lingkaran": ui._tombol_gamepad.get("lingkaran") as Button,
		"x": ui._tombol_gamepad.get("x") as Button,
	}
	var pusat := {}
	var semua_ada := true
	var semua_sama := true
	for k in tombol.keys():
		var b := tombol[k] as Button
		if b == null:
			semua_ada = false
			continue
		pusat[k] = _r(b).get_center()
		if b.size != Vector2(100, 100):
			semua_sama = false
	_cek("diamond: 4 tombol ada", semua_ada)
	_cek("diamond: keempat tombol ukuran SAMA 100x100", semua_sama)
	if semua_ada:
		var c_segitiga: Vector2 = pusat["segitiga"]
		var c_kotak: Vector2 = pusat["kotak"]
		var c_lingkaran: Vector2 = pusat["lingkaran"]
		var c_x: Vector2 = pusat["x"]
		_cek("diamond: △ paling atas", c_segitiga.y < c_kotak.y and c_segitiga.y < c_lingkaran.y)
		_cek("diamond: ✕ paling bawah", c_x.y > c_kotak.y and c_x.y > c_lingkaran.y)
		_cek("diamond: □ paling kiri, ○ paling kanan", c_kotak.x < c_segitiga.x and c_segitiga.x < c_lingkaran.x)
		var jarak_ok := true
		for pasang in [["segitiga", "kotak"], ["segitiga", "lingkaran"], ["kotak", "x"], ["lingkaran", "x"]]:
			var d: float = (pusat[pasang[0]] as Vector2).distance_to(pusat[pasang[1]] as Vector2)
			if d < 100.0:
				jarak_ok = false
				print("JARAK DISK: %s-%s = %.1f < 100" % [pasang[0], pasang[1], d])
		_cek("diamond: disc bersebelahan tidak tumpang (jarak pusat >= 100)", jarak_ok)
		var dalam := true
		for k in tombol.keys():
			var rc := _r(tombol[k] as Button)
			if rc.position.x < 0.0 or rc.position.y < 0.0 or rc.end.x > vp.x or rc.end.y > vp.y:
				dalam = false
		_cek("diamond: semua tombol di dalam viewport portrait", dalam)
		_cek("diamond: tidak menabrak joystick", not _r(tombol["kotak"]).intersects(_r(ui._joystick)) and not _r(tombol["x"]).intersects(_r(ui._joystick)))
		_cek("diamond: tidak menabrak minimap", not _r(tombol["segitiga"]).intersects(_r(ui._minimap)) and not _r(tombol["kotak"]).intersects(_r(ui._minimap)))

	# --- 6. Main Bersama + Interact tidak berubah ---
	_cek("Main Bersama: teks + terlihat + posisi (216,116)", ui._mp_gabung_btn.text == "Main Bersama" and ui._mp_gabung_btn.visible and ui._mp_gabung_btn.position == Vector2(216, 116))
	ui.set_interact_visible(true, "BUKA PETI")
	_cek("interact: .text ikut 'BUKA PETI'", ui._interact_btn.text == "BUKA PETI")
	ui.set_interact_visible(false)
	_cek("interact: sembunyi saat tidak ada interaksi", not ui._interact_btn.visible)
	ui.set_interact_visible(true, "MULAI MISI")

	# --- 7. Wajah B rev1 (GayaTombol kaca bertinta, tanpa bayang) ---
	_cek("B rev1: ✕ punya wajah disc 100x100", _punya_wajah(ui._interact_btn, 100, 100))
	_cek("B rev1: △ punya wajah disc 100x100", _punya_wajah(aksi_btn, 100, 100))
	_cek("B rev1: □ punya wajah disc 100x100", _punya_wajah(ui._chat_btn, 100, 100))
	_cek("B rev1: ○ punya wajah disc 100x100", _punya_wajah(reset_btn, 100, 100))
	_cek("B rev1: wajah ✕ kaca bertinta alpha 150", _wajah_tengah_kaca(ui._interact_btn, 150.0 / 255.0))
	_cek("B rev1: wajah △ kaca bertinta alpha 150", _wajah_tengah_kaca(aksi_btn, 150.0 / 255.0))
	_cek("B rev1: wajah □ kaca bertinta alpha 150", _wajah_tengah_kaca(ui._chat_btn, 150.0 / 255.0))
	_cek("B rev1: wajah ○ kaca bertinta alpha 150", _wajah_tengah_kaca(reset_btn, 150.0 / 255.0))
	_cek("B rev1: tombol gamepad hanya 1 TextureRect (tanpa bayang)", _jumlah_wajah(ui._interact_btn) == 1 and _jumlah_wajah(aksi_btn) == 1 and _jumlah_wajah(ui._chat_btn) == 1 and _jumlah_wajah(reset_btn) == 1)
	var bar_wajah := true
	var bar_putih := true
	if bar != null:
		for a in bar.get_children():
			if not _punya_wajah(a as Button, 64, 64):
				bar_wajah = false
			if not _wajah_tengah_putih(a as Button, 0.5):
				bar_putih = false
	_cek("v3: 6 tombol bar atas punya wajah 64x64", bar_wajah)
	_cek("v3: wajah bar atas putih tengah alpha 0.5", bar_putih)
	_cek("B rev1: Main Bersama punya wajah pill 200x56 kaca alpha 150", _punya_wajah(ui._mp_gabung_btn, 200, 56) and _wajah_tengah_kaca(ui._mp_gabung_btn, 150.0 / 255.0))
	_cek("B rev1: teks pill Main Bersama ZAMRUD GELAP", ui._mp_gabung_btn.get_theme_color("font_color").is_equal_approx(GayaTombol.ZAMRUD_GELAP))
	_cek("B rev1: joystick gaya v3 + terlihat + 220x220", SantriJoystick.GAYA_V3 and ui._joystick.visible and ui._joystick.size == Vector2(220, 220))
	var wajah_interact := ui._interact_btn.get_meta("wajah") as TextureRect
	ui._interact_btn.button_down.emit()
	_cek("v3: wajah menggelap saat ditekan", wajah_interact.modulate == Color(0.7, 0.7, 0.7))
	ui._interact_btn.button_up.emit()
	_cek("v3: wajah pulih saat dilepas", wajah_interact.modulate == Color.WHITE)

	# --- 8. Icon bentuk outline tebal + tanpa teks di tombol ---
	var jenis_harapan := {"segitiga": "segitiga", "kotak": "kotak", "lingkaran": "lingkaran", "x": "x"}
	var ikon_ok := true
	var tanpa_teks := true
	for k in tombol.keys():
		var b := tombol[k] as Button
		if b == null:
			ikon_ok = false
			tanpa_teks = false
			continue
		var ikon := _ikon_tombol(b)
		if ikon == null or String(ikon.jenis) != String(jenis_harapan[k]):
			ikon_ok = false
		elif ikon.bayangan:
			ikon_ok = false
		elif not ikon.warna.is_equal_approx(GayaTombol.ZAMRUD_GELAP):
			ikon_ok = false
		elif absf(ikon.tebal_tipis - 4.0) > 0.01:
			ikon_ok = false
		for c in b.get_children():
			if c is Label:
				tanpa_teks = false
	_cek("B rev1: tiap tombol punya icon bentuk yang benar (△□○✕)", ikon_ok)
	_cek("B rev1: icon bentuk tanpa bayangan, ZAMRUD GELAP, garis 4 (X 5)", ikon_ok)
	_cek("v3: TIDAK ADA teks/label di dalam tombol gamepad", tanpa_teks)

	# --- 9. Pemetaan contoh (tabel) ---
	_cek("B rev1: PEMETAAN_TOMBOL_GAMEPAD sesuai contoh ACC (□=chat)", PesantrenUI.PEMETAAN_TOMBOL_GAMEPAD == {"x": "interact", "segitiga": "aksi", "kotak": "chat", "lingkaran": "reset"})
	_cek("v3: tombol gamepad membawa meta bentuk yang benar", String((ui._tombol_gamepad.get("x") as Button).get_meta("bentuk")) == "x" and String((ui._tombol_gamepad.get("segitiga") as Button).get_meta("bentuk")) == "segitiga" and String((ui._tombol_gamepad.get("kotak") as Button).get_meta("bentuk")) == "kotak" and String((ui._tombol_gamepad.get("lingkaran") as Button).get_meta("bentuk")) == "lingkaran")

	# --- 10. Pop-up "PETUNJUK TOMBOL" ---
	_cek("v3: pop-up masih tampil (flag false)", ui.is_petunjuk_visible())
	var teks_popup := _teks_label_di(ui._petunjuk_panel)
	_cek("B rev1: pop-up berisi judul + 4 fungsi + catatan + Mengerti", teks_popup.has("PETUNJUK TOMBOL") and teks_popup.has("Aksi") and teks_popup.has("Chat") and teks_popup.has("Reset") and teks_popup.has("Mulai Misi") and teks_popup.has("Kamera ada di menu atas • Fungsi tombol berubah sesuai misi") and teks_popup.has("Mengerti"))
	_cek("B rev1: dim pop-up alpha 80", absf(ui._petunjuk_dim.color.a - 80.0 / 255.0) < 0.01)
	var gaya_panel := ui._petunjuk_panel.get_theme_stylebox("panel") as StyleBoxFlat
	_cek("B rev1: panel pop-up alpha 225 (hampir pekat)", gaya_panel != null and absf(gaya_panel.bg_color.a - 225.0 / 255.0) < 0.01)
	var ikon_popup: Array[String] = []
	var ikon_popup_hitam := true
	var tumpuk_popup: Array[Node] = [ui._petunjuk_panel]
	while not tumpuk_popup.is_empty():
		var m: Node = tumpuk_popup.pop_back()
		if m is IkonHUD:
			ikon_popup.append(String((m as IkonHUD).jenis))
			var w := (m as IkonHUD).warna
			if w.r > 0.05 or w.g > 0.05 or w.b > 0.05:
				ikon_popup_hitam = false
		for c in m.get_children():
			tumpuk_popup.append(c)
	_cek("v3: pop-up berisi 4 bentuk △□○✕", ikon_popup.has("segitiga") and ikon_popup.has("kotak") and ikon_popup.has("lingkaran") and ikon_popup.has("x"))
	_cek("v3: bentuk + teks pop-up HITAM (terbaca)", ikon_popup_hitam)
	var panel_rect := _r(ui._petunjuk_panel)
	var panel_tutup := true
	for k in tombol.keys():
		if panel_rect.intersects(_r(tombol[k] as Button)):
			panel_tutup = false
	if panel_rect.intersects(_r(ui._joystick)):
		panel_tutup = false
	_cek("v3: pop-up tidak menutupi klaster tombol maupun analog", panel_tutup)
	# Tutup via "Mengerti" -> flag save true.
	ui._petunjuk_mengerti_btn.pressed.emit()
	for i in 3:
		await get_tree().process_frame
	_cek("v3: tutup via Mengerti -> pop-up hilang", not ui.is_petunjuk_visible())
	_cek("v3: tutup via Mengerti -> flag save true", bool(_main._save.get("petunjuk_tombol_ditutup", false)))
	# Flag true -> tidak muncul lagi.
	ui.coba_tampilkan_petunjuk_awal(true)
	_cek("v3: flag true -> pop-up tidak muncul lagi", not ui.is_petunjuk_visible())
	# Tampilkan lagi (flag false) -> tutup via ×.
	_main._save["petunjuk_tombol_ditutup"] = false
	ui.coba_tampilkan_petunjuk_awal(false)
	_cek("v3: flag false -> pop-up tampil lagi", ui.is_petunjuk_visible())
	ui._petunjuk_tutup_btn.pressed.emit()
	for i in 3:
		await get_tree().process_frame
	_cek("v3: tutup via × -> pop-up hilang + flag save true", not ui.is_petunjuk_visible() and bool(_main._save.get("petunjuk_tombol_ditutup", false)))

	# --- 11. GEDUNG_PUTRI: Asrama Putri baru ---
	var asrama_putri_ok := false
	for gedung in PesantrenUI.PetaControl.GEDUNG_PUTRI:
		if String(gedung[0]) == "ASRAMA PUTRI":
			asrama_putri_ok = (gedung[1] as Vector2) == Vector2(155, 0) and (gedung[2] as Vector2) == Vector2(21.5, 12)
	_cek("v3: GEDUNG_PUTRI Asrama Putri (155,0) ukuran (21.5,12)", asrama_putri_ok)

	print("TES HUD ROMBAK: %d lulus, %d gagal" % [_lulus, _gagal])
	# Pulihkan save asli sebelum quit (pola foto_kamera_mode.gd).
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	_main._save["petunjuk_tombol_ditutup"] = _flag_petunjuk_asli
	SantriSave.save_data(_main._save)
	get_tree().quit(0 if _gagal == 0 else 1)
