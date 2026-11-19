class_name Onboarding
## State machine alur santri baru — A8 Fase A (Lukman, 18 Nov 2026).
##
## Acuan: DRAF-ALUR-MISI.md §1A (DI-ACC Mas 18:16 WIB, 18 Nov 2026):
##   Daftar → cari Ust. Aqsal M → percakapan aturan pesantren →
##   cari Ust. Sanusi (lokasi RANDOM) → belajar ke Ust. Sanusi →
##   tes kenaikan di Kantor → belajar lagi → HATAM.
##
## File ini MURNI LOGIKA (state + data rantai + NPC Sanusi). TIDAK
## ada UI di sini — tampilan percakapan/panel misi dikerjakan Sinta
## (A9, mockup dulu). Wiring ke main.gd dilakukan gelombang 2 oleh
## Raka (lihat cara panggil buat_sanusi() di bawah).
##
## BENTUK SAVE (kunci "onboarding", dict di dalam save utama):
##   {
##     "langkah": 1,        # 1..7 (§1A)
##     "modul": 1,          # modul Nahwu berjalan (1..30, §2.1)
##     "sanusi_lokasi": "", # id lokasi acak saat ini (lihat
##                          # LokasiAcak.KANDIDAT), "" = belum diacak
##     "fatimah_lokasi": "", # id lokasi acak putri (lihat
##                          # LokasiAcak.KANDIDAT_PUTRI), "" = belum
##                          # diacak (§9 butir 22)
##     "tes_lulus": 0,      # jumlah tes kenaikan yang sudah lulus
##     "selesai": false,    # true = HATAM Nahwu Dasar
##   }
## Kunci dibaca DEFENSIF (save.get("onboarding", {})) — Nusa (agen
## paralel) yang menambahkan default "onboarding": {} ke
## save_data.gd; file itu TIDAK diubah di sini. Save lama tanpa
## kunci ini tetap jalan (dianggap langkah 1).
## CATATAN: SantriSave.load_data hanya menyalin kunci yang ada di
## default_data() — sampai Nusa menambahkan kuncinya, progres
## onboarding yang ditulis ke save AKAN HILANG saat load berikut.
## Itu urusan gelombang 2, bukan bug file ini.
##
## HAL YANG TIDAK DIKARANG (pertanyaan §9 terbuka):
##   - Butir 18 (mekanik random): lihat LokasiAcak — REFRESH_PER_MISI
##     + daftar kandidat = USULAN, menunggu keputusan Mas.
##   - Butir 19 (kantor putra): venue_tes() lokasi-agnostik.
##     19 Nov 2026 (Gilang, perintah Mas 18:09 WIB "Bikin kantor
##     putra sementara"): Kantor Putra SEMENTARA dibangun di
##     (-11,-4) (pesantren_builder.gd) — venue putra PINDAH ke
##     depan pintunya (-11,0). PINDAH LAGI 18:40 WIB (perintah Mas
##     "Kantor taruh di sebelah asrama tapi agak jauh"): kantor ke
##     selatan Asrama Putra (-18,22.5), celah 4 m — venue putra
##     PINDAH ke depan pintu utara (-18,18.5). Putri TETAP Kantor
##     Ustadzah (148,-33).
##     (Koreksi gelombang 2, Raka: (150,−28) SALAH — yang benar
##     (148,−33) sesuai kampus_putri.gd KANTOR_USTADZAH_POS dan
##     KONSEP-TATA-LETAK.md relokasi U3; draf §6.1 + §9 butir 19
##     ikut dibetulkan.)
##   - Butir 22 (onboarding putri): DI-ACC Mas 18:55 WIB, 18 Nov
##     2026 — jalur putri: Mariyah (pengasuh, Musholla Ar-Raudhah)
##     -> Fatimah (guru, lokasi acak KANDIDAT_PUTRI). Diwujudkan
##     di sini: kunci "fatimah_lokasi", maju()/lulus_tes()/
##     kembali_belajar() gender-aware (save["jenis_kelamin"] ==
##     "putri"), override misi_aktif() putri langkah 2–5, 7.
##     Perilaku putra TIDAK berubah. KONFIG_GENDER putri tetap "?"
##     (tidak diisi di sini). Factory NPC Fatimah (outfit + buat +
##     tempatkan) BUKAN di sini — milik Kirana di
##     scripts/npc_fatimah.gd (NPCFatimah.buat/tempatkan);
##     JANGAN buat factory kedua di file ini.
##   - Butir 17 (isi percakapan): TOPIK_PERCAKAPAN memakai garis
##     besar 6 topik §1A apa adanya, ditandai "DRAF — menunggu
##     tashih Mas". Bukan kalimat aturan final.
##   - Hatam = selesai 4 Bagian Nahwu Dasar (§1A langkah 7 + §9
##     butir 20): JUMLAH_MODUL = 30 mengikuti §2.1 (30 misi Nahwu
##     Dasar). Pemetaan tes PER BAGIAN (N1.T–N4.T, bukan per modul)
##     diselaraskan gelombang 2 bersama A1/A2 (mesin kuis + modul).

## Jumlah langkah §1A.
const JUMLAH_LANGKAH := 7
## Jumlah modul Nahwu Dasar (§2.1: 30 misi + 4 tes = 420 poin).
const JUMLAH_MODUL := 30
## Modul pertama (§1A langkah 5): Nahwu Dasar Bagian 1 Modul 01.
const MODUL_PERTAMA := "Nahwu Dasar Bagian 1 — Modul 01 \"Mengenal Kata\""
## Tes kenaikan (§1A langkah 6 + §2.1): kuis 10 soal, lulus ≥8/10.
const TES_JUMLAH_SOAL := 10
const TES_LULUS_MINIMAL := 8

## Rantai onboarding: judul + deskripsi per langkah (§1A).
## "target" = kunci lokasi untuk panel misi nanti:
##   "surau" = Surau (0,−14) · "sanusi" = lokasi acak saat ini ·
##   "venue_tes" = venue_tes(jenis_kelamin) · "" = tanpa target.
const LANGKAH: Array[Dictionary] = [
	{
		"id": 1,
		"judul": "Daftar jadi santri",
		"deskripsi": "Daftar (nama + gender) di app, dapat kasur (1 santri = 1 kasur), lalu masuk pesantren.",
		"npc": "",
		"target": "",
	},
	{
		"id": 2,
		"judul": "Cari Ust. Aqsal M",
		"deskripsi": "Cari Ustadz Aqsal — di game namanya tampil \"Ust. Aqsal M\". Beliau ada di Surau (area putra).",
		"npc": "Ust. Aqsal M",
		"target": "surau",
	},
	{
		"id": 3,
		"judul": "Percakapan aturan pesantren",
		"deskripsi": "DRAF — menunggu tashih Mas (butir 17). Bertemu Ust. Aqsal M: percakapan interaktif seputar aturan pesantren (6 topik, lihat TOPIK_PERCAKAPAN).",
		"npc": "Ust. Aqsal M",
		"target": "surau",
	},
	{
		"id": 4,
		"judul": "Cari Ust. Sanusi",
		"deskripsi": "Ust. Aqsal M menyuruh mencari Ust. Sanusi — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik. Tidak ada marker pasti di peta.",
		"npc": "Ust. Sanusi",
		"target": "sanusi",
	},
	{
		"id": 5,
		"judul": "Belajar ke Ust. Sanusi",
		"deskripsi": "Bertemu Ust. Sanusi, buka Ruang Belajar: materi singkat, latihan mudah, kuis. Modul pertama: Nahwu Dasar Bagian 1 — Modul 01 \"Mengenal Kata\".",
		"npc": "Ust. Sanusi",
		"target": "sanusi",
	},
	{
		"id": 6,
		"judul": "Tes kenaikan di Kantor",
		"deskripsi": "Setelah selesai belajar, pergi ke Kantor untuk ikut tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8.",
		"npc": "",
		"target": "venue_tes",
	},
	{
		"id": 7,
		"judul": "Belajar lagi sampai hatam",
		"deskripsi": "Lulus tes? Kembali belajar ke Ust. Sanusi (modul/bagian berikut), tes lagi di Kantor, ulangi sampai hatam Nahwu Dasar (4 Bagian). Gagal tes = ulangi belajar + tesnya saja, bukan dari awal.",
		"npc": "Ust. Sanusi",
		"target": "sanusi",
	},
]

## DRAF — menunggu tashih Mas (§9 butir 17). Garis besar 6 topik
## percakapan aturan pesantren (§1A) APA ADANYA — bukan kalimat
## aturan final. Isi detail ikut kurikulum / tashih Mas.
const TOPIK_PERCAKAPAN: Array[String] = [
	"Sambutan — Ust. Aqsal M menyambut santri baru, memperkenalkan diri (\"Saya Ust. Aqsal M\") dan pesantren (\"di sini kita belajar kitab kuning sambil main game\").",
	"Apa itu Pesantren Universe — belajar seperti pesantren sungguhan (kitab, ustadz, musyawarah) tapi dibungkus game (misi, poin, gelar, ranking).",
	"Aturan pokok pesantren — (a) adab kepada ustadz & sesama santri; (b) jadwal harian (sholat berjamaah, khataman, belajar); (c) zona putra/putri — tidak boleh masuk area seberang; (d) kasur & kamar — 1 santri 1 kasur, jaga kebersihan; (e) belajar berurutan — modul terkunci, tidak boleh loncat; (f) khidmah & musyawarah sebagai bagian dari belajar.",
	"Penugasan pertama — \"Sekarang cari Ust. Sanusi — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik.\"",
	"Penutup — santri mengiyakan, misi \"Cari Ust. Sanusi\" terbuka.",
	# Topik ke-6 = penanda bahwa percakapan ini beberapa pertukaran
	# dialog (bukan satu teks panjang) — butir ini BUKAN topik isi.
	"(Struktur — DRAF: percakapan interaktif beberapa pertukaran dialog, bukan satu teks panjang.)",
]

## Konfigurasi per-gender (butir 22 — jalur PUTRA dulu).
## "pengajar" = nama NPC pengajar onboarding per gender; putri
## BELUM diputuskan (tanda tanya = JANGAN diisi sendiri).
## "kyai_lokasi" = tempat langkah 2–3 per gender (putra: Surau;
## putri: MENYUSUL butir 22 — Ust. Aqsal M di Surau area putra).
const KONFIG_GENDER: Dictionary = {
	"putra": {"pengajar": "Ust. Sanusi", "kyai_lokasi": Vector3(0, 0, -14)},
	"putri": {"pengajar": "?", "kyai_lokasi": Vector3.ZERO},
}

## Outfit Ust. Sanusi — ustadz biasa (koko/songkok/sarung/kulit
## saja, TANPA serban/jenggot — itu khusus Kyai).
## Beda jelas dari yang sudah ada (palet Palette / MissionData):
##   Kyai      = koko KREM #f2ead6 + sarung HITAM + serban + jenggot
##   Ustadzah  = abaya ZAMRUD #065f46 + jilbab krem
##   Satpam    = koko NAVY GELAP #2b3a4a + sarung hitam + lencana
##   Bilal     = koko putih + sarung BIRU #1d4e6b + kacamata
##   Faris     = koko putih + sarung COKLAT #6b3a1d
##   Santri    = koko putih + sarung ZAMRUD #008062 (default)
##   Sanusi    = koko BIRU MUDA #cfe0f0 + sarung HITAM #2b2b2b
##   (kombinasi koko biru muda + sarung hitam tidak dipakai siapa
##   pun; songkok putih + kulit sawo matang = standar.)
const OUTFIT_SANUSI := {
	"koko": "#cfe0f0",
	"songkok": "#faf7f0",
	"sarung": "#2b2b2b",
	"kulit": "#c68e5e",
	"kacamata": false,
}

## Venue tes kenaikan — titik di DEPAN pintu gedung (pemain harus
## bisa berdiri di sana; jarak interaksi 3,5 m).
##   putra: depan pintu Kantor Putra SEMENTARA (-18,18.5) — 19 Nov 2026
##     (Gilang, perintah Mas 18:40 WIB "taruh di sebelah asrama tapi
##     agak jauh": pindah dari (-11,-4) ke selatan Asrama Putra,
##     celah 4 m dari dinding selatan asrama). Venue LAMA (0,−14, tengah
##     Surau) TIDAK TERJANGKAU pemain: dinding Surau bercollision,
##     titik terdekat dari luar 8 m > 3,5 m — tes putra tidak bisa
##     dibuka dari dunia sebelum pindah ini.
##   putri: Kantor Ustadzah (148,−33) — titik tengah gedung; pemain
##     bisa berdiri di dinding utara/selatan (3,0 m < 3,5 m).
const VENUE_TES_PUTRA := Vector3(-18, 0, 18.5)
const VENUE_TES_PUTRI := Vector3(148, 0, -33)


## ---------- baca / tulis save (defensif) ----------

## Baca state onboarding dari save utama, dilengkapi default bila
## kunci belum ada (save lama / Nusa belum menambah default-nya).
## Mengembalikan dict BARU (salinan) — tulis balik via _tulis().
static func baca(save: Dictionary) -> Dictionary:
	var ob := {"langkah": 1, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false}
	var mentah: Variant = save.get("onboarding", {})
	if mentah is Dictionary:
		for k in ob.keys():
			if (mentah as Dictionary).has(k):
				ob[k] = (mentah as Dictionary)[k]
	# Jepit ke rentang yang sah (save korup / angka liar).
	ob["langkah"] = clampi(int(ob["langkah"]), 1, JUMLAH_LANGKAH)
	ob["modul"] = clampi(int(ob["modul"]), 1, JUMLAH_MODUL)
	ob["tes_lulus"] = maxi(0, int(ob["tes_lulus"]))
	ob["selesai"] = bool(ob["selesai"])
	if not LokasiAcak.id_valid(String(ob["sanusi_lokasi"])) and String(ob["sanusi_lokasi"]) != "":
		ob["sanusi_lokasi"] = ""
	if not LokasiAcak.id_valid_putri(String(ob["fatimah_lokasi"])) and String(ob["fatimah_lokasi"]) != "":
		ob["fatimah_lokasi"] = ""
	if bool(ob["selesai"]):
		ob["langkah"] = JUMLAH_LANGKAH
	return ob


static func _tulis(save: Dictionary, ob: Dictionary) -> void:
	save["onboarding"] = ob


## Reset onboarding ke awal (dipakai tes + daftar ulang).
static func reset(save: Dictionary) -> void:
	_tulis(save, {"langkah": 1, "modul": 1, "sanusi_lokasi": "", "fatimah_lokasi": "", "tes_lulus": 0, "selesai": false})
	# TEKA-TEKI (Raka, 18 Nov 2026): flag tanya ikut direset — alur
	# baru = misi cari guru baru (lihat maju() di bawah).
	save["tanya_guru"] = []


## ---------- state machine langkah 1–7 ----------

## Langkah saat ini (1..7). Save tanpa kunci = 1.
static func langkah_saat_ini(save: Dictionary) -> int:
	return int(baca(save)["langkah"])


## Apakah onboarding sudah hatam (Nahwu Dasar selesai)?
static func selesai(save: Dictionary) -> bool:
	return bool(baca(save)["selesai"])


## Maju SATU langkah (tidak bisa loncat — hanya +1). Mengembalikan
## langkah baru. Di 7 / sudah hatam: tetap 7.
## Masuk langkah 4 (misi "cari Ust. Sanusi" dimulai) = lokasi
## Sanusi DIACAK di sini (usulan butir 18 — LokasiAcak).
static func maju(save: Dictionary) -> int:
	var ob := baca(save)
	if bool(ob["selesai"]) or int(ob["langkah"]) >= JUMLAH_LANGKAH:
		_tulis(save, ob)
		return JUMLAH_LANGKAH
	ob["langkah"] = int(ob["langkah"]) + 1
	if int(ob["langkah"]) == 4:
		# Gender-aware (§9 butir 22): putri mengacak Fatimah,
		# putra mengacak Sanusi seperti semula.
		# TEKA-TEKI (Raka, 18 Nov 2026): masuk langkah 4 = misi cari
		# guru BARU dimulai — flag tanya direset (satu NPC, satu
		# petunjuk PER MISI, draf §6).
		save["tanya_guru"] = []
		if String(save.get("jenis_kelamin", "putra")) == "putri":
			var baru_p := LokasiAcak.lokasi_berikutnya_putri(String(ob["fatimah_lokasi"]))
			ob["fatimah_lokasi"] = String(baru_p["id"])
		else:
			var baru := LokasiAcak.lokasi_berikutnya(String(ob["sanusi_lokasi"]))
			ob["sanusi_lokasi"] = String(baru["id"])
	_tulis(save, ob)
	return int(ob["langkah"])


## Tes kenaikan LULUS di langkah 6: catat, lalu kembali belajar
## (langkah 5, modul berikut) — atau HATAM bila modul sudah habis.
## Mengembalikan langkah baru (5, atau 7 bila hatam).
static func lulus_tes(save: Dictionary) -> int:
	var ob := baca(save)
	if int(ob["langkah"]) != 6:
		return int(ob["langkah"])
	ob["tes_lulus"] = int(ob["tes_lulus"]) + 1
	if int(ob["modul"]) >= JUMLAH_MODUL:
		ob["selesai"] = true
		ob["langkah"] = JUMLAH_LANGKAH
		_tulis(save, ob)
		return JUMLAH_LANGKAH
	ob["modul"] = int(ob["modul"]) + 1
	ob["langkah"] = 5
	# Modul berikut = misi cari pengajar baru = lokasi diacak lagi
	# (usulan butir 18 — LokasiAcak.REFRESH_PER_MISI).
	# Gender-aware (§9 butir 22): putri -> Fatimah, putra -> Sanusi.
	if String(save.get("jenis_kelamin", "putra")) == "putri":
		var baru_p := LokasiAcak.lokasi_berikutnya_putri(String(ob["fatimah_lokasi"]))
		ob["fatimah_lokasi"] = String(baru_p["id"])
	else:
		var baru := LokasiAcak.lokasi_berikutnya(String(ob["sanusi_lokasi"]))
		ob["sanusi_lokasi"] = String(baru["id"])
	_tulis(save, ob)
	return 5


## Tes kenaikan GAGAL di langkah 6: ulangi belajar + tesnya saja
## (§1A langkah 7) — kembali ke langkah 5, modul TETAP.
## Mengembalikan langkah baru (5, atau langkah saat ini bila
## dipanggil di luar langkah 6).
static func gagal_tes(save: Dictionary) -> int:
	var ob := baca(save)
	if int(ob["langkah"]) != 6:
		return int(ob["langkah"])
	ob["langkah"] = 5
	_tulis(save, ob)
	return 5


## Kembali belajar dari langkah 7 (loop §1A — dipakai bila alur
## sampai di langkah 7 tapi belum hatam, mis. setelah maju manual).
## Modul +1; bila modul habis, tandai hatam. Mengembalikan 5/7.
static func kembali_belajar(save: Dictionary) -> int:
	var ob := baca(save)
	if bool(ob["selesai"]):
		return JUMLAH_LANGKAH
	if int(ob["modul"]) >= JUMLAH_MODUL:
		ob["selesai"] = true
		ob["langkah"] = JUMLAH_LANGKAH
		_tulis(save, ob)
		return JUMLAH_LANGKAH
	ob["modul"] = int(ob["modul"]) + 1
	ob["langkah"] = 5
	# Gender-aware (§9 butir 22): putri -> Fatimah, putra -> Sanusi.
	if String(save.get("jenis_kelamin", "putra")) == "putri":
		var baru_p := LokasiAcak.lokasi_berikutnya_putri(String(ob["fatimah_lokasi"]))
		ob["fatimah_lokasi"] = String(baru_p["id"])
	else:
		var baru := LokasiAcak.lokasi_berikutnya(String(ob["sanusi_lokasi"]))
		ob["sanusi_lokasi"] = String(baru["id"])
	_tulis(save, ob)
	return 5


## Tandai hatam secara langsung (dipakai A2/mesin kuis bila modul
## terakhir selesai lewat jalur lain). Langkah jadi 7.
static func tandai_hatam(save: Dictionary) -> int:
	var ob := baca(save)
	ob["selesai"] = true
	ob["langkah"] = JUMLAH_LANGKAH
	_tulis(save, ob)
	return JUMLAH_LANGKAH


## ---------- misi aktif (untuk panel misi nanti, A9) ----------

## Venue tes kenaikan per gender (lokasi-agnostik — posisi sebagai
## parameter). "putri" = Kantor Ustadzah; SELAIN itu = putra.
## SEMENTARA, menunggu §9 butir 19 — lihat konstanta di atas.
static func venue_tes(jenis_kelamin: String) -> Vector3:
	if jenis_kelamin == "putri":
		return VENUE_TES_PUTRI
	return VENUE_TES_PUTRA


## Id lokasi venue tes (untuk panel misi): "kantor_putra" / "kantor_ustadzah".
static func venue_tes_id(jenis_kelamin: String) -> String:
	if jenis_kelamin == "putri":
		return "kantor_ustadzah"
	return "kantor_putra"


## Misi yang sedang aktif: judul + deskripsi + npc + target lokasi
## (Vector3; Vector3.ZERO = tanpa target). "jenis_kelamin" untuk
## venue tes (default "putra").
static func misi_aktif(save: Dictionary, jenis_kelamin: String = "putra") -> Dictionary:
	var ob := baca(save)
	var idx: int = int(ob["langkah"]) - 1
	var data: Dictionary = LANGKAH[idx]
	var target_pos := Vector3.ZERO
	match String(data["target"]):
		"surau":
			target_pos = Vector3(0, 0, -14)
		"sanusi":
			target_pos = LokasiAcak.pos_dari_id(String(ob["sanusi_lokasi"]))
		"venue_tes":
			target_pos = venue_tes(jenis_kelamin)
	var judul := String(data["judul"])
	var deskripsi := String(data["deskripsi"])
	var npc := String(data["npc"])
	# Jalur putri (§9 butir 22, DI-ACC Mas 18:55 WIB, 18 Nov 2026):
	# santri putri -> Ustzh. Mariyah (pengasuh, Musholla
	# Ar-Raudhah) -> Ustzh. Fatimah (guru, lokasi acak putri).
	# Tabel LANGKAH TIDAK dirombak — override di sini saja.
	# Langkah 6: target tetap venue_tes (sudah gender-aware),
	# hanya deskripsi menyebut "Kantor Ustadzah".
	if jenis_kelamin == "putri":
		match int(ob["langkah"]):
			2:
				judul = "Cari Ustzh. Mariyah"
				deskripsi = "Cari Ustzh. Mariyah — pengasuh putri, di Musholla Ar-Raudhah (area putri)."
				npc = "Ustzh. Mariyah"
				target_pos = Vector3(134, 0, -24)
			3:
				deskripsi = "DRAF — menunggu tashih Mas (butir 17). Bertemu Ustzh. Mariyah: percakapan interaktif seputar aturan pesantren (6 topik, lihat TOPIK_PERCAKAPAN)."
				npc = "Ustzh. Mariyah"
				target_pos = Vector3(134, 0, -24)
			4:
				judul = "Cari Ustzh. Fatimah"
				deskripsi = "Ustzh. Mariyah menyuruh mencari Ustzh. Fatimah — beliau yang akan mengajarimu Nahwu Dasar. Tempatnya berpindah-pindah, jadi carilah baik-baik. Tidak ada marker pasti di peta."
				npc = "Ustzh. Fatimah"
				target_pos = LokasiAcak.pos_dari_id_putri(String(ob["fatimah_lokasi"]))
			5:
				judul = "Belajar ke Ustzh. Fatimah"
				deskripsi = "Bertemu Ustzh. Fatimah, buka Ruang Belajar: materi singkat, latihan mudah, kuis. Modul pertama: Nahwu Dasar Bagian 1 — Modul 01 \"Mengenal Kata\"."
				npc = "Ustzh. Fatimah"
				target_pos = LokasiAcak.pos_dari_id_putri(String(ob["fatimah_lokasi"]))
			6:
				deskripsi = "Setelah selesai belajar, pergi ke Kantor Ustadzah untuk ikut tes kenaikan (tes naik bagian N.T): kuis 10 soal, lulus bila benar minimal 8."
			7:
				deskripsi = "Lulus tes? Kembali belajar ke Ustzh. Fatimah (modul/bagian berikut), tes lagi di Kantor Ustadzah, ulangi sampai hatam Nahwu Dasar (4 Bagian). Gagal tes = ulangi belajar + tesnya saja, bukan dari awal."
				npc = "Ustzh. Fatimah"
				target_pos = LokasiAcak.pos_dari_id_putri(String(ob["fatimah_lokasi"]))
	if int(ob["langkah"]) == 5:
		deskripsi += " Modul berjalan: %d dari %d." % [int(ob["modul"]), JUMLAH_MODUL]
	if int(ob["langkah"]) == JUMLAH_LANGKAH and bool(ob["selesai"]):
		judul = "Hatam — Nahwu Dasar selesai"
		deskripsi = "Alhamdulillah — Nahwu Dasar (4 Bagian, %d modul) hatam. Lanjut ke gerbang ruang belajar + Kelas Jurumiyah (§2.1)." % JUMLAH_MODUL
	return {
		"langkah": int(ob["langkah"]),
		"judul": judul,
		"deskripsi": deskripsi,
		"npc": npc,
		"target_id": String(data["target"]),
		"target_pos": target_pos,
		"modul": int(ob["modul"]),
		"tes_lulus": int(ob["tes_lulus"]),
		"selesai": bool(ob["selesai"]),
	}


## ---------- NPC Ust. Sanusi ----------

## Buat NPC Ust. Sanusi (BARU — bukan Kyai/Ustadzah/Bilal/Faris).
## Mode DIAM (berdiri tetap di tempat — santri yang mencari dia,
## bukan dia yang keliling). Posisi awal = Surau (0,−14, lokasi
## live); gelombang 2 MEMINDAHKAN dia ke lokasi acak tiap misi
## "cari Ust. Sanusi" dimulai — lihat tempatkan_sanusi().
##
## CARA PAKAI (wiring gelombang 2, Raka — di main.gd _spawn_npcs(),
## SATU tempat saja, jangan tabrakan dengan agen lain):
##   var sanusi := Onboarding.buat_sanusi(self)
##   # tiap misi "cari Ust. Sanusi" dimulai (langkah 4):
##   var lok := LokasiAcak.lokasi_berikutnya(_save_onboarding_lokasi)
##   Onboarding.tempatkan_sanusi(sanusi, lok["pos"])
##   sanusi.pesan.connect(_on_npc_pesan)  # pola main.gd (feed
##   melayang ui.gd) — sama seperti NPC lain di _spawn_npcs().
##   sanusi.rute_selesai.connect(_on_npc_rute_selesai)
## JANGAN panggil buat_sanusi() dua kali (satu Sanusi saja).
static func buat_sanusi(parent: Node) -> SantriNPC:
	var npc := SantriNPC.new()
	# KONSEP SONGKOK v1 (ACC Mas 14:07): model peci campur 50/50 acak
	# tapi tetap per NPC — hash nama (SantriPlayer.peci_model_untuk).
	var outfit_sanusi := OUTFIT_SANUSI.duplicate()
	outfit_sanusi["peci_model"] = SantriPlayer.peci_model_untuk("Ust. Sanusi")
	npc.setup("Ust. Sanusi", Vector3(0, 0, -14), [Vector3(0, 0, -14)], outfit_sanusi, true)
	parent.add_child(npc)
	return npc


## Pindahkan Sanusi ke posisi lokasi acak (dipanggil tiap misi
## "cari Ust. Sanusi" dimulai — setelah LokasiAcak diacak).
## Mode DIAM membuat dia tetap di situ sampai dipindah lagi.
static func tempatkan_sanusi(npc: SantriNPC, pos: Vector3) -> void:
	if npc == null:
		return
	npc.position = pos
