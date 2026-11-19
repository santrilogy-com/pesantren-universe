#!/usr/bin/env python3
"""Tukar gambar tekstur 2k -> 1k di blend yang sudah bertekstur (hemat ukuran
GLB; di render 768px tidak ada bedanya). Lalu simpan + ekspor ulang GLB.
Pemakaian: blender --background <blend> --python swap_tekstur_1k.py"""
import bpy
import os

for img in bpy.data.images:
    if "_2k.jpg" in img.filepath:
        baru = img.filepath.replace("_2k.jpg", "_1k.jpg")
        img.filepath = baru
        img.reload()
        print("TUKAR:", img.name, "->", baru)

blend_path = bpy.data.filepath
glb_path = blend_path[:-6] + ".glb"
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB",
                          export_apply=True, export_yup=True)
print("GLB diekspor:", glb_path, os.path.getsize(glb_path), "byte")
print("SELESAI TUKAR 1K")
