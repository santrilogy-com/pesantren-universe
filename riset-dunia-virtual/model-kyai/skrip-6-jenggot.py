import bpy, math, os
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.wm.open_mainfile(filepath=OUT + 'ust-aqsal.blend')

# ---------- 1. Bersihkan lampu duplikat (.001) ----------
for o in list(bpy.data.objects):
    if o.type == 'LIGHT' and o.name.endswith('.001'):
        nm = o.name
        bpy.data.objects.remove(o, do_unlink=True)
        print('Lampu duplikat dihapus:', nm)

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

# ---------- 2. Hapus jenggot + kumis lama ----------
for nm in ['GEO-jenggot', 'GEO-kumis-kiri', 'GEO-kumis-kanan']:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
        print('Dihapus:', nm)

# ---------- 3. Jenggot baru: CANGKANG yang membungkus rahang ----------
# Bola -> buang bagian belakang (y > -0.005) dan atas (z > 1.628, di atas bibir bawah)
# -> cangkang depan-bawah yang menempel dagu/rahang dari telinga ke telinga.
bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=32,
                                      location=(0, -0.018, 1.575))
jenggot = bpy.context.active_object
jenggot.name = 'GEO-jenggot'
jenggot.scale = (0.088, 0.062, 0.075)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
me = jenggot.data
import bmesh
bm = bmesh.new()
bm.from_mesh(me)
bm.verts.ensure_lookup_table()
buang = [v for v in bm.verts if v.co.y > -0.005 or v.co.z > 1.628]
bmesh.ops.delete(bm, geom=buang, context='VERTS')
bm.to_mesh(me)
bm.free()
# Haluskan shading
for p in me.polygons:
    p.use_smooth = True
# Beri ketebalan supaya padat dari samping/bawah
mod = jenggot.modifiers.new(name='Tebal', type='SOLIDIFY')
mod.thickness = 0.006
me.materials.append(MAT_jenggot)
print('JENGGOT cangkang dibuat, poligon:', len(me.polygons))

# ---------- 4. Kumis baru: kecil, menempel di bibir atas ----------
def kumis(nama, x):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16,
                                          location=(x, -0.073, 1.652))
    k = bpy.context.active_object
    k.name = nama
    k.scale = (0.021, 0.010, 0.008)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for p in k.data.polygons:
        p.use_smooth = True
    k.data.materials.append(MAT_jenggot)
    return k
kumis('GEO-kumis-kiri', -0.017)
kumis('GEO-kumis-kanan', 0.017)
print('KUMIS dibuat ulang (menempel bibir atas)')

# ---------- 5. Verifikasi posisi jenggot vs dagu ----------
import mathutils
def bbox(o):
    bb = [o.matrix_world @ mathutils.Vector(c) for c in o.bound_box]
    xs = [v.x for v in bb]; ys = [v.y for v in bb]; zs = [v.z for v in bb]
    return (min(xs), max(xs)), (min(ys), max(ys)), (min(zs), max(zs))
print('GEO-jenggot bbox x/y/z:', bbox(jenggot))

# ---------- 6. Render ulang (studio sudah ada dari tahap 5) ----------
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

# Hapus kamera diag dari skrip diag (kalau ada) supaya tidak bingung
for nm in ['Cam_Diag_Depan', 'Cam_Diag_Samping']:
    o = bpy.data.objects.get(nm)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)

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

# ---------- 7. Hapus studio + kamera render, simpan + export GLB ----------
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
print('SELESAI-TAHAP6')
