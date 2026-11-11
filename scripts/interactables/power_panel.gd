extends StaticBody3D

var lamp_material: StandardMaterial3D

func _ready() -> void:
	lamp_material = $Indicator.material_override.duplicate()
	$Indicator.material_override = lamp_material
	PowerState.power_changed.connect(update_power)
	update_power(PowerState.is_power_on)

func interaction_text() -> String:
	if not PowerState.has_fuse:
		return "[E] Instalar fusível"
	return "[E] Desligar energia" if PowerState.is_power_on else "[E] Ligar energia"

func interact(player: Node3D) -> void:
	if not PowerState.has_fuse and not PowerState.install_fuse(player.inventory):
		player.show_interaction_message("Falta um fusível.\nEncontre um para ligar a energia.")
		return
	PowerState.set_power(not PowerState.is_power_on)
	player.show_interaction_message("Energia ligada." if PowerState.is_power_on else "Energia desligada.")

func update_power(enabled: bool) -> void:
	lamp_material.albedo_color = Color(0.15, 0.85, 0.28) if enabled else Color(0.25, 0.035, 0.02)
	lamp_material.emission_enabled = enabled
	lamp_material.emission = Color(0.1, 0.8, 0.2)
	$Status.text = "LIGADO" if enabled else "DESLIGADO"
	$Status.modulate = Color(0.4, 1, 0.5) if enabled else Color(0.6, 0.6, 0.55)
	$Lever.rotation.x = -0.65 if enabled else 0.65
	$PanelLight.visible = enabled
