import bpy, math, mathutils, numpy as np
import bmesh
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal-pose.blend')

def cari(nama_frag):
    for o in bpy.data.objects:
        if o.type == 'MESH' and nama_frag in o.name:
            return o
    return None

body = cari('body'); head = cari('head')
print('BODY:', body.name, 'tris:', len(body.data.polygons))
print('HEAD:', head.name, 'tris:', len(head.data.polygons))

# --- 1. Ratakan tonjolan bahu (artefak putaran verteks): tarik ke dalam + ke bawah ---
me = body.data
bm = bmesh.new(); bm.from_mesh(me)
n = 0
for v in bm.verts:
    x, y, z = v.co.x, v.co.y, v.co.z
    if z > 1.40 and abs(x) > 0.12:
        # tarik x ke dalam 20% dari bagian di luar 0.12; z ke arah 1.40 sebesar 15%
        nx = 0.12 + (abs(x) - 0.12) * 0.80
        v.co.x = math.copysign(nx, x)
        v.co.z = 1.40 + (z - 1.40) * 0.85
        n += 1
bm.to_mesh(me); bm.free(); me.update()
print(f'BAHU diratakan: {n} verteks')

# --- 2. Decimate: body 0.5, kepala 0.7 (wajah dipertahankan) ---
def decimate(obj, ratio):
    mod = obj.modifiers.new('Decimate', 'DECIMATE')
    mod.decimate_type = 'COLLAPSE'
    mod.ratio = ratio
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)
    print(f'DECIMATE {obj.name}: ratio {ratio} -> tris {len(obj.data.polygons)}')
decimate(body, 0.5)
decimate(head, 0.7)

# --- 3. Ukur bahu + pergelangan setelah decimate ---
deps = bpy.context.evaluated_depsgraph_get()
def verts_dunia(obj):
    ev = obj.evaluated_get(deps); m = ev.to_mesh()
    out = [obj.matrix_world @ v.co for v in m.vertices]
    ev.to_mesh_clear(); return out
bv = verts_dunia(body)
bahu_area = [v for v in bv if 1.42 < v.z < 1.65 and abs(v.x) > 0.12]
R_bahu = max(abs(v.x) for v in bahu_area)
Z_bahu = max(v.z for v in bahu_area)
print(f'BAHU terukur: R={R_bahu:.3f} Ztop={Z_bahu:.3f}')
tangan = [v for v in bv if abs(v.x) > 0.18 and v.z < 1.1]
print(f'TANGAN: z min {min(v.z for v in tangan):.3f}, x +{max(v.x for v in tangan):.3f} / {min(v.x for v in tangan):.3f}')
# pergelangan: verteks tangan tertinggi di tiap sisi
for sisi, tanda in [('kiri(+X)', 1), ('kanan(-X)', -1)]:
    tw = [v for v in bv if v.x * tanda > 0.20 and v.z < 1.1]
    print(f'  {sisi}: pergelangan z~{max(v.z for v in tw):.3f} x={max(v.x*tanda for v in tw):.3f}')

# --- 4. Material (Principled BSDF saja, aman untuk glTF) ---
def buat_material(nama, warna, rough=0.85):
    m = bpy.data.materials.new(nama)
    m.use_nodes = True
    b = m.node_tree.nodes['Principled BSDF']
    b.inputs['Base Color'].default_value = (*warna, 1.0)
    b.inputs['Metallic'].default_value = 0.0
    b.inputs['Roughness'].default_value = rough
    return m
MAT_jubah = buat_material('MAT-jubah', (0.96, 0.96, 0.94), 0.85)
MAT_serban = buat_material('MAT-serban', (0.93, 0.93, 0.90), 0.9)
MAT_jenggot = buat_material('MAT-jenggot', (0.05, 0.04, 0.03), 0.95)
MAT_tasbih = buat_material('MAT-tasbih', (0.20, 0.10, 0.04), 0.6)
MAT_kancing = buat_material('MAT-kancing', (0.85, 0.85, 0.82), 0.5)

# --- 5. Jubah: tabung cincin dari leher sampai mata kaki ---
def buat_jubah(rings, seg=48):
    verts, faces = [], []
    for (z, r) in rings:
        for j in range(seg):
            a = 2 * math.pi * j / seg
            verts.append((r * math.cos(a), r * math.sin(a), z))
    for i in range(len(rings) - 1):
        for j in range(seg):
            j2 = (j + 1) % seg
            faces.append((i*seg+j, i*seg+j2, (i+1)*seg+j2, (i+1)*seg+j))
    mesh = bpy.data.meshes.new('GEO-jubah')
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new('GEO-jubah', mesh)
    bpy.context.collection.objects.link(obj)
    # normal ke luar + halus
    bm2 = bmesh.new(); bm2.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces)
    bm2.to_mesh(mesh); bm2.free()
    for p in mesh.polygons:
        p.use_smooth = True
    mesh.update()
    return obj

rings = [
    (Z_bahu + 0.01, 0.10),
    (Z_bahu - 0.02, R_bahu + 0.02),
    (1.44, R_bahu + 0.01),
    (1.30, 0.27),
    (1.05, 0.26),
    (0.80, 0.28),
    (0.50, 0.315),
    (0.25, 0.355),
    (0.10, 0.385),
]
jubah = buat_jubah(rings)
jubah.data.materials.append(MAT_jubah)
print('JUBAH dibuat, rings:', [(round(z,2), round(r,2)) for z, r in rings])

# penutup lubang dada (piringan di dalam leher jubah, menghadap ke atas)
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.22, depth=0.01, location=(0, 0, 1.47))
tutup = bpy.context.active_object
tutup.name = 'GEO-tutup-dada'
tutup.data.materials.append(MAT_jubah)

# kerah: torus di leher
bpy.ops.mesh.primitive_torus_add(major_radius=0.095, minor_radius=0.022, major_segments=32, minor_segments=12, location=(0, 0, 1.52))
kerah = bpy.context.active_object
kerah.name = 'GEO-kerah'
kerah.data.materials.append(MAT_jubah)

# kancing: 5 butir di depan dada (depan = -Y)
def jari_jubah(z):
    # interpolasi radius jubah pada ketinggian z
    for i in range(len(rings) - 1):
        z1, r1 = rings[i]; z2, r2 = rings[i+1]
        if z2 <= z <= z1:
            t = (z1 - z) / (z1 - z2)
            return r1 + t * (r2 - r1)
    return rings[-1][1]
for i, z in enumerate([1.48, 1.40, 1.32, 1.24, 1.16]):
    r = jari_jubah(z)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=0.011, location=(0, -(r + 0.002), z))
    k = bpy.context.active_object
    k.name = f'GEO-kancing-{i+1}'
    k.data.materials.append(MAT_kancing)
print('KANCING 5 buah')

# --- 6. Lengan jubah (selongsong dari bahu ke pergelangan) ---
def tabung_dua_titik(nama, p1, p2, r1, r2, mat, seg=20):
    d = Vector(p2) - Vector(p1)
    tengah = (Vector(p1) + Vector(p2)) / 2
    bpy.ops.mesh.primitive_cone_add(vertices=seg, radius1=r1, radius2=r2, depth=d.length, location=tengah)
    o = bpy.context.active_object
    o.name = nama
    o.rotation_mode = 'QUATERNION'
    o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d.normalized())
    o.data.materials.append(mat)
    return o
tabung_dua_titik('GEO-lengan-kiri', (0.24, 0.02, 1.44), (0.27, 0.02, 0.80), 0.085, 0.062, MAT_jubah)
tabung_dua_titik('GEO-lengan-kanan', (-0.24, 0.02, 1.44), (-0.27, 0.02, 0.80), 0.085, 0.062, MAT_jubah)
print('LENGAN jubah dibuat')

# --- 7. Serban: tumpukan torus + penutup atas + ekor di belakang ---
for i, z in enumerate([1.845, 1.865, 1.885, 1.905, 1.920]):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.105, minor_radius=0.030,
        major_segments=32, minor_segments=12,
        location=((0.004 if i % 2 else -0.004), (0.004 if i % 2 else -0.004), z),
        rotation=(0.10 if i % 2 else -0.06, 0.05, 0))
    t = bpy.context.active_object
    t.name = f'GEO-serban-{i+1}'
    t.data.materials.append(MAT_serban)
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=0.10, location=(0, 0.005, 1.925))
puncak = bpy.context.active_object
puncak.name = 'GEO-serban-puncak'
puncak.scale = (1.0, 1.0, 0.55)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
puncak.data.materials.append(MAT_serban)
# ekor serban (kurva bezier, menggantung di belakang leher)
cu = bpy.data.curves.new('GEO-ekor-serban', 'CURVE')
cu.dimensions = '3D'
cu.bevel_depth = 0.030
cu.bevel_resolution = 3
spl = cu.splines.new('BEZIER')
spl.bezier_points.add(2)
for bp, co in zip(spl.bezier_points, [(0, 0.105, 1.87), (0, 0.085, 1.70), (0, 0.075, 1.55)]):
    bp.co = co
    bp.handle_left_type = 'AUTO'
    bp.handle_right_type = 'AUTO'
ekor = bpy.data.objects.new('GEO-ekor-serban', cu)
bpy.context.collection.objects.link(ekor)
ekor.data.materials.append(MAT_serban)
print('SERBAN dibuat')

# --- 8. Jenggot + kumis (landmark terukur: hidung (0,-0.11,1.75); dagu z 1.549;
#      rahang x +-0.053 di z 1.569; mulut ~1.63; mata z 1.78) ---
bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=1.0, location=(0, -0.01, 1.555))
jenggot = bpy.context.active_object
jenggot.name = 'GEO-jenggot'
jenggot.scale = (0.095, 0.05, 0.07)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
jenggot.data.materials.append(MAT_jenggot)
for sisi, sx in [('kiri', 1), ('kanan', -1)]:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0, location=(sx*0.022, -0.075, 1.648))
    kum = bpy.context.active_object
    kum.name = f'GEO-kumis-{sisi}'
    kum.scale = (0.028, 0.012, 0.010)
    kum.rotation_euler = (0, 0, -sx * 0.3)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    kum.data.materials.append(MAT_jenggot)
print('JENGGOT + KUMIS dibuat')

# --- 9. Tasbih di tangan kanan (kanan figur = -X; pergelangan ~(-0.27, 0.02, 0.82)) ---
cx, cy, cz = -0.27, 0.02, 0.72
for i in range(11):
    a = 2 * math.pi * i / 11
    bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=6, radius=0.008,
        location=(cx + 0.030 * math.cos(a), cy, cz + 0.030 * math.sin(a)))
    b = bpy.context.active_object
    b.name = f'GEO-tasbih-{i+1:02d}'
    b.data.materials.append(MAT_tasbih)
bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.008, radius2=0.002, depth=0.05, location=(cx, cy, cz - 0.055))
rumbai = bpy.context.active_object
rumbai.name = 'GEO-tasbih-rumbai'
rumbai.data.materials.append(MAT_tasbih)
print('TASBIH dibuat')

bpy.ops.wm.save_as_mainfile(filepath=OUT + 'ust-aqsal.blend')
print('BLEND final tersimpan')

# --- 10. Render verifikasi (depan, samping, wajah) ---
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'
scene.cycles.use_denoising = False
scene.render.resolution_x = 768
scene.render.resolution_y = 1024

def kamera(nama, lokasi, target):
    bpy.ops.object.camera_add(location=lokasi)
    cam = bpy.context.active_object
    cam.name = nama
    arah = Vector(target) - cam.location
    cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
    return cam

scene.camera = kamera('Cam_Verif_Depan', (0, -3.4, 1.35), (0, 0, 0.95))
scene.render.filepath = OUT + 'kyai-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER depan selesai')
scene.camera = kamera('Cam_Verif_Samping', (3.2, -1.2, 1.35), (0, 0, 0.95))
scene.render.filepath = OUT + 'kyai-samping.png'
bpy.ops.render.render(write_still=True)
print('RENDER samping selesai')
scene.camera = kamera('Cam_Verif_Wajah', (0.25, -0.9, 1.72), (0, 0, 1.66))
scene.render.filepath = OUT + 'kyai-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah selesai')

# --- 11. Hapus studio, export GLB ---
for o in list(bpy.data.objects):
    if o.type in ('LIGHT', 'CAMERA') or o.name.startswith('GEO-panggung'):
        bpy.data.objects.remove(o, do_unlink=True)
tot = 0
for o in bpy.data.objects:
    if o.type == 'MESH':
        tot += len(o.data.polygons)
        print(f"  MESH {o.name}: {len(o.data.polygons)} tris")
print(f'TOTAL TRIS SEBELUM EXPORT: {tot}')
bpy.ops.export_scene.gltf(filepath=OUT + 'ust-aqsal.glb', export_format='GLB',
    export_apply=True, export_yup=True, export_materials='EXPORT',
    export_animations=False, export_normals=True, export_tangents=False)
print('EXPORT GLB selesai')
print('SELESAI-TAHAP3')
