extends Node

@onready var character_state_machine = $"../state machine"

@onready var BaseCharacterNode = $".."


func ResolveAllTurns():
	var Actions_to_resolve = character_state_machine.TurnActions
	print('Resolving turn with actions: %s' % [Actions_to_resolve])
	for i in range(1,5):
		ResolveAction(Actions_to_resolve[i])
		
	return
	
func ResolveTurn(index: int):
	var Actions_to_resolve = character_state_machine.TurnActions
	ResolveAction(character_state_machine.TurnActions[index])



func ResolveAction(action : ActionBasis) -> bool:
	if action == null:
		return true
	var action_type = action.action_type
	var movement_points = action.movement_points
	var movement_speed = action.move_speed
	print('\naction type = %s
	\n all movement points : %s
	\n speed to move : %s' % [action_type, movement_points, movement_speed])
	return true
	
	
