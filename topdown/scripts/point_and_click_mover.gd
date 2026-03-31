extends CharacterBody3D
@onready var camera_3d: Camera3D = $"../freeview_cam"
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var max_length = 20
@onready var is_moving : bool = false
@export var click_type: String = 'Movement'


signal movement_finished(name,bool_value)

# Prepare query objects.
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()

	var map: RID = get_world_3d().get_navigation_map()

	if NavigationServer3D.map_get_iteration_id(map) == 0:
		# This map has never synced and is empty, no point in querying it.
		return PackedVector3Array()

	query_parameters.map = map
	query_parameters.start_position = p_start_position
	query_parameters.target_position = p_target_position
	query_parameters.navigation_layers = p_navigation_layers

	NavigationServer3D.query_path(query_parameters, query_result)
	var path: PackedVector3Array = query_result.get_path()

	return path



func _unhandled_input(event: InputEvent) -> void:
	if click_type == 'Movement':
		if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_moving == false):
			#var cell = get_cell_item(event.position)
			#print('EVENT: %s \n cell: %s' % [event, cell])
			var pos = event.position
			var from =  camera_3d.project_ray_origin(pos)
			var to = from + camera_3d.project_ray_normal(pos) * 1000
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
			if len(result) > 0:
				print('Clicked Position: %s' % [result.position])
				move_navigation_to_target(result.position)
				
				print(query_path(position,result.position))
	else:
		print('cannot click')

	
	return

func StartMovement() -> void:
	if is_moving == false:
		set_is_moving(true)
	return

func get_world_pos_from_camera_view(event: InputEvent) -> Vector3:
	var pos = event.position
	var from =  camera_3d.project_ray_origin(pos)
	var to = from + camera_3d.project_ray_normal(pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	return result.position
		
	


func move_navigation_to_target(target_position: Vector3):
	var old_target_position = navigation_agent_3d.target_position
	navigation_agent_3d.set_target_position(target_position)
	navigation_agent_3d.get_next_path_position()
	var path_length = navigation_agent_3d.get_path_length()
	print('path length %s' % [path_length])
	if path_length > max_length:
		navigation_agent_3d.set_target_position(old_target_position)
		navigation_agent_3d.get_next_path_position()
		path_length = navigation_agent_3d.get_path_length()
		# double check??
		if path_length > max_length:
			navigation_agent_3d.set_target_position(position)
			navigation_agent_3d.get_next_path_position()
		
	#print('Target Position: %s' % [is_position_within_distance(target_position, 10)])
	return

func _process(_delta: float) -> void:
	#get desitation position
	var target_position = navigation_agent_3d.get_next_path_position()
	var local_position = target_position - global_position
	var direction = local_position.normalized()
	velocity = direction * 5
	if is_moving == true:
		move_and_slide()
		set_is_moving(not navigation_agent_3d.is_target_reached())
	return

func set_is_moving(value: bool) -> void:
	if value != is_moving:
		is_moving = value
		movement_finished.emit(name, not is_moving)
	elif value == is_moving:
		is_moving = value
		
func handle_ended_movement(name, bool_value) -> void:
	if bool_value:
		navigation_agent_3d.set_target_position(position)
	return
	


func _ready() -> void:
	move_navigation_to_target(position)
	movement_finished.connect(handle_ended_movement)
	return

func is_position_within_distance(target_pos: Vector3, distance: float) -> bool:
	var distance_to_position = position.distance_to(target_pos)
	print(distance_to_position)
	return distance_to_position <= distance


func _on_control_move_characters() -> void:
	StartMovement()
	return


func _on_character_1_pressed() -> void:
	pass # Replace with function body.
