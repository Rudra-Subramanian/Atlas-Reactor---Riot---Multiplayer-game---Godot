## Character Template
## Use this as a base for creating new playable characters
## Attach to CharacterBody3D node

extends CharacterBody3D

## TODO: Set character stats
@export_group("Character Stats")
@export var character_name: String = "NewCharacter"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var movement_speed: float = 5.0

## TODO: Define character actions
@export_group("Movement Actions")
@export var sprint_distance: float = 10.0
@export var sprint_speed: float = 8.0
@export var walk_distance: float = 6.25
@export var walk_speed: float = 5.0

## References
@onready var state_machine: Node = $CharacterStateMachine
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

## Signals
signal health_changed(new_health: float, max_health: float)
signal character_died()
signal action_started(action_name: String)
signal action_completed(action_name: String)


func _ready() -> void:
	# Setup character
	setup_character()
	
	# Initialize state machine if exists
	if state_machine:
		initialize_state_machine()


func setup_character() -> void:
	# Set character name
	name = character_name
	
	# Configure collision
	if collision:
		collision.shape = CylinderShape3D.new()
		collision.shape.radius = 0.5
		collision.shape.height = 2.0


func initialize_state_machine() -> void:
	# Initialize character's state machine with custom values
	if state_machine.has_method("_set_move_speed"):
		state_machine.walking_speed = walk_speed
		state_machine.sprinting_speed = sprint_speed
	
	# Custom action initialization
	initialize_custom_actions()


func initialize_custom_actions() -> void:
	# TODO: Initialize character-specific actions
	# Example: Add a unique ability to this character
	
	# Initialize Sprint
	var sprint = ActionBasis.new()
	sprint.action_type = ActionBasis.ActionType.MOVE
	sprint._set_move_speed(sprint_speed)
	sprint._set_move_distance(sprint_distance)
	sprint._set_action_turn(4)
	sprint.set_movement_zero(global_position)
	state_machine.Action_list['Sprint'] = sprint
	
	# Initialize Walk
	var walk = ActionBasis.new()
	walk.action_type = ActionBasis.ActionType.MOVE
	walk._set_move_speed(walk_speed)
	walk._set_move_distance(walk_distance)
	walk._set_action_turn(4)
	walk.set_movement_zero(global_position)
	state_machine.Action_list['Walk'] = walk
	
	# TODO: Add character-specific ability
	# Example:
	# initialize_unique_ability()


func initialize_unique_ability() -> void:
	# Example: Teleport ability
	var teleport = ActionBasis.new()
	teleport.action_type = ActionBasis.ActionType.CAST
	teleport._set_move_speed(100.0)  # Instant
	teleport._set_move_distance(15.0)
	teleport._set_action_turn(3)  # Attack phase
	teleport.set_movement_zero(global_position)
	state_machine.Action_list['Ability1'] = teleport


## Health Management
func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()


func heal(amount: float) -> void:
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health, max_health)


func die() -> void:
	character_died.emit()
	# TODO: Death animation, effects, etc.
	queue_free()


## Action Execution
func execute_action(action_name: String) -> void:
	if not state_machine or not state_machine.Action_list.has(action_name):
		push_warning("Action not found: ", action_name)
		return
	
	var action = state_machine.Action_list[action_name]
	if action == null:
		push_warning("Action not initialized: ", action_name)
		return
	
	action_started.emit(action_name)
	
	# Execute based on action type
	match action.action_type:
		ActionBasis.ActionType.MOVE:
			execute_movement(action)
		ActionBasis.ActionType.SHOOT:
			execute_shoot(action)
		ActionBasis.ActionType.CAST:
			execute_cast(action)
		ActionBasis.ActionType.THROW:
			execute_throw(action)
		ActionBasis.ActionType.USE:
			execute_use(action)


func execute_movement(action: ActionBasis) -> void:
	# Movement handled by point_and_click_mover or similar
	print("Executing movement for: ", character_name)
	# TODO: Implement movement logic


func execute_shoot(action: ActionBasis) -> void:
	# TODO: Implement shooting logic
	print("Executing shoot for: ", character_name)


func execute_cast(action: ActionBasis) -> void:
	# TODO: Implement ability casting
	print("Executing cast for: ", character_name)


func execute_throw(action: ActionBasis) -> void:
	# TODO: Implement throw logic
	print("Executing throw for: ", character_name)


func execute_use(action: ActionBasis) -> void:
	# TODO: Implement item use logic
	print("Executing use for: ", character_name)


## Utility Functions
func get_available_actions() -> Array[String]:
	if not state_machine:
		return []
	
	var actions: Array[String] = []
	for action_name in state_machine.Action_list:
		if state_machine.Action_list[action_name] != null:
			actions.append(action_name)
	
	return actions


func is_action_ready(action_name: String) -> bool:
	if not state_machine or not state_machine.Action_list.has(action_name):
		return false
	
	return state_machine.Action_list[action_name] != null
