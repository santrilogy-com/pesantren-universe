#!/usr/bin/env python3
"""Mockup konsep Ruang Belajar gaya GENSHIN — DUDUK + papan tulis — Sinta, 19 Nov 2026.
Revisi §8 atas koreksi Mas (19 Nov 15:00):
  1. HAPUS "sedang mengetik" — ustadz sedang BICARA, bukan mengetik. Tidak ada
     lagi status mengetik, tidak ada lagi tombol jawaban terkunci/redup.
     Efek huruf muncul satu-satu TETAP sebagai EFEK BICARA (alasan di §8
     dokumen): standar dialog visual-novel — teks muncul progresif selagi
     tokoh bicara; kursor blok emas = penanda "sedang bicara". Pilihan
     jawaban TIDAK tampil selama ustadz bicara; muncul begitu kalimat
     selesai, langsung aktif penuh.
  2. Sanusi DUDUK + papan tulis KECIL di sampingnya untuk keterangan
     (isi papan mengikuti pesan yang sedang dibahas). Putri: sama dengan
     Ustzh. Fatimah (mockup C, latar Musholla).
Alur 14 pesan + poin 35 + cabang "Belum" maks 2x + resume TIDAK berubah.
Palet GayaMisi, font Baloo 2. Latar = render gerbang/musholla (stand-in
dunia; di game latarnya dunia live tempat ustadz duduk).
Potret dipotong dari foto (Sanusi: songkok-v2; Fatimah: fatimah_depan),
latar datar dihapus flood fill, diposisikan DUDUK di atas tikar. Di game,
pose duduk memakai pose duduk yang sudah ada (dipakai ulang dari
_terapkan_duduk_baca) — mockup hanya memosisikan potongan foto yang ada.
Contoh Arab hanya transliterasi di mockup (PIL tak membentuk huruf Arab);
di game tetap Amiri seperti sekarang (catatan: teks Arab di panel sedang
diselidiki Tara — 19 Nov 15:00 — jadi isi papan tulis v1 transliterasi).
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = os.path.expanduser("~/workspace/pesantren-verse")
OUT = os.path.join(BASE, "v2/konsep")
FONT = os.path.join(BASE, "v2/godot-dunia/fonts/Baloo2-Variable.ttf")
FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
BG_GERBANG = os.path.join(OUT, "konsep-splash-a-gerbang.png")
BG_MUSHOLLA = os.path.join(OUT, "konsep-splash-b-musholla.png")
SANUSI = os.path.join(BASE, "v2/foto-karakter/songkok-v2-sanusi-depan.png")
FATIMAH = os.path.join(BASE, "v2/foto-npc-fatimah/fatimah_depan.png")

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
KAYU = (139, 94, 52)
TIKAR = (198, 168, 112)
TIKAR_G = (150, 120, 75)

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
def _bersihkan_latar(img, seeds):
    """Hapus latar datar via flood fill per komponen (lihat catatan ambang
    di bawah). Kembalikan RGBA yang sudah di-crop ke bbox."""
    MAG = (255, 0, 255)
    for (sx, sy, th) in seeds:
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

def potret_sanusi():
    """Potong foto Sanusi (tanpa label nama). Ambang putih HARUS kecil (4):
    jubah Sanusi hampir putih murni (255,255,242-245) — ambang 10 memakan
    dada jubah. Latar putih datar (255,255,255) tetap bersih di ambang 4."""
    img = Image.open(SANUSI).convert("RGB")
    img = img.crop((360, 145, 920, 720))  # 560x575, label nama terpotong
    return _bersihkan_latar(img, [(2, 2, 12), (557, 2, 12),
                                  (2, 300, 4), (557, 300, 4),
                                  (2, 572, 4), (557, 572, 4)])

def potret_fatimah():
    """Potong foto Fatimah (tanpa label nama), badan atas saja. Jilbab
    putih krem — ambang putih kecil (4) seperti jubah Sanusi; jilbab
    tidak menyentuh tepi crop, jadi flood fill dari sudut aman."""
    img = Image.open(FATIMAH).convert("RGB")
    img = img.crop((430, 60, 850, 480))  # 420x420, tangan ikut terpotong
    return _bersihkan_latar(img, [(2, 2, 12), (417, 2, 12),
                                  (2, 200, 4), (417, 200, 4),
                                  (2, 417, 4), (417, 417, 4)])

# ---------------------------------------------------------------- latar
def latar(path):
    bg = Image.open(path).convert("RGBA").resize((1280, 720))
    ov = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rectangle([0, 0, 1280, 720], fill=(8, 14, 16, 45))
    for y in range(480, 720):
        t = (y - 480) / 240
        od.line([(0, y), (1280, y)], fill=(8, 14, 16, int(60 * t)))
    return Image.alpha_composite(bg, ov)

# ---------------------------------------------------------------- duduk + papan
def tempel_potret_duduk(img, potret, px, py, h):
    """Tempel potret DUDUK: lebih rendah dari potret berdiri, di atas tikar.
    Tikar digambar SETELAH potret (di depan tepi bawah jubah) supaya
    terbaca duduk di atas tikar."""
    w = int(potret.width * h / potret.height)
    p = potret.resize((w, h), Image.LANCZOS)
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sil = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sil.putalpha(p.split()[3].point(lambda v: int(v * 0.55)))
    sil = sil.filter(ImageFilter.GaussianBlur(7))
    sh.paste(sil, (px + 10, py + 12), sil)
    img.alpha_composite(sh)
    img.alpha_composite(p, (px, py))
    d = ImageDraw.Draw(img)
    # tikar: trapesium perspektif di depan tepi bawah potret (y 484-512) —
    # melebar ke bawah supaya terbaca hamparan di lantai, bukan meja.
    # Digambar SETELAH potret supaya tepi bawah jubah bertemu tikar.
    d.polygon([(px - 90, 484), (px + w + 90, 484),
               (px + w + 130, 512), (px - 130, 512)],
              fill=TIKAR, outline=TIKAR_G)
    d.line([(px - 100, 492), (px + w + 100, 492)], fill=TIKAR_G, width=1)
    d.line([(px - 112, 501), (px + w + 112, 501)], fill=TIKAR_G, width=1)
    return px, w

def papan_tulis(d, x, y, w, h, baris, judul=None):
    """Papan tulis KECIL di atas kaki (easel) — keterangan materi.
    baris: list teks (transliterasi, bukan Arab — lihat catatan file).
    Isi papan mengikuti pesan yang sedang dibahas."""
    # kaki easel
    d.line([(x + 28, y + h), (x + 14, y + h + 34)], fill=KAYU, width=5)
    d.line([(x + w - 28, y + h), (x + w - 14, y + h + 34)], fill=KAYU, width=5)
    d.line([(x + 14, y + h + 34), (x + w - 14, y + h + 34)], fill=KAYU, width=4)
    # papan: putih + bingkai emas
    d.rounded_rectangle([x, y, x + w, y + h], radius=6,
                        fill=(250, 250, 244), outline=EMAS, width=4)
    ty = y + 14
    if judul:
        d.text((x + 14, ty), judul, font=font(17), fill=EMAS)
        ty += 26
        d.line([(x + 14, ty - 4), (x + w - 14, ty - 4)], fill=(220, 210, 180),
               width=1)
    f = font(19)
    for ln in baris:
        for g in wrap(d, ln, f, w - 28):
            d.text((x + 14, ty), g, font=f, fill=ZAMRUD_G)
            ty += 26

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
    # tombol Riwayat (log percakapan) — pertanyaan §5 no. 6, usulan: ada
    d.text((1100, 530), "Riwayat", font=font(16), fill=KREM_R, anchor="ra")
    d.text((1202, 530), "× Tutup", font=font(16), fill=KREM_R, anchor="ra")

def pesan_dialog(d, teks, fsz=22, y0=574):
    f = font(fsz)
    garis = wrap(d, teks, f, 1120)
    lh = int(fsz * 1.35)
    y = y0
    for ln in garis:
        d.text((78, y), ln, font=f, fill=PUTIH)
        y += lh
    return garis, y

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

def pilihan(d, x, y, w, teks, emas=True):
    """Gelembung pilihan jawaban — SELALU aktif penuh. Tidak ada lagi
    status redup/terkunci: pilihan baru muncul setelah ustadz selesai
    bicara, dan saat muncul langsung bisa ditekan."""
    h = 54
    f = font(20)
    if emas:
        d.rounded_rectangle([x, y, x + w, y + h], radius=27, fill=EMAS)
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=ZAMRUD_G, anchor="mm")
    else:
        d.rounded_rectangle([x, y, x + w, y + h], radius=27, fill=(10, 18, 22),
                            outline=KREM, width=2)
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=KREM, anchor="mm")

# ---------------------------------------------------------------- A. DUDUK — MENUNGGU JAWABAN
def mockup_a():
    img = latar(BG_GERBANG)
    px, _w = tempel_potret_duduk(img, potret_sanusi(), 830, 120, 380)
    d = ImageDraw.Draw(img)
    papan_tulis(d, 545, 300, 255, 180, ["kalam =", "susunan kalimat",
                                        "kata = isim • fi'il • huruf"],
                judul="KALAM")
    chip_auto(d)
    # pilihan jawaban melayang — aktif penuh (ustadz selesai bicara)
    pilihan(d, 60, 300, 400, "Paham, lanjut  ›", emas=True)
    pilihan(d, 60, 366, 400, "Belum, jelaskan lagi", emas=False)
    d = kotak_dialog(img)
    kepala_dialog(d)
    pesan_dialog(d, "kalam itu artinya adalah susunan kalimat. Kalimat disini "
                    "maksudnya adalah kata dalam bahasa indonesia. Paham?")
    footer_progres(d, "Pesan 2 dari 14  •  Materi", 2 / 14)
    img.convert("RGB").save(f"{OUT}/konsep-ruang-belajar-genshin-duduk-v1.png")

# ---------------------------------------------------------------- B. DUDUK — SEDANG BICARA (bukan mengetik)
def mockup_b():
    img = latar(BG_GERBANG)
    px, _w = tempel_potret_duduk(img, potret_sanusi(), 830, 120, 380)
    d = ImageDraw.Draw(img)
    papan_tulis(d, 545, 300, 255, 180, ["Qaama Muhammadun",
                                        "Muhammad telah berdiri.",
                                        "Itu kalam."],
                judul="CONTOH")
    chip_auto(d)
    # gelembung kecil player (jawaban yang dipilih) — pindah kiri supaya
    # tidak menutupi potret duduk di kanan
    gelembung_pemain(d, 60, 446, "Belum, jelaskan lagi.")
    # TIDAK ADA pilihan jawaban di frame ini: ustadz masih bicara, pilihan
    # baru muncul setelah kalimat selesai — langsung aktif, tanpa redup.
    d = kotak_dialog(img)
    kepala_dialog(d)
    teks = ("Baik, coba contoh ini: Qaama Muhammadun — “Muhammad telah "
            "berdiri.” Itu kalam, karena pendengar sudah paham dan tidak "
            "bertanya lagi.")
    garis, y_akhir = pesan_dialog(d, teks, fsz=21, y0=572)
    # kursor blok emas = EFEK BICARA (bukan mengetik): teks muncul
    # progresif selagi ustadz bicara; hilang begitu kalimat selesai
    # dan pilihan jawaban muncul.
    f = font(21)
    lx = 78 + d.textlength(garis[-1], font=f) + 6
    ly = 572 + (len(garis) - 1) * int(21 * 1.35)
    d.rectangle([lx, ly + 2, lx + 10, ly + 24], fill=EMAS_T)
    footer_progres(d, "Pesan 4 dari 14  •  Materi — penjelasan ulang 1 dari 2",
                   4 / 14)
    img.convert("RGB").save(f"{OUT}/konsep-ruang-belajar-genshin-duduk-bicara-v1.png")

# ---------------------------------------------------------------- C. DUDUK — PUTRI (Fatimah, Musholla)
def mockup_c():
    img = latar(BG_MUSHOLLA)
    px, _w = tempel_potret_duduk(img, potret_fatimah(), 830, 120, 380)
    d = ImageDraw.Draw(img)
    papan_tulis(d, 545, 300, 255, 180, ["kalam =", "susunan kalimat",
                                        "kata = isim • fi'il • huruf"],
                judul="KALAM")
    chip_auto(d)
    pilihan(d, 60, 300, 400, "Paham, lanjut  ›", emas=True)
    pilihan(d, 60, 366, 400, "Belum, jelaskan lagi", emas=False)
    d = kotak_dialog(img)
    kepala_dialog(d, nama="Ustzh. Fatimah")
    pesan_dialog(d, "kalam itu artinya adalah susunan kalimat. Kalimat disini "
                    "maksudnya adalah kata dalam bahasa indonesia. Paham?")
    footer_progres(d, "Pesan 2 dari 14  •  Materi", 2 / 14)
    img.convert("RGB").save(f"{OUT}/konsep-ruang-belajar-genshin-duduk-fatimah-v1.png")

mockup_a()
mockup_b()
mockup_c()
print("selesai")
