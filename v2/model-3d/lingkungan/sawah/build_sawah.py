#!/usr/bin/env python3
"""Bangun SAWAH v2 (20 x 12 m) dari lembar konsep lingkungan-03 (DI-ACC Mas).
4 petak @ 9,1 x 5,3 m, pematang tanah 60 cm (bisa jalan), saluran air utara,
air 15 cm, padi hijau muda berbaris rapi (jarak +-0,5 m antar rumpun).
Padi = segitiga tipis 3 bilah per rumpun (1 mesh per warna, hemat tris).
Jalankan headless: blender --background --python build_sawah.py"""
import os
import sys
import math
import random

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *  # noqa

BLEND = os.path.dirname(os.path.abspath(__file__))

PETAK_W, PETAK_H = 9.1, 5.3   # pematang 0,6 m -> total 20 x 12 m
PETAK_CX = [-(0.3 + PETAK_W / 2), 0.3 + PETAK_W / 2]
PETAK_CY = [-(0.3 + PETAK_H / 2), 0.3 + PETAK_H / 2]


def tuft_mesh(name, positions, mat, coll):
    """Satu mesh berisi banyak rumpun padi; tiap rumpun = 3 bilah segitiga."""
    verts, faces = [], []
    for (bx, by, tilt) in positions:
        h = 0.45 + 0.1 * ((hash((round(bx, 2), round(by, 2))) % 10) / 10.0)
        for k in range(3):
            a = tilt + k * (2 * math.pi / 3)
            dx, dy = math.cos(a), math.sin(a)
            base = len(verts)
            verts.append((bx - dy * 0.07, by + dx * 0.07, 0.15))
            verts.append((bx + dy * 0.07, by - dx * 0.07, 0.15))
            verts.append((bx + dx * 0.12, by + dy * 0.12, 0.15 + h))
            faces.append((base, base + 1, base + 2))
    me = bpy.data.meshes.new(name + "_mesh")
    me.from_pydata(verts, [], faces)
    me.update()
    o = bpy.data.objects.new(name, me)
    me.materials.append(mat)
    link(o, coll)
    return o


def build_sawah(coll, M):
    rnd = random.Random(23)
    # --- dasar lumpur 20 x 12 ---
    box("Lumpur", (0, 0, -0.1), (20.0, 12.0, 0.2), M["lumpur"], coll)
    # --- pematang 0,6 m, tinggi 0,4 m (puncak z=0,4) ---
    box("Pematang_Utara", (0, 5.7, 0.2), (20.0, 0.6, 0.4), M["tanah"], coll)
    box("Pematang_Selatan", (0, -5.7, 0.2), (20.0, 0.6, 0.4), M["tanah"], coll)
    box("Pematang_Tengah", (0, 0, 0.2), (20.0, 0.6, 0.4), M["tanah"], coll)
    # Pematang vertikal 5 mm LEBIH RENDAH (puncak 0,395) dari horizontal
    # (0,4) — kalau koplanar, persilangannya z-fighting jadi kotak hitam
    # (terlihat di render pertama). Selisih 5 mm tidak terlihat.
    box("Pematang_Barat", (-9.7, 0, 0.195), (0.6, 10.8, 0.4), M["tanah"], coll)
    box("Pematang_Timur", (9.7, 0, 0.195), (0.6, 10.8, 0.4), M["tanah"], coll)
    box("Pematang_Tengah_V", (0, 0, 0.195), (0.6, 10.8, 0.4), M["tanah"], coll)
    # --- saluran air utara (di luar pematang utara) ---
    box("Saluran_Bed", (0, 6.35, 0.0), (20.0, 0.9, 0.3), M["lumpur"], coll)
    box("Saluran_Air", (0, 6.35, 0.28), (20.0, 0.7, 0.06), M["air"], coll)
    # --- air + padi per petak ---
    pos_a, pos_b = [], []
    for cx in PETAK_CX:
        for cy in PETAK_CY:
            box("Air_Petak", (cx, cy, 0.12), (PETAK_W, PETAK_H, 0.06),
                M["air"], coll)
            nx = int(PETAK_W / 0.5)   # 18 kolom
            ny = int(PETAK_H / 0.5)   # 10 baris
            for i in range(nx):
                for j in range(ny):
                    x = cx - PETAK_W / 2 + 0.25 + i * 0.5 + rnd.uniform(-0.06, 0.06)
                    y = cy - PETAK_H / 2 + 0.25 + j * 0.5 + rnd.uniform(-0.06, 0.06)
                    t = rnd.uniform(0, 2 * math.pi)
                    (pos_a if rnd.random() < 0.6 else pos_b).append((x, y, t))
    tuft_mesh("Padi_Hijau", pos_a, M["daun"], coll)
    tuft_mesh("Padi_Muda", pos_b, M["daun_muda"], coll)


coll = new_scene("Sawah")
M = mats()
build_sawah(coll, M)
stats_and_save(os.path.join(BLEND, "sawah.blend"),
               os.path.join(BLEND, "sawah.glb"))
