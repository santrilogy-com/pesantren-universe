class_name KameraPesantren
extends RefCounted
## Kamera third-person Pesantren Universe (Cakra, 17 Nov 2026).
##
## RIWAYAT — v1 (17 Nov ~23:45): follow halus + goyang handheld
## (napas saat diam, sway langkah saat jalan) + dinamika framing
## (FOV 60->66, spring +0,6 m, rig merendah saat kencang), acuan
## reel @jipraks ("kamera kayak lensa beneran").
## PERBAIKAN BUG MABUK — v2 (18 Nov ~00:16, laporan Mas dari HP,
## alpha ecd7e2e9): "saat jalan kamera goyang seperti gempa; saat
## diam kamera bergerak sendiri sampai bikin pusing". Akar masalah
## TERUKUR di v1: (1) sway napas saat diam ±0,20° TERUS-MENERUS —
## kamera tidak pernah benar-benar diam; (2) sway jalan 3 sumbu
## ±0,40° pada ~2,3 Hz + FOV berdenyut 60<->66 mengikuti
## kecepatan — di layar HP kecil itu terbaca sebagai gempa.
## KEPUTUSAN: goyang + dinamika framing DIMATIKAN TOTAL (bukan
## dikurangi). Kamera diam = DIAM TOTAL (nol gerakan, dibuktikan
## tes ukur). Kamera jalan = follow halus saja, tanpa bob.
## Yang TERSISA di modul ini — semuanya anti-mabuk:
## 1. Follow eksponensial frame-rate independent (bobot
##    1-exp(-k*delta), selalu <= 1,0 — pelajaran RONDE 5) +
##    SNAP: kalau rig sudah < 5 mm dari target, ditempel persis
##    (tanpa snap, pendekatan eksponensial tidak pernah sampai dan
##    kamera merangkak selamanya — itulah "bergerak sendiri").
## 2. Orbit drag seperti sebelumnya (lerp yaw/pitch 12/dtk).
## 3. Rotasi kamera DI-NOL-KAN tiap frame (cam.rotation = 0) —
##    tidak ada jalur lain yang bisa menggoyang kamera.
## 4. FOV DIKUNCI per zona, tanpa denyut zoom: 68 di luar Asrama
##    (v3 — dulu 60; Normal lebih luas, koreksi Mas 13:13),
##    65 di dalam Asrama (Lestari, 18 Nov 2026 — perbesaran
##    tapak 18x12; portrait butuh bidang lebih lebar). Nilai FOV
##    masuk lewat parameter perbarui() dari main.gd; modul ini
##    hanya menguncinya tiap frame, bukan mengubah-ubahnya.
## 5. Panjang spring DIHALUSKAN ASIMETRIS (terapkan_panjang_spring):
##    memendek CEPAT (25/dtk — keselamatan anti-tembus tetap
##    diutamakan) tapi memanjang PELAN (4/dtk — kamera tidak
##    melonjak keluar saat halangan lewat). Tanpa ini, panjang
##    spring hasil raycast _jarak_kamera_aman bisa melompat
##    frame-ke-frame saat halangan masuk/keluar sinar = getar.
##    SpringArm3D sendiri tetap jadi lapis pertama anti-tembus;
##    penjaga Eka (_jarak_kamera_aman di main.gd) tetap berlaku
##    penuh — modul ini TIDAK memotong hasil raycast, hanya
##    menghaluskan CARA panjang itu diterapkan.
## 6. Bokeh TIDAK dipakai (keputusan tugas awal).
## "Hidup" gaya handheld DIPARKIR sampai verdict HP Mas atas
## versi tenang ini — kalau nanti mau dihidupkan lagi, jalurnya
## lewat modul ini dengan amplitudo jauh di bawah ambang mabuk
## dan tes ukur yang sama (diam = 0, jalan = rotasi 0).
##
## MODE KAMERA — v3 (18 Nov ~13:13, permintaan Mas "Camera tambah..
## drone, low angel, high angel dll. Biar enak" + koreksi 13:13
## "Cukup dicubit enak ngga? ... Cuma yg biasa ini masih belum
## luas kameranya"):
## 7. Lima mode (enum Mode): NORMAL (default) / DRONE / LOW ANGLE /
##    HIGH ANGLE / SINEMATIK. Tiap mode = target tinggi rig +
##    panjang spring + pitch + FOV sendiri (lihat MODE_PARAM).
##    Di mode NORMAL pitch mengikuti drag pemain (_cam_pitch);
##    di mode lain pitch dikunci ke target mode (drag yaw tetap
##    jalan — orbit mengelilingi pemain dari sudut mode itu).
## 8. TRANSISI HALUS: ganti mode TIDAK melompat — tinggi/pitch/FOV
##    efektif di-lerp eksponensial (3,5/dtk) ke target mode baru
##    lalu di-SNAP saat sudah < 0,005 (supaya diam = diam total,
##    bukan merangkak). Panjang spring TIDAK di-lerp di sini:
##    target spring diteruskan ke terapkan_panjang_spring yang
##    sudah punya penghalusan asimetris (cepat memendek, pelan
##    memanjang) — satu jalur, tanpa getar ganda.
## 9. ATURAN ASRAMA MENANG (keputusan Cakra, v3): di dalam Asrama
##    (dan saat tidur) kontrak lama DIJEPIT, bukan mode dinonaktifkan
##    — mode tetap tercatat + nama tetap tampil, tapi parameter
##    efektif = spring 5,5 m (3,0 m bila tidur), pitch dijepit
##    -0,22..-0,10, FOV 65, tinggi rig 1,6 m (0,9 m bila tidur).
##    Alasan: menonaktifkan mode di dalam ruangan membuat tombol
##    terasa mati/rusak; menjepit menjaga kamera DI BAWAH pelat
##    lantai atas (y≈2,8 < 3,0) di semua mode — Drone di dalam
##    Asrama TIDAK PERNAH menembus pelat. Yaw orbit + Sinematik
##    tetap jalan di Asrama (hanya memutar, tidak mengubah tinggi).
##    RUANGAN LAIN (Surau/Cangkruk/Kelas/dll — bukan Asrama):
##    spring dijepit ke <= 4,0 m (kontrak RONDE 7: kamera harus
##    di bawah plafon 3,6 m) + pitch dijepit -0,35..+0,15, FOV
##    tetap ikut mode. Jadi Drone di Surau tidak menembus atap.
## 10. PINCH-TO-ZOOM (koreksi Mas 13:13): zoom = pengali panjang
##     spring (DOLLY, bukan FOV — FOV tetap per mode/zona supaya
##     framing tidak berubah rasa). Jari merenggang = zoom in
##     (mendekat), merapat = zoom out. Faktor target dijepit
##     0,55..1,30 lalu dihaluskan eksponensial 8/dtk (responsif
##     tapi tanpa lompat). Faktor ZOOM itu GLOBAL (satu nilai untuk
##     semua mode, tersimpan selama sesi) — ganti mode tidak
##     me-reset zoom, supaya cubit terasa konsisten "seperti
##     biasa". Batas keras dihitung per frame: spring efektif
##     >= 2,0 m (tidak masuk ke pemain) dan <= 3,0 m bila tidur /
##     <= 5,5 m bila di Asrama / <= 12,0 m di luar. Zoom-out TETAP
##     lewat _jarak_kamera_aman + SpringArm (tidak tembus dinding).
## 11. NORMAL LEBIH LUAS (koreksi Mas 13:13 — keluhan utama):
##     di LUAR ruangan, NORMAL kini spring 8,0 m (dulu 7,0) +
##     FOV 68 (dulu 60). Di dalam Asrama TIDAK berubah (kontrak
##     koridor 5,5 m / FOV 65 tetap). Nilai baru ini yang dikunci
##     tes test_kamera.gd (FOV 68, spring ~8,0).

# --- Follow ---
const IKUT_DATAR := 8.0 ## /dtk, sumbu X/Z.
const IKUT_TEGAK := 6.0 ## /dtk, sumbu Y (lebih kalem).
const PUTAR_YAW := 12.0 ## /dtk, lerp yaw orbit.
const PUTAR_PITCH := 12.0 ## /dtk, lerp pitch orbit.
const SNAP_JARAK := 0.005 ## meter — di bawah ini rig ditempel persis.

# --- Spring (asimetris: cepat memendek, pelan memanjang) ---
const SPRING_PENDEK := 25.0 ## /dtk saat memendek (keselamatan).
const SPRING_PANJANG := 4.0 ## /dtk saat memanjang (halus).
const FOV_TETAP := 60.0

# --- Mode kamera (v3) ---
enum Mode { NORMAL, DRONE, LOW, HIGH, SINEMATIK }
const NAMA_MODE: Array[String] = ["Normal", "Drone", "Low Angle", "High Angle", "Sinematik"]
## Per mode: tinggi rig (m), panjang spring luar ruangan (m),
## pitch (rad; + = kamera rendah memandang ke atas), FOV (derajat).
## NORMAL: pitch -1 artinya "ikut drag pemain" (lihat perbarui).
## LOW tinggi 1,0 m (BUKAN 0,9): kamera di 1,0 - 4*sin(0,15)
## = ~0,40 m di atas tanah. Di 0,9 m kamera duduk di 0,2995 m
## dan bola probe 0,3 m menyentuh tanah persis (0,5 mm) — plus
## tanah tidak rata / paving bisa membuat kamera sungguhan
## menyerempet tanah. 1,0 m tetap low-angle (di bawah mata) tapi
## punya jarak aman 10 cm. (Ditemukan tes 18 Nov 13:5x WIB.)
const MODE_PARAM := {
	Mode.NORMAL: {"tinggi": 1.6, "spring": 8.0, "pitch": -1.0, "fov": 68.0},
	Mode.DRONE: {"tinggi": 1.6, "spring": 10.0, "pitch": -1.05, "fov": 60.0},
	Mode.LOW: {"tinggi": 1.0, "spring": 4.0, "pitch": 0.15, "fov": 65.0},
	Mode.HIGH: {"tinggi": 1.6, "spring": 6.0, "pitch": -0.85, "fov": 60.0},
	Mode.SINEMATIK: {"tinggi": 1.6, "spring": 8.0, "pitch": -0.35, "fov": 68.0},
}
const TRANSISI := 3.5 ## /dtk, lerp tinggi/pitch/FOV saat ganti mode.
const SNAP_PARAM := 0.005 ## di bawah ini nilai efektif ditempel persis.
const PUTAR_SINEMATIK := 0.05 ## rad/dtk — SANGAT pelan (1 putaran ~2 menit).
# --- Asrama (kontrak Lestari — MENANG atas mode, lihat butir 9) ---
const ASRAMA_SPRING := 5.5
const ASRAMA_FOV := 65.0
const ASRAMA_PITCH_MIN := -0.22
const ASRAMA_PITCH_MAKS := -0.10
const TIDUR_SPRING := 3.0
const TIDUR_TINGGI := 0.9
const RUANGAN_SPRING := 4.0 ## jepit ruangan non-Asrama (RONDE 7).
const RUANGAN_PITCH_MIN := -0.35
const RUANGAN_PITCH_MAKS := 0.15
# --- Pinch zoom (v3, butir 10) ---
const ZOOM_MIN := 0.55
const ZOOM_MAKS := 1.30
const ZOOM_HALUS_LAJU := 8.0 ## /dtk, lerp faktor zoom (responsif, tanpa lompat).
const SPRING_MIN_MUTLAK := 2.0 ## kamera tidak boleh lebih dekat dari ini.
const SPRING_MAKS_LUAR := 12.0
# --- Nama di mode Drone (v3, keputusan Mas 13:19: nama tampil
# SELALU dan di Drone harus TERBACA JELAS) ---
const DRONE_LABEL_BOOST := 2.5 ## pengali skala maks label nama di Drone.

var _spring_halus := 8.0
## F1 (Raka, 19 Nov 2026 — perbaikan kamera pinch, disetujui Xam):
## panjang hit SpringArm yang DIHALUSKAN. SpringArm menaruh kamera di
## titik tabrak SEKETIKA (hit-length tidak dihaluskan) — itu sumber
## lompatan kamera S2b/S3b/S5b saat sinar melewati tepi tembok.
var _hit_halus := 8.0
var _mode: int = Mode.NORMAL
var _tinggi_efektif := 1.6
var _pitch_efektif := -0.35
var _fov_efektif := 68.0
var _zoom_target := 1.0
var _zoom_halus := 1.0


## Mode aktif saat ini.
func mode() -> int:
	return _mode


## Nama mode aktif untuk tombol UI / toast.
func nama_mode() -> String:
	return NAMA_MODE[_mode]


## Atur mode (dijepit ke rentang enum). Transisi halus dikerjakan
## perbarui() — panggilan ini sendiri tidak mengubah kamera.
func atur_mode(m: int) -> void:
	_mode = clampi(m, Mode.NORMAL, Mode.SINEMATIK)


## Siklus NORMAL -> DRONE -> LOW -> HIGH -> SINEMATIK -> NORMAL.
## Mengembalikan mode baru.
func mode_berikut() -> int:
	_mode = (_mode + 1) % NAMA_MODE.size()
	return _mode


## Pengali skala MAKS label nama (dibaca main.gd -> meta kamera ->
## Palette.batasi_label_kamera). Drone = 2,5 (nama tetap terbaca
## jelas dari ketinggian — keputusan Mas 13:19); mode lain = 1,0
## (aturan lama tidak berubah).
func pengali_label_drone() -> float:
	return DRONE_LABEL_BOOST if _mode == Mode.DRONE else 1.0


## Yaw otomatis SINEMATIK: putaran SANGAT pelan mengelilingi pemain.
## Mode lain: yaw dikembalikan apa adanya (drag pemain yang mengatur).
func putar_sinematik(delta: float, yaw: float) -> float:
	if _mode == Mode.SINEMATIK:
		return yaw + PUTAR_SINEMATIK * delta
	return yaw


## Pinch-to-zoom: geser faktor target secara RELATIF (faktor < 1 =
## zoom in / mendekat, > 1 = zoom out / menjauh). Dijepit
## 0,55..1,30 — di luar itu cubit tidak berpengaruh lagi.
func geser_zoom(faktor: float) -> void:
	_zoom_target = clampf(_zoom_target * faktor, ZOOM_MIN, ZOOM_MAKS)


## Faktor zoom target (untuk tes) dan faktor halus saat ini.
func zoom_target() -> float:
	return _zoom_target


func zoom_halus() -> float:
	return _zoom_halus


## Target parameter kamera frame ini (SEBELUM penghalusan spring
## asimetris): tinggi rig, spring (sudah dikali zoom halus +
## dijepit zona), pitch, FOV. Dipakai tes untuk memeriksa mode,
## jepit Asrama/ruangan, dan zoom tanpa menunggu transisi selesai.
func parameter_target(di_asrama: bool, tidur: bool, pitch_drag: float, di_ruangan: bool = false) -> Dictionary:
	var p: Dictionary = MODE_PARAM[_mode]
	var tinggi: float = TIDUR_TINGGI if tidur else float(p["tinggi"])
	var spring: float = float(p["spring"])
	var pitch: float = pitch_drag if _mode == Mode.NORMAL else float(p["pitch"])
	var fov: float = float(p["fov"])
	if tidur:
		spring = TIDUR_SPRING
	if di_asrama:
		# KONTRAK ASRAMA MENANG: semua mode dijepit ke nilai aman
		# (spring 5,5 / 3,0 tidur, pitch -0,22..-0,10, FOV 65).
		spring = TIDUR_SPRING if tidur else ASRAMA_SPRING
		pitch = clampf(pitch, ASRAMA_PITCH_MIN, ASRAMA_PITCH_MAKS)
		fov = ASRAMA_FOV
	elif di_ruangan:
		# RUANGAN LAIN (RONDE 7): spring <= 4,0 m + pitch
		# -0,35..+0,15 supaya kamera tetap di bawah plafon.
		spring = minf(spring, RUANGAN_SPRING)
		pitch = clampf(pitch, RUANGAN_PITCH_MIN, RUANGAN_PITCH_MAKS)
	# Zoom (global, sudah dihaluskan di perbarui) + batas keras zona.
	var cap := TIDUR_SPRING if tidur else (ASRAMA_SPRING if di_asrama else (RUANGAN_SPRING if di_ruangan else SPRING_MAKS_LUAR))
	spring = clampf(spring * _zoom_halus, SPRING_MIN_MUTLAK, cap)
	return {"tinggi": tinggi, "spring": spring, "pitch": pitch, "fov": fov}


## Satu panggilan per frame dari main.gd._process.
## pitch_drag = _cam_pitch pemain (hanya dipakai mode NORMAL);
## tidur/di_asrama/di_ruangan = jepit zona (lihat parameter_target).
## Mengembalikan target panjang spring frame ini — main lalu
## meneruskannya ke _jarak_kamera_aman + terapkan_panjang_spring.
func perbarui(delta: float, rig: Node3D, spring: SpringArm3D, cam: Camera3D,
		target_pemain: Vector3, cam_yaw: float, pitch_drag: float,
		tidur: bool, di_asrama: bool, di_ruangan: bool = false) -> float:
	# --- Zoom dihaluskan dulu (8/dtk, responsif tapi tanpa lompat) ---
	var w_zoom := minf(1.0, 1.0 - exp(-ZOOM_HALUS_LAJU * delta))
	_zoom_halus = lerpf(_zoom_halus, _zoom_target, w_zoom)
	if absf(_zoom_halus - _zoom_target) < 0.001:
		_zoom_halus = _zoom_target
	# --- Target mode (+ jepit zona) lalu transisi halus ---
	var t := parameter_target(di_asrama, tidur, pitch_drag, di_ruangan)
	var w := minf(1.0, 1.0 - exp(-TRANSISI * delta))
	_tinggi_efektif = lerpf(_tinggi_efektif, float(t["tinggi"]), w)
	_pitch_efektif = lerpf(_pitch_efektif, float(t["pitch"]), w)
	_fov_efektif = lerpf(_fov_efektif, float(t["fov"]), w)
	if absf(_tinggi_efektif - float(t["tinggi"])) < SNAP_PARAM:
		_tinggi_efektif = float(t["tinggi"])
	if absf(_pitch_efektif - float(t["pitch"])) < SNAP_PARAM:
		_pitch_efektif = float(t["pitch"])
	if absf(_fov_efektif - float(t["fov"])) < SNAP_PARAM:
		_fov_efektif = float(t["fov"])
	# --- Follow: rig mengejar pemain (vertikal lebih kalem) ---
	var target := target_pemain + Vector3(0, _tinggi_efektif, 0)
	var w_datar := minf(1.0, 1.0 - exp(-IKUT_DATAR * delta))
	var w_tegak := minf(1.0, 1.0 - exp(-IKUT_TEGAK * delta))
	var pos := rig.global_position
	pos.x = lerpf(pos.x, target.x, w_datar)
	pos.z = lerpf(pos.z, target.z, w_datar)
	pos.y = lerpf(pos.y, target.y, w_tegak)
	# SNAP anti-drift: di bawah 5 mm, tempel persis — kamera diam
	# harus BERHENTI, bukan merangkak mendekati target selamanya.
	if pos.distance_to(target) < SNAP_JARAK:
		pos = target
	rig.global_position = pos
	# --- Orbit drag (tetap seperti sebelumnya) ---
	rig.rotation.y = lerp_angle(rig.rotation.y, cam_yaw, minf(1.0, delta * PUTAR_YAW))
	spring.rotation.x = lerpf(spring.rotation.x, _pitch_efektif, minf(1.0, delta * PUTAR_PITCH))
	# --- NOL goyang, NOL denyut: rotasi + FOV dikunci tiap frame. ---
	# FOV = nilai efektif hasil transisi mode (bukan denyut).
	cam.rotation = Vector3.ZERO
	cam.fov = _fov_efektif
	return float(t["spring"])


## Terapkan panjang spring AMAN hasil _jarak_kamera_aman dengan
## penghalusan asimetris. Memendek cepat (anti-tembus), memanjang
## pelan (tanpa lonjakan). Mengembalikan panjang yang dipakai.
## F1 (Raka, 19 Nov 2026): haluskan JUGA panjang hit SpringArm —
## spring diterapkan = min(_spring_halus, _hit_halus). _hit_halus
## mengejar get_hit_length() dengan laju asimetris yang sama.
## Jebakan: get_hit_length() <= spring_length SELALU — bila tidak ada
## tabrakan, hit == spring_length dan _hit_halus akan macet di nilai
## itu (tidak pernah memanjang lagi). Jadi bila hit >= spring_length
## (tidak ada tabrakan), targetnya _spring_halus (panjang yang
## diinginkan), bukan hit.
func terapkan_panjang_spring(spring: SpringArm3D, panjang_aman: float, delta: float) -> float:
	var laju := SPRING_PENDEK if panjang_aman < _spring_halus else SPRING_PANJANG
	var w := minf(1.0, 1.0 - exp(-laju * delta))
	_spring_halus = lerpf(_spring_halus, panjang_aman, w)
	# Kalau sudah sangat dekat, tempel persis (tanpa ini panjang
	# merangkak asimtotik dan kamera "bernapas" pelan).
	if absf(_spring_halus - panjang_aman) < 0.01:
		_spring_halus = panjang_aman
	var hit := spring.get_hit_length()
	var target_hit := _spring_halus if hit >= spring.spring_length - 0.01 else hit
	var laju_hit := SPRING_PENDEK if target_hit < _hit_halus else SPRING_PANJANG
	var w_hit := minf(1.0, 1.0 - exp(-laju_hit * delta))
	_hit_halus = lerpf(_hit_halus, target_hit, w_hit)
	if absf(_hit_halus - target_hit) < 0.01:
		_hit_halus = target_hit
	spring.spring_length = minf(_spring_halus, _hit_halus)
	return spring.spring_length


## Panjang hit yang dihaluskan (untuk tes/diagnosis).
func hit_halus() -> float:
	return _hit_halus


## Reset keadaan halus (dipakai setelah teleport/snap supaya spring
## tidak tertinggal dari adegan sebelumnya).
func reset_halus() -> void:
	_spring_halus = 8.0
	_hit_halus = 8.0
