class_name RuangBelajarUI
extends PanelContainer
## Panel Ruang Belajar Modul 01 — Fase A, A1/A8 (Sinta, 18 Nov 2026).
## Mockup ACC Mas: ruang-belajar-v1.png (panel zamrud gelap + rim
## emas + tab emas "Ruang Belajar" + 3 pill langkah + tag TEKS DRAF
## + footer "Materi 1 dari 3" / "✕ Lanjut □ Chat").
##
## Panel ini TIDAK membuat dim sendiri dan TIDAK mengatur anchor
## sendiri — Manajer (Raka) yang menaruhnya di tengah + memberi
## dim. Panel hidden saat dibuat; tampilkan() memunculkan.
##
## 3 langkah: 1 Materi -> 2 Latihan (5 soal, boleh ulang sampai
## benar) -> 3 Kuis (1 soal, boleh ulang tanpa penalti).
## Poin: materi 10 + latihan 15 + kuis 10 = 35 (konstanta
## DataModul01). Soal + mesin dari kontrak Dita/Wulan (MesinKuis
## sudah ada; DataModul01 + GayaMisi dibuat paralel).
##
## Catatan mesin: MesinKuis.jawab() selalu maju ke soal berikut,
## jadi jawaban SALAH TIDAK diteruskan ke mesin — soal yang sama
## tetap tampil sampai pemain memilih jawaban benar, baru
## jawab() dipanggil. Dengan begitu skor mesin tetap akurat
## (latihan 5/5, kuis 1/1) dan "coba lagi" sungguh mengulang
## soal yang sama.

signal langkah_selesai(jenis: String, poin: int)
signal selesai(poin_total: int)
signal ditutup  ## pemain menutup di tengah

const _LEBAR_MIN := 660.0
const _NAMA_LANGKAH := ["Materi", "Latihan", "Kuis"]
const _FOOTER := ["Materi 1 dari 3", "Latihan 2 dari 3", "Kuis 3 dari 3"]

var _pengajar := ""
var _langkah := 1
var _poin_total := 0
var _selesai_semua := false

var _judul: Label
var _subjudul: Label
var _label_pengajar: Label
var _pill_panel: Array[PanelContainer] = []
var _pill_label: Array[Label] = []
var _gulung: ScrollContainer
var _isi: VBoxContainer
var _footer_kiri: Label

# Status kuis (langkah 2 dan 3).
var _mesin: MesinKuis
var _mode := ""  ## "latihan" | "kuis"
var _nama_langkah_soal := "Latihan"
var _soal_aktif := {}
var _jawaban_benar := -1
var _menunggu_lanjut := false
var _label_soal: Label
var _bilah: ProgressBar
var _teks_soal: Label
var _opsi_box: VBoxContainer
var _tombol_opsi: Array[Button] = []
var _umpan: Label
var _petunjuk: Label
var _tombol_lanjut: Button


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(_LEBAR_MIN, 0)
	add_theme_stylebox_override("panel", GayaMisi.gaya_panel())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)

	# Baris atas: tab emas + pill TEKS DRAF + tombol ✕.
	var atas := HBoxContainer.new()
	atas.add_theme_constant_override("separation", 8)
	v.add_child(atas)
	atas.add_child(GayaMisi.buat_tab_judul("Ruang Belajar"))
	var spasi := Control.new()
	spasi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	atas.add_child(spasi)
	atas.add_child(GayaMisi.buat_pill_draf())
	var tombol_tutup := Button.new()
	tombol_tutup.text = "✕"
	tombol_tutup.tooltip_text = "Tutup"
	tombol_tutup.flat = true
	tombol_tutup.pressed.connect(_on_tutup_ditekan)
	atas.add_child(tombol_tutup)

	# Header modul.
	_judul = GayaMisi.buat_label(DataModul01.JUDUL, 22, GayaMisi.EMAS)
	v.add_child(_judul)
	_subjudul = GayaMisi.buat_label(DataModul01.SUBJUDUL, 15, GayaMisi.KREM)
	v.add_child(_subjudul)
	_label_pengajar = GayaMisi.buat_label("", 15, GayaMisi.KREM_REDUP)
	v.add_child(_label_pengajar)

	# 3 pill langkah.
	var pill := HBoxContainer.new()
	pill.add_theme_constant_override("separation", 8)
	v.add_child(pill)
	for i in range(3):
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var lab := GayaMisi.buat_label("%d %s" % [i + 1, _NAMA_LANGKAH[i]], 16, GayaMisi.KREM_REDUP)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_child(lab)
		pill.add_child(panel)
		_pill_panel.append(panel)
		_pill_label.append(lab)

	# Isi langkah (bisa digulung — materi panjang).
	_gulung = ScrollContainer.new()
	_gulung.custom_minimum_size = Vector2(0, 380)
	_gulung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gulung.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_gulung.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(_gulung)

	_isi = VBoxContainer.new()
	_isi.add_theme_constant_override("separation", 12)
	_isi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gulung.add_child(_isi)

	# Footer: kiri "Materi 1 dari 3" dst, kanan petunjuk tombol.
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	v.add_child(footer)
	_footer_kiri = GayaMisi.buat_label(_FOOTER[0], 14, GayaMisi.KREM_REDUP)
	footer.add_child(_footer_kiri)
	var spasi_footer := Control.new()
	spasi_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spasi_footer)
	footer.add_child(GayaMisi.buat_label("✕ Lanjut    □ Chat", 14, GayaMisi.KREM_REDUP))


## Tampilkan dari langkah 1. Pengajar mis. "Ust. Sanusi" / "Ustzh. Fatimah".
func tampilkan(pengajar: String) -> void:
	_pengajar = pengajar
	_poin_total = 0
	_selesai_semua = false
	_label_pengajar.text = "Pengajar: " + pengajar
	_ke_langkah(1)
	visible = true


## Sembunyikan tanpa sinyal.
func tutup() -> void:
	visible = false


func _ke_langkah(nomor: int) -> void:
	_langkah = nomor
	_perbarui_pill()
	_footer_kiri.text = _FOOTER[nomor - 1]
	_bersihkan_isi()
	match nomor:
		1:
			_bangun_materi()
		2:
			_bangun_latihan()
		3:
			_bangun_kuis()


func _bersihkan_isi() -> void:
	for anak in _isi.get_children():
		anak.queue_free()
	_tombol_opsi.clear()
	_soal_aktif = {}
	_jawaban_benar = -1
	_menunggu_lanjut = false


func _perbarui_pill() -> void:
	for i in range(3):
		var panel := _pill_panel[i]
		var lab := _pill_label[i]
		if _selesai_semua or i + 1 < _langkah:
			panel.add_theme_stylebox_override("panel", GayaMisi.gaya_tombol_emas())
			lab.add_theme_color_override("font_color", GayaMisi.ZAMRUD_GELAP)
		elif i + 1 == _langkah:
			panel.add_theme_stylebox_override("panel", GayaMisi.gaya_tab())
			lab.add_theme_color_override("font_color", GayaMisi.ZAMRUD_GELAP)
		else:
			panel.add_theme_stylebox_override("panel", GayaMisi.gaya_chip())
			lab.add_theme_color_override("font_color", GayaMisi.KREM_REDUP)


## Kartu zamrud di dalam _isi; kembalikan VBox isinya (judul sudah terisi).
func _buat_kartu(judul: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", GayaMisi.gaya_kartu())
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	margin.add_child(v)
	v.add_child(GayaMisi.buat_label(judul, 18, GayaMisi.EMAS))
	_isi.add_child(panel)
	return v


func _buat_label_isi(teks: String, ukuran: int, warna: Color) -> Label:
	var lab := GayaMisi.buat_label(teks, ukuran, warna)
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lab


# ---------------------------------------------------------------- langkah 1

func _bangun_materi() -> void:
	# Kartu "Apa itu kalam?".
	var kartu := _buat_kartu(DataModul01.MATERI_JUDUL)
	kartu.add_child(_buat_label_isi(DataModul01.MATERI_TEKS, 16, GayaMisi.KREM))
	var arab := GayaMisi.buat_label_arab(DataModul01.MATERI_ARAB, 30)
	arab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kartu.add_child(arab)
	var trans := _buat_label_isi(DataModul01.MATERI_TRANSLITERASI, 15, GayaMisi.KREM_REDUP)
	trans.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kartu.add_child(trans)
	var catatan := _buat_label_isi(DataModul01.MATERI_CATATAN, 14, GayaMisi.KREM_REDUP)
	catatan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kartu.add_child(catatan)

	# 3 kartu kata berdampingan.
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 8)
	_isi.add_child(baris)
	for k in DataModul01.KARTU_KATA:
		var kata: Dictionary = k
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", GayaMisi.gaya_kartu())
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		panel.add_child(margin)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		margin.add_child(v)
		var nama := _buat_label_isi(String(kata.get("nama", "")), 17, GayaMisi.EMAS)
		nama.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nama)
		var ciri := _buat_label_isi(String(kata.get("ciri", "")), 14, GayaMisi.KREM)
		ciri.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(ciri)
		var arti := _buat_label_isi(String(kata.get("arti", "")), 13, GayaMisi.KREM_REDUP)
		arti.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(arti)
		baris.add_child(panel)

	# Kartu "Rumus 10 detik".
	var rumus := _buat_kartu("Rumus 10 detik")
	var baris_rumus: Array[String] = []
	for i in range(DataModul01.RUMUS.size()):
		baris_rumus.append("%d. %s" % [i + 1, String(DataModul01.RUMUS[i])])
	rumus.add_child(_buat_label_isi("\n".join(baris_rumus), 16, GayaMisi.KREM))

	# Kartu "Bait hafalan".
	var bait := _buat_kartu("Bait hafalan")
	var teks_bait := String(DataModul01.BAIT)
	if not teks_bait.begins_with("“") and not teks_bait.begins_with("\""):
		teks_bait = "“" + teks_bait + "”"
	var lab_bait := _buat_label_isi(teks_bait, 16, GayaMisi.KREM)
	lab_bait.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bait.add_child(lab_bait)

	# Alur + chip poin.
	var alur := _buat_label_isi("Selesai materi → latihan 5 soal → kuis 1 soal", 14, GayaMisi.KREM_REDUP)
	alur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_isi.add_child(alur)
	var chip := HBoxContainer.new()
	chip.alignment = BoxContainer.ALIGNMENT_CENTER
	chip.add_theme_constant_override("separation", 8)
	chip.add_child(GayaMisi.buat_chip("+%d poin materi" % DataModul01.POIN_MATERI))
	chip.add_child(GayaMisi.buat_chip("+%d latihan" % DataModul01.POIN_LATIHAN))
	chip.add_child(GayaMisi.buat_chip("+%d hafalan" % DataModul01.POIN_HAFALAN))
	_isi.add_child(chip)

	var lanjut := GayaMisi.buat_tombol_emas("Lanjut ke Latihan")
	lanjut.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lanjut.pressed.connect(_on_lanjut_latihan)
	_isi.add_child(lanjut)


func _on_lanjut_latihan() -> void:
	langkah_selesai.emit("materi", DataModul01.POIN_MATERI)
	_ke_langkah(2)


# ---------------------------------------------------------------- langkah 2 & 3

func _bangun_latihan() -> void:
	_mode = "latihan"
	_mesin = MesinKuis.new()
	if not _mesin.mulai(DataModul01.latihan_soal(), "latihan"):
		_bangun_error()
		return
	_bangun_soal("Latihan")


func _bangun_kuis() -> void:
	_mode = "kuis"
	_mesin = MesinKuis.new()
	var daftar: Array = DataModul01.kuis_soal()
	if daftar.is_empty() or not _mesin.mulai([daftar[0]], "materi"):
		_bangun_error()
		return
	_bangun_soal("Kuis")


## Kerangka soal dipakai latihan (5 soal) maupun kuis (1 soal).
func _bangun_soal(nama_langkah: String) -> void:
	_label_soal = GayaMisi.buat_label("", 16, GayaMisi.EMAS)
	_isi.add_child(_label_soal)

	_bilah = GayaMisi.buat_bilah_progres()
	_bilah.max_value = _mesin.jumlah_soal()
	_bilah.value = 0
	_bilah.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_isi.add_child(_bilah)

	var kartu := _buat_kartu("Soal")
	_teks_soal = _buat_label_isi("", 17, GayaMisi.KREM)
	kartu.add_child(_teks_soal)

	_opsi_box = VBoxContainer.new()
	_opsi_box.add_theme_constant_override("separation", 8)
	_isi.add_child(_opsi_box)

	_umpan = _buat_label_isi("", 16, GayaMisi.EMAS)
	_umpan.visible = false
	_isi.add_child(_umpan)

	_petunjuk = _buat_label_isi("", 14, GayaMisi.KREM_REDUP)
	_petunjuk.visible = false
	_isi.add_child(_petunjuk)

	_tombol_lanjut = GayaMisi.buat_tombol_emas("Soal berikut")
	_tombol_lanjut.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tombol_lanjut.visible = false
	_tombol_lanjut.pressed.connect(_on_lanjut_soal)
	_isi.add_child(_tombol_lanjut)

	_nama_langkah_soal = nama_langkah
	_tampilkan_soal()


func _tampilkan_soal() -> void:
	_soal_aktif = _mesin.soal_saat_ini()
	if _soal_aktif.is_empty():
		_bangun_error()
		return
	_label_soal.text = "%s — Soal %d dari %d" % [_nama_langkah_soal, _mesin.nomor_soal(), _mesin.jumlah_soal()]
	_bilah.value = _mesin.nomor_soal() - 1
	_teks_soal.text = String(_soal_aktif.get("pertanyaan", ""))
	_gulung.scroll_vertical = 0

	for anak in _opsi_box.get_children():
		anak.queue_free()
	_tombol_opsi.clear()
	var huruf := ["A", "B", "C", "D"]
	var opsi: Array = _soal_aktif.get("opsi", [])
	for i in range(opsi.size()):
		var tombol := GayaMisi.buat_tombol_outline("%s. %s" % [huruf[i], String(opsi[i])])
		tombol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tombol.pressed.connect(_on_opsi_ditekan.bind(i))
		_opsi_box.add_child(tombol)
		_tombol_opsi.append(tombol)

	_umpan.visible = false
	_petunjuk.visible = false
	_tombol_lanjut.visible = false
	_jawaban_benar = -1
	_menunggu_lanjut = false


func _on_opsi_ditekan(i: int) -> void:
	if _menunggu_lanjut or _soal_aktif.is_empty():
		return
	var benar_idx := int(_soal_aktif.get("jawaban", -1))

	# Petunjuk tampil SETELAH menjawab (bila soal menyediakannya).
	if _soal_aktif.has("petunjuk"):
		var petunjuk := String(_soal_aktif.get("petunjuk", "")).strip_edges()
		if not petunjuk.is_empty():
			_petunjuk.text = "Petunjuk: " + petunjuk
			_petunjuk.visible = true

	if i == benar_idx:
		_umpan.text = "Benar!"
		_umpan.add_theme_color_override("font_color", GayaMisi.EMAS)
		_umpan.visible = true
		_jawaban_benar = i
		_menunggu_lanjut = true
		for tombol in _tombol_opsi:
			tombol.disabled = true
		_tombol_lanjut.text = _teks_tombol_lanjut()
		_tombol_lanjut.visible = true
	else:
		_umpan.text = "Belum tepat — coba lagi."
		_umpan.add_theme_color_override("font_color", GayaMisi.KREM)
		_umpan.visible = true
		# Opsi yang salah dimatikan saja; soal yang sama tetap bisa
		# dijawab ulang dari opsi yang tersisa.
		if i >= 0 and i < _tombol_opsi.size():
			_tombol_opsi[i].disabled = true


func _teks_tombol_lanjut() -> String:
	if _mesin.nomor_soal() >= _mesin.jumlah_soal():
		return "Lihat hasil" if _mode == "kuis" else "Selesai"
	return "Soal berikut"


func _on_lanjut_soal() -> void:
	if _jawaban_benar < 0:
		return
	_mesin.jawab(_jawaban_benar)
	_menunggu_lanjut = false
	if _mesin.selesai():
		if _mode == "latihan":
			langkah_selesai.emit("latihan", DataModul01.POIN_LATIHAN)
			_ke_langkah(3)
		else:
			_selesaikan_kuis()
		return
	_tampilkan_soal()


func _selesaikan_kuis() -> void:
	langkah_selesai.emit("kuis", DataModul01.POIN_HAFALAN)
	_poin_total = DataModul01.POIN_MATERI + DataModul01.POIN_LATIHAN + DataModul01.POIN_HAFALAN
	selesai.emit(_poin_total)
	_selesai_semua = true
	_perbarui_pill()
	_bersihkan_isi()
	_bangun_selesai()


func _bangun_selesai() -> void:
	var kartu := _buat_kartu("Selesai — %d poin" % _poin_total)
	kartu.add_child(_buat_label_isi("Materi, latihan, dan kuis Modul 01 tuntas.", 16, GayaMisi.KREM))
	var tutup_btn := GayaMisi.buat_tombol_emas("Tutup")
	tutup_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutup_btn.pressed.connect(tutup)
	_isi.add_child(tutup_btn)


func _bangun_error() -> void:
	_bersihkan_isi()
	_isi.add_child(_buat_label_isi("Soal belum tersedia — menunggu tashih.", 16, GayaMisi.KREM))
	var tutup_btn := GayaMisi.buat_tombol_emas("Tutup")
	tutup_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutup_btn.pressed.connect(tutup)
	_isi.add_child(tutup_btn)


func _on_tutup_ditekan() -> void:
	visible = false
	ditutup.emit()
