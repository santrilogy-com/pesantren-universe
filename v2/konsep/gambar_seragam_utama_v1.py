#!/usr/bin/env python3
"""Mockup seragam utama v1 — Kirana, 19 Nov 2026.
Putra: baju putih + sarung hijau garis kuning tipis VERTIKAL.
Putri: baju biru langit + sarung batik (tekstur asli tekstur-batik-putri-v1.png).
Gaya gambar mengikuti gambar_npc_v1.py (figur datar, palet resmi PV).
Output: konsep-seragam-utama-v1.png (depan + detail) dan
        konsep-seragam-utama-samping-v1.png (profil).
"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.expanduser("~/workspace/pesantren-verse/v2/konsep")
FONT = os.path.expanduser("~/workspace/pesantren-verse/v2/godot-dunia/fonts/Baloo2-Variable.ttf")
FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
BATIK = f"{OUT}/tekstur-batik-putri-v1.png"


def font(sz):
    for p in (FONT, FALLBACK):
        try:
            return ImageFont.truetype(p, sz)
        except Exception:
            pass
    return ImageFont.load_default()


def mtext(d, xy, text, f, fill):
    lines = text.split("\n")
    lh = int(f.size * 1.25)
    for i, ln in enumerate(lines):
        d.text((xy[0], xy[1] + i * lh), ln, font=f, fill=fill, anchor="mt")


KREM2 = (250, 246, 236)
ZAMRUD = (6, 95, 70)
ZAMRUD_G = (4, 59, 44)
EMAS = (201, 162, 39)
JATI = (123, 75, 42)
BATU = (184, 178, 164)
ABU = (90, 90, 90)
KULIT = (255, 192, 159)
GELAP = (42, 32, 24)
PUTIH_BAJU = (245, 243, 238)   # putih (digambar sedikit krem supaya bayangan terbaca)
HIJAU_SARUNG = (0, 128, 98)    # #008062 — hijau sarung santri sekarang
HIJAU_HEM = (6, 95, 70)        # #065F46 hem
LANGIT = (135, 206, 235)       # #87CEEB biru langit (baju putri)
LANGIT_GELAP = (127, 184, 224) # #7FB8E0 jilbab (sedikit lebih dalam dari baju)
LANGIT_OUT = (94, 147, 184)    # outline baju putri

FW, FH = 420, 760  # ukuran layer figur


def wajah(d, cx, cy, r):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=KULIT)
    er, ex, ey = r * 0.11, r * 0.32, cy + r * 0.05
    for sx in (-1, 1):
        d.ellipse([cx + sx * ex - er, ey - er * 1.25, cx + sx * ex + er, ey + er * 1.25], fill=GELAP)
        ay = ey - r * 0.30
        d.line([cx + sx * ex - er * 1.3, ay, cx + sx * ex + er * 1.3, ay], fill=GELAP, width=4)
    d.ellipse([cx - r * 0.06, ey + r * 0.22, cx + r * 0.06, ey + r * 0.38], fill=GELAP)
    d.arc([cx - r * 0.28, ey + r * 0.45, cx + r * 0.28, ey + r * 0.85], 20, 160, fill=GELAP, width=4)


def kaki(d, cx):
    for sx in (-1, 1):
        d.ellipse([cx + sx * 45 - 16, 692, cx + sx * 45 + 16, 714], fill=KULIT)
        d.rounded_rectangle([cx + sx * 45 - 22, 706, cx + sx * 45 + 22, 724],
                            radius=6, fill=JATI, outline=(90, 58, 34), width=2)


def figur_putra():
    lay = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    cx, cy, r = 210, 130, 56
    # --- koko putih ---
    d.polygon([(cx - 78, 215), (cx + 78, 215), (cx + 88, 470), (cx - 88, 470)],
              fill=PUTIH_BAJU, outline=(201, 194, 178), width=2)
    # lengan + tangan
    for sx in (-1, 1):
        d.line([cx + sx * 82, 240, cx + sx * 92, 452], fill=PUTIH_BAJU, width=26)
        d.line([cx + sx * 82, 240, cx + sx * 92, 452], fill=(201, 194, 178), width=26)
        d.line([cx + sx * 82, 240, cx + sx * 92, 452], fill=PUTIH_BAJU, width=22)
        d.ellipse([cx + sx * 92 - 13, 452, cx + sx * 92 + 13, 478], fill=KULIT)
    # kerah + kancing emas
    d.polygon([(cx - 18, 212), (cx + 18, 212), (cx, 238)], fill=(232, 228, 216), outline=(201, 194, 178))
    d.line([cx, 238, cx, 460], fill=(216, 210, 194), width=3)
    for yy in (262, 312, 362):
        d.ellipse([cx - 5, yy - 5, cx + 5, yy + 5], fill=EMAS, outline=(150, 118, 20), width=1)
    # leher + kepala + peci bulat putih
    d.rectangle([cx - 16, cy + 48, cx + 16, cy + 76], fill=KULIT)
    wajah(d, cx, cy, r)
    d.pieslice([cx - 58, cy - 98, cx + 58, cy + 10], 180, 360, fill=(250, 247, 240), outline=BATU, width=2)
    d.rectangle([cx - 58, cy - 32, cx + 58, cy - 18], fill=(220, 216, 205))
    # --- sarung hijau + garis kuning tipis vertikal (mask trapesium) ---
    pola = Image.new("RGB", (FW, FH), HIJAU_SARUNG)
    dp = ImageDraw.Draw(pola)
    for x in range(cx - 78, cx + 79, 26):
        dp.line([x, 460, x, 690], fill=EMAS, width=2)
    mask = Image.new("L", (FW, FH), 0)
    dm = ImageDraw.Draw(mask)
    dm.polygon([(cx - 88, 460), (cx + 88, 460), (cx + 98, 690), (cx - 98, 690)], fill=255)
    lay.paste(pola, (0, 0), mask)
    d = ImageDraw.Draw(lay)
    d.line([cx - 96, 672, cx + 96, 672], fill=EMAS, width=2)  # trim emas
    d.line([cx - 97, 680, cx + 97, 680], fill=HIJAU_HEM, width=10)  # hem
    kaki(d, cx)
    return lay


def figur_putri():
    lay = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    cx, cy, r = 210, 130, 56
    # --- baju biru langit (tunik sampai lutut) ---
    d.polygon([(cx - 72, 215), (cx + 72, 215), (cx + 84, 560), (cx - 84, 560)],
              fill=LANGIT, outline=LANGIT_OUT, width=2)
    for sx in (-1, 1):
        d.line([cx + sx * 76, 240, cx + sx * 86, 452], fill=LANGIT, width=26)
        d.line([cx + sx * 76, 240, cx + sx * 86, 452], fill=LANGIT_OUT, width=26)
        d.line([cx + sx * 76, 240, cx + sx * 86, 452], fill=LANGIT, width=22)
        d.ellipse([cx + sx * 86 - 13, 452, cx + sx * 86 + 13, 478], fill=KULIT)
    d.line([cx, 230, cx, 540], fill=(178, 218, 240), width=3)
    for yy in (260, 310):
        d.ellipse([cx - 5, yy - 5, cx + 5, yy + 5], fill=(255, 255, 255), outline=LANGIT_OUT, width=1)
    d.line([cx - 82, 548, cx + 82, 548], fill=LANGIT_OUT, width=2)
    # --- jilbab biru langit (kubah + drape sampai dada, menutup bahu) ---
    d.polygon([(cx - 78, 150), (cx + 78, 150), (cx + 106, 392), (cx - 106, 392)],
              fill=LANGIT_GELAP, outline=LANGIT_OUT, width=2)
    d.ellipse([cx - 72, cy - 72, cx + 72, cy + 78], fill=LANGIT_GELAP, outline=LANGIT_OUT, width=2)
    # wajah di dalam jilbab
    d.ellipse([cx - 42, cy - 38, cx + 42, cy + 52], fill=KULIT)
    er, ex, ey = r * 0.11, r * 0.32, cy + r * 0.05
    for sx in (-1, 1):
        d.ellipse([cx + sx * ex - er, ey - er * 1.25, cx + sx * ex + er, ey + er * 1.25], fill=GELAP)
        ay = ey - r * 0.30
        d.line([cx + sx * ex - er * 1.3, ay, cx + sx * ex + er * 1.3, ay], fill=GELAP, width=4)
    d.ellipse([cx - r * 0.06, ey + r * 0.22, cx + r * 0.06, ey + r * 0.38], fill=GELAP)
    d.arc([cx - r * 0.28, ey + r * 0.45, cx + r * 0.28, ey + r * 0.85], 20, 160, fill=GELAP, width=4)
    # --- sarung batik (tekstur asli, mask trapesium) ---
    batik = Image.open(BATIK).convert("RGB").resize((380, 190), Image.LANCZOS)
    pola = Image.new("RGB", (FW, FH), (27, 42, 74))
    pola.paste(batik, (20, 520))
    mask = Image.new("L", (FW, FH), 0)
    dm = ImageDraw.Draw(mask)
    dm.polygon([(cx - 84, 550), (cx + 84, 550), (cx + 94, 690), (cx - 94, 690)], fill=255)
    lay.paste(pola, (0, 0), mask)
    d = ImageDraw.Draw(lay)
    d.line([cx - 93, 684, cx + 93, 684], fill=(14, 22, 38), width=4)  # hem gelap
    kaki(d, cx)
    return lay


# ---------------------------------------------------------------- DEPAN
def depan():
    W, H = 1280, 1080
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 14), "SERAGAM UTAMA — KONSEP v1", font=font(30), fill=ZAMRUD_G)
    d.text((24, 52), "Putra: baju putih + sarung hijau garis kuning tipis vertikal  •  "
                     "Putri: baju biru langit + sarung batik",
           font=font(20), fill=ABU)
    putra = figur_putra()
    putri = figur_putri()
    img.paste(putra, (110, 110), putra)
    img.paste(putri, (750, 110), putri)
    d.text((320, 872), "SANTRI PUTRA", font=font(24), fill=ZAMRUD_G, anchor="mt")
    mtext(d, (320, 902),
          "baju putih #FFFFFF\nsarung hijau #008062\ngaris kuning #C9A227 (2 px, jarak 32 px)\npeci bulat putih (sistem peci_model tetap)",
          font(19), ZAMRUD_G)
    d.text((960, 872), "SANTRIWATI", font=font(24), fill=ZAMRUD_G, anchor="mt")
    mtext(d, (960, 902),
          "baju biru langit #87CEEB\nsarung batik indigo #1B2A4A\njilbab biru langit #7FB8E0\n(tekstur: tekstur-batik-putri-v1.png, 1.066 byte)",
          font(19), ZAMRUD_G)
    img.save(f"{OUT}/konsep-seragam-utama-v1.png")
    return putra, putri


# ---------------------------------------------------------------- DETAIL
def detail(putra, putri):
    W, H = 1280, 460
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 12), "DETAIL — garis, batik, dan tampilan dari jauh", font=font(26), fill=ZAMRUD_G)
    # Kotak A: zoom garis kuning (crop sarong putra, perbesar NEAREST)
    crop = putra.crop((150, 520, 270, 640)).resize((240, 240), Image.NEAREST)
    img.paste(crop, (24, 60))
    d.rectangle([24, 60, 264, 300], outline=ZAMRUD, width=3)
    mtext(d, (144, 312), "A — Garis kuning 2 px\n≈ 1,2 cm • jarak 32 px ≈ 19 cm",
          font(17), ZAMRUD_G)
    # Kotak B: zoom tekstur batik 2x
    batik = Image.open(BATIK).convert("RGB")
    crop2 = batik.crop((128, 64, 256, 192)).resize((256, 256), Image.NEAREST)
    img.paste(crop2, (300, 60))
    d.rectangle([300, 60, 556, 316], outline=ZAMRUD, width=3)
    mtext(d, (428, 328), "B — Batik parang 2x\n512×256 • 5 warna • 1.066 byte",
          font(17), ZAMRUD_G)
    # Kotak C: dari jauh (figur putra 25%)
    mini = putra.resize((105, 190), Image.LANCZOS)
    img.paste(mini, (650, 110), mini)
    d.line([600, 300, 780, 300], fill=BATU, width=3)
    d.rectangle([592, 60, 788, 316], outline=ZAMRUD, width=3)
    mtext(d, (690, 328), "C — Dilihat dari jauh\n(25%): garis hampir tidak ketara",
          font(17), ZAMRUD_G)
    # Kotak D: chips warna
    x0 = 830
    d.text((x0, 60), "Warna resmi:", font=font(20), fill=ZAMRUD_G)
    chips = [("Putih baju", "#FFFFFF", (255, 255, 255)),
             ("Hijau sarung", "#008062", HIJAU_SARUNG),
             ("Kuning garis", "#C9A227", EMAS),
             ("Biru langit", "#87CEEB", LANGIT),
             ("Indigo batik", "#1B2A4A", (27, 42, 74)),
             ("Jilbab", "#7FB8E0", LANGIT_GELAP)]
    yy = 96
    for nama, hx, col in chips:
        d.rectangle([x0, yy, x0 + 34, yy + 26], fill=col, outline=BATU, width=2)
        d.text((x0 + 44, yy + 1), f"{nama}  {hx}", font=font(18), fill=ZAMRUD_G)
        yy += 34
    d.text((x0, 312), "Peci + hijab mengikuti sistem sekarang.", font=font(16), fill=ABU)
    img.save(f"{OUT}/konsep-seragam-utama-detail-v1.png")


# ---------------------------------------------------------------- SAMPING
def samping():
    W, H = 1280, 760
    img = Image.new("RGB", (W, H), KREM2)
    d = ImageDraw.Draw(img)
    d.text((24, 14), "SERAGAM UTAMA — TAMPILAN SAMPING", font=font(30), fill=ZAMRUD_G)
    d.text((24, 52), "Garis kuning melingkari sarung (vertikal, depan–belakang)  •  "
                     "Batik melingkari sarung putri tanpa jahitan (tekstur periodik 64 px)",
           font=font(20), fill=ABU)

    def profil_putra(cx):
        d.ellipse([cx - 50, 140, cx + 50, 240], fill=KULIT)  # kepala
        d.polygon([(cx + 44, 178), (cx + 62, 196), (cx + 44, 206)], fill=KULIT)  # hidung
        d.ellipse([cx + 18, 172, cx + 30, 196], fill=GELAP)  # mata (profil: 1)
        d.pieslice([cx - 52, 92, cx + 52, 172], 180, 360, fill=(250, 247, 240), outline=BATU, width=2)
        d.rectangle([cx - 52, 138, cx + 52, 150], fill=(220, 216, 205))
        d.rectangle([cx - 14, 238, cx + 14, 262], fill=KULIT)  # leher
        d.polygon([(cx - 52, 262), (cx + 52, 262), (cx + 58, 480), (cx - 58, 480)],
                  fill=PUTIH_BAJU, outline=(201, 194, 178), width=2)  # koko
        d.line([cx + 40, 280, cx + 48, 460], fill=PUTIH_BAJU, width=22)  # lengan
        d.ellipse([cx + 36, 452, cx + 60, 476], fill=KULIT)  # tangan
        d.rectangle([cx - 58, 470, cx + 58, 690], fill=HIJAU_SARUNG)  # sarung
        for x in (cx - 40, cx - 14, cx + 12, cx + 38):
            d.line([x, 470, x, 690], fill=EMAS, width=2)
        d.line([cx - 58, 678, cx + 58, 678], fill=HIJAU_HEM, width=10)
        d.ellipse([cx - 30, 692, cx + 30, 712], fill=KULIT)
        d.rounded_rectangle([cx - 34, 704, cx + 44, 722], radius=6, fill=JATI)
        d.text((cx, 736), "PUTRA — samping", font=font(18), fill=ZAMRUD_G, anchor="mt")

    def profil_putri(cx):
        # Drape jilbab jatuh vertikal di belakang badan (bukan menyamping).
        d.rounded_rectangle([cx - 82, 180, cx - 44, 410], radius=18,
                            fill=LANGIT_GELAP, outline=LANGIT_OUT, width=2)
        d.ellipse([cx - 56, 132, cx + 56, 300], fill=LANGIT_GELAP, outline=LANGIT_OUT, width=2)  # jilbab
        d.ellipse([cx - 8, 158, cx + 52, 238], fill=KULIT)  # wajah profil
        d.polygon([(cx + 46, 188), (cx + 62, 202), (cx + 46, 210)], fill=KULIT)  # hidung
        d.ellipse([cx + 16, 180, cx + 28, 200], fill=GELAP)  # mata
        d.polygon([(cx - 52, 300), (cx + 52, 300), (cx + 58, 560), (cx - 58, 560)],
                  fill=LANGIT, outline=LANGIT_OUT, width=2)  # tunik
        d.line([cx + 40, 320, cx + 48, 460], fill=LANGIT, width=22)
        d.ellipse([cx + 36, 452, cx + 60, 476], fill=KULIT)
        batik = Image.open(BATIK).convert("RGB").resize((116, 140), Image.LANCZOS)
        img.paste(batik, (cx - 58, 550))
        d.rectangle([cx - 58, 550, cx + 58, 690], outline=(14, 22, 38), width=2)
        d.ellipse([cx - 30, 692, cx + 30, 712], fill=KULIT)
        d.rounded_rectangle([cx - 34, 704, cx + 44, 722], radius=6, fill=JATI)
        d.text((cx, 736), "PUTRI — samping", font=font(18), fill=ZAMRUD_G, anchor="mt")

    profil_putra(320)
    profil_putri(960)
    img.save(f"{OUT}/konsep-seragam-utama-samping-v1.png")


putra, putri = depan()
detail(putra, putri)
samping()
print("selesai")
