#!/usr/bin/env python3
"""CLAY santri PUTRA v2 — REVISI lembar baru (ACC Mas 22:47 WIB 17 Nov 2026).

Bangun parametrik dari lembar konsep-santri-putra.png REVISI (KONSEP-KARAKTER.md):
  - proporsi 3,0 kepala (metode baru: puncak peci -> dagu); kepala 0,34 m
  - koko PUTIH kerah tegak (mandarin) + kancing depan, lengan pendek
  - SANDAL coklat gelap (bukan sepatu); betis + kaki telanjang di bawah sarung
  - RAMBUT PENDEK RAPI ala santri — dahi TERLIHAT, tanpa poni lurus.
    Rambut hanya di belakang + samping kepala (cangkang lathe, muka depan
    dipotong); peci berkubah menempel di atasnya.
  - sarung SATU lembar tanpa belahan (sudah begitu di clay lama — dipertahankan)
  - sarung selutut seperti gambar (ACC apa adanya)
  - kacamata bundar besar; dari samping lensa tetap garis tipis vertikal
    (sama seperti tampak samping di lembar konsep) — tube lensa ditipiskan.
  - wajah DATAR: mata titik, alis tebal, hidung kecil, senyum tipis TERTUTUP.
  - lengan menggantung vertikal, tangan mitten halus, tanpa jari.

CLAY = satu material matte abu-abu terang (roughness 0,9). Fitur wajah
(mata, alis, senyum, kacamata, peci, rambut) geometri tipis terpisah dengan
abu-abu sedikit lebih gelap supaya terbaca di render clay.

ATURAN: render CLAY ini dulu untuk verdict Mas SEBELUM detail/tekstur.
Clay lama (polo kuning + sepatu + poni, 3,43 kepala) DIHENTIKAN dan disimpan
di santri-putra-clay.blend — tidak dipakai, tidak ditimpa.

Jalankan:
  blender -b --python build_santri_putra_clay_v2.py -- --out santri-putra-clay-v2.blend
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
# Metode baru (lembar revisi): kepala = puncak peci -> dagu = 0,34 m.
# Dagu 0,68; ubun 0,976; puncak peci 1,020 -> total 1,020 m = 3,0 kepala.
HEAD_H = 0.34          # puncak peci -> dagu
HEAD_R = 0.148         # kepala: bola r 0,148 (sedikit lebih besar dari lama)
HEAD_CZ = 0.828        # pusat kepala (dagu 0,68 / ubun 0,976)
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


def cut_front(ob, ny_thresh=-0.5):
    """Hapus muka-muka cangkang yang menghadap ke depan (normal Y < ambang):
    dipakai untuk rambut — dahi harus telanjang, rambut hanya di belakang
    + samping kepala. Mengembalikan (muka_sebelum, muka_sesudah, min_y)."""
    me = ob.data
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    n_before = len(bm.faces)
    doomed = [f for f in bm.faces if f.normal.y < ny_thresh]
    bmesh.ops.delete(bm, geom=doomed, context="FACES")
    bm.to_mesh(me)
    bm.free()
    min_y = min((v.co.y for v in me.vertices), default=0.0)
    print("CUT %s: muka %d -> %d, min_y %.3f" % (ob.name, n_before,
                                                 len(me.polygons), min_y))
    return n_before, len(me.polygons), min_y


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
EYE_Z = 0.855          # garis mata (skala dari kepala baru)
LENS_X = 0.061         # pusat lensa kiri/kanan
LENS_R = 0.055

# ---- KEPALA -------------------------------------------------------
head = sphere("Kepala", HEAD_R, location=(0, 0, HEAD_CZ),
              scale=(1.0, HEAD_SY, 1.0))
assign(head, CLAY)
shade_smooth(head)

# telinga: pipih, di garis mata (sedikit keluar supaya tidak tertutup rambut)
for s in (-1, 1):
    ear = sphere("Telinga_%s" % ("L" if s < 0 else "R"), 0.030,
                 location=(s * 0.148, 0, 0.839), scale=(0.45, 0.7, 1.0))
    assign(ear, CLAY)
    shade_smooth(ear)

# rambut PENDEK RAPI: cangkang lathe mengikuti bola kepala + 0,004, dari
# tengkuk (z 0,80) sampai ubun (0,978). Muka depan DIPOTONG (cut_front)
# supaya dahi telanjang — tanpa poni lurus. Rambut tinggal di belakang +
# samping kepala (pelipis), seperti di lembar konsep.
hair = profile_spin("Rambut", [(0.149, 0.800), (0.149, 0.860), (0.133, 0.900),
                               (0.111, 0.930), (0.088, 0.950), (0.071, 0.960),
                               (0.046, 0.970), (0.0, 0.978)], steps=96)
assign(hair, DARK)
shade_smooth(hair)
cut_front(hair, ny_thresh=-0.5)

# peci putih BERKUBAH MENEMPEL: alas z 0,961 = 0,015 DI BAWAH ubun 0,976
# (ditanam, tidak melayang), kubah sampai 1,020.
peci = profile_spin("Peci", [(0.122, 0.961), (0.121, 0.976), (0.111, 0.991),
                             (0.085, 1.004), (0.042, 1.011), (0.0, 1.020)])
assign(peci, DARK)
shade_smooth(peci)

# ---- WAJAH (geometri tipis gelap, di permukaan kepala) -------------
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    ly = face_y(LENS_X, EYE_Z) - 0.004
    # kacamata: cincin torus besar + gagang ke telinga + jembatan
    # (tube lensa ditipiskan supaya dari samping tidak jadi batang tebal)
    lens = torus_xz("Kacamata_Lensa_%s" % side, LENS_R, 0.0055,
                    location=(s * LENS_X, ly, EYE_Z))
    assign(lens, DARK)
    shade_smooth(lens)
    temple = box("Kacamata_Gagang_%s" % side, (0.008, 0.120, 0.010), "CLAY_DARK",
                 location=(s * 0.135, -0.065, EYE_Z))
    assign(temple, DARK)
    # mata: titik kecil di dalam lensa, menempel permukaan wajah
    eye = sphere("Mata_%s" % side, 0.010, location=(s * LENS_X, face_y(LENS_X, EYE_Z) - 0.002, EYE_Z),
                 scale=(1.0, 0.5, 1.0), u=12, v=8)
    assign(eye, DARK)
    # alis tebal: busur atas lensa (di dahi telanjang, di atas garis mata)
    brow = torus_xz("Alis_%s" % side, 0.036, 0.005, location=(s * LENS_X, face_y(LENS_X, 0.918) - 0.003, 0.918),
                    arc_deg=130, arc_start=25)
    assign(brow, DARK)
bridge = box("Kacamata_Jembatan", (0.030, 0.010, 0.010), "CLAY_DARK",
             location=(0, face_y(0, EYE_Z) - 0.004, EYE_Z))
assign(bridge, DARK)

# hidung kecil: tonjolan membulat
nose = sphere("Hidung", 0.0127, location=(0, face_y(0, 0.802) - 0.004, 0.802),
              scale=(0.85, 0.6, 1.0), u=12, v=8)
assign(nose, DARK)
shade_smooth(nose)

# senyum tipis TERTUTUP: busur bawah (bentuk U), garis tipis
smile = torus_xz("Senyum", 0.0296, 0.0044, location=(0, face_y(0, 0.759) - 0.003, 0.767),
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

# kerah TEGAK koko (mandarin): pita silinder pendek mengelilingi leher
collar = cylinder("Kerah_Mandarin", 0.078, 0.035, radius_top=0.074,
                  location=(0, 0, 0.688))
assign(collar, CLAY)
shade_smooth(collar)

# lajur kancing depan (plakat tipis) + 3 kancing di tengah dada
placket = box("Plakat_Kancing", (0.022, 0.008, 0.12), "CLAY",
              location=(0, -0.128, 0.60))
assign(placket, CLAY)
for i, z in enumerate((0.625, 0.595, 0.565)):
    btn = sphere("Kancing_%d" % (i + 1), 0.008,
                 location=(0, -0.132, z), scale=(1.0, 0.5, 1.0), u=12, v=8)
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

# ---- BETIS + SANDAL (bukan sepatu) ----------------------------------
# Betis telanjang di bawah hem sarung; kaki di atas sol sandal tipis;
# 2 tali melintang di atas punggung kaki.
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    calf = cylinder("Betis_%s" % side, 0.042, 0.12,
                    location=(s * SHOE_X, 0, 0.11))
    assign(calf, CLAY)
    shade_smooth(calf)
    foot = box("Kaki_%s" % side, (0.080, 0.170, 0.035),
               location=(s * SHOE_X, -0.005, 0.030))
    assign(foot, CLAY)
    b = foot.modifiers.new("Bevel", "BEVEL")
    b.width = 0.010
    b.segments = 2
    apply_all_modifiers(foot)
    shade_smooth(foot)
    sole = box("Sandal_Sol_%s" % side, (0.090, 0.200, 0.012),
               location=(s * SHOE_X, -0.010, 0.006))
    assign(sole, DARK)
    for j, sy in enumerate((-0.05, 0.015)):
        strap = box("Sandal_Tali_%s_%d" % (side, j + 1), (0.088, 0.016, 0.010),
                    location=(s * SHOE_X, sy, 0.050))
        assign(strap, DARK)

# ------------------------------------------------------------------ hitung + simpan
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=OUT)

n_verts = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == "MESH")
n_tris = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == "MESH")
print("CLAY SELESAI:", OUT)
print("objek mesh:", sum(1 for o in bpy.data.objects if o.type == "MESH"))
print("verts:", n_verts, "tris:", n_tris, "(budget < 30000)")
# tinggi NYATA dari bounding box (lathe ber-origin 0,0,0 — location.z +
# dimensions.z/2 salah untuknya, seperti di skrip lama)
top = max((o.matrix_world @ Vector(v)).z
          for o in bpy.data.objects if o.type == "MESH"
          for v in o.bound_box)
print("tinggi total (puncak peci): %.3f m | kepala %.3f m | proporsi %.2f kepala"
      % (top, HEAD_H, top / HEAD_H))
