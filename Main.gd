extends Control

const MAX_ATTEMPTS := 12
const PASSWORD_LENGTH := 8

var current_attempt := 0
var password: Array = []
var current_input: Array[String] = []
var current_column := 0
var current_row
var game_won := false

@onready var grid := $Grid
@onready var attempts := $Info/Attempts
@onready var keyboard := $Keyboard
@onready var a_row := $ARow
	
func _ready():
	var music = load("res://Assets/Music.wav") as AudioStream
	$MusicPlayer.stream = music
	$MusicPlayer.play()
	$Background.play("default")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_viewport().set_size(Vector2i(1920, 1080))
	generate_password()
	create_empty_rows()
	for row in grid.get_children():
		row.set_expected_types(password)
	current_row = grid.get_child(0)
	await get_tree().process_frame
	if current_row:
		current_row.grab_focus()
		current_row.set_active(true)

	keyboard.connect("key_pressed", Callable(self, "_on_virtual_key_pressed"))
	update_attempts_label()
	set_process_unhandled_input(true)

func generate_password():
	var chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	password.clear()
	for i in PASSWORD_LENGTH:
		password.append(chars[randi() % chars.length()])
	print("Senha gerada: ", password)  # Tirar dps

func create_empty_rows():
	for i in MAX_ATTEMPTS:
		var row = preload("res://ARow.tscn").instantiate()
		grid.add_child(row)
	current_row = grid.get_child(0)

func create_new_attempt():
	var row_scene = preload("res://ARow.tscn").instantiate()
	$Grid.add_child(row_scene)
	current_row = row_scene
	current_row.grab_focus()

func update_attempts_label():
	attempts.text = "Tentativas restantes: %d" % (MAX_ATTEMPTS - current_attempt)

func is_all_correct(result: Array) -> bool:
	for status in result:
		if status != "correct":
			return false
	return true
	
func move_cursor(dir: int):
	current_column = clamp(current_column + dir, 0, PASSWORD_LENGTH - 1)

func add_char_at_cursor(char: String):
	if current_column < PASSWORD_LENGTH:
		if current_input.size() <= current_column:
			while current_input.size() < current_column:
				current_input.append("_")
			current_input.append(char)
		else:
			current_input[current_column] = char
		update_input_display()
		move_cursor(1)

func remove_char_at_cursor():
	if current_column < current_input.size():
		current_input[current_column] = "_"
		update_input_display()

	
func _unhandled_input(event):
	$TypePlayer.stream = preload("res://Assets/Type.wav")
	$TypePlayer.play()
	if game_won or current_row == null:
		if event.keycode == Key.KEY_ESCAPE:
			get_tree().quit()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Key.KEY_LEFT:
			current_row.move_cursor(-1)
		elif event.keycode == Key.KEY_RIGHT:
			current_row.move_cursor(1)
		elif event.keycode == Key.KEY_BACKSPACE:
			current_row.remove_char_at_cursor()
		elif event.keycode == Key.KEY_ENTER:
			submit_current_input()
		elif event.keycode == Key.KEY_ESCAPE:
			get_tree().quit()
		else:
			var char = event.as_text().to_upper()
			if char.length() == 1 and (
				(char >= "A" and char <= "Z") or 
				(char >= "0" and char <= "9")
			):
				current_row.set_char_at_cursor(char)

func _on_virtual_key_pressed(char: String):
	if game_won or current_row == null:
		return
	current_row.set_char_at_cursor(char)

func add_char_to_input(char: String):
	if current_input.size() < PASSWORD_LENGTH:
		current_input.append(char)
		update_input_display()

func remove_last_char():
	if current_input.size() > 0:
		current_input.pop_back()
		update_input_display()

func update_input_display():
	var row = grid.get_child(current_attempt)
	if not row:
		return
	for i in range(PASSWORD_LENGTH):
		var panel = row.get_child(i)
		var label = panel.get_child(0)
		if label and label is Label:
			label.text = current_input[i] if i < current_input.size() and current_input[i] != "_" else "_"
			
func submit_current_input():
	$TryPlayer.stream = preload("res://Assets/Try.wav")
	$TryPlayer.play()
	
	if current_row == null:
		return
		
	if not current_row.is_complete():
		return
	var guess = current_row.get_current_input()
	submit_attempt(guess)
	current_row.set_active(false)
	
	if current_attempt < MAX_ATTEMPTS:
		current_row = grid.get_child(current_attempt)  
		current_row.set_active(true)
	else:
		current_row = null
	current_input.clear()
	current_column = 0
	update_input_display()
	
	if current_input.size() == PASSWORD_LENGTH:
		submit_attempt(current_input.duplicate())
		current_input.clear()
		update_input_display()
	current_input = []
	current_column = 0
	update_input_display()


func submit_attempt(guess: Array):
	if guess.size() != PASSWORD_LENGTH:
		return
	var result := evaluate_attempt(guess)
	var row := grid.get_child(current_attempt)
	row.update_cells(guess, result)
	keyboard.update_keys(guess, result)
	current_attempt += 1
	update_attempts_label()

	if is_all_correct(result):
		show_victory()
	elif current_attempt >= MAX_ATTEMPTS:
		show_game_over()

func evaluate_attempt(guess: Array) -> Array:
	var result := []
	for i in PASSWORD_LENGTH:
		if guess[i] == password[i]:
			result.append("correct")
		elif guess[i] in password:
			result.append("present")
		else:
			result.append("absent")
	return result

func show_victory():
	$Info/Rules.text = "Parabéns! Você acertou a senha!"
	game_won = true

func show_game_over():
	$GameoverPlayer.stream = preload("res://Assets/Gameover.wav")
	$GameoverPlayer.play()
	$MusicPlayer.stop()
	$Info/Rules.text = "Fim de jogo! A senha era: %s" % String("").join(password)
