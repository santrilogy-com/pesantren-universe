extends Node
## AUDIT KETERJANGKAUAN LOKASI ACAK GURU (Raka, 20 Nov 2026).
## Temuan tes salaman: Sanusi pernah diacak ke (64,-24) plot Masjid
## Besar (zona larangan putra) dan Fatimah sering di tengah cangkang
## gedung putri — misi "cari guru" (§1A langkah 4-5) bisa MACET
## karena pemain tidak bisa mendekati guru (jangkauan interaksi
## _dekat_npc = 3,5 m, main.gd CHAT_JARAK_INTERAKSI).
## Audit ini membuktikan tiap kandidat LokasiAcak:
##   A. Zona gender benar (putra: BUKAN x>14 & z<16 — balik tembok
##      x=14, gerbang tertutup; putri: di dalam perimeter putri
##      x 115..216, z -70..+40).
##   B. Di luar SEMUA tapak gedung (SantriNPC.TAPAK + 5 gedung putri
##      kampus_putri.gd) + margin 0,5 m — pemain bisa BERDIRI di
##      titik itu sendiri, bukan hanya mendekat dari luar dinding.
##   C. Ada segmen bersih dari kandidat ke minimal satu titik jangkar
##      yang diketahui terbuka: raycast 3 jalur (_segmen_bersih
##      npc.gd, persis yang dipakai game) + sampel tapak tiap 1 m
##      (tabel diperluas di sini).
##   D. Acak deterministik 200 seed: hanya id valid, semua kandidat
##      muncul (tidak ada kandidat mati).
##   E. Save lama dengan id yang dihapus ("masjid_besar") dibersihkan
##      Onboarding.baca (migrasi otomatis, tidak macet).
## Jalankan headless (butuh dunia untuk raycast, pola
## test_npc_tembus.gd):
##   HOME=/tmp/iso-lokasi-acak godot --headless --path . --scene res://skrip/test_lokasi_acak.tscn

var _lulus := 0
var _gagal := 0
var _main: Node


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("LOKASI-ACAK LULUS %s %s" % [nama, detail])
	else:
		_gagal += 1
		print("LOKASI-ACAK GAGAL %s %s" % [nama, detail])


## Tapak gedung putri yang TIDAK ada di SantriNPC.TAPAK (hanya 6
## cangkang besar) — disalin dari kampus_putri.gd _gedung():
## KelasPutri 10x8 (130,10), KantorUstadzah 8x6 (148,-33),
## Madrasah 10x8 (152,-12), Studio 10x8 (166,-12),
## PosJagaTL 3x3 (176,-20).
const TAPAK_PUTRI_TAMBAHAN := {
	"KelasPutri": [Vector2(125, 6), Vector2(135, 14)],
	"KantorUstadzah": [Vector2(144, -36), Vector2(152, -30)],
	"Madrasah": [Vector2(147, -16), Vector2(157, -8)],
	"Studio": [Vector2(161, -16), Vector2(171, -8)],
	"PosJagaTL": [Vector2(174.5, -21.5), Vector2(177.5, -18.5)],
}

## Semua tapak (TAPAK npc.gd + tambahan putri) untuk cek titik/segmen.
func _semua_tapak() -> Dictionary:
	var out := {}
	for nama in SantriNPC.TAPAK:
		out[nama] = SantriNPC.TAPAK[nama]
	for nama in TAPAK_PUTRI_TAMBAHAN:
		out[nama] = TAPAK_PUTRI_TAMBAHAN[nama]
	return out


## Titik di luar semua tapak + margin (m) di semua sisi?
func _di_luar_tapak(p: Vector3, tapak: Dictionary, margin: float) -> String:
	for nama in tapak:
		var r: Array = tapak[nama]
		var mn: Vector2 = r[0]
		var mx: Vector2 = r[1]
		if p.x > mn.x - margin and p.x < mx.x + margin and p.z > mn.y - margin and p.z < mx.y + margin:
			return String(nama)
	return ""


## Segmen bersih dari tapak (sampel tiap 1 m, pola _segmen_bersih).
func _segmen_bersih_tapak(a: Vector3, b: Vector3, tapak: Dictionary) -> String:
	var d := Vector2(b.x - a.x, b.z - a.z)
	var panjang := d.length()
	if panjang < 0.05:
		return ""
	var n := int(panjang / 1.0) + 1
	for i in range(n + 1):
		var t := float(i) / float(n)
		var p := Vector2(a.x, a.z) + d * t
		for nama in tapak:
			var r: Array = tapak[nama]
			var mn: Vector2 = r[0]
			var mx: Vector2 = r[1]
			if p.x >= mn.x and p.x <= mx.x and p.y >= mn.y and p.y <= mx.y:
				return String(nama)
	return ""


func _ready() -> void:
	var tapak := _semua_tapak()

	# ---------- A. Jumlah + id unik + teka-teki ----------
	_cek("Kandidat putra tetap 6", LokasiAcak.KANDIDAT.size() == 6, str(LokasiAcak.semua_id()))
	_cek("Kandidat putri tetap 6", LokasiAcak.KANDIDAT_PUTRI.size() == 6)
	var id_lihat := {}
	var id_unik := true
	for k in LokasiAcak.KANDIDAT + LokasiAcak.KANDIDAT_PUTRI:
		var id := String(k["id"])
		if id_lihat.has(id):
			id_unik = false
		id_lihat[id] = true
	_cek("Semua 12 id unik", id_unik)
	_cek("Id lama masjid_besar sudah tidak valid", not LokasiAcak.id_valid("masjid_besar"))
	var semua_teka := true
	for k in LokasiAcak.KANDIDAT + LokasiAcak.KANDIDAT_PUTRI:
		if not DataTekaTeki.ada(String(k["id"])):
			semua_teka = false
	_cek("Semua kandidat punya teka-teki", semua_teka)

	# ---------- B. Zona gender ----------
	for k in LokasiAcak.KANDIDAT:
		var p: Vector3 = k["pos"]
		_cek("Putra %s bukan zona larangan (x>14 & z<16)" % String(k["id"]), not (p.x > 14.0 and p.z < 16.0), str(p))
		_cek("Putra %s y=0 (tanah terbuka)" % String(k["id"]), absf(p.y) < 0.01, str(p))
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var p: Vector3 = k["pos"]
		_cek("Putri %s di dalam perimeter putri" % String(k["id"]), p.x >= 115.0 and p.x <= 216.0 and p.z >= -70.0 and p.z <= 40.0, str(p))
		_cek("Putri %s y=0 (tanah terbuka)" % String(k["id"]), absf(p.y) < 0.01, str(p))

	# ---------- C. Di luar semua tapak + margin 0,5 m ----------
	for k in LokasiAcak.KANDIDAT + LokasiAcak.KANDIDAT_PUTRI:
		var p: Vector3 = k["pos"]
		var masuk := _di_luar_tapak(p, tapak, 0.5)
		_cek("Kandidat %s di luar tapak (+0,5 m)" % String(k["id"]), masuk == "", ("DI DALAM " + masuk) if masuk != "" else str(p))

	# ---------- E. Save lama: id dihapus dibersihkan ----------
	var s_lama := SantriSave.default_data()
	s_lama["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "masjid_besar", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	_cek("Save lama masjid_besar dibersihkan Onboarding.baca", String(Onboarding.baca(s_lama)["sanusi_lokasi"]) == "")
	var s_lama_p := SantriSave.default_data()
	s_lama_p["jenis_kelamin"] = "putri"
	s_lama_p["onboarding"] = {"langkah": 4, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "tidak_ada", "tes_lulus": 0, "selesai": false}
	_cek("Save putri id tak dikenal dibersihkan", String(Onboarding.baca(s_lama_p)["fatimah_lokasi"]) == "")

	# ---------- D. Acak deterministik ----------
	var muncul_putra := {}
	var muncul_putri := {}
	var acak_valid := true
	for seed in range(200):
		var a := LokasiAcak.acak(seed)
		if not LokasiAcak.id_valid(String(a["id"])):
			acak_valid = false
		muncul_putra[String(a["id"])] = true
		var b := LokasiAcak.acak_putri(seed)
		if not LokasiAcak.id_valid_putri(String(b["id"])):
			acak_valid = false
		muncul_putri[String(b["id"])] = true
	_cek("Acak 200 seed putra+putri hanya id valid", acak_valid)
	_cek("Acak 200 seed: semua 6 kandidat putra muncul", muncul_putra.size() == 6, str(muncul_putra.keys()))
	_cek("Acak 200 seed: semua 6 kandidat putri muncul", muncul_putri.size() == 6, str(muncul_putri.keys()))
	var berikut_valid := true
	for k in LokasiAcak.KANDIDAT:
		var nb := LokasiAcak.lokasi_berikutnya(String(k["id"]), 7)
		if not LokasiAcak.id_valid(String(nb["id"])) or String(nb["id"]) == String(k["id"]):
			berikut_valid = false
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var nb := LokasiAcak.lokasi_berikutnya_putri(String(k["id"]), 7)
		if not LokasiAcak.id_valid_putri(String(nb["id"])) or String(nb["id"]) == String(k["id"]):
			berikut_valid = false
	_cek("lokasi_berikutnya selalu valid + berbeda", berikut_valid)

	# ---------- C2. Segmen bersih ke jangkar (butuh dunia) ----------
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["ig_username"] = ""
	SantriSave.save_data(_main._save)
	_main._masuk_pesantren("Tes Lokasi Acak")
	for i in 5:
		await get_tree().process_frame
	var sanusi: SantriNPC = _main._sanusi
	# Jangkar yang diketahui terbuka: waypoint NPC putra (7 titik
	# tervalidasi test_npc_tembus) + titik terbuka putri (spawn,
	# taman, halaman, jalan internal x=142).
	var jangkar_putra: Array = []
	for wp in PesantrenBuilder.NPC_WAYPOINTS:
		jangkar_putra.append(wp)
	var jangkar_putri: Array = [
		Vector3(140, 0, 16), Vector3(122, 0, 32),
		Vector3(128, 0, -12), Vector3(142, 0, 0),
	]
	for k in LokasiAcak.KANDIDAT:
		var p: Vector3 = k["pos"]
		var bersih_ke := ""
		for j in jangkar_putra:
			var jj: Vector3 = j
			if sanusi._segmen_bersih(p, jj) and _segmen_bersih_tapak(p, jj, tapak) == "":
				bersih_ke = "(%.1f,%.1f)" % [jj.x, jj.z]
				break
		_cek("Putra %s segmen bersih ke jangkar" % String(k["id"]), bersih_ke != "", ("via " + bersih_ke) if bersih_ke != "" else str(p))
	for k in LokasiAcak.KANDIDAT_PUTRI:
		var p: Vector3 = k["pos"]
		var bersih_ke := ""
		for j in jangkar_putri:
			var jj: Vector3 = j
			if sanusi._segmen_bersih(p, jj) and _segmen_bersih_tapak(p, jj, tapak) == "":
				bersih_ke = "(%.1f,%.1f)" % [jj.x, jj.z]
				break
		_cek("Putri %s segmen bersih ke jangkar" % String(k["id"]), bersih_ke != "", ("via " + bersih_ke) if bersih_ke != "" else str(p))

	print("LOKASI-ACAK SELESAI lulus=%d gagal=%d" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
