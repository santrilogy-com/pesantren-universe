extends Node
## Tes logika FITUR ADZAN (Sinta, 17 Nov 2026). Dijalankan HEADLESS:
##   godot --headless --path . test_adzan.tscn
## Dua mode (tergantung file audio/adzan.ogg ADA atau TIDAK):
##  A) file ADA — tes jalur putar penuh (dipakai saat rekaman
##     berlisensi sudah diletakkan / file nada tes sementara);
##  B) file TIDAK ADA — tes degradasi halus: banner + sesi tetap
##     jalan, game tidak error, adzan diam.
## Yang diperiksa:
##  1) adzan bunyi (counter +1, playing) tepat saat _mulai_sholat
##     untuk tiap waktu sholat (Subuh 04:30, Dzuhur 12:00, Ashar
##     15:00, Maghrib 18:00, Isya 19:00);
##  2) TIDAK bunyi di luar jendela sholat (jam 10:00);
##  3) TIDAK bunyi dua kali: panggil mainkan_adzan() ulang selagi
##     bunyi + sesi mulai ulang di jendela sama (kunci _sholat_sudah);
##  4) TIDAK bunyi saat mute aktif (tombol Suara/Senyap); bunyi lagi
##     setelah unmute (panggil langsung);
##  5) ambience di-duck (-30 dB) selagi adzan bunyi, kembali normal
##     setelah adzan berhenti;
##  6) adzan yang diminta SEBELUM gestur pertama ditunda, baru bunyi
##     di mulai() (autoplay web).
## TIDAK menyimpan PNG (headless tidak bisa save_png).

var _gagal: int = 0
var _main: Node
var _audio: AudioPesantren


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		print("PASS " + nama + " " + detail)
	else:
		_gagal += 1
		print("FAIL " + nama + " " + detail)


func _ready() -> void:
	LangitDinamis.debug_jam = 10.0
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_main._save["nama"] = "Tes"
	_main._save["id_santri"] = "PV-0001"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["outfit"] = MissionData.OUTFIT_DEFAULT.duplicate()
	_main._masuk_pesantren("Tes adzan")
	await get_tree().process_frame
	await get_tree().process_frame
	_audio = _main._audio
	# Simulasi gestur pertama (di headless tidak ada _input).
	_audio.mulai()

	var ada_file := _audio.adzan_tersedia()
	print("ADZAN FILE: " + ("ADA" if ada_file else "TIDAK ADA"))
	if ada_file:
		await _tes_dengan_file()
	else:
		await _tes_tanpa_file()

	if _gagal == 0:
		print("TES ADZAN: SEMUA LULUS")
	else:
		print("TES ADZAN: " + str(_gagal) + " GAGAL")
	get_tree().quit(_gagal)


## ---- B) file TIDAK ADA: degradasi halus ----
func _tes_tanpa_file() -> void:
	# Di luar jendela: tidak ada sesi, tidak ada adzan.
	LangitDinamis.debug_jam = 10.0
	_main._cek_waktu_sholat()
	_cek("tanpa-file-luar-jendela", not _main._sholat_aktif and _audio.adzan_jumlah_main() == 0)
	# Masuk jendela Subuh: sesi + banner jalan, adzan diam, no crash.
	LangitDinamis.debug_jam = 4.5
	_main._cek_waktu_sholat()
	_cek("tanpa-file-subuh-sesi", _main._sholat_aktif, "nama=" + str(_main._sholat_nama))
	_cek("tanpa-file-subuh-banner", _main._ui._sholat_banner.visible)
	_cek("tanpa-file-subuh-diam", _audio.adzan_jumlah_main() == 0 and not _audio.adzan_dimainkan())
	_main._akhiri_sholat()
	_cek("tanpa-file-akhir-sesi", not _main._sholat_aktif)
	# Jendela lain tetap jalan tanpa file.
	LangitDinamis.debug_jam = 12.0
	_main._cek_waktu_sholat()
	_cek("tanpa-file-dzuhur-sesi", _main._sholat_aktif)
	_cek("tanpa-file-dzuhur-diam", _audio.adzan_jumlah_main() == 0)
	_main._akhiri_sholat()
	# Panggil langsung tanpa file: no-op, tidak crash.
	_audio.mainkan_adzan()
	_cek("tanpa-file-panggil-langsung", _audio.adzan_jumlah_main() == 0)
	# Tertunda sebelum gestur: node baru, mainkan dulu baru mulai().
	var a2 := AudioPesantren.new()
	add_child(a2)
	a2.mainkan_adzan()
	a2.mulai()
	_cek("tanpa-file-tertunda-tetap-diam", a2.adzan_jumlah_main() == 0)
	a2.queue_free()


## ---- A) file ADA: jalur putar penuh ----
func _tes_dengan_file() -> void:
	# Di luar jendela: tidak ada sesi, tidak ada adzan.
	LangitDinamis.debug_jam = 10.0
	_main._cek_waktu_sholat()
	_cek("luar-jendela", not _main._sholat_aktif and _audio.adzan_jumlah_main() == 0, "jam=10.0")

	# Empat waktu pertama dengan suara NYALA (mute mati).
	var jadwal := [
		[4.5, "Subuh"], [12.0, "Dzuhur"], [15.0, "Ashar"], [18.0, "Maghrib"],
	]
	var harap := 0
	for entri in jadwal:
		var jam: float = entri[0]
		var nama: String = entri[1]
		LangitDinamis.debug_jam = jam
		_main._cek_waktu_sholat()
		harap += 1
		_cek("sesi-" + nama, _main._sholat_aktif and _main._sholat_nama == nama, "jam=%.2f" % jam)
		_cek("banner-" + nama, _main._ui._sholat_banner.visible)
		_cek("adzan-bunyi-" + nama, _audio.adzan_jumlah_main() == harap and _audio.adzan_dimainkan(),
			"jumlah=%d harap=%d playing=%s" % [_audio.adzan_jumlah_main(), harap, str(_audio.adzan_dimainkan())])
		# Panggil ulang selagi bunyi: tidak boleh mulai lagi.
		_audio.mainkan_adzan()
		_cek("tanpa-ganda-" + nama, _audio.adzan_jumlah_main() == harap, "jumlah=%d" % _audio.adzan_jumlah_main())
		# Sesi mulai ulang di jendela sama: kunci _sholat_sudah menolak.
		_main._akhiri_sholat()
		_main._cek_waktu_sholat()
		_cek("tanpa-ulang-sesi-" + nama, not _main._sholat_aktif and _audio.adzan_jumlah_main() == harap,
			"jumlah=%d" % _audio.adzan_jumlah_main())
		# Hentikan adzan sebelum waktu berikutnya (nada tes 30 dtk).
		_audio._adz.stop()

	# Ambience di-duck selagi adzan bunyi (jam 12.0 = angin, kunci
	# ambience stabil — tidak ada crossfade yang mengacaukan ukur).
	LangitDinamis.debug_jam = 12.0
	_audio.mainkan_adzan()
	_audio._process(1.0)
	_cek("ambience-duck", is_equal_approx(_audio._aktif.volume_db, -30.0),
		"vol=%.1f" % _audio._aktif.volume_db)
	_audio._adz.stop()
	_audio._process(1.0)
	_cek("ambience-kembali", is_equal_approx(_audio._aktif.volume_db, -16.0),
		"vol=%.1f" % _audio._aktif.volume_db)
	# Tes duck di atas memutar adzan sekali lagi (langsung, tanpa
	# sesi) — sinkronkan penghitung harapan sebelum tes mute.
	harap = _audio.adzan_jumlah_main()

	# MUTE: Isya dengan suara dimatikan — sesi + banner jalan,
	# adzan TIDAK bunyi.
	_audio.set_mute(true)
	LangitDinamis.debug_jam = 19.0
	_main._cek_waktu_sholat()
	_cek("mute-isya-sesi", _main._sholat_aktif and _main._sholat_nama == "Isya")
	_cek("mute-isya-banner", _main._ui._sholat_banner.visible)
	_cek("mute-isya-diam", _audio.adzan_jumlah_main() == harap and not _audio.adzan_dimainkan(),
		"jumlah=%d" % _audio.adzan_jumlah_main())
	_main._akhiri_sholat()
	# Unmute lalu panggil langsung: bunyi lagi.
	_audio.set_mute(false)
	_audio.mainkan_adzan()
	_cek("unmute-bunyi-lagi", _audio.adzan_jumlah_main() == harap + 1 and _audio.adzan_dimainkan(),
		"jumlah=%d" % _audio.adzan_jumlah_main())
	_audio._adz.stop()

	# Tertunda sebelum gestur: node baru, mainkan dulu baru mulai().
	var a2 := AudioPesantren.new()
	add_child(a2)
	a2.mainkan_adzan()
	_cek("tertunda-belum-bunyi", a2.adzan_jumlah_main() == 0 and not a2.adzan_dimainkan())
	a2.mulai()
	_cek("tertunda-bunyi-di-mulai", a2.adzan_jumlah_main() == 1 and a2.adzan_dimainkan())
	a2._adz.stop()
	a2.queue_free()
