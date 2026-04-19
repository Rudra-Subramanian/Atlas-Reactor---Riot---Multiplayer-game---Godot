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
	sprint_action._set_move_speed(8)
	sprint_action._set_move_distance(10)
	sprint_action._set_action_turn((4))
	sprint_action.add_movement_point(get_parent().global_position)
	Action_list['Sprint'] = sprint_action
	return

func initialize_Walk():
	var walk_action = ActionBasis.new()
	walk_action.action_type = ActionBasis.ActionType.MOVE
	walk_action._set_move_speed(5)
	walk_action._set_move_distance(25/4)
	walk_action._set_action_turn((4))
	walk_action.add_movement_point(get_parent().global_position)
	Action_list['Walk'] = walk_action
	return
	
func initialize_Sneak():
	return
func initialize_Peek():
	return
func initialize_Hold():
	return
func initialize_Ability1():
	return
func initialize_Ability2():
	return
func initialize_Ability3():
	return
func initialize_Ability4():
	return


func set_Action(Action_name: String, action: ActionBasis):
	Action_list[Action_name] = action
	Last_Action = Current_Action
	Current_Action = ''
	

func set_Turn(Action_name: String):
	if Action_name:
		TurnActions[Action_list[Action_name].action_turn] = Action_list[Action_name]
	
