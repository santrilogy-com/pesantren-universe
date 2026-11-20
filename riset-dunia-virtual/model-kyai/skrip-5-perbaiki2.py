import bpy, math, bmesh
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

def cari(nama):
    return bpy.data.objects.get(nama)

def ambil_material(nama, warna, rough=0.85):
    m = bpy.data.materials.get(nama)
    if m is None:
        m = bpy.data.materials.new(nama)
        m.use_nodes = True
        b = m.node_tree.nodes['Principled BSDF']
        b.inputs['Base Color'].default_value = (*warna, 1.0)
        b.inputs['Metallic'].default_value = 0.0
        b.inputs['Roughness'].default_value = rough
        print(f'MATERIAL dibuat ulang: {nama}')
    return m

MAT_jubah = ambil_material('MAT-jubah', (0.96, 0.96, 0.94))
MAT_serban = ambil_material('MAT-serban', (0.93, 0.93, 0.90))
MAT_jenggot = ambil_material('MAT-jenggot', (0.05, 0.04, 0.03), 0.95)
MAT_tasbih = ambil_material('MAT-tasbih', (0.20, 0.10, 0.04), 0.6)
MAT_kancing = ambil_material('MAT-kancing', (0.85, 0.85, 0.82), 0.5)
MAT_gelap = ambil_material('MAT-gelap', (0.02, 0.02, 0.02), 1.0)

def cek_mat(obj):
    print(f'  {obj.name}: mats={[m.name if m else None for m in obj.data.materials]}')

# --- 0. STUDIO (untuk render; dihapus sebelum export) ---
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
lampu('Key', (2.0, -2.5, 3.0), 900, 1.2, (math.radians(55), 0, math.radians(20)))
lampu('Fill', (-2.0, -2.0, 1.5), 350, 1.0, (math.radians(55), 0, math.radians(-25)))
lampu('Rim', (0.0, 2.5, 2.5), 600, 0.8, (math.radians(120), 0, 0))
lampu('DepanBawah', (0, -2.0, 0.6), 150, 1.0, (math.radians(80), 0, 0))
bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=0.08, location=(0, 0, -0.04))
pg = bpy.context.active_object
pg.name = 'GEO-panggung'
mat_pg = bpy.data.materials.new('MAT-panggung')
mat_pg.use_nodes = True
mat_pg.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.08, 0.08, 0.10, 1.0)
mat_pg.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value = 0.6
pg.data.materials.append(mat_pg)

body = cari('maasai-style-herder_body')

# --- 1. Ratakan bahu LEBIH KUAT (daerah ini tertutup jubah, aman) ---
me = body.data
bm = bmesh.new(); bm.from_mesh(me)
n = 0
for v in bm.verts:
    x, y, z = v.co.x, v.co.y, v.co.z
    if z > 1.42 and abs(x) > 0.10:
        nx = 0.10 + (abs(x) - 0.10) * 0.65
        v.co.x = math.copysign(nx, x)
        v.co.z = 1.42 + (z - 1.42) * 0.70
        n += 1
bm.to_mesh(me); bm.free(); me.update()
print(f'BAHU diratakan lagi: {n} verteks')
deps = bpy.context.evaluated_depsgraph_get()
ev = body.evaluated_get(deps); m2 = ev.to_mesh()
bv = [body.matrix_world @ v.co for v in m2.vertices]
ev.to_mesh_clear()
bahu_area = [v for v in bv if 1.42 < v.z < 1.62 and abs(v.x) > 0.10]
R_bahu = max(abs(v.x) for v in bahu_area)
Z_bahu = max(v.z for v in bahu_area)
print(f'BAHU baru: R={R_bahu:.3f} Ztop={Z_bahu:.3f}')

# --- 2. SERBAN: ganti tumpukan torus dengan SATU lathe beralur (lilitan menyatu) ---
for nm in ['GEO-serban-1', 'GEO-serban-2', 'GEO-serban-3', 'GEO-serban-4', 'GEO-serban-5',
           'GEO-serban-puncak', 'GEO-serban-inti']:
    o = cari(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
print('SERBAN lama dihapus')
profil = [
    (1.820, 0.090), (1.835, 0.100), (1.848, 0.096), (1.862, 0.104),
    (1.875, 0.098), (1.888, 0.103), (1.900, 0.096), (1.910, 0.082),
    (1.920, 0.060), (1.928, 0.030), (1.930, 0.0),
]
seg = 48
verts, faces = [], []
for (z, r) in profil:
    for j in range(seg):
        a = 2 * math.pi * j / seg
        verts.append((r * math.cos(a), r * math.sin(a) + 0.005, z))
for i in range(len(profil) - 1):
    for j in range(seg):
        j2 = (j + 1) % seg
        faces.append((i*seg+j, i*seg+j2, (i+1)*seg+j2, (i+1)*seg+j))
mesh = bpy.data.meshes.new('GEO-serban')
mesh.from_pydata(verts, [], faces)
mesh.update()
serban = bpy.data.objects.new('GEO-serban', mesh)
bpy.context.collection.objects.link(serban)
bm2 = bmesh.new(); bm2.from_mesh(mesh)
bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces)
bm2.to_mesh(mesh); bm2.free()
for p in mesh.polygons:
    p.use_smooth = True
mesh.update()
serban.data.materials.append(MAT_serban)
cek_mat(serban)
print('SERBAN lathe dibuat (satu mesh beralur)')

# --- 3. JENGGOT + KUMIS: bentuk ulang, menempel di rahang ---
for nm in ['GEO-jenggot', 'GEO-kumis-kiri', 'GEO-kumis-kanan']:
    o = cari(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=1.0, location=(0, -0.02, 1.565))
jenggot = bpy.context.active_object
jenggot.name = 'GEO-jenggot'
jenggot.scale = (0.075, 0.045, 0.065)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
jenggot.data.materials.append(MAT_jenggot)
cek_mat(jenggot)
for sisi, sx in [('kiri', 1), ('kanan', -1)]:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0, location=(sx*0.020, -0.078, 1.645))
    kum = bpy.context.active_object
    kum.name = f'GEO-kumis-{sisi}'
    kum.scale = (0.026, 0.011, 0.009)
    kum.rotation_euler = (0, 0, -sx * 0.3)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    kum.data.materials.append(MAT_jenggot)
    cek_mat(kum)
print('JENGGOT + KUMIS dibuat ulang (menempel rahang)')

# --- 4. JUBAH: bangun ulang, bahu landai mengikuti bahu yang sudah diratakan ---
for nm in ['GEO-jubah', 'GEO-tutup-dada', 'GEO-kerah',
           'GEO-kancing-1', 'GEO-kancing-2', 'GEO-kancing-3', 'GEO-kancing-4', 'GEO-kancing-5']:
    o = cari(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
rings = [
    (Z_bahu + 0.01, 0.09),
    (Z_bahu - 0.005, (R_bahu + 0.09) / 2 + 0.03),
    (Z_bahu - 0.03, R_bahu + 0.02),
    (1.44, R_bahu + 0.01),
    (1.30, 0.26),
    (1.05, 0.255),
    (0.80, 0.275),
    (0.50, 0.31),
    (0.25, 0.35),
    (0.10, 0.38),
]
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
print('JUBAH dibangun ulang, rings:', [(round(z, 2), round(r, 2)) for z, r in rings])

# penutup lubang leher: kecil + GELAP (terbaca sebagai bayangan, bukan nampan abu-abu)
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.13, depth=0.01, location=(0, 0, 1.46))
tutup = bpy.context.active_object
tutup.name = 'GEO-tutup-dada'
tutup.data.materials.append(MAT_gelap)
# kerah lebih besar menutup sambungan leher
bpy.ops.mesh.primitive_torus_add(major_radius=0.10, minor_radius=0.028, major_segments=32, minor_segments=12, location=(0, 0, 1.545))
kerah = bpy.context.active_object
kerah.name = 'GEO-kerah'
kerah.data.materials.append(MAT_jubah)

def jari_jubah(z):
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

# --- 5. LENGAN: tempelkan ke badan jubah (atas masuk ke dalam jubah) ---
for nm in ['GEO-lengan-kiri', 'GEO-lengan-kanan']:
    o = cari(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
def tabung_dua_titik(nama, p1, p2, r1, r2, mat, seg2=20):
    d = Vector(p2) - Vector(p1)
    tengah = (Vector(p1) + Vector(p2)) / 2
    bpy.ops.mesh.primitive_cone_add(vertices=seg2, radius1=r1, radius2=r2, depth=d.length, location=tengah)
    o = bpy.context.active_object
    o.name = nama
    o.rotation_mode = 'QUATERNION'
    o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d.normalized())
    o.data.materials.append(mat)
    return o
tabung_dua_titik('GEO-lengan-kiri', (0.19, 0.02, 1.46), (0.26, 0.02, 0.80), 0.10, 0.062, MAT_jubah)
tabung_dua_titik('GEO-lengan-kanan', (-0.19, 0.02, 1.46), (-0.26, 0.02, 0.80), 0.10, 0.062, MAT_jubah)
print('LENGAN ditempelkan ke badan jubah')

bpy.ops.wm.save_as_mainfile(filepath=OUT + 'ust-aqsal.blend')
print('BLEND tersimpan')

# --- 6. Render verifikasi ulang ---
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

# --- 7. Hapus studio, export GLB ---
for o in list(bpy.data.objects):
    if o.type in ('LIGHT', 'CAMERA') or o.name.startswith('GEO-panggung'):
        bpy.data.objects.remove(o, do_unlink=True)
tot = 0
for o in bpy.data.objects:
    if o.type == 'MESH':
        tot += len(o.data.polygons)
print(f'TOTAL POLIGON SEBELUM EXPORT: {tot}')
bpy.ops.export_scene.gltf(filepath=OUT + 'ust-aqsal.glb', export_format='GLB',
    export_apply=True, export_yup=True, export_materials='EXPORT',
    export_animations=False, export_normals=True, export_tangents=False)
print('EXPORT GLB selesai')
print('SELESAI-TAHAP5')
