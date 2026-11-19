#!/usr/bin/env python3
"""Bangun TAMAN v2 (8 x 6 m) dari lembar konsep lingkungan-02 (DI-ACC Mas).
Rumput, jalan batu melengkung, 4 bedeng bunga (4 warna), 2 bangku jati,
1 pohon hias + 3 semak.
Jalankan headless: blender --background --python build_taman.py"""
import os
import sys
import math
import random

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *  # noqa

BLEND = os.path.dirname(os.path.abspath(__file__))


def pohon_hias_at(coll, M, cx, cy):
    lathe("Batang_Pohon", [(0.16, 0.0), (0.14, 0.9), (0.11, 1.8)], 10,
          M["jati"], coll, loc=(cx, cy, 0))
    sphere("Tajuk_Pohon", (cx, cy, 2.55), 1.2, M["zamrud"], coll,
           seg=16, rings=10, scale=(1, 1, 0.92))
    sphere("DaunMuda_Pohon", (cx + 0.45, cy + 0.4, 2.9), 0.55,
           M["daun_muda"], coll, seg=14, rings=9, scale=(1, 1, 0.9))


def bangku(coll, M, cx, cy, rot_z):
    """Bangku jati 1,8 m, menghadap arah -Y lokal; diputar rot_z."""
    def R(lx, ly):
        c, s = math.cos(rot_z), math.sin(rot_z)
        return (cx + lx * c - ly * s, cy + lx * s + ly * c)
    # dudukan
    x, y = R(0, 0)
    o = box("Bangku_Duduk", (x, y, 0.45), (1.8, 0.5, 0.08), M["jati"], coll)
    o.rotation_euler = (0, 0, rot_z)
    # 2 bilah sandaran (di sisi +Y lokal = belakang)
    for lz in (0.75, 0.95):
        x, y = R(0, -0.24)
        o = box("Bangku_Sandaran", (x, y, lz), (1.8, 0.06, 0.12),
                M["jati"], coll)
        o.rotation_euler = (0, 0, rot_z)
    # 2 kaki
    for lx in (-0.8, 0.8):
        x, y = R(lx, 0)
        o = box("Bangku_Kaki", (x, y, 0.225), (0.06, 0.5, 0.45),
                M["jati"], coll)
        o.rotation_euler = (0, 0, rot_z)


def build_taman(coll, M):
    rnd = random.Random(17)
    # --- rumput 8 x 6 ---
    box("Rumput", (0, 0, 0.05), (8.0, 6.0, 0.1), M["rumput"], coll)
    # --- jalan batu melengkung (selatan -> utara) ---
    for i, (py, px, rz) in enumerate([
            (-2.6, -0.2, 0.08), (-1.7, 0.2, -0.06), (-0.8, 0.45, 0.05),
            (0.1, 0.3, -0.05), (1.0, -0.1, 0.06), (1.9, -0.3, -0.04),
            (2.7, 0.0, 0.0)]):
        o = box(f"Jalan_Batu_{i}", (px, py, 0.12), (0.8, 1.05, 0.04),
                M["batu"], coll)
        o.rotation_euler = (0, 0, rz)
    # --- 4 bedeng bunga (satu warna per bedeng) ---
    warna_bedeng = ["bunga_merah", "bunga_kuning", "bunga_ungu", "bunga_oranye"]
    for bi, (bx, by) in enumerate([(-2.6, 2.2), (2.6, 2.2),
                                   (-2.6, -2.2), (2.6, -2.2)]):
        box(f"Bedeng_{bi}", (bx, by, 0.125), (2.4, 1.2, 0.25),
            M["tanah"], coll)
        # pagar jati rendah keliling bedeng
        box(f"Bedeng_Pagar_N_{bi}", (bx, by + 0.57, 0.2), (2.4, 0.06, 0.18),
            M["jati"], coll)
        box(f"Bedeng_Pagar_S_{bi}", (bx, by - 0.57, 0.2), (2.4, 0.06, 0.18),
            M["jati"], coll)
        box(f"Bedeng_Pagar_E_{bi}", (bx + 1.17, by, 0.2), (0.06, 1.2, 0.18),
            M["jati"], coll)
        box(f"Bedeng_Pagar_W_{bi}", (bx - 1.17, by, 0.2), (0.06, 1.2, 0.18),
            M["jati"], coll)
        # 8 bunga per bedeng (2 baris x 4 kolom, jitter)
        wk = warna_bedeng[bi]
        for r in range(2):
            for c in range(4):
                fx = bx - 0.8 + c * 0.53 + rnd.uniform(-0.12, 0.12)
                fy = by - 0.28 + r * 0.56 + rnd.uniform(-0.1, 0.1)
                cyl(f"Bunga_Batang_{bi}_{r}_{c}", (fx, fy, 0.35), 0.015,
                    0.22, M["daun"], coll, verts=6)
                ico(f"Bunga_{bi}_{r}_{c}", (fx, fy, 0.5), 0.075, M[wk],
                    coll, subdiv=0, scale=(1, 1, 0.8))
    # --- 2 bangku jati ---
    bangku(coll, M, 0, 2.55, 0.0)                    # utara, menghadap selatan
    bangku(coll, M, 3.45, -0.2, math.radians(90))     # timur, menghadap barat
    # --- 1 pohon hias + 3 semak ---
    pohon_hias_at(coll, M, -2.2, 0.6)
    for i, (sx, sy, sr) in enumerate([(2.5, 1.2, 0.5), (1.8, -1.8, 0.42),
                                      (-2.8, -0.8, 0.45)]):
        sphere(f"Semak_{i}", (sx, sy, sr * 0.55), sr, M["daun"], coll,
               seg=12, rings=8, scale=(1, 1, 0.6))


coll = new_scene("Taman")
M = mats()
build_taman(coll, M)
stats_and_save(os.path.join(BLEND, "taman.blend"),
               os.path.join(BLEND, "taman.glb"))
