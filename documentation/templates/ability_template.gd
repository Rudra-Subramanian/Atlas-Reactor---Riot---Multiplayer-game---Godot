## Ability System Template
## Create custom abilities for characters
## Based on ActionBasis system

extends Node

class_name AbilityTemplate

## Ability Configuration
@export_group("Ability Settings")
@export var ability_name: String = "Custom Ability"
@export var ability_description: String = "Description of what this ability does"
@export var cooldown_turns: int = 3
@export var current_cooldown: int = 0

@export_group("Range and Targeting")
@export var ability_range: float = 10.0
@export var area_of_effect: float = 3.0
@export var requires_line_of_sight: bool = true
@export var targeting_mode: TargetingMode = TargetingMode.SINGLE_TARGET

@export_group("Effects")
@export var damage: float = 0.0
@export var healing: float = 0.0
@export var status_effects: Array[String] = []

enum TargetingMode {
	SINGLE_TARGET,      # Target one character
	AREA_OF_EFFECT,     # Target a position, affects area
	LINE,               # Target in a line
	CONE,               # Cone-shaped area
	SELF,               # Only affects caster
	ALL_ENEMIES,        # All enemy characters
	ALL_ALLIES          # All ally characters
}

## Signals
signal ability_used(caster: Node3D, targets: Array)
signal ability_hit(target: Node3D, damage_dealt: float)
signal cooldown_ready()


## Create ActionBasis for this ability
func create_ability_action(caster_position: Vector3) -> ActionBasis:
	var action = ActionBasis.new()
	action.action_type = ActionBasis.ActionType.CAST
	action._set_move_speed(0.0)  # Abilities don't move
	action._set_move_distance(ability_range)
	action._set_action_turn(3)  # Execute in Attack phase
	action.set_movement_zero(caster_position)
	return action


## Check if ability can be used
func can_use(caster: Node3D) -> bool:
	if current_cooldown > 0:
		print(ability_name, " is on cooldown: ", current_cooldown, " turns left")
		return false
	
	# TODO: Add other conditions (mana, prerequisites, etc.)
	return true


## Execute the ability
func use_ability(caster: Node3D, target_position: Vector3) -> void:
	if not can_use(caster):
		return
	
	# Validation
	if not is_in_range(caster.global_position, target_position):
		print("Target out of range!")
		return
	
	if requires_line_of_sight and not has_line_of_sight(caster.global_position, target_position):
		print("No line of sight!")
		return
	
	# Find targets
	var targets = get_targets(caster, target_position)
	
	# Apply effects
	for target in targets:
		apply_effects(caster, target)
	
	# Trigger cooldown
	current_cooldown = cooldown_turns
	
	# Emit signal
	ability_used.emit(caster, targets)
	
	# TODO: Play ability animation/VFX


## Targeting Logic

func is_in_range(from: Vector3, to: Vector3) -> bool:
	return from.distance_to(to) <= ability_range


func has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Only check terrain layer
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()  # True if no obstacles


func get_targets(caster: Node3D, target_position: Vector3) -> Array:
	match targeting_mode:
		TargetingMode.SINGLE_TARGET:
			return get_single_target(target_position)
		TargetingMode.AREA_OF_EFFECT:
			return get_area_targets(target_position)
		TargetingMode.LINE:
			return get_line_targets(caster.global_position, target_position)
		TargetingMode.CONE:
			return get_cone_targets(caster.global_position, target_position)
		TargetingMode.SELF:
			return [caster]
		TargetingMode.ALL_ENEMIES:
			return get_all_enemies(caster)
		TargetingMode.ALL_ALLIES:
			return get_all_allies(caster)
	
	return []


func get_single_target(position: Vector3) -> Array:
	# Find closest character to position
	var characters = get_tree().get_nodes_in_group("characters")
	var closest = null
	var closest_dist = INF
	
	for char in characters:
		var dist = char.global_position.distance_to(position)
		if dist < closest_dist and dist < 1.0:  # Within 1 unit
			closest = char
			closest_dist = dist
	
	return [closest] if closest else []


func get_area_targets(center: Vector3) -> Array:
	var targets = []
	var characters = get_tree().get_nodes_in_group("characters")
	
	for char in characters:
		if char.global_position.distance_to(center) <= area_of_effect:
			targets.append(char)
	
	return targets


func get_line_targets(from: Vector3, to: Vector3) -> Array:
	var targets = []
	var direction = (to - from).normalized()
	var characters = get_tree().get_nodes_in_group("characters")
	
	for char in characters:
		var to_char = char.global_position - from
		var projection = to_char.dot(direction)
		
		if projection > 0 and projection <= ability_range:
			var perpendicular_dist = to_char.distance_to(direction * projection)
			if perpendicular_dist < 1.0:  # Line width
				targets.append(char)
	
	return targets


func get_cone_targets(from: Vector3, to: Vector3) -> Array:
	var targets = []
	var direction = (to - from).normalized()
	var cone_angle = deg_to_rad(45)  # 45-degree cone
	var characters = get_tree().get_nodes_in_group("characters")
	
	for char in characters:
		var to_char = (char.global_position - from).normalized()
		var angle = acos(direction.dot(to_char))
		var distance = from.distance_to(char.global_position)
		
		if angle <= cone_angle and distance <= ability_range:
			targets.append(char)
	
	return targets


func get_all_enemies(caster: Node3D) -> Array:
	var enemies = []
	var caster_team = get_character_team(caster)
	var characters = get_tree().get_nodes_in_group("characters")
	
	for char in characters:
		if get_character_team(char) != caster_team:
			enemies.append(char)
	
	return enemies


func get_all_allies(caster: Node3D) -> Array:
	var allies = []
	var caster_team = get_character_team(caster)
	var characters = get_tree().get_nodes_in_group("characters")
	
	for char in characters:
		if get_character_team(char) == caster_team and char != caster:
			allies.append(char)
	
	return allies


func get_character_team(character: Node3D) -> int:
	if character.is_in_group("team1"):
		return 1
	elif character.is_in_group("team2"):
		return 2
	return 0


## Effect Application

func apply_effects(caster: Node3D, target: Node3D) -> void:
	if damage > 0:
		apply_damage(target, damage)
	
	if healing > 0:
		apply_healing(target, healing)
	
	for status in status_effects:
		apply_status(target, status)


func apply_damage(target: Node3D, amount: float) -> void:
	if target.has_method("take_damage"):
		target.take_damage(amount)
		ability_hit.emit(target, amount)
		print(ability_name, " dealt ", amount, " damage to ", target.name)


func apply_healing(target: Node3D, amount: float) -> void:
	if target.has_method("heal"):
		target.heal(amount)
		print(ability_name, " healed ", target.name, " for ", amount)


func apply_status(target: Node3D, status_name: String) -> void:
	# TODO: Implement status effect system
	print("Applied ", status_name, " to ", target.name)


## Cooldown Management

func tick_cooldown() -> void:
	if current_cooldown > 0:
		current_cooldown -= 1
		if current_cooldown == 0:
			cooldown_ready.emit()
			print(ability_name, " ready!")


func reset_cooldown() -> void:
	current_cooldown = 0


## Example Abilities

static func create_fireball() -> AbilityTemplate:
	var ability = AbilityTemplate.new()
	ability.ability_name = "Fireball"
	ability.ability_description = "Launch a fireball dealing 30 damage"
	ability.ability_range = 15.0
	ability.area_of_effect = 3.0
	ability.damage = 30.0
	ability.cooldown_turns = 2
	ability.targeting_mode = TargetingMode.AREA_OF_EFFECT
	return ability


static func create_heal() -> AbilityTemplate:
	var ability = AbilityTemplate.new()
	ability.ability_name = "Heal"
	ability.ability_description = "Restore 40 health to target ally"
	ability.ability_range = 10.0
	ability.healing = 40.0
	ability.cooldown_turns = 3
	ability.targeting_mode = TargetingMode.SINGLE_TARGET
	return ability


static func create_dash() -> AbilityTemplate:
	var ability = AbilityTemplate.new()
	ability.ability_name = "Combat Dash"
	ability.ability_description = "Quickly dash forward"
	ability.ability_range = 8.0
	ability.cooldown_turns = 1
	ability.targeting_mode = TargetingMode.SELF
	return ability
