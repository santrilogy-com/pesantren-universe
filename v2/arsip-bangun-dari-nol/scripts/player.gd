extends CharacterBody3D
class_name V2Player
## Santri PLACEHOLDER v2 ALPHA — primitif Godot sederhana (pola v1).
## Karakter 3D final belum ada; ini hanya supaya dunia bisa dijelajahi.
## Gerak: move_input (joystick / keyboard) relatif terhadap kamera.
## Kamera: manual follow (tanpa SpringArm) — offset putar oleh cam_yaw.

const SPEED := 6.0
const GRAVITY := 20.0

var move_input: Vector2 = Vector2.ZERO
var cam_yaw: float = 0.0

var _visual: Node3D
var _arm_l: Node3D
var _arm_r: Node3D
var _cam: Camera3D
var _walk_time: float = 0.0
var _facing: float = 0.0

# Batas dunia (tanah x -70..210, z -70..95) — jangan jatuh keluar tanah.
const MIN_X := -68.0
const MAX_X := 208.0
const MIN_Z := -68.0
const MAX_Z := 93.0


func _ready() -> void:
	# Collision capsule.
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.5
	col.shape = cap
	col.position = Vector3(0, 0.75, 0)
	add_child(col)
	_build_visual()
	# Kamera follow manual.
	_cam = Camera3D.new()
	_cam.fov = 60.0
	_cam.current = true
	add_child(_cam)


func _build_visual() -> void:
	_visual = Node3D.new()
	add_child(_visual)
	var mat_koko := StandardMaterial3D.new()
	mat_koko.albedo_color = Color(0.95, 0.95, 0.92)
	var mat_kulit := StandardMaterial3D.new()
	mat_kulit.albedo_color = Color(0.85, 0.62, 0.42)
	var mat_sarung := StandardMaterial3D.new()
	mat_sarung.albedo_color = Color(0.02, 0.37, 0.27) # zamrud PV
	var mat_putih := StandardMaterial3D.new()
	mat_putih.albedo_color = Color(1, 1, 1)
	# Torso koko.
	_visual.add_child(_prim(BoxMesh.new(), Vector3(0.55, 0.7, 0.32), Vector3(0, 1.0, 0), mat_koko))
	# Kepala.
	_visual.add_child(_prim(SphereMesh.new(), Vector3(0.56, 0.56, 0.56), Vector3(0, 1.62, 0), mat_kulit))
	# Peci putih.
	var peci := _prim(CylinderMesh.new(), Vector3(0.58, 0.14, 0.58), Vector3(0, 1.9, 0), mat_putih)
	_visual.add_child(peci)
	# Sarung (kerucut: atas kecil, bawah lebar) — radius lewat size.
	var sarung_mesh := CylinderMesh.new()
	_visual.add_child(_prim(sarung_mesh, Vector3(0.52, 0.75, 0.88), Vector3(0, 0.38, 0), mat_sarung))
	# Lengan (kapsul kecil, untuk ayunan jalan).
	_arm_l = _prim(CapsuleMesh.new(), Vector3(0.14, 0.55, 0.14), Vector3(-0.36, 1.05, 0), mat_koko)
	_arm_r = _prim(CapsuleMesh.new(), Vector3(0.14, 0.55, 0.14), Vector3(0.36, 1.05, 0), mat_koko)
	_visual.add_child(_arm_l)
	_visual.add_child(_arm_r)


func _prim(mesh: Mesh, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	if mesh is BoxMesh:
		(mesh as BoxMesh).size = size
	elif mesh is SphereMesh:
		(mesh as SphereMesh).radius = size.x * 0.5
		(mesh as SphereMesh).height = size.y
	elif mesh is CylinderMesh:
		(mesh as CylinderMesh).top_radius = size.x * 0.5
		(mesh as CylinderMesh).bottom_radius = size.z * 0.5
		(mesh as CylinderMesh).height = size.y
	elif mesh is CapsuleMesh:
		(mesh as CapsuleMesh).radius = size.x * 0.5
		(mesh as CapsuleMesh).height = size.y
	mi.position = pos
	mi.material_override = mat
	return mi


func add_yaw(delta: float) -> void:
	cam_yaw += delta


func _physics_process(delta: float) -> void:
	# Gravitasi.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	# Arah gerak relatif kamera.
	var basis := Basis(Vector3.UP, cam_yaw)
	var fwd: Vector3 = -basis.z
	var right: Vector3 = basis.x
	var dir: Vector3 = right * move_input.x + fwd * (-move_input.y)
	if dir.length() > 1.0:
		dir = dir.normalized()
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	move_and_slide()
	# Batas dunia.
	global_position.x = clampf(global_position.x, MIN_X, MAX_X)
	global_position.z = clampf(global_position.z, MIN_Z, MAX_Z)
	# Hadap arah jalan + ayunan lengan.
	var planar := Vector2(velocity.x, velocity.z)
	if planar.length() > 0.5:
		var target_yaw := atan2(velocity.x, velocity.z)
		_facing = lerp_angle(_facing, target_yaw, minf(1.0, delta * 10.0))
		_walk_time += delta * planar.length() * 1.6
		_arm_l.rotation.x = sin(_walk_time) * 0.5
		_arm_r.rotation.x = -sin(_walk_time) * 0.5
	else:
		_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, minf(1.0, delta * 8.0))
		_arm_r.rotation.x = lerpf(_arm_r.rotation.x, 0.0, minf(1.0, delta * 8.0))
	_visual.rotation.y = _facing
	# Kamera follow: di belakang + atas, menghadap pemain.
	var cam_offset := Vector3(0, 4.2, 7.5).rotated(Vector3.UP, cam_yaw)
	_cam.global_position = global_position + cam_offset
	_cam.look_at(global_position + Vector3(0, 1.4, 0), Vector3.UP)
