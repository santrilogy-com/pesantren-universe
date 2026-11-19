#!/usr/bin/env python3
"""Grid verifikasi hijab ronde 8 — satu kain menyatu (panel samping).

Cek depan (grid x,y -> z terdepan):
  A. zona pipi (y 1.55..1.66, |x| 0.14..0.22): 0 titik kulit terlihat
  B. tengah wajah (|x| <= 0.08, y 1.56..1.76): 0 titik kain di depan kulit
     (mata/hidung/alis; mulut dicek terpisah — dagu BOLEH tertutup y<=1.51)
  B2. mulut (y 1.54..1.56, |x| <= 0.05): kulit terdepan
  C. tonjolan panel vs kubah di atas (y 1.70..1.78): maks selisih z
Cek samping (grid z,y -> x terluar, sampling numerik):
  D. zona pelipis (z -0.12..0.05, y 1.50..1.70): 0 titik kulit terluar
     (panel + strip + drape harus menutupi sisi kepala)
"""
import math

# ---------- depan: analitik ----------
def ellipsoid(cx, cy, cz, rx, ry, rz, x, y):
    s = 1.0 - ((x - cx) / rx) ** 2 - ((y - cy) / ry) ** 2
    if s <= 0:
        return None
    return cz + rz * math.sqrt(s)

def frustum(cx, cy, cz, r_top, y_top, r_bot, y_bot, zscale, x, y):
    if y < y_bot or y > y_top:
        return None
    r = r_bot + (r_top - r_bot) * (y - y_bot) / (y_top - y_bot)
    if abs(x - cx) >= r:
        return None
    return cz + zscale * r * math.sqrt(1.0 - ((x - cx) / r) ** 2)

def capsule(cx, cy, cz, r, L, theta, scale_x, x, y):
    c, s = math.cos(theta), math.sin(theta)
    dx, dy = x - cx, y - cy
    u = dx * c + dy * s
    v = -dx * s + dy * c
    rx = r * scale_x
    if abs(v) <= L:
        t = 1.0 - (u / rx) ** 2
        if t <= 0:
            return None
        return cz + r * math.sqrt(t)
    dv = v - L if v > L else v + L
    t = 1.0 - (u / rx) ** 2 - (dv / r) ** 2
    if t <= 0:
        return None
    return cz + r * math.sqrt(t)

def surfaces(panel):
    s = {}
    s["kepala"] = lambda x, y: ellipsoid(0, 1.66, 0, 0.24, 0.24, 0.24, x, y)
    s["kubah"] = lambda x, y: ellipsoid(0, 1.74, -0.065, 0.2996, 0.2184, 0.2604, x, y)
    s["leher"] = lambda x, y: ellipsoid(0, 1.42, 0, 0.21, 0.0945, 0.1218, x, y)
    s["dagu"] = lambda x, y: frustum(0, 1.405, 0.02, 0.178, 1.51, 0.155, 1.30, 1.0, x, y)
    s["drape"] = lambda x, y: frustum(0, 1.43, -0.15, 0.25, 1.78, 0.22, 1.08, 0.52, x, y)
    if panel is None:
        s["pipi"] = lambda x, y: max(
            filter(None, [
                ellipsoid(0.16, 1.60, 0.10, 0.084, 0.12, 0.108, x, y),
                ellipsoid(-0.16, 1.60, 0.10, 0.084, 0.12, 0.108, x, y),
            ]), default=None)
    else:
        p = panel
        s["panel"] = lambda x, y: max(
            filter(None, [
                capsule(p["cx"], p["cy"], p["cz"], p["r"], p["L"], p["theta"], p["scale_x"], x, y),
                capsule(-p["cx"], p["cy"], p["cz"], p["r"], p["L"], -p["theta"], p["scale_x"], x, y),
            ]), default=None)
    return s

def cek_depan(label, surf):
    pipi, tengah, mulut, standoff, so_xy = [], [], [], 0.0, None
    for i in range(49):
        x = round(-0.24 + i * 0.01, 4)
        for j in range(34):
            y = round(1.45 + j * 0.01, 4)
            best, bestz = None, -9.0
            for nama, f in surf.items():
                z = f(x, y)
                if z is not None and z > bestz:
                    best, bestz = nama, z
            if best is None:
                continue
            if 1.55 <= y <= 1.66 and 0.14 <= abs(x) <= 0.22 and best == "kepala":
                pipi.append((x, y))
            if abs(x) <= 0.08 and 1.56 <= y <= 1.76 and best != "kepala":
                tengah.append((x, y, best))
            if abs(x) <= 0.05 and 1.54 <= y <= 1.56 and best != "kepala":
                mulut.append((x, y, best))
            # standoff: seberapa jauh kain panel di depan permukaan kulit
            # di zona pipi (info saja — pipi melengkung ke belakang,
            # kain pasti berdiri di depan kulit; ronde 7 pad ~0.04)
            if 1.55 <= y <= 1.66 and 0.14 <= abs(x) <= 0.22 and best in ("panel", "pipi"):
                hz = surf["kepala"](x, y)
                if hz is not None and bestz - hz > standoff:
                    standoff, so_xy = bestz - hz, (x, y)
    print(f"[{label}] pipi:{len(pipi)} tengah:{len(tengah)} mulut-tertutup:{len(mulut)} "
          f"standoff-maks:{standoff:.3f}@{so_xy}")
    if pipi:
        print("   pipi terlihat:", pipi[:6])
    if tengah:
        print("   tengah tertutup:", tengah[:6])
    if mulut:
        print("   mulut tertutup:", mulut[:6])
    return len(pipi), len(tengah), len(mulut), standoff

# ---------- samping: sampling numerik -> x terluar per sel (z,y) ----------
def sample_ellipsoid(cx, cy, cz, rx, ry, rz, nlat=60, nlon=120):
    pts = []
    for i in range(nlat + 1):
        th = math.pi * i / nlat
        for j in range(nlon):
            ph = 2 * math.pi * j / nlon
            pts.append((cx + rx * math.sin(th) * math.cos(ph),
                        cy + ry * math.cos(th),
                        cz + rz * math.sin(th) * math.sin(ph)))
    return pts

def sample_frustum(cx, cy, cz, r_top, y_top, r_bot, y_bot, zscale, n=40, nlon=90):
    pts = []
    for i in range(n + 1):
        y = y_bot + (y_top - y_bot) * i / n
        r = r_bot + (r_top - r_bot) * (y - y_bot) / (y_top - y_bot)
        for j in range(nlon):
            ph = 2 * math.pi * j / nlon
            pts.append((cx + r * math.cos(ph), y, cz + zscale * r * math.sin(ph)))
    return pts

def sample_capsule(cx, cy, cz, r, L, theta, scale_x, nv=60, nlon=48):
    """Kapsul sumbu lokal y, rotation.z=theta, skala x. Titik permukaan."""
    c, s = math.cos(theta), math.sin(theta)
    pts = []
    # bagian silinder
    for i in range(nv + 1):
        v = -L + 2 * L * i / nv
        for j in range(nlon):
            ph = 2 * math.pi * j / nlon
            u, w = r * scale_x * math.cos(ph), r * math.sin(ph)
            pts.append((cx + u * c - v * s, cy + u * s + v * c, cz + w))
    # tutup atas + bawah (setengah elipsoid)
    for cap in (L, -L):
        for i in range(nv // 2 + 1):
            dv = r * i / (nv // 2)
            rem = math.sqrt(max(0.0, r * r - dv * dv))
            for j in range(nlon):
                ph = 2 * math.pi * j / nlon
                u, w = rem * scale_x * math.cos(ph), rem * math.sin(ph)
                v = cap + (dv if cap > 0 else -dv)
                pts.append((cx + u * c - v * s, cy + u * s + v * c, cz + w))
    return pts

def cek_samping(label, panel):
    sel = {}  # (z,y) -> (nama, x maks) — hanya sisi kanan x>=0
    def masuk(nama, pts):
        for (x, y, z) in pts:
            if x < 0:
                continue
            key = (round(z / 0.02), round(y / 0.02))
            if key not in sel or x > sel[key][1]:
                sel[key] = (nama, x)
    masuk("kepala", sample_ellipsoid(0, 1.66, 0, 0.24, 0.24, 0.24))
    masuk("kubah", sample_ellipsoid(0, 1.74, -0.065, 0.2996, 0.2184, 0.2604))
    masuk("drape", sample_frustum(0, 1.43, -0.15, 0.25, 1.78, 0.22, 1.08, 0.52))
    masuk("dagu", sample_frustum(0, 1.405, 0.02, 0.178, 1.51, 0.155, 1.30, 1.0))
    masuk("leher", sample_ellipsoid(0, 1.42, 0, 0.21, 0.0945, 0.1218))
    masuk("strip", sample_capsule(0.22, 1.51, -0.05, 0.04, 0.23, 0.10, 1.0))
    if panel is None:
        masuk("pipi", sample_ellipsoid(0.16, 1.60, 0.10, 0.084, 0.12, 0.108))
    else:
        p = panel
        masuk("panel", sample_capsule(p["cx"], p["cy"], p["cz"], p["r"], p["L"], p["theta"], p["scale_x"]))
    kulit = [(round(z * 0.02, 2), round(y * 0.02, 2)) for (z, y), (n, x) in sel.items()
             if -0.12 <= z * 0.02 <= -0.02 and 1.50 <= y * 0.02 <= 1.70 and n == "kepala"]
    # siluet: panel tidak boleh keluar dari siluet kubah (x terluar per y)
    sil = 0.0
    if panel is not None:
        p = panel
        pmax, kmax = {}, {}
        for (x, y, z) in sample_capsule(p["cx"], p["cy"], p["cz"], p["r"], p["L"], p["theta"], p["scale_x"]):
            k = round(y / 0.02)
            pmax[k] = max(pmax.get(k, 0.0), x)
        for (x, y, z) in sample_ellipsoid(0, 1.74, -0.065, 0.2996, 0.2184, 0.2604):
            k = round(y / 0.02)
            kmax[k] = max(kmax.get(k, 0.0), x)
        for k, px in pmax.items():
            y = k * 0.02
            if 1.62 <= y <= 1.80 and k in kmax:
                sil = max(sil, px - kmax[k])
    print(f"[{label}] SAMPING kulit di pelipis (z -0.12..-0.02): {len(kulit)} {kulit[:8]} | siluet panel vs kubah: +{sil:.3f}")
    return len(kulit)

cek_depan("RONDE 7 (pad)", surfaces(None))
cek_samping("RONDE 7 (pad)", None)
for label, p in [
    ("R8-D r.11 L.13 cx.17 cy1.49 cz.10 sx.65", dict(cx=0.17, cy=1.49, cz=0.10, r=0.11, L=0.13, theta=0.10, scale_x=0.65)),
    ("R8-E r.12 L.13 cx.17 cy1.49 cz.09 sx.65", dict(cx=0.17, cy=1.49, cz=0.09, r=0.12, L=0.13, theta=0.10, scale_x=0.65)),
    ("R8-G r.13 L.13 cx.17 cy1.49 cz.085 sx.65", dict(cx=0.17, cy=1.49, cz=0.085, r=0.13, L=0.13, theta=0.10, scale_x=0.65)),
    ("R8-H r.12 L.15 cx.17 cy1.48 cz.085 sx.65", dict(cx=0.17, cy=1.48, cz=0.085, r=0.12, L=0.15, theta=0.10, scale_x=0.65)),
]:
    cek_depan(label, surfaces(p))
    cek_samping(label, p)
