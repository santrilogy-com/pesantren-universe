#!/usr/bin/env python3
"""Generator lembar konsep SURAU v2 — vektor datar (SVG) -> PNG.
Skala: tampak depan 40 px/m, tampak samping 30 px/m, tiga-perempat isometri 13 px/m.
Palet: krem #F2EAD6, zamrud #065F46, emas #C9A227, jati #7B4B2A,
batu #B8B2A4, krem muda #FAF4E6.
"""
import math

W, H = 1080, 2600
CREAM = "#F2EAD6"; CREAM_D = "#EADFC6"; CREAM_L = "#FAF4E6"
EMERALD = "#065F46"; EMERALD_D = "#04402F"
GOLD = "#C9A227"; TEAK = "#7B4B2A"; TEAK_D = "#4A2E18"
STONE = "#B8B2A4"; STONE_L = "#D8D2C2"; INK = "#3A2E1E"
PAPER = "#FBF8F1"; LINE = "#8A7B5C"

S = []  # potongan SVG

def add(s):
    S.append(s)

def rect(x, y, w, h, fill, stroke=None, sw=0, rx=0, op=None):
    a = f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" fill="{fill}"'
    if rx: a += f' rx="{rx}"'
    if stroke: a += f' stroke="{stroke}" stroke-width="{sw}"'
    if op: a += f' opacity="{op}"'
    return a + '/>'

def line(x1, y1, x2, y2, stroke, sw=2, op=None):
    a = f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{stroke}" stroke-width="{sw}"'
    if op: a += f' opacity="{op}"'
    return a + '/>'

def text(x, y, s, size, fill=INK, bold=False, anchor="start", fam="Noto Sans, DejaVu Sans, sans-serif", ls=None):
    import re as _re
    s = _re.sub(r'&(?!amp;)', '&amp;', str(s))  # amankan & mentah untuk XML
    w = ' font-weight="bold"' if bold else ''
    a = f' text-anchor="{anchor}"' if anchor != "start" else ''
    l = f' letter-spacing="{ls}"' if ls else ''
    return (f'<text x="{x:.1f}" y="{y:.1f}" font-family="{fam}" font-size="{size}"'
            f' fill="{fill}"{w}{a}{l}>{s}</text>')

def path(d, fill, stroke=None, sw=0, op=None):
    a = f'<path d="{d}" fill="{fill}"'
    if stroke: a += f' stroke="{stroke}" stroke-width="{sw}"'
    if op: a += f' opacity="{op}"'
    return a + '/>'

def onion(cx, base_y, w, h):
    """Kubah bawang: alas di base_y, puncak di base_y-h."""
    x0, x1 = cx - w / 2, cx + w / 2
    return (f"M {x0:.1f} {base_y:.1f} "
            f"C {x0-w*0.12:.1f} {base_y-h*0.28:.1f}, {cx-w*0.44:.1f} {base_y-h*0.58:.1f}, {cx:.1f} {base_y-h:.1f} "
            f"C {cx+w*0.44:.1f} {base_y-h*0.58:.1f}, {x1+w*0.12:.1f} {base_y-h*0.28:.1f}, {x1:.1f} {base_y:.1f} Z")

def onion_ribs(cx, base_y, w, h, color, n=2):
    """Garis rusuk kubah (2 garis melengkung)."""
    out = []
    for f in (-0.45, 0.45):
        x0 = cx + f * w
        out.append(f'<path d="M {x0:.1f} {base_y:.1f} Q {cx+f*w*0.72:.1f} {base_y-h*0.45:.1f} {cx:.1f} {base_y-h:.1f}" fill="none" stroke="{color}" stroke-width="2.5" opacity="0.55"/>')
    return "".join(out)

def crescent(cx, cy, r, fill=GOLD):
    """Bulan sabit (path dua busur, tanpa cakram penutup — bersih di semua ukuran)."""
    R = r * 1.118
    return (f'<path d="M {cx:.1f} {cy-r:.1f} A {r:.1f} {r:.1f} 0 1 0 {cx:.1f} {cy+r:.1f} '
            f'A {R:.1f} {R:.1f} 0 0 1 {cx:.1f} {cy-r:.1f} Z" fill="{fill}"/>')

def finial(cx, top_y, rod_h, cres_r, ball_r=6):
    """Tiang + bola + sabit di atas kubah. top_y = ujung atas kubah."""
    return (line(cx, top_y - rod_h, cx, top_y, GOLD, 3) +
            f'<circle cx="{cx:.1f}" cy="{top_y-rod_h*0.45:.1f}" r="{ball_r}" fill="{GOLD}"/>' +
            crescent(cx, top_y - rod_h - cres_r - 2, cres_r))

def arch_path(x, y_base, w, spring_y, apex_y):
    """Lengkung lancip: sisi tegak sampai spring_y, puncak di apex_y."""
    cx = x + w / 2
    cy = apex_y + (spring_y - apex_y) * 0.30
    return (f"M {x:.1f} {y_base:.1f} L {x:.1f} {spring_y:.1f} "
            f"Q {x+w*0.08:.1f} {cy:.1f} {cx:.1f} {apex_y:.1f} "
            f"Q {x+w*0.92:.1f} {cy:.1f} {x+w:.1f} {spring_y:.1f} "
            f"L {x+w:.1f} {y_base:.1f} Z")

def lattice(x, y, w, h, clip_id, color=GOLD, step=28):
    """Kisi diagonal di dalam klip arch. Mengembalikan grup garis."""
    d = [f'<clipPath id="{clip_id}"><path d="{arch_path(x, y+h, w, y+h*0.45, y)}"/></clipPath>']
    g = [f'<g clip-path="url(#{clip_id})" stroke="{color}" stroke-width="1.8" opacity="0.6">']
    for i in range(-h, w + h, step):
        g.append(f'<line x1="{x+i}" y1="{y+h}" x2="{x+i+h}" y2="{y}"/>')
        g.append(f'<line x1="{x+i}" y1="{y}" x2="{x+i+h}" y2="{y+h}"/>')
    g.append('</g>')
    return "".join(d + g)

def window_arch(x, y_base, w, h, tag):
    """Jendela lengkung: bingkai emas, isi jati gelap + kisi emas."""
    spring_y = y_base - h * 0.55
    apex_y = y_base - h
    d = arch_path(x, y_base, w, spring_y, apex_y)
    out = [path(d, TEAK_D, GOLD, 3)]
    out.append(lattice(x + 5, apex_y + 4, w - 10, y_base - apex_y - 4, f"cl{tag}"))
    # tiang tengah + ambang
    out.append(line(x + w / 2, apex_y + 8, x + w / 2, y_base, GOLD, 2))
    out.append(line(x, y_base - h * 0.35, x + w, y_base - h * 0.35, GOLD, 2))
    out.append(rect(x - 6, y_base, w + 12, 8, STONE))
    return "".join(out)

def minaret(cx, ground_y, s, with_base=True):
    """Menara: badan krem, balkon ~9 m, tutup kubah zamrud + sabit."""
    w = 1.7 * s
    top = ground_y - 14 * s
    balc_y = ground_y - 9 * s
    cap_base = ground_y - 12.4 * s
    out = []
    if with_base:
        out.append(rect(cx - w * 0.75, ground_y - 1.2 * s, w * 1.5, 1.2 * s, STONE))
    out.append(rect(cx - w / 2, cap_base, w, ground_y - 1.2 * s - cap_base, CREAM, "#D8CDB2", 1))
    # balkon
    out.append(rect(cx - w * 0.72, balc_y - 0.35 * s, w * 1.44, 0.35 * s, CREAM, GOLD, 2))
    for i in range(5):
        bx = cx - w * 0.6 + i * w * 0.3
        out.append(line(bx, balc_y - 0.85 * s, bx, balc_y - 0.35 * s, GOLD, 2))
    out.append(line(cx - w * 0.72, balc_y - 0.85 * s, cx + w * 0.72, balc_y - 0.85 * s, GOLD, 2))
    # badan atas (lebih ramping)
    out.append(rect(cx - w * 0.38, top + 1.6 * s, w * 0.76, cap_base - (top + 1.6 * s), CREAM, "#D8CDB2", 1))
    # tutup kubah zamrud
    out.append(path(onion(cx, cap_base, w * 0.95, 1.6 * s), EMERALD))
    out.append(finial(cx, cap_base - 1.6 * s, 0.9 * s, 0.42 * s, 4))
    return "".join(out)

# ============================================================ HEADER
add(rect(0, 0, W, 140, EMERALD))
add(rect(0, 140, W, 6, GOLD))
add(text(56, 82, "SURAU v2", 64, CREAM, bold=True))
add(text(56, 122, "Lembar Konsep  ·  Wajah Pesantren", 26, GOLD))
add(text(1024, 66, "PESANTREN UNIVERSE", 22, CREAM, anchor="end"))
add(text(1024, 104, "KONSEP 2D — BELUM DIBANGUN 3D", 20, GOLD, anchor="end"))

def section_label(x, y, letter, title, anchor="start"):
    add(text(x, y, f"{letter}  ·  {title}", 28, EMERALD, bold=True, anchor=anchor))
    ax = x if anchor == "start" else x - 340
    add(rect(ax, y + 12, 340, 4, GOLD))

# ============================================================ A — TAMPAK DEPAN
section_label(56, 192, "A", "TAMPAK DEPAN — dari timur / jalan")
# skala 40 px/m, tanah y=800, pusat bangunan x=520
G = 800; S40 = 40; CX = 520
BX0, BX1 = 120, 920          # dinding 20 m
WALL_TOP = G - 5 * S40       # 600
# --- kubah utama (di belakang dinding) ---
add(rect(CX - 170, WALL_TOP - 16, 340, 16, CREAM_D))  # drum
add(path(onion(CX, WALL_TOP, 360, 240), EMERALD))
add(onion_ribs(CX, WALL_TOP, 360, 240, EMERALD_D))
add(finial(CX, WALL_TOP - 240, 40, 26))
# --- menara (sudut tenggara, kanan) ---
add(minaret(965, G, S40))
# --- kubah kecil sudut depan ---
for kcx in (160, 880):
    add(path(onion(kcx, WALL_TOP, 72, 112), EMERALD))
    add(finial(kcx, WALL_TOP - 112, 22, 10, 3))
# --- dinding + lis + alas ---
add(rect(BX0, WALL_TOP, BX1 - BX0, G - WALL_TOP, CREAM, "#D8CDB2", 1))
add(rect(BX0 - 8, WALL_TOP - 10, BX1 - BX0 + 16, 10, GOLD))
add(rect(BX0, G - 20, BX1 - BX0, 20, STONE))
# --- portal (blok tengah 8 m, tinggi 8 m) ---
PX0, PX1 = 360, 680
PTOP = G - 8 * S40           # 480
add(rect(PX0, PTOP, PX1 - PX0, G - PTOP, CREAM, "#D8CDB2", 1))
add(rect(PX0 - 8, PTOP - 10, PX1 - PX0 + 16, 10, GOLD))
# --- plakat di atas lengkung ---
add(rect(420, 488, 200, 28, EMERALD, GOLD, 3, rx=4))
add(text(520, 509, "مصلى الإخلاص", 24, GOLD, anchor="middle", fam="'Noto Sans Arabic', 'Noto Sans', sans-serif"))
# --- lengkung portal + kisi + pintu ---
AX0, AX1 = 424, 616
add(path(arch_path(AX0, 780, AX1 - AX0, 620, 524), TEAK_D, GOLD, 3))
add(lattice(AX0 + 6, 524, AX1 - AX0 - 12, 780 - 524, "clportal"))
add(line(AX0, 676, AX1, 676, GOLD, 3))
add(rect(440, 676, 160, 104, TEAK))
add(rect(448, 684, 144, 88, "none", GOLD, 2))
add(line(520, 684, 520, 772, GOLD, 2))
add(f'<circle cx="500" cy="730" r="6" fill="{GOLD}"/><circle cx="540" cy="730" r="6" fill="{GOLD}"/>')
# --- jendela depan 2+2 ---
for i, wx in enumerate((178, 278, 690, 790)):
    add(window_arch(wx, 776, 72, 156, f"f{i}"))
# --- serambi: pelat + 2 tiang + 3 lengkung ---
add(rect(330, 664, 380, 16, CREAM, GOLD, 2))
add(rect(330, 678, 380, 4, GOLD))
for ccx in (452, 572):
    add(rect(ccx, 680, 16, 100, CREAM, "#D8CDB2", 1))
    add(rect(ccx - 3, 680, 22, 6, GOLD))
for a0, a1 in ((340, 452), (468, 572), (588, 700)):
    add(f'<path d="{arch_path(a0, 780, a1 - a0, 730, 692)}" fill="none" stroke="{LINE}" stroke-width="2.5"/>')
# --- 3 anak tangga batu ---
add(rect(402, 780, 236, 10, STONE, "#9A9384", 1))
add(rect(386, 790, 268, 10, STONE, "#9A9384", 1))
add(rect(370, 800, 300, 12, STONE, "#9A9384", 1))
# --- tanah + tanaman pot ---
add(rect(56, 812, 968, 4, LINE))
add(rect(300, 816, 440, 14, STONE_L))
for px in (330, 706):
    add(rect(px - 14, 786, 28, 26, TEAK))
    add(f'<circle cx="{px}" cy="776" r="20" fill="#5F7055"/><circle cx="{px-12}" cy="784" r="12" fill="#6E8263"/><circle cx="{px+12}" cy="784" r="12" fill="#6E8263"/>')
# --- label ukuran depan ---
add(text(56, 862, "Lebar 20 m  ·  dinding 5 m  ·  puncak kubah ±11 m  ·  menara ±14 m  ·  serambi 3 m", 20, "#5A4A32"))
add(text(1024, 862, "Skala tampak: 40 px = 1 m", 18, LINE, anchor="end"))

# ============================================================ B — TAMPAK SAMPING
section_label(56, 895, "B", "TAMPAK SAMPING — dari selatan")
# skala 30 px/m, tanah y=1400, pusat x=540
G2 = 1400; S30 = 30
add(minaret(210, G2, S30))
# kubah utama
add(rect(540 - 135, G2 - 5 * S30 - 16, 270, 16, CREAM_D))
add(path(onion(540, G2 - 5 * S30, 270, 180), EMERALD))
add(onion_ribs(540, G2 - 5 * S30, 270, 180, EMERALD_D))
add(finial(540, G2 - 5 * S30 - 180, 30, 20))
# kubah kecil sudut
for kcx in (240, 840):
    add(path(onion(kcx, G2 - 5 * S30, 54, 84), EMERALD))
    add(finial(kcx, G2 - 5 * S30 - 84, 16, 8, 3))
# dinding + lis + alas
add(rect(240, G2 - 5 * S30, 600, 5 * S30, CREAM, "#D8CDB2", 1))
add(rect(232, G2 - 5 * S30 - 10, 616, 10, GOLD))
add(rect(240, G2 - 20, 600, 20, STONE))
# 3 jendela lengkung selatan
for i, wx in enumerate((333, 513, 693)):
    add(window_arch(wx, 1388, 54, 108, f"s{i}"))
# tepi serambi (ujung timur, kiri)
add(rect(190, 1301, 50, 14, CREAM, GOLD, 2))
add(rect(196, 1315, 12, 85, CREAM, "#D8CDB2", 1))
# tempat wudu (sisi selatan, ujung barat)
add(rect(764, 1338, 82, 17, TEAK))
add(rect(770, 1355, 70, 45, STONE, "#9A9384", 1))
for tx in (790, 805, 820):
    add(f'<circle cx="{tx}" cy="1362" r="3.5" fill="{GOLD}"/>')
add(text(820, 1324, "Tempat wudu", 18, INK, anchor="middle"))
# tanah
add(line(56, G2, 1024, G2, LINE, 3))
add(rect(180, G2, 680, 12, STONE_L))
add(text(56, 1442, "Panjang 20 m  ·  3 jendela lengkung  ·  tempat wudu di sisi selatan", 20, "#5A4A32"))

# ============================================================ C — TIGA-PEREMPAT (isometri)
section_label(56, 1480, "C", "TIGA-PEREMPAT")
OX, OY, SI = 560, 1740, 16
COS30 = math.cos(math.radians(30)); SIN30 = 0.5

def iso(x, y, z):
    return (OX + (x - y) * COS30 * SI, OY + (x + y) * SIN30 * SI - z * SI)

def poly3(pts, fill, stroke=None, sw=1):
    p = " ".join(f"{iso(*q)[0]:.1f},{iso(*q)[1]:.1f}" for q in pts)
    a = f'<polygon points="{p}" fill="{fill}"'
    if stroke: a += f' stroke="{stroke}" stroke-width="{sw}"'
    return a + '/>'

def arch_iso(plane, fixed, c, w, z_base, z_spring, z_apex, fill, stroke=None, sw=1.5):
    """Lengkung lancip pada bidang tegak: plane 'south' (y=fixed) atau 'east' (x=fixed)."""
    def P(u, z):
        return iso(u, fixed, z) if plane == 'south' else iso(fixed, u, z)
    x0, x1 = c - w / 2, c + w / 2
    cx = c
    cy = z_apex + (z_spring - z_apex) * 0.30
    p0, p1 = P(x0, z_base), P(x0, z_spring)
    c1 = P(x0 + w * 0.08, cy); ap = P(cx, z_apex); c2 = P(x1 - w * 0.08, cy)
    p2, p3 = P(x1, z_spring), P(x1, z_base)
    d = (f"M {p0[0]:.1f} {p0[1]:.1f} L {p1[0]:.1f} {p1[1]:.1f} "
         f"Q {c1[0]:.1f} {c1[1]:.1f} {ap[0]:.1f} {ap[1]:.1f} "
         f"Q {c2[0]:.1f} {c2[1]:.1f} {p2[0]:.1f} {p2[1]:.1f} "
         f"L {p3[0]:.1f} {p3[1]:.1f} Z")
    return path(d, fill, stroke, sw)

# bayangan tanah
gc = iso(10, 8, 0)
add(f'<ellipse cx="{gc[0]:.1f}" cy="{gc[1]+4:.1f}" rx="300" ry="72" fill="#E9E2D0"/>')
# muka selatan (y=0) + muka timur (x=0)
add(poly3([(0, 0, 0), (20, 0, 0), (20, 0, 5), (0, 0, 5)], CREAM, "#D8CDB2", 1))
add(poly3([(0, 0, 0), (0, 16, 0), (0, 16, 5), (0, 0, 5)], CREAM_D, "#D8CDB2", 1))
# atap + lis emas
add(poly3([(0, 0, 5), (20, 0, 5), (20, 16, 5), (0, 16, 5)], "#EFE7D2", GOLD, 2))
# blok portal di muka timur (naik sampai 8 m)
add(poly3([(0, 5, 0), (0, 11, 0), (0, 11, 8), (0, 5, 8)], CREAM, "#D8CDB2", 1))
p_a, p_b = iso(0, 5, 8), iso(0, 11, 8)
add(line(p_a[0], p_a[1], p_b[0], p_b[1], GOLD, 2))
# lengkung portal + pintu di muka timur
add(arch_iso('east', 0, 8, 4.8, 0, 4.5, 7, TEAK_D, GOLD, 1.5))
add(arch_iso('east', 0, 8, 3.0, 0, 2.6, 4.0, TEAK, GOLD, 1))
d0, d1 = iso(0, 8, 0), iso(0, 8, 4.0)
add(line(d0[0], d0[1], d1[0], d1[1], GOLD, 1.5))
# jendela: 3 di selatan, 2 di timur
for wx in (4, 10, 16):
    add(arch_iso('south', 0, wx, 1.8, 0.8, 3.0, 3.7, TEAK_D, GOLD, 1.5))
for wy in (2.5, 13.5):
    add(arch_iso('east', 0, wy, 1.8, 0.8, 3.0, 3.7, TEAK_D, GOLD, 1.5))
# kubah utama di tengah atap
dc = iso(10, 8, 5)
add(f'<ellipse cx="{dc[0]:.1f}" cy="{dc[1]:.1f}" rx="50" ry="22" fill="{EMERALD}"/>')
add(f'<path d="M {dc[0]-50:.1f} {dc[1]:.1f} C {dc[0]-55:.1f} {dc[1]-45:.1f} {dc[0]-32:.1f} {dc[1]-70:.1f} {dc[0]:.1f} {dc[1]-90:.1f} C {dc[0]+32:.1f} {dc[1]-70:.1f} {dc[0]+55:.1f} {dc[1]-45:.1f} {dc[0]+50:.1f} {dc[1]:.1f} Z" fill="{EMERALD}"/>')
add(f'<path d="M {dc[0]-22:.1f} {dc[1]:.1f} Q {dc[0]-12:.1f} {dc[1]-45:.1f} {dc[0]:.1f} {dc[1]-90:.1f}" fill="none" stroke="{EMERALD_D}" stroke-width="2" opacity="0.6"/>')
add(f'<path d="M {dc[0]+22:.1f} {dc[1]:.1f} Q {dc[0]+12:.1f} {dc[1]-45:.1f} {dc[0]:.1f} {dc[1]-90:.1f}" fill="none" stroke="{EMERALD_D}" stroke-width="2" opacity="0.6"/>')
add(line(dc[0], dc[1] - 90, dc[0], dc[1] - 106, GOLD, 2.5))
add(f'<circle cx="{dc[0]:.1f}" cy="{dc[1]-98:.1f}" r="4" fill="{GOLD}"/>')
add(crescent(dc[0], dc[1] - 116, 11))
# 4 kubah kecil di sudut atap
for kx, ky in ((1.5, 1.5), (18.5, 1.5), (1.5, 14.5), (18.5, 14.5)):
    kc = iso(kx, ky, 5)
    add(f'<ellipse cx="{kc[0]:.1f}" cy="{kc[1]:.1f}" rx="18" ry="9" fill="{EMERALD}"/>')
    add(f'<path d="M {kc[0]-18:.1f} {kc[1]:.1f} C {kc[0]-19:.1f} {kc[1]-15:.1f} {kc[0]-8:.1f} {kc[1]-20:.1f} {kc[0]:.1f} {kc[1]-26:.1f} C {kc[0]+8:.1f} {kc[1]-20:.1f} {kc[0]+19:.1f} {kc[1]-15:.1f} {kc[0]+18:.1f} {kc[1]:.1f} Z" fill="{EMERALD}"/>')
    add(f'<circle cx="{kc[0]:.1f}" cy="{kc[1]-28:.1f}" r="2.5" fill="{GOLD}"/>')
# serambi: kotak menonjol di muka timur (x -3..0, y 5..11, tinggi 3,3 m)
add(poly3([(-3, 5, 0), (0, 5, 0), (0, 5, 3.3), (-3, 5, 3.3)], CREAM_D, "#D8CDB2", 1))
add(poly3([(-3, 5, 0), (-3, 11, 0), (-3, 11, 3.3), (-3, 5, 3.3)], CREAM, "#D8CDB2", 1))
add(poly3([(-3, 5, 3.3), (0, 5, 3.3), (0, 11, 3.3), (-3, 11, 3.3)], "#EFE7D2", GOLD, 1.5))
for ay in (6.5, 8, 9.5):
    add(arch_iso('east', -3, ay, 1.4, 0, 2.2, 2.9, TEAK_D, GOLD, 1))
# 3 anak tangga di depan serambi
for i in range(3):
    z = 0.5 - i * 0.17
    x0 = -3 - 0.6 * (i + 1); x1 = -3 - 0.6 * i
    add(poly3([(x0, 5.5, z), (x0, 10.5, z), (x1, 10.5, z), (x1, 5.5, z)], STONE_L, "#9A9384", 1))
    add(poly3([(x0, 5.5, 0), (x0, 10.5, 0), (x0, 10.5, z), (x0, 5.5, z)], STONE, "#9A9384", 1))
# menara di sudut tenggara (0,0) — paling depan
mb = iso(0, 0, 0)
add(rect(mb[0] - 17, mb[1] - 16, 34, 16, STONE))
add(rect(mb[0] - 13, mb[1] - 224, 26, 208, CREAM, "#D8CDB2", 1))
add(rect(mb[0] - 23, mb[1] - 154, 46, 10, CREAM, GOLD, 2))
add(line(mb[0] - 23, mb[1] - 164, mb[0] + 23, mb[1] - 164, GOLD, 2))
add(f'<ellipse cx="{mb[0]:.1f}" cy="{mb[1]-224:.1f}" rx="18" ry="9" fill="{EMERALD}"/>')
add(f'<path d="M {mb[0]-18:.1f} {mb[1]-224:.1f} C {mb[0]-19:.1f} {mb[1]-240:.1f} {mb[0]-9:.1f} {mb[1]-248:.1f} {mb[0]:.1f} {mb[1]-256:.1f} C {mb[0]+9:.1f} {mb[1]-248:.1f} {mb[0]+19:.1f} {mb[1]-240:.1f} {mb[0]+18:.1f} {mb[1]-224:.1f} Z" fill="{EMERALD}"/>')
add(line(mb[0], mb[1] - 256, mb[0], mb[1] - 268, GOLD, 2))
add(crescent(mb[0], mb[1] - 276, 8))
add(text(1024, 2055, "Tampak dari tenggara: muka timur (portal + serambi) & muka selatan (3 jendela)", 18, LINE, anchor="end"))

# ============================================================ D — DENAH & PALET
section_label(56, 2100, "D", "DENAH & PALET")
# --- denah (utara di atas, barat/kiblat di kiri) ---
add(text(100, 2148, "Denah — 1 kotak = 1 m", 20, EMERALD, bold=True))
add(text(100, 2152, "", 15, INK))
DX, DY = 100, 2160
add(rect(DX, DY, 220, 176, CREAM_L, INK, 2))
add(rect(DX + 8, DY + 8, 204, 160, "none", INK, 1))
# mihrab (tengah dinding barat) + mimbar
add(rect(DX - 4, DY + 78, 12, 20, EMERALD, GOLD, 1.5))
add(text(DX - 10, DY + 92, "Mihrab", 15, INK, anchor="end"))
add(rect(DX + 12, DY + 36, 18, 22, TEAK))
add(text(DX + 34, DY + 52, "Mimbar", 15, INK))
# saf ×6 (garis tegak, menghadap barat)
for i in range(6):
    sx = DX + 50 + i * 22
    add(line(sx, DY + 20, sx, DY + 130, GOLD, 2))
add(text(DX + 105, DY + 150, "Saf ×6", 14, INK, anchor="middle"))
# rak kitab utara + selatan
add(rect(DX + 30, DY + 8, 170, 10, TEAK, None, 0, 0, 0.85))
add(rect(DX + 30, DY + 158, 170, 10, TEAK, None, 0, 0, 0.85))
# pintu timur (celah di dinding timur) + serambi + tangga
add(line(DX + 220, DY, DX + 220, DY + 78, INK, 2))
add(line(DX + 220, DY + 98, DX + 220, DY + 176, INK, 2))
add(text(DX + 230, DY + 64, "Pintu", 15, INK))
add(rect(DX + 220, DY + 70, 33, 36, CREAM, INK, 1))
add(text(DX + 230, DY + 136, "Serambi 3 m", 14, INK))
add(rect(DX + 253, DY + 78, 12, 20, STONE))
# menara (sudut tenggara) + wudu (selatan)
add(f'<circle cx="{DX+226}" cy="{DY+164}" r="7" fill="{EMERALD}" stroke="{GOLD}" stroke-width="1.5"/>')
add(text(DX + 238, DY + 168, "Menara", 14, INK))
add(rect(DX + 100, DY + 180, 56, 12, STONE, "#9A9384", 1))
add(text(DX + 162, DY + 190, "Wudu", 14, INK))
add(text(DX, DY + 236, "Utara di atas · kiblat di kiri (barat) · rak kitab utara & selatan", 14, "#5A4A32"))
# --- palet ---
add(text(450, 2148, "PALET WARNA", 20, EMERALD, bold=True))
PAL = [
    (CREAM, "Krem", "#F2EAD6", "dinding"),
    (EMERALD, "Zamrud", "#065F46", "kubah"),
    (GOLD, "Emas", "#C9A227", "lis, bulan sabit &amp; cornice"),
    (TEAK, "Jati", "#7B4B2A", "pintu, jendela &amp; serambi"),
    (STONE, "Batu", "#B8B2A4", "tangga & lantai serambi"),
    (CREAM_L, "Krem muda", "#FAF4E6", "lantai interior"),
]
for i, (c, name, hx, use) in enumerate(PAL):
    y = 2165 + i * 32
    add(rect(450, y, 64, 24, c, "#00000033", 1))
    add(text(526, y + 19, f"{name}  {hx}  —  {use}", 21, INK))
# --- ukuran + catatan kaki ---
add(text(540, 2432, "Jejak 20 × 16 m  ·  Interior 18 × 14 m  ·  Dinding 5 m  ·  Kubah ±11 m  ·  Menara ±14 m", 21, "#5A4A32", anchor="middle"))
add(rect(56, 2462, 968, 96, CREAM, GOLD, 2, rx=8))
add(text(76, 2500, "Yang dipertahankan / diubah & keputusan yang perlu Mas buat — lihat KONSEP-SURAU.md.", 20, INK, bold=True))
add(text(76, 2534, "Lembar ini hanya gambar konsep 2D — belum dibangun 3D, tunggu penilaian Mas.", 20, "#5A4A32"))
add(text(1024, 2590, "v2 · konsep 01 · 17 Nov 2026", 18, LINE, anchor="end"))

# ============================================================ RAKIT SVG
svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="2600" '
       f'viewBox="0 0 {W} {H}"><rect width="1080" height="2600" fill="{PAPER}"/>'
       + "".join(S) + '</svg>')
with open("/home/hatch/workspace/pesantren-verse/v2/konsep/bangunan/surau-v2-konsep.svg", "w") as f:
    f.write(svg)
print("SVG ditulis:", len(svg), "karakter")
