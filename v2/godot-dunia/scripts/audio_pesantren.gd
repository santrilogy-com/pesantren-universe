class_name AudioPesantren
extends Node
## RONDE 17 — audio suasana pesantren (Mas 16 Nov ~08:52 WIB:
## "biar ada suasana pesantren.. perlu ada audio di gamenya.. seperti
## wirid-wirid, bacaan al-quran, baca nadzom dll. Untuk diluar kegiatan
## maka kasih sound yg menenangkan.. seperti bunyi burung dll").
##
## Dua lapis suara:
## 1. AMBIENCE menurut jam perangkat (selaras fase langit_dinamis.gd):
##    04:00-10:00 kicau burung (subuh+pagi), 10:00-15:00 angin/daun
##    (siang), 15:00-18:00 kicau burung (sore — kicau senja),
##    18:00-04:00 jangkrik (malam). Crossfade halus 2,5 dtk saat fase
##    berganti (dua AudioStreamPlayer bergantian).
## 2. KEGIATAN (hanya bila sesi berjalan + filenya ADA):
##    sesi sholat -> wirid.ogg; sesi khataman kitab Amtsilah ->
##    nadzom.ogg; sesi khataman kitab lain -> quran_khataman.ogg.
##    Saat kegiatan berbunyi, ambience di-duck (-30 dB); saat sesi
##    habis, ambience kembali normal. Bila file kegiatan BELUM ADA,
##    sistem diam-diam tetap memainkan ambience (TIDAK error, TIDAK
##    ada suara palsu — bacaan TIDAK PERNAH digenerate/dipalsukan).
##
## 3. ADZAN (FITUR ADZAN — Mas 17 Nov ~20:52 WIB): SATU rekaman
##    adzan (adzan.ogg, lisensi bersih — sumber + lisensi di
##    audio/README.md) yang bunyi BERSAMAAN dengan banner sholat
##    (main.gd _mulai_sholat memanggil mainkan_adzan()). Sekali
##    putar sampai habis (TIDAK di-loop). Selama adzan bunyi,
##    ambience di-duck seperti saat kegiatan. File BOLEH tidak ada
##    — bila belum ada, mainkan_adzan() diam (peringatan di log)
##    dan banner tetap tampil tanpa suara; game TIDAK error.
##    Mute bus Master (tombol Suara/Senyap) dihormati: bila mati,
##    adzan TIDAK diputar. Jangan isi slot ini dengan TTS / suara
##    palsu / rip YouTube — menunggu rekaman berlisensi bersih.
##
## Autoplay web: AudioContext browser baru bunyi setelah GESTUR
## pengguna (kebijakan browser). Karena itu audio TIDAK mulai di
## _ready — main.gd memanggil mulai() pada input pertama (klik/
## sentuh/tombol). Di headless (driver Dummy) mulai() tetap aman.

## File ambience (CC0 — sumber + lisensi di audio/README.md).
const PATH_AMBIENCE := {
	"burung": "res://audio/burung.ogg",
	"angin": "res://audio/angin.ogg",
	"jangkrik": "res://audio/jangkrik.ogg",
}
## Slot bacaan — SENGAJA KOSONG (menunggu rekaman Mas / file
## berlisensi). Nama file TETAP — cukup letakkan file .ogg di folder
## audio/ dengan nama ini, tanpa ubah kode.
const PATH_KEGIATAN := {
	"wirid": "res://audio/wirid.ogg",
	"khataman": "res://audio/quran_khataman.ogg",
	"nadzom": "res://audio/nadzom.ogg",
}
## Adzan (FITUR ADZAN): satu file, sekali putar (TIDAK di-loop).
## Boleh tidak ada — lihat mainkan_adzan().
const PATH_ADZAN := "res://audio/adzan.ogg"

## SFX (Sinta, 17 Nov 2026 — acuan reel @jipraks: SFX sinkron tepat
## di momennya). Semua CC0 — sumber + lisensi di SFX-STATUS.md dan
## audio/README.md. Langkah kaki: 3 variasi per permukaan (dipilih
## acak tiap langkah supaya tidak terdengar seperti mesin) + pitch
## acak 0,95–1,05. Pintu: buka/tutup kayu. Klik: tombol/panel
## (pemicu di ui.gd — BELUM dipasang ronde ini, lihat SFX-STATUS.md).
const PATH_SFX_LANGKAH_TANAH := [
	"res://audio/langkah_tanah_1.ogg",
	"res://audio/langkah_tanah_2.ogg",
	"res://audio/langkah_tanah_3.ogg",
]
const PATH_SFX_LANGKAH_LANTAI := [
	"res://audio/langkah_lantai_1.ogg",
	"res://audio/langkah_lantai_2.ogg",
	"res://audio/langkah_lantai_3.ogg",
]
const PATH_SFX_PINTU_BUKA := "res://audio/pintu_buka.ogg"
const PATH_SFX_PINTU_TUTUP := "res://audio/pintu_tutup.ogg"
const PATH_SFX_KLIK := "res://audio/klik.ogg"

## Volume (dB). Ambience pelan (latar), bacaan lebih jelas.
const DB_AMBIENCE := -16.0
const DB_KEGIATAN := -10.0
const DB_ADZAN := -10.0
const DB_DUCK := -30.0
## SFX: langkah pelan di bawah ambience, pintu jelas, klik paling pelan.
const DB_LANGKAH := -14.0
const DB_PINTU := -10.0
const DB_KLIK := -16.0
const DB_DIAM := -40.0
const DURASI_FADE := 2.5
## Semua stream di-loop: ambience 40 dtk berputar terus; bacaan
## kegiatan juga berputar selama sesinya (rekaman pendek — mis.
## Al-Fatihah 47 dtk — akan berulang; rekaman lebih panjang lebih
## baik, lihat audio/README.md + RONDE17-STATUS.md §4).

var _amb_a: AudioStreamPlayer
var _amb_b: AudioStreamPlayer
var _keg: AudioStreamPlayer
var _adz: AudioStreamPlayer
var _stream_amb: Dictionary = {}
var _stream_keg: Dictionary = {}
var _stream_adzan: AudioStream = null
var _adzan_tertunda: bool = false
var _adzan_jumlah_main: int = 0
## SFX (lihat PATH_SFX_* di atas): satu player per jenis — play()
## saat masih bunyi memulai ulang dari awal (langkah tiap ~0,35 dtk,
## file 0,24–0,44 dtk, jadi tumpang tindih nyaris tidak terjadi).
var _sfx_langkah: AudioStreamPlayer
var _sfx_pintu: AudioStreamPlayer
var _sfx_klik: AudioStreamPlayer
var _stream_langkah_tanah: Array[AudioStream] = []
var _stream_langkah_lantai: Array[AudioStream] = []
var _stream_pintu_buka: AudioStream = null
var _stream_pintu_tutup: AudioStream = null
var _stream_klik: AudioStream = null
var _langkah_jumlah: int = 0
var _pintu_jumlah: int = 0
var _klik_jumlah: int = 0
var _langkah_lantai_terakhir: bool = false
var _dimulai: bool = false
var _amb_key: String = ""
var _aktif: AudioStreamPlayer
var _cadangan: AudioStreamPlayer
var _kegiatan: String = ""
var _keg_tersedia: bool = false
var _fade_t: float = -1.0
var _fade_dari: AudioStreamPlayer
var _fade_ke: AudioStreamPlayer
var _keg_target_db: float = DB_DIAM


func _ready() -> void:
	_amb_a = AudioStreamPlayer.new()
	_amb_a.name = "AmbienceA"
	_amb_b = AudioStreamPlayer.new()
	_amb_b.name = "AmbienceB"
	_keg = AudioStreamPlayer.new()
	_keg.name = "Kegiatan"
	_adz = AudioStreamPlayer.new()
	_adz.name = "Adzan"
	_sfx_langkah = AudioStreamPlayer.new()
	_sfx_langkah.name = "SfxLangkah"
	_sfx_pintu = AudioStreamPlayer.new()
	_sfx_pintu.name = "SfxPintu"
	_sfx_klik = AudioStreamPlayer.new()
	_sfx_klik.name = "SfxKlik"
	# Volume awal DIAM — supaya tidak ada bunyi sebelum mulai().
	_amb_a.volume_db = DB_DIAM
	_amb_b.volume_db = DB_DIAM
	_keg.volume_db = DB_DIAM
	_adz.volume_db = DB_DIAM
	_sfx_langkah.volume_db = DB_DIAM
	_sfx_pintu.volume_db = DB_DIAM
	_sfx_klik.volume_db = DB_DIAM
	add_child(_amb_a)
	add_child(_amb_b)
	add_child(_keg)
	add_child(_adz)
	add_child(_sfx_langkah)
	add_child(_sfx_pintu)
	add_child(_sfx_klik)
	_aktif = _amb_a
	_cadangan = _amb_b
	for k in PATH_AMBIENCE.keys():
		if ResourceLoader.exists(PATH_AMBIENCE[k]):
			_stream_amb[k] = _muat_loop(PATH_AMBIENCE[k])
		else:
			push_warning("[RONDE17] ambience hilang: " + PATH_AMBIENCE[k])
	for k in PATH_KEGIATAN.keys():
		# File bacaan BOLEH tidak ada — itu keadaan normal ronde ini.
		_stream_keg[k] = _muat_loop(PATH_KEGIATAN[k]) if ResourceLoader.exists(PATH_KEGIATAN[k]) else null
	# Adzan BOLEH tidak ada (menunggu rekaman berlisensi bersih).
	# TIDAK di-loop: sekali putar sampai habis.
	_stream_adzan = load(PATH_ADZAN) if ResourceLoader.exists(PATH_ADZAN) else null
	# SFX: file BOLEH tidak ada (mainkan_* diam bila kosong — game
	# TIDAK error). Peringatan di log supaya ketahuan bila file hilang.
	for p in PATH_SFX_LANGKAH_TANAH:
		if ResourceLoader.exists(p):
			_stream_langkah_tanah.append(load(p))
		else:
			push_warning("[SFX] langkah tanah hilang: " + p)
	for p in PATH_SFX_LANGKAH_LANTAI:
		if ResourceLoader.exists(p):
			_stream_langkah_lantai.append(load(p))
		else:
			push_warning("[SFX] langkah lantai hilang: " + p)
	_stream_pintu_buka = load(PATH_SFX_PINTU_BUKA) if ResourceLoader.exists(PATH_SFX_PINTU_BUKA) else null
	if _stream_pintu_buka == null:
		push_warning("[SFX] pintu buka hilang: " + PATH_SFX_PINTU_BUKA)
	_stream_pintu_tutup = load(PATH_SFX_PINTU_TUTUP) if ResourceLoader.exists(PATH_SFX_PINTU_TUTUP) else null
	if _stream_pintu_tutup == null:
		push_warning("[SFX] pintu tutup hilang: " + PATH_SFX_PINTU_TUTUP)
	_stream_klik = load(PATH_SFX_KLIK) if ResourceLoader.exists(PATH_SFX_KLIK) else null
	if _stream_klik == null:
		push_warning("[SFX] klik hilang: " + PATH_SFX_KLIK)


## Muat stream Ogg + aktifkan loop penuh (loop_begin/end 0 =
## seluruh file). Tanpa ini, ambience 40 dtk hanya berbunyi sekali.
static func _muat_loop(path: String) -> AudioStream:
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	return s


## Ambience untuk sebuah jam (desimal). Fungsi murni — dipakai tes.
## Selaras fase langit: subuh 04:00-05:30 + pagi 05:30-10:00 = burung;
## siang 10:00-15:00 = angin; sore 15:00-18:00 = burung (kicau senja);
## malam 18:00-04:00 = jangkrik.
static func ambience_untuk_jam(jam: float) -> String:
	if jam >= 4.0 and jam < 10.0:
		return "burung"
	if jam >= 10.0 and jam < 15.0:
		return "angin"
	if jam >= 15.0 and jam < 18.0:
		return "burung"
	return "jangkrik"


## Audio kegiatan untuk sebuah kitab khataman (fungsi murni — tes).
## Amtsilah Tashrifiyyah = nadzom; kitab lain = quran_khataman.
static func kegiatan_untuk_kitab(kitab: String) -> String:
	if kitab == "Amtsilah Tashrifiyyah":
		return "nadzom"
	return "khataman"


## Mulai audio — dipanggil main.gd pada GESTUR pertama (autoplay
## web). Sebelum ini, tidak ada suara apa pun.
func mulai() -> void:
	if _dimulai:
		return
	_dimulai = true
	var key := ambience_untuk_jam(LangitDinamis.jam_saat_ini())
	_mulai_ambience_langsung(key)
	# Sesi kegiatan mungkin sudah dicatat sebelum gestur pertama —
	# baru sekarang boleh berbunyi (autoplay web).
	if _keg_tersedia and _kegiatan != "":
		_keg.play()
	# Adzan yang diminta sebelum gestur pertama (banner sholat
	# muncul saat dunia baru terlihat) — baru sekarang boleh bunyi.
	if _adzan_tertunda:
		_adzan_tertunda = false
		if _stream_adzan != null and not bisukan():
			_adz.stream = _stream_adzan
			_adz.volume_db = DB_ADZAN
			_adz.play()
			_adzan_jumlah_main += 1
			print("[ADZAN] diputar (tertunda sampai gestur pertama)")
	print("[RONDE17] audio dimulai (gestur pertama) — ambience: " + key)


func dimulai() -> bool:
	return _dimulai


func amb_key() -> String:
	return _amb_key


func kegiatan_aktif() -> String:
	return _kegiatan if _keg_tersedia else ""


## Apakah file bacaan untuk jenis ini sudah ada di proyek?
func file_kegiatan_ada(jenis: String) -> bool:
	return _stream_keg.get(jenis, null) != null


## FITUR ADZAN — putar adzan sekali sampai habis, bersamaan dengan
## banner sholat (dipanggil main.gd _mulai_sholat). Aman dipanggil
## kapan saja:
## - file adzan.ogg belum ada -> diam + peringatan di log, banner
##   tetap tampil tanpa suara (game TIDAK error);
## - sudah bunyi -> tidak mulai ulang (tidak ada adzan ganda);
## - suara dimatikan (tombol Suara/Senyap, bus Master) -> tidak bunyi;
## - audio belum dimulai (belum ada gestur pertama, autoplay web) ->
##   ditunda; mulai() yang akan memutarkannya.
func mainkan_adzan() -> void:
	if _stream_adzan == null:
		print("[ADZAN] file adzan.ogg belum ada — banner tetap tampil tanpa suara")
		return
	if _adz.playing:
		return
	if bisukan():
		print("[ADZAN] dilewati — suara dimatikan pemain")
		return
	if not _dimulai:
		_adzan_tertunda = true
		print("[ADZAN] ditunda sampai gestur pertama")
		return
	_adz.stream = _stream_adzan
	_adz.volume_db = DB_ADZAN
	_adz.play()
	_adzan_jumlah_main += 1
	print("[ADZAN] diputar")


## Apakah file adzan.ogg sudah ada di proyek?
func adzan_tersedia() -> bool:
	return _stream_adzan != null


## Apakah adzan sedang bunyi saat ini?
func adzan_dimainkan() -> bool:
	return _adz.playing


## Berapa kali adzan benar-benar mulai diputar sesi ini (tes:
## pemicu ganda tidak boleh menaikkan angka ini selama masih bunyi).
func adzan_jumlah_main() -> int:
	return _adzan_jumlah_main


## SFX — dipicu dari main.gd (langkah: signal SantriPlayer.langkah;
## pintu: _masuk/_keluar Surau/Musholla/Cangkruk; klik: panel UI).
## Diam bila audio belum dimulai (autoplay web — sebelum gestur
## pertama) atau file belum ada; tombol Suara/Senyap (bus Master)
## otomatis membisukan semuanya (tidak perlu cek bisukan() di sini).
func mainkan_langkah(di_lantai: bool) -> void:
	if not _dimulai:
		return
	var varian: Array[AudioStream] = _stream_langkah_lantai if di_lantai else _stream_langkah_tanah
	if varian.is_empty():
		return
	_sfx_langkah.stream = varian[randi() % varian.size()]
	_sfx_langkah.volume_db = DB_LANGKAH
	_sfx_langkah.pitch_scale = randf_range(0.95, 1.05)
	_sfx_langkah.play()
	_langkah_jumlah += 1
	_langkah_lantai_terakhir = di_lantai


func mainkan_pintu(membuka: bool) -> void:
	if not _dimulai:
		return
	var stream: AudioStream = _stream_pintu_buka if membuka else _stream_pintu_tutup
	if stream == null:
		return
	_sfx_pintu.stream = stream
	_sfx_pintu.volume_db = DB_PINTU
	_sfx_pintu.pitch_scale = 1.0
	_sfx_pintu.play()
	_pintu_jumlah += 1


func mainkan_klik() -> void:
	if not _dimulai or _stream_klik == null:
		return
	_sfx_klik.stream = _stream_klik
	_sfx_klik.volume_db = DB_KLIK
	_sfx_klik.pitch_scale = 1.0
	_sfx_klik.play()
	_klik_jumlah += 1


## Berapa kali tiap SFX benar-benar mulai diputar sesi ini (tes).
func langkah_jumlah() -> int:
	return _langkah_jumlah


func pintu_jumlah() -> int:
	return _pintu_jumlah


func klik_jumlah() -> int:
	return _klik_jumlah


## Apakah langkah TERAKHIR memakai varian lantai (true) atau tanah
## (false)? Tes: jalan di luar -> false, jalan di dalam -> true.
func langkah_lantai_terakhir() -> bool:
	return _langkah_lantai_terakhir


## Mute/unmute lewat bus Master (volume player tetap jalan, jadi
## fade tidak rusak saat mute).
func set_mute(mati: bool) -> void:
	AudioServer.set_bus_mute(0, mati)


func bisukan() -> bool:
	return AudioServer.is_bus_mute(0)


## Kegiatan baru ("" = tidak ada kegiatan). Dipanggil main.gd tiap
## frame — hanya bereaksi bila jenis BERUBAH. Bila file bacaan belum
## ada, kegiatan dicatat tapi TIDAK berbunyi dan ambience TIDAK
## di-duck (fallback: ambience biasa).
func set_kegiatan(jenis: String) -> void:
	if jenis == _kegiatan:
		return
	_kegiatan = jenis
	if jenis == "":
		_keg_target_db = DB_DIAM
		_keg_tersedia = false
		return
	var stream: AudioStream = _stream_keg.get(jenis, null)
	if stream == null:
		_keg_tersedia = false
		_keg_target_db = DB_DIAM
		print("[RONDE17] audio kegiatan '" + jenis + "' belum ada — ambience tetap")
		return
	_keg_tersedia = true
	_keg.stream = stream
	_keg.volume_db = DB_DIAM
	_keg_target_db = DB_KEGIATAN
	# Jangan play() sebelum gestur pertama (autoplay web) — mulai()
	# yang akan memutarnya bila sesi masih berjalan.
	if _dimulai:
		_keg.play()
	print("[RONDE17] audio kegiatan mulai: " + jenis)


func _process(delta: float) -> void:
	if not _dimulai:
		return
	# Ambience mengikuti jam — ganti bila fase berubah.
	var key := ambience_untuk_jam(LangitDinamis.jam_saat_ini())
	if key != _amb_key:
		_mulai_crossfade(key)
	# Jalankan crossfade ambience (kalau sedang jalan).
	if _fade_t >= 0.0:
		_fade_t = minf(1.0, _fade_t + delta / DURASI_FADE)
		var target := DB_DUCK if (_keg_tersedia or _adz.playing) else DB_AMBIENCE
		_fade_dari.volume_db = lerpf(_fade_dari.volume_db, DB_DIAM, _fade_t)
		_fade_ke.volume_db = lerpf(DB_DIAM, target, _fade_t)
		if _fade_t >= 1.0:
			_fade_dari.stop()
			_fade_dari.volume_db = DB_DIAM
			_fade_t = -1.0
	else:
		# Tanpa crossfade: ambience meluncur ke target (duck/normal).
		# Adzan men-duck ambience seperti kegiatan (suara adzan jelas).
		var target2 := DB_DUCK if (_keg_tersedia or _adz.playing) else DB_AMBIENCE
		_aktif.volume_db = lerpf(_aktif.volume_db, target2, minf(1.0, delta * 2.0))
	# Kegiatan meluncur ke targetnya; berhenti bila sesi sudah habis.
	# (Stream kegiatan di-loop — tidak ada deteksi "selesai main",
	# jadi tidak bergantung pada AudioStreamPlayer.playing.)
	if _keg_target_db > DB_DIAM or _keg.volume_db > DB_DIAM + 0.5:
		_keg.volume_db = lerpf(_keg.volume_db, _keg_target_db, minf(1.0, delta * 2.0))
		if _keg_target_db <= DB_DIAM and _keg.volume_db <= DB_DIAM + 0.5:
			_keg.stop()


## Ambience pertama (tanpa fade — langsung bunyi setelah gestur).
func _mulai_ambience_langsung(key: String) -> void:
	_amb_key = key
	var stream: AudioStream = _stream_amb.get(key, null)
	if stream == null:
		push_warning("[RONDE17] stream ambience hilang: " + key)
		return
	_aktif.stream = stream
	_aktif.volume_db = DB_AMBIENCE
	_aktif.play()


## Ganti ambience dengan crossfade: cadangan memutar stream baru
## dari diam, aktif meredup, lalu peran bertukar.
func _mulai_crossfade(key: String) -> void:
	_amb_key = key
	var stream: AudioStream = _stream_amb.get(key, null)
	if stream == null:
		push_warning("[RONDE17] stream ambience hilang: " + key)
		return
	_fade_dari = _aktif
	_fade_ke = _cadangan
	_fade_ke.stream = stream
	_fade_ke.volume_db = DB_DIAM
	_fade_ke.play()
	_fade_t = 0.0
	_aktif = _fade_ke
	_cadangan = _fade_dari
