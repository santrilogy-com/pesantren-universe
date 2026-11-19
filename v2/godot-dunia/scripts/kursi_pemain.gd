class_name KursiPemain
## Registry kursi duduk PEMAIN (Gilang, 20 Nov 2026 — permintaan Mas
## 00:24 WIB: "bisa duduk di kursi taman dll").
##
## Survei semua kursi/bangku di dunia putra + putri yang layak
## diduduki pemain. Pola mengikuti registry kursi NPC
## (SantriNPC.KURSI_LUAR / KURSI_DALAM): tiap entri
## {id, pos, yaw, gedung, jenis, putri, dalam, bangun, lantai_y,
##  npc_id, pintu_luar, pintu_dalam, spawn_dalam}.
## - pos: posisi DUDUK (y = tinggi duduk: kursi 0,45 / kasur 0,51 /
##   bersila = lantai_y).
## - yaw: hadap saat duduk (0 = +z/selatan, PI = -z/utara,
##   PI/2 = +x/timur, -PI/2 = -x/barat).
## - jenis: "kursi" (bangku/kursi kayu) / "bersila" (lantai) / "kasur".
## - bangun: titik BERDIRI setelah bangun dari kursi (y = lantai_y).
##   Kursi: 0,8 m ke arah hadap, ATAU lorong samping bila depannya
##   meja (kursi kelas: bangun di lorong antar-kolom x=118,65 /
##   121,35 — bangun ke depan mendarat DI DALAM meja). Bersila:
##   bangun = posisi yang sama (berdiri di tempat). Kasur: 1,5 m
##   ke selatan kaki kasur (celah antar-kasur / koridor).
## - lantai_y: lantai visual di titik bangun (0, kecuali serambi
##   Musholla 0,05). Dalam interior = 0.
## - npc_id: id di registry NPC bila kursi ini JUGA dipakai NPC
##   (28 dari 42 entri). Wiring HARUS cek SantriNPC._kursi_registry
##   sebelum mendudukkan pemain di kursi berbagi — jangan duduki
##   kursi yang sedang diklaim NPC. npc_id "" = khusus pemain.
## - dalam=true: kursi di interior — pemain masuk lewat pintu_luar
##   (teleport ke spawn_dalam, pola GTA patroli Kyai).
##
## WIRING DITUNDA — DEPENDENSI KIRANA: JANGAN wiring kursi-kursi ini
## ke pose "duduk" (bersila) lama. Pose duduk-kursi yang benar
## (kaki menjuntai, bukan bersila) + logika turun-ke-lantai saat
## berdiri dari kursi sedang diperbaiki Kirana (bug laporan Mas
## yang sama: duduk di kursi malah bersila, berdiri dari kursi
## malah berdiri DI ATAS kursi). Wiring interaksi duduk dilakukan
## SETELAH Kirana melaporkan nama pose/API duduk_kursi barunya.
##
## DIKELUARKAN dari registry (bukan untuk pemain):
## - Kursi Kyai (Surau), Kursi Ustadzah (Musholla), Kursi Ustadzah
##   (Kelas Putri), Kursi Guru (Madrasah), Kursi Kerja (Kantor
##   Ustadzah), Kursi Jaga (Pos Jaga) — kursi guru/penjaga/otoritas
##   (NPC registry juga mengecualikan kursi Kyai/Ustadzah/Guru,
##   desain §6). Kursi Kerja Kantor Ustadzah juga dikecualikan
##   (kursi Ustadzah); kursi peserta tes ditambah konsep tes Laras.
## - Kantor Putra: BELUM ADA interior/kursi (cangkang saja; konsep
##   tes Laras — pemain duduk berhadapan juri di dalam kantor).
## - Kelas Putra, Kantin, Perpustakaan, Masjid Besar: BELUM DIBANGUN
##   (rencana/lahan berpapan) — tidak ada kursi di game.
## - Plaza: TIDAK ADA bangku (hanya spawn + peti M3).
## Isi: 42 entri = 28 berbagi NPC + 14 khusus pemain
## (12 kursi Kelas Putri baris utara+tengah + 2 kursi Studio).
const KURSI_PEMAIN: Array[Dictionary] = [
	# --- Taman Putra: bangku 1 (sumbu X, hadap selatan) ---
	{"id": "bangku_taman_putra_1a", "pos": Vector3(-3.4, 0.45, 25.45), "yaw": 0.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "bangun": Vector3(-3.4, 0, 26.25), "lantai_y": 0.0, "npc_id": "bangku_taman_putra_1a"},
	{"id": "bangku_taman_putra_1b", "pos": Vector3(-2.6, 0.45, 25.45), "yaw": 0.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "bangun": Vector3(-2.6, 0, 26.25), "lantai_y": 0.0, "npc_id": "bangku_taman_putra_1b"},
	# --- Taman Putra: bangku 2 (sumbu Z, hadap barat) ---
	{"id": "bangku_taman_putra_2a", "pos": Vector3(3.45, 0.45, 27.8), "yaw": -PI / 2.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "bangun": Vector3(2.65, 0, 27.8), "lantai_y": 0.0, "npc_id": "bangku_taman_putra_2a"},
	{"id": "bangku_taman_putra_2b", "pos": Vector3(3.45, 0.45, 28.6), "yaw": -PI / 2.0, "gedung": "taman_putra", "jenis": "kursi", "putri": false, "dalam": false, "bangun": Vector3(2.65, 0, 28.6), "lantai_y": 0.0, "npc_id": "bangku_taman_putra_2b"},
	# --- Taman Putri: bangku utara (hadap selatan) ---
	{"id": "bangku_taman_putri_utara_a", "pos": Vector3(121.6, 0.45, 30.4), "yaw": 0.0, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "bangun": Vector3(121.6, 0, 31.2), "lantai_y": 0.0, "npc_id": "bangku_taman_putri_utara_a"},
	{"id": "bangku_taman_putri_utara_b", "pos": Vector3(122.4, 0.45, 30.4), "yaw": 0.0, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "bangun": Vector3(122.4, 0, 31.2), "lantai_y": 0.0, "npc_id": "bangku_taman_putri_utara_b"},
	# --- Taman Putri: bangku selatan (hadap utara) ---
	{"id": "bangku_taman_putri_selatan_a", "pos": Vector3(121.6, 0.45, 33.6), "yaw": PI, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "bangun": Vector3(121.6, 0, 32.8), "lantai_y": 0.0, "npc_id": "bangku_taman_putri_selatan_a"},
	{"id": "bangku_taman_putri_selatan_b", "pos": Vector3(122.4, 0.45, 33.6), "yaw": PI, "gedung": "taman_putri", "jenis": "kursi", "putri": true, "dalam": false, "bangun": Vector3(122.4, 0, 32.8), "lantai_y": 0.0, "npc_id": "bangku_taman_putri_selatan_b"},
	# --- Serambi Surau: bersila di plaza selatan, hadap Surau ---
	{"id": "serambi_surau_a", "pos": Vector3(-2, 0, 2), "yaw": PI, "gedung": "serambi_surau", "jenis": "bersila", "putri": false, "dalam": false, "bangun": Vector3(-2, 0, 2), "lantai_y": 0.0, "npc_id": "serambi_surau_a"},
	{"id": "serambi_surau_b", "pos": Vector3(2, 0, 2), "yaw": PI, "gedung": "serambi_surau", "jenis": "bersila", "putri": false, "dalam": false, "bangun": Vector3(2, 0, 2), "lantai_y": 0.0, "npc_id": "serambi_surau_b"},
	# --- Bawah pohon Taman Putri: bersila, hadap selatan ---
	{"id": "pohon_taman_putri_a", "pos": Vector3(123.2, 0, 29.8), "yaw": 0.0, "gedung": "taman_putri", "jenis": "bersila", "putri": true, "dalam": false, "bangun": Vector3(123.2, 0, 29.8), "lantai_y": 0.0, "npc_id": "pohon_taman_putri_a"},
	{"id": "pohon_taman_putri_b", "pos": Vector3(124.8, 0, 29.8), "yaw": 0.0, "gedung": "taman_putri", "jenis": "bersila", "putri": true, "dalam": false, "bangun": Vector3(124.8, 0, 29.8), "lantai_y": 0.0, "npc_id": "pohon_taman_putri_b"},
	# --- Teras Musholla: bersila di pelat serambi (lantai 0,05) ---
	{"id": "teras_musholla_a", "pos": Vector3(132, 0.05, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "bangun": Vector3(132, 0.05, -18), "lantai_y": 0.05, "npc_id": "teras_musholla_a"},
	{"id": "teras_musholla_b", "pos": Vector3(134, 0.05, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "bangun": Vector3(134, 0.05, -18), "lantai_y": 0.05, "npc_id": "teras_musholla_b"},
	{"id": "teras_musholla_c", "pos": Vector3(136, 0.05, -18), "yaw": PI, "gedung": "teras_musholla", "jenis": "bersila", "putri": true, "dalam": false, "bangun": Vector3(136, 0.05, -18), "lantai_y": 0.05, "npc_id": "teras_musholla_c"},
	# --- Kelas Putri: baris UTARA (meja z=-301,8 -> kursi -301,25) ---
	# Khusus pemain (NPC hanya pakai baris selatan). Bangun di lorong.
	{"id": "kelas_putri_kursi_1u", "pos": Vector3(117.0, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_2u", "pos": Vector3(117.6, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_3u", "pos": Vector3(119.7, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_4u", "pos": Vector3(120.3, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_5u", "pos": Vector3(122.4, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_6u", "pos": Vector3(123.0, 0.45, -301.25), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -301.25), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	# --- Kelas Putri: baris TENGAH (meja z=-300,4 -> kursi -299,85) ---
	{"id": "kelas_putri_kursi_1t", "pos": Vector3(117.0, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_2t", "pos": Vector3(117.6, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_3t", "pos": Vector3(119.7, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_4t", "pos": Vector3(120.3, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_5t", "pos": Vector3(122.4, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_6t", "pos": Vector3(123.0, 0.45, -299.85), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -299.85), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	# --- Kelas Putri: baris SELATAN (meja z=-299,0 -> kursi -298,45) ---
	# Berbagi NPC (KURSI_DALAM kelas_putri_kursi_1..6).
	{"id": "kelas_putri_kursi_1", "pos": Vector3(117.0, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_1", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_2", "pos": Vector3(117.6, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_2", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_3", "pos": Vector3(119.7, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_3", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_4", "pos": Vector3(120.3, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(118.65, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_4", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_5", "pos": Vector3(122.4, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_5", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	{"id": "kelas_putri_kursi_6", "pos": Vector3(123.0, 0.45, -298.45), "yaw": PI, "gedung": "kelas_putri", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(121.35, 0, -298.45), "lantai_y": 0.0, "npc_id": "kelas_putri_kursi_6", "pintu_luar": Vector3(130, 0, 14), "pintu_dalam": Vector3(120, 0, -297), "spawn_dalam": Vector3(118.6, 0, -298.5)},
	# --- Madrasah Putri: 2 kursi murid (hadap utara, ke papan) ---
	# Berbagi NPC (KURSI_DALAM madrasah_kursi_1/2). Bangun ke selatan
	# (belakang kursi, menjauhi meja — ke depan mendarat di meja).
	{"id": "madrasah_kursi_1", "pos": Vector3(-182.0, 0.45, -297.4), "yaw": PI, "gedung": "madrasah", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(-182.0, 0, -296.6), "lantai_y": 0.0, "npc_id": "madrasah_kursi_1", "pintu_luar": Vector3(147, 0, -12), "pintu_dalam": Vector3(-185, 0, -300), "spawn_dalam": Vector3(-183.5, 0, -300)},
	{"id": "madrasah_kursi_2", "pos": Vector3(-178.8, 0.45, -297.4), "yaw": PI, "gedung": "madrasah", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(-178.8, 0, -296.6), "lantai_y": 0.0, "npc_id": "madrasah_kursi_2", "pintu_luar": Vector3(147, 0, -12), "pintu_dalam": Vector3(-185, 0, -300), "spawn_dalam": Vector3(-183.5, 0, -300)},
	# --- Studio: 2 kursi kerja (khusus pemain) ---
	# Kursi 1 hadap timur (meja di 244,45); bangun ke barat (belakang).
	{"id": "studio_kursi_1", "pos": Vector3(243.1, 0.45, -301.0), "yaw": PI / 2.0, "gedung": "studio", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(242.3, 0, -301.0), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(166, 0, -16), "pintu_dalam": Vector3(240, 0, -304), "spawn_dalam": Vector3(240, 0, -302.5)},
	# Kursi 2 hadap barat (meja di 235,55); bangun ke timur (belakang).
	{"id": "studio_kursi_2", "pos": Vector3(236.9, 0.45, -299.0), "yaw": -PI / 2.0, "gedung": "studio", "jenis": "kursi", "putri": true, "dalam": true, "bangun": Vector3(237.7, 0, -299.0), "lantai_y": 0.0, "npc_id": "", "pintu_luar": Vector3(166, 0, -16), "pintu_dalam": Vector3(240, 0, -304), "spawn_dalam": Vector3(240, 0, -302.5)},
	# --- Cangkruk Putra: 5 kasur (kepala utara, hadap selatan) ---
	# Berbagi NPC (KURSI_DALAM cangkruk_kasur_1..5). Bangun 1,5 m ke
	# selatan kaki kasur (celah antar-kasur / koridor tengah).
	{"id": "cangkruk_kasur_1", "pos": Vector3(-66, 0.51, -303.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "bangun": Vector3(-66, 0, -301.8), "lantai_y": 0.0, "npc_id": "cangkruk_kasur_1", "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_2", "pos": Vector3(-66, 0.51, -300.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "bangun": Vector3(-66, 0, -298.5), "lantai_y": 0.0, "npc_id": "cangkruk_kasur_2", "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_3", "pos": Vector3(-54, 0.51, -303.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "bangun": Vector3(-54, 0, -301.8), "lantai_y": 0.0, "npc_id": "cangkruk_kasur_3", "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_4", "pos": Vector3(-54, 0.51, -300.3), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "bangun": Vector3(-54, 0, -298.5), "lantai_y": 0.0, "npc_id": "cangkruk_kasur_4", "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
	{"id": "cangkruk_kasur_5", "pos": Vector3(-60, 0.51, -303.7), "yaw": 0.0, "gedung": "cangkruk", "jenis": "kasur", "putri": false, "dalam": true, "bangun": Vector3(-60, 0, -301.9), "lantai_y": 0.0, "npc_id": "cangkruk_kasur_5", "pintu_luar": Vector3(-22, 0, -14), "pintu_dalam": Vector3(-60, 0, -295), "spawn_dalam": Vector3(-60, 0, -296.5)},
]


## Entri registry dari id ({} bila tidak ada).
static func dari_id(id: String) -> Dictionary:
	for k in KURSI_PEMAIN:
		if String(k["id"]) == id:
			return k
	return {}


## Kursi terdekat dari `pos` (jarak XZ) di area gender yang sama.
## `dalam` = cari kursi interior (pemain sudah di dalam ruangan)
## atau luar (pemain di halaman). `jenis` kosong = semua jenis.
static func terdekat(pos: Vector3, putri: bool, dalam: bool, jenis: String = "") -> Dictionary:
	var terbaik := {}
	var jarak_terbaik := 1e9
	for k in KURSI_PEMAIN:
		if bool(k["putri"]) != putri:
			continue
		if bool(k["dalam"]) != dalam:
			continue
		if jenis != "" and String(k["jenis"]) != jenis:
			continue
		var p: Vector3 = k["pos"]
		var d := Vector2(pos.x - p.x, pos.z - p.z).length()
		if d < jarak_terbaik:
			jarak_terbaik = d
			terbaik = k
	return terbaik
