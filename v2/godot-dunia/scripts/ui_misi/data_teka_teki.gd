class_name DataTekaTeki
## Data petunjuk teka-teki mencari guru (Raka, 18 Nov 2026).
## Perintah Mas 22:59 WIB — "Misal bisa tanya ke NPC atau satpam..
## jadi dibikin kek teka-teki.." — draf Laras
## v2/konsep/DRAF-PETUNJUK-TEKA-TEKI.md, DI-ACC Mas 23:03 WIB.
##
## LOGIKA/DATA MURNI, tanpa UI: tampilan panel dikerjakan DialogMisi
## (tampilkan_tanya / tampilkan_pesan), wiring ke main.gd.
## Semua teks = TEKS DRAF — menunggu tashih Mas (§9 butir 17).
##
## ATURAN (draf §4): satu baris singkat, menunjuk ke lokasi TANPA
## menyebut namanya langsung. Nama lokasi hanya ada di kolom kiri
## (untuk pembaca draf), TIDAK PERNAH muncul di teks teka-teki.
## Kunci = id lokasi di scripts/lokasi_acak.gd (putra 6 + putri 6).
## Sistem memilih teka-teki dari id lokasi di save
## (sanusi_lokasi / fatimah_lokasi) — TIDAK ada kunci save baru
## untuk lokasi. Tetap TANPA marker di peta (§9 butir 18).

## 12 teka-teki VERBATIM draf Laras (putra 6 + putri 6).
const TEKA_TEKI: Dictionary = {
	# --- Putra (LokasiAcak.KANDIDAT) ---
	"surau": "Tempat sholat berjamaah paling ramai di pesantren — beliau sering duduk di sana menunggu waktu sholat.",
	"kelas_putra": "Di barat, tempat bangku berderet dan papan tulis menunggu — beliau mungkin sedang menyiapkan pelajaran di sana.",
	"taman_surau": "Taman di balik Surau, tempat bunga dan pohon rindang — beliau suka duduk tenang di sana.",
	"perpustakaan_taman": "Tempat buku-buku akan tinggal — lahannya masih berpapan, tapi beliau kadang membaca di sekitar sana.",
	"masjid_besar": "Di timur, lahan luas yang sudah dipancang untuk bangunan besar — beliau suka melihat-lihat ke sana.",
	"kantin": "Kalau perut lapar, santri larinya ke mana? Ke sanalah beliau mungkin pergi.",
	# --- Putri (LokasiAcak.KANDIDAT_PUTRI, semua live) ---
	"musholla_putri": "Tempat sholat para santriwati — beliau sering duduk di sana.",
	"kelas_putri": "Tempat bangku berderet dan papan tulis menunggu — beliau mungkin sedang menyiapkan pelajaran di sana.",
	"taman_putri": "Tempat bunga warna-warni bermekaran — beliau suka duduk tenang di sana.",
	"asrama_putri": "Gedung tempat para santriwati tidur — beliau mungkin sedang memeriksa kamar di sana.",
	"kantor_ustadzah": "Tempat para ustadzah mengurus pesantren — beliau mungkin sedang di sana.",
	"halaman_putri": "Halaman terbuka di tengah kawasan putri — beliau suka berjalan-jalan di sana.",
}

## Kalimat pembuka boleh beda tiap NPC (draf §3) — isi teka-tekinya
## SAMA untuk lokasi yang sama. Hanya Satpam + Bilal yang punya
## pembuka di draf; NPC lain langsung ke teka-tekinya ("").
const PEMBUKA: Dictionary = {
	"satpam": "Hmm, terakhir kulihat beliau ke arah…",
	"bilal": "Aku tadi lihat beliau lewat, coba tebak…",
}

## NPC yang bisa ditanya saat misi cari guru aktif (langkah 4).
## Putra: Kyai BOLEH ditanya ulang setelah 5 babak (keputusan Mas
## 23:03 WIB no. 3 — draf awal bilang "tidak dulu", Mas memutuskan
## "Ya boleh"). Fatimah TIDAK pernah (beliau yang dicari); putri
## tidak punya Bilal/Faris/Satpam.
const NPC_PUTRA: Array[String] = ["kyai", "bilal", "faris", "satpam"]
const NPC_PUTRI: Array[String] = ["mariyah", "penjaga_putri"]

## Teks pengulangan (draf §6): NPC yang sama ditanya ulang sebelum
## misi selesai — satu NPC, satu petunjuk per misi.
const TEKS_ULANG := "Itu tadi petunjuknya — coba cari dulu, nanti tanya lagi kalau masih bingung."
## Jaga-jaga (draf §5): save kosong / id tidak valid — JANGAN bocorkan
## lokasi, JANGAN crash.
const TEKS_TANYA_LAGI := "Coba tanya lagi nanti."


## Teka-teki untuk satu id lokasi. "" bila id tidak dikenal.
static func teka_teki_untuk(lokasi_id: String) -> String:
	return String(TEKA_TEKI.get(lokasi_id, ""))


## Apakah id ini punya teka-teki?
static func ada(lokasi_id: String) -> bool:
	return TEKA_TEKI.has(lokasi_id)


## Kalimat pembuka NPC ("" bila NPC itu tidak punya pembuka khusus).
static func pembuka_untuk(npc_id: String) -> String:
	return String(PEMBUKA.get(npc_id, ""))


## Nama guru yang dicari per gender (§9 butir 22).
static func guru_saat_ini(save: Dictionary) -> String:
	return "Ustzh. Fatimah" if String(save.get("jenis_kelamin", "putra")) == "putri" else "Ust. Sanusi"


## Id lokasi guru saat ini dari save ("" bila belum diacak).
static func lokasi_id_saat_ini(save: Dictionary) -> String:
	var ob := Onboarding.baca(save)
	if String(save.get("jenis_kelamin", "putra")) == "putri":
		return String(ob["fatimah_lokasi"])
	return String(ob["sanusi_lokasi"])


## Teka-teki untuk misi cari guru yang SEDANG aktif. "" bila misi
## tidak aktif (langkah != 4) atau lokasi di save tidak valid —
## pemanggil menampilkan TEKS_TANYA_LAGI, bukan teka-teki.
static func teka_teki_saat_ini(save: Dictionary) -> String:
	if Onboarding.langkah_saat_ini(save) != 4:
		return ""
	return teka_teki_untuk(lokasi_id_saat_ini(save))


## Apakah NPC ini boleh ditanya saat ini? Syarat: misi cari guru
## aktif (langkah 4) DAN id NPC ada di daftar gender pemain.
static func npc_bisa_ditanya(save: Dictionary, npc_id: String) -> bool:
	if Onboarding.langkah_saat_ini(save) != 4:
		return false
	if String(save.get("jenis_kelamin", "putra")) == "putri":
		return npc_id in NPC_PUTRI
	return npc_id in NPC_PUTRA


## Apakah NPC ini SUDAH memberi petunjuk di misi ini? Flag disimpan
## di save kunci "tanya_guru" (array id NPC — wajib ada di
## SantriSave.default_data; load_data membuang kunci tak dikenal).
static func sudah_ditanya(save: Dictionary, npc_id: String) -> bool:
	return npc_id in (save.get("tanya_guru", []) as Array)


## Catat NPC sudah memberi petunjuk (sekali saja — tanpa duplikat).
## HANYA mengubah dict save, TIDAK menulis file (main.gd yang
## memanggil SantriSave.save_data).
static func catat_tanya(save: Dictionary, npc_id: String) -> void:
	var sudah: Array = save.get("tanya_guru", [])
	if npc_id in sudah:
		return
	sudah.append(npc_id)
	save["tanya_guru"] = sudah
