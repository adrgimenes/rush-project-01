extends NavigationRegion3D

func _ready() -> void:
	# Bake after the modeling plugin has built the level meshes.
	call_deferred("build_navigation")

func build_navigation() -> void:
	var mesh = NavigationMesh.new()
	mesh.cell_size = 0.15
	mesh.cell_height = 0.1
	mesh.agent_height = 1.9
	mesh.agent_radius = 0.3
	mesh.agent_max_climb = 0.2
	mesh.agent_max_slope = 40.0
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, mesh.cell_size)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, mesh.cell_height)
	var geometry = NavigationMeshSourceGeometryData3D.new()
	# Rooms are independent meshes directly below the level root.
	# Moving doors stay physical obstacles rather than permanent baked walls.
	for child in get_parent().get_children():
		if child is MeshInstance3D and child.mesh != null:
			var shapes = child.find_children("*", "CollisionShape3D", true, false)
			for collider in shapes:
				if collider.shape is ConcavePolygonShape3D:
					geometry.add_faces(collider.shape.get_faces(), global_transform.affine_inverse() * collider.global_transform)
				elif collider.shape is BoxShape3D and collider.get_parent() is StaticBody3D:
					# Furnishings must also block the enemy's baked route.
					var decor_obstacle := BoxMesh.new()
					decor_obstacle.size = collider.shape.size
					geometry.add_faces(decor_obstacle.get_faces(), global_transform.affine_inverse() * collider.global_transform)
	NavigationServer3D.bake_from_source_geometry_data(mesh, geometry)
	navigation_mesh = mesh
