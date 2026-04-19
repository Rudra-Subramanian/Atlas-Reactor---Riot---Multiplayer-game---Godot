## Level Template
## Use this to set up new game levels
## Attach to root Node of your level scene

extends Node

## TODO: Configure level settings
@export_group("Level Settings")
@export var level_name: String = "New Level"
@export var max_turns: int = 20
@export var current_turn: int = 1

@export_group("Team Setup")
@export var team1_characters: Array[PackedScene] = []
@export var team2_characters: Array[PackedScene] = []
@export var team1_spawn_points: Array[Vector3] = []
@export var team2_spawn_points: Array[Vector3] = []

@export_group("References")
@export var camera: Camera3D
@export var ui: Control
@export var navigation_region: NavigationRegion3D
@export var environment: WorldEnvironment

## Internal references
var spawned_team1: Array[Node3D] = []
var spawned_team2: Array[Node3D] = []
var region_display: MeshInstance3D

## Signals
signal level_loaded()
signal turn_started(turn_number: int)
signal turn_ended(turn_number: int)
signal level_completed(winning_team: int)


func _ready() -> void:
	print("Loading level: ", level_name)
	setup_level()
	await get_tree().process_frame  # Wait for navigation to sync
	spawn_teams()
	initialize_systems()
	level_loaded.emit()
	start_turn()


func setup_level() -> void:
	# TODO: Set up level-specific elements
	setup_environment()
	setup_navigation()
	setup_visuals()


func setup_environment() -> void:
	if not environment:
		environment = WorldEnvironment.new()
		add_child(environment)
	
	# TODO: Configure lighting, sky, etc.


func setup_navigation() -> void:
	if not navigation_region:
		push_warning("No NavigationRegion3D assigned!")
		return
	
	# Ensure navigation mesh is baked
	if navigation_region.navigation_mesh == null:
		push_error("NavigationRegion has no baked NavigationMesh!")


func setup_visuals() -> void:
	# Create movement visualization if needed
	if not region_display:
		region_display = MeshInstance3D.new()
		region_display.name = "RegionDisplay"
		add_child(region_display)
		
		# Add movement_decal script
		var decal_script = preload("res://scripts/movement_decal.gd")
		region_display.set_script(decal_script)


func spawn_teams() -> void:
	spawn_team(team1_characters, team1_spawn_points, 1)
	spawn_team(team2_characters, team2_spawn_points, 2)


func spawn_team(character_scenes: Array, spawn_points: Array, team_number: int) -> void:
	for i in range(min(character_scenes.size(), spawn_points.size())):
		var character_scene = character_scenes[i]
		var spawn_point = spawn_points[i]
		
		if character_scene:
			var character = character_scene.instantiate()
			add_child(character)
			character.global_position = spawn_point
			character.add_to_group("team" + str(team_number))
			
			if team_number == 1:
				spawned_team1.append(character)
			else:
				spawned_team2.append(character)
			
			print("Spawned ", character.name, " at ", spawn_point)


func initialize_systems() -> void:
	# Initialize UI
	if ui:
		if camera:
			ui.initialize_camera(camera)
		
		# Use spawned team1 as player-controlled
		if spawned_team1.size() > 0:
			ui.initialize_character_list(spawned_team1)
		
		if region_display:
			ui.region_display = region_display
	
	# Initialize Camera
	if camera:
		for i in range(spawned_team1.size()):
			if camera.has_method("assign_player"):
				camera.assign_player(i, spawned_team1[i])


## Turn Management

func start_turn() -> void:
	print("\n=== Turn ", current_turn, " ===")
	turn_started.emit(current_turn)
	
	# TODO: Enable player input
	if ui:
		ui.EnableActions()


func end_turn() -> void:
	turn_ended.emit(current_turn)
	current_turn += 1
	
	# Check win conditions
	if check_victory():
		return
	
	# Check turn limit
	if current_turn > max_turns:
		end_level(0)  # Draw
		return
	
	# Start next turn
	start_turn()


func execute_turn() -> void:
	print("Executing turn actions...")
	
	# TODO: Execute all queued actions
	# Phase 1: Prep actions
	# Phase 2: Dash actions
	# Phase 3: Attack actions
	# Phase 4: Movement actions
	
	await get_tree().create_timer(2.0).timeout  # Simulate execution time
	end_turn()


## Victory Conditions

func check_victory() -> bool:
	var team1_alive = count_alive_characters(spawned_team1)
	var team2_alive = count_alive_characters(spawned_team2)
	
	if team1_alive == 0 and team2_alive > 0:
		end_level(2)  # Team 2 wins
		return true
	elif team2_alive == 0 and team1_alive > 0:
		end_level(1)  # Team 1 wins
		return true
	elif team1_alive == 0 and team2_alive == 0:
		end_level(0)  # Draw
		return true
	
	return false


func count_alive_characters(team: Array) -> int:
	var count = 0
	for character in team:
		if is_instance_valid(character):
			count += 1
	return count


func end_level(winning_team: int) -> void:
	var result_text = ""
	match winning_team:
		0: result_text = "Draw!"
		1: result_text = "Team 1 Wins!"
		2: result_text = "Team 2 Wins!"
	
	print("\n=== GAME OVER ===")
	print(result_text)
	
	level_completed.emit(winning_team)
	
	# TODO: Show results screen


## Utility Functions

func get_all_characters() -> Array[Node3D]:
	var all_chars: Array[Node3D] = []
	all_chars.append_array(spawned_team1)
	all_chars.append_array(spawned_team2)
	return all_chars


func find_character_by_name(char_name: String) -> Node3D:
	for character in get_all_characters():
		if character.name == char_name:
			return character
	return null


func get_characters_in_radius(center: Vector3, radius: float) -> Array[Node3D]:
	var nearby: Array[Node3D] = []
	for character in get_all_characters():
		if character.global_position.distance_to(center) <= radius:
			nearby.append(character)
	return nearby
