import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

def ambil_material(nama, warna, rough=0.95):
    m = bpy.data.materials.get(nama)
    if m is None:
        m = bpy.data.materials.new(name=nama)
        m.use_nodes = True
        b = m.node_tree.nodes['Principled BSDF']
        b.inputs['Base Color'].default_value = (*warna, 1.0)
        b.inputs['Roughness'].default_value = rough
    return m

MAT_jenggot = ambil_material('MAT-jenggot', (0.05, 0.04, 0.03), 0.95)

for nm in ['GEO-jenggot', 'GEO-kumis-kiri', 'GEO-kumis-kanan']:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
        print('Dihapus:', nm)

# Jenggot: lebih ramping, ujung bawah meruncing
PROFIL = [
    (1.658, -0.088, 0.048),
    (1.632, -0.075, 0.065),
    (1.600, -0.070, 0.072),
    (1.560, -0.068, 0.062),
    (1.520, -0.062, 0.048),
    (1.485, -0.048, 0.022),
]
Y_BELAKANG = 0.015
N = 13
verts, faces = [], []
for (z, y_depan, w) in PROFIL:
    for i in range(N):
        th = -math.pi / 2 + math.pi * i / (N - 1)
        x = w * math.sin(th)
        y = Y_BELAKANG + (y_depan - Y_BELAKANG) * math.cos(th)
        verts.append((x, y, z))
for r in range(len(PROFIL) - 1):
    for i in range(N - 1):
        a = r * N + i; b = r * N + i + 1
        c = (r + 1) * N + i + 1; d = (r + 1) * N + i
        faces.append((a, b, c, d))
tip = len(verts)
verts.append((0, (PROFIL[-1][1] + Y_BELAKANG) / 2, PROFIL[-1][0] - 0.004))
last = (len(PROFIL) - 1) * N
for i in range(N - 1):
    faces.append((last + i, last + i + 1, tip))
me = bpy.data.meshes.new('GEO-jenggot-mesh')
me.from_pydata(verts, [], faces)
me.update()
for p in me.polygons:
    p.use_smooth = True
jenggot = bpy.data.objects.new('GEO-jenggot', me)
bpy.context.collection.objects.link(jenggot)
mod = jenggot.modifiers.new(name='Tebal', type='SOLIDIFY')
mod.thickness = 0.004
me.materials.append(MAT_jenggot)
print('JENGGOT ramping dibuat, poligon:', len(me.polygons))

# Kumis: lebih kecil, selebar mulut
def kumis(nama, x):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16,
                                          location=(x, -0.090, 1.685))
    k = bpy.context.active_object
    k.name = nama
    k.scale = (0.016, 0.007, 0.006)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for p in k.data.polygons:
        p.use_smooth = True
    k.data.materials.append(MAT_jenggot)
    return k
kumis('GEO-kumis-kiri', -0.012)
kumis('GEO-kumis-kanan', 0.012)
print('KUMIS kecil dibuat ulang')

# Studio (lampu + panggung) untuk render verifikasi
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
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
lampu('Key', (2.0, -2.5, 3.0), 900, 1.2, (math.radians(55), 0, math.radians(20)))
lampu('Fill', (-2.0, -2.0, 1.5), 350, 1.0, (math.radians(55), 0, math.radians(-25)))
lampu('Rim', (0, 2.5, 2.0), 600, 1.0, (math.radians(120), 0, 0))
lampu('DepanBawah', (0, -2.0, 0.6), 150, 1.0, (math.radians(80), 0, 0))
bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=0.06, location=(0, 0, -0.03))
pg = bpy.context.active_object
pg.name = 'GEO-panggung'
mp = bpy.data.materials.new('MAT-panggung')
mp.use_nodes = True
mp.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.02, 0.02, 0.02, 1.0)
pg.data.materials.append(mp)

def kamera(nama, lokasi, target):
    cam = bpy.data.objects.get(nama)
    if cam is None:
        bpy.ops.object.camera_add(location=lokasi)
        cam = bpy.context.active_object
        cam.name = nama
    else:
        cam.location = lokasi
    arah = Vector(target) - cam.location
    cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
    return cam

cam_wajah = kamera('Cam_Wajah', (0.25, -0.9, 1.72), (0, 0, 1.66))
scene.camera = cam_wajah
# Render 1: Filmic (bawaan) — seperti sebelumnya
scene.view_settings.view_transform = 'Filmic'
scene.render.filepath = OUT + 'kyai-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah Filmic selesai')
# Render 2: Standard — warna material apa adanya (tanpa kompresi Filmic)
scene.view_settings.view_transform = 'Standard'
scene.render.filepath = OUT + 'kyai-wajah-standard.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah Standard selesai')
scene.view_settings.view_transform = 'Filmic'
scene.camera = kamera('Cam_Depan', (0, -3.4, 1.35), (0, 0, 1.05))
scene.render.filepath = OUT + 'kyai-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER depan selesai')
scene.camera = kamera('Cam_Samping', (3.4, -0.35, 1.35), (0, 0, 1.05))
scene.render.filepath = OUT + 'kyai-samping.png'
bpy.ops.render.render(write_still=True)
print('RENDER samping selesai')

for o in list(bpy.data.objects):
    if o.type == 'LIGHT' or o.type == 'CAMERA' or o.name.startswith('GEO-panggung'):
        bpy.data.objects.remove(o, do_unlink=True)
tot = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == 'MESH')
print('TOTAL POLIGON SEBELUM EXPORT:', tot)
bpy.ops.wm.save_as_mainfile(filepath=OUT + 'ust-aqsal.blend')
print('BLEND tersimpan')
bpy.ops.export_scene.gltf(filepath=OUT + 'ust-aqsal.glb', export_format='GLB',
                          export_yup=True, export_apply=True)
print('EXPORT GLB selesai')
print('SELESAI-TAHAP8')
