class_name TesKenaikanUI
extends PanelContainer
## Tes Kenaikan naik Bagian (N*.T) — Fase A, A9 (Nusa, 18 Nov 2026).
## Acuan: mockup tes-kenaikan-v1.png (DI-ACC Mas) + DRAF-ALUR-MISI
## §2.1 (tes 10 soal, lulus >= 8/10, +20 poin bila lulus).
## Branding: "Pesantren Universe" — panel ini tidak menulis nama
## game sama sekali; JANGAN tulis "Verse" di sini.
## Bank soal menunggu tashih.
##
## ALUR (catatan implementasi):
## - MesinKuis.jawab() langsung maju ke soal berikut, jadi kunci
##   jawaban dibuat DUA langkah: tekan "Kunci Jawaban" -> jawaban
##   dikunci + umpan balik benar/salah tampil di kartu soal yang
##   sama; tombol berubah jadi "Soal Berikutnya" / "Lihat Hasil"
##   untuk maju. _soal_tampil/_nomor_tampil menyimpan soal yang
##   sedang diberi umpan balik.
## - MesinKuis tidak menyimpan jawaban per soal, jadi _riwayat
##   (Array[bool]) mencatat benar/salah tiap soal untuk chip
##   "Jawaban sejauh ini" + hitungan "Benar X • Salah Y".
## - UI ini TIDAK PERNAH mencatat hasil ke save: sinyal
##   tes_selesai meneruskan mesin ke main.gd, dan main.gd yang
##   memanggil Gerbang.catat_tes (pencatatan wilayah main.gd).
## - tes_selesai di-emit SEKALI per sesi selesai, saat kartu hasil
##   pertama tampil. "Ulangi Tes" mereset penanda itu, jadi sesi
##   ulang yang selesai lagi meng-emit lagi; main.gd yang menjaga
##   idempotensi pencatatan.
## - "petunjuk" hanya tampil bila kunci itu ada di soal (bank tes
##   N1.T saat ini TIDAK punya petunjuk — hanya latihan yang punya;
##   mockup menampilkannya sebagai contoh).
## - Bagian N2/N3/N4: bank soal BELUM ADA (A2 menunggu tashih) ->
##   kartu "belum tersedia" + tombol Tutup; TIDAK mulai sesi kosong,
##   TIDAK crash.
## - Penutup oleh pemain (footer "Keluar", tombol "Tutup") meng-emit
##   ditutup; tutup() menutup diam-diam tanpa sinyal (untuk
##   penutupan programatik oleh main.gd).

signal tes_selesai(lulus: bool, skor: int, bagian: String, mesin: MesinKuis)
signal ditutup

const HURUF_OPSI: Array[String] = ["A", "B", "C", "D"]
const POIN_TES := 20

var _bagian := "N1"
var _mesin: MesinKuis = null
var _bank_tersedia := false
var _pilihan := -1  ## indeks opsi yang dipilih, -1 = belum memilih
var _terkunci := false  ## true = jawaban sudah dikunci, menunggu lanjut
var _soal_tampil := {}
var _nomor_tampil := 0
var _jawaban_benar := false
var _jawaban_benar_teks := ""
var _riwayat: Array[bool] = []
var _hasil_ditampilkan := false

var _gulung: ScrollContainer
var _konten: VBoxContainer
var _label_kaki: Label


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 18
	offset_top = 64
	offset_right = -18
	offset_bottom = -18
	add_theme_stylebox_override("panel", GayaMisi.gaya_panel())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var akar := VBoxContainer.new()
	akar.add_theme_constant_override("separation", 12)
	margin.add_child(akar)
	var tengah := CenterContainer.new()
	tengah.add_child(GayaMisi.buat_tab_judul("Tes Kenaikan"))
	akar.add_child(tengah)
	_gulung = ScrollContainer.new()
	_gulung.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_gulung.size_flags_vertical = Control.SIZE_EXPAND_FILL
	akar.add_child(_gulung)
	_konten = VBoxContainer.new()
	_konten.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_konten.add_theme_constant_override("separation", 12)
	_gulung.add_child(_konten)
	var kaki := HBoxContainer.new()
	kaki.add_theme_constant_override("separation", 8)
	akar.add_child(kaki)
	_label_kaki = GayaMisi.buat_label("N1.T • Kantor", 16, GayaMisi.KREM_REDUP)
	_label_kaki.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kaki.add_child(_label_kaki)
	var keluar := Button.new()
	keluar.text = "✕ Keluar"
	keluar.flat = true
	keluar.focus_mode = Control.FOCUS_NONE
	keluar.add_theme_font_size_override("font_size", 16)
	keluar.add_theme_color_override("font_color", GayaMisi.KREM)
	keluar.pressed.connect(_on_tutup_ditekan)
	kaki.add_child(keluar)
	kaki.add_child(GayaMisi.buat_label("□ Chat", 16, GayaMisi.KREM_REDUP))


## Tampilkan tes untuk satu Bagian ("N1".."N4"). N1 memakai
## DataModul01.kuis_soal(); N2-N4 bank belum ada -> kartu
## "belum tersedia". Panel hidden sebelum tampilkan() dipanggil.
func tampilkan(bagian: String) -> void:
	_bagian = bagian
	_pilihan = -1
	_terkunci = false
	_riwayat.clear()
	_hasil_ditampilkan = false
	_soal_tampil = {}
	_nomor_tampil = 0
	_jawaban_benar_teks = ""
	_bank_tersedia = false
	_mesin = MesinKuis.new()
	if _nomor_bagian(bagian) == 1:
		var bank: Array = DataModul01.kuis_soal()
		if _mesin.mulai(bank, MesinKuis.JENIS_TES):
			_bank_tersedia = true
	visible = true
	_render()


## Sembunyikan panel tanpa sinyal (penutupan programatik).
func tutup() -> void:
	visible = false


func _on_tutup_ditekan() -> void:
	visible = false
	ditutup.emit()


func _on_opsi_ditekan(i: int) -> void:
	if _terkunci:
		return
	_pilihan = i
	_render()


func _on_kunci_ditekan() -> void:
	if _terkunci:
		# Lanjut dari umpan balik: soal berikut, atau kartu hasil
		# bila sesi sudah selesai (dirender _render()).
		_terkunci = false
		_pilihan = -1
		_render()
		return
	if _mesin == null or not _mesin.dimulai() or _pilihan < 0 or _pilihan > 3:
		return
	var soal := _mesin.soal_saat_ini()
	if soal.is_empty():
		return
	_soal_tampil = soal
	_nomor_tampil = _mesin.nomor_soal()
	if not _mesin.jawab(_pilihan):
		return
	_jawaban_benar = _mesin.jawaban_terakhir_benar()
	_riwayat.append(_jawaban_benar)
	var opsi: Array = soal.get("opsi", [])
	var j: int = int(soal.get("jawaban", -1))
	if j >= 0 and j < opsi.size():
		_jawaban_benar_teks = String(opsi[j])
	else:
		_jawaban_benar_teks = ""
	_terkunci = true
	_render()


func _on_ulangi_ditekan() -> void:
	if _mesin == null or not _mesin.ulang():
		return
	_pilihan = -1
	_terkunci = false
	_riwayat.clear()
	_hasil_ditampilkan = false
	_soal_tampil = {}
	_nomor_tampil = 0
	_jawaban_benar_teks = ""
	_render()


func _render() -> void:
	_bersihkan(_konten)
	if _label_kaki != null:
		_label_kaki.text = "%s.T • Kantor" % _bagian
	_tambah_header()
	if not _bank_tersedia or _mesin == null:
		_tambah_kartu_belum_tersedia()
		return
	if _mesin.selesai() and not _terkunci:
		_tambah_kartu_hasil()
		if not _hasil_ditampilkan:
			_hasil_ditampilkan = true
			tes_selesai.emit(
				_mesin.lulus(MesinKuis.AMBANG_TES_DEFAULT),
				_mesin.skor(),
				_bagian,
				_mesin
			)
		return
	var nomor := _nomor_tampil if _terkunci else _mesin.nomor_soal()
	var soal := _soal_tampil if _terkunci else _mesin.soal_saat_ini()
	if soal.is_empty():
		_tambah_kartu_belum_tersedia()
		return
	_tambah_kartu_progres(nomor)
	_tambah_kartu_soal(soal, nomor)
	_tambah_tombol_kunci()
	_tambah_riwayat()


func _tambah_header() -> void:
	var nomor := _nomor_bagian(_bagian)
	var judul := ""
	if nomor >= 1 and nomor <= 4:
		# "Bagian 2" di mockup = Bagian BERIKUTNYA yang dibuka bila
		# lulus (nomor + 1), bukan nomor Bagian tes itu sendiri.
		judul = "Kantor • Tes Naik Bagian %d (%s.T)" % [nomor + 1, _bagian]
	else:
		judul = "Kantor • Tes Naik Bagian (%s.T)" % _bagian
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 8)
	_konten.add_child(baris)
	var l := GayaMisi.buat_label(judul, 20, GayaMisi.KREM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	baris.add_child(l)
	_konten.add_child(GayaMisi.buat_label(
		"10 soal • Lulus bila benar ≥ 8 • +%d poin bila lulus" % POIN_TES,
		16, GayaMisi.KREM_REDUP, true
	))


func _tambah_kartu_belum_tersedia() -> void:
	var nomor := _nomor_bagian(_bagian)
	var teks := ""
	if nomor >= 1:
		teks = "Bank soal Bagian %d belum tersedia — menunggu tashih." % nomor
	else:
		teks = "Bank soal %s belum tersedia — menunggu tashih." % _bagian
	var v := _buat_kartu()
	v.add_child(GayaMisi.buat_label(teks, 18, GayaMisi.KREM, true))
	var tutup := GayaMisi.buat_tombol_emas("Tutup")
	tutup.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutup.pressed.connect(_on_tutup_ditekan)
	_konten.add_child(tutup)


func _tambah_kartu_progres(nomor: int) -> void:
	var jumlah := _mesin.jumlah_soal()
	var v := _buat_kartu()
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 8)
	v.add_child(baris)
	var l := GayaMisi.buat_label("Soal %d dari %d" % [nomor, jumlah], 18, GayaMisi.KREM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	baris.add_child(l)
	var salah := 0
	for r in _riwayat:
		if not r:
			salah += 1
	baris.add_child(GayaMisi.buat_label(
		"Benar %d • Salah %d" % [_mesin.skor(), salah],
		16, GayaMisi.KREM_REDUP
	))
	v.add_child(_bilah(float(nomor) / float(maxi(jumlah, 1))))


func _tambah_kartu_soal(soal: Dictionary, nomor: int) -> void:
	var v := _buat_kartu()
	v.add_child(GayaMisi.buat_label("SOAL %d" % nomor, 16, GayaMisi.EMAS_TERANG))
	v.add_child(GayaMisi.buat_label(String(soal.get("pertanyaan", "")), 20, GayaMisi.KREM, true))
	var petunjuk := String(soal.get("petunjuk", "")).strip_edges()
	if petunjuk != "":
		v.add_child(GayaMisi.buat_label("Petunjuk: " + petunjuk, 16, GayaMisi.KREM_REDUP, true))
	var opsi: Array = soal.get("opsi", [])
	for i in range(4):
		var teks := ""
		if i < opsi.size():
			teks = String(opsi[i])
		var b := GayaMisi.buat_tombol_outline("%s. %s" % [HURUF_OPSI[i], teks])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = _terkunci
		if i == _pilihan:
			_sorot_emas(b)
		b.pressed.connect(_on_opsi_ditekan.bind(i))
		v.add_child(b)
	if _terkunci:
		var umpan := ""
		if _jawaban_benar:
			umpan = "Benar ✓"
		elif _jawaban_benar_teks != "":
			umpan = "Salah ✗ — jawaban benar: %s" % _jawaban_benar_teks
		else:
			umpan = "Salah ✗"
		var warna := GayaMisi.EMAS_TERANG if _jawaban_benar else GayaMisi.KREM
		v.add_child(GayaMisi.buat_label(umpan, 18, warna, true))


func _tambah_tombol_kunci() -> void:
	var teks := "Kunci Jawaban"
	if _terkunci:
		teks = "Lihat Hasil" if _mesin.selesai() else "Soal Berikutnya"
	var b := GayaMisi.buat_tombol_emas(teks)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.disabled = (not _terkunci) and _pilihan < 0
	b.pressed.connect(_on_kunci_ditekan)
	_konten.add_child(b)


func _tambah_riwayat() -> void:
	if _riwayat.is_empty():
		return
	_konten.add_child(GayaMisi.buat_label("Jawaban sejauh ini:", 16, GayaMisi.KREM_REDUP))
	var alir := HFlowContainer.new()
	alir.add_theme_constant_override("h_separation", 8)
	alir.add_theme_constant_override("v_separation", 8)
	_konten.add_child(alir)
	for i in range(_riwayat.size()):
		var teks := ""
		if _riwayat[i]:
			teks = "Soal %d ✓ Benar" % (i + 1)
		else:
			teks = "Soal %d ✗ Salah" % (i + 1)
		alir.add_child(GayaMisi.buat_chip(teks))


func _tambah_kartu_hasil() -> void:
	var skor := _mesin.skor()
	var jumlah := _mesin.jumlah_soal()
	var lulus := _mesin.lulus(MesinKuis.AMBANG_TES_DEFAULT)
	var v := _buat_kartu()
	# Mockup menulis "CONTOH HASIL" — panel nyata memakai "HASIL TES".
	v.add_child(GayaMisi.buat_label("HASIL TES", 16, GayaMisi.EMAS_TERANG))
	if lulus:
		v.add_child(GayaMisi.buat_label("LULUS — %d/%d" % [skor, jumlah], 24, GayaMisi.EMAS_TERANG))
		var alir := HFlowContainer.new()
		alir.add_theme_constant_override("h_separation", 8)
		alir.add_theme_constant_override("v_separation", 8)
		v.add_child(alir)
		alir.add_child(GayaMisi.buat_chip("+%d poin" % POIN_TES))
		alir.add_child(GayaMisi.buat_chip("+%d bintang gelar" % MesinKuis.BINTANG_TES))
		alir.add_child(GayaMisi.buat_chip("Buka Bagian %d" % (_nomor_bagian(_bagian) + 1)))
		var tutup := GayaMisi.buat_tombol_outline("Tutup")
		tutup.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tutup.pressed.connect(_on_tutup_ditekan)
		v.add_child(tutup)
	else:
		v.add_child(GayaMisi.buat_label("BELUM LULUS — %d/%d" % [skor, jumlah], 24, GayaMisi.KREM))
		v.add_child(GayaMisi.buat_label(
			"Gagal = ulangi kuisnya saja, bukan dari awal. Bintang tidak berkurang.",
			16, GayaMisi.KREM_REDUP, true
		))
		var ulangi := GayaMisi.buat_tombol_emas("Ulangi Tes")
		ulangi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ulangi.pressed.connect(_on_ulangi_ditekan)
		v.add_child(ulangi)
		var tutup := GayaMisi.buat_tombol_outline("Tutup")
		tutup.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tutup.pressed.connect(_on_tutup_ditekan)
		v.add_child(tutup)


func _nomor_bagian(bagian: String) -> int:
	if bagian.length() != 2:
		return 0
	if bagian[0] != "N":
		return 0
	if not bagian[1].is_valid_int():
		return 0
	return int(bagian[1])


func _bilah(fraksi: float) -> ProgressBar:
	var b := GayaMisi.buat_bilah_progres()
	b.value = clampf(fraksi, 0.0, 1.0)
	b.custom_minimum_size = Vector2(0, 14)
	return b


func _buat_kartu() -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", GayaMisi.gaya_kartu())
	p.add_theme_constant_override("margin_left", 14)
	p.add_theme_constant_override("margin_right", 14)
	p.add_theme_constant_override("margin_top", 12)
	p.add_theme_constant_override("margin_bottom", 12)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	_konten.add_child(p)
	return v


func _sorot_emas(b: Button) -> void:
	b.add_theme_stylebox_override("normal", GayaMisi.gaya_tombol_emas())
	b.add_theme_stylebox_override("hover", GayaMisi.gaya_tombol_emas_hover())
	b.add_theme_stylebox_override("pressed", GayaMisi.gaya_tombol_emas_pressed())
	b.add_theme_color_override("font_color", GayaMisi.ZAMRUD_GELAP)
	b.add_theme_color_override("font_hover_color", GayaMisi.ZAMRUD_GELAP)
	b.add_theme_color_override("font_pressed_color", GayaMisi.ZAMRUD_GELAP)


func _bersihkan(kontainer: Container) -> void:
	for anak in kontainer.get_children():
		kontainer.remove_child(anak)
		anak.queue_free()
