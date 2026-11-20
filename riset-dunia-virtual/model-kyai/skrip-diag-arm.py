import bpy, math
from mathutils import Vector

OUT = '/home/hatch/workspace/pesantren-verse/riset-dunia-virtual/model-kyai/'
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.gltf(filepath=OUT + 'herder-asli.glb')

arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
print('ARMATURE matrix_world:')
for r in arm.matrix_world:
    print('  ', tuple(round(v, 3) for v in r))
print('ARMATURE location:', tuple(round(v, 3) for v in arm.location),
      'scale:', tuple(round(v, 3) for v in arm.scale))

bpy.context.view_layer.objects.active = arm
arm.select_set(True)
bpy.ops.object.mode_set(mode='POSE')
pb = arm.pose.bones['mixamorig:LeftArm']
print('LeftArm bone matrix_local (kolom = sumbu lokal X,Y,Z dlm ruang armature):')
for r in pb.bone.matrix_local:
    print('  ', tuple(round(v, 3) for v in r))
print('LeftArm head (armature space):', tuple(round(v, 3) for v in pb.bone.head))
print('LeftArm tail (armature space):', tuple(round(v, 3) for v in pb.bone.tail))
print('LeftArm head (pose, awal):', tuple(round(v, 3) for v in pb.head))
print('LeftArm matrix (pose, awal):')
for r in pb.matrix:
    print('  ', tuple(round(v, 3) for v in r))
# sumbu lokal dalam ruang armature
R = pb.bone.matrix_local.to_3x3()
print('sumbu lokal X ->', tuple(round(v, 3) for v in (R @ Vector((1, 0, 0)))))
print('sumbu lokal Y ->', tuple(round(v, 3) for v in (R @ Vector((0, 1, 0)))))
print('sumbu lokal Z ->', tuple(round(v, 3) for v in (R @ Vector((0, 0, 1)))))
print('SELESAI-DIAG')
