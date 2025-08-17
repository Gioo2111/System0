extends Control

const MAX_ATTEMPTS := 12
const PASSWORD_LENGTH := 8

var current_attempt := 0
var password: Array = []

@onready var grid := $Grid
@onready var attempts := $InfoPanel/Attempts
@onready var keyboard := $Keyboard

func _ready():
	generate_password()
	create_empty_rows()
	update_attempts_label()

func generate_password():
	var chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	password.clear()
	for i in PASSWORD_LENGTH:
		password.append(chars[randi() % chars.length()])
	print("Senha gerada: ", password)  # Remover depois para produção

func create_empty_rows():
	for i in MAX_ATTEMPTS:
		var row = preload("res://AttemptRow.tscn").instantiate()
		password_grid.add_child(row)

func update_attempts_label():
	attempts_label.text = "Tentativas restantes: " + str(MAX_ATTEMPTS - current_attempt)

func submit_attempt(guess: Array):
	if guess.size() != PASSWORD_LENGTH:
		return

	var result := evaluate_attempt(guess)
	var row := password_grid.get_child(current_attempt)
	row.update_cells(guess, result)

	keyboard.update_keys(guess, result)

	current_attempt += 1
	update_attempts_label()

	if result == ["correct"] * PASSWORD_LENGTH:
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
	print("Você venceu!")
	# Implementar feedback visual

func show_game_over():
	print("Fim de jogo! A senha era: ", password.join(""))
	# Implementar feedback visual
