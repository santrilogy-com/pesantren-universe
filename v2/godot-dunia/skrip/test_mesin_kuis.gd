extends Node
## Tes A1 — Mesin ruang belajar (MesinKuis, Arka, 18 Nov 2026).
## Headless:
##   godot --headless --path . skrip/test_mesin_kuis.tscn
## Pola test_v2.gd: _cek + hitung lulus/gagal, print per butir.
## Acuan draf v5.2 §2.1 + §1A: kuis 1/5/10 soal; tes naik Bagian
## lulus >= 8/10; gagal boleh ulang tanpa penalti; bintang: misi
## selesai = 1, lulus tes = 2.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


## n soal dummy: pertanyaan "Soal i", opsi A-D, jawaban benar 0.
func _buat_soal(n: int) -> Array:
	var daftar: Array = []
	for i in n:
		daftar.append({
			"pertanyaan": "Soal %d" % (i + 1),
			"opsi": ["A", "B", "C", "D"],
			"jawaban": 0,
		})
	return daftar


## Jawab benar k soal pertama, salah sisanya (salah = pilih 1).
func _jawab_sebagian(m: MesinKuis, benar: int, total: int) -> void:
	for i in total:
		m.jawab(0 if i < benar else 1)


func _ready() -> void:
	# --- SESI 1 SOAL: benar ---
	var m1 := MesinKuis.new()
	_cek("1 soal: mulai diterima", m1.mulai(_buat_soal(1), "materi"))
	_cek("1 soal: jumlah 1, nomor 1", m1.jumlah_soal() == 1 and m1.nomor_soal() == 1)
	_cek("1 soal: soal_saat_ini terisi", String(m1.soal_saat_ini().get("pertanyaan", "")) == "Soal 1")
	_cek("1 soal: jawab benar diterima", m1.jawab(0))
	_cek("1 soal: selesai setelah 1 jawaban", m1.selesai())
	_cek("1 soal: skor 1/1", m1.skor() == 1 and m1.skor_maks() == 1)
	_cek("1 soal: lulus(1) bila benar", m1.lulus(1))
	_cek("1 soal: bintang misi = 1", m1.bintang() == 1)
	_cek("1 soal: jawab setelah selesai ditolak", not m1.jawab(0))
	_cek("1 soal: soal_saat_ini kosong setelah selesai", m1.soal_saat_ini().is_empty())

	# --- SESI 1 SOAL: salah -> gagal, boleh ulang ---
	var m1s := MesinKuis.new()
	m1s.mulai(_buat_soal(1), "materi")
	_cek("1 soal salah: jawab diterima", m1s.jawab(2))
	_cek("1 soal salah: skor 0", m1s.skor() == 0)
	_cek("1 soal salah: tidak lulus(1)", not m1s.lulus(1))
	_cek("1 soal salah: bisa_ulang (tanpa penalti)", m1s.bisa_ulang())
	_cek("1 soal salah: bintang 0", m1s.bintang() == 0)
	_cek("1 soal salah: ulang() berhasil", m1s.ulang())
	_cek("1 soal salah: setelah ulang belum selesai", not m1s.selesai() and m1s.nomor_soal() == 1)
	_cek("1 soal salah: ulang lalu jawab benar -> lulus", m1s.jawab(0) and m1s.lulus(1))

	# --- SESI 5 SOAL (latihan, draf §2.1: 15 poin) ---
	var m5 := MesinKuis.new()
	_cek("5 soal: mulai diterima", m5.mulai(_buat_soal(5), "latihan"))
	_jawab_sebagian(m5, 5, 5)
	_cek("5 soal: 5 benar -> skor 5", m5.skor() == 5)
	_cek("5 soal: lulus(5)", m5.lulus(5))
	_cek("5 soal: bintang misi = 1", m5.bintang() == 1)
	var m5b := MesinKuis.new()
	m5b.mulai(_buat_soal(5), "latihan")
	_jawab_sebagian(m5b, 4, 5)
	_cek("5 soal: 4 benar -> skor 4", m5b.skor() == 4)
	_cek("5 soal: 4 benar tidak lulus(5), lulus(4)", not m5b.lulus(5) and m5b.lulus(4))

	# --- SESI 10 SOAL, BATAS LULUS 8/10 (tes naik Bagian, draf §2.1) ---
	var m10 := MesinKuis.new()
	_cek("10 soal: mulai diterima (tes)", m10.mulai(_buat_soal(10), "tes"))
	_jawab_sebagian(m10, 8, 10)
	_cek("10 soal: 8 benar -> skor 8", m10.skor() == 8)
	_cek("10 soal: 8/10 LULUS ambang default", m10.lulus())
	_cek("10 soal: 8/10 bintang tes = 2", m10.bintang() == 2)
	var m10g := MesinKuis.new()
	m10g.mulai(_buat_soal(10), "tes")
	_jawab_sebagian(m10g, 7, 10)
	_cek("10 soal: 7 benar -> skor 7", m10g.skor() == 7)
	_cek("10 soal: 7/10 GAGAL ambang default", not m10g.lulus())
	_cek("10 soal: 7/10 bintang tes = 0", m10g.bintang() == 0)
	_cek("10 soal: 7/10 bisa_ulang", m10g.bisa_ulang())

	# --- AMBANG BISA DIUBAH (parameter, bukan hardcode) ---
	_cek("Ambang: 8/10 tidak lulus(9)", not m10.lulus(9))
	_cek("Ambang: 8/10 lulus(8)", m10.lulus(8))
	_cek("Ambang: 7/10 lulus(7)", m10g.lulus(7))
	var m1a := MesinKuis.new()
	m1a.mulai(_buat_soal(1), "tes")
	m1a.jawab(0)
	_cek("Ambang: 1 soal benar tidak lulus ambang default 8", not m1a.lulus())
	_cek("Ambang: 1 soal benar lulus(1)", m1a.lulus(1))

	# --- DAFTAR SOAL KOSONG DITOLAK DENGAN AMAN (bukan crash) ---
	var mk := MesinKuis.new()
	_cek("Kosong: mulai([]) ditolak", not mk.mulai([]))
	_cek("Kosong: tidak selesai, skor 0", not mk.selesai() and mk.skor() == 0)
	_cek("Kosong: jawab ditolak", not mk.jawab(0))
	_cek("Kosong: lulus() false", not mk.lulus())
	_cek("Kosong: soal_saat_ini {}", mk.soal_saat_ini().is_empty())
	_cek("Kosong: ulang() ditolak", not mk.ulang())

	# --- SOAL TIDAK VALID DITOLAK ---
	var miv := MesinKuis.new()
	_cek("Invalid: opsi 3 butir ditolak", not miv.mulai([{"pertanyaan": "X", "opsi": ["A", "B", "C"], "jawaban": 0}]))
	_cek("Invalid: jawaban 4 ditolak", not miv.mulai([{"pertanyaan": "X", "opsi": ["A", "B", "C", "D"], "jawaban": 4}]))
	_cek("Invalid: pertanyaan kosong ditolak", not miv.mulai([{"pertanyaan": "  ", "opsi": ["A", "B", "C", "D"], "jawaban": 0}]))
	_cek("Invalid: satu soal rusak merusak seluruh daftar", not miv.mulai(_buat_soal(4) + [{"pertanyaan": "X", "opsi": ["A"], "jawaban": 0}]))
	_cek("Invalid: sesi tetap tidak berjalan", not miv.selesai() and miv.jumlah_soal() == 0)

	# --- JAWAB DI LUAR INDEKS DITOLAK ---
	var mo := MesinKuis.new()
	mo.mulai(_buat_soal(2), "latihan")
	_cek("Indeks: jawab(-1) ditolak", not mo.jawab(-1))
	_cek("Indeks: jawab(4) ditolak", not mo.jawab(4))
	_cek("Indeks: soal tetap soal ke-1", mo.nomor_soal() == 1 and not mo.selesai())
	_cek("Indeks: jawab benar setelah penolakan tetap jalan", mo.jawab(0) and mo.nomor_soal() == 2)
	mo.jawab(0)
	_cek("Indeks: sesi 2 soal selesai normal", mo.selesai() and mo.skor() == 2)

	# --- BINTANG (statis, draf §2.6) ---
	_cek("Bintang: tes lulus = 2", MesinKuis.bintang_untuk(8, true, "tes") == 2)
	_cek("Bintang: tes gagal = 0", MesinKuis.bintang_untuk(7, false, "tes") == 0)
	_cek("Bintang: misi selesai = 1", MesinKuis.bintang_untuk(5, true, "latihan") == 1)
	_cek("Bintang: misi selesai sebagian = 1", MesinKuis.bintang_untuk(3, false, "latihan") == 1)
	_cek("Bintang: skor 0 = 0", MesinKuis.bintang_untuk(0, false, "latihan") == 0)

	# --- JEMBATAN MissionData M1-M3 (gelombang 2) ---
	var soal_m1 := MesinKuis.dari_misi(MissionData.MISSIONS[0])
	_cek("dari_misi: M1 jadi 1 soal valid", not soal_m1.is_empty())
	var mm := MesinKuis.new()
	_cek("dari_misi: sesi M1 jalan", mm.mulai([soal_m1], "materi") and mm.jawab(0) and mm.skor() == 1)
	_cek("dari_misi: entri rusak -> {}", MesinKuis.dari_misi({"kuis": "X"}).is_empty())
	_cek("dari_misi: M3 (peti) valid", not MesinKuis.dari_misi(MissionData.MISSIONS[2]).is_empty())

	# --- RINGKASAN ---
	var r := m10.ringkasan()
	_cek("Ringkasan: skor 8, lulus, bintang 2, tes", r["skor"] == 8 and r["lulus"] == true and r["bintang"] == 2 and r["jenis"] == "tes")

	print("TES MESIN KUIS: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
