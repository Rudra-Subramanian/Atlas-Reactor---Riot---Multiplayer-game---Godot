extends Control

@onready var bottom_bar = $"bottom character"

@onready var left_bar = $actions

@onready var right_bar = $"Turn end actions"

@onready var CharacterList : Array = []

@onready var Ability1_button = $"actions/ability 1"
@onready var Ability2_button = $"actions/ability 2"
@onready var Ability3_button = $"actions/ability 3"
@onready var Ability4_button = $"actions/ability 4"

@onready var character_1: Button = $"bottom character/character1"
@onready var character_2: Button =$"bottom character/character2"
@onready var character_3: Button =$"bottom character/character3"
@onready var character_4: Button =$"bottom character/character4"
@onready var character_5: Button =$"bottom character/character5"
@onready var character_button_list = [character_1, character_2,character_3,character_4,character_5]
@onready var free_cam: Button =$"bottom character/free cam"

@onready var camera_3d = null

@export var Agents : Array[Node3D] = []

enum ClickMode {NOCLICK, CHARACTER}
@onready var current_click_mode = ClickMode.NOCLICK


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

func initialize_character_list(new_character_list: Array):
	CharacterList = new_character_list
	for i in range(len(CharacterList)):
		ChangeBottomBar(CharacterList[i], i)
	update_bottom_bar_buttons()
	return

func update_bottom_bar_buttons():
	var character_list_length = len(CharacterList)
	for i in range(len(character_button_list)):
		if i < character_list_length:
			character_button_list[i].show()
		else:
			character_button_list[i].hide()
		
		
		
	
	
	
func initialize_camera(camera_to_connect : Camera3D):
	camera_3d = camera_to_connect

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
	



# --------------------------------------- INPUT HANDLING CLICKS ----------------------------------

func _unhandled_input(event: InputEvent) -> void:
	var CLICK_MODE = null
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and camera_3d != null):
		#var cell = get_cell_item(event.position)
		#print('EVENT: %s \n cell: %s' % [event, cell])
		var pos = event.position
		var from =  camera_3d.project_ray_origin(pos)
		var to = from + camera_3d.project_ray_normal(pos) * 1000
		var space_state = camera_3d.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if len(result) > 0:
			print('Clicked Position: %s' % [result.position])


	
	return

		
	
	
	
	
