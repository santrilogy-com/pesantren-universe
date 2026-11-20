import bpy, math, mathutils, numpy as np
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
GLB = OUT + 'herder-asli.glb'

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.gltf(filepath=GLB)

HAPUS = ['Icosphere', 'top', 'bottoms', 'collar', 'bands', 'prop']
for o in list(bpy.data.objects):
    if o.type == 'MESH' and any(k in o.name for k in HAPUS):
        print('HAPUS:', o.name)
        bpy.data.objects.remove(o, do_unlink=True)

# Armature tidak dipakai lagi (pose dilakukan langsung pada verteks body)
arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
bahu_kiri = Vector((0.19, 0.024, 1.536))   # dari matrix_local tulang LeftArm
bahu_kanan = Vector((-0.19, 0.024, 1.536))
for o in list(bpy.data.objects):
    if o.type == 'MESH':
        for mod in list(o.modifiers):
            if mod.type == 'ARMATURE':
                o.modifiers.remove(mod)
bpy.data.objects.remove(arm, do_unlink=True)
print('ARMATURE dihapus (pose via verteks)')

# --- Pose lengan: putar verteks lengan ke bawah mengelilingi bahu,
# dengan blend halus di dekat bahu supaya tidak robek. ---
import bmesh
def smoothstep(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)

def putar_lengan(obj, pivot, arah_x, sudut_deg):
    me = obj.data
    bm = bmesh.new()
    bm.from_mesh(me)
    th = math.radians(sudut_deg)
    P = Vector(pivot)
    n = 0
    for v in bm.verts:
        d = v.co - P
        s = d.x * arah_x  # jarak sepanjang sumbu lengan (positif ke arah luar)
        w = smoothstep(0.02, 0.12, s)
        if w <= 0:
            continue
        ang = th * w
        c, sn = math.cos(ang), math.sin(ang)
        x, y, z = d.x, d.y, d.z
        v.co = P + Vector((x * c + z * sn, y, -x * sn + z * c))
        n += 1
    bm.to_mesh(me)
    bm.free()
    me.update()
    print(f'PUTAR lengan {obj.name}: {n} verteks digerakkan (arah_x={arah_x}, sudut={sudut_deg})')

body = next(o for o in bpy.data.objects if o.type == 'MESH' and 'body' in o.name)
putar_lengan(body, bahu_kiri, +1, 84)
putar_lengan(body, bahu_kanan, -1, -84)
# normal halus kembali
bpy.context.view_layer.objects.active = body
bpy.ops.object.shade_smooth()
print('POSE verteks selesai')

# --- Landmark wajah dari mesh kepala (terukur) ---
deps = bpy.context.evaluated_depsgraph_get()
def verts_dunia(obj):
    ev = obj.evaluated_get(deps)
    me = ev.to_mesh()
    out = [obj.matrix_world @ v.co for v in me.vertices]
    ev.to_mesh_clear()
    return out

head = next(o for o in bpy.data.objects if o.type == 'MESH' and 'head' in o.name)
hv = verts_dunia(head)
print(f"KEPALA bbox x[{min(v.x for v in hv):.3f},{max(v.x for v in hv):.3f}] y[{min(v.y for v in hv):.3f},{max(v.y for v in hv):.3f}] z[{min(v.z for v in hv):.3f},{max(v.z for v in hv):.3f}]")
wajah = [v for v in hv if 1.58 < v.z < 1.85]
hidung = min(wajah, key=lambda v: v.y)
print(f"UJUNG HIDUNG: {tuple(round(v,3) for v in hidung)}")
depan = [v for v in hv if v.y < -0.04]
dagu = min(depan, key=lambda v: v.z)
print(f"DAGU (z terendah depan): {tuple(round(v,3) for v in dagu)}")
rahang = [v for v in hv if abs(v.z - (dagu.z + 0.02)) < 0.015]
if rahang:
    print(f"RAHANG z~{dagu.z+0.02:.3f}: x[{min(v.x for v in rahang):.3f},{max(v.x for v in rahang):.3f}] yDepan {min(v.y for v in rahang):.3f}")
eyes = next(o for o in bpy.data.objects if o.type == 'MESH' and 'eyes' in o.name)
evv = verts_dunia(eyes)
print(f"MATA bbox x[{min(v.x for v in evv):.3f},{max(v.x for v in evv):.3f}] y[{min(v.y for v in evv):.3f},{max(v.y for v in evv):.3f}] z[{min(v.z for v in evv):.3f},{max(v.z for v in evv):.3f}]")
bv = verts_dunia(body)
print(f"BODY bbox x[{min(v.x for v in bv):.3f},{max(v.x for v in bv):.3f}] y[{min(v.y for v in bv):.3f},{max(v.y for v in bv):.3f}] z[{min(v.z for v in bv):.3f},{max(v.z for v in bv):.3f}]")
tangan = [v for v in bv if abs(v.x) > 0.18 and v.z < 1.1]
if tangan:
    print(f"TANGAN: z min {min(v.z for v in tangan):.3f} (ujung jari), x +{max(v.x for v in tangan):.3f} / {min(v.x for v in tangan):.3f}")
else:
    print('TANGAN: tidak ada verteks |x|>0.18 di bawah z=1.1 (POSE GAGAL?)')

# --- Terangkan warna kulit (Maasai gelap -> sawo matang), hanya peta base color material skin ---
FAKTOR = 1.35
skin_mat = bpy.data.materials.get('skin')
if skin_mat and skin_mat.use_nodes:
    for node in skin_mat.node_tree.nodes:
        if node.type == 'TEX_IMAGE' and node.image:
            ke_base = any(l.to_node.type == 'BSDF_PRINCIPLED' and l.to_socket.name == 'Base Color'
                          for l in skin_mat.node_tree.links if l.from_node == node)
            if ke_base:
                img = node.image
                print(f"KULIT: mencerahkan {img.name} {img.size[0]}x{img.size[1]} x{FAKTOR}")
                px = np.array(img.pixels[:], dtype=np.float32).reshape(-1, 4)
                px[:, :3] = np.clip(px[:, :3] * FAKTOR, 0.0, 1.0)
                img.pixels = px.flatten().tolist()
                img.update()
                print('KULIT: selesai')

bpy.ops.wm.save_as_mainfile(filepath=OUT + 'ust-aqsal-pose.blend')
print('BLEND tersimpan')

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
pg = bpy.context.active_object
pg.name = 'GEO-panggung'
mat = bpy.data.materials.new('MAT-panggung')
mat.use_nodes = True
mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.08, 0.08, 0.10, 1.0)
mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value = 0.6
pg.data.materials.append(mat)

def kamera(nama, lokasi, target):
    bpy.ops.object.camera_add(location=lokasi)
    cam = bpy.context.active_object
    cam.name = nama
    arah = Vector(target) - cam.location
    cam.rotation_euler = arah.to_track_quat('-Z', 'Y').to_euler()
    return cam

scene.camera = kamera('Cam_Depan', (0, -3.4, 1.35), (0, 0, 0.95))
scene.render.filepath = OUT + 'cek-pose-depan.png'
bpy.ops.render.render(write_still=True)
print('RENDER pose depan selesai')
scene.camera = kamera('Cam_Wajah', (0.25, -0.9, 1.72), (0, 0, 1.66))
scene.render.filepath = OUT + 'cek-pose-wajah.png'
bpy.ops.render.render(write_still=True)
print('RENDER pose wajah selesai')
print('SELESAI-TAHAP2')
