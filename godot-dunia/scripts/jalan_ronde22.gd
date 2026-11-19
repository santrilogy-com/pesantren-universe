class_name JalanRonde22
## RONDE 22 (17 Nov — Sinta, semua jalan).
## File ini SATU-SATUNYA tempat jalan-jalan berikut dibangun:
## - Jalan N-S x=0, tiga segmen (perbaikan jalan ke Surau,
##   perintah Mas 06:05 WIB: "tidak lurus").
## - Jalan masuk internal pondok putri (115,0)->(115,8)->(142,8).
## Jalan akses E-W (14,0)->(115,0) TIDAK dibangun di sini:
## jalan E-W di _ground sudah satu box (320,0.06,2.5) di (0,0.03,0),
## x -160..+160 — sudah mencakup (14,0)->(115,0) lurus dan bersih.
## TIDAK ADA jalan pendek ke plot Masjid (stub (0,-19) DIHAPUS ronde
## ini); plot Masjid Besar sudah pindah ke (0,-32) (mission_data.gd)
## dan aksesnya dirancang ulang saat Masjid dibangun.
## TIDAK ADA jalan diagonal baru ke Surau — pendekatan ke pintu Surau:
## jalan N-S -> persimpangan T jalan E-W -> anak tangga serambi
## (tangga sudah menyentuh jalan E-W).
## INTEGRASI (Raka): panggil JalanRonde22.bangun(root) dari
## PesantrenBuilder.build() SEKALI, dan HAPUS salinan lamanya —
## tiga segmen N-S tanpa nama di _ground (pesantren_builder.gd)
## dan _jalan_masuk() di kampus_putri.gd — supaya tidak ada
## geometri ganda (z-fighting) di posisi yang sama.
## Semua jalan: pasir Palette.PASIR, tebal 0,06, y=0,03 (pola _ground).

## RONDE PERBAIKAN (Fajar, 17 Nov — retest Ronde 23: "jalan Surau
## meleset ~7 m dari pintu"): jalan N-S PINDAH dari x=0 ke x=-3,38
## (= x pintu luar Surau setelah rotasi -25°, lihat
## PesantrenBuilder.surau_pintu()) — garis lurus spawn (-4,14) ->
## pintu (-3,38,-6,75) kini SELURUHNYA di atas aspal (sebelumnya
## hanya 5/41 titik; pintu 5,50 m dari aspal terdekat).
## - Segmen selatan (z 1,25..14) + tengah (z 14..200): geser ke x=-3,38.
## - Segmen utara DIPENDEKKAN (z -200..-25,5; dulu -200..-24): dinding
## utara Surau yang diputar -25° mencapai z=-25,10 di tepi barat jalan
## (x=-4,88) — ujung lama z=-24 akan menusuk 1,1 m ke dalam cangkang.
## - BARU: JalanNS_Surau (z -3,44..-1,25, x=-3,38) — taji aspal dari
## tepi utara jalan E-W (z=-1,25) sampai tepi selatan serambi
## (z=-3,44 di garis tengah x=-3,38); serambi -> tangga -> pintu.
## Semua jalan: pasir Palette.PASIR, tebal 0,06, y=0,03 (pola _ground).
## Jalan N-S x=-3,38, tiga segmen (lebar 3 m, x -4,88..-1,88):
## - Selatan: (3,0.06,12.75) di (-3.38,0.03,7.625) — z +1,25..+14,
##   berakhir TEPAT di tepi utara jalan E-W (z=1,25): persimpangan
##   T yang rapi. Spawn putra (-4,14) tepat di atas jalan ini.
## - Tengah: (3,0.06,186) di (-3.38,0.03,107) — z +14..+200.
## - Utara: (3,0.06,174.5) di (-3.38,0.03,-112.75) — z -200..-25,5,
##   berakhir 0,4 m di utara dinding utara Surau (z=-25,10 di tepi
##   barat jalan; dinding miring -25°, lihat catatan di atas).
## - Taji Surau: (3,0.06,2.19) di (-3.38,0.03,-2.345) — z -3,44..-1,25,
##   tepi selatan menempel tepi utara jalan E-W, tepi utara menempel
##   tepi selatan serambi (di garis tengah); tiang serambi timur
##   (-2,30,-3,15) berdiri di atas taji (alasnya 6 cm di bawah
##   permukaan jalan — tidak terlihat dari mata normal).
## Segmen N-S ditambahkan LANGSUNG sebagai anak root (bukan di bawah
## grup) — sama seperti _ground dulu — supaya tes asap Ronde 22 yang
## memindai anak langsung root tetap menemukan ketiganya.
static func bangun(root: Node3D) -> void:
	var selatan := Palette.box(Vector3(3, 0.06, 12.75), Vector3(-3.38, 0.03, 7.625), Palette.PASIR)
	selatan.name = "JalanNS_Selatan"
	root.add_child(selatan)
	var tengah := Palette.box(Vector3(3, 0.06, 186), Vector3(-3.38, 0.03, 107), Palette.PASIR)
	tengah.name = "JalanNS_Tengah"
	root.add_child(tengah)
	var utara := Palette.box(Vector3(3, 0.06, 174.5), Vector3(-3.38, 0.03, -112.75), Palette.PASIR)
	utara.name = "JalanNS_Utara"
	root.add_child(utara)
	var surau := Palette.box(Vector3(3, 0.06, 2.19), Vector3(-3.38, 0.03, -2.345), Palette.PASIR)
	surau.name = "JalanNS_Surau"
	root.add_child(surau)
	_jalan_masuk(root)


## Jalan masuk kampus putri (115,0)->(115,8)->(142,8) — pindahan
## PERSIS dari _jalan_masuk() KampusPutri (Cakra, terverifikasi
## 17 Nov ~06:16 WIB). Membelok (bukan lurus z=0) karena Kelas
## Putri (130,0) menghalangi jalan lurus z=0.
## - Kaki utara 'JalanMasukUtara': (2.5,0.06,6.75) di (117.5,0.03,4.625)
##   — x 116,25..118,75, z 1,25..8,0; tepi barat 1,05 m dari muka
##   timur tembok keliling (x=115,2); tepi selatan z=1,25 menempel
##   tepi utara jalan E-W (z=1,25), edge-to-edge.
## - Kaki timur 'JalanMasukTimur': (21.75,0.06,2.5) di (129.625,0.03,8)
##   — x 118,75..140,5, z 6,75..9,25; menempel tepi timur kaki utara
##   (x=118,75) dan tepi barat jalan internal x=142 (x=140,5);
##   2,75 m di selatan dinding selatan Kelas Putri (z=+4).
static func _jalan_masuk(root: Node3D) -> void:
	var j := Node3D.new()
	j.name = "JalanMasuk"
	root.add_child(j)
	var utara := Palette.box(Vector3(2.5, 0.06, 6.75), Vector3(117.5, 0.03, 4.625), Palette.PASIR)
	utara.name = "JalanMasukUtara"
	j.add_child(utara)
	var timur := Palette.box(Vector3(21.75, 0.06, 2.5), Vector3(129.625, 0.03, 8), Palette.PASIR)
	timur.name = "JalanMasukTimur"
	j.add_child(timur)
