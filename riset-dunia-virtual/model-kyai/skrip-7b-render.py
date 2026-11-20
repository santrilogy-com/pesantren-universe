import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

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

# Panggung
bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=0.06, location=(0, 0, -0.03))
pg = bpy.context.active_object
pg.name = 'GEO-panggung'
m = bpy.data.materials.new('MAT-panggung')
m.use_nodes = True
m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.02, 0.02, 0.02, 1.0)
pg.data.materials.append(m)

def kamera(nama, lokasi, target):
    bpy.ops.object.camera_add(location=lokasi)
    cam = bpy.context.active_object
    cam.name = nama
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
print('SELESAI-RENDER-7B')
