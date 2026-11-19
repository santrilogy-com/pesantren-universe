"""Desain mockup UI percakapan (dialog) Pesantren Universe — DESAIN DULU.
Dibuat Sinta 18 Nov 2026, Fase A — A9 (koordinator Raka).
Pola: desain-hud-v3.py Tara (PIL; gambar di layer lalu alpha_composite;
JANGAN ubah file Tara). Latar: v2/foto-hud/hud-v3-idle.png (foto
implementasi game — lantai marmer putih spawn + Surau).

Panel dialog di bawah layar ala game 3D: medali potret pembicara +
tab nama emas + teks dialog + 2 tombol pilihan jawaban + petunjuk
tombol (pemetaan BARU Mas 18:33 WIB: X = Lanjut di scene dialog,
kotak = Chat; Kamera sudah pindah ke menu atas).
Palet game: krem #F2EAD6, zamrud #065F46, zamrud gelap #043B2C,
emas #C9A227, jati #7B4B2A.

TEKS DIALOG = DRAF dari garis besar DRAF-ALUR-MISI.md §1A babak 1-2
(sambutan + apa itu Pesantren Universe). BUKAN kalimat final — isi
aturan detail menunggu tashih Mas (§9 butir 17).
"""
import math
import sys

from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE = "/home/hatch/workspace/pesantren-verse/v2/foto-hud/hud-v3-idle.png"
OUTDIR = "/home/hatch/workspace/pesantren-verse/v2/foto-misi/"
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_R = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

KREM = (242, 234, 214, 255)
KREM_T = (242, 234, 214, 205)   # krem agak transparan (subjudul, petunjuk)
ZAMRUD = (6, 95, 70, 255)
ZAMRUD_G = (4, 59, 44, 255)     # zamrud gelap
EMAS = (201, 162, 39, 255)
EMAS_T = (232, 196, 90, 255)    # emas terang (teks di atas zamrud gelap)
JATI = (123, 75, 42, 255)
KULIT = (222, 184, 150, 255)    # kulit wajah medali potret
PUTIH = (255, 255, 255, 255)


def fb(sz):
    return ImageFont.truetype(FONT_B, sz)


def fr(sz):
    return ImageFont.truetype(FONT_R, sz)


def _lapis(base):
    """Layer transparan baru + Draw-nya (elemen ber-alpha HARUS lewat
    layer lalu alpha_composite — ImageDraw langsung di base RGBA tidak
    mem-blend alpha, pelajaran lama skrip Tara)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    return layer, ImageDraw.Draw(layer)


def vgrad(size, top, bottom):
    w, h = size
    img = Image.new("RGBA", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(4))
        d.line([(0, y), (w, y)], fill=c)
    return img


def rounded_mask(size, rad):
    m = Image.new("L", size, 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=rad, fill=255)
    return m


def teks(base, xy, s, font, fill=KREM, anchor="mm"):
    """Teks di layer (alpha benar) lalu composite."""
    layer, d = _lapis(base)
    d.text(xy, s, font=font, fill=fill, anchor=anchor)
    base.alpha_composite(layer)


def bungkus(d, s, font, lebar):
    """Pecah teks jadi baris-baris selebar `lebar` px (ukur textbbox)."""
    kata = s.split(" ")
    baris, cur = [], ""
    for k in kata:
        coba = (cur + " " + k).strip()
        w = d.textbbox((0, 0), coba, font=font)[2]
        if w <= lebar or not cur:
            cur = coba
        else:
            baris.append(cur)
            cur = k
    if cur:
        baris.append(cur)
    return baris


def bayang_panel(base, box, rad, dy=10, alpha=95, blur=12):
    """Bayangan jatuh di bawah panel — yang bikin panel terasa
    MENGAMBANG ala game 3D (bukan kartu datar menempel layar)."""
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([box[0], box[1] + dy, box[2], box[3] + dy],
                        radius=rad, fill=(0, 0, 0, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def medali_potret():
    """Medali potret bulat Ust. Aqsal M (digambar kode: peci putih +
    wajah + jubah zamrud + kerah emas). Dibuat sebagai tile 120x120
    dengan mask lingkaran, lalu ditempel ke base."""
    S = 120
    tile = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(tile)
    # isi krem (latar medali)
    d.ellipse([0, 0, S - 1, S - 1], fill=KREM)
    # jubah zamrud (bawah)
    d.rounded_rectangle([16, 80, 104, 122], radius=10, fill=ZAMRUD)
    # kerah emas bentuk V
    d.line([(60, 80), (42, 98)], fill=EMAS, width=3)
    d.line([(60, 80), (78, 98)], fill=EMAS, width=3)
    # leher + wajah
    d.rectangle([52, 68, 68, 82], fill=KULIT)
    d.ellipse([38, 30, 82, 76], fill=KULIT)
    # peci putih (kopiah) + pita gelap tipis di bawahnya
    d.pieslice([36, 12, 84, 54], start=180, end=360, fill=PUTIH)
    d.arc([36, 12, 84, 54], start=180, end=360, fill=(200, 200, 200, 255),
          width=2)
    d.line([(38, 46), (82, 46)], fill=(90, 90, 90, 255), width=2)
    # mata + senyum
    d.ellipse([48, 52, 53, 57], fill=(40, 30, 25, 255))
    d.ellipse([67, 52, 72, 57], fill=(40, 30, 25, 255))
    d.arc([52, 60, 68, 72], start=10, end=170, fill=(40, 30, 25, 255),
          width=2)
    # rim emas tebal (lapisan paling atas)
    d.ellipse([1, 1, S - 2, S - 2], outline=EMAS, width=5)
    d.ellipse([6, 6, S - 7, S - 7], outline=(138, 109, 31, 255), width=1)
    return tile


def panel_dialog(base):
    """Panel dialog utama: bayangan jatuh + gradien zamrud gelap +
    rim emas + garis emas di dalam tepi atas. Panel MENUTUP analog +
    klaster bawah (dialog itu modal — HUD disembunyikan saat dialog,
    seperti pop-up petunjuk Tara)."""
    box = [36, 1030, 684, 1470]
    rad = 24
    bayang_panel(base, box, rad)
    # isi gradien zamrud gelap (atas) -> zamrud (bawah), alpha 242
    grad = vgrad((box[2] - box[0], box[3] - box[1]),
                 (4, 59, 44, 242), (6, 95, 70, 242))
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    layer.paste(grad, (box[0], box[1]), rounded_mask(grad.size, rad))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    # rim emas + hairline krem di dalam rim
    d.rounded_rectangle(box, radius=rad, outline=EMAS, width=3)
    d.rounded_rectangle([box[0] + 5, box[1] + 5, box[2] - 5, box[3] - 5],
                        radius=rad - 4, outline=(242, 234, 214, 90), width=1)
    return box


def tab_nama(base, subjudul="Pengasuh Pesantren Verse"):
    """Tab nama pembicara — pill EMAS yang MENIMPA tepi atas panel
    (berlapis: tab di atas panel, bukan teks di dalam panel).
    Subjudul default = v1 (Verse); v2 ke atas pakai 'Pesantren
    Universe' (ACC Mas 18:53 WIB)."""
    box = [182, 1008, 430, 1052]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=22, fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=22, outline=(255, 240, 180, 255),
                         width=2)
    teks(base, (306, 1030), "Ust. Aqsal M", fb(24),
         fill=(4, 59, 44, 255))
    # subjudul kecil di bawah tab, di dalam panel
    teks(base, (182, 1072), subjudul, fr(15),
         fill=KREM_T, anchor="la")


def tag_draf(base):
    """Penanda kecil 'TEKS DRAF' di pojok kanan atas panel — supaya
    jelas di mockup bahwa kalimat dialog menunggu tashih Mas."""
    box = [540, 1050, 664, 1076]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=13, outline=EMAS, width=2)
    base.alpha_composite(layer)
    teks(base, (602, 1063), "TEKS DRAF", fb(12), fill=EMAS_T)


def teks_dialog(base):
    """Teks dialog (DRAF §1A babak 1-2). Krem di atas zamrud gelap —
    kontras tinggi, terbaca di HP. Posisi dihitung dinamis dari jumlah
    baris supaya tombol pilihan selalu berjarak rapi di bawah teks."""
    s = ("Ahlan wa sahlan, santri baru. Saya Ust. Aqsal M, pengasuh "
         "pesantren ini. Di sini kita belajar kitab kuning seperti "
         "pesantren sungguhan \u2014 tapi dibungkus game: misi, poin, "
         "dan gelar.")
    d_tmp = ImageDraw.Draw(base)
    baris = bungkus(d_tmp, s, fr(23), 470)
    y = 1108
    for b in baris:
        teks(base, (182, y), b, fr(23), fill=KREM, anchor="la")
        y += 30
    return y  # y akhir teks


def tombol_pilihan(base, y_teks):
    """2 tombol pilihan jawaban, ditumpuk penuh lebar panel.
    Pilihan 1 = emas padat (jawaban utama); pilihan 2 = outline krem
    (jawaban tanya). Keduanya tappable, teks gelap/terang kontras."""
    y1 = y_teks + 22
    y2 = y1 + 44 + 8
    # pilihan 1 — emas padat, teks zamrud gelap
    b1 = [60, y1, 660, y1 + 44]
    layer, d = _lapis(base)
    d.rounded_rectangle(b1, radius=22, fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(b1, radius=22, outline=(255, 240, 180, 255),
                         width=2)
    teks(base, (360, y1 + 22), "Baik, Ustadz. Saya siap belajar.",
         fb(20), fill=(4, 59, 44, 255))
    # pilihan 2 — outline krem, isi zamrud sedikit lebih gelap
    b2 = [60, y2, 660, y2 + 44]
    layer, d = _lapis(base)
    d.rounded_rectangle(b2, radius=22, fill=(3, 45, 34, 200))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(b2, radius=22, outline=KREM, width=2)
    teks(base, (360, y2 + 22), "Apa saja aturannya, Ustadz?",
         fb(20), fill=KREM)
    return y2 + 44


def petunjuk_bawah(base):
    """Baris petunjuk paling bawah panel: kiri = penanda babak
    (Babak 1 dari 5 — sesuai garis besar §1A); kanan = tombol
    gamepad (ikon digambar kode, bukan glyph — aman di semua font):
    X = Lanjut, kotak = Chat. Pemetaan BARU Mas 18:33 WIB — kotak
    adalah Chat (bukan Kamera); Kamera sudah pindah ke menu atas."""
    y = 1438
    teks(base, (60, y), "Babak 1 dari 5", fr(14), fill=KREM_T,
         anchor="lm")
    # susun dari kanan: [kotak] Chat  [X] Lanjut
    d_tmp = ImageDraw.Draw(base)
    f = fr(14)
    w_chat = d_tmp.textbbox((0, 0), "Chat", font=f)[2]
    w_lanjut = d_tmp.textbbox((0, 0), "Lanjut", font=f)[2]
    # total: ikon 12 + gap 6 + teks + gap 22, dua pasang
    total = (12 + 6 + w_lanjut) + 22 + (12 + 6 + w_chat)
    x = 660 - total
    layer, d = _lapis(base)
    # ikon X (dua garis miring)
    d.line([(x, y - 6), (x + 12, y + 6)], fill=KREM_T, width=2)
    d.line([(x, y + 6), (x + 12, y - 6)], fill=KREM_T, width=2)
    base.alpha_composite(layer)
    teks(base, (x + 18, y), "Lanjut", f, fill=KREM_T, anchor="lm")
    x2 = x + 18 + w_lanjut + 22
    layer, d = _lapis(base)
    d.rectangle([x2, y - 6, x2 + 12, y + 6], outline=KREM_T, width=2)
    base.alpha_composite(layer)
    teks(base, (x2 + 18, y), "Chat", f, fill=KREM_T, anchor="lm")


def build_dialog(subjudul="Pengasuh Pesantren Verse",
                 nama_file="dialog-aqsal-v1.png"):
    base = Image.open(BASE).convert("RGBA")
    # dim tipis seluruh scene — dialog itu modal, fokus ke panel
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 45))
    base.alpha_composite(layer)
    panel_dialog(base)
    # medali potret menimpa tepi kiri panel
    tile = medali_potret()
    base.alpha_composite(tile, (46, 1080))
    tab_nama(base, subjudul)
    tag_draf(base)
    y_teks = teks_dialog(base)
    tombol_pilihan(base, y_teks)
    petunjuk_bawah(base)
    out = OUTDIR + nama_file
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


def build_dialog_v2():
    """Revisi v2 (ACC Mas 18:53 WIB, syarat branding): subjudul jadi
    'Pengasuh Pesantren Universe'. Isi dialog lain TIDAK berubah.
    File BARU — v1 tidak ditimpa."""
    return build_dialog("Pengasuh Pesantren Universe",
                        "dialog-aqsal-v2.png")


# =====================================================================
# LANJUTAN GELOMBANG 3 — Fase A, A9 (Sinta, 18 Nov 2026)
# 3 mockup lanjutan, pola SAMA dengan dialog-aqsal-v1:
# panel gradien zamrud gelap + rim emas + tab emas + tag TEKS DRAF +
# footer petunjuk tombol (pemetaan BARU Mas 18:33: X = Lanjut/Tutup,
# kotak = Chat; Kamera di menu atas). Latar foto implementasi game.
# Isi contoh dari Modul 01 "Mengenal Kata" (menunggu tashih Mas) +
# draf v5.2 (§2.1 poin, §2.6 gelar, §1A alur santri baru).
# =====================================================================
FONT_AR = "/home/hatch/workspace/pesantren-verse/godot-dunia/fonts/Amiri-Bold.ttf"


def fa(sz):
    return ImageFont.truetype(FONT_AR, sz)


def base_dim():
    base = Image.open(BASE).convert("RGBA")
    layer, d = _lapis(base)
    d.rectangle([0, 0, 720, 1560], fill=(0, 0, 0, 45))
    base.alpha_composite(layer)
    return base


def panel_besar(base, y0=150, y1=1480):
    """Panel besar (hampir selayar) — gradien + rim sama seperti dialog."""
    box = [36, y0, 684, y1]
    rad = 24
    bayang_panel(base, box, rad)
    grad = vgrad((box[2] - box[0], box[3] - box[1]),
                 (4, 59, 44, 242), (6, 95, 70, 242))
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    layer.paste(grad, (box[0], box[1]), rounded_mask(grad.size, rad))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle(box, radius=rad, outline=EMAS, width=3)
    d.rounded_rectangle([box[0] + 5, box[1] + 5, box[2] - 5, box[3] - 5],
                        radius=rad - 4, outline=(242, 234, 214, 90), width=1)
    return box


def tab_judul(base, y0, judul):
    """Tab emas di tengah tepi atas panel (lebar ikut teks)."""
    font = fb(24)
    d_tmp = ImageDraw.Draw(base)
    w = d_tmp.textbbox((0, 0), judul, font=font)[2]
    bw = w + 56
    box = [360 - bw // 2, y0 - 22, 360 + bw // 2, y0 + 22]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=22, fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=22, outline=(255, 240, 180, 255),
                         width=2)
    teks(base, (360, y0), judul, font, fill=(4, 59, 44, 255))


def tag_draf_xy(base, cx, cy):
    """Penanda 'TEKS DRAF' di posisi bebas (pojok kanan atas panel)."""
    box = [cx - 62, cy - 13, cx + 62, cy + 13]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=13, outline=EMAS, width=2)
    base.alpha_composite(layer)
    teks(base, (cx, cy), "TEKS DRAF", fb(12), fill=EMAS_T)


def kartu(base, box, isi=(3, 45, 34, 200), outline=(242, 234, 214, 70),
          w=1, rad=16):
    """Kartu dalam panel — zamrud lebih gelap + outline krem tipis."""
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=rad, fill=isi)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=rad, outline=outline, width=w)


def bilah(base, box, frac):
    """Bilah progres: trek gelap + isi emas."""
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=8, fill=(3, 45, 34, 255))
    w = box[2] - box[0]
    fw = max(18, int(w * frac))
    d.rounded_rectangle([box[0], box[1], box[0] + fw, box[3]], radius=8,
                        fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=8, outline=(242, 234, 214, 90), width=1)


def tombol_emas(base, box, label, font=None):
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=22, fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=22, outline=(255, 240, 180, 255),
                         width=2)
    teks(base, ((box[0] + box[2]) // 2, (box[1] + box[3]) // 2), label,
         font or fb(20), fill=(4, 59, 44, 255))


def tombol_outline(base, box, label, font=None):
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=22, fill=(3, 45, 34, 200))
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=22, outline=KREM, width=2)
    teks(base, ((box[0] + box[2]) // 2, (box[1] + box[3]) // 2), label,
         font or fb(20), fill=KREM)


def petunjuk_kaki(base, kiri, pasangan, y=1438):
    """Footer panel: kiri = konteks, kanan = pasangan tombol gamepad.
    pasangan: list (jenis, label) — jenis 'x' atau 'kotak'."""
    teks(base, (60, y), kiri, fr(14), fill=KREM_T, anchor="lm")
    d_tmp = ImageDraw.Draw(base)
    f = fr(14)
    total = 0
    for jenis, lab in pasangan:
        total += 12 + 6 + d_tmp.textbbox((0, 0), lab, font=f)[2]
    total += 22 * (len(pasangan) - 1)
    x = 660 - total
    for jenis, lab in pasangan:
        layer, d = _lapis(base)
        if jenis == "x":
            d.line([(x, y - 6), (x + 12, y + 6)], fill=KREM_T, width=2)
            d.line([(x, y + 6), (x + 12, y - 6)], fill=KREM_T, width=2)
        else:  # kotak
            d.rectangle([x, y - 6, x + 12, y + 6], outline=KREM_T, width=2)
        base.alpha_composite(layer)
        teks(base, (x + 18, y), lab, f, fill=KREM_T, anchor="lm")
        w = d_tmp.textbbox((0, 0), lab, font=f)[2]
        x = x + 18 + w + 22


def gambar_bintang(d, cx, cy, r, isi=True):
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
    if isi:
        d.polygon(pts, fill=EMAS)
    else:
        d.line(pts + [pts[0]], fill=EMAS, width=2, joint="curve")


def gambar_centang(d, cx, cy, s, warna, width=3):
    d.line([(cx - s, cy), (cx - s * 0.3, cy + s * 0.7)], fill=warna,
           width=width)
    d.line([(cx - s * 0.3, cy + s * 0.7), (cx + s, cy - s * 0.8)],
           fill=warna, width=width)


def gambar_gembok(d, cx, cy, s, warna, width=2):
    d.arc([cx - s, cy - s - 6, cx + s, cy + 2], start=180, end=360,
          fill=warna, width=width)
    d.rounded_rectangle([cx - s, cy - 2, cx + s, cy + s + 2], radius=3,
                        outline=warna, width=width)


def gambar_putar(d, cx, cy, s, warna):
    d.polygon([(cx - s * 0.6, cy - s), (cx - s * 0.6, cy + s),
               (cx + s, cy)], fill=warna)


def ikon_kitab(base, cx, cy, r=32):
    """Ikon kitab terbuka di lingkaran emas (header Ruang Belajar)."""
    layer, d = _lapis(base)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=EMAS)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle([cx - 17, cy - 11, cx - 1, cy + 12], radius=3,
                         fill=KREM)
    d2.rounded_rectangle([cx + 1, cy - 11, cx + 17, cy + 12], radius=3,
                         fill=KREM)
    d2.line([(cx, cy - 11), (cx, cy + 12)], fill=(4, 59, 44, 255), width=2)
    d2.ellipse([cx - r, cy - r, cx + r, cy + r],
               outline=(255, 240, 180, 255), width=2)


def chip(base, x, y, label, font=None):
    """Chip kecil outline emas; kembalikan lebar chip."""
    font = font or fr(14)
    d_tmp = ImageDraw.Draw(base)
    w = d_tmp.textbbox((0, 0), label, font=font)[2] + 28
    box = [x, y, x + w, y + 34]
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=17, outline=EMAS, width=2)
    base.alpha_composite(layer)
    teks(base, (x + w // 2, y + 17), label, font, fill=EMAS_T)
    return w


# ------------------------------------------------------------------
# 1) UI RUANG BELAJAR — materi singkat + latihan + kuis (Modul 01)
# ------------------------------------------------------------------
def build_ruang_belajar():
    base = base_dim()
    panel_besar(base)
    tab_judul(base, 150, "Ruang Belajar")
    # header: ikon kitab + judul + pengajar
    ikon_kitab(base, 98, 228)
    teks(base, (142, 208), "Nahwu Dasar — Modul 01", fb(21), fill=KREM,
         anchor="la")
    teks(base, (142, 234), "Mengenal Kata • Bagian 1 (Hijau)", fr(15),
         fill=KREM_T, anchor="la")
    teks(base, (142, 258), "Pengajar: Ust. Sanusi", fr(15), fill=KREM_T,
         anchor="la")
    tag_draf_xy(base, 602, 210)
    # langkah 1-2-3
    labels = ["1  Materi", "2  Latihan", "3  Kuis"]
    w, gap = 190, 10
    for i, lab in enumerate(labels):
        box = [60 + i * (w + gap), 288, 60 + i * (w + gap) + w, 328]
        if i == 0:
            layer, d = _lapis(base)
            d.rounded_rectangle(box, radius=20, fill=EMAS)
            base.alpha_composite(layer)
            d2 = ImageDraw.Draw(base)
            d2.rounded_rectangle(box, radius=20,
                                 outline=(255, 240, 180, 255), width=2)
            teks(base, (box[0] + w // 2, 308), lab, fb(18),
                 fill=(4, 59, 44, 255))
        else:
            layer, d = _lapis(base)
            d.rounded_rectangle(box, radius=20, fill=(3, 45, 34, 200))
            base.alpha_composite(layer)
            d2 = ImageDraw.Draw(base)
            d2.rounded_rectangle(box, radius=20, outline=KREM, width=2)
            teks(base, (box[0] + w // 2, 308), lab, fb(18), fill=KREM)
    # kartu materi: definisi kalam + contoh Arab (Amiri) + catatan
    kartu(base, [60, 348, 660, 652])
    teks(base, (84, 372), "Apa itu kalam?", fb(21), fill=EMAS_T,
         anchor="la")
    d_tmp = ImageDraw.Draw(base)
    baris = bungkus(d_tmp, "Kalam adalah susunan kata yang memberi arti "
                     "sempurna, sehingga pendengar tidak bertanya lagi.",
                     fr(19), 540)
    y = 408
    for b in baris:
        teks(base, (84, y), b, fr(19), fill=KREM, anchor="la")
        y += 26
    teks(base, (360, 496), "قَامَ مُحَمَّدٌ", fa(34), fill=EMAS_T)
    teks(base, (360, 544), "Qaama Muhammadun — “Muhammad telah berdiri.”",
         fr(16), fill=KREM_T)
    layer, d = _lapis(base)
    d.line([(84, 580), (636, 580)], fill=(242, 234, 214, 60), width=1)
    base.alpha_composite(layer)
    teks(base, (360, 606), "Kenali cirinya, bukan hafalan definisinya.",
         fr(16), fill=KREM_T)
    # 3 kartu jenis kata
    mini = [("ISIM", "tanwin • al- • jer", "kata benda & nama"),
            ("FI'IL", "qad • sin • saufa", "kata kerja & waktu"),
            ("HURUF", "penghubung kecil", "bermakna bila digabung")]
    for i, (judul, ciri, jenis) in enumerate(mini):
        x0 = 60 + i * 206
        kartu(base, [x0, 672, x0 + 188, 792])
        teks(base, (x0 + 94, 706), judul, fb(19), fill=EMAS_T)
        teks(base, (x0 + 94, 740), ciri, fr(14), fill=KREM)
        teks(base, (x0 + 94, 764), jenis, fr(14), fill=KREM_T)
    # rumus 10 detik
    kartu(base, [60, 812, 660, 972])
    teks(base, (84, 836), "Rumus 10 detik", fb(19), fill=EMAS_T,
         anchor="la")
    for j, r in enumerate(["1.  Ada tanwin atau al-? Itu isim.",
                           "2.  Ada qad, sin, atau saufa? Itu fi'il.",
                           "3.  Kata pendek penghubung? Itu huruf."]):
        teks(base, (84, 872 + j * 28), r, fr(17), fill=KREM, anchor="la")
    # bait hafalan
    kartu(base, [60, 992, 660, 1140])
    teks(base, (84, 1016), "Bait hafalan", fb(17), fill=EMAS_T,
         anchor="la")
    baris = bungkus(d_tmp, "“Kata itu tiga, hafalkanlah: isim, fi'il, dan "
                     "huruf yang datang untuk suatu makna — maka "
                     "ketahuilah ia.”", fr(17), 540)
    y = 1046
    for b in baris:
        teks(base, (84, y), b, fr(17), fill=KREM, anchor="la")
        y += 24
    # hadiah langkah (chip diukur dulu supaya barisnya terpusat)
    teks(base, (360, 1184),
         "Selesai materi → latihan 5 soal → kuis 1 soal", fr(14),
         fill=KREM_T)
    d_tmp = ImageDraw.Draw(base)
    hadiah = ["+10 poin materi", "+15 latihan", "+10 hafalan"]
    lebar = [d_tmp.textbbox((0, 0), h, font=fr(14))[2] + 28
             for h in hadiah]
    x = 360 - (sum(lebar) + 20) // 2
    for h, w in zip(hadiah, lebar):
        chip(base, x, 1212, h)
        x += w + 10
    tombol_emas(base, [60, 1280, 660, 1324], "Lanjut ke Latihan")
    petunjuk_kaki(base, "Materi 1 dari 3", [("x", "Lanjut"), ("kotak", "Chat")])
    out = OUTDIR + "ruang-belajar-v1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ------------------------------------------------------------------
# 2) UI TES KENAIKAN — kuis 10 soal di Kantor, lulus ≥ 8/10
# ------------------------------------------------------------------
def opsi_jawaban(base, box, huruf, label, dipilih=False):
    if dipilih:
        layer, d = _lapis(base)
        d.rounded_rectangle(box, radius=14, fill=EMAS)
        base.alpha_composite(layer)
        d2 = ImageDraw.Draw(base)
        d2.rounded_rectangle(box, radius=14,
                             outline=(255, 240, 180, 255), width=2)
        isi, teks_w = (4, 59, 44, 255), (4, 59, 44, 255)
    else:
        layer, d = _lapis(base)
        d.rounded_rectangle(box, radius=14, fill=(3, 45, 34, 200))
        base.alpha_composite(layer)
        d2 = ImageDraw.Draw(base)
        d2.rounded_rectangle(box, radius=14, outline=KREM, width=2)
        isi, teks_w = KREM, KREM
    cy = (box[1] + box[3]) // 2
    layer, d = _lapis(base)
    d.ellipse([box[0] + 14, cy - 16, box[0] + 46, cy + 16],
              outline=isi, width=2)
    base.alpha_composite(layer)
    teks(base, (box[0] + 30, cy), huruf, fb(17), fill=isi)
    teks(base, (box[0] + 60, cy), label, fb(19), fill=teks_w,
         anchor="lm")


def build_tes_kenaikan():
    base = base_dim()
    panel_besar(base)
    tab_judul(base, 150, "Tes Kenaikan")
    teks(base, (60, 206), "Kantor • Tes Naik Bagian 2 (N1.T)", fb(20),
         fill=KREM, anchor="la")
    teks(base, (60, 232), "10 soal • Lulus bila benar ≥ 8 • +20 poin bila "
         "lulus", fr(15), fill=KREM_T, anchor="la")
    tag_draf_xy(base, 602, 214)
    # progres soal
    kartu(base, [60, 268, 660, 360])
    teks(base, (84, 292), "Soal 4 dari 10", fb(17), fill=KREM, anchor="la")
    teks(base, (636, 292), "Benar 3 • Salah 0", fr(14), fill=KREM_T,
         anchor="rm")
    bilah(base, [84, 314, 636, 330], 0.4)
    # kartu soal + 4 pilihan
    kartu(base, [60, 380, 660, 830])
    teks(base, (84, 404), "SOAL 4", fb(14), fill=EMAS_T, anchor="la")
    d_tmp = ImageDraw.Draw(base)
    baris = bungkus(d_tmp, "Kata “al-kitaabu” termasuk jenis kata apa?",
                    fb(21), 540)
    y = 434
    for b in baris:
        teks(base, (84, y), b, fb(21), fill=KREM, anchor="la")
        y += 28
    teks(base, (84, y + 6),
         "Petunjuk: kata diawali al- — ingat ciri isim di Modul 01.",
         fr(15), fill=KREM_T, anchor="la")
    opsi = [("A", "Isim", True), ("B", "Fi'il", False),
            ("C", "Huruf", False), ("D", "Bukan ketiganya", False)]
    y = 510
    for huruf, label, dipilih in opsi:
        opsi_jawaban(base, [84, y, 636, y + 64], huruf, label, dipilih)
        y += 76
    tombol_emas(base, [60, 856, 660, 900], "Kunci Jawaban")
    # jawaban sejauh ini
    teks(base, (60, 934), "Jawaban sejauh ini:", fr(15), fill=KREM_T,
         anchor="la")
    x = 60
    for lab in ["Soal 1 ✓ Benar", "Soal 2 ✓ Benar", "Soal 3 ✓ Benar"]:
        x += chip(base, x, 962, lab)
        x += 10
    # kartu contoh hasil (lulus / gagal)
    kartu(base, [60, 1022, 660, 1262])
    layer, d = _lapis(base)
    d.rounded_rectangle([84, 1046, 224, 1072], radius=13, outline=EMAS,
                        width=2)
    base.alpha_composite(layer)
    teks(base, (154, 1059), "CONTOH HASIL", fb(12), fill=EMAS_T)
    teks(base, (84, 1100), "LULUS — 9/10", fb(22), fill=EMAS_T,
         anchor="la")
    x = 84
    for lab in ["+20 poin", "+2 bintang gelar", "Buka Bagian 2"]:
        x += chip(base, x, 1136, lab)
        x += 10
    baris = bungkus(d_tmp, "Gagal = ulangi kuisnya saja, bukan dari awal. "
                     "Bintang tidak berkurang.", fr(15), 540)
    y = 1196
    for b in baris:
        teks(base, (84, y), b, fr(15), fill=KREM_T, anchor="la")
        y += 22
    teks(base, (360, 1300),
         "Hasil tersimpan • gelar & poin masuk Kartu Santri", fr(14),
         fill=KREM_T)
    petunjuk_kaki(base, "N1.T • Kantor", [("x", "Keluar"), ("kotak", "Chat")])
    out = OUTDIR + "tes-kenaikan-v1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


# ------------------------------------------------------------------
# 3) PANEL MISI — daftar misi aktif + progres Bagian + gelar
# ------------------------------------------------------------------
def baris_misi(base, y, status, kode, nama, poin, aktif=False):
    h = 58
    box = [60, y, 660, y + h]
    if aktif:
        isi, outl, w = (6, 95, 70, 255), EMAS, 2
    elif status == "selesai":
        isi, outl, w = (3, 45, 34, 160), (242, 234, 214, 45), 1
    else:
        isi, outl, w = (3, 45, 34, 120), (242, 234, 214, 35), 1
    layer, d = _lapis(base)
    d.rounded_rectangle(box, radius=14, fill=isi)
    base.alpha_composite(layer)
    d2 = ImageDraw.Draw(base)
    d2.rounded_rectangle(box, radius=14, outline=outl, width=w)
    cy = y + h // 2
    layer, d = _lapis(base)
    if status == "selesai":
        gambar_centang(d, 86, cy, 8, EMAS, width=3)
        warna_nama, warna_poin = (242, 234, 214, 205), KREM_T
    elif aktif:
        gambar_putar(d, 86, cy, 9, EMAS)
        warna_nama, warna_poin = KREM, EMAS_T
    else:
        gambar_gembok(d, 86, cy, 8, KREM_T, width=2)
        warna_nama, warna_poin = (242, 234, 214, 160), KREM_T
    base.alpha_composite(layer)
    teks(base, (112, cy), kode, fb(15), fill=EMAS_T, anchor="lm")
    teks(base, (168, cy), nama, fb(18), fill=warna_nama, anchor="lm")
    teks(base, (640, cy), poin, fr(14), fill=warna_poin, anchor="rm")
    if aktif:
        layer, d = _lapis(base)
        d.rounded_rectangle([470, cy - 13, 544, cy + 13], radius=13,
                            fill=EMAS)
        base.alpha_composite(layer)
        teks(base, (507, cy), "AKTIF", fb(11), fill=(4, 59, 44, 255))


def build_panel_misi():
    base = base_dim()
    panel_besar(base)
    tab_judul(base, 150, "Panel Misi")
    # tag draf di atas kartu gelar (kartu mulai y=186) — jangan
    # sampai tertutup kartu seperti revisi pertama
    tag_draf_xy(base, 602, 168)
    # kartu gelar saat ini
    kartu(base, [60, 186, 660, 392])
    teks(base, (84, 210), "GELAR SAAT INI", fr(13), fill=KREM_T,
         anchor="la")
    teks(base, (84, 240), "Thalib al-'Ilm", fb(26), fill=EMAS_T,
         anchor="la")
    teks(base, (84, 274), "Penuntut Ilmu • Divisi II", fr(16), fill=KREM,
         anchor="la")
    layer, d = _lapis(base)
    for i in range(3):
        gambar_bintang(d, 100 + i * 34, 316, 13, isi=(i < 2))
    base.alpha_composite(layer)
    teks(base, (212, 316), "2/3 bintang", fr(15), fill=KREM, anchor="lm")
    bilah(base, [84, 344, 636, 360], 2 / 3)
    teks(base, (636, 380), "35 poin • Bagian 1 (Hijau)", fr(14),
         fill=KREM_T, anchor="rm")
    # progres Bagian 1
    teks(base, (60, 428), "Bagian 1 (Hijau) — 3 dari 7 misi", fb(17),
         fill=KREM, anchor="la")
    bilah(base, [60, 456, 660, 472], 3 / 7)
    teks(base, (660, 492), "35/110 poin", fr(14), fill=KREM_T,
         anchor="rm")
    # daftar misi Bagian 1
    teks(base, (60, 530), "MISI BAGIAN 1", fr(13), fill=KREM_T,
         anchor="la")
    misi = [("selesai", "N1.1", "Kenalan dengan Nahwu", "+10 poin", False),
            ("selesai", "N1.2", "Isim", "+10 poin", False),
            ("selesai", "N1.3", "Fi'il", "+10 poin", False),
            ("aktif", "N1.4", "Huruf — Ust. Sanusi",
             "+10 poin", True),
            ("kunci", "N1.5", "Latihan mabni / mu'rob", "+15 poin", False),
            ("kunci", "N1.6", "Hafalan bait", "+10 poin", False),
            ("kunci", "N1.7", "Peti Hijau", "+25 poin", False),
            ("kunci", "N1.T", "Tes Naik Bagian 2 — Kantor", "+20 poin",
             False)]
    y = 552
    for status, kode, nama, poin, aktif in misi:
        baris_misi(base, y, status, kode, nama, poin, aktif)
        y += 64
    # tugas dari Ustadz
    kartu(base, [60, y + 8, 660, y + 92], outline=EMAS, w=2)
    teks(base, (84, y + 32), "Tugas dari Ustadz (N1.3)", fb(16),
         fill=EMAS_T, anchor="la")
    teks(base, (84, y + 60),
         "Hafal bait + baca 1 bab di rak kitab — Selesai ✓ • +5 poin",
         fr(15), fill=KREM, anchor="la")
    y = y + 92
    teks(base, (360, y + 30),
         "Pola misi: cari Ustadz → belajar → tugas dari Ustadz", fr(14),
         fill=KREM_T)
    # pratinjau Bagian 2 (terkunci) — supaya progres ke depan kebaca
    kartu(base, [60, y + 56, 660, y + 140], isi=(3, 45, 34, 120),
          outline=(242, 234, 214, 35))
    layer, d = _lapis(base)
    gambar_gembok(d, 92, y + 98, 9, KREM_T, width=2)
    base.alpha_composite(layer)
    teks(base, (120, y + 82), "Bagian 2 (Biru) — Isim Lebih Dalam", fb(18),
         fill=(242, 234, 214, 160), anchor="la")
    teks(base, (120, y + 110), "Terbuka setelah lulus N1.T • 100 poin",
         fr(14), fill=KREM_T, anchor="la")
    petunjuk_kaki(base, "Bagian 1 dari 4 • Nahwu Dasar",
                 [("x", "Tutup"), ("kotak", "Chat")])
    out = OUTDIR + "panel-misi-v1.png"
    base.convert("RGB").save(out)
    print("OK", out, base.size)
    return out


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "lanjutan":
        build_ruang_belajar()
        build_tes_kenaikan()
        build_panel_misi()
    elif len(sys.argv) > 1 and sys.argv[1] == "dialog-v2":
        build_dialog_v2()
    else:
        build_dialog()
