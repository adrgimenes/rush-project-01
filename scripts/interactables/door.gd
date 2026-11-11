extends Node3D

@export var required_item: StringName = &""
@export var consume_required_item = true
@export_multiline var locked_message = "Porta trancada.\nPrecisa da Chave do Professor."
var opened = false
var moving = false
var unlocked = false

func interaction_text() -> String:
	return "[E] Fechar porta" if opened else "[E] Abrir porta"

func interact(player: Node3D) -> void:
	if moving:
		return
	if not opened and not unlocked and required_item != &"":
		if not player.inventory.has_item(required_item):
			player.show_interaction_message(locked_message)
			return
		if consume_required_item:
			if not player.inventory.consume_item(required_item):
				return
			unlocked = true
	if opened:
		for body in $Safety.get_overlapping_bodies():
			if body is CharacterBody3D:
				return
	opened = not opened
	moving = true
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property($Hinge, "rotation:y", -PI * 0.5 if opened else 0.0, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	moving = false
