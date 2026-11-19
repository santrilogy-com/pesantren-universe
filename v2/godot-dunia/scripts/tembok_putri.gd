class_name TembokPutri
## RONDE 22 — Tembok keliling pondok putri (ACC Mas 17 Nov ~06:11 WIB:
## "Pagar tembok pondok putri mengelilingi pondok").
## Persegi x 115..216, z -70..+40 (101x110 m) — DIPERLUAS 18 Nov (Mira,
## perintah Mas 00:28 WIB "Langsung aja ya.. intinya diperluas.."):
## barat TETAP x=115 (gerbang (115,0) + zona penyangga tidak disentuh);
## timur 180->216 (menelan tapak Lapangan Putri (198,12) ke dalam kampus);
## utara -52->-70 (reserve Masjid Putri (166,-40) kini 22 m dari tembok);
## selatan 22->40 (halaman selatan Kelas/Asrama). Solid tertutup 3 m x 0,4 m,
## plester krem #F2EAD6 + lis emas + fondasi batu, collision penuh —
## bahan SAMA seperti tembok x=14. Satu-satunya bukaan: GERBANG PUTRI
## di (115,0), lebar 4 m (z -2..+2), 2 pilar (115,±2) + gapura + label
## GERBANG PUTRI, PINTU TERTUTUP + barrier collision penuh melintasi
## bukaan (celah visual, bukan celah lewat). Tembok x=14 TETAP
## (pemisah zona); pagar kayu taman Musholla + Pos Jaga TL TETAP di
## dalam keliling; reserve Masjid Putri peta v2 (166,-40) di dalam keliling
## (alasan tembok utara z=-70) — TIDAK dibangun ronde ini.
## Dibangun oleh Cakra; digabung oleh Raka (koordinator).
## Kontrak: static func bangun(root: Node3D) -> void.
## JANGAN sebut pesantren "dunia".
##
## RONDE 23 (Cakra) — CAHAYA ISI UTARA. Foto 28 Ronde 22: sisi luar
## z=-52 tampil abu-abu kehijauan gelap, bukan krem. Penyebab
## TERVERIFIKASI (render ulang sudut sama jam 10:00/12:00/15:00 —
## foto 40-43): muka luar z=-52 TIDAK PERNAH kena matahari langsung
## sepanjang hari, hanya ambient langit. Koreksi arah dari hipotesis
## awal: muka itu menghadap UTARA (-Z, azimut 0°), bukan selatan —
## konvensi dunia ini +Z = selatan (minimap ui.gd: "y = selatan/+z";
## sawah "tenggara" di (60,+30); gunung "di selatan" di z≈+330;
## kiblat 295° konsisten dengan azimut 0 = utara = -Z). Matahari jam
## 10:00 di azimut 118° (dot dengan normal -Z = -0,27), jam 12:00 di
## 200° (dot -0,44), jam 15:00 di 252° (dot -0,31) — selalu negatif,
## jadi prediksi "siang lebih terang" SALAH dan terbukti salah di
## foto 42/43. Nama node "Selatan"/"Utara" di file ini TETAP (tes
## Ronde 22 mengacu ke nama itu) meski tertukar arah mata anginnya.
## Perbaikan: satu DirectionalLight3D isi TANPA bayangan dari langit
## utara (azimut 0°, elevasi 20°), energi mengikuti jam (0 di malam
## hari — tembok TIDAK menyala sendiri; penuh 05:30–17:30).
## ISOLASI LAPIS (supaya isi tidak menyentuh scene lain): semua mesh
## tembok dipindah ke visual layer 2 (LAPIS_TEMBOK) dan cull mask
## cahaya isi HANYA layer 2 — gunung, rumput, dan bangunan lain
## (layer 1) tidak kena isi sama sekali. Matahari utama (mask semua
## lapis) + lampu tetap menyinari tembok seperti biasa; kamera utama
## (mask semua lapis) tetap melihat tembok. Proyek ini sebelumnya
## tidak memakai visual layer sama sekali, jadi layer 2 kosong.
## Geometri + collision tembok TIDAK berubah; jalur matahari +
## Palette.KREM TIDAK disentuh.

const KELILING_X_MIN := 115.0
const KELILING_X_MAX := 216.0
const KELILING_Z_MIN := -70.0
const KELILING_Z_MAX := 40.0
const KELILING_GARIS: Array[Vector2] = [
	Vector2(115, -70), Vector2(216, -70), Vector2(216, 40),
	Vector2(115, 40), Vector2(115, -70),
]
const GERBANG_PUTRI_POS := Vector3(115, 0, 0)

## RONDE 23 — cahaya isi dari langit utara (lihat catatan header).
## Energi siang penuh; 0 di malam hari (tembok tidak menyala sendiri).
## KALIBRASI (Cakra, foto tuning dekat 10:00): energi 0,35 hanya
## mengangkat dinding ke (149,173,145) — masih abu-abu kehijauan
## (baseline (103,145,123)). Muka timur yang kena matahari merender
## (254,255,255) dengan direct 1,25 × dot 0,51 ≈ 0,64 — supaya muka
## utara menyamai, isi butuh ≈ 0,64 / cos(elevasi). Elevasi 20°
## dipilih supaya muka utara dapat 1,2 × cos 20° ≈ 1,13 sementara
## muka horizontal (tanah/atap) hanya +0,41 — dan dengan isolasi
## lapis, tanah di luar tembok tidak kena isi sama sekali.
## Energi 0,75 ternyata hanya (174,192,162): ambient langit utara
## jauh lebih redup dari ambient timur (dekat matahari), jadi isi
## harus mendominasi ambient — energi 1,2 mencapai (208,197,174)
## jauh / krem terang dekat, lis emas jelas. Versi global 1,2 sempat
## membuat lereng utara gunung kuning-hijau pucat — DIATASI dengan
## isolasi lapis (isi hanya layer 2 = tembok), jadi energi 1,2
## dipakai tanpa efek samping ke scene lain.
const ENERGI_ISI := 1.2
## Visual layer khusus tembok (bit layer 2). Lihat catatan header.
const LAPIS_TEMBOK := 2
const AZIMUT_ISI := 0.0
const ELEVASI_ISI := 20.0
## Warna isi: hangat seperti matahari pagi (#fff3d6, keyframe 10:00
## K_MATAHARI) supaya muka teduh tampil krem, bukan biru-abu.
## KALIBRASI lanjutan: energi 0,75 hanya mencapai (174,192,162)
## (G-R masih +18) — ambient langit utara redup + kehijauan (pantulan
## rumput di ground sky) sehingga isi harus mendominasi ambient, bukan
## sekadar menambah. Warna dibuat lebih hangat (#ffd9a0, senja) untuk
## menetralkan sisa hijau; energi 1,2.
const WARNA_ISI := Color("#ffd9a0")


## Faktor siang 0..1 untuk cahaya isi: penuh 05:30–17:30, padam
## 18:00–05:00, transisi halus di subuh/senja (ikut fase K_LANGIT).
static func _faktor_siang(jam: float) -> float:
	var j := fmod(jam, 24.0)
	if j < 0.0:
		j += 24.0
	if j >= 5.5 and j <= 17.5:
		return 1.0
	if j < 5.5:
		return smoothstep(5.0, 5.5, j)
	if j > 17.5:
		return 1.0 - smoothstep(17.5, 18.0, j)
	return 0.0


## Pindah satu mesh tembok ke visual layer 2 (isolasi cahaya isi).
static func _lapis(mi: MeshInstance3D) -> MeshInstance3D:
	mi.layers = LAPIS_TEMBOK
	return mi


## DirectionalLight3D isi: energi mengikuti jam nyata/debug tiap frame.
class CahayaIsiUtara extends DirectionalLight3D:
	func _process(_delta: float) -> void:
		light_energy = TembokPutri.ENERGI_ISI * TembokPutri._faktor_siang(LangitDinamis.jam_saat_ini())


static func bangun(root: Node3D) -> void:
	var t := Node3D.new()
	t.name = "TembokKeliling"
	root.add_child(t)
	# Sisi barat: dua segmen (terbelah gerbang z -2..+2).
	# Utara: z -70..-2 (68 m), pusat z=-36.
	var barat_u := _lapis(PesantrenBuilder._static_box(t, Vector3(0.4, 3.0, 68), Vector3(115, 1.5, -36), Palette.KREM))
	barat_u.name = "TembokKelilingBaratUtara"
	# Selatan: z +2..+40 (38 m), pusat z=21.
	var barat_s := _lapis(PesantrenBuilder._static_box(t, Vector3(0.4, 3.0, 38), Vector3(115, 1.5, 21), Palette.KREM))
	barat_s.name = "TembokKelilingBaratSelatan"
	# Sisi timur: x=216, z -70..+40 (110 m), pusat z=-15.
	var timur := _lapis(PesantrenBuilder._static_box(t, Vector3(0.4, 3.0, 110), Vector3(216, 1.5, -15), Palette.KREM))
	timur.name = "TembokKelilingTimur"
	# Sisi utara: z=+40, x 115..216 (101 m), pusat x=165,5.
	var utara := _lapis(PesantrenBuilder._static_box(t, Vector3(101, 3.0, 0.4), Vector3(165.5, 1.5, 40), Palette.KREM))
	utara.name = "TembokKelilingUtara"
	# Sisi selatan: z=-70, x 115..216 (101 m), pusat x=165,5.
	var selatan := _lapis(PesantrenBuilder._static_box(t, Vector3(101, 3.0, 0.4), Vector3(165.5, 1.5, -70), Palette.KREM))
	selatan.name = "TembokKelilingSelatan"
	# Lis emas di atas tembok + fondasi batu di bawah (visual, tanpa collision).
	t.add_child(_lapis(Palette.box(Vector3(0.44, 0.1, 68), Vector3(115, 3.05, -36), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(0.44, 0.1, 38), Vector3(115, 3.05, 21), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(0.44, 0.1, 110), Vector3(216, 3.05, -15), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(101, 0.1, 0.44), Vector3(165.5, 3.05, 40), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(101, 0.1, 0.44), Vector3(165.5, 3.05, -70), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(0.5, 0.3, 68), Vector3(115, 0.15, -36), Palette.BATU)))
	t.add_child(_lapis(Palette.box(Vector3(0.5, 0.3, 38), Vector3(115, 0.15, 21), Palette.BATU)))
	t.add_child(_lapis(Palette.box(Vector3(0.5, 0.3, 110), Vector3(216, 0.15, -15), Palette.BATU)))
	t.add_child(_lapis(Palette.box(Vector3(101, 0.3, 0.5), Vector3(165.5, 0.15, 40), Palette.BATU)))
	t.add_child(_lapis(Palette.box(Vector3(101, 0.3, 0.5), Vector3(165.5, 0.15, -70), Palette.BATU)))
	# Pilar gerbang putri (115,±2): 0,6x3,4x0,6 + tutup emas.
	# (Pusat pilar 0,75 m dari tepi jalan E-W — sama seperti gerbang (14,0).)
	var pilar_u := _lapis(PesantrenBuilder._static_box(t, Vector3(0.6, 3.4, 0.6), Vector3(115, 1.7, -2), Palette.KREM))
	pilar_u.name = "PilarGerbangPutriUtara"
	var pilar_s := _lapis(PesantrenBuilder._static_box(t, Vector3(0.6, 3.4, 0.6), Vector3(115, 1.7, 2), Palette.KREM))
	pilar_s.name = "PilarGerbangPutriSelatan"
	t.add_child(_lapis(Palette.box(Vector3(0.7, 0.15, 0.7), Vector3(115, 3.45, -2), Palette.EMAS_DESAIN, 0.4)))
	t.add_child(_lapis(Palette.box(Vector3(0.7, 0.15, 0.7), Vector3(115, 3.45, 2), Palette.EMAS_DESAIN, 0.4)))
	# Gapura: balok di atas bukaan (y 3,4..3,9) + lis emas + atap zamrud.
	var gapura := Node3D.new()
	gapura.name = "GapuraGerbangPutri"
	t.add_child(gapura)
	_lapis(PesantrenBuilder._static_box(gapura, Vector3(0.5, 0.5, 4.6), Vector3(115, 3.65, 0), Palette.KREM))
	gapura.add_child(_lapis(Palette.box(Vector3(0.54, 0.1, 4.6), Vector3(115, 3.92, 0), Palette.EMAS_DESAIN, 0.4)))
	gapura.add_child(_lapis(Palette.box(Vector3(0.8, 0.15, 5.0), Vector3(115, 4.0, 0), Palette.ZAMRUD_GELAP)))
	# Label GERBANG PUTRI menghadap barat (sisi penyangga) & timur (sisi kampus).
	# RONDE PERBAIKAN (Fajar): double_sided=false di keduanya — tiap
	# sisi sudah punya label sendiri yang menghadap keluar; sisi
	# belakang label (cermin) terlihat dari sisi seberang lewat bawah
	# gapura (temuan retest Ronde 23, sama seperti GERBANG (14,0)).
	var label_barat := Palette.label3d("GERBANG PUTRI", Vector3(114.7, 3.65, 0), 24, Color("#f2c14e"), false)
	label_barat.name = "LabelGerbangPutriBarat"
	label_barat.rotation.y = -PI / 2.0
	label_barat.double_sided = false
	gapura.add_child(label_barat)
	var label_timur := Palette.label3d("GERBANG PUTRI", Vector3(115.3, 3.65, 0), 24, Color("#f2c14e"), false)
	label_timur.name = "LabelGerbangPutriTimur"
	label_timur.rotation.y = PI / 2.0
	label_timur.double_sided = false
	gapura.add_child(label_timur)
	# PINTU GERBANG PUTRI TERTUTUP: dua daun jati rapat (visual) +
	# barrier collision penuh melintasi bukaan (inilah yang menahan pemain).
	var pintu := Node3D.new()
	pintu.name = "PintuGerbangPutri"
	t.add_child(pintu)
	pintu.add_child(_lapis(Palette.box(Vector3(0.1, 2.6, 1.9), Vector3(115, 1.3, -1), Palette.JATI)))
	pintu.add_child(_lapis(Palette.box(Vector3(0.1, 2.6, 1.9), Vector3(115, 1.3, 1), Palette.JATI)))
	pintu.add_child(_lapis(Palette.box(Vector3(0.12, 0.12, 3.8), Vector3(115, 2.65, 0), Palette.EMAS_DESAIN, 0.4)))
	var barrier := StaticBody3D.new()
	barrier.name = "BarrierGerbangPutri"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.4, 3.0, 4.0)
	col.shape = shape
	col.position = Vector3(115, 1.5, 0)
	barrier.add_child(col)
	pintu.add_child(barrier)
	# RONDE 23 — cahaya isi utara (tanpa bayangan, energi ikut jam).
	# DirectionalLight3D bersifat global: posisi node tidak penting,
	# yang penting arah basis (dari langit utara, azimut 0°).
	# light_cull_mask = layer 2 SAJA: isi hanya menyentuh mesh
	# tembok (sudah dipindah ke layer 2 di atas) — gunung, rumput,
	# dan bangunan lain tidak kena.
	var isi := CahayaIsiUtara.new()
	isi.name = "CahayaIsiUtara"
	isi.basis = Basis.looking_at(-LangitDinamis.arah(AZIMUT_ISI, ELEVASI_ISI), Vector3.UP)
	isi.light_color = WARNA_ISI
	isi.light_energy = ENERGI_ISI
	isi.light_cull_mask = LAPIS_TEMBOK
	isi.shadow_enabled = false
	t.add_child(isi)
