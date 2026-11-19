"""Desain mockup HUD v3 Pesantren Universe (DESAIN DULU — bukan kode game).
Dibuat Tara 18 Nov 2026, arahan Mas 16:08 WIB: referensi MLBB / Free Fire / PUBG.
Dasar: v2/foto-hud/hud-v2-idle.png (720x1560) — HUD lama ditutup gambar baru.
Palet Pesantren Universe: zamrud #065F46, emas #C9A227, krem #F2EAD6.
Varian A = MLBB (glossy + glow). Varian B = PUBG/FF (clean outline, analog putih
translusen seperti analog asli yang Mas suka).
"""
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE = "/home/hatch/workspace/pesantren-verse/v2/foto-hud/hud-v2-idle.png"
OUTDIR = "/home/hatch/workspace/pesantren-verse/v2/foto-hud/"
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_R = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

ZAMRUD = (6, 95, 70, 255)
ZAMRUD_T = (16, 185, 129, 255)      # zamrud terang (glow)
ZAMRUD_G = (4, 59, 44, 255)         # zamrud gelap
EMAS = (201, 162, 39, 255)
EMAS_T = (248, 220, 125, 255)
EMAS_G = (138, 109, 31, 255)
KREM = (242, 234, 214, 255)
PUTIH = (255, 255, 255, 255)


def fb(sz):
    return ImageFont.truetype(FONT_B, sz)


def fr(sz):
    return ImageFont.truetype(FONT_R, sz)


def circle_mask(size):
    m = Image.new("L", size, 0)
    d = ImageDraw.Draw(m)
    d.ellipse([0, 0, size[0] - 1, size[1] - 1], fill=255)
    return m


def vgrad(size, top, bottom):
    w, h = size
    img = Image.new("RGBA", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(4))
        d.line([(0, y), (w, y)], fill=c)
    return img


def radial_disc(base, cx, cy, r, center_col, edge_col, steps=28):
    """Bola glossy: cincin konsentris dari edge (luar) ke center (terang)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps, 0, -1):
        t = i / steps  # 1 = tepi, mendekati 0 = tengah
        rr = r * t
        c = tuple(int(edge_col[j] + (center_col[j] - edge_col[j]) * (1 - t))
                  for j in range(4))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=c)
    base.alpha_composite(layer)


def gloss(base, cx, cy, r, alpha=90):
    """Sorot kilap putih di kiri atas disc."""
    hl = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(hl)
    d.ellipse([cx - r * 0.62, cy - r * 0.88, cx + r * 0.42, cy - r * 0.18],
              fill=(255, 255, 255, alpha))
    hl = hl.filter(ImageFilter.GaussianBlur(7))
    base.alpha_composite(hl)
    d2 = ImageDraw.Draw(base)
    d2.ellipse([cx - r * 0.34, cy - r * 0.62, cx - r * 0.08, cy - r * 0.36],
               fill=(255, 255, 255, 150))


def glow_disc(base, cx, cy, r, color, blur=10, extra=14):
    g = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    d.ellipse([cx - r - extra, cy - r - extra, cx + r + extra, cy + r + extra],
              fill=color)
    g = g.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(g)


def bayang(base, cx, cy, r, dy=6, alpha=80, blur=8):
    """Bayangan jatuh di bawah disc — yang bikin tombol terasa TIMBUL
    walau isinya transparan."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - r, cy - r + dy, cx + r, cy + r + dy],
              fill=(0, 0, 0, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def radial_disc_layer(base, cx, cy, r, center_col, edge_col, steps=28):
    """Versi layer dari radial_disc: cincin konsentris dengan alpha —
    digambar di layer transparan lalu alpha_composite (ImageDraw RGBA
    tidak mem-blend alpha, jadi TIDAK boleh digambar langsung di base)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps, 0, -1):
        t = i / steps
        rr = r * t
        c = tuple(int(edge_col[j] + (center_col[j] - edge_col[j]) * (1 - t))
                  for j in range(4))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=c)
    base.alpha_composite(layer)


def disc_t(base, cx, cy, r, top, bottom, rim=None, rim_w=0,
           glow=None, gloss_a=110, shadow=True):
    """Disc TRANSLUSEN ala joystick lama, tapi tetap timbul: isi gradien
    ber-alpha (lantai tembus), bayangan jatuh, rim tebal, sorot glossy."""
    if shadow:
        bayang(base, cx, cy, r)
    if glow:
        glow_disc(base, cx, cy, r, glow)
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    grad = vgrad((2 * r, 2 * r), top, bottom)
    layer.paste(grad, (cx - r, cy - r), circle_mask((2 * r, 2 * r)))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    if rim and rim_w:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=rim, width=rim_w)
    gloss(base, cx, cy, r, alpha=gloss_a)


def disc_vgrad(base, cx, cy, r, top, bottom, rim=None, rim_w=0,
               glow=None, highlight=True):
    if glow:
        glow_disc(base, cx, cy, r, glow)
    grad = vgrad((2 * r, 2 * r), top, bottom)
    base.paste(grad, (cx - r, cy - r), circle_mask((2 * r, 2 * r)))
    d = ImageDraw.Draw(base)
    if rim and rim_w:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=rim, width=rim_w)
    if highlight:
        gloss(base, cx, cy, r)
    return d


def star_points(cx, cy, r_out, r_in, rot=-90):
    pts = []
    for i in range(10):
        ang = math.radians(rot + i * 36)
        rr = r_out if i % 2 == 0 else r_in
        pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
    return pts


def text_outlined(base, xy, s, font, fill=(255, 255, 255, 255),
                  stroke=(0, 0, 0, 220), sw=3, anchor="mm"):
    d = ImageDraw.Draw(base)
    d.text(xy, s, font=font, fill=fill, stroke_width=sw,
           stroke_fill=stroke, anchor=anchor)


def rounded_rect(d, box, rad, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, radius=rad, fill=fill, outline=outline, width=width)


# ---------------- ikon (digambar kode, putih, isi padat) ----------------

def ico_kamera(d, cx, cy, s, col=PUTIH):
    # badan kamera + lensa
    d.rounded_rectangle([cx - s, cy - s * 0.55, cx + s, cy + s * 0.6],
                        radius=int(s * 0.25), fill=col)
    d.ellipse([cx - s * 0.45, cy - s * 0.45, cx + s * 0.45, cy + s * 0.45],
              fill=(6, 95, 70, 255), outline=col, width=max(2, int(s * 0.12)))
    d.ellipse([cx - s * 0.18, cy - s * 0.18, cx + s * 0.18, cy + s * 0.18],
              fill=col)
    d.rectangle([cx - s * 0.45, cy - s * 0.85, cx + s * 0.25, cy - s * 0.5],
                fill=col)


def ico_orang(d, cx, cy, s, col=PUTIH):
    d.ellipse([cx - s * 0.34, cy - s * 0.85, cx + s * 0.34, cy - s * 0.17],
              fill=col)
    d.pieslice([cx - s * 0.85, cy - s * 0.1, cx + s * 0.85, cy + s * 1.15],
               start=180, end=360, fill=col)


def ico_reset(d, cx, cy, s, col=PUTIH):
    d.arc([cx - s * 0.7, cy - s * 0.7, cx + s * 0.7, cy + s * 0.7],
          start=40, end=320, fill=col, width=max(3, int(s * 0.22)))
    # kepala panah di ujung busur (sudut 40 deg)
    ax, ay = cx + s * 0.7 * math.cos(math.radians(40)), cy - s * 0.7 * math.sin(math.radians(40))
    d.polygon([(ax + s * 0.35, ay - s * 0.1), (ax - s * 0.15, ay - s * 0.42),
               (ax - s * 0.05, ay + s * 0.28)], fill=col)


def ico_kartu(d, cx, cy, s, col=PUTIH):
    d.rounded_rectangle([cx - s, cy - s * 0.7, cx + s, cy + s * 0.7],
                        radius=int(s * 0.22), outline=col, width=max(2, int(s * 0.16)))
    d.ellipse([cx - s * 0.45, cy - s * 0.45, cx + s * 0.05, cy + s * 0.05],
              fill=col)
    d.line([(cx - s * 0.55, cy + s * 0.35), (cx + s * 0.55, cy + s * 0.35)],
           fill=col, width=max(2, int(s * 0.14)))
    d.line([(cx - s * 0.55, cy + s * 0.55), (cx + s * 0.2, cy + s * 0.55)],
           fill=col, width=max(2, int(s * 0.14)))


def ico_peta(d, cx, cy, s, col=PUTIH):
    d.polygon([(cx - s, cy - s * 0.6), (cx - s * 0.33, cy - s * 0.75),
               (cx + s * 0.33, cy - s * 0.6), (cx + s, cy - s * 0.75),
               (cx + s, cy + s * 0.6), (cx + s * 0.33, cy + s * 0.75),
               (cx - s * 0.33, cy + s * 0.6), (cx - s, cy + s * 0.75)],
              outline=col)
    d.line([(cx - s * 0.33, cy - s * 0.75), (cx - s * 0.33, cy + s * 0.6)],
           fill=col, width=max(2, int(s * 0.12)))
    d.line([(cx + s * 0.33, cy - s * 0.6), (cx + s * 0.33, cy + s * 0.75)],
           fill=col, width=max(2, int(s * 0.12)))


def ico_amplop(d, cx, cy, s, col=PUTIH):
    d.rounded_rectangle([cx - s, cy - s * 0.7, cx + s, cy + s * 0.7],
                        radius=int(s * 0.18), outline=col, width=max(2, int(s * 0.16)))
    d.line([(cx - s, cy - s * 0.6), (cx, cy + s * 0.1)], fill=col,
           width=max(2, int(s * 0.14)))
    d.line([(cx + s, cy - s * 0.6), (cx, cy + s * 0.1)], fill=col,
           width=max(2, int(s * 0.14)))


def ico_suara(d, cx, cy, s, col=PUTIH):
    d.polygon([(cx - s * 0.8, cy - s * 0.25), (cx - s * 0.25, cy - s * 0.25),
               (cx + s * 0.35, cy - s * 0.75), (cx + s * 0.35, cy + s * 0.75),
               (cx - s * 0.25, cy + s * 0.25), (cx - s * 0.8, cy + s * 0.25)],
              fill=col)
    d.arc([cx + s * 0.35, cy - s * 0.55, cx + s * 1.05, cy + s * 0.55],
          start=-55, end=55, fill=col, width=max(2, int(s * 0.14)))


def ico_fullscreen(d, cx, cy, s, col=PUTIH):
    w = max(3, int(s * 0.2))
    L = s * 0.45
    for sx, sy in [(-1, -1), (1, -1), (-1, 1), (1, 1)]:
        x0, y0 = cx + sx * s * 0.85, cy + sy * s * 0.85
        d.line([(x0, y0), (x0 - sx * L, y0)], fill=col, width=w)
        d.line([(x0, y0), (x0, y0 - sy * L)], fill=col, width=w)


def chevron(d, cx, cy, tip_r, base_r, half_w, angle_deg, col):
    """Panah kecil di dalam ring analog (ala MLBB — kecil, bukan besar)."""
    a = math.radians(angle_deg)
    tip = (cx + tip_r * math.cos(a), cy + tip_r * math.sin(a))
    base_c = (cx + base_r * math.cos(a), cy + base_r * math.sin(a))
    perp = (math.cos(a + math.pi / 2), math.sin(a + math.pi / 2))
    d.polygon([tip,
               (base_c[0] + perp[0] * half_w, base_c[1] + perp[1] * half_w),
               (base_c[0] - perp[0] * half_w, base_c[1] - perp[1] * half_w)],
              fill=col)


# ---------------- latar: tutup HUD lama ----------------

def tutup_lantai(base, box, src):
    """Tutup area HUD lama dengan klon lantai marmer bersih dari `src`
    (lantai di bawah sini hampir seragam putih — klon + tepi lembut
    tidak terlihat). `box`/`src` = (x0,y0,x1,y1)."""
    patch = base.crop(src)
    patch = patch.resize((box[2] - box[0], box[3] - box[1]))
    mask = Image.new("L", patch.size, 255).filter(ImageFilter.GaussianBlur(7))
    base.paste(patch, (box[0], box[1]), mask)


def tutup_teks_foto(base):
    """Tutup teks debug 'Foto Tara' (x ~265-455, y ~695-730) dengan
    menempel potongan kisi pintu yang sama dari kanan (x 500-695) —
    pola kisi berlanjut, jauh lebih menyatu daripada tambalan datar."""
    patch = base.crop((500, 688, 695, 738))
    mask = Image.new("L", patch.size, 255)
    mask = mask.filter(ImageFilter.GaussianBlur(2))
    base.paste(patch, (262, 688), mask)


# ---------------- elemen bersama ----------------

def bar_atas(base, gold_line=True, fill_alpha=175):
    """Strip atas ala PUBG: satu strip gelap menyatu, 5 icon putih tebal.
    Isi strip digambar di layer (alpha_composite) supaya alpha-nya
    benar-benar translusen — ImageDraw langsung di base akan jadi pekat."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([498, 8, 712, 54], radius=14, fill=(8, 20, 16, fill_alpha))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base, "RGBA")
    line_col = EMAS if gold_line else (255, 255, 255, 220)
    d.line([(512, 52), (698, 52)], fill=line_col, width=3)
    icons = [ico_kartu, ico_peta, ico_amplop, ico_suara, ico_fullscreen]
    xs = [524, 567, 610, 653, 692]
    d2 = ImageDraw.Draw(base)
    for f, x in zip(icons, xs):
        f(d2, x, 30, 13)


def pill_main_bersama(base, variant):
    """Pill 'Main Bersama' — di kanan minimap, posisi foto terukur:
    pill lama (120,74)-(219,104); pill baru sedikit lebih besar,
    kotak (118,66)-(288,112), teks tengah (203,89)."""
    d = ImageDraw.Draw(base, "RGBA")
    box = [118, 66, 288, 112]
    if variant == "T":
        # Transparan seperti joystick lama: emas alpha 150 (lantai tembus),
        # rim krem + sorot atas dilembutkan (di A garisnya agak menonjol).
        layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle(box, radius=23, fill=(201, 162, 39, 150))
        base.alpha_composite(layer)
        d2 = ImageDraw.Draw(base)
        d2.rounded_rectangle(box, radius=23,
                             outline=(255, 240, 180, 255), width=3)
        d2.rounded_rectangle([118, 66, 288, 84], radius=23,
                             outline=(255, 255, 255, 40), width=3)
        text_outlined(base, (203, 90), "Main Bersama", fb(21),
                      fill=(20, 30, 20, 255), stroke=(255, 240, 180, 255), sw=1)
    elif variant == "A":
        # pill emas: gambar di layer lalu mask rounded
        layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle(box, radius=23, fill=(201, 162, 39, 255))
        base.alpha_composite(layer)
        d2 = ImageDraw.Draw(base)
        d2.rounded_rectangle(box, radius=23,
                             outline=(255, 240, 180, 255), width=3)
        d2.rounded_rectangle([118, 66, 288, 84], radius=23,
                             outline=(255, 255, 255, 70), width=3)
        text_outlined(base, (203, 90), "Main Bersama", fb(21),
                      fill=(20, 30, 20, 255), stroke=(255, 240, 180, 255), sw=1)
    else:
        d.rounded_rectangle(box, radius=23, fill=(8, 20, 16, 185))
        d2 = ImageDraw.Draw(base)
        d2.rounded_rectangle(box, radius=23,
                             outline=(255, 255, 255, 255), width=3)
        text_outlined(base, (203, 90), "Main Bersama", fb(21),
                      fill=(255, 255, 255, 255), stroke=(0, 0, 0, 220), sw=3)


def analog(base, variant):
    """Analog kiri bawah — HERO v3. Pusat (116, 1422), r 124 (menutup
    penuh joystick lama yang pusatnya ~(110,1435) r~110)."""
    cx, cy, r = 116, 1430, 128
    d = ImageDraw.Draw(base, "RGBA")
    if variant == "T":
        # Transparan kaya joystick lama (putih pucat tembus pandang),
        # TAPI tetap timbul: ring putih tebal + ring glow zamrud + knob
        # bola zamrud translusen + sorot + bayangan jatuh.
        bayang(base, cx, cy, r, dy=7, alpha=70)
        glow_disc(base, cx, cy, r, (16, 185, 129, 70), blur=14, extra=10)
        layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 45))
        base.alpha_composite(layer)
        d.ellipse([cx - r, cy - r, cx + r, cy + r],
                  outline=(255, 255, 255, 235), width=5)
        d.ellipse([cx - r + 6, cy - r + 6, cx + r - 6, cy + r - 6],
                  outline=(16, 185, 129, 200), width=3)
        for ang in (-90, 0, 90, 180):
            chevron(d, cx, cy, 88, 70, 10, ang, (16, 185, 129, 230))
        # knob bola zamrud TRANSLUSEN (bukan padat seperti A)
        radial_disc_layer(base, cx, cy, 52, (143, 245, 207, 165),
                          (6, 95, 70, 205))
        d.ellipse([cx - 52, cy - 52, cx + 52, cy + 52],
                  outline=(255, 255, 255, 230), width=3)
        gloss(base, cx, cy, 52, alpha=110)
    elif variant == "A":
        # MLBB: cincin terang + glow zamrud, knob bola glossy zamrud terang
        glow_disc(base, cx, cy, r, (16, 185, 129, 70), blur=14, extra=10)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 38))
        d.ellipse([cx - r, cy - r, cx + r, cy + r],
                  outline=(255, 255, 255, 235), width=5)
        d.ellipse([cx - r + 6, cy - r + 6, cx + r - 6, cy + r - 6],
                  outline=(16, 185, 129, 200), width=3)
        for ang in (-90, 0, 90, 180):
            chevron(d, cx, cy, 88, 70, 10, ang, (16, 185, 129, 230))
        # knob glossy
        radial_disc(base, cx, cy, 52, (143, 245, 207, 255), (6, 95, 70, 255))
        d.ellipse([cx - 52, cy - 52, cx + 52, cy + 52],
                  outline=(255, 255, 255, 230), width=3)
        gloss(base, cx, cy, 52, alpha=110)
    else:
        # PUBG/FF: cincin putih tebal; isi ring zamrud muda TRANSLUSEN
        # (digambar di layer lalu alpha_composite — ImageDraw RGBA
        # tidak mem-blend alpha, dan convert RGB membuang alpha,
        # jadi fill langsung akan jadi zamrud pekat, bukan mint pucat)
        layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(16, 185, 129, 55))
        base.alpha_composite(layer)
        d = ImageDraw.Draw(base, "RGBA")
        d.ellipse([cx - r, cy - r, cx + r, cy + r],
                  outline=(255, 255, 255, 240), width=6)
        d.ellipse([cx - r + 10, cy - r + 10, cx + r - 10, cy + r - 10],
                  outline=(255, 255, 255, 120), width=2)
        for ang in (-90, 0, 90, 180):
            chevron(d, cx, cy, 86, 68, 10, ang, (255, 255, 255, 200))
        # knob mint padat (bukan putih pucat — itu yang bikin v1 hilang)
        d.ellipse([cx - 52, cy - 52, cx + 52, cy + 52],
                  fill=(110, 215, 175, 235))
        d.ellipse([cx - 52, cy - 52, cx + 52, cy + 52],
                  outline=(255, 255, 255, 240), width=4)
        d.ellipse([cx - 56, cy - 56, cx + 56, cy + 56],
                  outline=(16, 185, 129, 200), width=3)
        gloss(base, cx, cy, 52, alpha=90)


def klaster_tombol(base, variant):
    """Klaster kanan bawah: Interact emas besar + Kamera/Aksi/Reset."""
    d = ImageDraw.Draw(base)
    if variant == "T":
        # Transparan basis A: isi disc gradien ber-alpha (lantai tembus),
        # rim tebal + glow + sorot + bayangan jatuh = tetap TIMBUL.
        # Icon + label tetap putih solid supaya terbaca.
        disc_t(base, 640, 1440, 74, (255, 232, 160, 150), (168, 130, 32, 185),
               rim=(255, 244, 200, 255), rim_w=6,
               glow=(255, 210, 90, 120), gloss_a=100)
        d.ellipse([572, 1372, 708, 1508], outline=(138, 109, 31, 255), width=2)
        d.polygon(star_points(640, 1436, 30, 13), fill=(255, 255, 255, 255))
        text_outlined(base, (640, 1532), "MULAI MISI", fb(20))
        # Kamera — zamrud translusen, rim emas tebal
        disc_t(base, 520, 1375, 48, (32, 200, 150, 130), (6, 95, 70, 175),
               rim=(255, 220, 130, 255), rim_w=5,
               glow=(16, 185, 129, 90), gloss_a=100)
        ico_kamera(d, 520, 1375, 17)
        text_outlined(base, (520, 1437), "Kamera", fb(18))
        text_outlined(base, (520, 1459), "Normal", fr(16),
                      fill=(242, 234, 214, 255))
        # Aksi — zamrud translusen, rim krem
        disc_t(base, 435, 1445, 48, (32, 200, 150, 130), (6, 95, 70, 175),
               rim=(242, 234, 214, 255), rim_w=5,
               glow=(16, 185, 129, 80), gloss_a=100)
        ico_orang(d, 435, 1445, 17)
        text_outlined(base, (435, 1507), "Aksi", fb(18))
        # Reset — emas translusen, rim krem
        disc_t(base, 620, 1300, 34, (232, 190, 80, 140), (138, 109, 31, 180),
               rim=(242, 234, 214, 255), rim_w=4,
               glow=(201, 162, 39, 80), gloss_a=100)
        ico_reset(d, 620, 1300, 12)
        text_outlined(base, (620, 1346), "Reset", fb(16))
    elif variant == "A":
        # Interact — disc emas glossy MLBB: gradien radial + rim krem tebal + glow
        glow_disc(base, 640, 1440, 74, (255, 210, 90, 120), blur=12, extra=12)
        radial_disc(base, 640, 1440, 74, (255, 232, 160, 255), (168, 130, 32, 255))
        d.ellipse([566, 1366, 714, 1514], outline=(255, 244, 200, 255), width=6)
        d.ellipse([572, 1372, 708, 1508], outline=(138, 109, 31, 255), width=2)
        gloss(base, 640, 1440, 74, alpha=100)
        d.polygon(star_points(640, 1436, 30, 13), fill=(255, 255, 255, 255))
        text_outlined(base, (640, 1532), "MULAI MISI", fb(20))
        # Kamera — zamrud glossy, rim emas tebal
        disc_vgrad(base, 520, 1375, 48, (32, 200, 150, 255), (6, 95, 70, 255),
                   rim=(255, 220, 130, 255), rim_w=5,
                   glow=(16, 185, 129, 90))
        ico_kamera(d, 520, 1375, 17)
        text_outlined(base, (520, 1437), "Kamera", fb(18))
        text_outlined(base, (520, 1459), "Normal", fr(16),
                      fill=(242, 234, 214, 255))
        # Aksi — zamrud glossy, rim krem
        disc_vgrad(base, 435, 1445, 48, (32, 200, 150, 255), (6, 95, 70, 255),
                   rim=(242, 234, 214, 255), rim_w=5,
                   glow=(16, 185, 129, 80))
        ico_orang(d, 435, 1445, 17)
        text_outlined(base, (435, 1507), "Aksi", fb(18))
        # Reset — emas gelap glossy, rim krem
        disc_vgrad(base, 620, 1300, 34, (232, 190, 80, 255), (138, 109, 31, 255),
                   rim=(242, 234, 214, 255), rim_w=4,
                   glow=(201, 162, 39, 80))
        ico_reset(d, 620, 1300, 12)
        text_outlined(base, (620, 1346), "Reset", fb(16))
    else:
        # Interact — emas datar + rim PUTIH tebal ala FF (tombol tembak)
        glow_disc(base, 640, 1440, 74, (255, 255, 255, 70), blur=12, extra=10)
        disc_vgrad(base, 640, 1440, 74, (233, 190, 80, 255), (190, 145, 35, 255),
                   rim=(255, 255, 255, 255), rim_w=6, highlight=True)
        d.ellipse([572, 1372, 708, 1508], outline=(138, 109, 31, 255), width=2)
        d.polygon(star_points(640, 1436, 30, 13), fill=(255, 255, 255, 255))
        text_outlined(base, (640, 1532), "MULAI MISI", fb(20))
        # Kamera/Aksi/Reset — dark translusen + rim putih tebal ala PUBG
        for (cx, cy, r, ico, label, sub) in [
                (520, 1375, 48, ico_kamera, "Kamera", "Normal"),
                (435, 1445, 48, ico_orang, "Aksi", None),
                (620, 1300, 34, ico_reset, "Reset", None)]:
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 115))
            d.ellipse([cx - r, cy - r, cx + r, cy + r],
                      outline=(255, 255, 255, 240), width=5)
            s = 17 if r == 48 else 12
            ico(d, cx, cy, s)
            text_outlined(base, (cx, cy + r + 14), label, fb(18))
            if sub:
                text_outlined(base, (cx, cy + r + 36), sub, fr(16),
                              fill=(242, 234, 214, 255))


def build(variant):
    base = Image.open(BASE).convert("RGBA")
    tutup_teks_foto(base)
    # Hapus HUD lama dengan klon lantai (bukan bidang transparan —
    # itu jadi hitam saat disimpan RGB; dan elemen baru saja tidak
    # cukup menutup klaster lama yang posisinya tidak sama persis).
    # Sumber = lantai putih MURNI (280,1350)-(420,1560) — strip
    # y 1300-1330 JANGAN dipakai: ada bayangan pot (avg 170).
    # Kotak mulai y=1340 (di bawah bayangan pot); Reset lama di atas
    # itu tertutup disc Reset baru yang posisinya sama persis.
    tutup_lantai(base, (400, 1340, 720, 1560), (280, 1350, 420, 1560))
    tutup_lantai(base, (0, 1340, 270, 1560), (280, 1350, 420, 1560))
    if variant == "T":
        bar_atas(base, gold_line=True, fill_alpha=115)
    else:
        bar_atas(base, gold_line=(variant == "A"))
    pill_main_bersama(base, variant)
    analog(base, variant)
    klaster_tombol(base, variant)
    if variant == "T":
        out = OUTDIR + "hud-v3-desain-a-transparan.png"
    else:
        out = OUTDIR + f"hud-v3-desain-{variant.lower()}.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------- varian P — PUTIH POLOS TRANSPARAN ----------------
# Arahan Mas 16:26-16:27 WIB (MENGALAHKAN "timbul"): buang SEMUA rasa
# timbul — tanpa rim tebal bercahaya, tanpa sorot glossy, tanpa
# bayangan jatuh, tanpa glow. Semuanya POLOS TRANSPARAN seperti
# joystick versi sebelumnya (disc + knob putih translusen polos).
# Icon + label GELAP supaya terbaca di atas putih translusen.
# Strip atas juga polos transparan (izin "boleh solid" 16:27 adalah
# izin, bukan keharusan — arahan terbaru bilang polos transparan).
# Latar: slice lapang dari foto P5 asrama-putra (bangunan + pemain +
# rumput + langit), BUKAN close-up dinding putih. Slice x 480-746
# dipilih karena BERSIH dari HUD lama (minimap/pill/joystick/klaster
# lama semuanya di luar slice) — tidak perlu tambal-menambal.

GELAP = (45, 45, 45, 255)
GELAP_TXT = (35, 35, 35, 255)


def latar_putih():
    src = Image.open(
        "/home/hatch/workspace/pesantren-verse/v2/foto-tekstur-p5-sesudah/asrama-putra.png"
    ).convert("RGBA")
    crop = src.crop((460, 0, 726, 576))
    bg = crop.resize((720, 1560), Image.LANCZOS)
    bg = bg.filter(ImageFilter.GaussianBlur(1.2))
    return bg


def disc_p(base, cx, cy, r, alpha_fill, outline_w=2):
    """Disc PUTIH POLOS TRANSLUSEN: isi putih ber-alpha (lantai tembus)
    + garis tepi gelap TIPIS saja (bukan rim tebal bercahaya) supaya
    disc tetap terlihat di lantai putih. Tanpa gloss/glow/bayangan."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, alpha_fill))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.ellipse([cx - r, cy - r, cx + r, cy + r], outline=GELAP, width=outline_w)


def ico_kamera_gelap(d, cx, cy, s):
    """Ikon kamera GELAP (bukan putih): badan gelap + lensa cincin
    putih + titik gelap — terbaca di atas disc putih."""
    d.rounded_rectangle([cx - s, cy - s * 0.55, cx + s, cy + s * 0.6],
                        radius=int(s * 0.25), fill=GELAP)
    d.ellipse([cx - s * 0.45, cy - s * 0.45, cx + s * 0.45, cy + s * 0.45],
              fill=(255, 255, 255, 255))
    d.ellipse([cx - s * 0.22, cy - s * 0.22, cx + s * 0.22, cy + s * 0.22],
              fill=GELAP)
    d.rectangle([cx - s * 0.45, cy - s * 0.85, cx + s * 0.25, cy - s * 0.5],
                fill=GELAP)


def minimap_p(base):
    """Minimap + teks status (elemen lama, bukan bagian 'semua putih'):
    dipertahankan seperti di game — disc hijau gelap + segitiga emas."""
    d = ImageDraw.Draw(base)
    d.ellipse([16, 60, 128, 172], fill=(10, 25, 20, 210))
    d.ellipse([16, 60, 128, 172], outline=(255, 255, 255, 200), width=2)
    for (x, y) in [(45, 94), (95, 84), (60, 144), (100, 139), (85, 109)]:
        d.ellipse([x - 3, y - 3, x + 3, y + 3], fill=(180, 220, 190, 255))
    d.polygon([(72, 100), (64, 116), (80, 116)], fill=(201, 162, 39, 255))
    text_outlined(base, (8, 10), "Poin: 0", fr(15),
                  fill=(255, 255, 255, 255), stroke=(0, 0, 0, 220), sw=2,
                  anchor="la")
    text_outlined(base, (8, 27), "Misi: Misi 1 — Kenalan dengan Nahwu", fr(15),
                  fill=(255, 255, 255, 255), stroke=(0, 0, 0, 220), sw=2,
                  anchor="la")
    text_outlined(base, (8, 44), "Offline", fr(15),
                  fill=(255, 255, 255, 255), stroke=(0, 0, 0, 220), sw=2,
                  anchor="la")


def bar_atas_p(base):
    """Strip atas POLOS TRANSPARAN (bukan solid): putih alpha 130,
    tanpa garis emas, icon GELAP. Lebar strip dilebarkan (488-714)
    supaya 5 icon tidak berdesakan/terpotong di tepi."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([488, 8, 714, 54], radius=14,
                        fill=(255, 255, 255, 130))
    base.alpha_composite(layer)
    icons = [ico_kartu, ico_peta, ico_amplop, ico_suara, ico_fullscreen]
    xs = [514, 558, 602, 646, 690]
    d2 = ImageDraw.Draw(base)
    for f, x in zip(icons, xs):
        f(d2, x, 30, 13, col=GELAP)


def pill_p(base):
    """Pill 'Main Bersama' PUTIH POLOS TRANSLUSEN, teks GELAP.
    Posisi DIPERBAIKI (ini salah satu yang 'kacau' di revisi T):
    kotak (150,70)-(330,116) — jarak 22 px dari tepi minimap (128),
    TIDAK menumpuk minimap lagi."""
    box = [150, 70, 330, 116]
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    ld.rounded_rectangle(box, radius=23, fill=(255, 255, 255, 80))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle(box, radius=23, outline=GELAP, width=2)
    text_outlined(base, (240, 93), "Main Bersama", fb(20),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)


def analog_p(base):
    """Analog PUTIH POLOS (bukan mint): isi disc putih translusen,
    knob putih lebih padat, chevron GELAP kecil. Tanpa glow zamrud
    (itu yang bikin isi jadi mint di revisi T)."""
    cx, cy, r = 128, 1428, 120
    disc_p(base, cx, cy, r, 55)
    disc_p(base, cx, cy, 48, 130)
    d = ImageDraw.Draw(base)
    for ang in (-90, 0, 90, 180):
        chevron(d, cx, cy, 80, 62, 9, ang, (50, 50, 50, 255))


def klaster_p(base):
    """Klaster kanan bawah — SEMUA PUTIH POLOS TRANSLUSEN (Interact
    bukan emas lagi, Kamera/Aksi/Reset bukan zamrud/emas). Icon +
    label GELAP. Posisi/label sama seperti varian A (sudah dicek
    tidak saling sentuh)."""
    d = ImageDraw.Draw(base)
    # Interact — bintang GELAP di atas disc putih
    disc_p(base, 640, 1440, 74, 70)
    d.polygon(star_points(640, 1436, 30, 13), fill=GELAP)
    text_outlined(base, (640, 1532), "MULAI MISI", fb(20),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)
    # Kamera
    disc_p(base, 520, 1375, 48, 70)
    ico_kamera_gelap(d, 520, 1375, 17)
    text_outlined(base, (520, 1437), "Kamera", fb(18),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)
    text_outlined(base, (520, 1459), "Normal", fr(16),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)
    # Aksi
    disc_p(base, 435, 1445, 48, 70)
    ico_orang(d, 435, 1445, 17, col=GELAP)
    text_outlined(base, (435, 1507), "Aksi", fb(18),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)
    # Reset
    disc_p(base, 620, 1300, 34, 70)
    ico_reset(d, 620, 1300, 12, col=GELAP)
    text_outlined(base, (620, 1346), "Reset", fb(16),
                  fill=GELAP_TXT, stroke=(255, 255, 255, 255), sw=2)


def build_putih():
    base = latar_putih()
    minimap_p(base)
    bar_atas_p(base)
    pill_p(base)
    analog_p(base)
    klaster_p(base)
    out = OUTDIR + "hud-v3-desain-putih.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out



# ---------------- varian P2 — PUTIH MODERN (revisi v1 putih) ----------------
# Verdict Mas 16:57 WIB atas mockup putih v1: "Kurang modern tombolnya..
# terus tulisan tombol terlalu besar.."
# Dua perbaikan (arahan Xam):
#  (1) MODERN — v1 (garis tepi gelap tipis 2 px) terbaca primitif seperti
#      v1 dulu. Tetap PUTIH + transparan, TANPA timbul glossy penuh
#      (itu sudah ditolak). Yang berubah: RING PUTIH SOLID tegas +
#      hairline gelap tipis di dalam ring (ala tombol skill MLBB / FF:
#      ring rapi + isi tembus pandang), icon lebih TEBAL/besar, knob
#      analog ikut dirapikan. Sentuhan kaca buram = ring solid + isi
#      translusen, BUKAN gloss/glow/bayangan.
#  (2) TULISAN LEBIH KECIL ~30-40%: MULAI MISI 20->13, Kamera 18->12,
#      Normal 16->11, Aksi 18->12, Reset 16->11, Main Bersama 20->13.
#      Stroke putih label ikut ditipiskan (sw 2->1) supaya huruf kecil
#      tidak "gemuk" oleh outline.

def disc_m(base, cx, cy, r, alpha_fill, ring_w=5):
    """Disc PUTIH MODERN: isi putih translusen + RING PUTIH SOLID tegas
    + hairline gelap tipis tepat di dalam ring (batas yang terbaca di
    lantai putih). Tanpa gloss/glow/bayangan — modern, bukan mengkilap."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, alpha_fill))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.ellipse([cx - r, cy - r, cx + r, cy + r],
               outline=(255, 255, 255, 255), width=ring_w)
    d2.ellipse([cx - r + ring_w + 1, cy - r + ring_w + 1,
                cx + r - ring_w - 1, cy + r - ring_w - 1],
               outline=(45, 45, 45, 170), width=2)


def teks_tombol(base, xy, s, font, anchor="mm"):
    """Label tombol GELAP, stroke putih TIPIS (sw=1) — huruf kecil
    tetap ramping, tidak gemuk oleh outline."""
    text_outlined(base, xy, s, font, fill=GELAP_TXT,
                  stroke=(255, 255, 255, 255), sw=1, anchor=anchor)


def bar_atas_m(base):
    """Strip atas — sama seperti P (putih polos transparan, icon gelap),
    ditambah outline putih solid tipis supaya strip terasa 'selesai'
    dan rapi; icon sedikit diperbesar (13->14) supaya lebih tegas."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([488, 8, 714, 54], radius=14,
                        fill=(255, 255, 255, 130))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle([488, 8, 714, 54], radius=14,
                         outline=(255, 255, 255, 255), width=2)
    icons = [ico_kartu, ico_peta, ico_amplop, ico_suara, ico_fullscreen]
    xs = [514, 558, 602, 646, 690]
    for f, x in zip(icons, xs):
        f(d2, x, 30, 14, col=GELAP)


def pill_m(base):
    """Pill 'Main Bersama' — ring putih solid + hairline gelap (sama
    seperti disc modern), teks DIKECILKAN 20->13. Lebar pill dihitung
    dari lebar teks (padding 24 px tiap sisi) supaya tidak terlalu
    lapang; tetap jauh dari minimap (jarak 32 px)."""
    f = fb(13)
    d_tmp = ImageDraw.Draw(base)
    tw = d_tmp.textbbox((0, 0), "Main Bersama", font=f)[2]
    w = tw + 48
    x0, x1 = 160, 160 + w
    y0, y1 = 74, 112
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    ld.rounded_rectangle([x0, y0, x1, y1], radius=19,
                         fill=(255, 255, 255, 80))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle([x0, y0, x1, y1], radius=19,
                        outline=(255, 255, 255, 255), width=3)
    d.rounded_rectangle([x0 + 4, y0 + 4, x1 - 4, y1 - 4], radius=16,
                        outline=(45, 45, 45, 170), width=1)
    teks_tombol(base, ((x0 + x1) // 2, (y0 + y1) // 2), "Main Bersama", f)


def analog_m(base):
    """Analog — ring putih solid tegas + hairline gelap (bukan garis
    tipis 2 px), knob lebih rapi (ring solid + hairline), chevron
    GELAP lebih tebal/besar. Tetap putih polos transparan, bukan mint."""
    cx, cy, r = 128, 1428, 120
    disc_m(base, cx, cy, r, 55, ring_w=5)
    disc_m(base, cx, cy, 50, 130, ring_w=4)
    d = ImageDraw.Draw(base)
    for ang in (-90, 0, 90, 180):
        chevron(d, cx, cy, 84, 64, 11, ang, (50, 50, 50, 255))


def klaster_m(base):
    """Klaster kanan bawah — disc modern (ring solid + hairline),
    icon LEBIH TEBAL/besar, label DIKECILKAN ~30-40%. Posisi sama
    seperti P (sudah dicek tidak saling sentuh)."""
    d = ImageDraw.Draw(base)
    # Interact — bintang lebih besar (30->34), label 20->13
    disc_m(base, 640, 1440, 74, 70, ring_w=6)
    d.polygon(star_points(640, 1436, 34, 15), fill=GELAP)
    teks_tombol(base, (640, 1532), "MULAI MISI", fb(13))
    # Kamera — icon 17->19, label 18->12 / 16->11
    disc_m(base, 520, 1375, 48, 70, ring_w=5)
    ico_kamera_gelap(d, 520, 1375, 19)
    teks_tombol(base, (520, 1436), "Kamera", fb(12))
    teks_tombol(base, (520, 1455), "Normal", fr(11))
    # Aksi — icon 17->19, label 18->12
    disc_m(base, 435, 1445, 48, 70, ring_w=5)
    ico_orang(d, 435, 1445, 19, col=GELAP)
    teks_tombol(base, (435, 1506), "Aksi", fb(12))
    # Reset — icon 12->14, label 16->11
    disc_m(base, 620, 1300, 34, 70, ring_w=4)
    ico_reset(d, 620, 1300, 14, col=GELAP)
    teks_tombol(base, (620, 1345), "Reset", fb(11))


def build_putih_v2():
    base = latar_putih()
    minimap_p(base)
    bar_atas_m(base)
    pill_m(base)
    analog_m(base)
    klaster_m(base)
    out = OUTDIR + "hud-v3-desain-putih-v2.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------- varian G — GAMEPAD (revisi BESAR mockup putih v2) ----------------
# Verdict Mas 17:04 WIB atas mockup putih v2: "Coba tanpa outline dan warna
# hitam ganti warna putih agak transparan.. teks juga tanpa outline dan kecilin
# aja.. kalau bisa taruh di dalam tombol aja.. dan icon ganti Segitiga, kotak,
# bulan dan X.. nanti fungsinya kek joystick.. fleksibel sesuai scene atau
# misi.. dan kasih petunjuk untuk player baru.. fungsi tiap tombol... dan tata
# letak tombol sama seperti di joystick"
# Aturan varian ini (arahan Xam):
#  (1) TANPA outline: semua outline GELAP dibuang — hairline di dalam ring,
#      outline label, semuanya. Ring putih v2 juga dibuang (itu outline).
#      Disc = isi putih translusen saja.
#  (2) Hitam -> PUTIH agak transparan (alpha ~180-195): semua icon + teks,
#      termasuk chevron analog.
#  (3) Teks tanpa outline, LEBIH KECIL, DI DALAM tombol (di bawah icon bentuk).
#  (4) Icon = bentuk gamepad: Segitiga, Kotak, Bulan (sabit), X.
#      "Bulan" Mas digambar SABIT — kalau yang dimaksud lingkaran ala
#      PlayStation, tinggal ganti satu fungsi.
#  (5) Tata letak DIAMOND ala joystick/gamepad: Segitiga atas, Kotak kiri,
#      Bulan kanan, X bawah. Klaster ini MENGGANTIKAN klaster lama
#      (Interact/Kamera/Aksi/Reset).
#  (6) Fungsi FLEKSIBEL (kontekstual per scene/misi). Mockup ini pakai
#      pemetaan CONTOH scene idle/misi: X = Mulai Misi (aksi utama, posisi
#      jempol), Segitiga = Aksi, Kotak = Kamera, Bulan = Reset. BUKAN final —
#      Mas yang menentukan pemetaan akhirnya.
#  (7) PETUNJUK pemain baru: kartu legenda kecil di tengah bawah (antara
#      analog dan klaster) — bentuk + fungsi tiap tombol di scene ini,
#      ada tombol tutup (x), isinya ikut berubah sesuai scene/misi.
# CATATAN TEKNIS: semua elemen putih ber-alpha HARUS digambar di layer
# transparan lalu alpha_composite — ImageDraw langsung di base RGBA tidak
# mem-blend alpha (pelajaran lama skrip ini).

PUTIH_T = (255, 255, 255, 190)    # icon/bentuk putih agak transparan


def _lapis(base):
    """Layer transparan baru + Draw-nya (untuk elemen ber-alpha)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    return layer, ImageDraw.Draw(layer)


def teks_putih(base, xy, s, font, alpha=195, anchor="mm"):
    """Teks PUTIH agak transparan TANPA outline (arahan Mas 17:04)."""
    layer, d = _lapis(base)
    d.text(xy, s, font=font, fill=(255, 255, 255, alpha), anchor=anchor)
    base.alpha_composite(layer)


def disc_g(base, cx, cy, r, alpha_fill=70):
    """Disc PUTIH TRANSLUSEN tanpa outline sama sekali: isi putih
    ber-alpha saja — batas disc hanya dari selisih tembus pandang."""
    layer, d = _lapis(base)
    d.ellipse([cx - r, cy - r, cx + r, cy + r],
              fill=(255, 255, 255, alpha_fill))
    base.alpha_composite(layer)


def ico_segitiga(d, cx, cy, s, col=PUTIH_T):
    """Segitiga PADAT (bukan outline) menghadap atas."""
    d.polygon([(cx, cy - s),
               (cx - s * 0.92, cy + s * 0.72),
               (cx + s * 0.92, cy + s * 0.72)], fill=col)


def ico_kotak(d, cx, cy, s, col=PUTIH_T):
    """Kotak PADAT (bukan outline), sudut sedikit membulat."""
    d.rounded_rectangle([cx - s, cy - s, cx + s, cy + s],
                        radius=int(s * 0.22), fill=col)


def ico_x(d, cx, cy, s, col=PUTIH_T):
    """X PADAT: dua batang miring 45 derajat."""
    w = s * 0.42
    for ang in (45, -45):
        a = math.radians(ang)
        ux, uy = math.cos(a), math.sin(a)
        px, py = -uy, ux
        d.polygon([(cx + ux * s + px * w, cy + uy * s + py * w),
                   (cx + ux * s - px * w, cy + uy * s - py * w),
                   (cx - ux * s - px * w, cy - uy * s - py * w),
                   (cx - ux * s + px * w, cy - uy * s + py * w)], fill=col)


def ico_bulan_layer(layer, cx, cy, r, col=PUTIH_T):
    """Bulan SABIT padat: lingkaran penuh dikurangi lingkaran geser
    (via mask — ditempel ke layer yang diberikan)."""
    pad = 4
    size = 2 * r + 2 * pad
    m = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(m)
    md.ellipse([pad, pad, pad + 2 * r, pad + 2 * r], fill=255)
    bx = pad + int(r * 0.55)
    by = pad - int(r * 0.18)
    md.ellipse([bx, by, bx + 2 * r, by + 2 * r], fill=0)
    tile = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    solid = Image.new("RGBA", (size, size), col)
    tile.paste(solid, (0, 0), m)
    layer.alpha_composite(tile, (cx - r - pad, cy - r - pad))


def minimap_g(base):
    """Minimap seperti v2 (disc + titik + segitiga emas), TAPI teks status
    TANPA outline hitam (arahan 'tanpa outline' — teks putih polos).
    Outline PUTIH disc minimap dipertahankan (bukan outline gelap)."""
    layer, d = _lapis(base)
    d.ellipse([16, 60, 128, 172], fill=(10, 25, 20, 210))
    d.ellipse([16, 60, 128, 172], outline=(255, 255, 255, 200), width=2)
    for (x, y) in [(45, 94), (95, 84), (60, 144), (100, 139), (85, 109)]:
        d.ellipse([x - 3, y - 3, x + 3, y + 3], fill=(180, 220, 190, 255))
    d.polygon([(72, 100), (64, 116), (80, 116)], fill=(201, 162, 39, 255))
    base.alpha_composite(layer)
    teks_putih(base, (8, 10), "Poin: 0", fr(15), alpha=220, anchor="la")
    teks_putih(base, (8, 27), "Misi: Misi 1 — Kenalan dengan Nahwu", fr(15),
               alpha=220, anchor="la")
    teks_putih(base, (8, 44), "Offline", fr(15), alpha=220, anchor="la")


def bar_atas_g(base):
    """Strip atas PUTIH TRANSLUSEN, TANPA outline (v2 masih punya outline
    putih 2 px — dibuang). Icon PUTIH agak transparan."""
    layer, d = _lapis(base)
    d.rounded_rectangle([488, 8, 714, 54], radius=14,
                        fill=(255, 255, 255, 130))
    icons = [ico_kartu, ico_peta, ico_amplop, ico_suara, ico_fullscreen]
    xs = [514, 558, 602, 646, 690]
    for f, x in zip(icons, xs):
        f(d, x, 30, 14, col=PUTIH_T)
    base.alpha_composite(layer)


def pill_g(base):
    """Pill 'Main Bersama' — isi putih translusen saja, TANPA outline/ring.
    Teks putih agak transparan, tanpa outline, dikecilkan 13->12."""
    f = fb(12)
    d_tmp = ImageDraw.Draw(base)
    tw = d_tmp.textbbox((0, 0), "Main Bersama", font=f)[2]
    w = tw + 48
    x0, x1 = 160, 160 + w
    y0, y1 = 74, 112
    layer, d = _lapis(base)
    d.rounded_rectangle([x0, y0, x1, y1], radius=19,
                        fill=(255, 255, 255, 80))
    base.alpha_composite(layer)
    teks_putih(base, ((x0 + x1) // 2, (y0 + y1) // 2), "Main Bersama", f)


def analog_g(base):
    """Analog ala joystick lama — TANPA outline/ring: disc + knob isi
    putih translusen saja, chevron PUTIH agak transparan (dulu gelap)."""
    cx, cy, r = 128, 1428, 120
    disc_g(base, cx, cy, r, 55)
    disc_g(base, cx, cy, 50, 130)
    layer, d = _lapis(base)
    for ang in (-90, 0, 90, 180):
        chevron(d, cx, cy, 84, 64, 11, ang, PUTIH_T)
    base.alpha_composite(layer)


def klaster_gamepad(base):
    """Klaster DIAMOND ala joystick/gamepad — MENGGANTIKAN klaster lama.
    Segitiga atas, Kotak kiri, Bulan kanan, X bawah. Icon bentuk PUTIH
    agak transparan, label fungsi KECIL DI DALAM tombol (di bawah icon),
    tanpa outline. Pemetaan CONTOH scene idle/misi (BUKAN final):
    X = Mulai Misi (aksi utama, posisi jempol), Segitiga = Aksi,
    Kotak = Kamera, Bulan = Reset."""
    # disc dulu (isi saja, tanpa outline)
    disc_g(base, 575, 1310, 50, 70)   # Segitiga atas
    disc_g(base, 490, 1395, 50, 70)   # Kotak kiri
    disc_g(base, 660, 1395, 50, 70)   # Bulan kanan
    disc_g(base, 575, 1480, 62, 70)   # X bawah (aksi utama, sedikit lebih besar)
    layer, d = _lapis(base)
    ico_segitiga(d, 575, 1300, 17)    # Segitiga, icon di atas tengah disc
    ico_kotak(d, 490, 1385, 16)       # Kotak
    ico_bulan_layer(layer, 660, 1385, 17)  # Bulan sabit
    ico_x(d, 575, 1464, 24)           # X
    base.alpha_composite(layer)
    # label DI DALAM tombol, kecil, tanpa outline
    teks_putih(base, (575, 1332), "AKSI", fb(10))
    teks_putih(base, (490, 1417), "KAMERA", fb(10))
    teks_putih(base, (660, 1417), "RESET", fb(10))
    teks_putih(base, (575, 1508), "MULAI MISI", fb(10))


def petunjuk_g(base):
    """PETUNJUK pemain baru — kartu legenda kecil di tengah bawah (antara
    analog dan klaster): bentuk + fungsi tiap tombol di scene ini.
    Muncul untuk pemain baru, bisa ditutup (x di pojok), isinya ikut
    berubah sesuai scene/misi. Isi putih translusen, teks putih agak
    transparan, tanpa outline."""
    box = [256, 1380, 436, 1540]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=16, fill=(255, 255, 255, 85))
    base.alpha_composite(layer)
    teks_putih(base, (346, 1398), "PETUNJUK TOMBOL", fb(11), alpha=200)
    teks_putih(base, (424, 1398), "×", fb(14), alpha=200)
    # 4 baris: bentuk kecil + fungsi (pemetaan contoh scene idle/misi)
    layer2, d2 = _lapis(base)
    ico_segitiga(d2, 276, 1424, 8)
    ico_kotak(d2, 276, 1450, 8)
    ico_bulan_layer(layer2, 276, 1476, 8)
    ico_x(d2, 276, 1502, 8)
    base.alpha_composite(layer2)
    teks_putih(base, (292, 1424), "Aksi", fb(11), anchor="lm")
    teks_putih(base, (292, 1450), "Kamera", fb(11), anchor="lm")
    teks_putih(base, (292, 1476), "Reset", fb(11), anchor="lm")
    teks_putih(base, (292, 1502), "Mulai Misi", fb(11), anchor="lm")
    teks_putih(base, (346, 1528), "Fungsi tombol berubah sesuai misi",
               fr(9), alpha=170)


def build_gamepad():
    base = latar_putih()
    minimap_g(base)
    bar_atas_g(base)
    pill_g(base)
    analog_g(base)
    klaster_gamepad(base)
    petunjuk_g(base)
    out = OUTDIR + "hud-v3-desain-gamepad.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------------------------------------------------------------------
# VARIAN G2 — revisi gamepad per arahan Mas 17:15 WIB (+ gambar referensi
# stik PS5 DualSense): icon bentuk HANYA OUTLINE TIPIS (bukan padat),
# BULAN SABIT -> LINGKARAN, petunjuk jadi POP-UP awal main (bisa di-close).
# ---------------------------------------------------------------------------

def ico_segitiga_o(d, cx, cy, s, col=PUTIH_T, w=3):
    """Segitiga OUTLINE TIPIS (ala simbol stik PS5), menghadap atas."""
    d.polygon([(cx, cy - s),
               (cx - s * 0.92, cy + s * 0.72),
               (cx + s * 0.92, cy + s * 0.72)],
              outline=col, width=w)


def ico_kotak_o(d, cx, cy, s, col=PUTIH_T, w=3):
    """Kotak OUTLINE TIPIS, sudut sedikit membulat."""
    d.rounded_rectangle([cx - s, cy - s, cx + s, cy + s],
                        radius=int(s * 0.22), outline=col, width=w)


def ico_lingkaran_o(d, cx, cy, r, col=PUTIH_T, w=3):
    """Lingkaran OUTLINE TIPIS (tombol bulat ala PlayStation) —
    MENGGANTIKAN bulan sabit v1 (Mas 17:15: 'kok jadi bulan sabit')."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=col, width=w)


def ico_x_o(d, cx, cy, s, col=PUTIH_T, w=4):
    """X TIPIS: dua garis miring 45 derajat (bukan batang padat tebal)."""
    d.line([(cx - s * 0.72, cy - s * 0.72), (cx + s * 0.72, cy + s * 0.72)],
           fill=col, width=w)
    d.line([(cx - s * 0.72, cy + s * 0.72), (cx + s * 0.72, cy - s * 0.72)],
           fill=col, width=w)


def klaster_gamepad_v2(base):
    """Klaster DIAMOND sama seperti v1, TAPI icon bentuk jadi OUTLINE
    TIPIS (bukan padat) dan BULAN SABIT diganti LINGKARAN. X ditipiskan.
    Pemetaan contoh tetap: X = Mulai Misi, Segitiga = Aksi,
    Kotak = Kamera, Lingkaran = Reset."""
    disc_g(base, 575, 1310, 50, 70)   # Segitiga atas
    disc_g(base, 490, 1395, 50, 70)   # Kotak kiri
    disc_g(base, 660, 1395, 50, 70)   # Lingkaran kanan
    disc_g(base, 575, 1480, 62, 70)   # X bawah (aksi utama)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 575, 1300, 17)
    ico_kotak_o(d, 490, 1385, 16)
    ico_lingkaran_o(d, 660, 1385, 17)
    ico_x_o(d, 575, 1464, 24)
    base.alpha_composite(layer)
    # label DI DALAM tombol, kecil, tanpa outline (sama seperti v1)
    teks_putih(base, (575, 1332), "AKSI", fb(10))
    teks_putih(base, (490, 1417), "KAMERA", fb(10))
    teks_putih(base, (660, 1417), "RESET", fb(10))
    teks_putih(base, (575, 1508), "MULAI MISI", fb(10))


def popup_petunjuk(base):
    """POP-UP petunjuk pemain baru — muncul KETIKA AWAL MAIN (pertama
    kali main), bisa di-CLOSE (tombol x pojok + tombol 'Mengerti').
    Panel di TENGAH layar; scene/HUD di belakang sedikit di-dim, TAPI
    klaster tombol diamond + analog TIDAK tertutup pop-up (panel
    y 500..940, klaster mulai 1310, analog 1428). Isi: judul + 4 baris
    bentuk (outline tipis) + fungsi + catatan 'Fungsi tombol berubah
    sesuai misi'. Semuanya putih, polos transparan."""
    # dim: selubung hitam tipis di seluruh layar
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 65))
    base.alpha_composite(layer)
    # panel: putih translusen alpha 150 — di atas latar yang di-dim,
    # panel jadi abu-abu sedang sehingga teks putih terbaca, tapi
    # tetap terasa transparan (bukan kartu putih pekat)
    box = [120, 500, 600, 940]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=20, fill=(255, 255, 255, 150))
    base.alpha_composite(layer)
    # judul + tombol tutup x
    teks_putih(base, (360, 548), "PETUNJUK TOMBOL", fb(15), alpha=210)
    teks_putih(base, (568, 540), "×", fb(18), alpha=210)
    # 4 baris: bentuk outline tipis + fungsi (pemetaan contoh)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 185, 625, 12, w=2)
    ico_kotak_o(d, 185, 678, 12, w=2)
    ico_lingkaran_o(d, 185, 731, 12, w=2)
    ico_x_o(d, 185, 784, 12, w=3)
    base.alpha_composite(layer)
    teks_putih(base, (212, 625), "Aksi", fb(13), anchor="lm", alpha=210)
    teks_putih(base, (212, 678), "Kamera", fb(13), anchor="lm", alpha=210)
    teks_putih(base, (212, 731), "Reset", fb(13), anchor="lm", alpha=210)
    teks_putih(base, (212, 784), "Mulai Misi", fb(13), anchor="lm", alpha=210)
    teks_putih(base, (360, 838), "Fungsi tombol berubah sesuai misi",
               fr(11), alpha=185)
    # tombol 'Mengerti': pill outline putih + teks putih (tanpa isi padat)
    layer, d = _lapis(base)
    d.rounded_rectangle([270, 862, 450, 906], radius=22,
                        outline=(255, 255, 255, 215), width=2)
    base.alpha_composite(layer)
    teks_putih(base, (360, 884), "Mengerti", fb(13), alpha=215)


def build_gamepad_v2():
    base = latar_putih()
    minimap_g(base)
    bar_atas_g(base)
    pill_g(base)
    analog_g(base)
    klaster_gamepad_v2(base)
    popup_petunjuk(base)
    out = OUTDIR + "hud-v3-desain-gamepad-v2.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------- varian G3 — revisi gamepad per arahan Mas 17:26 WIB ------
# "Tulisan di petunjuk warna hitam aja biar bisa dibaca.. Terus tombol
# tanpa teks.. dan ukuran tombol harus sama"
#  (1) Semua TEKS di pop-up petunjuk jadi HITAM (judul, 4 baris fungsi,
#      catatan kaki, teks 'Mengerti', tombol tutup x) supaya bisa dibaca.
#  (2) Tombol TANPA TEKS — label di dalam disc dihapus, tombol hanya
#      icon bentuk outline-nya saja.
#  (3) Keempat tombol UKURAN SAMA — X yang dulu r=62 disamakan r=50.
# KEPUTUSAN XAM (dilaporkan ke Mas, bisa dikoreksi): bentuk outline kecil
# di baris pop-up (△ □ ○ ✕) ikut dibuat outline HITAM, supaya satu baris
# terbaca utuh di atas panel terang. Outline pill 'Mengerti' juga hitam
# (outline putih di atas panel pucat nyaris tidak kelihatan).
# ---------------------------------------------------------------------------

HITAM_T = (0, 0, 0, 220)   # teks/bentuk hitam di pop-up (pekat, terbaca)


def teks_hitam(base, xy, s, font, alpha=220, anchor="mm"):
    """Teks HITAM tanpa outline (arahan Mas 17:26: tulisan di petunjuk
    warna hitam supaya bisa dibaca)."""
    layer, d = _lapis(base)
    d.text(xy, s, font=font, fill=(0, 0, 0, alpha), anchor=anchor)
    base.alpha_composite(layer)


def klaster_gamepad_v3(base):
    """Klaster DIAMOND — revisi per arahan Mas 17:26 WIB:
    (1) TANPA TEKS di dalam tombol (label AKSI/KAMERA/RESET/MULAI MISI
    dihapus — tombol hanya icon bentuk outline);
    (2) KEEMPAT tombol UKURAN SAMA (X yang dulu r=62 disamakan r=50
    dengan tiga lainnya). Icon dipusatkan di tengah disc (tidak ada
    label lagi di bawahnya). Diamond tetap: △ atas, □ kiri, ○ kanan,
    ✕ bawah. Pemetaan contoh tetap: ✕ = Mulai Misi, △ = Aksi,
    □ = Kamera, ○ = Reset — fungsinya hanya diketahui dari pop-up
    petunjuk (sesuai arahan Mas)."""
    disc_g(base, 575, 1310, 50, 70)   # Segitiga atas
    disc_g(base, 490, 1395, 50, 70)   # Kotak kiri
    disc_g(base, 660, 1395, 50, 70)   # Lingkaran kanan
    disc_g(base, 575, 1480, 50, 70)   # X bawah — SAMA BESAR (dulu 62)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 575, 1310, 18)
    ico_kotak_o(d, 490, 1395, 17)
    ico_lingkaran_o(d, 660, 1395, 18)
    ico_x_o(d, 575, 1480, 26)
    base.alpha_composite(layer)


def popup_petunjuk_v3(base):
    """POP-UP petunjuk — revisi per arahan Mas 17:26 WIB: SEMUA teks
    jadi HITAM (judul, 4 baris fungsi, catatan kaki, tombol 'Mengerti',
    tombol tutup ×) supaya bisa dibaca di atas panel terang.
    Panel tetap putih translusen alpha 150, scene di belakang di-dim."""
    # dim: selubung hitam tipis di seluruh layar
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 65))
    base.alpha_composite(layer)
    # panel: putih translusen alpha 150 (sama seperti v2)
    box = [120, 500, 600, 940]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=20, fill=(255, 255, 255, 150))
    base.alpha_composite(layer)
    # judul + tombol tutup x — HITAM
    teks_hitam(base, (360, 548), "PETUNJUK TOMBOL", fb(15), alpha=220)
    teks_hitam(base, (568, 540), "×", fb(18), alpha=220)
    # 4 baris: bentuk outline HITAM + fungsi HITAM (keputusan Xam)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 185, 625, 12, col=HITAM_T, w=2)
    ico_kotak_o(d, 185, 678, 12, col=HITAM_T, w=2)
    ico_lingkaran_o(d, 185, 731, 12, col=HITAM_T, w=2)
    ico_x_o(d, 185, 784, 12, col=HITAM_T, w=3)
    base.alpha_composite(layer)
    teks_hitam(base, (212, 625), "Aksi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 678), "Kamera", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 731), "Reset", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 784), "Mulai Misi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (360, 838), "Fungsi tombol berubah sesuai misi",
               fr(11), alpha=200)
    # tombol 'Mengerti': pill outline HITAM + teks HITAM
    layer, d = _lapis(base)
    d.rounded_rectangle([270, 862, 450, 906], radius=22,
                        outline=(0, 0, 0, 220), width=2)
    base.alpha_composite(layer)
    teks_hitam(base, (360, 884), "Mengerti", fb(13), alpha=220)


def build_gamepad_v3():
    base = latar_putih()
    minimap_g(base)
    bar_atas_g(base)
    pill_g(base)
    analog_g(base)
    klaster_gamepad_v3(base)
    popup_petunjuk_v3(base)
    out = OUTDIR + "hud-v3-desain-gamepad-v3.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------- varian K — PERBAIKAN KONTRAS (18 Nov 2026, 18:26) ------
# Keputusan Mas 18:26 WIB: "Perbaiki kontras dulu, desain dulu".
# Masalah (TERBUKTI di foto implementasi hud-v3-idle.png, bukan dugaan):
# di lantai marmer putih depan Surau (tempat spawn), klaster diamond +
# analog + pill "Main Bersama" NYARIS HILANG TOTAL — disc putih translusen
# (alpha 70) + icon outline putih (alpha 190) di atas lantai putih = nol
# kontras. Latar rumput hijau di mockup G3 menyembunyikan cacat ini.
# Pop-up di implementasi juga meleset dari G3: panel SANGAT translusen
# (pemain + jendela menembus kuat) dan layout timpang (baris menumpuk di
# kiri atas, setengah bawah panel kosong, "Mengerti" menimpa nama pemain).
# Perbaikan (TANPA mengubah konsep yang di-ACC: tetap 4 tombol diamond
# sama besar, icon △ □ ○ ✕ outline tipis, tanpa teks, analog putih
# translusen, pop-up pertama main):
#  (1) Disc KACA BURAM BERTINTA: isi BUKAN putih murni — putih kehijauan
#      sangat muda (tint zamrud, (222,234,228)) alpha 150. CATATAN FISIS:
#      putih murni seberapa pun alpha-nya TIDAK PERNAH terlihat di atas
#      lantai putih (hanya bisa makin putih); tint tipis inilah yang
#      membuat tepi disc terbaca sebagai kaca buram. Tetap translusen
#      (lantai masih tembus samar), bukan kartu pekat.
#  (2) BAYANGAN JATUH lembut di bawah tiap disc (hitam alpha 70, blur 8,
#      turun 6 px): tombol terasa mengambang ala game 3D. Ini BAYANGAN,
#      bukan outline/rim/gloss — bukan "timbul" yang ditolak Mas.
#  (3) Icon + chevron + teks pill: outline ZAMRUD GELAP #043B2C (bukan
#      putih, bukan hitam — hitam ditolak Mas 17:04; zamrud gelap = warna
#      game sendiri, konsisten dengan style 3D yang sudah bagus),
#      sedikit lebih tebal (3->4, X 4->5) dan sedikit lebih besar.
#  (4) Pop-up: panel alpha 150 -> 225 (adegan belakang nyaris tak tembus)
#      + dim 65 -> 80 + layout KEMBALI ke G3 yang seimbang (baris
#      tersebar rata, 'Mengerti' di bawah tengah, tidak menimpa apa pun).
# Varian K-A = perbaikan lengkap (tint + bayangan + icon zamrud).
# Varian K-B = perbaikan TANPA bayangan (hanya tint + icon zamrud) —
#   untuk Mas bila bayangan terasa 'timbul'.
# Varian K2 = pop-up perbaikan (di atas HUD varian A).
# Latar SEMUA varian K: foto implementasi hud-v3-idle.png (lantai marmer
# putih spawn), BUKAN slice rumput. Elemen yang sudah terbaca di foto
# (minimap + strip atas, berlatar langit) TIDAK digambar ulang — hanya
# analog, klaster, pill (yang hilang) + pop-up yang diperbaiki.

FROST = (222, 234, 228)        # kaca buram putih-kehijauan (tint zamrud muda)
FROST_KNOB = (212, 228, 220)   # knob sedikit lebih pekat dari disc
ZAMRUD_GELAP = (4, 59, 44, 235)  # icon/chevron/teks — zamrud gelap game


def latar_implementasi():
    """Latar = foto implementasi HUD v3 (lantai marmer putih spawn)."""
    return Image.open(
        "/home/hatch/workspace/pesantren-verse/v2/foto-hud/hud-v3-idle.png"
    ).convert("RGBA")


def disc_k(base, cx, cy, r, alpha_fill=150, shadow=True,
           tint=FROST):
    """Disc KACA BURAM BERTINTA + bayangan jatuh lembut. Tanpa rim/
    outline/gloss. Disc baru menutup disc lama yang nyaris tak terlihat
    (posisi + ukuran sama persis dengan G3)."""
    if shadow:
        bayang(base, cx, cy, r, dy=6, alpha=70, blur=8)
    layer, d = _lapis(base)
    d.ellipse([cx - r, cy - r, cx + r, cy + r],
              fill=tint + (alpha_fill,))
    base.alpha_composite(layer)


def bayang_pill(base, box, dy=5, alpha=60, blur=7):
    """Bayangan jatuh untuk pill (rounded rect, bukan elips)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([box[0], box[1] + dy, box[2], box[3] + dy],
                        radius=19, fill=(0, 0, 0, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def teks_zamrud(base, xy, s, font, alpha=235, anchor="mm"):
    """Teks ZAMRUD GELAP tanpa outline (untuk pill 'Main Bersama')."""
    layer, d = _lapis(base)
    d.text(xy, s, font=font, fill=(4, 59, 44, alpha), anchor=anchor)
    base.alpha_composite(layer)


def pill_k(base, shadow=True):
    """Pill 'Main Bersama' — kaca buram bertinta + bayangan + teks
    ZAMRUD GELAP (dulu teks putih di atas isi putih = tak terbaca).
    Posisi sama seperti G3: x0=160, y 74-112."""
    f = fb(12)
    d_tmp = ImageDraw.Draw(base)
    tw = d_tmp.textbbox((0, 0), "Main Bersama", font=f)[2]
    w = tw + 48
    x0, x1 = 160, 160 + w
    y0, y1 = 74, 112
    box = [x0, y0, x1, y1]
    if shadow:
        bayang_pill(base, box)
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=19, fill=FROST + (150,))
    base.alpha_composite(layer)
    teks_zamrud(base, ((x0 + x1) // 2, (y0 + y1) // 2), "Main Bersama", f)


def analog_k(base, shadow=True):
    """Analog — disc + knob kaca buram bertinta + bayangan, chevron
    ZAMRUD GELAP (dulu putih). Posisi + ukuran sama seperti G3."""
    cx, cy, r = 128, 1428, 120
    disc_k(base, cx, cy, r, 150, shadow)
    disc_k(base, cx, cy, 50, 170, shadow, tint=FROST_KNOB)
    layer, d = _lapis(base)
    for ang in (-90, 0, 90, 180):
        chevron(d, cx, cy, 84, 64, 11, ang, ZAMRUD_GELAP)
    base.alpha_composite(layer)


def klaster_k(base, shadow=True):
    """Klaster DIAMOND — disc kaca buram + bayangan, icon bentuk
    outline ZAMRUD GELAP sedikit lebih tebal/besar (3->4, X 4->5;
    ukuran 18/17/18/26 -> 20/19/20/28). Tanpa teks, ukuran sama.
    Pemetaan REVISI 18:33 (Mas: "Kotak ganti chat"): ✕ = Mulai Misi,
    △ = Aksi, □ = Chat, ○ = Reset. Icon □ TIDAK berubah bentuk —
    hanya fungsinya yang jadi Chat (terlihat di pop-up, bukan di
    klaster)."""
    disc_k(base, 575, 1310, 50, 150, shadow)   # Segitiga atas
    disc_k(base, 490, 1395, 50, 150, shadow)   # Kotak kiri
    disc_k(base, 660, 1395, 50, 150, shadow)   # Lingkaran kanan
    disc_k(base, 575, 1480, 50, 150, shadow)   # X bawah
    layer, d = _lapis(base)
    ico_segitiga_o(d, 575, 1310, 20, col=ZAMRUD_GELAP, w=4)
    ico_kotak_o(d, 490, 1395, 19, col=ZAMRUD_GELAP, w=4)
    ico_lingkaran_o(d, 660, 1395, 20, col=ZAMRUD_GELAP, w=4)
    ico_x_o(d, 575, 1480, 28, col=ZAMRUD_GELAP, w=5)
    base.alpha_composite(layer)


def popup_k(base):
    """POP-UP petunjuk — perbaikan dari implementasi: panel KURANG
    translusen (alpha 150 -> 225, adegan belakang nyaris tak tembus),
    dim 65 -> 80, dan layout KEMBALI ke G3 yang seimbang (judul tengah,
    4 baris tersebar rata, catatan kaki, 'Mengerti' di bawah tengah —
    tidak menimpa apa pun). Teks + bentuk tetap HITAM (keputusan Mas
    17:26). Panel di tengah layar, klaster + analog tidak tertutup."""
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 80))
    base.alpha_composite(layer)
    box = [120, 500, 600, 940]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=20, fill=(255, 255, 255, 225))
    base.alpha_composite(layer)
    teks_hitam(base, (360, 548), "PETUNJUK TOMBOL", fb(15), alpha=220)
    teks_hitam(base, (568, 540), "×", fb(18), alpha=220)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 185, 625, 12, col=HITAM_T, w=2)
    ico_kotak_o(d, 185, 678, 12, col=HITAM_T, w=2)
    ico_lingkaran_o(d, 185, 731, 12, col=HITAM_T, w=2)
    ico_x_o(d, 185, 784, 12, col=HITAM_T, w=3)
    base.alpha_composite(layer)
    teks_hitam(base, (212, 625), "Aksi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 678), "Kamera", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 731), "Reset", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 784), "Mulai Misi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (360, 838), "Fungsi tombol berubah sesuai misi",
               fr(11), alpha=200)
    layer, d = _lapis(base)
    d.rounded_rectangle([270, 862, 450, 906], radius=22,
                        outline=(0, 0, 0, 220), width=2)
    base.alpha_composite(layer)
    teks_hitam(base, (360, 884), "Mengerti", fb(13), alpha=220)


def build_perbaikan_a():
    base = latar_implementasi()
    pill_k(base, shadow=True)
    analog_k(base, shadow=True)
    klaster_k(base, shadow=True)
    out = OUTDIR + "hud-v3-perbaikan-a.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


def build_perbaikan_b():
    base = latar_implementasi()
    pill_k(base, shadow=False)
    analog_k(base, shadow=False)
    klaster_k(base, shadow=False)
    out = OUTDIR + "hud-v3-perbaikan-b.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


def build_perbaikan_popup():
    base = latar_implementasi()
    pill_k(base, shadow=True)
    analog_k(base, shadow=True)
    klaster_k(base, shadow=True)
    popup_k(base)
    out = OUTDIR + "hud-v3-perbaikan-popup.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ---------------- varian R — REVISI PEMETAAN (18 Nov 2026, 18:33) ------
# Arahan Mas 18:33 WIB: "Kotak ganti chat aja ya.. kamera taruh di menu atas.."
#  - Tombol □ klaster diamond: Kamera -> Chat.
#  - Kamera PINDAH ke menu atas (strip atas).
#  - Pemetaan baru: ✕ = Mulai Misi, △ = Aksi, □ = Chat, ○ = Reset.
# KEPUTUSAN TARA (dicatat di laporan, bisa dikoreksi Mas): strip atas di
# game SUDAH punya icon amplop = tombol Chat (_chat_ikon_btn, ui.gd:1155).
# Karena Chat pindah ke □, icon amplop di strip atas DIGANTI icon kamera
# (slot ke-3 dari 5) — BUKAN ditambah jadi icon ke-6 (strip jadi berdesakan
# + Chat dobel di dua tempat). Strip tetap 5 icon, jarak sama. Icon □ di
# klaster TIDAK berubah bentuk (tetap kotak outline zamrud gelap) — hanya
# fungsinya yang jadi Chat, jadi klaster tidak digambar ulang; di pop-up
# hanya label baris □ ("Kamera" -> "Chat") + catatan kaki yang berubah.
# Strip di FOTO IMPLEMENTASI (bukan mockup): 5 tile kaca TERPISAH (bukan
# satu bar gelap) — terukur dari foto: tile 26x26, y 8..33, pusat x
# 578/608/638/668/698, isi putih alpha 128. Revisi: tile lama dihapus
# (langit solid + klon kubah), 5 tile baru digambar dengan icon
# kartu/peta/KAMERA/suara/fullscreen.
# File BARU (Mas belum memilih A atau B — A/B/pop-up lama TIDAK ditimpa):
# hud-v3-perbaikan-a-rev1.png, hud-v3-perbaikan-b-rev1.png,
# hud-v3-perbaikan-popup-rev1.png.

def strip_kamera(base):
    """Strip atas di foto implementasi: amplop (Chat) -> kamera.
    Hapus 5 tile lama (langit solid x 560..618 + klon kubah x 618..714
    dari y 38..64 — kubah nyaris seragam vertikal di x tetap), lalu
    gambar 5 tile kaca baru (putih alpha 128) + 5 icon putih (kartu,
    peta, KAMERA, suara, fullscreen)."""
    d0 = ImageDraw.Draw(base)
    d0.rectangle([560, 6, 618, 36], fill=(133, 173, 196, 255))
    kubah = base.crop((618, 38, 714, 64))
    base.paste(kubah, (618, 8))
    layer, d = _lapis(base)
    for cx in (578, 608, 638, 668, 698):
        d.rounded_rectangle([cx - 13, 8, cx + 13, 34], radius=6,
                            fill=(255, 255, 255, 128))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    ico_kartu(d2, 578, 21, 9)
    ico_peta(d2, 608, 21, 9)
    ico_kamera_strip(d2, 638, 21, 9)
    ico_suara(d2, 668, 21, 9)
    ico_fullscreen(d2, 698, 21, 9)


def ico_kamera_strip(d, cx, cy, s):
    """Kamera PUTIH untuk strip atas: badan putih, lensa cincin putih
    + titik ZAMRUD (lensa terbaca di atas tile terang, konsisten palet
    game — icon lain di strip tetap putih polos)."""
    d.rounded_rectangle([cx - s, cy - s * 0.55, cx + s, cy + s * 0.6],
                        radius=int(s * 0.25), fill=PUTIH)
    d.ellipse([cx - s * 0.45, cy - s * 0.45, cx + s * 0.45, cy + s * 0.45],
              outline=PUTIH, width=max(2, int(s * 0.12)))
    d.ellipse([cx - s * 0.18, cy - s * 0.18, cx + s * 0.18, cy + s * 0.18],
              fill=ZAMRUD)
    d.rectangle([cx - s * 0.45, cy - s * 0.85, cx + s * 0.25, cy - s * 0.5],
                fill=PUTIH)


def popup_k2(base):
    """POP-UP petunjuk — revisi pemetaan 18:33: baris □ jadi 'Chat'
    (dulu 'Kamera'); catatan kaki ditambah 'Kamera ada di menu atas'.
    Panel + dim + layout sama seperti popup_k (alpha 225, dim 80,
    seimbang ala G3). Teks + bentuk tetap HITAM."""
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 80))
    base.alpha_composite(layer)
    box = [120, 500, 600, 940]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=20, fill=(255, 255, 255, 225))
    base.alpha_composite(layer)
    teks_hitam(base, (360, 548), "PETUNJUK TOMBOL", fb(15), alpha=220)
    teks_hitam(base, (568, 540), "×", fb(18), alpha=220)
    layer, d = _lapis(base)
    ico_segitiga_o(d, 185, 625, 12, col=HITAM_T, w=2)
    ico_kotak_o(d, 185, 678, 12, col=HITAM_T, w=2)
    ico_lingkaran_o(d, 185, 731, 12, col=HITAM_T, w=2)
    ico_x_o(d, 185, 784, 12, col=HITAM_T, w=3)
    base.alpha_composite(layer)
    teks_hitam(base, (212, 625), "Aksi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 678), "Chat", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 731), "Reset", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (212, 784), "Mulai Misi", fb(13), anchor="lm", alpha=220)
    teks_hitam(base, (360, 838),
               "Kamera ada di menu atas • Fungsi tombol berubah sesuai misi",
               fr(11), alpha=200)
    layer, d = _lapis(base)
    d.rounded_rectangle([270, 862, 450, 906], radius=22,
                        outline=(0, 0, 0, 220), width=2)
    base.alpha_composite(layer)
    teks_hitam(base, (360, 884), "Mengerti", fb(13), alpha=220)


def build_perbaikan_a_rev1():
    base = latar_implementasi()
    strip_kamera(base)
    pill_k(base, shadow=True)
    analog_k(base, shadow=True)
    klaster_k(base, shadow=True)
    out = OUTDIR + "hud-v3-perbaikan-a-rev1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


def build_perbaikan_b_rev1():
    base = latar_implementasi()
    strip_kamera(base)
    pill_k(base, shadow=False)
    analog_k(base, shadow=False)
    klaster_k(base, shadow=False)
    out = OUTDIR + "hud-v3-perbaikan-b-rev1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


def build_perbaikan_popup_rev1():
    base = latar_implementasi()
    strip_kamera(base)
    pill_k(base, shadow=True)
    analog_k(base, shadow=True)
    klaster_k(base, shadow=True)
    popup_k2(base)
    out = OUTDIR + "hud-v3-perbaikan-popup-rev1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "P":
        build_putih()
    elif len(sys.argv) > 1 and sys.argv[1] == "P2":
        build_putih_v2()
    elif len(sys.argv) > 1 and sys.argv[1] == "G":
        build_gamepad()
    elif len(sys.argv) > 1 and sys.argv[1] == "G2":
        build_gamepad_v2()
    elif len(sys.argv) > 1 and sys.argv[1] == "G3":
        build_gamepad_v3()
    elif len(sys.argv) > 1 and sys.argv[1] == "K1A":
        build_perbaikan_a()
    elif len(sys.argv) > 1 and sys.argv[1] == "K1B":
        build_perbaikan_b()
    elif len(sys.argv) > 1 and sys.argv[1] == "K2":
        build_perbaikan_popup()
    elif len(sys.argv) > 1 and sys.argv[1] == "R1A":
        build_perbaikan_a_rev1()
    elif len(sys.argv) > 1 and sys.argv[1] == "R1B":
        build_perbaikan_b_rev1()
    elif len(sys.argv) > 1 and sys.argv[1] == "R2":
        build_perbaikan_popup_rev1()
    else:
        build("A")
        build("B")
