extends Node
## Foto mode kamera v3 (Cakra, 18 Nov 2026) — jalankan TANPA --headless:
##   xvfb-run godot --path . skrip/foto_kamera_mode.tscn
## Memakai kamera GAME sendiri (bukan kamera foto terpisah) supaya
## framing antar mode benar-benar sebanding. Lanskap 1280x720
## (game memaksa lanskap — potret memunculkan overlay "PUTAR HP-MU").
## M1 Normal = BUKTI kamera lebih luas (bandingkan dengan
## foto-kamera/sesudah/K1-diam-spawn.png lama: FOV 60 / spring 7,0).
## M6 = Drone DI DALAM Asrama Putra — harus tetap dijepit kontrak
## (spring 5,5 / FOV 65 / kamera di bawah pelat), bukan menembus.

const OUT_DIR := "/home/hatch/workspace/pesantren-verse/v2/foto-kamera-mode/"

var _main: Node
# Nilai save ASLI (dipulihkan di akhir — lihat bawah).
var _nama_asli := ""
var _jk_asli := ""
var _outfit_asli := {}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	get_window().size = Vector2i(1280, 720)
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# SIMPAN nilai save asli DULU (nama + gender + outfit): foto
	# memakai nama "Foto Kamera" + gender putra di MEMORI supaya
	# avatar + label di foto konsisten — tapi _masuk_pesantren
	# memanggil _terapkan_gender_pemain() yang MENYIMPAN seluruh
	# _save ke disk, jadi nilai palsu itu IKUT TERSIMPAN bila
	# tidak dipulihkan (temuan Kirana 14:28: label "Foto Kamera"
	# melayang di depan Surau di foto idle — save disk
	# terkontaminasi). Karena itu di AKHIR _ready: pulihkan ketiganya
	# + save_data SEBELUM quit (lihat bawah). ig_username BOLEH
	# tetap "" di disk (isolasi MP, pola test_v2.gd).
	_nama_asli = String(_main._save.get("nama", ""))
	_jk_asli = String(_main._save.get("jenis_kelamin", "putra"))
	_outfit_asli = (_main._save.get("outfit", {}) as Dictionary).duplicate()
	# ISOLASI MP (pola test_v2.gd): santri.json bisa tertinggal akun
	# tes MP (test_mp_putra/putri) sehingga _masuk_pesantren
	# auto-join server live dan pemain lokal diadopsi avatar server
	# (teleport/foto jadi tidak stabil). Foto harus OFFLINE.
	# Gender + nama JUGA dipaksa SEBELUM masuk: _masuk_pesantren
	# menerapkan gender + nama dari _save di dalamnya — dipaksa
	# sesudah masuk sudah terlambat (foto lama: avatar putri
	# bernama "Tes MP Putri").
	_main._save["ig_username"] = ""
	_main._save["jenis_kelamin"] = "putra"
	_main._save["nama"] = "Foto Kamera"
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Foto mode kamera")
	# (PAKSA putra di sini DULU: _pos_legal_terakhir = SPAWN putra.)
	_main._pos_legal_terakhir = PesantrenBuilder.SPAWN
	for i in 3:
		await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	# M1: NORMAL di spawn (luas — FOV 68 / spring 8,0).
	_atur_mode(0)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M1-normal-luas.png")
	# M2: DRONE.
	_atur_mode(1)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M2-drone.png")
	# M3: LOW ANGLE.
	_atur_mode(2)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M3-low-angle.png")
	# M4: HIGH ANGLE.
	_atur_mode(3)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M4-high-angle.png")
	# M5: SINEMATIK (yaw sudah berputar pelan selama jeda).
	_atur_mode(4)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M5-sinematik.png")
	# M7: NORMAL + pinch zoom-in (faktor 0,6 — spring ~4,8 m).
	_atur_mode(0)
	_main._kamera.geser_zoom(0.6)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M7-normal-zoom-in.png")
	_main._kamera.geser_zoom(1.0 / 0.6)
	# M6: DRONE di dalam Asrama Putra — harus dijepit kontrak.
	# Hadapkan pemain MEMANJANG koridor (yaw PI/2, ke pintu barat):
	# dengan yaw PI bawaan kamera menghantam dinding koridor 2,6 m
	# di 1,2 m (jepit tetap benar, tapi foto jadi close-up kepala).
	_main._masuk_asrama_putra()
	_main._teleport_player(_main._asrama_putra_interior_spawn, PI * 0.5)
	_atur_mode(1)
	await _tunggu_mode(3.0)
	await _foto(OUT_DIR + "M6-asrama-drone-dijepit.png")
	# PULIHKAN save asli (nama + gender + outfit) + simpan ke disk
	# SEBELUM quit — tanpa ini label debug "Foto Kamera" (+ gender
	# putra + outfit non-muslimah) TERTINGGAL di santri.json dan
	# muncul di sesi/foto agen lain (temuan Kirana 14:28). Proses
	# ini tidak menyimpan lagi sesudah titik ini, jadi disk sudah
	# bersih saat quit. (Bila proses mati paksa di tengah jalan,
	# disk tetap terkontaminasi — bersihkan manual: nama akun itu
	# kembali ke nama sebelumnya, di sini "Tes MP Putri".)
	_main._save["nama"] = _nama_asli
	_main._save["jenis_kelamin"] = _jk_asli
	_main._save["outfit"] = _outfit_asli
	SantriSave.save_data(_main._save)
	print("FOTO MODE KAMERA SELESAI — save dipulihkan (nama='%s')" % _nama_asli)
	get_tree().quit(0)


## Atur mode + sinkronkan label tombol HUD (atur_mode() langsung
## TIDAK menyentuh label — label hanya disinkronkan _ganti_mode_
## kamera() saat ganti lewat tombol/keyboard; tanpa ini foto mode
## Drone berlabel "Kamera: Normal" dan menyesatkan).
func _atur_mode(mode: int) -> void:
	_main._kamera.atur_mode(mode)
	_main._ui.set_mode_kamera(_main._kamera.nama_mode())


## Jeda WAKTU (bukan jumlah frame): di VM padat, 1 frame bisa
## 1-2 dtk (render software) — hitungan frame saja membuat foto
## tertangkap sebelum transisi mode selesai.
func _tunggu_mode(detik: float) -> void:
	await get_tree().create_timer(detik).timeout
	for i in 15:
		await get_tree().process_frame


func _foto(path: String) -> void:
	for i in 3:
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(path)
	print("FOTO %s (err=%s)" % [path, str(err)])
