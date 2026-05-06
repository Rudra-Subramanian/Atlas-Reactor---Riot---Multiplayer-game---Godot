extends Control

@onready var bottom_bar = $"bottom character"

@onready var left_bar = $actions

@onready var right_bar = $"Turn end actions"
@onready var cancel_button = $"Turn end actions/cancel button"
@onready var confirm_button = $"Turn end actions/confirm button"

@onready var Ability1_button = $"actions/ability 1"
@onready var Ability2_button = $"actions/ability 2"
@onready var Ability3_button = $"actions/ability 3"
@onready var Ability4_button = $"actions/ability 4"

@onready var action_sprint: Button = $actions/action_sprint
@onready var action_sneak: Button = $actions/action_sneak
@onready var action_peek: Button = $actions/action_peek
@onready var action_hold: Button = $actions/action_hold
@onready var action_walk: Button = $actions/action_walk


@onready var character_1: Button = $"bottom character/character1"
@onready var character_2: Button =$"bottom character/character2"
@onready var character_3: Button =$"bottom character/character3"
@onready var character_4: Button =$"bottom character/character4"
@onready var character_5: Button =$"bottom character/character5"
@onready var character_button_list = [character_1, character_2,character_3,character_4,character_5]
@onready var free_cam: Button =$"bottom character/free cam"

@onready var camera_3d = null

@export var Agents : Array = []
@export var current_character : Node3D = null

enum ClickMode {NOCLICK, CHARACTER_MOVE, CHARACTER_ACTION, CHARACTER_AIM}
@onready var current_click_mode = ClickMode.NOCLICK



# Helper display meshes 
# Region display for movement 
# Aim display for aiming area
# arc display for throwing things
@onready var region_display : MeshInstance3D = null

signal Character_Pressed(Character: Node3D)
signal FreeCamStart
signal ActionPressed(ButtonName: String, character_node : Node3D)
signal CancelPressed
signal ConfirmPressed

func _ready() -> void:
	cancel_button.pressed.connect(CancelPressed.emit)
	confirm_button.pressed.connect(ConfirmPressed.emit)
	
	character_1.pressed.connect(Char1_pressed)
	character_2.pressed.connect(Char2_pressed)
	character_3.pressed.connect(Char3_pressed)
	character_4.pressed.connect(Char4_pressed)
	character_5.pressed.connect(Char5_pressed)
	free_cam.pressed.connect(free_cam_pressed)
	action_sprint.pressed.connect(action_button_pressed.bind('Sprint'))
	action_walk.pressed.connect(action_button_pressed.bind('Walk'))
	action_peek.pressed.connect(action_button_pressed.bind('Peek'))
	action_hold.pressed.connect(action_button_pressed.bind('Hold'))
	action_sneak.pressed.connect(action_button_pressed.bind('Sneak'))
	Ability1_button.pressed.connect(action_button_pressed.bind('Ability1'))
	Ability2_button.pressed.connect(action_button_pressed.bind('Ability2'))
	Ability3_button.pressed.connect(action_button_pressed.bind('Ability3'))
	Ability4_button.pressed.connect(action_button_pressed.bind('Ability4'))
	Character_Pressed.connect(_character_pressed)
	ConfirmPressed.connect(_confirm_pressed)
	CancelPressed.connect(_cancel_pressed)
	ActionPressed.emit('None')
	ChangeLeftBar(current_character)
	EnableUI()
	


func _confirm_pressed():
	print('confirm actions')
	return

func _cancel_pressed():
	print('removing current action')
	var cursor = camera_3d.get_child(0)
	var character_position = current_character.global_position
	var action_name = current_character.get_child(1).Current_Action
	# GETTING CURRENT ACTION NAME
	if  action_name == '':
		action_name = current_character.get_child(1).Last_Action
		if action_name == '':
			return
	var current_character_action = current_character.get_child(1).Action_list[action_name]
	var character_final_movement_position = current_character_action.get_last_point()
	var character_move_distance = current_character_action.get_distance_left()
	cursor.update_show(false)
	# REINITIALIZE ACTION (Could replace with reset)
	var initialize_string = 'current_character.get_child(1).reset_'
	var function_to_run = Expression.new()
	#print('Action name %s - Value %s' % [action, Action_list[action]])
	var function_string = initialize_string + action_name + '()'
	function_to_run.parse(function_string)
	function_to_run.execute([],self)
	current_click_mode = ClickMode.NOCLICK
	EnableActions()
	region_display.clear_mesh()
	region_display.remove_lines()
	return

func action_button_pressed(action_string: String):
	if current_character:
		ActionPressed.emit(action_string, current_character)
		var current_character_script = current_character.get_child(1)
		var character_action = current_character_script.Action_list[action_string]
		if character_action == null:
			return
		current_character.get_child(1).Current_Action = action_string
		if character_action.action_type == ActionBasis.ActionType.MOVE:
			print('move_action: %s' % [action_string])
			#set click mode to character movement
			current_click_mode = ClickMode.CHARACTER_MOVE
			DisableActions()
			region_display.remove_region()
			var circle_radius = character_action.get_distance_left()
			var center_position = character_action.get_last_point()
			
			#var radius = move distance (distance to move left) action class function
			#var center_position = end point of string (all ) also action class function
			#should change action class at end when pressing next button
			
			region_display.display_region(center_position, circle_radius, false)
	return
	
func _character_pressed(character : Node3D):
	current_character = character
	ChangeLeftBar(current_character)
	set_label(character.name)
	return


func initialize_character_list(new_character_list: Array):
	Agents = new_character_list
	for i in range(len(Agents)):
		ConfirmPressed.connect(Agents[i].get_child(2).ResolveAllTurns)
		
		ChangeBottomBar(Agents[i], i)
	update_bottom_bar_buttons()
	return

func update_bottom_bar_buttons():
	var character_list_length = len(Agents)
	for i in range(len(character_button_list)):
		if i < character_list_length:
			character_button_list[i].show()
		else:
			character_button_list[i].hide()
		
		
		
	
	
	
func initialize_camera(camera_to_connect : Camera3D):
	camera_3d = camera_to_connect
	var cursor = camera_3d.get_children()[0]
	ActionPressed.connect(cursor.on_action_pressed)
	FreeCamStart.connect(camera_3d.stop_tracking)
	Character_Pressed.connect(camera_3d.track_character)

func Char1_pressed() -> void:
	if len(Agents) > 0:
		Character_Pressed.emit(Agents[0])
		print('emitting agent 1 : %s' % [Agents[0]])
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
		print(Character.get_child(1).walking_speed)
		bottom_bar_buttons[index].text = Character.name
	else:
		bottom_bar_buttons[index].text = 'Character %s' % [index]
	return

func ChangeLeftBar(Character: Node3D) -> void:
	if Character == null:
		var left_buttons = left_bar.get_children()
		for j in len(left_buttons):
			left_buttons[j].visible = false
	elif Character.get_child(1).Action_list:
		var i = 0
		var left_buttons = left_bar.get_children()
		for j in len(left_buttons):
			if left_buttons[j].name == 'current character':
				set_label(Character.name)
			else:
				var keynames = Character.get_child(1).Action_list.keys()
				left_buttons[j].text = keynames[i]
				i = i + 1
			left_buttons[j].visible = true
			
	return
	
func DisableActions() -> void:
	if current_character:
		for button in left_bar.get_children():
			if button is Button:
				button.disabled = true
		for button in bottom_bar.get_children():
			print(button.text)
			if (button is Button and button.text != current_character.name) and (button is Button and button.text != 'free cam') :
				button.disabled = true
		

func EnableActions() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for button in left_bar.get_children():
		if button is Button:
			button.disabled = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.disabled = false
	
		


func DisableUI() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	for button in left_bar.get_children():
		if button is Button:
			button.disabled = true
	for button in bottom_bar.get_children():
		if button is Button:
			button.disabled = true

func EnableUI() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for button in left_bar.get_children():
		if button is Button:
			button.disabled = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.disabled = false
	



# --------------------------------------- INPUT HANDLING CLICKS ----------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if current_click_mode == ClickMode.CHARACTER_MOVE:
		#COULD MAKE THIS ITS OWN FUNCTION (HANDLE CLICK)
		if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and camera_3d != null):
			HandleMovementClick(event)
			


	
	return




#HANDLING MOVEMENT CLICKS

func HandleMovementClick(event: InputEvent):
	if current_character:
		var character_position = current_character.global_position
		var current_character_action = current_character.get_child(1).Action_list[current_character.get_child(1).Current_Action]
		var character_final_movement_position = current_character_action.get_last_point()
		var character_move_distance = current_character_action.get_distance_left()
		print(character_final_movement_position, character_move_distance)
		print(current_character.get_child(1).Current_Action)
	
	
	
	
		var pos = event.position
		var from =  camera_3d.project_ray_origin(pos)
		var to = from + camera_3d.project_ray_normal(pos) * 1000
		var space_state = camera_3d.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if len(result) > 0:
			print('Clicked Position: %s' % [result.position])
			
					#SEND POSITION HERE TO WHEREVER IT NEEDS TO GO
			var cursor = camera_3d.get_children()[0]
			cursor.spin_cursor()
			var extra_movement_path = current_character.get_child(1).get_path_to_movement_position(character_final_movement_position, result.position)
			var valid_click_position =  current_character.get_child(1).check_if_valid_movement_position(current_character.get_child(1).Current_Action, extra_movement_path)
			if valid_click_position:
				cursor.update_show(false)
				current_character_action.add_movement_array(extra_movement_path)
				
				current_character.get_child(1).set_Action(current_character.get_child(1).Current_Action, current_character_action)
				print(current_character.get_child(1).Last_Action)
				current_character.get_child(1).set_Turn(current_character.get_child(1).Last_Action)
				current_click_mode = ClickMode.NOCLICK
				EnableActions()
				region_display.clear_mesh()
				
		
	
# ------------------------------- HANDLING CLICK END

	
	
