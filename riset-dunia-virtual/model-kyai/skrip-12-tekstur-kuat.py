import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

# ---------- 1. Reload tekstur lipatan (versi kontras lebih kuat) ----------
img = bpy.data.images.get('lipatan-jubah.png')
if img is None:
    img = bpy.data.images.load(OUT + 'lipatan-jubah.png')
else:
    img.reload()
print('DIAG tekstur:', img.name, '| piksel[0]=',
      [round(v, 3) for v in img.pixels[:4]])

# ---------- 2. Penutup leher: naikkan + besarkan (tutup celah hitam) ----------
o = bpy.data.objects.get('GEO-leher-dalam')
if o:
    bpy.data.objects.remove(o, do_unlink=True)
    print('Dihapus: GEO-leher-dalam lama')

def ambil_material(nama, warna, rough=0.95):
    m = bpy.data.materials.get(nama)
    if m is None:
        m = bpy.data.materials.new(name=nama)
        m.use_nodes = True
        b = m.node_tree.nodes['Principled BSDF']
        b.inputs['Base Color'].default_value = (*warna, 1.0)
        b.inputs['Roughness'].default_value = rough
    return m

MAT_kulit = ambil_material('MAT-kulit-polos', (0.55, 0.38, 0.30), 0.9)
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.100, depth=0.012,
                                     location=(0, 0, 1.555))
leher = bpy.context.active_object
leher.name = 'GEO-leher-dalam'
leher.data.materials.append(MAT_kulit)
print('PENUTUP LEHER baru dibuat (r=0.100, z=1.555)')

# ---------- 3. Render ulang ----------
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

# ---------- 4. Hapus studio, simpan + export GLB ----------
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
print('SELESAI-TAHAP12')
