class_name PanelMisiUI
extends PanelContainer
## Panel Misi Bagian 1 (Hijau) — Fase A, A9 (Nusa, 18 Nov 2026).
## Acuan: mockup panel-misi-v1.png (DI-ACC Mas) + DataMisiBagian.
## V2 (Tara, 19 Nov 2026 — konsep panel-misi-v2 DI-ACC Mas
## 19:06 WIB): panel gradien 9-slice + kartu terpisah + chip AKTIF
## isi penuh + tombol Tutup berwadah. Isi/teks/poin TIDAK berubah.
## PELAJARAN v2: (1) theme constant margin_* PanelContainer TIDAK
## BERLAKU — padding kartu lama tidak pernah diterapkan; padding
## kini lewat content margin stylebox. (2) Button TIDAK menghitung
## isi HBox anak ke lebar minimum — Tutup lama flat 8 px dan
## isinya meluber menimpa chip Chat ("✕ □ Tutup"); kini stylebox
## + custom_minimum_size. (3) Panel TIDAK memakai TextureRect
## latar 1:1 seperti dialog — bakar gradien ukuran panel butuh
## ~2 detik (probe); gradien vertikal 9-slice hasilnya identik.
## Branding: "Pesantren Universe" — panel ini tidak menulis nama
## game sama sekali; JANGAN tulis "Verse" di sini.
##
## CATATAN:
## - tampilkan(save) membangun ulang seluruh isi dari save, jadi
##   boleh dipanggil ulang untuk refresh (mis. setelah satu misi
##   selesai). Kunci save dibaca defensif oleh DataMisiBagian /
##   Gelar, jadi save lama tanpa kunci tetap aman.
## - Hanya baris berstatus "aktif" yang bisa ditekan (satu-satunya
##   baris aktif). Menekannya MENUTUP panel + meng-emit ditutup —
##   navigasi ke target misi BELUM diimplementasi (langkah berikut,
##   dipasang main.gd gelombang 2 oleh Raka; JANGAN dikarang di
##   sini). Baris selesai/terkunci bukan tombol.
## - Subjudul gelar: "arti • Divisi X"; bila arti "" hanya "Divisi X"
##   yang tampil (tanpa "•"); tier 8 'Santri Senior (arti "" dan
##   divisi "") tidak punya baris sub — nama besar saja.
## - "X dari 7 misi" menghitung baris misi saja (baris tes N1.T
##   tidak dihitung sebagai misi); "X/110 poin" memakai
##   DataMisiBagian.total_poin().
## - Penutup oleh pemain (footer "Tutup", baris aktif) meng-emit
##   ditutup; tutup() menutup diam-diam tanpa sinyal (untuk
##   penutupan programatik oleh main.gd).

signal ditutup

var _save := {}

var _gulung: ScrollContainer
var _konten: VBoxContainer


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 18
	offset_top = 64
	offset_right = -18
	offset_bottom = -18
	# V2: panel luar hanya menggambar BAYANGAN (StyleBoxFlat
	# transparan — StyleBoxTexture tidak mendukung bayangan);
	# panel dalam menggambar gradien + rim emas. Isi masuk ke
	# panel dalam supaya mengisi penuh rect luar.
	add_theme_stylebox_override("panel", GayaMisi.gaya_panel_bayangan())
	var dalam := PanelContainer.new()
	dalam.add_theme_stylebox_override("panel", GayaMisi.gaya_panel_gradien_tekstur())
	add_child(dalam)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	dalam.add_child(margin)
	var akar := VBoxContainer.new()
	akar.add_theme_constant_override("separation", 12)
	margin.add_child(akar)
	var tengah := CenterContainer.new()
	tengah.add_child(GayaMisi.buat_tab_judul("Panel Misi"))
	akar.add_child(tengah)
	_gulung = ScrollContainer.new()
	_gulung.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_gulung.size_flags_vertical = Control.SIZE_EXPAND_FILL
	akar.add_child(_gulung)
	_konten = VBoxContainer.new()
	_konten.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_konten.add_theme_constant_override("separation", 6)
	_gulung.add_child(_konten)
	# V2: garis emas tipis pemisah footer (mockup: border-top emas 28%).
	var garis_kaki := Panel.new()
	garis_kaki.custom_minimum_size = Vector2(0, 1)
	var sb_garis := StyleBoxFlat.new()
	var emas_garis := GayaMisi.EMAS_TERANG
	emas_garis.a = 0.28
	sb_garis.bg_color = emas_garis
	garis_kaki.add_theme_stylebox_override("panel", sb_garis)
	akar.add_child(garis_kaki)
	var kaki := HBoxContainer.new()
	kaki.add_theme_constant_override("separation", 8)
	akar.add_child(kaki)
	var label_kaki := GayaMisi.buat_label(
		"Bagian 1 dari 4 • " + DataMisiBagian.BAGIAN_MODUL,
		16, GayaMisi.KREM_REDUP
	)
	label_kaki.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kaki.add_child(label_kaki)
	var tutup := Button.new()
	tutup.text = ""
	tutup.focus_mode = Control.FOCUS_NONE
	# V2: tombol berwadah (bukan flat) + lebar minimum benar —
	# isi HBox 72 px + padding stylebox 30 px = 102 px.
	tutup.add_theme_stylebox_override("normal", GayaMisi.gaya_tombol_tutup())
	tutup.add_theme_stylebox_override("hover", GayaMisi.gaya_tombol_tutup_hover())
	tutup.add_theme_stylebox_override("pressed", GayaMisi.gaya_tombol_tutup_pressed())
	tutup.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	tutup.custom_minimum_size = Vector2(102, 32)
	tutup.pressed.connect(_on_tutup_ditekan)
	# IKON PANEL (Tara, 19 Nov 2026): "✕ Tutup" teks tofu di web —
	# ikon "x" digambar IkonHUD di dalam tombol (pola baris aktif:
	# isi HBox full-rect + mouse IGNORE).
	var isi_tutup := HBoxContainer.new()
	isi_tutup.set_anchors_preset(Control.PRESET_FULL_RECT)
	isi_tutup.add_theme_constant_override("separation", 8)
	isi_tutup.alignment = BoxContainer.ALIGNMENT_CENTER
	tutup.add_child(isi_tutup)
	var ikon_tutup := IkonHUD.new()
	ikon_tutup.jenis = "x"
	ikon_tutup.warna = GayaMisi.KREM
	ikon_tutup.bayangan = false
	ikon_tutup.custom_minimum_size = Vector2(18, 18)
	ikon_tutup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	isi_tutup.add_child(ikon_tutup)
	isi_tutup.add_child(GayaMisi.buat_label("Tutup", 16, GayaMisi.KREM))
	_abaikan_mouse(isi_tutup)
	kaki.add_child(tutup)
	var chat_chip := HBoxContainer.new()
	chat_chip.add_theme_constant_override("separation", 6)
	chat_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ikon_chat := IkonHUD.new()
	ikon_chat.jenis = "kotak"
	ikon_chat.warna = GayaMisi.KREM_REDUP
	ikon_chat.bayangan = false
	ikon_chat.custom_minimum_size = Vector2(16, 16)
	ikon_chat.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chat_chip.add_child(ikon_chat)
	var label_chat := GayaMisi.buat_label("Chat", 16, GayaMisi.KREM_REDUP)
	label_chat.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chat_chip.add_child(label_chat)
	kaki.add_child(chat_chip)


## Tampilkan (atau refresh) panel dari save. Panel hidden sebelum
## tampilkan() dipanggil.
func tampilkan(save: Dictionary) -> void:
	_save = save
	visible = true
	_render()


## Sembunyikan panel tanpa sinyal (penutupan programatik).
func tutup() -> void:
	visible = false


func _on_tutup_ditekan() -> void:
	visible = false
	ditutup.emit()


func _on_baris_aktif_ditekan() -> void:
	# LANGKAH BERIKUT (belum diimplementasi — JANGAN dikarang):
	# navigasi ke target misi aktif (Ruang Belajar / Ustadz /
	# Kantor) dipasang main.gd gelombang 2 (Raka). Panel ditutup
	# dan sinyal ditutup di-emit supaya main.gd bisa menyambung
	# navigasi di sana.
	visible = false
	ditutup.emit()


func _render() -> void:
	_bersihkan(_konten)
	_tambah_kartu_gelar()
	_tambah_progres_bagian()
	_tambah_daftar_misi()
	_tambah_petunjuk_terakhir()
	_tambah_strip_tugas()
	_tambah_kartu_bagian_berikut()


func _tambah_kartu_gelar() -> void:
	var info := Gelar.tier_saat_ini(_save)
	var nama: String = info.get("nama", "")
	var divisi: String = info.get("divisi", "")
	var bintang_divisi: int = info.get("bintang_divisi", 0)
	var bintang_butuh: int = info.get("bintang_butuh", 0)
	var total_bintang: int = info.get("total_bintang", 0)
	var arti := String(DataMisiBagian.SUBJUDUL_GELAR.get(nama, ""))
	var v := _buat_kartu()
	v.add_child(GayaMisi.buat_label_subjudul("GELAR SAAT INI"))
	v.add_child(GayaMisi.buat_label(nama, 26, GayaMisi.EMAS_TERANG))
	var bagian_sub: Array[String] = []
	if arti != "":
		bagian_sub.append(arti)
	if divisi != "":
		bagian_sub.append("Divisi " + divisi)
	if not bagian_sub.is_empty():
		v.add_child(GayaMisi.buat_label(" • ".join(bagian_sub), 16, GayaMisi.KREM))
	# IKON PANEL (Tara, 19 Nov 2026): bintang "★"/"☆" teks tofu di
	# web — bintang isi/kosong digambar IkonHUD.
	var baris_bintang := HBoxContainer.new()
	baris_bintang.add_theme_constant_override("separation", 4)
	if bintang_butuh > 0:
		for i in range(bintang_butuh):
			var ikon := IkonHUD.new()
			ikon.jenis = "bintang" if i < bintang_divisi else "bintang_kosong"
			ikon.warna = GayaMisi.EMAS_TERANG
			ikon.bayangan = false
			ikon.custom_minimum_size = Vector2(20, 20)
			baris_bintang.add_child(ikon)
		baris_bintang.add_child(GayaMisi.buat_label(" %d/%d bintang" % [bintang_divisi, bintang_butuh], 18, GayaMisi.EMAS_TERANG))
	else:
		# Tier 8 'Santri Senior: tanpa divisi — tampilkan total.
		var ikon := IkonHUD.new()
		ikon.jenis = "bintang"
		ikon.warna = GayaMisi.EMAS_TERANG
		ikon.bayangan = false
		ikon.custom_minimum_size = Vector2(20, 20)
		baris_bintang.add_child(ikon)
		baris_bintang.add_child(GayaMisi.buat_label(" %d bintang" % total_bintang, 18, GayaMisi.EMAS_TERANG))
	v.add_child(baris_bintang)
	var fraksi := 0.0
	if bintang_butuh > 0:
		fraksi = float(bintang_divisi) / float(bintang_butuh)
	v.add_child(_bilah(fraksi))
	var kaki := GayaMisi.buat_label(
		"%d poin • %s" % [DataMisiBagian.poin_bagian(_save), DataMisiBagian.BAGIAN_NAMA],
		16, GayaMisi.KREM_REDUP
	)
	kaki.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(kaki)


func _tambah_progres_bagian() -> void:
	var selesai := 0
	var total_misi := 0
	for b in DataMisiBagian.status_baris(_save):
		if String(b.get("id", "")).ends_with(".T"):
			continue
		total_misi += 1
		if String(b.get("status", "")) == "selesai":
			selesai += 1
	_konten.add_child(GayaMisi.buat_label(
		"%s — %d dari %d misi" % [DataMisiBagian.BAGIAN_NAMA, selesai, total_misi],
		18, GayaMisi.KREM
	))
	var fraksi := 0.0
	if total_misi > 0:
		fraksi = float(selesai) / float(total_misi)
	_konten.add_child(_bilah(fraksi))
	var poin := GayaMisi.buat_label(
		"%d/%d poin" % [DataMisiBagian.poin_bagian(_save), DataMisiBagian.total_poin()],
		16, GayaMisi.KREM_REDUP
	)
	poin.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_konten.add_child(poin)


func _tambah_daftar_misi() -> void:
	_konten.add_child(GayaMisi.buat_label_subjudul("MISI BAGIAN 1"))
	for b in DataMisiBagian.status_baris(_save):
		_tambah_baris_misi(b)


func _tambah_baris_misi(b: Dictionary) -> void:
	var status := String(b.get("status", "terkunci"))
	if status == "aktif":
		# Satu-satunya baris yang bisa ditekan: Button dengan isi
		# HBox full-rect; isi di-IGNORE mouse-nya supaya klik
		# sampai ke Button (Label default STOP).
		# V2: kartu aktif bergradien + rim emas (semua mode sama).
		# Button TIDAK menghitung isi HBox anak ke ukuran minimum
		# (probe: min 16 px, isi meluber) — tinggi ditetapkan
		# 42 px: label baris 18 px (~25) + offset 16, SAMA dengan
		# kartu terkunci. JANGAN hitung dari get_minimum_size()
		# saat membangun — metrik font label belum final di situ
		# (probe: isi terukur 23 px saat bangun, 29 px sesudah
		# layout), hasilnya tombol 39 px dan isi meluber.
		var tombol := Button.new()
		tombol.text = ""
		tombol.focus_mode = Control.FOCUS_NONE
		tombol.custom_minimum_size = Vector2(0, 42)
		for mode in ["normal", "hover", "pressed", "disabled", "focus"]:
			tombol.add_theme_stylebox_override(mode, GayaMisi.gaya_kartu_aktif_gradien())
		var isi := _isi_baris_misi(b)
		isi.set_anchors_preset(Control.PRESET_FULL_RECT)
		isi.offset_left = 16
		isi.offset_top = 8
		isi.offset_right = -16
		isi.offset_bottom = -8
		_abaikan_mouse(isi)
		tombol.add_child(isi)
		tombol.pressed.connect(_on_baris_aktif_ditekan)
		_konten.add_child(tombol)
		return
	var kartu := PanelContainer.new()
	kartu.add_theme_stylebox_override("panel", GayaMisi.gaya_kartu_gradien())
	kartu.add_child(_isi_baris_misi(b))
	_konten.add_child(kartu)


func _isi_baris_misi(b: Dictionary) -> HBoxContainer:
	var status := String(b.get("status", "terkunci"))
	# IKON PANEL (Tara, 19 Nov 2026): "🔒"/"✓"/"▶" teks tofu di web
	# — gembok/centang/segitiga-isi digambar IkonHUD.
	var jenis_ikon := "gembok"
	if status == "selesai":
		jenis_ikon = "centang"
	elif status == "aktif":
		jenis_ikon = "segitiga_isi"
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 10)
	var ikon := IkonHUD.new()
	ikon.jenis = jenis_ikon
	ikon.warna = GayaMisi.EMAS_TERANG
	ikon.bayangan = false
	ikon.custom_minimum_size = Vector2(22, 22)
	ikon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	baris.add_child(ikon)
	var l_id := GayaMisi.buat_label(String(b.get("id", "")), 18, GayaMisi.EMAS_TERANG)
	l_id.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	baris.add_child(l_id)
	var warna_judul := GayaMisi.KREM
	if status == "terkunci":
		warna_judul = GayaMisi.KREM_REDUP
	var judul := GayaMisi.buat_label(String(b.get("judul", "")), 18, warna_judul)
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	judul.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	baris.add_child(judul)
	if status == "aktif":
		# V2: chip AKTIF isi penuh (pill emas, teks zamrud gelap).
		baris.add_child(GayaMisi.buat_chip_isi("AKTIF"))
	var warna_poin := GayaMisi.KREM if status == "aktif" else GayaMisi.KREM_REDUP
	var poin := GayaMisi.buat_label("+%d poin" % int(b.get("poin", 0)), 16, warna_poin)
	poin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	baris.add_child(poin)
	return baris


## TEKA-TEKI (Raka, 18 Nov 2026 — keputusan Mas 23:03 WIB no. 2):
## teka-teki TERAKHIR yang diberikan NPC tampil di sini supaya santri
## tidak lupa setelah menutup dialog. Syarat tampil: misi cari guru
## sedang aktif (langkah 4) DAN santri sudah bertanya ke minimal
## satu NPC (tanya_guru tidak kosong). Teka-teki dihitung dari id
## lokasi di save — sama untuk semua NPC di lokasi yang sama, jadi
## "terakhir" = teka-teki lokasi saat ini. Tanpa bertanya, kartu
## ini TIDAK muncul (petunjuk tidak bocor gratis).
func _tambah_petunjuk_terakhir() -> void:
	var ob := Onboarding.baca(_save)
	if int(ob["langkah"]) != 4:
		return
	var sudah: Array = _save.get("tanya_guru", [])
	if sudah.is_empty():
		return
	var putri := String(_save.get("jenis_kelamin", "putra")) == "putri"
	var lok_id := String(ob["fatimah_lokasi" if putri else "sanusi_lokasi"])
	var teka := DataTekaTeki.teka_teki_untuk(lok_id)
	if teka == "":
		return
	var v := _buat_kartu()
	v.add_child(GayaMisi.buat_label_subjudul("PETUNJUK TERAKHIR"))
	v.add_child(GayaMisi.buat_label("“" + teka + "”", 16, GayaMisi.KREM, true))


func _tambah_strip_tugas() -> void:
	var tugas: Dictionary = DataMisiBagian.TUGAS
	var v := _buat_kartu()
	v.add_child(GayaMisi.buat_label(String(tugas.get("label", "Tugas dari Ustadz")), 18, GayaMisi.EMAS_TERANG))
	var poin := int(tugas.get("poin", 0))
	v.add_child(GayaMisi.buat_label(
		String(tugas.get("teks", "")),
		16, GayaMisi.KREM, true
	))
	# IKON PANEL (Tara, 19 Nov 2026): "Selesai ✓" teks tofu di web —
	# centang digambar IkonHUD.
	if DataMisiBagian.tugas_selesai(_save):
		var baris_status := HBoxContainer.new()
		baris_status.add_theme_constant_override("separation", 8)
		var ikon := IkonHUD.new()
		ikon.jenis = "centang"
		ikon.warna = GayaMisi.EMAS_TERANG
		ikon.bayangan = false
		ikon.custom_minimum_size = Vector2(18, 18)
		baris_status.add_child(ikon)
		baris_status.add_child(GayaMisi.buat_label("Selesai • +%d poin" % poin, 16, GayaMisi.KREM))
		v.add_child(baris_status)
	else:
		v.add_child(GayaMisi.buat_label("Belum selesai • +%d poin" % poin, 16, GayaMisi.KREM))
	# IKON PANEL (Tara, 19 Nov 2026): "→" (U+2192) tofu di web —
	# Baloo 2 tak punya panah itu; "›" (U+203A) terbukti aman.
	# V2: baris rata tengah, pemisah › emas tebal (mockup).
	var pola := HBoxContainer.new()
	pola.add_theme_constant_override("separation", 0)
	pola.alignment = BoxContainer.ALIGNMENT_CENTER
	pola.add_child(GayaMisi.buat_label("Pola misi: cari Ustadz ", 14, GayaMisi.KREM_REDUP))
	pola.add_child(GayaMisi.buat_label_tebal("›", 14, GayaMisi.EMAS_TERANG))
	pola.add_child(GayaMisi.buat_label(" belajar ", 14, GayaMisi.KREM_REDUP))
	pola.add_child(GayaMisi.buat_label_tebal("›", 14, GayaMisi.EMAS_TERANG))
	pola.add_child(GayaMisi.buat_label(" tugas dari Ustadz", 14, GayaMisi.KREM_REDUP))
	_konten.add_child(pola)


func _tambah_kartu_bagian_berikut() -> void:
	var v := _buat_kartu()
	# IKON PANEL (Tara, 19 Nov 2026): "🔒" teks tofu di web —
	# gembok digambar IkonHUD.
	var baris_berikut := HBoxContainer.new()
	baris_berikut.add_theme_constant_override("separation", 8)
	var ikon_berikut := IkonHUD.new()
	ikon_berikut.jenis = "gembok"
	ikon_berikut.warna = GayaMisi.KREM_REDUP
	ikon_berikut.bayangan = false
	ikon_berikut.custom_minimum_size = Vector2(20, 20)
	baris_berikut.add_child(ikon_berikut)
	baris_berikut.add_child(GayaMisi.buat_label(DataMisiBagian.BAGIAN_BERIKUT_NAMA, 18, GayaMisi.KREM_REDUP))
	v.add_child(baris_berikut)
	v.add_child(GayaMisi.buat_label(DataMisiBagian.BAGIAN_BERIKUT_SYARAT, 16, GayaMisi.KREM_REDUP))


func _bilah(fraksi: float) -> ProgressBar:
	var b := GayaMisi.buat_bilah_progres()
	b.value = clampf(fraksi, 0.0, 1.0)
	b.custom_minimum_size = Vector2(0, 14)
	return b


func _buat_kartu() -> VBoxContainer:
	var p := PanelContainer.new()
	# V2: kartu gradien; padding lewat content margin stylebox
	# (theme constant margin_* PanelContainer tidak berlaku).
	p.add_theme_stylebox_override("panel", GayaMisi.gaya_kartu_gradien(10, 11))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	_konten.add_child(p)
	return v


func _abaikan_mouse(kontrol: Control) -> void:
	kontrol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for anak in kontrol.get_children():
		if anak is Control:
			_abaikan_mouse(anak)


func _bersihkan(kontainer: Container) -> void:
	for anak in kontainer.get_children():
		kontainer.remove_child(anak)
		anak.queue_free()
