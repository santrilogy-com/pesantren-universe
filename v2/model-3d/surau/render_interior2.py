#!/usr/bin/env python3
"""Render interior Surau v2 sudut ke-2: dari tengah ruangan melihat ke utara,
supaya rak buku utara tampak dari depan + dampar timur/barat terlihat.
Jalankan: blender --background surau-v2.blend --python render_interior2.py"""
import bpy
import math
import os

BLEND_DIR = os.path.dirname(os.path.abspath(bpy.data.filepath))
OUT_DIR = os.path.join(BLEND_DIR, "render")

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.cycles.max_bounces = 4
scene.cycles.diffuse_bounces = 3
scene.cycles.glossy_bounces = 2
scene.cycles.transmission_bounces = 2
scene.render.resolution_x = 768
scene.render.resolution_y = 768

if bpy.data.worlds:
    world = bpy.data.worlds["World"]
else:
    world = bpy.data.worlds.new("World")
    scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes["Background"]
bg.inputs[0].default_value = (0.96, 0.93, 0.87, 1.0)
bg.inputs[1].default_value = 1.0

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

sun("Matahari", (math.radians(50), 0, math.radians(135)), 4.0, (1.0, 0.93, 0.82))
sun("Isi", (math.radians(60), 0, math.radians(315)), 1.0, (0.85, 0.9, 1.0))

d = bpy.data.lights.new("LampuInterior", "POINT")
d.energy = 300
d.color = (1.0, 0.9, 0.75)
o = bpy.data.objects.new("LampuInterior", d)
bpy.context.scene.collection.objects.link(o)
o.location = (0, 0, 3.5)

from mathutils import Vector
# Sudut diagonal dari barat-daya melihat ke timur-laut: rak utara tampak
# dari depan + dampar timur terlihat + kedalaman ruangan terbaca.
bpy.ops.object.camera_add(location=(-6.0, -5.0, 3.2))
cam = bpy.context.object
cam.name = "Cam_interior2"
cam.data.lens = 28
direction = (6.0 - (-6.0), 5.0 - (-5.0), 0.8 - 3.2)
cam.rotation_euler = Vector(direction).to_track_quat("-Z", "Y").to_euler()
scene.camera = cam
scene.render.filepath = os.path.join(OUT_DIR, "surau_interior2.png")
bpy.ops.render.render(write_still=True)
print("RENDER interior2 ->", scene.render.filepath)
print("SELESAI RENDER INTERIOR2")
