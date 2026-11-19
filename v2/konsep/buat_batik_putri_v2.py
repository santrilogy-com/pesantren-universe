#!/usr/bin/env python3
"""Tekstur batik sarung putri v2 — Kirana, 19 Nov 2026.
Revisi dari v1 (koreksi Mas 19 Nov 15:38): palet COKLAT, bukan indigo.
Motif parang (pita diagonal mengalir) + isen-isen + mlinion, mengikuti
matematika _motif_sarung() di player.gd (periodik supaya menyambung
mulus saat melingkari tabung sarung).

Kunci kompresi (permintaan Mas: detail kelihatan, file kecil):
- Palet SENGAJA terbatas: 5 warna saja (coklat tua, coklat sedang, krem,
  coklat gelap, emas) -> PNG palet (mode P) jauh lebih kecil dari RGB
  pada pola garis/detail seperti batik.
- Ukuran 512x256 (2:1, sama rasionya dengan tekstur sarung game 256x128,
  4x piksel untuk detail) + periode 64 px (512/64=8, 256/64=4).

Output: v2/konsep/tekstur-batik-putri-v2.png (palet) + perbandingan RGB.
"""
import math, os
from PIL import Image

OUT = os.path.expanduser("~/workspace/pesantren-verse/v2/konsep")
W, H = 512, 256
PERIODE = 64.0

INDIGO = (74, 44, 23)        # #4A2C17 dasar coklat tua (batik sogan)
TERANG = (122, 78, 45)       # #7A4E2D pita terang (coklat sedang)
KREM = (242, 234, 214)       # #F2EAD6 garis halus + isen
GELAP = (42, 26, 14)         # #2A1A0E garis tepi pita (isen-isen)
EMAS = (201, 162, 39)        # #C9A227 mlinion (titik emas)

# Tabel sinus untuk kecepatan. Frekuensi k = 2*pi/64 supaya pola BENAR-BENAR
# periodik 64 px: sin((x-y)*k) berulang tiap 64 px di (x-y), dan 64 membagi
# habis 512 maupun 256 -> tekstur menyambung mulus tanpa jahitan saat
# melingkari tabung sarung. (0.08 seperti di _motif_sarung lama tidak
# membagi 2*pi, jadi ada jog kecil di garis sambung.)
K = 2 * math.pi / 64.0
SIN = [math.sin(i * K) for i in range(-(W + H), W + H + 1)]
OFF = W + H

img = Image.new("RGB", (W, H))
px = img.load()
for y in range(H):
    for x in range(W):
        d = (x + y + 6.0 * SIN[x - y + OFF]) % PERIODE
        fase = d / PERIODE
        if fase < 0.5:
            c = INDIGO
        else:
            c = TERANG
            # Garis halus sejajar pita di dalam pita terang (detail batik).
            if ((x + y) % 8) < 1:
                c = KREM
            # Titik emas (mlinion) di tengah pita terang, grid 16 px.
            gx = x % 16
            gy = (y + (8 if (x // 16) % 2 == 1 else 0)) % 16
            dx, dy = gx - 8, gy - 8
            if dx * dx + dy * dy < 5.0:
                c = EMAS
        # Garis tepi tipis di batas pita (isen-isen parang).
        jarak_tepi = min(abs(fase - 0.5), min(fase, 1.0 - fase))
        if jarak_tepi < 0.045:
            c = GELAP
        px[x, y] = c

# --- Simpan: palet (deliverable) + RGB (pembanding) ---
pal = img.convert("P", palette=Image.ADAPTIVE, colors=16)
p_pal = f"{OUT}/tekstur-batik-putri-v2.png"
pal.save(p_pal, optimize=True, compress_level=9)
p_rgb = f"{OUT}/tekstur-batik-putri-v2-rgb.png"
img.save(p_rgb, optimize=True, compress_level=9)
# Pratinjau 2x2 ubin (cek jahitan sambungan).
ubin = Image.new("RGB", (W * 2, H * 2))
for yy in (0, 1):
    for xx in (0, 1):
        ubin.paste(img, (xx * W, yy * H))
ubin.save(f"{OUT}/tekstur-batik-putri-v2-ubin2x2.png", optimize=True, compress_level=9)
print("palet :", p_pal, os.path.getsize(p_pal), "byte")
print("rgb   :", p_rgb, os.path.getsize(p_rgb), "byte")
print("warna palet:", sorted(set(pal.convert('RGB').getdata())))
