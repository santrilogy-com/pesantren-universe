import bpy, math, mathutils, os

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
GLB = OUT + 'herder-asli.glb'

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

bpy.ops.import_scene.gltf(filepath=GLB)

print('=== OBJEK SETELAH IMPOR ===')
for o in bpy.data.objects:
    if o.type == 'MESH':
        print(f"MESH {o.name}: verts={len(o.data.vertices)} tris={len(o.data.polygons)} loc={tuple(round(v,2) for v in o.location)}")

# Hapus Icosphere liar (tanpa material, bukan bagian model)
for o in list(bpy.data.objects):
    if o.type == 'MESH' and o.name.startswith('Icosphere'):
        print('HAPUS stray:', o.name, 'loc', tuple(o.location))
        bpy.data.objects.remove(o, do_unlink=True)

# BBox dunia dari mesh hasil evaluasi (tulang ikut dihitung)
deps = bpy.context.evaluated_depsgraph_get()
mins = mathutils.Vector((1e9, 1e9, 1e9))
maxs = mathutils.Vector((-1e9, -1e9, -1e9))
for o in bpy.data.objects:
    if o.type == 'MESH':
        ev = o.evaluated_get(deps)
        me = ev.to_mesh()
        mw = o.matrix_world
        for v in me.vertices:
            w = mw @ v.co
            mins = mathutils.Vector(map(min, mins, w))
            maxs = mathutils.Vector(map(max, maxs, w))
        ev.to_mesh_clear()
print(f"BBOX-DUNIA min={tuple(round(v,3) for v in mins)} max={tuple(round(v,3) for v in maxs)} tinggi={maxs.z-mins.z:.3f} lebar={maxs.x-mins.x:.3f}")

scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.device = 'CPU'
scene.cycles.use_denoising = False   # build Ubuntu tanpa OpenImageDenoiser
scene.render.resolution_x = 768
scene.render.resolution_y = 1024
world = bpy.data.worlds['World']
world.use_nodes = True
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.05, 0.05, 0.07, 1.0)
bg.inputs['Strength'].default_value = 1.0

def lampu(nama, lokasi, energi, ukuran=0.5):
    bpy.ops.object.light_add(type='AREA', location=lokasi)
    l = bpy.context.active_object
    l.name = nama
    l.data.energy = energi
    l.data.shape = 'DISK'
    l.data.size = ukuran
    l.rotation_euler = (math.radians(50), 0, math.radians(15))
    return l

lampu('Key', (2.0, -2.5, 3.0), 800, 1.2)
lampu('Fill', (-2.0, -2.0, 1.5), 300, 1.0)
lampu('Rim', (0.0, 2.5, 2.5), 500, 0.8)

bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=0.08, location=(0, 0, -0.04))
panggung = bpy.context.active_object
panggung.name = 'GEO-panggung'
mat = bpy.data.materials.new('MAT-panggung')
mat.use_nodes = True
b = mat.node_tree.nodes['Principled BSDF']
b.inputs['Base Color'].default_value = (0.08, 0.08, 0.10, 1.0)
b.inputs['Roughness'].default_value = 0.6
panggung.data.materials.append(mat)

def kamera(nama, lokasi, target):
    bpy.ops.object.camera_add(location=lokasi)
    cam = bpy.context.active_object
    cam.name = nama
    arah = mathutils.Vector(target) - cam.location
    cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
    return cam

scene.camera = kamera('Cam_Depan', (0, -3.4, 1.35), (0, 0, 0.95))
scene.render.filepath = OUT + 'cek-asli-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER depan selesai')

scene.camera = kamera('Cam_Wajah', (0.25, -0.9, 1.72), (0, 0, 1.66))
scene.render.filepath = OUT + 'cek-asli-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah selesai')
print('SELESAI-TAHAP1B')
