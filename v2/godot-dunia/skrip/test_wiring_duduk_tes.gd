extends Node
## TES WIRING DUDUK KURSI + ADEGAN TES DI DALAM KANTOR (Gilang,
## 20 Nov 2026 — konsep tes-di-dalam-kantor Laras, ACC Mas 00:37 WIB;
## pose duduk_kursi Kirana sudah ada di tree).
## Membuktikan lewat main.tscn asli + _masuk_pesantren (pola
## test_npc_20.gd), headless:
##   1. Duduk bangku taman (✕ DUDUK -> duduk_kursi, node di tanah)
##      + berdiri ✕ (BERDIRI -> bangun di samping kursi).
##   2. Kursi diklaim NPC DITOLAK — bangku 1a diklaim -> ditawari 1b;
##      1a+1b diklaim -> tidak ada tombol DUDUK.
##   3. Duduk bersila serambi (pose "duduk", bukan duduk_kursi) +
##      berdiri via △ Aksi -> kembali ke titik yang sama.
##   4. Tes TIDAK terbuka dari luar: langkah 6, pemain di venue lama
##      (-18,18.5) -> _buka_ui_misi_terdekat false, tidak ada panel,
##      ✕ = MASUK KANTOR PUTRA (bukan MULAI MISI).
##   5. Penguji duduk saat langkah 6 (duduk_tes: posisi + yaw) +
##      berdiri_tes() -> titik bangun di belakang kursi.
##   6. Tes terbuka setelah duduk di DALAM kantor: duduk di kursi
##      pemain -> panel "tes" terbuka OTOMATIS; ✕ pertama menutup
##      panel (tetap duduk); ✕ kedua berdiri di titik bangun.
##   7. Penguji TETAP duduk setelah tes selesai selagi pemain masih
##      di dalam kantor; baru berdiri + kembali ke lokasi acak save
##      setelah pemain keluar kantor.
## Jalankan headless (HOME terisolasi — jangan pakai save VM):
##   HOME=/tmp/iso-wiring-duduk-tes godot --headless --path . --scene res://skrip/test_wiring_duduk_tes.tscn

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _tunggu_frame(jumlah: int) -> void:
	for i in jumlah:
		await get_tree().process_frame


func _tunggu_fisika(jumlah: int) -> void:
	for i in jumlah:
		await get_tree().physics_frame


func _set_langkah(langkah: int) -> void:
	_main._save["onboarding"] = {"langkah": langkah, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "musholla", "tes_lulus": 0, "selesai": false}


func _teleport_pemain(pos: Vector3) -> void:
	_main._player.global_position = pos
	_main._player.velocity = Vector3.ZERO
	await _tunggu_frame(2)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await _tunggu_frame(3)
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes Wiring Duduk")
	await _tunggu_frame(5)

	var pemain: Node = _main._player
	var ui: Node = _main._ui
	var manajer: Node = _main._manajer_misi

	# ---------- 1) Duduk bangku taman + berdiri ✕ ----------
	await _teleport_pemain(Vector3(-3.4, 0, 26.5))
	var kursi: Dictionary = _main._kursi_duduk_terdekat()
	_cek("terdekat bangku taman = bangku_taman_putra_1a", String(kursi.get("id", "")) == "bangku_taman_putra_1a")
	_main._update_interact_button()
	_cek("✕ tampil DUDUK di dekat bangku", ui._interact_btn.visible and String(ui._interact_btn.text) == "DUDUK")
	_main._on_interact()
	await _tunggu_fisika(3)
	_cek("duduk bangku -> aksi duduk_kursi", String(pemain.aksi_saat_ini()) == "duduk_kursi")
	_cek("duduk bangku -> kursi_duduk = 1a", String(pemain.kursi_duduk().get("id", "")) == "bangku_taman_putra_1a")
	_cek("duduk bangku -> node di TANAH y=0 (bukan 0,45)", absf(pemain.global_position.y) < 0.05)
	_main._update_interact_button()
	_cek("✕ tampil BERDIRI selagi duduk", ui._interact_btn.visible and String(ui._interact_btn.text) == "BERDIRI")
	_main._on_interact()
	await _tunggu_fisika(3)
	_cek("berdiri ✕ -> aksi berdiri", String(pemain.aksi_saat_ini()) == "berdiri")
	_cek("berdiri ✕ -> kursi_duduk kosong", pemain.kursi_duduk().is_empty())
	_cek("berdiri ✕ -> di titik bangun (-3.4,26.25), BUKAN di atas bangku", Vector2(pemain.global_position.x, pemain.global_position.z).distance_to(Vector2(-3.4, 26.25)) < 0.3)

	# ---------- 2) Kursi diklaim NPC ditolak ----------
	var npc_klaim := SantriNPC.new()
	npc_klaim.set_process(false)
	_cek("klaim 1a berhasil", SantriNPC.klaim_kursi("bangku_taman_putra_1a", npc_klaim))
	await _teleport_pemain(Vector3(-3.4, 0, 26.5))
	var kursi2: Dictionary = _main._kursi_duduk_terdekat()
	_cek("1a diklaim -> ditawari 1b (0,8 m sebelahnya)", String(kursi2.get("id", "")) == "bangku_taman_putra_1b")
	_cek("klaim 1b berhasil", SantriNPC.klaim_kursi("bangku_taman_putra_1b", npc_klaim))
	var kursi3: Dictionary = _main._kursi_duduk_terdekat()
	_cek("1a+1b diklaim -> tidak ada kursi (tombol DUDUK mati)", kursi3.is_empty())
	_main._update_interact_button()
	_cek("✕ tidak tampil DUDUK saat semua bangku dekat diklaim", not (ui._interact_btn.visible and String(ui._interact_btn.text) == "DUDUK"))
	SantriNPC.lepas_kursi(npc_klaim)
	npc_klaim.queue_free()

	# ---------- 3) Duduk bersila serambi + berdiri via △ Aksi ----------
	await _teleport_pemain(Vector3(-2, 0, 3.0))
	var kursi4: Dictionary = _main._kursi_duduk_terdekat()
	_cek("terdekat serambi = serambi_surau_a", String(kursi4.get("id", "")) == "serambi_surau_a")
	_main._on_interact()
	await _tunggu_fisika(3)
	_cek("duduk bersila -> aksi duduk (bukan duduk_kursi)", String(pemain.aksi_saat_ini()) == "duduk")
	_main._on_aksi("berdiri")
	await _tunggu_fisika(3)
	_cek("berdiri △ Aksi dari bersila -> aksi berdiri", String(pemain.aksi_saat_ini()) == "berdiri")
	_cek("berdiri △ Aksi dari bersila -> kembali ke titik yang sama", Vector2(pemain.global_position.x, pemain.global_position.z).distance_to(Vector2(-2, 3.0)) < 0.3)

	# ---------- 4) Tes TIDAK terbuka dari luar ----------
	_set_langkah(6)
	await _tunggu_frame(3)
	await _teleport_pemain(Vector3(-18, 0, 18.5))
	_cek("langkah 6 di venue lama -> _dekat_npc_misi false", not _main._dekat_npc_misi())
	_cek("langkah 6 di venue lama -> _buka_ui_misi_terdekat false", not _main._buka_ui_misi_terdekat())
	_cek("langkah 6 di venue lama -> tidak ada panel terbuka", not manajer.ada_panel_terbuka())
	_main._update_interact_button()
	_cek("✕ di venue lama = MASUK KANTOR PUTRA (bukan MULAI MISI)", ui._interact_btn.visible and String(ui._interact_btn.text) == "MASUK KANTOR PUTRA")

	# ---------- 5) Penguji duduk saat langkah 6 + berdiri_tes ----------
	var sanusi: Node = _main._sanusi
	_main._cek_penguji_tes()
	await _tunggu_frame(5)
	_cek("langkah 6 -> penguji duduk_tes", sanusi.sedang_duduk_tes())
	_cek("penguji di kursi penguji (-90,-298.95)", Vector2(sanusi.global_position.x, sanusi.global_position.z).distance_to(Vector2(-90, -298.95)) < 0.3)
	_cek("penguji node di tanah (y=0)", absf(sanusi.global_position.y) < 0.05)
	_cek("penguji menghadap utara (yaw PI)", absf(absf(sanusi._visual.rotation.y) - PI) < 0.2)
	# API NPC langsung: berdiri_tes -> titik bangun di belakang kursi.
	sanusi.berdiri_tes()
	_cek("berdiri_tes -> tidak duduk lagi", not sanusi.sedang_duduk_tes())
	_cek("berdiri_tes -> titik bangun (-90,-298.15) di belakang kursi", Vector2(sanusi.global_position.x, sanusi.global_position.z).distance_to(Vector2(-90, -298.15)) < 0.3)

	# ---------- 6) Tes terbuka setelah duduk di DALAM kantor ----------
	_main._di_dalam_kantor_putra = true
	await _teleport_pemain(Vector3(-90, 0, -301.9))
	var kursi_tes: Dictionary = _main._kursi_duduk_terdekat()
	_cek("di dalam kantor -> kursi tes pemain", String(kursi_tes.get("id", "")) == "tes_kantor_putra_pemain")
	_main._on_interact()
	await _tunggu_fisika(3)
	_cek("duduk kursi tes -> aksi duduk_kursi", String(pemain.aksi_saat_ini()) == "duduk_kursi")
	_cek("duduk kursi tes -> panel tes terbuka OTOMATIS", manajer.panel_terbuka() == "tes")
	# ✕ pertama: tutup panel dulu, tetap duduk.
	_main._on_interact()
	await _tunggu_frame(2)
	_cek("✕ saat panel tes terbuka -> panel tertutup, tetap duduk", not manajer.ada_panel_terbuka() and String(pemain.aksi_saat_ini()) == "duduk_kursi")
	# ✕ kedua: berdiri di titik bangun (belakang kursi, BUKAN meja).
	_main._on_interact()
	await _tunggu_fisika(3)
	_cek("✕ kedua -> berdiri", String(pemain.aksi_saat_ini()) == "berdiri")
	_cek("berdiri dari kursi tes -> titik bangun (-90,-301.45)", Vector2(pemain.global_position.x, pemain.global_position.z).distance_to(Vector2(-90, -301.45)) < 0.3)

	# ---------- 7) Penguji TETAP duduk sampai pemain keluar ----------
	# Tes selesai (gagal) selagi pemain masih di dalam kantor.
	_cek("gagal_tes 6 -> langkah 5", Onboarding.gagal_tes(_main._save) == 5)
	_main._cek_penguji_tes()
	await _tunggu_frame(3)
	_cek("langkah 5 tapi pemain masih di kantor -> penguji TETAP duduk", sanusi.sedang_duduk_tes())
	_main._di_dalam_kantor_putra = false
	_main._cek_penguji_tes()
	await _tunggu_frame(3)
	_cek("pemain keluar kantor -> penguji berdiri", not sanusi.sedang_duduk_tes())
	var harap_sanusi: Vector3 = LokasiAcak.pos_dari_id("surau")
	_cek("penguji kembali ke lokasi acak save (surau)", sanusi.global_position.distance_to(harap_sanusi) < 0.5)

	print("WIRING-DUDUK-TES LULUS %d GAGAL %d" % [_lulus, _gagal])
	if _gagal > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
