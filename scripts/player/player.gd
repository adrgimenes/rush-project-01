extends CharacterBody3D

const WALK_SPEED = 3.0
const RUN_SPEED = 5.5
const SENSITIVITY = 0.0025
var pitch = 0.0
var stride = 0.0
var flashlight_on = true
var camera: Camera3D
var hands: Node3D
var beam: SpotLight3D
var spill: SpotLight3D
var lens_material: StandardMaterial3D
var inventory: Node
var pickup_prompt: Label
var paper_view: CanvasLayer

func show_paper(text: String) -> void:
	if is_instance_valid(paper_view):
		return
	paper_view = preload("res://scripts/ui/paper_view.gd").new()
	paper_view.set_meta("text", text)
	add_child(paper_view)
	velocity = Vector3.ZERO
	pickup_prompt.text = ""
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_paper() -> void:
	if is_instance_valid(paper_view):
		paper_view.queue_free()
	paper_view = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
var interaction_message = ""
var interaction_message_time = 0.0

func show_interaction_message(message: String) -> void:
	interaction_message = message
	interaction_message_time = 2.5

func get_collectible() -> Node:
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_basis.z * 2.5)
	query.collide_with_areas = true
	query.exclude = [get_rid()]
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target: Node = hit.collider
		while target != null:
			if (target.has_method("collect") or target.has_method("interact")) and not target.is_queued_for_deletion():
				return target
			target = target.get_parent()
	return null

func _ready() -> void:
	camera = Camera3D.new()
	camera.position.y = 1.65
	camera.near = 0.04
	camera.current = true
	add_child(camera)
	hands = Node3D.new()
	camera.add_child(hands)
	build_hand_and_flashlight()
	beam = make_light(22.0, 28.0, 7.0)
	beam.shadow_enabled = true
	beam.spot_attenuation = 1.8
	spill = make_light(46.0, 13.0, 0.8)
	spill.shadow_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var hud = CanvasLayer.new()
	add_child(hud)
	var label = Label.new()
	label.text = "WASD · Mover     Shift · Correr     Botão direito · Lanterna     Esc · Soltar mouse"
	label.position = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 16)
	hud.add_child(label)
	inventory = preload("res://scripts/inventory/inventory.gd").new()
	inventory.name = "Inventory"
	add_child(inventory)
	var inventory_ui = preload("res://scripts/ui/inventory_hud.gd").new()
	inventory_ui.inventory = inventory
	hud.add_child(inventory_ui)
	pickup_prompt = Label.new()
	hud.add_child(pickup_prompt)
	pickup_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pickup_prompt.position += Vector2(-260, 35)
	pickup_prompt.custom_minimum_size = Vector2(520, 32)
	pickup_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pickup_prompt.add_theme_font_override("font", preload("res://assets/fonts/PressStart2P-Regular.ttf"))
	pickup_prompt.add_theme_font_size_override("font_size", 12)
	pickup_prompt.add_theme_color_override("font_shadow_color", Color.BLACK)
	pickup_prompt.add_theme_constant_override("shadow_offset_x", 2)
	pickup_prompt.add_theme_constant_override("shadow_offset_y", 2)
	pickup_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE

func build_hand_and_flashlight() -> void:
	var skin = material(Color(0.57, 0.36, 0.27))
	var nails = material(Color(0.65, 0.46, 0.38))
	var metal = material(Color(0.035, 0.042, 0.048))
	metal.metallic = 0.65
	metal.roughness = 0.38
	var rubber = material(Color(0.018, 0.022, 0.025))
	var rim = material(Color(0.16, 0.18, 0.19))
	rim.metallic = 0.85
	rim.roughness = 0.26
	var sleeve = material(Color(0.085, 0.10, 0.115))
	# Forearm tapers into the wrist and an oval palm along the grip.
	segment(Vector3(0.43, -0.46, 0.02), Vector3(0.32, -0.34, -0.24), 0.082, sleeve, 0.066)
	segment(Vector3(0.32, -0.34, -0.24), Vector3(0.25, -0.28, -0.45), 0.06, skin, 0.038)
	ellipsoid(Vector3(0.235, -0.27, -0.49), Vector3(0.044, 0.046, 0.085), skin)
	# Four articulated fingers curl around the underside of the handle.
	for i in range(4):
		var z = -0.565 + i * 0.035
		var radius = 0.014 - i * 0.0007
		var base = Vector3(0.237, -0.282, z)
		var knuckle = Vector3(0.215, -0.316, z)
		var middle = Vector3(0.169, -0.316, z - 0.003)
		var tip = Vector3(0.144, -0.282, z - 0.006)
		segment(base, knuckle, radius, skin)
		segment(knuckle, middle, radius, skin, radius * 0.9)
		segment(middle, tip, radius * 0.9, skin, radius * 0.75)
		ellipsoid(knuckle, Vector3.ONE * radius, skin)
		ellipsoid(middle, Vector3.ONE * radius * 0.9, skin)
		ellipsoid(tip, Vector3.ONE * radius * 0.8, skin)
		ellipsoid(tip + Vector3(-0.008, 0.002, 0), Vector3(0.003, 0.009, 0.009), nails)
	# Thumb rests diagonally across the top, opposite the curled fingers.
	segment(Vector3(0.25, -0.25, -0.46), Vector3(0.219, -0.206, -0.52), 0.023, skin, 0.019)
	segment(Vector3(0.219, -0.206, -0.52), Vector3(0.173, -0.207, -0.56), 0.019, skin, 0.015)
	ellipsoid(Vector3(0.219, -0.206, -0.52), Vector3(0.02, 0.019, 0.022), skin)
	ellipsoid(Vector3(0.173, -0.207, -0.56), Vector3(0.016, 0.016, 0.022), skin)
	ellipsoid(Vector3(0.174, -0.192, -0.56), Vector3(0.011, 0.003, 0.016), nails)
	# Rubber grip, metal tail cap, tapered head and concentric bezel.
	segment(Vector3(0.18, -0.25, -0.36), Vector3(0.18, -0.25, -0.65), 0.049, rubber)
	segment(Vector3(0.18, -0.25, -0.345), Vector3(0.18, -0.25, -0.37), 0.053, metal)
	for i in range(12):
		var z = -0.38 - i * 0.021
		segment(Vector3(0.18, -0.25, z), Vector3(0.18, -0.25, z - 0.005), 0.051, metal)
	segment(Vector3(0.18, -0.25, -0.65), Vector3(0.18, -0.25, -0.74), 0.05, metal, 0.08)
	segment(Vector3(0.18, -0.25, -0.74), Vector3(0.18, -0.25, -0.80), 0.08, metal)
	for z in [-0.745, -0.765, -0.79]:
		segment(Vector3(0.18, -0.25, z), Vector3(0.18, -0.25, z - 0.006), 0.083, rubber)
	segment(Vector3(0.18, -0.25, -0.80), Vector3(0.18, -0.25, -0.807), 0.079, rim)
	lens_material = material(Color(0.68, 0.75, 0.77))
	lens_material.roughness = 0.12
	lens_material.emission_enabled = true
	lens_material.emission = Color(0.65, 0.70, 0.62)
	segment(Vector3(0.18, -0.25, -0.807), Vector3(0.18, -0.25, -0.809), 0.069, lens_material)
	ellipsoid(Vector3(0.18, -0.199, -0.62), Vector3(0.017, 0.008, 0.022), rubber)

func ellipsoid(center: Vector3, size: Vector3, mat: Material) -> void:
	var mesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	var part = MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = mat
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hands.add_child(part)
	part.position = center
	part.scale = size

func material(color: Color) -> StandardMaterial3D:
	var result = StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.85
	return result

func segment(start: Vector3, end: Vector3, radius: float, mat: Material, end_radius: float = -1.0) -> void:
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius if end_radius < 0.0 else end_radius
	mesh.bottom_radius = radius
	mesh.height = start.distance_to(end)
	mesh.radial_segments = 12
	var part = MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = mat
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hands.add_child(part)
	part.position = (start + end) * 0.5
	part.quaternion = Quaternion(Vector3.UP, (end - start).normalized())

func make_light(angle: float, distance: float, energy: float) -> SpotLight3D:
	var light = SpotLight3D.new()
	light.position = Vector3(0.18, -0.25, -0.82)
	light.spot_angle = angle
	light.spot_range = distance
	light.light_energy = energy
	light.light_color = Color(1.0, 0.94, 0.81)
	hands.add_child(light)
	return light

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(paper_view):
		if event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_E or event.keycode == KEY_ESCAPE):
			close_paper()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var collectible = get_collectible()
		if collectible != null:
			if collectible.has_method("interact"):
				collectible.interact(self)
			else:
				collectible.collect(inventory)
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			flashlight_on = not flashlight_on
			beam.visible = flashlight_on
			spill.visible = flashlight_on
			lens_material.emission_enabled = flashlight_on
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		pitch = clampf(pitch - event.relative.y * SENSITIVITY, -1.45, 1.45)
		camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if is_instance_valid(paper_view):
		return
	var collectible = get_collectible() if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else null
	pickup_prompt.text = ""
	if collectible != null:
		pickup_prompt.text = collectible.interaction_text() if collectible.has_method("interaction_text") else "[E] Coletar " + collectible.item_name
	if interaction_message_time > 0.0:
		interaction_message_time = maxf(0.0, interaction_message_time - delta)
		pickup_prompt.text = interaction_message
	var direction = Vector3.ZERO
	var running = false
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		direction = Vector3(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), 0, float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		running = Input.is_physical_key_pressed(KEY_SHIFT)
	direction = global_basis * direction.normalized()
	var speed = RUN_SPEED if running else WALK_SPEED
	velocity.x = move_toward(velocity.x, direction.x * speed, 18.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 18.0 * delta)
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()
	var moving = Vector2(velocity.x, velocity.z).length() > 0.1 and is_on_floor()
	stride += delta * (11.0 if running else 7.0)
	var offset = Vector3(sin(stride) * 0.012, abs(cos(stride)) * 0.014, 0) if moving else Vector3.ZERO
	hands.position = hands.position.lerp(offset, minf(delta * 12.0, 1.0))
