class_name Gerbang
## Gerbang naik Bagian + gerbang ruang belajar Jenjang 0 + badge
## "Bisa Baca Kitab Kuning" — logika MURNI tanpa UI (Fase A, A4).
## Acuan: DRAF-ALUR-MISI.md v5.2 §2.1 (Ruang Belajar, gerbang
## Jenjang 0, syarat badge) + §2.6 (gelar, bintang tes) + §1A
## langkah 6-7 (tes kenaikan di Kantor, loop sampai hatam).
##
## LOKASI TES (keputusan v5, §1A langkah 6): tes naik Bagian
## (N*.T) di KANTOR — BUKAN di Surau/Musholla. Kontradiksi lama
## draf §6.2 ("tes naik bagian tetap di Surau/Musholla selama
## Jenjang 0") SUDAH diputuskan: ikut §1A v5, tes di Kantor.
## File ini tidak tahu-menahu soal lokasi (logika murni) — lokasi
## hanya dicatat di sini supaya wiring gelombang 2 tidak salah
## menaruh tes di Surau/Musholla.
##
## ATURAN (persis draf, tanpa tambahan):
## - Tes naik Bagian N*.T = kuis 10 soal (MesinKuis, jenis "tes"),
##   lulus bila benar >= 8/10. Lulus -> "N*" ke "bagian_lulus" dan
##   "N*.T" ke "tes_lulus" (2 bintang — hitungannya di Gelar,
##   JANGAN dihitung ulang di sini). Gagal = ulangi tesnya saja,
##   tanpa penalti, tanpa ada yang ditulis (§1A langkah 7, §2.6).
## - Gerbang ruang belajar Jenjang 0: TERBUKA setelah N4.T lulus,
##   kuis kaidah Nahwu Dasar 10 soal, lulus >= 8/10. Lulus ->
##   kunci "gerbang_lulus" (bool) = true di save. Kunci ini yang
##   dibaca Gelar untuk tier 5 (Muntahi). Gerbang BUKAN tes baca
##   kitab — bukti baca yang jujur adalah rak kitab + setoran
##   (§2.1, catatan jujur Raka).
## - Badge "Bisa Baca Kitab Kuning" (§2.1, syarat DIKUNCI 18:22):
##   (a) ruang belajar Nahwu Dasar selesai = 4 Bagian lulus
##   (N1-N4 di "bagian_lulus"); (b) gerbang lulus (kunci
##   "gerbang_lulus" true); (c) baca 3 bab di rak kitab (kunci
##   "baca_bab", minimal 3 entri UNIK); (d) setoran baca di depan
##   ustadz langsung — Fase C, BELUM BISA lulus sekarang.
##
## TAFSIR (draf tidak merinci — dicatat supaya bisa dikoreksi
## Mas/Raka):
## 1. "Ruang belajar selesai" (syarat badge a) diartikan sebagai
##    4 Bagian lulus saja — draf menyebut "(4 Bagian + gerbang
##    lulus)" sebagai satu syarat (a); di sini dipecah jadi (a)
##    4 Bagian dan (b) gerbang supaya tiap syarat bisa dicek
##    sendiri. Misi per modul (N*.1...) TIDAK ikut dihitung:
##    draf tidak menyebutnya sebagai syarat badge.
## 2. Tes yang dicatat HARUS jenis "tes" dan TEPAT 10 soal —
##    draf §2.1: tes naik Bagian = kuis 10 soal; MesinKuis
##    membedakan jenis "tes" dari misi biasa (§2.6: 2 bintang
##    hanya untuk tes). Sesi "latihan" 10 soal atau sesi "tes"
##    5 soal DITOLAK (return false, tidak ada yang ditulis).
## 3. "3 bab" dihitung dari entri UNIK di "baca_bab" (mis.
##    "jurumiyah:3") — bab yang sama dibaca dua kali tetap
##    dihitung satu. Format entri ikut save_data.gd (A5).
## 4. Syarat (d) setoran dibaca dari kunci MASA DEPAN
##    "setoran_lulus" (bool, default false) secara defensif —
##    persis pola Gelar membaca "tahap_*_lulus". Kunci ini
##    BELUM DITULIS game mana pun, jadi (d) selalu false dan
##    badge BELUM BISA lulus sampai Fase C menulisnya.
##
## CATATAN PERSISTENSI (untuk Raka / pemilik save_data.gd):
## Kunci "gerbang_lulus" DITULIS file ini ke Dictionary data
## yang diteruskan (satu-satunya kunci yang ditulis file ini).
## Supaya nilainya BERTAHAN antar sesi, kunci itu juga harus
## ada di SantriSave.default_data() — load_data() hanya menyalin
## kunci yang ada di default_data (pelajaran bug flag pop-up
## Tara). File ini TIDAK BOLEH menyentuh save_data.gd (aturan
## Fase A), jadi penambahan satu baris itu tugas gelombang 2 /
## pemilik save. Tanpa baris itu, "gerbang_lulus" tetap benar di
## sesi berjalan, tapi hilang saat muat ulang dan tier 5
## terkunci lagi.

## Ambang lulus tes / gerbang (draf §2.1): benar >= 8 dari 10.
## Diambil dari MesinKuis.AMBANG_TES_DEFAULT, bukan angka baru.
const AMBANG := MesinKuis.AMBANG_TES_DEFAULT

## Jumlah soal tes naik Bagian / gerbang (draf §2.1): 10 soal.
const JUMLAH_SOAL_TES := 10

## Syarat badge (c): minimal bab unik yang dibaca (draf §2.1,
## DIKUNCI 18:22 — angka 3 keputusan Xam, bisa diubah Mas nanti).
const BAB_MINIMAL := 3

## Kunci save masa depan untuk syarat badge (d) — Fase C.
const KUNCI_SETORAN := "setoran_lulus"


## Id tes naik Bagian, mis. "N1" -> "N1.T".
static func id_tes(bagian: String) -> String:
	return bagian + ".T"


## Bagian Nahwu Dasar yang dikenal (N1-N4, ikut Gelar.BAGIAN).
static func bagian_valid(bagian: String) -> bool:
	return bagian in Gelar.BAGIAN


## Gerbang satu Bagian sudah lulus? Benar bila "N*" ada di
## "bagian_lulus" DAN "N*.T" ada di "tes_lulus" — keduanya harus
## ada (catat_tes selalu menulis sepasang; bila save lama hanya
## punya satu, gerbang dianggap belum lulus).
static func gerbang_lulus(data: Dictionary, bagian: String) -> bool:
	if not bagian_valid(bagian):
		return false
	var bagian_lulus: Array = data.get("bagian_lulus", [])
	var tes_lulus: Array = data.get("tes_lulus", [])
	return bagian in bagian_lulus and id_tes(bagian) in tes_lulus


## Gerbang ruang belajar Jenjang 0 sudah terbuka? Terbuka setelah
## N4.T lulus (draf §2.1: "Setelah N4.T, terbuka Gerbang").
static func gerbang_terbuka(data: Dictionary) -> bool:
	return gerbang_lulus(data, "N4")


## Kunci "gerbang_lulus" sudah true? (Dibaca defensif — kunci
## belum ada di save lama = false, tier 5 terkunci.)
static func jenjang0_lulus(data: Dictionary) -> bool:
	return bool(data.get("gerbang_lulus", false))


## Catat hasil satu sesi tes naik Bagian (N*.T).
## mesin = MesinKuis yang SUDAH selesai (jenis "tes", 10 soal).
## Lulus (>= 8/10) -> tulis "N*" ke "bagian_lulus" dan "N*.T"
## ke "tes_lulus" (tanpa duplikat), return true. Gagal / sesi
## tidak valid (belum selesai, jenis bukan "tes", soal bukan
## 10, bagian tidak dikenal) -> return false, TIDAK ADA yang
## ditulis. Tidak menulis kunci lain.
static func catat_tes(data: Dictionary, bagian: String, mesin: MesinKuis) -> bool:
	if not bagian_valid(bagian):
		return false
	if mesin == null or not mesin.selesai():
		return false
	if mesin.jenis() != MesinKuis.JENIS_TES:
		return false
	if mesin.jumlah_soal() != JUMLAH_SOAL_TES:
		return false
	if not mesin.lulus(AMBANG):
		return false
	var bagian_lulus: Array = data.get("bagian_lulus", [])
	if not bagian in bagian_lulus:
		bagian_lulus.append(bagian)
		data["bagian_lulus"] = bagian_lulus
	var tes_lulus: Array = data.get("tes_lulus", [])
	var id := id_tes(bagian)
	if not id in tes_lulus:
		tes_lulus.append(id)
		data["tes_lulus"] = tes_lulus
	return true


## Catat hasil kuis gerbang ruang belajar Jenjang 0 (kuis kaidah
## Nahwu Dasar, 10 soal, lulus >= 8/10 — draf §2.1).
## mesin = MesinKuis yang SUDAH selesai (jenis "tes", 10 soal).
## Gerbang harus sudah terbuka (N4.T lulus) — bila belum, kuis
## tidak bisa dicatat (return false). Lulus -> tulis kunci
## "gerbang_lulus" = true ke save, return true. Gagal / sesi
## tidak valid -> return false, kunci tidak ditulis/diubah.
## Satu-satunya fungsi di file ini yang menulis "gerbang_lulus".
static func catat_gerbang(data: Dictionary, mesin: MesinKuis) -> bool:
	if not gerbang_terbuka(data):
		return false
	if mesin == null or not mesin.selesai():
		return false
	if mesin.jenis() != MesinKuis.JENIS_TES:
		return false
	if mesin.jumlah_soal() != JUMLAH_SOAL_TES:
		return false
	if not mesin.lulus(AMBANG):
		return false
	data["gerbang_lulus"] = true
	return true


## Jumlah bab UNIK yang dibaca di rak kitab (kunci "baca_bab").
static func jumlah_bab_dibaca(data: Dictionary) -> int:
	var baca: Array = data.get("baca_bab", [])
	var unik := {}
	for b in baca:
		unik[String(b)] = true
	return unik.size()


## Cek badge "Bisa Baca Kitab Kuning" (§2.1, syarat DIKUNCI 18:22).
## Kembali Dictionary berisi tiap syarat + lulus keseluruhan:
##   "ruang_belajar_selesai": bool — 4 Bagian lulus (N1-N4)
##   "gerbang_lulus": bool — kunci "gerbang_lulus" true
##   "baca_3_bab": bool — >= 3 bab unik di "baca_bab"
##   "bab_dibaca": int — jumlah bab unik yang dibaca
##   "setoran_lulus": bool — kunci masa depan "setoran_lulus"
##     (Fase C — SELALU false sampai Fase C menulisnya; lihat
##     catatan (d) di atas)
##   "lulus": bool — true hanya bila KEEMPAT syarat true.
## Fungsi ini hanya MEMBACA — tidak menulis kunci apa pun.
static func badge_bisa_baca(data: Dictionary) -> Dictionary:
	var bagian_lulus: Array = data.get("bagian_lulus", [])
	var ruang_selesai := true
	for b in Gelar.BAGIAN:
		if not b in bagian_lulus:
			ruang_selesai = false
			break
	var gerbang := jenjang0_lulus(data)
	var bab := jumlah_bab_dibaca(data)
	var baca_cukup := bab >= BAB_MINIMAL
	# Syarat (d) — Fase C: baca di depan ustadz langsung. Kunci
	# "setoran_lulus" belum ditulis game mana pun; dibaca defensif
	# (default false), jadi badge BELUM BISA lulus sekarang.
	var setoran := bool(data.get(KUNCI_SETORAN, false))
	return {
		"ruang_belajar_selesai": ruang_selesai,
		"gerbang_lulus": gerbang,
		"baca_3_bab": baca_cukup,
		"bab_dibaca": bab,
		"setoran_lulus": setoran,
		"lulus": ruang_selesai and gerbang and baca_cukup and setoran,
	}
