class_name RuangBelajarUI
extends PanelContainer
## Ruang Belajar — NARASI TEKS, LANJUT MANUAL (Sinta, 22 Nov 2026).
## Keputusan Mas 22 Nov 16:03 WIB: karakter BERHENTI dulu, project
## Godot lanjut; misi Ruang Belajar pindah dari VIDEO ke TEKS —
## narasi guru ditulis detail dan lengkap, pakai dialog TETAP, tapi
## TIDAK otomatis lanjut — pemain yang menentukan lanjut/tidaknya.
## Konsep video v3 DITUNDA (spike pemutar video TIDAK di-port).
## Kotak dialog bawah gelap tembus pandang + garis emas tepi atas,
## nama emas, gelembung kecil player, Riwayat, bilah emas tipis
## TANPA teks penghitung (koreksi Mas 15:09).
##
## KONTRAK (tetap — manajer/main tidak berubah): class_name,
## sinyal langkah_selesai(jenis, poin) / selesai(poin_total) /
## ditutup, tampilkan(pengajar, save). Sinyal BARU: papan_berubah
## (judul, baris) untuk papan tulis di dunia + kemajuan_disimpan
## (pos_id, modul, fase, node_terakhir) untuk resume (kunci save
## rb_chat_pos + rb_chat_modul + rb_fase + rb_node_terakhir).
##
## BICARA, bukan mengetik (§8): TIDAK ADA teks "sedang mengetik"
## di mana pun; huruf muncul satu-satu ±40 ms/huruf sebagai EFEK
## BICARA (kursor blok emas yang digambar — "[bgcolor]" di
## RichTextLabel, BUKAN glif font); tap kotak dialog = tampil
## penuh saat bicara, LANJUT ke node berikut bila sudah selesai.
##
## LANJUT MANUAL — TIDAK ADA auto-advance, TIDAK ADA timer:
## setelah ucapan selesai, tombol emas "Lanjut ›" tampil dan
## pemain yang mengetuknya (atau mengetuk gelembung dialog).
## TIDAK ADA chip Auto lagi (dihapus dari manajer juga).
##
## Aturan pilihan: tombol jawaban TIDAK PERNAH redup/terkunci.
## Opsi soal yang sudah dijawab salah DIHILANGKAN dari pilihan
## saat soal diulang (bukan di-disabled) — "dimatikan" §2 tanpa
## pernah menampilkan tombol redup.
##
## Alur: DataChatModul01–04 (narasi + latihan l1–l5 +
## kuis k1 + penutup + tugas; dispatch lewat _chat dari _modul).
## Poin: materi +10 / latihan +15 /
## kuis +10 / tugas +5 = 40 (sinyal langkah_selesai per langkah +
## selesai(40) di tugas). Resume: rb_chat_pos = id node BERIKUTNYA
## yang akan tampil (disimpan tiap node mulai, dibersihkan saat
## tuntas); rb_fase = fase sesi ("narasi"/"latihan"/"kuis"/
## "penutup"/"tugas"/"selesai"); rb_node_terakhir = id node narasi
## TERAKHIR yang ditampilkan ("" bila belum ada).
## Buka ulang setelah tuntas = mode baca ulang (tanpa poin).
## PERBAIKAN dari UI lama: mode baca ulang dulu memakai cek
## string pada rb_selesai (Array) sehingga selesai SEBAGIAN
## (mis. baru materi) sudah dianggap tuntas — kini ketiga
## langkah dicek satu-satu.
## MesinKuis TIDAK dipakai: graf node DataChatModul0X SUDAH
## menjadi mesin keadaan (pengulangan soal) — data soal/opsi/
## jawaban benar tetap dipakai ulang dari DataModul0X lewat
## DataChatModul0X.opsi_soal()/benar_soal().
## Dispatch modul (Sinta, 22 Nov 23:0X): _chat = kelas data
## sesuai _modul (1→01, 2→02, 3→03, 4→04); modul di luar
## 1–4 (mis. Jurumiyah 05+) jatuh ke 01 sebagai fallback.

signal langkah_selesai(jenis: String, poin: int)
signal selesai(poin_total: int)
signal ditutup
signal papan_berubah(judul: String, baris: PackedStringArray)
signal kemajuan_disimpan(pos_id: String, modul: int, fase: String, node_terakhir: String)

const BICARA_MS_PER_HURUF := 40

var _pengajar := "Ust. Sanusi"
var _modul := 1
var _chat = DataChatModul01
var _node_saat_ini: Dictionary = {}
var _teks_penuh := ""
var _huruf_tampil := 0
var _sedang_bicara := false
var _kursor_nyala := true
var _baca_ulang := false
var _materi_selesai := false
var _latihan_selesai := false
var _kuis_selesai := false
var _tugas_selesai := false
var _narasi_terakhir := ""
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
	btn_tutup.text = ""
	btn_tutup.focus_mode = Control.FOCUS_NONE
	btn_tutup.custom_minimum_size = Vector2(40, 40)
	btn_tutup.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	btn_tutup.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_tutup.pressed.connect(_tutup)
	# IKON PANEL (Tara, 19 Nov 2026): "✕" teks tofu di web
	# (Baloo 2 tidak punya U+2715) — ikon "x" digambar IkonHUD.
	var ikon_tutup := IkonHUD.new()
	ikon_tutup.jenis = "x"
	ikon_tutup.warna = GayaMisi.KREM
	ikon_tutup.bayangan = false
	ikon_tutup.position = Vector2(8, 8)
	ikon_tutup.size = Vector2(24, 24)
	ikon_tutup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_tutup.add_child(ikon_tutup)
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
	# Timer: bicara (per huruf) + kedip kursor. TIDAK ADA timer
	# otomatis lanjut — pemain yang mengetuk "Lanjut" (22 Nov).
	_timer_bicara = Timer.new()
	_timer_bicara.wait_time = float(BICARA_MS_PER_HURUF) / 1000.0
	_timer_bicara.timeout.connect(_on_timer_bicara)
	add_child(_timer_bicara)
	_timer_kedip = Timer.new()
	_timer_kedip.wait_time = 0.5
	_timer_kedip.timeout.connect(_on_timer_kedip)
	add_child(_timer_kedip)
	visible = false


## Buka percakapan. save = kamus save pemain (untuk resume +
## mode baca ulang); {} = mulai dari awal.
func tampilkan(pengajar: String, save: Dictionary = {}) -> void:
	_pengajar = pengajar
	_modul = int(Onboarding.baca(save).get("modul", 1))
	# Dispatch data chat per modul (Sinta, 22 Nov 23:0X): kelas
	# GDScript disimpan di _chat (untyped) — pemanggilan statik
	# _chat.cari()/SPINE/POIN_* bekerja lewat resource skrip.
	match _modul:
		2:
			_chat = DataChatModul02
		3:
			_chat = DataChatModul03
		4:
			_chat = DataChatModul04
		_:
			_chat = DataChatModul01
	_nama_label.text = pengajar
	_avatar.atur_tipe("ustadzah" if pengajar.contains("Fatimah") else "sanusi")
	var sudah: Array = save.get("rb_selesai", [])
	var m := str(_modul)
	_baca_ulang = sudah.has(m + ":materi") and sudah.has(m + ":latihan") and sudah.has(m + ":kuis")
	_materi_selesai = false
	_latihan_selesai = false
	_kuis_selesai = false
	_tugas_selesai = false
	_narasi_terakhir = ""
	_opsi_salah.clear()
	_riwayat.clear()
	_hentikan_timer()
	_tutup_riwayat()
	visible = true
	var pos := String(save.get("rb_chat_pos", ""))
	if _baca_ulang:
		_bangun_log_baca_ulang()
		_tampilkan_node(_chat.cari(_chat.id_pertama()))
	elif pos != "" and not _chat.cari(pos).is_empty():
		_bangun_log_resume(pos)
		_tampilkan_node(_chat.cari(pos))
	else:
		_tampilkan_node(_chat.cari(_chat.id_pertama()))


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


## Pembicara node — naskah ditulis sekali (Sanusi) tapi dipakai
## dua versi: santri putri belajar dari Ustzh. Fatimah, jadi nama
## ustadz di node di-resolve ke pengajar sesi ini. Nama lain
## (bukan Sanusi/Fatimah) diteruskan apa adanya.
func _pembicara_node(nod: Dictionary) -> String:
	var p := String(nod.get("pembicara", _pengajar))
	if p.contains("Sanusi") or p.contains("Fatimah"):
		return _pengajar
	return p


func _bangun_log_resume(resume_id: String) -> void:
	_riwayat.clear()
	for id in _chat.jalur_log(resume_id):
		var n := _chat.cari(id)
		if not n.is_empty():
			_riwayat.append({"dari": "ustadz", "teks": String(n.get("teks", ""))})


func _bangun_log_baca_ulang() -> void:
	_riwayat.clear()
	for id in _chat.SPINE:
		var n := _chat.cari(id)
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
	var pembicara := _pembicara_node(nod)
	_nama_label.text = pembicara
	_avatar.atur_tipe("ustadzah" if pembicara.contains("Fatimah") else "sanusi")
	var papan: Dictionary = nod.get("papan", {})
	if not papan.is_empty():
		var baris := PackedStringArray()
		for b in papan.get("baris", []):
			baris.append(String(b))
		papan_berubah.emit(String(papan.get("judul", "")), baris)
	var pid := String(nod.get("id", ""))
	if _chat.SPINE.has(pid):
		_bilah_progres.value = float(_chat.indeks_progres(pid)) / float(_chat.jumlah_pesan())
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
	# Hanya node tulang punggung yang disimpan sebagai titik
	# resume (node sementara "_benar"/"_salah" tidak — titik
	# resume tetap di soal yang sedang dijawab).
	if id == "" or _chat.SPINE.has(id):
		if _chat.fase_node(id) == "narasi":
			_narasi_terakhir = id
		kemajuan_disimpan.emit(id, _modul, _chat.fase_node(id), _narasi_terakhir)


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


## Tap kotak dialog: saat bicara = tampil penuh (lewati ucapan);
## bila ucapan sudah selesai dan tombol Lanjut tampil = lanjut
## ke node berikut (ketuk gelembung = ketuk Lanjut).
func _on_kotak_gui_input(event: InputEvent) -> void:
	var ketuk := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		ketuk = mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed
	elif event is InputEventScreenTouch:
		ketuk = (event as InputEventScreenTouch).pressed
	if not ketuk:
		return
	if _sedang_bicara:
		_selesaikan_bicara()
	elif _lanjut_tampil:
		_lanjut_pesan()


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
	if _chat.SPINE.has(pid):
		_bilah_progres.value = float(_chat.indeks_progres(pid) + 1) / float(_chat.jumlah_pesan())
	_tampilkan_pilihan()


func _tampilkan_pilihan() -> void:
	_bersihkan_pilihan()
	var nod := _node_saat_ini
	var tipe := String(nod.get("tipe", ""))
	if _baca_ulang:
		# Baca ulang: tidak ada poin — tugas pun langsung Tutup.
		if tipe == "tugas":
			_tambah_tombol_tutup()
		else:
			_tambah_tombol_lanjut("Lanjut ›")
		return
	match tipe:
		"narasi", "pesan":
			# LANJUT MANUAL: selalu tombol, tidak pernah otomatis.
			_tambah_tombol_lanjut("Lanjut ›")
		"cek":
			# Node cek v4 ("Paham? Fahimtum?"): render nod.opsi
			# sebagai tombol outline (pola tombol soal); tiap
			# tombol mengikuti "ke"-nya. "Belum" maks 1x per cek
			# secara struktural — node ulang punya "berikut"
			# melewati cek, jadi tidak ada jalan kembali ke cek
			# yang sama dalam satu sesi.
			var opsi_cek: Array = nod.get("opsi", [])
			for o in opsi_cek:
				var od: Dictionary = o
				var bc := GayaMisi.buat_tombol_outline(String(od.get("teks", "")))
				bc.pressed.connect(_on_cek_ditekan.bind(od))
				_pilihan_box.add_child(bc)
		"soal":
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation", 10)
			grid.add_theme_constant_override("v_separation", 10)
			var opsi4: Array = _chat.opsi_soal(nod)
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
		"tugas":
			var b := GayaMisi.buat_tombol_emas("Terima Tugas ✓")
			b.pressed.connect(_on_terima_tugas)
			_pilihan_box.add_child(b)


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


## Lanjut dari node narasi/pesan (tombol Lanjut / ketuk
## gelembung): "berikut" eksplisit dulu (node pujian/teguran
## soal, node ulang u1-u4), lalu node berikutnya di tulang
## punggung. Materi +10 di-emit saat meninggalkan node narasi
## terakhir (p_latihan) ke l1.
func _lanjut_pesan() -> void:
	var nod := _node_saat_ini
	if String(nod.get("id", "")) == "p_latihan" and not _baca_ulang:
		_emit_materi()
	var berikut := String(nod.get("berikut", ""))
	if berikut == "":
		var i: int = _chat.SPINE.find(String(nod.get("id", "")))
		if i >= 0 and i + 1 < _chat.SPINE.size():
			berikut = _chat.SPINE[i + 1]
	if berikut == "":
		return
	_tampilkan_node(_chat.cari(berikut))


func _emit_materi() -> void:
	if _materi_selesai:
		return
	_materi_selesai = true
	langkah_selesai.emit("materi", _chat.POIN_MATERI)


## Pilihan node cek ("Paham, lanjut ›" / "Belum, jelaskan lagi"):
## catat jawaban player ke Riwayat + tampilkan node "ke"-nya
## (gelembung player menampilkan jawaban yang dipilih).
func _on_cek_ditekan(opsi: Dictionary) -> void:
	var teks_opsi := String(opsi.get("teks", ""))
	if not _baca_ulang:
		_riwayat.append({"dari": "pemain", "teks": teks_opsi})
	_tampilkan_node(_chat.cari(String(opsi.get("ke", ""))), teks_opsi)


func _on_soal_ditekan(idx: int) -> void:
	var nod := _node_saat_ini
	var benar := _chat.benar_soal(nod)
	var opsi: Array = _chat.opsi_soal(nod)
	var teks_opsi := String(opsi[idx]) if idx >= 0 and idx < opsi.size() else ""
	if not _baca_ulang:
		_riwayat.append({"dari": "pemain", "teks": teks_opsi})
	if idx == benar:
		_opsi_salah.clear()
		var berikut := _node_berikut_setelah_soal(String(nod.get("id", "")))
		if String(nod.get("id", "")) == "l5" and not _latihan_selesai:
			_latihan_selesai = true
			langkah_selesai.emit("latihan", _chat.POIN_LATIHAN)
		if String(nod.get("id", "")) == "k1" and not _kuis_selesai:
			_kuis_selesai = true
			langkah_selesai.emit("kuis", _chat.POIN_KUIS)
		var puji := {"id": String(nod.get("id", "")) + "_benar", "tipe": "pesan", "teks": String(nod.get("benar", "")), "berikut": berikut}
		_tampilkan_node(puji, teks_opsi)
	else:
		_opsi_salah.append(idx)
		var tegur := {"id": String(nod.get("id", "")) + "_salah", "tipe": "pesan", "teks": String(nod.get("salah", "")), "berikut": String(nod.get("id", ""))}
		_tampilkan_node(tegur, teks_opsi)


func _node_berikut_setelah_soal(id: String) -> String:
	var i: int = _chat.SPINE.find(id)
	if i >= 0 and i + 1 < _chat.SPINE.size():
		return _chat.SPINE[i + 1]
	return "penutup"


## Terima tugas (+5, sekali saja) -> tombol berubah jadi Tutup.
func _on_terima_tugas() -> void:
	if not _tugas_selesai:
		_tugas_selesai = true
		langkah_selesai.emit("tugas", _chat.POIN_TUGAS)
	_bersihkan_pilihan()
	_tambah_tombol_tutup()


func _on_tutup_penutup() -> void:
	if not _baca_ulang:
		selesai.emit(_chat.POIN_TOTAL)
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
