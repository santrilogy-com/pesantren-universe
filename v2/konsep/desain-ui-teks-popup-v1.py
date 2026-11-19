"""Konsep perbaikan tampilan teks + pop-up Pesantren Universe — DESAIN DULU.
Dibuat Sinta 19 Nov 2026, dari masukan Mas: "tampilan teks, pop up dll
kurang keren.. masih kaku". BUKAN ubah kode game — hanya mockup PNG di
v2/konsep/ untuk dinilai Mas sebelum dibangun.

Pola: desain-ui-misi.py (Sinta, 18 Nov) + desain-hud-v3.py (Tara).
Latar: v2/foto-hud/hud-v3-idle.png (portrait, dialog & pop-up) dan
v2/foto-misi/petunjuk-santri-baru-putra.png (landscape, banner).
Font ASLI game: Baloo2-Variable.ttf + Amiri-Bold.ttf (fonts/ proyek).
Palet tetap: krem #F2EAD6, zamrud #065F46, zamrud gelap #043B2C,
emas #C9A227, jati #7B4B2A.

3 mockup SESUDAH (layar penuh, elemen di posisi yang sama dengan foto
SEBELUM supaya Mas bisa membandingkan):
  konsep-ui-dialog-v2.png  — dialog misi Ust. Aqsal M
  konsep-ui-popup-v2.png   — pop-up PETUNJUK TOMBOL
  konsep-ui-banner-v2.png  — banner petunjuk misi santri baru
3 lembar banding (SEBELUM di atas, SESUDAH di bawah):
  konsep-ui-banding-dialog-v1.png / -popup-v1.png / -banner-v1.png

Ide inti v2 ("luwes, bukan kaku"): gradien vertikal panel (bukan warna
datar), bayangan lebih lembut & besar, hierarki ukuran teks (judul 26 /
isi 21 / kecil 14-15), aksen emas (garis pemisah, aksen kiri, ikon dalam
lingkaran lembut), spasi lebih lega, tombol bergradien + panah ›,
footer dialog jadi titik progres + chip tombol (keycap), pop-up rata
kiri (bukan semua rata tengah), banner jadi toast berikon + 2 baris.
Animasi masuk (usul, belum digambar): panel scale 0.96→1 + fade 180ms,
banner geser dari atas 220ms — via Tween Godot, tanpa aset baru.
"""
import math

from PIL import Image, ImageDraw, ImageFilter, ImageFont

V2 = "/home/hatch/workspace/pesantren-verse/v2/"
BASE_POTRET = V2 + "foto-hud/hud-v3-idle.png"
BASE_BANNER = V2 + "foto-misi/petunjuk-santri-baru-putra.png"
SEBELUM_DIALOG = V2 + "foto-misi/dialog-aqsal-v2.png"
SEBELUM_POPUP = V2 + "foto-hud/hud-v3-perbaikan-popup-rev1.png"
OUT = V2 + "konsep/"
FONT_BALOO = "/home/hatch/workspace/pesantren-verse/v2/godot-dunia/fonts/Baloo2-Variable.ttf"
FONT_AMIRI = "/home/hatch/workspace/pesantren-verse/v2/godot-dunia/fonts/Amiri-Bold.ttf"

KREM = (242, 234, 214, 255)
KREM_REDUP = (201, 194, 174, 255)
ZAMRUD = (6, 95, 70, 255)
ZAMRUD_G = (4, 59, 44, 255)
ZAMRUD_PANEL_ATAS = (17, 71, 55, 255)
ZAMRUD_PANEL_BAWAH = (7, 45, 36, 255)
ZAMRUD_KARTU = (3, 45, 34, 255)
EMAS = (201, 162, 39, 255)
EMAS_T = (232, 196, 90, 255)
JATI = (123, 75, 42, 255)
KULIT = (222, 184, 150, 255)
HITAM = (28, 28, 28, 255)
ABU = (96, 96, 96, 255)
PUTIH_HANGAT = (250, 247, 238, 255)
PUTIH_HANGAT_BAWAH = (238, 231, 214, 255)


def fb(sz):
    return ImageFont.truetype(FONT_BALOO, sz)


def fa(sz):
    return ImageFont.truetype(FONT_AMIRI, sz)


def lapis(base):
    lay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    return lay, ImageDraw.Draw(lay)


def tempel(base, lay):
    base.alpha_composite(lay)


def vgrad(w, h, c1, c2):
    """Gradien vertikal c1 (atas) -> c2 (bawah), RGBA."""
    g = Image.new("RGBA", (1, h))
    px = g.load()
    for y in range(h):
        t = y / max(1, h - 1)
        px[0, y] = tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(4))
    return g.resize((w, h))


def panel_gradien(base, box, radius, c1, c2, rim=None, rim_w=0,
                  bayangan=(0, 10, 16, 110)):
    """Panel sudut membulat berisi gradien vertikal + bayangan lembut.
    box = (x0, y0, x1, y1)."""
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    if bayangan:
        ox, oy, blur, alpha = bayangan
        lay, d = lapis(base)
        d.rounded_rectangle([x0 + ox, y0 + oy, x1 + ox, y1 + oy],
                            radius=radius, fill=(0, 0, 0, alpha))
        lay = lay.filter(ImageFilter.GaussianBlur(blur))
        tempel(base, lay)
    grad = vgrad(w, h, c1, c2)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=radius, fill=255)
    base.paste(grad, (x0, y0), mask)
    if rim:
        lay, d = lapis(base)
        d.rounded_rectangle(box, radius=radius, outline=rim, width=rim_w)
        tempel(base, lay)
    # Garis dalam (hairline) 1px di dalam rim — kesan berlapis.
    lay, d = lapis(base)
    d.rounded_rectangle([x0 + 4, y0 + 4, x1 - 4, y1 - 4], radius=max(4, radius - 4),
                        outline=(242, 234, 214, 36), width=1)
    tempel(base, lay)


def bungkus(d, teks, font, x, y, lebar, fill, leading):
    """Teks terbungkus kata-per-kata. Kembalikan y akhir."""
    kata = teks.split()
    baris, cur = [], ""
    for k in kata:
        coba = (cur + " " + k).strip()
        if d.textlength(coba, font=font) <= lebar:
            cur = coba
        else:
            baris.append(cur)
            cur = k
    if cur:
        baris.append(cur)
    for b in baris:
        d.text((x, y), b, font=font, fill=fill)
        y += leading
    return y


def spasi_huruf(d, xy, teks, font, fill, spasi=2):
    """Teks dengan jarak antar-huruf (untuk subjudul kapital)."""
    x, y = xy
    for ch in teks:
        d.text((x, y), ch, font=font, fill=fill)
        x += d.textlength(ch, font=font) + spasi
    return x


def tombol_gradien(base, box, radius, teks, font, fill_teks, panah=True):
    x0, y0, x1, y1 = box
    lay, d = lapis(base)
    d.rounded_rectangle([x0, y0 + 4, x1, y1 + 4], radius=radius, fill=(0, 0, 0, 90))
    lay = lay.filter(ImageFilter.GaussianBlur(6))
    tempel(base, lay)
    grad = vgrad(x1 - x0, y1 - y0, EMAS_T, EMAS)
    mask = Image.new("L", (x1 - x0, y1 - y0), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, x1 - x0 - 1, y1 - y0 - 1], radius=radius, fill=255)
    base.paste(grad, (x0, y0), mask)
    d = ImageDraw.Draw(base)
    tw = d.textlength(teks, font=font)
    tx = x0 + (x1 - x0 - tw) // 2 - (14 if panah else 0)
    ty = y0 + (y1 - y0 - font.size) // 2 - 2
    d.text((tx, ty), teks, font=font, fill=fill_teks)
    if panah:
        px = x1 - 34
        py = (y0 + y1) // 2
        d.line([(px, py - 9), (px + 10, py), (px, py + 9)], fill=fill_teks, width=4)


def tombol_outline(base, box, radius, teks, font, fill_teks):
    x0, y0, x1, y1 = box
    lay, d = lapis(base)
    d.rounded_rectangle(box, radius=radius, fill=(3, 45, 34, 160),
                        outline=KREM, width=2)
    tempel(base, lay)
    d = ImageDraw.Draw(base)
    tw = d.textlength(teks, font=font)
    d.text((x0 + (x1 - x0 - tw) // 2, y0 + (y1 - y0 - font.size) // 2 - 2),
           teks, font=font, fill=fill_teks)


def ikon_bentuk(d, cx, cy, bentuk, warna, r=13, lebar=4):
    """Glyph tombol gamepad: segitiga / kotak / lingkaran / silang."""
    if bentuk == "segitiga":
        d.polygon([(cx, cy - r), (cx + r, cy + r - 2), (cx - r, cy + r - 2)],
                  outline=warna, width=lebar)
    elif bentuk == "kotak":
        d.rectangle([cx - r + 2, cy - r + 2, cx + r - 2, cy + r - 2],
                    outline=warna, width=lebar)
    elif bentuk == "lingkaran":
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=warna, width=lebar)
    elif bentuk == "silang":
        d.line([(cx - r + 2, cy - r + 2), (cx + r - 2, cy + r - 2)],
               fill=warna, width=lebar)
        d.line([(cx - r + 2, cy + r - 2), (cx + r - 2, cy - r + 2)],
               fill=warna, width=lebar)


def medali_avatar(base, cx, cy, r=58):
    """Medali potret Kyai: cincin emas ganda + wajah sederhana."""
    lay, d = lapis(base)
    d.ellipse([cx - r, cy - r + 5, cx + r, cy + r + 5], fill=(0, 0, 0, 90))
    lay = lay.filter(ImageFilter.GaussianBlur(6))
    tempel(base, lay)
    d = ImageDraw.Draw(base)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=EMAS)
    d.ellipse([cx - r + 5, cy - r + 5, cx + r - 5, cy + r - 5], fill=KREM)
    d.ellipse([cx - 42, cy - 40, cx + 42, cy + 44], fill=KULIT)
    # Songkok putih.
    d.pieslice([cx - 42, cy - 62, cx + 42, cy - 6], 180, 360, fill=(250, 250, 250, 255))
    d.rectangle([cx - 42, cy - 34, cx + 42, cy - 22], fill=(250, 250, 250, 255))
    # Jenggot gelap.
    d.pieslice([cx - 40, cy - 2, cx + 40, cy + 46], 0, 180, fill=(52, 38, 26, 255))
    d.ellipse([cx - 9, cy - 2, cx + 9, cy + 12], fill=KULIT)  # dagu
    # Mata + senyum.
    d.ellipse([cx - 24, cy - 14, cx - 16, cy - 6], fill=HITAM)
    d.ellipse([cx + 16, cy - 14, cx + 24, cy - 6], fill=HITAM)
    d.arc([cx - 12, cy + 8, cx + 12, cy + 24], 20, 160, fill=(120, 60, 40, 255), width=3)


def bintang(d, cx, cy, r_luar, r_dalam, fill):
    pts = []
    for i in range(10):
        r = r_luar if i % 2 == 0 else r_dalam
        a = math.pi / 2 + i * math.pi / 5
        pts.append((cx + r * math.cos(a), cy - r * math.sin(a)))
    d.polygon(pts, fill=fill)


# ---------------------------------------------------------------- dialog
def mockup_dialog():
    base = Image.open(BASE_POTRET).convert("RGBA")
    panel = (28, 950, 692, 1520)
    panel_gradien(base, panel, 26, ZAMRUD_PANEL_ATAS, ZAMRUD_PANEL_BAWAH,
                  rim=EMAS, rim_w=2)
    # Tab nama emas (menumpang di atas panel).
    tab = (210, 922, 510, 978)
    lay, d = lapis(base)
    d.rounded_rectangle([tab[0], tab[1] + 4, tab[2], tab[3] + 4],
                        radius=28, fill=(0, 0, 0, 90))
    lay = lay.filter(ImageFilter.GaussianBlur(5))
    tempel(base, lay)
    grad = vgrad(tab[2] - tab[0], tab[3] - tab[1], EMAS_T, EMAS)
    mask = Image.new("L", (tab[2] - tab[0], tab[3] - tab[1]), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, tab[2] - tab[0] - 1, tab[3] - tab[1] - 1], radius=28, fill=255)
    base.paste(grad, (tab[0], tab[1]), mask)
    d = ImageDraw.Draw(base)
    t = "Ust. Aqsal M"
    d.text((tab[0] + (tab[2] - tab[0] - d.textlength(t, font=fb(26))) // 2,
            tab[1] + 10), t, font=fb(26), fill=ZAMRUD_G)
    # Kepala: medali + subjudul + salam Arab.
    medali_avatar(base, 122, 1058)
    d = ImageDraw.Draw(base)
    spasi_huruf(d, (196, 1022), "PENGASUH PESANTREN UNIVERSE", fb(14), EMAS_T, 2)
    d.text((196, 1052), "أهلا وسهلا", font=fa(22), fill=KREM)
    # Aksen emas vertikal + isi dialog.
    d.rectangle([56, 1162, 60, 1290], fill=EMAS)
    bungkus(d, "Ahlan wa sahlan, santri baru. Saya Ust. Aqsal M, pengasuh "
               "pesantren ini. Di sini kita belajar kitab kuning seperti "
               "pesantren sungguhan — tapi dibungkus game: misi, poin, "
               "dan gelar.",
            fb(21), 78, 1160, 586, KREM, 31)
    # Pemisah.
    lay, d = lapis(base)
    d.line([(56, 1322), (664, 1322)], fill=(201, 162, 39, 110), width=1)
    tempel(base, lay)
    # Tombol.
    tombol_gradien(base, (56, 1342, 664, 1406), 32,
                   "Baik, Ustadz. Saya siap belajar.", fb(20), ZAMRUD_G)
    tombol_outline(base, (56, 1418, 664, 1482), 32,
                   "Apa saja aturannya, Ustadz?", fb(20), KREM)
    # Footer: titik progres + chip tombol (keycap).
    d = ImageDraw.Draw(base)
    for i in range(5):
        cx = 66 + i * 22
        if i == 0:
            d.ellipse([cx - 6, 1496, cx + 6, 1508], fill=EMAS)
        else:
            d.ellipse([cx - 6, 1496, cx + 6, 1508], outline=(242, 234, 214, 160), width=2)
    d.text((186, 1492), "Babak 1 dari 5", font=fb(14), fill=KREM_REDUP)
    for (x0, teks, bentuk) in [(470, "Lanjut", "silang"), (574, "Chat", "kotak")]:
        lay, dd = lapis(base)
        dd.rounded_rectangle([x0, 1486, x0 + 88, 1514], radius=10,
                             fill=(3, 45, 34, 200),
                             outline=(242, 234, 214, 120), width=1)
        tempel(base, lay)
        dd = ImageDraw.Draw(base)
        ikon_bentuk(dd, x0 + 16, 1500, bentuk, KREM, r=7, lebar=3)
        dd.text((x0 + 30, 1490), teks, font=fb(14), fill=KREM)
    base.save(OUT + "konsep-ui-dialog-v2.png")
    print("dialog ok")


# ----------------------------------------------------------------- pop-up
def mockup_popup():
    base = Image.open(BASE_POTRET).convert("RGBA")
    # Dim latar (lebih gelap dari sebelumnya supaya pop-up menonjol).
    lay, d = lapis(base)
    d.rectangle([0, 0, base.width, base.height], fill=(0, 0, 0, 96))
    tempel(base, lay)
    panel = (90, 470, 630, 1170)
    panel_gradien(base, panel, 26, PUTIH_HANGAT, PUTIH_HANGAT_BAWAH,
                  rim=(201, 162, 39, 180), rim_w=2)
    d = ImageDraw.Draw(base)
    # Pita emas di atas panel.
    d.rounded_rectangle([90, 470, 630, 484], radius=13, fill=EMAS)
    d.rectangle([90, 477, 630, 484], fill=EMAS)
    # Kepala rata kiri + tombol tutup bulat.
    d.text((128, 508), "Petunjuk Tombol", font=fb(26), fill=HITAM)
    d.text((128, 546), "Ketuk tombol sesuai kebutuhanmu",
           font=fb(15), fill=ABU)
    lay, dd = lapis(base)
    dd.ellipse([566, 508, 610, 552], fill=ZAMRUD_G)
    tempel(base, lay)
    dd = ImageDraw.Draw(base)
    ikon_bentuk(dd, 588, 530, "silang", KREM, r=9, lebar=4)
    lay, dd = lapis(base)
    dd.line([(128, 584), (592, 584)], fill=(201, 162, 39, 120), width=1)
    tempel(base, lay)
    # Baris: ikon dalam lingkaran lembut + label tebal + keterangan.
    baris = [
        ("segitiga", "Aksi", "Berinteraksi dengan NPC & objek"),
        ("kotak", "Chat", "Ngobrol dengan santri lain"),
        ("lingkaran", "Reset", "Kembali ke posisi awal"),
        ("silang", "Mulai Misi", "Lanjut ke langkah misi berikutnya"),
    ]
    y = 606
    for bentuk, label, ket in baris:
        lay, dd = lapis(base)
        dd.ellipse([128, y + 8, 182, y + 62], fill=(6, 95, 70, 28))
        tempel(base, lay)
        dd = ImageDraw.Draw(base)
        ikon_bentuk(dd, 155, y + 35, bentuk, ZAMRUD, r=13, lebar=4)
        dd.text((198, y + 10), label, font=fb(20), fill=HITAM)
        dd.text((198, y + 42), ket, font=fb(14), fill=ABU)
        y += 96
    # Catatan kaki dalam strip krem.
    lay, dd = lapis(base)
    dd.rounded_rectangle([128, 996, 592, 1052], radius=14,
                         fill=(242, 234, 214, 255))
    dd.ellipse([142, 1014, 164, 1036], fill=EMAS)
    tempel(base, lay)
    dd = ImageDraw.Draw(base)
    dd.text((153, 1016), "i", font=fb(15), fill=ZAMRUD_G)
    dd.text((172, 1006), "Kamera ada di menu atas", font=fb(14), fill=(74, 74, 74, 255))
    dd.text((172, 1026), "Fungsi tombol berubah sesuai misi",
            font=fb(14), fill=(74, 74, 74, 255))
    # Tombol utama penuh.
    tombol_gradien(base, (128, 1064, 592, 1128), 32, "Mengerti", fb(21),
                   ZAMRUD_G, panah=False)
    base.save(OUT + "konsep-ui-popup-v2.png")
    print("popup ok")


# ----------------------------------------------------------------- banner
def mockup_banner():
    base = Image.open(BASE_BANNER).convert("RGBA")
    panel = (180, 168, 1100, 302)
    panel_gradien(base, panel, 22, ZAMRUD_PANEL_ATAS, ZAMRUD_PANEL_BAWAH,
                  rim=EMAS, rim_w=2)
    d = ImageDraw.Draw(base)
    # Ikon bintang dalam lingkaran emas.
    d.ellipse([202, 205, 262, 265], fill=EMAS)
    bintang(d, 232, 235, 20, 9, ZAMRUD_G)
    # Teks dua baris: ajakan tebal + arah emas.
    d.text((282, 196), "ayo mulai misi santri barumu!", font=fb(24), fill=KREM)
    d.text((282, 240), "Sowan ke Ustadz sekarang", font=fb(18), fill=EMAS_T)
    # Panah › di kanan.
    d.line([(1052, 222), (1066, 236), (1052, 250)], fill=EMAS_T, width=5)
    base.save(OUT + "konsep-ui-banner-v2.png")
    print("banner ok")


# ------------------------------------------------------- lembar banding
def banding(nama, sebelum_path, sebelum_box, sesudah_path, sesudah_box):
    s = Image.open(sebelum_path).convert("RGBA").crop(sebelum_box)
    a = Image.open(sesudah_path).convert("RGBA").crop(sesudah_box)
    W = 700
    s = s.resize((W, int(s.height * W / s.width)), Image.LANCZOS)
    a = a.resize((W, int(a.height * W / a.width)), Image.LANCZOS)
    H = 46 + s.height + 46 + a.height + 40
    sheet = Image.new("RGBA", (760, H), (242, 234, 214, 255))
    d = ImageDraw.Draw(sheet)
    d.text((30, 10), "SEBELUM", font=fb(18), fill=ABU)
    sheet.paste(s, (30, 46))
    y2 = 46 + s.height + 8
    d.text((30, y2), "SESUDAH — konsep v2", font=fb(18), fill=ZAMRUD_G)
    sheet.paste(a, (30, y2 + 38))
    sheet.save(OUT + nama)
    print(nama, "ok", sheet.size)


if __name__ == "__main__":
    mockup_dialog()
    mockup_popup()
    mockup_banner()
    banding("konsep-ui-banding-dialog-v1.png", SEBELUM_DIALOG,
            (28, 995, 692, 1480), OUT + "konsep-ui-dialog-v2.png",
            (28, 918, 692, 1520))
    banding("konsep-ui-banding-popup-v1.png", SEBELUM_POPUP,
            (120, 478, 600, 942), OUT + "konsep-ui-popup-v2.png",
            (90, 470, 630, 1170))
    banding("konsep-ui-banding-banner-v1.png", BASE_BANNER,
            (180, 168, 1100, 302), OUT + "konsep-ui-banner-v2.png",
            (180, 168, 1100, 302))
