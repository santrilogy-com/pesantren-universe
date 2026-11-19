extends Node
## Tes HALAMAN/TAMAN BEKAS CANGKRUK PUTRI (Dewi, 18 Nov 2026 —
## keputusan Xam dari Mas "Terserah kamu — yg putri": bekas tapak
## Cangkruk (128,-12) jadi halaman/taman dulu, BUKAN gazebo).
##   godot --headless --path . skrip/test_halaman_putri.tscn
## Cek: konstanta + node + dict; alas rumput 10x8 di posisi benar;
## pembatas batu 4 sisi (celah timur = jalur paving); paving timur
## menyatu dengan JalanInternal (x=140,5); 6 bedeng bunga / 48 bunga /
## 10 warna + semak + papan nama; TIDAK ada elemen halaman di luar
## tapak/paving (tidak menabrak gedung/jalan); pemain bisa jalan di
## atasnya.
## Keluar: exit 0 bila semua lulus.
## RONDE 2 (Dewi, 18 Nov 2026 — perintah Mas 13:47 WIB "Tidak
## usah kotak putih gitu.. langsung bunga.. terus kasih paving.."):
## box bedeng DIHAPUS, 48 bunga langsung di tanah (y 0,17) +
## paving dalam taman (jalur tengah + bingkai U/S/B).
## RONDE 3 (Dewi, 18 Nov 2026 — perintah Mas 13:56 WIB "Samakan
## dng taman pondok putra"): pembatas batu -> PAGAR BAMBU (bilah
## + 2 rel, celah timur tetap terbuka); bunga BERTANGKAI di atas
## alas TANAH gelap (bukan kotak putih); + 2 bangku kayu, 1 pohon,
## 1 lampu tiang; jalur cobblestone + rumput leafy grass (tekstur
## taman putra); papan nama DINAIKKAN (label y 1,75, di atas
## pagar) supaya tetap terbaca dari jalan.
## RONDE 4 (Dewi, 18 Nov 2026 — perintah Mas 14:17 WIB "Taman
## taruh di pojok aja.. jangan di depan musholla"): SELURUH isi r3
## PINDAH ke pojok barat-daya (122,32), offset dx=-6, dz=+44, layout
## sama persis (celah timur tetap); paving ke jalan DIPANJANGKAN
## (x 127..140,5) + strip penghubung ke utara (x 140,5..143,5,
## z 22..32) sampai ujung selatan JalanInternal; tapak lama
## (128,-12) harus KOSONG total; jarak ke Musholla > 40 m.

var _main: Node
var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _ready() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_main = packed.instantiate()
	add_child(_main)
	for i in 3:
		await get_tree().process_frame
	_main._save["jenis_kelamin"] = "putri"
	_main._masuk_pesantren("Tes halaman putri")
	for i in 3:
		await get_tree().process_frame
	_main._audio.mulai()

	var root: Node = _main._pesantren["root"]
	var kampus: Node = root.find_child("KampusPutri", true, false)
	var halaman: Node = root.find_child("HalamanCangkruk", true, false)

	# --- 1. Konstanta + node + dict ---
	_cek("Konstanta HALAMAN_CANGKRUK_POS (122,32)",
		KampusPutri.HALAMAN_CANGKRUK_POS.distance_to(Vector3(122, 0, 32)) < 0.01)
	_cek("KampusPutri ada", kampus != null)
	_cek("Node HalamanCangkruk ada", halaman != null)
	_cek("Node CangkrukPutri TETAP tidak ada",
		root.find_child("CangkrukPutri", true, false) == null)
	_cek("AlasRumput di posisi (122,0.03,32)",
		(root.find_child("AlasRumput", true, false) as Node3D).global_position.distance_to(Vector3(122, 0.03, 32)) < 0.01)
	_cek("Dict TANPA kunci cangkruk_putri_pos",
		not _main._pesantren.has("cangkruk_putri_pos"))
	# CATATAN: kunci "halaman_cangkruk_pos" ada di dict kembalian
	# KampusPutri.build() (kontrak builder), tapi TIDAK diteruskan
	# pesantren_builder.gd ke _pesantren — pola file itu hanya
	# meneruskan kunci yang dipakai main.gd/peta; posisi halaman
	# dibaca dari konstanta KampusPutri.HALAMAN_CANGKRUK_POS.

	# --- 2. Alas rumput 10x8 di posisi benar ---
	_cek("AlasRumput ada", root.find_child("AlasRumput", true, false) != null)
	_cek("Rumput di tengah tapak (122,0.03,32)",
		_ada_mesh_di(halaman, Vector3(122, 0.03, 32)))
	_cek("Rumput menutup sudut tapak (117.5,0.03,28.5)",
		_ada_mesh_di(halaman, Vector3(117.5, 0.03, 28.5)))
	_cek("Rumput menutup sudut tapak (126.5,0.03,35.5)",
		_ada_mesh_di(halaman, Vector3(126.5, 0.03, 35.5)))
	_cek("Rumput TIDAK menjorok ke luar tapak (128,0.03,30)",
		not _ada_mesh_di(halaman, Vector3(128, 0.03, 30)))

	# --- 3. Pagar bambu 4 sisi (RONDE 3 — ganti pembatas batu) ---
	var pagar := root.find_child("PagarBambu", true, false)
	_cek("PagarBambu ada", pagar != null)
	_cek("Tidak ada lagi pembatas batu (BatasUtara hilang)",
		root.find_child("BatasUtara", true, false) == null)
	_cek("Tidak ada lagi pembatas batu (BatasTimurUtara hilang)",
		root.find_child("BatasTimurUtara", true, false) == null)
	_cek("Jumlah bilah bambu 115 (34+34+27+10+10)",
		_hitung_awalan(pagar, "Bilah_") == 115)
	_cek("Jumlah rel bambu 10 (2 per segmen x 5)",
		_hitung_awalan(pagar, "Rel_") == 10)
	_cek("Jumlah tiang pagar 6 (4 sudut + 2 tepi celah)",
		_hitung_awalan(pagar, "TiangPagar_") == 6)
	_cek("Rel pagar utara di z=28 (122,0.45,28)",
		_ada_mesh_di(halaman, Vector3(122, 0.45, 28)))
	_cek("Rel pagar selatan di z=36 (122,0.45,36)",
		_ada_mesh_di(halaman, Vector3(122, 0.45, 36)))
	_cek("Rel pagar barat di x=117 (117,0.45,32)",
		_ada_mesh_di(halaman, Vector3(117, 0.45, 32)))
	_cek("Rel pagar timur-utara (127,0.45,29.5)",
		_ada_mesh_di(halaman, Vector3(127, 0.45, 29.5)))
	_cek("Rel pagar timur-selatan (127,0.45,34.5)",
		_ada_mesh_di(halaman, Vector3(127, 0.45, 34.5)))
	_cek("Tinggi pagar ~1,5 m (bilah atas y<=1,55)",
		_tinggi_maks_node(pagar) <= 1.65)
	_cek("Celah timur terbuka di jalur paving (127,0.45,32)",
		not _ada_mesh_di(pagar, Vector3(127, 0.45, 32)))
	_cek("Celah timur terbuka setinggi pagar (127,1.45,32)",
		not _ada_mesh_di(pagar, Vector3(127, 1.45, 32)))
	_cek("Tiang tepi celah utara (127,0.8,30.75)",
		_ada_mesh_di(halaman, Vector3(127, 0.8, 30.75)))
	_cek("Tiang tepi celah selatan (127,0.8,33.25)",
		_ada_mesh_di(halaman, Vector3(127, 0.8, 33.25)))

	# --- 4. Paving timur menyatu dengan jalan internal ---
	_cek("PavingKeJalan ada", root.find_child("PavingKeJalan", true, false) != null)
	_cek("Paving di tengah jalur (133.75,0.03,32)",
		_ada_mesh_di(halaman, Vector3(133.75, 0.03, 32)))
	var paving := root.find_child("PavingKeJalan", true, false) as MeshInstance3D
	var paving_aabb := paving.global_transform * paving.get_aabb()
	_cek("Paving berakhir tepat di tepi jalan (x maks 140,5)",
		absf(paving_aabb.end.x - 140.5) < 0.01)
	_cek("Paving TIDAK menabrak jalan (x maks <= 140,5)",
		paving_aabb.end.x <= 140.51)
	_cek("Paving TIDAK menabrak KonekMadrasah (x maks < 143,5)",
		paving_aabb.end.x < 143.5)
	# RONDE 4: strip penghubung ke utara (x 140,5..143,5, z 22..32)
	# sampai ujung selatan JalanInternal (z=+22).
	var strip := root.find_child("PavingStripJalan", true, false) as MeshInstance3D
	_cek("PavingStripJalan ada", strip != null)
	_cek("Strip di tengah koridor jalan (142,0.03,27)",
		strip != null and strip.global_position.distance_to(Vector3(142, 0.03, 27)) < 0.01)
	var strip_aabb := strip.global_transform * strip.get_aabb()
	_cek("Strip mencapai ujung selatan JalanInternal (z min 22)",
		absf(strip_aabb.position.z - 22.0) < 0.01)
	_cek("Strip selebar jalan (x 140,5..143,5)",
		absf(strip_aabb.position.x - 140.5) < 0.01 and absf(strip_aabb.end.x - 143.5) < 0.01)
	_cek("PavingKeJalan tersambung ke strip (x 140,5)",
		absf(paving_aabb.end.x - strip_aabb.position.x) < 0.01)
	_cek("Strip bertekstur cobblestone",
		_bertekstur(strip))

	# --- 5. Bunga bertangkai di atas alas tanah + paving dalam taman + semak + papan nama ---
	# RONDE 3 18 Nov ~13:56 WIB (perintah Mas "Samakan dng taman
	# pondok putra"): 48 bunga tetap di 6 rumpun yang sama, tapi
	# kini BERTANGKAI hijau (bola y 0,36) di atas alas TANAH gelap
	# rendah (tekstur farm soil — BUKAN kotak putih); jalur tengah
	# + bingkai paving tetap; + 2 bangku, 1 pohon, 1 lampu tiang.
	# Alas tanah ada di bawah tiap rumpun (y 0,09, di dalam bedeng).
	_cek("Alas tanah barat-laut (119.5,0.09,29.4)",
		_ada_mesh_di(halaman, Vector3(119.5, 0.09, 29.4)))
	_cek("Alas tanah timur-selatan (124.5,0.09,34.6)",
		_ada_mesh_di(halaman, Vector3(124.5, 0.09, 34.6)))
	_cek("Alas tanah barat-daya (119.5,0.09,34.6)",
		_ada_mesh_di(halaman, Vector3(119.5, 0.09, 34.6)))
	_cek("Alas tanah timur-laut (124.5,0.09,29.4)",
		_ada_mesh_di(halaman, Vector3(124.5, 0.09, 29.4)))
	_cek("Alas tanah utara-tengah (122,0.09,28.85)",
		_ada_mesh_di(halaman, Vector3(122, 0.09, 28.85)))
	_cek("Alas tanah selatan-tengah (122,0.09,35.15)",
		_ada_mesh_di(halaman, Vector3(122, 0.09, 35.15)))
	_cek("Jumlah bedeng tanah 6", _hitung_awalan(halaman, "BedengTanah_") == 6)
	_cek("Bedeng tanah bertekstur (bukan kotak putih polos)",
		_semua_bertekstur(halaman, "BedengTanah_"))
	_cek("Tidak ada lagi box PASIR_GELAP di halaman",
		not _ada_box_warna(halaman, Color("#cbb27f")))
	_cek("Tidak ada box PUTIH (f5f0e6) di halaman",
		not _ada_box_warna(halaman, Palette.PUTIH))
	_cek("Bunga bertangkai (119.25,0.36,29.68)",
		_ada_mesh_di(halaman, Vector3(119.25, 0.36, 29.68)))
	_cek("Bunga bertangkai (122.75,0.36,35.43)",
		_ada_mesh_di(halaman, Vector3(122.75, 0.36, 35.43)))
	var bunga := _bunga_halaman(halaman)
	_cek("Jumlah bunga tetap 48 (6 rumpun x 8)", bunga.size() == 48)
	_cek("Semua bunga bertangkai (pusat y 0,30..0,42)",
		_y_bunga_min(bunga) >= 0.30 and _y_bunga_maks(bunga) <= 0.42)
	_cek("Jumlah tangkai hijau 48", _hitung_tangkai(halaman) == 48)
	var warna := _warna_bunga(bunga)
	_cek("Warna bunga >= 8 macam", warna.size() >= 8)
	for w in ["d9382b", "ffd21a", "9b59b6", "2e86de", "ff8c1a"]:
		_cek("Ada bunga warna #" + w, w in warna)
	# Paving dalam taman (ronde 2): jalur tengah + bingkai.
	# Cek posisi node LANGSUNG (bukan _ada_mesh_di — alas rumput
	# juga memuat titik-titik ini, jadi cek mesh saja tidak cukup).
	var pt := root.find_child("PavingTengah", true, false) as Node3D
	_cek("PavingTengah ada", pt != null)
	_cek("PavingTengah di tengah tapak (122,0.045,32)",
		pt != null and pt.global_position.distance_to(Vector3(122, 0.045, 32)) < 0.01)
	var pbu := root.find_child("PavingBingkaiUtara", true, false) as Node3D
	_cek("PavingBingkaiUtara ada + di tepi utara (122,0.045,28.25)",
		pbu != null and pbu.global_position.distance_to(Vector3(122, 0.045, 28.25)) < 0.01)
	var pbs := root.find_child("PavingBingkaiSelatan", true, false) as Node3D
	_cek("PavingBingkaiSelatan ada + di tepi selatan (122,0.045,35.75)",
		pbs != null and pbs.global_position.distance_to(Vector3(122, 0.045, 35.75)) < 0.01)
	var pbb := root.find_child("PavingBingkaiBarat", true, false) as Node3D
	_cek("PavingBingkaiBarat ada + di tepi barat (117.25,0.045,32)",
		pbb != null and pbb.global_position.distance_to(Vector3(117.25, 0.045, 32)) < 0.01)
	_cek("PavingTengah meneruskan PavingKeJalan (ujung timur x=127)",
		pt != null and absf((pt as MeshInstance3D).global_transform.origin.x
			+ 5.0 - 127.0) < 0.01
		and absf((root.find_child("PavingKeJalan", true, false) as MeshInstance3D).global_transform.origin.x
			- 6.75 - 127.0) < 0.01)
	_cek("Paving dalam taman TIDAK menutupi bunga (XZ bunga di luar paving)",
		_bunga_tidak_di_atas_paving(bunga, halaman, ["PavingTengah", "PavingBingkaiUtara",
			"PavingBingkaiSelatan", "PavingBingkaiBarat"]))
	_cek("Bunga tidak menutupi papan nama (jarak min >= 0,8 m)",
		_jarak_bunga_min_ke(bunga, Vector2(126.2, 33.8)) >= 0.8)
	_cek("Bunga tidak menutup jalur tengah (koridor z 30,75..33,25 bebas)",
		_tidak_ada_bunga_di_koridor(bunga, 30.75, 33.25))
	# Bangku kayu (RONDE 3): utara + selatan menghadap jalur tengah.
	var bu := root.find_child("BangkuUtara", true, false) as Node3D
	_cek("BangkuUtara ada", bu != null)
	_cek("Duduk BangkuUtara (122,0.45,30.4)",
		_ada_mesh_di(halaman, Vector3(122, 0.45, 30.4)))
	_cek("Sandaran BangkuUtara di sisi utara (122,0.78,30.15)",
		_ada_mesh_di(halaman, Vector3(122, 0.78, 30.15)))
	var bs := root.find_child("BangkuSelatan", true, false) as Node3D
	_cek("BangkuSelatan ada", bs != null)
	_cek("Duduk BangkuSelatan (122,0.45,33.6)",
		_ada_mesh_di(halaman, Vector3(122, 0.45, 33.6)))
	_cek("Sandaran BangkuSelatan di sisi selatan (122,0.78,33.85)",
		_ada_mesh_di(halaman, Vector3(122, 0.78, 33.85)))
	_cek("BangkuUtara tidak menutupi bunga (jarak min >= 1,0 m)",
		_jarak_bunga_min_ke(bunga, Vector2(122, 30.4)) >= 1.0)
	_cek("BangkuSelatan tidak menutupi bunga (jarak min >= 1,0 m)",
		_jarak_bunga_min_ke(bunga, Vector2(122, 33.6)) >= 1.0)
	_cek("Bangku tidak menutupi jalur tengah (duduk di luar z 30,75..33,25)",
		(bu.global_position.z < 30.75 or bu.global_position.z > 33.25)
		and (bs.global_position.z < 30.75 or bs.global_position.z > 33.25))
	# Pohon (RONDE 3): sudut barat, di luar jalur tengah.
	var pohon := root.find_child("PohonTaman", true, false) as Node3D
	_cek("PohonTaman ada", pohon != null)
	_cek("Batang pohon (124,0.95,29.8)",
		_ada_mesh_di(halaman, Vector3(124.0, 0.95, 29.8)))
	_cek("Tajuk pohon (124,2.45,29.8)",
		_ada_mesh_di(halaman, Vector3(124.0, 2.45, 29.8)))
	_cek("Pohon tidak di jalur tengah (z 29,8 di luar 30,75..33,25)",
		pohon != null and (pohon.global_position.z < 30.75 or pohon.global_position.z > 33.25))
	# Lampu tiang (RONDE 3): dekat papan nama / tepi jalur.
	var lampu := root.find_child("LampuTaman", true, false) as Node3D
	_cek("LampuTaman ada", lampu != null)
	_cek("Tiang lampu (126.5,1.5,30.5)",
		_ada_mesh_di(halaman, Vector3(126.5, 1.5, 30.5)))
	_cek("Bohlam lampu (126.5,3.1,30.5)",
		_ada_mesh_di(halaman, Vector3(126.5, 3.1, 30.5)))
	var bohlam := root.find_child("BohlamLampu", true, false) as MeshInstance3D
	_cek("Bohlam lampu masuk grup LampuJalan (menyala malam)",
		bohlam != null and bohlam.is_in_group("LampuJalan"))
	# Tekstur taman putra: rumput leafy grass + jalur cobblestone.
	_cek("AlasRumput bertekstur leafy grass",
		_bertekstur(root.find_child("AlasRumput", true, false)))
	_cek("PavingTengah bertekstur cobblestone",
		_bertekstur(root.find_child("PavingTengah", true, false)))
	_cek("PavingKeJalan bertekstur cobblestone",
		_bertekstur(root.find_child("PavingKeJalan", true, false)))
	_cek("Semak barat-laut (117.8,0.4,28.8)",
		_ada_mesh_di(halaman, Vector3(117.8, 0.4, 28.8)))
	_cek("Semak timur-selatan (126.2,0.4,35.2)",
		_ada_mesh_di(halaman, Vector3(126.2, 0.4, 35.2)))
	_cek("PapanTaman ada", root.find_child("PapanTaman", true, false) != null)
	var label := root.find_child("LabelTaman", true, false) as Label3D
	_cek("Label TAMAN PUTRI ada + teks benar",
		label != null and label.text == "TAMAN PUTRI")
	_cek("Label di atas pagar (y 1,75 > 1,5) — terbaca dari jalan",
		label != null and label.global_position.y > 1.5)
	_cek("Label di posisi XZ baru (126.26,1.75,33.8)",
		label != null and label.global_position.distance_to(Vector3(126.26, 1.75, 33.8)) < 0.01)
	_cek("Papan tidak tertutup pagar (tidak ada mesh pagar di label)",
		not _ada_mesh_di(pagar, Vector3(126.26, 1.75, 33.8)))
	# BUKAN gazebo/bangunan: tidak ada atap/dinding di halaman —
	# yang tertinggi hanya tajuk pohon (~3,7 m) + bohlam (~3,3 m).
	_cek("Tidak ada mesh halaman di atas y=4,0 (terbuka, tanpa atap)",
		_tinggi_maks_mesh(halaman) <= 4.0)
	_cek("Tinggi maks halaman ~3,7 m (tajuk pohon)",
		_tinggi_maks_mesh(halaman) >= 3.6 and _tinggi_maks_mesh(halaman) <= 3.8)

	# --- 6. Tidak menabrak gedung/jalan (cek dari subtree halaman) ---
	_cek("Halaman tidak masuk Musholla (134,0.03,-24)",
		not _ada_mesh_di(halaman, Vector3(134, 0.03, -24)))
	_cek("Halaman tidak masuk pagar Musholla (126,0.06,-17)",
		not _ada_mesh_di(halaman, Vector3(126, 0.06, -17)))
	_cek("Halaman tidak masuk KelasPutri (130,0.03,10)",
		not _ada_mesh_di(halaman, Vector3(130, 0.03, 10)))
	_cek("Halaman tidak masuk Madrasah (147,0.03,-12)",
		not _ada_mesh_di(halaman, Vector3(147, 0.03, -12)))
	_cek("Halaman tidak masuk JalanInternal (142,0.03,-12)",
		not _ada_mesh_di(halaman, Vector3(142, 0.03, -12)))
	_cek("Halaman tidak masuk KonekMusholla (137.25,0.03,-19)",
		not _ada_mesh_di(halaman, Vector3(137.25, 0.03, -19)))
	_cek("Semua mesh halaman di dalam kotak x 116..144, z 22..37",
		_semua_mesh_dalam_kotak(halaman, 116.0, 144.0, 22.0, 37.0))
	# Halaman TANPA collision (visual saja): tidak ada StaticBody3D
	# di subtree halaman — pemain jalan bebas, tidak ada yang menahan.
	_cek("Halaman tanpa StaticBody3D (bisa dilalui)",
		not _ada_staticbody(halaman))

	# --- RONDE 4a. Tapak lama (128,-12) KOSONG total ---
	_cek("Tapak lama kosong — tidak ada mesh taman di (128,0.03,-12)",
		not _ada_mesh_di(halaman, Vector3(128, 0.03, -12)))
	_cek("Tapak lama kosong — sudut (123.5,0.03,-15.5)",
		not _ada_mesh_di(halaman, Vector3(123.5, 0.03, -15.5)))
	_cek("Tapak lama kosong — sudut (132.5,0.03,-8.5)",
		not _ada_mesh_di(halaman, Vector3(132.5, 0.03, -8.5)))
	_cek("Tapak lama kosong — pagar lama hilang (128,0.45,-16)",
		not _ada_mesh_di(halaman, Vector3(128, 0.45, -16)))
	_cek("Tapak lama kosong — paving lama hilang (136.75,0.03,-12)",
		not _ada_mesh_di(halaman, Vector3(136.75, 0.03, -12)))

	# --- RONDE 4c. Tapak di dalam pojok barat-daya (x 117..127, z 28..36) ---
	var rumput := root.find_child("AlasRumput", true, false) as MeshInstance3D
	var rumput_aabb := rumput.global_transform * rumput.get_aabb()
	_cek("Alas rumput di dalam pojok (x 117..127, z 28..36)",
		rumput_aabb.position.x >= 117.0 - 0.01 and rumput_aabb.end.x <= 127.0 + 0.01
		and rumput_aabb.position.z >= 28.0 - 0.01 and rumput_aabb.end.z <= 36.0 + 0.01)
	_cek("Tapak 2 m dari tembok barat (x min 117 > 115)",
		rumput_aabb.position.x > 115.0)
	_cek("Tapak 4 m dari tembok selatan (z maks 36 < 40)",
		rumput_aabb.end.z < 40.0)

	# --- RONDE 4d. Jauh dari Musholla (> 40 m) ---
	_cek("Jarak taman ke Musholla > 40 m",
		KampusPutri.HALAMAN_CANGKRUK_POS.distance_to(KampusPutri.MUSHOLLA_POS) > 40.0)

	# --- 7. Pemain bisa jalan di atas halaman ---
	_main._teleport_player(Vector3(122, 0, 32), 0.0)
	for i in 3:
		await get_tree().process_frame
	_cek("Teleport ke tengah halaman (122,32)",
		_main._player.global_position.distance_to(Vector3(122, 0, 32)) < 1.0)
	_main._player.set_aksi("berdiri")
	var a: Vector3 = _main._player.global_position
	_main._ui._joystick.output = Vector2(0, -1)
	for i in 30:
		await get_tree().process_frame
	_main._ui._joystick.output = Vector2.ZERO
	for i in 3:
		await get_tree().process_frame
	var b: Vector3 = _main._player.global_position
	print("DEBUG jalan di halaman: dari ", a, " ke ", b)
	_cek("Pemain bisa jalan di halaman (>0,5 m / 30 frame)",
		a.distance_to(b) > 0.5)
	_cek("Pemain tetap di permukaan (y -0,5..0,5)",
		b.y > -0.5 and b.y < 0.5)
	_cek("Pemain tetap di area putri setelah jalan",
		b.x > 115.0 and b.x < 216.0 and b.z > -70.0 and b.z < 40.0)

	print("HASIL HALAMAN PUTRI: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)


## True bila ada MeshInstance3D di subtree `di` yang AABB dunianya memuat titik.
func _ada_mesh_di(di: Node, titik: Vector3) -> bool:
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			if (mi.global_transform * mi.get_aabb()).has_point(titik):
				return true
		if _ada_mesh_di(ch, titik):
			return true
	return false


## Tinggi maksimum (y atas AABB) semua mesh di subtree.
func _tinggi_maks_mesh(di: Node) -> float:
	var maks := 0.0
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			maks = maxf(maks, (mi.global_transform * mi.get_aabb()).end.y)
		maks = maxf(maks, _tinggi_maks_mesh(ch))
	return maks


## True bila SEMUA mesh di subtree berada dalam kotak (x_min..x_max, z_min..z_max).
func _semua_mesh_dalam_kotak(di: Node, x_min: float, x_max: float, z_min: float, z_max: float) -> bool:
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			var ab := mi.global_transform * mi.get_aabb()
			if ab.position.x < x_min - 0.01 or ab.end.x > x_max + 0.01:
				print("DEBUG mesh di luar kotak x: ", mi.name, " ", ab)
				return false
			if ab.position.z < z_min - 0.01 or ab.end.z > z_max + 0.01:
				print("DEBUG mesh di luar kotak z: ", mi.name, " ", ab)
				return false
		if not _semua_mesh_dalam_kotak(ch, x_min, x_max, z_min, z_max):
			return false
	return true


func _ada_staticbody(di: Node) -> bool:
	for ch in di.get_children():
		if ch is StaticBody3D:
			return true
		if _ada_staticbody(ch):
			return true
	return false


## Bunga halaman = SphereMesh r=0,12 di subtree halaman (semak r=0,4
## tidak ikut — dibedakan dari radius).
func _bunga_halaman(di: Node) -> Array:
	var hasil: Array = []
	_kumpul_bunga(di, hasil)
	return hasil


func _kumpul_bunga(di: Node, hasil: Array) -> void:
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			if mi.mesh is SphereMesh and (mi.mesh as SphereMesh).radius < 0.2:
				hasil.append(mi)
		_kumpul_bunga(ch, hasil)


## Kumpulan warna albedo (hex tanpa '#') semua bunga.
func _warna_bunga(bunga: Array) -> Dictionary:
	var warna := {}
	for b in bunga:
		var mi := b as MeshInstance3D
		var m := mi.material_override as StandardMaterial3D
		if m != null:
			warna[m.albedo_color.to_html(false)] = true
	return warna


## Jarak XZ terdekat dari pusat bunga ke titik (x, z).
func _jarak_bunga_min_ke(bunga: Array, titik: Vector2) -> float:
	var jarak_min := 999.0
	for b in bunga:
		var mi := b as MeshInstance3D
		var p := mi.global_position
		jarak_min = minf(jarak_min, Vector2(p.x, p.z).distance_to(titik))
	return jarak_min


## True bila tidak ada pusat bunga di pita z_min..z_max (jalur tengah).
func _tidak_ada_bunga_di_koridor(bunga: Array, z_min: float, z_max: float) -> bool:
	for b in bunga:
		var mi := b as MeshInstance3D
		var z := mi.global_position.z
		if z >= z_min and z <= z_max:
			print("DEBUG bunga di koridor: ", mi.global_position)
			return false
	return true


## True bila ada BoxMesh dengan albedo `warna` di subtree `di`
## (dipakai ronde 2: memastikan box bedeng PASIR_GELAP sudah hilang).
func _ada_box_warna(di: Node, warna: Color) -> bool:
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			if mi.mesh is BoxMesh:
				var m := mi.material_override as StandardMaterial3D
				if m != null and m.albedo_color.to_html(false) == warna.to_html(false):
					return true
		if _ada_box_warna(ch, warna):
			return true
	return false


## Pusat y tertinggi semua bunga (ronde 2: bunga di tanah, y ~0,17;
## ronde 3: bunga bertangkai, y ~0,36).
func _y_bunga_maks(bunga: Array) -> float:
	var maks := 0.0
	for b in bunga:
		maks = maxf(maks, (b as MeshInstance3D).global_position.y)
	return maks


## Pusat y terendah semua bunga (ronde 3: bunga bertangkai, y ~0,36).
func _y_bunga_min(bunga: Array) -> float:
	var terkecil := 999.0
	for b in bunga:
		terkecil = minf(terkecil, (b as MeshInstance3D).global_position.y)
	return terkecil


## Jumlah anak LANGSUNG `di` yang namanya diawali `awalan`
## (ronde 3: hitung bilah/rel/tiang pagar + bedeng tanah).
func _hitung_awalan(di: Node, awalan: String) -> int:
	if di == null:
		return -1
	var n := 0
	for ch in di.get_children():
		if ch.name.begins_with(awalan):
			n += 1
	return n


## Tinggi maksimum (y atas AABB) semua mesh di subtree `di`
## (ronde 3: tinggi pagar bambu).
func _tinggi_maks_node(di: Node) -> float:
	if di == null:
		return -1.0
	return _tinggi_maks_mesh(di)


## Jumlah tangkai bunga: silinder hijau tipis (r<0,03, warna
## #2f7d33) di subtree — tiang papan (r 0,05), tiang lampu
## (r 0,05-0,07) dan batang pohon (r 0,14) tidak ikut.
func _hitung_tangkai(di: Node) -> int:
	var n := 0
	for ch in di.get_children():
		if ch is MeshInstance3D:
			var mi := ch as MeshInstance3D
			if mi.mesh is CylinderMesh and (mi.mesh as CylinderMesh).top_radius < 0.03:
				var m := mi.material_override as StandardMaterial3D
				if m != null and m.albedo_color.to_html(false) == "2f7d33":
					n += 1
		n += _hitung_tangkai(ch)
	return n


## True bila node mesh memakai material bertekstur
## (albedo_texture terisi — ronde 3: rumput/paving/bedeng).
func _bertekstur(node: Node) -> bool:
	if node is MeshInstance3D:
		var m := (node as MeshInstance3D).material_override as StandardMaterial3D
		return m != null and m.albedo_texture != null
	return false


## True bila SEMUA anak langsung `di` berawalan `awalan` bertekstur
## (ronde 3: 6 bedeng tanah memakai tekstur farm soil).
func _semua_bertekstur(di: Node, awalan: String) -> bool:
	var ketemu := false
	for ch in di.get_children():
		if ch.name.begins_with(awalan):
			ketemu = true
			if not _bertekstur(ch):
				print("DEBUG tidak bertekstur: ", ch.name)
				return false
	return ketemu


## True bila tidak ada pusat bunga (XZ) di atas footprint paving
## `nama_paving` di subtree `di` (ronde 2: paving dalam taman
## jangan menutupi bunga).
func _bunga_tidak_di_atas_paving(bunga: Array, di: Node, nama_paving: Array) -> bool:
	for nama in nama_paving:
		var pv := di.find_child(nama, true, false) as MeshInstance3D
		if pv == null:
			print("DEBUG paving tidak ketemu: ", nama)
			return false
		var ab := pv.global_transform * pv.get_aabb()
		for b in bunga:
			var p := (b as MeshInstance3D).global_position
			if p.x >= ab.position.x - 0.05 and p.x <= ab.end.x + 0.05 \
					and p.z >= ab.position.z - 0.05 and p.z <= ab.end.z + 0.05:
				print("DEBUG bunga di atas paving ", nama, ": ", p)
				return false
	return true
