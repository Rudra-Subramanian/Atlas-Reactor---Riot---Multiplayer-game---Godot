extends Control
#Gamestate options false is
@export var GameStates : Array = ['Decision','Dash', 'Action', 'Movement', 'Turn End']
@export var GameState : bool = false
@export var GameStep: String = 'Decision'
@onready var all_characters = ['astra']
@export var ready_characters = []

@onready var bottom_panel : HBoxContainer = $"bottom character"
@onready var actions: VBoxContainer = $"actions"
@onready var turn_end_actions: VBoxContainer = $"Turn end actions"

@onready var astra: CharacterBody3D = $"../astra"

signal move_characters
signal CurrentGameStep(step)




func _ready() -> void:
	CurrentGameStep.connect(ManageGameState)
	astra.movement_finished.connect(set_character_done_movement)


func check_all_movement_done() -> bool:
	for i in all_characters:
		if i not in ready_characters:
			return false
	# when done return true but reset to nothing
	ready_characters = []
	return true

func set_character_done_movement(character: String, bool_value: bool) -> void:
	print('%s moving' % [character])
	if bool_value != true:
		print("character is still moving")
		return
	if character not in ready_characters:
		print('appending character: %s to all_characters: %s' % [character, ready_characters])
		ready_characters.append(character)
	change_state_player_actions()
	return




func _confirm_button_pressed() -> void:
	CurrentGameStep.emit('Confirm')
	
	# Disable actions and turn end actions buttons
	for button in actions.get_children():
		if button is Button:
			button.disabled = true
	for button in turn_end_actions.get_children():
		if button is Button:
			button.disabled = true
	
	# Make control UI not able to be clicked through
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Start moving characters
	move_characters.emit()
	
	# Set GameState to true
	GameState = true

func change_state_player_actions() -> void:
	if check_all_movement_done():
		print('all movement done')
		# Make main control UI able to be clicked through
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Enable all disabled buttons
		for button in actions.get_children():
			if button is Button:
				button.disabled = false
		for button in turn_end_actions.get_children():
			if button is Button:
				button.disabled = false
		
		# Set GameState to false
		GameState = false
	else:
		return

func ManageGameState(step: String) -> void:

	
	return
