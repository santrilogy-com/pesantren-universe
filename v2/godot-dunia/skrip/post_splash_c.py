#!/usr/bin/env python3
"""Post-process varian C splash: tambah judul besar "PESANTREN UNIVERSE"
di area bawah (rumput/jalan kosong) dengan Baloo 2 ExtraBold — font
nuansa game yang sama dengan UI game. Emas #f2c14e + outline zamrud
gelap #043B2C, dua baris, rata tengah. Scrim gradien zamrud gelap
di bawah supaya judul terbaca di atas rumput terang/jalan putih.

Masuk : v2/konsep/konsep-splash-c-karakter-mentah.png (1280x720)
Keluar: v2/konsep/konsep-splash-c-karakter.png
"""
from PIL import Image, ImageDraw, ImageFont

MASUK = "/home/hatch/workspace/pesantren-verse/v2/konsep/konsep-splash-c-karakter-mentah.png"
KELUAR = "/home/hatch/workspace/pesantren-verse/v2/konsep/konsep-splash-c-karakter.png"
FONT = "/home/hatch/workspace/pesantren-verse/v2/godot-dunia/fonts/Baloo2-Variable.ttf"

EMAS = (242, 193, 78)      # #f2c14e — sama dengan plakat 3D
ZAMRUD_GELAP = (4, 59, 44)  # #043B2C — outline + scrim

img = Image.open(MASUK).convert("RGBA")
W, H = img.size
assert (W, H) == (1280, 720), (W, H)

# --- Scrim gradien bawah: transparan di y=430 -> zamrud gelap di y=720.
scrim = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = scrim.load()
Y0, Y1, A_MAX = 430, H, 150
for y in range(Y0, Y1):
    t = (y - Y0) / (Y1 - Y0)
    a = int(A_MAX * t * t)  # ease-in: makin bawah makin pekat
    for x in range(W):
        px[x, y] = (ZAMRUD_GELAP[0], ZAMRUD_GELAP[1], ZAMRUD_GELAP[2], a)
img = Image.alpha_composite(img, scrim)

d = ImageDraw.Draw(img)

# --- Judul dua baris, Baloo 2 ExtraBold (wght 800).
SIZE = 88
font = ImageFont.truetype(FONT, SIZE)
try:
    font.set_variation_by_axes([800])
except Exception as e:  # fallback: bobot default bila sumbu tak didukung
    print("variasi font tak dipakai:", e)

BARIS = [("PESANTREN", 522), ("UNIVERSE", 612)]
for teks, y in BARIS:
    # Bayangan lembut (offset, zamrud gelap) + isi emas + outline zamrud.
    d.text((W / 2 + 4, y + 5), teks, font=font, anchor="ma",
           fill=ZAMRUD_GELAP + (170,))
    d.text((W / 2, y), teks, font=font, anchor="ma",
           fill=EMAS + (255,), stroke_width=7,
           stroke_fill=ZAMRUD_GELAP + (255,))

img.convert("RGB").save(KELUAR, "PNG")
print("OK ->", KELUAR)
