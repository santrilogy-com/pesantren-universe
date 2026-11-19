#!/usr/bin/env python3
"""Bangun POHON v2 (2 varian) dari lembar konsep lingkungan-01 (DI-ACC Mas).
Varian A rindang ±8,5 m (tajuk 3 gumpalan, bukan lollipop v1) dan
Varian B hias ±3,5 m. Ringan untuk pemakaian massal.
Jalankan headless: blender --background --python build_pohon.py"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *  # noqa

BLEND = os.path.dirname(os.path.abspath(__file__))


def cabang(name, loc, rot, length, r0, r1, mat, coll):
    """Cabang meruncing (lathe sepanjang Z lalu diputar)."""
    prof = [(r0, 0.0), (r0 * 0.85, length * 0.5), (r1, length)]
    o = lathe(name, prof, 10, mat, coll, loc=loc)
    o.rotation_euler = rot
    return o


def build_rindang(coll, M):
    # Batang jati meruncing 0 -> 6 m (ujung masuk ke dalam tajuk)
    lathe("Batang", [(0.30, 0.0), (0.27, 1.0), (0.23, 3.0),
                     (0.19, 5.0), (0.13, 6.0)], 12, M["jati"], coll)
    # TIDAK ADA cabang: cabang lama menembus keluar tajuk dan menjuntai
    # di udara sebagai tongkat coklat (cacat tembus, pelajaran @jipraks).
    # Batang sudah masuk ke tajuk; cabang di dalam tajuk tidak terlihat.
    # Tajuk 3 gumpalan tumpang tindih (lebar total ±5,7 m, puncak ±8,4 m)
    sphere("Tajuk_Utama", (0, 0, 6.4), 2.3, M["zamrud"], coll,
           seg=16, rings=10, scale=(1, 1, 0.88))
    sphere("Tajuk_Kiri", (-1.45, 0.3, 5.8), 1.45, M["daun"], coll,
           seg=16, rings=10, scale=(1, 1, 0.9))
    sphere("Tajuk_Kanan", (1.5, -0.25, 5.9), 1.5, M["daun"], coll,
           seg=16, rings=10, scale=(1, 1, 0.9))
    sphere("DaunMuda_A", (-0.8, 0.8, 7.5), 0.85, M["daun_muda"], coll,
           seg=14, rings=9, scale=(1, 1, 0.9))
    sphere("DaunMuda_B", (1.1, -0.9, 7.2), 0.75, M["daun_muda"], coll,
           seg=14, rings=9, scale=(1, 1, 0.9))


def build_hias(coll, M):
    # Batang jati meruncing 0 -> 1,8 m
    lathe("Batang", [(0.16, 0.0), (0.14, 0.9), (0.11, 1.8)], 10,
          M["jati"], coll)
    # Tajuk bundar Ø 2,4 m, puncak ±3,6 m
    sphere("Tajuk", (0, 0, 2.55), 1.2, M["zamrud"], coll,
           seg=16, rings=10, scale=(1, 1, 0.92))
    sphere("DaunMuda", (0.45, 0.4, 2.9), 0.55, M["daun_muda"], coll,
           seg=14, rings=9, scale=(1, 1, 0.9))


# --- Varian A: rindang ---
coll = new_scene("Pohon_Rindang")
M = mats()
build_rindang(coll, M)
stats_and_save(os.path.join(BLEND, "pohon-rindang.blend"),
               os.path.join(BLEND, "pohon-rindang.glb"))

# --- Varian B: hias ---
coll = new_scene("Pohon_Hias")
M = mats()
build_hias(coll, M)
stats_and_save(os.path.join(BLEND, "pohon-hias.blend"),
               os.path.join(BLEND, "pohon-hias.glb"))
