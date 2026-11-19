extends Node
## Tes petunjuk misi santri baru (Raka, 18 Nov 2026 — perintah Mas
## 21:32 WIB: "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang").
## Headless:
##   godot --headless --path . skrip/test_petunjuk_santri_baru.tscn
## Pola test_v2.gd: _cek + hitung lulus/gagal, EXIT 0 bila semua lulus.
## PEMETAAN LANGKAH (penting — jangan "perbaiki" tes ini jadi langkah 1):
## "langkah 1" di kata-kata Mas = santri yang baru masuk dunia. Di kode,
## masuk dunia langsung memajukan 1->2 (_masuk_pesantren), jadi di dunia
## langkah 2 = "Cari Ust. Aqsal M / Ustzh. Mariyah" (sowan) — di situlah
## petunjuk tampil. Langkah 1 (sebelum masuk) TIDAK tampil; langkah 3+
## (sudah sowan) TIDAK tampil lagi.
## Butir tes:
##   - UI murni: teks persis ucapan Mas (huruf kecil "ayo"), putra vs
##     putri, show/hide, mouse_filter IGNORE (tidak memakan sentuhan),
##     posisi y=200 (di bawah tombol Main Bersama + banner sholat);
##   - integrasi main: masuk dunia langkah 1 -> maju 2 -> banner tampil
##     (putra); putri langkah 2 -> teks Ustadzah; langkah 3/5/1 ->
##     sembunyi; dialog sowan dibuka di langkah 2 -> sembunyi.

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


func _ob(langkah: int) -> Dictionary:
	return {"langkah": langkah, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}


func _ready() -> void:
	# ---------- UI murni (tanpa main.tscn) ----------
	var ui := PesantrenUI.new()
	add_child(ui)
	for i in 3:
		await get_tree().process_frame
	_cek("Banner sembunyi saat awal", not ui.is_petunjuk_misi_visible())
	ui.show_petunjuk_misi(false)
	_cek("Show putra -> tampil", ui.is_petunjuk_misi_visible())
	_cek("Teks putra persis ucapan Mas", ui.teks_petunjuk_misi() == "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang")
	ui.show_petunjuk_misi(true)
	_cek("Teks putri persis (Ustadzah)", ui.teks_petunjuk_misi() == "ayo mulai misi santri barumu! Sowan ke Ustadzah sekarang")
	_cek("Banner tidak memakan sentuhan (IGNORE)", ui._petunjuk_misi_banner.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_cek("Banner di y=200 (lewat di bawah tombol Main Bersama + banner sholat)", ui._petunjuk_misi_banner.offset_top == 200.0)
	_cek("Banner tidak selebar layar penuh (<=560)", ui._petunjuk_misi_banner.offset_right - ui._petunjuk_misi_banner.offset_left <= 560.0)
	ui.hide_petunjuk_misi()
	_cek("Hide -> sembunyi", not ui.is_petunjuk_misi_visible())
	ui.queue_free()

	# ---------- integrasi main (headless, pola test_v2.gd) ----------
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	# ISOLASI MP (pola test_v2.gd): kosongkan ig supaya _masuk_pesantren
	# tidak auto-join server live.
	_main._save["ig_username"] = ""
	_main._save["poin"] = 0
	_main._save["nama"] = "Tes"
	_main._save["jenis_kelamin"] = "putra"
	_main._save["onboarding"] = _ob(1)
	_main._masuk_pesantren("Tes petunjuk")
	for i in 3:
		await get_tree().process_frame
	_cek("Masuk dunia langkah 1 -> maju 2", Onboarding.langkah_saat_ini(_main._save) == 2)
	_cek("Santri baru putra -> banner tampil", _main._ui.is_petunjuk_misi_visible())
	_cek("Banner masuk dunia = teks putra", _main._ui.teks_petunjuk_misi() == "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang")

	# Putri langkah 2 -> teks Ustadzah.
	_main._save["jenis_kelamin"] = "putri"
	_main._save["onboarding"] = _ob(2)
	_main._update_hud()
	_cek("Santri baru putri langkah 2 -> banner tampil", _main._ui.is_petunjuk_misi_visible())
	_cek("Banner putri = teks Ustadzah", _main._ui.teks_petunjuk_misi() == "ayo mulai misi santri barumu! Sowan ke Ustadzah sekarang")

	# Sudah sowan (langkah 3) -> sembunyi, tidak muncul lagi.
	_main._save["onboarding"] = _ob(3)
	_main._update_hud()
	_cek("Langkah 3 (sudah sowan) -> sembunyi", not _main._ui.is_petunjuk_misi_visible())
	# Langkah 5 (belajar) -> sembunyi.
	_main._save["onboarding"] = _ob(5)
	_main._update_hud()
	_cek("Langkah 5 -> sembunyi", not _main._ui.is_petunjuk_misi_visible())
	# Langkah 1 di dunia (sebelum masuk) -> sembunyi.
	_main._save["onboarding"] = _ob(1)
	_main._update_hud()
	_cek("Langkah 1 -> sembunyi (tampilnya di langkah 2)", not _main._ui.is_petunjuk_misi_visible())
	# Pop-up petunjuk tombol terbuka di langkah 2 -> banner sembunyi
	# (tidak menumpuk di atas pop-up); begitu pop-up ditutup, banner
	# muncul lagi (via _on_petunjuk_ditutup -> _update_hud).
	_main._save["jenis_kelamin"] = "putra"
	_main._save["onboarding"] = _ob(2)
	_main._ui.coba_tampilkan_petunjuk_awal(false)
	_main._update_hud()
	_cek("Pop-up petunjuk terbuka -> banner sembunyi", not _main._ui.is_petunjuk_misi_visible())
	_main._ui._tutup_petunjuk()
	_cek("Pop-up ditutup -> banner muncul lagi", _main._ui.is_petunjuk_misi_visible())
	# Dialog sowan dibuka di langkah 2 -> sembunyi (cek terakhir,
	# tanpa cleanup — tes selesai sesudah ini).
	_main._save["jenis_kelamin"] = "putra"
	_main._save["onboarding"] = _ob(2)
	_main._update_hud()
	_cek("Langkah 2 sebelum dialog -> tampil", _main._ui.is_petunjuk_misi_visible())
	_main._manajer_misi.buka_dialog("putra")
	_main._update_hud()
	_cek("Dialog sowan dibuka -> banner sembunyi", not _main._ui.is_petunjuk_misi_visible())

	print("HASIL: LULUS=%d GAGAL=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
