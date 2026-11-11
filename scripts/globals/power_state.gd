extends Node

signal power_changed(enabled: bool)
signal fuse_installed
const FUSE_ITEM: StringName = &"Fusivel"
var has_fuse = false

func install_fuse(inventory: Node) -> bool:
	if has_fuse:
		return true
	if not inventory.consume_item(FUSE_ITEM):
		return false
	has_fuse = true
	fuse_installed.emit()
	return true

# Shared for the current game session, including scene changes.
var is_power_on: bool = false:
	set(value):
		if value and not has_fuse:
			return
		if is_power_on == value:
			return
		is_power_on = value
		power_changed.emit(value)

func set_power(enabled: bool) -> void:
	is_power_on = enabled
