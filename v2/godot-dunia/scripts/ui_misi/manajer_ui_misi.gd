class_name ManajerUIMisi
extends CanvasLayer
## Manajer 4 panel UI misi (Raka, 18 Nov 2026 — implementasi mockup
## UI misi DI-ACC Mas 18:58 WIB: dialog-aqsal-v2, ruang-belajar-v1,
## tes-kenaikan-v1, panel-misi-v1).
## Pemilik 4 panel + dim modal. Panel-panel dibuat di sini (bukan di
## ui.gd — wilayah Tara, HUD B rev1) supaya tidak ada tabrakan file.
## Dim disinkronkan lewat sinyal visibility_changed tiap panel — ada
## tombol "Tutup" yang memanggil tutup() TANPA sinyal (kartu selesai
## RuangBelajarUI), jadi dim TIDAK boleh hanya mengandalkan sinyal
## ditutup/selesai.
## Semua teks panel = TEKS DRAF (mockup) — isi final menunggu tashih
## Mas (§9 butir 17 / Modul 01). Branding: "Pesantren Universe".

## Sinyal ke main.gd (main yang menulis save — UI tidak menyentuh save).
signal dialog_selesai
signal ruang_belajar_langkah(jenis: String, poin: int)
signal ruang_belajar_selesai(poin_total: int)
## RUANG BELAJAR CHAT (Sinta, 19 Nov 2026 — §7+§8): penutupan
## eksplisit (× / "Tutup"), isi papan tulis di dunia, dan titik
## resume (rb_chat_pos + rb_chat_modul).
signal ruang_belajar_ditutup
signal ruang_belajar_papan(judul: String, baris: PackedStringArray)
signal ruang_belajar_kemajuan(pos_id: String, modul: int)
signal tes_selesai(lulus: bool, skor: int, bagian: String, mesin: MesinKuis)
## TEKA-TEKI (Raka, 18 Nov 2026): pemain memilih "Tanya tentang
## guru" di layar tanya — main menghitung teka-tekinya lalu membuka
## buka_teka_teki(). "Sapa saja" tidak meng-emit apa pun.
signal tanya_dipilih(npc_id: String)

const LEBAR_PANEL := 660.0
const TINGGI_PANEL := 1120.0
## Ruang Belajar minta LEBAR (Mas, 19 Nov 2026): panel belajar
## nyaris full screen di landscape biar enak dibaca — lebar desain
## 1480 (bukan 660), fraksi layar 0.96. Panel lain TIDAK berubah.
const LEBAR_RUANG_BELAJAR := 1480.0
const FRAKSI_RUANG_BELAJAR := 0.96
## RUANG BELAJAR CHAT (Sinta, 19 Nov 2026 — §7+§8): kotak dialog
## di BAWAH layar (bukan tengah) — tinggi desain 560, fraksi
## tinggi 0.66 (di 720p = 475 px, dunia tetap terlihat di atas).
const TINGGI_RUANG_BELAJAR_CHAT := 560.0
const FRAKSI_TINGGI_RUANG_BELAJAR_CHAT := 0.66
## Dialog isinya pendek (avatar + teks + 2 pilihan) — panel kompak
## supaya tidak 75% kosong seperti foto ui-misi v2 (Raka, 18 Nov
## 2026). Ruang Belajar/Tes/Panel Misi tetap 1120 (konten panjang
## + bertambah: soal, riwayat, hasil, daftar misi).
const TINGGI_DIALOG := 560.0

var _dim: ColorRect
var _dialog: DialogMisi
var _ruang_belajar: RuangBelajarUI
var _tes: TesKenaikanUI
var _panel_misi: PanelMisiUI
var _terbuka: PanelContainer = null
## RUANG BELAJAR CHAT (§7): chip "Auto" kecil di kiri atas
## layar — milik manajer (bukan panel) supaya posisinya tetap
## di pojok layar saat panel menempel bawah. Hanya tampil saat
## Ruang Belajar terbuka.
var _rb_auto_chip: Button
## TEKA-TEKI (Raka, 18 Nov 2026): id NPC layar tanya yang sedang
## terbuka — diteruskan ke main saat pemain memilih "Tanya".
var _npc_tanya_id := ""


func _ready() -> void:
	# RONDE 21b: masuk grup supaya animasi idle (player.gd / npc.gd)
	# bisa membaca ada_panel_terbuka() tanpa lewat main.gd — siwak
	# + menoleh ditekan saat panel misi terbuka.
	add_to_group("manajer_ui_misi")
	layer = 10
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.55)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.visible = false
	add_child(_dim)
	_dialog = DialogMisi.new()
	_ruang_belajar = RuangBelajarUI.new()
	_tes = TesKenaikanUI.new()
	_panel_misi = PanelMisiUI.new()
	for panel in [_dialog, _ruang_belajar, _tes, _panel_misi]:
		add_child(panel)
		panel.visibility_changed.connect(_on_panel_visibility_changed.bind(panel))
	_dialog.selesai.connect(_on_dialog_selesai)
	_dialog.pilihan_tanya.connect(_on_dialog_pilihan_tanya)
	_ruang_belajar.langkah_selesai.connect(_on_rb_langkah)
	_ruang_belajar.selesai.connect(_on_rb_selesai)
	_ruang_belajar.ditutup.connect(_on_rb_ditutup)
	_ruang_belajar.papan_berubah.connect(_on_rb_papan)
	_ruang_belajar.kemajuan_disimpan.connect(_on_rb_kemajuan)
	_ruang_belajar.auto_berubah.connect(func(_v: bool) -> void: _sinkron_chip_auto())
	_tes.tes_selesai.connect(_on_tes_selesai)
	# Chip Auto (Ruang Belajar chat §7) — anak manajer supaya
	# selalu di kiri atas layar, di atas dim.
	_rb_auto_chip = GayaMisi.buat_tombol_outline("Auto: ON")
	_rb_auto_chip.position = Vector2(16, 16)
	_rb_auto_chip.visible = false
	_rb_auto_chip.pressed.connect(_on_rb_auto_chip_ditekan)
	add_child(_rb_auto_chip)


## ---------- buka panel (satu saja dalam satu waktu) ----------

func buka_dialog(pembicara: String) -> void:
	_tampilkan(_dialog, TINGGI_DIALOG)
	_dialog.tampilkan(pembicara)


## TEKA-TEKI (Raka, 18 Nov 2026): buka layar tanya satu langkah
## (DialogMisi mode tanya — bukan babak 1-5). npc_id disimpan
## untuk diteruskan ke main bila pemain memilih "Tanya".
func buka_tanya(nama: String, subjudul: String, avatar: String, teks: String, label_tanya: String, npc_id: String) -> void:
	_npc_tanya_id = npc_id
	_tampilkan(_dialog, TINGGI_DIALOG)
	_dialog.tampilkan_tanya(nama, subjudul, avatar, teks, label_tanya)


## TEKA-TEKI (Raka, 18 Nov 2026): buka layar pesan satu langkah —
## teka-teki (atau pengulangan / jaga-jaga) + tombol "Tutup".
func buka_teka_teki(nama: String, subjudul: String, avatar: String, teks: String) -> void:
	_tampilkan(_dialog, TINGGI_DIALOG)
	_dialog.tampilkan_pesan(nama, subjudul, avatar, teks)


## RUANG BELAJAR CHAT (§7+§8): panel BAWAH + dim transparan
## (dunia tetap terlihat — ustadz duduk + papan tulis di dunia).
## save diteruskan untuk resume + mode baca ulang.
func buka_ruang_belajar(pengajar: String, save: Dictionary = {}) -> void:
	_tampilkan_bawah(_ruang_belajar, TINGGI_RUANG_BELAJAR_CHAT, LEBAR_RUANG_BELAJAR, FRAKSI_RUANG_BELAJAR, FRAKSI_TINGGI_RUANG_BELAJAR_CHAT)
	_ruang_belajar.tampilkan(pengajar, save)
	_sinkron_chip_auto()


func buka_tes(bagian: String) -> void:
	_tampilkan(_tes)
	_tes.tampilkan(bagian)


func buka_panel_misi(save: Dictionary) -> void:
	_tampilkan(_panel_misi)
	_panel_misi.tampilkan(save)


func tutup_semua() -> void:
	for panel in [_dialog, _ruang_belajar, _tes, _panel_misi]:
		panel.tutup()
	_terbuka = null
	_sinkron_dim()


func ada_panel_terbuka() -> bool:
	return _terbuka != null and _terbuka.visible


func panel_terbuka() -> String:
	if _dialog.visible:
		return "dialog"
	if _ruang_belajar.visible:
		return "ruang_belajar"
	if _tes.visible:
		return "tes"
	if _panel_misi.visible:
		return "panel_misi"
	return ""


## ---------- dalam ----------

func _tampilkan(panel: PanelContainer, tinggi_target: float = TINGGI_PANEL, lebar_desain: float = LEBAR_PANEL, fraksi: float = 0.92) -> void:
	for p in [_dialog, _ruang_belajar, _tes, _panel_misi]:
		if p != panel:
			p.tutup()
	_terbuka = panel
	_pusatkan(panel, tinggi_target, lebar_desain, fraksi)
	_dim.color = Color(0, 0, 0, 0.55)
	_dim.visible = true
	panel.visible = true


## RUANG BELAJAR CHAT (§7): panel menempel BAWAH layar + dim
## TRANSPARAN (alpha 0 — dunia tetap terlihat, tapi input dunia
## tetap tertahan karena dim MOUSE_FILTER_STOP). Tinggi dibatasi
## fraksi_tinggi supaya dunia di atas tetap terlihat.
func _tampilkan_bawah(panel: PanelContainer, tinggi_target: float, lebar_desain: float, fraksi_lebar: float, fraksi_tinggi: float) -> void:
	for p in [_dialog, _ruang_belajar, _tes, _panel_misi]:
		if p != panel:
			p.tutup()
	_terbuka = panel
	var vp := get_viewport().get_visible_rect().size
	var s := _skala_layar()
	var lebar := minf(vp.x * fraksi_lebar, maxf(lebar_desain, lebar_desain / s))
	var tinggi := minf(vp.y * fraksi_tinggi, maxf(tinggi_target, tinggi_target / s))
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -lebar / 2.0
	panel.offset_right = lebar / 2.0
	panel.offset_top = -tinggi
	panel.offset_bottom = 0.0
	_dim.color = Color(0, 0, 0, 0)
	_dim.visible = true
	panel.visible = true


func _pusatkan(panel: PanelContainer, tinggi_target: float = TINGGI_PANEL, lebar_desain: float = LEBAR_PANEL, fraksi: float = 0.92) -> void:
	var vp := get_viewport().get_visible_rect().size
	var s := _skala_layar()
	# Pola ui.gd _pusatkan_panel (Tara/Ronde 4): ukuran target FISIK
	# = ukuran desain — di layar portrait (skala kecil, mis. 0,56 di
	# Xvfb 720x1560) ukuran kanvas diperbesar supaya panel tetap
	# 660x1120 px fisik. Tanpa ini panel hanya ~51% lebar layar
	# (cacat foto ui-misi v1: panel 368 px fisik di layar 720).
	var lebar := minf(vp.x * fraksi, maxf(lebar_desain, lebar_desain / s))
	var tinggi := minf(vp.y * fraksi, maxf(tinggi_target, tinggi_target / s))
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -lebar / 2.0
	panel.offset_right = lebar / 2.0
	panel.offset_top = -tinggi / 2.0
	panel.offset_bottom = tinggi / 2.0


## Skala layar saat ini (stretch canvas_items, pola ui.gd): dipakai
## supaya panel overlay berukuran FISIK yang sama di semua layar.
func _skala_layar() -> float:
	var s := get_viewport().get_screen_transform().x.x
	if s <= 0.01 or is_nan(s):
		return 1.0
	return clampf(s, 0.2, 3.0)


func _sinkron_dim() -> void:
	_dim.visible = ada_panel_terbuka()
	_sinkron_chip_auto()


## Chip Auto hanya tampil saat Ruang Belajar terbuka; teksnya
## mengikuti saklar panel (default ON).
func _sinkron_chip_auto() -> void:
	if _rb_auto_chip == null or _ruang_belajar == null:
		return
	_rb_auto_chip.visible = _ruang_belajar.visible
	_rb_auto_chip.text = "Auto: ON" if _ruang_belajar.auto_aktif() else "Auto: OFF"


func _on_rb_auto_chip_ditekan() -> void:
	var baru := not _ruang_belajar.auto_aktif()
	_ruang_belajar.set_auto(baru)
	_sinkron_chip_auto()


func _on_panel_visibility_changed(panel: PanelContainer) -> void:
	if not panel.visible and panel == _terbuka:
		_terbuka = null
	_sinkron_dim()


func _on_dialog_selesai() -> void:
	dialog_selesai.emit()


func _on_dialog_pilihan_tanya(id_pilihan: String) -> void:
	# "sapa" = tutup saja, tanpa sinyal (panel sudah disembunyikan
	# DialogMisi). "tanya" = main menghitung teka-teki + mencatat.
	if id_pilihan == "tanya":
		tanya_dipilih.emit(_npc_tanya_id)


func _on_rb_langkah(jenis: String, poin: int) -> void:
	ruang_belajar_langkah.emit(jenis, poin)


func _on_rb_selesai(poin_total: int) -> void:
	ruang_belajar_selesai.emit(poin_total)


func _on_rb_ditutup() -> void:
	ruang_belajar_ditutup.emit()


func _on_rb_papan(judul: String, baris: PackedStringArray) -> void:
	ruang_belajar_papan.emit(judul, baris)


func _on_rb_kemajuan(pos_id: String, modul: int) -> void:
	ruang_belajar_kemajuan.emit(pos_id, modul)


func _on_tes_selesai(lulus: bool, skor: int, bagian: String, mesin: MesinKuis) -> void:
	tes_selesai.emit(lulus, skor, bagian, mesin)
