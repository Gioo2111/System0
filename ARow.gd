extends HBoxContainer

@onready var cells := get_children()
const Colors = preload("res://Assets/Colors.gd")
var selected_index := 0
var panels : Array = []
var is_active := false

func _ready():
	panels.clear()
	for i in range(get_child_count()):
		panels.append(get_child(i))
	update_highlight()

func set_active(active: bool):
	is_active = active
	update_highlight()

func is_complete() -> bool:
	for panel in panels:
		var label := panel.get_child(0) as Label
		if not label:
			return false
		var t := label.text.strip_edges()
		if t.length() != 1:
			return false
		if not ((t >= "A" and t <= "Z") or (t >= "0" and t <= "9")):
			return false
	return true

func set_expected_types(secret_word: Array):
	var cells = get_children()
	for i in range(secret_word.size()):
		if i >= cells.size():
			break
			
		var cell = cells[i]
		var char = str(secret_word[i])
	
		var style := StyleBoxFlat.new()
		style.border_width_top = 3
		style.border_width_bottom = 3
		style.border_width_left = 3
		style.border_width_right = 3
		style.bg_color = Color(0,0,0,0)
		
		if char.is_valid_int():
			style.border_color = Colors.NUMBER_COLOR
		elif char.is_valid_identifier() or (char >= "A" and char <= "Z") or (char >= "a" and char <= "z"):
			style.border_color = Colors.LETTER_COLOR
		else:
			style.border_color = Color.DARK_GRAY
			
		cell.add_theme_stylebox_override("panel", style)

func update_cells(guess: Array, result: Array) -> void:
	for i in range(min(guess.size(), panels.size())):
		var panel = panels[i]
		var label = panel.get_child(0) as Label
		if label:
			label.text = str(guess[i])
		var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			match result[i]:
				"correct":
					style.bg_color = Color(0, 1, 0, 0.3)
					label.add_theme_color_override("font_color", Color.GREEN)
				"present":
					style.bg_color = Color(1, 1, 0, 0.3)
					label.add_theme_color_override("font_color", Color.YELLOW)
				"absent":
					style.bg_color = Color(0.3, 0.3, 0.3, 0.3)
					label.add_theme_color_override("font_color", Color.GRAY)
				_:
					style.bg_color = Color(0, 0, 0, 0)
					label.add_theme_color_override("font_color", Color.WHITE)
			panel.add_theme_stylebox_override("panel", style)
			panel.set_meta("result_bg_applied", true)

func update_highlight():
	for i in range(panels.size()):
		var panel = panels[i]
		var style:= panels[i].get_theme_stylebox("panel") as StyleBoxFlat
		if not style:
				continue
		var has_result = panel.has_meta("result_bg_applied") and panel.get_meta("result_bg_applied")

		if is_active and i == selected_index:
			if not has_result:
				style.bg_color = Color(0, 1, 0, 0.3)
		else:
			if not has_result:
				style.bg_color = Color(0, 0, 0, 0)

		panel.add_theme_stylebox_override("panel", style)

func move_cursor(direction: int):
	selected_index = clamp(selected_index + direction, 0, panels.size() - 1)
	update_highlight()

func set_char_at_cursor(char: String):
	var label = panels[selected_index].get_child(0)
	label.text = char
	update_highlight()
	if selected_index < panels.size() - 1:
		move_cursor(1)
		return true
	return false

func remove_char_at_cursor():
	var label = panels[selected_index].get_child(0)
	if label.text != "":
		label.text = ""
	label.text = ""
	if selected_index > 0:
		selected_index -= 1
	update_highlight()

func get_current_input() -> Array:
	var arr = []
	for panel in panels:
		var label = panel.get_child(0) as Label
		arr.append(label.text if label else "")
	return arr
