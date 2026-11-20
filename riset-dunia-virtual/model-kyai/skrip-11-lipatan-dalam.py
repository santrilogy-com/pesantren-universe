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

MAT_jubah = bpy.data.materials.get('MAT-jubah')
MAT_lengan = ambil_material('MAT-lengan', (0.92, 0.92, 0.90), 0.95)
MAT_kancing = ambil_material('MAT-kancing', (0.85, 0.85, 0.82), 0.9)
MAT_kulit = ambil_material('MAT-kulit-polos', (0.55, 0.38, 0.30), 0.9)

# ---------- 1. Hapus jubah + lengan + kancing lama ----------
for nm in ['GEO-jubah', 'GEO-lengan-kiri', 'GEO-lengan-kanan',
           'GEO-kancing-1', 'GEO-kancing-2', 'GEO-kancing-3',
           'GEO-kancing-4', 'GEO-kancing-5', 'GEO-leher-dalam']:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
        print('Dihapus:', nm)

# ---------- 2. Tekstur garis lipatan (selaras dengan lipatan geometri) ----------
# B(u) = 0.88 + 0.06*sin(18*pi*u) — terang di punggung lipatan, gelap di alur.
# (Dibuat via PIL sebagai file, karena img.pixels di sesi Blender ini gagal.)
img = bpy.data.images.load(OUT + 'lipatan-jubah.png')
img.colorspace_settings.name = 'sRGB'
print('DIAG tekstur dimuat:', img.name, img.size[:],
      '| piksel[0]=', [round(v,3) for v in img.pixels[:4]])
# Pasang tekstur ke MAT-jubah (Base Color putih supaya tekstur murni)
nt = MAT_jubah.node_tree
bsdf = nt.nodes.get('Principled BSDF')
bsdf.inputs['Base Color'].default_value = (1.0, 1.0, 1.0, 1.0)
# Hapus node tekstur lama (dari run sebelumnya yang hitam)
for n in [n for n in nt.nodes if n.type == 'TEX_IMAGE']:
    nt.nodes.remove(n)
tex = nt.nodes.new('ShaderNodeTexImage')
tex.image = img
tex.label = 'Garis lipatan'
nt.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
print('DIAG material MAT-jubah: links ke Base Color =',
      [(l.from_node.name, l.from_socket.name) for l in nt.links
       if l.to_socket.name == 'Base Color'])
print('TEKSTUR lipatan dipasang ke MAT-jubah')

# ---------- 3. JUBAH: lipatan lebih dalam + UV silinder ----------
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
    return 0.030 + 0.070 * t   # 3% bahu -> 10% hem

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

verts, faces, uvs = [], [], []
for ri, (z, r0) in enumerate(PROFIL):
    for j in range(N_SEG + 1):
        th = math.pi + 2 * math.pi * j / N_SEG
        r = r0 * faktor_lipat(z, th)
        zz = z
        if ri == len(PROFIL) - 1:
            zz = z - 0.020 * math.sin(N_LIPAT * th + math.pi) + 0.008 * math.sin(3 * th + 0.7)
        verts.append((r * math.cos(th), r * math.sin(th), zz))
        uvs.append(((th - math.pi) / (2 * math.pi), (z - 0.10) / 1.46))
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
uv_layer = me.uv_layers.new(name='UVMap')
for loop in me.loops:
    uv_layer.data[loop.index].uv = uvs[loop.vertex_index]
us = [uv[0] for uv in uvs]
vs_ = [uv[1] for uv in uvs]
print('DIAG UV jubah: u', round(min(us),3), round(max(us),3),
      '| v', round(min(vs_),3), round(max(vs_),3),
      '| jumlah loop:', len(me.loops))
for p in me.polygons:
    p.use_smooth = True
jubah = bpy.data.objects.new('GEO-jubah', me)
bpy.context.collection.objects.link(jubah)
me.materials.append(MAT_jubah)
print('JUBAH lipatan dalam + tekstur dibuat, poligon:', len(me.polygons))

# ---------- 4. LENGAN (material polos, tanpa tekstur) ----------
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
    m.materials.append(MAT_lengan)
    print(nama, 'dibuat, poligon:', len(m.polygons))
    return o
lengan('GEO-lengan-kanan', 1)
lengan('GEO-lengan-kiri', -1)

# ---------- 5. Kancing ----------
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

# ---------- 6. Penutup leher (piringan kulit, menutup lubang gelap) ----------
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.095, depth=0.012,
                                     location=(0, 0, 1.53))
leher = bpy.context.active_object
leher.name = 'GEO-leher-dalam'
leher.data.materials.append(MAT_kulit)
print('PENUTUP LEHER dibuat')

# ---------- 7. Render ulang ----------
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
lampu('Key', (2.0, -2.5, 3.0), 400, 1.2, (math.radians(55), 0, math.radians(20)))
lampu('Fill', (-2.0, -2.0, 1.5), 150, 1.0, (math.radians(55), 0, math.radians(-25)))
lampu('Rim', (0, 2.5, 2.0), 300, 1.0, (math.radians(120), 0, 0))
lampu('DepanBawah', (0, -2.0, 0.6), 80, 1.0, (math.radians(80), 0, 0))
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

# ---------- 8. Hapus studio, simpan + export GLB ----------
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
print('SELESAI-TAHAP11')
