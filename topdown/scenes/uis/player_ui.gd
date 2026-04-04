extends Control

@onready var bottom_bar = $"bottom character"

@onready var left_bar = $actions

@onready var right_bar = $"Turn end actions"

@onready var CharacterList : Array[Node3D] = []

@onready var Ability1_button = $"actions/ability 1"
@onready var Ability2_button = $"actions/ability 2"
@onready var Ability3_button = $"actions/ability 3"
@onready var Ability4_button = $"actions/ability 4"

@onready var character_1: Button = $"bottom character/character1"
@onready var character_2: Button =$"bottom character/character2"
@onready var character_3: Button =$"bottom character/character3"
@onready var character_4: Button =$"bottom character/character4"
@onready var character_5: Button =$"bottom character/character5"
@onready var free_cam: Button =$"bottom character/free cam"

@export var Agents : Array[Node3D] = []


signal Character_Pressed(Character: Node3D)
signal FreeCamStart

func _ready() -> void:
	character_1.pressed.connect(Char1_pressed)
	character_2.pressed.connect(Char2_pressed)
	character_3.pressed.connect(Char3_pressed)
	character_4.pressed.connect(Char4_pressed)
	character_5.pressed.connect(Char5_pressed)
	free_cam.pressed.connect(free_cam_pressed)
	EnableUI()

func Char1_pressed() -> void:
	if len(Agents) > 0:
		Character_Pressed.emit(Agents[0])
	return
func Char2_pressed() -> void:
	if len(Agents) > 1:
		Character_Pressed.emit(Agents[1])
	return
func Char3_pressed() -> void:
	if len(Agents) > 2:
		Character_Pressed.emit(Agents[2])
	return
func Char4_pressed() -> void:
	if len(Agents) > 3:
		Character_Pressed.emit(Agents[3])
	return
func Char5_pressed() -> void:
	if len(Agents) > 4:
		Character_Pressed.emit(Agents[4])
	return
func free_cam_pressed() -> void:
	FreeCamStart.emit()
	return



func set_label(textstring : String) -> bool:
	var current_character_label = left_bar.get_child(0)
	if current_character_label.name == 'current character':
		current_character_label.text = textstring
		return true
	else:
		return false

func ChangeBottomBar(Character : Node3D, index : int) -> void:
	var bottom_bar_buttons = bottom_bar.get_children()
	if Character.name:
		bottom_bar_buttons[index].text = Character.name
	else:
		bottom_bar_buttons[index].text = 'Character %s' % [index]
	return

func ChangeLeftBar(Character: Node3D) -> void:
	if Character.Action_list:
		var i = 0
		var left_buttons = left_bar.get_children()
		for j in len(left_buttons):
			if left_buttons[j].name == 'current character':
				set_label(Character.name)
			else:
				left_buttons[j].text = Character.Action_list[i]
				i = i + 1
			
	return
	
func DisableUI() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	for button in left_bar.get_children():
		if button is Button:
			button.disabled = true
	for button in bottom_bar.get_children():
		if button is Button:
			button.disabled = true

func EnableUI() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for button in left_bar.get_children():
		if button is Button:
			button.disabled = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.disabled = false
	
		
	
	
	
	
