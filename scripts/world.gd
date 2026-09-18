extends Node3D

const Player = preload("res://scripts/player.gd")
const Dressing = preload("res://scripts/dressing.gd")
var player: Player
var enemies: Array[Node3D] = []
var supplies: Array[Node3D] = []
var hud: Label
var objective: Label
var health: float = 100.0
var ammo: int = 24
var collected: int = 0
var kills: int = 0
var cooldown: float = 0.0
var reload_time: float = 0.0
var ended: bool = false
var rng := RandomNumberGenerator.new()

func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	if glow:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 3.0
	return m

func shape(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.material_override = mat
	parent.add_child(n)
	n.position = pos
	return n

func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, solid: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var n := shape(parent, mesh, pos, mat)
	if solid:
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var s := BoxShape3D.new()
		s.size = size
		collider.shape = s
		n.add_child(body)
		body.add_child(collider)
	return n

func _ready() -> void:
	rng.seed = 7241
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("243b57")
	sky_mat.sky_horizon_color = Color("eab087")
	sky_mat.ground_horizon_color = Color("bb9478")
	sky_mat.ground_bottom_color = Color("26312d")
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8bacc0")
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("859995")
	env.fog_density = 0.0025
	env.glow_enabled = true
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-22, -38, 0)
	sun.light_color = Color("ffca95")
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90.0
	var ground := Dressing.surface(Color("354431"), Color("736b4e"), 0.7)
	var wood := material(Color("443d34"))
	var wall := Dressing.surface(Color("454c49"), Color("9a9b83"), 3.0)
	var metal := material(Color("28383e"))
	box(self, Vector3(0, -0.5, 0), Vector3(180, 1, 180), ground, true)
	box(self, Vector3(0, 0.015, -14), Vector3(7, 0.02, 110), material(Color("545149")))
	for x in [-90, 90]:
		box(self, Vector3(x, 4, 0), Vector3(1, 8, 180), wood, true).visible = false
	for z in [-90, 90]:
		box(self, Vector3(0, 4, z), Vector3(180, 8, 1), wood, true).visible = false
	# Open-front derelict shelter: accessible interior and porch.
	box(self, Vector3(0, 0.18, -22), Vector3(15, 0.35, 12), wood, true)
	box(self, Vector3(0, 3, -28), Vector3(15, 6, 0.3), wall, true)
	for x in [-7.4, 7.4]:
		box(self, Vector3(x, 3, -22), Vector3(0.3, 6, 12), wall, true)
	for x in [-5, 5]:
		box(self, Vector3(x, 3, -16), Vector3(4.5, 6, 0.3), wall, true)
	box(self, Vector3(0, 6, -22), Vector3(16, 0.35, 14), metal, true)
	for x in [-6, -2, 2, 6]:
		box(self, Vector3(x, 2.2, -13), Vector3(0.22, 4.4, 0.22), wood, true)
	box(self, Vector3(0, 4.4, -14), Vector3(16, 0.2, 4), metal, true)
	for i in range(28):
		box(self, Vector3(-7.2 + i * 0.53, 3, -15.8), Vector3(0.035, 5.8, 0.035), wood)
	var sign := Label3D.new()
	add_child(sign)
	sign.position = Vector3(0, 4.9, -15.7)
	sign.text = "ASHWOOD  /  RESEARCH OUTPOST"
	sign.font_size = 48
	sign.pixel_size = 0.006
	var dressing := Dressing.new()
	add_child(dressing)
	dressing.build(self)
	for p in [Vector3(-4, 0.6, -22), Vector3(13, 0.6, -8), Vector3(-15, 0.6, -35)]:
		var crate := box(self, p, Vector3(1.2, 1.2, 1.2), metal)
		box(crate, Vector3(0, 0.62, 0), Vector3(1, 0.06, 1), material(Color("68e3bf"), true))
		supplies.append(crate)
	player = Player.new()
	add_child(player)
	player.position = Vector3(0, 1, 12)
	for p in [Vector3(12, 0, -18), Vector3(-12, 0, -30), Vector3(4, 0, -40)]:
		var enemy := Node3D.new()
		add_child(enemy)
		enemy.position = p
		enemy.set_meta("hp", 3)
		box(enemy, Vector3(0, 1.2, 0), Vector3(0.8, 1.9, 0.6), metal)
		box(enemy, Vector3(0, 2.35, 0), Vector3(0.6, 0.6, 0.6), material(Color("d67859"), true))
		var hit_body := StaticBody3D.new()
		enemy.add_child(hit_body)
		var hit := CollisionShape3D.new()
		var hit_shape := BoxShape3D.new()
		hit_shape.size = Vector3(1, 3, 1)
		hit.shape = hit_shape
		hit.position.y = 1.5
		hit_body.add_child(hit)
		hit_body.set_meta("enemy", enemy)
		enemies.append(enemy)
	var ui := CanvasLayer.new()
	add_child(ui)
	var screen := Control.new()
	ui.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective = Label.new()
	screen.add_child(objective)
	objective.position = Vector2(32, 28)
	objective.add_theme_font_size_override("font_size", 22)
	objective.add_theme_color_override("font_color", Color("f4d6a0"))
	hud = Label.new()
	screen.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hud.offset_left = 32
	hud.offset_top = -116
	hud.offset_right = 1000
	hud.offset_bottom = -16
	hud.add_theme_font_size_override("font_size", 19)
	for label in [hud, objective]:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
	var reticle := Label.new()
	screen.add_child(reticle)
	reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	reticle.offset_left = -7
	reticle.offset_top = -15
	reticle.offset_right = 15
	reticle.offset_bottom = 20
	reticle.text = "+"
	reticle.add_theme_font_size_override("font_size", 25)

func _physics_process(delta: float) -> void:
	cooldown = maxf(0, cooldown - delta)
	if reload_time > 0:
		reload_time -= delta
		if reload_time <= 0:
			ammo = 24
	if not ended:
		for enemy in enemies:
			var diff: Vector3 = player.position - enemy.position
			diff.y = 0
			if diff.length() < 24 and diff.length() > 1.8:
				var start := enemy.position + Vector3.UP
				var query := PhysicsRayQueryParameters3D.create(start, player.position + Vector3.UP)
				query.exclude = [enemy.get_child(2).get_rid()]
				var sight := get_world_3d().direct_space_state.intersect_ray(query)
				if sight.is_empty() or sight.collider == player:
					enemy.position += diff.normalized() * delta * 1.7
			if diff.length() < 2.0:
				health = maxf(0, health - delta * 12)
		if health <= 0:
			ended = true
			player.active = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	objective.text = "FADING DAWN  /  ASHWOOD\n\nPulihkan persediaan: %d / 3\nKalahkan penjaga: %d / 3" % [collected, kills]
	if collected == 3 and kills == 3:
		objective.text += "\n\nAREA AMAN — MISI SELESAI"
	if ended:
		objective.text += "\n\nKAMU GUGUR — tekan Enter untuk ulang"
	hud.text = "HP %03d     /     AMMO %02d     %s\nWASD Jalan  ·  Shift Lari  ·  Space Lompat\nMouse Bidik  ·  Klik Tembak  ·  R Reload  ·  E Ambil  ·  Esc Kursor" % [int(health), ammo, "RELOADING..." if reload_time > 0 else ""]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER and ended:
			get_tree().reload_current_scene()
		if event.keycode == KEY_R and not ended and ammo < 24 and reload_time <= 0:
			reload_time = 1.4
		if event.keycode == KEY_E and not ended:
			for crate in supplies.duplicate():
				if player.position.distance_to(crate.position) < 3:
					supplies.erase(crate)
					crate.queue_free()
					collected += 1
					health = minf(100, health + 20)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not ended and ammo > 0 and cooldown <= 0 and reload_time <= 0:
			shoot()

func shoot() -> void:
	ammo -= 1
	cooldown = 0.16
	var camera: Camera3D = player.camera
	var start := camera.global_position
	var end := start - camera.global_basis.z * 100
	var query := PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		end = hit.position
		if hit.collider.has_meta("enemy"):
			var enemy: Node3D = hit.collider.get_meta("enemy")
			var hp: int = enemy.get_meta("hp") - 1
			enemy.set_meta("hp", hp)
			if hp <= 0:
				enemies.erase(enemy)
				enemy.queue_free()
				kills += 1
	var muzzle: Vector3 = player.global_position + Vector3(0, 1.4, 0) - camera.global_basis.z * 0.8
	var beam := box(self, (muzzle + end) * 0.5, Vector3(0.025, 0.025, muzzle.distance_to(end)), material(Color("ffd49a"), true))
	beam.look_at(end)
	get_tree().create_timer(0.045).timeout.connect(beam.queue_free)
