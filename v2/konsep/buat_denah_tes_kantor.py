# Denah konsep Tes di dalam kantor — Laras, 20 Nov 2026 (v2: label ditempatkan eksplisit)
# Dua denah tampak-atas: Kantor Putra (BARU, 6x5) + Kantor Ustadzah (penataan ulang, 8x6).
# Palet Pesantren Universe: krem #F2EAD6, zamrud #065F46, zamrud gelap #043B2C,
# emas #C9A227, jati #7B4B2A.
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1560, 860
ZAMRUD = (6, 95, 70)
ZAMRUD_GELAP = (4, 59, 44)
EMAS = (201, 162, 39)
JATI = (123, 75, 42)
BATU = (184, 178, 164)
PUTIH = (255, 255, 255)
HITAM = (30, 30, 30)
ABU = (90, 90, 90)
KARPET = (210, 225, 200)
BIRU = (180, 220, 240)

def font(sz, bold=False):
    p = ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else
         "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    return ImageFont.truetype(p, sz) if os.path.exists(p) else ImageFont.load_default()

F_TITLE = font(30, True)
F_SUB = font(20, True)
F_LBL = font(19)
F_SM = font(16)
F_TINY = font(15)

img = Image.new("RGB", (W, H), PUTIH)
d = ImageDraw.Draw(img)
d.rectangle([0, 0, W, 64], fill=ZAMRUD_GELAP)
d.text((24, 14), "KONSEP — Tes di dalam kantor  •  Denah interior (tampak atas)", font=F_TITLE, fill=PUTIH)

def text_lines(lines, x, y, anchor="l", f=F_LBL, fill=ZAMRUD_GELAP, lh=22):
    for i, t in enumerate(lines):
        if anchor == "l":
            d.text((x, y + i * lh), t, font=f, fill=fill)
        elif anchor == "r":
            d.text((x, y + i * lh), t, font=f, fill=fill, anchor="ra")
        else:
            d.text((x, y + i * lh), t, font=f, fill=fill, anchor="ma")

def arrow(x, y, arah, warna, panjang=34):
    dx, dy = {"U": (0, -1), "S": (0, 1), "B": (-1, 0), "T": (1, 0)}[arah]
    x2, y2 = x + dx * panjang, y + dy * panjang
    d.line([(x, y), (x2, y2)], fill=warna, width=4)
    px, py = -dy, -dx
    d.polygon([(x2, y2),
               (x2 - dx * 10 + px * 7, y2 - dy * 10 + py * 7),
               (x2 - dx * 10 - px * 7, y2 - dy * 10 - py * 7)], fill=warna)

def room(x0, y0, s, lw, ld, judul, sub, pintu):
    x1, y1 = x0 + lw * s, y0 + ld * s
    d.text((x0, y0 - 58), judul, font=F_SUB, fill=ZAMRUD_GELAP)
    d.text((x0, y0 - 30), sub, font=F_SM, fill=ABU)
    d.rectangle([x0 + 1.6 * s, y0 + 1.2 * s, x1 - 1.6 * s, y1 - 1.2 * s], fill=KARPET)
    T = 8
    if pintu == "U":
        g0 = x0 + (lw / 2 - 0.8) * s
        g1 = x0 + (lw / 2 + 0.8) * s
        d.line([(x0, y0), (g0, y0)], fill=ZAMRUD, width=T)
        d.line([(g1, y0), (x1, y0)], fill=ZAMRUD, width=T)
        text_lines(["PINTU (utara)"], (g0 + g1) / 2, y0 + 12, anchor="m", f=F_TINY, fill=ZAMRUD)
        d.line([(x0, y1), (x1, y1)], fill=ZAMRUD, width=T)
        d.line([(x0, y0), (x0, y1)], fill=ZAMRUD, width=T)
        d.line([(x1, y0), (x1, y1)], fill=ZAMRUD, width=T)
    else:  # pintu barat
        g0 = y0 + (ld / 2 - 0.8) * s
        g1 = y0 + (ld / 2 + 0.8) * s
        d.line([(x0, y0), (x0, g0)], fill=ZAMRUD, width=T)
        d.line([(x0, g1), (x0, y1)], fill=ZAMRUD, width=T)
        text_lines(["PINTU (barat)"], x0 + 14, g0 - 34, f=F_TINY, fill=ZAMRUD)
        d.line([(x0, y0), (x1, y0)], fill=ZAMRUD, width=T)
        d.line([(x0, y1), (x1, y1)], fill=ZAMRUD, width=T)
        d.line([(x1, y0), (x1, y1)], fill=ZAMRUD, width=T)
    return x0, y0, x1, y1

def box(x0, y0, s, cx, cz, w, h, fill, outline, width=2):
    return [x0 + (cx - w / 2) * s, y0 + (cz - h / 2) * s,
            x0 + (cx + w / 2) * s, y0 + (cz + h / 2) * s]

def spawn_dot(x0, y0, s, cx, cz, arah):
    px, py = x0 + cx * s, y0 + cz * s
    d.ellipse([px - 9, py - 9, px + 9, py + 9], fill=EMAS, outline=ZAMRUD_GELAP, width=2)
    arrow(px, py, arah, ZAMRUD_GELAP, 26)
    d.text((px + 14, py - 10), "spawn", font=F_TINY, fill=ABU)

# ============ Kantor Putra (BARU) 6x5, pintu UTARA ============
X0, Y0, S = 70, 150, 104
room(X0, Y0, S, 6, 5, "Kantor Putra — BARU (6 × 5 m)",
     "Interior baru di garis z=-300 (slot usul pusat x=-90). Pintu UTARA.", "U")
spawn_dot(X0, Y0, S, 3.0, 0.6, "S")
# meja
r = box(X0, Y0, S, 3.0, 2.7, 1.5, 0.75, JATI, ZAMRUD_GELAP)
d.rectangle(r, fill=JATI, outline=ZAMRUD_GELAP, width=2)
d.text(((r[0] + r[2]) / 2, (r[1] + r[3]) / 2 - 10), "MEJA", font=F_TINY, fill=PUTIH, anchor="ma")
# kursi pemain (utara meja, hadap selatan) — label di kanan
r = box(X0, Y0, S, 3.0, 1.85, 0.55, 0.55, EMAS, ZAMRUD_GELAP)
d.rectangle(r, fill=EMAS, outline=ZAMRUD_GELAP, width=2)
arrow((r[0] + r[2]) / 2, (r[1] + r[3]) / 2, "S", ZAMRUD_GELAP)
text_lines(["Kursi pemain", "(hadap selatan)"], r[2] + 10, (r[1] + r[3]) / 2 - 22)
# kursi penguji (selatan meja, hadap utara) — label di bawah kursi
r = box(X0, Y0, S, 3.0, 3.55, 0.55, 0.55, ZAMRUD, ZAMRUD_GELAP)
d.rectangle(r, fill=ZAMRUD, outline=ZAMRUD_GELAP, width=2)
arrow((r[0] + r[2]) / 2, (r[1] + r[3]) / 2, "U", PUTIH)
text_lines(["Kursi penguji — Ust. Sanusi", "(hadap utara)"], (r[0] + r[2]) / 2, r[3] + 10, anchor="m")
# lemari barat-daya
r = box(X0, Y0, S, 0.75, 4.45, 1.0, 0.5, BATU, ZAMRUD_GELAP)
d.rectangle(r, fill=BATU, outline=ZAMRUD_GELAP, width=2)
d.text((r[0] + 6, r[1] + 6), "Lemari", font=F_TINY, fill=HITAM)
# rak dinding timur
r = box(X0, Y0, S, 5.65, 2.4, 0.4, 1.5, BATU, ZAMRUD_GELAP)
d.rectangle(r, fill=BATU, outline=ZAMRUD_GELAP, width=2)
d.text((r[0] + 5, (r[1] + r[3]) / 2 - 8), "Rak", font=F_TINY, fill=HITAM)
# papan dinding selatan
r = box(X0, Y0, S, 3.0, 4.82, 1.9, 0.28, PUTIH, EMAS)
d.rectangle(r, fill=PUTIH, outline=EMAS, width=3)
d.text((r[0] + 8, r[1] + 5), "Papan", font=F_TINY, fill=HITAM)
# lampu (timur-laut, tidak menutupi MEJA)
lx, ly = X0 + 4.8 * S, Y0 + 1.0 * S
d.ellipse([lx - 12, ly - 12, lx + 12, ly + 12], fill=EMAS, outline=ZAMRUD_GELAP, width=2)
d.text((lx - 62, ly - 9), "Lampu", font=F_TINY, fill=ABU, anchor="ra")
# jendela barat (label di dalam, kanan jendela)
r = box(X0, Y0, S, 0.12, 1.5, 0.24, 1.2, BIRU, EMAS)
d.rectangle(r, fill=BIRU, outline=EMAS, width=2)
d.text((r[2] + 10, (r[1] + r[3]) / 2 - 9), "Jendela", font=F_TINY, fill=ABU)
# jendela timur (label di dalam, kiri jendela)
r = box(X0, Y0, S, 5.88, 3.6, 0.24, 1.2, BIRU, EMAS)
d.rectangle(r, fill=BIRU, outline=EMAS, width=2)
d.text((r[0] - 10, (r[1] + r[3]) / 2 - 9), "Jendela", font=F_TINY, fill=ABU, anchor="ra")

# ============ Kantor Ustadzah (penataan ulang) 8x6, pintu BARAT ============
X0, Y0, S = 800, 150, 82
room(X0, Y0, S, 8, 6, "Kantor Ustadzah — PENATAAN ULANG (8 × 6 m)",
     "Interior SUDAH ADA (pusat -120,-300). Meja pindah ke tengah.", "B")
spawn_dot(X0, Y0, S, 0.6, 3.0, "T")
# meja tengah
r = box(X0, Y0, S, 4.0, 3.0, 1.6, 0.8, JATI, ZAMRUD_GELAP)
d.rectangle(r, fill=JATI, outline=ZAMRUD_GELAP, width=2)
d.text(((r[0] + r[2]) / 2, (r[1] + r[3]) / 2 - 10), "MEJA", font=F_TINY, fill=PUTIH, anchor="ma")
# kursi pemain (barat meja, hadap timur) — label di bawah kursi
r = box(X0, Y0, S, 2.85, 3.0, 0.55, 0.55, EMAS, ZAMRUD_GELAP)
d.rectangle(r, fill=EMAS, outline=ZAMRUD_GELAP, width=2)
arrow((r[0] + r[2]) / 2, (r[1] + r[3]) / 2, "T", ZAMRUD_GELAP)
text_lines(["Kursi pemain", "(hadap timur)"], (r[0] + r[2]) / 2, r[3] + 14, anchor="m")
# kursi penguji (timur meja, hadap barat) — label di kanan kursi
r = box(X0, Y0, S, 5.15, 3.0, 0.55, 0.55, ZAMRUD, ZAMRUD_GELAP)
d.rectangle(r, fill=ZAMRUD, outline=ZAMRUD_GELAP, width=2)
arrow((r[0] + r[2]) / 2, (r[1] + r[3]) / 2, "B", PUTIH)
text_lines(["Kursi penguji", "Ustzh. Fatimah", "(hadap barat)"], r[2] + 10, (r[1] + r[3]) / 2 - 34)
# lemari barat-laut
r = box(X0, Y0, S, 1.0, 0.55, 1.2, 0.5, BATU, ZAMRUD_GELAP)
d.rectangle(r, fill=BATU, outline=ZAMRUD_GELAP, width=2)
d.text((r[0] + 6, r[1] + 6), "Lemari", font=F_TINY, fill=HITAM)
# rak dinding selatan
r = box(X0, Y0, S, 5.7, 5.65, 1.6, 0.4, BATU, ZAMRUD_GELAP)
d.rectangle(r, fill=BATU, outline=ZAMRUD_GELAP, width=2)
d.text((r[0] + 8, r[1] + 4), "Rak", font=F_TINY, fill=HITAM)
# papan dinding utara
r = box(X0, Y0, S, 5.7, 0.32, 2.0, 0.3, PUTIH, EMAS)
d.rectangle(r, fill=PUTIH, outline=EMAS, width=3)
d.text((r[0] + 8, r[1] + 4), "Papan", font=F_TINY, fill=HITAM)
# lampu timur-laut (sudah ada) — label di kiri
lx, ly = X0 + 6.8 * S, Y0 + 1.0 * S
d.ellipse([lx - 12, ly - 12, lx + 12, ly + 12], fill=EMAS, outline=ZAMRUD_GELAP, width=2)
d.text((lx - 16, ly - 9), "Lampu", font=F_TINY, fill=ABU, anchor="ra")
# jendela utara (label di bawah, di dalam ruangan)
r = box(X0, Y0, S, 3.0, 0.12, 1.2, 0.24, BIRU, EMAS)
d.rectangle(r, fill=BIRU, outline=EMAS, width=2)
d.text((r[0], r[3] + 8), "Jendela", font=F_TINY, fill=ABU)
# jendela selatan (label di kiri jendela, di dalam ruangan)
r = box(X0, Y0, S, 5.2, 5.88, 1.2, 0.24, BIRU, EMAS)
d.rectangle(r, fill=BIRU, outline=EMAS, width=2)
d.text((r[0] - 10, r[1] - 4), "Jendela", font=F_TINY, fill=ABU, anchor="ra")

# ============ legenda ============
ly = 720
d.text((70, ly), "Legenda:", font=F_SUB, fill=ZAMRUD_GELAP)
d.rectangle([220, ly + 2, 246, ly + 22], fill=JATI, outline=ZAMRUD_GELAP, width=2)
d.text((252, ly), "Meja", font=F_LBL, fill=HITAM)
d.rectangle([340, ly + 2, 366, ly + 22], fill=EMAS, outline=ZAMRUD_GELAP, width=2)
d.text((372, ly), "Kursi pemain", font=F_LBL, fill=HITAM)
d.rectangle([540, ly + 2, 566, ly + 22], fill=ZAMRUD, outline=ZAMRUD_GELAP, width=2)
d.text((572, ly), "Kursi penguji", font=F_LBL, fill=HITAM)
d.rectangle([740, ly + 2, 766, ly + 22], fill=ZAMRUD_GELAP)
d.text((772, ly), "Dinding (collision)", font=F_LBL, fill=HITAM)
d.ellipse([980, ly + 4, 1004, ly + 22], fill=EMAS, outline=ZAMRUD_GELAP, width=2)
d.text((1010, ly), "Spawn / lampu", font=F_LBL, fill=HITAM)
d.text((70, ly + 40), "Panah = arah hadap saat duduk. Pemain masuk → duduk di kursi emas → panel tes terbuka, berhadapan dengan penguji di seberang meja.",
       font=F_SM, fill=ABU)
d.text((70, ly + 66), "Sumber: InteriorGedungPutri (Kantor Ustadzah sudah ada) + _kantor_putra di pesantren_builder.gd (cangkang saja, tanpa interior).",
       font=F_SM, fill=ABU)

out = os.path.expanduser("~/workspace/pesantren-verse/v2/konsep/konsep-tes-dalam-kantor-denah.png")
img.save(out)
print("OK", out, img.size)
