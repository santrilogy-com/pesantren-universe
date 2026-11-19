extends Node
## Tes Fatimah — state machine putri + lokasi acak putri (Wulan, 18 Nov 2026).
## §9 butir 22 (DI-ACC Mas 18:55 WIB): santri putri -> Ustzh. Mariyah
## -> Ustzh. Fatimah (guru, lokasi acak area putri, pola Ust. Sanusi).
## CAKUPAN: kunci "fatimah_lokasi" di baca()/reset()/maju()/
## lulus_tes()/kembali_belajar() + misi_aktif() putri + fungsi
## LokasiAcak putri. Factory NPC (outfit + buat + tempatkan) BUKAN
## di sini — milik Kirana di scripts/npc_fatimah.gd, jadi TIDAK dites
## di file ini.
## Headless (user-dir TERISOLASI — jangan pakai save VM):
##   HOME=/tmp/iso-fatimah XDG_DATA_HOME=/tmp/iso-fatimah/.local/share godot --headless --path . --scene res://skrip/test_fatimah.tscn
## Pola test_onboarding.gd: _cek + hitung lulus/gagal, EXIT 0 bila
## semua lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _save_putri() -> Dictionary:
	return {"jenis_kelamin": "putri"}


func _save_putra() -> Dictionary:
	return {"jenis_kelamin": "putra"}


func _ready() -> void:
	# ---------- LokasiAcak putri: kandidat ----------
	_cek("KANDIDAT_PUTRI = 6", LokasiAcak.KANDIDAT_PUTRI.size() == 6)
	var semua_putri := true
	var semua_ada_pos := true
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var p: Vector3 = k["pos"]
		if p.x <= 14.0:
			semua_putri = false
		if p == Vector3.ZERO:
			semua_ada_pos = false
	_cek("Semua kandidat putri di area putri (x > 14)", semua_putri)
	_cek("Semua kandidat putri punya posisi (bukan ZERO)", semua_ada_pos)
	_cek("pos_dari_id_putri musholla_putri = (134,-24)", LokasiAcak.pos_dari_id_putri("musholla_putri").distance_to(Vector3(134, 0, -24)) < 0.01)
	_cek("pos_dari_id_putri kantor_ustadzah = (148,-33)", LokasiAcak.pos_dari_id_putri("kantor_ustadzah").distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("pos_dari_id_putri kelas_putri = (130,0)", LokasiAcak.pos_dari_id_putri("kelas_putri").distance_to(Vector3(130, 0, 0)) < 0.01)
	_cek("pos_dari_id_putri asrama_putri = (152,9)", LokasiAcak.pos_dari_id_putri("asrama_putri").distance_to(Vector3(152, 0, 9)) < 0.01)
	_cek("pos_dari_id_putri taman_putri = (122,32)", LokasiAcak.pos_dari_id_putri("taman_putri").distance_to(Vector3(122, 0, 32)) < 0.01)
	_cek("pos_dari_id_putri halaman_putri = (128,-12)", LokasiAcak.pos_dari_id_putri("halaman_putri").distance_to(Vector3(128, 0, -12)) < 0.01)
	_cek("cari_putri() id tak dikenal = {}", LokasiAcak.cari_putri("tidak_ada").is_empty())
	_cek("id_valid_putri surau = false (bukan lokasi putri)", not LokasiAcak.id_valid_putri("surau"))
	_cek("id_valid_putri musholla_putri = true", LokasiAcak.id_valid_putri("musholla_putri"))
	_cek("pos_dari_id_putri tak dikenal = ZERO", LokasiAcak.pos_dari_id_putri("tidak_ada") == Vector3.ZERO)

	# ---------- LokasiAcak putri: acak benar-benar berubah ----------
	var acak_dari_kandidat := true
	var beda_seed_beda_hasil := false
	var hasil_pertama := String(LokasiAcak.acak_putri(1)["id"])
	for seed in range(1, 51):
		var h := LokasiAcak.acak_putri(seed)
		if not LokasiAcak.id_valid_putri(String(h["id"])):
			acak_dari_kandidat = false
		if String(h["id"]) != hasil_pertama:
			beda_seed_beda_hasil = true
	_cek("acak_putri() 50 seed selalu dari daftar putri", acak_dari_kandidat)
	_cek("acak_putri() berubah antar seed (bukan lokasi tetap)", beda_seed_beda_hasil)
	_cek("acak_putri() deterministik: seed sama = hasil sama", String(LokasiAcak.acak_putri(42)["id"]) == String(LokasiAcak.acak_putri(42)["id"]))
	var berikut_beda := true
	var berikut_putri := true
	for seed in range(1, 21):
		var cur := String(LokasiAcak.acak_putri(seed)["id"])
		var nxt := LokasiAcak.lokasi_berikutnya_putri(cur, seed + 100)
		if String(nxt["id"]) == cur:
			berikut_beda = false
		if (nxt["pos"] as Vector3).x <= 14.0:
			berikut_putri = false
	_cek("lokasi_berikutnya_putri() selalu beda dari lokasi saat ini (20x)", berikut_beda)
	_cek("lokasi_berikutnya_putri() selalu di area putri (x > 14, 20x)", berikut_putri)
	_cek("lokasi_berikutnya_putri() dari id kosong = kandidat putri valid", LokasiAcak.id_valid_putri(String(LokasiAcak.lokasi_berikutnya_putri("", 7)["id"])))

	# ---------- baca / reset ----------
	var s0 := _save_putri()
	_cek("baca() default punya fatimah_lokasi = ''", Onboarding.baca(s0).has("fatimah_lokasi") and String(Onboarding.baca(s0)["fatimah_lokasi"]) == "")
	var s_inv := {"onboarding": {"fatimah_lokasi": "tidak_ada"}}
	_cek("Lokasi Fatimah tak dikenal dibersihkan", String(Onboarding.baca(s_inv)["fatimah_lokasi"]) == "")
	var sr := _save_putri()
	Onboarding.maju(sr)
	Onboarding.maju(sr)
	Onboarding.maju(sr) # 4, isi fatimah_lokasi
	Onboarding.reset(sr)
	_cek("reset mengosongkan fatimah_lokasi", String(Onboarding.baca(sr)["fatimah_lokasi"]) == "")

	# ---------- maju() putri langkah 4 mengacak Fatimah ----------
	var s := _save_putri()
	Onboarding.maju(s) # 2
	Onboarding.maju(s) # 3
	var lok4 := Onboarding.maju(s) # 4
	_cek("Masuk langkah 4 (putri)", lok4 == 4)
	var id4 := String(Onboarding.baca(s)["fatimah_lokasi"])
	_cek("Langkah 4 putri mengisi fatimah_lokasi id putri valid (dapat '%s')" % id4, LokasiAcak.id_valid_putri(id4))
	_cek("Posisi Fatimah langkah 4 di area putri (x > 14)", LokasiAcak.pos_dari_id_putri(id4).x > 14.0)
	_cek("Langkah 4 putri TIDAK mengisi sanusi_lokasi", String(Onboarding.baca(s)["sanusi_lokasi"]) == "")

	# ---------- maju() putra tetap Sanusi (tidak berubah) ----------
	var sp := _save_putra()
	Onboarding.maju(sp) # 2
	Onboarding.maju(sp) # 3
	Onboarding.maju(sp) # 4
	_cek("Langkah 4 putra mengisi sanusi_lokasi", LokasiAcak.id_valid(String(Onboarding.baca(sp)["sanusi_lokasi"])))
	_cek("Langkah 4 putra TIDAK mengisi fatimah_lokasi", String(Onboarding.baca(sp)["fatimah_lokasi"]) == "")

	# ---------- misi_aktif putri ----------
	var sm := _save_putri()
	Onboarding.maju(sm) # 2
	var m2 := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 2 putri judul = Cari Ustzh. Mariyah", String(m2["judul"]) == "Cari Ustzh. Mariyah")
	_cek("Langkah 2 putri npc = Ustzh. Mariyah", String(m2["npc"]) == "Ustzh. Mariyah")
	_cek("Langkah 2 putri target = Musholla Ar-Raudhah (134,-24)", (m2["target_pos"] as Vector3).distance_to(Vector3(134, 0, -24)) < 0.01)
	Onboarding.maju(sm) # 3
	var m3 := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 3 putri npc = Ustzh. Mariyah", String(m3["npc"]) == "Ustzh. Mariyah")
	_cek("Langkah 3 putri target = Musholla Ar-Raudhah (134,-24)", (m3["target_pos"] as Vector3).distance_to(Vector3(134, 0, -24)) < 0.01)
	_cek("Langkah 3 putri deskripsi = bertemu Ustzh. Mariyah (bukan Aqsal M)", String(m3["deskripsi"]).contains("Ustzh. Mariyah") and not String(m3["deskripsi"]).contains("Aqsal M"))
	_cek("Langkah 3 putri deskripsi tetap ada kata DRAF", String(m3["deskripsi"]).contains("DRAF"))
	Onboarding.maju(sm) # 4
	var m4 := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 4 putri judul = Cari Ustzh. Fatimah", String(m4["judul"]) == "Cari Ustzh. Fatimah")
	_cek("Langkah 4 putri npc = Ustzh. Fatimah", String(m4["npc"]) == "Ustzh. Fatimah")
	_cek("Langkah 4 putri target = posisi Fatimah (area putri)", (m4["target_pos"] as Vector3).distance_to(LokasiAcak.pos_dari_id_putri(String(Onboarding.baca(sm)["fatimah_lokasi"]))) < 0.01 and (m4["target_pos"] as Vector3).x > 14.0)
	Onboarding.maju(sm) # 5
	var m5 := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 5 putri judul = Belajar ke Ustzh. Fatimah", String(m5["judul"]) == "Belajar ke Ustzh. Fatimah")
	_cek("Langkah 5 putri npc = Ustzh. Fatimah", String(m5["npc"]) == "Ustzh. Fatimah")
	_cek("Langkah 5 putri target = posisi Fatimah", (m5["target_pos"] as Vector3).distance_to(LokasiAcak.pos_dari_id_putri(String(Onboarding.baca(sm)["fatimah_lokasi"]))) < 0.01)
	_cek("Langkah 5 putri deskripsi menyebut Modul 01", String(m5["deskripsi"]).contains("Modul 01"))
	Onboarding.maju(sm) # 6
	var m6p := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 6 putri target tetap Kantor Ustadzah (148,-33)", (m6p["target_pos"] as Vector3).distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("Langkah 6 putri deskripsi = Kantor Ustadzah (bukan Kantor saja)", String(m6p["deskripsi"]).contains("Kantor Ustadzah"))
	# Langkah 7 putri: set manual (misi_aktif saja, tanpa alur penuh).
	var s7 := _save_putri()
	var ob7 := Onboarding.baca(s7)
	ob7["langkah"] = 7
	ob7["fatimah_lokasi"] = "kelas_putri"
	s7["onboarding"] = ob7
	var m7 := Onboarding.misi_aktif(s7, "putri")
	_cek("Langkah 7 putri npc = Ustzh. Fatimah", String(m7["npc"]) == "Ustzh. Fatimah")
	_cek("Langkah 7 putri target = Kelas Putri (130,0)", (m7["target_pos"] as Vector3).distance_to(Vector3(130, 0, 0)) < 0.01)
	_cek("Langkah 7 putri deskripsi = kembali ke Ustzh. Fatimah + Kantor Ustadzah", String(m7["deskripsi"]).contains("Ustzh. Fatimah") and String(m7["deskripsi"]).contains("Kantor Ustadzah") and not String(m7["deskripsi"]).contains("Sanusi"))
	# Putra tidak berubah.
	var m4p := Onboarding.misi_aktif(sp, "putra")
	_cek("Langkah 4 putra tetap npc Ust. Sanusi", String(m4p["npc"]) == "Ust. Sanusi")

	# ---------- lulus_tes putri mengacak ulang Fatimah ----------
	var st := _save_putri()
	for i in 5:
		Onboarding.maju(st) # sampai 6
	_cek("Lulus tes putri 6 -> kembali belajar (5), modul 2", Onboarding.lulus_tes(st) == 5 and int(Onboarding.baca(st)["modul"]) == 2)
	_cek("Lulus tes putri mengacak ulang lokasi Fatimah (id valid putri)", LokasiAcak.id_valid_putri(String(Onboarding.baca(st)["fatimah_lokasi"])))
	_cek("Lulus tes putri TIDAK mengisi sanusi_lokasi", String(Onboarding.baca(st)["sanusi_lokasi"]) == "")

	# ---------- kembali_belajar putri mengacak ulang Fatimah ----------
	var sk := _save_putri()
	var obk := Onboarding.baca(sk)
	obk["langkah"] = 7
	obk["modul"] = 3
	obk["fatimah_lokasi"] = "kelas_putri"
	sk["onboarding"] = obk
	_cek("kembali_belajar putri -> langkah 5, modul 4", Onboarding.kembali_belajar(sk) == 5 and int(Onboarding.baca(sk)["modul"]) == 4)
	_cek("kembali_belajar putri mengacak ulang lokasi Fatimah (id valid putri)", LokasiAcak.id_valid_putri(String(Onboarding.baca(sk)["fatimah_lokasi"])))

	print("TES FATIMAH: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
