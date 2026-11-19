#!/usr/bin/env python3
"""Render satu elemen lingkungan v2 (Cycles CPU, 768px, 64 sampel).
Pemakaian:
  blender --background <blend> --python render_lingkungan.py -- <kunci>
Kunci: pohon-rindang | pohon-hias | pagar-bambu | pagar-bata |
       gubuk-santri | taman | sawah
Output: <folder blend>/render/<kunci>_<view>.png"""
import bpy
import math
import os
import sys
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
KEY = argv[0]

BLEND_DIR = os.path.dirname(os.path.abspath(bpy.data.filepath))
OUT_DIR = os.path.join(BLEND_DIR, "render")
os.makedirs(OUT_DIR, exist_ok=True)

# (nama_view, lokasi_kamera, target, lensa)
VIEWS = {
    "pohon-rindang": [
        ("depan", (0, -16, 4.5), (0, 0, 4.2), 50),
        ("tiga_perempat", (11, -11, 7), (0, 0, 4.0), 50),
    ],
    "pohon-hias": [
        ("depan", (0, -8, 2.0), (0, 0, 1.7), 50),
        ("tiga_perempat", (5, -5, 3.5), (0, 0, 1.7), 50),
    ],
    "pagar-bambu": [
        ("depan", (0, -9, 1.0), (0, 0, 0.7), 50),
        ("tiga_perempat", (6, -6, 2.5), (0, 0, 0.7), 50),
    ],
    "pagar-bata": [
        ("depan", (0, -9, 1.0), (0, 0, 0.6), 50),
        ("tiga_perempat", (6, -6, 2.5), (0, 0, 0.6), 50),
    ],
    "gubuk-santri": [
        # PINTU menghadap +Y — kamera depan & tiga-perempat HARUS dari +Y
        # (sebelumnya dari -Y sehingga yang terfoto dinding belakang).
        ("depan", (0, 11, 2.5), (0, 0, 2.2), 50),
        ("samping", (11, 0, 2.5), (0, 0, 2.2), 50),
        ("tiga_perempat", (8, 8, 4.5), (0, 0, 2.0), 50),
    ],
    "taman": [
        ("depan", (0, -11, 2.5), (0, 0, 0.5), 50),
        ("tiga_perempat", (7, -7, 6), (0, 0, 0.3), 45),
    ],
    "sawah": [
        ("tiga_perempat", (14, -14, 10), (0, 0, 0), 40),
        ("atas", (0, -16, 15), (0, 0.5, 0), 40),
    ],
}

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.cycles.max_bounces = 4
scene.cycles.diffuse_bounces = 3
scene.cycles.glossy_bounces = 2
scene.render.resolution_x = 768
scene.render.resolution_y = 768

LING_DIR = os.path.dirname(os.path.abspath(__file__))
HDRI = os.path.join(LING_DIR, "tekstur", "kloppenheim_06_puresky_2k.hdr")

world = bpy.data.worlds["World"] if bpy.data.worlds else bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
# HDRI Poly Haven CC0 (langit siang cerah + matahari) sebagai cahaya + latar
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


for name, loc, target, lens in VIEWS[KEY]:
    camera("Cam_" + name, loc, target, lens)
    scene.render.filepath = os.path.join(OUT_DIR, f"{KEY}_{name}.png")
    bpy.ops.render.render(write_still=True)
    print("RENDER:", KEY, name, "->", scene.render.filepath)
print("SELESAI RENDER", KEY)
