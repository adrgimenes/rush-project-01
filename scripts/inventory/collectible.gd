extends Area3D

@export var item_id: StringName = &"item"
@export var item_name: String = "Item"
@export var icon: Texture2D
@export_range(1, 999) var quantity: int = 1
var collected = false

func collect(inventory: Node) -> bool:
	if collected:
		return false
	collected = true
	if not inventory.add_item(item_id, item_name, icon, quantity):
		collected = false
		return false
	queue_free()
	return true
