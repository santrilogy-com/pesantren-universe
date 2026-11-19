extends Node
## Tes Seragam Utama v2 (Kirana, 19 Nov 2026 — ACC Mas 15:41).
## CAKUPAN: OUTFIT_DEFAULT baru (koko putih #FFFFFF + sarung #008062
## motif garis + jilbab putih); komposisi putra/putri room_config;
## build_visual putra (garis kuning 2px/32px) + putri (tunik, tanpa
## Abaya, batik coklat PNG, jilbab putih); Ustadzah/Fatimah/Penjaga
## TETAP abaya; Kyai/Satpam TETAP parang; migrasi save lama; NPC
## _terapkan_pakaian tunik TIDAK dipetakan ke varian abaya.
## Headless (user-dir TERISOLASI — jangan pakai save VM):
##   godot --headless --path . --user-dir /tmp/test-seragam-utama/ skrip/test_seragam_utama.tscn
## Pola test_npc_fatimah.gd: _cek + hitung lulus/gagal, EXIT 0 bila
## semua lulus.

var _lulus := 0
var _gagal := 0


func _cek(nama: String, ok: bool) -> void:
	if ok:
		_lulus += 1
		print("LULUS: " + nama)
	else:
		_gagal += 1
		print("GAGAL: " + nama)


func _mat_albedo(node: Node, nama_node: String) -> StandardMaterial3D:
	var m := node.find_child(nama_node, true, false) as MeshInstance3D
	if m == null:
		return null
	return m.material_override as StandardMaterial3D


func _ready() -> void:
	# ---------- OUTFIT_DEFAULT ----------
	_cek("DEFAULT koko putih #ffffff", String(MissionData.OUTFIT_DEFAULT["koko"]) == "#ffffff")
	_cek("DEFAULT sarung zamrud #008062", String(MissionData.OUTFIT_DEFAULT["sarung"]) == "#008062")
	_cek("DEFAULT sarung_motif garis", String(MissionData.OUTFIT_DEFAULT.get("sarung_motif", "")) == "garis")
	_cek("DEFAULT hijab_warna putih #ffffff", String(MissionData.OUTFIT_DEFAULT["hijab_warna"]) == "#ffffff")

	# ---------- Komposisi room_config ----------
	var putra := RoomConfig.outfit_untuk("putra")
	_cek("PUTRA muslimah false", not bool(putra.get("muslimah", true)))
	_cek("PUTRA tunik false", not bool(putra.get("tunik", true)))
	_cek("PUTRA sarung_motif garis", String(putra.get("sarung_motif", "")) == "garis")
	var putri := RoomConfig.outfit_untuk("putri")
	_cek("PUTRI muslimah true", bool(putri.get("muslimah", false)))
	_cek("PUTRI hijab true", bool(putri.get("hijab", false)))
	_cek("PUTRI tunik true", bool(putri.get("tunik", false)))
	_cek("PUTRI koko biru langit #87ceeb", String(putri.get("koko", "")) == "#87ceeb")
	_cek("PUTRI sarung coklat #4a2c17", String(putri.get("sarung", "")) == "#4a2c17")
	_cek("PUTRI sarung_motif batik", String(putri.get("sarung_motif", "")) == "batik")
	_cek("PUTRI hijab_warna putih #ffffff", String(putri.get("hijab_warna", "")) == "#ffffff")

	# ---------- Save default ----------
	var save_outfit: Dictionary = SantriSave.default_data()["outfit"]
	_cek("SAVE koko putih #ffffff", String(save_outfit.get("koko", "")) == "#ffffff")
	_cek("SAVE sarung #008062 + motif garis", String(save_outfit.get("sarung", "")) == "#008062" and String(save_outfit.get("sarung_motif", "")) == "garis")
	_cek("SAVE hijab_warna putih #ffffff", String(save_outfit.get("hijab_warna", "")) == "#ffffff")

	# ---------- Putra: build_visual ----------
	var b_putra := SantriPlayer.build_visual("Santri", MissionData.OUTFIT_DEFAULT)
	var root_putra: Node = b_putra["root"]
	add_child(root_putra)
	_cek("PUTRA ada node Sarung", root_putra.find_child("Sarung", true, false) != null)
	_cek("PUTRA tidak ada node Abaya", root_putra.find_child("Abaya", true, false) == null)
	_cek("PUTRA tunik false", not bool(b_putra.get("tunik", true)))
	var mat_torso := _mat_albedo(root_putra, "Torso")
	_cek("PUTRA torso putih #ffffff", mat_torso != null and mat_torso.albedo_color.is_equal_approx(Color("#ffffff")))
	var mat_sarung := _mat_albedo(root_putra, "Sarung")
	_cek("PUTRA sarung punya albedo_texture", mat_sarung != null and mat_sarung.albedo_texture != null)
	var img_garis := (mat_sarung.albedo_texture as ImageTexture).get_image()
	_cek("GARIS tekstur 256x128", img_garis.get_size() == Vector2i(256, 128))
	_cek("GARIS piksel (0,0) emas #c9a227", img_garis.get_pixel(0, 0).is_equal_approx(Color("#c9a227")))
	_cek("GARIS piksel (1,0) emas (lebar 2px)", img_garis.get_pixel(1, 0).is_equal_approx(Color("#c9a227")))
	_cek("GARIS piksel (2,0) dasar hijau #008062", img_garis.get_pixel(2, 0).is_equal_approx(Color("#008062")))
	_cek("GARIS piksel (16,0) dasar hijau", img_garis.get_pixel(16, 0).is_equal_approx(Color("#008062")))
	_cek("GARIS piksel (32,0) emas lagi (periodik 32px)", img_garis.get_pixel(32, 0).is_equal_approx(Color("#c9a227")))
	_cek("GARIS piksel (16,64) dasar hijau (vertikal penuh)", img_garis.get_pixel(16, 64).is_equal_approx(Color("#008062")))
	_cek("GARIS piksel (0,64) emas (vertikal penuh)", img_garis.get_pixel(0, 64).is_equal_approx(Color("#c9a227")))

	# ---------- Putri: build_visual ----------
	var b_putri := SantriPlayer.build_visual("Santriwati", putri)
	var root_putri: Node = b_putri["root"]
	add_child(root_putri)
	_cek("PUTRI tidak ada node Abaya", root_putri.find_child("Abaya", true, false) == null)
	_cek("PUTRI ada node Sarung", root_putri.find_child("Sarung", true, false) != null)
	_cek("PUTRI tunik true", bool(b_putri.get("tunik", false)))
	_cek("PUTRI muslimah true (wajah + lengan putri tetap)", bool(b_putri.get("muslimah", false)))
	var mat_torso_p := _mat_albedo(root_putri, "Torso")
	_cek("PUTRI torso biru langit #87ceeb", mat_torso_p != null and mat_torso_p.albedo_color.is_equal_approx(Color("#87ceeb")))
	var mat_jilbab := _mat_albedo(root_putri, "HijabKerudung")
	_cek("PUTRI jilbab putih #ffffff", mat_jilbab != null and mat_jilbab.albedo_color.is_equal_approx(Color("#ffffff")))
	var mat_sarung_p := _mat_albedo(root_putri, "Sarung")
	_cek("PUTRI sarung punya albedo_texture", mat_sarung_p != null and mat_sarung_p.albedo_texture != null)
	var img_batik := mat_sarung_p.albedo_texture.get_image()
	_cek("BATIK tekstur 512x256", img_batik.get_size() == Vector2i(512, 256))
	# Palet file sumber: 5 warna saja (cek file PNG langsung — impor
	# lossless, tapi sumber adalah bukti paling tegas).
	var img_src := Image.load_from_file("res://models/batik_putri_coklat.png")
	var warna_unik := {}
	for y in range(img_src.get_height()):
		for x in range(img_src.get_width()):
			warna_unik[img_src.get_pixel(x, y).to_html()] = true
	_cek("BATIK file sumber <= 16 warna (palet)", warna_unik.size() <= 16)
	_cek("BATIK palet berisi coklat tua #4a2c17", warna_unik.has(Color("#4a2c17").to_html()))
	_cek("BATIK palet berisi coklat sedang #7a4e2d", warna_unik.has(Color("#7a4e2d").to_html()))
	_cek("BATIK palet berisi krem #f2ead6", warna_unik.has(Color("#f2ead6").to_html()))
	_cek("BATIK palet berisi emas #c9a227", warna_unik.has(Color("#c9a227").to_html()))
	var mat_hem_p := _mat_albedo(root_putri, "SarungHem")
	_cek("PUTRI hem coklat #4a2c17 (mengikuti motif batik)", mat_hem_p != null and mat_hem_p.albedo_color.is_equal_approx(Color("#4a2c17")))

	# ---------- Ustadzah / Fatimah / Penjaga TETAP abaya ----------
	var b_ustadzah := SantriPlayer.build_visual("Ustadzah Mariyah", MissionData.OUTFIT_USTADZAH)
	_cek("USTADZAH ada node Abaya", (b_ustadzah["root"] as Node).find_child("Abaya", true, false) != null)
	_cek("USTADZAH tunik false", not bool(b_ustadzah.get("tunik", true)))
	var b_fatimah := SantriPlayer.build_visual("Ustzh. Fatimah", NPCFatimah.OUTFIT_FATIMAH)
	_cek("FATIMAH ada node Abaya", (b_fatimah["root"] as Node).find_child("Abaya", true, false) != null)
	_cek("FATIMAH tunik false", not bool(b_fatimah.get("tunik", true)))
	var b_penjaga := SantriPlayer.build_visual("Penjaga Pos Jaga", MissionData.OUTFIT_PENJAGA_PUTRI)
	_cek("PENJAGA ada node Abaya", (b_penjaga["root"] as Node).find_child("Abaya", true, false) != null)
	_cek("PENJAGA tunik false", not bool(b_penjaga.get("tunik", true)))

	# ---------- Kyai / Satpam TETAP parang ----------
	var b_kyai := SantriPlayer.build_visual("Ust. Aqsal M", MissionData.OUTFIT_KYAI)
	var img_kyai := _mat_albedo(b_kyai["root"], "Sarung").albedo_texture.get_image()
	_cek("KYAI sarung 256x128 (parang prosedural)", img_kyai.get_size() == Vector2i(256, 128))
	# (0,0) tepat di tepi pita (fase 0) -> garis tepi GELAP, bukan dasar;
	# tengah pita (8,0) fase 0,36 -> warna dasar persis.
	_cek("KYAI piksel (8,0) dasar gelap #23282e (parang)", img_kyai.get_pixel(8, 0).is_equal_approx(Color("#23282e")))
	_cek("KYAI piksel (0,0) BUKAN emas garis", not img_kyai.get_pixel(0, 0).is_equal_approx(Color("#c9a227")))
	var b_satpam := SantriPlayer.build_visual("Satpam", MissionData.OUTFIT_SATPAM)
	var img_satpam := _mat_albedo(b_satpam["root"], "Sarung").albedo_texture.get_image()
	_cek("SATPAM piksel (8,0) dasar gelap #2b2b2b (parang)", img_satpam.get_pixel(8, 0).is_equal_approx(Color("#2b2b2b")))
	_cek("SATPAM piksel (0,0) BUKAN emas garis", not img_satpam.get_pixel(0, 0).is_equal_approx(Color("#c9a227")))

	# ---------- terapkan_outfit: ganti motif di tempat ----------
	var pemain := SantriPlayer.new()
	add_child(pemain)
	# _ready pemain membangun OUTFIT_DEFAULT (putra garis); ganti ke
	# outfit putri HANYA mewarnai (struktur tetap — rebuild milik
	# bangun_ulang_visual / _terapkan_outfit_sync, dites terpisah).
	pemain.terapkan_outfit(putri)
	var mat_ganti := _mat_albedo(pemain, "Sarung")
	_cek("TERAPKAN sarung jadi batik 512x256", mat_ganti != null and mat_ganti.albedo_texture != null and mat_ganti.albedo_texture.get_image().get_size() == Vector2i(512, 256))
	pemain.bangun_ulang_visual(putri)
	_cek("BANGUN-ULANG putri: tunik true", pemain.apakah_tunik())
	_cek("BANGUN-ULANG putri: muslimah true", pemain.apakah_muslimah())
	_cek("BANGUN-ULANG putri: ada Sarung, tanpa Abaya", pemain.find_child("Sarung", true, false) != null and pemain.find_child("Abaya", true, false) == null)
	pemain.bangun_ulang_visual(MissionData.OUTFIT_DEFAULT)
	_cek("BANGUN-ULANG putra: tunik false", not pemain.apakah_tunik())
	_cek("BANGUN-ULANG putra: ada Sarung, tanpa Abaya", pemain.find_child("Sarung", true, false) != null and pemain.find_child("Abaya", true, false) == null)

	# ---------- NPC: tunik TIDAK dipetakan ke varian abaya ----------
	var npc_putri := SantriNPC.new()
	add_child(npc_putri)
	npc_putri.setup("Tes Putri", Vector3(140, 0, 16), [Vector3(140, 0, 16)], putri, true)
	npc_putri._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DUDUK)
	_cek("NPC PUTRI duduk: skala sarung = PAKAIAN_DUDUK (1.70,0.45,1.70)", npc_putri._sarung.scale.is_equal_approx(Vector3(1.70, 0.45, 1.70)))
	npc_putri._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DEFAULT)
	_cek("NPC PUTRI berdiri: skala sarung = PAKAIAN_DEFAULT (1,1,1)", npc_putri._sarung.scale.is_equal_approx(Vector3.ONE))
	var npc_ustadzah := SantriNPC.new()
	add_child(npc_ustadzah)
	npc_ustadzah.setup("Ustadzah Mariyah", Vector3(134, 0, -17), [Vector3(134, 0, -17)], MissionData.OUTFIT_USTADZAH, true)
	npc_ustadzah._terapkan_pakaian(1.0, SantriPlayer.PAKAIAN_DUDUK)
	_cek("NPC USTADZAH duduk: skala abaya = ABAYA_DUDUK (1.65,0.72,1.65)", npc_ustadzah._sarung.scale.is_equal_approx(Vector3(1.65, 0.72, 1.65)))

	print("TES SERAGAM UTAMA: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
