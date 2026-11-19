class_name DialogMisi
extends PanelContainer
## Panel dialog misi pembuka — Fase A, A9 (Sinta, 18 Nov 2026).
## Mockup ACC Mas: dialog-aqsal-v2.png (panel zamrud gelap + rim
## emas + tab emas + footer "Babak X dari 5" /
## "✕ Lanjut □ Chat").
##
## Panel ini TIDAK membuat dim sendiri dan TIDAK mengatur anchor
## sendiri — Manajer (Raka) yang menaruhnya di tengah + memberi
## dim. Panel hidden saat dibuat; tampilkan() memunculkan.
##
## Isi babak + pilihan berasal dari DataDialogMisi (kontrak
## Dita/Wulan); gaya dari GayaMisi; avatar dari AvatarMisi.

signal selesai  ## percakapan tuntas (pilihan "ke" == -1)
signal ditutup  ## pemain menutup di tengah (JANGAN emit selesai)
## TEKA-TEKI (Raka, 18 Nov 2026): pemain memilih di layar tanya —
## "tanya" (bertanya tentang guru) atau "sapa" (tutup saja).
signal pilihan_tanya(id_pilihan: String)

const _LEBAR_MIN := 660.0

var _pembicara := "putra"
var _babak := 1

var _tab_wadah: HBoxContainer
var _subjudul: Label
var _salam_arab: Label
var _avatar: AvatarMisi
var _teks: Label
var _gulung: ScrollContainer
var _pilihan_box: VBoxContainer
var _footer_kiri: Label
var _footer_dot: HBoxContainer
var _anim_tween: Tween = null


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(_LEBAR_MIN, 0)
	# v2 (19 Nov 2026): panel gradien zamrud + rim emas 2 + radius 26
	# (gaya_panel_gradien, transparan — gradien dari TextureRect latar
	# di bawah, anak pertama panel).
	add_theme_stylebox_override("panel", GayaMisi.gaya_panel_gradien())
	# v2-perbaikan sudut (Sinta, 19 Nov 2026): latar dibakar 660x560
	# (ukuran panel sebenarnya, LEBAR_PANEL x TINGGI_DIALOG) — 1:1,
	# tanpa rentang. Panggang 96x96 lama direntang ~7x bikin sudut
	# bergerigi/tangga saat di-zoom (foto dialog v2).
	add_child(GayaMisi.buat_latar_gradien(GayaMisi.ZAMRUD, GayaMisi.ZAMRUD_GELAP, 23, Vector2i(660, 560)))
	# Animasi masuk memakai pivot tengah — jaga tetap di tengah.
	resized.connect(func() -> void: pivot_offset = size * 0.5)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)

	# Baris atas: tab emas nama pembicara + tombol ✕.
	# (Chip "TEKS DRAF" DIHAPUS atas keputusan Mas, 19 Nov 2026
	# 13:05 WIB — jangan dipasang lagi di sini.)
	var atas := HBoxContainer.new()
	atas.add_theme_constant_override("separation", 8)
	v.add_child(atas)

	_tab_wadah = HBoxContainer.new()
	_tab_wadah.add_theme_constant_override("separation", 0)
	atas.add_child(_tab_wadah)

	var spasi := Control.new()
	spasi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	atas.add_child(spasi)

	var tombol_tutup := Button.new()
	tombol_tutup.text = "✕"
	tombol_tutup.tooltip_text = "Tutup"
	tombol_tutup.flat = true
	tombol_tutup.pressed.connect(_on_tutup_ditekan)
	atas.add_child(tombol_tutup)

	# v2 — Kepala: avatar di kiri, subjudul kapital + salam Arab di
	# kanan avatar (dulu subjudul satu baris di bawah tab).
	var kepala := HBoxContainer.new()
	kepala.add_theme_constant_override("separation", 14)
	v.add_child(kepala)

	_avatar = AvatarMisi.new()
	_avatar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	kepala.add_child(_avatar)

	var kepala_teks := VBoxContainer.new()
	kepala_teks.add_theme_constant_override("separation", 2)
	kepala_teks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kepala_teks.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	kepala.add_child(kepala_teks)

	# Subjudul pembicara ("Pengasuh Pesantren Universe" dst) —
	# v2: kapital berjarak, emas terang.
	_subjudul = GayaMisi.buat_label_subjudul("")
	kepala_teks.add_child(_subjudul)

	# Salam Arab pembicara (tanpa harakat — render harakat di game
	# berantakan, pelajaran mockup v2).
	_salam_arab = GayaMisi.buat_label_arab("أهلا وسهلا", 20)
	_salam_arab.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kepala_teks.add_child(_salam_arab)

	# Isi: aksen emas vertikal di kiri + teks babak (bisa digulung).
	var isi := HBoxContainer.new()
	isi.add_theme_constant_override("separation", 12)
	v.add_child(isi)

	var aksen := ColorRect.new()
	aksen.color = GayaMisi.EMAS
	aksen.custom_minimum_size = Vector2(4, 0)
	aksen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	isi.add_child(aksen)

	_gulung = ScrollContainer.new()
	_gulung.custom_minimum_size = Vector2(0, 120)
	_gulung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gulung.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_gulung.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	isi.add_child(_gulung)

	# v2: isi 21 + jarak baris lega (leading ~1,45).
	_teks = GayaMisi.buat_label("", 21, GayaMisi.KREM)
	_teks.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_teks.add_theme_constant_override("line_spacing", 6)
	_teks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gulung.add_child(_teks)

	# v2 — Pemisah emas tipis antara isi dan tombol.
	var pemisah := ColorRect.new()
	var warna_pemisah := GayaMisi.EMAS
	warna_pemisah.a = 140.0 / 255.0
	pemisah.color = warna_pemisah
	pemisah.custom_minimum_size = Vector2(0, 2)
	pemisah.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(pemisah)

	# Tombol pilihan (dibangun ulang tiap babak).
	_pilihan_box = VBoxContainer.new()
	_pilihan_box.add_theme_constant_override("separation", 8)
	v.add_child(_pilihan_box)

	# Footer v2: titik progres + "Babak X dari 5" di kiri,
	# chip keycap "✕ Lanjut" / "□ Chat" di kanan.
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	v.add_child(footer)

	_footer_dot = GayaMisi.buat_dot_progres(DataDialogMisi.JUMLAH_BABAK, 1)
	footer.add_child(_footer_dot)

	_footer_kiri = GayaMisi.buat_label("", 14, GayaMisi.KREM_REDUP)
	footer.add_child(_footer_kiri)

	var spasi_footer := Control.new()
	spasi_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spasi_footer)

	footer.add_child(GayaMisi.buat_chip_kunci("✕ Lanjut"))
	footer.add_child(GayaMisi.buat_chip_kunci("□ Chat"))


## Tampilkan dialog dari babak 1. Pembicara tak dikenal -> "putra".
func tampilkan(pembicara: String) -> void:
	_pembicara = pembicara if pembicara == "putri" else "putra"
	var info: Dictionary = DataDialogMisi.PEMBICARA.get(_pembicara, {})
	_atur_kepala(
		String(info.get("nama", "Ust. Aqsal M")),
		String(info.get("subjudul", "Pengasuh Pesantren Universe")),
		String(info.get("avatar", "kyai"))
	)
	_tampilkan_babak(1)
	visible = true
	_animasi_masuk()


## TEKA-TEKI (Raka, 18 Nov 2026): layar tanya SATU langkah — BUKAN
## babak 1-5 (footer tidak menulis "Babak X dari 5"). Dipakai saat
## santri mendekati NPC yang bisa ditanya di langkah 4: pilihan
## "Tanya tentang guru" (emit pilihan_tanya "tanya") atau "Sapa
## saja" (emit "sapa" — main menutup saja). Panel disembunyikan
## sebelum sinyal di-emit supaya main bisa langsung membuka panel
## teka-teki tanpa tumpukan.
func tampilkan_tanya(nama: String, subjudul: String, avatar: String, teks: String, label_tanya: String) -> void:
	_atur_kepala(nama, subjudul, avatar)
	_teks.text = teks
	_gulung.scroll_vertical = 0
	_footer_kiri.text = "Tanya NPC"
	_footer_dot.visible = false
	for anak in _pilihan_box.get_children():
		anak.queue_free()
	var tombol_tanya := GayaMisi.buat_tombol_emas(label_tanya)
	tombol_tanya.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tombol_tanya.pressed.connect(_on_tanya_dipilih.bind("tanya"))
	_pilihan_box.add_child(tombol_tanya)
	var tombol_sapa := GayaMisi.buat_tombol_outline("Sapa saja")
	tombol_sapa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tombol_sapa.pressed.connect(_on_tanya_dipilih.bind("sapa"))
	_pilihan_box.add_child(tombol_sapa)
	visible = true
	_animasi_masuk()


## TEKA-TEKI (Raka, 18 Nov 2026): layar pesan SATU langkah — teks
## teka-teki (atau pengulangan / jaga-jaga) + satu tombol "Tutup".
## Tidak emit selesai (bukan dialog 5 babak — main TIDAK boleh maju
## langkah karena pemain membaca petunjuk).
func tampilkan_pesan(nama: String, subjudul: String, avatar: String, teks: String) -> void:
	_atur_kepala(nama, subjudul, avatar)
	_teks.text = teks
	_gulung.scroll_vertical = 0
	_footer_kiri.text = "Petunjuk"
	_footer_dot.visible = false
	for anak in _pilihan_box.get_children():
		anak.queue_free()
	var tombol := GayaMisi.buat_tombol_emas("Tutup")
	tombol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tombol.pressed.connect(_on_pesan_ditutup)
	_pilihan_box.add_child(tombol)
	visible = true
	_animasi_masuk()


## Isi kepala panel: tab nama + subjudul + avatar. Dipakai tampilkan()
## (dialog 5 babak) dan tampilkan_tanya()/tampilkan_pesan().
func _atur_kepala(nama: String, subjudul: String, avatar: String) -> void:
	for anak in _tab_wadah.get_children():
		anak.queue_free()
	_tab_wadah.add_child(GayaMisi.buat_tab_judul(nama))
	_subjudul.text = subjudul
	_avatar.atur_tipe(avatar)


## Sembunyikan tanpa sinyal.
func tutup() -> void:
	visible = false


func _tampilkan_babak(nomor: int) -> void:
	_babak = nomor
	var data: Dictionary = DataDialogMisi.babak(nomor, _pembicara)
	_teks.text = String(data.get("teks", ""))
	_gulung.scroll_vertical = 0
	_footer_kiri.text = "Babak %d dari %d" % [nomor, DataDialogMisi.JUMLAH_BABAK]
	_atur_dot_progres(nomor)

	for anak in _pilihan_box.get_children():
		anak.queue_free()

	var pilihan: Array = data.get("pilihan", [])
	for i in range(pilihan.size()):
		var p: Dictionary = pilihan[i]
		var tombol: Button
		if i == 0:
			tombol = GayaMisi.buat_tombol_emas(String(p.get("teks", "")))
			GayaMisi.tambah_panah_kanan(tombol)
		else:
			tombol = GayaMisi.buat_tombol_outline(String(p.get("teks", "")))
		tombol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tombol.pressed.connect(_on_pilihan_ditekan.bind(int(p.get("ke", -1))))
		_pilihan_box.add_child(tombol)


## v2: isi ulang titik progres footer (titik ke-nomor emas terisi).
func _atur_dot_progres(nomor: int) -> void:
	if _footer_dot == null:
		return
	_footer_dot.visible = true
	for anak in _footer_dot.get_children():
		_footer_dot.remove_child(anak)
		anak.queue_free()
	for i in range(DataDialogMisi.JUMLAH_BABAK):
		_footer_dot.add_child(GayaMisi.buat_dot(i + 1 == nomor))


## v2: animasi masuk — mengembang lembut (scale 0.96->1.0 + fade,
## 180 ms ease-out), bukan pop.
func _animasi_masuk() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	pivot_offset = size * 0.5
	scale = Vector2(0.96, 0.96)
	modulate.a = 0.0
	_anim_tween = create_tween()
	_anim_tween.set_parallel(true)
	_anim_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_anim_tween.tween_property(self, "scale", Vector2.ONE, 0.18)
	_anim_tween.tween_property(self, "modulate:a", 1.0, 0.18)


func _on_pilihan_ditekan(ke: int) -> void:
	if ke >= 1:
		_tampilkan_babak(ke)
		return
	# ke == -1 (atau tak dikenal): percakapan tuntas.
	visible = false
	selesai.emit()


func _on_tanya_dipilih(id_pilihan: String) -> void:
	visible = false
	pilihan_tanya.emit(id_pilihan)


func _on_pesan_ditutup() -> void:
	visible = false
	ditutup.emit()


func _on_tutup_ditekan() -> void:
	visible = false
	ditutup.emit()
