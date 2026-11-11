extends Node

signal changed
var items: Dictionary = {}

func add_item(id: StringName, title: String, icon: Texture2D = null, amount: int = 1) -> bool:
	if id == &"" or amount <= 0:
		return false
	if not items.has(id):
		items[id] = {"title": title, "icon": icon, "amount": 0}
	items[id].amount += amount
	changed.emit()
	return true

func has_item(id: StringName, amount: int = 1) -> bool:
	return amount > 0 and items.has(id) and items[id].amount >= amount

# Call only when the associated interaction succeeds.
func consume_item(id: StringName, amount: int = 1) -> bool:
	if not has_item(id, amount):
		return false
	items[id].amount -= amount
	if items[id].amount == 0:
		items.erase(id)
	changed.emit()
	return true
