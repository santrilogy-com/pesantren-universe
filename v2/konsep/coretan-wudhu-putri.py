# -*- coding: utf-8 -*-
"""
Coretan USULAN Wudhu Putri di atas salinan masterplan v2 (Gilang, Tim Maps, 18 Nov 2026).
- TIDAK menimpa peta yang sudah DI-ACC: baca peta-tata-letak-v2-masterplan.png,
  tulis peta-tata-letak-v2-masterplan_wudhu-putri-usulan.png.
- Transformasi koordinat SAMA dengan buat_masterplan.py (X_MIN -70, Z_MIN -84, S 8.6).
- Usulan utama: (122,-24), tapak 8x6 (x 118..126, z -27..-21), barat Musholla.
- Alternatif: (134,-35), tapak 8x6 (x 130..138, z -38..-32), utara Musholla.
"""
from PIL import Image, ImageDraw, ImageFont

X_MIN, Z_MIN, S, ML, MT = -70.0, -84.0, 8.6, 60, 110
ZAMRUD = (6, 95, 70)
EMAS = (201, 162, 39)
PUTIH = (255, 253, 245)
TINTA = (31, 61, 43)

def X(x): return ML + (x - X_MIN) * S
def Z(z): return MT + (z - Z_MIN) * S

FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
def f(sz, bold=True):
    return ImageFont.truetype(FONT_B if bold else FONT, sz)

img = Image.open("peta-tata-letak-v2-masterplan.png").convert("RGB")
d = ImageDraw.Draw(img)
W, H = img.size

def rect(x0, z0, x1, z1, outline, width, fill=None):
    d.rectangle([X(x0), Z(z0), X(x1), Z(z1)], outline=outline, width=width, fill=fill)

def dashed_rect(x0, z0, x1, z1, color, width=3, dash=10):
    # garis putus-putus manual (PIL tidak punya dash)
    x0p, z0p, x1p, z1p = X(x0), Z(z0), X(x1), Z(z1)
    def hline(y, a, b):
        x = a
        while x < b:
            d.line([(x, y), (min(x + dash, b), y)], fill=color, width=width)
            x += dash * 2
    def vline(x, a, b):
        y = a
        while y < b:
            d.line([(x, y), (x, min(y + dash, b))], fill=color, width=width)
            y += dash * 2
    hline(z0p, x0p, x1p); hline(z1p, x0p, x1p)
    vline(x0p, z0p, z1p); vline(x1p, z0p, z1p)

def text_c(cx, cy, s, size, color=TINTA, bold=True):
    ft = f(size, bold)
    bb = d.textbbox((0, 0), s, font=ft)
    w, h = bb[2] - bb[0], bb[3] - bb[1]
    d.text((cx - w / 2 - bb[0], cy - h / 2 - bb[1]), s, font=ft, fill=color,
           stroke_width=4, stroke_fill=PUTIH)

# --- Usulan utama: barat Musholla, (122,-24), 8x6 ---
# Label DI DALAM kotak (label di luar bertabrakan dengan label Musholla)
rect(118, -27, 126, -21, ZAMRUD, 4, fill=(215, 232, 222))
text_c(X(122), Z(-25.6), "WUDHU", 14)
text_c(X(122), Z(-23.9), "PUTRI", 14)
text_c(X(122), Z(-22.4), "(utama)", 11, bold=False)

# --- Alternatif: utara Musholla, (134,-35), 8x6 ---
dashed_rect(130, -38, 138, -32, EMAS, 3)
text_c(X(134), Z(-36.6), "WUDHU", 13)
text_c(X(134), Z(-34.9), "PUTRI", 13)
text_c(X(134), Z(-33.4), "(alternatif)", 10, bold=False)

# --- Keterangan bawah (di antara legenda dan footer resmi) ---
text_c(W / 2, H - 62,
       "Coretan usulan 18 Nov 2026 — Wudhu Putri utama (122,-24) barat Musholla; alternatif (134,-35) utara Musholla. BUKAN masterplan resmi — menunggu keputusan Mas.",
       15, color=TINTA, bold=False)

img.save("peta-tata-letak-v2-masterplan_wudhu-putri-usulan.png")
print("tersimpan: peta-tata-letak-v2-masterplan_wudhu-putri-usulan.png", img.size)
