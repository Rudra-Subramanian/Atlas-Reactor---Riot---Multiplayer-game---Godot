extends Node


@onready var movement_path: Array[Vector3] = []
@export var walking_speed: float = 5
@export var peeking_speed: float = 5
@export var sprinting_speed: float = 8
@export var sneaking_speed: float = 3
@export var current_movement_speed: float = 10.0 #knife run speed
@onready var Health : float = 100
#Phases are 1: Prep, 2: Dash, 3: Attack, 4: Movement 
@onready var TurnActions: Dictionary = {1: null, 2: null, 3: null, 4: null} 

@onready var Action_list : Dictionary = {'Sprint': null, 'Walk': null, 'Sneak': null, 'Peek': null,  'Hold': null, 'Ability1': null, 'Ability2': null, "Ability3": null, 'Ability4': null}
@onready var Current_Action : String = ''
@onready var Last_Action: String = ''


enum CharacterState {
	WAIT,
	WALK,
	RUN,
	SPRINT,
	PEEK,
	HOLD,
	ABILITY1,
	ABILITY2,
	ABILITY3,
	ABILITY4,
	DONE
}

@onready var CurrentState = CharacterState.WAIT

func _ready() -> void:
	initialize_actions()
	return

func get_path_to_movement_position(position_from, position_to) -> Array:
	#find path to point
	var path_finder = NavigationPathFinderHelper.new()
	#adding child to world to get proper positions
	add_child(path_finder)
	var found_path = path_finder.query_path(position_from, position_to)
	#removing child from world to not clog 
	remove_child(path_finder)
	#print('found a path to the point from the last point %s' % [found_path])
	return found_path


func check_if_valid_movement_position(action: String, extra_movement_path: Array) -> bool:
	
	var total = 0
	var previous_point = null
	for point in extra_movement_path:
		if previous_point == null:
			previous_point = point
		else:
			total = total + previous_point.distance_to(point)
			previous_point = point
	if total <= Action_list[action].get_distance_left():
		print('Valid movement of %s length' % [total])
		return true
	else:
		print('INVALID MOVEMENT OF LENGTH %s over by %s' % [total, total - Action_list[action].get_distance_left()])
		return false
	
	return false

func SetTurnAction(turn: int, action: ActionBasis):
	TurnActions[turn] = action
	return

func initialize_actions() -> void:
	var initialize_string = 'initialize_'
	var function_to_run = Expression.new()
	for action in Action_list:
		#print('Action name %s - Value %s' % [action, Action_list[action]])
		var function_string = initialize_string + action + '()'
		function_to_run.parse(function_string)
		function_to_run.execute([],self)
		#print(Action_list[action])
	return
	
	
func initialize_Sprint():
	var sprint_action = ActionBasis.new()
	sprint_action.action_type = ActionBasis.ActionType.MOVE
	sprint_action._set_move_speed(6)
	sprint_action._set_move_distance(10)
	sprint_action._set_action_turn(4)
	sprint_action.add_movement_point(get_parent().global_position)
	Action_list['Sprint'] = sprint_action
	return

func initialize_Walk():
	var walk_action = ActionBasis.new()
	walk_action.action_type = ActionBasis.ActionType.SHOOT
	walk_action._set_move_speed(4)
	walk_action._set_move_distance(25/4)
	walk_action._set_action_turn((4))
	walk_action.add_movement_point(get_parent().global_position)
	Action_list['Walk'] = walk_action
	return
	
func initialize_Sneak():
	var sneak_action = ActionBasis.new()
	sneak_action.action_type = ActionBasis.ActionType.SHOOT
	sneak_action._set_move_speed(2)
	sneak_action._set_move_distance(15.0/4)
	sneak_action._set_action_turn((4))
	sneak_action.add_movement_point(get_parent().global_position)
	Action_list['Sneak'] = sneak_action
	
	return
func initialize_Peek():
	var peek_action = ActionBasis.new()
	peek_action.action_type = ActionBasis.ActionType.SHOOT
	peek_action._set_move_speed(4)
	peek_action._set_move_distance(5.0/4)
	peek_action._set_action_turn((4))
	peek_action.add_movement_point(get_parent().global_position)
	Action_list['Peek'] = peek_action
	return
func initialize_Hold():
	var hold_action = ActionBasis.new()
	hold_action.action_type = ActionBasis.ActionType.SHOOT
	hold_action._set_action_turn(3)
	hold_action.set_shoot_point(get_parent().global_position)
	Action_list['Hold'] = hold_action
	return

func initialize_Ability1():
	var ability1 = ActionBasis.new()
	ability1.action_type = ActionBasis.ActionType.THROW
	ability1._set_action_turn(3)
	ability1.set_throw_point(get_parent().global_position)
	ability1.set_throw_distance(15.0)
	Action_list['Ability1'] = ability1
	return

func initialize_Ability2():
	var ability2 = ActionBasis.new()
	ability2.action_type = ActionBasis.ActionType.CAST
	ability2._set_action_turn(3)
	ability2.set_cast_node(get_parent())
	Action_list['Ability2'] = ability2
	return

func initialize_Ability3():
	var ability3 = ActionBasis.new()
	ability3.action_type = ActionBasis.ActionType.USE
	ability3._set_action_turn(3)
	ability3.set_use_node(get_parent())
	Action_list['Ability3'] = ability3
	return

func initialize_Ability4():
	var ability4 = ActionBasis.new()
	ability4.action_type = ActionBasis.ActionType.MOVE
	ability4._set_move_speed(8.0)
	ability4._set_move_distance(12.0)
	ability4._set_action_turn(2)
	ability4.add_movement_point(get_parent().global_position)
	Action_list['Ability4'] = ability4
	return
	
	
func reset_Sprint():
	var sprint_action = Action_list['Sprint']
	sprint_action.set_movement_zero(get_parent().global_position)
	Action_list['Sprint'] = sprint_action
	print(get_parent().global_position)

func reset_Walk():
	var walk_action = Action_list['Walk']
	walk_action.set_movement_zero(get_parent().global_position)
	Action_list['Walk'] = walk_action

func reset_Sneak():
	var sneak_action = Action_list['Sneak']
	sneak_action.set_movement_zero(get_parent().global_position)
	Action_list['Sneak'] = sneak_action

func reset_Peek():
	var peek_action = Action_list['Peek']
	peek_action.set_movement_zero(get_parent().global_position)
	Action_list['Peek'] = peek_action

func reset_Hold():
	var hold_action = Action_list['Hold']
	if hold_action:
		hold_action.set_shoot_point(get_parent().global_position)
		Action_list['Hold'] = hold_action

func reset_Ability1():
	var ability1 = Action_list['Ability1']
	if ability1:
		ability1.set_throw_point(get_parent().global_position)
		Action_list['Ability1'] = ability1

func reset_Ability2():
	var ability2 = Action_list['Ability2']
	if ability2:
		ability2.set_cast_node(null)
		Action_list['Ability2'] = ability2

func reset_Ability3():
	var ability3 = Action_list['Ability3']
	if ability3:
		ability3.set_use_node(null)
		Action_list['Ability3'] = ability3

func reset_Ability4():
	var ability4 = Action_list['Ability4']
	if ability4:
		ability4.set_movement_zero(get_parent().global_position)
		Action_list['Ability4'] = ability4
	
	


func reset_Actions():
	TurnActions = {1: null, 2: null, 3: null, 4: null}
	var initialize_string = 'reset_'
	var function_to_run = Expression.new()
	for action in Action_list:
		#print('Action name %s - Value %s' % [action, Action_list[action]])
		var function_string = initialize_string + action + '()'
		function_to_run.parse(function_string)
		function_to_run.execute([],self)
		#print(Action_list[action])
	return


func set_Action(Action_name: String, action: ActionBasis):
	Action_list[Action_name] = action
	Last_Action = Current_Action
	Current_Action = ''
	

func set_Turn(Action_name: String):
	if Action_name:
		TurnActions[Action_list[Action_name].action_turn] = Action_list[Action_name]
	
