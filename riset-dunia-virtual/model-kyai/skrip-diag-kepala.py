import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

# Sembunyikan semua kecuali kepala + jenggot + kumis + mata
for o in bpy.data.objects:
    if o.type == 'MESH':
        keep = any(k in o.name for k in ['head', 'jenggot', 'kumis', 'eyes', 'teeth'])
        o.hide_render = not keep
        print(('TAMPIL ' if keep else 'SEMBUNYI ') + o.name)

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
lampu('DepanBawah', (0, -2.0, 0.6), 150, 1.0, (math.radians(80), 0, 0))

def kamera(nama, lokasi, target):
    bpy.ops.object.camera_add(location=lokasi)
    cam = bpy.context.active_object
    cam.name = nama
    arah = Vector(target) - cam.location
    cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
    return cam

scene.camera = kamera('Cam_Diag_Depan', (0, -0.9, 1.70), (0, 0, 1.66))
scene.render.filepath = OUT + 'diag-kepala-depan.png'
bpy.ops.render.render(write_still=True)
scene.camera = kamera('Cam_Diag_Samping', (0.9, -0.15, 1.70), (0, 0, 1.66))
scene.render.filepath = OUT + 'diag-kepala-samping.png'
bpy.ops.render.render(write_still=True)
print('SELESAI-DIAG-KEPALA')
