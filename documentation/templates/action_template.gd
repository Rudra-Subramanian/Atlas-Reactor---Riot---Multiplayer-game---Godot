## Custom Action Template
## Use this to create new character actions
## Based on ActionClass.gd

extends Node

class_name CustomActionTemplate

## TODO: Define your action parameters
const ACTION_NAME = "CustomAction"
const ACTION_TYPE = ActionBasis.ActionType.MOVE  # Or SHOOT, THROW, USE, CAST
const MOVE_SPEED = 5.0
const MOVE_DISTANCE = 10.0
const ACTION_PHASE = 4  # 1=Prep, 2=Dash, 3=Attack, 4=Movement

## Initialize the action
func create_action(starting_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	
	# Configure action
	action.action_type = ACTION_TYPE
	action._set_move_speed(MOVE_SPEED)
	action._set_move_distance(MOVE_DISTANCE)
	action._set_action_turn(ACTION_PHASE)
	
	# Set starting position
	action.set_movement_zero(starting_position)
	
	return action


## Example: Dash Action (Fast, short-distance movement)
static func create_dash_action(starting_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	action.action_type = ActionBasis.ActionType.MOVE
	action._set_move_speed(12.0)  # Fast
	action._set_move_distance(8.0)  # Short range
	action._set_action_turn(2)  # Dash phase
	action.set_movement_zero(starting_position)
	return action


## Example: Teleport Ability (Instant repositioning)
static func create_teleport_action(starting_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	action.action_type = ActionBasis.ActionType.CAST
	action._set_move_speed(100.0)  # Instant
	action._set_move_distance(15.0)  # Moderate range
	action._set_action_turn(3)  # Attack phase
	action.set_movement_zero(starting_position)
	return action


## Example: Sniper Shot (No movement, long range targeting)
static func create_sniper_shot_action(starting_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	action.action_type = ActionBasis.ActionType.SHOOT
	action._set_move_speed(0.0)  # No movement
	action._set_move_distance(25.0)  # Long range
	action._set_action_turn(3)  # Attack phase
	action.set_movement_zero(starting_position)
	return action


## Example: Grenade Throw (Arc trajectory, area effect)
static func create_grenade_action(starting_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	action.action_type = ActionBasis.ActionType.THROW
	action._set_move_speed(0.0)
	action._set_move_distance(12.0)  # Throw range
	action._set_action_turn(3)  # Attack phase
	action.set_movement_zero(starting_position)
	return action


## Validate action against character position
static func is_action_valid(action: ActionBasis, target_position: Vector3) -> bool:
	var last_point = action.get_last_point()
	var distance = last_point.distance_to(target_position)
	var remaining = action.get_distance_left()
	
	if distance > remaining:
		print("Target too far: ", distance, " > ", remaining)
		return false
	
	return true


## Add waypoint with validation
static func add_validated_waypoint(action: ActionBasis, position: Vector3) -> bool:
	var old_distance = action.get_current_distance()
	action.add_movement_point(position)
	var new_distance = action.get_current_distance()
	
	# Check if point was actually added (distance changed)
	if new_distance > old_distance:
		print("Waypoint added. Distance: ", new_distance, "/", action.move_distance)
		return true
	else:
		print("Waypoint rejected - exceeds distance")
		return false
