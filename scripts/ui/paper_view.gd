extends CanvasLayer

func _ready() -> void:
	layer = 20
	var shade = ColorRect.new()
	shade.color = Color(0, 0, 0, 0.75)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(column)
	var paper = PanelContainer.new()
	paper.custom_minimum_size = Vector2(440, 520)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.86, 0.83, 0.73)
	style.set_content_margin_all(36)
	paper.add_theme_stylebox_override("panel", style)
	column.add_child(paper)
	var text = Label.new()
	text.name = "PaperText"
	text.text = get_meta("text", "Hello World")
	text.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	text.add_theme_font_size_override("font_size", 24)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper.add_child(text)
	var hint = Label.new()
	hint.text = "E / Esc · Fechar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(hint)
