#!/usr/bin/env python3
## Prototipe mesh prosedural jilbab REBUILD (Kirana, 18 Nov 2026 — reset total
## setelah verdict Mas 12:10 WIB "Jelek.. coba bikin dari awal lagi").
##
## Satu permukaan utuh (ArrayMesh): kubah + rok kain yang melebar ke dada,
## dengan bukaan wajah OVAL yang dibentuk oleh mesh-nya sendiri.
## Bagian A (hood): baris y horizontal, y 1.96..1.44, bukaan wajah dipotong
##   di pita y 1.515..1.775 (elips di y, tepi oval lembut).
## Bagian B (rok): baris t, y 1.44 -> y_bottom(theta) (U depan 0.88,
##   sisi 1.06, belakang 1.00), lingkaran penuh, melebar menutupi abaya.
## Verifikasi numerik + render preview matplotlib (depan + samping).
## Jalankan:  python3 skrip/grid_jilbab_rebuild.py
import math

# ---------- profil penampang (y, rx, rz, cz), interpolasi kosinus ----------
PROFILE = [
    (1.98, 0.005, 0.005, -0.02),
    (1.975, 0.055, 0.055, -0.025),
    (1.96, 0.10, 0.10, -0.03),
    (1.93, 0.16, 0.16, -0.035),
    (1.90, 0.20, 0.20, -0.04),
    (1.86, 0.24, 0.24, -0.045),
    (1.82, 0.26, 0.26, -0.045),
    (1.78, 0.275, 0.27, -0.04),
    (1.74, 0.28, 0.275, -0.04),
    (1.70, 0.282, 0.272, -0.035),
    (1.66, 0.278, 0.268, -0.03),
    (1.62, 0.275, 0.265, -0.02),
    (1.58, 0.268, 0.26, -0.01),
    (1.54, 0.26, 0.252, 0.0),
    (1.52, 0.25, 0.24, 0.005),
    (1.50, 0.247, 0.237, 0.005),
    (1.48, 0.242, 0.232, 0.0),
    (1.46, 0.242, 0.235, 0.0),
    (1.44, 0.25, 0.25, 0.0),
    (1.42, 0.252, 0.252, 0.005),
    (1.38, 0.26, 0.26, 0.005),
    (1.34, 0.268, 0.268, 0.008),
    (1.30, 0.275, 0.275, 0.008),
    (1.24, 0.282, 0.282, 0.01),
    (1.18, 0.29, 0.29, 0.01),
    (1.12, 0.296, 0.296, 0.01),
    (1.06, 0.302, 0.302, 0.01),
    (1.00, 0.305, 0.305, 0.01),
    (0.94, 0.303, 0.303, 0.01),
    (0.88, 0.298, 0.298, 0.01),
]

# ---------- bukaan wajah: elips di y ----------
Y_C, Y_H, TH_MAX = 1.645, 0.13, 0.63


def theta_open(y):
    d = (y - Y_C) / Y_H
    if abs(d) >= 1.0:
        return 0.0
    return TH_MAX * math.sqrt(1.0 - d * d)


# ---------- tepi bawah rok: kunci per sudut (derajat -> y) ----------
HEM_KEYS = [(0, 0.88), (45, 0.97), (90, 1.06), (135, 1.04), (180, 1.00)]


def _interp(keys, x):
    if x <= keys[0][0]:
        return keys[0][1]
    if x >= keys[-1][0]:
        return keys[-1][1]
    for i in range(len(keys) - 1):
        x0, v0 = keys[i]
        x1, v1 = keys[i + 1]
        if x0 <= x <= x1:
            t = (x - x0) / (x1 - x0)
            t = 0.5 - 0.5 * math.cos(math.pi * t)
            return v0 + (v1 - v0) * t
    return keys[-1][1]


def profile(y):
    asc = list(reversed(PROFILE))  # _interp butuh kunci menaik
    rx = _interp([(k[0], k[1]) for k in asc], y)
    rz = _interp([(k[0], k[2]) for k in asc], y)
    cz = _interp([(k[0], k[3]) for k in asc], y)
    return rx, rz, cz


def y_bottom(theta):
    deg = math.degrees(theta) % 360.0
    if deg > 180.0:
        deg = 360.0 - deg
    return _interp(HEM_KEYS, deg)


def fold_env(y):
    if y >= 1.50:
        return 0.0
    if y <= 1.30:
        return 1.0
    t = (1.50 - y) / 0.20
    return 0.5 - 0.5 * math.cos(math.pi * t)


def point(y, theta):
    rx, rz, cz = profile(y)
    f = 1.0 + 0.03 * math.cos(6.0 * theta) * fold_env(y)
    rx *= f
    rz *= f
    return (rx * math.sin(theta), y, cz + rz * math.cos(theta))


# ---------- bangun mesh ----------
C = 48
ROWS_A = [1.975, 1.96, 1.93, 1.90, 1.87, 1.84, 1.81, 1.78, 1.75, 1.72, 1.69,
          1.66, 1.63, 1.60, 1.57, 1.54, 1.52, 1.50, 1.48, 1.46, 1.44]
TS_B = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]

verts = []          # (x, y, z)
tris = []           # (i, j, k)
# apex
APEX = (0.0, 1.98, -0.02)
apex_i = 0
verts.append(APEX)


def arc_thetas(y):
    """Sudut kolom untuk satu baris hood: [th_a, 2pi - th_a], C kolom."""
    th_a = theta_open(y)
    if th_a <= 0.0:
        return [2.0 * math.pi * j / C for j in range(C)], True
    return [th_a + (2.0 * math.pi - 2.0 * th_a) * j / (C - 1)
            for j in range(C)], False


# Bagian A
idx_a = []  # per baris: list indeks simpul (panjang C); None bila busur penuh wrap
for y in ROWS_A:
    thetas, full = arc_thetas(y)
    row = []
    for th in thetas:
        row.append(len(verts))
        verts.append(point(y, th))
    idx_a.append((row, full))

# kipas apex -> baris 0 (busur penuh). Urutan (puncak, b, a):
# GODOT: front face = CW bila dilihat dari luar (dibuktikan debug
# winding 18 Nov: (puncak,a,b) terbaca backface -> normal dibalik
# renderer). Cross di bawah dibalik supaya normal array tetap ATAS.
row0, _ = idx_a[0]
for j in range(C):
    a = row0[j]
    b = row0[(j + 1) % C]
    tris.append((apex_i, b, a))
# quad antar baris A (urutan DIBALIK: (a,b,c) — front face Godot = CW)
for r in range(len(ROWS_A) - 1):
    row_lo, _ = idx_a[r]
    row_hi, _ = idx_a[r + 1]
    for j in range(C - 1):
        a, b = row_lo[j], row_lo[j + 1]
        c, d = row_hi[j], row_hi[j + 1]
        tris.append((a, b, c))
        tris.append((b, d, c))
    # kolom terakhir -> kolom pertama hanya bila kedua baris busur penuh
    _, full_lo = idx_a[r]
    _, full_hi = idx_a[r + 1]
    if full_lo and full_hi:
        a, b = row_lo[C - 1], row_lo[0]
        c, d = row_hi[C - 1], row_hi[0]
        tris.append((a, b, c))
        tris.append((b, d, c))

# Bagian B (rok): baris t, lingkaran penuh, seam = baris terakhir A
seam_row, _ = idx_a[-1]
assert len(seam_row) == C
idx_b = [seam_row]
for t in TS_B[1:]:
    y_front = 1.44 + t * (0.88 - 1.44)
    row = []
    for j in range(C):
        th = 2.0 * math.pi * j / C
        y = 1.44 + t * (y_bottom(th) - 1.44)
        # profil dari y depan (seragam per baris), posisi dari y(theta)
        rx, rz, cz = profile(y_front)
        f = 1.0 + 0.03 * math.cos(6.0 * th) * fold_env(y_front)
        row.append(len(verts))
        verts.append((rx * f * math.sin(th), y, cz + rz * f * math.cos(th)))
    idx_b.append(row)
for r in range(len(idx_b) - 1):
    for j in range(C):
        a, b = idx_b[r][j], idx_b[r][(j + 1) % C]
        c, d = idx_b[r + 1][j], idx_b[r + 1][(j + 1) % C]
        tris.append((a, b, c))
        tris.append((b, d, c))

print("simpul: %d, segitiga: %d" % (len(verts), len(tris)))

# ---------- normal halus + cek winding ----------
import collections
nrm = [[0.0, 0.0, 0.0] for _ in verts]


def sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1],
            a[2] * b[0] - a[0] * b[2],
            a[0] * b[1] - a[1] * b[0])


def dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


bad_wind = 0
for (i, j, k) in tris:
    # Cross DIBALIK ((vk-vi)x(vj-vi)): winding dibalik untuk front
    # face Godot (CW), tapi normal array harus tetap mengarah KELUAR.
    n = cross(sub(verts[k], verts[i]), sub(verts[j], verts[i]))
    L = math.sqrt(dot(n, n))
    if L == 0:
        continue
    n = (n[0] / L, n[1] / L, n[2] / L)
    for idx in (i, j, k):
        nrm[idx][0] += n[0]
        nrm[idx][1] += n[1]
        nrm[idx][2] += n[2]
    # cek: normal segitiga harus mengarah keluar (dot dgn radial > 0)
    c = ((verts[i][0] + verts[j][0] + verts[k][0]) / 3.0,
         (verts[i][1] + verts[j][1] + verts[k][1]) / 3.0,
         (verts[i][2] + verts[j][2] + verts[k][2]) / 3.0)
    radial = (c[0], 0.0, c[2] - 0.0)
    if dot(n, radial) < -0.05 and c[1] < 1.90:
        bad_wind += 1
print("segitiga winding mencurigakan (normal ke dalam): %d / %d"
      % (bad_wind, len(tris)))
for i in range(len(nrm)):
    L = math.sqrt(dot(nrm[i], nrm[i]))
    if L > 0:
        nrm[i] = (nrm[i][0] / L, nrm[i][1] / L, nrm[i][2] / L)
luar = 0
for i, v in enumerate(verts):
    radial = (v[0], 0.0, v[2])
    if dot(nrm[i], radial) > 0:
        luar += 1
print("simpul dgn normal mengarah keluar: %d / %d" % (luar, len(verts)))
print("normal puncak (harus y > 0.5): (%.3f, %.3f, %.3f)"
      % (nrm[apex_i][0], nrm[apex_i][1], nrm[apex_i][2]))

# ---------- verifikasi geometri ----------
HEAD_C, HEAD_R = (0.0, 1.66, 0.0), 0.24


def r_abaya(y):
    return 0.23 + (1.42 - y) / 1.32 * 0.13


min_head = 9.9
for v in verts:
    if 1.42 <= v[1] <= 1.90:
        d = math.sqrt((v[0] - HEAD_C[0]) ** 2 + (v[1] - HEAD_C[1]) ** 2
                      + (v[2] - HEAD_C[2]) ** 2)
        min_head = min(min_head, d)
print("jarak min simpul ke pusat kepala (harus > 0.24): %.4f" % min_head)

min_abaya = 9.9
for v in verts:
    if v[1] < 1.42:
        d = math.sqrt(v[0] ** 2 + v[2] ** 2)
        min_abaya = min(min_abaya, d - r_abaya(v[1]))
print("margin min simpul thd abaya (harus > 0): %.4f" % min_abaya)

tengah = [v for v in verts if abs(v[0]) < 0.10 and 1.55 <= v[1] <= 1.72
          and v[2] > 0.15]
print("simpul kain di depan tengah wajah (harus 0): %d" % len(tengah))
pipi_kiri = [v for v in verts if 1.58 <= v[1] <= 1.68 and -0.20 <= v[0] <= -0.14
             and v[2] > 0.15]
pipi_kanan = [v for v in verts if 1.58 <= v[1] <= 1.68 and 0.14 <= v[0] <= 0.20
              and v[2] > 0.15]
print("simpul kain di depan pipi kiri/kanan (harus >0): %d / %d"
      % (len(pipi_kiri), len(pipi_kanan)))
dagu = [v for v in verts if 1.44 <= v[1] <= 1.50 and abs(v[0]) < 0.10
        and v[2] > 0.18]
print("simpul kain di depan dagu (harus >0): %d" % len(dagu))

# tepi bukaan per tinggi
for y in (1.69, 1.62, 1.55):
    th = theta_open(y)
    rx, rz, cz = profile(y)
    print("bukaan y=%.2f: th=%.3f rad, tepi x=+-%.3f z=%.3f"
          % (y, th, rx * math.sin(th), cz + rz * math.cos(th)))

xs = [v[0] for v in verts]
ys = [v[1] for v in verts]
zs = [v[2] for v in verts]
print("AABB: x %.3f..%.3f  y %.3f..%.3f  z %.3f..%.3f"
      % (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)))
print("tepi bawah: depan y=%.3f (th=0), sisi y=%.3f (th=90), belakang y=%.3f"
      % (y_bottom(0.0), y_bottom(math.pi / 2), y_bottom(math.pi)))

# ---------- render preview ----------
try:
    import numpy as np
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection

    V = np.array(verts)
    T = np.array(tris)
    # kepala referensi: bola r 0.24
    u = np.linspace(0, 2 * np.pi, 24)
    w = np.linspace(0, np.pi, 16)
    hx = 0.24 * np.outer(np.cos(u), np.sin(w))
    hy = 1.66 + 0.24 * np.outer(np.ones_like(u), np.cos(w))
    hz = 0.24 * np.outer(np.sin(u), np.sin(w))
    fig = plt.figure(figsize=(10, 6))
    for k, (elev, azim, judul) in enumerate(
            [(0, 90, "DEPAN"), (0, 0, "SAMPING")]):
        ax = fig.add_subplot(1, 2, k + 1, projection="3d")
        # peta (x, y, z) -> mpl (x, z, y): vertikal = y
        tri_pts = V[T][:, :, [0, 2, 1]]
        pc = Poly3DCollection(tri_pts, alpha=0.95, linewidths=0.1,
                              edgecolor="#b9a888", facecolor="#f2ead6")
        ax.add_collection3d(pc)
        ax.plot_surface(hx, hz, hy, color="#ffc09f", alpha=0.55,
                        linewidth=0)
        # kacamata: dua lingkaran di y 1.69, z 0.24
        for cx0 in (-0.085, 0.085):
            t = np.linspace(0, 2 * np.pi, 40)
            ax.plot(cx0 + 0.055 * np.cos(t), 0.24 + 0 * t,
                    1.69 + 0.045 * np.sin(t), color="black", lw=1.5)
        ax.set_xlim(-0.45, 0.45)
        ax.set_ylim(-0.45, 0.45)
        ax.set_zlim(0.75, 2.05)
        ax.set_box_aspect((1, 1, 1.45))
        ax.view_init(elev=elev, azim=azim)
        ax.set_title(judul)
        ax.set_xlabel("x")
        ax.set_ylabel("z")
        ax.set_zlabel("y")
    plt.tight_layout()
    plt.savefig("/tmp/jilbab_rebuild_preview.png", dpi=110)
    print("preview: /tmp/jilbab_rebuild_preview.png")
except Exception as e:
    print("preview gagal: %r" % (e,))
