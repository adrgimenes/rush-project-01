extends Node3D

signal elevator_called
var button_material: StandardMaterial3D

func _ready() -> void:
	button_material = $CallButton.material_override.duplicate()
	$CallButton.material_override = button_material
	PowerState.power_changed.connect(update_power)
	update_power(PowerState.is_power_on)

func update_power(enabled: bool) -> void:
	$FloorNumber.visible = enabled
	button_material.emission_enabled = enabled
	button_material.albedo_color = Color(0.65, 0.13, 0.06) if enabled else Color(0.08, 0.07, 0.06)

func interaction_text() -> String:
	return "[E] Chamar elevador" if PowerState.is_power_on else "Elevador sem energia"

func interact(player: Node3D) -> void:
	if not PowerState.is_power_on:
		player.show_interaction_message("Elevador desligado.\nRestabeleça a energia.")
		return
	elevator_called.emit()
	player.show_interaction_message("Chamada do elevador registrada.")
