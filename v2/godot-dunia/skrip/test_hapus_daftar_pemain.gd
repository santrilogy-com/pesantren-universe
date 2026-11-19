extends Node
## Tes hapus daftar nama pemain online (Dimas, 19 Nov 2026 — keputusan
## Mas 12:32 WIB: "list nama player online ga perlu").
##
##   godot --headless --path . skrip/test_hapus_daftar_pemain.tscn
##
## Kriteria:
##   (a) variabel _mp_pemain_label TIDAK ADA lagi di UI.
##   (b) method set_mp_pemain TIDAK ADA lagi di UI.
##   (c) set_mp_status("online") tetap jalan: label status "Online (N pemain)",
##       tombol "Main Bersama" sembunyi saat online; lalu status "offline"
##       mengembalikan tombol.
##   (d) tidak ada Label di HUD yang berisi daftar ("Online:\n- ...").
##   (e) label nama di atas kepala pemain lokal MASIH ADA (Label3D, teks terisi).
## Exit 0 = semua lulus; bukan-nol = ada gagal.

var _main: Node = null
var _lulus := 0
var _gagal := 0
var _tunggu := 0.0
var _sudah_nilai := false


func _ready() -> void:
	_main = get_parent()


func _process(delta: float) -> void:
	if _sudah_nilai:
		return
	_tunggu += delta
	if _tunggu > 180.0:
		_gagal += 1
		print("[HAPUS-DAFTAR] GAGAL: timeout menunggu Main siap (>180 dtk)")
		_selesai()
		return
	if _main == null or _main.get("_ui") == null or _main.get("_player") == null:
		return
	_nilai()


func _cek(nama: String, ok: bool, detail: String = "") -> void:
	if ok:
		_lulus += 1
		print("[HAPUS-DAFTAR] LOLOS: %s" % nama)
	else:
		_gagal += 1
		print("[HAPUS-DAFTAR] GAGAL: %s %s" % [nama, detail])


func _cari_label_daftar(node: Node) -> Label:
	for c in node.get_children():
		if c is Label and String((c as Label).text).begins_with("Online:"):
			return c as Label
		var ketemu := _cari_label_daftar(c)
		if ketemu != null:
			return ketemu
	return null


func _nilai() -> void:
	_sudah_nilai = true
	var ui: Node = _main.get("_ui")
	# (a) variabel daftar sudah tidak ada.
	_cek("(a) _mp_pemain_label tidak ada", ui.get("_mp_pemain_label") == null)
	# (b) method pengisi daftar sudah tidak ada.
	_cek("(b) set_mp_pemain tidak ada", not ui.has_method("set_mp_pemain"))
	# (c) status online tetap jalan + tombol gabung sembunyi; offline kembalikan.
	_main.call("_mp_set_status", "online")
	var teks_status := String(ui.get("_mp_status_label").text) if ui.get("_mp_status_label") != null else "?"
	_cek("(c1) status online tampil", teks_status.begins_with("Online ("), "teks='%s'" % teks_status)
	_cek("(c2) tombol gabung sembunyi saat online", ui.get("_mp_gabung_btn") != null and not (ui.get("_mp_gabung_btn") as Button).visible)
	_main.call("_mp_set_status", "offline")
	_cek("(c3) tombol gabung kembali saat offline", ui.get("_mp_gabung_btn") != null and (ui.get("_mp_gabung_btn") as Button).visible and not (ui.get("_mp_gabung_btn") as Button).disabled)
	# (d) tidak ada Label daftar di HUD.
	var hud: Node = ui.get("_hud")
	var daftar: Label = _cari_label_daftar(hud) if hud != null else null
	_cek("(d) tidak ada label daftar di HUD", daftar == null, "ketemu='%s'" % (String(daftar.text) if daftar != null else ""))
	# (e) label nama di atas kepala pemain lokal masih utuh.
	var nama_label: Variant = _main.get("_player").get("_name_label")
	_cek("(e1) _name_label pemain masih Label3D", nama_label is Label3D)
	_cek("(e2) _name_label terisi nama", nama_label is Label3D and String((nama_label as Label3D).text) != "", "teks='%s'" % (String((nama_label as Label3D).text) if nama_label is Label3D else "?"))
	_selesai()


func _selesai() -> void:
	print("[HAPUS-DAFTAR] HASIL: %d lulus, %d gagal" % [_lulus, _gagal])
	get_tree().quit(0 if _gagal == 0 else 1)
