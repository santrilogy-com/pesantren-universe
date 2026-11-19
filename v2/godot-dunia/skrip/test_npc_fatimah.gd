extends Node
## Tes NPC Ustzh. Fatimah — factory file baru (Kirana, 18 Nov 2026).
## §9 butir 22 (DI-ACC Mas 18:55 WIB): guru santri putri, pola
## Ust. Sanusi, HANYA di area putri (x > 14).
## CAKUPAN: NPCFatimah.OUTFIT_FATIMAH (format OUTFIT_USTADZAH,
## abaya gelap #043B2C beda dari Mariyah #065F46) + buat() (nama,
## mode DIAM, posisi awal spawn putri) + tempatkan() (pindah ke
## 2 titik putri + semua 6 kandidat putri + null aman) + NPC tidak
## pernah di area putra.
## State machine + LokasiAcak putri BUKAN di sini — milik Wulan di
## skrip/test_fatimah.gd. TIDAK memuat main.tscn (tes ringan).
## Headless (user-dir TERISOLASI — jangan pakai save VM):
##   godot --headless --path . --user-dir /tmp/test-npc-fatimah/ skrip/test_npc_fatimah.tscn
## Pola test_jalan_mundur.tscn / test_fatimah.gd: _cek + hitung
## lulus/gagal, EXIT 0 bila semua lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	# ---------- Outfit: format PERSIS OUTFIT_USTADZAH ----------
	var kunci_ustadzah: Array = MissionData.OUTFIT_USTADZAH.keys()
	var format_sama := true
	for k in kunci_ustadzah:
		if not NPCFatimah.OUTFIT_FATIMAH.has(k):
			format_sama = false
	_cek("OUTFIT_FATIMAH punya semua kunci OUTFIT_USTADZAH", format_sama)
	_cek("OUTFIT_FATIMAH abaya zamrud gelap #043B2C", String(NPCFatimah.OUTFIT_FATIMAH["abaya"]) == "#043B2C")
	_cek("OUTFIT_FATIMAH abaya beda dari Mariyah #065F46", String(NPCFatimah.OUTFIT_FATIMAH["abaya"]) != String(MissionData.OUTFIT_USTADZAH["abaya"]))
	_cek("OUTFIT_FATIMAH hijab true + muslimah true", bool(NPCFatimah.OUTFIT_FATIMAH["hijab"]) and bool(NPCFatimah.OUTFIT_FATIMAH["muslimah"]))
	_cek("OUTFIT_FATIMAH hijab_warna krem #f2ead6", String(NPCFatimah.OUTFIT_FATIMAH["hijab_warna"]) == "#f2ead6")
	_cek("OUTFIT_FATIMAH koko + sarung #043B2C", String(NPCFatimah.OUTFIT_FATIMAH["koko"]) == "#043B2C" and String(NPCFatimah.OUTFIT_FATIMAH["sarung"]) == "#043B2C")
	_cek("OUTFIT_FATIMAH kulit #c68e5e, kacamata false", String(NPCFatimah.OUTFIT_FATIMAH["kulit"]) == "#c68e5e" and not bool(NPCFatimah.OUTFIT_FATIMAH["kacamata"]))
	# (Perbandingan dengan Onboarding.OUTFIT_FATIMAH SENGAJA tidak
	# dites di sini: onboarding.gd sedang ditulis ulang Wulan
	# paralel — 20:41 WIB bagiannya belum ada di disk, dan nilai
	# literal di atas sudah sama persis dengan spek tugas.)

	# ---------- buat(): nama + mode DIAM + posisi awal putri ----------
	var npc := NPCFatimah.buat(self)
	_cek("buat() mengembalikan SantriNPC", npc is SantriNPC)
	_cek("buat() nama = Ustzh. Fatimah", npc.nama_santri() == "Ustzh. Fatimah")
	_cek("buat() mode DIAM (berdiri_tetap)", npc.berdiri_tetap())
	_cek("buat() posisi awal = spawn putri (140,16)", npc.position.distance_to(Vector3(140, 0, 16)) < 0.01)
	_cek("buat() posisi awal di area putri (x > 14)", npc.position.x > 14.0)
	_cek("buat() NPC terpasang di parent", npc.get_parent() == self)

	# ---------- tempatkan(): 2 titik putri ----------
	NPCFatimah.tempatkan(npc, Vector3(122, 0, 32))
	_cek("tempatkan() Taman Putri (122,32)", npc.position.distance_to(Vector3(122, 0, 32)) < 0.01)
	_cek("tempatkan() Taman Putri di area putri (x > 14)", npc.position.x > 14.0)
	NPCFatimah.tempatkan(npc, Vector3(148, 0, -33))
	_cek("tempatkan() Kantor Ustadzah (148,-33)", npc.position.distance_to(Vector3(148, 0, -33)) < 0.01)
	_cek("tempatkan() Kantor Ustadzah di area putri (x > 14)", npc.position.x > 14.0)

	# ---------- tempatkan(): semua 6 kandidat putri ----------
	var semua_putri := true
	var semua_tepat := true
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var p: Vector3 = k["pos"]
		NPCFatimah.tempatkan(npc, p)
		if npc.position.x <= 14.0:
			semua_putri = false
		if npc.position.distance_to(p) >= 0.01:
			semua_tepat = false
	_cek("tempatkan() semua 6 kandidat putri di area putri (x > 14)", semua_putri)
	_cek("tempatkan() semua 6 kandidat putri tepat di posisinya", semua_tepat)

	# ---------- tempatkan(null) aman + NPC tidak pernah di putra ----------
	NPCFatimah.tempatkan(null, Vector3(0, 0, -14))
	_cek("tempatkan(null) tidak crash", true)
	_cek("NPC tidak pernah di area putra (x <= 14) selama tes", npc.position.x > 14.0)

	# ---------- PENJAGA area putri (Kirana) ----------
	_cek("di_area_putri Taman Putri (122,32) = true", NPCFatimah.di_area_putri(Vector3(122, 0, 32)))
	_cek("di_area_putri Kantor Ustadzah (148,-33) = true", NPCFatimah.di_area_putri(Vector3(148, 0, -33)))
	_cek("di_area_putri Surau (0,-14) = false", not NPCFatimah.di_area_putri(Vector3(0, 0, -14)))
	_cek("di_area_putri tepi tembok (14,0) = false", not NPCFatimah.di_area_putri(Vector3(14, 0, 0)))
	_cek("di_area_putri Kantin putra (0,40) = false", not NPCFatimah.di_area_putri(Vector3(0, 0, 40)))
	_cek("di_area_putri luar tembok timur (220,0) = false", not NPCFatimah.di_area_putri(Vector3(220, 0, 0)))
	var pos_sebelum := npc.position
	_cek("tempatkan() menolak Surau (0,-14) -> false", not NPCFatimah.tempatkan(npc, Vector3(0, 0, -14)))
	_cek("tempatkan() ditolak: NPC tetap di tempat", npc.position.distance_to(pos_sebelum) < 0.01)
	_cek("tempatkan() menolak tepi tembok (14,0) -> false", not NPCFatimah.tempatkan(npc, Vector3(14, 0, 0)))
	_cek("tempatkan() menolak null -> false", not NPCFatimah.tempatkan(null, Vector3(122, 0, 32)))
	_cek("tempatkan() menerima Taman Putri -> true", NPCFatimah.tempatkan(npc, Vector3(122, 0, 32)))
	_cek("tempatkan() diterima: posisi = target", npc.position.distance_to(Vector3(122, 0, 32)) < 0.01)

	# ---------- lokasi acak putri via modul ----------
	_cek("acak_lokasi(7) id putri valid", LokasiAcak.id_valid_putri(String(NPCFatimah.acak_lokasi(7)["id"])))
	_cek("lokasi_berikutnya() beda dari saat ini + valid", String(NPCFatimah.lokasi_berikutnya("taman_putri", 3)["id"]) != "taman_putri" and LokasiAcak.id_valid_putri(String(NPCFatimah.lokasi_berikutnya("taman_putri", 3)["id"])))
	_cek("semua_id_lokasi() = 6 id", NPCFatimah.semua_id_lokasi().size() == 6)
	_cek("semua_id_lokasi() memuat kantor_ustadzah", "kantor_ustadzah" in NPCFatimah.semua_id_lokasi())

	# ---------- dialog putri (Mariyah menugaskan cari Fatimah) ----------
	var b1 := NPCFatimah.dialog_babak(1)
	_cek("Dialog babak 1 putri menyebut Ustzh. Mariyah", String(b1["teks"]).contains("Ustzh. Mariyah"))
	_cek("Dialog babak 1 putri TIDAK menyebut Ust. Aqsal M", not String(b1["teks"]).contains("Ust. Aqsal M"))
	var b4 := NPCFatimah.dialog_babak(4)
	_cek("Dialog babak 4 putri menugaskan cari Ustzh. Fatimah", String(b4["teks"]).contains("Ustzh. Fatimah"))
	_cek("Dialog babak 4 putri TIDAK menyebut Ust. Sanusi", not String(b4["teks"]).contains("Ust. Sanusi"))
	var b5 := NPCFatimah.dialog_babak(5)
	_cek("Dialog babak 5 putri menyebut Ustzh. Fatimah", String(b5["teks"]).contains("Ustzh. Fatimah"))
	_cek("Dialog babak 5 putri TIDAK menyebut Ust. Sanusi", not String(b5["teks"]).contains("Ust. Sanusi"))
	var semua_babak_ok := true
	for n in range(1, 6):
		var b := NPCFatimah.dialog_babak(n)
		if String(b.get("teks", "")).is_empty() or (b.get("pilihan", []) as Array).is_empty():
			semua_babak_ok = false
	_cek("Dialog babak 1-5 putri semua ada teks + pilihan", semua_babak_ok)
	_cek("Dialog babak 5 putri pilihan terakhir selesai (ke=-1)", int(((NPCFatimah.dialog_babak(5)["pilihan"] as Array)[0] as Dictionary)["ke"]) == -1)
	_cek("Dialog babak 0 -> {}", NPCFatimah.dialog_babak(0).is_empty())
	_cek("Dialog babak 6 -> {}", NPCFatimah.dialog_babak(6).is_empty())

	print("TES NPC FATIMAH: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
