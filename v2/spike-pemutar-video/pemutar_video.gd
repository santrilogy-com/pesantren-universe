class_name PemutarVideoSpike
extends Node
## Spike cara A konsep RB v3: video diputar DI DALAM game (export web)
## lewat elemen <video> HTML + JavaScriptBridge.
##
## Prinsip:
## - Elemen <video> dibuat lewat JS (bukan node Godot), diposisikan
##   fixed di atas canvas, vertikal 9:16 seperti episode Nahwu.
## - Godot mengendalikan: muat / putar / jeda / seek / sembunyikan /
##   tampilkan / hapus — semua lewat jsb.eval.
## - Waktu tonton KUMULATIF (gate 80%) dihitung di sisi JS dari event
##   `timeupdate`: hanya delta maju kecil (<= 1,0 dtk) yang dijumlah;
##   lompat seek maju TIDAK menambah hitungan; seek mundur tidak
##   mengurangi. Tiap tick diteruskan ke Godot lewat create_callback.
## - Godot juga polling status tiap 0,5 dtk (eval JSON) sebagai
##   cadangan bila callback terlewat.
## - Overlay HARUS `pointer-events:none` (video + backdrop): tanpa ini
##   div backdrop (inset:0, z-index di atas canvas) MENELAN semua klik/
##   sentuhan sehingga tombol Godot di bawahnya mati total — terbukti
##   di uji run 1 (klik Putar/Seek tidak sampai ke Godot). Overlay
##   hanya lapisan VISUAL; semua input tetap milik Godot (ketuk area
##   video = klik canvas -> Godot yang menjeda/melanjutkan).
##
## Di luar web (editor/headless): semua fungsi aman no-op + sinyal
## galat, supaya tes logika tetap bisa jalan tanpa browser.

signal siap
signal metadata_diterima(durasi: float)
signal waktu_berubah(posisi: float, ditonton: float, durasi: float)
signal video_selesai
signal galat(pesan: String)

## Ambang gate konsep v3 (opsi A): 80% durasi harus benar-benar diputar.
const GATE_PERSEN := 0.80
## Batas delta timeupdate yang dihitung (seek maju = lompat > 1 dtk).
const DELTA_MAKS_DETIK := 1.0

var durasi: float = 0.0
var posisi: float = 0.0
var ditonton: float = 0.0
var sedang_putar: bool = false
var sudah_dimuat: bool = false

var _jsb: Variant = null
var _timer_poll: Timer = null

## JS pembuat elemen video. Satu string utuh supaya bisa di-eval sekali.
## window.__pv_* = namespace spike (hindari bentrok dengan game).
const JS_BUAT_VIDEO := """
(function(){
  if (window.__pv_video) return 'sudah-ada';
  var v = document.createElement('video');
  v.id = 'pv-video';
  v.src = 'episode-contoh.mp4';
  v.playsInline = true;
  v.preload = 'metadata';
  v.style.cssText = 'position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);height:78vh;aspect-ratio:9/16;max-width:92vw;background:#000;z-index:2147483646;object-fit:contain;pointer-events:none;';
  var bg = document.createElement('div');
  bg.id = 'pv-backdrop';
  bg.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.72);z-index:2147483645;pointer-events:none;';
  document.body.appendChild(bg);
  document.body.appendChild(v);
  window.__pv_video = v;
  window.__pv_backdrop = bg;
  window.__pv_watched = 0;
  window.__pv_last_t = 0;
  window.__pv_durasi = 0;
  window.__pv_autoplay = null;
  v.addEventListener('loadedmetadata', function(){
    window.__pv_durasi = v.duration;
    if (window.__pv_cb_meta) window.__pv_cb_meta(v.duration);
  });
  v.addEventListener('timeupdate', function(){
    if (!v.paused && !v.seeking) {
      var d = v.currentTime - window.__pv_last_t;
      if (d >= 0 && d <= 1.0) { window.__pv_watched += d; }
    }
    window.__pv_last_t = v.currentTime;
    if (window.__pv_cb_tick) window.__pv_cb_tick(v.currentTime, window.__pv_watched, v.duration);
  });
  v.addEventListener('seeked', function(){ window.__pv_last_t = v.currentTime; });
  v.addEventListener('ended', function(){ if (window.__pv_cb_ended) window.__pv_cb_ended(); });
  v.addEventListener('error', function(){ if (window.__pv_cb_err) window.__pv_cb_err(v.error ? (v.error.code || -1) : -1); });
  return 'dibuat';
})()
"""

const JS_STATUS := """
(function(){
  var v = window.__pv_video;
  if (!v) return '';
  return JSON.stringify({ada:true, durasi:(v.duration||0), posisi:(v.currentTime||0), ditonton:(window.__pv_watched||0), jeda:v.paused, berakhir:v.ended, tampil:(v.style.display !== 'none'), autoplay:(window.__pv_autoplay||null)});
})()
"""


func _ready() -> void:
	_jsb = Engine.get_singleton("JavaScriptBridge")
	_timer_poll = Timer.new()
	_timer_poll.wait_time = 0.5
	_timer_poll.autostart = false
	_timer_poll.timeout.connect(_on_poll)
	add_child(_timer_poll)


## True bila berjalan di export web (punya JavaScriptBridge).
func di_web() -> bool:
	return OS.has_feature("web") and _jsb != null


## Buat elemen <video> + daftarkan callback JS -> Godot.
## url dipakai apa adanya sebagai src (relatif terhadap index.html).
func muat(url: String) -> void:
	if not di_web():
		galat.emit("bukan export web — JavaScriptBridge tidak ada")
		return
	var window = _jsb.get_interface("window")
	window.__pv_cb_tick = _jsb.create_callback(_on_tick)
	window.__pv_cb_meta = _jsb.create_callback(_on_meta)
	window.__pv_cb_ended = _jsb.create_callback(_on_ended)
	window.__pv_cb_err = _jsb.create_callback(_on_error_js)
	var js_buat: String = JS_BUAT_VIDEO.replace("episode-contoh.mp4", url)
	var hasil = _jsb.eval(js_buat)
	print("[SpikeVideo] muat -> ", hasil)
	sudah_dimuat = true
	_timer_poll.start()
	siap.emit()


func putar() -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video) { window.__pv_video.play(); }")
	sedang_putar = true


func jeda() -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video) { window.__pv_video.pause(); }")
	sedang_putar = false


func seek(detik: float) -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video) { window.__pv_video.currentTime = %f; }" % detik)


func sembunyikan() -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video) { window.__pv_video.style.display = 'none'; } if (window.__pv_backdrop) { window.__pv_backdrop.style.display = 'none'; }")


func tampilkan() -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video) { window.__pv_video.style.display = ''; } if (window.__pv_backdrop) { window.__pv_backdrop.style.display = ''; }")


func minta_layar_penuh() -> void:
	if not di_web() or not sudah_dimuat:
		return
	_jsb.eval("if (window.__pv_video && window.__pv_video.requestFullscreen) { window.__pv_video.requestFullscreen(); }")


func hapus() -> void:
	if not di_web():
		return
	_timer_poll.stop()
	_jsb.eval("if (window.__pv_video) { window.__pv_video.pause(); window.__pv_video.remove(); window.__pv_video = null; } if (window.__pv_backdrop) { window.__pv_backdrop.remove(); window.__pv_backdrop = null; }")
	sudah_dimuat = false
	sedang_putar = false


## Persen gate yang tercapai (0..100+). 100 = sudah memutar 80% durasi.
func persen_gate() -> float:
	if durasi <= 0.0:
		return 0.0
	return (ditonton / (durasi * GATE_PERSEN)) * 100.0


func gate_tercapai() -> bool:
	return durasi > 0.0 and ditonton >= durasi * GATE_PERSEN


## Status lengkap dari sisi JS (dipakai polling + tes).
func status_js() -> Dictionary:
	if not di_web() or not sudah_dimuat:
		return {}
	var teks = _jsb.eval(JS_STATUS)
	if typeof(teks) != TYPE_STRING or (teks as String).is_empty():
		return {}
	var data: Variant = JSON.parse_string(teks)
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	return data


func _on_tick(args: Array) -> void:
	if args.size() < 3:
		return
	posisi = float(args[0])
	ditonton = float(args[1])
	durasi = float(args[2])
	waktu_berubah.emit(posisi, ditonton, durasi)


func _on_meta(args: Array) -> void:
	if args.size() < 1:
		return
	durasi = float(args[0])
	print("[SpikeVideo] metadata: durasi = ", durasi)
	metadata_diterima.emit(durasi)


func _on_ended(_args: Array) -> void:
	sedang_putar = false
	print("[SpikeVideo] video berakhir (ended)")
	video_selesai.emit()


func _on_error_js(args: Array) -> void:
	var kode := int(args[0]) if args.size() > 0 else -1
	print("[SpikeVideo] GALAT elemen video, kode MediaError = ", kode)
	galat.emit("galat video kode %d" % kode)


func _on_poll() -> void:
	var st := status_js()
	if st.is_empty():
		return
	posisi = float(st.get("posisi", posisi))
	ditonton = float(st.get("ditonton", ditonton))
	durasi = float(st.get("durasi", durasi))
	sedang_putar = not bool(st.get("jeda", true))
	waktu_berubah.emit(posisi, ditonton, durasi)
