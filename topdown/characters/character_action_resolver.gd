extends Node

@onready var character_state_machine = $"../state machine"

@onready var BaseCharacterNode = $".."

@onready var CurrentMovementSpeed : int = 0
@onready var CurrentActionProgression :  float = 0
enum CurrentState {NONE, SHOOT, MOVE, THROW, USE , CAST}
@onready var current_state : CurrentState = CurrentState.NONE
@onready var movement_path3d : Path3D = null

signal TurnDone(turn_number : int)
signal MovementDone

func _ready() -> void:
	return


func ResolveAllTurns():
	var Actions_to_resolve = character_state_machine.TurnActions
	print('Resolving turn with actions: %s' % [Actions_to_resolve])
	for i in range(1,5):
		ResolveAction(Actions_to_resolve[i])
	#set all actions to null again
	character_state_machine.reset_Actions()
		
	return
	
func ResolveTurn(index: int):
	var Actions_to_resolve = character_state_machine.TurnActions
	ResolveAction(character_state_machine.TurnActions[index])
	TurnDone.emit(index)



func ResolveAction(action : ActionBasis) -> bool:
	if action == null:
		return true
	var action_type = action.action_type
	var movement_points = action.movement_points
	var movement_speed = action.move_speed
	CurrentMovementSpeed = movement_speed
	print('\naction type = %s
	\n all movement points : %s
	\n speed to move : %s' % [action_type, movement_points, movement_speed])
	if action_type == action.ActionType.MOVE:
		var started_movement = ResolveMovement(action)
		if started_movement:
			var check_finish_movement = await MovementFinished()
			
	return true

func MovementFinished():
	if current_state == CurrentState.MOVE:
		await get_tree().create_timer(1).timeout
		MovementFinished()
	else:
		return true


func ResolveMovement(action: ActionBasis) -> bool:
	#generate curve3d
	var curve_path = Curve3D.new()
	for point in action.movement_points:
		curve_path.add_point(point)
	
	
		
	#generate path3d
	movement_path3d = Path3D.new()
	#generate followpath3d
	var follow_path3d = PathFollow3D.new()
	movement_path3d.add_child(follow_path3d)
	movement_path3d.curve = curve_path
	var remote_transform = RemoteTransform3D.new()
	follow_path3d.add_child(remote_transform)
	get_tree().get_root().get_child(0).add_child(movement_path3d)
	var path_to_player = remote_transform.get_path_to(get_parent())
	remote_transform.set_remote_node(path_to_player)

	current_state = CurrentState.MOVE
	
	
	
	
	return true
	
func _process(delta: float) -> void:
	if current_state == CurrentState.MOVE:
		#print(movement_path3d)
		if movement_path3d != null:
			var pathfollower = movement_path3d.get_child(0)
			if movement_path3d.get_child(0).progress_ratio == 1:
				#movement_path3d.get_child(0).get_child(0).remote_path = null
				#movement_path3d.queue_free()
				print(movement_path3d)
				current_state = CurrentState.NONE
				
			else:
				var old_progress_ratio = movement_path3d.get_child(0).progress_ratio
				print('moving node, %s' % [movement_path3d.get_child(0).progress])
				movement_path3d.get_child(0).progress = movement_path3d.get_child(0).progress + (CurrentMovementSpeed * delta)
				var new_progress_ratio = movement_path3d.get_child(0).progress_ratio
				if new_progress_ratio< old_progress_ratio:
					movement_path3d.get_child(0).progress_ratio = 1
				
					
				
			 
	
	
