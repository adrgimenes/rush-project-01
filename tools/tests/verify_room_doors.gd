extends Node
func _ready() -> void:
	var level = load("res://scenes/levels/ThirtyLevel.tscn").instantiate()
	add_child(level)
	await get_tree().create_timer(3).timeout
	for actor in ["Player", "Butcher"]:
		level.get_node(actor).queue_free()
	await get_tree().physics_frame
	var dummy := Node3D.new()
	add_child(dummy)
	var doors := []
	for room in level.get_children():
		var door = room.get_node_or_null("RoomDoor")
		if door:
			assert(door.required_item == &"")
			door.interact(dummy)
			doors.append(door)
	assert(doors.size() == 36)
	await get_tree().create_timer(0.9).timeout
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.8
	var blocked := []
	for door in doors:
		assert(door.opened and not door.moving)
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.collision_mask = 1
		query.transform = Transform3D(Basis.IDENTITY, door.to_global(Vector3(0.5,1,0)))
		var hits = get_viewport().world_3d.direct_space_state.intersect_shape(query)
		if not hits.is_empty():
			var names := []
			for hit in hits: names.append(str(hit.collider.get_path()))
			blocked.append([str(door.get_parent().name),names])
	print("DOOR QA: opened=",doors.size()," obstructed=",blocked)
	assert(blocked.is_empty())
	assert(level.get_node("SalaProfessor01Secreta/Door").required_item == &"Chave do Professor")
	assert(level.get_node("Sala de Energia/Door").required_item == &"CartaoAcesso01")
	print("LOCKED DOORS PRESERVED")
	get_tree().quit()
