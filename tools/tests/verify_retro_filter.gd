extends Node
func _ready() -> void:
	var level = load("res://scenes/levels/ThirtyLevel.tscn").instantiate()
	add_child(level)
	await get_tree().create_timer(3.0).timeout
	var rooms := 0
	var missing := []
	for room in level.get_children():
		if room is MeshInstance3D and (str(room.name).begins_with("Sala") or str(room.name).begins_with("Laboratorio") or str(room.name).begins_with("Banheiro") or str(room.name) in ["Secretaria", "AchadosEPerdidos"]):
			rooms += 1
			if not room.has_node("Decor"):
				missing.append(room.name)
	print("DECOR QA: rooms=", rooms, " missing=", missing)
	assert(missing.is_empty())
	var nav = level.get_node("Navigation")
	assert(nav.navigation_mesh != null and nav.navigation_mesh.get_polygon_count() > 0)
	print("NAV QA: polygons=", nav.navigation_mesh.get_polygon_count())
	for actor_name in ["Player", "Butcher"]:
		var actor = level.get_node_or_null(actor_name)
		if actor:
			actor.queue_free()
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var camera := Camera3D.new()
	add_child(camera)
	camera.current = true
	camera.fov = 85
	var light := OmniLight3D.new()
	add_child(light)
	light.omni_range = 18
	light.light_energy = 2.5
	light.shadow_enabled = true
	var shots = [
		["LaboratorioComputa\u00e7\u00e3o02", Vector3(2.8,2.8,30), Vector3(7,0.8,26.8), "lab"],
		["SalaMuseu", Vector3(33.6,2.5,78.3), Vector3(36.2,1,75), "museum"],
		["BanheiroMasculinoNorte", Vector3(6.2,2.4,63.5), Vector3(10,0.8,60.5), "bathroom"]
	]
	for shot in shots:
		var room = level.get_node(shot[0])
		camera.global_position = room.to_global(shot[1])
		camera.look_at(room.to_global(shot[2]))
		light.global_position = room.to_global((shot[1]+shot[2])*0.5+Vector3(0,0.5,0))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tools/tests/retro_"+shot[3]+".png")
	print("DECOR QA PASSED")
	get_tree().quit()
