extends CanvasLayer
class_name PesantrenUI
## Semua UI Pesantren Universe, dibangun dari kode.
## Bahasa: "pesantren" (bukan "dunia") di semua label — keputusan Mas 15 Nov ~09:09 WIB.
## Layar: login -> HUD pesantren (joystick + tombol aksi + chat) ->
## panel misi / dashboard Kartu Santri.

## Login server (integrasi login-gender, 17 Nov 2026): masuk dengan
## username Instagram (+ kata sandi bila sudah diset) — server
## mengembalikan ID Santri + nama + jenis_kelamin + token sesi.
signal login_submitted(ig_username: String, password: String)
signal register_submitted(ig_username: String, nama: String, jenis_kelamin: String)
signal continue_pressed
signal interact_pressed
signal chat_sent(teks: String)
signal quiz_answered(index: int)
signal mission_closed
signal mahadiyah_toggled(key: String, checked: bool)
signal khataman_joined
signal open_dashboard_requested
signal open_peta_requested
signal slide_changed(index: int)
signal reset_requested
# RONDE 6: aksi karakter (duduk/salaman/menulis/bawa kitab/melambai/
# tidur/berdiri) + ganti outfit (koko/songkok/sarung) di kamar cangkruk.
# RONDE 7: ganti baju juga bisa dari dashboard Kartu Santri.
signal aksi_dipilih(nama: String)
signal ganti_baju_requested()
signal outfit_dipilih(jenis: String, warna_hex: String)
# RONDE 13: sholat berjamaah — pemain menekan "Ikut Sholat" di banner.
signal ikut_sholat_pressed
# RONDE 17: audio suasana — tombol "Suara"/"Senyap" di HUD (mute).
signal suara_toggled
# KUALITAS ADAPTIF (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB):
# pilihan kualitas di Pengaturan — "otomatis"/"ringan"/"sedang"/"tinggi".
signal kualitas_dipilih(mode: String)
# MODE KAMERA v3 (Cakra, 18 Nov 13:13): tombol "Kamera: ..." di HUD.
signal kamera_mode_pressed
# MULTIPLAYER FASE 1 (Dimas, 18 Nov 2026 — perbaikan "Belum bisa main
# multiplayer"): tombol "Main Bersama" di HUD — pemain harus punya
# jalan masuk yang terlihat, bukan hanya label status "Offline".
signal mp_gabung_ditekan
# ROMBAKAN HUD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB):
# pop-up "PETUNJUK TOMBOL" ditutup pemain baru.
signal petunjuk_ditutup

# ROMBAKAN HUD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB,
# mockup hud-v3-desain-gamepad-v3.png): 4 tombol gamepad diamond
# (△ atas, □ kiri, ○ kanan, ✕ bawah), disc putih translusen tanpa
# outline, icon bentuk outline tipis putih, TANPA teks di tombol.
# PEMETAAN bentuk -> aksi adalah CONTOH yang di-ACC — TABEL ini
# satu-satunya tempat pemetaan ditulis, supaya nanti bisa diubah
# per scene/misi tanpa menulis ulang tombol (sistem kontekstual
# penuh BELUM dibangun; pasang pemetaan contoh ini saja).
const PEMETAAN_TOMBOL_GAMEPAD: Dictionary = {
	"x": "interact",
	"segitiga": "aksi",
	"kotak": "chat",
	"lingkaran": "reset",
}
# Baris pop-up "PETUNJUK TOMBOL": [bentuk, fungsi] — urutan tampil.
const PETUNJUK_BARIS: Array = [
	["segitiga", "Aksi"],
	["kotak", "Chat"],
	["lingkaran", "Reset"],
	["x", "Mulai Misi"],
]
# Keterangan tiap baris pop-up (Konsep UI v2, 19 Nov 2026).
const PETUNJUK_KETERANGAN := {
	"Aksi": "Berinteraksi dengan NPC & objek",
	"Chat": "Ngobrol dengan santri lain",
	"Reset": "Kembali ke posisi awal",
	"Mulai Misi": "Lanjut ke langkah misi berikutnya",
}
const UKURAN_TOMBOL_GAMEPAD := Vector2(100, 100)

const HIJAU := Color("#065f46")
const HIJAU_TERANG := Color("#0e7a5f")
const EMAS := Color("#d4a017")
const KREM := Color("#f5f0e6")
const GELAP := Color("#1d2b26")

## URL video YouTube untuk smartboard — sumber tunggal:
## MissionData.SMARTBOARD_VIDEO_URL (mission_data.gd). Alias di sini
## supaya pemanggil (Dewa / main.gd) cukup membaca PesantrenUI.
## Kosong = tombol "Tonton Video" nonaktif ("Belum ada video").
const SMARTBOARD_VIDEO_URL := MissionData.SMARTBOARD_VIDEO_URL

var _login_panel: Control
var _login_card: PanelContainer
var _login_stack: VBoxContainer
var _login_box: VBoxContainer
var _login_title: Label
var _login_sub: Label
var _ig_input: LineEdit
var _sandi_input: LineEdit
var _masuk_btn: Button
var _login_error: Label
var _login_note: Label
var _continue_btn: Button
var _daftar_link: Button
var _register_box: VBoxContainer
var _reg_title: Label
var _reg_sub: Label
var _reg_nama_input: LineEdit
var _reg_ig_input: LineEdit
# REGISTRASI-GENDER (Tara, 17 Nov 2026): pemilih gender di form daftar
# — dua tombol besar (PUTRA / PUTRI), default "putra". Nilai dibaca
# _on_daftar_pressed dan dikirim ke server bersama nama + akun IG.
var _reg_gender: String = "putra"
var _reg_gender_label: Label
var _reg_putra_btn: Button
var _reg_putri_btn: Button
var _reg_daftar_btn: Button
var _kembali_btn: Button
var _reg_error: Label
var _reg_note: Label

var _hud: Control
var _joystick: SantriJoystick
var _interact_btn: Button
var _reset_btn: Button
# ROMBAKAN HUD v3: 4 tombol gamepad (bentuk -> Button) + pop-up
# petunjuk (dim + panel). _chat_btn = tombol □ (Chat, sejak varian
# B rev1 — dulu Kamera), _interact_btn = tombol ✕, _reset_btn =
# tombol ○ — member lama dipakai main.gd + tes, jadi dipertahankan;
# isinya kini tombol gamepad (label di dalam tombol + label mode
# singkat DIHAPUS v3 — mockup: tanpa teks). Kamera PINDAH ke strip
# atas (lihat _kamera_ikon_btn di bawah).
var _tombol_gamepad: Dictionary = {}
var _petunjuk_dim: ColorRect
var _petunjuk_panel: PanelContainer
var _petunjuk_mengerti_btn: Button
var _petunjuk_tutup_btn: Button
var _tween_petunjuk: Tween = null
# RONDE 17: tombol "Suara"/"Senyap" di HUD (mute audio suasana).
var _suara_btn: Button
# VARIAN B rev1 (Tara, 18 Nov 2026 — DI-ACC Mas 18:43 WIB):
# tombol □ kini Chat; KAMERA PINDAH KE STRIP ATAS (icon kamera,
# slot ke-3 dari 5, menggantikan icon amplop Chat). .text tetap
# "Kamera: <Mode>" (dibaca test_kamera.gd); font transparan.
var _chat_btn: Button
var _kamera_ikon_btn: Button
# FULLSCREEN (Cakra, 17 Nov 2026 — ACC Mas ~20:52 WIB): tombol toggle
# "Layar Penuh" / "Keluar Layar" di HUD + jejak permintaan terakhir
# (_layar_penuh_diminta, dipakai tes headless sebagai bukti permintaan
# terkirim vs. sudah fullscreen).
var _layar_penuh_btn: Button
var _layar_penuh_diminta := false
var _sinkron_layar_penuh_timer := 0.0
# KUALITAS ADAPTIF (Rangga, 19 Nov 2026): tombol strip atas ke-6 +
# panel pilihan kualitas (Otomatis/Ringan/Sedang/Tinggi).
var _kualitas_btn: Button
var _kualitas_panel: PanelContainer
var _kualitas_tombol: Dictionary = {}
var _poin_label: Label
var _misi_label: Label
# MULTIPLAYER FASE 1 (Wira, 18 Nov 2026 — langkah 10 prep §1.6, MINIMAL,
# tanpa chat): indikator status koneksi saja. Daftar nama pemain online
# DIHAPUS 19 Nov 2026 (keputusan Mas 12:32 WIB — "ga perlu").
# Feed chat MLBB TIDAK disentuh (itu Fase 2).
var _mp_status_label: Label
# MULTIPLAYER FASE 1 (Dimas, 18 Nov 2026): tombol "Main Bersama" di
# HUD (di bawah label status) — jalan masuk multiplayer yang terlihat.
var _mp_gabung_btn: Button
var _minimap: MinimapControl
var _chat_panel: PanelContainer
var _chat_list: VBoxContainer
var _chat_input: LineEdit
var _chat_lines: Array[Label] = []

var _mission_panel: PanelContainer
var _mission_title: Label
var _materi_box: VBoxContainer
var _materi_judul: Label
var _materi_body: Label
var _kuis_box: VBoxContainer
var _kuis_q: Label
var _kuis_opts: Array[Button] = []
var _kuis_feedback: Label
var _kuis_tutup_btn: Button
var _kuis_materi_btn: Button
var _misi_x_btn: Button
var _current_misi: Dictionary = {}

var _peta_panel: PanelContainer
var _peta_map: PetaControl
var _peta_data: Dictionary = {}
var _peta_zoom_idx: int = 0
# RONDE 8 (retest: zoom hanya 1 tingkat — tombol + ke-2 mati): 3 tingkat
# 1.0x -> 2.0x -> 4.0x. 2.0x dulu dihapus ronde 5 karena label menumpuk;
# de-collision ronde 7 kini menanganinya (diuji di test_ronde8.gd).
const PETA_ZOOM: Array[float] = [1.0, 2.0, 4.0]
var _zoom_in_btn: Button
var _zoom_out_btn: Button
var _zoom_label: Label

var _smartboard_panel: PanelContainer
var _slide_judul: Label
var _slide_isi: Label
var _slide_nomor: Label
var _slide_prev_btn: Button
var _slide_next_btn: Button
var _video_btn: Button
var _slide_idx: int = 0
# BACA BUKU (Tara, 17 Nov 2026 — Mas: "Segera selesain ya"): pembaca
# kitab di dalam game, patokan artifact pratinjau-pembaca-kitab
# (daftar bab -> halaman baca Arab besar, zamrud/pasir/emas).
# ATURAN (Mas, 23:49 WIB): hanya buku dicek_ustadz:true yang tampil
# (filter di BukuData) — Jurumiyah + antrean sudah OK, jadi lolos
# filter server begitu ada di server. Tanpa lencana status.
var _baca_panel: PanelContainer
var _baca_judul: Label
var _baca_status: Label
var _baca_daftar_view: ScrollContainer
var _baca_daftar_box: VBoxContainer
var _baca_bab_view: ScrollContainer
var _baca_bab_box: VBoxContainer
var _baca_baca_view: VBoxContainer
var _baca_kicker: Label
var _baca_judul_baca: Label
var _baca_teks_wrap: Control
var _baca_isi_scroll: ScrollContainer
var _baca_isi_teks: Label
var _baca_tap_kiri: Button
var _baca_tap_kanan: Button
var _baca_gambar_scroll: ScrollContainer
var _baca_gambar: TextureRect
var _baca_keterangan: Label
var _baca_zoom_kecil: Button
var _baca_zoom_besar: Button
var _baca_zoom_row: HBoxContainer
var _baca_nomor: Label
var _baca_prev_btn: Button
var _baca_next_btn: Button
var _baca_zoom_label: Label
var _baca_daftar: Array[Dictionary] = []
var _baca_lokal: Array[Dictionary] = []
var _baca_server: Array[Dictionary] = []
var _baca_buku: Dictionary = {}
var _baca_idx: int = 0
var _baca_http: HTTPRequest = null
var _baca_kitab_http: HTTPRequest = null
var _baca_server_status: String = "" # "" | "memuat" | "ok" | "gagal"
var _baca_zoom: float = 1.0
const BACA_ZOOM_MAKS := 2.5
# Timeout fetch kitab 30 dtk (bukan 10): HTTPRequest Godot dipacu
# iterasi main-loop — di render software / HP kentang satu frame
# bisa >1 dtk, jadi handshake TLS butuh banyak iterasi; 10 dtk
# sempat gagal 2x di run foto (server-nya sehat, curl 1,4–2,1 dtk).
const BACA_HTTP_TIMEOUT := 30.0

var _dashboard_panel: PanelContainer
var _dash_content: VBoxContainer
var _dash_scroll: ScrollContainer
var _dash_title: Label
var _streak_label: Label
var _khataman_btn: Button

var _toast: Label
var _toast_timer: float = 0.0
# BUBBLE-ML (Gita, 17 Nov 2026 — koreksi Mas ~21:30 WIB: bubble kotak
# di atas kepala jelek): feed teks melayang ala Mobile Legends — pesan
# chat tampil sebagai TEKS KECIL di sebelah analog (kiri bawah, di atas
# joystick), TANPA kotak/border, latar transparan. Maks 3 baris, tiap
# baris hidup 4 dtk lalu fade + hilang sendiri. Pesan baru masuk di
# BAWAH (paling MLBB: pesan terbaru di bawah, yang lama naik) — baris
# lama naik, lebih dari 3 baris = yang paling lama dibuang.
var _feed_chat: VBoxContainer
var _feed_baris: Array[Dictionary] = [] # {"row": HBoxContainer, "sisa": float}
const FEED_CHAT_MAKS := 3
const FEED_CHAT_DURASI := 4.0
const FEED_CHAT_FADE := 1.0
var _rotate_overlay: Control
var _rotate_dismissed: bool = false
# RONDE 13: banner sholat berjamaah (muncul saat waktu sholat tiba).
var _sholat_banner: PanelContainer
var _sholat_label: Label
# PETUNJUK MISI SANTRI BARU (Raka, 18 Nov 2026 — perintah Mas 21:32 WIB).
var _petunjuk_misi_banner: PanelContainer
var _petunjuk_misi_label: Label
var _petunjuk_misi_arah: Label
var _petunjuk_misi_teks := ""
var _tween_banner: Tween = null
# RONDE 18 — overlay blackout adegan sholat sinematik (layar menghitam
# di antara takbir dan selesai). Selalu paling atas (dibangun terakhir).
var _blackout_overlay: Control
var _blackout_label: Label
# RONDE 6: panel aksi karakter + panel ganti outfit (kamar cangkruk).
var _aksi_panel: PanelContainer
var _outfit_panel: PanelContainer
var _outfit_buttons: Dictionary = {} # "koko:#faf7f0" -> Button
# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): wadah tiap
# baris panel ("koko" -> VBoxContainer) supaya open_outfit bisa
# menyembunyikan baris santriwan untuk santriwati dan sebaliknya.
var _outfit_baris: Dictionary = {}


# STEMPEL BUILD (Tara, 19 Nov 2026 — T1 Mas: tombol mati di HP,
# perlu cara memastikan build mana yang sedang jalan di HP-nya):
# VERSI SUMBER, format YYYYMMDD-N (tanggal staging + urutan hari itu).
# JANGAN pakai ID deployment Cloudflare (mis. "716a5831") — ID itu
# baru ada SETELAH deploy, jadi stempel di dalam build selalu menunjuk
# deployment SEBELUMNYA dan menyesatkan (insiden 19 Nov 2026: stempel
# "716a5831" ikut deploy 716a5831 padahal ditulis sebelum deploy itu).
# ATURAN: Eka menaikkan stempel ini tiap kali staging (N naik per
# staging di hari yang sama, reset ke 1 tiap tanggal baru), SEBELUM
# export — supaya stempel di HP Mas selalu = isi source yang di-stage.
const BUILD_STAMP := "20261119-3"
var _stempel_label: Label


func _ready() -> void:
	layer = 10
	_build_login()
	_build_hud()
	_build_mission_panel()
	_build_peta_panel()
	_build_smartboard_panel()
	_build_baca_buku_panel()
	_build_dashboard_panel()
	_build_aksi_panel()
	_build_outfit_panel()
	_build_toast()
	_build_petunjuk_misi_banner()
	_build_sholat_banner()
	_build_rotate_overlay()
	_build_blackout_overlay()
	_build_stempel_build()
	# RONDE 4: satu handler resize untuk SEMUA panel overlay — connect
	# per-panel ke _pusatkan_panel.bind(...) DITOLAK Godot ("already
	# connected": callable dengan method sama dianggap sama walau argumen
	# bind-nya beda), sehingga hanya panel pertama yang ter-layout ulang.
	get_viewport().size_changed.connect(_layout_semua_panel)
	# FULLSCREEN: label tombol ikut berubah kalau browser keluar
	# sendiri dari fullscreen (tombol kembali / ESC di HP) — resize
	# ikut fire saat mode berubah.
	get_viewport().size_changed.connect(_sinkron_tombol_layar_penuh)
	_hud.visible = false
	_mission_panel.visible = false
	_peta_panel.visible = false
	_smartboard_panel.visible = false
	_baca_panel.visible = false
	_dashboard_panel.visible = false
	_chat_panel.visible = false
	_aksi_panel.visible = false
	_outfit_panel.visible = false


# ---------- stempel build ----------
# Label kecil "Build <id deploy>" di bawah-tengah layar — terlihat di
# layar masuk MAUPUN di dalam game (anak root, bukan anak _hud, jadi
# tidak ikut sembunyi saat _hud disembunyikan). Dibangun TERAKHIR
# supaya di atas overlay putar HP / blackout (tetap terbaca saat
# overlay tampil). mouse_filter IGNORE: tidak boleh memblokir
# sentuhan ke joystick/gamepad di bawahnya. Tengah-bawah kosong
# (joystick kiri, gamepad kanan) — tidak menutupi tombol apa pun.
func _build_stempel_build() -> void:
	_stempel_label = _make_label("Build " + BUILD_STAMP, 13, Color(1, 1, 1, 0.55))
	_stempel_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_stempel_label.position = Vector2(-60, -28)
	_stempel_label.size = Vector2(120, 18)
	_stempel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stempel_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stempel_label)


## Teks stempel build (untuk tes + main.gd bila perlu).
func stempel_build_teks() -> String:
	return "Build " + BUILD_STAMP


# ---------- gaya ----------
func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(14)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


# Kartu form masuk/daftar: krem di atas latar zamrud, sudut membulat
# besar + bayangan halus (15 Nov ~12:00 WIB, form lama "kurang modern").
func _login_card_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color("#fbf8f1")
	s.border_color = EMAS
	s.set_border_width_all(2)
	s.set_corner_radius_all(20)
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 24
	s.content_margin_bottom = 24
	s.shadow_color = Color(0, 0, 0, 0.28)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 4)
	return s


func _btn_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(12)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	s.shadow_color = Color(0, 0, 0, 0.2)
	s.shadow_size = 3
	s.shadow_offset = Vector2(0, 2)
	return s


# Field modern: putih, sudut membulat, border abu-hijau; saat fokus
# border zamrud terang + latar hijau sangat muda.
func _field_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color.WHITE
	s.border_color = Color("#b9c4bb")
	s.set_border_width_all(2)
	s.set_corner_radius_all(12)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


func _field_style_focus() -> StyleBoxFlat:
	var s := _field_style()
	s.border_color = HIJAU_TERANG
	s.bg_color = Color("#f2fbf6")
	return s


func _gaya_field(f: Control) -> void:
	f.add_theme_stylebox_override("normal", _field_style())
	f.add_theme_stylebox_override("focus", _field_style_focus())
	f.add_theme_color_override("font_color", GELAP)
	f.add_theme_color_override("placeholder_color", Color("#7a8a80"))


func _gold_divider() -> Panel:
	var p := Panel.new()
	var s := StyleBoxFlat.new()
	s.bg_color = EMAS
	s.set_corner_radius_all(2)
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(120, 4)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return p


func _make_button(teks: String, bg: Color, font_color: Color = Color.WHITE) -> Button:
	var b := Button.new()
	b.text = teks
	b.add_theme_stylebox_override("normal", _btn_style(bg))
	b.add_theme_stylebox_override("hover", _btn_style(bg.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _btn_style(bg.darkened(0.15)))
	b.add_theme_stylebox_override("disabled", _btn_style(Color("#888888")))
	b.add_theme_color_override("font_color", font_color)
	b.add_theme_font_size_override("font_size", 20)
	# TARA 20 Nov 2026 (audit tombol — laporan Mas "ga bisa tekan X"):
	# SEMUA tombol _make_button menyala saat TEKAN, bukan saat lepas.
	# Pola yang sama sudah terbukti di file ini (Gita item 8 untuk
	# X/Tutup/zoom; Ronde 19 untuk swatch outfit): ketukan HP hampir
	# selalu bergeser sedikit, jadi tombol mode LEPAS terasa "mati"
	# padahal handler tersambung. _buat_tombol_ikon + _make_button_bulat
	# sudah BUTTON_PRESS sejak v3; ini menyeragamkan sisanya
	# (login, Main Bersama, petunjuk, chat, aksi, misi, smartboard,
	# baca buku, khataman, sholat, rotate). CheckButton Ma'hadiyah
	# SENGAJA tidak diubah (seret untuk scroll tidak boleh menandai).
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	# RONDE 4 (Tara): simpan ukuran dasar supaya _terapkan_skala_panel
	# bisa memperbesar font + tombol di layar berskala kecil (HP).
	b.set_meta("font_dasar", 20)
	return b


# DEBOUNCE TOGGLE (Tara, 19 Nov 2026 — perbaikan double-fire HP Mas):
# Sekali ketuk di HP bisa menghasilkan 2× `pressed` (sentuh + event
# mouse kompatibilitas browser) dalam <200 ms. Pada tombol TOGGLE itu
# berarti buka lalu tutup = tampak mati; pada kamera berarti lompat
# 2 mode. Guard ini mengabaikan `pressed` ke-2 pada tombol YANG SAMA
# bila datang <200 ms setelah `pressed` sebelumnya yang DITERIMA
# (timestamp hanya diperbarui saat diterima, supaya rentetan ketuk
# cepat yang disengaja tidak tertelan semua).
# Dipasang per-handler (bukan di factory): sinyal `pressed` tidak
# punya pembatalan — handler yang tersambung di factory tidak bisa
# menghentikan handler lain; factory-level sejati butuh subclass
# Button + override `_gui_input`, perubahan kelas seluruh UI di
# tengah gate. Guard per-handler dengan helper bersama ini
# menyembuhkan 100% gejala yang dilaporkan dengan diff minimal.
# Tombol momentary (✕, ○, MASUK, ...) SENGAJA tidak dipasang:
# double-fire di sana tidak berbahaya (aksi idempoten / sudah
# terbukti jalan di HP Mas).
const DEBOUNCE_TOGGLE_MS := 200
var _debounce_terakhir := {}


func _debounce_tekan(b: Button) -> bool:
	var kini := Time.get_ticks_msec()
	var lalu: int = int(_debounce_terakhir.get(b, -1000000))
	if kini - lalu < DEBOUNCE_TOGGLE_MS:
		return false
	_debounce_terakhir[b] = kini
	return true


func _make_label(teks: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = teks
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	# RONDE 4 (Tara): ukuran dasar untuk _terapkan_skala_panel.
	l.set_meta("font_dasar", size)
	return l


# ---------- tombol ikon + tombol bulat (ROMBAKAN HUD v3, Tara 18 Nov 2026) ----------
# ROMBAKAN v3 (DI-ACC Mas 17:39 WIB, mockup hud-v3-desain-gamepad-v3.png):
# wajah PUTIH translusen datar (bukan kaca gelap/glossy v2) + icon
# putih agak transparan TANPA bayangan gelap.
# Tombol ikon: Button 64x64 berisi IkonHUD di tengah. Teks tombol
# tetap bisa diisi pemanggil (logika lama yang membaca .text tidak
# berubah) tapi font dibuat transparan — yang terlihat hanya icon.
# 64x64 (DI-ACC Mas 21:18 WIB, 18 Nov 2026: perbesar tombol strip
# atas dari 48x48 supaya lebih gampang disentuh jari di HP).
func _buat_tombol_ikon(jenis: String, bg: Color) -> Button:
	var b := _make_button("", bg)
	b.custom_minimum_size = Vector2(64, 64)
	b.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	# clip_text: teks (tak terlihat) tidak boleh mengembangkan tombol
	# — tanpa ini "Layar Penuh"/"Suara" (diisi logika lama) membuat
	# tombol 84/149 px (temuan tes HUD rombak).
	b.clip_text = true
	# RONDE PERBAIKAN (Gita, item 8): tombol menyala saat TEKAN, bukan
	# saat lepas — di HP hampir semua ketukan bergeser sedikit.
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	# ROMBAKAN v3: wajah putih translusen datar + icon putih agak
	# transparan tanpa bayangan (bg pemanggil tidak lagi dipakai
	# untuk wajah — dipertahankan di signature supaya pemanggil lama
	# tidak berubah).
	var wajah := GayaTombol.bulat_putih(64, 64, 19, 0.5)
	GayaTombol.pasang_wajah(b, wajah)
	var ikon := IkonHUD.new()
	ikon.jenis = jenis
	ikon.warna = Color(1, 1, 1, 0.8)
	ikon.bayangan = false
	ikon.anchor_left = 0.5
	ikon.anchor_top = 0.5
	ikon.anchor_right = 0.5
	ikon.anchor_bottom = 0.5
	ikon.offset_left = -23
	ikon.offset_top = -23
	ikon.offset_right = 23
	ikon.offset_bottom = 23
	ikon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ikon)
	b.set_meta("ikon", ikon)
	return b


func _ikon_dari(b: Button) -> IkonHUD:
	if b == null or not b.has_meta("ikon"):
		return null
	return b.get_meta("ikon") as IkonHUD


# Tombol aksi BULAT v3 (DI-ACC Mas 17:39 WIB): disc PUTIH translusen
# datar (alpha 0.28), TANPA outline/ring/gradien/sorot/bayang.
# VARIAN B rev1 (DI-ACC Mas 18:43 WIB): disc KACA BURAM BERTINTA
# zamrud muda alpha 150 (putih polos TERBUKTI hilang di lantai
# marmer) — TANPA bayangan (varian B).
# .text tetap diisi pemanggil (font transparan) karena dibaca
# logika/tes lama ("Kamera: <Mode>", "MULAI MISI", ...).
func _make_button_bulat(ukuran: Vector2) -> Button:
	var b := _make_button("", Color(0, 0, 0, 0), Color.WHITE)
	b.custom_minimum_size = ukuran
	# clip_text: teks (tak terlihat, mis. "Reset Posisi"/"MULAI MISI")
	# tidak boleh mengembangkan tombol — tanpa ini tombol jadi
	# 139/142 px (temuan tes HUD rombak).
	b.clip_text = true
	var d := int(ukuran.x)
	var wajah := GayaTombol.disc_kaca(d)
	GayaTombol.pasang_wajah(b, wajah)
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	return b


# Anak icon di tengah tombol bulat (posisi absolut relatif tombol).
# ROMBAKAN v3: icon TANPA bayangan gelap (mockup: putih polos).
# VARIAN B rev1: garis sedikit lebih tebal (tebal_tipis 4.0; X
# otomatis 5.0 lewat IkonHUD) + icon ZAMRUD GELAP di atas kaca
# bertinta (warna dilewatkan pemanggil).
func _tambah_ikon_tombol(b: Button, jenis: String, warna: Color, pos: Vector2, ukuran: float) -> IkonHUD:
	var ikon := IkonHUD.new()
	ikon.jenis = jenis
	ikon.warna = warna
	ikon.bayangan = false
	ikon.tebal_tipis = 4.0
	ikon.position = pos
	ikon.size = Vector2(ukuran, ukuran)
	ikon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ikon)
	return ikon


# ---------- login + daftar ----------
# Dua kotak dalam satu panel: kotak MASUK (username IG + kata sandi,
# login server) dan kotak DAFTAR (santri baru: nama + akun IG +
# gender, ID diterbitkan server). Hanya satu yang terlihat.
# Ukuran semua field dihitung _layout_login() dari skala layar supaya
# form tidak kekecilan di HP portrait (masalah 15 Nov ~11:26 WIB).
func _build_login() -> void:
	_login_panel = Control.new()
	_login_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_login_panel)
	var bg := ColorRect.new()
	bg.color = HIJAU
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_login_panel.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_login_panel.add_child(center)
	# Kartu krem bersudut membulat di atas latar zamrud (15 Nov ~12:00 WIB,
	# form lama "kurang modern": dulu teks putih langsung di atas hijau).
	_login_card = PanelContainer.new()
	_login_card.add_theme_stylebox_override("panel", _login_card_style())
	center.add_child(_login_card)
	_login_stack = VBoxContainer.new()
	_login_stack.add_theme_constant_override("separation", 0)
	_login_card.add_child(_login_stack)
	# --- kotak MASUK ---
	_login_box = VBoxContainer.new()
	_login_box.add_theme_constant_override("separation", 12)
	_login_stack.add_child(_login_box)
	_login_title = _make_label("PESANTREN UNIVERSE", 44, HIJAU)
	_login_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_login_box.add_child(_login_title)
	_login_box.add_child(_gold_divider())
	_login_sub = _make_label("Merangkak dari surau kecil — dari nol, bersama santri.", 20, Color("#4a6b5c"))
	_login_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_login_box.add_child(_login_sub)
	_ig_input = LineEdit.new()
	# RONDE PERBAIKAN (Gita, item 12): placeholder HARUS muat di field
	# pada semua skala — "Username Instagram (tanpa @)" 29 huruf
	# terpotong di HP (425 px vs 315 tersedia di landscape, 750 vs 315
	# di portrait); "Username IG" pun masih 329 vs 315 di portrait.
	# "Akun IG" muat di mana-mana; keterangan lengkapnya sudah ada di
	# catatan bawah ("username Instagram yang dipakai saat daftar").
	_ig_input.placeholder_text = "Akun IG"
	_ig_input.max_length = 30
	_ig_input.custom_minimum_size = Vector2(360, 44)
	_ig_input.add_theme_font_size_override("font_size", 20)
	_gaya_field(_ig_input)
	_ig_input.focus_entered.connect(_minta_keyboard)
	_ig_input.gui_input.connect(_on_field_gui_input.bind(_ig_input))
	_login_box.add_child(_ig_input)
	_sandi_input = LineEdit.new()
	# RONDE PERBAIKAN (Gita, item 12): placeholder lama 50 huruf
	# ("Kata sandi (opsional — kosongkan bila belum diset)", 431 px)
	# terpotong di SEMUA skala — desktop 332 px tersedia, HP landscape
	# 315, portrait 315. "Kata sandi" muat di mana-mana (terukur di tes:
	# 86/147/259 px); "(opsional...)" sudah dijelaskan catatan bawah.
	_sandi_input.placeholder_text = "Kata sandi"
	_sandi_input.max_length = 64
	_sandi_input.secret = true
	_sandi_input.custom_minimum_size = Vector2(360, 44)
	_sandi_input.add_theme_font_size_override("font_size", 20)
	_gaya_field(_sandi_input)
	_sandi_input.focus_entered.connect(_minta_keyboard)
	_sandi_input.gui_input.connect(_on_field_gui_input.bind(_sandi_input))
	_login_box.add_child(_sandi_input)
	# Login server (17 Nov 2026): masuk pakai username IG + kata
	# sandi opsional. ID + nama diambil dari server, bukan diisi manual.
	_masuk_btn = _make_button("MASUK PESANTREN", EMAS, GELAP)
	_masuk_btn.custom_minimum_size = Vector2(360, 52)
	_masuk_btn.pressed.connect(_on_masuk_pressed)
	_login_box.add_child(_masuk_btn)
	_continue_btn = _make_button("Lanjutkan sesi sebelumnya", HIJAU_TERANG)
	_continue_btn.custom_minimum_size = Vector2(360, 48)
	_continue_btn.visible = false
	_continue_btn.pressed.connect(_on_continue_pressed)
	_login_box.add_child(_continue_btn)
	_daftar_link = _make_button("Belum terdaftar? Daftar baru", HIJAU_TERANG)
	_daftar_link.custom_minimum_size = Vector2(360, 48)
	_daftar_link.pressed.connect(_tampil_daftar)
	_login_box.add_child(_daftar_link)
	_login_error = _make_label("", 18, Color("#a33b3b"))
	_login_error.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_login_box.add_child(_login_error)
	_login_note = _make_label("Masuk dengan username Instagram yang dipakai saat daftar. Kata sandi hanya perlu diisi bila sudah diset.", 16, Color("#5a6b60"))
	_login_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_login_note.custom_minimum_size = Vector2(380, 0)
	_login_box.add_child(_login_note)
	# --- kotak DAFTAR (santri baru) ---
	_register_box = VBoxContainer.new()
	_register_box.add_theme_constant_override("separation", 12)
	_register_box.visible = false
	_login_stack.add_child(_register_box)
	_reg_title = _make_label("DAFTAR SANTRI BARU", 44, HIJAU)
	_reg_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reg_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_box.add_child(_reg_title)
	_register_box.add_child(_gold_divider())
	_reg_sub = _make_label("Isi nama, akun IG, dan pilih gender — ID Santri diterbitkan server.", 20, Color("#4a6b5c"))
	_reg_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reg_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_box.add_child(_reg_sub)
	_reg_nama_input = LineEdit.new()
	# RONDE PERBAIKAN (Gita, item 12): sama seperti placeholder login —
	# "Nama santri (maks 30 huruf)" terpotong di HP (410/724 px vs 315
	# tersedia). Batas 30 huruf sudah dijaga max_length.
	_reg_nama_input.placeholder_text = "Nama santri"
	_reg_nama_input.max_length = 30
	_reg_nama_input.custom_minimum_size = Vector2(360, 44)
	_reg_nama_input.add_theme_font_size_override("font_size", 20)
	_gaya_field(_reg_nama_input)
	_reg_nama_input.focus_entered.connect(_minta_keyboard)
	_reg_nama_input.gui_input.connect(_on_field_gui_input.bind(_reg_nama_input))
	_register_box.add_child(_reg_nama_input)
	# REGISTRASI-GENDER (Tara, 17 Nov 2026): akun IG wajib — dipakai
	# login nanti + harus unik di server (satu akun IG = satu santri).
	_reg_ig_input = LineEdit.new()
	_reg_ig_input.placeholder_text = "Akun IG"
	_reg_ig_input.max_length = 30
	_reg_ig_input.custom_minimum_size = Vector2(360, 44)
	_reg_ig_input.add_theme_font_size_override("font_size", 20)
	_gaya_field(_reg_ig_input)
	_reg_ig_input.focus_entered.connect(_minta_keyboard)
	_reg_ig_input.gui_input.connect(_on_field_gui_input.bind(_reg_ig_input))
	_register_box.add_child(_reg_ig_input)
	# Pemilih gender: label + dua tombol besar berdampingan (gampang
	# ditekan di HP). Yang terpilih beraksen emas + ikon centang.
	_reg_gender_label = _make_label("Saya daftar sebagai:", 20, Color("#4a6b5c"))
	_reg_gender_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reg_gender_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_box.add_child(_reg_gender_label)
	var gender_row := HBoxContainer.new()
	gender_row.add_theme_constant_override("separation", 12)
	_register_box.add_child(gender_row)
	_reg_putra_btn = _make_button("Santri (Putra)", HIJAU_TERANG)
	_reg_putra_btn.custom_minimum_size = Vector2(0, 52)
	_reg_putra_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reg_putra_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_reg_putra_btn.pressed.connect(_on_gender_dipilih.bind("putra"))
	gender_row.add_child(_reg_putra_btn)
	_reg_putri_btn = _make_button("Santriwati (Putri)", HIJAU_TERANG)
	_reg_putri_btn.custom_minimum_size = Vector2(0, 52)
	_reg_putri_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reg_putri_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_reg_putri_btn.pressed.connect(_on_gender_dipilih.bind("putri"))
	gender_row.add_child(_reg_putri_btn)
	_perbarui_tombol_gender()
	# RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): pilihan jalur
	# DIHAPUS dari daftar. Daftar kini nama + akun IG + gender;
	# ID diterbitkan server (POST /api/santri/register).
	_reg_daftar_btn = _make_button("DAFTAR & MASUK PESANTREN", EMAS, GELAP)
	_reg_daftar_btn.custom_minimum_size = Vector2(360, 52)
	_reg_daftar_btn.pressed.connect(_on_daftar_pressed)
	_register_box.add_child(_reg_daftar_btn)
	_kembali_btn = _make_button("Sudah punya ID? Masuk di sini", HIJAU_TERANG)
	_kembali_btn.custom_minimum_size = Vector2(360, 48)
	_kembali_btn.pressed.connect(_tampil_masuk)
	_register_box.add_child(_kembali_btn)
	_reg_error = _make_label("", 18, Color("#a33b3b"))
	_reg_error.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reg_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_box.add_child(_reg_error)
	_reg_note = _make_label("ID Santri (PV-XXXX) diterbitkan server dan disimpan di perangkat ini. Satu akun IG hanya untuk satu santri — username yang sudah dipakai tidak bisa dipakai lagi.", 16, Color("#5a6b60"))
	_reg_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reg_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reg_note.custom_minimum_size = Vector2(380, 0)
	_register_box.add_child(_reg_note)
	# Ukuran form menyesuaikan layar (dipanggil lagi tiap resize).
	get_viewport().size_changed.connect(_layout_login)
	_layout_login()


## Minta keyboard virtual secara eksplisit saat sebuah field dapat fokus.
## Di web mobile, fokus LineEdit saja tidak cukup: tanpa
## html/experimental_virtual_keyboard=true di export preset, keyboard
## tidak pernah muncul (masalah 15 Nov ~11:26 WIB). focus_entered
## berjalan sinkron di dalam gesture ketuk, jadi panggilan ini sah.
func _minta_keyboard() -> void:
	DisplayServer.virtual_keyboard_show("")


## Ketuk sentuh HARUS memberi fokus ke LineEdit (19 Nov 2026 — laporan Mas
## 15:58/16:01 WIB: keyboard HP tidak muncul saat kolom login diketuk).
## Sejak emulate_mouse_from_touch=false, ketuk jari hanya menghasilkan
## InputEventScreenTouch tanpa event mouse, dan LineEdit Godot 4.7 tidak
## mengambil fokus dari sentuhan — focus_entered -> _minta_keyboard tidak
## pernah menyala. Handler ini dipasang di semua LineEdit (login, daftar,
## chat). JANGAN hidupkan lagi emulate_mouse_from_touch (itu mengembalikan
## bug double-fire toggle).
func _on_field_gui_input(ev: InputEvent, field: LineEdit) -> void:
	if ev is InputEventScreenTouch and (ev as InputEventScreenTouch).pressed:
		field.grab_focus()


## Hitung ukuran form dari skala stretch layar (fungsi murni, bisa dites).
## scale ~1.5 = desktop 1920x1080; ~0.30 = HP portrait 390 px;
## ~0.54 = HP landscape 844x390.
## Target fisik di layar: field 56 px, tombol 64 px, font field 20 px,
## judul 40 px, lebar form ~340 px. Nilai logis = max(ukuran desain,
## target_fisik / scale) supaya di desktop tidak mengecil.
## Mode kompak (15 Nov ~12:00 WIB): di layar pendek (HP landscape,
## tinggi logis ~722) form penuh tidak muat — pakai target fisik lebih
## kecil dan sembunyikan sub-judul + catatan. "perkiraan_tinggi_form"
## dihitung supaya tes bisa memastikan form muat di layar.
static func login_metrics(scale: float, lebar_viewport: float, tinggi_viewport: float = 0.0) -> Dictionary:
	var s := scale
	if s <= 0.01 or is_nan(s):
		s = 1.0
	# Jepit skala ke rentang wajar: jendela super-kecil (mis. headless
	# 64x64, scale 0.05) tidak boleh menghasilkan font ribuan piksel.
	s = clampf(s, 0.2, 3.0)
	var lebar_form := minf(lebar_viewport * 0.88, maxf(360.0, 340.0 / s))
	var m := {
		"lebar_form": lebar_form,
		"judul": maxi(44, int(ceil(40.0 / s))),
		"sub": maxi(20, int(ceil(18.0 / s))),
		"font_field": maxi(20, int(ceil(20.0 / s))),
		"tinggi_field": maxi(44, int(ceil(56.0 / s))),
		"font_tombol": maxi(20, int(ceil(22.0 / s))),
		"tinggi_tombol": maxi(52, int(ceil(64.0 / s))),
		"font_note": maxi(16, int(ceil(16.0 / s))),
		"font_error": maxi(18, int(ceil(18.0 / s))),
		"separation": maxi(12, int(ceil(14.0 / s))),
		"compact": false,
		"perkiraan_tinggi_form": 0.0,
		"tampilkan_sub": true,
		"tampilkan_note": true,
	}
	# Perkiraan tinggi tumpukan login: judul + sub (2 baris) + 2 field
	# (username IG + kata sandi — login server, 17 Nov 2026) + tombol
	# masuk + tombol tautan + catatan (2 baris) + pemisah + padding
	# kartu + pembatas emas (60).
	var est := float(m["judul"]) * 1.3 + float(m["sub"]) * 2.0 + float(m["tinggi_field"]) * 2.0 + float(m["tinggi_tombol"]) * 2.0 + float(m["font_note"]) * 2.2 + float(m["separation"]) * 8.0 + 60.0
	# Kotak DAFTAR lebih tinggi (registrasi-gender, 17 Nov 2026): 2 field
	# (nama + akun IG) + label gender + baris pemilih gender + tombol
	# daftar + tombol kembali — pakai yang tertinggi dari keduanya
	# supaya mode kompak dihitung dari kotak yang paling tinggi.
	var est_daftar := float(m["judul"]) * 1.3 + float(m["sub"]) * 2.0 + float(m["tinggi_field"]) * 2.0 + float(m["sub"]) * 1.3 + float(m["tinggi_tombol"]) * 3.0 + float(m["font_note"]) * 2.2 + float(m["separation"]) * 10.0 + 60.0
	m["perkiraan_tinggi_form"] = maxf(est, est_daftar)
	if tinggi_viewport > 0.0 and est > tinggi_viewport * 0.94:
		# Mode kompak: target fisik lebih kecil, sub + catatan disembunyikan.
		m["judul"] = maxi(40, int(ceil(30.0 / s)))
		m["sub"] = maxi(18, int(ceil(16.0 / s)))
		m["font_field"] = maxi(20, int(ceil(18.0 / s)))
		m["tinggi_field"] = maxi(44, int(ceil(48.0 / s)))
		m["font_tombol"] = maxi(20, int(ceil(20.0 / s)))
		m["tinggi_tombol"] = maxi(52, int(ceil(56.0 / s)))
		m["font_note"] = maxi(16, int(ceil(14.0 / s)))
		m["separation"] = maxi(10, int(ceil(8.0 / s)))
		m["compact"] = true
		m["tampilkan_sub"] = false
		m["tampilkan_note"] = false
		var est_kompak := float(m["judul"]) * 1.3 + float(m["tinggi_field"]) * 2.0 + float(m["tinggi_tombol"]) * 2.0 + float(m["separation"]) * 6.0 + 60.0
		var est_daftar_kompak := float(m["judul"]) * 1.3 + float(m["tinggi_field"]) * 2.0 + float(m["sub"]) * 1.3 + float(m["tinggi_tombol"]) * 3.0 + float(m["separation"]) * 8.0 + 60.0
		m["perkiraan_tinggi_form"] = maxf(est_kompak, est_daftar_kompak)
	return m


func _layout_login() -> void:
	var vp := get_viewport().get_visible_rect().size
	var s := get_viewport().get_screen_transform().x.x
	_apply_login_metrics(login_metrics(s, vp.x, vp.y))
	_update_rotate_overlay()


func _apply_login_metrics(m: Dictionary) -> void:
	var w := float(m["lebar_form"])
	var sep := int(m["separation"])
	var tampil_sub := bool(m.get("tampilkan_sub", true))
	var tampil_note := bool(m.get("tampilkan_note", true))
	_login_sub.visible = tampil_sub
	_reg_sub.visible = tampil_sub
	_login_note.visible = tampil_note
	_reg_note.visible = tampil_note
	_login_box.custom_minimum_size = Vector2(w, 0)
	_register_box.custom_minimum_size = Vector2(w, 0)
	_login_box.add_theme_constant_override("separation", sep)
	_register_box.add_theme_constant_override("separation", sep)
	_login_title.add_theme_font_size_override("font_size", int(m["judul"]))
	_reg_title.add_theme_font_size_override("font_size", int(m["judul"]))
	_login_sub.add_theme_font_size_override("font_size", int(m["sub"]))
	_reg_sub.add_theme_font_size_override("font_size", int(m["sub"]))
	for field in [_ig_input, _sandi_input, _reg_nama_input, _reg_ig_input]:
		field.custom_minimum_size = Vector2(w, int(m["tinggi_field"]))
		field.add_theme_font_size_override("font_size", int(m["font_field"]))
	for btn in [_masuk_btn, _reg_daftar_btn]:
		btn.custom_minimum_size = Vector2(w, int(m["tinggi_tombol"]))
		btn.add_theme_font_size_override("font_size", int(m["font_tombol"]))
	# Pemilih gender: dua tombol berdampingan, masing-masing selebar
	# setengah form (dikurangi pemisah) + setinggi tombol utama.
	for gbtn in [_reg_putra_btn, _reg_putri_btn]:
		gbtn.custom_minimum_size = Vector2((w - 12) * 0.5, int(m["tinggi_tombol"]))
		gbtn.add_theme_font_size_override("font_size", int(m["font_tombol"]))
	_reg_gender_label.add_theme_font_size_override("font_size", int(m["sub"]))
	_continue_btn.custom_minimum_size = Vector2(w, maxi(48, int(m["tinggi_tombol"]) - 4))
	_continue_btn.add_theme_font_size_override("font_size", int(m["font_tombol"]))
	# RONDE PERBAIKAN (Raka, integrasi catatan Gita): tombol tautan
	# login/daftar ("Belum terdaftar? Daftar baru" / "Sudah punya ID?
	# Masuk di sini") tadinya berukuran TETAP (360x48, font 20) —
	# di portrait HP (form ~315 px) tombolnya tampak kecil/menciut
	# dibanding tombol utama. Kini ikut metrik form seperti tombol lain.
	for link in [_daftar_link, _kembali_btn]:
		link.custom_minimum_size = Vector2(w, maxi(48, int(m["tinggi_tombol"]) - 4))
		link.add_theme_font_size_override("font_size", int(m["font_tombol"]))
	_login_error.add_theme_font_size_override("font_size", int(m["font_error"]))
	_reg_error.add_theme_font_size_override("font_size", int(m["font_error"]))
	for note in [_login_note, _reg_note]:
		note.custom_minimum_size = Vector2(w, 0)
		note.add_theme_font_size_override("font_size", int(m["font_note"]))


func show_login(saved: Dictionary) -> void:
	_login_panel.visible = true
	_hud.visible = false
	_tampil_masuk()
	if String(saved.get("id_santri", "")) != "" and String(saved.get("nama", "")) != "":
		_continue_btn.visible = true
		_continue_btn.text = "Lanjutkan sebagai " + String(saved["nama"]) + " (" + String(saved["id_santri"]) + ")"
		_ig_input.text = String(saved.get("ig_username", ""))
	else:
		_continue_btn.visible = false


func _tampil_masuk() -> void:
	_login_box.visible = true
	_register_box.visible = false
	_login_error.text = ""


func _tampil_daftar() -> void:
	_login_box.visible = false
	_register_box.visible = true
	_reg_error.text = ""
	# grab_focus di dalam gesture tombol (sinkron) supaya keyboard HP
	# langsung terbuka bersama kotaknya.
	_reg_nama_input.grab_focus()


func _on_daftar_pressed() -> void:
	var nama := _reg_nama_input.text.strip_edges()
	if nama.length() < 2:
		_reg_error.text = "Isi nama santri dulu (minimal 2 huruf)."
		return
	var ig := SantriSave.normalisasi_ig(_reg_ig_input.text)
	if ig == "":
		_reg_error.text = "Isi username Instagram dulu."
		return
	if ig.contains(" "):
		_reg_error.text = "Username Instagram tidak boleh mengandung spasi."
		return
	if not RegistrasiServer.gender_valid(_reg_gender):
		_reg_error.text = "Pilih dulu: daftar sebagai Santri atau Santriwati."
		return
	_reg_error.text = ""
	# FULLSCREEN: tombol ini juga masuk ke game dari layar login —
	# perlakuannya sama seperti MASUK (lihat _on_masuk_pressed).
	_minta_layar_penuh()
	register_submitted.emit(ig, nama, _reg_gender)


## Gender yang dipilih di form daftar ("putra"/"putri").
func gender_daftar_terpilih() -> String:
	return _reg_gender


func _on_gender_dipilih(jk: String) -> void:
	_reg_gender = jk
	_perbarui_tombol_gender()


## Tanda centang pilihan-aktif sebagai IKON gambar-kode di kiri
## tombol (Tara, 19 Nov 2026): "✓ " di depan teks tombol tofu di
## web (Baloo 2 tidak punya U+2713). Ikon IkonHUD "centang"
## dibuat sekali per tombol (disimpan di meta "ikon_centang"),
## warnanya ikut font_color tombol, posisinya di tepi kiri
## (teks tombol tetap di tengah — tidak bertabrakan). Dipakai
## tombol gender daftar, panel kualitas, dan swatch outfit.
func _set_centang_tombol(b: Button, aktif: bool) -> void:
	if b == null:
		return
	# get_meta() MELEMPAR ERROR bila kunci belum ada — bahkan bentuk
	# dua argumen (default null) tetap error di Godot 4.7.2 (terbukti
	# probe /tmp/probe_meta.gd). Jadi: cek has_meta() dulu.
	var ikon: IkonHUD = null
	if b.has_meta("ikon_centang"):
		ikon = b.get_meta("ikon_centang") as IkonHUD
	if ikon == null:
		ikon = IkonHUD.new()
		ikon.jenis = "centang"
		ikon.warna = b.get_theme_color("font_color")
		ikon.bayangan = false
		ikon.anchor_top = 0.5
		ikon.anchor_bottom = 0.5
		ikon.offset_left = 12.0
		ikon.offset_top = -11.0
		ikon.offset_right = 34.0
		ikon.offset_bottom = 11.0
		ikon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(ikon)
		b.set_meta("ikon_centang", ikon)
	ikon.visible = aktif


## Yang terpilih: emas + ikon centang (jelas di HP); yang tidak:
## krem gelap.
func _perbarui_tombol_gender() -> void:
	_gaya_tombol_gender(_reg_putra_btn, _reg_gender == "putra", "Santri (Putra)")
	_gaya_tombol_gender(_reg_putri_btn, _reg_gender == "putri", "Santriwati (Putri)")


func _gaya_tombol_gender(b: Button, terpilih: bool, teks: String) -> void:
	if b == null:
		return
	var bg := EMAS if terpilih else Color("#e8e0d0")
	b.text = teks
	b.add_theme_stylebox_override("normal", _btn_style(bg))
	b.add_theme_stylebox_override("hover", _btn_style(bg.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _btn_style(bg.darkened(0.15)))
	b.add_theme_stylebox_override("disabled", _btn_style(Color("#888888")))
	b.add_theme_color_override("font_color", GELAP)
	_set_centang_tombol(b, terpilih)


## Dipanggil main.gd saat register server menjawab / gagal: tampilkan
## pesan yang jelas di bawah tombol DAFTAR (save tidak disentuh).
func show_register_error(pesan: String) -> void:
	_reg_error.text = pesan


## Keadaan "sedang mendaftar ke server": tombol + field + pemilih
## gender dikunci + teks berubah supaya tidak ada ketukan ganda.
func set_register_loading(busy: bool) -> void:
	_reg_daftar_btn.disabled = busy
	_reg_daftar_btn.text = "MENDAFTAR…" if busy else "DAFTAR & MASUK PESANTREN"
	_reg_nama_input.editable = not busy
	_reg_ig_input.editable = not busy
	_reg_putra_btn.disabled = busy
	_reg_putri_btn.disabled = busy


func _on_continue_pressed() -> void:
	# FULLSCREEN: "Lanjutkan sesi sebelumnya" juga masuk ke game dari
	# layar login — perlakuannya sama seperti MASUK.
	_minta_layar_penuh()
	continue_pressed.emit()


func _on_masuk_pressed() -> void:
	var ig := SantriSave.normalisasi_ig(_ig_input.text)
	var sandi := _sandi_input.text
	if ig == "":
		_login_error.text = "Isi username Instagram dulu."
		return
	if ig.contains(" "):
		_login_error.text = "Username Instagram tidak boleh mengandung spasi."
		return
	_login_error.text = ""
	# FULLSCREEN (ACC Mas 17 Nov ~20:52 WIB): browser melarang
	# fullscreen otomatis tanpa ketukan — tapi handler ini berjalan
	# sinkron di dalam gesture ketuk tombol MASUK, jadi permintaan di
	# sini diterima browser. Validasi di atas dulu: ketukan yang
	# gagal (username kosong / berspasi) TIDAK minta fullscreen.
	_minta_layar_penuh()
	login_submitted.emit(ig, sandi)


## Dipanggil main.gd saat login server menjawab / gagal: tampilkan
## pesan yang jelas di bawah tombol MASUK (save tidak disentuh).
func show_login_error(pesan: String) -> void:
	_login_error.text = pesan


## Keadaan "sedang menghubungi server": tombol dikunci + teks berubah
## supaya tidak ada ketukan ganda selama request berjalan.
func set_login_loading(busy: bool) -> void:
	_masuk_btn.disabled = busy
	_masuk_btn.text = "MENGHUBUNGKAN…" if busy else "MASUK PESANTREN"
	_ig_input.editable = not busy
	_sandi_input.editable = not busy


# ---------- layar penuh (fullscreen) ----------
# ACC Mas 17 Nov ~20:52 WIB: fullscreen diminta saat pemain mengetuk
# tombol masuk di layar login (MASUK / DAFTAR / Lanjutkan sesi).
# Batas Apple: iPhone/Safari TIDAK mendukung Fullscreen API
# (document.fullscreenEnabled == false) — itu batas platform, bukan
# bug; tombol toggle memberi tahu pemain, tidak mengakali.
# RONDE PERBAIKAN (Tara, 18 Nov 2026 — bug Mas: "ketika full screen
# kenapa ga bisa chatingan?"): AKAR MASALAH ada di engine Godot 4.7,
# bukan di panel chat. Dua fakta dari sumber engine 4.7-stable:
# (1) fullscreen diminta engine HANYA pada kanvas
# (library_godot_display.js GodotDisplayScreen.requestFullscreen:
# canvas.requestFullscreen); (2) input tersembunyi keyboard virtual
# ditempel engine sebagai SAUDARA kanvas
# (GodotDisplayVK.init: canvas.insertAdjacentElement('beforebegin',
# elem) — anak <body>, BUKAN anak kanvas). Saat kanvas yang
# fullscreen, browser hanya merender subtree kanvas: input di luar
# subtree itu tidak bisa memanggil keyboard (Chrome Android) sehingga
# LineEdit chat — dan semua field — tidak bisa diketik walau panel
# terbuka dan fokus didapat. Perbaikan: minta fullscreen pada
# documentElement (<html>) — kanvas + input keyboard sama-sama
# keturunannya, jadi keyboard tetap muncul. Kanvas tetap sepenuh layar
# karena canvas_resize_policy=2 (Adaptive): engine selalu menyesuaikan
# kanvas ke ukuran jendela walau mode internal engine tetap WINDOWED.
# _apakah_layar_penuh() sudah baca document.fullscreenElement (benar
# untuk elemen apa pun). Keluar fullscreen JUGA harus lewat JS:
# DisplayServerWeb::window_set_mode(WINDOWED) tidak memanggil
# exitFullscreen bila mode internal sudah WINDOWED (early return) —
# dan mode internal memang tetap WINDOWED di sini.
# Batas tes: fullscreen ASLI di browser (Chrome Android menerima
# gesture ketuk MASUK + kanvas benar-benar fullscreen + keyboard
# muncul saat chat dibuka) hanya bisa dibuktikan di browser HP Mas.
# Yang bisa dibuktikan headless: jalur fallback non-web
# (window_set_mode FULLSCREEN/WINDOWED + flag _layar_penuh_diminta)
# dan alur chat lengkap saat mode FULLSCREEN.
func _minta_layar_penuh() -> void:
	if _apakah_layar_penuh():
		return
	if _minta_layar_penuh_web():
		_layar_penuh_diminta = true
		return
	# Fallback (bukan web, atau JS menolak): cara engine.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_layar_penuh_diminta = true


## Minta fullscreen pada documentElement (<html>) via JS. Kembalikan
## true bila permintaan terkirim. Di luar web kembalikan false supaya
## pemanggil memakai fallback engine. requestFullscreen wajib dari
## gesture pengguna — semua pemanggil _minta_layar_penuh() ada di
## handler ketuk tombol (MASUK / DAFTAR / Lanjutkan / "Layar Penuh").
func _minta_layar_penuh_web() -> bool:
	if not OS.has_feature("web"):
		return false
	var jsb = Engine.get_singleton("JavaScriptBridge")
	if jsb == null:
		return false
	var hasil = jsb.eval("try { var el = document.documentElement; var req = el.requestFullscreen || el.webkitRequestFullscreen; if (!req) { false; } else { var p = req.call(el); if (p && p.catch) { p.catch(function(){}); } true; } } catch (e) { false; }")
	if hasil is bool:
		return hasil
	return false


func _keluar_layar_penuh() -> void:
	if _keluar_layar_penuh_web():
		_layar_penuh_diminta = false
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_layar_penuh_diminta = false


## Keluar fullscreen via JS (document.exitFullscreen keluar dari
## elemen fullscreen apa pun — kanvas maupun documentElement).
## Kembalikan true bila perintah terkirim. Di luar web kembalikan
## false supaya pemanggil memakai fallback engine.
func _keluar_layar_penuh_web() -> bool:
	if not OS.has_feature("web"):
		return false
	var jsb = Engine.get_singleton("JavaScriptBridge")
	if jsb == null:
		return false
	var hasil = jsb.eval("try { if (!document.fullscreenElement) { true; } else if (document.exitFullscreen) { document.exitFullscreen(); true; } else if (document.webkitExitFullscreen) { document.webkitExitFullscreen(); true; } else { false; } } catch (e) { false; }")
	if hasil is bool:
		return hasil
	return false


## Apakah game sedang fullscreen sekarang. Di web baca DOM
## (document.fullscreenElement) — ini yang benar saat browser keluar
## sendiri via tombol kembali/ESC, karena mode internal Godot belum
## tentu ikut berubah. Di luar web pakai window_get_mode.
func _apakah_layar_penuh() -> bool:
	if OS.has_feature("web"):
		var jsb = Engine.get_singleton("JavaScriptBridge")
		if jsb != null:
			var hasil = jsb.eval("document.fullscreenElement != null")
			if hasil is bool:
				return hasil
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


## Apakah browser ini mengizinkan fullscreen. iPhone/Safari:
## document.fullscreenEnabled == false. Kalau JS tidak bisa dibaca,
## anggap didukung — browser yang menolak akan mengabaikan permintaan
## diam-diam dan game tetap jalan berjendela.
func _dukung_layar_penuh() -> bool:
	if not OS.has_feature("web"):
		return true
	var jsb = Engine.get_singleton("JavaScriptBridge")
	if jsb == null:
		return true
	var hasil = jsb.eval("document.fullscreenEnabled")
	if hasil is bool:
		return hasil
	return true


## Toggle dari tombol HUD "Layar Penuh" / "Keluar Layar".
func _on_layar_penuh_pressed() -> void:
	if not _debounce_tekan(_layar_penuh_btn):
		return
	if _apakah_layar_penuh():
		_keluar_layar_penuh()
		return
	if not _dukung_layar_penuh():
		toast("Layar penuh tidak didukung di browser ini (mis. Safari iPhone).")
		return
	_minta_layar_penuh()


## Perbarui teks tombol HUD sesuai keadaan sekarang. Dipanggil saat
## resize (termasuk saat browser masuk/keluar fullscreen) + berkala
## 0,5 dtk di _process (jaring pengaman kalau resize tidak fire).
func _sinkron_tombol_layar_penuh() -> void:
	_atur_teks_tombol_layar_penuh(_apakah_layar_penuh())


func _atur_teks_tombol_layar_penuh(penuh: bool) -> void:
	if _layar_penuh_btn == null:
		return
	_layar_penuh_btn.text = "Keluar Layar" if penuh else "Layar Penuh"
	# ROMBAKAN HUD (Tara, 18 Nov 2026): icon ikut keadaan — panah
	# keluar saat jendela, panah masuk (ciut) saat sudah penuh.
	var ikon := _ikon_dari(_layar_penuh_btn)
	if ikon != null:
		ikon.set_varian("ciut" if penuh else "expand")


## MODE KAMERA v3 (Cakra, 18 Nov 13:13): sinkronkan label tombol
## "Kamera: <Mode>" dengan mode aktif. Dipanggil main.gd tiap ganti
## mode (tombol UI maupun keyboard C). Dijaga null (jaring pengaman
## bila dipanggil sebelum _build_hud).
## ROMBAKAN HUD v3 (Tara, 18 Nov 2026): .text TETAP "Kamera: <Mode>"
## (dibaca test_kamera.gd); label singkat di bawah tombol DIHAPUS
## (mockup: tanpa teks).
## VARIAN B rev1 (Tara, 18 Nov 2026 — DI-ACC Mas 18:43 WIB):
## tombol kamera kini di STRIP ATAS (_kamera_ikon_btn), bukan □.
func set_mode_kamera(nama: String) -> void:
	if _kamera_ikon_btn == null:
		return
	_kamera_ikon_btn.text = "Kamera: " + nama


# ---------- HUD ----------
func _build_hud() -> void:
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hud)
	# Kiri atas: poin + misi.
	var kiri := VBoxContainer.new()
	kiri.position = Vector2(16, 12)
	kiri.add_theme_constant_override("separation", 2)
	_hud.add_child(kiri)
	# ROMBAKAN HUD v3: teks status putih polos TANPA bayangan/outline
	# (mockup: putih tanpa outline).
	_poin_label = _make_label("Poin: 0", 22, Color.WHITE)
	kiri.add_child(_poin_label)
	_misi_label = _make_label("Misi: -", 20, Color.WHITE)
	kiri.add_child(_misi_label)
	# MULTIPLAYER FASE 1 (Wira): status koneksi di bawah misi.
	# ROMBAKAN HUD v3: tanpa bayangan (putih polos, seperti status lain).
	_mp_status_label = _make_label("Offline", 18, Color("#9aa0a6"))
	kiri.add_child(_mp_status_label)
	# MULTIPLAYER FASE 1 (Dimas, 18 Nov 2026 — perbaikan "Belum bisa
	# main multiplayer"): tombol gabung yang terlihat. TANPA ini
	# pemain hanya melihat "Offline" tanpa jalan masuk apa pun
	# (Mas 13:10 WIB: "Belum bisa main multiplayer", "Dimana itu?").
	# POSISI (Cakra, 18 Nov 13:44 — temuan Nadia di foto taman):
	# tombol ini DULU anak VBox kiri, di bawah label status
	# (y~96..140, x 16..176) — TERTUTUP minimap (16,96, 190x190)
	# yang digambar belakangan, teks "Main" setengah hilang.
	# Sekarang anak _hud langsung di (216,116): di kanan minimap
	# (x 16..206), di bawah toast tengah-atas (y 70..110), di atas
	# feed chat (y>=256), jauh dari bar kanan-atas (y 12..56).
	# HANYA posisi yang pindah — teks, ukuran, sinyal tidak berubah.
	_mp_gabung_btn = _make_button("Main Bersama", HIJAU_TERANG)
	_mp_gabung_btn.custom_minimum_size = Vector2(200, 56)
	_mp_gabung_btn.position = Vector2(216, 116)
	# VARIAN B rev1: pill KACA BURAM BERTINTA zamrud muda alpha 150
	# + teks ZAMRUD GELAP (dulu putih translusen + teks putih =
	# tak terbaca di lantai marmer).
	# Pill diperbesar 160x44 -> 200x56 (DI-ACC Mas 21:18 WIB,
	# 18 Nov 2026: perbesar tombol strip atas, proporsional).
	var _wajah_mp := GayaTombol.bulat_kaca(200, 56, 28)
	GayaTombol.pasang_wajah(_mp_gabung_btn, _wajah_mp)
	_mp_gabung_btn.add_theme_color_override("font_color", GayaTombol.ZAMRUD_GELAP)
	_mp_gabung_btn.pressed.connect(func() -> void: mp_gabung_ditekan.emit())
	_hud.add_child(_mp_gabung_btn)
	# ROMBAKAN HUD (Tara, 18 Nov 2026 — arahan Mas 14:41 WIB: tombol
	# aksi ke bawah gaya console, bagian lain cukup icon aja).
	# Bar atas kini ICON-ONLY: Kartu / Peta / Kamera / Suara / Layar
	# Penuh — 64x64, icon digambar kode (IkonHUD, tanpa emoji).
	# (64x64 DI-ACC Mas 21:18 WIB, 18 Nov 2026 — dulu 48x48.)
	# Tombol Aksi pindah ke klaster bawah (lihat bawah); Kamera
	# PINDAH KE SINI dari □ (varian B rev1, arahan Mas 18:33 WIB:
	# "Kotak ganti chat aja ya.. kamera taruh di menu atas..");
	# Chat kini di tombol □ klaster.
	# Teks tombol tetap diisi pemanggil (tidak terlihat — font
	# transparan) supaya logika lama yang membaca .text tidak berubah.
	var bar_ikon := HBoxContainer.new()
	bar_ikon.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	# 6 ikon x 64 + 5x6 separasi = 414, +12 dari tepi kanan.
	# (Dulu 5 ikon = 344/-356 — ikon ke-6 Kualitas, Rangga 19 Nov 2026.)
	bar_ikon.position = Vector2(-426, 12)
	bar_ikon.add_theme_constant_override("separation", 6)
	_hud.add_child(bar_ikon)
	# RONDE 4: tombol Kartu Santri — membuka dashboard (toggle).
	var kartu_btn := _buat_tombol_ikon("kartu", HIJAU)
	kartu_btn.pressed.connect(func() -> void:
		if _debounce_tekan(kartu_btn):
			open_dashboard_requested.emit()
	)
	bar_ikon.add_child(kartu_btn)
	# RONDE 4: tombol Peta — membuka overlay peta top-down (toggle).
	var peta_btn := _buat_tombol_ikon("peta", HIJAU_TERANG)
	peta_btn.pressed.connect(func() -> void:
		if _debounce_tekan(peta_btn):
			open_peta_requested.emit()
	)
	bar_ikon.add_child(peta_btn)
	# VARIAN B rev1 (DI-ACC Mas 18:43 WIB): tombol KAMERA di strip
	# atas (slot ke-3 dari 5, menggantikan icon amplop Chat — Chat
	# pindah ke □). Icon kamera putih + titik lensa ZAMRUD GELAP
	# (varian "lensa_zamrud") supaya lensa terbaca di atas tile
	# terang. Fungsi = ganti mode kamera seperti tombol □ dulu
	# (siklus Normal -> Drone -> Low -> High -> Sinematik).
	# .text tetap "Kamera: <Mode>" (dibaca test_kamera.gd).
	_kamera_ikon_btn = _buat_tombol_ikon("kamera", HIJAU_TERANG)
	_kamera_ikon_btn.text = "Kamera: Normal"
	_kamera_ikon_btn.clip_text = true
	(_ikon_dari(_kamera_ikon_btn) as IkonHUD).varian = "lensa_zamrud"
	_kamera_ikon_btn.pressed.connect(func() -> void:
		if _debounce_tekan(_kamera_ikon_btn):
			kamera_mode_pressed.emit()
	)
	bar_ikon.add_child(_kamera_ikon_btn)
	# RONDE 17: tombol Suara — mute/unmute audio suasana. Icon ikut
	# keadaan (speaker berombak / dicoret, lihat set_suara_mati).
	_suara_btn = _buat_tombol_ikon("speaker", HIJAU_TERANG)
	_suara_btn.pressed.connect(func() -> void:
		if _debounce_tekan(_suara_btn):
			suara_toggled.emit()
	)
	bar_ikon.add_child(_suara_btn)
	# FULLSCREEN (Cakra, 17 Nov 2026): tombol toggle "Layar Penuh" /
	# "Keluar Layar" — jalan keluar yang jelas supaya pemain tidak
	# terjebak fullscreen. Icon ikut keadaan (panah keluar / masuk,
	# lihat _atur_teks_tombol_layar_penuh).
	_layar_penuh_btn = _buat_tombol_ikon("expand", HIJAU_TERANG)
	_layar_penuh_btn.pressed.connect(_on_layar_penuh_pressed)
	bar_ikon.add_child(_layar_penuh_btn)
	# KUALITAS ADAPTIF (Rangga, 19 Nov 2026): tombol ke-6 — membuka
	# panel pilihan kualitas (Otomatis/Ringan/Sedang/Tinggi).
	_kualitas_btn = _buat_tombol_ikon("kualitas", HIJAU_TERANG)
	_kualitas_btn.text = "Kualitas"
	_kualitas_btn.clip_text = true
	_kualitas_btn.pressed.connect(func() -> void: _toggle_panel_kualitas())
	bar_ikon.add_child(_kualitas_btn)
	# RONDE 5: MINIMAP GTA di kiri atas, di bawah label poin/misi —
	# selalu terlihat saat main (petunjuk arah). Kiri bawah sudah
	# dipakai joystick; atas-kiri aman di portrait maupun landscape.
	_minimap = MinimapControl.new()
	_minimap.clip_contents = true
	_minimap.position = Vector2(16, 96)
	_minimap.size = Vector2(190, 190)
	_minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_minimap)
	# Joystick kiri bawah — berjangkar ke sudut kiri bawah (15 Nov ~12:00 WIB:
	# dulu koordinat tetap 720, di HP portrait/landscape posisinya melayang).
	_joystick = SantriJoystick.new()
	_joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_joystick.position = Vector2(24, -244)
	_joystick.size = Vector2(220, 220)
	_hud.add_child(_joystick)
	# BUBBLE-ML: feed chat melayang di ATAS joystick (lihat
	# _build_feed_chat) — anak _hud, jadi ikut sembunyi di layar login.
	_build_feed_chat()
	# KLASTER AKSI GAMEPAD v3 (Tara, 18 Nov 2026 — DI-ACC Mas 17:39 WIB,
	# mockup hud-v3-desain-gamepad-v3.png): 4 tombol diamond ala stik
	# PS5 — △ atas, □ kiri, ○ kanan, ✕ bawah. KEEMPATNYA UKURAN SAMA
	# (100x100), disc putih translusen tanpa outline, icon bentuk
	# outline tipis putih, TANPA teks di tombol. Joystick kiri bawah
	# tetap. Semua berjangkar kanan-bawah (offset tetap) supaya
	# posisinya sama di portrait maupun landscape; tidak ada yang
	# menutupi minimap / joystick / tengah layar. Posisi dihitung dari
	# mockup 720x1560 (pusat △ (-145,-250), □ (-230,-165), ○ (-60,-165),
	# ✕ (-145,-80) dari sudut kanan-bawah, dikurangi setengah ukuran
	# 50) — jarak pusat tombol bersebelahan 120 px > diameter 100 px,
	# jadi disc tidak saling tumpang (sudut rect boleh bersentuhan —
	# lihat test_hud_rombak.gd).
	# Fungsi mengikuti PEMETAAN_TOMBOL_GAMEPAD (contoh yang di-ACC):
	# ✕ = Interact (kontekstual, tampil/sembunyi seperti dulu),
	# △ = Aksi, □ = Chat (varian B rev1 — dulu Kamera), ○ = Reset.
	# Kamera PINDAH ke strip atas. Sinyal + .text TIDAK berubah
	# maknanya (dibaca main.gd + tes lama).
	_tombol_gamepad.clear()
	# ✕ bawah — Interact / Mulai Misi (tombol primer kontekstual:
	# "MULAI MISI" / "BUKA PETI" / "TIDUR" ... dari main.gd).
	_interact_btn = _make_button_bulat(UKURAN_TOMBOL_GAMEPAD)
	_interact_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_interact_btn.position = Vector2(-195, -130)
	_interact_btn.visible = false
	_interact_btn.text = "MULAI MISI"
	_interact_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	_interact_btn.pressed.connect(func() -> void: interact_pressed.emit())
	_interact_btn.set_meta("bentuk", "x")
	_hud.add_child(_interact_btn)
	_tambah_ikon_tombol(_interact_btn, "x", GayaTombol.ZAMRUD_GELAP, Vector2(15, 15), 70)
	_tombol_gamepad["x"] = _interact_btn
	# △ atas — Aksi: menu pose karakter (duduk bersila, salaman,
	# menulis, bawa kitab, melambai, tidur, berdiri).
	var aksi_btn := _make_button_bulat(UKURAN_TOMBOL_GAMEPAD)
	aksi_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	aksi_btn.position = Vector2(-195, -300)
	aksi_btn.text = "Aksi"
	aksi_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	aksi_btn.pressed.connect(_toggle_aksi)
	aksi_btn.set_meta("bentuk", "segitiga")
	_hud.add_child(aksi_btn)
	_tambah_ikon_tombol(aksi_btn, "segitiga", GayaTombol.ZAMRUD_GELAP, Vector2(15, 15), 70)
	_tombol_gamepad["segitiga"] = aksi_btn
	# □ kiri — Chat (varian B rev1, arahan Mas 18:33 WIB: "Kotak
	# ganti chat aja ya.."). Panel chat dibuka saat diketuk (dulu
	# icon amplop di strip atas). Kamera PINDAH ke strip atas.
	_chat_btn = _make_button_bulat(UKURAN_TOMBOL_GAMEPAD)
	_chat_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_chat_btn.position = Vector2(-280, -215)
	_chat_btn.text = "Chat"
	_chat_btn.clip_text = true
	_chat_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	_chat_btn.pressed.connect(_toggle_chat)
	_chat_btn.set_meta("bentuk", "kotak")
	_hud.add_child(_chat_btn)
	_tambah_ikon_tombol(_chat_btn, "kotak", GayaTombol.ZAMRUD_GELAP, Vector2(15, 15), 70)
	_tombol_gamepad["kotak"] = _chat_btn
	# ○ kanan — Reset Posisi (15 Nov ~12:00 WIB): jaring pengaman
	# kalau pemain nyangkut di mana pun — teleport ke depan Surau.
	# RONDE PERBAIKAN (Gita, item 8): tombol menyala saat TEKAN,
	# bukan saat lepas — di HP hampir semua ketukan bergeser sedikit,
	# jadi tombol "mati" padahal kodenya benar (tes klik-seret 120 px:
	# sinyal 0). _make_button_bulat sudah memakai BUTTON_PRESS.
	_reset_btn = _make_button_bulat(UKURAN_TOMBOL_GAMEPAD)
	_reset_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_reset_btn.position = Vector2(-110, -215)
	_reset_btn.text = "Reset Posisi"
	_reset_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0))
	_reset_btn.pressed.connect(func() -> void: reset_requested.emit())
	_reset_btn.set_meta("bentuk", "lingkaran")
	_hud.add_child(_reset_btn)
	_tambah_ikon_tombol(_reset_btn, "lingkaran", GayaTombol.ZAMRUD_GELAP, Vector2(15, 15), 70)
	_tombol_gamepad["lingkaran"] = _reset_btn
	# Pop-up "PETUNJUK TOMBOL" pemain baru (lihat _build_petunjuk_popup).
	_build_petunjuk_popup()
	# KUALITAS ADAPTIF (Rangga, 19 Nov 2026): panel pilihan kualitas.
	_build_panel_kualitas()
	# Panel chat ala Mobile Legends (RONDE 5, Mas: "elegan kaya di mobile
	# legend"): compact, semi-transparan gelap, sudut membulat — riwayat
	# singkat + input ringkas di dalam panel. Panel BUKAN di bawah layar
	# (tengah-atas, tetap terlihat saat keyboard virtual HP terbuka).
	# Riwayat chat lama di kiri bawah (log terpisah) DIHAPUS — riwayat
	# kini tinggal di dalam panel ini.
	_build_chat_panel()


# ---------- pop-up "PETUNJUK TOMBOL" (ROMBAKAN HUD v3 + v2) ----------
# Pop-up pemain baru: muncul saat PERTAMA KALI main (flag save
# "petunjuk_tombol_ditutup", ditulis main.gd lewat sinyal
# petunjuk_ditutup), bisa di-close via tombol × atau "Mengerti".
# v2 (Sinta, 19 Nov 2026 — Konsep UI v2 ACC Mas): kepala rata kiri
# + subjudul, tiap baris berikon dalam lingkaran + keterangan,
# catatan kaki dalam strip krem berikon "i", tombol "Mengerti"
# penuh lebar bergradien emas, panel putih hangat bergradien +
# pita emas di atas + radius 26 + bayangan lembut, animasi masuk.
# DIPERTAHANKAN dari B rev1 (dikunci tes gate test_hud_rombak):
# dim alpha 80, panel alpha 225, judul "PETUNJUK TOMBOL", teks
# catatan kaki persis, SEMUA ikon + teks HITAM (arahan Mas 17:26 WIB:
# "Tulisan di petunjuk warna hitam aja biar bisa dibaca") — jadi
# lingkaran tutup ✕ memakai zamrud lembut + ✕ hitam (bukan lingkaran
# gelap + ✕ putih seperti mockup), dan dim tetap 80 (bukan 96).
# Panel di tengah layar (dipusatkan _pusatkan_panel 480x440, maks
# 92% viewport) — TIDAK menutupi klaster tombol maupun analog
# (panel berakhir jauh di atas klaster). Dim hitam menutupi layar di
# belakang panel (klik ke game tertahan selama pop-up terbuka).
## KUALITAS ADAPTIF (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB):
## panel pilihan kualitas di strip atas (tombol ke-6, ikon 3 batang).
## Minimal: 4 pilihan (Otomatis/Ringan/Sedang/Tinggi) + tombol tutup.
## Pilihan aktif ditandai ikon centang di kiri teks (lihat set_kualitas_mode).
## Panel ini HANYA memilih mode — logika deteksi/probe/pantau tinggal
## di KualitasAdaptif; main menghubungkan sinyal kualitas_dipilih.
func _build_panel_kualitas() -> void:
	_kualitas_panel = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color("#fdf8ec")
	gaya.bg_color.a = 225.0 / 255.0
	gaya.set_corner_radius_all(26)
	gaya.shadow_color = Color(0, 0, 0, 70.0 / 255.0)
	gaya.shadow_size = 16
	gaya.shadow_offset = Vector2(0, 8)
	_kualitas_panel.add_theme_stylebox_override("panel", gaya)
	_kualitas_panel.visible = false
	_hud.add_child(_kualitas_panel)
	_pusatkan_panel(_kualitas_panel, 420.0, 400.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	_kualitas_panel.add_child(margin)
	var tumpuk := VBoxContainer.new()
	tumpuk.add_theme_constant_override("separation", 10)
	margin.add_child(tumpuk)
	var judul := _make_label("Kualitas", 26, Color("#043b2c"))
	tumpuk.add_child(judul)
	var sub := _make_label("Game menyesuaikan dengan perangkatmu.", 15, Color("#555555"))
	tumpuk.add_child(sub)
	var pilihan := [
		["otomatis", "Otomatis (disarankan)"],
		["ringan", "Ringan — HP kentang"],
		["sedang", "Sedang"],
		["tinggi", "Tinggi — HP kuat"],
	]
	for p in pilihan:
		var mode := String(p[0])
		var b := _make_button(String(p[1]), HIJAU_TERANG)
		b.pressed.connect(func() -> void: kualitas_dipilih.emit(mode))
		tumpuk.add_child(b)
		_kualitas_tombol[mode] = b
	var tutup := _make_button("Tutup", Color("#888888"))
	tutup.pressed.connect(func() -> void: _kualitas_panel.visible = false)
	tumpuk.add_child(tutup)


func _toggle_panel_kualitas() -> void:
	if _kualitas_panel == null:
		return
	if not _debounce_tekan(_kualitas_btn):
		return
	_kualitas_panel.visible = not _kualitas_panel.visible


## Dipanggil main setelah menerapkan mode — menandai pilihan aktif.
## IKON PANEL (Tara, 19 Nov 2026): "✓ " di depan teks tofu di web —
## centang digambar IkonHUD (lihat _set_centang_tombol).
func set_kualitas_mode(mode: String) -> void:
	for m in _kualitas_tombol.keys():
		var b := _kualitas_tombol[m] as Button
		if b == null:
			continue
		var teks := String(b.text).trim_prefix("✓ ")
		b.text = teks
		_set_centang_tombol(b, String(m) == mode)


func _build_petunjuk_popup() -> void:
	_petunjuk_dim = ColorRect.new()
	# VARIAN B rev1: dim 80/255 (dulu 65) + panel alpha 225/255
	# (dulu 150) — panel hampir pekat supaya teks hitam terbaca
	# meski pemain di belakangnya (mockup hud-v3-perbaikan-b-rev1).
	_petunjuk_dim.color = Color(0, 0, 0, 80.0 / 255.0)
	_petunjuk_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_petunjuk_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_petunjuk_dim.visible = false
	_hud.add_child(_petunjuk_dim)
	_petunjuk_panel = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color("#fdf8ec")
	gaya.bg_color.a = 225.0 / 255.0
	gaya.set_corner_radius_all(26)
	gaya.shadow_color = Color(0, 0, 0, 70.0 / 255.0)
	gaya.shadow_size = 16
	gaya.shadow_offset = Vector2(0, 8)
	_petunjuk_panel.add_theme_stylebox_override("panel", gaya)
	_petunjuk_panel.visible = false
	_hud.add_child(_petunjuk_panel)
	# Ukuran awal 440 tetap (placeholder) — tinggi final mengikuti isi
	# di _pusatkan_petunjuk_panel(), yang HANYA dipanggil saat tampil /
	# resize (saat itu layout sudah jalan). JANGAN panggil helper di
	# sini: get_minimum_size() saat _ready masih mengembalikan 1621
	# (belum stabil), panel jadi 1621 kanvas (foto 19 Nov 2026).
	_pusatkan_panel(_petunjuk_panel, 480.0, 440.0)
	_petunjuk_panel.resized.connect(func() -> void: _petunjuk_panel.pivot_offset = _petunjuk_panel.size * 0.5)
	# Latar gradien putih hangat + pita emas di atas (anak pertama —
	# PanelContainer menaruh semua anak di rect yang sama).
	# v2-perbaikan (Sinta, 19 Nov 2026): tekstur dibakar 480x460 (bukan
	# 96x96) + radius 20. Radius 26/96 lama = 27% lebar panel, jauh
	# lebih bulat dari StyleBoxFlat (26 px kanvas) — pita emas robek
	# diagonal di sudut + tangga di sudut bawah saat direntang 8,9x.
	# Pita 38 = 8/96 tinggi lama, dipertahankan proporsinya.
	var latar := TextureRect.new()
	latar.texture = GayaMisi.buat_tekstur_gradien(Color("#fdf8ec"), KREM, 20, Color(0, 0, 0, 0), 0, EMAS, 38, Color(0, 0, 0, 0), 0, Vector2i(480, 460))
	latar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	latar.stretch_mode = TextureRect.STRETCH_SCALE
	latar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_petunjuk_panel.add_child(latar)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	_petunjuk_panel.add_child(margin)
	var tumpuk := VBoxContainer.new()
	tumpuk.add_theme_constant_override("separation", 10)
	margin.add_child(tumpuk)
	# v2 — Kepala rata kiri: judul + subjudul, tombol tutup ✕ dalam
	# lingkaran zamrud lembut (icon IkonHUD "x" hitam — bukan teks
	# "×", supaya tidak bergantung pada glif font).
	var baris_judul := HBoxContainer.new()
	baris_judul.add_theme_constant_override("separation", 8)
	tumpuk.add_child(baris_judul)
	var kepala_teks := VBoxContainer.new()
	kepala_teks.add_theme_constant_override("separation", 2)
	kepala_teks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	baris_judul.add_child(kepala_teks)
	var judul := _make_label("PETUNJUK TOMBOL", 24, Color.BLACK)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kepala_teks.add_child(judul)
	var subjudul := _make_label("Ketuk tombol sesuai kebutuhanmu", 15, Color("#5a5a5a"))
	subjudul.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kepala_teks.add_child(subjudul)
	_petunjuk_tutup_btn = _make_button("", Color(0, 0, 0, 0), Color.BLACK)
	_petunjuk_tutup_btn.custom_minimum_size = Vector2(40, 40)
	var gaya_tutup := StyleBoxFlat.new()
	gaya_tutup.bg_color = Color("#dcefe6")
	gaya_tutup.set_corner_radius_all(20)
	for mode in ["normal", "hover", "pressed", "disabled", "focus"]:
		_petunjuk_tutup_btn.add_theme_stylebox_override(mode, gaya_tutup)
	var ikon_tutup := IkonHUD.new()
	ikon_tutup.jenis = "x"
	ikon_tutup.warna = Color.BLACK
	ikon_tutup.bayangan = false
	ikon_tutup.position = Vector2(8, 8)
	ikon_tutup.size = Vector2(24, 24)
	ikon_tutup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_petunjuk_tutup_btn.add_child(ikon_tutup)
	_petunjuk_tutup_btn.set_meta("ikon", ikon_tutup)
	_petunjuk_tutup_btn.pressed.connect(_tutup_petunjuk)
	baris_judul.add_child(_petunjuk_tutup_btn)
	# v2 — 4 baris bentuk + fungsi + keterangan (dari PETUNJUK_BARIS
	# + PETUNJUK_KETERANGAN — urutan tampil sama).
	for baris in PETUNJUK_BARIS:
		var bentuk := String(baris[0])
		var fungsi := String(baris[1])
		var baris_h := HBoxContainer.new()
		baris_h.add_theme_constant_override("separation", 12)
		tumpuk.add_child(baris_h)
		var lingkaran := Panel.new()
		lingkaran.custom_minimum_size = Vector2(44, 44)
		var gaya_lingkaran := StyleBoxFlat.new()
		gaya_lingkaran.bg_color = Color("#dcefe6")
		gaya_lingkaran.set_corner_radius_all(22)
		lingkaran.add_theme_stylebox_override("panel", gaya_lingkaran)
		baris_h.add_child(lingkaran)
		var ikon := IkonHUD.new()
		ikon.jenis = bentuk
		ikon.warna = Color.BLACK
		ikon.bayangan = false
		ikon.position = Vector2(8, 8)
		ikon.size = Vector2(28, 28)
		ikon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lingkaran.add_child(ikon)
		var teks_baris := VBoxContainer.new()
		teks_baris.add_theme_constant_override("separation", 2)
		teks_baris.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		baris_h.add_child(teks_baris)
		var label := _make_label(fungsi, 20, Color.BLACK)
		teks_baris.add_child(label)
		var keterangan := _make_label(String(PETUNJUK_KETERANGAN.get(fungsi, "")), 14, Color("#5a5a5a"))
		teks_baris.add_child(keterangan)
	# v2 — Catatan kaki dalam strip krem berikon "i" emas.
	# TEKS DIPERTAHANKAN PERSIS (dikunci tes gate test_hud_rombak).
	# VARIAN B rev1: kamera kini di menu atas (bukan □ lagi).
	var strip := PanelContainer.new()
	var gaya_strip := StyleBoxFlat.new()
	gaya_strip.bg_color = KREM
	gaya_strip.set_corner_radius_all(12)
	strip.add_theme_stylebox_override("panel", gaya_strip)
	strip.add_theme_constant_override("margin_left", 12)
	strip.add_theme_constant_override("margin_right", 12)
	strip.add_theme_constant_override("margin_top", 8)
	strip.add_theme_constant_override("margin_bottom", 8)
	tumpuk.add_child(strip)
	var baris_catatan := HBoxContainer.new()
	baris_catatan.add_theme_constant_override("separation", 8)
	strip.add_child(baris_catatan)
	var ikon_info := PanelContainer.new()
	ikon_info.custom_minimum_size = Vector2(24, 24)
	var gaya_info := StyleBoxFlat.new()
	gaya_info.bg_color = EMAS
	gaya_info.set_corner_radius_all(12)
	ikon_info.add_theme_stylebox_override("panel", gaya_info)
	baris_catatan.add_child(ikon_info)
	var label_info := _make_label("i", 16, Color.WHITE)
	label_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ikon_info.add_child(label_info)
	var catatan := _make_label("Kamera ada di menu atas • Fungsi tombol berubah sesuai misi", 15, Color.BLACK)
	catatan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catatan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	baris_catatan.add_child(catatan)
	# v2 — Tombol "Mengerti": penuh lebar, gradien emas, 21 tebal.
	_petunjuk_mengerti_btn = _make_button("Mengerti", Color(0, 0, 0, 0), Color.BLACK)
	_petunjuk_mengerti_btn.custom_minimum_size = Vector2(0, 52)
	_petunjuk_mengerti_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_petunjuk_mengerti_btn.add_theme_font_size_override("font_size", 21)
	_petunjuk_mengerti_btn.set_meta("font_dasar", 21)
	_petunjuk_mengerti_btn.add_theme_stylebox_override("normal", GayaMisi.gaya_tombol_emas_gradien())
	_petunjuk_mengerti_btn.add_theme_stylebox_override("hover", GayaMisi.gaya_tombol_emas_gradien_hover())
	_petunjuk_mengerti_btn.add_theme_stylebox_override("pressed", GayaMisi.gaya_tombol_emas_gradien_pressed())
	_petunjuk_mengerti_btn.add_theme_stylebox_override("disabled", GayaMisi.gaya_tombol_emas_gradien())
	_petunjuk_mengerti_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_petunjuk_mengerti_btn.pressed.connect(_tutup_petunjuk)
	GayaMisi.pasang_umpan_tekan(_petunjuk_mengerti_btn)
	tumpuk.add_child(_petunjuk_mengerti_btn)


## Pop-up petunjuk: tinggi mengikuti isi (v2-perbaikan Sinta, 19 Nov
## 2026). Panel 440 tetap menyisakan ~40% ruang kosong di layar
## skala kecil (foto: isi 266 px dari panel 440 px) dan meluber
## ~20 px di HP (skala 1,5: panel 440 kanvas < isi ~460 kanvas).
## Lebar tetap 480; tinggi = tinggi minimum isi (kanvas) di semua skala.
func _pusatkan_petunjuk_panel() -> void:
	if _petunjuk_panel == null:
		return
	var isi := _petunjuk_panel.get_minimum_size().y
	var target := maxf(isi * _skala_layar(), 200.0)
	_pusatkan_panel(_petunjuk_panel, 480.0, target)


## Versi tertunda dari _pusatkan_petunjuk_panel (dipakai saat tampil):
## pengukuran isi hanya stabil setelah panel melewati satu layout pass
## dalam keadaan terlihat — label autowrap diukur pada lebar ~0
## sebelumnya sehingga isi terbaca 1621 (bukan ~451). Tunggu 2 frame
## agar layout jalan; 2 frame pertama animasi masuk masih modulate~0.
func _pusatkan_petunjuk_panel_tertunda() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_pusatkan_petunjuk_panel()


## Tampilkan pop-up sekali saja (dipanggil main.gd dari
## _masuk_pesantren): sudah_ditutup dibaca dari save — kalau sudah
## pernah ditutup, pop-up tidak muncul lagi.
func coba_tampilkan_petunjuk_awal(sudah_ditutup: bool) -> void:
	if sudah_ditutup:
		return
	if _petunjuk_dim == null or _petunjuk_panel == null:
		return
	# Tinggi panel mengikuti isi — via _tertunda (2 frame, setelah
	# layout): ukur langsung di sini masih 1621 (label autowrap pada
	# lebar ~0); setelah layout, isi stabil ~451 kanvas. Frame pertama
	# animasi masuk masih modulate.a~0 (tidak terlihat).
	call_deferred("_pusatkan_petunjuk_panel_tertunda")
	_petunjuk_dim.visible = true
	_petunjuk_panel.visible = true
	_animasi_petunjuk_masuk()


## v2: dim fade 150 ms + panel mengembang (scale 0.96->1.0 + fade,
## 180 ms ease-out).
func _animasi_petunjuk_masuk() -> void:
	if _tween_petunjuk != null and _tween_petunjuk.is_valid():
		_tween_petunjuk.kill()
	_petunjuk_panel.pivot_offset = _petunjuk_panel.size * 0.5
	_petunjuk_panel.scale = Vector2(0.96, 0.96)
	_petunjuk_panel.modulate.a = 0.0
	_petunjuk_dim.modulate.a = 0.0
	_tween_petunjuk = create_tween()
	_tween_petunjuk.set_parallel(true)
	_tween_petunjuk.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_petunjuk.tween_property(_petunjuk_dim, "modulate:a", 1.0, 0.15)
	_tween_petunjuk.tween_property(_petunjuk_panel, "scale", Vector2.ONE, 0.18)
	_tween_petunjuk.tween_property(_petunjuk_panel, "modulate:a", 1.0, 0.18)


func is_petunjuk_visible() -> bool:
	return _petunjuk_panel != null and _petunjuk_panel.visible


func _tutup_petunjuk() -> void:
	if _tween_petunjuk != null and _tween_petunjuk.is_valid():
		_tween_petunjuk.kill()
	if _petunjuk_dim != null:
		_petunjuk_dim.modulate.a = 1.0
		_petunjuk_dim.visible = false
	if _petunjuk_panel != null:
		_petunjuk_panel.scale = Vector2.ONE
		_petunjuk_panel.modulate.a = 1.0
		_petunjuk_panel.visible = false
	petunjuk_ditutup.emit()


## Panel chat ala Mobile Legends (RONDE 5): PanelContainer gelap
## semi-transparan (alpha 0.82) + sudut membulat 12, header kecil
## (judul + X), daftar pesan singkat (font 15, maks 5), baris input
## ringkas (LineEdit + tombol Kirim compact). Posisi tengah-atas
## (offset 70 dari atas) — JAUH dari keyboard virtual yang muncul
## dari bawah layar HP, teks yang diketik tetap terbaca. Lebar maks
## 520, dibatasi 92% viewport supaya muat di portrait 390 px.
func _build_chat_panel() -> void:
	_chat_panel = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color(0.06, 0.10, 0.09, 0.82)
	gaya.corner_radius_top_left = 12
	gaya.corner_radius_top_right = 12
	gaya.corner_radius_bottom_left = 12
	gaya.corner_radius_bottom_right = 12
	gaya.border_color = Color(1, 1, 1, 0.15)
	gaya.set_border_width_all(1)
	gaya.content_margin_left = 12.0
	gaya.content_margin_right = 12.0
	gaya.content_margin_top = 10.0
	gaya.content_margin_bottom = 10.0
	_chat_panel.add_theme_stylebox_override("panel", gaya)
	add_child(_chat_panel)
	_layout_chat_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_chat_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var judul := _make_label("CHAT PESANTREN", 16, Color("#f2c14e"))
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(judul)
	var x_btn := _make_button("X", Color("#555555"))
	# RONDE 8 (retest: X chat tidak menutup — tombol 40x36 terlalu
	# kecil, sama seperti pelajaran tombol X dashboard 15:05 WIB):
	# diperbesar ke 56x48 supaya tepi tombol tetap kena klik.
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.pressed.connect(close_chat)
	header.add_child(x_btn)
	_chat_list = VBoxContainer.new()
	_chat_list.add_theme_constant_override("separation", 2)
	_chat_list.custom_minimum_size = Vector2(0, 96)
	box.add_child(_chat_list)
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 8)
	box.add_child(baris)
	_chat_input = LineEdit.new()
	_chat_input.placeholder_text = "Tulis pesan..."
	_chat_input.max_length = 60
	_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_input.custom_minimum_size = Vector2(0, 44)
	_chat_input.add_theme_font_size_override("font_size", 16)
	_gaya_field(_chat_input)
	_chat_input.focus_entered.connect(_minta_keyboard)
	_chat_input.gui_input.connect(_on_field_gui_input.bind(_chat_input))
	_chat_input.text_submitted.connect(_on_chat_submit)
	baris.add_child(_chat_input)
	var kirim_btn := _make_button("Kirim", EMAS, GELAP)
	kirim_btn.custom_minimum_size = Vector2(76, 44)
	kirim_btn.pressed.connect(_on_chat_submit.bind(""))
	baris.add_child(kirim_btn)


## Layout panel chat: tengah-atas, lebar maks 520 (92% viewport).
## Dipanggil saat dibangun + tiap resize (lihat _layout_semua_panel).
func _layout_chat_panel() -> void:
	if _chat_panel == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var w := minf(vp.x * 0.92, 520.0)
	_chat_panel.anchor_left = 0.5
	_chat_panel.anchor_right = 0.5
	_chat_panel.anchor_top = 0.0
	_chat_panel.anchor_bottom = 0.0
	_chat_panel.offset_left = -w * 0.5
	_chat_panel.offset_right = w * 0.5
	_chat_panel.offset_top = 70.0
	_chat_panel.offset_bottom = 70.0 + 216.0


func is_chat_visible() -> bool:
	return _chat_panel.visible


func close_chat() -> void:
	_chat_panel.visible = false
	if _chat_input != null:
		_chat_input.release_focus()


func _toggle_chat() -> void:
	if not _debounce_tekan(_chat_btn):
		return
	_chat_panel.visible = not _chat_panel.visible
	if _chat_panel.visible:
		close_aksi()
		_chat_input.grab_focus()


## Panel Aksi karakter (RONDE 6, Mas: duduk bersila, berdiri, salaman,
## menulis, bawa kitab/buku, melambai, tidur): menu kecil ala MLBB,
## tengah-atas seperti panel chat (tombol Aksi di HUD). Membuka panel
## ini menutup panel chat (dan sebaliknya) supaya tidak menumpuk.
func _build_aksi_panel() -> void:
	_aksi_panel = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color(0.06, 0.10, 0.09, 0.88)
	gaya.corner_radius_top_left = 12
	gaya.corner_radius_top_right = 12
	gaya.corner_radius_bottom_left = 12
	gaya.corner_radius_bottom_right = 12
	gaya.border_color = Color(1, 1, 1, 0.15)
	gaya.set_border_width_all(1)
	gaya.content_margin_left = 12.0
	gaya.content_margin_right = 12.0
	gaya.content_margin_top = 10.0
	gaya.content_margin_bottom = 10.0
	_aksi_panel.add_theme_stylebox_override("panel", gaya)
	add_child(_aksi_panel)
	_layout_aksi_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_aksi_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var judul := _make_label("AKSI", 16, Color("#f2c14e"))
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(judul)
	var x_btn := _make_button("X", Color("#555555"))
	# TARA 20 Nov 2026 (audit tombol): 40x36 -> 56x48, samakan dengan
	# X chat (perbaikan Ronde 8: 40x36 terlalu kecil, tepi tidak kena
	# klik). Panel aksi TIDAK ikut _terapkan_skala_panel, jadi ukuran
	# dasar ini yang menentukan target ketuk di HP.
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.pressed.connect(close_aksi)
	header.add_child(x_btn)
	for aksi in [
		["duduk", "Duduk Bersila"],
		["berdiri", "Berdiri"],
		["salaman", "Salaman"],
		["menulis", "Menulis"],
		["bawa_kitab", "Bawa Kitab"],
		["melambai", "Melambai"],
		["tidur", "Tidur"],
	]:
		var b := _make_button(String(aksi[1]), HIJAU_TERANG)
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(_on_aksi_pressed.bind(String(aksi[0])))
		box.add_child(b)


func _layout_aksi_panel() -> void:
	if _aksi_panel == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var w := minf(vp.x * 0.92, 320.0)
	_aksi_panel.anchor_left = 0.5
	_aksi_panel.anchor_right = 0.5
	_aksi_panel.anchor_top = 0.0
	_aksi_panel.anchor_bottom = 0.0
	_aksi_panel.offset_left = -w * 0.5
	_aksi_panel.offset_right = w * 0.5
	_aksi_panel.offset_top = 70.0
	_aksi_panel.offset_bottom = 70.0 + 420.0


func _on_aksi_pressed(nama: String) -> void:
	aksi_dipilih.emit(nama)
	close_aksi()


func close_aksi() -> void:
	if _aksi_panel != null:
		_aksi_panel.visible = false


func is_aksi_visible() -> bool:
	return _aksi_panel != null and _aksi_panel.visible


func _toggle_aksi() -> void:
	var b := _tombol_gamepad.get("segitiga") as Button
	if b != null and not _debounce_tekan(b):
		return
	_aksi_panel.visible = not _aksi_panel.visible
	if _aksi_panel.visible:
		close_chat()


## RONDE 17: label tombol Suara mengikuti status mute ("Suara" =
## bunyi, "Senyap" = dimatikan). Dipanggil main.gd saat load + saat
## tombol ditekan.
## ROMBAKAN HUD (Tara, 18 Nov 2026): icon ikut keadaan — speaker
## berombak saat bunyi, speaker dicoret saat senyap.
func set_suara_mati(mati: bool) -> void:
	if _suara_btn == null:
		return
	_suara_btn.text = "Senyap" if mati else "Suara"
	var ikon := _ikon_dari(_suara_btn)
	if ikon != null:
		ikon.set_varian("senyap" if mati else "nyala")


## Panel Ganti Baju (RONDE 6, Mas: "kek game beneran"): dibuka dari
## kamar cangkruk (dekat lemari). Tiga baris pilihan — Koko, Songkok,
## Sarung — berupa tombol contoh warna (swatch). Pilihan langsung
## diterapkan ke karakter (preview langsung) + disimpan (main.gd).
func _build_outfit_panel() -> void:
	_outfit_panel = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color("#f5f0e6")
	gaya.corner_radius_top_left = 14
	gaya.corner_radius_top_right = 14
	gaya.corner_radius_bottom_left = 14
	gaya.corner_radius_bottom_right = 14
	gaya.border_color = Color("#d4a017")
	gaya.set_border_width_all(2)
	gaya.content_margin_left = 16.0
	gaya.content_margin_right = 16.0
	gaya.content_margin_top = 14.0
	gaya.content_margin_bottom = 14.0
	_outfit_panel.add_theme_stylebox_override("panel", gaya)
	add_child(_outfit_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_outfit_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var judul := _make_label("GANTI BAJU", 22, HIJAU)
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(judul)
	var x_btn := _make_button("X", Color("#555555"))
	x_btn.custom_minimum_size = Vector2(48, 44)
	x_btn.pressed.connect(close_outfit)
	header.add_child(x_btn)
	var sub := _make_label("Pilihan langsung terlihat di karaktermu.", 15, Color("#666666"))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(sub)
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): enam
	# baris pilihan — Koko/Songkok/Sarung untuk santriwan, Abaya/
	# Jilbab untuk santriwati, Kulit untuk semua. Baris "jilbab"
	# menulis kunci save "hijab_warna" (yang dibaca build_visual);
	# label panel tetap "Jilbab". Tiap baris dibungkus wadah sendiri
	# supaya open_outfit bisa menyembunyikan baris yang tidak
	# berlaku untuk gender pemain.
	var baris_outfit: Array = [
		["koko", "Koko (baju)", MissionData.OUTFIT_KOKO],
		["songkok", "Songkok", MissionData.OUTFIT_SONGKOK],
		["sarung", "Sarung", MissionData.OUTFIT_SARUNG],
		["abaya", "Abaya", MissionData.OUTFIT_ABAYA],
		["jilbab", "Jilbab", MissionData.OUTFIT_JILBAB],
		["kulit", "Kulit", MissionData.OUTFIT_KULIT],
	]
	for entri in baris_outfit:
		var jenis: String = entri[0]
		var kunci: String = "hijab_warna" if jenis == "jilbab" else jenis
		var wadah := VBoxContainer.new()
		wadah.add_theme_constant_override("separation", 8)
		box.add_child(wadah)
		_outfit_baris[jenis] = wadah
		wadah.add_child(_make_label(String(entri[1]), 19, HIJAU))
		var baris := HBoxContainer.new()
		baris.add_theme_constant_override("separation", 8)
		wadah.add_child(baris)
		var pilihan: Array = entri[2]
		for p in pilihan:
			var warna: Color = p["warna"]
			var b := Button.new()
			b.text = String(p["nama"])
			b.custom_minimum_size = Vector2(0, 48)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var sb := StyleBoxFlat.new()
			sb.bg_color = warna
			sb.corner_radius_top_left = 10
			sb.corner_radius_top_right = 10
			sb.corner_radius_bottom_left = 10
			sb.corner_radius_bottom_right = 10
			sb.set_border_width_all(2)
			sb.border_color = Color("#d4a017")
			b.add_theme_stylebox_override("normal", sb)
			var lum := 0.299 * warna.r + 0.587 * warna.g + 0.114 * warna.b
			b.add_theme_color_override("font_color", Color("#1d2b26") if lum > 0.5 else Color.WHITE)
			b.add_theme_font_size_override("font_size", 17)
			b.set_meta("font_dasar", 17)
			# RONDE 19 (retest: klik sarung Biru/Coklat tidak terdaftar
			# live, padahal klik bersih headless lolos): tombol Button
			# default menyala saat LEPAS di dalam tombol — kalau klik
			# browser dikirim sebagai tekan → geser mouse → lepas di
			# luar tombol, pilihan TIDAK menyala (terbukti tes seret
			# 120 px: sinyal 7->7). Pemilih warna menyala saat TEKAN
			# (langsung terasa dipilih) — kebal terhadap posisi lepas.
			b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			# RONDE 6 — PERBAIKAN (tes foto ronde 6): kunci tombol harus
			# memakai format hex yang SAMA dengan yang dibandingkan
			# set_outfit_terpilih ("#rrggbb", 6 digit, huruf kecil).
			# Dulu: warna.to_html() = 8 digit TANPA # ("faf7f0ff")
			# sehingga perbandingan kunci TIDAK PERNAH cocok dan tanda
			# "✓" pilihan aktif tidak pernah muncul di panel.
			_outfit_buttons[kunci + ":" + "#" + warna.to_html(false).to_lower()] = b
			b.pressed.connect(_on_outfit_swatch.bind(kunci, "#" + warna.to_html(false)))
			baris.add_child(b)
	# RONDE 11: baris Kacamata — bukan swatch warna, tombol Pakai /
	# Lepas. Kunci "kacamata:ya"/"kacamata:tidak" supaya tanda ✓ di
	# set_outfit_terpilih tetap jalan (pola yang sama seperti swatch).
	box.add_child(_make_label("Kacamata", 19, HIJAU))
	var baris_kc := HBoxContainer.new()
	baris_kc.add_theme_constant_override("separation", 8)
	box.add_child(baris_kc)
	for pakai in [true, false]:
		var bkc := Button.new()
		bkc.text = "Pakai" if pakai else "Lepas"
		bkc.custom_minimum_size = Vector2(0, 48)
		bkc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sbkc := StyleBoxFlat.new()
		sbkc.bg_color = Color("#1a1a1a") if pakai else Color("#e8e0d0")
		sbkc.corner_radius_top_left = 10
		sbkc.corner_radius_top_right = 10
		sbkc.corner_radius_bottom_left = 10
		sbkc.corner_radius_bottom_right = 10
		sbkc.set_border_width_all(2)
		sbkc.border_color = Color("#d4a017")
		bkc.add_theme_stylebox_override("normal", sbkc)
		bkc.add_theme_color_override("font_color", Color.WHITE if pakai else Color("#1d2b26"))
		bkc.add_theme_font_size_override("font_size", 17)
		bkc.set_meta("font_dasar", 17)
		# RONDE 19: sama seperti swatch — menyala saat TEKAN.
		bkc.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		_outfit_buttons["kacamata:" + ("ya" if pakai else "tidak")] = bkc
		bkc.pressed.connect(_on_kacamata_dipilih.bind(pakai))
		baris_kc.add_child(bkc)


func _on_kacamata_dipilih(pakai: bool) -> void:
	outfit_dipilih.emit("kacamata", "ya" if pakai else "tidak")
	set_outfit_terpilih("kacamata", "ya" if pakai else "tidak")


func _on_outfit_swatch(jenis: String, warna_hex: String) -> void:
	outfit_dipilih.emit(jenis, warna_hex)
	set_outfit_terpilih(jenis, warna_hex)


func open_outfit(outfit: Dictionary) -> void:
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum):
	# santriwati abaya melihat baris Abaya + Jilbab (bukan Koko/
	# Songkok/Sarung); santriwan sebaliknya. Kulit + Kacamata selalu ada.
	# SERAGAM UTAMA v2: santriwati tunik (baju+sarung) melihat baris
	# Koko/Sarung/Jilbab — bukan Abaya. Songkok tetap putra saja
	# (putri memakai jilbab, bukan peci).
	var muslimah := bool(outfit.get("muslimah", false))
	var tunik := bool(outfit.get("tunik", false))
	var pakai_abaya := muslimah and not tunik
	var tampil := {"koko": not pakai_abaya, "songkok": not muslimah, "sarung": not pakai_abaya, "abaya": pakai_abaya, "jilbab": muslimah, "kulit": true}
	for jenis in _outfit_baris.keys():
		(_outfit_baris[jenis] as VBoxContainer).visible = bool(tampil.get(jenis, true))
	for jenis in ["koko", "songkok", "sarung", "kulit"]:
		set_outfit_terpilih(jenis, String(outfit.get(jenis, "")))
	set_outfit_terpilih("abaya", String(outfit.get("abaya", "#065f46")))
	set_outfit_terpilih("hijab_warna", String(outfit.get("hijab_warna", "#f2ead6")))
	set_outfit_terpilih("kacamata", "ya" if bool(outfit.get("kacamata", false)) else "tidak")
	_outfit_panel.visible = true
	_minta_relayout()


func close_outfit() -> void:
	if _outfit_panel != null:
		_outfit_panel.visible = false


func is_outfit_visible() -> bool:
	return _outfit_panel != null and _outfit_panel.visible


## Tandai pilihan aktif dengan ikon centang di kiri nama swatch.
## IKON PANEL (Tara, 19 Nov 2026): "✓ " di depan teks tofu di web —
## centang digambar IkonHUD (lihat _set_centang_tombol).
func set_outfit_terpilih(jenis: String, warna_hex: String) -> void:
	for key in _outfit_buttons.keys():
		var b: Button = _outfit_buttons[key]
		if not String(key).begins_with(jenis + ":"):
			continue
		var nama := b.text.trim_prefix("✓ ")
		b.text = nama
		_set_centang_tombol(b, String(key) == jenis + ":" + warna_hex.to_lower())


func _on_chat_submit(_text: String) -> void:
	var teks := _chat_input.text.strip_edges()
	if teks.is_empty():
		return
	_chat_input.text = ""
	chat_sent.emit(teks)


func add_chat_line(pengirim: String, teks: String) -> void:
	# RONDE 5 (MLBB): riwayat masuk ke daftar di dalam panel chat
	# (font kecil 15, maks 5 baris) — bukan lagi log terpisah di
	# kiri bawah. Bubble di atas karakter tetap seperti sebelumnya.
	var l := _make_label(pengirim + ": " + teks, 15, Color("#f5f0e6"))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_chat_list.add_child(l)
	_chat_lines.append(l)
	while _chat_lines.size() > 5:
		var lama: Label = _chat_lines.pop_front()
		lama.queue_free()


func show_world() -> void:
	_login_panel.visible = false
	_hud.visible = true


func is_world_visible() -> bool:
	return _hud.visible


## Sembunyikan/tampilkan HUD (dipakai adegan belajar Ruang Belajar
## chat §8 — dunia bersih ala Genshin selama dialog; dim transparan
## manajer tetap menahan input dunia).
func set_hud_visible(v: bool) -> void:
	_hud.visible = v


func get_joystick_vector() -> Vector2:
	return _joystick.get_vector()


func set_hud(poin: int, misi_text: String) -> void:
	_poin_label.text = "Poin: " + str(poin)
	_misi_label.text = "Misi: " + misi_text


# MULTIPLAYER FASE 1 (Wira): status koneksi (Offline / Menghubungkan /
# Online + jumlah pemain). Daftar nama pemain online DIHAPUS 19 Nov 2026
# (keputusan Mas). Dipanggil main.gd. Tanpa chat (Fase 2). Teks ASCII
# saja (font HUD tidak punya glif emoji/lingkaran — pelajaran ronde 7).
func set_mp_status(status: String, jumlah: int) -> void:
	if _mp_status_label == null:
		return
	match status:
		"online":
			_mp_status_label.text = "Online (%d pemain)" % jumlah
			_mp_status_label.add_theme_color_override("font_color", Color("#7dd87d"))
		"menghubungkan":
			_mp_status_label.text = "Menghubungkan..."
			_mp_status_label.add_theme_color_override("font_color", Color("#f2c14e"))
		_:
			_mp_status_label.text = "Offline"
			_mp_status_label.add_theme_color_override("font_color", Color("#9aa0a6"))
	# Tombol gabung (Dimas, 18 Nov 2026): hanya saat offline; saat
	# menghubungkan tampil nonaktif, saat online sembunyi (status
	# sudah jelas dari label).
	if _mp_gabung_btn != null:
		match status:
			"online":
				_mp_gabung_btn.visible = false
			"menghubungkan":
				_mp_gabung_btn.visible = true
				_mp_gabung_btn.disabled = true
				_mp_gabung_btn.text = "Menghubungkan..."
			_:
				_mp_gabung_btn.visible = true
				_mp_gabung_btn.disabled = false
				_mp_gabung_btn.text = "Main Bersama"


# ROMBAKAN HUD v3: teks kontekstual hanya di .text (font tombol
# transparan, tidak tampil) — label di dalam tombol DIHAPUS v3
# (mockup: tanpa teks; fungsi tombol dibaca dari pop-up petunjuk).
func set_interact_visible(v: bool, teks: String = "MULAI MISI") -> void:
	_interact_btn.visible = v
	_interact_btn.text = teks


# ---------- feed chat melayang ala Mobile Legends (BUBBLE-ML) ----------
## Posisi: kiri bawah, 12 px DI ATAS joystick (joystick: y -244..-24,
## 220x220 di (24,-244)). Wadah 520x208 di (24,-464): bawah wadah di
## -256 (12 px di atas joystick), kiri sejajar joystick (x=24). Baris
## menumpuk ke ATAS (alignment END: baris baru di bawah, yang lama
## naik) — feed tidak pernah menutup joystick, tombol Reset Posisi
## (kanan bawah), atau minimap (kiri atas). TANPA PanelContainer /
## stylebox / latar — hanya Label dengan bayangan (pola label HUD
## poin/misi) supaya terbaca di atas dunia 3D.
func _build_feed_chat() -> void:
	_feed_chat = VBoxContainer.new()
	_feed_chat.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_feed_chat.position = Vector2(24, -464)
	_feed_chat.size = Vector2(520, 208)
	_feed_chat.alignment = BoxContainer.ALIGNMENT_END
	_feed_chat.add_theme_constant_override("separation", 4)
	_feed_chat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_feed_chat)


## Tampilkan satu pesan di feed melayang. Dipanggil main.gd:
## - pesan pemain: _on_chat_sent -> tampilkan_pesan_melayang(nama, teks)
## - pesan NPC: sinyal SantriNPC.pesan -> connect ke fungsi ini.
## Nama emas (#f2c14e, warna judul panel chat), teks putih, font 18.
func tampilkan_pesan_melayang(nama: String, teks: String) -> void:
	if _feed_chat == null:
		return
	var bersih := Palette.rapikan_bubble(teks, 100)
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 6)
	baris.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var nama_label := _make_label(nama + ":", 18, Color("#f2c14e"))
	nama_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	baris.add_child(nama_label)
	var teks_label := _make_label(bersih, 18, Color.WHITE)
	teks_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	teks_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	teks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	baris.add_child(teks_label)
	# Bayangan hitam supaya terbaca di atas dunia 3D (pola label HUD).
	for l in [nama_label, teks_label]:
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		l.add_theme_constant_override("shadow_offset_x", 2)
		l.add_theme_constant_override("shadow_offset_y", 2)
	_feed_chat.add_child(baris)
	_feed_baris.append({"row": baris, "sisa": FEED_CHAT_DURASI})
	while _feed_baris.size() > FEED_CHAT_MAKS:
		var lama: Dictionary = _feed_baris.pop_front()
		(lama["row"] as HBoxContainer).queue_free()


## Jumlah baris feed yang sedang tampil (untuk tes headless).
func jumlah_pesan_melayang() -> int:
	return _feed_baris.size()


## Teks tiap baris feed yang sedang tampil, dari atas ke bawah
## (untuk tes headless: urutan + baris yang dibuang).
func pesan_melayang_terlihat() -> Array[String]:
	var hasil: Array[String] = []
	for entri in _feed_baris:
		var row := entri["row"] as HBoxContainer
		hasil.append((row.get_child(1) as Label).text)
	return hasil


# ---------- panel overlay (misi / peta / smartboard / dashboard) ----------
## Ukuran panel overlay yang dijamin muat di viewport — fungsi murni,
## bisa dites di 390x844 portrait dan 844x390 landscape.
## Aturan (sama seperti login_metrics): ukuran target FISIK maks
## 700x560 px, dibatasi 92% lebar/tinggi viewport. Di layar berskala
## kecil (HP portrait skala ~0.30), 700x560 kanvas cuma 213x171 px
## fisik — tidak terbaca, tombol X 17x15 px tidak bisa diketuk. Karena
## itu ukuran kanvas = maks(700, 700/skala), dibatasi 92% viewport:
## di desktop (skala >= 1) tetap 700x560 kanvas seperti ronde 2-3,
## di HP panel membesar sampai 700 px fisik (atau 92% layar).
static func panel_metrics(lebar_viewport: float, tinggi_viewport: float, scale: float = 1.0) -> Dictionary:
	var s := scale
	if s <= 0.01 or is_nan(s):
		s = 1.0
	s = clampf(s, 0.2, 3.0)
	return {
		"w": minf(lebar_viewport * 0.92, maxf(700.0, 700.0 / s)),
		"h": minf(tinggi_viewport * 0.92, maxf(560.0, 560.0 / s)),
	}


## Memusatkan sebuah panel overlay dengan ukuran dari panel_metrics.
## Dipanggil saat panel dibangun + tiap resize — panel tidak pernah
## menjorok keluar layar (perbaikan bug Kartu Santri ronde 2 + panel
## misi ronde 4: preset-sebelum-add_child membuat offset 0 semua).
## Relayout 2 frame setelah panel dibuka (15 Nov ~17:10 WIB — penyebab
## panel misi/peta membesar ke 1014/2512 px): label autowrap dihitung
## min-size-nya saat lebar masih 0 (panel tersembunyi belum pernah
## di-layout) — judul misi 1 px × 979 px, legenda peta 1 px × 1971 px —
## sehingga PanelContainer terpaksa membesar ke combined minimum size
## kontennya dan TIDAK PERNAH mengecil lagi (offset hanya diterapkan
## ulang saat resize). Setelah 1 frame terlihat, label punya lebar nyata,
## min-size kembali waras; offset diterapkan ulang 2 frame berturut-turut
## supaya panel kembali ke 700x560 (atau 92% viewport).
var _relayout_frames: int = 0


func _minta_relayout() -> void:
	_relayout_frames = 2


func _pusatkan_panel(panel: PanelContainer, lebar_target: float = 700.0, tinggi_target: float = 560.0) -> void:
	if panel == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var s := _skala_layar()
	# Sama seperti panel_metrics, tapi target ukuran bisa beda per
	# panel. Reader baca buku TIDAK lagi memakai ini (layar penuh,
	# lihat _layout_baca_panel).
	var w := minf(vp.x * 0.92, maxf(lebar_target, lebar_target / s))
	var h := minf(vp.y * 0.92, maxf(tinggi_target, tinggi_target / s))
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -w / 2.0
	panel.offset_top = -h / 2.0
	panel.offset_right = w / 2.0
	panel.offset_bottom = h / 2.0


## Reader baca buku LAYAR PENUH (Mas 18 Nov 2026 ~07:11 WIB: "bisa
## ngga dimodel full? Bukan pop up gitu.. biar bisa dibaca jelas"):
## panel mengisi SELURUH viewport (anchor full rect, offset 0) —
## bukan lagi popup 720x640. Anchor membuat panel selalu mengikuti
## ukuran viewport (portrait maupun landscape) tanpa hitung ulang;
## dipanggil dari _build_baca_buku_panel + _layout_semua_panel
## (resize/open). Klik-di-luar tidak lagi bisa menutup (tidak ada
## "luar" — panel menutupi semuanya); tutup tetap via X / TUTUP /
## Escape, dan kunci gerak pemain tetap lewat visibilitas panel.
func _layout_baca_panel() -> void:
	if _baca_panel == null:
		return
	_baca_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_baca_panel.offset_left = 0.0
	_baca_panel.offset_top = 0.0
	_baca_panel.offset_right = 0.0
	_baca_panel.offset_bottom = 0.0


## Skala layar saat ini (stretch canvas_items): dipakai supaya panel
## overlay + fontnya berukuran FISIK yang sama di semua layar.
## Di desktop skala ~1.5, di HP portrait ~0.30, landscape ~0.54.
func _skala_layar() -> float:
	var s := get_viewport().get_screen_transform().x.x
	if s <= 0.01 or is_nan(s):
		return 1.0
	return clampf(s, 0.2, 3.0)


## Terapkan skala font + ukuran minimum tombol ke seluruh isi sebuah
## panel overlay (RONDE 4, Tara). Dijalankan tiap layout ulang
## (resize + 2 frame setelah panel dibuka). Aturan sama seperti
## login_metrics: ukuran target FISIK = ukuran desain, jadi ukuran
## kanvas = maks(dasar, dasar/skala). Di desktop (skala >= 1) tidak
## mengubah apa pun — ukuran desain dipakai apa adanya; di HP, font +
## tombol diperbesar supaya terbaca dan bisa diketuk (dulu font 26
## kanvas = 8 px fisik di portrait 390 px, tombol X 17x15 px fisik).
## Hanya berjalan di 4 panel overlay — panel login punya metriknya
## sendiri, HUD tidak disentuh.
func _terapkan_skala_panel(panel: PanelContainer) -> void:
	if panel == null:
		return
	var s := _skala_layar()
	for node in _semua_turunan(panel):
		if node is Label:
			var l := node as Label
			if l.has_meta("font_dasar"):
				var dasar := int(l.get_meta("font_dasar"))
				l.add_theme_font_size_override("font_size", maxi(dasar, int(ceil(float(dasar) / s))))
		elif node is Button:
			var b := node as Button
			if b.has_meta("font_dasar"):
				var dasar := int(b.get_meta("font_dasar"))
				b.add_theme_font_size_override("font_size", maxi(dasar, int(ceil(float(dasar) / s))))
			if not b.has_meta("min_dasar"):
				b.set_meta("min_dasar", b.custom_minimum_size)
			var md: Vector2 = b.get_meta("min_dasar")
			b.custom_minimum_size = Vector2(maxf(md.x, md.x / s), maxf(md.y, md.y / s))


func _semua_turunan(node: Node) -> Array[Node]:
	var hasil: Array[Node] = []
	for c in node.get_children():
		hasil.append(c)
		hasil.append_array(_semua_turunan(c))
	return hasil


## Layout ulang SEMUA panel overlay saat viewport berubah ukuran.
func _layout_semua_panel() -> void:
	_pusatkan_panel(_mission_panel)
	_pusatkan_panel(_peta_panel)
	_pusatkan_panel(_smartboard_panel)
	_layout_baca_panel()
	_pusatkan_panel(_dashboard_panel)
	_pusatkan_panel(_outfit_panel)
	# ROMBAKAN HUD v3: pop-up petunjuk ikut dipusatkan saat resize
	# (tinggi mengikuti isi — lihat _pusatkan_petunjuk_panel).
	_pusatkan_petunjuk_panel()
	_terapkan_skala_panel(_mission_panel)
	_terapkan_skala_panel(_peta_panel)
	_terapkan_skala_panel(_smartboard_panel)
	_terapkan_skala_panel(_baca_panel)
	_terapkan_skala_panel(_dashboard_panel)
	_terapkan_skala_panel(_outfit_panel)
	# RONDE 5: panel chat MLBB ikut di-layout ulang saat resize.
	_layout_chat_panel()
	# RONDE 6: panel aksi ikut di-layout ulang saat resize.
	_layout_aksi_panel()
	# RONDE 13: banner sholat ikut di-layout ulang saat resize.
	_layout_sholat_banner()
	# PETUNJUK MISI SANTRI BARU: banner petunjuk ikut di-layout ulang.
	_layout_petunjuk_misi_banner()


## Minimap GTA di HUD (RONDE 5): posisi + arah pemain diperbarui
## tiap frame oleh main.gd. Dipanggil walau panel peta tertutup —
## minimap SELALU terlihat saat main.
func update_minimap(data: Dictionary) -> void:
	if _minimap == null:
		return
	_minimap.data = data
	_minimap.queue_redraw()


# ---------- panel misi ----------
# RONDE 4 (15 Nov — Mas: kartu kuis terpotong & tidak bisa ditutup):
# panel misi memakai pola preset-sebelum-add_child yang SAMA seperti bug
# Kartu Santri dulu: dipusatkan dengan set_anchors_preset(PRESET_CENTER)
# SEBELUM add_child, saat ukuran panel masih 0 — offset semua 0, sudut
# kiri-atas panel jatuh di tengah viewport, isi menjorok keluar layar di
# HP dan tombol Tutup tidak terlihat. Perbaikan (sama seperti dashboard
# ronde 2): ukuran panel dihitung eksplisit dari viewport
# (_pusatkan_panel: maks 700x560, dibatasi 92% viewport), konten di
# dalam ScrollContainer supaya bisa di-scroll kalau lebih tinggi dari
# panel, header punya tombol X (56x48), dan panel bisa ditutup lewat X +
# Escape + klik-di-luar + tombol interaksi (toggle, main.gd _on_interact)
# + tombol Tutup di dalam.
func _build_mission_panel() -> void:
	_mission_panel = PanelContainer.new()
	_mission_panel.add_theme_stylebox_override("panel", _panel_style(Color("#f5f0e6"), EMAS))
	add_child(_mission_panel)
	_pusatkan_panel(_mission_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mission_panel.add_child(box)
	# Header: judul + tombol tutup X.
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	_mission_title = _make_label("", 26, HIJAU)
	_mission_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mission_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mission_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(_mission_title)
	_misi_x_btn = _make_button("X", Color("#888888"))
	_misi_x_btn.custom_minimum_size = Vector2(56, 48)
	_misi_x_btn.pressed.connect(close_mission)
	# RONDE PERBAIKAN (Gita, item 8 — pola yang sama): X misi menyala
	# saat TEKAN, seperti semua tombol tutup panel lain.
	_misi_x_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(_misi_x_btn)
	# Isi bisa di-scroll (materi + kuis bisa lebih tinggi dari panel di
	# HP portrait — tanpa scroll, tombol Tutup jatuh di luar layar).
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 10)
	isi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(isi)
	_materi_box = VBoxContainer.new()
	_materi_box.add_theme_constant_override("separation", 10)
	isi.add_child(_materi_box)
	_materi_judul = _make_label("", 22, GELAP)
	_materi_judul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_materi_box.add_child(_materi_judul)
	_materi_body = _make_label("", 19, GELAP)
	_materi_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_materi_box.add_child(_materi_body)
	var mulai_btn := _make_button("Mulai Kuis", HIJAU)
	mulai_btn.pressed.connect(_show_quiz)
	_materi_box.add_child(mulai_btn)
	var tutup1 := _make_button("Tutup", Color("#888888"))
	tutup1.pressed.connect(close_mission)
	# RONDE PERBAIKAN (Gita, item 8 — pola yang sama): Tutup materi
	# menyala saat TEKAN.
	tutup1.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_materi_box.add_child(tutup1)
	_kuis_box = VBoxContainer.new()
	_kuis_box.add_theme_constant_override("separation", 8)
	_kuis_box.visible = false
	isi.add_child(_kuis_box)
	_kuis_q = _make_label("", 21, GELAP)
	_kuis_q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_kuis_box.add_child(_kuis_q)
	for i in range(4):
		var ob := _make_button("", HIJAU_TERANG)
		ob.pressed.connect(_on_quiz_option.bind(i))
		_kuis_opts.append(ob)
		_kuis_box.add_child(ob)
	_kuis_feedback = _make_label("", 20, HIJAU)
	_kuis_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_kuis_box.add_child(_kuis_feedback)
	_kuis_materi_btn = _make_button("Baca Materi Lagi", Color("#888888"))
	_kuis_materi_btn.visible = false
	_kuis_materi_btn.pressed.connect(_show_materi)
	_kuis_box.add_child(_kuis_materi_btn)
	_kuis_tutup_btn = _make_button("Tutup", HIJAU)
	_kuis_tutup_btn.visible = false
	_kuis_tutup_btn.pressed.connect(close_mission)
	# RONDE PERBAIKAN (Gita, item 8 — pola yang sama): Tutup kuis
	# menyala saat TEKAN.
	_kuis_tutup_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_kuis_box.add_child(_kuis_tutup_btn)
func open_mission(misi: Dictionary) -> void:
	_current_misi = misi
	_mission_title.text = String(misi["judul"])
	_show_materi()
	_mission_panel.visible = true
	_minta_relayout()


func _show_materi() -> void:
	_materi_judul.text = String(_current_misi["materi_judul"])
	_materi_body.text = String(_current_misi["materi"])
	_materi_box.visible = true
	_kuis_box.visible = false


func _show_quiz() -> void:
	_kuis_q.text = String(_current_misi["kuis"])
	var opsi: Array = _current_misi["opsi"]
	for i in range(4):
		_kuis_opts[i].text = str(i + 1) + ". " + String(opsi[i])
		_kuis_opts[i].disabled = false
	_kuis_feedback.text = ""
	_kuis_materi_btn.visible = false
	_kuis_tutup_btn.visible = false
	_materi_box.visible = false
	_kuis_box.visible = true


func _on_quiz_option(index: int) -> void:
	for b in _kuis_opts:
		b.disabled = true
	quiz_answered.emit(index)


func quiz_result(benar: bool, poin: int) -> void:
	if benar:
		_kuis_feedback.text = "Benar! Kamu dapat +" + str(poin) + " poin. Misi selesai!"
		_kuis_feedback.add_theme_color_override("font_color", HIJAU)
		_kuis_tutup_btn.visible = true
		_kuis_materi_btn.visible = false
	else:
		_kuis_feedback.text = "Belum tepat. Baca lagi materinya, lalu coba jawab sekali lagi."
		_kuis_feedback.add_theme_color_override("font_color", Color("#a33b3b"))
		_kuis_materi_btn.visible = true


func is_mission_visible() -> bool:
	return _mission_panel.visible


func close_mission() -> void:
	_mission_panel.visible = false
	mission_closed.emit()



# ---------- panel peta ----------
# RONDE 4 (15 Nov — Mas minta opsi tampilkan peta): tombol "Peta" di
# HUD membuka overlay peta top-down — posisi santri, Surau, keempat
# lahan terkunci beserta ambangnya, posisi NPC, peti kayu, gerbang.
# Posisi santri + NPC diperbarui tiap frame selama panel terbuka
# (main.gd memanggil update_peta) — petanya hidup, bukan gambar mati.
# Ditutup lewat X + Escape + klik-di-luar + tombol Peta (toggle) +
# tombol Tutup. Ukuran sama seperti panel lain (_pusatkan_panel).
func _build_peta_panel() -> void:
	_peta_panel = PanelContainer.new()
	_peta_panel.add_theme_stylebox_override("panel", _panel_style(Color("#f5f0e6"), EMAS))
	add_child(_peta_panel)
	_pusatkan_panel(_peta_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_peta_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var judul := _make_label("PETA PESANTREN", 28, HIJAU)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(judul)
	# RONDE 5: tombol zoom peta (1.0x / 2.0x / 4.0x — saat zoom,
	# peta berpusat pada pemain supaya detail sekitar terlihat).
	# RONDE 8: tombol dinonaktifkan di ujung + label tingkat zoom —
	# supaya tidak ada lagi tombol yang tampak hidup tapi mati.
	var zoom_out_btn := _make_button("−", Color("#888888"))
	zoom_out_btn.custom_minimum_size = Vector2(48, 48)
	zoom_out_btn.pressed.connect(_peta_zoom_keluar)
	# RONDE PERBAIKAN (Gita, item 9): zoom menyala saat TEKAN (pola
	# yang sama seperti item 8 — tombol 48 px mati bila lepas bergeser).
	zoom_out_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(zoom_out_btn)
	_zoom_out_btn = zoom_out_btn
	_zoom_label = _make_label("1.0x", 16, Color("#666666"))
	header.add_child(_zoom_label)
	var zoom_in_btn := _make_button("+", Color("#888888"))
	zoom_in_btn.custom_minimum_size = Vector2(48, 48)
	zoom_in_btn.pressed.connect(_peta_zoom_masuk)
	zoom_in_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(zoom_in_btn)
	_zoom_in_btn = zoom_in_btn
	var x_btn := _make_button("X", Color("#888888"))
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.pressed.connect(close_peta)
	x_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(x_btn)
	_peta_map = PetaControl.new()
	# RONDE PERBAIKAN (Gita, item 11): jepit gambar ke rect peta —
	# tanpa ini label/kotak di luar bingkai (mis. sawah + label putra
	# saat tampilan putri di-zoom) tertumpah ke luar panel, menutupi
	# HUD/dunia (foto G5/G6 pertama). Berlaku juga untuk minimap.
	_peta_map.clip_contents = true
	# Min 280x200 (bukan 600x400): min panel = min peta + margin; 600
	# membuat panel peta 632 px lebar — meluber di HP portrait 390 px.
	# PetaControl menggambar dari ukuran aktualnya, jadi tetap mengisi
	# panel di desktop.
	_peta_map.custom_minimum_size = Vector2(280, 200)
	_peta_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_peta_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# CACAT #1 (Tara, 19 Nov 2026): peta + legenda dibungkus
	# ScrollContainer — min-size gabungan legenda (label diskala 3,1x
	# di HP portrait) dulu 1363 px dan memaksa panel meluber keluar
	# viewport 1280, tombol X jatuh di luar layar HP. ScrollContainer
	# tidak meneruskan min-size anak ke panel, jadi panel tetap di
	# ukuran _pusatkan_panel (1177x1739 kanvas) dan X selalu di dalam
	# layar. Header (judul + zoom + X) + tombol Tutup di LUAR scroll
	# supaya selalu terlihat; yang bisa di-scroll hanya peta + legenda.
	var gulung := ScrollContainer.new()
	gulung.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	gulung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gulung.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(gulung)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 8)
	isi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	isi.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gulung.add_child(isi)
	isi.add_child(_peta_map)
	# RONDE 7 (retest: semua ikon legenda tampil kotak kosong "▯" —
	# glif ● ■ ▢ ◆ ▨ ▲ TIDAK ADA di font game Baloo 2, jadi dirender
	# tofu): legenda kini swatch warna + teks biasa (tanpa glif
	# khusus) — kotak warna 16x16 + label, 3 kolom. Tidak ada lagi
	# karakter di luar ASCII + tanda baca dasar.
	var grid_legenda := GridContainer.new()
	grid_legenda.columns = 3
	grid_legenda.add_theme_constant_override("h_separation", 16)
	grid_legenda.add_theme_constant_override("v_separation", 4)
	isi.add_child(grid_legenda)
	for item in [
		["Kamu", Color("#0e7a5f")],
		["Santri NPC", Color("#1d4e6b")],
		["Surau", Color("#065f46")],
		["Cangkruk", Color("#8a5a2b")],
		["Lahan terkunci (angka = ambang)", Color("#d4a017")],
		["Peti Kayu", Color("#6b4423")],
		["Tujuan misi", Color("#f2c14e")],
		["Sawah", Color("#7fb8a8")],
		["Gunung", Color("#6b7a8a")],
	]:
		var sel := HBoxContainer.new()
		sel.add_theme_constant_override("separation", 6)
		grid_legenda.add_child(sel)
		var sw := ColorRect.new()
		sw.color = item[1]
		sw.custom_minimum_size = Vector2(16, 16)
		sel.add_child(sw)
		var lab := _make_label(String(item[0]), 15, Color("#666666"))
		# CACAT #1: autowrap supaya kolom legenda bisa menyempit ke
		# lebar panel — tanpa ini min-size grid = lebar teks penuh
		# ("Lahan terkunci (angka = ambang)" diskala 3,1x) dan panel
		# meluber keluar layar di HP portrait.
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sel.add_child(lab)
	var tutup := _make_button("Tutup", HIJAU)
	tutup.pressed.connect(close_peta)
	# RONDE PERBAIKAN (Gita, item 8): Tutup peta menyala saat TEKAN.
	tutup.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	box.add_child(tutup)


func is_peta_visible() -> bool:
	return _peta_panel.visible


func open_peta(data: Dictionary) -> void:
	_peta_data = data
	_peta_map.data = data
	_peta_map.queue_redraw()
	_peta_panel.visible = true
	_perbarui_tombol_zoom()
	_minta_relayout()


func update_peta(data: Dictionary) -> void:
	if not _peta_panel.visible:
		return
	_peta_data = data
	_peta_map.data = data
	_peta_map.queue_redraw()


func close_peta() -> void:
	_peta_panel.visible = false


## Zoom peta penuh (RONDE 5): langkah 1.0x -> 2.0x -> 4.0x.
## RONDE 8: tombol dinonaktifkan di ujung + label tingkat.
func _perbarui_tombol_zoom() -> void:
	if _zoom_in_btn != null:
		_zoom_in_btn.disabled = _peta_zoom_idx >= PETA_ZOOM.size() - 1
	if _zoom_out_btn != null:
		_zoom_out_btn.disabled = _peta_zoom_idx <= 0
	if _zoom_label != null:
		_zoom_label.text = "%.1fx" % PETA_ZOOM[_peta_zoom_idx]


func _peta_zoom_masuk() -> void:
	_peta_zoom_idx = mini(_peta_zoom_idx + 1, PETA_ZOOM.size() - 1)
	_peta_map.zoom = PETA_ZOOM[_peta_zoom_idx]
	_peta_map.queue_redraw()
	_perbarui_tombol_zoom()


func _peta_zoom_keluar() -> void:
	_peta_zoom_idx = maxi(_peta_zoom_idx - 1, 0)
	_peta_map.zoom = PETA_ZOOM[_peta_zoom_idx]
	_peta_map.queue_redraw()
	_perbarui_tombol_zoom()


## Peta top-down yang digambar kode (tanpa aset gambar): latar pasir,
## grid tiap 14 m, jalan, pagar hijau, Surau, kamar cangkruk (RONDE 6),
## lahan terkunci + ambang, peti kayu, NPC (nama + titik biru), santri
## (titik hijau + "Kamu"). Utara di atas (z negatif = atas). Data:
## {"player": Vector2, "npcs": [{"nama", "pos"}], "surau": Vector2,
## "cangkruk": Vector2, "peti": Vector2, "half": float} — lahan dibaca
## langsung dari MissionData.
## RONDE 5: + marker TUJUAN misi aktif (wajik emas), sawah (tenggara),
## gunung (segitiga abu-abu di kejauhan), dan ZOOM (1.0 / 4.0 — saat
## zoom, peta berpusat pada pemain, bukan tengah peta). Dulu ada 2.0x
## di tengah, tapi dihapus: di 2.0x cluster lahan (~30x43 px) masih
## jauh lebih kecil dari labelnya (~100-190 px), label tetap menumpuk
## (foto ronde 5) — 1.0x = keseluruhan tanpa label, 4.0x = detail
## dengan label terbaca. Label teks hanya tampil saat zoom > 1.0, dan
## label 4 lahan digeser diagonal supaya tidak menumpuk di tengah.
class PetaControl extends Control:
	var data: Dictionary = {}
	var zoom: float = 1.0
	var _asal: Vector2 = Vector2.ZERO
	# RONDE 7: label yang sudah digambar di frame ini (untuk
	# de-collision — label yang bertumpuk digeser ke bawah).
	var _label_rects: Array[Rect2] = []
	# RONDE 8: rect GERBANG terakhir (untuk tes: label ini WAJIB dalam
	# batas di semua zoom; label lain boleh keluar layar saat zoom —
	# itu perilaku normal peta berpusat-pemain).
	var _rect_gerbang := Rect2()
	# RONDE 8: rect yang harus DIHINDARI label (marker pemain + tujuan)
	# — dipisah dari _label_rects supaya tes tumpang-tindih label tidak
	# salah menuduh saat pemain berdiri tepat di atas tujuan misi.
	var _label_hindari: Array[Rect2] = []

	# RONDE PERBAIKAN (Gita, item 11): gedung kampus putri untuk peta
	# besar + minimap — [label, posisi (x,z), ukuran (m)]. Sumber:
	# konstanta KampusPutri (bukan data main.gd, supaya peta tetap
	# lengkap walau main.gd belum mengirim kunci gedung putri).
	const GEDUNG_PUTRI: Array = [
		["CANGKRUK PUTRI", Vector2(128, -12), Vector2(10, 8)],
		["KELAS PUTRI", Vector2(130, 0), Vector2(10, 8)],
		# ROMBAKAN HUD v3 (Tara, 18 Nov 2026 — bonus, menunggu HUD
		# mendarat): cangkang Asrama Putri baru 21,5x12 m di (155,0)
		# (P1 Gilang) — dulu 12x8 m di (152,0).
		["ASRAMA PUTRI", Vector2(155, 0), Vector2(21.5, 12)],
		["MADRASAH", Vector2(152, -12), Vector2(10, 8)],
		["STUDIO", Vector2(166, -12), Vector2(10, 8)],
		["KANTOR USTADZAH", Vector2(150, -28), Vector2(8, 6)],
		["POS JAGA", Vector2(160, -35), Vector2(3, 3)],
	]
	# MARKER ASRAMA PUTRA (Cakra, 18 Nov 13:19 — Mas: "Tambah"):
	# gedung Asrama Putra harus bertanda di peta besar + minimap
	# setelah kotak emas plot-nya hilang (tahap 2 "Asrama" di
	# MissionData.GROWTH_STAGES sudah "dibangun"). Posisi +
	# ukuran dari AsramaPutra (pos (-24,0,10), badan 18x12 m) —
	# ditulis literal mengikuti pola GEDUNG_PUTRI di atas.
	const GEDUNG_PUTRA: Array = [
		["ASRAMA PUTRA", Vector2(-24, 10), Vector2(18, 12)],
	]
	# RONDE PERBAIKAN (Gita, item 11): bingkai tampilan peta besar.
	# Putra: perilaku lama — seluruh dunia (half 400, pusat 0,0) di
	# zoom 1.0x; zoom > 1 berpusat pada pemain. Putri (pemain x > 60,
	# di timur tembok x=14): zoom 1.0x membingkai kampus putri (pusat
	# (147.5,-15), setengah 55 m) supaya kampus putri mengisi peta,
	# bukan jadi bintik 32 px di tepi (retest Ronde 23: di peta 660 px
	# kampus putri cuma 32 px lebar); zoom > 1 berpusat pada pemain
	# dengan skala dari setengah putri. Fungsi murni (kecuali membaca
	# data/zoom/size) supaya bisa dites headless.
	func bingkai_peta() -> Dictionary:
		var half := float(data.get("half", 400.0))
		var putri := false
		if data.has("player"):
			putri = (data["player"] as Vector2).x > 60.0
		var pusat := Vector2.ZERO
		var setengah := half
		if putri:
			pusat = Vector2(147.5, -15.0)
			setengah = 55.0
		var s := minf(size.x, size.y) / (setengah * 2.0 + 8.0) * zoom
		var asal := pusat
		if zoom > 1.0 and data.has("player"):
			asal = data["player"]
		return {"putri": putri, "pusat": pusat, "setengah": setengah, "skala": s, "asal": asal}

	func _draw() -> void:
		var half := float(data.get("half", 400.0))
		var bingkai := bingkai_peta()
		var putri: bool = bingkai["putri"]
		var pusat: Vector2 = bingkai["pusat"]
		var setengah: float = bingkai["setengah"]
		var s: float = bingkai["skala"]
		var c := size * 0.5
		_label_rects.clear()
		_label_hindari.clear()
		# Saat zoom, peta berpusat pada pemain (bukan tengah peta);
		# di zoom 1.0x putri, berpusat pada kampus putri (bingkai).
		_asal = bingkai["asal"]
		# RONDE 8: cadangkan rect marker pemain + tujuan misi di
		# _label_hindari SEBELUM label digambar — de-collision _teks
		# menghindarinya (retest: "RU" RUANG KELAS tertutup titik hijau
		# pemain karena marker digambar SETELAH label, menutupinya).
		if data.has("player"):
			var ppos0 := _ke_peta(data["player"], c, s)
			_label_hindari.append(Rect2(ppos0 - Vector2(12, 12), Vector2(24, 24)))
		if data.has("target"):
			var tg0: Vector2 = data["target"]
			if tg0 != Vector2.INF:
				var tp0 := _ke_peta(tg0, c, s)
				_label_hindari.append(Rect2(tp0 - Vector2(13, 13), Vector2(26, 26)))
		# RONDE 5 (perbaikan dari foto): di zoom 1.0x, seluruh pesantren
		# (inti ~50 m) cuma ~30 px — label nama lahan/Surau/NPC/Kamu/
		# SAWAH/TUJUAN menumpuk jadi gumpalan tak terbaca di tengah.
		# Karena itu label teks HANYA tampil saat zoom >= 1.6x; di 1.0x
		# yang tampil cuma markernya (kotak/titik/wajik) + GERBANG
		# (di tepi, tidak menumpuk). Ini perilaku peta game pada umumnya.
		var tampil_label := zoom > 1.0 or putri
		# Latar pasir.
		draw_rect(Rect2(Vector2.ZERO, size), Color("#e3d3ae"))
		# Grid tiap 14 m — hanya sepanjang bingkai tampilan (putra:
		# seluruh dunia seperti dulu; putri: kampus putri saja).
		var grid_col := Color(0, 0, 0, 0.07)
		var grid_lo := pusat - Vector2(setengah, setengah)
		var grid_hi := pusat + Vector2(setengah, setengah)
		var g := grid_lo.x
		while g <= grid_hi.x:
			draw_line(_ke_peta(Vector2(g, grid_lo.y), c, s), _ke_peta(Vector2(g, grid_hi.y), c, s), grid_col, 1.0)
			g += 14.0
		g = grid_lo.y
		while g <= grid_hi.y:
			draw_line(_ke_peta(Vector2(grid_lo.x, g), c, s), _ke_peta(Vector2(grid_hi.x, g), c, s), grid_col, 1.0)
			g += 14.0
		# Jalan: vertikal x=0 (gerbang-surau-utara) + horizontal z=0.
		var jalan := Color("#cbb27f")
		draw_line(_ke_peta(Vector2(0, -half), c, s), _ke_peta(Vector2(0, half), c, s), jalan, 3.0 * s)
		draw_line(_ke_peta(Vector2(-28, 0), c, s), _ke_peta(Vector2(28, 0), c, s), jalan, 2.5 * s)
		# RONDE PERBAIKAN (Gita, item 11): jalan internal kampus putri
		# (x=142, z -35..+14) — dari KampusPutri.JALAN_INTERNAL_X.
		draw_line(_ke_peta(Vector2(KampusPutri.JALAN_INTERNAL_X, -35), c, s), _ke_peta(Vector2(KampusPutri.JALAN_INTERNAL_X, 14), c, s), jalan, 2.5 * s)
		# Pagar hijau (batas tanah 800 m — hanya garis peta, bukan pagar
		# di dunia: RONDE 5 dunia tanpa pagar, ini tepi tanahnya).
		# Di tampilan putri tidak digambar: batasnya adalah tembok
		# keliling (garis coklat di bawah), bukan tepi tanah 800 m.
		if not putri:
			draw_rect(Rect2(_ke_peta(Vector2(-half, -half), c, s), Vector2(half * 2.0 * s, half * 2.0 * s)), Color("#3f7d44"), false, 3.0)
		# Sawah (tenggara): petak biru-hijau + label.
		var sawah_pos: Vector2 = data.get("sawah_pos", PesantrenBuilder.SAWAH_POS)
		var sawah_size: Vector2 = data.get("sawah_size", PesantrenBuilder.SAWAH_SIZE)
		draw_rect(Rect2(_ke_peta(sawah_pos - sawah_size * 0.5, c, s), sawah_size * s), Color("#7fb8a8"))
		if tampil_label:
			_teks("SAWAH", _ke_peta(sawah_pos, c, s), Color("#065f46"), 12)
		# Gunung di kejauhan (segitiga abu-abu).
		for gunung in data.get("gunung", []):
			var sudut := deg_to_rad(float(gunung["sudut"]))
			var jarak: float = gunung["jarak"]
			var gp := Vector2(sin(sudut) * jarak, -cos(sudut) * jarak)
			var gc := _ke_peta(gp, c, s)
			draw_colored_polygon(PackedVector2Array([gc + Vector2(0, -7), gc + Vector2(7, 6), gc + Vector2(-7, 6)]), Color("#6b7a8a"))
		# Surau (12x10 m). Teks "SURAU" TIDAK digambar: di zoom, posisinya
		# (0,-12) tepat di antara label Masjid dan wajik tujuan — teksnya
		# menumpuk di tengah (foto ronde 5). Kotak hijau + legenda cukup.
		var surau := Vector2(0, -12)
		if data.has("surau"):
			surau = data["surau"]
		# RONDE 14: Surau diputar -25° (mihrab menghadap kiblat 295°) —
		# kotaknya digambar sebagai poligon miring, bukan persegi tegak.
		# Rotasi 2D mengikuti rotasi 3D: (x,z) -> (x·cos+z·sin,
		# -x·sin+z·cos) dengan sumbu peta y = z dunia.
		var rot_surau := deg_to_rad(float(data.get("surau_rotasi", 0.0)))
		var cs := cos(rot_surau)
		var sn := sin(rot_surau)
		var sudut_surau := PackedVector2Array()
		for pojok in [Vector2(-6, -5), Vector2(6, -5), Vector2(6, 5), Vector2(-6, 5)]:
			var putar := Vector2(pojok.x * cs + pojok.y * sn, -pojok.x * sn + pojok.y * cs)
			sudut_surau.append(_ke_peta(surau + putar, c, s))
		draw_colored_polygon(sudut_surau, Color("#065f46"))
		# Kamar cangkruk (RONDE 6 revisi 23:01 WIB, pos ronda 10x8 m kayu — kotak coklat + label).
		var cangkruk := Vector2(14, -14)
		if data.has("cangkruk"):
			cangkruk = data["cangkruk"]
		draw_rect(Rect2(_ke_peta(cangkruk + Vector2(-5, -4), c, s), Vector2(10 * s, 8 * s)), Color("#8a5a2b"))
		if tampil_label:
			_teks("CANGKRUK", _ke_peta(cangkruk + Vector2(0, 10), c, s), Color("#6b4423"), 12)
		# RONDE 20 — Musholla Ar-Raudhah (putri, 10x8 m, diputar -25°
		# seperti Surau) — poligon miring zamrud terang + label.
		var musholla := Vector2(18, -24)
		if data.has("musholla"):
			musholla = data["musholla"]
		var rot_musholla := deg_to_rad(float(data.get("musholla_rotasi", 0.0)))
		var cm := cos(rot_musholla)
		var sm := sin(rot_musholla)
		var sudut_musholla := PackedVector2Array()
		for pojok in [Vector2(-5, -4), Vector2(5, -4), Vector2(5, 4), Vector2(-5, 4)]:
			var putar := Vector2(pojok.x * cm + pojok.y * sm, -pojok.x * sm + pojok.y * cm)
			sudut_musholla.append(_ke_peta(musholla + putar, c, s))
		draw_colored_polygon(sudut_musholla, Color("#0e7a5f"))
		# RONDE PERBAIKAN (Gita, item 11): gedung kampus putri —
		# kotak krem berbingkai zamrud. DUA PASS: semua kotak dulu,
		# semua label kemudian — satu pass membuat kotak gedung yang
		# digambar belakangan menutupi label gedung sebelumnya
		# (foto G5 pertama: "MUSHOLLA" tinggal "HOLLA", "CANGKRUK
		# PUTRI" terpotong). Label Musholla ikut pass label supaya
		# tidak ada kotak yang menutupinya. Label gedung putri HANYA
		# di tampilan putri — di tampilan putra (zoom 2.0x) ketujuh
		# label itu ikut menumpuk di gumpalan label tengah (foto G4
		# pertama); kotaknya tetap tergambar di mana-mana.
		for gedung in GEDUNG_PUTRI:
			var gpos: Vector2 = gedung[1]
			var gukuran: Vector2 = gedung[2]
			var gsudut := _ke_peta(gpos - gukuran * 0.5, c, s)
			draw_rect(Rect2(gsudut, gukuran * s), Color("#e8dcc0"))
			draw_rect(Rect2(gsudut, gukuran * s), Color("#065f46"), false, 1.5)
		# MARKER ASRAMA PUTRA (Cakra, 18 Nov 13:19): kotaknya
		# tergambar di mana-mana seperti gedung putri (pass kotak).
		for gedung in GEDUNG_PUTRA:
			var gpos: Vector2 = gedung[1]
			var gukuran: Vector2 = gedung[2]
			var gsudut := _ke_peta(gpos - gukuran * 0.5, c, s)
			draw_rect(Rect2(gsudut, gukuran * s), Color("#e8dcc0"))
			draw_rect(Rect2(gsudut, gukuran * s), Color("#065f46"), false, 1.5)
		if tampil_label:
			_teks("MUSHOLLA", _ke_peta(musholla + Vector2(0, 9), c, s), Color("#065f46"), 12)
		if putri:
			for gedung in GEDUNG_PUTRI:
				var gpos2: Vector2 = gedung[1]
				var gukuran2: Vector2 = gedung[2]
				_teks(String(gedung[0]), _ke_peta(gpos2 + Vector2(0, gukuran2.y * 0.5 + 5), c, s), Color("#065f46"), 12)
		# MARKER ASRAMA PUTRA (Cakra, 18 Nov 13:19): label tampil
		# saat tampil_label (zoom detail), seperti MUSHOLLA/CANGKRUK
		# — di zoom 1.0x hanya kotaknya yang tampil (aturan label).
		if tampil_label:
			for gedung in GEDUNG_PUTRA:
				var gpos2: Vector2 = gedung[1]
				var gukuran2: Vector2 = gedung[2]
				_teks(String(gedung[0]), _ke_peta(gpos2 + Vector2(0, gukuran2.y * 0.5 + 5), c, s), Color("#065f46"), 12)
		# RONDE 21 — Tembok pemisah (garis coklat mengikuti
		# TEMBOK_GARIS x=14) + gerbang di (14,0) + pos jaga + pos
		# satpam. Kunci lama "pagar_garis" dipertahankan sebagai
		# fallback (data Ronde 20). Label gerbang "GERBANG BATAS"
		# (beda dari "GERBANG" selatan = gerbang utama kampus, di
		# tepi bawah peta).
		if data.has("tembok_garis") or data.has("pagar_garis"):
			var garis: Array = data.get("tembok_garis", data.get("pagar_garis", []))
			for i in garis.size() - 1:
				var a: Vector2 = garis[i]
				var b: Vector2 = garis[i + 1]
				draw_line(_ke_peta(a, c, s), _ke_peta(b, c, s), Color("#6b4423"), 2.0)
		# RONDE 22 — Tembok keliling kampus putri (persegi x 115..180,
		# z -52..+22) + gerbang barat (115,0). Kunci "tembok_keliling_garis"
		# dari dict build (Raka); .get() + fallback kosong supaya peta
		# tidak crash sebelum kunci itu mendarat (pola Ronde 21).
		# RONDE PERBAIKAN (Gita, item 11): fallback kini KONSTANTA
		# TembokPutri, bukan kosong — main.gd _data_peta() sampai hari
		# ini TIDAK mengirim kunci ini, jadi tanpa fallback tembok
		# keliling tidak pernah tergambar di peta mana pun.
		var keliling: Array = data.get("tembok_keliling_garis", TembokPutri.KELILING_GARIS)
		for i in keliling.size() - 1:
			var ka: Vector2 = keliling[i]
			var kb: Vector2 = keliling[i + 1]
			draw_line(_ke_peta(ka, c, s), _ke_peta(kb, c, s), Color("#6b4423"), 2.0)
		var gpp: Vector3 = data.get("gerbang_putri_pos", TembokPutri.GERBANG_PUTRI_POS)
		var gputri := Vector2(gpp.x, gpp.z)
		draw_rect(Rect2(_ke_peta(gputri + Vector2(-2, -2), c, s), Vector2(4 * s, 4 * s)), Color("#d4a017"))
		if tampil_label:
			var r_gp := _teks("GERBANG PUTRI", _ke_peta(gputri + Vector2(0, 8), c, s), Color("#6b4423"), 12)
			# Di tampilan putri, rect gerbang putri yang dipakai tes
			# Ronde 8 sebagai "gerbang wajib dalam batas".
			if putri:
				_rect_gerbang = r_gp
		var gerbang := Vector2(0, 0)
		if data.has("gerbang_pos"):
			var gp3: Vector3 = data["gerbang_pos"]
			gerbang = Vector2(gp3.x, gp3.z)
		draw_rect(Rect2(_ke_peta(gerbang + Vector2(-2, -2), c, s), Vector2(4 * s, 4 * s)), Color("#d4a017"))
		if tampil_label:
			_teks("GERBANG BATAS", _ke_peta(gerbang + Vector2(0, 8), c, s), Color("#6b4423"), 12)
		for pos_jaga in data.get("pos_jaga", []):
			var pj: Vector3 = pos_jaga
			var pj2 := Vector2(pj.x, pj.z)
			draw_rect(Rect2(_ke_peta(pj2 + Vector2(-1.5, -1.5), c, s), Vector2(3 * s, 3 * s)), Color("#3a2a1a"))
			if tampil_label:
				_teks("POS JAGA", _ke_peta(pj2 + Vector2(0, 6), c, s), Color("#3a2a1a"), 12)
		if data.has("pos_satpam"):
			var ps: Vector3 = data["pos_satpam"]
			var ps2 := Vector2(ps.x, ps.z)
			draw_rect(Rect2(_ke_peta(ps2 + Vector2(-1.5, -1.5), c, s), Vector2(3 * s, 3 * s)), Color("#3a2a1a"))
			if tampil_label:
				# Label di utara pos (3,-3) — di selatan (3,9) menabrak
				# label GERBANG BATAS (0,8).
				_teks("SATPAM", _ke_peta(ps2 + Vector2(0, -6), c, s), Color("#3a2a1a"), 12)
		# Lahan terkunci (tahap > 0, status "terkunci"): kotak emas + nama
		# + ambang. Tahap yang sudah dibangun (status "dibangun") tidak
		# digambar lagi sebagai lahan terkunci.
		for stage in MissionData.GROWTH_STAGES:
			if int(stage["tahap"]) == 0:
				continue
			if String(stage["status"]) == "dibangun":
				continue
			var plot: Vector2 = stage["plot"]
			draw_rect(Rect2(_ke_peta(plot + Vector2(-5, -4), c, s), Vector2(10 * s, 8 * s)), Color("#d4a017"), false, 2.0)
			if tampil_label:
				# Label SATU baris "NAMA (ambang)" + geser DIAGONAL per
				# lahan — dua baris + geser lurus masih menumpuk (foto
				# ronde 5, zoom 2.0x): pasangan timur-barat (Asrama di
				# (-16,0), Ruang Kelas di (16,0)) cuma 32 m apart,
				# labelnya ~100 px — tanpa pisah vertikal pasti tabrakan.
				# Asrama ke kiri-atas, Kelas ke kanan-bawah, Masjid ke
				# atas, Perpus ke bawah.
				var geser := Vector2.ZERO
				match String(stage["nama"]):
					"Masjid Besar":
						geser = Vector2(0, -12)
					"Perpustakaan & Taman":
						geser = Vector2(0, 12)
					"Ruang Kelas":
						geser = Vector2(12, 8)
					"Asrama":
						geser = Vector2(-12, -8)
				_teks("%s (%d)" % [String(stage["nama"]).to_upper(), int(stage["ambang_santri"])], _ke_peta(plot + geser, c, s), Color("#065f46"), 12)
		# Peti kayu (wajik coklat).
		var peti := Vector2(6, 10)
		if data.has("peti"):
			peti = data["peti"]
		var pp := _ke_peta(peti, c, s)
		draw_colored_polygon(PackedVector2Array([pp + Vector2(0, -6), pp + Vector2(6, 0), pp + Vector2(0, 6), pp + Vector2(-6, 0)]), Color("#8a5a2b"))
		# Tujuan misi aktif (wajik emas besar). Teks "TUJUAN" TIDAK
		# digambar: posisinya di tengah cluster, menumpuk dengan label
		# lain (foto ronde 5). Wajik emas + legenda cukup.
		if data.has("target"):
			var target: Vector2 = data["target"]
			if target != Vector2.INF:
				var tp := _ke_peta(target, c, s)
				draw_colored_polygon(PackedVector2Array([tp + Vector2(0, -9), tp + Vector2(9, 0), tp + Vector2(0, 9), tp + Vector2(-9, 0)]), Color("#f2c14e"))
				draw_arc(tp, 12.0, 0, TAU, 24, Color("#d4a017"), 2.0)
		# NPC santri.
		for npc in data.get("npcs", []):
			var np: Vector2 = npc["pos"]
			var npos := _ke_peta(np, c, s)
			draw_circle(npos, 6.0, Color("#1d4e6b"))
			if tampil_label:
				_teks(String(npc["nama"]), npos + Vector2(9, 4), Color("#1d4e6b"), 12)
		# Pemain (titik hijau + cincin putih). Teks "Kamu" TIDAK digambar:
		# titiknya di tengah cluster, teksnya menumpuk dengan label lain
		# (foto ronde 5). Titik hijau + legenda cukup.
		var pl := Vector2.ZERO
		if data.has("player"):
			pl = data["player"]
		var ppos := _ke_peta(pl, c, s)
		draw_circle(ppos, 8.0, Color("#0e7a5f"))
		draw_arc(ppos, 8.0, 0, TAU, 24, Color.WHITE, 2.0)
		# Gerbang (selatan). RONDE 7: posisi y half-16 (dulu half-2) —
		# label terpotong setengah di tepi bawah peta karena baseline
		# teks jatuh di luar rect kontrol; kini seluruh huruf masuk.
		# RONDE 8: + jepit ke tepi (jepit_tepi=true) — saat zoom maks
		# peta berpusat pada pemain dan GERBANG (384 m jauhnya) jatuh
		# jauh di luar layar sehingga HILANG; kini dijepit ke tepi
		# bawah yang terlihat. Di zoom 1.0x juga tidak lagi bersentuhan
		# bingkai hijau bawah grid.
		# RONDE PERBAIKAN (Gita, item 11): HANYA di tampilan putra —
		# di tampilan putri, gerbang selatan putra 384 m jauhnya akan
		# dijepit ke tepi bawah peta putri dan menyesatkan (itu bukan
		# gerbang kampus putri; gerbang putri sudah digambar di atas).
		if not putri:
			_rect_gerbang = _teks("GERBANG", _ke_peta(Vector2(0, half - 16), c, s), Color("#3f7d44"), 12, true)

	func _ke_peta(w: Vector2, c: Vector2, s: float) -> Vector2:
		return Vector2(c.x + (w.x - _asal.x) * s, c.y + (w.y - _asal.y) * s)

	func _teks(teks: String, pos: Vector2, warna: Color, ukuran: int, jepit_tepi: bool = false) -> Rect2:
		var font := Palette.FONT_GAME  # RONDE 6: font game (Baloo 2 Bold), bukan fallback Arial
		var lebar := font.get_string_size(teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran).x
		# RONDE 7 (retest: label bertumpuk saat zoom-in — Bilal /
		# CANGKRUK / RUANG KELAS di sekitar pemain): de-collision
		# sederhana — label yang rect-nya menabrak label yang sudah
		# digambar digeser ke bawah sampai bebas (maks 6 geseran).
		# Label plot/surau digambar dulu, nama NPC belakangan, jadi
		# yang mengalah adalah label yang datang belakangan.
		var p := pos
		var ok := false
		for _i in range(6):
			var r := Rect2(p.x - lebar / 2.0 - 2.0, p.y - float(ukuran) * 0.75, lebar + 4.0, float(ukuran) + 4.0)
			var tabrakan := false
			for lama in _label_rects:
				if lama.intersects(r):
					tabrakan = true
					break
			if not tabrakan:
				for hindari in _label_hindari:
					if hindari.intersects(r):
						tabrakan = true
						break
			if not tabrakan:
				ok = true
				break
			p.y += float(ukuran) + 4.0
		# RONDE 8 (jepit_tepi, dipakai GERBANG): jepit posisi akhir ke
		# dalam rect kontrol supaya label tidak terpotong tepi / hilang
		# saat zoom (posisi dunia jauh di luar layar). Dijepit SETELAH
		# de-collision supaya tidak kembali keluar karena geseran.
		# Batas dihitung dari RECT label (p.y-9 s.d. p.y+7 untuk ukuran
		# 12), bukan dari titik tengah — jepit ke size-4 saja masih
		# menyisakan 3 px terpotong di bawah (terukur di tes).
		if jepit_tepi:
			p.x = clampf(p.x, lebar / 2.0 + 2.0, size.x - lebar / 2.0 - 2.0)
			p.y = clampf(p.y, float(ukuran) * 0.75, size.y - float(ukuran) * 0.25 - 4.0)
		var rect_akhir := Rect2(p.x - lebar / 2.0 - 2.0, p.y - float(ukuran) * 0.75, lebar + 4.0, float(ukuran) + 4.0)
		if ok:
			_label_rects.append(rect_akhir)
		draw_string(font, p + Vector2(-lebar / 2.0, ukuran * 0.35), teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran, warna)
		return rect_akhir


## Minimap GTA di HUD (RONDE 5): lingkaran hidup heading-up seperti
## GTA V — panah pemain SELALU menghadap ke atas, dunia yang berputar
## di sekelilingnya. Menampilkan area ~45 m di sekitar pemain: jalan,
## Surau, lahan terkunci, peti, NPC, tujuan misi aktif (dijepit ke tepi
## lingkaran bila jauh + berdenyut), sawah, utara (huruf U di tepi).
## Data: sama seperti PetaControl + "yaw" (arah hadap pemain, radian).
class MinimapControl extends Control:
	var data: Dictionary = {}
	var jarak_pandang: float = 45.0

	func _draw() -> void:
		var r := minf(size.x, size.y) * 0.5
		var c := size * 0.5
		if r < 10.0:
			return
		# Latar bulat hijau gelap semi-transparan.
		draw_circle(c, r, Color(0.05, 0.16, 0.13, 0.88))
		var pemain: Vector2 = data.get("player", Vector2.ZERO)
		var yaw: float = data.get("yaw", 0.0)
		var s := r / jarak_pandang
		# Jalan (dipotong ke dalam lingkaran): utara-selatan x=0,
		# timur-barat z=0, dan jalan ke sawah z=30.
		var jalan := Color("#cbb27f")
		for seg in [[Vector2(0, -400), Vector2(0, 400)], [Vector2(-400, 0), Vector2(400, 0)], [Vector2(0, 30), Vector2(32, 30)]]:
			var a := _ke_mini(seg[0], pemain, yaw, s, c)
			var b := _ke_mini(seg[1], pemain, yaw, s, c)
			var klip := _klip_lingkaran(a, b, c, r - 2.0)
			if klip.size() == 2:
				draw_line(klip[0], klip[1], jalan, 3.0)
		# Sawah (titik biru-hijau bila dalam jangkauan).
		if data.has("sawah_pos"):
			var sp: Vector2 = data["sawah_pos"]
			var sm := _ke_mini_jepit(sp, pemain, yaw, s, c, r)
			if sm != Vector2.INF:
				draw_circle(sm, 5.0, Color("#7fb8a8"))
		# Lahan terkunci (kotak emas). Tahap yang sudah dibangun
		# (status "dibangun") tidak digambar lagi sebagai lahan terkunci.
		for stage in MissionData.GROWTH_STAGES:
			if int(stage["tahap"]) == 0:
				continue
			if String(stage["status"]) == "dibangun":
				continue
			var plot: Vector2 = stage["plot"]
			var pm := _ke_mini_jepit(plot, pemain, yaw, s, c, r)
			if pm != Vector2.INF:
				draw_rect(Rect2(pm - Vector2(4, 4), Vector2(8, 8)), Color("#d4a017"))
		# Surau (kotak hijau).
		var surau: Vector2 = data.get("surau", Vector2(0, -12))
		var sum := _ke_mini_jepit(surau, pemain, yaw, s, c, r)
		if sum != Vector2.INF:
			draw_rect(Rect2(sum - Vector2(5, 5), Vector2(10, 10)), Color("#0e7a5f"))
		# Kamar cangkruk (RONDE 6 revisi 23:01 WIB — kotak coklat, pos ronda 10x8 m).
		var cangkruk: Vector2 = data.get("cangkruk", Vector2(14, -14))
		var cm := _ke_mini_jepit(cangkruk, pemain, yaw, s, c, r)
		if cm != Vector2.INF:
			draw_rect(Rect2(cm - Vector2(5, 5), Vector2(10, 10)), Color("#8a5a2b"))
		# RONDE 20 — Musholla Ar-Raudhah (putri, kotak hijau seperti
		# Surau) + pagar putra/putri (garis coklat, diklip lingkaran)
		# + gerbang (kotak emas) + pos jaga + pos satpam (kotak gelap).
		var musholla: Vector2 = data.get("musholla", Vector2(18, -24))
		var mm := _ke_mini_jepit(musholla, pemain, yaw, s, c, r)
		if mm != Vector2.INF:
			draw_rect(Rect2(mm - Vector2(5, 5), Vector2(10, 10)), Color("#0e7a5f"))
		# RONDE PERBAIKAN (Gita, item 11): gedung kampus putri di
		# minimap (kotak krem 8x8) — tanpa ini minimap santriwati
		# hanya menampilkan Musholla di tengah area kosong.
		for gedung in PetaControl.GEDUNG_PUTRI:
			var gpos: Vector2 = gedung[1]
			var gm := _ke_mini_jepit(gpos, pemain, yaw, s, c, r)
			if gm != Vector2.INF:
				draw_rect(Rect2(gm - Vector2(4, 4), Vector2(8, 8)), Color("#e8dcc0"))
		# MARKER ASRAMA PUTRA (Cakra, 18 Nov 13:19 — Mas: "Tambah"):
		# kotak krem 8x8 seperti gedung putri, bila dalam jangkauan.
		for gedung in PetaControl.GEDUNG_PUTRA:
			var gpos: Vector2 = gedung[1]
			var gapm := _ke_mini_jepit(gpos, pemain, yaw, s, c, r)
			if gapm != Vector2.INF:
				draw_rect(Rect2(gapm - Vector2(4, 4), Vector2(8, 8)), Color("#e8dcc0"))
		if data.has("tembok_garis") or data.has("pagar_garis"):
			var garis: Array = data.get("tembok_garis", data.get("pagar_garis", []))
			for i in garis.size() - 1:
				var a := _ke_mini(garis[i], pemain, yaw, s, c)
				var b := _ke_mini(garis[i + 1], pemain, yaw, s, c)
				var klip := _klip_lingkaran(a, b, c, r - 2.0)
				if klip.size() == 2:
					draw_line(klip[0], klip[1], Color("#6b4423"), 2.0)
		# RONDE 22 — Tembok keliling kampus putri (persegi x 115..180,
		# z -52..+22) + gerbang barat (115,0). Defensif seperti peta
		# besar: .get() + fallback kosong (pola Ronde 21).
		# RONDE PERBAIKAN (Gita, item 11): fallback kini KONSTANTA
		# TembokPutri (lihat peta besar — main.gd tidak mengirim kunci
		# ini, jadi fallback kosong membuat tembok tidak pernah muncul).
		var keliling: Array = data.get("tembok_keliling_garis", TembokPutri.KELILING_GARIS)
		for i in keliling.size() - 1:
			var ka := _ke_mini(keliling[i], pemain, yaw, s, c)
			var kb := _ke_mini(keliling[i + 1], pemain, yaw, s, c)
			var kklip := _klip_lingkaran(ka, kb, c, r - 2.0)
			if kklip.size() == 2:
				draw_line(kklip[0], kklip[1], Color("#6b4423"), 2.0)
		var gpp: Vector3 = data.get("gerbang_putri_pos", TembokPutri.GERBANG_PUTRI_POS)
		var gpm := _ke_mini_jepit(Vector2(gpp.x, gpp.z), pemain, yaw, s, c, r)
		if gpm != Vector2.INF:
			draw_rect(Rect2(gpm - Vector2(3, 3), Vector2(6, 6)), Color("#d4a017"))
		var gerbang: Vector2 = Vector2(0, 0)
		if data.has("gerbang_pos"):
			var gp3: Vector3 = data["gerbang_pos"]
			gerbang = Vector2(gp3.x, gp3.z)
		var gm := _ke_mini_jepit(gerbang, pemain, yaw, s, c, r)
		if gm != Vector2.INF:
			draw_rect(Rect2(gm - Vector2(3, 3), Vector2(6, 6)), Color("#d4a017"))
		for pos_jaga in data.get("pos_jaga", []):
			var pj: Vector3 = pos_jaga
			var pjm := _ke_mini_jepit(Vector2(pj.x, pj.z), pemain, yaw, s, c, r)
			if pjm != Vector2.INF:
				draw_rect(Rect2(pjm - Vector2(3, 3), Vector2(6, 6)), Color("#3a2a1a"))
		if data.has("pos_satpam"):
			var ps: Vector3 = data["pos_satpam"]
			var psm := _ke_mini_jepit(Vector2(ps.x, ps.z), pemain, yaw, s, c, r)
			if psm != Vector2.INF:
				draw_rect(Rect2(psm - Vector2(3, 3), Vector2(6, 6)), Color("#3a2a1a"))
		# Peti kayu (wajik coklat).
		var peti: Vector2 = data.get("peti", Vector2(6, 10))
		var pm2 := _ke_mini_jepit(peti, pemain, yaw, s, c, r)
		if pm2 != Vector2.INF:
			draw_colored_polygon(PackedVector2Array([pm2 + Vector2(0, -5), pm2 + Vector2(5, 0), pm2 + Vector2(0, 5), pm2 + Vector2(-5, 0)]), Color("#8a5a2b"))
		# NPC santri (titik biru).
		for npc in data.get("npcs", []):
			var np: Vector2 = npc["pos"]
			var nm := _ke_mini_jepit(np, pemain, yaw, s, c, r)
			if nm != Vector2.INF:
				draw_circle(nm, 4.0, Color("#1d4e6b"))
		# Tujuan misi aktif (wajik emas + cincin berdenyut; dijepit ke
		# tepi lingkaran bila jauh supaya tetap jadi petunjuk arah).
		if data.has("target"):
			var target: Vector2 = data["target"]
			if target != Vector2.INF:
				var tm := _ke_mini_target(target, pemain, yaw, s, c, r)
				var denyut := 9.0 + 3.0 * sin(float(Time.get_ticks_msec()) * 0.005)
				draw_arc(tm, denyut, 0, TAU, 24, Color("#f2c14e"), 2.0)
				draw_colored_polygon(PackedVector2Array([tm + Vector2(0, -6), tm + Vector2(6, 0), tm + Vector2(0, 6), tm + Vector2(-6, 0)]), Color("#f2c14e"))
		# Panah pemain (segitiga hijau menghadap ke atas, tengah).
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -10), c + Vector2(-7, 8), c + Vector2(7, 8)]), Color("#f2c14e"))
		draw_polyline(PackedVector2Array([c + Vector2(0, -10), c + Vector2(-7, 8), c + Vector2(7, 8), c + Vector2(0, -10)]), Color.WHITE, 2.0)
		# Utara (huruf U di tepi, mengikuti putaran peta).
		var u_dir := _putar(Vector2(0, -1), yaw)
		_teks("U", c + u_dir * (r - 12.0), Color.WHITE, 12)
		# Bingkai lingkaran.
		draw_arc(c, r - 1.0, 0, TAU, 48, Color(1, 1, 1, 0.9), 2.0)

	## Putar vektor peta supaya arah hadap pemain menunjuk ke atas.
	## (x = timur, y = selatan/+z; hadap = (sin yaw, cos yaw).)
	func _putar(d: Vector2, yaw: float) -> Vector2:
		var a := yaw - PI
		var ca := cos(a)
		var sa := sin(a)
		return Vector2(d.x * ca - d.y * sa, d.x * sa + d.y * ca)

	## Posisi dunia -> posisi minimap (tanpa jepit; untuk jalan).
	func _ke_mini(w: Vector2, pemain: Vector2, yaw: float, s: float, c: Vector2) -> Vector2:
		return c + _putar(w - pemain, yaw) * s

	## Posisi dunia -> posisi minimap, dijepit ke dalam lingkaran
	## (radius - 10). Kembalikan Vector2.INF bila titik aslinya di luar
	## jangkauan pandang (marker biasa tidak digambar bila jauh).
	func _ke_mini_jepit(w: Vector2, pemain: Vector2, yaw: float, s: float, c: Vector2, r: float) -> Vector2:
		var d := _putar(w - pemain, yaw)
		var jauh := d.length()
		if jauh > jarak_pandang:
			return Vector2.INF
		var p := c + d * s
		var dari_pusat := p - c
		if dari_pusat.length() > r - 10.0:
			p = c + dari_pusat.normalized() * (r - 10.0)
		return p

	## Posisi TUJUAN misi -> posisi minimap: SELALU digambar, dijepit
	## ke tepi lingkaran bila jauh (petunjuk arah ala GTA).
	func _ke_mini_target(w: Vector2, pemain: Vector2, yaw: float, s: float, c: Vector2, r: float) -> Vector2:
		var d := _putar(w - pemain, yaw)
		if d.length() < 0.001:
			return c
		var p := c + d * s
		var dari_pusat := p - c
		if dari_pusat.length() > r - 12.0:
			p = c + dari_pusat.normalized() * (r - 12.0)
		return p

	## Potong segmen ke dalam lingkaran; [] bila tidak memotong.
	func _klip_lingkaran(p1: Vector2, p2: Vector2, c: Vector2, r: float) -> Array:
		var d := p2 - p1
		var f := p1 - c
		var a := d.dot(d)
		if a < 0.001:
			return []
		var b := 2.0 * f.dot(d)
		var cc := f.dot(f) - r * r
		var disc := b * b - 4.0 * a * cc
		if disc < 0.0:
			return []
		var sq := sqrt(disc)
		var t1 := (-b - sq) / (2.0 * a)
		var t2 := (-b + sq) / (2.0 * a)
		var ta := clampf(maxf(t1, 0.0), 0.0, 1.0)
		var tb := clampf(minf(t2, 1.0), 0.0, 1.0)
		if tb <= ta:
			return []
		return [p1 + d * ta, p1 + d * tb]

	func _teks(teks: String, pos: Vector2, warna: Color, ukuran: int) -> void:
		var font := Palette.FONT_GAME  # RONDE 6: font game (Baloo 2 Bold), bukan fallback Arial
		var lebar := font.get_string_size(teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran).x
		draw_string(font, pos + Vector2(-lebar / 2.0, ukuran * 0.35), teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran, warna)


# ---------- panel smartboard ----------
# RONDE 4 (15 Nov — Mas minta smartboard buat presentasi): panel slide
# Nahwu M1 (isim / fi'il / huruf) + tombol video. Slide bisa next/prev;
# tiap ganti slide, layar 3D smartboard di dalam Surau ikut berubah
# (sinyal slide_changed -> main.gd). Video TIDAK diputar di dalam game
# (batas Godot web) — tombolnya membuka URL di tab browser baru.
func _build_smartboard_panel() -> void:
	_smartboard_panel = PanelContainer.new()
	_smartboard_panel.add_theme_stylebox_override("panel", _panel_style(Color("#f5f0e6"), EMAS))
	add_child(_smartboard_panel)
	_pusatkan_panel(_smartboard_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_smartboard_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var judul := _make_label("SMARTBOARD — NAHWU", 28, HIJAU)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(judul)
	var x_btn := _make_button("X", Color("#888888"))
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.pressed.connect(close_smartboard)
	# RONDE PERBAIKAN (Gita, item 8 — pola yang sama): X smartboard
	# menyala saat TEKAN.
	x_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(x_btn)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 10)
	isi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(isi)
	_slide_judul = _make_label("", 26, HIJAU)
	_slide_judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slide_judul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	isi.add_child(_slide_judul)
	_slide_isi = _make_label("", 19, GELAP)
	_slide_isi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	isi.add_child(_slide_isi)
	_slide_nomor = _make_label("", 16, Color("#666666"))
	_slide_nomor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	isi.add_child(_slide_nomor)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	isi.add_child(nav)
	_slide_prev_btn = _make_button("‹ Sebelumnya", HIJAU_TERANG)
	_slide_prev_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slide_prev_btn.pressed.connect(_slide_sebelumnya)
	nav.add_child(_slide_prev_btn)
	_slide_next_btn = _make_button("Berikutnya ›", HIJAU_TERANG)
	_slide_next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slide_next_btn.pressed.connect(_slide_berikutnya)
	nav.add_child(_slide_next_btn)
	_video_btn = _make_button("Tonton Video", Color("#a33b3b"))
	_video_btn.pressed.connect(_on_video_pressed)
	isi.add_child(_video_btn)
	var video_note := _make_label("Video dibuka di tab browser baru — YouTube tidak bisa diputar di dalam game.", 16, Color("#666666"))
	video_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	video_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	isi.add_child(video_note)
	var tutup := _make_button("Tutup", HIJAU)
	tutup.pressed.connect(close_smartboard)
	# RONDE PERBAIKAN (Gita, item 8 — pola yang sama): Tutup smartboard
	# menyala saat TEKAN.
	tutup.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	isi.add_child(tutup)


func is_smartboard_visible() -> bool:
	return _smartboard_panel.visible


## Buka panel smartboard — nama publik untuk Dewa: panggil
## ui.show_smartboard() saat pemain menekan board 3D di interior
## Surau (atau dari tombol interaksi, lihat main.gd _on_interact).
## Slide yang tampil = _slide_idx terakhir; tombol "Tonton Video"
## membuka SMARTBOARD_VIDEO_URL di tab browser baru (web only).
func show_smartboard() -> void:
	open_smartboard()


func open_smartboard() -> void:
	_tampil_slide(_slide_idx)
	_smartboard_panel.visible = true
	_minta_relayout()


func close_smartboard() -> void:
	_smartboard_panel.visible = false


func _tampil_slide(idx: int) -> void:
	_slide_idx = clampi(idx, 0, MissionData.SMARTBOARD_SLIDES.size() - 1)
	var slide: Dictionary = MissionData.SMARTBOARD_SLIDES[_slide_idx]
	_slide_judul.text = String(slide["judul"])
	_slide_isi.text = String(slide["isi"])
	_slide_nomor.text = "Slide " + str(_slide_idx + 1) + " / " + str(MissionData.SMARTBOARD_SLIDES.size())
	_slide_prev_btn.disabled = _slide_idx == 0
	_slide_next_btn.disabled = _slide_idx == MissionData.SMARTBOARD_SLIDES.size() - 1
	# Tombol video: nonaktif + jelas kalau URL belum diisi.
	var url := SMARTBOARD_VIDEO_URL
	if url.is_empty():
		_video_btn.disabled = true
		_video_btn.text = "Belum ada video"
	else:
		_video_btn.disabled = false
		_video_btn.text = "Tonton Video"
	slide_changed.emit(_slide_idx)


func _slide_sebelumnya() -> void:
	_tampil_slide(_slide_idx - 1)


func _slide_berikutnya() -> void:
	_tampil_slide(_slide_idx + 1)


## Buka video pelajaran di tab browser baru (khusus web). Mengembalikan
## false kalau URL kosong / tidak valid / bukan web — pemanggil yang
## menampilkan pesan. JavaScriptBridge diakses lewat Engine singleton
## supaya aman di platform non-web (tidak ada referensi kelas statis).
func _buka_video() -> bool:
	var url := SMARTBOARD_VIDEO_URL
	if url.is_empty() or not url.begins_with("https://"):
		return false
	if "'" in url or '"' in url or "\n" in url:
		return false
	if not OS.has_feature("web"):
		return false
	var jsb = Engine.get_singleton("JavaScriptBridge")
	if jsb == null:
		return false
	jsb.eval("window.open('" + url + "', '_blank')")
	return true


func _on_video_pressed() -> void:
	if _buka_video():
		return
	toast("Video belum bisa dibuka di sini.")

# ---------- baca buku / rak kitab ----------
## Pembaca kitab di dalam game (Tara, 17 Nov 2026 — Mas: "Segera
## selesain ya"): dekati rak -> tombol "BACA KITAB" -> panel ini.
## Tiga tampilan dalam satu panel (patokan artifact
## pratinjau-pembaca-kitab: daftar -> daftar bab -> halaman baca,
## palet zamrud #065F46 / pasir #F2EAD6 / emas #C9A227):
## - DAFTAR: buku lokal (data/buku.json, Laras) + kitab server
##   (GET /api/kitab, publik tanpa token) — keduanya HANYA yang
##   dicek_ustadz:true (filter BukuData). Judul + bahasa + atribusi.
## - BAB: daftar bab (teks) / halaman (gambar), nomor + judul + "›".
## - BACA: teks Arab besar (Amiri, rata kanan) atau Latin; tombol
##   Sebelum/Berikut + zona tap kiri-kanan; nomor bab/halaman;
##   gambar fit-to-width + zoom/pan (ScrollContainer) + keterangan;
##   tombol TUTUP besar + X + Escape + klik-di-luar.
## Pemain tidak bisa jalan selagi panel terbuka (main.gd menolkan
## input bila is_baca_buku_visible()); tutup mengembalikan kontrol.
func _build_baca_buku_panel() -> void:
	_baca_panel = PanelContainer.new()
	# LAYAR PENUH: sudut siku + tanpa border — panel menutupi seluruh
	# viewport, sudut membulat akan menyisakan celah game di 4 sudut.
	var gaya_baca := _panel_style(Palette.KREM, HIJAU)
	gaya_baca.set_corner_radius_all(0)
	gaya_baca.set_border_width_all(0)
	_baca_panel.add_theme_stylebox_override("panel", gaya_baca)
	add_child(_baca_panel)
	_layout_baca_panel()
	# Jarak aman dari tepi layar (ponsel dipegang, jempol di pinggir):
	# isi tidak menempel bezel — kiri/kanan 40, atas/bawah 16
	# (satuan kanvas; di HP portrait ~13 px fisik).
	var pinggir := MarginContainer.new()
	pinggir.add_theme_constant_override("margin_left", 40)
	pinggir.add_theme_constant_override("margin_top", 16)
	pinggir.add_theme_constant_override("margin_right", 40)
	pinggir.add_theme_constant_override("margin_bottom", 16)
	pinggir.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pinggir.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_baca_panel.add_child(pinggir)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pinggir.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	_baca_judul = _make_label("RAK KITAB", 28, HIJAU)
	_baca_judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_judul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_baca_judul.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_baca_judul)
	var x_btn := _make_button("X", Color("#888888"))
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	x_btn.pressed.connect(close_baca_buku)
	header.add_child(x_btn)
	_baca_status = _make_label("", 16, Color("#666666"))
	_baca_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_baca_status)
	# --- tampilan DAFTAR buku ---
	_baca_daftar_view = ScrollContainer.new()
	_baca_daftar_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_baca_daftar_view)
	_baca_daftar_box = VBoxContainer.new()
	_baca_daftar_box.add_theme_constant_override("separation", 10)
	_baca_daftar_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_daftar_view.add_child(_baca_daftar_box)
	var intro := _make_label("Kitab yang sudah dicek ustadz — ketuk untuk membaca.", 17, Color("#4a6b5c"))
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_baca_daftar_box.add_child(intro)
	# --- tampilan BAB / halaman ---
	_baca_bab_view = ScrollContainer.new()
	_baca_bab_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_baca_bab_view.visible = false
	box.add_child(_baca_bab_view)
	_baca_bab_box = VBoxContainer.new()
	_baca_bab_box.add_theme_constant_override("separation", 8)
	_baca_bab_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_bab_view.add_child(_baca_bab_box)
	# --- tampilan BACA ---
	_baca_baca_view = VBoxContainer.new()
	_baca_baca_view.add_theme_constant_override("separation", 8)
	_baca_baca_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_baca_baca_view.visible = false
	box.add_child(_baca_baca_view)
	_baca_kicker = _make_label("", 16, Color("#c9a227"))
	_baca_kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_baca_view.add_child(_baca_kicker)
	_baca_judul_baca = _make_label("", 30, HIJAU)
	_baca_judul_baca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_judul_baca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_baca_baca_view.add_child(_baca_judul_baca)
	_baca_baca_view.add_child(_gold_divider())
	# Teks: ScrollContainer dalam Control supaya zona tap kiri-kanan
	# bisa menumpang di atasnya (tombol transparan 64 px di pinggir).
	_baca_teks_wrap = Control.new()
	_baca_teks_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_baca_teks_wrap.custom_minimum_size = Vector2(0, 200)
	_baca_baca_view.add_child(_baca_teks_wrap)
	_baca_isi_scroll = ScrollContainer.new()
	_baca_isi_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_baca_teks_wrap.add_child(_baca_isi_scroll)
	# PERBAIKAN F4 (Mas 18 Nov 2026: teks Arab mepet scrollbar):
	# label teks dibungkus MarginContainer — kanan 32 supaya teks
	# tidak menyentuh scrollbar, kiri 16 supaya simetris.
	var teks_margin := MarginContainer.new()
	teks_margin.add_theme_constant_override("margin_left", 16)
	teks_margin.add_theme_constant_override("margin_top", 8)
	teks_margin.add_theme_constant_override("margin_right", 32)
	teks_margin.add_theme_constant_override("margin_bottom", 8)
	teks_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_isi_scroll.add_child(teks_margin)
	_baca_isi_teks = _make_label("", 30, GELAP)
	_baca_isi_teks.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_baca_isi_teks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	teks_margin.add_child(_baca_isi_teks)
	_baca_tap_kiri = _baca_tombol_tap("‹", true)
	_baca_teks_wrap.add_child(_baca_tap_kiri)
	_baca_tap_kanan = _baca_tombol_tap("›", false)
	_baca_teks_wrap.add_child(_baca_tap_kanan)
	# Gambar: TextureRect + keterangan di dalam ScrollContainer (pan
	# + zoom; keterangan ikut scroll supaya tidak makan baris tetap).
	# PERBAIKAN F5: sebelumnya keterangan + baris zoom berdiri sendiri
	# di VBox — baris-baris tetap itu menghabiskan tinggi panel
	# (560 px) sehingga ScrollContainer gambar kebagian 0 px dan
	# peta tidak terlihat sama sekali.
	_baca_gambar_scroll = ScrollContainer.new()
	_baca_gambar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_baca_gambar_scroll.custom_minimum_size = Vector2(0, 200)
	_baca_gambar_scroll.visible = false
	_baca_baca_view.add_child(_baca_gambar_scroll)
	var gambar_box := VBoxContainer.new()
	gambar_box.add_theme_constant_override("separation", 8)
	gambar_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_gambar_scroll.add_child(gambar_box)
	_baca_gambar = TextureRect.new()
	_baca_gambar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_baca_gambar.stretch_mode = TextureRect.STRETCH_SCALE
	gambar_box.add_child(_baca_gambar)
	_baca_keterangan = _make_label("", 17, Color("#4a6b5c"))
	_baca_keterangan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_keterangan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gambar_box.add_child(_baca_keterangan)
	_baca_nomor = _make_label("", 17, Color("#666666"))
	_baca_nomor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_baca_view.add_child(_baca_nomor)
	# Navigasi: DUA baris (bukan satu) — di HP portrait, satu baris
	# berisi Sebelumnya + zoom −/100%/+ + Berikutnya meluber keluar
	# panel (lebar minimum gabungan > lebar isi panel saat font
	# diperbesar skala layar). Baris 1: Sebelumnya/Berikutnya
	# (lebar penuh, selalu ada). Baris 2: zoom (hanya halaman gambar).
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	_baca_baca_view.add_child(nav)
	_baca_prev_btn = _make_button("‹ Sebelumnya", HIJAU_TERANG)
	_baca_prev_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_prev_btn.pressed.connect(_baca_sebelumnya)
	nav.add_child(_baca_prev_btn)
	_baca_next_btn = _make_button("Berikutnya ›", HIJAU_TERANG)
	_baca_next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_baca_next_btn.pressed.connect(_baca_berikutnya)
	nav.add_child(_baca_next_btn)
	_baca_zoom_row = HBoxContainer.new()
	_baca_zoom_row.add_theme_constant_override("separation", 8)
	_baca_zoom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_baca_baca_view.add_child(_baca_zoom_row)
	_baca_zoom_kecil = _make_button("−", HIJAU_TERANG)
	_baca_zoom_kecil.custom_minimum_size = Vector2(56, 48)
	_baca_zoom_kecil.pressed.connect(_baca_zoom_keluar)
	_baca_zoom_row.add_child(_baca_zoom_kecil)
	_baca_zoom_label = _make_label("100%", 18, GELAP)
	_baca_zoom_label.custom_minimum_size = Vector2(72, 0)
	_baca_zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_baca_zoom_row.add_child(_baca_zoom_label)
	_baca_zoom_besar = _make_button("+", HIJAU_TERANG)
	_baca_zoom_besar.custom_minimum_size = Vector2(56, 48)
	_baca_zoom_besar.pressed.connect(_baca_zoom_masuk)
	_baca_zoom_row.add_child(_baca_zoom_besar)
	var kembali := _make_button("‹ Daftar Bab", Color("#888888"))
	kembali.pressed.connect(_baca_ke_daftar_bab)
	_baca_baca_view.add_child(kembali)
	var tutup := _make_button("TUTUP", HIJAU)
	tutup.custom_minimum_size = Vector2(0, 56)
	tutup.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	tutup.pressed.connect(close_baca_buku)
	_baca_baca_view.add_child(tutup)


## Tombol tap transparan di pinggir area baca (64 px): "‹"/"›" zamrud
## samar — ketuk untuk pindah bab/halaman tanpa tombol bawah.
func _baca_tombol_tap(teks: String, kiri: bool) -> Button:
	var b := Button.new()
	b.text = teks
	# TARA 20 Nov 2026 (audit tombol): zona tap pinggir menyala saat
	# TEKAN (pola Gita item 8 / Ronde 19 — ketukan HP bergeser).
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", Color(0.02, 0.37, 0.27, 0.45))
	b.add_theme_font_size_override("font_size", 36)
	if kiri:
		b.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		b.offset_right = 64
		b.offset_top = -120
		b.offset_bottom = 120
		b.pressed.connect(_baca_sebelumnya)
	else:
		b.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		b.offset_left = -64
		b.offset_top = -120
		b.offset_bottom = 120
		b.pressed.connect(_baca_berikutnya)
	return b


func is_baca_buku_visible() -> bool:
	return _baca_panel.visible


func open_baca_buku() -> void:
	_baca_panel.visible = true
	_baca_tampil_view("daftar")
	_baca_muat_daftar_lokal()
	_baca_muat_daftar_server()
	_minta_relayout()


func close_baca_buku() -> void:
	_baca_panel.visible = false


## Status di bawah judul: disembunyikan saat kosong supaya tidak
## makan satu baris tetap di panel yang tingginya sudah pas-pasan.
func _baca_set_status(teks: String) -> void:
	_baca_status.text = teks
	_baca_status.visible = teks != ""


func _baca_tampil_view(nama: String) -> void:
	_baca_daftar_view.visible = nama == "daftar"
	_baca_bab_view.visible = nama == "bab"
	_baca_baca_view.visible = nama == "baca"
	if nama == "daftar":
		_baca_judul.text = "RAK KITAB"
	elif nama == "bab":
		_baca_judul.text = "DAFTAR BAB"
	# "baca": judul diatur _baca_buka_bagian (judul buku).


## Muat buku lokal + gabung dengan yang server (kalau sudah ada).
func _baca_muat_daftar_lokal() -> void:
	_baca_lokal = BukuData.muat_lokal()
	_baca_daftar = BukuData.gabung(_baca_lokal, _baca_server)
	_baca_tampil_daftar()


## Ambil daftar kitab server (GET /api/kitab, publik tanpa token).
## Sekali jalan satu request (ketukan ganda diabaikan). Gagal/offline
## -> daftar lokal tetap tampil + pesan singkat (bukan error keras).
func _baca_muat_daftar_server() -> void:
	if _baca_http != null:
		return
	_baca_server_status = "memuat"
	_baca_set_status("Memuat kitab server…")
	var http := HTTPRequest.new()
	http.timeout = BACA_HTTP_TIMEOUT
	_baca_http = http
	add_child(http)
	http.request_completed.connect(_on_baca_http_selesai)
	var err := http.request(BukuData.KITAB_API_BASE + "/api/kitab", [], HTTPClient.METHOD_GET, "")
	if err != OK:
		_baca_http = null
		http.queue_free()
		_baca_server_status = "gagal"
		_baca_set_status("Kitab server tidak terjangkau — menampilkan buku lokal.")


func _on_baca_http_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _baca_http
	_baca_http = null
	if http != null:
		http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_baca_server_status = "gagal"
		_baca_set_status("Kitab server tidak terjangkau — menampilkan buku lokal.")
		return
	var daftar := BukuData.parse_daftar_server(body.get_string_from_utf8())
	_baca_server = daftar
	_baca_server_status = "ok"
	_baca_set_status("")
	_baca_daftar = BukuData.gabung(_baca_lokal, _baca_server)
	_baca_tampil_daftar()


## Bangun ulang daftar buku (server dulu, lalu lokal). Baris lama
## dibuang kecuali label intro (anak pertama _baca_daftar_box).
func _baca_tampil_daftar() -> void:
	for c in _baca_daftar_box.get_children():
		if c is Label and String((c as Label).text).begins_with("Kitab yang sudah"):
			continue
		c.queue_free()
	if _baca_daftar.is_empty():
		var kosong := _make_label("Belum ada buku yang bisa dibaca.", 18, Color("#666666"))
		kosong.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		kosong.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_baca_daftar_box.add_child(kosong)
		return
	for b in _baca_daftar:
		_baca_daftar_box.add_child(_baca_tombol_buku(b))


## Satu baris buku: tombol kartu krem berisi judul (Amiri bila Arab),
## baris meta (judul latin • bahasa • jumlah bab/halaman), dan atribusi.
func _baca_tombol_buku(b: Dictionary) -> Button:
	var btn := Button.new()
	# TARA 20 Nov 2026 (audit tombol): kartu buku menyala saat TEKAN
	# (pola Gita item 8 / Ronde 19 — ketukan HP bergeser).
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn.add_theme_stylebox_override("normal", _btn_style(Color("#fbf8f1")))
	btn.add_theme_stylebox_override("hover", _btn_style(Color("#fbf8f1").lightened(0.05)))
	btn.add_theme_stylebox_override("pressed", _btn_style(Color("#e8dfc8")))
	btn.add_theme_stylebox_override("disabled", _btn_style(Color("#888888")))
	btn.custom_minimum_size = Vector2(0, 104)
	btn.pressed.connect(_baca_buka_buku.bind(b))
	var isi := VBoxContainer.new()
	isi.set_anchors_preset(Control.PRESET_FULL_RECT)
	isi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(isi)
	var arab := String(b.get("bahasa", "id")) == "ar"
	var judul_teks := String(b.get("judul", ""))
	if judul_teks == "":
		judul_teks = String(b.get("judul_latin", ""))
	var j := _make_label(judul_teks, 24, HIJAU)
	if arab:
		j.add_theme_font_override("font", Palette.FONT_ARAB)
		j.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	j.mouse_filter = Control.MOUSE_FILTER_IGNORE
	isi.add_child(j)
	var satuan := "bab" if String(b.get("jenis", "teks")) == "teks" else "halaman"
	var jumlah := BukuData.jumlah_bagian(b)
	if String(b.get("sumber", "")) == "server" and jumlah == 0 and int(b.get("jumlah_bab", 0)) > 0:
		jumlah = int(b.get("jumlah_bab", 0))
	var meta := _make_label("%s • %s • %d %s" % [String(b.get("judul_latin", "")), BukuData.label_bahasa(String(b.get("bahasa", "id"))), jumlah, satuan], 17, GELAP)
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	isi.add_child(meta)
	var atr := String(b.get("atribusi", ""))
	if atr != "":
		var a := _make_label(atr, 15, Color("#666666"))
		a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		a.mouse_filter = Control.MOUSE_FILTER_IGNORE
		isi.add_child(a)
	return btn


## Buka satu buku: kitab server yang bab-nya belum diunduh -> fetch
## dulu (GET /api/kitab/<id>); gambar/teks lokal -> langsung daftar bab.
func _baca_buka_buku(b: Dictionary) -> void:
	_baca_buku = b
	_baca_idx = 0
	if String(b.get("sumber", "")) == "server" and (b.get("bab", []) as Array).is_empty():
		_baca_ambil_kitab_server(String(b.get("id", "")))
		return
	_baca_tampil_bab_view()


func _baca_ambil_kitab_server(id_kitab: String) -> void:
	if _baca_kitab_http != null or id_kitab == "":
		return
	_baca_set_status("Memuat kitab…")
	_baca_tampil_view("bab")
	for c in _baca_bab_box.get_children():
		c.queue_free()
	var http := HTTPRequest.new()
	http.timeout = BACA_HTTP_TIMEOUT
	_baca_kitab_http = http
	add_child(http)
	http.request_completed.connect(_on_baca_kitab_http_selesai)
	var err := http.request(BukuData.KITAB_API_BASE + "/api/kitab/" + id_kitab, [], HTTPClient.METHOD_GET, "")
	if err != OK:
		_baca_kitab_http = null
		http.queue_free()
		_baca_set_status("Kitab tidak bisa dimuat. Coba lagi.")
		_baca_tampil_view("daftar")


func _on_baca_kitab_http_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _baca_kitab_http
	_baca_kitab_http = null
	if http != null:
		http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_baca_set_status("Kitab tidak bisa dimuat. Coba lagi.")
		_baca_tampil_view("daftar")
		return
	var buku := BukuData.parse_kitab_server(body.get_string_from_utf8())
	if buku.is_empty():
		_baca_set_status("Kitab tidak bisa dimuat. Coba lagi.")
		_baca_tampil_view("daftar")
		return
	_baca_buku = buku
	for i in _baca_daftar.size():
		if String((_baca_daftar[i] as Dictionary).get("id", "")) == String(buku.get("id", "")):
			_baca_daftar[i] = buku
	_baca_set_status("")
	_baca_tampil_bab_view()


## Daftar bab/halaman buku aktif: nomor + judul + "›" (pola artifact).
func _baca_tampil_bab_view() -> void:
	_baca_tampil_view("bab")
	_baca_judul.text = String(_baca_buku.get("judul_latin", ""))
	for c in _baca_bab_box.get_children():
		c.queue_free()
	var total := BukuData.jumlah_bagian(_baca_buku)
	if total == 0:
		var kosong := _make_label("Buku ini belum punya isi yang bisa dibaca.", 18, Color("#666666"))
		kosong.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		kosong.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_baca_bab_box.add_child(kosong)
		return
	var arab := String(_baca_buku.get("bahasa", "id")) == "ar"
	for i in total:
		var btn := Button.new()
		# TARA 20 Nov 2026 (audit tombol): baris bab menyala saat
		# TEKAN (pola Gita item 8 / Ronde 19 — ketukan HP bergeser).
		btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		btn.add_theme_stylebox_override("normal", _btn_style(Color("#fbf8f1")))
		btn.add_theme_stylebox_override("hover", _btn_style(Color("#fbf8f1").lightened(0.05)))
		btn.add_theme_stylebox_override("pressed", _btn_style(Color("#e8dfc8")))
		btn.custom_minimum_size = Vector2(0, 56)
		btn.pressed.connect(_baca_buka_bagian.bind(i))
		var baris := HBoxContainer.new()
		baris.set_anchors_preset(Control.PRESET_FULL_RECT)
		baris.add_theme_constant_override("separation", 12)
		baris.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(baris)
		var no := _make_label(str(i + 1), 20, HIJAU)
		no.custom_minimum_size = Vector2(44, 0)
		no.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no.mouse_filter = Control.MOUSE_FILTER_IGNORE
		baris.add_child(no)
		var nama := _make_label(BukuData.judul_bagian(_baca_buku, i), 22, GELAP)
		if arab:
			nama.add_theme_font_override("font", Palette.FONT_ARAB)
			nama.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		nama.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nama.mouse_filter = Control.MOUSE_FILTER_IGNORE
		baris.add_child(nama)
		var panah := _make_label("›", 22, Color("#c9a227"))
		panah.mouse_filter = Control.MOUSE_FILTER_IGNORE
		baris.add_child(panah)
		_baca_bab_box.add_child(btn)


func _baca_ke_daftar_bab() -> void:
	if _baca_buku.is_empty():
		_baca_tampil_view("daftar")
		return
	_baca_tampil_bab_view()


## Tampilkan bab/halaman ke-idx (0-based): teks atau gambar.
func _baca_buka_bagian(idx: int) -> void:
	var total := BukuData.jumlah_bagian(_baca_buku)
	if total == 0:
		return
	_baca_idx = clampi(idx, 0, total - 1)
	_baca_tampil_view("baca")
	_baca_judul.text = String(_baca_buku.get("judul_latin", ""))
	var arab := String(_baca_buku.get("bahasa", "id")) == "ar"
	if String(_baca_buku.get("jenis", "teks")) == "gambar":
		# Kicker disembunyikan: judul "Halaman N" + nomor sudah cukup.
		_baca_kicker.visible = false
		_baca_teks_wrap.visible = false
		_baca_gambar_scroll.visible = true
		_baca_zoom_row.visible = true
		_baca_tampil_gambar()
	else:
		_baca_kicker.visible = true
		_baca_teks_wrap.visible = true
		_baca_gambar_scroll.visible = false
		_baca_zoom_row.visible = false
		var bab: Dictionary = (_baca_buku.get("bab", []) as Array)[_baca_idx]
		_baca_kicker.text = "BAB %d • %d / %d" % [int(bab.get("nomor", _baca_idx + 1)), _baca_idx + 1, total]
		_baca_judul_baca.text = String(bab.get("judul", ""))
		_baca_judul_baca.add_theme_font_override("font", Palette.FONT_ARAB if arab else Palette.FONT_GAME)
		_baca_judul_baca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_baca_isi_teks.text = String(bab.get("teks", ""))
		if arab:
			_baca_isi_teks.add_theme_font_override("font", Palette.FONT_ARAB)
			_baca_isi_teks.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			_baca_isi_teks.set_meta("font_dasar", 34)
			_baca_isi_teks.add_theme_font_size_override("font_size", 34)
		else:
			_baca_isi_teks.add_theme_font_override("font", Palette.FONT_UI)
			_baca_isi_teks.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_baca_isi_teks.set_meta("font_dasar", 26)
			_baca_isi_teks.add_theme_font_size_override("font_size", 26)
		_baca_isi_scroll.scroll_vertical = 0
	_baca_nomor.text = ("Bab %d / %d" % [_baca_idx + 1, total]) if String(_baca_buku.get("jenis", "teks")) == "teks" else ("Halaman %d / %d" % [_baca_idx + 1, total])
	_baca_prev_btn.disabled = _baca_idx == 0
	_baca_next_btn.disabled = _baca_idx == total - 1


## Halaman bergambar: fit-to-width + zoom (0.5x–2.5x) + pan (scroll).
func _baca_tampil_gambar() -> void:
	var hal: Dictionary = (_baca_buku.get("halaman", []) as Array)[_baca_idx]
	_baca_judul_baca.text = "Halaman " + str(int(hal.get("nomor", _baca_idx + 1)))
	_baca_judul_baca.add_theme_font_override("font", Palette.FONT_GAME)
	var tex := load(String(hal.get("gambar", ""))) as Texture2D
	if tex == null:
		_baca_keterangan.text = "Gambar tidak ditemukan: " + String(hal.get("gambar", ""))
		_baca_keterangan.visible = true
		_baca_gambar.visible = false
	else:
		_baca_gambar.texture = tex
		_baca_gambar.visible = true
		_baca_keterangan.text = String(hal.get("keterangan", ""))
		_baca_keterangan.visible = String(hal.get("keterangan", "")) != ""
	_baca_zoom = 1.0
	_baca_atur_zoom(1.0)
	_baca_gambar_scroll.scroll_vertical = 0
	_baca_gambar_scroll.scroll_horizontal = 0


## Lebar gambar = lebar isi panel × zoom; tinggi ikut rasio asli.
func _baca_atur_zoom(z: float) -> void:
	_baca_zoom = clampf(z, 1.0, BACA_ZOOM_MAKS)
	var lebar := maxf(320.0, _baca_panel.size.x - 48.0) * _baca_zoom
	var tex := _baca_gambar.texture
	if tex != null:
		var ts := tex.get_size()
		if ts.x > 0.0:
			_baca_gambar.custom_minimum_size = Vector2(lebar, lebar * ts.y / ts.x)
	_baca_zoom_label.text = "%d%%" % int(_baca_zoom * 100.0)


func _baca_zoom_masuk() -> void:
	_baca_atur_zoom(_baca_zoom + 0.5)


func _baca_zoom_keluar() -> void:
	_baca_atur_zoom(_baca_zoom - 0.5)


func _baca_sebelumnya() -> void:
	if _baca_idx > 0:
		_baca_buka_bagian(_baca_idx - 1)


func _baca_berikutnya() -> void:
	if _baca_idx < BukuData.jumlah_bagian(_baca_buku) - 1:
		_baca_buka_bagian(_baca_idx + 1)


# ---------- helper tes headless ----------
## Judul latin buku di daftar (urut tampil: server dulu, lalu lokal).
func baca_daftar_judul() -> Array[String]:
	var hasil: Array[String] = []
	for b in _baca_daftar:
		hasil.append(String(b.get("judul_latin", "")))
	return hasil


func baca_jumlah_daftar() -> int:
	return _baca_daftar.size()


func baca_buku_aktif_id() -> String:
	return String(_baca_buku.get("id", ""))


## Indeks bagian aktif (0-based) — -1 bila belum ada buku dibuka.
func baca_bagian_aktif() -> int:
	if _baca_buku.is_empty():
		return -1
	return _baca_idx


## Status fetch server terakhir: "" | "memuat" | "ok" | "gagal".
func baca_status_server() -> String:
	return _baca_server_status


func baca_jumlah_server() -> int:
	return _baca_server.size()


## Buka buku dari daftar berdasarkan id (dipakai tes + foto).
func baca_buka_buku_id(id_buku: String) -> bool:
	for b in _baca_daftar:
		if String(b.get("id", "")) == id_buku:
			_baca_buka_buku(b)
			return true
	return false


## Buka bagian ke-idx buku aktif (dipakai tes + foto).
func baca_buka_bagian(idx: int) -> bool:
	if _baca_buku.is_empty():
		return false
	if idx < 0 or idx >= BukuData.jumlah_bagian(_baca_buku):
		return false
	_baca_buka_bagian(idx)
	return true


# ---------- dashboard / Kartu Santri ----------
func _build_dashboard_panel() -> void:
	# Perbaikan 15 Nov ~12:50 WIB (Kartu Santri TIDAK BISA DITUTUP — bug:
	# panel dipusatkan dengan set_anchors_preset(PRESET_CENTER) SEBELUM
	# add_child, saat ukuran panel masih 0 — offset semua 0, sudut kiri-atas
	# panel jatuh tepat di tengah viewport, tombol Tutup (504 px di bawah
	# atas panel) di luar layar pada viewport <1100 px; tidak ada tombol X,
	# tidak ada Escape, tidak ada klik-di-luar).
	# Perbaikan: ukuran panel dihitung eksplisit dari ukuran viewport
	# (_layout_dashboard: maks 700x560, dibatasi 92% viewport) dan
	# dipusatkan dengan offset simetris; header punya tombol X; footer
	# Tutup tetap ada; Escape + klik di luar panel menutup (lihat
	# _unhandled_input); tombol "Kartu Santri" di HUD menutup lewat toggle
	# (main.gd _on_open_dashboard).
	_dashboard_panel = PanelContainer.new()
	_dashboard_panel.add_theme_stylebox_override("panel", _panel_style(Color("#f5f0e6"), EMAS))
	add_child(_dashboard_panel)
	_layout_dashboard()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dashboard_panel.add_child(box)
	# Header: judul + tombol tutup X yang jelas.
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	_dash_title = _make_label("KARTU SANTRI", 28, HIJAU)
	_dash_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dash_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dash_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_dash_title)
	var x_btn := _make_button("X", Color("#888888"))
	# Perbaikan 15 Nov ~15:05 WIB (penguji 4.7: klik pertama di tepi kiri
	# tombol X tidak menutup, baru klik kedua tepat di tengah yang menutup):
	# area klik diperbesar 48x44 -> 56x48 supaya tepi tombol tetap kena.
	x_btn.custom_minimum_size = Vector2(56, 48)
	x_btn.pressed.connect(close_dashboard)
	# RONDE PERBAIKAN (Gita, item 8): X dashboard menyala saat TEKAN.
	x_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	header.add_child(x_btn)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	_dash_scroll = scroll
	_dash_content = VBoxContainer.new()
	_dash_content.add_theme_constant_override("separation", 6)
	_dash_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_dash_content)
	# Footer: "Ganti Baju" + "Tutup" — di LUAR ScrollContainer supaya
	# selalu terlihat tanpa scroll (RONDE 7: tombol Ganti Baju yang
	# ditaruh di tengah konten scroll tidak bisa diklik sebelum
	# di-scroll — sama sulitnya ditemukan seperti lemari).
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	box.add_child(footer)
	var ganti_footer := _make_button("Ganti Baju", EMAS, GELAP)
	ganti_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ganti_footer.pressed.connect(func() -> void: ganti_baju_requested.emit())
	# RONDE PERBAIKAN (Gita, item 8): Ganti Baju menyala saat TEKAN.
	ganti_footer.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	footer.add_child(ganti_footer)
	var tutup := _make_button("Tutup", HIJAU)
	tutup.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutup.pressed.connect(close_dashboard)
	# RONDE PERBAIKAN (Gita, item 8): Tutup dashboard menyala saat TEKAN.
	tutup.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	footer.add_child(tutup)


## Memusatkan panel Kartu Santri dengan ukuran yang dijamin muat di
## viewport (maks 700x560, dibatasi 92% lebar/tinggi viewport) — panel
## tidak pernah menjorok keluar layar, tombol Tutup selalu terlihat.
## RONDE 4: memakai helper umum _pusatkan_panel (rumus yang sama).
func _layout_dashboard() -> void:
	_pusatkan_panel(_dashboard_panel)


func is_dashboard_visible() -> bool:
	return _dashboard_panel.visible


func close_dashboard() -> void:
	_dashboard_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Menutup panel overlay (misi / peta / smartboard / Kartu Santri):
	# tombol Escape, atau klik/ketuk di luar panel. RONDE 4: dulu fungsi
	# ini hanya menangani Kartu Santri — panel misi tidak bisa ditutup
	# Escape/klik-di-luar. Sekarang semua panel ditangani di sini.
	# (HUD sudah MOUSE_FILTER_IGNORE, jadi klik di area kosong memang
	# sampai ke _unhandled_input; klik di tombol HUD dimakan tombol itu
	# sendiri — toggle "Kartu Santri" / "Peta" tetap bekerja.)
	var esc := false
	var klik_pos := Vector2.ZERO
	var ada_klik := false
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and k.keycode == KEY_ESCAPE:
			esc = true
	elif event is InputEventMouseButton:
		var m := event as InputEventMouseButton
		if m.pressed and m.button_index == MOUSE_BUTTON_LEFT:
			ada_klik = true
			klik_pos = m.position
	elif event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed:
			ada_klik = true
			klik_pos = t.position
	if esc:
		var ada := false
		if _mission_panel.visible:
			close_mission()
			ada = true
		if _peta_panel.visible:
			close_peta()
			ada = true
		if _smartboard_panel.visible:
			close_smartboard()
			ada = true
		if _baca_panel.visible:
			close_baca_buku()
			ada = true
		if _dashboard_panel.visible:
			close_dashboard()
			ada = true
		# RONDE 5: Escape juga menutup panel chat MLBB.
		if _chat_panel.visible:
			close_chat()
			ada = true
		# RONDE 6: Escape juga menutup panel aksi + panel ganti baju.
		if _aksi_panel.visible:
			close_aksi()
			ada = true
		if _outfit_panel.visible:
			close_outfit()
			ada = true
		if ada:
			get_viewport().set_input_as_handled()
	elif ada_klik:
		# KOREKSI RUANG KOORDINAT (Tara, 19 Nov 2026): klik_pos datang
		# dalam koordinat PIKSEL viewport (InputEventMouseButton /
		# InputEventScreenTouch.position), sedangkan get_global_rect()
		# dalam koordinat KANVAS. Di HP portrait skala ~0,32, keduanya
		# beda ~3x — bandingkan langsung membuat ketuk di LUAR panel
		# (mis. di bawah panel) terbaca "di dalam" sehingga panel
		# tidak mau tertutup, dan sebaliknya. Konversi dulu dengan
		# invers transform layar (eksak, termasuk bila ada offset
		# letterbox), baru has_point — untuk SEMUA panel di bawah.
		var klik_kanvas: Vector2 = get_viewport().get_screen_transform().affine_inverse() * klik_pos
		# Tutup panel yang terbuka bila klik jatuh DI LUAR rect-nya
		# (satu klik menutup satu panel — panel teratas dulu).
		if _mission_panel.visible and not _mission_panel.get_global_rect().has_point(klik_kanvas):
			close_mission()
			get_viewport().set_input_as_handled()
		elif _peta_panel.visible and not _peta_panel.get_global_rect().has_point(klik_kanvas):
			close_peta()
			get_viewport().set_input_as_handled()
		elif _smartboard_panel.visible and not _smartboard_panel.get_global_rect().has_point(klik_kanvas):
			close_smartboard()
			get_viewport().set_input_as_handled()
		elif _baca_panel.visible and not _baca_panel.get_global_rect().has_point(klik_kanvas):
			close_baca_buku()
			get_viewport().set_input_as_handled()
		elif _dashboard_panel.visible and not _dashboard_panel.get_global_rect().has_point(klik_kanvas):
			close_dashboard()
			get_viewport().set_input_as_handled()
		# RONDE 8 (retest: X chat tidak menutup, hanya tombol Chat yang
		# menutup): klik di luar panel chat juga menutupnya — konsisten
		# dengan semua panel lain.
		elif _chat_panel.visible and not _chat_panel.get_global_rect().has_point(klik_kanvas):
			close_chat()
			get_viewport().set_input_as_handled()
		elif _aksi_panel.visible and not _aksi_panel.get_global_rect().has_point(klik_kanvas):
			close_aksi()
			get_viewport().set_input_as_handled()
		elif _outfit_panel.visible and not _outfit_panel.get_global_rect().has_point(klik_kanvas):
			close_outfit()
			get_viewport().set_input_as_handled()


func open_dashboard(data: Dictionary, today_done: Array, khataman_hadir: bool, streak: int) -> void:
	for c in _dash_content.get_children():
		c.queue_free()
	var tier := SantriSave.tier_for_points(int(data["poin"]))
	var misi_done: Array = data["misi_selesai"]
	_dash_content.add_child(_make_label("ID Santri: " + String(data["id_santri"]), 21, GELAP))
	_dash_content.add_child(_make_label("Nama: " + String(data["nama"]), 21, GELAP))
	# RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): baris "Jalur:"
	# DIHAPUS — tidak ada lagi pilihan Misi / Ngaji Aja.
	_dash_content.add_child(_make_label("Tier: " + tier, 21, GELAP))
	_dash_content.add_child(_make_label("Poin: " + str(data["poin"]), 21, GELAP))
	_dash_content.add_child(_make_label("Misi selesai: " + str(misi_done.size()) + " / " + str(MissionData.MISSIONS.size()), 21, GELAP))
	_streak_label = _make_label("Streak Ma'hadiyah: " + str(streak) + " hari", 21, GELAP)
	_dash_content.add_child(_streak_label)
	# Ma'hadiyah hari ini.
	var mh_title := _make_label("Ma'hadiyah hari ini (wajib):", 22, HIJAU)
	_dash_content.add_child(mh_title)
	for key in MissionData.MAHADIYAH:
		var cb := CheckButton.new()
		cb.text = String(MissionData.MAHADIYAH_LABEL[key])
		cb.button_pressed = today_done.has(key)
		cb.add_theme_font_size_override("font_size", 19)
		cb.set_meta("font_dasar", 19)
		cb.add_theme_color_override("font_color", GELAP)
		# RONDE 7 (retest: "Subuh berjamaah" jadi putih di atas krem
		# saat hover — nyaris tak terbaca): warna hover/pressed
		# default tema adalah putih; kunci ke GELAP juga.
		cb.add_theme_color_override("font_hover_color", GELAP)
		cb.add_theme_color_override("font_pressed_color", GELAP)
		cb.add_theme_color_override("font_focus_color", GELAP)
		# RONDE 8 (retest: daftar hanya bisa di-scroll roda mouse, bukan
		# seret): CheckButton memakan klik (STOP) sehingga ScrollContainer
		# tidak pernah melihat awal seretan — seret yang mulai di atas
		# baris checklist tidak menggulir sama sekali (terukur: scroll
		# tetap 0; dari Label menggulir normal). Teruskan gerak seret
		# dari tiap baris ke ScrollContainer; klik biasa (tanpa gerak)
		# tetap menandai checklist seperti biasa.
		cb.gui_input.connect(_on_dash_item_seret)
		cb.toggled.connect(_on_mahadiyah.bind(String(key)))
		_dash_content.add_child(cb)
	# Khataman — pengajian kitab terjadwal (RONDE 6, Mas 22:17 WIB:
	# ganti konsep "jadwal Ngaji Aja" — tiap jam tertentu ada sesi baca
	# kitab bersama. Sesi yang sedang berlangsung ditandai).
	var kh_title := _make_label("Khataman — pengajian kitab (tiap hari, di surau):", 22, HIJAU)
	kh_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dash_content.add_child(kh_title)
	var sesi_aktif := MissionData.khataman_saat_ini()
	for j in MissionData.KHATAMAN_JADWAL:
		var teks := String(j["jam"]) + " " + String(j["nama"]) + " — " + String(j["kitab"])
		if not sesi_aktif.is_empty() and String(sesi_aktif["jam"]) == String(j["jam"]):
			teks += "  • SEDANG BERLANGSUNG"
		_dash_content.add_child(_make_label(teks, 18, GELAP))
	_khataman_btn = _make_button("Hadir Khataman Hari Ini", HIJAU_TERANG)
	_khataman_btn.pressed.connect(func() -> void: khataman_joined.emit())
	_dash_content.add_child(_khataman_btn)
	set_khataman_hadir(khataman_hadir)
	# Pertumbuhan pesantren.
	var gr_title := _make_label("Pertumbuhan pesantren:", 22, HIJAU)
	_dash_content.add_child(gr_title)
	for stage in MissionData.GROWTH_STAGES:
		var status := "Sudah dibangun" if String(stage["status"]) == "dibangun" else "Terkunci — dibuka saat " + str(stage["ambang_santri"]) + " santri"
		_dash_content.add_child(_make_label("Tahap " + str(stage["tahap"]) + " — " + String(stage["nama"]) + ": " + status, 18, GELAP))
	var gr_note := _make_label("Jumlah santri dihitung server nanti (mode lokal: hanya kamu). Ambang di atas sudah disetujui: Ruang Kelas 25, Asrama 50, Masjid Besar 100, Perpustakaan & Taman 200 santri.", 16, Color("#666666"))
	gr_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dash_content.add_child(gr_note)
	# RONDE 7 (retest: baris Khataman 18:30 terpotong setengah di tepi
	# bawah area gulir): spacer bawah 20 px supaya baris terakhir bisa
	# di-scroll sampai terlihat penuh, tidak berhenti di tepi.
	var spasi_bawah := Control.new()
	spasi_bawah.custom_minimum_size = Vector2(0, 20)
	_dash_content.add_child(spasi_bawah)
	_dashboard_panel.visible = true
	_minta_relayout()


## RONDE 8: seret dari baris checklist Kartu Santri — teruskan gerak
## seret (mouse + sentuh) ke ScrollContainer dashboard. Seret yang
## mulai di atas CheckButton tidak sampai ke ScrollContainer karena
## tombol memakan eventnya (STOP); tanpa ini daftar tidak bisa
## digulir dengan seret dari baris mana pun (di HP tidak ada roda
## mouse). Klik biasa tanpa gerak tidak menggulir, jadi checklist
## tetap bisa ditandai seperti biasa.
func _on_dash_item_seret(event: InputEvent) -> void:
	if _dash_scroll == null:
		return
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.button_mask & MOUSE_BUTTON_MASK_LEFT != 0:
			_dash_scroll.scroll_vertical -= mm.relative.y
	elif event is InputEventScreenDrag:
		_dash_scroll.scroll_vertical -= (event as InputEventScreenDrag).relative.y


func _on_mahadiyah(checked: bool, key: String) -> void:
	mahadiyah_toggled.emit(key, checked)


func set_mahadiyah_streak(streak: int) -> void:
	if _streak_label != null:
		_streak_label.text = "Streak Ma'hadiyah: " + str(streak) + " hari"


func set_khataman_hadir(hadir: bool) -> void:
	if _khataman_btn == null:
		return
	_khataman_btn.text = "Hadir hari ini" if hadir else "Hadir Khataman Hari Ini"
	_khataman_btn.disabled = hadir


# ---------- toast ----------
func _build_toast() -> void:
	_toast = _make_label("", 22, Color.WHITE)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.position = Vector2(-400, 70)
	_toast.custom_minimum_size = Vector2(800, 40)
	# RONDE 8: toast TIDAK BOLEH memakan klik — Label 800x40 di y=70
	# menutupi header panel chat (X ada di sana). Label default
	# mouse_filter STOP; paksa IGNORE supaya klik tembus ke tombol.
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_toast.add_theme_constant_override("shadow_offset_x", 2)
	_toast.add_theme_constant_override("shadow_offset_y", 2)
	_toast.visible = false
	add_child(_toast)


func toast(teks: String) -> void:
	_toast.text = teks
	_toast.visible = true
	_toast_timer = 2.5


func is_toast_visible() -> bool:
	return _toast != null and _toast.visible


# ---------- banner "Ikut Sholat" (RONDE 13) ----------
# Muncul saat waktu sholat tiba (main.gd): pemberitahuan + tombol
# "IKUT SHOLAT" yang mengantar pemain ke Surau. Banner TIDAK modal —
# pemain boleh mengabaikannya (tetap main) atau menutupnya dengan
# berjalan menjauh setelah ikut (main.gd menampilkan lagi).
# Posisi tengah-atas (offset 120, di bawah toast y=70) — kalau panel
# chat sedang terbuka, banner menutupi sebagian atasnya (jarang:
# sesi sholat hanya 1 menit); tombol tetap bisa diketuk.
func _build_sholat_banner() -> void:
	_sholat_banner = PanelContainer.new()
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color(0.06, 0.10, 0.09, 0.88)
	gaya.corner_radius_top_left = 12
	gaya.corner_radius_top_right = 12
	gaya.corner_radius_bottom_left = 12
	gaya.corner_radius_bottom_right = 12
	gaya.border_color = Color(1, 1, 1, 0.15)
	gaya.set_border_width_all(1)
	gaya.content_margin_left = 14.0
	gaya.content_margin_right = 14.0
	gaya.content_margin_top = 10.0
	gaya.content_margin_bottom = 10.0
	_sholat_banner.add_theme_stylebox_override("panel", gaya)
	_sholat_banner.visible = false
	add_child(_sholat_banner)
	_layout_sholat_banner()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	_sholat_banner.add_child(box)
	_sholat_label = _make_label("", 19, Color("#f2c14e"))
	_sholat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sholat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_sholat_label)
	var ikut_btn := _make_button("IKUT SHOLAT", EMAS, GELAP)
	ikut_btn.custom_minimum_size = Vector2(170, 48)
	ikut_btn.pressed.connect(func() -> void: ikut_sholat_pressed.emit())
	box.add_child(ikut_btn)


func _layout_sholat_banner() -> void:
	if _sholat_banner == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var w := minf(vp.x * 0.92, 560.0)
	_sholat_banner.anchor_left = 0.5
	_sholat_banner.anchor_right = 0.5
	_sholat_banner.anchor_top = 0.0
	_sholat_banner.anchor_bottom = 0.0
	_sholat_banner.offset_left = -w * 0.5
	_sholat_banner.offset_right = w * 0.5
	_sholat_banner.offset_top = 120.0
	_sholat_banner.offset_bottom = 120.0 + 72.0


## RONDE PERBAIKAN (Raka, integrasi laporan Eka): tempat sholat
## mengikuti gender/area pemain — santriwati ke Musholla, bukan Surau.
func show_sholat_banner(nama: String, tempat: String = "Surau") -> void:
	_sholat_label.text = "Waktu sholat " + nama + " — ayo ke " + tempat + "!"
	_sholat_banner.visible = true


func hide_sholat_banner() -> void:
	if _sholat_banner != null:
		_sholat_banner.visible = false


func is_sholat_banner_visible() -> bool:
	return _sholat_banner != null and _sholat_banner.visible


# ---------- banner petunjuk misi santri baru ----------
# Perintah Mas 21:32 WIB, 18 Nov 2026: santri baru dikasih petunjuk
# teks "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang".
# Banner PERSISTEN tengah-atas — BUKAN toast (toast cuma 2,5 dtk dan
# langsung tertimpa toast lain; pelajaran Sinta 18 Nov).
# POSISI y=200 (BUKAN y=120 seperti banner sholat — foto pertama
# menunjukkan banner di y=120 menutupi ujung kanan tombol "Main
# Bersama" (216,116, 200x56): huruf "a" terakhir hilang. Di y=200
# banner lewat di bawah tombol itu (berakhir y=172) dan di bawah
# banner sholat (120..192, jeda 8 px bila keduanya tampil).
# Selama pop-up petunjuk tombol terbuka, banner disembunyikan
# (sinkronisasi main.gd) supaya tidak menumpuk di atas pop-up.
# mouse_filter IGNORE: banner ini teks saja, TANPA tombol — tidak
# boleh memakan sentuhan apa pun (gamepad/strip atas tetap bisa
# ditekan walau banner tampil). Dibangun SEBELUM banner sholat
# supaya saat keduanya tampil, banner sholat (tombol IKUT SHOLAT)
# yang di atas.
# Teks dipertahankan persis ucapan Mas (huruf kecil "ayo").
const TEKS_PETUNJUK_MISI_PUTRA := "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang"
const TEKS_PETUNJUK_MISI_PUTRI := "ayo mulai misi santri barumu! Sowan ke Ustadzah sekarang"


func _build_petunjuk_misi_banner() -> void:
	_petunjuk_misi_banner = PanelContainer.new()
	# v2 (19 Nov 2026): toast gradien zamrud + rim emas 2 + bayangan
	# lembut. StyleBoxFlat transparan — gradien dari TextureRect latar.
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = Color(0, 0, 0, 0)
	gaya.border_color = EMAS
	gaya.set_border_width_all(2)
	gaya.set_corner_radius_all(16)
	gaya.shadow_color = Color(0, 0, 0, 70.0 / 255.0)
	gaya.shadow_size = 12
	gaya.shadow_offset = Vector2(0, 5)
	gaya.content_margin_left = 2.0
	gaya.content_margin_right = 2.0
	gaya.content_margin_top = 2.0
	gaya.content_margin_bottom = 2.0
	_petunjuk_misi_banner.add_theme_stylebox_override("panel", gaya)
	_petunjuk_misi_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_petunjuk_misi_banner.visible = false
	add_child(_petunjuk_misi_banner)
	_layout_petunjuk_misi_banner()
	# v2-perbaikan sudut (Sinta, 19 Nov 2026): latar dibakar 560x88
	# (ukuran banner sebenarnya, _layout_petunjuk_misi_banner) — 1:1.
	# Panggang 96x96 lama direntang ~6x bikin sudut bergerigi, sama
	# seperti dialog.
	var latar := GayaMisi.buat_latar_gradien(GayaMisi.ZAMRUD, GayaMisi.ZAMRUD_GELAP, 14, Vector2i(560, 88))
	_petunjuk_misi_banner.add_child(latar)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_petunjuk_misi_banner.add_child(margin)
	var baris := HBoxContainer.new()
	baris.add_theme_constant_override("separation", 12)
	baris.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(baris)
	# Ikon bintang zamrud gelap dalam lingkaran emas.
	var lingkaran := Panel.new()
	lingkaran.custom_minimum_size = Vector2(40, 40)
	var gaya_lingkaran := StyleBoxFlat.new()
	gaya_lingkaran.bg_color = EMAS
	gaya_lingkaran.set_corner_radius_all(20)
	lingkaran.add_theme_stylebox_override("panel", gaya_lingkaran)
	lingkaran.mouse_filter = Control.MOUSE_FILTER_IGNORE
	baris.add_child(lingkaran)
	var bintang := IkonHUD.new()
	bintang.jenis = "bintang"
	bintang.warna = Color("#043b2c")
	bintang.bayangan = false
	bintang.position = Vector2(7, 7)
	bintang.size = Vector2(26, 26)
	bintang.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lingkaran.add_child(bintang)
	# Teks dua baris: ajakan tebal krem + arah emas terang.
	var teks_baris := VBoxContainer.new()
	teks_baris.add_theme_constant_override("separation", 2)
	teks_baris.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	teks_baris.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	teks_baris.mouse_filter = Control.MOUSE_FILTER_IGNORE
	baris.add_child(teks_baris)
	_petunjuk_misi_label = _make_label("", 24, Color("#f2ead6"))
	_petunjuk_misi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_petunjuk_misi_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	teks_baris.add_child(_petunjuk_misi_label)
	_petunjuk_misi_arah = _make_label("", 18, Color("#e8c45a"))
	_petunjuk_misi_arah.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_petunjuk_misi_arah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	teks_baris.add_child(_petunjuk_misi_arah)
	# Panah › di kanan (isyarat "ikuti arah ini").
	var panah := _make_label("›", 28, Color("#e8c45a"))
	panah.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	baris.add_child(panah)


func _layout_petunjuk_misi_banner() -> void:
	if _petunjuk_misi_banner == null:
		return
	var vp := get_viewport().get_visible_rect().size
	var w := minf(vp.x * 0.92, 560.0)
	_petunjuk_misi_banner.anchor_left = 0.5
	_petunjuk_misi_banner.anchor_right = 0.5
	_petunjuk_misi_banner.anchor_top = 0.0
	_petunjuk_misi_banner.anchor_bottom = 0.0
	_petunjuk_misi_banner.offset_left = -w * 0.5
	_petunjuk_misi_banner.offset_right = w * 0.5
	_petunjuk_misi_banner.offset_top = 200.0
	_petunjuk_misi_banner.offset_bottom = 200.0 + 88.0


func show_petunjuk_misi(putri: bool) -> void:
	_petunjuk_misi_teks = TEKS_PETUNJUK_MISI_PUTRI if putri else TEKS_PETUNJUK_MISI_PUTRA
	_petunjuk_misi_label.text = "ayo mulai misi santri barumu!"
	_petunjuk_misi_arah.text = "Sowan ke Ustadzah sekarang" if putri else "Sowan ke Ustadz sekarang"
	_petunjuk_misi_banner.visible = true
	_animasi_banner_masuk()


## v2: banner geser turun dari atas + fade, 220 ms ease-out.
func _animasi_banner_masuk() -> void:
	if _tween_banner != null and _tween_banner.is_valid():
		_tween_banner.kill()
	_petunjuk_misi_banner.position.y = 184.0
	_petunjuk_misi_banner.modulate.a = 0.0
	_tween_banner = create_tween()
	_tween_banner.set_parallel(true)
	_tween_banner.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_banner.tween_property(_petunjuk_misi_banner, "position:y", 200.0, 0.22)
	_tween_banner.tween_property(_petunjuk_misi_banner, "modulate:a", 1.0, 0.22)


func hide_petunjuk_misi() -> void:
	if _petunjuk_misi_banner != null:
		if _tween_banner != null and _tween_banner.is_valid():
			_tween_banner.kill()
		_petunjuk_misi_banner.position.y = 200.0
		_petunjuk_misi_banner.modulate.a = 1.0
		_petunjuk_misi_banner.visible = false


func is_petunjuk_misi_visible() -> bool:
	return _petunjuk_misi_banner != null and _petunjuk_misi_banner.visible


func teks_petunjuk_misi() -> String:
	return _petunjuk_misi_teks


# ---------- overlay BLACKOUT adegan sholat (RONDE 18) ----------
# Layar menghitam di antara takbir dan selesai (fade out ±0,5 dtk,
# tahan hitam sampai ±2,5 dtk, lalu fade in ±0,8 dtk — main.gd).
# Teks kecil di tengah: "Sholat berjamaah...". Overlay tidak menangkap
# input (mouse_filter IGNORE) supaya tidak memblokir klik saat fade.
# Dibangun TERAKHIR di _ready supaya selalu di atas semua UI lain.
func _build_blackout_overlay() -> void:
	_blackout_overlay = Control.new()
	_blackout_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blackout_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blackout_overlay.visible = false
	_blackout_overlay.modulate.a = 0.0
	add_child(_blackout_overlay)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blackout_overlay.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blackout_overlay.add_child(center)
	_blackout_label = _make_label("Sholat berjamaah...", 26, Color(1, 1, 1, 0.92))
	_blackout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_blackout_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_blackout_label)


func show_blackout() -> void:
	if _blackout_overlay == null:
		return
	_blackout_overlay.modulate.a = 0.0
	_blackout_overlay.visible = true


func set_blackout_alpha(a: float) -> void:
	if _blackout_overlay == null:
		return
	_blackout_overlay.modulate.a = clampf(a, 0.0, 1.0)


func hide_blackout() -> void:
	if _blackout_overlay == null:
		return
	_blackout_overlay.visible = false
	_blackout_overlay.modulate.a = 0.0


func is_blackout_visible() -> bool:
	return _blackout_overlay != null and _blackout_overlay.visible


func get_blackout_alpha() -> float:
	if _blackout_overlay == null:
		return 0.0
	return _blackout_overlay.modulate.a


# ---------- overlay "Putar HP" (mode landscape) ----------
# 15 Nov ~12:00 WIB (Mas minta main HP miring supaya lebih lega):
# overlay muncul saat layar portrait DI PERANGKAT SENTUH, baik di layar
# masuk maupun di dalam game (satu overlay di atas semua UI). Di desktop
# berjendela sempit tidak muncul (tanpa sentuhan) supaya tidak mengganggu.
# Bisa ditutup dengan "Tetap main portrait" — muncul lagi kalau orientasi
# berubah ke landscape lalu kembali portrait.
static func butuh_putar_hp(ukuran: Vector2, layar_sentuh: bool) -> bool:
	return layar_sentuh and ukuran.y > ukuran.x


func _build_rotate_overlay() -> void:
	# TARA 18 Nov 2026 (laporan Mas "tombol di HP belum stabil"):
	# overlay ini dibangun SETELAH _hud sehingga berada DI ATAS HUD —
	# dengan mouse_filter default (STOP) latarnya menelan SEMUA sentuhan
	# ke tombol gamepad selama tampil. Latar/dim/teks dibuat IGNORE
	# supaya sentuhan tembus ke HUD; HANYA tombol "Tetap main portrait"
	# yang tetap STOP (bisa ditekan). Perilaku lain tidak berubah:
	# tetap tampil saat portrait, tetap bisa ditutup, tetap tidak
	# muncul lagi setelah ditutup (flag _rotate_dismissed).
	_rotate_overlay = Control.new()
	_rotate_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rotate_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rotate_overlay.visible = false
	add_child(_rotate_overlay)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.15, 0.11, 0.96)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rotate_overlay.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rotate_overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(box)
	var ikon := IkonPutar.new()
	ikon.custom_minimum_size = Vector2(96, 96)
	ikon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ikon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(ikon)
	var judul := _make_label("PUTAR HP-MU", 36, EMAS)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(judul)
	var pesan := _make_label("Pesantren Universe lebih lega dimainkan miring (landscape).", 20, Color.WHITE)
	pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pesan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pesan.custom_minimum_size = Vector2(320, 0)
	pesan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(pesan)
	var lanjut := _make_button("Tetap main portrait", HIJAU_TERANG)
	lanjut.custom_minimum_size = Vector2(280, 52)
	lanjut.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	lanjut.pressed.connect(_tutup_rotate_overlay)
	box.add_child(lanjut)
	_update_rotate_overlay()


func _update_rotate_overlay() -> void:
	if _rotate_overlay == null:
		return
	var vp := get_viewport().get_visible_rect().size
	if not butuh_putar_hp(vp, DisplayServer.is_touchscreen_available()):
		_rotate_overlay.visible = false
		_rotate_dismissed = false
		return
	_rotate_overlay.visible = not _rotate_dismissed


func _tutup_rotate_overlay() -> void:
	_rotate_dismissed = true
	_rotate_overlay.visible = false


# Ikon panah melingkar (digambar kode — tanpa aset gambar).
class IkonPutar extends Control:
	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.38
		# Busur 300 derajat (celah di kanan tempat kepala panah).
		draw_arc(c, r, deg_to_rad(40), deg_to_rad(340), 48, Color("#d4a017"), 8.0)
		# Kepala panah di ujung busur (sudut 40 derajat, searah singgung).
		var ujung := c + Vector2(cos(deg_to_rad(40)), sin(deg_to_rad(40))) * r
		var arah := Vector2(cos(deg_to_rad(130)), sin(deg_to_rad(130)))
		var tegak := Vector2(-arah.y, arah.x)
		draw_colored_polygon(PackedVector2Array([
			ujung + arah * 16.0,
			ujung - arah * 6.0 + tegak * 12.0,
			ujung - arah * 6.0 - tegak * 12.0,
		]), Color("#d4a017"))


func _process(delta: float) -> void:
	if _toast.visible:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast.visible = false
	# BUBBLE-ML: tiap baris feed hidup 4 dtk; 1 dtk terakhir fade
	# (modulate 1 -> 0), lalu baris dibuang.
	for i in range(_feed_baris.size() - 1, -1, -1):
		var entri: Dictionary = _feed_baris[i]
		entri["sisa"] = float(entri["sisa"]) - delta
		var sisa := float(entri["sisa"])
		var row := entri["row"] as HBoxContainer
		if sisa <= 0.0:
			_feed_baris.remove_at(i)
			row.queue_free()
		elif sisa < FEED_CHAT_FADE:
			row.modulate.a = sisa / FEED_CHAT_FADE
	# FULLSCREEN: sinkron label tombol tiap 0,5 dtk (jaring pengaman
	# kalau browser keluar fullscreen tanpa resize — mis. ESC).
	_sinkron_layar_penuh_timer -= delta
	if _sinkron_layar_penuh_timer <= 0.0:
		_sinkron_layar_penuh_timer = 0.5
		_sinkron_tombol_layar_penuh()
	# Relayout 2 frame setelah panel dibuka (lihat _minta_relayout):
	# offset diterapkan ulang setelah min-size label autowrap waras.
	if _relayout_frames > 0:
		_relayout_frames -= 1
		_layout_semua_panel()
	# Peta hidup: gambar ulang tiap frame selama panel terbuka (posisi
	# santri + NPC diperbarui main.gd lewat update_peta).
	if _peta_panel.visible and _peta_map != null:
		_peta_map.queue_redraw()


