extends CharacterBody3D

var camera: Camera3D
var pivot: Node3D
var model: Node3D
var active: bool = true
var pitch: float = -0.12

func part(pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	mesh.material_override = mat
	model.add_child(mesh)
	mesh.position = pos

func _ready() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	model = Node3D.new()
	add_child(model)
	part(Vector3(0, 1.2, 0), Vector3(0.65, 0.75, 0.36), Color("344b4a"))
	part(Vector3(0, 1.78, 0), Vector3(0.38, 0.4, 0.36), Color("bd9981"))
	part(Vector3(0, 1.98, 0.02), Vector3(0.43, 0.14, 0.44), Color("263137"))
	part(Vector3(0, 1.2, 0.3), Vector3(0.5, 0.65, 0.25), Color("866c4b"))
	for x in [-0.19, 0.19]:
		part(Vector3(x, 0.45, 0), Vector3(0.25, 0.9, 0.28), Color("273745"))
		part(Vector3(x * 2, 1.25, -0.18), Vector3(0.18, 0.22, 0.7), Color("344b4a"))
	part(Vector3(0.4, 1.36, -0.65), Vector3(0.13, 0.18, 0.9), Color("171e23"))
	pivot = Node3D.new()
	add_child(pivot)
	pivot.position.y = 1.65
	var arm := SpringArm3D.new()
	pivot.add_child(arm)
	arm.spring_length = 4.0
	arm.margin = 0.2
	arm.add_excluded_object(get_rid())
	camera = Camera3D.new()
	arm.add_child(camera)
	camera.current = true
	camera.fov = 72
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and active:
		rotation.y -= event.relative.x * 0.0025
		pitch = clampf(pitch - event.relative.y * 0.0025, -0.9, 0.65)

func _physics_process(delta: float) -> void:
	pivot.rotation.x = pitch
	if not is_on_floor():
		velocity.y -= 22 * delta
	var direction := Vector3.ZERO
	if active and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		direction = Vector3(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), 0, float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
			velocity.y = 7
	var speed: float = 8.0 if Input.is_physical_key_pressed(KEY_SHIFT) else 4.5
	direction = basis * direction.normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * 25)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * 25)
	move_and_slide()
	model.position.y = sin(Time.get_ticks_msec() * 0.013) * 0.035 * Vector2(velocity.x, velocity.z).length() / 4.5
	camera.fov = lerpf(camera.fov, 52.0 if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) else 72.0, minf(1, delta * 10))
