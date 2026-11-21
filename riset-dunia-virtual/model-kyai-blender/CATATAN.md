# CATATAN — Kyai Chibi Blender (Bima, 21 Nov 2026)

## File
- `build_kyai.py` — skrip build lengkap (dijalankan ulang = rebuild penuh)
- `kyai-chibi.blend` — scene sumber (2,4 MB)
- `kyai-chibi.glb` — export glTF 2.0 + Draco, 216.992 B, **57 mesh, 49.156 tris** (target <100k ✓)
- `render-depan.png`, `render-34.png`, `render-samping.png`,
  `render-wajah-depan.png` (close-up DEPAN), `render-tanpa-kacamata.png`
- Blender: portable 4.0.2 di `~/workspace/.tools/blender-4.0.2-linux-x64/blender`
  (persisten di workspace; apt hilang tiap ganti VM). `libegl1 libgl1
  libglx-mesa0` sudah terinstal di VM ini (bisa hilang saat ganti VM —
  Eevee tetap jalan, ada warning EGL tapi render selesai).

## Cara bangun (semua lewat skrip, tanpa sculpt interaktif)
Kepala bola UV 64 seg → deformasi vertex matematis (pipi/dagu, falloff
proporsional = setara brush Grab/Inflate/Smooth) → Subdivision Surface 1–2
level → bevel tepi. Serban = lathe (profil Catmull-Rom) + 3 torus lilitan
yang di-shear & di-noise ringan. Kacamata = outline mesh datar (ngon) +
Solidify + Bevel, yaw 22° mengikuti lengkung wajah. Jenggot = elipsoid
yang "dipeluk" ke permukaan kepala (clamp ke permukaan + ketebalan
0,02–0,06) + tepi atas ditarik ke dalam di bawah mulut. Jubah = lathe
A-line + hem bergelombang (noise halus). Tasbih 14 butir + rumbai.
Material Principled BSDF, warna sampling dari foto referensi, dikonversi
sRGB→linear (wajib — kalau tidak, warna jadi pucat/overexposed).
Render Eevee 1024², 64 sample, 3 area light + world 0,4.

## Yang kena (vs referensi chibi vinyl-toy)
1. Kacamata cat-eye: sayap ujung luar terangkat jelas, frame tipis
   mengikuti lengkung wajah, lensa melengkung — BUKAN gumpalan/masker
   (v6.1) dan bukan sirip dari samping (lensa kini menempel, yaw 22°).
2. Serban: dome mulus duduk rendah + 3 lilitan terbaca jelas — bukan
   topi renang (v6.1).
3. Jenggot: mengikuti rahang, dari samping TIDAK membaji (terverifikasi
   di render-samping) — ujung bawah meruncing lembut ke dagu.
4. Anti-balok: semua bentuk di-subdivide/di-deformasi — tidak ada bola/
   kapsul/kerucut polos yang kelihatan.
5. Wajah minimal: blush lembut, senyum tipis (kini terlihat, tidak lagi
   tertutup jenggot), hidung kecil, mata dot di balik kacamata
   (mode tanpa kacamata terverifikasi di render-tanpa-kacamata).
6. Identitas Kyai: serban navy, jubah putih + 3 kancing, jenggot, tasbih.

## Yang masih meleset (jujur)
- Sayap kacamata sudah jelas tapi BELUM sedramatis referensi (ujung
  referensi lebih tajam & menyapu lebih tinggi). Menaikkannya lagi
  lewat skrip berisiko lensa menabrak pelipis — batas yang aman
  menurut perhitungan sudah dicapai.
- Tepi atas jenggot di close-up depan masih berupa garis lurus yang
  agak keras (persimpangan dua permukaan, bukan fillet). Dari depan
  jarak penuh dan 3/4 tidak mengganggu.
- Lilitan serban masih berupa cincin yang agak sejajar (belum diagonal
  tumpang-tindih seperti lilitan kain asli); dome sedikit datar di puncak.
- Hidung masih berupa tonjolan bulat kecil (sengaja, gaya chibi).
- Lengan masih kapsul halus — sambungan bahu terbaca sedikit, tapi
  tertutup jubah dari depan.
- Render Eevee software (llvmpipe) lambat: ~3 menit untuk 5 render.
  Ada warning EGL di log, tapi render selesai normal.

## Bug yang ditemukan & diperbaiki selama build
- `BLENDER_EEVEE_NEXT` tidak ada di 4.0.2 → pakai `BLENDER_EEVEE`.
- Operator `primitive_torus_add` 4.0 tidak punya parameter `arc` →
  jembatan kacamata & mulut diganti tabung Bezier.
- `bmesh.faces[0]` butuh `ensure_lookup_table()` dulu.
- Scene kosong tidak punya World → dibuat bila belum ada.
- Kamera: `rotation_quaternion` harus diisi SETELAH
  `rotation_mode='QUATERNION'`, dan arah pandang harus pakai
  `to_track_quat('-Z','Y')` — `rotation_difference` membuat gambar
  terbalik/miring (roll tak terkontrol).
- Warna material harus dikonversi sRGB→linear, kalau tidak semua warna
  pucat & overexposed.
- Kamera depan harus di +Y (wajah menghadap +Y), bukan −Y.
