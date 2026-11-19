#!/usr/bin/env python3
"""CLAY santri PUTRA v2 — Pesantren Universe (Tim Karakter: Kirana).

Tongkat pertama v2: clay putra SAJA (putri + detail/tekstur setelah clay ini
lolos verdict Mas). Bangun parametrik baru, gaya low-poly halus (satu bahasa
dengan Surau + lingkungan v2 Bima), BUKAN lanjut mesh blockout lama.

Sumber ukuran: lembar konsep v2 (KONSEP-KARAKTER.md + konsep-santri-putra.png,
diukur dari gambar, bukan kira-kira):
  - proporsi 3,4 kepala; kepala (dagu->ubun, tanpa peci) 0,28 m
  - total badan 0,96 m (ubun); peci menambah sampai ~0,995 m
  - kepala lebar 0,28 m; bahu/polo 0,32 m; sarung SATU lembar, hem selutut
  - wajah DATAR satu sistem (pelajaran Syumra): mata titik, alis tebal,
    hidung kecil, senyum tipis TERTUTUP. TANPA bola mata 3D / mulut merah /
    gigi / rambut helm.
  - peci BERKUBAH MENEMPEL (cacat lama: melayang ~0,025 m) -> alas peci
    ditanam 0,015 m ke dalam ubun.
  - lengan menggantung vertikal di sisi badan, BUKAN T-pose.
  - tangan mitten halus, tanpa jari.

CLAY = satu material matte abu-abu terang (roughness 0,9). Fitur wajah
(mata, alis, senyum, kacamata, peci, poni) geometri tipis terpisah dengan
abu-abu sedikit lebih gelap supaya terbaca di render clay.

Jalankan:
  blender -b --python build_santri_putra_clay.py -- --out santri-putra-clay.blend
Blender 4.5.16 headless. Budget < 30.000 tris.
"""
import bpy
import bmesh
import math
import os
import sys
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = argv[argv.index("--out") + 1] if "--out" in argv else "santri-putra-clay.blend"
OUT = os.path.abspath(OUT)

# ------------------------------------------------------------------ ukuran
HEAD_H = 0.28          # dagu -> ubun (tanpa peci)
HEAD_R = 0.14          # kepala: bola r 0,14
HEAD_CZ = 0.82         # pusat kepala (dagu 0,68 / ubun 0,96)
HEAD_SY = 0.92         # kepala sedikit pipih depan-belakang
NECK_Z0, NECK_Z1 = 0.63, 0.70
TORSO_Z0, TORSO_Z1 = 0.42, 0.68
SHOULDER_Z = 0.64
SARUNG_Z0, SARUNG_Z1 = 0.16, 0.44   # hem selutut (lutut ~0,20) -> waist
SHOE_X = 0.085
ARM_X = 0.20

# ------------------------------------------------------------------ util
def col(name):
    c = bpy.data.collections.get(name)
    if c is None:
        c = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(c)
    return c


def new_mesh_object(name, bm, collection, location=(0, 0, 0), rotation=(0, 0, 0)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    ob.location = location
    ob.rotation_euler = rotation
    col(collection).objects.link(ob)
    return ob


def box(name, size, collection="CLAY", location=(0, 0, 0), rotation=(0, 0, 0)):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location, rotation)


def cylinder(name, radius, height, collection="CLAY", segments=32,
             radius_top=None, location=(0, 0, 0), scale=(1, 1, 1)):
    bm = bmesh.new()
    r2 = radius if radius_top is None else radius_top
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=radius, radius2=r2, depth=height)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location)


def sphere(name, radius, collection="CLAY", location=(0, 0, 0),
           u=24, v=12, scale=(1, 1, 1)):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=radius)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location)


def profile_spin(name, profile_xz, collection="CLAY", steps=32, location=(0, 0, 0)):
    """Lathe profil (radius, z) mengelilingi sumbu Z: kubah rambut, peci."""
    bm = bmesh.new()
    verts = [bm.verts.new((r, 0, z)) for r, z in profile_xz]
    edges = [bm.edges.new((verts[i], verts[i + 1])) for i in range(len(verts) - 1)]
    bmesh.ops.spin(bm, geom=verts + edges, cent=(0, 0, 0), axis=(0, 0, 1),
                   angle=math.radians(360), steps=steps, use_merge=True)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return new_mesh_object(name, bm, collection, location)


def torus_xz(name, major, minor, collection="CLAY_DARK", location=(0, 0, 0),
             arc_deg=360, arc_start=0, ring_seg=32, tube_seg=10):
    """Torus (atau busur) pada bidang X-Z — menghadap -Y (wajah).
    arc diukur dari sumbu +X ke arah +Z: 25..155 = busur atas (alis),
    205..335 = busur bawah (senyum)."""
    bm = bmesh.new()
    n = max(4, int(ring_seg * arc_deg / 360.0))
    grid = []
    for i in range(n + 1):
        th = math.radians(arc_start + arc_deg * i / n)
        cx, cz = major * math.cos(th), major * math.sin(th)
        row = []
        for j in range(tube_seg):
            ph = 2 * math.pi * j / tube_seg
            x = cx + minor * math.cos(ph) * math.cos(th)
            y = minor * math.sin(ph)
            z = cz + minor * math.cos(ph) * math.sin(th)
            row.append(bm.verts.new((x, y, z)))
        grid.append(row)
    for i in range(n):
        for j in range(tube_seg):
            a, b = grid[i][j], grid[i][j + 1] if j + 1 < tube_seg else grid[i][0]
            c, d = grid[i + 1][j], grid[i + 1][j + 1] if j + 1 < tube_seg else grid[i + 1][0]
            bm.faces.new((a, b, d, c))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return new_mesh_object(name, bm, collection, location)


def shade_smooth(ob, sharp_angle=math.radians(35)):
    me = ob.data
    bm = bmesh.new()
    bm.from_mesh(me)
    for f in bm.faces:
        f.smooth = True
    for e in bm.edges:
        if len(e.link_faces) == 2:
            e.smooth = e.calc_face_angle(0.0) <= sharp_angle
    bm.to_mesh(me)
    bm.free()
    return ob


def apply_all_modifiers(ob):
    dg = bpy.context.evaluated_depsgraph_get()
    eo = ob.evaluated_get(dg)
    me = bpy.data.meshes.new_from_object(eo)
    old = ob.data
    ob.data = me
    ob.modifiers.clear()
    if old.users == 0:
        bpy.data.meshes.remove(old)
    return ob


def face_y(x, z):
    """Y permukaan depan kepala pada (x, z). Kepala = bola r 0,14,
    pusat (0,0,0,82), skala Y 0,92. Negatif = menghadap -Y."""
    nx, nz = x / HEAD_R, (z - HEAD_CZ) / HEAD_R
    v = 1.0 - nx * nx - nz * nz
    return -HEAD_R * HEAD_SY * math.sqrt(max(0.0, v))


def mat(name, grey, rough=0.9):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (grey, grey, grey, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = 0.0
    return m


def assign(ob, m):
    ob.data.materials.append(m)
    return ob


# ------------------------------------------------------------------ scene
bpy.ops.wm.read_factory_settings(use_empty=True)
CLAY = mat("Clay_Terang", 0.78)
DARK = mat("Clay_Gelap", 0.42)
EYE_Z = 0.845          # garis mata
LENS_X = 0.058         # pusat lensa kiri/kanan
LENS_R = 0.052

# ---- KEPALA -------------------------------------------------------
head = sphere("Kepala", HEAD_R, location=(0, 0, HEAD_CZ),
              scale=(1.0, HEAD_SY, 1.0))
assign(head, CLAY)
shade_smooth(head)

# telinga: pipih, di garis mata
for s in (-1, 1):
    ear = sphere("Telinga_%s" % ("L" if s < 0 else "R"), 0.030,
                 location=(s * 0.138, 0, 0.83), scale=(0.45, 0.7, 1.0))
    assign(ear, CLAY)
    shade_smooth(ear)

# rambut: kubah lathe menutup ubun + belakang kepala (di bawah peci).
# Profil mengikuti bola kepala + 0,004, dari z 0,86 (pelipis) ke ubun 0,962.
hair = profile_spin("Rambut", [(0.144, 0.860), (0.143, 0.900), (0.130, 0.930),
                               (0.100, 0.950), (0.055, 0.960), (0.0, 0.962)])
assign(hair, DARK)
shade_smooth(hair)

# poni lurus: 5 helai kotak membulat di dahi (z 0,885-0,935), menempel
# permukaan kepala; helai tengah paling panjang.
for i, dx in enumerate((-0.088, -0.044, 0.0, 0.044, 0.088)):
    h = 0.052 if i == 2 else (0.048 if i in (1, 3) else 0.042)
    y = face_y(dx, 0.905) - 0.004
    strand = box("Poni_%d" % i, (0.036, 0.016, h), "CLAY_DARK",
                 location=(dx, y, 0.905), rotation=(math.radians(-8), 0, 0))
    assign(strand, DARK)
    b = strand.modifiers.new("Bevel", "BEVEL")
    b.width = 0.006
    b.segments = 2
    apply_all_modifiers(strand)
    shade_smooth(strand)

# peci putih BERKUBAH MENEMPEL: alas z 0,945 = 0,015 DI BAWAH ubun 0,96
# (ditanam, tidak melayang), kubah sampai 0,995.
peci = profile_spin("Peci", [(0.115, 0.945), (0.114, 0.960), (0.105, 0.975),
                             (0.080, 0.988), (0.040, 0.995), (0.0, 0.996)])
assign(peci, DARK)
shade_smooth(peci)

# ---- WAJAH (geometri tipis gelap, di permukaan kepala) -------------
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    ly = face_y(LENS_X, EYE_Z) - 0.004
    # kacamata: cincin torus besar + gagang ke telinga + jembatan
    lens = torus_xz("Kacamata_Lensa_%s" % side, LENS_R, 0.0065,
                    location=(s * LENS_X, ly, EYE_Z))
    assign(lens, DARK)
    shade_smooth(lens)
    temple = box("Kacamata_Gagang_%s" % side, (0.008, 0.110, 0.010), "CLAY_DARK",
                 location=(s * 0.118, -0.062, EYE_Z))
    assign(temple, DARK)
    # mata: titik kecil di dalam lensa, menempel permukaan wajah
    eye = sphere("Mata_%s" % side, 0.0095, location=(s * LENS_X, face_y(LENS_X, EYE_Z) - 0.002, EYE_Z),
                 scale=(1.0, 0.5, 1.0), u=12, v=8)
    assign(eye, DARK)
    # alis tebal: busur atas lensa
    brow = torus_xz("Alis_%s" % side, 0.034, 0.005, location=(s * LENS_X, face_y(LENS_X, 0.905) - 0.003, 0.905),
                    arc_deg=130, arc_start=25)
    assign(brow, DARK)
bridge = box("Kacamata_Jembatan", (0.030, 0.010, 0.010), "CLAY_DARK",
             location=(0, face_y(0, EYE_Z) - 0.004, EYE_Z))
assign(bridge, DARK)

# hidung kecil: tonjolan membulat
nose = sphere("Hidung", 0.012, location=(0, face_y(0, 0.795) - 0.004, 0.795),
              scale=(0.85, 0.6, 1.0), u=12, v=8)
assign(nose, DARK)
shade_smooth(nose)

# senyum tipis TERTUTUP: busur bawah (bentuk U), garis tipis
smile = torus_xz("Senyum", 0.028, 0.0042, location=(0, face_y(0, 0.755) - 0.003, 0.762),
                 arc_deg=130, arc_start=205)
assign(smile, DARK)

# ---- LEHER + BADAN ------------------------------------------------
neck = cylinder("Leher", 0.062, NECK_Z1 - NECK_Z0,
                location=(0, 0, (NECK_Z0 + NECK_Z1) / 2))
assign(neck, CLAY)
shade_smooth(neck)

torso = cylinder("Torso_Polo", 0.175, TORSO_Z1 - TORSO_Z0, radius_top=0.165,
                 location=(0, 0, (TORSO_Z0 + TORSO_Z1) / 2), scale=(1.0, 0.75, 1.0))
assign(torso, CLAY)
shade_smooth(torso)

# bahu membulat: elipsoid pipih di puncak torso
sh = sphere("Bahu", 0.165, location=(0, 0, 0.665), scale=(1.0, 0.75, 0.45))
assign(sh, CLAY)
shade_smooth(sh)

# kerah polo: cincin pipih di leher + dua lipatan kerah di depan
collar = torus_xz("Kerah", 0.072, 0.013, location=(0, 0, 0.685),
                  arc_deg=360, ring_seg=32, tube_seg=8)
collar.scale = (1.0, 1.0, 0.55)
assign(collar, CLAY)
shade_smooth(collar)
for s in (-1, 1):
    flap = box("Kerah_Lipat_%s" % ("L" if s < 0 else "R"), (0.055, 0.012, 0.035),
               location=(s * 0.045, -0.118, 0.662),
               rotation=(math.radians(18), 0, math.radians(s * -28)))
    assign(flap, CLAY)

# bukaan V + 3 kancing (tonjolan kecil) di tengah dada
for s in (-1, 1):
    v = box("BukaanV_%s" % ("L" if s < 0 else "R"), (0.010, 0.008, 0.075),
            location=(s * 0.016, -0.128, 0.635),
            rotation=(0, 0, math.radians(s * 22)))
    assign(v, DARK)
for i, z in enumerate((0.625, 0.595, 0.565)):
    btn = sphere("Kancing_%d" % (i + 1), 0.008,
                 location=(0, -0.130, z), scale=(1.0, 0.5, 1.0), u=12, v=8)
    assign(btn, DARK)

# ---- LENGAN menggantung vertikal ----------------------------------
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    sleeve = cylinder("LenganAtas_%s" % side, 0.058, 0.16, radius_top=0.055,
                      location=(s * ARM_X, 0, 0.575))
    assign(sleeve, CLAY)
    shade_smooth(sleeve)
    fore = cylinder("LenganBawah_%s" % side, 0.033, 0.20, radius_top=0.030,
                    location=(s * ARM_X, 0, 0.40))
    assign(fore, CLAY)
    shade_smooth(fore)
    hand = sphere("Tangan_%s" % side, 0.045, location=(s * ARM_X, 0, 0.255),
                  scale=(0.9, 0.75, 1.25))
    assign(hand, CLAY)
    shade_smooth(hand)

# ---- SARUNG satu lembar (tanpa belahan kaki) ----------------------
sarung = cylinder("Sarung", 0.175, SARUNG_Z1 - SARUNG_Z0, radius_top=0.155,
                  location=(0, 0, (SARUNG_Z0 + SARUNG_Z1) / 2), scale=(1.0, 0.80, 1.0))
assign(sarung, CLAY)
shade_smooth(sarung)
waist = cylinder("Sarung_Pinggang", 0.158, 0.03,
                 location=(0, 0, 0.435), scale=(1.0, 0.80, 1.0))
assign(waist, CLAY)
shade_smooth(waist)

# ---- KAOS KAKI + SEPATU -------------------------------------------
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    sock = cylinder("KaosKaki_%s" % side, 0.042, 0.12,
                    location=(s * SHOE_X, 0, 0.11))
    assign(sock, CLAY)
    shade_smooth(sock)
    shoe = box("Sepatu_%s" % side, (0.085, 0.160, 0.055),
               location=(s * SHOE_X, -0.010, 0.028))
    assign(shoe, CLAY)
    b = shoe.modifiers.new("Bevel", "BEVEL")
    b.width = 0.016
    b.segments = 2
    apply_all_modifiers(shoe)
    shade_smooth(shoe)
    sole = box("Sepatu_Sol_%s" % side, (0.090, 0.170, 0.014),
               location=(s * SHOE_X, -0.010, 0.007))
    assign(sole, DARK)

# ------------------------------------------------------------------ hitung + simpan
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=OUT)

n_verts = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == "MESH")
n_tris = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == "MESH")
print("CLAY SELESAI:", OUT)
print("objek mesh:", sum(1 for o in bpy.data.objects if o.type == "MESH"))
print("verts:", n_verts, "tris:", n_tris, "(budget < 30000)")
top = max((o.location.z + o.dimensions.z / 2) for o in bpy.data.objects if o.type == "MESH")
print("tinggi total (puncak peci): %.3f m | kepala %.3f m | proporsi %.2f kepala"
      % (top, HEAD_H, top / HEAD_H))
