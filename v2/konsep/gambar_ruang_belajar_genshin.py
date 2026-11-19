#!/usr/bin/env python3
"""Mockup konsep Ruang Belajar versi CHAT gaya GENSHIN — Sinta, 19 Nov 2026.
Revisi dari konsep chat v1 (gelembung chat) atas referensi Mas (gambar
Genshin, 14:50): portrait ustadz BESAR di dunia + kotak dialog bawah
dengan nama pembicara emas + baris player sebagai gelembung kecil.
Alur 14 pesan + poin 35 + cabang 'Belum' TIDAK berubah — tampilannya saja.
Palet GayaMisi, font Baloo 2. Latar = render gerbang (stand-in dunia;
di game latarnya dunia live tempat ustadz berdiri).
Potret Sanusi dipotong dari foto songkok-v2 (latar datar dihapus flood
fill). Contoh Arab hanya transliterasi di mockup (PIL tak membentuk
huruf Arab) — di game tetap Amiri seperti sekarang.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = os.path.expanduser("~/workspace/pesantren-verse")
OUT = os.path.join(BASE, "v2/konsep")
FONT = os.path.join(BASE, "v2/godot-dunia/fonts/Baloo2-Variable.ttf")
FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
BG = os.path.join(OUT, "konsep-splash-a-gerbang.png")
SANUSI = os.path.join(BASE, "v2/foto-karakter/songkok-v2-sanusi-depan.png")

def font(sz, tebal=False):
    for p in (FONT, FALLBACK):
        try:
            f = ImageFont.truetype(p, sz)
            return f
        except Exception:
            pass
    return ImageFont.load_default()

ZAMRUD_G = (4, 59, 44)
EMAS = (201, 162, 39)
EMAS_T = (232, 196, 90)
KREM = (242, 234, 214)
KREM_R = (201, 194, 174)
PUTIH = (255, 255, 255)

def wrap(d, teks, f, lebar):
    baris, cur = [], ""
    for kata in teks.split(" "):
        uji = (cur + " " + kata).strip()
        if d.textlength(uji, font=f) <= lebar or not cur:
            cur = uji
        else:
            baris.append(cur)
            cur = kata
    if cur:
        baris.append(cur)
    return baris

# ---------------------------------------------------------------- potret
def potret_sanusi():
    """Potong foto Sanusi (tanpa label nama), hapus latar datar
    (beige atas + putih bawah) via flood fill. Kembalikan RGBA."""
    img = Image.open(SANUSI).convert("RGB")
    img = img.crop((360, 145, 920, 720))  # 560x575, label nama terpotong
    MAG = (255, 0, 255)
    d = ImageDraw.Draw(img)
    # Latar datar ada di beberapa komponen yang TIDAK terhubung (badan
    # karakter memisahkan putih kiri dan putih kanan) — satu seed per
    # komponen: beige atas kiri+kanan, putih tengah kiri+kanan, putih
    # bawah kiri+kanan.
    # Ambang putih HARUS kecil (4): jubah Sanusi hampir putih murni
    # (255,255,242–245) — ambang 10 memakan dada jubah. Latar putih
    # datar (255,255,255) tetap bersih di ambang 4; tepi anti-alias
    # jubah hanya terpotong 1–2 px.
    for (sx, sy, th) in [(2, 2, 12), (557, 2, 12),
                         (2, 300, 4), (557, 300, 4),
                         (2, 572, 4), (557, 572, 4)]:
        ImageDraw.floodfill(img, (sx, sy), MAG, thresh=th)
    a = img.convert("RGBA")
    px = a.load()
    for y in range(a.height):
        for x in range(a.width):
            if px[x, y][:3] == MAG:
                px[x, y] = (0, 0, 0, 0)
    r, g, b, al = a.split()
    al = al.filter(ImageFilter.GaussianBlur(1.2))
    a.putalpha(al)
    return a.crop(a.getbbox())

# ---------------------------------------------------------------- latar
def latar():
    bg = Image.open(BG).convert("RGBA").resize((1280, 720))
    ov = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rectangle([0, 0, 1280, 720], fill=(8, 14, 16, 45))
    for y in range(480, 720):
        t = (y - 480) / 240
        od.line([(0, y), (1280, y)], fill=(8, 14, 16, int(60 * t)))
    return Image.alpha_composite(bg, ov)

def tempel_potret(img):
    p = potret_sanusi()
    h = 470
    w = int(p.width * h / p.height)
    p = p.resize((w, h), Image.LANCZOS)
    px, py = 790, 50
    # bayangan lembut
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sil = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sil.putalpha(p.split()[3].point(lambda v: int(v * 0.55)))
    sil = sil.filter(ImageFilter.GaussianBlur(7))
    sh.paste(sil, (px + 10, py + 12), sil)
    img.alpha_composite(sh)
    img.alpha_composite(p, (px, py))

def chip_auto(d):
    # lingkaran + "Auto" kiri atas (ala Genshin)
    d.ellipse([24, 22, 52, 50], outline=PUTIH, width=2)
    d.ellipse([34, 32, 42, 40], fill=PUTIH)
    d.text((60, 36), "Auto", font=font(18), fill=PUTIH, anchor="lm")

# ---------------------------------------------------------------- kotak dialog
BOX = (40, 505, 1240, 695)

def kotak_dialog(img):
    x0, y0, x1, y1 = BOX
    box = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    bd = ImageDraw.Draw(box)
    for y in range(y1 - y0):
        t = y / max(1, (y1 - y0 - 1))
        c = (int(13 + (7 - 13) * t), int(22 + (12 - 22) * t),
             int(28 + (16 - 28) * t), int(232 + (245 - 232) * t))
        bd.line([(0, y), (x1 - x0, y)], fill=c)
    mask = Image.new("L", (x1 - x0, y1 - y0), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, x1 - x0 - 1, y1 - y0 - 1], radius=6, fill=255)
    img.paste(box, (x0, y0), mask)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([x0, y0, x1, y1], radius=6,
                        outline=(201, 162, 39, 120), width=1)
    d.line([(x0 + 2, y0 + 2), (x1 - 2, y0 + 2)], fill=EMAS, width=3)
    return d

def kepala_dialog(d, nama="Ust. Sanusi"):
    d.text((78, 522), nama, font=font(26), fill=EMAS_T, stroke_width=1,
           stroke_fill=EMAS_T)
    d.line([(78, 560), (330, 560)], fill=EMAS, width=2)
    d.text((1202, 530), "× Tutup", font=font(16), fill=KREM_R, anchor="ra")

def pesan_dialog(d, teks, fsz=22, y0=574):
    f = font(fsz)
    garis = wrap(d, teks, f, 1120)
    lh = int(fsz * 1.35)
    y = y0
    for ln in garis:
        d.text((78, y), ln, font=f, fill=PUTIH)
        y += lh
    return garis, y  # garis terakhir + y akhir

def footer_progres(d, kiri, progres):
    d.text((1202, 668), kiri, font=font(15), fill=KREM_R, anchor="ra")
    x0, x1, by = 40, 1240, 690
    d.rectangle([x0, by, x1, by + 5], fill=(10, 18, 22))
    d.rectangle([x0, by, x0 + (x1 - x0) * progres, by + 5], fill=EMAS)

def gelembung_pemain(d, x, y, teks):
    """Gelembung kecil player di atas kotak dialog (ala Genshin):
    ikon chat + teks, ekor menunjuk ke bawah."""
    f = font(19)
    w = int(d.textlength(teks, font=f)) + 64
    h = 48
    d.polygon([(x + w - 90, y + h - 2), (x + w - 66, y + h - 2),
               (x + w - 78, y + h + 12)], fill=(16, 20, 20))
    d.rounded_rectangle([x, y, x + w, y + h], radius=22,
                        fill=(16, 20, 20), outline=KREM, width=1)
    cx, cy = x + 26, y + h // 2
    d.ellipse([cx - 12, cy - 12, cx + 12, cy + 12], outline=KREM, width=2)
    for dx in (-5, 0, 5):
        d.ellipse([cx + dx - 2, cy - 2, cx + dx + 2, cy + 2], fill=KREM)
    d.text((x + 46, cy), teks, font=f, fill=KREM, anchor="lm")
    return w

def pilihan(d, x, y, w, teks, emas=True, redup=False):
    """Gelembung pilihan jawaban (ala Genshin: melayang di atas kotak)."""
    h = 54
    f = font(20)
    if emas:
        isi = (120, 97, 23) if redup else EMAS
        d.rounded_rectangle([x, y, x + w, y + h], radius=27, fill=isi)
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=ZAMRUD_G, anchor="mm")
    else:
        isi = (10, 18, 22)
        warna = tuple(int(c * 0.5) for c in KREM) if redup else KREM
        d.rounded_rectangle([x, y, x + w, y + h], radius=27, fill=isi,
                            outline=warna, width=2)
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=warna, anchor="mm")

# ---------------------------------------------------------------- A. MENUNGGU JAWABAN
def mockup_a():
    img = latar()
    tempel_potret(img)
    d = ImageDraw.Draw(img)
    chip_auto(d)
    # pilihan jawaban melayang (ala Genshin)
    pilihan(d, 380, 296, 400, "Paham, lanjut  ›", emas=True)
    pilihan(d, 380, 362, 400, "Belum, jelaskan lagi", emas=False)
    d = kotak_dialog(img)
    kepala_dialog(d)
    pesan_dialog(d, "kalam itu artinya adalah susunan kalimat. Kalimat disini "
                    "maksudnya adalah kata dalam bahasa indonesia. Paham?")
    footer_progres(d, "Pesan 2 dari 14  •  Materi", 2 / 14)
    img.convert("RGB").save(f"{OUT}/konsep-ruang-belajar-genshin-v1.png")

# ---------------------------------------------------------------- B. EFEK KETIK + CABANG
def mockup_b():
    img = latar()
    tempel_potret(img)
    d = ImageDraw.Draw(img)
    chip_auto(d)
    # gelembung kecil player (jawaban yang dipilih)
    gelembung_pemain(d, 956, 446, "Belum, jelaskan lagi.")
    # pilihan jawaban TERKUNCI (redup) selama ustadz mengetik
    pilihan(d, 380, 296, 400, "Paham, lanjut  ›", emas=True, redup=True)
    pilihan(d, 380, 362, 400, "Belum, jelaskan lagi", emas=False, redup=True)
    d = kotak_dialog(img)
    kepala_dialog(d)
    teks = ("Baik, coba contoh ini: Qaama Muhammadun — “Muhammad telah "
            "berdiri.” Itu kalam, karena pendengar sudah paham dan tidak "
            "bertanya lagi.")
    garis, y_akhir = pesan_dialog(d, teks, fsz=21, y0=572)
    # kursor blok di ujung teks (digambar, bukan glif font)
    f = font(21)
    lx = 78 + d.textlength(garis[-1], font=f) + 6
    ly = 572 + (len(garis) - 1) * int(21 * 1.35)
    d.rectangle([lx, ly + 2, lx + 10, ly + 24], fill=EMAS_T)
    d.text((78, 664), "Ust. Sanusi sedang mengetik…", font=font(15), fill=EMAS_T)
    footer_progres(d, "Pesan 4 dari 14  •  Materi — penjelasan ulang 1 dari 2",
                   4 / 14)
    img.convert("RGB").save(f"{OUT}/konsep-ruang-belajar-genshin-ketik-v1.png")

mockup_a()
mockup_b()
print("selesai")
