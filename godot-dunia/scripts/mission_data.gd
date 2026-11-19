class_name MissionData
## Data misi + kegiatan Ma'hadiyah Pesantren Universe (Fase 1: rantai Nahwu).
## Konten ditulis di sini (bukan di main) supaya mudah diganti/ditambah
## tanpa menyentuh logika game. Nanti konten bisa datang dari server app.

## 7 kegiatan Ma'hadiyah wajib harian (sama dengan daftar di app web).
const MAHADIYAH: Array[String] = [
	"tahajjud",
	"subuh_berjamaah",
	"dzikir_pagi",
	"dhuha",
	"tilawah",
	"lima_waktu_berjamaah",
	"dzikir_petang",
]

const MAHADIYAH_LABEL: Dictionary = {
	"tahajjud": "Tahajjud",
	"subuh_berjamaah": "Subuh berjamaah",
	"dzikir_pagi": "Dzikir pagi",
	"dhuha": "Dhuha",
	"tilawah": "Tilawah",
	"lima_waktu_berjamaah": "Lima waktu berjamaah",
	"dzikir_petang": "Dzikir petang",
}

## Rantai misi Nahwu (M1 -> M2 -> M3). Misi berikut terkunci sampai
## misi sebelumnya selesai. "syarat" = kondisi lokasi sebelum kuis bisa
## dibuka: "" = di mana saja dekat penanda; "kelas" = harus di dalam
## ruang kelas; "peti" = harus dekat peti.
const MISSIONS: Array[Dictionary] = [
	{
		"id": "M1",
		"judul": "Misi 1 — Kenalan dengan Nahwu",
		"penanda": Vector3(3.0, 0, -6.5),
		"penanda_label": "Papan Misi 1",
		"syarat": "",
		"materi_judul": "Apa itu ilmu Nahwu?",
		"materi": "Nahwu adalah ilmu yang mempelajari perubahan akhir kata (i'rab) dalam bahasa Arab. Contoh: kata 'kitab' berubah harakat akhirnya tergantung kedudukannya dalam kalimat. Dengan Nahwu, kita bisa membaca kitab kuning dengan benar.",
		"kuis": "Apa yang dipelajari ilmu Nahwu?",
		"opsi": ["Perubahan akhir kata (i'rab)", "Cara menghafal Al-Quran", "Sejarah Islam", "Cara berwudhu"],
		"jawaban": 0,
		"poin": 10,
		"peti": false,
	},
	{
		"id": "M2",
		"judul": "Misi 2 — I'rab: Isim Marfu'",
		# RONDE 4 (15 Nov): penanda M2 pindah KE DALAM interior Surau
		# (map terpisah di z=-300) — papan tulisnya sekarang Smartboard
		# di dinding barat interior, titik berdirinya (-4.6, 0, -300).
		# RONDE 5 (15 Nov): papan tulis DIHAPUS (Mas: "cukup smartboard
		# aja") — penanda + materi kini menyebut Smartboard, bukan
		# papan tulis.
		# RONDE 14: interior diputar -25° mengelilingi pintu dan
		# smartboard pindah ke ujung utara dinding barat — penanda ini
		# posisi DUNIA (marker anak root luar yang berimpit dengan
		# interior): (0.14,-305.19) = ke_dunia((-4.6,-304.2)), 2,4 m
		# dari titik berdiri smartboard dunia (-1.43,-307.02).
		"penanda": Vector3(0.14, 0, -305.19),
		"penanda_label": "Smartboard Surau",
		"syarat": "surau",
		"materi_judul": "Isim marfu' ditandai dhammah",
		"materi": "Isim marfu' adalah isim yang berkedudukan sebagai subjek, contohnya mubtada'. Tandanya dhammah: 'al-kitabu' (kitab itu). Masuklah ke dalam surau dan perhatikan smartboard sebelum menjawab kuisnya.",
		"kuis": "Apa tanda isim marfu'?",
		"opsi": ["Dhammah", "Fathah", "Kasrah", "Sukun"],
		"jawaban": 0,
		"poin": 15,
		"peti": false,
	},
	{
		"id": "M3",
		"judul": "Misi 3 — Buka Peti Kayu",
		# RONDE 20: peti PINDAH (6,10) -> (0,26) kawasan bersama.
		# Pagar putra/putri (x=0, z -60..+16) membuat peti lama
		# jatuh di AREA PUTRI — santri putra tidak bisa lagi
		# menjangkaunya tanpa melanggar pakem batas. Posisi baru
		# di sumbu selatan (depan Perpustakaan & Taman), terjangkau
		# kedua area. Penanda + posisi peti di builder ikut pindah.
		"penanda": Vector3(0, 0, 26),
		"penanda_label": "Peti Kayu",
		"syarat": "peti",
		"materi_judul": "Isim, fi'il, dan huruf",
		"materi": "Kalimat dalam bahasa Arab tersusun dari tiga unsur: isim (kata benda, mis. kitab), fi'il (kata kerja, mis. kataba = dia menulis), dan huruf (mis. fi = di dalam). Jawab dengan benar untuk membuka peti kayu ini!",
		"kuis": "Manakah yang termasuk isim?",
		"opsi": ["kitabun (kitab)", "kataba (dia menulis)", "fi (di dalam)", "min (dari)"],
		"jawaban": 0,
		"poin": 25,
		"peti": true,
	},
]

## Slide Smartboard di dalam Surau (RONDE 4, 15 Nov — Mas minta ada
## smartboard buat presentasi). Materi Nahwu M1: isim / fi'il / huruf.
## "ringkas" = satu baris yang tampil di layar 3D smartboard.
const SMARTBOARD_SLIDES: Array[Dictionary] = [
	{
		"judul": "Isim — Kata Benda",
		"isi": "Isim adalah kata benda: kitab (buku), masjid, santri, guru. Tandanya: bisa dimasuki al- (al-kitabu), bisa tanwin (kitabun), dan bisa didahului huruf jarr (fi al-masjidi — di dalam masjid).",
		"ringkas": "Isim = kata benda",
	},
	{
		"judul": "Fi'il — Kata Kerja",
		"isi": "Fi'il adalah kata kerja: kataba (dia menulis), yaktubu (dia sedang menulis), uktub (tulislah!). Fi'il berubah menurut waktu: madhi (lampau), mudhari' (sekarang / akan datang), dan amr (perintah).",
		"ringkas": "Fi'il = kata kerja",
	},
	{
		"judul": "Huruf — Kata Sambung",
		"isi": "Huruf adalah kata yang tidak punya makna sendiri: fi (di dalam), min (dari), ila (ke), 'ala (di atas). Huruf menyambung isim dan fi'il sehingga kalimat menjadi lengkap.",
		"ringkas": "Huruf = kata sambung",
	},
]

## Video pelajaran untuk Smartboard (RONDE 4): URL YouTube dibuka di tab
## browser baru lewat JavaScriptBridge (khusus export web). KOSONG =
## tombol nonaktif ("Belum ada video"). BATAS JUJUR: video TIDAK BISA
## diputar di dalam scene Godot web — Godot web hanya mendukung video
## Ogg Theora, dan embed YouTube adalah iframe, bukan di dalam canvas 3D.
## Jadi smartboard menampilkan slide, videonya dibuka di tab baru.
const SMARTBOARD_VIDEO_URL := ""

## PILIHAN OUTFIT (RONDE 6 — Mas: ganti baju/songkok/sarung "kek game
## beneran", di kamar cangkruk). Warna disimpan sebagai hex di save
## ("outfit": {"koko": hex, "songkok": hex, "sarung": hex}).
const OUTFIT_KOKO: Array[Dictionary] = [
	{"nama": "Putih", "warna": Color("#faf7f0")},
	{"nama": "Krem", "warna": Color("#e8dcc0")},
	{"nama": "Hijau Muda", "warna": Color("#cfe8d0")},
	{"nama": "Biru Muda", "warna": Color("#cfe0f0")},
]
const OUTFIT_SONGKOK: Array[Dictionary] = [
	{"nama": "Putih", "warna": Color("#faf7f0")},
	{"nama": "Hitam", "warna": Color("#1a1a1a")},
]
const OUTFIT_SARUNG: Array[Dictionary] = [
	{"nama": "Zamrud", "warna": Color("#0b6b4f")},
	{"nama": "Biru", "warna": Color("#1d4e6b")},
	{"nama": "Coklat", "warna": Color("#6b4423")},
	{"nama": "Hitam", "warna": Color("#2b2b2b")},
]
## PILIHAN ABAYA + JILBAB (KIRANA 17 Nov 2026 — Mas: "Abaya dan
## jilbab warnanya bisa dikostum ganti ketika ganti baju"): warna
## abaya + jilbab santriwati dipilih pemain lewat panel Ganti Baju,
## tersimpan di save ("outfit": {..., "abaya": hex,
## "hijab_warna": hex}). Default = tampilan Ustadzah (abaya zamrud
## #065f46 + jilbab krem #f2ead6). Kunci "hijab_warna" (bukan
## "jilbab") karena build_visual membaca kunci itu; label panel
## tetap "Jilbab". Hanya ditawarkan untuk santriwati (muslimah).
const OUTFIT_ABAYA: Array[Dictionary] = [
	{"nama": "Zamrud", "warna": Color("#065f46")},
	{"nama": "Hitam", "warna": Color("#23282e")},
	{"nama": "Navy", "warna": Color("#2b3a4a")},
	{"nama": "Coklat", "warna": Color("#5a3a22")},
]
const OUTFIT_JILBAB: Array[Dictionary] = [
	{"nama": "Krem", "warna": Color("#f2ead6")},
	{"nama": "Putih", "warna": Color("#faf7f0")},
	{"nama": "Hitam", "warna": Color("#23282e")},
	{"nama": "Zamrud", "warna": Color("#065f46")},
]
## PILIHAN WARNA KULIT (RONDE 11 — Mas: "Karakter harus beda² ya..
## bisa kulit, kacamata, kopyah hitam nasional dll"). Tiga pilihan:
## Terang / Sawo Matang (default lama Palette.KULIT) / Gelap.
## Disimpan sebagai hex di save ("outfit": {..., "kulit": hex}).
const OUTFIT_KULIT: Array[Dictionary] = [
	{"nama": "Terang", "warna": Color("#e8b98a")},
	{"nama": "Sawo Matang", "warna": Color("#c68e5e")},
	{"nama": "Gelap", "warna": Color("#8a5a33")},
]
## RONDE 11: songkok Hitam diperdalam #2b2b2b -> #1a1a1a (hitam pekat,
## "kopyah hitam nasional" Mas) supaya beda jelas dari putih. Save
## lama yang sudah memilih Hitam menyimpan "#2b2b2b" — tetap tampil
## hitam gelap, hanya tanda ✓ di panel yang tidak cocok sampai
## dipilih ulang (tidak ada santri produksi yang terkena: 0 santri).
const OUTFIT_DEFAULT := {"koko": "#faf7f0", "songkok": "#faf7f0", "sarung": "#0b6b4f", "kulit": "#c68e5e", "kacamata": false, "abaya": "#065f46", "hijab_warna": "#f2ead6"}
## RONDE 15 (Mas: karakter pemimpin pesantren): outfit Ust. Aqsal
## Murad — Pengasuh. Koko KREM + sarung HITAM (gelap, berwibawa);
## serban putih krem + jenggot gelap beruban di ujung + kumis tipis.
## Kulit sawo matang (sama seperti pemain — pembedanya serban +
## jenggot + kumis + sarung gelap). Kunci "serban"/"jenggot"/"kumis"
## hanya dibaca build_visual (player.gd); panel Ganti Baju TIDAK
## menawarkannya (hanya Kyai yang memakai).
const OUTFIT_KYAI := {"koko": "#f2ead6", "songkok": "#faf7f0", "sarung": "#23282e", "kulit": "#c68e5e", "kacamata": false, "serban": true, "serban_warna": "#f5f0e0", "jenggot": true, "jenggot_warna": "#2b241d", "uban_warna": "#7d7468", "kumis": true}
## RONDE 20 (Mas: Musholla Ar-Raudhah dipimpin Ustadzah Mariyah):
## outfit Ustadzah Mariyah — pimpinan pesantren putri. HIJAB zamrud
## gelap + gamis krem (koko) + rok zamrud (sarung, motif batik seperti
## biasa). Kunci "hijab"/"hijab_warna" hanya dibaca build_visual
## (player.gd); panel Ganti Baju TIDAK menawarkannya (hanya Ustadzah
## yang memakai). Beda jelas dari Kyai (serban krem + koko krem +
## sarung hitam) dan dari santri (peci putih + koko putih).
const OUTFIT_USTADZAH := {"koko": "#065f46", "songkok": "#faf7f0", "sarung": "#065f46", "kulit": "#c68e5e", "kacamata": false, "hijab": true, "hijab_warna": "#f2ead6", "abaya": "#065f46", "muslimah": true}
## RONDE 20: outfit SATPAM gerbang — penjaga gerbang putra/putri.
## Seragam gelap (koko biru gelap + songkok hitam + sarung hitam) supaya
## terbaca sebagai petugas, bukan santri. NPC diam di pos (3,3).
const OUTFIT_SATPAM := {"koko": "#2b3a4a", "songkok": "#1a1a1a", "sarung": "#2b2b2b", "kulit": "#c68e5e", "kacamata": false}

## Jadwal KHATAMAN (RONDE 6, Mas 22:17 WIB — ganti konsep "jadwal Ngaji
## Aja": sistem pesantren SATU jalur, pengajian kitab terjadwal — tiap
## jam tertentu ada sesi baca kitab bersama di surau, tiap hari sama.
## Kitab diambil dari jadwal lama (Jurumiyah, Amtsilah Tashrifiyyah,
## Safinatun Naja); "metode" bandongan/sorogan tidak lagi dipakai
## sebagai jalur — semua santri ikut kurikulum tunggal berurutan
## (misi M1->M2->M3). durasi_menit = lama sesi (untuk penanda
## "sedang berlangsung").
const KHATAMAN_JADWAL: Array[Dictionary] = [
	{"jam": "05:00", "durasi_menit": 60, "nama": "Ba'da Subuh", "kitab": "Jurumiyah"},
	{"jam": "13:00", "durasi_menit": 60, "nama": "Siang", "kitab": "Amtsilah Tashrifiyyah"},
	{"jam": "18:30", "durasi_menit": 60, "nama": "Ba'da Maghrib", "kitab": "Safinatun Naja"},
]


## Sesi khataman yang sedang berlangsung sekarang (jam perangkat),
## atau {} bila di luar jam sesi. Dipakai dashboard Kartu Santri.
static func khataman_saat_ini() -> Dictionary:
	var now := Time.get_datetime_dict_from_system()
	var menit_now := int(now["hour"]) * 60 + int(now["minute"])
	for s in KHATAMAN_JADWAL:
		var parts := String(s["jam"]).split(":")
		if parts.size() < 2:
			continue
		var mulai := int(parts[0]) * 60 + int(parts[1])
		var akhir := mulai + int(s.get("durasi_menit", 60))
		if menit_now >= mulai and menit_now < akhir:
			return s
	return {}


## Jadwal SHOLAT BERJAMAAH (RONDE 13, Mas 06:30 WIB — "kalau masuk
## waktu sholat maka semuanya ke surau untuk sholat"). Jam TETAP dulu
## (WIB, jam perangkat): Subuh 04:30, Dzuhur 12:00, Ashar 15:00,
## Maghrib 18:00, Isya 19:00. BATASAN: waktu sholat asli berubah tiap
## hari/tanggal — versi ini pakai jam tetap; jadwal dinamis (hisab)
## adalah ronde lain. durasi_menit = 1 (RONDE 18, Mas 12:14 WIB —
## adegan sholat jadi SINEMATIK singkat, bukan 10 menit): jendela
## 1 menit cukup untuk NPC berkumpul (±10-20 dtk jalan) + takbir
## (±4 dtk) + blackout (±2,5 dtk); NPC pulang setelah adegan selesai.
const WAKTU_SHOLAT: Array[Dictionary] = [
	{"nama": "Subuh", "jam": "04:30", "durasi_menit": 1},
	{"nama": "Dzuhur", "jam": "12:00", "durasi_menit": 1},
	{"nama": "Ashar", "jam": "15:00", "durasi_menit": 1},
	{"nama": "Maghrib", "jam": "18:00", "durasi_menit": 1},
	{"nama": "Isya", "jam": "19:00", "durasi_menit": 1},
]


## Sholat yang sedang berlangsung sekarang (jam desimal — main.gd
## memakai LangitDinamis.jam_saat_ini() supaya debug_jam dipakai
## tes/foto), atau {} bila di luar jendela sholat. Dipakai main.gd
## untuk memulai/mengakhiri sesi sholat berjamaah.
static func sholat_saat_ini(jam: float) -> Dictionary:
	var menit_now := int(jam * 60.0)
	for s in WAKTU_SHOLAT:
		var parts := String(s["jam"]).split(":")
		if parts.size() < 2:
			continue
		var mulai := int(parts[0]) * 60 + int(parts[1])
		var akhir := mulai + int(s.get("durasi_menit", 1))
		if menit_now >= mulai and menit_now < akhir:
			return s
	return {}

## Kalimat NPC (diucapkan bergantian sebagai chat bubble).
const NPC_LINES: Array[String] = [
	"Assalamu'alaikum! Ayo selesaikan misinya.",
	"Jangan lupa dhuha hari ini ya.",
	"Aku baru buka Peti Kayu, dapat 25 poin!",
	"Kelas Nahwu jam 8, jangan telat.",
	"Ustadz Aqsal Murad sedang di surau.",
	"Ranking regu minggu ini ketat sekali.",
]

## PERTUMBUHAN PESANTREN (keputusan Mas, 15 Nov ~09:08 WIB).
## Pesantren dimulai dari SURAU KECIL dulu (Tahap 0, Fase 1). Bangunan
## berikutnya dibuka bertahap mengikuti jumlah santri — lahan kosong di
## pesantren sudah disiapkan sebagai plot bertanda, dan bangunan muncul saat
## ambang tercapai. Ambang di bawah ini DISETUJUI Mas 15 Nov ~11:37 WIB:
## Ruang Kelas 25 santri, Asrama 50, Masjid Besar 100,
## Perpustakaan & Taman 200 santri. Papan tanda plot dan dashboard
## menampilkan angka sebenarnya dari data ini.
## "plot" = posisi lahan kosong di pesantren (x, z) tempat bangunan nanti berdiri.
const GROWTH_STAGES: Array[Dictionary] = [
	{"tahap": 0, "nama": "Surau Kecil", "ambang_santri": 0, "plot": Vector2(0, -12), "status": "dibangun"},
	{"tahap": 1, "nama": "Ruang Kelas", "ambang_santri": 25, "plot": Vector2(16, 0), "status": "terkunci"},
	{"tahap": 2, "nama": "Asrama", "ambang_santri": 50, "plot": Vector2(-16, 0), "status": "terkunci"},
	{"tahap": 3, "nama": "Masjid Besar", "ambang_santri": 100, "plot": Vector2(0, -32), "status": "terkunci"},
	{"tahap": 4, "nama": "Perpustakaan & Taman", "ambang_santri": 200, "plot": Vector2(0, 20), "status": "terkunci"},
]
