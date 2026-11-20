import bpy, math, os

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
GLB = OUT + 'herder-asli.glb'

# Bersihkan scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Impor GLB
bpy.ops.import_scene.gltf(filepath=GLB)

print('=== OBJEK SETELAH IMPOR ===')
for o in bpy.data.objects:
    if o.type == 'MESH':
        me = o.data
        print(f"MESH {o.name}: verts={len(me.vertices)} tris={len(me.polygons)} mats={[m.name if m else None for m in me.materials]}")
    else:
        print(f"{o.type} {o.name}")

# Ukur bounding box keseluruhan + kepala (cari objek dengan 'Head' di nama atau tulang Head)
import mathutils
deps = bpy.context.evaluated_depsgraph_get()
mins = mathutils.Vector((1e9, 1e9, 1e9))
maxs = mathutils.Vector((-1e9, -1e9, -1e9))
for o in bpy.data.objects:
    if o.type == 'MESH':
        for c in o.bound_box:
            w = o.matrix_world @ mathutils.Vector(c)
            mins = mathutils.Vector(map(min, mins, w))
            maxs = mathutils.Vector(map(max, maxs, w))
print(f"TOTAL BBOX min={tuple(round(v,3) for v in mins)} max={tuple(round(v,3) for v in maxs)} tinggi={maxs.z-mins.z:.3f}")

# Kepala: cari mesh yang mengandung 'Head' di nama
for o in bpy.data.objects:
    if o.type == 'MESH' and 'head' in o.name.lower():
        bb = [o.matrix_world @ mathutils.Vector(c) for c in o.bound_box]
        xs = [v.x for v in bb]; ys = [v.y for v in bb]; zs = [v.z for v in bb]
        print(f"KEPALA {o.name}: x[{min(xs):.3f},{max(xs):.3f}] y[{min(ys):.3f},{max(ys):.3f}] z[{min(zs):.3f},{max(zs):.3f}]")

# --- Studio sederhana untuk render verifikasi ---
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.cycles.device = 'CPU'
scene.render.resolution_x = 768
scene.render.resolution_y = 1024
scene.render.film_transparent = False
world = bpy.data.worlds['World']
world.use_nodes = True
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.05, 0.05, 0.07, 1.0)
bg.inputs['Strength'].default_value = 1.0

# Lampu: key + fill + rim
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

# Lantai panggung bundar gelap (ala Syumra)
bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=0.08, location=(0, 0, -0.04))
panggung = bpy.context.active_object
panggung.name = 'GEO-panggung'
mat = bpy.data.materials.new('MAT-panggung')
mat.use_nodes = True
b = mat.node_tree.nodes['Principled BSDF']
b.inputs['Base Color'].default_value = (0.08, 0.08, 0.10, 1.0)
b.inputs['Roughness'].default_value = 0.6
panggung.data.materials.append(mat)

# Kamera depan (seluruh tubuh)
bpy.ops.object.camera_add(location=(0, -3.4, 1.35))
cam = bpy.context.active_object
cam.name = 'Cam_Depan'
cam.rotation_euler = (math.radians(88), 0, 0)
# arahkan ke tengah badan (0,0,0.95)
arah = mathutils.Vector((0, 0, 0.95)) - cam.location
cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
scene.camera = cam
scene.render.filepath = OUT + 'cek-asli-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER depan selesai')

# Kamera close-up wajah
bpy.ops.object.camera_add(location=(0.25, -0.9, 1.72))
cam2 = bpy.context.active_object
cam2.name = 'Cam_Wajah'
arah2 = mathutils.Vector((0, 0, 1.66)) - cam2.location
cam2.rotation_euler = arah2.to_track_quat('-Z', 'Y').to_euler()
scene.camera = cam2
scene.render.filepath = OUT + 'cek-asli-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER wajah selesai')
print('SELESAI-TAHAP1')
