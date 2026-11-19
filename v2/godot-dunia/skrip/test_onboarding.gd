extends Node
## Tes A8 — alur santri baru / onboarding (Lukman, 18 Nov 2026).
## Headless:
##   godot --headless --path . --scene res://skrip/test_onboarding.tscn
## Pola test_v2.gd: _cek + hitung lulus/gagal, EXIT 0 bila semua
## lulus. Logika MURNI (tanpa main.tscn) + satu NPC Sanusi nyata
## (buat_sanusi -> SantriNPC.setup -> build_visual).
## Butir tes (§ tugas A8):
##   - urutan langkah 1→7 benar + tidak bisa loncat langkah;
##   - lokasi acak selalu dari daftar kandidat + benar-benar berubah
##     antar panggilan dengan seed berbeda (bukan lokasi tetap);
##   - venue tes putra/putri sesuai default sementara;
##   - state tersimpan/bisa dibaca dari dict save (defensif bila
##     kunci belum ada).

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _save_baru() -> Dictionary:
	return {}


func _ready() -> void:
	# ---------- save defensif ----------
	var s0 := _save_baru()
	_cek("Save kosong -> langkah 1", Onboarding.langkah_saat_ini(s0) == 1)
	_cek("Save kosong -> belum selesai", not Onboarding.selesai(s0))
	_cek("Save kosong -> misi aktif langkah 1", Onboarding.misi_aktif(s0)["langkah"] == 1)
	var s1 := {"nama": "Tes", "poin": 0}
	_cek("Save tanpa kunci onboarding -> langkah 1", Onboarding.langkah_saat_ini(s1) == 1)
	var s2 := {"onboarding": {"langkah": 99, "modul": 999}}
	_cek("Langkah liar dijepit ke 7", Onboarding.langkah_saat_ini(s2) == 7)
	var s3 := {"onboarding": {"langkah": 0}}
	_cek("Langkah 0 dijepit ke 1", Onboarding.langkah_saat_ini(s3) == 1)
	var s4 := {"onboarding": {"sanusi_lokasi": "tidak_ada"}}
	_cek("Lokasi Sanusi tak dikenal dibersihkan", String(Onboarding.baca(s4)["sanusi_lokasi"]) == "")

	# ---------- urutan langkah 1→7 + tidak bisa loncat ----------
	var s := _save_baru()
	var urutan: Array[int] = [Onboarding.langkah_saat_ini(s)]
	for i in 6:
		urutan.append(Onboarding.maju(s))
	_cek("Urutan maju 1→7 benar (dapat %s)" % str(urutan), urutan == [1, 2, 3, 4, 5, 6, 7])
	_cek("Maju di 7 tetap 7 (terminal)", Onboarding.maju(s) == 7 and Onboarding.langkah_saat_ini(s) == 7)
	var s5 := _save_baru()
	_cek("Maju sekali dari 1 = 2 (tidak loncat)", Onboarding.maju(s5) == 2)
	_cek("State tersimpan di dict save", int((s5["onboarding"] as Dictionary)["langkah"]) == 2)

	# ---------- masuk langkah 4 mengacak lokasi Sanusi ----------
	var s6 := _save_baru()
	Onboarding.maju(s6) # 2
	Onboarding.maju(s6) # 3
	var lok4 := Onboarding.maju(s6) # 4
	_cek("Masuk langkah 4", lok4 == 4)
	var id4 := String(Onboarding.baca(s6)["sanusi_lokasi"])
	_cek("Langkah 4 mengisi lokasi Sanusi dari kandidat (dapat '%s')" % id4, LokasiAcak.id_valid(id4))
	var m4 := Onboarding.misi_aktif(s6)
	_cek("Misi aktif langkah 4 target = posisi Sanusi", (m4["target_pos"] as Vector3).distance_to(LokasiAcak.pos_dari_id(id4)) < 0.01)
	_cek("Misi aktif langkah 4 npc = Ust. Sanusi", String(m4["npc"]) == "Ust. Sanusi")

	# ---------- misi aktif per langkah ----------
	var sm := _save_baru()
	var m1 := Onboarding.misi_aktif(sm)
	_cek("Langkah 1 tanpa target (ZERO)", (m1["target_pos"] as Vector3) == Vector3.ZERO)
	Onboarding.maju(sm) # 2
	var m2 := Onboarding.misi_aktif(sm)
	_cek("Langkah 2 target = Surau (0,-14)", (m2["target_pos"] as Vector3).distance_to(Vector3(0, 0, -14)) < 0.01)
	_cek("Langkah 2 npc = Ust. Aqsal M", String(m2["npc"]) == "Ust. Aqsal M")
	Onboarding.maju(sm) # 3
	var m3 := Onboarding.misi_aktif(sm)
	_cek("Langkah 3 ada kata DRAF (butir 17 belum tashih)", String(m3["deskripsi"]).contains("DRAF"))
	Onboarding.maju(sm) # 4 (acak lokasi)
	Onboarding.maju(sm) # 5
	var m5 := Onboarding.misi_aktif(sm)
	_cek("Langkah 5 modul 1 dari 30", int(m5["modul"]) == 1 and String(m5["deskripsi"]).contains("1 dari 30"))
	Onboarding.maju(sm) # 6
	var m6 := Onboarding.misi_aktif(sm)
	_cek("Langkah 6 putra target = Surau (0,-14) SEMENTARA", (m6["target_pos"] as Vector3).distance_to(Vector3(0, 0, -14)) < 0.01)
	var m6p := Onboarding.misi_aktif(sm, "putri")
	_cek("Langkah 6 putri target = Kantor Ustadzah (148,-33) SEMENTARA", (m6p["target_pos"] as Vector3).distance_to(Vector3(148, 0, -33)) < 0.01)

	# ---------- tes lulus / gagal ----------
	var st := _save_baru()
	for i in 5:
		Onboarding.maju(st) # sampai 6
	_cek("Lulus tes 6 -> kembali belajar (5), modul 2", Onboarding.lulus_tes(st) == 5 and int(Onboarding.baca(st)["modul"]) == 2)
	_cek("Tes lulus tercatat (1)", int(Onboarding.baca(st)["tes_lulus"]) == 1)
	_cek("Lulus tes mengacak ulang lokasi Sanusi", LokasiAcak.id_valid(String(Onboarding.baca(st)["sanusi_lokasi"])))
	Onboarding.maju(st) # 6 lagi
	_cek("Gagal tes 6 -> kembali belajar (5), modul TETAP 2", Onboarding.gagal_tes(st) == 5 and int(Onboarding.baca(st)["modul"]) == 2)
	_cek("Gagal tes tidak menambah tes_lulus", int(Onboarding.baca(st)["tes_lulus"]) == 1)
	var st2 := _save_baru()
	_cek("lulus_tes di luar langkah 6 tidak mengubah", Onboarding.lulus_tes(st2) == 1 and int(Onboarding.baca(st2)["modul"]) == 1)
	_cek("gagal_tes di luar langkah 6 tidak mengubah", Onboarding.gagal_tes(st2) == 1)

	# ---------- hatam ----------
	var sh := _save_baru()
	var obh := Onboarding.baca(sh)
	obh["langkah"] = 6
	obh["modul"] = Onboarding.JUMLAH_MODUL
	sh["onboarding"] = obh
	_cek("Lulus tes modul terakhir -> hatam (7)", Onboarding.lulus_tes(sh) == 7)
	_cek("Hatam tercatat selesai", Onboarding.selesai(sh))
	var mh := Onboarding.misi_aktif(sh)
	_cek("Misi aktif hatam judul Hatam", String(mh["judul"]).begins_with("Hatam"))
	_cek("Maju setelah hatam tetap 7", Onboarding.maju(sh) == 7)
	var sh2 := _save_baru()
	_cek("tandai_hatam -> selesai + langkah 7", Onboarding.tandai_hatam(sh2) == 7 and Onboarding.selesai(sh2))
	var sh3 := _save_baru()
	Onboarding.reset(sh3)
	_cek("reset -> langkah 1, modul 1, belum selesai", Onboarding.langkah_saat_ini(sh3) == 1 and int(Onboarding.baca(sh3)["modul"]) == 1 and not Onboarding.selesai(sh3))

	# ---------- LokasiAcak: kandidat ----------
	_cek("Kandidat = 6 (Surau, Kelas, Taman, Perpus, Masjid, Kantin)", LokasiAcak.KANDIDAT.size() == 6)
	var semua_id := LokasiAcak.semua_id()
	_cek("semua_id berisi 6 id unik", semua_id.size() == 6 and semua_id[0] == "surau")
	var semua_putra := true
	var semua_ada_pos := true
	for k in LokasiAcak.KANDIDAT:
		var p: Vector3 = k["pos"]
		if p.x >= 115.0:
			semua_putra = false
		if p == Vector3.ZERO:
			semua_ada_pos = false
	_cek("Semua kandidat di area putra/kawasan bersama (x < 115, bukan kampus putri)", semua_putra)
	_cek("Semua kandidat punya posisi (bukan ZERO)", semua_ada_pos)
	_cek("cari() id tak dikenal = {}", LokasiAcak.cari("tidak_ada").is_empty())
	_cek("pos_dari_id tak dikenal = ZERO", LokasiAcak.pos_dari_id("tidak_ada") == Vector3.ZERO)
	_cek("pos_dari_id surau = (0,-14)", LokasiAcak.pos_dari_id("surau").distance_to(Vector3(0, 0, -14)) < 0.01)
	_cek("pos_dari_id kantin = (0,40)", LokasiAcak.pos_dari_id("kantin").distance_to(Vector3(0, 0, 40)) < 0.01)
	_cek("pos_dari_id masjid_besar = (64,-24)", LokasiAcak.pos_dari_id("masjid_besar").distance_to(Vector3(64, 0, -24)) < 0.01)

	# ---------- LokasiAcak: acak benar-benar berubah ----------
	var acak_dari_kandidat := true
	var beda_seed_beda_hasil := false
	var hasil_pertama := String(LokasiAcak.acak(1)["id"])
	for seed in range(1, 51):
		var h := LokasiAcak.acak(seed)
		if not LokasiAcak.id_valid(String(h["id"])):
			acak_dari_kandidat = false
		if String(h["id"]) != hasil_pertama:
			beda_seed_beda_hasil = true
	_cek("acak() 50 seed selalu dari daftar kandidat", acak_dari_kandidat)
	_cek("acak() berubah antar seed (bukan lokasi tetap)", beda_seed_beda_hasil)
	_cek("acak() deterministik: seed sama = hasil sama", String(LokasiAcak.acak(42)["id"]) == String(LokasiAcak.acak(42)["id"]))
	var berikut_beda := true
	for seed in range(1, 21):
		var cur := String(LokasiAcak.acak(seed)["id"])
		var nxt := LokasiAcak.lokasi_berikutnya(cur, seed + 100)
		if String(nxt["id"]) == cur:
			berikut_beda = false
	_cek("lokasi_berikutnya() selalu beda dari lokasi saat ini (20x)", berikut_beda)
	_cek("lokasi_berikutnya() dari id kosong = kandidat valid", LokasiAcak.id_valid(String(LokasiAcak.lokasi_berikutnya("", 7)["id"])))
	_cek("REFRESH_PER_MISI default true (usulan butir 18)", LokasiAcak.REFRESH_PER_MISI)

	# ---------- venue tes ----------
	_cek("venue_tes putra = Surau (0,-14)", Onboarding.venue_tes("putra").distance_to(Vector3(0, 0, -14)) < 0.01)
	_cek("venue_tes putri = Kantor Ustadzah (148,-33)", Onboarding.venue_tes("putri").distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("venue_tes gender tak dikenal = putra (default)", Onboarding.venue_tes("").distance_to(Vector3(0, 0, -14)) < 0.01)
	_cek("venue_tes_id putri = kantor_ustadzah", Onboarding.venue_tes_id("putri") == "kantor_ustadzah")
	_cek("venue_tes_id putra = surau", Onboarding.venue_tes_id("putra") == "surau")

	# ---------- topik percakapan (butir 17 — DRAF) ----------
	_cek("TOPIK_PERCAKAPAN = 6 butir (§1A)", Onboarding.TOPIK_PERCAKAPAN.size() == 6)
	_cek("Topik 1 = Sambutan Ust. Aqsal M", String(Onboarding.TOPIK_PERCAKAPAN[0]).begins_with("Sambutan"))

	# ---------- outfit Sanusi beda dari Kyai/Ustadzah ----------
	var o := Onboarding.OUTFIT_SANUSI
	_cek("Sanusi tanpa serban/jenggot/hijab (ustadz biasa)", not o.has("serban") and not o.has("jenggot") and not o.has("hijab"))
	_cek("Sanusi koko biru muda, beda dari Kyai krem", String(o["koko"]) == "#cfe0f0" and String(o["koko"]) != String(MissionData.OUTFIT_KYAI["koko"]))
	_cek("Sanusi sarung hitam, beda dari santri zamrud", String(o["sarung"]) == "#2b2b2b")
	_cek("Sanusi beda dari Ustadzah zamrud", String(o["koko"]) != String(MissionData.OUTFIT_USTADZAH["koko"]))

	# ---------- NPC Sanusi nyata ----------
	var sanusi := Onboarding.buat_sanusi(self)
	_cek("buat_sanusi mengembalikan SantriNPC", sanusi is SantriNPC)
	_cek("Nama NPC = Ust. Sanusi", sanusi.nama_santri() == "Ust. Sanusi")
	_cek("Sanusi mode DIAM (berdiri tetap)", sanusi.berdiri_tetap())
	_cek("Sanusi spawn awal di Surau (0,-14)", sanusi.position.distance_to(Vector3(0, 0, -14)) < 0.01)
	Onboarding.tempatkan_sanusi(sanusi, LokasiAcak.pos_dari_id("kantin"))
	_cek("tempatkan_sanusi pindah ke Kantin (0,40)", sanusi.position.distance_to(Vector3(0, 0, 40)) < 0.01)
	# Biarkan _process jalan beberapa frame (tangkap error runtime
	# di npc.gd headless tanpa kamera), lalu cek tetap diam.
	for i in 5:
		await get_tree().process_frame
	_cek("Sanusi tetap di Kantin setelah 5 frame (mode diam)", sanusi.position.distance_to(Vector3(0, 0, 40)) < 0.01)
	_cek("Sanusi punya sinyal pesan + rute_selesai", sanusi.has_signal("pesan") and sanusi.has_signal("rute_selesai"))

	print("TES ONBOARDING: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
