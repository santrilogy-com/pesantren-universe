#!/usr/bin/env python3
"""Perbaiki pintu Surau GLB: dua daun jati DIBUKA ke luar (~110 derajat,
terlipat ke arah dinding luar serambi) supaya dari luar terlihat TERBUKA
seperti primitif v1 — bukan panel cokelat tertutup seperti di foto alpha F1.

Geometri (dari build_surau.py):
  - daun kiri/kanan SR_Pintu_Kiri/Kanan: kotak di (10.2, -/+0.99, 1.8),
    ukuran (0.06, 1.95, 2.6) — engsel di tepi luar (Y -/+1.965).
  - kenop SR_Pintu_KnobKiri/Kanan di (10.14, -/+0.15, 1.8) ikut berputar
    mengelilingi engsel yang sama.
  - garis tengah emas SR_Pintu_GarisTengah dihapus (penutup sambungan
    daun tertutup — tidak berlaku kalau daun terbuka).
  - kisi di atas pintu (z 3.1..6.9) + ambang emas TIDAK disentuh.
  - daun terbuka 110 derajat: ujung bebas di (12.03, -/+2.63) — lewat
    bukaan portal (Y -2.4..2.4) tanpa menabrak blok portal; tidak sampai
    ke tiang serambi (X 12.9, Y -/+1). Tumpang 0,1 m dengan atap serambi
    di strip atas daun SUDAH ADA sejak daun tertutup (tidak kelihatan).

HANYA ubah surau-v2.blend + export ulang surau-v2.glb. JANGAN sentuh
proyek Godot v2 / deploy — itu langkah terpisah.

Jalankan dari folder surau:
  blender -b --python fix_pintu_surau.py
Blender 4.5.16 headless.
"""
import bpy
import math
import os
from mathutils import Vector

BLEND_DIR = os.path.dirname(os.path.abspath(__file__))
BLEND = os.path.join(BLEND_DIR, "surau-v2.blend")
OUT_GLB = os.path.join(BLEND_DIR, "surau-v2.glb")

bpy.ops.wm.open_mainfile(filepath=BLEND)

ANGLE = math.radians(110.0)  # derajat bukaan daun


def buka_daun(nama_daun, nama_knob, hinge_y, sign):
    """Putar daun + kenop mengelilingi engsel (tepi luar daun)."""
    daun = bpy.data.objects.get(nama_daun)
    assert daun is not None, "tidak ketemu: " + nama_daun
    # pindahkan origin objek ke engsel: geser mesh, lalu geser location
    cy = daun.location.y
    dy = cy - hinge_y  # geser mesh sebesar ini supaya posisi dunia tetap
    for v in daun.data.vertices:
        v.co.y -= dy
    daun.location.y = hinge_y
    daun.rotation_euler = (0.0, 0.0, sign * ANGLE)
    print("DAUN %s: engsel Y %.3f, rotasi Z %+.1f derajat"
          % (nama_daun, hinge_y, math.degrees(sign * ANGLE)))

    knob = bpy.data.objects.get(nama_knob)
    assert knob is not None, "tidak ketemu: " + nama_knob
    # putar posisi kenop mengelilingi titik engsel (10.2, hinge_y)
    rel = Vector((knob.location.x - 10.2, knob.location.y - hinge_y))
    rot = math.radians(sign * 110.0)
    c, s = math.cos(rot), math.sin(rot)
    rel2 = Vector((rel.x * c - rel.y * s, rel.x * s + rel.y * c))
    knob.location.x = 10.2 + rel2.x
    knob.location.y = hinge_y + rel2.y
    print("KNOB %s: (%.2f, %.2f) -> (%.2f, %.2f)"
          % (nama_knob, 10.2 + rel.x, hinge_y + rel.y,
             knob.location.x, knob.location.y))


buka_daun("SR_Pintu_Kiri", "SR_Pintu_KnobKiri", -1.965, -1)
buka_daun("SR_Pintu_Kanan", "SR_Pintu_KnobKanan", 1.965, +1)

# hapus garis tengah emas (sambungan daun tertutup)
garis = bpy.data.objects.get("SR_Pintu_GarisTengah")
if garis is not None:
    bpy.data.objects.remove(garis, do_unlink=True)
    print("HAPUS SR_Pintu_GarisTengah")

bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=BLEND)
print("BLEND disimpan:", BLEND)

bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format="GLB",
                          export_apply=True, export_yup=True)
print("GLB diekspor:", OUT_GLB, os.path.getsize(OUT_GLB), "byte")
print("SELESAI PERBAIKAN PINTU SURAU")
