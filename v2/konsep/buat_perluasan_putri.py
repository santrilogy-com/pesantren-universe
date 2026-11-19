# -*- coding: utf-8 -*-
"""
KONSEP PERLUASAN AREA PUTRI — Pesantren Universe (Mira, Tim Area Putri, 18 Nov 2026)
Dokumentasi visual perluasan yang SUDAH diterapkan di kode (perintah Mas 00:28 WIB).
Gaya + palet SAMA dengan buat_peta.py (Gilang) supaya bisa diselaraskan ke peta v2:
krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A, x+ = timur, z+ = selatan.
Jalankan: python3 buat_perluasan_putri.py -> area-putri-perluasan.png
"""
import math
from PIL import Image, ImageDraw, ImageFont

KREM = (242, 234, 214)
PUTIH = (255, 253, 245)
ZAMRUD = (6, 95, 70)
ZAMRUD_TUA = (4, 66, 48)
EMAS = (201, 162, 39)
EMAS_TUA = (150, 118, 20)
JATI = (123, 75, 42)
JATI_TUA = (90, 52, 26)
TINTA = (31, 61, 43)
JALAN = (231, 220, 192)
JALAN_GARIS = (201, 185, 138)
WASH_PUTRI = (248, 239, 214)
WASH_BARU = (238, 244, 222)   # tint hijau pucat — lahan perluasan
SAWAH = (201, 220, 196)
MERAH = (178, 58, 48)

X_MIN, X_MAX = 105.0, 228.0
Z_MIN, Z_MAX = -80.0, 50.0
S = 12.0
ML, MT = 70, 130
W = int(ML + (X_MAX - X_MIN) * S + 80)
H = int(MT + (Z_MAX - Z_MIN) * S + 270)

def X(x): return ML + (x - X_MIN) * S
def Z(z): return MT + (z - Z_MIN) * S

FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
def f(sz, bold=False):
    return ImageFont.truetype(FONT_B if bold else FONT, sz)

img = Image.new("RGB", (W, H), KREM)
d = ImageDraw.Draw(img)

def text_c(cx, cy, s, size, color=TINTA, bold=True, halo=True):
    ft = f(size, bold)
    bb = d.textbbox((0, 0), s, font=ft)
    w, h = bb[2] - bb[0], bb[3] - bb[1]
    x, y = cx - w / 2 - bb[0], cy - h / 2 - bb[1]
    if halo:
        d.text((x, y), s, font=ft, fill=PUTIH, stroke_width=4, stroke_fill=PUTIH)
    d.text((x, y), s, font=ft, fill=color)

def text_l(x, y, s, size, color=TINTA, bold=False):
    d.text((x, y), s, font=f(size, bold), fill=color)

def rect_m(x0, z0, x1, z1, **kw):
    d.rectangle([X(x0), Z(z0), X(x1), Z(z1)], **kw)

def line_m(x0, z0, x1, z1, **kw):
    d.line([X(x0), Z(z0), X(x1), Z(z1)], **kw)

def dashed_rect(x0, z0, x1, z1, color, width=4, dash=16, gap=11):
    def dash_line(p0, p1):
        x0p, y0p = p0; x1p, y1p = p1
        L = math.hypot(x1p - x0p, y1p - y0p)
        n = max(1, int(L // (dash + gap)))
        for i in range(n + 1):
            t0 = i * (dash + gap) / L
            t1 = min(1.0, t0 + dash / L)
            if t1 <= t0:
                continue
            d.line([(x0p + (x1p - x0p) * t0, y0p + (y1p - y0p) * t0),
                    (x0p + (x1p - x0p) * t1, y0p + (y1p - y0p) * t1)],
                   fill=color, width=width)
    A, B, C, D = (X(x0), Z(z0)), (X(x1), Z(z0)), (X(x1), Z(z1)), (X(x0), Z(z1))
    for p, q in ((A, B), (B, C), (C, D), (D, A)):
        dash_line(p, q)

def building(cx, cz, w, h, label, fill=PUTIH, outline=ZAMRUD, lw=4,
             label_size=24, dome_r=0, label_color=TINTA):
    hw, hh = w / 2, h / 2
    poly = [(X(cx - hw), Z(cz - hh)), (X(cx + hw), Z(cz - hh)),
            (X(cx + hw), Z(cz + hh)), (X(cx - hw), Z(cz + hh))]
    d.polygon(poly, fill=fill, outline=outline, width=lw)
    if dome_r:
        r = dome_r * S
        d.ellipse([X(cx) - r, Z(cz - h * 0.22) - r, X(cx) + r, Z(cz - h * 0.22) + r],
                  fill=ZAMRUD, outline=EMAS_TUA, width=3)
        d.ellipse([X(cx) - r * 0.25, Z(cz - h * 0.22) - r * 1.25,
                   X(cx) + r * 0.25, Z(cz - h * 0.22) - r * 0.75], fill=EMAS)
    lines = label if isinstance(label, list) else [label]
    lh = label_size + 4
    y0 = Z(cz) + (h * 0.22 * S if dome_r else 0) - (len(lines) - 1) * lh / 2
    for i, s in enumerate(lines):
        text_c(X(cx), y0 + i * lh, s, label_size, color=label_color)

def reserve(cx, cz, w, h, label, label_size=22):
    hw, hh = w / 2, h / 2
    dashed_rect(cx - hw, cz - hh, cx + hw, cz + hh, EMAS_TUA, width=4)
    if not label:
        return
    lines = label if isinstance(label, list) else [label]
    lh = label_size + 4
    y0 = Z(cz) - (len(lines) - 1) * lh / 2
    for i, s in enumerate(lines):
        text_c(X(cx), y0 + i * lh, s, label_size, color=EMAS_TUA)

def old_pos(cx, cz, w, h, label):
    """Posisi lama: garis putus-putus merah + label merah (sudah dipindah/dihapus)."""
    dashed_rect(cx - w / 2, cz - h / 2, cx + w / 2, cz + h / 2, MERAH, width=3)
    d.line([X(cx - w / 2), Z(cz - h / 2), X(cx + w / 2), Z(cz + h / 2)], fill=MERAH, width=3)
    d.line([X(cx + w / 2), Z(cz - h / 2), X(cx - w / 2), Z(cz + h / 2)], fill=MERAH, width=3)
    text_c(X(cx), Z(cz) + h / 2 * S + 16, label, 19, color=MERAH)

def star(cx, cz, r_m=2.2, color=EMAS):
    r = r_m * S
    pts = []
    for i in range(10):
        ang = math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append((X(cx) + rr * math.cos(ang), Z(cz) - rr * math.sin(ang)))
    d.polygon(pts, fill=color, outline=EMAS_TUA, width=2)

def dim_h(x0, x1, z, label, color=JATI_TUA, dy=-14):
    """Garis ukur horizontal + label."""
    y = Z(z) + dy
    d.line([X(x0), y, X(x1), y], fill=color, width=2)
    d.line([X(x0), y - 6, X(x0), y + 6], fill=color, width=2)
    d.line([X(x1), y - 6, X(x1), y + 6], fill=color, width=2)
    text_c((X(x0) + X(x1)) / 2, y - 16, label, 19, color=color)

def dim_v(z0, z1, x, label, color=JATI_TUA, dx=-14):
    """Garis ukur vertikal + label."""
    xx = X(x) + dx
    d.line([xx, Z(z0), xx, Z(z1)], fill=color, width=2)
    d.line([xx - 6, Z(z0), xx + 6, Z(z0)], fill=color, width=2)
    d.line([xx - 6, Z(z1), xx + 6, Z(z1)], fill=color, width=2)
    text_c(xx - 8, (Z(z0) + Z(z1)) / 2, label, 19, color=color)

# ================= 1. lahan =================
rect_m(X_MIN, Z_MIN, X_MAX, Z_MAX, fill=KREM)
rect_m(115, -70, 216, 40, fill=WASH_PUTRI)          # kampus baru
rect_m(115, -52, 180, 22, fill=WASH_BARU)          # (bayang: area lama, ditimpa wash baru)
rect_m(115, -70, 216, 40, fill=WASH_PUTRI)
# zona penyangga (barat tembok) — tetap, jangan dimakan
rect_m(X_MIN, -52, 115, 22, fill=(231, 237, 216))
text_c(X(110), Z(-47), "ZONA", 20, color=ZAMRUD)
text_c(X(110), Z(-44), "PENYANGGA", 20, color=ZAMRUD)
text_c(X(110), Z(-40), "tetap —", 18, color=TINTA, bold=False)
text_c(X(110), Z(-37), "tidak dimakan", 18, color=TINTA, bold=False)

# ================= 2. jalan =================
rect_m(115, -1.25, 216, 1.25, fill=JALAN, outline=JALAN_GARIS, width=2)  # E-W (di dalam kampus)
rect_m(140.5, -35, 143.5, 22, fill=JALAN, outline=JALAN_GARIS, width=2)  # internal x=142
text_c(X(142), Z(25), "JALAN INTERNAL x=142", 19, color=TINTA)
text_c(X(142), Z(28), "3 m — diperpanjang ke z=+22", 17, color=TINTA, bold=False)
# konektor
for (kx0, kz0, kx1, kz1) in [(134, -20.25, 140.5, -17.75), (135, 8.75, 140.5, 11.25),
                             (143.5, 7.75, 146, 10.25), (143.5, -34.25, 144, -31.75),
                             (143.5, -13.25, 147, -10.75), (143.5, -19.25, 166, -16.75),
                             (134.5, 14.75, 142, 17.25), (143.5, -22.25, 174.5, -19.75)]:
    rect_m(kx0, kz0, kx1, kz1, fill=JALAN, outline=JALAN_GARIS, width=1)

# ================= 3. tembok =================
# lama (putus-putus jati) — x 115..180, z -52..22
dashed_rect(115, -52, 180, 22, JATI, width=5)
text_c(X(147), Z(-55), "TEMBOK LAMA x 115..180, z -52..+22", 20, color=JATI_TUA)
# baru (solid) — x 115..216, z -70..40
d.line([X(115), Z(-70), X(216), Z(-70)], fill=JATI, width=10)
d.line([X(216), Z(-70), X(216), Z(40)], fill=JATI, width=10)
d.line([X(216), Z(40), X(115), Z(40)], fill=JATI, width=10)
d.line([X(115), Z(-70), X(115), Z(-2)], fill=JATI, width=10)
d.line([X(115), Z(2), X(115), Z(40)], fill=JATI, width=10)
# pilar gerbang (115,0)
for zz in (-2, 2):
    rect_m(114.2, zz - 0.8, 115.8, zz + 0.8, fill=JATI, outline=EMAS_TUA, width=2)
text_c(X(110), Z(6), "GERBANG", 16, color=JATI_TUA)
text_c(X(110), Z(9.5), "PUTRI", 16, color=JATI_TUA)
text_c(X(110), Z(13), "(115,0)", 15, color=JATI_TUA)
text_c(X(110), Z(16), "TERTUTUP", 15, color=JATI_TUA)

# ================= 4. bangunan — posisi BARU =================
building(134, -24, 12, 10, ["MUSHOLLA", "AR-RAUDHAH"], label_size=22, dome_r=2.4)
building(130, 10, 10, 8, ["KELAS", "PUTRI"], label_size=22)
building(152, 9, 12, 8, ["ASRAMA", "PUTRI"], label_size=22)
building(148, -33, 8, 6, ["KANTOR", "USTADZAH"], label_size=18)
building(152, -12, 10, 8, "MADRASAH", label_size=18)
building(166, -12, 10, 8, "STUDIO", label_size=18)
building(176, -20, 3, 3, "", fill=JATI, outline=JATI_TUA, lw=2)
text_c(X(176), Z(-15.5), "POS JAGA", 18, color=JATI_TUA)
# lapangan putri — kini DI DALAM tembok (tapak peta v2; belum dibangun di kode)
rect_m(183, 2, 213, 22, fill=SAWAH, outline=ZAMRUD, width=3)
text_c(X(198), Z(9), "LAPANGAN", 22)
text_c(X(198), Z(15), "PUTRI", 22)
text_c(X(198), Z(19), "tapak peta — belum dibangun", 16, color=TINTA, bold=False)

# ================= 5. posisi LAMA (hanya yang DIHAPUS) =================
# Posisi lama Kelas/Asrama/Kantor/Pos/Spawn TIDAK digambar X (terlalu ramai) —
# perpindahannya tercatat di area-putri-perluasan.md + catatan kaki peta ini.
old_pos(128, -12, 10, 8, "CANGKRUK — DIHAPUS")
text_c(X(128), Z(-4), "bekas tapak → halaman/taman", 17, color=MERAH, bold=False)
# spawn lama (abu-abu, tanpa label — lihat MD)
star(130, 14, 2.0, color=(200, 200, 200))

# ================= 6. reserve (emas putus-putus — BUTUH ACC) =================
reserve(128, 10, 20, 12, "", label_size=18)
reserve(156, 10, 20, 12, "", label_size=18)
text_c(X(128), Z(18.5), "KELAS 5 LANTAI · 20×12", 17, color=EMAS_TUA)
text_c(X(156), Z(18.5), "ASRAMA 3 LANTAI · 20×12", 17, color=EMAS_TUA)
reserve(166, -40, 20, 16, ["MASJID PUTRI", "20×16 (rencana)"], label_size=20)
# pagar musholla (tipis)
d.rectangle([X(126), Z(-31), X(140), Z(-17)], outline=JATI, width=2)

# ================= 7. garis ukur =================
dim_h(140, 143.5, -24, "0,5 m", dy=-30)
dim_h(135, 140.5, 10, "5,5 m", dy=-30)
dim_h(213, 216, 12, "3 m", dy=-30)
dim_v(-48, -70, 166, "22 m", dx=118)
_xx = X(118) - 14
d.line([_xx, Z(-19), _xx, Z(6)], fill=JATI_TUA, width=2)
d.line([_xx - 6, Z(-19), _xx + 6, Z(-19)], fill=JATI_TUA, width=2)
d.line([_xx - 6, Z(6), _xx + 6, Z(6)], fill=JATI_TUA, width=2)
text_c(_xx, Z(-19) - 26, "25 m", 19, color=JATI_TUA)
dim_v(13, 40, 152, "27 m", dx=118)
dim_h(115, 216, -70, "101 m", dy=34)
dim_v(-70, 40, 216, "110 m", dx=16)

# ================= 8. judul + label =================
text_c(W / 2, 44, "AREA PUTRI — PERLUASAN (18 Nov 2026)", 44, color=ZAMRUD)
text_c(W / 2, 88, "Tembok lama x 115..180, z -52..+22 (4.810 m²)  →  tembok baru x 115..216, z -70..+40 (11.110 m², ×2,31)",
       24, color=TINTA, bold=False)
text_c(X(165), Z(-66), "KAMPUS PUTRI — BARU", 30, color=ZAMRUD)
text_c(X(165), Z(36), "HALAMAN SELATAN — 27 m di selatan Asrama", 20, color=TINTA, bold=False)
text_c(X(190), Z(-62), "TIMUR: tapak Lapangan Putri", 18, color=TINTA, bold=False)
text_c(X(190), Z(-59), "kini di DALAM tembok", 18, color=TINTA, bold=False)

# kompas
cx, cy = W - 90, 52
d.ellipse([cx - 34, cy - 34, cx + 34, cy + 34], fill=PUTIH, outline=ZAMRUD, width=3)
d.polygon([(cx, cy - 24), (cx + 10, cy + 6), (cx - 10, cy + 6)], fill=ZAMRUD)
text_c(cx, cy + 19, "U", 22, color=ZAMRUD)

# ================= 9. legenda + skala + catatan =================
ly = H - 250
d.line([40, ly, W - 40, ly], fill=EMAS, width=3)
text_l(60, ly + 16, "Legenda:", 24, color=ZAMRUD, bold=True)
items = [
    ("gedung (posisi baru)", PUTIH, ZAMRUD),
    ("rencana — butuh ACC Mas", (250, 246, 232), EMAS_TUA),
    ("tembok baru", JATI, JATI),
    ("tembok lama", None, JATI),
    ("dipindah / dihapus", None, MERAH),
    ("jalan", JALAN, JALAN_GARIS),
]
x = 200
for name, fillc, oc in items:
    if fillc is None and name.startswith("tembok lama"):
        d.rectangle([x, ly + 20, x + 44, ly + 48], fill=KREM, outline=oc, width=3)
        for xx in range(x + 4, x + 44, 12):
            d.line([xx, ly + 34, xx + 7, ly + 34], fill=oc, width=3)
    elif fillc is None:
        d.rectangle([x, ly + 20, x + 44, ly + 48], fill=KREM, outline=oc, width=3)
        d.line([x, ly + 20, x + 44, ly + 48], fill=oc, width=2)
        d.line([x + 44, ly + 20, x, ly + 48], fill=oc, width=2)
    else:
        d.rectangle([x, ly + 20, x + 44, ly + 48], fill=fillc, outline=oc, width=3)
    text_l(x + 54, ly + 22, name, 22, color=TINTA)
    x += 54 + len(name) * 12 + 40
sx = W - 560
sy = ly + 80
d.rectangle([sx, sy, sx + 20 * S, sy + 12], fill=ZAMRUD)
d.rectangle([sx + 20 * S, sy, sx + 40 * S, sy + 12], fill=PUTIH, outline=ZAMRUD, width=2)
for v, px in ((0, sx), (20, sx + 20 * S), (40, sx + 40 * S)):
    text_c(px, sy + 30, f"{v} m", 20, color=TINTA)
text_l(60, ly + 70, "Skala & koordinat SAMA dengan peta-tata-letak-v2.png (Gilang).", 22, color=TINTA)
text_l(60, ly + 96, "1 kotak = 1 m · Utara = -z (atas).", 22, color=TINTA)
text_c(W / 2, H - 78,
       "Dipindah: Kelas (130,0)→(130,10) · Asrama (152,0)→(152,9) · Kantor (150,-28)→(148,-33)",
       18, color=TINTA, bold=False)
text_c(W / 2, H - 52,
       "Pos Jaga (160,-35)→(176,-20) · Spawn (130,14)→(140,16) · Cangkruk DIHAPUS",
       18, color=TINTA, bold=False)
text_c(W / 2, H - 26,
       "Sudah diterapkan di kode 18 Nov 2026 (Mira) — kampus_putri.gd + tembok_putri.gd. Lihat area-putri-perluasan.md",
       18, color=TINTA, bold=False)

img.save("/home/hatch/workspace/pesantren-verse/v2/konsep/area-putri-perluasan.png")
print("tersimpan:", img.size)
