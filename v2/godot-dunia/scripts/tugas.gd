class_name Tugas
## Tracker tugas dari Ustadz — logika MURNI tanpa UI (Fase A, A7).
## Acuan: DRAF-ALUR-MISI.md §2.1 (pola baku tiap modul: cari Ustadz
## -> belajar -> tugas dari Ustadz; rantai Nahwu Dasar 30 misi + 4 tes
## = 420 poin).
##
## DEFINISI TUGAS ADALAH DATA, BUKAN KARANGAN: semua fungsi di sini
## menerima definisi tugas dari luar sebagai array Dictionary dengan
## bentuk {id, modul, jenis, poin}. File ini TIDAK berisi satu pun isi
## tugas Modul 01 — Modul 01 masih menunggu tashih Mas, dan isi
## tugas datang dari A2 (tim kurikulum) nanti. Jangan menambah daftar
## tugas di sini.
##
## POIN (tafsir yang dipakai — draf tidak merinci cara tugas dihitung):
## - Logika inti memakai "poin" dari definisi bila definisi menyebutnya.
## - Bila definisi tidak menyebut poin, dipakai POIN_JENIS[jenis]
##   sebagai default — angkanya poin jenis misi §2.1 (materi 10 /
##   latihan 15 / hafalan 10 / peti 25 / tes 20).
## - Bila jenisnya pun tidak dikenal, poinnya 0 (bukan karangan angka).
## - Catatan: §2.1 pola baku juga menyebut usulan "poin tugas 5 poin"
##   untuk tugas dari Ustadz. Usulan itu TIDAK dipakai sebagai default
##   di sini karena tugas tracker ini mengikuti jenis misinya
##   (materi/latihan/hafalan/peti/tes); bila Mas/Raka memutuskan
##   tugas dari Ustadz selalu 5 poin, yang berubah hanya POIN_JENIS
##   / definisi dari A2 — bukan logika di bawah.
##
## TES "HANYA BILA LULUS" (§2.1: tes 20 poin hanya bila lulus):
## aturan lulus itu ditegakkan oleh yang MENULIS ke "tugas_selesai"
## (mesin kuis, A1) — tracker ini hanya mencatat id yang sudah
## ditulis di sana. Id tes yang gagal TIDAK ditulis ke tugas_selesai,
## jadi tidak ikut kehitung poin. Jangan menulis id tes ke sini
## sebelum lulus.
##
## MARKER PETA USTADZ (langkah "cari Ustadz") BUKAN bagian file ini —
## marker menyusul setelah HUD Tara mendarat. Tracker ini logika dulu.
##
## KUNCI SAVE: "tugas_selesai" (array id tugas, mis. ["N1.2-t1"]) —
## sudah ada di SantriSave.default_data (A7 pemilik gelombang 1).
## Semua baca di sini defensif dengan .get("tugas_selesai", []) supaya
## save lama tanpa kunci itu tetap aman.

## Poin default per jenis tugas (poin jenis misi §2.1).
const POIN_JENIS := {
	"materi": 10,
	"latihan": 15,
	"hafalan": 10,
	"peti": 25,
	"tes": 20,
}

## Kunci save tempat id tugas selesai dicatat.
const KUNCI_SAVE := "tugas_selesai"


## Poin satu tugas: "poin" dari definisinya bila ada, kalau tidak
## default POIN_JENIS[jenis], kalau jenisnya tidak dikenal 0.
## Definisi yang rusak (bukan Dictionary / tanpa "id") -> 0.
static func poin_untuk(tugas: Dictionary) -> int:
	if tugas.has("poin"):
		return maxi(int(tugas["poin"]), 0)
	var jenis := String(tugas.get("jenis", ""))
	if POIN_JENIS.has(jenis):
		return int(POIN_JENIS[jenis])
	return 0


## Daftar tugas untuk satu modul saja (modul lain tidak ikut).
## "definisi" = array Dictionary {id, modul, jenis, poin}.
## Entri tanpa "modul" yang cocok / tanpa "id" dilewati.
static func tugas_untuk_modul(definisi: Array, modul: String) -> Array[Dictionary]:
	var keluar: Array[Dictionary] = []
	for t in definisi:
		if not (t is Dictionary):
			continue
		var d: Dictionary = t
		if String(d.get("id", "")) == "":
			continue
		if String(d.get("modul", "")) != modul:
			continue
		keluar.append(d)
	return keluar


## Tandai satu tugas selesai: menulis id ke data["tugas_selesai"].
## Unik — id yang sudah ada tidak ditulis dua kali. Membuat kunci
## "tugas_selesai" bila data save lama belum memilikinya.
static func tandai_selesai(data: Dictionary, id_tugas: String) -> void:
	if id_tugas == "":
		return
	var selesai: Array = data.get(KUNCI_SAVE, [])
	# Salin supaya tidak memutasi array milik caller secara diam-diam
	# bila data datang dari luar (array di Dictionary itu referensi).
	var daftar: Array = selesai.duplicate()
	if not daftar.has(id_tugas):
		daftar.append(id_tugas)
	data[KUNCI_SAVE] = daftar


## Apakah tugas ini sudah selesai (id-nya ada di "tugas_selesai")?
## Save lama tanpa kunci -> false, bukan error.
static func sudah_selesai(data: Dictionary, id_tugas: String) -> bool:
	var selesai: Array = data.get(KUNCI_SAVE, [])
	return selesai.has(id_tugas)


## Total poin tugas yang sudah selesai, dari definisi yang diberikan.
## - Hanya tugas yang id-nya ada di "tugas_selesai" yang dihitung.
## - Id duplikat (di definisi maupun di "tugas_selesai") dihitung
##   sekali — poin tidak menggelembung karena data ganda.
## - Panggil dengan definisi satu modul untuk poin modul itu, atau
##   dengan definisi semua modul untuk total semua tugas.
static func poin_tugas(data: Dictionary, definisi: Array) -> int:
	var selesai: Array = data.get(KUNCI_SAVE, [])
	var sudah := {}
	for id_tugas in selesai:
		sudah[String(id_tugas)] = true
	var dihitung := {}
	var total := 0
	for t in definisi:
		if not (t is Dictionary):
			continue
		var d: Dictionary = t
		var id_tugas := String(d.get("id", ""))
		if id_tugas == "":
			continue
		if dihitung.has(id_tugas):
			continue
		dihitung[id_tugas] = true
		if sudah.has(id_tugas):
			total += poin_untuk(d)
	return total
