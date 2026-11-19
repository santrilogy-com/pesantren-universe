#!/usr/bin/env python3
"""Santri PUTRA v2 BERWARNA — dibangun ulang parametrik dari clay v2 +
4 koreksi Mas (23:14 & 23:17 WIB 17 Nov 2026).

Koreksi yang diterapkan (MENGUBAH lembar konsep — dicatat di KONSEP-KARAKTER.md):
  1. PECI: kubah penuh/bulat (bukan piring datar), alas di z 0,93 membungkus
     kepala rapat — tidak melayang, tidak ada celah; alas di atas garis alis
     supaya alis tetap terlihat.
  2. SARUNG: dipanjangkan sampai MATA KAKI (hem z 0,055, dulu selutut 0,16),
     tetap SATU lembar tanpa belahan; sandal tetap terlihat di bawah hem.
  3. KOKO PANJANG gaya kurta: lengan panjang + badan sampai paha tengah
     (hem z 0,24), dipakai di luar sarung, menutupi pinggang.
  4. BAHU: lengan menyatu dengan badan — bola bahu di sendi + bevel sudut
     pada silinder lengan + lengan sedikit lebih tebal; bukan balok terpisah.
  5. WARNA dari palet lembar (Xam, setelah baca ulang lembar): koko #E8E8E8,
     zamrud #008062, emas #E2B955, kulit #FFC09F, sandal #4A3226.
     Sarung pakai tekstur batik_parang_rapi.png — parang diagonal RAPI
     (pita diagonal sejajar, bilah emas + titik mlinion), dibuat prosedural
     dengan numpy supaya tileable sempurna; tekstur lama batik_parang.png
     bilahnya tersebar acak dan terbaca seperti blob di render.

Dibangun ulang dari build_santri_putra_clay_v2.py (bukan patch file clay —
clay v2 tetap utuh di santri-putra-clay-v2.blend).
Output: santri-putra-v2-berwarna.blend (file BARU, jangan timpa clay).
Jalankan: blender -b --python build_santri_putra_v2_berwarna.py -- --out santri-putra-v2-berwarna.blend
Blender 4.5.16 headless. Budget < 30.000 tris.
"""
import bpy
import bmesh
import math
import os
import sys
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = argv[argv.index("--out") + 1] if "--out" in argv else "santri-putra-v2-berwarna.blend"
OUT = os.path.abspath(OUT)

# ------------------------------------------------------------------ ukuran
# Kepala tetap: puncak peci -> dagu = 0,34 m (dagu 0,68; puncak peci baru 1,022).
HEAD_H = 0.34          # puncak peci -> dagu
HEAD_R = 0.148
HEAD_CZ = 0.828
HEAD_SY = 0.92
NECK_Z0, NECK_Z1 = 0.63, 0.70
TORSO_Z0, TORSO_Z1 = 0.24, 0.68          # koko PANJANG: hem paha tengah
TORSO_R_BOT, TORSO_R_TOP = 0.195, 0.165  # bawah lebih lebar (menutup sarung)
SHOULDER_Z = 0.64
SARUNG_Z0, SARUNG_Z1 = 0.055, 0.44       # sarung MATA KAKI (hem 0,055)
SHOE_X = 0.085
ARM_X = 0.212
HAND_X = 0.215

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


def box(name, size, collection="PUTRA_V2", location=(0, 0, 0), rotation=(0, 0, 0)):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location, rotation)


def cylinder(name, radius, height, collection="PUTRA_V2", segments=32,
             radius_top=None, location=(0, 0, 0), scale=(1, 1, 1)):
    bm = bmesh.new()
    r2 = radius if radius_top is None else radius_top
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments,
                          radius1=radius, radius2=r2, depth=height)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location)


def sphere(name, radius, collection="PUTRA_V2", location=(0, 0, 0),
           u=24, v=12, scale=(1, 1, 1)):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=radius)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    return new_mesh_object(name, bm, collection, location)


def profile_spin(name, profile_xz, collection="PUTRA_V2", steps=32, location=(0, 0, 0)):
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
    + samping kepala."""
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


def torus_xz(name, major, minor, collection="PUTRA_V2_GELAP", location=(0, 0, 0),
             arc_deg=360, arc_start=0, ring_seg=32, tube_seg=10):
    """Torus (atau busur) pada bidang X-Z — menghadap -Y (wajah)."""
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


def bevel(ob, width=0.012, segments=2):
    """Bevel hanya pada rusuk tajam (>30 derajat) — tepi atas/bawah silinder
    jadi membulat (sambungan bahu halus), rusuk vertikal silinder tidak
    ikut (lebar bevel > jarak antar-segmen akan merusak silinder)."""
    b = ob.modifiers.new("Bevel", "BEVEL")
    b.width = width
    b.segments = segments
    b.limit_method = "ANGLE"
    b.angle_limit = math.radians(30)
    apply_all_modifiers(ob)
    return ob


def face_y(x, z):
    """Y permukaan depan kepala pada (x, z)."""
    nx, nz = x / HEAD_R, (z - HEAD_CZ) / HEAD_R
    v = 1.0 - nx * nx - nz * nz
    return -HEAD_R * HEAD_SY * math.sqrt(max(0.0, v))


def torso_r(z):
    """Radius X torso koko pada tinggi z (kerucut: bawah 0,195 -> atas 0,165)."""
    return TORSO_R_BOT - (z - TORSO_Z0) / (TORSO_Z1 - TORSO_Z0) * (TORSO_R_BOT - TORSO_R_TOP)


def cylindrical_uv(ob):
    """UV silinder untuk sarung: u = sudut keliling, v = tinggi (0..1).
    Dipakai supaya tekstur batik parang membungkus sarung dengan rapi."""
    me = ob.data
    bm = bmesh.new()
    bm.from_mesh(me)
    zs = [v.co.z for v in bm.verts]
    z0, z1 = min(zs), max(zs)
    uv_layer = bm.loops.layers.uv.new("UVMap")
    for f in bm.faces:
        for loop in f.loops:
            v = loop.vert.co
            u = math.atan2(v.y, v.x) / (2 * math.pi) + 0.5
            vv = (v.z - z0) / (z1 - z0) if z1 > z0 else 0.0
            loop[uv_layer].uv = (u, vv)
    bm.to_mesh(me)
    bm.free()
    return ob


# ------------------------------------------------------------------ material
def srgb2lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def hexcol(h):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    return (srgb2lin(r), srgb2lin(g), srgb2lin(b), 1.0)


def mat_flat(name, hexcode, rough=0.8, metallic=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hexcol(hexcode)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    return m


def mat_batik(name, img_path, rough=0.9):
    """Sarung batik parang: tekstur gambar (tileable) + repeat 3x keliling,
    2x vertikal — bilah parang seukuran di lembar."""
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = rough
    tc = nt.nodes.new("ShaderNodeTexCoord")
    mp = nt.nodes.new("ShaderNodeMapping")
    mp.inputs["Scale"].default_value = (3.0, 2.0, 1.0)
    im = nt.nodes.new("ShaderNodeTexImage")
    im.image = bpy.data.images.load(img_path)
    im.extension = "REPEAT"
    nt.links.new(tc.outputs["UV"], mp.inputs["Vector"])
    nt.links.new(mp.outputs["Vector"], im.inputs["Vector"])
    nt.links.new(im.outputs["Color"], bsdf.inputs["Base Color"])
    return m


def assign(ob, m):
    ob.data.materials.append(m)
    return ob


# ------------------------------------------------------------------ scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Palet lembar (Xam, baca ulang 23:14 WIB)
KULIT = mat_flat("Kulit_FFC09F", "#FFC09F", 0.65)
KOKO = mat_flat("Koko_E8E8E8", "#E8E8E8", 0.85)
PECI = mat_flat("Peci_Putih", "#F7F7F7", 0.75)
RAMBUT = mat_flat("Rambut_Hitam", "#1A1A1A", 0.9)
EMAS = mat_flat("Emas_E2B955", "#E2B955", 0.35, 0.4)
GELAP = mat_flat("Gelap_Kacamata", "#1F1F1F", 0.6)
SANDAL = mat_flat("Sandal_4A3226", "#4A3226", 0.85)
BATIK = mat_batik("Sarung_Batik",
                  "/home/hatch/workspace/pesantren-verse/blender-santri/karakter-baru/batik_parang_rapi.png",
                  0.9)

EYE_Z = 0.855
LENS_X = 0.061
LENS_R = 0.055

# ---- KEPALA -------------------------------------------------------
head = sphere("Kepala", HEAD_R, location=(0, 0, HEAD_CZ),
              scale=(1.0, HEAD_SY, 1.0))
assign(head, KULIT)
shade_smooth(head)

for s in (-1, 1):
    ear = sphere("Telinga_%s" % ("L" if s < 0 else "R"), 0.030,
                 location=(s * 0.148, 0, 0.839), scale=(0.45, 0.7, 1.0))
    assign(ear, KULIT)
    shade_smooth(ear)

# rambut PENDEK RAPI (sama seperti clay): cangkang lathe, muka depan dipotong
hair = profile_spin("Rambut", [(0.149, 0.800), (0.149, 0.860), (0.133, 0.900),
                               (0.111, 0.930), (0.088, 0.950), (0.071, 0.960),
                               (0.046, 0.970), (0.0, 0.978)], steps=96)
assign(hair, RAMBUT)
shade_smooth(hair)
cut_front(hair, ny_thresh=-0.5)

# PECI — KOREKSI 1: kubah PENUH (bukan piring). Alas z 0,93 membungkus kepala
# rapat (di atas garis alis 0,918 supaya alis tetap terlihat); naik 0,092
# dari alas ke puncak 1,022 — rasio kubah 0,80 (dulu 0,48, makanya piring).
peci = profile_spin("Peci", [(0.115, 0.930), (0.114, 0.945), (0.107, 0.962),
                             (0.092, 0.980), (0.068, 0.997), (0.038, 1.010),
                             (0.0, 1.022)])
assign(peci, PECI)
shade_smooth(peci)

# ---- WAJAH (sama seperti clay, tinggal warna) ----------------------
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    ly = face_y(LENS_X, EYE_Z) - 0.004
    lens = torus_xz("Kacamata_Lensa_%s" % side, LENS_R, 0.0055,
                    location=(s * LENS_X, ly, EYE_Z))
    assign(lens, GELAP)
    shade_smooth(lens)
    temple = box("Kacamata_Gagang_%s" % side, (0.008, 0.120, 0.010), "PUTRA_V2_GELAP",
                 location=(s * 0.135, -0.065, EYE_Z))
    assign(temple, GELAP)
    eye = sphere("Mata_%s" % side, 0.010, location=(s * LENS_X, face_y(LENS_X, EYE_Z) - 0.002, EYE_Z),
                 scale=(1.0, 0.5, 1.0), u=12, v=8)
    assign(eye, GELAP)
    brow = torus_xz("Alis_%s" % side, 0.036, 0.005, location=(s * LENS_X, face_y(LENS_X, 0.918) - 0.003, 0.918),
                    arc_deg=130, arc_start=25)
    assign(brow, GELAP)
bridge = box("Kacamata_Jembatan", (0.030, 0.010, 0.010), "PUTRA_V2_GELAP",
             location=(0, face_y(0, EYE_Z) - 0.004, EYE_Z))
assign(bridge, GELAP)

nose = sphere("Hidung", 0.0127, location=(0, face_y(0, 0.802) - 0.004, 0.802),
              scale=(0.85, 0.6, 1.0), u=12, v=8)
assign(nose, GELAP)
shade_smooth(nose)

smile = torus_xz("Senyum", 0.0296, 0.0044, location=(0, face_y(0, 0.759) - 0.003, 0.767),
                 arc_deg=130, arc_start=205)
assign(smile, GELAP)

# ---- LEHER + KOKO PANJANG (kurta, hem paha tengah) -----------------
neck = cylinder("Leher", 0.062, NECK_Z1 - NECK_Z0,
                location=(0, 0, (NECK_Z0 + NECK_Z1) / 2))
assign(neck, KULIT)
shade_smooth(neck)

# KOREKSI 3: torso koko PANJANG — dari bahu (0,68) sampai paha tengah (0,24),
# dipakai di LUAR sarung: radius bawah 0,195 > sarung di ketinggian itu.
torso = cylinder("Torso_Koko", TORSO_R_BOT, TORSO_Z1 - TORSO_Z0, radius_top=TORSO_R_TOP,
                 location=(0, 0, (TORSO_Z0 + TORSO_Z1) / 2), scale=(1.0, 0.75, 1.0))
assign(torso, KOKO)
shade_smooth(torso)

sh = sphere("Bahu", 0.165, location=(0, 0, 0.665), scale=(1.0, 0.75, 0.45))
assign(sh, KOKO)
shade_smooth(sh)

collar = cylinder("Kerah_Mandarin", 0.078, 0.035, radius_top=0.074,
                  location=(0, 0, 0.688))
assign(collar, KOKO)
shade_smooth(collar)

# Plakat panjang mengikuti kemiringan kerucut torso (miring -3,9 derajat),
# 4 kancing EMAS (seperti di lembar, kancingnya emas). Kancing menempel di
# MUKA PLAKAT (bukan di torso) supaya tidak tertelan plakat yang miring.
placket = box("Plakat_Kancing", (0.024, 0.008, 0.30), "PUTRA_V2",
              location=(0, -0.137, 0.49), rotation=(-0.068, 0, 0))
assign(placket, KOKO)


def placket_face_y(z):
    """Y muka depan plakat pada tinggi z (plakat miring -0,068 rad)."""
    return -0.141 - math.tan(0.068) * (0.49 - z)


for i, z in enumerate((0.615, 0.555, 0.495, 0.435)):
    btn = sphere("Kancing_%d" % (i + 1), 0.008,
                 location=(0, placket_face_y(z) - 0.001, z), scale=(1.0, 0.5, 1.0), u=12, v=8)
    assign(btn, EMAS)

# ---- LENGAN PANJANG — KOREKSI 4: menyatu dengan badan -------------
# Bola bahu di sendi menjembatani torso -> lengan; silinder lengan di-bevel
# supaya tepi atas/bawahnya membulat; lengan sedikit lebih tebal dari clay
# (lengan atas 0,058, lengan bawah 0,050) dan masuk sedikit ke dalam torso
# (x 0,212, tepi dalam 0,154 < radius torso 0,168 di bahu) — bukan tempelan.
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    shb = sphere("Bahu_%s" % side, 0.062, location=(s * 0.198, 0, 0.632),
                 scale=(1.0, 0.8, 1.0))
    assign(shb, KOKO)
    shade_smooth(shb)
    sleeve = cylinder("LenganAtas_Koko_%s" % side, 0.052, 0.17, radius_top=0.058,
                      location=(s * ARM_X, 0, 0.545))
    assign(sleeve, KOKO)
    bevel(sleeve, 0.012, 2)
    shade_smooth(sleeve)
    fore = cylinder("LenganBawah_Koko_%s" % side, 0.042, 0.18, radius_top=0.050,
                    location=(s * ARM_X, 0, 0.375))
    assign(fore, KOKO)
    bevel(fore, 0.012, 2)
    shade_smooth(fore)
    cuff = cylinder("Manset_%s" % side, 0.044, 0.035,
                    location=(s * ARM_X, 0, 0.27))
    assign(cuff, KOKO)
    shade_smooth(cuff)
    hand = sphere("Tangan_%s" % side, 0.045, location=(s * HAND_X, 0, 0.225),
                  scale=(0.9, 0.75, 1.25))
    assign(hand, KULIT)
    shade_smooth(hand)

# ---- SARUNG satu lembar SAMPAI MATA KAKI (koreksi 2) ---------------
sarung = cylinder("Sarung", 0.175, SARUNG_Z1 - SARUNG_Z0, radius_top=0.155,
                  location=(0, 0, (SARUNG_Z0 + SARUNG_Z1) / 2), scale=(1.0, 0.80, 1.0))
assign(sarung, BATIK)
shade_smooth(sarung)
cylindrical_uv(sarung)
waist = cylinder("Sarung_Pinggang", 0.158, 0.03,
                 location=(0, 0, 0.435), scale=(1.0, 0.80, 1.0))
assign(waist, BATIK)
shade_smooth(waist)
cylindrical_uv(waist)

# ---- BETIS + SANDAL (tetap; betis kini tersembunyi di balik sarung) --
for s in (-1, 1):
    side = "L" if s < 0 else "R"
    calf = cylinder("Betis_%s" % side, 0.042, 0.12,
                    location=(s * SHOE_X, 0, 0.11))
    assign(calf, KULIT)
    shade_smooth(calf)
    foot = box("Kaki_%s" % side, (0.080, 0.170, 0.035),
               location=(s * SHOE_X, -0.005, 0.030))
    assign(foot, KULIT)
    b = foot.modifiers.new("Bevel", "BEVEL")
    b.width = 0.010
    b.segments = 2
    apply_all_modifiers(foot)
    shade_smooth(foot)
    sole = box("Sandal_Sol_%s" % side, (0.090, 0.200, 0.012),
               location=(s * SHOE_X, -0.010, 0.006))
    assign(sole, SANDAL)
    for j, sy in enumerate((-0.05, 0.015)):
        strap = box("Sandal_Tali_%s_%d" % (side, j + 1), (0.088, 0.016, 0.010),
                    location=(s * SHOE_X, sy, 0.050))
        assign(strap, SANDAL)

# ------------------------------------------------------------------ hitung + simpan
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=OUT)

n_verts = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == "MESH")
n_tris = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == "MESH")
print("BERWARNA SELESAI:", OUT)
print("objek mesh:", sum(1 for o in bpy.data.objects if o.type == "MESH"))
print("verts:", n_verts, "tris:", n_tris, "(budget < 30000)")
top = max((o.matrix_world @ Vector(v)).z
          for o in bpy.data.objects if o.type == "MESH"
          for v in o.bound_box)
print("tinggi total (puncak peci): %.3f m | kepala %.3f m | proporsi %.2f kepala"
      % (top, HEAD_H, top / HEAD_H))
