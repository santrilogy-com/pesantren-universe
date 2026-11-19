class_name SantriSave
## Penyimpanan lokal santri (user://santri.json).
## MVP: data tersimpan di perangkat. Struktur dict ini SENGAJA dibuat
## 1:1 dengan yang akan dikirim ke server app nanti (lihat CATATAN.md),
## jadi saat sinkronisasi server siap, tinggal kirim dict yang sama.

const SAVE_PATH := "user://santri.json"


static func default_data() -> Dictionary:
	return {
		"id_santri": "",
		"nama": "",
		# Login server (integrasi login-gender, 17 Nov 2026): identitas
		# dari API — ditulis _terapkan_login_server() di main.gd.
		"ig_username": "",
		# Gender ("putra"/"putri") — ditulis login server dari field
		# jenis_kelamin API; dibaca _pemain_adalah_putri() (spawn +
		# aturan batas cermin). Default "putra" = perilaku lama.
		"jenis_kelamin": "putra",
		# Peran ("santri"/"pengasuh"/"musyrif"/"musyrifah"/"keamanan")
		# — dibaca _pemain_boleh_lewat_batas(); API login belum
		# mengembalikannya, jadi kunci ini disiapkan untuk nanti.
		"role": "santri",
		# RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): kunci "jalur"
		# DIHAPUS — tidak ada lagi pilihan Misi / Ngaji Aja. Semua
		# santri ikut kurikulum tunggal berurutan (misi M1->M2->M3).
		# Save lama yang masih punya "jalur" tidak masalah (kunci itu
		# tidak lagi dibaca di mana pun).
		"poin": 0,
		"misi_selesai": [], # array id misi, mis. ["M1", "M2"]
		"mahadiyah": {}, # "2026-11-15": ["tahajjud", "dhuha", ...]
		"khataman_hadir": [], # tanggal hadir khataman, mis. ["2026-11-15"]
		# FASE A GELOMBANG 1 (Nusa, 18 Nov 2026 — pemilik kunci ini):
		# WAJIB ada di default_data: load_data hanya menyalin kunci
		# yang ada di sini (pelajaran bug flag pop-up Tara).
		"tes_lulus": [], # id tes yang lulus, mis. ["N1.T"] — 2 bintang
		# gelar per tes (A5); ditulis mesin kuis (A1).
		"bagian_lulus": [], # Bagian Nahwu yang lulus, mis. ["N1","N2"]
		# — gerbang tier gelar (A5); ditulis mesin kuis (A1).
		"gerbang_lulus": false, # gerbang ruang belajar Jenjang 0 lulus
		# (A4 — Gerbang.catat_gerbang; dibaca Gelar untuk tier 5
		# Muntahi). Ditambah Raka 18 Nov: tanpa baris ini load_data
		# membuang kunci itu dan tier 5 terkunci lagi saat muat ulang.
		"tugas_selesai": [], # id tugas dari Ustadz yang selesai (A7).
		# FASE A GELOMBANG 3 (Raka, 18 Nov 2026 — UI misi): langkah
		# Ruang Belajar yang SUDAH diberi poin, "modul:jenis" mis.
		# ["1:materi", "1:latihan", "1:kuis"] — anti-farming bila
		# pemain mengulang Ruang Belajar modul yang sama. WAJIB ada
		# di default_data (load_data membuang kunci yang tidak ada
		# di sini — pelajaran bug flag pop-up Tara).
		"rb_selesai": [],
		"baca_bab": [], # bab kitab yang dibaca di rak kitab, mis.
		# ["jurumiyah:3"] — syarat badge "Bisa Baca Kitab Kuning"
		# (A4); ditulis reader (gelombang 2).
		"onboarding": {}, # langkah alur santri baru §1A (A8 — Lukman;
		# dibaca defensif dengan .get("onboarding", {})).
		"terakhir_login": "",
		# Nomor ID lokal terakhir yang diterbitkan game ini (mode lokal).
		# Dipakai supaya daftar baru selalu dapat nomor BERIKUTNYA dan
		# tidak bertabrakan dengan ID yang sudah ada di perangkat ini.
		"id_terakhir": 0,
		# RONDE 6: outfit karakter (koko/songkok/sarung) — diganti di
		# kamar cangkruk, tersimpan seperti ID/poin. Save lama tanpa
		# kunci ini otomatis mendapat OUTFIT_DEFAULT (load_data hanya
		# menyalin kunci yang ada di default_data).
		# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum):
		# kunci "abaya" + "hijab_warna" (default = tampilan Ustadzah).
		"outfit": {"koko": "#faf7f0", "songkok": "#faf7f0", "sarung": "#0b6b4f", "abaya": "#065f46", "hijab_warna": "#f2ead6"},
		# RONDE 17: audio dimatikan (tombol "Suara" di HUD) — tersimpan
		# supaya pilihan bertahan antar sesi.
		"suara_mati": false,
		# HUD v3 (Tara, 18 Nov 2026): pop-up "PETUNJUK TOMBOL" sudah
		# ditutup pemain — tersimpan supaya tidak muncul lagi di sesi
		# berikutnya. WAJIB ada di default_data: load_data hanya
		# menyalin kunci yang ada di sini — tanpa kunci ini flag
		# hilang tiap muat ulang dan pop-up muncul SETIAP sesi.
		"petunjuk_tombol_ditutup": false,
		# TEKA-TEKI (Raka, 18 Nov 2026 — perintah Mas 22:59 WIB,
		# DI-ACC 23:03 WIB): NPC yang SUDAH memberi petunjuk di misi
		# cari guru ini, mis. ["bilal", "satpam"] — anti-spam draf
		# §6: satu NPC, satu petunjuk per misi. Direset tiap masuk
		# langkah 4 (Onboarding.maju) + reset(). WAJIB ada di
		# default_data (alasan sama seperti rb_selesai di atas).
		"tanya_guru": [],
		# KUALITAS ADAPTIF (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB:
		# "kualitas game tergantung device user"): mode kualitas
		# ("otomatis"/"ringan"/"sedang"/"tinggi", default "otomatis") dan
		# tingkat yang sedang diterapkan ("ringan"/"sedang"/"tinggi";
		# "" = belum pernah ditentukan -> KualitasAdaptif mendeteksi
		# perangkat saat setup). WAJIB ada di default_data (alasan sama
		# seperti rb_selesai di atas).
		"kualitas_mode": "otomatis",
		"kualitas_tingkat": "",
	}


static func load_data() -> Dictionary:
	var data := default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		return data
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return data
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		for k in data.keys():
			if parsed.has(k):
				data[k] = parsed[k]
	return data


static func save_data(data: Dictionary) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SantriSave: gagal menulis " + SAVE_PATH)
		return
	f.store_string(JSON.stringify(data))
	f.close()


## Format ID Santri: PV- diikuti 4 angka, mis. PV-0002.
static func id_valid(id_santri: String) -> bool:
	var s := id_santri.strip_edges().to_upper()
	if s.length() != 7:
		return false
	if not s.begins_with("PV-"):
		return false
	for i in range(3, 7):
		if not s[i].is_valid_int():
			return false
	return true


static func normalisasi_id(id_santri: String) -> String:
	return id_santri.strip_edges().to_upper()


## Normalisasi username Instagram: tanpa "@", huruf kecil, tanpa spasi
## di ujung. Sama dengan normalisasi server (register/login).
static func normalisasi_ig(ig_username: String) -> String:
	var s := ig_username.strip_edges().to_lower()
	if s.begins_with("@"):
		s = s.substr(1)
	return s


## Nomor urut dari sebuah ID valid ("PV-0002" -> 2). -1 kalau tidak valid.
static func nomor_id(id_santri: String) -> int:
	if not id_valid(id_santri):
		return -1
	return int(id_santri.strip_edges().to_upper().substr(3, 4))


## Catat sebuah ID yang dipakai (login/daftar) supaya nomor berikutnya
## tidak bertabrakan dengannya. Dipanggil setiap kali ada ID masuk.
static func catat_id(data: Dictionary, id_santri: String) -> void:
	var n := nomor_id(id_santri)
	if n > int(data.get("id_terakhir", 0)):
		data["id_terakhir"] = n


## Terbitkan ID Santri baru untuk pendaftar baru (mode lokal):
## nomor berikutnya setelah nomor tertinggi yang dikenal perangkat ini.
## Mengubah data["id_terakhir"] — panggil SEBELUM reset data baru,
## lalu salin nilai id_terakhir itu ke data baru (lihat main.gd).
static func terbitkan_id_baru(data: Dictionary) -> String:
	var n := int(data.get("id_terakhir", 0))
	var cur := nomor_id(String(data.get("id_santri", "")))
	n = maxi(n, cur) + 1
	data["id_terakhir"] = n
	return "PV-%04d" % n


## Tier dari total poin. Ambang sama dengan yang dipakai app web.
static func tier_for_points(poin: int) -> String:
	if poin >= 100:
		return "Penjaga Lentera"
	if poin >= 50:
		return "Pembuka Peti"
	if poin >= 25:
		return "Penjelajah"
	return "Santri Baru"


## Streak hari lengkap Ma'hadiyah (semua 7 kegiatan dicentang).
## Hitung mundur dari hari ini; berhenti di hari pertama yang tidak lengkap.
static func streak_mahadiyah(mahadiyah: Dictionary) -> int:
	var streak := 0
	var d := Time.get_date_dict_from_system()
	while true:
		var key := "%04d-%02d-%02d" % [d["year"], d["month"], d["day"]]
		if not mahadiyah.has(key):
			break
		var done: Array = mahadiyah[key]
		if done.size() < MissionData.MAHADIYAH.size():
			break
		streak += 1
		# Mundur satu hari (pakai unix time supaya aman di ujung bulan).
		var t: int = Time.get_unix_time_from_datetime_dict(d) - 86400
		d = Time.get_datetime_dict_from_unix_time(t)
		# get_datetime_dict_from_unix_time mengembalikan dict datetime;
		# ambil bagian tanggalnya saja.
		d = {"year": d["year"], "month": d["month"], "day": d["day"]}
	return streak


static func tanggal_hari_ini() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [d["year"], d["month"], d["day"]]
