# -*- coding: utf-8 -*-
"""
Lembar konsep 2D — 5 ELEMEN LINGKUNGAN v2 (Bima, Blender Pesantren Universe)
Aturan v2: gambar konsep dulu, setor ke Mas, baru bangun 3D kalau di-ACC.
Vektor datar berskala (PIL), palet HEX persis PV, gaya sama seperti
lembar konsep Surau + peta tata letak.
Jalankan: python3 gambar_lingkungan.py  ->  5 PNG di folder ini.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFont

OUT = __file__.rsplit("/", 1)[0]

# ---------------- palet (RGB) ----------------
KREM      = (242, 234, 214)
KREM_MUDA = (250, 244, 230)
PUTIH     = (255, 253, 245)
ZAMRUD    = (6, 95, 70)
ZAMRUD_TUA = (4, 66, 48)
EMAS      = (201, 162, 39)
JATI      = (123, 75, 42)
JATI_TUA  = (90, 52, 26)
BATU      = (184, 178, 164)
BATU_MUDA = (231, 220, 192)
TINTA     = (31, 61, 43)
ABU       = (110, 110, 100)
HIJAU_DAUN = (46, 125, 91)
HIJAU_MUDA = (127, 176, 105)
RUMPUT    = (168, 198, 134)
RUMPUT_TUA = (122, 154, 91)
AIR       = (168, 200, 184)
AIR_TUA   = (140, 180, 200)
TANAH     = (138, 109, 75)
BAMBU     = (217, 179, 106)
BAMBU_TUA = (190, 150, 80)
B_MERAH   = (185, 28, 28)
B_KUNING  = (234, 179, 8)
B_UNGU    = (126, 34, 206)
B_ORANYE  = (234, 88, 12)

FONT   = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

def f(sz, bold=False):
    return ImageFont.truetype(FONT_B if bold else FONT, sz)

W, H = 1080, 1560

def text_c(d, cx, cy, s, size, color=TINTA, bold=True, halo=False):
    ft = f(size, bold)
    bb = d.textbbox((0, 0), s, font=ft)
    w, h = bb[2] - bb[0], bb[3] - bb[1]
    x, y = cx - w / 2 - bb[0], cy - h / 2 - bb[1]
    if halo:
        d.text((x, y), s, font=ft, fill=PUTIH, stroke_width=4, stroke_fill=PUTIH)
    d.text((x, y), s, font=ft, fill=color)

def text_r(d, x, cy, s, size, color=TINTA, bold=True):
    """Teks rata kanan: ujung kanan di x, tengah vertikal di cy."""
    ft = f(size, bold)
    bb = d.textbbox((0, 0), s, font=ft)
    w, h = bb[2] - bb[0], bb[3] - bb[1]
    d.text((x - w - bb[0], cy - h / 2 - bb[1]), s, font=ft, fill=color)

def text_l(d, x, y, s, size, color=TINTA, bold=False):
    d.text((x, y), s, font=f(size, bold), fill=color)

def sheet(no, title, subtitle):
    img = Image.new("RGB", (W, H), KREM)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 112], fill=ZAMRUD)
    d.rectangle([0, 112, W, 120], fill=EMAS)
    # judul auto-fit: kecilkan font sampai muat 960 px
    tsize = 42
    while tsize > 20:
        ft = ImageFont.truetype(FONT_B, tsize)
        bb = d.textbbox((0, 0), title, font=ft)
        if bb[2] - bb[0] <= 960:
            break
        tsize -= 2
    text_c(d, W // 2, 46, title, tsize, color=KREM_MUDA, bold=True)
    text_c(d, W // 2, 88, subtitle, 22, color=(205, 225, 205), bold=False)
    text_l(d, 60, 132, f"LINGKUNGAN v2 — {no}", 20, color=ZAMRUD_TUA, bold=True)
    text_r(d, 1020, 142, "Skala pada gambar", 18, color=ABU, bold=False)
    return img, d

def dim_h(d, x0, x1, y, label, color=TINTA):
    d.line([(x0, y), (x1, y)], fill=color, width=3)
    d.line([(x0, y - 8), (x0, y + 8)], fill=color, width=3)
    d.line([(x1, y - 8), (x1, y + 8)], fill=color, width=3)
    text_c(d, (x0 + x1) // 2, y - 24, label, 22, color=color)

def dim_v(d, x, y0, y1, label, color=TINTA, label_side="left"):
    d.line([(x, y0), (x, y1)], fill=color, width=3)
    d.line([(x - 8, y0), (x + 8, y0)], fill=color, width=3)
    d.line([(x - 8, y1), (x + 8, y1)], fill=color, width=3)
    if label_side == "right":
        text_l(d, x + 14, (y0 + y1) // 2 - 11, label, 22, color=color, bold=True)
    else:
        text_r(d, x - 14, (y0 + y1) // 2, label, 22, color=color)

def palette_strip(d, y, colors):
    """colors: list (nama, hex, rgb)."""
    text_l(d, 60, y - 30, "PALET", 20, color=ZAMRUD_TUA, bold=True)
    x = 60
    for (nama, hexs, rgb) in colors:
        d.rectangle([x, y, x + 110, y + 42], fill=rgb, outline=TINTA, width=2)
        d.text((x, y + 48), nama, font=f(17), fill=TINTA)
        d.text((x, y + 68), hexs, font=f(15), fill=ABU)
        x += 155

def notes_box(d, y, lines):
    h = 46 + 27 * len(lines)
    d.rectangle([60, y, 1020, y + h], fill=KREM_MUDA, outline=EMAS, width=3)
    d.text((82, y + 10), "CATATAN", font=f(21, True), fill=ZAMRUD)
    for i, s in enumerate(lines):
        d.text((82, y + 42 + i * 27), "•  " + s, font=f(21), fill=TINTA)

def orang(d, x, ground_y, s):
    """Figur santri 1,7 m untuk skala (kepala bundar + badan)."""
    h = 1.7 * s
    r = 0.11 * s
    d.ellipse([x - r, ground_y - h, x + r, ground_y - h + 2 * r], fill=TINTA)
    w = max(3, int(0.055 * s))
    d.line([(x, ground_y - h + 2 * r), (x, ground_y - 0.85 * s)], fill=TINTA, width=w)
    d.line([(x, ground_y - 0.85 * s), (x - 0.18 * s, ground_y)], fill=TINTA, width=w)
    d.line([(x, ground_y - 0.85 * s), (x + 0.18 * s, ground_y)], fill=TINTA, width=w)
    d.line([(x, ground_y - h + 2 * r + 0.22 * s), (x - 0.22 * s, ground_y - 0.55 * s)],
           fill=TINTA, width=max(3, int(0.04 * s)))
    d.line([(x, ground_y - h + 2 * r + 0.22 * s), (x + 0.22 * s, ground_y - 0.55 * s)],
           fill=TINTA, width=max(3, int(0.04 * s)))

def ground(d, y, x0=60, x1=1020):
    d.line([(x0, y), (x1, y)], fill=TINTA, width=4)
    for gx in range(x0 + 30, x1, 90):
        d.line([(gx, y), (gx - 8, y + 12)], fill=RUMPUT_TUA, width=3)
        d.line([(gx, y), (gx + 8, y + 12)], fill=RUMPUT_TUA, width=3)

# ======================================================================
# 01 — POHON
# ======================================================================
def lembar_pohon():
    img, d = sheet("01 — POHON", "Pohon rindang gaya Syumra (bukan lollipop v1)", "01")
    s = 80
    gy = 1090
    # --- Varian A: pohon rindang, total 8,5 m, tajuk ±5,5 m ---
    ax = 320
    # batang: meruncing, 6 m, + 2 cabang
    d.polygon([(ax - 26, gy), (ax - 16, gy - 6 * s), (ax + 16, gy - 6 * s), (ax + 26, gy)],
              fill=JATI)
    d.line([(ax, gy - 4.4 * s), (ax - 85, gy - 5.6 * s)], fill=JATI, width=16)
    d.line([(ax, gy - 4.8 * s), (ax + 90, gy - 5.9 * s)], fill=JATI, width=16)
    # tajuk: 3 gumpalan (tengah besar, 2 samping)
    d.ellipse([ax - 140, gy - 8.5 * s, ax + 140, gy - 8.5 * s + 280], fill=ZAMRUD)
    d.ellipse([ax - 225, gy - 7.3 * s, ax - 5, gy - 7.3 * s + 220], fill=HIJAU_DAUN)
    d.ellipse([ax + 5, gy - 7.3 * s, ax + 225, gy - 7.3 * s + 220], fill=HIJAU_DAUN)
    d.ellipse([ax - 90, gy - 8.5 * s + 30, ax + 40, gy - 8.5 * s + 160], fill=HIJAU_MUDA)
    d.ellipse([ax - 180, gy - 7.0 * s, ax - 90, gy - 7.0 * s + 90], fill=HIJAU_MUDA)
    ground(d, gy)
    # --- Varian B: pohon hias kecil, total 3,5 m, tajuk Ø 2,4 m ---
    bx = 780
    d.polygon([(bx - 16, gy), (bx - 10, gy - 1.8 * s), (bx + 10, gy - 1.8 * s), (bx + 16, gy)],
              fill=JATI)
    d.ellipse([bx - 95, gy - 3.5 * s, bx + 95, gy - 3.5 * s + 190], fill=HIJAU_DAUN)
    d.ellipse([bx - 60, gy - 3.5 * s + 20, bx + 20, gy - 3.5 * s + 100], fill=HIJAU_MUDA)
    # --- figur skala ---
    orang(d, 585, gy, s)
    text_c(d, 585, gy + 34, "1,7 m", 20, color=TINTA)
    # --- dimensi ---
    dim_v(d, 110, gy - 8.5 * s, gy, "8,5 m")
    dim_v(d, 970, gy - 3.5 * s, gy, "3,5 m")
    dim_h(d, ax - 225, ax + 225, gy - 8.5 * s - 40, "tajuk ±5,5 m")
    text_c(d, ax, gy + 34, "A — Pohon rindang", 24, color=TINTA)
    text_c(d, bx, gy + 34, "B — Pohon hias", 24, color=TINTA)
    palette_strip(d, 1215, [
        ("Jati", "#7B4B2A", JATI), ("Zamrud", "#065F46", ZAMRUD),
        ("Daun", "#2E7D5B", HIJAU_DAUN), ("Daun muda", "#7FB069", HIJAU_MUDA),
        ("Rumput", "#8FAE6B", (143, 174, 107)),
    ])
    notes_box(d, 1335, [
        "Tajuk 3 gumpalan tumpang tindih (bukan 1 bola lollipop v1).",
        "Varian A: halaman, tepi jalan, dekat Surau — peneduh utama.",
        "Varian B: taman, dekat bangunan, pot besar.",
        "Batang jati meruncing + 2–3 cabang; daun 2 tingkat warna.",
    ])
    img.save(f"{OUT}/lingkungan-01-pohon.png")
    print("OK lingkungan-01-pohon.png")

# ======================================================================
# 02 — TAMAN
# ======================================================================
def lembar_taman():
    img, d = sheet("02 — TAMAN", "Taman kecil 8 × 6 m — denah atas + bangku", "02")
    s = 80
    ox, oy = 220, 260  # sudut kiri-atas denah (meter 0,0)
    pw, ph = 8 * s, 6 * s  # 640 x 480
    # rumput
    d.rectangle([ox, oy, ox + pw, oy + ph], fill=RUMPUT, outline=TINTA, width=4)
    # jalan batu: dari pintu selatan (tengah bawah) melengkung ke bangku utara
    path = [(ox + 4 * s, oy + ph), (ox + 3.8 * s, oy + 4.6 * s), (ox + 4.2 * s, oy + 3.4 * s),
            (ox + 4.0 * s, oy + 2.2 * s), (ox + 4.0 * s, oy + 1.1 * s)]
    d.line(path, fill=(201, 185, 138), width=int(0.8 * s) + 6, joint="curve")
    d.line(path, fill=BATU_MUDA, width=int(0.8 * s), joint="curve")
    # bedeng bunga (4 sudut), tanah + bunga 4 warna
    rnd = random.Random(5)
    bunga = [B_MERAH, B_KUNING, B_UNGU, B_ORANYE]
    for (bx0, by0) in [(0.3, 0.3), (5.3, 0.3), (0.3, 4.5), (5.3, 4.5)]:
        x0, y0 = ox + bx0 * s, oy + by0 * s
        d.rounded_rectangle([x0, y0, x0 + 2.4 * s, y0 + 1.2 * s], radius=12,
                            fill=TANAH, outline=JATI_TUA, width=3)
        for _ in range(26):
            fx = x0 + rnd.uniform(8, 2.4 * s - 8)
            fy = y0 + rnd.uniform(8, 1.2 * s - 8)
            d.ellipse([fx - 5, fy - 5, fx + 5, fy + 5], fill=rnd.choice(bunga))
    # pohon hias kecil (sudut kiri-atas dalam)
    d.ellipse([ox + 1.1 * s, oy + 1.9 * s, ox + 3.5 * s, oy + 4.3 * s], fill=HIJAU_DAUN)
    d.ellipse([ox + 1.5 * s, oy + 2.2 * s, ox + 2.6 * s, oy + 3.3 * s], fill=HIJAU_MUDA)
    d.ellipse([ox + 2.2 * s, oy + 3.0 * s, ox + 2.4 * s, oy + 3.2 * s], fill=JATI)
    # semak di tepi jalan
    for (sx, sy) in [(3.3, 5.2), (4.7, 4.0), (3.4, 2.6)]:
        d.ellipse([ox + sx * s - 18, oy + sy * s - 18, ox + sx * s + 18, oy + sy * s + 18],
                  fill=RUMPUT_TUA)
    # bangku 1 (utara, menghadap selatan/jalan), bangku 2 (timur, menghadap barat)
    d.rectangle([ox + 3.1 * s, oy + 0.35 * s, ox + 4.9 * s, oy + 0.75 * s], fill=JATI, outline=JATI_TUA, width=3)
    d.rectangle([ox + 7.25 * s, oy + 2.6 * s, ox + 7.65 * s, oy + 4.4 * s], fill=JATI, outline=JATI_TUA, width=3)
    text_c(d, ox + 4 * s, oy + 0.12 * s, "bangku", 18, color=TINTA, bold=False)
    # label denah
    text_c(d, ox + pw / 2, oy - 34, "DENAH ATAS — TAMAN 8 × 6 m", 24, color=TINTA)
    dim_h(d, ox, ox + pw, oy - 58, "8 m")
    dim_v(d, ox - 30, oy, oy + ph, "6 m")
    # --- tampak depan bangku (skala 160 px/m) ---
    bs = 160
    bgx, bgy = 540, 1010  # tengah bawah bangku, tanah
    bw = 1.8 * bs  # 288
    d.rectangle([bgx - bw / 2, bgy - 0.45 * bs, bgx + bw / 2, bgy - 0.39 * bs], fill=JATI)  # papan duduk
    d.rectangle([bgx - bw / 2, bgy - 0.95 * bs, bgx + bw / 2, bgy - 0.89 * bs], fill=JATI)  # sandaran atas
    d.rectangle([bgx - bw / 2, bgy - 0.72 * bs, bgx + bw / 2, bgy - 0.66 * bs], fill=JATI)  # sandaran tengah
    for lx in (-0.75, 0.75):
        d.rectangle([bgx + lx * bs - 6, bgy - 0.95 * bs, bgx + lx * bs + 6, bgy - 0.39 * bs], fill=JATI_TUA)
    for lx in (-0.8, 0.8):
        d.rectangle([bgx + lx * bs - 7, bgy - 0.45 * bs, bgx + lx * bs + 7, bgy], fill=JATI_TUA)
    ground(d, bgy, 380, 700)
    dim_h(d, bgx - bw / 2, bgx + bw / 2, bgy - 0.95 * bs - 34, "1,8 m")
    dim_v(d, bgx - bw / 2 - 30, bgy - 0.45 * bs, bgy, "0,45 m")
    text_c(d, bgx, bgy + 34, "Bangku jati — tampak depan", 22, color=TINTA)
    palette_strip(d, 1215, [
        ("Jati", "#7B4B2A", JATI), ("Rumput", "#A8C686", RUMPUT),
        ("Batu", "#E7DCC0", BATU_MUDA), ("Bunga", "#B91C1C", B_MERAH),
        ("Tanah", "#8A6D4B", TANAH),
    ])
    notes_box(d, 1335, [
        "Bunga 4 warna di 4 bedeng (merah, kuning, ungu, oranye).",
        "2 bangku jati menghadap jalan setapak; 1 pohon hias + semak.",
        "Jalan batu lebar 0,8 m, dari pintu selatan ke bangku utara.",
        "Rumput hijau muda; bedeng tanah coklat berpagar jati rendah.",
    ])
    img.save(f"{OUT}/lingkungan-02-taman.png")
    print("OK lingkungan-02-taman.png")

# ======================================================================
# 03 — SAWAH
# ======================================================================
def lembar_sawah():
    img, d = sheet("03 — SAWAH", "Petak sawah berair 20 × 12 m — denah + potongan", "03")
    s = 38
    ox, oy = 160, 270
    pw, ph = 20 * s, 12 * s  # 760 x 456
    # saluran air di sisi utara
    d.rectangle([ox, oy - 42, ox + pw, oy - 16], fill=AIR_TUA, outline=TINTA, width=2)
    text_c(d, ox + pw / 2, oy - 29, "saluran air", 18, color=(20, 50, 70), bold=False)
    # pematang luar (tanah) + 4 petak air
    d.rectangle([ox, oy, ox + pw, oy + ph], fill=TANAH, outline=TINTA, width=3)
    pem = int(0.6 * s)  # 23 px
    b = 12  # tepi luar
    x0a, x1a = ox + b, ox + pw - b
    y0a, y1a = oy + b, oy + ph - b
    xm = (x0a + x1a) // 2
    ym = (y0a + y1a) // 2
    petak = [(x0a, y0a, xm - pem // 2, ym - pem // 2), (xm + pem // 2, y0a, x1a, ym - pem // 2),
             (x0a, ym + pem // 2, xm - pem // 2, y1a), (xm + pem // 2, ym + pem // 2, x1a, y1a)]
    rnd = random.Random(9)
    for (px0, py0, px1, py1) in petak:
        d.rectangle([px0, py0, px1, py1], fill=AIR)
        # baris padi: rumpun kecil hijau, jarak ~0,5 m
        for ry in range(py0 + 14, py1 - 8, 20):
            for rx in range(px0 + 12, px1 - 8, 16):
                g = HIJAU_DAUN if rnd.random() < 0.6 else (90, 154, 74)
                d.line([(rx, ry), (rx - 4, ry - 9)], fill=g, width=3)
                d.line([(rx, ry), (rx + 4, ry - 9)], fill=g, width=3)
                d.line([(rx, ry), (rx, ry - 10)], fill=g, width=3)
    text_c(d, ox + pw / 2, oy - 62, "DENAH ATAS — SAWAH 20 × 12 m (4 petak)", 24, color=TINTA)
    dim_h(d, ox, ox + pw, oy - 86, "20 m")
    dim_v(d, ox - 30, oy, oy + ph, "12 m")
    # --- potongan melintang (skala 120 px/m) ---
    ps = 120
    py0 = 890  # alas lumpur (denah bawah 726, judul potongan 795)
    px0, px1 = 180, 900
    d.rectangle([px0, py0 - 12, px1, py0 + 26], fill=(120, 92, 60))  # lumpur
    # air 15 cm di atas lumpur
    d.rectangle([px0, py0 - 12 - 18, px1, py0 - 12], fill=AIR)
    # pematang: 2 trapesium 0,6 m lebar, 0,4 m tinggi
    for mx0 in (px0 + 40, px1 - 40 - int(0.6 * ps)):
        d.polygon([(mx0, py0 - 12), (mx0 + 8, py0 - 12 - 48), (mx0 + int(0.6 * ps) - 8, py0 - 12 - 48),
                   (mx0 + int(0.6 * ps), py0 - 12)], fill=TANAH, outline=JATI_TUA)
    # padi 0,5 m di atas lumpur
    for px in range(px0 + 110, px1 - 100, 34):
        d.line([(px, py0 - 12), (px - 9, py0 - 12 - 60)], fill=HIJAU_DAUN, width=4)
        d.line([(px, py0 - 12), (px + 9, py0 - 12 - 60)], fill=HIJAU_DAUN, width=4)
        d.line([(px, py0 - 12), (px, py0 - 12 - 66)], fill=(90, 154, 74), width=4)
    text_c(d, (px0 + px1) // 2, 795, "POTONGAN — air 15 cm, padi 50 cm, pematang 40 cm", 22, color=TINTA)
    dim_v(d, px0 - 26, py0 - 30, py0 - 12, "15 cm")
    dim_v(d, px1 + 26, py0 - 78, py0 - 12, "50 cm")
    palette_strip(d, 1215, [
        ("Air", "#A8C8B8", AIR), ("Padi", "#2E7D5B", HIJAU_DAUN),
        ("Pematang", "#8A6D4B", TANAH), ("Lumpur", "#785C3C", (120, 92, 60)),
    ])
    notes_box(d, 1335, [
        "4 petak @ ±9,4 × 5,4 m, dipisah pematang tanah 60 cm (bisa jalan).",
        "Air 15 cm, padi hijau muda berbaris rapat (±0,5 m antar rumpun).",
        "Saluran air di sisi utara; pematang luar 60 cm keliling.",
        "Letak di peta: barat kampus putra (sesuai tata letak v2).",
    ])
    img.save(f"{OUT}/lingkungan-03-sawah.png")
    print("OK lingkungan-03-sawah.png")

# ======================================================================
# 04 — PAGAR
# ======================================================================
def lembar_pagar():
    img, d = sheet("04 — PAGAR", "Pagar pembatas — 2 varian (bambu & bata rendah)", "04")
    s = 110
    # --- Varian A: pagar bambu, tinggi 1,5 m, tiang tiap 2 m ---
    ax0, ax1 = 320, 760
    agy = 660
    # bilah bambu vertikal tiap 0,18 m
    for bx in range(ax0 + 8, ax1 - 8, 20):
        d.rectangle([bx, agy - int(1.5 * s), bx + 10, agy], fill=BAMBU, outline=BAMBU_TUA, width=1)
    # 2 rel horizontal jati
    for ry in (agy - int(0.5 * s), agy - int(1.1 * s)):
        d.rectangle([ax0, ry - 5, ax1, ry + 5], fill=JATI)
    # tiang tiap 2 m
    for tx in (ax0, 540, ax1):
        d.rectangle([tx - 7, agy - int(1.6 * s), tx + 7, agy], fill=JATI_TUA)
        d.polygon([(tx - 9, agy - int(1.6 * s)), (tx + 9, agy - int(1.6 * s)), (tx, agy - int(1.6 * s) - 16)],
                  fill=JATI_TUA)
    ground(d, agy, ax0 - 40, ax1 + 40)
    dim_v(d, ax0 - 40, agy - int(1.5 * s), agy, "1,5 m")
    dim_h(d, ax0, 540, agy + 44, "tiang 2 m")
    text_c(d, (ax0 + ax1) // 2, agy - int(1.5 * s) - 46, "A — Pagar bambu", 26, color=TINTA)
    # --- Varian B: bata rendah krem + lis emas, tinggi 0,9 m ---
    bx0, bx1 = 320, 760
    bgy = 1150
    d.rectangle([bx0, bgy - int(0.9 * s), bx1, bgy], fill=KREM, outline=TINTA, width=3)
    # garis bata: horizontal tiap 14 px, vertikal selang-seling tiap 36 px
    for yy in range(bgy - int(0.9 * s) + 14, bgy - 4, 14):
        d.line([(bx0, yy), (bx1, yy)], fill=(200, 190, 170), width=2)
    row = 0
    for yy in range(bgy - int(0.9 * s) + 14, bgy - 4, 14):
        off = 18 if row % 2 == 0 else 0
        for xx in range(bx0 + off, bx1 - 4, 36):
            d.line([(xx, yy), (xx, yy + 14)], fill=(200, 190, 170), width=2)
        row += 1
    # lis emas di atas
    d.rectangle([bx0 - 4, bgy - int(0.9 * s) - 10, bx1 + 4, bgy - int(0.9 * s)], fill=EMAS)
    # pilar tiap 2 m + tutup emas
    for tx in (bx0, 540, bx1):
        d.rectangle([tx - 14, bgy - int(1.1 * s), tx + 14, bgy], fill=KREM, outline=TINTA, width=2)
        d.polygon([(tx - 17, bgy - int(1.1 * s)), (tx + 17, bgy - int(1.1 * s)), (tx, bgy - int(1.1 * s) - 20)],
                  fill=EMAS)
    ground(d, bgy, bx0 - 40, bx1 + 40)
    dim_v(d, bx0 - 40, bgy - int(0.9 * s), bgy, "0,9 m")
    dim_h(d, bx0, 540, bgy + 44, "pilar 2 m")
    text_c(d, (bx0 + bx1) // 2, bgy - int(1.1 * s) - 66, "B — Pagar bata rendah + lis emas", 26, color=TINTA)
    palette_strip(d, 1215, [
        ("Bambu", "#D9B36A", BAMBU), ("Jati", "#7B4B2A", JATI),
        ("Krem", "#F2EAD6", KREM), ("Emas", "#C9A227", EMAS),
    ])
    notes_box(d, 1335, [
        "Varian A (bambu): batas kebun / sawah / belakang pesantren.",
        "Varian B (bata + lis emas): batas halaman — serasi tembok putri.",
        "Tiang/pilar tiap 2 m; bilah bambu 9 cm, jarak 18 cm.",
        "Tinggi A 1,5 m (menghalangi pandang), B 0,9 m (rendah, terbuka).",
    ])
    img.save(f"{OUT}/lingkungan-04-pagar.png")
    print("OK lingkungan-04-pagar.png")

# ======================================================================
# 05 — GUBUK SANTRI (rumah panggung)
# ======================================================================
def lembar_gubuk():
    img, d = sheet("05 — GUBUK SANTRI", "Rumah panggung kayu 4 × 3 m — depan + samping + denah", "05")
    s = 80
    # --- denah (kiri), skala 60 px/m ---
    ds = 60
    dx0, dy0 = 70, 760
    dw, dh = 4 * ds, 3 * ds  # 240 x 180
    d.rectangle([dx0, dy0, dx0 + dw, dy0 + dh], fill=KREM_MUDA, outline=TINTA, width=4)
    # dinding dalam (lantai papan): garis-garis papan
    for xx in range(dx0 + 30, dx0 + dw, 30):
        d.line([(xx, dy0), (xx, dy0 + dh)], fill=(220, 210, 185), width=2)
    # pintu (sisi selatan/bawah) + jendela (sisi barat/kiri)
    d.rectangle([dx0 + 100, dy0 + dh - 6, dx0 + 154, dy0 + dh + 6], fill=PUTIH, outline=JATI_TUA, width=3)
    d.rectangle([dx0 - 6, dy0 + 60, dx0 + 6, dy0 + 120], fill=PUTIH, outline=JATI_TUA, width=3)
    # tangga di depan pintu
    for i in range(5):
        d.rectangle([dx0 + 100 + i * 2, dy0 + dh + 8 + i * 10, dx0 + 154 - i * 2, dy0 + dh + 16 + i * 10],
                    fill=BATU, outline=JATI_TUA, width=1)
    # 2 tikar tidur + rak kecil
    d.rectangle([dx0 + 20, dy0 + 20, dx0 + 100, dy0 + 70], fill=(168, 198, 134), outline=RUMPUT_TUA, width=2)
    d.rectangle([dx0 + 20, dy0 + 95, dx0 + 100, dy0 + 145], fill=(168, 198, 134), outline=RUMPUT_TUA, width=2)
    d.rectangle([dx0 + 190, dy0 + 20, dx0 + 225, dy0 + 90], fill=JATI, outline=JATI_TUA, width=2)
    text_c(d, dx0 + 60, dy0 + 40, "tikar", 16, color=TINTA, bold=False)
    text_c(d, dx0 + 60, dy0 + 115, "tikar", 16, color=TINTA, bold=False)
    text_c(d, dx0 + 207, dy0 + 48, "rak", 16, color=KREM_MUDA, bold=False)
    text_c(d, dx0 + dw / 2, 700, "DENAH 4 × 3 m", 22, color=TINTA)
    dim_h(d, dx0, dx0 + dw, 660, "4 m")
    # (kedalaman 3 m tertulis di judul denah — garis dimensinya dihapus
    # supaya tidak menabrak dinding tampak depan)
    # --- tampak depan (tengah), skala 80 px/m ---
    fx0, fx1 = 380, 700  # lebar 4 m
    fgy = 1000
    fcx = 540
    # tiang (3 tampak depan) + silang kolong
    for tx in (fx0 + 14, fcx, fx1 - 14):
        d.rectangle([tx - 7, fgy - int(1.2 * s), tx + 7, fgy], fill=JATI_TUA)
    d.line([(fx0 + 14, fgy), (fcx, fgy - int(1.2 * s))], fill=JATI_TUA, width=5)
    d.line([(fcx, fgy - int(1.2 * s)), (fx1 - 14, fgy)], fill=JATI_TUA, width=5)
    # lantai
    d.rectangle([fx0, fgy - int(1.2 * s) - 12, fx1, fgy - int(1.2 * s)], fill=JATI)
    # dinding 2,2 m
    wy0 = fgy - int(1.2 * s) - 12 - int(2.2 * s)
    d.rectangle([fx0, wy0, fx1, fgy - int(1.2 * s) - 12], fill=JATI, outline=JATI_TUA, width=3)
    for xx in range(fx0 + 20, fx1, 20):
        d.line([(xx, wy0), (xx, fgy - int(1.2 * s) - 12)], fill=JATI_TUA, width=2)
    # pintu (kanan) + jendela (kiri)
    d.rectangle([600, fgy - int(1.2 * s) - 12 - int(1.8 * s), 664, fgy - int(1.2 * s) - 12],
                fill=JATI_TUA, outline=EMAS, width=2)
    d.ellipse([656, fgy - int(1.2 * s) - 12 - int(0.9 * s), 662, fgy - int(1.2 * s) - 12 - int(0.9 * s) + 6],
              fill=EMAS)
    d.rectangle([410, wy0 + 46, 486, wy0 + 46 + int(0.8 * s)], fill=KREM_MUDA, outline=JATI_TUA, width=3)
    d.line([(448, wy0 + 46), (448, wy0 + 46 + int(0.8 * s))], fill=JATI_TUA, width=3)
    d.line([(410, wy0 + 46 + int(0.4 * s)), (486, wy0 + 46 + int(0.4 * s))], fill=JATI_TUA, width=3)
    # atap pelana zamrud tua + lis emas bubungan
    apex_y = wy0 - int(1.1 * s)
    d.polygon([(fx0 - 32, wy0), (fx1 + 32, wy0), (fcx, apex_y)], fill=ZAMRUD_TUA)
    d.polygon([(fcx - 16, apex_y), (fcx + 16, apex_y), (fcx, apex_y - 14)], fill=EMAS)
    d.line([(fx0 - 32, wy0), (fx1 + 32, wy0)], fill=EMAS, width=4)
    # tangga depan (kiri, 5 anak tangga)
    stx0 = fx0 + 6
    for i in range(5):
        d.rectangle([stx0 + i * 14, fgy - (i + 1) * 23, stx0 + 90, fgy - i * 23],
                    fill=BATU, outline=JATI_TUA, width=2)
    ground(d, fgy, fx0 - 60, fx1 + 60)
    dim_h(d, fx0, fx1, fgy + 44, "4 m")
    dim_v(d, fx0 - 34, fgy - int(1.2 * s), fgy, "1,2 m")
    # (tinggi total ±4,5 m tertulis di judul tampak depan — garis dimensinya
    # dihapus supaya tidak menabrak tampak samping)
    text_c(d, fcx, apex_y - 78, "TAMPAK DEPAN (±4,5 m)", 22, color=TINTA)
    # --- tampak samping (kanan), skala 80 px/m ---
    sx0, sx1 = 800, 800 + int(3 * s)  # dalam 3 m
    d.rectangle([sx0, fgy - int(1.2 * s) - 12 - int(2.2 * s), sx1, fgy - int(1.2 * s) - 12],
                fill=JATI, outline=JATI_TUA, width=3)
    d.rectangle([sx0, fgy - int(1.2 * s) - 12, sx1, fgy - int(1.2 * s)], fill=JATI)
    for tx in (sx0 + 10, (sx0 + sx1) // 2, sx1 - 10):
        d.rectangle([tx - 7, fgy - int(1.2 * s), tx + 7, fgy], fill=JATI_TUA)
    d.polygon([(sx0 - 24, wy0), (sx1 + 24, wy0), ((sx0 + sx1) // 2, apex_y)], fill=ZAMRUD_TUA)
    d.polygon([((sx0 + sx1) // 2 - 14, apex_y), ((sx0 + sx1) // 2 + 14, apex_y),
               ((sx0 + sx1) // 2, apex_y - 12)], fill=EMAS)
    ground(d, fgy, sx0 - 30, sx1 + 30)
    dim_h(d, sx0, sx1, fgy + 44, "3 m")
    text_c(d, (sx0 + sx1) // 2, apex_y - 78, "TAMPAK SAMPING", 22, color=TINTA)
    palette_strip(d, 1215, [
        ("Jati", "#7B4B2A", JATI), ("Jati tua", "#4A2E18", JATI_TUA),
        ("Atap", "#044230", ZAMRUD_TUA), ("Emas", "#C9A227", EMAS),
        ("Krem", "#F2EAD6", KREM),
    ])
    notes_box(d, 1335, [
        "6 tiang jati, kolong 1,2 m (simpan kayu bakar / perkakas).",
        "Lantai + dinding papan jati; atap pelana zamrud + lis emas.",
        "Tangga kayu 5 anak tangga di depan; beranda 1 m di depan pintu.",
        "Muat 2–3 santri tidur (tikar) / 4–5 mengaji lesehan.",
    ])
    img.save(f"{OUT}/lingkungan-05-gubuk.png")
    print("OK lingkungan-05-gubuk.png")

if __name__ == "__main__":
    lembar_pohon()
    lembar_taman()
    lembar_sawah()
    lembar_pagar()
    lembar_gubuk()
    print("SELESAI 5 lembar konsep lingkungan")
