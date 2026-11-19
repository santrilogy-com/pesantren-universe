#!/usr/bin/env python3
"""Util bersama untuk build elemen lingkungan v2 Pesantren Universe.
Dipakai oleh build_*.py tiap elemen (import via sys.path).
Palet HEX persis PV; gaya halus (bevel tipis di objek kecil), bukan balok.
Blender 4.5.16 headless, Cycles CPU."""
import bpy
import bmesh
import math
import os
import random


# ------------------------------------------------------------------ warna
def srgb2lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def hex_rgb(h):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return (srgb2lin(r), srgb2lin(g), srgb2lin(b), 1.0)


# Palet PV + palet lembar konsep lingkungan
PALET = {
    "krem":      "#F2EAD6",
    "krem_muda": "#FAF4E6",
    "zamrud":    "#065F46",
    "zamrud_tua": "#044230",
    "emas":      "#C9A227",
    "jati":      "#7B4B2A",
    "jati_tua":  "#4A2E18",
    "batu":      "#B8B2A4",
    "daun":      "#2E7D5B",
    "daun_muda": "#7FB069",
    "rumput":    "#A8C686",
    "tanah":     "#8A6D4B",
    "lumpur":    "#785C3C",
    "air":       "#A8C8B8",
    "bambu":     "#D9B36A",
    "bunga_merah": "#B91C1C",
    "bunga_kuning": "#EAB308",
    "bunga_ungu": "#7E22CE",
    "bunga_oranye": "#EA580C",
    "tikar":     "#8FAE6B",
}


def mat_flat(name, hexcol, rough=0.9, metallic=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hex_rgb(hexcol)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    return m


def mats():
    """Semua material lingkungan, sekali panggil."""
    out = {}
    for k, v in PALET.items():
        rough = 0.25 if k == "air" else 0.9
        out[k] = mat_flat("L_" + k, v, rough=rough)
    out["emas"].node_tree.nodes["Principled BSDF"].inputs["Metallic"].default_value = 0.35
    out["emas"].node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.45
    return out


# ------------------------------------------------------------------ primitif
def link(obj, coll):
    # operator primitive sudah menautkan objek ke koleksi scene;
    # tautkan hanya bila belum ada di koleksi tujuan.
    if obj.name not in coll.objects:
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


def cyl(name, loc, r, depth, mat, coll, verts=16, rot=(0, 0, 0)):
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


def cone(name, loc, r, depth, mat, coll, verts=12, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=0.0,
                                    depth=depth, location=loc, rotation=rot)
    o = bpy.context.object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    link(o, coll)
    return o


def sphere(name, loc, r, mat, coll, seg=20, rings=12, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings,
                                         radius=r, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if mat:
        o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    link(o, coll)
    return o


def ico(name, loc, r, mat, coll, subdiv=1, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdiv, radius=r, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if mat:
        o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    link(o, coll)
    return o


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
                faces.append((r0[j], r1[j], r1[j2], r0[j2]))
    me = bpy.data.meshes.new(name + "_mesh")
    me.from_pydata(verts, [], faces)
    me.update()
    # pastikan normal menghadap keluar (prisma tertutup)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    if mat:
        me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = True
    link(o, coll)
    return o


def prism(name, profile_xz, depth, mat, coll, loc=(0, 0, 0), axis="Y"):
    """Prisma dari profil 2D (x, z), diekstrusi sepanjang sumbu axis sejauh depth.
    Dipakai untuk segitiga atap pelana (gable)."""
    verts, faces = [], []
    n = len(profile_xz)
    for (x, z) in profile_xz:
        verts.append((loc[0] + x, loc[1], loc[2] + z))
    for (x, z) in profile_xz:
        if axis == "Y":
            verts.append((loc[0] + x, loc[1] + depth, loc[2] + z))
        else:
            verts.append((loc[0] + x, loc[1], loc[2] + z))  # fallback
    faces.append(tuple(range(n - 1, -1, -1)))          # tutup belakang
    faces.append(tuple(range(n, 2 * n)))               # tutup depan
    for i in range(n):
        j = (i + 1) % n
        faces.append((i, j, n + j, n + i))
    me = bpy.data.meshes.new(name + "_mesh")
    me.from_pydata(verts, [], faces)
    me.update()
    # pastikan normal menghadap keluar (prisma tertutup)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    if mat:
        me.materials.append(mat)
    link(o, coll)
    return o


def join_objects(objs, name):
    """Gabung beberapa objek mesh jadi satu (hemat objek di GLB)."""
    if not objs:
        return None
    if len(objs) == 1:
        objs[0].name = name
        return objs[0]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    o = bpy.context.object
    o.name = name
    return o


# ------------------------------------------------------------------ akhir
def stats_and_save(out_blend, out_glb):
    dg = bpy.context.evaluated_depsgraph_get()
    total_verts = total_tris = 0
    n_obj = 0
    for o in bpy.context.scene.objects:
        if o.type != "MESH":
            continue
        n_obj += 1
        me = o.evaluated_get(dg).to_mesh()
        me.calc_loop_triangles()
        total_verts += len(me.vertices)
        total_tris += len(me.loop_triangles)
        o.evaluated_get(dg).to_mesh_clear()
    print(f"OBJEK: {n_obj}  VERTS (evaluated): {total_verts}  TRIS (evaluated): {total_tris}")
    bpy.ops.wm.save_as_mainfile(filepath=out_blend)
    print("BLEND disimpan:", out_blend, os.path.getsize(out_blend), "byte")
    bpy.ops.export_scene.gltf(filepath=out_glb, export_format="GLB",
                              export_apply=True, export_yup=True)
    print("GLB diekspor:", out_glb, os.path.getsize(out_glb), "byte")
    print("SELESAI")
    return n_obj, total_verts, total_tris


def new_scene(name):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    return bpy.context.scene.collection
