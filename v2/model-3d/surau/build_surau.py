#!/usr/bin/env python3
"""Bangun SURAU v2 (3D) dari lembar konsep yang sudah DI-ACC Mas.
Jejak 20x16 m, dinding 5 m, kubah bawang zamrud +-11 m, menara +-14 m.
Palet HEX PERSIS. Gaya halus (bevel), bukan balok.
Jalankan headless: blender --background --python build_surau.py
"""
import bpy
import bmesh
import math
import os
import random

BLEND_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_BLEND = os.path.join(BLEND_DIR, "surau-v2.blend")
OUT_GLB = os.path.join(BLEND_DIR, "surau-v2.glb")

# ------------------------------------------------------------------ util
def srgb2lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def hex_rgb(h):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i+2], 16) for i in (0, 2, 4))
    return (srgb2lin(r), srgb2lin(g), srgb2lin(b), 1.0)

def mat_flat(name, hexcol, rough=0.9, metallic=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hex_rgb(hexcol)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    return m

def mat_tex(name, img_path, rough=0.85):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    tex = m.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(img_path)
    tex.extension = "REPEAT"
    m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rough
    return m

def link(obj, coll):
    coll.objects.link(obj)
    return obj

def box(name, loc, dims, mat, coll, bevel_w=0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = name
    o.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if mat:
        o.data.materials.append(mat)
    if bevel_w > 0:
        mod = o.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel_w
        mod.segments = 2
        mod.limit_method = "ANGLE"
        mod.angle_limit = math.radians(30)
    link(o, coll)
    return o

def cyl(name, loc, r, depth, mat, coll, verts=32, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth,
                                        location=loc, rotation=rot)
    o = bpy.context.object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    link(o, coll)
    return o

def sphere(name, loc, r, mat, coll, seg=24):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=16,
                                         radius=r, location=loc)
    o = bpy.context.object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    link(o, coll)
    return o

def recalc_normals(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(obj.data)
    bm.free()

def bezier_cubic(p0, p1, p2, p3, n):
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3*p0[0] + 3*mt*mt*t*p1[0] + 3*mt*t*t*p2[0] + t**3*p3[0]
        z = mt**3*p0[1] + 3*mt*mt*t*p1[1] + 3*mt*t*t*p2[1] + t**3*p3[1]
        pts.append((x, z))
    return pts

def onion_profile(w, h, n=18):
    """Profil kubah bawang persis kurva SVG konsep (bezier kubik)."""
    return bezier_cubic((w/2, 0.0), (w/2 + 0.12*w, 0.28*h),
                        (0.44*w, 0.58*h), (0.0, h), n)

def lathe(name, profile, segments, mat, coll, loc=(0, 0, 0)):
    """Putar profil (r, z) mengelilingi sumbu Z di titik loc."""
    verts, rings = [], []
    for (r, z) in profile:
        if r < 1e-6:
            rings.append([len(verts)])
            verts.append((loc[0], loc[1], loc[2] + z))
        else:
            ring = []
            for j in range(segments):
                a = 2 * math.pi * j / segments
                ring.append(len(verts))
                verts.append((loc[0] + r * math.cos(a),
                              loc[1] + r * math.sin(a), loc[2] + z))
            rings.append(ring)
    faces = []
    for i in range(len(rings) - 1):
        r0, r1 = rings[i], rings[i + 1]
        if len(r0) == 1 and len(r1) == 1:
            continue
        if len(r0) == 1:
            for j in range(segments):
                faces.append((r0[0], r1[(j + 1) % segments], r1[j]))
        elif len(r1) == 1:
            for j in range(segments):
                faces.append((r0[j], r0[(j + 1) % segments], r1[0]))
        else:
            for j in range(segments):
                j2 = (j + 1) % segments
                faces.append((r0[j], r0[j2], r1[j2], r1[j]))
    if len(rings[0]) > 1:  # tutup bawah
        c = len(verts)
        verts.append((loc[0], loc[1], loc[2] + profile[0][1]))
        for j in range(segments):
            faces.append((c, rings[0][(j + 1) % segments], rings[0][j]))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    if mat:
        mesh.materials.append(mat)
    for p in mesh.polygons:
        p.use_smooth = True
    link(obj, coll)
    recalc_normals(obj)
    return obj

def arch_poly(w, base_z, spring_z, apex_z, n=10):
    """Outline lengkung lancip (CCW di bidang u=horizontal, v=vertikal)."""
    pts = [(-w/2, base_z), (-w/2, spring_z)]
    cy = apex_z + (spring_z - apex_z) * 0.30
    # kurva kiri
    for i in range(1, n + 1):
        t = i / n
        mt = 1 - t
        x = mt*mt*(-w/2) + 2*mt*t*(-w/2 + 0.08*w) + t*t*0
        z = mt*mt*spring_z + 2*mt*t*cy + t*t*apex_z
        pts.append((x, z))
    # kurva kanan
    for i in range(1, n + 1):
        t = i / n
        mt = 1 - t
        x = mt*mt*0 + 2*mt*t*(w/2 - 0.08*w) + t*t*(w/2)
        z = mt*mt*apex_z + 2*mt*t*cy + t*t*spring_z
        pts.append((x, z))
    pts.append((w/2, base_z))
    return pts

def extrude_poly(name, pts, plane, fixed, depth, mat, coll, uv_scale=1.0):
    """Ekstrusi poligon 2D (u,v) menjadi padat.
    plane 'YZ': u->Y, v->Z, ekstrusi sepanjang X (fixed..fixed+depth).
    plane 'XZ': u->X, v->Z, ekstrusi sepanjang Y.
    plane 'XY': u->X, v->Y, ekstrusi sepanjang Z.
    UV planar dari (u,v) dibagi uv_scale."""
    def P(u, v, w):
        if plane == "YZ":
            return (w, u, v)
        if plane == "XZ":
            return (u, w, v)
        return (u, v, w)
    n = len(pts)
    cu = sum(p[0] for p in pts) / n
    cv = sum(p[1] for p in pts) / n
    verts = [P(u, v, fixed) for (u, v) in pts]
    verts += [P(u, v, fixed + depth) for (u, v) in pts]
    cf = len(verts)
    verts.append(P(cu, cv, fixed))
    cb = len(verts)
    verts.append(P(cu, cv, fixed + depth))
    faces = []
    for i in range(n):
        j = (i + 1) % n
        faces.append((cf, j, i))          # tutup depan
        faces.append((cb, n + i, n + j))  # tutup belakang
        faces.append((i, j, n + j, n + i))  # sisi
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    # UV planar
    uv = mesh.uv_layers.new(name="UV")
    for loop in mesh.loops:
        vi = loop.vertex_index
        if vi < n:
            u, v = pts[vi]
        elif vi < 2 * n:
            u, v = pts[vi - n]
        else:
            u, v = cu, cv
        uv.data[loop.index].uv = (u / uv_scale, v / uv_scale)
    obj = bpy.data.objects.new(name, mesh)
    if mat:
        mesh.materials.append(mat)
    link(obj, coll)
    recalc_normals(obj)
    return obj

def crescent_poly(r, n=24):
    """Outline bulan sabit (dua busur, persis path SVG konsep)."""
    R = r * 1.118
    pts = []
    # busur luar: atas -> kiri -> bawah (sudut 90..270)
    for i in range(n + 1):
        a = math.radians(90 + 180 * i / n)
        pts.append((r * math.cos(a), r * math.sin(a)))
    # busur dalam: bawah -> kanan -> atas, pusat (-0.5r, 0), radius R
    a0 = math.degrees(math.atan2(-r, 0.5 * r))  # -63.43
    a1 = math.degrees(math.atan2(r, 0.5 * r))   # +63.43
    for i in range(1, n + 1):
        a = math.radians(a0 + (a1 - a0) * i / n)
        pts.append((-0.5 * r + R * math.cos(a), R * math.sin(a)))
    return pts

def crescent(name, r, loc, mat, coll):
    """Bulan sabit tegak, bidang YZ (terlihat dari timur/barat)."""
    pts = crescent_poly(r)
    return extrude_poly(name, pts, "YZ", loc[0] - 0.04, 0.08, mat, coll)

def arch_tube(name, fixed, center, w, base_z, spring_z, apex_z, span, mat, coll, r=0.05):
    """Trim lengkung emas (tabung mengikuti profil lengkung).
    span 'Y': lengkung membentang sepanjang Y di bidang X=fixed.
    span 'X': membentang sepanjang X di bidang Y=fixed."""
    pts = []
    prof = [(-w/2, base_z), (-w/2, spring_z)]
    cy = apex_z + (spring_z - apex_z) * 0.30
    for i in range(1, 11):
        t = i / 10
        mt = 1 - t
        x = mt*mt*(-w/2) + 2*mt*t*(-w/2 + 0.08*w) + t*t*0
        z = mt*mt*spring_z + 2*mt*t*cy + t*t*apex_z
        prof.append((x, z))
    for i in range(1, 11):
        t = i / 10
        mt = 1 - t
        x = mt*mt*0 + 2*mt*t*(w/2 - 0.08*w) + t*t*(w/2)
        z = mt*mt*apex_z + 2*mt*t*cy + t*t*spring_z
        prof.append((x, z))
    prof.append((w/2, base_z))
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r
    cu.bevel_resolution = 2
    cu.resolution_u = 2  # dulu 12 -> tabung lengkung 2112 poli/tabung; 2 cukup halus, hemat tris
    sp = cu.splines.new("BEZIER")
    sp.bezier_points.add(len(prof) - 1)
    for bp, (u, z) in zip(sp.bezier_points, prof):
        if span == "Y":
            bp.co = (fixed, center + u, z)
        else:
            bp.co = (center + u, fixed, z)
        bp.handle_left_type = "AUTO"
        bp.handle_right_type = "AUTO"
    sp.bezier_points[0].handle_left_type = "VECTOR"
    sp.bezier_points[0].handle_right_type = "VECTOR"
    # titik puncak (tengah) tajam
    mid = len(prof) // 2
    sp.bezier_points[mid].handle_left_type = "VECTOR"
    sp.bezier_points[mid].handle_right_type = "VECTOR"
    sp.bezier_points[-1].handle_left_type = "VECTOR"
    sp.bezier_points[-1].handle_right_type = "VECTOR"
    obj = bpy.data.objects.new(name, cu)
    link(obj, coll)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.object
    if mat:
        obj.data.materials.append(mat)
    return obj

def bool_cut(target, cutter):
    mod = target.modifiers.new("Bool", "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.solver = "EXACT"
    mod.object = cutter
    bpy.context.view_layer.objects.active = target
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(cutter, do_unlink=True)

def bevel(obj, w=0.04):
    mod = obj.modifiers.new("Bevel", "BEVEL")
    mod.width = w
    mod.segments = 2
    mod.limit_method = "ANGLE"
    mod.angle_limit = math.radians(30)
    return mod

def buku_row(name, cx, cy, z_base, length, mat_list, coll, seed=7,
             hmin=0.26, hmax=0.34):
    """Satu baris buku berdiri di rak: SATU mesh gabungan, warna per buku.
    Buku berdiri di atas papan (z_base), sepanjang X, tebal 0,05-0,09 m,
    tinggi hmin-hmax, sesekali ada celah kosong dan 1-2 buku miring."""
    rnd = random.Random(seed)
    verts, faces, mat_idx = [], [], []
    x = cx - length / 2
    end = cx + length / 2
    depth = 0.30
    while x < end - 0.06:
        if rnd.random() < 0.06:  # celah kosong sesekali
            x += rnd.uniform(0.08, 0.18)
            continue
        t = rnd.uniform(0.05, 0.09)
        h = rnd.uniform(hmin, hmax)
        lean = 0.0
        if rnd.random() < 0.05:
            lean = rnd.uniform(0.10, 0.18) * (1 if rnd.random() < 0.5 else -1)
        bx, bz = x + t / 2, z_base
        offs = [(-t/2, -depth/2, 0), (t/2, -depth/2, 0), (t/2, depth/2, 0), (-t/2, depth/2, 0),
                (-t/2, -depth/2, h), (t/2, -depth/2, h), (t/2, depth/2, h), (-t/2, depth/2, h)]
        base = len(verts)
        ca, sa = math.cos(lean), math.sin(lean)
        for (dx, dy, dz) in offs:
            rx = dx * ca + dz * sa
            rz = -dx * sa + dz * ca
            verts.append((bx + rx, cy + dy, bz + rz))
        quads = [(0, 1, 2, 3), (4, 7, 6, 5), (0, 4, 5, 1),
                 (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]
        ci = rnd.randrange(len(mat_list))
        for q in quads:
            faces.append(tuple(base + i for i in q))
            mat_idx.append(ci)
        x += t + 0.004
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    for m in mat_list:
        mesh.materials.append(m)
    for poly, mi in zip(mesh.polygons, mat_idx):
        poly.material_index = mi
    obj = bpy.data.objects.new(name, mesh)
    link(obj, coll)
    recalc_normals(obj)
    return obj

def rak_buku(name, cx, cy, coll):
    """Rak buku jati 8 m x 0,45 m x 1,8 m menempel dinding (utara/selatan),
    3 baris kitab warna-warni. cy = +6.75 (utara) atau -6.75 (selatan).
    Lantai interior z=0,55; rak z 0,55..2,35."""
    z0 = 0.55
    box(f"{name}_SampingKiri", (cx - 3.95, cy, z0 + 0.9), (0.1, 0.45, 1.8), M_JATI, coll, bevel_w=0.02)
    box(f"{name}_SampingKanan", (cx + 3.95, cy, z0 + 0.9), (0.1, 0.45, 1.8), M_JATI, coll, bevel_w=0.02)
    box(f"{name}_Atas", (cx, cy, z0 + 1.76), (8.0, 0.45, 0.08), M_JATI, coll, bevel_w=0.02)
    box(f"{name}_Plinth", (cx, cy, z0 + 0.05), (8.0, 0.45, 0.1), M_JATI_GELAP, coll)
    back_y = cy + (0.20 if cy > 0 else -0.20)
    box(f"{name}_Belakang", (cx, back_y, z0 + 0.9), (8.0, 0.05, 1.8), M_JATI, coll)
    # 2 papan tengah (alas baris 2 dan 3)
    box(f"{name}_Papan1", (cx, cy, z0 + 0.50), (7.8, 0.4, 0.06), M_JATI, coll)
    box(f"{name}_Papan2", (cx, cy, z0 + 0.95), (7.8, 0.4, 0.06), M_JATI, coll)
    # 3 baris buku: alas di atas plinth (0,65), papan 1 (1,08), papan 2 (1,53)
    seed0 = 11 if cy > 0 else 51
    buku_row(f"{name}_BukuBaris1", cx, cy, z0 + 0.10, 7.7, M_BUKU, coll,
             seed=seed0, hmin=0.26, hmax=0.34)
    buku_row(f"{name}_BukuBaris2", cx, cy, z0 + 0.53, 7.7, M_BUKU, coll,
             seed=seed0 + 1, hmin=0.26, hmax=0.34)
    buku_row(f"{name}_BukuBaris3", cx, cy, z0 + 0.98, 7.7, M_BUKU, coll,
             seed=seed0 + 2, hmin=0.30, hmax=0.38)

def dampar(name, cx, cy, coll):
    """Dampar santri: bangku kayu rendah 3,0 x 0,9 m, tinggi duduk 0,25 m,
    sumbu panjang utara-selatan (duduk menghadap barat/kiblat).
    Lantai interior z=0,55."""
    z0 = 0.55
    box(f"{name}_Papan", (cx, cy, z0 + 0.29), (0.9, 3.0, 0.08), M_JATI, coll, bevel_w=0.02)
    for dx in (-0.35, 0.35):
        for dy in (-1.35, 1.35):
            box(f"{name}_Kaki", (cx + dx, cy + dy, z0 + 0.125), (0.12, 0.12, 0.25), M_JATI_GELAP, coll)
    for dx in (-0.42, 0.42):
        box(f"{name}_ApronPanjang", (cx + dx, cy, z0 + 0.20), (0.06, 2.7, 0.15), M_JATI, coll)
    for dy in (-1.42, 1.42):
        box(f"{name}_ApronUjung", (cx, cy + dy, z0 + 0.20), (0.84, 0.06, 0.15), M_JATI, coll)
    # 3 kitab tergeletak di atas dampar
    for i, (ox, oy, rot) in enumerate(((-0.15, -0.9, 0.1), (0.1, 0.2, -0.15), (-0.1, 1.0, 0.05))):
        b = box(f"{name}_Kitab{i+1}", (cx + ox, cy + oy, z0 + 0.355),
                (0.30, 0.22, 0.05), M_BUKU[(i * 3 + 1) % len(M_BUKU)], coll)
        b.rotation_euler = (0, 0, rot)

# ======================================================================
# SCENE
# ======================================================================
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = "METRIC"
bpy.context.scene.unit_settings.scale_length = 1.0
coll = bpy.data.collections.new("Surau_v2")
bpy.context.scene.collection.children.link(coll)

# Koordinat: X timur-barat (timur +X), Y utara-selatan (utara +Y), Z atas.
# Bangunan berpusat di (0,0). Muka timur X=+10, barat X=-10,
# selatan Y=-8, utara Y=+8. Tanah z=0.

# ======================================================================
# MATERIAL (hex persis konsep)
# ======================================================================
M_KREM = mat_flat("Krem_Dinding", "#F2EAD6", rough=0.9)
M_ZAMRUD = mat_flat("Zamrud_Kubah", "#065F46", rough=0.65)
M_EMAS = mat_flat("Emas", "#C9A227", rough=0.35, metallic=0.55)
M_JATI = mat_flat("Jati", "#7B4B2A", rough=0.8)
M_JATI_GELAP = mat_flat("Jati_Gelap", "#4A2E18", rough=0.85)
M_BATU = mat_flat("Batu", "#B8B2A4", rough=0.95)
M_KREM_MUDA = mat_flat("Krem_Muda_Lantai", "#FAF4E6", rough=0.9)
M_HIJAU = mat_flat("Hijau_Tanaman", "#5F7055", rough=0.9)
M_KISI = mat_tex("Kisi_Emas", os.path.join(BLEND_DIR, "kisi.png"), rough=0.8)
M_PLAKAT = mat_tex("Plakat_Arab", os.path.join(BLEND_DIR, "plakat.png"), rough=0.6)
# Warna sampul kitab (dipakai rak buku + kitab di atas dampar)
BOOK_COLORS = ["#065F46", "#C9A227", "#B91C1C", "#1D4ED8", "#15803D",
               "#B45309", "#7E22CE", "#E8DCC0", "#0F766E", "#7B4B2A"]
M_BUKU = [mat_flat(f"Buku_{i}", c, rough=0.85) for i, c in enumerate(BOOK_COLORS)]

# ======================================================================
# ALAS + DINDING
# ======================================================================
# Alas batu (plinth) 0,5 m
box("SR_AlasBatu", (0, 0, 0.25), (20.4, 16.4, 0.5), M_BATU, coll, bevel_w=0.03)

# Dinding: 4 kotak 1 m tebal, z 0..5.
# Timur/barat dijepit di antara utara/selatan (Y -7..7) supaya tidak ada
# muka yang koplanar di sudut (penyebab muka hitam di render).
d_timur = box("SR_DindingTimur", (9.5, 0, 2.5), (1, 14, 5), M_KREM, coll)
d_barat = box("SR_DindingBarat", (-9.5, 0, 2.5), (1, 14, 5), M_KREM, coll)
d_utara = box("SR_DindingUtara", (0, 7.5, 2.5), (20, 1, 5), M_KREM, coll)
d_selatan = box("SR_DindingSelatan", (0, -7.5, 2.5), (20, 1, 5), M_KREM, coll)

# --- Bukaan jendela (lengkung 1,8 m, alas z 0,6, puncak 4,5) ---
def jendela_cutter(plane, fixed, center):
    """Cutter lengkung menembus dinding (kedalaman 1,4 m)."""
    pts = arch_poly(1.8, 0.6, 2.36, 4.5)
    if plane == "YZ":  # dinding timur/barat: u->Y
        pts2 = [(center + u, v) for (u, v) in pts]
        return extrude_poly("Cutter", pts2, "YZ", fixed - 0.7, 1.4, None, coll)
    else:  # dinding utara/selatan: u->X
        pts2 = [(center + u, v) for (u, v) in pts]
        return extrude_poly("Cutter", pts2, "XZ", fixed - 0.7, 1.4, None, coll)

# Timur: 4 jendela (2 tiap sisi portal), Y = +-4.2, +-6.0
for wy in (-6.0, -4.2, 4.2, 6.0):
    bool_cut(d_timur, jendela_cutter("YZ", 9.5, wy))
# Utara: 3 jendela, X = -6, 0, 6
for wx in (-6, 0, 6):
    bool_cut(d_utara, jendela_cutter("XZ", 7.5, wx))
# Selatan: 3 jendela, X = -6, 0, 6
for wx in (-6, 0, 6):
    bool_cut(d_selatan, jendela_cutter("XZ", -7.5, wx))
# Pintu timur: bukaan kotak 4 x 2,6 m di dinding timur (Y -2..2, z 0,5..3,1)
pintu_cutter = box("CutterPintu", (9.5, 0, 1.8), (1.4, 4.0, 2.6), None, coll)
bool_cut(d_timur, pintu_cutter)

# --- Kisi jendela (panel lengkung, mundur 0,05 dari muka luar) ---
def panel_kisi(plane, fixed, center):
    pts = arch_poly(1.8, 0.6, 2.36, 4.5)
    if plane == "YZ":
        pts2 = [(center + u, v) for (u, v) in pts]
        return extrude_poly("SR_KisiJendela", pts2, "YZ", fixed, 0.05, M_KISI, coll, uv_scale=1.2)
    pts2 = [(center + u, v) for (u, v) in pts]
    return extrude_poly("SR_KisiJendela", pts2, "XZ", fixed, 0.05, M_KISI, coll, uv_scale=1.2)

for wy in (-6.0, -4.2, 4.2, 6.0):
    panel_kisi("YZ", 9.45, wy)
for wx in (-6, 0, 6):
    panel_kisi("XZ", 7.45, wx)
    panel_kisi("XZ", -7.5, wx)

# --- Ambang batu di bawah tiap jendela (sisi luar) ---
for wy in (-6.0, -4.2, 4.2, 6.0):
    box("SR_AmbangJendela", (10.06, wy, 0.55), (0.18, 2.0, 0.1), M_BATU, coll)
for wx in (-6, 0, 6):
    box("SR_AmbangJendela", (wx, 8.06, 0.55), (2.0, 0.18, 0.1), M_BATU, coll)
    box("SR_AmbangJendela", (wx, -8.06, 0.55), (2.0, 0.18, 0.1), M_BATU, coll)

# (bevel dinding dilepas — pemicu muka hitam + menambah tris; tepi halus
# dibawa kubah/silinder, bukan bevel kotak)

# ======================================================================
# ATAP + LIS EMAS
# ======================================================================
# Atap: 20,0 x 16,0 x 0,14, puncak z 4,99 (0,01 di bawah puncak dinding
# agar tidak koplanar). Sisi tegak atap tersembunyi di balik lis emas
# (lis z 4,86-5,0, tebal 0,14) -> tidak ada lagi muka tegak yang kena
# bayangan dan render hitam di tepi atap.
_atap = box("SR_Atap", (0, 0, 4.92), (20.0, 16.0, 0.14), M_KREM, coll, bevel_w=0.0)
_atap.data.materials.append(M_EMAS)
for _p in _atap.data.polygons:
    if abs(_p.normal.x) > 0.5 or abs(_p.normal.y) > 0.5:
        _p.material_index = 1
# lis emas sekeliling tepi atap (z 4,9)
box("SR_LisAtap_Timur", (10.05, 0, 4.93), (0.14, 16.3, 0.14), M_EMAS, coll)
box("SR_LisAtap_Barat", (-10.05, 0, 4.93), (0.14, 16.3, 0.14), M_EMAS, coll)
box("SR_LisAtap_Utara", (0, 8.05, 4.93), (20.3, 0.14, 0.14), M_EMAS, coll)
box("SR_LisAtap_Selatan", (0, -8.05, 4.93), (20.3, 0.14, 0.14), M_EMAS, coll)

# ======================================================================
# KUBAH UTAMA + KUBAH KECIL
# ======================================================================
# Drum kubah (krem, r 4,25, z 5,0..5,4)
cyl("SR_DrumKubah", (0, 0, 5.2), 4.25, 0.4, M_KREM, coll, verts=48)
# Kubah bawang: lebar 9 m, tinggi 6 m, alas z 5,0, puncak 11,0
lathe("SR_KubahUtama", onion_profile(9.0, 6.0), 40, M_ZAMRUD, coll, loc=(0, 0, 5.0))
# Finial kubah utama: tiang 1 m + bola + sabit
cyl("SR_FinialTiang", (0, 0, 11.5), 0.04, 1.0, M_EMAS, coll, verts=12)
sphere("SR_FinialBola", (0, 0, 11.45), 0.12, M_EMAS, coll)
crescent("SR_SabitKubah", 0.65, (0, 0, 12.7), M_EMAS, coll)

# 4 kubah kecil di sudut atap (lebar 1,8 m, tinggi 2,8 m)
for (kx, ky) in ((-8.5, -6.5), (8.5, -6.5), (-8.5, 6.5), (8.5, 6.5)):
    lathe("SR_KubahKecil", onion_profile(1.8, 2.8), 24, M_ZAMRUD, coll, loc=(kx, ky, 5.0))
    cyl("SR_FinialKecil_Tiang", (kx, ky, 8.075), 0.03, 0.55, M_EMAS, coll, verts=8)
    sphere("SR_FinialKecil_Bola", (kx, ky, 8.05), 0.08, M_EMAS, coll, seg=16)
    crescent("SR_SabitKecil", 0.25, (kx, ky, 8.65), M_EMAS, coll)

# ======================================================================
# MENARA (sudut tenggara, pusat 10,85 / -8,85)
# ======================================================================
MX, MY = 10.85, -8.85
box("SR_MenaraAlas", (MX, MY, 0.3), (2.4, 2.4, 0.6), M_BATU, coll, bevel_w=0.03)
# Badan silinder r 0,85, z 0,6..12,4
cyl("SR_MenaraBadan", (MX, MY, 6.5), 0.85, 11.8, M_KREM, coll, verts=32)
# Balkon di z 9 m: piringan r 1,25 + pagar emas (torus + tiang)
cyl("SR_MenaraBalkon", (MX, MY, 9.0), 1.25, 0.35, M_KREM, coll, verts=32)
bpy.ops.mesh.primitive_torus_add(major_radius=1.18, minor_radius=0.035,
                                 major_segments=32, minor_segments=8,
                                 location=(MX, MY, 9.65))
o = bpy.context.object
o.name = "SR_MenaraPagar"
o.data.materials.append(M_EMAS)
link(o, coll)
for i in range(8):
    a = 2 * math.pi * i / 8
    cyl("SR_MenaraPagarTiang", (MX + 1.18 * math.cos(a), MY + 1.18 * math.sin(a), 9.4),
        0.03, 0.5, M_EMAS, coll, verts=8)
# Tutup kubah zamrud: lebar 1,6 m, tinggi 1,6 m, alas 12,4, puncak 14,0
lathe("SR_TutupMenara", onion_profile(1.6, 1.6), 24, M_ZAMRUD, coll, loc=(MX, MY, 12.4))
cyl("SR_FinialMenara_Tiang", (MX, MY, 14.45), 0.035, 0.9, M_EMAS, coll, verts=8)
sphere("SR_FinialMenara_Bola", (MX, MY, 14.4), 0.09, M_EMAS, coll, seg=16)
crescent("SR_SabitMenara", 0.42, (MX, MY, 15.35), M_EMAS, coll)

# ======================================================================
# BLOK PORTAL (muka timur, Y -3..3, X 10..10,6, z 0,5..8)
# ======================================================================
portal = box("SR_BlokPortal", (10.2, 0, 4.25), (0.8, 6, 7.5), M_KREM, coll)
# Bukaan lengkung portal: lebar 4,8 m, alas 0,5, puncak 6,9
pts_portal = arch_poly(4.8, 0.5, 4.5, 6.9)
cutter_portal = extrude_poly("CutterPortal", pts_portal, "YZ", 9.6, 1.2, None, coll)
bool_cut(portal, cutter_portal)
# Lis emas di atas blok portal
box("SR_LisPortal", (10.3, 0, 8.03), (0.8, 6.4, 0.12), M_EMAS, coll)

# --- Plakat (kotak zamrud + tekstur Arab, muka X=10,62, z 7,1..7,8) ---
bpy.ops.mesh.primitive_cube_add(location=(10.62, 0, 7.45))
o = bpy.context.object
o.name = "SR_Plakat"
o.dimensions = (0.1, 5.0, 0.7)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
o.data.materials.append(M_PLAKAT)
# UV: kubus default hanya memetakan 1/16 tekstur per muka -> teks Arab
# tercrop jadi garis. Petakan ulang muka +X (depan) ke seluruh tekstur:
# U = sepanjang Y (selatan->utara = kiri->kanan dari depan), V = sepanjang Z.
_uv = o.data.uv_layers.active.data
for _p in o.data.polygons:
    if _p.normal.x > 0.9:
        for _li in _p.loop_indices:
            _v = o.data.vertices[o.data.loops[_li].vertex_index].co
            _uv[_li].uv = ((_v.y + 2.5) / 5.0, (_v.z + 0.35) / 0.7)
link(o, coll)

# --- Pintu jati dua daun (X 10,2, z 0,5..3,1, total 4 m) ---
box("SR_Pintu_Kiri", (10.2, -0.99, 1.8), (0.06, 1.95, 2.6), M_JATI, coll)
box("SR_Pintu_Kanan", (10.2, 0.99, 1.8), (0.06, 1.95, 2.6), M_JATI, coll)
box("SR_Pintu_GarisTengah", (10.16, 0, 1.8), (0.04, 0.05, 2.6), M_EMAS, coll)
sphere("SR_Pintu_KnobKiri", (10.14, -0.15, 1.8), 0.06, M_EMAS, coll, seg=16)
sphere("SR_Pintu_KnobKanan", (10.14, 0.15, 1.8), 0.06, M_EMAS, coll, seg=16)
# Kisi di atas pintu (panel lengkung z 3,1..6,9, X 10,35)
pts_kisi_portal = arch_poly(4.8, 3.1, 4.5, 6.9)
extrude_poly("SR_KisiPortal", pts_kisi_portal, "YZ", 10.32, 0.06, M_KISI, coll, uv_scale=1.2)
# Ambang emas di bawah kisi (z 3,1)
box("SR_AmbangKisi", (10.35, 0, 3.1), (0.1, 4.8, 0.08), M_EMAS, coll)
# Trim lengkung emas di sekeliling bukaan portal (muka depan)
arch_tube("SR_TrimPortal", 10.62, 0, 4.8, 0.5, 4.5, 6.9, "Y", M_EMAS, coll, r=0.06)

# ======================================================================
# SERAMBI (muka timur, X 10..13, Y -3..3, atap z 3,0..3,3)
# ======================================================================
box("SR_SerambiLantai", (11.6, 0, 0.25), (3.4, 6.4, 0.5), M_BATU, coll, bevel_w=0.03)
box("SR_SerambiAtap", (11.6, 0, 3.15), (3.6, 6.8, 0.3), M_KREM, coll, bevel_w=0.03)
# Lis emas tepi atap serambi (depan + samping)
box("SR_LisSerambi_Depan", (13.42, 0, 3.15), (0.1, 6.8, 0.3), M_EMAS, coll)
box("SR_LisSerambi_Utara", (11.6, 3.42, 3.15), (3.6, 0.1, 0.3), M_EMAS, coll)
box("SR_LisSerambi_Selatan", (11.6, -3.42, 3.15), (3.6, 0.1, 0.3), M_EMAS, coll)
# 2 tiang ramping (0,4 x 0,4) di Y=+-1, X=12,9, z 0,5..3,0
for ty in (-1.0, 1.0):
    box("SR_TiangSerambi", (12.9, ty, 1.75), (0.4, 0.4, 2.5), M_KREM, coll, bevel_w=0.03)
    box("SR_TiangSerambi_Kepala", (12.9, ty, 2.96), (0.52, 0.52, 0.08), M_EMAS, coll)
    box("SR_TiangSerambi_Alas", (12.9, ty, 0.55), (0.52, 0.52, 0.1), M_BATU, coll)
# Tiang ujung (Y=+-2,9)
for ty in (-2.9, 2.9):
    box("SR_TiangUjung", (12.9, ty, 1.75), (0.3, 0.3, 2.5), M_KREM, coll, bevel_w=0.03)
# 3 lengkung emas di muka depan serambi (X=13,0)
for cy0 in (-2.0, 0.0, 2.0):
    arch_tube("SR_LengkungSerambi", 13.0, cy0, 1.9, 0.5, 1.75, 2.7, "Y", M_EMAS, coll, r=0.05)

# --- 3 anak tangga batu di depan serambi ---
box("SR_Tangga1", (13.5, 0, 0.417), (0.6, 6.0, 0.167), M_BATU, coll, bevel_w=0.02)
box("SR_Tangga2", (14.1, 0, 0.25), (0.6, 6.6, 0.167), M_BATU, coll, bevel_w=0.02)
box("SR_Tangga3", (14.7, 0, 0.083), (0.6, 7.2, 0.167), M_BATU, coll, bevel_w=0.02)

# --- 2 pot tanaman di sisi tangga ---
for py in (-4.2, 4.2):
    cyl("SR_Pot", (13.6, py, 0.2), 0.25, 0.4, M_JATI, coll, verts=20)
    sphere("SR_Semak1", (13.6, py, 0.6), 0.3, M_HIJAU, coll, seg=16)
    sphere("SR_Semak2", (13.5, py + 0.1, 0.78), 0.22, M_HIJAU, coll, seg=16)

# ======================================================================
# TEMPAT WUDU (sisi selatan, ujung barat: X -9..-6, Y -8,8..-8)
# ======================================================================
box("SR_Wudu_Bak", (-7.5, -8.4, 0.45), (3.0, 0.8, 0.9), M_BATU, coll, bevel_w=0.03)
box("SR_Wudu_Tutup", (-7.5, -8.4, 0.95), (3.1, 0.9, 0.1), M_JATI, coll)
for tx in (-8.5, -7.5, -6.5):
    cyl("SR_Wudu_Kran", (tx, -8.4, 1.12), 0.04, 0.25, M_EMAS, coll, verts=10)
    cyl("SR_Wudu_KranMoncong", (tx, -8.28, 1.2), 0.03, 0.25, M_EMAS, coll,
        verts=10, rot=(math.radians(90), 0, 0))

# ======================================================================
# INTERIOR DASAR (lantai 18x14 di z 0,5)
# ======================================================================
box("SR_LantaiInterior", (0, 0, 0.5), (17.9, 13.9, 0.1), M_KREM_MUDA, coll)
# Mihrab: panel lengkung zamrud + trim emas di dinding barat (X=-9)
pts_mihrab = arch_poly(1.6, 0.55, 2.0, 3.0)
extrude_poly("SR_MihrabPanel", pts_mihrab, "YZ", -8.97, 0.06, M_ZAMRUD, coll)
arch_tube("SR_MihrabTrim", -8.9, 0, 1.6, 0.55, 2.0, 3.0, "Y", M_EMAS, coll, r=0.05)
box("SR_MihrabPanggung", (-8.65, 0, 0.625), (0.7, 1.8, 0.15), M_BATU, coll)
# Mimbar: 3 anak tangga jati di utara mihrab
box("SR_Mimbar1", (-8.6, 2.0, 0.8), (0.8, 1.2, 0.5), M_JATI, coll, bevel_w=0.02)
box("SR_Mimbar2", (-8.75, 2.0, 1.3), (0.5, 1.2, 0.5), M_JATI, coll, bevel_w=0.02)
box("SR_Mimbar3", (-8.9, 2.0, 1.8), (0.2, 1.2, 0.5), M_JATI, coll, bevel_w=0.02)
# 6 saf: garis emas di lantai
for sx in (-5, -3, -1, 1, 3, 5):
    box("SR_Saf", (sx, 0, 0.56), (0.06, 12, 0.02), M_EMAS, coll)
# Rak buku utara & selatan (rak jati + 3 baris kitab warna-warni)
rak_buku("SR_RakBuku_Utara", 0, 6.75, coll)
rak_buku("SR_RakBuku_Selatan", 0, -6.75, coll)
# Dampar santri: 4 bangku kayu rendah, sumbu utara-selatan,
# di lajur timur & barat — di luar garis saf (X +-5) dan jalur pintu (Y -2..2)
for (dx, dy) in ((7.3, 4.5), (7.3, -4.5), (-7.3, 4.5), (-7.3, -4.5)):
    dampar(f"SR_Dampar_{'T' if dx > 0 else 'B'}{'U' if dy > 0 else 'S'}", dx, dy, coll)

# ======================================================================
# STATISTIK + SIMPAN + EXPORT GLB
# ======================================================================
bpy.context.view_layer.objects.active = None
total_verts = total_tris = 0
for o in coll.objects:
    if o.type == "MESH":
        dg = bpy.context.evaluated_depsgraph_get()
        eo = o.evaluated_get(dg)
        me = eo.to_mesh()
        total_verts += len(me.vertices)
        total_tris += len(me.loop_triangles)
        eo.to_mesh_clear()
print("OBJEK:", len(coll.objects))
print("TOTAL VERTS (evaluated):", total_verts)
print("TOTAL TRIS (evaluated):", total_tris)

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print("BLEND disimpan:", OUT_BLEND)

bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format="GLB",
                          export_apply=True, export_yup=True)
print("GLB diekspor:", OUT_GLB, os.path.getsize(OUT_GLB), "byte")
print("SELESAI")
