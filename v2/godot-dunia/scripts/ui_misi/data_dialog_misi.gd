class_name DataDialogMisi
## Data dialog misi (percakapan aturan pesantren) — Fase A, A9 (Wulan).
## LOGIKA/DATA MURNI, tanpa UI: tampilan dialog dikerjakan Sinta,
## wiring ke main.gd dilakukan gelombang 2 oleh Raka.
##
## TEKS DRAF — isi menunggu tashih Mas (§9 butir 17 / Modul 01).
##   - Babak 1: PERSIS mockup dialog-aqsal-v2.png (DI-ACC Mas).
##   - Babak 2-4: VERBATIM Onboarding.TOPIK_PERCAKAPAN[1..3]
##     (garis besar 6 topik §1A — bukan kalimat aturan final).
##   - Babak 5: TEKS BARU Laras (draf babak 5, DI-ACC Mas 23:03 WIB
##     18 Nov 2026) — ucapan penutup Kyai yang beneran, bukan
##     catatan panggung; pilihan jawaban = pamit berangkat.
##   - Branding: "Pesantren Universe" di mana pun nama brand muncul
##     (rebrand total DIKUNCI Mas 18:55 — JANGAN tulis "Verse").
##   - Varian PUTRI: substitusi MEKANIS dari keputusan §9 butir 22
##     (DIKUNCI 18:55 — Ustzh. Mariyah pengasuh putri, Ustzh.
##     Fatimah guru pengganti Ust. Sanusi), BUKAN kalimat baru:
##     nama pembicara, sapaan "Ustadz"->"Ustadzah", dan
##     "Ust. Sanusi"->"Ustzh. Fatimah" di babak 4 (nama misi
##     "Cari Ust. Sanusi" ikut berganti nama di babak 4).
##     Babak 5 ditulis TERPISAH putra/putri (pola babak 1) karena
##     pengait bertanyanya beda — putri tidak punya satpam.
##
## Bentuk satu babak (lihat babak()):
##   {"teks": String,
##    "pilihan": Array[Dictionary] {"teks": String, "ke": int}}
## "ke" = nomor babak tujuan; -1 = percakapan selesai.

## Jumlah babak dialog (mockup: "Babak 1 dari 5").
const JUMLAH_BABAK := 5

## Pembicara per gender. "avatar" = kunci avatar yang dipakai UI
## (kyai = avatar Kyai; ustadzah = avatar Ustadzah Mariyah).
const PEMBICARA: Dictionary = {
	"putra": {"nama": "Ust. Aqsal M", "subjudul": "Pengasuh Pesantren Universe", "avatar": "kyai"},
	"putri": {"nama": "Ustzh. Mariyah", "subjudul": "Pengasuh Pesantren Universe", "avatar": "ustadzah"},
}

## Babak 1 — PERSIS mockup dialog-aqsal-v2.png (putra).
const TEKS_BABAK_1_PUTRA := "Ahlan wa sahlan, santri baru. Saya Ust. Aqsal M, pengasuh pesantren ini. Di sini kita belajar kitab kuning seperti pesantren sungguhan — tapi dibungkus game: misi, poin, dan gelar."
## Babak 1 putri — substitusi mekanis nama dari TEKS_BABAK_1_PUTRA
## (§9 butir 22): "Saya Ust. Aqsal M" -> "Saya Ustzh. Mariyah".
const TEKS_BABAK_1_PUTRI := "Ahlan wa sahlan, santri baru. Saya Ustzh. Mariyah, pengasuh pesantren ini. Di sini kita belajar kitab kuning seperti pesantren sungguhan — tapi dibungkus game: misi, poin, dan gelar."

## Babak 2-4 — VERBATIM Onboarding.TOPIK_PERCAKAPAN[1..3].
## "Pesantren Verse" sudah "Pesantren Universe" di sumbernya
## (topik "Apa itu…"), jadi tidak ada penggantian brand di sini.
const TEKS_BABAK_2 := "Apa itu Pesantren Universe — belajar seperti pesantren sungguhan (kitab, ustadz, musyawarah) tapi dibungkus game (misi, poin, gelar, ranking)."
const TEKS_BABAK_3 := "Aturan pokok pesantren — (a) adab kepada ustadz & sesama santri; (b) jadwal harian (sholat berjamaah, khataman, belajar); (c) zona putra/putri — tidak boleh masuk area seberang; (d) kasur & kamar — 1 santri 1 kasur, jaga kebersihan; (e) belajar berurutan — modul terkunci, tidak boleh loncat; (f) khidmah & musyawarah sebagai bagian dari belajar."
const TEKS_BABAK_4 := "Penugasan pertama — \"Sekarang cari Ust. Sanusi — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik.\""

## Babak 5 — TEKS BARU (Laras, DI-ACC Mas 23:03 WIB 18 Nov 2026).
## PENUTUP ASLI yang diucapkan Kyai — teks lama ("Penutup — santri
## mengiyakan, misi ... terbuka.") adalah catatan panggung, BUKAN
## ucapan Kyai, dan pilihan jawabannya mengulang babak 1 (temuan
## Mas 22:59 WIB "dialog ... agak aneh ... pas bagian penutup").
## Putri ditulis terpisah (pengait bertanya beda: putri tidak punya
## satpam — "tanya ke santriwati lain atau kembali ke saya").
const TEKS_BABAK_5_PUTRA := "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat belajarnya. Sekarang berangkatlah mencari Ust. Sanusi — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya saja ke santri lain atau ke satpam di pos jaga. Semoga Allah mudahkan langkahmu."
const TEKS_BABAK_5_PUTRI := "Selamat datang di Pesantren Universe, Nak. Jaga adab, jaga sholat, dan semangat belajarnya. Sekarang berangkatlah mencari Ustzh. Fatimah — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik; kalau bingung, tanya saja ke santriwati lain atau kembali ke saya. Semoga Allah mudahkan langkahmu."


## Satu babak dialog. nomor 1..5; di luar itu -> {}.
## pembicara "putra" / "putri"; tak dikenal -> "putra".
static func babak(nomor: int, pembicara := "putra") -> Dictionary:
	if nomor < 1 or nomor > JUMLAH_BABAK:
		return {}
	var p := pembicara if PEMBICARA.has(pembicara) else "putra"
	var putri := p == "putri"
	var teks := ""
	var pilihan: Array[Dictionary] = []
	match nomor:
		1:
			teks = TEKS_BABAK_1_PUTRI if putri else TEKS_BABAK_1_PUTRA
			# Sapaan "Ustadz"->"Ustadzah" = substitusi mekanis
			# (§9 butir 22), bukan kalimat baru.
			var sapaan := "Ustadzah" if putri else "Ustadz"
			pilihan = [
				{"teks": "Baik, %s. Saya siap belajar." % sapaan, "ke": 2},
				{"teks": "Apa saja aturannya, %s?" % sapaan, "ke": 3},
			]
		2:
			teks = TEKS_BABAK_2
			pilihan = [{"teks": "Lanjut", "ke": 3}]
		3:
			teks = TEKS_BABAK_3
			pilihan = [{"teks": "Lanjut", "ke": 4}]
		4:
			teks = TEKS_BABAK_4
			pilihan = [{"teks": "Lanjut", "ke": 5}]
		5:
			# Pola babak 1: konstanta putra/putri terpisah (TEKS BARU
			# Laras, DI-ACC Mas 23:03 WIB). Pilihan = pamit berangkat
			# (bukan ulangan babak 1) — keduanya ke -1, selesai.
			teks = TEKS_BABAK_5_PUTRI if putri else TEKS_BABAK_5_PUTRA
			var sapaan := "Ustadzah" if putri else "Ustadz"
			pilihan = [
				{"teks": "Baik, %s. Saya berangkat mencari beliau sekarang." % sapaan, "ke": -1},
				{"teks": "Terima kasih, %s. Saya pamit dulu." % sapaan, "ke": -1},
			]
	# Babak 4 putri: "Ust. Sanusi"->"Ustzh. Fatimah" (mekanis,
	# §9 butir 22 — nama misi "Cari Ust. Sanusi" di babak 4 ikut
	# berganti nama karena gurunya berganti). Babak 5 TIDAK lagi
	# memakai substitusi — sudah tertulis langsung di konstanta
	# PUTRI (TEKS BARU Laras).
	if putri and nomor == 4:
		teks = teks.replace("Ust. Sanusi", "Ustzh. Fatimah")
	return {"teks": teks, "pilihan": pilihan}
