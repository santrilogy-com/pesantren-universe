# Bima — Kyai chibi vinyl-toy di Blender dari NOL
# Dibangun murni dari skrip Python (Blender 4.0.2, headless).
# Sculpt dilakukan lewat deformasi vertex matematis (falloff proporsional,
# setara brush Grab/Inflate/Smooth) + Subdivision Surface — deterministik,
# bukan stroke brush interaktif (tidak bisa di headless).
# Referensi gaya: ~/workspace/user/files/1002026799_0_mpsg.jpg
# Identitas Kyai: serban navy, jubah putih, jenggot.
import bpy, bmesh, math, random
from mathutils import Vector
from math import sin, cos, pi, sqrt

OUT = "/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai-blender"
random.seed(20261121)

# ---------- reset scene ----------
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.eevee.taa_render_samples = 64
scene.eevee.use_soft_shadows = True
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = False

# ---------- helpers ----------
def _lin(c):
    """sRGB (nilai sampling dari foto) -> linear (ruang warna Blender)."""
    return tuple(((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92
                 for v in c)

def mat_principled(name, rgb, roughness=0.4, coat=0.0, coat_rough=0.2,
                   metallic=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*_lin(rgb), 1.0)
    bs.inputs["Roughness"].default_value = roughness
    bs.inputs["Metallic"].default_value = metallic
    if alpha < 1.0:
        bs.inputs["Alpha"].default_value = alpha
    # Blender 4.0 Principled: Coat weight / Coat roughness
    try:
        bs.inputs["Coat weight"].default_value = coat
        bs.inputs["Coat roughness"].default_value = coat_rough
    except Exception:
        pass
    return m

def set_mat(obj, m):
    obj.data.materials.append(m)

def smooth_shade(obj):
    for p in obj.data.polygons:
        p.use_smooth = True

def subsurf(obj, levels=1):
    mod = obj.modifiers.new("Subdiv", 'SUBSURF')
    mod.subdivision_type = 'CATMULL_CLARK'
    mod.levels = levels
    mod.render_levels = levels
    return mod

def deform(obj, fn):
    """fn(v) -> None, v is a bmesh vert (edit v.co)."""
    me = obj.data
    bm = bmesh.new()
    bm.from_mesh(me)
    for v in bm.verts:
        fn(v)
    bm.to_mesh(me)
    bm.free()
    me.update()

def falloff(d, r):
    t = max(0.0, 1.0 - (d / r) ** 2)
    return t * t

def sstep(a, b, x):
    t = min(1.0, max(0.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)

def link_obj(obj, coll):
    coll.objects.link(obj)
    return obj

CHAR = bpy.data.collections.new("Kyai")
scene.collection.children.link(CHAR)

# ---------- materials (warna disampling dari referensi) ----------
SKIN   = mat_principled("Kulit",   (0.949, 0.812, 0.729), 0.35, coat=0.6, coat_rough=0.25)
SKIN2  = mat_principled("KulitGelap", (0.910, 0.706, 0.643), 0.40, coat=0.4)
NAVY   = mat_principled("SerbanNavy", (0.192, 0.235, 0.322), 0.45, coat=0.3, coat_rough=0.35)
NAVY2  = mat_principled("SerbanNavy2", (0.231, 0.278, 0.376), 0.50, coat=0.3)
BLACK  = mat_principled("KacamataHitam", (0.055, 0.055, 0.055), 0.25, coat=0.8, coat_rough=0.12)
LENS   = mat_principled("Lensa",   (0.030, 0.030, 0.032), 0.06, coat=1.0, coat_rough=0.05, metallic=0.25)
ROBE   = mat_principled("JubahPutih", (0.961, 0.945, 0.910), 0.50, coat=0.2, coat_rough=0.4)
BEARD  = mat_principled("Jenggot", (0.180, 0.129, 0.102), 0.65)
BLUSH  = mat_principled("Blush",   (0.937, 0.627, 0.549), 0.55)
MOUTH  = mat_principled("Mulut",   (0.227, 0.165, 0.133), 0.50)
BUTTON = mat_principled("Kancing", (0.545, 0.420, 0.271), 0.40, coat=0.4)
LEATHER= mat_principled("Sandal",  (0.420, 0.290, 0.184), 0.55)
BEAD   = mat_principled("Tasbih",  (0.545, 0.420, 0.271), 0.35, coat=0.6)

# ---------- KEPALA ----------
# bola 48x32, radius 0.55, pusat (0,0,1.52) — diameter 1.10 dari total ~2.2
bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=32, radius=0.55,
                                     location=(0, 0, 1.52))
head = bpy.context.active_object
head.name = "Kepala"
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
link_obj(head, CHAR); scene.collection.objects.unlink(head)

def head_shape(v):
    x, y, z = v.co
    # dagu menyempit: skala x mengecil ke bawah (bukan bola sempurna)
    t = sstep(1.52, 0.97, z)  # 0 di tengah, 1 di dagu
    v.co.x = x * (1.0 - 0.16 * t)
    v.co.y = y * (1.0 - 0.07 * t)
    # pipi menggembung
    for cx in (-0.26, 0.26):
        d = sqrt((x - cx) ** 2 + (y - 0.34) ** 2 + (z - 1.46) ** 2)
        f = falloff(d, 0.30)
        if f > 0:
            # dorong keluar sepanjang arah dari pusat pipi
            dirv = Vector((x - cx, y - 0.34, z - 1.46))
            if dirv.length > 1e-6:
                dirv.normalize()
                v.co += dirv * (0.035 * f)
    # dahi sedikit merata (serban menutup atas, tidak perlu menonjol)
    if z > 1.85 and y > 0.2:
        v.co.y -= 0.02 * sstep(1.85, 2.05, z)

deform(head, head_shape)
set_mat(head, SKIN)
smooth_shade(head)
subsurf(head, 2)

# ---------- HIDUNG (kecil, menempel, material sama) ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.045,
                                     location=(0, 0.525, 1.435))
nose = bpy.context.active_object
nose.name = "Hidung"
nose.scale = (0.9, 0.7, 1.1)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
link_obj(nose, CHAR); scene.collection.objects.unlink(nose)
set_mat(nose, SKIN)
smooth_shade(nose)

# ---------- TELINGA ----------
for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.09,
                                         location=(side * 0.52, -0.02, 1.52))
    ear = bpy.context.active_object
    ear.name = "TelingaR" if side > 0 else "TelingaL"
    ear.scale = (0.55, 0.9, 1.25)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(ear, CHAR); scene.collection.objects.unlink(ear)
    set_mat(ear, SKIN)
    smooth_shade(ear)

# ---------- BLUSH (cakram datar lembut, menempel di pipi) ----------
for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=0.06,
                                         location=(side * 0.315, 0.42, 1.40))
    bl = bpy.context.active_object
    bl.name = "BlushR" if side > 0 else "BlushL"
    bl.scale = (1.15, 0.25, 0.85)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(bl, CHAR); scene.collection.objects.unlink(bl)
    set_mat(bl, BLUSH)
    smooth_shade(bl)

# ---------- MATA DOT (untuk mode kacamata-off) ----------
EYES = []
for side in (-1, 1):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.034,
                                         location=(side * 0.165, 0.505, 1.585))
    e = bpy.context.active_object
    e.name = "MataR" if side > 0 else "MataL"
    e.scale = (0.85, 0.5, 1.25)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(e, CHAR); scene.collection.objects.unlink(e)
    set_mat(e, MOUTH)
    smooth_shade(e)
    EYES.append(e)
    # alis tipis: kotak melengkung kecil
    bpy.ops.mesh.primitive_cube_add(size=0.09, location=(side * 0.165, 0.52, 1.665))
    br = bpy.context.active_object
    br.name = "AlisR" if side > 0 else "AlisL"
    br.scale = (1.0, 0.18, 0.22)
    br.rotation_euler = (0.15, 0, side * -0.06)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(br, CHAR); scene.collection.objects.unlink(br)
    set_mat(br, MOUTH)
    subsurf(br, 1)
    smooth_shade(br)

# ---------- MULUT: dibangun di Part 2 sebagai busur Bezier (torus operator
# Blender 4.0 tidak punya parameter arc) ----------

print("PART1 OK — kepala, hidung, telinga, blush, mata, mulut")
bpy.ops.wm.save_as_mainfile(filepath=OUT + "/kyai-chibi.blend")

# ---------- PART 2: perbaikan posisi wajah + serban + kacamata + jenggot ----------
# Perbaikan: blush & mata sempat terlalu masuk ke dalam kepala — geser keluar.
for nm, ny in (("BlushL", 0.435), ("BlushR", 0.435),
               ("MataL", 0.52), ("MataR", 0.52)):
    o = bpy.data.objects.get(nm)
    if o:
        o.location.y = ny

# Mulut torus dari Part 1 orientasinya tebakan — ganti busur Bezier pasti.
if "Mulut" in bpy.data.objects:
    bpy.data.objects.remove(bpy.data.objects["Mulut"], do_unlink=True)

def bezier_tube(name, pts, y_plane, bevel, mat):
    cu = bpy.data.curves.new(name, 'CURVE')
    cu.dimensions = '3D'
    cu.bevel_depth = bevel
    cu.bevel_resolution = 2
    cu.resolution_u = 12
    sp = cu.splines.new('BEZIER')
    sp.bezier_points.add(len(pts) - 1)
    for bp, (x, z) in zip(sp.bezier_points, pts):
        bp.co = (x, y_plane, z)
        bp.handle_left_type = 'AUTO'
        bp.handle_right_type = 'AUTO'
    ob = bpy.data.objects.new(name, cu)
    CHAR.objects.link(ob)
    ob.data.materials.append(mat)
    return ob

# senyum tipis: busur "u" dangkal
bezier_tube("Mulut", [(-0.07, 1.335), (0.0, 1.31), (0.07, 1.335)],
            0.515, 0.008, MOUTH)

# ---------- SERBAN (lathe profil — rim terkontrol di z=1.68, di atas kacamata) ----------
prof = [(0.001, 2.18), (0.30, 2.16), (0.50, 2.05), (0.585, 1.92),
        (0.615, 1.80), (0.62, 1.74), (0.60, 1.70), (0.58, 1.68)]
verts = [(r, 0.0, z) for (r, z) in prof]
edges = [(i, i + 1) for i in range(len(verts) - 1)]
me = bpy.data.meshes.new("SerbanProf")
me.from_pydata(verts, edges, [])
me.update()
tur = bpy.data.objects.new("Serban", me)
CHAR.objects.link(tur)
mod = tur.modifiers.new("Screw", 'SCREW')
mod.axis = 'Z'
mod.angle = math.radians(360)
mod.steps = 64
mod.render_steps = 64
mod.use_smooth_shade = True
set_mat(tur, NAVY)
subsurf(tur, 1)
smooth_shade(tur)

# bibir rim serban (torus kecil membulatkan tepi bawah)
bpy.ops.mesh.primitive_torus_add(major_radius=0.575, minor_radius=0.025,
                                 major_segments=64, minor_segments=12,
                                 location=(0, 0, 1.68))
rim = bpy.context.active_object
rim.name = "SerbanRim"
link_obj(rim, CHAR); scene.collection.objects.unlink(rim)
set_mat(rim, NAVY)
smooth_shade(rim)

# lipatan lilit LEMBUT: 3 cincin torus miring, sedikit menonjol dari dome
for i, (z, major, minor, rx, ry) in enumerate([
        (1.80, 0.60, 0.032, 0.10, 0.05),
        (1.92, 0.57, 0.030, -0.08, 0.06),
        (2.02, 0.505, 0.028, 0.06, -0.05)]):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor,
                                     major_segments=64, minor_segments=12,
                                     location=(0, 0, z))
    ring = bpy.context.active_object
    ring.name = f"Lilitan{i+1}"
    ring.rotation_euler = (rx, ry, 0)
    link_obj(ring, CHAR); scene.collection.objects.unlink(ring)
    set_mat(ring, NAVY2)
    smooth_shade(ring)

# ekor serban di belakang
bezier_tube("SerbanEkor", [(0, 1.98), (0, 1.80), (0, 1.60)],
            -0.55, 0.035, NAVY)
# (bezier_tube memakai y_plane sebagai Y — untuk ekor, titiknya (x,z) dgn y=-0.55)

# ---------- KACAMATA CAT-EYE ----------
# Outline 2D (x, z) lensa kanan, pusat ~(0.22, 1.58). Sayap terangkat ke ujung luar.
LENS_R = [(0.045, 1.615), (0.10, 1.632), (0.18, 1.645), (0.28, 1.655),
          (0.37, 1.668), (0.44, 1.688), (0.448, 1.625), (0.44, 1.585),
          (0.425, 1.545), (0.40, 1.505), (0.32, 1.485), (0.22, 1.475),
          (0.12, 1.485), (0.05, 1.505), (0.035, 1.545), (0.035, 1.58),
          (0.04, 1.60)]
FRAME_Y = 0.56

def flat_shape(name, pts_xz, y_plane, mat, thick=0.025, bev=0.004):
    # balik urutan agar normal menghadap kamera (-Y / depan karakter +Y)
    pts = list(reversed(pts_xz))
    verts = [(x, y_plane, z) for (x, z) in pts]
    me = bpy.data.meshes.new(name)
    me.from_pydata(verts, [], [tuple(range(len(verts)))])
    me.update()
    ob = bpy.data.objects.new(name, me)
    CHAR.objects.link(ob)
    # normal harus menghadap +Y (depan wajah)
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    f = bm.faces[0]
    if f.normal.y < 0:
        bmesh.ops.reverse_faces(bm, faces=[f])
    bm.to_mesh(me)
    bm.free()
    me.update()
    ob.data.materials.append(mat)
    sol = ob.modifiers.new("Solid", 'SOLIDIFY')
    sol.thickness = thick
    sol.offset = 0.0
    bv = ob.modifiers.new("Bevel", 'BEVEL')
    bv.width = bev
    bv.segments = 2
    smooth_shade(ob)
    return ob

GLASSES = []
for side, sign in (("R", 1), ("L", -1)):
    pts = [(sign * x, z) for (x, z) in LENS_R]
    frame = flat_shape(f"Kacamata{side}", pts, FRAME_Y, BLACK, 0.025, 0.004)
    # lensa inset: outline sama diperkecil 0.85 terhadap pusat lensa
    cx, cz = sign * 0.22, 1.58
    pts_in = [(cx + (x - cx) * 0.85, cz + (z - cz) * 0.85) for (x, z) in pts]
    lens = flat_shape(f"Lensa{side}", pts_in, FRAME_Y - 0.014, LENS, 0.008, 0.002)
    for ob in (frame, lens):
        # origin ke tengah geometri, lalu yaw mengikuti lengkung wajah
        bpy.context.view_layer.objects.active = ob
        ob.select_set(True)
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')
        ob.select_set(False)
        ob.rotation_euler = (0.05, 0, sign * -0.38)  # yaw ~22° ke belakang
        GLASSES.append(ob)

# jembatan hidung: lengkung Bezier di atas hidung
br = bezier_tube("JembatanKacamata", [(-0.06, 1.575), (0.0, 1.615), (0.06, 1.575)],
                 0.565, 0.014, BLACK)
GLASSES.append(br)

# tangkai ke telinga
def tube_between(p1, p2, r, mat, name):
    v1, v2 = Vector(p1), Vector(p2)
    d = v2 - v1
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=d.length,
                                        vertices=12, location=(v1 + v2) / 2)
    ob = bpy.context.active_object
    ob.name = name
    ob.rotation_mode = 'QUATERNION'
    ob.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d.normalized())
    link_obj(ob, CHAR); scene.collection.objects.unlink(ob)
    set_mat(ob, BLACK)
    smooth_shade(ob)
    return ob

for side, sign in (("R", 1), ("L", -1)):
    t = tube_between((sign * 0.43, 0.47, 1.60), (sign * 0.53, -0.02, 1.56),
                     0.014, BLACK, f"Tangkai{side}")
    GLASSES.append(t)

# ---------- JENGGOT (volume memeluk rahang — TIDAK baji) ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=24, radius=1.0,
                                     location=(0, 0.28, 1.22))
beard = bpy.context.active_object
beard.name = "Jenggot"
beard.scale = (0.34, 0.22, 0.30)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
link_obj(beard, CHAR); scene.collection.objects.unlink(beard)

def beard_shape(v):
    x, y, z = v.co
    # buang bagian atas (di atas mulut) — jenggot mulai di bawah bibir bawah
    # (ditangani dengan menyusutkan, bukan menghapus: tarik ke dalam wajah)
    if z > 1.28:
        v.co.y = y - 0.35 * (z - 1.28)
    # permukaan kepala (bola r=0.55 pusat z=1.52) + ketebalan jenggot
    r2 = 0.55 ** 2 - (z - 1.52) ** 2 - x ** 2
    if r2 > 0:
        ys = sqrt(r2)
        # ketebalan: tebal di tengah (0.06), menipis ke tepi
        d = sqrt(x ** 2 + (z - 1.20) ** 2)
        thick = 0.02 + 0.04 * falloff(d, 0.26)
        if y > ys + thick:
            v.co.y = ys + thick
    # dagu meruncing lembut
    if z < 1.15:
        t = (1.15 - z) / 0.15
        v.co.x = x * (1.0 - 0.35 * t)
        # ujung dagu menekuk ke belakang mengikuti rahang (anti-baji)
        v.co.y = y - 0.05 * t
    # hem bergelombang halus
    if z < 1.10:
        v.co.z = z + 0.015 * sin(x * 28.0)

deform(beard, beard_shape)
set_mat(beard, BEARD)
smooth_shade(beard)
subsurf(beard, 1)

# kumis: tabung bezier "w" dangkal di atas bibir
bezier_tube("Kumis", [(-0.13, 1.37), (-0.06, 1.345), (0.0, 1.355),
                      (0.06, 1.345), (0.13, 1.37)],
            0.525, 0.018, BEARD)

print("PART2 OK — serban, kacamata, jenggot, kumis")
bpy.ops.wm.save_as_mainfile(filepath=OUT + "/kyai-chibi.blend")

# ---------- PART 3: leher, jubah, lengan, tasbih, sandal ----------
# leher
bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=0.20, vertices=32,
                                    location=(0, 0, 1.05))
neck = bpy.context.active_object
neck.name = "Leher"
link_obj(neck, CHAR); scene.collection.objects.unlink(neck)
set_mat(neck, SKIN)
smooth_shade(neck)

# jubah A-line — profil lathe (Catmull-Rom di kepala pembangun: titik halus)
prof_r = [(0.02, 1.12), (0.16, 1.10), (0.20, 1.04), (0.23, 0.95),
          (0.25, 0.80), (0.27, 0.60), (0.30, 0.40), (0.36, 0.20),
          (0.42, 0.10), (0.43, 0.08)]
verts = [(r, 0.0, z) for (r, z) in prof_r]
edges = [(i, i + 1) for i in range(len(verts) - 1)]
me = bpy.data.meshes.new("JubahProf")
me.from_pydata(verts, edges, [])
me.update()
robe = bpy.data.objects.new("Jubah", me)
CHAR.objects.link(robe)
mod = robe.modifiers.new("Screw", 'SCREW')
mod.axis = 'Z'
mod.angle = math.radians(360)
mod.steps = 64
mod.render_steps = 64
mod.use_smooth_shade = True
set_mat(robe, ROBE)

def robe_shape(v):
    x, y, z = v.co
    th = math.atan2(y, x)
    r = math.hypot(x, y)
    if r < 1e-6:
        return
    # drape kain: 6 lipatan vertikal lembut di bawah dada
    if z < 0.75:
        amp = 0.010 * sstep(0.75, 0.30, z)
        f = 1.0 + (amp / r) * sin(th * 6.0)
        v.co.x = x * f
        v.co.y = y * f
    # hem bergelombang halus
    if z < 0.12:
        v.co.z = z + 0.012 * sin(th * 6.0 + 0.5)

deform(robe, robe_shape)
smooth_shade(robe)
subsurf(robe, 1)

# kerah
bpy.ops.mesh.primitive_torus_add(major_radius=0.17, minor_radius=0.028,
                                 major_segments=48, minor_segments=12,
                                 location=(0, 0, 1.08))
col = bpy.context.active_object
col.name = "Kerah"
link_obj(col, CHAR); scene.collection.objects.unlink(col)
set_mat(col, ROBE)
smooth_shade(col)

# kancing depan
for z in (0.95, 0.75, 0.55, 0.35):
    rr = {0.95: 0.23, 0.75: 0.255, 0.55: 0.275, 0.35: 0.31}[z]
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.018,
                                         location=(0, rr + 0.004, z))
    b = bpy.context.active_object
    b.name = "Kancing"
    link_obj(b, CHAR); scene.collection.objects.unlink(b)
    set_mat(b, BUTTON)
    smooth_shade(b)

# lengan: kerucut meruncing bahu->pergelangan + bahu bulat + tangan
def limb(p1, p2, r_top, r_bot, name):
    v1, v2 = Vector(p1), Vector(p2)
    d = v2 - v1
    bpy.ops.mesh.primitive_cone_add(radius1=r_bot, radius2=r_top, depth=d.length,
                                    vertices=24, location=(v1 + v2) / 2)
    ob = bpy.context.active_object
    ob.name = name
    ob.rotation_mode = 'QUATERNION'
    # +Z lokal kerucut = radius2 (atas) -> arahkan ke bahu (p1)
    ob.rotation_quaternion = Vector((0, 0, 1)).rotation_difference((v1 - v2).normalized())
    link_obj(ob, CHAR); scene.collection.objects.unlink(ob)
    set_mat(ob, ROBE)
    smooth_shade(ob)
    return ob

for side, sign in (("R", 1), ("L", -1)):
    limb((sign * 0.23, 0, 1.02), (sign * 0.32, 0.03, 0.56),
         0.088, 0.072, f"Lengan{side}")
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.105,
                                         location=(sign * 0.23, 0, 1.02))
    sh = bpy.context.active_object
    sh.name = f"Bahu{side}"
    link_obj(sh, CHAR); scene.collection.objects.unlink(sh)
    set_mat(sh, ROBE)
    smooth_shade(sh)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=14, radius=0.068,
                                         location=(sign * 0.32, 0.03, 0.52))
    hd = bpy.context.active_object
    hd.name = f"Tangan{side}"
    hd.scale = (0.9, 0.9, 1.15)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(hd, CHAR); scene.collection.objects.unlink(hd)
    set_mat(hd, SKIN)
    smooth_shade(hd)

# tasbih 14 butir di tangan kanan (lingkaran kecil vertikal)
for i in range(14):
    a = i / 14.0 * 2 * pi
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=12, ring_count=10, radius=0.02,
        location=(0.32 + 0.055 * cos(a), 0.03, 0.47 + 0.05 * sin(a)))
    bd = bpy.context.active_object
    bd.name = "Tasbih"
    link_obj(bd, CHAR); scene.collection.objects.unlink(bd)
    set_mat(bd, BEAD)
    smooth_shade(bd)
# rumbai tasbih
bpy.ops.mesh.primitive_cone_add(radius1=0.008, radius2=0.02, depth=0.06,
                                location=(0.32, 0.03, 0.40))
ts = bpy.context.active_object
ts.name = "TasbihRumbai"
ts.rotation_euler = (pi, 0, 0)
link_obj(ts, CHAR); scene.collection.objects.unlink(ts)
set_mat(ts, BEAD)

# sandal: ujung kaki mengintip di bawah hem
for side, sign in (("R", 1), ("L", -1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, radius=0.10,
                                         location=(sign * 0.14, 0.34, 0.03))
    sd = bpy.context.active_object
    sd.name = f"Sandal{side}"
    sd.scale = (1.0, 1.5, 0.35)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link_obj(sd, CHAR); scene.collection.objects.unlink(sd)
    set_mat(sd, LEATHER)
    smooth_shade(sd)

print("PART3 OK — leher, jubah, lengan, tasbih, sandal")
bpy.ops.wm.save_as_mainfile(filepath=OUT + "/kyai-chibi.blend")

# ---------- PART 4: panggung, cahaya, kamera, render, export GLB ----------
# lantai penangkap bayangan
bpy.ops.mesh.primitive_circle_add(radius=3.0, vertices=64, location=(0, 0, 0))
gnd = bpy.context.active_object
gnd.name = "Lantai"
gnd.is_shadow_catcher = True

# plinth putih di bawah karakter
bpy.ops.mesh.primitive_cylinder_add(radius=0.85, depth=0.04, vertices=64,
                                    location=(0, 0, -0.02))
pl = bpy.context.active_object
pl.name = "Plinth"
pl.data.materials.append(mat_principled("Plinth", (0.96, 0.96, 0.96), 0.6))

# dunia: latar abu sangat muda
if "World" in bpy.data.worlds:
    w = bpy.data.worlds["World"]
else:
    w = bpy.data.worlds.new("World")
scene.world = w
w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (0.93, 0.93, 0.93, 1.0)
w.node_tree.nodes["Background"].inputs[1].default_value = 0.4

def area_light(name, loc, target, energy, size, color=(1, 1, 1)):
    ld = bpy.data.lights.new(name, 'AREA')
    ld.energy = energy
    ld.shape = 'DISK'
    ld.size = size
    ld.color = color
    ob = bpy.data.objects.new(name, ld)
    scene.collection.objects.link(ob)
    ob.location = loc
    ob.rotation_mode = 'QUATERNION'
    d = (Vector(target) - Vector(loc)).normalized()
    # to_track_quat: -Z ke target, +Y sedekat mungkin ke +Z dunia (anti-terbalik)
    ob.rotation_quaternion = d.to_track_quat('-Z', 'Y')
    return ob

area_light("Key", (2.5, 2.5, 3.5), (0, 0, 1.1), 500, 2.5)
area_light("Fill", (-2.5, 1.5, 2.2), (0, 0, 1.1), 250, 2.0)
area_light("Rim", (0, -3.0, 2.5), (0, 0, 1.2), 300, 1.5, color=(0.9, 0.95, 1.0))

# ---------- kamera ----------
def make_cam(name, loc, target, lens=50):
    cd = bpy.data.cameras.new(name)
    cd.lens = lens
    ob = bpy.data.objects.new(name, cd)
    scene.collection.objects.link(ob)
    ob.location = loc
    ob.rotation_mode = 'QUATERNION'
    d = (Vector(target) - Vector(loc)).normalized()
    ob.rotation_quaternion = d.to_track_quat('-Z', 'Y')
    return ob

def render_to(cam, path):
    scene.camera = cam
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("RENDERED:", path)

cam_depan = make_cam("CamDepan", (0, 3.4, 1.35), (0, 0, 1.15), 50)
cam_34 = make_cam("Cam34", (2.3, 2.5, 1.6), (0, 0, 1.1), 50)
cam_samping = make_cam("CamSamping", (3.4, 0, 1.3), (0, 0, 1.1), 50)
cam_wajah = make_cam("CamWajah", (0, 1.7, 1.58), (0, 0.45, 1.55), 60)

render_to(cam_depan, OUT + "/render-depan.png")
render_to(cam_34, OUT + "/render-34.png")
render_to(cam_samping, OUT + "/render-samping.png")
render_to(cam_wajah, OUT + "/render-wajah-depan.png")

# wajah tanpa kacamata (mode kacamata-off)
for ob in GLASSES:
    ob.hide_render = True
render_to(cam_depan, OUT + "/render-tanpa-kacamata.png")
for ob in GLASSES:
    ob.hide_render = False

# ---------- hitung tris (depsgraph, sebelum export) ----------
for ob in CHAR.objects:
    for m in ob.modifiers:
        if m.type == 'SUBSURF':
            m.levels = 1
            m.render_levels = 1
deps = bpy.context.evaluated_depsgraph_get()
quads = tris = 0
for ob in CHAR.objects:
    if ob.type != 'MESH':
        continue
    ev = ob.evaluated_get(deps)
    for p in ev.data.polygons:
        if len(p.vertices) == 3:
            tris += 1
        else:
            quads += 1
print(f"TRI_COUNT: quads={quads} tris={tris} est_total_tris={tris + quads * 2}")

# ---------- export GLB ----------
glb_path = OUT + "/kyai-chibi.glb"
try:
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB',
                              export_yup=True, export_apply=True,
                              export_draco_mesh_compression_enable=True,
                              export_animations=False, export_materials='EXPORT')
    print("GLB exported with Draco")
except Exception as e:
    print("Draco export failed, retry without Draco:", e)
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB',
                              export_yup=True, export_apply=True,
                              export_draco_mesh_compression_enable=False,
                              export_animations=False, export_materials='EXPORT')
    print("GLB exported without Draco")

import os
print("GLB size bytes:", os.path.getsize(glb_path))
bpy.ops.wm.save_as_mainfile(filepath=OUT + "/kyai-chibi.blend")
print("BUILD SELESAI")
