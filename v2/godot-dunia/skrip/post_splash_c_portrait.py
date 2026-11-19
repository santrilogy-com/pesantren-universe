#!/usr/bin/env python3
"""Post-process splash portrait 9:16 — varian C: judul "PESANTREN UNIVERSE"
MELENGKUNG (busur) di bagian ATAS, dua baris pada busur sepusat.
Baloo 2 ExtraBold emas #f2c14e + outline zamrud gelap #043B2C, sama
dengan varian C landscape. Scrim gradien zamrud gelap di atas supaya
judul terbaca di atas langit terang.

Masuk : v2/konsep/konsep-splash-c-karakter-portrait-mentah.png (720x1280)
Keluar: v2/konsep/konsep-splash-c-karakter-portrait.png
"""
import math

from PIL import Image, ImageDraw, ImageFont

MASUK = "/home/hatch/workspace/pesantren-verse/v2/konsep/konsep-splash-c-karakter-portrait-mentah.png"
KELUAR = "/home/hatch/workspace/pesantren-verse/v2/konsep/konsep-splash-c-karakter-portrait.png"
FONT = "/home/hatch/workspace/pesantren-verse/v2/godot-dunia/fonts/Baloo2-Variable.ttf"

EMAS = (242, 193, 78)      # #f2c14e
ZAMRUD_GELAP = (4, 59, 44)  # #043B2C

img = Image.open(MASUK).convert("RGBA")
W, H = img.size
assert (W, H) == (720, 1280), (W, H)

# --- Scrim gradien atas: pekat di y=0 -> transparan di y=400.
scrim = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = scrim.load()
Y0, Y1, A_MAX = 0, 400, 110
for y in range(Y0, Y1):
    t = (y - Y0) / (Y1 - Y0)
    a = int(A_MAX * (1.0 - t) * (1.0 - t))  # ease-out: pekat di atas
    for x in range(W):
        px[x, y] = (ZAMRUD_GELAP[0], ZAMRUD_GELAP[1], ZAMRUD_GELAP[2], a)
img = Image.alpha_composite(img, scrim)

# --- Judul melengkung: tiap huruf digambar di ubin sendiri, diputar
# mengikuti busur (pusat busur di bawah teks -> busur membumbung ke atas).
SIZE = 56
STROKE = 6
font = ImageFont.truetype(FONT, SIZE)
try:
    font.set_variation_by_axes([800])
except Exception as e:
    print("variasi font tak dipakai:", e)

measure = ImageDraw.Draw(Image.new("RGBA", (8, 8)))


def busur(teks: str, pusat: tuple, radius: float) -> list:
    """Kembalikan daftar (ubin, x, y) tiap huruf di sepanjang busur.
    Sudut diukur dari vertikal atas; huruf diputar searah jarum jam
    sejauh sudutnya supaya 'atas' huruf mengarah keluar busur."""
    advances = [measure.textlength(ch, font=font) for ch in teks]
    total = sum(advances)
    span = total / radius
    cx, cy = pusat
    sudut = -span / 2.0
    hasil = []
    for ch, adv in zip(teks, advances):
        tengah = sudut + (adv / 2.0) / radius
        x = cx + radius * math.sin(tengah)
        y = cy - radius * math.cos(tengah)
        bbox = measure.textbbox((0, 0), ch, font=font, stroke_width=STROKE)
        w = bbox[2] - bbox[0] + 20
        h = bbox[3] - bbox[1] + 20
        ubin = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        td = ImageDraw.Draw(ubin)
        td.text((10 - bbox[0], 10 - bbox[1]), ch, font=font,
                fill=EMAS + (255,), stroke_width=STROKE,
                stroke_fill=ZAMRUD_GELAP + (255,))
        putar = ubin.rotate(-math.degrees(tengah), resample=Image.BICUBIC, expand=True)
        hasil.append((putar, int(x), int(y)))
        sudut += adv / radius
    return hasil


def tempel(lapisan: list, dx: int = 0, dy: int = 0) -> None:
    for ubin, x, y in lapisan:
        img.alpha_composite(ubin, (x + dx - ubin.width // 2,
                                   y + dy - ubin.height // 2))


PUSAT = (W / 2, 560)
# Bayangan dulu (zamrud gelap, geser 4 px ke bawah), lalu isi emas.
for teks, radius in [("PESANTREN", 480), ("UNIVERSE", 400)]:
    lapis = busur(teks, PUSAT, radius)
    # Bayangan: gambar ulang tiap ubin dengan isi zamrud — pakai ubin
    # yang sama tapi ditempel dengan offset; karena ubin sudah emas,
    # bayangan dibuat dari ubin kedua (isi zamrud, tanpa outline).
    # Sederhana: tempel ubin emas dengan offset gelap di belakang
    # tidak mungkin tanpa ubin kedua, jadi buat ubin bayangan di sini.
    bayang = []
    for ubin, x, y in lapis:
        # ubin emas -> ubin bayangan: buat dari mask alpha ubin.
        alpha = ubin.split()[3]
        gelap = Image.new("RGBA", ubin.size, ZAMRUD_GELAP + (170,))
        gelap.putalpha(alpha)
        bayang.append((gelap, x, y))
    tempel(bayang, dx=0, dy=5)
    tempel(lapis)

img.convert("RGB").save(KELUAR, "PNG")
print("OK ->", KELUAR)
