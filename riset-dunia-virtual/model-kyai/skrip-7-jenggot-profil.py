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

# ---------- 1. Hapus jenggot + kumis lama ----------
for nm in ['GEO-jenggot', 'GEO-kumis-kiri', 'GEO-kumis-kanan']:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
        print('Dihapus:', nm)

# ---------- 2. Jenggot baru: cangkang mengikuti profil wajah ----------
# Profil depan (z, y_depan, setengah-lebar) dari bibir bawah ke bawah dagu.
# y diukur dari profil kepala asli (bibir -0.097, dagu -0.035, leher -0.04).
PROFIL = [
    (1.652, -0.086, 0.052),   # tepat di bawah bibir bawah (bibir depan -0.09)
    (1.630, -0.074, 0.072),   # bawah mulut, depan dagu
    (1.600, -0.070, 0.080),   # dagu, paling lebar
    (1.560, -0.068, 0.070),   # bawah dagu
    (1.520, -0.062, 0.055),   # menggantung di depan leher
    (1.495, -0.045, 0.030),   # ujung bawah, melengkung ke belakang
]
Y_BELAKANG = 0.015  # sisi cangkang masuk ke dalam kepala (tersembunyi)
N = 13  # verteks per cincin (busur -90..+90 derajat)

verts = []
faces = []
for (z, y_depan, w) in PROFIL:
    for i in range(N):
        th = -math.pi / 2 + math.pi * i / (N - 1)  # -90..+90
        x = w * math.sin(th)
        y = Y_BELAKANG + (y_depan - Y_BELAKANG) * math.cos(th)
        verts.append((x, y, z))
for r in range(len(PROFIL) - 1):
    for i in range(N - 1):
        a = r * N + i
        b = r * N + i + 1
        c = (r + 1) * N + i + 1
        d = (r + 1) * N + i
        faces.append((a, b, c, d))
# Tutup ujung bawah (kipas ke satu titik tengah)
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
print('JENGGOT profil dibuat, poligon:', len(me.polygons))

# ---------- 3. Kumis baru: menempel di bibir atas, menyatu ----------
def kumis(nama, x):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16,
                                          location=(x, -0.090, 1.685))
    k = bpy.context.active_object
    k.name = nama
    k.scale = (0.020, 0.008, 0.007)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for p in k.data.polygons:
        p.use_smooth = True
    k.data.materials.append(MAT_jenggot)
    return k
kumis('GEO-kumis-kiri', -0.015)
kumis('GEO-kumis-kanan', 0.015)
print('KUMIS dibuat ulang (di bibir atas, menyatu)')

# ---------- 4. Render ulang ----------
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.device = 'CPU'
scene.cycles.use_denoising = False
scene.render.resolution_x = 768
scene.render.resolution_y = 1024

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

scene.camera = kamera('Cam_Depan', (0, -3.4, 1.35), (0, 0, 1.05))
scene.render.filepath = OUT + 'kyai-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER depan selesai')
scene.camera = kamera('Cam_Samping', (3.4, -0.35, 1.35), (0, 0, 1.05))
scene.render.filepath = OUT + 'kyai-samping.png'
bpy.ops.render.render(write_still=True)
print('RENDER samping selesai')
scene.camera = kamera('Cam_Wajah', (0.25, -0.9, 1.72), (0, 0, 1.66))
scene.render.filepath = OUT + 'kyai-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah selesai')

# ---------- 5. Hapus studio + kamera render, simpan + export GLB ----------
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
print('SELESAI-TAHAP7')
