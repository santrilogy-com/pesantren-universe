# -*- coding: utf-8 -*-
"""
Sketsa peta top-down KONSEP TATA LETAK v2 — Pesantren Universe (Gilang, Tim Maps)
Hanya gambar 2D. Palet: krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A.
Koordinat game: x+ = timur, z+ = selatan, utara = -z (atas peta).
Jalankan: python3 buat_peta.py  ->  peta-tata-letak-v2.png
"""
import math, random
from PIL import Image, ImageDraw, ImageFont

# ---------------- palet ----------------
KREM   = (242, 234, 214)
PUTIH  = (255, 253, 245)
ZAMRUD = (6, 95, 70)
ZAMRUD_TUA = (4, 66, 48)
EMAS   = (201, 162, 39)
EMAS_TUA = (150, 118, 20)
JATI   = (123, 75, 42)
JATI_TUA = (90, 52, 26)
TINTA  = (31, 61, 43)      # teks gelap (hijau sangat gelap)
JALAN  = (231, 220, 192)
JALAN_GARIS = (201, 185, 138)
WASH_PUTRA   = (233, 241, 230)   # tint zamrud pucat
WASH_PENYANGGA = (231, 237, 216) # tint hijau-kuning pucat
WASH_PUTRI   = (248, 239, 214)   # tint emas pucat
SAWAH  = (201, 220, 196)
AIR    = (211, 229, 216)

# ---------------- geometri peta ----------------
# (18 Nov 2026 — diselaraskan ke perluasan area putri: tembok baru x 115..216,
#  z -70..+40; kanvas diperluas ke timur + utara supaya tembok + gunung muat)
X_MIN, X_MAX = -70.0, 235.0
Z_MIN, Z_MAX = -84.0, 95.0
S = 8.6                      # px per meter
ML, MT = 60, 110             # margin kiri / atas (ruang judul)
W = int(ML + (X_MAX - X_MIN) * S + 60)
H = int(MT + (Z_MAX - Z_MIN) * S + 170)

def X(x): return ML + (x - X_MIN) * S
def Z(z): return MT + (z - Z_MIN) * S

FONT      = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_B    = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
def f(sz, bold=False):
    return ImageFont.truetype(FONT_B if bold else FONT, sz)

img = Image.new("RGB", (W, H), KREM)
d = ImageDraw.Draw(img)

def text_c(cx, cy, s, size, color=TINTA, bold=True, halo=True):
    """Teks rata tengah di (cx, cy)."""
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

def dashed_rect(x0, z0, x1, z1, color, width=4, dash=14, gap=10):
    """Persegi garis putus-putus (untuk bangunan rencana/cadangan)."""
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
             rot=0, reserve=False, label_size=27, label_dy=0, label_color=TINTA,
             dome_r=0):
    """Bangunan: persegi (opsional diputar) + label 1-2 baris di tengah.
    Bila dome_r > 0: kubah digambar di bagian utara bangunan, label digeser ke selatan."""
    hw, hh = w / 2, h / 2
    pts = [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)]
    if rot:
        a = math.radians(rot)
        pts = [(x * math.cos(a) - z * math.sin(a),
                x * math.sin(a) + z * math.cos(a)) for x, z in pts]
    poly = [(X(cx + px), Z(cz + pz)) for px, pz in pts]
    if reserve:
        d.polygon(poly, fill=(250, 246, 232))
        for i in range(4):
            p0, p1 = poly[i], poly[(i + 1) % 4]
            L = math.hypot(p1[0] - p0[0], p1[1] - p0[1])
            step = 16
            t = 0.0
            while t < L:
                t1 = min(L, t + 11)
                d.line([(p0[0] + (p1[0] - p0[0]) * t / L, p0[1] + (p1[1] - p0[1]) * t / L),
                        (p0[0] + (p1[0] - p0[0]) * t1 / L, p0[1] + (p1[1] - p0[1]) * t1 / L)],
                       fill=outline, width=lw)
                t += step
    else:
        d.polygon(poly, fill=fill, outline=outline, width=lw)
    if dome_r:
        dome(cx, cz - h * 0.22, dome_r)
        label_dy = label_dy + h * 0.22 * S
    lines = label if isinstance(label, list) else [label]
    lh = label_size + 4
    y0 = Z(cz) + label_dy - (len(lines) - 1) * lh / 2
    for i, s in enumerate(lines):
        text_c(X(cx), y0 + i * lh, s, label_size, color=label_color)

def dome(cx, cz, r_m, color=ZAMRUD, gold=True):
    r = r_m * S
    d.ellipse([X(cx) - r, Z(cz) - r, X(cx) + r, Z(cz) + r], fill=color, outline=EMAS_TUA, width=3)
    if gold:
        d.ellipse([X(cx) - r * 0.25, Z(cz) - r * 1.25, X(cx) + r * 0.25, Z(cz) - r * 0.75],
                  fill=EMAS)

def star(cx, cz, r_m, color=EMAS):
    r = r_m * S
    pts = []
    for i in range(10):
        ang = math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append((X(cx) + rr * math.cos(ang), Z(cz) - rr * math.sin(ang)))
    d.polygon(pts, fill=color, outline=EMAS_TUA, width=2)

def tree(x, z, r_m=1.6):
    r = r_m * S
    d.ellipse([X(x) - r, Z(z) - r, X(x) + r, Z(z) + r], fill=ZAMRUD, outline=ZAMRUD_TUA, width=2)
    d.ellipse([X(x) - r * 0.45, Z(z) - r * 0.45, X(x) + r * 0.45, Z(z) + r * 0.45],
              fill=(16, 120, 88))

def road_h(z, x0, x1, w_m=4.0):
    rect_m(x0, z - w_m / 2, x1, z + w_m / 2, fill=JALAN, outline=JALAN_GARIS, width=2)

def road_v(x, z0, z1, w_m=4.0):
    rect_m(x - w_m / 2, z0, x + w_m / 2, z1, fill=JALAN, outline=JALAN_GARIS, width=2)

# ================= 1. zona (wash) =================
rect_m(X_MIN, Z_MIN, 14, 16, fill=WASH_PUTRA)                 # area putra
rect_m(14, Z_MIN, 115, 16, fill=WASH_PENYANGGA)               # zona penyangga
rect_m(115, -70, 216, 40, fill=WASH_PUTRI)                    # kampus putri (BARU 18 Nov)
# kawasan bersama selatan: krem dasar (tanpa wash)

# ================= 2. jalan =================
road_v(0, -62, -46)                # N-S utara (stub di utara Masjid)
rect_m(-8, -30, 8, 0, fill=JALAN, outline=JALAN_GARIS, width=2)  # plaza Surau-Masjid
road_v(0, 0, 90)                   # N-S selatan (ke Gerbang Utama)
road_h(0, -62, 198)                # E-W utama (diperpanjang ke Lapangan Putri)
road_v(142, -35, 22)               # jalan internal putri (diperpanjang ke z=+22, 18 Nov)
road_h(30, 0, 32)                  # jalan ke sawah

# ================= 3. sawah / kebun / kolam =================
# sawah 60x40 di (60,30): petak 4x3
rect_m(30, 10, 90, 50, fill=SAWAH, outline=ZAMRUD, width=3)
for i in range(1, 4):
    line_m(30 + i * 15, 10, 30 + i * 15, 50, fill=ZAMRUD, width=2)
for j in range(1, 3):
    line_m(30, 10 + j * 40 / 3, 90, 10 + j * 40 / 3, fill=ZAMRUD, width=2)
text_c(X(60), Z(30), "SAWAH", 26)
# kebun 30x20 di (100,30)
rect_m(85, 20, 115, 40, fill=(214, 230, 200), outline=ZAMRUD, width=3)
text_c(X(100), Z(44), "KEBUN", 26)
# kolam 12x8 di (100,60)
rect_m(94, 56, 106, 64, fill=AIR, outline=ZAMRUD, width=3)
for k, zz in enumerate((58, 60, 62)):
    d.arc([X(96), Z(zz) - 4, X(104), Z(zz) + 4], 200, 340, fill=ZAMRUD, width=2)
text_c(X(100), Z(68), "KOLAM", 24)

# pohon kebun/penyangga (deterministik)
rnd = random.Random(17)
for _ in range(46):
    x = rnd.uniform(20, 110); z = rnd.uniform(-50, 12)
    if 30 <= x <= 90 and 10 <= z <= 50:
        continue
    if abs(z) < 4 or abs(x - 14) < 4 or abs(x - 115) < 4:
        continue
    tree(x, z, rnd.uniform(1.2, 1.9))
for _ in range(10):
    tree(rnd.uniform(86, 114), rnd.uniform(21, 39), rnd.uniform(1.2, 1.7))
for _ in range(8):
    tree(rnd.uniform(-58, -42), rnd.uniform(-30, 30), rnd.uniform(1.2, 1.8))
for _ in range(6):
    tree(rnd.uniform(220, 232), rnd.uniform(-20, 20), rnd.uniform(1.2, 1.8))

# ================= 4. tembok =================
# tembok pemisah x=14, z -60..+16 (celah gerbang z -2..+2)
d.line([X(14), Z(-60), X(14), Z(-2)], fill=JATI, width=9)
d.line([X(14), Z(2), X(14), Z(16)], fill=JATI, width=9)
d.line([X(14), Z(-60), X(14), Z(-2)], fill=EMAS, width=2)
d.line([X(14), Z(2), X(14), Z(16)], fill=EMAS, width=2)
# pilar gerbang (14,0)
for zz in (-2, 2):
    rect_m(13.2, zz - 0.8, 14.8, zz + 0.8, fill=JATI, outline=EMAS_TUA, width=2)
# tembok keliling putri x 115..216, z -70..+40 (BARU 18 Nov; celah gerbang barat z -2..+2)
d.line([X(115), Z(-70), X(216), Z(-70)], fill=JATI, width=9)
d.line([X(216), Z(-70), X(216), Z(40)], fill=JATI, width=9)
d.line([X(216), Z(40), X(115), Z(40)], fill=JATI, width=9)
d.line([X(115), Z(-70), X(115), Z(-2)], fill=JATI, width=9)
d.line([X(115), Z(2), X(115), Z(40)], fill=JATI, width=9)
for zz in (-2, 2):
    rect_m(114.2, zz - 0.8, 115.8, zz + 0.8, fill=JATI, outline=EMAS_TUA, width=2)

# ================= 5. bangunan =================
# ---- area putra ----
# Surau lurus 16x20 (T-B x U-S) di (0,-14): depan z=-4, belakang z=-24
# (terverifikasi Rangga 23:19 — jejak GLB, bukan 20x16 seperti perkiraan awal)
building(0, -14, 16, 20, "SURAU", label_size=30, dome_r=3.2)
building(0, -38, 20, 16, ["MASJID BESAR", "(rencana)"], reserve=True, label_size=26, dome_r=3.2)
building(-35, -8, 12, 9, ["KELAS", "PUTRA"], label_size=26)
building(-16, 9, 14, 10, ["ASRAMA", "PUTRA"], label_size=26)
building(-22, -18, 10, 8, ["CANGKRUK", "PUTRA"], label_size=24)
building(-36, -28, 10, 8, ["KANTOR", "PENGASUH"], label_size=23)
# ---- kampus putri (posisi + batas BARU 18 Nov — perluasan Mira/Nadia) ----
building(134, -24, 12, 10, ["MUSHOLLA", "AR-RAUDHAH"], label_size=25, dome_r=2.4)
# Wudhu Putri (122,-24) — BARU, diputuskan Mas 18 Nov 18:27 WIB (usulan utama
# Tim Maps, barat Musholla, tapak 8x6 m x 118..126, z -27..-21; alternatif
# (134,-35) TIDAK dipakai). Ukuran standar, sama dengan Wudhu Surau.
# Label DIGESER KE UTARA (label_dy=-48): label Musholla "AR-RAUDHAH" (size 25,
# 22 m lebar) menjorok ke x=123, jadi label di dalam kotak 8 m bertabrakan
# dengannya — label ditaruh di atas kotak (ruang kosong, utara kotak).
building(122, -24, 8, 6, ["WUDHU", "PUTRI"], label_size=15, label_dy=-48)
# bekas Cangkruk Putri (128,-12) — Taman Putri PINDAH ke pojok barat-daya (122,32),
# ronde 4 (Dewi, 18 Nov); tapak lama kini tanah kosong
text_c(X(128), Z(-12), "TANAH KOSONG", 17, color=EMAS_TUA)
# tapak cadangan Kelas 5 lantai 20x12 (128,10) + Asrama 3 lantai 20x12 (156,10)
# (DITUNDA — keputusan Xam 18 Nov 13:19; gedung saat ini tetap 1 lantai di dalam tapak)
rect_m(118, 4, 138, 16, fill=(250, 246, 232))
dashed_rect(118, 4, 138, 16, EMAS_TUA, width=4)
building(130, 10, 10, 8, ["KELAS", "PUTRI"], label_size=24)
# Asrama Putri — P1 (Nadia, 18 Nov): cangkang DIBANGUN 21,5x12 m, 3 lantai
# (badan 18x12 pusat (155,9) + annex timur; tapak cadangan tidak lagi berlaku)
building(155, 9, 21.5, 12, ["ASRAMA", "PUTRI"], label_size=25)
text_c(X(128), Z(2.2), "TAPAK CADANGAN — KELAS 5 LANTAI (20×12)", 17, color=EMAS_TUA)
building(152, -12, 10, 8, "MADRASAH", label_size=20, label_dy=-30)
building(166, -12, 10, 8, "STUDIO", label_size=20, label_dy=30)
building(148, -33, 8, 6, ["KANTOR", "USTADZAH"], label_size=20)
building(166, -40, 20, 16, ["MASJID PUTRI", "(rencana)"], reserve=True, label_size=25, dome_r=3.2)
# Asrama ke-2 (cadangan) — HALAMAN SELATAN (keputusan Xam 18 Nov 13:19)
rect_m(160, 25, 180, 37, fill=(250, 246, 232))
dashed_rect(160, 25, 180, 37, EMAS_TUA, width=4)
text_c(X(170), Z(29.5), "ASRAMA KE-2", 22, color=EMAS_TUA)
text_c(X(170), Z(33.5), "(cadangan — halaman selatan)", 17, color=EMAS_TUA)
# Taman Putri — PINDAH ke pojok barat-daya, tapak x 117..127, z 28..36,
# pusat (122,32) (ronde 4, Dewi, 18 Nov; tapak lama (128,-12) kini tanah kosong)
rect_m(117, 28, 127, 36, fill=(214, 230, 200), outline=ZAMRUD, width=3)
text_c(X(122), Z(30.5), "TAMAN", 20)
text_c(X(122), Z(33.5), "PUTRI", 20)
# ---- kawasan bersama ----
building(0, 20, 12, 9, ["PERPUSTAKAAN", "& TAMAN"], label_size=24)
building(0, 40, 12, 8, "KANTIN", label_size=26)
building(0, 52, 16, 12, "AULA", label_size=28)
building(-30, 50, 30, 20, ["LAPANGAN", "PUTRA"], label_size=26,
         fill=(214, 230, 200), outline=ZAMRUD)
# Lapangan Putri (198,12) — kini DI DALAM tembok (tapak saja, BELUM dibangun;
#  keputusan Xam 18 Nov 13:19: dibangun NANTI, bareng Asrama ke-2)
rect_m(183, 2, 213, 22, fill=(214, 230, 200))
dashed_rect(183, 2, 213, 22, ZAMRUD, width=4)
text_c(X(198), Z(9), "LAPANGAN", 26)
text_c(X(198), Z(13), "PUTRI", 26)
text_c(X(198), Z(18.5), "(tapak — dibangun nanti)", 17, color=TINTA, bold=False)

# ---- pos & gerbang ----
def pos(x, z, label, size=21):
    rect_m(x - 1.8, z - 1.8, x + 1.8, z + 1.8, fill=JATI, outline=JATI_TUA, width=2)
    text_c(X(x), Z(z) - 26, label, size, color=JATI_TUA)

pos(-40, -35, "POS JAGA")
pos(-40, 80, "POS JAGA")
pos(40, 80, "POS JAGA")
pos(176, -20, "POS JAGA")
pos(17, 5, "SATPAM")
# gerbang utama (0,80)
rect_m(-3, 78, 3, 82, fill=JATI, outline=JATI_TUA, width=2)
text_c(X(0), Z(86), "GERBANG UTAMA", 26, color=JATI_TUA)
# peti + papan selamat datang
d.ellipse([X(0) - 10, Z(26) - 10, X(0) + 10, Z(26) + 10], fill=EMAS, outline=EMAS_TUA, width=2)
text_c(X(0), Z(26), "M3", 18, color=JATI_TUA, halo=False)
text_c(X(0), Z(32), "Papan selamat datang", 20, color=TINTA)

# ---- spawn ----
star(-4, 14, 2.6)
text_c(X(2), Z(14) - 30, "SPAWN PUTRA", 20, color=EMAS_TUA)
star(140, 16, 2.6)
text_c(X(140), Z(16) + 34, "SPAWN PUTRI", 22, color=EMAS_TUA)

# ---- label gerbang di tembok ----
text_c(X(14), Z(-8), "GERBANG", 22, color=JATI_TUA)
text_c(X(115), Z(-8), "GERBANG", 22, color=JATI_TUA)
text_c(X(115), Z(6), "PUTRI", 22, color=JATI_TUA)

# ================= 6. label zona =================
text_c(X(-28), Z(-58), "AREA PUTRA", 38, color=ZAMRUD)
text_c(X(64), Z(-58), "ZONA PENYANGGA", 34, color=ZAMRUD)
text_c(X(64), Z(-50), "kebun & taman — tanpa bangunan", 24, color=TINTA)
text_c(X(147), Z(-47), "KAMPUS PUTRI", 34, color=ZAMRUD)
text_c(X(0), Z(66), "KAWASAN BERSAMA", 34, color=ZAMRUD)
text_c(X(64), Z(-30), "Surau → Musholla ±134 m", 24, color=TINTA)
text_c(X(24), Z(-40), "TEMBOK x=14", 24, color=JATI_TUA)

# ================= 7. gunung (latar utara, deret segitiga kecil di tepi atas peta) =================
# (18 Nov: digeser ke z=-76 — tembok utara putri kini di z=-70, gunung harus di utaranya)
gy = Z(-76)
for gx in range(-66, 216, 14):
    d.polygon([(X(gx), gy), (X(gx + 7), gy - 26), (X(gx + 14), gy)],
              fill=(120, 130, 110), outline=JATI_TUA, width=1)
text_c(X(0), gy + 22, "Gunung — latar utara (±350 m)", 22, color=TINTA)

# ================= 8. judul =================
text_c(W / 2, 42, "PESANTREN UNIVERSE — KONSEP TATA LETAK v2", 48, color=ZAMRUD)
text_c(W / 2, 88, "Sketsa top-down  •  Satu dunia, dua area  •  Dasar: v1 Opsi A (live Ronde 23)  •  Area putri diperluas 18 Nov 2026",
       26, color=TINTA, bold=False)

# kompas (di baris judul, kanan atas)
cx, cy = W - 100, 52
d.ellipse([cx - 38, cy - 38, cx + 38, cy + 38], fill=PUTIH, outline=ZAMRUD, width=3)
d.polygon([(cx, cy - 26), (cx + 11, cy + 6), (cx - 11, cy + 6)], fill=ZAMRUD)
text_c(cx, cy + 21, "U", 24, color=ZAMRUD)

# ================= 9. legenda + skala =================
ly = H - 150
d.line([40, ly, W - 40, ly], fill=EMAS, width=3)
text_l(60, ly + 18, "Legenda:", 26, color=ZAMRUD, bold=True)
items = [
    ("bangunan", PUTIH, ZAMRUD, False),
    ("rencana / cadangan", (250, 246, 232), ZAMRUD, True),
    ("tembok", JATI, JATI, False),
    ("jalan", JALAN, JALAN_GARIS, False),
    ("sawah / kebun", SAWAH, ZAMRUD, False),
]
x = 220
for name, fillc, oc, dash in items:
    d.rectangle([x, ly + 22, x + 44, ly + 50], fill=fillc, outline=oc, width=3)
    text_l(x + 54, ly + 24, name, 24, color=TINTA)
    x += 54 + len(name) * 13 + 46
# bintang spawn di legenda
star_px = (x + 22, ly + 36)
d.polygon([(star_px[0], star_px[1] - 14), (star_px[0] + 5, star_px[1] - 4),
           (star_px[0] + 15, star_px[1] - 4), (star_px[0] + 7, star_px[1] + 4),
           (star_px[0] + 10, star_px[1] + 14), (star_px[0], star_px[1] + 8),
           (star_px[0] - 10, star_px[1] + 14), (star_px[0] - 7, star_px[1] + 4),
           (star_px[0] - 15, star_px[1] - 4), (star_px[0] - 5, star_px[1] - 4)],
          fill=EMAS, outline=EMAS_TUA, width=2)
text_l(x + 44, ly + 24, "spawn", 24, color=TINTA)

# skala 0-20-40 m
sx = W - 420
sy = ly + 95
d.rectangle([sx, sy, sx + 20 * S, sy + 12], fill=ZAMRUD)
d.rectangle([sx + 20 * S, sy, sx + 40 * S, sy + 12], fill=PUTIH, outline=ZAMRUD, width=2)
for v, px in ((0, sx), (20, sx + 20 * S), (40, sx + 40 * S)):
    text_c(px, sy + 30, f"{v} m", 22, color=TINTA)

text_c(W / 2, H - 28,
       "Konsep untuk dinilai Mas — belum dibangun 3D. Usulan perubahan dari v1 (U1–U4): lihat KONSEP-TATA-LETAK.md",
       23, color=TINTA, bold=False)

img.save("/home/hatch/workspace/pesantren-verse/v2/konsep/peta-tata-letak-v2.png")
print("tersimpan:", img.size)
