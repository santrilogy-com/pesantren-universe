#!/usr/bin/env python3
"""Render Surau v2: depan, samping, tiga-perempat, interior (Cycles CPU).
Jalankan headless: blender --background surau-v2.blend --python render_surau.py
Tidak menyimpan .blend (tanah + lampu + kamera hanya untuk render).
"""
import bpy
import math
import os

BLEND_DIR = os.path.dirname(os.path.abspath(bpy.data.filepath))
OUT_DIR = os.path.join(BLEND_DIR, "render")

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = False

# --- Dunia: langit krem hangat ---
if bpy.data.worlds:
    world = bpy.data.worlds["World"]
else:
    world = bpy.data.worlds.new("World")
    scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes["Background"]
bg.inputs[0].default_value = (0.96, 0.93, 0.87, 1.0)
bg.inputs[1].default_value = 1.0

# --- Tanah netral ---
bpy.ops.mesh.primitive_plane_add(size=120, location=(0, 0, -0.01))
g = bpy.context.object
g.name = "TanahRender"
m = bpy.data.materials.new("Tanah")
m.use_nodes = True
m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.85, 0.83, 0.75, 1.0)
m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 1.0
g.data.materials.append(m)

# --- Matahari hangat dari tenggara + isi dingin dari barat laut ---
def sun(name, rot, energy, color):
    d = bpy.data.lights.new(name, "SUN")
    d.energy = energy
    d.color = color
    o = bpy.data.objects.new(name, d)
    bpy.context.scene.collection.objects.link(o)
    o.rotation_euler = rot
    return o

sun("Matahari", (math.radians(50), 0, math.radians(135)), 4.0, (1.0, 0.93, 0.82))
sun("Isi", (math.radians(60), 0, math.radians(315)), 1.0, (0.85, 0.9, 1.0))

# --- Lampu interior hangat ---
d = bpy.data.lights.new("LampuInterior", "POINT")
d.energy = 300
d.color = (1.0, 0.9, 0.75)
o = bpy.data.objects.new("LampuInterior", d)
bpy.context.scene.collection.objects.link(o)
o.location = (0, 0, 3.5)

def camera(name, loc, target, lens=50):
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.name = name
    cam.data.lens = lens
    direction = (target[0] - loc[0], target[1] - loc[1], target[2] - loc[2])
    from mathutils import Vector
    cam.rotation_euler = Vector(direction).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    return cam

views = [
    ("depan", (38, 0, 6), (0, 0, 5), 50),
    ("samping", (0, -38, 6), (0, 0, 5), 50),
    ("tiga_perempat", (27, -27, 11), (0, 0, 5), 50),
    ("interior", (7.5, 0, 2.2), (-9, 0, 2.0), 28),
]
for name, loc, target, lens in views:
    camera("Cam_" + name, loc, target, lens)
    scene.render.filepath = os.path.join(OUT_DIR, f"surau_{name}.png")
    bpy.ops.render.render(write_still=True)
    print("RENDER:", name, "->", scene.render.filepath)
print("SELESAI RENDER")
