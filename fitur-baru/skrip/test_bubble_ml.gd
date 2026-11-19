extends Node
## Tes BUBBLE-ML (Gita, 17 Nov 2026) — koreksi Mas ~21:30 WIB: bubble
## kotak di atas kepala jelek, ganti feed teks melayang ala Mobile
## Legends di sebelah analog (kiri bawah, di atas joystick).
##
## Dijalankan sebagai SCENE:
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --resolution 1280x720 \
##     --path . test_bubble_ml.tscn
## (TANPA --headless — headless membuat save_png null; tes ini tidak
## memotret, tapi pola scene-nya sama seperti test_fullscreen.gd.)
##
## Yang dibuktikan:
##  A. Bubble 3D MATI: show_chat pemain + say() NPC tidak pernah
##     menyalakan Label3D _bubble (langsung + setelah 6 dtk).
##  B. Sinyal NPC: say() memancarkan pesan(nama, teks) — jalur yang
##     disambung main.gd ke feed (Raka).
##  C. Panel ketik chat TETAP jalan: buka -> ketik -> kirim -> baris
##     masuk riwayat panel + panel menutup (perilaku Eka dipertahankan).
##  D. Feed ML (HANYA kalau patch ui_feed_ml.patch sudah dipasang —
##     sebelum GO Cakra bagian ini DILEWATI, bukan gagal): 4 pesan ->
##     maks 3 baris, yang paling lama dibuang, pesan baru di bawah;
##     feed di atas joystick (tidak menutupinya); tanpa kotak/border
##     (tidak ada Panel/PanelContainer di subtree feed); tiap baris
##     hilang sendiri ~4 dtk.
##  E. Smoke 300 frame tanpa error.
## Keluar 0 bila semua LOLOS (bagian D yang dilewati tidak dihitung).

var _main: Node
var _ui: Node
var _player: Node
var _lolos := 0
var _gagal := 0
var _dilewati := 0
var _pesan_terakhir := ["", ""]


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_ui = _main._ui
	_player = _main._player
	# Masuk langsung TANPA login server (pola foto_cuaca.gd).
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes bubble ML")
	await get_tree().process_frame
	await get_tree().process_frame
	await _tes_bubble_mati()
	_tes_sinyal_npc()
	await _tes_panel_chat()
	await _tes_feed()
	await _tes_tanpa_kotak()
	print("HASIL TES BUBBLE-ML: %d LOLOS / %d GAGAL / %d DILEWATI (feed menunggu GO)" % [_lolos, _gagal, _dilewati])
	for i in 300:
		await get_tree().process_frame
	print("SMOKE 300 FRAME SELESAI")
	get_tree().quit(0 if _gagal == 0 else 1)


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lolos += 1
		print("  LOLOS: %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("  GAGAL: %s %s" % [nama, detail])


func _lewati(nama: String) -> void:
	_dilewati += 1
	print("  LEWATI: %s (feed ui.gd belum dipasang — menunggu GO Cakra)" % nama)


# ---------- A. Bubble 3D mati ----------
func _tes_bubble_mati() -> void:
	_cek("node bubble pemain tetap ada (kontrak build_visual)", _player._bubble != null)
	_cek("bubble pemain tersembunyi saat masuk dunia", not _player._bubble.visible)
	# set_bubble_ditahan kini no-op — tidak boleh menyalakan bubble.
	_player.set_bubble_ditahan(true)
	_player.show_chat("halo tes bubble")
	_cek("show_chat tidak menyalakan bubble (ditahan)", not _player._bubble.visible)
	_player.set_bubble_ditahan(false)
	_player.show_chat("halo tes bubble lagi")
	_cek("show_chat tidak menyalakan bubble (tidak ditahan)", not _player._bubble.visible)
	var npc = _main._npcs[0]
	_cek("bubble NPC tersembunyi saat masuk dunia", not npc._bubble.visible)
	npc.say("halo dari NPC")
	_cek("npc.say tidak menyalakan bubble", not npc._bubble.visible)
	# Tunggu 6 dtk WAKTU GAME (> durasi bubble lama 5 dtk): tidak ada
	# yang muncul belakangan (timer lama / _process yang menampilkan
	# ulang). Berbasis waktu, bukan jumlah frame — di xvfb (render
	# software, ~1-2 fps) 360 frame = puluhan detik waktu game.
	var mulai := Time.get_ticks_msec()
	while Time.get_ticks_msec() - mulai < 6000:
		await get_tree().process_frame
	_cek("bubble pemain tetap mati setelah 6 dtk", not _player._bubble.visible)
	_cek("bubble NPC tetap mati setelah 6 dtk", not npc._bubble.visible)


# ---------- B. Sinyal NPC ----------
func _catat_pesan(nama: String, teks: String) -> void:
	_pesan_terakhir = [nama, teks]


func _tes_sinyal_npc() -> void:
	var npc = _main._npcs[0]
	npc.pesan.connect(_catat_pesan)
	npc.say("Ayo sholat berjamaah di Surau!")
	_cek("say() memancarkan sinyal pesan", _pesan_terakhir[0] == "Bilal" and _pesan_terakhir[1] == "Ayo sholat berjamaah di Surau!",
		"(%s: %s)" % [_pesan_terakhir[0], _pesan_terakhir[1]])
	# Teks panjang tetap dipotong rapi 100 karakter (perilaku lama).
	npc.say("x".repeat(150))
	_cek("sinyal pesan memotong teks panjang + ...", _pesan_terakhir[1].length() <= 101 and _pesan_terakhir[1].ends_with("…"),
		"panjang=%d" % _pesan_terakhir[1].length())


# ---------- C. Panel ketik chat tetap jalan ----------
func _tes_panel_chat() -> void:
	_cek("panel chat tertutup saat masuk dunia", not _ui.is_chat_visible())
	_ui._toggle_chat()
	await get_tree().process_frame
	_cek("panel chat terbuka lewat tombol Chat", _ui.is_chat_visible())
	var sebelum: int = _ui._chat_lines.size()
	_ui._chat_input.text = "halo panel tes"
	_ui._on_chat_submit("")
	await get_tree().process_frame
	_cek("kirim chat menambah 1 baris riwayat panel", _ui._chat_lines.size() == sebelum + 1)
	_cek("baris riwayat berisi teks yang dikirim", (_ui._chat_lines[_ui._chat_lines.size() - 1] as Label).text.contains("halo panel tes"))
	_cek("panel menutup sendiri setelah kirim (perilaku Eka)", not _ui.is_chat_visible())


# ---------- D. Feed ML (dilewati bila patch belum dipasang) ----------
func _tes_feed() -> void:
	if not _ui.has_method("tampilkan_pesan_melayang"):
		_lewati("feed: 4 pesan -> maks 3 baris")
		_lewati("feed: posisi di atas joystick")
		_lewati("feed: baris hilang ~4 dtk")
		return
	_ui.tampilkan_pesan_melayang("Tes", "UJI1 pemain")
	_ui.tampilkan_pesan_melayang("Bilal", "UJI2 npc")
	_ui.tampilkan_pesan_melayang("Faris", "UJI3 npc")
	_ui.tampilkan_pesan_melayang("Tes", "UJI4 pemain lagi")
	await get_tree().process_frame
	await get_tree().process_frame
	_cek("feed maks 3 baris setelah 4 pesan", _ui.jumlah_pesan_melayang() == 3,
		"jumlah=%d" % _ui.jumlah_pesan_melayang())
	_cek("feed membuang yang paling lama, pesan baru di bawah",
		_ui.pesan_melayang_terlihat() == ["UJI2 npc", "UJI3 npc", "UJI4 pemain lagi"],
		"terlihat=%s" % str(_ui.pesan_melayang_terlihat()))
	# Posisi: bawah feed di atas joystick, kiri sejajar joystick.
	var r_feed: Rect2 = _ui._feed_chat.get_global_rect()
	var r_joy: Rect2 = _ui._joystick.get_global_rect()
	_cek("feed di atas joystick (tidak menutupinya)", r_feed.end.y <= r_joy.position.y + 1.0,
		"feed bawah=%.0f joystick atas=%.0f" % [r_feed.end.y, r_joy.position.y])
	_cek("feed sejajar kiri joystick", absf(r_feed.position.x - r_joy.position.x) < 1.0)
	# Tiap baris hilang sendiri ~4 dtk: tunggu sampai tidak ada lagi
	# baris UJI (polling maks ~10 dtk; obrolan acak NPC tidak diawali
	# "UJI" jadi tidak mengacaukan).
	var hilang := false
	for i in 600:
		await get_tree().process_frame
		var masih_uji := false
		for t in _ui.pesan_melayang_terlihat():
			if t.begins_with("UJI"):
				masih_uji = true
		if not masih_uji:
			hilang = true
			break
	_cek("baris feed hilang sendiri ~4 dtk", hilang)


# ---------- D2. Tanpa kotak/border (dilewati bila patch belum dipasang) ----------
func _tes_tanpa_kotak() -> void:
	if not _ui.has_method("tampilkan_pesan_melayang"):
		_lewati("feed: tanpa Panel/kotak")
		return
	_ui.tampilkan_pesan_melayang("Tes", "UJI kotak")
	await get_tree().process_frame
	var ada_kotak := false
	for node in _semua_turunan(_ui._feed_chat):
		if node is Panel or node is PanelContainer:
			ada_kotak = true
	_cek("feed tanpa Panel/PanelContainer (tanpa kotak)", not ada_kotak)
	# Label baris tidak memakai stylebox latar.
	var ada_stylebox := false
	for node in _semua_turunan(_ui._feed_chat):
		if node is Label and (node as Label).has_theme_stylebox_override("panel"):
			ada_stylebox = true
	_cek("label feed tanpa stylebox latar", not ada_stylebox)


func _semua_turunan(node: Node) -> Array[Node]:
	var hasil: Array[Node] = []
	for c in node.get_children():
		hasil.append(c)
		hasil.append_array(_semua_turunan(c))
	return hasil
