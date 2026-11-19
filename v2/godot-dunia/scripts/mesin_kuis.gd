class_name MesinKuis
extends RefCounted
## Mesin kuis ruang belajar — Fase A, A1 (Arka, 18 Nov 2026).
## LOGIKA MURNI, tanpa UI: UI kuis tetap di scripts/ui.gd (wilayah
## Tara) dan wiring ke main.gd dilakukan gelombang 2 oleh Raka.
##
## Acuan draf (DRAF-ALUR-MISI.md v5.2):
## - §2.1: materi 10 poin / latihan 15 / hafalan 10 / peti 25 /
##   tes 20 (hanya bila lulus); jenis misi Materi = kuis 1 soal,
##   Latihan = kuis 5 soal, Tes naik Bagian = kuis 10 soal.
## - §1A langkah 6 + §2.1: tes naik Bagian lulus bila benar >= 8
##   dari 10 soal. Gagal = ulangi belajar + tesnya saja, tanpa
##   penalti (draf §2.6: gagal tidak mengurangi bintang).
## - §2.6: selesaikan 1 misi = 1 bintang, lulus tes = 2 bintang.
##
## Format satu soal (sama dengan yang dipakai gelombang 2 nanti):
##   {"pertanyaan": String, "opsi": Array[String] (tepat 4),
##    "jawaban": int (0..3, indeks opsi benar)}
## Helper dari_misi() mengubah satu entri MissionData.MISSIONS
## (kunci "kuis"/"opsi"/"jawaban") ke format soal ini, supaya
## M1-M3 yang sudah live bisa langsung dipakai mesin ini.

## Ambang lulus TES naik Bagian (draf §2.1): benar >= 8 dari 10.
## Ini DEFAULT parameter lulus(), bukan hardcode di logika —
## pemanggil boleh memakai ambang lain (mis. latihan 5 soal).
const AMBANG_TES_DEFAULT := 8

## Bintang gelar (draf §2.6) — sebagai DATA, bukan tampilan.
const BINTANG_MISI := 1  ## selesaikan 1 misi
const BINTANG_TES := 2  ## lulus tes naik Bagian

## Jenis sesi yang dikenal (draf §2.1). "tes" = tes naik Bagian /
## gerbang ruang belajar; yang lain = misi biasa.
const JENIS_TES := "tes"

var _soal: Array = []
var _jenis := "latihan"
var _indeks := 0  ## soal yang sedang dijawab (0-based)
var _benar := 0
var _jawaban: Array[int] = []  ## jawaban pemain per soal (-1 = belum dijawab)
var _dimulai := false
var _selesai := false


## Satu soal valid? pertanyaan tidak kosong, opsi tepat 4 butir
## string tidak kosong, jawaban indeks 0..3.
static func soal_valid(soal: Dictionary) -> bool:
	if not soal.has("pertanyaan") or not soal.has("opsi") or not soal.has("jawaban"):
		return false
	if String(soal["pertanyaan"]).strip_edges().is_empty():
		return false
	var opsi: Array = soal["opsi"]
	if opsi.size() != 4:
		return false
	for o in opsi:
		if String(o).strip_edges().is_empty():
			return false
	if not (soal["jawaban"] is int):
		return false
	var j: int = soal["jawaban"]
	return j >= 0 and j <= 3


## Ubah satu entri MissionData.MISSIONS (kunci "kuis"/"opsi"/
## "jawaban") menjadi SATU soal format mesin ini. {} bila tidak valid.
static func dari_misi(misi: Dictionary) -> Dictionary:
	var soal := {
		"pertanyaan": String(misi.get("kuis", "")),
		"opsi": misi.get("opsi", []),
		"jawaban": misi.get("jawaban", -1),
	}
	return soal if soal_valid(soal) else {}


## Bintang gelar untuk satu sesi yang SUDAH selesai (draf §2.6).
## - jenis "tes": lulus -> 2 bintang, gagal -> 0 (coba lagi).
## - jenis lain (misi/latihan/hafalan/peti): skor > 0 (misi
##   selesai) -> 1 bintang; skor 0 -> 0.
## "skor" = jumlah jawaban benar, "lulus" = lulus ambang tes.
static func bintang_untuk(skor: int, lulus: bool, jenis := "latihan") -> int:
	if jenis == JENIS_TES:
		return BINTANG_TES if lulus else 0
	if lulus:
		# Misi biasa yang lulus ambangnya tetap 1 bintang (bukan 2):
		# 2 bintang hanya untuk tes naik Bagian.
		return BINTANG_MISI
	return BINTANG_MISI if skor > 0 else 0


## Mulai sesi baru. daftar_soal kosong / ada soal tidak valid ->
## DITOLAK (return false, sesi lama tidak berjalan, tanpa crash).
## jenis: "materi" | "latihan" | "hafalan" | "peti" | "tes".
func mulai(daftar_soal: Array, jenis := "latihan") -> bool:
	if daftar_soal.is_empty():
		return false
	for s in daftar_soal:
		if not (s is Dictionary) or not soal_valid(s):
			return false
	_soal = daftar_soal.duplicate(true)
	_jenis = jenis
	_indeks = 0
	_benar = 0
	_jawaban.clear()
	_jawaban.resize(_soal.size())
	_jawaban.fill(-1)
	_dimulai = true
	_selesai = false
	return true


## Sesi sedang berjalan (sudah mulai, belum selesai)?
func dimulai() -> bool:
	return _dimulai and not _selesai


func selesai() -> bool:
	return _selesai


func jenis() -> String:
	return _jenis


func jumlah_soal() -> int:
	return _soal.size()


## Nomor soal yang sedang dijawab, 1-based (0 bila belum mulai /
## sudah selesai).
func nomor_soal() -> int:
	if not _dimulai or _selesai:
		return 0
	return _indeks + 1


## Soal yang sedang dijawab ({} bila belum mulai / sudah selesai).
func soal_saat_ini() -> Dictionary:
	if not _dimulai or _selesai:
		return {}
	return _soal[_indeks]


## Jawab soal saat ini. pilihan di luar 0..3, sesi belum mulai,
## atau sesi sudah selesai -> DITOLAK (return false, tidak ada
## yang berubah, soal yang sama tetap ditampilkan). Diterima ->
## true, lalu lanjut ke soal berikut (atau selesai).
func jawab(pilihan: int) -> bool:
	if not _dimulai or _selesai:
		return false
	if pilihan < 0 or pilihan > 3:
		return false
	_jawaban[_indeks] = pilihan
	if pilihan == int(_soal[_indeks]["jawaban"]):
		_benar += 1
	_indeks += 1
	if _indeks >= _soal.size():
		_selesai = true
	return true


## Apakah jawaban TERAKHIR yang dimasukkan benar? false bila belum
## ada jawaban (atau sesi belum mulai).
func jawaban_terakhir_benar() -> bool:
	if not _dimulai or _indeks == 0:
		return false
	var i := mini(_indeks, _soal.size()) - 1
	if _jawaban[i] < 0:
		return false
	return _jawaban[i] == int(_soal[i]["jawaban"])


func skor() -> int:
	return _benar


func skor_maks() -> int:
	return _soal.size()


## Lulus? ambang = jumlah jawaban benar MINIMAL (parameter, bukan
## hardcode). Default 8 = ambang tes naik Bagian draf §2.1 (8/10).
## Belum selesai -> false. Untuk sesi 1/5 soal, pemanggil memakai
## ambang yang sesuai (mis. lulus(1) untuk kuis 1 soal M1).
func lulus(ambang := AMBANG_TES_DEFAULT) -> bool:
	if not _selesai:
		return false
	return _benar >= ambang


## Gagal = boleh ulang tanpa penalti (draf §1A langkah 6, §2.6).
func bisa_ulang() -> bool:
	return _selesai and not lulus()


## Ulangi sesi yang sama dari soal pertama (soal + jenis tetap).
## false bila tidak ada sesi yang pernah dimulai.
func ulang() -> bool:
	if _soal.is_empty():
		return false
	_indeks = 0
	_benar = 0
	_jawaban.clear()
	_jawaban.resize(_soal.size())
	_jawaban.fill(-1)
	_dimulai = true
	_selesai = false
	return true


## Bintang gelar sesi ini (draf §2.6). 0 bila belum selesai.
## ambang = ambang yang sama dengan yang dipakai lulus().
func bintang(ambang := AMBANG_TES_DEFAULT) -> int:
	if not _selesai:
		return 0
	return bintang_untuk(_benar, lulus(ambang), _jenis)


## Ringkasan sesi untuk UI / save (gelombang 2).
## ambang = ambang yang sama dengan yang dipakai lulus() — WAJIB
## diteruskan pemanggil untuk sesi 1/5 soal (mis. ringkasan(1)
## untuk kuis 1 soal M1-M3); default 8 = ambang tes naik Bagian.
## (Koreksi gelombang 2, Raka: ringkasan() lama memakai ambang
## default 8 — menyesatkan untuk sesi 1/5 soal.)
func ringkasan(ambang := AMBANG_TES_DEFAULT) -> Dictionary:
	return {
		"jenis": _jenis,
		"jumlah_soal": _soal.size(),
		"skor": _benar,
		"lulus": lulus(ambang),
		"bintang": bintang(ambang),
		"selesai": _selesai,
	}
