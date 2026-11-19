class_name NPCFatimah
## NPC Ustzh. Fatimah — guru santri putri (Kirana, 18 Nov 2026).
##
## Keputusan Mas 18:55 WIB (§9 butir 22): santri putri -> Ustzh.
## Mariyah (pengasuh, SUDAH ADA) -> Ustzh. Fatimah (guru, BARU,
## pola Ust. Sanusi). File ini CERMINAN Onboarding.buat_sanusi() +
## tempatkan_sanusi() — dipindah ke file sendiri supaya wiring
## main.gd tinggal menukar pemanggilan (lihat patch di bawah).
##
## PAKEM:
##   - Fatimah HANYA di area putri (semua x > 14, di balik tembok
##     x=14). Lokasi acak dari LokasiAcak.KANDIDAT_PUTRI, TANPA
##     marker di peta (pola Sanusi — santriwati yang mencari dia).
##   - Mode DIAM (berdiri tetap di tempat, santri yang datang).
##   - SATU Fatimah saja — JANGAN panggil buat() dua kali.
##   - SENGAJA TIDAK masuk _npcs main.gd: keikutsertaan di sholat
##     berjamaah belum diputuskan (sama seperti Sanusi).
##
## CARA PAKAI (wiring, Raka — di main.gd _spawn_npcs(), SATU tempat
## saja, setelah blok Sanusi; ganti blok Onboarding.buat_fatimah()
## yang sudah ada dengan blok ini):
##   _fatimah = NPCFatimah.buat(self)
##   var ob_fatimah := Onboarding.baca(_save)
##   var lok_fatimah_id := String(ob_fatimah["fatimah_lokasi"])
##   if LokasiAcak.id_valid_putri(lok_fatimah_id):
##       NPCFatimah.tempatkan(_fatimah, LokasiAcak.pos_dari_id_putri(lok_fatimah_id))
##   else:
##       var lok_acak_putri := LokasiAcak.acak_putri()
##       NPCFatimah.tempatkan(_fatimah, lok_acak_putri["pos"])
##   _fatimah.rute_selesai.connect(_on_npc_rute_selesai)
## Sinyal pesan belum disambung ke UI — dialog Fatimah bagian A9
## (Sinta), sama seperti Sanusi.
##
## TAMBAHAN (Kirana, sesi yang sama): tempatkan() kini BERPENJAGA —
## posisi di luar area putri DITOLAK (return false, NPC tetap di
## tempat). + di_area_putri() + acak_lokasi() / lokasi_berikutnya()
## / semua_id_lokasi() + dialog_babak() (delegasi DataDialogMisi,
## varian putri — Mariyah menugaskan cari Fatimah, TEKS DRAF).

## Batas area putri (tembok keliling putri — kampus_putri.gd:
## x 115..216, z -70..+40). Kandidat Fatimah WAJIB di dalam
## kotak ini; tembok x=14 memisahkan dari area putra.
const BATAS_PUTRI := {"x_min": 115.0, "x_max": 216.0, "z_min": -70.0, "z_max": 40.0}
## Garis tembok pemisah putra/putri (x=14). Posisi dengan x <= 14
## adalah area putra / kawasan bersama — Fatimah TIDAK BOLEH ke sana.
const TEMBOK_X := 14.0

## Outfit Ustzh. Fatimah — format PERSIS
## MissionData.OUTFIT_USTADZAH, tapi abaya ZAMRUD GELAP #043B2C
## (bukan #065F46) supaya tidak tertukar dengan Ustzh. Mariyah.
## (Satu-satunya OUTFIT_FATIMAH — factory NPCFatimah ini;
## onboarding.gd hanya menyimpan kunci save "fatimah_lokasi".)
const OUTFIT_FATIMAH := {"koko": "#043B2C", "songkok": "#faf7f0", "sarung": "#043B2C", "kulit": "#c68e5e", "kacamata": false, "hijab": true, "hijab_warna": "#f2ead6", "abaya": "#043B2C", "muslimah": true}

## Posisi awal (placeholder) = spawn putri (140,16); wiring
## gelombang 2 MEMINDAHKAN dia ke lokasi acak putri tiap misi
## "cari Ustzh. Fatimah" dimulai — lihat tempatkan().
const SPAWN_PUTRI := Vector3(140, 0, 16)


## Buat NPC Ustzh. Fatimah (BARU — bukan Mariyah/Kyai/Sanusi).
## Mode DIAM (berdiri tetap di tempat — santriwati yang mencari
## dia, bukan dia yang keliling).
## JANGAN panggil buat() dua kali (satu Fatimah saja).
static func buat(parent: Node) -> SantriNPC:
	var npc := SantriNPC.new()
	npc.setup("Ustzh. Fatimah", SPAWN_PUTRI, [SPAWN_PUTRI], OUTFIT_FATIMAH, true)
	parent.add_child(npc)
	return npc


## Apakah posisi ini di area putri (di balik tembok x=14 dan di
## dalam batas tembok keliling putri)? Dipakai penjaga tempatkan().
static func di_area_putri(pos: Vector3) -> bool:
	if pos.x <= TEMBOK_X:
		return false
	return pos.x >= float(BATAS_PUTRI["x_min"]) and pos.x <= float(BATAS_PUTRI["x_max"]) and pos.z >= float(BATAS_PUTRI["z_min"]) and pos.z <= float(BATAS_PUTRI["z_max"])


## Pindahkan Fatimah ke posisi lokasi acak putri (dipanggil tiap
## misi "cari Ustzh. Fatimah" dimulai — setelah LokasiAcak
## putri diacak). Mode DIAM membuat dia tetap di situ sampai
## dipindah lagi.
## PENJAGA (Kirana): posisi di luar area putri DITOLAK — return
## false dan NPC TETAP di tempat (tidak dipindah). Null check:
## panggilan dengan npc null return false, tidak crash (pola
## tempatkan_sanusi()). true = berhasil dipindah.
static func tempatkan(npc: SantriNPC, pos: Vector3) -> bool:
	if npc == null:
		return false
	if not di_area_putri(pos):
		return false
	npc.position = pos
	return true


## Pilih satu lokasi putri acak (delegasi ke LokasiAcak).
## seed >= 0 = deterministik (tes); seed < 0 = acak perangkat.
static func acak_lokasi(seed: int = -1) -> Dictionary:
	return LokasiAcak.acak_putri(seed)


## Lokasi Fatimah untuk misi "cari Ustzh. Fatimah" berikutnya
## (delegasi ke LokasiAcak): dijamin BERBEDA dari lokasi saat ini
## bila REFRESH_PER_MISI aktif. id_sekarang "" = belum ada lokasi.
static func lokasi_berikutnya(id_sekarang: String, seed: int = -1) -> Dictionary:
	return LokasiAcak.lokasi_berikutnya_putri(id_sekarang, seed)


## Semua id kandidat lokasi putri (untuk tes + panel misi nanti).
static func semua_id_lokasi() -> Array[String]:
	var out: Array[String] = []
	for k in LokasiAcak.KANDIDAT_PUTRI:
		out.append(String(k["id"]))
	return out


## Satu babak dialog aturan versi putri (delegasi ke DataDialogMisi):
## pembicara Ustzh. Mariyah; babak 4-5 menugaskan "cari Ustzh.
## Fatimah" (substitusi mekanis §9 butir 22, bukan kalimat baru).
## TEKS DRAF — isi menunggu tashih Mas (§9 butir 17).
## Bentuk: {"teks": String, "pilihan": Array[{"teks","ke"}]};
## nomor di luar 1..5 -> {}.
static func dialog_babak(nomor: int) -> Dictionary:
	return DataDialogMisi.babak(nomor, "putri")
