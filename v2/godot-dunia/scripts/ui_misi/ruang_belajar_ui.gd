class_name RuangBelajarUI
extends PanelContainer
## Ruang Belajar — chat gaya Genshin (Sinta, 19 Nov 2026).
## Konsep v2/konsep/KONSEP-RUANG-BELAJAR-CHAT-v1.md §7+§8 (ACC Mas
## 19 Nov 15:18 — versi DUDUK): ustadz DUDUK di dunia (adegan di
## main.gd), kotak dialog bawah gelap tembus pandang + garis emas
## tepi atas, nama emas, gelembung kecil player, pilihan melayang,
## Auto (chip milik manajer, kiri atas layar), Riwayat, bilah emas
## tipis TANPA teks penghitung (koreksi Mas 15:09).
##
## KONTRAK (tetap — manajer/main tidak berubah): class_name,
## sinyal langkah_selesai(jenis, poin) / selesai(poin_total) /
## ditutup, tampilkan(pengajar, save). Sinyal BARU: papan_berubah
## (judul, baris) untuk papan tulis di dunia + kemajuan_disimpan
## (pos_id, modul) untuk resume.
##
## BICARA, bukan mengetik (§8): TIDAK ADA teks "sedang mengetik"
## di mana pun; huruf muncul satu-satu ±40 ms/huruf sebagai EFEK
## BICARA (kursor blok emas yang digambar — "[bgcolor]" di
## RichTextLabel, BUKAN glif font); tap kotak dialog = tampil
## penuh; pilihan TIDAK TAMPIL selama ustadz bicara, muncul
## langsung AKTIF penuh begitu kalimat selesai.
##
## Aturan pilihan (§8): tombol jawaban TIDAK PERNAH redup/
## terkunci. Opsi soal yang sudah dijawab salah DIHILANGKAN dari
## pilihan saat soal diulang (bukan di-disabled) — "dimatikan"
## §2 tanpa pernah menampilkan tombol redup.
##
## Alur: DataChatModul01 (14 pesan + cabang Belum maks 2x).
## Poin: materi +10 / latihan +15 / kuis +10 = 35 (sinyal
## langkah_selesai per langkah + selesai(35) di penutup).
## Resume: rb_chat_pos = id node BERIKUTNYA yang akan tampil
## (bukan indeks — cabang b1/b2 membuat indeks linear tidak
## stabil; disimpan tiap node mulai, dibersihkan saat tuntas).
## Buka ulang setelah tuntas = mode baca ulang (tanpa poin).
## PERBAIKAN dari UI lama: mode baca ulang dulu memakai cek
## string pada rb_selesai (Array) sehingga selesai SEBAGIAN
## (mis. baru materi) sudah dianggap tuntas — kini ketiga
## langkah dicek satu-satu.
## MesinKuis TIDAK dipakai: graf node DataChatModul01 SUDAH
## menjadi mesin keadaan (pengulangan soal + cabang) — data
## soal/opsi/jawaban benar tetap dipakai ulang dari DataModul01
## lewat DataChatModul01.opsi_soal()/benar_soal().

signal langkah_selesai(jenis: String, poin: int)
signal selesai(poin_total: int)
signal ditutup
signal papan_berubah(judul: String, baris: PackedStringArray)
signal kemajuan_disimpan(pos_id: String, modul: int)
## Chip Auto milik manajer — emit tiap set_auto berubah supaya
## teks chip tidak pernah basi (foto memanggil set_auto langsung).
signal auto_berubah(v: bool)

const BICARA_MS_PER_HURUF := 40
const JEDA_OTOMATIS_DETIK := 0.8

var _pengajar := "Ust. Sanusi"
var _modul := 1
var _node_saat_ini: Dictionary = {}
var _teks_penuh := ""
var _huruf_tampil := 0
var _sedang_bicara := false
var _kursor_nyala := true
var _auto := true
var _baca_ulang := false
var _materi_selesai := false
var _latihan_selesai := false
var _kuis_selesai := false
var _ulang_materi := false
var _opsi_salah: Array = []
var _riwayat: Array = []
var _lanjut_tampil := false

var _avatar: AvatarMisi
var _nama_label: Label
var _gelembung_box: PanelContainer
var _gelembung_label: Label
var _pilihan_box: VBoxContainer
var _kotak_dialog: PanelContainer
var _pesan_label: RichTextLabel
var _bilah_progres: ProgressBar
var _log_overlay: PanelContainer
var _log_list: VBoxContainer
var _timer_bicara: Timer
var _timer_kedip: Timer
var _timer_otomatis: Timer


func _ready() -> void:
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var induk := VBoxContainer.new()
	# Rata BAWAH: kotak dialog menempel dasar layar, pilihan +
	# gelembung menumpuk di atasnya. Tanpa ini VBox menumpuk dari
	# ATAS root 475 px — kotak melayang di tengah layar dan dunia
	# di bawahnya kosong (cacat foto chat v1, 19 Nov).
	induk.alignment = BoxContainer.ALIGNMENT_END
	induk.add_theme_constant_override("separation", 10)
	add_child(induk)
	# Gelembung kecil player (kanan, di atas pilihan) — sembunyi
	# sampai player memilih jawaban.
	var baris_gelembung := HBoxContainer.new()
	baris_gelembung.alignment = BoxContainer.ALIGNMENT_END
	_gelembung_box = PanelContainer.new()
	_gelembung_box.add_theme_stylebox_override("panel", GayaMisi.gaya_gelembung_pemain())
	_gelembung_label = GayaMisi.buat_label("", 18, GayaMisi.ZAMRUD_GELAP)
	_gelembung_box.add_child(_gelembung_label)
	_gelembung_box.visible = false
	baris_gelembung.add_child(_gelembung_box)
	induk.add_child(baris_gelembung)
	# Pilihan melayang (kosong selama ustadz bicara).
	_pilihan_box = VBoxContainer.new()
	_pilihan_box.add_theme_constant_override("separation", 8)
	induk.add_child(_pilihan_box)
	# Kotak dialog bawah.
	_kotak_dialog = PanelContainer.new()
	_kotak_dialog.add_theme_stylebox_override("panel", GayaMisi.gaya_kotak_dialog_genshin())
	_kotak_dialog.gui_input.connect(_on_kotak_gui_input)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 6)
	_kotak_dialog.add_child(isi)
	var kepala := HBoxContainer.new()
	kepala.add_theme_constant_override("separation", 12)
	_avatar = AvatarMisi.new()
	_avatar.custom_minimum_size = Vector2(56, 56)
	_avatar.atur_tipe("sanusi")
	kepala.add_child(_avatar)
	var kolom_nama := VBoxContainer.new()
	kolom_nama.add_theme_constant_override("separation", 2)
	_nama_label = GayaMisi.buat_label_tebal(_pengajar, 22, GayaMisi.EMAS)
	kolom_nama.add_child(_nama_label)
	var garis_nama := ColorRect.new()
	garis_nama.color = GayaMisi.EMAS
	garis_nama.custom_minimum_size = Vector2(110, 2)
	kolom_nama.add_child(garis_nama)
	kepala.add_child(kolom_nama)
	var spasi := Control.new()
	spasi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kepala.add_child(spasi)
	var btn_riwayat := GayaMisi.buat_tombol_outline("Riwayat")
	btn_riwayat.pressed.connect(_buka_riwayat)
	kepala.add_child(btn_riwayat)
	var btn_tutup := Button.new()
	btn_tutup.text = "✕"
	btn_tutup.focus_mode = Control.FOCUS_NONE
	btn_tutup.add_theme_font_size_override("font_size", 22)
	btn_tutup.add_theme_color_override("font_color", GayaMisi.KREM)
	btn_tutup.add_theme_color_override("font_hover_color", GayaMisi.EMAS_TERANG)
	btn_tutup.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_tutup.pressed.connect(_tutup)
	kepala.add_child(btn_tutup)
	isi.add_child(kepala)
	_pesan_label = RichTextLabel.new()
	_pesan_label.bbcode_enabled = true
	_pesan_label.fit_content = false
	_pesan_label.scroll_active = true
	_pesan_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pesan_label.custom_minimum_size = Vector2(0, 96)
	_pesan_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_pesan_label.add_theme_font_size_override("normal_font_size", 21)
	_pesan_label.add_theme_color_override("default_color", GayaMisi.KREM)
	_pesan_label.add_theme_constant_override("line_separation", 6)
	_pesan_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	isi.add_child(_pesan_label)
	_bilah_progres = GayaMisi.buat_bilah_progres()
	_bilah_progres.custom_minimum_size = Vector2(0, 6)
	isi.add_child(_bilah_progres)
	induk.add_child(_kotak_dialog)
	# Overlay Riwayat (menutupi panel, dibuka dari tombol Riwayat).
	_log_overlay = PanelContainer.new()
	_log_overlay.add_theme_stylebox_override("panel", GayaMisi.gaya_kotak_dialog_genshin())
	_log_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_overlay.visible = false
	var log_v := VBoxContainer.new()
	log_v.add_theme_constant_override("separation", 10)
	var log_kepala := HBoxContainer.new()
	log_kepala.add_child(GayaMisi.buat_label_tebal("Riwayat Percakapan", 20, GayaMisi.EMAS))
	var spasi_log := Control.new()
	spasi_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_kepala.add_child(spasi_log)
	var btn_tutup_log := GayaMisi.buat_tombol_outline("Tutup")
	btn_tutup_log.pressed.connect(_tutup_riwayat)
	log_kepala.add_child(btn_tutup_log)
	log_v.add_child(log_kepala)
	var gulir := ScrollContainer.new()
	gulir.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log_list = VBoxContainer.new()
	_log_list.add_theme_constant_override("separation", 8)
	gulir.add_child(_log_list)
	log_v.add_child(gulir)
	_log_overlay.add_child(log_v)
	add_child(_log_overlay)
	# Timer: bicara (per huruf), kedip kursor, jeda otomatis.
	_timer_bicara = Timer.new()
	_timer_bicara.wait_time = float(BICARA_MS_PER_HURUF) / 1000.0
	_timer_bicara.timeout.connect(_on_timer_bicara)
	add_child(_timer_bicara)
	_timer_kedip = Timer.new()
	_timer_kedip.wait_time = 0.5
	_timer_kedip.timeout.connect(_on_timer_kedip)
	add_child(_timer_kedip)
	_timer_otomatis = Timer.new()
	_timer_otomatis.wait_time = JEDA_OTOMATIS_DETIK
	_timer_otomatis.one_shot = true
	_timer_otomatis.timeout.connect(_on_timer_otomatis)
	add_child(_timer_otomatis)
	visible = false


## Buka percakapan. save = kamus save pemain (untuk resume +
## mode baca ulang); {} = mulai dari awal.
func tampilkan(pengajar: String, save: Dictionary = {}) -> void:
	_pengajar = pengajar
	_modul = int(Onboarding.baca(save).get("modul", 1))
	_nama_label.text = pengajar
	_avatar.atur_tipe("ustadzah" if pengajar.contains("Fatimah") else "sanusi")
	var sudah: Array = save.get("rb_selesai", [])
	var m := str(_modul)
	_baca_ulang = sudah.has(m + ":materi") and sudah.has(m + ":latihan") and sudah.has(m + ":kuis")
	_materi_selesai = false
	_latihan_selesai = false
	_kuis_selesai = false
	_ulang_materi = false
	_opsi_salah.clear()
	_riwayat.clear()
	_hentikan_timer()
	_tutup_riwayat()
	visible = true
	var pos := String(save.get("rb_chat_pos", ""))
	if _baca_ulang:
		_bangun_log_baca_ulang()
		_tampilkan_node(DataChatModul01.cari(DataChatModul01.id_pertama()))
	elif pos != "" and not DataChatModul01.cari(pos).is_empty():
		_bangun_log_resume(pos)
		_tampilkan_node(DataChatModul01.cari(pos))
	else:
		_tampilkan_node(DataChatModul01.cari(DataChatModul01.id_pertama()))


## Auto ON/OFF (chip milik manajer). Bila dinyalakan saat sedang
## menunggu tombol Lanjut, lanjut otomatis sekarang.
func set_auto(v: bool) -> void:
	_auto = v
	auto_berubah.emit(v)
	if _auto and not _sedang_bicara and _lanjut_tampil and not _baca_ulang:
		_timer_otomatis.start()


func auto_aktif() -> bool:
	return _auto


## Id node yang sedang tampil (untuk tes + foto).
func node_saat_ini() -> String:
	return String(_node_saat_ini.get("id", ""))


## Apakah ustadz sedang bicara (efek huruf berjalan)?
func sedang_bicara() -> bool:
	return _sedang_bicara


## Jumlah baris di Riwayat (untuk tes).
func jumlah_riwayat() -> int:
	return _riwayat.size()


## Teks pesan yang sedang tampil (tanpa kursor) — untuk tes.
func teks_tampil() -> String:
	return _teks_penuh.substr(0, _huruf_tampil)


## Apakah ada tombol dalam keadaan disabled? (harus selalu false)
func ada_tombol_terkunci() -> bool:
	for b in _semua_tombol(_pilihan_box):
		if b.disabled:
			return true
	return false


func _semua_tombol(n: Node) -> Array[Button]:
	var out: Array[Button] = []
	for c in n.get_children():
		if c is Button:
			out.append(c)
		out.append_array(_semua_tombol(c))
	return out


func _bangun_log_resume(resume_id: String) -> void:
	_riwayat.clear()
	for id in DataChatModul01.jalur_log(resume_id):
		var n := DataChatModul01.cari(id)
		if not n.is_empty():
			_riwayat.append({"dari": "ustadz", "teks": String(n.get("teks", ""))})


func _bangun_log_baca_ulang() -> void:
	_riwayat.clear()
	for id in DataChatModul01.SPINE:
		var n := DataChatModul01.cari(id)
		if not n.is_empty():
			_riwayat.append({"dari": "ustadz", "teks": String(n.get("teks", ""))})


func _tampilkan_node(nod: Dictionary, jawaban_player: String = "") -> void:
	if nod.is_empty():
		return
	_node_saat_ini = nod
	_bersihkan_pilihan()
	if jawaban_player != "":
		_gelembung_label.text = jawaban_player
		_gelembung_box.visible = true
	else:
		_gelembung_box.visible = false
	var papan: Dictionary = nod.get("papan", {})
	if not papan.is_empty():
		var baris := PackedStringArray()
		for b in papan.get("baris", []):
			baris.append(String(b))
		papan_berubah.emit(String(papan.get("judul", "")), baris)
	var pid := String(nod.get("id", ""))
	if DataChatModul01.SPINE.has(pid) or pid == "b1" or pid == "b2":
		_bilah_progres.value = float(DataChatModul01.indeks_progres(pid)) / float(DataChatModul01.jumlah_pesan())
	_simpan_kemajuan(pid)
	_teks_penuh = String(nod.get("teks", ""))
	if _baca_ulang:
		# Baca ulang: tampil penuh tanpa efek bicara.
		_huruf_tampil = _teks_penuh.length()
		_sedang_bicara = false
		_render_teks()
		_tampilkan_pilihan()
		return
	_huruf_tampil = 0
	_sedang_bicara = true
	_kursor_nyala = true
	_render_teks()
	_timer_bicara.start()
	_timer_kedip.start()


func _simpan_kemajuan(id: String) -> void:
	# Hanya node nyata yang disimpan sebagai titik resume
	# (node sementara "_benar"/"_salah" tidak — titik resume
	# tetap di soal yang sedang dijawab).
	if id == "" or DataChatModul01.SPINE.has(id) or id == "b1" or id == "b2":
		kemajuan_disimpan.emit(id, _modul)


func _render_teks() -> void:
	var tampil := _teks_penuh.substr(0, _huruf_tampil).replace("[", "\\[")
	if _sedang_bicara and _kursor_nyala:
		tampil += "[bgcolor=#c9a227]  [/bgcolor]"
	_pesan_label.text = tampil


func _on_timer_bicara() -> void:
	if not _sedang_bicara:
		return
	_huruf_tampil += 1
	if _huruf_tampil >= _teks_penuh.length():
		_bicara_selesai()
	else:
		_render_teks()


func _on_timer_kedip() -> void:
	if not _sedang_bicara:
		return
	_kursor_nyala = not _kursor_nyala
	_render_teks()


func _on_timer_otomatis() -> void:
	if not _auto:
		_tampilkan_pilihan()
		return
	_lanjut_pesan()


## Tap kotak dialog = tampil penuh (lewati ucapan).
func _on_kotak_gui_input(event: InputEvent) -> void:
	var ketuk := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		ketuk = mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed
	elif event is InputEventScreenTouch:
		ketuk = (event as InputEventScreenTouch).pressed
	if ketuk and _sedang_bicara:
		_selesaikan_bicara()


func _selesaikan_bicara() -> void:
	if not _sedang_bicara:
		return
	_huruf_tampil = _teks_penuh.length()
	_bicara_selesai()


func _bicara_selesai() -> void:
	_sedang_bicara = false
	_timer_bicara.stop()
	_timer_kedip.stop()
	_huruf_tampil = _teks_penuh.length()
	_render_teks()
	if not _baca_ulang:
		_riwayat.append({"dari": "ustadz", "teks": _teks_penuh})
	var pid := String(_node_saat_ini.get("id", ""))
	if DataChatModul01.SPINE.has(pid) or pid == "b1" or pid == "b2":
		_bilah_progres.value = float(DataChatModul01.indeks_progres(pid) + 1) / float(DataChatModul01.jumlah_pesan())
	_tampilkan_pilihan()


func _tampilkan_pilihan() -> void:
	_bersihkan_pilihan()
	var nod := _node_saat_ini
	var tipe := String(nod.get("tipe", ""))
	if _baca_ulang:
		if tipe == "penutup":
			_tambah_tombol_tutup()
		else:
			var teks := "Lanjut ›"
			var opsi: Array = nod.get("opsi", [])
			if opsi.size() > 0:
				teks = String(opsi[0].get("teks", teks))
			_tambah_tombol_lanjut(teks)
		return
	match tipe:
		"pesan":
			if _auto:
				_timer_otomatis.start()
			else:
				var teks2 := "Lanjut ›"
				var opsi2: Array = nod.get("opsi", [])
				if opsi2.size() > 0:
					teks2 = String(opsi2[0].get("teks", teks2))
				_tambah_tombol_lanjut(teks2)
		"cek":
			var opsi3: Array = nod.get("opsi", [])
			for i in opsi3.size():
				var o: Dictionary = opsi3[i]
				var b := GayaMisi.buat_tombol_emas(String(o.get("teks", ""))) if i == 0 else GayaMisi.buat_tombol_outline(String(o.get("teks", "")))
				b.pressed.connect(_on_opsi_ditekan.bind(o))
				_pilihan_box.add_child(b)
		"soal":
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation", 10)
			grid.add_theme_constant_override("v_separation", 10)
			var opsi4: Array = DataChatModul01.opsi_soal(nod)
			for i in opsi4.size():
				if _opsi_salah.has(i):
					continue
				var b2 := GayaMisi.buat_tombol_outline(String(opsi4[i]))
				# Kolom grid membagi lebar penuh (tanpa ini tombol
				# mengecil ke ukuran teks dan menumpuk di kiri).
				b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b2.pressed.connect(_on_soal_ditekan.bind(i))
				grid.add_child(b2)
			_pilihan_box.add_child(grid)
		"penutup":
			_tambah_tombol_tutup()


func _tambah_tombol_lanjut(teks: String) -> void:
	var b := GayaMisi.buat_tombol_emas(teks)
	b.pressed.connect(_lanjut_pesan)
	_pilihan_box.add_child(b)
	_lanjut_tampil = true


func _tambah_tombol_tutup() -> void:
	var b := GayaMisi.buat_tombol_emas("Tutup")
	b.pressed.connect(_on_tutup_penutup)
	_pilihan_box.add_child(b)


func _bersihkan_pilihan() -> void:
	_lanjut_tampil = false
	for c in _pilihan_box.get_children():
		c.queue_free()


## Lanjut dari node "pesan" (otomatis / tombol Lanjut / opsi
## tunggal b2): "berikut" eksplisit dulu, lalu opsi tunggal,
## lalu node berikutnya di tulang punggung.
func _lanjut_pesan() -> void:
	_timer_otomatis.stop()
	var nod := _node_saat_ini
	var berikut := String(nod.get("berikut", ""))
	if berikut == "":
		var opsi: Array = nod.get("opsi", [])
		if opsi.size() > 0:
			berikut = String(opsi[0].get("ke", ""))
		else:
			var i := DataChatModul01.SPINE.find(String(nod.get("id", "")))
			if i >= 0 and i + 1 < DataChatModul01.SPINE.size():
				berikut = DataChatModul01.SPINE[i + 1]
	if berikut == "":
		return
	_tampilkan_node(DataChatModul01.cari(berikut))


func _on_opsi_ditekan(opsi: Dictionary) -> void:
	var teks_opsi := String(opsi.get("teks", ""))
	if not _baca_ulang:
		_riwayat.append({"dari": "pemain", "teks": teks_opsi})
	var ke := String(opsi.get("ke", ""))
	if ke == "ulang":
		if _ulang_materi:
			_emit_materi()
			_tampilkan_node(DataChatModul01.cari("l1"), teks_opsi)
		else:
			_ulang_materi = true
			_tampilkan_node(DataChatModul01.cari("m2"), teks_opsi)
		return
	if String(_node_saat_ini.get("id", "")) == "m7" and ke == "l1":
		_emit_materi()
	_tampilkan_node(DataChatModul01.cari(ke), teks_opsi)


func _emit_materi() -> void:
	if _materi_selesai:
		return
	_materi_selesai = true
	langkah_selesai.emit("materi", DataChatModul01.POIN_MATERI)


func _on_soal_ditekan(idx: int) -> void:
	var nod := _node_saat_ini
	var benar := DataChatModul01.benar_soal(nod)
	var opsi: Array = DataChatModul01.opsi_soal(nod)
	var teks_opsi := String(opsi[idx]) if idx >= 0 and idx < opsi.size() else ""
	if not _baca_ulang:
		_riwayat.append({"dari": "pemain", "teks": teks_opsi})
	if idx == benar:
		_opsi_salah.clear()
		var berikut := _node_berikut_setelah_soal(String(nod.get("id", "")))
		if String(nod.get("id", "")) == "l5" and not _latihan_selesai:
			_latihan_selesai = true
			langkah_selesai.emit("latihan", DataChatModul01.POIN_LATIHAN)
		if String(nod.get("id", "")) == "k1" and not _kuis_selesai:
			_kuis_selesai = true
			langkah_selesai.emit("kuis", DataChatModul01.POIN_KUIS)
		var puji := {"id": String(nod.get("id", "")) + "_benar", "tipe": "pesan", "teks": String(nod.get("benar", "")), "berikut": berikut}
		_tampilkan_node(puji, teks_opsi)
	else:
		_opsi_salah.append(idx)
		var tegur := {"id": String(nod.get("id", "")) + "_salah", "tipe": "pesan", "teks": String(nod.get("salah", "")), "berikut": String(nod.get("id", ""))}
		_tampilkan_node(tegur, teks_opsi)


func _node_berikut_setelah_soal(id: String) -> String:
	var i := DataChatModul01.SPINE.find(id)
	if i >= 0 and i + 1 < DataChatModul01.SPINE.size():
		return DataChatModul01.SPINE[i + 1]
	return "penutup"


func _on_tutup_penutup() -> void:
	if not _baca_ulang:
		selesai.emit(DataChatModul01.POIN_TOTAL)
		_simpan_kemajuan("")
	_tutup()


func _buka_riwayat() -> void:
	for c in _log_list.get_children():
		c.queue_free()
	for entri in _riwayat:
		var dari := String(entri.get("dari", ""))
		var awalan := _pengajar + ": " if dari == "ustadz" else "Kamu: "
		var l := GayaMisi.buat_label(awalan + String(entri.get("teks", "")), 18, GayaMisi.KREM if dari == "ustadz" else GayaMisi.EMAS_TERANG, true)
		_log_list.add_child(l)
	_log_overlay.visible = true


func _tutup_riwayat() -> void:
	_log_overlay.visible = false


func _hentikan_timer() -> void:
	_timer_bicara.stop()
	_timer_kedip.stop()
	_timer_otomatis.stop()


## Tutup panel TANPA sinyal (dipanggil manajer — tutup_semua() +
## _tampilkan() saat panel lain dibuka; sama seperti UI lama).
## Sinyal ditutup hanya dari penutupan eksplisit (× / "Tutup").
func tutup() -> void:
	_hentikan_timer()
	_sedang_bicara = false
	_tutup_riwayat()
	visible = false


func _tutup() -> void:
	_hentikan_timer()
	_sedang_bicara = false
	_tutup_riwayat()
	visible = false
	ditutup.emit()
