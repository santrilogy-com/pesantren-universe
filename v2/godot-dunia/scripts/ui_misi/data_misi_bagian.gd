class_name DataMisiBagian
## Data Panel Misi Bagian 1 (Hijau) — Fase A, A9 (Wulan).
## LOGIKA/DATA MURNI, tanpa UI: tampilan Panel Misi dikerjakan Sinta,
## wiring ke main.gd dilakukan gelombang 2 oleh Raka.
##
## TEKS DRAF — isi menunggu tashih Mas (§9 butir 17 / Modul 01).
## Semua baris + teks PERSIS mockup panel-misi-v1.png (DI-ACC Mas);
## arti gelar dari tabel draf §2.6; poin dari draf §2.1.
## Branding: "Pesantren Universe" (rebrand total DIKUNCI Mas 18:55
## — JANGAN tulis "Verse").
##
## KUNCI SAVE yang dibaca (defensif, .get dengan default — save lama
## tanpa kunci tetap aman):
##   "misi_selesai" (Array id misi), "tes_lulus" (Array id tes),
##   "tugas_selesai" (Array id tugas — lihat Tugas.KUNCI_SAVE).
##
## PEMETAAN id_save mengikuti judul/topik yang SAMA dengan
## MissionData.MISSIONS: M1 = "Kenalan dengan Nahwu", M2 = soal
## isim (Misi 2 — I'rab: Isim Marfu'), M3 = peti (Misi 3 — Buka
## Peti Kayu). N1.T selesai bila "N1.T" ada di save["tes_lulus"]
## (bukan di "misi_selesai" — tes bukan misi biasa, lihat Gelar).
## Baris dengan id_save "" BELUM dilacak game (A2) — statusnya
## tidak pernah "selesai" sampai A2 menulis kuncinya.

## Nama bagian + modul (mockup Panel Misi).
const BAGIAN_NAMA := "Bagian 1 (Hijau)"
const BAGIAN_MODUL := "Nahwu Dasar"
## Bagian berikut (mockup Panel Misi — teks DRAF).
const BAGIAN_BERIKUT_NAMA := "Bagian 2 (Biru) — Isim Lebih Dalam"
const BAGIAN_BERIKUT_SYARAT := "Terbuka setelah lulus N1.T • 100 poin"

## 8 baris misi Bagian 1 — PERSIS mockup panel-misi-v1.png.
## "id_save" = kunci save yang menandai selesai; "" = belum dilacak.
const BARIS: Array[Dictionary] = [
	{"id": "N1.1", "judul": "Kenalan dengan Nahwu", "poin": 10, "id_save": "M1"},
	{"id": "N1.2", "judul": "Isim", "poin": 10, "id_save": "M2"},
	{"id": "N1.3", "judul": "Fi'il", "poin": 10, "id_save": ""},
	{"id": "N1.4", "judul": "Huruf — Ust. Sanusi", "poin": 10, "id_save": ""},
	{"id": "N1.5", "judul": "Latihan mabni / mu'rob", "poin": 15, "id_save": ""},
	{"id": "N1.6", "judul": "Hafalan bait", "poin": 10, "id_save": ""},
	{"id": "N1.7", "judul": "Peti Hijau", "poin": 25, "id_save": "M3"},
	{"id": "N1.T", "judul": "Tes Naik Bagian 2 — Kantor", "poin": 20, "id_save": "N1.T"},
]

## Tugas dari Ustadz (mockup Panel Misi — Modul 01 "Tugas dari
## Ustadz": hafal bait + baca 1 bab di rak kitab).
## POIN 5 = usulan draf §2.1 / mockup — TAFSIR POIN TUGAS MASIH
## TERBUKA, menunggu verdict Mas: draf §2.1 menyebut "tugas 5 poin
## usulan", sementara A7 (tugas.gd) memakai poin jenis misi
## (materi 10 / latihan 15 / hafalan 10 / peti 25 / tes 20).
## Angka 5 di sini mengikuti mockup, BUKAN keputusan final.
const TUGAS: Dictionary = {
	"id": "N1-tugas-1",
	"label": "Tugas dari Ustadz (N1.3)",
	"teks": "Hafal bait + baca 1 bab di rak kitab",
	"poin": 5,
}

## Arti tiap gelar — dari tabel draf §2.6 (nama gelar = kunci,
## persis Gelar.TIERS; "" = tanpa arti, 'Santri Senior).
const SUBJUDUL_GELAR: Dictionary = {
	"Thalib al-'Ilm": "Penuntut Ilmu",
	"Mubtadi'": "Pemula",
	"Mutawassith": "Menengah",
	"Mutamayyiz": "Mahir",
	"Muntahi": "Tingkat Akhir",
	"Faqih": "Ahli Fiqih",
	"'Alim": "Orang Berilmu",
	"'Santri Senior": "",
}


## Total poin semua baris Bagian 1 (harus 110).
static func total_poin() -> int:
	var total := 0
	for b in BARIS:
		total += int(b["poin"])
	return total


## Status tiap baris dari save: salinan baris + kunci "status".
##   "selesai"  = id_save ada di save["misi_selesai"], atau (untuk
##                N1.T) "N1.T" ada di save["tes_lulus"].
##   "aktif"    = baris pertama yang belum selesai, berurutan —
##                belajar berurutan, tidak loncat.
##   "terkunci" = sisanya.
## Baris dengan id_save "" tidak pernah "selesai" (belum dilacak).
static func status_baris(save: Dictionary) -> Array[Dictionary]:
	var selesai_misi: Array = save.get("misi_selesai", [])
	var tes_lulus: Array = save.get("tes_lulus", [])
	var keluar: Array[Dictionary] = []
	var sudah_aktif := false
	for b in BARIS:
		var baris: Dictionary = (b as Dictionary).duplicate()
		var id_save := String(baris.get("id_save", ""))
		var selesai := false
		if id_save != "" and selesai_misi.has(id_save):
			selesai = true
		if String(baris["id"]) == "N1.T" and tes_lulus.has("N1.T"):
			selesai = true
		if selesai:
			baris["status"] = "selesai"
		elif not sudah_aktif:
			baris["status"] = "aktif"
			sudah_aktif = true
		else:
			baris["status"] = "terkunci"
		keluar.append(baris)
	return keluar


## Apakah tugas dari Ustadz sudah selesai (id-nya ada di
## save["tugas_selesai"])? Save lama tanpa kunci -> false.
static func tugas_selesai(save: Dictionary) -> bool:
	var selesai: Array = save.get("tugas_selesai", [])
	return selesai.has(String(TUGAS["id"]))


## Poin Bagian 1 yang sudah diraih: jumlah poin baris berstatus
## "selesai" + poin TUGAS bila tugas selesai.
static func poin_bagian(save: Dictionary) -> int:
	var total := 0
	for b in status_baris(save):
		if String(b["status"]) == "selesai":
			total += int(b["poin"])
	if tugas_selesai(save):
		total += int(TUGAS["poin"])
	return total
