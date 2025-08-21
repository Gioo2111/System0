extends GridContainer

signal key_pressed(char: String)

func _ready():
	for btn in get_children():
		if btn is Button:
			btn.pressed.connect(func(): _on_key_button_pressed(btn.text))

func _on_key_button_pressed(char: String):
	emit_signal("key_pressed", char)


func update_keys(chars: Array, statuses: Array):
	for i in chars.size():
		var char : String = chars[i]
		var status : String = statuses[i]
		var btn := get_node_or_null(char)
		if btn:
			match status:
				"correct":
					btn.modulate = Color.GREEN
				"present":
					btn.modulate = Color.YELLOW
				"absent":
					btn.modulate = Color.BLACK
