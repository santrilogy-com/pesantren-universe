# -*- coding: utf-8 -*-
"""
ATLAS READER — crop peta masterplan v2 jadi halaman atlas buku (Gilang, Tim Maps)
Sumber: v2/konsep/peta-tata-letak-v2-masterplan.png (masterplan) + peta-tata-letak-v2.png
Tujuan: v2/godot-dunia/data/atlas/ (dibaca reader buku, entri atlas-pesantren-verse)
Kotak crop dalam METER (bukan piksel) supaya tahan bila kanvas/skala peta berubah.
Kotak 3 zona lama dipulihkan persis dari crop 17 Nov (template-match diff 0.00):
  area-putra x -77..23, z -67.7..30 | penyangga x 12.6..120.7, z -66.5..6.7
  kawasan-bersama x -53.7..120.7, z -1.4..82.3
Kotak kampus-putri BARU 18 Nov (tembok baru x 115..216, z -70..+40):
  x 100..222, z -76..44 (margin 6-15 m dari tembok; gunung di utara tidak ikut).
Jalankan: python3 buat_atlas.py
"""
from PIL import Image
import shutil

KONSEP = "/home/hatch/workspace/pesantren-verse/v2/konsep"
ATLAS = "/home/hatch/workspace/pesantren-verse/v2/godot-dunia/data/atlas"

# geometri peta BARU (sama di buat_masterplan.py / buat_peta.py, 18 Nov 2026)
S, ML, MT, X_MIN, Z_MIN = 8.6, 60, 110, -70.0, -84.0

def X(x): return int(round(ML + (x - X_MIN) * S))
def Z(z): return int(round(MT + (z - Z_MIN) * S))

def crop_meter(src, x0, z0, x1, z1, dst):
    im = Image.open(src)
    box = (X(x0), Z(z0), X(x1), Z(z1))
    im.crop(box).save(dst)
    print(f"{dst.split('/')[-1]}: meter x {x0}..{x1}, z {z0}..{z1} -> px {box} "
          f"({box[2]-box[0]}x{box[3]-box[1]})")

MASTER = f"{KONSEP}/peta-tata-letak-v2-masterplan.png"
# 1-2. peta utuh (halaman 1 + 6 reader)
shutil.copy(MASTER, f"{ATLAS}/masterplan-v2.png")
shutil.copy(f"{KONSEP}/peta-tata-letak-v2.png", f"{ATLAS}/konsep-v2.png")
print("masterplan-v2.png + konsep-v2.png: disalin utuh")
# 3-5. crop zona (halaman 2, 3, 5 — kotak sama seperti 17 Nov)
crop_meter(MASTER, -77.0, -67.7, 23.0, 30.0, f"{ATLAS}/atlas-area-putra.png")
crop_meter(MASTER, 12.6, -66.5, 120.7, 6.7, f"{ATLAS}/atlas-zona-penyangga.png")
crop_meter(MASTER, -53.7, -1.4, 120.7, 82.3, f"{ATLAS}/atlas-kawasan-bersama.png")
# 6. crop kampus putri (halaman 4 — kotak BARU 18 Nov)
crop_meter(MASTER, 100, -76, 222, 44, f"{ATLAS}/atlas-kampus-putri.png")
print("selesai — 6 halaman atlas diperbarui dari masterplan baru")
