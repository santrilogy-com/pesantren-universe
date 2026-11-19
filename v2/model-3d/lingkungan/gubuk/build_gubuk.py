#!/usr/bin/env python3
"""Bangun GUBUK SANTRI v2 (rumah panggung) dari lembar konsep lingkungan-05
(DI-ACC Mas). 4 x 3 m, kolong 1,2 m, dinding 2,2 m, atap pelana zamrud tua
+ lis emas, total +-4,5 m. Tangga 5 anak tangga, beranda 1 m, 2 tikar + rak.
Jalankan headless: blender --background --python build_gubuk.py"""
import os
import sys
import math

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from common import *  # noqa

BLEND = os.path.dirname(os.path.abspath(__file__))
Z_LANTAI = 1.32   # permukaan lantai (kolong 1,2 m + pelat 0,12)
Z_ATAS_DINDING = 3.52
Z_BUBUNGAN = 4.5


def build_gubuk(coll, M):
    # --- 6 tiang jati (0,18, sedikit menonjol dari dinding) ---
    for px in (-1.92, 0.0, 1.92):
        for py in (-1.42, 1.42):
            box("Tiang", (px, py, 1.7), (0.18, 0.18, 3.4), M["jati"], coll)

    # --- silang kolong (diagonal, depan/belakang + samping) ---
    for py in (-1.42, 1.42):
        for cx in (-0.925, 0.925):
            o = box("Silang_Kolong", (cx, py, 0.6), (2.2, 0.06, 0.10),
                    M["jati_tua"], coll)
            o.rotation_euler = (0, math.radians(33 if cx < 0 else -33), 0)
    for px in (-1.92, 1.92):
        o = box("Silang_Samping", (px, 0, 0.6), (0.06, 2.95, 0.10),
                M["jati_tua"], coll)
        o.rotation_euler = (math.radians(24), 0, 0)

    # --- lantai + lis tepi ---
    box("Lantai", (0, 0, 1.26), (4.0, 3.0, 0.12), M["jati"], coll)
    box("Lis_Lantai_Depan", (0, 1.44, 1.26), (4.0, 0.06, 0.14),
        M["jati_tua"], coll)
    box("Lis_Lantai_Belakang", (0, -1.44, 1.26), (4.0, 0.06, 0.14),
        M["jati_tua"], coll)

    # --- dinding belakang + samping (padat) ---
    box("Dinding_Belakang", (0, -1.35, 2.42), (4.0, 0.12, 2.2),
        M["jati"], coll)
    box("Dinding_Kiri", (-1.925, 0, 2.42), (0.12, 2.58, 2.2),
        M["jati"], coll)
    box("Dinding_Kanan", (1.925, 0, 2.42), (0.12, 2.58, 2.2),
        M["jati"], coll)

    # --- dinding depan: pintu kanan (x 0,45..1,35), jendela kiri ---
    box("Depan_Kiri", (-1.65, 1.35, 2.42), (0.7, 0.12, 2.2), M["jati"], coll)
    box("Bawah_Jendela", (-0.9, 1.35, 1.67), (0.8, 0.12, 0.7),
        M["jati"], coll)
    box("Atas_Jendela", (-0.9, 1.35, 3.17), (0.8, 0.12, 0.7),
        M["jati"], coll)
    box("Depan_Tengah", (-0.025, 1.35, 2.42), (0.95, 0.12, 2.2),
        M["jati"], coll)
    box("Atas_Pintu", (0.9, 1.35, 3.32), (0.9, 0.12, 0.4), M["jati"], coll)
    box("Depan_Kanan", (1.675, 1.35, 2.42), (0.65, 0.12, 2.2),
        M["jati"], coll)

    # --- pintu jati tua + gagang emas ---
    box("Pintu", (0.9, 1.32, 2.22), (0.86, 0.06, 1.76), M["jati_tua"], coll)
    sphere("Gagang_Pintu", (0.58, 1.28, 2.22), 0.035, M["emas"], coll,
           seg=10, rings=7)

    # --- jendela: kaca krem + kisi silang ---
    box("Kaca_Jendela", (-0.9, 1.35, 2.42), (0.76, 0.02, 0.76),
        M["krem_muda"], coll)
    box("Kisi_V", (-0.9, 1.38, 2.42), (0.04, 0.04, 0.8), M["jati_tua"], coll)
    box("Kisi_H", (-0.9, 1.38, 2.42), (0.8, 0.04, 0.04), M["jati_tua"], coll)

    # --- segitiga atap pelana (gable) depan + belakang ---
    gable = [(-2.0, Z_ATAS_DINDING), (2.0, Z_ATAS_DINDING), (0, Z_BUBUNGAN)]
    prism("Gable_Belakang", gable, 0.12, M["jati"], coll, loc=(0, -1.41, 0))
    prism("Gable_Depan", gable, 0.12, M["jati"], coll, loc=(0, 1.29, 0))

    # --- 2 bidang atap pelana zamrud tua (miring 23 derajat) ---
    sudut = math.radians(23)
    kanan = box("Atap_Kanan", (1.15, 0, 4.01), (2.5, 3.6, 0.08),
                M["zamrud_tua"], coll)
    kanan.rotation_euler = (0, sudut, 0)
    kiri = box("Atap_Kiri", (-1.15, 0, 4.01), (2.5, 3.6, 0.08),
               M["zamrud_tua"], coll)
    kiri.rotation_euler = (0, -sudut, 0)
    # lis emas bubungan + finial emas ujung depan
    box("Lis_Bubungan", (0, 0, 4.53), (0.1, 3.64, 0.06), M["emas"], coll)
    cone("Finial_Depan", (0, 1.82, 4.62), 0.09, 0.18, M["emas"], coll, verts=4)

    # --- beranda 1 m di depan pintu + 2 tiang penyangga ---
    box("Beranda", (0.9, 1.91, 1.27), (1.2, 1.0, 0.1), M["jati"], coll)
    box("Tiang_Beranda_Kiri", (0.4, 2.36, 0.61), (0.1, 0.1, 1.22),
        M["jati"], coll)
    box("Tiang_Beranda_Kanan", (1.4, 2.36, 0.61), (0.1, 0.1, 1.22),
        M["jati"], coll)

    # --- tangga 5 anak tangga (tread melayang + 2 stringer miring) ---
    for i in range(5):
        box("Anak_Tangga", (0.9, 2.55 + i * 0.28, 1.10 - i * 0.22),
            (1.2, 0.3, 0.08), M["jati"], coll)
    for sx in (0.35, 1.45):
        o = box("Stringer", (sx, 3.11, 0.66), (0.06, 1.42, 0.14),
                M["jati_tua"], coll)
        o.rotation_euler = (math.radians(-38.2), 0, 0)

    # --- isi: 2 tikar + rak kecil dengan kitab ---
    box("Tikar_A", (-1.3, -0.65, 1.35), (1.2, 1.2, 0.03), M["tikar"], coll)
    box("Tikar_B", (-1.3, 0.65, 1.35), (1.2, 1.2, 0.03), M["tikar"], coll)
    box("Rak_Sisi_A", (1.7, -0.95, 1.85), (0.35, 0.05, 1.0),
        M["jati_tua"], coll)
    box("Rak_Sisi_B", (1.7, -0.25, 1.85), (0.35, 0.05, 1.0),
        M["jati_tua"], coll)
    box("Rak_Papan_Bawah", (1.7, -0.6, 1.55), (0.35, 0.75, 0.04),
        M["jati"], coll)
    box("Rak_Papan_Atas", (1.7, -0.6, 1.95), (0.35, 0.75, 0.04),
        M["jati"], coll)
    warna_kitab = ["bunga_merah", "bunga_kuning", "daun", "bunga_ungu"]
    for i, wk in enumerate(warna_kitab):
        box("Kitab_Rak", (1.7, -0.88 + i * 0.14, 1.72),
            (0.25, 0.11, 0.28), M[wk], coll)

    # --- kayu bakar di kolong ---
    for j, (ly, lz) in enumerate([(-0.8, 0.09), (-0.62, 0.09),
                                  (-0.98, 0.09), (-0.71, 0.26),
                                  (-0.89, 0.26)]):
        cyl(f"Kayu_Bakar_{j}", (0.8, ly, lz), 0.09, 0.8, M["jati_tua"],
            coll, verts=10, rot=(0, math.pi / 2, 0))


coll = new_scene("Gubuk_Santri")
M = mats()
build_gubuk(coll, M)
stats_and_save(os.path.join(BLEND, "gubuk-santri.blend"),
               os.path.join(BLEND, "gubuk-santri.glb"))
