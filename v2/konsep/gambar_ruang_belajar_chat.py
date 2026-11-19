#!/usr/bin/env python3
"""Mockup konsep Ruang Belajar versi CHAT — Sinta, 19 Nov 2026.
Ide Mas (19 Nov 14:35): Ruang Belajar jadi sistem dialog seperti
mengajar betulan — pesan ustadz muncul seperti diketik, player
menjawab lewat tombol pilihan (pola game, bukan kolom ketik bebas).
3 gambar: (A) menunggu jawaban "Paham?", (B) efek ketik + cabang
"Belum paham", (C) diagram alur pemetaan Modul 01 -> percakapan.
Palet resmi PV (GayaMisi). Font Baloo 2. Contoh Arab hanya
transliterasi di mockup (PIL tak membentuk huruf Arab) — di game
tetap Amiri seperti sekarang.
"""
from PIL import Image, ImageDraw, ImageFont
import os

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

ZAMRUD = (6, 95, 70)
ZAMRUD_G = (4, 59, 44)
ZAMRUD_PANEL = (13, 59, 46)
ZAMRUD_KARTU = (3, 45, 34)
EMAS = (201, 162, 39)
EMAS_T = (232, 196, 90)
KREM = (242, 234, 214)
KREM_R = (201, 194, 174)
KULIT = (198, 142, 94)
GELAP = (40, 30, 25)
HITAM = (18, 18, 18)
ABU = (110, 110, 110)
HIJAU_ON = (46, 204, 113)
DIM = (16, 20, 20)

def wrap(d, teks, f, lebar):
    """Bungkus kata per kata ke lebar piksel."""
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

def panel_gradien(W, H, x0, y0, x1, y1, radius=26):
    """Panel gradien zamrud vertikal + rim emas, kembalikan (img, d)."""
    img = Image.new("RGB", (W, H), DIM)
    grad = Image.new("RGB", (x1 - x0, y1 - y0))
    gd = ImageDraw.Draw(grad)
    for y in range(y1 - y0):
        t = y / max(1, (y1 - y0 - 1))
        c = tuple(int(ZAMRUD[i] + (ZAMRUD_G[i] - ZAMRUD[i]) * t) for i in range(3))
        gd.line([(0, y), (x1 - x0, y)], fill=c)
    mask = Image.new("L", (x1 - x0, y1 - y0), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, x1 - x0 - 1, y1 - y0 - 1], radius=radius, fill=255)
    img.paste(grad, (x0, y0), mask)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([x0, y0, x1, y1], radius=radius, outline=EMAS, width=2)
    return img, d

def avatar_sanusi(d, cx, cy, r, mini=False):
    """Medali Sanusi — meniru AvatarMisi 'sanusi', tapi peci HITAM
    NASIONAL (rata) sesuai build Kirana 19 Nov (bukan songkok putih
    lama). Jubah zamrud + kerah emas V."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=KREM, outline=EMAS, width=4)
    # jubah (bawah, terpotong lingkaran)
    d.polygon([(cx - r * 0.72, cy + r * 0.28), (cx + r * 0.72, cy + r * 0.28),
               (cx + r * 0.95, cy + r * 0.95), (cx - r * 0.95, cy + r * 0.95)], fill=ZAMRUD)
    # wajah
    d.ellipse([cx - r * 0.36, cy - r * 0.42, cx + r * 0.36, cy + r * 0.32], fill=KULIT)
    # peci hitam nasional: trapesium atas rata + lis
    d.polygon([(cx - r * 0.40, cy - r * 0.12), (cx - r * 0.34, cy - r * 0.62),
               (cx + r * 0.34, cy - r * 0.62), (cx + r * 0.40, cy - r * 0.12)],
              fill=(21, 21, 21))
    d.rectangle([cx - r * 0.40, cy - r * 0.16, cx + r * 0.40, cy - r * 0.06], fill=(13, 13, 13))
    # mata + senyum
    er = max(2, int(r * 0.055))
    ey = cy - r * 0.05
    ex = r * 0.16
    for sx in (-1, 1):
        d.ellipse([cx + sx * ex - er, ey - er, cx + sx * ex + er, ey + er], fill=GELAP)
    d.arc([cx - r * 0.16, cy + r * 0.08, cx + r * 0.16, cy + r * 0.30],
          15, 165, fill=GELAP, width=max(2, int(r * 0.04)))
    # kerah emas V
    d.line([cx, cy + r * 0.42, cx - r * 0.30, cy + r * 0.72], fill=EMAS, width=3)
    d.line([cx, cy + r * 0.42, cx + r * 0.30, cy + r * 0.72], fill=EMAS, width=3)

def gelembung_ustadz(d, x, y, lebar_maks, teks, f, nama=None, jam=None,
                     isi=ZAMRUD_KARTU, teks_warna=KREM):
    """Gelembung kiri. Kembalikan tinggi total yang dipakai."""
    pad = 16
    garis = wrap(d, teks, f, lebar_maks - pad * 2)
    lh = int(f.size * 1.35)
    ekstra_nama = 20 if nama else 0
    tinggi = pad * 2 + lh * len(garis) + (18 if jam else 0) + ekstra_nama
    d.rounded_rectangle([x, y, x + lebar_maks, y + tinggi], radius=16,
                        fill=isi, outline=(242, 234, 214, 90), width=1)
    ty = y + pad
    if nama:
        d.text((x + pad, ty - 2), nama, font=font(14), fill=EMAS_T)
        ty += ekstra_nama
    for ln in garis:
        d.text((x + pad, ty), ln, font=f, fill=teks_warna)
        ty += lh
    if jam:
        d.text((x + lebar_maks - pad - d.textlength(jam, font=font(12)), y + tinggi - 20),
               jam, font=font(12), fill=KREM_R)
    return tinggi

def gelembung_pemain(d, x_kanan, y, lebar_maks, teks, f, jam=None):
    """Gelembung kanan emas (jawaban player). Kembalikan tinggi."""
    pad = 16
    garis = wrap(d, teks, f, lebar_maks - pad * 2)
    lh = int(f.size * 1.35)
    tinggi = pad * 2 + lh * len(garis) + (18 if jam else 0)
    # lebar sebenarnya mengikuti teks terpanjang
    w = max(d.textlength(ln, font=f) for ln in garis) + pad * 2
    w = min(w, lebar_maks)
    x = x_kanan - w
    d.rounded_rectangle([x, y, x + w, y + tinggi], radius=16, fill=EMAS)
    ty = y + pad
    for ln in garis:
        d.text((x + pad, ty), ln, font=f, fill=ZAMRUD_G)
        ty += lh
    if jam:
        d.text((x + w - pad - d.textlength(jam, font=font(12)), y + tinggi - 20),
               jam, font=font(12), fill=(90, 70, 20))
    return tinggi

def tombol(d, x, y, w, h, teks, f, emas=True, redup=False):
    if emas:
        isi = tuple(int(c * 0.45) for c in EMAS) if redup else EMAS
        d.rounded_rectangle([x, y, x + w, y + h], radius=22, fill=isi)
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=ZAMRUD_G, anchor="mm")
    else:
        isi = ZAMRUD_KARTU
        d.rounded_rectangle([x, y, x + w, y + h], radius=22, fill=isi,
                            outline=KREM, width=2)
        warna = tuple(int(c * 0.55) for c in KREM) if redup else KREM
        d.text((x + w / 2, y + h / 2), teks, font=f, fill=warna, anchor="mm")

def header(img, d, px0, px1, pengajar="Ust. Sanusi", peran="Pengajar Nahwu Dasar"):
    # tab emas + tutup
    tab = "RUANG BELAJAR"
    tf = font(22)
    tw = d.textlength(tab, font=tf) + 56
    d.rounded_rectangle([px0, 62, px0 + tw, 62 + 44], radius=22, fill=EMAS)
    d.text((px0 + tw / 2, 84), tab, font=tf, fill=ZAMRUD_G, anchor="mm")
    d.text((px1 - 8, 84), "×", font=font(30), fill=KREM, anchor="mm")
    d.text((px0, 122), "Nahwu Dasar — Modul 01", font=font(30), fill=EMAS)
    d.text((px0, 158), "Mengenal Kata  •  Bagian 1 (Hijau)", font=font(18), fill=KREM)
    # baris pengajar
    avatar_sanusi(d, px0 + 32, 218, 32)
    d.text((px0 + 78, 198), pengajar, font=font(22), fill=KREM)
    d.text((px0 + 78, 226), peran, font=font(16), fill=KREM_R)
    d.ellipse([px1 - 190, 208, px1 - 178, 220], fill=HIJAU_ON)
    d.text((px1 - 170, 214), "sedang mengajar", font=font(16), fill=HIJAU_ON, anchor="lm")
    d.line([(px0, 256), (px1, 256)], fill=EMAS, width=2)

def footer(img, d, px0, px1, y, kiri, kanan="× Tutup", progres=None):
    d.text((px0, y), kiri, font=font(16), fill=KREM_R)
    d.text((px1, y), kanan, font=font(16), fill=KREM_R, anchor="ra")
    if progres is not None:
        bx0, bx1, by = px0, px1, y - 14
        d.rounded_rectangle([bx0, by, bx1, by + 8], radius=4, fill=ZAMRUD_KARTU)
        d.rounded_rectangle([bx0, by, bx0 + (bx1 - bx0) * progres, by + 8],
                            radius=4, fill=EMAS)

# ---------------------------------------------------------------- A. MENUNGGU JAWABAN
def mockup_a():
    W, H = 1280, 720
    img, d = panel_gradien(W, H, 90, 40, 1190, 680)
    px0, px1 = 120, 1160
    header(img, d, px0, px1)
    y = 272
    # pesan 1
    avatar_sanusi(d, px0 + 22, y + 24, 22)
    y += gelembung_ustadz(d, px0 + 56, y, 640,
        "Assalamu'alaikum, Nak. Hari ini kita belajar Nahwu Dasar — Modul 01: Mengenal Kata.",
        font(19), nama="Ust. Sanusi", jam="12:01") + 14
    # pesan 2 — contoh PERSIS Mas
    avatar_sanusi(d, px0 + 22, y + 24, 22)
    y += gelembung_ustadz(d, px0 + 56, y, 700,
        "kalam itu artinya adalah susunan kalimat. Kalimat disini maksudnya adalah kata dalam bahasa indonesia. Paham?",
        font(19), jam="12:01") + 14
    # tombol jawaban
    by = 548
    tombol(d, px0, by, 500, 52, "Paham, lanjut  ›", font(20), emas=True)
    tombol(d, px0 + 540, by, 500, 52, "Belum, jelaskan lagi", font(20), emas=False)
    footer(img, d, px0, px1, 636, "Pesan 2 dari 14  •  Materi", progres=2 / 14)
    img.save(f"{OUT}/konsep-ruang-belajar-chat-v1.png")

# ---------------------------------------------------------------- B. EFEK KETIK + CABANG
def mockup_b():
    W, H = 1280, 720
    img, d = panel_gradien(W, H, 90, 40, 1190, 680)
    px0, px1 = 120, 1160
    header(img, d, px0, px1)
    y = 272
    # pesan ustadz (contoh Mas, ringkas)
    avatar_sanusi(d, px0 + 22, y + 24, 22)
    y += gelembung_ustadz(d, px0 + 56, y, 700,
        "kalam itu artinya adalah susunan kalimat. Kalimat disini maksudnya adalah kata dalam bahasa indonesia. Paham?",
        font(19), jam="12:01") + 10
    # jawaban player
    y += gelembung_pemain(d, px1, y, 420, "Belum, jelaskan lagi.", font(19)) + 10
    # pesan ustadz SEDANG DIKETIK (huruf muncul sebagian + kursor)
    avatar_sanusi(d, px0 + 22, y + 24, 22)
    teks_ketik = ("Baik, coba contoh ini: Qaama Muhammadun — “Muhammad telah berdiri.” "
                  "Itu kalam, karena pendengar sudah paham dan tidak bertanya lagi. ▍")
    y += gelembung_ustadz(d, px0 + 56, y, 700, teks_ketik, font(19)) + 6
    d.text((px0 + 56, y), "Ust. Sanusi sedang mengetik…", font=font(15), fill=EMAS_T)
    # tombol jawaban TERKUNCI (redup) — tanpa label tambahan: status
    # "sedang mengetik…" di atas sudah menjelaskan kenapa terkunci.
    # by=560 (bukan 548 seperti mockup A): gelembung 1 membawa jam
    # (+18 px) sehingga isi chat B lebih tinggi 18 px.
    by = 560
    tombol(d, px0, by, 500, 52, "Paham, lanjut  ›", font(20), emas=True, redup=True)
    tombol(d, px0 + 540, by, 500, 52, "Belum, jelaskan lagi", font(20), emas=False, redup=True)
    footer(img, d, px0, px1, 636,
           "Pesan 4 dari 14  •  Materi — penjelasan ulang 1 dari 2", progres=4 / 14)
    img.save(f"{OUT}/konsep-ruang-belajar-chat-ketik-v1.png")

# ---------------------------------------------------------------- C. DIAGRAM ALUR
def kotak(d, x, y, w, h, judul, sub, isi=ZAMRUD_KARTU, garis=EMAS, tj=EMAS, ts=KREM):
    d.rounded_rectangle([x, y, x + w, y + h], radius=12, fill=isi, outline=garis, width=2)
    d.text((x + w / 2, y + 12), judul, font=font(19), fill=tj, anchor="mt")
    if sub:
        for i, ln in enumerate(sub.split("\n")):
            d.text((x + w / 2, y + 40 + i * 19), ln, font=font(15), fill=ts, anchor="mt")

def panah(d, x0, y, x1, putus=False):
    if putus:
        xx = x0
        while xx < x1 - 8:
            d.line([(xx, y), (xx + 8, y)], fill=EMAS, width=3)
            xx += 14
    else:
        d.line([(x0, y), (x1, y)], fill=EMAS, width=3)
    d.polygon([(x1, y), (x1 - 10, y - 6), (x1 - 10, y + 6)], fill=EMAS)

def diagram():
    W, H = 1280, 860
    img = Image.new("RGB", (W, H), (250, 246, 236))
    d = ImageDraw.Draw(img)
    d.text((24, 14), "ALUR — RUANG BELAJAR CHAT  (Modul 01: 14 pesan + cabang)",
           font=font(28), fill=ZAMRUD_G)
    d.text((24, 50), "Materi mengalir otomatis (tap = lewati ketikan)  •  berhenti hanya di titik “Paham?” dan soal",
           font=font(19), fill=ABU)
    # baris 1: materi
    y1, h1 = 92, 86
    b1 = [(24, "1 · SALAM", "Assalamu'alaikum,\nbelajar Modul 01"),
          (252, "2 · KALAM", "“kalam itu artinya…\nPaham?”  → cek 1"),
          (480, "3 · KATA ×3", "isim → fi'il → huruf\n(pesan berurutan)"),
          (708, "4 · RUMUS", "Rumus 10 detik\n(tanwin? isim…)"),
          (936, "5 · BAIT", "Bait hafalan\nBagian 1")]
    for (x, j, s) in b1:
        kotak(d, x, y1, 200, h1, j, s)
    for i in range(4):
        panah(d, 24 + 200 + i * 228, y1 + h1 / 2, 24 + 228 + i * 228)
    # cabang Belum (di bawah kotak 2)
    d.rounded_rectangle([252, 210, 452, 300], radius=12, fill=(255, 251, 235),
                        outline=EMAS, width=2)
    d.text((352, 222), "BELUM → PENJELASAN ULANG", font=font(17), fill=ZAMRUD_G, anchor="mt")
    for i, ln in enumerate(["Contoh Qaama Muhammadun", "cek lagi — maks 2×, lalu",
                            "ringkasan + lanjut otomatis"]):
        d.text((352, 248 + i * 19), ln, font=font(15), fill=ZAMRUD_G, anchor="mt")
    d.line([(352, 178), (352, 210)], fill=EMAS, width=3)
    d.polygon([(352, 210), (346, 200), (358, 200)], fill=EMAS)
    # baris 2: cek akhir materi + poin
    y2, h2 = 336, 86
    kotak(d, 24, y2, 320, h2, "6 · CEK AKHIR MATERI", "“Paham?” terakhir  →  +10 poin materi")
    panah(d, 344, y2 + h2 / 2, 380)
    kotak(d, 380, y2, 320, h2, "7 · LATIHAN  L1–L5", "soal chat, 4 opsi  •  salah → ustadz\njelaskan + soal yang sama")
    panah(d, 700, y2 + h2 / 2, 736)
    kotak(d, 736, y2, 320, h2, "+15 POIN LATIHAN", "setelah 5 soal benar")
    panah(d, 1056, y2 + h2 / 2, 1092)
    kotak(d, 1092, y2, 164, h2, "8 · KUIS  K1", "1 soal bank N1.T", isi=(13, 59, 46))
    # baris 3: selesai
    y3, h3 = 470, 86
    kotak(d, 24, y3, 320, h3, "+10 POIN KUIS", "jawaban benar")
    panah(d, 344, y3 + h3 / 2, 380)
    kotak(d, 380, y3, 420, h3, "SELESAI — 35 POIN", "kartu penutup + tombol Tutup\n→ maju langkah 6 (Tes Kenaikan)",
          isi=ZAMRUD, garis=EMAS_T, tj=EMAS_T)
    panah(d, 800, y3 + h3 / 2, 836)
    kotak(d, 836, y3, 420, h3, "TUTUP DI TENGAH?", "lanjut dari pesan terakhir\n(rb_chat_pos) — poin langkah\nselesai TIDAK hilang",
          isi=(255, 251, 235), garis=EMAS, tj=ZAMRUD_G, ts=ZAMRUD_G)
    # konektor siku: baris 1 (kanan, kotak 5) -> baris 2 (kiri, kotak 6)
    d.line([(1036, y1 + h1), (1036, 312)], fill=EMAS, width=3)
    d.line([(1036, 312), (184, 312)], fill=EMAS, width=3)
    d.line([(184, 312), (184, y2)], fill=EMAS, width=3)
    d.polygon([(184, y2), (178, y2 - 10), (190, y2 - 10)], fill=EMAS)
    # catatan bawah
    d.text((24, 590), "Aturan main",
           font=font(22), fill=ZAMRUD_G)
    for i, t in enumerate([
        "•  Pesan materi mengalir otomatis setelah ketikan selesai (jeda ±800 ms); tap gelembung = tampil penuh.",
        "•  Tombol jawaban terkunci selama ustadz mengetik — tidak bisa menjawab sebelum pesan selesai.",
        "•  Soal salah: opsi yang salah dimatikan, ustadz menjelaskan (pakai “petunjuk” dari data), soal yang sama diulang.",
        "•  Buka ulang setelah selesai: mode baca ulang (riwayat tampil penuh, tanpa efek ketik) — TANPA poin lagi.",
        "•  Putri: pengajar Ustzh. Fatimah, avatar jilbab krem — alur dan pesan SAMA.",
    ]):
        d.text((24, 622 + i * 30), t, font=font(18), fill=(60, 60, 60))
    d.text((24, 800), "Data tidak berubah: DataModul01 + MesinKuis dipakai ulang  •  sinyal langkah_selesai/selesai tetap — main.gd tidak berubah.",
           font=font(18), fill=ABU)
    img.save(f"{OUT}/konsep-ruang-belajar-chat-alur-v1.png")

mockup_a()
mockup_b()
diagram()
print("selesai")
