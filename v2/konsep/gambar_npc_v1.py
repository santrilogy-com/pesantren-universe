#!/usr/bin/env python3
"""Visual konsep sistem NPC v1 — Laras, 19 Nov 2026 (revisi gambar).
3 gambar: (1) peta zona 50 NPC, (2) variasi wajah, (3) pose hormat.
Skema, bukan skala. Palet resmi PV.
"""
from PIL import Image, ImageDraw, ImageFont
import os, random

OUT = os.path.expanduser("~/workspace/pesantren-verse/v2/konsep")
FONT = os.path.expanduser("~/workspace/pesantren-verse/v2/godot-dunia/fonts/Baloo2-Variable.ttf")
FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

def font(sz):
    for p in (FONT, FALLBACK):
        try:
            return ImageFont.truetype(p, sz)
        except Exception:
            pass
    return ImageFont.load_default()

def mtext(d, xy, text, f, fill):
    """Teks multi-baris rata tengah."""
    lines = text.split("\n")
    lh = int(f.size * 1.25)
    for i, ln in enumerate(lines):
        d.text((xy[0], xy[1] + i * lh), ln, font=f, fill=fill, anchor="mt")

KREM = (242, 234, 214)
KREM2 = (250, 246, 236)
ZAMRUD = (6, 95, 70)
ZAMRUD_G = (4, 59, 44)
EMAS = (201, 162, 39)
JATI = (123, 75, 42)
BATU = (184, 178, 164)
HITAM = (35, 40, 46)
KULIT_T = (255, 192, 159)
KULIT_S = (198, 142, 94)
KULIT_G = (138, 90, 51)
ABU = (90, 90, 90)
MERAH = (122, 31, 31)

# ---------------------------------------------------------------- 1. PETA ZONA
def peta_zona():
    W, H = 1280, 820
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 14), "PETA ZONA — 50 NPC BARU  (skema, bukan skala)", font=font(30), fill=ZAMRUD_G)
    d.text((24, 52), "Putra 25 (kiri)  •  Putri 25 (kanan)  •  Tembok x=14 memisahkan — NPC tidak pernah menyeberang",
           font=font(20), fill=ABU)
    px0, py0, pw, ph = 24, 92, 600, 640
    qx0, qy0, qw, qh = 656, 92, 600, 640
    ZMIN, ZMAX = -40.0, 45.0
    for (x0, y0, w, h, judul, sub) in [
            (px0, py0, pw, ph, "ZONA PUTRA — 25 NPC", "x −70..14  •  z −40..45  •  utara = atas (−z)"),
            (qx0, qy0, qw, qh, "ZONA PUTRI — 25 NPC", "x 115..216  •  z −40..45  •  utara = atas (−z)")]:
        d.rounded_rectangle([x0, y0, x0 + w, y0 + h], radius=14, outline=ZAMRUD, width=3)
        d.text((x0 + 14, y0 + 8), judul, font=font(24), fill=ZAMRUD_G)
        d.text((x0 + 14, y0 + 38), sub, font=font(16), fill=ABU)

    def m_putra(x, z):
        return (px0 + 20 + (x + 70) / 84.0 * (pw - 40),
                py0 + 70 + (z - ZMIN) / (ZMAX - ZMIN) * (ph - 90))
    def m_putri(x, z):
        return (qx0 + 20 + (x - 115) / 101.0 * (qw - 40),
                qy0 + 70 + (z - ZMIN) / (ZMAX - ZMIN) * (qh - 90))

    def di_dalam(x, z, rects):
        return any(rx1 <= x <= rx2 and rz1 <= z <= rz2 for (rx1, rz1, rx2, rz2) in rects)

    def zona(m, x1, z1, x2, z2, label, n, halangan):
        a, b = m(x1, z1), m(x2, z2)
        d.rounded_rectangle([a[0], a[1], b[0], b[1]], radius=10, outline=EMAS, width=2)
        d.text((a[0] + 4, b[1] + 6), label, font=font(15), fill=ZAMRUD_G)
        r = random.Random(hash(label))
        placed = 0
        tries = 0
        while placed < n and tries < 200:
            tries += 1
            x = x1 + 1.5 + r.random() * max(1, (x2 - x1 - 3))
            z = z1 + 1.5 + r.random() * max(1, (z2 - z1 - 3))
            if di_dalam(x, z, halangan):
                continue
            cx, cy = m(x, z)
            d.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=ZAMRUD)
            placed += 1

    def gedung(m, x1, z1, x2, z2, nama):
        a, b = m(x1, z1), m(x2, z2)
        d.rectangle([a[0], a[1], b[0], b[1]], fill=JATI, outline=ZAMRUD_G, width=2)
        f = font(15)
        tw = d.textlength(nama, font=f)
        if tw <= (b[0] - a[0] - 4):
            d.text(((a[0] + b[0]) / 2, (a[1] + b[1]) / 2), nama, font=f,
                   fill=(255, 255, 255), anchor="mm")
        else:
            d.text(((a[0] + b[0]) / 2, b[1] + 4), nama, font=font(13),
                   fill=ZAMRUD_G, anchor="mt")

    def titik(m, x, z, label, warna=MERAH, bawah=False):
        cx, cy = m(x, z)
        d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=warna, outline=(255, 255, 255), width=1)
        if bawah:
            d.text((cx, cy + 8), label, font=font(14), fill=warna, anchor="mt")
        else:
            d.text((cx + 8, cy - 8), label, font=font(14), fill=warna)

    # --- PUTRA (tapak yang dihindari: Surau, Cangkruk, Asrama)
    hal_putra = [(-8, -24, 8, -4), (-25, -21, -19, -15), (-34.7, 4, -13.2, 16)]
    zona(m_putra, -8, -2, 8, 14, "Plaza Surau · 8", 8, hal_putra)
    zona(m_putra, -32, -24, -14, 16, "Hal. Asrama–Cangkruk · 6", 6, hal_putra)
    zona(m_putra, -8, 22, 8, 34, "Taman selatan · 6", 6, hal_putra)
    zona(m_putra, -60, 0, -30, 40, "Jalur barat/sawah · 5", 5, hal_putra)
    gedung(m_putra, -8, -24, 8, -4, "SURAU")
    gedung(m_putra, -25, -21, -19, -15, "Cangkruk")
    gedung(m_putra, -34.7, 4, -13.2, 16, "Asrama")
    a, b = m_putra(14, -38), m_putra(14, 16)
    d.line([a[0], a[1], b[0], b[1]], fill=HITAM, width=5)
    d.text((a[0] - 8, a[1] + 2), "TEMBOK x=14", font=font(14), fill=HITAM, anchor="ra")
    titik(m_putra, 0, 26, "Peti", bawah=True)
    titik(m_putra, -3, 25.4, "1", EMAS)
    titik(m_putra, 3.45, 28.2, "2", EMAS)
    titik(m_putra, -4, 14, "Spawn", ZAMRUD)
    # --- PUTRI
    hal_putri = [(128, -29, 140, -19), (126, -4, 134, 14), (144, 3, 166, 15),
                 (144, -37, 152, -29), (148, -16, 156, -8), (162, -16, 170, -8), (173, -23, 179, -17)]
    zona(m_putri, 126, -32, 142, -16, "Hal. Musholla · 8", 8, hal_putri)
    zona(m_putri, 124, -4, 138, 14, "Hal. Kelas–Madrasah · 6", 6, hal_putri)
    zona(m_putri, 117, 28, 127, 36, "Taman Putri · 6", 6, hal_putri)
    zona(m_putri, 146, 14, 164, 28, "Hal. Asrama Putri · 5", 5, hal_putri)
    gedung(m_putri, 128, -29, 140, -19, "Musholla")
    gedung(m_putri, 126, -4, 134, 14, "Kelas")
    gedung(m_putri, 144, 3, 166, 15, "Asrama")
    gedung(m_putri, 144, -37, 152, -29, "Kantor")
    gedung(m_putri, 148, -16, 156, -8, "Madrasah")
    gedung(m_putri, 162, -16, 170, -8, "Studio")
    gedung(m_putri, 173, -23, 179, -17, "Pos Jaga")
    titik(m_putri, 122, 30.4, "U", EMAS)
    titik(m_putri, 122, 33.6, "S", EMAS)
    titik(m_putri, 140, 16, "Spawn", ZAMRUD)
    d.text((24, 748), "Aturan: waypoint di dalam sub-zona saja  •  segmen divalidasi vs tapak bangunan  •  interior hanya lewat teleport",
           font=font(18), fill=ABU)
    d.text((24, 776), "Kyai/Ustadzah patroli tetap seperti sekarang (bukan bagian 50 NPC baru).",
           font=font(18), fill=ABU)
    img.save(f"{OUT}/konsep-npc-50-zona-v1.png")

# ---------------------------------------------------------------- 2. WAJAH
def wajah():
    W, H = 1280, 840
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 14), "VARIASI WAJAH — 1.728 kombinasi per gender  (RNG berseed, wajah tetap tiap login)",
           font=font(28), fill=ZAMRUD_G)
    d.text((24, 50), "Sumbu: kulit × jarak mata × ukuran mata × kacamata × peci/jilbab × warna baju — contoh 8 dari ribuan",
           font=font(19), fill=ABU)

    def kepala(cx, cy, r, kulit, peci=None, jilbab=None, kacamata=False,
                jarak=0.32, ukuran=1.0, alis="lurus", label=""):
        d.ellipse([cx - r * 1.15, cy + r * 1.15, cx + r * 1.15, cy + r * 2.45], fill=(228, 228, 228))
        if jilbab:
            d.ellipse([cx - r * 1.25, cy - r * 1.35, cx + r * 1.25, cy + r * 1.1], fill=jilbab, outline=BATU, width=2)
            d.ellipse([cx - r * 0.72, cy - r * 0.55, cx + r * 0.72, cy + r * 0.95], fill=kulit)
        else:
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=kulit)
        er = r * 0.11 * ukuran
        ex = r * jarak
        ey = cy + r * 0.05
        for sx in (-1, 1):
            d.ellipse([cx + sx * ex - er, ey - er * 1.25, cx + sx * ex + er, ey + er * 1.25], fill=(42, 32, 24))
            ay = ey - r * 0.30
            if alis == "lurus":
                d.line([cx + sx * ex - er * 1.3, ay, cx + sx * ex + er * 1.3, ay], fill=(42, 32, 24), width=4)
            elif alis == "miring":
                off = 4 if sx < 0 else -4
                d.line([cx + sx * ex - er * 1.3, ay - off,
                        cx + sx * ex + er * 1.3, ay + off], fill=(42, 32, 24), width=4)
            else:  # naik
                d.arc([cx + sx * ex - er * 1.4, ay - 8, cx + sx * ex + er * 1.4, ay + 8],
                      200, 340, fill=(42, 32, 24), width=4)
        d.ellipse([cx - r * 0.06, ey + r * 0.22, cx + r * 0.06, ey + r * 0.38], fill=(42, 32, 24))
        d.arc([cx - r * 0.28, ey + r * 0.45, cx + r * 0.28, ey + r * 0.85], 20, 160, fill=(42, 32, 24), width=4)
        if kacamata:
            for sx in (-1, 1):
                d.ellipse([cx + sx * ex - er * 2.0, ey - er * 1.9, cx + sx * ex + er * 2.0, ey + er * 1.9],
                          outline=(30, 30, 30), width=4)
            d.line([cx - ex, ey, cx + ex, ey], fill=(30, 30, 30), width=3)
        if peci == "putih":
            d.pieslice([cx - r * 1.02, cy - r * 1.75, cx + r * 1.02, cy + r * 0.1], 180, 360,
                       fill=(250, 247, 240), outline=BATU, width=2)
            d.rectangle([cx - r * 1.02, cy - r * 0.55, cx + r * 1.02, cy - r * 0.38], fill=(220, 216, 205))
        elif peci == "hitam":
            d.polygon([(cx - r * 0.95, cy - r * 0.45), (cx - r * 0.85, cy - r * 1.25),
                       (cx + r * 0.85, cy - r * 1.25), (cx + r * 0.95, cy - r * 0.45)], fill=(26, 26, 26))
            d.rectangle([cx - r * 0.95, cy - r * 0.5, cx + r * 0.95, cy - r * 0.38], fill=(10, 10, 10))
        mtext(d, (cx, cy + r * 2.75), label, font(17), ZAMRUD_G)

    xs = [160, 480, 800, 1120]
    y1, y2 = 220, 520
    d.text((24, 130), "PUTRA", font=font(22), fill=ZAMRUD_G)
    kepala(xs[0], y1, 58, KULIT_T, peci="putih", label="Putra A\npeci putih · terang")
    kepala(xs[1], y1, 58, KULIT_G, peci="hitam", kacamata=True, label="Putra B\npeci hitam · gelap · kacamata")
    kepala(xs[2], y1, 58, KULIT_S, peci="putih", jarak=0.42, ukuran=1.25, label="Putra C\nmata lebar · besar")
    kepala(xs[3], y1, 58, KULIT_T, peci="hitam", jarak=0.24, ukuran=0.85, alis="miring", label="Putra D\nmata rapat · alis miring")
    d.text((24, 445), "PUTRI", font=font(22), fill=ZAMRUD_G)
    kepala(xs[0], y2, 58, KULIT_T, jilbab=(242, 234, 214), label="Putri A\njilbab krem · terang")
    kepala(xs[1], y2, 58, KULIT_S, jilbab=(35, 40, 46), label="Putri B\njilbab hitam · sawo matang")
    kepala(xs[2], y2, 58, KULIT_G, jilbab=ZAMRUD, kacamata=True, label="Putri C\njilbab zamrud · kacamata")
    kepala(xs[3], y2, 58, KULIT_T, jilbab=(90, 58, 34), jarak=0.42, alis="naik", label="Putri D\njilbab coklat · mata lebar")
    d.text((24, 790), "Catatan: model peci hitam nasional mengikuti konsep Kirana (item 2) — desain ini hanya memakainya sebagai pilihan.",
           font=font(17), fill=ABU)
    img.save(f"{OUT}/konsep-npc-wajah-v1.png")

# ---------------------------------------------------------------- 3. HORMAT
def hormat():
    W, H = 1280, 700
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 14), "HORMAT — DUA VARIAN  (aturan: jalan → A, diam/duduk → B)",
           font=font(28), fill=ZAMRUD_G)

    def figur(cx, cy, s, kulit, baju, peci=None, pose="berdiri"):
        d.line([cx - 8 * s, cy, cx - 8 * s, cy - 55 * s], fill=(42, 32, 24), width=max(3, int(7 * s)))
        d.line([cx + 8 * s, cy, cx + 8 * s, cy - 55 * s], fill=(42, 32, 24), width=max(3, int(7 * s)))
        d.polygon([(cx - 22 * s, cy - 55 * s), (cx + 22 * s, cy - 55 * s),
                   (cx + 26 * s, cy - 5 * s), (cx - 26 * s, cy - 5 * s)], fill=(0, 128, 98))
        d.line([cx, cy - 55 * s, cx, cy - 105 * s], fill=baju, width=max(4, int(16 * s)))
        hx, hy = cx, cy - 125 * s
        if pose == "nunduk":
            hx, hy = cx + 10 * s, cy - 120 * s
            d.line([cx, cy - 105 * s, hx, hy + 12 * s], fill=kulit, width=max(3, int(10 * s)))
        d.ellipse([hx - 16 * s, hy - 16 * s, hx + 16 * s, hy + 16 * s], fill=kulit)
        if peci == "putih":
            d.pieslice([hx - 17 * s, hy - 30 * s, hx + 17 * s, hy + 2 * s], 180, 360, fill=(250, 247, 240), outline=BATU, width=2)
        elif peci == "hitam":
            d.polygon([(hx - 16 * s, hy - 6 * s), (hx - 14 * s, hy - 28 * s),
                       (hx + 14 * s, hy - 28 * s), (hx + 16 * s, hy - 6 * s)], fill=(26, 26, 26))
        elif peci == "serban":
            d.ellipse([hx - 20 * s, hy - 24 * s, hx + 20 * s, hy + 6 * s], fill=(245, 240, 224), outline=BATU, width=2)
            d.ellipse([hx - 12 * s, hy - 8 * s, hx + 12 * s, hy + 14 * s], fill=kulit)
            d.ellipse([hx - 10 * s, hy + 8 * s, hx + 10 * s, hy + 20 * s], fill=(43, 36, 29))
        return (hx, hy)

    def lengan(cx, cy, s, pose, arah=1):
        bx, by = cx, cy - 100 * s
        if pose == "silang":
            d.line([bx - 10 * s, by, cx + 14 * s, by + 22 * s], fill=KULIT_T, width=6)
            d.line([bx + 10 * s, by, cx - 14 * s, by + 22 * s], fill=KULIT_T, width=6)
        elif pose == "ulur":
            d.line([bx + arah * 10 * s, by, cx + arah * 42 * s, by + 6 * s], fill=KULIT_T, width=6)
        elif pose == "cium":
            d.line([bx + arah * 10 * s, by, cx + arah * 26 * s, by - 28 * s], fill=KULIT_T, width=6)
        else:
            d.line([bx - 10 * s, by, bx - 14 * s, by + 34 * s], fill=KULIT_T, width=6)
            d.line([bx + 10 * s, by, bx + 14 * s, by + 34 * s], fill=KULIT_T, width=6)

    # ---- Panel A
    d.rounded_rectangle([24, 60, 620, 640], radius=14, outline=ZAMRUD, width=3)
    d.text((44, 76), "A — MINGGIR + NUNDUK", font=font(24), fill=ZAMRUD_G)
    d.text((44, 108), "NPC sedang JALAN · guru lewat · ±3 detik", font=font(18), fill=ABU)
    d.line([90, 280, 560, 280], fill=BATU, width=4)
    d.polygon([(560, 272), (580, 280), (560, 288)], fill=BATU)
    d.text((300, 292), "jalur guru →", font=font(16), fill=ABU, anchor="mt")
    # panah minggir (putus-putus) dari jalur ke NPC
    for yy in range(300, 420, 18):
        d.line([200, yy, 200, yy + 9], fill=EMAS, width=3)
    d.polygon([(192, 424), (208, 424), (200, 438)], fill=EMAS)
    figur(430, 470, 1.0, KULIT_S, (232, 232, 232), peci="serban", pose="berdiri")
    lengan(430, 470, 1.0, "berdiri")
    d.text((430, 490), "Kyai lewat", font=font(17), fill=ZAMRUD_G, anchor="mt")
    figur(200, 540, 1.0, KULIT_T, (232, 232, 232), peci="putih", pose="nunduk")
    lengan(200, 540, 1.0, "silang")
    mtext(d, (200, 560), "NPC minggir 1 m\nnunduk + tangan silang", font(17), ZAMRUD_G)
    d.text((44, 612), "Tahan 3 detik → lanjut jalan.", font=font(17), fill=ABU)

    # ---- Panel B
    d.rounded_rectangle([660, 60, 1256, 640], radius=14, outline=ZAMRUD, width=3)
    d.text((680, 76), "B — HAMPIRI + SALAMAN + CIUM TANGAN", font=font(24), fill=ZAMRUD_G)
    d.text((680, 108), "NPC sedang DIAM/DUDUK · guru bebas · ±4 detik + jalan", font=font(18), fill=ABU)
    figur(1090, 420, 1.0, KULIT_S, (242, 234, 214), peci="serban", pose="berdiri")
    lengan(1090, 420, 1.0, "ulur", arah=-1)
    mtext(d, (1090, 440), "Kyai (berhenti)", font(17), ZAMRUD_G)
    figur(950, 420, 1.0, KULIT_T, (232, 232, 232), peci="hitam", pose="berdiri")
    lengan(950, 420, 1.0, "ulur", arah=1)
    mtext(d, (950, 440), "NPC salaman\ntangan kanan · 2 detik", font(17), ZAMRUD_G)
    d.text((1020, 300), "jabat", font=font(16), fill=EMAS, anchor="mt")
    figur(790, 540, 0.8, KULIT_T, (232, 232, 232), peci="hitam", pose="berdiri")
    lengan(790, 540, 0.8, "cium", arah=1)
    mtext(d, (790, 560), "lalu cium tangan\n1,5 detik → kembali", font(17), ZAMRUD_G)
    d.text((680, 612), "Satu guru = satu salaman. Antre maks 3 — sisanya varian A.",
           font=font(17), fill=ABU)
    d.text((24, 662), "Yang dihormati: Kyai, Ustadzah Mariyah, Ust. Sanusi, Ustzh. Fatimah. Bukan: Bilal/Faris, Satpam/Penjaga, pemain.",
           font=font(17), fill=ABU)
    img.save(f"{OUT}/konsep-npc-hormat-v1.png")

peta_zona()
wajah()
hormat()
print("selesai")
