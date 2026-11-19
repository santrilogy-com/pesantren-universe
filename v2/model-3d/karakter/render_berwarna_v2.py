#!/usr/bin/env python3
"""Render santri putra v2 BERWARNA: depan, samping, tiga-perempat.
Cycles CPU 768px 64 sampel — kamera sama seperti render clay v2.
Jalankan: blender -b santri-putra-v2-berwarna.blend --python render_berwarna_v2.py
Output: render/santri-putra-v2-berwarna_<view>.png (file BARU, jangan timpa clay)"""
import bpy
import math
import os
from mathutils import Vector

BLEND_DIR = os.path.dirname(os.path.abspath(bpy.data.filepath))
OUT_DIR = os.path.join(BLEND_DIR, "render")
os.makedirs(OUT_DIR, exist_ok=True)

zs = []
for o in bpy.data.objects:
    if o.type == "MESH":
        for v in o.bound_box:
            zs.append((o.matrix_world @ Vector(v)).z)
print("RENDER-CHECK tinggi nyata: %.3f m (puncak peci)" % max(zs))

VIEWS = [
    ("depan", (0, -2.1, 0.55), (0, 0, 0.50), 50),
    ("samping", (2.1, 0, 0.55), (0, 0, 0.50), 50),
    ("tiga-perempat", (1.5, -1.5, 0.85), (0, 0, 0.48), 50),
]

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.cycles.max_bounces = 4
scene.render.resolution_x = 768
scene.render.resolution_y = 768

HDRI = "/home/hatch/workspace/pesantren-verse/v2/model-3d/lingkungan/tekstur/kloppenheim_06_puresky_2k.hdr"
world = bpy.data.worlds["World"] if bpy.data.worlds else bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes["Background"]
env = world.node_tree.nodes.new("ShaderNodeTexEnvironment")
env.image = bpy.data.images.load(HDRI)
world.node_tree.links.new(env.outputs["Color"], bg.inputs["Color"])
bg.inputs[1].default_value = 0.7

bpy.ops.mesh.primitive_plane_add(size=120, location=(0, 0, -0.01))
g = bpy.context.object
g.name = "TanahRender"
m = bpy.data.materials.new("Tanah")
m.use_nodes = True
m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.85, 0.83, 0.75, 1.0)
g.data.materials.append(m)


def sun(name, rot, energy, color):
    d = bpy.data.lights.new(name, "SUN")
    d.energy = energy
    d.color = color
    o = bpy.data.objects.new(name, d)
    bpy.context.scene.collection.objects.link(o)
    o.rotation_euler = rot
    return o


sun("Matahari", (math.radians(50), 0, math.radians(135)), 3.0, (1.0, 0.93, 0.82))
sun("Isi", (math.radians(60), 0, math.radians(315)), 0.8, (0.85, 0.9, 1.0))


def camera(name, loc, target, lens=50):
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.name = name
    cam.data.lens = lens
    direction = (target[0] - loc[0], target[1] - loc[1], target[2] - loc[2])
    cam.rotation_euler = Vector(direction).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    return cam


for name, loc, target, lens in VIEWS:
    camera("Cam_" + name, loc, target, lens)
    scene.render.filepath = os.path.join(OUT_DIR, "santri-putra-v2-berwarna_%s.png" % name)
    bpy.ops.render.render(write_still=True)
    print("RENDER:", name, "->", scene.render.filepath)
print("SELESAI RENDER BERWARNA PUTRA")
