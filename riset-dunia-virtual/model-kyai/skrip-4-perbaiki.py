import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

def cari(nama):
    return bpy.data.objects.get(nama)

# --- 1. STUDIO untuk render (pose.blend tidak menyimpan lampu!) ---
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'
scene.cycles.use_denoising = False
scene.render.resolution_x = 768
scene.render.resolution_y = 1024
world = bpy.data.worlds['World']
world.use_nodes = True
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.05, 0.05, 0.07, 1.0)
bg.inputs['Strength'].default_value = 1.0

def lampu(nama, lokasi, energi, ukuran=0.5, rot=(0.9, 0, 0.3)):
    bpy.ops.object.light_add(type='AREA', location=lokasi)
    l = bpy.context.active_object
    l.name = nama
    l.data.energy = energi
    l.data.shape = 'DISK'
    l.data.size = ukuran
    l.rotation_euler = rot
    return l
# key dari depan-atas-kanan, fill dari kiri, rim dari belakang
lampu('Key', (2.0, -2.5, 3.0), 900, 1.2, (math.radians(55), 0, math.radians(20)))
lampu('Fill', (-2.0, -2.0, 1.5), 350, 1.0, (math.radians(55), 0, math.radians(-25)))
lampu('Rim', (0.0, 2.5, 2.5), 600, 0.8, (math.radians(120), 0, 0))
lampu('DepanBawah', (0, -2.0, 0.6), 150, 1.0, (math.radians(80), 0, 0))

bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=0.08, location=(0, 0, -0.04))
pg = bpy.context.active_object
pg.name = 'GEO-panggung'
mat = bpy.data.materials.new('MAT-panggung')
mat.use_nodes = True
mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.08, 0.08, 0.10, 1.0)
mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value = 0.6
pg.data.materials.append(mat)

# --- 2. SERBAN: tambah inti padat + rapatkan lilitan ---
MAT_serban = bpy.data.materials.get('MAT-serban')
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=1.0, location=(0, 0.005, 1.885))
inti = bpy.context.active_object
inti.name = 'GEO-serban-inti'
inti.scale = (0.105, 0.105, 0.085)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
inti.data.materials.append(MAT_serban)
# rapatkan cincin lama: naikkan minor radius 0.030 -> 0.036
for i in range(1, 6):
    t = cari(f'GEO-serban-{i}')
    if t is None:
        continue
    # torus minor radius tidak bisa diubah langsung; skala lokal z/x tipis saja:
    # ganti dengan torus baru di posisi sama
    loc = tuple(t.location); rot = tuple(t.rotation_euler)
    bpy.data.objects.remove(t, do_unlink=True)
    z = [1.845, 1.861, 1.877, 1.893, 1.909][i-1]
    bpy.ops.mesh.primitive_torus_add(major_radius=0.105, minor_radius=0.036,
        major_segments=32, minor_segments=12,
        location=((0.004 if i % 2 else -0.004), (0.004 if i % 2 else -0.004), z),
        rotation=(0.10 if i % 2 else -0.06, 0.05, 0))
    nt = bpy.context.active_object
    nt.name = f'GEO-serban-{i}'
    nt.data.materials.append(MAT_serban)
print('SERBAN diperbaiki (inti + lilitan rapat)')

# --- 3. JENGGOT: bentuk ulang — lebih ramping, miring ke belakang (atas masuk ke wajah) ---
jenggot = cari('GEO-jenggot')
if jenggot:
    bpy.data.objects.remove(jenggot, do_unlink=True)
MAT_jenggot = bpy.data.materials.get('MAT-jenggot')
bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=1.0, location=(0, -0.008, 1.550))
jenggot = bpy.context.active_object
jenggot.name = 'GEO-jenggot'
jenggot.scale = (0.082, 0.05, 0.06)
jenggot.rotation_euler = (-0.35, 0, 0)  # atas masuk ke wajah, bawah menggantung
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
# terapkan rotasi ke mesh (bukan hanya objek) supaya export benar:
bpy.context.view_layer.objects.active = jenggot
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
jenggot.data.materials.append(MAT_jenggot)
print('JENGGOT dibentuk ulang (miring, ramping)')

# kumis: sedikit lebih besar
for sisi, sx in [('kiri', 1), ('kanan', -1)]:
    k = cari(f'GEO-kumis-{sisi}')
    if k:
        bpy.data.objects.remove(k, do_unlink=True)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0, location=(sx*0.022, -0.075, 1.650))
    kum = bpy.context.active_object
    kum.name = f'GEO-kumis-{sisi}'
    kum.scale = (0.030, 0.013, 0.011)
    kum.rotation_euler = (0, 0, -sx * 0.3)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    kum.data.materials.append(MAT_jenggot)
print('KUMIS diperbesar sedikit')

# --- 4. JUBAH: bangun ulang dengan bahu lebih landai ---
jubah_lama = cari('GEO-jubah')
R_bahu = 0.27  # dari pengukuran tahap 3 (tertutup penuh)
Z_bahu = 1.57
if jubah_lama:
    bpy.data.objects.remove(jubah_lama, do_unlink=True)
MAT_jubah = bpy.data.materials.get('MAT-jubah')
import bmesh
rings = [
    (Z_bahu + 0.01, 0.10),
    (Z_bahu - 0.005, 0.19),
    (Z_bahu - 0.02, R_bahu),
    (1.44, R_bahu + 0.01),
    (1.30, 0.27),
    (1.05, 0.26),
    (0.80, 0.28),
    (0.50, 0.315),
    (0.25, 0.355),
    (0.10, 0.385),
]
seg = 48
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
jubah = bpy.data.objects.new('GEO-jubah', mesh)
bpy.context.collection.objects.link(jubah)
bm2 = bmesh.new(); bm2.from_mesh(mesh)
bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces)
bm2.to_mesh(mesh); bm2.free()
for p in mesh.polygons:
    p.use_smooth = True
mesh.update()
jubah.data.materials.append(MAT_jubah)
print('JUBAH dibangun ulang (bahu landai)')

bpy.ops.wm.save_as_mainfile(filepath=OUT + 'ust-aqsal.blend')
print('BLEND tersimpan')

# --- 5. Render verifikasi ulang ---
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

# --- 6. Hapus studio, export GLB ---
for o in list(bpy.data.objects):
    if o.type in ('LIGHT', 'CAMERA') or o.name.startswith('GEO-panggung'):
        bpy.data.objects.remove(o, do_unlink=True)
tot = 0
for o in bpy.data.objects:
    if o.type == 'MESH':
        tot += len(o.data.polygons)
print(f'TOTAL TRIS SEBELUM EXPORT: {tot}')
bpy.ops.export_scene.gltf(filepath=OUT + 'ust-aqsal.glb', export_format='GLB',
    export_apply=True, export_yup=True, export_materials='EXPORT',
    export_animations=False, export_normals=True, export_tangents=False)
print('EXPORT GLB selesai')
print('SELESAI-TAHAP4')
