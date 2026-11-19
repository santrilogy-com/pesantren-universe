#!/usr/bin/env python3
"""Normalisasi tekstur P5 Pesantren Universe (Bima, 18 Nov 2026).

Masalah: texture Poly Haven mentah warnanya gelap/ber-cast (plester
rata-rata RGB 0.56/0.53/0.48, batu blok 0.24/0.18/0.12). Godot mengalikan
albedo_texture x albedo_color, jadi tekstur mentah x tinta krem
(#F2EAD6) = cokelat gelap -- palet rusak. Pelajaran yang sama dari
jilbab rebuild Kirana 18 Nov: tekstur jersey x krem = cokelat.

Solusi: remap affine per channel -- geser rata-rata tiap channel ke
0.90 (netral, tanpa cast warna) sambil mempertahankan kontras lokal
(gain <= 1.0, dibatasi supaya p1/p99 tidak terpotong). Hasilnya
tekstur x tinta palet ~= 0.90 x tinta -- warna palet tetap terbaca,
permukaan dapat detail.

File asli (MD5 terverifikasi sama dengan Poly Haven) dicatat di
v2/godot-dunia/models/README-TEKSTUR-P5.md; file di repo ini adalah
versi yang sudah dinormalisasi.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image

TARGET = 0.90
MODELS = Path(__file__).resolve().parent.parent / "godot-dunia" / "models"

FILES = [
    "dinding_white_plaster_02_1k.jpg",
    "pondasi_stone_block_wall_1k.jpg",
    "lantai_stone_floor_1k.jpg",
]

for name in FILES:
    p = MODELS / name
    a = np.asarray(Image.open(p).convert("RGB"), dtype=np.float32) / 255.0
    out = np.empty_like(a)
    for c in range(3):
        ch = a[:, :, c]
        mean = float(ch.mean())
        p1 = float(np.percentile(ch, 1))
        p99 = float(np.percentile(ch, 99))
        gain = 1.0
        if p99 > mean:
            gain = min(gain, (0.99 - TARGET) / (p99 - mean))
        if mean > p1:
            gain = min(gain, TARGET / (mean - p1))
        out[:, :, c] = np.clip((ch - mean) * gain + TARGET, 0.0, 1.0)
        print(f"{name} ch{c}: mean {mean:.3f} p1 {p1:.3f} p99 {p99:.3f} gain {gain:.3f} -> mean baru {float(out[:, :, c].mean()):.3f}")
    Image.fromarray((out * 255.0).round().astype(np.uint8)).save(p, quality=92)
    print(f"{name}: tersimpan, {p.stat().st_size} byte")
print("SELESAI")
