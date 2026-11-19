#!/usr/bin/env python3
"""Bangun PAGAR v2 (2 varian) dari lembar konsep lingkungan-04 (DI-ACC Mas).
Varian A bambu 1,5 m (bilah 9 cm, tiang jati tiap 2 m) dan
Varian B bata rendah 0,9 m krem + lis emas (pilar tiap 2 m).
Keduanya modul lurus segmen 4 m (sumbu X, tanah z=0) yang bisa diulang.
Jalankan headless: blender --background --python build_pagar.py"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *  # noqa

BLEND = os.path.dirname(os.path.abspath(__file__))


def build_bambu(coll, M):
    # Bilah bambu 9 cm, jarak 18 cm (pitch 0,27 m) -> 15 bilah per 4 m
    bilah = []
    x = -1.865
    while x <= 1.87:
        bilah.append(box("Bilah", (x, 0, 0.75), (0.09, 0.03, 1.5),
                         M["bambu"], coll))  # tanpa bevel: bilah 3 cm,
        # bevel menambah ~90 tris/bilah dan tak terlihat dari jarak main
        x += 0.27
    join_objects(bilah, "Bilah_Bambu")
    # 2 rel jati (depan bilah)
    rel = [
        box("Rel_Bawah", (0, 0.035, 0.45), (4.0, 0.05, 0.07), M["jati"], coll),
        box("Rel_Atas", (0, 0.035, 1.05), (4.0, 0.05, 0.07), M["jati"], coll),
    ]
    # Tiang jati tiap 2 m + ujung runcing
    tiang = []
    for tx in (-2.0, 0.0, 2.0):
        tiang.append(box("Tiang", (tx, 0, 0.8), (0.12, 0.12, 1.6),
                         M["jati"], coll))
        tiang.append(cone("Ujung_Tiang", (tx, 0, 1.68), 0.085, 0.16,
                          M["jati"], coll, verts=4))
    join_objects(rel + tiang, "Rel_Tiang_Jati")


def build_bata(coll, M):
    # Dinding bata krem 4 x 0,15 x 0,9 + plinth batu
    box("Dinding_Bata", (0, 0, 0.45), (4.0, 0.15, 0.9), M["krem"], coll)
    box("Plinth", (0, 0, 0.06), (4.0, 0.17, 0.12), M["batu"], coll)
    # Lis emas di atas dinding
    box("Lis_Emas", (0, 0, 0.925), (4.02, 0.17, 0.05), M["emas"], coll)
    # Pilar krem tiap 2 m + tutup emas (piramida)
    for px in (-2.0, 0.0, 2.0):
        box("Pilar", (px, 0, 0.525), (0.3, 0.3, 1.05), M["krem"], coll)
        cone("Tutup_Pilar", (px, 0, 1.13), 0.21, 0.16,
             M["emas"], coll, verts=4)


# --- Varian A: bambu ---
coll = new_scene("Pagar_Bambu")
M = mats()
build_bambu(coll, M)
stats_and_save(os.path.join(BLEND, "pagar-bambu.blend"),
               os.path.join(BLEND, "pagar-bambu.glb"))

# --- Varian B: bata rendah ---
coll = new_scene("Pagar_Bata")
M = mats()
build_bata(coll, M)
stats_and_save(os.path.join(BLEND, "pagar-bata.blend"),
               os.path.join(BLEND, "pagar-bata.glb"))
