extends Node3D
## Original procedural environment. No external asset dependencies.
var rng := RandomNumberGenerator.new()

static func surface(dark: Color, light: Color, frequency: float) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = preload("res://shaders/weathered.gdshader")
	m.set_shader_parameter("dark_color", dark)
	m.set_shader_parameter("light_color", light)
	m.set_shader_parameter("frequency", frequency)
	return m

func build(world: Node3D) -> void:
	rng.seed = 51290
	var bark := surface(Color("292921"), Color("76624b"), 5.0)
	var stone := surface(Color("38413c"), Color("727969"), 2.0)
	var foliage: StandardMaterial3D = world.material(Color("354f2a"))
	var leaf_mesh := SphereMesh.new()
	leaf_mesh.radius = 1
	leaf_mesh.height = 2
	leaf_mesh.radial_segments = 12
	leaf_mesh.rings = 6
	# Irregular branching silhouettes with shared leaf-cluster geometry.
	var leaf_transforms: Array[Transform3D] = []
	for i in range(100):
		var p := Vector3(rng.randf_range(-84, 84), 0, rng.randf_range(-84, 84))
		if absf(p.x) < 11 and p.z > -36 and p.z < 25:
			continue
		var height := rng.randf_range(8, 15)
		var trunk := CylinderMesh.new()
		trunk.bottom_radius = 0.38
		trunk.top_radius = 0.12
		trunk.height = height
		trunk.radial_segments = 10
		var mesh: MeshInstance3D = world.shape(self, trunk, p + Vector3.UP * height * 0.5, bark)
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.38
		capsule.height = height
		collision.shape = capsule
		mesh.add_child(body)
		body.add_child(collision)
		for j in range(7):
			var angle := j * 2.4 + rng.randf()
			var reach := rng.randf_range(1.7, 3.8)
			var center := p + Vector3(cos(angle) * reach, height * 0.64 + j * 0.55, sin(angle) * reach)
			var origin := p + Vector3.UP * (height * 0.45 + j * 0.45)
			branch(world, origin, center, bark)
			var scale_vec := Vector3(rng.randf_range(1.7, 2.8), rng.randf_range(1.1, 1.9), rng.randf_range(1.6, 2.6))
			leaf_transforms.append(Transform3D(Basis.from_euler(Vector3(0.2, angle, 0.3)).scaled(scale_vec), center))
	batch(leaf_mesh, foliage, leaf_transforms)
	# Crossed tapered blades, clustered around the playable clearing.
	var blades := SurfaceTool.new()
	blades.begin(Mesh.PRIMITIVE_TRIANGLES)
	for angle in [0.0, 1.05, 2.1]:
		var basis := Basis(Vector3.UP, angle)
		for point in [Vector3(-0.09, 0, 0), Vector3(0.09, 0, 0), Vector3(0.13, 0.72, 0)]:
			blades.add_vertex(basis * point)
	blades.generate_normals()
	var blade_mesh := blades.commit()
	var grass_mat := ShaderMaterial.new()
	grass_mat.shader = preload("res://shaders/grass.gdshader")
	var grass_transforms: Array[Transform3D] = []
	for i in range(18000):
		var p := Vector3(rng.randf_range(-48, 48), 0.02, rng.randf_range(-58, 32))
		if absf(p.x) < 3.8 or (absf(p.x) < 8.5 and p.z > -30 and p.z < -12):
			continue
		var size := rng.randf_range(0.5, 1.4)
		grass_transforms.append(Transform3D(Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3.ONE * size), p))
	batch(blade_mesh, grass_mat, grass_transforms)
	for i in range(55):
		var p := Vector3(rng.randf_range(-78, 78), 0.3, rng.randf_range(-78, 60))
		if absf(p.x) < 11:
			continue
		var rock: MeshInstance3D = world.shape(self, leaf_mesh, p, stone)
		rock.scale = Vector3(rng.randf_range(0.6, 2.7), rng.randf_range(0.5, 1.6), rng.randf_range(0.8, 2))
		rock.rotation.y = rng.randf_range(0, TAU)
	# Distant hills hide the square perimeter, without blocking the clearing.
	for i in range(22):
		var angle := i * TAU / 22
		var p := Vector3(cos(angle) * 125, -3, sin(angle) * 125)
		var hill: MeshInstance3D = world.shape(self, leaf_mesh, p, stone)
		hill.scale = Vector3(33, rng.randf_range(14, 32), 29)
	detail_house(world)

func branch(world: Node3D, start: Vector3, end: Vector3, mat: Material) -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.14
	cylinder.height = start.distance_to(end)
	cylinder.radial_segments = 7
	var n: MeshInstance3D = world.shape(self, cylinder, (start + end) * 0.5, mat)
	var direction := (end - start).normalized()
	var right := direction.cross(Vector3.FORWARD).normalized()
	n.basis = Basis(right, direction, right.cross(direction).normalized())

func batch(mesh: Mesh, mat: Material, transforms: Array[Transform3D]) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = mm
	instance.material_override = mat
	add_child(instance)

func detail_house(world: Node3D) -> void:
	var timber := surface(Color("2c3029"), Color("93816a"), 4.0)
	var rust := surface(Color("34393a"), Color("865b40"), 3.0)
	var dark: Material = world.material(Color("101d21"))
	# Upstairs frontage, recessed-looking window panels and shutters.
	world.box(self, Vector3(0, 7.3, -22), Vector3(15, 2.6, 12), timber, true)
	world.box(self, Vector3(0, 8.7, -22), Vector3(16, 0.22, 13), rust, true)
	for x in [-5.0, 0.0, 5.0]:
		world.box(self, Vector3(x, 7.2, -15.94), Vector3(1.3, 1.7, 0.06), dark)
		for side in [-0.8, 0.8]:
			world.box(self, Vector3(x + side, 7.2, -15.8), Vector3(0.2, 1.9, 0.18), timber)
		world.box(self, Vector3(x, 6.32, -15.7), Vector3(1.9, 0.15, 0.45), timber)
	for i in range(31):
		world.box(self, Vector3(-7.5 + i * 0.5, 8.87, -22), Vector3(0.04, 0.05, 13), rust)
	# Front steps prevent the floor lip blocking a walking player.
	world.box(self, Vector3(0, 0.08, -15.35), Vector3(4, 0.16, 0.9), timber, true)
	world.box(self, Vector3(0, 0.15, -15.8), Vector3(4, 0.3, 0.5), timber, true)
	for x in [-5.0, 5.0]:
		world.box(self, Vector3(x, 2.4, -15.75), Vector3(1.6, 1.8, 0.08), dark)
		var plank: MeshInstance3D = world.box(self, Vector3(x, 2.4, -15.65), Vector3(2.1, 0.2, 0.1), timber)
		plank.rotation.z = 0.25
		var lamp := OmniLight3D.new()
		add_child(lamp)
		lamp.position = Vector3(x, 3.5, -14)
		lamp.light_color = Color("ffb96c")
		lamp.light_energy = 2
		lamp.omni_range = 6
		world.box(self, lamp.position, Vector3(0.18, 0.25, 0.18), world.material(Color("ffb96c"), true))
	for i in range(16):
		world.box(self, Vector3(-13, 0.65, -8 - i * 1.4), Vector3(0.16, 1.3, 0.16), timber, true)
	for y in [0.5, 1.0]:
		world.box(self, Vector3(-13, y, -18.5), Vector3(0.12, 0.12, 22), timber, true)
