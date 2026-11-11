extends Control

var inventory: Node
var grid: GridContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin = MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid = GridContainer.new()
	grid.columns = 6
	grid.size_flags_horizontal = Control.SIZE_SHRINK_END
	grid.size_flags_vertical = Control.SIZE_SHRINK_END
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	margin.add_child(grid)
	inventory.changed.connect(refresh)
	refresh()

func refresh() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	var entries = inventory.items.values()
	var slots = maxi(6, ceili(entries.size() / 6.0) * 6)
	for i in range(slots):
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(64, 64)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.035, 0.04, 0.045, 0.82)
		style.border_color = Color(0.48, 0.47, 0.42, 0.65)
		style.set_border_width_all(1)
		style.set_content_margin_all(5)
		slot.add_theme_stylebox_override("panel", style)
		grid.add_child(slot)
		if i >= entries.size():
			continue
		var entry = entries[i]
		var content = VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(content)
		if entry.icon != null:
			var icon = TextureRect.new()
			icon.texture = entry.icon
			icon.custom_minimum_size = Vector2(40, 32)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(icon)
		var label = Label.new()
		label.text = entry.title
		if entry.amount > 1:
			label.text += " ×" + str(entry.amount)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 54
		label.add_theme_font_size_override("font_size", 12)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(label)
