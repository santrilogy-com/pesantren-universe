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
    else:
        # Setel ulang warna (jubah/serban sedikit diredupkan supaya lipatan kebaca)
        if m.use_nodes:
            b = m.node_tree.nodes.get('Principled BSDF')
            if b:
                b.inputs['Base Color'].default_value = (*warna, 1.0)
    return m

MAT_jubah = ambil_material('MAT-jubah', (0.92, 0.92, 0.90), 0.95)
MAT_serban = ambil_material('MAT-serban', (0.90, 0.90, 0.87), 0.95)
MAT_jenggot = ambil_material('MAT-jenggot', (0.05, 0.04, 0.03), 0.95)
MAT_kancing = ambil_material('MAT-kancing', (0.85, 0.85, 0.82), 0.9)

# ---------- 1. Ratakan deltoid badan supaya masuk ke dalam jubah ----------
body = bpy.data.objects['maasai-style-herder_body']
mw = body.matrix_world
inv = mw.inverted()
n_kena = 0
for v in body.data.vertices:
    w = mw @ v.co
    if w.z > 1.40 and abs(w.x) > 0.10:
        w.x *= 0.80
        v.co = inv @ w
        n_kena += 1
# Ukur bahu baru
xs = []
for v in body.data.vertices:
    w = mw @ v.co
    if w.z > 1.40:
        xs.append(abs(w.x))
print('DELTOID diratakan:', n_kena, 'verteks | R bahu baru:', round(max(xs), 3))

# ---------- 2. Hapus bagian lama yang dibangun ulang ----------
HAPUS = ['GEO-jubah', 'GEO-lengan-kiri', 'GEO-lengan-kanan', 'GEO-kerah',
         'GEO-kancing-1', 'GEO-kancing-2', 'GEO-kancing-3', 'GEO-kancing-4',
         'GEO-kancing-5', 'GEO-serban', 'GEO-jenggot', 'GEO-kumis']
for nm in HAPUS:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
        print('Dihapus:', nm)

# ---------- 3. JUBAH: bahu lebih lebar + lipatan lebih dalam ----------
PROFIL = [
    (1.56, 0.095), (1.55, 0.165), (1.54, 0.185), (1.52, 0.205),
    (1.49, 0.214), (1.45, 0.220), (1.40, 0.224), (1.35, 0.228),
    (1.30, 0.232), (1.15, 0.248), (1.00, 0.260), (0.80, 0.280),
    (0.60, 0.305), (0.40, 0.330), (0.25, 0.355), (0.10, 0.380),
]
N_SEG = 54
N_LIPAT = 9

def amp_lipatan(z):
    t = max(0.0, min(1.0, (1.45 - z) / 1.35))
    return 0.015 + 0.045 * t

def faktor_lipat(z, th):
    return (1.0 + amp_lipatan(z) * math.sin(N_LIPAT * th + math.pi)
            + 0.012 * math.sin(17 * th + 1.0)
            + 0.004 * math.sin(3 * th + z * 8.0))

def interp_r(z):
    for i in range(len(PROFIL) - 1):
        z0, r0 = PROFIL[i]
        z1, r1 = PROFIL[i + 1]
        if z1 <= z <= z0:
            t = (z0 - z) / (z0 - z1) if z0 != z1 else 0.0
            return r0 + t * (r1 - r0)
    return PROFIL[-1][1] if z < PROFIL[-1][0] else PROFIL[0][1]

verts, faces = [], []
for ri, (z, r0) in enumerate(PROFIL):
    for j in range(N_SEG + 1):
        th = math.pi + 2 * math.pi * j / N_SEG
        r = r0 * faktor_lipat(z, th)
        zz = z
        if ri == len(PROFIL) - 1:
            zz = z - 0.020 * math.sin(N_LIPAT * th + math.pi) + 0.008 * math.sin(3 * th + 0.7)
        verts.append((r * math.cos(th), r * math.sin(th), zz))
for ri in range(len(PROFIL) - 1):
    for j in range(N_SEG):
        a = ri * (N_SEG + 1) + j
        b = a + 1
        c = (ri + 1) * (N_SEG + 1) + j + 1
        d = (ri + 1) * (N_SEG + 1) + j
        faces.append((a, b, c, d))
me = bpy.data.meshes.new('GEO-jubah-mesh')
me.from_pydata(verts, [], faces)
me.update()
for p in me.polygons:
    p.use_smooth = True
jubah = bpy.data.objects.new('GEO-jubah', me)
bpy.context.collection.objects.link(jubah)
me.materials.append(MAT_jubah)
print('JUBAH lipatan dibuat, poligon:', len(me.polygons))

# ---------- 4. LENGAN terpisah (sama seperti tahap 9) ----------
def lengan(nama, sisi):
    PROF = [
        (0.225, 1.46, 0.068),
        (0.245, 1.30, 0.064),
        (0.270, 1.12, 0.060),
        (0.295, 0.95, 0.056),
        (0.320, 0.78, 0.052),
    ]
    NS = 24
    vs, fs = [], []
    for (x, z, r0) in PROF:
        for j in range(NS + 1):
            th0 = math.pi / 2 if sisi > 0 else -math.pi / 2
            th = th0 + 2 * math.pi * j / NS
            r = r0 * (1.0 + 0.020 * math.sin(6 * th + 0.5))
            vs.append((sisi * x + r * math.cos(th), r * math.sin(th), z))
    for ri in range(len(PROF) - 1):
        for j in range(NS):
            a = ri * (NS + 1) + j
            b = a + 1
            c = (ri + 1) * (NS + 1) + j + 1
            d = (ri + 1) * (NS + 1) + j
            fs.append((a, b, c, d))
    m = bpy.data.meshes.new(nama + '-mesh')
    m.from_pydata(vs, [], fs)
    m.update()
    for p in m.polygons:
        p.use_smooth = True
    o = bpy.data.objects.new(nama, m)
    bpy.context.collection.objects.link(o)
    m.materials.append(MAT_jubah)
    print(nama, 'dibuat, poligon:', len(m.polygons))
    return o
lengan('GEO-lengan-kanan', 1)
lengan('GEO-lengan-kiri', -1)

# ---------- 5. Kancing di atas lipatan depan ----------
TH_DEPAN = -math.pi / 2
for i, z in enumerate([1.48, 1.40, 1.32, 1.24, 1.16], start=1):
    rf = interp_r(z) * faktor_lipat(z, TH_DEPAN)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12,
                                          location=(0, -(rf + 0.003), z))
    k = bpy.context.active_object
    k.name = f'GEO-kancing-{i}'
    k.scale = (0.011, 0.006, 0.011)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for p in k.data.polygons:
        p.use_smooth = True
    k.data.materials.append(MAT_kancing)
print('KANCING dibuat')

# ---------- 6. SERBAN lilitan (lebih ramping + lebih pendek) ----------
bagian = []
for i in range(5):
    z = 1.835 + i * 0.017
    R = 0.092 + 0.003 * math.sin(i * 1.3)
    dx = 0.003 * math.sin(i * 2.1)
    dy = 0.003 * math.cos(i * 1.7)
    bpy.ops.mesh.primitive_torus_add(major_radius=R, minor_radius=0.022,
                                     major_segments=32, minor_segments=12,
                                     location=(dx, dy, z))
    t = bpy.context.active_object
    t.name = f'GEO-serban-cincin-{i+1}'
    t.data.materials.append(MAT_serban)
    bagian.append(t)
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16,
                                      location=(0, 0, 1.905))
tutup = bpy.context.active_object
tutup.name = 'GEO-serban-tutup'
tutup.scale = (0.075, 0.075, 0.040)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
for p in tutup.data.polygons:
    p.use_smooth = True
tutup.data.materials.append(MAT_serban)
bagian.append(tutup)
bpy.ops.mesh.primitive_cube_add(location=(0, 0.100, 1.73))
ekor = bpy.context.active_object
ekor.name = 'GEO-ekor-serban'
ekor.scale = (0.030, 0.007, 0.170)
ekor.rotation_euler = (0.05, 0, 0)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
ekor.data.materials.append(MAT_serban)
bagian.append(ekor)
bpy.ops.object.select_all(action='DESELECT')
for o in bagian:
    o.select_set(True)
bpy.context.view_layer.objects.active = bagian[0]
bpy.ops.object.join()
serban = bpy.context.active_object
serban.name = 'GEO-serban'
print('SERBAN lilitan dibuat, poligon:', len(serban.data.polygons))

# ---------- 7. KUMIS satu bentuk ----------
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16,
                                      location=(0, -0.089, 1.686))
kumis = bpy.context.active_object
kumis.name = 'GEO-kumis'
kumis.scale = (0.030, 0.008, 0.0065)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
for p in kumis.data.polygons:
    p.use_smooth = True
kumis.data.materials.append(MAT_jenggot)
print('KUMIS dibuat')

# ---------- 8. JENGGOT pendek (berakhir di atas kerah jubah) ----------
PROFIL_J = [
    (1.658, -0.088, 0.042),
    (1.632, -0.075, 0.058),
    (1.600, -0.070, 0.066),
    (1.570, -0.068, 0.056),
    (1.545, -0.060, 0.038),
    (1.535, -0.050, 0.016),
]
Y_BELAKANG = 0.015
N = 13
vs, fs = [], []
for (z, y_depan, w) in PROFIL_J:
    for i in range(N):
        th = -math.pi / 2 + math.pi * i / (N - 1)
        x = w * math.sin(th)
        y = Y_BELAKANG + (y_depan - Y_BELAKANG) * math.cos(th)
        vs.append((x, y, z))
for r in range(len(PROFIL_J) - 1):
    for i in range(N - 1):
        a = r * N + i; b = r * N + i + 1
        c = (r + 1) * N + i + 1; d = (r + 1) * N + i
        fs.append((a, b, c, d))
tip = len(vs)
vs.append((0, (PROFIL_J[-1][1] + Y_BELAKANG) / 2, PROFIL_J[-1][0] - 0.004))
last = (len(PROFIL_J) - 1) * N
for i in range(N - 1):
    fs.append((last + i, last + i + 1, tip))
mj = bpy.data.meshes.new('GEO-jenggot-mesh')
mj.from_pydata(vs, [], fs)
mj.update()
for p in mj.polygons:
    p.use_smooth = True
jenggot = bpy.data.objects.new('GEO-jenggot', mj)
bpy.context.collection.objects.link(jenggot)
mod = jenggot.modifiers.new(name='Tebal', type='SOLIDIFY')
mod.thickness = 0.004
mj.materials.append(MAT_jenggot)
print('JENGGOT pendek dibuat, poligon:', len(mj.polygons))

# ---------- 9. Render ulang (lampu diredupkan supaya lipatan kebaca) ----------
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
lampu('Key', (2.0, -2.5, 3.0), 500, 1.2, (math.radians(55), 0, math.radians(20)))
lampu('Fill', (-2.0, -2.0, 1.5), 200, 1.0, (math.radians(55), 0, math.radians(-25)))
lampu('Rim', (0, 2.5, 2.0), 400, 1.0, (math.radians(120), 0, 0))
lampu('DepanBawah', (0, -2.0, 0.6), 100, 1.0, (math.radians(80), 0, 0))
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

# ---------- 10. Hapus studio, simpan + export GLB ----------
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
print('SELESAI-TAHAP10')
