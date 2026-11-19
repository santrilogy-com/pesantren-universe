extends Node
## Pesantren Universe — orkestrator utama.
## Alur: login server (username IG + kata sandi opsional, kontrak
## v1.5.0) / daftar server (nama + akun IG + gender, kontrak v1.5.1)
## -> masuk pesantren 3D, spawn sesuai gender pemain.
## RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): TIDAK ADA lagi pilihan
## jalur (Misi / Ngaji Aja) — semua santri ikut kurikulum tunggal
## berurutan (misi M1->M2->M3) + pengajian kitab terjadwal (khataman).
## Semua belajar ada DI DALAM pesantren ini: misi Nahwu, khataman,
## Ma'hadiyah, chat bubble, dashboard Kartu Santri.
## Istilah: "pesantren" (bukan "dunia") — keputusan Mas 15 Nov ~09:09 WIB.

const CHAT_JARAK_INTERAKSI := 3.5

var _save: Dictionary = {}
# KASUR (Wulan, 18 Nov 2026 — tugas Mas 00:06 WIB: 1 santri = 1 kasur).
# Tugas kasur pemain ini (PembagianKasur, ledger lokal user://kasur.json
# — BUKAN field server). Dimuat di _ready + diperbarui tiap login/
# daftar baru. {} = belum terdaftar di ledger (save lama).
var _kasur_saya: Dictionary = {}
# Login server (integrasi login-gender, 17 Nov 2026): POST
# /api/santri/login mengembalikan ID + nama + jenis_kelamin +
# token sesi. Token sesi hanya di memori (berlaku 1 jam) — TIDAK
# disimpan di save. X-PV-Token TIDAK dipakai di game ini (hanya
# untuk POST /api/santri/points dari server tepercaya).
const SERVER_BASE_URL := "https://43-173-39-166.sslip.io"
const LOGIN_TIMEOUT_DETIK := 15.0
var _session_token: String = ""
var _login_http: HTTPRequest = null
# Registrasi-gender (Tara, 17 Nov 2026): request daftar punya
# HTTPRequest sendiri supaya tidak bentrok dengan request login.
var _register_http: HTTPRequest = null
var _pesantren: Dictionary = {}
var _player: SantriPlayer
var _player_capsule: CapsuleShape3D
var _rig: Node3D
var _spring: SpringArm3D
var _cam: Camera3D
# KUALITAS ADAPTIF (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB):
# manager kualitas (mode otomatis/manual + probe FPS + pantau).
var _kualitas: KualitasAdaptif = null
var _cam_yaw: float = 0.0
var _cam_pitch: float = -0.35
# KAMERA (Cakra, 17 Nov 2026; v2 18 Nov 00:16: goyang + framing
# DIMATIKAN — bug mabuk; modul hanya follow halus + anti-getar).
# v3 (18 Nov 13:13): 5 mode kamera + pinch-to-zoom (modul kamera.gd).
var _kamera: KameraPesantren
# PINCH-TO-ZOOM (v3): posisi jari aktif (index -> posisi layar) +
# jarak cubit frame lalu (0 = belum ada cubit dua jari).
var _sentuh := {}
var _jarak_cubit_lalu := 0.0
var _ui: PesantrenUI
var _markers: Dictionary = {}
var _chest_lid: Node3D
var _chest_opened: bool = false
var _npcs: Array[SantriNPC] = []
# RONDE 20 — referensi NPC khusus (dipakai rute sholat + batas):
# _kyai = Ust. Aqsal Murad (imam Surau, patroli putra);
# _ustadzah = Ustadzah Mariyah (imam Musholla Ar-Raudhah, patroli
# putri); _satpam = penjaga gerbang (diam di pos, TIDAK ikut sholat).
var _kyai: SantriNPC
var _ustadzah: SantriNPC
var _satpam: SantriNPC
# TEKA-TEKI (Raka, 18 Nov 2026): _bilal/_faris = santri putra yang
# bisa ditanya teka-teki (langkah 4); _penjaga_putri = Penjaga Pos
# Jaga putri (CEWE, abaya + jilbab — keputusan Mas 23:03 Opsi B +
# koreksi 23:04 WIB); _npc_tanya = NPC layar tanya yang sedang
# terbuka (dibersihkan saat jawaban dipilih).
var _bilal: SantriNPC
var _faris: SantriNPC
var _penjaga_putri: SantriNPC = null
var _npc_tanya: SantriNPC = null
var _active_misi: Dictionary = {}
# GELOMBANG 2 FASE A (Raka, 18 Nov 2026 — wiring fondasi A1/A5/A8):
# _kuis = sesi MesinKuis misi yang sedang dibuka (1 soal untuk
# M1-M3); _sanusi = NPC Ust. Sanusi (Onboarding, §1A langkah 4);
# _gelar_saat_ini = Gelar.nama_gelar(_save) — DISIMPAN SAJA, belum
# ditampilkan di mana pun (label/Kartu Santri menunggu HUD, A9).
var _kuis: MesinKuis = null
var _sanusi: SantriNPC = null
# Perintah Mas 20:30 WIB ("segera realisasikan" rantai putri):
# _fatimah = NPC Ustzh. Fatimah (guru putri, cerminan Sanusi).
var _fatimah: SantriNPC = null
var _gelar_saat_ini: String = ""
# FASE A GELOMBANG 3 (Raka, 18 Nov 2026 — UI misi, mockup DI-ACC
# Mas 18:58): manajer 4 panel UI misi (dialog / ruang belajar / tes
# kenaikan / panel misi). Dibuat di _ready setelah _ui.
var _manajer_misi: ManajerUIMisi = null
var _bob_time: float = 0.0
# RONDE 17 — audio suasana pesantren (ambience + bacaan kegiatan).
# _audio_unlocked = gestur pertama sudah terjadi (autoplay web).
var _audio: AudioPesantren
var _audio_unlocked: bool = false
# FITUR CUACA (Wulan, 17 Nov 2026; hook dipasang Raka): cuaca nyata
# lokasi pemain via Open-Meteo — dibuat sekali, mulai() aman dipanggil
# ulang (flag sudah_diminta cegah prompt izin kedua).
var _cuaca: Cuaca = null
# RONDE 13 — sholat berjamaah otomatis (Mas 06:30 WIB: "kalau masuk
# waktu sholat maka semuanya ke surau untuk sholat").
# _sholat_aktif + _sholat_nama + _sholat_akhir_menit = sesi berjalan;
# _pemain_ikut_sholat = pemain sudah menekan "Ikut Sholat";
# _npc_sholat_fase[npc] = "ke_pintu" | "ke_sajadah" | "sholat" |
# "pulang_dalam" | "pulang_luar" | "" (biasa);
# _npc_rumah[npc] = posisi sebelum sesi (untuk pulang);
# _sajadah_npc[npc] = posisi sajadah yang dipakai NPC itu.
var _sholat_aktif: bool = false
var _sholat_nama: String = ""
var _sholat_akhir_menit: int = 0
var _pemain_ikut_sholat: bool = false
var _npc_sholat_fase: Dictionary = {}
var _npc_rumah: Dictionary = {}
var _sajadah_npc: Dictionary = {}
# RONDE 18 — cegah sesi yang sama jalan 2x dalam 1 jendela: adegan
# sinematik (±30 dtk) selesai SEBELUM jendela 1 menit habis, jadi
# tanpa kunci ini sesi langsung mulai lagi (NPC jalan balik, takbir
# kedua). Kunci = nama + jam mulai + tanggal; dibersihkan saat
# tanggal berganti.
var _sholat_sudah: Dictionary = {}
var _sholat_tanggal: String = ""
# RONDE 18 — adegan sholat SINEMATIK (Mas 12:14 WIB: "adegan sholat
# cukup diambil pas takbir saja, lalu black out, lalu selesai").
# _sholat_adegan = "" (tidak ada adegan) | "kumpul" (NPC jalan ke
# Surau, banner IKUT SHOLAT masih tampil) | "takbir" (semua di
# sajadah, tangan terangkat, tahan TAKBIR_TAHAN_DETIK) | "gelap"
# (layar menghitam BLACKOUT_DETIK, teks "Sholat berjamaah...") |
# "selesai" (fade in + sesi berakhir, NPC pulang). Timer adegan
# berjalan di waktu GAME (delta _process), bukan jam perangkat.
var _sholat_adegan: String = ""
var _sholat_adegan_t: float = 0.0
const TAKBIR_TAHAN_DETIK := 4.0
const BLACKOUT_DETIK := 2.5
const BLACKOUT_FADE_DETIK := 0.5
const FADE_MASUK_DETIK := 0.8
const KUMPUL_TIMEOUT_DETIK := 25.0
## Yaw hadap kiblat 295° (InteriorSurau.KIBLAT_AZIMUT): arah kiblat
## (x,z) = (sin 295°, -cos 295°) = (-0.906, -0.423); wajah karakter
## di +Z lokal, jadi yaw = atan2(x, z) = -115° = -2.0071 rad.
const KIBLAT_YAW := -2.0071
# RONDE 16 — posisi imam: di depan baris depan saf, di sumbu mihrab.
# Dihitung runtime dari Sajadah_03 (tengah baris depan) + arah kiblat
# × jarak — supaya rotasi Surau ronde 14 tetap benar otomatis.
# 1.5 m dari pusat Sajadah_03 ≈ 0.9 m di depan tepi depan sajadah
# (sajadah 1.15 m); mihrab ~4.9 m di depan imam — jauh dari dinding.
const IMAM_JARAK_DEPAN := 1.5
# RONDE 4 — interior Surau sebagai map terpisah (ala GTA): pemain di
# dalam interior (z=-300) atau di peta luar? State santri (ID, nama,
# poin, misi) TIDAK disentuh saat bolak-balik — yang pindah hanya
# posisi pemain + kamera (teleport, lihat _teleport_player).
var _di_dalam: bool = false
# RONDE PERBAIKAN (Raka, integrasi item 7f): pemain di dalam map
# interior Musholla (60,-301)? Cermin _di_dalam (Surau) — dipakai
# _cek_pintu_musholla, _cek_batas, kamera, peta, dan sandal.
var _di_dalam_musholla: bool = false
var _smartboard_screen: Label3D
var _interior_door: Vector3 = Vector3(0, 0, -294)
# REVISI (Mas 17 Nov 22:51 WIB: Surau lurus) — KOREKSI 23:15 WIB:
# lurus = -90° (muka depan GLB di lokal +X): pintu luar kini
# (0,-3.8) di tengah dinding depan (selatan), keluar (0,-2.3)
# 1,5 m ke selatan di atas lantai serambi. Nilai runtime tetap
# dibaca dari builder di _ready (surau_pintu() + dict build).
# Dulu (asumsi 0° yang salah): pintu (0,-6), keluar (0,-4.5).
var _outdoor_door: Vector3 = Vector3(0, 0, -3.8)
var _interior_spawn: Vector3 = Vector3(0, 0, -295.5)
var _outdoor_exit: Vector3 = Vector3(0, 0, -2.3)
var _smartboard_spot: Vector3 = Vector3(-4.6, 0, -300)
# BACA BUKU (Tara, 17 Nov 2026): titik interaksi rak kitab — 2 di
# Surau (dari InteriorSurau.build()["rak_spots"]) + 1 di Musholla
# (dari InteriorMusholla.build()["rak_spot"]). Dibaca pakai .get()
# supaya _ready tidak crash sebelum merge.
var _rak_spots: Array[Vector3] = []
# REVISI (Mas 17 Nov 22:51 WIB): frame pintu LUAR kini LURUS —
# "pintu" = pusat celah pintu luar (0,-3.8); "sumbu" = arah
# memanjang celah (timur-barat); "masuk" = normal ke dalam
# bangunan (utara); "keluar" = normal ke luar/plaza (selatan).
# Dipakai koridor pintu LUAR + rute NPC. Dulu (Surau -25°):
# pintu (-3,38,-6,75); arah-arah = arah(115°/25°/205°).
# Frame pintu DALAM DIPISAH (interior TETAP miring -25° supaya
# mihrab tetap kiblat 295°): _surau_sumbu_dalam/_surau_keluar_dalam
# dari InteriorSurau.frame_pintu_dalam() — dipakai koridor keluar
# dari dalam Surau di _cek_pintu_surau.
var _surau_pintu: Vector3 = Vector3(0, 0, -3.8)
var _surau_sumbu: Vector3 = Vector3(1.0, 0, 0.0)
var _surau_masuk: Vector3 = Vector3(0.0, 0, -1.0)
var _surau_keluar: Vector3 = Vector3(0.0, 0, 1.0)
var _surau_sumbu_dalam: Vector3 = Vector3(0.9063, 0, 0.4226)
var _surau_keluar_dalam: Vector3 = Vector3(-0.4226, 0, 0.9063)
# RONDE 6 — kamar cangkruk (map interior kedua, ala GTA) + perbaikan
# DOUBLE SURAU: interior Surau + interior cangkruk DISEMBUNYIKAN saat
# pemain di luar (visible=false) — sebelumnya ruangan interior
# (18x14 m, dinding putih) berdiri di lapangan luar di z=-300 dan
# terlihat dari spawn sebagai bangunan kedua ("double surau").
var _di_dalam_cangkruk: bool = false
var _interior_root: Node3D
var _cangkruk_root: Node3D
# RONDE 21: cangkruk PINDAH (-12,-12) -> (-22,-18) (ACC Mas 22:57
# WIB, putra barat Surau baru) — pintu (-22,-14), keluar (-22,-12.5).
# Nilai awal di sini mengikuti builder (dipakai _cek_pintu_cangkruk).
var _cangkruk_door: Vector3 = Vector3(-22, 0, -14)
var _cangkruk_exit: Vector3 = Vector3(-22, 0, -12.5)
var _cangkruk_interior_door: Vector3 = Vector3(-60, 0, -295)
var _cangkruk_interior_spawn: Vector3 = Vector3(-60, 0, -296.5)
var _cangkruk_beds: Array = []
var _cangkruk_lemari: Vector3 = Vector3(-54.6, 0, -296.8)
var _sandal_luar_surau: Node3D
var _sandal_luar_cangkruk: Node3D
# RONDE 20 — Musholla Ar-Raudhah (putri, interior ketiga, ala GTA):
# ruangan 14x10 m di (60,0,-301), diputar -25° mengelilingi pintu
# (60,-296). Pemain putra TIDAK PERNAH masuk (pagar + barrier);
# yang masuk: Ustadzah Mariyah (patroli + imam putri).
var _musholla_root: Node3D
var _musholla_door: Vector3 = Vector3(60, 0, -296)
var _musholla_spawn: Vector3 = Vector3(60, 0, -297.5)
# RONDE 22 (Sinta): default pintu luar musholla PINDAH ke (134,-17.5)
# mengikuti Musholla baru (134,-24) — nilai lama (15.67,-19.01) posisi
# musholla Ronde 20 (18,-24), kini di BARAT tembok keliling (x=115):
# kalau dict build gagal memasok "musholla_exit", rute Ustadzah akan
# berakhir di barat tembok dan memotongnya lagi di segmen akhir.
# Nilai ini ditimpa dict build di _ready (lihat baris _musholla_exit).
var _musholla_exit: Vector3 = Vector3(134, 0, -17.5)
var _sandal_luar_musholla: Node3D
# RONDE 21 — penegakan batas putra/putri KERAS (Mas, pakem): tembok
# pemisah solid di x=14 (z -60..+16) menggantikan pagar kayu Ronde
# 20; gerbang (14,0) TERTUTUP + barrier collision penuh (builder).
# Aturan KERAS: pemain yang masuk zona larangan mendapat toast
# (dibatasi 1x per 4 detik) DAN didorong balik ke posisi legal
# terakhir — bukan cuma toast seperti Ronde 20. Selatan (z >= 16)
# tetap kawasan bersama. Nilai tembok dibaca dari dict build
# (_pesantren) di _ready — JANGAN hardcode ulang di sini.
# _batas_toast_count = jumlah toast batas yang tampil (dipakai tes
# headless). _pos_legal_terakhir = posisi legal terakhir pemain
# (dicatat tiap frame saat posisi legal).
var _batas_toast_timer: float = 0.0
var _batas_toast_count: int = 0
var _tembok_x: float = 14.0
var _tembok_z_min: float = -60.0
var _tembok_z_max: float = 16.0
var _batas_z_selatan: float = 16.0
var _gerbang_pos: Vector3 = Vector3(14, 0, 0)
var _gerbang_lebar: float = 4.0
var _spawn_putri: Vector3 = Vector3(130, 0, 14)
var _pos_satpam: Vector3 = Vector3(17, 0, 5)
var _pos_legal_terakhir: Vector3 = Vector3(-4, 0, 14)
var _punya_pos_legal: bool = false
# MULTIPLAYER FASE 1 (Wira, 18 Nov 2026 — integrasi main.gd, langkah 9
# MULTIPLAYER-FASE1-PREP.md §1.6). Node `Players` + `MultiplayerSpawner`
# dibuat di _mp_pasang_players() (akhir _ready). Alur: login/daftar/
# lanjut -> _masuk_pesantren() -> _mp_mulai() -> NetworkManager
# connect + submit_ticket -> server spawn avatar di `Players` ->
# kamera mengikuti avatar itu (diadopsi jadi _player).
# KONTRAK dengan Saka (NetworkManager — BUKAN file ini):
# - spawn_function spawner = NetworkManager.spawn_player (Saka).
#   File ini TIDAK menulis spawn_function sendiri.
# - NetworkManager yang connect + submit_ticket (tiket diambil dari
#   MpBootstrap.consume_ticket(); tiket disediakan file ini lewat
#   _mp_minta_tiket() -> MpBootstrap.set_ticket()).
# - NetworkManager memanggil _mp_terapkan_zone_reject(pos_legal) saat
#   server menolak posisi (zone_reject).
# - Titik spawn MP: mp_titik_spawn(putri) — putra
#   PesantrenBuilder.SPAWN (-4,14), putri KampusPutri.SPAWN_PUTRI
#   (140,0,16) — dari kode dunia, bukan karangan.
# OFFLINE DIPERTAHANKAN PENUH: tanpa NetworkManager / tanpa server,
# game jalan persis seperti sekarang (spawn lokal SantriPlayer.new(),
# semua sistem lama normal). Semua pemakaian NetworkManager dijaga
# has_method + null-check supaya game TIDAK PERNAH crash hanya karena
# server realtime mati.
# KOREKSI BRIEF (terukur probe headless Godot 4.7.2, 18 Nov 2026):
# spawn_path TIDAK BISA ^"Players" bila spawner anak Main — engine
# mencari spawn node RELATIF terhadap spawner ("Cannot find spawn
# node"), dan ^"../Players" TERBUKTI spawn ke Players. Dipakai itu.
const MP_WSS_URL := "wss://43-173-39-166.sslip.io/ws/"
const MP_WS_LOKAL_URL := "ws://127.0.0.1:8791"
var _players: Node = null
var _spawner: MultiplayerSpawner = null
var _mp_status: String = "offline" # "offline" | "menghubungkan" | "online"
var _mp_avatar_sendiri: SantriPlayer = null
var _mp_pemain_lokal: SantriPlayer = null # avatar offline, disembunyikan saat avatar MP diadopsi
var _mp_ticket_http: HTTPRequest = null
var _mp_login_diam_http: HTTPRequest = null # login diam-diam (Dimas, 18 Nov 2026)
var _mp_log_timer: float = 0.0
var _mp_zone_reject_diterima: bool = false
var _mp_zone_reject_pos: Vector3 = Vector3.ZERO
# HANYA tes headless (--mp-test-zona): validasi zona klien dimatikan
# supaya penolakan HARUS datang dari server (zone_reject). Default
# false — di game normal validasi klien tetap jalan.
var _mp_validasi_klien_mati: bool = false
# INTERIOR PUTRI (Lestari, 18 Nov 2026 — wiring Asrama/Kelas/Kantor/
# Madrasah/Studio/Pos Jaga; bug HP Mas 07:08 WIB: bangunan putri
# masih kosong di game karena interior sudah jadi sebagai file tapi
# wiring belum pernah dipasang). Pola = Surau/Cangkruk/Musholla: map
# interior terpisah di z=-300 + teleport lewat pintu.
# Pintu LUAR (kanonik, kampus_putri.gd BARU — Mira): Musholla
# (134,-19)/(134,-17.5); Kelas (130,14)/(130,15.5); Asrama
# (146,9)/(144.5,9); Kantor (144,-33)/(142.5,-33); Madrasah
# (147,-12)/(145.5,-12); Studio (166,-16)/(166,-17.5); Pos Jaga
# (174.5,-20)/(173,-20). Titik interaksi = posisi pintu luar ini.
var _kelas_putri_door: Vector3 = Vector3(130, 0, 14)
var _kelas_putri_exit: Vector3 = Vector3(130, 0, 15.5)
var _asrama_putri_door_luar: Vector3 = Vector3(146, 0, 9)
var _asrama_putri_exit: Vector3 = Vector3(144.5, 0, 9)
var _kantor_door_luar: Vector3 = Vector3(144, 0, -33)
var _kantor_exit: Vector3 = Vector3(142.5, 0, -33)
var _madrasah_door_luar: Vector3 = Vector3(147, 0, -12)
var _madrasah_exit: Vector3 = Vector3(145.5, 0, -12)
var _studio_door_luar: Vector3 = Vector3(166, 0, -16)
var _studio_exit: Vector3 = Vector3(166, 0, -17.5)
var _pos_jaga_door_luar: Vector3 = Vector3(174.5, 0, -20)
var _pos_jaga_exit: Vector3 = Vector3(173, 0, -20)
# Pusat cangkang luar (dict build, dipakai peta: titik pemain di
# dalam interior digambar di cangkangnya — pola Surau/Musholla).
# _kelas_putri_pos dulu dipakai penjaga cangkang kosong (RONDE
# PERBAIKAN Eka) — penjaga itu DIHAPUS: Kelas kini punya interior
# ter-wiring, pemain yang jalan ke pintu masuk lewat teleport,
# bukan didorong balik (lihat _cek_batas).
var _kelas_putri_pos: Vector3 = Vector3(130, 0, 10)
var _asrama_putri_pos: Vector3 = Vector3(152, 0, 9)
var _kantor_pos: Vector3 = Vector3(148, 0, -33)
var _madrasah_pos: Vector3 = Vector3(152, 0, -12)
var _studio_pos: Vector3 = Vector3(166, 0, -12)
var _pos_jaga_pos: Vector3 = Vector3(176, 0, -20)
# Interior putri (pintu/spawn dalam dibaca dari dict build di _ready).
var _di_dalam_kelas_putri: bool = false
var _kelas_putri_root: Node3D
var _kelas_putri_interior_door: Vector3 = Vector3(120, 0, -297)
var _kelas_putri_interior_spawn: Vector3 = Vector3(118.6, 0, -298.5)
var _di_dalam_asrama_putri: bool = false
var _asrama_putri_root: Node3D
# PERBESARAN NADIA (18 Nov 2026, tapak 18x12): pintu utama
# (-249,-300) + spawn (-247,5,-300) di dinding BARAT — nilai
# runtime tetap dibaca dari InteriorAsramaPutri.build() di _ready
# (baris 385-391), default di sini hanya penjaga sebelum _ready.
var _asrama_putri_interior_door: Vector3 = Vector3(-249, 0, -300)
var _asrama_putri_interior_spawn: Vector3 = Vector3(-247.5, 0, -300)
# ASRAMA PUTRA (Lestari, 18 Nov 2026 — ACC Mas 09:37 WIB; Nadia:
# geometri reuse modul Putri). Pintu LUAR (konsep KONSEP-ASRAMA-
# PUTRA.md: lokasi (-24,10), tapak 18x12, pintu dinding barat):
# dinding barat x=-33 -> pintu (-33,10), keluar (-34,5,10) =
# 1,5 m di barat pintu (pola Putri), pusat cangkang (-24,10).
# Diverifikasi 18 Nov ~10:0x WIB: SAMA PERSIS dengan
# AsramaPutra.ASRAMA_DOOR/ASRAMA_EXIT/ASRAMA_PUTRA_POS (Nadia).
var _asrama_putra_door_luar: Vector3 = Vector3(-33, 0, 10)
var _asrama_putra_exit: Vector3 = Vector3(-34.5, 0, 10)
var _asrama_putra_pos: Vector3 = Vector3(-24, 0, 10)
var _di_dalam_asrama_putra: bool = false
var _asrama_putra_root: Node3D
# Pintu/spawn DALAM dibaca dari dict build InteriorAsramaPutra
# di _ready (OFFSET (-300,0,-300) Nadia — slot -300, tetangga
# terdekat Asrama Putri -240). Default di sini = nilai runtime
# yang sama (penjaga sebelum _ready, pola Putri).
var _asrama_putra_interior_door: Vector3 = Vector3(-309, 0, -300)
var _asrama_putra_interior_spawn: Vector3 = Vector3(-307.5, 0, -300)
# TIDUR ASRAMA PUTRA: 96 posisi tidur (dunia) + 48 body kasur
# susun — kontrak SAMA seperti Asrama Putri (1 body per unit,
# body untuk idx = _asrama_putra_kasur_bodies[(idx-1)/2]).
# State tidur (_kasur_tidur_body/_kasur_tidur_idx/...) DIPAKAI
# BERSAMA dengan Putri: pemain hanya bisa tidur di satu kasur.
var _asrama_putra_beds: Array = []
var _asrama_putra_kasur_bodies: Array = []
# TIDUR ASRAMA (Rani): 96 posisi tidur (dunia) + 48 body kasur susun
# (SATU body per UNIT — 2 idx per body: bawah ganjil + atas genap;
# body untuk idx = _asrama_putri_kasur_bodies[(idx-1)/2] — BUKAN 96
# body, lihat test_interior_asrama_putri "48 unit kasur susun").
var _asrama_putri_beds: Array = []
var _asrama_putri_kasur_bodies: Array = []
# Body kasur yang sedang dimatikan selama pemiliknya tidur di
# Asrama (diaktifkan lagi saat bangun — lihat _on_aksi). "Dimatikan"
# = collision_layer/mask 0 (KOREKSI 18 Nov: StaticBody3D TIDAK
# punya properti "disabled" di Godot 4.7 — terukur headless;
# set_deferred("disabled") Rani di header interior_asrama_putri.gd
# tidak jalan). Layer/mask asal disimpan untuk pemulihan.
var _kasur_tidur_body: StaticBody3D = null
var _kasur_tidur_idx: int = 0
var _kasur_tidur_layer: int = 1
var _kasur_tidur_mask: int = 1
# Kapsul dikecilkan selama tidur di kasur ATAS Asrama (lihat _on_aksi).
var _kasur_tidur_kapsul_dikecilkan: bool = false
var _di_dalam_kantor: bool = false
var _kantor_root: Node3D
var _kantor_interior_door: Vector3 = Vector3(-124, 0, -300)
var _kantor_interior_spawn: Vector3 = Vector3(-122.5, 0, -300)
var _di_dalam_madrasah: bool = false
var _madrasah_root: Node3D
var _madrasah_interior_door: Vector3 = Vector3(-185, 0, -300)
var _madrasah_interior_spawn: Vector3 = Vector3(-183.5, 0, -300)
var _di_dalam_studio: bool = false
var _studio_root: Node3D
var _studio_interior_door: Vector3 = Vector3(240, 0, -304)
var _studio_interior_spawn: Vector3 = Vector3(240, 0, -302.5)
var _di_dalam_pos_jaga: bool = false
var _pos_jaga_root: Node3D
var _pos_jaga_interior_door: Vector3 = Vector3(178.5, 0, -300)
var _pos_jaga_interior_spawn: Vector3 = Vector3(179.6, 0, -299.6)


## PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): atur ulang bayangan mesh
## LUAR (Palette default OFF). Aturan per mesh:
## - LangitDinamis: dilewati total (matahari/bulan/awan tak berbayang).
## - GLB pohon (GLB_Pohon*) + gedung GLB (Surau, GLB_Gubuk*): biarkan
##   ON (default impor) — pohon + Surau + gubuk memang harus berbayang.
## - GLB pagar/taman/sawah: matikan total (bilah + petak kecil).
## - Mesh rakitan lain: ON hanya bila bentang horizontal >= 4 m DAN
##   tinggi >= 1 m (dinding/atap/tembok/gerbang/gunung); OFF bila sisi
##   terpanjang < 0,5 m (dekor mungil). Sisanya dibiarkan (mesh rakitan
##   sedang sudah OFF via Palette; atap kerucut mentah tetap ON).
## REVISI ambang (pengukuran caster 19 Nov): ambang lama >= 2 m
## menyalakan 843 mesh (pagar, jalan, tiang lampu ikut) — caster total
## 1.706, jauh di atas target < 500.
static func _nyalakan_bayangan_gedung(root: Node) -> void:
	var tumpuk: Array = [[root, ""]]
	while not tumpuk.is_empty():
		var item: Array = tumpuk.pop_back()
		var n: Node = item[0]
		var jenis: String = String(item[1])
		if n.name == "LangitDinamis":
			continue
		if String(n.name).begins_with("GLB_Pohon"):
			jenis = "pohon"
		elif n.name == "Surau" or String(n.name).begins_with("GLB_Gubuk"):
			jenis = "gedung"
		elif n.name == "Sawah" or n.name == "GLB_Taman" or String(n.name).begins_with("GLB_Pagar"):
			jenis = "mati"
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if jenis == "mati":
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			elif jenis == "pohon" or jenis == "gedung":
				# Pohon + Surau + gubuk tetap berbayang, KECUALI bagian
				# kecil (< 1 m: ranting, trim, ornamen) — bayangannya
				# tak terlihat dari jarak main. REVISI ambang (ukur
				# caster 19 Nov): biarkan-semua-ON menyisakan ~690
				# ArrayMesh GLB; potongan ini yang terbesar kedua.
				var s2: Vector3 = mi.get_aabb().size * mi.scale
				if maxf(maxf(s2.x, s2.y), s2.z) < 1.0:
					mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			else:
				var s: Vector3 = mi.get_aabb().size * mi.scale
				if maxf(s.x, s.z) >= 4.0 and s.y >= 1.0:
					mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
				elif maxf(maxf(s.x, s.y), s.z) < 0.5:
					mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for ch in n.get_children():
			tumpuk.append([ch, jenis])


## PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): semua mesh interior
## (root "Interior*" di z=-300) tanpa bayangan — ruangan tertutup,
## matahari tidak masuk; lampu omni interior memang tanpa bayangan.
## Dipanggil di akhir _ready, setelah semua interior dibangun.
static func _matikan_bayangan_interior(induk: Node) -> void:
	for ch in induk.get_children():
		if not String(ch.name).begins_with("Interior"):
			continue
		var tumpuk: Array[Node] = [ch]
		while not tumpuk.is_empty():
			var n: Node = tumpuk.pop_back()
			if n is MeshInstance3D:
				(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for c in n.get_children():
				tumpuk.append(c)


func _ready() -> void:
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): kunci 60 fps DULU di
	# sini (layar 120 Hz tanpa cap = 2x kerja GPU) — kini dipindah
	# ke KualitasAdaptif (setup di bawah, setelah kamera dibuat):
	# max_fps per tingkat (Ringan 30 / Sedang 60 / Tinggi tanpa cap).
	# Lihat juga scaling_3d 0,75 di project.godot (INERT di
	# Compatibility — penahan fill-rate yang jalan hanya max_fps).
	_save = SantriSave.load_data()
	# GELOMBANG 2 FASE A: gelar awal dari save (A5) — disimpan di
	# _gelar_saat_ini untuk label/Kartu Santri NANTI; JANGAN
	# tampilkan dulu (UI menunggu HUD/A9). Dihitung ulang tiap misi
	# selesai di _on_quiz_answered().
	_gelar_saat_ini = Gelar.nama_gelar(_save)
	_muat_kasur_saya()
	# Bangun pesantren 3D (surau kecil + plot pertumbuhan).
	_pesantren = PesantrenBuilder.build()
	add_child(_pesantren["root"])
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): Palette default
	# cast_shadow OFF — nyalakan lagi hanya untuk mesh LUAR yang
	# besar (>= 2 m: dinding/atap/tembok/tiang lampu). Interior
	# (root terpisah, z=-300) dan dekor kecil tetap tanpa bayangan.
	_nyalakan_bayangan_gedung(_pesantren["root"])
	_markers = _pesantren["markers"]
	_chest_lid = _pesantren["chest_lid"]
	# RONDE 4: posisi pintu luar (dari builder) + interior baru (Dewa).
	_outdoor_door = _pesantren["outdoor_door"]
	_outdoor_exit = _pesantren["outdoor_exit"]
	# REVISI (Mas 17 Nov 22:51 WIB): frame pintu LUAR kini LURUS
	# (Surau 0°, pintu (0,-6)); frame pintu DALAM tetap miring
	# (interior -25°, mihrab kiblat 295°) — dipisah supaya koridor
	# keluar dari dalam Surau tetap memakai frame miring.
	var frame := PesantrenBuilder.surau_pintu()
	_surau_pintu = frame["pintu"]
	_surau_sumbu = frame["sumbu"]
	_surau_masuk = frame["masuk"]
	_surau_keluar = frame["keluar"]
	var frame_dalam := InteriorSurau.frame_pintu_dalam()
	_surau_sumbu_dalam = frame_dalam["sumbu"]
	_surau_keluar_dalam = frame_dalam["keluar"]
	# Interior Surau BARU (Dewa, ronde 4): InteriorSurau.build()
	# menggantikan _interior_surau lama di PesantrenBuilder (dihapus
	# supaya tidak ada dua interior menumpuk di z=-300). Ruangan 18x14
	# m (bukan 14x12); dinding selatan + pintu + spawn TIDAK berubah.
	# Smartboard spot Dewa (-6.8,0,-301), bukan (-4.6,0,-300) — jarak
	# ke penanda M2 ±2,4 m, masih dalam radius interaksi 3,5 m.
	var interior := InteriorSurau.build()
	add_child(interior["root"])
	_interior_root = interior["root"]
	_interior_door = interior["interior_door"]
	_interior_spawn = interior["interior_spawn"]
	_smartboard_spot = interior["smartboard_spot"]
	_smartboard_screen = interior["smartboard_screen"]
	# BACA BUKU (Tara): titik rak Surau dari dict build.
	for s in interior.get("rak_spots", []):
		_rak_spots.append(s)
	# RONDE 6 — interior Surau DISEMBUNYIKAN saat pemain di luar
	# (perbaikan DOUBLE SURAU: ruangan 18x14 m di z=-300 sebelumnya
	# terlihat dari spawn sebagai bangunan kedua).
	_interior_root.visible = false
	# RONDE 6 — kamar cangkruk (map interior kedua, ala GTA).
	var cangkruk := InteriorCangkruk.build()
	add_child(cangkruk["root"])
	_cangkruk_root = cangkruk["root"]
	_cangkruk_interior_door = cangkruk["interior_door"]
	_cangkruk_interior_spawn = cangkruk["interior_spawn"]
	_cangkruk_beds = cangkruk["bed_pos_list"]
	_cangkruk_lemari = cangkruk["lemari_spot"]
	_cangkruk_root.visible = false
	# Posisi pintu luar cangkruk (dari builder) + sandal yang
	# ditinggalkan di depan kedua pintu (RONDE 6).
	_cangkruk_door = _pesantren["cangkruk_door"]
	_cangkruk_exit = _pesantren["cangkruk_exit"]
	_sandal_luar_surau = _pesantren["root"].find_child("SandalLuarSurau", true, false)
	_sandal_luar_cangkruk = _pesantren["root"].find_child("SandalLuarCangkruk", true, false)
	# RONDE 20 — interior Musholla Ar-Raudhah (map interior KETIGA,
	# ala GTA): ruangan 14x10 m di (60,0,-301). DISEMBUNYIKAN saat
	# pemain di luar (pola double-surau ronde 6). Pemain putra TIDAK
	# PERNAH masuk — yang memakai: Ustadzah Mariyah (patroli + imam
	# putri). Titik keluar luar (musholla_exit) dari builder.
	var musholla := InteriorMusholla.build()
	add_child(musholla["root"])
	_musholla_root = musholla["root"]
	_musholla_door = musholla["interior_door"]
	_musholla_spawn = musholla["interior_spawn"]
	_musholla_root.visible = false
	# BACA BUKU (Tara): titik rak Musholla dari dict build — "rak_spots"
	# (jamak: 2 rak Dewi, Timur + Utara) bila ada, kalau tidak
	# "rak_spot" (tunggal, kompatibel).
	if musholla.has("rak_spots"):
		for s in musholla["rak_spots"]:
			_rak_spots.append(s)
	elif musholla.has("rak_spot"):
		_rak_spots.append(musholla["rak_spot"])
	_musholla_exit = _pesantren["musholla_exit"]
	# INTERIOR PUTRI (Lestari, 18 Nov 2026): Asrama + Kelas + 4 gedung
	# — pola Musholla di atas (build -> add_child -> simpan pintu/
	# spawn -> visible=false). Musholla SUDAH ter-wiring — JANGAN
	# duplikat (verifikasi: rak_spots Musholla 2 sudah masuk
	# _rak_spots di atas).
	var kelas_putri := InteriorKelasPutri.build()
	add_child(kelas_putri["root"])
	_kelas_putri_root = kelas_putri["root"]
	_kelas_putri_interior_door = kelas_putri["interior_door"]
	_kelas_putri_interior_spawn = kelas_putri["interior_spawn"]
	_kelas_putri_root.visible = false
	# BACA BUKU: 2 rak Kelas (RAK_POS_LIST) masuk daftar titik rak
	# reader — supaya buku bisa dibaca di Kelas juga (pola Surau/
	# Musholla di atas).
	for s in kelas_putri.get("rak_spots", []):
		_rak_spots.append(s)
	var asrama_putri := InteriorAsramaPutri.build()
	add_child(asrama_putri["root"])
	_asrama_putri_root = asrama_putri["root"]
	_asrama_putri_interior_door = asrama_putri["interior_door"]
	_asrama_putri_interior_spawn = asrama_putri["interior_spawn"]
	_asrama_putri_beds = asrama_putri["posisi_tidur_list"]
	_asrama_putri_kasur_bodies = asrama_putri["kasur_bodies"]
	_asrama_putri_root.visible = false
	# ASRAMA PUTRA (Lestari, 18 Nov 2026): pola Asrama Putri di
	# atas — build -> add_child -> simpan pintu/spawn/beds/bodies
	# -> visible=false. Konstanta (OFFSET (-300,0,-300), pintu
	# dalam (-309,-300), BED_Z 4,7) dari InteriorAsramaPutra (Nadia).
	var asrama_putra := InteriorAsramaPutra.build()
	add_child(asrama_putra["root"])
	_asrama_putra_root = asrama_putra["root"]
	_asrama_putra_interior_door = asrama_putra["interior_door"]
	_asrama_putra_interior_spawn = asrama_putra["interior_spawn"]
	_asrama_putra_beds = asrama_putra["posisi_tidur_list"]
	_asrama_putra_kasur_bodies = asrama_putra["kasur_bodies"]
	_asrama_putra_root.visible = false
	var kantor := InteriorGedungPutri.build_kantor()
	add_child(kantor["root"])
	_kantor_root = kantor["root"]
	_kantor_interior_door = kantor["interior_door"]
	_kantor_interior_spawn = kantor["interior_spawn"]
	_kantor_root.visible = false
	var madrasah := InteriorGedungPutri.build_madrasah()
	add_child(madrasah["root"])
	_madrasah_root = madrasah["root"]
	_madrasah_interior_door = madrasah["interior_door"]
	_madrasah_interior_spawn = madrasah["interior_spawn"]
	_madrasah_root.visible = false
	var studio := InteriorGedungPutri.build_studio()
	add_child(studio["root"])
	_studio_root = studio["root"]
	_studio_interior_door = studio["interior_door"]
	_studio_interior_spawn = studio["interior_spawn"]
	_studio_root.visible = false
	var pos_jaga := InteriorGedungPutri.build_pos_jaga()
	add_child(pos_jaga["root"])
	_pos_jaga_root = pos_jaga["root"]
	_pos_jaga_interior_door = pos_jaga["interior_door"]
	_pos_jaga_interior_spawn = pos_jaga["interior_spawn"]
	_pos_jaga_root.visible = false
	# LIGHTING v2 (Cahya, 17 Nov 2026): modul pencahayaan — 11 lampu
	# baru + perbaikan 2 lampu interior Musholla (satu baris, §7
	# LIGHTING-PLAN.md). Dipasang di sini (setelah interior Musholla
	# dibangun) supaya _perbaiki_musholla menemukan LampuOmni_1/2;
	# _ready jalan sekali, jadi tidak ada pemasangan ganda. Posisi
	# pintu Surau dibaca runtime dari _outdoor_door (sudah benar
	# untuk Surau lurus -90°, pintu (0,-3,8) menghadap selatan).
	var cahaya := PencahayaanV2.pasang(self, _outdoor_door)
	# RONDE 21 — tembok pemisah + gerbang + spawn putri + pos satpam
	# (kontrak dict build Raka): dibaca pakai .get() dengan nilai
	# kontrak sebagai default — supaya _ready TIDAK crash kalau game
	# dijalankan sebelum merge Raka (kunci-kunci ini baru ada di
	# build() setelah merge); begitu kuncinya ada, nilai dict yang
	# dipakai. "pos_satpam" sudah ada di dict sejak Ronde 20.
	_tembok_x = float(_pesantren.get("tembok_x", 14.0))
	_tembok_z_min = float(_pesantren.get("tembok_z_min", -60.0))
	_tembok_z_max = float(_pesantren.get("tembok_z_max", 16.0))
	_batas_z_selatan = float(_pesantren.get("batas_z_selatan", 16.0))
	_gerbang_pos = _pesantren.get("gerbang_pos", Vector3(14, 0, 0))
	_gerbang_lebar = float(_pesantren.get("gerbang_lebar", 4.0))
	_spawn_putri = _pesantren.get("spawn_putri", Vector3(130, 0, 14))
	_pos_satpam = _pesantren.get("pos_satpam", Vector3(17, 0, 5))
	# INTERIOR PUTRI (Lestari): pusat cangkang luar untuk peta (titik
	# pemain di dalam interior digambar di cangkangnya — lihat
	# _data_peta). Dibaca dari dict build kampus_putri.gd.
	_kelas_putri_pos = _pesantren.get("kelas_putri_pos", Vector3(130, 0, 10))
	_asrama_putri_pos = _pesantren.get("asrama_putri_pos", Vector3(152, 0, 9))
	# ASRAMA PUTRA (Lestari): pusat cangkang luar untuk peta.
	# Kunci "asrama_putra_pos" disediakan PesantrenBuilder.build()
	# (AsramaPutra.build Nadia, (-24,10)) — default sama.
	_asrama_putra_pos = _pesantren.get("asrama_putra_pos", Vector3(-24, 0, 10))
	_kantor_pos = _pesantren.get("kantor_ustadzah_pos", Vector3(148, 0, -33))
	_madrasah_pos = _pesantren.get("madrasah_pos", Vector3(152, 0, -12))
	_studio_pos = _pesantren.get("studio_pos", Vector3(166, 0, -12))
	_pos_jaga_pos = _pesantren.get("pos_jaga_tl", Vector3(176, 0, -20))
	_sandal_luar_musholla = _pesantren["root"].find_child("SandalLuarMusholla", true, false)
	# Pemain.
	# Perbaikan 15 Nov ~12:00 WIB: kapsul dulu tinggi 1.2 dengan pusat
	# y=0.95 — alas kapsul 0,35 DI ATAS origin, jadi origin pemain
	# tenggelam 0,35 ke dalam tanah (kaki masuk tanah) dan bibir lantai
	# surau 0,15 m tidak bisa dilangkahi. Sekarang kapsul tinggi 1,7
	# berpusat y=0,85: alas tepat di origin (kaki menapak tanah).
	_player = SantriPlayer.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	_player_capsule = capsule
	shape.shape = capsule
	shape.position = Vector3(0, 0.85, 0)
	_player.add_child(shape)
	_player.floor_snap_length = 0.3
	_player.position = PesantrenBuilder.SPAWN
	# RONDE 21: posisi legal awal = titik spawn sesuai gender pemain
	# (putra -> SPAWN (-4,14); santriwati -> _spawn_putri (130,14)).
	_pos_legal_terakhir = _spawn_putri if _pemain_adalah_putri() else PesantrenBuilder.SPAWN
	_punya_pos_legal = true
	add_child(_player)
	_player.set_facing(PI) # menghadap surau (utara). Harus sesudah add_child (visual dibuat di _ready).
	# Kamera third-person (rig mengikuti pemain, orbit dengan drag).
	_rig = Node3D.new()
	_rig.name = "CameraRig"
	add_child(_rig)
	_spring = SpringArm3D.new()
	_spring.spring_length = 7.0
	_spring.margin = 0.5
	_spring.rotation = Vector3(_cam_pitch, 0, 0)
	_rig.add_child(_spring)
	var cam := Camera3D.new()
	cam.current = true
	cam.fov = 60.0
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): far 4000 -> 450.
	# REVISI nilai (foto A/B 19 Nov): far=300 MEMOTONG puncak gunung
	# (Gunung_0 331 m dari kamera, puncak ~337 m — foto far300 puncak
	# DATAR vs far4000 runcing) + bulan (384 m). Premis lama "gunung
	# ±210 m" SALAH — gunung di 350/360 m dari pusat. 450 mencakup
	# tepi jauh gunung (~408 m) + matahari+halo (~407 m) + bintang
	# (360 m) dari spawn; interior z=-300 tetap tak ter-render karena
	# visible=false saat pemain di luar (bukan karena far).
	cam.far = 450.0
	_spring.add_child(cam)
	_cam = cam
	# KUALITAS ADAPTIF (Rangga, 19 Nov 2026 — perintah Mas 13:11 WIB):
	# kualitas game tergantung perangkat user. Manager ini yang
	# memiliki Engine.max_fps, far, bayangan matahari, pengali lampu
	# omni, cull Label3D, dan MSAA — menerapkan tingkat awal dari
	# save/deteksi perangkat di sini (probe FPS dimulai di
	# _masuk_pesantren, bukan di layar login).
	_kualitas = KualitasAdaptif.new()
	add_child(_kualitas)
	_kualitas.setup(self, cam, _save)
	_kamera = KameraPesantren.new()
	# NPC santri.
	_spawn_npcs()
	# UI.
	_ui = PesantrenUI.new()
	add_child(_ui)
	_ui.login_submitted.connect(_on_login)
	_ui.register_submitted.connect(_on_register)
	_ui.continue_pressed.connect(_on_continue)
	# MULTIPLAYER FASE 1 (Dimas, 18 Nov 2026): tombol "Main Bersama"
	# di HUD — jalan masuk multiplayer yang terlihat.
	_ui.mp_gabung_ditekan.connect(_on_mp_gabung_ditekan)
	_ui.interact_pressed.connect(_on_interact)
	# MODE KAMERA v3 (Cakra, 18 Nov 13:13): tombol "Kamera: ..." di HUD.
	_ui.kamera_mode_pressed.connect(_ganti_mode_kamera)
	# ROMBAKAN HUD v3 (Tara, 18 Nov 2026): pop-up "PETUNJUK TOMBOL"
	# ditutup -> simpan flag di _save (lihat _on_petunjuk_ditutup).
	_ui.petunjuk_ditutup.connect(_on_petunjuk_ditutup)
	_ui.chat_sent.connect(_on_chat_sent)
	_ui.quiz_answered.connect(_on_quiz_answered)
	_ui.mission_closed.connect(_on_mission_closed)
	_ui.mahadiyah_toggled.connect(_on_mahadiyah_toggled)
	_ui.khataman_joined.connect(_on_khataman_joined)
	_ui.open_dashboard_requested.connect(_on_open_dashboard)
	_ui.open_peta_requested.connect(_on_open_peta)
	_ui.slide_changed.connect(_on_slide_changed)
	_ui.reset_requested.connect(_respawn_ke_spawn)
	# FASE A GELOMBANG 3 (Raka, 18 Nov 2026 — UI misi, mockup DI-ACC
	# Mas 18:58): manajer 4 panel UI misi (dialog / ruang belajar /
	# tes kenaikan / panel misi). File terpisah (scripts/ui_misi/) —
	# JANGAN sentuh ui.gd (wilayah Tara, HUD B rev1).
	_manajer_misi = ManajerUIMisi.new()
	add_child(_manajer_misi)
	_manajer_misi.dialog_selesai.connect(_on_manajer_dialog_selesai)
	_manajer_misi.tanya_dipilih.connect(_on_manajer_tanya_dipilih)
	_manajer_misi.ruang_belajar_langkah.connect(_on_manajer_rb_langkah)
	_manajer_misi.ruang_belajar_selesai.connect(_on_manajer_rb_selesai)
	_manajer_misi.tes_selesai.connect(_on_manajer_tes_selesai)
	# RONDE 6: aksi karakter + ganti outfit (kamar cangkruk).
	_ui.aksi_dipilih.connect(_on_aksi)
	_ui.outfit_dipilih.connect(_on_outfit_dipilih)
	# RONDE 13: tombol "Ikut Sholat" di banner sholat berjamaah.
	_ui.ikut_sholat_pressed.connect(_on_ikut_sholat)
	# BUBBLE-ML: pesan NPC (say() -> sinyal pesan) tampil di feed ML.
	# HARUS di sini (setelah _ui dibuat) — _spawn_npcs() di atas jalan
	# SEBELUM _ui ada, jadi connect di sana error Nil dan menghentikan
	# pembuatan npc2-npc5 (ditemukan tes reroute Raka, 17 Nov 2026).
	for npc in _npcs:
		npc.pesan.connect(_ui.tampilkan_pesan_melayang)
	# RONDE 7: tombol "Ganti Baju" di Kartu Santri — buka panel outfit
	# dari mana saja (dashboard ditutup dulu supaya panel tidak menumpuk).
	_ui.ganti_baju_requested.connect(_on_ganti_baju_requested)
	_ui.show_login(_save)
	# RONDE 17: audio suasana — dibuat setelah UI (tombol Suara ada di
	# HUD). mulai() TIDAK dipanggil di sini — baru pada gestur pertama
	# (autoplay web, lihat _input). Status mute dibaca dari save.
	_audio = AudioPesantren.new()
	add_child(_audio)
	_audio.set_mute(bool(_save.get("suara_mati", false)))
	_ui.set_suara_mati(bool(_save.get("suara_mati", false)))
	_ui.suara_toggled.connect(_on_suara_toggled)
	# KUALITAS ADAPTIF: pilihan kualitas dari panel Pengaturan.
	_ui.kualitas_dipilih.connect(_on_kualitas_dipilih)
	_ui.set_kualitas_mode(_kualitas.mode_saat_ini())
	# SFX LANGKAH (Sinta, 17 Nov 2026 — acuan reel @jipraks): tiap
	# kaki pemain menyentuh tanah (signal SantriPlayer.langkah) ->
	# AudioPesantren.mainkan_langkah(); permukaan dipilih di
	# _saat_langkah() (di dalam ruangan = lantai, di luar = tanah).
	_player.langkah.connect(_saat_langkah)
	_refresh_markers()
	_update_hud()
	# PERBAIKAN PERFORMA 19 Nov 2026 (Rangga): matikan bayangan semua
	# interior (lihat _matikan_bayangan_interior).
	_matikan_bayangan_interior(self)
	# MULTIPLAYER FASE 1 (Wira): pasang node Players + spawner.
	_mp_pasang_players()


func _input(event: InputEvent) -> void:
	# RONDE 17: autoplay web — audio baru boleh bunyi setelah gestur
	# pertama (klik/sentuh/tombol). _input dipanggil SEBELUM kontrol
	# GUI menelan event, jadi klik apa pun (termasuk tombol login)
	# membuka audio.
	if _audio_unlocked:
		return
	if event is InputEventMouseButton or event is InputEventKey or event is InputEventScreenTouch:
		_audio_unlocked = true
		_audio.mulai()


func _spawn_npcs() -> void:
	# RONDE 21: waypoint Bilal/Faris DIFILTER ke area putra + kawasan
	# bersama — titik di area putri DIBUANG. Aturan: x < -0,5 (barat
	# tembok) ATAU z > 16,5 (selatan ujung tembok, kawasan bersama).
	# Tembok pemisah kini di x=14 (dulu pagar x=0, lalu x=2,5) —
	# filter lama tetap benar untuk TITIK waypoint: tidak ada titik
	# yang lolos dengan x >= -0,5 dan z <= 16,5, jadi tidak ada
	# waypoint di timur tembok dengan z < 16. CATATAN (laporan
	# Ronde 21 ke Raka): NPC jalan GARIS LURUS tanpa collision
	# (npc.gd, Node3D biasa) dan target waypoint DIPILIH ACAK —
	# segmen lurus antara dua waypoint yang lolos (mis. (60,30) <->
	# (-60,-40)) MASIH bisa memotong garis x=14 di z < 16 secara
	# visual. Itu perilaku lama sejak pagar Ronde 20, bukan
	# waypoint yang menyeberang — perlu keputusan Raka (batasi
	# waypoint ke sisi barat saja, atau terima dulu).
	var wps: Array[Vector3] = []
	for wp in PesantrenBuilder.NPC_WAYPOINTS:
		if wp.x < -0.5 or wp.z > 16.5:
			wps.append(wp)
	# RONDE 11 (Mas: karakter harus beda-beda): Bilal vs Faris vs
	# pemain beda sekilas pandang. Bilal = kulit GELAP + kacamata +
	# songkok HITAM pekat + sarung biru; Faris = kulit TERANG + tanpa
	# kacamata + songkok putih + sarung coklat; pemain (default) =
	# kulit SAWO MATANG + tanpa kacamata + songkok putih + sarung
	# zamrud. Ketiganya beda kulit; Bilal beda juga kacamata+songkok.
	var outfit_bilal := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_bilal["sarung"] = "#1d4e6b"
	outfit_bilal["kulit"] = "#8a5a33"
	outfit_bilal["kacamata"] = true
	outfit_bilal["songkok"] = "#1a1a1a"
	var npc1 := SantriNPC.new()
	# RONDE 20: Bilal PINDAH (4,4) -> (-4,4) sisi PUTRA — spawn lama
	# jatuh di AREA PUTRI setelah pagar dibangun.
	npc1.setup("Bilal", Vector3(-4, 0, 4), wps, outfit_bilal)
	add_child(npc1)
	_npcs.append(npc1)
	_bilal = npc1
	npc1.rute_selesai.connect(_on_npc_rute_selesai)

	var outfit_faris := MissionData.OUTFIT_DEFAULT.duplicate()
	outfit_faris["sarung"] = "#6b3a1d"
	outfit_faris["kulit"] = "#e8b98a"
	outfit_faris["kacamata"] = false
	outfit_faris["songkok"] = "#faf7f0"
	var npc2 := SantriNPC.new()
	npc2.setup("Faris", Vector3(-5, 0, 8), wps, outfit_faris)
	add_child(npc2)
	_npcs.append(npc2)
	_faris = npc2
	npc2.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 15 (Mas: karakter pemimpin pesantren): Ust. Aqsal Murad —
	# Pengasuh. Serban putih krem + jenggot gelap beruban di ujung +
	# kumis tipis; koko KREM + sarung HITAM (lihat
	# MissionData.OUTFIT_KYAI).
	# RONDE 20 (Mas 15:56 WIB: "duduk bersila sambil baca kitab
	# khusyu'.. sesekali keliling pondok untuk ngontrol"): Kyai TIDAK
	# LAGI diam di serambi — default DUDUK di dalam Surau membaca
	# kitab (kursi (5.6,-305) lokal, hadap kiblat), sesekali PATROLI
	# area putra/plaza: pintu Surau -> (-4,4) -> (-8,8) -> (-4,12) ->
	# (0,20) kawasan bersama -> (-8,18) -> (-2,2) -> pintu Surau.
	# Serambi TETAP jadi "rumah" luar-nya (tujuan pulang sholat +
	# jangkar patroli) — lihat _mulai_sholat/_rute_pulang.
	# REVISI (Mas 17 Nov 22:51 WIB: Surau lurus) — KOREKSI 23:15 WIB
	# (lurus = -90°): rumah luar Kyai kini (-3.5,-2.0) — di rumput
	# barat serambi (0,5 m di barat tepi serambi x=-3.42), 2 m di
	# barat sumbu pintu, di depan dinding depan (z=-4); dekat
	# menara (sisi barat-daya). BUKAN lagi di depan pintu (0,-2.3)
	# karena di situ jalur masuk + sandal. Dulu (asumsi 0° yang
	# salah): (-0.5,-4.5) di depan pintu (0,-6).
	# Saat sesi sholat Kyai jalan ke Surau sebagai IMAM (ronde 16).
	var patroli_kyai := {
		"kursi": InteriorSurau.ke_dunia(Vector3(5.6, 0, -305.0)),
		"kursi_yaw": KIBLAT_YAW,
		"pintu_dalam": _interior_door,
		"spawn_dalam": _interior_spawn,
		"pintu_luar": _outdoor_exit,
		"rute_luar": [
			Vector3(-4, 0, 4), Vector3(-8, 0, 8), Vector3(-4, 0, 12),
			Vector3(0, 0, 20), Vector3(-8, 0, 18), Vector3(-2, 0, 2),
		],
	}
	var npc3 := SantriNPC.new()
	npc3.setup("Ust. Aqsal Murad", Vector3(-3.5, 0, -2.0), [Vector3(-3.5, 0, -2.0)], MissionData.OUTFIT_KYAI, false, patroli_kyai)
	add_child(npc3)
	_npcs.append(npc3)
	_kyai = npc3
	# RONDE 20 KOREKSI: rumah luar Kyai = serambi — default
	# _rute_pulang sebelum ada sesi sholat. KOREKSI 23:15 WIB:
	# samakan dengan posisi setup (-3.5,-2.0); nilai lama
	# (-4.8,-4.8) sudah tidak di depan pintu yang benar.
	_npc_rumah[npc3] = Vector3(-3.5, 0, -2.0)
	npc3.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 21 — Ustadzah Mariyah PINDAH ke kampus putri BARU (Opsi A,
	# ACC Mas 22:03 WIB): Musholla Ar-Raudhah kini di (134,-24).
	# ABAYA zamrud gelap + JILBAB krem (lihat
	# MissionData.OUTFIT_USTADZAH; susulan Ronde 20, Mas 19:42 WIB).
	# Default DUDUK di dalam Musholla membaca kitab, sesekali
	# PATROLI area putri baru. Home di dekat pintu Musholla baru
	# (134,-17); patroli di dalam kawasan putri, semua di timur
	# tembok x=14: depan Musholla (134,-14) -> jalan internal x=142
	# depan Cangkruk/Kelas Putri (142,-6) -> (142,6) -> dekat Kantor
	# Ustadzah (148,-24) -> pintu musholla. Saat sesi sholat ia
	# memimpin sisi putri sebagai IMAM di Musholla Ar-Raudhah
	# (bukan ke Surau). "Rumah" luar-nya: dekat pintu musholla
	# (tujuan pulang sholat).
	var patroli_ustadzah := {
		"kursi": InteriorMusholla.ke_dunia(InteriorMusholla.KURSI_USTADZAH),
		"kursi_yaw": KIBLAT_YAW,
		"pintu_dalam": _musholla_door,
		"spawn_dalam": _musholla_spawn,
		"pintu_luar": _musholla_exit,
		"rute_luar": [
			Vector3(134, 0, -14), Vector3(142, 0, -6),
			Vector3(142, 0, 6), Vector3(148, 0, -24),
		],
	}
	var npc4 := SantriNPC.new()
	npc4.setup("Ustadzah Mariyah", Vector3(134, 0, -17), [Vector3(134, 0, -17)], MissionData.OUTFIT_USTADZAH, false, patroli_ustadzah)
	add_child(npc4)
	_npcs.append(npc4)
	_ustadzah = npc4
	# RONDE 21 KOREKSI: rumah luar Ustadzah = dekat pintu musholla
	# BARU (134,-17) — default _rute_pulang sebelum ada sesi sholat.
	# Rumah lama (18,-16) jatuh di AREA PUTRA setelah kampus putri
	# pindah ke timur (tembok x=14).
	_npc_rumah[npc4] = Vector3(134, 0, -17)
	npc4.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE 21 — SATPAM gerbang: seragam gelap (lihat
	# MissionData.OUTFIT_SATPAM). Berdiri TETAP di timur gerbang —
	# posisi dari dict build (_pos_satpam, kontrak Ronde 21) — menghadap
	# BARAT ke gerbang (14,0). TIDAK keliling, TIDAK mengobrol, TIDAK
	# ikut sholat (tetap di pos selama sesi). Mode diam (npc.gd).
	# RONDE PERBAIKAN (Eka, 17 Nov): SEBELUMNYA di (17,5) — TITIK
	# TENGAH gubuk PosSatpam 3x3 m — jadi ia berdiri DI DALAM gubuk,
	# tersembunyi di balik dinding 2,6 m (retest Ronde 23 tidak
	# menemukannya; raycast dari sisi putri menabrak dinding gubuk).
	# Percobaan pertama (15,0,5, depan pintu barat) MASIH tersembunyi
	# dari timur — gubuk menutupi dari hampir semua sudut timur
	# (raycast (20,10)->satpam menabrak dinding selatan gubuk).
	# Kini di SELATAN gubuk (17,0,8,0) — 1,5 m di selatan dinding
	# selatan, di tanah terbuka — terlihat jelas dari timur (arah
	# datang santriwati dari spawn), utara, dan selatan, + masih
	# bisa melihat gerbang. Yaw -2,78 = atan2(-3,-8), arah dari
	# (17,8) ke gerbang (14,0).
	var pos_satpam_luar := Vector3(17.0, 0, 8.0)
	var npc5 := SantriNPC.new()
	npc5.setup("Satpam", pos_satpam_luar, [pos_satpam_luar], MissionData.OUTFIT_SATPAM, true, {}, false)
	npc5.rotation.y = -2.78
	add_child(npc5)
	_npcs.append(npc5)
	_satpam = npc5
	npc5.rute_selesai.connect(_on_npc_rute_selesai)

	# RONDE TEKA-TEKI (Raka, 18 Nov 2026 — keputusan Mas 23:03 WIB
	# Opsi B + koreksi Mas 23:04 WIB "Satpamnya cewe ya"): PENJAGA
	# POS JAGA PUTRI — CEWE, abaya + jilbab (OUTFIT_PENJAGA_PUTRI,
	# abaya jati — BUKAN seragam Satpam cowok). Perilaku = pola
	# Satpam: DIAM di pos, TIDAK ikut sholat, bisa ditanya teka-teki
	# (langkah 4). POSISI (173,-20), BUKAN (176,-20) pusat gubuk:
	# gubuk Pos Jaga TL 3x3 m berdinding 2,6 m dengan pintu BARAT
	# (POS_JAGA_DOOR (174.5,-20), exit (173,-20)) — berdiri tepat
	# di pusat (176,-20) akan MENYEMBUNYIKANNYA di dalam gubuk
	# (pelajaran Satpam, Ronde 21: dulu di (17,5) tengah gubuk,
	# tidak terlihat). Ia berdiri di depan pintu barat, di tanah
	# terbuka, menghadap BARAT ke jalan internal (yaw -PI/2).
	var pos_penjaga_luar := Vector3(173.0, 0, -20.0)
	var npc6 := SantriNPC.new()
	npc6.setup("Penjaga Pos Jaga", pos_penjaga_luar, [pos_penjaga_luar], MissionData.OUTFIT_PENJAGA_PUTRI, true, {}, false)
	npc6.rotation.y = -PI / 2.0
	add_child(npc6)
	_npcs.append(npc6)
	_penjaga_putri = npc6
	npc6.rute_selesai.connect(_on_npc_rute_selesai)

	# GELOMBANG 2 FASE A — Ust. Sanusi (Onboarding A8, §1A langkah 4):
	# NPC BARU, mode DIAM (berdiri tetap di tempat — santri yang
	# mencari dia, bukan dia yang keliling). Posisi = lokasi acak
	# dari LokasiAcak — TANPA marker peta (tempatkan_sanusi hanya
	# memindah posisi, tidak membuat marker; §1A: pencariannya
	# sungguhan). Bila save sudah punya lokasi Sanusi (langkah 4
	# sudah dimulai), pakai lokasi itu supaya konsisten dengan
	# state machine; kalau belum, acak satu sekarang — maju() yang
	# akan mengacak ulang + menyimpan saat langkah 4 resmi dimulai.
	# SENGAJA TIDAK masuk _npcs: keikutsertaan Sanusi di sholat
	# berjamaah belum diputuskan Raka (setup default ikut_sholat
	# true; bila masuk _npcs ia berbagi sajadah Bilal — perlu
	# sajadah sendiri / ikut_sholat=false). Sinyal pesan belum
	# disambung ke UI — dialog Sanusi bagian A9 (Sinta).
	_sanusi = Onboarding.buat_sanusi(self)
	var ob_sanusi := Onboarding.baca(_save)
	var lok_id := String(ob_sanusi["sanusi_lokasi"])
	if LokasiAcak.id_valid(lok_id):
		Onboarding.tempatkan_sanusi(_sanusi, LokasiAcak.pos_dari_id(lok_id))
	else:
		var lok_acak := LokasiAcak.acak()
		Onboarding.tempatkan_sanusi(_sanusi, lok_acak["pos"])
	_sanusi.rute_selesai.connect(_on_npc_rute_selesai)

	# RANTAI PUTRI (perintah Mas 20:30 WIB "segera realisasikan",
	# keputusan §9 butir 22, 18:55 WIB) — Ustzh. Fatimah: guru
	# santri putri, cerminan Ust. Sanusi (mode DIAM, lokasi acak
	# di AREA PUTRI saja, tanpa marker peta). Posisi = lokasi acak
	# putri dari LokasiAcak — bila save sudah punya lokasi Fatimah
	# (langkah 4 sudah dimulai), pakai lokasi itu; kalau belum,
	# acak satu sekarang. SENGAJA TIDAK masuk _npcs (sama seperti
	# Sanusi: keikutsertaan di sholat berjamaah belum diputuskan).
	_fatimah = NPCFatimah.buat(self)
	var ob_fatimah := Onboarding.baca(_save)
	var lok_fatimah_id := String(ob_fatimah["fatimah_lokasi"])
	if LokasiAcak.id_valid_putri(lok_fatimah_id):
		NPCFatimah.tempatkan(_fatimah, LokasiAcak.pos_dari_id_putri(lok_fatimah_id))
	else:
		var lok_acak_putri := LokasiAcak.acak_putri()
		NPCFatimah.tempatkan(_fatimah, lok_acak_putri["pos"])
	_fatimah.rute_selesai.connect(_on_npc_rute_selesai)



# ---------- login / sesi ----------
# RONDE 6 (Mas 22:17 WIB — sistem SATU jalur): login/daftar TANPA
# pilihan jalur. Satu kurikulum berurutan untuk semua santri.
# Integrasi login-gender (17 Nov 2026): login ke server dengan
# username IG (+ kata sandi bila sudah diset). Server mengembalikan
# ID + nama + jenis_kelamin ("putra"/"putri") + token sesi — gender
# ditulis ke save supaya _pemain_adalah_putri() + spawn + aturan
# batas cermin aktif. Gagal/offline = pesan jelas, save tidak diubah.
# Registrasi-gender (Tara, 17 Nov 2026): daftar JUGA ke server
# (POST /api/santri/register, publik) — nama + akun IG + gender;
# server menerbitkan ID PV-XXXX. Daftar lokal (terbitkan ID sendiri)
# DIHAPUS — tidak ada lagi pendaftaran diam-diam tanpa server.
func _on_login(ig_username: String, password: String) -> void:
	# Ketukan ganda saat request berjalan: abaikan (tombol sudah
	# dikunci UI, ini jaring pengaman kedua).
	if _login_http != null:
		return
	var ig := SantriSave.normalisasi_ig(ig_username)
	_ui.set_login_loading(true)
	_ui.show_login_error("")
	var http := HTTPRequest.new()
	http.timeout = LOGIN_TIMEOUT_DETIK
	_login_http = http
	add_child(http)
	http.request_completed.connect(_on_login_http_selesai)
	var body := {"ig_username": ig}
	if password != "":
		body["password"] = password
	var err := http.request(
		SERVER_BASE_URL + "/api/santri/login",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		_login_http = null
		http.queue_free()
		_ui.set_login_loading(false)
		_ui.show_login_error("Tidak bisa menghubungi server. Periksa koneksi internet, lalu coba lagi.")


func _on_login_http_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _login_http
	_login_http = null
	if http != null:
		http.queue_free()
	_ui.set_login_loading(false)
	# Jawaban (apa pun isinya) menghapus galat sebelumnya — galat
	# hanya ditulis lagi di bawah bila jawaban ini memang gagal.
	_ui.show_login_error("")
	# Jaringan gagal (offline / DNS / timeout): jangan crash, jangan
	# ubah save — pemain tetap di layar login dengan pesan jelas.
	if result != HTTPRequest.RESULT_SUCCESS:
		_ui.show_login_error("Server tidak terjangkau. Periksa koneksi internet, lalu coba lagi.")
		return
	# 401 = kata sandi salah (cek sebelum parse supaya halaman error
	# proxy yang bukan JSON tidak menutupi pesannya).
	if response_code == 401:
		_ui.show_login_error("Kata sandi salah. Coba lagi.")
		return
	# Bukan JSON sama sekali (mis. halaman error proxy): jangan panggil
	# JSON.parse_string — ia mencetak ERROR ke log tanpa perlu.
	var teks := body.get_string_from_utf8().strip_edges()
	if not teks.begins_with("{"):
		_ui.show_login_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var parsed: Variant = JSON.parse_string(teks)
	if not (parsed is Dictionary):
		_ui.show_login_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var data := parsed as Dictionary
	if response_code != 200:
		_ui.show_login_error("Server menjawab %d. Coba lagi nanti." % response_code)
		return
	if not bool(data.get("found", false)):
		_ui.show_login_error("Username IG tidak ditemukan. Daftar dulu lewat aplikasi, lalu coba lagi.")
		return
	var galat := _terapkan_login_server(data)
	if galat != "":
		_ui.show_login_error(galat)
		return
	_masuk_pesantren("Selamat datang di Pesantren Universe, " + String(_save["nama"]) + "!")


## Terapkan jawaban login server ke save lokal. Murni (tanpa I/O
## jaringan) supaya bisa dites headless dengan respons stub.
## Mengembalikan "" bila sukses, atau pesan galat untuk ditampilkan.
## Aturan: jenis_kelamin di luar "putra"/"putri" (termasuk field
## belum ada di server) = "putra" — perilaku lama tetap aman.
## Baca string dari dict jawaban server dengan aman: nilai null
## (mis. jenis_kelamin:null untuk santri lama) TIDAK boleh masuk ke
## String(...) — konstruktor itu error pada null. Kembalikan default.
static func _str_atau(d: Dictionary, kunci: String, default: String = "") -> String:
	var v: Variant = d.get(kunci, default)
	return default if v == null else String(v)


## KASUR (Wulan): muat tugas kasur pemain ini dari ledger lokal.
## Dipanggil di _ready + setelah login/daftar (ID bisa berganti).
func _muat_kasur_saya() -> void:
	var id := String(_save.get("id_santri", ""))
	_kasur_saya = PembagianKasur.bersama().ambil(id) if id != "" else {}


func _terapkan_login_server(data: Dictionary) -> String:
	var id_santri := _str_atau(data, "id").strip_edges().to_upper()
	if not SantriSave.id_valid(id_santri):
		return "Server mengembalikan ID yang tidak valid."
	var nama := _str_atau(data, "nama").strip_edges()
	if nama.length() < 2:
		return "Server mengembalikan nama yang tidak valid."
	var jk := _str_atau(data, "jenis_kelamin", "putra").strip_edges().to_lower()
	if jk != "putri" and jk != "putra":
		jk = "putra"
	var ig := SantriSave.normalisasi_ig(_str_atau(data, "ig_username"))
	# ID baru = santri baru: mulai dari nol. ID sama = lanjutkan progres.
	# Counter ID lokal dipertahankan supaya daftar berikutnya tidak
	# bertabrakan dengan ID yang pernah dipakai di perangkat ini.
	var counter := int(_save.get("id_terakhir", 0))
	# KASUR (Wulan): ID baru = santri baru = dapat 1 kasur (di bawah,
	# setelah save ditulis). Tangkap di sini — _save di-reset di bawah.
	var id_baru := String(_save.get("id_santri", "")) != id_santri
	if id_baru:
		_save = SantriSave.default_data()
	_save["id_terakhir"] = counter
	SantriSave.catat_id(_save, id_santri)
	_save["id_santri"] = id_santri
	_save["nama"] = nama
	_save["ig_username"] = ig
	_save["jenis_kelamin"] = jk
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	_session_token = _str_atau(data, "session")
	SantriSave.save_data(_save)
	# KASUR: setiap login memastikan santri punya kasur (ledger lokal,
	# idempotent — santri lama kembali ke kasur lamanya, santri baru
	# dapat kasur baru). Tanpa ini, santri lama yang ledger-nya hilang
	# (ganti HP / ledger terhapus) tidak pernah dapat kasur lagi
	# karena id_baru=false di login ulang (temuan tes 00:40 WIB).
	_kasur_saya = PembagianKasur.daftarkan_baru(id_santri, jk)
	return ""


## Registrasi-gender (Tara, 17 Nov 2026): daftar santri baru KE
## SERVER (POST /api/santri/register, publik, tanpa token).
## Body: ig_username + nama + jenis_kelamin ("putra"/"putri").
## Sukses (201): server menerbitkan ID PV-XXXX -> tulis ke save +
## langsung masuk (spawn sesuai gender). Gagal (409 username dipakai
## / 400 isian ditolak / offline): pesan jelas di form, save tidak
## disentuh, TIDAK ada daftar lokal diam-diam.
func _on_register(ig_username: String, nama: String, jenis_kelamin: String) -> void:
	# Ketukan ganda saat request berjalan: abaikan (tombol sudah
	# dikunci UI, ini jaring pengaman kedua).
	if _register_http != null:
		return
	var ig := SantriSave.normalisasi_ig(ig_username)
	var jk := jenis_kelamin.strip_edges().to_lower()
	if not RegistrasiServer.gender_valid(jk):
		jk = "putra"
	_ui.set_register_loading(true)
	_ui.show_register_error("")
	var http := HTTPRequest.new()
	http.timeout = LOGIN_TIMEOUT_DETIK
	_register_http = http
	add_child(http)
	http.request_completed.connect(_on_register_http_selesai)
	var err := http.request(
		SERVER_BASE_URL + "/api/santri/register",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(RegistrasiServer.bangun_body(ig, nama, jk))
	)
	if err != OK:
		_register_http = null
		http.queue_free()
		_ui.set_register_loading(false)
		_ui.show_register_error("Tidak bisa menghubungi server. Periksa koneksi internet, lalu coba lagi.")


func _on_register_http_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _register_http
	_register_http = null
	if http != null:
		http.queue_free()
	_ui.set_register_loading(false)
	# Jawaban (apa pun isinya) menghapus galat sebelumnya — galat
	# hanya ditulis lagi di bawah bila jawaban ini memang gagal.
	_ui.show_register_error("")
	var teks := body.get_string_from_utf8().strip_edges()
	var galat := RegistrasiServer.pesan_galat_respons(result, response_code, teks)
	if galat != "":
		_ui.show_register_error(galat)
		return
	# Bukan JSON sama sekali (mis. halaman error proxy): jangan panggil
	# JSON.parse_string — ia mencetak ERROR ke log tanpa perlu.
	if not teks.begins_with("{"):
		_ui.show_register_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var parsed: Variant = JSON.parse_string(teks)
	if not (parsed is Dictionary):
		_ui.show_register_error("Jawaban server tidak dapat dibaca. Coba lagi.")
		return
	var data := parsed as Dictionary
	var galat_data := _terapkan_register_server(data)
	if galat_data != "":
		_ui.show_register_error(galat_data)
		return
	_masuk_pesantren("Selamat datang, " + String(_save["nama"]) + "! ID Santrimu: " + String(_save["id_santri"]) + " — simpan baik-baik ya.")


## Terapkan jawaban register server ke save lokal. Murni (tanpa I/O
## jaringan) supaya bisa dites headless dengan respons stub.
## Mengembalikan "" bila sukses, atau pesan galat untuk ditampilkan.
## Aturan: ID + nama + jenis_kelamin diambil dari JAWABAN server
## (sumber kebenaran — sudah ternormalisasi); gender di luar
## "putra"/"putri" tidak mungkin lolos validasi (lihat
## RegistrasiServer.validasi_jawaban).
func _terapkan_register_server(data: Dictionary) -> String:
	var galat := RegistrasiServer.validasi_jawaban(data)
	if galat != "":
		return galat
	var id_santri := _str_atau(data, "id").strip_edges().to_upper()
	var nama := _str_atau(data, "nama").strip_edges()
	var jk := _str_atau(data, "jenis_kelamin", "putra").strip_edges().to_lower()
	if jk != "putri" and jk != "putra":
		jk = "putra"
	var ig := SantriSave.normalisasi_ig(_str_atau(data, "ig_username"))
	# Pendaftar baru = mulai dari nol. Counter ID lokal dipertahankan
	# supaya daftar berikutnya tidak bertabrakan dengan ID yang
	# pernah dipakai di perangkat ini.
	var counter := int(_save.get("id_terakhir", 0))
	_save = SantriSave.default_data()
	_save["id_terakhir"] = counter
	SantriSave.catat_id(_save, id_santri)
	_save["id_santri"] = id_santri
	_save["nama"] = nama
	_save["ig_username"] = ig
	_save["jenis_kelamin"] = jk
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	SantriSave.save_data(_save)
	# KASUR (Wulan): pendaftar baru langsung dapat 1 kasur.
	_kasur_saya = PembagianKasur.daftarkan_baru(id_santri, jk)
	return ""


func _on_continue() -> void:
	_save["terakhir_login"] = SantriSave.tanggal_hari_ini()
	SantriSave.save_data(_save)
	_masuk_pesantren("Selamat datang kembali, " + String(_save["nama"]) + "!")


## KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): samakan
## visual pemain dengan gender save. Santriwati ("putri") memakai
## muslimah + hijab (abaya + jilbab); santriwan tidak. Visual
## dibangun ulang HANYA bila flag-nya berubah — masuk ulang sebagai
## santriwan tidak membangun ulang apa-apa. Flag disimpan di save
## supaya panel Ganti Baju tahu baris mana yang ditampilkan dan
## warna abaya/jilbab bertahan antar sesi.
func _terapkan_gender_pemain() -> void:
	var outfit: Dictionary = _save.get("outfit", MissionData.OUTFIT_DEFAULT).duplicate()
	var putri := _pemain_adalah_putri()
	outfit["muslimah"] = putri
	outfit["hijab"] = putri
	_save["outfit"] = outfit
	if putri != _player.apakah_muslimah():
		_player.bangun_ulang_visual(outfit)
	SantriSave.save_data(_save)


# ROMBAKAN HUD v3 (Tara, 18 Nov 2026): pop-up "PETUNJUK TOMBOL"
# ditutup -> simpan flag supaya tidak muncul lagi di sesi berikut.
# Flag HARUS ditulis lewat _save di sini (bukan UI menulis langsung
# ke disk): main menyimpan _save berkali-kali sesudah masuk dunia,
# jadi tulisan langsung UI akan tertimpa save _save yang tidak punya
# flag.
func _on_petunjuk_ditutup() -> void:
	_save["petunjuk_tombol_ditutup"] = true
	SantriSave.save_data(_save)
	# Pop-up ditutup -> sinkronkan HUD lagi (banner petunjuk misi
	# santri baru muncul bila masih langkah 2).
	_update_hud()


func _masuk_pesantren(pesan: String) -> void:
	# KIRANA 17 Nov 2026 (Mas: abaya + jilbab bisa dikostum): visual
	# pemain mengikuti gender save — santriwati tampil abaya +
	# jilbab, santriwan tetap koko. Dipanggil di awal sini (sebelum
	# teleport) karena _ready membangun santriwan dulu.
	_terapkan_gender_pemain()
	# KUALITAS ADAPTIF: mulai probe FPS ~3 detik SETELAH masuk dunia
	# (fps layar login tidak mewakili dunia). Hanya jalan di mode
	# Otomatis; probe hanya bisa menurunkan tingkat, tidak menaikkan.
	if _kualitas != null:
		_kualitas.mulai_probe()
	# Spawn sesuai gender: santriwati di kampus putri (130,14),
	# santriwan di depan Surau (-4,14). Jangkar dorong-balik
	# _cek_batas ikut diperbarui di sini — _ready jalan SEBELUM
	# login (saat save masih putra), jadi tanpa ini santriwati
	# pertama kali login akan berdiri di area putra dan langsung
	# didorong balik ke titik yang salah.
	var spawn := _spawn_putri if _pemain_adalah_putri() else PesantrenBuilder.SPAWN
	_teleport_player(spawn, PI)
	_pos_legal_terakhir = spawn
	_punya_pos_legal = true
	_player.set_nama(String(_save["nama"]))
	# RONDE 6: terapkan outfit tersimpan (koko/songkok/sarung) saat masuk.
	_player.terapkan_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))
	_player.set_sandal(true)
	_ui.show_world()
	# ROMBAKAN HUD v3 (Tara, 18 Nov 2026): pop-up "PETUNJUK TOMBOL"
	# untuk pemain baru — hanya bila belum pernah ditutup (flag di
	# _save; sudah_ditutup dibaca di sini, bukan di UI, supaya flag
	# tidak tertimpa save _save yang ditulis main berkali-kali).
	_ui.coba_tampilkan_petunjuk_awal(bool(_save.get("petunjuk_tombol_ditutup", false)))
	# FASE A (Onboarding §1A langkah 1 -> 2): masuk dunia = "Daftar
	# jadi santri" selesai — langkah berikut "Cari Ust. Aqsal M".
	# Sekali saja (guard langkah == 1); masuk ulang tidak maju lagi.
	# CATATAN (temuan Sinta, 18 Nov): JANGAN toast "Cari..." di sini
	# — toast() di bawah langsung menimpanya (label tunggal 2,5 dtk,
	# tanpa antrean), jadi pemain tidak pernah melihatnya; pesan
	# selamat datang di bawah juga membawa ID Santri saat daftar.
	# Arahan "Cari Ustzh. Mariyah / Ust. Aqsal M" kini tampil
	# PERSISTEN di label misi HUD (_update_hud) + Panel Misi.
	if Onboarding.langkah_saat_ini(_save) == 1:
		Onboarding.maju(_save)
		SantriSave.save_data(_save)
	# FITUR CUACA (Wulan; hook Raka): mulai cuaca lokasi — sekali per
	# sesi; di luar web / izin ditolak / API gagal = tetap cerah.
	if _cuaca == null:
		_cuaca = Cuaca.new()
		_cuaca.name = "Cuaca"
		add_child(_cuaca)
	_cuaca.mulai(_pesantren["langit"])
	_ui.toast(pesan)
	_refresh_markers()
	_update_hud()
	# MULTIPLAYER FASE 1 (Wira): titik "Masuk Dunia" — login/daftar/
	# lanjut selesai, dunia terlihat. Di sini koneksi realtime
	# dimulai (NetworkManager connect + submit_ticket); bila tidak
	# ada NetworkManager/server, game tetap jalan offline.
	_mp_mulai()


# ---------- respawn (jatuh ke jurang / keluar batas / tombol reset) ----------
# Perbaikan 15 Nov ~12:00 WIB (Mas jatuh ke jurang dan terjebak): kalau
# pemain jatuh di bawah ambang Y atau keluar batas pesantren, teleport
# kembali ke titik spawn (depan Surau). Dipanggil tiap frame di _process
# dan dari tombol "Reset Posisi" di HUD.
func _respawn_ke_spawn() -> void:
	# RONDE 4: reset selalu ke peta LUAR — kalau pemain jatuh/nyangkut
	# di dalam interior pun, ia kembali ke luar. Titik luar SESUAI
	# GENDER (putra: depan Surau; putri: kampus putri) — perbaikan
	# 18 Nov 2026, laporan Mas: reset santriwati malah ke Surau.
	# Perbaikan 15 Nov ~17:20 WIB (penguji ronde 3: Reset Posisi tidak
	# mengembalikan arah kamera): reset kini lewat _teleport_player
	# yang men-snap posisi + arah hadap + yaw kamera + pitch kamera.
	# RONDE 6: reset juga mengeluarkan pemain dari interior (sembunyikan
	# kedua interior — perbaikan double surau), mengembalikan pose
	# berdiri + sandal dipakai lagi.
	_di_dalam = false
	_di_dalam_cangkruk = false
	_di_dalam_musholla = false
	_di_dalam_kelas_putri = false
	_di_dalam_asrama_putri = false
	_di_dalam_asrama_putra = false
	_di_dalam_kantor = false
	_di_dalam_madrasah = false
	_di_dalam_studio = false
	_di_dalam_pos_jaga = false
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_player.set_aksi("berdiri")
	# RONDE 13: reset posisi mengeluarkan pemain dari sholat (kalau
	# sedang ikut) — banner ditampilkan lagi selama sesi berjalan.
	# RONDE 18: banner hanya kembali selama "kumpul" (takbir sudah
	# mulai = pendaftaran ikut ditutup).
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		if _sholat_aktif and _sholat_adegan == "kumpul":
			_ui.show_sholat_banner(_sholat_nama, "Musholla" if _pemain_adalah_putri() else "Surau")
	# PERBAIKAN RESET PUTRI (Raka, 18 Nov 2026 — laporan Mas 20:20 WIB):
	# reset dulu SELALU ke PesantrenBuilder.SPAWN (-4,14) depan Surau —
	# santriwati ikut terlempar ke area putra. Kini ke spawn sesuai
	# gender (putri -> _spawn_putri (140,16) kampus putri), sama seperti
	# spawn saat login (_masuk_pesantren). Jangkar dorong-balik ikut
	# diperbarui supaya _cek_batas tidak menarik pemain kembali ke
	# posisi legal lama (yang bisa berada di area seberang).
	var spawn := _spawn_putri if _pemain_adalah_putri() else PesantrenBuilder.SPAWN
	_teleport_player(spawn, PI)
	_pos_legal_terakhir = spawn
	_punya_pos_legal = true
	_ui.toast("Kamu kembali ke kampus putri." if _pemain_adalah_putri() else "Kamu kembali ke depan Surau.")


# ---------- per-frame ----------
func _process(delta: float) -> void:
	_bob_time += delta
	# MULTIPLAYER FASE 1 (Wira): adopsi avatar sendiri + log/UI MP.
	_mp_proses_frame(delta)
	# Jaring pengaman jurang: jatuh ke bawah -> kembali ke spawn.
	# RONDE 5 (Mas: "tidak ada batasannya"): cek batas luar DIHAPUS —
	# tidak ada lagi teleport karena jalan terlalu jauh. Yang tersisa
	# hanya jatuh ke bawah (y < -5, mis. jatuh dari tepi tanah di
	# ±400 m) -> kembali ke spawn. Pemain di dalam interior (z=-300)
	# TIDAK BOLEH kena cek apa pun — interior punya lantai sendiri.
	var pp := _player.global_position
	if pp.y < -5.0:
		_respawn_ke_spawn()
	# Pintu Surau: jalan melewati ambang pintu = pindah map (ala GTA).
	_cek_pintu_surau()
	# RONDE 6: pintu kamar cangkruk — pola yang sama seperti Surau.
	_cek_pintu_cangkruk()
	# RONDE PERBAIKAN (Raka, integrasi item 7f): pintu Musholla —
	# pola yang sama (masuk = teleport ke map interior Musholla).
	_cek_pintu_musholla()
	# INTERIOR PUTRI (Lestari): pintu 6 gedung putri — pola yang sama.
	_cek_pintu_kelas_putri()
	_cek_pintu_asrama_putri()
	# ASRAMA PUTRA (Lestari): pintu Asrama Putra — pola yang sama.
	_cek_pintu_asrama_putra()
	_cek_pintu_kantor()
	_cek_pintu_madrasah()
	_cek_pintu_studio()
	_cek_pintu_pos_jaga()
	# ASRAMA PUTRI (Lestari): saat tidur di kasur susun, kapsul WAJIB
	# tetap di posisi tidur — gravitasi player.gd menariknya jatuh
	# ke lantai karena body kasur dimatikan (tidak ada pijakan di
	# y kasur; terukur headless: tanpa jepit ini y turun >0,05 m
	# dalam 5 frame). Jepit posisi + kecepatan tiap frame selama tidur.
	# ASRAMA PUTRA (Lestari): kontrak tidur yang sama (beds Putra
	# bila di Asrama Putra, beds Putri bila di Asrama Putri).
	if (_di_dalam_asrama_putri or _di_dalam_asrama_putra) and _kasur_tidur_idx > 0 and _player.aksi_saat_ini() == "tidur":
		var beds_jepit: Array = _asrama_putra_beds if _di_dalam_asrama_putra else _asrama_putri_beds
		_player.global_position = beds_jepit[_kasur_tidur_idx - 1]
		_player.velocity = Vector3.ZERO
	# RONDE 20: penegakan batas putra/putri + sandal NPC di pintu.
	_cek_batas(delta)
	_sinkron_sandal()
	# RONDE 13: masuk jendela waktu sholat -> mulai sesi berjamaah.
	_cek_waktu_sholat()
	# RONDE 18: mesin adegan sholat sinematik (takbir -> blackout ->
	# selesai) — jalan selama ada adegan, termasuk fase "selesai"
	# (fade masuk) yang sudah menutup sesi.
	if _sholat_adegan != "":
		_proses_adegan_sholat(delta)
	# RONDE 17: audio kegiatan mengikuti sesi yang berjalan (sholat /
	# khataman) — ambience mengikuti jam (di dalam AudioPesantren).
	_perbarui_audio()
	# Kamera mengikuti pemain. RONDE 4 (bonus "tampilan masih kaku"):
	# yaw/pitch kamera di-lerp (dulu dipasang langsung) supaya orbit
	# drag terasa halus, tidak patah-patah.
	# RONDE 7 (retest: kamera tidur masuk dinding — layar penuh kayu):
	# akar masalah: spring 7,0 m + pitch -0,35 menaruh kamera di
	# y≈4,0 — DI ATAS plafon cangkruk (3,6 m) yang TIDAK punya
	# collision, jadi spring tidak memendek dan kamera keluar ruangan
	# melihat plafon dari atas. Perbaikan 2 lapis: (a) di dalam
	# ruangan, spring dipendekkan ke 4,0 m (kamera y≈3,0 < plafon);
	# (b) plafon cangkruk kini punya collision (interior_cangkruk.gd)
	# sebagai jaring pengaman. Saat tidur, target rig diturunkan ke
	# 0,9 m supaya kamera memandang badan yang berbaring, bukan
	# udara kosong di atas kasur.
	var di_ruangan := _di_dalam or _di_dalam_cangkruk or _di_dalam_musholla or _di_dalam_kelas_putri or _di_dalam_asrama_putri or _di_dalam_asrama_putra or _di_dalam_kantor or _di_dalam_madrasah or _di_dalam_studio or _di_dalam_pos_jaga
	# RONDE 7 revisi: saat tidur spring 3,0 m (lebih dekat + lebih
	# rendah — kasur mengisi frame, plafon tidak mendominasi).
	# KAMERA ASRAMA (Lestari, 18 Nov 2026 — perbesaran Nadia tapak
	# 18x12, koridor 2,6 m): spring 5,5 m (dulu 4,0 m) + FOV 65
	# (dulu 60) khusus Asrama — portrait muat 3 pemain berdampingan
	# (lebar tampak +-3,2 m di jarak 5,5 m). Pitch dijepit ke -0,22:
	# kamera (y 1,6 + 5,5*sin 0,22 = 2,8 m) tetap DI BAWAH pelat
	# lantai atas (y 3,0, punya collision); pitch lama -0,35 di
	# spring 5,5 m menaruh kamera di y = 3,5 m = DI DALAM pelat.
	# Berlaku untuk Asrama Putri DAN Asrama Putra (denah sama).
	# Di luar Asrama TIDAK berubah (spring 4,0 ruangan / 7,0 luar,
	# FOV 60 — kontrak test_kamera LAMA; v3: luar Normal 8,0 / FOV 68,
	# ruangan non-Asrama 4,0 — lihat kamera.gd butir 9 + 11).
	# _jarak_kamera_aman + SpringArm tetap memendekkan spring bila
	# tembok di belakang pemain.
	var di_asrama := _di_dalam_asrama_putri or _di_dalam_asrama_putra
	# MODE KAMERA v3 (Cakra, 18 Nov 13:13 — permintaan Mas + koreksi
	# "Normal masih belum luas" + "dicubit enak ngga"): target
	# spring/pitch/FOV/tinggi DIHITUNG modul kamera.gd (mode + jepit
	# Asrama/ruangan + zoom cubit). Kontrak Asrama TIDAK berubah
	# (spring 5,5 / pitch -0,22 / FOV 65 — modul yang menjepit).
	var tidur := _player.aksi_saat_ini() == "tidur"
	# SINEMATIK: yaw berputar SANGAT pelan (0,05 rad/dtk); mode lain
	# putar_sinematik mengembalikan yaw apa adanya.
	_cam_yaw = _kamera.putar_sinematik(delta, _cam_yaw)
	var spring_target := _kamera.perbarui(delta, _rig, _spring, _cam,
		_player.global_position, _cam_yaw, _cam_pitch, tidur, di_asrama, di_ruangan)
	# NAMA DI DRONE (keputusan Mas 13:19): boost skala label nama
	# diteruskan lewat meta kamera — dibaca Palette tiap frame
	# (pemain + NPC + ikon misi). Mode lain meta = 1,0 (tak berubah).
	_cam.set_meta("drone_label_boost", _kamera.pengali_label_drone())
	_kamera.terapkan_panjang_spring(_spring, _jarak_kamera_aman(spring_target, delta), delta)
	# RONDE PERBAIKAN (Eka): panjang spring dijaga _jarak_kamera_aman —
	# kamera tidak boleh terhalang tembok/objek dari pemainnya (lihat
	# fungsi di bawah). SpringArm3D saja tidak cukup: sinarnya hanya
	# memeriksa sepanjang 7 m dari rig — tembok yang 8 m jauhnya di
	# sepanjang sinar (pemain di utara gedung, kamera 7 m di selatan)
	# tidak tertangkap, kamera mendarat di dalam gedung/atap (probe
	# ronde perbaikan: pemain masuk cangkang KelasPutri, kamera di
	# (130, 4.02, 3.05) — di dalam footprint gedung, di atas atap).
	# CATATAN: SpringArm3D TIDAK diberi shape (SphereShape3D) —
	# shape cast yang berawal di rig (di dalam kapsul pemain sendiri)
	# langsung bertabrakan dengan kapsul itu dan menjepit kamera ke
	# panjang ~0. Penjaga garis pandang di bawah memakai raycast
	# (sinar dari titik tidak menabrak bentuk yang memuat titik awal).
	# KAMERA (Cakra, v2 18 Nov 00:16 — PERBAIKAN BUG MABUK dari HP
	# Mas): goyang + dinamika framing DIMATIKAN TOTAL. Follow +
	# anti-getar di kamera.gd. Panjang spring hasil
	# _jarak_kamera_aman diterapkan HALUS (asimetris: cepat
	# memendek, pelan memanjang) supaya tidak melonjak saat
	# halangan masuk/keluar sinar raycast.
	# RONDE 5 (perbaikan dari foto): bobot lerp HARUS dijepit ke 1.0 —
	# di frame lambat (delta > 0,125 dtk, mis. HP kentang / render
	# software) delta*8 > 1 membuat rig OVERSHOOT lalu berosilasi,
	# kamera terbang menjauh dari pemain (terbukti di foto NPC ronde 5:
	# kamera mendarat di papan selamat datang). Dijaga di kamera.gd
	# (bobot eksponensial 1-exp(-k*delta), selalu <= 1,0).
	# Gerak: joystick atau keyboard, relatif terhadap kamera.
	var input_vec := Vector2.ZERO
	var joy := _ui.get_joystick_vector()
	if joy.length() > 0.05:
		input_vec = joy
	else:
		input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if Input.is_key_pressed(KEY_A):
			input_vec.x -= 1.0
		if Input.is_key_pressed(KEY_D):
			input_vec.x += 1.0
		if Input.is_key_pressed(KEY_W):
			input_vec.y -= 1.0
		if Input.is_key_pressed(KEY_S):
			input_vec.y += 1.0
	var forward := -_rig.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := _rig.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	# RONDE 6: pose diam (duduk/menulis/tidur/salaman/melambai) menahan
	# gerak — input jalan dinolkan supaya pose tidak rusak.
	# RONDE 8: gerak MEMBANGUNKAN dari tidur / MENGAKHIRI salaman dan
	# melambai (pose tahan sampai pemain bergerak — retest: 5 dtk terlalu
	# singkat, bangun hanya bisa lewat Aksi -> Berdiri). input_mentah
	# dibaca SEBELUM dinolkan di bawah.
	# BACA BUKU (Tara): selagi pembaca terbuka, pemain tidak bisa
	# jalan — input jalan dinolkan di sini (joystick + keyboard),
	# sebelum pose diam membacanya. Tutup panel mengembalikan kontrol.
	if _ui.is_baca_buku_visible():
		input_vec = Vector2.ZERO
	var input_mentah := input_vec
	if _player.sedang_aksi_diam():
		input_vec = Vector2.ZERO
	if input_mentah.length() > 0.3 and _player.aksi_saat_ini() in ["tidur", "salaman", "melambai", "sholat"]:
		_on_aksi("berdiri")
	_player.move_dir = (right * input_vec.x + forward * (-input_vec.y))
	# Penanda misi terdekat.
	_update_interact_button()
	# Peta hidup: posisi santri + NPC diperbarui tiap frame selama
	# panel peta terbuka (RONDE 4). RONDE 5: minimap GTA di HUD juga
	# diperbarui tiap frame selama dunia terlihat.
	if _ui.is_peta_visible():
		_ui.update_peta(_data_peta())
	if _ui.is_world_visible():
		_ui.update_minimap(_data_peta())
	# BUBBLE-ML: blok RONDE 7 DIHAPUS — bubble 3D dimatikan, jadi
	# set_bubble_ditahan() kini no-op (player.gd). Label nama di bawah
	# tetap ditahan saat panel chat terbuka (masih dipakai).
	# RONDE 8: label nama JUGA ditahan saat panel chat terbuka (retest:
	# panel chat memotong label nama "Tes" jadi setengah).
	var chat_buka := _ui.is_chat_visible()
	_player.set_nama_ditahan(chat_buka)
	for npc in _npcs:
		npc.set_nama_ditahan(chat_buka)
	# Animasi bobbing penanda misi + batasi ukuran tampak ikon/status
	# (15 Nov ~12:50 WIB: label melayang tidak boleh membesar menutupi
	# layar saat kamera dekat).
	var i := 0
	for id in _markers.keys():
		var node: Node3D = _markers[id]
		var icon: Label3D = node.get_node_or_null("Icon")
		if icon != null and icon.visible:
			icon.position.y = 2.9 + sin(_bob_time * 2.0 + float(i)) * 0.15
			Palette.batasi_label_kamera(icon, _cam)
		var status: Label3D = node.get_node_or_null("Status")
		if status != null:
			Palette.batasi_label_kamera(status, _cam)
		i += 1


## RONDE PERBAIKAN (Eka) — penjaga kamera third-person: panjang spring
## AMAN (<= target) supaya kamera tidak menembus bangunan/karakter.
## Cara: raycast dari posisi kamera PROSPEKTIF (spring penuh = target)
## ke pemain. Kalau garis pandang itu bersih -> pakai target. Kalau
## terhalang -> spring dipendekkan ke proyeksi titik tabrak ke sumbu
## lengan (dikurangi margin 0,3 m) — kamera berhenti di depan
## penghalang, stabil (tidak berosilasi: panjang dihitung langsung dari
## titik tabrak, bukan ditarik-mundur iteratif). SpringArm3D sendiri
## tetap menangani tembok di antara rig dan kamera; penjaga ini
## menangani tembok di antara KAMERA dan pemain yang sinar spring-nya
## lewati (mis. dinding rendah dekat pemain yang sinar spring lewati
## dari atas — probe: sinar spring melewati tembok 3,6 m, kamera
## mendarat di dalam cangkang KelasPutri).
## (b) NPC tidak punya body fisika (npc.gd), jadi sinar tidak bisa
## mendeteksinya: kalau ada NPC dalam 0,9 m dari posisi kamera
## efektif, spring dibatasi 2,0 m (kamera merapat, tidak menembus
## karakter itu). Mengembalikan panjang spring frame ini (min 1,2 m).
func _jarak_kamera_aman(target: float, _delta: float) -> float:
	var rig_pos := _rig.global_position
	var arah := _spring.global_transform.basis.z.normalized()
	var kamera_penuh := rig_pos + arah * target
	var target_pemain := _player.global_position + Vector3(0, 1.2, 0)
	var q := PhysicsRayQueryParameters3D.create(kamera_penuh, target_pemain)
	q.collision_mask = 0xFFFFFFFF
	q.exclude = [_player.get_rid()]
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(q)
	var batas := target
	if not hit.is_empty():
		var h: Vector3 = hit["position"]
		batas = clampf((h - rig_pos).dot(arah) - 0.3, 1.2, target)
	var kamera_efektif := rig_pos + arah * batas
	for npc in _npcs:
		if kamera_efektif.distance_to(npc.global_position + Vector3(0, 1.2, 0)) < 0.9:
			batas = minf(batas, 2.0)
	return maxf(1.2, batas)


func _unhandled_input(event: InputEvent) -> void:
	# PINCH-TO-ZOOM v3 (Cakra, 18 Nov 13:13 — koreksi Mas "dicubit
	# enak ngga"): dua jari di layar. Jari merenggang = zoom in
	# (kamera mendekat), merapat = zoom out. Perubahan jarak diubah
	# jadi faktor RELATIF ke modul (bukan set langsung) supaya
	# halus; modul yang me-lerp + menjepit (0,55..1,30).
	# Selama cubit dua jari, drag SATU jari bukan orbit.
	if event is InputEventScreenTouch:
		var sentuh := event as InputEventScreenTouch
		if sentuh.pressed:
			_sentuh[sentuh.index] = sentuh.position
		else:
			_sentuh.erase(sentuh.index)
		if _sentuh.size() < 2:
			_jarak_cubit_lalu = 0.0
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _sentuh.has(drag.index):
			_sentuh[drag.index] = drag.position
		if _sentuh.size() >= 2:
			var titik: Array = _sentuh.values()
			var jarak: float = (titik[0] as Vector2).distance_to(titik[1] as Vector2)
			if _jarak_cubit_lalu > 0.0 and jarak > 0.0:
				_kamera.geser_zoom(_jarak_cubit_lalu / jarak)
			_jarak_cubit_lalu = jarak
			return
		# Orbit kamera dengan drag satu jari (di area 3D, bukan di
		# atas tombol UI).
		_cam_yaw -= drag.relative.x * 0.006
		_cam_pitch = clampf(_cam_pitch - drag.relative.y * 0.005, -1.0, -0.1)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var motion := event as InputEventMouseMotion
		_cam_yaw -= motion.relative.x * 0.006
		_cam_pitch = clampf(_cam_pitch - motion.relative.y * 0.005, -1.0, -0.1)
	elif event is InputEventMagnifyGesture:
		# Cubit trackpad (pengujian desktop): factor > 1 = merenggang.
		_kamera.geser_zoom(1.0 / (event as InputEventMagnifyGesture).factor)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_on_interact()
		elif event.keycode == KEY_C:
			# MODE KAMERA v3: C = ganti mode (siklus).
			_ganti_mode_kamera()


# ---------- misi ----------
func _misi_tersedia(misi: Dictionary) -> bool:
	# Rantai berurutan: misi ke-n terbuka bila semua misi sebelumnya selesai.
	var idx := MissionData.MISSIONS.find(misi)
	if idx <= 0:
		return true
	for j in range(idx):
		if not (String(MissionData.MISSIONS[j]["id"]) in (_save["misi_selesai"] as Array)):
			return false
	return true


func _misi_selesai(id_misi: String) -> bool:
	return id_misi in (_save["misi_selesai"] as Array)


func _misi_aktif_saat_ini() -> Dictionary:
	for m in MissionData.MISSIONS:
		if not _misi_selesai(String(m["id"])):
			return m
	return {}


func _refresh_markers() -> void:
	# RONDE 6 (sistem SATU jalur): cabang "jalur Ngaji Aja" DIHAPUS —
	# semua santri ikut misi berurutan M1->M2->M3.
	for m in MissionData.MISSIONS:
		var id: String = m["id"]
		var node: Node3D = _markers[id]
		var icon: Label3D = node.get_node("Icon")
		var status: Label3D = node.get_node("Status")
		if _misi_selesai(id):
			icon.visible = false
			status.visible = true
			status.text = "SELESAI"
			status.modulate = Color("#2e7d32")
		elif _misi_tersedia(m):
			icon.visible = true
			status.visible = false
		else:
			icon.visible = false
			status.visible = true
			status.text = "TERKUNCI"
			status.modulate = Palette.ABU


func _update_interact_button() -> void:
	if not _ui.is_world_visible():
		_ui.set_interact_visible(false)
		return
	# BACA BUKU (Tara): selagi pembaca terbuka, tombol interaksi
	# disembunyikan — tutup lewat TUTUP / X / Escape / klik-di-luar.
	if _ui.is_baca_buku_visible():
		_ui.set_interact_visible(false)
		return
	# FASE A GELOMBANG 3 (UI misi) — PERBAIKAN TOMBOL ✕ (Raka,
	# 18 Nov 2026, laporan Mas 20:30 WIB: "ga bisa tekan X pas
	# deket"): dekat NPC alur santri baru (Kyai / Ustadzah / Sanusi /
	# Fatimah) tombol ✕ HARUS muncul "MULAI MISI". Sebelumnya cabang
	# ini TIDAK ADA — _misi_terdekat() di bawah hanya mengenal
	# penanda M1-M3 (jarak Kyai ke penanda M1 ~7,9 m > 3,5 m), jadi
	# di dekat Kyai tombol ✕ tidak pernah tampil dan misi pertama
	# tidak bisa dimulai, padahal _on_interact() sudah punya routing
	# dialognya.
	# URUTAN (Tara, 21:12 WIB): cabang misi DI ATAS semua cabang
	# pintu — bayangan pintu Musholla: Mariyah di (134,-17) hanya
	# 0,5 m dari _musholla_exit (134,-17,5) dan radius pintu 2,5 m,
	# jadi bila pintu dicek duluan santriwati selalu dapat "MASUK
	# MUSHOLLA" dan dialog tak pernah terbuka. Misi didahulukan;
	# pintu tetap jalan bila tidak dekat NPC misi (langkah 1/7+,
	# atau menjauh sedikit dari NPC).
	if _dekat_npc_misi():
		# TEKA-TEKI (Raka, 18 Nov 2026): langkah 4, dekat NPC yang
		# bisa ditanya (bukan guru yang dicari) -> tombol ✕ berbunyi
		# "TANYA", bukan "MULAI MISI" — menekan ✕ membuka layar
		# pilihan tanya, bukan Ruang Belajar/dialog.
		if Onboarding.langkah_saat_ini(_save) == 4 and _npc_tanya_terdekat() != null and not _dekat_guru():
			_ui.set_interact_visible(true, "TANYA")
			return
		_ui.set_interact_visible(true, "MULAI MISI")
		return
	# RONDE 4 — prioritas tombol interaksi: pintu surau (masuk/keluar)
	# dulu, lalu misi, lalu smartboard. Pintu penting karena pemain yang
	# berdiri di depan pintu harus bisa masuk tanpa jalan menembus dulu.
	# RONDE 6: pintu cangkruk (masuk/keluar) + lemari (ganti baju) +
	# tempat tidur (tidur) ditambahkan dengan prioritas yang sama.
	# (Sejak 21:12 WIB cabang misi di atas mendahului semua pintu —
	# lihat komentar di atas.)
	if not _di_dalam and _dekat_pintu_luar():
		_ui.set_interact_visible(true, "MASUK SURAU")
		return
	if _di_dalam and _dekat_pintu_dalam():
		_ui.set_interact_visible(true, "KELUAR SURAU")
		return
	if not _di_dalam_musholla and _dekat_pintu_musholla_luar():
		_ui.set_interact_visible(true, "MASUK MUSHOLLA")
		return
	if _di_dalam_musholla and _dekat_pintu_musholla_dalam():
		_ui.set_interact_visible(true, "KELUAR MUSHOLLA")
		return
	if not _di_dalam_cangkruk and _dekat_pintu_cangkruk_luar():
		_ui.set_interact_visible(true, "MASUK CANGKRUK")
		return
	if _di_dalam_cangkruk and _dekat_pintu_cangkruk_dalam():
		_ui.set_interact_visible(true, "KELUAR CANGKRUK")
		return
	# INTERIOR PUTRI (Lestari): pintu 6 gedung putri.
	if not _di_dalam_kelas_putri and _dekat_pintu_kelas_putri_luar():
		_ui.set_interact_visible(true, "MASUK KELAS PUTRI")
		return
	if _di_dalam_kelas_putri and _dekat_pintu_kelas_putri_dalam():
		_ui.set_interact_visible(true, "KELUAR KELAS PUTRI")
		return
	if not _di_dalam_asrama_putri and _dekat_pintu_asrama_putri_luar():
		_ui.set_interact_visible(true, "MASUK ASRAMA PUTRI")
		return
	if _di_dalam_asrama_putri and _tidur_asrama_lebih_dekat():
		_ui.set_interact_visible(true, "TIDUR")
		return
	if _di_dalam_asrama_putri and _dekat_pintu_asrama_putri_dalam():
		_ui.set_interact_visible(true, "KELUAR ASRAMA PUTRI")
		return
	# ASRAMA PUTRA (Lestari): tombol MASUK dijaga root null
	# (jaring pengaman bila build interior gagal).
	if _asrama_putra_root != null and not _di_dalam_asrama_putra and _dekat_pintu_asrama_putra_luar():
		_ui.set_interact_visible(true, "MASUK ASRAMA PUTRA")
		return
	if _di_dalam_asrama_putra and _tidur_asrama_putra_lebih_dekat():
		_ui.set_interact_visible(true, "TIDUR")
		return
	if _di_dalam_asrama_putra and _dekat_pintu_asrama_putra_dalam():
		_ui.set_interact_visible(true, "KELUAR ASRAMA PUTRA")
		return
	if not _di_dalam_kantor and _dekat_pintu_kantor_luar():
		_ui.set_interact_visible(true, "MASUK KANTOR USTADZAH")
		return
	if _di_dalam_kantor and _dekat_pintu_kantor_dalam():
		_ui.set_interact_visible(true, "KELUAR KANTOR USTADZAH")
		return
	if not _di_dalam_madrasah and _dekat_pintu_madrasah_luar():
		_ui.set_interact_visible(true, "MASUK MADRASAH")
		return
	if _di_dalam_madrasah and _dekat_pintu_madrasah_dalam():
		_ui.set_interact_visible(true, "KELUAR MADRASAH")
		return
	if not _di_dalam_studio and _dekat_pintu_studio_luar():
		_ui.set_interact_visible(true, "MASUK STUDIO")
		return
	if _di_dalam_studio and _dekat_pintu_studio_dalam():
		_ui.set_interact_visible(true, "KELUAR STUDIO")
		return
	if not _di_dalam_pos_jaga and _dekat_pintu_pos_jaga_luar():
		_ui.set_interact_visible(true, "MASUK POS JAGA")
		return
	if _di_dalam_pos_jaga and _dekat_pintu_pos_jaga_dalam():
		_ui.set_interact_visible(true, "KELUAR POS JAGA")
		return
	if _di_dalam_cangkruk and _dekat_lemari():
		_ui.set_interact_visible(true, "GANTI BAJU")
		return
	if _di_dalam_cangkruk and _dekat_tempat_tidur():
		_ui.set_interact_visible(true, "TIDUR")
		return
	var dekat := _misi_terdekat()
	if not dekat.is_empty():
		var teks := "BUKA PETI" if bool(dekat.get("peti", false)) else "MULAI MISI"
		_ui.set_interact_visible(true, teks)
		return
	if _di_dalam and _dekat_smartboard():
		_ui.set_interact_visible(true, "LIHAT SMARTBOARD")
		return
	if _dekat_rak():
		_ui.set_interact_visible(true, "BACA KITAB")
		return
	_ui.set_interact_visible(false)


# ---------- pintu Surau: masuk = pindah ke map interior (ala GTA) ----------
# Cara paling andal di codebase ini: SATU scene, interior dibangun jauh
# di (0, 0, -300) + teleport. Tidak ada reload scene, jadi state santri
# (ID, nama, poin, misi) utuh — yang pindah hanya posisi pemain
# + kamera (di-snap supaya tidak terbang melintasi peta).
# Jalan melewati ambang pintu memicu pindah; tombol interaksi adalah
# cadangan (pemain yang berhenti di depan pintu tetap bisa masuk).
## SFX LANGKAH (Sinta): dipanggil tiap signal langkah pemain.
## Di dalam Surau/Musholla/Cangkruk = lantai kayu, di luar = tanah.
func _saat_langkah() -> void:
	_audio.mainkan_langkah(_di_dalam or _di_dalam_musholla or _di_dalam_cangkruk or _di_dalam_kelas_putri or _di_dalam_asrama_putri or _di_dalam_asrama_putra or _di_dalam_kantor or _di_dalam_madrasah or _di_dalam_studio or _di_dalam_pos_jaga)


func _cek_pintu_surau() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam:
		# REVISI (Mas 17 Nov 22:51 WIB: Surau lurus) — KOREKSI
		# 23:15 WIB (lurus = -90°): koridor pintu LUAR dalam FRAME
		# LURUS — u = jarak sepanjang celah (sumbu timur-barat),
		# v = jarak ke DALAM bangunan (normal masuk = utara).
		# Pemicu: |u|<1,2 (celah pintu) dan 0<v<1,5 (zona 1,5 m di
		# dalam cangkang — pemain tidak bisa sampai sini kecuali
		# lewat celah, dinding menahan sisanya).
		var d := p - _outdoor_door
		var u := d.x * _surau_sumbu.x + d.z * _surau_sumbu.z
		var v := d.x * _surau_masuk.x + d.z * _surau_masuk.z
		if absf(u) < 1.2 and v > 0.0 and v < 1.5:
			_masuk_surau()
	else:
		# Koridor pintu DALAM — frame MIRING TETAP (interior -25°,
		# mihrab kiblat 295°; revisi Surau lurus tidak mengubah
		# interior): pintu dalam (0,-294) adalah pivot rotasi
		# interior, posisinya tidak berubah; v diukur ke LUAR
		# ruangan (normal keluar 205°), 0<v<1,5 (zona 1,5 m di
		# dalam ruangan, dekat pintu).
		var d2 := p - _interior_door
		var u2 := d2.x * _surau_sumbu_dalam.x + d2.z * _surau_sumbu_dalam.z
		var v2 := d2.x * _surau_keluar_dalam.x + d2.z * _surau_keluar_dalam.z
		if absf(u2) < 1.2 and v2 > 0.0 and v2 < 1.5:
			_keluar_surau()


func _teleport_player(pos: Vector3, yaw: float) -> void:
	# ASRAMA PUTRI: teleport apa pun mengaktifkan lagi body kasur
	# yang dimatikan saat tidur (teleport melewati _on_aksi — mis.
	# reset posisi / ikut sholat — jadi tanpa ini body bisa tertinggal
	# nonaktif dan kasur bisa ditembus).
	_aktifkan_lagi_kasur_tidur()
	_player.global_position = pos
	_player.velocity = Vector3.ZERO
	_player.set_facing(yaw)
	# RONDE 6: teleport apa pun mengembalikan pose berdiri (supaya
	# pemain tidak nyangkut dalam pose duduk/tidur di tempat baru).
	_player.set_aksi("berdiri")
	# Kamera di-snap (bukan lerp) supaya tidak terbang 300 m melintasi
	# peta saat teleport; kamera di belakang pemain (yaw + PI).
	# Pitch ikut di-reset ke -0,35 (awal) supaya Reset Posisi juga
	# mengembalikan arah pandang vertikal (bukan cuma yaw).
	_cam_yaw = fmod(yaw + PI, TAU)
	_cam_pitch = -0.35
	_rig.global_position = pos + Vector3(0, 1.6, 0)
	_rig.rotation.y = _cam_yaw
	_spring.rotation.x = _cam_pitch


func _masuk_surau() -> void:
	_di_dalam = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(true, false)
	_set_sandal_ruangan(true)
	_teleport_player(_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Surau. Selamat mengaji!")


func _keluar_surau() -> void:
	_di_dalam = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_outdoor_exit, 0.0)
	_ui.toast("Kamu keluar dari Surau.")


# ---------- pintu Musholla (RONDE PERBAIKAN, integrasi item 7f) ----------
# Cermin _cek_pintu_surau — bedanya: shell Musholla TIDAK diputar
# (rotasi 0°), jadi koridor LUAR cukup sumbu dunia; koridor DALAM
# memakai frame interior (SUMBU/KELUAR dari InteriorMusholla).
# Pemicu luar HARUS di luar dinding (z -19..-17,5): pemain di-teleport
# SEBELUM masuk shell (134,-24) — shell itu kosong (lantai biru
# polos), interior yang benar ada di map terpisah (60,-301).
func _cek_pintu_musholla() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_musholla:
		if absf(p.x - _musholla_exit.x) < 1.0 and p.z > -19.0 and p.z < -17.5:
			_masuk_musholla()
	else:
		var d2 := p - _musholla_door
		var u2 := d2.x * InteriorMusholla.SUMBU.x + d2.z * InteriorMusholla.SUMBU.z
		var v2 := d2.x * InteriorMusholla.KELUAR.x + d2.z * InteriorMusholla.KELUAR.z
		if absf(u2) < 1.2 and v2 > 0.0 and v2 < 1.5:
			_keluar_musholla()


func _masuk_musholla() -> void:
	_di_dalam_musholla = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_musholla_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Musholla. Selamat mengaji!")


func _keluar_musholla() -> void:
	_di_dalam_musholla = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_musholla_exit, 0.0)
	_ui.toast("Kamu keluar dari Musholla.")


# ---------- pintu gedung putri (INTERIOR PUTRI, Lestari 18 Nov 2026) ----------
# Cermin _cek_pintu_musholla: pemicu LUAR di luar dinding cangkang
# (teleport SEBELUM masuk cangkang kosong); koridor DALAM di pintu
# interior (z=-300). Frame DALAM per gedung: pintu barat = sumbu
# (0,0,1) + keluar (-1,0,0); pintu selatan = sumbu (1,0,0) +
# keluar (0,0,1); pintu utara = sumbu (1,0,0) + keluar (0,0,-1).
func _cek_pintu_kelas_putri() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_kelas_putri:
		if absf(p.x - _kelas_putri_door.x) < 1.0 and p.z > _kelas_putri_door.z and p.z < _kelas_putri_exit.z:
			_masuk_kelas_putri()
	else:
		var d2 := p - _kelas_putri_interior_door
		if absf(d2.x) < 1.2 and d2.z > 0.0 and d2.z < 1.5:
			_keluar_kelas_putri()


func _masuk_kelas_putri() -> void:
	_di_dalam_kelas_putri = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_kelas_putri_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Kelas Putri. Selamat belajar!")


func _keluar_kelas_putri() -> void:
	_di_dalam_kelas_putri = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_kelas_putri_exit, 0.0)
	_ui.toast("Kamu keluar dari Kelas Putri.")


func _cek_pintu_asrama_putri() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_asrama_putri:
		if absf(p.z - _asrama_putri_door_luar.z) < 1.0 and p.x > _asrama_putri_exit.x and p.x < _asrama_putri_door_luar.x:
			_masuk_asrama_putri()
	else:
		var d2 := p - _asrama_putri_interior_door
		if absf(d2.z) < 1.2 and -d2.x > 0.0 and -d2.x < 1.5:
			_keluar_asrama_putri()


func _masuk_asrama_putri() -> void:
	_di_dalam_asrama_putri = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_asrama_putri_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Asrama Putri.")


func _keluar_asrama_putri() -> void:
	_di_dalam_asrama_putri = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_asrama_putri_exit, 0.0)
	_ui.toast("Kamu keluar dari Asrama Putri.")


# ---------- pintu Asrama Putra (Lestari, 18 Nov 2026) ----------
# Cermin _cek_pintu_asrama_putri: pintu LUAR di dinding barat
# cangkang (-33,10), keluar (-34,5,10); pintu DALAM di dinding
# barat interior (dari dict build Nadia). Dijaga root null
# (jaring pengaman bila build interior gagal — jangan teleport
# ke map yang tidak ada).
func _cek_pintu_asrama_putra() -> void:
	if not _ui.is_world_visible():
		return
	if _asrama_putra_root == null:
		return
	var p := _player.global_position
	if not _di_dalam_asrama_putra:
		if absf(p.z - _asrama_putra_door_luar.z) < 1.0 and p.x > _asrama_putra_exit.x and p.x < _asrama_putra_door_luar.x:
			_masuk_asrama_putra()
	else:
		var d2 := p - _asrama_putra_interior_door
		if absf(d2.z) < 1.2 and -d2.x > 0.0 and -d2.x < 1.5:
			_keluar_asrama_putra()


func _masuk_asrama_putra() -> void:
	if _asrama_putra_root == null:
		_ui.toast("Asrama Putra masih dibangun.")
		return
	_di_dalam_asrama_putra = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, false, false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_asrama_putra_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Asrama Putra.")


func _keluar_asrama_putra() -> void:
	_di_dalam_asrama_putra = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_asrama_putra_exit, 0.0)
	_ui.toast("Kamu keluar dari Asrama Putra.")


func _cek_pintu_kantor() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_kantor:
		if absf(p.z - _kantor_door_luar.z) < 1.0 and p.x > _kantor_exit.x and p.x < _kantor_door_luar.x:
			_masuk_kantor()
	else:
		var d2 := p - _kantor_interior_door
		if absf(d2.z) < 1.2 and -d2.x > 0.0 and -d2.x < 1.5:
			_keluar_kantor()


func _masuk_kantor() -> void:
	_di_dalam_kantor = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_kantor_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Kantor Ustadzah.")


func _keluar_kantor() -> void:
	_di_dalam_kantor = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_kantor_exit, 0.0)
	_ui.toast("Kamu keluar dari Kantor Ustadzah.")


func _cek_pintu_madrasah() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_madrasah:
		if absf(p.z - _madrasah_door_luar.z) < 1.0 and p.x > _madrasah_exit.x and p.x < _madrasah_door_luar.x:
			_masuk_madrasah()
	else:
		var d2 := p - _madrasah_interior_door
		if absf(d2.z) < 1.2 and -d2.x > 0.0 and -d2.x < 1.5:
			_keluar_madrasah()


func _masuk_madrasah() -> void:
	_di_dalam_madrasah = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_madrasah_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Madrasah.")


func _keluar_madrasah() -> void:
	_di_dalam_madrasah = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_madrasah_exit, 0.0)
	_ui.toast("Kamu keluar dari Madrasah.")


func _cek_pintu_studio() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_studio:
		if absf(p.x - _studio_door_luar.x) < 1.0 and p.z > _studio_exit.z and p.z < _studio_door_luar.z:
			_masuk_studio()
	else:
		var d2 := p - _studio_interior_door
		if absf(d2.x) < 1.2 and -d2.z > 0.0 and -d2.z < 1.5:
			_keluar_studio()


func _masuk_studio() -> void:
	_di_dalam_studio = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_studio_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Studio.")


func _keluar_studio() -> void:
	_di_dalam_studio = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_studio_exit, 0.0)
	_ui.toast("Kamu keluar dari Studio.")


func _cek_pintu_pos_jaga() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_pos_jaga:
		if absf(p.z - _pos_jaga_door_luar.z) < 1.0 and p.x > _pos_jaga_exit.x and p.x < _pos_jaga_door_luar.x:
			_masuk_pos_jaga()
	else:
		var d2 := p - _pos_jaga_interior_door
		if absf(d2.z) < 1.2 and -d2.x > 0.0 and -d2.x < 1.5:
			_keluar_pos_jaga()


func _masuk_pos_jaga() -> void:
	_di_dalam_pos_jaga = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, false, false, false, false, false, false, false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_pos_jaga_interior_spawn, PI)
	_ui.toast("Kamu masuk ke dalam Pos Jaga.")


func _keluar_pos_jaga() -> void:
	_di_dalam_pos_jaga = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_pos_jaga_exit, 0.0)
	_ui.toast("Kamu keluar dari Pos Jaga.")


# ---------- kamar cangkruk (RONDE 6): pintu + transisi interior ----------
func _cek_pintu_cangkruk() -> void:
	if not _ui.is_world_visible():
		return
	var p := _player.global_position
	if not _di_dalam_cangkruk:
		# Koridor pintu luar cangkruk: |x - pintu.x| < 0.8 (celah
		# pintu 1.6 m), z melewati bidang pintu (zona 1.5 m di dalam
		# cangkang). RONDE 20: pintu PINDAH (14,-10) -> (-12,-8) —
		# dibaca dari _cangkruk_door (builder), JANGAN hardcode.
		if absf(p.x - _cangkruk_door.x) < 0.8 and p.z < _cangkruk_door.z and p.z > _cangkruk_door.z - 1.5:
			_masuk_cangkruk()
	elif absf(p.x + 60.0) < 0.8 and p.z > -295.0 and p.z < -293.5:
		_keluar_cangkruk()


## RONDE 21 — penegakan batas putra/putri KERAS (Mas, pakem):
## tembok pemisah solid di x=14 (z -60..+16) menggantikan pagar
## kayu Ronde 20; gerbang (14,0) TERTUTUP + barrier collision penuh
## di builder. Pemain yang masuk zona larangan mendapat toast
## peringatan (dibatasi 1x per 4 detik) DAN didorong balik ke posisi
## legal terakhir. Selatan (z >= _batas_z_selatan) kawasan bersama.
## Hanya di luar ruangan. Hanya berlaku untuk PEMAIN — NPC tidak
## lewat sini (npc.gd jalan lurus tanpa collision; lihat catatan
## segmen waypoint di _spawn_npcs + laporan Ronde 21 ke Raka).
## _jarak_ke_pagar DIHAPUS: aturan keras tidak lagi menghitung jarak
## ke polyline pagar (PAGAR_GARIS dihapus Raka saat merge).
func _cek_batas(delta: float) -> void:
	_batas_toast_timer = maxf(0.0, _batas_toast_timer - delta)
	if not _ui.is_world_visible() or _di_dalam or _di_dalam_cangkruk or _di_dalam_musholla or _di_dalam_kelas_putri or _di_dalam_asrama_putri or _di_dalam_asrama_putra or _di_dalam_kantor or _di_dalam_madrasah or _di_dalam_studio or _di_dalam_pos_jaga:
		return
	# Pengasuh + musyrif/musyrifah + Keamanan boleh lewat.
	if _pemain_boleh_lewat_batas():
		return
	var p := _player.global_position
	var putri := _pemain_adalah_putri()
	# Zona larangan: putra dilarang x > tembok saat z < batas selatan;
	# santriwati cerminnya (x < tembok). Tanpa batas z_min: aturan
	# ini JUGA menutup celah putar lewat ujung utara tembok (z<-60)
	# yang ditemukan Mas — lewat ujung utara tetap didorong balik.
	var melanggar := false
	if putri:
		melanggar = p.x < _tembok_x and p.z < _batas_z_selatan
	else:
		melanggar = p.x > _tembok_x and p.z < _batas_z_selatan
	if melanggar:
		if _batas_toast_timer <= 0.0:
			_batas_toast_timer = 4.0
			_batas_toast_count += 1
			if putri:
				_ui.toast("Santriwati tidak boleh masuk area putra.")
			else:
				_ui.toast("Santri putra tidak boleh masuk area putri.")
			if _mp_validasi_klien_mati:
				# Dibatasi timer toast (1x/4 dtk) supaya log tes zona
				# tidak dibanjiri tiap frame.
				print("[MP-TEST] pelanggaran zona (validasi klien MATI): pos=%s — menunggu zone_reject server" % str(p))
		if _mp_validasi_klien_mati:
			# TES HEADLESS --mp-test-zona: validasi klien SENGAJA
			# dimatikan — penolakan HARUS datang dari server
			# (zone_reject -> _mp_terapkan_zone_reject). Jangan
			# snap-back di sini, jangan catat posisi ini legal.
			return
		if _punya_pos_legal:
			_player.global_position = _pos_legal_terakhir
			_player.velocity = Vector3.ZERO
		return
	# RONDE PERBAIKAN (Eka) — AKAR MASALAH GERBANG (7x gagal di kelas
	# ini): tembok FISIK (BarrierGerbang + segmen tembok, builder)
	# menahan kapsul pemain di x≈13,45 — syarat "x > 14" di atas
	# TIDAK PERNAH terpicu, jadi toast + dorong balik tidak pernah
	# jalan walau pemain mendorong tembok 73 detik (probe ronde
	# perbaikan: x mentok 13,449, toast_count tetap 0). Penegakan kini
	# PROKSIMITAS: pemain yang MENEMPEL tembok (jarak < 0,6 m) DAN
	# MENEKAN ke arahnya (move_dir ke tembok) mendapat toast +
	# didorong balik 1,5 m. Berlaku di sepanjang tembok (z -60..16),
	# bukan cuma di gerbang; kawasan bersama selatan (z >= 16) bebas.
	var tekan_tembok := false
	var dorong_x := 0.0
	if putri:
		if p.x > _tembok_x and p.x < _tembok_x + 0.6 and p.z >= _tembok_z_min and p.z < _batas_z_selatan and _player.move_dir.x < -0.05:
			tekan_tembok = true
			dorong_x = _tembok_x + 1.5
	else:
		if p.x < _tembok_x and p.x > _tembok_x - 0.6 and p.z >= _tembok_z_min and p.z < _batas_z_selatan and _player.move_dir.x > 0.05:
			tekan_tembok = true
			dorong_x = _tembok_x - 1.5
	if tekan_tembok:
		if _batas_toast_timer <= 0.0:
			_batas_toast_timer = 4.0
			_batas_toast_count += 1
			if putri:
				_ui.toast("Santriwati tidak boleh masuk area putra.")
			else:
				_ui.toast("Santri putra tidak boleh masuk area putri.")
		_player.global_position = Vector3(dorong_x, p.y, p.z)
		_player.velocity = Vector3.ZERO
		_pos_legal_terakhir = _player.global_position
		_punya_pos_legal = true
		return
	# Posisi legal — catat tiap frame sebagai jangkar dorong-balik.
	_pos_legal_terakhir = p
	_punya_pos_legal = true


## RONDE 21 — gender pemain. Kunci save "jenis_kelamin" ("putra" /
## "putri") ditulis login server (_terapkan_login_server, dari field
## jenis_kelamin API) — default "putra" bila field belum ada. Cabang
## santriwati di _cek_batas + spawn putri aktif sendiri begitu kunci
## itu tertulis. Visual santriwati (abaya + jilbab) BELUM: karakter
## masih santriwan sampai Tim Karakter membangunnya (warna abaya
## belum diputuskan Mas) — login ini hanya mengatur spawn + aturan.
func _pemain_adalah_putri() -> bool:
	return String(_save.get("jenis_kelamin", "putra")) == "putri"


## RONDE 21 — pengecualian batas: Pengasuh + musyrif/musyrifah +
## Keamanan boleh lewat tembok. TEMUAN (laporan ke Raka): TIDAK ADA
## flag role pemain di mana pun (save maupun main.gd). Pengecekan
## keyed pada kunci save "role" — AKTIF SENDIRI begitu registrasi/
## server menulis role itu ("pengasuh" / "musyrif" / "musyrifah" /
## "keamanan"). Default "santri" = aturan berlaku penuh.
func _pemain_boleh_lewat_batas() -> bool:
	return String(_save.get("role", "santri")) in ["pengasuh", "musyrif", "musyrifah", "keamanan"]


## RONDE 20 — sandal di depan pintu Surau/Musholla: terlihat kalau
## ada yang di dalam ruangan itu (pemain di Surau, Kyai di Surau,
## Ustadzah di Musholla). Disinkron tiap frame supaya sandal Kyai/
## Ustadzah tidak tertutup logika sandal pemain (_set_sandal_ruangan
## hanya mengatur sandal pemain + cangkruk).
func _sinkron_sandal() -> void:
	if _sandal_luar_surau != null:
		_sandal_luar_surau.visible = _di_dalam or (_kyai != null and _kyai.di_dalam())
	if _sandal_luar_musholla != null:
		_sandal_luar_musholla.visible = _di_dalam_musholla or (_ustadzah != null and _ustadzah.di_dalam())


func _masuk_cangkruk() -> void:
	_di_dalam_cangkruk = true
	_audio.mainkan_pintu(true)
	_set_interior_terlihat(false, true)
	_set_sandal_ruangan(true)
	_teleport_player(_cangkruk_interior_spawn, PI)
	_ui.toast("Kamu masuk ke kamar cangkruk. Sandal dilepas di depan pintu.")


func _keluar_cangkruk() -> void:
	_di_dalam_cangkruk = false
	_audio.mainkan_pintu(false)
	_set_interior_terlihat(false, false)
	_set_sandal_ruangan(false)
	_teleport_player(_cangkruk_exit, 0.0)
	_ui.toast("Kamu keluar dari kamar cangkruk.")


## Tampilkan/sembunyikan interior saat pemain masuk/keluar ruangan.
## RONDE 6 (perbaikan DOUBLE SURAU): kedua interior DISEMBUNYIKAN saat
## pemain di luar — ruangan interior (18x14 m di z=-300) sebelumnya
## terlihat dari spawn sebagai bangunan kedua.
## RONDE 20: interior KETIGA (musholla, x=60) — parameter ketiga,
## default false (pemain putra tidak pernah masuk).
## INTERIOR PUTRI (Lestari): parameter ke-4..9 = asrama_putri,
## kelas_putri, kantor, madrasah, studio, pos_jaga (urutan ini —
## posisi, BUKAN nama: GDScript tidak punya keyword argument).
## ASRAMA PUTRA (Lestari): parameter ke-10 = asrama_putra —
## ditambahkan DI AKHIR supaya semua panggilan lama (posisi 1..9)
## tidak bergeser.
func _set_interior_terlihat(surau: bool, cangkruk: bool, musholla: bool = false, asrama_putri: bool = false, kelas_putri: bool = false, kantor: bool = false, madrasah: bool = false, studio: bool = false, pos_jaga: bool = false, asrama_putra: bool = false) -> void:
	if _interior_root != null:
		_interior_root.visible = surau
	if _cangkruk_root != null:
		_cangkruk_root.visible = cangkruk
	if _musholla_root != null:
		_musholla_root.visible = musholla
	if _asrama_putri_root != null:
		_asrama_putri_root.visible = asrama_putri
	if _kelas_putri_root != null:
		_kelas_putri_root.visible = kelas_putri
	if _kantor_root != null:
		_kantor_root.visible = kantor
	if _madrasah_root != null:
		_madrasah_root.visible = madrasah
	if _studio_root != null:
		_studio_root.visible = studio
	if _pos_jaga_root != null:
		_pos_jaga_root.visible = pos_jaga
	if _asrama_putra_root != null:
		_asrama_putra_root.visible = asrama_putra


## Sandal otomatis lepas saat masuk ruangan (Surau/cangkruk) dan
## dipakai lagi saat keluar. Sandal yang dilepas terlihat di depan
## pintu ruangan yang dimasuki (SandalLuarSurau / SandalLuarCangkruk).
## RONDE 20: sandal Surau + Musholla diatur _sinkron_sandal() tiap
## frame (tergantung pemain + Kyai/Ustadzah yang di dalam) — di sini
## hanya sandal pemain + sandal cangkruk.
func _set_sandal_ruangan(masuk_ruangan: bool) -> void:
	if masuk_ruangan:
		_player.set_sandal(false)
		if _di_dalam_cangkruk and _sandal_luar_cangkruk != null:
			_sandal_luar_cangkruk.visible = true
	else:
		_player.set_sandal(true)
		if _sandal_luar_cangkruk != null:
			_sandal_luar_cangkruk.visible = false


func _dekat_pintu_luar() -> bool:
	return _player.global_position.distance_to(_outdoor_door) < 2.5


func _dekat_pintu_dalam() -> bool:
	return _player.global_position.distance_to(_interior_door) < 2.5


## RONDE PERBAIKAN (integrasi item 7f): dekat pintu Musholla —
## luar = titik keluar (134,-17,5), dalam = pintu interior (60,-296).
func _dekat_pintu_musholla_luar() -> bool:
	return _player.global_position.distance_to(_musholla_exit) < 2.5


func _dekat_pintu_musholla_dalam() -> bool:
	return _player.global_position.distance_to(_musholla_door) < 2.5


func _dekat_pintu_cangkruk_luar() -> bool:
	return _player.global_position.distance_to(_cangkruk_door) < 2.5


func _dekat_pintu_cangkruk_dalam() -> bool:
	return _player.global_position.distance_to(_cangkruk_interior_door) < 2.5


## INTERIOR PUTRI (Lestari): dekat pintu — luar = titik keluar,
## dalam = pintu interior (pola Musholla di atas).
func _dekat_pintu_kelas_putri_luar() -> bool:
	return _player.global_position.distance_to(_kelas_putri_exit) < 2.5


func _dekat_pintu_kelas_putri_dalam() -> bool:
	return _player.global_position.distance_to(_kelas_putri_interior_door) < 2.5


func _dekat_pintu_asrama_putri_luar() -> bool:
	return _player.global_position.distance_to(_asrama_putri_exit) < 2.5


func _dekat_pintu_asrama_putri_dalam() -> bool:
	return _player.global_position.distance_to(_asrama_putri_interior_door) < 2.5


## ASRAMA PUTRA (Lestari): dekat pintu — luar = titik keluar,
## dalam = pintu interior (pola Asrama Putri di atas).
func _dekat_pintu_asrama_putra_luar() -> bool:
	return _player.global_position.distance_to(_asrama_putra_exit) < 2.5


func _dekat_pintu_asrama_putra_dalam() -> bool:
	return _player.global_position.distance_to(_asrama_putra_interior_door) < 2.5


func _dekat_pintu_kantor_luar() -> bool:
	return _player.global_position.distance_to(_kantor_exit) < 2.5


func _dekat_pintu_kantor_dalam() -> bool:
	return _player.global_position.distance_to(_kantor_interior_door) < 2.5


func _dekat_pintu_madrasah_luar() -> bool:
	return _player.global_position.distance_to(_madrasah_exit) < 2.5


func _dekat_pintu_madrasah_dalam() -> bool:
	return _player.global_position.distance_to(_madrasah_interior_door) < 2.5


func _dekat_pintu_studio_luar() -> bool:
	return _player.global_position.distance_to(_studio_exit) < 2.5


func _dekat_pintu_studio_dalam() -> bool:
	return _player.global_position.distance_to(_studio_interior_door) < 2.5


func _dekat_pintu_pos_jaga_luar() -> bool:
	return _player.global_position.distance_to(_pos_jaga_exit) < 2.5


func _dekat_pintu_pos_jaga_dalam() -> bool:
	return _player.global_position.distance_to(_pos_jaga_interior_door) < 2.5


func _dekat_lemari() -> bool:
	return _player.global_position.distance_to(_cangkruk_lemari) < 2.5


func _dekat_tempat_tidur() -> bool:
	# ASRAMA PUTRI (Lestari): kasur sendiri = posisi tidur dari
	# posisi_tidur_list() Asrama — BUKAN titik Musholla di ledger
	# (itu fallback lantai untuk santri yang kasur fisiknya belum
	# ada; santri Asrama tidur di kasurnya sendiri). Santri dengan
	# tugas BUKAN Asrama (mis. overflow Musholla) tidak boleh tidur
	# di sini; save lama tanpa tugas = kasur mana saja (pola lama).
	if _di_dalam_asrama_putri:
		var idx := _idx_kasur_asrama_tidur()
		if idx <= 0:
			return false
		return _player.global_position.distance_to(_asrama_putri_beds[idx - 1]) < 2.5
	# ASRAMA PUTRA (Lestari): sama seperti Putri (kasur sendiri
	# A-PUTRA-001..096 dari posisi_tidur_list() Asrama Putra).
	if _di_dalam_asrama_putra:
		var idx_p := _idx_kasur_asrama_putra_tidur()
		if idx_p <= 0:
			return false
		return _player.global_position.distance_to(_asrama_putra_beds[idx_p - 1]) < 2.5
	# RONDE 6 revisi 23:01 WIB: 5 kasur — dekat kalau dalam 2,5 m
	# dari kasur MANA SAJA.
	# KASUR (Wulan): 1 kasur = 1 santri — pemain dengan kasur fisik
	# HANYA boleh tidur di kasur SENDIRI (bukan kasur santri lain);
	# pemain tanpa kasur fisik hanya di titik tugasnya (Surau /
	# Musholla). Save lama tanpa tugas kasur = perilaku lama (kasur
	# mana saja) supaya tidak terkunci.
	if not _kasur_saya.is_empty():
		var milik := PembagianKasur.posisi_tidur(_kasur_saya)
		if milik != Vector3.INF:
			return _player.global_position.distance_to(milik) < 2.5
		return false
	for b in _cangkruk_beds:
		if _player.global_position.distance_to(b) < 2.5:
			return true
	return false


## TIDUR ASRAMA (Lestari): idx kasur (1..96) yang boleh ditiduri
## pemain di Asrama Putri. Tugas sendiri (A-PUTRI-001..096 dari
## _kasur_saya) bila ada; save lama tanpa tugas = kasur terdekat
## (pola Cangkruk lama). 0 = tidak boleh tidur di sini (tugasnya
## bukan kasur Asrama — mis. overflow Musholla).
func _idx_kasur_asrama_tidur() -> int:
	if not _kasur_saya.is_empty():
		var kid := String(_kasur_saya.get("kasur_id", ""))
		if kid.begins_with("A-PUTRI-"):
			var idx := int(kid.trim_prefix("A-PUTRI-"))
			if idx >= 1 and idx <= 96:
				return idx
		return 0
	var best := 0
	var best_d := 1e9
	for i in range(_asrama_putri_beds.size()):
		var d := _player.global_position.distance_to(_asrama_putri_beds[i])
		if d < best_d:
			best_d = d
			best = i + 1
	return best


## TIDUR ASRAMA PUTRA (Lestari): idx kasur (1..96) yang boleh
## ditiduri pemain di Asrama Putra — cermin _idx_kasur_asrama_tidur
## (tugas sendiri A-PUTRA-001..096; save lama tanpa tugas = kasur
## terdekat; 0 = tugasnya bukan kasur Asrama, mis. overflow Surau).
func _idx_kasur_asrama_putra_tidur() -> int:
	if not _kasur_saya.is_empty():
		var kid := String(_kasur_saya.get("kasur_id", ""))
		if kid.begins_with("A-PUTRA-"):
			var idx := int(kid.trim_prefix("A-PUTRA-"))
			if idx >= 1 and idx <= 96:
				return idx
		return 0
	var best := 0
	var best_d := 1e9
	for i in range(_asrama_putra_beds.size()):
		var d := _player.global_position.distance_to(_asrama_putra_beds[i])
		if d < best_d:
			best_d = d
			best = i + 1
	return best


## ASRAMA PUTRA (Lestari): prioritas TIDUR vs KELUAR — cermin
## _tidur_asrama_lebih_dekat (yang lebih dekat yang menang, jarak
## HORIZONTAL (x,z): kasur atas tidak boleh kalah karena tingginya).
func _tidur_asrama_putra_lebih_dekat() -> bool:
	if not _di_dalam_asrama_putra or not _dekat_tempat_tidur():
		return false
	var idx := _idx_kasur_asrama_putra_tidur()
	if idx <= 0:
		return false
	var pp := _player.global_position
	var bed: Vector3 = _asrama_putra_beds[idx - 1]
	var j_bed := Vector2(pp.x - bed.x, pp.z - bed.z).length()
	var j_pintu := Vector2(pp.x - _asrama_putra_interior_door.x, pp.z - _asrama_putra_interior_door.z).length()
	return j_bed < j_pintu


## INTERIOR PUTRI (Lestari): di Asrama, tombol KELUAR (dicek dulu,
## pola lama) bisa menutupi TIDUR bila pemain berdiri dekat pintu —
## karena itu yang lebih dekat yang menang (jarak HORIZONTAL (x,z):
## kasur atas (y 1,65) tidak boleh kalah hanya karena tingginya).
## KOREKSI 18 Nov 2026 (perbesaran Nadia tapak 18x12): posisi tidur
## terdekat kini 3,94 m dari pintu dalam (dulu <2,5 m) — kasur
## barat-laut 001 di (-247,8,-303,75) vs pintu (-249,-300) — jadi
## zona tumpang-tindihnya menyusut, tapi aturan prioritas tetap
## dipertahankan (berdiri TEPAT di kasur sendiri -> TIDUR menang).
func _tidur_asrama_lebih_dekat() -> bool:
	if not _di_dalam_asrama_putri or not _dekat_tempat_tidur():
		return false
	var idx := _idx_kasur_asrama_tidur()
	if idx <= 0:
		return false
	var pp := _player.global_position
	var bed: Vector3 = _asrama_putri_beds[idx - 1]
	var j_bed := Vector2(pp.x - bed.x, pp.z - bed.z).length()
	var j_pintu := Vector2(pp.x - _asrama_putri_interior_door.x, pp.z - _asrama_putri_interior_door.z).length()
	return j_bed < j_pintu


## Aktifkan lagi body kasur Asrama yang dimatikan saat tidur (Rani:
## kapsul TIDAK BOLEH di-snap ke dalam collision kasur — body
## dimatikan dulu, diaktifkan lagi saat bangun). Aman dipanggil
## kapan saja (no-op bila tidak ada yang dimatikan). Pulihkan juga
## tinggi kapsul bila dikecilkan untuk kasur atas.
func _aktifkan_lagi_kasur_tidur() -> void:
	if _kasur_tidur_kapsul_dikecilkan:
		_player_capsule.set_deferred("height", 1.7)
		_kasur_tidur_kapsul_dikecilkan = false
	if _kasur_tidur_body != null:
		_kasur_tidur_body.set_deferred("collision_layer", _kasur_tidur_layer)
		_kasur_tidur_body.set_deferred("collision_mask", _kasur_tidur_mask)
		_kasur_tidur_body = null
		_kasur_tidur_idx = 0


## KASUR (Wulan): posisi tidur tugas pemain ini — titik Surau /
## Musholla untuk santri yang kasur fisiknya belum ada (Cangkruk
## tingkat atas / Asrama / Cangkruk Putri). Vector3.INF bila pemain
## punya kasur fisik (tidur di kasur sendiri) atau belum ada tugas.
func _tempat_tidur_tugas() -> Vector3:
	if _kasur_saya.is_empty():
		return Vector3.INF
	if bool(_kasur_saya.get("fisik", false)):
		return Vector3.INF
	return PembagianKasur.posisi_tidur(_kasur_saya)


## Kasur terdekat dari pemain (untuk snap saat tidur).
func _kasur_terdekat() -> Vector3:
	# KASUR (Wulan): di Surau/Musholla, snap ke titik tugas sendiri
	# (bukan kasur Cangkruk yang jaraknya lintas map).
	if not _di_dalam_cangkruk and (_di_dalam or _di_dalam_musholla):
		var tugas := _tempat_tidur_tugas()
		if tugas != Vector3.INF:
			return tugas
	if _kasur_saya.is_empty():
		var best: Vector3 = _cangkruk_beds[0] if not _cangkruk_beds.is_empty() else Vector3.ZERO
		var best_d := 1e9
		for b in _cangkruk_beds:
			var d := _player.global_position.distance_to(b)
			if d < best_d:
				best_d = d
				best = b
		return best
	# Kasur sendiri (fisik) — satu-satunya yang boleh ditiduri.
	var milik := PembagianKasur.posisi_tidur(_kasur_saya)
	return milik if milik != Vector3.INF else Vector3.ZERO


func _dekat_smartboard() -> bool:
	return _player.global_position.distance_to(_smartboard_spot) < 3.5


## BACA BUKU (Tara): pemain dekat salah satu rak kitab (Surau x2 +
## Musholla x1 + Kelas Putri x2) — hanya di dalam ruangan yang
## bersangkutan, supaya titik interior tidak terpicu dari peta luar.
func _dekat_rak() -> bool:
	if not (_di_dalam or _di_dalam_musholla or _di_dalam_kelas_putri):
		return false
	for spot in _rak_spots:
		if _player.global_position.distance_to(spot) < 3.0:
			return true
	return false


func _misi_terdekat() -> Dictionary:
	# RONDE 6 (sistem SATU jalur): tidak ada lagi pengembalian {} untuk
	# "jalur Ngaji Aja" — semua santri ikut misi berurutan.
	var best := {}
	var best_d := CHAT_JARAK_INTERAKSI
	for m in MissionData.MISSIONS:
		if _misi_selesai(String(m["id"])):
			continue
		if not _misi_tersedia(m):
			continue
		var pos: Vector3 = m["penanda"]
		var d := _player.global_position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = m
	return best


func _di_dalam_surau() -> bool:
	# RONDE 4: "di dalam surau" = pemain sedang di map interior
	# (flag _di_dalam, diset tepat saat teleport masuk/keluar).
	return _di_dalam


## MODE KAMERA v3 (Cakra, 18 Nov 13:13): ganti mode (siklus
## NORMAL -> DRONE -> LOW -> HIGH -> SINEMATIK -> NORMAL),
## sinkronkan label tombol HUD + beri tahu pemain lewat toast.
func _ganti_mode_kamera() -> void:
	_kamera.mode_berikut()
	_ui.set_mode_kamera(_kamera.nama_mode())
	_ui.toast("Kamera: " + _kamera.nama_mode())


func _on_interact() -> void:
	# FASE A GELOMBANG 3 (UI misi): panel misi sedang terbuka ->
	# tutup dulu (toggle, seperti panel misi/smartboard/baca).
	if _manajer_misi != null and _manajer_misi.ada_panel_terbuka():
		_manajer_misi.tutup_semua()
		return
	# Toggle: panel misi / smartboard / baca buku sedang terbuka ->
	# tutup dulu.
	if _ui.is_mission_visible():
		_ui.close_mission()
		return
	if _ui.is_smartboard_visible():
		_ui.close_smartboard()
		return
	if _ui.is_baca_buku_visible():
		_ui.close_baca_buku()
		return
	# FASE A GELOMBANG 3 (UI misi, §1A): alur santri baru didahulukan
	# atas kuis misi M1-M3 — dialog dulu, baru cari Sanusi, baru
	# belajar, baru tes.
	# URUTAN (Tara, 21:12 WIB): cabang misi DI ATAS semua cabang
	# pintu — bayangan pintu Musholla: Mariyah di (134,-17) hanya
	# 0,5 m dari _musholla_exit (134,-17,5) dan radius pintu 2,5 m,
	# jadi bila pintu dicek duluan santriwati selalu masuk Musholla
	# dan dialog tak pernah terbuka. Misi didahulukan; pintu tetap
	# jalan bila tidak dekat NPC misi.
	if _buka_ui_misi_terdekat():
		return
	# Pintu Surau (cadangan tombol — jalan menembus pintu juga bisa).
	if not _di_dalam and _dekat_pintu_luar():
		_masuk_surau()
		return
	if _di_dalam and _dekat_pintu_dalam():
		_keluar_surau()
		return
	# RONDE PERBAIKAN (integrasi item 7f): pintu Musholla (cadangan
	# tombol — jalan menembus pintu juga bisa).
	if not _di_dalam_musholla and _dekat_pintu_musholla_luar():
		_masuk_musholla()
		return
	if _di_dalam_musholla and _dekat_pintu_musholla_dalam():
		_keluar_musholla()
		return
	# RONDE 6: pintu cangkruk (masuk/keluar) + lemari (ganti baju) +
	# tempat tidur (tidur). Lemari/tidur dicek sebelum misi/smartboard
	# karena hanya ada di dalam cangkruk.
	if not _di_dalam_cangkruk and _dekat_pintu_cangkruk_luar():
		_masuk_cangkruk()
		return
	if _di_dalam_cangkruk and _dekat_pintu_cangkruk_dalam():
		_keluar_cangkruk()
		return
	if _di_dalam_cangkruk and _dekat_lemari():
		_ui.open_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))
		return
	if _di_dalam_cangkruk and _dekat_tempat_tidur():
		_on_aksi("tidur")
		return
	# INTERIOR PUTRI (Lestari): pintu 6 gedung putri (cadangan tombol
	# — jalan menembus pintu juga bisa) + tidur di Asrama Putri.
	if not _di_dalam_kelas_putri and _dekat_pintu_kelas_putri_luar():
		_masuk_kelas_putri()
		return
	if _di_dalam_kelas_putri and _dekat_pintu_kelas_putri_dalam():
		_keluar_kelas_putri()
		return
	if not _di_dalam_asrama_putri and _dekat_pintu_asrama_putri_luar():
		_masuk_asrama_putri()
		return
	if _di_dalam_asrama_putri and _tidur_asrama_lebih_dekat():
		_on_aksi("tidur")
		return
	if _di_dalam_asrama_putri and _dekat_pintu_asrama_putri_dalam():
		_keluar_asrama_putri()
		return
	# ASRAMA PUTRA (Lestari): pintu + tidur Asrama Putra (cadangan
	# tombol — jalan menembus pintu juga bisa). Dijaga root null
	# (lihat _masuk_asrama_putra).
	if _asrama_putra_root != null and not _di_dalam_asrama_putra and _dekat_pintu_asrama_putra_luar():
		_masuk_asrama_putra()
		return
	if _di_dalam_asrama_putra and _tidur_asrama_putra_lebih_dekat():
		_on_aksi("tidur")
		return
	if _di_dalam_asrama_putra and _dekat_pintu_asrama_putra_dalam():
		_keluar_asrama_putra()
		return
	if not _di_dalam_kantor and _dekat_pintu_kantor_luar():
		_masuk_kantor()
		return
	if _di_dalam_kantor and _dekat_pintu_kantor_dalam():
		_keluar_kantor()
		return
	if not _di_dalam_madrasah and _dekat_pintu_madrasah_luar():
		_masuk_madrasah()
		return
	if _di_dalam_madrasah and _dekat_pintu_madrasah_dalam():
		_keluar_madrasah()
		return
	if not _di_dalam_studio and _dekat_pintu_studio_luar():
		_masuk_studio()
		return
	if _di_dalam_studio and _dekat_pintu_studio_dalam():
		_keluar_studio()
		return
	if not _di_dalam_pos_jaga and _dekat_pintu_pos_jaga_luar():
		_masuk_pos_jaga()
		return
	if _di_dalam_pos_jaga and _dekat_pintu_pos_jaga_dalam():
		_keluar_pos_jaga()
		return
	# Smartboard (di dalam surau, dekat papan pintar).
	if _di_dalam and _dekat_smartboard():
		_ui.open_smartboard()
		return
	# BACA BUKU (Tara): dekat rak kitab (Surau/Musholla) -> buka
	# pembaca. Dicek SETELAH smartboard (titiknya tidak beririsan).
	if _dekat_rak():
		_ui.open_baca_buku()
		return
	var misi := _misi_terdekat()
	if misi.is_empty():
		# FASE A GELOMBANG 3 (UI misi): tidak ada misi dekat -> ✕
		# membuka Panel Misi (gelar + progres + daftar misi).
		_manajer_misi.buka_panel_misi(_save)
		return
	var syarat := String(misi.get("syarat", ""))
	if syarat == "surau" and not _di_dalam_surau():
		_ui.toast("Masuk ke dalam surau dulu, lalu tekan lagi.")
		return
	if syarat == "peti":
		# RONDE 20: peti PINDAH (6,10) -> (0,26) kawasan bersama —
		# dibaca dari builder, JANGAN hardcode (posisi lama jatuh di
		# area putri setelah pagar dibangun).
		var chest_pos := Vector3(PesantrenBuilder.PETI_POS.x, 0, PesantrenBuilder.PETI_POS.y)
		if _player.global_position.distance_to(chest_pos) > CHAT_JARAK_INTERAKSI:
			_ui.toast("Dekati peti kayu dulu.")
			return
	_active_misi = misi
	# GELOMBANG 2 FASE A: mulai sesi MesinKuis untuk misi ini
	# (sebelum panel dibuka — jawaban nanti lewat _on_quiz_answered).
	_mulai_kuis_misi(misi)
	_ui.open_mission(misi)


# GELOMBANG 2 FASE A — mulai sesi MesinKuis (A1) untuk misi yang
# dibuka. M1-M3 = kuis 1 soal jenis "materi"; dari_misi() mengubah
# entri MissionData jadi 1 soal format mesin. Entri tidak valid /
# mulai gagal -> _kuis = null dan _on_quiz_answered memakai logika
# lama (fallback aman — perilaku M1-M3 live tidak berubah).
func _mulai_kuis_misi(misi: Dictionary) -> void:
	var soal := MesinKuis.dari_misi(misi)
	if soal.is_empty():
		_kuis = null
		return
	_kuis = MesinKuis.new()
	if not _kuis.mulai([soal], "materi"):
		_kuis = null


func _on_quiz_answered(index: int) -> void:
	if _active_misi.is_empty():
		return
	# GELOMBANG 2 FASE A — jawab lewat MesinKuis. M1-M3 = sesi
	# 1 soal, ambang 1 (ringkasan(1) — BUKAN ambang default 8).
	# Sesi sudah selesai karena jawaban salah sebelumnya -> ulang
	# sesi yang sama dulu (gagal = coba lagi tanpa penalti, §2.6;
	# UI "Baca Materi Lagi" + "Mulai Kuis" membuka percobaan baru).
	if _kuis != null:
		if _kuis.selesai() and not _kuis.lulus(1):
			_kuis.ulang()
		if _kuis.dimulai() and _kuis.jawab(index):
			var hasil := _kuis.ringkasan(1)
			if bool(hasil["lulus"]):
				var poin: int = int(_active_misi["poin"])
				_save["poin"] = int(_save["poin"]) + poin
				(_save["misi_selesai"] as Array).append(String(_active_misi["id"]))
				SantriSave.save_data(_save)
				# Gelar dihitung ulang dari save baru (A5) — disimpan
				# saja, belum ditampilkan (menunggu HUD/A9).
				_gelar_saat_ini = Gelar.nama_gelar(_save)
				_ui.quiz_result(true, poin)
				_update_hud()
				_refresh_markers()
				if bool(_active_misi.get("peti", false)):
					_buka_peti()
			else:
				_ui.quiz_result(false, 0)
			return
		# Sesi mesin tidak bisa dipakai (jawab ditolak) -> jatuh ke
		# logika lama di bawah (fallback aman).
	var benar: bool = index == int(_active_misi["jawaban"])
	if benar:
		var poin: int = int(_active_misi["poin"])
		_save["poin"] = int(_save["poin"]) + poin
		(_save["misi_selesai"] as Array).append(String(_active_misi["id"]))
		SantriSave.save_data(_save)
		_gelar_saat_ini = Gelar.nama_gelar(_save)
		_ui.quiz_result(true, poin)
		_update_hud()
		_refresh_markers()
		if bool(_active_misi.get("peti", false)):
			_buka_peti()
	else:
		_ui.quiz_result(false, 0)


func _buka_peti() -> void:
	if _chest_opened:
		return
	_chest_opened = true
	var tween := create_tween()
	tween.tween_property(_chest_lid, "rotation:x", -1.9, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_mission_closed() -> void:
	_active_misi = {}
	_kuis = null


# ---------- UI misi (FASE A GELOMBANG 3, Raka, 18 Nov 2026) ----------
# Routing ✕ (interact) ke 4 panel UI misi sesuai langkah onboarding
# §1A + handler sinyal ManajerUIMisi (main yang menulis save — UI
# tidak menyentuh save). Mockup DI-ACC Mas 18:58; semua teks panel =
# TEKS DRAF, isi final menunggu tashih Mas (butir 17 / Modul 01).

func _dekat_npc(npc: Node3D) -> bool:
	if npc == null or _player == null:
		return false
	return _player.global_position.distance_to(npc.global_position) <= CHAT_JARAK_INTERAKSI


## Bagian tes berikutnya = Bagian pertama yang belum lulus (N1-N4).
func _bagian_tes_berikut() -> String:
	var lulus: Array = _save.get("bagian_lulus", [])
	for b in Gelar.BAGIAN:
		if not b in lulus:
			return String(b)
	return "N4"


## Nama pengajar Ruang Belajar per gender (§9 butir 22: putri ->
## Ustzh. Fatimah, NPC sudah ada — scripts/npc_fatimah.gd).
func _pengajar_onboarding() -> String:
	return "Ustzh. Fatimah" if _pemain_adalah_putri() else "Ust. Sanusi"


## Apakah pemain dekat NPC alur santri baru (untuk TOMBOL ✕)?
## Cerminan kondisi _buka_ui_misi_terdekat() — TANPA membuka apa
## pun. Dipakai _update_interact_button() supaya tombol ✕ muncul di
## dekat Kyai / Ustadzah / Sanusi / Fatimah (langkah 2-3 dialog,
## langkah 5 Ruang Belajar, langkah 6 venue tes).
func _dekat_npc_misi() -> bool:
	if _manajer_misi == null:
		return false
	var langkah := Onboarding.langkah_saat_ini(_save)
	var putri := _pemain_adalah_putri()
	if langkah == 2 or langkah == 3:
		if not putri and _dekat_npc(_kyai):
			return true
		if putri and _dekat_npc(_ustadzah):
			return true
		return false
	if langkah == 4:
		if not putri and _dekat_npc(_sanusi):
			return true
		if putri and _dekat_npc(_fatimah):
			return true
		# TEKA-TEKI (Raka, 18 Nov 2026): dekat NPC yang bisa ditanya
		# (Bilal/Faris/Satpam/Kyai putra; Mariyah/Penjaga putri) ->
		# tombol ✕ muncul juga ("TANYA", lihat _update_interact_button).
		if _npc_tanya_terdekat() != null:
			return true
		return false
	if langkah == 5:
		if not putri and _dekat_npc(_sanusi):
			return true
		if putri and _dekat_npc(_fatimah):
			return true
		return false
	if langkah == 6:
		var venue := Onboarding.venue_tes("putri" if putri else "putra")
		if _player.global_position.distance_to(venue) <= CHAT_JARAK_INTERAKSI:
			return true
	return false


## Apakah pemain dekat guru yang dicari (Sanusi putra / Fatimah
## putri)? Dipakai _update_interact_button supaya guru selalu
## didahulukan atas NPC tanya bila keduanya dekat (langkah 4).
func _dekat_guru() -> bool:
	if _pemain_adalah_putri():
		return _fatimah != null and _dekat_npc(_fatimah)
	return _sanusi != null and _dekat_npc(_sanusi)


## TEKA-TEKI (Raka, 18 Nov 2026): NPC yang bisa ditanya teka-teki
## saat ini — null bila misi cari guru tidak aktif atau tidak ada
## NPC askable dalam jangkauan. Daftar askable di
## DataTekaTeki (NPC_PUTRA / NPC_PUTRI); di sini dipetakan ke node.
func _npc_tanya_terdekat() -> SantriNPC:
	if Onboarding.langkah_saat_ini(_save) != 4:
		return null
	var kandidat: Array[SantriNPC] = []
	if _pemain_adalah_putri():
		kandidat = [_ustadzah, _penjaga_putri]
	else:
		kandidat = [_kyai, _bilal, _faris, _satpam]
	for npc in kandidat:
		if npc != null and _dekat_npc(npc):
			return npc
	return null


## Id stabil NPC untuk flag anti-spam "tanya_guru" di save
## (sama dengan id di DataTekaTeki.NPC_PUTRA / NPC_PUTRI).
func _id_npc_tanya(npc: SantriNPC) -> String:
	if npc == _kyai:
		return "kyai"
	if npc == _ustadzah:
		return "mariyah"
	if npc == _satpam:
		return "satpam"
	if npc == _penjaga_putri:
		return "penjaga_putri"
	if npc == _bilal:
		return "bilal"
	if npc == _faris:
		return "faris"
	return String(npc.nama_santri()).to_lower()


## Nama + subjudul + avatar panel tanya untuk satu NPC. Avatar
## AvatarMisi hanya kenal "kyai" | "ustadzah" | "sanusi" (lainnya
## jatuh ke "kyai") — dipetakan yang terdekat: santri muda ->
## "sanusi", Satpam -> "kyai", penjaga putri -> "ustadzah".
func _info_npc_tanya(npc: SantriNPC) -> Dictionary:
	if npc == _kyai:
		return {"nama": "Ust. Aqsal Murad", "subjudul": "Pengasuh Pesantren Universe", "avatar": "kyai"}
	if npc == _ustadzah:
		return {"nama": "Ustadzah Mariyah", "subjudul": "Pengasuh Pesantren Universe", "avatar": "ustadzah"}
	if npc == _satpam:
		return {"nama": "Satpam", "subjudul": "Penjaga Gerbang", "avatar": "kyai"}
	if npc == _penjaga_putri:
		return {"nama": "Penjaga Pos Jaga", "subjudul": "Penjaga Pos Jaga", "avatar": "ustadzah"}
	if npc == _bilal:
		return {"nama": "Bilal", "subjudul": "Santri", "avatar": "sanusi"}
	if npc == _faris:
		return {"nama": "Faris", "subjudul": "Santri", "avatar": "sanusi"}
	return {"nama": npc.nama_santri(), "subjudul": "Santri", "avatar": "sanusi"}


## Buka layar tanya untuk satu NPC (dipanggil _buka_ui_misi_terdekat
## langkah 4). _npc_tanya disimpan supaya jawaban "Tanya" nanti
## tahu NPC mana yang ditanya (main tidak menebak dari posisi).
func _buka_tanya_guru(npc: SantriNPC) -> void:
	_npc_tanya = npc
	var info := _info_npc_tanya(npc)
	var guru := DataTekaTeki.guru_saat_ini(_save)
	_manajer_misi.buka_tanya(
		String(info["nama"]),
		String(info["subjudul"]),
		String(info["avatar"]),
		"Kamu mendekati %s. Mau bertanya tentang %s?" % [String(info["nama"]), guru],
		"Tanya tentang " + guru,
		_id_npc_tanya(npc)
	)


## Buka panel UI misi yang cocok dengan langkah + posisi pemain.
## true = satu panel dibuka (pemanggil return); false = tidak ada
## yang cocok, lanjut ke alur misi lama / Panel Misi.
func _buka_ui_misi_terdekat() -> bool:
	if _manajer_misi == null:
		return false
	var langkah := Onboarding.langkah_saat_ini(_save)
	var putri := _pemain_adalah_putri()
	# Langkah 2-3: dialog aturan — dekat Kyai (putra, Surau) atau
	# dekat Ustadzah Mariyah (putri, Musholla).
	if langkah == 2 or langkah == 3:
		if not putri and _dekat_npc(_kyai):
			_manajer_misi.buka_dialog("putra")
			return true
		if putri and _dekat_npc(_ustadzah):
			_manajer_misi.buka_dialog("putri")
			return true
		return false
	# Langkah 4: menemukan pengajar — dekat Sanusi (putra) / Fatimah
	# (putri) = maju ke langkah 5 lalu buka Ruang Belajar. Tanpa
	# cabang ini rantai PUTUS di langkah 4 (temuan Sinta, 18 Nov):
	# fungsi ini tidak mengenal langkah 4, ✕ hanya membuka Panel
	# Misi dan pemain tidak bisa lanjut. maju() 4->5 TIDAK mengacak
	# ulang lokasi (hanya masuk langkah 4 yang mengacak), jadi node
	# guru tetap di tempat pemain menemukannya.
	if langkah == 4:
		if not putri and _dekat_npc(_sanusi):
			Onboarding.maju(_save)
			SantriSave.save_data(_save)
			_update_hud()
			_manajer_misi.buka_ruang_belajar(_pengajar_onboarding())
			return true
		if putri and _dekat_npc(_fatimah):
			Onboarding.maju(_save)
			SantriSave.save_data(_save)
			_update_hud()
			_manajer_misi.buka_ruang_belajar(_pengajar_onboarding())
			return true
		# TEKA-TEKI (Raka, 18 Nov 2026): dekat NPC yang bisa ditanya
		# -> buka layar pilihan tanya (guru didahulukan di atas —
		# bila dekat guru, cabang di atas sudah return).
		var npc_tanya := _npc_tanya_terdekat()
		if npc_tanya != null:
			_buka_tanya_guru(npc_tanya)
			return true
		return false
	# Langkah 5: Ruang Belajar — dekat pengajar (Sanusi putra /
	# Fatimah putri, lokasi acak). Jalan pintas lama "Ruang Belajar
	# putri dekat Sanusi" DIHAPUS (perintah Mas 20:30 WIB).
	if langkah == 5:
		if not putri and _dekat_npc(_sanusi):
			_manajer_misi.buka_ruang_belajar(_pengajar_onboarding())
			return true
		if putri and _dekat_npc(_fatimah):
			_manajer_misi.buka_ruang_belajar(_pengajar_onboarding())
			return true
	# Langkah 6: Tes kenaikan — dekat venue tes (Surau putra /
	# Kantor Ustadzah putri, menunggu butir 19).
	if langkah == 6:
		var venue := Onboarding.venue_tes("putri" if putri else "putra")
		if _player.global_position.distance_to(venue) <= CHAT_JARAK_INTERAKSI:
			_manajer_misi.buka_tes(_bagian_tes_berikut())
			return true
	return false


## Pindahkan node guru (Sanusi/Fatimah) ke lokasi acak yang BARU
## tersimpan di save. Dipanggil setiap kali state machine mengacak
## ulang lokasi guru — kalau tidak, node tetap di lokasi lama
## sementara target misi (misi_aktif) menunjuk lokasi baru dan
## pemain mencari guru di tempat yang salah (temuan Sinta, 18 Nov).
func _pindah_guru_ke_lokasi_save() -> void:
	var ob := Onboarding.baca(_save)
	if _pemain_adalah_putri():
		if _fatimah != null and LokasiAcak.id_valid_putri(String(ob["fatimah_lokasi"])):
			NPCFatimah.tempatkan(_fatimah, LokasiAcak.pos_dari_id_putri(String(ob["fatimah_lokasi"])))
	elif _sanusi != null and LokasiAcak.id_valid(String(ob["sanusi_lokasi"])):
		Onboarding.tempatkan_sanusi(_sanusi, LokasiAcak.pos_dari_id(String(ob["sanusi_lokasi"])))


## Dialog aturan selesai (pilihan "ke" == -1) -> maju 1 langkah.
## Masuk langkah 4 = lokasi Sanusi diacak (Onboarding.maju).
func _on_manajer_dialog_selesai() -> void:
	var langkah := Onboarding.langkah_saat_ini(_save)
	if langkah != 2 and langkah != 3:
		return
	var baru := Onboarding.maju(_save)
	SantriSave.save_data(_save)
	if baru == 4:
		_pindah_guru_ke_lokasi_save()
		_ui.toast("Misi baru: cari Ustzh. Fatimah." if _pemain_adalah_putri() else "Misi baru: cari Ust. Sanusi.")
	_update_hud()


## TEKA-TEKI (Raka, 18 Nov 2026): pemain memilih "Tanya tentang
## guru" di layar tanya — hitung teka-teki dari lokasi di save lalu
## tampilkan di panel pesan (satu langkah, tombol "Tutup").
##   - NPC sudah memberi petunjuk di misi ini -> TEKS_ULANG
##     (satu NPC, satu petunjuk per misi — draf §6).
##   - Lokasi tidak valid / misi tidak aktif -> TEKS_TANYA_LAGI
##     (jaga-jaga draf §5 — JANGAN bocorkan lokasi, JANGAN crash).
##   - Selain itu: catat NPC ke "tanya_guru", simpan save, tampilkan
##     pembuka NPC (bila ada) + teka-teki lokasi saat ini.
## "Sapa saja" tidak sampai ke sini (ManajerUIMisi tidak meng-emit).
func _on_manajer_tanya_dipilih(npc_id: String) -> void:
	if _npc_tanya == null:
		return
	var npc := _npc_tanya
	_npc_tanya = null
	var info := _info_npc_tanya(npc)
	var nama := String(info["nama"])
	var subjudul := String(info["subjudul"])
	var avatar := String(info["avatar"])
	if DataTekaTeki.sudah_ditanya(_save, npc_id):
		_manajer_misi.buka_teka_teki(nama, subjudul, avatar, DataTekaTeki.TEKS_ULANG)
		return
	var teka := DataTekaTeki.teka_teki_saat_ini(_save)
	if teka == "":
		_manajer_misi.buka_teka_teki(nama, subjudul, avatar, DataTekaTeki.TEKS_TANYA_LAGI)
		return
	DataTekaTeki.catat_tanya(_save, npc_id)
	SantriSave.save_data(_save)
	var pembuka := DataTekaTeki.pembuka_untuk(npc_id)
	var teks := (pembuka + " " + teka).strip_edges() if pembuka != "" else teka
	_manajer_misi.buka_teka_teki(nama, subjudul, avatar, teks)


## Satu langkah Ruang Belajar selesai -> tambah poin SEKALI per
## (modul, jenis) — kunci "rb_selesai" di save (anti-farming bila
## pemain mengulang Ruang Belajar modul yang sama).
func _on_manajer_rb_langkah(jenis: String, poin: int) -> void:
	var modul := int(Onboarding.baca(_save)["modul"])
	var kunci := "%d:%s" % [modul, jenis]
	var sudah: Array = _save.get("rb_selesai", [])
	if kunci in sudah:
		return
	sudah.append(kunci)
	_save["rb_selesai"] = sudah
	_save["poin"] = int(_save["poin"]) + poin
	SantriSave.save_data(_save)
	_gelar_saat_ini = Gelar.nama_gelar(_save)
	_update_hud()


func _on_manajer_rb_selesai(poin_total: int) -> void:
	# FASE A (temuan Sinta, 18 Nov): tidak ada pemicu in-game 5->6 —
	# pemain yang menyelesaikan Modul 01 tidak pernah maju ke tes
	# (maju() hanya dipanggil login 1->2, dialog 2/3, dan cabang
	# 4->5). RB selesai = modul dipelajari tuntas (sinyal selesai
	# hanya keluar saat kuis terakhir dijawab) -> maju ke langkah 6
	# "Tes kenaikan". Guard langkah==5: bila RB dibuka ulang di
	# langkah 6/7, jangan loncat langkah.
	# SATU toast saja: toast() kedua langsung menimpa yang pertama
	# (pelajaran dari _masuk_pesantren — toast itu label tunggal
	# 2,5 dtk, tanpa antrean).
	var teks := "Ruang Belajar selesai — %d poin." % poin_total
	if Onboarding.langkah_saat_ini(_save) == 5:
		Onboarding.maju(_save)
		SantriSave.save_data(_save)
		teks += " Lanjut tes kenaikan di %s." % ("Kantor Ustadzah" if _pemain_adalah_putri() else "Surau")
	_ui.toast(teks)
	_update_hud()


## Tes kenaikan selesai (sinyal dari TesKenaikanUI, mesin diteruskan
## supaya pencatatan memakai Gerbang.catat_tes — UI tidak mencatat).
## Lulus -> +20 poin (sekali saja; gerbang_lulus guard), onboarding
## lulus_tes (langkah 6 -> 5 / hatam). Gagal -> kembali belajar
## (langkah 5, modul tetap) — ulangi belajar + tesnya saja.
func _on_manajer_tes_selesai(lulus: bool, skor: int, bagian: String, mesin: MesinKuis) -> void:
	if lulus:
		var sudah_lulus := Gerbang.gerbang_lulus(_save, bagian)
		if Gerbang.catat_tes(_save, bagian, mesin) and not sudah_lulus:
			_save["poin"] = int(_save["poin"]) + 20
		var baru := Onboarding.lulus_tes(_save)
		_gelar_saat_ini = Gelar.nama_gelar(_save)
		SantriSave.save_data(_save)
		if baru == 5:
			# Modul berikut = lokasi guru diacak ulang (lulus_tes) —
			# node harus ikut pindah, kalau tidak pemain mencari
			# guru di lokasi baru sementara node di lokasi lama.
			_pindah_guru_ke_lokasi_save()
		_update_hud()
		_refresh_markers()
		if baru == 7 and Onboarding.selesai(_save):
			_ui.toast("HATAM — Nahwu Dasar selesai. Alhamdulillah.")
		else:
			_ui.toast("LULUS — %d/10. Kembali belajar ke %s." % [skor, _pengajar_onboarding()])
	else:
		Onboarding.gagal_tes(_save)
		SantriSave.save_data(_save)
		_update_hud()
		_ui.toast("Belum lulus — ulangi belajar + tesnya saja.")


## Panel misi (dialog / Ruang Belajar / tes / Panel Misi) sedang
## terbuka? Dipakai petunjuk santri baru: petunjuk disembunyikan
## selama panel terbuka supaya tidak menumpuk di atas dialog.
func _panel_misi_terbuka() -> bool:
	return _manajer_misi != null and _manajer_misi.ada_panel_terbuka()


func _update_hud() -> void:
	# Label misi di HUD = langkah alur santri baru (§1A) selama
	# onboarding belum hatam — BUKAN M1-M3. Sebelumnya label selalu
	# "Misi 1 — Kenalan dengan Nahwu" (M1) padahal langkah pemain
	# baru adalah "Cari Ust. Aqsal M / Ustzh. Mariyah" — Mas bingung
	# (20:26 WIB: "kok ga bisa jalanin misi pertama?"). Setelah
	# hatam, label kembali ke M1-M3 seperti dulu. Target peta
	# (_data_peta) SENGAJA tidak diubah: lokasi Sanusi/Fatimah
	# memang tanpa marker (§1A).
	var teks := "Semua misi selesai!"
	if not Onboarding.selesai(_save):
		var ob := Onboarding.misi_aktif(_save, "putri" if _pemain_adalah_putri() else "putra")
		teks = String(ob["judul"])
	else:
		var aktif := _misi_aktif_saat_ini()
		if not aktif.is_empty():
			teks = String(aktif["judul"])
	_ui.set_hud(int(_save["poin"]), teks)
	# PETUNJUK SANTRI BARU (Raka, 18 Nov 2026 — perintah Mas 21:32 WIB:
	# "ayo mulai misi santri barumu! Sowan ke Ustadz sekarang").
	# PEMETAAN LANGKAH: "langkah 1" di kata-kata Mas = santri yang baru
	# masuk dunia. Di kode, masuk dunia langsung memajukan 1->2
	# (_masuk_pesantren), jadi di dunia langkah 2 = "Cari Ust. Aqsal M /
	# Ustzh. Mariyah" (sowan) — di situlah petunjuk tampil. Hilang
	# begitu dialog sowan dibuka (panel misi terbuka) atau langkah
	# lewat 2 (dialog selesai -> 3). Santri lama (langkah 3+) tidak
	# pernah melihatnya lagi. Selama pop-up petunjuk tombol terbuka,
	# banner disembunyikan (tidak menumpuk di atas pop-up); begitu
	# pop-up ditutup, _on_petunjuk_ditutup() memanggil _update_hud()
	# dan banner muncul lagi. _update_hud() dipanggil di semua titik
	# perubahan langkah (masuk dunia, dialog selesai, RB, tes), jadi
	# sinkronisasi di sini cukup — tidak perlu timer.
	if Onboarding.langkah_saat_ini(_save) == 2 and not _panel_misi_terbuka() and not _ui.is_petunjuk_visible():
		_ui.show_petunjuk_misi(_pemain_adalah_putri())
	else:
		_ui.hide_petunjuk_misi()


# ---------- chat ----------
func _on_chat_sent(teks: String) -> void:
	# BUBBLE-ML: pesan pemain tampil di feed ML di atas joystick
	# (bukan bubble kotak di atas kepala — show_chat kini no-op).
	_ui.tampilkan_pesan_melayang(String(_save["nama"]), teks)
	_ui.add_chat_line(String(_save["nama"]), teks)
	# RONDE PERBAIKAN (Eka) — AKAR MASALAH BUBBLE: panel chat TIDAK
	# menutup sendiri setelah kirim, sementara bubble DITAHAN selama
	# panel terbuka (Ronde 7: panel menutupi bubble) + timer 5 detik
	# terus jalan — jadi bubble tidak pernah muncul (probe ronde
	# perbaikan: kirim saat panel buka -> bubble=false, timer habis
	# -0,07, tutup panel pun bubble tetap false). Tutup panel saat
	# kirim: bubble langsung terlihat di atas kepala; riwayat chat
	# tetap ada, panel bisa dibuka lagi dengan tombol Chat.
	_ui.close_chat()


# ---------- dashboard ----------
func _on_open_dashboard() -> void:
	# Perbaikan 15 Nov ~12:50 WIB (Kartu Santri tidak bisa ditutup):
	# tombol "Kartu Santri" kini membuka-MENUTUP (toggle).
	if _ui.is_dashboard_visible():
		_ui.close_dashboard()
		return
	var hari := SantriSave.tanggal_hari_ini()
	var mh: Dictionary = _save["mahadiyah"]
	var today_done: Array = mh.get(hari, [])
	var khataman: Array = _save["khataman_hadir"]
	_ui.open_dashboard(_save, today_done, khataman.has(hari), SantriSave.streak_mahadiyah(mh))


func _on_mahadiyah_toggled(key: String, checked: bool) -> void:
	var hari := SantriSave.tanggal_hari_ini()
	var mh: Dictionary = _save["mahadiyah"]
	var done: Array = mh.get(hari, [])
	if checked and not done.has(key):
		done.append(key)
	elif not checked and done.has(key):
		done.erase(key)
	mh[hari] = done
	_save["mahadiyah"] = mh
	SantriSave.save_data(_save)
	_ui.set_mahadiyah_streak(SantriSave.streak_mahadiyah(mh))


func _on_khataman_joined() -> void:
	var hari := SantriSave.tanggal_hari_ini()
	var khataman: Array = _save["khataman_hadir"]
	if not khataman.has(hari):
		khataman.append(hari)
	_save["khataman_hadir"] = khataman
	SantriSave.save_data(_save)
	_ui.set_khataman_hadir(true)
	_ui.toast("Kamu tercatat hadir khataman hari ini.")


# ---------- peta (RONDE 4) ----------
func _on_open_peta() -> void:
	# Tombol "Peta" di HUD: buka-MENUTUP (toggle, seperti Kartu Santri).
	if _ui.is_peta_visible():
		_ui.close_peta()
		return
	_ui.open_peta(_data_peta())


## Data untuk PetaControl + MinimapControl: posisi pemain + NPC
## (Vector2 x,z) + arah hadap + tujuan misi aktif + sawah + gunung.
## Kalau pemain di dalam interior, titiknya digambar DI SURAU (peta
## luar) — dari luar, "di dalam surau" memang di situ. Tujuan misi
## yang di dalam interior (M2) juga dipetakan ke Surau.
func _data_peta() -> Dictionary:
	var pp := _player.global_position
	var pemain := Vector2(pp.x, pp.z)
	if _di_dalam:
		pemain = PesantrenBuilder.SURAU_POS
	# RONDE PERBAIKAN (Raka, integrasi item 7f): di dalam Musholla,
	# titik pemain digambar DI MUSHOLLA (peta luar) — seperti Surau.
	if _di_dalam_musholla:
		pemain = PesantrenBuilder.MUSHOLLA_POS
	# INTERIOR PUTRI (Lestari): di dalam interior putri, titik pemain
	# digambar di cangkang luarnya (pola Surau/Musholla di atas).
	if _di_dalam_kelas_putri:
		pemain = Vector2(_kelas_putri_pos.x, _kelas_putri_pos.z)
	if _di_dalam_asrama_putri:
		pemain = Vector2(_asrama_putri_pos.x, _asrama_putri_pos.z)
	if _di_dalam_asrama_putra:
		pemain = Vector2(_asrama_putra_pos.x, _asrama_putra_pos.z)
	if _di_dalam_kantor:
		pemain = Vector2(_kantor_pos.x, _kantor_pos.z)
	if _di_dalam_madrasah:
		pemain = Vector2(_madrasah_pos.x, _madrasah_pos.z)
	if _di_dalam_studio:
		pemain = Vector2(_studio_pos.x, _studio_pos.z)
	if _di_dalam_pos_jaga:
		pemain = Vector2(_pos_jaga_pos.x, _pos_jaga_pos.z)
	var npcs: Array = []
	for npc in _npcs:
		npcs.append({"nama": npc.nama_santri(), "pos": Vector2(npc.global_position.x, npc.global_position.z)})
	var target := Vector2.INF
	var aktif := _misi_aktif_saat_ini()
	if not aktif.is_empty():
		var tp: Vector3 = aktif["penanda"]
		target = Vector2(tp.x, tp.z)
		if _di_dalam or tp.z < -100.0:
			target = PesantrenBuilder.SURAU_POS
		if _di_dalam_musholla:
			target = PesantrenBuilder.MUSHOLLA_POS
	return {
		"player": pemain,
		"yaw": _player.get_facing_yaw(),
		"target": target,
		"npcs": npcs,
		"surau": PesantrenBuilder.SURAU_POS,
		# RONDE 14: Surau diputar -25° — peta besar menggambar kotaknya
		# sebagai poligon miring (ui.gd), bukan persegi tegak.
		"surau_rotasi": PesantrenBuilder.SURAU_ROTASI_DEG,
		"cangkruk": PesantrenBuilder.CANGKRUK_POS,
		"peti": PesantrenBuilder.PETI_POS,
		# RONDE 21: Musholla Ar-Raudhah (putri, kampus baru) + TEMBOK
		# pemisah + gerbang + pos jaga + pos satpam — digambar di
		# peta besar + minimap. "pagar_garis" DIGANTI "tembok_garis"
		# (PesantrenBuilder.TEMBOK_GARIS = [(14,-60),(14,16)]).
		# RONDE PERBAIKAN (Gita): ui.gd membaca "tembok_garis"
		# (fallback "pagar_garis") + "tembok_keliling_garis" /
		# "gerbang_putri_pos" (fallback konstanta TembokPutri) —
		# main.gd kini mengirim ketiga kunci itu langsung.
		"musholla": PesantrenBuilder.MUSHOLLA_POS,
		"musholla_rotasi": PesantrenBuilder.MUSHOLLA_ROTASI_DEG,
		"tembok_garis": PesantrenBuilder.TEMBOK_GARIS,
		"gerbang_pos": PesantrenBuilder.GERBANG_POS,
		"tembok_keliling_garis": TembokPutri.KELILING_GARIS,
		"gerbang_putri_pos": TembokPutri.GERBANG_PUTRI_POS,
		"pos_jaga": PesantrenBuilder.POS_JAGA,
		"pos_satpam": PesantrenBuilder.POS_SATPAM,
		"sawah_pos": PesantrenBuilder.SAWAH_POS,
		"sawah_size": PesantrenBuilder.SAWAH_SIZE,
		"gunung": PesantrenBuilder.GUNUNG,
		"half": PesantrenBuilder.MAP_HALF,
	}


# ---------- aksi karakter + ganti outfit (RONDE 6) ----------
func _on_aksi(nama: String) -> void:
	# RONDE 8: tekan TIDUR saat sudah tidur = bangun (toggle) — retest:
	# bangun hanya bisa lewat Aksi -> Berdiri.
	if nama == "tidur" and _player.aksi_saat_ini() == "tidur":
		nama = "berdiri"
	# RONDE 13: aksi apa pun (termasuk "berdiri" karena pemain
	# bergerak — lihat _process) mengakhiri keikutsertaan sholat:
	# pemain memilih aksi lain. Banner ditampilkan lagi supaya bisa
	# ikut lagi selama sesi masih berjalan.
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		if _sholat_aktif:
			_ui.show_sholat_banner(_sholat_nama, "Musholla" if _pemain_adalah_putri() else "Surau")
	var aksi_sebelum := _player.aksi_saat_ini()
	# Salaman: hadap NPC terdekat (<= 6 m) dulu supaya pose-nya
	# mengarah ke lawan bicara.
	if nama == "salaman":
		var dekat := _npc_terdekat(6.0)
		if dekat != null:
			var arah := dekat.global_position - _player.global_position
			arah.y = 0.0
			if arah.length() > 0.05:
				_player.set_facing(atan2(-arah.x, -arah.z))
	# Tidur: di kamar cangkruk, dekat tempat tidur — snap pemain ke
	# tempat tidur dulu, lalu pose berbaring.
	# KASUR (Wulan): boleh juga tidur di Surau/Musholla — di titik
	# tugas SENDIRI (santri yang kasur fisiknya belum ada / sudah
	# penuh). Di luar keempat ruangan itu tetap tidak bisa tidur.
	# ASRAMA PUTRI (Lestari, aturan Rani): satu kasur susun = SATU
	# StaticBody3D penuh — kapsul TIDAK BOLEH di-snap begitu saja
	# (akan berada DI DALAM collision kasur itu sendiri). Body
	# dimatikan dulu, snap ke posisi_tidur_list()[idx-1] (sudah
	# termasuk y kasur + offset kaki 0,95 m — JANGAN pakai rumus
	# Cangkruk +0,95), diaktifkan lagi saat bangun. "Dimatikan" =
	# collision_layer/mask 0 (Godot 4.7: StaticBody3D tidak punya
	# properti "disabled" — terukur headless).
	if nama == "tidur":
		if not (_di_dalam_cangkruk or _di_dalam or _di_dalam_musholla or _di_dalam_asrama_putri or _di_dalam_asrama_putra):
			_ui.toast("Tidur itu di tempat tidurmu — Cangkruk, Asrama Putra, Asrama Putri, atau Surau/Musholla kalau kasurmu belum ada.")
			return
		if not _dekat_tempat_tidur():
			_ui.toast("Dekati tempat tidurmu dulu.")
			return
		if _di_dalam_asrama_putri or _di_dalam_asrama_putra:
			var di_putra := _di_dalam_asrama_putra
			var idx_tidur := _idx_kasur_asrama_putra_tidur() if di_putra else _idx_kasur_asrama_tidur()
			if idx_tidur <= 0:
				_ui.toast("Dekati tempat tidurmu dulu.")
				return
			var bodies_tidur: Array = _asrama_putra_kasur_bodies if di_putra else _asrama_putri_kasur_bodies
			var beds_tidur: Array = _asrama_putra_beds if di_putra else _asrama_putri_beds
			var body_tidur: StaticBody3D = bodies_tidur[(idx_tidur - 1) / 2]
			_kasur_tidur_layer = body_tidur.collision_layer
			_kasur_tidur_mask = body_tidur.collision_mask
			body_tidur.set_deferred("collision_layer", 0)
			body_tidur.set_deferred("collision_mask", 0)
			_kasur_tidur_body = body_tidur
			_kasur_tidur_idx = idx_tidur
			# Kapsul vertikal 1,7 m TIDAK MUAT di kasur ATAS: y tidur
			# 1,65 + 1,7 = 3,35 > pelat lantai atas y 3,0 — kapsul
			# menembus pelat, fisika mendorongnya turun tiap frame
			# (terukur headless: tanpa ini y kasur atas tidak stabil).
			# Kecilkan kapsul selama tidur di kasur atas (visual
			# berbaring tidak berubah — hanya collision); dipulihkan
			# saat bangun (_aktifkan_lagi_kasur_tidur).
			if (idx_tidur - 1) % 2 == 1:
				_player_capsule.set_deferred("height", 0.8)
				_kasur_tidur_kapsul_dikecilkan = true
			_player.set_facing(0.0)
			_player.global_position = beds_tidur[idx_tidur - 1]
		else:
			# Snap ke kasur TERDEKAT. Offset +0,95 ke selatan (RONDE 9,
			# Mas: "kepalanya tembus ke luar"): origin pemain ada di KAKI
			# (rotasi tidur memutar visual di origin), jadi kepala jatuh
			# 1,66 m ke utara origin — offset +0,15 lama menaruh kepala
			# di bed_z-1,51, menembus dinding utara (terukur headless:
			# kasur utara-tengah kepala z=-305,21, ujung -305,45, melewati
			# muka luar dinding -305,125). Dengan +0,95 kepala di
			# bed_z-0,71 (tepat di atas bantal, pusat -0,75), ujung kepala
			# -0,95 masih di atas kasur (tepi -1,0), kaki di +0,88 (tepi
			# +1,05) — badan 1,83 m pas di kasur 2,1 m, kepala 0,23 m
			# dari muka dalam dinding utara.
			_player.set_facing(0.0)
			_player.global_position = _kasur_terdekat() + Vector3(0, 0, 0.95)
	_player.set_aksi(nama)
	# RONDE 8: bangun dari tidur — jepret kamera ke posisi akhir +
	# pitch default (-0,35) supaya tidak menyapu melewati lampu gantung
	# saat lerp (retest: bangun -> layar 80% hitam, kamera terjepit bola
	# lampu). Lampu juga sudah dipindah + diberi collision (lihat
	# interior_cangkruk.gd) — jepretan ini lapis keduanya.
	# ASRAMA PUTRI: aktifkan lagi body kasur yang dimatikan saat tidur.
	if aksi_sebelum == "tidur" and nama == "berdiri":
		_aktifkan_lagi_kasur_tidur()
		_cam_pitch = -0.35
		_rig.global_position = _player.global_position + Vector3(0, 1.6, 0)
		_spring.rotation.x = _cam_pitch
	# RONDE 7 (retest: pose dikira tidak jalan): konfirmasi toast
	# untuk SETIAP pose supaya ada umpan balik langsung — pose duduk
	# dari belakang memang halus (hanya badan turun), jadi toast
	# menegaskan aksinya berhasil.
	var label_pose := {"duduk": "Duduk bersila.", "berdiri": "Berdiri.", "salaman": "Salaman.", "menulis": "Menulis.", "melambai": "Melambai.", "tidur": "Selamat tidur, santri."}
	if nama == "bawa_kitab":
		_ui.toast("Kitab dipegang." if _player.bawa_kitab_aktif() else "Kitab disimpan.")
	elif label_pose.has(nama):
		_ui.toast(String(label_pose[nama]))


func _npc_terdekat(jarak_maks: float) -> SantriNPC:
	var best: SantriNPC = null
	var best_d := jarak_maks
	for npc in _npcs:
		var d := _player.global_position.distance_to(npc.global_position)
		if d < best_d:
			best_d = d
			best = npc
	return best


func _on_ganti_baju_requested() -> void:
	# RONDE 7: tombol "Ganti Baju" di Kartu Santri — tutup dashboard,
	# buka panel outfit dengan outfit saat ini (panel yang sama seperti
	# dari lemari; pilihan langsung diterapkan + disimpan).
	_ui.close_dashboard()
	_ui.open_outfit(_save.get("outfit", MissionData.OUTFIT_DEFAULT))


func _on_outfit_dipilih(jenis: String, warna_hex: String) -> void:
	var outfit: Dictionary = _save.get("outfit", MissionData.OUTFIT_DEFAULT).duplicate()
	# RONDE 11: kacamata disimpan sebagai bool, bukan hex — sinyal
	# membawa "ya"/"tidak" dari panel (lihat ui.gd _on_kacamata_dipilih).
	if jenis == "kacamata":
		outfit["kacamata"] = warna_hex == "ya"
	else:
		outfit[jenis] = warna_hex
	_save["outfit"] = outfit
	# RONDE 8 (retest: ganti baju tidak mengubah karakter di live —
	# headless membuktikan rantai sinyal→material jalan): visual DULU,
	# simpan belakangan — supaya kegagalan tulis save tidak mungkin
	# menggagalkan perubahan tampilan. Print diagnostik supaya retest
	# browser berikutnya bisa membuktikan sinyal ini sampai di sini.
	_player.terapkan_outfit(outfit)
	print("[RONDE8] outfit_dipilih: %s=%s -> sarung=%s" % [jenis, warna_hex, str(outfit.get("sarung", "?"))])
	SantriSave.save_data(_save)
	_ui.set_outfit_terpilih(jenis, warna_hex)


# ---------- sholat berjamaah (RONDE 13) ----------
## Cek jam perangkat tiap frame: masuk jendela sholat -> mulai sesi;
## jendela habis -> akhiri sesi. Hanya saat dunia terlihat (layar
## login menutupi dunia = sesi tidak mulai; begitu masuk di tengah
## jendela, sesi langsung mulai di frame berikutnya).
func _cek_waktu_sholat() -> void:
	if not _ui.is_world_visible():
		return
	var jam := LangitDinamis.jam_saat_ini()
	var s := MissionData.sholat_saat_ini(jam)
	# RONDE 18: bersihkan kunci sesi kemarin (tanggal berganti).
	var tgl := Time.get_date_string_from_system()
	if tgl != _sholat_tanggal:
		_sholat_tanggal = tgl
		_sholat_sudah.clear()
	if not _sholat_aktif and not s.is_empty():
		# RONDE 18: sesi yang sudah jalan di jendela ini (adegan
		# selesai sebelum 1 menit habis) TIDAK boleh mulai lagi.
		var kunci := String(s["nama"]) + "_" + String(s["jam"]) + "_" + tgl
		if not _sholat_sudah.has(kunci):
			_mulai_sholat(s)
	elif _sholat_aktif and int(jam * 60.0) >= _sholat_akhir_menit:
		_akhiri_sholat()


# ---------- audio suasana (RONDE 17) ----------
## Audio kegiatan mengikuti sesi yang berjalan — hanya saat dunia
## terlihat (layar login menutupi dunia = tidak ada kegiatan).
## Sholat -> wirid; khataman -> nadzom (Amtsilah) / khataman (kitab
## lain). Bila file bacaan belum ada, AudioPesantren diam-diam tetap
## memainkan ambience (fallback, tanpa error).
func _perbarui_audio() -> void:
	var kegiatan := ""
	if _ui.is_world_visible():
		if _sholat_aktif:
			kegiatan = "wirid"
		else:
			var kh := MissionData.khataman_saat_ini()
			if not kh.is_empty():
				kegiatan = AudioPesantren.kegiatan_untuk_kitab(String(kh.get("kitab", "")))
	_audio.set_kegiatan(kegiatan)


## Tombol "Suara"/"Senyap" di HUD: balik status mute + simpan.
func _on_suara_toggled() -> void:
	var mati := not bool(_save.get("suara_mati", false))
	_save["suara_mati"] = mati
	_audio.set_mute(mati)
	_ui.set_suara_mati(mati)
	SantriSave.save_data(_save)


## KUALITAS ADAPTIF: pemain memilih mode dari panel Pengaturan.
func _on_kualitas_dipilih(mode: String) -> void:
	if _kualitas == null:
		return
	_kualitas.atur_mode(mode)
	_ui.set_kualitas_mode(_kualitas.mode_saat_ini())


## Mulai sesi: toast + banner untuk pemain, NPC jalan ke Surau.
func _mulai_sholat(s: Dictionary) -> void:
	var nama := String(s["nama"])
	var parts := String(s["jam"]).split(":")
	var mulai := int(parts[0]) * 60 + int(parts[1])
	_sholat_aktif = true
	_sholat_nama = nama
	_sholat_akhir_menit = mulai + int(s.get("durasi_menit", 1))
	# RONDE 18: adegan dimulai dari "kumpul" — NPC jalan ke Surau;
	# takbir baru mulai kalau semua NPC sudah di sajadah (atau
	# timeout, lihat _proses_adegan_sholat).
	_sholat_adegan = "kumpul"
	_sholat_adegan_t = 0.0
	# RONDE PERBAIKAN (Eka): toast mengikuti gender/area pemain —
	# santriwati sholat di Musholla, bukan Surau (retest Ronde 23:
	# banner Dzuhur tulis "Surau" bahkan untuk putri). CATATAN: teks
	# BANNER-nya sendiri dibangun di ui.gd show_sholat_banner()
	# (BUKAN file ini) — perlu patch 1 baris di sana (lihat
	# RONDE-PERBAIKAN-EKA.md): show_sholat_banner(nama, tempat) dengan
	# tempat "Musholla"/"Surau", dipanggil dari 3 tempat di main.gd.
	var tempat_sholat := "Musholla" if _pemain_adalah_putri() else "Surau"
	_ui.toast("Waktu sholat " + nama + " — ayo ke " + tempat_sholat + "!")
	_ui.show_sholat_banner(nama, tempat_sholat)
	# FITUR ADZAN (Sinta, 17 Nov 2026): adzan bunyi BERSAMAAN dengan
	# banner. Sekali per sesi — _mulai_sholat hanya dipanggil sekali
	# per jendela berkat kunci _sholat_sudah di _cek_waktu_sholat
	# (dan mainkan_adzan() sendiri menolak mulai ulang selagi bunyi).
	# Bila file adzan.ogg belum ada / suara dimatikan, fungsi itu
	# diam saja — banner + sesi tetap jalan normal.
	_audio.mainkan_adzan()
	# RONDE 15: NPC diam (Kyai, berdiri tetap di serambi) TIDAK ikut
	# jalan ke Surau — tetap di tempat selama sesi; sajadah tetap
	# Sajadah_02 (Bilal) / Sajadah_04 (Faris).
	# RONDE 16 (Mas: Pengasuh seharusnya memimpin sebagai imam):
	# Kyai TIDAK lagi dilewati — ia jalan ke Surau seperti Bilal/
	# Faris, tapi ke POSISI IMAM di depan saf (lihat _posisi_imam),
	# bukan ke sajadah jamaah. Counter j hanya untuk jamaah supaya
	# Bilal tetap Sajadah_02 dan Faris tetap Sajadah_04.
	# RONDE 20: Kyai TIDAK LAGI diam di serambi — ia patroli (duduk di
	# Surau / keliling). Imam dikenali dari referensi _kyai (bukan
	# berdiri_tetap()). Ustadzah Mariyah memimpin sisi PUTRI sebagai
	# imam di Musholla Ar-Raudhah (bukan ke Surau). SATPAM dilewati
	# total (ikut_sholat()=false — tetap di pos gerbang).
	var sajadah := ["Sajadah_02", "Sajadah_04"]
	var j := 0
	for i in range(_npcs.size()):
		var npc := _npcs[i]
		if not npc.ikut_sholat():
			continue
		if npc == _kyai:
			# RONDE 24 (Raka, 19 Nov 2026 — "Kyai muncul dari tembok"):
			# JANGAN simpan posisi saat ini sebagai "rumah" kalau NPC
			# patroli sedang di DALAM ruangan — _rute_pulang akan
			# menarik garis lurus dari pintu luar ke kursi (z=-300),
			# menembus dinding timur interior (repro: skrip/
			# test_kyai_tembok.gd, TABRAK E_timur t=252). NPC patroli
			# pulang ke rumah LUAR dari setup (-3.5,-2.0); selesai_
			# sholat() mengantarnya masuk lagi lewat pintu (GTA).
			if npc._patroli.is_empty():
				_npc_rumah[npc] = npc.global_position
			_sajadah_npc[npc] = _posisi_imam()
			_npc_sholat_fase[npc] = "ke_pintu"
			npc.say("Ayo sholat berjamaah — saya jadi imam.")
			if npc.di_dalam():
				# Kyai sedang duduk di dalam Surau — keluarkan dulu
				# (teleport ke pintu luar), rute dihitung dari luar.
				npc.teleport_ke_pintu_luar()
			npc.mulai_rute(_rute_ke_pintu_surau(npc.global_position))
			continue
		if npc == _ustadzah:
			# RONDE 24 (Raka): sama seperti Kyai — jangan simpan kursi
			# Musholla (z=-300) sebagai "rumah"; pulang ke rumah LUAR
			# setup (134,-17), masuk lagi lewat pintu.
			if npc._patroli.is_empty():
				_npc_rumah[npc] = npc.global_position
			_sajadah_npc[npc] = _posisi_imam_musholla()
			npc.say("Ayo sholat berjamaah di Musholla Ar-Raudhah — saya jadi imam.")
			if npc.di_dalam():
				# Ustadzah sudah di dalam musholla — langsung jalan ke
				# sajadah imam (tanpa keluar-masuk lagi).
				_npc_sholat_fase[npc] = "ke_sajadah"
				npc.mulai_rute([_sajadah_npc[npc]])
			else:
				_npc_sholat_fase[npc] = "ke_pintu"
				npc.mulai_rute(_rute_ke_pintu_musholla(npc.global_position))
			continue
		# RONDE 24 (Raka): "rumah" harus titik luar yang bisa dicapai
		# jalan kaki — NPC patroli (punya kamus _patroli) tidak
		# menimpa rumah setup-nya dengan posisi di dalam ruangan.
		if npc._patroli.is_empty():
			_npc_rumah[npc] = npc.global_position
		_sajadah_npc[npc] = _posisi_sajadah(sajadah[j % sajadah.size()])
		_npc_sholat_fase[npc] = "ke_pintu"
		npc.say("Ayo sholat berjamaah di Surau!")
		npc.mulai_rute(_rute_ke_pintu_surau(npc.global_position))
		j += 1


## Akhiri sesi: banner hilang, pemain yang ikut berdiri lagi, NPC
## pulang (yang di dalam jalan ke pintu dalam dulu; yang masih di
## luar langsung pulang dari posisinya).
## RONDE 18: fade_in=true (akhir sinematik) — layar TIDAK langsung
## terang: overlay blackout dibiarkan lalu di-fade masuk oleh mesin
## adegan ("selesai"); fade_in=false (batas jam / abort) — overlay
## langsung disembunyikan supaya pemain tidak terjebak di layar hitam.
func _akhiri_sholat(fade_in: bool = false) -> void:
	# RONDE 18: tandai sesi ini sudah jalan (nama + jam mulai +
	# tanggal) — adegan selesai sebelum jendela 1 menit habis, jadi
	# tanpa kunci ini sesi langsung mulai lagi di sisa jendela.
	if _sholat_aktif:
		var mulai := _sholat_akhir_menit - 1
		var kunci := _sholat_nama + "_%02d:%02d_" % [mulai / 60, mulai % 60] + Time.get_date_string_from_system()
		_sholat_sudah[kunci] = true
	_sholat_aktif = false
	_ui.hide_sholat_banner()
	_ui.toast("Sholat " + _sholat_nama + " selesai.")
	if _pemain_ikut_sholat:
		_pemain_ikut_sholat = false
		_player.set_aksi("berdiri")
	for npc in _npcs:
		var fase := String(_npc_sholat_fase.get(npc, ""))
		if fase == "sholat" or fase == "ke_sajadah":
			_npc_sholat_fase[npc] = "pulang_dalam"
			# RONDE 20: Ustadzah pulang lewat pintu DALAM musholla
			# (bukan pintu Surau) — rute pulang_dalam dihitung dari
			# ruangan masing-masing.
			var pintu_dalam := _musholla_door if npc == _ustadzah else _interior_door
			var rute: Array[Vector3] = [pintu_dalam + Vector3(0, 0, 0.5)]
			npc.mulai_rute(rute)
		elif fase == "ke_pintu":
			_npc_sholat_fase[npc] = "pulang_luar"
			npc.mulai_rute(_rute_pulang(npc))
	if fade_in:
		_sholat_adegan = "selesai"
		_sholat_adegan_t = 0.0
	else:
		_sholat_adegan = ""
		_sholat_adegan_t = 0.0
		_ui.hide_blackout()


## Mesin adegan sholat sinematik (RONDE 18) — jalan tiap frame selama
## _sholat_adegan != "". Timer di waktu GAME (delta), bukan jam
## perangkat (supaya tes dengan debug_jam beku tetap jalan).
func _proses_adegan_sholat(delta: float) -> void:
	match _sholat_adegan:
		"kumpul":
			# Takbir mulai kalau SEMUA NPC sudah di sajadah (fase
			# "sholat" = sampai + pose takbir) — atau timeout 25 dtk
			# (NPC nyangkut di jalan; takbir jalan dengan yang ada).
			_sholat_adegan_t += delta
			var semua_sudah := true
			for npc in _npcs:
				# RONDE 20: satpam TIDAK ikut sholat — jangan ditunggu.
				if not npc.ikut_sholat():
					continue
				if String(_npc_sholat_fase.get(npc, "")) != "sholat":
					semua_sudah = false
					break
			if semua_sudah or _sholat_adegan_t >= KUMPUL_TIMEOUT_DETIK:
				_sholat_adegan = "takbir"
				_sholat_adegan_t = 0.0
				# Takbir dimulai = pendaftaran ikut DITUTUP.
				_ui.hide_sholat_banner()
		"takbir":
			_sholat_adegan_t += delta
			if _sholat_adegan_t >= TAKBIR_TAHAN_DETIK:
				_sholat_adegan = "gelap"
				_sholat_adegan_t = 0.0
				_ui.show_blackout()
		"gelap":
			_sholat_adegan_t += delta
			# Fade ke hitam 0,5 dtk, lalu tahan hitam sampai 2,5 dtk.
			_ui.set_blackout_alpha(clampf(_sholat_adegan_t / BLACKOUT_FADE_DETIK, 0.0, 1.0))
			if _sholat_adegan_t >= BLACKOUT_DETIK:
				# Selesai: sesi berakhir (NPC pulang, pemain berdiri)
				# TAPI layar tetap hitam dulu — fade masuk di bawah.
				_akhiri_sholat(true)
		"selesai":
			_sholat_adegan_t += delta
			# Fade masuk 0,8 dtk, lalu overlay hilang total.
			var a := 1.0 - clampf(_sholat_adegan_t / FADE_MASUK_DETIK, 0.0, 1.0)
			_ui.set_blackout_alpha(a)
			if _sholat_adegan_t >= FADE_MASUK_DETIK:
				_ui.hide_blackout()
				_sholat_adegan = ""
				_sholat_adegan_t = 0.0


## Posisi dunia sebuah sajadah — diambil dari scene SAAT ITU juga,
## JANGAN hardcode: ronde 14 memutar Surau, posisi sajadah ikut
## berubah; lookup runtime selalu benar.
func _posisi_sajadah(nama_node: String) -> Vector3:
	var node := _interior_root.find_child(nama_node, true, false)
	if node is Node3D:
		return (node as Node3D).global_position
	return _interior_spawn


## RONDE 16 — posisi imam: tengah baris depan (Sajadah_03) + arah
## kiblat × IMAM_JARAK_DEPAN. Lookup runtime (seperti _posisi_sajadah)
## supaya rotasi Surau ronde 14 tetap benar otomatis; arah kiblat
## dari KIBLAT_YAW (wajah karakter di +Z lokal).
func _posisi_imam() -> Vector3:
	var tengah := _posisi_sajadah("Sajadah_03")
	var arah := Vector3(sin(KIBLAT_YAW), 0, cos(KIBLAT_YAW))
	return tengah + arah * IMAM_JARAK_DEPAN


## RONDE 20 — posisi sajadah di dalam Musholla Ar-Raudhah (lookup
## runtime di _musholla_root, pola _posisi_sajadah untuk Surau).
func _posisi_sajadah_musholla(nama_node: String) -> Vector3:
	var node := _musholla_root.find_child(nama_node, true, false)
	if node is Node3D:
		return (node as Node3D).global_position
	return _musholla_spawn


## RONDE 20 — posisi imam PUTRI: tengah baris depan musholla
## (Sajadah_03) + arah kiblat × IMAM_JARAK_DEPAN. Ustadzah Mariyah
## memimpin sholat putri dari sini (Mas 15:56 WIB).
func _posisi_imam_musholla() -> Vector3:
	var tengah := _posisi_sajadah_musholla("Sajadah_03")
	var arah := Vector3(sin(KIBLAT_YAW), 0, cos(KIBLAT_YAW))
	return tengah + arah * IMAM_JARAK_DEPAN


## RONDE 21 — rute jalan kaki Ustadzah Mariyah ke pintu Musholla
## Ar-Raudhah (kampus putri BARU, Opsi A). Sederhana: dari area
## putri -> (134,-14) selatan musholla -> depan pintu (_musholla_exit,
## dari dict build — pintu + keluar x 1,5 m). Kalau dari utara
## musholla (z < -14, seharusnya tidak terjadi — patroli putri di
## selatan), keluar ke z=-14 dulu supaya tidak menembus musholla.
## Tidak ada koridor barat/timur: area putri terbuka, satu-satunya
## bangunan di jalur ini adalah musholla itu sendiri. Titik selatan
## lama (18,-14) ikut pindah ke (134,-14) mengikuti Musholla
## (18,-24) -> (134,-24); z=-14 tetap (pusat musholla z-nya sama).
func _rute_ke_pintu_musholla(dari: Vector3) -> Array[Vector3]:
	var rute: Array[Vector3] = []
	if dari.z < -14.0:
		rute.append(Vector3(dari.x, 0, -14.0))
	# RONDE 22 (Sinta): tembok keliling kampus putri (x=115,
	# z -52..+22; gerbang barat (115,0)). Kalau Ustadzah kebetulan di
	# barat tembok, garis lurus ke (134,-14) MEMOTONG tembok di
	# (115,-14) — belok lewat gerbang dulu: (18,-14) -> (115,0) ->
	# (134,-14). Mekanisme rute mendukung waypoint perantara
	# (mulai_rute menerima Array[Vector3]).
	if dari.x < 115.0:
		rute.append(Vector3(115, 0, 0))
	rute.append(Vector3(134, 0, -14.0))
	rute.append(_musholla_exit)
	return rute


## Rute jalan kaki NPC ke pintu Surau — SEGMENTASI (Manhattan),
## bukan garis lurus: garis lurus dari utara akan menembus dinding
## Surau/cangkruk. Koridor aman: z <= -27 (utara kedua bangunan),
## x <= -28 (barat Surau + cangkruk), z >= 2 (plaza selatan, terbuka).
## RONDE 21 (Sinta): koridor utara PINDAH -22 -> -27 — Surau geser
## ke (0,-14) dan sudut barat lautnya kini di z=-25,48, jadi garis
## z=-22 MEMOTONG tapak Surau (x -7,30..1,77). Koridor barat PINDAH
## -20 -> -28 — cangkruk pindah ke (-22,-18), membentang x -27..-17,
## z -22..-14; koridor lama x=-20 menembus cangkruk baru. Koridor
## baru x=-28: 1 m di barat dinding cangkruk, 2 m dari pohon (-26,-8)
## dan lampu (-30,-2); pohon (-20,-26) + lampu (-20,-28) kini di
## timur koridor (koridor lama x=-20 akan menabrak pohon itu kalau
## diperpanjang ke utara). Titik plaza (-2,2) TETAP — 7,3 m di selatan
## dinding selatan Surau, segmen (-2,2) -> depan pintu tidak menabrak
## dinding (terverifikasi geometris: kedua ujung di sisi luar).
## Urutan: (1) ke koridor utara z=-27 kalau masih di utara;
## (2) ke barat x=-28; (3) ke selatan sampai plaza (z=2);
## (4) ke depan pintu (-2, 2); (5) depan pintu (pintu + 1,5 m ke
## arah luar/plaza — RONDE 21: (-4.01,-5.39), bukan (-2.75,-6.11) lagi).
## BATASAN (jujur): NPC yang PERSIS di dalam tapak bangunan saat sesi
## mulai (transien keliling bebas yang memang sudah menembus dinding
## di segmen (8,-2)<->(0,-20)) tetap jalan lurus keluar — kasus langka,
## sama seperti keliling bebas yang sudah ada.
func _rute_ke_pintu_surau(dari: Vector3) -> Array[Vector3]:
	var rute: Array[Vector3] = []
	if dari.z < -7.0:
		if dari.z > -27.0:
			rute.append(Vector3(dari.x, 0, -27.0))
		if dari.x > -28.0:
			rute.append(Vector3(-28, 0, -27.0))
		rute.append(Vector3(-28, 0, 2.0))
	rute.append(Vector3(-2, 0, 2.0))
	# REVISI (Mas 17 Nov 22:51 WIB: Surau lurus) — KOREKSI 23:15 WIB
	# (lurus = -90°): titik akhir rute = depan pintu (0,-3.8) +
	# 1,5 m ke selatan = (0,-2.3) (di atas lantai serambi).
	# Segmen (-2,2) -> (0,-2.3) tidak menabrak dinding depan
	# (z=-4) — segmen berakhir 1,5 m di selatannya.
	rute.append(_outdoor_door + _surau_keluar * 1.5)
	return rute


## Rute pulang NPC dari plaza luar ke posisi rumah (disimpan saat sesi
## mulai). Rumah di utara dicapai lewat koridor barat + utara, bukan
## diagonal menembus Surau dari plaza.
## RONDE 21: koridor barat putra -20 -> -28 (cangkruk pindah ke
## (-22,-18); koridor utara -22 -> -27 (Surau geser ke (0,-14)));
## plaza (-2,2) tetap (di barat tembok). Ustadzah
## Mariyah pulang ke area PUTRI BARU dengan rute SENDIRI: dari pintu
## musholla baru (_musholla_exit, dari dict build) keluar ke selatan
## dulu (134,-14) lalu langsung ke rumah — tanpa koridor barat/plaza
## putra (rute putra dari pintu musholla akan menembus musholla +
## tembok).
func _rute_pulang(npc: SantriNPC) -> Array[Vector3]:
	var rumah: Vector3 = _npc_rumah.get(npc, PesantrenBuilder.SPAWN)
	var rute: Array[Vector3] = []
	var dari := npc.global_position
	if npc == _ustadzah:
		# RONDE 21: Area putri BARU (timur tembok x=14) — satu-satunya
		# bangunan di jalur pulang adalah musholla baru (134,-24).
		# Keluar dari utara musholla lewat (134,-14) selatan musholla.
		# RONDE 22 (Sinta): tembok keliling kampus putri (x=115,
		# gerbang barat (115,0)) — kalau Ustadzah dan rumahnya di sisi
		# berlawanan tembok, garis lurus memotong tembok: lewat
		# gerbang dulu. Normalnya keduanya di dalam keliling (rumah
		# (134,-17)); ini pengaman posisi transien di barat tembok.
		if (dari.x < 115.0) != (rumah.x < 115.0):
			if dari.z < -14.0:
				rute.append(Vector3(dari.x, 0, -14.0))
			rute.append(Vector3(115, 0, 0))
			if rumah.z < -14.0:
				rute.append(Vector3(134, 0, -14.0))
			rute.append(rumah)
			return rute
		if dari.z < -14.0:
			rute.append(Vector3(134, 0, -14.0))
		rute.append(rumah)
		return rute
	if dari.z < -7.0:
		# Masih di utara (tidak seharusnya dari pintu keluar, tapi
		# aman): keluar ke koridor utara dulu.
		if dari.z > -27.0:
			rute.append(Vector3(dari.x, 0, -27.0))
		if dari.x > -28.0:
			rute.append(Vector3(-28, 0, -27.0))
		rute.append(Vector3(-28, 0, 2.0))
	elif rumah.z < -7.0:
		# Rumah di utara: lewat koridor barat + utara.
		rute.append(Vector3(-28, 0, 2.0))
		rute.append(Vector3(-28, 0, -27.0))
		if rumah.x > -28.0:
			rute.append(Vector3(rumah.x, 0, -27.0))
		rute.append(rumah)
		return rute
	if rumah.distance_to(Vector3(-2, 0, 2.0)) > 0.5:
		rute.append(Vector3(-2, 0, 2.0))
	rute.append(rumah)
	return rute


## NPC selesai satu rute — lanjutkan mesin fase sholatnya.
func _on_npc_rute_selesai(npc: SantriNPC) -> void:
	match String(_npc_sholat_fase.get(npc, "")):
		"ke_pintu":
			# Sampai di depan pintu luar -> pindah ke interior (ala
			# GTA, sama seperti pemain masuk Surau — bukan menembus
			# dinding). Interior tetap tersembunyi kalau pemain di
			# luar; NPC sudah "di dalam" saat pemain masuk nanti.
			# RONDE 20: Ustadzah masuk ke MUSHOLLA (bukan Surau).
			if npc == _ustadzah:
				npc.global_position = _musholla_spawn
			else:
				npc.global_position = _interior_spawn
			_npc_sholat_fase[npc] = "ke_sajadah"
			var tujuan: Array[Vector3] = [_sajadah_npc.get(npc, _interior_spawn)]
			npc.mulai_rute(tujuan)
		"ke_sajadah":
			_npc_sholat_fase[npc] = "sholat"
			npc.mulai_pose_sholat(KIBLAT_YAW)
		"pulang_dalam":
			# Sampai di pintu dalam -> keluar ke plaza luar.
			# RONDE 20: Ustadzah keluar ke pintu LUAR musholla.
			if npc == _ustadzah:
				npc.global_position = _musholla_exit
			else:
				npc.global_position = _outdoor_exit
			_npc_sholat_fase[npc] = "pulang_luar"
			npc.mulai_rute(_rute_pulang(npc))
		"pulang_luar":
			_npc_sholat_fase[npc] = ""
			npc.selesai_sholat()


## Pemain menekan "IKUT SHOLAT" di banner: antar ke Surau (teleport
## ala GTA, sama seperti masuk lewat pintu) — pemain yang sedang di
## cangkruk pun langsung dipindah, tidak jalan kaki 300 m; ini
## undangan sholat, bukan paksaan (banner bisa diabaikan). Pemain
## yang sedang tidur dibangunkan dulu; panel apa pun ditutup supaya
## langsung melihat saf sholat.
func _on_ikut_sholat() -> void:
	if not _sholat_aktif:
		return
	# RONDE 18: ikut hanya selama "kumpul" — begitu takbir dimulai,
	# banner disembunyikan dan pendaftaran ikut ditutup.
	if _sholat_adegan != "kumpul":
		return
	_ui.hide_sholat_banner()
	if _player.aksi_saat_ini() == "tidur":
		_player.set_aksi("berdiri")
		# ASRAMA PUTRI: bangun lewat jalur ini melewati _on_aksi —
		# aktifkan lagi body kasur yang dimatikan saat tidur.
		_aktifkan_lagi_kasur_tidur()
		_cam_pitch = -0.35
		_rig.global_position = _player.global_position + Vector3(0, 1.6, 0)
		_spring.rotation.x = _cam_pitch
	if _ui.is_mission_visible():
		_ui.close_mission()
	if _ui.is_smartboard_visible():
		_ui.close_smartboard()
	if _ui.is_dashboard_visible():
		_ui.close_dashboard()
	if _ui.is_peta_visible():
		_ui.close_peta()
	if _ui.is_chat_visible():
		_ui.close_chat()
	if _ui.is_aksi_visible():
		_ui.close_aksi()
	if _ui.is_outfit_visible():
		_ui.close_outfit()
	# RONDE PERBAIKAN (Raka, integrasi item 7f + 15): pemain PUTRI
	# ikut sholat di Musholla (bukan Surau) — sajadah + flag + interior
	# mengikuti gender; Ustadzah sudah memimpin dari sana (lihat
	# _mulai_sholat: Ustadzah -> _posisi_imam_musholla).
	var putri := _pemain_adalah_putri()
	var sajadah := _posisi_sajadah_musholla("Sajadah_03") if putri else _posisi_sajadah("Sajadah_03")
	_di_dalam_cangkruk = false
	_di_dalam = not putri
	_di_dalam_musholla = putri
	_set_interior_terlihat(not putri, false, putri)
	_set_sandal_ruangan(true)
	_player.set_facing(KIBLAT_YAW)
	_player.global_position = sajadah
	_player.velocity = Vector3.ZERO
	_player.set_aksi("sholat")
	# Kamera di belakang pemain (menghadap kiblat = melihat mihrab).
	_cam_yaw = fmod(KIBLAT_YAW + PI, TAU)
	_cam_pitch = -0.35
	_rig.global_position = sajadah + Vector3(0, 1.6, 0)
	_rig.rotation.y = _cam_yaw
	_spring.rotation.x = _cam_pitch
	_pemain_ikut_sholat = true
	_ui.toast("Kamu ikut sholat " + _sholat_nama + " berjamaah.")


# ---------- smartboard (RONDE 4) ----------
func _on_slide_changed(index: int) -> void:
	# RONDE 10 (Mas: "Tulisan di smartboard dihapus"): papan 3D
	# smartboard di dalam Surau kini BERSIH — fungsi ini TIDAK LAGI
	# menulis judul/ringkas slide ke Label3D SmartboardScreen.
	# Konten slide tetap tampil di popup UI (ui.gd open_smartboard).
	# Fungsi dipertahankan sebagai no-op supaya koneksi signal
	# slide_changed (baris _ready) tidak perlu diubah.
	pass


# ======================================================================
# MULTIPLAYER FASE 1 (Wira, 18 Nov 2026 — langkah 9 prep §1.6)
# ======================================================================
## Titik spawn MP sesuai gender — dari kode dunia (JANGAN karang):
## putra PesantrenBuilder.SPAWN (-4,14), putri KampusPutri.SPAWN_PUTRI
## (140,0,16). Dipakai NetworkManager.spawn_player (Saka) + tes.
static func mp_titik_spawn(putri: bool) -> Vector3:
	return KampusPutri.SPAWN_PUTRI if putri else PesantrenBuilder.SPAWN


## Cari NetworkManager (autoload /root/NetworkManager, Saka) bila ada.
## null = belum disediakan — semua pemakaian dijaga supaya game tetap
## jalan offline.
func _mp_network_manager() -> Node:
	return get_node_or_null("/root/NetworkManager")


## Cari MpBootstrap (autoload Fase 0) bila ada — pemegang tiket.
func _mp_bootstrap() -> Node:
	return get_node_or_null("/root/MpBootstrap")


## Pasang node Players + MultiplayerSpawner (akhir _ready). Spawner
## anak Main; spawn_path ^"../Players" (TERBUKTI probe headless —
## ^"Players" gagal "Cannot find spawn node" karena engine mencari
## relatif terhadap spawner). spawn_function = NetworkManager.
## spawn_player HANYA bila node + method itu sudah ada; bila belum,
## spawner dibiarkan tanpa spawn_function + dicatat di log (mode
## offline saja — game tidak crash).
func _mp_pasang_players() -> void:
	_players = Node.new()
	_players.name = "Players"
	add_child(_players)
	_spawner = MultiplayerSpawner.new()
	_spawner.name = "MultiplayerSpawner"
	_spawner.spawn_path = ^"../Players"
	add_child(_spawner)
	var nm := _mp_network_manager()
	if nm != null and nm.has_method("spawn_player"):
		_spawner.spawn_function = Callable(nm, "spawn_player")
		print("[MP] spawner terhubung ke NetworkManager.spawn_player")
	else:
		print("[MP] NetworkManager.spawn_player belum ada — spawner tanpa spawn_function (mode offline saja)")
	multiplayer.peer_connected.connect(_mp_saat_peer_connected)
	multiplayer.peer_disconnected.connect(_mp_saat_peer_disconnected)
	multiplayer.connected_to_server.connect(_mp_saat_connected_to_server)
	multiplayer.connection_failed.connect(_mp_saat_connection_failed)
	multiplayer.server_disconnected.connect(_mp_saat_server_disconnected)
	# Sinyal bisa sudah lewat sebelum handler terpasang (_ready dunia
	# ~58 dtk di VM, handshake WebSocket hanya 1-2 dtk): bila peer
	# sudah tersambung saat ini, jalankan logika connected sekarang.
	if multiplayer.multiplayer_peer is WebSocketMultiplayerPeer and multiplayer.get_unique_id() != 0 and not multiplayer.is_server():
		_mp_saat_connected_to_server()
	if "--mp-test-zona" in OS.get_cmdline_user_args():
		_mp_validasi_klien_mati = true
		print("[MP-TEST] validasi zona klien DIMATIKAN (argumen --mp-test-zona) — penolakan harus datang dari server")


## Titik "Masuk Dunia": dipanggil akhir _masuk_pesantren() (setelah
## login/daftar/lanjut). NetworkManager yang connect + submit_ticket;
## file ini hanya (a) menyiapkan tiket, (b) memberi status ke UI.
## Mode CLI/smoke (--mp-join): koneksi sudah diminta MpBootstrap di
## _ready autoload — di sini hanya minta tiket + update status.
func _mp_mulai() -> void:
	if _mp_status != "offline":
		return
	if multiplayer.multiplayer_peer is WebSocketMultiplayerPeer:
		_mp_set_status("menghubungkan")
		_mp_minta_tiket()
		return
	var nm := _mp_network_manager()
	if nm == null:
		print("[MP] NetworkManager belum ada — tetap offline (game jalan normal)")
		_mp_set_status("offline")
		return
	if not nm.has_method("hubungkan"):
		print("[MP] NetworkManager ada tapi tanpa method hubungkan — tetap offline (kontrak hubungkan belum dipenuhi Saka)")
		_mp_set_status("offline")
		return
	_mp_set_status("menghubungkan")
	# Tanpa token sesi (lanjut tersimpan / baru daftar — hanya login
	# langsung yang mengisi _session_token), login diam-diam dulu
	# pakai ig_username tersimpan; tiket + hubungkan jalan dari
	# handler-nya. Tanpa ini pemain yang tidak login langsung TIDAK
	# PERNAH dapat tiket -> server menolak -> status Offline selamanya
	# tanpa jalan masuk (temuan 18 Nov 2026: "Belum bisa main
	# multiplayer", Mas: "Dimana itu?").
	if _session_token == "":
		if _mp_login_diam_diam():
			return
		_mp_set_status("offline")
		_ui.toast("Masuk dulu sebagai santri untuk main bersama.")
		return
	_mp_minta_tiket()
	nm.hubungkan(MP_WSS_URL)


## Tombol "Main Bersama" di HUD (Dimas, 18 Nov 2026): jalan masuk
## multiplayer yang terlihat. _mp_mulai sudah dijaga (abaikan bila
## status bukan offline), jadi ketukan ganda aman.
func _on_mp_gabung_ditekan() -> void:
	if _mp_status != "offline":
		return
	print("[MP] tombol Main Bersama ditekan — memulai multiplayer")
	_mp_mulai()


## Login diam-diam untuk multiplayer (Dimas, 18 Nov 2026): ambil token
## sesi baru lewat POST /api/santri/login dengan ig_username tersimpan
## (tanpa kata sandi — kontrak login mengizinkan username saja).
## Dipakai _mp_mulai bila _session_token kosong (lanjut tersimpan /
## baru daftar). TIDAK menyentuh _save / UI login — hanya token.
## Mengembalikan true bila request dimulai (lanjutan di handler),
## false bila tidak ada ig_username tersimpan.
func _mp_login_diam_diam() -> bool:
	if _mp_login_diam_http != null:
		return true
	var ig := SantriSave.normalisasi_ig(String(_save.get("ig_username", "")))
	if ig == "":
		print("[MP] tidak ada ig_username tersimpan — login diam-diam tidak mungkin")
		return false
	var http := HTTPRequest.new()
	http.timeout = LOGIN_TIMEOUT_DETIK
	_mp_login_diam_http = http
	add_child(http)
	http.request_completed.connect(_mp_saat_login_diam_diam_selesai)
	var err := http.request(
		SERVER_BASE_URL + "/api/santri/login",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify({"ig_username": ig})
	)
	if err != OK:
		_mp_login_diam_http = null
		http.queue_free()
		print("[MP] login diam-diam gagal dikirim: %s" % error_string(err))
		return false
	print("[MP] login diam-diam untuk %s ..." % ig)
	return true


func _mp_saat_login_diam_diam_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _mp_login_diam_http
	_mp_login_diam_http = null
	if http != null:
		http.queue_free()
	if _mp_status != "menghubungkan":
		return
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[MP] login diam-diam gagal (result=%d, http=%d) — tetap offline" % [result, response_code])
		_mp_set_status("offline")
		_ui.toast("Tidak bisa masuk multiplayer. Periksa koneksi, lalu ketuk Main Bersama lagi.")
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary):
		print("[MP] jawaban login diam-diam tidak dapat dibaca — tetap offline")
		_mp_set_status("offline")
		return
	# API mengembalikan token sesi di field "session" (BUKAN "token" —
	# koreksi Dimas 18 Nov 2026: baca "token" selalu "" sehingga
	# login diam-diam gagal dan multiplayer tetap offline).
	var token := _str_atau(parsed as Dictionary, "session", _str_atau(parsed as Dictionary, "token"))
	if token == "":
		print("[MP] login diam-diam tanpa token — tetap offline")
		_mp_set_status("offline")
		_ui.toast("Tidak bisa masuk multiplayer. Coba masuk ulang, lalu ketuk Main Bersama lagi.")
		return
	_session_token = token
	print("[MP] login diam-diam berhasil — token sesi diterima (nilai disembunyikan)")
	_mp_minta_tiket()
	var nm := _mp_network_manager()
	if nm != null and nm.has_method("hubungkan"):
		nm.hubungkan(MP_WSS_URL)
	else:
		print("[MP] NetworkManager/hubungkan hilang saat login diam-diam selesai — tetap offline")
		_mp_set_status("offline")


## Minta tiket realtime (REST publik, cara (a) — Saka): POST
## /api/santri/realtime_ticket body {"session": token sesi login}.
## Tiket disimpan ke MpBootstrap.set_ticket() (seam yang didokumentasi
## mp_bootstrap.gd) — TIDAK PERNAH ditulis ke log, TIDAK PERNAH
## dikirim ke pemain lain. Dilewati bila tiket sudah ada (mode CLI
## --mp-ticket) atau bila tidak ada token sesi (login lokal/tamu).
func _mp_minta_tiket() -> void:
	var bs := _mp_bootstrap()
	if bs != null and String(bs.get("ticket")) != "":
		return
	if _session_token == "":
		print("[MP] tidak ada token sesi — tiket realtime tidak diminta")
		return
	if _mp_ticket_http != null:
		return
	var http := HTTPRequest.new()
	http.timeout = LOGIN_TIMEOUT_DETIK
	_mp_ticket_http = http
	add_child(http)
	http.request_completed.connect(_mp_saat_tiket_selesai)
	var err := http.request(
		SERVER_BASE_URL + "/api/santri/realtime_ticket",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify({"session": _session_token})
	)
	if err != OK:
		_mp_ticket_http = null
		http.queue_free()
		print("[MP] gagal meminta tiket realtime: %s" % error_string(err))


func _mp_saat_tiket_selesai(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http := _mp_ticket_http
	_mp_ticket_http = null
	if http != null:
		http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[MP] tiket realtime gagal (result=%d, http=%d) — tetap offline" % [result, response_code])
		_mp_set_status("offline")
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary) or String((parsed as Dictionary).get("ticket", "")) == "":
		print("[MP] jawaban tiket realtime tidak dapat dibaca — tetap offline")
		_mp_set_status("offline")
		return
	var bs := _mp_bootstrap()
	if bs != null and bs.has_method("set_ticket"):
		bs.set_ticket(String((parsed as Dictionary)["ticket"]))
		print("[MP] tiket realtime diterima (nilai disembunyikan) — handshake milik NetworkManager")


## --- Handler sinyal multiplayer (status + log; submit_ticket MILIK
## NetworkManager — file ini tidak mengirim tiket sendiri) ---
func _mp_saat_connected_to_server() -> void:
	print("[MP] connected_to_server (peer id saya: %d)" % multiplayer.get_unique_id())
	_mp_set_status("menghubungkan")
	var nm := _mp_network_manager()
	if nm == null:
		print("[MP] BLOKIR: NetworkManager belum ada — submit_ticket tidak terkirim, server tidak akan spawn avatar (menunggu Saka)")
	else:
		print("[MP] NetworkManager ada — handshake tiket (submit_ticket) milik NetworkManager")
	_mp_perbarui_ui_pemain()


func _mp_saat_connection_failed() -> void:
	print("[MP] connection_failed — tetap offline (game jalan normal)")
	_mp_set_status("offline")


func _mp_saat_server_disconnected() -> void:
	print("[MP] server_disconnected — kembali ke avatar lokal (offline)")
	_mp_kembalikan_lokal()


func _mp_saat_peer_connected(id: int) -> void:
	print("[MP] peer_connected %d — avatar di Players: %d" % [id, _mp_jumlah_pemain()])
	_mp_perbarui_ui_pemain()


func _mp_saat_peer_disconnected(id: int) -> void:
	print("[MP] peer_disconnected %d — avatar di Players: %d" % [id, _mp_jumlah_pemain()])
	if id == multiplayer.get_unique_id():
		_mp_kembalikan_lokal()
	_mp_perbarui_ui_pemain()


## Per-frame (dipanggil awal _process): adopsi avatar sendiri dari
## Players + refresh UI/log berkala. Tanpa koneksi (offline) langsung
## kembali — nol biaya untuk mode offline.
func _mp_proses_frame(delta: float) -> void:
	if _mp_status == "offline":
		return
	if _mp_avatar_sendiri == null:
		_mp_adopsi_avatar_sendiri()
	_mp_log_timer += delta
	if _mp_log_timer >= 2.0:
		_mp_log_timer = 0.0
		_mp_perbarui_ui_pemain()
		if _mp_status == "online":
			print("[MP] pemain terlihat: %s" % _mp_daftar_pemain_log())


## Cari anak Players yang namanya = str(peer id sendiri); bila ada,
## jadikan _player (kamera + semua sistem main.gd otomatis mengikuti
## avatar itu) dan sembunyikan avatar lokal offline (jangan
## queue_free — dipakai lagi bila koneksi putus).
func _mp_adopsi_avatar_sendiri() -> void:
	if _players == null or _mp_avatar_sendiri != null:
		return
	var saya := str(multiplayer.get_unique_id())
	if saya == "0":
		return
	var node := _players.get_node_or_null(saya)
	if node == null:
		return
	if not (node is SantriPlayer):
		print("[MP] avatar sendiri di Players bukan SantriPlayer: %s" % node.get_class())
		return
	_mp_pemain_lokal = _player
	_mp_pemain_lokal.visible = false
	_mp_pemain_lokal.process_mode = Node.PROCESS_MODE_DISABLED
	_mp_avatar_sendiri = node
	_player = node
	if not _player.langkah.is_connected(_saat_langkah):
		_player.langkah.connect(_saat_langkah)
	# Nama + outfit avatar MP milik server (data DB saat spawn) —
	# TIDAK ditimpa dari save lokal di sini.
	_pos_legal_terakhir = _player.global_position
	_punya_pos_legal = true
	_mp_set_status("online")
	print("[MP] avatar sendiri diadopsi: peer %s di %s" % [saya, str(_player.global_position)])


## Kembali ke avatar lokal offline (putus server / peer sendiri hilang).
func _mp_kembalikan_lokal() -> void:
	if _mp_pemain_lokal == null:
		_mp_set_status("offline")
		return
	if _mp_avatar_sendiri != null and is_instance_valid(_mp_avatar_sendiri):
		if _mp_avatar_sendiri.langkah.is_connected(_saat_langkah):
			_mp_avatar_sendiri.langkah.disconnect(_saat_langkah)
	_player = _mp_pemain_lokal
	_mp_pemain_lokal.visible = true
	_mp_pemain_lokal.process_mode = Node.PROCESS_MODE_INHERIT
	_mp_avatar_sendiri = null
	_mp_pemain_lokal = null
	_pos_legal_terakhir = _player.global_position
	_punya_pos_legal = true
	_mp_set_status("offline")
	print("[MP] kembali ke avatar lokal (offline)")


## Seam untuk NetworkManager: server menolak posisi (zone_reject RPC)
## -> snap-back ke posisi legal. Dipanggil NetworkManager, bukan
## dari logika lokal. Mencatat flag untuk tes headless.
func _mp_terapkan_zone_reject(pos_legal: Vector3) -> void:
	_player.global_position = pos_legal
	_player.velocity = Vector3.ZERO
	_pos_legal_terakhir = pos_legal
	_punya_pos_legal = true
	_mp_zone_reject_diterima = true
	_mp_zone_reject_pos = pos_legal
	print("[MP] zone_reject dari server — snap-back ke %s" % str(pos_legal))
	_ui.toast("Server mengembalikanmu ke area yang benar.")


## --- UI + log ---
func _mp_jumlah_pemain() -> int:
	if _players == null:
		return 1
	return maxi(1, _players.get_child_count())


func _mp_nama_avatar(node: Node) -> String:
	var v: Variant = node.get("_nama")
	if v is String and String(v) != "":
		return String(v)
	var lbl: Variant = node.get("_name_label")
	if lbl is Label3D and String((lbl as Label3D).text) != "":
		return String((lbl as Label3D).text)
	return String(node.name)


func _mp_set_status(status: String) -> void:
	_mp_status = status
	_mp_perbarui_ui_pemain()


# Daftar nama pemain online DIHAPUS 19 Nov 2026 (keputusan Mas 12:32 WIB
# — "list nama player online ga perlu"). Fungsi ini kini hanya
# memperbarui indikator status koneksi ("Online (N pemain)").
func _mp_perbarui_ui_pemain() -> void:
	if _ui == null:
		return
	_ui.set_mp_status(_mp_status, _mp_jumlah_pemain())


func _mp_daftar_pemain_log() -> String:
	var bagian: Array[String] = []
	if _players != null:
		for c in _players.get_children():
			if c is Node3D:
				var p := (c as Node3D).global_position
				bagian.append("%s=%s@(%.1f,%.1f,%.1f)" % [String(c.name), _mp_nama_avatar(c), p.x, p.y, p.z])
	return ", ".join(bagian) if not bagian.is_empty() else "(tidak ada)"
