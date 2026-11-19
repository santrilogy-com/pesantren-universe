extends Node
## Tes teka-teki mencari guru + babak 5 baru (Raka, 18 Nov 2026).
## Perintah Mas 22:59 WIB ("Misal bisa tanya ke NPC atau satpam..
## jadi dibikin kek teka-teki..") + dialog penutup aneh — draf Laras
## DI-ACC Mas 23:03 WIB (Ya tambah / Ya / Ya boleh).
## CAKUPAN: DataTekaTeki (12 teka-teki verbatim + logika murni),
## babak 5 baru (teks + 2 pilihan pamit), DialogMisi mode tanya /
## pesan, ManajerUIMisi buka_tanya / buka_teka_teki, PanelMisiUI
## kartu "Petunjuk terakhir", kunci save "tanya_guru", outfit +
## wiring NPC Penjaga Pos Jaga putri (CEWE — koreksi Mas 23:04 WIB).
## Headless (user-dir TERISOLASI — jangan pakai save VM):
##   HOME=/tmp/iso-teka XDG_DATA_HOME=/tmp/iso-teka/.local/share godot --headless --path . --scene res://skrip/test_teka_teki.tscn
## Pola test_ui_misi.gd / test_fatimah.gd: _cek + hitung lulus/gagal,
## EXIT 0 bila semua lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## Cari teks di semua Label di bawah node (rekursif — pola test_ui_misi).
func _ada_teks(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	for anak in node.get_children():
		if _ada_teks(anak, cari):
			return true
	return false


## Seperti _ada_teks, tapi juga cocok dengan teks Button (pilihan
## "Tanya tentang …" / "Sapa saja" / "Tutup" adalah Button, bukan
## Label — _ada_teks saja tidak pernah menemukannya).
func _ada_teks_ui(node: Node, cari: String) -> bool:
	if node is Label and String((node as Label).text).contains(cari):
		return true
	if node is Button and String((node as Button).text).contains(cari):
		return true
	for anak in node.get_children():
		if _ada_teks_ui(anak, cari):
			return true
	return false


func _isi_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


## Save putra langkah 4 dengan lokasi Sanusi tertentu.
func _save_putra_langkah4(lok_id: String) -> Dictionary:
	var s := SantriSave.default_data()
	s["jenis_kelamin"] = "putra"
	s["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": lok_id, "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	return s


## Save putri langkah 4 dengan lokasi Fatimah tertentu.
func _save_putri_langkah4(lok_id: String) -> Dictionary:
	var s := SantriSave.default_data()
	s["jenis_kelamin"] = "putri"
	s["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": lok_id, "tes_lulus": 0, "selesai": false}
	return s


func _ready() -> void:
	# ---------- A. Tabel teka-teki: 12 entri verbatim draf ----------
	_cek("Teka-teki: tabel 12 entri", DataTekaTeki.TEKA_TEKI.size() == 12)
	var id_putra := ["surau", "kelas_putra", "taman_surau", "perpustakaan_taman", "taman_putra", "kantin"]
	var id_putri := ["musholla_putri", "kelas_putri", "taman_putri", "asrama_putri", "kantor_ustadzah", "halaman_putri"]
	var semua_ada := true
	var semua_isi := true
	for lok_id in id_putra + id_putri:
		if not DataTekaTeki.ada(lok_id):
			semua_ada = false
		if DataTekaTeki.teka_teki_untuk(lok_id) == "":
			semua_isi = false
	_cek("Teka-teki: 6 putra + 6 putri semua ada", semua_ada)
	_cek("Teka-teki: semua punya teks (tidak kosong)", semua_isi)
	_cek("Teka-teki: id tak dikenal -> ''", DataTekaTeki.teka_teki_untuk("tidak_ada") == "" and not DataTekaTeki.ada("tidak_ada"))
	# Verbatim draf (2 contoh per gender — sisanya dicek di laporan).
	_cek("Teka-teki: surau verbatim draf", DataTekaTeki.teka_teki_untuk("surau") == "Tempat sholat berjamaah paling ramai di pesantren — beliau sering duduk di sana menunggu waktu sholat.")
	_cek("Teka-teki: kantin verbatim draf", DataTekaTeki.teka_teki_untuk("kantin") == "Kalau perut lapar, santri larinya ke mana? Ke sanalah beliau mungkin pergi.")
	_cek("Teka-teki: musholla_putri verbatim draf", DataTekaTeki.teka_teki_untuk("musholla_putri") == "Tempat sholat para santriwati — beliau sering duduk di sana.")
	_cek("Teka-teki: taman_putri verbatim draf", DataTekaTeki.teka_teki_untuk("taman_putri") == "Tempat bunga warna-warni bermekaran — beliau suka duduk tenang di sana.")
	# Teka-teki TIDAK menyebut nama lokasinya langsung (frasa nama
	# lengkap — kata "Taman"/"Surau" di dalam kalimat boleh, itu
	# kata biasa, bukan nama lokasi).
	var tidak_bocor := true
	for k in LokasiAcak.KANDIDAT:
		var teks := DataTekaTeki.teka_teki_untuk(String(k["id"]))
		if teks.to_lower().contains(String(k["nama"]).to_lower()):
			tidak_bocor = false
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var teks := DataTekaTeki.teka_teki_untuk(String(k["id"]))
		if teks.to_lower().contains(String(k["nama"]).to_lower()):
			tidak_bocor = false
	_cek("Teka-teki: tidak ada yang menyebut nama lokasinya langsung", tidak_bocor)
	# Pembuka NPC (draf §3 — hanya Satpam + Bilal).
	_cek("Teka-teki: pembuka Satpam verbatim draf", DataTekaTeki.pembuka_untuk("satpam") == "Hmm, terakhir kulihat beliau ke arah…")
	_cek("Teka-teki: pembuka Bilal verbatim draf", DataTekaTeki.pembuka_untuk("bilal") == "Aku tadi lihat beliau lewat, coba tebak…")
	_cek("Teka-teki: NPC lain tanpa pembuka khusus", DataTekaTeki.pembuka_untuk("faris") == "" and DataTekaTeki.pembuka_untuk("kyai") == "" and DataTekaTeki.pembuka_untuk("mariyah") == "" and DataTekaTeki.pembuka_untuk("penjaga_putri") == "")
	_cek("Teka-teki: teks ulang verbatim draf §6", DataTekaTeki.TEKS_ULANG == "Itu tadi petunjuknya — coba cari dulu, nanti tanya lagi kalau masih bingung.")

	# ---------- B. Logika murni: teka-teki saat ini + guru ----------
	_cek("Logika: putra langkah 4 kantin -> teka-teki kantin", DataTekaTeki.teka_teki_saat_ini(_save_putra_langkah4("kantin")) == DataTekaTeki.teka_teki_untuk("kantin"))
	_cek("Logika: putri langkah 4 taman_putri -> teka-teki taman_putri", DataTekaTeki.teka_teki_saat_ini(_save_putri_langkah4("taman_putri")) == DataTekaTeki.teka_teki_untuk("taman_putri"))
	_cek("Logika: guru putra = Ust. Sanusi, putri = Ustzh. Fatimah", DataTekaTeki.guru_saat_ini(_save_putra_langkah4("surau")) == "Ust. Sanusi" and DataTekaTeki.guru_saat_ini(_save_putri_langkah4("surau")) == "Ustzh. Fatimah")
	var s_langkah3 := _save_putra_langkah4("surau")
	s_langkah3["onboarding"] = {"langkah": 3, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_cek("Logika: langkah 3 (bukan cari guru) -> teka-teki ''", DataTekaTeki.teka_teki_saat_ini(s_langkah3) == "")
	var s_langkah5 := _save_putra_langkah4("surau")
	s_langkah5["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_cek("Logika: langkah 5 (guru ketemu) -> teka-teki '' (pilihan tanya hilang)", DataTekaTeki.teka_teki_saat_ini(s_langkah5) == "")
	_cek("Logika: lokasi tak valid -> teka-teki '' (jaga-jaga, tidak bocor)", DataTekaTeki.teka_teki_saat_ini(_save_putra_langkah4("tidak_ada")) == "")

	# ---------- C. Siapa boleh ditanya (draf §2 + keputusan Mas no. 3) ----------
	var s4_putra := _save_putra_langkah4("surau")
	_cek("Tanya: putra langkah 4 boleh tanya Kyai (boleh ditanya ulang)", DataTekaTeki.npc_bisa_ditanya(s4_putra, "kyai"))
	_cek("Tanya: putra langkah 4 boleh tanya Bilal/Faris/Satpam", DataTekaTeki.npc_bisa_ditanya(s4_putra, "bilal") and DataTekaTeki.npc_bisa_ditanya(s4_putra, "faris") and DataTekaTeki.npc_bisa_ditanya(s4_putra, "satpam"))
	_cek("Tanya: putra TIDAK boleh tanya Mariyah/Penjaga/Fatimah", not DataTekaTeki.npc_bisa_ditanya(s4_putra, "mariyah") and not DataTekaTeki.npc_bisa_ditanya(s4_putra, "penjaga_putri") and not DataTekaTeki.npc_bisa_ditanya(s4_putra, "fatimah"))
	var s4_putri := _save_putri_langkah4("taman_putri")
	_cek("Tanya: putri langkah 4 boleh tanya Mariyah + Penjaga Pos Jaga", DataTekaTeki.npc_bisa_ditanya(s4_putri, "mariyah") and DataTekaTeki.npc_bisa_ditanya(s4_putri, "penjaga_putri"))
	_cek("Tanya: putri TIDAK boleh tanya Kyai/Bilal/Satpam/Fatimah", not DataTekaTeki.npc_bisa_ditanya(s4_putri, "kyai") and not DataTekaTeki.npc_bisa_ditanya(s4_putri, "bilal") and not DataTekaTeki.npc_bisa_ditanya(s4_putri, "satpam") and not DataTekaTeki.npc_bisa_ditanya(s4_putri, "fatimah"))
	_cek("Tanya: langkah 3 tidak boleh tanya siapa pun", not DataTekaTeki.npc_bisa_ditanya(s_langkah3, "bilal") and not DataTekaTeki.npc_bisa_ditanya(s_langkah3, "kyai"))
	_cek("Tanya: langkah 5 tidak boleh tanya siapa pun", not DataTekaTeki.npc_bisa_ditanya(s_langkah5, "bilal") and not DataTekaTeki.npc_bisa_ditanya(s_langkah5, "satpam"))

	# ---------- D. Anti-spam: satu NPC satu petunjuk per misi ----------
	var s_anti := _save_putra_langkah4("surau")
	_cek("Anti-spam: awal belum ada yang ditanya", not DataTekaTeki.sudah_ditanya(s_anti, "bilal"))
	DataTekaTeki.catat_tanya(s_anti, "bilal")
	_cek("Anti-spam: catat Bilal -> sudah ditanya", DataTekaTeki.sudah_ditanya(s_anti, "bilal"))
	_cek("Anti-spam: NPC lain masih boleh (teka-teki sama)", not DataTekaTeki.sudah_ditanya(s_anti, "satpam"))
	DataTekaTeki.catat_tanya(s_anti, "bilal")
	_cek("Anti-spam: catat ulang tidak duplikat", (s_anti.get("tanya_guru", []) as Array).count("bilal") == 1)
	# Reset tiap masuk langkah 4 (Onboarding.maju 3 -> 4).
	var s_reset := _save_putra_langkah4("surau")
	s_reset["onboarding"] = {"langkah": 3, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	s_reset["tanya_guru"] = ["bilal", "satpam"]
	_cek("Anti-spam: maju 3->4 (misi baru) -> langkah 4 + flag tanya direset", Onboarding.maju(s_reset) == 4 and (s_reset.get("tanya_guru", []) as Array).is_empty())
	var s_reset2 := _save_putra_langkah4("surau")
	s_reset2["tanya_guru"] = ["bilal"]
	Onboarding.reset(s_reset2)
	_cek("Anti-spam: Onboarding.reset() ikut membersihkan flag tanya", (s_reset2.get("tanya_guru", []) as Array).is_empty())
	_cek("Save: default_data punya tanya_guru (Array)", SantriSave.default_data().has("tanya_guru") and SantriSave.default_data()["tanya_guru"] is Array)

	# ---------- E. Babak 5 baru (verbatim Laras, DI-ACC Mas 23:03) ----------
	var b5 := DataDialogMisi.babak(5, "putra")
	_cek("Babak 5: putra verbatim Laras", String(b5.get("teks", "")) == "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat belajarnya. Sekarang berangkatlah mencari Ust. Sanusi — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya saja ke santri lain atau ke satpam di pos jaga. Semoga Allah mudahkan langkahmu.")
	var b5p := DataDialogMisi.babak(5, "putri")
	_cek("Babak 5: putri verbatim Laras (Fatimah + kembali ke saya)", String(b5p.get("teks", "")) == "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat belajarnya. Sekarang berangkatlah mencari Ustzh. Fatimah — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya saja ke santriwati lain atau kembali ke saya. Semoga Allah mudahkan langkahmu.")
	_cek("Babak 5: 2 pilihan pamit, keduanya ke -1", (b5.get("pilihan", []) as Array).size() == 2 and int((b5["pilihan"][0] as Dictionary).get("ke", 0)) == -1 and int((b5["pilihan"][1] as Dictionary).get("ke", 0)) == -1)
	_cek("Babak 5: pilihan 1 berangkat mencari beliau", String(((b5.get("pilihan", []) as Array)[0] as Dictionary).get("teks", "")) == "Baik, Ustadz. Saya berangkat mencari beliau sekarang.")
	_cek("Babak 5: pilihan 2 pamit dulu", String(((b5.get("pilihan", []) as Array)[1] as Dictionary).get("teks", "")) == "Terima kasih, Ustadz. Saya pamit dulu.")
	_cek("Babak 5: pilihan putri menyapa Ustadzah", String(((b5p.get("pilihan", []) as Array)[0] as Dictionary).get("teks", "")).contains("Ustadzah"))
	_cek("Babak 5: teks lama (catatan panggung) sudah hilang", not String(b5.get("teks", "")).contains("Penutup —"))
	_cek("Babak 4: TIDAK berubah (Penugasan pertama + substitusi putri)", String(DataDialogMisi.babak(4, "putra").get("teks", "")).contains("Penugasan pertama") and String(DataDialogMisi.babak(4, "putri").get("teks", "")).contains("Ustzh. Fatimah"))
	_cek("Babak 1: TIDAK berubah (Ahlan wa sahlan)", String(DataDialogMisi.babak(1, "putra").get("teks", "")).contains("Ahlan wa sahlan"))

	# ---------- F. DialogMisi mode tanya / pesan ----------
	var dlg := DialogMisi.new()
	add_child(dlg)
	var tanya_ev: Array = []
	dlg.pilihan_tanya.connect(func(id_pilihan: String) -> void: tanya_ev.append(id_pilihan))
	dlg.tampilkan_tanya("Bilal", "Santri", "sanusi", "Kamu mendekati Bilal. Mau bertanya tentang Ust. Sanusi?", "Tanya tentang Ust. Sanusi")
	_cek("Dialog tanya: tampil + nama + teks + footer Tanya NPC (bukan Babak)", dlg.visible and _ada_teks(dlg, "Bilal") and _ada_teks_ui(dlg, "Tanya tentang Ust. Sanusi") and _ada_teks(dlg, "Tanya NPC") and not _ada_teks(dlg, "Babak 1 dari 5"))
	_cek("Dialog tanya: pilihan Sapa saja ada", _ada_teks_ui(dlg, "Sapa saja"))
	dlg._on_tanya_dipilih("tanya")
	_cek("Dialog tanya: pilih Tanya -> sembunyi + sinyal tanya", not dlg.visible and tanya_ev == ["tanya"])
	dlg.tampilkan_tanya("Satpam", "Penjaga Gerbang", "kyai", "Kamu mendekati Satpam. Mau bertanya tentang Ust. Sanusi?", "Tanya tentang Ust. Sanusi")
	dlg._on_tanya_dipilih("sapa")
	_cek("Dialog tanya: pilih Sapa -> sembunyi + sinyal sapa", not dlg.visible and tanya_ev == ["tanya", "sapa"])
	var pesan_ditutup_ev: Array = []
	var pesan_selesai_ev: Array = []
	dlg.ditutup.connect(func() -> void: pesan_ditutup_ev.append(true))
	dlg.selesai.connect(func() -> void: pesan_selesai_ev.append(true))
	dlg.tampilkan_pesan("Bilal", "Santri", "sanusi", DataTekaTeki.teka_teki_untuk("kantin"))
	_cek("Dialog pesan: tampil + teka-teki kantin + footer Petunjuk + tombol Tutup", dlg.visible and _ada_teks(dlg, "Kalau perut lapar") and _ada_teks(dlg, "Petunjuk") and _ada_teks_ui(dlg, "Tutup"))
	dlg._on_pesan_ditutup()
	_cek("Dialog pesan: Tutup -> sembunyi + ditutup (TANPA selesai — langkah tidak maju)", not dlg.visible and not pesan_ditutup_ev.is_empty() and pesan_selesai_ev.is_empty())
	# Dialog 5 babak tetap jalan (regresi tampilkan()).
	dlg.tampilkan("putra")
	_cek("Dialog babak: tampilkan() tetap babak 1 + footer Babak 1 dari 5", dlg.visible and _ada_teks(dlg, "Ahlan wa sahlan") and _ada_teks(dlg, "Babak 1 dari 5"))
	dlg.queue_free()

	# ---------- G. ManajerUIMisi: buka_tanya / buka_teka_teki ----------
	var mj := ManajerUIMisi.new()
	add_child(mj)
	var mj_tanya_ev: Array = []
	mj.tanya_dipilih.connect(func(npc_id: String) -> void: mj_tanya_ev.append(npc_id))
	mj.buka_tanya("Satpam", "Penjaga Gerbang", "kyai", "Kamu mendekati Satpam. Mau bertanya tentang Ust. Sanusi?", "Tanya tentang Ust. Sanusi", "satpam")
	_cek("Manajer tanya: panel dialog terbuka + dim tampil", mj.ada_panel_terbuka() and mj.panel_terbuka() == "dialog" and mj._dim.visible)
	mj._dialog._on_tanya_dipilih("tanya")
	_cek("Manajer tanya: pilih Tanya -> sinyal tanya_dipilih(satpam)", mj_tanya_ev == ["satpam"])
	mj.buka_tanya("Bilal", "Santri", "sanusi", "Kamu mendekati Bilal. Mau bertanya tentang Ust. Sanusi?", "Tanya tentang Ust. Sanusi", "bilal")
	mj._dialog._on_tanya_dipilih("sapa")
	_cek("Manajer tanya: pilih Sapa -> TIDAK ada sinyal tanya", mj_tanya_ev == ["satpam"])
	mj.buka_teka_teki("Satpam", "Penjaga Gerbang", "kyai", DataTekaTeki.teka_teki_untuk("surau"))
	_cek("Manajer teka-teki: panel dialog terbuka + teka-teki surau tampil", mj.ada_panel_terbuka() and _ada_teks(mj._dialog, "Tempat sholat berjamaah paling ramai"))
	mj.tutup_semua()
	_cek("Manajer tanya: tutup_semua -> tidak ada panel + dim mati", not mj.ada_panel_terbuka() and not mj._dim.visible)
	mj.queue_free()

	# ---------- H. PanelMisiUI: kartu Petunjuk terakhir ----------
	var pm := PanelMisiUI.new()
	add_child(pm)
	var pm_save := _save_putra_langkah4("surau")
	pm_save["tanya_guru"] = ["bilal"]
	pm.tampilkan(pm_save)
	_cek("Panel: langkah 4 + sudah tanya -> kartu PETUNJUK TERAKHIR + teka-teki surau", _ada_teks(pm, "PETUNJUK TERAKHIR") and _ada_teks(pm, "Tempat sholat berjamaah paling ramai"))
	pm.tampilkan(_save_putra_langkah4("surau"))
	_cek("Panel: langkah 4 BELUM tanya -> kartu petunjuk TIDAK muncul (tidak bocor)", not _ada_teks(pm, "PETUNJUK TERAKHIR"))
	var pm_save5 := _save_putra_langkah4("surau")
	pm_save5["onboarding"] = {"langkah": 5, "modul": 1, "sanusi_lokasi": "surau", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	pm_save5["tanya_guru"] = ["bilal"]
	pm.tampilkan(pm_save5)
	_cek("Panel: langkah 5 (guru ketemu) -> kartu petunjuk TIDAK muncul", not _ada_teks(pm, "PETUNJUK TERAKHIR"))
	var pm_putri := _save_putri_langkah4("taman_putri")
	pm_putri["tanya_guru"] = ["mariyah"]
	pm.tampilkan(pm_putri)
	_cek("Panel: putri langkah 4 + sudah tanya -> teka-teki taman_putri tampil", _ada_teks(pm, "PETUNJUK TERAKHIR") and _ada_teks(pm, "Tempat bunga warna-warni bermekaran"))
	pm.tutup()
	pm.queue_free()

	# ---------- I. Outfit + wiring Penjaga Pos Jaga putri (CEWE) ----------
	_cek("Penjaga: outfit muslimah + hijab + abaya jati (bukan satpam cowok)", bool(MissionData.OUTFIT_PENJAGA_PUTRI.get("muslimah", false)) and bool(MissionData.OUTFIT_PENJAGA_PUTRI.get("hijab", false)) and String(MissionData.OUTFIT_PENJAGA_PUTRI.get("abaya", "")) == "#7b4b2a")
	_cek("Penjaga: abaya beda dari Mariyah (#065f46) + Fatimah (#043b2c)", String(MissionData.OUTFIT_PENJAGA_PUTRI.get("abaya", "")) != String(MissionData.OUTFIT_USTADZAH.get("abaya", "")) and String(MissionData.OUTFIT_PENJAGA_PUTRI.get("abaya", "")) != "#043b2c")
	var built := SantriPlayer.build_visual("Penjaga Pos Jaga", MissionData.OUTFIT_PENJAGA_PUTRI)
	_cek("Penjaga: build_visual muslimah + node hijab ada", bool(built.get("muslimah", false)) and built.has("hijab") and built["hijab"] != null)
	_cek("Penjaga: build_visual label nama 'Penjaga Pos Jaga'", built.has("name_label") and built["name_label"] != null)
	var main_src := _isi_file("res://scripts/main.gd")
	_cek("Wiring: main.gd membuat Penjaga Pos Jaga (OUTFIT_PENJAGA_PUTRI, diam, tidak ikut sholat)", main_src.contains("Penjaga Pos Jaga") and main_src.contains("OUTFIT_PENJAGA_PUTRI") and main_src.contains("_penjaga_putri") and main_src.contains("true, {}, false"))
	_cek("Wiring: main.gd handler tanya tersambung + routing langkah 4", main_src.contains("tanya_dipilih.connect(_on_manajer_tanya_dipilih)") and main_src.contains("_on_manajer_tanya_dipilih") and main_src.contains("_buka_tanya_guru") and main_src.contains("_npc_tanya_terdekat"))
	_cek("Wiring: main.gd tombol TANYA + guru didahulukan", main_src.contains("\"TANYA\"") and main_src.contains("_dekat_guru()"))
	_cek("Wiring: main.gd Bilal/Faris disimpan (_bilal/_faris)", main_src.contains("_bilal = npc1") and main_src.contains("_faris = npc2"))

	print("TES TEKA-TEKI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
