extends Control
## UI uji spike pemutar video (cara A RB v3).
## Tata letak TETAP (koordinat dikenal skrip uji puppeteer):
## tombol x=20 w=280 h=44, y mulai 60 langkah 54;
## label status x=330 w=920; log di bawah (20,560,1240,148).

var pemutar: PemutarVideoSpike
var _log_lines: Array[String] = []

var lbl_jsb: Label
var lbl_status: Label
var lbl_posisi: Label
var lbl_ditonton: Label
var lbl_gate: Label
var lbl_autoplay: Label
var lbl_video: Label
var lbl_log: Label
var btn_lanjut: Button


func _ready() -> void:
	pemutar = PemutarVideoSpike.new()
	add_child(pemutar)
	pemutar.metadata_diterima.connect(_on_meta)
	pemutar.waktu_berubah.connect(_on_waktu)
	pemutar.video_selesai.connect(_on_selesai)
	pemutar.galat.connect(_on_galat)
	_bangun_ui()
	_perbarui_label()
	_log("Spike dimulai. di_web=%s jsb=%s" % [str(pemutar.di_web()), str(Engine.get_singleton("JavaScriptBridge") != null)])
	if pemutar.di_web():
		var jsb = Engine.get_singleton("JavaScriptBridge")
		jsb.eval("window.__pv_spike_siap = true; console.log('[SPIKE] SIAP');")
		print("[SPIKE] SIAP")
	else:
		_log("BUKAN export web — tombol tidak akan berfungsi (butuh browser).")


func _bangun_ui() -> void:
	var judul := Label.new()
	judul.text = "SPIKE PEMUTAR VIDEO — cara A (elemen <video> HTML + JavaScriptBridge)"
	judul.position = Vector2(20, 12)
	judul.size = Vector2(1240, 30)
	judul.add_theme_font_size_override("font_size", 22)
	add_child(judul)

	var defs: Array = [
		["muat", "1. Muat Video", 60, _on_btn_muat],
		["putar", "2. Putar", 114, _on_btn_putar],
		["jeda", "3. Jeda", 168, _on_btn_jeda],
		["seek25", "4. Seek ke 25 dtk", 222, _on_btn_seek25],
		["seek5", "5. Seek ke 5 dtk", 276, _on_btn_seek5],
		["sembunyi", "6. Sembunyikan", 330, _on_btn_sembunyi],
		["tampil", "7. Tampilkan", 384, _on_btn_tampil],
		["fullscreen", "8. Layar Penuh", 438, _on_btn_fullscreen],
		["hapus", "9. Hapus Video", 492, _on_btn_hapus],
	]
	for d in defs:
		var b := Button.new()
		b.name = "btn_" + String(d[0])
		b.text = String(d[1])
		b.position = Vector2(20, float(d[2]))
		b.size = Vector2(280, 44)
		b.pressed.connect(d[3])
		add_child(b)

	lbl_jsb = _buat_label("lbl_jsb", 60)
	lbl_status = _buat_label("lbl_status", 90)
	lbl_posisi = _buat_label("lbl_posisi", 120)
	lbl_ditonton = _buat_label("lbl_ditonton", 150)
	lbl_gate = _buat_label("lbl_gate", 180)
	lbl_autoplay = _buat_label("lbl_autoplay", 210)
	lbl_video = _buat_label("lbl_video", 240)

	btn_lanjut = Button.new()
	btn_lanjut.name = "btn_lanjut"
	btn_lanjut.text = "Lanjut ke Latihan › (terkunci — gate 80%)"
	btn_lanjut.position = Vector2(330, 300)
	btn_lanjut.size = Vector2(420, 44)
	btn_lanjut.disabled = true
	add_child(btn_lanjut)

	lbl_log = Label.new()
	lbl_log.name = "lbl_log"
	lbl_log.position = Vector2(20, 560)
	lbl_log.size = Vector2(1240, 148)
	lbl_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_log.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	lbl_log.add_theme_font_size_override("font_size", 14)
	add_child(lbl_log)


func _buat_label(nama: String, y: float) -> Label:
	var l := Label.new()
	l.name = nama
	l.position = Vector2(330, y)
	l.size = Vector2(920, 28)
	l.add_theme_font_size_override("font_size", 18)
	add_child(l)
	return l


func _log(teks: String) -> void:
	var stempel := "[%d] %s" % [Time.get_ticks_msec() / 1000, teks]
	_log_lines.append(stempel)
	if _log_lines.size() > 6:
		_log_lines.remove_at(0)
	lbl_log.text = "\n".join(_log_lines)
	print("[SPIKE] ", teks)


func _perbarui_label() -> void:
	lbl_jsb.text = "JavaScriptBridge: %s (di_web=%s)" % ["ADA" if pemutar.di_web() else "TIDAK ADA", str(pemutar.di_web())]
	lbl_status.text = "Status: %s" % ("MEMUTAR" if pemutar.sedang_putar else ("dimuat" if pemutar.sudah_dimuat else "belum dimuat"))
	lbl_posisi.text = "Posisi: %.1f / %.1f dtk" % [pemutar.posisi, pemutar.durasi]
	lbl_ditonton.text = "Ditonton kumulatif: %.1f dtk" % pemutar.ditonton
	var persen := pemutar.persen_gate()
	lbl_gate.text = "Gate 80%%: %.0f%% %s (butuh %.1f dtk dari %.1f)" % [persen, "TERCAPAI ✓" if pemutar.gate_tercapai() else "belum", pemutar.durasi * 0.8, pemutar.durasi]
	var st := pemutar.status_js()
	if st.is_empty():
		lbl_autoplay.text = "Autoplay tanpa gestur: (belum ada video)"
		lbl_video.text = "Elemen video: tidak ada"
	else:
		var ap = st.get("autoplay", null)
		if ap is Dictionary:
			lbl_autoplay.text = "Autoplay tanpa gestur: ok=%s err=%s" % [str(ap.get("ok", "?")), str(ap.get("err", ""))]
		else:
			lbl_autoplay.text = "Autoplay tanpa gestur: (menunggu metadata)"
		lbl_video.text = "Elemen video: tampil=%s jeda=%s berakhir=%s" % [str(st.get("tampil", "?")), str(st.get("jeda", "?")), str(st.get("berakhir", "?"))]
	btn_lanjut.disabled = not pemutar.gate_tercapai()
	if pemutar.gate_tercapai():
		btn_lanjut.text = "Lanjut ke Latihan › (TERBUKA)"


func _on_meta(durasi: float) -> void:
	_log("metadata diterima: durasi %.1f dtk" % durasi)
	_perbarui_label()


func _on_waktu(posisi: float, ditonton: float, durasi: float) -> void:
	_perbarui_label()


func _on_selesai() -> void:
	_log("video berakhir (ended). Ditonton kumulatif %.1f dtk." % pemutar.ditonton)
	_perbarui_label()


func _on_galat(pesan: String) -> void:
	_log("GALAT: " + pesan)
	_perbarui_label()


func _on_btn_muat() -> void:
	_log("tombol: Muat Video")
	pemutar.muat("episode-contoh.mp4")
	_perbarui_label()


func _on_btn_putar() -> void:
	_log("tombol: Putar")
	pemutar.putar()
	_perbarui_label()


func _on_btn_jeda() -> void:
	_log("tombol: Jeda")
	pemutar.jeda()
	_perbarui_label()


func _on_btn_seek25() -> void:
	_log("tombol: Seek ke 25 dtk (uji gate — TIDAK boleh menambah hitungan)")
	pemutar.seek(25.0)


func _on_btn_seek5() -> void:
	_log("tombol: Seek ke 5 dtk")
	pemutar.seek(5.0)


func _on_btn_sembunyi() -> void:
	_log("tombol: Sembunyikan")
	pemutar.sembunyikan()


func _on_btn_tampil() -> void:
	_log("tombol: Tampilkan")
	pemutar.tampilkan()


func _on_btn_fullscreen() -> void:
	_log("tombol: Layar Penuh")
	pemutar.minta_layar_penuh()


func _on_btn_hapus() -> void:
	_log("tombol: Hapus Video")
	pemutar.hapus()
	_perbarui_label()
