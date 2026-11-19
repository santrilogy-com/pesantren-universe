#!/usr/bin/env python3
"""Cek TEMBUS eksplisit (pelajaran @jipraks): untuk tiap pasangan objek mesh,
uji tumpang-tindih segitiga via BVH dalam KOORDINAT DUNIA (transform objek
diterapkan — FromObject mentah mengabaikannya dan memberi positif palsu).
Pemakaian: blender --background <blend> --python cek_tembus.py
BVH overlap = pasangan segitiga yang AABB-nya bersinggungan (termasuk yang
hanya bersentuhan / tertanam sengaja). Penilaian sengaja/tidak sengaja
dilakukan manusia dari daftar ini + render."""
import bpy
from mathutils.bvhtree import BVHTree

dg = bpy.context.evaluated_depsgraph_get()
meshes = []
for o in bpy.context.scene.objects:
    if o.type != "MESH":
        continue
    me = o.evaluated_get(dg).to_mesh()
    me.calc_loop_triangles()
    if len(me.loop_triangles) == 0:
        continue
    mw = o.matrix_world
    verts = [mw @ v.co for v in me.vertices]
    polys = [tuple(t.vertices) for t in me.loop_triangles]
    meshes.append((o.name, BVHTree.FromPolygons(verts, polys)))

print(f"CEK TEMBUS: {bpy.data.filepath} — {len(meshes)} objek mesh")
temuan = 0
for i in range(len(meshes)):
    for j in range(i + 1, len(meshes)):
        n1, bvh1 = meshes[i]
        n2, bvh2 = meshes[j]
        ov = bvh1.overlap(bvh2)
        if ov:
            print(f"  TEMBUS: {n1} <-> {n2} : {len(ov)} pasang segitiga")
            temuan += 1
print(f"TOTAL PASANGAN TEMBUS: {temuan}")
