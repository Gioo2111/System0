extends HBoxContainer

@onready var cells := get_children()
const Colors = preload("res://Assets/Colors.gd")
var selected_index := 0
var panels : Array = []

func _ready():
	_set_initial_borders()
	panels.clear()
	for i in range(get_child_count()):
		panels.append(get_child(i))
	update_highlight()
	
func set_expected_types(secret_word: Array):
	var cells = get_children()
	for i in range(secret_word.size()):
		var cell = cells[i]
		var char = str(secret_word[i])

		if char.is_valid_int():
			cell.add_theme_color_override("border_color", Color.BLUE)
		elif char.is_valid_identifier() or (char >= "A" and char <= "Z") or (char >= "a" and char <= "z"):
			cell.add_theme_color_override("border_color", Color.PURPLE)
		else:
			cell.add_theme_color_override("border_color", Color.GRAY) # fallback para símbolos
	
func _set_initial_borders():
	for cell in cells:
		var label = cell.get_node("Label1")
		if label.text.length() > 0:
			if label.text.is_valid_integer():
				cell.add_theme_color_override("border_color", Color.BLUE)
			elif label.text.is_valid_identifier() or label.text.is_valid_string():
				cell.add_theme_color_override("border_color", Color.WEB_PURPLE)
	
func update_cells(guess: Array, result: Array) -> void:
	for i in range(min(guess.size(), panels.size())):
		var panel = panels[i]
		var label = panel.get_child(0) as Label
		if label:
			label.text = str(guess[i])
			
		match result[i]:
			"correct":
				panel.modulate = Colors.CORRECT
			"present":
				panel.modulate = Colors.PRESENT
			"absent":
				panel.modulate = Colors.ABSENT
			_:
				panel.modulate = Color(1, 1, 1)

func update_highlight():
	for i in range(panels.size()):
		if i == selected_index:
			panels[i].modulate = Color(1, 1, 0) # Amarelo para destaque
		else:
			panels[i].modulate = Color(1, 1, 1) # Branco normal

func move_cursor(direction: int):
	selected_index = clamp(selected_index + direction, 0, panels.size() - 1)
	update_highlight()

func set_char_at_cursor(char: String):
	var label = panels[selected_index].get_child(0) # Label dentro do Panel
	label.text = char
	update_highlight()
	if selected_index < panels.size() - 1:
		move_cursor(1)
		return true
	return false

func remove_char_at_cursor():
	var label = panels[selected_index].get_child(0)
	label.text = ""
	update_highlight()

func get_current_input() -> Array:
	var arr = []
	for panel in panels:
		var label = panel.get_child(0) as Label
		arr.append(label.text if label else "")
	return arr
