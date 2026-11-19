#!/usr/bin/env python3
"""Peta jejak Kyai — sebelum vs sesudah perbaikan (Raka, 19 Nov 2026).
Panel atas: rute penuh (tampak atas, utara di atas).
Panel bawah: zoom interior Surau (dinding timur yang ditembus)."""
from PIL import Image, ImageDraw, ImageFont
import csv, math

SEBELUM = "/home/hatch/workspace/.logs-gate-18nov/jejak-kyai-tembok-SEBELUM-19nov.csv"
SESUDAH = "/home/hatch/workspace/.logs-gate-18nov/jejak-kyai-tembok-SESUDAH-19nov.csv"
OUT = "/home/hatch/workspace/pesantren-verse/v2/konsep/jejak-kyai-tembok-v1.png"

def baca(path):
    pts = []
    with open(path) as f:
        for row in csv.DictReader(f):
            pts.append((float(row["x"]), float(row["z"])))
    return pts

sebelum = baca(SEBELUM)
sesudah = baca(SESUDAH)

try:
    fj = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
    fb = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 20)
    fk = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 17)
except Exception:
    fj = fb = fk = ImageFont.load_default()

W = 880
TOP = 84          # header panel atas
H1 = 1180         # tinggi peta panel atas
H2 = 560          # tinggi peta zoom
GAP = 70          # judul panel bawah
CAP = 96          # caption bawah
H = TOP + H1 + GAP + H2 + CAP
img = Image.new("RGB", (W, H), "#f2ead6")
d = ImageDraw.Draw(img)

# ---------- panel atas: rute penuh ----------
X0, X1, Z0, Z1 = -35.0, 20.0, -310.0, 10.0
def px(x): return int((x - X0) / (X1 - X0) * W)
def py(z): return TOP + int((Z1 - z) / (Z1 - Z0) * H1)

d.text((16, 8), "JEJAK KYAI — Dzuhur (tampak atas, utara di atas)", fill="#043b2c", font=fj)
d.text((16, 44), "Merah = SEBELUM  •  Hijau = SESUDAH perbaikan", fill="#333333", font=fb)
for gx in range(-30, 21, 10):
    d.line([(px(gx), py(10)), (px(gx), py(-310))], fill="#ddd5c2", width=1)
    d.text((px(gx) + 2, py(10) + 2), str(gx), fill="#999999", font=fk)
for gz in range(-300, 11, 20):
    d.line([(px(-35), py(gz)), (px(20), py(gz))], fill="#ddd5c2", width=1)
    d.text((px(-35) + 2, py(gz) + 2), str(gz), fill="#999999", font=fk)
# Cangkang Surau luar.
d.rectangle([px(-8), py(-4), px(8), py(-24)], outline="#7b4b2a", width=4)
d.text((px(-8) + 6, py(-10)), "SURAU", fill="#7b4b2a", font=fb)
# Interior (rotasi -25° mengelilingi pintu (0,-294)).
def ke_dunia(lx, lz):
    rot = math.radians(-25.0); c = math.cos(rot); s = math.sin(rot)
    qx, qz = lx, lz + 294.0
    return (qx * c + qz * s, -294.0 + (-qx * s + qz * c))
sudut = [ke_dunia(-9, -308), ke_dunia(9, -308), ke_dunia(9, -294), ke_dunia(-9, -294)]
d.polygon([(px(x), py(z)) for x, z in sudut], outline="#065f46", width=4)
d.text((px(-9), py(-299)), "INTERIOR", fill="#065f46", font=fb)
# Pintu luar + serambi.
d.ellipse([px(-1), py(-3.2), px(1), py(-4.4)], fill="#c9a227")
d.text((px(2), py(-5)), "pintu luar", fill="#7b4b2a", font=fk)
d.ellipse([px(-3.5) - 6, py(-2.0) - 6, px(-3.5) + 6, py(-2.0) + 6], fill="#1e8449")
d.text((px(-3.5) - 130, py(0) + 4), "rumah luar Kyai", fill="#1e8449", font=fk)
# Jejak (potong loncatan teleport > 5 m).
for pts, col, wd in [(sebelum, "#c0392b", 3), (sesudah, "#1e8449", 3)]:
    for a, b in zip(pts, pts[1:]):
        if math.hypot(b[0] - a[0], b[1] - a[1]) > 5.0:
            continue
        d.line([(px(a[0]), py(a[1])), (px(b[0]), py(b[1]))], fill=col, width=wd)
# Titik tabrakan (9.72,-293.55).
cx, cz = 9.72, -293.55
d.ellipse([px(cx) - 13, py(cz) - 13, px(cx) + 13, py(cz) + 13], outline="#c0392b", width=5)
d.line([(px(cx) - 9, py(cz) - 9), (px(cx) + 9, py(cz) + 9)], fill="#c0392b", width=4)
d.line([(px(cx) - 9, py(cz) + 9), (px(cx) + 9, py(cz) - 9)], fill="#c0392b", width=4)
d.text((px(cx) - 330, py(cz) - 10), "TEMBUS di sini", fill="#c0392b", font=fb)

# ---------- panel bawah: zoom interior ----------
Y0 = TOP + H1
d.text((16, Y0 + 8), "ZOOM INTERIOR — dinding timur yang ditembus Kyai", fill="#043b2c", font=fj)
ZX0, ZX1, ZZ0, ZZ1 = -12.0, 16.0, -312.0, -288.0
ZY = Y0 + GAP
def qx(x): return int((x - ZX0) / (ZX1 - ZX0) * W)
def qy(z): return ZY + int((ZZ1 - z) / (ZZ1 - ZZ0) * H2)
for gx in range(-10, 17, 5):
    d.line([(qx(gx), qy(-288)), (qx(gx), qy(-312))], fill="#ddd5c2", width=1)
    d.text((qx(gx) + 2, qy(-288) + 2), str(gx), fill="#999999", font=fk)
for gz in range(-310, -287, 5):
    d.line([(qx(-12), qy(gz)), (qx(16), qy(gz))], fill="#ddd5c2", width=1)
    d.text((qx(-12) + 2, qy(gz) + 2), str(gz), fill="#999999", font=fk)
# Dinding interior (4 sisi, beri celah pintu di selatan).
d.line([(qx(sudut[0][0]), qy(sudut[0][1])), (qx(sudut[1][0]), qy(sudut[1][1]))], fill="#065f46", width=5)  # utara
d.line([(qx(sudut[1][0]), qy(sudut[1][1])), (qx(sudut[2][0]), qy(sudut[2][1]))], fill="#065f46", width=5)  # timur
d.line([(qx(sudut[3][0]), qy(sudut[3][1])), (qx(sudut[0][0]), qy(sudut[0][1]))], fill="#065f46", width=5)  # barat
# selatan: dua segmen + celah pintu (lokal x -1.2..1.2)
s1a, s1b = ke_dunia(-9, -294), ke_dunia(-1.2, -294)
s2a, s2b = ke_dunia(1.2, -294), ke_dunia(9, -294)
d.line([(qx(s1a[0]), qy(s1a[1])), (qx(s1b[0]), qy(s1b[1]))], fill="#065f46", width=5)
d.line([(qx(s2a[0]), qy(s2a[1])), (qx(s2b[0]), qy(s2b[1]))], fill="#065f46", width=5)
d.text((qx(0) - 30, qy(-294) + 6), "PINTU", fill="#7b4b2a", font=fb)
# Mihrab, imam, kursi, spawn.
for (x, z, label, col) in [(-4.65, -303.89, "mihrab", "#065f46"),
                           (-0.21, -301.82, "imam", "#c9a227"),
                           (9.72, -301.60, "kursi Kyai", "#043b2c"),
                           (0.63, -295.36, "spawn dalam", "#7b4b2a")]:
    d.ellipse([qx(x) - 7, qy(z) - 7, qx(x) + 7, qy(z) + 7], fill=col)
    d.text((qx(x) + 10, qy(z) - 8), label, fill=col, font=fb)
# Jejak zoom: hanya titik di dalam jendela zoom.
for pts, col, wd in [(sebelum, "#c0392b", 4), (sesudah, "#1e8449", 4)]:
    for a, b in zip(pts, pts[1:]):
        if math.hypot(b[0] - a[0], b[1] - a[1]) > 5.0:
            continue
        if not (ZX0 <= a[0] <= ZX1 and ZZ0 <= a[1] <= ZZ1):
            continue
        if not (ZX0 <= b[0] <= ZX1 and ZZ0 <= b[1] <= ZZ1):
            continue
        d.line([(qx(a[0]), qy(a[1])), (qx(b[0]), qy(b[1]))], fill=col, width=wd)
# Tanda X di titik tembus.
d.ellipse([qx(cx) - 14, qy(cz) - 14, qx(cx) + 14, qy(cz) + 14], outline="#c0392b", width=5)
d.line([(qx(cx) - 10, qy(cz) - 10), (qx(cx) + 10, qy(cz) + 10)], fill="#c0392b", width=4)
d.line([(qx(cx) - 10, qy(cz) + 10), (qx(cx) + 10, qy(cz) - 10)], fill="#c0392b", width=4)
d.text((qx(cx) - 320, qy(cz) - 12), "TEMBUS (9.72,-293.55)", fill="#c0392b", font=fb)

# Caption.
CY = ZY + H2 + 12
d.text((16, CY), "SEBELUM: pulang (0,-2.3) -> (-28,2) -> (-28,-27) -> (9.72,-27) -> kursi (9.72,-301.6);", fill="#333333", font=fk)
d.text((16, CY + 26), "segmen terakhir 274 m lurus ke utara menembus dinding timur interior.", fill="#333333", font=fk)
d.text((16, CY + 52), "SESUDAH: pulang ke serambi (-3.5,-2.0), lalu masuk lewat pintu (teleport GTA) -> kursi. 0 tabrakan.", fill="#333333", font=fk)
img.save(OUT)
print("OK", OUT)
