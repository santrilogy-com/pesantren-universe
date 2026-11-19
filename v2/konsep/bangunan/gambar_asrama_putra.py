#!/usr/bin/env python3
"""Generator lembar konsep ASRAMA PUTRA — gambar 2D (matplotlib) -> PNG + SVG.
Mengikuti pola lembar Surau (gambar_surau.py) tapi digambar langsung
dengan matplotlib (tidak ada rsvg-convert/cairosvg di VM ini).

Denah MENYALIN layout Asrama Putri yang sudah diperbesar & teruji
(interior_asrama_putri.gd, verdict Mas 08:04 + 08:06 WIB):
  tapak utama 18x12 m + annex tangga timur 3,5x2,6 m (total 21,5x12 m)
  tinggi lantai 3,2 m (3 lantai = 9,6 m) + parapet 0,6 m = 10,2 m
  koridor timur-barat 2,6 m (z -1,3..1,3) — muat 3 orang berdampingan
  4 kamar/lantai (9x4,7 m): barat-laut 001, timur-laut 002,
  barat-daya 003, timur-daya 004; lantai 2 = 005-008, lantai 3 = 009-012
  tiap kamar 4 kasur susun (1,1x2,1 m) di dinding luar,
  lorong kaki kasur 2,275 m, lemari + meja + karpet + lampu + jendela
  tangga switchback di annex timur (2 flight + bordes, rampa 32,6 derajat)
  pintu utama di dinding BARAT (1,6 m), 96 kasur (A-PUTRA-001..096)

Palet: krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A,
batu #B8B2A4, krem muda #FAF4E6.

CATATAN KOORDINAT DENAH: sumbu y denah = sumbu z gedung; utara (-z)
di ATAS — karena itu ylim denah dibalik (8,6, -8,6).
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Circle, Arc
import os

OUT_DIR = "/home/hatch/workspace/pesantren-verse/v2/konsep"
CREAM = "#F2EAD6"; CREAM_D = "#EADFC6"; CREAM_L = "#FAF4E6"
EMERALD = "#065F46"; EMERALD_D = "#04402F"
GOLD = "#C9A227"; TEAK = "#7B4B2A"; TEAK_D = "#4A2E18"
STONE = "#B8B2A4"; STONE_L = "#D8D2C2"; INK = "#3A2E1E"
PAPER = "#FBF8F1"; LINE = "#8A7B5C"; WALL = "#5A4A32"
GLASS = "#BCD8E8"

FIG_W, FIG_H = 10.8, 24.0
fig = plt.figure(figsize=(FIG_W, FIG_H), dpi=100)
fig.patch.set_facecolor(PAPER)


def panel(rect, xlim, ylim):
    ax = fig.add_axes(rect)
    ax.set_xlim(*xlim); ax.set_ylim(*ylim)
    ax.set_aspect("equal"); ax.axis("off")
    ax.set_facecolor(PAPER)
    return ax


def rect(ax, x, y, w, h, fc, ec=None, lw=1.0, z=2, alpha=None):
    ax.add_patch(Rectangle((x, y), w, h, facecolor=fc,
                           edgecolor=ec if ec else "none",
                           linewidth=lw, zorder=z,
                           alpha=alpha if alpha else 1.0))


def txt(ax, x, y, s, size=11, color=INK, bold=False, ha="left", va="bottom",
        z=10, rot=0, bbox=None):
    ax.text(x, y, s, fontsize=size, color=color,
            fontweight="bold" if bold else "normal",
            ha=ha, va=va, zorder=z, rotation=rot,
            family="DejaVu Sans", bbox=bbox)


def dim(ax, x1, y1, x2, y2, label, off=0.45, size=10, color="#5A4A32"):
    """Garis ukuran dua panah + label di tengah (horizontal/vertikal)."""
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle="<->", color=color, lw=1.1),
                zorder=9)
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    if label:
        if abs(x2 - x1) >= abs(y2 - y1):
            txt(ax, mx, my + off, label, size, color, ha="center", va="bottom")
        else:
            txt(ax, mx + off, my, label, size, color, ha="left", va="center")


def window(ax, x, y, w, h, z=5):
    """Jendela: bingkai jati + kaca + jeruji + ambang batu."""
    rect(ax, x, y, w, h, TEAK_D, GOLD, 1.2, z)
    rect(ax, x + 0.08, y + 0.08, w - 0.16, h - 0.16, GLASS, None, 0, z + 1)
    ax.plot([x + w / 2, x + w / 2], [y + 0.08, y + h - 0.08],
            color=TEAK_D, lw=1.2, zorder=z + 2)
    ax.plot([x + 0.08, x + w - 0.08], [y + h / 2, y + h / 2],
            color=TEAK_D, lw=1.2, zorder=z + 2)
    rect(ax, x - 0.08, y - 0.12, w + 0.16, 0.12, STONE, "#9A9384", 0.8, z + 1)


def door_double(ax, x, y, w, h, z=5):
    """Pintu ganda jati + gagang emas."""
    rect(ax, x, y, w, h, TEAK, GOLD, 1.5, z)
    rect(ax, x + 0.1, y + 0.1, w - 0.2, h - 0.2, TEAK_D, GOLD, 1.0, z + 1)
    ax.plot([x + w / 2, x + w / 2], [y + 0.1, y + h - 0.1],
            color=GOLD, lw=1.4, zorder=z + 2)
    ax.add_patch(Circle((x + w / 2 - 0.14, y + h * 0.45), 0.07,
                        facecolor=GOLD, zorder=z + 3))
    ax.add_patch(Circle((x + w / 2 + 0.14, y + h * 0.45), 0.07,
                        facecolor=GOLD, zorder=z + 3))


def section_label(ax, x, y, letter, title):
    txt(ax, x, y, f"{letter}  ·  {title}", 15, EMERALD, bold=True)
    ax.plot([x, x + 3.4], [y - 0.18, y - 0.18], color=GOLD, lw=2.5, zorder=9)


def section_label_inv(ax, x, y, letter, title):
    """Label seksi untuk panel denah (sumbu y terbalik: garis di bawah teks)."""
    txt(ax, x, y, f"{letter}  ·  {title}", 15, EMERALD, bold=True)
    ax.plot([x, x + 3.4], [y + 0.35, y + 0.35], color=GOLD, lw=2.5, zorder=9)


def dinding_koridor(ax):
    """Dinding koridor (z=+-1,3) + dinding annex (dipakai denah C & D)."""
    for zw in (-1.3, 1.3):
        for x0, w in [(-9, 4.05), (-4.05, 8.1), (4.95, 4.05)]:
            rect(ax, x0, zw - 0.075, w, 0.15, WALL, None, 0, 3)
        rect(ax, 9, zw - 0.075, 3.5, 0.15, WALL, None, 0, 3)
    rect(ax, 12.425, -1.3, 0.15, 2.6, WALL, None, 0, 3)  # timur annex


def kamar_isi(ax, cx, zs, nama):
    """Isi satu kamar: 4 kasur susun + lemari + meja + karpet + label."""
    for off in (-3.3, -1.1, 1.1, 3.3):
        rect(ax, cx + off - 0.55, zs * 4.7 - 1.05, 1.1, 2.1,
             "#EFE7D2", TEAK, 1.0, 4)
        rect(ax, cx + off - 0.5, zs * 4.7 - 1.0, 1.0, 0.35,
             "#FFFFFF", None, 0, 5)  # bantal (kepala di dinding luar)
        rect(ax, cx + off - 0.51, zs * 4.7 - 0.45, 1.02, 1.0,
             EMERALD, None, 0, 5, alpha=0.85)  # selimut zamrud
    lx = -0.95 if cx < 0 else 0.95
    rect(ax, lx - 0.8, zs * 1.65 - 0.28, 1.6, 0.55, TEAK, TEAK_D, 1.0, 4)
    mx = -8.3 if cx < 0 else 8.3
    ax.add_patch(Circle((mx, zs * 1.65), 0.32, facecolor=TEAK,
                        edgecolor=TEAK_D, linewidth=1.0, zorder=4))
    rect(ax, cx - 2.5, zs * 2.55 - 0.8, 5.0, 1.6, EMERALD, None, 0, 3, alpha=0.55)
    txt(ax, cx, zs * 2.55, nama, 10.5, "#8A6D1B", bold=True,
        ha="center", va="center",
        bbox=dict(boxstyle="square,pad=0.15", facecolor="white",
                  alpha=0.9, edgecolor="none"))
    ax.add_patch(Arc((cx - 0.45, zs * 1.3), 0.9, 0.9,
                     theta1=0, theta2=90 if zs < 0 else 270,
                     color=LINE, lw=1.0, zorder=4))


# ============================================================ HEADER
hdr = fig.add_axes([0, 0.945, 1, 0.055]); hdr.axis("off")
hdr.set_xlim(0, 10.8); hdr.set_ylim(0, 1)
hdr.add_patch(Rectangle((0, 0), 10.8, 1, facecolor=EMERALD, zorder=1))
hdr.add_patch(Rectangle((0, 0), 10.8, 0.06, facecolor=GOLD, zorder=2))
hdr.text(0.5, 0.62, "ASRAMA PUTRA", fontsize=26, color=CREAM,
         fontweight="bold", ha="left", va="center", family="DejaVu Sans")
hdr.text(0.5, 0.28, "Lembar Konsep  ·  3 Lantai  ·  96 Santri  ·  Tapak 21,5 × 12 m",
         fontsize=11, color=GOLD, ha="left", va="center", family="DejaVu Sans")
hdr.text(10.3, 0.62, "PESANTREN UNIVERSE", fontsize=10, color=CREAM,
         ha="right", va="center", family="DejaVu Sans")
hdr.text(10.3, 0.28, "KONSEP 2D — BELUM DIBANGUN 3D", fontsize=9, color=GOLD,
         ha="right", va="center", family="DejaVu Sans")

# ============================================================ A — TAMPAK DEPAN (BARAT)
axA = panel([0.05, 0.775, 0.90, 0.155], (-0.6, 13.2), (-0.9, 12.2))
section_label(axA, -0.4, 11.55, "A", "TAMPAK DEPAN — dari barat (pintu utama)")
axA.plot([-0.5, 12.7], [0, 0], color=LINE, lw=2, zorder=3)
rect(axA, -0.5, -0.55, 13.2, 0.55, STONE_L, None, 0, 1)
rect(axA, 0, 0, 12, 9.6, CREAM, "#D8CDB2", 1, 2)
rect(axA, 0, 0, 12, 0.6, STONE, "#9A9384", 1, 3)
for fy in (3.2, 6.4):
    rect(axA, -0.15, fy, 12.3, 0.14, GOLD, None, 0, 4)
rect(axA, -0.15, 9.6, 12.3, 0.6, EMERALD, None, 0, 4)
rect(axA, -0.15, 9.6, 12.3, 0.1, GOLD, None, 0, 5)
door_double(axA, 5.2, 0.6, 1.6, 2.6)
rect(axA, 4.7, 3.35, 2.6, 0.22, EMERALD, GOLD, 1.2, 5)   # kanopi
rect(axA, 4.7, 3.57, 2.6, 0.08, GOLD, None, 0, 5)
rect(axA, 3.8, 3.85, 4.4, 0.62, EMERALD, GOLD, 1.5, 5)  # plakat
txt(axA, 6.0, 4.02, "ASRAMA PUTRA", 11, GOLD, bold=True, ha="center", va="center")
# jendela kamar (pusat kamar z=+-3,65 -> x 2,35 / 9,65); lantai 2-3
# tanpa jendela tengah koridor supaya plakat tidak tertutup
for fy in (0, 3.2, 6.4):
    window(axA, 1.75, fy + 0.9, 1.2, 1.5)
    window(axA, 9.05, fy + 0.9, 1.2, 1.5)
rect(axA, 4.9, 0.28, 2.2, 0.14, STONE, "#9A9384", 0.8, 4)
rect(axA, 4.7, 0.14, 2.6, 0.14, STONE, "#9A9384", 0.8, 4)
rect(axA, 4.5, 0.0, 3.0, 0.14, STONE, "#9A9384", 0.8, 4)
for px in (3.6, 8.4):
    rect(axA, px - 0.28, 0.0, 0.56, 0.5, TEAK, None, 0, 4)
    axA.add_patch(Circle((px, 0.85), 0.42, facecolor="#5F7055", zorder=4))
    axA.add_patch(Circle((px - 0.25, 0.7), 0.25, facecolor="#6E8263", zorder=4))
    axA.add_patch(Circle((px + 0.25, 0.7), 0.25, facecolor="#6E8263", zorder=4))
dim(axA, 0, -0.85, 12, -0.85, "Lebar 12 m", off=0.12)
dim(axA, 12.55, 0, 12.55, 9.6, "9,6 m (3 × 3,2 m)", off=0.12)
txt(axA, 6.0, 10.75, "Atap datar + parapet zamrud 0,6 m  ·  lis emas antar lantai",
    10, "#5A4A32", ha="center")

# ============================================================ B — TAMPAK SAMPING (UTARA)
axB = panel([0.05, 0.60, 0.90, 0.155], (-0.8, 23.3), (-0.9, 12.2))
section_label(axB, -0.6, 11.55, "B", "TAMPAK SAMPING — dari utara (panjang 21,5 m)")
axB.plot([-0.7, 22.6], [0, 0], color=LINE, lw=2, zorder=3)
rect(axB, -0.7, -0.55, 23.3, 0.55, STONE_L, None, 0, 1)
rect(axB, 0, 0, 18, 9.6, CREAM, "#D8CDB2", 1, 2)
rect(axB, 18, 0, 3.5, 9.6, CREAM_D, "#D8CDB2", 1, 2)
rect(axB, 0, 0, 21.5, 0.6, STONE, "#9A9384", 1, 3)
for fy in (3.2, 6.4):
    rect(axB, -0.15, fy, 21.8, 0.14, GOLD, None, 0, 4)
rect(axB, -0.15, 9.6, 21.8, 0.6, EMERALD, None, 0, 4)
rect(axB, -0.15, 9.6, 21.8, 0.1, GOLD, None, 0, 5)
# jendela kamar utara: 1 per kamar (pusat kamar x=+-4,5 -> sisi 4,5 / 13,5)
for fy in (0, 3.2, 6.4):
    for wx in (3.9, 12.9):
        window(axB, wx, fy + 0.9, 1.2, 1.5)
    window(axB, 19.3, fy + 1.4, 0.9, 1.1)  # jendela kecil annex
txt(axB, 10.75, 10.75, "Badan utama 18 m  ·  2 kamar utara per lantai (jendela 1 per kamar)",
    10, "#5A4A32", ha="center")
dim(axB, 0, -0.85, 21.5, -0.85, "Panjang total 21,5 m (18 + annex 3,5)", off=0.12)
dim(axB, 22.05, 0, 22.05, 9.6, "9,6 m", off=0.12)

# ============================================================ C — DENAH LANTAI 1
axC = panel([0.03, 0.295, 0.94, 0.285], (-12.5, 24.0), (8.6, -8.6))
section_label_inv(axC, -12.3, -7.9, "C", "DENAH LANTAI 1 — utara di atas")
rect(axC, -9, -6, 18, 12, CREAM_L, WALL, 2.2, 1)
rect(axC, 9, -1.3, 3.5, 2.6, CREAM_L, WALL, 2.2, 1)
rect(axC, -9, -1.3, 18, 2.6, "#DCE8D8", None, 0, 2)
rect(axC, 9, -1.3, 3.5, 2.6, "#DCE8D8", None, 0, 2)
txt(axC, -4.0, 0.35, "KORIDOR  2,6 m", 12, EMERALD_D, bold=True, ha="center", va="center")
txt(axC, -3.0, -0.55, "muat 3 orang berdampingan", 9.5, EMERALD_D, ha="center", va="center")
dinding_koridor(axC)
rect(axC, -0.075, -6, 0.15, 4.7, WALL, None, 0, 3)
rect(axC, -0.075, 1.3, 0.15, 4.7, WALL, None, 0, 3)
rect(axC, -9.075, -6, 0.15, 5.2, WALL, None, 0, 3)
rect(axC, -9.075, 0.8, 0.15, 5.2, WALL, None, 0, 3)
rect(axC, 9, -6, 0.15, 4.7, WALL, None, 0, 3)
rect(axC, 9, 1.3, 0.15, 4.7, WALL, None, 0, 3)
for wx in (-4.5, 4.5):
    for wz in (-6, 6):
        rect(axC, wx - 0.6, wz - 0.075, 1.2, 0.15, GLASS, TEAK, 1.2, 4)
for cx, zs, nama in [(-4.5, -1, "Kamar 001"), (4.5, -1, "Kamar 002"),
                     (-4.5, 1, "Kamar 003"), (4.5, 1, "Kamar 004")]:
    kamar_isi(axC, cx, zs, nama)
rect(axC, -7.6, -1.225, 1.2, 0.35, TEAK, TEAK_D, 1.0, 4)
txt(axC, -7.0, -0.35, "Rak buku", 8.5, INK, ha="center")
rect(axC, 9.0, -1.0, 2.5, 1.0, TEAK, TEAK_D, 1.2, 4)
rect(axC, 11.5, -1.0, 1.0, 2.0, "#EFE7D2", TEAK, 1.2, 4)
rect(axC, 9.0, 0.0, 2.5, 1.0, TEAK, TEAK_D, 1.2, 4)
txt(axC, 10.25, -0.5, "NAIK →", 8.5, CREAM, bold=True, ha="center", va="center")
txt(axC, 10.25, 0.5, "← NAIK", 8.5, CREAM, bold=True, ha="center", va="center")
txt(axC, 12.0, 0.0, "BORDES", 8, INK, ha="center", va="center", rot=90)
txt(axC, 10.75, -1.85, "TANGGA", 10, EMERALD_D, bold=True, ha="center")
txt(axC, 11.0, -2.45, "switchback 2 flight", 8, "#5A4A32", ha="center")
rect(axC, -10.6, -0.8, 1.6, 1.6, STONE_L, WALL, 1.2, 3)
txt(axC, -11.4, 0, "PINTU\nUTAMA", 9, INK, bold=True, ha="center", va="center")
# ukuran dalam denah: lorong kaki kasur + dalam kamar
WB = dict(boxstyle="square,pad=0.12", facecolor="white", alpha=0.9, edgecolor="none")
dim(axC, 7.6, -3.65, 7.6, -1.3, "", off=0.12)
txt(axC, 7.6, -2.475, "2,275 m", 8.5, INK, ha="center", va="center", rot=90, bbox=WB)
dim(axC, -8.7, -6, -8.7, -1.3, "", off=0.12)
txt(axC, -8.7, -3.65, "4,7 m", 8.5, INK, ha="center", va="center", rot=90, bbox=WB)
# panah utara + mistar + ukuran luar
axC.annotate("", xy=(14, -7.6), xytext=(14, -6.4),
             arrowprops=dict(arrowstyle="->", color=INK, lw=1.6), zorder=9)
txt(axC, 14, -7.85, "U", 11, INK, bold=True, ha="center")
rect(axC, 18.5, 7.9, 4, 0.35, INK, None, 0, 5)
rect(axC, 18.5, 7.9, 2, 0.35, PAPER, INK, 1.0, 6)
txt(axC, 18.5, 7.35, "0", 9, INK, ha="center")
txt(axC, 20.5, 7.35, "2 m", 9, INK, ha="center")
txt(axC, 22.5, 7.35, "4 m", 9, INK, ha="center")
dim(axC, -9, 7.6, 12.5, 7.6, "21,5 m (18 + annex 3,5)", off=0.15)
dim(axC, 13.3, -6, 13.3, 6, "12 m", off=0.15)
dim(axC, -9, -7.0, 0, -7.0, "Kamar 9 m", off=0.15)

# ============================================================ D — DENAH LANTAI 2 & 3 + PALET + UKURAN
axD = panel([0.03, 0.055, 0.56, 0.215], (-12.5, 24.0), (8.6, -8.6))
section_label_inv(axD, -12.3, -7.9, "D", "DENAH LANTAI 2 & 3 — sama dengan lantai 1")
rect(axD, -9, -6, 18, 12, CREAM_L, WALL, 2.2, 1)
rect(axD, 9, -1.3, 3.5, 2.6, CREAM_L, WALL, 2.2, 1)
rect(axD, -9, -1.3, 18, 2.6, "#DCE8D8", None, 0, 2)
rect(axD, 9, -1.3, 3.5, 2.6, "#DCE8D8", None, 0, 2)
txt(axD, 0, 0, "KORIDOR 2,6 m", 11, EMERALD_D, bold=True, ha="center", va="center")
dinding_koridor(axD)
rect(axD, -0.075, -6, 0.15, 4.7, WALL, None, 0, 3)
rect(axD, -0.075, 1.3, 0.15, 4.7, WALL, None, 0, 3)
rect(axD, -9.075, -6, 0.15, 12, WALL, None, 0, 3)  # barat UTUH (tanpa pintu)
rect(axD, 9, -6, 0.15, 4.7, WALL, None, 0, 3)
rect(axD, 9, 1.3, 0.15, 4.7, WALL, None, 0, 3)
for wx in (-4.5, 4.5):
    for wz in (-6, 6):
        rect(axD, wx - 0.6, wz - 0.075, 1.2, 0.15, GLASS, TEAK, 1.2, 4)
for cx, zs, nama in [(-4.5, -1, "005 / 009"), (4.5, -1, "006 / 010"),
                     (-4.5, 1, "007 / 011"), (4.5, 1, "008 / 012")]:
    kamar_isi(axD, cx, zs, nama)
rect(axD, 9.0, -1.0, 2.5, 1.0, TEAK, TEAK_D, 1.2, 4)
rect(axD, 11.5, -1.0, 1.0, 2.0, "#EFE7D2", TEAK, 1.2, 4)
rect(axD, 9.0, 0.0, 2.5, 1.0, TEAK, TEAK_D, 1.2, 4)
txt(axD, 10.75, -1.85, "TANGGA", 10, EMERALD_D, bold=True, ha="center")
txt(axD, -8.4, -6.9, "Lantai 2 = Kamar 005–008  ·  Lantai 3 = Kamar 009–012",
    10.5, EMERALD_D, bold=True)
txt(axD, -8.4, 7.35, "Dinding barat lantai 2–3 utuh (pintu utama hanya di lantai 1)",
    9.5, "#5A4A32")

# --- palet + ukuran kunci (kanan) ---
axP = fig.add_axes([0.62, 0.055, 0.35, 0.215]); axP.axis("off")
axP.set_xlim(0, 10); axP.set_ylim(0, 10)
axP.text(0, 9.6, "PALET WARNA", fontsize=13, color=EMERALD,
         fontweight="bold", family="DejaVu Sans")
PAL = [(CREAM, "Krem", "#F2EAD6", "dinding"),
       (EMERALD, "Zamrud", "#065F46", "parapet, selimut, karpet"),
       (GOLD, "Emas", "#C9A227", "lis, plakat & gagang"),
       (TEAK, "Jati", "#7B4B2A", "pintu, jendela, kasur"),
       (STONE, "Batu", "#B8B2A4", "alas & anak tangga"),
       (CREAM_L, "Krem muda", "#FAF4E6", "lantai interior")]
for i, (c, name, hx, use) in enumerate(PAL):
    y = 8.85 - i * 0.78
    axP.add_patch(Rectangle((0, y - 0.32), 1.1, 0.55, facecolor=c,
                            edgecolor="#00000033", linewidth=0.8))
    axP.text(1.35, y, f"{name}  {hx}  —  {use}", fontsize=10.5, color=INK,
             va="center", family="DejaVu Sans")
axP.text(0, 3.55, "UKURAN KUNCI", fontsize=13, color=EMERALD,
         fontweight="bold", family="DejaVu Sans")
KEYS = ["Tapak 18 × 12 m + annex 3,5 × 2,6 m (total 21,5 × 12 m)",
        "Tinggi lantai 3,2 m · total 9,6 m + parapet 0,6 m",
        "Koridor 2,6 m · kamar 9 × 4,7 m · lorong 2,275 m",
        "96 kasur (A-PUTRA-001..096): 12 kamar × 4 susun × 2",
        "Tangga switchback, rampa 32,6° — tanpa lift",
        "Kapasitas ±96 santri · asrama ke-2 cadangan di barat"]
for i, k in enumerate(KEYS):
    axP.text(0, 2.95 - i * 0.48, "•  " + k, fontsize=9.5, color=INK,
             va="center", family="DejaVu Sans")

# ============================================================ FOOTER
fig.text(0.05, 0.028,
         "Lembar ini hanya gambar konsep 2D — belum dibangun 3D, tunggu penilaian Mas.",
         fontsize=11, color="#5A4A32", family="DejaVu Sans")
fig.text(0.95, 0.028, "v2 · konsep 01 · 18 Nov 2026", fontsize=10,
         color=LINE, ha="right", family="DejaVu Sans")

png = os.path.join(OUT_DIR, "asrama-putra-konsep.png")
svg = os.path.join(OUT_DIR, "asrama-putra-konsep.svg")
fig.savefig(png, dpi=100, facecolor=PAPER)
fig.savefig(svg, facecolor=PAPER)
print("PNG ditulis:", png, os.path.getsize(png), "byte")
print("SVG ditulis:", svg, os.path.getsize(svg), "byte")
