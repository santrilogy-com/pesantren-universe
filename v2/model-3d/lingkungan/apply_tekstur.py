#!/usr/bin/env python3
"""Pasang tekstur + HDRI Poly Haven (CC0) ke model lingkungan v2 TANPA bangun
ulang geometri: tambah UV cube-project per mesh, lalu ubah material flat
menjadi MixRGB Multiply (warna palet x tekstur) + Bump halus.
Palet tetap terjaga karena warna dasar palet dikalikan tekstur (fac 0.35-0.5).
Pemakaian:
  blender --background <blend> --python apply_tekstur.py -- <kunci>
Kunci: pohon-rindang | pohon-hias | pagar-bambu | pagar-bata |
       gubuk-santri | taman | sawah
Menimpa .blend + .glb yang sama (ekspor ulang)."""
import bpy
import os
import sys

argv = sys.argv[sys.argv.index("--") + 1:]
KEY = argv[0]

LING = os.path.dirname(os.path.abspath(__file__))
TEK = os.path.join(LING, "tekstur")

# material -> (file tekstur, fac multiply, ubin per meter)
KONFIG = {
    "pohon-rindang": {"L_jati": ("bark_brown_01_2k.jpg", 0.5, 1.0)},
    "pohon-hias": {"L_jati": ("bark_brown_01_2k.jpg", 0.5, 1.0)},
    "pagar-bambu": {"L_jati": ("brown_planks_04_2k.jpg", 0.35, 2.0)},
    "pagar-bata": {"L_krem": ("brick_wall_001_2k.jpg", 0.45, 0.5)},
    "gubuk-santri": {
        "L_jati": ("brown_planks_04_2k.jpg", 0.5, 0.5),
        "L_jati_tua": ("brown_planks_04_2k.jpg", 0.5, 0.5),
    },
    "taman": {
        "L_rumput": ("leafy_grass_2k.jpg", 0.5, 0.33),
        "L_tanah": ("farm_soil_2k.jpg", 0.5, 0.33),
        "L_batu": ("cobblestone_01_2k.jpg", 0.45, 0.5),
        "L_jati": ("brown_planks_04_2k.jpg", 0.4, 0.5),
    },
    "sawah": {
        "L_lumpur": ("brown_mud_03_2k.jpg", 0.5, 0.25),
        "L_tanah": ("farm_soil_2k.jpg", 0.5, 0.25),
    },
}


def pastikan_uv():
    """UV cube-project (1 ubin per meter) untuk semua mesh — wajib untuk GLB."""
    for o in bpy.context.scene.objects:
        if o.type != "MESH":
            continue
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.cube_project(cube_size=1.0, correct_aspect=True,
                                clip_to_bounds=False, scale_to_bounds=False)
        bpy.ops.object.mode_set(mode="OBJECT")
        print("UV:", o.name)


def pasang_tekstur(mat_name, tex_file, fac, ubin_per_meter):
    m = bpy.data.materials.get(mat_name)
    if m is None:
        print("LEWAT (material tidak ada):", mat_name)
        return
    nt = m.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    flat = tuple(bsdf.inputs["Base Color"].default_value)
    img = bpy.data.images.load(os.path.join(TEK, tex_file))
    texcoord = nt.nodes.new("ShaderNodeTexCoord")
    mapping = nt.nodes.new("ShaderNodeMapping")
    mapping.inputs["Scale"].default_value = (ubin_per_meter, ubin_per_meter,
                                             ubin_per_meter)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.extension = "REPEAT"
    mix = nt.nodes.new("ShaderNodeMixRGB")
    mix.blend_type = "MULTIPLY"
    mix.inputs[0].default_value = fac
    mix.inputs[1].default_value = flat
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.15
    bump.inputs["Distance"].default_value = 0.05
    nt.links.new(texcoord.outputs["UV"], mapping.inputs["Vector"])
    nt.links.new(mapping.outputs["Vector"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], mix.inputs[2])
    nt.links.new(mix.outputs["Color"], bsdf.inputs["Base Color"])
    nt.links.new(tex.outputs["Color"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    print(f"TEKSTUR: {mat_name} <- {tex_file} (fac {fac}, {ubin_per_meter}/m)")


pastikan_uv()
for mat_name, (tex_file, fac, ubin) in KONFIG[KEY].items():
    pasang_tekstur(mat_name, tex_file, fac, ubin)

blend_path = bpy.data.filepath
glb_path = blend_path[:-6] + ".glb"
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
print("BLEND disimpan:", blend_path)
bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB",
                          export_apply=True, export_yup=True)
print("GLB diekspor:", glb_path, os.path.getsize(glb_path), "byte")
print("SELESAI TEKSTUR", KEY)
