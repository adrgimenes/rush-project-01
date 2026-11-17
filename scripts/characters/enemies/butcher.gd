extends CharacterBody3D

@export var speed = 2.2
@export var stopping_distance = 1.1
var target: Node3D
var repath_time = 0.0
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $Model/AnimationPlayer
@onready var footsteps: AudioStreamPlayer3D = $Footsteps

func _ready() -> void:
	var walking_stream: AudioStreamMP3 = footsteps.stream.duplicate()
	walking_stream.loop = true
	footsteps.stream = walking_stream
	var animation_player = $Model/AnimationPlayer
	var walk: Animation = animation_player.get_animation("mixamo_com").duplicate()
	walk.loop_mode = Animation.LOOP_LINEAR
	var library = AnimationLibrary.new()
	library.add_animation("walk", walk)
	animation_player.add_animation_library("butcher", library)
	animation_player.play("butcher/walk")
	target = get_parent().get_node_or_null("Player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		footsteps.stop()
		return
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	var direction = Vector3.ZERO
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) > 0:
		repath_time -= delta
		if repath_time <= 0.0:
			agent.target_position = target.global_position
			repath_time = 0.35
		var offset = target.global_position - global_position
		offset.y = 0.0
		if offset.length() > stopping_distance and not agent.is_navigation_finished():
			direction = agent.get_next_path_position() - global_position
			direction.y = 0.0
			direction = direction.normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, 8.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 8.0 * delta)
	move_and_slide()
	var moving = Vector2(get_real_velocity().x, get_real_velocity().z).length() > 0.05
	animator.speed_scale = 1.0 if moving else 0.0
	var walking = moving and is_on_floor()
	if walking and not footsteps.playing:
		footsteps.play()
	elif not walking and footsteps.playing:
		footsteps.stop()
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), minf(delta * 7.0, 1.0))
